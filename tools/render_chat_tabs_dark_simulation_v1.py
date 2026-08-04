#!/usr/bin/env python3
"""Render the local, non-production CHAT.TABS dark-direction simulation."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw

import build_chat_full_frame_v1_runtime as frame_v1
import build_chat_input_dark_v1_runtime as input_v1
import build_chat_v3_runtime_assets as v3
import render_chat_dark_paper_candidate_v1 as layout
import render_chat_input_dark_simulation_v1 as input_layout


ROOT = Path(__file__).resolve().parents[1]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--metrics", type=Path)
    return parser.parse_args()


def resolve(path: str | Path) -> Path:
    value = Path(path)
    return value if value.is_absolute() else ROOT / value


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def display(path: Path) -> str:
    try:
        return path.resolve().relative_to(ROOT).as_posix()
    except ValueError:
        return str(path.resolve())


def validate_hash(path: Path, expected: str, label: str) -> None:
    actual = sha256(path)
    if actual != expected:
        raise ValueError(f"{label} hash mismatch: {actual} != {expected}")


def hex_color(rgb: list[int]) -> str:
    return "#%02X%02X%02XFF" % tuple(rgb)


def draw_dark_shelf(frame: Image.Image, frame_width: int, colors: dict[str, str]) -> None:
    draw = ImageDraw.Draw(frame, "RGBA")
    left, top, right, bottom = 30, 18, frame_width - 30, 34
    draw.rectangle((left + 2, top + 4, right + 2, bottom + 2), fill=layout.rgba("#090604B8"))
    draw.polygon(
        [
            (left, top + 3),
            (left + 9, top + 1),
            (left + 74, top + 2),
            (left + 118, top),
            (right - 96, top + 2),
            (right - 18, top + 1),
            (right, top + 4),
            (right, bottom),
            (left, bottom),
        ],
        fill=layout.rgba(colors["shelf_fill"]),
        outline=layout.rgba(colors["shelf_edge"]),
    )
    # A broken, low-energy top seam avoids the old continuous pale strip.
    segments = ((left + 12, left + 68), (left + 126, left + 184), (right - 156, right - 104), (right - 72, right - 20))
    for x0, x1 in segments:
        draw.line((x0, top + 3, x1, top + 3), fill=layout.rgba(colors["shelf_glint"]), width=1)
    draw.line((left + 5, bottom - 2, right - 5, bottom - 2), fill=layout.rgba("#0A0705E8"), width=2)


def draw_dark_tab(
    frame: Image.Image,
    x: int,
    state: str,
    label: str,
    font: Any,
    colors: dict[str, Any],
) -> dict[str, Any]:
    draw = ImageDraw.Draw(frame, "RGBA")
    style = colors["states"][state]
    y = int(style["top"])
    width, height = 92, 30
    silhouette = [
        (x + 3, y + 7),
        (x + 10, y + 2),
        (x + 46, y + 1),
        (x + 83, y + 3),
        (x + 89, y + 8),
        (x + 90, y + height - 2),
        (x + 2, y + height - 2),
    ]
    shadow = [(px + 1, py + 2) for px, py in silhouette]
    draw.polygon(shadow, fill=layout.rgba("#080503C8"))
    draw.polygon(
        silhouette,
        fill=layout.rgba(style["fill"]),
        outline=layout.rgba(style["outline"]),
    )
    draw.line(
        (x + 7, y + 9, x + 7, y + height - 7),
        fill=layout.rgba(style["inner_shadow"]),
        width=2,
    )
    draw.line(
        (x + 84, y + 10, x + 84, y + height - 8),
        fill=layout.rgba(style["inner_shadow"]),
        width=1,
    )
    if style["glint"]:
        glint_width = int(style["glint_width"])
        center = x + width // 2
        draw.line(
            (center - glint_width // 2, y + 4, center + glint_width // 2, y + 4),
            fill=layout.rgba(style["glint"]),
            width=2 if state == "selected" else 1,
        )
    if state == "selected":
        draw.line((x + 12, y + height - 4, x + 78, y + height - 4), fill=layout.rgba("#2A190FF0"), width=2)
    draw.text(
        (x + width // 2, y + 16),
        label,
        font=font,
        fill=layout.rgba(style["text"]),
        anchor="mm",
    )
    return {
        "state": state,
        "visual_box": [x, 0, x + width, 32],
        "hit_box": [x, 2, x + width, 40],
    }


def build_dark_tabs(
    book: Image.Image,
    labels: list[str],
    states: list[str],
    tab_font: Any,
    colors: dict[str, Any],
) -> tuple[Image.Image, list[dict[str, Any]]]:
    if len(labels) != 4 or len(states) != 4:
        raise ValueError("simulation requires exactly four live tabs and four states")
    output = book.copy()
    draw_dark_shelf(output, output.width, colors)
    evidence = []
    for index, (label, state) in enumerate(zip(labels, states, strict=True)):
        x = 30 + index * 95
        evidence.append(draw_dark_tab(output, x, state, label, tab_font, colors))
    return output, evidence


def draw_old_v3_shelf(frame: Image.Image, frame_width: int, colors: dict[str, Any]) -> None:
    """Draw a dark shelf with the layered, repaired profile of the accepted V3 tabs.

    The geometry is intentionally simple and non-production.  It preserves the
    runtime shelf box while making the physical construction legible: a thin,
    uneven page stack rests on a worn leather binding instead of a straight UI
    rail.
    """
    draw = ImageDraw.Draw(frame, "RGBA")
    left, top, right, bottom = 30, 18, frame_width - 30, 34
    draw.polygon(
        [
            (left + 3, top + 6),
            (left + 11, top + 3),
            (left + 58, top + 4),
            (left + 112, top + 2),
            (right - 92, top + 3),
            (right - 22, top + 2),
            (right - 4, top + 5),
            (right, bottom - 1),
            (right - 8, bottom + 1),
            (left + 6, bottom),
            (left, bottom - 3),
        ],
        fill=layout.rgba("#070503B8"),
    )
    # The dark leather binding is the structural mass.
    draw.polygon(
        [
            (left + 1, top + 7),
            (left + 8, top + 5),
            (left + 72, top + 6),
            (left + 126, top + 4),
            (right - 132, top + 6),
            (right - 46, top + 4),
            (right - 7, top + 6),
            (right, top + 10),
            (right - 2, bottom - 2),
            (right - 10, bottom),
            (left + 7, bottom - 1),
            (left, bottom - 4),
        ],
        fill=layout.rgba(colors["shelf_leather"]),
        outline=layout.rgba(colors["shelf_edge"]),
    )
    # Two subdued, uneven page edges sit above the leather.  They are deliberately
    # broken so the shelf cannot read as a continuous gold separator.
    page_layers = (
        (top + 2, colors["shelf_page_dark"], ((left + 10, left + 91), (left + 116, right - 105), (right - 83, right - 13))),
        (top + 4, colors["shelf_page_light"], ((left + 17, left + 65), (left + 137, left + 206), (right - 142, right - 31))),
    )
    for y, color, segments in page_layers:
        for index, (x0, x1) in enumerate(segments):
            draw.line(
                (x0, y + (index % 2), x1, y + ((index + 1) % 2)),
                fill=layout.rgba(color),
                width=1,
            )
    draw.line((left + 12, bottom - 3, right - 14, bottom - 2), fill=layout.rgba(colors["shelf_seam"]), width=1)
    # Small hand repairs echo the old shelf ends without creating end monuments.
    stitch = layout.rgba(colors["shelf_stitch"])
    draw.line((left + 5, top + 9, left + 13, bottom - 3), fill=stitch, width=1)
    draw.line((left + 13, top + 8, left + 6, bottom - 3), fill=stitch, width=1)
    draw.line((right - 13, top + 8, right - 5, bottom - 3), fill=stitch, width=1)
    draw.line((right - 5, top + 9, right - 13, bottom - 3), fill=stitch, width=1)


def draw_old_v3_tab(
    frame: Image.Image,
    x: int,
    state: str,
    label: str,
    font: Any,
    colors: dict[str, Any],
    variant: int,
) -> dict[str, Any]:
    """Draw a dark tab using the compact, skewed leather-index grammar of V3."""
    draw = ImageDraw.Draw(frame, "RGBA")
    style = colors["states"][state]
    y = int(style["top"])
    width = 92

    # Every state keeps the 92x30 runtime canvas.  The visible leather is a
    # hand-cut trapezoid with kicked-out lower corners and an uneven crown,
    # rather than a rectangle inset into that canvas.
    crown_shift = (0, 1, -1, 0)[variant % 4]
    silhouette = [
        (x + 3, y + 10),
        (x + 8, y + 5),
        (x + 17, y + 3),
        (x + 35, y + 3 + crown_shift),
        (x + 43, y + 1),
        (x + 52, y + 3),
        (x + 74, y + 2 - crown_shift),
        (x + 84, y + 5),
        (x + 88, y + 10),
        (x + 87, y + 19),
        (x + 91, y + 26),
        (x + 86, y + 29),
        (x + 78, y + 26),
        (x + 15, y + 27),
        (x + 9, y + 29),
        (x + 1, y + 27),
        (x + 5, y + 19),
    ]
    shadow = [(px + 1, py + 2) for px, py in silhouette]
    draw.polygon(shadow, fill=layout.rgba("#060403C7"))

    if state == "selected":
        # A compressed smoked-page tongue restores the old lifted-bookmark
        # construction without reintroducing the rejected pale paper state.
        draw.polygon(
            [
                (x + 9, y + 22),
                (x + 83, y + 22),
                (x + 87, y + 27),
                (x + 82, y + 29),
                (x + 63, y + 28),
                (x + 48, y + 29),
                (x + 26, y + 28),
                (x + 12, y + 29),
                (x + 6, y + 27),
            ],
            fill=layout.rgba(style["page_underlay"]),
            outline=layout.rgba(style["page_underlay_edge"]),
        )

    draw.polygon(silhouette, fill=layout.rgba(style["fill"]), outline=layout.rgba(style["outline"]))

    seam = [
        (x + 8, y + 11),
        (x + 13, y + 7),
        (x + 31, y + 6 + crown_shift),
        (x + 43, y + 5),
        (x + 55, y + 6),
        (x + 79, y + 6 - crown_shift),
        (x + 84, y + 10),
        (x + 83, y + 19),
        (x + 86, y + 24),
        (x + 78, y + 23),
        (x + 15, y + 24),
        (x + 7, y + 25),
        (x + 9, y + 18),
        (x + 8, y + 11),
    ]
    draw.line(seam, fill=layout.rgba(style["seam"]), width=1, joint="curve")

    # Sparse, deliberately uneven stitches.  Their varying length and spacing
    # are part of the old tab language; they are not repeated machine dashes.
    stitch_y = y + 6
    stitches = ((15, 20), (25, 29), (36, 42), (49, 53), (61, 67), (73, 77))
    for index, (sx0, sx1) in enumerate(stitches):
        dy = (index + variant) % 2
        draw.line((x + sx0, stitch_y + dy, x + sx1, stitch_y + 1 - dy), fill=layout.rgba(style["stitch"]), width=1)

    # One laced repair alternates sides between cells, breaking cloned symmetry
    # while remaining well outside the live text-safe center.
    repair_x = x + (11 if variant % 2 == 0 else 80)
    draw.line((repair_x - 3, y + 18, repair_x + 3, y + 25), fill=layout.rgba(style["stitch"]), width=1)
    draw.line((repair_x + 3, y + 18, repair_x - 3, y + 25), fill=layout.rgba(style["stitch"]), width=1)

    if style["glint"]:
        glint_width = int(style["glint_width"])
        center = x + width // 2 + (-2 if variant % 2 else 1)
        draw.line(
            (center - glint_width // 2, y + 4, center + glint_width // 2, y + 3),
            fill=layout.rgba(style["glint"]),
            width=1,
        )

    draw.text(
        (x + width // 2, y + 17),
        label,
        font=font,
        fill=layout.rgba(style["text"]),
        anchor="mm",
    )
    return {
        "state": state,
        "visual_box": [x, 0, x + width, 34],
        "hit_box": [x, 2, x + width, 40],
        "visible_identity": "skewed hand-cut leather index with kicked corners",
    }


def build_old_v3_tabs(
    book: Image.Image,
    labels: list[str],
    states: list[str],
    tab_font: Any,
    colors: dict[str, Any],
) -> tuple[Image.Image, list[dict[str, Any]]]:
    if len(labels) != 4 or len(states) != 4:
        raise ValueError("simulation requires exactly four live tabs and four states")
    output = book.copy()
    draw_old_v3_shelf(output, output.width, colors)
    evidence = []
    for index, (label, state) in enumerate(zip(labels, states, strict=True)):
        x = 30 + index * 95
        evidence.append(draw_old_v3_tab(output, x, state, label, tab_font, colors, index))
    return output, evidence


def main() -> None:
    args = parse_args()
    spec_path = args.spec.resolve()
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    direction = json.loads(resolve(spec["direction_spec"]).read_text(encoding="utf-8"))
    frame_manifest = json.loads(resolve(spec["frame_runtime_manifest"]).read_text(encoding="utf-8"))
    input_manifest = json.loads(resolve(spec["input_runtime_manifest"]).read_text(encoding="utf-8"))
    v3_manifest = json.loads(resolve(spec["v3_manifest"]).read_text(encoding="utf-8"))

    paths = {
        "frame": resolve(spec["runtime_frame_atlas"]),
        "tabs": resolve(spec["runtime_tabs_atlas"]),
        "shelf": resolve(spec["runtime_tab_shelf"]),
        "input": resolve(spec["runtime_input_atlas"]),
    }
    validate_hash(paths["frame"], frame_manifest["runtime_export"]["sha256"], "frame")
    validate_hash(paths["tabs"], v3_manifest["runtime_exports"]["tabs"]["sha256"], "tabs")
    validate_hash(paths["shelf"], v3_manifest["runtime_exports"]["tab_shelf"]["sha256"], "shelf")
    validate_hash(paths["input"], input_manifest["runtime_export"]["sha256"], "input")

    frame_atlas = Image.open(paths["frame"]).convert("RGBA")
    tab_atlas = Image.open(paths["tabs"]).convert("RGBA")
    shelf = Image.open(paths["shelf"]).convert("RGBA")
    input_atlas = Image.open(paths["input"]).convert("RGBA")
    body_font = layout.load_font(spec["fonts"]["body"]["path"], spec["fonts"]["body"]["size"])
    tab_font = layout.load_font(spec["fonts"]["tab"]["path"], spec["fonts"]["tab"]["size"])
    input_font = layout.load_font(spec["fonts"]["input"]["path"], spec["fonts"]["input"]["size"])
    label_font = layout.load_font(spec["fonts"]["label"]["path"], spec["fonts"]["label"]["size"])
    note_font = layout.load_font(spec["fonts"]["note"]["path"], spec["fonts"]["note"]["size"])

    palette = {
        key: hex_color(value)
        for key, value in frame_manifest["text_readability"]["palette_rgb"].items()
    }
    direction_theme = next(
        item for item in direction["themes"] if item["id"] == "B-near-black-paper"
    )
    for role, value in direction_theme["palette"].items():
        if role not in palette:
            palette[role] = value
    canvas = Image.new("RGBA", tuple(spec["canvas"]), layout.rgba("#111713FF"))
    layout.draw_world_backdrop(canvas)
    draw = ImageDraw.Draw(canvas, "RGBA")
    evidence: dict[str, Any] = {}

    for scenario in spec["scenarios"]:
        origin = tuple(scenario["origin"])
        frame_size = tuple(scenario["frame_size"])
        draw.text(
            (origin[0] + frame_size[0] // 2, origin[1] - 28),
            scenario["label"],
            font=label_font,
            fill=layout.rgba("#E8D2A8FF"),
            anchor="mm",
        )
        draw.text(
            (origin[0] + frame_size[0] // 2, origin[1] - 11),
            scenario["note"],
            font=note_font,
            fill=layout.rgba("#A99572FF"),
            anchor="mm",
        )
        book = frame_v1.build_frame(frame_atlas, frame_size)
        if scenario["tabs_mode"] == "runtime-v3":
            assembled = layout.build_tabbed_frame(
                book,
                tab_atlas,
                shelf,
                direction["tabs"],
                scenario["selected_tab"],
                tab_font,
                spec["runtime_tab_text"]["selected"],
                spec["runtime_tab_text"]["normal"],
            )
            tab_evidence = [{"state": "selected" if index == scenario["selected_tab"] else "normal"} for index in range(4)]
        elif scenario["tabs_mode"] == "geometric-dark":
            assembled, tab_evidence = build_dark_tabs(
                book,
                direction["tabs"],
                scenario["states"],
                tab_font,
                spec["proposal"],
            )
        elif scenario["tabs_mode"] == "geometric-old-v3-dark":
            assembled, tab_evidence = build_old_v3_tabs(
                book,
                direction["tabs"],
                scenario["states"],
                tab_font,
                spec["proposal"],
            )
        else:
            raise ValueError(f"unsupported tabs_mode: {scenario['tabs_mode']}")

        messages = list(direction["messages"][: scenario["message_count"]])
        messages.extend(scenario.get("extra_messages", []))
        message_evidence = layout.draw_messages(
            assembled,
            messages,
            palette,
            body_font,
            scenario["maximum_lines"],
            frame_size,
        )
        input_width = frame_size[0] - 60
        input_y = frame_size[1] - 31
        strip = input_v1.build_input(input_atlas, scenario["input_state"], input_width)
        input_evidence = input_layout.add_input_text(
            strip,
            scenario["input_state"],
            scenario.get("input_header", ""),
            scenario.get("input_text", ""),
            input_font,
            spec["input_text"],
        )
        assembled.alpha_composite(strip, (30, input_y))
        canvas.alpha_composite(assembled, origin)
        evidence[scenario["id"]] = {
            "frame": list(frame_size),
            "origin": list(origin),
            "tabs_mode": scenario["tabs_mode"],
            "tabs": tab_evidence,
            "shelf_box": [30, 18, frame_size[0] - 30, 34],
            **message_evidence,
            **input_evidence,
        }

    draw.text(
        (spec["canvas"][0] // 2, spec["canvas"][1] - 13),
        spec["footer"],
        font=note_font,
        fill=layout.rgba("#D7C49AFF"),
        anchor="ms",
    )
    output = args.output or resolve(spec["output"])
    metrics_path = args.metrics or resolve(spec["metrics"])
    output.parent.mkdir(parents=True, exist_ok=True)
    metrics_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, format="PNG", optimize=False, compress_level=9)
    metrics = {
        "schema": "aeui-chat-tabs-dark-simulation-metrics-v1",
        "version": spec["version"],
        "preview": {"path": display(output), "sha256": sha256(output), "size": list(canvas.size)},
        "inputs": {key: {"path": display(path), "sha256": sha256(path)} for key, path in paths.items()},
        "layout": evidence,
        "imagegen": "0/0",
        "authority": {
            "frame_input_text": "current tracked runtime and representative dynamic content",
            "current_tabs": "current tracked V3 runtime used only in the comparison scene",
            "proposal": "deterministic flat geometry; direction evidence only; never source, runtime, or production input",
        },
    }
    metrics_path.write_text(json.dumps(metrics, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(output.resolve())
    print(metrics_path.resolve())


if __name__ == "__main__":
    main()
