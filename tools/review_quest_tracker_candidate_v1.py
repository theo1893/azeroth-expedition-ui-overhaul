#!/usr/bin/env python3
"""Build deterministic transparent candidates and 100% tracker layout previews."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont


CANVAS = (1536, 1024)
B1_ATLAS_SIZE = (1024, 768)
TRACKER_RUNTIME_X = (0, 24, 166, 190)
TRACKER_RUNTIME_Y = (0, 32, 456, 512)
TRACKER_RUNTIME_CAPS = (14, 14, 12, 16)
PROVIDER_FONT_SIZE = 12
PROVIDER_PANEL_HEIGHT = 16
PROVIDER_ENTRY_HEIGHT = math.ceil(PROVIDER_FONT_SIZE * 1.6)
GREEN = np.array([0, 255, 0], dtype=np.uint8)

QUESTS = [
    ("[44] 腐土的公正", ["已杀死废土游荡者: 8/8", "已杀死废土刺客: 6/6", "已杀死废土魔法师: 10/10"], 100, True, True),
    ("[51+] 沉没的神庙", ["使用过的寻水器: 0/1"], 0, False, False),
    ("[45] 南海复仇", ["杀死南海海盗: 0/10", "杀死南海劫掠者: 0/10", "杀死南海巫医: 0/10"], 0, True, False),
    ("[45+] 巨魔调和剂", ["巨魔调和剂: 0/20"], 0, False, False),
    ("[47+] 探水棒", ["探水棒: 0/1"], 0, False, False),
    ("[45] 海盗的帽子", ["南海海盗帽: 0/20"], 0, True, False),
    ("[51] 滑芯石油钻井平台的麻烦", ["杀死活化的油: 0/6"], 0, False, False),
    ("[50] 灌木谷", ["杀死长柄的灌木兽: 0/8", "杀死灌木塑根者: 0/8"], 0, False, False),
    ("[45] 狂风漩涡", ["捕捉之沙: 0/1"], 0, True, False),
    ("[49] 砂槌食人魔", ["杀死砂槌蛮兵: 0/10", "杀死砂槌执行者: 0/10", "杀死砂槌者塔玛洛克: 0/1"], 0, False, True),
]

DATABASE = [
    ("数据库：稀有敌人", [], 0, False, False),
    ("数据库：草药", [], 0, False, False),
    ("数据库：矿脉", [], 0, False, False),
    ("任务给予者", [], 0, False, False),
    ("历史搜索", [], 0, False, False),
    ("地图节点", [], 0, False, False),
]

GIVERS = [
    ("[12] 北郡修道院的委托", [], 0, False, False),
    ("[21] 夜色镇的守夜人", [], 0, False, False),
    ("[31] 南海镇的急件", [], 0, False, False),
    ("[42] 羽月要塞的斥候", [], 0, False, False),
    ("[49] 加基森的远征者", [], 0, False, False),
    ("[55] 东瘟疫之地的档案员", [], 0, False, False),
]

MAXIMUM_ENTRIES = [
    (
        f"[{20 + index}] 远征记录 {index + 1:02d}",
        [],
        0,
        False,
        False,
    )
    for index in range(25)
]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    alpha = np.asarray(image.getchannel("A"))
    ys, xs = np.where(alpha > 0)
    if not len(xs):
        return None
    return int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)


def chroma_key(raw: Image.Image) -> tuple[Image.Image, dict[str, object]]:
    rgb = np.asarray(raw.convert("RGB")).copy()
    source_rgb = rgb.copy()
    r = rgb[:, :, 0].astype(np.int16)
    g = rgb[:, :, 1].astype(np.int16)
    b = rgb[:, :, 2].astype(np.int16)
    green_score = g - np.maximum(r, b)

    alpha = np.clip((45 - green_score) * (255 / 30), 0, 255).astype(np.uint8)
    alpha[green_score >= 45] = 0
    alpha[green_score <= 15] = 255

    # Remove green from partially transparent edge pixels without repainting the object.
    partial = (alpha > 0) & (alpha < 255)
    rgb[:, :, 1][partial] = np.minimum(
        rgb[:, :, 1][partial],
        np.maximum(rgb[:, :, 0][partial], rgb[:, :, 2][partial]),
    )
    rgb[alpha == 0] = 0

    rgba = np.dstack([rgb, alpha])
    candidate = Image.fromarray(rgba, "RGBA")
    classified_background = green_score >= 45
    background_pixels = source_rgb[classified_background]
    exact_green = np.all(source_rgb == GREEN, axis=2)
    metrics: dict[str, object] = {
        "source_size": list(raw.size),
        "source_mode": raw.mode,
        "source_exact_00ff00_pixels": int(exact_green.sum()),
        "source_background_pixels": int(classified_background.sum()),
        "source_background_unique_rgb": int(
            len(np.unique(background_pixels, axis=0)) if len(background_pixels) else 0
        ),
        "transparent_bbox": list(alpha_bbox(candidate) or ()),
        "transparent_pixels": int((alpha == 0).sum()),
        "partial_pixels": int(((alpha > 0) & (alpha < 255)).sum()),
        "opaque_pixels": int((alpha == 255).sum()),
    }
    return candidate, metrics


def resize(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    return image.resize((max(1, size[0]), max(1, size[1])), Image.Resampling.LANCZOS)


def nine_slice(source: Image.Image, size: tuple[int, int]) -> Image.Image:
    bbox = alpha_bbox(source)
    if bbox is None:
        raise ValueError("A1 candidate has no visible paper object")
    src = source.crop(bbox)
    sw, sh = src.size
    sl, sr = min(64, sw // 4), min(64, sw // 4)
    st, sb = min(96, sh // 4), min(128, sh // 4)
    dw, dh = size
    dl = dr = min(16, max(8, dw // 10))
    dt = min(22, max(12, dh // 14))
    db = min(30, max(16, dh // 10))

    out = Image.new("RGBA", size)
    sx = (0, sl, sw - sr, sw)
    sy = (0, st, sh - sb, sh)
    dx = (0, dl, dw - dr, dw)
    dy = (0, dt, dh - db, dh)
    for row in range(3):
        for col in range(3):
            crop = src.crop((sx[col], sy[row], sx[col + 1], sy[row + 1]))
            piece = resize(crop, (dx[col + 1] - dx[col], dy[row + 1] - dy[row]))
            out.alpha_composite(piece, (dx[col], dy[row]))
    return out


def runtime_nine_slice(
    source: Image.Image,
    size: tuple[int, int],
) -> Image.Image:
    width, height = size
    left = min(
        TRACKER_RUNTIME_CAPS[0],
        max(1, (width - 1) // 2),
    )
    right = min(
        TRACKER_RUNTIME_CAPS[1],
        max(1, width - left - 1),
    )
    top = min(
        TRACKER_RUNTIME_CAPS[2],
        max(1, (height - 1) // 2),
    )
    bottom = min(
        TRACKER_RUNTIME_CAPS[3],
        max(1, height - top - 1),
    )
    target_x = (0, left, width - right, width)
    target_y = (0, top, height - bottom, height)
    out = Image.new("RGBA", size)
    for row in range(3):
        for column in range(3):
            crop = source.crop(
                (
                    TRACKER_RUNTIME_X[column],
                    TRACKER_RUNTIME_Y[row],
                    TRACKER_RUNTIME_X[column + 1],
                    TRACKER_RUNTIME_Y[row + 1],
                )
            )
            piece = resize(
                crop,
                (
                    target_x[column + 1] - target_x[column],
                    target_y[row + 1] - target_y[row],
                ),
            )
            out.alpha_composite(
                piece,
                (target_x[column], target_y[row]),
            )
    return out


def three_slice(source: Image.Image, size: tuple[int, int]) -> Image.Image:
    bbox = alpha_bbox(source)
    if bbox is None:
        return Image.new("RGBA", size)
    src = source.crop(bbox)
    sw, sh = src.size
    cap = min(sw // 3, max(1, sw // 6))
    target_cap = min(size[0] // 3, max(2, round(size[1] * 0.8)))
    out = Image.new("RGBA", size)
    left = resize(src.crop((0, 0, cap, sh)), (target_cap, size[1]))
    middle = resize(
        src.crop((cap, 0, sw - cap, sh)),
        (max(1, size[0] - target_cap * 2), size[1]),
    )
    right = resize(src.crop((sw - cap, 0, sw, sh)), (target_cap, size[1]))
    out.alpha_composite(left, (0, 0))
    out.alpha_composite(middle, (target_cap, 0))
    out.alpha_composite(right, (size[0] - target_cap, 0))
    return out


def crop_cell(source: Image.Image, box: tuple[int, int, int, int]) -> Image.Image:
    cell = source.crop(box)
    bbox = alpha_bbox(cell)
    return cell.crop(bbox) if bbox else Image.new("RGBA", (1, 1))


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size=size)


def world_scene(repo: Path) -> Image.Image:
    image = Image.new("RGBA", CANVAS, "#526C68FF")
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle((0, 0, 1536, 520), fill="#547779FF")
    draw.rectangle((0, 520, 1536, 1024), fill="#7D684DFF")
    for x in range(0, 1536, 90):
        draw.rectangle((x, 500, x + 60, 1024), fill="#64503AFF")
        draw.line((x + 5, 500, x + 5, 1024), fill="#907554FF", width=2)
    draw.ellipse((710, 320, 825, 500), fill="#303A35DD")
    draw.rectangle((754, 475, 782, 690), fill="#34362EFF")
    draw.ellipse((1360, 24, 1512, 176), fill="#827350FF", outline="#302319FF", width=8)
    draw.ellipse((1374, 38, 1498, 162), fill="#54786AFF")
    draw.rectangle((480, 938, 1056, 1018), fill="#2A211AFF", outline="#91713AFF", width=4)
    for index in range(12):
        x = 498 + index * 45
        draw.rectangle((x, 953, x + 37, 990), fill="#5A442AFF", outline="#B38A43FF", width=2)
    return image


def toolbar(repo: Path, width: int) -> Image.Image:
    # AEUI hides tracker.backdrop.bg. Only the seven live provider icons remain.
    bar = Image.new("RGBA", (width, PROVIDER_PANEL_HEIGHT), (0, 0, 0, 0))
    names = ("quests", "database", "giver", "search", "clean", "settings", "close")
    positions = [1, 18, 35, width - 66, width - 49, width - 32, width - 15]
    for index, (name, x) in enumerate(zip(names, positions)):
        icon_path = repo / "addon" / "pfQuest" / "img" / f"tracker_{name}.tga"
        icon = resize(Image.open(icon_path).convert("RGBA"), (14, 14))
        if index == 0:
            rgba = np.asarray(icon).copy()
            rgba[:, :, 0] = (rgba[:, :, 0].astype(np.uint16) * 45 // 100).astype(np.uint8)
            rgba[:, :, 1] = np.minimum(255, rgba[:, :, 1].astype(np.uint16) + 80).astype(np.uint8)
            icon = Image.fromarray(rgba, "RGBA")
        bar.alpha_composite(icon, (x, 1))
    return bar


def draw_entries(
    frame: Image.Image,
    repo: Path,
    entries: list[tuple[str, list[str], int, bool, bool]],
    mode: str,
    b1: dict[str, Image.Image] | None,
    paper_only: bool,
) -> None:
    width, height = frame.size
    font_path = repo / "addon" / "AzerothExpeditionUI" / "Media" / "Fonts" / "NotoSansSC-Medium.ttf"
    title_font = font(font_path, PROVIDER_FONT_SIZE)
    objective_font = font(font_path, PROVIDER_FONT_SIZE)
    draw = ImageDraw.Draw(frame, "RGBA")
    node = resize(Image.open(repo / "addon" / "pfQuest" / "img" / "node.tga").convert("RGBA"), (12, 12))
    complete_node = resize(
        Image.open(repo / "addon" / "pfQuest" / "img" / "complete_c.tga").convert("RGBA"),
        (12, 12),
    )
    y = PROVIDER_PANEL_HEIGHT

    for index, (title, objectives, percent, tracked, complete) in enumerate(entries):
        live_objectives = objectives if mode == "QUEST_TRACKING" else []
        entry_height = (
            PROVIDER_ENTRY_HEIGHT
            + PROVIDER_FONT_SIZE * len(live_objectives)
        )
        if index == 1:
            if b1:
                wash = three_slice(b1["focus"], (max(1, width - 8), entry_height))
                frame.alpha_composite(wash, (4, y))
            elif not paper_only:
                draw.rectangle(
                    (2, y, width - 2, y + entry_height),
                    fill=(20, 13, 8, 38),
                )

        frame.alpha_composite(complete_node if complete else node, (2, y + 4))
        title_color = (46, 79, 33, 255) if percent >= 100 else (74, 50, 25, 255)
        if mode != "QUEST_TRACKING":
            title_color = (65, 53, 31, 255)
        title_text = f"{title} ({percent}%)" if mode == "QUEST_TRACKING" else title
        draw.text((16, y + 4), title_text, font=title_font, fill=title_color)

        for objective_index, objective in enumerate(live_objectives, start=1):
            objective_y = y + PROVIDER_FONT_SIZE * objective_index + 6
            color = (54, 83, 36, 255) if percent >= 100 else (65, 48, 31, 255)
            draw.text(
                (20, objective_y),
                f"— {objective}",
                font=objective_font,
                fill=color,
            )

        if b1 and tracked:
            mark = resize(b1["tracked"], (10, max(14, min(22, entry_height - 4))))
            frame.alpha_composite(mark, (max(0, width - 12), y + 1))
        if b1 and complete:
            mark = resize(b1["complete"], (12, 12))
            frame.alpha_composite(mark, (max(0, width - 28), y + 2))
        y += entry_height

    if y != height:
        raise ValueError(
            f"provider layout mismatch: drew to y={y}, frame height is {height}"
        )


def provider_frame_height(
    mode: str,
    entries: list[tuple[str, list[str], int, bool, bool]],
) -> int:
    objective_count = (
        sum(len(entry[1]) for entry in entries)
        if mode == "QUEST_TRACKING"
        else 0
    )
    return (
        PROVIDER_PANEL_HEIGHT
        + len(entries) * PROVIDER_ENTRY_HEIGHT
        + objective_count * PROVIDER_FONT_SIZE
    )


def render_layout(
    repo: Path,
    paper: Image.Image,
    output: Path,
    size: tuple[int, int],
    mode: str,
    entries: list[tuple[str, list[str], int, bool, bool]],
    b1: dict[str, Image.Image] | None,
    paper_only: bool,
    runtime_paper: Image.Image | None,
) -> None:
    scene = world_scene(repo)
    tracker = (
        runtime_nine_slice(runtime_paper, size)
        if runtime_paper is not None
        else nine_slice(paper, size)
    )
    tracker.alpha_composite(toolbar(repo, size[0]), (0, 0))
    draw_entries(tracker, repo, entries, mode, b1, paper_only)
    x = CANVAS[0] - size[0] - 20
    y = 72 if size[1] >= 800 else 112
    scene.alpha_composite(tracker, (x, y))
    draw = ImageDraw.Draw(scene, "RGBA")
    label_font = font(
        repo / "addon" / "AzerothExpeditionUI" / "Media" / "Fonts" / "NotoSansSC-Medium.ttf",
        15,
    )
    draw.rectangle((18, 18, 540, 50), fill=(17, 14, 11, 205))
    draw.text(
        (30, 25),
        f"候选真实排版 · {mode} · tracker {size[0]}×{size[1]} UI px · 100%",
        font=label_font,
        fill=(232, 216, 176, 255),
    )
    output.parent.mkdir(parents=True, exist_ok=True)
    scene.save(output)


def build_overview(paths: list[Path], output: Path) -> None:
    thumbs = [resize(Image.open(path).convert("RGBA"), (768, 512)) for path in paths]
    rows = math.ceil(len(thumbs) / 2)
    board = Image.new("RGBA", (1536, rows * 512), "#201A15FF")
    for index, thumb in enumerate(thumbs):
        board.alpha_composite(thumb, ((index % 2) * 768, (index // 2) * 512))
    board.save(output)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", type=Path, required=True)
    parser.add_argument("--a1", type=Path, required=True)
    parser.add_argument("--b1", type=Path)
    parser.add_argument("--paper-only", action="store_true")
    parser.add_argument("--runtime-paper", type=Path)
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()

    repo = args.repo_root.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    a1_raw = Image.open(args.a1).convert("RGB")
    a1, a1_metrics = chroma_key(a1_raw)
    a1_path = output_dir / "QT-A1.transparent-review.png"
    a1.save(a1_path)

    b1_assets: dict[str, Image.Image] | None = None
    b1_metrics: dict[str, object] | None = None
    b1_path: Path | None = None
    if args.b1:
        b1_provider_raw = Image.open(args.b1).convert("RGB")
        provider_rgb = np.asarray(b1_provider_raw)
        provider_exact_green = int(np.all(provider_rgb == GREEN, axis=2).sum())
        b1_raw = (
            b1_provider_raw
            if b1_provider_raw.size == B1_ATLAS_SIZE
            else resize(b1_provider_raw, B1_ATLAS_SIZE)
        )
        b1, b1_metrics = chroma_key(b1_raw)
        b1_metrics = {
            "provider_source_size": list(b1_provider_raw.size),
            "provider_source_mode": b1_provider_raw.mode,
            "provider_exact_00ff00_pixels": provider_exact_green,
            "review_normalization": (
                "none"
                if b1_provider_raw.size == B1_ATLAS_SIZE
                else f"proportional resize to {B1_ATLAS_SIZE[0]}x{B1_ATLAS_SIZE[1]}"
            ),
            **b1_metrics,
        }
        b1_path = output_dir / "QT-B1.transparent-review.png"
        b1.save(b1_path)
        b1_assets = {
            "focus": crop_cell(b1, (152, 96, 872, 196)),
            "tracked": crop_cell(b1, (192, 440, 384, 632)),
            "complete": crop_cell(b1, (640, 440, 832, 632)),
        }

    runtime_paper: Image.Image | None = None
    if args.runtime_paper:
        runtime_paper = Image.open(args.runtime_paper).convert("RGBA")

    layout_inputs = [
        ("empty", 200, "QUEST_TRACKING", []),
        ("short", 130, "QUEST_TRACKING", QUESTS[:2]),
        ("quest", 230, "QUEST_TRACKING", QUESTS[:6]),
        ("dense", 330, "QUEST_TRACKING", QUESTS),
        ("maximum", 330, "QUEST_TRACKING", MAXIMUM_ENTRIES),
        ("database", 230, "DATABASE_TRACKING", DATABASE),
        ("giver", 230, "GIVER_TRACKING", GIVERS),
    ]
    layouts = []
    for label, width, mode, entries in layout_inputs:
        height = provider_frame_height(mode, entries)
        layouts.append(
            (
                f"real-layout-{label}-{width}x{height}.png",
                (width, height),
                mode,
                entries,
            )
        )
    layout_paths: list[Path] = []
    for filename, size, mode, entries in layouts:
        path = output_dir / filename
        render_layout(
            repo,
            a1,
            path,
            size,
            mode,
            entries,
            b1_assets,
            args.paper_only,
            runtime_paper,
        )
        layout_paths.append(path)

    overview = output_dir / "real-layout-overview.png"
    build_overview(layout_paths, overview)
    report = {
        "schema": "aeui-quest-tracker-candidate-review-v2",
        "a1": {
            **a1_metrics,
            "raw_path": str(args.a1.resolve()),
            "raw_sha256": sha256(args.a1.resolve()),
            "transparent_path": str(a1_path),
            "transparent_sha256": sha256(a1_path),
            "contract_object_box": [276, 96, 748, 1440],
        },
        "b1": (
            {
                **(b1_metrics or {}),
                "raw_path": str(args.b1.resolve()),
                "raw_sha256": sha256(args.b1.resolve()),
                "transparent_path": str(b1_path),
                "transparent_sha256": sha256(b1_path),
            }
            if args.b1 and b1_path
            else None
        ),
        "layouts": [
            {
                "path": str(path),
                "sha256": sha256(path),
                "frame_size": list(layouts[index][1]),
                "mode": layouts[index][2],
                "content_count": len(layouts[index][3]),
                "objective_count": (
                    sum(len(entry[1]) for entry in layouts[index][3])
                    if layouts[index][2] == "QUEST_TRACKING"
                    else 0
                ),
                "qt_a2": "current pfQuest icon fallback / non-authoritative",
            }
            for index, path in enumerate(layout_paths)
        ],
        "overview": {"path": str(overview), "sha256": sha256(overview)},
        "authority": {
            "candidate_pixels": "QT-A1 and optional QT-B1 candidates only",
            "dynamic_content": "representative pfQuest hierarchy at 100% UI pixels",
            "toolbar": "current pfQuest TGA fallback; QT-A2 remains non-authoritative",
            "world_and_neighboring_ui": "deterministic geometric fallback; non-authoritative",
            "entry_feedback": (
                "none; QT-B1 user-paused"
                if args.paper_only
                else "candidate B1 or current provider fallback"
            ),
        },
        "provider_geometry": {
            "source": "addon/pfQuest/tracker.lua",
            "font_size": PROVIDER_FONT_SIZE,
            "panel_height": PROVIDER_PANEL_HEIGHT,
            "entry_height": PROVIDER_ENTRY_HEIGHT,
            "height_formula": (
                "panel_height + entry_count * entry_height + "
                "objective_count * font_size"
            ),
            "superseded_fixed_capacity_previews": [
                [130, 180],
                [230, 500],
                [330, 865],
                [230, 500],
            ],
            "note": (
                "Those fixed heights were not provider instances and are not "
                "valid display-region evidence."
            ),
        },
        "runtime_paper": (
            {
                "path": str(args.runtime_paper.resolve()),
                "sha256": sha256(args.runtime_paper.resolve()),
                "size": list(runtime_paper.size),
                "assembly": "manifest-locked 3x3 atlas slices and display caps",
            }
            if args.runtime_paper and runtime_paper is not None
            else None
        ),
    }
    report_path = output_dir / "review.json"
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
