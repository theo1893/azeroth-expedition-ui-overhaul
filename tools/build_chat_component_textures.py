"""Build component-level chat skin textures from the locked chat-book master."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance


DARK = (35, 20, 10, 255)
DARK_SOFT = (52, 30, 14, 230)
BRASS = (132, 91, 35, 255)
BRASS_LIGHT = (190, 139, 62, 230)
STITCH = (199, 153, 83, 190)
WAX = (104, 24, 19, 255)
WAX_LIGHT = (154, 48, 31, 255)
LEATHER_BOX = (1408, 470, 1518, 735)


def material(
    source: Image.Image,
    box: tuple[int, int, int, int],
    size: tuple[int, int],
    brightness: float = 1.0,
    rotate: int = 0,
) -> Image.Image:
    patch = source.crop(box)
    if rotate:
        patch = patch.rotate(rotate, expand=True)
    patch = patch.resize(size, Image.Resampling.LANCZOS).convert("RGBA")
    if brightness != 1.0:
        patch = ImageEnhance.Brightness(patch).enhance(brightness)
    return patch


def paste_masked(
    canvas: Image.Image,
    fill: Image.Image,
    points: list[tuple[int, int]],
) -> Image.Image:
    mask = Image.new("L", canvas.size, 0)
    ImageDraw.Draw(mask).polygon(points, fill=255)
    canvas.alpha_composite(
        Image.composite(fill, Image.new("RGBA", canvas.size), mask)
    )
    return mask


def scaled_points(
    points: list[tuple[int, int]],
    scale: int,
) -> list[tuple[int, int]]:
    return [(x * scale, y * scale) for x, y in points]


def draw_open_tab_border(
    draw: ImageDraw.ImageDraw,
    points: list[tuple[int, int]],
    scale: int,
) -> None:
    border_path = points[1:]
    draw.line(border_path, fill=DARK, width=5 * scale)
    draw.line(border_path, fill=BRASS, width=2 * scale)


def draw_stitches(
    draw: ImageDraw.ImageDraw,
    raised: bool,
    scale: int,
) -> None:
    y = 9 if raised else 14
    for x in range(20, 110, 11):
        draw.line(
            (x * scale, y * scale, (x + 6) * scale, y * scale),
            fill=STITCH,
            width=scale,
        )
    for y_pos in range(y + 10, 55, 10):
        draw.line(
            (
                11 * scale,
                y_pos * scale,
                11 * scale,
                (y_pos + 5) * scale,
            ),
            fill=STITCH,
            width=scale,
        )
        draw.line(
            (
                117 * scale,
                y_pos * scale,
                117 * scale,
                (y_pos + 5) * scale,
            ),
            fill=STITCH,
            width=scale,
        )


def build_tab(source: Image.Image, state: str, scale: int) -> Image.Image:
    canvas = Image.new("RGBA", (128 * scale, 64 * scale), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)
    raised = state == "selected"

    if raised:
        base_points = [
            (4, 63),
            (5, 16),
            (13, 6),
            (24, 3),
            (105, 3),
            (116, 7),
            (123, 17),
            (124, 63),
        ]
    else:
        base_points = [
            (6, 63),
            (7, 21),
            (14, 11),
            (24, 8),
            (104, 8),
            (115, 12),
            (121, 22),
            (122, 63),
        ]

    points = scaled_points(base_points, scale)
    shadow = [
        ((x + 2) * scale, min(63, y + 2) * scale)
        for x, y in base_points
    ]
    draw.polygon(shadow, fill=(0, 0, 0, 115))

    if raised:
        fill = material(
            source,
            (420, 260, 1120, 650),
            canvas.size,
            brightness=0.83,
        )
    else:
        brightness = 1.18 if state == "hover" else 0.72
        fill = material(
            source,
            LEATHER_BOX,
            canvas.size,
            brightness=brightness,
            rotate=90,
        )

    paste_masked(canvas, fill, points)
    draw = ImageDraw.Draw(canvas)
    draw_open_tab_border(draw, points, scale)
    draw_stitches(draw, raised, scale)

    for x, y in (
        (17, 17 if not raised else 12),
        (111, 17 if not raised else 12),
    ):
        draw.ellipse(
            (
                (x - 2) * scale,
                (y - 2) * scale,
                (x + 2) * scale,
                (y + 2) * scale,
            ),
            fill=BRASS_LIGHT,
            outline=DARK,
            width=scale,
        )

    if raised:
        draw.line(
            (13 * scale, 59 * scale, 117 * scale, 59 * scale),
            fill=(104, 68, 31, 190),
            width=2 * scale,
        )

    return canvas


def build_tab_shelf(source: Image.Image, scale: int) -> Image.Image:
    canvas = Image.new("RGBA", (512 * scale, 64 * scale), (0, 0, 0, 0))
    strip = material(
        source,
        LEATHER_BOX,
        (512 * scale, 46 * scale),
        brightness=0.62,
        rotate=90,
    )
    canvas.alpha_composite(strip, (0, 18 * scale))
    draw = ImageDraw.Draw(canvas)
    draw.line(
        (0, 18 * scale, 511 * scale, 18 * scale),
        fill=DARK,
        width=5 * scale,
    )
    draw.line(
        (0, 20 * scale, 511 * scale, 20 * scale),
        fill=BRASS,
        width=2 * scale,
    )
    draw.line(
        (0, 60 * scale, 511 * scale, 60 * scale),
        fill=DARK,
        width=4 * scale,
    )
    draw.line(
        (0, 58 * scale, 511 * scale, 58 * scale),
        fill=BRASS,
        width=scale,
    )
    for x in range(12, 505, 16):
        draw.line(
            (x * scale, 26 * scale, (x + 8) * scale, 26 * scale),
            fill=STITCH,
            width=scale,
        )
    return canvas


def build_panel_segment(source: Image.Image, scale: int) -> Image.Image:
    canvas = Image.new("RGBA", (128 * scale, 32 * scale), (0, 0, 0, 0))
    points = scaled_points(
        [
            (2, 7),
            (8, 2),
            (120, 2),
            (126, 7),
            (124, 27),
            (118, 30),
            (9, 30),
            (3, 27),
        ],
        scale,
    )
    fill = material(
        source,
        LEATHER_BOX,
        canvas.size,
        brightness=0.58,
        rotate=90,
    )
    paste_masked(canvas, fill, points)
    draw = ImageDraw.Draw(canvas)
    draw.line(points + [points[0]], fill=DARK, width=4 * scale)
    draw.line(points + [points[0]], fill=BRASS, width=scale)
    draw.line(
        (12 * scale, 6 * scale, 116 * scale, 6 * scale),
        fill=STITCH,
        width=scale,
    )
    return canvas


def build_input_strip(source: Image.Image, scale: int) -> Image.Image:
    canvas = Image.new("RGBA", (256 * scale, 32 * scale), (0, 0, 0, 0))
    points = scaled_points(
        [
            (3, 5),
            (10, 2),
            (247, 2),
            (253, 6),
            (252, 27),
            (245, 30),
            (9, 30),
            (3, 26),
        ],
        scale,
    )
    fill = material(
        source,
        (420, 260, 1120, 650),
        canvas.size,
        brightness=0.68,
    )
    paste_masked(canvas, fill, points)
    draw = ImageDraw.Draw(canvas)
    draw.line(points + [points[0]], fill=DARK, width=4 * scale)
    draw.line(points + [points[0]], fill=BRASS, width=scale)
    draw.line(
        (15 * scale, 23 * scale, 241 * scale, 23 * scale),
        fill=(76, 45, 21, 210),
        width=scale,
    )
    return canvas


def build_wax_seal(scale: int) -> Image.Image:
    canvas = Image.new("RGBA", (32 * scale, 32 * scale), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)
    points = scaled_points(
        [
            (16, 2),
            (22, 5),
            (27, 10),
            (29, 17),
            (25, 24),
            (19, 29),
            (11, 28),
            (5, 24),
            (2, 17),
            (5, 9),
            (10, 4),
        ],
        scale,
    )
    draw.polygon(points, fill=WAX, outline=DARK)
    draw.ellipse(
        (7 * scale, 7 * scale, 25 * scale, 25 * scale),
        fill=WAX_LIGHT,
        outline=(72, 15, 12, 255),
        width=2 * scale,
    )
    draw.line(
        (11 * scale, 16 * scale, 21 * scale, 16 * scale),
        fill=(84, 19, 14, 255),
        width=2 * scale,
    )
    draw.line(
        (16 * scale, 11 * scale, 16 * scale, 21 * scale),
        fill=(84, 19, 14, 255),
        width=2 * scale,
    )
    return canvas


def save_tga(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="TGA")


def build_preview(
    assets: dict[str, Image.Image],
    destination: Path,
    scale: int,
) -> None:
    preview = Image.new(
        "RGBA",
        (512 * scale, 256 * scale),
        (17, 12, 8, 255),
    )
    preview.alpha_composite(assets["TabNormal"], (16 * scale, 16 * scale))
    preview.alpha_composite(assets["TabHover"], (152 * scale, 16 * scale))
    preview.alpha_composite(assets["TabSelected"], (288 * scale, 16 * scale))
    preview.alpha_composite(assets["TabShelf"], (0, 84 * scale))
    preview.alpha_composite(assets["PanelSegment"], (16 * scale, 164 * scale))
    preview.alpha_composite(assets["InputStrip"], (152 * scale, 164 * scale))
    preview.alpha_composite(assets["WaxSeal"], (424 * scale, 164 * scale))
    destination.parent.mkdir(parents=True, exist_ok=True)
    preview.save(destination, format="PNG", optimize=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--preview", required=True, type=Path)
    parser.add_argument("--scale", type=int, default=2)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    source = Image.open(args.input).convert("RGBA")
    scale = max(1, args.scale)
    assets = {
        "TabNormal": build_tab(source, "normal", scale),
        "TabHover": build_tab(source, "hover", scale),
        "TabSelected": build_tab(source, "selected", scale),
        "TabShelf": build_tab_shelf(source, scale),
        "PanelSegment": build_panel_segment(source, scale),
        "InputStrip": build_input_strip(source, scale),
        "WaxSeal": build_wax_seal(scale),
    }

    for name, image in assets.items():
        save_tga(image, args.output_dir / f"Chat{name}.tga")

    build_preview(assets, args.preview, scale)
    print(
        f"built {len(assets)} pfUI component textures at "
        f"{scale}x scale in {args.output_dir}"
    )


if __name__ == "__main__":
    main()
