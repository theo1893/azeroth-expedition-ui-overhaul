#!/usr/bin/env python3
"""Review one QL-D V2 reward-slot candidate without promoting it.

The provider raw is immutable. This reviewer applies only the authorized
square normalization, edge-connected chroma key and despill, proportional
visible-bbox fit, four-state derivation, atlas packing, and exact 0/1/2/4/6
Quest Log assembly. Every output remains under ignored ``generated/``.
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


ROOT = Path(__file__).resolve().parents[1]
RESAMPLE = Image.Resampling.LANCZOS
GREEN = np.array((0, 255, 0), dtype=np.uint8)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("raw", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--repo-root", type=Path, default=ROOT)
    parser.add_argument("--repo-commit", required=True)
    parser.add_argument("--session-id", required=True)
    parser.add_argument(
        "--production-contract",
        type=Path,
        default=Path("tools/specs/quest_log_reward_slot_production_v2.json"),
    )
    parser.add_argument(
        "--display-template",
        type=Path,
        default=Path(
            "tools/specs/quest_log_reward_slot_candidate_display_region_v2.json"
        ),
    )
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


def display(root: Path, path: Path) -> str:
    resolved = path.resolve()
    try:
        return resolved.relative_to(root).as_posix()
    except ValueError:
        return str(resolved)


def load_module(path: Path, name: str) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def alpha_bbox(
    image: Image.Image, threshold: int = 0
) -> tuple[int, int, int, int] | None:
    alpha = np.asarray(image.convert("RGBA"))[:, :, 3]
    ys, xs = np.where(alpha > threshold)
    if not len(xs):
        return None
    return int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def clear_edge_connected_green(image: Image.Image) -> tuple[Image.Image, int]:
    """Clear only low-alpha green spill connected to transparency."""
    rgba = np.asarray(image.convert("RGBA")).copy()
    r = rgba[:, :, 0].astype(np.int16)
    g = rgba[:, :, 1].astype(np.int16)
    b = rgba[:, :, 2].astype(np.int16)
    visible = rgba[:, :, 3] > 0
    greenish = visible & (g - np.maximum(r, b) >= 10) & (g - b >= 5)
    transparent = rgba[:, :, 3] == 0
    passable = transparent | greenish | (visible & (rgba[:, :, 3] < 16))
    flood = Image.fromarray(
        np.where(passable, 0, 255).astype(np.uint8), "L"
    ).copy()
    width, height = image.size
    for seed in (
        (0, 0),
        (width - 1, 0),
        (0, height - 1),
        (width - 1, height - 1),
        (width // 2, 0),
        (width // 2, height - 1),
        (0, height // 2),
        (width - 1, height // 2),
    ):
        if flood.getpixel(seed) == 0:
            ImageDraw.floodfill(flood, seed, 128, thresh=0)
    connected = np.asarray(flood) == 128
    remove = connected & greenish
    rgba[remove, 3] = 0
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA"), int(remove.sum())


def normalize_square(raw: Image.Image, size: tuple[int, int]) -> Image.Image:
    if raw.width != raw.height:
        raise ValueError("QL-D V2 provider output must be square")
    return raw.convert("RGB").resize(size, RESAMPLE)


def edge_connected_chroma_key(
    normalized: Image.Image,
) -> tuple[Image.Image, dict[str, Any]]:
    rgb = np.asarray(normalized.convert("RGB"), dtype=np.uint8)
    r = rgb[:, :, 0].astype(np.int16)
    g = rgb[:, :, 1].astype(np.int16)
    b = rgb[:, :, 2].astype(np.int16)
    green_score = g - np.maximum(r, b)
    greenish = (g >= 82) & (green_score >= 20) & ((g - b) >= 10)

    flood = Image.fromarray(
        np.where(greenish, 0, 255).astype(np.uint8), "L"
    ).copy()
    width, height = normalized.size
    seeds = (
        (0, 0),
        (width - 1, 0),
        (0, height - 1),
        (width - 1, height - 1),
        (width // 2, 0),
        (width // 2, height - 1),
        (0, height // 2),
        (width - 1, height // 2),
    )
    for seed in seeds:
        if flood.getpixel(seed) == 0:
            ImageDraw.floodfill(flood, seed, 128, thresh=0)
    connected = np.asarray(flood) == 128

    alpha = np.full((height, width), 255, dtype=np.uint8)
    alpha[connected] = 0
    rgba = np.dstack((rgb.copy(), alpha))
    rgba[alpha == 0, :3] = 0
    keyed = Image.fromarray(rgba, "RGBA")

    # Remove green from only the narrow visible band touching keyed
    # transparency. This changes neither object geometry nor interior colour.
    transparent = Image.fromarray(
        np.where(alpha == 0, 255, 0).astype(np.uint8), "L"
    )
    near_transparent = np.asarray(transparent.filter(ImageFilter.MaxFilter(7))) > 0
    visible = alpha > 0
    edge_green = visible & near_transparent & (green_score >= 4)
    keyed_rgba = np.asarray(keyed).copy()
    edge_limit = np.maximum(
        keyed_rgba[:, :, 0].astype(np.int16),
        keyed_rgba[:, :, 2].astype(np.int16),
    ) + 8
    keyed_rgba[:, :, 1][edge_green] = np.minimum(
        keyed_rgba[:, :, 1][edge_green], edge_limit[edge_green]
    ).astype(np.uint8)
    keyed = clear_transparent_rgb(Image.fromarray(keyed_rgba, "RGBA"))

    background = rgb[connected]
    exact = np.all(rgb == GREEN, axis=2)
    bbox = alpha_bbox(keyed)
    return keyed, {
        "normalized_size": list(normalized.size),
        "edge_connected_background_pixels": int(connected.sum()),
        "background_unique_rgb": int(len(np.unique(background, axis=0)))
        if len(background)
        else 0,
        "background_exact_00ff00_pixels": int(exact[connected].sum()),
        "background_exact_00ff00_ratio": float(exact[connected].mean())
        if int(connected.sum())
        else 0.0,
        "edge_despill_pixels": int(edge_green.sum()),
        "visible_bbox_exclusive": list(bbox or ()),
    }


def connected_components(
    image: Image.Image, threshold: int = 8
) -> dict[str, Any]:
    alpha = np.asarray(image.convert("RGBA"))[:, :, 3]
    visible = alpha >= threshold
    visited = np.zeros(visible.shape, dtype=bool)
    height, width = visible.shape
    sizes: list[int] = []
    for start_y, start_x in np.argwhere(visible & ~visited):
        if visited[start_y, start_x]:
            continue
        size = 0
        queue: deque[tuple[int, int]] = deque(
            [(int(start_x), int(start_y))]
        )
        visited[start_y, start_x] = True
        while queue:
            x, y = queue.popleft()
            size += 1
            for nx, ny in (
                (x - 1, y),
                (x + 1, y),
                (x, y - 1),
                (x, y + 1),
            ):
                if (
                    0 <= nx < width
                    and 0 <= ny < height
                    and visible[ny, nx]
                    and not visited[ny, nx]
                ):
                    visited[ny, nx] = True
                    queue.append((nx, ny))
        sizes.append(size)
    sizes.sort(reverse=True)
    total = int(sum(sizes))
    return {
        "count": len(sizes),
        "visible_pixels": total,
        "largest_pixels": sizes[0] if sizes else 0,
        "second_pixels": sizes[1] if len(sizes) > 1 else 0,
        "largest_share": (sizes[0] / total) if sizes and total else 0.0,
        "alpha_threshold": threshold,
    }


def fit_canonical(
    keyed: Image.Image,
    canvas_size: tuple[int, int],
    fit_box: tuple[int, int, int, int],
) -> tuple[Image.Image, dict[str, Any]]:
    bbox = alpha_bbox(keyed)
    if bbox is None:
        raise ValueError("candidate has no visible object after chroma key")
    crop = clear_transparent_rgb(keyed.crop(bbox))
    available = (fit_box[2] - fit_box[0], fit_box[3] - fit_box[1])
    ratio = min(available[0] / crop.width, available[1] / crop.height)
    size = (
        max(1, round(crop.width * ratio)),
        max(1, round(crop.height * ratio)),
    )
    resized = clear_transparent_rgb(crop.resize(size, RESAMPLE))
    canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    center = (
        (fit_box[0] + fit_box[2]) // 2,
        (fit_box[1] + fit_box[3]) // 2,
    )
    paste = (center[0] - size[0] // 2, center[1] - size[1] // 2)
    canvas.alpha_composite(resized, paste)
    canvas = clear_transparent_rgb(canvas)
    canvas, cleared_spill = clear_edge_connected_green(canvas)
    fitted_bbox = alpha_bbox(canvas)
    return canvas, {
        "keyed_bbox_exclusive": list(bbox),
        "keyed_visible_size": [bbox[2] - bbox[0], bbox[3] - bbox[1]],
        "keyed_aspect": (bbox[2] - bbox[0]) / (bbox[3] - bbox[1]),
        "fit_scale": ratio,
        "fit_box_exclusive": list(fit_box),
        "fitted_size": list(size),
        "paste_xy": list(paste),
        "canonical_bbox_exclusive": list(fitted_bbox or ()),
        "edge_connected_green_pixels_cleared_after_fit": cleared_spill,
    }


def visible_green_metrics(image: Image.Image) -> dict[str, int]:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8)
    visible = rgba[:, :, 3] > 0
    rgb = rgba[:, :, :3]
    exact = np.all(rgb == GREEN, axis=2) & visible
    r = rgb[:, :, 0].astype(np.int16)
    g = rgb[:, :, 1].astype(np.int16)
    b = rgb[:, :, 2].astype(np.int16)
    dominant = visible & (g - np.maximum(r, b) >= 35)
    return {
        "exact_00ff00": int(exact.sum()),
        "heuristic_green_dominant": int(dominant.sum()),
    }


def region_metrics(
    image: Image.Image, box: tuple[int, int, int, int]
) -> dict[str, Any]:
    rgba = np.asarray(image.crop(box).convert("RGBA"), dtype=np.uint8)
    alpha = rgba[:, :, 3]
    visible = alpha > 0
    rgb = rgba[:, :, :3].astype(np.float32)
    luma = 0.2126 * rgb[:, :, 0] + 0.7152 * rgb[:, :, 1] + 0.0722 * rgb[:, :, 2]
    values = luma[visible]
    return {
        "box": list(box),
        "alpha_coverage": float(visible.mean()),
        "mean_luma": float(values.mean()) if len(values) else 0.0,
        "luma_stddev": float(values.std()) if len(values) else 0.0,
        "luma_p05": float(np.percentile(values, 5)) if len(values) else 0.0,
        "luma_p95": float(np.percentile(values, 95)) if len(values) else 0.0,
    }


def derive_states(normal: Image.Image) -> dict[str, Image.Image]:
    rgba = np.asarray(normal.convert("RGBA"), dtype=np.uint8)
    rgb = rgba[:, :, :3].astype(np.float32)
    alpha = rgba[:, :, 3].copy()

    hover = np.empty_like(rgb)
    hover[:, :, 0] = np.minimum(255, np.rint(1.04 * rgb[:, :, 0] + 4))
    hover[:, :, 1] = np.minimum(255, np.rint(1.03 * rgb[:, :, 1] + 3))
    hover[:, :, 2] = np.minimum(255, np.rint(1.01 * rgb[:, :, 2] + 1))

    pressed = np.empty_like(rgb)
    pressed[:, :, 0] = np.rint(0.82 * rgb[:, :, 0])
    pressed[:, :, 1] = np.rint(0.80 * rgb[:, :, 1])
    pressed[:, :, 2] = np.rint(0.78 * rgb[:, :, 2])

    luma = np.rint(
        0.299 * rgb[:, :, 0]
        + 0.587 * rgb[:, :, 1]
        + 0.114 * rgb[:, :, 2]
    )
    disabled = np.rint(0.30 * rgb + 0.50 * luma[:, :, None])

    outputs: dict[str, Image.Image] = {}
    for name, values in (
        ("normal", rgb),
        ("hover", hover),
        ("pressed", pressed),
        ("disabled", disabled),
    ):
        out = np.dstack((np.clip(values, 0, 255).astype(np.uint8), alpha))
        out[alpha == 0, :3] = 0
        outputs[name] = Image.fromarray(out, "RGBA")
    return outputs


def build_atlas(
    states: dict[str, Image.Image], contract: dict[str, Any]
) -> Image.Image:
    atlas = Image.new("RGBA", tuple(contract["atlas"]["size"]), (0, 0, 0, 0))
    cell_width, _ = contract["atlas"]["cell_size"]
    x0, y0, _, _ = contract["atlas"]["content_xyxy_in_cell"]
    for index, state in enumerate(contract["states"]["order"]):
        atlas.alpha_composite(states[state], (index * cell_width + x0, y0))
    return clear_transparent_rgb(atlas)


def load_font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(
        str(path), size, layout_engine=ImageFont.Layout.BASIC
    )


def draw_icon(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    palette: tuple[tuple[int, int, int, int], ...],
    index: int,
) -> None:
    x0, y0, x1, y1 = box
    draw.rectangle(box, fill=palette[0], outline=(24, 16, 11, 255))
    draw.polygon(
        [
            (x0 + 5, y1 - 6),
            (x0 + 12, y0 + 5),
            (x1 - 5, y0 + 9),
            (x1 - 9, y1 - 5),
        ],
        fill=palette[1],
    )
    if index % 2:
        draw.line((x0 + 7, y1 - 7, x1 - 7, y0 + 7), fill=palette[2], width=3)
    else:
        draw.ellipse((x0 + 9, y0 + 8, x1 - 7, y1 - 8), fill=palette[2])


def reward_boxes(
    contract: dict[str, Any], count: int
) -> list[tuple[int, int, int, int]]:
    layout = contract["layout"]
    x, y = layout["reward_origin"]
    width, height = layout["reward_slot_size"]
    column_gap = layout["reward_column_gap"]
    row_gap = layout["reward_row_gap"]
    return [
        (
            x + (index % 2) * (width + column_gap),
            y + (index // 2) * (height + row_gap),
            x + (index % 2) * (width + column_gap) + width,
            y + (index // 2) * (height + row_gap) + height,
        )
        for index in range(count)
    ]


def draw_runtime_reward(
    image: Image.Image,
    box: tuple[int, int, int, int],
    state: str,
    sprite: Image.Image,
    body_font: ImageFont.FreeTypeFont,
    index: int,
) -> None:
    x0, y0, _, _ = box
    offset = 1 if state == "pressed" else 0
    image.alpha_composite(sprite, (x0 + offset, y0 + offset))
    layer = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer, "RGBA")
    palettes = (
        ((48, 55, 61, 255), (108, 119, 125, 255), (210, 190, 129, 255)),
        ((33, 52, 88, 255), (61, 121, 190, 255), (187, 229, 250, 255)),
        ((67, 39, 29, 255), (145, 88, 42, 255), (223, 176, 87, 255)),
        ((38, 58, 38, 255), (71, 126, 68, 255), (181, 204, 96, 255)),
        ((66, 45, 78, 255), (132, 89, 148, 255), (223, 181, 234, 255)),
        ((71, 38, 32, 255), (151, 65, 50, 255), (236, 160, 103, 255)),
    )
    draw_icon(
        draw,
        (x0 + 4 + offset, y0 + 4 + offset, x0 + 37 + offset, y0 + 37 + offset),
        palettes[index % len(palettes)],
        index,
    )
    names = ("断风者", "舞动之藤", "蛛丝护腕", "黑铁战锤", "秘银护符", "强效药剂")
    qualities = (
        (39, 32, 24, 255),
        (32, 86, 37, 255),
        (32, 64, 132, 255),
        (92, 42, 119, 255),
        (137, 72, 24, 255),
        (52, 49, 45, 255),
    )
    fill = (91, 80, 67, 255) if state == "disabled" else qualities[index]
    draw.text(
        (x0 + 42 + offset, y0 + 21 + offset),
        names[index],
        font=body_font,
        fill=fill,
        anchor="lm",
    )
    counts = (1, 1, 2, 1, 1, 5)
    if counts[index] > 1:
        value = str(counts[index])
        draw.text(
            (x0 + 35 + offset, y0 + 37 + offset),
            value,
            font=body_font,
            fill=(25, 15, 10, 255),
            anchor="rs",
        )
        draw.text(
            (x0 + 34 + offset, y0 + 36 + offset),
            value,
            font=body_font,
            fill=(239, 218, 170, 255),
            anchor="rs",
        )
    image.alpha_composite(layer)


def render_scenario(
    root: Path,
    contract: dict[str, Any],
    states: dict[str, Image.Image],
    count: int,
    output: Path,
) -> tuple[dict[str, bool], list[list[int]]]:
    neighbours = contract["runtime_neighbours"]
    layout = contract["layout"]
    frame_width, frame_height = layout["frame"]
    shell = Image.open(resolve(root, neighbours["quest_log_shell"])).convert("RGBA")
    image = shell.crop((0, 0, frame_width, frame_height))
    title_font = load_font(resolve(root, neighbours["title_font"]), 14)
    body_font = load_font(resolve(root, neighbours["body_font"]), 10)
    draw = ImageDraw.Draw(image, "RGBA")

    draw.text((82, 35), "任务：17/20", font=title_font, fill=(59, 37, 23, 255))
    rows = (
        ("日常任务", True),
        ("[60] 动员号令：地下城清剿", False),
        ("[60+] 黎明先锋（精英）", False),
        ("月语海岸", True),
        ("[55] 扭曲的同胞", False),
        ("[56] 仪式准备", False),
        ("通灵学院", True),
        ("[60+] 烈焰精华（团队）", False),
    )
    row_y = 68
    for text, header in rows:
        if header:
            draw.polygon(
                [(75, row_y + 3), (82, row_y + 7), (75, row_y + 11)],
                fill=(83, 47, 18, 255),
            )
            draw.text((88, row_y), text, font=body_font, fill=(59, 37, 23, 255))
        else:
            draw.text((101, row_y), text, font=body_font, fill=(36, 23, 15, 255))
        row_y += 22 if header else 18

    draw.text((376, 74), "……把蛛卵带回城镇。", font=body_font, fill=(36, 23, 15, 255))
    draw.text((376, 103), "任务奖励", font=title_font, fill=(59, 37, 23, 255))
    if count:
        draw.text((376, 127), "你将得到以下奖励：", font=body_font, fill=(59, 37, 23, 255))
    else:
        draw.text((376, 127), "这项任务没有物品奖励。", font=body_font, fill=(102, 81, 59, 255))

    sequence = ("normal", "hover", "normal", "pressed", "normal", "disabled")
    boxes = reward_boxes(contract, count)
    for index, box in enumerate(boxes):
        state = sequence[index]
        draw_runtime_reward(image, box, state, states[state], body_font, index)

    if boxes:
        money_y = boxes[-1][3] + 8
    else:
        money_y = 169
    draw.text((376, money_y), "奖励金钱：", font=body_font, fill=(59, 37, 23, 255))
    draw.ellipse((438, money_y, 449, money_y + 11), fill=(189, 144, 36, 255), outline=(104, 72, 25, 255))
    draw.text((454, money_y + 1), "8", font=body_font, fill=(36, 23, 15, 255))

    carrier = Image.open(resolve(root, neighbours["seal_carrier"])).convert("RGBA")
    carrier_x, carrier_y, carrier_width, carrier_height = layout["seal_carrier_root"]
    image.alpha_composite(
        carrier.crop((0, 0, carrier_width, carrier_height)),
        (carrier_x, carrier_y),
    )
    seal_atlas = Image.open(resolve(root, neighbours["seal_atlas"])).convert("RGBA")
    seal_x, seal_y, seal_width, seal_height = layout["seal_visual"]
    seal_cell = seal_atlas.crop((0, 0, seal_atlas.width // 4, seal_atlas.height))
    image.alpha_composite(seal_cell.resize((seal_width, seal_height), RESAMPLE), (seal_x, seal_y))

    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, "PNG", optimize=False, compress_level=9)

    content_x, content_y, content_width, content_height = layout["detail_content"]
    checks: dict[str, bool] = {
        f"scenario_{count}_count": len(boxes) == count,
        f"scenario_{count}_frame": image.size == tuple(layout["frame"]),
    }
    for index, box in enumerate(boxes, start=1):
        checks[f"scenario_{count}_reward_{index}_inside_detail"] = (
            box[0] >= content_x
            and box[1] >= content_y
            and box[2] <= content_x + content_width
            and box[3] <= content_y + content_height
        )
    return checks, [list(box) for box in boxes]


def render_layout_board(
    root: Path,
    contract: dict[str, Any],
    states: dict[str, Image.Image],
    output_dir: Path,
    attempt: str,
) -> tuple[Path, dict[str, Any]]:
    frame_width, frame_height = contract["layout"]["frame"]
    gap = 24
    label_height = 34
    board = Image.new(
        "RGBA",
        (frame_width * 2 + gap * 3, (frame_height + label_height) * 3 + gap * 4),
        (29, 23, 19, 255),
    )
    title_font = load_font(
        resolve(root, contract["runtime_neighbours"]["title_font"]), 16
    )
    draw = ImageDraw.Draw(board, "RGBA")
    all_checks: dict[str, bool] = {}
    scenarios: dict[str, Any] = {}
    for index, count in enumerate(contract["layout"]["scenarios"]):
        row, column = divmod(index, 2)
        x = gap + column * (frame_width + gap)
        y = gap + row * (frame_height + label_height + gap)
        scenario_path = output_dir / f"{attempt}.real-layout-{count}-rewards.png"
        checks, boxes = render_scenario(root, contract, states, count, scenario_path)
        scenario = Image.open(scenario_path).convert("RGBA")
        draw.text((x, y), f"真实排版：{count} 件奖励", font=title_font, fill=(220, 190, 139, 255))
        board.alpha_composite(scenario, (x, y + label_height))
        all_checks.update(checks)
        scenarios[str(count)] = {
            "path": display(root, scenario_path),
            "sha256": sha256(scenario_path),
            "frame": list(scenario.size),
            "reward_boxes_xyxy": boxes,
        }
    board_path = output_dir / f"{attempt}.real-layout-board.png"
    board.save(board_path, "PNG", optimize=False, compress_level=9)
    return board_path, {"checks": all_checks, "scenarios": scenarios}


def checkerboard(size: tuple[int, int], cell: int = 16) -> Image.Image:
    image = Image.new("RGBA", size, (225, 221, 212, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], cell):
        for x in range(0, size[0], cell):
            if (x // cell + y // cell) % 2:
                draw.rectangle((x, y, x + cell - 1, y + cell - 1), fill=(174, 166, 151, 255))
    return image


def render_contact_sheet(
    root: Path,
    raw: Image.Image,
    normalized: Image.Image,
    keyed: Image.Image,
    canonical: Image.Image,
    states: dict[str, Image.Image],
    atlas: Image.Image,
    layout_board: Path,
    output: Path,
    attempt: str,
    checks: dict[str, bool],
) -> None:
    sheet = Image.new("RGBA", (1800, 1420), (28, 23, 19, 255))
    draw = ImageDraw.Draw(sheet, "RGBA")
    title_font = load_font(
        resolve(root, "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"), 25
    )
    body_font = load_font(
        resolve(root, "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"), 17
    )
    draw.text((40, 24), f"QL-D V2 {attempt}｜候选审查（未晋级）", font=title_font, fill=(226, 194, 139, 255))
    labels = (
        (40, 76, "provider raw", raw),
        (470, 76, "1024² normalized", normalized),
    )
    for x, y, label, image in labels:
        draw.text((x, y), label, font=body_font, fill=(205, 184, 153, 255))
        sheet.alpha_composite(
            image.convert("RGBA").resize((400, 400), RESAMPLE),
            (x, y + 28),
        )

    draw.text((900, 76), "edge-connected keyed", font=body_font, fill=(205, 184, 153, 255))
    keyed_bg = checkerboard((400, 400))
    keyed_bg.alpha_composite(keyed.resize((400, 400), RESAMPLE))
    sheet.alpha_composite(keyed_bg, (900, 104))

    draw.text((1330, 76), "canonical 1080×410", font=body_font, fill=(205, 184, 153, 255))
    canonical_bg = checkerboard((432, 164), 12)
    canonical_bg.alpha_composite(canonical.resize((432, 164), RESAMPLE))
    sheet.alpha_composite(canonical_bg, (1330, 104))
    draw.rectangle((1346, 120, 1478, 252), outline=(207, 147, 67, 255), width=2)
    draw.rectangle((1494, 120, 1750, 252), outline=(138, 91, 49, 255), width=2)
    draw.text((1330, 282), "橙框 icon-safe；棕框 name-safe（缩放示意）", font=body_font, fill=(181, 154, 116, 255))

    draw.text((40, 540), "108×41 四态（4×最近邻）", font=body_font, fill=(205, 184, 153, 255))
    for index, state in enumerate(("normal", "hover", "pressed", "disabled")):
        x = 40 + index * 440
        draw.text((x, 576), state, font=body_font, fill=(181, 154, 116, 255))
        sheet.alpha_composite(states[state].resize((432, 164), Image.Resampling.NEAREST), (x, 606))

    draw.text((40, 790), "临时 512×64 atlas（2×）", font=body_font, fill=(205, 184, 153, 255))
    sheet.alpha_composite(atlas.resize((1024, 128), Image.Resampling.NEAREST), (40, 824))
    draw.text((1090, 790), "技术门禁", font=body_font, fill=(205, 184, 153, 255))
    check_y = 824
    for name, passed in list(checks.items())[:18]:
        draw.text(
            (1090, check_y),
            f"{'PASS' if passed else 'FAIL'}  {name}",
            font=body_font,
            fill=(146, 190, 112, 255) if passed else (211, 111, 91, 255),
        )
        check_y += 24

    board = Image.open(layout_board).convert("RGBA")
    board.thumbnail((1720, 410), RESAMPLE)
    draw.text((40, 980), "真实当前 UI：0／1／2／4／6 奖励场景缩略", font=body_font, fill=(205, 184, 153, 255))
    sheet.alpha_composite(board, (40, 1014))
    sheet.save(output, "PNG", optimize=False, compress_level=9)


def write_non_square_rejection(
    root: Path,
    raw_path: Path,
    raw: Image.Image,
    output_dir: Path,
    attempt: str,
    repo_commit: str,
    session_id: str,
    reference_checks: dict[str, bool],
    production_path: Path,
) -> int:
    keyed, key_metrics = edge_connected_chroma_key(raw.convert("RGB"))
    bbox = alpha_bbox(keyed)
    aspect = (
        (bbox[2] - bbox[0]) / (bbox[3] - bbox[1]) if bbox else None
    )
    keyed_path = output_dir / f"{attempt}.diagnostic-transparent.png"
    sheet_path = output_dir / f"{attempt}.hard-reject-sheet.png"
    report_path = output_dir / f"{attempt}.review.json"
    keyed.save(keyed_path, "PNG", optimize=False, compress_level=9)

    sheet = Image.new("RGBA", (1320, 700), (28, 23, 19, 255))
    draw = ImageDraw.Draw(sheet, "RGBA")
    title = load_font(
        resolve(
            root,
            "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf",
        ),
        25,
    )
    body = load_font(
        resolve(root, "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"),
        18,
    )
    draw.text(
        (36, 24),
        f"QL-D V2 {attempt}｜硬门禁拒绝：provider 非正方形",
        font=title,
        fill=(226, 194, 139, 255),
    )
    raw_preview = raw.convert("RGBA")
    raw_preview.thumbnail((600, 560), RESAMPLE)
    keyed_preview = checkerboard((600, 560))
    keyed_scaled = keyed.copy()
    keyed_scaled.thumbnail((600, 560), RESAMPLE)
    keyed_preview.alpha_composite(
        keyed_scaled,
        ((600 - keyed_scaled.width) // 2, (560 - keyed_scaled.height) // 2),
    )
    sheet.alpha_composite(raw_preview, (36, 86))
    sheet.alpha_composite(keyed_preview, (684, 86))
    draw.text((36, 654), f"raw {raw.width}×{raw.height}", font=body, fill=(211, 111, 91, 255))
    draw.text(
        (684, 654),
        f"diagnostic bbox {bbox}; aspect {aspect:.4f}" if aspect else "no visible bbox",
        font=body,
        fill=(211, 111, 91, 255),
    )
    sheet.save(sheet_path, "PNG", optimize=False, compress_level=9)
    report = {
        "schema": "aeui.quest-log.reward-slot.candidate-review.v2",
        "batch": "QL-D V2",
        "attempt": attempt,
        "repo_commit_before_generation": repo_commit,
        "fixed_executor_session_id": session_id,
        "raw": {
            "path": display(root, raw_path),
            "sha256": sha256(raw_path),
            "size": list(raw.size),
            "mode": raw.mode,
        },
        "contracts": {
            "production": {
                "path": display(root, production_path),
                "sha256": sha256(production_path),
            }
        },
        "key_metrics": key_metrics,
        "diagnostic_bbox_exclusive": list(bbox or ()),
        "diagnostic_aspect": aspect,
        "technical_checks": {
            **reference_checks,
            "provider_raw_is_square": False,
        },
        "technical_status": "fail",
        "first_technical_failure": "provider_raw_is_square",
        "contract_stop_reason": (
            "Non-square provider output must fail before authorized 1024-square "
            "normalization, bbox-fit, four-state derivation, atlas packing, or "
            "real-layout assembly."
        ),
        "visual_review": {
            "semantic_and_physical": "pending",
            "perspective_and_layers": "pending",
            "art_baseline": "pending",
            "component_and_states": "not-run-after-hard-gate",
            "assembly_and_runtime_legibility": "not-run-after-hard-gate",
        },
        "outputs": {
            "diagnostic_transparent": {
                "path": display(root, keyed_path),
                "sha256": sha256(keyed_path),
            },
            "hard_reject_sheet": {
                "path": display(root, sheet_path),
                "sha256": sha256(sheet_path),
            },
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
    return 1


def build_display_contract(
    root: Path,
    template_path: Path,
    raw_path: Path,
    atlas_path: Path,
    layout: dict[str, Any],
    output: Path,
    attempt: str,
) -> dict[str, Any]:
    contract = json.loads(template_path.read_text(encoding="utf-8"))
    contract["component"] = f"QL-D/QUEST.LOG.REWARD.SLOT/V2/{attempt}"
    contract["evidence"].update(
        {
            "candidate_raw": display(root, raw_path),
            "candidate_atlas": display(root, atlas_path),
            "exact_scenario_previews": layout["scenarios"],
            "attempt": attempt,
        }
    )
    output.write_text(
        json.dumps(contract, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return contract


def main() -> int:
    args = parse_args()
    root = args.repo_root.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    raw_path = args.raw.resolve()
    production_path = resolve(root, args.production_contract)
    display_template_path = resolve(root, args.display_template)
    contract = json.loads(production_path.read_text(encoding="utf-8"))
    if contract.get("version") != "QL-D V2" or not contract["executor"]["authorized"]:
        raise ValueError("QL-D V2 production contract is not authorized")
    reference_checks: dict[str, bool] = {}
    for reference in contract["fixed_references"]:
        path = resolve(root, reference["path"])
        reference_checks[f"image_{reference['image']}_sha256"] = (
            sha256(path) == reference["sha256"]
        )
    if not all(reference_checks.values()):
        raise ValueError("one or more fixed ImageGen reference SHA-256 values changed")

    with Image.open(raw_path) as opened:
        raw = opened.copy()
    if raw.width != raw.height:
        return write_non_square_rejection(
            root,
            raw_path,
            raw,
            output_dir,
            args.attempt,
            args.repo_commit,
            args.session_id,
            reference_checks,
            production_path,
        )
    candidate = contract["candidate"]
    normalized = normalize_square(raw, tuple(candidate["normalized_canvas"]))
    keyed, key_metrics = edge_connected_chroma_key(normalized)
    components = connected_components(keyed)
    keyed_bbox = alpha_bbox(keyed)
    if keyed_bbox is None:
        raise ValueError("candidate has no visible object")
    aspect = (keyed_bbox[2] - keyed_bbox[0]) / (keyed_bbox[3] - keyed_bbox[1])
    aspect_min, aspect_max = candidate["allowed_visible_aspect"]
    canonical, fit_metrics = fit_canonical(
        keyed,
        tuple(candidate["canonical_canvas"]),
        tuple(candidate["canonical_fit_box"]),
    )
    normal = clear_transparent_rgb(
        canonical.resize(tuple(candidate["runtime_size"]), RESAMPLE)
    )
    states = derive_states(normal)
    atlas = build_atlas(states, contract)

    base = args.attempt
    paths = {
        "normalized": output_dir / f"{base}.normalized-1024.png",
        "keyed": output_dir / f"{base}.transparent.png",
        "canonical": output_dir / f"{base}.canonical-review.png",
        "normal": output_dir / f"{base}.runtime-normal-review.png",
        "atlas": output_dir / f"{base}.temporary-state-atlas.png",
        "layout_board": output_dir / f"{base}.real-layout-board.png",
        "contact_sheet": output_dir / f"{base}.contact-sheet.png",
        "display_contract": output_dir / f"{base}.display-region-contract.json",
        "display_report": output_dir / f"{base}.display-region-report.json",
        "report": output_dir / f"{base}.review.json",
    }
    normalized.save(paths["normalized"], "PNG", optimize=False, compress_level=9)
    keyed.save(paths["keyed"], "PNG", optimize=False, compress_level=9)
    canonical.save(paths["canonical"], "PNG", optimize=False, compress_level=9)
    normal.save(paths["normal"], "PNG", optimize=False, compress_level=9)
    atlas.save(paths["atlas"], "PNG", optimize=False, compress_level=9)
    for state, image in states.items():
        image.save(output_dir / f"{base}.runtime-{state}-review.png", "PNG")

    board_path, layout = render_layout_board(root, contract, states, output_dir, base)
    if board_path != paths["layout_board"]:
        raise ValueError("layout board path contract changed")
    display_contract = build_display_contract(
        root,
        display_template_path,
        raw_path,
        paths["atlas"],
        layout,
        paths["display_contract"],
        base,
    )
    validator = load_module(
        root
        / ".codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py",
        "aeui_ql_d_display_validator",
    )
    display_report = validator.validate_contract(display_contract)
    paths["display_report"].write_text(
        json.dumps(display_report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    canonical_bbox = alpha_bbox(canonical)
    canonical_rgba = np.asarray(canonical.convert("RGBA"))
    atlas_rgba = np.asarray(atlas.convert("RGBA"))
    icon_metrics = region_metrics(canonical, tuple(candidate["icon_safe_xyxy"]))
    name_metrics = region_metrics(canonical, tuple(candidate["name_safe_xyxy"]))
    state_alpha = [np.asarray(image.getchannel("A")) for image in states.values()]
    fit_box = candidate["canonical_fit_box"]
    technical_checks = {
        **reference_checks,
        "provider_raw_is_square": raw.width == raw.height,
        "normalized_canvas_is_1024_square": normalized.size == (1024, 1024),
        "keyed_visible_bbox_does_not_touch_canvas": (
            keyed_bbox[0] > 0
            and keyed_bbox[1] > 0
            and keyed_bbox[2] < normalized.width
            and keyed_bbox[3] < normalized.height
        ),
        "keyed_aspect_is_2_58_to_2_69": aspect_min <= aspect <= aspect_max,
        "one_principal_object_share_at_least_99_percent": components["largest_share"] >= 0.99,
        "canonical_canvas_is_1080x410": canonical.size == (1080, 410),
        "canonical_bbox_inside_fit_box": bool(
            canonical_bbox
            and canonical_bbox[0] >= fit_box[0]
            and canonical_bbox[1] >= fit_box[1]
            and canonical_bbox[2] <= fit_box[2]
            and canonical_bbox[3] <= fit_box[3]
        ),
        "canonical_transparent_rgb_zero": bool(
            np.all(canonical_rgba[canonical_rgba[:, :, 3] == 0, :3] == 0)
        ),
        "canonical_visible_green_zero": all(
            value == 0 for value in visible_green_metrics(canonical).values()
        ),
        "icon_safe_region_alpha_coverage_at_least_98_percent": icon_metrics["alpha_coverage"] >= 0.98,
        "name_safe_region_alpha_coverage_at_least_98_percent": name_metrics["alpha_coverage"] >= 0.98,
        "runtime_normal_is_108x41": normal.size == (108, 41),
        "all_four_states_share_exact_alpha": all(
            np.array_equal(state_alpha[0], alpha) for alpha in state_alpha[1:]
        ),
        "temporary_atlas_is_512x64": atlas.size == (512, 64),
        "atlas_transparent_rgb_zero": bool(
            np.all(atlas_rgba[atlas_rgba[:, :, 3] == 0, :3] == 0)
        ),
        "all_real_layout_geometry_checks_pass": all(layout["checks"].values()),
        "display_region_five_of_five_pass": display_report["status"] == "pass",
    }
    raw_request_checks = {
        "raw_canvas_exact_1024x1024": raw.size == (1024, 1024),
        "raw_background_is_single_exact_00ff00": (
            key_metrics["background_unique_rgb"] == 1
            and key_metrics["background_exact_00ff00_ratio"] == 1.0
        ),
        "raw_bbox_matches_requested_target_exactly": list(keyed_bbox)
        == candidate["raw_target_visible_bbox"],
    }
    render_contact_sheet(
        root,
        raw,
        normalized,
        keyed,
        canonical,
        states,
        atlas,
        paths["layout_board"],
        paths["contact_sheet"],
        base,
        technical_checks,
    )
    first_failed = next(
        (name for name, passed in technical_checks.items() if not passed), None
    )
    report = {
        "schema": "aeui.quest-log.reward-slot.candidate-review.v2",
        "batch": "QL-D V2",
        "attempt": base,
        "repo_commit_before_generation": args.repo_commit,
        "fixed_executor_session_id": args.session_id,
        "raw": {
            "path": display(root, raw_path),
            "sha256": sha256(raw_path),
            "size": list(raw.size),
            "mode": raw.mode,
        },
        "contracts": {
            "production": {
                "path": display(root, production_path),
                "sha256": sha256(production_path),
            },
            "display_template": {
                "path": display(root, display_template_path),
                "sha256": sha256(display_template_path),
            },
        },
        "key_metrics": key_metrics,
        "connected_components": components,
        "fit": fit_metrics,
        "icon_safe_metrics": icon_metrics,
        "name_safe_metrics": name_metrics,
        "visible_green": visible_green_metrics(canonical),
        "raw_request_checks": raw_request_checks,
        "raw_request_status": "pass" if all(raw_request_checks.values()) else "diagnostic-fail",
        "technical_checks": technical_checks,
        "technical_checks_passed": sum(technical_checks.values()),
        "technical_checks_total": len(technical_checks),
        "first_technical_failure": first_failed,
        "technical_status": "pass" if first_failed is None else "fail",
        "layout": layout,
        "display_region": display_report,
        "visual_review": {
            "semantic_and_physical": "pending",
            "perspective_and_layers": "pending",
            "art_baseline": "pending",
            "component_and_states": "pending",
            "assembly_and_runtime_legibility": "pending",
        },
        "outputs": {
            name: {
                "path": display(root, path),
                "sha256": sha256(path),
            }
            for name, path in paths.items()
            if name != "report"
        },
        "promotion": {
            "source_written": False,
            "runtime_written": False,
            "addon_changed": False,
        },
    }
    paths["report"].write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if first_failed is None else 1


if __name__ == "__main__":
    raise SystemExit(main())
