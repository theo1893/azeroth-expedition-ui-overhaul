#!/usr/bin/env python3
"""Build and review one QS-B1 V5-A cloth-donor candidate.

The provider raw remains untouched.  This script performs only the frozen V5-A
deterministic operations: isotropic square normalization, the fixed donor crop,
the tracked 4x polygon mask, transparent-RGB clearing, proportional runtime
reduction, and exact Quest Log real-layout assembly.  Every output is an
ignored review intermediate; this script never writes source or addon runtime.
"""

from __future__ import annotations

import argparse
from collections import deque
import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont


NORMALIZED_SIZE = (1024, 1024)
RUNTIME_MASTER_SIZE = (32, 174)
RUNTIME_PREFIX_HEIGHT = 166
RUNTIME_TAIL_HEIGHT = 8
MASK_SCALE = 4


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("raw", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument(
        "--spec",
        type=Path,
        default=Path(
            "tools/specs/quest_log_seal_substrate_simulation_v14.json"
        ),
    )
    parser.add_argument(
        "--display-template",
        type=Path,
        default=Path(
            "tools/specs/quest_log_seal_actions_simulation_v13_display_region.json"
        ),
    )
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--repo-commit", required=True)
    parser.add_argument("--session-id", required=True)
    return parser.parse_args()


def resolve(root: Path, value: str | Path) -> Path:
    path = Path(value)
    return path if path.is_absolute() else root / path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_module(path: Path, name: str) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    return image.convert("RGBA").getchannel("A").getbbox()


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def component_count(
    image: Image.Image,
    alpha_threshold: int = 8,
) -> tuple[int, int]:
    alpha = np.asarray(image.convert("RGBA"))[:, :, 3]
    # The frozen 4x -> 1x LANCZOS mask intentionally creates sub-8-alpha
    # resampling lobes.  Count semantic objects above that deterministic fringe
    # without changing or thresholding the candidate pixels themselves.
    visible = alpha >= alpha_threshold
    visited = np.zeros(visible.shape, dtype=bool)
    height, width = visible.shape
    count = 0
    largest = 0
    for start_y, start_x in np.argwhere(visible & ~visited):
        if visited[start_y, start_x]:
            continue
        count += 1
        size = 0
        queue: deque[tuple[int, int]] = deque(
            [(int(start_x), int(start_y))]
        )
        visited[start_y, start_x] = True
        while queue:
            x, y = queue.popleft()
            size += 1
            for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if (
                    0 <= nx < width
                    and 0 <= ny < height
                    and visible[ny, nx]
                    and not visited[ny, nx]
                ):
                    visited[ny, nx] = True
                    queue.append((nx, ny))
        largest = max(largest, size)
    return count, largest


def load_spec(root: Path, path: Path) -> tuple[dict[str, Any], dict[str, Any]]:
    renderer = load_module(
        root / "tools/render_quest_log_seal_layered_actions_simulation_v2.py",
        "aeui_qs_b1_v5a_renderer",
    )
    overlay = json.loads(resolve(root, path).read_text(encoding="utf-8"))
    return renderer.load_simulation_spec(resolve(root, path), root), overlay


def build_mask(mockup: dict[str, Any]) -> Image.Image:
    width, height = mockup["canonical_source_size"]
    scale = MASK_SCALE
    high = Image.new("L", (width * scale, height * scale), 0)
    points = [
        (int(point[0]) * scale, int(point[1]) * scale)
        for point in mockup["mask_polygon_source"]
    ]
    ImageDraw.Draw(high).polygon(points, fill=255)
    return high.resize((width, height), Image.Resampling.LANCZOS)


def normalize_and_compose(
    raw_image: Image.Image,
    mockup: dict[str, Any],
) -> tuple[Image.Image, Image.Image, Image.Image, Image.Image, dict[str, Any]]:
    raw_mode = raw_image.mode
    raw_square = raw_image.width == raw_image.height
    raw_alpha_opaque = True
    if "A" in raw_image.getbands():
        alpha = np.asarray(raw_image.getchannel("A"))
        raw_alpha_opaque = bool(np.all(alpha == 255))
    raw_rgb = raw_image.convert("RGB")
    normalized = raw_rgb.resize(NORMALIZED_SIZE, Image.Resampling.LANCZOS)
    crop_box = tuple(int(value) for value in mockup["donor_crop"])
    crop = normalized.crop(crop_box)
    mask = build_mask(mockup)
    composite = crop.convert("RGBA")
    composite.putalpha(mask)
    composite = clear_transparent_rgb(composite)
    metrics = {
        "raw_mode": raw_mode,
        "raw_size": list(raw_image.size),
        "raw_square": raw_square,
        "raw_alpha_opaque": raw_alpha_opaque,
        "normalized_size": list(normalized.size),
        "normalization": "whole-square isotropic LANCZOS",
        "crop_box": list(crop_box),
        "crop_size": list(crop.size),
        "mask_scale": MASK_SCALE,
        "mask_bbox_exclusive": list(mask.getbbox() or ()),
        "composite_bbox_exclusive": list(alpha_bbox(composite) or ()),
    }
    return normalized, crop, mask, composite, metrics


def runtime_master_from_composite(composite: Image.Image) -> Image.Image:
    return clear_transparent_rgb(
        composite.resize(RUNTIME_MASTER_SIZE, Image.Resampling.LANCZOS)
    )


def candidate_substrate(
    runtime_master: Image.Image,
    visible_count: int,
    menu_open: bool,
) -> Image.Image:
    if not menu_open:
        return clear_transparent_rgb(runtime_master.crop((0, 0, 32, 12)))
    prefix_height = 12 + visible_count * 22
    result = Image.new(
        "RGBA",
        (32, prefix_height + RUNTIME_TAIL_HEIGHT),
        (0, 0, 0, 0),
    )
    result.alpha_composite(
        runtime_master.crop((0, 0, 32, prefix_height)),
        (0, 0),
    )
    result.alpha_composite(
        runtime_master.crop((0, RUNTIME_PREFIX_HEIGHT, 32, 174)),
        (0, prefix_height),
    )
    return clear_transparent_rgb(result)


def quiet_band_metrics(crop: Image.Image, rows: list[int]) -> list[dict[str, Any]]:
    rgba = np.asarray(crop.convert("RGBA"), dtype=np.float32)
    luma = (
        0.2126 * rgba[:, :, 0]
        + 0.7152 * rgba[:, :, 1]
        + 0.0722 * rgba[:, :, 2]
    )
    results: list[dict[str, Any]] = []
    for row in rows:
        top = max(0, row - 8)
        bottom = min(crop.height, row + 9)
        band = luma[top:bottom]
        row_means = band.mean(axis=1)
        horizontal_gradient = np.abs(np.diff(band, axis=1))
        results.append(
            {
                "source_y": row,
                "band": [top, bottom],
                "mean_luma": float(band.mean()),
                "row_mean_range": float(row_means.max() - row_means.min()),
                "max_adjacent_row_mean_jump": float(
                    np.abs(np.diff(row_means)).max()
                )
                if len(row_means) > 1
                else 0.0,
                "p95_horizontal_luma_gradient": float(
                    np.percentile(horizontal_gradient, 95)
                )
                if horizontal_gradient.size
                else 0.0,
            }
        )
    return results


def image_metrics(
    composite: Image.Image,
    runtime_master: Image.Image,
    quiet_rows: list[int],
    crop: Image.Image,
) -> dict[str, Any]:
    source_rgba = np.asarray(composite.convert("RGBA"))
    runtime_rgba = np.asarray(runtime_master.convert("RGBA"))
    runtime_alpha = runtime_rgba[:, :, 3]
    runtime_luma = (
        0.2126 * runtime_rgba[:, :, 0]
        + 0.7152 * runtime_rgba[:, :, 1]
        + 0.0722 * runtime_rgba[:, :, 2]
    )
    visible = runtime_alpha > 0
    blurred = np.asarray(
        Image.fromarray(runtime_luma.astype(np.uint8), "L").filter(
            ImageFilter.GaussianBlur(2.0)
        )
    ).astype(np.float32)
    cuts: list[dict[str, Any]] = []
    for source_cut in quiet_rows:
        runtime_cut = source_cut // 4
        upper = max(0, runtime_cut - 2)
        lower = min(runtime_master.height, runtime_cut + 2)
        band = runtime_alpha[upper:lower]
        cuts.append(
            {
                "source_y": source_cut,
                "runtime_y": runtime_cut,
                "alpha_coverage": float((band > 0).mean()) if band.size else 0.0,
            }
        )
    seams: list[dict[str, Any]] = []
    tail_top = runtime_rgba[RUNTIME_PREFIX_HEIGHT]
    for visible_count in (1, 3, 5, 7):
        cutoff = 12 + visible_count * 22
        prefix_row = runtime_rgba[cutoff - 1]
        overlap = (prefix_row[:, 3] > 0) & (tail_top[:, 3] > 0)
        delta = (
            float(
                np.abs(
                    prefix_row[overlap, :3].astype(np.int16)
                    - tail_top[overlap, :3].astype(np.int16)
                ).mean()
            )
            if overlap.any()
            else None
        )
        seams.append(
            {
                "visible_count": visible_count,
                "prefix_height": cutoff,
                "overlap_pixels": int(overlap.sum()),
                "mean_rgb_delta_to_tail": delta,
            }
        )
    return {
        "source": {
            "size": list(composite.size),
            "mode": composite.mode,
            "visible_bbox_exclusive": list(alpha_bbox(composite) or ()),
            "visible_pixels": int((source_rgba[:, :, 3] > 0).sum()),
            "transparent_pixels": int((source_rgba[:, :, 3] == 0).sum()),
            "partial_alpha_pixels": int(
                (
                    (source_rgba[:, :, 3] > 0)
                    & (source_rgba[:, :, 3] < 255)
                ).sum()
            ),
            "transparent_rgb_zero": bool(
                np.all(source_rgba[source_rgba[:, :, 3] == 0, :3] == 0)
            ),
        },
        "runtime": {
            "size": list(runtime_master.size),
            "mode": runtime_master.mode,
            "visible_bbox_exclusive": list(alpha_bbox(runtime_master) or ()),
            "transparent_rgb_zero": bool(
                np.all(runtime_rgba[runtime_alpha == 0, :3] == 0)
            ),
            "mean_high_frequency_luma_residual": float(
                np.abs(runtime_luma - blurred)[visible].mean()
            )
            if visible.any()
            else None,
            "cut_bands": cuts,
            "dynamic_tail_seams": seams,
        },
        "quiet_bands": quiet_band_metrics(crop, quiet_rows),
    }


def checker(size: tuple[int, int], block: int = 12) -> Image.Image:
    image = Image.new("RGBA", size, (52, 44, 37, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], block):
        for x in range(0, size[0], block):
            if (x // block + y // block) % 2:
                draw.rectangle(
                    (x, y, x + block - 1, y + block - 1),
                    fill=(83, 72, 62, 255),
                )
    return image


def render_contact_sheet(
    root: Path,
    raw: Image.Image,
    normalized: Image.Image,
    crop: Image.Image,
    composite: Image.Image,
    runtime_master: Image.Image,
    quiet_rows: list[int],
    output: Path,
    attempt: str,
) -> None:
    sheet = Image.new("RGBA", (1580, 940), (31, 25, 21, 255))
    draw = ImageDraw.Draw(sheet, "RGBA")
    title = ImageFont.truetype(
        str(root / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"),
        22,
    )
    body = ImageFont.truetype(
        str(root / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"),
        15,
    )
    draw.text(
        (28, 22),
        f"QS-B1 V5-A 布面 donor / fixed crop+mask 技术审查 · {attempt}",
        font=title,
        fill=(235, 201, 132, 255),
    )

    raw_preview = raw.convert("RGBA")
    raw_preview.thumbnail((390, 390), Image.Resampling.LANCZOS)
    sheet.alpha_composite(raw_preview, (28, 84))
    draw.text((28, 490), "A · untouched provider raw", font=body, fill=(219, 183, 116, 255))

    normalized_preview = normalized.convert("RGBA").resize(
        (390, 390), Image.Resampling.LANCZOS
    )
    nx, ny = 28, 540
    sheet.alpha_composite(normalized_preview, (nx, ny))
    draw.rectangle(
        (nx + 170, ny + 62, nx + 220, ny + 327),
        outline=(237, 190, 79, 255),
        width=2,
    )
    draw.text((445, 84), "B · fixed 128×696 donor crop", font=body, fill=(219, 183, 116, 255))
    sheet.alpha_composite(crop.convert("RGBA"), (445, 118))

    annotated = crop.convert("RGBA")
    annotated_draw = ImageDraw.Draw(annotated, "RGBA")
    for row in quiet_rows:
        annotated_draw.rectangle((0, row - 8, 127, row + 8), fill=(224, 173, 76, 38))
        annotated_draw.line((0, row, 127, row), fill=(235, 191, 91, 190), width=1)
    sheet.alpha_composite(annotated, (605, 118))
    draw.text((605, 84), "C · 8 quiet bands (review overlay)", font=body, fill=(219, 183, 116, 255))

    composite_board = checker((160, 720), 10)
    composite_board.alpha_composite(composite, (16, 12))
    sheet.alpha_composite(composite_board, (765, 106))
    draw.text((765, 84), "D · review composite", font=body, fill=(219, 183, 116, 255))

    runtime_big = runtime_master.resize((128, 696), Image.Resampling.NEAREST)
    runtime_board = checker((160, 720), 10)
    runtime_board.alpha_composite(runtime_big, (16, 12))
    sheet.alpha_composite(runtime_board, (965, 106))
    draw.text((965, 84), "E · 32×174 runtime ×4", font=body, fill=(219, 183, 116, 255))

    notes = [
        "固定流程：square → whole-image 1024² LANCZOS → [448,164,576,860] crop",
        "mask：tracked V14 polygon at 4× → LANCZOS 128×696；透明 RGB 清零",
        "候选对象是 D，不是 A/B；本图与全部输出仍在 generated/，不是 source/runtime。",
    ]
    for index, value in enumerate(notes):
        draw.text((1160, 120 + index * 42), value, font=body, fill=(208, 177, 117, 255))
    sheet.save(output, "PNG")


def render_real_layout(
    root: Path,
    spec: dict[str, Any],
    runtime_master: Image.Image,
    output: Path,
    preview_dir: Path,
) -> tuple[list[dict[str, Any]], dict[str, bool], dict[str, dict[str, Any]]]:
    module = load_module(
        root / "tools/render_quest_log_seal_layered_actions_simulation_v2.py",
        "aeui_qs_b1_v5a_layout",
    )
    module.substrate_master_v5 = lambda _spec: runtime_master.copy()
    base = module.load_base_module(root)
    title_path = resolve(root, spec["inputs"]["title_font"])
    body_path = resolve(root, spec["inputs"]["body_font"])
    fonts = {
        "title": base.load_font(title_path, 16),
        "detail_title": base.load_font(title_path, 15),
        "heading": base.load_font(title_path, 11),
        "body": base.load_font(body_path, 10),
        "row": base.load_font(body_path, 10),
        "small": base.load_font(body_path, 9),
        "reward": base.load_font(body_path, 8),
        "board_title": base.load_font(title_path, 19),
        "board_body": base.load_font(body_path, 11),
        "board_small": base.load_font(body_path, 10),
    }
    shell, seal = base.load_inputs(root, spec)
    canvas = Image.new("RGBA", tuple(spec["canvas"]), module.BOARD)
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rectangle((0, 626, canvas.width, canvas.height), fill=module.BOARD_LOWER)
    for x in range(-90, canvas.width + 120, 150):
        draw.polygon(
            [(x, 626), (x + 126, 626), (x + 190, canvas.height), (x + 14, canvas.height)],
            fill=(67, 47, 32, 155),
            outline=(40, 28, 20, 180),
        )
    draw.text(
        (30, 22),
        "QS-B1 V5-A · 正式 composite 候选 · 真实 Quest Log 六态排版",
        font=fonts["board_title"],
        fill=(237, 201, 128, 255),
    )
    draw.text(
        (30, 52),
        "空白布底来自本次 fixed crop+mask composite；七纹章仍为 V12 几何占位，仅核对层序、遮挡、动态长度与命中合同。",
        font=fonts["board_body"],
        fill=(203, 173, 113, 255),
    )
    preview_dir.mkdir(parents=True, exist_ok=True)
    metrics: list[dict[str, Any]] = []
    preview_evidence: dict[str, dict[str, Any]] = {}
    for origin, state in zip(
        [tuple(value) for value in spec["presentation"]["origins"]],
        spec["states"],
    ):
        draw.text(
            (origin[0], origin[1] - 27),
            state["label"],
            font=fonts["board_body"],
            fill=(237, 201, 128, 255),
        )
        module.draw_state(base, canvas, shell, seal, origin, spec, fonts, state)
        metrics.append(module.state_metrics(spec, state))
        content = module.draw_detail_content(base, spec, fonts, seal, state)
        _, _, viewport_width, viewport_height = spec["layout"]["detail_viewport"]
        offset = state["scroll_offset"]
        preview = content.crop(
            (0, offset, viewport_width, offset + viewport_height)
        )
        preview_path = preview_dir / f"{state['id']}.png"
        preview.save(preview_path, "PNG")
        preview_evidence[state["id"]] = {
            "path": str(preview_path),
            "sha256": sha256(preview_path),
            "size": list(preview.size),
        }
    draw.text(
        (30, 1172),
        "候选范围仅为空白 substrate；QS-A1 火漆、真实书壳、18 行任务、长正文与 4 个奖励槽为当前 accepted/runtime 邻接 UI。",
        font=fonts["board_small"],
        fill=(213, 179, 113, 255),
    )
    draw.text(
        (30, 1195),
        "P3 review intermediate：不创建 source、manifest、runtime、atlas 或 addon 接入。",
        font=fonts["board_small"],
        fill=(192, 159, 103, 255),
    )
    canvas.save(output, "PNG")

    by_id = {item["id"]: item for item in metrics}
    closed = by_id["closed-top"]
    seven = by_id["open-all-seven"]
    five = by_id["open-filtered-five"]
    three = by_id["open-filtered-three-disabled"]
    partial = by_id["filtered-five-partial-scroll"]
    full = by_id["filtered-five-fully-scrolled-out"]
    first_reward_y = min(box[1] for box in spec["layout"]["reward_slots_content"])
    seven_tail_end = module.tail_box(spec, spec["states"][1])[1] + 8
    five_tail_end = module.tail_box(spec, spec["states"][2])[1] + 8
    three_tail_end = module.tail_box(spec, spec["states"][3])[1] + 8
    checks = {
        "frame_is_676x464": spec["frame"] == [676, 464],
        "detail_viewport_is_real_246x324": spec["layout"]["detail_viewport"] == [366, 64, 246, 324],
        "quest_rows_are_18": spec["content"]["quest_rows"] == 18,
        "reward_slots_are_4": spec["content"]["reward_slots"] == 4,
        "closed_has_no_action_buttons": not closed["buttons"],
        "closed_root_visible": closed["root_visible_area"] > 0,
        "seven_independent_buttons": len(seven["buttons"]) == 7,
        "seven_enabled": seven["enabled_action_count"] == 7,
        "seven_contiguous": module.contiguous(seven["buttons"]),
        "seven_reward_gap_32": first_reward_y - seven_tail_end == 32,
        "five_exact_order": five["visible_actions"] == ["share", "detail", "show", "reset", "abandon"],
        "five_no_blank_slots": len(five["buttons"]) == 5 and module.contiguous(five["buttons"]),
        "five_background_shortens_44": seven["background_height"] - five["background_height"] == 44,
        "five_tail_moves_44": seven_tail_end - five_tail_end == 44,
        "five_reward_gap_76": first_reward_y - five_tail_end == 76,
        "three_exact_order": three["visible_actions"] == ["share", "show", "abandon"],
        "three_no_blank_slots": len(three["buttons"]) == 3 and module.contiguous(three["buttons"]),
        "three_background_shortens_88": seven["background_height"] - three["background_height"] == 88,
        "three_tail_moves_88": seven_tail_end - three_tail_end == 88,
        "three_reward_gap_120": first_reward_y - three_tail_end == 120,
        "disabled_remains_in_flow": any(item["id"] == "show" for item in three["buttons"]),
        "disabled_has_no_hitbox": three["enabled_action_count"] == 2,
        "partial_clips_first_action": partial["buttons"][0]["visible_area"] < 32 * 22 and not partial["buttons"][0]["hitbox_enabled"],
        "partial_contiguous": module.contiguous(partial["buttons"]),
        "partial_disabled_reset": not next(item for item in partial["buttons"] if item["id"] == "reset")["hitbox_enabled"],
        "partial_expected_enabled": partial["enabled_action_count"] == 3,
        "full_background_zero": full["background_visible_area"] == 0,
        "full_hitboxes_zero": full["enabled_action_count"] == 0,
        "all_detail_previews_are_246x324": all(
            item["size"] == [246, 324] for item in preview_evidence.values()
        ),
    }
    return metrics, checks, preview_evidence


def build_display_contract(
    template: dict[str, Any],
    raw: Path,
    composite: Path,
    real_layout: Path,
    previews: dict[str, dict[str, Any]],
    output: Path,
    attempt: str,
) -> None:
    contract = json.loads(json.dumps(template))
    contract["component"] = (
        f"QS-B1/QUEST.LOG.ACTION.SEAL_MENU.SUBSTRATE.MAX/V5-A/{attempt}"
    )
    contract["evidence"] = {
        "provider": "QuestLogDetailScrollFrame + QuestLogDetailScrollChild",
        "adapter": "addon/AzerothExpeditionUI/Modules/Quests.lua",
        "candidate_raw": str(raw),
        "candidate_composite": str(composite),
        "candidate_real_layout": str(real_layout),
        "exact_detail_previews": previews,
        "substrate_ownership": "one visual-only canonical composite; dynamic prefix plus shared tail; no motif or action ownership",
        "motif_ownership": "V12 geometry placeholders are non-authoritative in this V5-A-only review",
        "candidate_source": False,
        "final_runtime": False,
    }
    contract["atlas"] = {
        "size": [128, 696],
        "visible_bbox": [0, 0, 128, 696],
        "require_exact_visible_coverage": True,
        "sampled_regions": [
            {"id": "substrate.canonical-composite", "box": [0, 0, 128, 696]}
        ],
    }
    contract["nine_slice"] = {
        "caps": {"left": 1, "right": 1, "top": 1, "bottom": 1},
        "minimum_frame_size": [3, 3],
    }
    output.write_text(
        json.dumps(contract, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    raw_path = args.raw.resolve()
    raw_image = Image.open(raw_path)
    spec, overlay = load_spec(root, args.spec)
    mockup = overlay["visual_mockup"]
    normalized, crop, mask, composite, construction = normalize_and_compose(
        raw_image,
        mockup,
    )
    runtime_master = runtime_master_from_composite(composite)
    components, largest_component = component_count(composite)
    quiet_rows = [int(value) for value in mockup["quiet_crop_rows_source"]]
    metrics = image_metrics(composite, runtime_master, quiet_rows, crop)

    base_name = args.attempt
    normalized_path = output_dir / f"{base_name}.normalized-donor.png"
    crop_path = output_dir / f"{base_name}.fixed-crop.png"
    mask_path = output_dir / f"{base_name}.mask-4x-downsampled.png"
    composite_path = output_dir / f"{base_name}.composite.png"
    runtime_path = output_dir / f"{base_name}.runtime-master-review.png"
    contact_path = output_dir / f"{base_name}.contact-sheet.png"
    real_layout_path = output_dir / f"{base_name}.real-layout.png"
    preview_dir = output_dir / f"{base_name}.detail-previews"
    display_contract_path = output_dir / f"{base_name}.display-region-contract.json"
    report_path = output_dir / f"{base_name}.review.json"

    normalized.save(normalized_path, "PNG")
    crop.save(crop_path, "PNG")
    mask.save(mask_path, "PNG")
    composite.save(composite_path, "PNG")
    runtime_master.save(runtime_path, "PNG")
    render_contact_sheet(
        root,
        raw_image,
        normalized,
        crop,
        composite,
        runtime_master,
        quiet_rows,
        contact_path,
        args.attempt,
    )
    state_metrics, layout_checks, preview_evidence = render_real_layout(
        root,
        spec,
        runtime_master,
        real_layout_path,
        preview_dir,
    )
    display_template = json.loads(
        resolve(root, args.display_template).read_text(encoding="utf-8")
    )
    build_display_contract(
        display_template,
        raw_path,
        composite_path,
        real_layout_path,
        preview_evidence,
        display_contract_path,
        args.attempt,
    )

    source_metrics = metrics["source"]
    runtime_metrics = metrics["runtime"]
    expected_crop = [448, 164, 576, 860]
    raw_mode_supported = raw_image.mode in ("RGB", "RGBA")
    checks = {
        "raw_canvas_is_square": construction["raw_square"],
        "raw_mode_is_rgb_or_rgba": raw_mode_supported,
        "raw_is_fully_opaque": construction["raw_alpha_opaque"],
        "deterministic_canvas_is_1024_square": construction["normalized_size"] == [1024, 1024],
        "fixed_crop_contract_is_exact": construction["crop_box"] == expected_crop,
        "fixed_crop_is_128x696": construction["crop_size"] == [128, 696],
        "mask_is_built_at_4x": construction["mask_scale"] == 4,
        "mask_visible_bbox_is_exact": construction["mask_bbox_exclusive"] == [0, 0, 128, 696],
        "composite_is_128x696_rgba": source_metrics["size"] == [128, 696] and source_metrics["mode"] == "RGBA",
        "composite_visible_bbox_is_exact": source_metrics["visible_bbox_exclusive"] == [0, 0, 128, 696],
        "composite_is_one_connected_object": components == 1,
        "composite_transparent_rgb_is_zero": source_metrics["transparent_rgb_zero"],
        "tail_contract_is_exactly_two_notches": mockup["tail_notch_count"] == 2,
        "runtime_is_exactly_32x174": runtime_metrics["size"] == [32, 174],
        "runtime_visible_bbox_is_exact": runtime_metrics["visible_bbox_exclusive"] == [0, 0, 32, 174],
        "runtime_transparent_rgb_is_zero": runtime_metrics["transparent_rgb_zero"],
        "all_dynamic_cut_bands_have_cloth": all(
            item["alpha_coverage"] >= 0.75
            for item in runtime_metrics["cut_bands"]
        ),
        "all_real_layout_geometry_checks_pass": all(layout_checks.values()),
    }
    first_failed = next((name for name, passed in checks.items() if not passed), None)
    outputs = {
        "normalized_donor": normalized_path,
        "fixed_crop": crop_path,
        "mask": mask_path,
        "composite": composite_path,
        "runtime_master_review": runtime_path,
        "contact_sheet": contact_path,
    }
    report = {
        "schema": "aeui.quest-seal-menu.substrate-donor-candidate-review.v1",
        "batch": "QS-B1 V5-A",
        "attempt": args.attempt,
        "repo_commit_before_generation": args.repo_commit,
        "fixed_executor_session_id": args.session_id,
        "raw": {
            "path": str(raw_path),
            "sha256": sha256(raw_path),
            "size": list(raw_image.size),
            "mode": raw_image.mode,
        },
        "deterministic_construction": construction,
        "mask_spec": {
            "path": str(resolve(root, args.spec)),
            "sha256": sha256(resolve(root, args.spec)),
            "polygon_points": len(mockup["mask_polygon_source"]),
            "tail_notch_count": mockup["tail_notch_count"],
        },
        "connected_components": {
            "count": components,
            "largest_visible_pixels": largest_component,
            "alpha_threshold": 8,
        },
        "metrics": metrics,
        "layout_checks": layout_checks,
        "layout_checks_passed": sum(layout_checks.values()),
        "layout_checks_total": len(layout_checks),
        "checks": checks,
        "checks_passed": sum(checks.values()),
        "checks_total": len(checks),
        "first_automated_failure": first_failed,
        "technical_status": "pass" if first_failed is None else "fail",
        "real_layout": {
            "path": str(real_layout_path),
            "sha256": sha256(real_layout_path),
            "frame": spec["frame"],
            "detail_viewport": spec["layout"]["detail_viewport"],
            "quest_rows": spec["content"]["quest_rows"],
            "reward_slots": spec["content"]["reward_slots"],
            "state_metrics": state_metrics,
            "detail_previews": preview_evidence,
            "v3b_motifs": "non-authoritative V12 local geometry placeholders",
        },
        "display_region_contract": {
            "path": str(display_contract_path),
            "sha256": sha256(display_contract_path),
        },
        "outputs": {
            key: {"path": str(path), "sha256": sha256(path)}
            for key, path in outputs.items()
        },
        "promotion": {
            "source_written": False,
            "runtime_written": False,
            "addon_changed": False,
        },
    }
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
