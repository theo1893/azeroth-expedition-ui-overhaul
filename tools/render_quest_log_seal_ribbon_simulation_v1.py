#!/usr/bin/env python3
"""Render the deterministic four-state Quest Log seal-ribbon preview."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, ImageFont


INK = (50, 29, 17, 255)
INK_SOFT = (72, 45, 26, 255)
INK_MUTED = (103, 76, 46, 255)
PAPER = (188, 144, 81, 255)
PAPER_LIGHT = (211, 174, 107, 255)
PAPER_DARK = (126, 83, 43, 255)
RIBBON = (145, 101, 57, 255)
RIBBON_ALT = (157, 111, 62, 255)
RIBBON_SHADOW = (87, 52, 29, 255)
WINE = (91, 27, 24, 255)
BRASS = (142, 99, 39, 255)
BRASS_LIGHT = (190, 143, 64, 255)
BOARD = (35, 43, 41, 255)
BOARD_LOWER = (58, 42, 30, 255)


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


def intersection(
    left: list[int], right: list[int]
) -> list[int] | None:
    lx, ly, lw, lh = left
    rx, ry, rw, rh = right
    x0 = max(lx, rx)
    y0 = max(ly, ry)
    x1 = min(lx + lw, rx + rw)
    y1 = min(ly + lh, ry + rh)
    if x1 <= x0 or y1 <= y0:
        return None
    return [x0, y0, x1 - x0, y1 - y0]


def area(box: list[int] | None) -> int:
    return 0 if box is None else box[2] * box[3]


def contains(outer: list[int], inner: list[int]) -> bool:
    return (
        outer[0] <= inner[0]
        and outer[1] <= inner[1]
        and outer[0] + outer[2] >= inner[0] + inner[2]
        and outer[1] + outer[3] >= inner[1] + inner[3]
    )


def moved_for_scroll(box: list[int], offset: int) -> list[int]:
    return [box[0], box[1] - offset, box[2], box[3]]


def load_inputs(
    root: Path, spec: dict[str, Any]
) -> tuple[Image.Image, Image.Image]:
    frame_width, frame_height = spec["frame"]
    shell = Image.open(
        resolve(root, spec["inputs"]["quest_log_shell"])
    ).convert("RGBA")
    shell = shell.resize(
        (frame_width, frame_height), Image.Resampling.LANCZOS
    )
    atlas = Image.open(resolve(root, spec["inputs"]["seal_atlas"])).convert(
        "RGBA"
    )
    cell_width = atlas.width // 4
    seal = atlas.crop((0, 0, cell_width, atlas.height))
    return shell, seal


def draw_reward_slot(
    draw: ImageDraw.ImageDraw,
    box: list[int],
    label: str,
    index: int,
    body: ImageFont.FreeTypeFont,
) -> None:
    x, y, width, height = box
    draw.rounded_rectangle(
        (x, y, x + width - 1, y + height - 1),
        radius=2,
        fill=(62, 37, 21, 235),
        outline=(122, 78, 31, 255),
        width=1,
    )
    draw.rectangle(
        (x + 4, y + 4, x + 28, y + height - 5),
        fill=(62 + index * 13, 54, 36 + index * 11, 255),
        outline=BRASS_LIGHT,
        width=1,
    )
    draw.text(
        (x + 33, y + height / 2),
        label,
        font=body,
        fill=(218, 184, 117, 255),
        anchor="lm",
    )


def draw_action_motif(
    draw: ImageDraw.ImageDraw,
    index: int,
    center: tuple[int, int],
) -> None:
    cx, cy = center
    color = WINE if index == 6 else (62, 37, 25, 230)
    light = (113, 74, 42, 220)
    if index == 0:
        draw.ellipse((cx - 8, cy - 4, cx, cy + 4), outline=color, width=2)
        draw.ellipse((cx, cy - 4, cx + 8, cy + 4), outline=color, width=2)
        draw.line((cx - 6, cy + 6, cx + 6, cy - 6), fill=light, width=1)
    elif index == 1:
        draw.line((cx - 8, cy - 5, cx + 5, cy - 5), fill=color, width=2)
        draw.line((cx - 8, cy, cx + 7, cy), fill=color, width=2)
        draw.polygon(
            [(cx + 3, cy + 4), (cx + 8, cy + 4), (cx + 8, cy + 9)],
            fill=color,
        )
    elif index in (2, 3):
        draw.ellipse((cx - 6, cy - 6, cx + 6, cy + 6), outline=color, width=1)
        draw.polygon(
            [(cx, cy - 8), (cx + 3, cy), (cx, cy + 8), (cx - 3, cy)],
            fill=color,
        )
        draw.line((cx - 8, cy, cx + 8, cy), fill=color, width=1)
        if index == 3:
            draw.line((cx - 8, cy + 8, cx + 8, cy - 8), fill=WINE, width=2)
    elif index == 4:
        for step in range(3):
            y = cy - 6 + step * 5
            draw.arc((cx - 9, y - 2, cx + 9, y + 5), 190, 342, fill=color, width=2)
    elif index == 5:
        draw.arc((cx - 8, cy - 8, cx + 8, cy + 8), 35, 315, fill=color, width=2)
        draw.polygon(
            [(cx + 7, cy - 7), (cx + 9, cy - 1), (cx + 3, cy - 3)],
            fill=color,
        )
        draw.ellipse((cx - 2, cy - 2, cx + 2, cy + 2), fill=light)
    else:
        draw.line((cx - 8, cy - 5, cx - 1, cy + 5), fill=color, width=2)
        draw.line((cx + 2, cy - 5, cx + 8, cy + 4), fill=color, width=2)
        draw.line((cx - 2, cy - 1, cx + 2, cy + 1), fill=RIBBON_ALT, width=2)


def draw_ribbon_root(
    draw: ImageDraw.ImageDraw, box: list[int]
) -> None:
    x, y, width, height = box
    draw.polygon(
        [
            (x + 2, y),
            (x + width - 2, y + 1),
            (x + width - 1, y + height),
            (x + 1, y + height - 1),
        ],
        fill=RIBBON_SHADOW,
    )
    draw.line(
        (x + 3, y + height - 2, x + width - 4, y + height - 1),
        fill=(191, 139, 76, 210),
        width=1,
    )


def draw_ribbon_segment(
    draw: ImageDraw.ImageDraw,
    box: list[int],
    index: int,
) -> None:
    x, y, width, height = box
    left_jitter = (0, 1, 0, 1, 0, 1, 0)[index]
    right_jitter = (1, 0, 1, 0, 0, 1, 0)[index]
    fill = RIBBON_ALT if index in (1, 4) else RIBBON
    if index == 6:
        fill = (137, 88, 55, 255)
    polygon = [
        (x + left_jitter, y),
        (x + width - 1 - right_jitter, y + (index % 2)),
        (x + width - 1, y + height - 2),
        (x + width - 3, y + height),
        (x + 1, y + height - (index % 2)),
    ]
    draw.polygon(polygon, fill=fill)
    draw.line(
        (x + 2, y + 1, x + width - 4, y + (index % 2) + 1),
        fill=(204, 153, 89, 130),
        width=1,
    )
    draw.line(
        (x + 1, y + height - 1, x + width - 3, y + height - 2),
        fill=(76, 43, 27, 210),
        width=1,
    )
    if index in (2, 5):
        draw.line(
            (x + 3, y + 4, x + 5, y + height - 4),
            fill=(106, 67, 37, 145),
            width=1,
        )
    draw_action_motif(draw, index, (x + width // 2, y + height // 2))


def draw_ribbon_tail(
    draw: ImageDraw.ImageDraw, box: list[int]
) -> None:
    x, y, width, height = box
    draw.polygon(
        [
            (x + 1, y),
            (x + width - 2, y),
            (x + width - 3, y + height - 2),
            (x + width - 9, y + height),
            (x + width // 2, y + height - 3),
            (x + 8, y + height),
            (x + 1, y + height - 2),
        ],
        fill=(132, 83, 50, 255),
    )
    draw.line((x + 2, y, x + width - 3, y), fill=RIBBON_SHADOW, width=1)


def draw_detail_content(
    spec: dict[str, Any],
    fonts: dict[str, ImageFont.FreeTypeFont],
    seal: Image.Image,
    menu_open: bool,
) -> Image.Image:
    layout = spec["layout"]
    _, _, content_width, content_height = layout["detail_scroll_child"]
    content = Image.new("RGBA", (content_width, content_height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(content, "RGBA")

    x = layout["detail_body_origin"][0]
    draw.text((x, 8), "熔火之心", font=fonts["detail_title"], fill=INK)
    draw.line((x, 34, x + 184, 34), fill=(101, 65, 32, 150), width=1)
    body_lines = [
        (46, "黑石山深处传来古老而炽热的回声。", False),
        (64, "与同伴进入熔火之心，查明元素领主", False),
        (82, "再度苏醒的征兆，并带回远征记录。", False),
        (106, "任务目标", True),
        (128, "· 击败熔火巨人：6 / 8", False),
        (146, "· 取得远古符文碎片：2 / 4", False),
        (164, "· 向洛索斯·天痕复命", False),
        (194, "奖励", True),
        (216, "你将获得以下奖励：", False),
    ]
    for y, value, heading in body_lines:
        draw.text(
            (x, y),
            value,
            font=fonts["heading"] if heading else fonts["body"],
            fill=INK if heading else INK_SOFT,
        )

    reward_labels = ("远古徽记", "熔火碎片", "公会印记", "金币袋")
    for index, box in enumerate(layout["reward_slots_content"]):
        draw_reward_slot(draw, box, reward_labels[index], index, fonts["reward"])
    draw.text((x, 342), "经验：9950", font=fonts["body"], fill=INK_SOFT)
    draw.text((x, 362), "远征公会将记录你的功绩。", font=fonts["body"], fill=INK_SOFT)
    draw.line((x, 390, x + 184, 390), fill=(101, 65, 32, 120), width=1)

    draw_ribbon_root(draw, layout["ribbon_root_content"])
    if menu_open:
        for index, box in enumerate(layout["ribbon_action_segments_content"]):
            draw_ribbon_segment(draw, box, index)
        draw_ribbon_tail(draw, layout["ribbon_tail_content"])

    sx, sy, sw, sh = layout["seal_visual_content"]
    resized = seal.resize((sw, sh), Image.Resampling.LANCZOS)
    content.alpha_composite(resized, (sx, sy))
    return content


def draw_left_page(
    draw: ImageDraw.ImageDraw,
    origin: tuple[int, int],
    spec: dict[str, Any],
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> None:
    ox, oy = origin
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
        ("世界事件", True),
        ("[59] 最后的远征", False),
        ("[40] 旧友的来信", False),
    ]
    list_x = ox + spec["layout"]["list"][0]
    list_y = oy + spec["layout"]["list"][1]
    for index, (label, header) in enumerate(rows):
        y = list_y + index * 18
        if header:
            draw.polygon(
                [(list_x + 2, y + 6), (list_x + 10, y + 9), (list_x + 2, y + 12)],
                fill=INK,
            )
            color = INK
        else:
            draw.ellipse(
                (list_x + 2, y + 5, list_x + 10, y + 13),
                outline=INK_SOFT,
                width=1,
            )
            color = INK_SOFT
        draw.text((list_x + 18, y + 2), label, font=fonts["row"], fill=color)


def draw_frame_chrome(
    draw: ImageDraw.ImageDraw,
    origin: tuple[int, int],
    spec: dict[str, Any],
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> None:
    ox, oy = origin
    frame_width, _ = spec["frame"]
    draw.text(
        (ox + frame_width / 2, oy + 27),
        "任务日志",
        font=fonts["title"],
        fill=INK,
        anchor="mm",
    )
    draw.ellipse((ox + 134, oy + 45, ox + 143, oy + 54), outline=INK, width=1)
    draw.text((ox + 146, oy + 45), "显示任务等级", font=fonts["small"], fill=INK)
    draw.text((ox + 304, oy + 45), "任务：18 / 20", font=fonts["small"], fill=INK, anchor="ra")
    draw.text((ox + 546, oy + 47), "简体中文", font=fonts["small"], fill=INK_MUTED)
    draw.text((ox + 599, oy + 47), "在线", font=fonts["small"], fill=INK_MUTED)
    cx, cy, cw, ch = spec["layout"]["close"]
    draw.line(
        (ox + cx + 5, oy + cy + 5, ox + cx + cw - 5, oy + cy + ch - 5),
        fill=BRASS_LIGHT,
        width=2,
    )
    draw.line(
        (ox + cx + cw - 5, oy + cy + 5, ox + cx + 5, oy + cy + ch - 5),
        fill=BRASS_LIGHT,
        width=2,
    )


def draw_quest_log_state(
    canvas: Image.Image,
    shell: Image.Image,
    seal: Image.Image,
    origin: tuple[int, int],
    spec: dict[str, Any],
    fonts: dict[str, ImageFont.FreeTypeFont],
    state: dict[str, Any],
) -> None:
    canvas.alpha_composite(shell, origin)
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw_frame_chrome(draw, origin, spec, fonts)
    draw_left_page(draw, origin, spec, fonts)

    content = draw_detail_content(spec, fonts, seal, state["menu_open"])
    vx, vy, vw, vh = spec["layout"]["detail_viewport"]
    offset = state["scroll_offset"]
    visible = content.crop((0, offset, vw, offset + vh))
    canvas.alpha_composite(visible, (origin[0] + vx, origin[1] + vy))


def state_metrics(spec: dict[str, Any], state: dict[str, Any]) -> dict[str, Any]:
    layout = spec["layout"]
    _, _, viewport_width, viewport_height = layout["detail_viewport"]
    viewport = [0, 0, viewport_width, viewport_height]
    offset = state["scroll_offset"]
    seal = moved_for_scroll(layout["seal_hitbox_content"], offset)
    root = moved_for_scroll(layout["ribbon_root_content"], offset)
    tail = moved_for_scroll(layout["ribbon_tail_content"], offset)
    segments = [
        moved_for_scroll(box, offset)
        for box in layout["ribbon_action_segments_content"]
    ]
    visible_segments = [intersection(viewport, box) for box in segments]
    enabled = [
        bool(state["menu_open"] and contains(viewport, box))
        for box in segments
    ]
    return {
        "id": state["id"],
        "scroll_offset": offset,
        "menu_open": state["menu_open"],
        "seal_visible_area": area(intersection(viewport, seal)),
        "root_visible_area": area(intersection(viewport, root)),
        "tail_visible_area": area(intersection(viewport, tail)) if state["menu_open"] else 0,
        "action_visible_areas": [area(box) for box in visible_segments] if state["menu_open"] else [0] * 7,
        "action_hitbox_enabled": enabled if state["menu_open"] else [False] * 7,
        "enabled_action_count": sum(enabled) if state["menu_open"] else 0,
    }


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    spec = json.loads(args.spec.read_text(encoding="utf-8"))
    title_path = resolve(root, spec["inputs"]["title_font"])
    body_path = resolve(root, spec["inputs"]["body_font"])
    fonts = {
        "title": load_font(title_path, 16),
        "detail_title": load_font(title_path, 15),
        "heading": load_font(title_path, 11),
        "body": load_font(body_path, 10),
        "row": load_font(body_path, 10),
        "small": load_font(body_path, 9),
        "reward": load_font(body_path, 8),
        "board_title": load_font(title_path, 19),
        "board_body": load_font(body_path, 11),
        "board_small": load_font(body_path, 10),
    }
    shell, seal = load_inputs(root, spec)
    canvas = Image.new("RGBA", tuple(spec["canvas"]), BOARD)
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rectangle((0, 620, canvas.width, canvas.height), fill=BOARD_LOWER)
    for x in range(-80, canvas.width + 100, 150):
        draw.polygon(
            [(x, 620), (x + 125, 620), (x + 190, canvas.height), (x + 15, canvas.height)],
            fill=(69, 49, 33, 165),
            outline=(42, 29, 21, 190),
        )

    presentation = spec["presentation"]
    draw.text((36, 22), presentation["title"], font=fonts["board_title"], fill=(237, 201, 128, 255))
    draw.text((36, 52), presentation["subtitle"], font=fonts["board_body"], fill=(201, 171, 111, 255))

    origins = [tuple(value) for value in presentation["origins"]]
    for origin, state in zip(origins, spec["states"]):
        draw.text(
            (origin[0], origin[1] - 27),
            state["label"],
            font=fonts["board_body"],
            fill=(237, 201, 128, 255),
        )
        draw_quest_log_state(canvas, shell, seal, origin, spec, fonts, state)

    draw.text(
        (36, 1142),
        "绶带七段（从上到下）：共享任务 · 收起详情 · 显示位置 · 隐藏位置 · 清理标记 · 重建标记 · 放弃任务",
        font=fonts["board_body"],
        fill=(229, 194, 124, 255),
    )
    draw.text(
        (36, 1170),
        "合同：右页 viewport 246×324；正文宽 214px／缩进 204px 均不改变；绶带宽 32px、只在展开期覆盖右缘 14–24px，尾端在 108×41px 奖励槽前 32px 停止；无书外框、无弹窗底板。",
        font=fonts["board_small"],
        fill=(205, 171, 109, 255),
    )
    draw.text(
        (36, 1194),
        "模拟只确认布局、层序、综合色与裁切；手绘纤维、Alpha、四态和客户端命中实现仍非权威。ImageGen 0/0。",
        font=fonts["board_small"],
        fill=(190, 157, 101, 255),
    )

    board_path = resolve(root, spec["outputs"]["board"])
    board_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(board_path)

    layout = spec["layout"]
    segments = layout["ribbon_action_segments_content"]
    first_reward_y = min(box[1] for box in layout["reward_slots_content"])
    tail_end = layout["ribbon_tail_content"][1] + layout["ribbon_tail_content"][3]
    body_right = layout["detail_body_origin"][0] + layout["detail_body_width"]
    legacy_right = layout["detail_body_origin"][0] + layout["legacy_unconstrained_width"]
    ribbon_left = segments[0][0]
    ribbon_right = ribbon_left + segments[0][2]
    metrics = [state_metrics(spec, state) for state in spec["states"]]
    checks = {
        "frame_is_676x464": spec["frame"] == [676, 464],
        "detail_viewport_is_real_246x324": layout["detail_viewport"] == [366, 64, 246, 324],
        "quest_rows_are_18": spec["content"]["quest_rows"] == 18,
        "reward_slots_are_4": len(layout["reward_slots_content"]) == 4,
        "provider_proxies_are_7": len(spec["content"]["provider_proxies"]) == 7,
        "action_segments_are_7": len(segments) == 7,
        "each_segment_is_32x22": all(box[2:] == [32, 22] for box in segments),
        "segments_are_vertically_contiguous": all(
            left[1] + left[3] == right[1]
            for left, right in zip(segments, segments[1:])
        ),
        "seal_scrollchild_anchor_matches_current_visual_at_top": [
            layout["detail_viewport"][0] + layout["seal_visual_content"][0],
            layout["detail_viewport"][1] + layout["seal_visual_content"][1],
            layout["seal_visual_content"][2],
            layout["seal_visual_content"][3],
        ] == [576, 68, 32, 32],
        "closed_root_visible_is_6px": (
            layout["ribbon_root_content"][1] + layout["ribbon_root_content"][3]
            - (layout["seal_visual_content"][1] + layout["seal_visual_content"][3])
        ) == 6,
        "body_width_is_unchanged_214": layout["detail_body_width"] == 214,
        "indented_width_is_unchanged_204": layout["detail_indented_width"] == 204,
        "intentional_body_overlay_is_14px": max(
            0, min(body_right, ribbon_right) - max(layout["detail_body_origin"][0], ribbon_left)
        ) == 14,
        "legacy_overlay_is_24px": max(
            0, min(legacy_right, ribbon_right) - max(layout["detail_body_origin"][0], ribbon_left)
        ) == 24,
        "ribbon_ends_32px_before_rewards": first_reward_y - tail_end == 32,
        "all_top_actions_inside_viewport": metrics[1]["enabled_action_count"] == 7,
        "partial_scroll_disables_first_clipped_action": metrics[2]["enabled_action_count"] == 6 and not metrics[2]["action_hitbox_enabled"][0],
        "fully_scrolled_out_has_zero_visible_ribbon": metrics[3]["seal_visible_area"] == 0 and metrics[3]["root_visible_area"] == 0 and metrics[3]["tail_visible_area"] == 0 and sum(metrics[3]["action_visible_areas"]) == 0,
        "fully_scrolled_out_has_zero_action_hitboxes": metrics[3]["enabled_action_count"] == 0,
        "no_right_outset": spec["constraints"]["no_outer_book_frame_or_right_outset"],
        "imagegen_calls_are_zero": spec["constraints"]["imagegen_calls"] == 0,
    }
    report = {
        "schema": "aeui.quest-log.seal-ribbon.simulation-report.v1",
        "version": spec["version"],
        "design_batch": spec["design_batch"],
        "status": "displayable" if all(checks.values()) else "blocked",
        "checks": checks,
        "checks_passed": sum(checks.values()),
        "checks_total": len(checks),
        "geometry": {
            "frame": spec["frame"],
            "detail_viewport": layout["detail_viewport"],
            "detail_scroll_child": layout["detail_scroll_child"],
            "body_width": layout["detail_body_width"],
            "indented_width": layout["detail_indented_width"],
            "temporary_body_overlay_px": [14, 24],
            "ribbon_reward_gap_px": first_reward_y - tail_end,
            "action_segments_content": segments,
        },
        "states": metrics,
        "ownership": {
            "seal_parent": spec["interaction"]["seal_parent"],
            "ribbon_parent": spec["interaction"]["ribbon_parent"],
            "seven_independent_buttons": True,
            "shared_popup_backing": False,
            "original_provider_dispatch": True,
        },
        "inputs": {
            "quest_log_shell": {
                "path": spec["inputs"]["quest_log_shell"],
                "sha256": sha256(resolve(root, spec["inputs"]["quest_log_shell"])),
            },
            "seal_atlas": {
                "path": spec["inputs"]["seal_atlas"],
                "sha256": sha256(resolve(root, spec["inputs"]["seal_atlas"])),
            },
        },
        "board": {"path": spec["outputs"]["board"], "sha256": sha256(board_path)},
        "non_authoritative": [
            "final hand-painted parchment or cloth fibers",
            "production alpha and atlas slicing",
            "normal hover pressed disabled state art",
            "client-side ScrollFrame mouse clipping implementation",
            "simulation pixels are not source, runtime, or ImageGen input",
        ],
        "imagegen": {"calls": 0, "uploads": 0},
    }
    report_path = resolve(root, spec["outputs"]["report"])
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
