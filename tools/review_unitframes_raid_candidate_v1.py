#!/usr/bin/env python3
"""Deterministically review UF-RAID-A1 V1 production sheets.

All outputs remain under ignored ``generated/``.  This tool performs only the
authorized fixed-cell split, edge-connected chroma key, transparent-RGB clear,
bbox normalization gate, 74x37 diagnostic/runtime derivation and true 40-member
layout preview.  It never promotes source or writes addon media.
"""

from __future__ import annotations

import argparse
from collections import deque
import hashlib
import json
from pathlib import Path
import sys
from typing import Any

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from review_unitframes_primary_candidate_v1 import (  # noqa: E402
    alpha_bbox,
    checkerboard,
    clear_transparent_rgb,
    connected_chroma_key,
)
import render_unitframes_raid_simulation_v1 as simulation  # noqa: E402


PRODUCTION_SPEC = ROOT / "tools/specs/unitframes_raid_production_v1.json"
SIMULATION_SPEC = ROOT / "tools/specs/unitframes_raid_simulation_v1.json"
HEALTH_RUNTIME = (
    ROOT / "addon/AzerothExpeditionUI/Media/UnitFrames/UnitFrameHealthFillV1.tga"
)
POWER_RUNTIME = (
    ROOT / "addon/AzerothExpeditionUI/Media/UnitFrames/UnitFramePowerFillV1.tga"
)
FONT = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"
TITLE_FONT = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--attempt", type=int, required=True)
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def component_sizes(image: Image.Image) -> list[int]:
    mask = np.asarray(image.convert("RGBA"))[:, :, 3] >= 32
    height, width = mask.shape
    visited = np.zeros_like(mask, dtype=bool)
    sizes: list[int] = []
    for y in range(height):
        for x in range(width):
            if not mask[y, x] or visited[y, x]:
                continue
            queue: deque[tuple[int, int]] = deque([(x, y)])
            visited[y, x] = True
            size = 0
            while queue:
                px, py = queue.popleft()
                size += 1
                for ny in range(max(0, py - 1), min(height, py + 2)):
                    for nx in range(max(0, px - 1), min(width, px + 2)):
                        if mask[ny, nx] and not visited[ny, nx]:
                            visited[ny, nx] = True
                            queue.append((nx, ny))
            sizes.append(size)
    return sorted(sizes, reverse=True)


def strong_green_visible(image: Image.Image) -> int:
    array = np.asarray(image.convert("RGBA"))
    rgb = array[:, :, :3].astype(np.int16)
    alpha = array[:, :, 3] > 0
    green = rgb[:, :, 1]
    score = green - np.maximum(rgb[:, :, 0], rgb[:, :, 2])
    return int((alpha & (green >= 95) & (score >= 28)).sum())


def normalize_or_preview(
    keyed: Image.Image,
    bbox: tuple[int, int, int, int],
    target: tuple[int, int],
    contract_pass: bool,
) -> tuple[Image.Image, str]:
    crop = clear_transparent_rgb(keyed.crop(bbox))
    if contract_pass:
        normalized = crop.resize(target, Image.Resampling.LANCZOS)
        return clear_transparent_rgb(normalized), "authorized-bbox-normalization"
    scale = min(target[0] / crop.width, target[1] / crop.height)
    size = (max(1, round(crop.width * scale)), max(1, round(crop.height * scale)))
    resized = crop.resize(size, Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", target, (0, 0, 0, 0))
    offset = ((target[0] - size[0]) // 2, (target[1] - size[1]) // 2)
    canvas.alpha_composite(resized, offset)
    return clear_transparent_rgb(canvas), "diagnostic-proportional-fit-only"


def tint_runtime(path: Path, size: tuple[int, int], tint: tuple[int, int, int, int]) -> Image.Image:
    source = Image.open(path).convert("RGBA").resize(size, Image.Resampling.LANCZOS)
    coloured = ImageChops.multiply(source, Image.new("RGBA", size, tint))
    coloured.putalpha(source.getchannel("A"))
    return coloured


def member_tile(
    spec: dict[str, Any],
    shells: dict[str, Image.Image],
    index: int,
) -> Image.Image:
    variant = spec["architecture"]["variant_slot_order"][index - 1]
    state = simulation.state_for(spec, index)
    palette = spec["palette"]
    tile = Image.new("RGBA", (74, 39), (0, 0, 0, 0))
    tile.alpha_composite(shells[variant], (0, 2))
    draw = ImageDraw.Draw(tile, "RGBA")

    hp_fraction = 0.34 + ((index * 37) % 63) / 100
    if state["dead"]:
        hp_fraction = 0.0
    health_id = "health_full" if hp_fraction > 0.67 else (
        "health_mid" if hp_fraction > 0.35 else "health_low"
    )
    health_colour = simulation.rgba(palette[health_id])
    health_width = max(0, min(70, round(70 * hp_fraction)))
    draw.rectangle((2, 4, 71, 33), fill=(23, 16, 12, 245))
    if health_width:
        tile.alpha_composite(
            tint_runtime(HEALTH_RUNTIME, (health_width, 30), health_colour),
            (2, 4),
        )
    power_ids = ("mana", "rage", "energy", "focus")
    power_id = power_ids[(index - 1) % len(power_ids)]
    power_width = max(1, min(70, round(70 * (0.28 + ((index * 19) % 69) / 100))))
    draw.rectangle((2, 35, 71, 36), fill=(18, 13, 10, 245))
    tile.alpha_composite(
        tint_runtime(
            POWER_RUNTIME,
            (power_width, 2),
            simulation.rgba(palette[power_id]),
        ),
        (2, 35),
    )

    draw = ImageDraw.Draw(tile, "RGBA")
    if state["incoming_heal"] and health_width < 62:
        draw.rectangle((2 + health_width, 4, min(71, 11 + health_width), 33), fill=(80, 154, 73, 110))
    if state["aggro"]:
        colour = simulation.rgba(palette["aggro"], 230)
        draw.line((0, 8, 1, 28), fill=colour, width=1)
        draw.line((57, 38, 70, 37), fill=colour, width=1)
    if state["hover"]:
        colour = simulation.rgba(palette["hover"], 220)
        draw.line((5, 2, 27, 2), fill=colour, width=1)
        draw.line((54, 38, 68, 37), fill=colour, width=1)

    label_font = ImageFont.truetype(str(FONT), 10)
    draw.text(
        (37, 19),
        simulation.NAMES[index - 1],
        font=label_font,
        fill=(238, 226, 194, 255),
        stroke_width=1,
        stroke_fill=(19, 13, 9, 235),
        anchor="mm",
    )
    if state["buff_indicators"]:
        for pos, colour in enumerate(((69, 105, 148, 255), (115, 81, 139, 255), (93, 124, 69, 255))):
            x = 2 + pos * 10
            draw.rectangle((x, 4, x + 8, 12), fill=(18, 13, 10, 245))
            draw.rectangle((x + 1, 5, x + 7, 11), fill=colour)
    if state["debuff_magic"] or state["debuff_poison"]:
        colour = simulation.rgba(palette["magic"] if state["debuff_magic"] else palette["poison"])
        draw.rectangle((27, 9, 46, 28), fill=(17, 12, 9, 245))
        draw.rectangle((28, 10, 45, 27), fill=colour)
    marker = state["raid_marker"]
    if marker:
        colour = (222, 187, 55, 255) if marker == "star" else (
            (78, 170, 82, 255) if marker == "triangle" else (204, 204, 194, 255)
        )
        draw.ellipse((31, 0, 42, 11), fill=colour, outline=(48, 38, 24, 255))
    if state["leader"]:
        draw.polygon(((1, 3), (5, 3), (6, 8), (3, 6), (1, 8)), fill=(224, 180, 60, 255))
    if state["master_looter"]:
        draw.ellipse((0, 17, 7, 24), fill=(131, 113, 62, 255), outline=(32, 25, 17, 255))
    if state["resurrection"]:
        draw.ellipse((21, 1, 52, 32), fill=(28, 38, 34, 210), outline=(165, 183, 127, 235))
        draw.line((37, 7, 37, 26), fill=(205, 220, 166, 245), width=2)
        draw.line((30, 17, 44, 17), fill=(205, 220, 166, 245), width=2)

    opacity = 1.0
    if state["offline"]:
        opacity = spec["provider"]["profile_states"]["offline_alpha"]
    elif state["out_of_range"]:
        opacity = spec["provider"]["profile_states"]["range_alpha"]
    if opacity < 1:
        tile.putalpha(tile.getchannel("A").point(lambda value: round(value * opacity)))
    return tile


def cluster(spec: dict[str, Any], shells: dict[str, Image.Image], count: int = 40) -> Image.Image:
    columns = max(1, (count + 3) // 4)
    result = Image.new("RGBA", ((columns - 1) * 77 + 74, 159), (0, 0, 0, 0))
    for index in range(1, count + 1):
        column = (index - 1) // 4
        row_from_bottom = (index - 1) % 4
        result.alpha_composite(member_tile(spec, shells, index), (column * 77, (3 - row_from_bottom) * 40))
    return result


def render_contact(
    variants: dict[str, Image.Image],
    metrics: dict[str, dict[str, Any]],
    output: Path,
    attempt: int,
) -> None:
    image = checkerboard((1300, 760), 14)
    draw = ImageDraw.Draw(image, "RGBA")
    title = ImageFont.truetype(str(TITLE_FONT), 25)
    body = ImageFont.truetype(str(FONT), 14)
    draw.rectangle((0, 0, 1300, 78), fill=(20, 18, 16, 246))
    draw.text((28, 24), f"UF-RAID-A1 V1 · attempt {attempt} · keyed 74×37 review", font=title, fill=(222, 190, 126, 255))
    for pos, role in enumerate(("A", "B", "C", "D")):
        x = 38 + (pos % 2) * 630
        y = 112 + (pos // 2) * 310
        zoom = variants[role].resize((592, 296), Image.Resampling.NEAREST)
        image.alpha_composite(zoom, (x, y))
        item = metrics[role]
        draw.text(
            (x, y + 306),
            f"{role} · bbox {item['bbox_size'][0]}×{item['bbox_size'][1]} · ratio error {item['ratio_error_percent']:.2f}% · {item['runtime_mode']}",
            font=body,
            fill=(226, 211, 179, 255),
        )
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, format="PNG", optimize=False, compress_level=9)


def render_real_layout(
    spec: dict[str, Any],
    shells: dict[str, Image.Image],
    output: Path,
    attempt: int,
) -> None:
    image = Image.new("RGBA", (1600, 900), (0, 0, 0, 255))
    simulation.draw_world(image)
    simulation.draw_neighbour_ui(image, spec)
    draw = ImageDraw.Draw(image, "RGBA")
    title = ImageFont.truetype(str(TITLE_FONT), 24)
    note = ImageFont.truetype(str(FONT), 13)
    draw.text((34, 28), f"UF-RAID-A1 V1 · attempt {attempt} · 40 人真实排版", font=title, fill=(218, 186, 119, 255))
    draw.text((36, 65), "40 个真实 70×33 Button；候选外壳 74×37；Health／Power、文字、状态与图标均为动态层。", font=note, fill=(178, 168, 147, 255))
    raid = cluster(spec, shells, 40)
    cluster_y = image.height - (spec["provider"]["screen_anchor"]["resolved_y"] - 2) - 159
    image.alpha_composite(raid, (0, cluster_y))
    draw.text((10, cluster_y - 22), "100% runtime · 767×159 visual envelope · no shared outer panel", font=note, fill=(193, 173, 132, 255))

    draw.rectangle((845, 120, 1570, 540), fill=(19, 17, 15, 230), outline=(92, 70, 42, 255), width=2)
    draw.text((870, 145), "4× nearest-neighbour detail", font=note, fill=(210, 184, 128, 255))
    for pos, role in enumerate(("A", "B", "C", "D")):
        tile = shells[role].resize((296, 148), Image.Resampling.NEAREST)
        x = 870 + (pos % 2) * 335
        y = 182 + (pos // 2) * 172
        image.alpha_composite(tile, (x, y))
        draw.text((x, y + 151), role, font=note, fill=(228, 216, 187, 255))
    draw.text((870, 510), "相邻 Chat／动作条／罗盘沿用已确认模拟的非权威几何占位；Raid Frame 几何与重复数量为真实值。", font=note, fill=(159, 148, 130, 255))
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, format="PNG", optimize=False, compress_level=9)


def main() -> None:
    args = parse_args()
    production = json.loads(PRODUCTION_SPEC.read_text(encoding="utf-8"))
    spec = json.loads(SIMULATION_SPEC.read_text(encoding="utf-8"))
    raw_path = args.raw.resolve()
    raw = Image.open(raw_path).convert("RGB")
    if raw.size != tuple(production["canvas"]["size"]):
        raise ValueError(f"raw size must be {production['canvas']['size']}, got {raw.size}")
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)

    target = tuple(production["normalized_source"]["per_variant"])
    target_ratio = target[0] / target[1]
    gates = production["deterministic_postprocess"]["technical_gates"]
    keyed_sheet = Image.new("RGBA", raw.size, (0, 0, 0, 0))
    variant_metrics: dict[str, dict[str, Any]] = {}
    runtimes: dict[str, Image.Image] = {}

    for item in production["canvas"]["cells"]:
        role = item["id"]
        box = tuple(item["cell"])
        cell = raw.crop(box)
        keyed, chroma = connected_chroma_key(cell, include_center=False)
        bbox = alpha_bbox(keyed)
        if bbox is None:
            raise ValueError(f"{role}: no visible object after chroma key")
        width = bbox[2] - bbox[0]
        height = bbox[3] - bbox[1]
        ratio = width / height
        ratio_error = abs(ratio - target_ratio) / target_ratio * 100.0
        scale_x = target[0] / width
        scale_y = target[1] / height
        anisotropy = abs(scale_x - scale_y) / max(scale_x, scale_y) * 100.0
        padding = [bbox[0], bbox[1], cell.width - bbox[2], cell.height - bbox[3]]
        sizes = component_sizes(keyed)
        visible_green = strong_green_visible(keyed)
        technical_pass = (
            len(sizes) == gates["foreground_components_per_cell"]
            and all(value >= minimum for value, minimum in zip(padding, gates["minimum_cell_padding"]))
            and ratio_error <= gates["maximum_ratio_error_percent"]
            and anisotropy <= gates["maximum_normalization_anisotropy_percent"]
            and visible_green == gates["visible_green_spill"]
        )
        normalized, runtime_mode = normalize_or_preview(keyed, bbox, target, technical_pass)
        runtime = clear_transparent_rgb(normalized.resize((74, 37), Image.Resampling.LANCZOS))
        runtime.save(output / f"variant-{role}-runtime.png", format="PNG", optimize=False, compress_level=9)
        keyed.save(output / f"variant-{role}-keyed.png", format="PNG", optimize=False, compress_level=9)
        keyed_sheet.alpha_composite(keyed, (box[0], box[1]))
        runtimes[role] = runtime
        variant_metrics[role] = {
            "cell": list(box),
            "keyed_bbox_exclusive_local": list(bbox),
            "bbox_size": [width, height],
            "padding_left_top_right_bottom": padding,
            "source_ratio": round(ratio, 6),
            "target_ratio": round(target_ratio, 6),
            "ratio_error_percent": round(ratio_error, 6),
            "normalization_scale_x": round(scale_x, 6),
            "normalization_scale_y": round(scale_y, 6),
            "normalization_anisotropy_percent": round(anisotropy, 6),
            "component_sizes_alpha32": sizes,
            "foreground_component_count": len(sizes),
            "visible_green_spill_pixels": visible_green,
            "runtime_mode": runtime_mode,
            "technical_contract_pass": technical_pass,
            "chroma": chroma,
        }

    keyed_sheet = clear_transparent_rgb(keyed_sheet)
    keyed_sheet_path = output / "keyed-sheet.png"
    keyed_sheet.save(keyed_sheet_path, format="PNG", optimize=False, compress_level=9)
    contact_path = output / "contact-sheet.png"
    layout_path = output / "real-layout-preview.png"
    render_contact(runtimes, variant_metrics, contact_path, args.attempt)
    render_real_layout(spec, runtimes, layout_path, args.attempt)

    report = {
        "schema": "aeui-unitframes-raid-candidate-review-v1",
        "version": production["version"],
        "attempt": args.attempt,
        "raw": {
            "path": str(raw_path),
            "size": list(raw.size),
            "mode": "RGB",
            "sha256": sha256(raw_path),
        },
        "authorized_operations_only": True,
        "variants": variant_metrics,
        "technical_contract_pass": all(item["technical_contract_pass"] for item in variant_metrics.values()),
        "outputs": {
            "keyed_sheet": {"path": str(keyed_sheet_path), "sha256": sha256(keyed_sheet_path)},
            "contact_sheet": {"path": str(contact_path), "sha256": sha256(contact_path)},
            "real_layout_preview": {"path": str(layout_path), "sha256": sha256(layout_path)},
        },
        "preview_contract": {
            "runtime_member_shell": [74, 37],
            "provider_button": [70, 33],
            "runtime_repeat_count": 40,
            "cluster_visual_envelope": [767, 159],
            "candidate_pixels_authoritative": True,
            "health_power_text_state_geometry_authoritative": True,
            "neighbour_ui": "same non-authoritative geometric context as confirmed UF-RAID-SIM-V1",
        },
        "semantic_warning": "Technical metrics do not prove Vanilla art direction, repair anatomy, quiet-centre quality or variant identity.",
    }
    report_path = output / "technical-report.json"
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
