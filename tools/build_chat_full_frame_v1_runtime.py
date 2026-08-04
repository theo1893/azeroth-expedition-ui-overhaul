#!/usr/bin/env python3
"""Export the accepted CHAT.FRAME.FULL.V1 source for Turtle WoW.

The accepted 1608x978 RGBA source is immutable.  This tool only validates its
identity, proportionally resamples the whole frame into the established V3
nine-slice atlas geometry, writes a power-of-two TGA, and records the exact
crop/UV/runtime contract.  It never redraws or mixes pixels from another frame.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (
    ROOT
    / "assets"
    / "source"
    / "chat"
    / "frame-full-v1"
    / "ChatBookFrame_Full_V1_r1.png"
)
RUNTIME = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Chat"
    / "ChatBookFrameFullV1.tga"
)
RUNTIME_MANIFEST = (
    ROOT
    / "assets"
    / "source"
    / "chat"
    / "frame-full-v1"
    / "ChatBookFrame_Full_V1_RuntimeManifest_v1.json"
)
ARTIFACT_DIR = (
    ROOT
    / "generated"
    / "chat"
    / "core"
    / "CHAT.FRAME.FULL.V1"
    / "runtime-v1"
)

SOURCE_SHA256 = (
    "a97d9c5fa055a119cd5ea7809bdaa51460cddb9674355efcec35f98f6cd2c673"
)
SOURCE_SIZE = (1608, 978)
SOURCE_VISIBLE_BBOX = (24, 25, 1584, 952)
ATLAS_SIZE = (1024, 1024)
ATLAS_CONTENT_SIZE = (1024, 623)
SOURCE_NINE_SLICE_CUTS = (215, 100, 1485, 860)
ATLAS_NINE_SLICE_CUTS = {
    "left": 137,
    "top": 64,
    "right": 946,
    "bottom": 548,
    "content_bottom": 623,
}
RUNTIME_CAPS = {"left": 30, "right": 30, "top": 28, "bottom": 28}
CONTENT_SAFE_INSETS = {"left": 30, "right": 30, "top": 32, "bottom": 40}
SUPPORTED_FRAME_SIZES = ((440, 320), (540, 420))
PAPER_CONTRAST_PROXY_RGB = (48, 36, 27)
INLINE_CONTRAST_TARGET = 4.8
LOW_ALPHA_RINGING_LIMIT = 16
RESAMPLE = Image.Resampling.LANCZOS

# This palette is the user-confirmed dark-paper direction.  The saturated
# colors are unglowed Vanilla display colors, not baked pixels.
TEXT_PALETTE_RGB = {
    "say": (201, 185, 144),
    "channel": (255, 192, 192),
    "system": (255, 255, 0),
    "guild": (64, 255, 64),
    "party": (170, 170, 255),
    "raid": (255, 127, 0),
    "whisper": (255, 128, 255),
    "danger": (255, 86, 86),
    "emote": (255, 127, 63),
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def display_path(path: Path) -> str:
    resolved = path.resolve()
    try:
        return resolved.relative_to(ROOT).as_posix()
    except ValueError:
        return str(resolved)


def alpha_evidence(image: Image.Image) -> dict[str, Any]:
    alpha = image.getchannel("A")
    histogram = alpha.histogram()
    bbox = alpha.getbbox()
    exact_green = 0
    dominant_green = 0
    pixels = (
        image.get_flattened_data()
        if hasattr(image, "get_flattened_data")
        else image.getdata()
    )
    for red, green, blue, pixel_alpha in pixels:
        if pixel_alpha == 0:
            continue
        if red <= 4 and green >= 251 and blue <= 4:
            exact_green += 1
        if green >= 128 and green >= red + 32 and green >= blue + 32:
            dominant_green += 1
    return {
        "visible_bbox_exclusive": list(bbox) if bbox else None,
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
        "pure_green_visible_pixels": exact_green,
        "visible_green_spill_pixels": dominant_green,
    }


def validate_source(path: Path, image: Image.Image) -> None:
    if sha256(path) != SOURCE_SHA256:
        raise ValueError("frame source SHA-256 does not match the accepted P4 source")
    if image.size != SOURCE_SIZE or image.mode != "RGBA":
        raise ValueError(
            f"frame source must be {SOURCE_SIZE} RGBA, got {image.size} {image.mode}"
        )
    bbox = image.getchannel("A").getbbox()
    if bbox != SOURCE_VISIBLE_BBOX:
        raise ValueError(
            f"frame source visible bbox must be {SOURCE_VISIBLE_BBOX}, got {bbox}"
        )
    minimum, maximum = image.getchannel("A").getextrema()
    if (minimum, maximum) != (0, 255):
        raise ValueError("frame source must contain transparent and opaque pixels")


def clear_low_alpha_green_ringing(image: Image.Image) -> dict[str, int]:
    """Remove only impossible green Lanczos ringing from the soft outline.

    The accepted source has no visible dominant-green pixels.  Straight-alpha
    Lanczos can nevertheless create clipped green RGB values at very low
    Alpha.  Clearing RGB for those pixels preserves Alpha and every authored
    visible pixel while preventing a colored fringe in the serialized TGA.
    """

    pixels = image.load()
    cleared = 0
    highest_alpha = 0
    for y in range(image.height):
        for x in range(image.width):
            red, green, blue, alpha = pixels[x, y]
            if (
                0 < alpha <= LOW_ALPHA_RINGING_LIMIT
                and green >= 128
                and green >= red + 32
                and green >= blue + 32
            ):
                pixels[x, y] = (0, 0, 0, alpha)
                cleared += 1
                highest_alpha = max(highest_alpha, alpha)
    return {
        "cleared_pixel_count": cleared,
        "highest_affected_alpha": highest_alpha,
        "alpha_limit": LOW_ALPHA_RINGING_LIMIT,
    }


def build_atlas(source: Image.Image) -> tuple[Image.Image, dict[str, int]]:
    resized = source.resize(ATLAS_CONTENT_SIZE, RESAMPLE)
    ringing_cleanup = clear_low_alpha_green_ringing(resized)
    atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
    atlas.alpha_composite(resized, (0, 0))
    return atlas, ringing_cleanup


def build_frame(atlas: Image.Image, size: tuple[int, int]) -> Image.Image:
    target_width, target_height = size
    if target_width <= RUNTIME_CAPS["left"] + RUNTIME_CAPS["right"]:
        raise ValueError(f"frame width is below the nine-slice minimum: {size}")
    if target_height <= RUNTIME_CAPS["top"] + RUNTIME_CAPS["bottom"]:
        raise ValueError(f"frame height is below the nine-slice minimum: {size}")

    source_x = (
        0,
        ATLAS_NINE_SLICE_CUTS["left"],
        ATLAS_NINE_SLICE_CUTS["right"],
        ATLAS_SIZE[0],
    )
    source_y = (
        0,
        ATLAS_NINE_SLICE_CUTS["top"],
        ATLAS_NINE_SLICE_CUTS["bottom"],
        ATLAS_NINE_SLICE_CUTS["content_bottom"],
    )
    target_x = (
        0,
        RUNTIME_CAPS["left"],
        target_width - RUNTIME_CAPS["right"],
        target_width,
    )
    target_y = (
        0,
        RUNTIME_CAPS["top"],
        target_height - RUNTIME_CAPS["bottom"],
        target_height,
    )
    output = Image.new("RGBA", size, (0, 0, 0, 0))
    for row in range(3):
        for column in range(3):
            source_box = (
                source_x[column],
                source_y[row],
                source_x[column + 1],
                source_y[row + 1],
            )
            target_box = (
                target_x[column],
                target_y[row],
                target_x[column + 1],
                target_y[row + 1],
            )
            patch = atlas.crop(source_box).resize(
                (
                    target_box[2] - target_box[0],
                    target_box[3] - target_box[1],
                ),
                RESAMPLE,
            )
            output.alpha_composite(patch, (target_box[0], target_box[1]))
    return output


def save_tga(image: Image.Image, path: Path) -> None:
    if image.mode != "RGBA" or image.size != ATLAS_SIZE:
        raise ValueError(f"runtime atlas must be {ATLAS_SIZE} RGBA")
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="TGA")


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=False, compress_level=9)


def normalized_uv() -> dict[str, float]:
    return {
        "left": ATLAS_NINE_SLICE_CUTS["left"] / ATLAS_SIZE[0],
        "right": ATLAS_NINE_SLICE_CUTS["right"] / ATLAS_SIZE[0],
        "top": ATLAS_NINE_SLICE_CUTS["top"] / ATLAS_SIZE[1],
        "bottom_inner": ATLAS_NINE_SLICE_CUTS["bottom"] / ATLAS_SIZE[1],
        "content_bottom": (
            ATLAS_NINE_SLICE_CUTS["content_bottom"] / ATLAS_SIZE[1]
        ),
    }


def build_manifest(
    source_path: Path,
    source: Image.Image,
    runtime_path: Path,
    atlas: Image.Image,
    artifact_dir: Path,
    ringing_cleanup: dict[str, int],
) -> dict[str, Any]:
    return {
        "schema_version": 1,
        "module": "chat",
        "batch": "CHAT.FRAME.FULL.V1",
        "accepted_version": "CHAT.FRAME.FULL.V1.r1 attempt 2",
        "runtime_contract": "1.19",
        "status": "runtime-exported",
        "single_chat_frame": True,
        "source": {
            "file": display_path(source_path),
            "sha256": sha256(source_path),
            "width": source.width,
            "height": source.height,
            "mode": source.mode,
            **alpha_evidence(source),
        },
        "deterministic_export": {
            "operation": (
                "proportional whole-source LANCZOS resize to 1024x623; "
                "RGB clearing only for impossible dominant-green ringing at "
                "Alpha <=16; top-left placement on a transparent 1024x1024 "
                "atlas; and RGBA TGA serialization"
            ),
            "foreign_source_pixels_mixed": False,
            "redraw": False,
            "low_alpha_ringing_cleanup": ringing_cleanup,
            "source_nine_slice_cuts": list(SOURCE_NINE_SLICE_CUTS),
            "atlas_content_size": list(ATLAS_CONTENT_SIZE),
            "atlas_nine_slice_cuts": ATLAS_NINE_SLICE_CUTS,
            "normalized_uv": normalized_uv(),
            "runtime_caps_ltrb": [
                RUNTIME_CAPS["left"],
                RUNTIME_CAPS["top"],
                RUNTIME_CAPS["right"],
                RUNTIME_CAPS["bottom"],
            ],
            "content_safe_insets_ltrb": [
                CONTENT_SAFE_INSETS["left"],
                CONTENT_SAFE_INSETS["top"],
                CONTENT_SAFE_INSETS["right"],
                CONTENT_SAFE_INSETS["bottom"],
            ],
            "supported_frame_sizes": [list(item) for item in SUPPORTED_FRAME_SIZES],
        },
        "runtime_export": {
            "file": display_path(runtime_path),
            "sha256": sha256(runtime_path),
            "width": atlas.width,
            "height": atlas.height,
            "mode": atlas.mode,
            "logical_sampled_bbox": [0, 0, 1024, 623],
            **alpha_evidence(atlas),
        },
        "adapter": {
            "file": "addon/AzerothExpeditionUI/Modules/Chat.lua",
            "runtime_owner": "pfUI.chat.left / pfChatLeft",
            "texture_instances": 9,
            "right_frame_instances": 0,
            "fallback": "retained ChatBookFrameV3.tga and native/pfUI behavior",
        },
        "text_readability": {
            "paper_contrast_proxy_rgb": list(PAPER_CONTRAST_PROXY_RGB),
            "paper_proxy_role": "90th-percentile common reading-field luminance",
            "inline_contrast_target": INLINE_CONTRAST_TARGET,
            "palette_rgb": {
                key: list(value) for key, value in TEXT_PALETTE_RGB.items()
            },
            "unknown_inline_rule": (
                "preserve colors already meeting contrast; otherwise mix the "
                "minimum amount toward white until the target is reached"
            ),
            "outline": False,
            "shadow": False,
            "glow": False,
        },
        "review_artifacts": {
            "atlas_png": display_path(
                artifact_dir / "ChatBookFrameFullV1_RuntimeAtlas.png"
            ),
            "assembled_440x320": display_path(
                artifact_dir / "ChatBookFrameFullV1_440x320.png"
            ),
            "assembled_540x420": display_path(
                artifact_dir / "ChatBookFrameFullV1_540x420.png"
            ),
            "real_layout_spec": (
                "tools/specs/chat_full_frame_runtime_preview_v1.json"
            ),
            "display_region_contract": (
                "tools/specs/chat_full_frame_runtime_display_region_v1.json"
            ),
        },
        "forbidden_runtime_uses": [
            "do not load the accepted 1608x978 source directly in game",
            "do not use one stretched full-frame texture instead of nine slices",
            "do not mix pixels from the V3 frame or rejected paper donor",
            "do not bake tabs, text, input, unread, buttons or legacy panels",
            "do not instantiate a right-side chat book",
        ],
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--runtime", type=Path, default=RUNTIME)
    parser.add_argument("--manifest", type=Path, default=RUNTIME_MANIFEST)
    parser.add_argument("--artifact-dir", type=Path, default=ARTIFACT_DIR)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    source = Image.open(args.source).convert("RGBA")
    validate_source(args.source, source)
    atlas, ringing_cleanup = build_atlas(source)
    save_tga(atlas, args.runtime)

    save_png(atlas, args.artifact_dir / "ChatBookFrameFullV1_RuntimeAtlas.png")
    save_png(
        build_frame(atlas, SUPPORTED_FRAME_SIZES[0]),
        args.artifact_dir / "ChatBookFrameFullV1_440x320.png",
    )
    save_png(
        build_frame(atlas, SUPPORTED_FRAME_SIZES[1]),
        args.artifact_dir / "ChatBookFrameFullV1_540x420.png",
    )

    manifest = build_manifest(
        args.source,
        source,
        args.runtime,
        atlas,
        args.artifact_dir,
        ringing_cleanup,
    )
    args.manifest.parent.mkdir(parents=True, exist_ok=True)
    args.manifest.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(manifest, ensure_ascii=False))


if __name__ == "__main__":
    main()
