#!/usr/bin/env python3
"""Recover transparent CHAT.FRAME.FULL.V1 pixels from a baked checkerboard.

This is a deterministic technical cleanup of one generated candidate.  It
does not read the accepted frame, masks, or any other art source.  The script
keeps only the center-connected dark/chromatic object, derives a narrow soft
edge from that object, and places the complete result on the configured
transparent runtime-source canvas without compositing old pixels.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from collections.abc import Sequence
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--metrics", type=Path, required=True)
    parser.add_argument("--debug-mask", type=Path)
    parser.add_argument("--canvas", type=parse_size, default=(1608, 978))
    parser.add_argument("--margin", type=int, default=24)
    parser.add_argument("--minimum-threshold", type=int, default=140)
    parser.add_argument("--chroma-threshold", type=int, default=28)
    parser.add_argument("--chroma-luma-ceiling", type=int, default=185)
    parser.add_argument("--close-radius", type=int, default=0)
    parser.add_argument("--edge-radius", type=float, default=0.8)
    parser.add_argument("--edge-color-radius", type=float, default=2.0)
    parser.add_argument("--edge-color-inset", type=int, default=3)
    return parser.parse_args()


def parse_size(value: str) -> tuple[int, int]:
    parts = value.lower().split("x", 1)
    if len(parts) != 2:
        raise argparse.ArgumentTypeError("size must be WIDTHxHEIGHT")
    return int(parts[0]), int(parts[1])


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def ensure_parent(paths: Sequence[Path | None]) -> None:
    for path in paths:
        if path is not None:
            path.parent.mkdir(parents=True, exist_ok=True)


def center_component(mask: Image.Image) -> Image.Image:
    """Return only the foreground component connected to the canvas center."""
    width, height = mask.size
    marked = mask.copy()
    center = (width // 2, height // 2)
    if marked.getpixel(center) == 0:
        raise RuntimeError("candidate center is not part of the foreground seed")
    ImageDraw.floodfill(marked, center, 128, thresh=0)
    values = np.asarray(marked, dtype=np.uint8)
    return Image.fromarray(np.where(values == 128, 255, 0).astype(np.uint8), "L")


def fill_internal_holes(mask: Image.Image) -> Image.Image:
    """Fill neutral highlights enclosed by the center-connected silhouette."""
    marked = mask.copy()
    if marked.getpixel((0, 0)) != 0:
        raise RuntimeError("top-left pixel is not exterior background")
    ImageDraw.floodfill(marked, (0, 0), 128, thresh=0)
    values = np.asarray(marked, dtype=np.uint8)
    return Image.fromarray(np.where(values == 128, 0, 255).astype(np.uint8), "L")


def build_seed(rgb: np.ndarray, args: argparse.Namespace) -> Image.Image:
    values = rgb.astype(np.int32)
    minimum = values.min(axis=2)
    maximum = values.max(axis=2)
    chroma = maximum - minimum
    luma = (
        values[:, :, 0] * 54
        + values[:, :, 1] * 183
        + values[:, :, 2] * 19
    ) // 256
    foreground = (minimum < args.minimum_threshold) | (
        (chroma > args.chroma_threshold) & (luma < args.chroma_luma_ceiling)
    )
    seed = Image.fromarray((foreground * 255).astype(np.uint8), "L")
    if args.close_radius:
        kernel = args.close_radius * 2 + 1
        seed = seed.filter(ImageFilter.MaxFilter(kernel))
        seed = seed.filter(ImageFilter.MinFilter(kernel))
    return fill_internal_holes(center_component(seed))


def decontaminated_rgba(
    source: Image.Image,
    hard_mask: Image.Image,
    edge_radius: float,
    edge_color_radius: float,
    edge_color_inset: int,
) -> Image.Image:
    """Create a soft edge whose RGB comes only from nearby object pixels."""
    rgb = np.asarray(source.convert("RGB"), dtype=np.float32)
    hard = np.asarray(hard_mask, dtype=np.float32) / 255.0
    color_mask_image = hard_mask
    if edge_color_inset:
        color_mask_image = hard_mask.filter(
            ImageFilter.MinFilter(edge_color_inset * 2 + 1)
        )
    color_mask = np.asarray(color_mask_image, dtype=np.float32) / 255.0

    alpha_image = hard_mask.filter(ImageFilter.GaussianBlur(edge_radius))
    alpha_values = np.asarray(alpha_image, dtype=np.float32)
    alpha_values = np.where(alpha_values < 5.0, 0.0, alpha_values)
    alpha_values = np.where(alpha_values > 250.0, 255.0, alpha_values)

    weight_image = Image.fromarray((color_mask * 255.0).astype(np.uint8), "L")
    weight = np.asarray(
        weight_image.filter(ImageFilter.GaussianBlur(edge_color_radius)),
        dtype=np.float32,
    ) / 255.0
    weight = np.maximum(weight, 1.0 / 255.0)

    filled = np.empty_like(rgb)
    for channel in range(3):
        premultiplied = Image.fromarray(
            np.clip(rgb[:, :, channel] * color_mask, 0, 255).astype(np.uint8), "L"
        )
        blurred = np.asarray(
            premultiplied.filter(ImageFilter.GaussianBlur(edge_color_radius)),
            dtype=np.float32,
        )
        filled[:, :, channel] = blurred / weight

    use_original = color_mask >= (254.0 / 255.0)
    cleaned_rgb = np.where(use_original[:, :, None], rgb, filled)
    rgba = np.dstack(
        [np.clip(cleaned_rgb, 0, 255), np.clip(alpha_values, 0, 255)]
    ).astype(np.uint8)
    return Image.fromarray(rgba, "RGBA")


def normalize_whole_object(
    candidate: Image.Image,
    canvas_size: tuple[int, int],
    margin: int,
) -> tuple[Image.Image, dict[str, object]]:
    alpha = candidate.getchannel("A")
    bbox = alpha.point(lambda value: 255 if value > 4 else 0).getbbox()
    if bbox is None:
        raise RuntimeError("candidate has no visible pixels")
    object_image = candidate.crop(bbox)
    available = (canvas_size[0] - margin * 2, canvas_size[1] - margin * 2)
    scale = min(1.0, available[0] / object_image.width, available[1] / object_image.height)
    if scale < 1.0:
        new_size = (
            max(1, round(object_image.width * scale)),
            max(1, round(object_image.height * scale)),
        )
        object_image = object_image.resize(new_size, Image.Resampling.LANCZOS)
    origin = (
        (canvas_size[0] - object_image.width) // 2,
        (canvas_size[1] - object_image.height) // 2,
    )
    transparent_margins = (
        origin[0],
        origin[1],
        canvas_size[0] - origin[0] - object_image.width,
        canvas_size[1] - origin[1] - object_image.height,
    )
    if min(transparent_margins) < margin:
        raise RuntimeError(
            f"normalized margins {transparent_margins} are below {margin}px"
        )
    canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    canvas.alpha_composite(object_image, origin)
    return canvas, {
        "source_visible_bbox": list(bbox),
        "normalized_object_size": list(object_image.size),
        "normalized_origin": list(origin),
        "transparent_margins_ltrb": list(transparent_margins),
        "scale": scale,
    }


def main() -> None:
    args = parse_args()
    ensure_parent([args.output, args.metrics, args.debug_mask])
    source = Image.open(args.input).convert("RGB")
    source_rgb = np.asarray(source, dtype=np.uint8)
    hard_mask = build_seed(source_rgb, args)
    candidate = decontaminated_rgba(
        source,
        hard_mask,
        args.edge_radius,
        args.edge_color_radius,
        args.edge_color_inset,
    )
    normalized, placement = normalize_whole_object(candidate, args.canvas, args.margin)
    normalized.save(args.output, format="PNG", optimize=False, compress_level=9)
    if args.debug_mask:
        hard_mask.save(args.debug_mask, format="PNG", optimize=False, compress_level=9)

    alpha = np.asarray(normalized.getchannel("A"), dtype=np.uint8)
    metrics = {
        "schema": "aeui-chat-full-frame-alpha-cleanup-v1",
        "input": {
            "path": str(args.input.resolve()),
            "sha256": sha256(args.input),
            "size": list(source.size),
            "mode": Image.open(args.input).mode,
        },
        "output": {
            "path": str(args.output.resolve()),
            "sha256": sha256(args.output),
            "size": list(normalized.size),
            "mode": normalized.mode,
            "visible_bbox": list(normalized.getbbox() or ()),
            "opaque_pixels": int(np.count_nonzero(alpha == 255)),
            "partial_pixels": int(np.count_nonzero((alpha > 0) & (alpha < 255))),
            "transparent_pixels": int(np.count_nonzero(alpha == 0)),
        },
        "parameters": {
            "canvas": list(args.canvas),
            "margin": args.margin,
            "minimum_threshold": args.minimum_threshold,
            "chroma_threshold": args.chroma_threshold,
            "chroma_luma_ceiling": args.chroma_luma_ceiling,
            "close_radius": args.close_radius,
            "edge_radius": args.edge_radius,
            "edge_color_radius": args.edge_color_radius,
            "edge_color_inset": args.edge_color_inset,
        },
        "placement": placement,
        "provenance": {
            "candidate_pixels": "only the generated attempt-02 RGB candidate",
            "old_source_pixels": False,
            "old_masks": False,
            "operation": "deterministic whole-candidate alpha cleanup and normalization",
        },
    }
    args.metrics.write_text(
        json.dumps(metrics, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(args.output.resolve())
    print(args.metrics.resolve())


if __name__ == "__main__":
    main()
