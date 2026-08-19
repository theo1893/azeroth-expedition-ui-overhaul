#!/usr/bin/env python3
"""Re-export accepted Character art at two texels per WoW UI unit.

The accepted ImageGen source pixels remain authoritative.  The only source
pixel mutation supported here is the user-authorized Character slot opening
repair: Alpha/RGB are cleared inside a fixed 31x31 UI-unit icon window without
painting or reconstructing visible art.  CharacterFrame geometry and hitboxes
stay at their native 384x512 / 37x37 UI-unit sizes.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFont

from runtime_texture_compat import pad_to_power_of_two, power_of_two_size


ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ROOT / "assets/source/character"
MEDIA = ROOT / "addon/AzerothExpeditionUI/Media/Character"
PREVIEW = (
    ROOT
    / "generated/character/texel-density-2x/CharacterTexelDensity2x_Comparison.png"
)
SLOT_OPENING_PREVIEW = (
    ROOT
    / "generated/character/slot-opening-31/CharacterSlotOpening31_Comparison.png"
)

TEXEL_DENSITY = 2
UPGRADE_CONTRACT = "CHARACTER-TEXEL-DENSITY-2X"
UPGRADE_DATE = "2026-08-19"
SLOT_OPENING_REPAIR_CONTRACT = "CHAR-SLOT-OPENING-31-V1"
SLOT_OPENING_SOURCE = (12, 12, 136, 136)
SLOT_OPENING_RUNTIME = (6, 6, 68, 68)
SLOT_OPENING_LOGICAL = (3, 3, 34, 34)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def repo_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def read_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def open_accepted(path: Path, expected_sha256: str) -> Image.Image:
    if sha256(path) != expected_sha256:
        raise ValueError(f"accepted source SHA-256 changed: {path}")
    with Image.open(path) as opened:
        return opened.convert("RGBA")


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def clear_alpha_box(
    image: Image.Image,
    box: tuple[int, int, int, int],
) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    left, top, right, bottom = box
    rgba[top:bottom, left:right] = 0
    return Image.fromarray(rgba, "RGBA")


def cleared_visible_pixel_count(before: Image.Image, after: Image.Image) -> int:
    before_alpha = np.asarray(before.convert("RGBA"), dtype=np.uint8)[:, :, 3]
    after_alpha = np.asarray(after.convert("RGBA"), dtype=np.uint8)[:, :, 3]
    return int(np.count_nonzero((before_alpha > 0) & (after_alpha == 0)))


def clamp_central_alpha(
    image: Image.Image,
    box: tuple[int, int, int, int],
) -> tuple[Image.Image, int]:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    left, top, right, bottom = box
    alpha = rgba[top:bottom, left:right, 3]
    selected = (alpha >= 250) & (alpha <= 254)
    count = int(np.count_nonzero(selected))
    alpha[selected] = 255
    rgba[top:bottom, left:right, 3] = alpha
    return Image.fromarray(rgba, "RGBA"), count


def resize_runtime(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    return clear_transparent_rgb(
        image.resize(size, Image.Resampling.LANCZOS)
    )


def visible_green_pixels(image: Image.Image) -> int:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8)
    return int(
        np.count_nonzero(
            (rgba[:, :, 3] > 0)
            & (rgba[:, :, 0] <= 32)
            & (rgba[:, :, 1] >= 224)
            & (rgba[:, :, 2] <= 32)
        )
    )


def transparent_rgb_nonzero(image: Image.Image) -> int:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8)
    transparent = rgba[:, :, 3] == 0
    return int(np.count_nonzero(rgba[transparent, :3]))


def metrics(image: Image.Image) -> dict[str, Any]:
    rgba = image.convert("RGBA")
    alpha = rgba.getchannel("A")
    histogram = alpha.histogram()
    return {
        "size": list(rgba.size),
        "mode": rgba.mode,
        "pixel_sha256": pixel_sha256(rgba),
        "visible_bbox_exclusive": list(alpha.getbbox() or (0, 0, 0, 0)),
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
        "visible_green_spill_pixels": visible_green_pixels(rgba),
        "transparent_rgb_nonzero_pixels": transparent_rgb_nonzero(rgba),
    }


def tga_header(path: Path) -> dict[str, Any]:
    data = path.read_bytes()
    if len(data) < 18:
        raise ValueError(f"incomplete TGA header: {path}")
    width, height = struct.unpack("<HH", data[12:16])
    return {
        "image_type": data[2],
        "width": width,
        "height": height,
        "bits_per_pixel": data[16],
        "descriptor": data[17],
        "top_origin": bool(data[17] & 0x20),
    }


def save_png(path: Path, image: Image.Image) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG")


def save_tga(path: Path, sampled: Image.Image) -> Image.Image:
    path.parent.mkdir(parents=True, exist_ok=True)
    texture = pad_to_power_of_two(clear_transparent_rgb(sampled))
    texture.save(path, format="TGA")
    with Image.open(path) as opened:
        roundtrip = opened.convert("RGBA")
    if ImageChops.difference(roundtrip, texture).getbbox() is not None:
        raise ValueError(f"TGA roundtrip changed pixels: {path}")
    header = tga_header(path)
    if (
        header["image_type"] != 2
        or header["bits_per_pixel"] != 32
        or (header["width"], header["height"]) != texture.size
        or max(texture.size) > 1024
    ):
        raise ValueError(f"invalid Turtle WoW TGA: {path}: {header}")
    return roundtrip


def density_upgrade() -> dict[str, Any]:
    return {
        "contract": UPGRADE_CONTRACT,
        "authorized_on": UPGRADE_DATE,
        "user_instruction": "修复",
        "texels_per_ui_unit": TEXEL_DENSITY,
        "ui_geometry_changed": False,
        "hitboxes_changed": False,
        "accepted_source_pixels_changed": False,
        "imagegen_calls": 0,
        "operation": (
            "direct LANCZOS reduction from accepted high-resolution source "
            "to 2x sampled runtime pixels, transparent RGB clear, and POT TGA packing"
        ),
    }


def mark_source_manifest(manifest: dict[str, Any]) -> None:
    manifest["runtime_density_upgrade"] = density_upgrade()
    provenance = manifest.get("provenance")
    if isinstance(provenance, dict):
        text = str(provenance.get("postprocess", ""))
        if "2x texel-density" not in text:
            provenance["postprocess"] = (
                text.rstrip("; ")
                + "; deterministic 2x texel-density runtime export from accepted source"
            ).lstrip("; ")


def mark_runtime_manifest(
    manifest: dict[str, Any],
    contract: str,
) -> None:
    manifest["runtime_contract"] = contract
    manifest["texel_density"] = {
        "texels_per_ui_unit": TEXEL_DENSITY,
        "ui_geometry_changed": False,
        "target_physical_scale": "up to 2 screen pixels per UI unit",
    }


def export_shell() -> tuple[Image.Image, Image.Image]:
    directory = SOURCE_ROOT / "frame-shell-v3"
    source_manifest_path = directory / "CHAR-V3-A1-SHELL_SourceManifest_v1.json"
    runtime_manifest_path = directory / "CHAR-V3-A1-SHELL_RuntimeManifest_v1.json"
    source_manifest = read_json(source_manifest_path)
    runtime_manifest = read_json(runtime_manifest_path)
    source_record = source_manifest["accepted_assets"]["source"]
    source_path = ROOT / source_record["file"]
    source = open_accepted(source_path, source_record["sha256"])
    if source.size != (1536, 2048):
        raise ValueError("Character shell source geometry changed")

    runtime = resize_runtime(source, (768, 1024))
    runtime = clear_alpha_box(runtime, (130, 156, 596, 604))
    runtime = clear_alpha_box(runtime, (134, 582, 594, 738))
    runtime = clear_transparent_rgb(runtime)
    runtime_master_path = directory / "CharacterFrameShell_RuntimeMasterV3.png"
    save_png(runtime_master_path, runtime)

    slices = {
        "top_left": ((0, 0, 512, 512), (256, 256), "CharacterFrameShellTopLeftV3.tga"),
        "top_right": ((512, 0, 768, 512), (128, 256), "CharacterFrameShellTopRightV3.tga"),
        "bottom_left": ((0, 512, 512, 1024), (256, 256), "CharacterFrameShellBottomLeftV3.tga"),
        "bottom_right": ((512, 512, 768, 1024), (128, 256), "CharacterFrameShellBottomRightV3.tga"),
    }
    sampled_slices: dict[str, list[int]] = {}
    for key, (box, logical_ui, filename) in slices.items():
        sampled = runtime.crop(box)
        target = MEDIA / filename
        roundtrip = save_tga(target, sampled)
        record = runtime_manifest["runtime"][key]
        record.update(
            {
                "file": repo_path(target),
                "sha256": sha256(target),
                "logical_size_ui": list(logical_ui),
                "sampled_size": list(sampled.size),
                "texture_size": list(roundtrip.size),
                "texels_per_ui_unit": TEXEL_DENSITY,
                "pixel_sha256": pixel_sha256(roundtrip),
                "tga": tga_header(target),
            }
        )
        sampled_slices[key] = list(box)

    source_manifest["accepted_assets"]["runtime_master"] = {
        "file": repo_path(runtime_master_path),
        "sha256": sha256(runtime_master_path),
        "metrics": metrics(runtime),
        "texels_per_ui_unit": TEXEL_DENSITY,
        "logical_size_ui": [384, 512],
    }
    transform = source_manifest["deterministic_transform"]
    transform["green_spill_runtime_pixels_alpha_cleared_after_resize"] = 0
    transform["sampled_runtime_size"] = [768, 1024]
    transform["sampled_slices"] = sampled_slices
    transform["texels_per_ui_unit"] = TEXEL_DENSITY
    mark_source_manifest(source_manifest)
    mark_runtime_manifest(runtime_manifest, "1.1")
    runtime_manifest["layout_contract"]["texels_per_ui_unit"] = TEXEL_DENSITY
    runtime_manifest["layout_contract"]["ui_geometry_stretch"] = False
    write_json(source_manifest_path, source_manifest)
    write_json(runtime_manifest_path, runtime_manifest)

    legacy = resize_runtime(source, (384, 512))
    legacy = clear_alpha_box(legacy, (65, 78, 298, 302))
    legacy = clear_alpha_box(legacy, (67, 291, 297, 369))
    return legacy, runtime


def export_single_component(
    *,
    directory_name: str,
    source_manifest_name: str,
    runtime_manifest_name: str,
    asset_key: str,
    runtime_key: str,
    runtime_master_name: str,
    tga_name: str,
    logical_ui: tuple[int, int],
    runtime_contract: str,
) -> tuple[Image.Image, Image.Image]:
    directory = SOURCE_ROOT / directory_name
    source_manifest_path = directory / source_manifest_name
    runtime_manifest_path = directory / runtime_manifest_name
    source_manifest = read_json(source_manifest_path)
    runtime_manifest = read_json(runtime_manifest_path)
    source_record = source_manifest["accepted_assets"]["source"]
    source_path = ROOT / source_record["file"]
    source = open_accepted(source_path, source_record["sha256"])
    sampled_size = tuple(value * TEXEL_DENSITY for value in logical_ui)
    runtime = resize_runtime(source, sampled_size)
    runtime_master_path = directory / runtime_master_name
    save_png(runtime_master_path, runtime)
    target = MEDIA / tga_name
    roundtrip = save_tga(target, runtime)

    source_manifest["accepted_assets"]["runtime_master"] = {
        "file": repo_path(runtime_master_path),
        "sha256": sha256(runtime_master_path),
        "metrics": metrics(runtime),
        "texels_per_ui_unit": TEXEL_DENSITY,
        "logical_size_ui": list(logical_ui),
    }
    transform = source_manifest.get("deterministic_transform")
    if isinstance(transform, dict):
        transform["sampled_runtime_size"] = list(sampled_size)
        transform["texels_per_ui_unit"] = TEXEL_DENSITY
        for key in (
            "runtime_green_spill_alpha_cleared",
            "runtime_resample_green_spill_alpha_cleared",
        ):
            if key in transform:
                transform[key] = 0
        spill = transform.get("green_spill_alpha_cleared")
        if isinstance(spill, dict) and "runtime" in spill:
            spill["runtime"] = 0
    mark_source_manifest(source_manifest)

    runtime_record = runtime_manifest["runtime"][runtime_key]
    texture_size = roundtrip.size
    runtime_record.update(
        {
            "file": repo_path(target),
            "sha256": sha256(target),
            "logical_size": list(logical_ui),
            "sampled_size": list(sampled_size),
            "texture_size": list(texture_size),
            "texels_per_ui_unit": TEXEL_DENSITY,
            "uv": [
                0.0,
                sampled_size[0] / texture_size[0],
                0.0,
                sampled_size[1] / texture_size[1],
            ],
            "pixel_sha256": pixel_sha256(roundtrip),
            "logical_pixel_sha256": pixel_sha256(runtime),
            "sampled_pixel_sha256": pixel_sha256(runtime),
            "tga": tga_header(target),
        }
    )
    mark_runtime_manifest(runtime_manifest, runtime_contract)
    runtime_manifest["layout_contract"]["texels_per_ui_unit"] = TEXEL_DENSITY
    runtime_manifest["layout_contract"]["ui_geometry_stretch"] = False
    write_json(source_manifest_path, source_manifest)
    write_json(runtime_manifest_path, runtime_manifest)
    return resize_runtime(source, logical_ui), runtime


def export_resistance() -> tuple[list[Image.Image], list[Image.Image]]:
    directory = SOURCE_ROOT / "res-wells-v3"
    source_manifest_path = directory / "CHAR-V3-D1-RES-WELLS_SourceManifest_v1.json"
    runtime_manifest_path = directory / "CHAR-V3-D1-RES-WELLS_RuntimeManifest_v1.json"
    source_manifest = read_json(source_manifest_path)
    runtime_manifest = read_json(runtime_manifest_path)
    legacy_images: list[Image.Image] = []
    runtime_images: list[Image.Image] = []
    clamp_counts: list[int] = []

    for index, source_entry in enumerate(source_manifest["accepted_assets"], start=1):
        source_record = source_entry["source"]
        source_path = ROOT / source_record["file"]
        source = open_accepted(source_path, source_record["sha256"])
        runtime = resize_runtime(source, (64, 58))
        runtime, clamped = clamp_central_alpha(runtime, (16, 12, 48, 44))
        runtime = clear_transparent_rgb(runtime)
        clamp_counts.append(clamped)
        runtime_master_path = directory / f"CharacterResistanceWell{index}_RuntimeMasterV3.png"
        save_png(runtime_master_path, runtime)
        target = MEDIA / f"CharacterResistanceWell{index}V3.tga"
        roundtrip = save_tga(target, runtime)
        source_entry["runtime_master"] = {
            "file": repo_path(runtime_master_path),
            "sha256": sha256(runtime_master_path),
            "size": [64, 58],
            "pixel_sha256": pixel_sha256(runtime),
            "texels_per_ui_unit": TEXEL_DENSITY,
            "logical_size_ui": [32, 29],
        }
        record = runtime_manifest["runtime"][index - 1]
        record.update(
            {
                "file": repo_path(target),
                "sha256": sha256(target),
                "logical_size": [32, 29],
                "sampled_size": [64, 58],
                "texture_size": list(roundtrip.size),
                "texels_per_ui_unit": TEXEL_DENSITY,
                "uv": [0.0, 1.0, 0.0, 58 / 64],
                "pixel_sha256": pixel_sha256(roundtrip),
                "logical_pixel_sha256": pixel_sha256(runtime),
                "sampled_pixel_sha256": pixel_sha256(runtime),
                "tga": tga_header(target),
            }
        )
        legacy_images.append(resize_runtime(source, (32, 29)))
        runtime_images.append(runtime)

    transform = source_manifest["deterministic_transform"]
    transform["runtime_size"] = [64, 58]
    transform["logical_size_ui"] = [32, 29]
    transform["runtime_central_safe_area"] = [16, 12, 48, 44]
    transform["runtime_second_alpha_clamp_pixels_each"] = clamp_counts
    transform["texels_per_ui_unit"] = TEXEL_DENSITY
    mark_source_manifest(source_manifest)
    mark_runtime_manifest(runtime_manifest, "1.3")
    runtime_manifest["layout_contract"]["texels_per_ui_unit"] = TEXEL_DENSITY
    runtime_manifest["layout_contract"]["ui_geometry_stretch"] = False
    write_json(source_manifest_path, source_manifest)
    write_json(runtime_manifest_path, runtime_manifest)
    return legacy_images, runtime_images


def export_slot_base() -> tuple[
    dict[str, Image.Image],
    dict[str, Image.Image],
    dict[str, Image.Image],
]:
    directory = SOURCE_ROOT / "slot-base-v3"
    source_manifest_path = directory / "CHAR-V3-E1-SLOT-BASE_SourceManifest_v1.json"
    runtime_manifest_path = directory / "CHAR-V3-E1-SLOT-BASE_RuntimeManifest_v1.json"
    source_manifest = read_json(source_manifest_path)
    runtime_manifest = read_json(runtime_manifest_path)
    origins = {"A": (0, 0), "B": (128, 0), "C": (0, 128), "D": (128, 128)}
    runtime_images: dict[str, Image.Image] = {}
    legacy_images: dict[str, Image.Image] = {}
    previous_runtime_images: dict[str, Image.Image] = {}
    cleared_by_variant: dict[str, int] = {}
    atlas = Image.new("RGBA", (256, 256), (0, 0, 0, 0))

    for key, origin in origins.items():
        entry = source_manifest["accepted_assets"][key]
        source_record = entry["source"]
        source_path = ROOT / source_record["file"]
        original_source = open_accepted(source_path, source_record["sha256"])
        previous_runtime = clear_alpha_box(
            resize_runtime(original_source, (74, 74)),
            (8, 8, 66, 66),
        )
        source = clear_transparent_rgb(
            clear_alpha_box(original_source, SLOT_OPENING_SOURCE)
        )
        cleared_count = cleared_visible_pixel_count(original_source, source)
        previous_repair = entry.get("slot_opening_repair")
        previous_cleared = 0
        if isinstance(previous_repair, dict):
            previous_cleared = int(
                previous_repair.get("source_visible_pixels_alpha_cleared", 0)
            )
        recorded_cleared = cleared_count or previous_cleared
        cleared_by_variant[key] = recorded_cleared
        if ImageChops.difference(original_source, source).getbbox() is not None:
            save_png(source_path, source)
        source_record.update(
            {
                "sha256": sha256(source_path),
                "metrics": metrics(source),
            }
        )
        entry["slot_opening_repair"] = {
            "contract": SLOT_OPENING_REPAIR_CONTRACT,
            "source_alpha_clear_exclusive": list(SLOT_OPENING_SOURCE),
            "source_visible_pixels_alpha_cleared": recorded_cleared,
            "painted_or_synthesized_pixels": 0,
        }
        runtime = resize_runtime(source, (74, 74))
        runtime = clear_alpha_box(runtime, SLOT_OPENING_RUNTIME)
        runtime = clear_transparent_rgb(runtime)
        runtime_master_path = directory / f"CharacterSlotBase{key}_RuntimeMasterV3.png"
        save_png(runtime_master_path, runtime)
        atlas.alpha_composite(runtime, origin)
        entry["runtime_master"] = {
            "file": repo_path(runtime_master_path),
            "sha256": sha256(runtime_master_path),
            "metrics": metrics(runtime),
            "texels_per_ui_unit": TEXEL_DENSITY,
            "logical_size_ui": [37, 37],
        }
        record = runtime_manifest["runtime"]["variants"][key]
        record.update(
            {
                "cell_origin": list(origin),
                "logical_size": [37, 37],
                "sampled_size": [74, 74],
                "cell_size": [128, 128],
                "texels_per_ui_unit": TEXEL_DENSITY,
                "uv": [
                    origin[0] / 256,
                    (origin[0] + 74) / 256,
                    origin[1] / 256,
                    (origin[1] + 74) / 256,
                ],
                "logical_pixel_sha256": pixel_sha256(runtime),
                "sampled_pixel_sha256": pixel_sha256(runtime),
            }
        )
        legacy_images[key] = clear_alpha_box(
            resize_runtime(source, (37, 37)), SLOT_OPENING_LOGICAL
        )
        previous_runtime_images[key] = previous_runtime
        runtime_images[key] = runtime

    atlas = clear_transparent_rgb(atlas)
    atlas_master_path = directory / "CharacterSlotBaseAtlas_RuntimeMasterV3.png"
    save_png(atlas_master_path, atlas)
    target = MEDIA / "CharacterSlotBaseAtlasV3.tga"
    roundtrip = save_tga(target, atlas)
    runtime_manifest["runtime"].update(
        {
            "file": repo_path(target),
            "sha256": sha256(target),
            "texture_size": list(roundtrip.size),
            "pixel_sha256": pixel_sha256(roundtrip),
            "texels_per_ui_unit": TEXEL_DENSITY,
            "tga": tga_header(target),
        }
    )
    transform = source_manifest["deterministic_transform"]
    transform["logical_size_ui"] = [37, 37]
    transform["runtime_size"] = [74, 74]
    transform["source_center_alpha_clear_exclusive"] = list(SLOT_OPENING_SOURCE)
    transform["runtime_center_alpha_clear_exclusive"] = list(SLOT_OPENING_RUNTIME)
    transform["logical_center_alpha_clear_exclusive"] = list(SLOT_OPENING_LOGICAL)
    transform["runtime_atlas_size"] = [256, 256]
    transform["runtime_atlas_cell_origins"] = {
        key: list(value) for key, value in origins.items()
    }
    transform["texels_per_ui_unit"] = TEXEL_DENSITY
    source_manifest["accepted_assets"]["atlas_runtime_master"] = {
        "file": repo_path(atlas_master_path),
        "sha256": sha256(atlas_master_path),
        "size": [256, 256],
        "pixel_sha256": pixel_sha256(atlas),
    }
    source_manifest["slot_opening_repair"] = {
        "contract": SLOT_OPENING_REPAIR_CONTRACT,
        "authorized_on": UPGRADE_DATE,
        "user_instruction": "执行修复",
        "reason": (
            "pfUI keeps each provider icon at 31x31 inside the native 37x37 "
            "button, while the previous AEUI frame exposed only 29x29"
        ),
        "source_alpha_clear_exclusive": list(SLOT_OPENING_SOURCE),
        "runtime_alpha_clear_exclusive": list(SLOT_OPENING_RUNTIME),
        "logical_icon_safe_area": list(SLOT_OPENING_LOGICAL),
        "source_visible_pixels_alpha_cleared_by_variant": cleared_by_variant,
        "imagegen_calls": 0,
        "visible_rgb_painted_or_synthesized": False,
        "button_geometry_changed": False,
        "provider_icon_geometry_changed": False,
    }
    provenance = source_manifest.get("provenance")
    if isinstance(provenance, dict):
        text = str(provenance.get("postprocess", ""))
        marker = "31x31 provider-icon opening Alpha/RGB clear"
        if marker not in text:
            provenance["postprocess"] = (
                text.rstrip("; ") + "; " + marker
            ).lstrip("; ")
    mark_source_manifest(source_manifest)
    mark_runtime_manifest(runtime_manifest, "1.4.1")
    runtime_manifest["layout_contract"]["texels_per_ui_unit"] = TEXEL_DENSITY
    runtime_manifest["layout_contract"]["ui_geometry_stretch"] = False
    runtime_manifest["layout_contract"]["dynamic_icon_safe_area"] = list(
        SLOT_OPENING_LOGICAL
    )
    runtime_manifest["slot_opening_repair"] = {
        "contract": SLOT_OPENING_REPAIR_CONTRACT,
        "source_alpha_clear_exclusive": list(SLOT_OPENING_SOURCE),
        "runtime_alpha_clear_exclusive": list(SLOT_OPENING_RUNTIME),
        "logical_icon_safe_area": list(SLOT_OPENING_LOGICAL),
        "provider_icon_size": [31, 31],
        "button_size": [37, 37],
        "button_geometry_changed": False,
    }
    write_json(source_manifest_path, source_manifest)
    write_json(runtime_manifest_path, runtime_manifest)
    return legacy_images, runtime_images, previous_runtime_images


def export_slot_interactions() -> tuple[dict[str, Image.Image], dict[str, Image.Image]]:
    directory = SOURCE_ROOT / "slot-states-v3"
    source_manifest_path = directory / "CHAR-V3-E2-SLOT-INTERACTION_SourceManifest_v1.json"
    runtime_manifest_path = directory / "CHAR-V3-E2-SLOT-INTERACTION_RuntimeManifest_v1.json"
    source_manifest = read_json(source_manifest_path)
    runtime_manifest = read_json(runtime_manifest_path)
    source_keys = {"highlight": "hover", "pushed": "pressed", "disabled": "disabled"}
    origins = {"highlight": (0, 0), "pushed": (128, 0), "disabled": (256, 0)}
    runtime_images: dict[str, Image.Image] = {}
    legacy_images: dict[str, Image.Image] = {}
    atlas = Image.new("RGBA", (512, 128), (0, 0, 0, 0))

    for state, source_key in source_keys.items():
        entry = source_manifest["accepted_assets"][source_key]
        source_record = entry["source"]
        source_path = ROOT / source_record["file"]
        source = open_accepted(source_path, source_record["sha256"])
        runtime = resize_runtime(source, (74, 74))
        runtime_master_path = directory / (
            "CharacterSlot"
            + source_key.capitalize()
            + "_RuntimeMasterV3.png"
        )
        save_png(runtime_master_path, runtime)
        origin = origins[state]
        atlas.alpha_composite(runtime, origin)
        entry["runtime_master"] = {
            "file": repo_path(runtime_master_path),
            "sha256": sha256(runtime_master_path),
            "size": [74, 74],
            "pixel_sha256": pixel_sha256(runtime),
            "texels_per_ui_unit": TEXEL_DENSITY,
            "logical_size_ui": [37, 37],
        }
        record = runtime_manifest["runtime"]["states"][state]
        record.update(
            {
                "cell_origin": list(origin),
                "logical_size": [37, 37],
                "sampled_size": [74, 74],
                "cell_size": [128, 128],
                "texels_per_ui_unit": TEXEL_DENSITY,
                "uv": [
                    origin[0] / 512,
                    (origin[0] + 74) / 512,
                    0.0,
                    74 / 128,
                ],
                "logical_pixel_sha256": pixel_sha256(runtime),
                "sampled_pixel_sha256": pixel_sha256(runtime),
            }
        )
        legacy_images[state] = resize_runtime(source, (37, 37))
        runtime_images[state] = runtime

    atlas = clear_transparent_rgb(atlas)
    atlas_master_path = directory / "CharacterSlotInteractionAtlas_RuntimeMasterV3.png"
    save_png(atlas_master_path, atlas)
    target = MEDIA / "CharacterSlotInteractionAtlasV3.tga"
    roundtrip = save_tga(target, atlas)
    runtime_manifest["runtime"].update(
        {
            "file": repo_path(target),
            "sha256": sha256(target),
            "texture_size": list(roundtrip.size),
            "pixel_sha256": pixel_sha256(roundtrip),
            "texels_per_ui_unit": TEXEL_DENSITY,
            "tga": tga_header(target),
        }
    )
    transform = source_manifest["deterministic_transform"]
    transform["logical_size_ui"] = [37, 37]
    transform["runtime_size"] = [74, 74]
    transform["atlas_size"] = [512, 128]
    transform["atlas_cell_origins"] = {
        state: list(origin) for state, origin in origins.items()
    }
    transform["texels_per_ui_unit"] = TEXEL_DENSITY
    transform["postprocess"] = (
        "accepted source to 74x74 sampled runtime reduction; fixed 2x POT atlas packing"
    )
    source_manifest["accepted_assets"]["atlas_runtime_master"] = {
        "file": repo_path(atlas_master_path),
        "sha256": sha256(atlas_master_path),
        "size": [512, 128],
        "pixel_sha256": pixel_sha256(atlas),
    }
    mark_source_manifest(source_manifest)
    mark_runtime_manifest(runtime_manifest, "1.5")
    runtime_manifest["layout_contract"]["texels_per_ui_unit"] = TEXEL_DENSITY
    runtime_manifest["layout_contract"]["ui_geometry_stretch"] = False
    write_json(source_manifest_path, source_manifest)
    write_json(runtime_manifest_path, runtime_manifest)
    return legacy_images, runtime_images


def composite_preview(
    shell: Image.Image,
    model: Image.Image,
    stats: Image.Image,
    resistance: list[Image.Image],
    slots: dict[str, Image.Image],
    scale: int,
) -> Image.Image:
    panel = shell.copy()
    panel.alpha_composite(model, (65 * scale, 78 * scale))
    panel.alpha_composite(stats, (67 * scale, 291 * scale))
    for index, key in enumerate(("A", "B", "C", "D")):
        panel.alpha_composite(slots[key], (20 * scale, (74 + 41 * index) * scale))
        panel.alpha_composite(slots[key], (327 * scale, (74 + 41 * index) * scale))
    for index, well in enumerate(resistance):
        panel.alpha_composite(well, ((82 + 38 * index) * scale, 263 * scale))
    return panel


def write_preview(
    legacy: Image.Image,
    upgraded: Image.Image,
) -> None:
    legacy_physical = legacy.resize(upgraded.size, Image.Resampling.BILINEAR)
    margin = 24
    label_height = 42
    board = Image.new(
        "RGBA",
        (
            upgraded.width * 2 + margin * 3,
            upgraded.height + label_height + margin * 2,
        ),
        (20, 17, 14, 255),
    )
    board.alpha_composite(legacy_physical, (margin, label_height + margin))
    board.alpha_composite(
        upgraded,
        (upgraded.width + margin * 2, label_height + margin),
    )
    draw = ImageDraw.Draw(board)
    draw.text((margin, 14), "OLD 1x runtime enlarged to 2 screen px/UI", fill=(220, 194, 146, 255))
    draw.text(
        (upgraded.width + margin * 2, 14),
        "NEW 2x runtime at 2 screen px/UI",
        fill=(220, 194, 146, 255),
    )
    PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    board.save(PREVIEW, format="PNG")


def build_provider_icon() -> Image.Image:
    """Create representative provider-owned icon pixels at the real 31x31 geometry."""
    size = 62
    icon = Image.new("RGBA", (size, size), (34, 45, 42, 255))
    draw = ImageDraw.Draw(icon)
    for y in range(size):
        value = int(68 + (y / max(1, size - 1)) * 42)
        draw.line((0, y, size - 1, y), fill=(42, value, 71, 255))
    draw.polygon(
        ((11, 49), (17, 54), (51, 18), (47, 14)),
        fill=(210, 183, 118, 255),
    )
    draw.polygon(
        ((45, 10), (55, 7), (52, 18)),
        fill=(226, 207, 151, 255),
    )
    draw.line((14, 43, 24, 53), fill=(95, 58, 34, 255), width=4)
    draw.line((9, 49, 18, 58), fill=(52, 31, 22, 255), width=5)
    return icon


def compose_provider_slot(frame: Image.Image) -> Image.Image:
    slot = Image.new("RGBA", (74, 74), (0, 0, 0, 0))
    slot.alpha_composite(build_provider_icon(), (6, 6))
    slot.alpha_composite(frame, (0, 0))
    return slot


def write_slot_opening_preview(
    previous: dict[str, Image.Image],
    repaired: dict[str, Image.Image],
) -> None:
    title_font_path = (
        ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"
    )
    body_font_path = (
        ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"
    )
    title = ImageFont.truetype(str(title_font_path), 28)
    body = ImageFont.truetype(str(body_font_path), 17)
    small = ImageFont.truetype(str(body_font_path), 14)
    board = Image.new("RGBA", (1120, 650), (18, 15, 12, 255))
    draw = ImageDraw.Draw(board)
    draw.text(
        (42, 30),
        "CHAR-SLOT-OPENING-31-V1 · 装备槽开口修复",
        font=title,
        fill=(226, 202, 155, 255),
    )
    draw.text(
        (42, 72),
        "Button 与图标仍为 37×37 / 31×31；仅清除常驻外框侵入图标的 1 UI px。",
        font=body,
        fill=(178, 166, 142, 255),
    )

    large_before = compose_provider_slot(previous["A"]).resize(
        (296, 296), Image.Resampling.NEAREST
    )
    large_after = compose_provider_slot(repaired["A"]).resize(
        (296, 296), Image.Resampling.NEAREST
    )
    board.alpha_composite(large_before, (90, 145))
    board.alpha_composite(large_after, (450, 145))
    draw.text((188, 112), "修复前 · 29×29 开口", font=body, fill=(207, 179, 132, 255))
    draw.text((548, 112), "修复后 · 31×31 开口", font=body, fill=(207, 179, 132, 255))

    draw.rectangle((92, 443, 384, 475), fill=(40, 27, 19, 230))
    draw.text((105, 450), "四边各释放 1 UI px；没有拉伸外框或缩放 Button", font=small, fill=(211, 196, 164, 255))
    draw.rectangle((452, 443, 744, 475), fill=(40, 27, 19, 230))
    draw.text((466, 450), "物品图标完整落入 provider 原生 31×31 区域", font=small, fill=(211, 196, 164, 255))

    draw.text((805, 115), "2 screen px / UI unit", font=body, fill=(207, 179, 132, 255))
    draw.text((805, 145), "修复前", font=small, fill=(170, 157, 132, 255))
    draw.text((805, 262), "修复后", font=small, fill=(170, 157, 132, 255))
    for index, key in enumerate(("A", "B", "C", "D")):
        x = 805 + index * 76
        board.alpha_composite(compose_provider_slot(previous[key]), (x, 170))
        board.alpha_composite(compose_provider_slot(repaired[key]), (x, 287))

    draw.line((42, 525, 1078, 525), fill=(101, 74, 39, 255), width=1)
    draw.text(
        (42, 548),
        "保持不变：37×37 点击区、槽位锚点、pfUI 图标 UV、E2-A 悬停／按下／禁用资源、ShaguScore。",
        font=body,
        fill=(190, 176, 148, 255),
    )
    draw.text(
        (42, 585),
        "本图为确定性排版验证；剑形图案仅代表 provider 动态装备图标，不进入正式资产。",
        font=small,
        fill=(139, 129, 112, 255),
    )
    SLOT_OPENING_PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    board.save(SLOT_OPENING_PREVIEW, format="PNG")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--slot-opening-only",
        action="store_true",
        help="repair and export only the Character E1 slot opening",
    )
    args = parser.parse_args()

    if args.slot_opening_only:
        _, slots, previous_slots = export_slot_base()
        write_slot_opening_preview(previous_slots, slots)
        print(
            "repaired Character slot opening; preview="
            + repo_path(SLOT_OPENING_PREVIEW)
        )
        return 0

    legacy_shell, shell = export_shell()
    legacy_model, model = export_single_component(
        directory_name="model-back-v3",
        source_manifest_name="CHAR-V3-B1-MODEL_SourceManifest_v1.json",
        runtime_manifest_name="CHAR-V3-B1-MODEL_RuntimeManifest_v1.json",
        asset_key="model_background",
        runtime_key="model_background",
        runtime_master_name="CharacterModelBackground_RuntimeMasterV3.png",
        tga_name="CharacterModelBackgroundV3.tga",
        logical_ui=(233, 224),
        runtime_contract="1.2",
    )
    legacy_stats, stats = export_single_component(
        directory_name="stats-paper-v3",
        source_manifest_name="CHAR-V3-C1-STATS-PAPER_SourceManifest_v1.json",
        runtime_manifest_name="CHAR-V3-C1-STATS-PAPER_RuntimeManifest_v1.json",
        asset_key="stats_paper",
        runtime_key="stats_paper",
        runtime_master_name="CharacterStatsPaper_RuntimeMasterV3.png",
        tga_name="CharacterStatsPaperV3.tga",
        logical_ui=(230, 78),
        runtime_contract="1.3",
    )
    legacy_resistance, resistance = export_resistance()
    legacy_slots, slots, previous_slots = export_slot_base()
    write_slot_opening_preview(previous_slots, slots)
    export_slot_interactions()

    legacy_panel = composite_preview(
        legacy_shell,
        legacy_model,
        legacy_stats,
        legacy_resistance,
        legacy_slots,
        1,
    )
    upgraded_panel = composite_preview(
        shell,
        model,
        stats,
        resistance,
        slots,
        TEXEL_DENSITY,
    )
    write_preview(legacy_panel, upgraded_panel)
    print(f"exported Character 2x runtime; preview={repo_path(PREVIEW)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
