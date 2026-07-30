#!/usr/bin/env python3
"""Build the accepted QL-B1 directory marks and a real-layout preview.

The accepted 1024 x 1024 source is immutable. This builder extracts the four
fixed source cells, crops only transparent bounds, scales proportionally into
the declared runtime footprints, centers them in a 64 x 16 atlas, and writes
the runtime TGA plus its manifest. It also renders a 676 x 464 simulation with
the accepted shell, all 23 real row slots, representative localized content,
and the exact runtime sprites at their intended z-order and display size.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (
    ROOT
    / "assets"
    / "source"
    / "quests"
    / "ql-b1"
    / "QuestLogDirectoryMarks_Master_v1.png"
)
SOURCE_MANIFEST = SOURCE.with_name("QL-B1_SourceManifest_v1.json")
RUNTIME = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestLogDirectoryMarksV1.tga"
)
RUNTIME_MANIFEST = SOURCE.with_name("QL-B1_RuntimeManifest_v1.json")
ATLAS_PREVIEW = (
    ROOT
    / "generated"
    / "quests"
    / "QL-B1"
    / "v1"
    / "accepted"
    / "previews"
    / "QL-B1_V1_r3_runtime_atlas.png"
)
REAL_LAYOUT_PREVIEW = ATLAS_PREVIEW.with_name(
    "QL-B1_V1_r3_real_layout_676x464.png"
)
SHELL_RUNTIME = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestLogShellV4.tga"
)
TITLE_FONT = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Fonts"
    / "NotoSerifSC-SemiBold.ttf"
)
ROW_FONT = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Fonts"
    / "LXGWWenKaiGB-Medium.ttf"
)
BODY_FONT = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Fonts"
    / "NotoSansSC-Medium.ttf"
)

EXPECTED_SOURCE_SHA256 = (
    "719445d15fb34be4af3ec316eac5bdec51c2061423bae5d7f45b47a3b1128c44"
)
EXPECTED_SOURCE_SIZE = (1024, 1024)
ATLAS_SIZE = (64, 16)
CELL_SIZE = (16, 16)
SHELL_DISPLAY_SIZE = (676, 464)
ROW_COUNT = 23
ROW_BOX = (224, 15)
ROW_STEP = 14
LIST_ORIGIN = (64, 64)
RESAMPLE = Image.Resampling.LANCZOS

STATES: tuple[dict[str, Any], ...] = (
    {
        "id": "collapsed",
        "component": "QUEST.LOG.REGION.TOGGLE",
        "source_box": (0, 0, 512, 512),
        "display_size": (12, 12),
    },
    {
        "id": "expanded",
        "component": "QUEST.LOG.REGION.TOGGLE",
        "source_box": (512, 0, 1024, 512),
        "display_size": (12, 12),
    },
    {
        "id": "untracked",
        "component": "QUEST.LOG.LIST.CHECK",
        "source_box": (0, 512, 512, 1024),
        "display_size": (10, 10),
    },
    {
        "id": "tracked",
        "component": "QUEST.LOG.LIST.CHECK",
        "source_box": (512, 512, 1024, 1024),
        "display_size": (10, 10),
    },
)

QUEST_ROWS: tuple[tuple[str, str, bool], ...] = (
    ("header-expanded", "东瘟疫之地", False),
    ("quest", "[60]  达隆郡的战斗", True),
    ("quest", "[60]  爱与家庭", False),
    ("quest", "[60]  重铸秩序", True),
    ("quest", "[60]  卡林·雷德帕斯", False),
    ("header-expanded", "黑石山", False),
    ("quest", "[60+] 黑手的命令", True),
    ("quest", "[60R] 达基萨斯将军之死", True),
    ("quest", "[60R] 黑龙勇士之血", False),
    ("quest", "[58D] 烈焰精华", False),
    ("header-expanded", "希利苏斯", False),
    ("quest", "[60]  沙漠中的剧毒", True),
    ("quest", "[60]  暮光的秘密", False),
    ("quest", "[60R] 唤醒沉睡者", False),
    ("quest", "[60]  塞纳里奥的议会", True),
    ("header-collapsed", "冬泉谷", False),
    ("header-expanded", "安戈洛环形山", False),
    ("quest", "[55]  拉克维的诱饵", False),
    ("quest", "[56]  走丢了！", True),
    ("quest", "[57]  火羽山", False),
    ("header-expanded", "职业任务", False),
    ("quest", "[60]  久远的记忆", True),
    ("quest", "[60]  恐惧谷的灵魂", False),
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def display_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def alpha_evidence(image: Image.Image) -> dict[str, int]:
    histogram = image.getchannel("A").histogram()
    return {
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
    }


def green_spill_pixels(image: Image.Image) -> int:
    count = 0
    pixels = (
        image.get_flattened_data()
        if hasattr(image, "get_flattened_data")
        else image.getdata()
    )
    for red, green, blue, alpha in pixels:
        if alpha > 0 and red <= 32 and green >= 224 and blue <= 32:
            count += 1
    return count


def visible_bbox(image: Image.Image) -> list[int] | None:
    bounds = image.getchannel("A").getbbox()
    return list(bounds) if bounds else None


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    red, green, blue, alpha = image.convert("RGBA").split()
    visible = alpha.point(lambda value: 255 if value else 0)
    zero = Image.new("L", image.size, 0)
    return Image.merge(
        "RGBA",
        (
            Image.composite(red, zero, visible),
            Image.composite(green, zero, visible),
            Image.composite(blue, zero, visible),
            alpha,
        ),
    )


def validate_source(path: Path, image: Image.Image) -> None:
    if sha256(path) != EXPECTED_SOURCE_SHA256:
        raise ValueError("QL-B1 source SHA-256 does not match the accepted asset")
    if image.size != EXPECTED_SOURCE_SIZE:
        raise ValueError(
            f"QL-B1 source must be {EXPECTED_SOURCE_SIZE}, got {image.size}"
        )
    if image.mode != "RGBA":
        raise ValueError(f"QL-B1 source must be RGBA, got {image.mode}")
    if green_spill_pixels(image):
        raise ValueError("QL-B1 source contains visible chroma-key green")


def scale_to_fit(
    image: Image.Image,
    target: tuple[int, int],
) -> Image.Image:
    ratio = min(target[0] / image.width, target[1] / image.height)
    size = (
        max(1, round(image.width * ratio)),
        max(1, round(image.height * ratio)),
    )
    return clear_transparent_rgb(image.resize(size, RESAMPLE))


def build_atlas(
    source: Image.Image,
) -> tuple[Image.Image, dict[str, dict[str, Any]]]:
    atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
    records: dict[str, dict[str, Any]] = {}
    for index, state in enumerate(STATES):
        source_cell = source.crop(state["source_box"])
        bounds = source_cell.getchannel("A").getbbox()
        if not bounds:
            raise ValueError(f"{state['id']} source cell has no visible pixels")
        cropped = clear_transparent_rgb(source_cell.crop(bounds))
        scaled = scale_to_fit(cropped, state["display_size"])
        cell_x = index * CELL_SIZE[0]
        paste_x = cell_x + (CELL_SIZE[0] - scaled.width) // 2
        paste_y = (CELL_SIZE[1] - scaled.height) // 2
        atlas.alpha_composite(scaled, (paste_x, paste_y))
        content_box = (
            paste_x,
            paste_y,
            paste_x + scaled.width,
            paste_y + scaled.height,
        )
        records[state["id"]] = {
            "component": state["component"],
            "source_cell_xyxy": list(state["source_box"]),
            "source_visible_bbox_local_exclusive": list(bounds),
            "source_visible_size": [
                bounds[2] - bounds[0],
                bounds[3] - bounds[1],
            ],
            "runtime_cell_xyxy": [
                cell_x,
                0,
                cell_x + CELL_SIZE[0],
                CELL_SIZE[1],
            ],
            "runtime_content_xyxy": list(content_box),
            "runtime_display_size": [scaled.width, scaled.height],
            "texcoord": {
                "left": content_box[0] / ATLAS_SIZE[0],
                "right": content_box[2] / ATLAS_SIZE[0],
                "top": content_box[1] / ATLAS_SIZE[1],
                "bottom": content_box[3] / ATLAS_SIZE[1],
            },
        }
    return clear_transparent_rgb(atlas), records


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    if not path.is_file():
        raise FileNotFoundError(path)
    return ImageFont.truetype(str(path), size)


def draw_text(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    value: str,
    text_font: ImageFont.FreeTypeFont,
    fill: tuple[int, int, int, int],
) -> None:
    draw.text(
        (xy[0] + 1, xy[1] + 1),
        value,
        font=text_font,
        fill=(238, 196, 124, 80),
    )
    draw.text(xy, value, font=text_font, fill=fill)


def wrap_text(
    draw: ImageDraw.ImageDraw,
    value: str,
    text_font: ImageFont.FreeTypeFont,
    width: int,
) -> list[str]:
    lines: list[str] = []
    current = ""
    for character in value:
        candidate = current + character
        bounds = draw.textbbox((0, 0), candidate, font=text_font)
        if current and bounds[2] - bounds[0] > width:
            lines.append(current)
            current = character
        else:
            current = candidate
    if current:
        lines.append(current)
    return lines


def paste_sprite(
    preview: Image.Image,
    atlas: Image.Image,
    record: dict[str, Any],
    xy: tuple[int, int],
) -> None:
    sprite = atlas.crop(tuple(record["runtime_content_xyxy"]))
    preview.alpha_composite(sprite, xy)


def render_real_layout_preview(
    atlas: Image.Image,
    records: dict[str, dict[str, Any]],
) -> Image.Image:
    with Image.open(SHELL_RUNTIME) as opened:
        shell_atlas = opened.convert("RGBA")
    preview = shell_atlas.crop((0, 0, *SHELL_DISPLAY_SIZE))
    draw = ImageDraw.Draw(preview, "RGBA")
    title_font = font(TITLE_FONT, 15)
    row_font = font(ROW_FONT, 10)
    row_header_font = font(ROW_FONT, 11)
    body_font = font(BODY_FONT, 9)
    body_heading_font = font(TITLE_FONT, 11)

    draw_text(draw, (300, 27), "任务日志", title_font, (49, 26, 16, 255))
    draw_text(draw, (76, 49), "任务  18 / 20", row_font, (76, 43, 25, 235))

    for index, (kind, label, tracked) in enumerate(QUEST_ROWS):
        row_x = LIST_ORIGIN[0]
        row_y = LIST_ORIGIN[1] + index * ROW_STEP
        if kind == "header-expanded":
            paste_sprite(
                preview,
                atlas,
                records["expanded"],
                (row_x + 1, row_y + 1),
            )
            draw_text(
                draw,
                (row_x + 16, row_y + 1),
                label,
                row_header_font,
                (72, 38, 19, 255),
            )
        elif kind == "header-collapsed":
            paste_sprite(
                preview,
                atlas,
                records["collapsed"],
                (row_x + 1, row_y + 1),
            )
            draw_text(
                draw,
                (row_x + 16, row_y + 1),
                label,
                row_header_font,
                (72, 38, 19, 255),
            )
        else:
            state = "tracked" if tracked else "untracked"
            check_x = row_x + ROW_BOX[0] - 12
            check_y = row_y + 2
            paste_sprite(preview, atlas, records[state], (check_x, check_y))
            row_color = (
                (62, 39, 23, 255)
                if tracked
                else (89, 61, 38, 235)
            )
            draw_text(
                draw,
                (row_x + 16, row_y + 2),
                label,
                row_font,
                row_color,
            )

    detail_left = 374
    detail_width = 226
    draw_text(
        draw,
        (detail_left, 68),
        "达隆郡的战斗",
        title_font,
        (55, 28, 17, 255),
    )
    draw_text(
        draw,
        (detail_left, 91),
        "东瘟疫之地",
        row_font,
        (105, 57, 28, 235),
    )
    description = (
        "在达隆郡废墟中寻找约瑟夫的遗物，并帮助帕米拉了解那场战斗的真相。"
        "这份卷宗已经被多次翻阅，边角仍留着旧日远征者的墨迹。"
    )
    y = 111
    for line in wrap_text(draw, description, body_font, detail_width):
        draw_text(draw, (detail_left, y), line, body_font, (69, 48, 31, 245))
        y += 13
    y += 5
    draw_text(
        draw,
        (detail_left, y),
        "任务目标",
        body_heading_font,
        (64, 31, 18, 255),
    )
    y += 19
    for line in (
        "• 找到达隆郡的战斗遗物  3 / 5",
        "• 与帕米拉·雷德帕斯交谈",
        "• 守护达隆郡的幸存者",
    ):
        draw_text(draw, (detail_left, y), line, body_font, (74, 49, 31, 245))
        y += 14
    y += 5
    draw_text(
        draw,
        (detail_left, y),
        "奖励",
        body_heading_font,
        (64, 31, 18, 255),
    )
    y += 19
    draw_text(
        draw,
        (detail_left, y),
        "你将获得：  7 金  40 银",
        body_font,
        (74, 49, 31, 245),
    )

    # Pending QL-C controls are shown only as restrained runtime placeholders.
    # They are not source art and are deliberately omitted from all manifests.
    for x, label in ((62, "放弃任务"), (145, "共享任务"), (228, "退出")):
        draw.rounded_rectangle(
            (x, 421, x + 78, 441),
            radius=3,
            fill=(51, 34, 25, 220),
            outline=(116, 78, 44, 235),
            width=1,
        )
        bounds = draw.textbbox((0, 0), label, font=row_font)
        draw_text(
            draw,
            (x + (78 - (bounds[2] - bounds[0])) // 2, 425),
            label,
            row_font,
            (225, 184, 108, 255),
        )
    draw_text(draw, (314, 425), "›", title_font, (82, 47, 27, 255))

    return preview


def save_png(image: Image.Image, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, format="PNG", optimize=True)


def save_tga(image: Image.Image, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, format="TGA")


def tga_header(path: Path) -> dict[str, Any]:
    data = path.read_bytes()
    if len(data) < 18:
        raise ValueError("runtime TGA is shorter than its header")
    width, height = struct.unpack("<HH", data[12:16])
    return {
        "image_type": data[2],
        "width": width,
        "height": height,
        "bits_per_pixel": data[16],
        "descriptor": data[17],
        "top_origin": bool(data[17] & 0x20),
    }


def update_source_manifest(
    path: Path,
    runtime_manifest: Path,
    runtime_path: Path,
) -> None:
    manifest = json.loads(path.read_text(encoding="utf-8"))
    manifest["export_contract"]["status"] = "runtime-exported"
    manifest["runtime_exports"] = [
        {
            "contract": "QL-B1 V1.r3 / 1.0",
            "manifest": runtime_manifest.name,
            "file": display_path(runtime_path),
            "sha256": sha256(runtime_path),
            "atlas_size": list(ATLAS_SIZE),
            "cell_size": list(CELL_SIZE),
        }
    ]
    path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--source-manifest", type=Path, default=SOURCE_MANIFEST)
    parser.add_argument("--runtime", type=Path, default=RUNTIME)
    parser.add_argument("--manifest", type=Path, default=RUNTIME_MANIFEST)
    parser.add_argument("--atlas-preview", type=Path, default=ATLAS_PREVIEW)
    parser.add_argument(
        "--real-layout-preview",
        type=Path,
        default=REAL_LAYOUT_PREVIEW,
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    with Image.open(args.source) as opened:
        source = opened.convert("RGBA")
    validate_source(args.source, source)
    atlas, records = build_atlas(source)
    save_tga(atlas, args.runtime)
    save_png(atlas, args.atlas_preview)
    real_layout = render_real_layout_preview(atlas, records)
    save_png(real_layout, args.real_layout_preview)

    header = tga_header(args.runtime)
    if (
        header["image_type"] != 2
        or (header["width"], header["height"]) != ATLAS_SIZE
        or header["bits_per_pixel"] != 32
    ):
        raise ValueError(f"unexpected runtime TGA header: {header}")

    manifest = {
        "schema_version": 1,
        "batch": "QL-B1",
        "version": "V1.r3",
        "runtime_contract": "1.0",
        "status": "runtime-exported",
        "source": {
            "file": display_path(args.source),
            "sha256": sha256(args.source),
            "width": source.width,
            "height": source.height,
            "mode": source.mode,
            "visible_bbox_exclusive": visible_bbox(source),
            "visible_green_spill_pixels": green_spill_pixels(source),
            **alpha_evidence(source),
        },
        "transform": {
            "operation": (
                "fixed cell extraction, visible-alpha-bounds crop, "
                "proportional LANCZOS scale, centering and transparent atlas "
                "assembly"
            ),
            "resample": "Pillow Image.Resampling.LANCZOS",
            "alpha_cleanup": (
                "zero RGB only where alpha is fully transparent; preserve "
                "visible source alpha"
            ),
            "rotation": None,
            "mirror": False,
            "retouch": False,
            "atlas_size": list(ATLAS_SIZE),
            "cell_size": list(CELL_SIZE),
            "state_order": [state["id"] for state in STATES],
            "states": records,
        },
        "runtime": {
            "file": display_path(args.runtime),
            "sha256": sha256(args.runtime),
            "width": atlas.width,
            "height": atlas.height,
            "mode": atlas.mode,
            "tga_header": header,
            "visible_bbox_exclusive": visible_bbox(atlas),
            "visible_green_spill_pixels": green_spill_pixels(atlas),
            **alpha_evidence(atlas),
        },
        "simulation": {
            "atlas_preview": {
                "file": display_path(args.atlas_preview),
                "sha256": sha256(args.atlas_preview),
                "size": list(atlas.size),
            },
            "real_layout_preview": {
                "file": display_path(args.real_layout_preview),
                "sha256": sha256(args.real_layout_preview),
                "size": list(real_layout.size),
                "runtime_scale_percent": 100,
                "shell": display_path(SHELL_RUNTIME),
                "row_count": ROW_COUNT,
                "row_box": list(ROW_BOX),
                "row_step": ROW_STEP,
                "list_origin": list(LIST_ORIGIN),
                "content": (
                    "representative localized quest titles, levels, headers, "
                    "tracking states and right-page text at realistic density"
                ),
                "z_order": [
                    "QL-A2 accepted runtime shell",
                    "QL-B1 accepted runtime marks",
                    "runtime-localized text",
                    "simplified placeholders for pending QL-C controls",
                ],
                "authoritative_for": [
                    "QL-B1 target-size legibility",
                    "23-row density",
                    "safe-area and z-order review",
                ],
                "not_authoritative_for": [
                    "pending QL-B2, QL-B3, QL-C or QL-D artwork",
                    "Turtle WoW rendering, filtering, hit regions or font loading",
                ],
            },
        },
        "layout_contract": {
            "row_objects": "QuestLogTitle1..23",
            "row_count": ROW_COUNT,
            "row_box": list(ROW_BOX),
            "row_step": ROW_STEP,
            "total_height": (ROW_COUNT - 1) * ROW_STEP + ROW_BOX[1],
            "list_safe_area": [64, 64, 246, 324],
            "right_reserved": 22,
            "region_toggle_display_size": [12, 12],
            "list_check_display_size": [10, 10],
        },
        "state_mapping": {
            "quest_index": (
                "visible row id + FauxScrollFrame_GetOffset("
                "QuestLogListScrollFrame)"
            ),
            "collapsed": "isHeader and isCollapsed",
            "expanded": "isHeader and not isCollapsed",
            "untracked": "not isHeader and not IsQuestWatched(questIndex)",
            "tracked": "not isHeader and IsQuestWatched(questIndex)",
        },
        "ownership": {
            "row_button": (
                "QuestLogTitleN retains all click scripts and selection behavior"
            ),
            "region_toggle": (
                "non-interactive ARTWORK Texture attached to QuestLogTitleN"
            ),
            "list_check": (
                "non-interactive ARTWORK Texture attached to QuestLogTitleN; "
                "QuestLogTitleNCheck remains the native state visual and is "
                "hidden only while AEUI has the required tracking API"
            ),
        },
        "implementation": {
            "exporter": display_path(Path(__file__)),
            "adapter": "addon/AzerothExpeditionUI/Modules/Quests.lua",
            "source_manifest": display_path(args.source_manifest),
            "imagegen_calls_after_acceptance": 0,
            "static_tests_required": True,
            "game_validated": False,
        },
    }
    args.manifest.parent.mkdir(parents=True, exist_ok=True)
    args.manifest.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    update_source_manifest(
        args.source_manifest,
        args.manifest,
        args.runtime,
    )
    print(json.dumps(manifest, ensure_ascii=False))


if __name__ == "__main__":
    main()
