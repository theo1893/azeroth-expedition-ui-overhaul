#!/usr/bin/env python3
"""Build an authorized canonical Field Kit atlas from a chroma-key raw.

The provider raw is immutable.  This tool performs only the transport repair
authorized for AB.TRINKET.KIT.V1 and AB.CONSUMABLE.KIT.V1: whole-square
normalization, per-cell edge-connected chroma keying, complete-bbox
proportional fitting and centering, straight-Alpha output, and transparent-RGB
zeroing.  It never paints, sharpens, invents pixels, or promotes a candidate.
"""

from __future__ import annotations

import argparse
from collections import deque
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
CANVAS_SIZE = (1024, 1024)
CELL_SIZE = (512, 512)
SAFE_BOX = (80, 80, 432, 432)
GREEN = (0, 255, 0)
RESAMPLE = Image.Resampling.LANCZOS
CELL_BOXES = {
    "A": (0, 0, 512, 512),
    "B": (512, 0, 1024, 512),
    "C": (0, 512, 512, 1024),
    "D": (512, 512, 1024, 1024),
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--component", required=True, choices=("trinket", "consumable"))
    parser.add_argument("--raw", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--report", required=True, type=Path)
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--repo-root", type=Path, default=ROOT)
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


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    return image.convert("RGBA").getchannel("A").getbbox()


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = bytearray(image.convert("RGBA").tobytes())
    for offset in range(0, len(rgba), 4):
        if rgba[offset + 3] == 0:
            rgba[offset] = 0
            rgba[offset + 1] = 0
            rgba[offset + 2] = 0
    return Image.frombytes("RGBA", image.size, bytes(rgba))


def boundary_connected(mask: bytearray, width: int, height: int) -> bytearray:
    """Return all true pixels connected by four-neighbour paths to any edge."""

    connected = bytearray(width * height)
    queue: deque[int] = deque()

    def seed(x: int, y: int) -> None:
        index = y * width + x
        if mask[index] and not connected[index]:
            connected[index] = 1
            queue.append(index)

    for x in range(width):
        seed(x, 0)
        seed(x, height - 1)
    for y in range(1, height - 1):
        seed(0, y)
        seed(width - 1, y)

    while queue:
        index = queue.popleft()
        x = index % width
        candidates = []
        if x > 0:
            candidates.append(index - 1)
        if x + 1 < width:
            candidates.append(index + 1)
        if index >= width:
            candidates.append(index - width)
        if index + width < width * height:
            candidates.append(index + width)
        for neighbour in candidates:
            if mask[neighbour] and not connected[neighbour]:
                connected[neighbour] = 1
                queue.append(neighbour)
    return connected


def edge_connected_chroma_key(
    cell: Image.Image,
) -> tuple[Image.Image, dict[str, Any]]:
    """Convert only boundary-connected green to unassociated straight Alpha.

    The matte estimate assumes the authorized key is RGB (0, 255, 0) and the
    painted Field Kit contains no green material.  Connected mixed edge pixels
    receive partial Alpha and are deterministically unmatted against that key;
    isolated interior green is deliberately preserved for the later visible-
    green gate rather than being silently deleted.
    """

    rgb = list(cell.convert("RGB").getdata())
    greenish = bytearray(len(rgb))
    for index, (red, green, blue) in enumerate(rgb):
        dominance = green - max(red, blue)
        if green >= 82 and dominance >= 20 and green - blue >= 10:
            greenish[index] = 1
    connected = boundary_connected(greenish, cell.width, cell.height)
    connected_count = sum(connected)
    if connected_count == 0:
        raise ValueError("cell has no edge-connected chroma-key field")
    if connected_count < round(cell.width * cell.height * 0.10):
        raise ValueError("edge-connected chroma-key field covers less than 10% of cell")

    output = bytearray(len(rgb) * 4)
    zero_alpha = 0
    partial_alpha = 0
    opaque = 0
    exact_connected = 0
    connected_colours: set[tuple[int, int, int]] = set()
    for index, (red, green, blue) in enumerate(rgb):
        alpha = 255
        out_red, out_green, out_blue = red, green, blue
        if connected[index]:
            connected_colours.add((red, green, blue))
            if (red, green, blue) == GREEN:
                exact_connected += 1
            dominance = max(0, green - max(red, blue))
            key_distance = max(abs(red), abs(green - 255), abs(blue))
            alpha = max(0, min(255, 255 - dominance))
            if key_distance <= 20 or alpha <= 8:
                alpha = 0
            if 0 < alpha < 255:
                fraction = alpha / 255.0
                out_red = round(red / fraction)
                out_blue = round(blue / fraction)
                out_green = round((green - (1.0 - fraction) * 255.0) / fraction)
                out_red = max(0, min(255, out_red))
                out_green = max(0, min(255, out_green))
                out_blue = max(0, min(255, out_blue))
                # The raw edge was composited against the green transport
                # field.  Clamp only that connected, partially transparent
                # matte back to a non-green straight-RGB edge; opaque object
                # pixels and isolated interior green remain untouched.
                out_green = min(out_green, max(out_red, out_blue) + 8)
        if alpha == 0:
            out_red = out_green = out_blue = 0
            zero_alpha += 1
        elif alpha < 255:
            partial_alpha += 1
        else:
            opaque += 1
        offset = index * 4
        output[offset : offset + 4] = bytes((out_red, out_green, out_blue, alpha))

    keyed = clear_transparent_rgb(Image.frombytes("RGBA", cell.size, bytes(output)))
    bbox = alpha_bbox(keyed)
    if bbox is None:
        raise ValueError("cell contains no visible object after chroma key")

    return keyed, {
        "edge_connected_pixels": connected_count,
        "edge_connected_fraction": connected_count / (cell.width * cell.height),
        "edge_connected_exact_00ff00_pixels": exact_connected,
        "edge_connected_exact_00ff00_ratio": exact_connected / connected_count,
        "edge_connected_unique_rgb": len(connected_colours),
        "zero_alpha_pixels": zero_alpha,
        "partial_alpha_pixels": partial_alpha,
        "opaque_pixels": opaque,
        "keyed_bbox_exclusive": list(bbox),
    }


def resize_straight_alpha(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    """Resize through premultiplied RGBa, then return straight RGBA bytes."""

    premultiplied = image.convert("RGBa").resize(size, RESAMPLE)
    rgba = bytearray(premultiplied.convert("RGBA").tobytes())
    for offset in range(0, len(rgba), 4):
        alpha = rgba[offset + 3]
        if 0 < alpha < 255:
            cap = max(rgba[offset], rgba[offset + 2]) + 8
            rgba[offset + 1] = min(rgba[offset + 1], cap)
        if alpha <= 8:
            rgba[offset : offset + 4] = b"\x00\x00\x00\x00"
    return clear_transparent_rgb(Image.frombytes("RGBA", size, bytes(rgba)))


def fit_cell(keyed: Image.Image) -> tuple[Image.Image, dict[str, Any]]:
    bbox = alpha_bbox(keyed)
    if bbox is None:
        raise ValueError("cell contains no visible object to fit")
    crop = clear_transparent_rgb(keyed.crop(bbox))
    target_width = SAFE_BOX[2] - SAFE_BOX[0]
    target_height = SAFE_BOX[3] - SAFE_BOX[1]
    scale = min(target_width / crop.width, target_height / crop.height)
    size = (
        max(1, min(target_width, round(crop.width * scale))),
        max(1, min(target_height, round(crop.height * scale))),
    )
    resized = resize_straight_alpha(crop, size)
    paste = ((CELL_SIZE[0] - size[0]) // 2, (CELL_SIZE[1] - size[1]) // 2)
    output = Image.new("RGBA", CELL_SIZE, (0, 0, 0, 0))
    output.alpha_composite(resized, paste)
    output = clear_transparent_rgb(output)
    fitted_bbox = alpha_bbox(output)
    if fitted_bbox is None:
        raise ValueError("fitted cell contains no visible object")
    margins = [
        fitted_bbox[0],
        fitted_bbox[1],
        CELL_SIZE[0] - fitted_bbox[2],
        CELL_SIZE[1] - fitted_bbox[3],
    ]
    return output, {
        "complete_bbox_exclusive": list(bbox),
        "complete_visible_size": [bbox[2] - bbox[0], bbox[3] - bbox[1]],
        "fit_scale": scale,
        "resized_canvas_size": list(size),
        "paste_xy": list(paste),
        "safe_box_exclusive": list(SAFE_BOX),
        "canonical_bbox_exclusive": list(fitted_bbox),
        "canonical_margins_ltrb": margins,
        "minimum_margin": min(margins),
    }


def visible_green_metrics(image: Image.Image) -> dict[str, int]:
    exact = 0
    dominant = 0
    for red, green, blue, alpha in image.convert("RGBA").getdata():
        if alpha == 0:
            continue
        if (red, green, blue) == GREEN:
            exact += 1
        if green - max(red, blue) >= 35:
            dominant += 1
    return {"exact_00ff00": exact, "heuristic_green_dominant": dominant}


def transparent_rgb_nonzero(image: Image.Image) -> int:
    count = 0
    for red, green, blue, alpha in image.convert("RGBA").getdata():
        if alpha == 0 and (red != 0 or green != 0 or blue != 0):
            count += 1
    return count


def canonicalize(raw: Image.Image) -> tuple[Image.Image, dict[str, Any]]:
    if raw.width != raw.height:
        raise ValueError("Field Kit provider raw must be square; non-square resize is forbidden")
    normalized = raw.convert("RGB")
    if normalized.size != CANVAS_SIZE:
        normalized = normalized.resize(CANVAS_SIZE, RESAMPLE)

    canonical = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    cell_reports: dict[str, Any] = {}
    for identifier, global_box in CELL_BOXES.items():
        cell_rgb = normalized.crop(global_box)
        keyed, key_report = edge_connected_chroma_key(cell_rgb)
        fitted, fit_report = fit_cell(keyed)
        canonical.alpha_composite(fitted, (global_box[0], global_box[1]))
        cell_reports[identifier] = {
            "normalized_cell_exclusive": list(global_box),
            "chroma_key": key_report,
            "fit": fit_report,
        }

    canonical = clear_transparent_rgb(canonical)
    alpha_histogram = canonical.getchannel("A").histogram()
    alpha_min, alpha_max = canonical.getchannel("A").getextrema()
    transparent_pixels = alpha_histogram[0]
    opaque_pixels = alpha_histogram[255]
    partial_alpha_pixels = sum(alpha_histogram[1:255])
    green = visible_green_metrics(canonical)
    dirty_transparent = transparent_rgb_nonzero(canonical)
    checks = {
        "raw_rgb_mode": raw.mode == "RGB",
        "raw_square_canvas": raw.width == raw.height,
        "canonical_exact_1024_canvas": canonical.size == CANVAS_SIZE,
        "canonical_rgba_mode": canonical.mode == "RGBA",
        "canonical_has_transparency": alpha_min == 0 and alpha_max > 0,
        "four_cells_nonempty": all(
            report["fit"]["canonical_bbox_exclusive"] for report in cell_reports.values()
        ),
        "four_cells_minimum_80px_margin": all(
            report["fit"]["minimum_margin"] >= 80 for report in cell_reports.values()
        ),
        "no_cell_touches_boundary": all(
            report["fit"]["minimum_margin"] > 0 for report in cell_reports.values()
        ),
        "visible_green_zero": all(value == 0 for value in green.values()),
        "transparent_rgb_zero": dirty_transparent == 0,
    }
    return canonical, {
        "transport_operations": [
            "whole-square LANCZOS normalization to 1024x1024 RGB",
            "split into four fixed 512x512 cells",
            "per-cell edge-connected #00FF00 chroma key to straight RGBA",
            "per-cell complete visible-bbox proportional LANCZOS fit and centering",
            "fully transparent RGB zeroing",
        ],
        "forbidden_operations": [
            "repaint",
            "retouch",
            "sharpen",
            "content-aware fill",
            "new input image",
            "semantic repair",
        ],
        "raw": {"mode": raw.mode, "size": list(raw.size)},
        "normalized_rgb_size": list(normalized.size),
        "canonical": {
            "mode": canonical.mode,
            "size": list(canonical.size),
            "alpha_extrema": [alpha_min, alpha_max],
            "partial_alpha_pixels": partial_alpha_pixels,
            "opaque_pixels": opaque_pixels,
            "transparent_pixels": transparent_pixels,
            "visible_green": green,
            "transparent_rgb_nonzero_pixels": dirty_transparent,
        },
        "cells": cell_reports,
        "checks": checks,
        "status": "pass" if all(checks.values()) else "fail",
        "failures": [identifier for identifier, passed in checks.items() if not passed],
    }


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    raw_path = resolve(root, args.raw).resolve()
    output_path = resolve(root, args.output).resolve()
    report_path = resolve(root, args.report).resolve()
    with Image.open(raw_path) as opened:
        opened.load()
        raw_format = opened.format
        raw = opened.copy()

    canonical, details = canonicalize(raw)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    canonical.save(output_path, format="PNG", optimize=False, compress_level=9)
    report = {
        "schema": "aeui-action-fieldkit-canonicalization-v1",
        "component": (
            "AB.TRINKET.KIT.V1" if args.component == "trinket" else "AB.CONSUMABLE.KIT.V1"
        ),
        "attempt": args.attempt,
        "candidate_is_source": False,
        "candidate_is_runtime": False,
        "authorization": "2026-08-09 raw RGB chroma transport amendment",
        "raw": {
            "path": str(raw_path),
            "sha256": sha256(raw_path),
            "format": raw_format,
            **details.pop("raw"),
        },
        "canonical": {
            "path": str(output_path),
            "sha256": sha256(output_path),
            **details.pop("canonical"),
        },
        **details,
    }
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))
    if report["status"] != "pass":
        raise SystemExit(2)


if __name__ == "__main__":
    main()
