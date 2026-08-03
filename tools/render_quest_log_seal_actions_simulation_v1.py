#!/usr/bin/env python3
"""Render the deterministic Quest Log seal support and action-menu preview."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops, ImageDraw, ImageFont


INK = (49, 29, 18, 255)
INK_SOFT = (75, 47, 27, 255)
INK_MUTED = (104, 80, 52, 255)
PAPER = (190, 150, 91, 255)
PAPER_LIGHT = (210, 174, 111, 255)
PAPER_DARK = (139, 96, 52, 255)
LEATHER = (69, 34, 23, 255)
LEATHER_LIGHT = (112, 61, 31, 255)
LEATHER_DARK = (30, 15, 12, 255)
BRASS = (143, 99, 39, 255)
BRASS_LIGHT = (196, 148, 67, 255)
DANGER = (91, 22, 18, 255)


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


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(
        str(path), size, layout_engine=ImageFont.Layout.BASIC
    )


def contains(outer: list[int], inner: list[int]) -> bool:
    ox, oy, ow, oh = outer
    ix, iy, iw, ih = inner
    return (
        ix >= ox
        and iy >= oy
        and ix + iw <= ox + ow
        and iy + ih <= oy + oh
    )


def intersects(a: list[int], b: list[int]) -> bool:
    ax, ay, aw, ah = a
    bx, by, bw, bh = b
    return not (
        ax + aw <= bx
        or bx + bw <= ax
        or ay + ah <= by
        or by + bh <= ay
    )


def has_free_square(
    surface: list[int], occupied: list[int], size: int
) -> bool:
    """Return whether an axis-aligned square fits on a surface without overlap."""
    sx, sy, sw, sh = surface
    for y in range(sy, sy + sh - size + 1):
        for x in range(sx, sx + sw - size + 1):
            candidate = [x, y, size, size]
            if not intersects(candidate, occupied):
                return True
    return False


def draw_outlined_text(
    draw: ImageDraw.ImageDraw,
    xy: tuple[float, float],
    value: str,
    face: ImageFont.FreeTypeFont,
    fill: tuple[int, int, int, int],
    *,
    anchor: str | None = None,
) -> None:
    draw.text(
        xy,
        value,
        font=face,
        fill=fill,
        anchor=anchor,
        stroke_width=1,
        stroke_fill=(20, 12, 8, 165),
    )


def load_seal(root: Path, spec: dict[str, Any]) -> Image.Image:
    atlas = Image.open(resolve(root, spec["inputs"]["seal_atlas"])).convert(
        "RGBA"
    )
    cell_width = atlas.width // 4
    return atlas.crop((0, 0, cell_width, atlas.height))


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
        radius=3,
        fill=(48, 28, 18, 238),
        outline=BRASS,
        width=1,
    )
    draw.rectangle(
        (x + 4, y + 4, x + 28, y + height - 5),
        fill=(68 + index * 15, 60, 38 + index * 12, 255),
        outline=BRASS_LIGHT,
        width=1,
    )
    draw.text(
        (x + 33, y + height / 2),
        label,
        font=body,
        fill=(222, 191, 126, 255),
        anchor="lm",
    )


def draw_support_tab(
    layer: Image.Image,
    layout: dict[str, list[int]],
    origin: tuple[int, int],
    seal: Image.Image,
) -> None:
    ox, oy = origin
    tx, ty, tw, th = layout["support_tab"]
    tx += ox
    ty += oy
    draw = ImageDraw.Draw(layer, "RGBA")
    tab = [
        (tx, ty + 5),
        (tx + 13, ty),
        (tx + tw - 5, ty + 4),
        (tx + tw, ty + th // 2),
        (tx + tw - 6, ty + th - 4),
        (tx + 13, ty + th),
        (tx, ty + th - 5),
    ]
    draw.polygon(tab, fill=LEATHER_DARK)
    inner = [(x - 2 if x == tx + tw else x + 2, y) for x, y in tab]
    draw.polygon(inner, fill=LEATHER, outline=LEATHER_LIGHT)
    draw.line(
        (tx + 4, ty + 7, tx + tw - 8, ty + 5),
        fill=BRASS_LIGHT,
        width=1,
    )
    draw.line(
        (tx + 5, ty + th - 7, tx + tw - 8, ty + th - 5),
        fill=(26, 12, 10, 220),
        width=2,
    )
    for ry in (ty + 10, ty + th - 10):
        draw.ellipse(
            (tx + 5, ry - 2, tx + 9, ry + 2),
            fill=BRASS,
            outline=(63, 37, 16, 255),
        )

    sx, sy, sw, sh = layout["seal_visual"]
    resized = seal.resize((sw, sh), Image.Resampling.LANCZOS)
    layer.alpha_composite(resized, (ox + sx, oy + sy))


def draw_brass_corner_seal(
    layer: Image.Image,
    layout: dict[str, Any],
    origin: tuple[int, int],
    seal: Image.Image,
) -> None:
    """Place the accepted wax mark in a small socket on the real brass corner."""
    ox, oy = origin
    draw = ImageDraw.Draw(layer, "RGBA")
    bx, by, bw, bh = layout["seal_socket"]
    box = (ox + bx, oy + by, ox + bx + bw - 1, oy + by + bh - 1)
    draw.ellipse(box, fill=(56, 33, 15, 245), outline=(53, 27, 11, 255), width=2)
    draw.ellipse(
        (box[0] + 3, box[1] + 3, box[2] - 3, box[3] - 3),
        fill=(118, 77, 28, 235),
        outline=BRASS_LIGHT,
        width=1,
    )
    draw.arc(
        (box[0] + 5, box[1] + 5, box[2] - 5, box[3] - 5),
        205,
        332,
        fill=(222, 174, 84, 210),
        width=1,
    )
    sx, sy, sw, sh = layout["seal_visual"]
    resized = seal.resize((sw, sh), Image.Resampling.LANCZOS)
    layer.alpha_composite(resized, (ox + sx, oy + sy))


def draw_direct_page_seal(
    layer: Image.Image,
    layout: dict[str, Any],
    origin: tuple[int, int],
    seal: Image.Image,
) -> None:
    """Lay the accepted wax mark directly on the upper-right detail paper."""
    ox, oy = origin
    sx, sy, sw, sh = layout["seal_visual"]
    resized = seal.resize((sw, sh), Image.Resampling.LANCZOS)
    layer.alpha_composite(resized, (ox + sx, oy + sy))


def draw_bottom_action_rail(
    layer: Image.Image,
    spec: dict[str, Any],
    origin: tuple[int, int],
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> None:
    """Render seven transient provider proxies along the existing lower binding."""
    ox, oy = origin
    draw = ImageDraw.Draw(layer, "RGBA")
    rx, ry, rw, rh = spec["layout"]["action_rail"]
    rail_box = (ox + rx, oy + ry, ox + rx + rw - 1, oy + ry + rh - 1)
    draw.rounded_rectangle(
        rail_box,
        radius=4,
        fill=(35, 17, 13, 224),
        outline=(79, 45, 23, 240),
        width=2,
    )
    draw.line(
        (rail_box[0] + 5, rail_box[1] + 2, rail_box[2] - 5, rail_box[1] + 2),
        fill=(168, 116, 47, 190),
        width=1,
    )
    labels = spec["content"]["menu_actions"]
    for index, slot in enumerate(spec["layout"]["action_slots"]):
        x, y, width, height = slot
        x += ox
        y += oy
        fill = (61, 31, 21, 242)
        outline = BRASS if index < len(labels) - 1 else (133, 54, 39, 255)
        draw.rounded_rectangle(
            (x, y, x + width - 1, y + height - 1),
            radius=3,
            fill=fill,
            outline=outline,
            width=1,
        )
        draw.line(
            (x + 4, y + 3, x + width - 5, y + 3),
            fill=(173, 113, 51, 150),
            width=1,
        )
        draw.text(
            (x + width / 2, y + height / 2 + 1),
            labels[index],
            font=fonts["small"],
            fill=(225, 194, 132, 255),
            anchor="mm",
        )


def draw_right_page_action_list(
    layer: Image.Image,
    spec: dict[str, Any],
    origin: tuple[int, int],
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> None:
    """Render seven transient ledger tabs down the right side of the detail page."""
    ox, oy = origin
    draw = ImageDraw.Draw(layer, "RGBA")
    labels = spec["content"]["menu_actions"]
    for index, slot in enumerate(spec["layout"]["action_slots"]):
        x, y, width, height = slot
        x += ox
        y += oy
        points = [
            (x + 7, y),
            (x + width - 2, y),
            (x + width, y + height // 2),
            (x + width - 2, y + height),
            (x + 7, y + height),
            (x, y + height // 2),
        ]
        fill = (72, 39, 24, 238)
        outline = BRASS if index < len(labels) - 1 else (133, 54, 39, 255)
        draw.polygon(points, fill=fill, outline=outline)
        draw.line(
            (x + 9, y + 3, x + width - 7, y + 3),
            fill=(178, 124, 57, 145),
            width=1,
        )
        draw.text(
            (x + width / 2 + 3, y + height / 2 + 1),
            labels[index],
            font=fonts["small"],
            fill=(228, 198, 137, 255),
            anchor="mm",
        )


def draw_exterior_ledger_tabs(
    layer: Image.Image,
    shell: Image.Image,
    spec: dict[str, Any],
    origin: tuple[int, int],
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> None:
    """Render independent ledger tabs outside the page and occlude their roots."""
    ox, oy = origin
    draw = ImageDraw.Draw(layer, "RGBA")
    labels = spec["content"]["menu_actions"]
    text_boxes = spec["layout"]["action_text_safe"]
    for index, slot in enumerate(spec["layout"]["action_slots"]):
        x, y, width, height = slot
        x += ox
        y += oy
        is_danger = index == len(labels) - 1
        fill = (88, 45, 27, 246) if not is_danger else (78, 27, 24, 250)
        outline = BRASS if not is_danger else (148, 57, 43, 255)
        points = [
            (x, y + 5),
            (x + width - 8, y + 1),
            (x + width, y + height // 2),
            (x + width - 8, y + height - 1),
            (x, y + height - 5),
        ]
        draw.polygon(points, fill=(34, 17, 12, 215))
        inset = [
            (x + 2, y + 6),
            (x + width - 9, y + 3),
            (x + width - 3, y + height // 2),
            (x + width - 9, y + height - 3),
            (x + 2, y + height - 6),
        ]
        draw.polygon(inset, fill=fill, outline=outline)
        draw.line(
            (x + 12, y + 6, x + width - 14, y + 4),
            fill=(188, 132, 61, 135),
            width=1,
        )
        tx, ty, tw, th = text_boxes[index]
        draw.text(
            (ox + tx + tw / 2, oy + ty + th / 2 + 1),
            labels[index],
            font=fonts["small"],
            fill=(230, 201, 143, 255),
            anchor="mm",
        )
        draw.ellipse(
            (
                x + width - 14,
                y + height // 2 - 2,
                x + width - 10,
                y + height // 2 + 2,
            ),
            fill=BRASS_LIGHT,
            outline=(77, 44, 19, 255),
        )

    mx, my, mw, mh = spec["layout"]["page_edge_mask"]
    edge = shell.crop((mx, my, mx + mw, my + mh))
    layer.alpha_composite(edge, (ox + mx, oy + my))


def draw_parchment_seal_tag(
    layer: Image.Image,
    layout: dict[str, list[int]],
    origin: tuple[int, int],
    seal: Image.Image,
) -> None:
    """Draw a page-owned docket tag whose root is trapped under the page lip."""
    ox, oy = origin
    tx, ty, tw, th = layout["document_tag"]
    tx += ox
    ty += oy
    draw = ImageDraw.Draw(layer, "RGBA")

    hx, hy, hw, hh = layout["tag_head"]
    hx += ox
    hy += oy

    # Contact shadow: a narrow strip lies over the opened cover after leaving
    # the page stack. Its wider folded head is the actual wax-bearing surface.
    draw.polygon(
        [
            (tx + 2, ty + 7),
            (tx + tw, ty + 5),
            (tx + tw + 3, ty + th),
            (tx + 4, ty + th + 3),
        ],
        fill=(22, 12, 9, 155),
    )
    tag = [
        (tx + 1, ty + 3),
        (tx + tw - 6, ty),
        (tx + tw, ty + 5),
        (tx + tw - 2, ty + th - 4),
        (tx + 4, ty + th),
        (tx, ty + th - 5),
    ]
    draw.polygon(tag, fill=PAPER, outline=PAPER_DARK)
    draw.line(
        (tx + 7, ty + 7, tx + tw - 8, ty + 5),
        fill=(226, 193, 130, 150),
        width=1,
    )
    draw.line(
        (tx + 9, ty + th - 6, tx + tw - 9, ty + th - 5),
        fill=(101, 67, 34, 165),
        width=1,
    )

    head_shadow = [
        (hx + 5, hy + 5),
        (hx + hw - 5, hy + 4),
        (hx + hw + 3, hy + 12),
        (hx + hw, hy + hh - 5),
        (hx + hw - 7, hy + hh + 3),
        (hx + 5, hy + hh),
        (hx, hy + 11),
    ]
    draw.polygon(head_shadow, fill=(22, 12, 9, 165))
    head = [
        (hx + 6, hy),
        (hx + hw - 7, hy + 1),
        (hx + hw, hy + 8),
        (hx + hw - 2, hy + hh - 7),
        (hx + hw - 8, hy + hh),
        (hx + 6, hy + hh - 2),
        (hx, hy + hh - 9),
        (hx + 1, hy + 7),
    ]
    draw.polygon(head, fill=PAPER_LIGHT, outline=PAPER_DARK)
    draw.line(
        (hx + 5, hy + 7, hx + 7, hy + hh - 7),
        fill=(113, 77, 41, 130),
        width=1,
    )

    # The right-page lip is above the tag root. This small quiet overlay is
    # the decisive z-order cue that the tag emerges from between pages.
    lx, ly, lw, lh = layout["page_lip"]
    lx += ox
    ly += oy
    lip = [
        (lx, ly + 3),
        (lx + lw - 7, ly),
        (lx + lw - 1, ly + 5),
        (lx + lw, ly + 11),
        (lx + lw - 4, ly + lh - 6),
        (lx + lw - 9, ly + lh),
        (lx, ly + lh - 3),
    ]
    draw.polygon(lip, fill=PAPER_LIGHT)
    draw.line(
        (lx + lw - 3, ly + 7, lx + lw - 5, ly + lh - 6),
        fill=(96, 63, 33, 210),
        width=2,
    )
    draw.line(
        (lx + 3, ly + 6, lx + lw - 8, ly + 4),
        fill=(231, 203, 145, 145),
        width=1,
    )

    sx, sy, sw, sh = layout["seal_visual"]
    resized = seal.resize((sw, sh), Image.Resampling.LANCZOS)
    layer.alpha_composite(resized, (ox + sx, oy + sy))


def offset_polygon(
    points: list[list[int]],
    dx: int,
    dy: int,
) -> list[tuple[int, int]]:
    return [(x + dx, y + dy) for x, y in points]


def draw_page_layered_seal_tag(
    layer: Image.Image,
    shell: Image.Image,
    layout: dict[str, Any],
    origin: tuple[int, int],
    seal: Image.Image,
    *,
    cover_root: bool = True,
) -> None:
    """Draw one flexible docket tag, then restore the real page lip above it."""
    ox, oy = origin
    draw = ImageDraw.Draw(layer, "RGBA")
    tag_points = offset_polygon(layout["document_tag_polygon"], ox, oy)

    # The soft offset follows the same irregular silhouette and remains on the
    # book surface; it is a contact shadow, not an exterior frame fastener.
    draw.polygon(
        offset_polygon(layout["document_tag_polygon"], ox + 2, oy + 3),
        fill=(24, 13, 9, 155),
    )
    draw.polygon(tag_points, fill=PAPER, outline=PAPER_DARK)

    for line in layout["tag_crease_lines"]:
        points = offset_polygon(line, ox, oy)
        draw.line(points, fill=(103, 69, 36, 145), width=1)

    fold = offset_polygon(layout["tag_terminal_fold"], ox, oy)
    draw.polygon(fold, fill=(163, 119, 65, 235))
    draw.line(
        [fold[0], fold[1], fold[2]],
        fill=(91, 58, 30, 190),
        width=1,
    )

    # Re-sample the already accepted shell at the same 676x464 geometry and
    # put only the real page-lip pixels back above the tag root. The preview no
    # longer substitutes a beige rectangle for page occlusion.
    if cover_root:
        px, py, pw, ph = layout["page_lip_source_box"]
        page_crop = shell.crop((px, py, px + pw, py + ph)).copy()
        page_mask = Image.new("L", (pw, ph), 0)
        mask_draw = ImageDraw.Draw(page_mask)
        mask_points = [
            (x - px, y - py) for x, y in layout["page_lip_mask_polygon"]
        ]
        mask_draw.polygon(mask_points, fill=255)
        page_crop.putalpha(
            ImageChops.multiply(page_crop.getchannel("A"), page_mask)
        )
        layer.alpha_composite(page_crop, (ox + px, oy + py))

        lip_edge = offset_polygon(layout["page_lip_edge"], ox, oy)
        draw.line(lip_edge, fill=(79, 48, 27, 210), width=1)
        highlight = [(x - 1, y - 1) for x, y in lip_edge[:-1]]
        if len(highlight) > 1:
            draw.line(highlight, fill=(221, 190, 127, 135), width=1)

    sx, sy, sw, sh = layout["seal_visual"]
    resized = seal.resize((sw, sh), Image.Resampling.LANCZOS)
    layer.alpha_composite(resized, (ox + sx, oy + sy))


def draw_unfolded_tag_menu(
    layer: Image.Image,
    spec: dict[str, Any],
    origin: tuple[int, int],
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> None:
    """Draw one parchment sheet whose right spur remains connected to the tag."""
    ox, oy = origin
    mx, my, mw, mh = spec["layout"]["menu"]
    mx += ox
    my += oy
    connector_x, connector_y = spec["layout"]["menu_connection_point"]
    connector_x += ox
    connector_y += oy
    draw = ImageDraw.Draw(layer, "RGBA")

    sheet = [
        (mx + 8, my + 3),
        (mx + mw - 13, my),
        (mx + mw - 7, my + 92),
        (connector_x, connector_y - 13),
        (connector_x + 3, connector_y + 11),
        (mx + mw - 7, my + 132),
        (mx + mw - 4, my + mh - 11),
        (mx + mw - 12, my + mh - 3),
        (mx + 7, my + mh - 6),
        (mx + 2, my + 10),
    ]
    draw.polygon(
        [(x + 3, y + 4) for x, y in sheet],
        fill=(29, 16, 11, 175),
    )
    draw.polygon(sheet, fill=PAPER, outline=PAPER_DARK)

    # The title is ink on a folded parchment band, not a separate leather
    # popup title bar. This keeps the opened state one continuous document.
    header = [
        (mx + 11, my + 10),
        (mx + mw - 20, my + 8),
        (mx + mw - 17, my + 38),
        (mx + 12, my + 40),
    ]
    draw.polygon(header, fill=(173, 128, 71, 235))
    draw.line(
        (mx + 14, my + 42, mx + mw - 21, my + 40),
        fill=(102, 67, 33, 180),
        width=1,
    )
    draw.text(
        (mx + (mw - 8) / 2, my + 25),
        "任务事务",
        font=fonts["menu_title"],
        fill=INK,
        anchor="mm",
    )

    actions = spec["content"]["menu_actions"]
    cursor = my + 48
    for index, action in enumerate(actions):
        if index == 2:
            draw.line(
                (mx + 17, cursor - 3, mx + mw - 24, cursor - 3),
                fill=(104, 68, 33, 150),
                width=1,
            )
            draw.text(
                (mx + 17, cursor + 1),
                "地图标记",
                font=fonts["small"],
                fill=INK_MUTED,
            )
            cursor += 18
        if index == len(actions) - 1:
            draw.line(
                (mx + 17, cursor - 3, mx + mw - 24, cursor - 3),
                fill=(104, 68, 33, 150),
                width=1,
            )
            cursor += 3
        row_fill = DANGER if action == "放弃任务" else INK
        draw.ellipse(
            (mx + 16, cursor + 6, mx + 21, cursor + 11),
            fill=(111, 36, 26, 255) if action == "放弃任务" else BRASS,
        )
        draw.text(
            (mx + 28, cursor + 3),
            action,
            font=fonts["menu"],
            fill=row_fill,
        )
        cursor += 25

    # Broad fold lines visually carry the menu back into the narrow seal tag.
    draw.line(
        (mx + mw - 14, my + 91, connector_x - 2, connector_y - 12),
        fill=(111, 73, 38, 175),
        width=1,
    )
    draw.line(
        (mx + mw - 13, my + 132, connector_x, connector_y + 10),
        fill=(225, 193, 129, 135),
        width=1,
    )


def draw_bottom_unfolded_tag_menu(
    layer: Image.Image,
    spec: dict[str, Any],
    origin: tuple[int, int],
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> None:
    """Draw one docket sheet that narrows into a vertical bottom bookmark."""
    ox, oy = origin
    mx, my, mw, mh = spec["layout"]["menu"]
    mx += ox
    my += oy
    connector_x, connector_y = spec["layout"]["menu_connection_point"]
    connector_x += ox
    connector_y += oy
    draw = ImageDraw.Draw(layer, "RGBA")

    sheet = [
        (mx + 8, my + 4),
        (mx + mw - 12, my),
        (mx + mw - 5, my + 11),
        (mx + mw - 8, my + mh - 12),
        (connector_x + 13, connector_y + 18),
        (connector_x - 12, connector_y + 18),
        (mx + 17, my + mh - 5),
        (mx + 4, my + mh - 13),
    ]
    draw.polygon(
        [(x + 3, y + 4) for x, y in sheet],
        fill=(29, 16, 11, 175),
    )
    draw.polygon(sheet, fill=PAPER, outline=PAPER_DARK)

    header = [
        (mx + 12, my + 11),
        (mx + mw - 21, my + 8),
        (mx + mw - 18, my + 39),
        (mx + 13, my + 41),
    ]
    draw.polygon(header, fill=(173, 128, 71, 235))
    draw.line(
        (mx + 15, my + 43, mx + mw - 22, my + 41),
        fill=(102, 67, 33, 180),
        width=1,
    )
    draw.text(
        (mx + (mw - 8) / 2, my + 26),
        "任务事务",
        font=fonts["menu_title"],
        fill=INK,
        anchor="mm",
    )

    actions = spec["content"]["menu_actions"]
    cursor = my + 49
    for index, action in enumerate(actions):
        if index == 2:
            draw.line(
                (mx + 18, cursor - 3, mx + mw - 25, cursor - 3),
                fill=(104, 68, 33, 150),
                width=1,
            )
            draw.text(
                (mx + 18, cursor + 1),
                "地图标记",
                font=fonts["small"],
                fill=INK_MUTED,
            )
            cursor += 18
        if index == len(actions) - 1:
            draw.line(
                (mx + 18, cursor - 3, mx + mw - 25, cursor - 3),
                fill=(104, 68, 33, 150),
                width=1,
            )
            cursor += 3
        row_fill = DANGER if action == "放弃任务" else INK
        draw.ellipse(
            (mx + 17, cursor + 6, mx + 22, cursor + 11),
            fill=(111, 36, 26, 255) if action == "放弃任务" else BRASS,
        )
        draw.text(
            (mx + 29, cursor + 3),
            action,
            font=fonts["menu"],
            fill=row_fill,
        )
        cursor += 25

    # Two long folds converge on the narrow bookmark neck at the page bottom.
    draw.line(
        (
            mx + 22,
            my + mh - 15,
            connector_x - 10,
            connector_y + 14,
        ),
        fill=(112, 74, 38, 160),
        width=1,
    )
    draw.line(
        (
            mx + mw - 16,
            my + mh - 20,
            connector_x + 11,
            connector_y + 13,
        ),
        fill=(225, 193, 129, 135),
        width=1,
    )


def draw_same_page_transaction_mode(
    layer: Image.Image,
    shell: Image.Image,
    spec: dict[str, Any],
    origin: tuple[int, int],
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> None:
    """Replace live detail content on the existing right-page surface."""
    ox, oy = origin
    mx, my, mw, mh = spec["layout"]["menu"]

    # Restore the accepted shell pixels at the exact detail UV. This erases
    # live detail/reward mock content without introducing a second paper,
    # popup card, shadow plane, border or changed book hierarchy.
    page = shell.crop((mx, my, mx + mw, my + mh)).copy()
    layer.alpha_composite(page, (ox + mx, oy + my))

    mx += ox
    my += oy
    draw = ImageDraw.Draw(layer, "RGBA")
    center_x = mx + mw / 2
    draw.text(
        (center_x, my + 18),
        "任务事务",
        font=fonts["detail_title"],
        fill=INK,
        anchor="mm",
    )
    draw.line(
        (mx + 10, my + 34, mx + mw - 12, my + 34),
        fill=(105, 69, 34, 155),
        width=1,
    )
    draw.text(
        (mx + 12, my + 43),
        "当前任务：熔火之心",
        font=fonts["small"],
        fill=INK_MUTED,
    )

    actions = spec["content"]["menu_actions"]
    cursor = my + 66
    for index, action in enumerate(actions):
        if index == 2:
            draw.line(
                (mx + 12, cursor - 5, mx + mw - 14, cursor - 5),
                fill=(104, 68, 33, 130),
                width=1,
            )
            draw.text(
                (mx + 12, cursor + 1),
                "地图标记",
                font=fonts["small"],
                fill=INK_MUTED,
            )
            cursor += 19
        if index == len(actions) - 1:
            draw.line(
                (mx + 12, cursor - 5, mx + mw - 14, cursor - 5),
                fill=(104, 68, 33, 130),
                width=1,
            )
            cursor += 4
        row_fill = DANGER if action == "放弃任务" else INK
        draw.polygon(
            [
                (mx + 15, cursor + 8),
                (mx + 19, cursor + 4),
                (mx + 23, cursor + 8),
                (mx + 19, cursor + 12),
            ],
            fill=(111, 36, 26, 255) if action == "放弃任务" else BRASS,
        )
        draw.text(
            (mx + 31, cursor + 1),
            action,
            font=fonts["menu"],
            fill=row_fill,
        )
        cursor += 27

    draw.line(
        (mx + 12, my + mh - 27, mx + mw - 14, my + mh - 27),
        fill=(104, 68, 33, 115),
        width=1,
    )
    draw.text(
        (center_x, my + mh - 19),
        "再次点击火漆返回任务详情",
        font=fonts["small"],
        fill=INK_MUTED,
        anchor="mm",
    )


def draw_action_menu(
    layer: Image.Image,
    spec: dict[str, Any],
    origin: tuple[int, int],
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> None:
    ox, oy = origin
    mx, my, mw, mh = spec["layout"]["menu"]
    mx += ox
    my += oy
    draw = ImageDraw.Draw(layer, "RGBA")
    draw.polygon(
        [
            (mx + 7, my),
            (mx + mw - 4, my + 2),
            (mx + mw, my + mh - 8),
            (mx + mw - 8, my + mh),
            (mx + 3, my + mh - 3),
            (mx, my + 7),
        ],
        fill=(43, 23, 16, 232),
    )
    draw.polygon(
        [
            (mx + 9, my + 5),
            (mx + mw - 10, my + 6),
            (mx + mw - 6, my + mh - 12),
            (mx + mw - 12, my + mh - 6),
            (mx + 8, my + mh - 8),
            (mx + 5, my + 11),
        ],
        fill=PAPER,
        outline=PAPER_DARK,
        width=2,
    )
    draw.rectangle(
        (mx + 10, my + 8, mx + mw - 12, my + 35),
        fill=LEATHER,
        outline=BRASS,
        width=1,
    )
    draw.text(
        (mx + mw / 2, my + 21),
        "任务事务",
        font=fonts["menu_title"],
        fill=(234, 201, 126, 255),
        anchor="mm",
    )

    actions = spec["content"]["menu_actions"]
    cursor = my + 42
    for index, action in enumerate(actions):
        if index == 2:
            draw.line(
                (mx + 18, cursor - 3, mx + mw - 18, cursor - 3),
                fill=(104, 68, 33, 150),
                width=1,
            )
            draw.text(
                (mx + 18, cursor + 1),
                "地图标记",
                font=fonts["small"],
                fill=INK_MUTED,
            )
            cursor += 18
        if index == len(actions) - 1:
            draw.line(
                (mx + 18, cursor - 3, mx + mw - 18, cursor - 3),
                fill=(104, 68, 33, 150),
                width=1,
            )
            cursor += 3
        row_fill = DANGER if action == "放弃任务" else INK
        draw.ellipse(
            (mx + 17, cursor + 6, mx + 22, cursor + 11),
            fill=(111, 36, 26, 255) if action == "放弃任务" else BRASS,
        )
        draw.text(
            (mx + 29, cursor + 3),
            action,
            font=fonts["menu"],
            fill=row_fill,
        )
        cursor += 25

    # A short parchment tongue visually connects the transient docket to the
    # fixed leather tab. It is intentionally behind the seal hit box.
    sy = oy + spec["layout"]["seal_visual"][1] + 16
    draw.polygon(
        [(mx + mw - 2, sy - 8), (mx + mw + 18, sy), (mx + mw - 2, sy + 8)],
        fill=PAPER_DARK,
        outline=(85, 52, 27, 220),
    )


def draw_quest_log(
    layer: Image.Image,
    root: Path,
    spec: dict[str, Any],
    origin: tuple[int, int],
    fonts: dict[str, ImageFont.FreeTypeFont],
    seal: Image.Image,
    menu_open: bool,
) -> None:
    ox, oy = origin
    support_type = spec.get("support_type", "leather-tab")
    fw, fh = spec["frame"]
    shell = Image.open(resolve(root, spec["inputs"]["quest_log_shell"])).convert(
        "RGBA"
    )
    shell = shell.resize((fw, fh), Image.Resampling.LANCZOS)
    layer.alpha_composite(shell, origin)
    draw = ImageDraw.Draw(layer, "RGBA")

    draw.text(
        (ox + fw / 2, oy + 28),
        "任务日志",
        font=fonts["title"],
        fill=INK,
        anchor="mm",
    )
    draw_outlined_text(
        draw,
        (ox + 304, oy + 50),
        "任务：18 / 20",
        fonts["small"],
        INK,
        anchor="ra",
    )
    draw_outlined_text(
        draw,
        (ox + 145, oy + 50),
        "显示任务等级",
        fonts["small"],
        INK,
    )
    draw.ellipse((ox + 134, oy + 45, ox + 143, oy + 54), outline=INK, width=1)
    draw.text((ox + 546, oy + 48), "简体中文", font=fonts["small"], fill=INK_MUTED)
    draw.text((ox + 599, oy + 48), "在线", font=fonts["small"], fill=INK_MUTED)
    cx, cy, cw, ch = spec["layout"]["close"]
    draw.line((ox + cx + 5, oy + cy + 5, ox + cx + cw - 5, oy + cy + ch - 5), fill=BRASS_LIGHT, width=2)
    draw.line((ox + cx + cw - 5, oy + cy + 5, ox + cx + 5, oy + cy + ch - 5), fill=BRASS_LIGHT, width=2)

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
            draw.ellipse((list_x + 2, y + 5, list_x + 10, y + 13), outline=INK_SOFT, width=1)
            color = INK_SOFT
        draw_outlined_text(
            draw,
            (list_x + 18, y + 2),
            label,
            fonts["row"],
            color,
        )

    dx = ox + 376
    dy = oy + 73
    draw.text((dx, dy), "熔火之心", font=fonts["detail_title"], fill=INK)
    detail_rule_right = (
        ox + 560
        if support_type in (
            "direct-detail-page-seal-bottom-action-rail",
            "direct-detail-page-seal-right-action-list",
            "direct-detail-page-seal-exterior-ledger-tabs",
        )
        else ox + 600
    )
    draw.line((dx, dy + 23, detail_rule_right, dy + 23), fill=(105, 69, 34, 145), width=1)
    lines = [
        ("黑石山深处传来古老而炽热的回声。", False),
        ("与同伴进入熔火之心，查明元素领主", False),
        ("再度苏醒的征兆。", False),
        ("任务目标", True),
        ("· 击败熔火巨人：6 / 8", False),
        ("· 取得远古符文碎片：2 / 4", False),
        ("· 向洛索斯·天痕复命", False),
        ("奖励", True),
        ("你将获得以下奖励：", False),
    ]
    for index, (line, heading) in enumerate(lines):
        face = fonts["heading"] if heading else fonts["body"]
        color = INK if heading else INK_SOFT
        draw.text((dx, dy + 32 + index * 20), line, font=face, fill=color)

    reward_labels = ("远古徽记", "熔火碎片", "公会印记", "金币袋")
    for index, box in enumerate(spec["layout"]["reward_slots"]):
        absolute = [ox + box[0], oy + box[1], box[2], box[3]]
        draw_reward_slot(draw, absolute, reward_labels[index], index, fonts["reward"])

    # The accepted target contains no fixed bottom action row. The book page
    # remains visually quiet until the side seal is invoked.
    draw.text(
        (ox + 335, oy + 431),
        "",
        font=fonts["small"],
        fill=INK_MUTED,
    )
    if support_type == "direct-detail-page-seal-exterior-ledger-tabs":
        if menu_open:
            draw_exterior_ledger_tabs(
                layer,
                shell,
                spec,
                origin,
                fonts,
            )
        draw_direct_page_seal(layer, spec["layout"], origin, seal)
    elif support_type == "direct-detail-page-seal-right-action-list":
        if menu_open:
            draw_right_page_action_list(layer, spec, origin, fonts)
        draw_direct_page_seal(layer, spec["layout"], origin, seal)
    elif support_type == "direct-detail-page-seal-bottom-action-rail":
        if menu_open:
            draw_bottom_action_rail(layer, spec, origin, fonts)
        draw_direct_page_seal(layer, spec["layout"], origin, seal)
    elif support_type == "brass-corner-seal-bottom-action-rail":
        if menu_open:
            draw_bottom_action_rail(layer, spec, origin, fonts)
        draw_brass_corner_seal(layer, spec["layout"], origin, seal)
    elif support_type == "short-bottom-bookmark-same-page-menu":
        if menu_open:
            draw_same_page_transaction_mode(
                layer,
                shell,
                spec,
                origin,
                fonts,
            )
        draw_page_layered_seal_tag(
            layer,
            shell,
            spec["layout"],
            origin,
            seal,
            cover_root=True,
        )
    elif support_type == "bottom-page-layered-parchment-bookmark":
        if menu_open:
            draw_bottom_unfolded_tag_menu(layer, spec, origin, fonts)
        draw_page_layered_seal_tag(
            layer,
            shell,
            spec["layout"],
            origin,
            seal,
            cover_root=not menu_open,
        )
        if menu_open:
            join = offset_polygon(
                spec["layout"]["open_join_erase_line"],
                origin[0],
                origin[1],
            )
            open_draw = ImageDraw.Draw(layer, "RGBA")
            open_draw.line(join, fill=PAPER, width=2)
            fold = offset_polygon(
                spec["layout"]["open_page_fold_line"],
                origin[0],
                origin[1],
            )
            open_draw.line(
                fold,
                fill=(83, 50, 27, 210),
                width=2,
            )
    elif support_type == "page-layered-parchment-seal-tag":
        if menu_open:
            draw_unfolded_tag_menu(layer, spec, origin, fonts)
        draw_page_layered_seal_tag(
            layer,
            shell,
            spec["layout"],
            origin,
            seal,
        )
    elif support_type == "parchment-seal-tag":
        draw_parchment_seal_tag(layer, spec["layout"], origin, seal)
        if menu_open:
            draw_action_menu(layer, spec, origin, fonts)
    else:
        draw_support_tab(layer, spec["layout"], origin, seal)
        if menu_open:
            draw_action_menu(layer, spec, origin, fonts)


def draw_closeup(
    canvas: Image.Image,
    source_origin: tuple[int, int],
    source_box: list[int],
    destination_box: list[int],
    label: str,
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> None:
    sx, sy, sw, sh = source_box
    dx, dy, dw, dh = destination_box
    absolute_source = (
        source_origin[0] + sx,
        source_origin[1] + sy,
        source_origin[0] + sx + sw,
        source_origin[1] + sy + sh,
    )
    crop = canvas.crop(absolute_source).resize(
        (dw, dh),
        Image.Resampling.NEAREST,
    )
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rectangle(
        (dx - 5, dy - 29, dx + dw + 5, dy + dh + 5),
        fill=(26, 20, 17, 230),
        outline=(164, 119, 56, 255),
        width=2,
    )
    canvas.alpha_composite(crop, (dx, dy))
    draw.text(
        (dx + 4, dy - 24),
        label,
        font=fonts["board_body"],
        fill=(238, 202, 128, 255),
    )


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    spec = json.loads(args.spec.read_text(encoding="utf-8"))
    title_path = resolve(root, spec["inputs"]["title_font"])
    body_path = resolve(root, spec["inputs"]["body_font"])
    fonts = {
        "title": font(title_path, 16),
        "detail_title": font(title_path, 15),
        "heading": font(title_path, 11),
        "body": font(body_path, 10),
        "row": font(body_path, 10),
        "small": font(body_path, 9),
        "reward": font(body_path, 8),
        "menu": font(body_path, 11),
        "menu_title": font(title_path, 12),
        "board_title": font(title_path, 20),
        "board_body": font(body_path, 12),
    }
    seal = load_seal(root, spec)
    canvas = Image.new("RGBA", tuple(spec["canvas"]), (37, 28, 22, 255))
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rectangle(
        (0, 0, canvas.width, canvas.height),
        fill=(38, 45, 43, 255),
    )
    draw.rectangle(
        (0, 700, canvas.width, canvas.height),
        fill=(55, 41, 30, 255),
    )
    for x in range(-40, canvas.width + 50, 130):
        draw.polygon(
            [
                (x, 742),
                (x + 110, 720),
                (x + 165, canvas.height),
                (x + 20, canvas.height),
            ],
            fill=(73, 52, 34, 255),
            outline=(39, 28, 21, 255),
        )
    presentation = spec.get("presentation", {})
    draw.text(
        (44, 34),
        presentation.get(
            "title",
            "任务日志火漆承载与事务菜单 · 本地几何预演",
        ),
        font=fonts["board_title"],
        fill=(239, 207, 139, 255),
    )
    draw.text(
        (44, 66),
        presentation.get(
            "subtitle",
            "左：常态，仅保留侧边实体皮签与火漆；右：左键展开后，临时事务笺向书内展开。100% UI 像素，ImageGen 0/0。",
        ),
        font=fonts["board_body"],
        fill=(198, 171, 116, 255),
    )

    left_origin = tuple(presentation.get("left_origin", [35, 150]))
    right_origin = tuple(presentation.get("right_origin", [810, 150]))
    draw_quest_log(canvas, root, spec, left_origin, fonts, seal, False)
    draw_quest_log(canvas, root, spec, right_origin, fonts, seal, True)
    draw.text(
        (left_origin[0], 128),
        presentation.get("left_label", "A · 菜单关闭"),
        font=fonts["board_body"],
        fill=(238, 202, 128, 255),
    )
    draw.text(
        (right_origin[0], 128),
        presentation.get("right_label", "B · 菜单展开"),
        font=fonts["board_body"],
        fill=(238, 202, 128, 255),
    )
    draw.text(
        (44, 665),
        presentation.get(
            "interaction_contract",
            "交互合同：左键开关；点选／点击书外／Esc 关闭；所有动作只代理原 Button，不复制任务逻辑；放弃任务继续走原生确认框。",
        ),
        font=fonts["board_body"],
        fill=(219, 187, 123, 255),
    )
    draw.text(
        (44, 692),
        presentation.get(
            "fail_open_note",
            "迁移完成前 fail-open：只要任一 provider 尚未捕获，旧按钮继续显示；Close、等级、追踪、在线与语言仍保持独立。",
        ),
        font=fonts["board_body"],
        fill=(219, 187, 123, 255),
    )

    closeups = spec.get("closeups")
    if closeups:
        draw_closeup(
            canvas,
            left_origin,
            closeups["closed_source"],
            closeups["closed_destination"],
            closeups.get(
                "closed_label",
                "C · 根部层序放大：真实右页像素覆盖封签",
            ),
            fonts,
        )
        draw_closeup(
            canvas,
            right_origin,
            closeups["open_source"],
            closeups["open_destination"],
            closeups.get(
                "open_label",
                "D · 展开连接放大：同一张事务签连续展开",
            ),
            fonts,
        )
        draw = ImageDraw.Draw(canvas, "RGBA")
        annotation_x, annotation_y = presentation.get(
            "annotation_origin",
            [980, 758],
        )
        draw.text(
            (annotation_x, annotation_y),
            presentation.get("annotation_title", "V3 物理关系检查"),
            font=fonts["title"],
            fill=(238, 202, 128, 255),
        )
        annotations = presentation.get(
            "annotations",
            (
                "① 封签根部消失在真实右页下方",
                "② 羊皮纸横跨书封，但没有固定在书框",
                "③ 火漆直接压在同一张纸的外露末端",
                "④ 展开态没有独立弹窗底板",
                "⑤ 七项事务写在向书内展开的同一张纸上",
            ),
        )
        for index, annotation in enumerate(annotations):
            draw.text(
                (annotation_x, annotation_y + 34 + index * 28),
                annotation,
                font=fonts["board_body"],
                fill=(219, 187, 123, 255),
            )
        draw.text(
            (annotation_x, annotation_y + 196),
            presentation.get(
                "non_authoritative_note",
                "非权威：最终纸纤维、手绘折痕、动画与客户端字体。",
            ),
            font=fonts["small"],
            fill=(170, 145, 100, 255),
        )

    board_path = resolve(root, spec["outputs"]["board"])
    board_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(board_path, "PNG", optimize=False, compress_level=9)

    layout = spec["layout"]
    page_safe = [64, 64, 548, 324]
    seal_box = layout["seal_visual"]
    support_type = spec.get("support_type", "leather-tab")
    if support_type == "direct-detail-page-seal-exterior-ledger-tabs":
        declared_frame = [
            0,
            0,
            spec["frame"][0] + spec["right_outset"],
            spec["frame"][1],
        ]
        support_checks = {
            "seal_reserved_corner_inside_detail_page": contains(
                layout["paper_interaction_surface"],
                layout["seal_reserved_corner"],
            ),
            "seal_hitbox_equals_reserved_corner": (
                layout["seal_hitbox"] == layout["seal_reserved_corner"]
            ),
            "detail_title_avoids_seal": not intersects(
                layout["detail_title_safe"], layout["seal_hitbox"]
            ),
            "exterior_tabs_do_not_occupy_detail_page": not intersects(
                layout["exterior_action_menu"], layout["detail"]
            ),
            "exterior_tabs_begin_at_detail_right_edge": (
                layout["exterior_action_menu"][0]
                == layout["detail"][0] + layout["detail"][2]
            ),
            "exterior_tabs_extend_beyond_base_frame": (
                layout["exterior_action_menu"][0]
                + layout["exterior_action_menu"][2]
                > spec["frame"][0]
            ),
            "exterior_tabs_fit_declared_right_outset": contains(
                declared_frame, layout["exterior_action_menu"]
            ),
            "all_action_slots_inside_exterior_menu": all(
                contains(layout["exterior_action_menu"], box)
                for box in layout["action_slots"]
            ),
            "all_text_safe_boxes_inside_action_slots": all(
                contains(slot, safe)
                for slot, safe in zip(
                    layout["action_slots"],
                    layout["action_text_safe"],
                )
            ),
            "page_edge_mask_inside_shell": contains(
                [0, 0, *spec["frame"]], layout["page_edge_mask"]
            ),
            "page_edge_mask_occludes_every_tab_root": all(
                intersects(layout["page_edge_mask"], box)
                for box in layout["action_slots"]
            ),
            "page_edge_mask_avoids_all_text": all(
                not intersects(layout["page_edge_mask"], box)
                for box in layout["action_text_safe"]
            ),
            "exterior_tabs_avoid_all_reward_slots": all(
                not intersects(layout["exterior_action_menu"], box)
                for box in layout["reward_slots"]
            ),
            "seven_provider_slots": len(layout["action_slots"]) == 7,
        }
        support_non_authoritative = [
            "final ledger-tab leather, vellum labels, brass rivets and state art",
            "runtime page-edge root mask and staggered slide motion",
            "screen-right clamp shift and live provider enabled-state feedback",
        ]
    elif support_type == "direct-detail-page-seal-right-action-list":
        support_checks = {
            "seal_reserved_corner_inside_detail_page": contains(
                layout["paper_interaction_surface"],
                layout["seal_reserved_corner"],
            ),
            "seal_hitbox_equals_reserved_corner": (
                layout["seal_hitbox"] == layout["seal_reserved_corner"]
            ),
            "detail_title_avoids_seal": not intersects(
                layout["detail_title_safe"], layout["seal_hitbox"]
            ),
            "right_action_list_inside_detail_page": contains(
                layout["detail"], layout["right_action_menu"]
            ),
            "right_action_list_begins_below_seal": (
                layout["right_action_menu"][1]
                >= layout["seal_hitbox"][1] + layout["seal_hitbox"][3]
            ),
            "right_action_list_avoids_all_reward_slots": all(
                not intersects(layout["right_action_menu"], box)
                for box in layout["reward_slots"]
            ),
            "all_action_slots_inside_right_list": all(
                contains(layout["right_action_menu"], box)
                for box in layout["action_slots"]
            ),
            "seven_provider_slots": len(layout["action_slots"]) == 7,
        }
        support_non_authoritative = [
            "final wax-to-parchment contact shadow and page-fiber response",
            "right-side ledger-tab state art and open/close motion",
            "client enabled-state feedback and outside-click focus handling",
        ]
    elif support_type == "direct-detail-page-seal-bottom-action-rail":
        support_checks = {
            "seal_reserved_corner_inside_detail_page": contains(
                layout["paper_interaction_surface"],
                layout["seal_reserved_corner"],
            ),
            "seal_hitbox_equals_reserved_corner": (
                layout["seal_hitbox"] == layout["seal_reserved_corner"]
            ),
            "detail_title_avoids_seal": not intersects(
                layout["detail_title_safe"], layout["seal_hitbox"]
            ),
            "detail_body_avoids_seal": not intersects(
                layout["detail_body_safe"], layout["seal_hitbox"]
            ),
            "seal_avoids_all_reward_slots": all(
                not intersects(layout["seal_hitbox"], box)
                for box in layout["reward_slots"]
            ),
            "action_rail_below_dynamic_detail": not intersects(
                layout["action_rail"], layout["detail"]
            ),
            "all_action_slots_inside_rail": all(
                contains(layout["action_rail"], box)
                for box in layout["action_slots"]
            ),
            "seven_provider_slots": len(layout["action_slots"]) == 7,
            "action_rail_avoids_seal_hitbox": not intersects(
                layout["action_rail"], layout["seal_hitbox"]
            ),
        }
        support_non_authoritative = [
            "final wax-to-parchment contact shadow and page-fiber response",
            "bottom action rail open/close motion and final button-state art",
            "client edge clamp and live provider enabled-state feedback",
        ]
    elif support_type == "brass-corner-seal-bottom-action-rail":
        support_checks = {
            "direct_page_has_no_free_40px_square": not has_free_square(
                layout["paper_interaction_surface"],
                layout["detail"],
                layout["seal_hitbox"][2],
            ),
            "seal_socket_inside_existing_brass_corner": contains(
                layout["brass_corner"], layout["seal_socket"]
            ),
            "seal_hitbox_inside_existing_brass_corner": contains(
                layout["brass_corner"], layout["seal_hitbox"]
            ),
            "seal_avoids_dynamic_detail": not intersects(
                layout["seal_hitbox"], layout["detail"]
            ),
            "seal_avoids_all_reward_slots": all(
                not intersects(layout["seal_hitbox"], box)
                for box in layout["reward_slots"]
            ),
            "action_rail_below_dynamic_detail": not intersects(
                layout["action_rail"], layout["detail"]
            ),
            "all_action_slots_inside_rail": all(
                contains(layout["action_rail"], box)
                for box in layout["action_slots"]
            ),
            "seven_provider_slots": len(layout["action_slots"]) == 7,
            "action_rail_avoids_seal_hitbox": not intersects(
                layout["action_rail"], layout["seal_hitbox"]
            ),
        }
        support_non_authoritative = [
            "final brass socket brushwork and wax-to-metal contact shadow",
            "bottom action rail open/close motion and final button-state art",
            "client edge clamp and live provider enabled-state feedback",
        ]
    elif support_type == "short-bottom-bookmark-same-page-menu":
        visible_book_bottom = spec["visible_book_bottom_y"]
        support_checks = {
            "page_lip_source_inside_shell": contains(
                [0, 0, *spec["frame"]], layout["page_lip_source_box"]
            ),
            "page_lip_covers_bookmark_root": contains(
                layout["page_lip_source_box"], layout["tag_root_box"]
            ),
            "page_lip_avoids_all_reward_slots": all(
                not intersects(layout["page_lip_source_box"], box)
                for box in layout["reward_slots"]
            ),
            "bookmark_crosses_visible_book_bottom": (
                layout["document_tag_bbox"][1] < visible_book_bottom
                and layout["document_tag_bbox"][1]
                + layout["document_tag_bbox"][3]
                > visible_book_bottom
            ),
            "bookmark_is_short": layout["document_tag_bbox"][3] <= 80,
            "seal_sits_on_bookmark_terminal": contains(
                layout["tag_head"], layout["seal_visual"]
            ),
            "menu_reuses_exact_detail_page": (
                layout["menu"] == layout["detail"]
            ),
            "menu_connection_intersects_bookmark": intersects(
                layout["menu_connection_box"],
                layout["document_tag_bbox"],
            ),
            "menu_connection_intersects_same_page": intersects(
                layout["menu_connection_box"], layout["menu"]
            ),
            "bookmark_is_one_continuous_polygon": len(
                layout["document_tag_polygon"]
            ) >= 12,
            "bookmark_is_vertical": (
                layout["document_tag_bbox"][3]
                > layout["document_tag_bbox"][2]
            ),
            "bookmark_root_is_below_all_rewards": (
                layout["tag_root_box"][1]
                >= max(
                    box[1] + box[3]
                    for box in layout["reward_slots"]
                )
            ),
            "no_secondary_paper_layer": spec["constraints"][
                "menu_reuses_existing_detail_page_surface"
            ],
        }
        support_non_authoritative = [
            "final short-bookmark fibers, gravity bend and hand-painted folds",
            "runtime shell-UV sampling and lower-page edge mask",
            "same-page transaction-mode transition",
        ]
    elif support_type == "bottom-page-layered-parchment-bookmark":
        support_checks = {
            "page_lip_source_inside_shell": contains(
                [0, 0, *spec["frame"]], layout["page_lip_source_box"]
            ),
            "page_lip_covers_bookmark_root": contains(
                layout["page_lip_source_box"], layout["tag_root_box"]
            ),
            "page_lip_avoids_all_reward_slots": all(
                not intersects(layout["page_lip_source_box"], box)
                for box in layout["reward_slots"]
            ),
            "bookmark_crosses_book_bottom_edge": (
                layout["document_tag_bbox"][1] < spec["frame"][1]
                and layout["document_tag_bbox"][1]
                + layout["document_tag_bbox"][3]
                > spec["frame"][1]
            ),
            "seal_sits_on_bookmark_terminal": contains(
                layout["tag_head"], layout["seal_visual"]
            ),
            "menu_connection_intersects_bookmark": intersects(
                layout["menu_connection_box"],
                layout["document_tag_bbox"],
            ),
            "menu_connection_intersects_sheet": intersects(
                layout["menu_connection_box"], layout["menu"]
            ),
            "bookmark_is_one_continuous_polygon": len(
                layout["document_tag_polygon"]
            ) >= 12,
            "bookmark_is_vertical": (
                layout["document_tag_bbox"][3]
                > layout["document_tag_bbox"][2] * 2
            ),
            "bookmark_root_is_below_detail_content": (
                layout["tag_root_box"][1]
                >= layout["detail_content"][1]
                + layout["detail_content"][3]
                - 20
            ),
            "bookmark_root_is_below_all_rewards": (
                layout["tag_root_box"][1]
                >= max(
                    box[1] + box[3]
                    for box in layout["reward_slots"]
                )
            ),
        }
        support_non_authoritative = [
            "final parchment fibers, gravity bend and hand-painted folds",
            "runtime shell-UV sampling and lower-page edge mask",
        ]
    elif support_type == "page-layered-parchment-seal-tag":
        support_checks = {
            "page_lip_source_inside_shell": contains(
                [0, 0, *spec["frame"]], layout["page_lip_source_box"]
            ),
            "page_lip_covers_tag_root": contains(
                layout["page_lip_source_box"], layout["tag_root_box"]
            ),
            "tag_crosses_book_outer_edge": (
                layout["document_tag_bbox"][0] < spec["frame"][0]
                and layout["document_tag_bbox"][0]
                + layout["document_tag_bbox"][2]
                > spec["frame"][0]
            ),
            "seal_sits_on_tag_terminal": contains(
                layout["tag_head"], layout["seal_visual"]
            ),
            "menu_connection_intersects_tag": intersects(
                layout["menu_connection_box"],
                layout["document_tag_bbox"],
            ),
            "menu_connection_intersects_sheet": intersects(
                layout["menu_connection_box"], layout["menu"]
            ),
            "tag_is_one_continuous_polygon": len(
                layout["document_tag_polygon"]
            ) >= 8,
        }
        support_non_authoritative = [
            "final parchment fibers and hand-painted folds",
            "runtime shell-UV sampling and page-lip edge mask",
        ]
    elif support_type == "parchment-seal-tag":
        support_checks = {
            "tag_root_enters_page_edge": intersects(
                layout["document_tag"], layout["page_exit"]
            ),
            "page_lip_covers_tag_root": intersects(
                layout["page_lip"], layout["document_tag"]
            ),
            "tag_crosses_book_outer_edge": (
                layout["document_tag"][0] < spec["frame"][0]
                and layout["document_tag"][0]
                + layout["document_tag"][2]
                > spec["frame"][0]
            ),
            "seal_sits_on_tag_head": contains(
                layout["tag_head"], layout["seal_visual"]
            ),
        }
        support_non_authoritative = [
            "parchment-tag fibers, page-lip edge and fold microtexture",
        ]
    else:
        support_checks = {
            "support_attaches_to_exterior_rail": intersects(
                layout["support_tab"], layout["exterior_rail"]
            ),
        }
        support_non_authoritative = [
            "support-tab microtexture and stitching",
        ]
    report = {
        "schema": "aeui.quest-log.seal-actions.simulation-report.v1",
        "version": spec["version"],
        "imagegen_calls": "0/0",
        "frame": spec["frame"],
        "objects": {
            "quest_rows": spec["content"]["quest_rows"],
            "reward_slots": spec["content"]["reward_slots"],
            "menu_actions": len(spec["content"]["menu_actions"]),
        },
        "checks": {
            "all_rewards_inside_detail": all(
                contains(layout["detail"], box)
                for box in layout["reward_slots"]
            ),
            (
                "closed_seal_inside_reserved_detail_corner"
                if support_type
                in (
                    "direct-detail-page-seal-bottom-action-rail",
                    "direct-detail-page-seal-right-action-list",
                    "direct-detail-page-seal-exterior-ledger-tabs",
                )
                else "closed_seal_outside_page_safe_area"
            ): (
                contains(layout["seal_reserved_corner"], seal_box)
                if support_type
                in (
                    "direct-detail-page-seal-bottom-action-rail",
                    "direct-detail-page-seal-right-action-list",
                    "direct-detail-page-seal-exterior-ledger-tabs",
                )
                else not intersects(seal_box, page_safe)
            ),
            **support_checks,
            (
                "menu_inside_declared_frame_plus_outset"
                if support_type
                == "direct-detail-page-seal-exterior-ledger-tabs"
                else "menu_inside_base_frame"
            ): contains(
                (
                    [
                        0,
                        0,
                        spec["frame"][0] + spec["right_outset"],
                        spec["frame"][1],
                    ]
                    if support_type
                    == "direct-detail-page-seal-exterior-ledger-tabs"
                    else [0, 0, *spec["frame"]]
                ),
                layout["menu"],
            ),
            "menu_avoids_close_button": not intersects(
                layout["menu"], layout["close"]
            ),
            "seal_hitbox_contains_visual": contains(
                layout["seal_hitbox"], layout["seal_visual"]
            ),
            "bottom_buttons_removed_only_in_target_visual": spec["interaction"]["fail_open"]
                == "keep-original-buttons-visible-until-all-proxies-exist",
        },
        "intentional_overlay": {
            "menu_overlaps_detail_when_open": intersects(
                layout["menu"], layout["detail"]
            ),
            "reason": (
                "same accepted right-page surface temporarily replaces detail content; no secondary art plane"
                if support_type == "short-bottom-bookmark-same-page-menu"
                else (
                    "transient right-side action list; underlying detail remains and the list closes after selection/outside-click/Escape"
                    if support_type
                    == "direct-detail-page-seal-right-action-list"
                    else (
                        "independent ledger tabs outside the page; roots are occluded by the accepted page edge and no detail content is covered"
                        if support_type
                        == "direct-detail-page-seal-exterior-ledger-tabs"
                        else "transient action layer; closes after selection/outside-click/Escape"
                    )
                )
            ),
        },
        "non_authoritative": support_non_authoritative
        + (
            [
                "same-page ink spacing and final interaction feedback",
                "client font rasterization",
                "runtime animation and tooltip",
            ]
            if support_type == "short-bottom-bookmark-same-page-menu"
            else [
                "menu paper edge, seam and final state art",
                "client font rasterization",
                "runtime animation and tooltip",
            ]
        ),
        "board": {
            "path": spec["outputs"]["board"],
            "sha256": sha256(board_path),
        },
    }
    report["status"] = (
        "displayable"
        if all(report["checks"].values())
        else "blocked"
    )
    report_path = resolve(root, spec["outputs"]["report"])
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
