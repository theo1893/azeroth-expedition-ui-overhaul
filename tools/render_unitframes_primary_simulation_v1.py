#!/usr/bin/env python3
"""Render the deterministic, non-production primary unit-frame direction preview."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SPEC = ROOT / "tools/specs/unitframes_primary_simulation_v1.json"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=Path, default=DEFAULT_SPEC)
    return parser.parse_args()


def font(path: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(ROOT / path), size)


def rgba(hex_color: str, alpha: int = 255) -> tuple[int, int, int, int]:
    value = hex_color.lstrip("#")
    return tuple(int(value[index:index + 2], 16) for index in (0, 2, 4)) + (alpha,)


def rough_shell(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    hpw: int,
    hph: int,
    powerh: int,
    role: str,
    palette: dict[str, str],
    name: str,
    right_text: str,
    health: float,
    health_color: tuple[int, int, int, int],
    power_color: tuple[int, int, int, int],
    scale: int = 1,
    state: str = "normal",
) -> None:
    margin_x, margin_y = 7 * scale, 6 * scale
    hpw, hph, powerh = hpw * scale, hph * scale, max(powerh * scale, scale)
    gap = scale
    total_h = hph + gap + powerh
    left, top = x - margin_x, y - margin_y
    right, bottom = x + hpw + margin_x, y + total_h + margin_y

    # Low-frequency uneven silhouette: deliberately not a rounded rectangle.
    points = [
        (left + 4 * scale, top + 2 * scale),
        (left + 19 * scale, top),
        (x + hpw // 3, top + scale),
        (x + (hpw * 2) // 3, top),
        (right - 13 * scale, top + 2 * scale),
        (right, top + 6 * scale),
        (right - 2 * scale, bottom - 5 * scale),
        (right - 16 * scale, bottom),
        (x + hpw // 2, bottom - scale),
        (left + 12 * scale, bottom),
        (left, bottom - 7 * scale),
        (left + 2 * scale, top + 7 * scale),
    ]

    if state == "aggro":
        glow = [(px - 2 * scale if px < x + hpw / 2 else px + 2 * scale,
                 py - 2 * scale if py < y + total_h / 2 else py + 2 * scale)
                for px, py in points]
        draw.line([glow[10], glow[11], glow[0], glow[1]], fill=(130, 45, 25, 185), width=3 * scale, joint="curve")
        draw.line([glow[4], glow[5], glow[6]], fill=(130, 45, 25, 185), width=3 * scale, joint="curve")
        draw.line([glow[7], glow[8]], fill=(112, 39, 24, 145), width=2 * scale, joint="curve")
    elif state == "hover":
        draw.line(points[:2], fill=(205, 160, 90, 145), width=2 * scale, joint="curve")
        draw.line(points[3:5], fill=(205, 160, 90, 120), width=2 * scale, joint="curve")

    draw.polygon(points, fill=rgba(palette["leather"]), outline=(19, 10, 6, 255))
    inner = [
        (left + 6 * scale, top + 5 * scale),
        (right - 7 * scale, top + 5 * scale),
        (right - 6 * scale, bottom - 6 * scale),
        (left + 7 * scale, bottom - 5 * scale),
    ]
    draw.polygon(inner, fill=rgba(palette["leather_mid"]), outline=rgba(palette["brass_dim"]))
    draw.rectangle((x, y, x + hpw, y + hph), fill=(24, 17, 12, 255))
    draw.rectangle((x + scale, y + scale, x + int((hpw - 2 * scale) * health), y + hph - scale), fill=health_color)
    draw.line((x + 2 * scale, y + 2 * scale, x + hpw - 2 * scale, y + 2 * scale), fill=(210, 190, 125, 55), width=scale)
    py = y + hph + gap
    draw.rectangle((x, py, x + hpw, py + powerh), fill=(18, 14, 12, 255))
    draw.rectangle((x + scale, py, x + hpw - scale, py + powerh), fill=power_color)

    brass = rgba(palette["brass"])
    brass_dim = rgba(palette["brass_dim"])
    if role == "player":
        draw.line((left + 2 * scale, top + 5 * scale, x - 2 * scale, top + 2 * scale, x - scale, bottom - 4 * scale), fill=brass, width=3 * scale)
        draw.line((x - 6 * scale, top + 5 * scale, x - 3 * scale, top + 10 * scale), fill=(142, 103, 58, 255), width=2 * scale)
        draw.line((x - 4 * scale, top + 4 * scale, x - scale, top + 9 * scale), fill=(142, 103, 58, 255), width=2 * scale)
        draw.ellipse((x + hpw + 2 * scale, bottom - 11 * scale, x + hpw + 6 * scale, bottom - 7 * scale), fill=brass_dim)
    elif role == "target":
        draw.line((x + hpw + scale, top + 3 * scale, right - 2 * scale, top + 5 * scale, right - scale, bottom - 7 * scale), fill=brass, width=3 * scale)
        draw.line((x + hpw + 2 * scale, top + 14 * scale, right - scale, top + 18 * scale), fill=(121, 83, 43, 255), width=2 * scale)
        draw.ellipse((left + scale, top + 7 * scale, x - 2 * scale, top + 12 * scale), fill=brass_dim)
    elif role == "targettarget":
        draw.line((left + 2 * scale, top + 5 * scale, x - scale, top + 3 * scale), fill=brass_dim, width=2 * scale)
        draw.line((x + hpw + scale, bottom - 4 * scale, right - 2 * scale, bottom - 7 * scale), fill=brass_dim, width=2 * scale)
    elif role == "focus":
        draw.line((left + 2 * scale, top + 4 * scale, x - scale, top + 2 * scale), fill=brass_dim, width=2 * scale)
        cloth = rgba(palette["focus_cloth"])
        draw.polygon([
            (x + hpw - 18 * scale, top - scale),
            (right - 3 * scale, top - 6 * scale),
            (right - scale, top + 2 * scale),
            (x + hpw - 14 * scale, top + 4 * scale),
        ], fill=cloth, outline=(28, 34, 43, 255))
        draw.polygon([
            (x + hpw - 14 * scale, top + scale),
            (right - 2 * scale, top),
            (right - 7 * scale, top + 6 * scale),
            (x + hpw - 11 * scale, top + 4 * scale),
        ], fill=rgba(palette["focus_cloth"], 220), outline=(28, 34, 43, 255))
        draw.ellipse((x + hpw + scale, top - scale, x + hpw + 5 * scale, top + 3 * scale), fill=brass_dim)

    # Uneven repair scratches remain outside the quiet text corridor.
    draw.line((left + 31 * scale, bottom - 5 * scale, left + 38 * scale, bottom - 3 * scale), fill=(105, 70, 43, 180), width=scale)
    draw.line((right - 40 * scale, top + 3 * scale, right - 34 * scale, top + 2 * scale), fill=(105, 70, 43, 160), width=scale)

    body_font = font("addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf", 11 * scale)
    draw.text((x + 5 * scale, y + hph // 2), name, font=body_font, fill=(234, 215, 169, 255), anchor="lm")
    draw.text((x + hpw - 5 * scale, y + hph // 2), right_text, font=body_font, fill=(241, 225, 185, 255), anchor="rm")


def background(image: Image.Image) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle((0, 0, image.width, image.height), fill=(15, 18, 20, 255))
    for y in range(80, image.height - 120, 54):
        offset = 18 if (y // 54) % 2 else 0
        for x in range(-20 + offset, image.width, 96):
            draw.rectangle((x, y, x + 88, y + 47), fill=(25, 28, 29, 255), outline=(36, 36, 33, 255), width=2)
    draw.rectangle((0, image.height - 155, image.width, image.height), fill=(18, 15, 12, 255))


def neighbours(draw: ImageDraw.ImageDraw, palette: dict[str, str]) -> None:
    # Simplified current-UI neighbours: intentionally not copied from accepted pixels.
    draw.polygon([(18, 685), (328, 674), (344, 887), (12, 892)], fill=rgba(palette["leather"]), outline=rgba(palette["brass_dim"]))
    draw.polygon([(31, 704), (314, 696), (325, 865), (28, 872)], fill=(62, 48, 35, 255), outline=(112, 77, 40, 255))
    small = font("addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf", 12)
    draw.text((47, 722), "[公会] 今晚黑翼之巢 19:30 集合", font=small, fill=(90, 196, 96, 255))
    draw.text((47, 747), "[小队] 消耗品与灵魂石已准备。", font=small, fill=(158, 151, 230, 255))
    draw.text((47, 772), "[系统] 你获得了：远征补给。", font=small, fill=(235, 203, 81, 255))

    # Classic double-gryphon action-bar rhythm, deliberately geometric.
    x0, y0 = 480, 830
    for index in range(12):
        x = x0 + index * 43
        draw.rectangle((x, y0, x + 38, y0 + 38), fill=(45, 36, 26, 255), outline=rgba(palette["brass_dim"]), width=2)
        draw.rectangle((x + 5, y0 + 5, x + 33, y0 + 33), fill=((45 + index * 11) % 120, 48, 73, 255))
    draw.polygon([(430, 868), (461, 831), (474, 850), (461, 887)], fill=(96, 72, 38, 255), outline=rgba(palette["brass"]))
    draw.polygon([(1008, 850), (1022, 831), (1053, 868), (1022, 887)], fill=(96, 72, 38, 255), outline=rgba(palette["brass"]))


def scene(spec: dict) -> Image.Image:
    canvas = spec["canvas"]
    image = Image.new("RGBA", (canvas["width"], canvas["height"]), (0, 0, 0, 255))
    background(image)
    draw = ImageDraw.Draw(image, "RGBA")
    palette = spec["palette"]
    neighbours(draw, palette)
    title = font("addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf", 24)
    note = font("addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf", 13)
    draw.text((38, 30), "UF-PRIMARY-SIM-V1 · 行军身份牌方向预演", font=title, fill=(214, 184, 120, 255))
    draw.text((40, 67), "资源尺寸与信息密度为权威；屏幕位置、笔触、纹理与远端布局为非权威。ImageGen 0/0。", font=note, fill=(173, 164, 146, 255))

    p = spec["placements"]
    rough_shell(draw, *p["player"], 200, 25, 4, "player", palette, "纳斯雷兹姆 60", "5234 / 5234", 0.82, (74, 121, 58, 255), (45, 88, 150, 255))
    rough_shell(draw, *p["target"], 200, 25, 4, "target", palette, "黑石勇士 60+", "74%", 0.74, (132, 48, 41, 255), (84, 48, 112, 255), state="aggro")
    rough_shell(draw, *p["targettarget"], 100, 20, 1, "targettarget", palette, "治疗者", "91%", 0.91, (63, 111, 57, 255), (43, 72, 119, 255))
    rough_shell(draw, *p["focus"], 100, 25, 1, "focus", palette, "控场目标", "63%", 0.63, (121, 72, 44, 255), (48, 79, 124, 255), state="hover")

    # Unchanged runtime aura examples.
    for i, color in enumerate(((88, 86, 155, 255), (144, 76, 61, 255), (57, 107, 134, 255), (116, 91, 44, 255))):
        draw.rectangle((885 + i * 24, 748, 905 + i * 24, 768), fill=color, outline=(123, 91, 48, 255))
    draw.text((1250, 840), "邻接 Chat／动作条仅为几何占位", font=note, fill=(142, 131, 114, 255))
    return image


def zoom(spec: dict) -> Image.Image:
    image = Image.new("RGBA", (1200, 620), (21, 20, 18, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    palette = spec["palette"]
    title = font("addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf", 26)
    note = font("addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf", 14)
    draw.text((34, 24), "2×审阅放大：粗厚轮廓、非镜像端帽与 Focus 猎踪布结", font=title, fill=(216, 184, 119, 255))
    draw.text((35, 61), "放大图只帮助审视材料层级与不工整节奏；运行时仍按 214×42／112×34／112×39。", font=note, fill=(169, 157, 138, 255))
    rough_shell(draw, 92, 125, 200, 25, 4, "player", palette, "纳斯雷兹姆 60", "5234 / 5234", 0.82, (74, 121, 58, 255), (45, 88, 150, 255), scale=2)
    rough_shell(draw, 700, 125, 200, 25, 4, "target", palette, "黑石勇士 60+", "74%", 0.74, (132, 48, 41, 255), (84, 48, 112, 255), scale=2, state="aggro")
    rough_shell(draw, 188, 372, 100, 20, 1, "targettarget", palette, "治疗者", "91%", 0.91, (63, 111, 57, 255), (43, 72, 119, 255), scale=2)
    rough_shell(draw, 712, 360, 100, 25, 1, "focus", palette, "控场目标", "63%", 0.63, (121, 72, 44, 255), (48, 79, 124, 255), scale=2, state="hover")
    draw.text((95, 260), "玩家：左端修补更重", font=note, fill=(190, 169, 129, 255))
    draw.text((703, 260), "目标：右端破损夹片／仇恨短边", font=note, fill=(190, 169, 129, 255))
    draw.text((190, 486), "目标的目标：减法处理", font=note, fill=(190, 169, 129, 255))
    draw.text((714, 486), "焦点：被皮革压住的褪色靛蓝布结", font=note, fill=(190, 169, 129, 255))
    return image


def main() -> None:
    args = parse_args()
    spec = json.loads(args.spec.resolve().read_text(encoding="utf-8"))
    for role, image in (("scene", scene(spec)), ("zoom", zoom(spec))):
        output = ROOT / spec["outputs"][role]
        output.parent.mkdir(parents=True, exist_ok=True)
        image.save(output, format="PNG", optimize=False, compress_level=9)
        print(output.resolve())


if __name__ == "__main__":
    main()
