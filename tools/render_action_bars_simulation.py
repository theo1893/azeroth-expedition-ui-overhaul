#!/usr/bin/env python3
"""Render the deterministic Action Bars V1 direction simulation.

This output is a non-production layout/material mockup. It deliberately uses
flat geometry and abstract glyphs instead of game icons or generated assets.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, ImageFont


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument("--output", type=Path)
    return parser.parse_args()


def rgba(value: str, alpha: int | None = None) -> tuple[int, int, int, int]:
    value = value.removeprefix("#")
    if len(value) == 6:
        color = tuple(int(value[index:index + 2], 16) for index in (0, 2, 4))
        return color + ((255 if alpha is None else alpha),)
    if len(value) == 8:
        color = tuple(int(value[index:index + 2], 16) for index in (0, 2, 4, 6))
        return color if alpha is None else color[:3] + (alpha,)
    raise ValueError(f"unsupported color: {value}")


def load_font(root: Path, definition: dict[str, Any]) -> ImageFont.FreeTypeFont:
    path = Path(definition["path"])
    if not path.is_absolute():
        path = root / path
    return ImageFont.truetype(str(path), int(definition["size"]))


def draw_text(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    font: ImageFont.FreeTypeFont,
    fill: tuple[int, int, int, int],
    *,
    anchor: str | None = None,
    stroke: int = 0,
    stroke_fill: tuple[int, int, int, int] | None = None,
) -> None:
    draw.text(
        xy,
        text,
        font=font,
        fill=fill,
        anchor=anchor,
        stroke_width=stroke,
        stroke_fill=stroke_fill,
    )


def draw_scene(
    image: Image.Image,
    draw: ImageDraw.ImageDraw,
    palette: dict[str, str],
) -> None:
    width, height = image.size
    sky_top = rgba(palette["scene_sky_top"])
    sky_bottom = rgba(palette["scene_sky_bottom"])
    for y in range(height):
        t = y / max(1, height - 1)
        color = tuple(round(sky_top[i] * (1 - t) + sky_bottom[i] * t) for i in range(4))
        draw.line((0, y, width, y), fill=color)

    draw.polygon(
        [(0, 490), (245, 330), (455, 510), (680, 300), (910, 500),
         (1180, 280), (1450, 500), (1660, 345), (1920, 500), (1920, 720), (0, 720)],
        fill=rgba("#142823", 235),
    )
    draw.polygon(
        [(0, 650), (300, 500), (610, 655), (900, 505), (1240, 665),
         (1540, 490), (1920, 650), (1920, 880), (0, 880)],
        fill=rgba("#1a2c26", 245),
    )
    draw.rectangle((0, 690, width, height), fill=rgba("#18241f", 245))
    for x, y, radius in ((910, 560, 26), (1010, 510, 18), (1080, 590, 14)):
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=rgba("#253a2d", 210))
        draw.rectangle((x - 3, y, x + 3, y + 80), fill=rgba("#151d19", 230))

    # Player and target silhouettes provide scale without pretending to be art assets.
    draw.ellipse((936, 548, 982, 594), fill=rgba("#111713", 240))
    draw.polygon([(927, 602), (994, 602), (1010, 735), (912, 735)], fill=rgba("#101612", 240))
    draw.line([(930, 642), (862, 704)], fill=rgba("#0b100d", 245), width=12)
    draw.line([(990, 642), (1056, 702)], fill=rgba("#0b100d", 245), width=12)
    draw.ellipse((1170, 522, 1215, 567), fill=rgba("#2c1613", 230))
    draw.polygon([(1155, 574), (1232, 574), (1252, 706), (1138, 706)], fill=rgba("#221411", 230))

    # Soft edge vignette.
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    shade = ImageDraw.Draw(overlay, "RGBA")
    for inset, alpha in ((0, 110), (20, 75), (45, 45), (75, 24)):
        shade.rectangle((inset, inset, width - inset - 1, height - inset - 1), outline=(4, 7, 6, alpha), width=20)
    image.alpha_composite(overlay)


def draw_placeholder_ui(
    draw: ImageDraw.ImageDraw,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
) -> None:
    ink = rgba(palette["ink"])
    muted = rgba(palette["muted_ink"])
    leather = rgba(palette["leather"], 218)
    brass = rgba(palette["brass"], 225)
    parchment = rgba(palette["parchment"], 225)

    # Unit frames.
    for box, title, hp in (
        ((408, 708, 646, 765), "玩家单位框（邻接占位）", 0.76),
        ((1274, 708, 1512, 765), "目标单位框（邻接占位）", 0.58),
    ):
        draw.rounded_rectangle(box, radius=7, fill=leather, outline=brass, width=2)
        x0, y0, x1, y1 = box
        draw.rectangle((x0 + 8, y0 + 26, x1 - 8, y0 + 42), fill=rgba("#15130f"))
        draw.rectangle((x0 + 9, y0 + 27, x0 + 9 + int((x1 - x0 - 18) * hp), y0 + 41), fill=rgba("#5b6d3c"))
        draw_text(draw, (x0 + 10, y0 + 8), title, fonts["tiny"], muted)

    # Chat and minimap stay deliberately quiet.
    draw.rounded_rectangle((38, 824, 526, 1044), radius=10, fill=rgba("#0d1210", 175), outline=rgba("#59412c", 150), width=2)
    for index, width in enumerate((370, 430, 330, 400, 285, 350)):
        y = 858 + index * 25
        draw.line((62, y, 62 + width, y), fill=rgba("#b8aa8c", 125), width=2)
    draw_text(draw, (58, 839), "聊天框（现有 runtime 邻接占位）", fonts["tiny"], muted)

    draw.ellipse((1670, 292, 1870, 492), fill=rgba("#101613", 220), outline=brass, width=4)
    draw.ellipse((1690, 312, 1850, 472), fill=rgba("#304335", 215), outline=rgba("#5f4a32"), width=2)
    draw.line((1770, 308, 1770, 326), fill=rgba("#d1b676"), width=4)
    draw_text(draw, (1770, 502), "小地图（邻接占位）", fonts["tiny"], muted, anchor="ma")

    # Top annotations.
    draw.rounded_rectangle((36, 32, 900, 174), radius=12, fill=parchment, outline=rgba("#6c4e2f"), width=3)
    draw_text(draw, (62, 52), "动作条 / 随身栏 V1 · 战斗甲板", fonts["title"], ink)
    draw_text(draw, (62, 94), "自适应 Rail 保留 pfUI 自由拖动、缩放、分页与任意合法行列", fonts["body"], ink)
    draw_text(draw, (62, 126), "本地几何模拟 · 非 source / runtime · ImageGen 0/0", fonts["small"], rgba("#6f251e"))

    draw.rounded_rectangle((1326, 32, 1884, 250), radius=12, fill=rgba("#261a13", 225), outline=brass, width=3)
    draw_text(draw, (1352, 52), "战斗可读性规则", fonts["heading"], rgba("#ead7a4"))
    notes = (
        "主栏 / 核心消耗品 / 饰品：战斗常显",
        "辅助栏：仅脱战淡出，可由用户关闭",
        "动态图标、键位、数量、冷却不烘焙",
        "推荐预设一次应用，不覆盖现有 profile",
        "AutoBar / TrinketMenu 缺失时局部回退",
    )
    for index, note in enumerate(notes):
        draw.ellipse((1354, 94 + index * 27, 1362, 102 + index * 27), fill=rgba("#b18a4d"))
        draw_text(draw, (1372, 88 + index * 27), note, fonts["small"], rgba("#d4c5a1"))


def frame_size_ui(bar: dict[str, Any]) -> tuple[int, int]:
    icon = int(bar["icon_ui"])
    border = int(bar["border_ui"])
    spacing = int(bar["spacing_ui"])
    cols = int(bar["cols"])
    rows = int(bar["rows"])
    step = icon + border * 2 + spacing
    return step * cols + spacing, step * rows + spacing


def ui_px(value: int | float, ui_scale: float, local_scale: float = 1.0) -> int:
    return max(1, round(float(value) * ui_scale * local_scale))


def icon_palette(index: int) -> tuple[str, str]:
    colors = (
        ("#425f4b", "#d8c782"), ("#72523a", "#e0be76"),
        ("#344f62", "#c4d5cc"), ("#65434a", "#dfb39f"),
        ("#52633b", "#d9d090"), ("#594166", "#d5b1d6"),
        ("#6a5b35", "#e3d49b"), ("#2f5a58", "#a9d8cf"),
        ("#633b31", "#e8b39a"), ("#3a465f", "#b9c7e4"),
        ("#4f5d39", "#d2dca8"), ("#644b2d", "#e4c58b"),
    )
    return colors[index % len(colors)]


def draw_glyph(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    index: int,
    color: tuple[int, int, int, int],
) -> None:
    x0, y0, x1, y1 = box
    cx, cy = (x0 + x1) // 2, (y0 + y1) // 2
    radius = max(3, min(x1 - x0, y1 - y0) // 5)
    mode = index % 6
    if mode == 0:
        draw.line((cx, cy - radius * 2, cx, cy + radius * 2), fill=color, width=max(2, radius // 2))
        draw.line((cx - radius * 2, cy, cx + radius * 2, cy), fill=color, width=max(2, radius // 2))
    elif mode == 1:
        draw.ellipse((cx - radius * 2, cy - radius * 2, cx + radius * 2, cy + radius * 2), outline=color, width=max(2, radius // 2))
        draw.ellipse((cx - radius // 2, cy - radius // 2, cx + radius // 2, cy + radius // 2), fill=color)
    elif mode == 2:
        draw.polygon([(cx, cy - radius * 2), (cx + radius * 2, cy + radius * 2), (cx - radius * 2, cy + radius * 2)], outline=color)
        draw.line([(cx, cy - radius * 2), (cx + radius * 2, cy + radius * 2), (cx - radius * 2, cy + radius * 2), (cx, cy - radius * 2)], fill=color, width=2)
    elif mode == 3:
        draw.line((cx - radius * 2, cy + radius * 2, cx + radius * 2, cy - radius * 2), fill=color, width=max(2, radius // 2))
        draw.ellipse((cx - radius, cy - radius, cx + radius, cy + radius), outline=color, width=2)
    elif mode == 4:
        draw.polygon([(cx - radius * 2, cy), (cx, cy - radius * 2), (cx + radius * 2, cy), (cx, cy + radius * 2)], outline=color)
        draw.line([(cx - radius * 2, cy), (cx, cy - radius * 2), (cx + radius * 2, cy), (cx, cy + radius * 2), (cx - radius * 2, cy)], fill=color, width=2)
    else:
        draw.arc((cx - radius * 2, cy - radius * 2, cx + radius * 2, cy + radius * 2), 205, 515, fill=color, width=max(2, radius // 2))
        draw.line((cx, cy - radius * 2, cx + radius, cy + radius), fill=color, width=2)


def draw_slot(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    index: int,
    state: str,
    fonts: dict[str, ImageFont.FreeTypeFont],
    *,
    key: str = "",
    count: str = "",
    pocket: bool = False,
    trinket: bool = False,
) -> None:
    x0, y0, x1, y1 = box
    dark = rgba("#170f0b")
    brass = rgba("#80623d" if not trinket else "#96764b")
    leather = rgba("#352219" if not pocket else "#563526")
    if state == "disabled":
        brass = rgba("#4b453c")
        leather = rgba("#282522")
    draw.rounded_rectangle(box, radius=4, fill=dark, outline=rgba("#0e0907"), width=2)
    draw.rounded_rectangle((x0 + 2, y0 + 2, x1 - 2, y1 - 2), radius=3, fill=brass, outline=rgba("#b08b51", 180), width=1)
    draw.rectangle((x0 + 4, y0 + 4, x1 - 4, y1 - 4), fill=leather)

    inset = 6 if min(x1 - x0, y1 - y0) >= 28 else 5
    icon_box = (x0 + inset, y0 + inset, x1 - inset, y1 - inset)
    shift = 1 if state == "pressed" else 0
    icon_box = (icon_box[0], icon_box[1] + shift, icon_box[2], icon_box[3] + shift)
    fill_hex, glyph_hex = icon_palette(index + (7 if pocket else 0))
    if state == "empty":
        fill_hex, glyph_hex = "#221914", "#514032"
    draw.rectangle(icon_box, fill=rgba(fill_hex), outline=rgba("#15100d"), width=1)
    if state != "empty":
        draw_glyph(draw, icon_box, index, rgba(glyph_hex, 225))

    if state == "hover":
        draw.rounded_rectangle((x0 + 3, y0 + 3, x1 - 3, y1 - 3), radius=3, outline=rgba("#f0d99a"), width=2)
    elif state == "active":
        draw.rounded_rectangle((x0 + 3, y0 + 3, x1 - 3, y1 - 3), radius=3, outline=rgba("#d8a33e"), width=2)
        draw.ellipse((x0 + 5, y0 + 5, x0 + 9, y0 + 9), fill=rgba("#f2c45d"))
    elif state == "cooldown":
        draw.rectangle(icon_box, fill=rgba("#090b0b", 150))
        draw.polygon([(icon_box[0], icon_box[1]), (icon_box[2], icon_box[1]), (icon_box[2], (icon_box[1] + icon_box[3]) // 2)], fill=rgba("#080909", 105))
        draw_text(draw, ((x0 + x1) // 2, (y0 + y1) // 2), "8", fonts["micro"], rgba("#f1e7ca"), anchor="mm", stroke=1, stroke_fill=rgba("#000000"))
    elif state == "range":
        draw.rectangle(icon_box, fill=rgba("#7d1616", 90))
        draw.rounded_rectangle((x0 + 3, y0 + 3, x1 - 3, y1 - 3), radius=3, outline=rgba("#a93a32"), width=2)
    elif state == "oom":
        draw.rectangle(icon_box, fill=rgba("#173d69", 100))
        draw.rounded_rectangle((x0 + 3, y0 + 3, x1 - 3, y1 - 3), radius=3, outline=rgba("#4776aa"), width=2)
    elif state == "equipped":
        draw.line((x0 + 5, y1 - 5, x1 - 5, y1 - 5), fill=rgba("#71965a"), width=2)

    if key:
        draw_text(draw, (x1 - 4, y0 + 3), key, fonts["micro"], rgba("#f3ead4"), anchor="ra", stroke=1, stroke_fill=rgba("#050505"))
    if count:
        draw_text(draw, (x1 - 3, y1 - 2), count, fonts["micro"], rgba("#f1d28c"), anchor="rd", stroke=1, stroke_fill=rgba("#050505"))


def bar_geometry(bar: dict[str, Any], ui_scale: float) -> tuple[int, int, int, int, int, int]:
    local_scale = float(bar.get("scale", 1.0))
    width_ui, height_ui = frame_size_ui(bar)
    width = ui_px(width_ui, ui_scale, local_scale)
    height = ui_px(height_ui, ui_scale, local_scale)
    x, y = map(int, bar["screen_origin"])
    button_ui = int(bar["icon_ui"]) + int(bar["border_ui"]) * 2
    button = ui_px(button_ui, ui_scale, local_scale)
    step = ui_px(button_ui + int(bar["spacing_ui"]), ui_scale, local_scale)
    inset = ui_px(int(bar["border_ui"]) + int(bar["spacing_ui"]), ui_scale, local_scale)
    return x, y, width, height, button, step, inset


def draw_gryphon(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    height: int,
    direction: int,
) -> None:
    # A deliberately schematic, non-authoritative gryphon endcap silhouette.
    inner = x
    outer = x + direction * 70
    cy = y + height // 2
    points = [
        (inner, y + 2),
        (x + direction * 18, y - 10),
        (x + direction * 38, y - 20),
        (x + direction * 33, cy - 2),
        (outer, cy + 3),
        (x + direction * 34, cy + 10),
        (x + direction * 22, y + height + 14),
        (inner, y + height - 2),
    ]
    draw.polygon(points, fill=rgba("#5b4029"), outline=rgba("#2b1a11"))
    draw.line(points + [points[0]], fill=rgba("#9a794a"), width=3, joint="curve")
    head_x = x + direction * 42
    draw.ellipse((head_x - 10, cy - 12, head_x + 10, cy + 8), fill=rgba("#7f6038"), outline=rgba("#c09a5c"), width=2)
    draw.polygon([(head_x + direction * 7, cy - 3), (head_x + direction * 22, cy + 1), (head_x + direction * 8, cy + 5)], fill=rgba("#b28a4b"))
    for offset in (-9, 0, 9):
        draw.line((x + direction * 12, cy + offset, x + direction * 31, cy + offset + direction * 2), fill=rgba("#c19b62", 175), width=2)


def draw_bar(
    draw: ImageDraw.ImageDraw,
    bar: dict[str, Any],
    ui_scale: float,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
) -> tuple[int, int, int, int]:
    x, y, width, height, button, step, inset = bar_geometry(bar, ui_scale)
    shell = (x, y, x + width, y + height)
    draw.rounded_rectangle(shell, radius=6, fill=rgba(palette["rail"]), outline=rgba("#2a180f"), width=3)
    draw.rounded_rectangle((x + 2, y + 2, x + width - 2, y + height - 2), radius=5, outline=rgba(palette["brass"]), width=2)
    draw.line((x + 7, y + 4, x + width - 7, y + 4), fill=rgba("#b18a52", 145), width=1)

    states = list(bar.get("states", []))
    keys = list(bar.get("keys", []))
    counts = list(bar.get("counts", []))
    for index in range(int(bar["buttons"])):
        col = index % int(bar["cols"])
        row = index // int(bar["cols"])
        bx = x + inset + col * step
        by = y + inset + row * step
        draw_slot(
            draw,
            (bx, by, bx + button, by + button),
            index,
            states[index] if index < len(states) else "normal",
            fonts,
            key=keys[index] if index < len(keys) else "",
            count=counts[index] if index < len(counts) else "",
        )

    if bar.get("gryphons"):
        draw_gryphon(draw, x - 2, y, height, -1)
        draw_gryphon(draw, x + width + 2, y, height, 1)

    label = str(bar.get("label", ""))
    if label:
        label_y = y - 10
        draw_text(draw, (x + width // 2, label_y), label, fonts["tiny"], rgba(palette["label"]), anchor="ms", stroke=1, stroke_fill=rgba("#0a0c0a"))
    return shell


def draw_pouch(
    draw: ImageDraw.ImageDraw,
    config: dict[str, Any],
    ui_scale: float,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
) -> tuple[int, int, int, int]:
    x, y, width, height, button, step, inset = bar_geometry(config, ui_scale)
    shell = (x - 7, y - 9, x + width + 7, y + height + 8)
    draw.rounded_rectangle(shell, radius=12, fill=rgba("#4b2d20"), outline=rgba("#24150f"), width=3)
    draw.rounded_rectangle((shell[0] + 3, shell[1] + 3, shell[2] - 3, shell[3] - 3), radius=10, outline=rgba("#8e6339"), width=2)
    draw.rectangle((shell[0] + 10, shell[1] - 5, shell[2] - 10, shell[1] + 10), fill=rgba("#65432b"), outline=rgba("#9c7547"), width=2)
    for sx in range(shell[0] + 14, shell[2] - 10, 12):
        draw.line((sx, shell[1] + 5, sx + 5, shell[1] + 5), fill=rgba("#c19862", 145), width=1)

    states = list(config.get("states", []))
    counts = list(config.get("counts", []))
    for index in range(int(config["buttons"])):
        col = index % int(config["cols"])
        row = index // int(config["cols"])
        bx = x + inset + col * step
        by = y + inset + row * step
        draw_slot(
            draw,
            (bx, by, bx + button, by + button),
            index,
            states[index] if index < len(states) else "normal",
            fonts,
            count=counts[index] if index < len(counts) else "",
            pocket=True,
        )
    draw_text(draw, ((shell[0] + shell[2]) // 2, shell[1] - 10), str(config["label"]), fonts["tiny"], rgba(palette["label"]), anchor="ms", stroke=1, stroke_fill=rgba("#0a0c0a"))
    return shell


def draw_trinkets(
    draw: ImageDraw.ImageDraw,
    config: dict[str, Any],
    ui_scale: float,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
) -> tuple[int, int, int, int]:
    x, y, width, height, button, step, inset = bar_geometry(config, ui_scale)
    shell = (x - 8, y - 8, x + width + 8, y + height + 8)
    draw.rounded_rectangle(shell, radius=10, fill=rgba("#2f2018"), outline=rgba("#9b7848"), width=3)
    draw.rectangle((shell[0] + 5, shell[1] + 5, shell[2] - 5, shell[3] - 5), outline=rgba("#5d3c27"), width=2)
    for index in range(2):
        bx = x + inset + index * step
        by = y + inset
        draw_slot(
            draw,
            (bx, by, bx + button, by + button),
            index + 10,
            "cooldown" if index == 1 else "active",
            fonts,
            key=str(index + 1),
            trinket=True,
        )
        draw.ellipse((bx + button // 2 - 4, shell[1] - 2, bx + button // 2 + 4, shell[1] + 6), fill=rgba("#ad854d"), outline=rgba("#3a281a"))
    draw_text(draw, ((shell[0] + shell[2]) // 2, shell[1] - 10), str(config["label"]), fonts["tiny"], rgba(palette["label"]), anchor="ms", stroke=1, stroke_fill=rgba("#0a0c0a"))
    return shell


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    spec = json.loads(args.spec.read_text(encoding="utf-8"))
    canvas = spec["canvas"]
    image = Image.new("RGBA", (int(canvas["width"]), int(canvas["height"])), rgba(canvas["fill"]))
    draw = ImageDraw.Draw(image, "RGBA")
    fonts = {name: load_font(root, definition) for name, definition in spec["fonts"].items()}
    palette = spec["palette"]
    ui_scale = float(spec["target"]["ui_scale"])

    draw_scene(image, draw, palette)
    draw_placeholder_ui(draw, fonts, palette)
    for bar in spec["bars"]:
        draw_bar(draw, bar, ui_scale, fonts, palette)
    draw_pouch(draw, spec["consumables"], ui_scale, fonts, palette)
    draw_trinkets(draw, spec["trinkets"], ui_scale, fonts, palette)

    # Existing XP/rep adjacency remains provider-owned.
    main = spec["bars"][0]
    mx, my, mw, mh, _, _, _ = bar_geometry(main, ui_scale)
    draw.rectangle((mx, my + mh + 6, mx + mw, my + mh + 12), fill=rgba("#24170f"), outline=rgba("#80623d"), width=1)
    draw.rectangle((mx + 2, my + mh + 8, mx + int(mw * 0.64), my + mh + 10), fill=rgba("#756343"))
    draw_text(draw, (mx + mw // 2, my + mh + 17), "XP / 声望条保持 pfUI provider（邻接占位）", fonts["tiny"], rgba(palette["muted_ink"]), anchor="mm", stroke=1, stroke_fill=rgba("#080a08"))

    output = args.output or Path(spec["output"])
    if not output.is_absolute():
        output = root / output
    output.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(output, format="PNG", optimize=False, compress_level=9)
    print(output.resolve())


if __name__ == "__main__":
    main()
