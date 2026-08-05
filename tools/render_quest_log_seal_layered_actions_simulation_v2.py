#!/usr/bin/env python3
"""Render QS-B1 layered action simulations, including V4 dark substrate review."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFont


INK = (52, 29, 18, 238)
INK_SOFT = (73, 45, 27, 236)
INK_MUTED = (105, 78, 47, 235)
WINE = (91, 27, 24, 238)
DISABLED = (101, 89, 72, 150)
PAPER_INK = (50, 29, 17, 255)
SUBSTRATE = (122, 78, 43, 255)
SUBSTRATE_LIGHT = (170, 116, 63, 190)
SUBSTRATE_DARK = (68, 39, 24, 235)
BOARD = (32, 39, 37, 255)
BOARD_LOWER = (55, 39, 29, 255)

MOTIF_OFFSETS = {
    "share": (0, -1),
    "detail": (-1, 1),
    "show": (1, -1),
    "hide": (-1, 0),
    "clean": (1, 1),
    "reset": (-1, -1),
    "abandon": (1, 0),
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    return parser.parse_args()


def resolve(root: Path, value: str | Path) -> Path:
    path = Path(value)
    return path if path.is_absolute() else root / path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_base_module(root: Path) -> Any:
    path = root / "tools/render_quest_log_seal_ribbon_simulation_v1.py"
    spec = importlib.util.spec_from_file_location("aeui_qs_b1_v3_base", path)
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def intersection(left: list[int], right: list[int]) -> list[int] | None:
    x0 = max(left[0], right[0])
    y0 = max(left[1], right[1])
    x1 = min(left[0] + left[2], right[0] + right[2])
    y1 = min(left[1] + left[3], right[1] + right[3])
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


def substrate_height(visible_count: int, menu_open: bool) -> int:
    return 12 if not menu_open else 12 + visible_count * 22 + 8


def substrate_art_v3(visible_count: int, menu_open: bool) -> Image.Image:
    """Original V12 visual strip retained for deterministic reproduction."""
    width = 32
    height = substrate_height(visible_count, menu_open)
    art = Image.new("RGBA", (width, height), SUBSTRATE)
    mask = Image.new("L", (width, height), 0)
    mask_draw = ImageDraw.Draw(mask)
    if menu_open:
        levels = [0, 12] + [12 + index * 22 for index in range(1, visible_count + 1)]
        left_jitter = (2, 1, 2, 0, 1, 2, 1, 0, 2)
        right_jitter = (29, 30, 29, 31, 30, 29, 31, 30, 29)
        left = [
            (left_jitter[index % len(left_jitter)], y)
            for index, y in enumerate(levels)
        ]
        body_end = 12 + visible_count * 22
        left.extend(
            [
                (1, body_end + 3),
                (3, height - 2),
                (7, height - 1),
                (10, height - 4),
                (14, height - 1),
                (17, height - 4),
            ]
        )
        right = [
            (right_jitter[index % len(right_jitter)], y)
            for index, y in reversed(list(enumerate(levels)))
        ]
        tail_right = [
            (31, body_end + 3),
            (29, height - 2),
            (25, height - 1),
            (22, height - 4),
            (18, height - 1),
        ]
        polygon = left + tail_right + right
    else:
        polygon = [(2, 0), (29, 1), (30, height), (1, height - 1)]
    mask_draw.polygon(polygon, fill=255)

    draw = ImageDraw.Draw(art, "RGBA")
    # Large, low-frequency stains and broad value planes; no dense wallpaper.
    draw.ellipse((-10, 14, 22, 74), fill=(189, 126, 66, 30))
    draw.ellipse((13, max(12, height // 3), 43, max(42, height // 3 + 74)), fill=(51, 29, 20, 34))
    if height >= 24:
        draw.ellipse((-13, max(8, height - 82), 19, height + 4), fill=(76, 41, 25, 42))
    else:
        draw.ellipse((-7, 3, 13, height + 4), fill=(76, 41, 25, 32))
    draw.line((4, 1, 3, height - 3), fill=SUBSTRATE_LIGHT, width=2)
    draw.line((28, 2, 29, height - 3), fill=SUBSTRATE_DARK, width=2)
    draw.line((8, 4, 7, height - 7), fill=(205, 144, 77, 28), width=1)
    draw.line((23, 5, 24, height - 6), fill=(48, 29, 20, 26), width=1)
    if menu_open and height > 90:
        draw.line((7, height // 2, 10, height // 2 + 7), fill=(61, 34, 22, 70), width=1)
        draw.line((24, height // 2 + 19, 21, height // 2 + 25), fill=(185, 122, 63, 45), width=1)
    art.putalpha(ImageChops.multiply(art.getchannel("A"), mask))
    return art


def draw_flat_primitive(
    draw: ImageDraw.ImageDraw,
    primitive: dict[str, Any],
) -> None:
    fill = tuple(primitive["fill"])
    if primitive["kind"] == "polygon":
        draw.polygon([tuple(point) for point in primitive["points"]], fill=fill)
    elif primitive["kind"] == "ellipse":
        draw.ellipse(tuple(primitive["box"]), fill=fill)
    elif primitive["kind"] == "line":
        draw.line(
            [tuple(point) for point in primitive["points"]],
            fill=fill,
            width=primitive["width"],
        )
    else:
        raise ValueError(f"unsupported primitive kind: {primitive['kind']}")


def substrate_master_v4(spec: dict[str, Any]) -> Image.Image:
    """Build one dark, low-frequency canonical master from flat primitives."""
    mockup = spec["visual_mockup"]
    width, height = mockup["canonical_master_size"]
    art = Image.new("RGBA", (width, height), tuple(mockup["palette"]["base"]))
    draw = ImageDraw.Draw(art, "RGBA")
    for primitive in mockup["surface_primitives"]:
        draw_flat_primitive(draw, primitive)

    mask = Image.new("L", (width, height), 0)
    ImageDraw.Draw(mask).polygon(
        [tuple(point) for point in mockup["silhouette_points"]],
        fill=255,
    )
    art.putalpha(mask)
    return art


def substrate_art(
    spec: dict[str, Any],
    visible_count: int,
    menu_open: bool,
) -> Image.Image:
    """Compose the current visible length from one canonical source master."""
    if spec.get("visual_mockup", {}).get("substrate_variant") != "v4-dark-irregular":
        return substrate_art_v3(visible_count, menu_open)

    master = substrate_master_v4(spec)
    root_height = spec["layout"]["substrate_root_content"][3]
    action_height = spec["layout"]["action_slot_size"][1]
    tail_height = spec["layout"]["substrate_tail_size"][1]
    if not menu_open:
        return master.crop((0, 0, master.width, root_height))

    prefix_height = root_height + visible_count * action_height
    output = Image.new(
        "RGBA",
        (master.width, prefix_height + tail_height),
        (0, 0, 0, 0),
    )
    output.alpha_composite(master.crop((0, 0, master.width, prefix_height)), (0, 0))
    output.alpha_composite(
        master.crop((0, master.height - tail_height, master.width, master.height)),
        (0, prefix_height),
    )
    return output


def draw_imperfect_line(
    draw: ImageDraw.ImageDraw,
    points: list[tuple[int, int]],
    color: tuple[int, int, int, int],
    width: int = 2,
) -> None:
    draw.line(points, fill=(color[0], color[1], color[2], 70), width=width + 1)
    draw.line(points, fill=color, width=width)


def motif_art(action_id: str, state: str) -> Image.Image:
    image = Image.new("RGBA", (32, 22), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")
    dx, dy = MOTIF_OFFSETS[action_id]
    cx, cy = 16 + dx, 11 + dy
    if state == "disabled":
        color = DISABLED
    elif action_id == "abandon":
        color = WINE
    elif state == "hover":
        color = (73, 39, 20, 250)
        draw.ellipse((cx - 9, cy - 7, cx + 9, cy + 7), fill=(212, 145, 63, 22))
    elif state == "pressed":
        color = (38, 21, 15, 245)
        cy += 1
    else:
        color = INK

    if action_id == "share":
        draw.polygon([(cx - 1, cy + 2), (cx - 8, cy - 5), (cx - 5, cy + 4)], fill=color)
        draw.polygon([(cx + 1, cy + 2), (cx + 8, cy - 6), (cx + 5, cy + 4)], fill=color)
        draw_imperfect_line(draw, [(cx - 6, cy - 4), (cx, cy + 5)], color, 1)
        draw_imperfect_line(draw, [(cx + 6, cy - 5), (cx, cy + 5)], color, 1)
        draw.ellipse((cx - 2, cy + 3, cx + 2, cy + 7), outline=color, width=1)
    elif action_id == "detail":
        body = [(cx - 7, cy - 6), (cx + 5, cy - 5), (cx + 7, cy + 5), (cx - 6, cy + 6)]
        draw.polygon(body, outline=color)
        draw_imperfect_line(draw, [(cx - 4, cy - 2), (cx + 3, cy - 1)], color, 1)
        draw_imperfect_line(draw, [(cx - 4, cy + 2), (cx + 2, cy + 3)], color, 1)
        draw.polygon([(cx + 3, cy + 2), (cx + 7, cy + 5), (cx + 4, cy + 6)], fill=color)
    elif action_id in ("show", "hide"):
        draw.ellipse((cx - 7, cy - 7, cx + 7, cy + 7), outline=color, width=1)
        draw.polygon([(cx, cy - 8), (cx + 2, cy), (cx, cy + 8), (cx - 2, cy)], fill=color)
        draw.polygon([(cx - 8, cy), (cx, cy - 2), (cx + 8, cy), (cx, cy + 2)], fill=color)
        if action_id == "hide":
            draw_imperfect_line(draw, [(cx - 8, cy + 7), (cx + 8, cy - 7)], color, 2)
    elif action_id == "clean":
        for index, shift in enumerate((-5, 0, 5)):
            draw.arc((cx - 9, cy + shift - 4, cx + 8, cy + shift + 3), 195, 342, fill=color, width=2)
            if index != 1:
                draw.ellipse((cx + 5, cy + shift - 1, cx + 7, cy + shift + 1), fill=color)
    elif action_id == "reset":
        draw.arc((cx - 7, cy - 7, cx + 7, cy + 7), 28, 322, fill=color, width=2)
        draw.polygon([(cx + 6, cy - 7), (cx + 8, cy - 1), (cx + 2, cy - 3)], fill=color)
        draw.ellipse((cx - 2, cy - 2, cx + 2, cy + 2), outline=color, width=1)
    else:
        draw_imperfect_line(draw, [(cx - 8, cy - 4), (cx - 2, cy + 3)], color, 2)
        draw_imperfect_line(draw, [(cx + 2, cy - 4), (cx + 8, cy + 3)], color, 2)
        draw.line((cx - 2, cy - 1, cx + 2, cy + 1), fill=(120, 76, 47, 140), width=1)

    # Slightly soften state art so the simulation reads as stamped pigment,
    # not a crisp vector toolbar.  This remains non-authoritative geometry.
    if state == "disabled":
        image = ImageEnhance.Color(image).enhance(0.25)
    return image


def action_boxes(spec: dict[str, Any], state: dict[str, Any]) -> list[dict[str, Any]]:
    x, y = spec["layout"]["substrate_body_origin_content"]
    width, height = spec["layout"]["action_slot_size"]
    disabled = set(state["disabled_actions"])
    boxes = []
    for index, action_id in enumerate(state["visible_actions"]):
        boxes.append(
            {
                "id": action_id,
                "box": [x, y + index * height, width, height],
                "provider_enabled": action_id not in disabled,
            }
        )
    return boxes


def tail_box(spec: dict[str, Any], state: dict[str, Any]) -> list[int]:
    x, y = spec["layout"]["substrate_body_origin_content"]
    width, action_height = spec["layout"]["action_slot_size"]
    _, tail_height = spec["layout"]["substrate_tail_size"]
    return [x, y + len(state["visible_actions"]) * action_height, width, tail_height]


def draw_detail_content(
    base: Any,
    spec: dict[str, Any],
    fonts: dict[str, ImageFont.FreeTypeFont],
    seal: Image.Image,
    state: dict[str, Any],
) -> Image.Image:
    layout = spec["layout"]
    _, _, content_width, content_height = layout["detail_scroll_child"]
    content = Image.new("RGBA", (content_width, content_height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(content, "RGBA")
    x = layout["detail_body_origin"][0]
    draw.text((x, 8), "熔火之心", font=fonts["detail_title"], fill=PAPER_INK)
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
            fill=PAPER_INK if heading else INK_SOFT,
        )
    reward_labels = ("远古徽记", "熔火碎片", "公会印记", "金币袋")
    for index, box in enumerate(layout["reward_slots_content"]):
        base.draw_reward_slot(draw, box, reward_labels[index], index, fonts["reward"])
    draw.text((x, 342), "经验：9950", font=fonts["body"], fill=INK_SOFT)
    draw.text((x, 362), "远征公会将记录你的功绩。", font=fonts["body"], fill=INK_SOFT)
    draw.line((x, 390, x + 184, 390), fill=(101, 65, 32, 120), width=1)

    root_x, root_y, _, _ = layout["substrate_root_content"]
    background = substrate_art(spec, len(state["visible_actions"]), state["menu_open"])
    content.alpha_composite(background, (root_x, root_y))
    if state["menu_open"]:
        disabled = set(state["disabled_actions"])
        for item in action_boxes(spec, state):
            action_id = item["id"]
            if action_id in disabled:
                visual_state = "disabled"
            elif action_id == state.get("hover_action"):
                visual_state = "hover"
            else:
                visual_state = "normal"
            content.alpha_composite(motif_art(action_id, visual_state), (item["box"][0], item["box"][1]))

    sx, sy, sw, sh = layout["seal_visual_content"]
    content.alpha_composite(seal.resize((sw, sh), Image.Resampling.LANCZOS), (sx, sy))
    return content


def draw_state(
    base: Any,
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
    base.draw_frame_chrome(draw, origin, spec, fonts)
    base.draw_left_page(draw, origin, spec, fonts)
    content = draw_detail_content(base, spec, fonts, seal, state)
    vx, vy, vw, vh = spec["layout"]["detail_viewport"]
    offset = state["scroll_offset"]
    canvas.alpha_composite(content.crop((0, offset, vw, offset + vh)), (origin[0] + vx, origin[1] + vy))


def state_metrics(spec: dict[str, Any], state: dict[str, Any]) -> dict[str, Any]:
    layout = spec["layout"]
    viewport = [0, 0, layout["detail_viewport"][2], layout["detail_viewport"][3]]
    offset = state["scroll_offset"]
    seal = moved_for_scroll(layout["seal_hitbox_content"], offset)
    root = moved_for_scroll(layout["substrate_root_content"], offset)
    background = moved_for_scroll(
        [
            layout["substrate_root_content"][0],
            layout["substrate_root_content"][1],
            32,
            substrate_height(len(state["visible_actions"]), state["menu_open"]),
        ],
        offset,
    )
    buttons = []
    for item in action_boxes(spec, state) if state["menu_open"] else []:
        moved = moved_for_scroll(item["box"], offset)
        fully_visible = contains(viewport, moved)
        visible_area = area(intersection(viewport, moved))
        buttons.append(
            {
                "id": item["id"],
                "box_after_scroll": moved,
                "visible_area": visible_area,
                "fully_visible": fully_visible,
                "provider_enabled": item["provider_enabled"],
                "hitbox_enabled": fully_visible and item["provider_enabled"],
            }
        )
    tail = moved_for_scroll(tail_box(spec, state), offset)
    return {
        "id": state["id"],
        "menu_open": state["menu_open"],
        "scroll_offset": offset,
        "visible_actions": list(state["visible_actions"]),
        "hidden_actions": [
            item["id"]
            for item in spec["actions"]
            if item["id"] not in state["visible_actions"]
        ],
        "disabled_actions": list(state["disabled_actions"]),
        "seal_visible_area": area(intersection(viewport, seal)),
        "root_visible_area": area(intersection(viewport, root)),
        "background_visible_area": area(intersection(viewport, background)),
        "background_height": background[3],
        "buttons": buttons,
        "tail_box_after_scroll": tail,
        "tail_visible_area": area(intersection(viewport, tail)) if state["menu_open"] else 0,
        "enabled_action_count": sum(item["hitbox_enabled"] for item in buttons),
    }


def contiguous(buttons: list[dict[str, Any]]) -> bool:
    return all(
        left["box_after_scroll"][1] + left["box_after_scroll"][3]
        == right["box_after_scroll"][1]
        for left, right in zip(buttons, buttons[1:])
    )


def layered_substrate_art(spec: dict[str, Any], visible_count: int) -> Image.Image:
    art = substrate_art(spec, visible_count, True)
    for index, action in enumerate(spec["actions"][:visible_count]):
        art.alpha_composite(motif_art(action["id"], "normal"), (0, 12 + index * 22))
    return art


def render_zoom_board(
    root: Path,
    spec: dict[str, Any],
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> Path | None:
    zoom_output = spec["outputs"].get("zoom")
    if not zoom_output:
        return None

    canvas = Image.new("RGBA", (1600, 980), BOARD)
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rectangle((0, 86, canvas.width, canvas.height), fill=BOARD_LOWER)
    draw.text(
        (30, 20),
        spec["presentation"]["zoom_title"],
        font=fonts["board_title"],
        fill=(231, 202, 145, 255),
    )
    draw.text(
        (30, 52),
        spec["presentation"]["zoom_subtitle"],
        font=fonts["board_body"],
        fill=(194, 166, 113, 255),
    )

    substrate = substrate_art(spec, 7, True)
    layered = layered_substrate_art(spec, 7)
    draw.text((40, 106), "A · 空白布底 4×", font=fonts["board_body"], fill=(229, 197, 135, 255))
    draw.text((210, 106), "B · 真实叠放 4×", font=fonts["board_body"], fill=(229, 197, 135, 255))
    canvas.alpha_composite(substrate.resize((128, 696), Image.Resampling.NEAREST), (40, 142))
    canvas.alpha_composite(layered.resize((128, 696), Image.Resampling.NEAREST), (210, 142))

    top = substrate.crop((0, 0, 32, 64)).resize((256, 512), Image.Resampling.NEAREST)
    tail = substrate.crop((0, 120, 32, 174)).resize((256, 432), Image.Resampling.NEAREST)
    draw.text((400, 106), "C · 火漆下根部 / 上段 8×", font=fonts["board_body"], fill=(229, 197, 135, 255))
    draw.text((700, 106), "D · 尾端粗切口 8×", font=fonts["board_body"], fill=(229, 197, 135, 255))
    canvas.alpha_composite(top, (400, 142))
    canvas.alpha_composite(tail, (700, 142))

    draw.text((1010, 106), "E · 动态长度 3×", font=fonts["board_body"], fill=(229, 197, 135, 255))
    for index, count in enumerate((7, 5, 3)):
        art = layered_substrate_art(spec, count)
        scaled = art.resize((96, art.height * 3), Image.Resampling.NEAREST)
        x = 1010 + index * 126
        canvas.alpha_composite(scaled, (x, 142))
        draw.text((x + 34, 154 + scaled.height), f"{count} 项", font=fonts["board_small"], fill=(208, 177, 117, 255))

    draw.text((400, 690), "综合色角色（平面几何，非最终纹理）", font=fonts["board_body"], fill=(229, 197, 135, 255))
    palette = spec["visual_mockup"]["palette"]
    palette_items = [
        ("主体：烟熏深旧棕", palette["base"]),
        ("次亮面：暗赭灰棕", palette["light_plane"]),
        ("阴影：深棕灰", palette["shadow_plane"]),
        ("污渍：炭化旧棕", palette["stain"]),
    ]
    for index, (label, color) in enumerate(palette_items):
        y = 728 + index * 46
        draw.rectangle((400, y, 448, y + 28), fill=tuple(color), outline=(42, 31, 24, 255), width=2)
        draw.text((462, y + 5), label, font=fonts["board_small"], fill=(208, 177, 117, 255))

    notes = spec["presentation"]["zoom_notes"]
    for index, note in enumerate(notes):
        draw.text((700, 700 + index * 31), f"· {note}", font=fonts["board_small"], fill=(202, 173, 115, 255))
    draw.text(
        (30, 936),
        "非权威：最终纤维、磨损笔触、Alpha、纹章细节与四态；本图不得成为 source / runtime / ImageGen 输入。",
        font=fonts["board_small"],
        fill=(174, 146, 96, 255),
    )

    zoom_path = resolve(root, zoom_output)
    zoom_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(zoom_path, "PNG")
    return zoom_path


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    spec = json.loads(args.spec.read_text(encoding="utf-8"))
    base = load_base_module(root)
    title_path = resolve(root, spec["inputs"]["title_font"])
    body_path = resolve(root, spec["inputs"]["body_font"])
    fonts = {
        "title": base.load_font(title_path, 16),
        "detail_title": base.load_font(title_path, 15),
        "heading": base.load_font(title_path, 11),
        "body": base.load_font(body_path, 10),
        "row": base.load_font(body_path, 10),
        "small": base.load_font(body_path, 9),
        "reward": base.load_font(body_path, 8),
        "board_title": base.load_font(title_path, 19),
        "board_body": base.load_font(body_path, 11),
        "board_small": base.load_font(body_path, 10),
    }
    shell, seal = base.load_inputs(root, spec)
    canvas = Image.new("RGBA", tuple(spec["canvas"]), BOARD)
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rectangle((0, 626, canvas.width, canvas.height), fill=BOARD_LOWER)
    for x in range(-90, canvas.width + 120, 150):
        draw.polygon(
            [(x, 626), (x + 126, 626), (x + 190, canvas.height), (x + 14, canvas.height)],
            fill=(67, 47, 32, 155),
            outline=(40, 28, 20, 180),
        )
    draw.text((30, 22), spec["presentation"]["title"], font=fonts["board_title"], fill=(237, 201, 128, 255))
    draw.text((30, 52), spec["presentation"]["subtitle"], font=fonts["board_body"], fill=(203, 173, 113, 255))
    origins = [tuple(value) for value in spec["presentation"]["origins"]]
    metrics = []
    for origin, state in zip(origins, spec["states"]):
        draw.text((origin[0], origin[1] - 27), state["label"], font=fonts["board_body"], fill=(237, 201, 128, 255))
        draw_state(base, canvas, shell, seal, origin, spec, fonts, state)
        metrics.append(state_metrics(spec, state))
    footer_lines = spec["presentation"].get(
        "footer_lines",
        [
            "V3 资产边界：空白布底 root + seamless body variants + tail（无鼠标）｜七个透明纹章 normal master（独立 Button）｜状态由确定性 exporter / runtime 派生。",
            "美术目标：低频褶皱与污渍、手裁不齐边、稀疏磨损、印墨缺损与克制偏移；禁止均匀壁纸织纹、七格卡片、工整图标柱。当前只是几何与层序，ImageGen 0/0。",
        ],
    )
    draw.text((30, 1172), footer_lines[0], font=fonts["board_small"], fill=(213, 179, 113, 255))
    draw.text((30, 1195), footer_lines[1], font=fonts["board_small"], fill=(192, 159, 103, 255))
    board_path = resolve(root, spec["outputs"]["board"])
    board_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(board_path, "PNG")
    zoom_path = render_zoom_board(root, spec, fonts)

    by_id = {item["id"]: item for item in metrics}
    closed = by_id["closed-top"]
    all_seven = by_id["open-all-seven"]
    five = by_id["open-filtered-five"]
    three = by_id["open-filtered-three-disabled"]
    partial = by_id["filtered-five-partial-scroll"]
    full = by_id["filtered-five-fully-scrolled-out"]
    first_reward_y = min(box[1] for box in spec["layout"]["reward_slots_content"])
    all_tail_end = tail_box(spec, spec["states"][1])[1] + 8
    five_tail_end = tail_box(spec, spec["states"][2])[1] + 8
    three_tail_end = tail_box(spec, spec["states"][3])[1] + 8
    checks = {
        "frame_is_676x464": spec["frame"] == [676, 464],
        "detail_viewport_is_real_246x324": spec["layout"]["detail_viewport"] == [366, 64, 246, 324],
        "quest_rows_are_18": spec["content"]["quest_rows"] == 18,
        "reward_slots_are_4": (
            spec["content"]["reward_slots"] == 4
            and len(spec["layout"]["reward_slots_content"]) == 4
        ),
        "seven_provider_definitions": len(spec["actions"]) == 7,
        "closed_has_no_action_buttons": not closed["buttons"] and closed["enabled_action_count"] == 0,
        "closed_root_still_belongs_to_scrollchild": closed["root_visible_area"] > 0,
        "all_seven_are_independent_buttons": len(all_seven["buttons"]) == 7,
        "all_seven_enabled_at_top": all_seven["enabled_action_count"] == 7,
        "all_seven_slots_are_contiguous": contiguous(all_seven["buttons"]),
        "maximum_tail_ends_32px_before_rewards": first_reward_y - all_tail_end == 32,
        "filtered_five_has_exact_order": five["visible_actions"] == ["share", "detail", "show", "reset", "abandon"],
        "filtered_five_removes_hide_and_clean": five["hidden_actions"] == ["hide", "clean"],
        "filtered_five_has_no_blank_slots": len(five["buttons"]) == 5 and contiguous(five["buttons"]),
        "filtered_five_background_shortens_by_44px": all_seven["background_height"] - five["background_height"] == 44,
        "filtered_five_tail_moves_up_by_44px": all_tail_end - five_tail_end == 44,
        "filtered_three_has_exact_order": three["visible_actions"] == ["share", "show", "abandon"],
        "filtered_three_has_no_blank_slots": len(three["buttons"]) == 3 and contiguous(three["buttons"]),
        "filtered_three_background_shortens_by_88px": all_seven["background_height"] - three["background_height"] == 88,
        "filtered_three_tail_moves_up_by_88px": all_tail_end - three_tail_end == 88,
        "disabled_action_remains_in_flow": any(item["id"] == "show" for item in three["buttons"]),
        "disabled_action_has_no_enabled_hitbox": three["enabled_action_count"] == 2 and not next(item for item in three["buttons"] if item["id"] == "show")["hitbox_enabled"],
        "partial_scroll_clips_first_action": partial["buttons"][0]["visible_area"] < 32 * 22 and not partial["buttons"][0]["hitbox_enabled"],
        "partial_scroll_keeps_contiguous_visual_order": contiguous(partial["buttons"]),
        "partial_scroll_mirrors_reset_disabled": not next(item for item in partial["buttons"] if item["id"] == "reset")["hitbox_enabled"],
        "partial_scroll_expected_enabled_count": partial["enabled_action_count"] == 3,
        "fully_scrolled_out_has_zero_background": full["background_visible_area"] == 0,
        "fully_scrolled_out_has_zero_action_hitboxes": full["enabled_action_count"] == 0,
        "substrate_receives_no_mouse": spec["constraints"]["substrate_is_visual_only_and_receives_no_mouse"],
        "motifs_are_independent_transparent_assets": spec["constraints"]["motifs_are_seven_independent_transparent_assets"],
        "no_motif_is_baked_into_background": spec["constraints"]["no_motif_is_baked_into_background"],
        "hidden_actions_compact_without_blank_slots": spec["constraints"]["hidden_actions_compact_without_blank_slots"],
        "no_action_owns_cloth_slice": spec["constraints"]["no_action_owns_a_cloth_background_slice"],
        "no_page_reflow": spec["constraints"]["no_page_reflow_or_permanent_text_narrowing"],
        "imagegen_calls_are_zero": spec["constraints"]["imagegen_calls"] == 0,
    }
    if spec.get("visual_mockup", {}).get("substrate_variant") == "v4-dark-irregular":
        mockup = spec["visual_mockup"]
        checks.update(
            {
                "v4_uses_one_canonical_master": mockup["dynamic_assembly"] == "prefix-plus-tail-from-one-master",
                "v4_base_is_darker_than_old_v12": max(mockup["palette"]["base"][:3]) <= 90,
                "v4_highlight_is_not_gold_or_bright": max(mockup["palette"]["light_plane"][:3]) <= 120,
                "v4_tail_has_two_unequal_coarse_notches": mockup["tail_notch_count"] in (2, 3),
                "v4_has_no_periodic_22px_edge_control_points": all(
                    point[1] % 22 != 0
                    for point in mockup["edge_control_points"]
                    if point[1] not in (0, 174)
                ),
            }
        )
    report = {
        "schema": "aeui.quest-log.seal-layered-actions.simulation-report.v1",
        "version": spec["version"],
        "design_batch": spec["design_batch"],
        "status": "displayable" if all(checks.values()) else "blocked",
        "checks": checks,
        "checks_passed": sum(checks.values()),
        "checks_total": len(checks),
        "states": metrics,
        "asset_ownership": {
            "visual_substrate": ["root", "seamless-body-variants", "tail"],
            "visual_substrate_receives_mouse": False,
            "motif_normal_masters": [item["id"] for item in spec["actions"]],
            "motifs_have_transparent_background": True,
            "runtime_buttons": [item["provider"] for item in spec["actions"]],
            "hidden_reflow": "compact-visible-order",
            "disabled_reflow": "remain-in-flow",
        },
        "geometry": {
            "maximum_background_height": all_seven["background_height"],
            "five_action_background_height": five["background_height"],
            "three_action_background_height": three["background_height"],
            "maximum_reward_gap": first_reward_y - all_tail_end,
            "five_action_reward_gap": first_reward_y - five_tail_end,
            "three_action_reward_gap": first_reward_y - three_tail_end,
        },
        "inputs": {
            "quest_log_shell": {"path": spec["inputs"]["quest_log_shell"], "sha256": sha256(resolve(root, spec["inputs"]["quest_log_shell"]))},
            "seal_atlas": {"path": spec["inputs"]["seal_atlas"], "sha256": sha256(resolve(root, spec["inputs"]["seal_atlas"]))},
        },
        "board": {"path": spec["outputs"]["board"], "sha256": sha256(board_path)},
        "zoom": (
            {"path": spec["outputs"]["zoom"], "sha256": sha256(zoom_path)}
            if zoom_path is not None
            else None
        ),
        "imagegen": {"calls": 0, "uploads": 0},
        "non_authoritative": [
            "final substrate folds, stains, edge wear and seamless body variants",
            "final seven transparent stamped-ink motif masters",
            "normal hover pressed disabled exporter output",
            "client-side hidden-provider policy and configuration UI",
            "simulation is not source, runtime, addon art, or future ImageGen input"
        ]
    }
    report_path = resolve(root, spec["outputs"]["report"])
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
