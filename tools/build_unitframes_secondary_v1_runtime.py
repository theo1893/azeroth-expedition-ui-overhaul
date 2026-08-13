#!/usr/bin/env python3
"""Export accepted compact unit-frame sources into addon runtime media.

Accepted source pixels remain authoritative. This exporter only performs the
frozen deterministic operations: whole-source LANCZOS downscale, exact live-bed
Alpha clearing for the overlay rim, short state-edge derivation, transparent RGB
cleanup, and uncompressed 32-bit RGBA TGA export.
"""

from __future__ import annotations

import hashlib
import json
import struct
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops, ImageDraw, ImageFilter

from runtime_texture_compat import (
    content_uv,
    pad_to_power_of_two,
    power_of_two_size,
)


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets/source/unitframes/secondary-v1"
SOURCE_MANIFEST = SOURCE_DIR / "UF-SECONDARY-V1_SourceManifest.json"
RUNTIME_MANIFEST = SOURCE_DIR / "UF-SECONDARY-V1_RuntimeManifest.json"
RUNTIME_DIR = ROOT / "addon/AzerothExpeditionUI/Media/UnitFrames"

ROLES: dict[str, dict[str, Any]] = {
    "targettarget": {
        "component": "UF.TARGETTARGET.SHELL",
        "source": "UnitFrameTargetTargetShell_MasterV1.png",
        "source_sha256": (
            "ddf04c72098fd88a967ff8da72e5bc60d98492dd194b5d5afc72244474f42fe1"
        ),
        "rim_source": "UnitFrameTargetTargetShellRim_MasterV1.png",
        "rim_source_sha256": (
            "aaaf69d02187a53d32fb45675aa5a8752e00c89ab884e552d8499d228992c103"
        ),
        "source_size": (672, 204),
        "runtime_size": (112, 34),
        "live_bed": (6, 6, 106, 28),
        "slice_x": (20, 72, 20),
        "slice_y": (6, 22, 6),
        "outsets": {"left": 6, "right": 6, "top": 6, "bottom": 6},
        "runtime": "UnitFrameTargetTargetShellV1.tga",
        "rim": "UnitFrameTargetTargetShellRimV1.tga",
        "hover": "UnitFrameTargetTargetHoverRimV1.tga",
        "aggro": "UnitFrameTargetTargetAggroRimV1.tga",
    },
    "focus": {
        "component": "UF.FOCUS.SHELL",
        "source": "UnitFrameFocusShell_MasterV1.png",
        "source_sha256": (
            "9b6fee00cf242905a09a9cba5b4b543de2eaf4238d5118bc61fda47c94fb3b7c"
        ),
        "rim_source": "UnitFrameFocusShellRim_MasterV1.png",
        "rim_source_sha256": (
            "03ac97df6205152b9993ac217d64c5b3ff55e7eacc4004bcedd893a0f5a51353"
        ),
        "source_size": (672, 258),
        "runtime_size": (112, 43),
        "live_bed": (6, 10, 106, 37),
        "slice_x": (24, 64, 24),
        "slice_y": (10, 27, 6),
        "outsets": {"left": 6, "right": 6, "top": 10, "bottom": 6},
        "runtime": "UnitFrameFocusShellV1.tga",
        "rim": "UnitFrameFocusShellRimV1.tga",
        "hover": "UnitFrameFocusHoverRimV1.tga",
        "aggro": "UnitFrameFocusAggroRimV1.tga",
    },
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def repository_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    clean = Image.new("RGBA", rgba.size)
    clean.putdata(
        [
            (0, 0, 0, 0) if alpha == 0 else (red, green, blue, alpha)
            for red, green, blue, alpha in rgba.getdata()
        ]
    )
    return clean


def visible_green_pixels(image: Image.Image) -> int:
    return sum(
        1
        for red, green, blue, alpha in image.convert("RGBA").getdata()
        if alpha
        and green >= 35
        and green >= red + 12
        and green >= blue + 12
    )


def transparent_rgb_nonzero(image: Image.Image) -> int:
    return sum(
        1
        for red, green, blue, alpha in image.convert("RGBA").getdata()
        if alpha == 0 and (red or green or blue)
    )


def image_metrics(image: Image.Image) -> dict[str, Any]:
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


def load_accepted_image(
    role: str,
    filename: str,
    expected_sha256: str,
    expected_size: tuple[int, int],
    purpose: str,
) -> Image.Image:
    path = SOURCE_DIR / filename
    if sha256(path) != expected_sha256:
        raise ValueError(f"accepted {role} {purpose} SHA-256 changed: {path}")
    with Image.open(path) as opened:
        source = opened.convert("RGBA")
    if source.size != expected_size:
        raise ValueError(
            f"accepted {role} {purpose} must remain {expected_size}"
        )
    if visible_green_pixels(source) or transparent_rgb_nonzero(source):
        raise ValueError(f"accepted {role} {purpose} transparency drifted")
    return source


def make_runtime(source: Image.Image, size: tuple[int, int]) -> Image.Image:
    return clear_transparent_rgb(
        source.resize(size, Image.Resampling.LANCZOS)
    )


def make_overlay_rim(
    runtime: Image.Image,
    live_bed: tuple[int, int, int, int],
) -> Image.Image:
    rim = runtime.copy()
    ImageDraw.Draw(rim).rectangle(
        (live_bed[0], live_bed[1], live_bed[2] - 1, live_bed[3] - 1),
        fill=(0, 0, 0, 0),
    )
    return clear_transparent_rgb(rim)


def state_segments(
    role: str,
    state: str,
) -> list[tuple[int, int, int, int]]:
    if role == "targettarget":
        if state == "hover":
            return [(0, 0, 35, 8), (0, 0, 8, 22), (72, 29, 112, 34)]
        return [(0, 24, 40, 34), (88, 0, 112, 34), (50, 30, 82, 34)]
    if role == "focus":
        if state == "hover":
            return [(0, 0, 39, 13), (86, 0, 112, 17), (0, 35, 37, 43)]
        return [(91, 0, 112, 43), (0, 35, 112, 43), (0, 15, 10, 34)]
    raise ValueError(f"missing state-segment contract for {role}")


def make_state_mask(
    rim: Image.Image,
    role: str,
    state: str,
) -> Image.Image:
    alpha = rim.getchannel("A")
    eroded = alpha.filter(ImageFilter.MinFilter(3))
    edge = ImageChops.subtract(alpha, eroded).filter(ImageFilter.MaxFilter(3))
    if role == "focus":
        # Preserve the exact accepted A2 review derivation without changing
        # the already accepted TargetTarget state pixels.
        edge = ImageChops.multiply(edge, alpha)
    segments = Image.new("L", rim.size, 0)
    draw = ImageDraw.Draw(segments)
    for box in state_segments(role, state):
        draw.rectangle(box, fill=255)
    edge = ImageChops.multiply(edge, segments)
    strength = 185 if role == "focus" and state == "hover" else (
        190 if state == "hover" else 220
    )
    edge = edge.point(lambda value: min(strength, value * strength // 255))
    output = Image.new("RGBA", rim.size, (236, 220, 185, 0))
    output.putalpha(edge)
    return clear_transparent_rgb(output)


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


def save_runtime(
    image: Image.Image,
    path: Path,
    expected_size: tuple[int, int],
) -> Image.Image:
    path.parent.mkdir(parents=True, exist_ok=True)
    texture_size = power_of_two_size(expected_size)
    texture = pad_to_power_of_two(image)
    texture.save(path, format="TGA")
    with Image.open(path) as opened:
        roundtrip = opened.convert("RGBA")
    if ImageChops.difference(roundtrip, texture).getbbox() is not None:
        raise ValueError(f"TGA roundtrip changed pixels: {path}")
    logical_roundtrip = roundtrip.crop((0, 0, *expected_size))
    if ImageChops.difference(logical_roundtrip, image).getbbox() is not None:
        raise ValueError(f"TGA container changed accepted logical pixels: {path}")
    header = tga_header(path)
    if (
        header["image_type"] != 2
        or header["bits_per_pixel"] != 32
        or (header["width"], header["height"]) != texture_size
    ):
        raise ValueError(f"invalid runtime TGA: {path}: {header}")
    return logical_roundtrip


def live_bed_visible_pixels(
    image: Image.Image,
    live_bed: tuple[int, int, int, int],
) -> int:
    return sum(
        1
        for alpha in image.getchannel("A").crop(live_bed).getdata()
        if alpha
    )


def main() -> int:
    runtime_records: dict[str, Any] = {}
    source_records: dict[str, Any] = {}

    for role, contract in ROLES.items():
        source_path = SOURCE_DIR / contract["source"]
        source_size = tuple(contract["source_size"])
        source = load_accepted_image(
            role,
            contract["source"],
            contract["source_sha256"],
            source_size,
            "base source",
        )
        rim_source_path = SOURCE_DIR / contract["rim_source"]
        rim_source = load_accepted_image(
            role,
            contract["rim_source"],
            contract["rim_source_sha256"],
            source_size,
            "rim source",
        )
        runtime_size = tuple(contract["runtime_size"])
        live_bed = tuple(contract["live_bed"])
        runtime = make_runtime(source, runtime_size)
        rim = make_overlay_rim(
            make_runtime(rim_source, runtime_size),
            live_bed,
        )
        hover = make_state_mask(rim, role, "hover")
        aggro = make_state_mask(rim, role, "aggro")
        if live_bed_visible_pixels(rim, live_bed):
            raise ValueError(f"{role} overlay rim intrudes into its live bed")

        outputs = {
            "runtime": runtime,
            "rim": rim,
            "hover": hover,
            "aggro": aggro,
        }
        runtime_records[role] = {}
        for kind, image in outputs.items():
            path = RUNTIME_DIR / contract[kind]
            roundtrip = save_runtime(image, path, runtime_size)
            metrics = image_metrics(roundtrip)
            if (
                metrics["visible_green_spill_pixels"]
                or metrics["transparent_rgb_nonzero_pixels"]
            ):
                raise ValueError(f"{role} {kind} failed transparency checks")
            runtime_records[role][kind] = {
                "file": repository_path(path),
                "sha256": sha256(path),
                "tga_header": tga_header(path),
                "metrics": metrics,
                "logical_size": list(runtime_size),
                "texture_size": list(power_of_two_size(runtime_size)),
                "content_uv": content_uv(runtime_size),
            }
        source_records[role] = {
            "component": contract["component"],
            "file": repository_path(source_path),
            "sha256": sha256(source_path),
            "size": list(source.size),
            "rim_source": {
                "file": repository_path(rim_source_path),
                "sha256": sha256(rim_source_path),
                "size": list(rim_source.size),
            },
        }

    manifest = {
        "schema": "aeui-unitframes-secondary-v1-runtime-manifest-v1",
        "status": "runtime-exported-addon-integrated",
        "phase": "P5",
        "module": "unitframes",
        "runtime_contract": "1.6",
        "components": [contract["component"] for contract in ROLES.values()],
        "source_manifest": repository_path(SOURCE_MANIFEST),
        "sources": source_records,
        "runtime": runtime_records,
        "deterministic_export": {
            "tool": "tools/build_unitframes_secondary_v1_runtime.py",
            "operation": "whole-source LANCZOS downscale; accepted deterministic rim-source downscale plus exact live-bed Alpha clear; segmented edge masks derived from accepted rim Alpha; exact logical pixels padded top-left into 1.12-compatible power-of-two texture containers",
            "redraw": False,
            "mirror": False,
            "cross_role_pixels": False,
            "imagegen_calls": 0,
        },
        "geometry": {
            role: {
                "source_size": list(contract["source_size"]),
                "standard_runtime": list(contract["runtime_size"]),
                "texture_container": list(
                    power_of_two_size(tuple(contract["runtime_size"]))
                ),
                "content_uv": content_uv(tuple(contract["runtime_size"])),
                "provider_live_bed": list(contract["live_bed"]),
                "nine_slice_x": list(contract["slice_x"]),
                "nine_slice_y": list(contract["slice_y"]),
                "outsets": contract["outsets"],
                "complete_bitmap_vertical_stretch": False,
                "provider_geometry_changed": False,
            }
            for role, contract in ROLES.items()
        },
        "adapter": {
            "file": "addon/AzerothExpeditionUI/Modules/UnitFrames.lua",
            "provider_bridge": "addon/pfUI/api/unitframes.lua",
            "ownership": "addon/pfUI/api/expedition.lua",
            "route": "unitframes.primary-shell",
            "frames": ["pfTargetTarget", "pfFocus"],
            "fallback": "hide AEUI slices and let pfUI rebuild configured backdrops and glows",
        },
        "deployment": {
            "build_required_on_target_device": False,
            "game_validation": "pending Turtle WoW 1.18.1 / P6",
        },
    }
    RUNTIME_MANIFEST.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        "exported UF-SECONDARY V1 runtime: "
        f"{len(ROLES)} roles, {sum(len(value) for value in runtime_records.values())} TGA files"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
