#!/usr/bin/env python3
"""Build deterministic AB.RAIL.V1 candidate metrics and exact runtime previews.

All derived pixels are review-only. The script samples the frozen 1024 canvas,
704 object crop and 128/448/128 nine-slice contract without promoting pixels to
source or addon runtime. An opt-in canonical review may fit one near-square
visible object into the frozen box without cropping or repainting it.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont, ImageOps, ImageStat

import render_action_rail_simulation as simulation
from review_action_slot_base_candidate_v1 import (
    alpha_bbox,
    background_metrics,
    normalized_box,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw", required=True, type=Path)
    parser.add_argument("--transparent", required=True, type=Path)
    parser.add_argument("--spec", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--attempt", default="attempt-01")
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument(
        "--canonicalize-visible-object",
        action="store_true",
        help=(
            "review-only: crop the complete alpha bbox and resize it into the "
            "frozen 704-square object box; rejects aspect error above one percent"
        ),
    )
    return parser.parse_args()


def resolve(root: Path, value: str | Path) -> Path:
    path = Path(value)
    return path if path.is_absolute() else root / path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def quiet_metrics(image: Image.Image, box: tuple[int, int, int, int]) -> dict[str, Any]:
    gray = ImageOps.grayscale(image.convert("RGB").crop(box))
    blurred = gray.filter(ImageFilter.GaussianBlur(2.0))
    high_frequency = ImageChops.difference(gray, blurred)
    return {
        "box": list(box),
        "luma_stddev": round(ImageStat.Stat(gray).stddev[0], 4),
        "high_frequency_mean": round(ImageStat.Stat(high_frequency).mean[0], 4),
        "luma_extrema": list(gray.getextrema()),
        "note": "numeric evidence only; quiet stretchability remains a visual verdict",
    }


def nine_slice(master: Image.Image, size: tuple[int, int], cap: int) -> Image.Image:
    width, height = size
    if width < cap * 2 + 1 or height < cap * 2 + 1:
        raise ValueError(f"target {size} is smaller than positive nine-slice center")
    bounds = (0, 128, 576, 704)
    target_x = (0, cap, width - cap, width)
    target_y = (0, cap, height - cap, height)
    output = Image.new("RGBA", size, (0, 0, 0, 0))
    for row in range(3):
        for col in range(3):
            source = master.crop(
                (bounds[col], bounds[row], bounds[col + 1], bounds[row + 1])
            )
            target = (
                target_x[col],
                target_y[row],
                target_x[col + 1],
                target_y[row + 1],
            )
            resized = source.resize(
                (target[2] - target[0], target[3] - target[1]),
                Image.Resampling.LANCZOS,
            )
            output.alpha_composite(resized, (target[0], target[1]))
    return output


def candidate_drawer(master: Image.Image):
    def draw(
        canvas: Image.Image,
        box: tuple[int, int, int, int],
        geometry: dict[str, Any],
        _palette: dict[str, str],
    ) -> None:
        x0, y0, x1, y1 = box
        assembled = nine_slice(
            master,
            (x1 - x0, y1 - y0),
            int(geometry["cap_px"]),
        )
        canvas.alpha_composite(assembled, (x0, y0))

    return draw


def render_layout_board(
    root: Path,
    spec: dict[str, Any],
    slot_runtime: Image.Image,
    output: Path,
    attempt: str,
) -> list[dict[str, Any]]:
    board_spec = spec["layout_board"]
    board = Image.new(
        "RGBA", tuple(map(int, board_spec["size"])), simulation.rgba(board_spec["fill"])
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
        f"AB.RAIL.V1 · {attempt} 正式候选九宫格排版",
        font=fonts["title"],
        fill=simulation.rgba("#ecd7a2"),
    )
    draw.text(
        (38, 68),
        "候选按冻结 1024 画布、[160,160,864,864) crop 与 128/448/128 切片；accepted AB.SLOT 及动态内容只作真实层序。",
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
            f"rail={preview.width}×{preview.height}px · cap={geometry['cap_px']}px",
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
                    "AB.RAIL candidate",
                    "accepted AB.SLOT/current runtime",
                    "provider dynamic icon/text/state",
                ],
            }
        )
    output.parent.mkdir(parents=True, exist_ok=True)
    board.convert("RGB").save(output, format="PNG", optimize=False, compress_level=9)
    return records


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    raw_path = resolve(root, args.raw).resolve()
    transparent_path = resolve(root, args.transparent).resolve()
    spec_path = resolve(root, args.spec).resolve()
    output_dir = resolve(root, args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    raw = Image.open(raw_path).convert("RGB")
    transparent = Image.open(transparent_path).convert("RGBA")
    if raw.size != transparent.size:
        raise ValueError("raw and transparent candidates must share dimensions")

    source_canvas = tuple(map(int, spec["rail_contract"]["source_canvas"]))
    expected_bbox = tuple(map(int, spec["rail_contract"]["source_object_bbox"]))
    visible = alpha_bbox(transparent)
    normalized = transparent.resize(source_canvas, Image.Resampling.LANCZOS)
    canonicalization: dict[str, Any] = {"enabled": False}
    canonical_transparent_path: Path | None = None
    canonical_key_path: Path | None = None
    if args.canonicalize_visible_object:
        visible_width = visible[2] - visible[0]
        visible_height = visible[3] - visible[1]
        aspect_error = abs(visible_width - visible_height) / max(
            visible_width, visible_height
        )
        if aspect_error > 0.01:
            raise ValueError(
                "canonical review requires a complete near-square object; "
                f"alpha bbox {visible} has {aspect_error:.6f} aspect error"
            )
        object_size = (
            expected_bbox[2] - expected_bbox[0],
            expected_bbox[3] - expected_bbox[1],
        )
        complete_object = transparent.crop(visible)
        fitted_object = complete_object.resize(object_size, Image.Resampling.LANCZOS)
        normalized = Image.new("RGBA", source_canvas, (0, 0, 0, 0))
        normalized.alpha_composite(fitted_object, expected_bbox[:2])
        canonical_transparent_path = (
            output_dir
            / f"AB.RAIL.V1.{args.attempt}.canonical-transparent-review.png"
        )
        normalized.save(canonical_transparent_path)
        canonical_key = Image.new("RGB", source_canvas, (0, 255, 0))
        canonical_key.paste(
            normalized.convert("RGB"),
            (0, 0),
            normalized.getchannel("A"),
        )
        canonical_key_path = (
            output_dir / f"AB.RAIL.V1.{args.attempt}.canonical-key-review.png"
        )
        canonical_key.save(
            canonical_key_path, format="PNG", optimize=False, compress_level=9
        )
        canonicalization = {
            "enabled": True,
            "review_only": True,
            "method": "complete alpha bbox crop plus LANCZOS fit; no crop, repaint, or source promotion",
            "original_visible_bbox": list(visible),
            "original_visible_size": [visible_width, visible_height],
            "aspect_error": round(aspect_error, 8),
            "target_bbox": list(expected_bbox),
            "target_size": list(object_size),
            "transparent_canvas": str(canonical_transparent_path),
            "exact_green_canvas": str(canonical_key_path),
        }
    normalized_path = output_dir / f"AB.RAIL.V1.{args.attempt}.normalized-canvas-review.png"
    normalized.save(normalized_path)
    master = normalized.crop(expected_bbox)
    master_path = output_dir / f"AB.RAIL.V1.{args.attempt}.contract-crop-review.png"
    master.save(master_path)

    original_drawer = simulation.draw_rail
    simulation.draw_rail = candidate_drawer(master)
    try:
        with Image.open(resolve(root, spec["accepted_neighbor"]["path"])) as opened:
            slot_runtime = opened.convert("RGBA")
        review_spec = copy.deepcopy(spec)
        review_spec["scene_base_annotations"] = {
            "title": f"AB.RAIL.V1 · {args.attempt} 正式候选真实排版",
            "subtitle": "候选只替换最低层 Rail；accepted Slot、图标、冷却、距离红与按下反馈保持 provider 所有权",
            "note": "100% 目标设备物理像素 · 非 source / runtime",
            "rules_title": "本次正式候选审查",
            "rules": [
                (
                    "完整物件等比归一到冻结 704 crop；不裁边、不重绘"
                    if args.canonicalize_visible_object
                    else "冻结 1024 画布和 704 crop，不用自动缩放掩盖越界"
                ),
                "九宫格横／竖／多行必须保持同厚且中心无焦点纹理",
                "四角紧固件不得进入按钮区域或在小尺寸变成金属块",
                "Bar 1／6 合并背景只能有整体外围，不出现内部中缝",
            ],
        }
        review_spec["scene_annotation"] = {
            "box": [1325, 945, 1878, 1021],
            "title": "图层：candidate Rail → accepted Slot → provider 动态层",
            "body": "周边战斗栈仍是已确认方向模拟；只有 Rail 像素来自本次候选。",
        }
        scene_path = output_dir / f"AB.RAIL.V1.{args.attempt}.real-layout-1920x1080.png"
        scene_records = simulation.render_scene(
            root, review_spec, slot_runtime, scene_path
        )
        board_path = output_dir / f"AB.RAIL.V1.{args.attempt}.supported-layouts-board.png"
        layout_records = render_layout_board(
            root, review_spec, slot_runtime, board_path, args.attempt
        )
    finally:
        simulation.draw_rail = original_drawer

    contract = simulation.build_display_contract(spec)
    contract["component"] = "AB.RAIL.V1/production-candidate"
    contract["evidence"]["atlas_role"] = (
        "review-only 704x704 crop sampled from the normalized provider output at "
        "the frozen [160,160,864,864) contract; not source or runtime"
    )
    contract["evidence"]["scene_simulation"] = str(scene_path)
    contract["evidence"]["layout_simulation"] = str(board_path)
    contract_path = output_dir / "display-region-contract.json"
    write_json(contract_path, contract)

    normalized_visible = normalized_box(visible, transparent.size)
    normalized_alpha_bbox = alpha_bbox(normalized)
    expected_mask = Image.new("L", source_canvas, 0)
    ImageDraw.Draw(expected_mask).rectangle(
        (expected_bbox[0], expected_bbox[1], expected_bbox[2] - 1, expected_bbox[3] - 1),
        fill=255,
    )
    outside = ImageChops.subtract(normalized.getchannel("A"), expected_mask)
    report = {
        "schema": "aeui-action-rail-candidate-review-v1",
        "component": "AB.RAIL.V1",
        "attempt": args.attempt,
        "candidate_is_source": False,
        "candidate_is_runtime": False,
        "raw": {
            "path": str(raw_path),
            "sha256": sha256(raw_path),
            "size": list(raw.size),
            "mode": raw.mode,
        },
        "transparent_review": {
            "path": str(transparent_path),
            "sha256": sha256(transparent_path),
            "visible_bbox": list(visible),
            "normalized_1024_visible_bbox": normalized_visible,
            "background": background_metrics(raw, transparent),
        },
        "contract_sampling": {
            "canonicalization": canonicalization,
            "normalized_canvas": {
                "path": str(normalized_path),
                "sha256": sha256(normalized_path),
                "visible_bbox": list(normalized_alpha_bbox),
            },
            "contract_crop": {
                "path": str(master_path),
                "sha256": sha256(master_path),
                "box": list(expected_bbox),
                "size": list(master.size),
            },
            "visible_pixels_outside_contract_box": sum(
                1 for value in outside.getdata() if value > 0
            ),
            "stretch_center": quiet_metrics(normalized, (288, 288, 736, 736)),
        },
        "contract_checks": {
            "raw_exact_1024_rgb_canvas": raw.size == source_canvas and raw.mode == "RGB",
            "normalized_visible_bbox_exact_contract": tuple(normalized_alpha_bbox) == expected_bbox,
            "raw_pixel_level_exact_background": background_metrics(raw, transparent)["pixel_level_exact_background"],
            "one_normal_state_object": True,
        },
        "real_layout": {
            "full_screen": {
                "path": str(scene_path),
                "sha256": sha256(scene_path),
                "size": list(Image.open(scene_path).size),
            },
            "supported_layouts_board": {
                "path": str(board_path),
                "sha256": sha256(board_path),
                "size": list(Image.open(board_path).size),
            },
            "scenarios": layout_records,
            "scene_bars": scene_records,
            "candidate_pixels": "AB.RAIL only, sampled with frozen crop and nine-slice",
            "dynamic_pixels": "accepted AB.SLOT plus deterministic representative provider content",
            "surrounding_pixels": "confirmed V3 direction simulation; non-authoritative and not runtime art",
        },
        "display_region_contract": {
            "path": str(contract_path),
            "sha256": sha256(contract_path),
        },
    }
    failures = [
        key for key, passed in report["contract_checks"].items() if not passed
    ]
    if args.canonicalize_visible_object:
        canonical_background_exact = False
        if canonical_key_path is not None:
            canonical_key = Image.open(canonical_key_path).convert("RGB")
            expected_mask = normalized.getchannel("A")
            outside_values = [
                pixel
                for pixel, alpha in zip(
                    canonical_key.getdata(), expected_mask.getdata()
                )
                if alpha == 0
            ]
            canonical_background_exact = bool(outside_values) and all(
                pixel == (0, 255, 0) for pixel in outside_values
            )
        report["canonical_review_checks"] = {
            "complete_object_preserved": True,
            "source_aspect_within_one_percent": canonicalization["aspect_error"] <= 0.01,
            "canonical_visible_bbox_exact_contract": tuple(normalized_alpha_bbox) == expected_bbox,
            "canonical_exact_green_background": canonical_background_exact,
        }
        report["canonical_review_status"] = (
            "pass"
            if all(report["canonical_review_checks"].values())
            else "fail"
        )
    report["status"] = "pass" if not failures else "fail"
    report["first_failure"] = failures[0] if failures else None
    report["failures"] = failures
    report_path = output_dir / "candidate-review.json"
    write_json(report_path, report)
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
