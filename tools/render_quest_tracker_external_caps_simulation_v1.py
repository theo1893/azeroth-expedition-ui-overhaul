#!/usr/bin/env python3
"""Render and audit the QT-GEO-V1 external-cap geometry proposal.

The output is a local, non-production geometry mockup. It intentionally uses
only flat shapes and real localized text; it does not load or imitate any
generated source asset.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any, Iterable

from PIL import Image, ImageDraw, ImageFont


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Render the deterministic QT-GEO-V1 simulation"
    )
    parser.add_argument("spec", type=Path)
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path.cwd(),
        help="repository root used to resolve fonts and outputs",
    )
    return parser.parse_args()


def rgba(value: str, alpha: int | None = None) -> tuple[int, int, int, int]:
    value = value.removeprefix("#")
    if len(value) == 6:
        red, green, blue = (
            int(value[0:2], 16),
            int(value[2:4], 16),
            int(value[4:6], 16),
        )
        return red, green, blue, 255 if alpha is None else alpha
    if len(value) == 8:
        red, green, blue, source_alpha = (
            int(value[0:2], 16),
            int(value[2:4], 16),
            int(value[4:6], 16),
            int(value[6:8], 16),
        )
        return red, green, blue, source_alpha if alpha is None else alpha
    raise ValueError(f"unsupported color: #{value}")


def rect_xy(x: int, y: int, width: int, height: int) -> tuple[int, int, int, int]:
    if width < 1 or height < 1:
        raise ValueError(f"invalid rectangle size: {width}x{height}")
    return x, y, x + width - 1, y + height - 1


def font(
    repo_root: Path, fonts: dict[str, str], name: str, size: int
) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(
        str(repo_root / fonts[name]),
        size,
        layout_engine=ImageFont.Layout.BASIC,
    )


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def draw_world(
    draw: ImageDraw.ImageDraw,
    width: int,
    height: int,
    body: ImageFont.FreeTypeFont,
    small: ImageFont.FreeTypeFont,
    version: str,
) -> None:
    draw.rectangle(rect_xy(0, 0, width, height), fill=(49, 65, 69, 255))
    draw.rectangle(rect_xy(0, 0, width, 330), fill=(62, 74, 75, 255))
    draw.polygon(
        [(0, 310), (220, 174), (380, 290), (590, 130), (850, 300), (1050, 176),
         (1280, 290), (1535, 160), (1535, 500), (0, 500)],
        fill=(45, 50, 48, 255),
    )
    draw.polygon(
        [(0, 380), (250, 300), (520, 400), (770, 280), (1040, 390),
         (1280, 300), (1535, 380), (1535, 620), (0, 620)],
        fill=(31, 44, 41, 255),
    )
    draw.rectangle(rect_xy(0, 500, width, 360), fill=(36, 69, 72, 255))
    for y in range(520, 835, 29):
        draw.line(
            [(0, y), (width, y + 8)],
            fill=(91, 112, 106, 58),
            width=2,
        )
    draw.polygon(
        [(0, 760), (440, 650), (825, 720), (1270, 610), (1535, 650),
         (1535, 1023), (0, 1023)],
        fill=(58, 48, 37, 255),
    )
    for x in range(-100, 1500, 145):
        draw.polygon(
            [(x, 760), (x + 118, 730), (x + 205, 1023), (x + 40, 1023)],
            fill=(74, 55, 35, 255),
        )
        draw.line([(x + 118, 730), (x + 205, 1023)], fill=(36, 27, 21, 255), width=4)

    # Simplified player silhouette and cast bar context.
    draw.ellipse((716, 426, 784, 498), fill=(37, 29, 25, 255))
    draw.polygon(
        [(735, 488), (764, 488), (792, 640), (750, 690), (705, 640)],
        fill=(30, 24, 22, 255),
    )
    draw.line([(723, 520), (665, 616)], fill=(92, 72, 45, 255), width=9)
    draw.line([(776, 520), (834, 616)], fill=(92, 72, 45, 255), width=9)
    draw.rectangle((645, 698, 855, 715), fill=(25, 18, 14, 220))
    draw.rectangle((650, 702, 800, 711), fill=(116, 80, 38, 255))

    # Vanilla-shaped player/target frames, deliberately generic.
    draw.ellipse((34, 34, 100, 100), fill=(35, 26, 19, 255), outline=(126, 94, 45, 255), width=4)
    draw.rectangle((94, 46, 277, 68), fill=(28, 21, 16, 235), outline=(112, 84, 42, 255), width=3)
    draw.rectangle((98, 50, 244, 63), fill=(63, 117, 65, 255))
    draw.text((108, 73), "纳斯雷兹姆的文稿", font=small, fill=(225, 205, 155, 255))

    # Chunky classic actionbar and two opposing gryphon-like silhouettes.
    bar_y = height - 82
    draw.rectangle((430, bar_y, 1106, height - 18), fill=(41, 29, 20, 245), outline=(121, 86, 40, 255), width=4)
    for index in range(12):
        x = 446 + index * 53
        draw.rectangle((x, bar_y + 10, x + 45, bar_y + 55), fill=(70, 54, 37, 255), outline=(139, 101, 48, 255), width=2)
        draw.ellipse((x + 9, bar_y + 18, x + 35, bar_y + 44), fill=(71 + index * 4, 67, 48, 255))
        draw.text((x + 3, bar_y + 43), str(index + 1), font=small, fill=(236, 214, 165, 255))
    left_gryphon = [(420, bar_y + 8), (380, bar_y - 5), (351, bar_y + 17), (387, bar_y + 29), (353, bar_y + 51), (407, bar_y + 56), (432, bar_y + 35)]
    right_gryphon = [(1115, bar_y + 8), (1156, bar_y - 5), (1185, bar_y + 17), (1149, bar_y + 29), (1183, bar_y + 51), (1129, bar_y + 56), (1104, bar_y + 35)]
    draw.polygon(left_gryphon, fill=(106, 82, 44, 255), outline=(42, 31, 22, 255))
    draw.polygon(right_gryphon, fill=(106, 82, 44, 255), outline=(42, 31, 22, 255))

    draw.text(
        (24, height - 34),
        f"{version.replace('-', ' ')} · 本地几何预演 · ImageGen 0/0 · 非最终美术",
        font=body,
        fill=(221, 205, 166, 235),
    )


def draw_external_shell(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    width: int,
    height: int,
    outsets: dict[str, int],
    palette: dict[str, str],
    debug: bool = False,
) -> dict[str, tuple[int, int, int, int]]:
    left = int(outsets["left"])
    right = int(outsets["right"])
    top = int(outsets["top"])
    bottom = int(outsets["bottom"])
    paper = rgba(palette["paper"])
    paper_light = rgba(palette["paper_light"])
    paper_shadow = rgba(palette["paper_shadow"])
    page_edge = rgba(palette["page_edge"])
    ink = rgba(palette["ink"])

    shell = (x - left, y - top, x + width + right, y + height + bottom)
    live = (x, y, x + width, y + height)
    caps = {
        "left": (x - left, y, x, y + height),
        "right": (x + width, y, x + width + right, y + height),
        "top": (x - left, y - top, x + width + right, y),
        "bottom": (x - left, y + height, x + width + right, y + height + bottom),
    }

    if left == 0 and right == 0 and top == 0 and bottom == 0:
        # QT-GEO-V2: the user explicitly rejected every exterior book-frame,
        # page-stack, cap, and outline. The visible paper is exactly the live
        # provider rectangle; only the debug board draws its live-frame line.
        draw.rectangle(rect_xy(x, y, width, height), fill=paper)
        for offset, alpha in ((37, 24), (91, 18), (157, 14)):
            if offset < height:
                draw.line(
                    [(x + 6, y + offset), (x + width - 7, y + offset + 1)],
                    fill=rgba(palette["paper_light"], alpha),
                    width=1,
                )
        if debug:
            draw.rectangle(
                (live[0], live[1], live[2] - 1, live[3] - 1),
                outline=rgba(palette["debug_live"]),
                width=2,
            )
        return {"shell": shell, "live": live, **caps}

    # All rectangles below use inclusive Pillow coordinates while the returned
    # contract boxes stay right/bottom exclusive.
    draw.rectangle(
        (shell[0] + 5, shell[1] + 7, shell[2] + 5, shell[3] + 7),
        fill=(8, 6, 5, 105),
    )

    # Side page stacks are entirely outside the provider rectangle.
    draw.rectangle(rect_xy(x - left, y, left, height), fill=page_edge)
    draw.rectangle(rect_xy(x - left + 3, y, 4, height), fill=paper_shadow)
    draw.line([(x - 3, y), (x - 3, y + height - 1)], fill=(199, 164, 103, 190), width=1)
    draw.rectangle(rect_xy(x + width, y, right, height), fill=page_edge)
    draw.rectangle(rect_xy(x + width, y, 4, height), fill=paper_shadow)
    draw.line([(x + width + 4, y), (x + width + 4, y + height - 1)], fill=(185, 147, 88, 150), width=1)

    # Top/bottom caps are separate outside bands, never a border over live text.
    top_points = [
        (x - left, y - 2),
        (x - left + 5, y - top + 3),
        (x + width // 4, y - top),
        (x + width // 2, y - top + 2),
        (x + width * 3 // 4, y - top - 1),
        (x + width + right - 3, y - top + 3),
        (x + width + right - 1, y - 1),
    ]
    draw.polygon(top_points, fill=paper_shadow)
    draw.line(top_points[:-1], fill=paper_light, width=2, joint="curve")
    draw.line([(x - left, y - 1), (x + width + right - 1, y - 1)], fill=page_edge, width=2)

    bottom_points = [
        (x - left, y + height),
        (x + width + right - 1, y + height),
        (x + width + right - 4, y + height + bottom - 4),
        (x + width * 4 // 5, y + height + bottom - 1),
        (x + width * 3 // 5, y + height + bottom - 4),
        (x + width * 2 // 5, y + height + bottom),
        (x + width // 5, y + height + bottom - 3),
        (x - left + 3, y + height + bottom - 5),
    ]
    draw.polygon(bottom_points, fill=page_edge)
    draw.line([(x - left, y + height), (x + width + right - 1, y + height)], fill=paper_shadow, width=2)
    draw.line(bottom_points[2:], fill=(184, 144, 83, 190), width=1)

    # The entire provider rectangle is a quiet, uninterrupted paper field.
    draw.rectangle(rect_xy(x, y, width, height), fill=paper)
    draw.line([(x, y), (x + width - 1, y)], fill=paper_light, width=1)
    for offset, alpha in ((37, 32), (91, 24), (157, 20)):
        if offset < height:
            draw.line(
                [(x + 6, y + offset), (x + width - 7, y + offset + 1)],
                fill=rgba(palette["paper_light"], alpha),
                width=1,
            )

    if debug:
        live_color = rgba(palette["debug_live"])
        shell_color = rgba(palette["debug_shell"])
        draw.rectangle(
            (shell[0], shell[1], shell[2] - 1, shell[3] - 1),
            outline=shell_color,
            width=1,
        )
        draw.rectangle(
            (live[0], live[1], live[2] - 1, live[3] - 1),
            outline=live_color,
            width=2,
        )
        draw.line([(x, y), (x, y + height - 1)], fill=ink, width=1)

    return {"shell": shell, "live": live, **caps}


def draw_toolbar(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    width: int,
    palette: dict[str, str],
) -> list[tuple[int, int, int, int]]:
    boxes: list[tuple[int, int, int, int]] = []
    brass = rgba(palette["aged_brass"])
    wine = rgba(palette["old_wine"])
    ink = rgba(palette["ink"])
    paper_light = rgba(palette["paper_light"])

    for index in range(3):
        bx = x + 1 + index * 17
        box = (bx, y + 1, bx + 14, y + 15)
        boxes.append(box)
        draw.ellipse(
            (box[0], box[1], box[2] - 1, box[3] - 1),
            fill=brass if index else wine,
            outline=ink,
            width=1,
        )
        draw.line(
            [(bx + 4, y + 8), (bx + 7, y + 4), (bx + 10, y + 9)],
            fill=paper_light,
            width=1,
        )
    for index in range(4):
        bx = x + width - 15 - index * 17
        box = (bx, y + 1, bx + 14, y + 15)
        boxes.append(box)
        draw.rectangle(
            (box[0], box[1], box[2] - 1, box[3] - 1),
            fill=brass,
            outline=ink,
            width=1,
        )
        if index == 0:
            draw.line([(bx + 4, y + 5), (bx + 10, y + 11)], fill=paper_light, width=1)
            draw.line([(bx + 10, y + 5), (bx + 4, y + 11)], fill=paper_light, width=1)
        elif index == 1:
            draw.ellipse((bx + 4, y + 4, bx + 9, y + 9), outline=paper_light, width=1)
        elif index == 2:
            draw.line([(bx + 4, y + 11), (bx + 10, y + 5)], fill=paper_light, width=2)
        else:
            draw.ellipse((bx + 3, y + 3, bx + 9, y + 9), outline=paper_light, width=1)
            draw.line([(bx + 9, y + 9), (bx + 12, y + 12)], fill=paper_light, width=1)
    return boxes


def ellipsize(text: str, width: int) -> str:
    # This deterministic character cap is only a mockup stand-in for the
    # provider FontString clipping. It does not change runtime text.
    character_budget = max(5, int((width - 27) / 11))
    if len(text) <= character_budget:
        return text
    return text[: max(1, character_budget - 1)] + "…"


def scenario_titles(
    scenario: dict[str, Any], content: dict[str, list[str]]
) -> list[str]:
    mode = scenario["mode"]
    count = int(scenario["entry_count"])
    if mode == "DATABASE_TRACKING":
        return content["database_titles"][:count]
    if mode == "GIVER_TRACKING":
        return content["giver_titles"][:count]
    return content["quest_titles"][:count]


def draw_entries(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    width: int,
    scenario: dict[str, Any],
    provider: dict[str, Any],
    content: dict[str, list[str]],
    palette: dict[str, str],
    body_font: ImageFont.FreeTypeFont,
    objective_font: ImageFont.FreeTypeFont,
) -> list[dict[str, Any]]:
    panel_height = int(provider["panel_height"])
    entry_height = int(provider["entry_height"])
    objective_step = int(provider["objective_step"])
    titles = scenario_titles(scenario, content)
    objective_pool = content["objectives"]
    objective_cursor = 0
    cursor = panel_height
    regions: list[dict[str, Any]] = []

    for entry_index, objective_count in enumerate(
        scenario["objective_distribution"]
    ):
        title = titles[entry_index]
        icon_box = (2, cursor + 4, 14, cursor + 16)
        title_box = (16, cursor + 4, width - 10, cursor + 16)
        regions.extend(
            [
                {"id": f"entry.{entry_index + 1}.icon", "box": icon_box},
                {"id": f"entry.{entry_index + 1}.title", "box": title_box},
            ]
        )
        draw.ellipse(
            (
                x + icon_box[0],
                y + icon_box[1],
                x + icon_box[2] - 1,
                y + icon_box[3] - 1,
            ),
            fill=rgba(
                palette[
                    "old_wine" if entry_index % 3 == 0 else "aged_brass"
                ]
            ),
            outline=rgba(palette["ink"]),
            width=1,
        )
        title_color = (
            (116, 52, 43, 255)
            if entry_index % 4 == 0
            else (54, 42, 27, 255)
        )
        draw.text(
            (x + 16, y + cursor + 2),
            ellipsize(title, width),
            font=body_font,
            fill=title_color,
        )
        for objective_index in range(int(objective_count)):
            objective_top = cursor + 6 + objective_step * (objective_index + 1)
            objective_box = (
                20,
                objective_top,
                width - 10,
                objective_top + objective_step,
            )
            regions.append(
                {
                    "id": (
                        f"entry.{entry_index + 1}."
                        f"objective.{objective_index + 1}"
                    ),
                    "box": objective_box,
                }
            )
            text = objective_pool[objective_cursor % len(objective_pool)]
            objective_cursor += 1
            draw.text(
                (x + 20, y + objective_top - 2),
                ellipsize(text, width - 4),
                font=objective_font,
                fill=(68, 56, 39, 255),
            )
        cursor += entry_height + int(objective_count) * objective_step

    return regions


def expected_height(scenario: dict[str, Any], provider: dict[str, Any]) -> int:
    return (
        int(provider["panel_height"])
        + int(scenario["entry_count"]) * int(provider["entry_height"])
        + sum(int(value) for value in scenario["objective_distribution"])
        * int(provider["objective_step"])
    )


def contains(
    outer: tuple[int, int, int, int], inner: tuple[int, int, int, int]
) -> bool:
    return (
        outer[0] <= inner[0]
        and outer[1] <= inner[1]
        and inner[2] <= outer[2]
        and inner[3] <= outer[3]
    )


def intersects(
    first: tuple[int, int, int, int], second: tuple[int, int, int, int]
) -> bool:
    return not (
        first[2] <= second[0]
        or second[2] <= first[0]
        or first[3] <= second[1]
        or second[3] <= first[1]
    )


def audit_scenario(
    scenario: dict[str, Any],
    provider: dict[str, Any],
    toolbar: Iterable[tuple[int, int, int, int]],
    regions: Iterable[dict[str, Any]],
    outsets: dict[str, int],
) -> dict[str, Any]:
    width, height = (int(value) for value in scenario["frame"])
    live = (0, 0, width, height)
    cap_boxes = {
        "left": (-int(outsets["left"]), 0, 0, height),
        "right": (width, 0, width + int(outsets["right"]), height),
        "top": (
            -int(outsets["left"]),
            -int(outsets["top"]),
            width + int(outsets["right"]),
            0,
        ),
        "bottom": (
            -int(outsets["left"]),
            height,
            width + int(outsets["right"]),
            height + int(outsets["bottom"]),
        ),
    }
    checks: list[dict[str, Any]] = []
    checks.append(
        {
            "id": "visual-shell-equals-live"
            if not any(int(value) for value in outsets.values())
            else "visual-shell-outsets-match-contract",
            "pass": True,
            "outsets": {
                key: int(value) for key, value in outsets.items()
            },
        }
    )
    formula_height = expected_height(scenario, provider)
    checks.append(
        {
            "id": "provider-height-formula",
            "pass": formula_height == height,
            "expected": formula_height,
            "actual": height,
        }
    )
    for index, box in enumerate(toolbar, start=1):
        checks.append(
            {
                "id": f"toolbar.{index}.inside-live",
                "pass": contains(live, box),
                "box": list(box),
            }
        )
    for region in regions:
        box = tuple(int(value) for value in region["box"])
        checks.append(
            {
                "id": f"{region['id']}.inside-live",
                "pass": contains(live, box),
                "box": list(box),
            }
        )
    for name, cap in cap_boxes.items():
        checks.append(
            {
                "id": f"cap.{name}.outside-live",
                "pass": not intersects(live, cap),
                "box": list(cap),
            }
        )
    return {
        "id": scenario["id"],
        "mode": scenario["mode"],
        "frame": [width, height],
        "visual_shell": [
            width + int(outsets["left"]) + int(outsets["right"]),
            height + int(outsets["top"]) + int(outsets["bottom"]),
        ],
        "entry_count": int(scenario["entry_count"]),
        "objective_count": sum(
            int(value) for value in scenario["objective_distribution"]
        ),
        "checks": checks,
        "pass": all(check["pass"] for check in checks),
    }


def render_tracker(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    scenario: dict[str, Any],
    spec: dict[str, Any],
    fonts: dict[str, ImageFont.FreeTypeFont],
    debug: bool = False,
) -> dict[str, Any]:
    width, height = (int(value) for value in scenario["frame"])
    draw_external_shell(
        draw,
        x,
        y,
        width,
        height,
        spec["proposal"]["visual_outsets"],
        spec["palette"],
        debug=debug,
    )
    toolbar_boxes_abs = draw_toolbar(draw, x, y, width, spec["palette"])
    regions_abs = draw_entries(
        draw,
        x,
        y,
        width,
        scenario,
        spec["provider"],
        spec["localized_content"],
        spec["palette"],
        fonts["body11"],
        fonts["objective10"],
    )
    toolbar_boxes = [
        (box[0] - x, box[1] - y, box[2] - x, box[3] - y)
        for box in toolbar_boxes_abs
    ]
    return audit_scenario(
        scenario,
        spec["provider"],
        toolbar_boxes,
        regions_abs,
        spec["proposal"]["visual_outsets"],
    )


def render_ingame(
    spec: dict[str, Any],
    repo_root: Path,
    output: Path,
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> dict[str, Any]:
    width, height = (int(value) for value in spec["ingame_scene"]["canvas"])
    image = Image.new("RGBA", (width, height))
    draw = ImageDraw.Draw(image, "RGBA")
    draw_world(
        draw,
        width,
        height,
        fonts["body13"],
        fonts["body10"],
        spec["version"],
    )
    scenario = next(
        item
        for item in spec["scenarios"]
        if item["id"] == spec["ingame_scene"]["scenario"]
    )
    origin_x, origin_y = (
        int(value) for value in spec["ingame_scene"]["provider_origin"]
    )
    audit = render_tracker(
        draw, origin_x, origin_y, scenario, spec, fonts, debug=False
    )
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, format="PNG", optimize=False, compress_level=9)
    return audit


def board_positions() -> dict[str, tuple[int, int]]:
    return {
        "empty-provider": (70, 180),
        "quest-short-default-font": (390, 180),
        "database-six-entries-default-font": (680, 180),
        "giver-six-entries-default-font": (1045, 180),
        "quest-typical-default-font": (70, 460),
        "quest-dense-default-font": (430, 460),
        "quest-maximum-entry-count-default-font": (890, 460),
    }


def render_board(
    spec: dict[str, Any],
    output: Path,
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> list[dict[str, Any]]:
    width, height = (int(value) for value in spec["scenario_board"]["canvas"])
    image = Image.new("RGBA", (width, height), (28, 26, 23, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    direct_live = not any(
        int(value)
        for value in spec["proposal"]["visual_outsets"].values()
    )
    heading = (
        "QT-GEO V2 · 直接使用 live tracker 纸面 · 七种真实 provider 尺寸"
        if direct_live
        else "QT-GEO V1 · 外置装饰端帽 · 七种真实 provider 尺寸"
    )
    subheading = (
        "酒红线只标记原 pfQuest live Frame，非最终边框；无外置书框、端帽、页叠层或阴影。所有图均为 100% UI 像素，ImageGen 0/0。"
        if direct_live
        else "酒红线 = 原 pfQuest live Frame；浅金线 = 外层视觉壳。所有图均为 100% UI 像素，ImageGen 0/0。"
    )
    draw.text(
        (54, 34),
        heading,
        font=fonts["title24"],
        fill=(220, 195, 139, 255),
    )
    draw.text(
        (54, 76),
        subheading,
        font=fonts["body14"],
        fill=(194, 180, 148, 255),
    )
    audits: list[dict[str, Any]] = []
    positions = board_positions()
    for scenario in spec["scenarios"]:
        x, y = positions[scenario["id"]]
        frame_width, frame_height = (
            int(value) for value in scenario["frame"]
        )
        outsets = spec["proposal"]["visual_outsets"]
        shell_width = frame_width + int(outsets["left"]) + int(outsets["right"])
        shell_height = frame_height + int(outsets["top"]) + int(outsets["bottom"])
        draw.text(
            (x - int(outsets["left"]), y - int(outsets["top"]) - 50),
            f"{scenario['label']}  {frame_width}×{frame_height}",
            font=fonts["title15"],
            fill=(224, 204, 160, 255),
        )
        draw.text(
            (x - int(outsets["left"]), y - int(outsets["top"]) - 27),
            (
                f"显示面 {shell_width}×{shell_height} · {scenario['mode']}"
                if direct_live
                else f"视觉壳 {shell_width}×{shell_height} · {scenario['mode']}"
            ),
            font=fonts["body10"],
            fill=(160, 147, 119, 255),
        )
        audits.append(
            render_tracker(draw, x, y, scenario, spec, fonts, debug=True)
        )
    legend_y = 1042
    draw.line(
        [(58, legend_y), (110, legend_y)],
        fill=rgba(spec["palette"]["debug_live"]),
        width=3,
    )
    draw.text(
        (122, legend_y - 10),
        (
            "provider live Frame：也是唯一显示面；文字、节点图标、七个 Button 与全部 hitbox 仍在这里"
            if direct_live
            else "provider live Frame：文字、节点图标、七个 Button 与全部 hitbox 仍在这里"
        ),
        font=fonts["body13"],
        fill=(211, 193, 158, 255),
    )
    if direct_live:
        draw.text(
            (58, legend_y + 29),
            "无外置视觉壳：四边 outsets 全为 0px；没有书框、端帽、页叠层或外投影。",
            font=fonts["body13"],
            fill=(211, 193, 158, 255),
        )
    else:
        draw.line(
            [(58, legend_y + 40), (110, legend_y + 40)],
            fill=rgba(spec["palette"]["debug_shell"]),
            width=2,
        )
        draw.text(
            (122, legend_y + 29),
            "adapter 外层视觉壳：左 14／右 14／上 12／下 16px；不接收鼠标，位于 provider 后方",
            font=fonts["body13"],
            fill=(211, 193, 158, 255),
        )
    draw.text(
        (58, legend_y + 78),
        "高度公式：16 + 任务数 × 20 + 目标数 × 12。空状态仍保持 16px live Frame；端帽不再被压缩。",
        font=fonts["body13"],
        fill=(211, 193, 158, 255),
    )
    draw.text(
        (58, legend_y + 108),
        (
            "无外置像素，因此不存在端帽贴屏裁切；runtime 仍需复核纸面覆盖、动态尺寸与原 provider 交互。"
            if direct_live
            else "未决定：外置端帽在贴屏保存位置的裁切策略；必须在 runtime 接入前单独验证，不能改写 provider 数据或点击区。"
        ),
        font=fonts["body13"],
        fill=(194, 147, 120, 255),
    )
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, format="PNG", optimize=False, compress_level=9)
    return audits


def main() -> None:
    args = parse_args()
    repo_root = args.repo_root.resolve()
    spec_path = args.spec.resolve()
    requested_spec = json.loads(spec_path.read_text(encoding="utf-8"))
    if requested_spec["schema"] == (
        "aeui-quest-tracker-direct-paper-simulation-v1"
    ):
        base_path = repo_root / requested_spec["base_specification"]
        spec = json.loads(base_path.read_text(encoding="utf-8"))
        for field in (
            "schema",
            "version",
            "component",
            "purpose",
            "imagegen",
            "proposal",
            "ingame_scene",
            "scenario_board",
            "outputs",
        ):
            spec[field] = requested_spec[field]
    elif requested_spec["schema"] == (
        "aeui-quest-tracker-external-caps-simulation-v1"
    ):
        spec = requested_spec
    else:
        raise ValueError(f"unsupported schema: {requested_spec['schema']}")

    fonts = {
        "body10": font(repo_root, spec["fonts"], "body", 10),
        "body11": font(repo_root, spec["fonts"], "body", 11),
        "body13": font(repo_root, spec["fonts"], "body", 13),
        "body14": font(repo_root, spec["fonts"], "body", 14),
        "objective10": font(repo_root, spec["fonts"], "narrative", 10),
        "title15": font(repo_root, spec["fonts"], "title", 15),
        "title24": font(repo_root, spec["fonts"], "title", 24),
    }
    output_dir = repo_root / spec["outputs"]["directory"]
    ingame_path = output_dir / spec["outputs"]["ingame"]
    board_path = output_dir / spec["outputs"]["scenarios"]
    report_path = output_dir / spec["outputs"]["report"]

    ingame_audit = render_ingame(
        spec, repo_root, ingame_path, fonts
    )
    scenario_audits = render_board(spec, board_path, fonts)
    report = {
        "schema": (
            "aeui-quest-tracker-direct-paper-simulation-report-v1"
            if spec["schema"] == "aeui-quest-tracker-direct-paper-simulation-v1"
            else "aeui-quest-tracker-external-caps-simulation-report-v1"
        ),
        "version": spec["version"],
        "component": spec["component"],
        "imagegen": "0/0",
        "specification": str(
            spec_path.relative_to(repo_root)
        ),
        "proposal": spec["proposal"],
        "ingame_scenario": ingame_audit,
        "scenarios": scenario_audits,
        "pass": ingame_audit["pass"]
        and all(item["pass"] for item in scenario_audits),
        "outputs": {
            "ingame": str(ingame_path.relative_to(repo_root)),
            "scenarios": str(board_path.relative_to(repo_root)),
        },
    }
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(ingame_path)
    print(board_path)
    print(report_path)


if __name__ == "__main__":
    main()
