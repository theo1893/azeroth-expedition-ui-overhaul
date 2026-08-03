#!/usr/bin/env python3
"""Render the final CHAT.FRAME.FULL.V1 TGA with real Chat runtime neighbors."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw

import build_chat_full_frame_v1_runtime as frame_v1
import build_chat_v3_runtime_assets as v3
import render_chat_dark_paper_candidate_v1 as layout


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


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def hex_color(rgb: list[int]) -> str:
    return "#%02X%02X%02XFF" % tuple(rgb)


def build_input(
    atlas: Image.Image,
    state: str,
    width: int,
    height: int = 25,
) -> Image.Image:
    row = 0 if state == "normal" else 1
    source_y = (row * 128, row * 128 + 128)
    source_x = v3.INPUT_ATLAS_X_PIXELS
    target_x = (0, 28, width - 20, width)
    output = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    for index in range(3):
        patch = atlas.crop(
            (
                source_x[index],
                source_y[0],
                source_x[index + 1],
                source_y[1],
            )
        ).resize(
            (target_x[index + 1] - target_x[index], height),
            v3.RESAMPLE,
        )
        output.alpha_composite(patch, (target_x[index], 0))
    return output


def main() -> None:
    args = parse_args()
    spec = json.loads(args.spec.read_text(encoding="utf-8"))
    manifest_path = resolve(spec["runtime_manifest"])
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    direction = json.loads(
        resolve(spec["direction_spec"]).read_text(encoding="utf-8")
    )

    frame_path = resolve(spec["runtime_frame_atlas"])
    tabs_path = resolve(spec["runtime_tabs_atlas"])
    shelf_path = resolve(spec["runtime_tab_shelf"])
    input_path = resolve(spec["runtime_input_atlas"])
    frame_atlas = Image.open(frame_path).convert("RGBA")
    tab_atlas = Image.open(tabs_path).convert("RGBA")
    shelf = Image.open(shelf_path).convert("RGBA")
    input_atlas = Image.open(input_path).convert("RGBA")

    expected_runtime = manifest["runtime_export"]
    if sha256(frame_path) != expected_runtime["sha256"]:
        raise ValueError("runtime frame hash does not match its manifest")
    if list(frame_atlas.size) != [
        expected_runtime["width"],
        expected_runtime["height"],
    ]:
        raise ValueError("runtime frame size does not match its manifest")

    palette = {
        key: hex_color(value)
        for key, value in manifest["text_readability"]["palette_rgb"].items()
    }
    # Representative inline roles use the exact accepted dark-paper direction.
    theme = next(
        item for item in direction["themes"] if item["id"] == spec["theme_id"]
    )
    for role, value in theme["palette"].items():
        if role not in palette:
            palette[role] = value

    body_font = layout.load_font(
        spec["fonts"]["body"]["path"], spec["fonts"]["body"]["size"]
    )
    tab_font = layout.load_font(
        spec["fonts"]["tab"]["path"], spec["fonts"]["tab"]["size"]
    )
    label_font = layout.load_font(
        spec["fonts"]["label"]["path"], spec["fonts"]["label"]["size"]
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
        input_state = scenario.get("input_state")
        input_box = None
        if input_state:
            input_width = frame_size[0] - 60
            input_y = frame_size[1] - 31
            assembled.alpha_composite(
                build_input(input_atlas, input_state, input_width),
                (30, input_y),
            )
            input_box = [30, input_y, frame_size[0] - 30, input_y + 25]

        canvas.alpha_composite(assembled, origin)
        evidence[scenario["id"]] = {
            "frame": list(frame_size),
            "origin": list(origin),
            "selected_tab": scenario["selected_tab"],
            "message_count": len(messages),
            "input_state": input_state,
            "input_box": input_box,
            **message_layout,
        }

    output = args.output or resolve(spec["output"])
    metrics_path = args.metrics or resolve(spec["metrics"])
    output.parent.mkdir(parents=True, exist_ok=True)
    metrics_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, format="PNG", optimize=False, compress_level=9)

    metrics = {
        "schema": "aeui-chat-frame-runtime-layout-metrics-v1",
        "version": spec["version"],
        "runtime_contract": manifest["runtime_contract"],
        "inputs": {
            "frame": {"path": display(frame_path), "sha256": sha256(frame_path)},
            "tabs": {"path": display(tabs_path), "sha256": sha256(tabs_path)},
            "shelf": {"path": display(shelf_path), "sha256": sha256(shelf_path)},
            "input": {"path": display(input_path), "sha256": sha256(input_path)},
            "manifest": display(manifest_path),
        },
        "preview": {
            "path": display(output),
            "sha256": sha256(output),
            "size": list(canvas.size),
            "mode": canvas.mode,
        },
        "authority": {
            "frame": "final tracked runtime TGA sampled through adapter nine-slice UV",
            "tabs_shelf_input": "current tracked V3 runtime TGA neighbors",
            "text": "manifest palette with representative dynamic content",
            "world_backdrop": "non-authoritative geometric context",
        },
        "layout": evidence,
    }
    metrics_path.write_text(
        json.dumps(metrics, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(output.resolve())
    print(metrics_path.resolve())


def display(path: Path) -> str:
    try:
        return path.resolve().relative_to(ROOT).as_posix()
    except ValueError:
        return str(path.resolve())


if __name__ == "__main__":
    main()
