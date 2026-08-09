#!/usr/bin/env python3
"""Deterministically export the accepted AB.FIELDKIT.V1 source atlases.

The two accepted 1024-square sources remain archival four-cell masters.  This
exporter crops each complete visible cell object, performs one proportional
premultiplied-alpha reduction per object, packs the results into separate 512-square
straight-alpha runtime atlases, and writes tracked 32-bit TGAs.  Cell C is
sampled as a nine-slice.  Cell D is sampled as a three-slice in both its
accepted horizontal orientation and a deterministic 90-degree rotation.
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

from PIL import Image

import render_action_fieldkit_simulation as simulation
import review_action_fieldkit_candidate_v1 as reviewer


ADAPTER_REL = Path("addon/AzerothExpeditionUI/Modules/ActionBars.lua")
BOOTSTRAP_REL = Path("addon/AzerothExpeditionUI/Core/Bootstrap.lua")
TOC_REL = Path("addon/AzerothExpeditionUI/AzerothExpeditionUI.toc")
SPEC_REL = Path("tools/specs/action_fieldkit_v2_simulation.json")
DISPLAY_TEMPLATE_REL = Path(
    "tools/specs/action_fieldkit_v2_sim_display_region.json"
)
DISPLAY_VALIDATOR_REL = Path(
    ".codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py"
)
PREVIEW_REL = Path(
    "generated/actionbars/AB.FIELDKIT/AB.FIELDKIT.V1/runtime/V1"
)
ATLAS_SIZE = (512, 512)
RUNTIME_CONTRACT = "1.0"
DESTINATION_CAP_UI = 6
CONNECTOR_SOURCE_CAP = 30

CELL_ORIGINS = {
    "A": (0, 0),
    "B": (512, 0),
    "C": (0, 512),
    "D": (512, 512),
}

PACK_AREAS = {
    "A": (8, 8, 120, 120),
    "B": (136, 8, 248, 120),
    "C": (8, 136, 264, 392),
    "D_HORIZONTAL": (264, 8, 504, 120),
    "D_VERTICAL": (392, 136, 504, 392),
}

CASES: dict[str, dict[str, Any]] = {
    "trinket": {
        "component": "AB.TRINKET.KIT.V1",
        "source": Path(
            "assets/source/actionbars/ab-trinket-kit/"
            "ActionTrinketKit_Master_v1.png"
        ),
        "source_manifest": Path(
            "assets/source/actionbars/ab-trinket-kit/"
            "AB-TRINKET-KIT-V1_SourceManifest_v1.json"
        ),
        "runtime_manifest": Path(
            "assets/source/actionbars/ab-trinket-kit/"
            "AB-TRINKET-KIT-V1_RuntimeManifest_v1.json"
        ),
        "runtime": Path(
            "addon/AzerothExpeditionUI/Media/ActionBars/"
            "ActionTrinketKitV1.tga"
        ),
        "display_contract": Path(
            "tools/specs/action_trinket_kit_v1_runtime_display_region.json"
        ),
        "expected_source_sha256": (
            "82dd2260757616912a7ef78658cc230f66d89614613d64e85f8116cac284c012"
        ),
        "expected_runtime_pixel_sha256": (
            "0961d750d7436665a333d948ba010a212c5de6f87c51ab59a10ed8af86ac4aef"
        ),
        "cell_bboxes": {
            "A": (82, 80, 429, 432),
            "B": (80, 81, 432, 430),
            "C": (80, 82, 432, 429),
            "D": (80, 196, 432, 315),
        },
        "scenario_prefix": "trinket-",
        "runtime_key": "action_trinket_kit_v1",
    },
    "consumable": {
        "component": "AB.CONSUMABLE.KIT.V1",
        "source": Path(
            "assets/source/actionbars/ab-consumable-kit/"
            "ActionConsumableKit_Master_v1.png"
        ),
        "source_manifest": Path(
            "assets/source/actionbars/ab-consumable-kit/"
            "AB-CONSUMABLE-KIT-V1_SourceManifest_v1.json"
        ),
        "runtime_manifest": Path(
            "assets/source/actionbars/ab-consumable-kit/"
            "AB-CONSUMABLE-KIT-V1_RuntimeManifest_v1.json"
        ),
        "runtime": Path(
            "addon/AzerothExpeditionUI/Media/ActionBars/"
            "ActionConsumableKitV1.tga"
        ),
        "display_contract": Path(
            "tools/specs/action_consumable_kit_v1_runtime_display_region.json"
        ),
        "expected_source_sha256": (
            "623f29c5e16ea73c50778b462c2d79a4eb2dd4928b9a1d94f30876f13caa2419"
        ),
        "expected_runtime_pixel_sha256": (
            "658f826f5ffb52f77530d5e288f99ac9511db1317129aea7f64c4c8e7ea4e30d"
        ),
        "cell_bboxes": {
            "A": (80, 87, 432, 425),
            "B": (80, 83, 432, 429),
            "C": (80, 80, 432, 432),
            "D": (80, 226, 432, 286),
        },
        "scenario_prefix": "autobar-",
        "runtime_key": "action_consumable_kit_v1",
    },
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument(
        "--write-display-contracts",
        action="store_true",
        help="write the reviewed final-runtime display contracts",
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


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def repo_path(root: Path, path: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    data = bytearray(image.convert("RGBA").tobytes())
    for offset in range(0, len(data), 4):
        if data[offset + 3] == 0:
            data[offset : offset + 3] = b"\0\0\0"
    return Image.frombytes("RGBA", image.size, bytes(data))


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


def validate_source(path: Path, case: dict[str, Any]) -> Image.Image:
    if sha256(path) != case["expected_source_sha256"]:
        raise ValueError(f"accepted {case['component']} source SHA-256 changed")
    with Image.open(path) as opened:
        if opened.size != (1024, 1024) or opened.mode != "RGBA":
            raise ValueError(
                f"accepted {case['component']} source must remain 1024x1024 RGBA"
            )
        source = opened.copy()
    if visible_green_spill_pixels(source):
        raise ValueError(f"accepted {case['component']} source contains green spill")
    if transparent_rgb_nonzero_values(source):
        raise ValueError(
            f"accepted {case['component']} source has non-zero transparent RGB"
        )
    for name, expected in case["cell_bboxes"].items():
        origin = CELL_ORIGINS[name]
        cell = source.crop((origin[0], origin[1], origin[0] + 512, origin[1] + 512))
        if cell.getchannel("A").getbbox() != expected:
            raise ValueError(f"accepted {case['component']} cell {name} bbox changed")
    return source


def fit_visible(
    sprite: Image.Image,
    maximum: tuple[int, int],
    resample: Image.Resampling = Image.Resampling.LANCZOS,
) -> Image.Image:
    bbox = sprite.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("runtime source cell is empty")
    visible = sprite.crop(bbox)
    scale = min(maximum[0] / visible.width, maximum[1] / visible.height)
    size = (
        max(1, round(visible.width * scale)),
        max(1, round(visible.height * scale)),
    )
    # Pillow's straight-RGBA LANCZOS path can overshoot low-alpha chroma-key
    # edge RGB even when the accepted source itself is clean.  Resize in
    # premultiplied-alpha space, then return to straight RGBA.  This is still
    # one proportional resample and does not alter any opaque source pixel.
    reduced = clear_transparent_rgb(
        visible.convert("RGBa")
        .resize(size, resample)
        .convert("RGBA")
    )
    reduced_bbox = reduced.getchannel("A").getbbox()
    if reduced_bbox is None:
        raise ValueError("runtime resize erased a visible source cell")
    return clear_transparent_rgb(reduced.crop(reduced_bbox))


def center_box(
    area: tuple[int, int, int, int], size: tuple[int, int]
) -> tuple[int, int, int, int]:
    area_width = area[2] - area[0]
    area_height = area[3] - area[1]
    if size[0] > area_width or size[1] > area_height:
        raise ValueError(f"sprite {size} does not fit runtime area {area}")
    left = area[0] + (area_width - size[0]) // 2
    top = area[1] + (area_height - size[1]) // 2
    return left, top, left + size[0], top + size[1]


def split_nine(
    box: tuple[int, int, int, int], cap: int
) -> dict[str, tuple[int, int, int, int]]:
    names = (
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
    x = (box[0], box[0] + cap, box[2] - cap, box[2])
    y = (box[1], box[1] + cap, box[3] - cap, box[3])
    result: dict[str, tuple[int, int, int, int]] = {}
    index = 0
    for row in range(3):
        for column in range(3):
            result[names[index]] = (
                x[column],
                y[row],
                x[column + 1],
                y[row + 1],
            )
            index += 1
    return result


def split_horizontal(
    box: tuple[int, int, int, int], cap: int
) -> dict[str, tuple[int, int, int, int]]:
    return {
        "start": (box[0], box[1], box[0] + cap, box[3]),
        "middle": (box[0] + cap, box[1], box[2] - cap, box[3]),
        "end": (box[2] - cap, box[1], box[2], box[3]),
    }


def split_vertical(
    box: tuple[int, int, int, int], cap: int
) -> dict[str, tuple[int, int, int, int]]:
    return {
        "start": (box[0], box[1], box[2], box[1] + cap),
        "middle": (box[0], box[1] + cap, box[2], box[3] - cap),
        "end": (box[0], box[3] - cap, box[2], box[3]),
    }


def texcoord(box: tuple[int, int, int, int]) -> list[float]:
    return [
        box[0] / ATLAS_SIZE[0],
        box[2] / ATLAS_SIZE[0],
        box[1] / ATLAS_SIZE[1],
        box[3] / ATLAS_SIZE[1],
    ]


def build_runtime(
    source: Image.Image, case: dict[str, Any]
) -> tuple[Image.Image, dict[str, Any], dict[str, Image.Image]]:
    cells: dict[str, Image.Image] = {}
    for name in ("A", "B", "C", "D"):
        origin = CELL_ORIGINS[name]
        cells[name] = source.crop(
            (origin[0], origin[1], origin[0] + 512, origin[1] + 512)
        )

    sprites = {
        "A": fit_visible(cells["A"], (112, 112)),
        "B": fit_visible(cells["B"], (112, 112)),
        "C": fit_visible(cells["C"], (256, 256)),
        # The accepted consumable D edge contains sub-byte chroma-key residue
        # that LANCZOS overshoots into a visible alpha=1 green pixel.  HAMMING
        # is used for both D components so the rotatable strip stays clean
        # without deleting or recolouring any resulting visible pixel.
        "D": fit_visible(
            cells["D"], (240, 104), Image.Resampling.HAMMING
        ),
    }
    sprites["D_VERTICAL"] = clear_transparent_rgb(
        sprites["D"].transpose(Image.Transpose.ROTATE_90)
    )

    boxes = {
        "A": center_box(PACK_AREAS["A"], sprites["A"].size),
        "B": center_box(PACK_AREAS["B"], sprites["B"].size),
        "C": center_box(PACK_AREAS["C"], sprites["C"].size),
        "D_HORIZONTAL": center_box(
            PACK_AREAS["D_HORIZONTAL"], sprites["D"].size
        ),
        "D_VERTICAL": center_box(
            PACK_AREAS["D_VERTICAL"], sprites["D_VERTICAL"].size
        ),
    }
    atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
    atlas.alpha_composite(sprites["A"], boxes["A"][:2])
    atlas.alpha_composite(sprites["B"], boxes["B"][:2])
    atlas.alpha_composite(sprites["C"], boxes["C"][:2])
    atlas.alpha_composite(sprites["D"], boxes["D_HORIZONTAL"][:2])
    atlas.alpha_composite(
        sprites["D_VERTICAL"], boxes["D_VERTICAL"][:2]
    )
    atlas = clear_transparent_rgb(atlas)

    c_cap = round(min(sprites["C"].size) * 0.18)
    c_cap = max(
        1,
        min(
            c_cap,
            (sprites["C"].width - 1) // 2,
            (sprites["C"].height - 1) // 2,
        ),
    )
    d_cap = min(
        CONNECTOR_SOURCE_CAP,
        (sprites["D"].width - 1) // 2,
        (sprites["D_VERTICAL"].height - 1) // 2,
    )
    nine = split_nine(boxes["C"], c_cap)
    horizontal = split_horizontal(boxes["D_HORIZONTAL"], d_cap)
    vertical = split_vertical(boxes["D_VERTICAL"], d_cap)
    sampled: list[dict[str, Any]] = [
        {"id": "A", "box": list(boxes["A"])},
        {"id": "B", "box": list(boxes["B"])},
    ]
    sampled.extend(
        {"id": f"C.{name}", "box": list(box)}
        for name, box in nine.items()
    )
    sampled.extend(
        {"id": f"D.horizontal.{name}", "box": list(box)}
        for name, box in horizontal.items()
    )
    sampled.extend(
        {"id": f"D.vertical.{name}", "box": list(box)}
        for name, box in vertical.items()
    )

    layout = {
        "atlas_size": list(ATLAS_SIZE),
        "visible_bbox_exclusive": list(
            atlas.getchannel("A").getbbox() or (0, 0, 0, 0)
        ),
        "objects": {name: list(box) for name, box in boxes.items()},
        "c_nine_slice_cap_pixels": c_cap,
        "c_nine_slice_boxes": {
            name: list(box) for name, box in nine.items()
        },
        "d_three_slice_cap_pixels": d_cap,
        "d_horizontal_boxes": {
            name: list(box) for name, box in horizontal.items()
        },
        "d_vertical_boxes": {
            name: list(box) for name, box in vertical.items()
        },
        "sampled_regions": sampled,
        "texcoords": {
            "A": texcoord(boxes["A"]),
            "B": texcoord(boxes["B"]),
            "C": {name: texcoord(box) for name, box in nine.items()},
            "D_HORIZONTAL": {
                name: texcoord(box) for name, box in horizontal.items()
            },
            "D_VERTICAL": {
                name: texcoord(box) for name, box in vertical.items()
            },
        },
    }
    expected = case["expected_runtime_pixel_sha256"]
    if expected and pixel_sha256(atlas) != expected:
        raise ValueError(
            f"{case['component']} runtime atlas differs from the frozen export"
        )
    if visible_green_spill_pixels(atlas):
        raise ValueError(f"{case['component']} runtime atlas contains green spill")
    if transparent_rgb_nonzero_values(atlas):
        raise ValueError(
            f"{case['component']} runtime atlas has non-zero transparent RGB"
        )
    return atlas, layout, sprites


def write_runtime_tga(
    runtime: Image.Image, path: Path, runtime_rel: Path
) -> dict[str, Any]:
    path.parent.mkdir(parents=True, exist_ok=True)
    runtime.save(path, format="TGA")
    header = path.read_bytes()[:18]
    if len(header) != 18 or header[16] != 32:
        raise ValueError("Field Kit runtime TGA is not 32-bit RGBA")
    with Image.open(path) as opened:
        roundtrip = opened.convert("RGBA")
    if roundtrip.size != ATLAS_SIZE or roundtrip.tobytes() != runtime.tobytes():
        raise ValueError("Field Kit runtime TGA roundtrip changed pixels")
    return {
        "file": runtime_rel.as_posix(),
        "sha256": sha256(path),
        "width": ATLAS_SIZE[0],
        "height": ATLAS_SIZE[1],
        "mode": "RGBA",
        "bits_per_pixel": int(header[16]),
        "descriptor": int(header[17]),
        "top_origin": bool(header[17] & 0x20),
        "pixel_sha256": pixel_sha256(roundtrip),
        "visible_bbox_exclusive": list(
            roundtrip.getchannel("A").getbbox() or (0, 0, 0, 0)
        ),
        "visible_green_spill_pixels": visible_green_spill_pixels(roundtrip),
        "transparent_rgb_nonzero_values": transparent_rgb_nonzero_values(
            roundtrip
        ),
        **alpha_evidence(roundtrip),
    }


def render_previews(
    root: Path,
    spec: dict[str, Any],
    sprites_by_case: dict[str, dict[str, Image.Image]],
    preview_dir: Path,
) -> dict[str, Path]:
    originals = {
        "draw_trinket_main": simulation.draw_trinket_main,
        "draw_trinket_menu": simulation.draw_trinket_menu,
        "draw_rack": simulation.draw_rack,
        "draw_grouped_rack": simulation.draw_grouped_rack,
        "draw_popup": simulation.draw_popup,
    }
    trinket_main, trinket_menu = reviewer.trinket_drawers(
        sprites_by_case["trinket"]
    )
    rack, grouped, popup = reviewer.consumable_drawers(
        sprites_by_case["consumable"]
    )
    review_spec = copy.deepcopy(spec)
    review_spec["scene_annotations"] = {
        "title": "动作栏 / 随身栏 · Field Kit 最终运行时",
        "subtitle": "两张 512² TGA + 真实 provider 动态层；中央技能冷却视线保持净空",
        "note": "最终 runtime atlas / UV · 100% 目标设备物理像素 · ImageGen 新增 0",
        "rules_title": "P5 runtime 复查",
        "rules": [
            "TrinketMenu 双槽、30 候选、Queue、点击与换装逻辑不变",
            "AutoBar 24 主槽、12 popup、类别、数量与冷却仍由 provider 所有",
            "只有精确 4×6 profile 签名显示应急／增益／工具三组",
            "provider 缺失、禁用或自定义布局时局部回退，不显示占位栏",
            "不自动启用 AutoBar，不应用 profile，不改 TrinketMenu SavedVariables",
        ],
    }
    scene_path = preview_dir / "AB.FIELDKIT.V1.runtime-v1.real-layout-1920x1080.png"
    trinket_board = preview_dir / "AB.TRINKET.KIT.V1.runtime-v1.layouts.png"
    consumable_board = preview_dir / "AB.CONSUMABLE.KIT.V1.runtime-v1.layouts.png"
    try:
        simulation.draw_trinket_main = trinket_main
        simulation.draw_trinket_menu = trinket_menu
        simulation.draw_rack = rack
        simulation.draw_grouped_rack = grouped
        simulation.draw_popup = popup
        simulation.draw_scene(root, review_spec, scene_path)
        reviewer.render_supported_board(
            root, review_spec, "trinket", trinket_board
        )
        reviewer.render_supported_board(
            root, review_spec, "consumable", consumable_board
        )
    finally:
        simulation.draw_trinket_main = originals["draw_trinket_main"]
        simulation.draw_trinket_menu = originals["draw_trinket_menu"]
        simulation.draw_rack = originals["draw_rack"]
        simulation.draw_grouped_rack = originals["draw_grouped_rack"]
        simulation.draw_popup = originals["draw_popup"]
    return {
        "scene": scene_path,
        "trinket_board": trinket_board,
        "consumable_board": consumable_board,
    }


def build_display_contract(
    template: dict[str, Any],
    case: dict[str, Any],
    layout: dict[str, Any],
    previews: dict[str, Path],
    root: Path,
) -> dict[str, Any]:
    contract = copy.deepcopy(template)
    contract["component"] = f"{case['component']}/runtime-v1"
    board_key = (
        "trinket_board"
        if case["component"] == "AB.TRINKET.KIT.V1"
        else "consumable_board"
    )
    contract["evidence"].update(
        {
            "adapter": ADAPTER_REL.as_posix(),
            "scene_simulation": repo_path(root, previews["scene"]),
            "state_simulation": repo_path(root, previews[board_key]),
            "atlas_role": (
                "final 512x512 straight-alpha power-of-two TGA; each declared "
                "A/B object, C nine-slice cell and horizontal/vertical D "
                "three-slice cell is sampled by the adapter"
            ),
            "runtime_sampling": (
                "one proportional premultiplied-alpha reduction per complete "
                "accepted cell object; one deterministic 90-degree D rotation; "
                "transparent packing gutters are never sampled"
            ),
            "runtime_scope": (
                "TrinketMenu 3.3 existing main/menu frames and buttons"
                if case["component"] == "AB.TRINKET.KIT.V1"
                else "AutoBar 1.31 existing main/popup frames and buttons"
            ),
            "final_runtime": True,
        }
    )
    contract["atlas"] = {
        "size": list(ATLAS_SIZE),
        "visible_bbox": layout["visible_bbox_exclusive"],
        "require_exact_visible_coverage": False,
        "sampled_regions": [
            {
                "id": f"{case['component']}.{item['id']}",
                "box": item["box"],
            }
            for item in layout["sampled_regions"]
        ],
    }
    contract["nine_slice"] = {
        "caps": {
            "left": DESTINATION_CAP_UI,
            "right": DESTINATION_CAP_UI,
            "top": DESTINATION_CAP_UI,
            "bottom": DESTINATION_CAP_UI,
        },
        "minimum_frame_size": [
            DESTINATION_CAP_UI * 2 + 1,
            DESTINATION_CAP_UI * 2 + 1,
        ],
    }
    contract["scenarios"] = [
        scenario
        for scenario in contract["scenarios"]
        if scenario["id"].startswith(case["scenario_prefix"])
    ]
    return contract


def package_validation_record(
    root: Path, package_report_path: Path
) -> dict[str, Any] | None:
    if not package_report_path.is_file():
        return None
    report = load_json(package_report_path)
    if (
        report.get("status") != "pass"
        or report.get("violations")
        or report.get("build_required_on_target_device") is not False
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
    case: dict[str, Any],
    runtime_record: dict[str, Any],
    layout: dict[str, Any],
    exporter_sha: str,
    display_contract_path: Path,
    display_report_path: Path,
    previews: dict[str, Path],
    package_validation: dict[str, Any] | None,
) -> None:
    path = root / case["source_manifest"]
    manifest = load_json(path)
    manifest["status"] = "runtime-exported"
    manifest["workflow_state"] = "runtime-exported"
    manifest["project_phase"] = "P5"
    manifest["export_contract"] = {
        "status": "exported",
        "authorization": "user instruction '下一步' on 2026-08-09",
        "exporter": "tools/build_action_fieldkit_v1_runtime.py",
        "exporter_sha256": exporter_sha,
        "runtime_file": runtime_record["file"],
        "runtime_sha256": runtime_record["sha256"],
        "runtime_atlas_size": list(ATLAS_SIZE),
        "runtime_visible_bbox_exclusive": layout["visible_bbox_exclusive"],
        "runtime_objects": layout["objects"],
        "runtime_uv": layout["texcoords"],
        "c_nine_slice_cap_pixels": layout["c_nine_slice_cap_pixels"],
        "c_destination_cap_ui": DESTINATION_CAP_UI,
        "d_three_slice_cap_pixels": layout["d_three_slice_cap_pixels"],
            "resample": (
                "Pillow premultiplied RGBa: LANCZOS for A/B/C and HAMMING "
                "for the thin D connector, converted back to straight RGBA"
            ),
        "rotation": "Cell D receives one deterministic 90-degree runtime copy",
        "operation": (
            "crop each complete accepted cell visible bbox, proportionally "
            "resize it once into the frozen 512x512 packing areas, create one "
            "90-degree D copy, clear only fully transparent RGB, and export a "
            "tracked 32-bit TGA"
        ),
        "imagegen_calls_after_acceptance": 0,
        "allowed": [
            "complete declared A/B/C/D visible objects without removing visible pixels",
            "one proportional deterministic reduction per accepted object",
            "one deterministic 90-degree copy of the explicitly rotatable D object",
            "transparent power-of-two packing gutters that are never sampled",
            "fully transparent RGB zeroing without changing visible RGB or Alpha",
            "C nine-slice and D three-slice assembly beneath provider-owned content",
        ],
        "forbidden_runtime_uses": [
            "load the accepted 1024x1024 source directly in Turtle WoW",
            "sample transparent packing gutters or omit a declared visible slice",
            "redraw, recolor, mirror or invent states from accepted cells",
            "distort A/B or C edge/corner slices; only quiet C/D centers may stretch",
            "bake item icons, counts, cooldowns, Queue, category labels or tooltips",
            "replace provider Buttons, hit regions, scripts, drag, scale, docking or SavedVariables",
            "enable AutoBar or apply any AutoBar or TrinketMenu profile",
        ],
    }
    manifest["runtime_exports"] = {case["runtime_key"]: runtime_record}
    board_key = (
        "trinket_board"
        if case["component"] == "AB.TRINKET.KIT.V1"
        else "consumable_board"
    )
    scenario_count = 9 if case["component"] == "AB.TRINKET.KIT.V1" else 7
    manifest["p5_validation"] = {
        "display_region_contract": repo_path(root, display_contract_path),
        "display_region_contract_sha256": sha256(display_contract_path),
        "display_region_report": repo_path(root, display_report_path),
        "display_region_report_sha256": sha256(display_report_path),
        "real_layout_preview": repo_path(root, previews["scene"]),
        "real_layout_preview_sha256": sha256(previews["scene"]),
        "supported_layouts_preview": repo_path(root, previews[board_key]),
        "supported_layouts_preview_sha256": sha256(previews[board_key]),
        "real_layout_scenarios": f"{scenario_count}/{scenario_count} pass",
        "display_region_violations": 0,
        "addon_package": package_validation,
        "game_validated": False,
    }
    write_json(path, manifest)


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    preview_dir = root / PREVIEW_REL
    preview_dir.mkdir(parents=True, exist_ok=True)
    spec = load_json(root / SPEC_REL)
    template = load_json(root / DISPLAY_TEMPLATE_REL)

    sources: dict[str, Image.Image] = {}
    runtimes: dict[str, Image.Image] = {}
    layouts: dict[str, dict[str, Any]] = {}
    sprites_by_case: dict[str, dict[str, Image.Image]] = {}
    runtime_records: dict[str, dict[str, Any]] = {}
    for key, case in CASES.items():
        sources[key] = validate_source(root / case["source"], case)
        runtime, layout, sprites = build_runtime(sources[key], case)
        runtimes[key] = runtime
        layouts[key] = layout
        sprites_by_case[key] = sprites
        runtime_records[key] = write_runtime_tga(
            runtime, root / case["runtime"], case["runtime"]
        )
        runtime.save(
            preview_dir / f"{case['component']}.runtime-v1.atlas.png",
            format="PNG",
            optimize=False,
            compress_level=9,
        )

    previews = render_previews(root, spec, sprites_by_case, preview_dir)
    package_report_path = preview_dir / "addon-package-report.json"
    package_validation = package_validation_record(root, package_report_path)
    exporter_path = Path(__file__).resolve()
    exporter_sha = sha256(exporter_path)
    adapter_path = root / ADAPTER_REL
    bootstrap_path = root / BOOTSTRAP_REL
    toc_path = root / TOC_REL
    for required in (adapter_path, bootstrap_path, toc_path):
        if not required.is_file():
            raise FileNotFoundError(f"required addon integration missing: {required}")

    reports: dict[str, Any] = {}
    for key, case in CASES.items():
        contract_path = root / case["display_contract"]
        contract = build_display_contract(
            template, case, layouts[key], previews, root
        )
        if args.write_display_contracts:
            write_json(contract_path, contract)
        elif not contract_path.is_file():
            raise FileNotFoundError(
                f"tracked display contract missing for {case['component']}"
            )
        elif load_json(contract_path) != contract:
            raise ValueError(
                f"{case['component']} display contract drifted; inspect before rewriting"
            )

        display_report_path = (
            preview_dir / f"{case['component']}.display-region-report.json"
        )
        subprocess.run(
            [
                sys.executable,
                str(root / DISPLAY_VALIDATOR_REL),
                str(contract_path),
                "--report",
                str(display_report_path),
            ],
            cwd=root,
            check=True,
        )
        display_report = load_json(display_report_path)
        expected_scenarios = 9 if key == "trinket" else 7
        if (
            display_report.get("status") != "pass"
            or display_report.get("summary", {}).get("violation_count") != 0
            or display_report.get("summary", {}).get("scenario_count")
            != expected_scenarios
        ):
            raise ValueError(
                f"{case['component']} display-region gate did not pass"
            )

        runtime_manifest = {
            "schema_version": 1,
            "module": "actionbars",
            "batch": "AB.FIELDKIT.V1",
            "component": case["component"],
            "version": "runtime-v1",
            "runtime_contract": RUNTIME_CONTRACT,
            "status": "runtime-exported",
            "phase": "P5",
            "source": {
                "file": case["source"].as_posix(),
                "sha256": sha256(root / case["source"]),
                "width": sources[key].width,
                "height": sources[key].height,
                "mode": sources[key].mode,
                "visible_bbox_exclusive": list(
                    sources[key].getchannel("A").getbbox()
                    or (0, 0, 0, 0)
                ),
                "visible_green_spill_pixels": visible_green_spill_pixels(
                    sources[key]
                ),
                "transparent_rgb_nonzero_values": transparent_rgb_nonzero_values(
                    sources[key]
                ),
                **alpha_evidence(sources[key]),
            },
            "transform": {
                "operation": (
                    "complete per-cell visible-bbox crop; one proportional "
                    "premultiplied-alpha LANCZOS reduction for A/B/C and "
                    "HAMMING reduction for thin D; one 90-degree D rotation; "
                    "deterministic packing into a transparent 512-square atlas"
                ),
                "source_cell_bboxes_local_exclusive": {
                    name: list(box)
                    for name, box in case["cell_bboxes"].items()
                },
                "runtime_layout": layouts[key],
                "destination_nine_slice_cap_ui": DESTINATION_CAP_UI,
                "mirror": False,
                "recolor": False,
                "retouch": False,
                "straight_alpha": True,
            },
            "runtime_export": runtime_records[key],
            "deterministic_export": {
                "exporter": repo_path(root, exporter_path),
                "exporter_sha256": exporter_sha,
                "expected_runtime_pixel_sha256": (
                    case["expected_runtime_pixel_sha256"]
                    or runtime_records[key]["pixel_sha256"]
                ),
                "imagegen_calls_after_acceptance": 0,
                "attempt_6_allowed": False,
            },
            "adapter": {
                "file": ADAPTER_REL.as_posix(),
                "sha256": sha256(adapter_path),
                "provider": (
                    "TrinketMenu 3.3 existing main/menu frames and 2+30 buttons"
                    if key == "trinket"
                    else "AutoBar 1.31 existing main/popup frames and 24+12 buttons"
                ),
                "visual_layers_only": True,
                "provider_geometry_writes": False,
                "provider_behavior_replaced": False,
                "saved_variables_written": False,
                "autobar_enabled_or_profile_applied": False,
                "fallback": (
                    "missing/hidden providers render no placeholder; AEUI off restores "
                    "the provider normal textures and native TrinketMenu backdrops"
                ),
            },
            "addon_entrypoints": {
                "bootstrap": {
                    "file": BOOTSTRAP_REL.as_posix(),
                    "sha256": sha256(bootstrap_path),
                },
                "toc": {
                    "file": TOC_REL.as_posix(),
                    "sha256": sha256(toc_path),
                },
                "addon_version": "0.8.0",
                "required_dependency": "pfUI",
                "optional_provider": "TrinketMenu" if key == "trinket" else "AutoBar",
            },
            "provider_layers_preserved": [
                "provider position, scale, orientation, docking and visibility",
                "all Button parents, points, sizes, hit regions and scripts",
                "icons, counts, cooldowns, checked/highlight and tooltip layers",
                "Queue and combat swapping for TrinketMenu",
                "categories, bag slots, popup ordering and item use for AutoBar",
                "provider configuration and SavedVariables",
            ],
            "display_evidence": {
                "contract": repo_path(root, contract_path),
                "contract_sha256": sha256(contract_path),
                "report": repo_path(root, display_report_path),
                "report_sha256": sha256(display_report_path),
                "runtime_atlas": repo_path(
                    root,
                    preview_dir
                    / f"{case['component']}.runtime-v1.atlas.png",
                ),
                "runtime_atlas_sha256": sha256(
                    preview_dir
                    / f"{case['component']}.runtime-v1.atlas.png"
                ),
                "real_layout": repo_path(root, previews["scene"]),
                "real_layout_sha256": sha256(previews["scene"]),
                "supported_layouts": repo_path(
                    root,
                    previews[
                        "trinket_board" if key == "trinket" else "consumable_board"
                    ],
                ),
                "supported_layouts_sha256": sha256(
                    previews[
                        "trinket_board" if key == "trinket" else "consumable_board"
                    ]
                ),
                "result": f"{expected_scenarios}/{expected_scenarios} pass",
                "violations": 0,
                "surrounding_pixels": (
                    "accepted AB.SLOT/AB.RAIL runtime plus deterministic provider "
                    "content; no simulation pixel is runtime input"
                ),
            },
            "package_validation": package_validation,
            "game_validation": {
                "status": "pending",
                "phase": "P6",
                "target": "Turtle WoW 1.18.1 / Interface 11200",
            },
        }
        write_json(root / case["runtime_manifest"], runtime_manifest)
        update_source_manifest(
            root,
            case,
            runtime_records[key],
            layouts[key],
            exporter_sha,
            contract_path,
            display_report_path,
            previews,
            package_validation,
        )
        reports[key] = {
            "component": case["component"],
            "runtime": runtime_records[key],
            "layout": layouts[key],
            "display_region": {
                "contract": repo_path(root, contract_path),
                "report": repo_path(root, display_report_path),
                "scenarios": expected_scenarios,
                "violations": 0,
            },
        }

    export_report = {
        "schema": "aeui-action-fieldkit-runtime-export-report-v1",
        "status": "pass",
        "phase": "P5",
        "components": reports,
        "adapter": {
            "file": ADAPTER_REL.as_posix(),
            "sha256": sha256(adapter_path),
        },
        "package_validation": package_validation,
        "imagegen_calls": 0,
        "game_validated": False,
    }
    write_json(preview_dir / "runtime-export-report.json", export_report)
    print(json.dumps(export_report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
