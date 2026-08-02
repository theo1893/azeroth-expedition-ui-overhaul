#!/usr/bin/env python3
"""Render the deterministic CHAT dark-parchment A/B direction simulation.

This is a non-production preview. It deliberately uses only geometric
primitives and runtime text; no pixels are sampled from locked or accepted
artwork, and the output must never be promoted to source/runtime media.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageColor, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--metrics", type=Path)
    return parser.parse_args()


def rgba(value: str) -> tuple[int, int, int, int]:
    return ImageColor.getcolor(value, "RGBA")


def load_font(path: str, size: int) -> ImageFont.FreeTypeFont:
    candidate = Path(path)
    if not candidate.is_absolute():
        candidate = ROOT / candidate
    return ImageFont.truetype(
        str(candidate), size, layout_engine=ImageFont.Layout.BASIC
    )


def offset_points(
    points: list[list[int]], origin: tuple[int, int]
) -> list[tuple[int, int]]:
    return [(origin[0] + point[0], origin[1] + point[1]) for point in points]


def draw_world_backdrop(draw: ImageDraw.ImageDraw, width: int, height: int) -> None:
    draw.rectangle((0, 0, width, height), fill=rgba("#121914FF"))
    draw.polygon(
        [(0, 82), (170, 35), (365, 91), (520, 38), (760, 88), (1000, 24),
         (width, 0), (0, 0)],
        fill=rgba("#2C352DFF"),
    )
    draw.polygon(
        [(0, 173), (150, 111), (330, 155), (492, 93), (682, 157),
         (842, 102), (width, 140), (width, height), (0, height)],
        fill=rgba("#394036FF"),
    )
    draw.polygon(
        [(0, 255), (224, 205), (418, 257), (632, 189), (842, 241),
         (width, 210), (width, height), (0, height)],
        fill=rgba("#4A4334FF"),
    )
    for y, color in ((288, "#5C4B35AA"), (329, "#2D2B24AA"), (371, "#6B5337AA")):
        draw.line((0, y, width, y - 31), fill=rgba(color), width=3)


def draw_deckled_book(
    image: Image.Image,
    origin: tuple[int, int],
    frame_size: tuple[int, int],
    theme: dict[str, Any],
    tab_labels: list[str],
    body_font: ImageFont.FreeTypeFont,
    tab_font: ImageFont.FreeTypeFont,
    messages: list[dict[str, Any]],
) -> dict[str, int]:
    x, y = origin
    width, height = frame_size
    draw = ImageDraw.Draw(image, "RGBA")

    outer = [[0, 13], [13, 4], [424, 1], [439, 17], [437, 300],
             [421, 319], [13, 316], [1, 301]]
    shadow = [[point[0] + 5, point[1] + 7] for point in outer]
    draw.polygon(offset_points(shadow, origin), fill=rgba("#070503B8"))
    draw.polygon(
        offset_points(outer, origin),
        fill=rgba(theme["leather"]),
        outline=rgba(theme["brass"]),
    )

    page_layers = [
        ([[10, 30], [426, 27], [431, 294], [418, 310], [13, 307], [6, 292]],
         theme["page_stack_dark"]),
        ([[13, 27], [423, 25], [428, 292], [416, 306], [16, 303], [9, 289]],
         theme["page_stack_mid"]),
        ([[17, 25], [420, 27], [424, 287], [414, 301], [20, 299], [13, 286]],
         theme["paper"]),
    ]
    for points, fill in page_layers:
        draw.polygon(
            offset_points(points, origin),
            fill=rgba(fill),
            outline=rgba(theme["paper_edge"]),
        )

    # Micro-fibers, stains, seams, and alpha cleanup are deliberately omitted:
    # the simulation must test color polarity without inventing production art.

    # A continuous leather shelf and four real-sized tab bodies.
    draw.polygon(
        offset_points([[30, 18], [410, 18], [407, 34], [32, 34]], origin),
        fill=rgba(theme["shelf"]),
        outline=rgba(theme["shelf_edge"]),
    )
    tab_x = 30
    for index, label in enumerate(tab_labels):
        selected = index == 0
        tab_fill = theme["tab_selected"] if selected else theme["tab_normal"]
        top = 1 if selected else 4
        points = [
            [tab_x, top + 5], [tab_x + 8, top], [tab_x + 83, top + 1],
            [tab_x + 91, top + 7], [tab_x + 88, 30], [tab_x + 3, 30],
        ]
        draw.polygon(
            offset_points(points, origin),
            fill=rgba(tab_fill),
            outline=rgba(theme["tab_edge"]),
        )
        label_color = theme["tab_text_selected"] if selected else theme["tab_text"]
        draw.text(
            (x + tab_x + 46, y + 16),
            label,
            font=tab_font,
            fill=rgba(label_color),
            anchor="mm",
        )
        tab_x += 95

    safe_width, safe_height = 380, 248
    content = Image.new("RGBA", (safe_width, safe_height), (0, 0, 0, 0))
    content_draw = ImageDraw.Draw(content, "RGBA")
    line_height = 15
    max_lines = 16
    cursor_x = 0.0
    cursor_y = 12
    rendered_lines = 1
    truncated = False

    def newline() -> bool:
        nonlocal cursor_x, cursor_y, rendered_lines, truncated
        cursor_x = 0.0
        cursor_y += line_height
        rendered_lines += 1
        if rendered_lines > max_lines:
            truncated = True
            return False
        return True

    def draw_run(text: str, color_value: str) -> bool:
        nonlocal cursor_x, cursor_y, truncated
        remaining = text
        while remaining:
            if rendered_lines > max_lines:
                truncated = True
                return False
            if remaining[0] == "\n":
                remaining = remaining[1:]
                if not newline():
                    return False
                continue
            available = safe_width - cursor_x
            if available <= 0 and not newline():
                return False
            end = 0
            best_width = 0.0
            while end < len(remaining) and remaining[end] != "\n":
                test = remaining[: end + 1]
                test_width = content_draw.textlength(test, font=body_font)
                if test_width > available and end > 0:
                    break
                if test_width > available:
                    if not newline():
                        return False
                    available = safe_width
                    end = 0
                    continue
                end += 1
                best_width = test_width
            if end == 0:
                if not newline():
                    return False
                continue
            piece = remaining[:end]
            content_draw.text(
                (int(round(cursor_x)), cursor_y),
                piece,
                font=body_font,
                fill=rgba(color_value),
            )
            cursor_x += best_width
            remaining = remaining[end:]
            if remaining and remaining[0] != "\n":
                if not newline():
                    return False
        return True

    for message_index, message in enumerate(messages):
        for segment in message["segments"]:
            role = segment["role"]
            color_value = theme["palette"].get(role, theme["palette"]["body"])
            if not draw_run(segment["text"], color_value):
                break
        if truncated:
            break
        if message_index != len(messages) - 1 and not newline():
            break

    image.alpha_composite(content, (x + 30, y + 32))
    return {"rendered_lines": min(rendered_lines, max_lines), "truncated": int(truncated)}


def linear_channel(value: int) -> float:
    encoded = value / 255.0
    if encoded <= 0.04045:
        return encoded / 12.92
    return ((encoded + 0.055) / 1.055) ** 2.4


def luminance(value: str) -> float:
    red, green, blue, _ = rgba(value)
    return (
        0.2126 * linear_channel(red)
        + 0.7152 * linear_channel(green)
        + 0.0722 * linear_channel(blue)
    )


def contrast(left: str, right: str) -> float:
    l1, l2 = luminance(left), luminance(right)
    return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    args = parse_args()
    spec_path = args.spec.resolve()
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    canvas = spec["canvas"]
    image = Image.new(
        canvas.get("mode", "RGBA"),
        (canvas["width"], canvas["height"]),
        rgba(canvas["fill"]),
    )
    draw = ImageDraw.Draw(image, "RGBA")
    draw_world_backdrop(draw, canvas["width"], canvas["height"])

    body_font = load_font(spec["fonts"]["body"]["path"], spec["fonts"]["body"]["size"])
    tab_font = load_font(spec["fonts"]["tab"]["path"], spec["fonts"]["tab"]["size"])
    label_font = load_font(spec["fonts"]["label"]["path"], spec["fonts"]["label"]["size"])
    note_font = load_font(spec["fonts"]["note"]["path"], spec["fonts"]["note"]["size"])

    frame_size = tuple(spec["frame"]["size"])
    layout_evidence: dict[str, Any] = {}
    for theme in spec["themes"]:
        origin = tuple(theme["origin"])
        draw.text(
            (origin[0] + frame_size[0] // 2, 24),
            theme["label"],
            font=label_font,
            fill=rgba(theme["label_color"]),
            anchor="mm",
        )
        layout_evidence[theme["id"]] = draw_deckled_book(
            image,
            origin,
            frame_size,
            theme,
            spec["tabs"],
            body_font,
            tab_font,
            spec["messages"],
        )

    draw.text(
        (canvas["width"] // 2, canvas["height"] - 13),
        spec["footer"],
        font=note_font,
        fill=rgba("#D7C49AFF"),
        anchor="ms",
    )

    output = args.output or Path(spec["output"])
    if not output.is_absolute():
        output = ROOT / output
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, format="PNG", optimize=False, compress_level=9)

    metrics_path = args.metrics or output.with_name("chat_dark_parchment_ab_v1.metrics.json")
    if not metrics_path.is_absolute():
        metrics_path = ROOT / metrics_path
    metrics_path.parent.mkdir(parents=True, exist_ok=True)
    metrics: dict[str, Any] = {
        "schema": "aeui-chat-dark-parchment-simulation-metrics-v1",
        "version": spec["version"],
        "image": {
            "path": output.relative_to(ROOT).as_posix(),
            "size": list(image.size),
            "mode": image.mode,
            "sha256": sha256(output),
        },
        "frame_size": list(frame_size),
        "content_safe_area": spec["frame"]["content_safe_area"],
        "layout": layout_evidence,
        "contrast": {},
        "authority": "direction-only; never source, runtime, or production input",
        "imagegen": "0/0",
    }
    for theme in spec["themes"]:
        paper = theme["paper"]
        metrics["contrast"][theme["id"]] = {
            role: round(contrast(color_value, paper), 3)
            for role, color_value in theme["palette"].items()
        }
    metrics_path.write_text(
        json.dumps(metrics, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(output.resolve())
    print(metrics_path.resolve())


if __name__ == "__main__":
    main()
