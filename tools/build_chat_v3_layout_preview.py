#!/usr/bin/env python3
"""Build exact-size layout previews for the V3 modular chat artwork.

This is a visual contract check, not a runtime texture exporter.  It proves
that the A/B/C candidates can be assembled at pfUI's 440 x 320 minimum size
without reducing the 380 x 236 message rectangle.
"""

from pathlib import Path
from typing import Iterable, Sequence

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets" / "source" / "chat" / "v3"
FRAME_PATH = SOURCE_DIR / "ChatBookFrame_Master_v3.png"
TABS_PATH = SOURCE_DIR / "ChatTabs_Master_v3.png"
CONTROLS_PATH = SOURCE_DIR / "ChatControls_Master_v3.png"
OUTPUT_DIR = ROOT / "generated" / "chat" / "v3" / "layout-previews"

VIEWPORT = (440, 320)
MESSAGE_RECT = (30, 44, 410, 280)  # 380 x 236

RESAMPLE = Image.Resampling.LANCZOS


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        (
            ROOT
            / "addon"
            / "AzerothExpeditionUI"
            / "Media"
            / "Fonts"
            / (
                "NotoSerifSC-SemiBold.ttf"
                if bold
                else "NotoSansSC-Medium.ttf"
            )
        ),
        Path(r"C:\Windows\Fonts\simhei.ttf") if bold else Path(r"C:\Windows\Fonts\msyh.ttc"),
        Path(r"C:\Windows\Fonts\msyhbd.ttc"),
        Path(r"C:\Windows\Fonts\arial.ttf"),
    ]
    for path in candidates:
        if path.exists():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default()


FONT_CHAT = load_font(12)
FONT_TAB = load_font(14, bold=True)
FONT_STATUS = load_font(11)
FONT_HEADING = load_font(15, bold=True)
FONT_NOTE = load_font(12)


def alpha_composite_at(canvas: Image.Image, sprite: Image.Image, xy: tuple[int, int]) -> None:
    canvas.alpha_composite(sprite, dest=xy)


def nine_slice(
    source: Image.Image,
    source_cuts: tuple[int, int, int, int],
    target_size: tuple[int, int],
    target_borders: tuple[int, int, int, int],
) -> Image.Image:
    """Resize a texture while keeping the four edge reservations controlled."""

    sx1, sy1, sx2, sy2 = source_cuts
    left, top, right, bottom = target_borders
    target_w, target_h = target_size

    source_x = (0, sx1, sx2, source.width)
    source_y = (0, sy1, sy2, source.height)
    target_x = (0, left, target_w - right, target_w)
    target_y = (0, top, target_h - bottom, target_h)

    output = Image.new("RGBA", target_size, (0, 0, 0, 0))
    for row in range(3):
        for col in range(3):
            src_box = (
                source_x[col],
                source_y[row],
                source_x[col + 1],
                source_y[row + 1],
            )
            dst_box = (
                target_x[col],
                target_y[row],
                target_x[col + 1],
                target_y[row + 1],
            )
            dst_w = dst_box[2] - dst_box[0]
            dst_h = dst_box[3] - dst_box[1]
            tile = source.crop(src_box).resize((dst_w, dst_h), RESAMPLE)
            alpha_composite_at(output, tile, (dst_box[0], dst_box[1]))
    return output


def three_slice(
    source: Image.Image,
    target_size: tuple[int, int],
    source_caps: tuple[int, int],
    target_caps: tuple[int, int],
) -> Image.Image:
    """Resize a horizontal control while preserving its illustrated end caps."""

    target_w, target_h = target_size
    source_left, source_right = source_caps
    target_left, target_right = target_caps
    source_x = (0, source_left, source.width - source_right, source.width)
    target_x = (0, target_left, target_w - target_right, target_w)

    output = Image.new("RGBA", target_size, (0, 0, 0, 0))
    for col in range(3):
        tile = source.crop((source_x[col], 0, source_x[col + 1], source.height))
        tile = tile.resize((target_x[col + 1] - target_x[col], target_h), RESAMPLE)
        alpha_composite_at(output, tile, (target_x[col], 0))
    return output


def draw_centered_text(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    text: str,
    font: ImageFont.ImageFont,
    fill: tuple[int, int, int, int],
    shadow: tuple[int, int, int, int] = (0, 0, 0, 220),
) -> None:
    left, top, right, bottom = box
    bounds = draw.textbbox((0, 0), text, font=font, stroke_width=0)
    width = bounds[2] - bounds[0]
    height = bounds[3] - bounds[1]
    x = left + (right - left - width) // 2
    y = top + (bottom - top - height) // 2 - bounds[1]
    draw.text((x + 1, y + 1), text, font=font, fill=shadow)
    draw.text((x, y), text, font=font, fill=fill)


def ellipsize(
    draw: ImageDraw.ImageDraw,
    text: str,
    font: ImageFont.ImageFont,
    max_width: int,
) -> str:
    if draw.textlength(text, font=font) <= max_width:
        return text
    ellipsis = "…"
    trimmed = text
    while trimmed and draw.textlength(trimmed + ellipsis, font=font) > max_width:
        trimmed = trimmed[:-1]
    return trimmed + ellipsis


def draw_chat_lines(canvas: Image.Image) -> None:
    draw = ImageDraw.Draw(canvas)
    lines: Sequence[tuple[str, tuple[int, int, int, int]]] = (
        ("[22:58][说][60][毛仁凤]：邮件已经发出。", (239, 229, 208, 255)),
        ("[22:58][队伍][60][狼猎]：北门集合，准备出发。", (111, 174, 255, 255)),
        ("[22:59][公会][洋葱炼]：在硬核模式中已达到 40 级！", (97, 220, 85, 255)),
        ("[23:01][世界][60][法拉]：来自有史以来最好的赛事消息！", (246, 207, 72, 255)),
        ("[23:01][说][20][鱼人猎手]：有人去哀嚎洞穴吗？", (239, 229, 208, 255)),
        ("[23:02][拾取] 你获得了物品：[陈旧的航海图]", (114, 221, 117, 255)),
        ("[23:03][队伍][57][来辣]：牧师已就位，门口等。", (111, 174, 255, 255)),
        ("[23:04][世界][60][灰烬旅人]：黑石深渊来治疗。", (246, 207, 72, 255)),
        ("[23:05][公会][远征笔记]：今晚八点继续探索。", (97, 220, 85, 255)),
        ("[23:06][说][35][老水手]：暴风城港口见。", (239, 229, 208, 255)),
        ("[23:07][系统] 你的炉石将在 3 分钟后可用。", (255, 208, 64, 255)),
        ("[23:08][队伍][60][薄雾]：任务物品已经拿齐。", (111, 174, 255, 255)),
        ("[23:09][世界][45][荒野客]：寻找一名可靠的向导。", (246, 207, 72, 255)),
        ("[23:10][拾取] 你获得了 2 银 18 铜。", (114, 221, 117, 255)),
        ("[23:11][公会][旧书页]：回城后交任务。", (97, 220, 85, 255)),
        ("[23:12][说][60][暮色]：下一站，荆棘谷。", (239, 229, 208, 255)),
    )
    x = MESSAGE_RECT[0] + 5
    y = MESSAGE_RECT[1] + 2
    max_width = MESSAGE_RECT[2] - x - 5
    for index, (line, color) in enumerate(lines):
        fitted = ellipsize(draw, line, FONT_CHAT, max_width)
        draw.text(
            (x, y + index * 14),
            fitted,
            font=FONT_CHAT,
            fill=color,
            stroke_width=1,
            stroke_fill=(35, 20, 11, 245),
        )


def make_game_backdrop() -> Image.Image:
    canvas = Image.new("RGBA", VIEWPORT, (40, 28, 18, 255))
    draw = ImageDraw.Draw(canvas)
    for y in range(VIEWPORT[1]):
        fraction = y / max(1, VIEWPORT[1] - 1)
        color = (
            int(91 - 34 * fraction),
            int(61 - 27 * fraction),
            int(35 - 16 * fraction),
            255,
        )
        draw.line((0, y, VIEWPORT[0], y), fill=color)
    draw.ellipse((-90, 80, 250, 410), fill=(75, 86, 52, 255))
    draw.polygon(
        ((260, 0), (440, 0), (440, 320), (358, 320), (330, 145)),
        fill=(65, 37, 26, 255),
    )
    return canvas


def crop_tabs(tabs_sheet: Image.Image) -> tuple[Image.Image, list[Image.Image]]:
    shelf = tabs_sheet.crop((39, 196, 1733, 298))
    common_y = (508, 703)
    tab_boxes = (
        (27, common_y[0], 426, common_y[1]),
        (465, common_y[0], 864, common_y[1]),
        (906, common_y[0], 1307, common_y[1]),
        (1345, common_y[0], 1744, common_y[1]),
    )
    return shelf, [tabs_sheet.crop(box) for box in tab_boxes]


def crop_controls(
    controls_sheet: Image.Image,
) -> tuple[Image.Image, Image.Image, Image.Image, Image.Image]:
    return (
        controls_sheet.crop((51, 187, 1437, 363)),
        controls_sheet.crop((51, 448, 1437, 625)),
        controls_sheet.crop((199, 693, 811, 849)),
        controls_sheet.crop((1048, 686, 1160, 864)),
    )


def build_view(
    frame: Image.Image,
    shelf: Image.Image,
    tabs: Sequence[Image.Image],
    controls: tuple[Image.Image, Image.Image, Image.Image, Image.Image],
    input_focus: bool,
) -> Image.Image:
    canvas = make_game_backdrop()

    # Source cuts follow calm, low-detail join zones.  Runtime borders are
    # fixed at 30/28/30/28, leaving the required central 380 x 264 area.
    frame_runtime = nine_slice(
        frame,
        source_cuts=(215, 100, 1485, 860),
        target_size=VIEWPORT,
        target_borders=(30, 28, 30, 28),
    )
    alpha_composite_at(canvas, frame_runtime, (0, 0))

    shelf_runtime = shelf.resize((380, 23), RESAMPLE)
    alpha_composite_at(canvas, shelf_runtime, (30, 25))

    # The selected source is inserted into the first slot; all inactive tabs
    # reuse the normal geometry, proving that the four controls are separate.
    normal_tab = tabs[0].resize((92, 42), RESAMPLE)
    selected_tab = tabs[2].resize((92, 42), RESAMPLE)
    tab_x = (31, 126, 221, 316)
    tab_labels = ("综合", "拾取", "队伍", "个人")
    draw = ImageDraw.Draw(canvas)
    for index, (x, label) in enumerate(zip(tab_x, tab_labels)):
        tab = selected_tab if index == 0 else normal_tab
        alpha_composite_at(canvas, tab, (x, 3))
        draw_centered_text(
            draw,
            (x, 6, x + 92, 39),
            label,
            FONT_TAB,
            (42, 25, 13, 255) if index == 0 else (205, 177, 112, 255),
        )

    draw_chat_lines(canvas)

    input_normal, input_active, status_field, unread_marker = controls
    if input_focus:
        input_strip = three_slice(
            input_active,
            target_size=(380, 25),
            source_caps=(155, 105),
            target_caps=(28, 20),
        )
        alpha_composite_at(canvas, input_strip, (30, 289))
        draw = ImageDraw.Draw(canvas)
        draw.text(
            (59, 294),
            "说：",
            font=FONT_STATUS,
            fill=(62, 35, 17, 255),
        )
        draw.line((82, 295, 82, 307), fill=(65, 36, 17, 255), width=1)
    else:
        status_runtime = three_slice(
            status_field,
            target_size=(122, 22),
            source_caps=(92, 82),
            target_caps=(18, 16),
        )
        status_x = (30, 159, 288)
        status_labels = ("公会：无", "68 (4/72)", "59 帧 · 43 毫秒")
        for x, label in zip(status_x, status_labels):
            alpha_composite_at(canvas, status_runtime, (x, 291))
            draw_centered_text(
                ImageDraw.Draw(canvas),
                (x + 5, 292, x + 117, 312),
                label,
                FONT_STATUS,
                (53, 31, 15, 255),
                shadow=(222, 189, 113, 110),
            )

    unread_runtime = unread_marker.resize((16, 16), RESAMPLE)
    alpha_composite_at(canvas, unread_runtime, (401, 29))
    return canvas


def annotate_safe_area(view: Image.Image) -> Image.Image:
    debug = view.copy()
    draw = ImageDraw.Draw(debug, "RGBA")
    draw.rectangle(MESSAGE_RECT, outline=(38, 236, 226, 255), width=1)
    draw.rectangle((31, 263, 171, 278), fill=(11, 28, 29, 205))
    draw.text(
        (35, 263),
        "正文安全区 380 × 236",
        font=FONT_NOTE,
        fill=(94, 255, 240, 255),
    )
    return debug


def build_contact_sheet(
    left: Image.Image,
    right: Image.Image,
    output_path: Path,
    headings: Iterable[str],
) -> None:
    canvas = Image.new("RGBA", (940, 372), (22, 18, 14, 255))
    draw = ImageDraw.Draw(canvas)
    panel_positions = ((20, 36), (480, 36))
    for image, position, heading in zip((left, right), panel_positions, headings):
        draw.text(
            (position[0], 8),
            heading,
            font=FONT_HEADING,
            fill=(221, 193, 132, 255),
        )
        alpha_composite_at(canvas, image, position)
    draw.text(
        (20, 360),
        "每个内框均为精确 440 × 320 UI px；青线仅用于校验，不属于游戏贴图。",
        font=FONT_NOTE,
        fill=(151, 137, 111, 255),
    )
    canvas.convert("RGB").save(output_path, quality=95)


def main() -> None:
    for path in (FRAME_PATH, TABS_PATH, CONTROLS_PATH):
        if not path.exists():
            raise FileNotFoundError(path)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    frame = Image.open(FRAME_PATH).convert("RGBA")
    tabs_sheet = Image.open(TABS_PATH).convert("RGBA")
    controls_sheet = Image.open(CONTROLS_PATH).convert("RGBA")
    shelf, tabs = crop_tabs(tabs_sheet)
    controls = crop_controls(controls_sheet)

    default_view = build_view(frame, shelf, tabs, controls, input_focus=False)
    input_view = build_view(frame, shelf, tabs, controls, input_focus=True)

    default_path = OUTPUT_DIR / "ChatLayout_Default_440x320_v3.png"
    input_path = OUTPUT_DIR / "ChatLayout_Input_440x320_v3.png"
    clean_path = OUTPUT_DIR / "ChatLayout_Combined_Clean_v3.png"
    debug_path = OUTPUT_DIR / "ChatLayout_Combined_Debug_v3.png"

    default_view.convert("RGB").save(default_path, quality=95)
    input_view.convert("RGB").save(input_path, quality=95)
    build_contact_sheet(
        default_view,
        input_view,
        clean_path,
        ("默认状态：独立 Tab + 三个复用底栏字段", "输入状态：同一框架 + 聚焦输入纸带"),
    )
    build_contact_sheet(
        annotate_safe_area(default_view),
        annotate_safe_area(input_view),
        debug_path,
        ("默认状态 / 正文容量校验", "输入状态 / 正文容量校验"),
    )

    print(default_path)
    print(input_path)
    print(clean_path)
    print(debug_path)


if __name__ == "__main__":
    main()
