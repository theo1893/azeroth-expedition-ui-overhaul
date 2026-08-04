#!/usr/bin/env python3
"""Render final CHAT.TABS.DARK.V2 TGA files in the real Chat layout."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw

import build_chat_full_frame_v1_runtime as frame_v1
import build_chat_input_dark_v1_runtime as input_v1
import build_chat_tabs_dark_v2_runtime as tabs_v2
import render_chat_dark_paper_candidate_v1 as layout
import render_chat_input_dark_simulation_v1 as input_layout


ROOT = Path(__file__).resolve().parents[1]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--metrics", type=Path)
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


def validate_hash(path: Path, expected: str, label: str) -> None:
    actual = sha256(path)
    if actual != expected:
        raise ValueError(f"{label} hash mismatch: {actual} != {expected}")


def hex_color(rgb: list[int]) -> str:
    return "#%02X%02X%02XFF" % tuple(rgb)


def tab_width(frame_width: int, count: int) -> int:
    available = frame_width - 60
    maximum = (available - tabs_v2.TAB_RUNTIME_GAP * (count - 1)) / count
    return min(tabs_v2.TAB_RUNTIME_SIZE[0], math.floor(maximum))


def build_runtime_frame(
    frame_atlas: Image.Image,
    input_atlas: Image.Image,
    tab_atlas: Image.Image,
    shelf_atlas: Image.Image,
    direction: dict[str, Any],
    scenario: dict[str, Any],
    fonts: dict[str, Any],
    palette: dict[str, str],
    tab_text: dict[str, str],
    input_text: dict[str, str],
) -> tuple[Image.Image, dict[str, Any]]:
    frame_size = tuple(scenario["frame_size"])
    output = frame_v1.build_frame(frame_atlas, frame_size)
    shelf_width = frame_size[0] - 60
    output.alpha_composite(
        tabs_v2.build_runtime_shelf(shelf_atlas, shelf_width),
        (30, tabs_v2.SHELF_RUNTIME_TOP_OFFSET),
    )

    labels = scenario.get("tabs", direction["tabs"])
    states = scenario["states"]
    if len(labels) != len(states):
        raise ValueError("tab label and state counts differ")
    width = tab_width(frame_size[0], len(labels))
    tab_evidence: list[dict[str, Any]] = []
    draw = ImageDraw.Draw(output, "RGBA")
    x = 30
    for label, state in zip(labels, states, strict=True):
        tab = tabs_v2.build_runtime_tab(tab_atlas, state, width)
        output.alpha_composite(tab, (x, tabs_v2.TAB_RUNTIME_TOP_OFFSET))
        color = tab_text[state]
        draw.text(
            (x + width // 2, 17),
            label,
            font=fonts["tab"],
            fill=layout.rgba(color),
            anchor="mm",
        )
        tab_evidence.append(
            {
                "label": label,
                "state": state,
                "visual_box": [x, 2, x + width, 32],
                "text_safe_box": [x + 6, 8, x + width - 6, 26],
                "hit_box": [x, 2, x + width, 40],
            }
        )
        x += width + tabs_v2.TAB_RUNTIME_GAP

    messages = list(direction["messages"][: scenario["message_count"]])
    messages.extend(scenario.get("extra_messages", []))
    message_evidence = layout.draw_messages(
        output,
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
    output.alpha_composite(strip, (30, input_y))
    return output, {
        "frame": list(frame_size),
        "tab_count": len(labels),
        "tab_width": width,
        "tabs": tab_evidence,
        "shelf_box": [30, 18, frame_size[0] - 30, 34],
        "input_box": [30, input_y, frame_size[0] - 30, input_y + 25],
        **message_evidence,
        **input_evidence,
    }


def main() -> None:
    args = parse_args()
    spec = json.loads(args.spec.read_text(encoding="utf-8"))
    tabs_manifest_path = resolve(spec["tabs_runtime_manifest"])
    frame_manifest_path = resolve(spec["frame_runtime_manifest"])
    input_manifest_path = resolve(spec["input_runtime_manifest"])
    tabs_manifest = json.loads(tabs_manifest_path.read_text(encoding="utf-8"))
    frame_manifest = json.loads(frame_manifest_path.read_text(encoding="utf-8"))
    input_manifest = json.loads(input_manifest_path.read_text(encoding="utf-8"))
    direction = json.loads(resolve(spec["direction_spec"]).read_text(encoding="utf-8"))

    paths = {
        "frame": resolve(spec["runtime_frame_atlas"]),
        "tabs": resolve(spec["runtime_tabs_atlas"]),
        "shelf": resolve(spec["runtime_tab_shelf"]),
        "input": resolve(spec["runtime_input_atlas"]),
    }
    validate_hash(paths["frame"], frame_manifest["runtime_export"]["sha256"], "frame")
    validate_hash(paths["tabs"], tabs_manifest["runtime_exports"]["tabs"]["sha256"], "tabs")
    validate_hash(paths["shelf"], tabs_manifest["runtime_exports"]["shelf"]["sha256"], "shelf")
    validate_hash(paths["input"], input_manifest["runtime_export"]["sha256"], "input")

    frame_atlas = Image.open(paths["frame"]).convert("RGBA")
    tab_atlas = Image.open(paths["tabs"]).convert("RGBA")
    shelf_atlas = Image.open(paths["shelf"]).convert("RGBA")
    input_atlas = Image.open(paths["input"]).convert("RGBA")
    if tab_atlas.size != tabs_v2.TAB_ATLAS_SIZE:
        raise ValueError("final tab TGA size does not match runtime contract")
    if shelf_atlas.size != tabs_v2.SHELF_ATLAS_SIZE:
        raise ValueError("final shelf TGA size does not match runtime contract")

    fonts = {
        key: layout.load_font(value["path"], value["size"])
        for key, value in spec["fonts"].items()
    }
    palette = {
        key: hex_color(value)
        for key, value in frame_manifest["text_readability"]["palette_rgb"].items()
    }
    theme = next(item for item in direction["themes"] if item["id"] == spec["theme_id"])
    for role, value in theme["palette"].items():
        palette.setdefault(role, value)

    canvas = Image.new("RGBA", tuple(spec["canvas"]), layout.rgba("#111713FF"))
    layout.draw_world_backdrop(canvas)
    draw = ImageDraw.Draw(canvas, "RGBA")
    evidence: dict[str, Any] = {}
    for scenario in spec["scenarios"]:
        origin = tuple(scenario["origin"])
        frame, scenario_evidence = build_runtime_frame(
            frame_atlas,
            input_atlas,
            tab_atlas,
            shelf_atlas,
            direction,
            scenario,
            fonts,
            palette,
            spec["tab_text"],
            spec["input_text"],
        )
        draw.text(
            (origin[0] + scenario["frame_size"][0] // 2, origin[1] - 21),
            scenario["label"],
            font=fonts["label"],
            fill=layout.rgba("#E8D2A8FF"),
            anchor="mm",
        )
        canvas.alpha_composite(frame, origin)
        evidence[scenario["id"]] = {
            "origin": list(origin),
            **scenario_evidence,
        }

    draw.text(
        (spec["canvas"][0] // 2, spec["canvas"][1] - 14),
        spec["footer"],
        font=fonts["note"],
        fill=layout.rgba("#D7C49AFF"),
        anchor="ms",
    )

    output = args.output or resolve(spec["output"])
    metrics_path = args.metrics or resolve(spec["metrics"])
    output.parent.mkdir(parents=True, exist_ok=True)
    metrics_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, format="PNG", optimize=False, compress_level=9)
    metrics = {
        "schema": "aeui-chat-tabs-dark-runtime-layout-metrics-v2",
        "version": spec["version"],
        "runtime_contract": tabs_manifest["runtime_contract"],
        "inputs": {
            key: {"file": display(path), "sha256": sha256(path)}
            for key, path in paths.items()
        },
        "manifests": {
            "tabs": display(tabs_manifest_path),
            "frame": display(frame_manifest_path),
            "input": display(input_manifest_path),
        },
        "preview": {
            "file": display(output),
            "sha256": sha256(output),
            "size": list(canvas.size),
            "mode": canvas.mode,
        },
        "contract": {
            "atlas_x_pixels": list(tabs_v2.TAB_ATLAS_X_PIXELS),
            "runtime_caps": list(tabs_v2.TAB_RUNTIME_CAPS),
            "tab_size": list(tabs_v2.TAB_RUNTIME_SIZE),
            "tab_gap": tabs_v2.TAB_RUNTIME_GAP,
            "tab_top_offset": tabs_v2.TAB_RUNTIME_TOP_OFFSET,
            "hit_bottom_extension": tabs_v2.TAB_HIT_BOTTOM_EXTENSION,
            "shelf_height": tabs_v2.SHELF_RUNTIME_HEIGHT,
            "shelf_top_offset": tabs_v2.SHELF_RUNTIME_TOP_OFFSET,
        },
        "layout": evidence,
        "authority": {
            "tabs_and_shelf": "final tracked Dark V2 TGA sampled through adapter-equivalent three-slice and full-shelf geometry",
            "frame_and_input": "current tracked runtime TGA neighbors",
            "text": "representative runtime-only localized content; never baked into atlases",
            "world_backdrop": "non-authoritative geometric context",
        },
    }
    metrics_path.write_text(
        json.dumps(metrics, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(output.resolve())
    print(metrics_path.resolve())


if __name__ == "__main__":
    main()
