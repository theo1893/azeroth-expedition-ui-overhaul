#!/usr/bin/env python3
"""Export the accepted Gear Planner slot-state donor into one 2x sprite atlas."""

from __future__ import annotations

import hashlib
import json
import struct
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets/source/gearplanner/slot-states-v1"
SOURCE = SOURCE_DIR / "GearPlannerSlotStatesDonor_SourceV1.png"
MASTER = SOURCE_DIR / "GearPlannerSlotStatesAtlas_RuntimeMasterV1.png"
SOURCE_MANIFEST = SOURCE_DIR / "GEAR-SLOT-STATES-V1_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "GEAR-SLOT-STATES-V1_RuntimeManifest_v1.json"
RUNTIME = (
    ROOT
    / "addon/AzerothExpeditionUI/Media/GearPlanner/GearPlannerSlotStatesV1.tga"
)

SOURCE_SHA256 = "027d7da64169a9939ff264d64a27934f1eee49e2984291a9480b6b63bf2f5d15"
MASTER_SHA256 = "eee3a1cc01bdb299086a75e61f00712803fd510054e7ce583ea136863df80291"
ATLAS_SIZE = (256, 128)
REGIONS = {
    "difference_strong": {
        "origin": (0, 0),
        "sampled_size": (100, 40),
        "logical_size_ui": (50, 20),
    },
    "difference_weak": {
        "origin": (112, 4),
        "sampled_size": (76, 32),
        "logical_size_ui": (38, 16),
    },
    "draft_revision": {
        "origin": (208, 0),
        "sampled_size": (18, 72),
        "logical_size_ui": (9, 36),
    },
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def repo_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    pixels = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    pixels[pixels[:, :, 3] == 0, :3] = 0
    return Image.fromarray(pixels, "RGBA")


def metrics(image: Image.Image) -> dict[str, Any]:
    rgba = image.convert("RGBA")
    pixels = np.asarray(rgba, dtype=np.uint8)
    alpha = pixels[:, :, 3]
    return {
        "size": list(rgba.size),
        "mode": rgba.mode,
        "pixel_sha256": pixel_sha256(rgba),
        "visible_bbox_exclusive": list(rgba.getchannel("A").getbbox() or (0, 0, 0, 0)),
        "transparent_pixels": int(np.count_nonzero(alpha == 0)),
        "partially_transparent_pixels": int(
            np.count_nonzero((alpha > 0) & (alpha < 255))
        ),
        "opaque_pixels": int(np.count_nonzero(alpha == 255)),
        "transparent_rgb_nonzero_pixels": int(
            np.count_nonzero(pixels[alpha == 0, :3])
        ),
    }


def polygon_mask(size: tuple[int, int], points: list[tuple[int, int]]) -> Image.Image:
    scale = 4
    mask = Image.new("L", (size[0] * scale, size[1] * scale), 0)
    ImageDraw.Draw(mask).polygon(
        [(x * scale, y * scale) for x, y in points], fill=255
    )
    return mask.resize(size, Image.Resampling.LANCZOS)


def extract(
    source: Image.Image,
    box: tuple[int, int, int, int],
    size: tuple[int, int],
    points: list[tuple[int, int]],
) -> Image.Image:
    image = source.crop(box).resize(size, Image.Resampling.LANCZOS).convert("RGBA")
    pixels = np.asarray(image, dtype=np.uint8).copy()
    green = (
        (pixels[:, :, 1] > 100)
        & (pixels[:, :, 1] > pixels[:, :, 0] * 1.4)
        & (pixels[:, :, 1] > pixels[:, :, 2] * 1.4)
    )
    pixels[green, 3] = 0
    pixels[green, :3] = 0
    image = Image.fromarray(pixels, "RGBA")
    image.putalpha(
        ImageChops.darker(image.getchannel("A"), polygon_mask(size, points))
    )
    return image


def with_alpha(image: Image.Image, opacity: float) -> Image.Image:
    result = image.copy()
    result.putalpha(
        result.getchannel("A").point(lambda value: int(value * opacity))
    )
    return result


def build_atlas(source: Image.Image) -> Image.Image:
    strong = extract(
        source,
        (1505, 68, 1677, 151),
        (100, 40),
        [(0, 0), (100, 0), (100, 40), (25, 40), (0, 22)],
    )
    weak = with_alpha(strong.resize((76, 32), Image.Resampling.LANCZOS), 0.52)
    draft = extract(
        source,
        (326, 631, 398, 790),
        (18, 72),
        [(2, 0), (16, 0), (18, 4), (18, 68), (16, 72), (2, 72), (0, 68), (0, 4)],
    )
    atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
    atlas.alpha_composite(strong, REGIONS["difference_strong"]["origin"])
    atlas.alpha_composite(weak, REGIONS["difference_weak"]["origin"])
    atlas.alpha_composite(draft, REGIONS["draft_revision"]["origin"])
    return clear_transparent_rgb(atlas)


def tga_header(path: Path) -> dict[str, Any]:
    data = path.read_bytes()[:18]
    width, height = struct.unpack("<HH", data[12:16])
    return {
        "image_type": data[2],
        "width": width,
        "height": height,
        "bits_per_pixel": data[16],
        "descriptor": data[17],
        "top_origin": bool(data[17] & 0x20),
    }


def uv(origin: tuple[int, int], size: tuple[int, int]) -> list[float]:
    x, y = origin
    width, height = size
    return [
        x / ATLAS_SIZE[0],
        (x + width) / ATLAS_SIZE[0],
        y / ATLAS_SIZE[1],
        (y + height) / ATLAS_SIZE[1],
    ]


def write_manifests(source: Image.Image, master: Image.Image) -> None:
    source_manifest = {
        "schema": "aeui-gearplanner-slot-states-v1-source-manifest-v1",
        "schema_version": 1,
        "module": "gearplanner",
        "batch": "GEAR-SLOT-STATES-V1 final",
        "component": "GEAR.SLOT difference / draft state sprites",
        "status": "runtime-exported",
        "phase": "P5",
        "accepted_on": "2026-08-26",
        "user_acceptance": {
            "statement": "按候选 01 接入",
            "accepts_exact_pixels": True,
            "source_promotion_authorized": True,
            "runtime_export_authorized": True,
            "addon_integration_authorized": True,
        },
        "provenance": {
            "executor": "imagegen-0-143-0",
            "actual_imagegen_calls": 1,
            "fixed_reference_upload_authorized": True,
            "global_prompt": "docs/GLOBAL_ART_BASELINE.md",
            "module_prompt": "docs/modules/gearplanner/ART_BASELINE.md",
            "submodule_prompt": "docs/modules/gearplanner/SUBMODULE_ART_BASELINES.md",
        },
        "accepted_assets": {
            "source": {
                "file": repo_path(SOURCE),
                "sha256": sha256(SOURCE),
                "metrics": metrics(source),
                "background": "generated #00FF00-compatible chroma key",
            },
            "runtime_master": {
                "file": repo_path(MASTER),
                "sha256": sha256(MASTER),
                "metrics": metrics(master),
            },
        },
        "deterministic_transform": {
            "texels_per_ui_unit": 2,
            "dynamic_text_icons_slot_base_and_hitboxes_baked": False,
            "source_crops_exclusive": {
                "difference_strong": [1505, 68, 1677, 151],
                "draft_revision": [326, 631, 398, 790],
            },
            "difference_weak": "difference_strong LANCZOS 76x32 and alpha 0.52",
            "chroma_key": "green dominance: G > 100 and G > R*1.4 and G > B*1.4",
            "polygon_masks": "4x antialiased deterministic masks",
            "transparent_rgb_cleared": True,
            "runtime_exporter": repo_path(Path(__file__)),
        },
        "runtime_manifest": repo_path(RUNTIME_MANIFEST),
    }
    SOURCE_MANIFEST.write_text(
        json.dumps(source_manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    runtime_regions = {}
    for key, record in REGIONS.items():
        runtime_regions[key] = {
            "logical_size_ui": list(record["logical_size_ui"]),
            "sampled_size": list(record["sampled_size"]),
            "texels_per_ui_unit": 2,
            "uv": uv(record["origin"], record["sampled_size"]),
            "anchor": "TOPRIGHT" if key.startswith("difference") else "ICON_RIGHT",
        }
    runtime_manifest = {
        "schema": "aeui-gearplanner-slot-states-v1-runtime-manifest-v1",
        "schema_version": 1,
        "module": "gearplanner",
        "batch": "GEAR-SLOT-STATES-V1 final",
        "component": "GEAR.SLOT difference / draft state sprites",
        "status": "runtime-exported",
        "phase": "P5",
        "runtime_contract": "1.1-zhCN",
        "source_manifest": repo_path(SOURCE_MANIFEST),
        "runtime": {
            "slot_states": {
                "file": repo_path(RUNTIME),
                "sha256": sha256(RUNTIME),
                "texture_size": list(ATLAS_SIZE),
                "pixel_sha256": pixel_sha256(master),
                "tga": tga_header(RUNTIME),
                "regions": runtime_regions,
            }
        },
        "layout_contract": {
            "companion_slot_ui": [164, 40],
            "standalone_slot_ui": [202, 42],
            "difference_and_draft_can_stack": True,
            "slot_base_icon_text_status_and_star": "runtime-live",
            "button_geometry_and_hitboxes_changed": False,
        },
    }
    RUNTIME_MANIFEST.write_text(
        json.dumps(runtime_manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def main() -> None:
    if sha256(SOURCE) != SOURCE_SHA256:
        raise ValueError("accepted Gear Planner slot-state donor SHA-256 changed")
    if sha256(MASTER) != MASTER_SHA256:
        raise ValueError("accepted Gear Planner slot-state runtime master SHA-256 changed")
    with Image.open(SOURCE) as opened:
        source = opened.convert("RGBA")
    with Image.open(MASTER) as opened:
        master = clear_transparent_rgb(opened)
    rebuilt = build_atlas(source)
    if np.array_equal(np.asarray(rebuilt), np.asarray(master)) is False:
        raise ValueError("runtime master no longer matches deterministic donor extraction")

    RUNTIME.parent.mkdir(parents=True, exist_ok=True)
    master.save(RUNTIME, format="TGA")
    with Image.open(RUNTIME) as opened:
        roundtrip = clear_transparent_rgb(opened)
    if np.array_equal(np.asarray(roundtrip), np.asarray(master)) is False:
        raise ValueError("TGA round-trip changed accepted runtime pixels")
    write_manifests(source, master)
    print(
        json.dumps(
            {
                "contract": "GEAR-SLOT-STATES-V1",
                "source": repo_path(SOURCE),
                "runtime_master": repo_path(MASTER),
                "runtime": repo_path(RUNTIME),
                "runtime_sha256": sha256(RUNTIME),
            },
            ensure_ascii=False,
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
