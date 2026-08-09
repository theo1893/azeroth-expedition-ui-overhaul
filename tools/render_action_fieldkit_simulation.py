#!/usr/bin/env python3
"""Render the deterministic AB.FIELDKIT.V1 pre-production simulation.

The output intentionally uses flat local geometry. It represents provider
proportions, hierarchy, density and interaction states, never production art.
"""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, ImageFont

import render_action_bars_simulation as core


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument("--scene-output", type=Path)
    parser.add_argument("--states-output", type=Path)
    parser.add_argument("--layout-report", type=Path)
    return parser.parse_args()


def resolve(root: Path, value: str | Path) -> Path:
    path = Path(value)
    return path if path.is_absolute() else root / path


def ui_px(value: float, ui_scale: float, local_scale: float = 1.0) -> int:
    return max(1, round(value * ui_scale * local_scale))


def scale_box(box: list[int] | tuple[int, int, int, int], factor: float) -> tuple[int, int, int, int]:
    return tuple(round(value * factor) for value in box)  # type: ignore[return-value]


def offset_box(box: tuple[int, int, int, int], x: int, y: int) -> tuple[int, int, int, int]:
    return box[0] + x, box[1] + y, box[2] + x, box[3] + y


def contains(outer: list[int] | tuple[int, int, int, int], inner: list[int] | tuple[int, int, int, int]) -> bool:
    return outer[0] <= inner[0] and outer[1] <= inner[1] and outer[2] >= inner[2] and outer[3] >= inner[3]


def boxes_overlap(first: list[int] | tuple[int, int, int, int], second: list[int] | tuple[int, int, int, int]) -> bool:
    return first[0] < second[2] and first[2] > second[0] and first[1] < second[3] and first[3] > second[1]


def automatic_trinket_columns(count: int) -> int:
    if count > 24:
        return 5
    if count > 18:
        return 4
    if count > 12:
        return 3
    if count > 4:
        return 2
    return 1


def trinket_main_geometry(orientation: str) -> dict[str, Any]:
    if orientation == "HORIZONTAL":
        frame = [92, 52]
        buttons = [[8, 8, 44, 44], [48, 8, 84, 44]]
    else:
        frame = [52, 92]
        buttons = [[8, 8, 44, 44], [8, 48, 44, 84]]
    queues = [[button[0] - 2, button[1] - 2, button[0] + 16, button[1] + 16] for button in buttons]
    return {"frame": frame, "buttons": buttons, "queues": queues}


def trinket_menu_geometry(config: dict[str, Any]) -> dict[str, Any]:
    count = int(config["count"])
    if count == 0:
        return {"hidden": True, "frame": [0, 0], "buttons": [], "columns": 0, "rows": 0}
    columns = int(config["columns"]) if config.get("set_columns") else automatic_trinket_columns(count)
    columns = max(1, min(30, columns))
    rows = math.ceil(count / columns)
    orientation = str(config["orientation"])
    if orientation == "VERTICAL":
        frame = [12 + columns * 40, 12 + rows * 40]
        buttons = []
        for index in range(count):
            column = index % columns
            row_from_bottom = index // columns
            left = 8 + column * 40
            top = frame[1] - 44 - row_from_bottom * 40
            buttons.append([left, top, left + 36, top + 36])
    else:
        frame = [12 + rows * 40, 12 + columns * 40]
        buttons = []
        for index in range(count):
            row_from_bottom = index % columns
            column = index // columns
            left = 8 + column * 40
            top = frame[1] - 44 - row_from_bottom * 40
            buttons.append([left, top, left + 36, top + 36])
    return {"hidden": False, "frame": frame, "buttons": buttons, "columns": columns, "rows": rows}


def autobar_rack_geometry(config: dict[str, Any], padding: int = 6) -> dict[str, Any]:
    count = int(config["count"])
    columns = max(1, int(config["columns"]))
    displayed_columns = min(count, columns)
    displayed_rows = math.ceil(count / columns)
    button_width = 36
    button_height = 36
    gap = 3
    cluster_width = button_width + (displayed_columns - 1) * (button_width + gap)
    cluster_height = button_height + (displayed_rows - 1) * (button_height + gap)
    frame = [cluster_width + padding * 2, cluster_height + padding * 2]
    provider_frame = [displayed_columns * (button_width + gap) + 1, displayed_rows * (button_height + gap) + 1]
    buttons = []
    for index in range(count):
        column = index % columns
        row = index // columns
        left = padding + column * (button_width + gap)
        top = padding + row * (button_height + gap)
        buttons.append([left, top, left + button_width, top + button_height])
    return {
        "frame": frame,
        "provider_frame": provider_frame,
        "cluster": [padding, padding, padding + cluster_width, padding + cluster_height],
        "buttons": buttons,
        "displayed_columns": displayed_columns,
        "displayed_rows": displayed_rows,
    }


def autobar_grouped_rack_geometry(config: dict[str, Any]) -> dict[str, Any]:
    """Return a 24-button rack plus non-interactive type labels and seams.

    AutoBar still owns one uniform button grid.  The extra geometry lives
    outside the hit boxes and only explains the three contiguous slot ranges.
    """

    body = autobar_rack_geometry(config)
    columns = int(config["columns"])
    label_width = int(config.get("group_label_width_ui", 40))
    label_gap = int(config.get("group_label_gap_ui", 2))
    label_height = int(config.get("group_label_height_ui", 20))
    body_offset = label_width + label_gap
    step = 39
    labels: list[list[int]] = []
    dividers: list[list[int]] = []
    groups = list(config.get("groups", []))

    shifted_buttons = [
        [box[0] + body_offset, box[1], box[2] + body_offset, box[3]]
        for box in body["buttons"]
    ]
    for index, group in enumerate(groups):
        first_slot = int(group["start"]) - 1
        first_row = first_slot // columns
        label_top = max(0, 4 + first_row * step)
        labels.append([0, label_top, label_width, label_top + label_height])
        if index < len(groups) - 1:
            rows_in_group = math.ceil(int(group["count"]) / columns)
            divider_top = 3 + (first_row + rows_in_group) * step
            dividers.append(
                [body_offset + 6, divider_top, body_offset + body["frame"][0] - 6, divider_top + 3]
            )

    return {
        **body,
        "frame": [body_offset + body["frame"][0], body["frame"][1]],
        "body_frame": [body_offset, 0, body_offset + body["frame"][0], body["frame"][1]],
        "cluster": [
            body["cluster"][0] + body_offset,
            body["cluster"][1],
            body["cluster"][2] + body_offset,
            body["cluster"][3],
        ],
        "buttons": shifted_buttons,
        "group_labels": labels,
        "group_dividers": dividers,
        "groups": groups,
        "body_offset": body_offset,
    }


def autobar_popup_geometry(config: dict[str, Any], padding: int = 4) -> dict[str, Any]:
    count = int(config["count"])
    direction = str(config["direction"])
    step = 39
    buttons: list[list[int]] = []
    if direction in {"TOP", "BOTTOM"}:
        frame = [36 + padding * 2, 36 + (count - 1) * step + padding * 2]
        for index in range(count):
            top = padding + index * step
            buttons.append([padding, top, padding + 36, top + 36])
    else:
        frame = [36 + (count - 1) * step + padding * 2, 36 + padding * 2]
        for index in range(count):
            left = padding + index * step
            buttons.append([left, padding, left + 36, padding + 36])
    return {"frame": frame, "buttons": buttons, "direction": direction}


def autobar_drawer_geometry(config: dict[str, Any], padding: int = 4) -> dict[str, Any]:
    count = int(config["count"])
    maximum_rows = int(config.get("maximum_rows", 6))
    rows = count if count <= maximum_rows else math.ceil(count / 2)
    rows = max(1, min(maximum_rows, rows))
    columns = math.ceil(count / rows)
    step = 39
    buttons: list[list[int]] = []
    for index in range(count):
        column = index // rows
        row = index % rows
        left = padding + column * step
        top = padding + row * step
        buttons.append([left, top, left + 36, top + 36])
    frame = [
        padding * 2 + 36 + (columns - 1) * step,
        padding * 2 + 36 + (rows - 1) * step,
    ]
    spine = [frame[0] - 3, 0, frame[0], frame[1]]
    return {
        "frame": frame,
        "buttons": buttons,
        "rows": rows,
        "columns": columns,
        "spine": spine,
        "side": str(config.get("side", "LEFT")),
    }


def icon_colors(index: int) -> tuple[str, str]:
    colors = (
        ("#6f3529", "#e0ae61"),
        ("#3f5a3f", "#b7cf83"),
        ("#3e4e6a", "#92acd5"),
        ("#70552e", "#e0c27d"),
        ("#5a385e", "#ca9bcf"),
        ("#614a3b", "#cfb18a"),
        ("#31585c", "#8ac9ca"),
    )
    return colors[index % len(colors)]


def text(draw: ImageDraw.ImageDraw, xy: tuple[int, int], value: str, font: ImageFont.FreeTypeFont, fill: str, *, anchor: str | None = None) -> None:
    draw.text(xy, value, font=font, fill=core.rgba(fill), anchor=anchor, stroke_width=1, stroke_fill=core.rgba("#080706"))


def draw_item_button(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    index: int,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
    *,
    kind: str,
    cooldown: bool = False,
    count: str = "",
    queued: bool = False,
    selected: bool = False,
) -> None:
    x0, y0, x1, y1 = box
    width = x1 - x0
    inset = max(2, round(width * 0.10))
    if kind == "consumable":
        fill = palette["pouch_leather"]
        edge = palette["pouch_fold"]
        draw.rounded_rectangle(box, radius=max(2, width // 8), fill=core.rgba(fill), outline=core.rgba("#25160f"), width=max(1, width // 16))
        draw.line((x0 + inset, y0 + inset, x1 - inset, y0 + inset), fill=core.rgba(edge), width=max(1, width // 16))
        stitch_y = y0 + max(2, width // 7)
        for sx in range(x0 + inset, x1 - inset, max(5, width // 5)):
            draw.line((sx, stitch_y, min(x1 - inset, sx + max(2, width // 10)), stitch_y), fill=core.rgba("#c49a68", 150), width=1)
    elif kind == "candidate":
        draw.rounded_rectangle(box, radius=max(2, width // 9), fill=core.rgba(palette["trinket_insert"]), outline=core.rgba("#251811"), width=max(1, width // 18))
        draw.line((x0 + inset, y0 + 2, x1 - inset, y0 + 2), fill=core.rgba(palette["quiet_brass"], 145), width=max(1, width // 24))
    else:
        draw.rounded_rectangle(box, radius=max(2, width // 7), fill=core.rgba(palette["trinket_leather"]), outline=core.rgba("#17100c"), width=max(1, width // 12))
        draw.rounded_rectangle((x0 + 2, y0 + 2, x1 - 2, y1 - 2), radius=max(2, width // 9), outline=core.rgba(palette["quiet_brass"]), width=max(1, width // 18))
        clasp_w = max(4, width // 5)
        draw.rounded_rectangle((x0 + width // 2 - clasp_w // 2, y0, x0 + width // 2 + clasp_w // 2, y0 + max(4, width // 7)), radius=2, fill=core.rgba(palette["quiet_brass"]), outline=core.rgba("#312116"))

    icon = (x0 + inset, y0 + inset, x1 - inset, y1 - inset)
    background, glyph = icon_colors(index)
    draw.rectangle(icon, fill=core.rgba(background), outline=core.rgba("#100d0b"), width=1)
    core.draw_glyph(draw, icon, index + 3, core.rgba(glyph, 220))
    if cooldown:
        draw.rectangle(icon, fill=core.rgba("#050607", 145))
        text(draw, ((x0 + x1) // 2, (y0 + y1) // 2), "18", fonts["micro"], "#f1e6c7", anchor="mm")
    if selected:
        draw.rounded_rectangle((x0 + 1, y0 + 1, x1 - 1, y1 - 1), radius=max(2, width // 8), outline=core.rgba(palette["warm_edge"]), width=max(1, width // 14))
    if count:
        text(draw, (x1 - 2, y1 - 1), count, fonts["micro"], "#f1d18e", anchor="rd")
    if queued:
        queue_size = max(8, round(width * 0.5))
        queue_box = (x0 - max(1, width // 18), y0 - max(1, width // 18), x0 - max(1, width // 18) + queue_size, y0 - max(1, width // 18) + queue_size)
        draw.rounded_rectangle(queue_box, radius=2, fill=core.rgba("#21170f"), outline=core.rgba(palette["queue"]), width=max(1, width // 20))
        qx0, qy0, qx1, qy1 = queue_box
        draw.polygon([(qx0 + 3, qy0 + 3), (qx1 - 3, (qy0 + qy1) // 2), (qx0 + 3, qy1 - 3)], fill=core.rgba("#d7b069"))


def draw_rack(
    image: Image.Image,
    origin: tuple[int, int],
    config: dict[str, Any],
    factor: float,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
    *,
    label: str = "",
) -> tuple[int, int, int, int]:
    geometry = autobar_rack_geometry(config)
    width, height = (round(value * factor) for value in geometry["frame"])
    x, y = origin
    frame = (x, y, x + width, y + height)
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rounded_rectangle(frame, radius=max(7, round(10 * factor)), fill=core.rgba(palette["pouch_leather"], 244), outline=core.rgba(palette["pouch_dark"]), width=max(2, round(3 * factor)))
    draw.rounded_rectangle((x + 3, y + 3, x + width - 3, y + height - 3), radius=max(5, round(8 * factor)), outline=core.rgba(palette["pouch_fold"]), width=max(1, round(2 * factor)))
    band_height = max(5, round(8 * factor))
    draw.rectangle((x + round(8 * factor), y - band_height // 2, x + width - round(8 * factor), y + band_height), fill=core.rgba(palette["pouch_fold"]), outline=core.rgba(palette["quiet_brass"], 150), width=1)
    for index, raw_box in enumerate(geometry["buttons"]):
        box = offset_box(scale_box(raw_box, factor), x, y)
        draw_item_button(draw, box, index, fonts, palette, kind="consumable", cooldown=index in {2, 7}, count=("" if index in {4, 9} else str((index * 3 + 5) % 21 + 1)))
    if label:
        text(draw, ((frame[0] + frame[2]) // 2, frame[1] - max(10, round(11 * factor))), label, fonts["tiny"], palette["label"], anchor="ms")
    return frame


def draw_grouped_rack(
    image: Image.Image,
    origin: tuple[int, int],
    config: dict[str, Any],
    factor: float,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
    *,
    label: str = "",
) -> dict[str, Any]:
    geometry = autobar_grouped_rack_geometry(config)
    x, y = origin
    draw = ImageDraw.Draw(image, "RGBA")
    body_raw = geometry["body_frame"]
    body = offset_box(scale_box(body_raw, factor), x, y)
    full = (x, y, x + round(geometry["frame"][0] * factor), y + round(geometry["frame"][1] * factor))

    draw.rounded_rectangle(
        body,
        radius=max(7, round(10 * factor)),
        fill=core.rgba(palette["pouch_leather"], 244),
        outline=core.rgba(palette["pouch_dark"]),
        width=max(2, round(3 * factor)),
    )
    draw.rounded_rectangle(
        (body[0] + 3, body[1] + 3, body[2] - 3, body[3] - 3),
        radius=max(5, round(8 * factor)),
        outline=core.rgba(palette["pouch_fold"]),
        width=max(1, round(2 * factor)),
    )
    band_height = max(5, round(8 * factor))
    draw.rectangle(
        (body[0] + round(8 * factor), body[1] - band_height // 2, body[2] - round(8 * factor), body[1] + band_height),
        fill=core.rgba(palette["pouch_fold"]),
        outline=core.rgba(palette["quiet_brass"], 150),
        width=1,
    )

    for raw_box in geometry["group_dividers"]:
        divider = offset_box(scale_box(raw_box, factor), x, y)
        draw.rectangle(divider, fill=core.rgba(palette["pouch_dark"], 230))
        draw.line((divider[0], divider[1], divider[2], divider[1]), fill=core.rgba(palette["quiet_brass"], 120), width=1)

    label_boxes: list[tuple[int, int, int, int]] = []
    for group, raw_box in zip(geometry["groups"], geometry["group_labels"]):
        tab = offset_box(scale_box(raw_box, factor), x, y)
        label_boxes.append(tab)
        draw.rounded_rectangle(
            tab,
            radius=max(3, round(5 * factor)),
            fill=core.rgba(palette["pouch_leather"], 245),
            outline=core.rgba(palette["pouch_dark"]),
            width=max(1, round(2 * factor)),
        )
        draw.line(
            (tab[0] + 3, tab[1] + 2, tab[2] - 3, tab[1] + 2),
            fill=core.rgba(palette["quiet_brass"], 170),
            width=1,
        )
        text(draw, ((tab[0] + tab[2]) // 2, (tab[1] + tab[3]) // 2 + 1), str(group["label"]), fonts["micro"], palette["label"], anchor="mm")

    for index, raw_box in enumerate(geometry["buttons"]):
        box = offset_box(scale_box(raw_box, factor), x, y)
        draw_item_button(
            draw,
            box,
            index,
            fonts,
            palette,
            kind="consumable",
            cooldown=index in {1, 6, 10, 18},
            count=("" if index in {3, 11, 19, 23} else str((index * 3 + 5) % 21 + 1)),
        )
    if label:
        text(draw, ((body[0] + body[2]) // 2, full[1] - max(10, round(11 * factor))), label, fonts["tiny"], palette["label"], anchor="ms")
    return {"full": full, "body": body, "labels": label_boxes}


def draw_popup(
    image: Image.Image,
    origin: tuple[int, int],
    config: dict[str, Any],
    factor: float,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
) -> tuple[int, int, int, int]:
    geometry = autobar_popup_geometry(config)
    width, height = (round(value * factor) for value in geometry["frame"])
    x, y = origin
    draw = ImageDraw.Draw(image, "RGBA")
    frame = (x, y, x + width, y + height)
    for index, raw_box in enumerate(geometry["buttons"]):
        box = offset_box(scale_box(raw_box, factor), x, y)
        draw_item_button(draw, box, index + 20, fonts, palette, kind="consumable", cooldown=index == 3, count=str(index + 1), selected=index == 1)
    return frame


def draw_popup_drawer(
    image: Image.Image,
    origin: tuple[int, int],
    config: dict[str, Any],
    factor: float,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
) -> tuple[int, int, int, int]:
    geometry = autobar_drawer_geometry(config)
    width, height = (round(value * factor) for value in geometry["frame"])
    x, y = origin
    draw = ImageDraw.Draw(image, "RGBA")
    frame = (x, y, x + width, y + height)
    spine = offset_box(scale_box(geometry["spine"], factor), x, y)
    draw.rectangle(spine, fill=core.rgba(palette["pouch_dark"], 235))
    draw.line(
        (spine[0], spine[1], spine[0], spine[3]),
        fill=core.rgba(palette["quiet_brass"], 155),
        width=1,
    )
    for index, raw_box in enumerate(geometry["buttons"]):
        box = offset_box(scale_box(raw_box, factor), x, y)
        draw_item_button(
            draw,
            box,
            index + 20,
            fonts,
            palette,
            kind="consumable",
            cooldown=index == 3,
            count=str(index + 1),
            selected=index == 1,
        )
    return frame


def draw_trinket_main(
    image: Image.Image,
    origin: tuple[int, int],
    orientation: str,
    factor: float,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
    *,
    queue_slots: list[int] | None = None,
    label: str = "",
) -> tuple[int, int, int, int]:
    geometry = trinket_main_geometry(orientation)
    width, height = (round(value * factor) for value in geometry["frame"])
    x, y = origin
    frame = (x, y, x + width, y + height)
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rounded_rectangle(frame, radius=max(5, round(7 * factor)), fill=core.rgba(palette["trinket_leather"], 242), outline=core.rgba("#17100c"), width=max(2, round(3 * factor)))
    draw.rounded_rectangle((x + 2, y + 2, x + width - 2, y + height - 2), radius=max(4, round(6 * factor)), outline=core.rgba(palette["quiet_brass"], 200), width=max(1, round(2 * factor)))
    for index, raw_box in enumerate(geometry["buttons"]):
        box = offset_box(scale_box(raw_box, factor), x, y)
        draw_item_button(draw, box, index + 40, fonts, palette, kind="trinket", cooldown=index == 1, queued=index in (queue_slots or []), selected=index == 0)
    if label:
        text(draw, ((frame[0] + frame[2]) // 2, frame[1] - max(10, round(11 * factor))), label, fonts["tiny"], palette["label"], anchor="ms")
    return frame


def draw_trinket_menu(
    image: Image.Image,
    origin: tuple[int, int],
    config: dict[str, Any],
    factor: float,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
) -> tuple[int, int, int, int] | None:
    geometry = trinket_menu_geometry(config)
    if geometry["hidden"]:
        return None
    width, height = (round(value * factor) for value in geometry["frame"])
    x, y = origin
    frame = (x, y, x + width, y + height)
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rounded_rectangle(frame, radius=max(4, round(6 * factor)), fill=core.rgba("#291c16", 238), outline=core.rgba("#17100c"), width=max(1, round(3 * factor)))
    draw.rounded_rectangle((x + 2, y + 2, x + width - 2, y + height - 2), radius=max(3, round(5 * factor)), outline=core.rgba(palette["quiet_brass"], 160), width=max(1, round(2 * factor)))
    for index, raw_box in enumerate(geometry["buttons"]):
        box = offset_box(scale_box(raw_box, factor), x, y)
        draw_item_button(draw, box, index + 60, fonts, palette, kind="candidate", cooldown=index in {2, 6, 17}, selected=index == 4)
    return frame


def draw_scene(root: Path, spec: dict[str, Any], output: Path) -> dict[str, Any]:
    base = core.load_spec(resolve(root, spec["base_scene_spec"]).resolve(), root)
    base["annotations"] = spec.get(
        "scene_annotations",
        {
            "title": "动作栏 / 随身栏 · 饰品与消耗品 V1",
            "subtitle": "两侧独立随身装备，不挤压中央技能冷却视线",
            "note": "本地几何模拟 · 非 source / runtime · ImageGen 0/0",
            "rules_title": "本次要确认",
            "rules": [
                "TrinketMenu 双槽保留原插件比例与交互",
                "候选饰品沿当前右侧 / 向上方式展开",
                "AutoBar 只做可选 5×2 预设，不自动启用",
                "两套栏位独立拖动、缩放、显隐与回退",
                "图标、数量、冷却、排队和 Tooltip 全动态",
            ],
        },
    )
    canvas = base["canvas"]
    image = Image.new("RGBA", (int(canvas["width"]), int(canvas["height"])), core.rgba(canvas["fill"]))
    draw = ImageDraw.Draw(image, "RGBA")
    palette = {**base["palette"], **spec["palette"]}
    fonts = {name: core.load_font(root, definition) for name, definition in base["fonts"].items()}
    ui_scale = float(spec["target"]["ui_scale"])

    core.draw_scene(image, draw, palette)
    core.draw_placeholder_ui_v2(draw, fonts, palette, base)
    for bar in base["bars"]:
        core.draw_bar(draw, bar, ui_scale, fonts, palette)

    main = base["bars"][0]
    mx, my, mw, mh, _, _, _ = core.bar_geometry(main, ui_scale)
    draw.rectangle((mx, my + mh + 6, mx + mw, my + mh + 12), fill=core.rgba("#24170f"), outline=core.rgba("#80623d"), width=1)
    draw.rectangle((mx + 2, my + mh + 8, mx + int(mw * 0.64), my + mh + 10), fill=core.rgba("#756343"))

    consumable = spec["scene"]["consumable"]
    rack_factor = ui_scale * float(consumable["local_scale"])
    rack_config = {
        "count": consumable["buttons"],
        "columns": consumable["columns"],
        "rows": consumable["rows"],
        "groups": consumable.get("groups", []),
        "group_label_width_ui": consumable.get("group_label_width_ui", 40),
        "group_label_gap_ui": consumable.get("group_label_gap_ui", 2),
        "group_label_height_ui": consumable.get("group_label_height_ui", 20),
    }
    grouped = bool(rack_config["groups"])
    if grouped:
        rack_parts = draw_grouped_rack(
            image,
            tuple(consumable["origin_px"]),
            rack_config,
            rack_factor,
            fonts,
            palette,
            label=consumable["label"],
        )
        rack = rack_parts["full"]
        rack_body = rack_parts["body"]
        rack_labels = rack_parts["labels"]
    else:
        rack = draw_rack(
            image,
            tuple(consumable["origin_px"]),
            rack_config,
            rack_factor,
            fonts,
            palette,
            label=consumable["label"],
        )
        rack_body = rack
        rack_labels = []

    trinket = spec["scene"]["trinket"]
    main_factor = ui_scale * float(trinket["main_scale"])
    dock = draw_trinket_main(image, tuple(trinket["origin_px"]), trinket["main_orientation"], main_factor, fonts, palette, queue_slots=[0], label=trinket["label"])

    # Compact callouts state the runtime ownership without masking combat content.
    callout_y = rack[1] - 62
    draw.rounded_rectangle((rack[0], callout_y, rack[2], callout_y + 36), radius=6, fill=core.rgba("#17110d", 215), outline=core.rgba("#705235"), width=1)
    rack_callout = (
        "已由用户启用 · 左侧软吸附"
        if spec["current_device"]["auto_bar"]["enabled_for_current_character"]
        else "当前未启用 · 仅展示可选布局"
    )
    text(draw, ((rack[0] + rack[2]) // 2, callout_y + 18), rack_callout, fonts["micro"], "#d9bd85", anchor="mm")
    draw.rounded_rectangle((dock[0], dock[1] - 62, dock[2] + 76, dock[1] - 26), radius=6, fill=core.rgba("#17110d", 215), outline=core.rgba("#705235"), width=1)
    text(draw, ((dock[0] + dock[2] + 76) // 2, dock[1] - 44), "现用插件 · 排队角标保留", fonts["micro"], "#d9bd85", anchor="mm")

    output.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(output, format="PNG", optimize=False, compress_level=9)
    return {
        "actionbar": spec["scene"]["actionbar_box_px"],
        "consumable": list(rack),
        "consumable_body": list(rack_body),
        "consumable_labels": [list(box) for box in rack_labels],
        "trinket": list(dock),
    }


def panel(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], title_value: str, fonts: dict[str, ImageFont.FreeTypeFont]) -> None:
    draw.rounded_rectangle(box, radius=12, fill=core.rgba("#1c1713"), outline=core.rgba("#735535"), width=2)
    draw.rectangle((box[0] + 1, box[1] + 50, box[2] - 1, box[1] + 52), fill=core.rgba("#4d3524"))
    text(draw, (box[0] + 22, box[1] + 25), title_value, fonts["heading"], "#ead4a0", anchor="lm")


def draw_states_board(root: Path, spec: dict[str, Any], output: Path) -> None:
    base = core.load_spec(resolve(root, spec["base_scene_spec"]).resolve(), root)
    fonts = {name: core.load_font(root, definition) for name, definition in base["fonts"].items()}
    palette = {**base["palette"], **spec["palette"]}
    image = Image.new("RGBA", (1920, 1200), core.rgba("#111613"))
    draw = ImageDraw.Draw(image, "RGBA")
    text(draw, (42, 34), "AB.FIELDKIT.V1 · Provider 真实几何状态板", fonts["title"], "#edd7a2")
    provider_state = (
        "左：当前启用的 TrinketMenu　右：用户已启用并应用 4×6 分组的 AutoBar"
        if spec["current_device"]["auto_bar"]["enabled_for_current_character"]
        else "左：当前启用的 TrinketMenu　右：已安装但当前禁用的 AutoBar"
    )
    text(draw, (42, 76), provider_state, fonts["body"], "#c7b897")
    text(draw, (42, 108), "这里只确认布局、材质层级与视觉重量；所有图标、数字与纹理均为非权威占位。", fonts["small"], "#a99a7c")

    left_panel = (30, 142, 945, 1145)
    right_panel = (975, 142, 1890, 1145)
    panel(draw, left_panel, "饰品 · TrinketMenu 3.3 无损换肤", fonts)
    panel(draw, right_panel, "消耗品 · AutoBar 1.31 可选视觉桥接", fonts)

    # Current TrinketMenu configuration: horizontal main, four-column vertical menu.
    text(draw, (60, 220), "当前配置：主栏 92×52 UI / scale 0.904；菜单 4 列、向右停靠并向上增长", fonts["small"], "#d8c49a")
    current_main_origin = (72, 360)
    current_factor = 1.75
    main_box = draw_trinket_main(image, current_main_origin, "HORIZONTAL", current_factor, fonts, palette, queue_slots=[0], label="双槽 + 18×18 排队角标")
    menu_config = {"count": 8, "orientation": "VERTICAL", "set_columns": True, "columns": 4}
    menu_geom = trinket_menu_geometry(menu_config)
    menu_width = round(menu_geom["frame"][0] * current_factor)
    menu_height = round(menu_geom["frame"][1] * current_factor)
    menu_origin = (main_box[2] - round(4 * current_factor), main_box[3] - menu_height)
    draw_trinket_menu(image, menu_origin, menu_config, current_factor, fonts, palette)
    text(draw, (72, 516), "代表实例：8 个背包饰品 → 172×92 UI；左键换入 13，右键换入 14", fonts["tiny"], "#bdae8d")

    text(draw, (60, 570), "方向与空态", fonts["small"], "#d8c49a")
    draw_trinket_main(image, (72, 620), "VERTICAL", 1.25, fonts, palette, queue_slots=[1], label="52×92 UI 竖向")
    draw.rounded_rectangle((260, 608, 440, 700), radius=8, fill=core.rgba("#18130f"), outline=core.rgba("#5c432c"), width=2)
    text(draw, (350, 645), "0 个候选", fonts["small"], "#d7c398", anchor="mm")
    text(draw, (350, 676), "菜单完全隐藏", fonts["tiny"], "#a99a7c", anchor="mm")
    horizontal_config = {"count": 8, "orientation": "HORIZONTAL", "set_columns": True, "columns": 4}
    draw_trinket_menu(image, (510, 588), horizontal_config, 0.95, fonts, palette)
    text(draw, (644, 766), "右键菜单框切换后：92×172 UI", fonts["tiny"], "#bdae8d", anchor="mm")

    text(draw, (60, 810), "密度边界", fonts["small"], "#d8c49a")
    maximum_config = {"count": 30, "orientation": "VERTICAL", "set_columns": True, "columns": 4}
    draw_trinket_menu(image, (72, 858), maximum_config, 0.62, fonts, palette)
    text(draw, (190, 1080), "当前 4 列上限：30 个 → 172×332 UI", fonts["tiny"], "#bdae8d", anchor="mm")
    wide_config = {"count": 30, "orientation": "VERTICAL", "set_columns": True, "columns": 30}
    draw_trinket_menu(image, (360, 890), wide_config, 0.42, fonts, palette)
    text(draw, (618, 940), "合法极宽：30 列 → 1212×52 UI", fonts["tiny"], "#bdae8d", anchor="mm")

    # AutoBar optional recommendation and provider limits.
    if str(spec["version"]) in {"AB-FIELDKIT-SIM-V2", "AB-FIELDKIT-SIM-V3"}:
        text(draw, (1005, 220), "修订建议：完整 24 个类别槽，4×6；每两行一组，仍由 AutoBar 选择真实物品", fonts["small"], "#d8c49a")
        grouped_config = {
            "count": 24,
            "columns": 4,
            "rows": 6,
            "groups": spec["consumable_contract"]["recommended_profile"]["groups"],
            "group_label_width_ui": 40,
            "group_label_gap_ui": 2,
            "group_label_height_ui": 20,
        }
        draw_grouped_rack(image, (1015, 278), grouped_config, 1.25, fonts, palette, label="24 类随身卷袋 · 三组各 8 格")
        text(draw, (1298, 268), "应急", fonts["small"], "#e1c995")
        text(draw, (1298, 302), "生命 / 资源 / 双恢复 / 绷带", fonts["tiny"], "#bdae8d")
        text(draw, (1298, 330), "解毒 / 行动 / 机动 / 场景", fonts["tiny"], "#bdae8d")
        text(draw, (1298, 384), "增益", fonts["small"], "#e1c995")
        text(draw, (1298, 418), "战斗药剂 / 守护药剂 / 元素防护 / 卷轴", fonts["tiny"], "#bdae8d")
        text(draw, (1298, 446), "食物 / 饮料 / 增益食物 / 合剂手动", fonts["tiny"], "#bdae8d")
        text(draw, (1298, 500), "工具", fonts["small"], "#e1c995")
        text(draw, (1298, 534), "武器强化 / 职业用品 / 炉石 / 坐骑", fonts["tiny"], "#bdae8d")
        text(draw, (1298, 562), "工程 / 钓鱼 / 战场事件 / 任务物品", fonts["tiny"], "#bdae8d")
        text(draw, (1005, 622), "标签与分隔线不接收鼠标；配置不匹配该预设时隐藏标签，退回单一自适应外壳。", fonts["tiny"], "#bdae8d")

        if str(spec["version"]) == "AB-FIELDKIT-SIM-V3":
            text(draw, (1005, 684), "外置候选抽屉：1–6 项单列；7–12 项双列，整组位于卷袋外侧，不覆盖任何母格", fonts["small"], "#d8c49a")
            first_drawer = draw_popup_drawer(
                image,
                (1030, 724),
                {"count": 6, "side": "LEFT", "maximum_rows": 6},
                0.62,
                fonts,
                palette,
            )
            second_drawer = draw_popup_drawer(
                image,
                (1140, 724),
                {"count": 12, "side": "LEFT", "maximum_rows": 6},
                0.62,
                fonts,
                palette,
            )
            text(draw, (first_drawer[0], first_drawer[3] + 22), "6 项 · 1×6", fonts["tiny"], "#bdae8d")
            text(draw, (second_drawer[0], second_drawer[3] + 22), "12 项 · 2×6", fonts["tiny"], "#bdae8d")
            text(draw, (1340, 756), "AUTO：停靠左侧时向左展开", fonts["tiny"], "#bdae8d")
            text(draw, (1340, 786), "自由摆放时按屏幕余量选边", fonts["tiny"], "#bdae8d")
            text(draw, (1340, 816), "自定义配置不匹配则回退原生", fonts["tiny"], "#bdae8d")
            text(draw, (1340, 846), "图标 / CD / 点击 / Tooltip 不变", fonts["tiny"], "#bdae8d")
        else:
            text(draw, (1005, 684), "分类内候选仍用原生 popup：每个主槽悬停后最多 12 个真实物品，上下左右展开", fonts["small"], "#d8c49a")
            popup_box = draw_popup(image, (1030, 730), {"count": 6, "direction": "RIGHT"}, 0.90, fonts, palette)
            text(draw, (popup_box[0], popup_box[3] + 24), "代表 6 项；最大 12 项；不使用固定大面板", fonts["tiny"], "#bdae8d")

        text(draw, (1005, 875), "兼容而非推荐：原 5×2、24×1、1×24 与用户自定义行列继续有效", fonts["small"], "#d8c49a")
        draw_rack(image, (1015, 930), {"count": 10, "columns": 5, "rows": 2}, 0.80, fonts, palette, label="5×2 紧凑模式")
        draw_rack(image, (1235, 948), {"count": 24, "columns": 24, "rows": 1}, 0.45, fonts, palette, label="24×1 容量模式")
        profile_note = (
            "AutoBar 已由用户主动启用并应用分类预设；AEUI 仍保留恢复入口，不在普通刷新中重写配置。"
            if spec["current_device"]["auto_bar"]["enabled_for_current_character"]
            else "AutoBar 当前仍未启用；分类预设只在用户主动应用时写入一次，并保留恢复入口。"
        )
        text(draw, (1015, 1050), profile_note, fonts["tiny"], "#bdae8d")
    else:
        text(draw, (1005, 220), "建议预设：10 个真实分类按钮，5×2，36 UI，间隔 3 UI；只在用户主动应用时启用", fonts["small"], "#d8c49a")
        draw_rack(image, (1015, 285), {"count": 10, "columns": 5, "rows": 2}, 1.55, fonts, palette, label="炼金师卷袋 · 不烘焙瓶子或类别")
        text(draw, (1015, 454), "可见按钮簇 192×75 UI；自适应外壳 204×87 UI", fonts["tiny"], "#bdae8d")

        text(draw, (1005, 510), "弹出层：复用独立薄皮口袋，不依赖 AutoBarPopupFrame 的 72×72 初始尺寸", fonts["small"], "#d8c49a")
        popup_box = draw_popup(image, (1040, 560), {"count": 6, "direction": "TOP"}, 1.1, fonts, palette)
        text(draw, (popup_box[2] + 24, popup_box[1] + 16), "代表 6 项", fonts["tiny"], "#bdae8d")
        text(draw, (popup_box[2] + 24, popup_box[1] + 42), "最大 12 项", fonts["tiny"], "#bdae8d")
        text(draw, (popup_box[2] + 24, popup_box[1] + 68), "上下左右均由 provider 决定", fonts["tiny"], "#bdae8d")

        text(draw, (1005, 865), "已保存但当前未启用的 24×1 布局（容量检查，不是推荐默认）", fonts["small"], "#d8c49a")
        draw_rack(image, (1015, 915), {"count": 24, "columns": 24, "rows": 1}, 0.70, fonts, palette)
        text(draw, (1015, 1000), "同一外壳还支持 1×24；adapter 只跟随真实按钮边界，不重写分类与位置。", fonts["tiny"], "#bdae8d")

    text(draw, (960, 1173), "本地几何模拟 · ImageGen 0/0 · 不得作为 source、runtime 或外部生成输入", fonts["small"], "#b49c70", anchor="mm")
    output.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(output, format="PNG", optimize=False, compress_level=9)


def validate(spec: dict[str, Any], scene_boxes: dict[str, Any]) -> dict[str, Any]:
    checks: list[dict[str, Any]] = []

    def check(identifier: str, passed: bool, **details: Any) -> None:
        checks.append({"id": identifier, "pass": bool(passed), **details})

    contract = spec["scene"]["clearance_px"]
    actionbar = scene_boxes["actionbar"]
    rack = scene_boxes["consumable"]
    rack_body = scene_boxes["consumable_body"]
    rack_labels = scene_boxes["consumable_labels"]
    dock = scene_boxes["trinket"]
    if rack_labels:
        player_left = int(contract["player_frame_left"])
        chat = contract["chat_box"]
        check("scene.consumable-body-left-of-player", rack_body[2] <= player_left, rack_body=rack_body, player_left=player_left)
        check("scene.consumable-body-player-clearance", player_left - rack_body[2] == int(contract["consumable_body_to_player"]), actual=player_left - rack_body[2])
        check("scene.consumable-body-chat-clearance", rack_body[0] - int(chat[2]) == int(contract["chat_to_consumable_body"]), actual=rack_body[0] - int(chat[2]))
        check("scene.group-labels-clear-chat", all(box[3] <= int(chat[1]) or not boxes_overlap(box, chat) for box in rack_labels), labels=rack_labels, chat=chat)
        check("scene.consumable-body-main-clearance", actionbar[0] - rack_body[2] == int(contract["consumable_body_to_main"]), actual=actionbar[0] - rack_body[2])
    else:
        check("scene.consumable-left-of-actionbar", rack[2] <= actionbar[0], rack=rack, actionbar=actionbar)
        check("scene.consumable-clearance", actionbar[0] - rack[2] == int(contract["consumable_to_main"]), actual=actionbar[0] - rack[2])
    check("scene.trinket-right-of-actionbar", dock[0] >= actionbar[2], trinket=dock, actionbar=actionbar)
    check("scene.trinket-clearance", dock[0] - actionbar[2] == int(contract["main_to_trinket"]), actual=dock[0] - actionbar[2])
    check("scene.shared-bottom-consumable", rack_body[3] == int(contract["shared_bottom_y"]), actual=rack_body[3])
    check("scene.shared-bottom-trinket", dock[3] == int(contract["shared_bottom_y"]), actual=dock[3])

    for scenario in spec["trinket_scenarios"]:
        identifier = str(scenario["id"])
        if scenario["kind"] == "main":
            geometry = trinket_main_geometry(str(scenario["orientation"]))
            frame_box = [0, 0, *geometry["frame"]]
            check(f"{identifier}.two-buttons", len(geometry["buttons"]) == 2)
            check(f"{identifier}.buttons-contained", all(contains(frame_box, box) for box in geometry["buttons"]))
            check(f"{identifier}.queues-contained", all(contains(frame_box, box) for box in geometry["queues"]))
            check(f"{identifier}.buttons-disjoint", not boxes_overlap(geometry["buttons"][0], geometry["buttons"][1]))
        else:
            geometry = trinket_menu_geometry(scenario)
            if int(scenario["count"]) == 0:
                check(f"{identifier}.hidden", geometry["hidden"] and not geometry["buttons"])
                continue
            frame_box = [0, 0, *geometry["frame"]]
            check(f"{identifier}.count", len(geometry["buttons"]) == int(scenario["count"]), actual=len(geometry["buttons"]))
            check(f"{identifier}.buttons-contained", all(contains(frame_box, box) for box in geometry["buttons"]))
            check(f"{identifier}.frame-positive", min(geometry["frame"]) > 0, frame=geometry["frame"])
            check(f"{identifier}.no-button-overlap", all(not boxes_overlap(first, second) for index, first in enumerate(geometry["buttons"]) for second in geometry["buttons"][index + 1:]))

    for scenario in spec["consumable_scenarios"]:
        identifier = str(scenario["id"])
        if scenario["kind"] == "grouped-rack":
            geometry = autobar_grouped_rack_geometry(scenario)
        elif scenario["kind"] == "rack":
            geometry = autobar_rack_geometry(scenario)
        elif scenario["kind"] == "drawer":
            geometry = autobar_drawer_geometry(scenario)
        else:
            geometry = autobar_popup_geometry(scenario)
        frame_box = [0, 0, *geometry["frame"]]
        check(f"{identifier}.count", len(geometry["buttons"]) == int(scenario["count"]), actual=len(geometry["buttons"]))
        check(f"{identifier}.buttons-contained", all(contains(frame_box, box) for box in geometry["buttons"]))
        check(f"{identifier}.no-button-overlap", all(not boxes_overlap(first, second) for index, first in enumerate(geometry["buttons"]) for second in geometry["buttons"][index + 1:]))
        if scenario["kind"] == "drawer":
            check(f"{identifier}.maximum-six-rows", int(geometry["rows"]) <= 6, actual=geometry["rows"])
            check(f"{identifier}.maximum-two-columns", int(geometry["columns"]) <= 2, actual=geometry["columns"])
        if scenario["kind"] == "grouped-rack":
            groups = geometry["groups"]
            slot_ranges = [
                list(range(int(group["start"]), int(group["start"]) + int(group["count"])))
                for group in groups
            ]
            flattened = [slot for slot_range in slot_ranges for slot in slot_range]
            check(f"{identifier}.three-groups", len(groups) == 3, actual=len(groups))
            check(f"{identifier}.eight-slots-per-group", all(len(slot_range) == 8 for slot_range in slot_ranges), ranges=slot_ranges)
            check(f"{identifier}.groups-cover-1-24", flattened == list(range(1, 25)), actual=flattened)
            check(f"{identifier}.labels-contained", all(contains(frame_box, box) for box in geometry["group_labels"]))
            check(f"{identifier}.labels-clear-buttons", all(not boxes_overlap(label, button) for label in geometry["group_labels"] for button in geometry["buttons"]))
            check(f"{identifier}.two-divider-seams", len(geometry["group_dividers"]) == 2, actual=len(geometry["group_dividers"]))

    check("provider.trinket-enabled", spec["current_device"]["trinket_menu"]["enabled_for_current_character"] is True)
    if str(spec["version"]) == "AB-FIELDKIT-SIM-V3":
        check("provider.autobar-user-enabled", spec["current_device"]["auto_bar"]["enabled_for_current_character"] is True)
    else:
        check("provider.autobar-remains-disabled", spec["current_device"]["auto_bar"]["enabled_for_current_character"] is False)
    check("simulation.imagegen-zero", spec["imagegen"] == {"used": 0, "limit": 0})
    violations = [item["id"] for item in checks if not item["pass"]]
    return {
        "schema": "aeui-action-fieldkit-simulation-report-v1",
        "version": spec["version"],
        "status": "pass" if not violations else "fail",
        "checks": checks,
        "check_count": len(checks),
        "violations": violations,
        "first_failure": violations[0] if violations else None,
        "imagegen": spec["imagegen"],
        "scene_boxes_px": scene_boxes,
    }


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    spec = json.loads(args.spec.read_text(encoding="utf-8"))
    outputs = spec["outputs"]
    scene_output = resolve(root, args.scene_output or outputs["scene"])
    states_output = resolve(root, args.states_output or outputs["states"])
    report_output = resolve(root, args.layout_report or outputs["layout_report"])

    scene_boxes = draw_scene(root, spec, scene_output)
    draw_states_board(root, spec, states_output)
    report = validate(spec, scene_boxes)
    report_output.parent.mkdir(parents=True, exist_ok=True)
    report_output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(scene_output.resolve())
    print(states_output.resolve())
    print(report_output.resolve())
    if report["status"] != "pass":
        raise SystemExit(1)


if __name__ == "__main__":
    main()
