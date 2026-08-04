#!/usr/bin/env python3
"""Render the deterministic QL-D reward-slot direction preview."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, ImageFont


INK = (36, 23, 15, 255)
SECTION = (59, 37, 23, 255)
MUTED = (102, 81, 59, 255)
QUEST_TYPE = (47, 18, 54, 255)
LEATHER = (60, 31, 19, 248)
LEATHER_DARK = (30, 15, 10, 252)
BRASS = (125, 82, 33, 235)
BRASS_LIGHT = (173, 124, 56, 235)
PAPER = (178, 139, 79, 220)
PAPER_LIGHT = (195, 157, 94, 225)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    return parser.parse_args()


def resolve(root: Path, value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else root / path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(
        str(path), size, layout_engine=ImageFont.Layout.BASIC
    )


def text_width(
    draw: ImageDraw.ImageDraw,
    value: str,
    face: ImageFont.FreeTypeFont,
) -> float:
    return draw.textlength(value, font=face)


def wrap_characters(
    draw: ImageDraw.ImageDraw,
    value: str,
    face: ImageFont.FreeTypeFont,
    maximum: int,
) -> list[str]:
    lines: list[str] = []
    current = ""
    for character in value:
        if character == "\n":
            lines.append(current)
            current = ""
            continue
        candidate = current + character
        if current and text_width(draw, candidate, face) > maximum:
            lines.append(current)
            current = character
        else:
            current = candidate
    if current:
        lines.append(current)
    return lines


def draw_text_block(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    value: str,
    face: ImageFont.FreeTypeFont,
    fill: tuple[int, int, int, int],
    width: int,
    line_height: int,
) -> int:
    x, y = xy
    for line in wrap_characters(draw, value, face, width):
        draw.text((x, y), line, font=face, fill=fill)
        y += line_height
    return y


def draw_icon(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    palette: tuple[tuple[int, int, int, int], ...],
    index: int,
) -> None:
    x0, y0, x1, y1 = box
    draw.rectangle(box, fill=palette[0])
    draw.polygon(
        [
            (x0 + 5, y1 - 7),
            (x0 + 13, y0 + 5),
            (x1 - 5, y0 + 10),
            (x1 - 10, y1 - 5),
        ],
        fill=palette[1],
    )
    if index % 2:
        draw.line(
            (x0 + 7, y1 - 7, x1 - 7, y0 + 7),
            fill=palette[2],
            width=3,
        )
    else:
        draw.ellipse(
            (x0 + 9, y0 + 8, x1 - 7, y1 - 8),
            fill=palette[2],
        )


def draw_reward_slot(
    image: Image.Image,
    box: list[int],
    item: dict[str, Any],
    face: ImageFont.FreeTypeFont,
    index: int,
) -> None:
    x, y, width, height = box
    state = item["state"]
    pressed_offset = 1 if state == "pressed" else 0
    layer = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer, "RGBA")

    silhouette = [
        (x + 3, y),
        (x + width - 4, y),
        (x + width - 1, y + 3),
        (x + width - 1, y + height - 4),
        (x + width - 4, y + height - 1),
        (x + 3, y + height - 1),
        (x, y + height - 4),
        (x, y + 3),
    ]
    draw.polygon(
        [(px + 1, py + 2) for px, py in silhouette],
        fill=(31, 17, 11, 135),
    )

    outer_fill = LEATHER
    outer_edge = BRASS
    label_fill = PAPER
    if state == "hover":
        outer_edge = BRASS_LIGHT
        label_fill = PAPER_LIGHT
    elif state == "pressed":
        outer_fill = (47, 23, 15, 250)
        label_fill = (157, 117, 67, 225)
    elif state == "disabled":
        outer_fill = (55, 45, 36, 220)
        outer_edge = (99, 82, 57, 180)
        label_fill = (151, 128, 92, 185)

    draw.polygon(silhouette, fill=outer_fill, outline=outer_edge)
    draw.line(
        (x + 5, y + 2, x + width - 6, y + 2),
        fill=(190, 138, 61, 120),
        width=1,
    )

    icon_well = (x + 3, y + 3, x + 39, y + height - 4)
    draw.rectangle(icon_well, fill=LEATHER_DARK, outline=outer_edge)
    draw.rectangle(
        (x + 40, y + 3, x + width - 4, y + height - 4),
        fill=label_fill,
        outline=(87, 55, 28, 190),
    )
    draw.line(
        (x + 42, y + height - 5, x + width - 6, y + height - 5),
        fill=(92, 55, 27, 120),
        width=1,
    )

    palettes = (
        ((48, 55, 61, 255), (108, 119, 125, 255), (210, 190, 129, 255)),
        ((33, 52, 88, 255), (61, 121, 190, 255), (187, 229, 250, 255)),
        ((67, 39, 29, 255), (145, 88, 42, 255), (223, 176, 87, 255)),
        ((38, 58, 38, 255), (71, 126, 68, 255), (181, 204, 96, 255)),
        ((66, 45, 78, 255), (132, 89, 148, 255), (223, 181, 234, 255)),
        ((71, 38, 32, 255), (151, 65, 50, 255), (236, 160, 103, 255)),
    )
    draw_icon(
        draw,
        (
            x + 5 + pressed_offset,
            y + 5 + pressed_offset,
            x + 37 + pressed_offset,
            y + height - 6 + pressed_offset,
        ),
        palettes[index % len(palettes)],
        index,
    )

    text_fill = MUTED if state == "disabled" else INK
    draw.text(
        (x + 44 + pressed_offset, y + height // 2 + pressed_offset),
        item["name"],
        font=face,
        fill=text_fill,
        anchor="lm",
    )
    count = int(item.get("count", 1))
    if count > 1:
        value = str(count)
        count_x = x + 35 + pressed_offset
        count_y = y + height - 5 + pressed_offset
        draw.text(
            (count_x + 1, count_y + 1),
            value,
            font=face,
            fill=(18, 11, 7, 245),
            anchor="rs",
        )
        draw.text(
            (count_x, count_y),
            value,
            font=face,
            fill=(239, 218, 170, 255),
            anchor="rs",
        )

    image.alpha_composite(layer)


def reward_boxes(spec: dict[str, Any]) -> list[list[int]]:
    layout = spec["layout"]
    x, y = layout["reward_origin"]
    width, height = layout["reward_slot_size"]
    column_gap = layout["reward_column_gap"]
    row_gap = layout["reward_row_gap"]
    return [
        [
            x + (position % 2) * (width + column_gap),
            y + (position // 2) * (height + row_gap),
            width,
            height,
        ]
        for position in range(6)
    ]


def validate_geometry(spec: dict[str, Any], boxes: list[list[int]]) -> None:
    _, _, safe_width, safe_height = spec["layout"]["detail_content"]
    content_x, content_y, _, _ = spec["layout"]["detail_content"]
    for index, (x, y, width, height) in enumerate(boxes, start=1):
        if x < content_x or y < content_y:
            raise ValueError(f"reward {index} starts outside detail content")
        if x + width > content_x + safe_width:
            raise ValueError(f"reward {index} exceeds detail content width")
        if y + height > content_y + safe_height:
            raise ValueError(f"reward {index} exceeds detail content height")
    first, second, third = boxes[0], boxes[1], boxes[2]
    if second[0] - (first[0] + first[2]) != spec["layout"]["reward_column_gap"]:
        raise ValueError("reward column gap mismatch")
    if third[1] - (first[1] + first[3]) != spec["layout"]["reward_row_gap"]:
        raise ValueError("reward row gap mismatch")


def render(root: Path, spec: dict[str, Any]) -> dict[str, Any]:
    inputs = spec["inputs"]
    outputs = spec["outputs"]
    shell_path = resolve(root, inputs["quest_log_shell"])
    seal_path = resolve(root, inputs["seal_atlas"])
    title_font_path = resolve(root, inputs["title_font"])
    body_font_path = resolve(root, inputs["body_font"])
    output_path = resolve(root, outputs["preview"])
    review_path = resolve(root, outputs["review_2x"])
    report_path = resolve(root, outputs["report"])
    output_path.parent.mkdir(parents=True, exist_ok=True)

    frame_width, frame_height = spec["frame"]
    shell = Image.open(shell_path).convert("RGBA")
    if shell.width < frame_width or shell.height < frame_height:
        raise ValueError("runtime shell is smaller than the Quest Log frame")
    image = shell.crop((0, 0, frame_width, frame_height))
    draw = ImageDraw.Draw(image, "RGBA")
    title_face = load_font(title_font_path, 14)
    body_face = load_font(body_font_path, 12)
    small_face = load_font(body_font_path, 10)

    # Representative left page: the type suffixes deliberately use the same
    # quiet semantic ink, independent of the quest difficulty colour.
    draw.text((82, 35), "任务：17/20", font=title_face, fill=SECTION)
    directory = [
        ("日常任务", None),
        ("[60] 动员号令：地下城清剿", "（地下城）"),
        ("[60+] 黎明先锋", "（精英）"),
        ("[60+] 黑石塔突袭", "（团队）"),
        ("月语海岸", None),
        ("[55] 扭曲的同胞", None),
        ("[56] 仪式准备", None),
        ("通灵学院", None),
        ("[60+] 黎明先锋", "（地下城）"),
        ("[58+] 烈焰精华", "（精英）"),
    ]
    y = 66
    for label, tag in directory:
        if tag is None and not label.startswith("["):
            draw.polygon([(75, y + 3), (82, y + 7), (75, y + 11)], fill=(83, 47, 18, 255))
            draw.text((88, y), label, font=body_face, fill=SECTION)
        else:
            draw.text((101, y), label, font=body_face, fill=INK)
            if tag:
                draw.text((310, y), tag, font=body_face, fill=QUEST_TYPE, anchor="ra")
        y += 25 if tag is None and not label.startswith("[") else 20

    # Reward-focused scroll state. All glyphs are dynamic preview content and
    # are never part of the proposed bitmap container.
    draw.text((376, 74), "……把蛛卵带回城镇。", font=body_face, fill=INK)
    draw.text((376, 103), "奖励", font=title_face, fill=SECTION)
    draw.text((376, 127), "你可以从这些奖励中选择一件：", font=body_face, fill=SECTION)

    boxes = reward_boxes(spec)
    validate_geometry(spec, boxes)
    items = spec["content"]["items"]
    for index in range(2):
        draw_reward_slot(image, boxes[index], items[index], body_face, index)

    second_heading_y = boxes[0][1] + boxes[0][3] + 5
    draw.text((376, second_heading_y), "你还将得到：", font=body_face, fill=SECTION)
    guaranteed_origin_y = second_heading_y + 19
    delta = guaranteed_origin_y - boxes[2][1]
    for index in range(2, 6):
        shifted = list(boxes[index])
        shifted[1] += delta
        boxes[index] = shifted
        draw_reward_slot(image, shifted, items[index], body_face, index)

    last_bottom = boxes[5][1] + boxes[5][3]
    draw.text((376, last_bottom + 7), "奖励金钱：", font=body_face, fill=SECTION)
    draw.ellipse((438, last_bottom + 6, 449, last_bottom + 17), fill=(189, 144, 36, 255), outline=(104, 72, 25, 255))
    draw.text((454, last_bottom + 7), "8", font=small_face, fill=INK)
    draw.ellipse((468, last_bottom + 6, 479, last_bottom + 17), fill=(155, 147, 126, 255), outline=(91, 82, 65, 255))
    draw.text((484, last_bottom + 7), "67", font=small_face, fill=INK)

    seal_atlas = Image.open(seal_path).convert("RGBA")
    cell_width = seal_atlas.width // 4
    seal = seal_atlas.crop((0, 0, cell_width, seal_atlas.height))
    seal = seal.resize((32, 32), Image.Resampling.LANCZOS)
    image.alpha_composite(seal, (576, 68))

    image.save(output_path, optimize=True)
    review = image.resize(
        (frame_width * 2, frame_height * 2),
        Image.Resampling.NEAREST,
    )
    review.save(review_path, optimize=True)

    report = {
        "schema": "aeui.quest-log.reward-slots.simulation-report.v1",
        "component": spec["component"],
        "status": "pass",
        "imagegen_calls": 0,
        "frame": spec["frame"],
        "reward_slot_size": spec["layout"]["reward_slot_size"],
        "reward_column_gap": spec["layout"]["reward_column_gap"],
        "reward_row_gap": spec["layout"]["reward_row_gap"],
        "rendered_reward_count": len(items),
        "states": [item["state"] for item in items],
        "inputs": {
            "quest_log_shell": {"path": inputs["quest_log_shell"], "sha256": sha256(shell_path)},
            "seal_atlas": {"path": inputs["seal_atlas"], "sha256": sha256(seal_path)},
            "title_font": {"path": inputs["title_font"], "sha256": sha256(title_font_path)},
            "body_font": {"path": inputs["body_font"], "sha256": sha256(body_font_path)},
        },
        "outputs": {
            "preview": {"path": outputs["preview"], "sha256": sha256(output_path)},
            "review_2x": {"path": outputs["review_2x"], "sha256": sha256(review_path)},
        },
        "non_authoritative": True,
        "next_gate": "user-visible-direction-confirmation",
    }
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return report


def main() -> int:
    args = parse_args()
    root = args.repo_root.resolve()
    spec = json.loads(args.spec.read_text(encoding="utf-8"))
    report = render(root, spec)
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
