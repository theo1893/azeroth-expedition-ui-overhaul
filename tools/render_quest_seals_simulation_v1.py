#!/usr/bin/env python3
"""Render the deterministic Quest Log / Tracker wax-seal direction preview."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, ImageFont


INK = (54, 30, 17, 255)
INK_SOFT = (82, 49, 27, 225)
PAPER = (183, 143, 83, 255)
PAPER_LIGHT = (198, 159, 98, 255)
PAPER_DARK = (139, 100, 57, 255)
LEATHER = (70, 36, 24, 255)
LEATHER_DARK = (34, 19, 14, 255)
BRASS = (139, 96, 38, 255)
BRASS_LIGHT = (186, 137, 61, 255)
WAX = (105, 29, 26, 255)
WAX_HOVER = (137, 44, 32, 255)
WAX_PRESSED = (73, 20, 20, 255)
WAX_DISABLED = (79, 57, 48, 205)
WAX_EDGE = (48, 14, 15, 255)
WAX_HIGHLIGHT = (183, 74, 48, 205)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    return parser.parse_args()


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(
        str(path), size, layout_engine=ImageFont.Layout.BASIC
    )


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def resolve(root: Path, value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else root / path


def contains(outer: list[int], inner: list[int]) -> bool:
    ox, oy, ow, oh = outer
    ix, iy, iw, ih = inner
    return (
        ix >= ox
        and iy >= oy
        and ix + iw <= ox + ow
        and iy + ih <= oy + oh
    )


def overlaps(a: list[int], b: list[int]) -> bool:
    ax, ay, aw, ah = a
    bx, by, bw, bh = b
    return not (
        ax + aw <= bx
        or bx + bw <= ax
        or ay + ah <= by
        or by + bh <= ay
    )


def dashed_rectangle(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    fill: tuple[int, int, int, int],
    width: int = 1,
    dash: int = 5,
) -> None:
    x0, y0, x1, y1 = box
    for x in range(x0, x1, dash * 2):
        draw.line((x, y0, min(x + dash, x1), y0), fill=fill, width=width)
        draw.line((x, y1, min(x + dash, x1), y1), fill=fill, width=width)
    for y in range(y0, y1, dash * 2):
        draw.line((x0, y, x0, min(y + dash, y1)), fill=fill, width=width)
        draw.line((x1, y, x1, min(y + dash, y1)), fill=fill, width=width)


def irregular_ring(cx: float, cy: float, radius: float) -> list[tuple[int, int]]:
    offsets = (0.1, -0.7, 0.5, -0.2, 0.7, -0.6, 0.2, -0.35, 0.55, -0.5, 0.25, -0.2)
    points: list[tuple[int, int]] = []
    for index, offset in enumerate(offsets):
        angle = -math.pi / 2 + index * math.tau / len(offsets)
        r = radius + offset * max(0.8, radius * 0.08)
        points.append(
            (
                int(round(cx + math.cos(angle) * r)),
                int(round(cy + math.sin(angle) * r)),
            )
        )
    return points


def draw_compass_imprint(
    draw: ImageDraw.ImageDraw, cx: float, cy: float, radius: float
) -> None:
    scale = max(1.0, radius / 7.0)
    long = radius * 0.55
    short = radius * 0.28
    points = [
        (cx, cy - long),
        (cx + short, cy - short),
        (cx + long, cy),
        (cx + short, cy + short),
        (cx, cy + long),
        (cx - short, cy + short),
        (cx - long, cy),
        (cx - short, cy - short),
    ]
    draw.polygon(points, fill=(51, 16, 16, 215))
    draw.line(
        (cx - long * 0.72, cy + long * 0.72, cx + long * 0.72, cy - long * 0.72),
        fill=(203, 99, 57, 120),
        width=max(1, int(scale)),
    )
    if radius >= 10:
        draw.ellipse(
            (
                int(cx - radius * 0.18),
                int(cy - radius * 0.18),
                int(cx + radius * 0.18),
                int(cy + radius * 0.18),
            ),
            fill=(122, 43, 31, 255),
            outline=(42, 14, 15, 190),
            width=1,
        )


def draw_seal(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    state: str = "normal",
    hitbox: bool = False,
) -> None:
    x, y, width, height = box
    if state == "pressed":
        y += 1
    cx = x + width / 2
    cy = y + height / 2
    radius = min(width, height) / 2 - 1
    palette = {
        "normal": WAX,
        "hover": WAX_HOVER,
        "pressed": WAX_PRESSED,
        "disabled": WAX_DISABLED,
    }
    fill = palette[state]
    shadow = irregular_ring(cx + 1, cy + 2, radius)
    draw.polygon(shadow, fill=(22, 10, 8, 115))
    outer = irregular_ring(cx, cy, radius)
    draw.polygon(outer, fill=fill, outline=WAX_EDGE)
    inset = max(2, int(radius * 0.23))
    draw.ellipse(
        (x + inset, y + inset, x + width - inset - 1, y + height - inset - 1),
        outline=(48, 15, 15, 185),
        width=1,
    )
    if width >= 20:
        draw.arc(
            (x + 3, y + 3, x + width - 4, y + height - 4),
            196,
            302,
            fill=WAX_HIGHLIGHT,
            width=2,
        )
        draw.line(
            (x + width - 7, y + height - 5, x + width - 4, y + height - 8),
            fill=(37, 12, 12, 210),
            width=1,
        )
    else:
        draw.point((x + 3, y + 3), fill=WAX_HIGHLIGHT)
    draw_compass_imprint(draw, cx, cy, radius)
    if hitbox:
        dashed_rectangle(
            draw,
            (x - 1, y - 1, x + width, y + height),
            (232, 186, 81, 235),
            width=1,
            dash=3,
        )


def draw_scene_background(image: Image.Image, utility: ImageFont.FreeTypeFont) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle((0, 0, 1536, 1024), fill=(49, 61, 60, 255))
    draw.polygon(
        [(0, 310), (220, 175), (380, 300), (590, 130), (850, 300), (1050, 176), (1260, 290), (1536, 155), (1536, 560), (0, 560)],
        fill=(41, 48, 46, 255),
    )
    draw.polygon(
        [(0, 380), (250, 300), (520, 400), (770, 280), (1040, 390), (1260, 310), (1536, 390), (1536, 610), (0, 610)],
        fill=(27, 49, 45, 255),
    )
    draw.rectangle((0, 530, 1536, 730), fill=(36, 74, 77, 255))
    for y in range(552, 725, 29):
        draw.line((0, y, 1536, y), fill=(93, 122, 119, 120), width=1)
    draw.polygon(
        [(0, 760), (430, 650), (760, 720), (1270, 610), (1536, 650), (1536, 1024), (0, 1024)],
        fill=(59, 46, 34, 255),
    )
    for x in range(-10, 1540, 145):
        draw.polygon(
            [(x, 755), (x + 118, 725), (x + 155, 1024), (x + 24, 1024)],
            fill=(80, 57, 36, 255),
            outline=(42, 29, 21, 255),
        )
    draw.ellipse((40, 34, 106, 100), fill=(38, 27, 20, 255), outline=BRASS, width=4)
    draw.rectangle((95, 47, 276, 69), fill=(39, 25, 18, 245), outline=BRASS, width=3)
    draw.rectangle((98, 50, 244, 66), fill=(68, 126, 77, 255))
    draw.text((108, 78), "纳斯雷兹姆的文稿", font=utility, fill=(218, 183, 112, 255))
    draw.ellipse((714, 426, 786, 500), fill=(40, 24, 21, 255))
    draw.polygon([(738, 490), (763, 490), (793, 642), (750, 692), (706, 642)], fill=(27, 18, 17, 255))
    draw.line((738, 506, 665, 616), fill=(132, 91, 39, 255), width=8)
    draw.line((763, 506, 836, 616), fill=(132, 91, 39, 255), width=8)
    start_x = 432
    for index in range(12):
        x = start_x + index * 53
        draw.rectangle((x, 954, x + 44, 998), fill=(42, 27, 18, 245), outline=BRASS, width=2)
        draw.ellipse((x + 8, 962, x + 35, 989), fill=(82 + index * 3, 72, 49, 255))
        draw.text((x + 4, 988), str(index + 1), font=utility, fill=(231, 199, 133, 255), anchor="ls")


def draw_leather_button(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    label: str,
    font_face: ImageFont.FreeTypeFont,
) -> None:
    x, y, width, height = box
    draw.rectangle((x, y, x + width, y + height), fill=LEATHER_DARK)
    draw.rectangle((x + 1, y + 1, x + width - 1, y + height - 1), fill=LEATHER, outline=BRASS, width=1)
    draw.line((x + 2, y + 2, x + width - 2, y + 2), fill=BRASS_LIGHT, width=1)
    draw.text((x + width / 2, y + height / 2), label, font=font_face, fill=(232, 196, 116, 255), anchor="mm")


def draw_quest_log(
    image: Image.Image,
    root: Path,
    spec: dict[str, Any],
    fonts: dict[str, ImageFont.FreeTypeFont],
    origin: tuple[int, int] | None = None,
    annotate: bool = False,
) -> dict[str, list[int]]:
    frame_x, frame_y, frame_w, frame_h = spec["frame"]
    if origin is not None:
        frame_x, frame_y = origin
    shell_path = resolve(root, spec["_shell_path"])
    shell = Image.open(shell_path).convert("RGBA").resize(
        (frame_w, frame_h), Image.Resampling.LANCZOS
    )
    image.alpha_composite(shell, (frame_x, frame_y))
    draw = ImageDraw.Draw(image, "RGBA")
    title = fonts["title"]
    body = fonts["body"]
    tiny = fonts["tiny"]
    utility = fonts["utility"]
    draw.text((frame_x + frame_w / 2, frame_y + 28), "任务日志", font=title, fill=INK, anchor="mm")
    draw.text((frame_x + 304, frame_y + 51), "任务：18 / 20", font=tiny, fill=INK_SOFT, anchor="ra")
    draw.text((frame_x + 142, frame_y + 46), "显示任务等级", font=tiny, fill=INK_SOFT)
    draw.ellipse((frame_x + 134, frame_y + 44, frame_x + 143, frame_y + 53), outline=INK_SOFT, width=1)
    draw.text((frame_x + 598, frame_y + 45), "在线", font=tiny, fill=INK_SOFT, anchor="ra")
    draw.text((frame_x + 550, frame_y + 45), "简体中文", font=tiny, fill=INK_SOFT, anchor="ra")

    rows = [
        ("东部王国", True),
        ("[60] 黑石山的暗影", False),
        ("[58+] 深渊中的回响", False),
        ("[60R] 熔火之心", False),
        ("卡利姆多", True),
        ("[55] 费伍德的净化", False),
        ("[57] 冬泉谷的传说", False),
        ("[60] 希利苏斯的召唤", False),
        ("地下城", True),
        ("[52D] 沉没的神庙", False),
        ("[58D] 黑石深渊", False),
        ("[60D] 通灵学院", False),
        ("职业任务", True),
        ("[60] 远古法典", False),
        ("[60] 公会的委托", False),
        ("世界任务", True),
        ("[54] 失落的信使", False),
        ("[56] 被遗忘的祭坛", False),
        ("[57] 风暴前夕", False),
        ("[59] 最后的远征", False),
        ("节庆", True),
        ("[35] 月光下的约定", False),
        ("[40] 旧友的来信", False),
    ]
    list_x = frame_x + 64
    list_y = frame_y + 67
    for index, (text, header) in enumerate(rows[: int(spec["_row_count"])]):
        y = list_y + index * 14
        if header:
            draw.polygon([(list_x + 2, y + 4), (list_x + 8, y + 7), (list_x + 2, y + 10)], fill=INK)
            fill = (70, 44, 22, 255)
        else:
            draw.ellipse((list_x + 2, y + 4, list_x + 9, y + 11), outline=INK_SOFT, width=1)
            fill = INK_SOFT
        draw.text((list_x + 13, y + 1), text, font=tiny, fill=fill)

    detail_x = frame_x + 376
    detail_y = frame_y + 72
    draw.text((detail_x, detail_y), "熔火之心", font=title, fill=INK)
    draw.line((detail_x, detail_y + 24, frame_x + 600, detail_y + 24), fill=(103, 70, 35, 150), width=1)
    detail_lines = [
        "黑石山深处传来古老而炽热的回声。",
        "公爵要求你与同伴进入熔火之心，",
        "查明元素领主再度苏醒的征兆。",
        "",
        "任务目标",
        "  · 击败熔火巨人：6 / 8",
        "  · 取得远古符文碎片：2 / 4",
        "  · 向洛索斯·天痕复命",
        "",
        "奖励",
        "你将获得：",
    ]
    for index, line in enumerate(detail_lines):
        fill = INK if index in (4, 9) else INK_SOFT
        face = body if index not in (4, 9) else utility
        draw.text((detail_x, detail_y + 34 + index * 18), line, font=face, fill=fill)
    for index in range(3):
        x = detail_x + index * 48
        y = detail_y + 244
        draw.rectangle((x, y, x + 36, y + 36), fill=(49, 30, 20, 235), outline=BRASS, width=2)
        draw.ellipse((x + 7, y + 7, x + 29, y + 29), fill=(73 + 25 * index, 71, 48 + 18 * index, 255))

    button_y = frame_y + 423
    for index, label in enumerate(("放弃任务", "共享任务", "退出")):
        draw_leather_button(draw, (frame_x + 62 + index * 83, button_y, 78, 22), label, tiny)
    draw_leather_button(draw, (frame_x + 311, button_y, 24, 22), ">", tiny)
    for index, label in enumerate(("显示", "隐藏", "清空", "重置")):
        draw_leather_button(draw, (frame_x + 379 + index * 56, button_y + 1, 52, 20), label, tiny)

    sx, sy, sw, sh = spec["seal"]["box"]
    seal_box = (frame_x + sx, frame_y + sy, sw, sh)
    draw_seal(draw, seal_box, state=spec["seal"]["state_in_scene"], hitbox=annotate)
    if annotate:
        draw.line(
            (seal_box[0] + sw, seal_box[1] + sh / 2, frame_x + frame_w + 36, seal_box[1] + sh / 2),
            fill=BRASS_LIGHT,
            width=2,
        )
        draw.text(
            (frame_x + frame_w + 42, seal_box[1] + sh / 2),
            "28×28 独立 Texture\n当前不接收鼠标",
            font=utility,
            fill=(236, 202, 127, 255),
            anchor="lm",
            spacing=4,
        )
    return {
        "frame": [frame_x, frame_y, frame_w, frame_h],
        "seal": [seal_box[0], seal_box[1], sw, sh],
    }


def tracker_button_boxes(x: int, y: int, width: int, panel_height: int) -> dict[str, tuple[int, int, int, int]]:
    size = panel_height - 2
    step = panel_height + 1
    return {
        "quests": (x + 1, y + 1, size, size),
        "database": (x + 1 + step, y + 1, size, size),
        "giver": (x + 1 + step * 2, y + 1, size, size),
        "close": (x + width - 1 - size, y + 1, size, size),
        "settings": (x + width - 1 - step - size, y + 1, size, size),
        "clean": (x + width - 1 - step * 2 - size, y + 1, size, size),
        "search": (x + width - 1 - step * 3 - size, y + 1, size, size),
    }


def draw_provider_icon(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    kind: str,
) -> None:
    x, y, width, height = box
    draw.rectangle((x, y, x + width - 1, y + height - 1), fill=(91, 61, 30, 255), outline=(39, 24, 15, 255), width=1)
    if kind == "close":
        draw.line((x + 3, y + 3, x + width - 4, y + height - 4), fill=BRASS_LIGHT, width=1)
        draw.line((x + width - 4, y + 3, x + 3, y + height - 4), fill=BRASS_LIGHT, width=1)
    elif kind == "clean":
        draw.line((x + 3, y + height - 4, x + width - 4, y + 3), fill=BRASS_LIGHT, width=2)
    elif kind == "search":
        draw.ellipse((x + 3, y + 2, x + width - 5, y + height - 6), outline=BRASS_LIGHT, width=1)
        draw.line((x + width - 6, y + height - 6, x + width - 3, y + height - 3), fill=BRASS_LIGHT, width=1)
    else:
        draw.ellipse((x + 3, y + 3, x + width - 4, y + height - 4), fill=(98, 72, 37, 255), outline=BRASS_LIGHT, width=1)


def draw_tracker(
    image: Image.Image,
    spec: dict[str, Any],
    fonts: dict[str, ImageFont.FreeTypeFont],
    frame: tuple[int, int, int, int] | None = None,
    annotate: bool = False,
    compact: bool = False,
) -> dict[str, list[int]]:
    x, y, width, height = frame or tuple(spec["frame"])
    panel_height = int(spec["panel_height"])
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle((x, y, x + width - 1, y + height - 1), fill=PAPER)
    draw.rectangle((x, y, x + width - 1, y + panel_height - 1), fill=(171, 126, 70, 255))
    draw.line((x, y + panel_height, x + width - 1, y + panel_height), fill=(113, 76, 38, 185), width=1)
    boxes = tracker_button_boxes(x, y, width, panel_height)
    seal_size = int(spec["seal"]["size"])
    seal_outset = int(spec["seal"]["top_outset"])
    seal_box = (
        x + (width - seal_size) // 2,
        y - seal_outset,
        seal_size,
        seal_size,
    )
    draw_seal(
        draw,
        seal_box,
        state=spec["seal"]["state_in_scene"],
        hitbox=annotate,
    )

    if not compact:
        tiny = fonts["tracker"]
        objective = fonts["tracker_small"]
        tasks = [
            ("[60] 黑石深渊的余烬 (35%)", ["黑铁矮人：7 / 12", "找到失落的勋章：0 / 1"]),
            ("[58] 失落的矮人远征队 (60%)", ["火焰精华：3 / 8"]),
            ("[60+] 熔火之心的召唤 (0%)", ["将指令交给指挥官：0 / 1", "击败熔岩巨人：5 / 10"]),
            ("[57] 东瘟疫之地的档案 (75%)", ["破损的档案：4 / 6", "霜刃剑刃：2 / 6"]),
            ("[55] 被遗忘的补给线 (40%)", ["向骑兵石板：1 / 4"]),
            ("[60] 银色黎明的委托 (100%)", ["黑龙军团徽记：0 / 10", "搜索东部营地：1 / 3"]),
            ("[59] 冬泉谷的盟约 (20%)", ["清除燃烧平原的斥候：6 / 9", "熔岩之核：2 / 5"]),
            ("[56] 沉没神庙的石板 (50%)", ["最后黎明勇士：4 / 7", "寻找遗失的手记：0 / 1"]),
            ("[60+] 黑翼之巢的密令 (0%)", ["收集黑龙信件：3 / 5"]),
            ("[54] 荒芜之地的线索 (90%)", ["净化断枪的圣水：1 / 3", "追回圣光之愿礼拜堂：0 / 1"]),
        ]
        cursor_y = y + panel_height + 5
        for index, (title, objectives) in enumerate(tasks):
            marker = WAX if index in (0, 3, 6, 9) else (126, 87, 35, 255)
            draw.ellipse((x + 3, cursor_y + 2, x + 12, cursor_y + 11), fill=marker, outline=INK, width=1)
            title_fill = WAX if index in (0, 8) else INK
            draw.text((x + 15, cursor_y), title, font=tiny, fill=title_fill)
            cursor_y += 14
            for line in objectives:
                draw.text((x + 24, cursor_y), "— " + line, font=objective, fill=INK_SOFT)
                cursor_y += 12
            if index != len(tasks) - 1:
                draw.line((x + 16, cursor_y + 1, x + width - 7, cursor_y + 1), fill=(111, 78, 42, 105), width=1)
                cursor_y += 5
            if cursor_y > y + height - 15:
                break

    if annotate:
        bx, by, bw, bh = seal_box
        draw.line((bx + bw / 2, by + bh + 4, bx + bw / 2, y + height + 24), fill=BRASS_LIGHT, width=2)
        draw.text(
            (bx + bw / 2, y + height + 31),
            "34×34 顶部中央功能入口\n纸面／列表坐标保持不变",
            font=fonts["utility"],
            fill=(236, 202, 127, 255),
            anchor="ma",
            spacing=4,
        )
    return {
        "frame": [x, y, width, height],
        "hub_seal": list(seal_box),
        "provider_buttons": {
            name: list(box) for name, box in boxes.items()
        },
    }


def build_fonts(root: Path, inputs: dict[str, str]) -> dict[str, ImageFont.FreeTypeFont]:
    title_path = resolve(root, inputs["title_font"])
    body_path = resolve(root, inputs["body_font"])
    utility_path = resolve(root, inputs["utility_font"])
    return {
        "title": font(title_path, 15),
        "body": font(body_path, 11),
        "tiny": font(body_path, 9),
        "utility": font(utility_path, 11),
        "utility_large": font(utility_path, 17),
        "tracker": font(body_path, 10),
        "tracker_small": font(body_path, 9),
    }


def render_ingame(root: Path, spec: dict[str, Any], output: Path) -> None:
    width = int(spec["canvas"]["width"])
    height = int(spec["canvas"]["height"])
    image = Image.new("RGBA", (width, height), (0, 0, 0, 255))
    fonts = build_fonts(root, spec["inputs"])
    draw_scene_background(image, fonts["tiny"])
    quest_log_spec = dict(spec["quest_log"])
    quest_log_spec["_shell_path"] = spec["inputs"]["quest_log_shell"]
    quest_log_spec["_row_count"] = spec["content"]["quest_log_rows"]
    draw_quest_log(image, root, quest_log_spec, fonts)
    draw_tracker(image, spec["tracker"], fonts)
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle((18, 980, 407, 1011), fill=(32, 22, 17, 210))
    draw.text(
        (28, 995),
        "QUEST-SEALS-SIM-V1 · 本地几何预演 · ImageGen 0/0",
        font=fonts["utility"],
        fill=(228, 199, 137, 255),
        anchor="lm",
    )
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, "PNG", optimize=False, compress_level=9)


def render_contract(root: Path, spec: dict[str, Any], output: Path) -> None:
    image = Image.new("RGBA", (1536, 1024), (40, 30, 24, 255))
    fonts = build_fonts(root, spec["inputs"])
    draw = ImageDraw.Draw(image, "RGBA")
    draw.text((38, 32), "Quest Log / Quest Tracker 漆章组件合同预演", font=fonts["utility_large"], fill=(240, 208, 138, 255))
    draw.text(
        (38, 61),
        "黄色虚线仅表示组件／命中盒；不会进入游戏资产。两处均不改变现有 UI 结构。",
        font=fonts["utility"],
        fill=(191, 163, 111, 255),
    )
    quest_log_spec = dict(spec["quest_log"])
    quest_log_spec["_shell_path"] = spec["inputs"]["quest_log_shell"]
    quest_log_spec["_row_count"] = spec["content"]["quest_log_rows"]
    draw_quest_log(image, root, quest_log_spec, fonts, origin=(35, 102), annotate=True)

    draw.text((850, 106), "Tracker：明显的顶部中央功能漆章", font=fonts["utility_large"], fill=(240, 208, 138, 255))
    tracker_y = 158
    for index, width in enumerate(spec["tracker"]["supported_widths"]):
        x = 850
        y = tracker_y + index * 142
        draw.text((x, y - 28), f"{width}×64 UI px（旧七按钮在目标视觉中隐藏）", font=fonts["utility"], fill=(201, 173, 116, 255))
        draw_tracker(
            image,
            spec["tracker"],
            fonts,
            frame=(x, y, int(width), 64),
            annotate=False,
            compact=True,
        )
        seal_size = int(spec["tracker"]["seal"]["size"])
        top_outset = int(spec["tracker"]["seal"]["top_outset"])
        sx = x + (int(width) - seal_size) // 2
        sy = y - top_outset
        dashed_rectangle(
            draw,
            (sx - 1, sy - 1, sx + seal_size, sy + seal_size),
            (232, 186, 81, 235),
            width=1,
            dash=3,
        )
        label_x = 1230
        label_y = sy + seal_size / 2
        draw.line(
            (sx + seal_size, label_y, label_x - 12, label_y),
            fill=BRASS_LIGHT,
            width=2,
        )
        draw.text(
            (label_x, label_y),
            "34×34 顶部中央入口\n底边恰接列表起点",
            font=fonts["utility"],
            fill=(236, 202, 127, 255),
            anchor="lm",
            spacing=4,
        )

    strip_y = 710
    draw.text((38, strip_y), "未来交互状态（生产时必须分离；本轮只确认视觉节奏）", font=fonts["utility_large"], fill=(240, 208, 138, 255))
    for index, state in enumerate(("normal", "hover", "pressed", "disabled")):
        x = 58 + index * 145
        draw_seal(draw, (x, strip_y + 54, 40, 40), state=state)
        draw.text((x + 20, strip_y + 108), state, font=fonts["utility"], fill=(210, 181, 122, 255), anchor="ma")
    draw.text((38, 892), "Quest Log", font=fonts["utility"], fill=(220, 191, 129, 255))
    draw.text((38, 916), "当前：28×28 无鼠标独立 Texture。未来：有真实动作时，在同一盒内升级为 Button。", font=fonts["utility"], fill=(183, 156, 108, 255))
    draw.text((775, 892), "Quest Tracker", font=fonts["utility"], fill=(220, 191, 129, 255))
    draw.text((775, 916), "目标：34×34 漆章作为唯一显式工具入口；七项功能迁移完成前不在 runtime 隐藏旧按钮。", font=fonts["utility"], fill=(183, 156, 108, 255))
    draw.text((38, 975), "非权威范围：最终手绘蜡质、裂纹、Alpha、像素边缘、atlas 与客户端混合。", font=fonts["utility"], fill=(148, 126, 91, 255))
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, "PNG", optimize=False, compress_level=9)


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    spec_path = args.spec.resolve()
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    ingame = resolve(root, spec["outputs"]["ingame"])
    contract = resolve(root, spec["outputs"]["contract"])
    report = resolve(root, spec["outputs"]["report"])
    render_ingame(root, spec, ingame)
    render_contract(root, spec, contract)

    ql = spec["quest_log"]
    frame = [0, 0, ql["frame"][2], ql["frame"][3]]
    quest_log_seal = ql["seal"]["box"]
    tracker_checks = []
    for width in spec["tracker"]["supported_widths"]:
        seal_size = int(spec["tracker"]["seal"]["size"])
        top_outset = int(spec["tracker"]["seal"]["top_outset"])
        tracker_seal = [
            (int(width) - seal_size) // 2,
            -top_outset,
            seal_size,
            seal_size,
        ]
        tracker_checks.append(
            {
                "width": int(width),
                "hub_seal_box": tracker_seal,
                "horizontally_centered": tracker_seal[0] * 2 + seal_size
                in (int(width), int(width) - 1),
                "bottom_aligns_with_content_start": tracker_seal[1]
                + tracker_seal[3]
                == int(spec["tracker"]["panel_height"]),
                "does_not_overlap_list_content": tracker_seal[1]
                + tracker_seal[3]
                <= int(spec["tracker"]["panel_height"]),
            }
        )
    checks = {
        "quest_log_seal_inside_frame": contains(frame, quest_log_seal),
        "quest_log_seal_overlaps_list_safe_region": overlaps(
            quest_log_seal, ql["layout"]["list"]
        ),
        "quest_log_seal_overlaps_detail_safe_region": overlaps(
            quest_log_seal, ql["layout"]["detail"]
        ),
        "quest_log_seal_overlaps_bottom_action_band": overlaps(
            quest_log_seal, ql["layout"]["bottom_action_band"]
        ),
        "quest_log_seal_overlaps_provider_bottom_band": overlaps(
            quest_log_seal, ql["layout"]["provider_bottom_band"]
        ),
        "quest_log_seal_overlaps_close_box": overlaps(
            quest_log_seal, ql["layout"]["close_box"]
        ),
        "tracker_widths": tracker_checks,
        "new_runtime_frames": int(spec["constraints"]["new_runtime_frames"]),
        "new_current_hitboxes": int(spec["constraints"]["new_current_hitboxes"]),
        "tracker_paper_outsets": spec["constraints"]["tracker_paper_outsets"],
        "tracker_seal_visual_outsets": spec["constraints"]["tracker_seal_visual_outsets"],
        "tracker_screen_safe_top_margin_required": int(
            spec["constraints"]["tracker_screen_safe_top_margin_required"]
        ),
        "runtime_screen_clamp_gate": "pending-adapter-implementation",
        "provider_buttons_hidden_before_functional_parity": spec["constraints"][
            "provider_buttons_hidden_before_functional_parity"
        ],
    }
    passed = (
        checks["quest_log_seal_inside_frame"]
        and not checks["quest_log_seal_overlaps_list_safe_region"]
        and not checks["quest_log_seal_overlaps_detail_safe_region"]
        and not checks["quest_log_seal_overlaps_bottom_action_band"]
        and not checks["quest_log_seal_overlaps_provider_bottom_band"]
        and not checks["quest_log_seal_overlaps_close_box"]
        and all(
            item["horizontally_centered"]
            and item["bottom_aligns_with_content_start"]
            and item["does_not_overlap_list_content"]
            for item in tracker_checks
        )
        and checks["new_runtime_frames"] == 0
        and checks["new_current_hitboxes"] == 0
        and checks["tracker_paper_outsets"] == [0, 0, 0, 0]
        and checks["tracker_seal_visual_outsets"] == [0, 0, 18, 0]
        and checks["tracker_screen_safe_top_margin_required"] == 18
        and checks["provider_buttons_hidden_before_functional_parity"] is False
    )
    payload = {
        "schema": "aeui.quest-seals.simulation-report.v1",
        "version": spec["version"],
        "imagegen_calls": 0,
        "local_render_errors": 0,
        "overall": "pass" if passed else "fail",
        "checks": checks,
        "outputs": {
            "ingame": {
                "path": spec["outputs"]["ingame"],
                "sha256": sha256(ingame),
                "size": [1536, 1024],
                "mode": "RGBA",
            },
            "contract": {
                "path": spec["outputs"]["contract"],
                "sha256": sha256(contract),
                "size": [1536, 1024],
                "mode": "RGBA",
            },
        },
    }
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(ingame)
    print(contract)
    print(report)


if __name__ == "__main__":
    main()
