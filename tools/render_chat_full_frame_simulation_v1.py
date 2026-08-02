#!/usr/bin/env python3
"""Render the deterministic CHAT.FRAME.FULL.V1 pre-production simulation.

The preview uses geometric primitives only. It demonstrates a single coherent
book material stack at the live 440x320 geometry while keeping tabs and text as
independent runtime neighbors. No source, locked-reference, or generated pixels
are sampled, and the output must never be promoted to source/runtime media.
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


def load_font(font_spec: dict[str, Any]) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(
        str(resolve(font_spec["path"])),
        int(font_spec["size"]),
        layout_engine=ImageFont.Layout.BASIC,
    )


def shifted(
    points: list[tuple[int, int]], origin: tuple[int, int]
) -> list[tuple[int, int]]:
    return [(origin[0] + x, origin[1] + y) for x, y in points]


def draw_world_backdrop(image: Image.Image) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    width, height = image.size
    draw.rectangle((0, 0, width, height), fill=rgba("#111713FF"))
    draw.polygon(
        [(0, 65), (160, 20), (330, 75), (510, 22), (720, 79),
         (width, 28), (width, 0), (0, 0)],
        fill=rgba("#293129FF"),
    )
    draw.polygon(
        [(0, 182), (190, 112), (370, 168), (570, 102), (780, 164),
         (width, 116), (width, height), (0, height)],
        fill=rgba("#3E3A2FFF"),
    )
    draw.polygon(
        [(0, 292), (250, 234), (500, 292), (755, 224), (width, 270),
         (width, height), (0, height)],
        fill=rgba("#55442FFF"),
    )


def draw_unified_book(
    image: Image.Image,
    origin: tuple[int, int],
    materials: dict[str, str],
) -> None:
    """Draw one connected material hierarchy, never a center-panel overlay."""
    draw = ImageDraw.Draw(image, "RGBA")

    outer = [(0, 14), (10, 5), (96, 2), (218, 5), (326, 1), (430, 7),
             (439, 20), (437, 296), (426, 316), (330, 318), (218, 315),
             (108, 319), (12, 314), (1, 299)]
    draw.polygon(
        shifted([(x + 5, y + 7) for x, y in outer], origin),
        fill=rgba(materials["shadow"]),
    )
    draw.polygon(
        shifted(outer, origin),
        fill=rgba(materials["leather"]),
        outline=rgba(materials["brass_dark"]),
        width=2,
    )
    draw.line(
        shifted([(8, 19), (17, 10), (214, 10), (320, 6), (429, 14)], origin),
        fill=rgba(materials["leather_light"]),
        width=3,
    )

    # The page stack grades continuously from leather into the reading paper.
    # None of these layers is a pasted rectangular center panel.
    layers = [
        ([(7, 28), (16, 18), (425, 17), (433, 29), (431, 291),
          (419, 309), (18, 306), (7, 292)], "page_stack_outer"),
        ([(11, 28), (20, 21), (421, 21), (429, 31), (427, 288),
          (416, 304), (20, 302), (11, 287)], "page_stack_mid"),
        ([(15, 29), (24, 24), (417, 24), (425, 33), (423, 285),
          (413, 299), (23, 298), (15, 283)], "page_stack_inner"),
        ([(20, 31), (29, 27), (412, 27), (420, 35), (418, 281),
          (409, 294), (28, 294), (20, 279)], "paper_warm"),
        ([(25, 34), (33, 30), (407, 30), (415, 38), (413, 277),
          (405, 290), (32, 289), (25, 275)], "paper"),
    ]
    for points, key in layers:
        draw.polygon(
            shifted(points, origin),
            fill=rgba(materials[key]),
            outline=rgba(materials["paper_edge"]),
        )

    # Quiet deterministic fibers demonstrate material identity only.
    for index in range(15):
        x = 47 + (index * 67) % 340
        y = 54 + (index * 41) % 202
        length = 18 + (index % 4) * 8
        draw.line(
            (origin[0] + x, origin[1] + y,
             origin[0] + min(404, x + length), origin[1] + y + (index % 3) - 1),
            fill=rgba(materials["fiber"]),
            width=1,
        )

    # Uneven page fans and sparse non-mirrored repairs keep the book untidy.
    deckled_lines = [
        [(25, 285), (86, 288), (142, 286), (206, 291), (275, 287),
         (338, 290), (408, 284)],
        [(20, 291), (74, 294), (130, 291), (192, 296), (259, 292),
         (326, 296), (413, 290)],
        [(17, 298), (105, 301), (163, 298), (239, 303), (310, 300),
         (416, 296)],
    ]
    for index, line in enumerate(deckled_lines):
        draw.line(
            shifted(line, origin),
            fill=rgba(materials["page_stack_inner"] if index == 0
                      else materials["page_stack_mid"]),
            width=1,
        )

    draw.ellipse(
        (origin[0] + 7, origin[1] + 15, origin[0] + 18, origin[1] + 26),
        fill=rgba(materials["brass"]),
        outline=rgba(materials["brass_dark"]),
    )
    draw.polygon(
        shifted([(419, 291), (431, 287), (435, 302), (425, 309), (417, 302)], origin),
        fill=rgba(materials["brass"]),
        outline=rgba(materials["brass_dark"]),
    )
    draw.line(
        shifted([(420, 16), (428, 21), (423, 29)], origin),
        fill=rgba(materials["brass"]),
        width=2,
    )


def draw_runtime_tabs(
    image: Image.Image,
    origin: tuple[int, int],
    labels: list[str],
    selected_index: int,
    materials: dict[str, str],
    font: ImageFont.FreeTypeFont,
) -> None:
    """Represent current independent tab objects; these pixels are not frame art."""
    draw = ImageDraw.Draw(image, "RGBA")
    draw.polygon(
        shifted([(30, 18), (410, 18), (407, 34), (32, 34)], origin),
        fill=rgba(materials["shelf"]),
        outline=rgba(materials["shelf_edge"]),
    )
    tab_x = 30
    for index, label in enumerate(labels):
        selected = index == selected_index
        top = 1 if selected else 4
        points = [(tab_x, top + 5), (tab_x + 8, top), (tab_x + 83, top + 1),
                  (tab_x + 91, top + 7), (tab_x + 88, 30), (tab_x + 3, 30)]
        draw.polygon(
            shifted(points, origin),
            fill=rgba(materials["tab_selected"] if selected else materials["tab_normal"]),
            outline=rgba(materials["tab_edge"]),
        )
        draw.text(
            (origin[0] + tab_x + 46, origin[1] + 16),
            label,
            font=font,
            fill=rgba(
                materials["tab_text_selected"] if selected
                else materials["tab_text"]
            ),
            anchor="mm",
        )
        tab_x += 95


def draw_message_lines(
    image: Image.Image,
    origin: tuple[int, int],
    messages: list[list[list[str]]],
    palette: dict[str, str],
    font: ImageFont.FreeTypeFont,
    line_count: int,
    line_height: int,
) -> dict[str, int]:
    draw = ImageDraw.Draw(image, "RGBA")
    left = origin[0] + 30
    top = origin[1] + 42
    right = origin[0] + 410
    for line_index, line in enumerate(messages[:line_count]):
        x = left
        y = top + line_index * line_height
        for role, text_value in line:
            available = max(0, right - x)
            if available == 0:
                break
            text = text_value
            while text and draw.textlength(text, font=font) > available:
                text = text[:-1]
            if not text:
                break
            draw.text(
                (x, y),
                text,
                font=font,
                fill=rgba(palette.get(role, palette["body"])),
            )
            x += int(round(draw.textlength(text, font=font)))
    return {
        "rendered_lines": min(line_count, len(messages)),
        "first_baseline_y": 42,
        "last_baseline_y": 42 + (line_count - 1) * line_height,
        "content_bottom": 280,
    }


def main() -> None:
    args = parse_args()
    spec = json.loads(args.spec.resolve().read_text(encoding="utf-8"))
    canvas_spec = spec["canvas"]
    image = Image.new(
        canvas_spec["mode"],
        (canvas_spec["width"], canvas_spec["height"]),
        rgba(canvas_spec["fill"]),
    )
    draw_world_backdrop(image)

    body_font = load_font(spec["fonts"]["body"])
    tab_font = load_font(spec["fonts"]["tab"])
    label_font = load_font(spec["fonts"]["label"])
    note_font = load_font(spec["fonts"]["note"])
    draw = ImageDraw.Draw(image, "RGBA")
    evidence: dict[str, Any] = {}

    for scenario in spec["scenarios"]:
        origin = tuple(scenario["origin"])
        draw.text(
            (origin[0] + 220, 20),
            scenario["label"],
            font=label_font,
            fill=rgba("#E8D2A8FF"),
            anchor="mm",
        )
        draw_unified_book(image, origin, spec["materials"])
        draw_runtime_tabs(
            image,
            origin,
            spec["tabs"],
            int(scenario["selected_tab"]),
            spec["materials"],
            tab_font,
        )
        layout = draw_message_lines(
            image,
            origin,
            spec["messages"],
            spec["palette"],
            body_font,
            int(scenario["line_count"]),
            int(spec["frame"]["line_height"]),
        )
        evidence[scenario["id"]] = {
            "frame": spec["frame"]["size"],
            "origin": list(origin),
            "selected_tab": scenario["selected_tab"],
            **layout,
        }

    draw.text(
        (canvas_spec["width"] // 2, canvas_spec["height"] - 10),
        spec["footer"],
        font=note_font,
        fill=rgba("#D7C49AFF"),
        anchor="ms",
    )

    output = args.output or resolve(spec["output"])
    output = output if output.is_absolute() else ROOT / output
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, format="PNG", optimize=False, compress_level=9)

    metrics_path = args.metrics or resolve(spec["metrics"])
    metrics_path = metrics_path if metrics_path.is_absolute() else ROOT / metrics_path
    metrics_path.parent.mkdir(parents=True, exist_ok=True)
    metrics = {
        "schema": "aeui-chat-full-frame-simulation-metrics-v1",
        "version": spec["version"],
        "component": spec["component"],
        "preview": {
            "path": output.relative_to(ROOT).as_posix(),
            "sha256": sha256(output),
            "size": list(image.size),
            "mode": image.mode,
        },
        "frame_size": spec["frame"]["size"],
        "content_safe_area": spec["frame"]["content_safe_area"],
        "nine_slice_caps": spec["frame"]["nine_slice_caps"],
        "layout": evidence,
        "authority": {
            "book": "direction-only geometric representation of one coherently generated object",
            "tabs_and_text": "independent runtime-neighbor representations; not frame art",
            "world_backdrop": "non-authoritative geometric context",
            "promotion": "never source, runtime, or production input"
        },
        "imagegen": "0/0",
        "external_uploads": 0,
    }
    metrics_path.write_text(
        json.dumps(metrics, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(output.resolve())
    print(metrics_path.resolve())


if __name__ == "__main__":
    main()
