#!/usr/bin/env python3
"""Render the deterministic, non-production UF complete-shell and bar preview."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SPEC = ROOT / "tools/specs/unitframes_primary_v3_simulation_v1.json"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=Path, default=DEFAULT_SPEC)
    return parser.parse_args()


def color(value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    raw = value.lstrip("#")
    return tuple(int(raw[index:index + 2], 16) for index in (0, 2, 4)) + (alpha,)


def get_font(path: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(ROOT / path), size)


def multiply_tint(
    base: tuple[int, int, int],
    tint: tuple[int, int, int, int],
    strength: float,
) -> tuple[int, int, int, int]:
    channels = []
    for source, semantic in zip(base, tint[:3]):
        neutral = int(source * (1.0 - strength))
        coloured = int(source * semantic / 255 * strength)
        channels.append(max(0, min(255, neutral + coloured)))
    return channels[0], channels[1], channels[2], 255


def paint_fill(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    tint: tuple[int, int, int, int],
    scale: int,
    dense: bool,
) -> None:
    x0, y0, x1, y1 = box
    base = (205, 201, 188) if not dense else (194, 191, 181)
    draw.rectangle(box, fill=multiply_tint(base, tint, 0.78))
    height = max(1, y1 - y0)
    strokes = (
        (0.18, (229, 224, 205), 68),
        (0.48, (158, 153, 142), 58),
        (0.73, (219, 213, 194), 48),
    )
    for ratio, grey, alpha in strokes:
        y = y0 + min(height - 1, max(0, int(height * ratio)))
        shaded = multiply_tint(grey, tint, 0.78)
        draw.line(
            (x0 + 2 * scale, y, x1 - 3 * scale, y),
            fill=shaded[:3] + (alpha,),
            width=max(1, scale),
        )
    if not dense and height >= 8 * scale:
        draw.line(
            (x0 + 19 * scale, y0 + 5 * scale, x0 + 43 * scale, y0 + 6 * scale),
            fill=multiply_tint((137, 133, 124), tint, 0.72),
            width=max(1, scale),
        )


def draw_shell(
    draw: ImageDraw.ImageDraw,
    live_x: int,
    live_y: int,
    content_width: int,
    hp_height: int,
    power_height: int,
    role: str,
    palette: dict[str, str],
    health_fraction: float,
    health_tint: tuple[int, int, int, int],
    power_fraction: float,
    power_tint: tuple[int, int, int, int],
    name: str,
    value: str,
    scale: int = 1,
    state: str = "normal",
) -> tuple[int, int, int, int]:
    margin_x = 7 * scale
    margin_y = 6 * scale
    gap = scale
    width = content_width * scale
    hp_h = hp_height * scale
    power_h = max(scale, power_height * scale)
    left = live_x - margin_x
    top = live_y - margin_y
    right = live_x + width + margin_x
    bottom = live_y + hp_h + gap + power_h + margin_y

    # One continuous, hand-cut shell silhouette. There are no separately mounted caps.
    outer = [
        (left + 3 * scale, top + 2 * scale),
        (left + 24 * scale, top),
        (left + 67 * scale, top + scale),
        (left + 114 * scale, top),
        (right - 53 * scale, top + scale),
        (right - 15 * scale, top + 3 * scale),
        (right, top + 7 * scale),
        (right - 2 * scale, bottom - 6 * scale),
        (right - 18 * scale, bottom - scale),
        (right - 72 * scale, bottom),
        (left + 91 * scale, bottom - scale),
        (left + 31 * scale, bottom),
        (left + 8 * scale, bottom - 2 * scale),
        (left, bottom - 8 * scale),
        (left + 2 * scale, top + 8 * scale),
    ]

    if state == "aggro":
        draw.line(
            [outer[13], outer[14], outer[0], outer[1]],
            fill=(139, 58, 35, 175),
            width=max(2, 2 * scale),
        )
        draw.line(
            [outer[5], outer[6], outer[7]],
            fill=(139, 58, 35, 150),
            width=max(2, 2 * scale),
        )

    draw.polygon(outer, fill=color(palette["leather_dark"]), outline=(17, 9, 5, 255))
    draw.line(outer[0:6], fill=color(palette["leather_worn"], 180), width=max(1, scale))
    draw.line(outer[8:13], fill=(57, 32, 18, 220), width=max(1, scale))

    # Soot-brown inset is quiet and subordinate to runtime bars.
    inset = [
        (live_x - scale, live_y),
        (live_x + width // 3, live_y - scale),
        (live_x + width + scale, live_y),
        (live_x + width, live_y + hp_h + gap + power_h + scale),
        (live_x + (width * 2) // 3, live_y + hp_h + gap + power_h),
        (live_x - scale, live_y + hp_h + gap + power_h + scale),
    ]
    draw.polygon(inset, fill=color(palette["liner"]), outline=color(palette["leather_mid"]))

    hp_width = max(0, int(width * health_fraction))
    power_width = max(0, int(width * power_fraction))
    paint_fill(
        draw,
        (live_x, live_y, live_x + hp_width, live_y + hp_h),
        health_tint,
        scale,
        dense=False,
    )
    power_y = live_y + hp_h + gap
    paint_fill(
        draw,
        (live_x, power_y, live_x + power_width, power_y + power_h),
        power_tint,
        scale,
        dense=True,
    )

    brass = color(palette["brass"])
    brass_dim = color(palette["brass_dim"])
    stitch = color(palette["stitch"])
    if role == "player":
        draw.polygon(
            [
                (left + scale, top + 8 * scale),
                (left + 5 * scale, top + 5 * scale),
                (left + 7 * scale, top + 16 * scale),
                (left + 3 * scale, top + 18 * scale),
            ],
            fill=brass,
        )
        draw.line((left + 7 * scale, top + 19 * scale, left + 11 * scale, top + 23 * scale), fill=stitch, width=max(1, 2 * scale))
        draw.line((left + 6 * scale, top + 25 * scale, left + 10 * scale, top + 29 * scale), fill=stitch, width=max(1, 2 * scale))
        draw.ellipse((right - 6 * scale, bottom - 10 * scale, right - 3 * scale, bottom - 7 * scale), fill=brass_dim)
    elif role == "target":
        draw.line((left + 2 * scale, top + 8 * scale, left + 6 * scale, top + 5 * scale), fill=color(palette["leather_worn"]), width=max(1, 2 * scale))
        draw.polygon(
            [
                (right - 7 * scale, top + 12 * scale),
                (right - 2 * scale, top + 14 * scale),
                (right - 3 * scale, top + 28 * scale),
                (right - 8 * scale, top + 25 * scale),
            ],
            fill=brass,
        )
        draw.line((right - 8 * scale, top + 21 * scale, right - 3 * scale, top + 19 * scale), fill=(92, 58, 31, 255), width=max(1, 2 * scale))
    elif role == "targettarget":
        draw.line((left + 2 * scale, top + 5 * scale, left + 6 * scale, top + 3 * scale), fill=brass_dim, width=max(1, scale))
        draw.line((right - 7 * scale, bottom - 3 * scale, right - 2 * scale, bottom - 6 * scale), fill=brass_dim, width=max(1, scale))
    elif role == "focus":
        cloth = color(palette["focus_cloth"])
        draw.polygon(
            [
                (right - 24 * scale, top + 2 * scale),
                (right - 7 * scale, top - 5 * scale),
                (right - 2 * scale, top + scale),
                (right - 18 * scale, top + 7 * scale),
            ],
            fill=cloth,
            outline=(24, 29, 38, 255),
        )
        draw.ellipse((right - 11 * scale, top, right - 6 * scale, top + 5 * scale), fill=brass_dim)

    body_font = get_font("addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf", max(8, 11 * scale))
    draw.text((live_x + 5 * scale, live_y + hp_h // 2), name, font=body_font, fill=(235, 219, 180, 255), anchor="lm")
    draw.text((live_x + width - 5 * scale, live_y + hp_h // 2), value, font=body_font, fill=(239, 225, 188, 255), anchor="rm")
    return left, top, right, bottom


def draw_world_background(image: Image.Image) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle((0, 0, image.width, image.height), fill=(15, 18, 20, 255))
    for y in range(88, image.height - 150, 54):
        offset = 34 if (y // 54) % 2 else 0
        for x in range(-40 + offset, image.width, 104):
            draw.polygon(
                [(x, y + 5), (x + 93, y), (x + 97, y + 43), (x + 4, y + 48)],
                fill=(24, 27, 27, 255),
                outline=(37, 36, 32, 255),
            )
    draw.rectangle((0, image.height - 155, image.width, image.height), fill=(18, 15, 12, 255))


def draw_neighbours(draw: ImageDraw.ImageDraw, palette: dict[str, str]) -> None:
    # Current neighboring modules represented with deterministic geometry only.
    draw.polygon([(16, 686), (328, 675), (343, 888), (12, 893)], fill=color(palette["leather_dark"]), outline=color(palette["brass_dim"]))
    draw.polygon([(30, 705), (315, 697), (326, 865), (27, 873)], fill=(62, 48, 35, 255), outline=(112, 77, 40, 255))
    chat_font = get_font("addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf", 12)
    draw.text((46, 722), "[公会] 黑翼之巢 19:30 集合。", font=chat_font, fill=(90, 196, 96, 255))
    draw.text((46, 747), "[小队] 灵魂石和药剂已准备。", font=chat_font, fill=(158, 151, 230, 255))
    draw.text((46, 772), "[系统] 你获得了：远征补给。", font=chat_font, fill=(235, 203, 81, 255))

    x0, y0 = 480, 830
    for index in range(12):
        x = x0 + index * 43
        draw.rectangle((x, y0, x + 38, y0 + 38), fill=(45, 36, 26, 255), outline=color(palette["brass_dim"]), width=2)
        draw.rectangle((x + 5, y0 + 5, x + 33, y0 + 33), fill=((48 + index * 13) % 125, 49, 73, 255))
    draw.polygon([(430, 868), (461, 831), (474, 850), (461, 887)], fill=(96, 72, 38, 255), outline=color(palette["brass"]))
    draw.polygon([(1008, 850), (1022, 831), (1053, 868), (1022, 887)], fill=(96, 72, 38, 255), outline=color(palette["brass"]))


def render_scene(spec: dict) -> Image.Image:
    canvas = spec["canvas"]
    image = Image.new("RGBA", (canvas["width"], canvas["height"]), (0, 0, 0, 255))
    draw_world_background(image)
    draw = ImageDraw.Draw(image, "RGBA")
    palette = spec["palette"]
    draw_neighbours(draw, palette)

    title = get_font("addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf", 24)
    note = get_font("addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf", 13)
    draw.text((38, 30), "UF-PRIMARY-V3-SIM-V1 · 完整外壳与资源条预演", font=title, fill=(214, 184, 120, 255))
    draw.text((40, 67), "真实 Frame／动态区／状态色；笔触、微纹理、Alpha 与屏幕位置非权威。ImageGen 0/0。", font=note, fill=(173, 164, 146, 255))

    placements = spec["placements"]
    health_friendly = color(palette["health_friendly"])
    health_hostile = color(palette["health_hostile"])
    power = {item["id"]: color(item["color"]) for item in spec["power_types"]}
    draw_shell(draw, *placements["player_live_origin"], 200, 25, 4, "player", palette, 0.82, health_friendly, 0.68, power["mana"], "纳斯雷兹姆 60", "5234 / 5234")
    draw_shell(draw, *placements["target_live_origin"], 200, 25, 4, "target", palette, 0.74, health_hostile, 0.61, power["rage"], "黑石勇士 60+", "74%", state="aggro")
    draw_shell(draw, *placements["targettarget_live_origin"], 100, 20, 1, "targettarget", palette, 0.91, health_friendly, 0.57, power["mana"], "治疗者", "91%")
    draw_shell(draw, *placements["focus_live_origin"], 100, 25, 1, "focus", palette, 0.63, (121, 72, 44, 255), 0.44, power["focus"], "控场目标", "63%")

    for index, icon_color in enumerate(((88, 86, 155, 255), (144, 76, 61, 255), (57, 107, 134, 255), (116, 91, 44, 255))):
        draw.rectangle((885 + index * 24, 748, 905 + index * 24, 768), fill=icon_color, outline=(123, 91, 48, 255))
    draw.text((1227, 839), "Chat／动作条与紧凑框为邻接占位", font=note, fill=(142, 131, 114, 255))
    return image


def render_review(spec: dict) -> Image.Image:
    image = Image.new("RGBA", (1500, 920), (21, 20, 18, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    palette = spec["palette"]
    title = get_font("addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf", 26)
    note = get_font("addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf", 14)
    label = get_font("addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf", 16)
    draw.text((34, 24), "完整外壳、粗犷轮廓与资源材质审阅板", font=title, fill=(216, 184, 119, 255))
    draw.text((35, 62), "外壳按 3× 放大；资源类型只改变 pfUI 乘色，Health／Power 灰阶母材彼此独立。", font=note, fill=(169, 157, 138, 255))

    health_friendly = color(palette["health_friendly"])
    health_hostile = color(palette["health_hostile"])
    power = {item["id"]: color(item["color"]) for item in spec["power_types"]}

    draw_shell(draw, 84, 135, 200, 25, 4, "player", palette, 0.82, health_friendly, 0.68, power["mana"], "玩家 · 法力", "82%", scale=3)
    draw_shell(draw, 820, 135, 200, 25, 4, "target", palette, 0.74, health_hostile, 0.61, power["rage"], "目标 · 怒气", "74%", scale=3, state="aggro")
    draw.text((65, 304), "Player：旧马鞍带式完整外壳；左端野外修补较重", font=note, fill=(191, 169, 129, 255))
    draw.text((801, 304), "Target：同族但从零绘制；右端破损压片较重", font=note, fill=(191, 169, 129, 255))

    draw.text((48, 365), "Power 支持模式（2×，几何相同）", font=label, fill=(209, 179, 119, 255))
    y = 420
    for index, item in enumerate(spec["power_types"]):
        row_y = y + index * 105
        draw_shell(draw, 80, row_y, 200, 25, 4, "player", palette, 0.67, health_friendly, 0.76 - index * 0.08, power[item["id"]], f"玩家 · {item['id'].upper()}", f"{67 - index * 6}%", scale=2)
        draw.text((540, row_y + 21), f"UnitPowerType={item['unit_power_type']} · 同一 Power 灰阶材质，仅运行时乘色", font=note, fill=(171, 160, 140, 255), anchor="lm")

    # Material donors are isolated here for role review only; they are not source pixels.
    draw.text((970, 405), "无色母材角色（非生产像素）", font=label, fill=(209, 179, 119, 255))
    draw.rectangle((980, 455, 1350, 575), fill=(33, 29, 25, 255), outline=(92, 68, 38, 255), width=2)
    paint_fill(draw, (1000, 475, 1320, 555), (255, 255, 255, 255), 2, dense=False)
    draw.text((980, 586), "Health：较粗的矿物颜料刷痕", font=note, fill=(184, 170, 143, 255))
    draw.rectangle((980, 640, 1350, 720), fill=(33, 29, 25, 255), outline=(92, 68, 38, 255), width=2)
    paint_fill(draw, (1000, 660, 1320, 700), (255, 255, 255, 255), 2, dense=True)
    draw.text((980, 731), "Power：更窄、更密、更安静", font=note, fill=(184, 170, 143, 255))
    draw.text((970, 802), "生产时二者仍是独立逻辑资产；不会把颜色、文字或数值烘焙进去。", font=note, fill=(153, 143, 126, 255))
    return image


def main() -> None:
    args = parse_args()
    spec = json.loads(args.spec.resolve().read_text(encoding="utf-8"))
    outputs = (("scene", render_scene(spec)), ("review", render_review(spec)))
    for role, image in outputs:
        output = ROOT / spec["outputs"][role]
        output.parent.mkdir(parents=True, exist_ok=True)
        image.save(output, format="PNG", optimize=False, compress_level=9)
        print(output.resolve())


if __name__ == "__main__":
    main()
