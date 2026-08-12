#!/usr/bin/env python3
"""Render the local, non-production UF-PRIMARY-V4 architecture preview.

The shell pixels in this renderer are deliberately simple geometric placeholders.
The accepted Health and Power runtime textures are used for realistic information
density, but no locked reference or accepted Unit Frames material sample is copied.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFont


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SPEC = ROOT / "tools/specs/unitframes_primary_v4_simulation_v1.json"
FONT_SANS = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"
FONT_SERIF = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=Path, default=DEFAULT_SPEC)
    return parser.parse_args()


def rgba(value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    raw = value.lstrip("#")
    return tuple(int(raw[index:index + 2], 16) for index in (0, 2, 4)) + (alpha,)


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size)


def _statusbar_texture(path: str, size: tuple[int, int], tint: tuple[int, int, int, int]) -> Image.Image:
    texture = Image.open(ROOT / path).convert("RGBA").resize(size, Image.Resampling.LANCZOS)
    rgb = texture.convert("RGB")
    tint_layer = Image.new("RGB", size, tint[:3])
    tinted = ImageChops.multiply(rgb, tint_layer)
    # Match the restrained, readable in-game value of the accepted bar assets.
    tinted = ImageEnhance.Brightness(tinted).enhance(1.34)
    result = tinted.convert("RGBA")
    result.putalpha(texture.getchannel("A"))
    return result


def _paste_bar(
    image: Image.Image,
    path: str,
    box: tuple[int, int, int, int],
    tint: tuple[int, int, int, int],
    fraction: float,
) -> None:
    x0, y0, x1, y1 = box
    width = max(1, x1 - x0)
    height = max(1, y1 - y0)
    full = _statusbar_texture(path, (width, height), tint)
    visible = max(1, min(width, round(width * fraction)))
    crop = full.crop((0, 0, visible, height))
    image.alpha_composite(crop, (x0, y0))


def _map_points(points: list[tuple[int, int]], left: int, top: int, scale: int) -> list[tuple[int, int]]:
    return [(left + x * scale, top + y * scale) for x, y in points]


def draw_complete_shell(
    image: Image.Image,
    left: int,
    top: int,
    content_width: int,
    role: str,
    palette: dict[str, str],
    bar_paths: dict[str, str],
    health_fraction: float,
    health_tint: tuple[int, int, int, int],
    power_fraction: float,
    power_tint: tuple[int, int, int, int],
    name: str,
    value: str,
    *,
    scale: int = 1,
    state: str = "normal",
    show_text: bool = True,
) -> tuple[int, int, int, int]:
    runtime_width = content_width + 14
    runtime_height = 42
    right = left + runtime_width * scale
    bottom = top + runtime_height * scale
    draw = ImageDraw.Draw(image, "RGBA")

    # Slow, non-periodic deviations: exact geometry, but not an industrial card.
    outer = [
        (0, 6), (3, 2), (16, 0), (31, 2), (55, 1),
        (runtime_width // 2 - 18, 2), (runtime_width // 2 + 27, 1),
        (runtime_width - 38, 2), (runtime_width - 14, 1),
        (runtime_width - 3, 4), (runtime_width, 9),
        (runtime_width - 1, 22), (runtime_width, 34),
        (runtime_width - 5, 40), (runtime_width - 22, 42),
        (runtime_width - 49, 40), (runtime_width // 2 + 34, 41),
        (runtime_width // 2 - 23, 40), (52, 42), (21, 40),
        (5, 41), (1, 36), (2, 25), (0, 14),
    ]
    outer_abs = _map_points(outer, left, top, scale)

    if state == "aggro":
        draw.line(
            _map_points([(0, 27), (1, 35), (5, 40), (22, 42)], left, top, scale),
            fill=(144, 55, 32, 205), width=max(2, 2 * scale),
        )
        draw.line(
            _map_points([(runtime_width - 29, 2), (runtime_width - 8, 2), (runtime_width, 9)], left, top, scale),
            fill=(144, 55, 32, 190), width=max(2, 2 * scale),
        )
    elif state == "hover":
        draw.line(
            _map_points([(19, 0), (31, 2), (49, 1)], left, top, scale),
            fill=(232, 213, 170, 150), width=max(1, scale),
        )
        draw.line(
            _map_points([(runtime_width - 20, 40), (runtime_width - 7, 39)], left, top, scale),
            fill=(232, 213, 170, 135), width=max(1, scale),
        )

    draw.polygon(outer_abs, fill=rgba(palette["leather_dark"]), outline=(16, 8, 5, 255))

    # Quiet liner may live under the bars; relief and repairs never cover this bed.
    live = (left + 7 * scale, top + 6 * scale, right - 7 * scale, top + 36 * scale)
    draw.rectangle(live, fill=rgba(palette["liner"]), outline=rgba(palette["leather_mid"]))

    # Broken highlights make the exact mask feel cut and repaired rather than extruded.
    draw.line(_map_points([(5, 4), (22, 1), (39, 2)], left, top, scale), fill=rgba(palette["leather_worn"], 190), width=max(1, scale))
    draw.line(_map_points([(58, 2), (91, 2)], left, top, scale), fill=rgba(palette["leather_worn"], 125), width=max(1, scale))
    draw.line(_map_points([(runtime_width - 72, 2), (runtime_width - 42, 2)], left, top, scale), fill=rgba(palette["leather_worn"], 120), width=max(1, scale))
    draw.line(_map_points([(13, 40), (37, 41)], left, top, scale), fill=(55, 30, 18, 230), width=max(1, scale))
    draw.line(_map_points([(runtime_width - 83, 40), (runtime_width - 48, 41)], left, top, scale), fill=(55, 30, 18, 220), width=max(1, scale))

    brass = rgba(palette["brass"])
    brass_dim = rgba(palette["brass_dim"])
    stitch = rgba(palette["stitch"])
    if role == "player":
        draw.polygon(
            _map_points([(7, 1), (27, 1), (30, 5), (24, 6), (8, 5), (4, 3)], left, top, scale),
            fill=brass, outline=(62, 43, 23, 255),
        )
        draw.line(_map_points([(3, 11), (6, 15), (3, 19)], left, top, scale), fill=stitch, width=max(1, 2 * scale))
        draw.line(_map_points([(4, 23), (7, 27), (3, 31)], left, top, scale), fill=stitch, width=max(1, 2 * scale))
        draw.ellipse((right - 7 * scale, top + 34 * scale, right - 3 * scale, top + 38 * scale), fill=brass_dim)
    elif role == "target":
        draw.line(_map_points([(2, 8), (11, 3), (24, 2)], left, top, scale), fill=rgba(palette["leather_worn"]), width=max(1, 2 * scale))
        draw.polygon(
            _map_points(
                [(runtime_width - 31, 36), (runtime_width - 17, 35), (runtime_width - 4, 31),
                 (runtime_width - 1, 37), (runtime_width - 8, 41), (runtime_width - 27, 41)],
                left, top, scale,
            ),
            fill=brass, outline=(63, 43, 22, 255),
        )
        draw.line(
            _map_points([(runtime_width - 22, 36), (runtime_width - 17, 40), (runtime_width - 12, 36)], left, top, scale),
            fill=(64, 38, 23, 255), width=max(1, scale),
        )

    # The provider bars and live text are above the complete-shell BACKGROUND layer.
    hp_box = (left + 7 * scale, top + 6 * scale, right - 7 * scale, top + 31 * scale)
    power_box = (left + 7 * scale, top + 32 * scale, right - 7 * scale, top + 36 * scale)
    draw.rectangle(hp_box, fill=(31, 25, 20, 255))
    draw.rectangle(power_box, fill=(25, 22, 19, 255))
    _paste_bar(image, bar_paths["health"], hp_box, health_tint, health_fraction)
    _paste_bar(image, bar_paths["power"], power_box, power_tint, power_fraction)

    if show_text:
        body_font = font(FONT_SANS, max(9, 11 * scale))
        draw = ImageDraw.Draw(image, "RGBA")
        draw.text((left + 12 * scale, top + 18 * scale), name, font=body_font, fill=(235, 219, 180, 255), anchor="lm")
        draw.text((right - 12 * scale, top + 18 * scale), value, font=body_font, fill=(239, 225, 188, 255), anchor="rm")
    return left, top, right, bottom


def draw_world_background(image: Image.Image) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle((0, 0, image.width, image.height), fill=(14, 17, 18, 255))
    for y in range(95, image.height - 145, 55):
        offset = 42 if (y // 55) % 2 else 0
        for x in range(-50 + offset, image.width, 118):
            draw.polygon(
                [(x, y + 5), (x + 106, y), (x + 111, y + 44), (x + 3, y + 49)],
                fill=(23, 26, 26, 255), outline=(38, 36, 31, 255),
            )
    draw.rectangle((0, image.height - 145, image.width, image.height), fill=(17, 14, 12, 255))
    draw.ellipse((575, 155, 1055, 615), outline=(46, 40, 31, 125), width=6)
    draw.ellipse((665, 245, 965, 540), outline=(35, 29, 24, 120), width=3)


def draw_neighbours(draw: ImageDraw.ImageDraw, palette: dict[str, str]) -> None:
    # Deterministic geometry only: accepted neighbouring modules are not copied.
    draw.polygon([(17, 684), (329, 675), (342, 888), (12, 892)], fill=rgba(palette["leather_dark"]), outline=rgba(palette["brass_dim"]))
    draw.polygon([(31, 704), (315, 697), (326, 865), (27, 873)], fill=(60, 47, 34, 255), outline=(111, 76, 40, 255))
    chat_font = font(FONT_SANS, 12)
    draw.text((45, 722), "[公会] 黑翼之巢 19:30 集合。", font=chat_font, fill=(90, 196, 96, 255))
    draw.text((45, 748), "[小队] 合剂、灵魂石已准备。", font=chat_font, fill=(158, 151, 230, 255))
    draw.text((45, 774), "[系统] 你获得了：远征补给。", font=chat_font, fill=(235, 203, 81, 255))
    x0, y0 = 483, 830
    for index in range(12):
        x = x0 + index * 43
        draw.rectangle((x, y0, x + 38, y0 + 38), fill=(43, 34, 25, 255), outline=rgba(palette["brass_dim"]), width=2)
        draw.rectangle((x + 5, y0 + 5, x + 33, y0 + 33), fill=((47 + index * 13) % 125, 48, 70, 255))
    draw.polygon([(432, 869), (461, 831), (475, 850), (461, 887)], fill=(96, 72, 38, 255), outline=rgba(palette["brass"]))
    draw.polygon([(1009, 850), (1022, 831), (1054, 869), (1022, 887)], fill=(96, 72, 38, 255), outline=rgba(palette["brass"]))


def render_scene(spec: dict) -> Image.Image:
    canvas = spec["canvas"]
    image = Image.new("RGBA", (canvas["width"], canvas["height"]), (0, 0, 0, 255))
    draw_world_background(image)
    draw = ImageDraw.Draw(image, "RGBA")
    palette = spec["palette"]
    draw_neighbours(draw, palette)

    title = font(FONT_SERIF, 24)
    note = font(FONT_SANS, 13)
    draw.text((38, 29), "UF-PRIMARY-V4-SIM-V1 · 完整外壳新生产架构", font=title, fill=(214, 184, 120, 255))
    draw.text((40, 66), "真实 214×42 排版；壳体仅为几何占位，Health／Power 使用已验收运行时纹理。ImageGen 0/0。", font=note, fill=(173, 164, 146, 255))

    bars = {
        "health": spec["runtime"]["health_texture"]["file"],
        "power": spec["runtime"]["power_texture"]["file"],
    }
    power = {item["id"]: rgba(item["color"]) for item in spec["power_types"]}

    draw_complete_shell(
        image, 520, 707, 200, "player", palette, bars,
        0.82, rgba(palette["health_friendly"]), 0.68, power["mana"],
        "纳斯雷兹姆 60", "5234 / 5234",
    )
    draw_complete_shell(
        image, 880, 707, 200, "target", palette, bars,
        0.74, rgba(palette["health_hostile"]), 0.61, power["rage"],
        "黑石勇士 60+", "74%", state="aggro",
    )
    for index, icon_color in enumerate(((88, 86, 155, 255), (144, 76, 61, 255), (57, 107, 134, 255), (116, 91, 44, 255))):
        x = 885 + index * 24
        draw.rectangle((x, 754, x + 20, 774), fill=icon_color, outline=(123, 91, 48, 255))

    # Enlarged architecture inset stays separate from the real 1:1 scene.
    draw.rounded_rectangle((1088, 110, 1565, 443), radius=8, fill=(19, 18, 16, 235), outline=(93, 70, 42, 255), width=2)
    draw.text((1114, 132), "2× 局部检查 · 非生产像素", font=font(FONT_SERIF, 18), fill=(209, 180, 119, 255))
    draw_complete_shell(
        image, 1134, 190, 200, "player", palette, bars,
        0.88, rgba(palette["health_friendly"]), 0.70, power["mana"],
        "Player", "88%", scale=2,
    )
    draw.text((1114, 336), "上／下缘只占 6px；动态内容 200×30 不被覆盖", font=note, fill=(169, 158, 139, 255))
    draw.text((1114, 363), "Player 左上维修沿顶缘展开，不再挤进生命条", font=note, fill=(169, 158, 139, 255))
    draw.text((1114, 390), "Target 的识别件改到右下缘，双方不镜像", font=note, fill=(169, 158, 139, 255))
    draw.text((1218, 839), "Chat／动作条为几何邻接占位", font=note, fill=(142, 131, 114, 255))
    return image


def _arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color_value: tuple[int, int, int, int]) -> None:
    draw.line((start, end), fill=color_value, width=3)
    x, y = end
    draw.polygon([(x, y), (x - 10, y - 6), (x - 10, y + 6)], fill=color_value)


def render_review(spec: dict) -> Image.Image:
    image = Image.new("RGBA", (1600, 1050), (21, 20, 18, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    palette = spec["palette"]
    title = font(FONT_SERIF, 26)
    section = font(FONT_SERIF, 18)
    note = font(FONT_SANS, 14)
    small = font(FONT_SANS, 12)
    bars = {
        "health": spec["runtime"]["health_texture"]["file"],
        "power": spec["runtime"]["power_texture"]["file"],
    }
    power = {item["id"]: rgba(item["color"]) for item in spec["power_types"]}

    draw.text((34, 24), "Player／Target 完整外壳 · V4 架构审阅板", font=title, fill=(216, 184, 119, 255))
    draw.text((35, 63), "模型不再负责 UI 几何；几何占位只验证轮廓、维修位置、真实排版和缩放。ImageGen 0/0。", font=note, fill=(169, 157, 138, 255))

    draw.text((42, 112), "A. 真实信息密度与非镜像身份（3×）", font=section, fill=(209, 179, 119, 255))
    draw_complete_shell(
        image, 73, 164, 200, "player", palette, bars,
        0.82, rgba(palette["health_friendly"]), 0.68, power["mana"],
        "玩家 · 法力", "82%", scale=3, state="hover",
    )
    draw_complete_shell(
        image, 824, 164, 200, "target", palette, bars,
        0.74, rgba(palette["health_hostile"]), 0.61, power["rage"],
        "目标 · 怒气", "74%", scale=3, state="aggro",
    )
    draw.text((73, 311), "Player：左上短夹片＋左侧粗缝；右下只有偏心暗钉", font=note, fill=(190, 169, 130, 255))
    draw.text((824, 311), "Target：左上磨亮折边；右下断裂暗铜压片承担识别", font=note, fill=(190, 169, 130, 255))

    draw.line((35, 359, 1565, 359), fill=(69, 57, 42, 255), width=1)
    draw.text((42, 382), "B. 新生产职责：复用已验收材料，Python 构造两张完整壳", font=section, fill=(209, 179, 119, 255))

    material_colors = [
        ("旧皮革", palette["leather_mid"]),
        ("烟褐内衬", palette["liner"]),
        ("氧化暗铜", palette["brass"]),
        ("粗麻修补线", palette["stitch"]),
    ]
    for index, (label, value) in enumerate(material_colors):
        x = 47 + index * 145
        draw.rounded_rectangle((x, 433, x + 118, 510), radius=5, fill=rgba(value), outline=(106, 80, 46, 255), width=2)
        draw.text((x + 59, 521), label, font=small, fill=(195, 179, 147, 255), anchor="ma")
    draw.text((50, 548), "输入：Raid A2 已接受 sample（预演不复制其像素）", font=small, fill=(143, 133, 118, 255))
    _arrow(draw, (633, 474), (721, 474), (139, 108, 59, 255))
    draw.rounded_rectangle((739, 421, 1057, 552), radius=7, fill=(42, 33, 24, 255), outline=(132, 98, 52, 255), width=2)
    draw.text((898, 446), "确定性完整外壳 builder", font=section, fill=(220, 191, 132, 255), anchor="ma")
    draw.text((760, 477), "• 固定 1284×252 Alpha／安全区", font=note, fill=(183, 171, 149, 255))
    draw.text((760, 503), "• 角色维修 mask／光照／透明清理", font=note, fill=(183, 171, 149, 255))
    draw.text((760, 529), "• 完整纹理＋32／150／32 三切片", font=note, fill=(183, 171, 149, 255))
    _arrow(draw, (1074, 474), (1151, 474), (139, 108, 59, 255))
    draw.rounded_rectangle((1171, 412, 1546, 560), radius=7, fill=(31, 27, 22, 255), outline=(132, 98, 52, 255), width=2)
    draw_complete_shell(image, 1197, 435, 120, "player", palette, bars, 0.8, rgba(palette["health_friendly"]), 0.65, power["mana"], "", "", show_text=False)
    draw_complete_shell(image, 1197, 493, 120, "target", palette, bars, 0.7, rgba(palette["health_hostile"]), 0.55, power["rage"], "", "", show_text=False)
    draw.text((1357, 462), "Player 完整 214×42", font=small, fill=(195, 179, 147, 255), anchor="lm")
    draw.text((1357, 520), "Target 完整 214×42", font=small, fill=(195, 179, 147, 255), anchor="lm")

    draw.line((35, 586, 1565, 586), fill=(69, 57, 42, 255), width=1)
    draw.text((42, 609), "C. 真实变宽与状态（1×）", font=section, fill=(209, 179, 119, 255))
    draw_complete_shell(image, 62, 658, 160, "player", palette, bars, 0.67, rgba(palette["health_friendly"]), 0.54, power["energy"], "W=160", "67%")
    draw.text((62, 713), "174×42 · 固定两端，中央伸缩", font=small, fill=(171, 159, 137, 255))
    draw_complete_shell(image, 392, 658, 240, "target", palette, bars, 0.78, rgba(palette["health_hostile"]), 0.63, power["rage"], "W=240", "78%", state="aggro")
    draw.text((392, 713), "254×42 · 右下身份不随中心拉伸", font=small, fill=(171, 159, 137, 255))
    draw_complete_shell(image, 794, 658, 200, "player", palette, bars, 0.85, rgba(palette["health_friendly"]), 0.75, power["focus"], "Hover", "85%", state="hover")
    draw.text((794, 713), "暖白只响应两段磨损边", font=small, fill=(171, 159, 137, 255))
    draw_complete_shell(image, 1129, 658, 200, "target", palette, bars, 0.62, rgba(palette["health_hostile"]), 0.42, power["rage"], "Aggro", "62%", state="aggro")
    draw.text((1129, 713), "暗红只响应断续外缘", font=small, fill=(171, 159, 137, 255))

    draw.line((35, 757, 1565, 757), fill=(69, 57, 42, 255), width=1)
    draw.text((42, 780), "D. UI Scale 预演（统一缩放，不纵向拉扯）", font=section, fill=(209, 179, 119, 255))
    scale_rows = [("75%", 160, 32), ("100%", 214, 42), ("125%", 268, 53), ("150%", 321, 63)]
    x = 52
    for label_text, width, height in scale_rows:
        draw.rounded_rectangle((x, 833, x + width + 20, 833 + height + 44), radius=4, fill=(28, 25, 21, 255), outline=(69, 55, 39, 255))
        # Scale a single complete simulated runtime; no independent axis scaling.
        temp = Image.new("RGBA", (214, 42), (0, 0, 0, 0))
        draw_complete_shell(temp, 0, 0, 200, "player", palette, bars, 0.83, rgba(palette["health_friendly"]), 0.69, power["mana"], "", "", show_text=False)
        scaled = temp.resize((width, height), Image.Resampling.NEAREST)
        image.alpha_composite(scaled, (x + 10, 843))
        draw.text((x + width // 2 + 10, 843 + height + 18), label_text, font=small, fill=(193, 178, 147, 255), anchor="ma")
        x += width + 55

    draw.text((43, 997), "本图只确认新架构与几何。若方向确认，下一步先用已接受材料构造透明 candidate，再由你确认 exact pixels；不直接接入 addon。", font=note, fill=(164, 153, 134, 255))
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
