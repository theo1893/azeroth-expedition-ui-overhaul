#!/usr/bin/env python3
"""Build deterministic AB.SLOT candidate metrics and exact runtime previews.

All derived pixels are review-only.  The script never promotes a candidate to
assets/source or addon runtime, and representative icons/text remain dynamic
preview content rather than candidate pixels.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import statistics
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont, ImageOps, ImageStat


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw", required=True, type=Path)
    parser.add_argument("--transparent", required=True, type=Path)
    parser.add_argument("--spec", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--attempt", default="attempt-01")
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    return parser.parse_args()


def resolve(root: Path, path: Path | str) -> Path:
    candidate = Path(path)
    return candidate if candidate.is_absolute() else root / candidate


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def merge_specs(base: dict[str, Any], override: dict[str, Any]) -> dict[str, Any]:
    merged = dict(base)
    for key, value in override.items():
        if isinstance(value, dict) and isinstance(merged.get(key), dict):
            merged[key] = merge_specs(merged[key], value)
        else:
            merged[key] = value
    return merged


def load_extended_spec(path: Path, root: Path) -> dict[str, Any]:
    data = load_json(path)
    base_ref = data.pop("extends", None)
    if not base_ref:
        return data
    return merge_specs(load_extended_spec(resolve(root, base_ref), root), data)


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("transparent candidate has no visible pixels")
    return bbox


def square_crop_box(
    bbox: tuple[int, int, int, int], canvas: tuple[int, int]
) -> tuple[int, int, int, int]:
    x0, y0, x1, y1 = bbox
    width, height = x1 - x0, y1 - y0
    side = max(width, height)
    center_x = (x0 + x1) / 2
    center_y = (y0 + y1) / 2
    left = round(center_x - side / 2)
    top = round(center_y - side / 2)
    left = min(max(0, left), canvas[0] - side)
    top = min(max(0, top), canvas[1] - side)
    return left, top, left + side, top + side


def normalized_box(
    bbox: tuple[int, int, int, int], size: tuple[int, int], target: int = 1024
) -> list[int]:
    return [
        round(bbox[0] * target / size[0]),
        round(bbox[1] * target / size[1]),
        round(bbox[2] * target / size[0]),
        round(bbox[3] * target / size[1]),
    ]


def background_metrics(raw: Image.Image, transparent: Image.Image) -> dict[str, Any]:
    alpha = transparent.getchannel("A")
    raw_bytes = raw.convert("RGB").tobytes()
    alpha_bytes = alpha.tobytes()
    background = [
        (raw_bytes[index * 3], raw_bytes[index * 3 + 1], raw_bytes[index * 3 + 2])
        for index, value in enumerate(alpha_bytes)
        if value == 0
    ]
    exact = sum(1 for pixel in background if pixel == (0, 255, 0))
    sample = background[:: max(1, len(background) // 100_000)] if background else []
    median = [round(statistics.median(pixel[channel] for pixel in sample)) for channel in range(3)] if sample else []
    return {
        "transparent_background_pixels": len(background),
        "exact_00ff00_pixels": exact,
        "exact_fraction": exact / len(background) if background else 0.0,
        "sampled_median_rgb": median,
        "sampled_median_hex": "#" + "".join(f"{value:02x}" for value in median) if median else None,
        "pixel_level_exact_background": bool(background) and exact == len(background),
    }


def quiet_zone_metrics(raw: Image.Image) -> dict[str, Any]:
    normalized = raw.convert("RGB").resize((1024, 1024), Image.Resampling.LANCZOS)
    quiet = normalized.crop((232, 232, 792, 792))
    gray = ImageOps.grayscale(quiet)
    blurred = gray.filter(ImageFilter.GaussianBlur(2.0))
    high_frequency = ImageChops.difference(gray, blurred)
    return {
        "normalized_zone": [232, 232, 792, 792],
        "luma_stddev": round(ImageStat.Stat(gray).stddev[0], 4),
        "high_frequency_mean": round(ImageStat.Stat(high_frequency).mean[0], 4),
        "luma_extrema": list(gray.getextrema()),
        "note": "numeric evidence only; the hand-painted quiet-zone verdict remains visual",
    }


def make_runtime_master(
    transparent: Image.Image, output: Path
) -> tuple[Image.Image, tuple[int, int, int, int], tuple[int, int, int, int]]:
    visible = alpha_bbox(transparent)
    crop_box = square_crop_box(visible, transparent.size)
    crop = transparent.crop(crop_box)
    runtime = crop.resize((128, 128), Image.Resampling.LANCZOS)
    runtime.save(output)
    return runtime, visible, crop_box


def icon_palette(index: int) -> tuple[tuple[int, int, int, int], tuple[int, int, int, int]]:
    palettes = (
        ((55, 83, 54, 255), (192, 163, 80, 255)),
        ((70, 53, 93, 255), (166, 120, 207, 255)),
        ((75, 45, 36, 255), (208, 113, 65, 255)),
        ((37, 71, 84, 255), (99, 178, 194, 255)),
        ((83, 69, 37, 255), (213, 185, 78, 255)),
        ((48, 57, 76, 255), (135, 151, 205, 255)),
    )
    return palettes[index % len(palettes)]


def dynamic_icon(size: int, index: int, state: str) -> Image.Image:
    size = max(1, size)
    image = Image.new("RGBA", (size, size), (0, 0, 0, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    dark, light = icon_palette(index)
    for y in range(size):
        ratio = y / max(1, size - 1)
        color = tuple(round(light[c] * (1 - ratio) + dark[c] * ratio) for c in range(3)) + (255,)
        draw.line((0, y, size - 1, y), fill=color)
    inset = max(2, size // 5)
    draw.ellipse((inset, inset, size - inset - 1, size - inset - 1), outline=(232, 216, 157, 220), width=max(1, size // 16))
    draw.line((inset, size - inset - 1, size - inset - 1, inset), fill=(42, 29, 22, 220), width=max(1, size // 12))
    if state == "range":
        draw.rectangle((0, 0, size - 1, size - 1), fill=(130, 15, 15, 105))
    elif state == "oom":
        draw.rectangle((0, 0, size - 1, size - 1), fill=(30, 55, 145, 120))
    elif state == "cooldown":
        draw.rectangle((0, 0, size - 1, size - 1), fill=(0, 0, 0, 140))
        draw.pieslice((1, 1, size - 2, size - 2), 270, 54, fill=(8, 8, 8, 150))
    return image


def draw_outline(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], color: tuple[int, int, int, int], width: int = 1) -> None:
    for inset in range(width):
        draw.rectangle((box[0] + inset, box[1] + inset, box[2] - 1 - inset, box[3] - 1 - inset), outline=color)


def paste_button(
    canvas: Image.Image,
    sprite: Image.Image,
    outer_box: tuple[int, int, int, int],
    icon_size: int,
    index: int,
    state: str,
    key: str,
) -> dict[str, list[int]]:
    x0, y0, x1, y1 = outer_box
    outer_size = min(x1 - x0, y1 - y0)
    art = sprite.resize((outer_size, outer_size), Image.Resampling.LANCZOS)
    canvas.alpha_composite(art, (x0, y0))
    icon_size = min(icon_size, outer_size)
    icon_x = x0 + (outer_size - icon_size) // 2
    icon_y = y0 + (outer_size - icon_size) // 2
    icon_box = (icon_x, icon_y, icon_x + icon_size, icon_y + icon_size)
    hit_box = icon_box
    if state != "empty":
        icon = dynamic_icon(icon_size, index, state)
        if state == "pressed" and icon_size > 2:
            icon_x += 1
            icon_y += 1
            icon_box = (icon_x, icon_y, icon_x + icon_size, icon_y + icon_size)
        canvas.alpha_composite(icon, (icon_x, icon_y))
    draw = ImageDraw.Draw(canvas, "RGBA")
    if state == "hover":
        draw_outline(draw, outer_box, (245, 225, 164, 240), max(1, outer_size // 18))
    elif state == "active":
        draw_outline(draw, icon_box, (245, 196, 70, 245), max(1, outer_size // 18))
    elif state == "equipped":
        draw_outline(draw, icon_box, (72, 196, 96, 245), max(1, outer_size // 20))
    if key and icon_size >= 13:
        font = ImageFont.load_default(size=max(7, min(11, icon_size // 3)))
        draw.text((icon_box[2] - 2, icon_box[1] + 1), key, font=font, fill=(252, 245, 220, 255), stroke_width=1, stroke_fill=(0, 0, 0, 255), anchor="ra")
    if state == "cooldown" and icon_size >= 15:
        font = ImageFont.load_default(size=max(8, min(12, icon_size // 3)))
        draw.text(((icon_box[0] + icon_box[2]) // 2, (icon_box[1] + icon_box[3]) // 2), "4", font=font, fill=(255, 224, 150, 255), stroke_width=1, stroke_fill=(0, 0, 0, 255), anchor="mm")
    return {
        "backdrop": list(outer_box),
        "icon": list(icon_box),
        "hit": list(hit_box),
    }


def scenario_geometry(scenario: dict[str, Any], ui_scale: float) -> dict[str, Any]:
    icon_ui = int(scenario["icon_ui"])
    border_ui = int(scenario["border_ui"])
    spacing_ui = int(scenario["spacing_ui"])
    cols = int(scenario["cols"])
    rows = int(scenario["rows"])
    factor = ui_scale * float(scenario["local_scale"])
    step_ui = icon_ui + border_ui * 2 + spacing_ui
    outer_ui = icon_ui + border_ui * 2
    frame_ui = (step_ui * cols + spacing_ui, step_ui * rows + spacing_ui)
    frame_px = (max(1, round(frame_ui[0] * factor)), max(1, round(frame_ui[1] * factor)))
    outer_px = max(1, round(outer_ui * factor))
    icon_px = max(1, round(icon_ui * factor))
    boxes = []
    for index in range(int(scenario["buttons"])):
        col = index % cols
        row = index // cols
        x0 = round((spacing_ui + col * step_ui) * factor)
        y0 = round((spacing_ui + row * step_ui) * factor)
        boxes.append((x0, y0, x0 + outer_px, y0 + outer_px))
    return {
        "factor": factor,
        "frame_ui": list(frame_ui),
        "frame_px": list(frame_px),
        "outer_px": outer_px,
        "icon_px": icon_px,
        "boxes": boxes,
    }


def render_scenario(
    scenario: dict[str, Any], geometry: dict[str, Any], sprite: Image.Image, output: Path
) -> list[dict[str, list[int]]]:
    frame = tuple(geometry["frame_px"])
    image = Image.new("RGBA", frame, (24, 17, 13, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle((0, 0, frame[0] - 1, frame[1] - 1), fill=(37, 25, 18, 255), outline=(103, 75, 42, 255))
    records = []
    states = list(scenario["states"])
    keys = list(scenario["keys"])
    for index, box in enumerate(geometry["boxes"]):
        records.append(
            paste_button(
                image,
                sprite,
                box,
                int(geometry["icon_px"]),
                index,
                str(states[index]),
                str(keys[index]),
            )
        )
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output)
    return records


def render_supported_board(
    previews: list[dict[str, Any]], output: Path
) -> None:
    board = Image.new("RGBA", (1600, 900), (17, 22, 20, 255))
    draw = ImageDraw.Draw(board, "RGBA")
    title = ImageFont.load_default(size=24)
    body = ImageFont.load_default(size=14)
    draw.text((34, 24), "AB.SLOT.BASE.V1 attempt review - exact provider layouts", font=title, fill=(235, 211, 157, 255))
    draw.text((34, 58), "Candidate pixels: slot base only. Icons, text and states: deterministic provider-owned preview content.", font=body, fill=(183, 192, 179, 255))
    positions = [(40, 110), (360, 110), (250, 330), (690, 330), (1320, 110)]
    for item, position in zip(previews, positions):
        image = Image.open(item["path"]).convert("RGBA")
        x, y = position
        draw.text((x, y - 24), f"{item['id']}  exact={image.width}x{image.height}px", font=body, fill=(231, 225, 206, 255))
        board.alpha_composite(image, (x, y))
        zoom = min(3, max(1, 260 // max(image.width, image.height)))
        if zoom > 1:
            enlarged = image.resize((image.width * zoom, image.height * zoom), Image.Resampling.NEAREST)
            zx = min(1590 - enlarged.width, x + image.width + 24)
            zy = y
            board.alpha_composite(enlarged, (zx, zy))
            draw.text((zx, zy + enlarged.height + 4), f"{zoom}x inspection only", font=body, fill=(151, 160, 150, 255))
    output.parent.mkdir(parents=True, exist_ok=True)
    board.save(output)


def render_full_screen(
    root: Path,
    spec: dict[str, Any],
    sprite: Image.Image,
    output: Path,
) -> list[dict[str, Any]]:
    simulation_path = resolve(root, spec["target"]["simulation"])
    scene = Image.open(simulation_path).convert("RGBA")
    simulation_spec = load_extended_spec(resolve(root, spec["target"]["simulation_spec"]), root)
    ui_scale = float(spec["target"]["ui_scale"])
    records = []
    for bar in simulation_spec["bars"]:
        if str(bar["id"]) == "AB.BAR11.STANCE":
            continue
        geometry = scenario_geometry(
            {
                "buttons": bar["buttons"],
                "cols": bar["cols"],
                "rows": bar["rows"],
                "icon_ui": bar["icon_ui"],
                "border_ui": bar["border_ui"],
                "spacing_ui": bar["spacing_ui"],
                "local_scale": bar["scale"],
            },
            ui_scale,
        )
        states = list(bar["states"])
        keys = list(bar["keys"])
        origin = tuple(bar["screen_origin"])
        button_records = []
        for index, local_box in enumerate(geometry["boxes"]):
            box = (
                origin[0] + local_box[0],
                origin[1] + local_box[1],
                origin[0] + local_box[2],
                origin[1] + local_box[3],
            )
            button_records.append(
                paste_button(scene, sprite, box, int(geometry["icon_px"]), index, str(states[index]), str(keys[index]))
            )
        records.append({"bar": bar["id"], "origin": list(origin), "buttons": button_records})
    draw = ImageDraw.Draw(scene, "RGBA")
    font = ImageFont.load_default(size=13)
    draw.rounded_rectangle((1370, 1000, 1904, 1064), radius=6, fill=(11, 14, 13, 220), outline=(128, 91, 49, 230), width=2)
    draw.text((1384, 1012), "AB.SLOT candidate @ exact target-device scale", font=font, fill=(238, 218, 169, 255))
    draw.text((1384, 1036), "Surrounding V3 geometry is confirmed direction-only, not runtime art.", font=font, fill=(186, 192, 177, 255))
    output.parent.mkdir(parents=True, exist_ok=True)
    scene.save(output)
    return records


def display_contract(
    spec: dict[str, Any],
    runtime_master: Image.Image,
    scenario_records: list[dict[str, Any]],
    full_screen: Path,
) -> dict[str, Any]:
    visible = list(alpha_bbox(runtime_master))
    contract: dict[str, Any] = {
        "schema": "aeui-display-region-contract-v1",
        "component": "AB.SLOT.BASE.V1/production-candidate",
        "coordinate_system": "top-left-origin, right-bottom-exclusive, target-device physical pixels",
        "evidence": {
            "provider": "addon/pfUI/api/api.lua BarLayoutSize + BarButtonAnchor; addon/pfUI/modules/actionbar.lua",
            "layout_formula": "frame=(icon+2*border+spacing)*cols+spacing; candidate backdrop=(icon+2*border); all dimensions multiplied by UI scale and local bar scale",
            "target": "1920x1080; UI scale 0.81269841269841",
            "runtime_sampling": "single 128x128 texture sampled at full UV; not a nine-slice runtime asset",
            "dynamic_ownership": "icons, keybinds, counts, macro names, cooldowns, highlight, active, equipped, range, OOM and pressed feedback remain provider-owned",
            "real_layout_preview": str(full_screen),
            "final_runtime": False,
        },
        "atlas": {
            "size": [128, 128],
            "visible_bbox": visible,
            "require_exact_visible_coverage": True,
            "sampled_regions": [{"id": "AB.SLOT.full-uv", "box": [0, 0, 128, 128]}],
        },
        "nine_slice": {
            "caps": {"left": 1, "right": 1, "top": 1, "bottom": 1},
            "minimum_frame_size": [3, 3],
        },
        "scenarios": [],
    }
    for record in scenario_records:
        width, height = record["frame_px"]
        scenario = {
            "id": record["id"],
            "frame": [width, height],
            "preview_frame": [width, height],
            "zones": {"bar-frame": [0, 0, width, height]},
            "regions": [],
        }
        for index, button in enumerate(record["buttons"], start=1):
            backdrop_zone = f"button-{index}.backdrop-safe"
            icon_zone = f"button-{index}.icon-safe"
            hit_zone = f"button-{index}.hit-safe"
            scenario["zones"][backdrop_zone] = button["backdrop"]
            scenario["zones"][icon_zone] = button["icon"]
            scenario["zones"][hit_zone] = button["hit"]
            scenario["regions"].extend(
                [
                    {"id": f"button-{index}.backdrop", "kind": "texture", "box": button["backdrop"], "zone": backdrop_zone},
                    {"id": f"button-{index}.icon-and-state", "kind": "icon", "box": button["icon"], "zone": icon_zone},
                    {"id": f"button-{index}.hit", "kind": "button", "box": button["hit"], "zone": hit_zone},
                ]
            )
        contract["scenarios"].append(scenario)
    return contract


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    raw_path = resolve(root, args.raw).resolve()
    transparent_path = resolve(root, args.transparent).resolve()
    spec_path = resolve(root, args.spec).resolve()
    output_dir = resolve(root, args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    spec = load_json(spec_path)
    raw = Image.open(raw_path).convert("RGB")
    transparent = Image.open(transparent_path).convert("RGBA")
    if raw.size != transparent.size:
        raise ValueError("raw and transparent review candidates must share dimensions")

    runtime_path = output_dir / f"AB.SLOT.BASE.V1.{args.attempt}.runtime-master-review.png"
    runtime, visible_bbox, crop_box = make_runtime_master(transparent, runtime_path)
    ui_scale = float(spec["target"]["ui_scale"])

    layouts_dir = output_dir / "layouts"
    scenario_records = []
    preview_inventory = []
    for scenario in spec["scenarios"]:
        geometry = scenario_geometry(scenario, ui_scale)
        path = layouts_dir / f"{scenario['id']}.{geometry['frame_px'][0]}x{geometry['frame_px'][1]}.png"
        buttons = render_scenario(scenario, geometry, runtime, path)
        scenario_records.append(
            {
                "id": scenario["id"],
                "frame_ui": geometry["frame_ui"],
                "frame_px": geometry["frame_px"],
                "outer_px": geometry["outer_px"],
                "icon_px": geometry["icon_px"],
                "buttons": buttons,
                "path": str(path),
                "sha256": sha256(path),
            }
        )
        preview_inventory.append({"id": scenario["id"], "path": str(path)})

    board_path = output_dir / f"AB.SLOT.BASE.V1.{args.attempt}.supported-layouts-board.png"
    render_supported_board(preview_inventory, board_path)
    full_screen_path = output_dir / f"AB.SLOT.BASE.V1.{args.attempt}.real-layout-1920x1080.png"
    full_screen_bars = render_full_screen(root, spec, runtime, full_screen_path)

    contract = display_contract(spec, runtime, scenario_records, full_screen_path)
    contract_path = output_dir / "display-region-contract.json"
    contract_path.write_text(json.dumps(contract, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    normalized_visible = normalized_box(visible_bbox, raw.size)
    report = {
        "schema": "aeui-action-slot-candidate-review-v1",
        "component": spec["component"],
        "attempt": args.attempt,
        "candidate_is_source": False,
        "candidate_is_runtime": False,
        "raw": {
            "path": str(raw_path),
            "sha256": sha256(raw_path),
            "size": list(raw.size),
            "mode": raw.mode,
        },
        "transparent_review": {
            "path": str(transparent_path),
            "sha256": sha256(transparent_path),
            "size": list(transparent.size),
            "visible_bbox": list(visible_bbox),
            "normalized_1024_visible_bbox": normalized_visible,
            "background": background_metrics(raw, transparent),
        },
        "contract_checks": {
            "exact_1024_rgb_canvas": raw.size == (1024, 1024) and raw.mode == "RGB",
            "visible_bbox_inside_192_192_832_832_after_1024_normalization": (
                normalized_visible[0] >= 192
                and normalized_visible[1] >= 192
                and normalized_visible[2] <= 832
                and normalized_visible[3] <= 832
            ),
            "quiet_zone": quiet_zone_metrics(raw),
        },
        "runtime_master_review_only": {
            "path": str(runtime_path),
            "sha256": sha256(runtime_path),
            "size": list(runtime.size),
            "visible_bbox": list(alpha_bbox(runtime)),
            "source_square_crop": list(crop_box),
        },
        "real_layout": {
            "full_screen": {"path": str(full_screen_path), "sha256": sha256(full_screen_path), "size": list(Image.open(full_screen_path).size)},
            "supported_layouts_board": {"path": str(board_path), "sha256": sha256(board_path), "size": list(Image.open(board_path).size)},
            "scenarios": scenario_records,
            "full_screen_bars": full_screen_bars,
            "candidate_pixels": "AB.SLOT base only",
            "dynamic_pixels": "deterministic representative spell icons, keybinds and provider states",
            "surrounding_pixels": "confirmed V3 direction simulation; non-authoritative and not runtime art",
        },
        "display_region_contract": {"path": str(contract_path), "sha256": sha256(contract_path)},
    }
    report_path = output_dir / "candidate-review.json"
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
