#!/usr/bin/env python3
"""Review exact UF-PRIMARY V4 deterministic Player/Target candidates."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFont, ImageOps

from build_unitframes_primary_v4_candidates_v1 import (
    clear_transparent_rgb,
    role_masks,
    sha256,
)


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SPEC = ROOT / "tools/specs/unitframes_primary_v4_candidate_v1.json"
DEFAULT_DISPLAY = ROOT / "tools/specs/unitframes_primary_v4_candidate_display_region_v1.json"
DISPLAY_VALIDATOR = (
    ROOT / ".codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py"
)
FONT_SANS = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"
FONT_SERIF = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=Path, default=DEFAULT_SPEC)
    parser.add_argument("--display-contract", type=Path, default=DEFAULT_DISPLAY)
    parser.add_argument("--output-dir", type=Path)
    return parser.parse_args()


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size)


def count_nonzero(mask: Image.Image) -> int:
    histogram = mask.convert("L").histogram()
    return sum(histogram[1:])


def transparent_rgb_count(image: Image.Image) -> int:
    red, green, blue, alpha = image.convert("RGBA").split()
    invisible = alpha.point(lambda value: 255 if value == 0 else 0)
    coloured = ImageChops.lighter(red, ImageChops.lighter(green, blue))
    return count_nonzero(ImageChops.multiply(coloured, invisible))


def rgba(hex_value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    raw = hex_value.lstrip("#")
    return tuple(int(raw[index:index + 2], 16) for index in (0, 2, 4)) + (alpha,)


def checker(size: tuple[int, int], step: int = 12) -> Image.Image:
    image = Image.new("RGBA", size, (35, 33, 30, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], step):
        for x in range(0, size[0], step):
            if (x // step + y // step) % 2:
                draw.rectangle((x, y, x + step - 1, y + step - 1), fill=(52, 49, 44, 255))
    return image


def tint_statusbar(path: Path, size: tuple[int, int], tint: tuple[int, int, int]) -> Image.Image:
    source = Image.open(path).convert("RGBA").resize(size, Image.Resampling.LANCZOS)
    colour = Image.new("RGB", size, tint)
    rgb = ImageChops.multiply(source.convert("RGB"), colour)
    rgb = ImageEnhance.Brightness(rgb).enhance(1.34)
    result = rgb.convert("RGBA")
    result.putalpha(source.getchannel("A"))
    return result


def assemble_runtime(runtime: Image.Image, content_width: int) -> Image.Image:
    total_width = content_width + 14
    if content_width == 200:
        return runtime.copy()
    left = runtime.crop((0, 0, 32, 42))
    centre = runtime.crop((32, 0, 182, 42)).resize(
        (total_width - 64, 42), Image.Resampling.LANCZOS
    )
    right = runtime.crop((182, 0, 214, 42))
    output = Image.new("RGBA", (total_width, 42), (0, 0, 0, 0))
    output.alpha_composite(left, (0, 0))
    output.alpha_composite(centre, (32, 0))
    output.alpha_composite(right, (total_width - 32, 0))
    return clear_transparent_rgb(output)


def assemble_state(state: Image.Image, content_width: int) -> Image.Image:
    return assemble_runtime(state, content_width)


def render_unit_frame(
    shell: Image.Image,
    state: Image.Image | None,
    spec: dict,
    content_width: int,
    health_fraction: float,
    health_tint: tuple[int, int, int],
    power_fraction: float,
    power_tint: tuple[int, int, int],
    name: str,
    value: str,
    *,
    text: bool = True,
) -> Image.Image:
    total_width = content_width + 14
    frame = Image.new("RGBA", (total_width, 42), (0, 0, 0, 0))
    if state is not None:
        frame.alpha_composite(assemble_state(state, content_width), (0, 0))
    frame.alpha_composite(assemble_runtime(shell, content_width), (0, 0))

    draw = ImageDraw.Draw(frame, "RGBA")
    hp_box = (7, 6, content_width + 7, 31)
    power_box = (7, 32, content_width + 7, 36)
    draw.rectangle(hp_box, fill=(29, 23, 18, 255))
    draw.rectangle(power_box, fill=(22, 19, 16, 255))
    health = tint_statusbar(
        ROOT / spec["inputs"]["bars"]["health"]["file"],
        (content_width, 25),
        health_tint,
    )
    power = tint_statusbar(
        ROOT / spec["inputs"]["bars"]["power"]["file"],
        (content_width, 4),
        power_tint,
    )
    hp_visible = max(1, min(content_width, round(content_width * health_fraction)))
    power_visible = max(1, min(content_width, round(content_width * power_fraction)))
    frame.alpha_composite(health.crop((0, 0, hp_visible, 25)), (7, 6))
    frame.alpha_composite(power.crop((0, 0, power_visible, 4)), (7, 32))

    if text:
        draw.text((12, 18), name, font=font(FONT_SANS, 10), fill=(238, 222, 183, 255), anchor="lm")
        draw.text((content_width + 2, 18), value, font=font(FONT_SANS, 10), fill=(241, 227, 192, 255), anchor="rm")
    return frame


def draw_world_background(image: Image.Image) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle((0, 0, image.width, image.height), fill=(13, 15, 15, 255))
    for y in range(78, image.height - 125, 49):
        offset = 53 if (y // 49) % 2 else 0
        for x in range(-75 + offset, image.width, 132):
            draw.polygon(
                [(x, y + 4), (x + 119, y), (x + 125, y + 39), (x + 3, y + 44)],
                fill=(22, 24, 23, 255), outline=(36, 34, 29, 255),
            )
    draw.ellipse((610, 170, 1050, 610), outline=(49, 42, 32, 105), width=7)
    draw.rectangle((0, image.height - 128, image.width, image.height), fill=(16, 13, 11, 255))


def place_scaled(
    canvas: Image.Image,
    frame: Image.Image,
    position: tuple[int, int],
    scale: int,
) -> None:
    scaled = frame.resize(
        (frame.width * scale, frame.height * scale),
        Image.Resampling.NEAREST,
    )
    canvas.alpha_composite(scaled, position)


def render_real_layout(
    spec: dict,
    runtimes: dict[str, Image.Image],
    states: dict[str, Image.Image],
) -> Image.Image:
    image = Image.new("RGBA", (1600, 900), (0, 0, 0, 255))
    draw_world_background(image)
    draw = ImageDraw.Draw(image, "RGBA")
    title = font(FONT_SERIF, 23)
    note = font(FONT_SANS, 13)
    draw.text((34, 24), "UF-PRIMARY-V4-CANDIDATE-V1 · 真实排版", font=title, fill=(214, 182, 119, 255))
    draw.text((35, 60), "完整透明候选位于 BACKGROUND；生命／资源条、文字与 Aura 仍由运行时独立绘制。", font=note, fill=(171, 160, 140, 255))

    player = render_unit_frame(
        runtimes["player"], None, spec, 200, 0.82, (104, 137, 78),
        0.68, (82, 111, 168), "纳斯雷兹姆 60", "5234 / 5234",
    )
    target = render_unit_frame(
        runtimes["target"], states["target_aggro"], spec, 200, 0.64,
        (151, 70, 58), 0.47, (158, 73, 66), "黑石勇士 60+", "64%",
    )
    image.alpha_composite(player, (36, 104))
    image.alpha_composite(target, (690, 104))
    draw.text((37, 154), "Player · 1× exact runtime", font=note, fill=(185, 169, 136, 255))
    draw.text((691, 211), "Target · 1× exact runtime + Aura／Cast／Aggro", font=note, fill=(185, 169, 136, 255))

    # Auras and cast information are independent provider objects, shown only to
    # reproduce realistic density and z-order.
    for index, colour in enumerate(((72, 82, 143), (126, 66, 55), (53, 99, 126), (108, 87, 47), (75, 110, 65))):
        x = 696 + index * 25
        draw.rectangle((x, 151, x + 20, 171), fill=colour + (255,), outline=(116, 87, 48, 255))
    draw.rectangle((695, 183, 909, 198), fill=(31, 25, 20, 255), outline=(95, 67, 37, 255))
    draw.rectangle((697, 185, 832, 196), fill=(63, 76, 116, 255))
    draw.text((802, 191), "暗影烈焰 1.4", font=font(FONT_SANS, 10), fill=(233, 218, 183, 255), anchor="mm")

    draw.rounded_rectangle((1015, 91, 1564, 378), radius=6, fill=(20, 18, 15, 236), outline=(91, 67, 39, 255), width=2)
    draw.text((1041, 114), "2× 运行时局部", font=font(FONT_SERIF, 18), fill=(207, 177, 116, 255))
    place_scaled(image, player, (1045, 158), 2)
    place_scaled(image, target, (1045, 257), 2)
    draw.text((1043, 350), "维修在外围；资源条及文字没有被壳体覆盖", font=note, fill=(171, 159, 137, 255))

    # Lightweight neighbours establish the overall UI weight without claiming
    # to reproduce accepted Chat or Action Bar pixels.
    draw.polygon([(17, 652), (350, 646), (359, 887), (13, 890)], fill=(40, 27, 19, 255), outline=(97, 66, 36, 255))
    draw.rectangle((33, 674, 335, 864), fill=(61, 47, 33, 255), outline=(103, 74, 43, 255))
    for index, line in enumerate((
        "[公会] 黑翼之巢 19:30 集合。",
        "[小队] 合剂、灵魂石已准备。",
        "[系统] 你获得了：远征补给。",
    )):
        draw.text((47, 700 + index * 28), line, font=font(FONT_SANS, 12), fill=((98, 188, 99, 255) if index == 0 else (224, 200, 118, 255)))
    for index in range(12):
        x = 498 + index * 44
        draw.rectangle((x, 838, x + 39, 877), fill=(42, 33, 25, 255), outline=(104, 75, 42, 255), width=2)
        draw.rectangle((x + 5, 843, x + 34, 872), fill=((51 + index * 17) % 130, 49, 72, 255))
    draw.text((1190, 849), "邻接 UI 仅为非权威几何占位", font=note, fill=(146, 134, 115, 255))
    return image


def render_real_layout_review(
    spec: dict,
    runtimes: dict[str, Image.Image],
    states: dict[str, Image.Image],
) -> Image.Image:
    image = Image.new("RGBA", (1600, 1220), (20, 19, 17, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    title = font(FONT_SERIF, 25)
    section = font(FONT_SERIF, 18)
    note = font(FONT_SANS, 13)
    small = font(FONT_SANS, 11)
    draw.text((34, 23), "UF-PRIMARY-V4-CANDIDATE-V1 · 多场景审阅板", font=title, fill=(216, 185, 120, 255))
    draw.text((35, 60), "所有框均使用本轮 exact candidate + 已验收 Health／Power；标准宽度不切片，变宽只拉伸中央。", font=note, fill=(171, 159, 138, 255))

    draw.text((42, 103), "A. 四资源与低血量（3×）", font=section, fill=(208, 177, 116, 255))
    power_types = [
        ("法力", (82, 111, 168)), ("怒气", (160, 78, 69)),
        ("集中值", (153, 118, 79)), ("能量", (180, 166, 82)),
    ]
    for index, (label, colour) in enumerate(power_types):
        x = 52 + (index % 2) * 750
        y = 145 + (index // 2) * 168
        frame = render_unit_frame(
            runtimes["player"], states["player_hover"] if index == 2 else None,
            spec, 200, 0.22 if index == 3 else 0.82, (101, 132, 76),
            0.57 + index * 0.07, colour, f"Player · {label}", f"{22 if index == 3 else 82}%",
        )
        place_scaled(image, frame, (x, y), 3)
        draw.text((x, y + 132), f"Player / {label}" + (" / Hover" if index == 2 else ""), font=note, fill=(188, 169, 133, 255))

    draw.line((35, 489, 1565, 489), fill=(69, 56, 40, 255))
    draw.text((42, 512), "B. Target 正常／仇恨与非镜像身份（3×）", font=section, fill=(208, 177, 116, 255))
    target_normal = render_unit_frame(
        runtimes["target"], None, spec, 200, 0.76, (145, 72, 59), 0.61,
        (83, 108, 162), "Target · 普通", "76%",
    )
    target_aggro = render_unit_frame(
        runtimes["target"], states["target_aggro"], spec, 200, 0.61, (151, 67, 55),
        0.44, (160, 72, 64), "Target · Aggro", "61%",
    )
    place_scaled(image, target_normal, (64, 559), 3)
    place_scaled(image, target_aggro, (824, 559), 3)
    draw.text((64, 691), "左上只保留磨亮折边；不是 Player 镜像", font=note, fill=(188, 169, 133, 255))
    draw.text((824, 691), "暗红只在断续外缘；右下断铜承担目标识别", font=note, fill=(188, 169, 133, 255))

    draw.line((35, 733, 1565, 733), fill=(69, 56, 40, 255))
    draw.text((42, 756), "C. 变宽三切片（3×）", font=section, fill=(208, 177, 116, 255))
    narrow = render_unit_frame(runtimes["player"], None, spec, 160, 0.68, (101, 132, 76), 0.52, (180, 166, 82), "W160", "68%")
    wide = render_unit_frame(runtimes["target"], states["target_aggro"], spec, 240, 0.73, (147, 69, 57), 0.58, (160, 72, 64), "W240", "73%")
    place_scaled(image, narrow, (63, 807), 3)
    place_scaled(image, wide, (770, 807), 3)
    draw.text((63, 939), "174×42：32px 左端 + 110px 中央 + 32px 右端", font=small, fill=(170, 157, 134, 255))
    draw.text((770, 939), "254×42：32px 左端 + 190px 中央 + 32px 右端", font=small, fill=(170, 157, 134, 255))

    draw.line((35, 976, 1565, 976), fill=(69, 56, 40, 255))
    draw.text((42, 999), "D. 统一 UI Scale（完整 Frame 一次缩放）", font=section, fill=(208, 177, 116, 255))
    base = render_unit_frame(runtimes["player"], None, spec, 200, 0.81, (101, 132, 76), 0.66, (82, 111, 168), "", "", text=False)
    x = 52
    for label, scale in (("75%", 0.75), ("100%", 1.0), ("125%", 1.25), ("150%", 1.5)):
        width = int(base.width * scale + 0.5)
        height = int(base.height * scale + 0.5)
        draw.rectangle((x - 8, 1055, x + width + 8, 1125 + height), fill=(28, 25, 21, 255), outline=(73, 57, 39, 255))
        scaled = base.resize((width, height), Image.Resampling.NEAREST)
        image.alpha_composite(scaled, (x, 1065))
        draw.text((x + width // 2, 1082 + height), label, font=small, fill=(191, 174, 144, 255), anchor="ma")
        x += width + 55
    draw.text((43, 1190), "候选仍为 ignored P3 证据；用户接受 exact pixels 前，不写 assets/source，不导出 TGA，不接入 addon。", font=note, fill=(165, 152, 132, 255))
    return image


def render_technical_review(
    spec: dict,
    sources: dict[str, Image.Image],
    runtimes: dict[str, Image.Image],
    masks: dict[str, dict[str, Image.Image]],
) -> Image.Image:
    image = Image.new("RGBA", (1380, 1020), (20, 19, 17, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    title = font(FONT_SERIF, 24)
    note = font(FONT_SANS, 12)
    draw.text((30, 19), "UF-PRIMARY-V4 · exact transparent candidate technical review", font=title, fill=(216, 184, 119, 255))
    draw.text((31, 55), "Checkerboard shows Alpha. Source is 1284×252 RGBA; runtime review is 214×42 RGBA.", font=note, fill=(171, 159, 138, 255))
    for row, role in enumerate(("player", "target")):
        y = 86 + row * 295
        backing = checker((1284, 252), 12)
        image.alpha_composite(backing, (48, y))
        image.alpha_composite(sources[role], (48, y))
        draw.rectangle((48, y, 1331, y + 251), outline=(112, 82, 45, 255), width=2)
        draw.rectangle((48 + 42, y + 36, 48 + 1241, y + 215), outline=(92, 151, 121, 205), width=2)
        draw.line((48 + 192, y, 48 + 192, y + 251), fill=(180, 139, 65, 155), width=1)
        draw.line((48 + 1092, y, 48 + 1092, y + 251), fill=(180, 139, 65, 155), width=1)
        draw.text((55, y + 8), f"{role.upper()} · green = live bed boundary; gold = 192/900/192", font=note, fill=(229, 212, 176, 255))

    draw.text((48, 689), "Runtime 3× nearest-neighbour inspection", font=font(FONT_SERIF, 17), fill=(207, 176, 115, 255))
    for index, role in enumerate(("player", "target")):
        x = 50 + index * 660
        backing = checker((214 * 3, 42 * 3), 12)
        image.alpha_composite(backing, (x, 727))
        runtime = runtimes[role].resize((214 * 3, 42 * 3), Image.Resampling.NEAREST)
        image.alpha_composite(runtime, (x, 727))
        draw.text((x, 866), f"{role} · exact 214×42 pixels enlarged 3×", font=note, fill=(187, 169, 135, 255))
    draw.text((48, 958), "All relief and repairs are mask-clipped outside source [42,36,1242,216]. Liner is allowed below provider bars.", font=note, fill=(168, 155, 133, 255))
    return image


def candidate_review(
    spec: dict,
    output_dir: Path,
    display_report: dict,
) -> tuple[dict, dict[str, Image.Image], dict[str, Image.Image], dict[str, dict[str, Image.Image]], dict[str, Image.Image]]:
    outputs = spec["outputs"]
    source_paths = {
        "player": output_dir / outputs["player_source"],
        "target": output_dir / outputs["target_source"],
    }
    runtime_paths = {
        "player": output_dir / outputs["player_runtime_review"],
        "target": output_dir / outputs["target_runtime_review"],
    }
    state_paths = {
        "player_hover": output_dir / outputs["player_hover_review"],
        "target_aggro": output_dir / outputs["target_aggro_review"],
    }
    sources = {role: Image.open(path).copy() for role, path in source_paths.items()}
    runtimes = {role: Image.open(path).copy() for role, path in runtime_paths.items()}
    states = {role: Image.open(path).copy() for role, path in state_paths.items()}
    masks = {role: role_masks(spec, role) for role in ("player", "target")}
    bed_box = tuple(spec["geometry"]["live_content_bed_source"])
    bed_area = (bed_box[2] - bed_box[0]) * (bed_box[3] - bed_box[1])

    checks: dict[str, object] = {}
    input_shas = {}
    for material_id, contract in spec["inputs"]["materials"].items():
        actual = sha256(ROOT / contract["file"])
        input_shas[material_id] = actual
        checks[f"input_{material_id}_sha_match"] = actual == contract["sha256"]
    for bar_id, contract in spec["inputs"]["bars"].items():
        actual = sha256(ROOT / contract["file"])
        input_shas[f"bar_{bar_id}"] = actual
        checks[f"input_bar_{bar_id}_sha_match"] = actual == contract["sha256"]

    role_metrics = {}
    for role in ("player", "target"):
        source = sources[role]
        runtime = runtimes[role]
        alpha = source.getchannel("A")
        outside = ImageChops.multiply(alpha, ImageOps.invert(masks[role]["outer"]))
        liner_coverage = count_nonzero(alpha.crop(bed_box)) / bed_area
        repair_masks = [value for key, value in masks[role].items() if key.startswith("repair_")]
        repair_union = Image.new("L", source.size, 0)
        for repair in repair_masks:
            repair_union = ImageChops.lighter(repair_union, repair)
        relief_intrusion = count_nonzero(ImageChops.multiply(masks[role]["rim"], masks[role]["bed"]))
        repair_intrusion = count_nonzero(ImageChops.multiply(repair_union, masks[role]["bed"]))
        role_metrics[role] = {
            "source_size": list(source.size),
            "source_mode": source.mode,
            "source_sha256": sha256(source_paths[role]),
            "source_visible_bbox": list(alpha.getbbox() or (0, 0, 0, 0)),
            "runtime_size": list(runtime.size),
            "runtime_mode": runtime.mode,
            "runtime_sha256": sha256(runtime_paths[role]),
            "transparent_rgb_nonzero_pixels": transparent_rgb_count(source),
            "outside_outer_alpha_pixels": count_nonzero(outside),
            "live_bed_liner_coverage_ratio": liner_coverage,
            "perimeter_relief_intrusion_pixels": relief_intrusion,
            "identity_repair_intrusion_pixels": repair_intrusion,
            "repair_visible_bbox": list(repair_union.getbbox() or (0, 0, 0, 0)),
        }
        checks[f"{role}_source_size_mode"] = source.size == (1284, 252) and source.mode == "RGBA"
        checks[f"{role}_runtime_size_mode"] = runtime.size == (214, 42) and runtime.mode == "RGBA"
        checks[f"{role}_transparent_rgb_zero"] = transparent_rgb_count(source) == 0
        checks[f"{role}_outside_outer_alpha_zero"] = count_nonzero(outside) == 0
        checks[f"{role}_liner_coverage"] = liner_coverage >= spec["review_gates"]["live_bed_liner_coverage_ratio_min"]
        checks[f"{role}_relief_intrusion_zero"] = relief_intrusion == 0
        checks[f"{role}_repair_intrusion_zero"] = repair_intrusion == 0

    player_target_diff = ImageChops.difference(sources["player"], sources["target"])
    player_target_mirror_diff = ImageChops.difference(
        sources["player"], ImageOps.mirror(sources["target"])
    )
    checks["roles_not_identical"] = player_target_diff.getbbox() is not None
    checks["roles_not_horizontal_mirrors"] = player_target_mirror_diff.getbbox() is not None
    checks["player_left_repairs_in_fixed_cap"] = (
        masks["player"]["repair_brass"].getbbox()[2] <= 192
        and masks["player"]["repair_thread"].getbbox()[2] <= 192
    )
    checks["player_rivet_in_right_fixed_cap"] = masks["player"]["repair_rivet"].getbbox()[0] >= 1092
    checks["target_fold_in_left_fixed_cap"] = masks["target"]["repair_fold"].getbbox()[2] <= 192
    checks["target_damage_in_right_fixed_cap"] = (
        masks["target"]["repair_brass"].getbbox()[0] >= 1092
        and masks["target"]["repair_split"].getbbox()[0] >= 1092
    )
    checks["display_region_10_of_10"] = (
        display_report.get("status") == "pass"
        and display_report.get("summary", {}).get("scenario_count") == 10
        and display_report.get("summary", {}).get("violation_count") == 0
    )
    checks["standard_width_uses_complete_texture"] = spec["geometry"]["standard_width_uses_one_complete_texture"] is True
    checks["no_source_or_addon_promotion"] = (
        spec["promotion_policy"]["source_directory_write_allowed"] is False
        and spec["promotion_policy"]["addon_write_allowed"] is False
    )
    failures = [key for key, value in checks.items() if value is not True]
    report = {
        "schema": "aeui-unitframes-primary-v4-candidate-review-v1",
        "version": spec["version"],
        "phase": "P3",
        "status": "pass" if not failures else "fail",
        "candidate_status": "candidate-reviewed-user-acceptance-pending" if not failures else "candidate-blocked",
        "imagegen_calls": 0,
        "input_shas": input_shas,
        "checks": checks,
        "role_metrics": role_metrics,
        "role_difference": {
            "identical": player_target_diff.getbbox() is None,
            "horizontal_mirror": player_target_mirror_diff.getbbox() is None,
        },
        "display_region": display_report,
        "first_failure": failures[0] if failures else None,
        "promotion": {
            "may_write_assets_source": False,
            "may_write_addon_runtime": False,
            "next_gate": "user exact-pixel acceptance",
        },
        "files": {
            "sources": {role: {"path": str(path.relative_to(ROOT)), "sha256": sha256(path)} for role, path in source_paths.items()},
            "runtime_reviews": {role: {"path": str(path.relative_to(ROOT)), "sha256": sha256(path)} for role, path in runtime_paths.items()},
            "states": {role: {"path": str(path.relative_to(ROOT)), "sha256": sha256(path)} for role, path in state_paths.items()},
        },
    }
    return report, sources, runtimes, masks, states


def main() -> int:
    args = parse_args()
    spec = json.loads(args.spec.resolve().read_text(encoding="utf-8"))
    output_dir = (args.output_dir or ROOT / spec["outputs"]["directory"]).resolve()
    display_report_path = output_dir / spec["outputs"]["display_region_report"]
    subprocess.run(
        [
            sys.executable,
            str(DISPLAY_VALIDATOR),
            str(args.display_contract.resolve()),
            "--report",
            str(display_report_path),
        ],
        check=True,
        stdout=subprocess.DEVNULL,
    )
    display_report = json.loads(display_report_path.read_text(encoding="utf-8"))
    report, sources, runtimes, masks, states = candidate_review(spec, output_dir, display_report)

    technical = render_technical_review(spec, sources, runtimes, masks)
    real_layout = render_real_layout(spec, runtimes, states)
    real_layout_review = render_real_layout_review(spec, runtimes, states)
    technical.save(output_dir / spec["outputs"]["technical_review"], compress_level=9)
    real_layout.save(output_dir / spec["outputs"]["real_layout"], compress_level=9)
    real_layout_review.save(output_dir / spec["outputs"]["real_layout_review"], compress_level=9)
    report["files"]["reviews"] = {
        "technical": {
            "path": str((output_dir / spec["outputs"]["technical_review"]).relative_to(ROOT)),
            "sha256": sha256(output_dir / spec["outputs"]["technical_review"]),
        },
        "real_layout": {
            "path": str((output_dir / spec["outputs"]["real_layout"]).relative_to(ROOT)),
            "sha256": sha256(output_dir / spec["outputs"]["real_layout"]),
        },
        "real_layout_review": {
            "path": str((output_dir / spec["outputs"]["real_layout_review"]).relative_to(ROOT)),
            "sha256": sha256(output_dir / spec["outputs"]["real_layout_review"]),
        },
        "geometry_masks": {
            "path": str((output_dir / spec["outputs"]["geometry_masks"]).relative_to(ROOT)),
            "sha256": sha256(output_dir / spec["outputs"]["geometry_masks"]),
        },
        "display_region_report": {
            "path": str(display_report_path.relative_to(ROOT)),
            "sha256": sha256(display_report_path),
        },
    }
    report_path = output_dir / spec["outputs"]["review_report"]
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({
        "status": report["status"],
        "first_failure": report["first_failure"],
        "report": str(report_path),
        "technical": str(output_dir / spec["outputs"]["technical_review"]),
        "real_layout": str(output_dir / spec["outputs"]["real_layout"]),
        "real_layout_review": str(output_dir / spec["outputs"]["real_layout_review"]),
    }, ensure_ascii=False, indent=2))
    return 0 if report["status"] == "pass" else 1


if __name__ == "__main__":
    raise SystemExit(main())
