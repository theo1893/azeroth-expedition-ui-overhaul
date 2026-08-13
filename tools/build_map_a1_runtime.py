#!/usr/bin/env python3
"""Promote the accepted Map A1 donors and export deterministic runtime media.

The ignored ImageGen candidates are consumed only when ``--promote-*`` is
provided.  Once the accepted component PNGs exist in ``assets/source``, normal
rebuilds require no generated files and never reinterpret the donor layout.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageChops, ImageDraw

from runtime_texture_compat import (
    content_uv,
    pad_to_power_of_two,
    power_of_two_size,
)


ROOT = Path(__file__).resolve().parents[1]
RESAMPLE = Image.Resampling.LANCZOS

WORLD_RAW_SHA256 = (
    "c27008280cf8db8f09f7957b0f77cb0614025ba869af8ffa07926cc69be7aad0"
)
MINI_RAW_SHA256 = (
    "eb7f13856573284290b368be829d2fb4907d476756d7b2b974076a26cdfeaba2"
)

WORLD_SOURCE_DIR = ROOT / "assets/source/map/world-a1"
MINI_SOURCE_DIR = ROOT / "assets/source/map/mini-a1"
RUNTIME_DIR = ROOT / "addon/AzerothExpeditionUI/Media/Map"

WORLD_SOURCE_MANIFEST = WORLD_SOURCE_DIR / "MAP-WORLD-A1_SourceManifest_v1.json"
WORLD_RUNTIME_MANIFEST = WORLD_SOURCE_DIR / "MAP-WORLD-A1_RuntimeManifest_v1.json"
MINI_SOURCE_MANIFEST = MINI_SOURCE_DIR / "MAP-MINI-A1_SourceManifest_v1.json"
MINI_RUNTIME_MANIFEST = MINI_SOURCE_DIR / "MAP-MINI-A1_RuntimeManifest_v1.json"

WORLD_SOURCES = {
    "rod_top": "MapWorldRodTop_MasterV1.png",
    "rod_bottom": "MapWorldRodBottom_MasterV1.png",
    "edge_left": "MapWorldPaperEdgeLeft_MasterV1.png",
    "edge_right": "MapWorldPaperEdgeRight_MasterV1.png",
}
WORLD_RUNTIME = {
    "rod_top": ("MapWorldRodTopV1.tga", (1024, 109)),
    "rod_bottom": ("MapWorldRodBottomV1.tga", (1024, 109)),
    "edge_left": ("MapWorldPaperEdgeLeftV1.tga", (118, 512)),
    "edge_right": ("MapWorldPaperEdgeRightV1.tga", (118, 512)),
}
WORLD_COMPONENTS = {
    "rod_top": "MAP.WORLD.FRAME.ROD.TOP",
    "rod_bottom": "MAP.WORLD.FRAME.ROD.BOTTOM",
    "edge_left": "MAP.WORLD.FRAME.EDGE.LEFT",
    "edge_right": "MAP.WORLD.FRAME.EDGE.RIGHT",
}

MINI_SOURCES = {
    "ring": "MapMiniCompassRing_MasterV1.png",
    "north": "MapMiniNorth_MasterV1.png",
    "west": "MapMiniDirectionWest_MasterV1.png",
    "east": "MapMiniDirectionEast_MasterV1.png",
    "south": "MapMiniDirectionSouth_MasterV1.png",
    "plaque": "MapMiniInfoPlaque_MasterV1.png",
}
MINI_RUNTIME = {
    "ring": ("MapMiniCompassRingV1.tga", (184, 184)),
    "north": ("MapMiniNorthV1.tga", (42, 58)),
    "west": ("MapMiniDirectionWestV1.tga", (50, 36)),
    "east": ("MapMiniDirectionEastV1.tga", (50, 36)),
    "south": ("MapMiniDirectionSouthV1.tga", (38, 42)),
    "plaque": ("MapMiniInfoPlaqueV1.tga", (150, 44)),
}
MINI_COMPONENTS = {
    "ring": "MAP.MINI.COMPASS",
    "north": "MAP.MINI.NORTH",
    "west": "MAP.MINI.DIRECTIONS.WEST",
    "east": "MAP.MINI.DIRECTIONS.EAST",
    "south": "MAP.MINI.DIRECTIONS.SOUTH",
    "plaque": "MAP.MINI.ZONE.PLAQUE",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--promote-world",
        type=Path,
        help="Exact accepted MAP-WORLD-A1 attempt-1 provider output.",
    )
    parser.add_argument(
        "--promote-mini",
        type=Path,
        help="Exact accepted MAP-MINI-A1 attempt-2 provider output.",
    )
    return parser.parse_args()


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def repository_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = np.array(image.convert("RGBA"), dtype=np.uint8)
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def clear_visible_cyan_key_spill(image: Image.Image) -> Image.Image:
    """Remove only unmistakable key-field pixels left by isolated AI islands."""

    rgba = np.array(image.convert("RGBA"), dtype=np.uint8)
    red = rgba[:, :, 0].astype(np.int16)
    green = rgba[:, :, 1].astype(np.int16)
    blue = rgba[:, :, 2].astype(np.int16)
    spill = (
        (rgba[:, :, 3] > 0)
        & (green >= 224)
        & (blue >= 224)
        & (green - red >= 150)
        & (blue - red >= 150)
    )
    rgba[spill] = 0
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def visible_cyan_pixels(image: Image.Image) -> int:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8)
    red = rgba[:, :, 0].astype(np.int16)
    green = rgba[:, :, 1].astype(np.int16)
    blue = rgba[:, :, 2].astype(np.int16)
    alpha = rgba[:, :, 3]
    mask = (
        (alpha > 0)
        & (green >= 224)
        & (blue >= 224)
        & (green - red >= 150)
        & (blue - red >= 150)
    )
    return int(mask.sum())


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
        "visible_bbox_exclusive": list(rgba.getchannel("A").getbbox() or (0, 0, 0, 0)),
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
        "visible_cyan_key_pixels": visible_cyan_pixels(rgba),
        "transparent_rgb_nonzero_values": transparent_rgb_nonzero(rgba),
    }


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    clear_visible_cyan_key_spill(image).save(
        path,
        format="PNG",
        compress_level=9,
    )


def validate_raw(path: Path, expected_sha: str, size: tuple[int, int]) -> Image.Image:
    path = path.resolve()
    if sha256(path) != expected_sha:
        raise ValueError(f"accepted provider output hash mismatch: {path}")
    with Image.open(path) as opened:
        if opened.size != size or opened.mode != "RGB":
            raise ValueError(
                f"accepted provider output must remain {size[0]}x{size[1]} RGB: {path}"
            )
        return opened.copy()


def edge_connected_cyan_key(image: Image.Image) -> Image.Image:
    rgb = np.asarray(image.convert("RGB"), dtype=np.uint8)
    red = rgb[:, :, 0].astype(np.int16)
    green = rgb[:, :, 1].astype(np.int16)
    blue = rgb[:, :, 2].astype(np.int16)
    chroma = (
        (green >= 135)
        & (blue >= 135)
        & (green - red >= 70)
        & (blue - red >= 70)
    )
    field = Image.fromarray(np.where(chroma, 0, 255).astype(np.uint8), "L").copy()
    if field.getpixel((0, 0)) != 0:
        raise ValueError("world donor top-left pixel is not in the cyan key field")
    ImageDraw.floodfill(field, (0, 0), 128)
    connected = np.asarray(field) == 128
    alpha = np.where(connected, 0, 255).astype(np.uint8)
    rgba = np.dstack([rgb, alpha])
    rgba[alpha == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def crop_fraction(
    image: Image.Image,
    bbox: tuple[int, int, int, int],
    x1: float,
    y1: float,
    x2: float,
    y2: float,
) -> Image.Image:
    left, top, right, bottom = bbox
    width, height = right - left, bottom - top
    box = (
        round(left + width * x1),
        round(top + height * y1),
        round(left + width * x2),
        round(top + height * y2),
    )
    return image.crop(box)


def promote_world(path: Path) -> None:
    raw = validate_raw(path, WORLD_RAW_SHA256, (1513, 1040))
    keyed = edge_connected_cyan_key(raw)
    bbox = keyed.getbbox()
    if bbox != (17, 29, 1495, 1013):
        raise ValueError(f"world donor visible bbox drifted: {bbox}")
    sources = {
        "rod_top": crop_fraction(keyed, bbox, 0.0, 0.0, 1.0, 0.16),
        "rod_bottom": crop_fraction(keyed, bbox, 0.0, 0.84, 1.0, 1.0),
        "edge_left": crop_fraction(keyed, bbox, 0.035, 0.105, 0.155, 0.885),
        "edge_right": crop_fraction(keyed, bbox, 0.845, 0.105, 0.965, 0.885),
    }
    expected_sizes = {
        "rod_top": (1478, 157),
        "rod_bottom": (1478, 157),
        "edge_left": (177, 768),
        "edge_right": (177, 768),
    }
    for key, source in sources.items():
        if source.size != expected_sizes[key]:
            raise ValueError(f"world component geometry drifted: {key} {source.size}")
        save_png(source, WORLD_SOURCE_DIR / WORLD_SOURCES[key])


def cyan_key_all(image: Image.Image) -> Image.Image:
    rgb = np.asarray(image.convert("RGB"), dtype=np.uint8)
    red = rgb[:, :, 0].astype(np.int16)
    green = rgb[:, :, 1].astype(np.int16)
    blue = rgb[:, :, 2].astype(np.int16)
    cyan = (
        (green >= 130)
        & (blue >= 130)
        & (green - red >= 65)
        & (blue - red >= 65)
    )
    alpha = np.where(cyan, 0, 255).astype(np.uint8)
    rgba = np.dstack([rgb, alpha])
    rgba[alpha == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def antialiased_annulus(size: int = 184, outer: int = 92, inner: int = 70) -> Image.Image:
    factor = 4
    mask = Image.new("L", (size * factor, size * factor), 0)
    draw = ImageDraw.Draw(mask)
    center = size * factor / 2
    draw.ellipse(
        (
            center - outer * factor,
            center - outer * factor,
            center + outer * factor,
            center + outer * factor,
        ),
        fill=255,
    )
    draw.ellipse(
        (
            center - inner * factor,
            center - inner * factor,
            center + inner * factor,
            center + inner * factor,
        ),
        fill=0,
    )
    return mask.resize((size, size), RESAMPLE)


def apply_mask(image: Image.Image, mask: Image.Image) -> Image.Image:
    result = image.convert("RGBA")
    result.putalpha(ImageChops.multiply(result.getchannel("A"), mask))
    return clear_transparent_rgb(result)


def crop_fit(
    image: Image.Image,
    box: tuple[int, int, int, int],
    size: tuple[int, int],
) -> Image.Image:
    crop = image.crop(box)
    crop.thumbnail(size, RESAMPLE)
    result = Image.new("RGBA", size, (0, 0, 0, 0))
    result.alpha_composite(crop, ((size[0] - crop.width) // 2, (size[1] - crop.height) // 2))
    return clear_transparent_rgb(result)


def promote_mini(path: Path) -> None:
    raw = validate_raw(path, MINI_RAW_SHA256, (1254, 1254))
    keyed = cyan_key_all(raw)
    if keyed.getbbox() != (135, 41, 1119, 1198):
        raise ValueError(f"mini donor visible bbox drifted: {keyed.getbbox()}")
    ring_material = keyed.crop((118, 118, 1136, 1136)).resize((184, 184), RESAMPLE)
    sources = {
        "ring": apply_mask(ring_material, antialiased_annulus()),
        "north": crop_fit(keyed, (520, 20, 735, 320), (42, 58)),
        "west": crop_fit(keyed, (75, 520, 315, 710), (50, 36)),
        "east": crop_fit(keyed, (940, 520, 1180, 710), (50, 36)),
        "south": crop_fit(keyed, (535, 900, 720, 1090), (38, 42)),
        "plaque": crop_fit(keyed, (285, 1010, 970, 1225), (150, 44)),
    }
    for key, source in sources.items():
        if source.size != MINI_RUNTIME[key][1]:
            raise ValueError(f"mini component geometry drifted: {key} {source.size}")
        save_png(source, MINI_SOURCE_DIR / MINI_SOURCES[key])


def load_sources(
    source_dir: Path,
    names: dict[str, str],
    expected_sizes: dict[str, tuple[int, int]],
) -> dict[str, Image.Image]:
    loaded: dict[str, Image.Image] = {}
    for key, filename in names.items():
        path = source_dir / filename
        with Image.open(path) as opened:
            source = clear_transparent_rgb(opened)
        if source.size != expected_sizes[key]:
            raise ValueError(f"accepted source geometry drifted: {path} {source.size}")
        metrics = image_metrics(source)
        if metrics["transparent_rgb_nonzero_values"] or metrics["visible_cyan_key_pixels"]:
            raise ValueError(f"accepted source transparency drifted: {path}")
        loaded[key] = source
    return loaded


def tga_header(path: Path) -> dict[str, Any]:
    data = path.read_bytes()
    if len(data) < 18:
        raise ValueError(f"TGA header is incomplete: {path}")
    width, height = struct.unpack("<HH", data[12:16])
    return {
        "image_type": data[2],
        "width": width,
        "height": height,
        "bits_per_pixel": data[16],
        "descriptor": data[17],
        "top_origin": bool(data[17] & 0x20),
    }


def export_runtime(
    sources: dict[str, Image.Image],
    exports: dict[str, tuple[str, tuple[int, int]]],
) -> dict[str, Image.Image]:
    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    runtimes: dict[str, Image.Image] = {}
    for key, source in sources.items():
        filename, target_size = exports[key]
        runtime = clear_transparent_rgb(source.resize(target_size, RESAMPLE))
        texture = pad_to_power_of_two(runtime)
        path = RUNTIME_DIR / filename
        texture.save(path, format="TGA")
        with Image.open(path) as opened:
            roundtrip = opened.convert("RGBA")
        if ImageChops.difference(texture, roundtrip).getbbox() is not None:
            raise ValueError(f"runtime TGA changed pixels: {path}")
        logical_roundtrip = roundtrip.crop((0, 0, *target_size))
        if ImageChops.difference(runtime, logical_roundtrip).getbbox() is not None:
            raise ValueError(f"runtime container changed accepted pixels: {path}")
        header = tga_header(path)
        if (
            header["image_type"] != 2
            or header["bits_per_pixel"] != 32
            or (header["width"], header["height"])
            != power_of_two_size(target_size)
        ):
            raise ValueError(f"runtime TGA header drifted: {path}: {header}")
        runtimes[key] = logical_roundtrip
    return runtimes


def media_record(path: Path, image: Image.Image) -> dict[str, Any]:
    return {
        "file": repository_path(path),
        "sha256": sha256(path),
        "metrics": image_metrics(image),
    }


def source_records(
    source_dir: Path,
    names: dict[str, str],
    components: dict[str, str],
    sources: dict[str, Image.Image],
) -> dict[str, Any]:
    return {
        key: {
            "component": components[key],
            **media_record(source_dir / names[key], sources[key]),
        }
        for key in names
    }


def runtime_records(
    exports: dict[str, tuple[str, tuple[int, int]]],
    components: dict[str, str],
    runtimes: dict[str, Image.Image],
) -> dict[str, Any]:
    return {
        key: {
            "component": components[key],
            **media_record(RUNTIME_DIR / exports[key][0], runtimes[key]),
            "tga_header": tga_header(RUNTIME_DIR / exports[key][0]),
            "logical_size": list(exports[key][1]),
            "texture_size": list(power_of_two_size(exports[key][1])),
            "content_uv": content_uv(exports[key][1]),
        }
        for key in exports
    }


def write_manifests(
    world_sources: dict[str, Image.Image],
    world_runtimes: dict[str, Image.Image],
    mini_sources: dict[str, Image.Image],
    mini_runtimes: dict[str, Image.Image],
) -> None:
    world_source = {
        "schema": "aeui-map-world-a1-source-manifest-v1",
        "schema_version": 1,
        "module": "map",
        "batch": "MAP-WORLD-A1 V1",
        "status": "runtime-exported",
        "phase": "P5",
        "accepted_on": "2026-08-13",
        "user_acceptance": {
            "exact_statement": (
                "接受 MAP-WORLD-A1 V1 attempt 1 与 MAP-MINI-A1 V1 attempt 2；"
                "允许提升 source/runtime、接入 addon 并清理对应中间产物。"
            ),
            "accepted_attempt": 1,
            "p4_p5_and_integration_authorized": True,
        },
        "provenance": {
            "executor": "imagegen-0-143-0",
            "provider_raw_sha256": WORLD_RAW_SHA256,
            "provider_raw_size": [1513, 1040],
            "actual_imagegen_calls": 1,
            "maximum_imagegen_calls": 5,
            "prompt": "docs/modules/map/SUBMODULE_ART_BASELINES.md#mapworldframe",
            "global_prompt": "docs/GLOBAL_ART_BASELINE.md",
            "module_prompt": "docs/modules/map/ART_BASELINE.md",
            "locked_reference_sha256": (
                "22f9309de17014795215a5ca908a3b18e30ed0d1b6f006f08d071566693d41b9"
            ),
            "roughness_reference_sha256": (
                "272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8"
            ),
        },
        "components": source_records(
            WORLD_SOURCE_DIR, WORLD_SOURCES, WORLD_COMPONENTS, world_sources
        ),
        "deterministic_transform": {
            "outer_key": (
                "edge-connected cyan plus isolated dominant-key spill; "
                "transparent RGB cleared"
            ),
            "visible_bbox_exclusive": [17, 29, 1495, 1013],
            "component_crops_fraction_xyxy": {
                "rod_top": [0.0, 0.0, 1.0, 0.16],
                "rod_bottom": [0.0, 0.84, 1.0, 1.0],
                "edge_left": [0.035, 0.105, 0.155, 0.885],
                "edge_right": [0.845, 0.105, 0.965, 0.885],
            },
            "dynamic_content_pixels_promoted": False,
            "generative_postprocess": False,
        },
        "runtime_manifest": repository_path(WORLD_RUNTIME_MANIFEST),
    }
    WORLD_SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    WORLD_SOURCE_MANIFEST.write_text(
        json.dumps(world_source, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    world_runtime = {
        "schema": "aeui-map-world-a1-runtime-manifest-v1",
        "schema_version": 1,
        "module": "map",
        "batch": "MAP-WORLD-A1 V1",
        "status": "runtime-exported",
        "phase": "P5",
        "runtime_contract": "1.1",
        "source_manifest": repository_path(WORLD_SOURCE_MANIFEST),
        "runtime": runtime_records(
            WORLD_RUNTIME, WORLD_COMPONENTS, world_runtimes
        ),
        "layout_contract": {
            "provider": "WorldMapButton",
            "provider_size": "runtime GetWidth/GetHeight; no fixed fallback",
            "art_outsets_ui": {"left": 50, "right": 50, "top": 72, "bottom": 72},
            "rod_three_slice_uv": [0.0, 0.15, 0.85, 1.0],
            "rod_runtime_height_ui": 72,
            "rod_cap_runtime_width_ui": 102,
            "edge_three_slice_uv": [0.0, 0.16, 0.84, 1.0],
            "edge_runtime_width_ui": 58,
            "edge_cap_runtime_height_ui": 40,
            "dynamic_content_and_pfquest_above_shell": True,
            "vanilla_power_of_two_texture_containers": True,
        },
    }
    WORLD_RUNTIME_MANIFEST.write_text(
        json.dumps(world_runtime, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    mini_source = {
        "schema": "aeui-map-mini-a1-source-manifest-v1",
        "schema_version": 1,
        "module": "map",
        "batch": "MAP-MINI-A1 V1",
        "status": "runtime-exported",
        "phase": "P5",
        "accepted_on": "2026-08-13",
        "user_acceptance": {
            "exact_statement": (
                "接受 MAP-WORLD-A1 V1 attempt 1 与 MAP-MINI-A1 V1 attempt 2；"
                "允许提升 source/runtime、接入 addon 并清理对应中间产物。"
            ),
            "accepted_attempt": 2,
            "p4_p5_and_integration_authorized": True,
        },
        "provenance": {
            "executor": "imagegen-0-143-0",
            "provider_raw_sha256": MINI_RAW_SHA256,
            "provider_raw_size": [1254, 1254],
            "actual_imagegen_calls": 2,
            "maximum_imagegen_calls": 5,
            "prompt": "docs/modules/map/SUBMODULE_ART_BASELINES.md#mapminimaskcompass",
            "global_prompt": "docs/GLOBAL_ART_BASELINE.md",
            "module_prompt": "docs/modules/map/ART_BASELINE.md",
            "locked_reference_sha256": (
                "9e6a38dbaa2e7df82480c4fe8ca32ca2c931fa016a8264f26964903468ac2ea6"
            ),
            "roughness_reference_sha256": (
                "272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8"
            ),
        },
        "components": source_records(
            MINI_SOURCE_DIR, MINI_SOURCES, MINI_COMPONENTS, mini_sources
        ),
        "deterministic_transform": {
            "key": (
                "full-field cyan plus isolated dominant-key spill and "
                "transparent RGB clear"
            ),
            "visible_bbox_exclusive": [135, 41, 1119, 1198],
            "ring_material_window_xyxy": [118, 118, 1136, 1136],
            "ring_geometry": {"outer": [184, 184], "content": [140, 140]},
            "component_windows_are_fixed": True,
            "buttons_or_plugin_slots_promoted": False,
            "generative_postprocess": False,
        },
        "runtime_manifest": repository_path(MINI_RUNTIME_MANIFEST),
    }
    MINI_SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    MINI_SOURCE_MANIFEST.write_text(
        json.dumps(mini_source, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    mini_runtime = {
        "schema": "aeui-map-mini-a1-runtime-manifest-v1",
        "schema_version": 1,
        "module": "map",
        "batch": "MAP-MINI-A1 V1",
        "status": "runtime-exported",
        "phase": "P5",
        "runtime_contract": "1.1",
        "source_manifest": repository_path(MINI_SOURCE_MANIFEST),
        "runtime": runtime_records(MINI_RUNTIME, MINI_COMPONENTS, mini_runtimes),
        "layout_contract": {
            "provider": "pfUI.minimap and Minimap",
            "provider_size": "runtime Minimap GetWidth/GetHeight; square-only fail-open",
            "reference_content_ui": [140, 140],
            "reference_ring_ui": [184, 184],
            "uniform_scale_only": True,
            "farmmode_shell_reuse": False,
            "provider_buttons_and_pfquest_pins_remain_live": True,
            "zone_and_coordinates_are_runtime_text": True,
            "vanilla_power_of_two_texture_containers": True,
        },
    }
    MINI_RUNTIME_MANIFEST.write_text(
        json.dumps(mini_runtime, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def main() -> int:
    args = parse_args()
    if args.promote_world:
        promote_world(args.promote_world)
    if args.promote_mini:
        promote_mini(args.promote_mini)

    world_sizes = {
        "rod_top": (1478, 157),
        "rod_bottom": (1478, 157),
        "edge_left": (177, 768),
        "edge_right": (177, 768),
    }
    mini_sizes = {key: value[1] for key, value in MINI_RUNTIME.items()}
    world_sources = load_sources(WORLD_SOURCE_DIR, WORLD_SOURCES, world_sizes)
    mini_sources = load_sources(MINI_SOURCE_DIR, MINI_SOURCES, mini_sizes)
    world_runtimes = export_runtime(world_sources, WORLD_RUNTIME)
    mini_runtimes = export_runtime(mini_sources, MINI_RUNTIME)
    write_manifests(world_sources, world_runtimes, mini_sources, mini_runtimes)

    print(
        json.dumps(
            {
                "status": "pass",
                "world_source_manifest": repository_path(WORLD_SOURCE_MANIFEST),
                "world_runtime_manifest": repository_path(WORLD_RUNTIME_MANIFEST),
                "mini_source_manifest": repository_path(MINI_SOURCE_MANIFEST),
                "mini_runtime_manifest": repository_path(MINI_RUNTIME_MANIFEST),
                "runtime_files": len(WORLD_RUNTIME) + len(MINI_RUNTIME),
            },
            ensure_ascii=False,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
