#!/usr/bin/env python3
"""Promote and export the accepted nameplate target cue at 2 texels/UI."""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[1]
CANDIDATE = (
    ROOT
    / "generated/nameplates/target-cue/attempt-3/"
    "NP-TARGET-CUE-V1_Attempt3_Candidate.png"
)
SOURCE_DIR = ROOT / "assets/source/unitframes/nameplate-target-cue-v1"
SOURCE = SOURCE_DIR / "NameplateTargetCue_SourceV1.png"
SOURCE_MANIFEST = SOURCE_DIR / "NP-TARGET-CUE-V1_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "NP-TARGET-CUE-V1_RuntimeManifest_v1.json"
RUNTIME = (
    ROOT
    / "addon/AzerothExpeditionUI/Media/UnitFrames/NameplateTargetCueV1.tga"
)

CANDIDATE_SHA256 = (
    "229e0d0a7718c1ef082d18c1ef391964721d1e9a3ac8a8d9ddf0a936cadb084c"
)
RAW_SHA256 = (
    "daf9d495b26c23cfff135c7eac94188b67012ed56d1253d77b7543a9cd2a94a5"
)
SOURCE_SHA256 = (
    "348593fec2f1c42f7bff2c3c7de88981eb0fca9f48ce35abf03417d49c447cfb"
)
CANDIDATE_SIZE = (1254, 1254)
SOURCE_BBOX = (240, 199, 1014, 1108)
SOURCE_SIZE = (774, 909)

LOGICAL_SIZE = (20, 24)
SAMPLED_SIZE = (40, 48)
ART_SAMPLE_SIZE = (40, 47)
TEXTURE_SIZE = (64, 64)
SAMPLE_ORIGIN = (12, 8)
ART_ORIGIN = (12, 9)
TEXELS_PER_UI = 2
RUNTIME_CONTRACT = "1.9"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def repository_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def transparent_rgb_nonzero(image: Image.Image) -> int:
    return sum(
        1
        for red, green, blue, alpha in image.convert("RGBA").getdata()
        if alpha == 0 and (red or green or blue)
    )


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    red, green, blue, alpha = rgba.split()
    visible = alpha.point(lambda value: 255 if value else 0)
    zero = Image.new("L", rgba.size, 0)
    return Image.merge(
        "RGBA",
        (
            Image.composite(red, zero, visible),
            Image.composite(green, zero, visible),
            Image.composite(blue, zero, visible),
            alpha,
        ),
    )


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
        "transparent_rgb_nonzero_pixels": transparent_rgb_nonzero(rgba),
    }


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def promote_source() -> None:
    if sha256(CANDIDATE) != CANDIDATE_SHA256:
        raise ValueError("accepted candidate SHA-256 changed")
    with Image.open(CANDIDATE) as opened:
        candidate = opened.convert("RGBA")
    if candidate.size != CANDIDATE_SIZE:
        raise ValueError(f"accepted candidate size changed: {candidate.size}")
    if candidate.getchannel("A").getbbox() != SOURCE_BBOX:
        raise ValueError("accepted candidate Alpha bounds changed")

    source = clear_transparent_rgb(candidate.crop(SOURCE_BBOX))
    if source.size != SOURCE_SIZE:
        raise ValueError(f"promoted source size changed: {source.size}")
    if source.getchannel("A").getbbox() != (0, 0, *SOURCE_SIZE):
        raise ValueError("promoted source contains unexpected transparent margin")

    SOURCE.parent.mkdir(parents=True, exist_ok=True)
    source.save(SOURCE, format="PNG", compress_level=9)


def load_source() -> Image.Image:
    if not SOURCE.is_file():
        raise ValueError("accepted source is missing; run once with --promote")
    source_hash = sha256(SOURCE)
    if SOURCE_SHA256 != "__PROMOTE_ONCE__" and source_hash != SOURCE_SHA256:
        raise ValueError("accepted source SHA-256 changed")
    with Image.open(SOURCE) as opened:
        source = opened.convert("RGBA")
    if source.size != SOURCE_SIZE:
        raise ValueError(f"accepted source size changed: {source.size}")
    if source.getchannel("A").getbbox() != (0, 0, *SOURCE_SIZE):
        raise ValueError("accepted source Alpha bounds changed")
    if transparent_rgb_nonzero(source):
        raise ValueError("accepted source has RGB data under zero Alpha")
    return source


def tga_header(path: Path) -> dict[str, Any]:
    data = path.read_bytes()
    if len(data) < 18:
        raise ValueError("runtime TGA header is incomplete")
    width, height = struct.unpack("<HH", data[12:16])
    return {
        "image_type": data[2],
        "width": width,
        "height": height,
        "bits_per_pixel": data[16],
        "descriptor": data[17],
        "top_origin": bool(data[17] & 0x20),
    }


def export_runtime(source: Image.Image) -> tuple[Image.Image, Image.Image]:
    art = clear_transparent_rgb(
        source.resize(ART_SAMPLE_SIZE, Image.Resampling.LANCZOS)
    )
    sampled = Image.new("RGBA", SAMPLED_SIZE, (0, 0, 0, 0))
    sampled.paste(art, (0, 1))

    texture = Image.new("RGBA", TEXTURE_SIZE, (0, 0, 0, 0))
    texture.paste(sampled, SAMPLE_ORIGIN)
    texture = clear_transparent_rgb(texture)

    RUNTIME.parent.mkdir(parents=True, exist_ok=True)
    texture.save(RUNTIME, format="TGA")
    with Image.open(RUNTIME) as opened:
        roundtrip = opened.convert("RGBA")
    if ImageChops.difference(roundtrip, texture).getbbox() is not None:
        raise ValueError("TGA roundtrip changed runtime pixels")

    header = tga_header(RUNTIME)
    if (
        header["image_type"] != 2
        or header["bits_per_pixel"] != 32
        or (header["width"], header["height"]) != TEXTURE_SIZE
    ):
        raise ValueError(f"invalid Turtle WoW runtime TGA: {header}")
    return sampled, roundtrip


def write_manifests(
    source: Image.Image,
    sampled: Image.Image,
    runtime: Image.Image,
) -> None:
    source_metrics = metrics(source)
    sampled_metrics = metrics(sampled)
    runtime_metrics = metrics(runtime)
    source_hash = sha256(SOURCE)
    runtime_hash = sha256(RUNTIME)
    sample_box = (
        SAMPLE_ORIGIN[0],
        SAMPLE_ORIGIN[1],
        SAMPLE_ORIGIN[0] + SAMPLED_SIZE[0],
        SAMPLE_ORIGIN[1] + SAMPLED_SIZE[1],
    )
    art_box = (
        ART_ORIGIN[0],
        ART_ORIGIN[1],
        ART_ORIGIN[0] + ART_SAMPLE_SIZE[0],
        ART_ORIGIN[1] + ART_SAMPLE_SIZE[1],
    )
    content_uv = [
        sample_box[0] / TEXTURE_SIZE[0],
        sample_box[2] / TEXTURE_SIZE[0],
        sample_box[1] / TEXTURE_SIZE[1],
        sample_box[3] / TEXTURE_SIZE[1],
    ]

    write_json(
        SOURCE_MANIFEST,
        {
            "schema": "aeui-unitframes-nameplate-target-cue-v1-source-manifest-v1",
            "schema_version": 1,
            "module": "unitframes",
            "batch": "NP-TARGET-CUE-V1",
            "component": "UF.NAMEPLATE.TARGET.CUE",
            "status": "accepted-source",
            "phase": "P4",
            "accepted_on": "2026-08-24",
            "user_acceptance": {
                "statement": "用户在候选 3 展示后回复‘ok’，接受该候选 exact visible pixels，并授权正式接入。",
                "accepts_exact_visible_pixels": True,
                "source_promotion_authorized": True,
                "runtime_export_authorized": True,
                "addon_integration_authorized": True,
            },
            "provenance": {
                "executor": "imagegen-0-143-0",
                "production_attempt": 3,
                "actual_imagegen_calls": 3,
                "raw_output_sha256": RAW_SHA256,
                "accepted_candidate_sha256": CANDIDATE_SHA256,
                "candidate_alpha_crop_exclusive": list(SOURCE_BBOX),
                "promotion_postprocess": "crop transparent margin and clear RGB only where Alpha is zero",
                "python_generated_visual_pixels": False,
            },
            "accepted_assets": {
                "source": {
                    "file": repository_path(SOURCE),
                    "sha256": source_hash,
                    "metrics": source_metrics,
                }
            },
            "geometry": {
                "provider": "pfUI.nameplates world nameplate",
                "logical_size": list(LOGICAL_SIZE),
                "sampled_size": list(SAMPLED_SIZE),
                "art_sample_size": list(ART_SAMPLE_SIZE),
                "texture_container": list(TEXTURE_SIZE),
                "texels_per_ui": TEXELS_PER_UI,
                "source_aspect_ratio": round(SOURCE_SIZE[0] / SOURCE_SIZE[1], 6),
                "provider_geometry_changed": False,
            },
            "visual_authority": {
                "global_prompt": "docs/GLOBAL_ART_BASELINE.md",
                "module_prompt": "docs/modules/unitframes/ART_BASELINE.md",
                "submodule_prompt": "docs/modules/unitframes/SUBMODULE_ART_BASELINES.md",
                "submodule_prompt_heading": "UF.NAMEPLATE.TARGET.CUE",
                "component_contract": "docs/modules/unitframes/SUBMODULES.md",
            },
        },
    )

    write_json(
        RUNTIME_MANIFEST,
        {
            "schema": "aeui-unitframes-nameplate-target-cue-v1-runtime-manifest-v1",
            "schema_version": 1,
            "module": "unitframes",
            "component": "UF.NAMEPLATE.TARGET.CUE",
            "status": "runtime-exported-addon-integrated",
            "phase": "P5",
            "runtime_contract": RUNTIME_CONTRACT,
            "source_manifest": repository_path(SOURCE_MANIFEST),
            "route": "unitframes.nameplate-target-cue",
            "runtime": {
                "file": repository_path(RUNTIME),
                "sha256": runtime_hash,
                "logical_size": list(LOGICAL_SIZE),
                "sampled_size": list(SAMPLED_SIZE),
                "art_sample_size": list(ART_SAMPLE_SIZE),
                "texels_per_ui": TEXELS_PER_UI,
                "texture_size": list(TEXTURE_SIZE),
                "sample_box_exclusive": list(sample_box),
                "art_box_exclusive": list(art_box),
                "content_uv": content_uv,
                "tga_header": tga_header(RUNTIME),
                "sampled_metrics": sampled_metrics,
                "texture_metrics": runtime_metrics,
                "source_to_art_sample": [list(SOURCE_SIZE), list(ART_SAMPLE_SIZE)],
            },
            "addon_contract": {
                "provider": "pfUI.nameplates",
                "state": "provider nameplate.istarget",
                "display": "20x24 UI above the visible name or above a shown top-positioned provider raid icon",
                "raid_icon": "provider-owned; parented to the nameplate so health visibility cannot hide it",
                "health_hidden": "personal target cue and provider raid icon remain independently visible",
                "dynamic_owner": "pfUI retains plate discovery, target detection, text, bars, raid marks, clicks, events and SavedVariables",
                "fallback": "hide only the AEUI personal target cue; retain the complete pfUI nameplate",
            },
        },
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--promote",
        action="store_true",
        help="promote the already accepted generated candidate once",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.promote:
        promote_source()
    source = load_source()
    sampled, runtime = export_runtime(source)
    write_manifests(source, sampled, runtime)
    print(
        json.dumps(
            {
                "source_sha256": sha256(SOURCE),
                "runtime_tga_sha256": sha256(RUNTIME),
                "source": repository_path(SOURCE),
                "runtime": repository_path(RUNTIME),
                "logical_size": list(LOGICAL_SIZE),
                "sampled_size": list(SAMPLED_SIZE),
                "texture_size": list(TEXTURE_SIZE),
                "content_uv": [12 / 64, 52 / 64, 8 / 64, 56 / 64],
            },
            ensure_ascii=False,
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
