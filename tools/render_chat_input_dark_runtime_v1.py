#!/usr/bin/env python3
"""Render final CHAT.INPUT.DARK.V1 TGA in the real Chat layout."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw

import build_chat_full_frame_v1_runtime as frame_v1
import build_chat_input_dark_v1_runtime as input_v1
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


def main() -> None:
    args = parse_args()
    spec = json.loads(args.spec.read_text(encoding="utf-8"))
    input_manifest_path = resolve(spec["input_runtime_manifest"])
    frame_manifest_path = resolve(spec["frame_runtime_manifest"])
    v3_manifest_path = resolve(spec["v3_manifest"])
    input_manifest = json.loads(input_manifest_path.read_text(encoding="utf-8"))
    frame_manifest = json.loads(frame_manifest_path.read_text(encoding="utf-8"))
    v3_manifest = json.loads(v3_manifest_path.read_text(encoding="utf-8"))
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
    validate_hash(
        paths["frame"], frame_manifest["runtime_export"]["sha256"], "frame"
    )
    validate_hash(
        paths["tabs"], v3_manifest["runtime_exports"]["tabs"]["sha256"], "tabs"
    )
    validate_hash(
        paths["shelf"],
        v3_manifest["runtime_exports"]["tab_shelf"]["sha256"],
        "shelf",
    )
    validate_hash(
        paths["input"], input_manifest["runtime_export"]["sha256"], "input"
    )

    frame_atlas = Image.open(paths["frame"]).convert("RGBA")
    tab_atlas = Image.open(paths["tabs"]).convert("RGBA")
    shelf = Image.open(paths["shelf"]).convert("RGBA")
    input_atlas = Image.open(paths["input"]).convert("RGBA")
    if input_atlas.size != input_v1.ATLAS_SIZE:
        raise ValueError("final input TGA size does not match runtime contract")
    normal_alpha = input_atlas.crop(input_v1.ATLAS_BOXES["normal"]).getchannel("A")
    focus_alpha = input_atlas.crop(input_v1.ATLAS_BOXES["focus"]).getchannel("A")
    if normal_alpha.tobytes() != focus_alpha.tobytes():
        raise ValueError("final input TGA state Alpha differs")

    palette = {
        key: hex_color(value)
        for key, value in frame_manifest["text_readability"]["palette_rgb"].items()
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
        strip = input_v1.build_input(
            input_atlas, scenario["input_state"], input_width
        )
        text_evidence = input_layout.add_input_text(
            strip,
            scenario["input_state"],
            scenario.get("input_header", ""),
            scenario.get("input_text", ""),
            input_font,
            spec["input_text"],
        )
        assembled.alpha_composite(strip, (30, input_y))
        canvas.alpha_composite(assembled, origin)
        evidence[scenario["id"]] = {
            "frame": list(frame_size),
            "origin": list(origin),
            "input_state": scenario["input_state"],
            "input_box": [30, input_y, frame_size[0] - 30, input_y + 25],
            "input_text_safe_box": [64, input_y, frame_size[0] - 52, input_y + 25],
            **text_evidence,
            **message_layout,
        }

    draw.text(
        (spec["canvas"][0] // 2, spec["canvas"][1] - 14),
        spec["footer"],
        font=note_font,
        fill=layout.rgba("#D7C49AFF"),
        anchor="ms",
    )

    output = args.output or resolve(spec["output"])
    metrics_path = args.metrics or resolve(spec["metrics"])
    output.parent.mkdir(parents=True, exist_ok=True)
    metrics_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, format="PNG", optimize=False, compress_level=9)

    metrics = {
        "schema": "aeui-chat-input-dark-runtime-layout-metrics-v1",
        "version": spec["version"],
        "runtime_contract": input_manifest["runtime_contract"],
        "inputs": {
            key: {"path": display(path), "sha256": sha256(path)}
            for key, path in paths.items()
        },
        "manifests": {
            "input": display(input_manifest_path),
            "frame": display(frame_manifest_path),
            "v3_neighbors": display(v3_manifest_path),
        },
        "preview": {
            "path": display(output),
            "sha256": sha256(output),
            "size": list(canvas.size),
            "mode": canvas.mode,
        },
        "contract": {
            "atlas_x_pixels": list(input_v1.ATLAS_X_PIXELS),
            "runtime_caps": list(input_v1.RUNTIME_CAPS),
            "runtime_height": input_v1.RUNTIME_HEIGHT,
            "text_insets": list(input_v1.TEXT_INSETS),
            "normal_focus_alpha_equal": True,
        },
        "layout": evidence,
        "authority": {
            "input": "final tracked ChatInputDarkV1.tga sampled through adapter three-slice UV",
            "frame_tabs_shelf": "current tracked runtime TGA neighbors",
            "text": "dynamic representative runtime content; never baked into atlas",
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
