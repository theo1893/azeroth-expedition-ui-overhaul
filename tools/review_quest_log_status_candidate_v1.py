#!/usr/bin/env python3
"""Build deterministic QL-B3 candidate atlases and a 23-row runtime preview.

This is a review-only tool. It never promotes source art or writes addon media.
Missing neighboring QL-B3 batches are rendered as neutral placeholders and are
recorded as non-authoritative in the sidecar report.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
QL_B1_BUILDER = ROOT / "tools" / "build_quest_log_directory_marks_v1.py"
B1_ATLAS = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestLogDirectoryMarksV1.tga"
)
B1_MANIFEST = (
    ROOT
    / "assets"
    / "source"
    / "quests"
    / "ql-b1"
    / "QL-B1_RuntimeManifest_v1.json"
)
B2_ATLAS = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestLogSelectionBookmarkV1.tga"
)
SHELL = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestLogShellV4.tga"
)

SOURCE_SIZE = (1024, 1024)
ROW_COUNT = 23
ROW_STEP = 14
LIST_ORIGIN = (64, 64)
ROW_WIDTH = 224
TEXT_X = 18
TEXT_WIDTH = 155
TYPE_X = 176
TIMER_X = 187
STATE_X = 198
TRACK_X = 212
RESAMPLE = Image.Resampling.LANCZOS

TYPE_STATES = ("elite", "dungeon", "raid", "pvp")
STATE_STATES = ("complete", "failed")

ROWS: tuple[dict[str, Any], ...] = (
    {"kind": "header-expanded", "label": "东瘟疫之地"},
    {
        "kind": "quest",
        "label": "[60+] 达隆郡的战斗与幸存者名册",
        "tracked": True,
        "type": "elite",
        "timed": True,
        "state": "complete",
    },
    {"kind": "quest", "label": "[60]  爱与家庭", "tracked": False},
    {
        "kind": "quest",
        "label": "[60+] 重铸秩序",
        "tracked": True,
        "type": "elite",
        "state": "failed",
    },
    {
        "kind": "quest",
        "label": "[60P] 东瘟疫之地的战场密令",
        "tracked": False,
        "type": "pvp",
        "timed": True,
    },
    {"kind": "header-expanded", "label": "黑石山"},
    {
        "kind": "quest",
        "label": "[60D] 黑手的命令",
        "tracked": True,
        "type": "dungeon",
    },
    {
        "kind": "quest",
        "label": "[60R] 达基萨斯将军之死与王座回报",
        "tracked": True,
        "type": "raid",
        "timed": True,
        "state": "complete",
        "selected": True,
    },
    {
        "kind": "quest",
        "label": "[60R] 黑龙勇士之血",
        "tracked": False,
        "type": "raid",
        "state": "failed",
    },
    {
        "kind": "quest",
        "label": "[58D] 烈焰精华",
        "tracked": False,
        "type": "dungeon",
        "state": "complete",
    },
    {"kind": "header-expanded", "label": "希利苏斯"},
    {
        "kind": "quest",
        "label": "[60P] 暮光前线的军旗",
        "tracked": True,
        "type": "pvp",
    },
    {
        "kind": "quest",
        "label": "[60]  暮光的秘密",
        "tracked": False,
        "state": "complete",
    },
    {
        "kind": "quest",
        "label": "[60R] 唤醒沉睡者",
        "tracked": False,
        "type": "raid",
    },
    {
        "kind": "quest",
        "label": "[60+] 塞纳里奥议会的紧急征召",
        "tracked": True,
        "type": "elite",
        "timed": True,
    },
    {"kind": "header-collapsed", "label": "冬泉谷"},
    {"kind": "header-expanded", "label": "安戈洛环形山"},
    {
        "kind": "quest",
        "label": "[55D] 拉克维的诱饵",
        "tracked": False,
        "type": "dungeon",
    },
    {
        "kind": "quest",
        "label": "[56P] 走丢了！",
        "tracked": True,
        "type": "pvp",
        "state": "failed",
    },
    {
        "kind": "quest",
        "label": "[57]  火羽山",
        "tracked": False,
        "state": "complete",
    },
    {"kind": "header-expanded", "label": "职业任务"},
    {
        "kind": "quest",
        "label": "[60+] 久远的记忆",
        "tracked": True,
        "type": "elite",
    },
    {"kind": "quest", "label": "[60]  恐惧谷的灵魂", "tracked": False},
)


def load_ql_b1_builder() -> Any:
    spec = importlib.util.spec_from_file_location(
        "aeui_ql_b1_builder_for_status_review",
        QL_B1_BUILDER,
    )
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load {QL_B1_BUILDER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


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


def scale_to_fit(image: Image.Image, target: tuple[int, int]) -> Image.Image:
    ratio = min(target[0] / image.width, target[1] / image.height)
    size = (
        max(1, round(image.width * ratio)),
        max(1, round(image.height * ratio)),
    )
    return clear_transparent_rgb(image.resize(size, RESAMPLE))


def load_candidate(path: Path) -> Image.Image:
    with Image.open(path) as opened:
        image = opened.convert("RGBA")
    if image.size != SOURCE_SIZE:
        raise ValueError(f"{path} must be 1024 x 1024, got {image.size}")
    return clear_transparent_rgb(image)


def make_atlas(
    source: Image.Image,
    *,
    states: tuple[str, ...],
    source_boxes: tuple[tuple[int, int, int, int], ...],
    safe_boxes: tuple[tuple[int, int, int, int], ...],
    content_size: tuple[int, int],
) -> tuple[Image.Image, dict[str, Any]]:
    atlas = Image.new("RGBA", (16 * len(states), 16), (0, 0, 0, 0))
    records: dict[str, Any] = {}
    for index, (state, source_box, safe_box) in enumerate(
        zip(states, source_boxes, safe_boxes, strict=True)
    ):
        cell = source.crop(source_box)
        bounds = cell.getchannel("A").getbbox()
        if not bounds:
            raise ValueError(f"{state} has no visible pixels")
        cropped = clear_transparent_rgb(cell.crop(bounds))
        scaled = scale_to_fit(cropped, content_size)
        paste = (
            index * 16 + (16 - scaled.width) // 2,
            (16 - scaled.height) // 2,
        )
        atlas.alpha_composite(scaled, paste)
        records[state] = {
            "source_cell_xyxy": list(source_box),
            "source_visible_bbox_local_exclusive": list(bounds),
            "source_visible_size": [
                bounds[2] - bounds[0],
                bounds[3] - bounds[1],
            ],
            "source_safe_box_local_exclusive": list(safe_box),
            "source_safe_box_pass": (
                bounds[0] >= safe_box[0]
                and bounds[1] >= safe_box[1]
                and bounds[2] <= safe_box[2]
                and bounds[3] <= safe_box[3]
            ),
            "runtime_cell_xyxy": [index * 16, 0, index * 16 + 16, 16],
            "runtime_content_xyxy": [
                paste[0],
                paste[1],
                paste[0] + scaled.width,
                paste[1] + scaled.height,
            ],
            "runtime_display_size": [scaled.width, scaled.height],
        }
    return clear_transparent_rgb(atlas), records


def type_atlas(path: Path) -> tuple[Image.Image, dict[str, Any]]:
    return make_atlas(
        load_candidate(path),
        states=TYPE_STATES,
        source_boxes=(
            (0, 0, 512, 512),
            (512, 0, 1024, 512),
            (0, 512, 512, 1024),
            (512, 512, 1024, 1024),
        ),
        safe_boxes=((128, 128, 384, 384),) * 4,
        content_size=(10, 10),
    )


def timer_atlas(path: Path) -> tuple[Image.Image, dict[str, Any]]:
    return make_atlas(
        load_candidate(path),
        states=("timed",),
        source_boxes=((0, 0, 1024, 1024),),
        safe_boxes=((352, 352, 672, 672),),
        content_size=(10, 10),
    )


def state_atlas(path: Path) -> tuple[Image.Image, dict[str, Any]]:
    return make_atlas(
        load_candidate(path),
        states=STATE_STATES,
        source_boxes=((0, 0, 512, 1024), (512, 0, 1024, 1024)),
        safe_boxes=((128, 384, 384, 640),) * 2,
        content_size=(12, 12),
    )


def placeholder_atlas(kind: str) -> tuple[Image.Image, dict[str, Any]]:
    states = TYPE_STATES if kind == "type" else (
        ("timed",) if kind == "timer" else STATE_STATES
    )
    atlas = Image.new("RGBA", (16 * len(states), 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(atlas, "RGBA")
    records: dict[str, Any] = {}
    for index, state in enumerate(states):
        left = index * 16
        if kind == "timer":
            draw.polygon(
                ((left + 4, 3), (left + 12, 3), (left + 8, 8)),
                outline=(92, 82, 70, 150),
            )
            draw.polygon(
                ((left + 4, 13), (left + 12, 13), (left + 8, 8)),
                outline=(92, 82, 70, 150),
            )
            box = [left + 3, 2, left + 13, 14]
        elif kind == "state":
            draw.ellipse(
                (left + 2, 2, left + 14, 14),
                outline=(92, 82, 70, 150),
                width=1,
            )
            if state == "failed":
                draw.line(
                    (left + 5, 3, left + 10, 13),
                    fill=(92, 82, 70, 150),
                    width=1,
                )
            box = [left + 2, 2, left + 15, 15]
        else:
            draw.rectangle(
                (left + 3, 3, left + 12, 12),
                outline=(92, 82, 70, 120),
                width=1,
            )
            box = [left + 3, 3, left + 13, 13]
        records[state] = {
            "runtime_cell_xyxy": [left, 0, left + 16, 16],
            "runtime_content_xyxy": box,
            "placeholder": True,
        }
    return atlas, records


def sprite(
    atlas: Image.Image,
    records: dict[str, Any],
    state: str,
) -> Image.Image:
    return atlas.crop(tuple(records[state]["runtime_content_xyxy"]))


def load_b1() -> tuple[Image.Image, dict[str, Any]]:
    with Image.open(B1_ATLAS) as opened:
        atlas = opened.convert("RGBA")
    manifest = json.loads(B1_MANIFEST.read_text(encoding="utf-8"))
    return atlas, manifest["transform"]["states"]


def paste_b1(
    preview: Image.Image,
    atlas: Image.Image,
    records: dict[str, Any],
    state: str,
    xy: tuple[int, int],
) -> None:
    preview.alpha_composite(
        atlas.crop(tuple(records[state]["runtime_content_xyxy"])),
        xy,
    )


def draw_clipped_row_text(
    preview: Image.Image,
    value: str,
    text_font: ImageFont.FreeTypeFont,
    color: tuple[int, int, int, int],
    xy: tuple[int, int],
) -> None:
    layer = Image.new("RGBA", (TEXT_WIDTH, 15), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer, "RGBA")
    draw.text((1, 1), value, font=text_font, fill=(238, 196, 124, 80))
    draw.text((0, 0), value, font=text_font, fill=color)
    preview.alpha_composite(layer, xy)


def render_preview(
    *,
    atlases: dict[str, Image.Image],
    records: dict[str, dict[str, Any]],
    placeholders: list[str],
) -> Image.Image:
    ql_b1 = load_ql_b1_builder()
    with Image.open(SHELL) as opened:
        preview = opened.convert("RGBA").crop((0, 0, 676, 464))
    b1_atlas, b1_records = load_b1()
    with Image.open(B2_ATLAS) as opened:
        selection = opened.convert("RGBA").crop((0, 0, 32, 16))

    draw = ImageDraw.Draw(preview, "RGBA")
    title_font = ql_b1.font(ql_b1.TITLE_FONT, 15)
    row_font = ql_b1.font(ql_b1.ROW_FONT, 10)
    header_font = ql_b1.font(ql_b1.ROW_FONT, 11)
    body_font = ql_b1.font(ql_b1.BODY_FONT, 9)
    body_heading = ql_b1.font(ql_b1.TITLE_FONT, 11)
    ql_b1.draw_text(draw, (300, 27), "任务日志", title_font, (49, 26, 16, 255))
    ql_b1.draw_text(draw, (76, 49), "任务  18 / 20", row_font, (76, 43, 25, 235))

    for index, row in enumerate(ROWS):
        row_x = LIST_ORIGIN[0]
        row_y = LIST_ORIGIN[1] + index * ROW_STEP
        kind = row["kind"]
        if kind.startswith("header"):
            mark = "expanded" if kind == "header-expanded" else "collapsed"
            paste_b1(
                preview,
                b1_atlas,
                b1_records,
                mark,
                (row_x + 1, row_y + 1),
            )
            ql_b1.draw_text(
                draw,
                (row_x + 16, row_y + 1),
                row["label"],
                header_font,
                (72, 38, 19, 255),
            )
            continue

        if row.get("selected"):
            preview.alpha_composite(selection, (row_x - 12, row_y - 1))

        tracked = bool(row.get("tracked"))
        paste_b1(
            preview,
            b1_atlas,
            b1_records,
            "tracked" if tracked else "untracked",
            (row_x + TRACK_X, row_y + 2),
        )
        if row.get("type"):
            icon = sprite(atlases["type"], records["type"], row["type"])
            preview.alpha_composite(
                icon,
                (row_x + TYPE_X, row_y + (15 - icon.height) // 2),
            )
        if row.get("timed"):
            icon = sprite(atlases["timer"], records["timer"], "timed")
            preview.alpha_composite(
                icon,
                (row_x + TIMER_X, row_y + (15 - icon.height) // 2),
            )
        if row.get("state"):
            icon = sprite(atlases["state"], records["state"], row["state"])
            preview.alpha_composite(
                icon,
                (row_x + STATE_X, row_y + (15 - icon.height) // 2),
            )
        draw_clipped_row_text(
            preview,
            row["label"],
            row_font,
            (57, 30, 19, 255)
            if row.get("selected")
            else ((62, 39, 23, 255) if tracked else (89, 61, 38, 235)),
            (row_x + TEXT_X, row_y + 2),
        )

    detail_left = 374
    detail_width = 226
    ql_b1.draw_text(
        draw,
        (detail_left, 68),
        "达基萨斯将军之死",
        title_font,
        (55, 28, 17, 255),
    )
    ql_b1.draw_text(
        draw,
        (detail_left, 91),
        "黑石塔上层",
        row_font,
        (105, 57, 28, 235),
    )
    y = 111
    description = (
        "深入黑石塔上层，击败达基萨斯将军，并把战斗结果写入远征卷宗。"
        "左页状态槽使用真实任务密度，长任务名按一百五十五像素安全区裁切。"
    )
    for line in ql_b1.wrap_text(draw, description, body_font, detail_width):
        ql_b1.draw_text(draw, (detail_left, y), line, body_font, (69, 48, 31, 245))
        y += 13
    y += 5
    ql_b1.draw_text(
        draw,
        (detail_left, y),
        "任务目标",
        body_heading,
        (64, 31, 18, 255),
    )
    y += 19
    for line in (
        "• 达基萨斯将军的首级  0 / 1",
        "• 返回暴风城复命",
        "• 在限时结束前完成远征",
    ):
        ql_b1.draw_text(draw, (detail_left, y), line, body_font, (74, 49, 31, 245))
        y += 14
    y += 5
    ql_b1.draw_text(draw, (detail_left, y), "奖励", body_heading, (64, 31, 18, 255))
    y += 19
    ql_b1.draw_text(
        draw,
        (detail_left, y),
        "你将获得：  9 金  80 银",
        body_font,
        (74, 49, 31, 245),
    )
    if placeholders:
        ql_b1.draw_text(
            draw,
            (detail_left, 355),
            "灰色状态图形仅为未完成邻件占位",
            body_font,
            (103, 76, 55, 210),
        )

    for x, label in ((62, "放弃任务"), (145, "共享任务"), (228, "退出")):
        draw.rounded_rectangle(
            (x, 421, x + 78, 441),
            radius=3,
            fill=(51, 34, 25, 220),
            outline=(116, 78, 44, 235),
            width=1,
        )
        bounds = draw.textbbox((0, 0), label, font=row_font)
        ql_b1.draw_text(
            draw,
            (x + (78 - (bounds[2] - bounds[0])) // 2, 425),
            label,
            row_font,
            (225, 184, 108, 255),
        )
    ql_b1.draw_text(draw, (314, 425), "›", title_font, (82, 47, 27, 255))
    return preview


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--focus", choices=("type", "timer", "state"), required=True)
    parser.add_argument("--type-candidate", type=Path)
    parser.add_argument("--timer-candidate", type=Path)
    parser.add_argument("--state-candidate", type=Path)
    parser.add_argument("--output-dir", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    candidates = {
        "type": args.type_candidate,
        "timer": args.timer_candidate,
        "state": args.state_candidate,
    }
    builders = {
        "type": type_atlas,
        "timer": timer_atlas,
        "state": state_atlas,
    }
    atlases: dict[str, Image.Image] = {}
    records: dict[str, dict[str, Any]] = {}
    placeholders: list[str] = []
    candidate_hashes: dict[str, str] = {}
    for kind in ("type", "timer", "state"):
        path = candidates[kind]
        if path:
            if not path.is_file():
                raise FileNotFoundError(path)
            atlases[kind], records[kind] = builders[kind](path)
            candidate_hashes[kind] = sha256(path)
        else:
            atlases[kind], records[kind] = placeholder_atlas(kind)
            placeholders.append(kind)

    args.output_dir.mkdir(parents=True, exist_ok=True)
    for kind, atlas in atlases.items():
        save_png(atlas, args.output_dir / f"{kind}_runtime_atlas.png")
    preview_path = args.output_dir / "real_layout_676x464.png"
    save_png(
        render_preview(
            atlases=atlases,
            records=records,
            placeholders=placeholders,
        ),
        preview_path,
    )
    report = {
        "schema": "aeui-ql-b3-review-preview-v1",
        "focus": args.focus,
        "runtime_size": [676, 464],
        "runtime_scale_percent": 100,
        "row_count": ROW_COUNT,
        "row_box": [ROW_WIDTH, 15],
        "row_step": ROW_STEP,
        "text_safe_area": [TEXT_X, 0, TEXT_X + TEXT_WIDTH, 15],
        "status_slots": {
            "type": [TYPE_X, 10, 10],
            "timer": [TIMER_X, 10, 10],
            "state": [STATE_X, 12, 12],
            "tracking": [TRACK_X, 10, 10],
        },
        "candidate_sha256": candidate_hashes,
        "records": records,
        "non_authoritative_placeholders": placeholders,
        "surrounding_runtime": [
            "QuestLogShellV4.tga",
            "QuestLogDirectoryMarksV1.tga",
            "QuestLogSelectionBookmarkV1.tga",
        ],
        "preview": {
            "file": preview_path.resolve().relative_to(ROOT).as_posix(),
            "sha256": sha256(preview_path),
        },
    }
    report_path = args.output_dir / "review_preview.json"
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(report_path.resolve())


if __name__ == "__main__":
    main()
