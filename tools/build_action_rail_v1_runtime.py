#!/usr/bin/env python3
"""Deterministically export and review the accepted AB.RAIL.V1 source.

The exporter performs one proportional resize of the accepted 704-square
source crop, places it inside a power-of-two straight-alpha atlas, and writes
one tracked 32-bit TGA.  The nine runtime slices, representative action
buttons, and combat layout are assembled only in ignored review previews.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw

import render_action_rail_simulation as simulation
from review_action_slot_base_candidate_v1 import alpha_bbox


SOURCE_REL = Path(
    "assets/source/actionbars/ab-rail/ActionRail_Master_v1.png"
)
SOURCE_MANIFEST_REL = Path(
    "assets/source/actionbars/ab-rail/AB-RAIL-V1_SourceManifest_v1.json"
)
RUNTIME_MANIFEST_REL = Path(
    "assets/source/actionbars/ab-rail/AB-RAIL-V1_RuntimeManifest_v1.json"
)
RUNTIME_REL = Path(
    "addon/AzerothExpeditionUI/Media/ActionBars/ActionRailV1.tga"
)
ADAPTER_REL = Path("addon/AzerothExpeditionUI/Modules/ActionBars.lua")
BOOTSTRAP_REL = Path("addon/AzerothExpeditionUI/Core/Bootstrap.lua")
TOC_REL = Path("addon/AzerothExpeditionUI/AzerothExpeditionUI.toc")
SPEC_REL = Path("tools/specs/action_rail_v1_simulation.json")
DISPLAY_CONTRACT_REL = Path(
    "tools/specs/action_rail_v1_runtime_display_region.json"
)
DISPLAY_VALIDATOR_REL = Path(
    ".codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py"
)
PREVIEW_REL = Path("generated/actionbars/AB.RAIL/AB.RAIL.V1/runtime/V1")

EXPECTED_SOURCE_SHA256 = (
    "7c49995d45b88f5ac12020c4b158027674b7ab7ed6e44a992e643f2ef6bd32e9"
)
EXPECTED_SOURCE_SIZE = (1024, 1024)
SOURCE_CROP = (160, 160, 864, 864)
SOURCE_SLICE_BOUNDARIES = (0, 128, 576, 704)
RUNTIME_ATLAS_SIZE = (256, 256)
RUNTIME_OBJECT_BOX = (40, 40, 216, 216)
RUNTIME_SLICE_BOUNDARIES = (40, 72, 184, 216)
RUNTIME_CAP_UI = 6
EXPECTED_RUNTIME_PIXEL_SHA256 = (
    "1b09b93b0a229b416e7961da47d1c97e0e75280245efe2d6310a955132b09db5"
)

SLICE_NAMES = (
    "topLeft",
    "top",
    "topRight",
    "left",
    "center",
    "right",
    "bottomLeft",
    "bottom",
    "bottomRight",
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
    return sum(
        1
        for red, green, blue, alpha in image.convert("RGBA").getdata()
        if alpha and red <= 32 and green >= 224 and blue <= 32
    )


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
        raise ValueError("accepted AB.RAIL source SHA-256 changed")
    with Image.open(path) as opened:
        if opened.size != EXPECTED_SOURCE_SIZE or opened.mode != "RGBA":
            raise ValueError("accepted AB.RAIL source must remain 1024x1024 RGBA")
        source = opened.copy()
    if alpha_bbox(source) != SOURCE_CROP:
        raise ValueError("accepted AB.RAIL visible bbox changed")
    if visible_green_spill_pixels(source):
        raise ValueError("accepted AB.RAIL source contains visible chroma green")
    if transparent_rgb_nonzero_values(source):
        raise ValueError("accepted AB.RAIL source has non-zero transparent RGB")
    return source


def build_runtime(source: Image.Image) -> Image.Image:
    crop = source.crop(SOURCE_CROP)
    if crop.size != (704, 704):
        raise AssertionError("AB.RAIL source crop must be 704x704")
    reduced = clear_transparent_rgb(
        crop.resize((176, 176), Image.Resampling.LANCZOS)
    )
    atlas = Image.new("RGBA", RUNTIME_ATLAS_SIZE, (0, 0, 0, 0))
    atlas.alpha_composite(reduced, RUNTIME_OBJECT_BOX[:2])
    atlas = clear_transparent_rgb(atlas)
    if (
        EXPECTED_RUNTIME_PIXEL_SHA256
        and pixel_sha256(atlas) != EXPECTED_RUNTIME_PIXEL_SHA256
    ):
        raise ValueError("runtime atlas pixels differ from the frozen export")
    if alpha_bbox(atlas) != RUNTIME_OBJECT_BOX:
        raise ValueError("runtime atlas visible bbox changed")
    if visible_green_spill_pixels(atlas):
        raise ValueError("runtime atlas contains visible chroma green")
    if transparent_rgb_nonzero_values(atlas):
        raise ValueError("runtime atlas has non-zero transparent RGB")
    return atlas


def slice_boxes() -> dict[str, tuple[int, int, int, int]]:
    bounds = RUNTIME_SLICE_BOUNDARIES
    boxes: dict[str, tuple[int, int, int, int]] = {}
    index = 0
    for row in range(3):
        for column in range(3):
            boxes[SLICE_NAMES[index]] = (
                bounds[column],
                bounds[row],
                bounds[column + 1],
                bounds[row + 1],
            )
            index += 1
    return boxes


def texcoords() -> dict[str, list[float]]:
    width, height = RUNTIME_ATLAS_SIZE
    return {
        key: [
            box[0] / width,
            box[2] / width,
            box[1] / height,
            box[3] / height,
        ]
        for key, box in slice_boxes().items()
    }


def assemble_nine_slice(
    atlas: Image.Image, size: tuple[int, int], cap: int
) -> Image.Image:
    width, height = size
    if width < cap * 2 + 1 or height < cap * 2 + 1:
        raise ValueError(f"target {size} is smaller than positive nine-slice center")
    target_x = (0, cap, width - cap, width)
    target_y = (0, cap, height - cap, height)
    boxes = slice_boxes()
    output = Image.new("RGBA", size, (0, 0, 0, 0))
    index = 0
    for row in range(3):
        for column in range(3):
            source = atlas.crop(boxes[SLICE_NAMES[index]])
            target = (
                target_x[column],
                target_y[row],
                target_x[column + 1],
                target_y[row + 1],
            )
            resized = source.resize(
                (target[2] - target[0], target[3] - target[1]),
                Image.Resampling.LANCZOS,
            )
            output.alpha_composite(resized, target[:2])
            index += 1
    return output


def runtime_drawer(atlas: Image.Image):
    def draw(
        canvas: Image.Image,
        box: tuple[int, int, int, int],
        geometry: dict[str, Any],
        _palette: dict[str, str],
    ) -> None:
        x0, y0, x1, y1 = box
        assembled = assemble_nine_slice(
            atlas,
            (x1 - x0, y1 - y0),
            int(geometry["cap_px"]),
        )
        canvas.alpha_composite(assembled, (x0, y0))

    return draw


def write_runtime_tga(runtime: Image.Image, path: Path) -> dict[str, Any]:
    path.parent.mkdir(parents=True, exist_ok=True)
    runtime.save(path, format="TGA")
    header = path.read_bytes()[:18]
    if len(header) != 18 or header[16] != 32:
        raise ValueError("runtime TGA is not 32-bit RGBA")
    with Image.open(path) as opened:
        roundtrip = opened.convert("RGBA")
    if (
        roundtrip.size != RUNTIME_ATLAS_SIZE
        or roundtrip.tobytes() != runtime.tobytes()
    ):
        raise ValueError("runtime TGA roundtrip changed pixels")
    return {
        "file": RUNTIME_REL.as_posix(),
        "sha256": sha256(path),
        "width": RUNTIME_ATLAS_SIZE[0],
        "height": RUNTIME_ATLAS_SIZE[1],
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


def render_layout_board(
    root: Path,
    spec: dict[str, Any],
    slot_runtime: Image.Image,
    output: Path,
) -> list[dict[str, Any]]:
    board_spec = spec["layout_board"]
    board = Image.new(
        "RGBA",
        tuple(map(int, board_spec["size"])),
        simulation.rgba(board_spec["fill"]),
    )
    draw = ImageDraw.Draw(board, "RGBA")
    fonts = {
        name: simulation.font(root, spec, name) for name in spec["fonts"]
    }
    ui_scale = float(spec["target"]["ui_scale"])
    cap_ui = int(spec["rail_contract"]["runtime_cap_ui"])
    ornament_ui = int(spec["rail_contract"]["ornament_edge_ui"])
    draw.text(
        (38, 26),
        "AB.RAIL.V1 · 最终 runtime 九宫格排版",
        font=fonts["title"],
        fill=simulation.rgba("#ecd7a2"),
    )
    draw.text(
        (38, 68),
        "Rail 来自最终 TGA/UV；accepted AB.SLOT 与动态内容保持 provider 所有。",
        font=fonts["small"],
        fill=simulation.rgba("#bcb49d"),
    )

    records: list[dict[str, Any]] = []
    for config in spec["scenarios"]:
        geometry = simulation.rail_geometry(
            config, ui_scale, cap_ui, ornament_ui
        )
        preview, buttons = simulation.render_scenario(
            config, geometry, slot_runtime, spec["palette"]
        )
        x, y = map(int, config["board_origin"])
        draw.text(
            (x, y - 44),
            config["label"],
            font=fonts["small"],
            fill=simulation.rgba("#e4d2a7"),
        )
        draw.text(
            (x, y - 21),
            (
                f"rail={preview.width}×{preview.height}px · "
                f"cap={geometry['cap_px']}px · final runtime"
            ),
            font=fonts["tiny"],
            fill=simulation.rgba("#9fa99d"),
        )
        simulation.composite_with_checker(board, preview, (x, y))
        zoom = int(config.get("inspection_zoom", 1))
        if zoom > 1:
            enlarged = preview.resize(
                (preview.width * zoom, preview.height * zoom),
                Image.Resampling.NEAREST,
            )
            zx, zy = map(int, config["inspection_origin"])
            simulation.composite_with_checker(board, enlarged, (zx, zy))

        width, height = map(int, geometry["rail_frame_px"])
        boxes = [tuple(item["backdrop"]) for item in buttons]
        records.append(
            {
                "id": config["id"],
                "rail_frame_ui": geometry["rail_frame_ui"],
                "rail_frame_px": geometry["rail_frame_px"],
                "cap_px": geometry["cap_px"],
                "center_px": [
                    width - 2 * int(geometry["cap_px"]),
                    height - 2 * int(geometry["cap_px"]),
                ],
                "buttons": len(buttons),
                "button_regions_contained": all(
                    0 <= box[0] < box[2] <= width
                    and 0 <= box[1] < box[3] <= height
                    for box in boxes
                ),
                "layer_order": [
                    "AB.RAIL final runtime",
                    "AB.SLOT accepted runtime or provider fallback",
                    "provider dynamic icon/text/state",
                ],
            }
        )

    output.parent.mkdir(parents=True, exist_ok=True)
    board.convert("RGB").save(
        output, format="PNG", optimize=False, compress_level=9
    )
    return records


def render_previews(
    root: Path,
    spec: dict[str, Any],
    atlas: Image.Image,
    preview_dir: Path,
) -> tuple[Path, Path, list[dict[str, Any]], list[dict[str, Any]]]:
    with Image.open(root / spec["accepted_neighbor"]["path"]) as opened:
        slot_runtime = opened.convert("RGBA")
    review_spec = copy.deepcopy(spec)
    review_spec["scene_base_annotations"] = {
        "title": "AB.RAIL.V1 · 最终运行时承托轨",
        "subtitle": (
            "最终 Rail 只替换最低背景层；动作槽、冷却、距离红、按下反馈和命中区"
            "保持 provider 所有权"
        ),
        "note": "最终 TGA/UV · 100% 目标设备物理像素 · ImageGen 新增 0",
        "rules_title": "P5 runtime 复查",
        "rules": [
            "256² power-of-two atlas；只采样 [40,40,216,216) 的九个切片",
            "四边固定 6 UI cap；横、竖、多行保持同一视觉厚度",
            "Bar 1/6 合并背景只有整体外围，不出现内部中缝",
            "所有 Button、拖动、缩放、显隐、分页与 SavedVariables 均未替换",
        ],
    }
    review_spec["scene_annotation"] = {
        "box": [1325, 945, 1878, 1021],
        "title": "图层：final Rail → accepted Slot → provider 动态层",
        "body": "姿态／宠物栏槽位仍是 pfUI fallback；Rail 仅接管其已有背景。",
    }
    scene_path = preview_dir / "AB.RAIL.V1.runtime-v1.real-layout-1920x1080.png"
    layouts_path = preview_dir / "AB.RAIL.V1.runtime-v1.layouts.png"
    original_drawer = simulation.draw_rail
    simulation.draw_rail = runtime_drawer(atlas)
    try:
        scene_records = simulation.render_scene(
            root, review_spec, slot_runtime, scene_path
        )
        layout_records = render_layout_board(
            root, review_spec, slot_runtime, layouts_path
        )
    finally:
        simulation.draw_rail = original_drawer
    return scene_path, layouts_path, scene_records, layout_records


def build_display_contract(
    spec: dict[str, Any], scene_path: str, layouts_path: str
) -> dict[str, Any]:
    contract = simulation.build_display_contract(spec)
    contract["component"] = "AB.RAIL.V1/runtime-v1"
    contract["evidence"].update(
        {
            "adapter": ADAPTER_REL.as_posix(),
            "scene_simulation": scene_path,
            "layout_simulation": layouts_path,
            "atlas_role": (
                "final 256x256 straight-alpha power-of-two TGA; only the exact "
                "[40,40,216,216) visible object and its nine declared cells are sampled"
            ),
            "runtime_sampling": (
                "one proportional 704-to-176 LANCZOS resize; runtime cells "
                "32/112/32 pixels; fixed 6 UI-unit caps"
            ),
            "runtime_scope": (
                "pfUI Bars 1-12 existing bar.backdrop plus the existing Bar 1/6 "
                "mergedBackdrop.backdrop path"
            ),
            "final_runtime": True,
        }
    )
    contract["atlas"] = {
        "size": list(RUNTIME_ATLAS_SIZE),
        "visible_bbox": list(RUNTIME_OBJECT_BOX),
        "require_exact_visible_coverage": True,
        "sampled_regions": [
            {"id": f"AB.RAIL.{key}", "box": list(box)}
            for key, box in slice_boxes().items()
        ],
    }
    for scenario in contract["scenarios"]:
        scenario["zones"] = {
            key.replace(".ornament-safe", ".rail-corner-safe"): value
            for key, value in scenario["zones"].items()
        }
        for region in scenario["regions"]:
            region["id"] = region["id"].replace(
                ".ornament", ".rail-corner"
            )
            region["zone"] = region["zone"].replace(
                ".ornament-safe", ".rail-corner-safe"
            )
    return contract


def package_validation_record(
    root: Path, package_report_path: Path
) -> dict[str, Any] | None:
    if not package_report_path.is_file():
        return None
    package_report = load_json(package_report_path)
    if (
        package_report.get("status") != "pass"
        or package_report.get("violations")
        or package_report.get("build_required_on_target_device") is not False
    ):
        raise ValueError("fresh-checkout addon package evidence is not passing")
    return {
        "report": repo_path(root, package_report_path),
        "report_sha256": sha256(package_report_path),
        "status": "pass",
        "violations": 0,
        "build_required_on_target_device": False,
    }


def update_source_manifest(
    root: Path,
    runtime_record: dict[str, Any],
    exporter_sha: str,
    display_contract_path: Path,
    display_report_path: Path,
    scene_path: Path,
    layouts_path: Path,
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
        "authorization": "user instruction '进行下一步' on 2026-08-09",
        "exporter": "tools/build_action_rail_v1_runtime.py",
        "exporter_sha256": exporter_sha,
        "runtime_file": runtime_record["file"],
        "runtime_sha256": runtime_record["sha256"],
        "accepted_source_crop_exclusive": list(SOURCE_CROP),
        "accepted_source_crop_size": [704, 704],
        "source_nine_slice_boundaries": list(SOURCE_SLICE_BOUNDARIES),
        "source_corner_size": [128, 128],
        "source_stretch_center": [128, 128, 576, 576],
        "runtime_atlas_size": list(RUNTIME_ATLAS_SIZE),
        "runtime_visible_bbox_exclusive": list(RUNTIME_OBJECT_BOX),
        "runtime_nine_slice_boundaries": list(RUNTIME_SLICE_BOUNDARIES),
        "runtime_cell_sizes": [32, 112, 32],
        "runtime_uv": texcoords(),
        "runtime_cap_ui": RUNTIME_CAP_UI,
        "resample": "Pillow Image.Resampling.LANCZOS",
        "operation": (
            "crop the complete accepted 704x704 object, proportionally resize it "
            "once to 176x176, place it at [40,40,216,216) in a transparent "
            "256x256 atlas, clear only fully transparent RGB, and export a tracked "
            "32-bit TGA"
        ),
        "imagegen_calls_after_acceptance": 0,
        "allowed": [
            "the complete declared 704x704 crop without removing visible pixels",
            "one proportional deterministic resize by exactly one quarter",
            "power-of-two transparent atlas padding that is never sampled",
            "fully transparent RGB zeroing without changing visible RGB or Alpha",
            "nine-slice assembly behind provider-owned slots and dynamic content",
        ],
        "forbidden_runtime_uses": [
            "load the 1024x1024 source directly in Turtle WoW",
            "sample transparent atlas padding or omit any visible runtime cell",
            "redraw, rotate, mirror, recolor or non-uniformly distort the source",
            "introduce a fixed slot grid or a Bar 1/6 internal seam",
            "derive hover, pressed, cooldown, range, mana, equipped, active or disabled states",
            "bake icons, keybinds, counts, macro names, cooldowns or state colours",
            "replace provider Buttons, hit regions, scripts, paging, drag behavior, scale or SavedVariables",
            "apply the source to slots, gryphons, AutoBar, TrinketMenu, castbars, swing timers or DoiteDPS",
        ],
    }
    manifest["runtime_exports"] = {"action_rail_v1": runtime_record}
    manifest["p5_validation"] = {
        "display_region_contract": repo_path(root, display_contract_path),
        "display_region_contract_sha256": sha256(display_contract_path),
        "display_region_report": repo_path(root, display_report_path),
        "display_region_report_sha256": sha256(display_report_path),
        "real_layout_preview": repo_path(root, scene_path),
        "real_layout_preview_sha256": sha256(scene_path),
        "supported_layouts_preview": repo_path(root, layouts_path),
        "supported_layouts_preview_sha256": sha256(layouts_path),
        "real_layout_scenarios": "8/8 pass",
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
    runtime_png = preview_dir / "AB.RAIL.V1.runtime-v1.atlas.png"
    runtime.save(runtime_png)

    spec = load_json(root / SPEC_REL)
    scene_path, layouts_path, scene_records, layout_records = render_previews(
        root, spec, runtime, preview_dir
    )
    if len(layout_records) != 8:
        raise ValueError("final runtime review must cover all eight Rail scenarios")
    if not all(record["button_regions_contained"] for record in layout_records):
        raise ValueError("final runtime review contains an escaped button region")

    contract = build_display_contract(
        spec, repo_path(root, scene_path), repo_path(root, layouts_path)
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
        or display_report.get("summary", {}).get("scenario_count") != 8
    ):
        raise ValueError("final runtime display-region gate did not pass 8/8")

    package_report_path = preview_dir / "addon-package-report.json"
    package_validation = package_validation_record(root, package_report_path)
    exporter_path = Path(__file__).resolve()
    exporter_sha = sha256(exporter_path)
    adapter_path = root / ADAPTER_REL
    bootstrap_path = root / BOOTSTRAP_REL
    toc_path = root / TOC_REL
    for required in (adapter_path, bootstrap_path, toc_path):
        if not required.is_file():
            raise FileNotFoundError(f"required addon integration is missing: {required}")
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
        "batch": "AB.RAIL.V1",
        "version": "runtime-v1",
        "runtime_contract": "1.0",
        "status": "game-validated" if game_validated else "runtime-exported",
        "phase": "P6" if game_validated else "P5",
        "source": {
            "file": SOURCE_REL.as_posix(),
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
                "fixed 704-square crop, one proportional LANCZOS resize to "
                "176-square, paste into a transparent 256-square atlas, then zero "
                "RGB only where Alpha is fully transparent"
            ),
            "source_crop_exclusive": list(SOURCE_CROP),
            "source_slice_boundaries": list(SOURCE_SLICE_BOUNDARIES),
            "runtime_atlas_size": list(RUNTIME_ATLAS_SIZE),
            "runtime_visible_bbox_exclusive": list(RUNTIME_OBJECT_BOX),
            "runtime_slice_boundaries": list(RUNTIME_SLICE_BOUNDARIES),
            "runtime_cell_sizes": [32, 112, 32],
            "resample": "Pillow Image.Resampling.LANCZOS",
            "rotation": None,
            "mirror": False,
            "retouch": False,
            "straight_alpha": True,
            "texcoords": texcoords(),
            "runtime_cap_ui": RUNTIME_CAP_UI,
        },
        "runtime_export": runtime_record,
        "deterministic_export": {
            "exporter": repo_path(root, exporter_path),
            "exporter_sha256": exporter_sha,
            "expected_runtime_pixel_sha256": (
                EXPECTED_RUNTIME_PIXEL_SHA256 or runtime_record["pixel_sha256"]
            ),
            "one_proportional_resample": True,
            "imagegen_calls_after_acceptance": 0,
            "attempt_6_allowed": False,
        },
        "adapter": {
            "file": ADAPTER_REL.as_posix(),
            "provider": (
                "pfUI.bars[1..12].backdrop and "
                "pfUI.bars[1].mergedBackdrop.backdrop"
            ),
            "logical_bars": list(range(1, 13)),
            "merged_pair": [1, 6],
            "maximum_rail_backdrops": 13,
            "textures_per_rail": 9,
            "maximum_texture_instances": 117,
            "parent": "each existing provider backdrop frame",
            "draw_layer": (
                "OVERLAY on the provider backdrop frame, still beneath live "
                "button and slot-backdrop frame levels"
            ),
            "fallback": (
                "native pfUI backdrop remains and is never removed; missing "
                "provider objects or disabled AEUI art leave it visible"
            ),
            "provider_geometry_writes": False,
            "texture_geometry_writes_after_creation": False,
            "provider_behavior_replaced": False,
        },
        "addon_entrypoints": {
            "bootstrap": {"file": BOOTSTRAP_REL.as_posix()},
            "toc": {"file": TOC_REL.as_posix()},
            "required_dependency": "pfUI",
        },
        "provider_layers_preserved": [
            "bar position and movable scale",
            "bar show, hide and autohide",
            "button and hit region geometry",
            "icons, keybinds, counts and macro names",
            "cooldown, range, OOM, equipped, active and pressed feedback",
            "paging, stance and pet behavior",
            "drag behavior and SavedVariables",
        ],
        "display_evidence": {
            "contract": repo_path(root, display_contract_path),
            "contract_sha256": sha256(display_contract_path),
            "report": repo_path(root, display_report_path),
            "report_sha256": sha256(display_report_path),
            "runtime_atlas": repo_path(root, runtime_png),
            "runtime_atlas_sha256": sha256(runtime_png),
            "supported_layouts": repo_path(root, layouts_path),
            "supported_layouts_sha256": sha256(layouts_path),
            "real_layout": repo_path(root, scene_path),
            "real_layout_sha256": sha256(scene_path),
            "scenario_ids": [record["id"] for record in layout_records],
            "scenario_frames": {
                record["id"]: record["rail_frame_px"]
                for record in layout_records
            },
            "scene_bars": scene_records,
            "result": "8/8 pass",
            "violations": 0,
            "surrounding_pixels": (
                "confirmed V3 direction simulation only; not runtime art or "
                "visual authority"
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
        scene_path,
        layouts_path,
        package_validation,
    )

    export_report = {
        "schema": "aeui-action-rail-runtime-export-report-v1",
        "status": "pass",
        "phase": "P6" if game_validated else "P5",
        "source": runtime_manifest["source"],
        "runtime": runtime_record,
        "display_region": {
            "contract": repo_path(root, display_contract_path),
            "report": repo_path(root, display_report_path),
            "scenarios": 8,
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
