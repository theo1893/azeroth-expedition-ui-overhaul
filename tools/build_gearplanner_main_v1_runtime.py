#!/usr/bin/env python3
"""Export the accepted Gear Planner donor into Turtle WoW runtime atlases.

The accepted donor is a material/component source, not one runtime backdrop.
This exporter only crops, downsamples, packs transparent atlases, and produces
focused 2x previews. Dynamic text, item icons, difference states, and dirty
states remain runtime-owned.
"""

from __future__ import annotations

import hashlib
import json
import struct
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFont

from runtime_texture_compat import is_power_of_two


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets/source/gearplanner/main-v1"
SOURCE = SOURCE_DIR / "GearPlannerMainDonor_SourceV1.png"
MEDIA_DIR = ROOT / "addon/AzerothExpeditionUI/Media/GearPlanner"
PREVIEW_DIR = ROOT / "generated/gearplanner/runtime-main-v1"

SOURCE_SHA256 = "90f60cc9220e413fabb37a9aaea6c83d7e488924f7a9c0ffb88853bc269f7938"
SOURCE_SIZE = (1262, 1246)
VISIBLE_BBOX = (41, 29, 1220, 1208)
TEXELS_PER_UI_UNIT = 2

FONT_SANS = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"
FONT_SERIF = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"


ATLAS_DEFINITIONS: dict[str, dict[str, Any]] = {
    "frame": {
        "master": "GearPlannerFrameAtlas_RuntimeMasterV1.png",
        "runtime": "GearPlannerFrameAtlasV1.tga",
        "texture_size": (256, 256),
        "regions": {
            "top_left": ((41, 29, 73, 61), (32, 32), (0, 0), (16, 16)),
            "top": ((950, 29, 1078, 61), (128, 32), (32, 0), (64, 16)),
            "top_right": ((1188, 29, 1220, 61), (32, 32), (160, 0), (16, 16)),
            "left": ((41, 330, 73, 458), (32, 128), (0, 32), (16, 64)),
            "right": ((1188, 330, 1220, 458), (32, 128), (160, 32), (16, 64)),
            "bottom_left": ((41, 1176, 73, 1208), (32, 32), (0, 160), (16, 16)),
            "bottom": ((600, 1176, 728, 1208), (128, 32), (32, 160), (64, 16)),
            "bottom_right": ((1188, 1176, 1220, 1208), (32, 32), (160, 160), (16, 16)),
        },
    },
    "fill": {
        "master": "GearPlannerLeatherFill_RuntimeMasterV1.png",
        "runtime": "GearPlannerLeatherFillV1.tga",
        "texture_size": (128, 128),
        "regions": {
            "normal": ((976, 103, 1104, 231), (128, 128), (0, 0), (64, 64)),
        },
    },
    "decor": {
        "master": "GearPlannerDecorAtlas_RuntimeMasterV1.png",
        "runtime": "GearPlannerDecorAtlasV1.tga",
        "texture_size": (1024, 256),
        "regions": {
            "title_plaque": ((82, 49, 885, 128), (800, 80), (0, 0), (400, 40)),
            "hinge_top": ((41, 151, 105, 275), (56, 120), (0, 96), (28, 60)),
            "hinge_middle": ((41, 518, 84, 644), (40, 120), (64, 96), (20, 60)),
            "hinge_bottom": ((41, 882, 84, 1007), (40, 120), (112, 96), (20, 60)),
        },
    },
    "controls": {
        "master": "GearPlannerControlsAtlas_RuntimeMasterV1.png",
        "runtime": "GearPlannerControlsAtlasV1.tga",
        "texture_size": (1024, 128),
        "regions": {
            "save": ((80, 124, 241, 200), (136, 44), (0, 0), (68, 22)),
            "import": ((250, 129, 432, 193), (188, 44), (144, 0), (94, 22)),
            "clear": ((438, 129, 555, 193), (100, 44), (340, 0), (50, 22)),
            "manage": ((560, 129, 712, 193), (156, 44), (448, 0), (78, 22)),
            "previous": ((899, 52, 938, 121), (36, 52), (612, 0), (18, 26)),
            "next": ((937, 52, 974, 121), (36, 52), (656, 0), (18, 26)),
            "close": ((1125, 43, 1202, 123), (64, 64), (700, 0), (32, 32)),
        },
    },
    "slot": {
        "master": "GearPlannerSlotAtlas_RuntimeMasterV1.png",
        "runtime": "GearPlannerSlotAtlasV1.tga",
        "texture_size": (512, 128),
        "regions": {
            "normal": ((81, 235, 418, 316), (328, 80), (0, 0), (164, 40)),
        },
    },
    "paper": {
        "master": "GearPlannerStatsPaper_RuntimeMasterV1.png",
        "runtime": "GearPlannerStatsPaperV1.tga",
        "texture_size": (512, 1024),
        "regions": {
            "normal": ((771, 237, 1183, 1167), (392, 896), (0, 0), (196, 448)),
        },
    },
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def repo_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def metrics(image: Image.Image) -> dict[str, Any]:
    rgba = image.convert("RGBA")
    alpha = rgba.getchannel("A")
    histogram = alpha.histogram()
    data = np.asarray(rgba, dtype=np.uint8)
    transparent = data[:, :, 3] == 0
    magenta_strength = (
        np.minimum(data[:, :, 0], data[:, :, 2]).astype(int)
        - data[:, :, 1].astype(int)
    )
    magenta = (
        (data[:, :, 3] > 8)
        & (magenta_strength > 48)
        & (np.abs(data[:, :, 0].astype(int) - data[:, :, 2].astype(int)) < 48)
    )
    return {
        "size": list(rgba.size),
        "mode": rgba.mode,
        "pixel_sha256": pixel_sha256(rgba),
        "visible_bbox_exclusive": list(alpha.getbbox() or (0, 0, 0, 0)),
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
        "transparent_rgb_nonzero_pixels": int(np.count_nonzero(data[transparent, :3])),
        "visible_magenta_fringe_pixels": int(np.count_nonzero(magenta)),
    }


def tga_header(path: Path) -> dict[str, Any]:
    data = path.read_bytes()[:18]
    if len(data) < 18:
        raise ValueError(f"incomplete TGA header: {path}")
    width, height = struct.unpack("<HH", data[12:16])
    return {
        "image_type": data[2],
        "width": width,
        "height": height,
        "bits_per_pixel": data[16],
        "descriptor": data[17],
        "top_origin": bool(data[17] & 0x20),
    }


def uv(region: tuple[int, int, int, int], texture_size: tuple[int, int]) -> list[float]:
    left, top, right, bottom = region
    width, height = texture_size
    return [left / width, right / width, top / height, bottom / height]


def open_source() -> Image.Image:
    if sha256(SOURCE) != SOURCE_SHA256:
        raise ValueError("accepted Gear Planner source SHA-256 changed")
    with Image.open(SOURCE) as opened:
        source = clear_transparent_rgb(opened)
    if source.size != SOURCE_SIZE:
        raise ValueError(f"accepted source geometry changed: {source.size}")
    if source.getchannel("A").getbbox() != VISIBLE_BBOX:
        raise ValueError("accepted source visible Alpha bounds changed")
    corners = (
        source.getpixel((0, 0))[3],
        source.getpixel((source.width - 1, 0))[3],
        source.getpixel((0, source.height - 1))[3],
        source.getpixel((source.width - 1, source.height - 1))[3],
    )
    if corners != (0, 0, 0, 0):
        raise ValueError(f"accepted source corners are not transparent: {corners}")
    return source


def export_atlas(
    source: Image.Image,
    atlas_key: str,
    definition: dict[str, Any],
) -> tuple[Image.Image, dict[str, Any]]:
    texture_size = tuple(definition["texture_size"])
    if (
        not all(is_power_of_two(value) for value in texture_size)
        or max(texture_size) > 1024
    ):
        raise ValueError(f"invalid Turtle texture size: {atlas_key}: {texture_size}")

    atlas = Image.new("RGBA", texture_size, (0, 0, 0, 0))
    region_records: dict[str, Any] = {}
    for region_key, region_definition in definition["regions"].items():
        crop_box, sampled_size, origin, logical_size = region_definition
        crop = source.crop(crop_box)
        sampled = clear_transparent_rgb(
            crop.resize(sampled_size, Image.Resampling.LANCZOS)
        )
        atlas.alpha_composite(sampled, origin)
        packed = (
            origin[0],
            origin[1],
            origin[0] + sampled_size[0],
            origin[1] + sampled_size[1],
        )
        region_records[region_key] = {
            "source_crop_exclusive": list(crop_box),
            "logical_size_ui": list(logical_size),
            "sampled_size": list(sampled_size),
            "texels_per_ui_unit": TEXELS_PER_UI_UNIT,
            "atlas_rect_exclusive": list(packed),
            "uv": uv(packed, texture_size),
            "stretch": region_key in {
                "top", "left", "center", "right", "bottom", "import",
                "normal",
            },
        }

    atlas = clear_transparent_rgb(atlas)
    master_path = SOURCE_DIR / definition["master"]
    master_path.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(master_path, format="PNG")

    runtime_path = MEDIA_DIR / definition["runtime"]
    runtime_path.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(runtime_path, format="TGA")
    with Image.open(runtime_path) as opened:
        roundtrip = opened.convert("RGBA")
    if ImageChops.difference(roundtrip, atlas).getbbox() is not None:
        raise ValueError(f"TGA roundtrip changed pixels: {runtime_path}")
    header = tga_header(runtime_path)
    if (
        header["image_type"] != 2
        or header["bits_per_pixel"] != 32
        or (header["width"], header["height"]) != texture_size
    ):
        raise ValueError(f"invalid Turtle TGA: {runtime_path}: {header}")

    return atlas, {
        "file": repo_path(runtime_path),
        "sha256": sha256(runtime_path),
        "texture_size": list(texture_size),
        "pixel_sha256": pixel_sha256(roundtrip),
        "tga": header,
        "runtime_master": {
            "file": repo_path(master_path),
            "sha256": sha256(master_path),
            "metrics": metrics(atlas),
        },
        "regions": region_records,
    }


def atlas_region(
    atlas: Image.Image,
    definition: dict[str, Any],
    key: str,
) -> Image.Image:
    _, sampled_size, origin, _ = definition["regions"][key]
    return atlas.crop(
        (
            origin[0],
            origin[1],
            origin[0] + sampled_size[0],
            origin[1] + sampled_size[1],
        )
    )


def compose_nine_slice(
    atlas: Image.Image,
    definition: dict[str, Any],
    keys: tuple[str, str, str, str, str, str, str, str, str],
    target_size: tuple[int, int],
    border: tuple[int, int, int, int],
) -> Image.Image:
    width, height = target_size
    left, right, top, bottom = border
    if width <= left + right or height <= top + bottom:
        raise ValueError(f"nine-slice target too small: {target_size}, {border}")
    output = Image.new("RGBA", target_size, (0, 0, 0, 0))
    regions = [atlas_region(atlas, definition, key) for key in keys]
    boxes = (
        (0, 0, left, top),
        (left, 0, width - right, top),
        (width - right, 0, width, top),
        (0, top, left, height - bottom),
        (left, top, width - right, height - bottom),
        (width - right, top, width, height - bottom),
        (0, height - bottom, left, height),
        (left, height - bottom, width - right, height),
        (width - right, height - bottom, width, height),
    )
    for region, box in zip(regions, boxes, strict=True):
        size = (box[2] - box[0], box[3] - box[1])
        output.alpha_composite(region.resize(size, Image.Resampling.LANCZOS), box[:2])
    return output


def compose_frame_shell(
    atlases: dict[str, Image.Image],
    target_size: tuple[int, int],
) -> Image.Image:
    width, height = target_size
    output = Image.new("RGBA", target_size, (0, 0, 0, 0))
    fill = atlas_region(atlases["fill"], ATLAS_DEFINITIONS["fill"], "normal")
    for y in range(0, height, fill.height):
        for x in range(0, width, fill.width):
            output.alpha_composite(fill, (x, y))

    keys = (
        "top_left", "top", "top_right",
        "left", "right",
        "bottom_left", "bottom", "bottom_right",
    )
    pieces = [
        atlas_region(atlases["frame"], ATLAS_DEFINITIONS["frame"], key)
        for key in keys
    ]
    border = 32
    boxes = (
        (0, 0, border, border),
        (border, 0, width - border, border),
        (width - border, 0, width, border),
        (0, border, border, height - border),
        (width - border, border, width, height - border),
        (0, height - border, border, height),
        (border, height - border, width - border, height),
        (width - border, height - border, width, height),
    )
    for piece, box in zip(pieces, boxes, strict=True):
        size = (box[2] - box[0], box[3] - box[1])
        output.alpha_composite(piece.resize(size, Image.Resampling.LANCZOS), box[:2])
    return output


def compose_region_nine_slice(
    atlas: Image.Image,
    definition: dict[str, Any],
    key: str,
    target_size: tuple[int, int],
    border: tuple[int, int, int, int],
) -> Image.Image:
    source = atlas_region(atlas, definition, key)
    width, height = source.size
    left, right, top, bottom = border
    pieces = (
        source.crop((0, 0, left, top)),
        source.crop((left, 0, width - right, top)),
        source.crop((width - right, 0, width, top)),
        source.crop((0, top, left, height - bottom)),
        source.crop((left, top, width - right, height - bottom)),
        source.crop((width - right, top, width, height - bottom)),
        source.crop((0, height - bottom, left, height)),
        source.crop((left, height - bottom, width - right, height)),
        source.crop((width - right, height - bottom, width, height)),
    )
    target_width, target_height = target_size
    boxes = (
        (0, 0, left, top),
        (left, 0, target_width - right, top),
        (target_width - right, 0, target_width, top),
        (0, top, left, target_height - bottom),
        (left, top, target_width - right, target_height - bottom),
        (target_width - right, top, target_width, target_height - bottom),
        (0, target_height - bottom, left, target_height),
        (left, target_height - bottom, target_width - right, target_height),
        (target_width - right, target_height - bottom, target_width, target_height),
    )
    output = Image.new("RGBA", target_size, (0, 0, 0, 0))
    for piece, box in zip(pieces, boxes, strict=True):
        size = (box[2] - box[0], box[3] - box[1])
        output.alpha_composite(piece.resize(size, Image.Resampling.LANCZOS), box[:2])
    return output


def compose_slot(
    atlas: Image.Image,
    definition: dict[str, Any],
    target_size: tuple[int, int],
) -> Image.Image:
    source = atlas_region(atlas, definition, "normal")
    left, right = 80, 16
    width, height = source.size
    target_width, target_height = target_size
    pieces = (
        source.crop((0, 0, left, height)),
        source.crop((left, 0, width - right, height)),
        source.crop((width - right, 0, width, height)),
    )
    widths = (left, target_width - left - right, right)
    output = Image.new("RGBA", target_size, (0, 0, 0, 0))
    x = 0
    for piece, piece_width in zip(pieces, widths, strict=True):
        output.alpha_composite(
            piece.resize((piece_width, target_height), Image.Resampling.LANCZOS),
            (x, 0),
        )
        x += piece_width
    return output


def tint(image: Image.Image, color: tuple[float, float, float, float]) -> Image.Image:
    data = np.asarray(image.convert("RGBA"), dtype=np.float32).copy()
    for channel in range(4):
        data[:, :, channel] *= color[channel]
    return Image.fromarray(np.clip(data, 0, 255).astype(np.uint8), "RGBA")


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size)


def paste_control(
    image: Image.Image,
    atlases: dict[str, Image.Image],
    key: str,
    box: tuple[int, int, int, int],
    disabled: bool = False,
) -> None:
    control = atlas_region(atlases["controls"], ATLAS_DEFINITIONS["controls"], key)
    control = control.resize((box[2] - box[0], box[3] - box[1]), Image.Resampling.LANCZOS)
    if disabled:
        control = tint(control, (0.52, 0.50, 0.46, 1.0))
    image.alpha_composite(control, box[:2])


def draw_dynamic_content(
    image: Image.Image,
    *,
    companion: bool,
    atlases: dict[str, Image.Image],
) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    serif = font(FONT_SERIF, 27)
    body = font(FONT_SANS, 18)
    small = font(FONT_SANS, 15)
    tiny = font(FONT_SANS, 13)

    draw.text((36, 25), "配装方案 · 熔火远征  1/3", font=serif, fill=(226, 194, 126, 255))
    if companion:
        button_specs = (
            ("save", (20, 86, 156, 130), "保存 (2)", False),
            ("import", (164, 86, 352, 130), "导入当前装备", False),
            ("clear", (360, 86, 460, 130), "清空", False),
            ("manage", (468, 86, 624, 130), "方案管理", False),
        )
        slot_width, slot_height = 328, 80
        first_x, second_x, first_y, step_y = 20, 364, 184, 88
        stats_box = (708, 184, 1100, 1080)
        draw.text(
            (24, 140),
            "AtlasLoot OK · 6360 · BS OK · 武器 Nampower",
            font=tiny,
            fill=(166, 139, 96, 255),
        )
    else:
        button_specs = (
            ("save", (32, 86, 172, 130), "保存 (2)", False),
            ("import", (186, 86, 418, 130), "导入当前装备", False),
            ("clear", (432, 86, 560, 130), "清空", False),
            ("manage", (574, 86, 730, 130), "方案管理", False),
        )
        slot_width, slot_height = 404, 84
        first_x, second_x, first_y, step_y = 28, 452, 144, 92
        stats_box = (876, 144, 1488, 1070)
        draw.text(
            (758, 100),
            "AtlasLoot：就绪  物品：6360  属性：BonusScanner + 武器 Nampower",
            font=tiny,
            fill=(166, 139, 96, 255),
        )

    for key, box, label, disabled in button_specs:
        paste_control(image, atlases, key, box, disabled)
        text_box = draw.textbbox((0, 0), label, font=small)
        text_width = text_box[2] - text_box[0]
        text_height = text_box[3] - text_box[1]
        draw.text(
            ((box[0] + box[2] - text_width) // 2, (box[1] + box[3] - text_height) // 2 - 1),
            label,
            font=small,
            fill=(232, 201, 139, 255),
        )

    close_box = (image.width - 74, 12, image.width - 10, 76)
    paste_control(image, atlases, "close", close_box)
    paste_control(image, atlases, "previous", (image.width - 164, 24, image.width - 128, 76))
    paste_control(image, atlases, "next", (image.width - 120, 24, image.width - 84, 76))

    slot = compose_slot(
        atlases["slot"],
        ATLAS_DEFINITIONS["slot"],
        (slot_width, slot_height),
    )
    slot_names = (
        ("头部", "愤怒头盔"), ("项链", "奥妮克希亚龙牙坠饰"),
        ("肩部", "力量肩铠"), ("背部", "环雾披风"),
        ("胸部", "愤怒胸甲"), ("衬衣", "棕色亚麻衬衣"),
        ("战袍", "银色黎明战袍"), ("护腕", "愤怒护腕"),
        ("手套", "力量护手"), ("腰带", "冲击束带"),
        ("腿部", "愤怒腿铠"), ("脚部", "多彩长靴"),
        ("戒指一", "埃古雷亚指环"), ("戒指二", "屠龙大师之戒"),
        ("饰品一", "龙牙饰物"), ("饰品二", "正义之手"),
        ("主手", "逐风者的祝福之剑"), ("副手", "源质壁垒"),
        ("远程／圣物", "速射强弓"),
    )
    palette = ((74, 106, 142), (103, 72, 132), (121, 83, 51), (74, 121, 88))
    for index, (label, item) in enumerate(slot_names):
        column = index // 10
        row = index - column * 10
        x = first_x + (second_x - first_x) * column
        y = first_y + step_y * row
        image.alpha_composite(slot, (x, y))
        icon_size = 56 if companion else 64
        icon_x = x + 12
        icon_y = y + (slot_height - icon_size) // 2
        color = palette[index % len(palette)]
        draw.rectangle(
            (icon_x, icon_y, icon_x + icon_size - 1, icon_y + icon_size - 1),
            fill=(*color, 255),
            outline=(197, 153, 75, 255),
            width=2,
        )
        text_x = icon_x + icon_size + 12
        draw.text((text_x, y + 10), label, font=tiny, fill=(212, 177, 111, 255))
        draw.text((text_x, y + slot_height - 31), item, font=small, fill=(226, 214, 187, 255))
        if index == 0:
            wash = Image.new("RGBA", image.size, (0, 0, 0, 0))
            wash_draw = ImageDraw.Draw(wash, "RGBA")
            wash_draw.rectangle(
                (x + 5, y + 5, x + slot_width - 6, y + slot_height - 6),
                fill=(242, 139, 26, 25),
            )
            image.alpha_composite(wash)
            draw.rectangle((x + 2, y + 2, x + slot_width - 3, y + slot_height - 3), outline=(242, 171, 51, 255), width=3)
            draw.text((x + slot_width - 58, y + 10), "更换", font=tiny, fill=(255, 200, 67, 255))
        if index == 1:
            draw.rectangle((x + 2, y + 2, x + slot_width - 3, y + slot_height - 3), outline=(107, 173, 194, 255), width=3)
            draw.rectangle((x + 4, y + 5, x + 9, y + slot_height - 6), fill=(107, 173, 194, 235))
            draw.text((text_x + 28, y + 10), "*", font=body, fill=(127, 181, 192, 255))

    paper = compose_region_nine_slice(
        atlases["paper"],
        ATLAS_DEFINITIONS["paper"],
        "normal",
        (stats_box[2] - stats_box[0], stats_box[3] - stats_box[1]),
        (36, 36, 36, 36),
    )
    image.alpha_composite(paper, stats_box[:2])
    sx, sy = stats_box[:2]
    sw = stats_box[2] - stats_box[0]
    columns = (sx + 24, sx + int(sw * 0.48), sx + int(sw * 0.66), sx + int(sw * 0.82))
    for x, text in zip(columns, ("属性", "当前", "配装", "变化"), strict=True):
        draw.text((x, sy + 24), text, font=small, fill=(76, 47, 25, 255))
    stats = (
        ("力量", "196", "204", "+8"),
        ("耐力", "238", "251", "+13"),
        ("护甲", "7421", "7368", "-53"),
        ("攻击强度", "1028", "1064", "+36"),
        ("物理命中", "6%", "7%", "+1%"),
        ("主手秒伤", "73.4", "74.8", "+1.4"),
        ("主手攻速", "1.90", "2.00", "+0.10"),
    )
    for index, row in enumerate(stats):
        y = sy + 60 + index * 28
        for column, text in enumerate(row):
            color = (53, 35, 22, 255)
            if column == 3:
                color = (28, 102, 47, 255) if not text.startswith("-") else (130, 35, 28, 255)
            draw.text((columns[column], y), text, font=small, fill=color)
    draw.text(
        (sx + 24, stats_box[3] - 56),
        "未填槽位按空槽；攻速变化不判断优劣",
        font=tiny,
        fill=(93, 69, 48, 255),
    )


def render_preview(
    atlases: dict[str, Image.Image],
    *,
    companion: bool,
) -> Path:
    logical_size = (560, 555) if companion else (760, 555)
    sampled_size = tuple(value * TEXELS_PER_UI_UNIT for value in logical_size)
    image = compose_frame_shell(atlases, sampled_size)
    title = atlas_region(atlases["decor"], ATLAS_DEFINITIONS["decor"], "title_plaque")
    image.alpha_composite(title, (32, 16))
    for key, x, y in (
        ("hinge_top", 0, 114),
        ("hinge_middle", 0, 462),
        ("hinge_bottom", 0, 804),
    ):
        image.alpha_composite(
            atlas_region(atlases["decor"], ATLAS_DEFINITIONS["decor"], key),
            (x, y),
        )
    draw_dynamic_content(image, companion=companion, atlases=atlases)
    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
    suffix = "Companion2x" if companion else "Standalone2x"
    target = PREVIEW_DIR / f"GearPlannerMainV1_RuntimePreview_{suffix}.png"
    clear_transparent_rgb(image).save(target, format="PNG")
    return target


def main() -> None:
    source = open_source()
    atlases: dict[str, Image.Image] = {}
    runtime: dict[str, Any] = {}
    for atlas_key, definition in ATLAS_DEFINITIONS.items():
        atlas, record = export_atlas(source, atlas_key, definition)
        atlases[atlas_key] = atlas
        runtime[atlas_key] = record

    previews = [
        render_preview(atlases, companion=True),
        render_preview(atlases, companion=False),
    ]
    report = {
        "schema": "aeui-gearplanner-main-v1-runtime-export-report-v1",
        "source": {
            "file": repo_path(SOURCE),
            "sha256": sha256(SOURCE),
            "metrics": metrics(source),
        },
        "runtime": runtime,
        "previews": [repo_path(path) for path in previews],
    }
    print(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
