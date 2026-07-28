"""Build the Turtle WoW runtime chat-book texture from a generated master."""

from __future__ import annotations

import argparse
from collections import deque
from pathlib import Path

from PIL import Image

NINE_SLICE_SOURCE = {
    "left": 114,
    "right": 866,
    "upper": 94,
    "lower": 502,
    "bottom": 586,
}

NINE_SLICE_BORDER = {
    "left": 52,
    "right": 52,
    "top": 76,
    "bottom": 74,
}


def remove_connected_black_background(
    image: Image.Image,
    threshold: int,
    transparent_point: int,
) -> Image.Image:
    """Remove only near-black pixels connected to the outside image border."""

    rgb = image.convert("RGB")
    width, height = rgb.size
    pixels = rgb.load()
    visited = bytearray(width * height)
    queue: deque[tuple[int, int]] = deque()

    def eligible(x: int, y: int) -> bool:
        red, green, blue = pixels[x, y]
        return max(red, green, blue) <= threshold

    def enqueue(x: int, y: int) -> None:
        offset = y * width + x
        if visited[offset] or not eligible(x, y):
            return
        visited[offset] = 1
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

    rgba = rgb.convert("RGBA")
    rgba_pixels = rgba.load()
    alpha_range = max(1, threshold - transparent_point)

    for y in range(height):
        row_offset = y * width
        for x in range(width):
            if not visited[row_offset + x]:
                continue
            value = max(pixels[x, y])
            alpha = int(
                max(0, min(255, (value - transparent_point) * 255 / alpha_range))
            )
            red, green, blue, _ = rgba_pixels[x, y]
            rgba_pixels[x, y] = (red, green, blue, alpha)

    return rgba


def crop_to_alpha(image: Image.Image, padding: int) -> Image.Image:
    alpha = image.getchannel("A")
    bounds = alpha.getbbox()
    if bounds is None:
        raise ValueError("Background removal produced an empty image.")

    left, top, right, bottom = bounds
    left = max(0, left - padding)
    top = max(0, top - padding)
    right = min(image.width, right + padding)
    bottom = min(image.height, bottom + padding)
    return image.crop((left, top, right, bottom))


def build_runtime_canvas(
    image: Image.Image,
    canvas_size: int,
) -> tuple[Image.Image, int]:
    aspect = image.width / image.height
    content_width = canvas_size
    content_height = max(1, round(content_width / aspect))

    if content_height > canvas_size:
        content_height = canvas_size
        content_width = max(1, round(content_height * aspect))

    resized = image.resize((content_width, content_height), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    x = (canvas_size - content_width) // 2
    canvas.alpha_composite(resized, (x, 0))
    return canvas, content_height


def build_nine_slice_preview(
    runtime: Image.Image,
    width: int,
    height: int,
) -> Image.Image:
    """Compose the runtime texture with the same nine-slice cuts used by Lua."""

    source = NINE_SLICE_SOURCE
    border = NINE_SLICE_BORDER
    output = Image.new("RGBA", (width, height), (0, 0, 0, 0))

    source_columns = (
        (0, source["left"]),
        (source["left"], source["right"]),
        (source["right"], runtime.width),
    )
    source_rows = (
        (0, source["upper"]),
        (source["upper"], source["lower"]),
        (source["lower"], source["bottom"]),
    )
    target_columns = (
        (0, border["left"]),
        (border["left"], width - border["right"]),
        (width - border["right"], width),
    )
    target_rows = (
        (0, border["top"]),
        (border["top"], height - border["bottom"]),
        (height - border["bottom"], height),
    )

    for row in range(3):
        for column in range(3):
            source_left, source_right = source_columns[column]
            source_top, source_bottom = source_rows[row]
            target_left, target_right = target_columns[column]
            target_top, target_bottom = target_rows[row]

            patch = runtime.crop(
                (source_left, source_top, source_right, source_bottom)
            )
            patch = patch.resize(
                (target_right - target_left, target_bottom - target_top),
                Image.Resampling.LANCZOS,
            )
            output.alpha_composite(patch, (target_left, target_top))

    return output


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--runtime-tga", required=True, type=Path)
    parser.add_argument("--alpha-master", required=True, type=Path)
    parser.add_argument("--runtime-preview", required=True, type=Path)
    parser.add_argument("--canvas-size", type=int, default=512)
    parser.add_argument("--nineslice-preview", type=Path)
    parser.add_argument("--preview-width", type=int, default=751)
    parser.add_argument("--preview-height", type=int, default=590)
    parser.add_argument("--threshold", type=int, default=18)
    parser.add_argument("--transparent-point", type=int, default=2)
    parser.add_argument("--padding", type=int, default=4)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    source = Image.open(args.input)
    alpha_master = crop_to_alpha(
        remove_connected_black_background(
            source,
            threshold=args.threshold,
            transparent_point=args.transparent_point,
        ),
        padding=args.padding,
    )
    runtime, content_height = build_runtime_canvas(alpha_master, args.canvas_size)

    for output in (args.runtime_tga, args.alpha_master, args.runtime_preview):
        output.parent.mkdir(parents=True, exist_ok=True)

    alpha_master.save(args.alpha_master, format="PNG", optimize=True)
    runtime.save(args.runtime_preview, format="PNG", optimize=True)
    runtime.save(args.runtime_tga, format="TGA")
    if args.nineslice_preview:
        args.nineslice_preview.parent.mkdir(parents=True, exist_ok=True)
        build_nine_slice_preview(
            runtime,
            width=args.preview_width,
            height=args.preview_height,
        ).save(args.nineslice_preview, format="PNG", optimize=True)

    ratio = content_height / args.canvas_size
    print(
        f"source={source.width}x{source.height} "
        f"master={alpha_master.width}x{alpha_master.height} "
        f"runtime={args.canvas_size}x{args.canvas_size} "
        f"content_height={content_height} texcoord_bottom={ratio:.9f}"
    )


if __name__ == "__main__":
    main()
