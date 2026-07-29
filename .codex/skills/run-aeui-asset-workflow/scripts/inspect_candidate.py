#!/usr/bin/env python3
"""Report deterministic PNG/bitmap candidate metrics.

This checker intentionally does not infer logical-object identity, anatomy, style, or
correctness from connected regions. Those are visual review responsibilities.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Any


def parse_cell(value: str) -> tuple[str, tuple[int, int, int, int]]:
    try:
        name, raw_box = value.split("=", 1)
        coordinates = tuple(int(part.strip()) for part in raw_box.split(","))
    except (ValueError, TypeError) as exc:
        raise argparse.ArgumentTypeError(
            "cell must use ID=x0,y0,x1,y1"
        ) from exc

    if not name.strip() or len(coordinates) != 4:
        raise argparse.ArgumentTypeError("cell must use ID=x0,y0,x1,y1")

    x0, y0, x1, y1 = coordinates
    if x0 < 0 or y0 < 0 or x1 <= x0 or y1 <= y0:
        raise argparse.ArgumentTypeError("cell coordinates must define a positive box")

    return name.strip(), (x0, y0, x1, y1)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def globalize_bbox(
    bbox: tuple[int, int, int, int] | None, x0: int, y0: int
) -> list[int] | None:
    if bbox is None:
        return None
    left, top, right, bottom = bbox
    return [left + x0, top + y0, right + x0, bottom + y0]


def cell_report(
    alpha: Any, name: str, box: tuple[int, int, int, int]
) -> dict[str, Any]:
    x0, y0, x1, y1 = box
    cropped = alpha.crop(box)
    histogram = cropped.histogram()
    transparent = histogram[0]
    opaque = histogram[255]
    partial = sum(histogram[1:255])
    bbox = cropped.getbbox()

    touches = {
        "left": bool(bbox and bbox[0] == 0),
        "top": bool(bbox and bbox[1] == 0),
        "right": bool(bbox and bbox[2] == x1 - x0),
        "bottom": bool(bbox and bbox[3] == y1 - y0),
    }

    return {
        "id": name,
        "box": [x0, y0, x1, y1],
        "size": [x1 - x0, y1 - y0],
        "alpha_pixels": {
            "transparent": transparent,
            "partial": partial,
            "opaque": opaque,
            "visible": partial + opaque,
        },
        "visible_bbox_local": list(bbox) if bbox else None,
        "visible_bbox_global": globalize_bbox(bbox, x0, y0),
        "touches_cell_edge": touches,
    }


def inspect(path: Path, cells: list[tuple[str, tuple[int, int, int, int]]]) -> dict[str, Any]:
    try:
        from PIL import Image
    except ImportError as exc:
        raise RuntimeError(
            "Pillow is required; use the repository's locked tools environment"
        ) from exc

    with Image.open(path) as source:
        source.load()
        source_format = source.format
        source_mode = source.mode
        rgba = source.convert("RGBA")

    width, height = rgba.size
    alpha = rgba.getchannel("A")
    histogram = alpha.histogram()
    transparent = histogram[0]
    opaque = histogram[255]
    partial = sum(histogram[1:255])

    exact_key_visible = 0
    green_dominant_visible = 0
    pixel_data = (
        rgba.get_flattened_data()
        if hasattr(rgba, "get_flattened_data")
        else rgba.getdata()
    )
    for red, green, blue, pixel_alpha in pixel_data:
        if pixel_alpha == 0:
            continue
        if red <= 4 and green >= 251 and blue <= 4:
            exact_key_visible += 1
        if green >= 128 and green >= red + 32 and green >= blue + 32:
            green_dominant_visible += 1

    reports: list[dict[str, Any]] = []
    seen: set[str] = set()
    for name, box in cells:
        if name in seen:
            raise ValueError(f"duplicate cell id: {name}")
        seen.add(name)
        x0, y0, x1, y1 = box
        if x1 > width or y1 > height:
            raise ValueError(
                f"cell {name} box {box} exceeds image size {width}x{height}"
            )
        reports.append(cell_report(alpha, name, box))

    visible_bbox = alpha.getbbox()
    return {
        "schema": "aeui-candidate-inspection-v1",
        "path": str(path.resolve()),
        "sha256": sha256(path),
        "format": source_format,
        "source_mode": source_mode,
        "inspection_mode": "RGBA",
        "size": [width, height],
        "pixels": width * height,
        "alpha_pixels": {
            "transparent": transparent,
            "partial": partial,
            "opaque": opaque,
            "visible": partial + opaque,
        },
        "visible_bbox": list(visible_bbox) if visible_bbox else None,
        "visible_green_spill": {
            "exact_00ff00": exact_key_visible,
            "heuristic_green_dominant": green_dominant_visible,
        },
        "cells": reports,
        "semantic_warning": (
            "Pixel metrics do not prove object identity, anatomy, perspective, "
            "layering, runtime ownership, or art-direction compliance."
        ),
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Inspect deterministic Alpha, bounds, spill, and hash metrics."
    )
    parser.add_argument("image", type=Path, help="candidate bitmap path")
    parser.add_argument(
        "--cell",
        action="append",
        default=[],
        type=parse_cell,
        metavar="ID=x0,y0,x1,y1",
        help="inspect one contract-defined atlas cell; repeat as needed",
    )
    return parser


def main() -> int:
    args = build_parser().parse_args()
    if not args.image.is_file():
        print(f"error: image does not exist: {args.image}", file=sys.stderr)
        return 2

    try:
        report = inspect(args.image, args.cell)
    except (OSError, RuntimeError, ValueError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    print(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
