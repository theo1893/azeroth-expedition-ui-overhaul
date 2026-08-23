#!/usr/bin/env python3
"""Export the accepted Player V5 shell at two texels per UI unit."""

from __future__ import annotations

import hashlib
import json
import struct
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops

from runtime_texture_compat import content_uv, pad_to_power_of_two, power_of_two_size


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets/source/unitframes/player-v5"
SOURCE = SOURCE_DIR / "UnitFramePlayerShell_SourceV5.png"
RUNTIME_MASTER = SOURCE_DIR / "UnitFramePlayerShell_RuntimeMasterV5.png"
SOURCE_MANIFEST = SOURCE_DIR / "UF-PLAYER-V5_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "UF-PLAYER-V5_RuntimeManifest_v1.json"
RUNTIME = (
    ROOT
    / "addon/AzerothExpeditionUI/Media/UnitFrames/UnitFramePlayerShellV5.tga"
)

SOURCE_SIZE = (1524, 462)
LOGICAL_SIZE = (254, 77)
SAMPLED_SIZE = (508, 154)
TEXTURE_SIZE = power_of_two_size(SAMPLED_SIZE)
TEXELS_PER_UI = 2
SOURCE_SAFE = (42, 96, 1482, 432)
RUNTIME_SAFE = (7, 16, 247, 72)
SAMPLED_SAFE = (14, 32, 494, 144)
SOURCE_SHA256 = "ec74c829d18553cc78ab95a4ae1a01fc392d2efc2157e42a4a5166f7f0cf903d"
RUNTIME_MASTER_SHA256 = "d449b8bd1dfef1a073ca69cecc57e2c7cb0d38e4a4fb9961bd60f8467253ecbc"
RAW_SHA256 = "5b0f588d66ba75a811dac7528b1c6064782d2c653dcc602c4f79c6ba6a0290e8"


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


def visible_green_pixels(image: Image.Image) -> int:
    return sum(
        1
        for red, green, blue, alpha in image.convert("RGBA").getdata()
        if alpha and red <= 32 and green >= 224 and blue <= 32
    )


def alpha_max(image: Image.Image, box: tuple[int, int, int, int]) -> int:
    return max(image.getchannel("A").crop(box).getdata(), default=0)


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


def load_exact(path: Path, expected_size: tuple[int, int], expected_sha: str) -> Image.Image:
    if sha256(path) != expected_sha:
        raise ValueError(f"accepted file SHA-256 changed: {path}")
    with Image.open(path) as opened:
        image = opened.convert("RGBA")
    if image.size != expected_size:
        raise ValueError(f"accepted file must remain {expected_size}: {path}")
    # The accepted runtime contains one pure-green edge pixel at Alpha 1 from
    # the authorized LANCZOS pass. Its exact SHA is authoritative; do not
    # silently alter it during promotion. Transparent pixels must still keep
    # zero RGB so the padded container cannot bleed colour.
    if transparent_rgb_nonzero(image):
        raise ValueError(f"accepted transparency changed: {path}")
    return image


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


def export_runtime(source: Image.Image) -> Image.Image:
    RUNTIME.parent.mkdir(parents=True, exist_ok=True)
    sampled = clear_transparent_rgb(
        source.resize(SAMPLED_SIZE, Image.Resampling.LANCZOS)
    )
    sampled.paste((0, 0, 0, 0), SAMPLED_SAFE)
    sampled = clear_transparent_rgb(sampled)
    texture = pad_to_power_of_two(sampled)
    texture.save(RUNTIME, format="TGA")
    with Image.open(RUNTIME) as opened:
        roundtrip = opened.convert("RGBA")
    if ImageChops.difference(roundtrip, texture).getbbox() is not None:
        raise ValueError("TGA roundtrip changed the padded texture")
    sampled_roundtrip = roundtrip.crop((0, 0, *SAMPLED_SIZE))
    if ImageChops.difference(sampled_roundtrip, sampled).getbbox() is not None:
        raise ValueError("TGA export changed accepted sampled pixels")
    header = tga_header(RUNTIME)
    if (
        header["image_type"] != 2
        or header["bits_per_pixel"] != 32
        or (header["width"], header["height"]) != TEXTURE_SIZE
    ):
        raise ValueError(f"invalid Turtle WoW runtime TGA: {header}")
    return sampled_roundtrip


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def main() -> int:
    source = load_exact(SOURCE, SOURCE_SIZE, SOURCE_SHA256)
    runtime_master = load_exact(
        RUNTIME_MASTER, LOGICAL_SIZE, RUNTIME_MASTER_SHA256
    )
    if alpha_max(source, SOURCE_SAFE) != 0:
        raise ValueError("accepted source dynamic hard-clear region is no longer empty")
    if alpha_max(runtime_master, (7, 16, 247, 72)) != 0:
        raise ValueError("accepted runtime dynamic hard-clear region is no longer empty")

    runtime_roundtrip = export_runtime(source)
    if alpha_max(runtime_roundtrip, SAMPLED_SAFE) != 0:
        raise ValueError("2x runtime dynamic hard-clear region is no longer empty")
    runtime_header = tga_header(RUNTIME)

    write_json(
        SOURCE_MANIFEST,
        {
            "schema": "aeui-unitframes-player-v5-source-manifest-v1",
            "schema_version": 1,
            "module": "unitframes",
            "batch": "UF-PLAYER-SHELL-V5-A1",
            "component": "UF.PLAYER.SHELL",
            "status": "accepted-source",
            "phase": "P4",
            "accepted_on": "2026-08-17",
            "user_acceptance": {
                "statement": "接受 UF-PLAYER-SHELL-V5-A1 attempt 3 的 exact pixels；允许提升 source/runtime、导出正式媒体并接入 addon。",
                "accepts_exact_pixels": True,
                "source_promotion_authorized": True,
                "runtime_export_authorized": True,
                "addon_integration_authorized": True,
                "authorized_exception": "right dynamic hard-clear intrusion: 9 source px; Alpha-clear only",
            },
            "provenance": {
                "executor": "imagegen-0-143-0",
                "production_attempt": 3,
                "actual_imagegen_calls": 5,
                "raw_candidate_sha256": RAW_SHA256,
                "postprocess": "colour key, transparent RGB clear, bounded X/Y normalization, authorized hard-clear Alpha removal, LANCZOS runtime resize",
                "python_generated_visual_pixels": False,
            },
            "accepted_assets": {
                "source": {
                    "file": repository_path(SOURCE),
                    "sha256": sha256(SOURCE),
                    "metrics": metrics(source),
                    "dynamic_hard_clear": list(SOURCE_SAFE),
                    "dynamic_hard_clear_alpha_max": alpha_max(source, SOURCE_SAFE),
                },
                "runtime_master": {
                    "file": repository_path(RUNTIME_MASTER),
                    "sha256": sha256(RUNTIME_MASTER),
                    "metrics": metrics(runtime_master),
                    "dynamic_hard_clear": list(RUNTIME_SAFE),
                    "dynamic_hard_clear_alpha_max": alpha_max(
                        runtime_master, RUNTIME_SAFE
                    ),
                },
            },
            "geometry": {
                "provider": "pfUI.uf.player / pfPlayer",
                "provider_size": [240, 65],
                "art_box": [254, 77],
                "outsets": {"left": 7, "right": 7, "top": 6, "bottom": 6},
                "logical_art_box": list(LOGICAL_SIZE),
                "sampled_art_box": list(SAMPLED_SIZE),
                "texture_container": list(TEXTURE_SIZE),
                "texels_per_ui": TEXELS_PER_UI,
                "complete_bitmap": True,
                "canonical_size_only": True,
                "ui_scale_inherits_from_provider": True,
                "provider_geometry_changed": False,
            },
            "visual_authority": {
                "global_prompt": "docs/GLOBAL_ART_BASELINE.md",
                "module_prompt": "docs/modules/unitframes/ART_BASELINE.md",
                "submodule_prompt": "docs/modules/unitframes/SUBMODULE_ART_BASELINES.md",
                "submodule_prompt_heading": "UF.PLAYER.SHELL",
                "component_contract": "docs/modules/unitframes/SUBMODULES.md",
            },
        },
    )

    write_json(
        RUNTIME_MANIFEST,
        {
            "schema": "aeui-unitframes-player-v5-runtime-manifest-v1",
            "schema_version": 1,
            "module": "unitframes",
            "component": "UF.PLAYER.SHELL",
            "status": "runtime-exported-addon-integrated",
            "phase": "P5",
            "runtime_contract": "1.8",
            "source_manifest": repository_path(SOURCE_MANIFEST),
            "route": "unitframes.player-shell-v5",
            "runtime": {
                "file": repository_path(RUNTIME),
                "sha256": sha256(RUNTIME),
                "logical_size": list(LOGICAL_SIZE),
                "sampled_size": list(SAMPLED_SIZE),
                "texels_per_ui": TEXELS_PER_UI,
                "texture_size": list(TEXTURE_SIZE),
                "content_uv": content_uv(SAMPLED_SIZE, TEXTURE_SIZE),
                "tga_header": runtime_header,
                "sampled_metrics": metrics(runtime_roundtrip),
                "accepted_runtime_master_sha256": sha256(RUNTIME_MASTER),
                "historical_1x_runtime_master_retained": True,
                "source_to_sampled": [list(SOURCE_SIZE), list(SAMPLED_SIZE)],
            },
            "addon_contract": {
                "provider": "pfUI.uf.player / pfPlayer",
                "canonical_provider_size": [240, 65],
                "assembly": "one complete bitmap; no slicing or texture reconstruction",
                "ui_scale": "inherited parent scale; 508x154 samples display in the unchanged 254x77 art box",
                "size_mismatch": "restore only Player to configured pfUI chrome",
                "other_roles": "Target, TargetTarget and Focus remain paused on pfUI fallback",
                "dynamic_owner": "pfUI retains bars, text, colours, auras, icons, clicks and events",
            },
        },
    )

    print(
        json.dumps(
            {
                "source_sha256": sha256(SOURCE),
                "runtime_master_sha256": sha256(RUNTIME_MASTER),
                "runtime_tga_sha256": sha256(RUNTIME),
                "runtime_tga": repository_path(RUNTIME),
                "texture_size": list(TEXTURE_SIZE),
                "logical_geometry_unchanged": True,
                "texels_per_ui": TEXELS_PER_UI,
            },
            ensure_ascii=False,
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
