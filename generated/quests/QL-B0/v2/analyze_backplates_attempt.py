from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(r"D:\Git\azeroth-expedition-ui-overhaul")
PARSER = argparse.ArgumentParser()
PARSER.add_argument("--attempt", required=True, type=Path)
PARSER.add_argument("--candidate", required=True, type=Path)
PARSER.add_argument("--output-token", required=True)
ARGS = PARSER.parse_args()
ATTEMPT = ARGS.attempt.resolve()
CANDIDATE = ARGS.candidate.resolve()
PREVIEWS = ATTEMPT / "previews"
SHELL = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestLogShellV4.tga"
)
MARKS = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestLogDirectoryMarksV1.tga"
)
SELECTION = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestLogSelectionBookmarkV1.tga"
)
HEADER_FONT = (
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

REGION_TARGET = (112, 272, 912, 336)
ROW_TARGET = (112, 688, 912, 752)
LIST_POSITION = (64, 64)
ROW_SIZE = (224, 18)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def global_bbox(alpha: Image.Image, vertical_range: tuple[int, int]) -> tuple[int, int, int, int]:
    y0, y1 = vertical_range
    local = alpha.crop((0, y0, alpha.width, y1)).getbbox()
    if local is None:
        raise RuntimeError(f"No visible object in y={y0}..{y1}")
    return local[0], local[1] + y0, local[2], local[3] + y0


def normalized_bbox(
    bbox: tuple[int, int, int, int], native_size: tuple[int, int]
) -> list[int]:
    width, height = native_size
    return [
        round(bbox[0] * 1024 / width),
        round(bbox[1] * 1024 / height),
        round(bbox[2] * 1024 / width),
        round(bbox[3] * 1024 / height),
    ]


def paste_alpha(canvas: Image.Image, image: Image.Image, xy: tuple[int, int]) -> None:
    canvas.alpha_composite(image, xy)


def render_layout(
    region: Image.Image,
    row: Image.Image,
    output: Path,
    label: str,
) -> None:
    shell_atlas = Image.open(SHELL).convert("RGBA")
    canvas = shell_atlas.crop((0, 0, 676, 464))
    marks = Image.open(MARKS).convert("RGBA")
    selection = Image.open(SELECTION).convert("RGBA")
    collapsed = marks.crop((0, 0, 16, 16))
    expanded = marks.crop((16, 0, 32, 16))
    untracked = marks.crop((32, 0, 48, 16))
    tracked = marks.crop((48, 0, 64, 16))
    selected = selection.crop((0, 0, 32, 16))

    draw = ImageDraw.Draw(canvas)
    header_font = ImageFont.truetype(str(HEADER_FONT), 12)
    row_font = ImageFont.truetype(str(ROW_FONT), 11)
    title_font = ImageFont.truetype(str(HEADER_FONT), 18)
    detail_font = ImageFont.truetype(str(ROW_FONT), 13)
    note_font = ImageFont.truetype(str(ROW_FONT), 9)

    rows = [
        ("header-expanded", "奥格瑞玛", (239, 211, 145, 255)),
        ("quest", "夺回希利苏斯", (25, 102, 38, 255)),
        ("header-collapsed", "幻影赛道", (239, 211, 145, 255)),
        ("quest", "《加基森时报》：重大新闻", (158, 116, 8, 255)),
        ("header-expanded", "战士", (239, 211, 145, 255)),
        ("quest", "老兵犹塞克", (48, 43, 36, 255)),
        ("quest", "和鲁迦交谈", (48, 43, 36, 255)),
        ("quest-selected", "岛民", (48, 43, 36, 255)),
        ("header-collapsed", "灰谷", (239, 211, 145, 255)),
        ("quest", "失踪的使节", (48, 43, 36, 255)),
        ("quest-tracked", "深渊中的密令", (32, 83, 34, 255)),
        ("quest", "远古石碑的回声", (48, 43, 36, 255)),
        ("header-expanded", "千针石林", (239, 211, 145, 255)),
        ("quest", "风巢双足飞龙", (48, 43, 36, 255)),
        ("quest", "被遗忘的航线", (48, 43, 36, 255)),
        ("quest-tracked", "闪光平原的秘密", (32, 83, 34, 255)),
        ("quest", "商队失踪案", (48, 43, 36, 255)),
        ("quest", "最后的线索", (48, 43, 36, 255)),
    ]

    for index, (kind, text, color) in enumerate(rows):
        x = LIST_POSITION[0]
        y = LIST_POSITION[1] + index * ROW_SIZE[1]
        is_header = kind.startswith("header")
        paste_alpha(canvas, region if is_header else row, (x, y))
        if kind == "quest-selected":
            paste_alpha(canvas, selected, (x - 12, y + 1))
        if kind == "header-expanded":
            paste_alpha(canvas, expanded, (x, y + 1))
        elif kind == "header-collapsed":
            paste_alpha(canvas, collapsed, (x, y + 1))
        else:
            marker = tracked if kind == "quest-tracked" else untracked
            paste_alpha(canvas, marker, (x + 208, y + 2))
        draw.text(
            (x + 20, y + 1),
            text,
            font=header_font if is_header else row_font,
            fill=color,
        )

    # Current native scrollbar is represented above the non-interactive row art.
    draw.rounded_rectangle((312, 67, 318, 384), radius=2, fill=(50, 35, 25, 190))
    draw.rounded_rectangle((312, 108, 318, 160), radius=2, fill=(129, 103, 66, 255))

    draw.text((338, 18), "任务日志", font=title_font, fill=(247, 231, 190, 255))
    draw.text((558, 44), "任务：8/20", font=header_font, fill=(66, 43, 19, 255))
    draw.text((366, 76), "岛民", font=title_font, fill=(47, 31, 18, 255))
    detail_lines = [
        "和克兰诺克·马克雷德谈一谈。",
        "",
        "描述",
        "作为一名战士，你的名声越传越响。",
        "现在是时候让你和其它战士比试一下，",
        "看看你真正的实力了。",
        "",
        "在贫瘠之地的海岸附近有一座小岛，",
        "强大的战士们时常在那里聚会。",
    ]
    y = 108
    for line in detail_lines:
        draw.text((366, y), line, font=detail_font, fill=(43, 29, 18, 255))
        y += 20
    draw.text((362, 434), label, font=note_font, fill=(91, 52, 28, 255))

    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, format="PNG")


def main() -> None:
    candidate = Image.open(CANDIDATE).convert("RGBA")
    alpha = candidate.getchannel("A")
    region_bbox = global_bbox(alpha, (0, candidate.height // 2))
    row_bbox = global_bbox(alpha, (candidate.height // 2, candidate.height))

    normalized = candidate.resize((1024, 1024), Image.Resampling.LANCZOS)
    strict_region = normalized.crop(REGION_TARGET).resize(ROW_SIZE, Image.Resampling.LANCZOS)
    strict_row = normalized.crop(ROW_TARGET).resize(ROW_SIZE, Image.Resampling.LANCZOS)
    fitted_region = candidate.crop(region_bbox).resize(ROW_SIZE, Image.Resampling.LANCZOS)
    fitted_row = candidate.crop(row_bbox).resize(ROW_SIZE, Image.Resampling.LANCZOS)

    strict_output = PREVIEWS / f"{ARGS.output_token}_contract-layout_676x464.png"
    fitted_output = PREVIEWS / f"{ARGS.output_token}_bboxfit-art-check_676x464.png"
    render_layout(
        strict_region,
        strict_row,
        strict_output,
        "严格 1024 网格裁切；100% runtime；18 行",
    )
    render_layout(
        fitted_region,
        fitted_row,
        fitted_output,
        "非权威 bbox-fit 美术检查；100% runtime；18 行",
    )

    report = {
        "schema": "ql-b0-b-v2-attempt-review-v1",
        "candidate": str(CANDIDATE),
        "candidate_sha256": sha256(CANDIDATE),
        "native_size": list(candidate.size),
        "region": {
            "native_bbox": list(region_bbox),
            "native_size": [
                region_bbox[2] - region_bbox[0],
                region_bbox[3] - region_bbox[1],
            ],
            "normalized_bbox": normalized_bbox(region_bbox, candidate.size),
            "target_bbox": list(REGION_TARGET),
            "target_size": [800, 64],
        },
        "row": {
            "native_bbox": list(row_bbox),
            "native_size": [
                row_bbox[2] - row_bbox[0],
                row_bbox[3] - row_bbox[1],
            ],
            "normalized_bbox": normalized_bbox(row_bbox, candidate.size),
            "target_bbox": list(ROW_TARGET),
            "target_size": [800, 64],
        },
        "strict_layout": {
            "path": str(strict_output),
            "sha256": sha256(strict_output),
            "geometry": [676, 464],
            "runtime_rows": 18,
            "runtime_row_size": [224, 18],
            "scope": "authoritative contract crop; unfinished scrollbar remains a simplified non-authoritative placeholder",
        },
        "bboxfit_layout": {
            "path": str(fitted_output),
            "sha256": sha256(fitted_output),
            "geometry": [676, 464],
            "runtime_rows": 18,
            "runtime_row_size": [224, 18],
            "scope": "non-authoritative art check only; stretches each actual bbox to runtime size",
        },
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
