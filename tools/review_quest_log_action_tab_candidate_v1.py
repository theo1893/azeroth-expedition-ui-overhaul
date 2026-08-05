#!/usr/bin/env python3
"""Review one QS-B1 tab candidate in exact Quest Log runtime geometry.

The script performs only the deterministic operations authorized by the QS-B1
contract: edge-connected chroma keying, transparent-RGB cleanup, proportional
bbox fitting, temporary state derivation, and 100% UI-pixel assembly.  It never
promotes a candidate to source or writes addon runtime media.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import sys
from pathlib import Path
from typing import Any, Callable

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFont


ROOT = Path(__file__).resolve().parents[1]
CANVAS = (1024, 1024)
TARGET_BOX = (120, 442, 904, 582)
TARGET_SIZE = (784, 140)
RUNTIME_SIZE = (112, 20)
CELL_SIZE = (128, 32)
ATLAS_SIZE = (1024, 32)
CELL_INSET = (8, 6)
GREEN = np.array((0, 255, 0), dtype=np.uint8)
RESAMPLE = Image.Resampling.LANCZOS
STATE_NAMES = (
    "standard-normal",
    "standard-hover",
    "standard-pressed",
    "standard-disabled",
    "danger-normal",
    "danger-hover",
    "danger-pressed",
    "danger-disabled",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("raw", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--repo-root", type=Path, default=ROOT)
    parser.add_argument("--repo-commit", required=True)
    parser.add_argument("--session-id", required=True)
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def display(root: Path, path: Path) -> str:
    resolved = path.resolve()
    try:
        return resolved.relative_to(root).as_posix()
    except ValueError:
        return str(resolved)


def alpha_bbox(image: Image.Image, threshold: int = 0) -> tuple[int, int, int, int] | None:
    alpha = np.asarray(image.getchannel("A"))
    ys, xs = np.where(alpha > threshold)
    if not len(xs):
        return None
    return int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def clear_edge_connected_green(image: Image.Image) -> tuple[Image.Image, int]:
    """Clear only visible green spill connected to existing transparency."""
    rgba = np.asarray(image.convert("RGBA")).copy()
    r = rgba[:, :, 0].astype(np.int16)
    g = rgba[:, :, 1].astype(np.int16)
    b = rgba[:, :, 2].astype(np.int16)
    visible = rgba[:, :, 3] > 0
    greenish = visible & (g - np.maximum(r, b) >= 10) & (g - b >= 5)
    transparent = rgba[:, :, 3] == 0
    passable = transparent | greenish | (visible & (rgba[:, :, 3] < 255))
    flood = Image.fromarray(
        np.where(passable, 0, 255).astype(np.uint8), "L"
    ).copy()
    width, height = image.size
    for seed in (
        (0, 0),
        (width - 1, 0),
        (0, height - 1),
        (width - 1, height - 1),
        (width // 2, 0),
        (width // 2, height - 1),
        (0, height // 2),
        (width - 1, height // 2),
    ):
        if flood.getpixel(seed) == 0:
            ImageDraw.floodfill(flood, seed, 128, thresh=0)
    connected = np.asarray(flood) == 128
    remove = connected & greenish
    rgba[remove, 3] = 0
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA"), int(remove.sum())


def edge_connected_chroma_key(raw: Image.Image) -> tuple[Image.Image, dict[str, Any]]:
    """Remove only green-classified pixels connected to the canvas boundary."""
    rgb = np.asarray(raw.convert("RGB"), dtype=np.uint8)
    r = rgb[:, :, 0].astype(np.int16)
    g = rgb[:, :, 1].astype(np.int16)
    b = rgb[:, :, 2].astype(np.int16)
    green_score = g - np.maximum(r, b)
    greenish = (g >= 90) & (green_score >= 24) & ((g - b) >= 14)

    # Pillow's exact binary flood fill gives a deterministic edge-connected
    # component without allowing isolated green pixels inside the object to be
    # deleted.  The generated background is connected through every corner.
    flood = Image.fromarray(
        np.where(greenish, 0, 255).astype(np.uint8), "L"
    ).copy()
    flood_draw = ImageDraw.Draw(flood)
    width, height = raw.size
    boundary_seeds = (
        (0, 0),
        (width - 1, 0),
        (0, height - 1),
        (width - 1, height - 1),
        (width // 2, 0),
        (width // 2, height - 1),
        (0, height // 2),
        (width - 1, height // 2),
    )
    for seed in boundary_seeds:
        if flood.getpixel(seed) == 0:
            ImageDraw.floodfill(flood, seed, 128, thresh=0)
    connected = np.asarray(flood) == 128

    alpha = np.full((height, width), 255, dtype=np.uint8)
    alpha[connected] = 0
    rgba = np.dstack((rgb.copy(), alpha))
    rgba[alpha == 0, :3] = 0
    keyed = Image.fromarray(rgba, "RGBA")
    background = rgb[connected]
    exact = np.all(rgb == GREEN, axis=2)
    bbox = alpha_bbox(keyed)
    unique = len(np.unique(background, axis=0)) if len(background) else 0
    metrics: dict[str, Any] = {
        "raw_size": list(raw.size),
        "raw_mode": raw.mode,
        "edge_connected_background_pixels": int(connected.sum()),
        "background_unique_rgb": int(unique),
        "background_exact_00ff00_pixels": int(exact[connected].sum()),
        "background_exact_00ff00_ratio": (
            float(exact[connected].mean()) if int(connected.sum()) else 0.0
        ),
        "raw_visible_bbox_exclusive": list(bbox or ()),
        "raw_visible_size": (
            [bbox[2] - bbox[0], bbox[3] - bbox[1]] if bbox else [0, 0]
        ),
        "transparent_pixels": int((alpha == 0).sum()),
        "opaque_pixels": int((alpha == 255).sum()),
    }
    return keyed, metrics


def fit_bbox(keyed: Image.Image) -> tuple[Image.Image, dict[str, Any]]:
    bbox = alpha_bbox(keyed)
    if bbox is None:
        raise ValueError("candidate contains no visible object after chroma key")
    crop = clear_transparent_rgb(keyed.crop(bbox))
    ratio = min(TARGET_SIZE[0] / crop.width, TARGET_SIZE[1] / crop.height)
    resized_size = (
        max(1, round(crop.width * ratio)),
        max(1, round(crop.height * ratio)),
    )
    resized = clear_transparent_rgb(crop.resize(resized_size, RESAMPLE))
    output = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
    target_center = (
        (TARGET_BOX[0] + TARGET_BOX[2]) // 2,
        (TARGET_BOX[1] + TARGET_BOX[3]) // 2,
    )
    paste = (
        target_center[0] - resized.width // 2,
        target_center[1] - resized.height // 2,
    )
    output.alpha_composite(resized, paste)
    output = clear_transparent_rgb(output)
    output, cleared_spill = clear_edge_connected_green(output)
    normalized_bbox = alpha_bbox(output)
    return output, {
        "raw_bbox_exclusive": list(bbox),
        "raw_aspect": crop.width / crop.height,
        "scale": ratio,
        "normalized_visible_size": list(resized_size),
        "normalized_bbox_exclusive": list(normalized_bbox or ()),
        "target_bbox_exclusive": list(TARGET_BOX),
        "edge_connected_green_pixels_cleared_after_resize": cleared_spill,
    }


def visible_green_metrics(image: Image.Image) -> dict[str, int]:
    rgba = np.asarray(image.convert("RGBA"))
    visible = rgba[:, :, 3] > 0
    rgb = rgba[:, :, :3]
    exact = np.all(rgb == GREEN, axis=2) & visible
    dominant = (
        (rgb[:, :, 1].astype(np.int16) - np.maximum(
            rgb[:, :, 0].astype(np.int16), rgb[:, :, 2].astype(np.int16)
        ) >= 45)
        & visible
    )
    return {
        "exact_00ff00": int(exact.sum()),
        "heuristic_green_dominant": int(dominant.sum()),
    }


def build_runtime_base(normalized: Image.Image) -> Image.Image:
    bbox = alpha_bbox(normalized)
    if bbox is None:
        raise ValueError("normalized candidate contains no visible pixels")
    crop = clear_transparent_rgb(normalized.crop(bbox))
    ratio = min(RUNTIME_SIZE[0] / crop.width, RUNTIME_SIZE[1] / crop.height)
    size = (max(1, round(crop.width * ratio)), max(1, round(crop.height * ratio)))
    resized = clear_transparent_rgb(crop.resize(size, RESAMPLE))
    output = Image.new("RGBA", RUNTIME_SIZE, (0, 0, 0, 0))
    output.alpha_composite(
        resized,
        ((RUNTIME_SIZE[0] - size[0]) // 2, (RUNTIME_SIZE[1] - size[1]) // 2),
    )
    output = clear_transparent_rgb(output)
    output, _ = clear_edge_connected_green(output)
    return output


def recolor_danger_edge(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    alpha = rgba[:, :, 3]
    width = rgba.shape[1]
    x_grid = np.broadcast_to(np.arange(width), alpha.shape)
    outer_band = (alpha > 0) & (x_grid >= width - 8)
    rgba[outer_band, 0] = np.maximum(rgba[outer_band, 0], 78)
    rgba[outer_band, 1] = (rgba[outer_band, 1].astype(np.uint16) * 3 // 5).astype(np.uint8)
    rgba[outer_band, 2] = (rgba[outer_band, 2].astype(np.uint16) * 3 // 5).astype(np.uint8)
    return Image.fromarray(rgba, "RGBA")


def state_image(base: Image.Image, state: str) -> Image.Image:
    danger = state.startswith("danger-")
    suffix = state.split("-", 1)[1]
    image = recolor_danger_edge(base) if danger else base.copy()
    if suffix == "hover":
        image = ImageEnhance.Brightness(image).enhance(1.08)
        rgba = np.asarray(image).copy()
        visible = rgba[:, :, 3] > 0
        rgba[visible, 0] = np.minimum(255, rgba[visible, 0].astype(np.uint16) + 6).astype(np.uint8)
        image = Image.fromarray(rgba, "RGBA")
    elif suffix == "pressed":
        image = ImageEnhance.Brightness(image).enhance(0.82)
    elif suffix == "disabled":
        image = ImageEnhance.Color(image).enhance(0.25)
        image = ImageEnhance.Brightness(image).enhance(0.76)
    return clear_transparent_rgb(image)


def build_state_atlas(base: Image.Image) -> tuple[Image.Image, dict[str, Image.Image]]:
    atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
    states: dict[str, Image.Image] = {}
    for index, state in enumerate(STATE_NAMES):
        sprite = state_image(base, state)
        states[state] = sprite
        atlas.alpha_composite(
            sprite,
            (index * CELL_SIZE[0] + CELL_INSET[0], CELL_INSET[1]),
        )
    return clear_transparent_rgb(atlas), states


def load_renderer(root: Path) -> Any:
    path = root / "tools" / "render_quest_log_seal_actions_simulation_v1.py"
    spec = importlib.util.spec_from_file_location("aeui_qs_b1_candidate_renderer", path)
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def install_candidate_tabs(
    renderer: Any,
    states: dict[str, Image.Image],
) -> Callable[..., None]:
    sequence = (
        "standard-normal",
        "standard-hover",
        "standard-pressed",
        "standard-disabled",
        "standard-normal",
        "standard-hover",
        "danger-normal",
    )

    def draw_tabs(
        layer: Image.Image,
        shell: Image.Image,
        spec: dict[str, Any],
        origin: tuple[int, int],
        fonts: dict[str, ImageFont.FreeTypeFont],
    ) -> None:
        ox, oy = origin
        draw = ImageDraw.Draw(layer, "RGBA")
        labels = spec["content"]["menu_actions"]
        for index, (slot, text_box, state) in enumerate(
            zip(
                spec["layout"]["action_slots"],
                spec["layout"]["action_text_safe"],
                sequence,
                strict=True,
            )
        ):
            x, y, width, height = slot
            sprite = states[state]
            layer.alpha_composite(sprite, (ox + x, oy + y))
            tx, ty, tw, th = text_box
            offset = 1 if state.endswith("pressed") else 0
            if state.endswith("disabled"):
                color = (120, 105, 83, 255)
            elif state.startswith("danger"):
                color = (191, 137, 116, 255)
            else:
                color = (214, 185, 128, 255)
            draw.text(
                (ox + tx + tw / 2 + offset, oy + ty + th / 2 + offset),
                labels[index],
                font=fonts["small"],
                fill=color,
                anchor="mm",
            )

        mx, my, mw, mh = spec["layout"]["page_edge_mask"]
        edge = shell.crop((mx, my, mx + mw, my + mh))
        layer.alpha_composite(edge, (ox + mx, oy + my))

    renderer.draw_exterior_ledger_tabs = draw_tabs
    return draw_tabs


def render_layouts(
    root: Path,
    output_dir: Path,
    attempt: str,
    states: dict[str, Image.Image],
) -> tuple[Path, Path, Path, dict[str, Any]]:
    renderer = load_renderer(root)
    install_candidate_tabs(renderer, states)
    source_spec = root / "tools/specs/quest_log_seal_actions_simulation_v9.json"
    spec = json.loads(source_spec.read_text(encoding="utf-8"))
    board_path = output_dir / f"{attempt}.real-layout.png"
    report_path = output_dir / f"{attempt}.layout-report.json"
    spec_path = output_dir / f"{attempt}.review-spec.json"
    spec["version"] = f"{attempt}-candidate-review"
    spec["outputs"] = {
        "board": display(root, board_path),
        "report": display(root, report_path),
    }
    spec["presentation"]["title"] = f"QS-B1 候选真实排版 · {attempt}"
    spec["presentation"]["subtitle"] = (
        "当前候选经确定性色键与等比 bbox-fit 后，按 112×20px、七个真实标签、"
        "18 行任务与四个奖励槽进行 100% UI 像素装配。"
    )
    spec["presentation"]["non_authoritative_note"] = (
        "非权威仅限 Turtle WoW 最终字体栅格、Tooltip 与真实点击反馈；候选皮革像素为本次审查对象。"
    )
    spec_path.write_text(json.dumps(spec, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    previous_argv = sys.argv
    try:
        sys.argv = [
            str(root / "tools/render_quest_log_seal_actions_simulation_v1.py"),
            str(spec_path),
            "--repo-root",
            str(root),
        ]
        renderer.main()
    finally:
        sys.argv = previous_argv

    # Exact open width is 676 + 48 = 724.  Positioning it at x=292 places the
    # rightmost visible tab at screenRight-8 on a 1024 px test screen.
    clamp_path = output_dir / f"{attempt}.right-clamp.png"
    clamp = Image.new("RGBA", (1024, 600), (45, 53, 50, 255))
    clamp_draw = ImageDraw.Draw(clamp, "RGBA")
    clamp_draw.rectangle((0, 430, 1024, 600), fill=(70, 51, 34, 255))
    for x in range(0, 1024, 96):
        clamp_draw.line((x, 430, x + 70, 600), fill=(95, 70, 45, 255), width=2)
    title_path = root / spec["inputs"]["title_font"]
    body_path = root / spec["inputs"]["body_font"]
    fonts = {
        "title": renderer.font(title_path, 16),
        "detail_title": renderer.font(title_path, 15),
        "heading": renderer.font(title_path, 11),
        "body": renderer.font(body_path, 10),
        "row": renderer.font(body_path, 10),
        "small": renderer.font(body_path, 9),
        "reward": renderer.font(body_path, 8),
        "menu": renderer.font(body_path, 11),
        "menu_title": renderer.font(title_path, 12),
        "board_title": renderer.font(title_path, 20),
        "board_body": renderer.font(body_path, 12),
    }
    seal = renderer.load_seal(root, spec)
    origin = (1024 - 8 - (spec["frame"][0] + spec["right_outset"]), 68)
    renderer.draw_quest_log(clamp, root, spec, origin, fonts, seal, True)
    clamp_draw = ImageDraw.Draw(clamp, "RGBA")
    clamp_draw.line((1016, 0, 1016, 600), fill=(240, 196, 88, 255), width=1)
    clamp_draw.text((20, 18), "1024px 屏幕 · 展开态右缘 8px clamp", font=fonts["board_body"], fill=(238, 205, 137, 255))
    clamp.save(clamp_path, "PNG", optimize=False, compress_level=9)
    layout_report = json.loads(report_path.read_text(encoding="utf-8"))
    return board_path, clamp_path, report_path, layout_report


def checker(size: tuple[int, int], block: int = 16) -> Image.Image:
    image = Image.new("RGBA", size, (54, 48, 42, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], block):
        for x in range(0, size[0], block):
            if ((x // block) + (y // block)) % 2:
                draw.rectangle((x, y, x + block - 1, y + block - 1), fill=(82, 73, 64, 255))
    return image


def render_contact_sheet(
    root: Path,
    raw: Image.Image,
    normalized: Image.Image,
    base: Image.Image,
    atlas: Image.Image,
    output: Path,
    attempt: str,
    source_checks: dict[str, Any],
) -> None:
    sheet = Image.new("RGBA", (1536, 900), (34, 27, 22, 255))
    draw = ImageDraw.Draw(sheet, "RGBA")
    title_font = ImageFont.truetype(str(root / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"), 22)
    body_font = ImageFont.truetype(str(root / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"), 16)
    draw.text((30, 24), f"QS-B1 候选审查 · {attempt}", font=title_font, fill=(238, 204, 137, 255))

    raw_preview = raw.copy().convert("RGBA")
    raw_preview.thumbnail((450, 450), RESAMPLE)
    sheet.alpha_composite(raw_preview, (30, 78))
    draw.text((30, 544), "原始输出", font=body_font, fill=(215, 183, 124, 255))

    transparent = checker((450, 450))
    bbox = alpha_bbox(normalized)
    if bbox:
        crop = normalized.crop(bbox)
        crop.thumbnail((410, 410), RESAMPLE)
        transparent.alpha_composite(crop, ((450 - crop.width) // 2, (450 - crop.height) // 2))
    sheet.alpha_composite(transparent, (510, 78))
    draw.text((510, 544), "边缘连通色键＋等比 bbox-fit", font=body_font, fill=(215, 183, 124, 255))

    runtime_panel = Image.new("RGBA", (520, 450), (178, 139, 83, 255))
    runtime_draw = ImageDraw.Draw(runtime_panel, "RGBA")
    runtime_panel.alpha_composite(base, (36, 56))
    zoom = base.resize((448, 80), Image.Resampling.NEAREST)
    runtime_panel.alpha_composite(zoom, (36, 112))
    atlas_zoom = atlas.resize((512, 16), RESAMPLE)
    runtime_panel.alpha_composite(atlas_zoom, (4, 250))
    runtime_draw.rectangle((36, 56, 147, 75), outline=(242, 201, 95, 255), width=1)
    runtime_draw.text((36, 24), "真实 112×20 与 4×最近邻；下方为八态临时 atlas", font=body_font, fill=(70, 42, 24, 255))
    sheet.alpha_composite(runtime_panel, (990, 78))
    draw.text((990, 544), "固定尺寸／状态装配检查", font=body_font, fill=(215, 183, 124, 255))

    failed = [name for name, passed in source_checks.items() if not passed]
    draw.text(
        (30, 620),
        "机器合同：" + ("pass" if not failed else "fail"),
        font=title_font,
        fill=(113, 205, 116, 255) if not failed else (232, 111, 83, 255),
    )
    draw.multiline_text(
        (30, 666),
        "失败项：" + ("、".join(failed) if failed else "无"),
        font=body_font,
        fill=(213, 184, 132, 255),
        spacing=8,
    )
    sheet.save(output, "PNG", optimize=False, compress_level=9)


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    raw_path = args.raw.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    raw = Image.open(raw_path).convert("RGB")
    keyed, key_metrics = edge_connected_chroma_key(raw)
    normalized, normalization = fit_bbox(keyed)
    base = build_runtime_base(normalized)
    atlas, states = build_state_atlas(base)

    keyed_path = output_dir / f"{args.attempt}.transparent.png"
    normalized_path = output_dir / f"{args.attempt}.normalized-review.png"
    atlas_path = output_dir / f"{args.attempt}.temporary-state-atlas.png"
    contact_path = output_dir / f"{args.attempt}.contact-sheet.png"
    metrics_path = output_dir / f"{args.attempt}.metrics.json"
    keyed.save(keyed_path, "PNG", optimize=False, compress_level=9)
    normalized.save(normalized_path, "PNG", optimize=False, compress_level=9)
    atlas.save(atlas_path, "PNG", optimize=False, compress_level=9)

    bbox = alpha_bbox(normalized)
    normalized_rgba = np.asarray(normalized)
    transparent_rgb_zero = bool(np.all(normalized_rgba[normalized_rgba[:, :, 3] == 0, :3] == 0))
    raw_generation_checks = {
        "raw_canvas_exact_1024_square": raw.size == CANVAS,
        "raw_background_uniform_exact_00ff00": (
            key_metrics["background_unique_rgb"] == 1
            and key_metrics["background_exact_00ff00_ratio"] == 1.0
        ),
    }
    deterministic_candidate_checks = {
        "raw_one_horizontal_object": bool(bbox),
        "raw_aspect_within_5_45_to_5_75": 5.45 <= normalization["raw_aspect"] <= 5.75,
        "normalized_canvas_1024_square": normalized.size == CANVAS,
        "normalized_bbox_inside_target": bool(
            bbox
            and bbox[0] >= TARGET_BOX[0]
            and bbox[1] >= TARGET_BOX[1]
            and bbox[2] <= TARGET_BOX[2]
            and bbox[3] <= TARGET_BOX[3]
        ),
        "transparent_rgb_zero": transparent_rgb_zero,
        "normalized_visible_green_zero": all(value == 0 for value in visible_green_metrics(normalized).values()),
        "runtime_sprite_exact_112x20": base.size == RUNTIME_SIZE,
        "temporary_atlas_exact_1024x32": atlas.size == ATLAS_SIZE,
    }

    board_path, clamp_path, layout_report_path, layout_report = render_layouts(
        root, output_dir, args.attempt, states
    )
    deterministic_candidate_checks["layout_geometry_25_of_25"] = all(layout_report["checks"].values())
    source_checks = {**raw_generation_checks, **deterministic_candidate_checks}
    render_contact_sheet(root, raw, normalized, base, atlas, contact_path, args.attempt, source_checks)

    metrics = {
        "schema": "aeui.quest-log.action-tab.candidate-review.v1",
        "attempt": args.attempt,
        "repo_commit": args.repo_commit,
        "session_id": args.session_id,
        "raw": {
            "path": display(root, raw_path),
            "sha256": sha256(raw_path),
        },
        "key_metrics": key_metrics,
        "normalization": normalization,
        "normalized_bbox": list(bbox or ()),
        "runtime_visible_bbox": list(alpha_bbox(base) or ()),
        "normalized_green_spill": visible_green_metrics(normalized),
        "raw_generation_checks": raw_generation_checks,
        "deterministic_candidate_checks": deterministic_candidate_checks,
        "source_checks": source_checks,
        "raw_request_overall": "pass" if all(raw_generation_checks.values()) else "fail",
        "technical_overall": (
            "pass" if all(deterministic_candidate_checks.values()) else "fail"
        ),
        "layout_checks": layout_report["checks"],
        "visual_review": "pending",
        "outputs": {},
    }
    outputs = {
        "transparent": keyed_path,
        "normalized_review": normalized_path,
        "temporary_state_atlas": atlas_path,
        "contact_sheet": contact_path,
        "real_layout": board_path,
        "right_clamp": clamp_path,
        "layout_report": layout_report_path,
    }
    metrics["outputs"] = {
        name: {"path": display(root, path), "sha256": sha256(path)}
        for name, path in outputs.items()
    }
    metrics_path.write_text(json.dumps(metrics, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    for path in (*outputs.values(), metrics_path):
        print(path)


if __name__ == "__main__":
    main()
