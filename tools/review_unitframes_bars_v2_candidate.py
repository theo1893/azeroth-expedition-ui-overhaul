#!/usr/bin/env python3
"""Deterministically review UF-B1 V2 Health/Power material candidates.

The reviewer accepts only a two-object green-screen sheet.  It may key green,
clear transparent RGB, remove tiny residual chroma by equal-channel luminance,
and normalize each accepted swatch to its donor geometry.  It never invents
texture, removes a semantic third object, or promotes media to source/runtime.
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
CANVAS = (1024, 1024)
HEALTH_MASTER = (256, 128)
POWER_MASTER = (256, 64)
HEALTH_RUNTIME = (64, 32)
POWER_RUNTIME = (64, 16)
MIN_MAJOR_AREA = 2_000
MAX_MINOR_AREA = 128
MIN_EDGE_ISOLATION = 64
MIN_MID_GAP = 64
MIN_COVERAGE = 0.72
MAX_RATIO_ERROR = 25.0
MAX_CORE_CHROMA_Q95 = 18.0
MAX_CORE_CHROMA_MEAN = 8.0
MIN_MEAN_VALUE = 85.0
MAX_MEAN_VALUE = 210.0
MAX_CENTRE_BIAS = 18.0
FONT = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"
TITLE_FONT = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
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


def connected_component_stats(mask: np.ndarray) -> list[dict[str, Any]]:
    """Return exact 8-connected component areas/bboxes via scanline union-find."""
    height, width = mask.shape
    parent: list[int] = []
    area: list[int] = []
    min_x: list[int] = []
    min_y: list[int] = []
    max_x: list[int] = []
    max_y: list[int] = []

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
        return root_a

    previous: list[tuple[int, int, int]] = []
    for y in range(height):
        padded = np.concatenate((np.array([False]), mask[y], np.array([False])))
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
        bbox = [min_x[label], min_y[label], max_x[label], max_y[label]]
        bbox_area = max(1, (bbox[2] - bbox[0]) * (bbox[3] - bbox[1]))
        components.append({
            "area": area[label],
            "bbox_exclusive": bbox,
            "coverage": area[label] / bbox_area,
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


def component_core_metrics(raw: Image.Image, material: np.ndarray, bbox: list[int]) -> dict[str, float]:
    x0, y0, x1, y1 = bbox
    local_mask = Image.fromarray((material[y0:y1, x0:x1] * 255).astype(np.uint8), "L")
    eroded = np.asarray(local_mask.filter(ImageFilter.MinFilter(5))) >= 128
    rgb = np.asarray(raw.convert("RGB"))[y0:y1, x0:x1]
    pixels = rgb[eroded]
    if not len(pixels):
        return {
            "core_pixels": 0,
            "chroma_mean": 255.0,
            "chroma_q95": 255.0,
            "value_mean": 0.0,
        }
    spread = pixels.max(axis=1).astype(np.float32) - pixels.min(axis=1).astype(np.float32)
    value = (
        pixels[:, 0].astype(np.float32) * 0.2126
        + pixels[:, 1].astype(np.float32) * 0.7152
        + pixels[:, 2].astype(np.float32) * 0.0722
    )
    return {
        "core_pixels": int(len(pixels)),
        "chroma_mean": round(float(spread.mean()), 6),
        "chroma_q95": round(float(np.quantile(spread, 0.95)), 6),
        "value_mean": round(float(value.mean()), 6),
    }


def neutral_normalize(keyed: Image.Image, bbox: list[int], size: tuple[int, int]) -> Image.Image:
    crop = clear_transparent_rgb(keyed.crop(tuple(bbox)))
    rgba = np.asarray(crop).copy()
    luma = np.rint(
        rgba[:, :, 0].astype(np.float32) * 0.2126
        + rgba[:, :, 1].astype(np.float32) * 0.7152
        + rgba[:, :, 2].astype(np.float32) * 0.0722
    ).astype(np.uint8)
    rgba[:, :, :3] = luma[:, :, None]
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return clear_transparent_rgb(
        Image.fromarray(rgba, "RGBA").resize(size, Image.Resampling.LANCZOS)
    )


def runtime_metrics(image: Image.Image, runtime: tuple[int, int]) -> dict[str, float]:
    resized = clear_transparent_rgb(image.resize(runtime, Image.Resampling.LANCZOS))
    rgba = np.asarray(resized)
    visible = rgba[:, :, 3] >= 128
    values = rgba[:, :, 0][visible].astype(np.float32)
    if not len(values):
        return {"mean": 0.0, "stddev": 0.0, "centre_bias": 255.0, "visible_pixels": 0}
    width = runtime[0]
    centre = rgba[:, width * 3 // 8:width * 5 // 8, 0]
    centre_alpha = rgba[:, width * 3 // 8:width * 5 // 8, 3] >= 128
    centre_values = centre[centre_alpha].astype(np.float32)
    centre_mean = float(centre_values.mean()) if len(centre_values) else 0.0
    mean = float(values.mean())
    return {
        "mean": round(mean, 6),
        "stddev": round(float(values.std()), 6),
        "centre_bias": round(abs(centre_mean - mean), 6),
        "visible_pixels": int(len(values)),
    }


def tint_texture(texture: Image.Image, colour: tuple[int, int, int], size: tuple[int, int]) -> Image.Image:
    image = clear_transparent_rgb(texture.resize(size, Image.Resampling.LANCZOS))
    rgba = np.asarray(image).copy()
    grey = rgba[:, :, 0].astype(np.uint16)
    for channel, value in enumerate(colour):
        rgba[:, :, channel] = ((grey * value + 127) // 255).astype(np.uint8)
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def checkerboard(size: tuple[int, int], step: int = 12) -> Image.Image:
    image = Image.new("RGBA", size, (55, 52, 47, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], step):
        for x in range(0, size[0], step):
            if (x // step + y // step) % 2:
                draw.rectangle((x, y, x + step - 1, y + step - 1), fill=(84, 78, 69, 255))
    return image


def render_real_layout(
    health: Image.Image,
    power: Image.Image,
    technical_pass: bool,
    output: Path,
) -> None:
    scene = Image.new("RGBA", (1600, 900), (13, 16, 18, 255))
    draw = ImageDraw.Draw(scene, "RGBA")
    for y in range(95, 810, 48):
        offset = 44 if (y // 48) % 2 else 0
        for x in range(-35 + offset, 1600, 96):
            draw.polygon([(x, y + 3), (x + 87, y), (x + 91, y + 40), (x + 2, y + 44)], fill=(24, 27, 27, 255), outline=(37, 36, 32, 255))
    draw.rectangle((0, 0, 1600, 80), fill=(18, 16, 14, 250))
    draw.text((32, 17), "UF-B1 V2 · real 100% StatusBar layout", font=font(24, True), fill=(225, 196, 139, 255))
    verdict = "all deterministic gates pass" if technical_pass else "diagnostic only — failed candidate is not promoted"
    draw.text((34, 52), verdict, font=font(13), fill=(190, 171, 142, 255))

    cases = [
        ("Mana", (61, 132, 62), (48, 82, 160), 0.93),
        ("Rage", (135, 46, 39), (158, 47, 38), 0.77),
        ("Focus", (67, 126, 58), (166, 98, 40), 0.65),
        ("Energy", (65, 125, 56), (184, 166, 46), 0.84),
        ("Hostile", (148, 48, 39), (44, 77, 143), 0.58),
    ]
    for index, (label, health_colour, power_colour, fraction) in enumerate(cases):
        x = 55
        y = 126 + index * 104
        draw.text((x, y - 22), f"{index + 1}. {label}", font=font(13), fill=(208, 191, 158, 255))
        draw.rectangle((x, y, x + 214, y + 42), fill=(23, 16, 13, 255), outline=(102, 72, 38, 255), width=2)
        health_width = round(200 * fraction)
        scene.alpha_composite(tint_texture(health, health_colour, (health_width, 25)), (x + 7, y + 6))
        scene.alpha_composite(tint_texture(power, power_colour, (200, 4)), (x + 7, y + 32))
        draw.text((x + 12, y + 19), "远征者 60", font=font(11), fill=(239, 224, 187, 255), anchor="lm")
        draw.text((x + 202, y + 19), f"{round(fraction * 100)}%", font=font(11), fill=(241, 228, 194, 255), anchor="rm")

    draw.text((420, 112), "Neutral donors at runtime and 4× nearest inspection", font=font(15, True), fill=(211, 187, 137, 255))
    health_runtime = health.resize(HEALTH_RUNTIME, Image.Resampling.LANCZOS)
    power_runtime = power.resize(POWER_RUNTIME, Image.Resampling.LANCZOS)
    health_zoom = health_runtime.resize((256, 128), Image.Resampling.NEAREST)
    power_zoom = power_runtime.resize((256, 64), Image.Resampling.NEAREST)
    health_board = checkerboard(health_zoom.size, 16)
    power_board = checkerboard(power_zoom.size, 16)
    health_board.alpha_composite(health_zoom)
    power_board.alpha_composite(power_zoom)
    scene.alpha_composite(health_board, (420, 150))
    scene.alpha_composite(power_board, (420, 315))
    draw.text((420, 286), "Health 64×32 → 4×", font=font(12), fill=(184, 169, 141, 255))
    draw.text((420, 386), "Power 64×16 → 4×", font=font(12), fill=(184, 169, 141, 255))

    x0 = 760
    draw.text((x0, 112), "Tint parity: same donor, runtime vertex colours", font=font(15, True), fill=(211, 187, 137, 255))
    tint_cases = [
        ("Health", (66, 126, 57)),
        ("Mana", (49, 84, 160)),
        ("Rage", (158, 47, 38)),
        ("Focus", (166, 98, 40)),
        ("Energy", (184, 166, 46)),
    ]
    for index, (label, colour) in enumerate(tint_cases):
        y = 155 + index * 74
        draw.text((x0, y - 19), label, font=font(12), fill=(194, 179, 151, 255))
        donor = health if index == 0 else power
        height = 25 if index == 0 else 12
        scene.alpha_composite(tint_texture(donor, colour, (520, height)), (x0, y))

    draw.text((420, 505), "Dynamic values, names and colours remain runtime-owned", font=font(14), fill=(190, 171, 140, 255))
    draw.text((420, 540), "No source/runtime files are emitted before user acceptance.", font=font(13), fill=(165, 151, 127, 255))
    save_png(scene, output)


def render_technical(
    raw: Image.Image,
    major: list[dict[str, Any]],
    metrics: dict[str, Any],
    health: Image.Image,
    power: Image.Image,
    output: Path,
) -> None:
    annotated = raw.convert("RGBA")
    overlay = Image.new("RGBA", raw.size, (0, 0, 0, 0))
    odraw = ImageDraw.Draw(overlay, "RGBA")
    colours = [(219, 73, 57, 255), (68, 133, 223, 255)]
    for index, item in enumerate(major):
        x0, y0, x1, y1 = item["bbox_exclusive"]
        odraw.rectangle((x0, y0, x1 - 1, y1 - 1), outline=colours[index], width=5)
    annotated = Image.alpha_composite(annotated, overlay)
    annotated.thumbnail((690, 690), Image.Resampling.LANCZOS)

    board = Image.new("RGBA", (1500, 980), (25, 22, 19, 255))
    draw = ImageDraw.Draw(board, "RGBA")
    draw.text((28, 18), "UF-B1 V2 deterministic StatusBar review", font=font(25, True), fill=(226, 196, 137, 255))
    board.alpha_composite(annotated, (28, 84))
    lines = [
        f"technical pass: {metrics['overall_technical_pass']}",
        f"first failure: {metrics['first_failure'] or 'none'}",
        f"major / minor material: {metrics['major_component_count']} / {metrics['minor_material_area']} px",
        f"Health bbox / ratio error: {metrics['health']['bbox_size']} / {metrics['health']['ratio_error_percent']:.3f}%",
        f"Power bbox / ratio error: {metrics['power']['bbox_size']} / {metrics['power']['ratio_error_percent']:.3f}%",
        f"Health chroma mean/q95: {metrics['health']['core']['chroma_mean']:.2f}/{metrics['health']['core']['chroma_q95']:.2f}",
        f"Power chroma mean/q95: {metrics['power']['core']['chroma_mean']:.2f}/{metrics['power']['core']['chroma_q95']:.2f}",
        f"edge isolation: {metrics['edge_isolation']}; mid gap: {metrics['mid_gap']}",
        f"centre bias H/P: {metrics['health']['runtime']['centre_bias']:.2f}/{metrics['power']['runtime']['centre_bias']:.2f}",
    ]
    for index, line in enumerate(lines):
        colour = (222, 102, 83, 255) if index < 2 and not metrics["overall_technical_pass"] else (216, 204, 177, 255)
        draw.text((775, 96 + index * 40), line, font=font(14), fill=colour)

    health_board = checkerboard(HEALTH_MASTER, 12)
    power_board = checkerboard(POWER_MASTER, 12)
    health_board.alpha_composite(health)
    power_board.alpha_composite(power)
    board.alpha_composite(health_board, (775, 520))
    board.alpha_composite(power_board, (775, 700))
    draw.text((775, 660), "Health normalized diagnostic 256×128", font=font(12), fill=(183, 168, 140, 255))
    draw.text((775, 790), "Power normalized diagnostic 256×64", font=font(12), fill=(183, 168, 140, 255))
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
    material = ~green
    components = connected_component_stats(material)
    major = [item for item in components if item["area"] >= MIN_MAJOR_AREA]
    minor_area = sum(item["area"] for item in components if item["area"] < MIN_MAJOR_AREA)
    ordered = sorted(major, key=lambda item: item["bbox_exclusive"][1])
    usable = len(ordered) == 2

    placeholder_health = [128, 192, 896, 448]
    placeholder_power = [128, 640, 896, 768]
    health_bbox = ordered[0]["bbox_exclusive"] if usable else placeholder_health
    power_bbox = ordered[1]["bbox_exclusive"] if usable else placeholder_power
    keyed = keyed_material(raw, green)
    health = neutral_normalize(keyed, health_bbox, HEALTH_MASTER)
    power = neutral_normalize(keyed, power_bbox, POWER_MASTER)

    def swatch_metrics(item: dict[str, Any] | None, bbox: list[int], target_ratio: float, normalized: Image.Image, runtime_size: tuple[int, int]) -> dict[str, Any]:
        width, height = bbox[2] - bbox[0], bbox[3] - bbox[1]
        ratio = width / max(1, height)
        return {
            "bbox_exclusive": bbox,
            "bbox_size": [width, height],
            "area": item["area"] if item else 0,
            "coverage": round(float(item["coverage"]), 6) if item else 0.0,
            "source_ratio": round(ratio, 6),
            "target_ratio": target_ratio,
            "ratio_error_percent": round(abs(ratio - target_ratio) / target_ratio * 100.0, 6),
            "core": component_core_metrics(raw, material, bbox),
            "runtime": runtime_metrics(normalized, runtime_size),
        }

    health_item = ordered[0] if usable else None
    power_item = ordered[1] if usable else None
    health_metrics = swatch_metrics(health_item, health_bbox, 2.0, health, HEALTH_RUNTIME)
    power_metrics = swatch_metrics(power_item, power_bbox, 4.0, power, POWER_RUNTIME)
    edge_isolation = {
        "health_left": health_bbox[0],
        "health_top": health_bbox[1],
        "health_right": CANVAS[0] - health_bbox[2],
        "power_left": power_bbox[0],
        "power_right": CANVAS[0] - power_bbox[2],
        "power_bottom": CANVAS[1] - power_bbox[3],
    }
    mid_gap = power_bbox[1] - health_bbox[3]
    vertical_order = health_bbox[3] <= CANVAS[1] // 2 and power_bbox[1] >= CANVAS[1] // 2
    neutral = all(
        item["core"]["chroma_q95"] <= MAX_CORE_CHROMA_Q95
        and item["core"]["chroma_mean"] <= MAX_CORE_CHROMA_MEAN
        for item in (health_metrics, power_metrics)
    )
    tintable = all(
        MIN_MEAN_VALUE <= item["core"]["value_mean"] <= MAX_MEAN_VALUE
        for item in (health_metrics, power_metrics)
    )
    hierarchy = (
        health_metrics["runtime"]["stddev"] >= 4.0
        and power_metrics["runtime"]["stddev"] >= 2.0
        and power_metrics["runtime"]["stddev"] <= health_metrics["runtime"]["stddev"] * 1.2 + 2.0
    )

    checks = [
        ("exactly-two-isolated-swatches", usable and minor_area <= MAX_MINOR_AREA),
        ("upper-health-lower-power", vertical_order and mid_gap >= MIN_MID_GAP),
        ("green-isolation", min(edge_isolation.values()) >= MIN_EDGE_ISOLATION),
        ("swatch-ratios", health_metrics["ratio_error_percent"] <= MAX_RATIO_ERROR and power_metrics["ratio_error_percent"] <= MAX_RATIO_ERROR),
        ("rectangular-coverage", health_metrics["coverage"] >= MIN_COVERAGE and power_metrics["coverage"] >= MIN_COVERAGE),
        ("neutral-core", neutral),
        ("tintable-value", tintable),
        ("no-centre-hotspot", health_metrics["runtime"]["centre_bias"] <= MAX_CENTRE_BIAS and power_metrics["runtime"]["centre_bias"] <= MAX_CENTRE_BIAS),
        ("health-power-hierarchy", hierarchy),
    ]
    first_failure = next((name for name, passed in checks if not passed), None)
    technical_pass = first_failure is None
    metrics: dict[str, Any] = {
        "overall_technical_pass": technical_pass,
        "first_failure": first_failure,
        "checks": [{"id": name, "pass": passed} for name, passed in checks],
        "component_count": len(components),
        "major_component_count": len(major),
        "minor_material_area": int(minor_area),
        "edge_isolation": edge_isolation,
        "mid_gap": int(mid_gap),
        "health": health_metrics,
        "power": power_metrics,
    }

    health_diag = output_dir / "health-normalized-diagnostic.png"
    power_diag = output_dir / "power-normalized-diagnostic.png"
    technical_path = output_dir / "technical-review.png"
    real_layout_path = output_dir / "real-layout-preview.png"
    save_png(health, health_diag)
    save_png(power, power_diag)
    render_technical(raw, ordered[:2], metrics, health, power, technical_path)
    render_real_layout(health, power, technical_pass, real_layout_path)

    health_candidate: Path | None = None
    power_candidate: Path | None = None
    if technical_pass:
        health_candidate = output_dir / "health-candidate.png"
        power_candidate = output_dir / "power-candidate.png"
        save_png(health, health_candidate)
        save_png(power, power_candidate)

    artifacts: dict[str, Any] = {
        "health_normalized_diagnostic": {"path": str(health_diag), "sha256": sha256(health_diag)},
        "power_normalized_diagnostic": {"path": str(power_diag), "sha256": sha256(power_diag)},
        "technical_review": {"path": str(technical_path), "sha256": sha256(technical_path)},
        "real_layout_preview": {"path": str(real_layout_path), "sha256": sha256(real_layout_path)},
        "health_candidate": {"path": str(health_candidate), "sha256": sha256(health_candidate)} if health_candidate else None,
        "power_candidate": {"path": str(power_candidate), "sha256": sha256(power_candidate)} if power_candidate else None,
    }
    report = {
        "schema": "aeui-unitframes-bars-v2-review-v1",
        "raw": str(raw_path),
        "raw_sha256": sha256(raw_path),
        "raw_size": list(raw.size),
        "raw_mode": raw.mode,
        "contract": {
            "canvas": list(CANVAS),
            "health_master": list(HEALTH_MASTER),
            "power_master": list(POWER_MASTER),
            "health_runtime": list(HEALTH_RUNTIME),
            "power_runtime": list(POWER_RUNTIME),
            "max_ratio_error_percent": MAX_RATIO_ERROR,
            "max_core_chroma_q95": MAX_CORE_CHROMA_Q95,
            "max_core_chroma_mean": MAX_CORE_CHROMA_MEAN,
        },
        "metrics": metrics,
        "artifacts": artifacts,
        "deterministic_operations": [
            "green predicate and one-pixel despill",
            "exact connected-component labelling",
            "transparent RGB clear",
            "equal-channel luminance conversion after residual-chroma gates",
            "independent swatch bbox normalization",
            "64x32 and 64x16 diagnostic downsample",
            "100-percent real-layout runtime tint preview",
        ],
        "may_be_candidate": technical_pass,
        "may_be_source": False,
        "may_be_runtime": False,
        "note": "candidate donors are emitted only after every objective gate; user visual acceptance remains separate",
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
