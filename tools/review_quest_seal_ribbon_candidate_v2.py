#!/usr/bin/env python3
"""Review one QS-B1 V2 ribbon candidate in the accepted Quest Log layout.

The raw provider output is never modified.  This reviewer performs only the
deterministic operations authorized by the QS-B1 V2 contract: edge-connected
green-screen removal, transparent-RGB clearing, proportional bbox fitting,
fixed nine-zone slicing, four-state derivation, and a 100% runtime preview.
All outputs are review intermediates under generated/.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any, Callable

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont


CANVAS = (1024, 1024)
TARGET_BBOX = (448, 164, 576, 860)
TARGET_SIZE = (128, 696)
GREEN = np.array((0, 255, 0), dtype=np.uint8)
RESAMPLE = Image.Resampling.LANCZOS

ZONES: tuple[tuple[str, tuple[int, int, int, int], tuple[int, int]], ...] = (
    ("root", (448, 164, 576, 212), (32, 12)),
    ("action-01", (448, 212, 576, 300), (32, 22)),
    ("action-02", (448, 300, 576, 388), (32, 22)),
    ("action-03", (448, 388, 576, 476), (32, 22)),
    ("action-04", (448, 476, 576, 564), (32, 22)),
    ("action-05", (448, 564, 576, 652), (32, 22)),
    ("action-06", (448, 652, 576, 740), (32, 22)),
    ("action-07", (448, 740, 576, 828), (32, 22)),
    ("tail", (448, 828, 576, 860), (32, 8)),
)

STATE_ORDER = ("normal", "hover", "pressed", "disabled")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("raw", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument(
        "--spec",
        type=Path,
        default=Path("tools/specs/quest_log_seal_actions_simulation_v11.json"),
    )
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--repo-commit", required=True)
    parser.add_argument("--session-id", required=True)
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


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    alpha = np.asarray(image.convert("RGBA"))[:, :, 3]
    ys, xs = np.where(alpha > 0)
    if not len(xs):
        return None
    return int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)


def edge_connected_chroma_key(
    raw: Image.Image,
) -> tuple[Image.Image, dict[str, Any]]:
    """Remove only green-like pixels connected to a canvas edge.

    A broad chroma predicate identifies the provider's green field.  Pillow's
    flood fill then restricts removal to the connected exterior field, so a
    green detail enclosed by the cloth can never be removed merely by color.
    """
    rgb = np.asarray(raw.convert("RGB")).copy()
    red = rgb[:, :, 0].astype(np.int16)
    green = rgb[:, :, 1].astype(np.int16)
    blue = rgb[:, :, 2].astype(np.int16)
    score = green - np.maximum(red, blue)
    chroma = (green >= 95) & (score >= 28)

    # 0 is eligible exterior green; 255 is protected foreground/non-green.
    # copy() detaches the NumPy-backed read-only buffer.  Pillow's floodfill
    # otherwise returns without mutating Image.fromarray() on this runtime.
    flood = Image.fromarray(
        np.where(chroma, 0, 255).astype(np.uint8), "L"
    ).copy()
    flood_pixels = np.asarray(flood)
    seeds: list[tuple[int, int]] = []
    width, height = raw.size
    for x in range(width):
        if flood_pixels[0, x] == 0:
            seeds.append((x, 0))
            break
        if flood_pixels[height - 1, x] == 0:
            seeds.append((x, height - 1))
            break
    for y in range(height):
        if flood_pixels[y, 0] == 0:
            seeds.append((0, y))
            break
        if flood_pixels[y, width - 1] == 0:
            seeds.append((width - 1, y))
            break
    if not seeds:
        raise ValueError("no edge-connected chroma seed found")
    for seed in seeds:
        if flood.getpixel(seed) == 0:
            ImageDraw.floodfill(flood, seed, 128, thresh=0)

    connected = np.asarray(flood) == 128
    alpha = np.where(connected, 0, 255).astype(np.uint8)

    # Despill only the one-pixel foreground ring adjacent to removed exterior.
    connected_mask = Image.fromarray((connected * 255).astype(np.uint8), "L")
    expanded = np.asarray(connected_mask.filter(ImageFilter.MaxFilter(3))) > 0
    edge_ring = expanded & ~connected
    rgb[:, :, 1][edge_ring] = np.minimum(
        rgb[:, :, 1][edge_ring],
        np.maximum(rgb[:, :, 0][edge_ring], rgb[:, :, 2][edge_ring]),
    )
    rgb[alpha == 0] = 0
    keyed = clear_transparent_rgb(Image.fromarray(np.dstack((rgb, alpha)), "RGBA"))

    exterior_pixels = rgb[connected]
    exact_green = np.all(np.asarray(raw.convert("RGB")) == GREEN, axis=2)
    metrics = {
        "source_size": list(raw.size),
        "source_mode": raw.mode,
        "chroma_predicate_pixels": int(chroma.sum()),
        "edge_connected_removed_pixels": int(connected.sum()),
        "source_exact_00ff00_pixels": int(exact_green.sum()),
        "source_exterior_unique_rgb_after_despill": int(
            len(np.unique(exterior_pixels, axis=0)) if len(exterior_pixels) else 0
        ),
        "keyed_visible_bbox_exclusive": list(alpha_bbox(keyed) or ()),
    }
    return keyed, metrics


def proportional_fit(
    keyed: Image.Image,
) -> tuple[Image.Image, dict[str, Any]]:
    bbox = alpha_bbox(keyed)
    if bbox is None:
        raise ValueError("candidate has no visible object after chroma key")
    crop = clear_transparent_rgb(keyed.crop(bbox))
    ratio = min(TARGET_SIZE[0] / crop.width, TARGET_SIZE[1] / crop.height)
    size = (
        max(1, round(crop.width * ratio)),
        max(1, round(crop.height * ratio)),
    )
    resized = clear_transparent_rgb(crop.resize(size, RESAMPLE))
    normalized = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
    paste = (
        TARGET_BBOX[0] + (TARGET_SIZE[0] - size[0]) // 2,
        TARGET_BBOX[1] + (TARGET_SIZE[1] - size[1]) // 2,
    )
    normalized.alpha_composite(resized, paste)
    normalized = clear_transparent_rgb(normalized)
    visible = alpha_bbox(normalized)
    source_ratio = crop.width / crop.height
    target_ratio = TARGET_SIZE[0] / TARGET_SIZE[1]
    return normalized, {
        "raw_visible_bbox_exclusive": list(bbox),
        "raw_visible_size": [crop.width, crop.height],
        "raw_visible_aspect": source_ratio,
        "target_visible_aspect": target_ratio,
        "relative_aspect_error": abs(source_ratio / target_ratio - 1.0),
        "normalization_scale": ratio,
        "normalized_object_size": list(size),
        "normalized_visible_bbox_exclusive": list(visible or ()),
        "target_bbox_exclusive": list(TARGET_BBOX),
    }


def derive_state(image: Image.Image, state: str) -> Image.Image:
    image = clear_transparent_rgb(image)
    if state == "normal":
        return image
    if state == "hover":
        image = ImageEnhance.Brightness(image).enhance(1.11)
        image = ImageEnhance.Color(image).enhance(1.04)
    elif state == "pressed":
        image = ImageEnhance.Brightness(image).enhance(0.82)
    elif state == "disabled":
        image = ImageEnhance.Color(image).enhance(0.26)
        image = ImageEnhance.Brightness(image).enhance(0.76)
        rgba = np.asarray(image.convert("RGBA")).copy()
        rgba[:, :, 3] = (rgba[:, :, 3].astype(np.uint16) * 190 // 255).astype(
            np.uint8
        )
        image = Image.fromarray(rgba, "RGBA")
    else:
        raise ValueError(f"unknown state {state}")
    return clear_transparent_rgb(image)


def slice_and_derive(
    normalized: Image.Image,
) -> tuple[dict[str, dict[str, Image.Image]], list[dict[str, Any]]]:
    sprites: dict[str, dict[str, Image.Image]] = {}
    metrics: list[dict[str, Any]] = []
    normalized_array = np.asarray(normalized.convert("RGBA"))
    normalized_rgb = normalized_array[:, :, :3].astype(np.float32)
    normalized_luma = (
        0.2126 * normalized_rgb[:, :, 0]
        + 0.7152 * normalized_rgb[:, :, 1]
        + 0.0722 * normalized_rgb[:, :, 2]
    )
    # A small morphological opening removes isolated dark weave flecks while
    # retaining the broad heraldic strokes.  This is diagnostic only; it never
    # changes candidate pixels or the exported review sprites.
    dark_mask = (
        (normalized_array[:, :, 3] > 128) & (normalized_luma < 70)
    ).astype(np.uint8) * 255
    broad_dark = np.asarray(
        Image.fromarray(dark_mask, "L")
        .filter(ImageFilter.MinFilter(3))
        .filter(ImageFilter.MaxFilter(3))
    ) > 0
    for name, box, runtime_size in ZONES:
        zone = clear_transparent_rgb(normalized.crop(box))
        alpha = np.asarray(zone)[:, :, 3]
        source_coverage = float((alpha > 0).mean())
        top_coverage = float((alpha[0] > 0).mean())
        bottom_coverage = float((alpha[-1] > 0).mean())
        normal = clear_transparent_rgb(zone.resize(runtime_size, RESAMPLE))
        sprites[name] = {
            state: derive_state(normal, state) for state in STATE_ORDER
        }
        runtime_alpha = np.asarray(normal)[:, :, 3]
        item: dict[str, Any] = {
            "name": name,
            "source_box_exclusive": list(box),
            "runtime_size": list(runtime_size),
            "source_alpha_coverage": source_coverage,
            "source_top_edge_coverage": top_coverage,
            "source_bottom_edge_coverage": bottom_coverage,
            "runtime_visible_pixels": int((runtime_alpha > 0).sum()),
        }
        if name.startswith("action-"):
            x0, y0, x1, y1 = box
            ink = broad_dark[y0:y1, x0:x1].copy()
            ink[:, :16] = False
            ink[:, 112:] = False
            ys, xs = np.where(ink)
            total = int(ink.sum())
            outside = int(ink[:12].sum() + ink[76:].sum())
            item.update(
                {
                    "diagnostic_broad_ink_bbox_relative": (
                        [
                            int(xs.min()),
                            int(ys.min()),
                            int(xs.max() + 1),
                            int(ys.max() + 1),
                        ]
                        if len(xs)
                        else []
                    ),
                    "diagnostic_broad_ink_pixels": total,
                    "diagnostic_broad_ink_outside_vertical_safe_pixels": outside,
                    "diagnostic_broad_ink_outside_vertical_safe_ratio": (
                        outside / total if total else 1.0
                    ),
                }
            )
        metrics.append(item)
    return sprites, metrics


def build_atlas(
    sprites: dict[str, dict[str, Image.Image]], output: Path
) -> None:
    height = sum(runtime_size[1] for _, _, runtime_size in ZONES)
    atlas = Image.new("RGBA", (32 * len(STATE_ORDER), height), (0, 0, 0, 0))
    for state_index, state in enumerate(STATE_ORDER):
        y = 0
        for name, _, runtime_size in ZONES:
            atlas.alpha_composite(sprites[name][state], (state_index * 32, y))
            y += runtime_size[1]
    clear_transparent_rgb(atlas).save(output, "PNG")


def load_simulation_module(root: Path) -> Any:
    path = root / "tools" / "render_quest_log_seal_ribbon_simulation_v1.py"
    spec = importlib.util.spec_from_file_location("aeui_qs_b1_v2_review_sim", path)
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def install_candidate_art(
    module: Any, sprites: dict[str, dict[str, Image.Image]]
) -> Callable[[str], None]:
    active = {"panel": "closed-top"}

    def select_state(index: int | None = None) -> str:
        if active["panel"] == "open-top" and index is not None:
            return ("normal", "hover", "pressed", "disabled")[index % 4]
        return "normal"

    def composite(draw: ImageDraw.ImageDraw, image: Image.Image, box: list[int]) -> None:
        x, y, width, height = box
        if image.size != (width, height):
            image = clear_transparent_rgb(image.resize((width, height), RESAMPLE))
        draw._image.alpha_composite(image, (x, y))

    def draw_root(draw: ImageDraw.ImageDraw, box: list[int]) -> None:
        composite(draw, sprites["root"]["normal"], box)

    def draw_segment(draw: ImageDraw.ImageDraw, box: list[int], index: int) -> None:
        composite(draw, sprites[f"action-{index + 1:02d}"][select_state(index)], box)

    def draw_tail(draw: ImageDraw.ImageDraw, box: list[int]) -> None:
        composite(draw, sprites["tail"]["normal"], box)

    module.draw_ribbon_root = draw_root
    module.draw_ribbon_segment = draw_segment
    module.draw_ribbon_tail = draw_tail

    def set_panel(panel: str) -> None:
        active["panel"] = panel

    return set_panel


def render_real_layout(
    root: Path,
    spec: dict[str, Any],
    sprites: dict[str, dict[str, Image.Image]],
    output: Path,
) -> list[dict[str, Any]]:
    module = load_simulation_module(root)
    set_panel = install_candidate_art(module, sprites)
    title_path = resolve(root, spec["inputs"]["title_font"])
    body_path = resolve(root, spec["inputs"]["body_font"])
    fonts = {
        "title": module.load_font(title_path, 16),
        "detail_title": module.load_font(title_path, 15),
        "heading": module.load_font(title_path, 11),
        "body": module.load_font(body_path, 10),
        "row": module.load_font(body_path, 10),
        "small": module.load_font(body_path, 9),
        "reward": module.load_font(body_path, 8),
        "board_title": module.load_font(title_path, 19),
        "board_body": module.load_font(body_path, 11),
        "board_small": module.load_font(body_path, 10),
    }
    shell, seal = module.load_inputs(root, spec)
    canvas = Image.new("RGBA", tuple(spec["canvas"]), module.BOARD)
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rectangle((0, 620, canvas.width, canvas.height), fill=module.BOARD_LOWER)
    for x in range(-80, canvas.width + 100, 150):
        draw.polygon(
            [(x, 620), (x + 125, 620), (x + 190, canvas.height), (x + 15, canvas.height)],
            fill=(69, 49, 33, 165),
            outline=(42, 29, 21, 190),
        )
    draw.text(
        (36, 22),
        f"QS-B1 V2 · {spec['version']} · 候选真实排版",
        font=fonts["board_title"],
        fill=(237, 201, 128, 255),
    )
    draw.text(
        (36, 52),
        "真实 676×464 Frame、246×324 详情 viewport、18 行任务、4 个 108×41 奖励槽；候选按固定九区切片显示。",
        font=fonts["board_body"],
        fill=(201, 171, 111, 255),
    )
    origins = [tuple(value) for value in spec["presentation"]["origins"]]
    metrics: list[dict[str, Any]] = []
    for origin, state in zip(origins, spec["states"]):
        set_panel(state["id"])
        draw.text(
            (origin[0], origin[1] - 27),
            state["label"],
            font=fonts["board_body"],
            fill=(237, 201, 128, 255),
        )
        module.draw_quest_log_state(
            canvas, shell, seal, origin, spec, fonts, state
        )
        metrics.append(module.state_metrics(spec, state))
    draw.text(
        (36, 1142),
        "候选显示顺序：挂根 · 共享 · 收起详情 · 显示位置 · 隐藏位置 · 清理标记 · 重建标记 · 放弃任务 · 短尾。",
        font=fonts["board_body"],
        fill=(229, 194, 124, 255),
    )
    draw.text(
        (36, 1170),
        "B 面板轮换 normal / hover / pressed / disabled，仅用于检查四态；C/D 检查 ScrollChild 裁切与命中区。",
        font=fonts["board_small"],
        fill=(205, 171, 109, 255),
    )
    draw.text(
        (36, 1194),
        "本图是 ignored review intermediate，不是 source、runtime 或 addon 资产。",
        font=fonts["board_small"],
        fill=(190, 157, 101, 255),
    )
    canvas.save(output, "PNG")
    return metrics


def checker(size: tuple[int, int], block: int = 16) -> Image.Image:
    image = Image.new("RGBA", size, (54, 46, 39, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], block):
        for x in range(0, size[0], block):
            if (x // block + y // block) % 2:
                draw.rectangle(
                    (x, y, x + block - 1, y + block - 1),
                    fill=(84, 73, 63, 255),
                )
    return image


def render_contact_sheet(
    root: Path,
    raw: Image.Image,
    normalized: Image.Image,
    atlas: Image.Image,
    output: Path,
    attempt: str,
    fit_metrics: dict[str, Any],
) -> None:
    sheet = Image.new("RGBA", (1500, 1000), (34, 27, 22, 255))
    draw = ImageDraw.Draw(sheet, "RGBA")
    title = ImageFont.truetype(
        str(root / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"),
        22,
    )
    body = ImageFont.truetype(
        str(root / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"),
        16,
    )
    draw.text((28, 22), f"QS-B1 V2 候选技术审查 · {attempt}", font=title, fill=(235, 201, 132, 255))

    raw_preview = raw.copy().convert("RGBA")
    raw_preview.thumbnail((520, 820), RESAMPLE)
    sheet.alpha_composite(raw_preview, (28, 72))
    draw.text((28, 910), "A · untouched raw", font=body, fill=(219, 183, 116, 255))

    normalized_preview = checker((512, 512))
    normalized_preview.alpha_composite(normalized.resize((512, 512), RESAMPLE))
    nx, ny = 580, 72
    sheet.alpha_composite(normalized_preview, (nx, ny))
    draw.rectangle(
        (
            nx + TARGET_BBOX[0] // 2,
            ny + TARGET_BBOX[1] // 2,
            nx + TARGET_BBOX[2] // 2,
            ny + TARGET_BBOX[3] // 2,
        ),
        outline=(237, 190, 79, 255),
        width=2,
    )
    for _, box, _ in ZONES[1:-1]:
        y = ny + box[1] // 2
        draw.line(
            (nx + TARGET_BBOX[0] // 2, y, nx + TARGET_BBOX[2] // 2, y),
            fill=(139, 69, 52, 220),
            width=1,
        )
        draw.rectangle(
            (
                nx + (box[0] + 16) // 2,
                ny + (box[1] + 12) // 2,
                nx + (box[0] + 112) // 2,
                ny + (box[1] + 76) // 2,
            ),
            outline=(75, 205, 212, 220),
            width=1,
        )
    draw.text((580, 603), "B · 1024² normalized + fixed nine-zone grid", font=body, fill=(219, 183, 116, 255))

    atlas_preview = atlas.resize((512, atlas.height * 4), Image.Resampling.NEAREST)
    sheet.alpha_composite(atlas_preview, (950, 660))
    draw.text((950, 630), "C · four-state runtime atlas ×4", font=body, fill=(219, 183, 116, 255))
    for index, state in enumerate(STATE_ORDER):
        draw.text((950 + index * 128 + 4, 945), state, font=body, fill=(204, 171, 111, 255))

    lines = (
        f"raw visible: {fit_metrics['raw_visible_size'][0]}×{fit_metrics['raw_visible_size'][1]}",
        f"raw aspect: {fit_metrics['raw_visible_aspect']:.4f}",
        f"target aspect: {fit_metrics['target_visible_aspect']:.4f}",
        f"aspect error: {fit_metrics['relative_aspect_error']:.1%}",
        f"normalized object: {fit_metrics['normalized_object_size'][0]}×{fit_metrics['normalized_object_size'][1]}",
    )
    for index, value in enumerate(lines):
        draw.text((1140, 88 + index * 26), value, font=body, fill=(215, 184, 125, 255))
    sheet.save(output, "PNG")


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    spec_path = resolve(root, args.spec)
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    raw = Image.open(args.raw).convert("RGB")

    keyed, chroma_metrics = edge_connected_chroma_key(raw)
    normalized, fit_metrics = proportional_fit(keyed)
    sprites, zone_metrics = slice_and_derive(normalized)

    keyed_path = output_dir / f"{args.attempt}.keyed.png"
    normalized_path = output_dir / f"{args.attempt}.normalized-review.png"
    atlas_path = output_dir / f"{args.attempt}.four-state-atlas-review.png"
    contact_path = output_dir / f"{args.attempt}.contact-sheet.png"
    real_layout_path = output_dir / f"{args.attempt}.real-layout.png"
    report_path = output_dir / f"{args.attempt}.review.json"
    keyed.save(keyed_path, "PNG")
    normalized.save(normalized_path, "PNG")
    build_atlas(sprites, atlas_path)
    atlas = Image.open(atlas_path).convert("RGBA")
    render_contact_sheet(
        root, raw, normalized, atlas, contact_path, args.attempt, fit_metrics
    )
    state_metrics = render_real_layout(
        root, spec, sprites, real_layout_path
    )

    visible_bbox = fit_metrics["normalized_visible_bbox_exclusive"]
    zone_nonempty = all(item["runtime_visible_pixels"] > 0 for item in zone_metrics)
    internal_boundaries_connected = all(
        upper["source_bottom_edge_coverage"] >= 0.75
        and lower["source_top_edge_coverage"] >= 0.75
        for upper, lower in zip(zone_metrics, zone_metrics[1:])
    )
    action_metrics = [
        item for item in zone_metrics if item["name"].startswith("action-")
    ]
    motifs_inside_safe_boxes = all(
        item["diagnostic_broad_ink_pixels"] > 0
        and item["diagnostic_broad_ink_outside_vertical_safe_ratio"] <= 0.05
        for item in action_metrics
    )
    checks = {
        "normalized_canvas_is_1024_square": normalized.size == CANVAS,
        "normalized_transparent_rgb_is_zero": bool(
            np.all(
                np.asarray(normalized)[:, :, :3][
                    np.asarray(normalized)[:, :, 3] == 0
                ]
                == 0
            )
        ),
        "visible_bbox_exactly_matches_128x696_contract": visible_bbox
        == list(TARGET_BBOX),
        "visible_aspect_within_one_percent": fit_metrics[
            "relative_aspect_error"
        ]
        <= 0.01,
        "all_nine_runtime_zones_have_visible_pixels": zone_nonempty,
        "cloth_is_continuous_across_all_zone_boundaries": internal_boundaries_connected,
        "all_action_motifs_stay_inside_vertical_safe_boxes": motifs_inside_safe_boxes,
        "runtime_zone_dimensions_match_v11": all(
            item["runtime_size"] == list(runtime_size)
            for item, (_, _, runtime_size) in zip(zone_metrics, ZONES)
        ),
        "real_layout_uses_four_states": len(state_metrics) == 4,
        "real_layout_top_open_has_seven_enabled_actions": state_metrics[1][
            "enabled_action_count"
        ]
        == 7,
        "real_layout_partial_scroll_disables_clipped_action": state_metrics[2][
            "enabled_action_count"
        ]
        == 6,
        "real_layout_full_scroll_has_zero_hitboxes": state_metrics[3][
            "enabled_action_count"
        ]
        == 0,
    }
    first_failed = next((name for name, passed in checks.items() if not passed), None)
    report = {
        "schema": "aeui.quest-seal-ribbon.candidate-review.v2",
        "batch": "QS-B1 V2",
        "attempt": args.attempt,
        "repo_commit_before_generation": args.repo_commit,
        "fixed_executor_session_id": args.session_id,
        "raw": {
            "path": str(args.raw),
            "sha256": sha256(args.raw),
            **chroma_metrics,
        },
        "fit": fit_metrics,
        "zones": zone_metrics,
        "checks": checks,
        "checks_passed": sum(checks.values()),
        "checks_total": len(checks),
        "first_automated_failure": first_failed,
        "technical_status": "pass" if first_failed is None else "fail",
        "real_layout": {
            "path": str(real_layout_path),
            "sha256": sha256(real_layout_path),
            "frame": spec["frame"],
            "detail_viewport": spec["layout"]["detail_viewport"],
            "quest_rows": spec["content"]["quest_rows"],
            "reward_slots": spec["content"]["reward_slots"],
            "state_metrics": state_metrics,
        },
        "outputs": {
            "keyed": {"path": str(keyed_path), "sha256": sha256(keyed_path)},
            "normalized": {
                "path": str(normalized_path),
                "sha256": sha256(normalized_path),
            },
            "four_state_atlas_review": {
                "path": str(atlas_path),
                "sha256": sha256(atlas_path),
            },
            "contact_sheet": {
                "path": str(contact_path),
                "sha256": sha256(contact_path),
            },
        },
        "promotion": {
            "source_written": False,
            "runtime_written": False,
            "addon_changed": False,
        },
    }
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
