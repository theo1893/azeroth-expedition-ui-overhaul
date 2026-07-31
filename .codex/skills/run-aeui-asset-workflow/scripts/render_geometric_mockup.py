#!/usr/bin/env python3
"""Render a deterministic UI direction mockup from simple geometric primitives."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageColor, ImageDraw, ImageFont


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Render a local, non-production PNG mockup from a JSON specification. "
            "Supported primitives: rect, rounded_rect, polygon, line, ellipse, text."
        )
    )
    parser.add_argument("spec", type=Path, help="JSON primitive specification")
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path.cwd(),
        help="base directory for repo-relative font paths (default: current directory)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="override the output path declared by the specification",
    )
    return parser.parse_args()


def color(value: str | None) -> tuple[int, ...] | None:
    if value is None:
        return None
    return ImageColor.getcolor(value, "RGBA")


def require_int_pair(value: Any, field: str) -> tuple[int, int]:
    if not isinstance(value, list) or len(value) != 2:
        raise ValueError(f"{field} must be a two-integer list")
    return int(value[0]), int(value[1])


def require_box(value: Any, field: str) -> tuple[int, int, int, int]:
    if not isinstance(value, list) or len(value) != 4:
        raise ValueError(f"{field} must be a four-integer list")
    return tuple(int(item) for item in value)


def load_fonts(
    definitions: dict[str, Any], repo_root: Path
) -> dict[str, ImageFont.FreeTypeFont]:
    fonts: dict[str, ImageFont.FreeTypeFont] = {}
    for name, definition in definitions.items():
        font_path = Path(definition["path"])
        if not font_path.is_absolute():
            font_path = repo_root / font_path
        fonts[name] = ImageFont.truetype(
            str(font_path), int(definition["size"]), layout_engine=ImageFont.Layout.BASIC
        )
    return fonts


def render_layer(
    draw: ImageDraw.ImageDraw,
    layer: dict[str, Any],
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> None:
    kind = layer["type"]
    fill = color(layer.get("fill"))
    outline = color(layer.get("outline"))
    width = int(layer.get("width", 1))

    if kind == "rect":
        draw.rectangle(
            require_box(layer["xy"], "rect.xy"),
            fill=fill,
            outline=outline,
            width=width,
        )
    elif kind == "rounded_rect":
        draw.rounded_rectangle(
            require_box(layer["xy"], "rounded_rect.xy"),
            radius=int(layer["radius"]),
            fill=fill,
            outline=outline,
            width=width,
        )
    elif kind == "polygon":
        points = [require_int_pair(point, "polygon point") for point in layer["points"]]
        draw.polygon(points, fill=fill, outline=outline)
        if outline is not None and width > 1:
            draw.line(points + [points[0]], fill=outline, width=width, joint="curve")
    elif kind == "line":
        points = [require_int_pair(point, "line point") for point in layer["points"]]
        draw.line(
            points,
            fill=fill,
            width=width,
            joint=layer.get("joint", "curve"),
        )
    elif kind == "ellipse":
        draw.ellipse(
            require_box(layer["xy"], "ellipse.xy"),
            fill=fill,
            outline=outline,
            width=width,
        )
    elif kind == "text":
        font_name = layer["font"]
        if font_name not in fonts:
            raise ValueError(f"unknown font alias: {font_name}")
        draw.text(
            require_int_pair(layer["xy"], "text.xy"),
            str(layer["text"]),
            font=fonts[font_name],
            fill=fill,
            anchor=layer.get("anchor"),
            stroke_width=int(layer.get("stroke_width", 0)),
            stroke_fill=color(layer.get("stroke_fill")),
        )
    else:
        raise ValueError(f"unsupported primitive type: {kind}")


def main() -> None:
    args = parse_args()
    spec_path = args.spec.resolve()
    specification = json.loads(spec_path.read_text(encoding="utf-8"))
    canvas = specification["canvas"]
    width, height = int(canvas["width"]), int(canvas["height"])
    mode = canvas.get("mode", "RGBA")
    image = Image.new(mode, (width, height), color(canvas["fill"]))
    draw = ImageDraw.Draw(image, "RGBA")
    fonts = load_fonts(specification.get("fonts", {}), args.repo_root.resolve())

    for layer in specification["layers"]:
        render_layer(draw, layer, fonts)

    output = args.output or Path(specification["output"])
    if not output.is_absolute():
        output = spec_path.parent / output
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, format="PNG", optimize=False, compress_level=9)
    print(output.resolve())


if __name__ == "__main__":
    main()
