from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(r"D:\Git\azeroth-expedition-ui-overhaul")
CANDIDATE = (
    ROOT
    / "generated"
    / "quests"
    / "QL-B0"
    / "v2"
    / "inset"
    / "attempt-04"
    / "transparent"
    / "QL-B0-A_V2_r3_attempt-04_transparent.png"
)
OUTPUT = (
    ROOT
    / "generated"
    / "quests"
    / "QL-B0"
    / "v2"
    / "inset"
    / "attempt-04"
    / "previews"
    / "QL-B0-A_V2_r3_attempt-04_bboxfit-art-check_676x464.png"
)
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

FRAME_POSITION = (56, 56)
FRAME_SIZE = (262, 340)
LIST_POSITION = (64, 64)
ROW_SIZE = (224, 18)
ROW_COUNT = 18


def contract_crop(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    alpha = image.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        raise ValueError("Candidate has no visible pixels")
    return image.crop(bbox).resize(size, Image.Resampling.LANCZOS)


def paste_alpha(canvas: Image.Image, image: Image.Image, xy: tuple[int, int]) -> None:
    canvas.alpha_composite(image, xy)


def main() -> None:
    shell_atlas = Image.open(SHELL).convert("RGBA")
    canvas = shell_atlas.crop((0, 0, 676, 464))

    candidate = Image.open(CANDIDATE).convert("RGBA")
    runtime_frame = contract_crop(candidate, FRAME_SIZE)
    paste_alpha(canvas, runtime_frame, FRAME_POSITION)

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

    rows = [
        ("header-expanded", "奥格瑞玛", (54, 38, 25, 255)),
        ("quest", "夺回希利苏斯", (25, 102, 38, 255)),
        ("header-collapsed", "幻影赛道", (54, 38, 25, 255)),
        ("quest", "《加基森时报》：重大新闻", (158, 116, 8, 255)),
        ("header-expanded", "战士", (54, 38, 25, 255)),
        ("quest", "老兵犹塞克", (48, 43, 36, 255)),
        ("quest", "和鲁迦交谈", (48, 43, 36, 255)),
        ("quest-selected", "岛民", (48, 43, 36, 255)),
        ("header-collapsed", "灰谷", (54, 38, 25, 255)),
        ("quest", "失踪的使节", (48, 43, 36, 255)),
        ("quest-tracked", "深渊中的密令", (32, 83, 34, 255)),
        ("quest", "远古石碑的回声", (48, 43, 36, 255)),
        ("header-expanded", "千针石林", (54, 38, 25, 255)),
        ("quest", "风巢双足飞龙", (48, 43, 36, 255)),
        ("quest", "被遗忘的航线", (48, 43, 36, 255)),
        ("quest-tracked", "闪光平原的秘密", (32, 83, 34, 255)),
        ("quest", "商队失踪案", (48, 43, 36, 255)),
        ("quest", "最后的线索", (48, 43, 36, 255)),
    ]

    for index, (kind, label, color) in enumerate(rows):
        x = LIST_POSITION[0]
        y = LIST_POSITION[1] + index * ROW_SIZE[1]
        if kind == "quest-selected":
            paste_alpha(canvas, selected, (x - 12, y + 1))
        if kind == "header-expanded":
            paste_alpha(canvas, expanded, (x, y + 1))
        elif kind == "header-collapsed":
            paste_alpha(canvas, collapsed, (x, y + 1))
        else:
            marker = tracked if kind == "quest-tracked" else untracked
            paste_alpha(canvas, marker, (x + 208, y + 4))
        draw.text(
            (x + 20, y + 1),
            label,
            font=header_font if kind.startswith("header") else row_font,
            fill=color,
            stroke_width=0,
        )

    # Simplified live scrollbar evidence, drawn above the non-interactive inset.
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

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(OUTPUT, format="PNG")
    print(OUTPUT)


if __name__ == "__main__":
    main()
