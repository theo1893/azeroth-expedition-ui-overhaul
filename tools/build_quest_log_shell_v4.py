#!/usr/bin/env python3
"""Export the accepted QL-A1 book as the fixed QL-A2 V4 runtime shell.

This builder is intentionally narrow: it validates the accepted source,
performs one aspect-preserving resize with integer-pixel rounding, pads the
result into a power-of-two atlas, writes TGA/PNG files, and records the exact
runtime contract. It never crops, mirrors, stretches, retouches, or redraws
the accepted artwork.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (
    ROOT
    / "assets"
    / "source"
    / "quests"
    / "ql-a1"
    / "QuestLogBookShell_Master_v1.png"
)
RUNTIME_LEFT = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestLogShellLeftV4.tga"
)
RUNTIME_RIGHT = RUNTIME_LEFT.with_name("QuestLogShellRightV4.tga")
LEGACY_RUNTIME = RUNTIME_LEFT.with_name("QuestLogShellV4.tga")
PREVIEW = (
    ROOT
    / "generated"
    / "quests"
    / "QL-A2"
    / "v4"
    / "previews"
    / "QL-A2_V4_SHELL_676x464.preview.png"
)
MANIFEST = SOURCE.with_name("QL-A1_RuntimeManifest_v1.json")
SOURCE_MANIFEST = SOURCE.with_name("QL-A1_SourceManifest_v1.json")

EXPECTED_SOURCE_SHA256 = (
    "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5"
)
EXPECTED_SOURCE_SIZE = (1514, 1039)
DISPLAY_SIZE = (676, 464)
SAMPLED_SIZE = (1352, 928)
TILE_LOGICAL_SIZE = (338, 464)
TILE_SAMPLED_SIZE = (676, 928)
ATLAS_SIZE = (1024, 1024)
TEXELS_PER_UI = 2
CONTENT_BOX = (0, 0, TILE_SAMPLED_SIZE[0], TILE_SAMPLED_SIZE[1])
TEXCOORD = {
    "left": 0.0,
    "right": TILE_SAMPLED_SIZE[0] / ATLAS_SIZE[0],
    "top": 0.0,
    "bottom": TILE_SAMPLED_SIZE[1] / ATLAS_SIZE[1],
}
SAFE_AREAS = {
    "list": [64, 64, 310, 388],
    "detail": [366, 64, 612, 388],
    "gutter": [318, 40, 358, 412],
}
RESAMPLE = Image.Resampling.LANCZOS


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


def alpha_evidence(image: Image.Image) -> dict[str, int]:
    histogram = image.getchannel("A").histogram()
    return {
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
    }


def green_spill_pixels(image: Image.Image) -> int:
    count = 0
    pixels = (
        image.get_flattened_data()
        if hasattr(image, "get_flattened_data")
        else image.getdata()
    )
    for red, green, blue, alpha in pixels:
        if alpha > 0 and red <= 32 and green >= 224 and blue <= 32:
            count += 1
    return count


def clear_resampling_green_spill(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            red, green, blue, alpha = pixels[x, y]
            if alpha > 0 and red <= 32 and green >= 224 and blue <= 32:
                pixels[x, y] = (0, 0, 0, 0)
    return rgba


def visible_bbox(image: Image.Image) -> list[int] | None:
    bounds = image.getchannel("A").getbbox()
    return list(bounds) if bounds else None


def validate_source(path: Path, image: Image.Image) -> None:
    if sha256(path) != EXPECTED_SOURCE_SHA256:
        raise ValueError("QL-A1 source SHA-256 does not match the accepted asset")
    if image.size != EXPECTED_SOURCE_SIZE:
        raise ValueError(
            f"QL-A1 source must be {EXPECTED_SOURCE_SIZE}, got {image.size}"
        )
    if image.mode != "RGBA":
        raise ValueError(f"QL-A1 source must be RGBA, got {image.mode}")
    alpha_minimum, alpha_maximum = image.getchannel("A").getextrema()
    if (alpha_minimum, alpha_maximum) != (0, 255):
        raise ValueError("QL-A1 source must contain transparent and opaque pixels")
    if green_spill_pixels(image):
        raise ValueError("QL-A1 source contains visible chroma-key green")


def build_runtime(
    source: Image.Image,
) -> tuple[Image.Image, dict[str, Image.Image]]:
    scaled = clear_resampling_green_spill(
        source.resize(SAMPLED_SIZE, RESAMPLE)
    )
    tiles: dict[str, Image.Image] = {}
    for name, box in {
        "left": (0, 0, TILE_SAMPLED_SIZE[0], SAMPLED_SIZE[1]),
        "right": (
            TILE_SAMPLED_SIZE[0],
            0,
            SAMPLED_SIZE[0],
            SAMPLED_SIZE[1],
        ),
    }.items():
        atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
        atlas.alpha_composite(scaled.crop(box), (0, 0))
        tiles[name] = atlas
    return scaled, tiles


def save_png(image: Image.Image, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, format="PNG", optimize=True)


def save_tga(image: Image.Image, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, format="TGA")


def tga_descriptor(path: Path) -> int:
    data = path.read_bytes()
    if len(data) < 18:
        raise ValueError("runtime TGA is shorter than its header")
    return data[17]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--runtime-left", type=Path, default=RUNTIME_LEFT)
    parser.add_argument("--runtime-right", type=Path, default=RUNTIME_RIGHT)
    parser.add_argument("--preview", type=Path, default=PREVIEW)
    parser.add_argument("--manifest", type=Path, default=MANIFEST)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    with Image.open(args.source) as opened:
        source = opened.convert("RGBA")
    validate_source(args.source, source)

    scaled, tiles = build_runtime(source)
    save_png(scaled, args.preview)
    save_tga(tiles["left"], args.runtime_left)
    save_tga(tiles["right"], args.runtime_right)

    runtime_paths = {
        "left": args.runtime_left,
        "right": args.runtime_right,
    }
    runtime_descriptors = {
        name: tga_descriptor(path) for name, path in runtime_paths.items()
    }
    manifest = {
        "schema_version": 1,
        "batch": "QL-A2",
        "version": "V4",
        "runtime_contract": "1.1",
        "status": "runtime-exported",
        "source": {
            "file": display_path(args.source),
            "sha256": sha256(args.source),
            "width": source.width,
            "height": source.height,
            "mode": source.mode,
            **alpha_evidence(source),
        },
        "transform": {
            "operation": (
                "aspect-preserving 2x resize with integer-pixel rounding, "
                "vertical half split, then transparent top-left atlas padding"
            ),
            "resample": "Pillow Image.Resampling.LANCZOS",
            "crop": None,
            "rotation": None,
            "mirror": False,
            "retouch": False,
            "logical_display_size": list(DISPLAY_SIZE),
            "sampled_size": list(SAMPLED_SIZE),
            "tile_logical_size": list(TILE_LOGICAL_SIZE),
            "tile_sampled_size": list(TILE_SAMPLED_SIZE),
            "texels_per_ui": TEXELS_PER_UI,
            "atlas_size_per_tile": list(ATLAS_SIZE),
            "tile_content_box": list(CONTENT_BOX),
            "tile_texcoord": TEXCOORD,
        },
        "preview": {
            "file": display_path(args.preview),
            "sha256": sha256(args.preview),
            "width": scaled.width,
            "height": scaled.height,
            "mode": scaled.mode,
            "visible_bbox_exclusive": visible_bbox(scaled),
            "visible_green_spill_pixels": green_spill_pixels(scaled),
            **alpha_evidence(scaled),
        },
        "runtime": {
            "assembly": "two vertical half textures in one unchanged 676x464 UI box",
            "logical_size": list(DISPLAY_SIZE),
            "sampled_size": list(SAMPLED_SIZE),
            "texels_per_ui": TEXELS_PER_UI,
            "legacy_1x_file_retained_unmounted": display_path(LEGACY_RUNTIME),
            "tiles": {
                name: {
                    "file": display_path(runtime_paths[name]),
                    "sha256": sha256(runtime_paths[name]),
                    "logical_size": list(TILE_LOGICAL_SIZE),
                    "sampled_size": list(TILE_SAMPLED_SIZE),
                    "texture_size": list(ATLAS_SIZE),
                    "texcoord": TEXCOORD,
                    "tga_descriptor": runtime_descriptors[name],
                    "tga_top_origin": bool(runtime_descriptors[name] & 0x20),
                    "visible_bbox_exclusive": visible_bbox(tiles[name]),
                    "visible_green_spill_pixels": green_spill_pixels(tiles[name]),
                    **alpha_evidence(tiles[name]),
                }
                for name in ("left", "right")
            },
        },
        "frame_contract": {
            "object": "QuestLogFrame",
            "width": DISPLAY_SIZE[0],
            "height": DISPLAY_SIZE[1],
            "physical_center_x": DISPLAY_SIZE[0] // 2,
            "fixed_size": True,
            "stretch": False,
            "safe_areas_xyxy": SAFE_AREAS,
            "list_only": (
                "keep the full 676 x 464 shell visible and hide only "
                "right-page dynamic content"
            ),
        },
        "ownership": {
            "QUEST.LOG.SHELL": "two static 2x half textures with one logical shell",
            "QUEST.LOG.LIST.PAPER": "static SHELL subregion and layout safe area",
            "QUEST.LOG.DETAIL.PAPER": (
                "static SHELL subregion and layout safe area"
            ),
            "QUEST.LOG.GUTTER.UNDERLAY": "static SHELL subregion",
            "QUEST.LOG.GUTTER.LEFT_FOLD": "static SHELL subregion",
            "QUEST.LOG.GUTTER.RIGHT_FOLD": "static SHELL subregion",
            "QUEST.LOG.GUTTER.STITCH": "static SHELL subregion; no repetition",
            "QUEST.LOG.GUTTER.TOP": "no independent asset",
            "QUEST.LOG.GUTTER.BOTTOM": "no independent asset",
        },
        "dynamic_exclusions": [
            "quest title, count, rows, levels, tags, selection and tracking",
            "quest description, objectives, rewards, item icons and quantities",
            "close, collapse, expand, scrollbar and action button states",
            "all runtime text, tooltips, click regions, events and SavedVariables",
        ],
        "implementation": {
            "exporter": "tools/build_quest_log_shell_v4.py",
            "adapter": "addon/AzerothExpeditionUI/Modules/Quests.lua",
            "imagegen_calls": 0,
            "game_validated": False,
        },
    }
    args.manifest.parent.mkdir(parents=True, exist_ok=True)
    args.manifest.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    source_manifest = json.loads(SOURCE_MANIFEST.read_text(encoding="utf-8"))
    source_manifest["crop_contract"].update(
        {
            "reason": (
                "QL-A2 V4 displays one unchanged 676x464 shell from two "
                "338x464 logical half textures sampled at two texels per UI "
                "unit. No crop, redraw, stretch, mirror, or independent "
                "gutter extraction is allowed."
            ),
            "display_size": list(DISPLAY_SIZE),
            "sampled_size": list(SAMPLED_SIZE),
            "tile_logical_size": list(TILE_LOGICAL_SIZE),
            "tile_sampled_size": list(TILE_SAMPLED_SIZE),
            "atlas_size_per_tile": list(ATLAS_SIZE),
            "atlas_content_box": list(CONTENT_BOX),
            "texels_per_ui": TEXELS_PER_UI,
            "texcoord": [
                TEXCOORD["left"],
                TEXCOORD["right"],
                TEXCOORD["top"],
                TEXCOORD["bottom"],
            ],
            "planned_outputs": [
                display_path(RUNTIME_LEFT),
                display_path(RUNTIME_RIGHT),
                display_path(MANIFEST),
            ],
        }
    )
    source_manifest["runtime_exports"] = [
        {
            "contract": "QL-A2 V4 / 1.1 / 2x",
            "manifest": MANIFEST.name,
            "assembly": "left and right vertical half textures",
            "logical_size": list(DISPLAY_SIZE),
            "sampled_size": list(SAMPLED_SIZE),
            "texels_per_ui": TEXELS_PER_UI,
            "tiles": [
                {
                    "file": display_path(runtime_paths[name]),
                    "sha256": sha256(runtime_paths[name]),
                    "logical_size": list(TILE_LOGICAL_SIZE),
                    "sampled_size": list(TILE_SAMPLED_SIZE),
                    "atlas_size": list(ATLAS_SIZE),
                }
                for name in ("left", "right")
            ],
        }
    ]
    SOURCE_MANIFEST.write_text(
        json.dumps(source_manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(manifest, ensure_ascii=False))


if __name__ == "__main__":
    main()
