#!/usr/bin/env python3
"""Promote and export the accepted CHAR-V3-E3-AMMO exact pixels."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import struct
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[1]
PROMOTION_DIR = (
    ROOT
    / "generated/character/ammo-production/attempt-5/postprocess"
)
SOURCE_DIR = ROOT / "assets/source/character/ammo-slot-v3"
MEDIA_DIR = ROOT / "addon/AzerothExpeditionUI/Media/Character"
ATLAS_MASTER = SOURCE_DIR / "CharacterAmmoSlotAtlas_RuntimeMasterV3.png"
RUNTIME_TGA = MEDIA_DIR / "CharacterAmmoSlotV3.tga"
SOURCE_MANIFEST = SOURCE_DIR / "CHAR-V3-E3-AMMO_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "CHAR-V3-E3-AMMO_RuntimeManifest_v1.json"

SOURCE_SIZE = (108, 108)
RUNTIME_SIZE = (54, 54)
ATLAS_SIZE = (128, 128)
SOURCE_SAFE_BOX = (12, 12, 96, 96)
RUNTIME_SAFE_BOX = (6, 6, 48, 48)
TEXEL_DENSITY = 2
EXPECTED_ATLAS_PIXEL_SHA256 = (
    "9b95f5a2449ec51a7e527079a568544dd1c234a54abd439125d6ae4f95986a50"
)
ACCEPTED_ATLAS_CANDIDATE_SHA256 = (
    "14e1a0100b3dd75a2b03d1c9d20ee0c62be5b772ec8285e3ca7fbcf6ff0cee09"
)
RAW_CANDIDATE = (
    "generated/character/ammo-production/attempt-5/"
    "CharacterAmmoSlot_Production_Attempt5.png"
)
RAW_CANDIDATE_SHA256 = (
    "79ded4c06777191d7fe4997cae3354d6aa1ce98cbcdf8eb8cca9197b1b68c96e"
)
ACCEPTED_ON = "2026-08-19"

STATES: dict[str, dict[str, Any]] = {
    "normal": {
        "promotion_name": "CharacterAmmoSlot_normal_SourceCandidate.png",
        "source_name": "CharacterAmmoSlotNormal_SourceV3.png",
        "sha256": "9b108bed2758484ae638db01c0514768edb63c248f1c02b562470520fb9213e5",
        "cell": (0, 0),
    },
    "hover": {
        "promotion_name": "CharacterAmmoSlot_hover_SourceCandidate.png",
        "source_name": "CharacterAmmoSlotHover_SourceV3.png",
        "sha256": "bce23047c1a7cd510cdff03128ba3b92629dd558a2673af106822c2f1dadc5af",
        "cell": (64, 0),
    },
    "pressed": {
        "promotion_name": "CharacterAmmoSlot_pressed_SourceCandidate.png",
        "source_name": "CharacterAmmoSlotPressed_SourceV3.png",
        "sha256": "aca68aaf7af4ea545a4757ebb0844df7734861e7adb2a6ad4fd7ca35b20a70dc",
        "cell": (0, 64),
    },
    "disabled": {
        "promotion_name": "CharacterAmmoSlot_disabled_SourceCandidate.png",
        "source_name": "CharacterAmmoSlotDisabled_SourceV3.png",
        "sha256": "40e391c06b5dafd62878af592e75e59d2daf531535719011ae92293815f46b61",
        "cell": (64, 64),
    },
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def repo_path(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = bytearray(rgba.tobytes())
    for offset in range(0, len(pixels), 4):
        if pixels[offset + 3] == 0:
            pixels[offset] = 0
            pixels[offset + 1] = 0
            pixels[offset + 2] = 0
    return Image.frombytes("RGBA", rgba.size, bytes(pixels))


def transparent_rgb_nonzero(image: Image.Image) -> int:
    return sum(
        1
        for red, green, blue, alpha in image.convert("RGBA").getdata()
        if alpha == 0 and (red or green or blue)
    )


def green_dominant_pixels(image: Image.Image) -> int:
    return sum(
        1
        for red, green, blue, alpha in image.convert("RGBA").getdata()
        if alpha > 0 and green > 210 and green > red * 1.35 and green > blue * 1.35
    )


def box_alpha_max(image: Image.Image, box: tuple[int, int, int, int]) -> int:
    return max(image.convert("RGBA").getchannel("A").crop(box).getdata())


def image_metrics(image: Image.Image) -> dict[str, Any]:
    rgba = image.convert("RGBA")
    return {
        "size": list(rgba.size),
        "pixel_sha256": pixel_sha256(rgba),
        "visible_bbox_exclusive": list(
            rgba.getchannel("A").getbbox() or (0, 0, 0, 0)
        ),
        "transparent_rgb_nonzero_pixels": transparent_rgb_nonzero(rgba),
        "green_dominant_pixels": green_dominant_pixels(rgba),
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


def save_tga(path: Path, image: Image.Image) -> Image.Image:
    rgba = clear_transparent_rgb(image)
    path.parent.mkdir(parents=True, exist_ok=True)
    rgba.save(path, format="TGA")
    with Image.open(path) as opened:
        roundtrip = opened.convert("RGBA")
    if ImageChops.difference(roundtrip, rgba).getbbox() is not None:
        raise ValueError("TGA roundtrip changed accepted runtime pixels")
    header = tga_header(path)
    if (
        header["image_type"] != 2
        or header["bits_per_pixel"] != 32
        or (header["width"], header["height"]) != ATLAS_SIZE
        or max(ATLAS_SIZE) > 1024
    ):
        raise ValueError(f"invalid Turtle WoW TGA: {header}")
    return roundtrip


def promote_sources() -> None:
    SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    for state, definition in STATES.items():
        candidate = PROMOTION_DIR / str(definition["promotion_name"])
        expected = str(definition["sha256"])
        if not candidate.is_file():
            raise FileNotFoundError(f"accepted promotion input missing: {candidate}")
        if sha256(candidate) != expected:
            raise ValueError(f"accepted exact pixels changed before promotion: {state}")
        target = SOURCE_DIR / str(definition["source_name"])
        shutil.copyfile(candidate, target)
        if sha256(target) != expected:
            raise ValueError(f"promotion changed exact bytes: {state}")


def load_sources() -> dict[str, Image.Image]:
    sources: dict[str, Image.Image] = {}
    for state, definition in STATES.items():
        path = SOURCE_DIR / str(definition["source_name"])
        expected = str(definition["sha256"])
        if not path.is_file() or sha256(path) != expected:
            raise ValueError(f"accepted source missing or changed: {path}")
        with Image.open(path) as opened:
            source = opened.convert("RGBA")
        if source.size != SOURCE_SIZE:
            raise ValueError(f"accepted source geometry changed: {state}={source.size}")
        metrics = image_metrics(source)
        if (
            metrics["transparent_rgb_nonzero_pixels"] != 0
            or box_alpha_max(source, SOURCE_SAFE_BOX) != 0
        ):
            raise ValueError(f"accepted source transparency check failed: {state}")
        sources[state] = source
    return sources


def build_atlas(
    sources: dict[str, Image.Image],
) -> tuple[Image.Image, dict[str, Any]]:
    atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
    runtime_states: dict[str, Any] = {}
    for state, definition in STATES.items():
        runtime = sources[state].resize(
            RUNTIME_SIZE,
            Image.Resampling.LANCZOS,
        )
        runtime.paste((0, 0, 0, 0), RUNTIME_SAFE_BOX)
        runtime = clear_transparent_rgb(runtime)
        if box_alpha_max(runtime, RUNTIME_SAFE_BOX) != 0:
            raise ValueError(f"runtime icon safe area is not transparent: {state}")
        x, y = definition["cell"]
        atlas.alpha_composite(runtime, (x, y))
        runtime_states[state] = {
            "cell_origin": [x, y],
            "logical_size_ui": [27, 27],
            "sampled_size": list(RUNTIME_SIZE),
            "icon_safe_size_ui": [21, 21],
            "icon_safe_sampled_box": list(RUNTIME_SAFE_BOX),
            "texels_per_ui_unit": TEXEL_DENSITY,
            "uv": [
                x / ATLAS_SIZE[0],
                (x + RUNTIME_SIZE[0]) / ATLAS_SIZE[0],
                y / ATLAS_SIZE[1],
                (y + RUNTIME_SIZE[1]) / ATLAS_SIZE[1],
            ],
            "pixel_sha256": pixel_sha256(runtime),
        }
    atlas = clear_transparent_rgb(atlas)
    if transparent_rgb_nonzero(atlas) or green_dominant_pixels(atlas):
        raise ValueError("runtime atlas transparency/chroma check failed")
    return atlas, runtime_states


def write_manifests(
    sources: dict[str, Image.Image],
    atlas: Image.Image,
    runtime_states: dict[str, Any],
    roundtrip: Image.Image,
) -> None:
    source_assets: dict[str, Any] = {}
    for state, definition in STATES.items():
        path = SOURCE_DIR / str(definition["source_name"])
        source_assets[state] = {
            "file": repo_path(path),
            "sha256": sha256(path),
            "metrics": image_metrics(sources[state]),
            "icon_safe_source_box": list(SOURCE_SAFE_BOX),
            "icon_safe_alpha_max": box_alpha_max(sources[state], SOURCE_SAFE_BOX),
        }
    source_assets["runtime_master"] = {
        "file": repo_path(ATLAS_MASTER),
        "sha256": sha256(ATLAS_MASTER),
        "metrics": image_metrics(atlas),
    }

    source_payload = {
        "schema": "aeui-character-v3-e3-ammo-source-manifest-v1",
        "schema_version": 1,
        "module": "character",
        "batch": "CHAR-V3-E3-AMMO V1 final",
        "component": "CHAR.SLOT.AMMO",
        "status": "runtime-exported",
        "phase": "P5",
        "accepted_on": ACCEPTED_ON,
        "acceptance": (
            "CHAR-V3-E3-AMMO V1 attempt 5 exact pixels accepted; "
            "1254x1254 native container split at x/y=627 authorized"
        ),
        "provenance": {
            "generator": "imagegen-0-143-0",
            "selected_attempt": 5,
            "actual_imagegen_calls": 5,
            "raw_candidate": RAW_CANDIDATE,
            "raw_candidate_sha256": RAW_CANDIDATE_SHA256,
            "deterministic_exception": {
                "native_container": [1254, 1254],
                "split_midlines": [627, 627],
                "quadrants": "normal/hover/pressed/disabled",
            },
            "postprocess": [
                "fixed four-quadrant split",
                "edge-connected green key and spill cleanup",
                "transparent RGB zeroing",
                "independent bbox-fit within the authorized tolerance",
                "108x108 source normalization",
                "84x84 hard icon-safe alpha clear",
            ],
            "accepted_runtime_atlas_candidate_sha256": (
                ACCEPTED_ATLAS_CANDIDATE_SHA256
            ),
            "accepted_runtime_atlas_pixel_sha256": (
                EXPECTED_ATLAS_PIXEL_SHA256
            ),
        },
        "contract": {
            "provider_object": "CharacterAmmoSlot",
            "logical_size_ui": [27, 27],
            "source_size": list(SOURCE_SIZE),
            "source_texels_per_ui_unit": 4,
            "icon_safe_size_ui": [21, 21],
            "source_icon_safe_box": list(SOURCE_SAFE_BOX),
            "runtime_sample_size": list(RUNTIME_SIZE),
            "runtime_texels_per_ui_unit": TEXEL_DENSITY,
            "runtime_icon_safe_box": list(RUNTIME_SAFE_BOX),
            "dynamic_content_owner": [
                "item icon",
                "count",
                "cooldown",
                "click and tooltip",
                "availability and bag data",
            ],
        },
        "assets": source_assets,
    }
    SOURCE_MANIFEST.write_text(
        json.dumps(source_payload, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )

    runtime_payload = {
        "schema": "aeui-character-v3-e3-ammo-runtime-manifest-v1",
        "schema_version": 1,
        "module": "character",
        "batch": "CHAR-V3-E3-AMMO V1 final",
        "component": "CHAR.SLOT.AMMO",
        "status": "runtime-exported",
        "phase": "P5",
        "runtime_contract": "1.9",
        "ownership_route": "character.ammo-slot-v3",
        "source_manifest": repo_path(SOURCE_MANIFEST),
        "runtime": {
            "file": repo_path(RUNTIME_TGA),
            "sha256": sha256(RUNTIME_TGA),
            "texture_size": list(ATLAS_SIZE),
            "pixel_sha256": pixel_sha256(roundtrip),
            "texels_per_ui_unit": TEXEL_DENSITY,
            "tga": tga_header(RUNTIME_TGA),
            "states": runtime_states,
        },
        "integration": {
            "provider_object": "CharacterAmmoSlot",
            "anchor": "TOPLEFT 0,0 on the unchanged provider Button",
            "normal_layer": "ARTWORK",
            "interaction_layers": "native Button highlight/pushed/disabled textures",
            "dynamic_content": "provider-owned and never baked",
            "fallback": "restore pfUI backdrop and captured Button-state textures",
        },
    }
    RUNTIME_MANIFEST.write_text(
        json.dumps(runtime_payload, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--promote",
        action="store_true",
        help="copy the accepted attempt-5 exact pixels into assets/source",
    )
    args = parser.parse_args()

    if args.promote:
        promote_sources()
    sources = load_sources()
    atlas, runtime_states = build_atlas(sources)
    if pixel_sha256(atlas) != EXPECTED_ATLAS_PIXEL_SHA256:
        raise ValueError(
            "runtime atlas no longer matches the accepted exact-pixels preview: "
            f"{pixel_sha256(atlas)}"
        )
    SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    atlas.save(ATLAS_MASTER, format="PNG")
    roundtrip = save_tga(RUNTIME_TGA, atlas)
    write_manifests(sources, atlas, runtime_states, roundtrip)
    print(f"promoted={args.promote}")
    print(f"source_dir={repo_path(SOURCE_DIR)}")
    print(f"atlas_pixel_sha256={pixel_sha256(atlas)}")
    print(f"runtime_tga={repo_path(RUNTIME_TGA)} sha256={sha256(RUNTIME_TGA)}")


if __name__ == "__main__":
    main()
