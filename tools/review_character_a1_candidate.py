#!/usr/bin/env python3
"""Review and normalize a CHAR-A1 ImageGen candidate.

The script performs only the deterministic operations authorized by CHAR-A1:
edge-connected chroma keying, transparent-RGB clearing, isotropic bbox-fit,
fixed native-coordinate component crops, and a real-layout preview.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from collections import Counter, deque
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from render_character_simulation_v2 import (
    AMMO_RECT,
    BOTTOM_SLOT_X,
    BOTTOM_SLOT_Y,
    CREAM,
    GOLD,
    INK,
    LEFT_SLOT_X,
    MODEL_RECT,
    OUT as SIM_OUT,
    RIGHT_SLOT_X,
    SANS,
    SERIF,
    SLOT_Y,
    STATS_RECT,
    draw_model,
    draw_slot,
    font,
)


ROOT = Path(__file__).resolve().parents[1]
TARGET_SOURCE = (768, 1024)
TARGET_RUNTIME = (384, 512)
RES_RECTS = [(265, 77 + 29 * index, 297, 106 + 29 * index) for index in range(5)]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    digest.update(path.read_bytes())
    return digest.hexdigest()


def distance(a: tuple[int, int, int], b: tuple[int, int, int]) -> float:
    return math.sqrt(sum((a[index] - b[index]) ** 2 for index in range(3)))


def estimate_key(image: Image.Image, border_width: int = 8) -> tuple[tuple[int, int, int], float]:
    rgb = image.convert("RGB")
    width, height = rgb.size
    pixels: list[tuple[int, int, int]] = []
    for y in range(height):
        for x in range(width):
            if x < border_width or x >= width - border_width or y < border_width or y >= height - border_width:
                pixels.append(rgb.getpixel((x, y)))
    quantized = Counter(tuple(channel // 12 for channel in pixel) for pixel in pixels)
    modal, _ = quantized.most_common(1)[0]
    modal_pixels = [pixel for pixel in pixels if tuple(channel // 12 for channel in pixel) == modal]
    key = tuple(sorted(pixel[channel] for pixel in modal_pixels)[len(modal_pixels) // 2] for channel in range(3))
    flat_ratio = sum(distance(pixel, key) <= 28 for pixel in pixels) / len(pixels)
    return key, flat_ratio


def edge_connected_background(image: Image.Image, key: tuple[int, int, int], tolerance: float = 58) -> Image.Image:
    rgb = image.convert("RGB")
    width, height = rgb.size
    mask = Image.new("1", (width, height), 0)
    mask_pixels = mask.load()
    source = rgb.load()
    queue: deque[tuple[int, int]] = deque()

    def enqueue(x: int, y: int) -> None:
        if mask_pixels[x, y] or distance(source[x, y], key) > tolerance:
            return
        mask_pixels[x, y] = 1
        queue.append((x, y))

    for x in range(width):
        enqueue(x, 0)
        enqueue(x, height - 1)
    for y in range(height):
        enqueue(0, y)
        enqueue(width - 1, y)

    while queue:
        x, y = queue.popleft()
        if x > 0:
            enqueue(x - 1, y)
        if x + 1 < width:
            enqueue(x + 1, y)
        if y > 0:
            enqueue(x, y - 1)
        if y + 1 < height:
            enqueue(x, y + 1)
    return mask


def key_candidate(image: Image.Image) -> tuple[Image.Image, dict[str, object]]:
    rgb = image.convert("RGB")
    key, flat_ratio = estimate_key(rgb)
    bg = edge_connected_background(rgb, key)
    foreground = bg.point(lambda value: 0 if value else 255, mode="L")
    bbox = foreground.getbbox()
    keyed = rgb.convert("RGBA")
    keyed.putalpha(foreground)
    cleared = Image.new("RGBA", keyed.size, (0, 0, 0, 0))
    cleared.alpha_composite(keyed)

    width, height = rgb.size
    aspect = 0.0
    margins = [0, 0, 0, 0]
    if bbox:
        aspect = (bbox[2] - bbox[0]) / (bbox[3] - bbox[1])
        margins = [bbox[0], bbox[1], width - bbox[2], height - bbox[3]]
    saturation = max(key) - min(key)
    metrics: dict[str, object] = {
        "input_size": list(rgb.size),
        "key_rgb": list(key),
        "key_saturation": saturation,
        "border_flat_ratio": round(flat_ratio, 6),
        "foreground_bbox": list(bbox) if bbox else None,
        "foreground_aspect": round(aspect, 6),
        "aspect_relative_error": round(abs(aspect / 0.75 - 1.0), 6) if aspect else None,
        "margins": margins,
    }
    return cleared, metrics


def normalize(keyed: Image.Image, bbox: tuple[int, int, int, int]) -> Image.Image:
    crop = keyed.crop(bbox)
    scale = min(TARGET_SOURCE[0] / crop.width, TARGET_SOURCE[1] / crop.height)
    resized = crop.resize((max(1, round(crop.width * scale)), max(1, round(crop.height * scale))), Image.Resampling.LANCZOS)
    normalized = Image.new("RGBA", TARGET_SOURCE, (0, 0, 0, 0))
    normalized.alpha_composite(resized, ((TARGET_SOURCE[0] - resized.width) // 2, (TARGET_SOURCE[1] - resized.height) // 2))
    return normalized


def clear_rect(image: Image.Image, box: tuple[int, int, int, int]) -> None:
    ImageDraw.Draw(image).rectangle(box, fill=(0, 0, 0, 0))


def split_components(runtime: Image.Image, output: Path) -> dict[str, Path]:
    parts_dir = output / "parts"
    parts_dir.mkdir(parents=True, exist_ok=True)
    shell = runtime.copy()
    clear_rect(shell, MODEL_RECT)
    clear_rect(shell, STATS_RECT)
    for rect in RES_RECTS:
        clear_rect(shell, rect)

    model = runtime.crop(MODEL_RECT)
    for rect in RES_RECTS:
        local = (rect[0] - MODEL_RECT[0], rect[1] - MODEL_RECT[1], rect[2] - MODEL_RECT[0], rect[3] - MODEL_RECT[1])
        clear_rect(model, local)
    stats = runtime.crop(STATS_RECT)

    paths = {
        "shell": parts_dir / "CharacterFrameShellV1.preview.png",
        "model": parts_dir / "CharacterModelBackgroundV1.preview.png",
        "stats": parts_dir / "CharacterStatsPaperV1.preview.png",
    }
    shell.save(paths["shell"], compress_level=9)
    model.save(paths["model"], compress_level=9)
    stats.save(paths["stats"], compress_level=9)
    for index, rect in enumerate(RES_RECTS, start=1):
        path = parts_dir / f"CharacterResistanceWell{index}V1.preview.png"
        runtime.crop(rect).save(path, compress_level=9)
        paths[f"resistance_{index}"] = path
    return paths


def overlay_dynamic(runtime: Image.Image) -> Image.Image:
    preview = runtime.copy()
    draw = ImageDraw.Draw(preview)
    draw_model(draw, 1)

    for index, y in enumerate(SLOT_Y):
        draw_slot(preview, LEFT_SLOT_X, y, 1, index, empty=index in {1, 5})
        draw_slot(preview, RIGHT_SLOT_X, y, 1, index + 8, state="broken" if index == 7 else "normal")
    for index, x in enumerate(BOTTOM_SLOT_X):
        draw_slot(preview, x, BOTTOM_SLOT_Y, 1, index + 16, state="hover" if index == 0 else "normal")

    # Dynamic Ammo content; A1 owns neither the well nor the count.
    ax1, ay1, ax2, ay2 = AMMO_RECT
    draw.ellipse((ax1, ay1, ax2, ay2), fill=(38, 31, 23, 255), outline=(89, 67, 37, 255), width=1)
    draw.line((ax1 + 8, ay2 - 6, ax2 - 5, ay1 + 5), fill=(163, 129, 71, 255), width=2)
    draw.text((ax2 - 1, ay2 - 1), "847", font=font(SANS, 5), fill=CREAM, anchor="rb")

    draw.text((198, 18), "伊瑟拉的旅人", font=font(SERIF, 11), fill=CREAM, anchor="mm")
    draw.text((198, 36), "60级  暗夜精灵  法师", font=font(SANS, 7), fill=(184, 155, 103, 255), anchor="mm")

    left_stats = [("力量", "29"), ("敏捷", "33"), ("耐力", "226"), ("智力", "353"), ("精神", "294")]
    right_stats = [("护甲", "895"), ("攻击强度", "118"), ("法术强度", "214"), ("爆击", "7.8%"), ("命中", "3%")]
    draw.text((73, 297), "主属性", font=font(SERIF, 7), fill=INK)
    draw.text((187, 297), "战斗属性", font=font(SERIF, 7), fill=INK)
    for index, ((label_l, value_l), (label_r, value_r)) in enumerate(zip(left_stats, right_stats)):
        y = 311 + index * 11
        draw.text((74, y), label_l, font=font(SANS, 6), fill=(59, 40, 24, 255), anchor="lm")
        draw.text((174, y), value_l, font=font(SANS, 6), fill=(37, 80, 39, 255), anchor="rm")
        draw.text((188, y), label_r, font=font(SANS, 6), fill=(59, 40, 24, 255), anchor="lm")
        draw.text((290, y), value_r, font=font(SANS, 6), fill=(37, 80, 39, 255), anchor="rm")

    res_colors = [(92, 104, 117, 255), (91, 106, 76, 255), (112, 84, 70, 255), (102, 89, 120, 255), (107, 100, 68, 255)]
    for index, color in enumerate(res_colors):
        y = 77 + 29 * index
        draw.ellipse((271, y + 4, 289, y + 22), fill=color)
        draw.text((280, y + 23), str(15 + index * 5), font=font(SANS, 5), fill=CREAM, anchor="ms")

    # Controls remain separate mock objects.
    for x, glyph in ((70, "‹"), (91, "›")):
        draw.ellipse((x, 80, x + 18, 98), fill=(50, 37, 25, 230), outline=(82, 61, 35, 255), width=1)
        draw.text((x + 9, 88), glyph, font=font(SERIF, 11), fill=CREAM, anchor="mm")
    draw.ellipse((327, 13, 351, 37), fill=(64, 46, 29, 255), outline=(116, 89, 45, 255), width=1)
    draw.line((335, 21, 343, 29), fill=CREAM, width=1)
    draw.line((343, 21, 335, 29), fill=CREAM, width=1)

    labels = ["角色", "声望", "技能", "PVP"]
    x = 15
    tab_w = 86
    for index, label in enumerate(labels):
        y = 430 if index == 0 else 433
        points = [(x, y + 4), (x + 7, y), (x + tab_w - 6, y + 1), (x + tab_w, y + 6), (x + tab_w - 3, y + 27), (x + 4, y + 27)]
        draw.polygon(points, fill=(103, 64, 37, 255) if index == 0 else (52, 36, 25, 255), outline=(75, 55, 31, 255))
        draw.text((x + tab_w // 2, y + 14), label, font=font(SERIF, 7), fill=GOLD if index == 0 else CREAM, anchor="mm")
        x += tab_w - 5
    return preview


def checkerboard(size: tuple[int, int], cell: int = 16) -> Image.Image:
    image = Image.new("RGBA", size, (42, 42, 42, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], cell):
        for x in range(0, size[0], cell):
            if (x // cell + y // cell) % 2:
                draw.rectangle((x, y, x + cell - 1, y + cell - 1), fill=(58, 58, 58, 255))
    return image


def contain(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    copy = image.copy()
    copy.thumbnail(size, Image.Resampling.LANCZOS)
    result = checkerboard(size)
    result.alpha_composite(copy, ((size[0] - copy.width) // 2, (size[1] - copy.height) // 2))
    return result


def review_board(original: Image.Image, keyed: Image.Image, runtime: Image.Image, real: Image.Image, metrics: dict[str, object], output: Path) -> Path:
    board = Image.new("RGBA", (1920, 1200), (24, 23, 21, 255))
    draw = ImageDraw.Draw(board)
    draw.text((44, 30), "CHAR-A1 · deterministic review", font=font(SERIF, 32), fill=CREAM)
    draw.text((44, 78), "Original / keyed alpha / native static / real dynamic layout", font=font(SANS, 17), fill=(178, 160, 128, 255))

    panels = [
        ("ImageGen 1024²", contain(original.convert("RGBA"), (430, 430)), (40, 120)),
        ("Edge-connected key", contain(keyed, (430, 430)), (490, 120)),
        ("Static 384×512", contain(runtime, (384, 512)), (960, 120)),
        ("Real layout @ 150%", real.resize((576, 768), Image.Resampling.NEAREST), (1320, 120)),
    ]
    for label, image, origin in panels:
        board.alpha_composite(image, origin)
        draw.text((origin[0], origin[1] - 27), label, font=font(SANS, 16), fill=GOLD)

    checks = metrics["checks"]
    draw.rounded_rectangle((40, 600, 920, 1115), radius=8, fill=(35, 31, 27, 245), outline=(83, 63, 39, 255), width=2)
    draw.text((66, 624), "Technical contract", font=font(SERIF, 24), fill=CREAM)
    rows = [
        ("input 1024²", checks["input_1024_square"]),
        ("flat saturated edge key", checks["flat_saturated_key"]),
        ("subject clear of canvas edge", checks["subject_has_margin"]),
        ("bbox aspect 0.75 ±1%", checks["bbox_aspect_pass"]),
    ]
    for index, (label, passed) in enumerate(rows):
        color = (104, 170, 96, 255) if passed else (202, 88, 67, 255)
        draw.text((70, 675 + index * 38), "PASS" if passed else "FAIL", font=font(SANS, 16), fill=color)
        draw.text((140, 675 + index * 38), label, font=font(SANS, 16), fill=(205, 190, 160, 255))
    details = [
        f"key RGB: {metrics['key_rgb']}",
        f"border flat ratio: {metrics['border_flat_ratio']}",
        f"bbox: {metrics['foreground_bbox']}",
        f"aspect: {metrics['foreground_aspect']}",
        f"relative error: {metrics['aspect_relative_error']}",
        f"margins: {metrics['margins']}",
        f"technical pass: {metrics['technical_pass']}",
    ]
    for index, line in enumerate(details):
        draw.text((70, 850 + index * 30), line, font=font(SANS, 15), fill=(173, 156, 126, 255))

    draw.rounded_rectangle((960, 930, 1895, 1115), radius=8, fill=(35, 31, 27, 245), outline=(83, 63, 39, 255), width=2)
    draw.text((988, 954), "Visual review gates", font=font(SERIF, 23), fill=CREAM)
    gates = [
        "No portrait / race / class icon or empty medallion at top-left",
        "No baked model, item icons, text, tabs, close or rotate buttons",
        "Rough hand-painted leather; asymmetric wear; no industrial symmetry",
        "Quiet model field and continuous stats parchment fit native content",
    ]
    for index, line in enumerate(gates):
        draw.text((990, 998 + index * 27), f"• {line}", font=font(SANS, 15), fill=(195, 178, 145, 255))
    path = output / "review-board.png"
    board.convert("RGB").save(path, compress_level=9)
    return path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--attempt", required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)

    original = Image.open(args.candidate).convert("RGB")
    keyed, metrics = key_candidate(original)
    bbox_list = metrics["foreground_bbox"]
    if not bbox_list:
        raise SystemExit("No foreground subject detected")
    bbox = tuple(int(value) for value in bbox_list)
    normalized = normalize(keyed, bbox)
    runtime = normalized.resize(TARGET_RUNTIME, Image.Resampling.LANCZOS)
    clear = Image.new("RGBA", runtime.size, (0, 0, 0, 0))
    clear.alpha_composite(runtime)
    runtime = clear

    keyed_path = args.output / "candidate-keyed.png"
    normalized_path = args.output / "candidate-normalized-768x1024.png"
    runtime_path = args.output / "candidate-runtime-384x512.png"
    real_path = args.output / "real-layout-384x512.png"
    keyed.save(keyed_path, compress_level=9)
    normalized.save(normalized_path, compress_level=9)
    runtime.save(runtime_path, compress_level=9)
    real = overlay_dynamic(runtime)
    real.save(real_path, compress_level=9)
    parts = split_components(runtime, args.output)

    aspect = float(metrics["foreground_aspect"])
    margins = list(metrics["margins"])
    checks = {
        "input_1024_square": original.size == (1024, 1024),
        "flat_saturated_key": float(metrics["border_flat_ratio"]) >= 0.92 and int(metrics["key_saturation"]) >= 80,
        "subject_has_margin": min(margins) >= 8,
        "bbox_aspect_pass": abs(aspect / 0.75 - 1.0) <= 0.01,
    }
    metrics["checks"] = checks
    metrics["technical_pass"] = all(checks.values())
    metrics["attempt"] = args.attempt
    metrics["candidate"] = str(args.candidate)
    metrics["candidate_sha256"] = sha256(args.candidate)
    metrics["outputs"] = {
        "keyed": str(keyed_path),
        "normalized": str(normalized_path),
        "runtime": str(runtime_path),
        "real_layout": str(real_path),
        "parts": {name: str(path) for name, path in parts.items()},
    }
    board_path = review_board(original, keyed, runtime, real, metrics, args.output)
    metrics["outputs"]["review_board"] = str(board_path)
    metrics_path = args.output / "review.json"
    metrics_path.write_text(json.dumps(metrics, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(metrics, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
