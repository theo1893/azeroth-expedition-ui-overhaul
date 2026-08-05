#!/usr/bin/env python3
"""Review one QS-B1 action-tab candidate in exact Quest Log geometry."""

from __future__ import annotations

import argparse
from collections import deque
import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any, Iterable

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SOURCE_CANVAS = (1024, 1024)
TARGET_BOX = (120, 442, 904, 582)
TARGET_SIZE = (784, 140)
RAW_ASPECT_RANGE = (5.45, 5.75)
ATLAS_SIZE = (1024, 32)
CELL_SIZE = (128, 32)
CELL_SAFE_BOX = (8, 6, 120, 26)
RUNTIME_SIZE = (112, 20)
RESAMPLE = Image.Resampling.LANCZOS
GREEN = np.array((0, 255, 0), dtype=np.uint8)
STATES = (
    "standard.normal",
    "standard.hover",
    "standard.pressed",
    "standard.disabled",
    "danger.normal",
    "danger.hover",
    "danger.pressed",
    "danger.disabled",
)
OPEN_STATE_INDICES = (0, 1, 2, 3, 0, 1, 4)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("raw", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--repo-root", type=Path, default=ROOT)
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--repo-commit", required=True)
    parser.add_argument("--session-id", required=True)
    parser.add_argument("--prompt-sha", required=True)
    parser.add_argument(
        "--display-contract",
        type=Path,
        default=ROOT
        / "tools"
        / "specs"
        / "quest_log_action_tabs_candidate_display_region_v1.json",
    )
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def relative(path: Path, root: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(
        str(path), size=size, layout_engine=ImageFont.Layout.BASIC
    )


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    alpha = np.asarray(image.getchannel("A"))
    ys, xs = np.where(alpha > 0)
    if not len(xs):
        return None
    return int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def shift_union(mask: np.ndarray) -> np.ndarray:
    expanded = mask.copy()
    expanded[1:, :] |= mask[:-1, :]
    expanded[:-1, :] |= mask[1:, :]
    expanded[:, 1:] |= mask[:, :-1]
    expanded[:, :-1] |= mask[:, 1:]
    return expanded


def dilate(mask: np.ndarray, steps: int) -> np.ndarray:
    result = mask.copy()
    for _ in range(steps):
        result = shift_union(result)
    return result


def edge_seeds(mask: np.ndarray) -> list[tuple[int, int]]:
    height, width = mask.shape
    seeds: list[tuple[int, int]] = []
    for x in np.flatnonzero(mask[0, :]):
        seeds.append((0, int(x)))
    for x in np.flatnonzero(mask[height - 1, :]):
        seeds.append((height - 1, int(x)))
    for y in np.flatnonzero(mask[:, 0]):
        seeds.append((int(y), 0))
    for y in np.flatnonzero(mask[:, width - 1]):
        seeds.append((int(y), width - 1))
    return seeds


def scanline_flood(
    mask: np.ndarray,
    seeds: Iterable[tuple[int, int]],
) -> np.ndarray:
    """Return the four-connected portion of mask reachable from seeds."""

    height, width = mask.shape
    reached = np.zeros(mask.shape, dtype=bool)
    queue: deque[tuple[int, int]] = deque(seeds)
    while queue:
        y, x = queue.popleft()
        if (
            y < 0
            or y >= height
            or x < 0
            or x >= width
            or reached[y, x]
            or not mask[y, x]
        ):
            continue
        left = x
        while left > 0 and mask[y, left - 1] and not reached[y, left - 1]:
            left -= 1
        right = x
        while (
            right + 1 < width
            and mask[y, right + 1]
            and not reached[y, right + 1]
        ):
            right += 1
        reached[y, left : right + 1] = True
        for next_y in (y - 1, y + 1):
            if next_y < 0 or next_y >= height:
                continue
            start = max(0, left - 1)
            stop = min(width, right + 2)
            candidates = mask[next_y, start:stop] & ~reached[next_y, start:stop]
            indices = np.flatnonzero(candidates)
            if not len(indices):
                continue
            run_starts = indices[
                np.concatenate(([True], np.diff(indices) > 1))
            ]
            queue.extend((next_y, start + int(value)) for value in run_starts)
    return reached


def primary_component(mask: np.ndarray) -> tuple[np.ndarray, int]:
    ys, xs = np.where(mask)
    if not len(xs):
        return np.zeros(mask.shape, dtype=bool), 0
    center_x = (int(xs.min()) + int(xs.max())) / 2
    center_y = (int(ys.min()) + int(ys.max())) / 2
    distances = (xs - center_x) ** 2 + (ys - center_y) ** 2
    selected = int(np.argmin(distances))
    component = scanline_flood(mask, [(int(ys[selected]), int(xs[selected]))])
    return component, int((mask & ~component).sum())


def edge_connected_chroma_key(
    raw: Image.Image,
) -> tuple[Image.Image, dict[str, Any]]:
    original = np.asarray(raw.convert("RGB")).copy()
    rgb = original.copy()
    red = rgb[:, :, 0].astype(np.int16)
    green = rgb[:, :, 1].astype(np.int16)
    blue = rgb[:, :, 2].astype(np.int16)
    strongest_other = np.maximum(red, blue)
    green_score = green - strongest_other
    eligible = (green >= 80) & (green_score >= 24)
    background = scanline_flood(eligible, edge_seeds(eligible))

    alpha = np.full(eligible.shape, 255, dtype=np.uint8)
    alpha[background] = 0
    boundary = dilate(background, 3) & ~background
    fringe = boundary & (green > strongest_other) & (green_score > 0)
    fringe_alpha = np.clip(
        ((24 - green_score.astype(np.float32)) / 24) * 255,
        0,
        255,
    ).astype(np.uint8)
    alpha[fringe] = np.minimum(alpha[fringe], fringe_alpha[fringe])

    partial = (alpha > 0) & (alpha < 255)
    rgb[:, :, 1][partial] = np.minimum(
        rgb[:, :, 1][partial],
        np.maximum(rgb[:, :, 0][partial], rgb[:, :, 2][partial]),
    )
    rgb[alpha == 0] = 0
    keyed = clear_transparent_rgb(
        Image.fromarray(np.dstack((rgb, alpha)), "RGBA")
    )

    visible = alpha > 0
    primary, secondary_pixels = primary_component(visible)
    exact_green = np.all(original == GREEN, axis=2)
    background_pixels = original[background]
    unique_background = (
        int(np.unique(background_pixels, axis=0).shape[0])
        if len(background_pixels)
        else 0
    )
    bbox = alpha_bbox(keyed)
    metrics: dict[str, Any] = {
        "source_size": list(raw.size),
        "source_mode": raw.mode,
        "source_exact_00ff00_pixels": int(exact_green.sum()),
        "edge_connected_background_pixels": int(background.sum()),
        "edge_connected_background_unique_rgb": unique_background,
        "edge_connected_background_exact_ratio": (
            float(exact_green[background].mean()) if background.any() else 0.0
        ),
        "transparent_pixels": int((alpha == 0).sum()),
        "partial_pixels": int(partial.sum()),
        "opaque_pixels": int((alpha == 255).sum()),
        "visible_pixels": int(visible.sum()),
        "primary_component_pixels": int(primary.sum()),
        "secondary_component_pixels": secondary_pixels,
        "raw_visible_bbox_exclusive": list(bbox or ()),
    }
    return keyed, metrics


def fit_to_target(
    keyed: Image.Image,
) -> tuple[Image.Image, dict[str, Any]]:
    bbox = alpha_bbox(keyed)
    if bbox is None:
        raise ValueError("candidate has no visible object after chroma key")
    crop = clear_transparent_rgb(keyed.crop(bbox))
    scale = min(TARGET_SIZE[0] / crop.width, TARGET_SIZE[1] / crop.height)
    size = (
        max(1, round(crop.width * scale)),
        max(1, round(crop.height * scale)),
    )
    resized = clear_transparent_rgb(crop.resize(size, RESAMPLE))
    output = Image.new("RGBA", SOURCE_CANVAS, (0, 0, 0, 0))
    paste = (
        TARGET_BOX[0] + (TARGET_SIZE[0] - size[0]) // 2,
        TARGET_BOX[1] + (TARGET_SIZE[1] - size[1]) // 2,
    )
    output.alpha_composite(resized, paste)
    normalized_bbox = alpha_bbox(output)
    return clear_transparent_rgb(output), {
        "raw_visible_bbox_exclusive": list(bbox),
        "raw_visible_size": [crop.width, crop.height],
        "raw_visible_aspect": crop.width / crop.height,
        "normalization_scale": scale,
        "normalized_visible_size": list(size),
        "normalized_visible_bbox_exclusive": list(normalized_bbox or ()),
        "target_bbox_exclusive": list(TARGET_BOX),
    }


def transparent_rgb_is_zero(image: Image.Image) -> bool:
    rgba = np.asarray(image.convert("RGBA"))
    hidden = rgba[:, :, 3] == 0
    return bool(np.all(rgba[:, :, :3][hidden] == 0))


def high_frequency_metrics(image: Image.Image) -> dict[str, float]:
    rgba = np.asarray(image.convert("RGBA"))
    alpha = rgba[:, :, 3] >= 128
    luma = (
        rgba[:, :, 0].astype(np.float32) * 0.299
        + rgba[:, :, 1].astype(np.float32) * 0.587
        + rgba[:, :, 2].astype(np.float32) * 0.114
    )
    horizontal = alpha[:, 1:] & alpha[:, :-1]
    vertical = alpha[1:, :] & alpha[:-1, :]
    horizontal_diff = np.abs(luma[:, 1:] - luma[:, :-1])[horizontal]
    vertical_diff = np.abs(luma[1:, :] - luma[:-1, :])[vertical]
    combined = np.concatenate((horizontal_diff, vertical_diff))
    return {
        "mean_neighbor_luma_delta": float(combined.mean())
        if len(combined)
        else 0.0,
        "p95_neighbor_luma_delta": float(np.percentile(combined, 95))
        if len(combined)
        else 0.0,
    }


def source_contract(
    raw: Image.Image,
    keyed: Image.Image,
    normalized: Image.Image,
    pixel_metrics: dict[str, Any],
    normalization: dict[str, Any],
) -> dict[str, Any]:
    bbox = normalization["raw_visible_bbox_exclusive"]
    width, height = normalization["raw_visible_size"]
    aspect = normalization["raw_visible_aspect"]
    margins = [bbox[0], bbox[1], raw.width - bbox[2], raw.height - bbox[3]]
    normalized_bbox = normalization["normalized_visible_bbox_exclusive"]
    normalized_width, normalized_height = normalization["normalized_visible_size"]
    checks = {
        "raw_canvas_exact_1024_square": raw.size == SOURCE_CANVAS,
        "raw_mode_rgb": raw.mode == "RGB",
        "raw_background_uniform_exact_00ff00": (
            pixel_metrics["edge_connected_background_pixels"] > 0
            and pixel_metrics["edge_connected_background_unique_rgb"] == 1
            and pixel_metrics["edge_connected_background_exact_ratio"] == 1.0
        ),
        "one_connected_primary_object": (
            pixel_metrics["primary_component_pixels"] > 0
            and pixel_metrics["secondary_component_pixels"] <= 16
        ),
        "raw_visible_aspect_5_45_to_5_75": (
            RAW_ASPECT_RANGE[0] <= aspect <= RAW_ASPECT_RANGE[1]
        ),
        "raw_not_edge_clipped": min(margins) > 0,
        "normalized_inside_target_bbox": (
            normalized_bbox[0] >= TARGET_BOX[0]
            and normalized_bbox[1] >= TARGET_BOX[1]
            and normalized_bbox[2] <= TARGET_BOX[2]
            and normalized_bbox[3] <= TARGET_BOX[3]
        ),
        "normalized_uses_target_safe_box": (
            normalized_width >= 763 and normalized_height >= 136
        ),
        "transparent_rgb_zero": (
            transparent_rgb_is_zero(keyed)
            and transparent_rgb_is_zero(normalized)
        ),
    }
    return {
        "raw_visible_bbox_exclusive": bbox,
        "raw_visible_size": [width, height],
        "raw_visible_aspect": aspect,
        "raw_margins_ltrb": margins,
        "normalized_visible_bbox_exclusive": normalized_bbox,
        "normalized_visible_size": [normalized_width, normalized_height],
        "checks": checks,
        "overall": "pass" if all(checks.values()) else "fail",
    }


def apply_state(
    sprite: Image.Image,
    *,
    state: str,
    danger: bool,
) -> Image.Image:
    alpha = sprite.getchannel("A")
    rgb = sprite.convert("RGB")
    if state == "hover":
        rgb = ImageEnhance.Brightness(rgb).enhance(1.09)
        rgb = ImageEnhance.Color(rgb).enhance(1.04)
    elif state == "pressed":
        rgb = ImageEnhance.Brightness(rgb).enhance(0.78)
    elif state == "disabled":
        rgb = ImageEnhance.Color(rgb).enhance(0.22)
        rgb = ImageEnhance.Brightness(rgb).enhance(0.72)
    result = clear_transparent_rgb(Image.merge("RGBA", (*rgb.split(), alpha)))
    if not danger:
        return result

    rgba = np.asarray(result).copy()
    visible = rgba[:, :, 3] > 0
    eroded = visible.copy()
    eroded[1:, :] &= visible[:-1, :]
    eroded[:-1, :] &= visible[1:, :]
    eroded[:, 1:] &= visible[:, :-1]
    eroded[:, :-1] &= visible[:, 1:]
    border = visible & ~eroded
    yy, xx = np.indices(visible.shape)
    short_trace = border & (
        (xx >= round(visible.shape[1] * 0.83))
        | (
            (yy >= round(visible.shape[0] * 0.82))
            & (xx >= round(visible.shape[1] * 0.55))
        )
    )
    burgundy = np.array((104, 47, 43), dtype=np.float32)
    current = rgba[:, :, :3].astype(np.float32)
    current[short_trace] = current[short_trace] * 0.45 + burgundy * 0.55
    rgba[:, :, :3] = np.clip(current, 0, 255).astype(np.uint8)
    return clear_transparent_rgb(Image.fromarray(rgba, "RGBA"))


def make_atlas(
    normalized: Image.Image,
) -> tuple[Image.Image, dict[str, Any]]:
    bbox = alpha_bbox(normalized)
    if bbox is None:
        raise ValueError("normalized candidate has no visible object")
    crop = clear_transparent_rgb(normalized.crop(bbox))
    scale = min(RUNTIME_SIZE[0] / crop.width, RUNTIME_SIZE[1] / crop.height)
    runtime_size = (
        max(1, round(crop.width * scale)),
        max(1, round(crop.height * scale)),
    )
    base = clear_transparent_rgb(crop.resize(runtime_size, RESAMPLE))
    atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
    records: dict[str, Any] = {}
    for index, state_name in enumerate(STATES):
        family, state = state_name.split(".")
        sprite = apply_state(base, state=state, danger=family == "danger")
        cell_x = index * CELL_SIZE[0]
        paste = (
            cell_x
            + CELL_SAFE_BOX[0]
            + (RUNTIME_SIZE[0] - sprite.width) // 2,
            CELL_SAFE_BOX[1]
            + (RUNTIME_SIZE[1] - sprite.height) // 2,
        )
        atlas.alpha_composite(sprite, paste)
        records[state_name] = {
            "cell_xyxy": [cell_x, 0, cell_x + CELL_SIZE[0], CELL_SIZE[1]],
            "uv_sample_xyxy": [
                cell_x + CELL_SAFE_BOX[0],
                CELL_SAFE_BOX[1],
                cell_x + CELL_SAFE_BOX[2],
                CELL_SAFE_BOX[3],
            ],
            "actual_visible_xyxy": [
                paste[0],
                paste[1],
                paste[0] + sprite.width,
                paste[1] + sprite.height,
            ],
            "actual_visible_size": [sprite.width, sprite.height],
        }
    return clear_transparent_rgb(atlas), {
        "size": list(ATLAS_SIZE),
        "cell_size": list(CELL_SIZE),
        "runtime_safe_size": list(RUNTIME_SIZE),
        "source_runtime_scale": scale,
        "records": records,
        "transparent_rgb_zero": transparent_rgb_is_zero(atlas),
    }


def load_renderer(repo: Path) -> Any:
    path = repo / "tools" / "render_quest_log_seal_actions_simulation_v1.py"
    spec = importlib.util.spec_from_file_location(
        "aeui_qs_b1_candidate_renderer", path
    )
    if spec is None or spec.loader is None:
        raise ImportError(path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def crop_atlas_state(atlas: Image.Image, state_index: int) -> Image.Image:
    cell_x = state_index * CELL_SIZE[0]
    return atlas.crop(
        (
            cell_x + CELL_SAFE_BOX[0],
            CELL_SAFE_BOX[1],
            cell_x + CELL_SAFE_BOX[2],
            CELL_SAFE_BOX[3],
        )
    )


def install_candidate_tabs(renderer: Any, atlas: Image.Image) -> None:
    def draw_candidate_tabs(
        layer: Image.Image,
        shell: Image.Image,
        spec: dict[str, Any],
        origin: tuple[int, int],
        fonts: dict[str, ImageFont.FreeTypeFont],
    ) -> None:
        ox, oy = origin
        labels = spec["content"]["menu_actions"]
        text_boxes = spec["layout"]["action_text_safe"]
        draw = ImageDraw.Draw(layer, "RGBA")
        for index, (slot, state_index) in enumerate(
            zip(spec["layout"]["action_slots"], OPEN_STATE_INDICES, strict=True)
        ):
            x, y, width, height = slot
            sprite = crop_atlas_state(atlas, state_index)
            pressed = state_index in (2, 6)
            texture_layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
            texture_layer.alpha_composite(sprite, (1, 1) if pressed else (0, 0))
            layer.alpha_composite(texture_layer, (ox + x, oy + y))
            tx, ty, tw, th = text_boxes[index]
            if state_index == 3:
                color = (137, 121, 98, 210)
            elif state_index >= 4:
                color = (188, 129, 111, 255)
            else:
                color = (221, 193, 137, 255)
            offset = 1 if pressed else 0
            draw.text(
                (ox + tx + tw / 2 + offset, oy + ty + th / 2 + offset),
                labels[index],
                font=fonts["small"],
                fill=color,
                anchor="mm",
            )
        mx, my, mw, mh = spec["layout"]["page_edge_mask"]
        edge = shell.crop((mx, my, mx + mw, my + mh))
        layer.alpha_composite(edge, (ox + mx, oy + my))

    renderer.draw_exterior_ledger_tabs = draw_candidate_tabs


def renderer_fonts(renderer: Any, repo: Path, spec: dict[str, Any]) -> dict[str, Any]:
    title_path = repo / spec["inputs"]["title_font"]
    body_path = repo / spec["inputs"]["body_font"]
    return {
        "title": renderer.font(title_path, 16),
        "detail_title": renderer.font(title_path, 15),
        "heading": renderer.font(title_path, 11),
        "body": renderer.font(body_path, 10),
        "row": renderer.font(body_path, 10),
        "small": renderer.font(body_path, 9),
        "reward": renderer.font(body_path, 8),
        "menu": renderer.font(body_path, 11),
        "menu_title": renderer.font(title_path, 12),
    }


def render_scenario(
    renderer: Any,
    repo: Path,
    spec: dict[str, Any],
    fonts: dict[str, Any],
    seal: Image.Image,
    *,
    size: tuple[int, int],
    origin: tuple[int, int],
    menu_open: bool,
) -> Image.Image:
    image = Image.new("RGBA", size, (38, 31, 27, 255))
    renderer.draw_quest_log(image, repo, spec, origin, fonts, seal, menu_open)
    return image


def draw_geometry_debug(
    image: Image.Image,
    spec: dict[str, Any],
    origin: tuple[int, int],
) -> Image.Image:
    result = image.copy()
    draw = ImageDraw.Draw(result, "RGBA")
    ox, oy = origin
    for slot in spec["layout"]["action_slots"]:
        x, y, width, height = slot
        draw.rectangle(
            (ox + x, oy + y, ox + x + width - 1, oy + y + height - 1),
            outline=(246, 206, 82, 240),
            width=1,
        )
    for box in spec["layout"]["action_text_safe"]:
        x, y, width, height = box
        draw.rectangle(
            (ox + x, oy + y, ox + x + width - 1, oy + y + height - 1),
            outline=(82, 220, 211, 230),
            width=1,
        )
    for key, color in (
        ("detail", (87, 181, 250, 220)),
        ("page_edge_mask", (243, 129, 78, 220)),
    ):
        x, y, width, height = spec["layout"][key]
        draw.rectangle(
            (ox + x, oy + y, ox + x + width - 1, oy + y + height - 1),
            outline=color,
            width=1,
        )
    for box in spec["layout"]["reward_slots"]:
        x, y, width, height = box
        draw.rectangle(
            (ox + x, oy + y, ox + x + width - 1, oy + y + height - 1),
            outline=(126, 220, 107, 220),
            width=1,
        )
    return result


def intersects(left: list[int], right: list[int]) -> bool:
    lx, ly, lw, lh = left
    rx, ry, rw, rh = right
    return not (
        lx + lw <= rx
        or rx + rw <= lx
        or ly + lh <= ry
        or ry + rh <= ly
    )


def intersection_width(left: list[int], right: list[int]) -> int:
    return max(0, min(left[0] + left[2], right[0] + right[2]) - max(left[0], right[0]))


def geometry_checks(spec: dict[str, Any]) -> dict[str, Any]:
    layout = spec["layout"]
    slots = layout["action_slots"]
    text_boxes = layout["action_text_safe"]
    page_edge = layout["page_edge_mask"]
    menu = layout["exterior_action_menu"]
    detail = layout["detail"]
    rewards = layout["reward_slots"]
    checks = {
        "seven_action_slots": len(slots) == 7,
        "all_action_slots_112x20": all(box[2:] == [112, 20] for box in slots),
        "menu_is_112x158": menu[2:] == [112, 158],
        "right_outset_is_48": menu[0] + menu[2] - spec["frame"][0] == 48,
        "detail_overlap_zero": not intersects(menu, detail),
        "reward_overlap_zero": all(not intersects(menu, box) for box in rewards),
        "page_edge_occludes_16px_of_each_root": all(
            intersection_width(page_edge, box) == 16 for box in slots
        ),
        "text_begins_after_page_edge": all(
            box[0] >= page_edge[0] + page_edge[2] for box in text_boxes
        ),
        "right_clamp_formula_is_8px": (
            max(0, 16 + spec["frame"][0] + 48 - (740 - 8)) == 8
        ),
    }
    return {
        "checks": checks,
        "overall": "pass" if all(checks.values()) else "fail",
    }


def checker(size: tuple[int, int], block: int = 16) -> Image.Image:
    image = Image.new("RGBA", size, (57, 50, 45, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], block):
        for x in range(0, size[0], block):
            if (x // block + y // block) % 2:
                draw.rectangle(
                    (x, y, x + block - 1, y + block - 1),
                    fill=(88, 79, 71, 255),
                )
    return image


def fitted_preview(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    preview = image.copy().convert("RGBA")
    preview.thumbnail(size, RESAMPLE)
    panel = checker(size)
    panel.alpha_composite(
        preview,
        ((size[0] - preview.width) // 2, (size[1] - preview.height) // 2),
    )
    return panel


def render_review_sheet(
    repo: Path,
    raw: Image.Image,
    keyed: Image.Image,
    normalized: Image.Image,
    atlas: Image.Image,
    source: dict[str, Any],
    attempt: str,
) -> Image.Image:
    sheet = Image.new("RGBA", (1536, 940), (34, 27, 23, 255))
    draw = ImageDraw.Draw(sheet, "RGBA")
    title_font = font(
        repo
        / "addon"
        / "AzerothExpeditionUI"
        / "Media"
        / "Fonts"
        / "NotoSerifSC-SemiBold.ttf",
        24,
    )
    body_font = font(
        repo
        / "addon"
        / "AzerothExpeditionUI"
        / "Media"
        / "Fonts"
        / "NotoSansSC-Medium.ttf",
        16,
    )
    draw.text(
        (32, 24),
        f"QS-B1 候选完整审查 · {attempt}",
        font=title_font,
        fill=(235, 202, 135, 255),
    )
    panels = (
        ("untouched raw", raw.convert("RGBA")),
        ("edge-connected key", keyed),
        ("aspect-preserving bbox-fit review", normalized),
    )
    for index, (label, image) in enumerate(panels):
        x = 32 + index * 500
        sheet.alpha_composite(fitted_preview(image, (468, 468)), (x, 76))
        draw.text((x, 557), label, font=body_font, fill=(218, 185, 124, 255))

    normal = crop_atlas_state(atlas, 0)
    runtime_panel = Image.new("RGBA", (1472, 245), (55, 43, 34, 255))
    runtime_draw = ImageDraw.Draw(runtime_panel, "RGBA")
    runtime_draw.text(
        (20, 18),
        "临时八态 atlas（4× 最近邻）与 112×20 实际 normal",
        font=body_font,
        fill=(231, 198, 134, 255),
    )
    atlas_zoom = atlas.resize((1024, 128), Image.Resampling.NEAREST)
    runtime_panel.alpha_composite(atlas_zoom, (20, 56))
    runtime_panel.alpha_composite(normal, (1090, 63))
    runtime_panel.alpha_composite(
        normal.resize((336, 60), Image.Resampling.NEAREST), (1090, 112)
    )
    failed = [name for name, passed in source["checks"].items() if not passed]
    runtime_draw.text(
        (20, 202),
        "机器源合同："
        + source["overall"]
        + "；失败："
        + (" / ".join(failed) if failed else "无"),
        font=body_font,
        fill=(227, 111, 86, 255)
        if failed
        else (118, 207, 126, 255),
    )
    sheet.alpha_composite(runtime_panel, (32, 626))
    return sheet


def render_layout_board(
    repo: Path,
    closed: Image.Image,
    opened: Image.Image,
    clamped: Image.Image,
) -> Image.Image:
    board = Image.new("RGBA", (1536, 1055), (33, 28, 25, 255))
    draw = ImageDraw.Draw(board, "RGBA")
    label_font = font(
        repo
        / "addon"
        / "AzerothExpeditionUI"
        / "Media"
        / "Fonts"
        / "NotoSansSC-Medium.ttf",
        15,
    )
    draw.text(
        (36, 20),
        "100% UI 像素：closed / open / screen-right clamp",
        font=label_font,
        fill=(235, 202, 135, 255),
    )
    board.alpha_composite(closed, (36, 70))
    board.alpha_composite(opened, (776, 70))
    board.alpha_composite(clamped, (398, 572))
    draw.text((36, 47), "closed · 676×464", font=label_font, fill=(215, 183, 124, 255))
    draw.text((776, 47), "open · 724×464", font=label_font, fill=(215, 183, 124, 255))
    draw.text(
        (398, 549),
        "right clamp · screen 740 / safe-right 732 / origin 16→8",
        font=label_font,
        fill=(215, 183, 124, 255),
    )
    return board


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, "PNG", optimize=False, compress_level=9)


def output_record(path: Path, repo: Path) -> dict[str, Any]:
    return {"path": relative(path, repo), "sha256": sha256(path)}


def main() -> None:
    args = parse_args()
    repo = args.repo_root.resolve()
    raw_path = args.raw.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    with Image.open(raw_path) as opened:
        raw_mode = opened.mode
        raw = opened.copy()
    if raw_mode != raw.mode:
        raise AssertionError("raw mode changed while loading")

    keyed, pixel_metrics = edge_connected_chroma_key(raw)
    normalized, normalization = fit_to_target(keyed)
    source = source_contract(raw, keyed, normalized, pixel_metrics, normalization)
    atlas, atlas_metrics = make_atlas(normalized)

    renderer = load_renderer(repo)
    simulation_spec = json.loads(
        (repo / "tools/specs/quest_log_seal_actions_simulation_v9.json").read_text(
            encoding="utf-8"
        )
    )
    install_candidate_tabs(renderer, atlas)
    fonts = renderer_fonts(renderer, repo, simulation_spec)
    seal = renderer.load_seal(repo, simulation_spec)
    closed = render_scenario(
        renderer,
        repo,
        simulation_spec,
        fonts,
        seal,
        size=(676, 464),
        origin=(0, 0),
        menu_open=False,
    )
    opened = render_scenario(
        renderer,
        repo,
        simulation_spec,
        fonts,
        seal,
        size=(724, 464),
        origin=(0, 0),
        menu_open=True,
    )
    clamped = render_scenario(
        renderer,
        repo,
        simulation_spec,
        fonts,
        seal,
        size=(740, 464),
        origin=(8, 0),
        menu_open=True,
    )
    geometry_debug = draw_geometry_debug(opened, simulation_spec, (0, 0))
    review_sheet = render_review_sheet(
        repo, raw, keyed, normalized, atlas, source, args.attempt
    )
    layout_board = render_layout_board(repo, closed, opened, clamped)

    stem = args.attempt
    paths = {
        "transparent": output_dir / f"{stem}.transparent.png",
        "normalized_review": output_dir / f"{stem}.normalized-review.png",
        "temporary_atlas": output_dir / f"{stem}.temporary-atlas.png",
        "review_sheet": output_dir / f"{stem}.review-sheet.png",
        "closed": output_dir / f"{stem}.closed-676x464.png",
        "open": output_dir / f"{stem}.open-724x464.png",
        "clamped": output_dir / f"{stem}.clamped-740x464.png",
        "layout_board": output_dir / f"{stem}.real-layout-board.png",
        "geometry_debug": output_dir / f"{stem}.geometry-debug.png",
    }
    images = {
        "transparent": keyed,
        "normalized_review": normalized,
        "temporary_atlas": atlas,
        "review_sheet": review_sheet,
        "closed": closed,
        "open": opened,
        "clamped": clamped,
        "layout_board": layout_board,
        "geometry_debug": geometry_debug,
    }
    for key, image in images.items():
        save_png(image, paths[key])

    display_contract = args.display_contract.resolve()
    contract_copy = output_dir / f"{stem}.display-region-contract.json"
    contract_copy.write_text(
        display_contract.read_text(encoding="utf-8"), encoding="utf-8"
    )
    geometry = geometry_checks(simulation_spec)
    metrics_path = output_dir / f"{stem}.metrics.json"
    metrics = {
        "schema": "aeui.quest-log.action-tab.candidate-review.v1",
        "attempt": args.attempt,
        "repo_commit": args.repo_commit,
        "session_id": args.session_id,
        "prompt_sha256": args.prompt_sha,
        "raw": {
            "path": relative(raw_path, repo),
            "sha256": sha256(raw_path),
            "size": list(raw.size),
            "mode": raw.mode,
        },
        "pixel_metrics": pixel_metrics,
        "normalization_preview": normalization,
        "source_contract": source,
        "source_high_frequency": high_frequency_metrics(keyed),
        "normalized_high_frequency": high_frequency_metrics(normalized),
        "temporary_atlas": atlas_metrics,
        "geometry_contract": geometry,
        "display_region_validation": "pending-external-validator",
        "visual_review": "pending",
        "outputs": {key: output_record(path, repo) for key, path in paths.items()},
        "display_contract": output_record(contract_copy, repo),
    }
    metrics_path.write_text(
        json.dumps(metrics, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(metrics_path)
    print(contract_copy)


if __name__ == "__main__":
    main()
