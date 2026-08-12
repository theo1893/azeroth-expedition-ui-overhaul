#!/usr/bin/env python3
"""Deterministically review UF-PRIMARY V3 complete-shell candidates.

This tool creates review-only artifacts under an ignored attempt directory.  It
never promotes a failed image to source/runtime media and it never repairs
visible shell anatomy.  A normalized candidate is emitted only when every
objective shell gate passes.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
CANVAS = (1536, 1024)
NORMALIZED = (1284, 252)
RUNTIME = (214, 42)
TARGET_RATIO = RUNTIME[0] / RUNTIME[1]
SOURCE_SAFE = (42, 36, 1242, 216)
SOURCE_SAFE_CORE = (48, 42, 1236, 210)
RUNTIME_SAFE = (7, 6, 207, 36)
MIN_ISOLATION = 80
MAX_RATIO_ERROR = 8.0
MAX_ANISOTROPY = 8.0
MIN_LARGE_OPENING_AREA = 10_000
MIN_PHYSICAL_COMPONENT_AREA = 256
FONT = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"
TITLE_FONT = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"
CHAT_SOURCE = ROOT / "assets/source/chat/frame-full-v1/ChatBookFrame_Full_V1_r1.png"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--segment", choices=("A", "B"), required=True)
    parser.add_argument("--raw", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=False, compress_level=9)


def font(size: int, title: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(TITLE_FONT if title else FONT), size)


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def chroma_mask(raw: Image.Image) -> np.ndarray:
    rgb = np.asarray(raw.convert("RGB"), dtype=np.int16)
    red, green, blue = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
    return (green >= 95) & ((green - np.maximum(red, blue)) >= 28)


def bbox_from_mask(mask: np.ndarray) -> tuple[int, int, int, int] | None:
    ys, xs = np.where(mask)
    if not len(xs):
        return None
    return int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)


def connected_component_stats(mask: np.ndarray) -> list[dict[str, Any]]:
    """Label an 8-connected boolean mask with a scanline run union-find.

    The provider image can contain thousands of one-pixel painterly flecks.  A
    repeated full-canvas flood is quadratic in that case; scanline runs keep the
    check effectively linear while retaining exact areas and bboxes.
    """
    height, width = mask.shape
    parent: list[int] = []
    area: list[int] = []
    min_x: list[int] = []
    min_y: list[int] = []
    max_x: list[int] = []
    max_y: list[int] = []
    touches_edge: list[bool] = []
    contains_center: list[bool] = []

    def find(label: int) -> int:
        while parent[label] != label:
            parent[label] = parent[parent[label]]
            label = parent[label]
        return label

    def union(first: int, second: int) -> int:
        root_a, root_b = find(first), find(second)
        if root_a == root_b:
            return root_a
        if area[root_a] < area[root_b]:
            root_a, root_b = root_b, root_a
        parent[root_b] = root_a
        area[root_a] += area[root_b]
        min_x[root_a] = min(min_x[root_a], min_x[root_b])
        min_y[root_a] = min(min_y[root_a], min_y[root_b])
        max_x[root_a] = max(max_x[root_a], max_x[root_b])
        max_y[root_a] = max(max_y[root_a], max_y[root_b])
        touches_edge[root_a] = touches_edge[root_a] or touches_edge[root_b]
        contains_center[root_a] = contains_center[root_a] or contains_center[root_b]
        return root_a

    previous: list[tuple[int, int, int]] = []
    centre_x, centre_y = width // 2, height // 2
    for y in range(height):
        row = mask[y]
        padded = np.concatenate((np.array([False]), row, np.array([False])))
        changes = np.diff(padded.astype(np.int8))
        starts = np.flatnonzero(changes == 1)
        ends = np.flatnonzero(changes == -1)
        current: list[tuple[int, int, int]] = []
        previous_cursor = 0
        for start_raw, end_raw in zip(starts, ends):
            start, end = int(start_raw), int(end_raw)
            label = len(parent)
            parent.append(label)
            area.append(end - start)
            min_x.append(start)
            min_y.append(y)
            max_x.append(end)
            max_y.append(y + 1)
            touches_edge.append(y in (0, height - 1) or start == 0 or end == width)
            contains_center.append(y == centre_y and start <= centre_x < end)

            while previous_cursor < len(previous) and previous[previous_cursor][1] < start - 1:
                previous_cursor += 1
            probe = previous_cursor
            while probe < len(previous) and previous[probe][0] <= end:
                prev_start, prev_end, prev_label = previous[probe]
                if prev_end >= start - 1 and prev_start <= end:
                    label = union(label, prev_label)
                probe += 1
            current.append((start, end, label))
        previous = current

    components: list[dict[str, Any]] = []
    for label in range(len(parent)):
        if find(label) != label:
            continue
        components.append({
            "area": area[label],
            "bbox_exclusive": [min_x[label], min_y[label], max_x[label], max_y[label]],
            "touches_canvas_edge": touches_edge[label],
            "contains_canvas_center": contains_center[label],
        })
    components.sort(key=lambda item: item["area"], reverse=True)
    for index, item in enumerate(components, start=1):
        item["index"] = index
    return components


def keyed_material(raw: Image.Image, green: np.ndarray) -> Image.Image:
    rgb = np.asarray(raw.convert("RGB")).copy()
    alpha = np.where(green, 0, 255).astype(np.uint8)
    removed = Image.fromarray((green * 255).astype(np.uint8), "L")
    ring = np.asarray(removed.filter(ImageFilter.MaxFilter(3))) > 0
    ring &= ~green
    rgb[:, :, 1][ring] = np.minimum(
        rgb[:, :, 1][ring],
        np.maximum(rgb[:, :, 0][ring], rgb[:, :, 2][ring]),
    )
    rgb[alpha == 0] = 0
    return clear_transparent_rgb(Image.fromarray(np.dstack((rgb, alpha)), "RGBA"))


def normalize_shell(keyed: Image.Image, bbox: tuple[int, int, int, int]) -> Image.Image:
    crop = clear_transparent_rgb(keyed.crop(bbox))
    return clear_transparent_rgb(crop.resize(NORMALIZED, Image.Resampling.LANCZOS))


def checkerboard(size: tuple[int, int], step: int = 12) -> Image.Image:
    image = Image.new("RGBA", size, (58, 55, 50, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], step):
        for x in range(0, size[0], step):
            if (x // step + y // step) % 2:
                draw.rectangle((x, y, x + step - 1, y + step - 1), fill=(86, 81, 73, 255))
    return image


def runtime_shell(normalized: Image.Image, clear_safe: bool) -> Image.Image:
    result = clear_transparent_rgb(normalized.resize(RUNTIME, Image.Resampling.LANCZOS))
    if clear_safe:
        array = np.asarray(result).copy()
        x0, y0, x1, y1 = RUNTIME_SAFE
        array[y0:y1, x0:x1] = 0
        result = Image.fromarray(array, "RGBA")
    return clear_transparent_rgb(result)


def derive_width(shell: Image.Image, content_width: int) -> Image.Image:
    left = shell.crop((0, 0, 7, 42))
    centre = shell.crop((7, 0, 207, 42)).resize((content_width, 42), Image.Resampling.LANCZOS)
    right = shell.crop((207, 0, 214, 42))
    result = Image.new("RGBA", (content_width + 14, 42), (0, 0, 0, 0))
    result.alpha_composite(centre, (7, 0))
    result.alpha_composite(left, (0, 0))
    result.alpha_composite(right, (content_width + 7, 0))
    return clear_transparent_rgb(result)


def draw_bar_frame(
    scene: Image.Image,
    shell: Image.Image,
    x: int,
    y: int,
    content_width: int,
    name: str,
    power: tuple[int, int, int],
    health: tuple[int, int, int],
    health_fraction: float,
) -> None:
    draw = ImageDraw.Draw(scene, "RGBA")
    actual_shell = shell if content_width == 200 else derive_width(shell, content_width)
    draw.rectangle((x + 7, y + 6, x + 7 + content_width, y + 31), fill=(27, 18, 14, 255))
    draw.rectangle(
        (x + 7, y + 6, x + 7 + round(content_width * health_fraction), y + 31),
        fill=health + (255,),
    )
    draw.line((x + 9, y + 9, x + 5 + round(content_width * health_fraction), y + 9), fill=(201, 188, 147, 68), width=1)
    draw.rectangle((x + 7, y + 32, x + 7 + content_width, y + 36), fill=(22, 16, 13, 255))
    draw.rectangle((x + 7, y + 32, x + 7 + round(content_width * 0.72), y + 36), fill=power + (255,))
    scene.alpha_composite(actual_shell, (x, y))
    body = font(11)
    draw.text((x + 12, y + 19), name, font=body, fill=(239, 224, 187, 255), anchor="lm")
    draw.text((x + 7 + content_width - 5, y + 19), f"{round(health_fraction * 100)}%", font=body, fill=(241, 228, 194, 255), anchor="rm")


def render_real_layout(normalized: Image.Image, output: Path, segment: str, technical_pass: bool) -> None:
    shell = runtime_shell(normalized, clear_safe=technical_pass)
    scene = Image.new("RGBA", (1600, 900), (14, 17, 19, 255))
    draw = ImageDraw.Draw(scene, "RGBA")
    for y in range(88, 760, 50):
        offset = 46 if (y // 50) % 2 else 0
        for x in range(-40 + offset, 1600, 100):
            draw.polygon([(x, y + 4), (x + 91, y), (x + 96, y + 43), (x + 3, y + 47)], fill=(25, 28, 28, 255), outline=(38, 37, 33, 255))
    draw.rectangle((0, 0, 1600, 82), fill=(18, 16, 14, 248))
    draw.text((34, 18), f"UF-A1 V3-{segment} candidate · real 100% layout", font=font(24, True), fill=(224, 193, 132, 255))
    verdict = "all deterministic gates pass" if technical_pass else "diagnostic only — failed anatomy remains visible"
    draw.text((36, 54), verdict, font=font(13), fill=(190, 171, 142, 255))

    cases = [
        ("Mana", (47, 86, 155), 200, 0.91),
        ("Rage", (145, 42, 34), 200, 0.78),
        ("Focus", (154, 92, 34), 200, 0.66),
        ("Energy", (166, 151, 38), 200, 0.84),
        ("W=160", (47, 86, 155), 160, 0.59),
        ("W=240", (87, 49, 116), 240, 0.73),
    ]
    positions = [(55, 130), (55, 238), (55, 346), (55, 454), (470, 150), (470, 290)]
    health_colours = [(64, 125, 55), (69, 128, 57), (135, 51, 42), (69, 126, 55), (75, 126, 58), (135, 49, 42)]
    for index, ((label, power, width, fraction), (x, y)) in enumerate(zip(cases, positions)):
        draw.text((x, y - 24), f"{index + 1}. {label}", font=font(13), fill=(203, 189, 158, 255))
        draw_bar_frame(scene, shell, x, y, width, "远征者 60" if index < 4 else "缩放实例", power, health_colours[index], fraction)

    draw.text((890, 112), "4× nearest-neighbour inspection", font=font(15, True), fill=(211, 187, 137, 255))
    zoom = shell.resize((shell.width * 4, shell.height * 4), Image.Resampling.NEAREST)
    board = checkerboard(zoom.size, 16)
    board.alpha_composite(zoom)
    scene.alpha_composite(board, (890, 145))

    if CHAT_SOURCE.exists():
        chat = Image.open(CHAT_SOURCE).convert("RGBA")
        chat.thumbnail((355, 225), Image.Resampling.LANCZOS)
        scene.alpha_composite(chat, (22, 650))
    for index in range(12):
        ax = 516 + index * 43
        draw.rectangle((ax, 822, ax + 38, 860), fill=(43, 34, 25, 255), outline=(111, 82, 43, 255), width=2)
        draw.rectangle((ax + 5, 827, ax + 33, 855), fill=((44 + index * 11) % 120, 49, 74, 255))
    draw.polygon([(464, 860), (495, 822), (508, 843), (494, 881)], fill=(92, 68, 37, 255), outline=(131, 95, 46, 255))
    draw.polygon([(1030, 843), (1044, 822), (1076, 860), (1044, 881)], fill=(92, 68, 37, 255), outline=(131, 95, 46, 255))
    draw.text((1130, 838), "Current Chat source; action bar remains an explicit fallback", font=font(12), fill=(161, 149, 130, 255))
    save_png(scene, output)


def render_technical(
    raw: Image.Image,
    bbox: tuple[int, int, int, int],
    enclosed: list[dict[str, Any]],
    normalized: Image.Image,
    metrics: dict[str, Any],
    output: Path,
) -> None:
    annotated = raw.convert("RGBA")
    overlay = Image.new("RGBA", raw.size, (0, 0, 0, 0))
    odraw = ImageDraw.Draw(overlay, "RGBA")
    colours = [(211, 57, 48, 105), (55, 125, 220, 105), (220, 154, 48, 105), (150, 67, 186, 105)]
    for index, item in enumerate(enclosed):
        if not item["large_semantic_opening"]:
            continue
        x0, y0, x1, y1 = item["bbox_exclusive"]
        odraw.rectangle((x0, y0, x1 - 1, y1 - 1), fill=colours[index % len(colours)], outline=colours[index % len(colours)][:3] + (255,), width=5)
    odraw.rectangle((bbox[0], bbox[1], bbox[2] - 1, bbox[3] - 1), outline=(255, 232, 117, 255), width=5)
    annotated = Image.alpha_composite(annotated, overlay)
    annotated.thumbnail((850, 565), Image.Resampling.LANCZOS)

    board = Image.new("RGBA", (1500, 980), (25, 22, 19, 255))
    draw = ImageDraw.Draw(board, "RGBA")
    draw.text((28, 18), "UF-PRIMARY V3 deterministic shell review", font=font(25, True), fill=(226, 196, 137, 255))
    draw.text((30, 58), "Yellow = outer bbox; coloured boxes = enclosed green components", font=font(13), fill=(183, 169, 143, 255))
    board.alpha_composite(annotated, (28, 90))

    lines = [
        f"technical pass: {metrics['overall_technical_pass']}",
        f"first failure: {metrics['first_failure'] or 'none'}",
        f"large openings: {metrics['large_opening_count']} (required exactly 1)",
        f"physical material components: {metrics['major_physical_component_count']} (required 1)",
        f"bbox: {metrics['bbox_size'][0]} × {metrics['bbox_size'][1]}",
        f"ratio error: {metrics['ratio_error_percent']:.3f}% (max {MAX_RATIO_ERROR:.1f}%)",
        f"anisotropy: {metrics['anisotropy_percent']:.3f}% (max {MAX_ANISOTROPY:.1f}%)",
        f"safe-core alpha>=128: {metrics['safe_core_alpha_pixels']} (required 0)",
        f"isolation L/T/R/B: {metrics['isolation_margins']}",
    ]
    for index, line in enumerate(lines):
        colour = (221, 105, 85, 255) if index < 2 and not metrics["overall_technical_pass"] else (216, 204, 177, 255)
        draw.text((925, 105 + index * 36), line, font=font(14), fill=colour)

    preview = checkerboard((1284, 252), 14)
    preview.alpha_composite(normalized)
    safe_draw = ImageDraw.Draw(preview, "RGBA")
    safe_draw.rectangle((SOURCE_SAFE[0], SOURCE_SAFE[1], SOURCE_SAFE[2] - 1, SOURCE_SAFE[3] - 1), outline=(227, 176, 62, 210), width=3)
    safe_draw.rectangle((SOURCE_SAFE_CORE[0], SOURCE_SAFE_CORE[1], SOURCE_SAFE_CORE[2] - 1, SOURCE_SAFE_CORE[3] - 1), outline=(221, 68, 61, 230), width=2)
    board.alpha_composite(preview, (28, 690))
    draw.text((30, 950), "Normalized diagnostic 1284×252 · amber safe boundary · red hard core", font=font(12), fill=(182, 168, 142, 255))
    save_png(board, output)


def main() -> None:
    args = parse_args()
    raw_path = args.raw.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    raw = Image.open(raw_path)
    if raw.size != CANVAS:
        raise ValueError(f"expected {CANVAS}, got {raw.size}")

    green = chroma_mask(raw)
    green_components = connected_component_stats(green)
    edge_green_components = [item for item in green_components if item["touches_canvas_edge"]]
    enclosed = [dict(item) for item in green_components if not item["touches_canvas_edge"]]
    for item in enclosed:
        item["large_semantic_opening"] = item["area"] >= MIN_LARGE_OPENING_AREA
    large_openings = [item for item in enclosed if item["large_semantic_opening"]]

    material = ~green
    material_components = connected_component_stats(material)
    material_sizes = [item["area"] for item in material_components]
    major_material = [item for item in material_components if item["area"] >= MIN_PHYSICAL_COMPONENT_AREA]
    bbox = bbox_from_mask(material)
    if bbox is None:
        raise ValueError("no shell material found")
    bbox_width, bbox_height = bbox[2] - bbox[0], bbox[3] - bbox[1]
    source_ratio = bbox_width / bbox_height
    ratio_error = abs(source_ratio - TARGET_RATIO) / TARGET_RATIO * 100.0
    sx, sy = NORMALIZED[0] / bbox_width, NORMALIZED[1] / bbox_height
    anisotropy = abs(sx - sy) / max(sx, sy) * 100.0
    isolation = {
        "left": bbox[0],
        "top": bbox[1],
        "right": CANVAS[0] - bbox[2],
        "bottom": CANVAS[1] - bbox[3],
    }

    keyed = keyed_material(raw, green)
    normalized = normalize_shell(keyed, bbox)
    normalized_array = np.asarray(normalized)
    x0, y0, x1, y1 = SOURCE_SAFE
    cx0, cy0, cx1, cy1 = SOURCE_SAFE_CORE
    safe_alpha = normalized_array[y0:y1, x0:x1, 3]
    safe_core_alpha = normalized_array[cy0:cy1, cx0:cx1, 3]
    safe_alpha_pixels = int((safe_alpha >= 128).sum())
    safe_core_alpha_pixels = int((safe_core_alpha >= 128).sum())

    checks = [
        ("one-connected-opening", len(large_openings) == 1 and large_openings[0]["contains_canvas_center"]),
        ("one-connected-physical-shell", len(major_material) == 1),
        ("bbox-ratio", ratio_error <= MAX_RATIO_ERROR),
        ("normalization-anisotropy", anisotropy <= MAX_ANISOTROPY),
        ("dynamic-safe-core", safe_core_alpha_pixels == 0),
        ("green-isolation", min(isolation.values()) >= MIN_ISOLATION),
    ]
    first_failure = next((name for name, passed in checks if not passed), None)
    technical_pass = first_failure is None

    metrics: dict[str, Any] = {
        "overall_technical_pass": technical_pass,
        "first_failure": first_failure,
        "checks": [{"id": name, "pass": passed} for name, passed in checks],
        "large_opening_count": len(large_openings),
        "enclosed_chroma_components": enclosed,
        "edge_connected_green_pixels": int(sum(item["area"] for item in edge_green_components)),
        "edge_connected_green_component_count": len(edge_green_components),
        "enclosed_green_pixels": int(sum(item["area"] for item in enclosed)),
        "chroma_predicate_pixels": int(green.sum()),
        "major_physical_component_count": len(major_material),
        "physical_component_sizes_top10": material_sizes[:10],
        "bbox_exclusive": list(bbox),
        "bbox_size": [bbox_width, bbox_height],
        "source_ratio": round(source_ratio, 6),
        "target_ratio": round(TARGET_RATIO, 6),
        "ratio_error_percent": round(ratio_error, 6),
        "scale_x": round(sx, 8),
        "scale_y": round(sy, 8),
        "anisotropy_percent": round(anisotropy, 6),
        "isolation_margins": isolation,
        "required_min_isolation": MIN_ISOLATION,
        "safe_alpha_pixels": safe_alpha_pixels,
        "safe_core_alpha_pixels": safe_core_alpha_pixels,
    }

    normalized_path = output_dir / "normalized-diagnostic.png"
    runtime_path = output_dir / "runtime-diagnostic.png"
    technical_path = output_dir / "technical-review.png"
    real_layout_path = output_dir / "real-layout-preview.png"
    save_png(normalized, normalized_path)
    save_png(runtime_shell(normalized, clear_safe=False), runtime_path)
    render_technical(raw, bbox, enclosed, normalized, metrics, technical_path)
    render_real_layout(normalized, real_layout_path, args.segment, technical_pass)

    candidate_path: Path | None = None
    if technical_pass:
        cleaned = np.asarray(normalized).copy()
        cleaned[y0:y1, x0:x1] = 0
        candidate = clear_transparent_rgb(Image.fromarray(cleaned, "RGBA"))
        candidate_path = output_dir / "candidate.png"
        save_png(candidate, candidate_path)

    report = {
        "schema": "aeui-unitframes-primary-v3-shell-review-v1",
        "segment": args.segment,
        "raw": str(raw_path),
        "raw_sha256": sha256(raw_path),
        "raw_size": list(raw.size),
        "raw_mode": raw.mode,
        "contract": {
            "canvas": list(CANVAS),
            "normalized": list(NORMALIZED),
            "runtime": list(RUNTIME),
            "source_safe": list(SOURCE_SAFE),
            "source_safe_core": list(SOURCE_SAFE_CORE),
            "max_ratio_error_percent": MAX_RATIO_ERROR,
            "max_anisotropy_percent": MAX_ANISOTROPY,
        },
        "metrics": metrics,
        "artifacts": {
            "normalized_diagnostic": {"path": str(normalized_path), "sha256": sha256(normalized_path)},
            "runtime_diagnostic": {"path": str(runtime_path), "sha256": sha256(runtime_path)},
            "technical_review": {"path": str(technical_path), "sha256": sha256(technical_path)},
            "real_layout_preview": {"path": str(real_layout_path), "sha256": sha256(real_layout_path)},
            "candidate": {"path": str(candidate_path), "sha256": sha256(candidate_path)} if candidate_path else None,
        },
        "deterministic_operations": [
            "green predicate",
            "edge and enclosed connected-component labelling",
            "transparent RGB clear and one-pixel despill",
            "bbox measurement",
            "diagnostic 1284x252 independent-axis normalization",
            "safe-area alpha measurement",
            "100-percent real-layout and variable-width preview",
        ],
        "may_be_candidate": technical_pass,
        "may_be_source": False,
        "may_be_runtime": False,
        "note": "candidate is emitted only after all objective gates; user visual acceptance remains separate",
    }
    report_path = output_dir / "review-report.json"
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({
        "report": str(report_path),
        "technical_review": str(technical_path),
        "real_layout_preview": str(real_layout_path),
        "technical_pass": technical_pass,
        "first_failure": first_failure,
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
