#!/usr/bin/env python3
"""Deterministic CHAT.COPY.V1.2 candidate construction and review helpers.

This tool never invents final painted pixels. It derives the copy surface from the
accepted Chat V3 parchment, creates geometry/material scaffolds for fixed ImageGen
editing, applies the predeclared state masks, and assembles review previews.
"""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
SOURCE_FRAME = ROOT / "assets/source/chat/v3/ChatBookFrame_Master_v3.png"
OUTPUT_ROOT = ROOT / "generated/chat/copy/v1_2"
A_CANDIDATE = OUTPUT_ROOT / "a/CHAT.COPY.SURFACE.V1_2.candidate.png"
INPUT_DIR = OUTPUT_ROOT / "inputs"
MASK_DIR = INPUT_DIR / "masks"
PREVIEW_DIR = OUTPUT_ROOT / "previews"

EXPECTED_SOURCE_SHA256 = (
    "f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057"
)
EXPECTED_SOURCE_SIZE = (1608, 978)
A_CROP = (270, 130, 1338, 827)
A_SIZE = (1140, 744)
A_SLICE_X = (0, 24, 1116, 1140)
A_SLICE_Y = (0, 24, 720, 744)

CANVAS_SIZE = (1024, 1024)
OUTER_BOX = (336, 304, 688, 720)
CHROMA_GREEN = (0, 255, 0)
PARCHMENT_SHADOW = (118, 81, 46)
DEEP_WALNUT = (40, 24, 14)
INK_BROWN = (36, 23, 15)

LOWER_LEAF = ((336, 348), (674, 332), (687, 719), (344, 711))
UPPER_CLOSED = ((370, 328), (650, 340), (638, 672), (358, 690))
UPPER_OPEN = ((370, 328), (650, 340), (678, 684), (350, 704))
TOP_CLAMP = (
    (420, 312),
    (584, 304),
    (606, 338),
    (592, 378),
    (414, 370),
    (402, 340),
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def save_png(image: Image.Image, path: Path) -> None:
    ensure_parent(path)
    image.save(path, format="PNG", compress_level=9)


def require_accepted_frame() -> Image.Image:
    if sha256(SOURCE_FRAME) != EXPECTED_SOURCE_SHA256:
        raise RuntimeError(f"Unexpected source SHA-256: {SOURCE_FRAME}")
    image = Image.open(SOURCE_FRAME)
    if image.size != EXPECTED_SOURCE_SIZE or image.mode != "RGBA":
        raise RuntimeError(
            f"Expected {EXPECTED_SOURCE_SIZE} RGBA, got {image.size} {image.mode}"
        )
    return image


def require_a_candidate() -> Image.Image:
    if not A_CANDIDATE.is_file():
        raise RuntimeError("Build A before constructing B scaffolds.")
    image = Image.open(A_CANDIDATE).convert("RGBA")
    if image.size != A_SIZE:
        raise RuntimeError(f"Expected A size {A_SIZE}, got {image.size}")
    alpha = image.getchannel("A")
    if alpha.getextrema() != (255, 255):
        raise RuntimeError("A candidate must remain fully opaque.")
    return image


def resize_tile(tile: Image.Image, size: tuple[int, int]) -> Image.Image:
    if tile.size == size:
        return tile.copy()
    return tile.resize(size, Image.Resampling.LANCZOS)


def render_nine_slice(
    source: Image.Image,
    target_size: tuple[int, int],
    destination_border: int = 8,
) -> Image.Image:
    target_width, target_height = target_size
    if target_width <= destination_border * 2:
        raise ValueError("Target width is smaller than the fixed borders.")
    if target_height <= destination_border * 2:
        raise ValueError("Target height is smaller than the fixed borders.")

    destination_x = (
        0,
        destination_border,
        target_width - destination_border,
        target_width,
    )
    destination_y = (
        0,
        destination_border,
        target_height - destination_border,
        target_height,
    )
    output = Image.new("RGBA", target_size, (0, 0, 0, 0))
    for row in range(3):
        for column in range(3):
            source_box = (
                A_SLICE_X[column],
                A_SLICE_Y[row],
                A_SLICE_X[column + 1],
                A_SLICE_Y[row + 1],
            )
            destination_box = (
                destination_x[column],
                destination_y[row],
                destination_x[column + 1],
                destination_y[row + 1],
            )
            tile = source.crop(source_box)
            tile = resize_tile(
                tile,
                (
                    destination_box[2] - destination_box[0],
                    destination_box[3] - destination_box[1],
                ),
            )
            output.alpha_composite(tile, destination_box[:2])
    return output


def build_a() -> None:
    source = require_accepted_frame()
    crop = source.crop(A_CROP)
    if crop.size != (1068, 697):
        raise RuntimeError(f"Unexpected crop size: {crop.size}")
    candidate = crop.resize(A_SIZE, Image.Resampling.LANCZOS)
    candidate.putalpha(255)
    save_png(candidate, A_CANDIDATE)

    real_size = render_nine_slice(candidate, (380, 248))
    expanded_size = render_nine_slice(candidate, (480, 348))
    save_png(
        real_size,
        PREVIEW_DIR / "CHAT.COPY.SURFACE.V1_2.nineslice.380x248.png",
    )
    save_png(
        expanded_size,
        PREVIEW_DIR / "CHAT.COPY.SURFACE.V1_2.nineslice.480x348.png",
    )

    safe_area = real_size.copy()
    draw = ImageDraw.Draw(safe_area)
    draw.rectangle((10, 8, 369, 239), outline=(170, 35, 28, 255), width=1)
    save_png(
        safe_area,
        PREVIEW_DIR / "CHAT.COPY.SURFACE.V1_2.text-safe.380x248.png",
    )


def polygon_mask(points: Iterable[tuple[int, int]]) -> Image.Image:
    mask = Image.new("L", CANVAS_SIZE, 0)
    ImageDraw.Draw(mask).polygon(tuple(points), fill=255)
    return mask


def shifted_mask(mask: Image.Image, x: int, y: int) -> Image.Image:
    return ImageChops.offset(mask, x, y).crop((0, 0, *CANVAS_SIZE))


def material_patch(
    source: Image.Image, crop: tuple[int, int, int, int]
) -> Image.Image:
    patch = source.crop(crop).resize(
        (OUTER_BOX[2] - OUTER_BOX[0], OUTER_BOX[3] - OUTER_BOX[1]),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("RGB", CANVAS_SIZE, CHROMA_GREEN)
    canvas.paste(patch.convert("RGB"), OUTER_BOX[:2])
    return canvas


def paste_masked(
    destination: Image.Image,
    source: Image.Image | tuple[int, int, int],
    mask: Image.Image,
) -> None:
    if isinstance(source, tuple):
        layer = Image.new("RGB", CANVAS_SIZE, source)
    else:
        layer = source
    destination.paste(layer, (0, 0), mask)


def state_masks(state: str) -> dict[str, Image.Image]:
    if state not in {"closed", "open"}:
        raise ValueError(f"Unknown state: {state}")
    lower = polygon_mask(LOWER_LEAF)
    upper = polygon_mask(UPPER_CLOSED if state == "closed" else UPPER_OPEN)
    clamp = polygon_mask(TOP_CLAMP)
    total = ImageChops.lighter(ImageChops.lighter(lower, upper), clamp)
    return {"lower": lower, "upper": upper, "clamp": clamp, "total": total}


def build_scaffold(state: str, paper: Image.Image) -> tuple[Image.Image, dict[str, Image.Image]]:
    masks = state_masks(state)
    lower_material = material_patch(paper, (0, 0, 600, 744))
    upper_material = material_patch(paper, (240, 120, 880, 700))
    canvas = Image.new("RGB", CANVAS_SIZE, CHROMA_GREEN)

    paste_masked(canvas, lower_material, masks["lower"])
    upper_shadow = ImageChops.multiply(
        shifted_mask(masks["upper"], 4, 6), masks["lower"]
    )
    paste_masked(canvas, PARCHMENT_SHADOW, upper_shadow)
    paste_masked(canvas, upper_material, masks["upper"])

    clamp_shadow = ImageChops.multiply(
        shifted_mask(masks["clamp"], 0, 7), masks["total"]
    )
    paste_masked(canvas, INK_BROWN, clamp_shadow)
    paste_masked(canvas, DEEP_WALNUT, masks["clamp"])
    return canvas, masks


def build_scaffolds() -> None:
    paper = require_a_candidate()
    for state in ("closed", "open"):
        scaffold, masks = build_scaffold(state, paper)
        if masks["total"].getbbox() != OUTER_BOX:
            raise RuntimeError(
                f"{state} mask bbox {masks['total'].getbbox()} != {OUTER_BOX}"
            )
        green = Image.new("RGB", CANVAS_SIZE, CHROMA_GREEN)
        outside = ImageChops.invert(masks["total"])
        difference = ImageChops.difference(scaffold, green)
        if any(
            ImageChops.multiply(channel, outside).getbbox()
            for channel in difference.split()
        ):
            raise RuntimeError(f"{state} scaffold changed pixels outside its mask.")
        state_upper = state.upper()
        save_png(
            scaffold,
            INPUT_DIR
            / f"CHAT.COPY.TOGGLE.{state_upper}.SCAFFOLD.V1_2.png",
        )
        for name, mask in masks.items():
            save_png(
                mask,
                MASK_DIR
                / f"CHAT.COPY.TOGGLE.{state_upper}.{name.upper()}.MASK.V1_2.png",
            )
        runtime = scaffold.crop(OUTER_BOX).resize(
            (22, 26), Image.Resampling.LANCZOS
        )
        save_png(
            runtime,
            PREVIEW_DIR
            / f"CHAT.COPY.TOGGLE.{state_upper}.SCAFFOLD.22x26.png",
        )


def require_transparent_candidate(path: Path) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    if image.size != CANVAS_SIZE:
        raise RuntimeError(f"Expected {CANVAS_SIZE}, got {image.size}: {path}")
    return image


def apply_mask(input_path: Path, state: str, output_path: Path) -> None:
    image = require_transparent_candidate(input_path)
    mask = state_masks(state)["total"]
    alpha = ImageChops.multiply(image.getchannel("A"), mask)
    image.putalpha(alpha)
    save_png(image, output_path)


def assemble_b2(b1_path: Path, b2_path: Path, output_path: Path) -> None:
    b1 = require_transparent_candidate(b1_path)
    b2 = require_transparent_candidate(b2_path)
    closed = state_masks("closed")
    opened = state_masks("open")

    b2.putalpha(ImageChops.multiply(b2.getchannel("A"), opened["total"]))

    not_closed_upper = ImageChops.invert(closed["upper"])
    not_open_upper = ImageChops.invert(opened["upper"])
    common_lower = ImageChops.multiply(
        closed["lower"], ImageChops.multiply(not_closed_upper, not_open_upper)
    )
    preserve = ImageChops.lighter(common_lower, closed["clamp"])
    preserve = ImageChops.multiply(preserve, b1.getchannel("A"))

    fixed = b1.copy()
    fixed.putalpha(preserve)
    b2.alpha_composite(fixed)
    save_png(b2, output_path)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("build-a")
    subparsers.add_parser("build-scaffolds")

    mask_parser = subparsers.add_parser("apply-mask")
    mask_parser.add_argument("--input", type=Path, required=True)
    mask_parser.add_argument("--state", choices=("closed", "open"), required=True)
    mask_parser.add_argument("--output", type=Path, required=True)

    assemble_parser = subparsers.add_parser("assemble-b2")
    assemble_parser.add_argument("--b1", type=Path, required=True)
    assemble_parser.add_argument("--b2", type=Path, required=True)
    assemble_parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.command == "build-a":
        build_a()
    elif args.command == "build-scaffolds":
        build_scaffolds()
    elif args.command == "apply-mask":
        apply_mask(args.input.resolve(), args.state, args.output.resolve())
    elif args.command == "assemble-b2":
        assemble_b2(args.b1.resolve(), args.b2.resolve(), args.output.resolve())


if __name__ == "__main__":
    main()
