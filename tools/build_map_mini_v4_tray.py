#!/usr/bin/env python3
"""Promote MAP-MINI-V4-TRAY and export Vanilla-safe directional media.

ImageGen owns the accepted hand-painted pixels.  This builder performs only the
two user-authorized exceptions and normal deterministic packaging: an edge-
connected near-cyan key, at most 2.2% relative Y compression, transparent RGB
cleanup, 270x74 runtime reduction, lossless directional rotation, POT TGA
packing, manifests, and a real-button-geometry review sheet.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import struct
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFont

from runtime_texture_compat import content_uv, pad_to_power_of_two, power_of_two_size


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets/source/map/mini-v4-tray"
SOURCE = SOURCE_DIR / "MapMiniAddonTray_SourceV4.png"
SOURCE_MANIFEST = SOURCE_DIR / "MAP-MINI-V4-TRAY_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "MAP-MINI-V4-TRAY_RuntimeManifest_v1.json"
RUNTIME_DIR = ROOT / "addon/AzerothExpeditionUI/Media/Map"

RAW_SHA256 = "98bc709e50cc8161afd964cb93f4df9e3c73fcb4013e3e6ede95c90abe385cf9"
RAW_SIZE = (1695, 928)
SOURCE_SIZE = (1080, 296)
LOGICAL_SIZE = (270, 74)
MAX_RELATIVE_Y_COMPRESSION = 0.022
DIRECTIONS = ("bottom", "top", "left", "right")

RUNTIME_FILES = {
    "bottom": "MapMiniAddonTrayBottomV4.tga",
    "top": "MapMiniAddonTrayTopV4.tga",
    "left": "MapMiniAddonTrayLeftV4.tga",
    "right": "MapMiniAddonTrayRightV4.tga",
}

# Logical fixed zones after each lossless directional rotation.
CUTS = {
    "bottom": {"x": (18, 258), "y": (12, 64)},
    "top": {"x": (12, 252), "y": (10, 62)},
    "left": {"x": (10, 62), "y": (18, 258)},
    "right": {"x": (12, 64), "y": (12, 252)},
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--promote", type=Path)
    parser.add_argument("--preview", type=Path)
    return parser.parse_args()


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def repository_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def transparent_rgb_nonzero(image: Image.Image) -> int:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8)
    transparent = rgba[:, :, 3] == 0
    return int(np.count_nonzero(rgba[transparent, :3]))


def image_metrics(image: Image.Image) -> dict[str, Any]:
    rgba = image.convert("RGBA")
    histogram = rgba.getchannel("A").histogram()
    return {
        "size": list(rgba.size),
        "mode": rgba.mode,
        "pixel_sha256": pixel_sha256(rgba),
        "visible_bbox_exclusive": list(
            rgba.getchannel("A").getbbox() or (0, 0, 0, 0)
        ),
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
        "transparent_rgb_nonzero_values": transparent_rgb_nonzero(rgba),
    }


def border_key(image: Image.Image, border: int = 12) -> np.ndarray:
    rgb = np.asarray(image.convert("RGB"), dtype=np.uint8)
    samples = np.concatenate(
        [
            rgb[:border].reshape(-1, 3),
            rgb[-border:].reshape(-1, 3),
            rgb[:, :border].reshape(-1, 3),
            rgb[:, -border:].reshape(-1, 3),
        ]
    )
    return np.median(samples, axis=0)


def edge_connected(mask: np.ndarray) -> np.ndarray:
    """Return only mask pixels connected to an image edge."""

    height, width = mask.shape
    connected = np.zeros_like(mask, dtype=bool)
    stack: list[tuple[int, int]] = []
    for x in range(width):
        if mask[0, x]:
            stack.append((x, 0))
        if mask[height - 1, x]:
            stack.append((x, height - 1))
    for y in range(1, height - 1):
        if mask[y, 0]:
            stack.append((0, y))
        if mask[y, width - 1]:
            stack.append((width - 1, y))

    while stack:
        x, y = stack.pop()
        if connected[y, x] or not mask[y, x]:
            continue
        left = x
        while left > 0 and mask[y, left - 1] and not connected[y, left - 1]:
            left -= 1
        right = x
        while (
            right + 1 < width
            and mask[y, right + 1]
            and not connected[y, right + 1]
        ):
            right += 1
        connected[y, left : right + 1] = True
        for adjacent_y in (y - 1, y + 1):
            if adjacent_y < 0 or adjacent_y >= height:
                continue
            candidates = (
                mask[adjacent_y, left : right + 1]
                & ~connected[adjacent_y, left : right + 1]
            )
            starts = candidates & np.concatenate(([True], ~candidates[:-1]))
            for offset in np.flatnonzero(starts):
                stack.append((left + int(offset), adjacent_y))
    return connected


def connected_chroma_key(image: Image.Image) -> tuple[Image.Image, list[int]]:
    rgb = np.asarray(image.convert("RGB"), dtype=np.uint8)
    key = border_key(image)
    distance = np.max(
        np.abs(rgb.astype(np.int16) - key.astype(np.int16)), axis=2
    )
    background = edge_connected(distance <= 58)
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    rgba[background] = 0

    # Remove only cyan-dominant antialias fringe touching keyed background.
    for _ in range(3):
        transparent = rgba[:, :, 3] == 0
        neighbour = np.zeros_like(transparent)
        neighbour[1:] |= transparent[:-1]
        neighbour[:-1] |= transparent[1:]
        neighbour[:, 1:] |= transparent[:, :-1]
        neighbour[:, :-1] |= transparent[:, 1:]
        values = rgba[:, :, :3].astype(np.int16)
        cyan = (
            (values[:, :, 1] > values[:, :, 0] + 36)
            & (values[:, :, 2] > values[:, :, 0] + 36)
            & (values[:, :, 1] + values[:, :, 2] >= 250)
        )
        spill = neighbour & cyan & ~transparent
        if not np.any(spill):
            break
        rgba[spill] = 0
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA"), [int(round(value)) for value in key]


def promote(raw_path: Path) -> tuple[Image.Image, dict[str, Any]]:
    raw_path = raw_path.resolve()
    if sha256(raw_path) != RAW_SHA256:
        raise ValueError(f"accepted raw hash mismatch: {raw_path}")
    with Image.open(raw_path) as opened:
        raw = opened.convert("RGBA")
    if raw.size != RAW_SIZE:
        raise ValueError(f"accepted raw size mismatch: {raw.size} != {RAW_SIZE}")

    keyed, key_rgb = connected_chroma_key(raw)
    bbox = keyed.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("keyed tray is empty")
    crop = keyed.crop(bbox)
    scale_x = SOURCE_SIZE[0] / crop.width
    scale_y = SOURCE_SIZE[1] / crop.height
    relative_y_compression = 1.0 - (scale_y / scale_x)
    if relative_y_compression < 0 or relative_y_compression > MAX_RELATIVE_Y_COMPRESSION:
        raise ValueError(
            "authorized Y compression exceeded: "
            f"{relative_y_compression:.6f} not in [0,{MAX_RELATIVE_Y_COMPRESSION}]"
        )
    normalized = clear_transparent_rgb(
        crop.resize(SOURCE_SIZE, Image.Resampling.LANCZOS)
    )
    SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    normalized.save(SOURCE, format="PNG", compress_level=9)
    return normalized, {
        "raw_visible_bbox_exclusive": list(bbox),
        "raw_visible_size": [crop.width, crop.height],
        "raw_visible_ratio": crop.width / crop.height,
        "target_ratio": LOGICAL_SIZE[0] / LOGICAL_SIZE[1],
        "relative_y_compression": relative_y_compression,
        "sampled_background_rgb": key_rgb,
        "chroma_threshold_max_channel": 58,
    }


def load_source() -> Image.Image:
    if not SOURCE.is_file():
        raise ValueError(f"accepted source is missing: {SOURCE}")
    if SOURCE_MANIFEST.is_file():
        manifest = json.loads(SOURCE_MANIFEST.read_text(encoding="utf-8"))
        expected = manifest.get("source", {}).get("sha256")
        if expected and sha256(SOURCE) != expected:
            raise ValueError(f"accepted source hash drifted: {SOURCE}")
    with Image.open(SOURCE) as opened:
        source = clear_transparent_rgb(opened)
    if source.size != SOURCE_SIZE:
        raise ValueError(f"accepted source size drifted: {source.size}")
    if transparent_rgb_nonzero(source):
        raise ValueError("accepted source transparent RGB drifted")
    return source


def rotate_for_attachment(image: Image.Image, direction: str) -> Image.Image:
    if direction == "bottom":
        return image.copy()
    if direction == "top":
        return image.transpose(Image.Transpose.ROTATE_180)
    if direction == "left":
        return image.transpose(Image.Transpose.ROTATE_270)
    if direction == "right":
        return image.transpose(Image.Transpose.ROTATE_90)
    raise ValueError(direction)


def runtime_logical(source: Image.Image) -> dict[str, Image.Image]:
    bottom = clear_transparent_rgb(
        source.resize(LOGICAL_SIZE, Image.Resampling.LANCZOS)
    )
    return {
        direction: clear_transparent_rgb(rotate_for_attachment(bottom, direction))
        for direction in DIRECTIONS
    }


def tga_header(path: Path) -> dict[str, Any]:
    data = path.read_bytes()
    width, height = struct.unpack("<HH", data[12:16])
    return {
        "image_type": data[2],
        "width": width,
        "height": height,
        "bits_per_pixel": data[16],
        "descriptor": data[17],
        "top_origin": bool(data[17] & 0x20),
    }


def export_runtime(images: dict[str, Image.Image]) -> None:
    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    for direction, logical in images.items():
        texture = pad_to_power_of_two(logical)
        path = RUNTIME_DIR / RUNTIME_FILES[direction]
        texture.save(path, format="TGA")
        with Image.open(path) as opened:
            roundtrip = opened.convert("RGBA")
        if ImageChops.difference(texture, roundtrip).getbbox() is not None:
            raise ValueError(f"TGA roundtrip changed pixels: {path}")
        header = tga_header(path)
        if (
            header["image_type"] != 2
            or header["bits_per_pixel"] != 32
            or (header["width"], header["height"])
            != power_of_two_size(logical.size)
        ):
            raise ValueError(f"Vanilla TGA contract drifted: {path}: {header}")


def media_record(path: Path, image: Image.Image) -> dict[str, Any]:
    return {
        "file": repository_path(path),
        "sha256": sha256(path),
        "metrics": image_metrics(image),
    }


def write_manifests(
    source: Image.Image,
    images: dict[str, Image.Image],
    transform: dict[str, Any],
) -> None:
    source_manifest = {
        "schema": "aeui-map-mini-v4-tray-source-manifest-v1",
        "schema_version": 1,
        "module": "map",
        "batch": "MAP-MINI-V4-TRAY",
        "phase": "P5",
        "status": "runtime-exported",
        "accepted_on": "2026-08-19",
        "user_acceptance": {
            "exact_statement": "接受。并且考虑：我们是否真的需要游戏中的 connector？实机视觉效果很差。",
            "accepted_candidate": "attempt 5",
            "accepted_raw_sha256": RAW_SHA256,
            "authorized_exceptions": [
                "maximum 2.2 percent relative Y compression",
                "edge-connected near-cyan tolerance key",
            ],
        },
        "provenance": {
            "executor": "imagegen-0-143-0",
            "actual_imagegen_calls": 5,
            "flow_errors_counted_as_imagegen_calls": False,
            "accepted_raw": {"sha256": RAW_SHA256, "size": list(RAW_SIZE)},
            "global_prompt": "docs/GLOBAL_ART_BASELINE.md",
            "module_prompt": "docs/modules/map/ART_BASELINE.md",
            "stable_prompt": "docs/modules/map/SUBMODULE_ART_BASELINES.md",
        },
        "component": "MAP.MINI.ADDONS.TRAY.V4",
        "source": media_record(SOURCE, source),
        "deterministic_transform": {
            **transform,
            "source_size": list(SOURCE_SIZE),
            "runtime_size": list(LOGICAL_SIZE),
            "transparent_rgb_cleared": True,
            "generative_postprocess": False,
        },
        "runtime_manifest": repository_path(RUNTIME_MANIFEST),
    }
    SOURCE_MANIFEST.write_text(
        json.dumps(source_manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    runtime: dict[str, Any] = {}
    for direction, image in images.items():
        path = RUNTIME_DIR / RUNTIME_FILES[direction]
        runtime[direction] = {
            "component": f"MAP.MINI.ADDONS.TRAY.V4.{direction.upper()}",
            **media_record(path, image),
            "logical_size": list(image.size),
            "texture_size": list(power_of_two_size(image.size)),
            "content_uv": content_uv(image.size),
            "nine_slice_cuts": {
                "x": [0, *CUTS[direction]["x"], image.width],
                "y": [0, *CUTS[direction]["y"], image.height],
            },
            "tga_header": tga_header(path),
        }
    runtime_manifest = {
        "schema": "aeui-map-mini-v4-tray-runtime-manifest-v1",
        "schema_version": 1,
        "module": "map",
        "batch": "MAP-MINI-V4-TRAY",
        "phase": "P5",
        "status": "runtime-exported",
        "runtime_contract": "4.0",
        "source_manifest": repository_path(SOURCE_MANIFEST),
        "runtime": runtime,
        "layout_contract": {
            "provider_container": "pfUI.addonbuttons / pfMinimapButtons",
            "provider_toggle": "pfUI.addonbuttons.minimapbutton / pfMinimapButton",
            "addon_positions": list(DIRECTIONS),
            "addon_counts_reviewed": [0, 4, 6, 30],
            "icon_safe_padding_derived_from_nine_slice": True,
            "plugin_icons_and_interactions_remain_provider_owned": True,
            "decorative_connector_required": False,
            "direct_latch_tray_rectangle_overlap_ui": 4,
            "direct_latch_tray_visible_alpha_contact_pixels": 1,
            "zero_addons_hide_toggle_and_tray": True,
            "vanilla_power_of_two_texture_containers": True,
        },
    }
    RUNTIME_MANIFEST.write_text(
        json.dumps(runtime_manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def render_nine_slice(image: Image.Image, size: tuple[int, int], direction: str) -> Image.Image:
    width, height = size
    x1, x2 = CUTS[direction]["x"]
    y1, y2 = CUTS[direction]["y"]
    cap_left = min(x1, width // 3)
    cap_right = min(image.width - x2, width // 3)
    cap_top = min(y1, height // 3)
    cap_bottom = min(image.height - y2, height // 3)
    destination_x = (0, cap_left, width - cap_right, width)
    destination_y = (0, cap_top, height - cap_bottom, height)
    source_x = (0, x1, x2, image.width)
    source_y = (0, y1, y2, image.height)
    result = Image.new("RGBA", size, (0, 0, 0, 0))
    for row in range(3):
        for column in range(3):
            source_box = (
                source_x[column], source_y[row], source_x[column + 1], source_y[row + 1]
            )
            target_box = (
                destination_x[column], destination_y[row],
                destination_x[column + 1], destination_y[row + 1]
            )
            target_size = (target_box[2] - target_box[0], target_box[3] - target_box[1])
            if target_size[0] <= 0 or target_size[1] <= 0:
                continue
            piece = image.crop(source_box).resize(target_size, Image.Resampling.LANCZOS)
            result.alpha_composite(piece, target_box[:2])
    return clear_transparent_rgb(result)


def tray_layout(count: int, direction: str) -> tuple[tuple[int, int], list[tuple[int, int]]]:
    horizontal = direction in ("bottom", "top")
    row_size = 6
    line_size = max(row_size, math.ceil(count / 3)) if horizontal else row_size
    primary = min(line_size, count)
    secondary = math.ceil(count / line_size)
    x1, x2 = CUTS[direction]["x"]
    y1, y2 = CUTS[direction]["y"]
    logical = LOGICAL_SIZE if horizontal else (LOGICAL_SIZE[1], LOGICAL_SIZE[0])
    pad_left, pad_right = x1 + 2, logical[0] - x2 + 2
    pad_top, pad_bottom = y1 + 2, logical[1] - y2 + 2
    button, gap = 21, 2
    if horizontal:
        width = primary * button + max(0, primary - 1) * gap + pad_left + pad_right
        height = secondary * button + max(0, secondary - 1) * gap + pad_top + pad_bottom
    else:
        width = secondary * button + max(0, secondary - 1) * gap + pad_left + pad_right
        height = primary * button + max(0, primary - 1) * gap + pad_top + pad_bottom
    positions: list[tuple[int, int]] = []
    for index in range(count):
        group = index // line_size
        item = index - group * line_size
        group_count = min(line_size, count - group * line_size)
        group_span = group_count * button + max(0, group_count - 1) * gap
        if horizontal:
            interior = width - pad_left - pad_right
            x = pad_left + (interior - group_span) // 2 + item * (button + gap)
            y = pad_top + group * (button + gap)
        else:
            interior = height - pad_top - pad_bottom
            x = pad_left + group * (button + gap)
            y = pad_top + (interior - group_span) // 2 + item * (button + gap)
        positions.append((x, y))
    return (width, height), positions


def load_logical_tga(path: Path, size: tuple[int, int]) -> Image.Image:
    with Image.open(path) as opened:
        return clear_transparent_rgb(opened.convert("RGBA").crop((0, 0, *size)))


def render_preview(images: dict[str, Image.Image], destination: Path) -> None:
    compass = load_logical_tga(RUNTIME_DIR / "MapMiniCompassCradleV3.tga", (220, 264))
    icon_paths = [
        ROOT / "addon/pfQuest/img/tracker_quests.tga",
        ROOT / "addon/pfQuest/img/tracker_settings.tga",
        ROOT / "addon/pfQuest/img/tracker_database.tga",
        ROOT / "addon/pfQuest/img/tracking/vendor.tga",
        ROOT / "addon/pfQuest/img/tracking/mines.tga",
        ROOT / "addon/pfQuest/img/icon_horde.tga",
        ROOT / "addon/pfQuest/img/icon_alliance.tga",
    ]
    icons = []
    for path in icon_paths:
        with Image.open(path) as opened:
            icons.append(opened.convert("RGBA").resize((21, 21), Image.Resampling.LANCZOS))

    cases = [
        ("bottom", 0), ("bottom", 4), ("bottom", 6), ("bottom", 30),
        ("top", 6), ("left", 6), ("right", 6),
    ]
    cells: list[Image.Image] = []
    font = ImageFont.load_default()
    for direction, count in cases:
        cell = Image.new("RGBA", (430, 440), (26, 24, 23, 255))
        art_x, art_y = 105, 55
        cell.alpha_composite(compass, (art_x, art_y))
        if count:
            tray_size, icon_positions = tray_layout(count, direction)
            tray = render_nine_slice(images[direction], tray_size, direction)
            if direction == "bottom":
                tray_x, tray_y = art_x + 220 - tray_size[0], art_y + 271
                latch_x, latch_y = art_x + 110 - 19, art_y + 251
            elif direction == "top":
                tray_x, tray_y = art_x + 161 - tray_size[0] // 2, art_y + 21 - tray_size[1]
                latch_x, latch_y = art_x + 142, art_y + 17
            elif direction == "left":
                tray_x, tray_y = art_x - 7 - tray_size[0], art_y + 111 - tray_size[1] // 2
                latch_x, latch_y = art_x - 11, art_y + 92
            else:
                tray_x, tray_y = art_x + 227, art_y + 111 - tray_size[1] // 2
                latch_x, latch_y = art_x + 207, art_y + 92
            cell.alpha_composite(tray, (tray_x, tray_y))
            for index, (x, y) in enumerate(icon_positions):
                cell.alpha_composite(icons[index % len(icons)], (tray_x + x, tray_y + y))
            latch_size = (38, 24) if direction in ("bottom", "top") else (24, 38)
            latch = load_logical_tga(
                RUNTIME_DIR / f"MapMiniAddonLatch{direction.title()}NormalV3.tga",
                latch_size,
            )
            cell.alpha_composite(latch, (latch_x, latch_y))
        ImageDraw.Draw(cell).text(
            (10, 10), f"{direction} / {count} provider buttons", font=font, fill=(235, 218, 178, 255)
        )
        cells.append(cell)

    sheet = Image.new("RGBA", (430 * 4, 440 * 2), (18, 17, 16, 255))
    for index, cell in enumerate(cells):
        sheet.alpha_composite(cell, ((index % 4) * 430, (index // 4) * 440))
    destination.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(destination, format="PNG", compress_level=9)


def main() -> int:
    args = parse_args()
    transform: dict[str, Any] = {}
    if args.promote:
        _, transform = promote(args.promote)
    source = load_source()
    images = runtime_logical(source)
    for direction, image in images.items():
        if transparent_rgb_nonzero(image):
            raise ValueError(f"transparent RGB drifted: {direction}")
    export_runtime(images)
    if not transform and SOURCE_MANIFEST.is_file():
        transform = json.loads(SOURCE_MANIFEST.read_text(encoding="utf-8")).get(
            "deterministic_transform", {}
        )
    write_manifests(source, images, transform)
    if args.preview:
        render_preview(images, args.preview.resolve())
    print(
        json.dumps(
            {
                "status": "pass",
                "source": repository_path(SOURCE),
                "source_manifest": repository_path(SOURCE_MANIFEST),
                "runtime_manifest": repository_path(RUNTIME_MANIFEST),
                "runtime_files": [repository_path(RUNTIME_DIR / RUNTIME_FILES[d]) for d in DIRECTIONS],
                "preview": str(args.preview.resolve()) if args.preview else None,
                "connector_required": False,
            },
            ensure_ascii=False,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
