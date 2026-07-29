#!/usr/bin/env python3
"""Build review-only Turtle WoW runtime textures from V3 chat artwork.

The tracked A/B/C masters remain the visual source. This script performs only
deterministic validation, cropping, scaling, atlas packing and TGA conversion.
Its outputs are migration artifacts until Lua integration and in-game review
are complete.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets" / "source" / "chat" / "v3"
GENERATED_DIR = ROOT / "generated" / "chat" / "v3"

RESAMPLE = Image.Resampling.LANCZOS

BOOK_CANVAS = (1024, 1024)
BOOK_SOURCE_CUTS = (215, 100, 1485, 860)
BOOK_RUNTIME_CUTS = {
    "left": 137,
    "top": 64,
    "right": 946,
    "bottom_inner": 548,
    "content_bottom": 623,
}
BOOK_RUNTIME_BORDER = {
    "left": 30,
    "top": 28,
    "right": 30,
    "bottom": 28,
}

TAB_SHELF_BOX = (39, 196, 1733, 298)
TAB_COMMON_Y = (508, 703)
TAB_BOXES = (
    (27, TAB_COMMON_Y[0], 426, TAB_COMMON_Y[1]),
    (465, TAB_COMMON_Y[0], 864, TAB_COMMON_Y[1]),
    (906, TAB_COMMON_Y[0], 1307, TAB_COMMON_Y[1]),
    (1345, TAB_COMMON_Y[0], 1744, TAB_COMMON_Y[1]),
)

INPUT_NORMAL_BOX = (51, 187, 1437, 363)
INPUT_FOCUS_BOX = (51, 448, 1437, 625)
SEAL_BOX = (1048, 686, 1160, 864)

EXPECTED_SOURCE_SIZES = {
    "frame": (1608, 978),
    "tabs": (1774, 887),
    "controls": (1536, 1024),
}


def validate_source(
    name: str,
    image: Image.Image,
    crop_boxes: tuple[tuple[int, int, int, int], ...],
) -> None:
    expected = EXPECTED_SOURCE_SIZES[name]
    if image.size != expected:
        raise ValueError(f"{name} source must be {expected}, got {image.size}")
    minimum, maximum = image.getchannel("A").getextrema()
    if minimum != 0 or maximum != 255:
        raise ValueError(
            f"{name} source must contain transparent and opaque pixels: "
            f"{(minimum, maximum)}"
        )
    for box in crop_boxes:
        left, top, right, bottom = box
        if left < 0 or top < 0 or right > image.width or bottom > image.height:
            raise ValueError(f"{name} crop is outside source bounds: {box}")
        if left >= right or top >= bottom:
            raise ValueError(f"{name} crop is empty: {box}")


def is_power_of_two(value: int) -> bool:
    return value > 0 and value & (value - 1) == 0


def validate_runtime_image(name: str, image: Image.Image) -> None:
    if not is_power_of_two(image.width) or not is_power_of_two(image.height):
        raise ValueError(f"{name} is not power-of-two: {image.size}")
    if image.mode != "RGBA":
        raise ValueError(f"{name} is not RGBA: {image.mode}")
    minimum, maximum = image.getchannel("A").getextrema()
    if minimum != 0 or maximum != 255:
        raise ValueError(
            f"{name} must contain transparent and opaque pixels: {(minimum, maximum)}"
        )


def save_tga(image: Image.Image, destination: Path) -> None:
    validate_runtime_image(destination.name, image)
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, format="TGA")


def save_png(image: Image.Image, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, format="PNG", optimize=True)


def build_book(frame: Image.Image) -> Image.Image:
    content_height = BOOK_RUNTIME_CUTS["content_bottom"]
    resized = frame.resize((BOOK_CANVAS[0], content_height), RESAMPLE)
    atlas = Image.new("RGBA", BOOK_CANVAS, (0, 0, 0, 0))
    atlas.alpha_composite(resized, (0, 0))
    return atlas


def build_book_preview(
    atlas: Image.Image,
    target_size: tuple[int, int] = (440, 320),
) -> Image.Image:
    target_w, target_h = target_size
    cuts = BOOK_RUNTIME_CUTS
    borders = BOOK_RUNTIME_BORDER
    source_x = (0, cuts["left"], cuts["right"], atlas.width)
    source_y = (
        0,
        cuts["top"],
        cuts["bottom_inner"],
        cuts["content_bottom"],
    )
    target_x = (
        0,
        borders["left"],
        target_w - borders["right"],
        target_w,
    )
    target_y = (
        0,
        borders["top"],
        target_h - borders["bottom"],
        target_h,
    )
    preview = Image.new("RGBA", target_size, (0, 0, 0, 0))
    for row in range(3):
        for column in range(3):
            source_box = (
                source_x[column],
                source_y[row],
                source_x[column + 1],
                source_y[row + 1],
            )
            target_box = (
                target_x[column],
                target_y[row],
                target_x[column + 1],
                target_y[row + 1],
            )
            patch = atlas.crop(source_box)
            patch = patch.resize(
                (
                    target_box[2] - target_box[0],
                    target_box[3] - target_box[1],
                ),
                RESAMPLE,
            )
            preview.alpha_composite(patch, (target_box[0], target_box[1]))
    return preview


def build_tab_atlas(tabs_sheet: Image.Image) -> Image.Image:
    atlas = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    for index, box in enumerate(TAB_BOXES):
        # All states use the same source canvas.  The selected state already
        # rises inside that canvas, so runtime geometry never has to move.
        state = tabs_sheet.crop(box).resize((256, 124), RESAMPLE)
        atlas.alpha_composite(state, (0, index * 128 + 2))
    return atlas


def build_tab_shelf(tabs_sheet: Image.Image) -> Image.Image:
    atlas = Image.new("RGBA", (1024, 64), (0, 0, 0, 0))
    shelf = tabs_sheet.crop(TAB_SHELF_BOX).resize((1024, 62), RESAMPLE)
    atlas.alpha_composite(shelf, (0, 1))
    return atlas


def build_input_atlas(controls_sheet: Image.Image) -> Image.Image:
    atlas = Image.new("RGBA", (1024, 256), (0, 0, 0, 0))
    for index, box in enumerate((INPUT_NORMAL_BOX, INPUT_FOCUS_BOX)):
        strip = controls_sheet.crop(box).resize((1008, 120), RESAMPLE)
        atlas.alpha_composite(strip, (8, index * 128 + 4))
    return atlas


def build_seal(controls_sheet: Image.Image) -> Image.Image:
    atlas = Image.new("RGBA", (64, 128), (0, 0, 0, 0))
    seal = controls_sheet.crop(SEAL_BOX)
    seal.thumbnail((56, 120), RESAMPLE)
    x = (atlas.width - seal.width) // 2
    y = (atlas.height - seal.height) // 2
    atlas.alpha_composite(seal, (x, y))
    return atlas


def checkerboard(size: tuple[int, int]) -> Image.Image:
    output = Image.new("RGBA", size, (34, 28, 21, 255))
    draw = ImageDraw.Draw(output)
    tile = 16
    for y in range(0, size[1], tile):
        for x in range(0, size[0], tile):
            if (x // tile + y // tile) % 2 == 0:
                draw.rectangle(
                    (x, y, x + tile - 1, y + tile - 1),
                    fill=(50, 42, 32, 255),
                )
    return output


def build_atlas_preview(
    book_preview: Image.Image,
    tab_atlas: Image.Image,
    shelf: Image.Image,
    input_atlas: Image.Image,
    seal: Image.Image,
) -> Image.Image:
    preview = checkerboard((1024, 768))
    preview.alpha_composite(book_preview.resize((440, 320), RESAMPLE), (24, 24))
    preview.alpha_composite(tab_atlas.resize((384, 384), RESAMPLE), (536, 20))
    preview.alpha_composite(shelf.resize((456, 29), RESAMPLE), (24, 380))
    preview.alpha_composite(input_atlas.resize((456, 114), RESAMPLE), (24, 438))
    preview.alpha_composite(seal.resize((32, 64), RESAMPLE), (536, 438))
    return preview


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--frame",
        type=Path,
        default=SOURCE_DIR / "ChatBookFrame_Master_v3.png",
    )
    parser.add_argument(
        "--tabs",
        type=Path,
        default=SOURCE_DIR / "ChatTabs_Master_v3.png",
    )
    parser.add_argument(
        "--controls",
        type=Path,
        default=SOURCE_DIR / "ChatControls_Master_v3.png",
    )
    parser.add_argument(
        "--runtime-dir",
        type=Path,
        default=GENERATED_DIR / "runtime-review",
    )
    parser.add_argument(
        "--artifact-dir",
        type=Path,
        default=GENERATED_DIR / "runtime-artifacts",
        help="Directory for review previews and the generated UV manifest",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    frame = Image.open(args.frame).convert("RGBA")
    tabs_sheet = Image.open(args.tabs).convert("RGBA")
    controls_sheet = Image.open(args.controls).convert("RGBA")

    validate_source("frame", frame, (BOOK_SOURCE_CUTS,))
    validate_source("tabs", tabs_sheet, (TAB_SHELF_BOX,) + TAB_BOXES)
    validate_source(
        "controls",
        controls_sheet,
        (INPUT_NORMAL_BOX, INPUT_FOCUS_BOX, SEAL_BOX),
    )

    book = build_book(frame)
    book_preview = build_book_preview(book)
    tab_atlas = build_tab_atlas(tabs_sheet)
    shelf = build_tab_shelf(tabs_sheet)
    input_atlas = build_input_atlas(controls_sheet)
    seal = build_seal(controls_sheet)

    runtime = args.runtime_dir
    save_tga(book, runtime / "ChatBookFrameV3.tga")
    save_tga(tab_atlas, runtime / "ChatTabAtlasV3.tga")
    save_tga(shelf, runtime / "ChatTabShelfV3.tga")
    save_tga(input_atlas, runtime / "ChatInputAtlasV3.tga")
    save_tga(seal, runtime / "ChatUnreadSealV3.tga")

    artifacts = args.artifact_dir
    save_png(book, artifacts / "ChatBookFrame_RuntimeAtlas_v3.png")
    save_png(book_preview, artifacts / "ChatBookFrame_440x320_v3.png")
    save_png(
        build_atlas_preview(
            book_preview,
            tab_atlas,
            shelf,
            input_atlas,
            seal,
        ),
        artifacts / "ChatRuntimeAtlasesPreview_v3.png",
    )

    manifest = {
        "schema": 1,
        "status": "migration-review-only",
        "sources": {
            "frame": {
                "file": args.frame.name,
                "size": frame.size,
                "nine_slice_cuts": BOOK_SOURCE_CUTS,
            },
            "tabs": {
                "file": args.tabs.name,
                "size": tabs_sheet.size,
                "shelf_crop": TAB_SHELF_BOX,
                "state_crops": TAB_BOXES,
            },
            "controls": {
                "file": args.controls.name,
                "size": controls_sheet.size,
                "input_normal_crop": INPUT_NORMAL_BOX,
                "input_focus_crop": INPUT_FOCUS_BOX,
                "seal_crop": SEAL_BOX,
            },
        },
        "book": {
            "canvas": BOOK_CANVAS,
            "cuts": BOOK_RUNTIME_CUTS,
            "runtime_border": BOOK_RUNTIME_BORDER,
        },
        "tab": {
            "atlas": (512, 512),
            "state_rows": {
                "normal": (0.0, 0.25),
                "hover": (0.25, 0.5),
                "selected": (0.5, 0.75),
                "disabled": (0.75, 1.0),
            },
            "x": (0.0, 0.09375, 0.40625, 0.5),
            "runtime": {"height": 42, "left": 16, "right": 16},
        },
        "input": {
            "atlas": (1024, 256),
            "state_rows": {"normal": (0.0, 0.5), "focus": (0.5, 1.0)},
            "x_pixels": (8, 121, 932, 1016),
            "runtime": {"height": 25, "left": 28, "right": 20},
        },
        "seal": {"atlas": (64, 128), "runtime": (14, 22)},
    }
    manifest_path = artifacts / "ChatRuntimeManifest_v3.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(json.dumps(manifest, ensure_ascii=False))


if __name__ == "__main__":
    main()
