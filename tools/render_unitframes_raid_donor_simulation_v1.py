#!/usr/bin/env python3
"""Render UF-RAID-A2 using exact shells and real 40-member layout geometry."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont

from build_unitframes_raid_donor_shells_v1 import (
    ShellSet,
    build_shells,
    render_source_preview,
    save_shell_set,
    synthetic_materials,
)


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SPEC = ROOT / "tools/specs/unitframes_raid_donor_simulation_v1.json"
HEALTH_RUNTIME = ROOT / "addon/AzerothExpeditionUI/Media/UnitFrames/UnitFrameHealthFillV1.tga"
POWER_RUNTIME = ROOT / "addon/AzerothExpeditionUI/Media/UnitFrames/UnitFramePowerFillV1.tga"

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


def get_font(path: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(ROOT / path), size)


def tint_runtime(path: Path, size: tuple[int, int], tint: tuple[int, int, int, int]) -> Image.Image:
    source = Image.open(path).convert("RGBA").resize(size, Image.Resampling.LANCZOS)
    layer = Image.new("RGBA", size, tint)
    coloured = ImageChops.multiply(source, layer)
    coloured.putalpha(source.getchannel("A"))
    return coloured


def state_for(spec: dict, index: int) -> dict[str, object]:
    distribution = spec["simulation"]["state_distribution"]
    result: dict[str, object] = {}
    for key in (
        "hover", "aggro", "out_of_range", "offline", "dead", "incoming_heal",
        "resurrection", "buff_indicators", "debuff_magic", "debuff_poison",
        "leader", "master_looter",
    ):
        result[key] = index in distribution[key]
    result["raid_marker"] = distribution["raid_markers"].get(str(index))
    return result


def _paste_bar(
    tile: Image.Image,
    path: Path,
    box: tuple[int, int, int, int],
    fraction: float,
    tint: tuple[int, int, int, int],
) -> int:
    x0, y0, x1, y1 = box
    fill_width = max(0, min(x1 - x0, round((x1 - x0) * fraction)))
    if fill_width:
        tile.alpha_composite(tint_runtime(path, (fill_width, y1 - y0), tint), (x0, y0))
    return fill_width


def render_member(
    spec: dict,
    shells: ShellSet,
    index: int,
    variant: str | None = None,
    state_override: dict[str, object] | None = None,
    name: str | None = None,
    display_scale: int = 1,
) -> Image.Image:
    palette = spec["simulation"]["palette"]
    variant = variant or spec["simulation"]["variant_slot_order"][index - 1]
    state = state_for(spec, index)
    if state_override:
        state.update(state_override)

    tile = Image.new("RGBA", (74, 39), (0, 0, 0, 0))
    tile.alpha_composite(shells.runtimes[variant], (0, 2))

    hp_fraction = 0.34 + ((index * 37) % 63) / 100
    if state["dead"]:
        hp_fraction = 0.0
    if hp_fraction > 0.67:
        hp_colour = rgba(palette["health_full"])
    elif hp_fraction > 0.35:
        hp_colour = rgba(palette["health_mid"])
    else:
        hp_colour = rgba(palette["health_low"])

    power_ids = ("mana", "rage", "energy", "focus")
    power_id = power_ids[(index - 1) % len(power_ids)]
    power_fraction = 0.28 + ((index * 19) % 69) / 100
    hp_width = _paste_bar(tile, HEALTH_RUNTIME, (2, 4, 72, 34), hp_fraction, hp_colour)
    _paste_bar(tile, POWER_RUNTIME, (2, 35, 72, 37), power_fraction, rgba(palette[power_id]))

    draw = ImageDraw.Draw(tile, "RGBA")
    if state["incoming_heal"] and hp_fraction < 0.88:
        draw.rectangle((2 + hp_width, 4, min(72, 2 + hp_width + 9), 33), fill=(80, 154, 73, 110))

    # State accents remain live overlays and never enter the donor or shell source.
    if state["aggro"]:
        draw.line(((0, 9), (1, 22), (0, 30)), fill=rgba(palette["aggro"], 230), width=1)
        draw.line(((58, 38), (70, 37)), fill=rgba(palette["aggro"], 230), width=1)
    if state["hover"]:
        draw.line(((5, 2), (18, 1), (27, 2)), fill=rgba(palette["hover"], 215), width=1)
        draw.line(((54, 38), (67, 37)), fill=rgba(palette["hover"], 215), width=1)
    if state.get("combat"):
        draw.polygon(((2, 4), (8, 4), (8, 10), (5, 8), (2, 10)), fill=(173, 140, 59, 230))

    label = name or NAMES[index - 1]
    label_font = get_font(spec["provider"]["font"], 10)
    draw.text(
        (37, 19), label, font=label_font, fill=(238, 226, 194, 255),
        stroke_width=1, stroke_fill=(19, 13, 9, 235), anchor="mm",
    )

    if state["buff_indicators"]:
        colours = ((69, 105, 148, 255), (115, 81, 139, 255), (93, 124, 69, 255))
        for position, icon_colour in enumerate(colours):
            x = 2 + position * 10
            draw.rectangle((x, 4, x + 8, 12), fill=(18, 13, 10, 245))
            draw.rectangle((x + 1, 5, x + 7, 11), fill=icon_colour)
    if state["debuff_magic"] or state["debuff_poison"]:
        colour = rgba(palette["magic"] if state["debuff_magic"] else palette["poison"])
        draw.rectangle((27, 9, 46, 28), fill=(17, 12, 9, 245))
        draw.rectangle((28, 10, 45, 27), fill=colour)
        draw.line(((31, 25), (43, 13)), fill=(218, 220, 199, 210), width=1)

    marker = state["raid_marker"]
    if marker == "star":
        draw.polygon(
            ((37, 0), (39, 4), (43, 4), (40, 7), (41, 12), (37, 9),
             (33, 12), (34, 7), (31, 4), (35, 4)),
            fill=(222, 187, 55, 255), outline=(60, 39, 18, 255),
        )
    elif marker == "triangle":
        draw.polygon(((37, 0), (43, 12), (31, 12)), fill=(78, 170, 82, 255), outline=(31, 53, 26, 255))
    elif marker == "skull":
        draw.ellipse((31, 0, 43, 11), fill=(204, 204, 194, 255), outline=(55, 48, 42, 255))
        draw.rectangle((34, 7, 40, 12), fill=(204, 204, 194, 255))

    if state["leader"]:
        draw.polygon(((1, 3), (5, 3), (6, 8), (3, 6), (1, 8)), fill=(224, 180, 60, 255), outline=(62, 43, 19, 255))
    if state["master_looter"]:
        draw.ellipse((0, 17, 7, 24), fill=(131, 113, 62, 255), outline=(32, 25, 17, 255))
    if state["resurrection"]:
        draw.ellipse((22, 2, 52, 32), fill=(28, 38, 34, 210), outline=(165, 183, 127, 235), width=1)
        draw.line(((37, 8), (37, 26)), fill=(205, 220, 166, 245), width=3)
        draw.line(((30, 17), (44, 17)), fill=(205, 220, 166, 245), width=3)

    opacity = 1.0
    if state["offline"]:
        opacity = 0.25
    elif state["out_of_range"]:
        opacity = 0.40
    if opacity < 1:
        tile.putalpha(tile.getchannel("A").point(lambda value: round(value * opacity)))
    if display_scale != 1:
        tile = tile.resize((74 * display_scale, 39 * display_scale), Image.Resampling.NEAREST)
    return tile


def compose_cluster(spec: dict, shells: ShellSet, count: int = 40) -> Image.Image:
    columns = max(1, (count + 3) // 4)
    cluster = Image.new("RGBA", ((columns - 1) * 77 + 74, 159), (0, 0, 0, 0))
    for index in range(1, count + 1):
        column = (index - 1) // 4
        row_from_bottom = (index - 1) % 4
        cluster.alpha_composite(render_member(spec, shells, index), (column * 77, (3 - row_from_bottom) * 40))
    return cluster


def draw_world(image: Image.Image) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle((0, 0, image.width, image.height), fill=(13, 16, 18, 255))
    for y in range(100, image.height - 190, 52):
        shift = 42 if (y // 52) % 2 else 0
        for x in range(-70 + shift, image.width, 118):
            draw.polygon(
                ((x, y + 3), (x + 106, y), (x + 111, y + 44), (x + 6, y + 49)),
                fill=(24, 27, 28, 255), outline=(40, 39, 34, 255),
            )
    draw.ellipse((590, 290, 1040, 650), fill=(30, 34, 35, 165), outline=(45, 46, 42, 180), width=5)
    draw.polygon(((770, 245), (820, 188), (871, 246), (847, 385), (790, 385)), fill=(39, 43, 42, 190), outline=(67, 63, 51, 220))


def draw_neighbour_ui(image: Image.Image, spec: dict) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    body = get_font(spec["provider"]["font"], 12)
    draw.polygon(((0, 658), (12, 650), (348, 650), (360, 660), (357, 900), (5, 900)), fill=(30, 20, 14, 255), outline=(91, 68, 35, 255))
    draw.polygon(((14, 666), (346, 662), (349, 892), (12, 895)), fill=(62, 49, 36, 255), outline=(109, 77, 43, 255))
    draw.text((25, 684), "[团队] 第一组就位，等待开怪。", font=body, fill=(231, 132, 53, 255))
    draw.text((25, 708), "[公会] 药剂与灵魂石已确认。", font=body, fill=(84, 194, 94, 255))
    draw.text((25, 732), "[小队] 治疗注意主坦。", font=body, fill=(164, 154, 229, 255))
    bar_x, bar_y = 475, 844
    for index in range(12):
        x = bar_x + index * 42
        draw.rectangle((x, bar_y, x + 37, bar_y + 37), fill=(49, 37, 27, 255), outline=(105, 78, 39, 255), width=2)
        draw.rectangle((x + 5, bar_y + 5, x + 32, bar_y + 32), fill=((54 + index * 12) % 120, 52, 76, 255))
    draw.polygon(((427, 874), (451, 836), (476, 851), (463, 897), (438, 892)), fill=(91, 66, 35, 255), outline=(130, 99, 51, 255))
    draw.polygon(((981, 851), (1006, 836), (1030, 874), (1019, 892), (994, 897)), fill=(91, 66, 35, 255), outline=(130, 99, 51, 255))
    cx, cy = 1492, 96
    draw.ellipse((cx - 55, cy - 55, cx + 55, cy + 55), fill=(31, 25, 18, 235), outline=(111, 82, 42, 255), width=5)
    draw.polygon(((cx, cy - 42), (cx + 8, cy), (cx, cy + 34), (cx - 8, cy)), fill=(116, 89, 49, 255))


def render_scene(spec: dict, shells: ShellSet) -> Image.Image:
    image = Image.new("RGBA", (1600, 900), (0, 0, 0, 255))
    draw_world(image)
    draw_neighbour_ui(image, spec)
    draw = ImageDraw.Draw(image, "RGBA")
    title = get_font("addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf", 25)
    note = get_font(spec["provider"]["font"], 13)
    draw.text((34, 28), "UF-RAID-A2-SIM-V1 · donor / deterministic shell 预演", font=title, fill=(218, 186, 119, 255))
    draw.text((36, 66), "真实 74×39 显示包络 · 10×4 VERTICAL · 40 个对象 · ImageGen 0/0", font=note, fill=(178, 168, 147, 255))
    draw.text((36, 88), "本图只确认精确外壳几何、四种维修位置和运行时密度；粗粝材质为本地占位。", font=note, fill=(164, 151, 129, 255))
    cluster = compose_cluster(spec, shells, 40)
    cluster_y = image.height - (spec["provider"]["screen_anchor"]["resolved_y"] - 2) - 159
    image.alpha_composite(cluster, (0, cluster_y))
    draw.text((10, cluster_y - 22), "pfRaid1..40 · 实际尺寸与状态层", font=note, fill=(193, 173, 132, 255))
    draw.text((1040, 820), "Chat／动作条／罗盘仅作相邻 UI 占位", font=note, fill=(145, 136, 121, 255))
    return image


def render_review(spec: dict, shells: ShellSet) -> Image.Image:
    image = Image.new("RGBA", (1700, 1120), (20, 18, 16, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    title = get_font("addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf", 27)
    label = get_font(spec["provider"]["font"], 15)
    small = get_font(spec["provider"]["font"], 12)
    draw.text((36, 25), "团队框架 A2：模型供材，Python 造壳", font=title, fill=(219, 187, 118, 255))
    draw.text((38, 64), "确认对象：精确轮廓、2px 运行时夹边、A-D 维修差异、动态层级与 40 人密度。", font=label, fill=(178, 166, 143, 255))
    draw.text((38, 88), "不确认对象：当前材质笔触、微纹理与最终色差（这些将由未来一次 material-only donor 提供）。", font=label, fill=(155, 144, 124, 255))

    reset = {
        "hover": False, "aggro": False, "out_of_range": False, "offline": False,
        "dead": False, "incoming_heal": False, "resurrection": False,
        "buff_indicators": False, "debuff_magic": False, "debuff_poison": False,
        "raid_marker": None, "leader": False, "master_looter": False,
    }
    variant_briefs = {
        "A": ("左上浅缺口", "右下两条不等缝补"),
        "B": ("右侧偏心暗铆钉", "右下克制磨痕"),
        "C": ("左侧短皮补丁", "两处乱线修补；无金属"),
        "D": ("右侧歪斜暗铜片", "左下微裂"),
    }
    for position, variant in enumerate(("A", "B", "C", "D")):
        x = 42 + position * 405
        tile = render_member(
            spec, shells, position + 1, variant=variant,
            state_override=reset, name=f"变体 {variant}", display_scale=4,
        )
        image.alpha_composite(tile, (x, 130))
        draw.text((x, 300), variant_briefs[variant][0], font=small, fill=(184, 163, 128, 255))
        draw.text((x, 320), variant_briefs[variant][1], font=small, fill=(158, 145, 122, 255))

    draw.text((40, 354), "状态层（2×；全部仍为动态内容）", font=label, fill=(211, 179, 111, 255))
    examples = [
        ("普通", {}), ("悬停", {"hover": True}), ("仇恨", {"aggro": True}),
        ("距离外", {"out_of_range": True}), ("离线", {"offline": True}),
        ("可驱散", {"debuff_magic": True}),
        ("复活中", {"dead": True, "resurrection": True}),
        ("战斗角标", {"combat": True}),
    ]
    for position, (state_name, changes) in enumerate(examples):
        override = dict(reset)
        override.update(changes)
        x = 42 + position * 202
        image.alpha_composite(
            render_member(spec, shells, position + 1, state_override=override, name=state_name, display_scale=2),
            (x, 392),
        )
        draw.text((x + 74, 480), state_name, font=small, fill=(188, 171, 139, 255), anchor="ma")

    draw.text((40, 532), "真实 100% 排版：40 个独立 Secure Button / 767×159 / 无共享外框", font=label, fill=(211, 179, 111, 255))
    image.alpha_composite(compose_cluster(spec, shells, 40), (42, 570))
    draw.rectangle((846, 570, 1650, 800), outline=(70, 58, 43, 255), width=1)
    draw.text((868, 594), "确定性合同", font=label, fill=(204, 177, 118, 255))
    notes = [
        "· source 592×296 → runtime 74×37，几何由 Python 固定。",
        "· provider Button 固定内缩 source 16px / runtime 2px。",
        "· 水平三切片固定 source 48/496/48 → runtime 6/62/6。",
        "· A：左上浅缺口 + 右下两条不等缝补。",
        "· B：右侧偏心暗铆钉 + 右下克制磨痕。",
        "· C：左侧短皮补丁 + 两处不规则线修，无金属。",
        "· D：右侧歪斜暗黄铜补片 + 左下微裂。",
        "· 名称、血/资源、光环、仇恨、距离与图标不烘焙。",
    ]
    for row, value in enumerate(notes):
        draw.text((868, 630 + row * 22), value, font=small, fill=(174, 161, 139, 255))

    draw.text((42, 835), "运行时局部放大（8×像素预览）", font=label, fill=(211, 179, 111, 255))
    for position, variant in enumerate(("A", "B", "C", "D")):
        runtime = shells.runtimes[variant].resize((296, 148), Image.Resampling.NEAREST)
        x = 42 + position * 405
        checker = Image.new("RGBA", (296, 148), (43, 40, 36, 255))
        checker_draw = ImageDraw.Draw(checker)
        for yy in range(0, 148, 16):
            for xx in range(0, 296, 16):
                if (xx // 16 + yy // 16) % 2:
                    checker_draw.rectangle((xx, yy, xx + 15, yy + 15), fill=(58, 54, 48, 255))
        image.alpha_composite(checker, (x, 872))
        image.alpha_composite(runtime, (x, 872))
        draw.text((x, 1028), f"{variant} · exact 74×37 runtime", font=small, fill=(183, 164, 130, 255))

    draw.text((42, 1068), "Simulation only · ImageGen 0/0 · 未授权 production donor · 不写 source/runtime/addon", font=label, fill=(206, 177, 116, 255))
    return image


def main() -> None:
    args = parse_args()
    spec = json.loads(args.spec.resolve().read_text(encoding="utf-8"))
    shells = build_shells(spec, synthetic_materials(spec))
    output_root = ROOT / "generated/unitframes/raid/simulation/A2-V1"
    save_shell_set(shells, output_root / "shells")
    source_path = ROOT / spec["outputs"]["source_preview"]
    source_path.parent.mkdir(parents=True, exist_ok=True)
    render_source_preview(spec, shells).save(source_path, format="PNG", compress_level=9)
    for role, rendered in (("scene", render_scene(spec, shells)), ("review", render_review(spec, shells))):
        output = ROOT / spec["outputs"][role]
        output.parent.mkdir(parents=True, exist_ok=True)
        rendered.save(output, format="PNG", compress_level=9)
        print(output.resolve())
    print(source_path.resolve())


if __name__ == "__main__":
    main()
