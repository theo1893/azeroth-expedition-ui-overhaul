#!/usr/bin/env python3
"""Render exact 100%-UI candidate layouts for a generated CHAT.FRAME.

The candidate frame and accepted V3 tab pixels are assembled at the live
440x320 geometry. Text is deterministic runtime evidence only and is never
written into the candidate source or runtime texture.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageColor, ImageDraw, ImageFont

import build_chat_v3_runtime_assets as v3


ROOT = Path(__file__).resolve().parents[1]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--metrics", type=Path)
    return parser.parse_args()


def resolve(path: str | Path) -> Path:
    candidate = Path(path)
    return candidate if candidate.is_absolute() else ROOT / candidate


def rgba(value: str) -> tuple[int, int, int, int]:
    return ImageColor.getcolor(value, "RGBA")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_font(path: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(
        str(resolve(path)), size, layout_engine=ImageFont.Layout.BASIC
    )


def draw_world_backdrop(image: Image.Image) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    width, height = image.size
    draw.rectangle((0, 0, width, height), fill=rgba("#111713FF"))
    draw.polygon(
        [(0, 70), (170, 24), (350, 76), (540, 22), (760, 84), (width, 32),
         (width, 0), (0, 0)],
        fill=rgba("#293129FF"),
    )
    draw.polygon(
        [(0, 185), (190, 116), (390, 172), (590, 104), (790, 168),
         (width, 118), (width, height), (0, height)],
        fill=rgba("#3E3A2FFF"),
    )
    draw.polygon(
        [(0, 300), (260, 238), (505, 298), (760, 226), (width, 274),
         (width, height), (0, height)],
        fill=rgba("#55442FFF"),
    )


def build_tabbed_frame(
    book: Image.Image,
    tab_atlas: Image.Image,
    shelf: Image.Image,
    labels: list[str],
    selected_index: int,
    tab_font: ImageFont.FreeTypeFont,
    selected_color: str,
    normal_color: str,
) -> Image.Image:
    output = book.copy()
    output.alpha_composite(
        shelf.resize((380, v3.TAB_SHELF_RUNTIME_HEIGHT), v3.RESAMPLE),
        (30, v3.TAB_SHELF_TOP_OFFSET),
    )
    for index, label in enumerate(labels):
        state = 2 if index == selected_index else 0
        tab = v3.build_runtime_tab(tab_atlas, state)
        x = 30 + index * (v3.TAB_RUNTIME_WIDTH + v3.TAB_RUNTIME_GAP)
        output.alpha_composite(tab, (x, v3.TAB_RUNTIME_TOP_OFFSET))
        draw = ImageDraw.Draw(output, "RGBA")
        draw.text(
            (x + v3.TAB_RUNTIME_WIDTH // 2, 17),
            label,
            font=tab_font,
            fill=rgba(selected_color if index == selected_index else normal_color),
            anchor="mm",
        )
    return output


def draw_messages(
    frame: Image.Image,
    messages: list[dict[str, Any]],
    palette: dict[str, str],
    body_font: ImageFont.FreeTypeFont,
    maximum_lines: int,
    frame_size: tuple[int, int] = (440, 320),
) -> dict[str, Any]:
    safe_width = frame_size[0] - 60
    safe_height = frame_size[1] - 72
    layer = Image.new("RGBA", (safe_width, safe_height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer, "RGBA")
    line_height = 15
    line_capacity = ((safe_height - 10) // line_height) + 1
    if maximum_lines > line_capacity:
        raise ValueError(
            f"maximum_lines {maximum_lines} exceeds frame capacity {line_capacity}"
        )
    cursor_x = 0.0
    cursor_y = 10
    rendered_lines = 1 if messages else 0
    truncated = False

    def newline() -> bool:
        nonlocal cursor_x, cursor_y, rendered_lines, truncated
        cursor_x = 0.0
        cursor_y += line_height
        rendered_lines += 1
        if rendered_lines > maximum_lines:
            truncated = True
            return False
        return True

    def draw_run(text: str, color_value: str) -> bool:
        nonlocal cursor_x, cursor_y, truncated
        remaining = text
        while remaining:
            if rendered_lines > maximum_lines:
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
                test_width = draw.textlength(test, font=body_font)
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
            draw.text(
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
            color_value = palette.get(segment["role"], palette["body"])
            if not draw_run(segment["text"], color_value):
                break
        if truncated:
            break
        if message_index != len(messages) - 1 and not newline():
            break

    frame.alpha_composite(layer, (30, 32))
    return {
        "rendered_lines": min(rendered_lines, maximum_lines),
        "maximum_lines": maximum_lines,
        "truncated": int(truncated),
        "last_baseline_y": 32 + cursor_y,
        "content_bottom": frame_size[1] - 40,
        "content_safe_area": [30, 32, frame_size[0] - 30, frame_size[1] - 40],
    }


def main() -> None:
    args = parse_args()
    spec_path = args.spec.resolve()
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    direction_spec_path = resolve(spec["direction_spec"])
    direction = json.loads(direction_spec_path.read_text(encoding="utf-8"))
    theme = next(
        item for item in direction["themes"] if item["id"] == spec["theme_id"]
    )

    frame_path = resolve(spec["candidate_frame"])
    tabs_path = resolve(spec["accepted_tabs"])
    frame_source = Image.open(frame_path).convert("RGBA")
    tabs_source = Image.open(tabs_path).convert("RGBA")
    book_atlas = v3.build_book(frame_source)
    tab_atlas = v3.build_tab_atlas(tabs_source)
    shelf = v3.build_tab_shelf(tabs_source)

    body_font = load_font(spec["fonts"]["body"]["path"], spec["fonts"]["body"]["size"])
    tab_font = load_font(spec["fonts"]["tab"]["path"], spec["fonts"]["tab"]["size"])
    label_font = load_font(spec["fonts"]["label"]["path"], spec["fonts"]["label"]["size"])

    canvas = Image.new("RGBA", tuple(spec["canvas"]), rgba("#111713FF"))
    draw_world_backdrop(canvas)
    draw = ImageDraw.Draw(canvas, "RGBA")
    evidence: dict[str, Any] = {}

    for scenario in spec["scenarios"]:
        origin = tuple(scenario["origin"])
        frame_size = tuple(scenario.get("frame_size", [440, 320]))
        draw.text(
            (origin[0] + frame_size[0] // 2, origin[1] - 21),
            scenario["label"],
            font=label_font,
            fill=rgba("#E8D2A8FF"),
            anchor="mm",
        )
        assembled = build_tabbed_frame(
            v3.build_book_preview(book_atlas, frame_size),
            tab_atlas,
            shelf,
            direction["tabs"],
            scenario["selected_tab"],
            tab_font,
            spec["tab_text"]["selected"],
            spec["tab_text"]["normal"],
        )
        messages = list(direction["messages"][: scenario["message_count"]])
        messages.extend(scenario.get("extra_messages", []))
        layout = draw_messages(
            assembled,
            messages,
            theme["palette"],
            body_font,
            scenario["maximum_lines"],
            frame_size,
        )
        canvas.alpha_composite(assembled, origin)
        evidence[scenario["id"]] = {
            "frame": list(frame_size),
            "origin": list(origin),
            "selected_tab": scenario["selected_tab"],
            "message_count": len(messages),
            **layout,
        }

    output = args.output or resolve(spec["output"])
    if not output.is_absolute():
        output = ROOT / output
    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, format="PNG", optimize=False, compress_level=9)

    metrics_path = args.metrics or resolve(spec["metrics"])
    if not metrics_path.is_absolute():
        metrics_path = ROOT / metrics_path
    metrics_path.parent.mkdir(parents=True, exist_ok=True)
    metrics = {
        "schema": "aeui-chat-frame-candidate-layout-metrics-v1",
        "version": spec["version"],
        "candidate_frame": {
            "path": frame_path.relative_to(ROOT).as_posix(),
            "sha256": sha256(frame_path),
            "size": list(frame_source.size),
            "mode": frame_source.mode,
        },
        "accepted_tabs": {
            "path": tabs_path.relative_to(ROOT).as_posix(),
            "sha256": sha256(tabs_path),
        },
        "preview": {
            "path": output.relative_to(ROOT).as_posix(),
            "sha256": sha256(output),
            "size": list(canvas.size),
            "mode": canvas.mode,
        },
        "frame_sizes": sorted(
            {tuple(item["frame"]) for item in evidence.values()}
        ),
        "authority": {
            "candidate_pixels": (
                f"whole generated {spec['version']} candidate after "
                "deterministic alpha cleanup"
            ),
            "tabs": "accepted V3 runtime-equivalent pixels",
            "text": "dynamic representative content; never source or runtime pixels",
            "world_backdrop": "non-authoritative geometric context",
        },
        "layout": evidence,
    }
    metrics_path.write_text(
        json.dumps(metrics, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(output.resolve())
    print(metrics_path.resolve())


if __name__ == "__main__":
    main()
