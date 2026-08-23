#!/usr/bin/env python3
"""Promote the accepted Minimap V3 pixels and export Vanilla-safe media.

ImageGen owns the accepted hand-painted pixels.  This builder performs only the
authorized deterministic work: chroma-key cleanup, fixed component extraction,
aspect-preserving bbox fit, state/rotation derivation, POT TGA packing, and
manifest generation.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageEnhance

from runtime_texture_compat import content_uv, pad_to_power_of_two, power_of_two_size


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets/source/map/mini-v3"
RUNTIME_DIR = ROOT / "addon/AzerothExpeditionUI/Media/Map"
SOURCE_MANIFEST = SOURCE_DIR / "MAP-MINI-V3_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "MAP-MINI-V3_RuntimeManifest_v1.json"

RAW_ACCEPTED = {
    "a": {
        "sha256": "5c6190eb3eee72aa5360e8d3390bb5f51187f13731da8a008d05809b1c7c6982",
        "size": (1146, 1373),
        "attempt": 2,
        "calls": 2,
    },
    "b": {
        "sha256": "fa42e6aa246ae217ca9fae381adee692048b940990033dbfc9c74f5d6d625f07",
        "size": (1254, 1254),
        "attempt": 1,
        "calls": 1,
    },
    "c": {
        "sha256": "b643663c2adaee771e0969898e460d9675167ce8ecc10a636d9c1025774a8302",
        "size": (1683, 935),
        "attempt": 4,
        "calls": 4,
    },
}

SOURCE = {
    "compass": {
        "filename": "MapMiniCompassCradle_SourceV3.png",
        "size": (220, 264),
        "component": "MAP.MINI.COMPASS.INFO.V3",
    },
    "latch": {
        "filename": "MapMiniAddonLatch_SourceV3.png",
        "size": (38, 24),
        "component": "MAP.MINI.ADDONS.TOGGLE.LATCH.V3",
    },
    "glyph": {
        "filename": "MapMiniAddonGlyph_SourceV3.png",
        "size": (10, 12),
        "component": "MAP.MINI.ADDONS.TOGGLE.GLYPH.V3",
    },
    "connector": {
        "filename": "MapMiniAddonConnector_SourceV3.png",
        "size": (32, 14),
        "component": "MAP.MINI.ADDONS.CONNECTOR.V3",
    },
    "socket": {
        "filename": "MapMiniStatusSocket_SourceV3.png",
        "size": (24, 24),
        "component": "MAP.MINI.STATUS.SOCKET.V3",
    },
    "tray": {
        "filename": "MapMiniAddonTray_SourceV3.png",
        "size": (270, 74),
        "component": "MAP.MINI.ADDONS.TRAY.V3",
    },
}

# Filled with immutable accepted source hashes after the first promotion.  The
# manifest remains the package-level authority; these constants prevent a
# later rebuild from silently consuming edited source pixels.
SOURCE_EXPECTED_SHA256 = {
    "compass": "d0ee4ac3cec0ca936795d61a79c48a0ecdc2ae10848d8a6d5ee60e10be202613",
    "latch": "0878de0512ee659c5b51c911c53a9ded2b739003ba12a8afcbc0d7f4c0467d33",
    "glyph": "c2496bf80ea2ffd9b071ad8b5cd76886d555e0dbdea4498787f49cd0bcc5040f",
    "connector": "752ae6ff103e6105724b431a023546a74948e964bcf5521d74d084ff8d4d2a0c",
    "socket": "ec41629b673b1331ff09d8f93a63289f911f166a06bf4a6bd5651692b08e6da3",
    "tray": "923c0878eb459639edf1b03fcf881236f82338a512d1c05126ea49a934ed6696",
}

DIRECTIONS = ("bottom", "top", "left", "right")
STATES = ("normal", "hover", "pressed")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--promote-a", type=Path)
    parser.add_argument("--promote-b", type=Path)
    parser.add_argument("--promote-c", type=Path)
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


def clear_chroma_spill(image: Image.Image) -> Image.Image:
    """Clear only low-alpha or bright cyan fringe left by keyed resampling."""

    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    rgb = rgba[:, :, :3].astype(np.int16)
    cyan_dominant = (
        (rgb[:, :, 1] > rgb[:, :, 0] + 40)
        & (rgb[:, :, 2] > rgb[:, :, 0] + 40)
    )
    low_alpha = rgba[:, :, 3] <= 96
    bright_key_mix = rgb[:, :, 1] + rgb[:, :, 2] >= 260
    spill = (
        (rgba[:, :, 3] > 0)
        & cyan_dominant
        & (low_alpha | bright_key_mix)
    )
    rgba[spill] = 0
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
        "visible_bbox_exclusive": list(
            rgba.getchannel("A").getbbox() or (0, 0, 0, 0)
        ),
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
        "transparent_rgb_nonzero_values": transparent_rgb_nonzero(rgba),
    }


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    clear_transparent_rgb(image).save(path, format="PNG", compress_level=9)


def validate_raw(path: Path, key: str) -> Image.Image:
    contract = RAW_ACCEPTED[key]
    resolved = path.resolve()
    if sha256(resolved) != contract["sha256"]:
        raise ValueError(f"accepted raw hash mismatch: {resolved}")
    with Image.open(resolved) as opened:
        image = opened.convert("RGBA")
    if image.size != contract["size"]:
        raise ValueError(
            f"accepted raw size mismatch: {key} {image.size} != {contract['size']}"
        )
    return image


def border_key(image: Image.Image, border: int) -> np.ndarray:
    rgb = np.asarray(image.convert("RGB"), dtype=np.uint8)
    samples = np.concatenate(
        [
            rgb[:border].reshape(-1, 3),
            rgb[-border:].reshape(-1, 3),
            rgb[:, :border].reshape(-1, 3),
            rgb[:, -border:].reshape(-1, 3),
        ]
    )
    return np.median(samples, axis=0)


def chroma_mask(
    image: Image.Image,
    *,
    threshold: int,
    border: int,
) -> np.ndarray:
    rgb = np.asarray(image.convert("RGB"), dtype=np.uint8)
    key = border_key(image, border)
    return (
        np.max(
            np.abs(rgb.astype(np.int16) - key.astype(np.int16)),
            axis=2,
        )
        <= threshold
    )


def key_image(
    image: Image.Image,
    *,
    threshold: int,
    border: int,
) -> tuple[Image.Image, np.ndarray]:
    keyed = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    mask = chroma_mask(image, threshold=threshold, border=border)
    keyed[mask, 3] = 0
    keyed[mask, :3] = 0
    return clear_transparent_rgb(Image.fromarray(keyed, "RGBA")), mask


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("keyed component is empty")
    return bbox


def connected_key_centre(
    source: Image.Image,
    mask: np.ndarray,
    seed: tuple[int, int],
) -> tuple[float, float]:
    if not bool(mask[seed[1], seed[0]]):
        raise ValueError("declared minimap opening seed is not chroma key")
    # Pillow's L-mode floodfill is a no-op in some py312/Pillow builds.  Keep
    # the operation deterministic with a scanline flood fill over the boolean
    # key mask instead of depending on that implementation detail.
    component = np.zeros_like(mask, dtype=bool)
    stack = [seed]
    height, width = mask.shape
    while stack:
        x, y = stack.pop()
        if x < 0 or x >= width or y < 0 or y >= height:
            continue
        if component[y, x] or not mask[y, x]:
            continue
        left = x
        while left > 0 and mask[y, left - 1] and not component[y, left - 1]:
            left -= 1
        right = x
        while (
            right + 1 < width
            and mask[y, right + 1]
            and not component[y, right + 1]
        ):
            right += 1
        component[y, left : right + 1] = True
        for adjacent_y in (y - 1, y + 1):
            if adjacent_y < 0 or adjacent_y >= height:
                continue
            candidates = (
                mask[adjacent_y, left : right + 1]
                & ~component[adjacent_y, left : right + 1]
            )
            starts = candidates & np.concatenate(
                ([True], ~candidates[:-1])
            )
            for offset in np.flatnonzero(starts):
                stack.append((left + int(offset), adjacent_y))
    ys, xs = np.where(component)
    if not len(xs):
        raise ValueError("minimap opening component is empty")
    return float(xs.mean()), float(ys.mean())


def fit(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    scale = min(size[0] / image.width, size[1] / image.height)
    resized = image.resize(
        (
            max(1, round(image.width * scale)),
            max(1, round(image.height * scale)),
        ),
        Image.Resampling.LANCZOS,
    )
    result = Image.new("RGBA", size, (0, 0, 0, 0))
    result.alpha_composite(
        resized,
        ((size[0] - resized.width) // 2, (size[1] - resized.height) // 2),
    )
    return clear_transparent_rgb(result)


def make_compass_source(raw: Image.Image) -> Image.Image:
    keyed, key_mask = key_image(raw, threshold=38, border=12)
    source_centre = connected_key_centre(
        raw,
        key_mask,
        (raw.width // 2, int(raw.height * 0.43)),
    )
    bbox = alpha_bbox(keyed)
    target_size = SOURCE["compass"]["size"]
    target_centre = (110.0, 110.0)
    margins = [
        (target_centre[0] - 2) / (source_centre[0] - bbox[0]),
        (target_size[0] - 2 - target_centre[0])
        / (bbox[2] - source_centre[0]),
        (target_centre[1] - 2) / (source_centre[1] - bbox[1]),
        (target_size[1] - 2 - target_centre[1])
        / (bbox[3] - source_centre[1]),
    ]
    scale = min(margins)
    resized = keyed.resize(
        (round(raw.width * scale), round(raw.height * scale)),
        Image.Resampling.LANCZOS,
    )
    mapped_centre = (source_centre[0] * scale, source_centre[1] * scale)
    offset = (
        round(target_centre[0] - mapped_centre[0]),
        round(target_centre[1] - mapped_centre[1]),
    )
    result = Image.new("RGBA", target_size, (0, 0, 0, 0))
    result.alpha_composite(resized, offset)

    rgba = np.asarray(result, dtype=np.uint8).copy()
    yy, xx = np.mgrid[0 : target_size[1], 0 : target_size[0]]
    distance = np.sqrt(
        (xx + 0.5 - target_centre[0]) ** 2
        + (yy + 0.5 - target_centre[1]) ** 2
    )
    protected = distance <= 70.0
    rgba[protected] = 0
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def key_crop(
    source: Image.Image,
    box: tuple[int, int, int, int],
) -> Image.Image:
    crop = source.crop(box).convert("RGBA")
    keyed, _ = key_image(crop, threshold=42, border=8)
    left, top, right, bottom = alpha_bbox(keyed)
    pad = 3
    return clear_transparent_rgb(
        keyed.crop(
            (
                max(0, left - pad),
                max(0, top - pad),
                min(keyed.width, right + pad),
                min(keyed.height, bottom + pad),
            )
        )
    )


def make_hardware_sources(raw: Image.Image) -> dict[str, Image.Image]:
    width, height = raw.size
    regions = {
        "latch": (
            int(width * 0.15),
            int(height * 0.12),
            int(width * 0.84),
            int(height * 0.52),
        ),
        "glyph": (0, int(height * 0.50), int(width * 0.31), int(height * 0.94)),
        "connector": (
            int(width * 0.28),
            int(height * 0.57),
            int(width * 0.69),
            int(height * 0.91),
        ),
        "socket": (
            int(width * 0.68),
            int(height * 0.55),
            width,
            int(height * 0.94),
        ),
    }
    return {
        key: fit(key_crop(raw, box), SOURCE[key]["size"])
        for key, box in regions.items()
    }


def make_tray_source(raw: Image.Image) -> Image.Image:
    keyed, _ = key_image(raw, threshold=42, border=10)
    return fit(keyed.crop(alpha_bbox(keyed)), SOURCE["tray"]["size"])


def promote(args: argparse.Namespace) -> None:
    paths = {"a": args.promote_a, "b": args.promote_b, "c": args.promote_c}
    supplied = [path is not None for path in paths.values()]
    if any(supplied) and not all(supplied):
        raise ValueError("promotion requires all A/B/C accepted exact-pixels inputs")
    if not all(supplied):
        return

    raw_a = validate_raw(paths["a"], "a")
    raw_b = validate_raw(paths["b"], "b")
    raw_c = validate_raw(paths["c"], "c")
    sources = {
        "compass": make_compass_source(raw_a),
        **make_hardware_sources(raw_b),
        "tray": make_tray_source(raw_c),
    }
    for key, image in sources.items():
        image = clear_chroma_spill(image)
        if image.size != SOURCE[key]["size"]:
            raise ValueError(f"promoted source size mismatch: {key} {image.size}")
        save_png(image, SOURCE_DIR / SOURCE[key]["filename"])


def load_sources() -> dict[str, Image.Image]:
    result: dict[str, Image.Image] = {}
    for key, contract in SOURCE.items():
        path = SOURCE_DIR / contract["filename"]
        if not path.is_file():
            raise ValueError(f"accepted source is missing: {path}")
        expected = SOURCE_EXPECTED_SHA256[key]
        if expected and sha256(path) != expected:
            raise ValueError(f"accepted source hash drifted: {path}")
        with Image.open(path) as opened:
            image = clear_transparent_rgb(opened)
        if image.size != contract["size"]:
            raise ValueError(f"accepted source size drifted: {key} {image.size}")
        if transparent_rgb_nonzero(image):
            raise ValueError(f"accepted source transparent RGB drifted: {key}")
        result[key] = image
    return result


def make_round_mask() -> Image.Image:
    factor = 4
    size = 512
    high = Image.new("L", (size * factor, size * factor), 0)
    ImageDraw.Draw(high).ellipse(
        (factor, factor, size * factor - factor - 1, size * factor - factor - 1),
        fill=255,
    )
    alpha = high.resize((size, size), Image.Resampling.LANCZOS)
    alpha_array = np.asarray(alpha, dtype=np.uint8).copy()
    yy, xx = np.ogrid[:size, :size]
    centre = (size - 1) / 2
    radius = np.sqrt((xx - centre) ** 2 + (yy - centre) ** 2)
    alpha_array[radius >= centre - 0.5] = 0
    rgba = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    rgba.putalpha(Image.fromarray(alpha_array, "L"))
    return clear_transparent_rgb(rgba)


def state_variants(normal: Image.Image) -> dict[str, Image.Image]:
    hover = ImageEnhance.Color(
        ImageEnhance.Brightness(normal).enhance(1.08)
    ).enhance(1.04)
    pressed = Image.new("RGBA", normal.size, (0, 0, 0, 0))
    pressed.alpha_composite(ImageEnhance.Brightness(normal).enhance(0.84), (0, 1))
    return {
        "normal": clear_transparent_rgb(normal),
        "hover": clear_transparent_rgb(hover),
        "pressed": clear_transparent_rgb(pressed),
    }


def rotate_for_attachment(image: Image.Image, direction: str) -> Image.Image:
    if direction == "bottom":
        return image.copy()
    if direction == "top":
        return image.transpose(Image.Transpose.ROTATE_180)
    if direction == "left":
        return image.transpose(Image.Transpose.ROTATE_270)
    if direction == "right":
        return image.transpose(Image.Transpose.ROTATE_90)
    raise ValueError(f"unknown attachment direction: {direction}")


def glyph_direction(image: Image.Image, direction: str) -> Image.Image:
    if direction == "up":
        return image.copy()
    if direction == "down":
        return image.transpose(Image.Transpose.ROTATE_180)
    if direction == "left":
        return image.transpose(Image.Transpose.ROTATE_90)
    if direction == "right":
        return image.transpose(Image.Transpose.ROTATE_270)
    raise ValueError(f"unknown glyph direction: {direction}")


def runtime_images(sources: dict[str, Image.Image]) -> dict[str, tuple[str, Image.Image]]:
    result: dict[str, tuple[str, Image.Image]] = {
        "compass": ("MapMiniCompassCradleV3.tga", sources["compass"]),
        "mask": ("MapMiniMaskV3.tga", make_round_mask()),
        "socket": ("MapMiniStatusSocketV3.tga", sources["socket"]),
    }
    for state, image in state_variants(sources["latch"]).items():
        for direction in DIRECTIONS:
            key = f"latch_{direction}_{state}"
            filename = (
                f"MapMiniAddonLatch{direction.title()}{state.title()}V3.tga"
            )
            result[key] = (filename, rotate_for_attachment(image, direction))
    for direction in ("up", "down", "left", "right"):
        result[f"glyph_{direction}"] = (
            f"MapMiniAddonGlyph{direction.title()}V3.tga",
            glyph_direction(sources["glyph"], direction),
        )
    for direction in DIRECTIONS:
        result[f"connector_{direction}"] = (
            f"MapMiniAddonConnector{direction.title()}V3.tga",
            rotate_for_attachment(sources["connector"], direction),
        )
        result[f"tray_{direction}"] = (
            f"MapMiniAddonTray{direction.title()}V3.tga",
            rotate_for_attachment(sources["tray"], direction),
        )
    return result


def validate_geometry(
    sources: dict[str, Image.Image],
    runtimes: dict[str, tuple[str, Image.Image]],
) -> None:
    compass_alpha = np.asarray(sources["compass"].getchannel("A"), dtype=np.uint8)
    yy, xx = np.ogrid[:264, :220]
    radius = np.sqrt((xx + 0.5 - 110.0) ** 2 + (yy + 0.5 - 110.0) ** 2)
    if int(np.count_nonzero(compass_alpha[radius <= 69.0])) != 0:
        raise ValueError("compass material enters the protected 140x140 map window")

    mask_alpha = np.asarray(runtimes["mask"][1].getchannel("A"), dtype=np.uint8)
    mask_size = mask_alpha.shape[0]
    if any(
        int(mask_alpha[y, x]) != 0
        for x, y in (
            (0, 0),
            (mask_size - 1, 0),
            (0, mask_size - 1),
            (mask_size - 1, mask_size - 1),
        )
    ) or int(mask_alpha[mask_size // 2, mask_size // 2]) != 255:
        raise ValueError("round mask does not have transparent corners and opaque centre")
    my, mx = np.ogrid[:mask_size, :mask_size]
    mask_centre = (mask_size - 1) / 2
    mask_radius = np.sqrt((mx - mask_centre) ** 2 + (my - mask_centre) ** 2)
    if int(np.count_nonzero(mask_alpha[mask_radius >= mask_centre - 0.5])) != 0:
        raise ValueError("round mask leaks outside the circular provider boundary")

    socket_alpha = np.asarray(sources["socket"].getchannel("A"), dtype=np.uint8)
    if int(socket_alpha[9:15, 9:15].max()) > 8:
        raise ValueError("status socket blocks the protected provider icon centre")

    for key, (_, image) in runtimes.items():
        if transparent_rgb_nonzero(image):
            raise ValueError(f"runtime transparent RGB is not clear: {key}")


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
    definitions: dict[str, tuple[str, Image.Image]],
) -> dict[str, Image.Image]:
    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    result: dict[str, Image.Image] = {}
    for key, (filename, raw_logical) in definitions.items():
        logical = clear_transparent_rgb(raw_logical)
        texture = pad_to_power_of_two(logical)
        path = RUNTIME_DIR / filename
        texture.save(path, format="TGA")
        with Image.open(path) as opened:
            roundtrip = opened.convert("RGBA")
        if ImageChops.difference(texture, roundtrip).getbbox() is not None:
            raise ValueError(f"TGA roundtrip changed pixels: {path}")
        logical_roundtrip = roundtrip.crop((0, 0, *logical.size))
        if ImageChops.difference(logical, logical_roundtrip).getbbox() is not None:
            raise ValueError(f"TGA container changed logical pixels: {path}")
        header = tga_header(path)
        if (
            header["image_type"] != 2
            or header["bits_per_pixel"] != 32
            or (header["width"], header["height"])
            != power_of_two_size(logical.size)
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


def component_for_runtime(key: str) -> str:
    if key == "compass":
        return "MAP.MINI.COMPASS.INFO.V3"
    if key == "mask":
        return "MAP.MINI.MASK.V3"
    if key == "socket":
        return "MAP.MINI.STATUS.SOCKET.V3"
    if key.startswith("latch_"):
        return "MAP.MINI.ADDONS.TOGGLE.LATCH.V3." + key[6:].upper()
    if key.startswith("glyph_"):
        return "MAP.MINI.ADDONS.TOGGLE.GLYPH.V3." + key[6:].upper()
    if key.startswith("connector_"):
        return "MAP.MINI.ADDONS.CONNECTOR.V3." + key[10:].upper()
    if key.startswith("tray_"):
        return "MAP.MINI.ADDONS.TRAY.V3." + key[5:].upper()
    raise ValueError(f"missing runtime component mapping: {key}")


def write_manifests(
    sources: dict[str, Image.Image],
    definitions: dict[str, tuple[str, Image.Image]],
    runtimes: dict[str, Image.Image],
) -> None:
    source_components = {
        key: {
            "component": SOURCE[key]["component"],
            **media_record(SOURCE_DIR / SOURCE[key]["filename"], image),
        }
        for key, image in sources.items()
    }
    source_manifest = {
        "schema": "aeui-map-mini-v3-source-manifest-v1",
        "schema_version": 1,
        "module": "map",
        "batch": "MAP-MINI-V3",
        "status": "runtime-exported",
        "phase": "P5",
        "accepted_on": "2026-08-18",
        "user_acceptance": {
            "exact_statement": (
                "接受 MAP-MINI-V3-A attempt 2、B attempt 1、C attempt 4 的 exact pixels；"
                "允许按既定合同执行确定性色键、透明 RGB 清零、bbox-fit、固定拆分、"
                "状态派生、九切片及四向派生，并提升 source/runtime、导出正式媒体和接入 addon。"
            ),
            "p4_p5_and_integration_authorized": True,
        },
        "provenance": {
            "executor": "imagegen-0-143-0",
            "provider_raw": {
                key: {
                    "sha256": value["sha256"],
                    "size": list(value["size"]),
                    "attempt": value["attempt"],
                    "calls": value["calls"],
                }
                for key, value in RAW_ACCEPTED.items()
            },
            "maximum_imagegen_calls_per_segment": 5,
            "flow_errors_counted_as_imagegen_calls": False,
            "prompt": "docs/modules/map/SUBMODULE_ART_BASELINES.md",
            "global_prompt": "docs/GLOBAL_ART_BASELINE.md",
            "module_prompt": "docs/modules/map/ART_BASELINE.md",
            "architecture_reference": {
                "file": "assets/locked/map/MapMiniV3_ArchitectureLock_v1.png",
                "sha256": "34fabc744b063ab4b2146ac2759bf440695516528ad05839cd7120b38c7bf04a",
            },
            "compass_reference_sha256": (
                "9e6a38dbaa2e7df82480c4fe8ca32ca2c931fa016a8264f26964903468ac2ea6"
            ),
            "roughness_reference_sha256": (
                "a97d9c5fa055a119cd5ea7809bdaa51460cddb9674355efcec35f98f6cd2c673"
            ),
        },
        "components": source_components,
        "deterministic_transform": {
            "a": (
                "global chroma-key cleanup; hole-centred aspect-preserving 220x264 fit; "
                "hard radius-70 alpha exclusion"
            ),
            "b": (
                "fixed four-region split; chroma-key cleanup; independent aspect-preserving "
                "38x24, 10x12, 32x14 and 24x24 bbox-fit"
            ),
            "c": "chroma-key cleanup; visible bbox; aspect-preserving 270x74 fit",
            "states": "latch hover brightness/color and pressed 1px displacement only",
            "directions": "lossless 90/180/270-degree rotations only",
            "transparent_rgb_cleared": True,
            "generative_postprocess": False,
        },
        "density_contract": {
            "functional_mask": "deterministically rebuilt at 512x512",
            "explicit_1x_exception": [
                "compass",
                "latch",
                "glyph",
                "connector",
                "socket",
                "tray",
            ],
            "reason": (
                "the accepted normalized V3 art sources exist only at their "
                "logical 1x sizes; the original accepted provider raws were "
                "not retained, and upscaling those 1x sources is forbidden"
            ),
        },
        "runtime_manifest": repository_path(RUNTIME_MANIFEST),
    }
    SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    SOURCE_MANIFEST.write_text(
        json.dumps(source_manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    runtime_components: dict[str, Any] = {}
    for key, (filename, logical_definition) in definitions.items():
        path = RUNTIME_DIR / filename
        logical_size = logical_definition.size
        runtime_components[key] = {
            "component": component_for_runtime(key),
            **media_record(path, runtimes[key]),
            "logical_size": list(logical_size),
            "texture_size": list(power_of_two_size(logical_size)),
            "content_uv": content_uv(logical_size),
            "tga_header": tga_header(path),
            "texels_per_ui": (
                "functional-mask-512" if key == "mask" else 1
            ),
        }
    runtime_manifest = {
        "schema": "aeui-map-mini-v3-runtime-manifest-v1",
        "schema_version": 1,
        "module": "map",
        "batch": "MAP-MINI-V3",
        "status": "runtime-exported",
        "phase": "P5",
        "runtime_contract": "3.1",
        "source_manifest": repository_path(SOURCE_MANIFEST),
        "runtime": runtime_components,
        "layout_contract": {
            "provider": "pfUI.minimap and Minimap",
            "reference_content_ui": [140, 140],
            "reference_shell_ui": [220, 264],
            "map_hole_centre_ui": [110, 110],
            "map_hole_diameter_ui": 140,
            "provider_mask_texture": "MapMiniMaskV3.tga",
            "provider_mask_is_independent_of_shell": True,
            "map_tiles_player_arrow_pfquest_pins_share_masked_provider": True,
            "map_content_can_cross_compass_inner_edge": False,
            "zone_safe_region_ui": [42, 216, 178, 238],
            "coordinates_safe_region_ui": [60, 239, 160, 254],
            "status_socket_positions_ui": {
                "tracking": [12, 25],
                "mail": [184, 25],
                "battlefield": [184, 168],
                "pvp": [12, 168],
            },
            "tray_nine_slice_pixels_bottom": {
                "x": [0, 18, 258, 270],
                "y": [0, 10, 64, 74],
            },
            "addon_positions": list(DIRECTIONS),
            "addon_counts_reviewed": [0, 6, 30],
            "zero_addons_hide_toggle_connector_and_tray": True,
            "plugin_icons_states_clicks_tooltips_cooldowns_notifications_remain_provider_owned": True,
            "zone_and_coordinates_are_runtime_text_outside_map": True,
            "farmmode_shell_reuse": False,
            "world_map_integration_remains_paused": True,
            "vanilla_power_of_two_texture_containers": True,
        },
    }
    RUNTIME_MANIFEST.write_text(
        json.dumps(runtime_manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def main() -> int:
    args = parse_args()
    promote(args)
    sources = load_sources()
    definitions = runtime_images(sources)
    validate_geometry(sources, definitions)
    runtimes = export_runtime(definitions)
    write_manifests(sources, definitions, runtimes)
    print(
        json.dumps(
            {
                "status": "pass",
                "source_manifest": repository_path(SOURCE_MANIFEST),
                "runtime_manifest": repository_path(RUNTIME_MANIFEST),
                "source_files": len(SOURCE),
                "runtime_files": len(definitions),
                "round_mask": True,
                "provider_icons_baked": False,
            },
            ensure_ascii=False,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
