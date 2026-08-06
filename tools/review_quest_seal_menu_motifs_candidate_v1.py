#!/usr/bin/env python3
"""Review one QS-B1 V5-B seven-motif worksheet candidate.

The raw provider image is kept untouched.  Every derived file is a review-only
intermediate under ``generated/``: square normalization, edge-connected chroma
keying, fixed seven-cell crops, proportional runtime fits, four-state previews,
and a six-scenario Quest Log composition using the accepted substrate.  This
script never writes source assets, runtime media, or addon files.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFont


CANVAS = (1024, 1024)
RESAMPLE = Image.Resampling.LANCZOS
STATE_ORDER = ("normal", "hover", "pressed", "disabled")

ACTIONS: tuple[dict[str, Any], ...] = (
    {
        "id": "share",
        "cell": (32, 160, 256, 384),
        "safe": (64, 208, 224, 336),
        "runtime_box": (7, 5, 25, 17),
    },
    {
        "id": "detail",
        "cell": (272, 160, 496, 384),
        "safe": (304, 208, 464, 336),
        "runtime_box": (9, 4, 23, 18),
    },
    {
        "id": "show",
        "cell": (512, 160, 736, 384),
        "safe": (544, 208, 704, 336),
        "runtime_box": (9, 4, 23, 18),
    },
    {
        "id": "hide",
        "cell": (752, 160, 976, 384),
        "safe": (784, 208, 944, 336),
        "runtime_box": (8, 4, 24, 18),
    },
    {
        "id": "clean",
        "cell": (32, 608, 256, 832),
        "safe": (64, 656, 224, 784),
        "runtime_box": (7, 6, 25, 16),
    },
    {
        "id": "reset",
        "cell": (272, 608, 496, 832),
        "safe": (304, 656, 464, 784),
        "runtime_box": (7, 5, 24, 17),
    },
    {
        "id": "abandon",
        "cell": (512, 608, 736, 832),
        "safe": (544, 656, 704, 784),
        "runtime_box": (8, 7, 24, 16),
    },
)
EMPTY_CELL = (752, 608, 976, 832)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("raw", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument(
        "--spec",
        type=Path,
        default=Path("tools/specs/quest_log_seal_motifs_simulation_v15.json"),
    )
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--repo-commit", required=True)
    parser.add_argument("--session-id", required=True)
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_module(path: Path, name: str) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot import {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


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


def contains(outer: tuple[int, int, int, int], inner: tuple[int, int, int, int]) -> bool:
    return (
        outer[0] <= inner[0]
        and outer[1] <= inner[1]
        and outer[2] >= inner[2]
        and outer[3] >= inner[3]
    )


def visible_green_spill(image: Image.Image) -> int:
    rgba = np.asarray(image.convert("RGBA"))
    visible = rgba[:, :, 3] > 0
    red = rgba[:, :, 0].astype(np.int16)
    green = rgba[:, :, 1].astype(np.int16)
    blue = rgba[:, :, 2].astype(np.int16)
    return int((visible & (green >= 95) & (green - np.maximum(red, blue) >= 28)).sum())


def color_metrics(image: Image.Image) -> dict[str, Any]:
    rgba = np.asarray(image.convert("RGBA"))
    pixels = rgba[rgba[:, :, 3] > 0, :3]
    if not len(pixels):
        return {"visible_pixels": 0}
    luma = (
        pixels[:, 0].astype(np.float64) * 0.2126
        + pixels[:, 1].astype(np.float64) * 0.7152
        + pixels[:, 2].astype(np.float64) * 0.0722
    )
    chroma = pixels.max(axis=1).astype(np.int16) - pixels.min(axis=1).astype(np.int16)
    return {
        "visible_pixels": int(len(pixels)),
        "median_rgb": [int(value) for value in np.median(pixels, axis=0)],
        "luma_p50": round(float(np.percentile(luma, 50)), 3),
        "luma_p95": round(float(np.percentile(luma, 95)), 3),
        "chroma_p50": round(float(np.percentile(chroma, 50)), 3),
    }


def fit_cell_to_runtime(
    cell: Image.Image,
    target_box: tuple[int, int, int, int],
) -> tuple[Image.Image, dict[str, Any]]:
    bbox = alpha_bbox(cell)
    if bbox is None:
        raise ValueError("cannot fit an empty motif cell")
    crop = clear_transparent_rgb(cell.crop(bbox))
    width = target_box[2] - target_box[0]
    height = target_box[3] - target_box[1]
    scale = min(width / crop.width, height / crop.height)
    size = (max(1, round(crop.width * scale)), max(1, round(crop.height * scale)))
    resized = clear_transparent_rgb(crop.resize(size, RESAMPLE))
    sprite = Image.new("RGBA", (32, 22), (0, 0, 0, 0))
    paste = (
        target_box[0] + (width - size[0]) // 2,
        target_box[1] + (height - size[1]) // 2,
    )
    sprite.alpha_composite(resized, paste)
    sprite = clear_transparent_rgb(sprite)
    return sprite, {
        "source_bbox_exclusive": list(bbox),
        "runtime_box_exclusive": list(target_box),
        "runtime_size": list(size),
        "runtime_paste": list(paste),
        "runtime_visible_bbox_exclusive": list(alpha_bbox(sprite) or ()),
    }


def derive_state(normal: Image.Image, state: str) -> Image.Image:
    if state == "normal":
        return normal.copy()
    if state == "hover":
        result = ImageEnhance.Brightness(normal).enhance(1.08)
        return clear_transparent_rgb(ImageEnhance.Color(result).enhance(1.02))
    if state == "pressed":
        result = clear_transparent_rgb(ImageEnhance.Brightness(normal).enhance(0.82))
        shifted = Image.new("RGBA", result.size, (0, 0, 0, 0))
        shifted.alpha_composite(result, (1, 1))
        return clear_transparent_rgb(shifted)
    rgba = np.asarray(normal.convert("RGBA")).copy()
    rgb = rgba[:, :, :3].astype(np.float64)
    grey = (
        rgb[:, :, 0] * 0.2126
        + rgb[:, :, 1] * 0.7152
        + rgb[:, :, 2] * 0.0722
    )
    rgba[:, :, :3] = np.clip(grey[:, :, None] * 0.72, 0, 255).astype(np.uint8)
    rgba[:, :, 3] = np.round(rgba[:, :, 3].astype(np.float64) * 0.52).astype(np.uint8)
    return clear_transparent_rgb(Image.fromarray(rgba, "RGBA"))


def build_atlas(states: dict[str, dict[str, Image.Image]]) -> Image.Image:
    atlas = Image.new("RGBA", (256, 128), (0, 0, 0, 0))
    for column, action in enumerate(ACTIONS):
        for row, state in enumerate(STATE_ORDER):
            atlas.alpha_composite(states[action["id"]][state], (column * 32, row * 32 + 5))
    return clear_transparent_rgb(atlas)


def render_real_layout(
    root: Path,
    spec_path: Path,
    states: dict[str, dict[str, Image.Image]],
    output: Path,
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    renderer = load_module(
        root / "tools/render_quest_log_seal_layered_actions_simulation_v2.py",
        "aeui_qs_b1_v5b_layout",
    )
    base = renderer.load_base_module(root)
    spec = renderer.load_simulation_spec(spec_path, root)
    spec["_repo_root"] = str(root)

    def candidate_motif(
        action_id: str,
        state: str,
        _spec: dict[str, Any] | None = None,
    ) -> Image.Image:
        return states[action_id][state].copy()

    renderer.motif_art = candidate_motif
    fonts = {
        "title": base.load_font(renderer.resolve(root, spec["inputs"]["title_font"]), 16),
        "detail_title": base.load_font(renderer.resolve(root, spec["inputs"]["title_font"]), 15),
        "heading": base.load_font(renderer.resolve(root, spec["inputs"]["title_font"]), 11),
        "body": base.load_font(renderer.resolve(root, spec["inputs"]["body_font"]), 10),
        "row": base.load_font(renderer.resolve(root, spec["inputs"]["body_font"]), 10),
        "small": base.load_font(renderer.resolve(root, spec["inputs"]["body_font"]), 9),
        "reward": base.load_font(renderer.resolve(root, spec["inputs"]["body_font"]), 8),
        "board_title": base.load_font(renderer.resolve(root, spec["inputs"]["title_font"]), 19),
        "board_body": base.load_font(renderer.resolve(root, spec["inputs"]["body_font"]), 11),
        "board_small": base.load_font(renderer.resolve(root, spec["inputs"]["body_font"]), 10),
    }
    shell, seal = base.load_inputs(root, spec)
    canvas = Image.new("RGBA", tuple(spec["canvas"]), renderer.BOARD)
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rectangle((0, 626, canvas.width, canvas.height), fill=renderer.BOARD_LOWER)
    for x in range(-90, canvas.width + 120, 150):
        draw.polygon(
            [(x, 626), (x + 126, 626), (x + 190, canvas.height), (x + 14, canvas.height)],
            fill=(67, 47, 32, 155),
            outline=(40, 28, 20, 180),
        )
    draw.text((30, 22), "QS-B1 V5-B · production candidate real layout", font=fonts["board_title"], fill=(237, 201, 128, 255))
    draw.text((30, 52), "accepted V5-A substrate + seven candidate motifs · exact 676×464 Quest Log geometry", font=fonts["board_body"], fill=(203, 173, 113, 255))
    metrics: list[dict[str, Any]] = []
    for origin, scenario in zip(
        [tuple(value) for value in spec["presentation"]["origins"]],
        spec["states"],
    ):
        draw.text((origin[0], origin[1] - 27), scenario["label"], font=fonts["board_body"], fill=(237, 201, 128, 255))
        renderer.draw_state(base, canvas, shell, seal, origin, spec, fonts, scenario)
        metrics.append(renderer.state_metrics(spec, scenario))
    draw.text((30, 1172), "Review-only assembly: dynamic text and rewards remain runtime objects; motif pixels are not source/runtime.", font=fonts["board_small"], fill=(213, 179, 113, 255))
    draw.text((30, 1195), "Scenarios: closed / 7 / 5 / 3+disabled / partial scroll / fully scrolled out.", font=fonts["board_small"], fill=(192, 159, 103, 255))
    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, "PNG")
    return metrics, spec


def render_contact_sheet(
    raw: Image.Image,
    normalized: Image.Image,
    keyed: Image.Image,
    cells: dict[str, Image.Image],
    atlas: Image.Image,
    output: Path,
) -> None:
    canvas = Image.new("RGBA", (1800, 1500), (35, 38, 35, 255))
    draw = ImageDraw.Draw(canvas, "RGBA")
    title_font = ImageFont.load_default()
    draw.text((24, 18), "QS-B1 V5-B candidate technical board", font=title_font, fill=(235, 202, 139, 255))
    raw_thumb = raw.convert("RGBA").resize((500, 500), Image.Resampling.BILINEAR)
    norm_thumb = normalized.convert("RGBA").resize((500, 500), Image.Resampling.BILINEAR)
    keyed_thumb = keyed.resize((500, 500), Image.Resampling.BILINEAR)
    canvas.alpha_composite(raw_thumb, (24, 54))
    canvas.alpha_composite(norm_thumb, (650, 54))
    checker = Image.new("RGBA", (500, 500), (93, 90, 79, 255))
    check_draw = ImageDraw.Draw(checker)
    for y in range(0, 500, 24):
        for x in range(0, 500, 24):
            if (x // 24 + y // 24) % 2:
                check_draw.rectangle((x, y, x + 23, y + 23), fill=(133, 126, 106, 255))
    checker.alpha_composite(keyed_thumb)
    canvas.alpha_composite(checker, (1276, 54))
    for x, label in ((24, "raw 1254²"), (650, "normalized 1024²"), (1276, "edge-connected key")):
        draw.text((x, 566), label, font=title_font, fill=(216, 183, 121, 255))

    for index, action in enumerate(ACTIONS):
        x = 24 + index * 246
        cell = cells[action["id"]]
        canvas.alpha_composite(cell.resize((224, 224), Image.Resampling.NEAREST), (x, 650))
        draw.text((x, 884), action["id"], font=title_font, fill=(216, 183, 121, 255))
    draw.text((388, 928), "four-state review atlas ×4", font=title_font, fill=(216, 183, 121, 255))
    canvas.alpha_composite(atlas.resize((1024, 512), Image.Resampling.NEAREST), (388, 958))
    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, "PNG")


def write_display_region_contract(
    root: Path,
    spec: dict[str, Any],
    attempt: str,
    real_layout_path: Path,
    output_dir: Path,
) -> Path:
    template_path = root / spec["display_region"]["template"]
    contract = json.loads(template_path.read_text(encoding="utf-8"))
    contract["component"] = (
        "QS-B1/QUEST.LOG.ACTION.SEAL_MENU/V5-B/"
        f"{attempt}/production-candidate-review"
    )
    contract["evidence"].update(
        {
            "production_prompt_version": "QS-B1 V5-B",
            "production_candidate": str(real_layout_path),
            "background_ownership": (
                "exact accepted V5-A source reduced to one 32x174 visual-only "
                "master; dynamic prefix plus fixed tail"
            ),
            "motif_ownership": (
                "seven independent review-only transparent motif crops and "
                "seven independent runtime Button geometries"
            ),
            "direction_only": False,
            "final_runtime": False,
        }
    )
    output = output_dir / f"{attempt}.display-region-contract.json"
    output.write_text(
        json.dumps(contract, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return output


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    raw_path = args.raw.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    spec_path = args.spec if args.spec.is_absolute() else root / args.spec

    helper = load_module(
        root / "tools/review_quest_seal_ribbon_candidate_v2.py",
        "aeui_qs_b1_chroma_helper",
    )
    with Image.open(raw_path) as opened:
        raw = opened.convert("RGB")
    if raw.width != raw.height:
        raise ValueError("V5-B raw worksheet must be square before normalization")
    normalized = raw.resize(CANVAS, RESAMPLE)
    keyed, chroma_metrics = helper.edge_connected_chroma_key(normalized)
    keyed = clear_transparent_rgb(keyed)

    normalized_path = output_dir / f"{args.attempt}.normalized-rgb.png"
    keyed_path = output_dir / f"{args.attempt}.keyed-review.png"
    normalized.save(normalized_path, "PNG")
    keyed.save(keyed_path, "PNG")

    cells: dict[str, Image.Image] = {}
    states: dict[str, dict[str, Image.Image]] = {}
    cell_metrics: list[dict[str, Any]] = []
    for action in ACTIONS:
        cell = clear_transparent_rgb(keyed.crop(action["cell"]))
        cells[action["id"]] = cell
        local_bbox = alpha_bbox(cell)
        if local_bbox is None:
            global_bbox: tuple[int, int, int, int] | None = None
        else:
            global_bbox = (
                action["cell"][0] + local_bbox[0],
                action["cell"][1] + local_bbox[1],
                action["cell"][0] + local_bbox[2],
                action["cell"][1] + local_bbox[3],
            )
        sprite, fit = fit_cell_to_runtime(cell, action["runtime_box"])
        states[action["id"]] = {
            state: derive_state(sprite, state) for state in STATE_ORDER
        }
        cell_path = output_dir / f"{args.attempt}.cell-{action['id']}.png"
        cell.save(cell_path, "PNG")
        cell_metrics.append(
            {
                "id": action["id"],
                "cell_exclusive": list(action["cell"]),
                "safe_box_exclusive": list(action["safe"]),
                "visible_bbox_global_exclusive": list(global_bbox or ()),
                "nonempty": global_bbox is not None,
                "inside_safe_box": bool(global_bbox and contains(action["safe"], global_bbox)),
                "visible_green_spill": visible_green_spill(cell),
                "color": color_metrics(cell),
                "runtime_fit": fit,
                "review_cell": {"path": str(cell_path), "sha256": sha256(cell_path)},
            }
        )

    empty = clear_transparent_rgb(keyed.crop(EMPTY_CELL))
    empty_visible = int((np.asarray(empty)[:, :, 3] > 0).sum())
    atlas = build_atlas(states)
    atlas_path = output_dir / f"{args.attempt}.four-state-atlas-review.png"
    atlas.save(atlas_path, "PNG")
    real_layout_path = output_dir / f"{args.attempt}.real-layout.png"
    state_metrics, spec = render_real_layout(root, spec_path, states, real_layout_path)
    display_contract_path = write_display_region_contract(
        root, spec, args.attempt, real_layout_path, output_dir
    )
    contact_path = output_dir / f"{args.attempt}.contact-sheet.png"
    render_contact_sheet(raw, normalized, keyed, cells, atlas, contact_path)

    by_id = {item["id"]: item for item in state_metrics}
    checks = {
        "raw_is_square": raw.width == raw.height,
        "normalized_canvas_is_1024_square": normalized.size == CANVAS,
        "keyed_transparent_rgb_is_zero": bool(
            np.all(np.asarray(keyed)[:, :, :3][np.asarray(keyed)[:, :, 3] == 0] == 0)
        ),
        "exactly_seven_nonempty_cells": sum(item["nonempty"] for item in cell_metrics) == 7,
        "all_visible_pixels_stay_inside_safe_boxes": all(item["inside_safe_box"] for item in cell_metrics),
        "all_seven_cells_have_zero_visible_green_spill": all(item["visible_green_spill"] == 0 for item in cell_metrics),
        "eighth_cell_is_empty": empty_visible == 0,
        "atlas_is_256x128": atlas.size == (256, 128),
        "closed_has_zero_action_buttons": by_id["closed-top"]["enabled_action_count"] == 0,
        "all_seven_state_has_seven_hitboxes": by_id["open-all-seven"]["enabled_action_count"] == 7,
        "disabled_state_leaves_two_enabled_hitboxes": by_id["open-filtered-three-disabled"]["enabled_action_count"] == 2,
        "fully_scrolled_out_has_zero_hitboxes": by_id["filtered-five-fully-scrolled-out"]["enabled_action_count"] == 0,
    }
    first_failed = next((name for name, passed in checks.items() if not passed), None)
    report = {
        "schema": "aeui.quest-log.seal-menu-motifs.candidate-review.v1",
        "batch": "QS-B1 V5-B",
        "attempt": args.attempt,
        "repo_commit_before_generation": args.repo_commit,
        "fixed_executor_session_id": args.session_id,
        "raw": {
            "path": str(raw_path),
            "sha256": sha256(raw_path),
            "size": list(raw.size),
            "mode": raw.mode,
        },
        "normalization": {
            "method": "whole-square proportional LANCZOS 1254-to-1024",
            "path": str(normalized_path),
            "sha256": sha256(normalized_path),
            **chroma_metrics,
        },
        "cells": cell_metrics,
        "empty_cell_visible_pixels": empty_visible,
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
        "display_region_contract": {
            "path": str(display_contract_path),
            "sha256": sha256(display_contract_path),
        },
        "outputs": {
            "keyed_review": {"path": str(keyed_path), "sha256": sha256(keyed_path)},
            "four_state_atlas_review": {"path": str(atlas_path), "sha256": sha256(atlas_path)},
            "contact_sheet": {"path": str(contact_path), "sha256": sha256(contact_path)},
        },
        "promotion": {
            "source_written": False,
            "runtime_written": False,
            "addon_changed": False,
        },
    }
    report_path = output_dir / f"{args.attempt}.review.json"
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
