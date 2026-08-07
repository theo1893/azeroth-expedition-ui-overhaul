#!/usr/bin/env python3
"""Render the deterministic QL-D V3 rough quartermaster-docket preview."""

from __future__ import annotations

import argparse
import json
import platform
import sys
from pathlib import Path
from typing import Any

import PIL
from PIL import Image, ImageDraw, ImageFont

import render_quest_log_reward_slots_simulation_v1 as base


INK = (36, 23, 15, 255)
MUTED = (96, 78, 62, 255)
LEATHER = (64, 34, 22, 252)
LEATHER_DARK = (30, 17, 12, 252)
LEATHER_LIGHT = (102, 58, 32, 230)
PAPER = (164, 124, 70, 238)
PAPER_LIGHT = (179, 139, 81, 242)
PAPER_DARK = (132, 92, 49, 225)
CORD = (91, 57, 28, 245)
TACK = (112, 77, 37, 235)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    return parser.parse_args()


def _shift(
    points: list[tuple[int, int]], x: int, y: int
) -> list[tuple[int, int]]:
    return [(x + px, y + py) for px, py in points]


def _palette(state: str) -> dict[str, tuple[int, int, int, int]]:
    palette = {
        "leather": LEATHER,
        "leather_dark": LEATHER_DARK,
        "leather_light": LEATHER_LIGHT,
        "paper": PAPER,
        "paper_light": PAPER_LIGHT,
        "paper_dark": PAPER_DARK,
        "cord": CORD,
        "tack": TACK,
    }
    if state == "hover":
        palette.update(
            leather=(72, 39, 24, 252),
            leather_light=(119, 68, 36, 235),
            paper=(179, 137, 77, 242),
            paper_light=(193, 153, 92, 245),
            tack=(126, 88, 43, 238),
        )
    elif state == "pressed":
        palette.update(
            leather=(49, 26, 18, 252),
            leather_light=(79, 43, 27, 225),
            paper=(141, 103, 59, 238),
            paper_light=(156, 117, 67, 238),
            paper_dark=(112, 76, 42, 225),
        )
    elif state == "disabled":
        palette.update(
            leather=(59, 48, 39, 220),
            leather_dark=(34, 30, 26, 225),
            leather_light=(84, 68, 53, 205),
            paper=(145, 126, 96, 205),
            paper_light=(158, 139, 107, 205),
            paper_dark=(116, 101, 79, 195),
            cord=(78, 68, 54, 205),
            tack=(91, 80, 61, 195),
        )
    return palette


def draw_rough_reward_slot(
    image: Image.Image,
    box: list[int],
    item: dict[str, Any],
    face: ImageFont.FreeTypeFont,
    index: int,
) -> None:
    """Draw a controlled rough field-added docket inside the live 108x41 box."""

    x, y, width, height = box
    if (width, height) != (108, 41):
        raise ValueError("QL-D V3 simulation requires a 108x41 reward box")
    state = item["state"]
    colours = _palette(state)
    pressed_offset = 1 if state == "pressed" else 0
    layer = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer, "RGBA")

    # Deliberately non-mirrored leather backing. It still owns the exact live
    # Button footprint, but no clean four-sided frame survives at runtime.
    backing = _shift(
        [
            (3, 2), (13, 0), (29, 2), (43, 1), (57, 3), (74, 1),
            (91, 2), (105, 1), (107, 9), (105, 17), (108, 28),
            (104, 39), (88, 38), (73, 41), (57, 39), (42, 40),
            (29, 38), (15, 41), (2, 38), (1, 29), (3, 20), (0, 11),
        ],
        x,
        y,
    )
    draw.polygon([(px + 1, py + 2) for px, py in backing], fill=(30, 17, 12, 120))
    draw.polygon(backing, fill=colours["leather"])

    # The name surface is a rough-cut parchment docket tucked beneath the
    # leather icon patch. The explicit rectangle guarantees the live name-safe
    # [41,4,105,37] stays continuous and quiet despite the torn outer edge.
    paper_patch = _shift(
        [
            (39, 4), (48, 1), (58, 4), (70, 1), (82, 4), (94, 2),
            (106, 4), (105, 12), (108, 20), (104, 28), (107, 36),
            (96, 39), (87, 37), (75, 40), (63, 37), (51, 40),
            (39, 36), (41, 29), (38, 21), (40, 12),
        ],
        x,
        y,
    )
    draw.polygon(paper_patch, fill=colours["paper"])
    draw.rectangle(
        (x + 41, y + 4, x + 105, y + 37),
        fill=colours["paper"],
    )
    # Broad brush planes, not procedural grain.
    draw.line((x + 46, y + 5, x + 61, y + 4), fill=colours["paper_light"], width=2)
    draw.line((x + 69, y + 4, x + 83, y + 6), fill=colours["paper_light"], width=1)
    draw.line((x + 93, y + 4, x + 101, y + 6), fill=colours["paper_light"], width=2)
    draw.line((x + 45, y + 37, x + 56, y + 39), fill=colours["paper_dark"], width=1)
    draw.line((x + 65, y + 38, x + 78, y + 40), fill=colours["paper_dark"], width=1)
    draw.line((x + 88, y + 38, x + 98, y + 37), fill=colours["paper_dark"], width=2)

    # Rough leather icon patch sits above the parchment and is secured with
    # uneven hand-driven stitches at the joint. The safe icon square remains
    # dark and unornamented for the live item art.
    icon_patch = _shift(
        [
            (2, 5), (9, 1), (19, 3), (28, 0), (37, 3), (40, 8),
            (38, 17), (41, 27), (37, 39), (27, 37), (18, 41),
            (9, 38), (1, 40), (2, 28), (0, 18),
        ],
        x,
        y,
    )
    draw.polygon(icon_patch, fill=colours["leather"])
    draw.rectangle(
        (x + 4, y + 4, x + 37, y + 37),
        fill=colours["leather_dark"],
    )
    draw.line(
        (x + 5, y + 4, x + 17, y + 3, x + 31, y + 5),
        fill=colours["leather_light"],
        width=2,
    )
    draw.line(
        (x + 4, y + 35, x + 14, y + 38, x + 31, y + 37),
        fill=(23, 13, 10, 220),
        width=2,
    )

    # Three hand-set lash marks are intentionally different lengths and angles.
    stitches = (
        ((37, 7), (40, 10)),
        ((38, 18), (40, 21)),
        ((37, 31), (40, 33)),
    )
    for start, end in stitches:
        draw.line(
            (x + start[0], y + start[1], x + end[0], y + end[1]),
            fill=colours["cord"],
            width=2,
        )

    # Sparse broken edge strokes and two mismatched dull tacks prevent a clean
    # industrial outline while preserving a readable coarse material hierarchy.
    draw.line((x + 7, y + 1, x + 18, y), fill=colours["leather_light"], width=1)
    draw.line((x + 25, y + 39, x + 34, y + 38), fill=(37, 19, 13, 220), width=1)
    draw.line((x + 76, y + 40, x + 87, y + 38), fill=(55, 31, 19, 210), width=1)
    draw.ellipse((x + 101, y + 1, x + 105, y + 4), fill=colours["tack"])
    draw.polygon(
        [(x + 45, y + 38), (x + 49, y + 37), (x + 48, y + 40)],
        fill=colours["tack"],
    )

    palettes = (
        ((48, 55, 61, 255), (108, 119, 125, 255), (210, 190, 129, 255)),
        ((33, 52, 88, 255), (61, 121, 190, 255), (187, 229, 250, 255)),
        ((67, 39, 29, 255), (145, 88, 42, 255), (223, 176, 87, 255)),
        ((38, 58, 38, 255), (71, 126, 68, 255), (181, 204, 96, 255)),
        ((66, 45, 78, 255), (132, 89, 148, 255), (223, 181, 234, 255)),
        ((71, 38, 32, 255), (151, 65, 50, 255), (236, 160, 103, 255)),
    )
    base.draw_icon(
        draw,
        (
            x + 5 + pressed_offset,
            y + 5 + pressed_offset,
            x + 37 + pressed_offset,
            y + height - 6 + pressed_offset,
        ),
        palettes[index % len(palettes)],
        index,
    )

    text_fill = MUTED if state == "disabled" else INK
    draw.text(
        (x + 44 + pressed_offset, y + height // 2 + pressed_offset),
        item["name"],
        font=face,
        fill=text_fill,
        anchor="lm",
    )
    count = int(item.get("count", 1))
    if count > 1:
        value = str(count)
        count_x = x + 35 + pressed_offset
        count_y = y + height - 5 + pressed_offset
        draw.text(
            (count_x + 1, count_y + 1),
            value,
            font=face,
            fill=(18, 11, 7, 245),
            anchor="rs",
        )
        draw.text(
            (count_x, count_y),
            value,
            font=face,
            fill=(239, 218, 170, 255),
            anchor="rs",
        )

    image.alpha_composite(layer)


def _final_reward_boxes(spec: dict[str, Any]) -> list[list[int]]:
    boxes = base.reward_boxes(spec)
    second_heading_y = boxes[0][1] + boxes[0][3] + 5
    guaranteed_origin_y = second_heading_y + 19
    delta = guaranteed_origin_y - boxes[2][1]
    for index in range(2, 6):
        boxes[index] = [*boxes[index]]
        boxes[index][1] += delta
    return boxes


def compose_current_neighbours_and_board(
    root: Path,
    spec: dict[str, Any],
    report: dict[str, Any],
) -> dict[str, Any]:
    inputs = spec["inputs"]
    outputs = spec["outputs"]
    layout = spec["layout"]
    preview_path = base.resolve(root, outputs["preview"])
    review_path = base.resolve(root, outputs["review_2x"])
    board_path = base.resolve(root, outputs["direction_board"])
    report_path = base.resolve(root, outputs["report"])
    carrier_path = base.resolve(root, inputs["seal_carrier"])
    seal_path = base.resolve(root, inputs["seal_atlas"])

    image = Image.open(preview_path).convert("RGBA")
    carrier = Image.open(carrier_path).convert("RGBA")
    seal_atlas = Image.open(seal_path).convert("RGBA")
    carrier_x, carrier_y, carrier_width, carrier_height = layout["seal_carrier_root"]
    carrier_root = carrier.crop((0, 0, carrier_width, carrier_height))
    image.alpha_composite(carrier_root, (carrier_x, carrier_y))

    seal_x, seal_y, seal_width, seal_height = layout["seal_visual"]
    seal_cell_width = seal_atlas.width // 4
    seal = seal_atlas.crop((0, 0, seal_cell_width, seal_atlas.height))
    seal = seal.resize((seal_width, seal_height), Image.Resampling.LANCZOS)
    image.alpha_composite(seal, (seal_x, seal_y))
    image.save(preview_path, optimize=True)
    image.resize(
        (image.width * 2, image.height * 2),
        Image.Resampling.NEAREST,
    ).save(review_path, optimize=True)

    board = Image.new("RGBA", (1400, 900), (29, 22, 17, 255))
    board_draw = ImageDraw.Draw(board, "RGBA")
    title_path = base.resolve(root, inputs["title_font"])
    body_path = base.resolve(root, inputs["body_font"])
    title_face = base.load_font(title_path, 22)
    body_face = base.load_font(body_path, 17)
    board_draw.text((24, 18), "QL-D-SIM-V3  手绘军需装备签（真实 108×41 排版）", font=title_face, fill=(215, 176, 106, 255))
    board_draw.text((24, 49), "完整任务书环境；右侧为四态 4× 像素放大。模拟像素不进入插件。", font=body_face, fill=(167, 137, 94, 255))

    scaled = image.resize((879, 603), Image.Resampling.LANCZOS)
    board.alpha_composite(scaled, (24, 91))
    board_draw.rectangle((23, 90, 904, 695), outline=(91, 61, 34, 255), width=2)

    boxes = _final_reward_boxes(spec)
    labels = ((0, "普通"), (1, "悬停"), (3, "按下"), (5, "禁用"))
    y = 89
    for index, label in labels:
        x0, y0, width, height = boxes[index]
        crop = image.crop((x0, y0, x0 + width, y0 + height))
        zoom = crop.resize((width * 4, height * 4), Image.Resampling.NEAREST)
        board_draw.text((940, y), label, font=body_face, fill=(190, 155, 96, 255))
        board.alpha_composite(zoom, (940, y + 23))
        board_draw.rectangle((939, y + 22, 1373, y + 188), outline=(80, 54, 32, 255), width=1)
        y += 195
    board.save(board_path, optimize=True)

    report["schema"] = "aeui.quest-log.reward-slots.simulation-report.v3"
    report["inputs"]["seal_carrier"] = {
        "path": inputs["seal_carrier"],
        "sha256": base.sha256(carrier_path),
    }
    report["outputs"]["preview"]["sha256"] = base.sha256(preview_path)
    report["outputs"]["review_2x"]["sha256"] = base.sha256(review_path)
    report["outputs"]["direction_board"] = {
        "path": outputs["direction_board"],
        "sha256": base.sha256(board_path),
    }
    report["current_runtime_neighbours"] = [
        "QuestLogShellV4",
        "QS-A1 wax seal",
        "QS-B1 V7-A collapsed carrier root",
    ]
    report["visual_delta_from_v2"] = [
        "no continuous leather or brass enclosure",
        "non-mirrored rough-cut leather backing and parchment docket",
        "three mismatched hand-set lash marks at the material joint",
        "sparse off-axis tacks and broken brush edges",
        "quiet live icon and name safe regions preserved",
    ]
    report["environment"] = {
        "sys_executable": sys.executable,
        "python": platform.python_version(),
        "pillow": PIL.__version__,
        "os": platform.system(),
    }
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return report


def main() -> int:
    args = parse_args()
    root = args.repo_root.resolve()
    spec = json.loads(args.spec.read_text(encoding="utf-8"))
    original = base.draw_reward_slot
    try:
        base.draw_reward_slot = draw_rough_reward_slot
        report = base.render(root, spec)
    finally:
        base.draw_reward_slot = original
    report = compose_current_neighbours_and_board(root, spec, report)
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
