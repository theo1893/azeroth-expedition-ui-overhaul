#!/usr/bin/env python3
"""Render the deterministic, non-production pfUI raid-frame direction preview."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SPEC = ROOT / "tools/specs/unitframes_raid_simulation_v1.json"
HEALTH_RUNTIME = (
    ROOT / "addon/AzerothExpeditionUI/Media/UnitFrames/UnitFrameHealthFillV1.tga"
)
POWER_RUNTIME = (
    ROOT / "addon/AzerothExpeditionUI/Media/UnitFrames/UnitFramePowerFillV1.tga"
)

NAMES = [
    "铁壁", "月桂", "灰烬", "晨星", "霜枝", "暮钟", "长风", "石歌", "赤砂", "银羽",
    "铜炉", "夜潮", "苔痕", "远岚", "旧弦", "微光", "断矛", "松烟", "白鹿", "沉舟",
    "鹿角", "黑松", "寒砧", "白桦", "烛影", "山雀", "雷痕", "苍岩", "雾铃", "赤铜",
    "长夜", "野火", "风桅", "暮鸦", "星屑", "冻土", "旧盾", "晨露", "岩盐", "旅歌",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=Path, default=DEFAULT_SPEC)
    return parser.parse_args()


def rgba(value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    raw = value.lstrip("#")
    return tuple(int(raw[index:index + 2], 16) for index in (0, 2, 4)) + (alpha,)


def font(path: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(ROOT / path), size)


def tint_runtime(
    path: Path,
    size: tuple[int, int],
    tint: tuple[int, int, int, int],
) -> Image.Image:
    source = Image.open(path).convert("RGBA").resize(size, Image.Resampling.LANCZOS)
    tint_layer = Image.new("RGBA", size, tint)
    coloured = ImageChops.multiply(source, tint_layer)
    coloured.putalpha(source.getchannel("A"))
    return coloured


def sc(points: list[tuple[int, int]], scale: int) -> list[tuple[int, int]]:
    return [(x * scale, y * scale) for x, y in points]


def draw_shell(
    draw: ImageDraw.ImageDraw,
    width: int,
    scale: int,
    variant: str,
    palette: dict[str, str],
) -> None:
    # Logical shell is 4 px wider and 4 px taller than the 70x33 provider button.
    height = 37
    outer_by_variant = {
        "A": [(1, 4), (3, 2), (18, 2), (27, 1), (width - 19, 2), (width - 3, 3), (width, 6), (width - 1, 31), (width - 4, 36), (width - 24, 37), (17, 36), (2, 35), (0, 31), (1, 4)],
        "B": [(0, 5), (4, 2), (22, 2), (35, 1), (width - 11, 2), (width - 2, 5), (width, 13), (width - 1, 32), (width - 6, 36), (width - 31, 36), (width - 43, 37), (3, 35), (1, 29), (0, 5)],
        "C": [(1, 3), (10, 2), (21, 1), (width - 35, 2), (width - 4, 2), (width, 7), (width - 2, 25), (width, 31), (width - 4, 36), (width - 29, 37), (31, 36), (5, 37), (0, 32), (1, 3)],
        "D": [(2, 4), (5, 2), (29, 2), (43, 1), (width - 20, 2), (width - 2, 4), (width, 9), (width - 1, 30), (width - 5, 35), (width - 16, 37), (width - 41, 36), (13, 37), (1, 34), (0, 9), (2, 4)],
    }
    outer = outer_by_variant[variant]
    draw.polygon(
        sc(outer, scale),
        fill=rgba(palette["leather_dark"]),
        outline=(13, 8, 5, 255),
    )

    # This liner is behind live status bars. It is not a baked health/power state.
    draw.rectangle(
        (2 * scale, 2 * scale, (width - 2) * scale - 1, 35 * scale - 1),
        fill=rgba(palette["liner"]),
    )
    draw.polygon(
        sc([(3, 5), (width // 3, 4), (width // 2, 8), (width // 3, 13), (3, 12)], scale),
        fill=(70, 46, 29, 62),
    )
    draw.polygon(
        sc([(width // 2, 20), (width - 3, 17), (width - 3, 28), (width * 2 // 3, 31)], scale),
        fill=(54, 36, 24, 52),
    )
    worn = rgba(palette["leather_worn"], 220)
    mid = rgba(palette["leather_mid"], 230)
    draw.line(sc([(4, 3), (18, 2), (31, 3)], scale), fill=worn, width=max(1, scale))
    draw.line(sc([(width - 31, 3), (width - 13, 2), (width - 4, 4)], scale), fill=mid, width=max(1, scale))
    draw.line(sc([(8, 35), (24, 36), (39, 35)], scale), fill=mid, width=max(1, scale))

    brass = rgba(palette["brass_dim"])
    stitch = rgba(palette["stitch"])
    if variant == "A":
        draw.line(sc([(width - 13, 35), (width - 10, 32)], scale), fill=stitch, width=max(1, scale))
        draw.line(sc([(width - 8, 35), (width - 6, 32)], scale), fill=stitch, width=max(1, scale))
        draw.line(sc([(3, 3), (7, 2)], scale), fill=worn, width=max(1, scale))
    elif variant == "B":
        draw.ellipse(
            ((width - 7) * scale, 2 * scale, (width - 4) * scale, 5 * scale),
            fill=brass,
        )
        draw.line(sc([(24, 36), (33, 35)], scale), fill=(91, 53, 27, 255), width=max(1, scale))
    elif variant == "C":
        draw.polygon(sc([(0, 12), (3, 9), (4, 25), (1, 28)], scale), fill=rgba(palette["leather_mid"]))
        draw.line(sc([(3, 13), (5, 16)], scale), fill=stitch, width=max(1, scale))
        draw.line(sc([(3, 21), (5, 24)], scale), fill=stitch, width=max(1, scale))
    else:
        draw.polygon(
            sc([(width - 8, 2), (width - 3, 4), (width - 4, 10), (width - 9, 8)], scale),
            fill=brass,
        )
        draw.line(sc([(2, 32), (6, 35), (10, 34)], scale), fill=(87, 48, 26, 255), width=max(1, scale))


def paste_bar(
    tile: Image.Image,
    path: Path,
    box: tuple[int, int, int, int],
    fraction: float,
    tint: tuple[int, int, int, int],
) -> int:
    x0, y0, x1, y1 = box
    fill_width = max(0, min(x1 - x0, round((x1 - x0) * fraction)))
    if fill_width:
        material = tint_runtime(path, (fill_width, y1 - y0), tint)
        tile.alpha_composite(material, (x0, y0))
    return fill_width


def state_for(spec: dict, index: int) -> dict[str, object]:
    distribution = spec["state_distribution"]
    result: dict[str, object] = {}
    for key in (
        "hover", "aggro", "out_of_range", "offline", "dead",
        "incoming_heal", "resurrection", "buff_indicators",
        "debuff_magic", "debuff_poison", "leader", "master_looter",
    ):
        result[key] = index in distribution[key]
    result["raid_marker"] = distribution["raid_markers"].get(str(index))
    return result


def render_member(
    spec: dict,
    index: int,
    scale: int = 1,
    width: int = 70,
    variant: str | None = None,
    state_override: dict[str, object] | None = None,
    name: str | None = None,
) -> Image.Image:
    palette = spec["palette"]
    variant = variant or spec["architecture"]["variant_slot_order"][index - 1]
    state = state_for(spec, index)
    if state_override:
        state.update(state_override)

    tile = Image.new("RGBA", ((width + 4) * scale, 39 * scale), (0, 0, 0, 0))
    draw = ImageDraw.Draw(tile, "RGBA")
    shell_width = width + 4
    draw_shell(draw, shell_width, scale, variant, palette)

    hp_fraction = 0.34 + ((index * 37) % 63) / 100
    if state["dead"]:
        hp_fraction = 0.0
    if hp_fraction > 0.67:
        health_tint = rgba(palette["health_full"])
    elif hp_fraction > 0.35:
        health_tint = rgba(palette["health_mid"])
    else:
        health_tint = rgba(palette["health_low"])

    power_ids = ("mana", "rage", "energy", "focus")
    power_id = power_ids[(index - 1) % len(power_ids)]
    power_fraction = 0.28 + ((index * 19) % 69) / 100
    hp_box = (2 * scale, 4 * scale, (width + 2) * scale, 34 * scale)
    power_box = (2 * scale, 35 * scale, (width + 2) * scale, 37 * scale)
    hp_width = paste_bar(tile, HEALTH_RUNTIME, hp_box, hp_fraction, health_tint)
    paste_bar(tile, POWER_RUNTIME, power_box, power_fraction, rgba(palette[power_id]))

    draw = ImageDraw.Draw(tile, "RGBA")
    if state["incoming_heal"] and hp_fraction < 0.88:
        start = 2 * scale + hp_width
        end = min((width + 2) * scale, start + 9 * scale)
        draw.rectangle((start, 4 * scale, end, 34 * scale - 1), fill=(80, 154, 73, 110))

    # State responses are short broken edges, not full modern glows.
    if state["aggro"]:
        aggro = rgba(palette["aggro"], 225)
        draw.line(sc([(0, 7), (1, 20), (0, 28)], scale), fill=aggro, width=max(1, scale))
        draw.line(sc([(shell_width - 16, 36), (shell_width - 4, 35)], scale), fill=aggro, width=max(1, scale))
    if state["hover"]:
        hover = rgba(palette["hover"], 210)
        draw.line(sc([(5, 2), (18, 1), (27, 2)], scale), fill=hover, width=max(1, scale))
        draw.line(sc([(shell_width - 20, 36), (shell_width - 7, 35)], scale), fill=hover, width=max(1, scale))
    if state.get("combat"):
        draw.polygon(sc([(2, 4), (8, 4), (8, 10), (5, 8), (2, 10)], scale), fill=(173, 140, 59, 230))

    label_font = font(spec["provider"]["font"]["simulation_fallback"], 10 * scale)
    label = name or NAMES[index - 1]
    draw.text(
        ((width + 4) * scale // 2, 19 * scale),
        label,
        font=label_font,
        fill=(238, 226, 194, 255),
        stroke_width=max(1, scale // 2),
        stroke_fill=(19, 13, 9, 235),
        anchor="mm",
    )

    if state["buff_indicators"]:
        colours = ((69, 105, 148, 255), (115, 81, 139, 255), (93, 124, 69, 255))
        for pos, icon_colour in enumerate(colours):
            x0 = (2 + pos * 10) * scale
            draw.rectangle((x0, 4 * scale, x0 + 9 * scale - 1, 13 * scale - 1), fill=(18, 13, 10, 245))
            draw.rectangle((x0 + scale, 5 * scale, x0 + 8 * scale - 1, 12 * scale - 1), fill=icon_colour)
    if state["debuff_magic"] or state["debuff_poison"]:
        icon_colour = rgba(palette["magic"] if state["debuff_magic"] else palette["poison"])
        draw.rectangle((27 * scale, 9 * scale, 47 * scale - 1, 29 * scale - 1), fill=(17, 12, 9, 245))
        draw.rectangle((28 * scale, 10 * scale, 46 * scale - 1, 28 * scale - 1), fill=icon_colour)
        draw.line(sc([(31, 25), (43, 13)], scale), fill=(218, 220, 199, 210), width=max(1, scale))

    marker = state["raid_marker"]
    if marker:
        cx = (width + 4) * scale // 2
        if marker == "star":
            points = [(37, 0), (39, 4), (43, 4), (40, 7), (41, 12), (37, 9), (33, 12), (34, 7), (31, 4), (35, 4)]
            draw.polygon(sc([(x - 37 + (width + 4) // 2, y) for x, y in points], scale), fill=(222, 187, 55, 255), outline=(60, 39, 18, 255))
        elif marker == "triangle":
            draw.polygon([(cx, 0), (cx + 6 * scale, 12 * scale), (cx - 6 * scale, 12 * scale)], fill=(78, 170, 82, 255), outline=(31, 53, 26, 255))
        else:
            draw.ellipse((cx - 6 * scale, 0, cx + 6 * scale, 11 * scale), fill=(204, 204, 194, 255), outline=(55, 48, 42, 255))
            draw.rectangle((cx - 3 * scale, 7 * scale, cx + 3 * scale, 12 * scale), fill=(204, 204, 194, 255))

    if state["leader"]:
        draw.polygon(sc([(1, 3), (5, 3), (6, 8), (3, 6), (1, 8)], scale), fill=(224, 180, 60, 255), outline=(62, 43, 19, 255))
    if state["master_looter"]:
        draw.ellipse((0, 17 * scale, 7 * scale, 24 * scale), fill=(131, 113, 62, 255), outline=(32, 25, 17, 255))
    if state["resurrection"]:
        cx, cy = (width + 4) * scale // 2, 17 * scale
        draw.ellipse((cx - 15 * scale, cy - 15 * scale, cx + 15 * scale, cy + 15 * scale), fill=(28, 38, 34, 210), outline=(165, 183, 127, 235), width=max(1, scale))
        draw.line((cx, cy - 9 * scale, cx, cy + 9 * scale), fill=(205, 220, 166, 245), width=max(1, 3 * scale))
        draw.line((cx - 7 * scale, cy, cx + 7 * scale, cy), fill=(205, 220, 166, 245), width=max(1, 3 * scale))

    opacity = 1.0
    if state["offline"]:
        opacity = spec["provider"]["profile_states"]["offline_alpha"]
    elif state["out_of_range"]:
        opacity = spec["provider"]["profile_states"]["range_alpha"]
    if opacity < 1:
        tile.putalpha(tile.getchannel("A").point(lambda value: round(value * opacity)))
    return tile


def compose_cluster(spec: dict, count: int = 40) -> Image.Image:
    columns = max(1, (count + 3) // 4)
    width = (columns - 1) * 77 + 74
    cluster = Image.new("RGBA", (width, 159), (0, 0, 0, 0))
    for index in range(1, count + 1):
        column = (index - 1) // 4
        row_from_bottom = (index - 1) % 4
        tile = render_member(spec, index)
        cluster.alpha_composite(tile, (column * 77, (3 - row_from_bottom) * 40))
    return cluster


def draw_world(image: Image.Image) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle((0, 0, image.width, image.height), fill=(13, 16, 18, 255))
    for y in range(100, image.height - 190, 52):
        shift = 42 if (y // 52) % 2 else 0
        for x in range(-70 + shift, image.width, 118):
            draw.polygon([(x, y + 3), (x + 106, y), (x + 111, y + 44), (x + 6, y + 49)], fill=(24, 27, 28, 255), outline=(40, 39, 34, 255))
    draw.ellipse((590, 290, 1040, 650), fill=(30, 34, 35, 165), outline=(45, 46, 42, 180), width=5)
    draw.polygon([(770, 245), (820, 188), (871, 246), (847, 385), (790, 385)], fill=(39, 43, 42, 190), outline=(67, 63, 51, 220))


def draw_neighbour_ui(image: Image.Image, spec: dict) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    palette = spec["palette"]
    body_font = font(spec["provider"]["font"]["simulation_fallback"], 12)

    # Current chat module represented as an old open field book at its true 360x250 profile box.
    draw.polygon([(0, 658), (12, 650), (348, 650), (360, 660), (357, 900), (5, 900)], fill=rgba(palette["leather_dark"]), outline=rgba(palette["brass_dim"]))
    draw.polygon([(14, 666), (346, 662), (349, 892), (12, 895)], fill=(62, 49, 36, 255), outline=(109, 77, 43, 255))
    draw.text((25, 684), "[团队] 第一组就位，等待开怪。", font=body_font, fill=(231, 132, 53, 255))
    draw.text((25, 708), "[公会] 药剂与灵魂石已确认。", font=body_font, fill=(84, 194, 94, 255))
    draw.text((25, 732), "[小队] 治疗注意主坦。", font=body_font, fill=(164, 154, 229, 255))

    # Classic action bar silhouette with two gryphon-like end masses.
    bar_x, bar_y = 475, 844
    for index in range(12):
        x = bar_x + index * 42
        draw.rectangle((x, bar_y, x + 37, bar_y + 37), fill=(49, 37, 27, 255), outline=(105, 78, 39, 255), width=2)
        draw.rectangle((x + 5, bar_y + 5, x + 32, bar_y + 32), fill=((54 + index * 12) % 120, 52, 76, 255))
    draw.polygon([(427, 874), (451, 836), (476, 851), (463, 897), (438, 892)], fill=(91, 66, 35, 255), outline=(130, 99, 51, 255))
    draw.polygon([(981, 851), (1006, 836), (1030, 874), (1019, 892), (994, 897)], fill=(91, 66, 35, 255), outline=(130, 99, 51, 255))

    # Compact compass placeholder for the current map direction.
    cx, cy = 1492, 96
    draw.ellipse((cx - 55, cy - 55, cx + 55, cy + 55), fill=(31, 25, 18, 235), outline=(111, 82, 42, 255), width=5)
    draw.polygon([(cx, cy - 42), (cx + 8, cy), (cx, cy + 34), (cx - 8, cy)], fill=(116, 89, 49, 255))


def render_scene(spec: dict) -> Image.Image:
    image = Image.new("RGBA", (1600, 900), (0, 0, 0, 255))
    draw_world(image)
    draw_neighbour_ui(image, spec)
    draw = ImageDraw.Draw(image, "RGBA")
    title = font("addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf", 25)
    note = font(spec["provider"]["font"]["simulation_fallback"], 13)
    draw.text((34, 28), "UF-RAID-SIM-V1 · 40 人团队框架预演", font=title, fill=(218, 186, 119, 255))
    draw.text((36, 66), "真实 70×33 Button / 10×4 VERTICAL / 40 个对象；无整团外框。新外壳仅为几何方向，ImageGen 0/0。", font=note, fill=(178, 168, 147, 255))

    cluster = compose_cluster(spec, 40)
    provider = spec["provider"]
    visual_h = provider["visual_cluster_bbox_with_shell_and_markers"][1]
    cluster_y = image.height - (provider["screen_anchor"]["resolved_y"] - 2) - visual_h
    image.alpha_composite(cluster, (0, cluster_y))
    draw.text((10, cluster_y - 22), "pfRaid1..40 · 当前仓库 profile 的真实位置与密度", font=note, fill=(193, 173, 132, 255))
    draw.text((1045, 820), "Chat／动作条／罗盘仅作当前相邻 UI 的确定性占位", font=note, fill=(145, 136, 121, 255))
    return image


def render_review(spec: dict) -> Image.Image:
    image = Image.new("RGBA", (1700, 1050), (20, 18, 16, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    title = font("addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf", 27)
    label = font(spec["provider"]["font"]["simulation_fallback"], 15)
    small = font(spec["provider"]["font"]["simulation_fallback"], 12)
    draw.text((36, 25), "团队成员条：四个粗糙变体、动态状态与真实重复密度", font=title, fill=(219, 187, 118, 255))
    draw.text((38, 64), "每个框仍是独立 Secure Button；外观来自轻薄旧皮革夹边，不把 40 人包进新的书框或面板。", font=label, fill=(178, 166, 143, 255))

    variants = ("A", "B", "C", "D")
    for pos, variant in enumerate(variants):
        tile = render_member(
            spec,
            pos + 1,
            scale=4,
            variant=variant,
            state_override={
                "hover": False, "aggro": False, "out_of_range": False,
                "offline": False, "dead": False, "incoming_heal": False,
                "resurrection": False, "buff_indicators": False,
                "debuff_magic": False, "debuff_poison": False,
                "raid_marker": None, "leader": False, "master_looter": False,
            },
            name=f"变体 {variant}",
        )
        x = 42 + pos * 405
        image.alpha_composite(tile, (x, 112))
        draw.text((x, 276), spec["variant_direction"][variant], font=small, fill=(184, 163, 128, 255))

    draw.text((40, 326), "状态层（2×；外壳不烘焙状态）", font=label, fill=(211, 179, 111, 255))
    state_examples = [
        ("普通", {}),
        ("悬停", {"hover": True}),
        ("仇恨", {"aggro": True}),
        ("距离外", {"out_of_range": True}),
        ("离线", {"offline": True, "out_of_range": False}),
        ("可驱散", {"debuff_magic": True}),
        ("复活中", {"dead": True, "resurrection": True}),
        ("战斗角标", {"combat": True}),
    ]
    reset = {
        "hover": False, "aggro": False, "out_of_range": False,
        "offline": False, "dead": False, "incoming_heal": False,
        "resurrection": False, "buff_indicators": False,
        "debuff_magic": False, "debuff_poison": False,
        "raid_marker": None, "leader": False, "master_looter": False,
    }
    for pos, (state_name, changes) in enumerate(state_examples):
        override = dict(reset)
        override.update(changes)
        tile = render_member(spec, pos + 1, scale=2, state_override=override, name=state_name)
        x = 42 + pos * 202
        image.alpha_composite(tile, (x, 362))
        draw.text((x + 74, 449), state_name, font=small, fill=(188, 171, 139, 255), anchor="ma")

    draw.text((40, 500), "可选 Group N 标签（当前 raidgrouplabel=0，因此主预演不显示）", font=label, fill=(211, 179, 111, 255))
    draw.polygon([(44, 536), (52, 529), (168, 531), (177, 538), (171, 559), (48, 560)], fill=(61, 42, 28, 255), outline=(99, 72, 41, 255))
    draw.line((63, 533, 69, 558), fill=(126, 91, 59, 255), width=2)
    draw.text((110, 544), "Group 1", font=label, fill=(223, 208, 174, 255), anchor="mm")
    draw.text((216, 544), "现阶段只登记对象，不进入正式资产生成；避免为默认关闭的配置增加视觉噪声。", font=small, fill=(164, 153, 134, 255), anchor="lm")

    draw.text((40, 610), "真实 100% 排版：40 个成员对象 / 767×159 视觉包络 / 无共享外框", font=label, fill=(211, 179, 111, 255))
    cluster = compose_cluster(spec, 40)
    image.alpha_composite(cluster, (42, 650))
    draw.rectangle((846, 650, 1650, 850), outline=(70, 58, 43, 255), width=1)
    draw.text((868, 675), "结构要点", font=label, fill=(204, 177, 118, 255))
    notes = [
        "· 皮革只形成 2px 外夹边；单个成员不会变成厚重卡片。",
        "· 四变体按 pfRaid 槽位固定分配，换人时美术不会跳动。",
        "· Health / Power 使用已接受的真实 runtime 纹理并由 pfUI 乘色。",
        "· Hover / Aggro 只亮两三段破边，删除当前完整矩形 glow。",
        "· Buff、Debuff、复活、队长、拾取与 Raid Icon 继续是动态层。",
        "· 全局 UI Scale 同步缩放；配置高度偏离 33px 时局部回退 pfUI。",
    ]
    for row, text_value in enumerate(notes):
        draw.text((868, 711 + row * 22), text_value, font=small, fill=(174, 161, 139, 255))

    draw.text((42, 880), "该图只确认布局、隐喻、层级、综合色重和状态密度；不能作为 source/runtime，也不会上传给生图模型。", font=label, fill=(178, 164, 141, 255))
    draw.text((42, 916), "下一门禁：用户确认 UF-RAID-SIM-V1 后，再写完整 production prompt；当前正式 ImageGen 仍为 0/0。", font=label, fill=(206, 177, 116, 255))
    return image


def main() -> None:
    args = parse_args()
    spec = json.loads(args.spec.resolve().read_text(encoding="utf-8"))
    for role, rendered in (("scene", render_scene(spec)), ("review", render_review(spec))):
        output = ROOT / spec["outputs"][role]
        output.parent.mkdir(parents=True, exist_ok=True)
        rendered.save(output, format="PNG", optimize=False, compress_level=9)
        print(output.resolve())


if __name__ == "__main__":
    main()
