#!/usr/bin/env python3
"""Normalize and review one CHAT.INPUT.DARK.V1 provider candidate.

The script uses only pixels from the supplied candidate. It derives Alpha from
the candidate's green field, aligns the two generated states, enforces their
shared silhouette, builds the contracted runtime atlas, and renders the atlas
inside the current tracked Chat layout. Outputs remain review intermediates.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw

import build_chat_full_frame_v1_runtime as frame_v1
import build_chat_v3_runtime_assets as v3
import render_chat_dark_paper_candidate_v1 as layout
import render_chat_full_frame_runtime_v1 as full_runtime
import render_chat_input_dark_simulation_v1 as sim


ROOT = Path(__file__).resolve().parents[1]
RAW_SIZE = (1536, 1024)
PROVIDER_CELLS = {
    "normal": (51, 187, 1437, 363),
    "focus": (51, 448, 1437, 625),
}
# The authorized prose also says both cells are 1386x176. The focus bounds
# above are 177px high under the same right/bottom-exclusive convention. Use
# the first 176 rows as the canonical state crop and leave y=624 transparent;
# the generated object still remains within the larger provider allowance.
STATE_CELLS = {
    "normal": (51, 187, 1437, 363),
    "focus": (51, 448, 1437, 624),
}
STATE_HALVES = {
    "normal": (0, 0, 1536, 512),
    "focus": (0, 512, 1536, 1024),
}
NORMALIZED_OBJECT_SIZE = (1344, 154)
ATLAS_BOXES = {
    "normal": (8, 4, 1016, 124),
    "focus": (8, 132, 1016, 252),
}
MAX_OPAQUE_GREEN_SCORE = 160
MIN_MATTE_TRANSITION = 40
BACKGROUND_BORDER = 32
RESAMPLE = Image.Resampling.LANCZOS


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument(
        "--simulation-spec",
        type=Path,
        default=ROOT / "tools/specs/chat_input_dark_simulation_v1.json",
    )
    parser.add_argument(
        "--display-contract",
        type=Path,
        default=ROOT / "tools/specs/chat_input_dark_display_region_v1.json",
    )
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--session", required=True)
    parser.add_argument("--execution-commit", required=True)
    parser.add_argument("--imagegen-count", default="1/5")
    return parser.parse_args()


def resolve(path: str | Path) -> Path:
    value = Path(path)
    return value if value.is_absolute() else ROOT / value


def display(path: Path) -> str:
    try:
        return path.resolve().relative_to(ROOT).as_posix()
    except ValueError:
        return str(path.resolve())


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=False, compress_level=9)


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    values = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    values_i16 = values.astype(np.int16)
    visible_green = (
        (values[:, :, 3] > 0)
        & (values[:, :, 1] >= 96)
        & (values_i16[:, :, 1] >= values_i16[:, :, 0] + 32)
        & (values_i16[:, :, 1] >= values_i16[:, :, 2] + 32)
    )
    cap = np.minimum(
        values_i16[:, :, 1],
        np.maximum(values_i16[:, :, 0], values_i16[:, :, 2]) + 4,
    ).astype(np.uint8)
    values[:, :, 1][visible_green] = cap[visible_green]
    values[values[:, :, 3] == 0, :3] = 0
    return Image.fromarray(values, mode="RGBA")


def green_metrics(rgb: np.ndarray) -> dict[str, Any]:
    score = rgb[:, :, 1].astype(np.int16) - np.maximum(
        rgb[:, :, 0].astype(np.int16), rgb[:, :, 2].astype(np.int16)
    )
    exact = np.all(rgb == np.array([0, 255, 0], dtype=np.uint8), axis=2)
    return {
        "exact_00ff00_pixels": int(exact.sum()),
        "score_min": int(score.min()),
        "score_max": int(score.max()),
        "score_percentiles": {
            str(percentile): float(np.percentile(score, percentile))
            for percentile in (0, 1, 5, 25, 50, 75, 95, 99, 100)
        },
    }


def derive_candidate_rgba(raw: Image.Image) -> tuple[Image.Image, dict[str, Any]]:
    rgb = np.asarray(raw.convert("RGB"), dtype=np.uint8)
    red = rgb[:, :, 0].astype(np.int16)
    green = rgb[:, :, 1].astype(np.int16)
    blue = rgb[:, :, 2].astype(np.int16)
    score = green - np.maximum(red, blue)

    border_values = np.concatenate(
        (
            score[:BACKGROUND_BORDER, :].ravel(),
            score[-BACKGROUND_BORDER:, :].ravel(),
            score[BACKGROUND_BORDER:-BACKGROUND_BORDER, :BACKGROUND_BORDER].ravel(),
            score[BACKGROUND_BORDER:-BACKGROUND_BORDER, -BACKGROUND_BORDER:].ravel(),
        )
    )
    transparent_green_score = int(border_values.min()) - 1
    opaque_green_score = min(
        MAX_OPAQUE_GREEN_SCORE,
        transparent_green_score - MIN_MATTE_TRANSITION,
    )
    if transparent_green_score <= opaque_green_score:
        raise ValueError("candidate green field has no usable matte transition")

    alpha = np.clip(
        (transparent_green_score - score)
        * (255.0 / (transparent_green_score - opaque_green_score)),
        0,
        255,
    ).astype(np.uint8)
    alpha[score <= opaque_green_score] = 255
    alpha[score >= transparent_green_score] = 0

    # Candidate-self despill only. Brown object pixels already have R >= G and
    # are unchanged; green-mixed edge pixels are capped to their own R/B range.
    rgba = np.zeros((*rgb.shape[:2], 4), dtype=np.uint8)
    rgba[:, :, :3] = rgb
    visible = alpha > 0
    green_cap = np.minimum(
        rgba[:, :, 1].astype(np.int16),
        np.maximum(
            rgba[:, :, 0].astype(np.int16),
            rgba[:, :, 2].astype(np.int16),
        )
        + 4,
    ).astype(np.uint8)
    rgba[:, :, 1][visible] = green_cap[visible]
    rgba[:, :, 3] = alpha
    rgba[~visible, :3] = 0

    image = Image.fromarray(rgba, mode="RGBA")
    return image, {
        "background_border_pixels": BACKGROUND_BORDER,
        "background_score_min": int(border_values.min()),
        "background_score_max": int(border_values.max()),
        "opaque_green_score": opaque_green_score,
        "transparent_green_score": transparent_green_score,
        "alpha_pixels": {
            "transparent": int((alpha == 0).sum()),
            "partial": int(((alpha > 0) & (alpha < 255)).sum()),
            "opaque": int((alpha == 255).sum()),
        },
        "raw_green": green_metrics(rgb),
    }


def state_bbox(image: Image.Image, state: str) -> tuple[int, int, int, int]:
    half = STATE_HALVES[state]
    alpha = image.crop(half).getchannel("A")
    visible = np.asarray(alpha, dtype=np.uint8) > 0
    candidate_rows = np.flatnonzero(visible.sum(axis=1) > 30)
    if not len(candidate_rows):
        raise ValueError(f"{state} has no complete visible candidate row")
    row_groups = np.split(
        candidate_rows, np.flatnonzero(np.diff(candidate_rows) > 1) + 1
    )
    main_rows = max(
        row_groups,
        key=lambda group: int(visible[group[0] : group[-1] + 1].sum()),
    )
    main_visible = np.zeros_like(visible)
    main_visible[main_rows[0] : main_rows[-1] + 1] = visible[
        main_rows[0] : main_rows[-1] + 1
    ]
    bbox = Image.fromarray(main_visible.astype(np.uint8) * 255, mode="L").getbbox()
    if bbox is None:
        raise ValueError(f"{state} has no visible candidate pixels")
    absolute = (
        bbox[0] + half[0],
        bbox[1] + half[1],
        bbox[2] + half[0],
        bbox[3] + half[1],
    )
    if absolute[2] - absolute[0] < 1000 or absolute[3] - absolute[1] < 100:
        raise ValueError(f"{state} visible bbox is not a complete long strip: {absolute}")
    return absolute


def normalize_states(
    candidate: Image.Image,
) -> tuple[Image.Image, dict[str, Any]]:
    normalized = Image.new("RGBA", RAW_SIZE, (0, 0, 0, 0))
    raw_bboxes: dict[str, list[int]] = {}
    placed_boxes: dict[str, list[int]] = {}

    for state in ("normal", "focus"):
        bbox = state_bbox(candidate, state)
        raw_bboxes[state] = list(bbox)
        object_image = candidate.crop(bbox).resize(NORMALIZED_OBJECT_SIZE, RESAMPLE)
        cell = STATE_CELLS[state]
        x = cell[0] + ((cell[2] - cell[0]) - NORMALIZED_OBJECT_SIZE[0]) // 2
        y = cell[1] + ((cell[3] - cell[1]) - NORMALIZED_OBJECT_SIZE[1]) // 2
        normalized.alpha_composite(object_image, (x, y))
        placed_boxes[state] = [
            x,
            y,
            x + NORMALIZED_OBJECT_SIZE[0],
            y + NORMALIZED_OBJECT_SIZE[1],
        ]

    cells = {
        state: normalized.crop(STATE_CELLS[state])
        for state in ("normal", "focus")
    }
    normal_alpha = np.asarray(cells["normal"].getchannel("A"), dtype=np.uint8)
    focus_alpha = np.asarray(cells["focus"].getchannel("A"), dtype=np.uint8)
    shared_alpha = np.minimum(normal_alpha, focus_alpha)
    alpha_difference = int(np.count_nonzero(normal_alpha != focus_alpha))

    normalized = Image.new("RGBA", RAW_SIZE, (0, 0, 0, 0))
    for state in ("normal", "focus"):
        cell = cells[state].copy()
        cell.putalpha(Image.fromarray(shared_alpha, mode="L"))
        cell = clear_transparent_rgb(cell)
        normalized.alpha_composite(cell, STATE_CELLS[state][:2])

    return normalized, {
        "raw_visible_bboxes": raw_bboxes,
        "normalized_visible_boxes": placed_boxes,
        "normalized_object_size": list(NORMALIZED_OBJECT_SIZE),
        "pre_intersection_alpha_difference_pixels": alpha_difference,
        "shared_alpha_visible_bbox": list(
            Image.fromarray(shared_alpha, mode="L").getbbox() or ()
        ),
    }


def build_atlas(normalized: Image.Image) -> tuple[Image.Image, dict[str, Any]]:
    strips: dict[str, Image.Image] = {}
    for state in ("normal", "focus"):
        strips[state] = normalized.crop(STATE_CELLS[state]).resize((1008, 120), RESAMPLE)

    normal_alpha = np.asarray(strips["normal"].getchannel("A"), dtype=np.uint8)
    focus_alpha = np.asarray(strips["focus"].getchannel("A"), dtype=np.uint8)
    shared_alpha = np.minimum(normal_alpha, focus_alpha)
    for state in ("normal", "focus"):
        strips[state].putalpha(Image.fromarray(shared_alpha, mode="L"))
        strips[state] = clear_transparent_rgb(strips[state])

    atlas = Image.new("RGBA", (1024, 256), (0, 0, 0, 0))
    atlas.alpha_composite(strips["normal"], ATLAS_BOXES["normal"][:2])
    atlas.alpha_composite(strips["focus"], ATLAS_BOXES["focus"][:2])
    atlas = clear_transparent_rgb(atlas)
    visible = np.asarray(atlas, dtype=np.uint8)
    visible_i16 = visible.astype(np.int16)
    heuristic_green = (
        (visible[:, :, 3] > 0)
        & (visible[:, :, 1] >= 96)
        & (visible_i16[:, :, 1] >= visible_i16[:, :, 0] + 32)
        & (visible_i16[:, :, 1] >= visible_i16[:, :, 2] + 32)
    )
    return atlas, {
        "size": list(atlas.size),
        "normal_focus_alpha_equal": strips["normal"].getchannel("A").tobytes()
        == strips["focus"].getchannel("A").tobytes(),
        "shared_alpha_bbox": list(
            strips["normal"].getchannel("A").getbbox() or ()
        ),
        "visible_green_spill_pixels": int(heuristic_green.sum()),
        "transparent_rgb_nonzero_values": int(
            np.count_nonzero(visible[visible[:, :, 3] == 0, :3])
        ),
    }


def render_transparent_preview(source: Image.Image) -> Image.Image:
    preview = Image.new("RGBA", source.size, (24, 18, 13, 255))
    draw = ImageDraw.Draw(preview, "RGBA")
    tile = 32
    for y in range(0, source.height, tile):
        for x in range(0, source.width, tile):
            if ((x // tile) + (y // tile)) % 2:
                draw.rectangle(
                    (x, y, x + tile - 1, y + tile - 1),
                    fill=(47, 37, 28, 255),
                )
    preview.alpha_composite(source)
    return preview


def render_real_layout(
    spec: dict[str, Any], candidate_atlas: Image.Image
) -> tuple[Image.Image, dict[str, Any], dict[str, Any]]:
    runtime_manifest = json.loads(
        resolve(spec["runtime_manifest"]).read_text(encoding="utf-8")
    )
    v3_manifest = json.loads(
        resolve(spec["v3_manifest"]).read_text(encoding="utf-8")
    )
    direction = json.loads(
        resolve(spec["direction_spec"]).read_text(encoding="utf-8")
    )
    theme = next(
        item for item in direction["themes"] if item["id"] == spec["theme_id"]
    )

    paths = {
        "frame": resolve(spec["runtime_frame_atlas"]),
        "tabs": resolve(spec["runtime_tabs_atlas"]),
        "shelf": resolve(spec["runtime_tab_shelf"]),
        "input": resolve(spec["runtime_input_atlas"]),
    }
    sim.validate_hash(
        paths["frame"], runtime_manifest["runtime_export"]["sha256"], "frame"
    )
    for key in ("tabs", "tab_shelf", "input"):
        path_key = "shelf" if key == "tab_shelf" else key
        sim.validate_hash(
            paths[path_key], v3_manifest["runtime_exports"][key]["sha256"], key
        )

    frame_atlas = Image.open(paths["frame"]).convert("RGBA")
    tab_atlas = Image.open(paths["tabs"]).convert("RGBA")
    shelf = Image.open(paths["shelf"]).convert("RGBA")
    current_input = Image.open(paths["input"]).convert("RGBA")
    palette = {
        key: sim.hex_color(value)
        for key, value in runtime_manifest["text_readability"]["palette_rgb"].items()
    }
    for role, value in theme["palette"].items():
        if role not in palette:
            palette[role] = value

    body_font = layout.load_font(
        spec["fonts"]["body"]["path"], spec["fonts"]["body"]["size"]
    )
    tab_font = layout.load_font(
        spec["fonts"]["tab"]["path"], spec["fonts"]["tab"]["size"]
    )
    input_font = layout.load_font(
        spec["fonts"]["input"]["path"], spec["fonts"]["input"]["size"]
    )
    label_font = layout.load_font(
        spec["fonts"]["label"]["path"], spec["fonts"]["label"]["size"]
    )
    note_font = layout.load_font(
        spec["fonts"]["note"]["path"], spec["fonts"]["note"]["size"]
    )

    canvas = Image.new("RGBA", tuple(spec["canvas"]), layout.rgba("#111713FF"))
    layout.draw_world_backdrop(canvas)
    draw = ImageDraw.Draw(canvas, "RGBA")
    evidence: dict[str, Any] = {}

    for scenario in spec["scenarios"]:
        origin = tuple(scenario["origin"])
        frame_size = tuple(scenario.get("frame_size", [440, 320]))
        draw.text(
            (origin[0] + frame_size[0] // 2, origin[1] - 21),
            scenario["label"],
            font=label_font,
            fill=layout.rgba("#E8D2A8FF"),
            anchor="mm",
        )
        assembled = layout.build_tabbed_frame(
            frame_v1.build_frame(frame_atlas, frame_size),
            tab_atlas,
            shelf,
            direction["tabs"],
            scenario["selected_tab"],
            tab_font,
            spec["tab_text"]["selected"],
            spec["tab_text"]["normal"],
        )
        messages = list(direction["messages"][: scenario["message_count"]])
        messages.extend(scenario.get("extra_messages", []))
        message_layout = layout.draw_messages(
            assembled,
            messages,
            palette,
            body_font,
            scenario["maximum_lines"],
            frame_size,
        )

        input_width = frame_size[0] - 60
        input_y = frame_size[1] - 31
        if scenario["input_source"] == "current-v3":
            strip = full_runtime.build_input(
                current_input, scenario["input_state"], input_width
            )
            text_evidence = {"text_box": None, "text_width": 0}
        else:
            strip = sim.build_candidate_input(
                candidate_atlas, scenario["input_state"], input_width
            )
            text_evidence = sim.add_input_text(
                strip,
                scenario["input_state"],
                scenario.get("input_header", ""),
                scenario.get("input_text", ""),
                input_font,
                spec["candidate_atlas"]["text"],
            )
        assembled.alpha_composite(strip, (30, input_y))
        canvas.alpha_composite(assembled, origin)
        evidence[scenario["id"]] = {
            "frame": list(frame_size),
            "origin": list(origin),
            "input_source": scenario["input_source"],
            "input_state": scenario["input_state"],
            "input_box": [30, input_y, frame_size[0] - 30, input_y + 25],
            "input_text_safe_box": [64, input_y, frame_size[0] - 52, input_y + 25],
            **text_evidence,
            **message_layout,
        }

    draw.text(
        (spec["canvas"][0] // 2, spec["canvas"][1] - 14),
        "正式候选真实排版：书框、Tab、动态文字与尺寸均来自当前 runtime；输入像素来自本次候选。",
        font=note_font,
        fill=layout.rgba("#D7C49AFF"),
        anchor="ms",
    )
    return canvas, evidence, paths


def make_display_contract(
    base_path: Path,
    attempt: str,
    atlas_path: Path,
    layout_path: Path,
    metrics_path: Path,
) -> dict[str, Any]:
    contract = copy.deepcopy(json.loads(base_path.read_text(encoding="utf-8")))
    contract["component"] = f"CHAT.INPUT.DARK.V1/{attempt}"
    contract["evidence"] = {
        "provider": "addon/pfUI/modules/chat.lua",
        "adapter": "addon/AzerothExpeditionUI/Modules/Chat.lua",
        "current_runtime_manifest": "assets/source/chat/v3/ChatV3_RuntimeManifest_v1.json",
        "candidate_atlas": display(atlas_path),
        "candidate_layout": display(layout_path),
        "candidate_metrics": display(metrics_path),
        "direction_only": False,
    }
    return contract


def main() -> None:
    args = parse_args()
    raw_path = resolve(args.raw)
    output_dir = resolve(args.output_dir)
    spec = json.loads(resolve(args.simulation_spec).read_text(encoding="utf-8"))
    raw = Image.open(raw_path)
    if raw.size != RAW_SIZE:
        raise ValueError(f"raw canvas must be {RAW_SIZE}, got {raw.size}")

    output_dir.mkdir(parents=True, exist_ok=True)
    normalized_path = output_dir / f"{args.attempt}.normalized-source.png"
    transparent_preview_path = output_dir / f"{args.attempt}.transparent-preview.png"
    atlas_path = output_dir / f"{args.attempt}.logical-atlas.png"
    layout_path = output_dir / f"{args.attempt}.real-layout.png"
    metrics_path = output_dir / f"{args.attempt}.metrics.json"
    contract_path = output_dir / "display-region-contract.json"

    candidate, matte_metrics = derive_candidate_rgba(raw)
    normalized, normalization_metrics = normalize_states(candidate)
    atlas, atlas_metrics = build_atlas(normalized)
    real_layout, layout_metrics, runtime_paths = render_real_layout(spec, atlas)

    save_png(normalized, normalized_path)
    save_png(render_transparent_preview(normalized), transparent_preview_path)
    save_png(atlas, atlas_path)
    save_png(real_layout, layout_path)

    normal_alpha = atlas.crop(ATLAS_BOXES["normal"]).getchannel("A")
    focus_alpha = atlas.crop(ATLAS_BOXES["focus"]).getchannel("A")
    metrics = {
        "schema": "aeui-chat-input-dark-candidate-review-v1",
        "component": "CHAT.INPUT.DARK.V1",
        "attempt": args.attempt,
        "imagegen": args.imagegen_count,
        "session": args.session,
        "execution_commit": args.execution_commit,
        "raw": {
            "path": display(raw_path),
            "sha256": sha256(raw_path),
            "size": list(raw.size),
            "mode": raw.mode,
        },
        "matte": matte_metrics,
        "normalization": normalization_metrics,
        "atlas_contract": {
            **atlas_metrics,
            "boxes": {key: list(value) for key, value in ATLAS_BOXES.items()},
            "provider_cells": {
                key: list(value) for key, value in PROVIDER_CELLS.items()
            },
            "canonical_176px_cells": {
                key: list(value) for key, value in STATE_CELLS.items()
            },
            "focus_cell_resolution": (
                "Authorized focus y=448..625 is 177px under exclusive bounds "
                "while the same contract declares 176px states; canonical crop "
                "uses y=448..624 and leaves the final allowed row transparent."
            ),
            "x_pixels": spec["candidate_atlas"]["x_pixels"],
            "runtime_caps": spec["candidate_atlas"]["runtime_caps"],
            "runtime_height": spec["candidate_atlas"]["runtime_height"],
            "normal_focus_alpha_equal": normal_alpha.tobytes()
            == focus_alpha.tobytes(),
        },
        "outputs": {
            "normalized_source": {
                "path": display(normalized_path),
                "sha256": sha256(normalized_path),
                "size": list(normalized.size),
            },
            "transparent_preview": {
                "path": display(transparent_preview_path),
                "sha256": sha256(transparent_preview_path),
                "size": list(normalized.size),
            },
            "logical_atlas": {
                "path": display(atlas_path),
                "sha256": sha256(atlas_path),
                "size": list(atlas.size),
            },
            "real_layout": {
                "path": display(layout_path),
                "sha256": sha256(layout_path),
                "size": list(real_layout.size),
            },
        },
        "runtime_inputs": {
            key: {"path": display(path), "sha256": sha256(path)}
            for key, path in runtime_paths.items()
        },
        "layout": layout_metrics,
        "authority": {
            "pixel_source": "candidate-self only",
            "normalization": "green-to-alpha, bbox fit, per-pixel minimum shared Alpha, transparent RGB clear",
            "frame_tabs_shelf": "current tracked runtime TGA context",
            "text": "dynamic representative runtime content; never baked into atlas",
            "promotion": "none; review intermediates only",
        },
    }
    metrics_path.write_text(
        json.dumps(metrics, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    contract = make_display_contract(
        resolve(args.display_contract),
        args.attempt,
        atlas_path,
        layout_path,
        metrics_path,
    )
    contract_path.write_text(
        json.dumps(contract, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    for path in (
        normalized_path,
        transparent_preview_path,
        atlas_path,
        layout_path,
        metrics_path,
        contract_path,
    ):
        print(path.resolve())


if __name__ == "__main__":
    main()
