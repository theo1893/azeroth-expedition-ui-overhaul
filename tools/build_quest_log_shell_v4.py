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
RUNTIME = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestLogShellV4.tga"
)
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

EXPECTED_SOURCE_SHA256 = (
    "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5"
)
EXPECTED_SOURCE_SIZE = (1514, 1039)
DISPLAY_SIZE = (676, 464)
ATLAS_SIZE = (1024, 512)
CONTENT_BOX = (0, 0, DISPLAY_SIZE[0], DISPLAY_SIZE[1])
TEXCOORD = {
    "left": 0.0,
    "right": DISPLAY_SIZE[0] / ATLAS_SIZE[0],
    "top": 0.0,
    "bottom": DISPLAY_SIZE[1] / ATLAS_SIZE[1],
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


def build_runtime(source: Image.Image) -> tuple[Image.Image, Image.Image]:
    scaled = source.resize(DISPLAY_SIZE, RESAMPLE)
    atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
    atlas.alpha_composite(scaled, (0, 0))
    return scaled, atlas


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
    parser.add_argument("--runtime", type=Path, default=RUNTIME)
    parser.add_argument("--preview", type=Path, default=PREVIEW)
    parser.add_argument("--manifest", type=Path, default=MANIFEST)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    with Image.open(args.source) as opened:
        source = opened.convert("RGBA")
    validate_source(args.source, source)

    scaled, atlas = build_runtime(source)
    save_png(scaled, args.preview)
    save_tga(atlas, args.runtime)

    runtime_descriptor = tga_descriptor(args.runtime)
    manifest = {
        "schema_version": 1,
        "batch": "QL-A2",
        "version": "V4",
        "runtime_contract": "1.0",
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
                "aspect-preserving resize with integer-pixel rounding, "
                "then transparent top-left atlas padding"
            ),
            "resample": "Pillow Image.Resampling.LANCZOS",
            "crop": None,
            "rotation": None,
            "mirror": False,
            "retouch": False,
            "display_size": list(DISPLAY_SIZE),
            "atlas_size": list(ATLAS_SIZE),
            "content_box": list(CONTENT_BOX),
            "texcoord": TEXCOORD,
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
            "file": display_path(args.runtime),
            "sha256": sha256(args.runtime),
            "width": atlas.width,
            "height": atlas.height,
            "mode": atlas.mode,
            "tga_descriptor": runtime_descriptor,
            "tga_top_origin": bool(runtime_descriptor & 0x20),
            "visible_bbox_exclusive": visible_bbox(atlas),
            "visible_green_spill_pixels": green_spill_pixels(atlas),
            **alpha_evidence(atlas),
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
            "QUEST.LOG.SHELL": "single static runtime texture",
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
    print(json.dumps(manifest, ensure_ascii=False))


if __name__ == "__main__":
    main()
