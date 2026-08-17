#!/usr/bin/env python3
"""Render CHAR-SIM-V2 from the Vanilla 1.12.1 PaperDollFrame geometry.

This is a deterministic geometric review mock. It deliberately contains no
production bitmap and does not write into addon/ or assets/source/.
"""

from __future__ import annotations

import hashlib
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "generated/character/simulation"
SERIF = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"
SANS = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"

NATIVE = (384, 512)
MODEL_RECT = (65, 78, 298, 302)
STATS_RECT = (67, 291, 297, 369)
LEFT_SLOT_X = 21
RIGHT_SLOT_X = 305
SLOT_Y = [74 + 41 * index for index in range(8)]
BOTTOM_SLOT_X = [122, 164, 206]
BOTTOM_SLOT_Y = 385
AMMO_RECT = (258, 390, 285, 417)

INK = (46, 30, 20, 255)
CREAM = (222, 199, 149, 255)
GOLD = (205, 166, 82, 255)
LEATHER = (70, 43, 29, 255)
LEATHER_DARK = (35, 24, 19, 255)
LEATHER_WORN = (104, 66, 38, 255)
BRASS = (116, 89, 45, 255)
BRASS_DARK = (55, 46, 31, 255)
PARCHMENT = (172, 139, 91, 255)
PARCHMENT_LIGHT = (198, 167, 113, 255)
MODEL_FIELD = (42, 48, 39, 255)


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size)


def scaled_box(box: tuple[int, int, int, int], scale: int) -> tuple[int, int, int, int]:
    return tuple(value * scale for value in box)


def rough_polygon(draw: ImageDraw.ImageDraw, points: list[tuple[int, int]], fill, outline, width: int) -> None:
    draw.polygon(points, fill=fill)
    draw.line(points + [points[0]], fill=outline, width=width, joint="curve")


def add_grain(image: Image.Image, strength: float = 0.13) -> Image.Image:
    noise = Image.effect_noise(image.size, 28).convert("L")
    tint = Image.new("RGBA", image.size, (87, 59, 35, 255))
    tint.putalpha(noise.point(lambda value: int(value * strength)))
    return Image.alpha_composite(image, tint)


def draw_slot(
    canvas: Image.Image,
    x: int,
    y: int,
    scale: int,
    index: int,
    state: str = "normal",
    empty: bool = False,
) -> None:
    draw = ImageDraw.Draw(canvas)
    left, top = x * scale, y * scale
    size = 37 * scale
    rng = random.Random(3000 + index)
    wobble = [rng.randint(-1, 1) * scale for _ in range(8)]
    outer = [
        (left + wobble[0], top + 2 * scale + wobble[1]),
        (left + size - 2 * scale + wobble[2], top + wobble[3]),
        (left + size + wobble[4], top + size - 3 * scale),
        (left + 2 * scale + wobble[6], top + size + wobble[7]),
    ]
    rim = (134, 103, 54, 255)
    if state == "hover":
        rim = (190, 148, 72, 255)
    elif state == "broken":
        rim = (112, 46, 36, 255)
    rough_polygon(draw, outer, LEATHER_DARK, (18, 13, 10, 255), max(1, scale))
    inset = (left + 4 * scale, top + 4 * scale, left + size - 4 * scale, top + size - 4 * scale)
    draw.rounded_rectangle(inset, radius=2 * scale, fill=(31, 32, 27, 255), outline=rim, width=max(1, scale))
    if empty:
        draw.ellipse(
            (left + 11 * scale, top + 10 * scale, left + 26 * scale, top + 25 * scale),
            outline=(104, 88, 61, 190),
            width=max(1, scale),
        )
        draw.line(
            (left + 13 * scale, top + 25 * scale, left + 24 * scale, top + 12 * scale),
            fill=(92, 76, 53, 170),
            width=max(1, scale),
        )
    else:
        colors = [
            (82, 105, 83, 255), (102, 76, 58, 255), (68, 86, 112, 255),
            (107, 77, 96, 255), (92, 104, 62, 255), (76, 92, 97, 255),
        ]
        color = colors[index % len(colors)]
        draw.rectangle(
            (left + 7 * scale, top + 7 * scale, left + 30 * scale, top + 30 * scale),
            fill=color,
        )
        draw.polygon(
            [
                (left + 18 * scale, top + 8 * scale),
                (left + 28 * scale, top + 20 * scale),
                (left + 19 * scale, top + 29 * scale),
                (left + 9 * scale, top + 20 * scale),
            ],
            fill=(160, 139, 94, 210),
        )
        quality = [(73, 122, 73, 255), (81, 102, 152, 255), (116, 75, 145, 255)][index % 3]
        draw.line(
            (left + 5 * scale, top + 5 * scale, left + size - 5 * scale, top + 5 * scale),
            fill=quality,
            width=max(1, scale),
        )
    if state == "hover":
        draw.line(outer + [outer[0]], fill=(219, 177, 87, 230), width=scale, joint="curve")
    if state == "broken":
        draw.line(
            (left + 8 * scale, top + 6 * scale, left + 17 * scale, top + 18 * scale,
             left + 12 * scale, top + 30 * scale),
            fill=(193, 80, 50, 255),
            width=max(1, scale),
        )


def draw_model(draw: ImageDraw.ImageDraw, scale: int) -> None:
    def p(x: int, y: int) -> tuple[int, int]:
        return x * scale, y * scale

    # Dynamic character silhouette: deliberately schematic and not part of the frame asset.
    draw.ellipse((*p(169, 104), *p(193, 130)), fill=(105, 130, 117, 255), outline=(176, 157, 116, 210), width=scale)
    draw.polygon([p(155, 138), p(207, 138), p(220, 229), p(142, 229)], fill=(65, 79, 91, 255))
    draw.polygon([p(142, 215), p(220, 215), p(244, 286), p(122, 286)], fill=(49, 62, 71, 255))
    draw.line((*p(138, 146), *p(106, 228)), fill=(147, 126, 83, 255), width=5 * scale)
    draw.line((*p(211, 145), *p(241, 226)), fill=(147, 126, 83, 255), width=5 * scale)
    draw.line((*p(227, 104), *p(116, 283)), fill=(118, 91, 48, 255), width=4 * scale)
    draw.ellipse((*p(219, 92), *p(237, 110)), fill=(105, 74, 134, 255), outline=(171, 132, 180, 255), width=scale)
    draw.line((*p(157, 153), *p(204, 153)), fill=(175, 141, 76, 255), width=2 * scale)
    draw.line((*p(151, 179), *p(211, 179)), fill=(89, 112, 107, 255), width=2 * scale)


def render_character(scale: int = 2, four_tabs: bool = True) -> Image.Image:
    width, height = NATIVE[0] * scale, NATIVE[1] * scale
    panel = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(panel)
    rng = random.Random(11201)

    def p(x: int, y: int) -> tuple[int, int]:
        return x * scale, y * scale

    outer = [p(8, 10), p(40, 5), p(349, 8), p(357, 35), p(354, 424), p(342, 446), p(19, 447), p(7, 420)]
    rough_polygon(draw, outer, LEATHER_DARK, (15, 10, 7, 255), 2 * scale)
    inner = [p(17, 48), p(29, 39), p(339, 42), p(347, 58), p(346, 421), p(336, 432), p(24, 433), p(16, 419)]
    rough_polygon(draw, inner, LEATHER, BRASS_DARK, scale)
    draw.line((*p(25, 52), *p(335, 49)), fill=BRASS, width=scale)
    draw.line((*p(22, 420), *p(338, 422)), fill=(92, 67, 36, 255), width=scale)

    # CharacterFramePortrait is intentionally hidden by the overhaul. Keep this
    # corner as worn structural leather: no portrait, race icon, class icon, or
    # empty medallion backing.
    draw.line((*p(13, 20), *p(56, 14)), fill=(92, 58, 34, 150), width=scale)
    draw.line((*p(17, 27), *p(48, 23)), fill=(50, 34, 24, 190), width=scale)

    # Title and close clasp.
    draw.text(p(198, 18), "伊瑟拉的旅人", font=font(SERIF, 11 * scale), fill=CREAM, anchor="mm")
    draw.text(p(198, 36), "60级  暗夜精灵  法师", font=font(SANS, 7 * scale), fill=(184, 155, 103, 255), anchor="mm")
    close_center = p(339, 25)
    draw.ellipse((close_center[0] - 12 * scale, close_center[1] - 12 * scale,
                  close_center[0] + 12 * scale, close_center[1] + 12 * scale),
                 fill=(64, 46, 29, 255), outline=BRASS, width=scale)
    draw.line((close_center[0] - 4 * scale, close_center[1] - 4 * scale,
               close_center[0] + 4 * scale, close_center[1] + 4 * scale), fill=CREAM, width=scale)
    draw.line((close_center[0] + 4 * scale, close_center[1] - 4 * scale,
               close_center[0] - 4 * scale, close_center[1] + 4 * scale), fill=CREAM, width=scale)

    # Exact native model field and quiet material background.
    mx1, my1, mx2, my2 = scaled_box(MODEL_RECT, scale)
    model_points = [(mx1 - scale, my1 + scale), (mx2 - 2 * scale, my1), (mx2, my2 - scale), (mx1 + scale, my2)]
    rough_polygon(draw, model_points, MODEL_FIELD, (86, 67, 39, 255), scale)
    for _ in range(28):
        x = rng.randint(mx1 + 8 * scale, mx2 - 8 * scale)
        y = rng.randint(my1 + 8 * scale, my2 - 8 * scale)
        draw.point((x, y), fill=(106, 90, 58, rng.randint(28, 65)))
    draw_model(draw, scale)

    # Real 230x78 attribute field, kept as one old parchment object rather than cards.
    sx1, sy1, sx2, sy2 = scaled_box(STATS_RECT, scale)
    stats_points = [(sx1, sy1 + scale), (sx2 - scale, sy1), (sx2, sy2 - 2 * scale), (sx1 + 2 * scale, sy2)]
    rough_polygon(draw, stats_points, PARCHMENT, (82, 55, 32, 255), scale)
    draw.line((181 * scale, 296 * scale, 181 * scale, 364 * scale), fill=(111, 79, 45, 160), width=scale)
    draw.text(p(73, 297), "主属性", font=font(SERIF, 7 * scale), fill=INK)
    draw.text(p(187, 297), "战斗属性", font=font(SERIF, 7 * scale), fill=INK)
    left_stats = [("力量", "29"), ("敏捷", "33"), ("耐力", "226"), ("智力", "353"), ("精神", "294")]
    right_stats = [("护甲", "895"), ("攻击强度", "118"), ("法术强度", "214"), ("爆击", "7.8%"), ("命中", "3%")]
    stat_font = font(SANS, 6 * scale)
    for idx, ((label_l, value_l), (label_r, value_r)) in enumerate(zip(left_stats, right_stats)):
        y = 311 + idx * 11
        draw.text(p(74, y), label_l, font=stat_font, fill=(59, 40, 24, 255), anchor="lm")
        draw.text(p(174, y), value_l, font=stat_font, fill=(37, 80, 39, 255), anchor="rm")
        draw.text(p(188, y), label_r, font=stat_font, fill=(59, 40, 24, 255), anchor="lm")
        draw.text(p(290, y), value_r, font=stat_font, fill=(37, 80, 39, 255), anchor="rm")

    # Equipment buttons remain separate dynamic objects.
    for index, y in enumerate(SLOT_Y):
        draw_slot(panel, LEFT_SLOT_X, y, scale, index, empty=index in {1, 5})
        draw_slot(panel, RIGHT_SLOT_X, y, scale, index + 8, state="broken" if index == 7 else "normal")
    for index, x in enumerate(BOTTOM_SLOT_X):
        draw_slot(panel, x, BOTTOM_SLOT_Y, scale, index + 16, state="hover" if index == 0 else "normal")

    # Native independent ammunition well.
    ax1, ay1, ax2, ay2 = scaled_box(AMMO_RECT, scale)
    draw.ellipse((ax1, ay1, ax2, ay2), fill=(40, 33, 24, 255), outline=BRASS_DARK, width=scale)
    draw.line((ax1 + 8 * scale, ay2 - 6 * scale, ax2 - 5 * scale, ay1 + 5 * scale), fill=(163, 129, 71, 255), width=2 * scale)
    draw.text((ax2 - scale, ay2 - scale), "847", font=font(SANS, 5 * scale), fill=CREAM, anchor="rb")

    # Five independent resistance wells at the original right-side strip.
    res_colors = [(92, 104, 117, 255), (91, 106, 76, 255), (112, 84, 70, 255), (102, 89, 120, 255), (107, 100, 68, 255)]
    for index, color in enumerate(res_colors):
        y = (77 + 29 * index) * scale
        draw.ellipse((266 * scale, y, 294 * scale, y + 27 * scale), fill=(34, 31, 24, 255), outline=BRASS_DARK, width=scale)
        draw.ellipse((271 * scale, y + 4 * scale, 289 * scale, y + 22 * scale), fill=color)
        draw.text((280 * scale, y + 23 * scale), str(15 + index * 5), font=font(SANS, 5 * scale), fill=CREAM, anchor="ms")

    # Small model rotation controls, independent and intentionally quiet.
    for x, glyph in ((70, "‹"), (91, "›")):
        draw.ellipse((*p(x, 80), *p(x + 18, 98)), fill=(50, 37, 25, 230), outline=BRASS_DARK, width=scale)
        draw.text(p(x + 9, 88), glyph, font=font(SERIF, 11 * scale), fill=CREAM, anchor="mm")

    # Tabs are real buttons. Four are visible for this non-pet class; the fifth remains feature-detected.
    labels = ["角色", "声望", "技能", "PVP"] if four_tabs else ["角色", "宠物", "声望", "技能", "PVP"]
    available = 328
    tab_w = available // len(labels) + 4
    x = 15
    for index, label in enumerate(labels):
        y = 433 - (3 if index == 0 else 0)
        points = [p(x, y + 4), p(x + 7, y), p(x + tab_w - 6, y + 1), p(x + tab_w, y + 6), p(x + tab_w - 3, y + 27), p(x + 4, y + 27)]
        fill = LEATHER_WORN if index == 0 else (52, 36, 25, 255)
        rough_polygon(draw, points, fill, BRASS_DARK, scale)
        draw.text(p(x + tab_w // 2, y + 14), label, font=font(SERIF, 7 * scale), fill=GOLD if index == 0 else CREAM, anchor="mm")
        x += tab_w - 5

    panel = add_grain(panel, 0.07)
    return panel


def draw_component_map(board: Image.Image, panel: Image.Image, origin: tuple[int, int]) -> None:
    x0, y0 = origin
    preview = panel.resize((384, 512), Image.Resampling.LANCZOS)
    board.alpha_composite(preview, origin)
    draw = ImageDraw.Draw(board)
    overlay = [
        ("MODEL 233×224", MODEL_RECT, (91, 156, 139, 255)),
        ("STATS 230×78", STATS_RECT, (211, 166, 79, 255)),
        ("SLOT 37×37", (21, 74, 342, 398), (145, 103, 170, 255)),
        ("TABS 4/5", (15, 430, 348, 462), (190, 92, 73, 255)),
    ]
    for label, box, color in overlay:
        b = tuple((x0 + value if idx % 2 == 0 else y0 + value) for idx, value in enumerate(box))
        draw.rectangle(b, outline=color, width=2)
        draw.rectangle((b[0], b[1], b[0] + 108, b[1] + 17), fill=(21, 20, 18, 225))
        draw.text((b[0] + 5, b[1] + 2), label, font=font(SANS, 11), fill=color)


def draw_state_samples(board: Image.Image, origin: tuple[int, int]) -> None:
    x0, y0 = origin
    draw = ImageDraw.Draw(board)
    draw.text((x0, y0), "交互对象仍逐个存在", font=font(SERIF, 24), fill=CREAM)
    labels = [("普通", "normal", False), ("悬停", "hover", False), ("损坏", "broken", False), ("空槽", "normal", True)]
    for index, (label, state, empty) in enumerate(labels):
        cell = Image.new("RGBA", (116, 128), (30, 28, 25, 255))
        draw_slot(cell, 10, 8, 2, 30 + index, state=state, empty=empty)
        ImageDraw.Draw(cell).text((58, 105), label, font=font(SANS, 15), fill=CREAM, anchor="mm")
        board.alpha_composite(cell, (x0 + index * 128, y0 + 38))


def render_review(runtime: Image.Image) -> Image.Image:
    board = Image.new("RGBA", (1920, 1200), (23, 23, 22, 255))
    # Soft warm vignette.
    backdrop = Image.new("RGBA", board.size, (31, 29, 25, 255))
    backdrop = add_grain(backdrop, 0.05)
    board.alpha_composite(backdrop)
    draw = ImageDraw.Draw(board)
    draw.text((64, 42), "CHAR-SIM-V2 · 香草 CharacterFrame 组件级预演", font=font(SERIF, 34), fill=CREAM)
    draw.text((66, 91), "几何来自 WoW 1.12.1 FrameXML；这里仅验证结构、层次与综合色感，不是 production 位图。", font=font(SANS, 18), fill=(178, 161, 130, 255))

    main = runtime.resize((768, 1024), Image.Resampling.NEAREST)
    shadow = Image.new("RGBA", main.size, (0, 0, 0, 0))
    shadow.putalpha(main.getchannel("A").filter(ImageFilter.GaussianBlur(16)))
    shadow = ImageEnhance.Brightness(shadow).enhance(0.2)
    board.alpha_composite(shadow, (69, 136))
    board.alpha_composite(main, (54, 120))
    draw.text((438, 1150), "主视图：原生 384×512 @ 200%", font=font(SANS, 16), fill=(162, 143, 112, 255), anchor="mm")

    draw.text((900, 126), "真实对象地图", font=font(SERIF, 27), fill=CREAM)
    draw_component_map(board, runtime, (900, 173))

    notes_x = 1318
    draw.text((notes_x, 130), "原生尺寸与边界", font=font(SERIF, 27), fill=CREAM)
    notes = [
        "CharacterFrame  384×512",
        "CharacterModelFrame  233×224 @ 65,78",
        "CharacterAttributesFrame  230×78 @ 67,291",
        "左右装备槽  37×37；纵向间隔 4px",
        "底部：主手／副手／远程三槽",
        "弹药：独立 27×27，不并入第四底槽",
        "Tabs：原生 5 个；非宠物职业动态显示 4 个",
        "左上 CharacterFramePortrait：隐藏且不生成底座",
        "右侧第三方装备列表：明确排除",
    ]
    for index, line in enumerate(notes):
        draw.ellipse((notes_x, 184 + index * 39, notes_x + 8, 192 + index * 39), fill=BRASS)
        draw.text((notes_x + 18, 175 + index * 39), line, font=font(SANS, 17), fill=(202, 186, 154, 255))

    draw.text((notes_x, 520), "production 必须拆分", font=font(SERIF, 27), fill=CREAM)
    splits = [
        "1. FRAME 外壳：不含文字／槽／Tab",
        "2. MODEL 安静背景与窄边框",
        "3. STATS 一张连续旧羊皮纸底，不做现代卡片",
        "4. SLOT 基座、空槽、品质、耐久分别叠加",
        "5. RESISTANCE 每格独立；图标与数值动态",
        "6. CLOSE／ROTATE／TABS 各自四态",
        "7. 模型、装备 icon、文字、数量全部由游戏实时绘制",
    ]
    for index, line in enumerate(splits):
        draw.text((notes_x, 568 + index * 34), line, font=font(SANS, 16), fill=(189, 171, 138, 255))

    draw_state_samples(board, (900, 750))
    draw.rounded_rectangle((900, 955, 1830, 1135), radius=9, fill=(37, 33, 28, 235), outline=(79, 62, 39, 255), width=2)
    draw.text((925, 977), "本版收敛重点", font=font(SERIF, 23), fill=GOLD)
    focus = [
        "• 保留香草密度与竖向轮廓，不扩展为横向 Dashboard。",
        "• 皮革边缘有轻微手工偏差；黄铜只作窄包边，不做工业对称框。",
        "• 品质色缩成槽内一条窄沿；属性区是一整张旧纸，不是两张数据卡。",
        "• 左上不保留肖像、种族／职业 icon 或空徽章底座。",
    ]
    for index, line in enumerate(focus):
        draw.text((928, 1017 + index * 27), line, font=font(SANS, 16), fill=(202, 186, 154, 255))
    return board.convert("RGB")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    digest.update(path.read_bytes())
    return digest.hexdigest()


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    runtime = render_character(scale=1)
    runtime_path = OUT / "CHAR-SIM-V2_reference.png"
    review_path = OUT / "CHAR-SIM-V2_review.png"
    runtime.save(runtime_path, compress_level=9)
    render_review(runtime).save(review_path, compress_level=9)
    print(f"reference={runtime_path} size={runtime.size} sha256={sha256(runtime_path)}")
    print(f"review={review_path} size={(1920, 1200)} sha256={sha256(review_path)}")


if __name__ == "__main__":
    main()
