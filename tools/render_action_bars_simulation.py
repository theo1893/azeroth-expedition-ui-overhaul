#!/usr/bin/env python3
"""Render deterministic Action Bars direction simulations.

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
    parser.add_argument("--layout-report", type=Path)
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


def merge_specs(base: dict[str, Any], override: dict[str, Any]) -> dict[str, Any]:
    """Recursively merge a compact revision spec over a tracked base spec."""
    merged = dict(base)
    for key, value in override.items():
        if isinstance(value, dict) and value.get("__replace__") is True:
            merged[key] = {
                child_key: child_value
                for child_key, child_value in value.items()
                if child_key != "__replace__"
            }
            continue
        if (
            isinstance(value, dict)
            and isinstance(merged.get(key), dict)
        ):
            merged[key] = merge_specs(merged[key], value)
        else:
            merged[key] = value
    return merged


def apply_bar_overrides(spec: dict[str, Any]) -> dict[str, Any]:
    """Apply compact per-bar geometry revisions after inherited lists resolve."""
    overrides = spec.pop("bar_overrides", None)
    if not overrides:
        return spec

    bars = []
    matched: set[str] = set()
    for bar in spec["bars"]:
        bar_id = str(bar["id"])
        if bar_id in overrides:
            bars.append(merge_specs(bar, overrides[bar_id]))
            matched.add(bar_id)
        else:
            bars.append(bar)

    missing = sorted(set(overrides) - matched)
    if missing:
        raise ValueError(f"unknown bar override ids: {', '.join(missing)}")
    spec["bars"] = bars
    return spec


def apply_unit_frame_overrides(spec: dict[str, Any]) -> dict[str, Any]:
    """Apply compact per-frame revisions without duplicating aura evidence."""
    overrides = spec.pop("unit_frame_overrides", None)
    if not overrides:
        return spec

    unit_frames = spec.get("unit_frames", {})
    frames = []
    matched: set[str] = set()
    for frame in unit_frames.get("frames", []):
        frame_id = str(frame["id"])
        if frame_id in overrides:
            frames.append(merge_specs(frame, overrides[frame_id]))
            matched.add(frame_id)
        else:
            frames.append(frame)

    missing = sorted(set(overrides) - matched)
    if missing:
        raise ValueError(f"unknown unit-frame override ids: {', '.join(missing)}")
    unit_frames["frames"] = frames
    spec["unit_frames"] = unit_frames
    return spec


def apply_spec_overrides(spec: dict[str, Any]) -> dict[str, Any]:
    return apply_unit_frame_overrides(apply_bar_overrides(spec))


def load_spec(path: Path, root: Path) -> dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    base_ref = data.pop("extends", None)
    if not base_ref:
        return apply_spec_overrides(data)

    base_path = Path(str(base_ref))
    if not base_path.is_absolute():
        base_path = root / base_path
    return apply_spec_overrides(
        merge_specs(load_spec(base_path.resolve(), root), data)
    )


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


def draw_placeholder_ui_v1(
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


def draw_aura_strip(
    draw: ImageDraw.ImageDraw,
    origin: tuple[int, int],
    auras: list[dict[str, Any]],
    fonts: dict[str, ImageFont.FreeTypeFont],
    direction: str = "ltr",
    size: int = 19,
    gap: int = 4,
    per_row: int | None = None,
    row_gap: int | None = None,
) -> None:
    x, y = origin
    row_width = max(1, int(per_row or len(auras) or 1))
    vertical_gap = gap if row_gap is None else int(row_gap)
    for index, aura in enumerate(auras):
        column = index % row_width
        row = index // row_width
        step = column * (size + gap)
        ax = x - step if direction == "rtl" else x + step
        ay = y + row * (size + vertical_gap)
        kind = str(aura.get("kind", "buff"))
        outer = "#8d6b3f" if kind == "buff" else "#7c463f"
        inner = "#455b3e" if kind == "buff" else "#593333"
        draw.rounded_rectangle(
            (ax, ay, ax + size, ay + size),
            radius=3,
            fill=rgba("#17110d"),
            outline=rgba(outer),
            width=2,
        )
        draw.rectangle((ax + 3, ay + 3, ax + size - 3, ay + size - 3), fill=rgba(inner))
        draw_glyph(draw, (ax + 3, ay + 3, ax + size - 3, ay + size - 3), index + 3, rgba("#dbc68e", 215))
        if aura.get("count"):
            draw_text(
                draw,
                (ax + size - 1, ay + size),
                str(aura["count"]),
                fonts["micro"],
                rgba("#f3e7c7"),
                anchor="rd",
                stroke=1,
                stroke_fill=rgba("#050505"),
            )


def draw_unit_frame_v2(
    draw: ImageDraw.ImageDraw,
    config: dict[str, Any],
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
) -> None:
    x0, y0, x1, y1 = map(int, config["screen_box"])
    portrait_side = str(config.get("portrait_side", "left"))
    frame_fill = rgba("#342219", 242)
    brass = rgba(palette["brass"])
    muted = rgba(palette["muted_ink"])

    draw.rounded_rectangle((x0, y0, x1, y1), radius=8, fill=frame_fill, outline=rgba("#21150f"), width=3)
    draw.rounded_rectangle((x0 + 3, y0 + 3, x1 - 3, y1 - 3), radius=6, outline=brass, width=2)
    draw.line((x0 + 9, y0 + 5, x1 - 9, y0 + 5), fill=rgba("#b18a52", 130), width=1)

    portrait_width = 47
    if portrait_side == "left":
        portrait = (x0 + 7, y0 + 8, x0 + 7 + portrait_width, y1 - 8)
        content_x0, content_x1 = portrait[2] + 7, x1 - 8
    else:
        portrait = (x1 - 7 - portrait_width, y0 + 8, x1 - 7, y1 - 8)
        content_x0, content_x1 = x0 + 8, portrait[0] - 7

    draw.rounded_rectangle(portrait, radius=5, fill=rgba("#171d18"), outline=rgba("#a17a45"), width=2)
    px0, py0, px1, py1 = portrait
    portrait_tint = rgba(str(config.get("portrait_tint", "#30483b")))
    draw.ellipse((px0 + 11, py0 + 6, px1 - 11, py0 + 25), fill=portrait_tint)
    draw.polygon(
        [(px0 + 8, py1 - 5), ((px0 + px1) // 2, py0 + 20), (px1 - 8, py1 - 5)],
        fill=portrait_tint,
    )

    name_font = str(config.get("name_font", "tiny"))
    level_font = str(config.get("level_font", "micro"))
    health_font = str(config.get("health_font", "micro"))
    draw_text(
        draw,
        (content_x0 + 1, y0 + 8),
        str(config["name"]),
        fonts[name_font],
        rgba("#ead9ad"),
    )
    draw_text(
        draw,
        (content_x1 - 1, y0 + 9),
        str(config.get("level", "")),
        fonts[level_font],
        muted,
        anchor="ra",
    )

    health_box = (content_x0, y0 + 25, content_x1, y0 + 43)
    power_box = (content_x0, y0 + 47, content_x1, y0 + 54)
    draw.rectangle(health_box, fill=rgba("#11120e"), outline=rgba("#19100b"), width=1)
    health = max(0.0, min(1.0, float(config.get("health", 1.0))))
    health_right = health_box[0] + round((health_box[2] - health_box[0]) * health)
    draw.rectangle((health_box[0] + 1, health_box[1] + 1, health_right, health_box[3] - 1), fill=rgba(str(config.get("health_color", "#657742"))))
    draw.line((health_box[0] + 2, health_box[1] + 2, max(health_box[0] + 2, health_right - 2), health_box[1] + 2), fill=rgba("#aab878", 115), width=1)
    power = max(0.0, min(1.0, float(config.get("power", 1.0))))
    power_right = power_box[0] + round((power_box[2] - power_box[0]) * power)
    draw.rectangle(power_box, fill=rgba("#101318"), outline=rgba("#19100b"), width=1)
    draw.rectangle((power_box[0] + 1, power_box[1] + 1, power_right, power_box[3] - 1), fill=rgba(str(config.get("power_color", "#3e6280"))))
    draw_text(
        draw,
        ((health_box[0] + health_box[2]) // 2, (health_box[1] + health_box[3]) // 2),
        str(config.get("health_text", "")),
        fonts[health_font],
        rgba("#f2ead4"),
        anchor="mm",
        stroke=1,
        stroke_fill=rgba("#050505"),
    )

    label_y = y0 - 12
    draw_text(
        draw,
        ((x0 + x1) // 2, label_y),
        str(config["label"]),
        fonts["tiny"],
        rgba(palette["label"]),
        anchor="ms",
        stroke=1,
        stroke_fill=rgba("#080a08"),
    )
    strips = config.get("aura_strips")
    if strips:
        for strip in strips:
            draw_aura_strip(
                draw,
                tuple(map(int, strip["origin"])),
                list(strip.get("auras", [])),
                fonts,
                str(strip.get("direction", "ltr")),
                int(strip.get("size", 19)),
                int(strip.get("gap", 4)),
                int(strip["per_row"]) if "per_row" in strip else None,
                int(strip["row_gap"]) if "row_gap" in strip else None,
            )
    else:
        draw_aura_strip(
            draw,
            tuple(map(int, config["aura_origin"])),
            list(config.get("auras", [])),
            fonts,
        )


def draw_cast_bar(
    draw: ImageDraw.ImageDraw,
    config: dict[str, Any],
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
) -> None:
    x0, y0, x1, y1 = map(int, config["screen_box"])
    height = y1 - y0
    icon_width = height
    icon_box = (x0, y0, x0 + icon_width, y1)
    bar_box = (x0 + icon_width + 3, y0, x1, y1)
    warning = bool(config.get("interruptible"))
    outline = rgba("#9b5b45" if warning else palette["brass"])
    fill = rgba(str(config.get("fill", "#8b6a3e")))

    draw.rounded_rectangle(icon_box, radius=3, fill=rgba("#1a120e"), outline=outline, width=2)
    draw.rectangle(
        (icon_box[0] + 3, icon_box[1] + 3, icon_box[2] - 3, icon_box[3] - 3),
        fill=rgba(str(config.get("icon_fill", "#4f5e42"))),
    )
    draw_glyph(
        draw,
        (icon_box[0] + 3, icon_box[1] + 3, icon_box[2] - 3, icon_box[3] - 3),
        int(config.get("glyph", 2)),
        rgba("#e0cf9a", 225),
    )

    draw.rounded_rectangle(bar_box, radius=3, fill=rgba("#17110e"), outline=outline, width=2)
    inner = (bar_box[0] + 2, bar_box[1] + 2, bar_box[2] - 2, bar_box[3] - 2)
    progress = max(0.0, min(1.0, float(config.get("progress", 0.5))))
    progress_right = inner[0] + round((inner[2] - inner[0]) * progress)
    draw.rectangle((inner[0], inner[1], progress_right, inner[3]), fill=fill)
    draw.line(
        (inner[0] + 1, inner[1] + 1, max(inner[0] + 1, progress_right - 1), inner[1] + 1),
        fill=rgba("#d5bd83", 105),
        width=1,
    )

    latency = max(0.0, min(1.0, float(config.get("latency", 0.0))))
    if latency:
        lag_left = inner[2] - round((inner[2] - inner[0]) * latency)
        draw.rectangle((lag_left, inner[1], inner[2], inner[3]), fill=rgba("#9d352d", 115))

    draw_text(
        draw,
        (bar_box[0] + 6, (bar_box[1] + bar_box[3]) // 2),
        str(config.get("name", "")),
        fonts["micro"],
        rgba("#f3ead4"),
        anchor="lm",
        stroke=1,
        stroke_fill=rgba("#050505"),
    )
    draw_text(
        draw,
        (bar_box[2] - 5, (bar_box[1] + bar_box[3]) // 2),
        str(config.get("timer", "")),
        fonts["micro"],
        rgba("#f3ead4"),
        anchor="rm",
        stroke=1,
        stroke_fill=rgba("#050505"),
    )


def indicator_box(
    config: dict[str, Any],
    ui_scale: float,
) -> tuple[int, int, int, int]:
    x, y = map(int, config["screen_origin"])
    local_scale = float(config.get("scale", 1.0))
    width = ui_px(config["width_ui"], ui_scale, local_scale)
    height = ui_px(config["height_ui"], ui_scale, local_scale)
    return x, y, x + width, y + height


def draw_swing_timers(
    draw: ImageDraw.ImageDraw,
    config: dict[str, Any],
    ui_scale: float,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
) -> None:
    if config.get("label"):
        draw_text(
            draw,
            tuple(map(int, config.get("label_origin", [960, 562]))),
            str(config["label"]),
            fonts["tiny"],
            rgba(palette["label"]),
            anchor="ms",
            stroke=1,
            stroke_fill=rgba("#080a08"),
        )

    for index, bar in enumerate(config.get("bars", [])):
        x0, y0, x1, y1 = indicator_box(bar, ui_scale)
        draw.rounded_rectangle((x0, y0, x1, y1), radius=2, fill=rgba("#16100d"), outline=rgba(palette["brass"]), width=1)
        inner = (x0 + 2, y0 + 2, x1 - 2, y1 - 2)
        progress = max(0.0, min(1.0, float(bar.get("progress", 0.5))))
        right = inner[0] + round((inner[2] - inner[0]) * progress)
        draw.rectangle((inner[0], inner[1], right, inner[3]), fill=rgba(str(bar.get("fill", "#85643c"))))
        marker_x = max(inner[0], min(inner[2], right))
        draw.line((marker_x, y0 - 2, marker_x, y1 + 2), fill=rgba("#ead49a"), width=2)
        draw_text(
            draw,
            (x0 - 6, (y0 + y1) // 2),
            str(bar.get("left_text", "")),
            fonts["micro"],
            rgba("#d8c8a5"),
            anchor="rm",
            stroke=1,
            stroke_fill=rgba("#050505"),
        )
        draw_text(
            draw,
            (x1 + 6, (y0 + y1) // 2),
            str(bar.get("right_text", "")),
            fonts["micro"],
            rgba("#d8c8a5"),
            anchor="lm",
            stroke=1,
            stroke_fill=rgba("#050505"),
        )


def draw_doite_dps(
    draw: ImageDraw.ImageDraw,
    config: dict[str, Any],
    ui_scale: float,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
) -> None:
    x0, y0, x1, y1 = indicator_box(config, ui_scale)
    local_scale = float(config.get("scale", 1.0))
    hit_x = x0 + ui_px(config.get("hit_x_ui", 45), ui_scale, local_scale)
    ready_size = ui_px(config.get("ready_slot_ui", 46), ui_scale, local_scale)
    track_y = (y0 + y1) // 2

    label_origin = tuple(map(int, config.get("label_origin", [960, y0 - 26])))
    draw_text(
        draw,
        label_origin,
        str(config.get("label", "DoiteDPS")),
        fonts["tiny"],
        rgba(palette["label"]),
        anchor="ms",
        stroke=1,
        stroke_fill=rgba("#080a08"),
    )

    # Provider-owned blue/green semantics stay intact; the shell is only a
    # low-weight placement cue for this non-production simulation.
    draw.rounded_rectangle((x0, y0, x1, y1), radius=5, fill=rgba("#07101a", 210), outline=rgba("#6f6249", 175), width=1)
    forecast_max_x = x0 + ui_px(config.get("forecast_max_x_ui", 294), ui_scale, local_scale)
    draw.line((hit_x + ready_size // 2, track_y, forecast_max_x, track_y), fill=rgba("#345c7b", 190), width=2)

    ready_box = (
        hit_x - ready_size // 2,
        track_y - ready_size // 2,
        hit_x + ready_size // 2,
        track_y + ready_size // 2,
    )
    draw.rounded_rectangle(ready_box, radius=5, fill=rgba("#07100d"), outline=rgba("#46d36b"), width=2)
    current_box = (ready_box[0] + 4, ready_box[1] + 4, ready_box[2] - 4, ready_box[3] - 4)
    draw.rectangle(current_box, fill=rgba("#38543e"), outline=rgba("#142119"), width=1)
    draw_glyph(draw, current_box, 7, rgba("#d9e5bd", 230))

    icon_size = ui_px(config.get("forecast_icon_ui", 34), ui_scale, local_scale)
    for index, offset in enumerate(config.get("forecast_offsets_ui", [106, 166, 226, 286])):
        center_x = x0 + ui_px(offset, ui_scale, local_scale)
        box = (
            center_x - icon_size // 2,
            track_y - icon_size // 2,
            center_x + icon_size // 2,
            track_y + icon_size // 2,
        )
        draw.rounded_rectangle(box, radius=4, fill=rgba("#08111a"), outline=rgba("#6f9cc2", 205), width=2)
        inner = (box[0] + 3, box[1] + 3, box[2] - 3, box[3] - 3)
        fill_hex, glyph_hex = icon_palette(index + 4)
        draw.rectangle(inner, fill=rgba(fill_hex), outline=rgba("#101923"), width=1)
        draw_glyph(draw, inner, index + 10, rgba(glyph_hex, 220))

    if config.get("show_resource", True):
        resource_width = ui_px(config.get("resource_width_ui", 178), ui_scale, local_scale)
        resource_height = ui_px(config.get("resource_height_ui", 22), ui_scale, local_scale)
        gap = ui_px(config.get("resource_gap_ui", 2), ui_scale, local_scale)
        resource_box = (x0, y0 - gap - resource_height, x0 + resource_width, y0 - gap)
        draw.rounded_rectangle(resource_box, radius=4, fill=rgba("#07101a", 220), outline=rgba("#6f6249", 165), width=1)
        cell_width = resource_width // 3
        for index in range(3):
            ix = resource_box[0] + index * cell_width + 4
            iy = resource_box[1] + 3
            icon = (ix, iy, ix + resource_height - 6, resource_box[3] - 3)
            draw.rectangle(icon, fill=rgba(("#3e543d", "#594432", "#3a4f62")[index]), outline=rgba("#9b8155"), width=1)
            draw_text(
                draw,
                (icon[2] + 4, (resource_box[1] + resource_box[3]) // 2),
                ("OK", "2", "CD")[index],
                fonts["micro"],
                rgba("#d8e0d0"),
                anchor="lm",
                stroke=1,
                stroke_fill=rgba("#050505"),
            )


def draw_placeholder_ui_v2(
    draw: ImageDraw.ImageDraw,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
    spec: dict[str, Any],
) -> None:
    ink = rgba(palette["ink"])
    muted = rgba(palette["muted_ink"])
    brass = rgba(palette["brass"], 225)
    parchment = rgba(palette["parchment"], 225)

    # Existing chat and minimap remain quiet context, not redesign scope.
    draw.rounded_rectangle((38, 824, 526, 1044), radius=10, fill=rgba("#0d1210", 175), outline=rgba("#59412c", 150), width=2)
    for index, width in enumerate((370, 430, 330, 400, 285, 350)):
        y = 858 + index * 25
        draw.line((62, y, 62 + width, y), fill=rgba("#b8aa8c", 125), width=2)
    draw_text(draw, (58, 839), "聊天框（现有 runtime 邻接占位）", fonts["tiny"], muted)

    draw.ellipse((1670, 292, 1870, 492), fill=rgba("#101613", 220), outline=brass, width=4)
    draw.ellipse((1690, 312, 1850, 472), fill=rgba("#304335", 215), outline=rgba("#5f4a32"), width=2)
    draw.line((1770, 308, 1770, 326), fill=rgba("#d1b676"), width=4)
    draw_text(draw, (1770, 502), "小地图（邻接占位）", fonts["tiny"], muted, anchor="ma")

    annotations = spec["annotations"]
    draw.rounded_rectangle((36, 32, 930, 174), radius=12, fill=parchment, outline=rgba("#6c4e2f"), width=3)
    draw_text(draw, (62, 52), str(annotations["title"]), fonts["title"], ink)
    draw_text(draw, (62, 94), str(annotations["subtitle"]), fonts["body"], ink)
    draw_text(draw, (62, 126), str(annotations["note"]), fonts["small"], rgba("#6f251e"))

    draw.rounded_rectangle((1270, 32, 1884, 250), radius=12, fill=rgba("#261a13", 225), outline=brass, width=3)
    draw_text(draw, (1296, 52), str(annotations["rules_title"]), fonts["heading"], rgba("#ead7a4"))
    for index, note in enumerate(annotations["rules"]):
        draw.ellipse((1298, 94 + index * 27, 1306, 102 + index * 27), fill=rgba("#b18a4d"))
        draw_text(draw, (1316, 88 + index * 27), str(note), fonts["small"], rgba("#d4c5a1"))

    # A quiet focus bracket explains the intended eye path without becoming runtime art.
    focus = tuple(map(int, spec["focus_field"]["screen_box"]))
    draw.rounded_rectangle(focus, radius=18, outline=rgba("#8b7047", 72), width=2)
    fx0, fy0, fx1, fy1 = focus
    draw.line((960, fy0 + 8, 960, fy0 + 25), fill=rgba("#c4a76b", 100), width=2)
    draw.line((960, fy1 - 25, 960, fy1 - 8), fill=rgba("#c4a76b", 100), width=2)

    ui_scale = float(spec["target"]["ui_scale"])
    if "doite_dps" in spec:
        draw_doite_dps(draw, spec["doite_dps"], ui_scale, fonts, palette)
    if "swing_timers" in spec:
        draw_swing_timers(draw, spec["swing_timers"], ui_scale, fonts, palette)

    for frame in spec["unit_frames"]["frames"]:
        draw_unit_frame_v2(draw, frame, fonts, palette)

    for castbar in spec.get("cast_bars", {}).get("bars", []):
        if castbar.get("visible_in_simulation", True):
            draw_cast_bar(draw, castbar, fonts, palette)

    cluster_label_origin = tuple(map(int, spec["unit_frames"].get("cluster_label_origin", [960, 735])))
    draw_text(
        draw,
        cluster_label_origin,
        str(spec["unit_frames"]["cluster_label"]),
        fonts["micro"],
        rgba(palette["label"]),
        anchor="mm",
        stroke=1,
        stroke_fill=rgba("#080a08"),
    )


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


def draw_side_cluster(
    draw: ImageDraw.ImageDraw,
    config: dict[str, Any],
    ui_scale: float,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
) -> None:
    bars = list(config.get("bars", []))
    if not bars:
        return
    shells = [bar_geometry(bar, ui_scale) for bar in bars]
    left = min(item[0] for item in shells)
    top = min(item[1] for item in shells)
    right = max(item[0] + item[2] for item in shells)
    bottom = max(item[1] + item[3] for item in shells)
    padding = int(config.get("annotation_padding_px", 10))
    label_height = int(config.get("annotation_label_height_px", 22))
    outer = (
        left - padding,
        top - padding - label_height,
        right + padding,
        bottom + padding,
    )
    draw.rounded_rectangle(
        outer,
        radius=10,
        fill=rgba("#101410", 158),
        outline=rgba("#b18a52", 175),
        width=2,
    )
    draw_text(
        draw,
        ((left + right) // 2, top - padding - 4),
        str(config.get("label", "Right-side grouped bars proposal")),
        fonts["tiny"],
        rgba(palette["label"]),
        anchor="ms",
        stroke=1,
        stroke_fill=rgba("#080a08"),
    )
    for bar in bars:
        draw_bar(draw, bar, ui_scale, fonts, palette)


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


def totem_geometry(
    config: dict[str, Any],
    ui_scale: float,
) -> dict[str, int]:
    local_scale = float(config.get("scale", 1.0))
    handle_scale = float(config.get("handle_scale", 1.0))
    button = ui_px(int(config.get("button_ui", 40)), ui_scale, local_scale)
    handle = ui_px(int(config.get("handle_ui", 20)), ui_scale, handle_scale)
    element_count = int(config.get("element_count", 4))
    special_count = 1
    if config.get("recall_visible", False):
        special_count += 1
    if config.get("preset_visible", False):
        special_count += 1
    width = element_count * button + handle + special_count * button
    popup_count = max(1, int(config.get("popup_count", 1)))
    popup_height = popup_count * button
    x, y = map(int, config["screen_origin"])
    return {
        "x": x,
        "y": y,
        "button": button,
        "handle": handle,
        "width": width,
        "row_height": button,
        "popup_height": popup_height,
        "popup_bottom": y + popup_height,
    }


def draw_totem_satellite(
    draw: ImageDraw.ImageDraw,
    config: dict[str, Any],
    ui_scale: float,
    fonts: dict[str, ImageFont.FreeTypeFont],
    palette: dict[str, str],
) -> tuple[int, int, int, int]:
    geometry = totem_geometry(config, ui_scale)
    x = geometry["x"]
    y = geometry["y"]
    button = geometry["button"]
    handle = geometry["handle"]
    element_count = int(config.get("element_count", 4))
    labels = list(config.get("element_labels", ["土", "火", "水", "风"]))
    states = list(config.get("element_states", []))
    durations = list(config.get("durations", []))

    for index in range(element_count):
        bx = x + index * button
        draw_slot(
            draw,
            (bx, y, bx + button, y + button),
            index + 20,
            states[index] if index < len(states) else "normal",
            fonts,
            key=labels[index] if index < len(labels) else "",
        )
        if index < len(durations) and durations[index]:
            draw_text(
                draw,
                (bx + button // 2, y - 3),
                str(durations[index]),
                fonts["micro"],
                rgba("#e7cf91"),
                anchor="ms",
                stroke=1,
                stroke_fill=rgba("#050505"),
            )

    cursor = x + element_count * button
    cy = y + button // 2
    draw.ellipse(
        (cursor, cy - handle // 2, cursor + handle, cy + handle // 2),
        fill=rgba("#17130f"),
        outline=rgba(palette["brass"]),
        width=2,
    )
    dot = max(2, handle // 5)
    draw.ellipse(
        (
            cursor + handle // 2 - dot,
            cy - dot,
            cursor + handle // 2 + dot,
            cy + dot,
        ),
        fill=rgba("#7fb959" if not config.get("locked", False) else "#716858"),
    )
    cursor += handle

    special_buttons = [("一键", "active")]
    if config.get("recall_visible", False):
        special_buttons.append(("召", "cooldown"))
    if config.get("preset_visible", False):
        special_buttons.append(("组", "normal"))
    for index, (label, state) in enumerate(special_buttons):
        draw_slot(
            draw,
            (cursor, y, cursor + button, y + button),
            index + 30,
            state,
            fonts,
            key=label,
        )
        cursor += button

    active_index = int(config.get("active_popup_index", element_count - 1))
    popup_count = max(1, int(config.get("popup_count", 1)))
    direction = str(config.get("direction", "down")).lower()
    popup_x = x + active_index * button
    for index in range(1, popup_count):
        popup_y = y + index * button if direction == "down" else y - index * button
        draw_slot(
            draw,
            (popup_x, popup_y, popup_x + button, popup_y + button),
            index + 38,
            "cooldown" if index == 2 else "normal",
            fonts,
        )

    label = str(config.get("label", ""))
    if label:
        draw_text(
            draw,
            (x + geometry["width"] // 2, y - 20),
            label,
            fonts["tiny"],
            rgba(palette["label"]),
            anchor="ms",
            stroke=1,
            stroke_fill=rgba("#080a08"),
        )

    popup_top = y if direction == "down" else y - (popup_count - 1) * button
    popup_bottom = y + button if direction == "up" else y + popup_count * button
    return (x, popup_top, x + geometry["width"], popup_bottom)


def validate_compact_row_v6(
    spec: dict[str, Any],
    contract: dict[str, Any],
) -> dict[str, Any]:
    """Validate the V6 provider geometry without reusing V5's vertical stack."""
    ui_scale = float(spec["target"]["ui_scale"])
    checks: list[dict[str, Any]] = []

    def check(identifier: str, expected: Any, actual: Any) -> None:
        checks.append({
            "id": identifier,
            "expected": expected,
            "actual": actual,
            "pass": actual == expected,
        })

    frames = {frame["id"]: frame for frame in spec["unit_frames"]["frames"]}
    player = list(map(int, frames["UF.PLAYER.ADJACENCY"]["screen_box"]))
    target = list(map(int, frames["UF.TARGET.ADJACENCY"]["screen_box"]))
    target_target = list(map(int, frames["UF.TARGETTARGET.ADJACENCY"]["screen_box"]))
    check("unit.player-width", int(contract["unit_frame_width_px"]), player[2] - player[0])
    check("unit.target-width", int(contract["unit_frame_width_px"]), target[2] - target[0])
    check("unit.shared-height", player[3] - player[1], target[3] - target[1])
    check("unit.inner-gap", int(contract["unit_frame_inner_gap_px"]), target[0] - player[2])
    check("unit.cluster-center", int(contract["main_bar_center_x"]), round((player[0] + target[2]) / 2))
    check("targettarget.gap", int(contract["targettarget_gap_px"]), target_target[0] - target[2])
    check("targettarget.center-y", round((target[1] + target[3]) / 2), round((target_target[1] + target_target[3]) / 2))
    check("targettarget.width", int(contract["targettarget_width_px"]), target_target[2] - target_target[0])

    player_strips = frames["UF.PLAYER.ADJACENCY"]["aura_strips"]
    target_strips = frames["UF.TARGET.ADJACENCY"]["aura_strips"]
    target_target_strips = frames["UF.TARGETTARGET.ADJACENCY"]["aura_strips"]
    check("aura.player-buffs-direction", "ltr", player_strips[0]["direction"])
    check("aura.player-debuffs-direction", "ltr", player_strips[1]["direction"])
    check("aura.target-buffs-direction", "rtl", target_strips[0]["direction"])
    check("aura.target-debuffs-direction", "rtl", target_strips[1]["direction"])
    check("aura.targettarget-buffs-direction", "rtl", target_target_strips[0]["direction"])
    check("aura.targettarget-debuffs-direction", "rtl", target_target_strips[1]["direction"])

    castbars = {
        item["id"]: list(map(int, item["screen_box"]))
        for item in spec["cast_bars"]["bars"]
        if item.get("visible_in_simulation", True)
    }
    player_cast = castbars["CAST.PLAYER"]
    target_cast = castbars["CAST.TARGET"]
    swings = {
        item["id"]: indicator_box(item, ui_scale)
        for item in spec["swing_timers"]["bars"]
    }
    swing = swings["SWING.MAINHAND"]
    offhand = swings["SWING.OFFHAND"]
    readout_widths = [
        player_cast[2] - player_cast[0],
        swing[2] - swing[0],
        target_cast[2] - target_cast[0],
    ]
    readout_heights = [
        player_cast[3] - player_cast[1],
        swing[3] - swing[1],
        target_cast[3] - target_cast[1],
    ]
    check("readout.equal-widths", [readout_widths[0]] * 3, readout_widths)
    check("readout.equal-heights", [readout_heights[0]] * 3, readout_heights)
    check("readout.width", int(contract["readout_width_px"]), readout_widths[0])
    check("readout.height", int(contract["readout_height_px"]), readout_heights[0])
    check("readout.shared-top", [player_cast[1]] * 3, [player_cast[1], swing[1], target_cast[1]])
    check("readout.player-swing-gap", int(contract["readout_column_gap_px"]), swing[0] - player_cast[2])
    check("readout.swing-target-gap", int(contract["readout_column_gap_px"]), target_cast[0] - swing[2])
    check("readout.offhand-gap", int(contract["swing_pair_gap_px"]), offhand[1] - swing[3])
    check("readout.unit-clearance", int(contract["unit_to_readout_clearance_px"]), player_cast[1] - int(player_strips[1]["origin"][1]) - 19)

    bars = {bar["id"]: bar for bar in spec["bars"]}
    main_x, main_y, main_w, main_h, _, _, _ = bar_geometry(bars["AB.BAR1.MAIN"], ui_scale)
    top_x, top_y, top_w, _, _, _, _ = bar_geometry(bars["AB.BAR6.TOP"], ui_scale)
    check("deck.main-center", int(contract["main_bar_center_x"]), round(main_x + main_w / 2))
    check("deck.top-center", int(contract["main_bar_center_x"]), round(top_x + top_w / 2))
    check("deck.readout-clearance", int(contract["readout_to_deck_clearance_px"]), top_y - offhand[3])

    pouch_x, _, pouch_w, _, _, _, _ = bar_geometry(spec["consumables"], ui_scale)
    trinket_x, _, _, _, _, _, _ = bar_geometry(spec["trinkets"], ui_scale)
    check("dock.consumable-gap", int(contract["consumable_to_main_gap_px"]), main_x - (pouch_x + pouch_w))
    check("dock.player-clearance", int(contract["consumable_to_player_gap_px"]), player[0] - (pouch_x + pouch_w))
    check("dock.trinket-gap", int(contract["main_to_trinket_gap_px"]), trinket_x - (main_x + main_w))
    check("dock.group-labels", False, bool(spec["consumables"].get("labels_visible", True)))

    geometry = totem_geometry(spec["totem_satellite"], ui_scale)
    check("dock.totem-direction", "down", spec["totem_satellite"]["direction"])
    check("dock.totem-gap", int(contract["totem_to_xp_rail_clearance_px"]), geometry["y"] - int(contract["xp_rail_bottom_y"]))
    check("dock.totem-center", int(contract["main_bar_center_x"]), round(geometry["x"] + geometry["width"] / 2))

    check("layout.no-unit-readout-overlap", True, player_strips[1]["origin"][1] + 19 <= player_cast[1])
    check("layout.no-readout-deck-overlap", True, offhand[3] <= top_y)
    check("layout.no-consumable-player-overlap", True, pouch_x + pouch_w <= player[0])

    violations = [item["id"] for item in checks if not item["pass"]]
    return {
        "schema": "aeui-action-bars-layout-report-v1",
        "version": spec["version"],
        "target": spec["target"],
        "status": "pass" if not violations else "fail",
        "checks": checks,
        "violations": violations,
        "first_failure": violations[0] if violations else None,
    }


def validate_compact_stack_v7(
    spec: dict[str, Any],
    contract: dict[str, Any],
) -> dict[str, Any]:
    """Validate the V7 equal-unit, edge-aura, vertical readout stack."""
    ui_scale = float(spec["target"]["ui_scale"])
    checks: list[dict[str, Any]] = []

    def check(identifier: str, expected: Any, actual: Any) -> None:
        checks.append({
            "id": identifier,
            "expected": expected,
            "actual": actual,
            "pass": actual == expected,
        })

    frames = {frame["id"]: frame for frame in spec["unit_frames"]["frames"]}
    player_frame = frames["UF.PLAYER.ADJACENCY"]
    target_frame = frames["UF.TARGET.ADJACENCY"]
    target_target_frame = frames["UF.TARGETTARGET.ADJACENCY"]
    player = list(map(int, player_frame["screen_box"]))
    target = list(map(int, target_frame["screen_box"]))
    target_target = list(map(int, target_target_frame["screen_box"]))
    unit_widths = [box[2] - box[0] for box in (player, target, target_target)]
    unit_heights = [box[3] - box[1] for box in (player, target, target_target)]
    check("unit.equal-widths", [int(contract["unit_frame_width_px"])] * 3, unit_widths)
    check("unit.equal-heights", [int(contract["unit_frame_height_px"])] * 3, unit_heights)
    check("unit.player-target-gap", int(contract["player_target_gap_px"]), target[0] - player[2])
    check("unit.cluster-center", int(contract["unit_cluster_center_x"]), round((player[0] + target[2]) / 2))
    check("targettarget.align-target-left", target[0], target_target[0])
    check("targettarget.align-target-right", target[2], target_target[2])
    check("targettarget.vertical-gap", int(contract["targettarget_vertical_gap_px"]), target[1] - target_target[3])

    player_strips = player_frame["aura_strips"]
    target_strips = target_frame["aura_strips"]
    target_target_strips = target_target_frame["aura_strips"]
    aura_size = int(contract["aura_size_px"])
    check("aura.player-buffs-direction", "ltr", player_strips[0]["direction"])
    check("aura.player-debuffs-direction", "ltr", player_strips[1]["direction"])
    check("aura.target-buffs-direction", "rtl", target_strips[0]["direction"])
    check("aura.target-debuffs-direction", "rtl", target_strips[1]["direction"])
    check("aura.targettarget-buffs-direction", "rtl", target_target_strips[0]["direction"])
    check("aura.targettarget-debuffs-direction", "rtl", target_target_strips[1]["direction"])
    check("aura.shared-size", [aura_size] * 6, [
        int(strip["size"])
        for strip in player_strips + target_strips + target_target_strips
    ])
    check("aura.player-buff-left-edge", player[0], int(player_strips[0]["origin"][0]))
    check("aura.player-debuff-left-edge", player[0], int(player_strips[1]["origin"][0]))
    check("aura.target-buff-right-edge", target[2], int(target_strips[0]["origin"][0]) + aura_size)
    check("aura.target-debuff-right-edge", target[2], int(target_strips[1]["origin"][0]) + aura_size)
    check("aura.targettarget-buff-right-edge", target_target[2], int(target_target_strips[0]["origin"][0]) + aura_size)
    check("aura.targettarget-debuff-right-edge", target_target[2], int(target_target_strips[1]["origin"][0]) + aura_size)
    check(
        "aura.internal-lane-gap",
        int(contract["internal_aura_lane_gap_px"]),
        int(target_strips[0]["origin"][1]) -
        (int(target_target_strips[1]["origin"][1]) + aura_size),
    )

    castbars = {
        item["id"]: list(map(int, item["screen_box"]))
        for item in spec["cast_bars"]["bars"]
        if item.get("visible_in_simulation", True)
    }
    player_cast = castbars["CAST.PLAYER"]
    target_cast = castbars["CAST.TARGET"]
    swings = {
        item["id"]: indicator_box(item, ui_scale)
        for item in spec["swing_timers"]["bars"]
    }
    swing = swings["SWING.MAINHAND"]
    offhand = swings["SWING.OFFHAND"]
    readout_widths = [
        player_cast[2] - player_cast[0],
        target_cast[2] - target_cast[0],
        swing[2] - swing[0],
        offhand[2] - offhand[0],
    ]
    readout_heights = [
        player_cast[3] - player_cast[1],
        target_cast[3] - target_cast[1],
        swing[3] - swing[1],
        offhand[3] - offhand[1],
    ]
    check("readout.equal-widths", [int(contract["readout_width_px"])] * 4, readout_widths)
    check("readout.equal-heights", [int(contract["readout_height_px"])] * 4, readout_heights)
    check("readout.cast-shared-top", player_cast[1], target_cast[1])
    check("readout.cast-horizontal-gap", int(contract["cast_horizontal_gap_px"]), target_cast[0] - player_cast[2])
    check("readout.swing-center", int(contract["main_bar_center_x"]), round((swing[0] + swing[2]) / 2))
    check("readout.cast-to-swing-gap", int(contract["cast_to_swing_gap_px"]), swing[1] - player_cast[3])
    check("readout.offhand-gap", int(contract["swing_pair_gap_px"]), offhand[1] - swing[3])
    check(
        "readout.unit-debuff-to-cast-gap",
        int(contract["unit_debuff_to_cast_gap_px"]),
        player_cast[1] - (int(player_strips[1]["origin"][1]) + aura_size),
    )

    bars = {bar["id"]: bar for bar in spec["bars"]}
    main_x, _, main_w, _, _, _, _ = bar_geometry(bars["AB.BAR1.MAIN"], ui_scale)
    top_x, top_y, top_w, _, _, _, _ = bar_geometry(bars["AB.BAR6.TOP"], ui_scale)
    check("deck.main-center", int(contract["main_bar_center_x"]), round(main_x + main_w / 2))
    check("deck.top-center", int(contract["main_bar_center_x"]), round(top_x + top_w / 2))
    check("deck.readout-clearance", int(contract["readout_to_deck_clearance_px"]), top_y - offhand[3])

    pouch_x, _, pouch_w, _, _, _, _ = bar_geometry(spec["consumables"], ui_scale)
    trinket_x, _, _, _, _, _, _ = bar_geometry(spec["trinkets"], ui_scale)
    check("dock.consumable-gap", int(contract["consumable_to_main_gap_px"]), main_x - (pouch_x + pouch_w))
    check("dock.player-clearance", int(contract["consumable_to_player_gap_px"]), player[0] - (pouch_x + pouch_w))
    check("dock.trinket-gap", int(contract["main_to_trinket_gap_px"]), trinket_x - (main_x + main_w))
    check("dock.group-labels", False, bool(spec["consumables"].get("labels_visible", True)))

    geometry = totem_geometry(spec["totem_satellite"], ui_scale)
    check("dock.totem-direction", "down", spec["totem_satellite"]["direction"])
    check("dock.totem-gap", int(contract["totem_to_xp_rail_clearance_px"]), geometry["y"] - int(contract["xp_rail_bottom_y"]))
    check("dock.totem-center", int(contract["main_bar_center_x"]), round(geometry["x"] + geometry["width"] / 2))

    doite = indicator_box(spec["doite_dps"], ui_scale)
    doite_resource_height = ui_px(
        spec["doite_dps"].get("resource_height_ui", 22),
        ui_scale,
        float(spec["doite_dps"].get("scale", 1.0)),
    )
    doite_resource_gap = ui_px(
        spec["doite_dps"].get("resource_gap_ui", 2),
        ui_scale,
        float(spec["doite_dps"].get("scale", 1.0)),
    )
    doite_union = (doite[0], doite[1] - doite_resource_gap - doite_resource_height, doite[2], doite[3])
    check("doitedps.targettarget-clearance", int(contract["doitedps_to_targettarget_clearance_px"]), target_target[0] - doite_union[2])
    check("doitedps.two-row-union-clear", True, doite_union[2] <= target_target[0] and doite_union[3] <= player_strips[0]["origin"][1])

    check("layout.no-consumable-player-overlap", True, pouch_x + pouch_w <= player[0])
    check("layout.no-unit-readout-overlap", True, int(player_strips[1]["origin"][1]) + aura_size <= player_cast[1])
    check("layout.no-readout-deck-overlap", True, offhand[3] <= top_y)

    violations = [item["id"] for item in checks if not item["pass"]]
    return {
        "schema": "aeui-action-bars-layout-report-v1",
        "version": spec["version"],
        "target": spec["target"],
        "status": "pass" if not violations else "fail",
        "checks": checks,
        "violations": violations,
        "first_failure": violations[0] if violations else None,
    }


def validate_compact_stack_v8(
    spec: dict[str, Any],
    contract: dict[str, Any],
) -> dict[str, Any]:
    """Validate V8/V9/V10 right-attached units and centered timing stacks."""
    ui_scale = float(spec["target"]["ui_scale"])
    checks: list[dict[str, Any]] = []

    def check(identifier: str, expected: Any, actual: Any) -> None:
        checks.append({
            "id": identifier,
            "expected": expected,
            "actual": actual,
            "pass": actual == expected,
        })

    def strip_bounds(strip: dict[str, Any]) -> tuple[int, int, int, int]:
        x, y = map(int, strip["origin"])
        size = int(strip["size"])
        gap = int(strip["gap"])
        count = len(strip.get("auras", []))
        per_row = max(1, int(strip.get("per_row", count or 1)))
        columns = min(count, per_row)
        rows = max(1, (count + per_row - 1) // per_row)
        row_gap = int(strip.get("row_gap", gap))
        last_step = max(0, columns - 1) * (size + gap)
        bottom = y + size + max(0, rows - 1) * (size + row_gap)
        if strip["direction"] == "rtl":
            return x - last_step, y, x + size, bottom
        return x, y, x + last_step + size, bottom

    frames = {frame["id"]: frame for frame in spec["unit_frames"]["frames"]}
    player_frame = frames["UF.PLAYER.ADJACENCY"]
    target_frame = frames["UF.TARGET.ADJACENCY"]
    target_target_frame = frames["UF.TARGETTARGET.ADJACENCY"]
    frame_configs = [player_frame, target_frame, target_target_frame]
    player = list(map(int, player_frame["screen_box"]))
    target = list(map(int, target_frame["screen_box"]))
    target_target = list(map(int, target_target_frame["screen_box"]))
    frame_boxes = [player, target, target_target]
    unit_widths = [box[2] - box[0] for box in frame_boxes]
    unit_heights = [box[3] - box[1] for box in frame_boxes]
    expected_widths = list(map(int, contract.get(
        "unit_frame_widths_px",
        [int(contract["unit_frame_width_px"])] * 3,
    )))
    expected_heights = list(map(int, contract.get(
        "unit_frame_heights_px",
        [int(contract["unit_frame_height_px"])] * 3,
    )))
    check("unit.widths", expected_widths, unit_widths)
    check("unit.heights", expected_heights, unit_heights)
    if "targettarget_vertical_center_offset_px" in contract:
        check("unit.player-target-shared-y", player[1::2], target[1::2])
        check(
            "targettarget.vertical-center-offset",
            int(contract["targettarget_vertical_center_offset_px"]),
            round((target_target[1] + target_target[3]) / 2) -
            round((target[1] + target[3]) / 2),
        )
    else:
        check("unit.shared-top", [player[1]] * 3, [box[1] for box in frame_boxes])
        check("unit.shared-bottom", [player[3]] * 3, [box[3] for box in frame_boxes])
    check("unit.player-target-gap", int(contract["player_target_gap_px"]), target[0] - player[2])
    check("unit.player-target-center", int(contract["player_target_center_x"]), round((player[0] + target[2]) / 2))
    check("targettarget.right-gap", int(contract["targettarget_gap_px"]), target_target[0] - target[2])
    if "targettarget_vertical_center_offset_px" in contract:
        check(
            "targettarget.center-attached",
            round((target[1] + target[3]) / 2) +
            int(contract["targettarget_vertical_center_offset_px"]),
            round((target_target[1] + target_target[3]) / 2),
        )
    else:
        check("targettarget.same-baseline", target[3], target_target[3])
    check("unit.three-frame-center", int(contract["three_unit_cluster_center_x"]), round((player[0] + target_target[2]) / 2))
    font_roles = contract.get("unit_font_roles", {
        "name": "small",
        "level": "tiny",
        "health": "tiny",
    })
    check("unit.font-name-role", [str(font_roles["name"])] * 3, [str(frame.get("name_font")) for frame in frame_configs])
    check("unit.font-level-role", [str(font_roles["level"])] * 3, [str(frame.get("level_font")) for frame in frame_configs])
    check("unit.font-health-role", [str(font_roles["health"])] * 3, [str(frame.get("health_font")) for frame in frame_configs])

    player_strips = player_frame["aura_strips"]
    target_strips = target_frame["aura_strips"]
    target_target_strips = target_target_frame["aura_strips"]
    all_strips = player_strips + target_strips + target_target_strips
    aura_size = int(contract["aura_size_px"])
    aura_gap = int(contract["aura_gap_px"])
    aura_count = int(contract["aura_per_row"])
    check("aura.player-buffs-direction", "ltr", player_strips[0]["direction"])
    check("aura.player-debuffs-direction", "ltr", player_strips[1]["direction"])
    check("aura.target-buffs-direction", "rtl", target_strips[0]["direction"])
    check("aura.target-debuffs-direction", "rtl", target_strips[1]["direction"])
    check("aura.targettarget-buffs-direction", "rtl", target_target_strips[0]["direction"])
    check("aura.targettarget-debuffs-direction", "rtl", target_target_strips[1]["direction"])
    expected_aura_sizes = list(map(int, contract.get(
        "aura_sizes_px", [aura_size] * 6
    )))
    expected_aura_gaps = list(map(int, contract.get(
        "aura_gaps_px", [aura_gap] * 6
    )))
    check("aura.sizes", expected_aura_sizes, [int(strip["size"]) for strip in all_strips])
    check("aura.gaps", expected_aura_gaps, [int(strip["gap"]) for strip in all_strips])
    expected_aura_counts = list(map(int, contract.get(
        "aura_counts", [aura_count] * 6
    )))
    check("aura.counts", expected_aura_counts, [len(strip["auras"]) for strip in all_strips])
    check("aura.player-buff-left-edge", player[0], int(player_strips[0]["origin"][0]))
    check("aura.player-debuff-left-edge", player[0], int(player_strips[1]["origin"][0]))
    check("aura.target-buff-right-edge", target[2], int(target_strips[0]["origin"][0]) + int(target_strips[0]["size"]))
    check("aura.target-debuff-right-edge", target[2], int(target_strips[1]["origin"][0]) + int(target_strips[1]["size"]))
    check("aura.targettarget-buff-right-edge", target_target[2], int(target_target_strips[0]["origin"][0]) + int(target_target_strips[0]["size"]))
    check("aura.targettarget-debuff-right-edge", target_target[2], int(target_target_strips[1]["origin"][0]) + int(target_target_strips[1]["size"]))
    strip_boxes = [strip_bounds(strip) for strip in all_strips]
    expected_spans = list(map(int, contract.get(
        "aura_row_spans_px", [int(contract["aura_row_span_px"])] * 6
    )))
    expected_slacks = list(map(int, contract.get(
        "aura_row_slacks_px", [int(contract["aura_row_slack_px"])] * 6
    )))
    check("aura.row-span", expected_spans, [box[2] - box[0] for box in strip_boxes])
    check("aura.row-slack", expected_slacks, [unit_widths[index // 2] - (box[2] - box[0]) for index, box in enumerate(strip_boxes)])
    check("aura.target-targettarget-buff-clear", True, strip_boxes[2][2] <= strip_boxes[4][0])
    check("aura.target-targettarget-debuff-clear", True, strip_boxes[3][2] <= strip_boxes[5][0])
    runtime_aura_span = int(contract["aura_size_ui"]) + (aura_count - 1) * (
        int(contract["aura_size_ui"]) + int(contract["aura_gap_ui"])
    )
    check("aura.runtime-row-span", int(contract["aura_row_span_ui"]), runtime_aura_span)
    check("aura.runtime-row-slack", int(contract["aura_row_slack_ui"]), 240 - runtime_aura_span)
    if "target_debuff_dense_count" in contract:
        target_debuff_count = len(target_strips[1]["auras"])
        target_debuff_per_row = int(target_strips[1].get("per_row", target_debuff_count))
        target_debuff_rows = (target_debuff_count + target_debuff_per_row - 1) // target_debuff_per_row
        check("aura.target-debuff-dense-count", int(contract["target_debuff_dense_count"]), target_debuff_count)
        check("aura.target-debuff-rows", int(contract["target_debuff_rows"]), target_debuff_rows)

    castbars = {
        item["id"]: list(map(int, item["screen_box"]))
        for item in spec["cast_bars"]["bars"]
        if item.get("visible_in_simulation", True)
    }
    player_cast = castbars["CAST.PLAYER"]
    target_cast = castbars["CAST.TARGET"]
    swings = {
        item["id"]: indicator_box(item, ui_scale)
        for item in spec["swing_timers"]["bars"]
    }
    swing = swings["SWING.MAINHAND"]
    offhand = swings["SWING.OFFHAND"]
    readouts = [player_cast, target_cast, swing, offhand]
    check("readout.equal-widths", [int(contract["readout_width_px"])] * 4, [box[2] - box[0] for box in readouts])
    check("readout.equal-heights", [int(contract["readout_height_px"])] * 4, [box[3] - box[1] for box in readouts])
    check("readout.shared-center", [int(contract["main_bar_center_x"])] * 4, [round((box[0] + box[2]) / 2) for box in readouts])
    check("readout.player-target-gap", int(contract["readout_row_gap_px"]), target_cast[1] - player_cast[3])
    check("readout.target-swing-gap", int(contract["readout_row_gap_px"]), swing[1] - target_cast[3])
    check("readout.offhand-gap", int(contract["swing_pair_gap_px"]), offhand[1] - swing[3])
    check("readout.unit-debuff-gap", int(contract["unit_debuff_to_readout_gap_px"]), player_cast[1] - strip_boxes[1][3])
    if "target_debuff_to_readout_gap_px" in contract:
        check(
            "readout.target-debuff-dense-gap",
            int(contract["target_debuff_to_readout_gap_px"]),
            player_cast[1] - strip_boxes[3][3],
        )

    bars = {bar["id"]: bar for bar in spec["bars"]}
    main_x, _, main_w, _, _, _, _ = bar_geometry(bars["AB.BAR1.MAIN"], ui_scale)
    top_x, top_y, top_w, _, _, _, _ = bar_geometry(bars["AB.BAR6.TOP"], ui_scale)
    check("deck.main-center", int(contract["main_bar_center_x"]), round(main_x + main_w / 2))
    check("deck.top-center", int(contract["main_bar_center_x"]), round(top_x + top_w / 2))
    check("deck.readout-clearance", int(contract["readout_to_deck_clearance_px"]), top_y - offhand[3])

    pouch_x, pouch_y, pouch_w, pouch_h, _, _, _ = bar_geometry(spec["consumables"], ui_scale)
    trinket_x, trinket_y, _, trinket_h, _, _, _ = bar_geometry(spec["trinkets"], ui_scale)
    check("dock.consumable-gap", int(contract["consumable_to_main_gap_px"]), main_x - (pouch_x + pouch_w))
    check("dock.player-clearance", int(contract["consumable_to_player_gap_px"]), player[0] - (pouch_x + pouch_w))
    check("dock.trinket-gap", int(contract["main_to_trinket_gap_px"]), trinket_x - (main_x + main_w))
    check("dock.group-labels", False, bool(spec["consumables"].get("labels_visible", True)))
    if "fieldkit_shared_dock_bottom_px" in contract:
        check(
            "dock.shared-lower-bottom",
            [int(contract["fieldkit_shared_dock_bottom_px"])] * 2,
            [pouch_y + pouch_h, trinket_y + trinket_h],
        )

    geometry = totem_geometry(spec["totem_satellite"], ui_scale)
    check("dock.totem-direction", "down", spec["totem_satellite"]["direction"])
    check("dock.totem-gap", int(contract["totem_to_xp_rail_clearance_px"]), geometry["y"] - int(contract["xp_rail_bottom_y"]))
    check("dock.totem-center", int(contract["main_bar_center_x"]), round(geometry["x"] + geometry["width"] / 2))

    doite = indicator_box(spec["doite_dps"], ui_scale)
    doite_resource_height = ui_px(
        spec["doite_dps"].get("resource_height_ui", 22),
        ui_scale,
        float(spec["doite_dps"].get("scale", 1.0)),
    )
    doite_resource_gap = ui_px(
        spec["doite_dps"].get("resource_gap_ui", 2),
        ui_scale,
        float(spec["doite_dps"].get("scale", 1.0)),
    )
    doite_union = (doite[0], doite[1] - doite_resource_gap - doite_resource_height, doite[2], doite[3])
    check("doitedps.unit-aura-vertical-clearance", int(contract["doitedps_to_unit_aura_vertical_clearance_px"]), strip_boxes[0][1] - doite_union[3])
    check("doitedps.two-row-union-clear", True, doite_union[3] <= strip_boxes[0][1])

    check("layout.no-consumable-player-overlap", True, pouch_x + pouch_w <= player[0])
    deepest_unit_debuff_bottom = max(strip_boxes[1][3], strip_boxes[3][3], strip_boxes[5][3])
    check("layout.no-unit-readout-overlap", True, deepest_unit_debuff_bottom <= player_cast[1])
    check("layout.no-readout-deck-overlap", True, offhand[3] <= top_y)
    check("layout.targettarget-inside-focus-field", True, target_target[2] <= int(spec["focus_field"]["screen_box"][2]))

    side_cluster = spec.get("side_cluster")
    if side_cluster:
        side_bars = list(side_cluster.get("bars", []))
        side_boxes = [bar_geometry(item, ui_scale) for item in side_bars]
        side_rights = [item[0] + item[2] for item in side_boxes]
        side_bottoms = [item[1] + item[3] for item in side_boxes]
        union = (
            min(item[0] for item in side_boxes),
            min(item[1] for item in side_boxes),
            max(side_rights),
            max(side_bottoms),
        )
        check(
            "sidecluster.proposal-only",
            True,
            bool(side_cluster.get("proposal_only")),
        )
        check(
            "sidecluster.provider-order",
            list(contract["side_cluster_provider_order"]),
            [str(item["id"]) for item in side_bars],
        )
        check(
            "sidecluster.tile-shapes",
            [[12, 3, 4]] * 4,
            [
                [int(item["buttons"]), int(item["cols"]), int(item["rows"])]
                for item in side_bars
            ],
        )
        check(
            "sidecluster.union-size",
            list(map(int, contract["side_cluster_union_size_px"])),
            [union[2] - union[0], union[3] - union[1]],
        )
        check(
            "sidecluster.right-inset",
            int(contract["side_cluster_right_inset_px"]),
            int(spec["canvas"]["width"]) - union[2],
        )
        check(
            "sidecluster.center-offset-y",
            int(contract["side_cluster_center_offset_y_px"]),
            round((union[1] + union[3]) / 2) -
            round(int(spec["canvas"]["height"]) / 2),
        )
        check(
            "sidecluster.horizontal-gaps",
            [int(contract["side_cluster_tile_gap_px"])] * 2,
            [side_boxes[1][0] - side_rights[0],
             side_boxes[3][0] - side_rights[2]],
        )
        check(
            "sidecluster.vertical-gaps",
            [int(contract["side_cluster_tile_gap_px"])] * 2,
            [side_boxes[2][1] - side_bottoms[0],
             side_boxes[3][1] - side_bottoms[1]],
        )

    violations = [item["id"] for item in checks if not item["pass"]]
    return {
        "schema": "aeui-action-bars-layout-report-v1",
        "version": spec["version"],
        "target": spec["target"],
        "status": "pass" if not violations else "fail",
        "checks": checks,
        "violations": violations,
        "first_failure": violations[0] if violations else None,
    }


def validate_layout(spec: dict[str, Any]) -> dict[str, Any]:
    contract = spec.get("layout_contract")
    if not contract:
        return {
            "schema": "aeui-action-bars-layout-report-v1",
            "version": spec["version"],
            "status": "not-applicable",
            "checks": [],
            "violations": [],
        }

    if contract.get("layout_mode") == "compact-row-v6":
        return validate_compact_row_v6(spec, contract)

    if contract.get("layout_mode") == "compact-stack-v7":
        return validate_compact_stack_v7(spec, contract)

    if contract.get("layout_mode") == "compact-stack-v8":
        return validate_compact_stack_v8(spec, contract)

    if contract.get("layout_mode") == "compact-stack-v9":
        return validate_compact_stack_v8(spec, contract)

    if contract.get("layout_mode") == "compact-stack-v10":
        return validate_compact_stack_v8(spec, contract)

    if contract.get("layout_mode") == "compact-stack-v11":
        return validate_compact_stack_v8(spec, contract)

    ui_scale = float(spec["target"]["ui_scale"])
    checks: list[dict[str, Any]] = []

    def check(identifier: str, expected: Any, actual: Any) -> None:
        checks.append({
            "id": identifier,
            "expected": expected,
            "actual": actual,
            "pass": actual == expected,
        })

    frames = {frame["id"]: frame for frame in spec["unit_frames"]["frames"]}
    player = list(map(int, frames["UF.PLAYER.ADJACENCY"]["screen_box"]))
    target = list(map(int, frames["UF.TARGET.ADJACENCY"]["screen_box"]))
    check("unit-frames.same-top", player[1], target[1])
    check("unit-frames.same-baseline", int(contract["unit_frame_baseline_y"]), player[3])
    check("unit-frames.target-baseline", int(contract["unit_frame_baseline_y"]), target[3])
    check("unit-frames.inner-gap", int(contract["unit_frame_inner_gap_px"]), target[0] - player[2])
    check(
        "unit-frames.cluster-center-x",
        int(contract["unit_frame_outer_cluster_center_x"]),
        round((player[0] + target[2]) / 2),
    )
    safe_box = contract.get("player_core_safe_box")
    if safe_box:
        safe_left, _, safe_right, _ = map(int, safe_box)
        check("unit-frames.player-safe-lane-left", safe_left, player[2])
        check("unit-frames.player-safe-lane-right", safe_right, target[0])
        check(
            "unit-frames.player-safe-lane-width",
            int(contract["player_core_safe_width_px"]),
            safe_right - safe_left,
        )

    aura_top = min(
        int(frame["aura_origin"][1])
        for frame in spec["unit_frames"]["frames"]
    )
    aura_bottom = max(
        int(frame["aura_origin"][1]) + 19
        for frame in spec["unit_frames"]["frames"]
    )
    if "unit_frame_aura_top_y" in contract:
        check("unit-frames.aura-top", int(contract["unit_frame_aura_top_y"]), aura_top)
    if "unit_frame_aura_bottom_y" in contract:
        check("unit-frames.aura-bottom", int(contract["unit_frame_aura_bottom_y"]), aura_bottom)

    bars = {bar["id"]: bar for bar in spec["bars"]}
    main_x, main_y, main_w, main_h, main_button, _, _ = bar_geometry(bars["AB.BAR1.MAIN"], ui_scale)
    stance_x, stance_y, stance_w, _, _, _, _ = bar_geometry(bars["AB.BAR11.STANCE"], ui_scale)
    check("combat-bars.stance-top", int(contract["stance_top_y"]), stance_y)
    if "aura_to_stance_clearance_px" in contract:
        check(
            "combat-bars.aura-to-stance-clearance",
            int(contract["aura_to_stance_clearance_px"]),
            stance_y - aura_bottom,
        )
    check("combat-bars.main-top", int(contract["main_bar_top_y"]), main_y)
    check("combat-bars.main-bottom", int(contract["main_bar_bottom_y"]), main_y + main_h)
    check("combat-bars.main-center-x", int(contract["main_bar_center_x"]), round(main_x + main_w / 2))
    check("combat-bars.stance-center-x", int(contract["main_bar_center_x"]), round(stance_x + stance_w / 2))
    check("combat-bars.main-button-size", int(contract["main_button_physical_px"]), main_button)
    check(
        "combat-bars.main-bottom-clearance",
        int(contract["main_bar_bottom_clearance_px"]),
        int(spec["canvas"]["height"]) - (main_y + main_h),
    )
    check("combat-bars.xp-rail-bottom", int(contract["xp_rail_bottom_y"]), main_y + main_h + 12)

    pouch_x, pouch_y, pouch_w, pouch_h, _, _, _ = bar_geometry(spec["consumables"], ui_scale)
    pouch_shell = (pouch_x - 7, pouch_y - 9, pouch_x + pouch_w + 7, pouch_y + pouch_h + 8)
    chat_box = (38, 824, 526, 1044)
    pouch_chat_overlap = (
        pouch_shell[0] < chat_box[2]
        and pouch_shell[2] > chat_box[0]
        and pouch_shell[1] < chat_box[3]
        and pouch_shell[3] > chat_box[1]
    )
    check("adjacency.consumables-clear-chat", False, pouch_chat_overlap)

    proposed = spec["unit_frames"]["profile_recommendation"]["proposed_shared"]
    proposed_width = ui_px(proposed["width_ui"], ui_scale, proposed["scale"])
    proposed_height = ui_px(proposed["height_ui"], ui_scale, proposed["scale"])
    check("profile-proposal.player-width", player[2] - player[0], proposed_width)
    check("profile-proposal.target-width", target[2] - target[0], proposed_width)
    check("profile-proposal.player-height", player[3] - player[1], proposed_height)
    check("profile-proposal.target-height", target[3] - target[1], proposed_height)

    castbar_boxes: dict[str, list[int]] = {}
    if "cast_bars" in spec:
        castbar_boxes = {
            item["id"]: list(map(int, item["screen_box"]))
            for item in spec["cast_bars"].get("bars", [])
            if item.get("visible_in_simulation", True)
        }
        player_cast = castbar_boxes["CAST.PLAYER"]
        target_cast = castbar_boxes["CAST.TARGET"]
        check("castbars.same-top", player_cast[1], target_cast[1])
        check("castbars.same-bottom", player_cast[3], target_cast[3])
        check("castbars.player-width-matches-frame", player[2] - player[0], player_cast[2] - player_cast[0])
        check("castbars.target-width-matches-frame", target[2] - target[0], target_cast[2] - target_cast[0])
        check("castbars.pair-inner-gap", int(contract["castbar_pair_inner_gap_px"]), target_cast[0] - player_cast[2])
        check("castbars.top", int(contract["castbar_top_y"]), player_cast[1])
        check("castbars.bottom", int(contract["castbar_bottom_y"]), player_cast[3])
        check("castbars.height", int(contract["castbar_height_px"]), player_cast[3] - player_cast[1])
        check("castbars.unitframe-gap", int(contract["unitframe_to_castbar_gap_px"]), player_cast[1] - player[3])
        check("castbars.to-stance-clearance", int(contract["castbar_to_stance_clearance_px"]), stance_y - player_cast[3])

    swing_boxes: dict[str, tuple[int, int, int, int]] = {}
    if "swing_timers" in spec:
        swing_boxes = {
            item["id"]: indicator_box(item, ui_scale)
            for item in spec["swing_timers"].get("bars", [])
        }
        main_swing = swing_boxes["SWING.MAINHAND"]
        off_swing = swing_boxes["SWING.OFFHAND"]
        check("swing.main-top", int(contract["swing_main_top_y"]), main_swing[1])
        check("swing.pair-bottom", int(contract["swing_pair_bottom_y"]), off_swing[3])
        check("swing.width", int(contract["swing_width_px"]), main_swing[2] - main_swing[0])
        check("swing.height", int(contract["swing_height_px"]), main_swing[3] - main_swing[1])
        check("swing.pair-gap", int(contract["swing_pair_gap_px"]), off_swing[1] - main_swing[3])
        check("swing.main-center-x", int(contract["main_bar_center_x"]), round((main_swing[0] + main_swing[2]) / 2))
        check("swing.offhand-center-x", int(contract["main_bar_center_x"]), round((off_swing[0] + off_swing[2]) / 2))
        check("swing.to-aura-clearance", int(contract["swing_to_aura_clearance_px"]), aura_top - off_swing[3])
        if castbar_boxes and "attack_to_castbar_clearance_px" in contract:
            check(
                "swing.to-castbar-clearance",
                int(contract["attack_to_castbar_clearance_px"]),
                castbar_boxes["CAST.PLAYER"][1] - off_swing[3],
            )

    if "doite_dps" in spec:
        doite_box = indicator_box(spec["doite_dps"], ui_scale)
        check("doitedps.root-top", int(contract["doitedps_root_top_y"]), doite_box[1])
        check("doitedps.root-bottom", int(contract["doitedps_root_bottom_y"]), doite_box[3])
        check("doitedps.root-width", int(contract["doitedps_root_width_px"]), doite_box[2] - doite_box[0])
        check("doitedps.root-height", int(contract["doitedps_root_height_px"]), doite_box[3] - doite_box[1])
        check("doitedps.center-x", int(contract["main_bar_center_x"]), round((doite_box[0] + doite_box[2]) / 2))
        if swing_boxes:
            main_swing = swing_boxes["SWING.MAINHAND"]
            check("doitedps.to-swing-clearance", int(contract["doitedps_to_swing_clearance_px"]), main_swing[1] - doite_box[3])

    if "totem_satellite" in spec:
        totem = spec["totem_satellite"]
        geometry = totem_geometry(totem, ui_scale)
        totem_x = geometry["x"]
        totem_y = geometry["y"]
        check("totem.direction", str(contract["totem_popup_direction"]), str(totem.get("direction", "down")))
        check("totem.row-top", int(contract["totem_row_top_y"]), totem_y)
        check("totem.row-bottom", int(contract["totem_row_bottom_y"]), totem_y + geometry["row_height"])
        check("totem.visible-width", int(contract["totem_visible_width_px"]), geometry["width"])
        check("totem.center-x", int(contract["main_bar_center_x"]), round(totem_x + geometry["width"] / 2))
        check("totem.popup-bottom", int(contract["totem_popup_bottom_y"]), geometry["popup_bottom"])
        check(
            "totem.popup-bottom-clearance",
            int(contract["totem_popup_bottom_clearance_px"]),
            int(spec["canvas"]["height"]) - geometry["popup_bottom"],
        )
        check(
            "totem.clear-xp-rail",
            int(contract["totem_to_xp_rail_clearance_px"]),
            totem_y - int(contract["xp_rail_bottom_y"]),
        )

    if castbar_boxes and swing_boxes and "doite_dps" in spec:
        doite_box = indicator_box(spec["doite_dps"], ui_scale)
        vertical_order = [
            doite_box[1],
            swing_boxes["SWING.MAINHAND"][1],
            aura_top,
            player[1],
            castbar_boxes["CAST.PLAYER"][1],
            stance_y,
            main_y,
        ]
        check("combat-focus.strict-vertical-order", sorted(vertical_order), vertical_order)
        if "combat_focus_max_interlayer_gap_px" in contract:
            interlayer_gaps = [
                swing_boxes["SWING.MAINHAND"][1] - doite_box[3],
                aura_top - swing_boxes["SWING.OFFHAND"][3],
                player[1] - aura_bottom,
                castbar_boxes["CAST.PLAYER"][1] - player[3],
                stance_y - castbar_boxes["CAST.PLAYER"][3],
            ]
            check(
                "combat-focus.max-interlayer-gap",
                int(contract["combat_focus_max_interlayer_gap_px"]),
                max(interlayer_gaps),
            )

    violations = [item["id"] for item in checks if not item["pass"]]
    return {
        "schema": "aeui-action-bars-layout-report-v1",
        "version": spec["version"],
        "target": spec["target"],
        "status": "pass" if not violations else "fail",
        "checks": checks,
        "violations": violations,
        "first_failure": violations[0] if violations else None,
    }


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    spec = load_spec(args.spec.resolve(), root)
    canvas = spec["canvas"]
    image = Image.new("RGBA", (int(canvas["width"]), int(canvas["height"])), rgba(canvas["fill"]))
    draw = ImageDraw.Draw(image, "RGBA")
    fonts = {name: load_font(root, definition) for name, definition in spec["fonts"].items()}
    palette = spec["palette"]
    ui_scale = float(spec["target"]["ui_scale"])

    draw_scene(image, draw, palette)
    if "unit_frames" in spec:
        draw_placeholder_ui_v2(draw, fonts, palette, spec)
    else:
        draw_placeholder_ui_v1(draw, fonts, palette)
    for bar in spec["bars"]:
        if bar.get("visible_in_simulation", True):
            draw_bar(draw, bar, ui_scale, fonts, palette)
    if "side_cluster" in spec:
        draw_side_cluster(draw, spec["side_cluster"], ui_scale, fonts, palette)
    draw_pouch(draw, spec["consumables"], ui_scale, fonts, palette)
    draw_trinkets(draw, spec["trinkets"], ui_scale, fonts, palette)
    if "totem_satellite" in spec:
        draw_totem_satellite(
            draw, spec["totem_satellite"], ui_scale, fonts, palette
        )

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

    if args.layout_report:
        report = validate_layout(spec)
        report_path = args.layout_report
        if not report_path.is_absolute():
            report_path = root / report_path
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(report_path.resolve())
        if report["status"] == "fail":
            raise SystemExit(1)


if __name__ == "__main__":
    main()
