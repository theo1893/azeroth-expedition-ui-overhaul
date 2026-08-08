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


def draw_scene(root: Path, spec: dict[str, Any], output: Path) -> dict[str, list[int]]:
    base = core.load_spec(resolve(root, spec["base_scene_spec"]).resolve(), root)
    base["annotations"] = {
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
    }
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
    rack = draw_rack(image, tuple(consumable["origin_px"]), {"count": consumable["buttons"], "columns": consumable["columns"], "rows": consumable["rows"]}, rack_factor, fonts, palette, label=consumable["label"])

    trinket = spec["scene"]["trinket"]
    main_factor = ui_scale * float(trinket["main_scale"])
    dock = draw_trinket_main(image, tuple(trinket["origin_px"]), trinket["main_orientation"], main_factor, fonts, palette, queue_slots=[0], label=trinket["label"])

    # Compact callouts state the runtime ownership without masking combat content.
    callout_y = rack[1] - 62
    draw.rounded_rectangle((rack[0], callout_y, rack[2], callout_y + 36), radius=6, fill=core.rgba("#17110d", 215), outline=core.rgba("#705235"), width=1)
    text(draw, ((rack[0] + rack[2]) // 2, callout_y + 18), "当前未启用 · 仅展示可选布局", fonts["micro"], "#d9bd85", anchor="mm")
    draw.rounded_rectangle((dock[0], dock[1] - 62, dock[2] + 76, dock[1] - 26), radius=6, fill=core.rgba("#17110d", 215), outline=core.rgba("#705235"), width=1)
    text(draw, ((dock[0] + dock[2] + 76) // 2, dock[1] - 44), "现用插件 · 排队角标保留", fonts["micro"], "#d9bd85", anchor="mm")

    output.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(output, format="PNG", optimize=False, compress_level=9)
    return {"actionbar": spec["scene"]["actionbar_box_px"], "consumable": list(rack), "trinket": list(dock)}


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
    text(draw, (42, 76), "左：当前启用的 TrinketMenu　右：已安装但当前禁用的 AutoBar", fonts["body"], "#c7b897")
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


def validate(spec: dict[str, Any], scene_boxes: dict[str, list[int]]) -> dict[str, Any]:
    checks: list[dict[str, Any]] = []

    def check(identifier: str, passed: bool, **details: Any) -> None:
        checks.append({"id": identifier, "pass": bool(passed), **details})

    contract = spec["scene"]["clearance_px"]
    actionbar = scene_boxes["actionbar"]
    rack = scene_boxes["consumable"]
    dock = scene_boxes["trinket"]
    check("scene.consumable-left-of-actionbar", rack[2] <= actionbar[0], rack=rack, actionbar=actionbar)
    check("scene.consumable-clearance", actionbar[0] - rack[2] == int(contract["consumable_to_main"]), actual=actionbar[0] - rack[2])
    check("scene.trinket-right-of-actionbar", dock[0] >= actionbar[2], trinket=dock, actionbar=actionbar)
    check("scene.trinket-clearance", dock[0] - actionbar[2] == int(contract["main_to_trinket"]), actual=dock[0] - actionbar[2])
    check("scene.shared-bottom-consumable", rack[3] == int(contract["shared_bottom_y"]), actual=rack[3])
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
        geometry = autobar_rack_geometry(scenario) if scenario["kind"] == "rack" else autobar_popup_geometry(scenario)
        frame_box = [0, 0, *geometry["frame"]]
        check(f"{identifier}.count", len(geometry["buttons"]) == int(scenario["count"]), actual=len(geometry["buttons"]))
        check(f"{identifier}.buttons-contained", all(contains(frame_box, box) for box in geometry["buttons"]))
        check(f"{identifier}.no-button-overlap", all(not boxes_overlap(first, second) for index, first in enumerate(geometry["buttons"]) for second in geometry["buttons"][index + 1:]))

    check("provider.trinket-enabled", spec["current_device"]["trinket_menu"]["enabled_for_current_character"] is True)
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
