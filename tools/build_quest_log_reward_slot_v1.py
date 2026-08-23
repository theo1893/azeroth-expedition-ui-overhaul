#!/usr/bin/env python3
"""Export the accepted QL-D reward-slot source and exact runtime previews."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import struct
import subprocess
import sys
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (
    ROOT
    / "assets"
    / "source"
    / "quests"
    / "ql-d"
    / "QuestLogRewardSlot_Master_v1.png"
)
SOURCE_MANIFEST = SOURCE.with_name("QL-D_SourceManifest_v1.json")
RUNTIME = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestLogRewardSlotStatesV1.tga"
)
RUNTIME_MANIFEST = SOURCE.with_name("QL-D_RuntimeManifest_v1.json")
PRODUCTION_CONTRACT = (
    ROOT / "tools" / "specs" / "quest_log_reward_slot_production_v3.json"
)
DISPLAY_CONTRACT = (
    ROOT
    / "tools"
    / "specs"
    / "quest_log_reward_slot_runtime_display_region_v1.json"
)
VALIDATOR = (
    ROOT
    / ".codex"
    / "skills"
    / "run-aeui-asset-workflow"
    / "scripts"
    / "validate_display_regions.py"
)
REVIEWER = ROOT / "tools" / "review_quest_log_reward_slot_candidate_v2.py"
PREVIEW_DIR = (
    ROOT
    / "generated"
    / "quests"
    / "ql-d-reward-slots"
    / "runtime"
    / "V1"
)
ATLAS_PREVIEW = PREVIEW_DIR / "QuestLogRewardSlotStatesV1.png"
DISPLAY_REPORT = PREVIEW_DIR / "display-region-report.json"
BOARD_BASENAME = "ql-d-v3-attempt-04-accepted"
BOARD_PREVIEW = PREVIEW_DIR / f"{BOARD_BASENAME}.real-layout-board.png"
HISTORICAL_ATLAS = (
    ROOT
    / "generated"
    / "quests"
    / "ql-d-reward-slots"
    / "production"
    / "V3"
    / "attempt-04"
    / "review"
    / "ql-d-v3-attempt-04.temporary-state-atlas.png"
)

EXPECTED_SOURCE_SHA256 = (
    "816aeedd3ea8a890b5d6d39da2ce10771509afadfcfa92025024b736384347c5"
)
EXPECTED_SOURCE_SIZE = (1080, 410)
EXPECTED_SOURCE_BBOX = (20, 16, 1060, 392)
EXPECTED_HISTORICAL_ATLAS_SHA256 = (
    "55ba76e9630b9d582bbd95f6d9486a816cd3939213b8d8d26a8d5b15e1a22b68"
)
EXPECTED_HISTORICAL_ATLAS_PIXEL_SHA256 = (
    "3b538eb8d28b9b4bfa11e7497013f1ed8d8a141d15c52d1b7447fee51df50a90"
)
LOGICAL_SIZE = (108, 41)
RUNTIME_SIZE = (216, 82)
ATLAS_SIZE = (1024, 128)
CELL_SIZE = (256, 128)
CONTENT_BOX = (20, 22, 236, 104)
TEXELS_PER_UI = 2
STATE_ORDER = ("normal", "hover", "pressed", "disabled")
RESAMPLE = Image.Resampling.LANCZOS


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def display_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def load_module(path: Path, name: str) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ImportError(path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def alpha_evidence(image: Image.Image) -> dict[str, int]:
    histogram = image.getchannel("A").histogram()
    return {
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
    }


def visible_green_pixels(image: Image.Image) -> int:
    count = 0
    for red, green, blue, alpha in image.convert("RGBA").getdata():
        if alpha and red <= 32 and green >= 224 and blue <= 32:
            count += 1
    return count


def transparent_rgb_nonzero(image: Image.Image) -> int:
    count = 0
    for red, green, blue, alpha in image.convert("RGBA").getdata():
        if not alpha and (red or green or blue):
            count += 1
    return count


def validate_source(path: Path, image: Image.Image) -> None:
    if sha256(path) != EXPECTED_SOURCE_SHA256:
        raise ValueError("QL-D accepted source SHA-256 changed")
    if image.size != EXPECTED_SOURCE_SIZE or image.mode != "RGBA":
        raise ValueError(
            f"QL-D source must be {EXPECTED_SOURCE_SIZE} RGBA, "
            f"got {image.size} {image.mode}"
        )
    if image.getchannel("A").getbbox() != EXPECTED_SOURCE_BBOX:
        raise ValueError("QL-D accepted source visible bbox changed")
    if visible_green_pixels(image) or transparent_rgb_nonzero(image):
        raise ValueError("QL-D accepted source Alpha hygiene changed")


def save_tga(image: Image.Image, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, format="TGA")


def tga_header(path: Path) -> dict[str, Any]:
    data = path.read_bytes()
    if len(data) < 18:
        raise ValueError("runtime TGA is shorter than its header")
    width, height = struct.unpack("<HH", data[12:16])
    return {
        "image_type": data[2],
        "width": width,
        "height": height,
        "bits_per_pixel": data[16],
        "descriptor": data[17],
        "top_origin": bool(data[17] & 0x20),
    }


def runtime_states_from_atlas(atlas: Image.Image) -> dict[str, Image.Image]:
    states: dict[str, Image.Image] = {}
    x0, y0, x1, y1 = CONTENT_BOX
    for index, state in enumerate(STATE_ORDER):
        dx = index * CELL_SIZE[0]
        states[state] = atlas.crop((dx + x0, y0, dx + x1, y1))
    return states


def state_records(states: dict[str, Image.Image]) -> dict[str, Any]:
    records: dict[str, Any] = {}
    x0, y0, x1, y1 = CONTENT_BOX
    for index, state in enumerate(STATE_ORDER):
        dx = index * CELL_SIZE[0]
        records[state] = {
            "runtime_cell_xyxy": [dx, 0, dx + CELL_SIZE[0], CELL_SIZE[1]],
            "runtime_content_xyxy": [dx + x0, y0, dx + x1, y1],
            "runtime_display_size": list(states[state].size),
            "pixel_sha256": pixel_sha256(states[state]),
            "texcoord": {
                "left": (dx + x0) / ATLAS_SIZE[0],
                "right": (dx + x1) / ATLAS_SIZE[0],
                "top": y0 / ATLAS_SIZE[1],
                "bottom": y1 / ATLAS_SIZE[1],
            },
        }
    return records


def run_display_validator(contract: Path, report: Path) -> dict[str, Any]:
    report.parent.mkdir(parents=True, exist_ok=True)
    result = subprocess.run(
        [
            sys.executable,
            str(VALIDATOR),
            str(contract),
            "--report",
            str(report),
        ],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise ValueError(
            "QL-D runtime display-region validation failed: "
            + result.stderr.strip()
            + result.stdout.strip()
        )
    value = json.loads(report.read_text(encoding="utf-8"))
    if value.get("status") != "pass":
        raise ValueError("QL-D runtime display-region report did not pass")
    return value


def update_source_manifest(
    source_manifest: Path,
    runtime_manifest: Path,
    runtime: Path,
) -> None:
    value = json.loads(source_manifest.read_text(encoding="utf-8"))
    value["export_contract"]["status"] = "runtime-exported"
    value["export_contract"]["operation"] = (
        "resize the entire accepted 1080x410 canonical source directly to "
        "216x82 sampled pixels for an unchanged 108x41 UI slot, derive four "
        "RGB states with frozen formulas, place them in fixed 256x128 cells "
        "and write a 1024x128 RGBA TGA atlas"
    )
    value["export_contract"]["runtime_atlas_size"] = list(ATLAS_SIZE)
    value["export_contract"]["runtime_cell_size"] = list(CELL_SIZE)
    value["export_contract"]["runtime_content_xyxy_in_cell"] = list(
        CONTENT_BOX
    )
    value["export_contract"]["texels_per_ui"] = TEXELS_PER_UI
    value["runtime_exports"] = [
        {
            "contract": "QL-D V3.r3 attempt-04 user-selected / 1.1 / 2x",
            "manifest": runtime_manifest.name,
            "file": display_path(runtime),
            "sha256": sha256(runtime),
            "atlas_size": list(ATLAS_SIZE),
            "cell_size": list(CELL_SIZE),
            "content_size": list(RUNTIME_SIZE),
            "logical_content_size": list(LOGICAL_SIZE),
            "texels_per_ui": TEXELS_PER_UI,
        }
    ]
    source_manifest.write_text(
        json.dumps(value, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--source-manifest", type=Path, default=SOURCE_MANIFEST)
    parser.add_argument("--runtime", type=Path, default=RUNTIME)
    parser.add_argument("--manifest", type=Path, default=RUNTIME_MANIFEST)
    parser.add_argument("--preview-dir", type=Path, default=PREVIEW_DIR)
    parser.add_argument("--display-contract", type=Path, default=DISPLAY_CONTRACT)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    reviewer = load_module(REVIEWER, "aeui_ql_d_reviewer")
    contract = json.loads(PRODUCTION_CONTRACT.read_text(encoding="utf-8"))
    with Image.open(args.source) as opened:
        source = opened.convert("RGBA")
    validate_source(args.source, source)

    normal = reviewer.clear_transparent_rgb(
        source.resize(RUNTIME_SIZE, RESAMPLE)
    )
    derived_states = reviewer.derive_states(normal)
    runtime_atlas_contract = json.loads(json.dumps(contract))
    runtime_atlas_contract["atlas"]["size"] = list(ATLAS_SIZE)
    runtime_atlas_contract["atlas"]["cell_size"] = list(CELL_SIZE)
    runtime_atlas_contract["atlas"]["content_xyxy_in_cell"] = list(
        CONTENT_BOX
    )
    atlas = reviewer.build_atlas(derived_states, runtime_atlas_contract)
    if atlas.size != ATLAS_SIZE:
        raise ValueError(f"unexpected QL-D atlas size: {atlas.size}")
    if visible_green_pixels(atlas) or transparent_rgb_nonzero(atlas):
        raise ValueError("QL-D runtime atlas Alpha hygiene failed")
    review_normal = reviewer.clear_transparent_rgb(
        source.resize(LOGICAL_SIZE, RESAMPLE)
    )
    review_states = reviewer.derive_states(review_normal)
    review_atlas = reviewer.build_atlas(review_states, contract)
    if pixel_sha256(review_atlas) != EXPECTED_HISTORICAL_ATLAS_PIXEL_SHA256:
        raise ValueError(
            "QL-D density-equivalent logical review no longer matches the "
            "user-reviewed attempt 4"
        )

    save_tga(atlas, args.runtime)
    args.preview_dir.mkdir(parents=True, exist_ok=True)
    atlas_preview = args.preview_dir / ATLAS_PREVIEW.name
    atlas.save(atlas_preview, "PNG", optimize=False, compress_level=9)

    with Image.open(args.runtime) as opened:
        runtime_roundtrip = opened.convert("RGBA")
    if ImageChops.difference(runtime_roundtrip, atlas).getbbox() is not None:
        raise ValueError("QL-D TGA roundtrip changed atlas pixels")

    states = runtime_states_from_atlas(runtime_roundtrip)
    board, layout = reviewer.render_layout_board(
        ROOT,
        contract,
        review_states,
        args.preview_dir,
        BOARD_BASENAME,
    )
    if board != args.preview_dir / BOARD_PREVIEW.name:
        raise ValueError("QL-D real-layout board path changed")
    display_report = args.preview_dir / DISPLAY_REPORT.name
    display_value = run_display_validator(args.display_contract, display_report)

    if HISTORICAL_ATLAS.is_file():
        with Image.open(HISTORICAL_ATLAS) as opened:
            historical = opened.convert("RGBA")
        if sha256(HISTORICAL_ATLAS) != EXPECTED_HISTORICAL_ATLAS_SHA256:
            raise ValueError("ignored QL-D attempt-04 atlas bytes changed")
        if (
            historical.size != review_atlas.size
            or ImageChops.difference(historical, review_atlas).getbbox() is not None
        ):
            raise ValueError(
                "exported QL-D atlas does not match the user-reviewed attempt 4"
            )

    header = tga_header(args.runtime)
    if (
        header["image_type"] != 2
        or (header["width"], header["height"]) != ATLAS_SIZE
        or header["bits_per_pixel"] != 32
    ):
        raise ValueError(f"unexpected QL-D runtime TGA header: {header}")

    source_bbox = source.getchannel("A").getbbox()
    records = state_records(states)
    manifest = {
        "schema_version": 1,
        "module": "quests",
        "batch": "QL-D V3",
        "version": "V3.r3 / attempt 4 / user-selected",
        "runtime_contract": "1.1",
        "status": "runtime-exported",
        "source": {
            "file": display_path(args.source),
            "sha256": sha256(args.source),
            "width": source.width,
            "height": source.height,
            "mode": source.mode,
            "visible_bbox_exclusive": list(source_bbox or ()),
            "visible_aspect": (
                (source_bbox[2] - source_bbox[0])
                / (source_bbox[3] - source_bbox[1])
                if source_bbox
                else None
            ),
            "visible_green_spill_pixels": visible_green_pixels(source),
            "transparent_rgb_nonzero_values": transparent_rgb_nonzero(source),
            **alpha_evidence(source),
        },
        "accepted_contract_exception": {
            "original_allowed_keyed_aspect": [2.58, 2.69],
            "attempt_04_keyed_aspect": 2.7694524495677233,
            "historical_generation_result": "18/19; aspect failed",
            "runtime_operation": (
                "uniformly resize the complete accepted canonical canvas; "
                "do not stretch or crop visible pixels"
            ),
            "historical_gate_rewritten_as_pass": False,
        },
        "transform": {
            "operation": (
                "uniform full-canvas 1080x410 to 216x82 LANCZOS resize, "
                "frozen RGB state derivation and fixed 2x atlas packing"
            ),
            "resample": "Pillow Image.Resampling.LANCZOS",
            "logical_size": list(LOGICAL_SIZE),
            "source_canvas_resize": list(RUNTIME_SIZE),
            "texels_per_ui": TEXELS_PER_UI,
            "non_uniform_stretch": False,
            "visible_pixel_crop": False,
            "rotation": None,
            "mirror": False,
            "state_order": list(STATE_ORDER),
            "alpha_identical_across_states": all(
                states[state].getchannel("A").tobytes()
                == states["normal"].getchannel("A").tobytes()
                for state in STATE_ORDER
            ),
            "hover_rgb": {
                "r": "min(255, rint(1.04R + 4))",
                "g": "min(255, rint(1.03G + 3))",
                "b": "min(255, rint(1.01B + 1))",
            },
            "pressed_rgb": {
                "r": "rint(0.82R)",
                "g": "rint(0.80G)",
                "b": "rint(0.78B)",
            },
            "disabled_rgb": {
                "l": "rint(0.299R + 0.587G + 0.114B)",
                "channel": "rint(0.30C + 0.50L)",
            },
            "atlas_size": list(ATLAS_SIZE),
            "cell_size": list(CELL_SIZE),
            "content_xyxy_in_cell": list(CONTENT_BOX),
            "states": records,
        },
        "runtime": {
            "file": display_path(args.runtime),
            "sha256": sha256(args.runtime),
            "pixel_sha256": pixel_sha256(runtime_roundtrip),
            "width": runtime_roundtrip.width,
            "height": runtime_roundtrip.height,
            "mode": runtime_roundtrip.mode,
            "tga_header": header,
            "visible_bbox_exclusive": list(
                runtime_roundtrip.getchannel("A").getbbox() or ()
            ),
            "visible_green_spill_pixels": visible_green_pixels(
                runtime_roundtrip
            ),
            "transparent_rgb_nonzero_values": transparent_rgb_nonzero(
                runtime_roundtrip
            ),
            **alpha_evidence(runtime_roundtrip),
        },
        "historical_preview_equivalence": {
            "attempt_04_temporary_atlas": display_path(HISTORICAL_ATLAS),
            "attempt_04_temporary_atlas_sha256": (
                EXPECTED_HISTORICAL_ATLAS_SHA256
            ),
            "expected_pixel_sha256": EXPECTED_HISTORICAL_ATLAS_PIXEL_SHA256,
            "logical_review_pixel_sha256": pixel_sha256(review_atlas),
            "logical_review_pixel_identical": True,
            "runtime_is_direct_2x_source_export": True,
            "fresh_checkout_dependency": False,
        },
        "simulation": {
            "atlas_preview": {
                "file": display_path(atlas_preview),
                "sha256": sha256(atlas_preview),
                "size": list(atlas.size),
            },
            "real_layout_board": {
                "file": display_path(board),
                "sha256": sha256(board),
                "size": list(Image.open(board).size),
                "scenarios": [0, 1, 2, 4, 6],
                "checks_passed": all(layout["checks"].values()),
                "rendered_from_density_equivalent_logical_review": True,
                "runtime_scale_percent": 100,
            },
            "display_region": {
                "contract": display_path(args.display_contract),
                "report": display_path(display_report),
                "report_sha256": sha256(display_report),
                "status": display_value["status"],
                "scenario_count": display_value["summary"]["scenario_count"],
                "violation_count": display_value["summary"]["violation_count"],
                "first_failure": display_value["summary"]["first_failure"],
            },
        },
        "layout_contract": {
            "runtime_objects": "QuestLogItem1..MAX_NUM_ITEMS",
            "button_size": [108, 41],
            "icon_safe_xyxy": [4, 4, 37, 37],
            "name_safe_xyxy": [41, 4, 105, 37],
            "name_safe_width": 64,
            "column_gap": 8,
            "row_gap": 4,
            "scenario_reward_counts": [0, 1, 2, 4, 6],
        },
        "ownership": {
            "visual_container": (
                "adapter-owned mouse-inert child Frame and BACKGROUND Texture"
            ),
            "live_content": (
                "provider QuestLogItem icon, count and name are reparented above "
                "the visual container without changing their values"
            ),
            "button": (
                "QuestLogItem Button retains hitbox, tooltip, click scripts and "
                "provider behavior"
            ),
            "pressed_offset": (
                "move the visual container and its live children one UI pixel "
                "down-right; do not move the QuestLogItem hitbox"
            ),
        },
        "implementation": {
            "exporter": display_path(Path(__file__)),
            "adapter": "addon/AzerothExpeditionUI/Modules/Quests.lua",
            "theme": "addon/AzerothExpeditionUI/Modules/QuestVisualTheme.lua",
            "source_manifest": display_path(args.source_manifest),
            "imagegen_calls_after_acceptance": 0,
            "game_validated": False,
        },
    }
    args.manifest.parent.mkdir(parents=True, exist_ok=True)
    args.manifest.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    update_source_manifest(args.source_manifest, args.manifest, args.runtime)
    print(json.dumps(manifest, ensure_ascii=False))


if __name__ == "__main__":
    main()
