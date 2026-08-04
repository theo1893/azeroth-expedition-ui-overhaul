#!/usr/bin/env python3
"""Render the CHAT.INPUT dark-paper direction at exact runtime geometry.

The proposed input art is deterministic local geometry only. Current tracked
frame, tab, shelf, and one V3 input comparison are used as runtime context;
the proposed pixels must never be promoted to source or addon media.
"""

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
import render_chat_full_frame_runtime_v1 as full_runtime


ROOT = Path(__file__).resolve().parents[1]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--atlas-output", type=Path)
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


def hex_color(rgb: list[int]) -> str:
    return "#%02X%02X%02XFF" % tuple(rgb)


def draw_candidate_strip(
    size: tuple[int, int], palette: dict[str, str]
) -> Image.Image:
    """Draw one state with fixed cap detail and a quiet stretchable center."""

    width, height = size
    if size != (1008, 120):
        raise ValueError(f"candidate strip must be 1008x120, got {size}")
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")

    shadow = [
        (0, 30), (16, 14), (78, 11), (108, 16), (114, 18),
        (924, 18), (944, 13), (992, 19), (1007, 34), (1004, 106),
        (989, 119), (932, 116), (924, 113), (114, 113), (88, 119),
        (15, 115), (0, 103),
    ]
    stack = [
        (0, 27), (15, 12), (76, 9), (108, 14), (114, 17),
        (924, 17), (942, 11), (991, 17), (1007, 31), (1003, 102),
        (989, 115), (933, 112), (924, 109), (114, 109), (90, 115),
        (17, 112), (0, 100),
    ]
    stack_mid = [
        (0, 25), (15, 11), (74, 8), (108, 13), (114, 15),
        (924, 15), (940, 10), (990, 16), (1007, 30), (1003, 96),
        (990, 109), (936, 106), (924, 103), (114, 103), (91, 110),
        (18, 107), (0, 94),
    ]
    paper = [
        (0, 27), (16, 13), (74, 10), (107, 15), (114, 16),
        (924, 16), (940, 12), (988, 18), (1007, 31), (1003, 84),
        (989, 96), (940, 93), (924, 91), (114, 91), (91, 97),
        (18, 94), (0, 83),
    ]
    draw.polygon(shadow, fill=layout.rgba(palette["shadow"]))
    draw.polygon(stack, fill=layout.rgba(palette["page_stack"]))
    draw.polygon(stack_mid, fill=layout.rgba(palette["page_stack_mid"]))
    draw.polygon(paper, fill=layout.rgba(palette["paper"]))

    # Low-frequency paper variation. Draw translucent detail on a separate
    # overlay so it modulates opaque paper instead of punching alpha holes.
    detail = Image.new("RGBA", size, (0, 0, 0, 0))
    detail_draw = ImageDraw.Draw(detail, "RGBA")
    detail_draw.polygon(
        [(170, 34), (238, 25), (369, 29), (420, 47), (392, 69),
         (267, 78), (183, 64)],
        fill=layout.rgba(palette["stain"]),
    )
    detail_draw.polygon(
        [(501, 40), (552, 30), (684, 34), (746, 50), (716, 77),
         (602, 83), (520, 69)],
        fill=layout.rgba(palette["stain"]),
    )
    detail_draw.polygon(
        [(777, 29), (837, 25), (903, 39), (910, 61), (872, 75),
         (802, 68)],
        fill=layout.rgba(palette["stain"]),
    )
    for start, end in (
        ((157, 34), (246, 31)),
        ((310, 56), (411, 58)),
        ((468, 29), (548, 27)),
        ((601, 67), (708, 64)),
        ((766, 43), (850, 46)),
    ):
        detail_draw.line(
            [start, end], fill=layout.rgba(palette["fiber"]), width=2
        )

    # Intermittent deckled edge catches; never a complete rectangular stroke.
    detail_draw.line([(24, 15), (72, 12), (105, 17)], fill=layout.rgba(palette["paper_edge"]), width=3)
    detail_draw.line([(137, 16), (321, 16)], fill=layout.rgba(palette["paper_edge"]), width=2)
    detail_draw.line([(675, 16), (837, 16)], fill=layout.rgba(palette["paper_edge"]), width=2)
    detail_draw.line([(944, 14), (987, 20)], fill=layout.rgba(palette["paper_edge"]), width=3)
    detail_draw.line([(142, 91), (372, 91)], fill=layout.rgba(palette["paper_edge"]), width=2)
    detail_draw.line([(603, 91), (889, 91)], fill=layout.rgba(palette["paper_edge"]), width=2)
    image.alpha_composite(detail)

    # Fixed left cap: a folded paper tongue, not a leather or metal endpoint.
    draw.polygon(
        [(1, 27), (16, 13), (72, 10), (108, 15), (89, 31), (25, 38), (3, 51)],
        fill=layout.rgba(palette["fold"]),
    )

    # Fixed right cap: a small dog-ear and page tuck. No complete metal frame.
    draw.polygon(
        [(925, 16), (988, 18), (1006, 31), (1002, 83), (988, 95), (947, 92),
         (962, 76), (962, 33)],
        fill=layout.rgba(palette["fold"]),
    )
    accents = Image.new("RGBA", size, (0, 0, 0, 0))
    accent_draw = ImageDraw.Draw(accents, "RGBA")
    accent_draw.line(
        [(19, 16), (31, 31), (86, 25), (104, 17)],
        fill=layout.rgba(palette["paper_edge"]),
        width=3,
    )
    accent_draw.line(
        [(11, 46), (38, 48), (89, 39)],
        fill=layout.rgba(palette["short_highlight"]),
        width=3,
    )
    accent_draw.line(
        [(947, 18), (965, 34), (989, 21)],
        fill=layout.rgba(palette["paper_edge"]),
        width=3,
    )
    accent_draw.line(
        [(967, 36), (967, 74), (949, 91)],
        fill=layout.rgba(palette["short_highlight"]),
        width=3,
    )

    # The writing guide is deliberately broken and faded so it cannot read as
    # a progress fill or a modern full-width underline.
    for start, end, y in ((138, 374, 70), (402, 676, 69), (710, 902, 71)):
        accent_draw.line(
            [(start, y), (end, y)],
            fill=layout.rgba(palette["ink"]),
            width=3,
        )
    accent_draw.line([(155, 19), (310, 18)], fill=layout.rgba(palette["short_highlight"]), width=3)
    accent_draw.line([(717, 19), (812, 20)], fill=layout.rgba(palette["short_highlight"]), width=2)
    image.alpha_composite(accents)
    draw.line(
        [(116, 102), (923, 102)],
        fill=layout.rgba(palette["page_stack"]),
        width=3,
    )
    return image


def build_candidate_atlas(spec: dict[str, Any]) -> Image.Image:
    contract = spec["candidate_atlas"]
    atlas = Image.new("RGBA", tuple(contract["size"]), (0, 0, 0, 0))
    strips: list[Image.Image] = []
    for state in ("normal", "focus"):
        strip = draw_candidate_strip((1008, 120), contract["palette"][state])
        strips.append(strip)
    # State feedback may recolor translucent internal strokes, but it must not
    # alter the clickable/visible silhouette. Reuse the normal alpha mask for
    # focus after all color drawing so both rows have byte-identical geometry.
    strips[1].putalpha(strips[0].getchannel("A"))
    if strips[0].getchannel("A").tobytes() != strips[1].getchannel("A").tobytes():
        raise ValueError("normal and focus candidate alpha geometry must be identical")
    atlas.alpha_composite(strips[0], (8, 4))
    atlas.alpha_composite(strips[1], (8, 132))
    return atlas


def build_candidate_input(
    atlas: Image.Image, state: str, width: int, height: int = 25
) -> Image.Image:
    row = 0 if state == "normal" else 1
    source_y = (row * 128, row * 128 + 128)
    source_x = (8, 121, 932, 1016)
    target_x = (0, 28, width - 20, width)
    output = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    for index in range(3):
        patch = atlas.crop(
            (source_x[index], source_y[0], source_x[index + 1], source_y[1])
        ).resize(
            (target_x[index + 1] - target_x[index], height), v3.RESAMPLE
        )
        output.alpha_composite(patch, (target_x[index], 0))
    return output


def add_input_text(
    strip: Image.Image,
    state: str,
    header: str,
    text_value: str,
    font: Any,
    colors: dict[str, str],
) -> dict[str, Any]:
    if not header and not text_value:
        return {"text_box": None, "text_width": 0}
    draw = ImageDraw.Draw(strip, "RGBA")
    x = 34
    y = 12
    if header:
        draw.text(
            (x, y), header, font=font, fill=layout.rgba(colors["header"]), anchor="lm"
        )
        x += int(round(draw.textlength(header, font=font)))
    draw.text(
        (x, y),
        text_value,
        font=font,
        fill=layout.rgba(colors[state]),
        anchor="lm",
    )
    x += int(round(draw.textlength(text_value, font=font)))
    if state == "focus":
        draw.line(
            [(min(x + 2, strip.width - 23), 5), (min(x + 2, strip.width - 23), 20)],
            fill=layout.rgba(colors["cursor"]),
            width=1,
        )
        x += 4
    return {"text_box": [34, 4, min(x, strip.width - 22), 21], "text_width": x - 34}


def validate_hash(path: Path, expected: str, label: str) -> None:
    actual = sha256(path)
    if actual != expected:
        raise ValueError(f"{label} hash mismatch: {actual} != {expected}")


def main() -> None:
    args = parse_args()
    spec = json.loads(args.spec.read_text(encoding="utf-8"))
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
    validate_hash(
        paths["frame"], runtime_manifest["runtime_export"]["sha256"], "frame"
    )
    for key in ("tabs", "tab_shelf", "input"):
        path_key = "shelf" if key == "tab_shelf" else key
        validate_hash(
            paths[path_key], v3_manifest["runtime_exports"][key]["sha256"], key
        )

    frame_atlas = Image.open(paths["frame"]).convert("RGBA")
    tab_atlas = Image.open(paths["tabs"]).convert("RGBA")
    shelf = Image.open(paths["shelf"]).convert("RGBA")
    current_input = Image.open(paths["input"]).convert("RGBA")
    candidate_atlas = build_candidate_atlas(spec)

    palette = {
        key: hex_color(value)
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
            strip = build_candidate_input(
                candidate_atlas, scenario["input_state"], input_width
            )
            text_evidence = add_input_text(
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
        spec["footer"],
        font=note_font,
        fill=layout.rgba("#D7C49AFF"),
        anchor="ms",
    )

    output = args.output or resolve(spec["output"])
    atlas_output = args.atlas_output or resolve(spec["atlas_output"])
    metrics_path = args.metrics or resolve(spec["metrics"])
    output.parent.mkdir(parents=True, exist_ok=True)
    atlas_output.parent.mkdir(parents=True, exist_ok=True)
    metrics_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, format="PNG", optimize=False, compress_level=9)
    candidate_atlas.save(
        atlas_output, format="PNG", optimize=False, compress_level=9
    )

    normal_alpha = candidate_atlas.crop((8, 4, 1016, 124)).getchannel("A")
    focus_alpha = candidate_atlas.crop((8, 132, 1016, 252)).getchannel("A")
    metrics = {
        "schema": "aeui-chat-input-dark-simulation-metrics-v1",
        "version": spec["version"],
        "runtime_contract": spec["runtime_contract"],
        "imagegen": "0/0",
        "uploads": 0,
        "outputs": {
            "game_layout": {
                "path": display(output),
                "sha256": sha256(output),
                "size": list(canvas.size),
                "mode": canvas.mode,
            },
            "logical_atlas": {
                "path": display(atlas_output),
                "sha256": sha256(atlas_output),
                "size": list(candidate_atlas.size),
                "mode": candidate_atlas.mode,
                "normal_focus_alpha_equal": normal_alpha.tobytes()
                == focus_alpha.tobytes(),
                "normal_visible_bbox": list(normal_alpha.getbbox() or ()),
                "focus_visible_bbox": list(focus_alpha.getbbox() or ()),
            },
        },
        "inputs": {
            key: {"path": display(path), "sha256": sha256(path)}
            for key, path in paths.items()
        },
        "contract": {
            "atlas_x_pixels": spec["candidate_atlas"]["x_pixels"],
            "runtime_caps": spec["candidate_atlas"]["runtime_caps"],
            "runtime_height": spec["candidate_atlas"]["runtime_height"],
            "normal_focus_geometry_equal": True,
            "text_insets": [34, 22, 0, 0],
        },
        "layout": evidence,
        "authority": {
            "candidate_input": "deterministic local geometry; direction-only; never source/runtime",
            "frame_tabs_shelf": "current tracked runtime TGA context",
            "current_v3_input": "comparison-only current tracked runtime TGA",
            "text": "dynamic representative content; never baked into candidate atlas",
            "world_backdrop": "non-authoritative geometric context",
        },
    }
    metrics_path.write_text(
        json.dumps(metrics, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(output.resolve())
    print(atlas_output.resolve())
    print(metrics_path.resolve())


if __name__ == "__main__":
    main()
