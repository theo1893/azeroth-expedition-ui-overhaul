#!/usr/bin/env python3
"""Promote accepted SB-A2 masters and export the four native TGA regions."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import struct
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets/source/spellbook/frame-a2"
RUNTIME_DIR = ROOT / "addon/AzerothExpeditionUI/Media/Spellbook"

SOURCE_MASTER = SOURCE_DIR / "SpellbookFramePageField_SourceV1.png"
RUNTIME_MASTER = SOURCE_DIR / "SpellbookFramePageField_RuntimeMasterV1.png"
SOURCE_MANIFEST = SOURCE_DIR / "SB-A2_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "SB-A2_RuntimeManifest_v1.json"

SOURCE_SHA = "deb9785f36d0f49fe78d20a56a7c25353a9e010fc10ba3859386d51cd75fa5fc"
SOURCE_PIXEL_SHA = "d225486f62081636eea6ee4abfc16f4cdb653e4f2c19c4d5022190f9763edaa9"
RUNTIME_SHA = "24a007ab835c8ded8b66fc964114b624e0027cdf90c7eba94ed2cda14f4db946"
RUNTIME_PIXEL_SHA = "3d51ed2142637f1219f3b9b59598ad75095dacdacd3c7cbb056b8df7de8fb7e7"
DONOR_SHA = "afb16a7f92fa492c24d5edc787d11e3bb73769a6ad57016d9b1d1dbfef6334b1"

SLICES = {
    "top_left": {
        "component": "SB.FRAME.PAGE_FIELD.TOP_LEFT",
        "crop": (0, 0, 256, 256),
        "size": (256, 256),
        "file": "SpellbookFramePageFieldTopLeftV1.tga",
    },
    "top_right": {
        "component": "SB.FRAME.PAGE_FIELD.TOP_RIGHT",
        "crop": (256, 0, 384, 256),
        "size": (128, 256),
        "file": "SpellbookFramePageFieldTopRightV1.tga",
    },
    "bottom_left": {
        "component": "SB.FRAME.PAGE_FIELD.BOTTOM_LEFT",
        "crop": (0, 256, 256, 512),
        "size": (256, 256),
        "file": "SpellbookFramePageFieldBottomLeftV1.tga",
    },
    "bottom_right": {
        "component": "SB.FRAME.PAGE_FIELD.BOTTOM_RIGHT",
        "crop": (256, 256, 384, 512),
        "size": (128, 256),
        "file": "SpellbookFramePageFieldBottomRightV1.tga",
    },
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--promote-source", type=Path)
    parser.add_argument("--promote-runtime", type=Path)
    return parser.parse_args()


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def repo_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def transparent_rgb_nonzero(image: Image.Image) -> int:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8)
    transparent = rgba[:, :, 3] == 0
    return int(np.count_nonzero(rgba[transparent, :3]))


def visible_cyan_pixels(image: Image.Image) -> int:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8)
    red = rgba[:, :, 0].astype(np.int16)
    green = rgba[:, :, 1].astype(np.int16)
    blue = rgba[:, :, 2].astype(np.int16)
    return int(np.count_nonzero(
        (rgba[:, :, 3] > 0)
        & (green >= 170)
        & (blue >= 170)
        & (green - red >= 95)
        & (blue - red >= 95)
    ))


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
        "visible_cyan_key_pixels": visible_cyan_pixels(rgba),
        "transparent_rgb_nonzero_values": transparent_rgb_nonzero(rgba),
    }


def validate_png(
    path: Path,
    expected_size: tuple[int, int],
    expected_sha: str,
    expected_pixel_sha: str,
) -> Image.Image:
    if not path.is_file():
        raise ValueError(f"missing accepted master: {path}")
    if sha256(path) != expected_sha:
        raise ValueError(f"accepted master file hash drifted: {path}")
    with Image.open(path) as opened:
        image = opened.convert("RGBA")
    if image.size != expected_size:
        raise ValueError(f"accepted master size drifted: {path}: {image.size}")
    if pixel_sha256(image) != expected_pixel_sha:
        raise ValueError(f"accepted master pixel hash drifted: {path}")
    evidence = metrics(image)
    if evidence["transparent_rgb_nonzero_values"]:
        raise ValueError(f"transparent RGB is not cleared: {path}")
    if evidence["visible_cyan_key_pixels"]:
        raise ValueError(f"visible cyan key remains: {path}")
    return image


def promote(source: Path, runtime: Path) -> None:
    validate_png(source, (768, 1024), SOURCE_SHA, SOURCE_PIXEL_SHA)
    validate_png(runtime, (384, 512), RUNTIME_SHA, RUNTIME_PIXEL_SHA)
    SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, SOURCE_MASTER)
    shutil.copyfile(runtime, RUNTIME_MASTER)


def tga_header(path: Path) -> dict[str, Any]:
    raw = path.read_bytes()
    if len(raw) < 18:
        raise ValueError(f"incomplete TGA header: {path}")
    width, height = struct.unpack("<HH", raw[12:16])
    return {
        "image_type": raw[2],
        "width": width,
        "height": height,
        "bits_per_pixel": raw[16],
        "descriptor": raw[17],
        "top_origin": bool(raw[17] & 0x20),
    }


def export_slices(runtime: Image.Image) -> dict[str, dict[str, Any]]:
    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    records: dict[str, dict[str, Any]] = {}
    reassembled = Image.new("RGBA", runtime.size, (0, 0, 0, 0))
    destinations = {
        "top_left": (0, 0),
        "top_right": (256, 0),
        "bottom_left": (0, 256),
        "bottom_right": (256, 256),
    }
    for key, spec in SLICES.items():
        piece = runtime.crop(spec["crop"])
        if piece.size != spec["size"]:
            raise ValueError(f"native slice size drifted: {key}: {piece.size}")
        path = RUNTIME_DIR / spec["file"]
        piece.save(path, format="TGA")
        with Image.open(path) as opened:
            roundtrip = opened.convert("RGBA")
        if ImageChops.difference(piece, roundtrip).getbbox() is not None:
            raise ValueError(f"TGA roundtrip changed pixels: {path}")
        header = tga_header(path)
        if (
            header["image_type"] != 2
            or header["bits_per_pixel"] != 32
            or (header["width"], header["height"]) != spec["size"]
        ):
            raise ValueError(f"TGA header drifted: {path}: {header}")
        reassembled.paste(roundtrip, destinations[key])
        records[key] = {
            "component": spec["component"],
            "file": repo_path(path),
            "sha256": sha256(path),
            "metrics": metrics(roundtrip),
            "tga_header": header,
        }
    if ImageChops.difference(runtime, reassembled).getbbox() is not None:
        raise ValueError("native four-slice reassembly changed runtime pixels")
    return records


def write_manifests(source: Image.Image, runtime: Image.Image, records: dict[str, dict[str, Any]]) -> None:
    source_manifest = {
        "schema": "aeui-spellbook-sb-a2-source-manifest-v1",
        "schema_version": 1,
        "module": "spellbook",
        "batch": "SB-A2-DONOR V1",
        "status": "runtime-exported",
        "phase": "P5",
        "accepted_on": "2026-08-13",
        "user_acceptance": {
            "exact_statement": (
                "接受 SB-A2-DONOR V1 的运行时视觉，允许提升 source/runtime、"
                "导出正式原生四块 TGA 并接入 addon。但是移除左上角的职业icon"
                "(如果左上角有职业icon)"
            ),
            "p4_p5_and_integration_authorized": True,
            "top_left_provider_icon_must_be_hidden": True,
        },
        "provenance": {
            "fixed_material_donor": "SB-A1 attempt 1",
            "fixed_material_donor_sha256": DONOR_SHA,
            "additional_imagegen_calls": 0,
            "cross_attempt_pixel_reuse": False,
            "other_module_pixel_reuse": False,
            "geometry": "Python deterministic 768x1024 source and 384x512 runtime",
            "global_prompt": "docs/GLOBAL_ART_BASELINE.md",
            "module_prompt": "docs/modules/spellbook/ART_BASELINE.md",
            "component_prompt": "docs/modules/spellbook/SUBMODULE_ART_BASELINES.md#sbframe--sbpagefield",
        },
        "accepted_masters": {
            "source": {
                "file": repo_path(SOURCE_MASTER),
                "sha256": sha256(SOURCE_MASTER),
                "metrics": metrics(source),
            },
            "runtime": {
                "file": repo_path(RUNTIME_MASTER),
                "sha256": sha256(RUNTIME_MASTER),
                "metrics": metrics(runtime),
            },
        },
        "deterministic_transform": {
            "complete_candidate_anisotropic_stretch": False,
            "runtime_downsample": "2x LANCZOS performed before acceptance and locked as tracked runtime master",
            "native_slices": {key: list(spec["crop"]) for key, spec in SLICES.items()},
            "native_four_slice_reassembly_exact": True,
            "dynamic_text_icons_tabs_buttons_baked": False,
            "top_left_class_or_spellbook_icon_baked": False,
        },
        "runtime_manifest": repo_path(RUNTIME_MANIFEST),
    }
    SOURCE_MANIFEST.write_text(json.dumps(source_manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    runtime_manifest = {
        "schema": "aeui-spellbook-sb-a2-runtime-manifest-v1",
        "schema_version": 1,
        "module": "spellbook",
        "batch": "SB-A2-DONOR V1",
        "status": "runtime-exported",
        "phase": "P5",
        "runtime_contract": "1.0",
        "source_manifest": repo_path(SOURCE_MANIFEST),
        "runtime": records,
        "layout_contract": {
            "provider": "Blizzard SpellBookFrame",
            "provider_geometry_ui": [384, 512],
            "provider_original_direct_textures_hidden": True,
            "top_left_spellbook_or_class_icon_hidden": True,
            "pfui_modern_backdrop_disabled_by_scoped_skin_ownership": True,
            "native_spells_cooldowns_tooltips_book_tabs_skill_tabs_page_controls": "provider-live",
            "stretch": False,
        },
    }
    RUNTIME_MANIFEST.write_text(json.dumps(runtime_manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    args = parse_args()
    if bool(args.promote_source) != bool(args.promote_runtime):
        raise ValueError("--promote-source and --promote-runtime must be provided together")
    if args.promote_source and args.promote_runtime:
        promote(args.promote_source.resolve(), args.promote_runtime.resolve())

    source = validate_png(SOURCE_MASTER, (768, 1024), SOURCE_SHA, SOURCE_PIXEL_SHA)
    runtime = validate_png(RUNTIME_MASTER, (384, 512), RUNTIME_SHA, RUNTIME_PIXEL_SHA)
    rebuilt = source.resize((384, 512), Image.Resampling.LANCZOS)
    if ImageChops.difference(rebuilt, runtime).getbbox() is not None:
        raise ValueError("tracked runtime master no longer matches the accepted source downsample")

    records = export_slices(runtime)
    write_manifests(source, runtime, records)
    print(json.dumps({
        "contract": "SB-A2-DONOR V1",
        "source": repo_path(SOURCE_MASTER),
        "runtime_master": repo_path(RUNTIME_MASTER),
        "runtime_files": [record["file"] for record in records.values()],
        "native_four_slice_reassembly_exact": True,
        "top_left_provider_icon": "hidden-by-addon-contract",
        "additional_imagegen_calls": 0,
    }, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
