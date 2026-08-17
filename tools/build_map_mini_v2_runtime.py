#!/usr/bin/env python3
"""Promote the accepted Minimap V2 exact pixels and export Vanilla-safe media."""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageChops, ImageDraw

from runtime_texture_compat import content_uv, pad_to_power_of_two, power_of_two_size


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets/source/map/mini-v2"
RUNTIME_DIR = ROOT / "addon/AzerothExpeditionUI/Media/Map"
SOURCE_MANIFEST = SOURCE_DIR / "MAP-MINI-OVERHAUL-V2_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "MAP-MINI-OVERHAUL-V2_RuntimeManifest_v1.json"

ACCEPTED = {
    "frame": {
        "filename": "MapMiniFrame_SourceV2.png",
        "size": (184, 184),
        "sha256": "de7bc4e0282ab42b53c9639ce2dc25cb5c7cc60238eb1f614bc675071fa299d2",
        "component": "MAP.MINI.FRAME.V2",
    },
    "toggle_body": {
        "filename": "MapMiniAddonToggleBody_SourceV2.png",
        "size": (28, 25),
        "sha256": "d65f1ef25ce8bf0a40571d53734b2fdf4e9c0c54e18f6de7a1b7a4de6f24641f",
        "component": "MAP.MINI.ADDONS.TOGGLE.BODY.V2",
    },
    "toggle_glyph": {
        "filename": "MapMiniAddonToggleGlyph_SourceV2.png",
        "size": (10, 8),
        "sha256": "f8bd249fb7636fba2c92a6e85780b690394da7e848027dceb1a3a5b299a57d8b",
        "component": "MAP.MINI.ADDONS.TOGGLE.GLYPH.V2",
    },
    "socket": {
        "filename": "MapMiniAddonSocket_SourceV2.png",
        "size": (22, 22),
        "sha256": "4101315da0057cc77d7534f7569c4afdbf95af4d655dab0266c9d2328165c06d",
        "component": "MAP.MINI.ADDONS.SOCKET.V2",
    },
    "tray": {
        "filename": "MapMiniAddonTray_SourceV2.png",
        "size": (1494, 354),
        "sha256": "13e4d23f93fa6a04f42c0e0ca6b50b06bbda0e33ece393be4257b5c9c0ede81c",
        "component": "MAP.MINI.ADDONS.TRAY.V2",
    },
}

RUNTIME = {
    "frame": ("MapMiniFrameV2.tga", (184, 184)),
    "mask": ("MapMiniMaskV2.tga", (256, 256)),
    "toggle_body": ("MapMiniAddonToggleBodyV2.tga", (28, 25)),
    "toggle_glyph_down": ("MapMiniAddonToggleGlyphDownV2.tga", (10, 8)),
    "toggle_glyph_up": ("MapMiniAddonToggleGlyphUpV2.tga", (10, 8)),
    "toggle_glyph_left": ("MapMiniAddonToggleGlyphLeftV2.tga", (8, 10)),
    "toggle_glyph_right": ("MapMiniAddonToggleGlyphRightV2.tga", (8, 10)),
    "socket": ("MapMiniAddonSocketV2.tga", (22, 22)),
    "tray": ("MapMiniAddonTrayV2.tga", (270, 64)),
}

PROVIDER_RAW = {
    "frame": {
        "sha256": "e54e79c9cd8feed0411efa0adc419adc3b9f88bbcbc5fbfa1a7992fe00321f1f",
        "size": [1254, 1254],
        "attempt": 3,
        "calls": 3,
    },
    "hardware": {
        "sha256": "8d135fe42ddd3460cf9c945e591f1d15fa8f2e58c1b6b0c43c0e100cf854aa28",
        "size": [1254, 1254],
        "attempt": 2,
        "calls": 2,
    },
    "tray": {
        "sha256": "2d103d8517c352e1d058300f104202b3baa067932ec9607883cf223803d4ea70",
        "size": [1536, 1024],
        "attempt": 1,
        "calls": 1,
    },
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--promote-frame", type=Path)
    parser.add_argument("--promote-toggle-body", type=Path)
    parser.add_argument("--promote-toggle-glyph", type=Path)
    parser.add_argument("--promote-socket", type=Path)
    parser.add_argument("--promote-tray", type=Path)
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
        "visible_bbox_exclusive": list(rgba.getchannel("A").getbbox() or (0, 0, 0, 0)),
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
        "transparent_rgb_nonzero_values": transparent_rgb_nonzero(rgba),
    }


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    clear_transparent_rgb(image).save(path, format="PNG", compress_level=9)


def validate_accepted(path: Path, key: str) -> Image.Image:
    contract = ACCEPTED[key]
    resolved = path.resolve()
    if sha256(resolved) != contract["sha256"]:
        raise ValueError(f"accepted exact-pixels hash mismatch: {resolved}")
    with Image.open(resolved) as opened:
        image = clear_transparent_rgb(opened)
    if image.size != contract["size"]:
        raise ValueError(f"accepted exact-pixels size mismatch: {key} {image.size}")
    if transparent_rgb_nonzero(image):
        raise ValueError(f"accepted exact-pixels transparent RGB drifted: {key}")
    return image


def clear_frame_provider_interior(image: Image.Image) -> Image.Image:
    """Remove only sub-visible resampling residue inside the 140px map window."""

    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    yy, xx = np.ogrid[:184, :184]
    radius = np.sqrt((xx - 91.5) ** 2 + (yy - 91.5) ** 2)
    protected = radius <= 69.0
    rgba[protected] = 0
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def promote(args: argparse.Namespace) -> None:
    paths = {
        "frame": args.promote_frame,
        "toggle_body": args.promote_toggle_body,
        "toggle_glyph": args.promote_toggle_glyph,
        "socket": args.promote_socket,
        "tray": args.promote_tray,
    }
    supplied = [value is not None for value in paths.values()]
    if any(supplied) and not all(supplied):
        raise ValueError("promotion requires all five accepted exact-pixels inputs")
    if not all(supplied):
        return
    for key, path in paths.items():
        image = validate_accepted(path, key)
        if key == "frame":
            image = clear_frame_provider_interior(image)
        save_png(image, SOURCE_DIR / ACCEPTED[key]["filename"])


def make_round_mask() -> Image.Image:
    factor = 4
    size = 256
    high = Image.new("L", (size * factor, size * factor), 0)
    draw = ImageDraw.Draw(high)
    # One pixel of transparent breathing room prevents corner leakage at the provider edge.
    draw.ellipse((factor, factor, size * factor - factor - 1, size * factor - factor - 1), fill=255)
    alpha = high.resize((size, size), Image.Resampling.LANCZOS)
    alpha_array = np.asarray(alpha, dtype=np.uint8).copy()
    yy, xx = np.ogrid[:size, :size]
    radius = np.sqrt((xx - 127.5) ** 2 + (yy - 127.5) ** 2)
    # Hard outer guard: even sub-visible resampling values cannot expose map tiles
    # beyond the circular provider boundary.
    alpha_array[radius >= 127.0] = 0
    alpha = Image.fromarray(alpha_array, "L")
    rgba = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    rgba.putalpha(alpha)
    return clear_transparent_rgb(rgba)


def load_sources() -> dict[str, Image.Image]:
    result: dict[str, Image.Image] = {}
    for key, contract in ACCEPTED.items():
        path = SOURCE_DIR / contract["filename"]
        if not path.exists():
            raise ValueError(f"accepted source is missing: {path}")
        with Image.open(path) as opened:
            image = clear_transparent_rgb(opened)
        if image.size != contract["size"]:
            raise ValueError(f"accepted source size drifted: {key} {image.size}")
        result[key] = image
    result["mask"] = make_round_mask()
    return result


def validate_round_contract(sources: dict[str, Image.Image]) -> None:
    frame_alpha = np.asarray(sources["frame"].getchannel("A"), dtype=np.uint8)
    yy, xx = np.ogrid[:184, :184]
    radius = np.sqrt((xx - 91.5) ** 2 + (yy - 91.5) ** 2)
    if int(np.count_nonzero(frame_alpha[radius <= 69.0])) != 0:
        raise ValueError("frame material enters the protected 140x140 circular provider interior")

    mask_alpha = np.asarray(sources["mask"].getchannel("A"), dtype=np.uint8)
    corners = [mask_alpha[0, 0], mask_alpha[0, -1], mask_alpha[-1, 0], mask_alpha[-1, -1]]
    if any(int(value) != 0 for value in corners) or int(mask_alpha[128, 128]) != 255:
        raise ValueError("round minimap mask does not have transparent corners and opaque centre")
    my, mx = np.ogrid[:256, :256]
    mask_radius = np.sqrt((mx - 127.5) ** 2 + (my - 127.5) ** 2)
    if int(np.count_nonzero(mask_alpha[mask_radius >= 127.0])) != 0:
        raise ValueError("round minimap mask leaks outside its circular provider boundary")

    socket_alpha = np.asarray(sources["socket"].getchannel("A"), dtype=np.uint8)
    if int(socket_alpha[4:18, 4:18].max()) > 4:
        raise ValueError("socket material enters the protected dynamic icon interior")


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


def fit_tray(source: Image.Image) -> Image.Image:
    target = RUNTIME["tray"][1]
    resized = source.copy()
    resized.thumbnail(target, Image.Resampling.LANCZOS)
    if resized.size != target:
        raise ValueError(f"tray aspect no longer fits the accepted 270x64 runtime: {resized.size}")
    return clear_transparent_rgb(resized)


def export_runtime(sources: dict[str, Image.Image]) -> dict[str, Image.Image]:
    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    result: dict[str, Image.Image] = {}
    for key, (filename, logical_size) in RUNTIME.items():
        if key == "tray":
            logical = fit_tray(sources[key])
        elif key == "mask":
            logical = sources[key]
        elif key == "toggle_glyph_down":
            logical = sources["toggle_glyph"]
        elif key == "toggle_glyph_up":
            logical = sources["toggle_glyph"].transpose(Image.Transpose.ROTATE_180)
        elif key == "toggle_glyph_left":
            logical = sources["toggle_glyph"].transpose(Image.Transpose.ROTATE_270)
        elif key == "toggle_glyph_right":
            logical = sources["toggle_glyph"].transpose(Image.Transpose.ROTATE_90)
        else:
            logical = sources[key].resize(logical_size, Image.Resampling.LANCZOS)
        logical = clear_transparent_rgb(logical)
        texture = pad_to_power_of_two(logical)
        path = RUNTIME_DIR / filename
        texture.save(path, format="TGA")
        with Image.open(path) as opened:
            roundtrip = opened.convert("RGBA")
        if ImageChops.difference(texture, roundtrip).getbbox() is not None:
            raise ValueError(f"TGA roundtrip changed pixels: {path}")
        logical_roundtrip = roundtrip.crop((0, 0, *logical_size))
        if ImageChops.difference(logical, logical_roundtrip).getbbox() is not None:
            raise ValueError(f"TGA container changed logical pixels: {path}")
        header = tga_header(path)
        if (
            header["image_type"] != 2
            or header["bits_per_pixel"] != 32
            or (header["width"], header["height"]) != power_of_two_size(logical_size)
        ):
            raise ValueError(f"Vanilla TGA contract drifted: {path}: {header}")
        result[key] = logical_roundtrip
    return result


def media_record(path: Path, image: Image.Image) -> dict[str, Any]:
    return {
        "file": repository_path(path),
        "sha256": sha256(path),
        "metrics": image_metrics(image),
    }


def write_manifests(sources: dict[str, Image.Image], runtimes: dict[str, Image.Image]) -> None:
    source_components = {
        key: {
            "component": ACCEPTED[key]["component"],
            **media_record(SOURCE_DIR / ACCEPTED[key]["filename"], sources[key]),
        }
        for key in ACCEPTED
    }
    source_manifest = {
        "schema": "aeui-map-mini-overhaul-v2-source-manifest-v1",
        "schema_version": 1,
        "module": "map",
        "batch": "MAP-MINI-OVERHAUL-V2",
        "status": "runtime-exported",
        "phase": "P5",
        "accepted_on": "2026-08-17",
        "user_acceptance": {
            "exact_statement": (
                "接受 MAP-MINI-OVERHAUL-V2 exact pixels；允许提升 source/runtime、"
                "导出正式媒体并接入 addon。要保证小地图确实是圆形，内部的地图不能超出罗盘边框"
            ),
            "exact_pixels_review_sha256": "9c867218f683532b530796195b3132a6c691be811ae2f0a4498222b25b26fca2",
            "p4_p5_and_integration_authorized": True,
        },
        "provenance": {
            "executor": "imagegen-0-143-0",
            "provider_raw": PROVIDER_RAW,
            "maximum_imagegen_calls_per_segment": 5,
            "flow_errors_counted_as_imagegen_calls": False,
            "prompt": "docs/modules/map/CURRENT.md",
            "global_prompt": "docs/GLOBAL_ART_BASELINE.md",
            "module_prompt": "docs/modules/map/ART_BASELINE.md",
            "locked_reference_sha256": "9e6a38dbaa2e7df82480c4fe8ca32ca2c931fa016a8264f26964903468ac2ea6",
            "roughness_reference_sha256": "272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8",
        },
        "components": source_components,
        "deterministic_transform": {
            "frame": "accepted 184x184 exact pixels; protected radius 69 has zero alpha; only sub-visible resampling residue cleared",
            "mask": "independent 256x256 antialiased circular alpha mask; transparent corners",
            "hardware": "accepted exact body/glyph/socket pixels; no generative state synthesis",
            "tray": "accepted keyed source; aspect-preserving 270x64 runtime; nine-slice only",
            "transparent_rgb_cleared": True,
            "generative_postprocess": False,
        },
        "runtime_manifest": repository_path(RUNTIME_MANIFEST),
    }
    SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    SOURCE_MANIFEST.write_text(
        json.dumps(source_manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    runtime_components: dict[str, Any] = {}
    component_ids = {
        "frame": "MAP.MINI.FRAME.V2",
        "mask": "MAP.MINI.MASK.V2",
        "toggle_body": "MAP.MINI.ADDONS.TOGGLE.BODY.V2",
        "toggle_glyph_down": "MAP.MINI.ADDONS.TOGGLE.GLYPH.DOWN.V2",
        "toggle_glyph_up": "MAP.MINI.ADDONS.TOGGLE.GLYPH.UP.V2",
        "toggle_glyph_left": "MAP.MINI.ADDONS.TOGGLE.GLYPH.LEFT.V2",
        "toggle_glyph_right": "MAP.MINI.ADDONS.TOGGLE.GLYPH.RIGHT.V2",
        "socket": "MAP.MINI.ADDONS.SOCKET.V2",
        "tray": "MAP.MINI.ADDONS.TRAY.V2",
    }
    for key, (filename, logical_size) in RUNTIME.items():
        path = RUNTIME_DIR / filename
        runtime_components[key] = {
            "component": component_ids[key],
            **media_record(path, runtimes[key]),
            "logical_size": list(logical_size),
            "texture_size": list(power_of_two_size(logical_size)),
            "content_uv": content_uv(logical_size),
            "tga_header": tga_header(path),
        }
    runtime_manifest = {
        "schema": "aeui-map-mini-overhaul-v2-runtime-manifest-v1",
        "schema_version": 1,
        "module": "map",
        "batch": "MAP-MINI-OVERHAUL-V2",
        "status": "runtime-exported",
        "phase": "P5",
        "runtime_contract": "2.0",
        "source_manifest": repository_path(SOURCE_MANIFEST),
        "runtime": runtime_components,
        "layout_contract": {
            "provider": "pfUI.minimap and Minimap",
            "reference_content_ui": [140, 140],
            "reference_frame_ui": [184, 184],
            "frame_central_alpha_exclusion": "140x140 centred circle",
            "provider_mask_texture": "MapMiniMaskV2.tga",
            "provider_mask_is_independent_of_frame": True,
            "map_tiles_player_arrow_pfquest_pins_share_masked_provider": True,
            "map_content_can_cross_compass_inner_edge": False,
            "minimum_screen_inset_ui": 24,
            "zone_and_coordinates_are_runtime_text_inside_map": True,
            "tray_nine_slice_uv_fraction": {"x": [0.0, 0.13, 0.87, 1.0], "y": [0.0, 0.25, 0.75, 1.0]},
            "addon_positions": ["bottom", "left", "top", "right"],
            "addon_counts_reviewed": [0, 4, 6, 10],
            "plugin_icons_and_behaviour_remain_provider_owned": True,
            "farmmode_shell_reuse": False,
            "world_map_integration_remains_paused": True,
            "vanilla_power_of_two_texture_containers": True,
        },
    }
    RUNTIME_MANIFEST.write_text(
        json.dumps(runtime_manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


def main() -> int:
    args = parse_args()
    promote(args)
    sources = load_sources()
    validate_round_contract(sources)
    runtimes = export_runtime(sources)
    write_manifests(sources, runtimes)
    print(json.dumps({
        "status": "pass",
        "source_manifest": repository_path(SOURCE_MANIFEST),
        "runtime_manifest": repository_path(RUNTIME_MANIFEST),
        "runtime_files": len(RUNTIME),
        "round_mask": True,
        "frame_provider_interior_clear": True,
    }, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
