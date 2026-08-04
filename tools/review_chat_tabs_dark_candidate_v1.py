#!/usr/bin/env python3
"""Review a CHAT.TABS.DARK candidate at source and exact runtime geometry.

This tool never redraws the candidate. It clips the declared production cells,
performs the same deterministic resize/atlas/three-slice assembly intended for
runtime, and places the result over the current tracked chat frame and input UI.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops, ImageDraw

import build_chat_full_frame_v1_runtime as frame_v1
import build_chat_input_dark_v1_runtime as input_v1
import build_chat_v3_runtime_assets as v3
import render_chat_dark_paper_candidate_v1 as layout
import render_chat_input_dark_simulation_v1 as input_layout


ROOT = Path(__file__).resolve().parents[1]
SIM_SPEC = ROOT / "tools/specs/chat_tabs_dark_simulation_v1.json"
SCAFFOLD = (
    ROOT
    / "generated/chat/core/CHAT.TABS.DARK.V1/production-scaffold/CHAT_TABS_DARK_V1_scaffold.png"
)
DISPLAY_CONTRACT = ROOT / "tools/specs/chat_tabs_dark_sim_display_region_v1.json"

CELLS: tuple[tuple[str, tuple[int, int, int, int]], ...] = (
    ("shelf", (64, 96, 1472, 232)),
    ("normal", (64, 560, 384, 716)),
    ("hover", (416, 560, 736, 716)),
    ("selected", (768, 560, 1088, 716)),
    ("disabled", (1120, 560, 1440, 716)),
)
STATE_INDEX = {"normal": 0, "hover": 1, "selected": 2, "disabled": 3}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("candidate", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--attempt", default="attempt-unknown")
    parser.add_argument("--simulation-spec", type=Path, default=SIM_SPEC)
    parser.add_argument("--scaffold", type=Path, default=SCAFFOLD)
    parser.add_argument("--display-contract", type=Path, default=DISPLAY_CONTRACT)
    parser.add_argument("--component", default="CHAT.TABS.DARK.V1")
    return parser.parse_args()


def resolve(path: str | Path) -> Path:
    value = Path(path)
    return value if value.is_absolute() else ROOT / value


def display(path: Path) -> str:
    resolved = path.resolve()
    try:
        return resolved.relative_to(ROOT).as_posix()
    except ValueError:
        return str(resolved)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def visible_count(alpha: Image.Image) -> int:
    histogram = alpha.histogram()
    return sum(histogram[1:])


def alpha_metrics(image: Image.Image) -> dict[str, int]:
    histogram = image.getchannel("A").histogram()
    return {
        "transparent": histogram[0],
        "partial": sum(histogram[1:255]),
        "opaque": histogram[255],
        "visible": sum(histogram[1:]),
    }


def inspect_cells(candidate: Image.Image, scaffold: Image.Image) -> dict[str, Any]:
    alpha = candidate.getchannel("A")
    allowed = Image.new("L", candidate.size, 0)
    allowed_draw = ImageDraw.Draw(allowed)
    cell_reports: list[dict[str, Any]] = []

    for cell_id, box in CELLS:
        x0, y0, x1, y1 = box
        allowed_draw.rectangle((x0, y0, x1 - 1, y1 - 1), fill=255)
        cell_alpha = alpha.crop(box)
        bbox = cell_alpha.getbbox()
        if bbox is None:
            margins = None
            touches = {edge: False for edge in ("left", "top", "right", "bottom")}
        else:
            margins = {
                "left": bbox[0],
                "top": bbox[1],
                "right": cell_alpha.width - bbox[2],
                "bottom": cell_alpha.height - bbox[3],
            }
            touches = {edge: value < 4 for edge, value in margins.items()}
        cell_reports.append(
            {
                "id": cell_id,
                "box": list(box),
                "visible_bbox_local": list(bbox) if bbox else None,
                "visible_pixels": visible_count(cell_alpha),
                "margins": margins,
                "touches_4px_isolation": touches,
            }
        )

    outside_alpha = ImageChops.multiply(alpha, ImageChops.invert(allowed))
    outside_visible = visible_count(outside_alpha)
    scaffold_rgb = scaffold.convert("RGB")
    scaffold_allowed = Image.new("L", scaffold.size, 0)
    scaffold_pixels = scaffold_rgb.load()
    scaffold_mask_pixels = scaffold_allowed.load()
    for y in range(scaffold.height):
        for x in range(scaffold.width):
            if scaffold_pixels[x, y] != (0, 255, 0):
                scaffold_mask_pixels[x, y] = 255
    outside_scaffold_alpha = ImageChops.multiply(
        alpha, ImageChops.invert(scaffold_allowed)
    )
    outside_scaffold_visible = visible_count(outside_scaffold_alpha)
    isolation_failures = [
        item["id"]
        for item in cell_reports
        if not item["visible_bbox_local"]
        or any(item["touches_4px_isolation"].values())
    ]
    return {
        "candidate_visible_bbox": list(alpha.getbbox()) if alpha.getbbox() else None,
        "outside_declared_cells_visible_pixels": outside_visible,
        "outside_scaffold_mask_visible_pixels": outside_scaffold_visible,
        "cells": cell_reports,
        "isolation_failures": isolation_failures,
        "cell_contract_pass": outside_visible == 0 and not isolation_failures,
        "strict_scaffold_mask_pass": outside_scaffold_visible == 0,
    }


def build_review_textures(candidate: Image.Image) -> tuple[Image.Image, Image.Image]:
    cell_images = {cell_id: candidate.crop(box) for cell_id, box in CELLS}
    tab_atlas = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    for state, state_index in STATE_INDEX.items():
        resized = cell_images[state].resize((248, 120), v3.RESAMPLE)
        tab_atlas.alpha_composite(resized, (4, state_index * 128 + 4))

    shelf_atlas = Image.new("RGBA", (1024, 64), (0, 0, 0, 0))
    shelf = cell_images["shelf"].resize((1016, 56), v3.RESAMPLE)
    shelf_atlas.alpha_composite(shelf, (4, 4))
    return tab_atlas, shelf_atlas


def draw_debug(candidate: Image.Image, destination: Path) -> None:
    background = Image.new("RGBA", candidate.size, (26, 22, 18, 255))
    tile = 32
    draw = ImageDraw.Draw(background, "RGBA")
    for y in range(0, candidate.height, tile):
        for x in range(0, candidate.width, tile):
            if ((x // tile) + (y // tile)) % 2:
                draw.rectangle((x, y, x + tile - 1, y + tile - 1), fill=(48, 43, 37, 255))
    background.alpha_composite(candidate)
    draw = ImageDraw.Draw(background, "RGBA")
    for cell_id, (x0, y0, x1, y1) in CELLS:
        draw.rectangle((x0, y0, x1 - 1, y1 - 1), outline=(255, 70, 54, 255), width=3)
        draw.text((x0 + 5, y0 + 5), cell_id, fill=(255, 225, 190, 255))
    background.save(destination, format="PNG", optimize=False, compress_level=9)


def build_candidate_frame(
    frame_atlas: Image.Image,
    input_atlas: Image.Image,
    tab_atlas: Image.Image,
    shelf_atlas: Image.Image,
    direction: dict[str, Any],
    scenario: dict[str, Any],
    fonts: dict[str, Any],
    palette: dict[str, str],
    input_text: dict[str, str],
) -> tuple[Image.Image, dict[str, Any]]:
    frame_size = tuple(scenario["frame_size"])
    book = frame_v1.build_frame(frame_atlas, frame_size)
    shelf_width = frame_size[0] - 60
    book.alpha_composite(
        shelf_atlas.resize((shelf_width, v3.TAB_SHELF_RUNTIME_HEIGHT), v3.RESAMPLE),
        (30, v3.TAB_SHELF_TOP_OFFSET),
    )
    tab_evidence = []
    for index, (label, state) in enumerate(
        zip(direction["tabs"], scenario["states"], strict=True)
    ):
        x = 30 + index * (v3.TAB_RUNTIME_WIDTH + v3.TAB_RUNTIME_GAP)
        tab = v3.build_runtime_tab(tab_atlas, STATE_INDEX[state])
        book.alpha_composite(tab, (x, v3.TAB_RUNTIME_TOP_OFFSET))
        color = (
            "#FFE09EFF"
            if state == "selected"
            else ("#756652FF" if state == "disabled" else "#9F8257FF")
        )
        ImageDraw.Draw(book, "RGBA").text(
            (x + v3.TAB_RUNTIME_WIDTH // 2, 17),
            label,
            font=fonts["tab"],
            fill=layout.rgba(color),
            anchor="mm",
        )
        tab_evidence.append(
            {
                "label": label,
                "state": state,
                "visual_box": [x, 2, x + 92, 32],
                "hit_box": [x, 2, x + 92, 40],
            }
        )

    messages = list(direction["messages"][: scenario["message_count"]])
    messages.extend(scenario.get("extra_messages", []))
    message_evidence = layout.draw_messages(
        book,
        messages,
        palette,
        fonts["body"],
        scenario["maximum_lines"],
        frame_size,
    )
    input_width = frame_size[0] - 60
    input_y = frame_size[1] - 31
    strip = input_v1.build_input(input_atlas, scenario["input_state"], input_width)
    input_evidence = input_layout.add_input_text(
        strip,
        scenario["input_state"],
        scenario.get("input_header", ""),
        scenario.get("input_text", ""),
        fonts["input"],
        input_text,
    )
    book.alpha_composite(strip, (30, input_y))
    return book, {
        "frame": list(frame_size),
        "tabs": tab_evidence,
        "shelf_box": [30, 18, frame_size[0] - 30, 34],
        **message_evidence,
        **input_evidence,
    }


def display_contract(
    attempt: str,
    preview_path: Path,
    metrics_path: Path,
    source_path: Path,
    component: str,
) -> dict[str, Any]:
    base = json.loads(
        source_path.read_text(encoding="utf-8")
    )
    base["component"] = f"{component}/{attempt}/candidate-review"
    base["evidence"] = {
        "provider": "addon/pfUI/modules/chat.lua",
        "adapter": "addon/AzerothExpeditionUI/Modules/Chat.lua",
        "candidate_real_layout": display(preview_path),
        "candidate_metrics": display(metrics_path),
        "direction_only": False,
        "final_runtime": False,
    }
    for scenario in base["scenarios"]:
        if scenario["id"] == "current-v3-440":
            scenario["id"] = "candidate-typical-440"
        elif scenario["id"] == "proposal-four-states-440":
            scenario["id"] = "candidate-four-states-440"
        elif scenario["id"] == "proposal-expanded-540":
            scenario["id"] = "candidate-expanded-540"
    return base


def main() -> None:
    args = parse_args()
    candidate_path = args.candidate.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    candidate = Image.open(candidate_path).convert("RGBA")
    if candidate.size != (1536, 1024):
        raise ValueError(f"candidate must be 1536x1024, got {candidate.size}")
    if candidate.getchannel("A").getextrema()[0] != 0:
        raise ValueError("candidate must contain transparent pixels after chroma cleanup")
    scaffold_path = resolve(args.scaffold)
    scaffold = Image.open(scaffold_path).convert("RGBA")
    if scaffold.size != candidate.size:
        raise ValueError("production scaffold and candidate size mismatch")

    simulation_spec = resolve(args.simulation_spec)
    display_contract_source = resolve(args.display_contract)
    spec = json.loads(simulation_spec.read_text(encoding="utf-8"))
    direction = json.loads(resolve(spec["direction_spec"]).read_text(encoding="utf-8"))
    frame_manifest = json.loads(resolve(spec["frame_runtime_manifest"]).read_text(encoding="utf-8"))
    input_manifest = json.loads(resolve(spec["input_runtime_manifest"]).read_text(encoding="utf-8"))
    frame_path = resolve(spec["runtime_frame_atlas"])
    input_path = resolve(spec["runtime_input_atlas"])
    if sha256(frame_path) != frame_manifest["runtime_export"]["sha256"]:
        raise ValueError("current runtime frame hash mismatch")
    if sha256(input_path) != input_manifest["runtime_export"]["sha256"]:
        raise ValueError("current runtime input hash mismatch")

    tab_atlas, shelf_atlas = build_review_textures(candidate)
    tab_atlas_path = output_dir / "candidate-tab-atlas.png"
    shelf_atlas_path = output_dir / "candidate-tab-shelf.png"
    debug_path = output_dir / "candidate-cell-debug.png"
    preview_path = output_dir / "candidate-real-layout.png"
    metrics_path = output_dir / "candidate-review.metrics.json"
    contract_path = output_dir / "display-region-contract.json"
    tab_atlas.save(tab_atlas_path, format="PNG", optimize=False, compress_level=9)
    shelf_atlas.save(shelf_atlas_path, format="PNG", optimize=False, compress_level=9)
    draw_debug(candidate, debug_path)

    fonts = {
        key: layout.load_font(value["path"], value["size"])
        for key, value in spec["fonts"].items()
    }
    palette = {
        key: "#%02X%02X%02XFF" % tuple(value)
        for key, value in frame_manifest["text_readability"]["palette_rgb"].items()
    }
    theme = next(item for item in direction["themes"] if item["id"] == "B-near-black-paper")
    for role, value in theme["palette"].items():
        palette.setdefault(role, value)

    scenarios = [item for item in spec["scenarios"] if "states" in item]
    if len(scenarios) != 2:
        raise ValueError(f"expected exactly two candidate scenarios, got {len(scenarios)}")
    origins = ((20, 66), (500, 66))
    canvas = Image.new("RGBA", (1060, 510), layout.rgba("#111713FF"))
    layout.draw_world_backdrop(canvas)
    draw = ImageDraw.Draw(canvas, "RGBA")
    evidence: dict[str, Any] = {}
    frame_atlas = Image.open(frame_path).convert("RGBA")
    input_atlas = Image.open(input_path).convert("RGBA")
    for scenario, origin in zip(scenarios, origins, strict=True):
        frame, scenario_evidence = build_candidate_frame(
            frame_atlas,
            input_atlas,
            tab_atlas,
            shelf_atlas,
            direction,
            scenario,
            fonts,
            palette,
            spec["input_text"],
        )
        title = (
            "候选四状态 · 440×320 · 100%"
            if scenario["frame_size"][0] == 440
            else "候选扩展窗口 · 540×420 · 100%"
        )
        draw.text(
            (origin[0] + scenario["frame_size"][0] // 2, 36),
            title,
            font=fonts["label"],
            fill=layout.rgba("#E8D2A8FF"),
            anchor="mm",
        )
        canvas.alpha_composite(frame, origin)
        evidence[scenario["id"]] = {"origin": list(origin), **scenario_evidence}

    draw.text(
        (530, 497),
        f"{args.attempt} · candidate pixels clipped to declared cells; dynamic text is runtime-only",
        font=fonts["note"],
        fill=layout.rgba("#D7C49AFF"),
        anchor="mm",
    )
    canvas.save(preview_path, format="PNG", optimize=False, compress_level=9)

    cell_report = inspect_cells(candidate, scaffold)
    metrics = {
        "schema": "aeui-chat-tabs-dark-candidate-review-v1",
        "attempt": args.attempt,
        "candidate": {
            "path": display(candidate_path),
            "sha256": sha256(candidate_path),
            "size": list(candidate.size),
            "mode": candidate.mode,
            "alpha": alpha_metrics(candidate),
        },
        "cell_contract": cell_report,
        "review_textures": {
            "tab_atlas": {"path": display(tab_atlas_path), "sha256": sha256(tab_atlas_path)},
            "shelf": {"path": display(shelf_atlas_path), "sha256": sha256(shelf_atlas_path)},
            "cell_debug": {"path": display(debug_path), "sha256": sha256(debug_path)},
        },
        "real_layout": {
            "path": display(preview_path),
            "sha256": sha256(preview_path),
            "size": list(canvas.size),
            "runtime_scale": "100%",
            "scenarios": evidence,
        },
        "authority": {
            "candidate": "generated candidate after deterministic chroma cleanup",
            "frame_and_input": "current tracked runtime pixels",
            "dynamic_text": "representative runtime-only content",
            "clipping": "declared production cell bounds; overflow is measured and not silently retained",
            "scaffold_mask": "production scaffold non-green pixels; exact-mask overflow is measured separately from the frozen cell contract",
        },
    }
    metrics_path.write_text(json.dumps(metrics, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    contract_path.write_text(
        json.dumps(
            display_contract(
                args.attempt,
                preview_path,
                metrics_path,
                display_contract_source,
                args.component,
            ),
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(preview_path)
    print(metrics_path)
    print(contract_path)
    print(json.dumps(cell_report, ensure_ascii=False))


if __name__ == "__main__":
    main()
