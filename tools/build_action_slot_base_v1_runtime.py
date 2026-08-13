#!/usr/bin/env python3
"""Deterministically export and review the accepted AB.SLOT.BASE.V1 source.

The exporter is intentionally narrow: it performs the accepted square crop,
one proportional LANCZOS resize, transparent-RGB cleanup, and a 32-bit TGA
write.  Representative icons and states are added only to ignored previews.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, ImageFont

from review_action_slot_base_candidate_v1 import (
    alpha_bbox,
    load_extended_spec,
    paste_button,
    render_scenario,
    scenario_geometry,
)


SOURCE_REL = Path(
    "assets/source/actionbars/ab-slot/ActionSlotBase_Master_v1.png"
)
SOURCE_MANIFEST_REL = Path(
    "assets/source/actionbars/ab-slot/AB-SLOT-BASE-V1_SourceManifest_v1.json"
)
RUNTIME_MANIFEST_REL = Path(
    "assets/source/actionbars/ab-slot/AB-SLOT-BASE-V1_RuntimeManifest_v1.json"
)
RUNTIME_REL = Path(
    "addon/AzerothExpeditionUI/Media/ActionBars/ActionSlotBaseV1.tga"
)
ADAPTER_REL = Path("addon/AzerothExpeditionUI/Modules/ActionBars.lua")
SPEC_REL = Path("tools/specs/action_slot_base_v1_candidate_review.json")
DISPLAY_CONTRACT_REL = Path(
    "tools/specs/action_slot_base_v1_runtime_display_region.json"
)
DISPLAY_VALIDATOR_REL = Path(
    ".codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py"
)
SIMULATION_RENDERER_REL = Path("tools/render_action_bars_simulation.py")
PREVIEW_REL = Path(
    "generated/actionbars/AB.SLOT/AB.SLOT.BASE.V1/runtime/V1"
)

EXPECTED_SOURCE_SHA256 = (
    "6d4a4d16e9a9c11248f0c63636e916e462d5d64f548335f26252e19e0b787dc0"
)
EXPECTED_SOURCE_SIZE = (1024, 1024)
EXPECTED_SOURCE_VISIBLE_BBOX = (200, 202, 824, 822)
SOURCE_CROP = (200, 200, 824, 824)
RUNTIME_SIZE = (128, 128)
EXPECTED_RUNTIME_PIXEL_SHA256 = (
    "e527c0382a7e7d727fa8a8cee10262cd99470d1ee0204ba8301a5f698c24c35c"
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument(
        "--write-display-contract",
        action="store_true",
        help="write the reviewed static final-runtime display contract",
    )
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def repo_path(root: Path, path: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def alpha_evidence(image: Image.Image) -> dict[str, int]:
    histogram = image.convert("RGBA").getchannel("A").histogram()
    return {
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
    }


def visible_green_spill_pixels(image: Image.Image) -> int:
    count = 0
    for red, green, blue, alpha in image.convert("RGBA").getdata():
        if alpha and red <= 32 and green >= 224 and blue <= 32:
            count += 1
    return count


def transparent_rgb_nonzero_values(image: Image.Image) -> int:
    count = 0
    for red, green, blue, alpha in image.convert("RGBA").getdata():
        if not alpha:
            count += int(bool(red)) + int(bool(green)) + int(bool(blue))
    return count


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    data = bytearray(image.convert("RGBA").tobytes())
    for offset in range(0, len(data), 4):
        if data[offset + 3] == 0:
            data[offset : offset + 3] = b"\0\0\0"
    return Image.frombytes("RGBA", image.size, bytes(data))


def validate_source(path: Path) -> Image.Image:
    if sha256(path) != EXPECTED_SOURCE_SHA256:
        raise ValueError("accepted AB.SLOT source SHA-256 changed")
    with Image.open(path) as opened:
        if opened.size != EXPECTED_SOURCE_SIZE or opened.mode != "RGBA":
            raise ValueError("accepted AB.SLOT source must remain 1024x1024 RGBA")
        source = opened.copy()
    if alpha_bbox(source) != EXPECTED_SOURCE_VISIBLE_BBOX:
        raise ValueError("accepted AB.SLOT visible bbox changed")
    if visible_green_spill_pixels(source):
        raise ValueError("accepted AB.SLOT source contains visible chroma green")
    if transparent_rgb_nonzero_values(source):
        raise ValueError("accepted AB.SLOT source has non-zero transparent RGB")
    return source


def build_runtime(source: Image.Image) -> Image.Image:
    crop = source.crop(SOURCE_CROP)
    if crop.size != (624, 624):
        raise AssertionError("AB.SLOT source crop must be 624x624")
    runtime = clear_transparent_rgb(
        crop.resize(RUNTIME_SIZE, Image.Resampling.LANCZOS)
    )
    if pixel_sha256(runtime) != EXPECTED_RUNTIME_PIXEL_SHA256:
        raise ValueError("runtime pixels differ from accepted attempt-05 review")
    if alpha_bbox(runtime) != (0, 0, 128, 128):
        raise ValueError("runtime alpha no longer covers the full-UV sample")
    if visible_green_spill_pixels(runtime):
        raise ValueError("runtime contains visible chroma green")
    if transparent_rgb_nonzero_values(runtime):
        raise ValueError("runtime has non-zero transparent RGB")
    return runtime


def write_runtime_tga(runtime: Image.Image, path: Path) -> dict[str, Any]:
    path.parent.mkdir(parents=True, exist_ok=True)
    runtime.save(path, format="TGA")
    header = path.read_bytes()[:18]
    if len(header) != 18 or header[16] != 32:
        raise ValueError("runtime TGA is not 32-bit RGBA")
    with Image.open(path) as opened:
        roundtrip = opened.convert("RGBA")
    if roundtrip.size != RUNTIME_SIZE or roundtrip.tobytes() != runtime.tobytes():
        raise ValueError("runtime TGA roundtrip changed pixels")
    return {
        "file": str(RUNTIME_REL).replace("\\", "/"),
        "sha256": sha256(path),
        "width": 128,
        "height": 128,
        "mode": "RGBA",
        "bits_per_pixel": int(header[16]),
        "descriptor": int(header[17]),
        "top_origin": bool(header[17] & 0x20),
        "pixel_sha256": pixel_sha256(roundtrip),
        "visible_bbox_exclusive": list(alpha_bbox(roundtrip)),
        "visible_green_spill_pixels": visible_green_spill_pixels(roundtrip),
        "transparent_rgb_nonzero_values": transparent_rgb_nonzero_values(
            roundtrip
        ),
        **alpha_evidence(roundtrip),
    }


def ensure_simulation(root: Path, spec: dict[str, Any], preview_dir: Path) -> Path:
    output = preview_dir / "action-bars-core-simulation-v3.png"
    report = preview_dir / "action-bars-core-simulation-v3.layout.json"
    simulation_spec = root / spec["target"]["simulation_spec"]
    subprocess.run(
        [
            sys.executable,
            str(root / SIMULATION_RENDERER_REL),
            str(simulation_spec),
            "--repo-root",
            str(root),
            "--output",
            str(output),
            "--layout-report",
            str(report),
        ],
        cwd=root,
        check=True,
    )
    return output


def render_board(previews: list[dict[str, Any]], output: Path) -> None:
    board = Image.new("RGBA", (1600, 900), (17, 22, 20, 255))
    draw = ImageDraw.Draw(board, "RGBA")
    title = ImageFont.load_default(size=24)
    body = ImageFont.load_default(size=14)
    draw.text(
        (34, 24),
        "AB.SLOT.BASE.V1 accepted runtime - exact provider layouts",
        font=title,
        fill=(235, 211, 157, 255),
    )
    draw.text(
        (34, 58),
        "TGA pixels: slot base only. Icons, text and states: provider-owned preview content.",
        font=body,
        fill=(183, 192, 179, 255),
    )
    positions = [(40, 110), (360, 110), (250, 330), (690, 330), (1320, 110)]
    for item, position in zip(previews, positions):
        with Image.open(item["path"]) as opened:
            image = opened.convert("RGBA")
        x, y = position
        draw.text(
            (x, y - 24),
            f"{item['id']}  exact={image.width}x{image.height}px",
            font=body,
            fill=(231, 225, 206, 255),
        )
        board.alpha_composite(image, (x, y))
        zoom = min(3, max(1, 260 // max(image.width, image.height)))
        if zoom > 1:
            enlarged = image.resize(
                (image.width * zoom, image.height * zoom),
                Image.Resampling.NEAREST,
            )
            zx = min(1590 - enlarged.width, x + image.width + 24)
            board.alpha_composite(enlarged, (zx, y))
            draw.text(
                (zx, y + enlarged.height + 4),
                f"{zoom}x inspection only",
                font=body,
                fill=(151, 160, 150, 255),
            )
    output.parent.mkdir(parents=True, exist_ok=True)
    board.save(output)


def render_full_screen(
    root: Path,
    spec: dict[str, Any],
    runtime: Image.Image,
    simulation: Path,
    output: Path,
) -> list[dict[str, Any]]:
    with Image.open(simulation) as opened:
        scene = opened.convert("RGBA")
    simulation_spec = load_extended_spec(
        root / spec["target"]["simulation_spec"], root
    )
    ui_scale = float(spec["target"]["ui_scale"])
    records: list[dict[str, Any]] = []
    for bar in simulation_spec["bars"]:
        if str(bar["id"]) == "AB.BAR11.STANCE":
            continue
        geometry = scenario_geometry(
            {
                "buttons": bar["buttons"],
                "cols": bar["cols"],
                "rows": bar["rows"],
                "icon_ui": bar["icon_ui"],
                "border_ui": bar["border_ui"],
                "spacing_ui": bar["spacing_ui"],
                "local_scale": bar["scale"],
            },
            ui_scale,
        )
        origin = tuple(bar["screen_origin"])
        buttons = []
        for index, local_box in enumerate(geometry["boxes"]):
            box = (
                origin[0] + local_box[0],
                origin[1] + local_box[1],
                origin[0] + local_box[2],
                origin[1] + local_box[3],
            )
            buttons.append(
                paste_button(
                    scene,
                    runtime,
                    box,
                    int(geometry["icon_px"]),
                    index,
                    str(bar["states"][index]),
                    str(bar["keys"][index]),
                )
            )
        records.append(
            {"bar": bar["id"], "origin": list(origin), "buttons": buttons}
        )
    draw = ImageDraw.Draw(scene, "RGBA")
    font = ImageFont.load_default(size=13)
    draw.rounded_rectangle(
        (1330, 1000, 1904, 1064),
        radius=6,
        fill=(11, 14, 13, 230),
        outline=(128, 91, 49, 230),
        width=2,
    )
    draw.text(
        (1344, 1012),
        "AB.SLOT accepted runtime TGA @ exact target-device scale",
        font=font,
        fill=(238, 218, 169, 255),
    )
    draw.text(
        (1344, 1036),
        "Surrounding V3 geometry is direction-only; slot pixels are final runtime.",
        font=font,
        fill=(186, 192, 177, 255),
    )
    output.parent.mkdir(parents=True, exist_ok=True)
    scene.save(output)
    return records


def build_display_contract(
    spec: dict[str, Any],
    scenario_records: list[dict[str, Any]],
    full_screen_rel: str,
) -> dict[str, Any]:
    contract: dict[str, Any] = {
        "schema": "aeui-display-region-contract-v1",
        "component": "AB.SLOT.BASE.V1/runtime-v1",
        "coordinate_system": (
            "top-left-origin, right-bottom-exclusive, target-device physical pixels"
        ),
        "evidence": {
            "provider": (
                "addon/pfUI/api/api.lua BarLayoutSize + BarButtonAnchor; "
                "addon/pfUI/modules/actionbar.lua"
            ),
            "adapter": "addon/AzerothExpeditionUI/Modules/ActionBars.lua",
            "layout_formula": (
                "frame=(icon+2*border+spacing)*cols+spacing; "
                "backdrop=(icon+2*border); dimensions multiplied by UI scale "
                "and local bar scale"
            ),
            "target": "1920x1080; UI scale 0.81269841269841",
            "runtime_sampling": (
                "single 128x128 straight-alpha TGA sampled at full UV; no atlas "
                "cells and no nine-slice"
            ),
            "runtime_scope": (
                "pfUI logical Bars 1-10 only; stance Bar 11 and pet Bar 12 excluded"
            ),
            "dynamic_ownership": (
                "icons, keybinds, counts, macro names, cooldowns, highlight, active, "
                "equipped, range, OOM and pressed feedback remain provider-owned"
            ),
            "real_layout_preview": full_screen_rel,
            "final_runtime": True,
        },
        "atlas": {
            "size": [128, 128],
            "visible_bbox": [0, 0, 128, 128],
            "require_exact_visible_coverage": True,
            "sampled_regions": [
                {"id": "AB.SLOT.full-uv", "box": [0, 0, 128, 128]}
            ],
        },
        "nine_slice": {
            "caps": {"left": 1, "right": 1, "top": 1, "bottom": 1},
            "minimum_frame_size": [3, 3],
        },
        "scenarios": [],
    }
    for record in scenario_records:
        width, height = record["frame_px"]
        scenario: dict[str, Any] = {
            "id": record["id"],
            "frame": [width, height],
            "preview_frame": [width, height],
            "zones": {"bar-frame": [0, 0, width, height]},
            "regions": [],
        }
        for index, button in enumerate(record["buttons"], start=1):
            for suffix, kind in (
                ("backdrop", "texture"),
                ("icon", "icon"),
                ("hit", "button"),
            ):
                zone = f"button-{index}.{suffix}-safe"
                scenario["zones"][zone] = button[suffix]
                scenario["regions"].append(
                    {
                        "id": f"button-{index}.{suffix}",
                        "kind": kind,
                        "box": button[suffix],
                        "zone": zone,
                    }
                )
        contract["scenarios"].append(scenario)
    return contract


def update_source_manifest(
    root: Path,
    runtime_record: dict[str, Any],
    exporter_sha: str,
    display_contract_path: Path,
    display_report_path: Path,
    package_validation: dict[str, Any] | None,
) -> None:
    path = root / SOURCE_MANIFEST_REL
    manifest = load_json(path)
    game_validated = manifest.get("p6_validation", {}).get("status") == "pass"
    manifest["status"] = "game-validated" if game_validated else "runtime-exported"
    manifest["workflow_state"] = manifest["status"]
    manifest["project_phase"] = "P6" if game_validated else "P5"
    manifest["export_contract"] = {
        "status": "exported",
        "authorization": "user instruction '进行下一步' on 2026-08-08",
        "exporter": "tools/build_action_slot_base_v1_runtime.py",
        "exporter_sha256": exporter_sha,
        "runtime_file": runtime_record["file"],
        "runtime_sha256": runtime_record["sha256"],
        "source_square_crop_exclusive": list(SOURCE_CROP),
        "runtime_size": list(RUNTIME_SIZE),
        "resample": "Pillow Image.Resampling.LANCZOS",
        "sampling": (
            "one straight-alpha texture sampled at full UV; no atlas and no nine-slice"
        ),
        "operation": (
            "crop the declared 624x624 square, proportionally resize once to "
            "128x128, preserve straight Alpha, clear fully transparent RGB, "
            "and export as a tracked 32-bit TGA"
        ),
        "imagegen_calls_after_acceptance": 0,
        "allowed": [
            "the declared square crop without removing visible accepted pixels",
            "one proportional deterministic resize to 128x128",
            "fully transparent RGB zeroing without changing visible RGB or Alpha",
            "full-UV sampling beneath the live icon",
        ],
        "forbidden_runtime_uses": [
            "load the 1024x1024 source directly in Turtle WoW",
            "redraw, rotate, mirror, non-uniformly stretch or recolor the source",
            "derive fake disabled, range, mana, equipped, selected or cooldown cells",
            "bake icons, keybinds, counts, macro names, cooldowns or state colours",
            "replace provider Buttons, hit regions, scripts, paging, drag behavior or SavedVariables",
            "apply the source to stance, pet, AutoBar, TrinketMenu, castbar, swingtimer or DoiteDPS objects without their own contracts",
        ],
    }
    manifest["runtime_exports"] = {
        "action_slot_base_v1": runtime_record,
    }
    manifest["p5_validation"] = {
        "display_region_contract": repo_path(root, display_contract_path),
        "display_region_contract_sha256": sha256(display_contract_path),
        "display_region_report": repo_path(root, display_report_path),
        "display_region_report_sha256": sha256(display_report_path),
        "real_layout_scenarios": "5/5 pass",
        "display_region_violations": 0,
        "addon_package": package_validation,
        "game_validated": game_validated,
    }
    write_json(path, manifest)


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    source_path = root / SOURCE_REL
    runtime_path = root / RUNTIME_REL
    runtime_manifest_path = root / RUNTIME_MANIFEST_REL
    display_contract_path = root / DISPLAY_CONTRACT_REL
    preview_dir = root / PREVIEW_REL
    preview_dir.mkdir(parents=True, exist_ok=True)

    source = validate_source(source_path)
    runtime = build_runtime(source)
    runtime_record = write_runtime_tga(runtime, runtime_path)
    runtime_png = preview_dir / "AB.SLOT.BASE.V1.runtime-v1.png"
    runtime.save(runtime_png)

    spec = load_json(root / SPEC_REL)
    ui_scale = float(spec["target"]["ui_scale"])
    layouts_dir = preview_dir / "layouts"
    scenario_records: list[dict[str, Any]] = []
    preview_inventory: list[dict[str, Any]] = []
    for scenario in spec["scenarios"]:
        geometry = scenario_geometry(scenario, ui_scale)
        path = layouts_dir / (
            f"{scenario['id']}.{geometry['frame_px'][0]}x"
            f"{geometry['frame_px'][1]}.png"
        )
        buttons = render_scenario(scenario, geometry, runtime, path)
        record = {
            "id": scenario["id"],
            "frame_ui": geometry["frame_ui"],
            "frame_px": geometry["frame_px"],
            "outer_px": geometry["outer_px"],
            "icon_px": geometry["icon_px"],
            "buttons": buttons,
            "path": repo_path(root, path),
            "sha256": sha256(path),
        }
        scenario_records.append(record)
        preview_inventory.append({"id": scenario["id"], "path": path})

    board_path = preview_dir / "AB.SLOT.BASE.V1.runtime-v1.layouts.png"
    render_board(preview_inventory, board_path)
    simulation = ensure_simulation(root, spec, preview_dir)
    full_screen_path = (
        preview_dir / "AB.SLOT.BASE.V1.runtime-v1.real-layout-1920x1080.png"
    )
    render_full_screen(root, spec, runtime, simulation, full_screen_path)

    contract = build_display_contract(
        spec, scenario_records, repo_path(root, full_screen_path)
    )
    if args.write_display_contract:
        write_json(display_contract_path, contract)
    elif not display_contract_path.is_file():
        raise FileNotFoundError(
            "tracked display contract is missing; review then rerun with "
            "--write-display-contract"
        )
    elif load_json(display_contract_path) != contract:
        raise ValueError(
            "runtime display contract drifted; inspect before using "
            "--write-display-contract"
        )

    display_report_path = preview_dir / "display-region-report.json"
    subprocess.run(
        [
            sys.executable,
            str(root / DISPLAY_VALIDATOR_REL),
            str(display_contract_path),
            "--report",
            str(display_report_path),
        ],
        cwd=root,
        check=True,
    )
    display_report = load_json(display_report_path)
    if (
        display_report.get("status") != "pass"
        or display_report.get("violations")
        or len(display_report.get("scenarios", [])) != 5
    ):
        raise ValueError("final runtime display-region gate did not pass 5/5")

    package_report_path = preview_dir / "addon-package-report.json"
    package_validation = None
    if package_report_path.is_file():
        package_report = load_json(package_report_path)
        if (
            package_report.get("status") != "pass"
            or package_report.get("violations")
            or package_report.get("build_required_on_target_device") is not False
        ):
            raise ValueError("fresh-checkout addon package evidence is not passing")
        package_validation = {
            "report": repo_path(root, package_report_path),
            "report_sha256": sha256(package_report_path),
            "status": "pass",
            "violations": 0,
            "build_required_on_target_device": False,
        }

    exporter_path = Path(__file__).resolve()
    exporter_sha = sha256(exporter_path)
    adapter_path = root / ADAPTER_REL
    if not adapter_path.is_file():
        raise FileNotFoundError("ActionBars runtime adapter must exist before export")
    source_manifest = load_json(root / SOURCE_MANIFEST_REL)
    p6_validation = source_manifest.get("p6_validation", {})
    game_validated = p6_validation.get("status") == "pass"
    game_validation = (
        {"status": "pass", "phase": "P6", **{
            key: value
            for key, value in p6_validation.items()
            if key != "status"
        }}
        if game_validated
        else {
            "status": "pending",
            "phase": "P6",
            "target": "Turtle WoW 1.18.1 / Interface 11200",
        }
    )
    runtime_manifest = {
        "schema_version": 1,
        "module": "actionbars",
        "batch": "AB.SLOT.BASE.V1",
        "version": "runtime-v1",
        "runtime_contract": "1.0",
        "status": "game-validated" if game_validated else "runtime-exported",
        "phase": "P6" if game_validated else "P5",
        "source": {
            "file": str(SOURCE_REL).replace("\\", "/"),
            "sha256": sha256(source_path),
            "width": source.width,
            "height": source.height,
            "mode": source.mode,
            "visible_bbox_exclusive": list(alpha_bbox(source)),
            "visible_green_spill_pixels": visible_green_spill_pixels(source),
            "transparent_rgb_nonzero_values": transparent_rgb_nonzero_values(
                source
            ),
            **alpha_evidence(source),
        },
        "transform": {
            "operation": (
                "fixed square crop, one proportional LANCZOS resize, then zero "
                "RGB only where Alpha is fully transparent"
            ),
            "source_crop_exclusive": list(SOURCE_CROP),
            "runtime_size": list(RUNTIME_SIZE),
            "resample": "Pillow Image.Resampling.LANCZOS",
            "rotation": None,
            "mirror": False,
            "retouch": False,
            "straight_alpha": True,
            "texcoord": {"left": 0.0, "right": 1.0, "top": 0.0, "bottom": 1.0},
        },
        "runtime_export": runtime_record,
        "deterministic_export": {
            "exporter": repo_path(root, exporter_path),
            "exporter_sha256": exporter_sha,
            "expected_runtime_pixel_sha256": EXPECTED_RUNTIME_PIXEL_SHA256,
            "pixel_identical_to_accepted_attempt_05_runtime_review": True,
            "imagegen_calls_after_acceptance": 0,
        },
        "adapter": {
            "file": str(ADAPTER_REL).replace("\\", "/"),
            "provider": "pfUI.bars and pfActionBar<BarName>Button1..12.backdrop",
            "logical_bars": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            "excluded_provider_bars": [11, 12],
            "maximum_texture_instances": 120,
            "parent": "each existing provider button.backdrop",
            "draw_layer": "ARTWORK on provider backdrop frame, beneath live button layers",
            "fallback": "native pfUI backdrop remains and is never removed",
            "geometry_writes_after_creation": False,
            "provider_behavior_replaced": False,
        },
        "provider_layers_preserved": [
            "icon",
            "equipped",
            "cooldown",
            "animation",
            "highlight",
            "active",
            "macro",
            "keybind",
            "count",
            "hit region",
            "scripts",
            "paging",
            "drag behavior",
            "SavedVariables",
        ],
        "display_evidence": {
            "contract": repo_path(root, display_contract_path),
            "contract_sha256": sha256(display_contract_path),
            "report": repo_path(root, display_report_path),
            "report_sha256": sha256(display_report_path),
            "runtime_master": repo_path(root, runtime_png),
            "runtime_master_sha256": sha256(runtime_png),
            "supported_layouts": repo_path(root, board_path),
            "supported_layouts_sha256": sha256(board_path),
            "real_layout": repo_path(root, full_screen_path),
            "real_layout_sha256": sha256(full_screen_path),
            "scenario_ids": [record["id"] for record in scenario_records],
            "scenario_frames": {
                record["id"]: record["frame_px"] for record in scenario_records
            },
            "full_screen_scope": (
                "all V3 action-button bars except provider-owned AB.BAR11.STANCE"
            ),
            "result": "5/5 pass",
            "violations": 0,
            "surrounding_pixels": (
                "V3 direction simulation only; not runtime art or visual authority"
            ),
        },
        "package_validation": package_validation,
        "game_validation": game_validation,
    }
    write_json(runtime_manifest_path, runtime_manifest)
    update_source_manifest(
        root,
        runtime_record,
        exporter_sha,
        display_contract_path,
        display_report_path,
        package_validation,
    )

    export_report = {
        "schema": "aeui-action-slot-runtime-export-report-v1",
        "status": "pass",
        "phase": "P6" if game_validated else "P5",
        "source": runtime_manifest["source"],
        "runtime": runtime_record,
        "display_region": {
            "contract": repo_path(root, display_contract_path),
            "report": repo_path(root, display_report_path),
            "scenarios": 5,
            "violations": 0,
        },
        "adapter": runtime_manifest["adapter"],
        "package_validation": package_validation,
        "imagegen_calls": 0,
        "game_validated": game_validated,
    }
    export_report_path = preview_dir / "runtime-export-report.json"
    write_json(export_report_path, export_report)
    print(json.dumps(export_report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
