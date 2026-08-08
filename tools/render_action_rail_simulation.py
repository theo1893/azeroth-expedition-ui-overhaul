#!/usr/bin/env python3
"""Render the deterministic pre-production simulation for AB.RAIL.V1.

The rendered pixels are direction evidence only.  They are never source art,
runtime media, or an ImageGen input.  Existing AB.SLOT.BASE.V1 runtime pixels
are included read-only as the current neighbouring UI layer.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, ImageFont

import render_action_bars_simulation as core
from review_action_slot_base_candidate_v1 import paste_button, scenario_geometry


DISPLAY_VALIDATOR_SCHEMA = "aeui-display-region-contract-v1"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument("--scene-output", type=Path)
    parser.add_argument("--layouts-output", type=Path)
    parser.add_argument("--layout-report", type=Path)
    parser.add_argument(
        "--write-display-contract",
        action="store_true",
        help="write the derived tracked display-region contract",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def resolve(root: Path, value: str | Path) -> Path:
    path = Path(value)
    return path if path.is_absolute() else root / path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def rgba(value: str, alpha: int | None = None) -> tuple[int, int, int, int]:
    return core.rgba(value, alpha)


def as_slot_scenario(config: dict[str, Any]) -> dict[str, Any]:
    value = dict(config)
    value["local_scale"] = float(config.get("local_scale", config.get("scale", 1.0)))
    return value


def rail_geometry(
    config: dict[str, Any], ui_scale: float, cap_ui: int, ornament_ui: int
) -> dict[str, Any]:
    slot = scenario_geometry(as_slot_scenario(config), ui_scale)
    border_ui = int(config["border_ui"])
    factor = float(slot["factor"])
    bar_width_ui, bar_height_ui = map(int, slot["frame_ui"])

    if config.get("merged_pair"):
        spacing_ui = int(config["spacing_ui"])
        merged_height_ui = bar_height_ui * 2 - spacing_ui
        rail_width_ui = bar_width_ui + border_ui * 2
        rail_height_ui = merged_height_ui + border_ui * 2
        second_row_offset_ui = bar_height_ui - spacing_ui
        button_boxes_ui = button_boxes_for_bar_ui(config, border_ui, 0)
        button_boxes_ui.extend(
            button_boxes_for_bar_ui(config, border_ui, second_row_offset_ui)
        )
    else:
        rail_width_ui = bar_width_ui + border_ui * 2
        rail_height_ui = bar_height_ui + border_ui * 2
        second_row_offset_ui = None
        button_boxes_ui = button_boxes_for_bar_ui(config, border_ui, 0)

    rail_width_px = max(1, round(rail_width_ui * factor))
    rail_height_px = max(1, round(rail_height_ui * factor))
    border_px = max(1, round(border_ui * factor))
    cap_px = max(1, round(cap_ui * factor))
    ornament_px = max(1, round(ornament_ui * factor))
    button_boxes_px = [
        tuple(round(value * factor) for value in box) for box in button_boxes_ui
    ]
    return {
        **slot,
        "bar_frame_ui": [bar_width_ui, bar_height_ui],
        "rail_frame_ui": [rail_width_ui, rail_height_ui],
        "rail_frame_px": [rail_width_px, rail_height_px],
        "border_px": border_px,
        "cap_px": cap_px,
        "ornament_px": ornament_px,
        "button_boxes_ui": [list(box) for box in button_boxes_ui],
        "button_boxes_px": [list(box) for box in button_boxes_px],
        "second_row_offset_ui": second_row_offset_ui,
    }


def button_boxes_for_bar_ui(
    config: dict[str, Any], rail_border_ui: int, y_offset_ui: int
) -> list[tuple[int, int, int, int]]:
    icon_ui = int(config["icon_ui"])
    border_ui = int(config["border_ui"])
    spacing_ui = int(config["spacing_ui"])
    cols = int(config["cols"])
    outer_ui = icon_ui + border_ui * 2
    step_ui = outer_ui + spacing_ui
    boxes: list[tuple[int, int, int, int]] = []
    for index in range(int(config["buttons"])):
        col = index % cols
        row = index // cols
        x0 = rail_border_ui + spacing_ui + col * step_ui
        y0 = rail_border_ui + y_offset_ui + spacing_ui + row * step_ui
        boxes.append((x0, y0, x0 + outer_ui, y0 + outer_ui))
    return boxes


def clipped_outline(width: int, height: int, clip: int) -> list[tuple[int, int]]:
    right = width - 1
    bottom = height - 1
    return [
        (clip, 0),
        (right - clip, 0),
        (right, clip),
        (right, bottom - clip),
        (right - clip, bottom),
        (clip, bottom),
        (0, bottom - clip),
        (0, clip),
    ]


def draw_rail(
    canvas: Image.Image,
    box: tuple[int, int, int, int],
    geometry: dict[str, Any],
    palette: dict[str, str],
) -> None:
    """Draw one quiet rail shell behind all dynamic button layers."""
    x0, y0, x1, y1 = box
    width, height = x1 - x0, y1 - y0
    patch = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(patch, "RGBA")
    cap = min(
        int(geometry["cap_px"]),
        max(1, (min(width, height) - 1) // 2),
    )
    ornament = min(int(geometry["ornament_px"]), cap)
    clip = max(1, min(3, ornament))
    outline = clipped_outline(width, height, clip)

    draw.polygon(outline, fill=rgba(palette["rail_core"]), outline=rgba(palette["rail_contact"]))

    # Broad, deliberately low-frequency value grouping.
    if width > cap * 2 and height > cap * 2:
        draw.rectangle(
            (cap, cap, width - cap - 1, height - cap - 1),
            fill=rgba(palette["rail_center"]),
        )
        # Keep the stretch center quiet and non-directional. Broad rectangular
        # masses survive either-axis stretching without creating a focal slash.
        draw.rectangle(
            (cap, cap, max(cap, width // 2), height - cap - 1),
            fill=rgba(palette["rail_warm"], 10),
        )
        draw.rectangle(
            (max(cap, width * 2 // 3), cap, width - cap - 1, height - cap - 1),
            fill=rgba(palette["rail_pressure"], 16),
        )

    # Oxidized brass is a broken functional edge, never a bright full bezel.
    brass = rgba(palette["rail_brass"], 190)
    warm = rgba(palette["rail_highlight"], 145)
    pressure = rgba(palette["rail_pressure"], 215)
    left_stop = max(clip + 1, min(width - clip - 2, cap * 2))
    top_stop = max(clip + 1, min(height - clip - 2, cap * 2))
    draw.line((left_stop, 1, max(left_stop, width * 2 // 5), 1), fill=brass, width=1)
    draw.line((1, top_stop, 1, max(top_stop, height * 2 // 5)), fill=brass, width=1)
    if width >= 28:
        draw.line((max(left_stop, width // 5), 2, max(left_stop, width // 3), 2), fill=warm, width=1)
    if height >= 28:
        draw.line((2, max(top_stop, height // 5), 2, max(top_stop, height // 3)), fill=warm, width=1)
    draw.line((width - 2, height * 3 // 5, width - 2, height - clip - 1), fill=pressure, width=1)
    draw.line((width * 3 // 5, height - 2, width - clip - 1, height - 2), fill=pressure, width=1)

    # Tiny corner fasteners remain inside the ornament band and disappear on tiny rails.
    if min(width, height) >= 24 and ornament >= 2:
        radius = 1 if min(width, height) < 44 else 2
        centers = (
            (clip + radius + 1, clip + radius + 1),
            (width - clip - radius - 2, clip + radius + 1),
            (clip + radius + 1, height - clip - radius - 2),
            (width - clip - radius - 2, height - clip - radius - 2),
        )
        for cx, cy in centers:
            draw.ellipse(
                (cx - radius, cy - radius, cx + radius, cy + radius),
                fill=rgba(palette["rail_rivet"]),
            )
            draw.point((cx - radius, cy - radius), fill=warm)

    canvas.alpha_composite(patch, (x0, y0))


def scenario_states(config: dict[str, Any], count: int) -> tuple[list[str], list[str]]:
    defaults = [
        "active", "cooldown", "normal", "range", "normal", "pressed",
        "cooldown", "normal", "oom", "equipped", "normal", "empty",
    ]
    keys_default = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "="]
    states = list(config.get("states", []))
    keys = list(config.get("keys", []))
    while len(states) < count:
        states.append(defaults[len(states) % len(defaults)])
    while len(keys) < count:
        keys.append(keys_default[len(keys) % len(keys_default)])
    return states[:count], keys[:count]


def render_scenario(
    config: dict[str, Any],
    geometry: dict[str, Any],
    slot_runtime: Image.Image,
    palette: dict[str, str],
) -> tuple[Image.Image, list[dict[str, list[int]]]]:
    width, height = map(int, geometry["rail_frame_px"])
    image = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw_rail(image, (0, 0, width, height), geometry, palette)
    boxes = [tuple(map(int, box)) for box in geometry["button_boxes_px"]]
    states, keys = scenario_states(config, len(boxes))
    icon_px = max(1, round(int(config["icon_ui"]) * float(geometry["factor"])))
    records: list[dict[str, list[int]]] = []
    for index, box in enumerate(boxes):
        records.append(
            paste_button(
                image,
                slot_runtime,
                box,
                icon_px,
                index,
                states[index],
                keys[index],
            )
        )
    return image, records


def font(root: Path, spec: dict[str, Any], name: str) -> ImageFont.FreeTypeFont:
    return core.load_font(root, spec["fonts"][name])


def draw_scene_annotation(
    draw: ImageDraw.ImageDraw,
    spec: dict[str, Any],
    fonts: dict[str, ImageFont.FreeTypeFont],
) -> None:
    label = spec["scene_annotation"]
    box = tuple(map(int, label["box"]))
    draw.rounded_rectangle(box, radius=8, fill=rgba("#16110d", 218), outline=rgba("#765c39", 220), width=2)
    draw.text((box[0] + 14, box[1] + 10), label["title"], font=fonts["small"], fill=rgba("#ead6a2"))
    draw.text((box[0] + 14, box[1] + 34), label["body"], font=fonts["tiny"], fill=rgba("#c8b995"))


def draw_scene_bar(
    image: Image.Image,
    bar: dict[str, Any],
    ui_scale: float,
    slot_runtime: Image.Image,
    palette: dict[str, str],
    fonts: dict[str, ImageFont.FreeTypeFont],
    cap_ui: int,
    ornament_ui: int,
) -> dict[str, Any]:
    config = dict(bar)
    config["local_scale"] = float(bar.get("scale", 1.0))
    geometry = rail_geometry(config, ui_scale, cap_ui, ornament_ui)
    factor = float(geometry["factor"])
    border_px = int(geometry["border_px"])
    origin_x, origin_y = map(int, bar["screen_origin"])
    rail_width, rail_height = map(int, geometry["rail_frame_px"])
    rail_box = (
        origin_x - border_px,
        origin_y - border_px,
        origin_x - border_px + rail_width,
        origin_y - border_px + rail_height,
    )
    draw_rail(image, rail_box, geometry, palette)

    provider_fallback = str(bar["id"]) in {"AB.BAR11.STANCE", "AB.BAR12.PET"}
    states, keys = scenario_states(bar, int(bar["buttons"]))
    icon_px = max(1, round(int(bar["icon_ui"]) * factor))
    button_boxes: list[list[int]] = []
    for index, local_box in enumerate(geometry["button_boxes_px"]):
        box = tuple(
            value + (origin_x - border_px if axis % 2 == 0 else origin_y - border_px)
            for axis, value in enumerate(map(int, local_box))
        )
        button_boxes.append(list(box))
        if provider_fallback:
            core.draw_slot(
                ImageDraw.Draw(image, "RGBA"),
                box,
                index,
                states[index],
                fonts,
                key=keys[index],
            )
        else:
            paste_button(
                image,
                slot_runtime,
                box,
                icon_px,
                index,
                states[index],
                keys[index],
            )
    return {
        "id": bar["id"],
        "rail_box": list(rail_box),
        "button_boxes": button_boxes,
        "accepted_slot_neighbor": not provider_fallback,
        "provider_fallback": provider_fallback,
    }


def render_scene(
    root: Path,
    spec: dict[str, Any],
    slot_runtime: Image.Image,
    output: Path,
) -> list[dict[str, Any]]:
    base_spec = core.load_spec(resolve(root, spec["base_scene_spec"]).resolve(), root)
    base_spec["annotations"] = spec["scene_base_annotations"]
    canvas = base_spec["canvas"]
    image = Image.new(
        "RGBA",
        (int(canvas["width"]), int(canvas["height"])),
        rgba(canvas["fill"]),
    )
    draw = ImageDraw.Draw(image, "RGBA")
    fonts = {
        name: core.load_font(root, definition)
        for name, definition in base_spec["fonts"].items()
    }
    palette = {**base_spec["palette"], **spec["palette"]}
    ui_scale = float(spec["target"]["ui_scale"])
    rail = spec["rail_contract"]

    core.draw_scene(image, draw, palette)
    core.draw_placeholder_ui_v2(draw, fonts, palette, base_spec)
    records = [
        draw_scene_bar(
            image,
            bar,
            ui_scale,
            slot_runtime,
            palette,
            fonts,
            int(rail["runtime_cap_ui"]),
            int(rail["ornament_edge_ui"]),
        )
        for bar in base_spec["bars"]
    ]
    core.draw_pouch(draw, base_spec["consumables"], ui_scale, fonts, palette)
    core.draw_trinkets(draw, base_spec["trinkets"], ui_scale, fonts, palette)

    main = base_spec["bars"][0]
    mx, my, mw, mh, _, _, _ = core.bar_geometry(main, ui_scale)
    draw.rectangle((mx, my + mh + 6, mx + mw, my + mh + 12), fill=rgba("#24170f"), outline=rgba("#80623d"), width=1)
    draw.rectangle((mx + 2, my + mh + 8, mx + int(mw * 0.64), my + mh + 10), fill=rgba("#756343"))
    draw_scene_annotation(draw, spec, fonts)

    output.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(output, format="PNG", optimize=False, compress_level=9)
    return records


def composite_with_checker(board: Image.Image, item: Image.Image, origin: tuple[int, int]) -> None:
    x, y = origin
    checker = Image.new("RGBA", item.size, rgba("#171b18"))
    check = ImageDraw.Draw(checker, "RGBA")
    for cy in range(0, item.height, 8):
        for cx in range(0, item.width, 8):
            if (cx // 8 + cy // 8) % 2:
                check.rectangle((cx, cy, min(item.width - 1, cx + 7), min(item.height - 1, cy + 7)), fill=rgba("#20251f"))
    checker.alpha_composite(item)
    board.alpha_composite(checker, (x, y))


def render_layout_board(
    root: Path,
    spec: dict[str, Any],
    slot_runtime: Image.Image,
    output: Path,
) -> list[dict[str, Any]]:
    board_spec = spec["layout_board"]
    board = Image.new("RGBA", tuple(map(int, board_spec["size"])), rgba(board_spec["fill"]))
    draw = ImageDraw.Draw(board, "RGBA")
    fonts = {name: font(root, spec, name) for name in spec["fonts"]}
    palette = spec["palette"]
    ui_scale = float(spec["target"]["ui_scale"])
    cap_ui = int(spec["rail_contract"]["runtime_cap_ui"])
    ornament_ui = int(spec["rail_contract"]["ornament_edge_ui"])

    draw.text((38, 26), "AB.RAIL.V1 · 自适应承托轨本地模拟", font=fonts["title"], fill=rgba("#ecd7a2"))
    draw.text(
        (38, 68),
        "全部实例按目标设备物理像素绘制；accepted AB.SLOT 只作为当前相邻 runtime。ImageGen 0/0。",
        font=fonts["small"],
        fill=rgba("#bcb49d"),
    )

    records: list[dict[str, Any]] = []
    for config in spec["scenarios"]:
        geometry = rail_geometry(config, ui_scale, cap_ui, ornament_ui)
        preview, buttons = render_scenario(config, geometry, slot_runtime, palette)
        x, y = map(int, config["board_origin"])
        draw.text(
            (x, y - 44),
            config["label"],
            font=fonts["small"],
            fill=rgba("#e4d2a7"),
        )
        draw.text(
            (x, y - 21),
            f"rail={preview.width}×{preview.height}px · bar={geometry['bar_frame_ui'][0]}×{geometry['bar_frame_ui'][1]} UI · scale={geometry['factor'] / ui_scale:.2f}",
            font=fonts["tiny"],
            fill=rgba("#9fa99d"),
        )
        composite_with_checker(board, preview, (x, y))

        zoom = int(config.get("inspection_zoom", 1))
        if zoom > 1:
            enlarged = preview.resize(
                (preview.width * zoom, preview.height * zoom),
                Image.Resampling.NEAREST,
            )
            zx, zy = map(int, config["inspection_origin"])
            composite_with_checker(board, enlarged, (zx, zy))
            draw.text(
                (zx, zy + enlarged.height + 5),
                f"{zoom}× 检查视图（非实际尺寸）",
                font=fonts["tiny"],
                fill=rgba("#8f988d"),
            )

        boxes = [tuple(item["backdrop"]) for item in buttons]
        ornament = int(geometry["ornament_px"])
        width, height = map(int, geometry["rail_frame_px"])
        ornaments = [
            (0, 0, ornament, ornament),
            (width - ornament, 0, width, ornament),
            (0, height - ornament, ornament, height),
            (width - ornament, height - ornament, width, height),
        ]
        overlaps = [
            [button_index, ornament_index]
            for button_index, button in enumerate(boxes, start=1)
            for ornament_index, corner in enumerate(ornaments, start=1)
            if boxes_overlap(button, corner)
        ]
        center = [width - 2 * int(geometry["cap_px"]), height - 2 * int(geometry["cap_px"])]
        records.append(
            {
                "id": config["id"],
                "bar_frame_ui": geometry["bar_frame_ui"],
                "rail_frame_ui": geometry["rail_frame_ui"],
                "rail_frame_px": geometry["rail_frame_px"],
                "cap_px": geometry["cap_px"],
                "center_px": center,
                "buttons": len(buttons),
                "ornament_button_overlaps": overlaps,
                "button_regions_contained": all(
                    0 <= box[0] < box[2] <= width and 0 <= box[1] < box[3] <= height
                    for box in boxes
                ),
                "layer_order": ["AB.RAIL", "AB.SLOT/current-neighbor", "provider dynamic icon/text/state"],
            }
        )

    # Enlarged rail-only material/layer explanation. This is deliberately not a source layout.
    study_box = tuple(map(int, board_spec["rail_study_box"]))
    study_geometry = {
        "cap_px": 28,
        "ornament_px": 10,
    }
    draw_rail(board, study_box, study_geometry, palette)
    sx0, sy0, sx1, sy1 = study_box
    draw.text((sx0, sy0 - 44), "材质与层级示意（放大、非 source、非 runtime）", font=fonts["small"], fill=rgba("#e4d2a7"))
    draw.text((sx0, sy0 - 21), "深胡桃褐核心 · 断续暗黄铜外缘 · 四角极少铆钉 · 中心安静可拉伸", font=fonts["tiny"], fill=rgba("#9fa99d"))
    draw.text((sx0 + 12, sy1 + 8), "Rail 在最底层；不包含格线、图标、文字或交互状态", font=fonts["tiny"], fill=rgba("#9fa99d"))

    output.parent.mkdir(parents=True, exist_ok=True)
    board.convert("RGB").save(output, format="PNG", optimize=False, compress_level=9)
    return records


def boxes_overlap(left: tuple[int, int, int, int], right: tuple[int, int, int, int]) -> bool:
    return max(left[0], right[0]) < min(left[2], right[2]) and max(left[1], right[1]) < min(left[3], right[3])


def build_display_contract(spec: dict[str, Any]) -> dict[str, Any]:
    rail = spec["rail_contract"]
    cap = int(rail["runtime_cap_ui"])
    ornament = int(rail["ornament_edge_ui"])
    atlas_size = int(rail["source_object_size"])
    source_cap = int(rail["source_cap_px"])
    center_end = atlas_size - source_cap
    samples = []
    names = ("left", "center", "right")
    bounds = (0, source_cap, center_end, atlas_size)
    for row in range(3):
        for col in range(3):
            samples.append(
                {
                    "id": f"planned.{names[row]}-{names[col]}",
                    "box": [bounds[col], bounds[row], bounds[col + 1], bounds[row + 1]],
                }
            )

    scenarios: list[dict[str, Any]] = []
    for config in spec["scenarios"]:
        border = int(config["border_ui"])
        geometry = rail_geometry(config, 1.0, cap, ornament)
        width, height = map(int, geometry["rail_frame_ui"])
        zones: dict[str, list[int]] = {"rail-target": [0, 0, width, height]}
        regions: list[dict[str, Any]] = []
        corner_boxes = [
            [0, 0, ornament, ornament],
            [width - ornament, 0, width, ornament],
            [0, height - ornament, ornament, height],
            [width - ornament, height - ornament, width, height],
        ]
        for index, box in enumerate(corner_boxes, start=1):
            zone = f"corner-{index}.ornament-safe"
            zones[zone] = box
            regions.append({"id": f"corner-{index}.ornament", "kind": "decoration", "box": box, "zone": zone})
        for index, box in enumerate(geometry["button_boxes_ui"], start=1):
            backdrop_zone = f"button-{index}.backdrop-safe"
            hit_zone = f"button-{index}.hit-safe"
            hit = [box[0] + border, box[1] + border, box[2] - border, box[3] - border]
            zones[backdrop_zone] = box
            zones[hit_zone] = hit
            regions.extend(
                [
                    {"id": f"button-{index}.backdrop", "kind": "texture", "box": box, "zone": backdrop_zone},
                    {"id": f"button-{index}.hit", "kind": "button", "box": hit, "zone": hit_zone},
                ]
            )
        scenarios.append(
            {
                "id": config["id"],
                "frame": [width, height],
                "preview_frame": [width, height],
                "zones": zones,
                "regions": regions,
            }
        )

    return {
        "schema": DISPLAY_VALIDATOR_SCHEMA,
        "component": "AB.RAIL.V1/simulation-v1",
        "coordinate_system": "top-left-origin, right-bottom-exclusive, pfUI UI units before UIParent and movable scale",
        "evidence": {
            "provider": "addon/pfUI/api/api.lua BarLayoutSize + BarButtonAnchor + CreateBackdrop; addon/pfUI/modules/actionbar.lua",
            "layout_formula": "bar=(icon+2*border+spacing)*cols+spacing; rail target is the bar backdrop and therefore adds border on all four sides; merged bar1+bar6 spans two equal bar frames minus their anchored spacing and adds one outer backdrop",
            "simulation_spec": spec["self_path"],
            "scene_simulation": spec["outputs"]["scene"],
            "layout_simulation": spec["outputs"]["layouts"],
            "target": "1920x1080; UI scale 0.81269841269841; physical preview also applies each movable local scale",
            "atlas_role": "planned 704x704 crop of a future single square stretch master; nine logical slices only; no source or runtime asset exists",
            "dynamic_ownership": "icons, slots, keybinds, counts, cooldowns, range, OOM, pressed feedback, paging, drag, scale, visibility and hit regions remain provider-owned",
            "final_runtime": False,
        },
        "atlas": {
            "size": [atlas_size, atlas_size],
            "visible_bbox": [0, 0, atlas_size, atlas_size],
            "require_exact_visible_coverage": True,
            "sampled_regions": samples,
        },
        "nine_slice": {
            "caps": {"left": cap, "right": cap, "top": cap, "bottom": cap},
            "minimum_frame_size": [cap * 2 + 1, cap * 2 + 1],
        },
        "scenarios": scenarios,
    }


def build_report(
    root: Path,
    spec_path: Path,
    spec: dict[str, Any],
    slot_path: Path,
    scene_path: Path,
    layouts_path: Path,
    scene_records: list[dict[str, Any]],
    layout_records: list[dict[str, Any]],
) -> dict[str, Any]:
    checks: list[dict[str, Any]] = []

    def check(identifier: str, passed: bool, **evidence: Any) -> None:
        checks.append({"id": identifier, "pass": bool(passed), **evidence})

    expected_slot_sha = spec["accepted_neighbor"]["sha256"]
    actual_slot_sha = sha256(slot_path)
    check("accepted-slot.sha256", actual_slot_sha == expected_slot_sha, expected=expected_slot_sha, actual=actual_slot_sha)
    check("simulation.imagegen-zero", spec["imagegen"] == {"used": 0, "limit": 0}, value=spec["imagegen"])
    check("scene.resolution", Image.open(scene_path).size == tuple(spec["target"]["resolution"]), actual=list(Image.open(scene_path).size))
    for record in layout_records:
        check(f"{record['id']}.positive-nine-slice-center", min(record["center_px"]) >= 1, center_px=record["center_px"])
        check(f"{record['id']}.buttons-contained", record["button_regions_contained"], frame_px=record["rail_frame_px"])
        check(f"{record['id']}.ornaments-clear-buttons", not record["ornament_button_overlaps"], overlaps=record["ornament_button_overlaps"])
        check(f"{record['id']}.layer-order", record["layer_order"][0] == "AB.RAIL", layer_order=record["layer_order"])
    check("scene.current-slot-neighbor", any(item["accepted_slot_neighbor"] for item in scene_records), bars=[item["id"] for item in scene_records if item["accepted_slot_neighbor"]])
    check("scene.stance-provider-fallback", any(item["provider_fallback"] for item in scene_records), bars=[item["id"] for item in scene_records if item["provider_fallback"]])
    violations = [item["id"] for item in checks if not item["pass"]]
    return {
        "schema": "aeui-action-rail-simulation-report-v1",
        "version": spec["version"],
        "status": "pass" if not violations else "fail",
        "specification": {"path": spec["self_path"], "sha256": sha256(spec_path)},
        "renderer": {"path": "tools/render_action_rail_simulation.py", "sha256": sha256(Path(__file__).resolve())},
        "accepted_neighbor": {"path": spec["accepted_neighbor"]["path"], "sha256": actual_slot_sha, "role": "read-only current runtime context; lower authority than locked Character V3"},
        "outputs": {
            "scene": {"path": spec["outputs"]["scene"], "sha256": sha256(scene_path)},
            "layouts": {"path": spec["outputs"]["layouts"], "sha256": sha256(layouts_path)},
        },
        "imagegen": {"used": 0, "limit": 0},
        "scenario_count": len(layout_records),
        "scenarios": layout_records,
        "checks": checks,
        "violations": violations,
        "first_failure": violations[0] if violations else None,
        "non_production": True,
    }


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    spec_path = args.spec.resolve()
    spec = load_json(spec_path)
    slot_path = resolve(root, spec["accepted_neighbor"]["path"])
    with Image.open(slot_path) as opened:
        slot_runtime = opened.convert("RGBA")

    scene_path = args.scene_output or resolve(root, spec["outputs"]["scene"])
    layouts_path = args.layouts_output or resolve(root, spec["outputs"]["layouts"])
    report_path = args.layout_report or resolve(root, spec["outputs"]["layout_report"])
    display_path = resolve(root, spec["display_contract"])

    scene_records = render_scene(root, spec, slot_runtime, scene_path)
    layout_records = render_layout_board(root, spec, slot_runtime, layouts_path)
    derived_contract = build_display_contract(spec)
    if args.write_display_contract:
        write_json(display_path, derived_contract)
    elif not display_path.is_file():
        raise FileNotFoundError("tracked display contract is missing; rerun once with --write-display-contract")
    elif load_json(display_path) != derived_contract:
        raise ValueError("tracked display contract differs from the simulation specification")

    report = build_report(
        root,
        spec_path,
        spec,
        slot_path,
        scene_path,
        layouts_path,
        scene_records,
        layout_records,
    )
    write_json(report_path, report)
    print(scene_path.resolve())
    print(layouts_path.resolve())
    print(report_path.resolve())
    if report["status"] != "pass":
        raise SystemExit(1)


if __name__ == "__main__":
    main()
