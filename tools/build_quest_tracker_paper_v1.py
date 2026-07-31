#!/usr/bin/env python3
"""Export the temporary accepted tracker paper as one nine-slice runtime atlas."""

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
    / "qt-a1"
    / "QuestTrackerPaperShell_Temporary_v1.png"
)
SOURCE_MANIFEST = SOURCE.with_name("QT-A1_SourceManifest_v1.json")
RUNTIME_MANIFEST = SOURCE.with_name("QT-A1_RuntimeManifest_v1.json")
RUNTIME = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestTrackerPaperV1.tga"
)
PREVIEW = (
    ROOT
    / "generated"
    / "quests"
    / "QT"
    / "QT-A1"
    / "temporary-runtime"
    / "QuestTrackerPaperV1.atlas.png"
)

EXPECTED_SOURCE_SHA256 = (
    "a9d700cd01f26535ae2035bfa3d8c2cedd7337bfb47d3fa9494ba592d259c59b"
)
EXPECTED_SOURCE_SIZE = (1024, 1536)
EXPECTED_VISIBLE_BBOX = (261, 82, 771, 1454)
RAW_ATTEMPT_SHA256 = (
    "13aefd716b129fd2f6b629147b77c0033b8c9db6e3f3c1d71c2a96d7dd347474"
)
ATLAS_SIZE = (256, 512)
CONTENT_SIZE = (190, 512)
CONTENT_BOX = (0, 0, CONTENT_SIZE[0], CONTENT_SIZE[1])
X_CUTS = (0, 24, 166, 190)
Y_CUTS = (0, 32, 456, 512)
DISPLAY_CAPS = {
    "left": 14,
    "right": 14,
    "top": 12,
    "bottom": 16,
}
RESAMPLE = Image.Resampling.LANCZOS


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def display_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def alpha_evidence(image: Image.Image) -> dict[str, int]:
    histogram = image.getchannel("A").histogram()
    return {
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
    }


def visible_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    return image.getchannel("A").getbbox()


def green_spill_pixels(image: Image.Image) -> int:
    rgba = image.convert("RGBA")
    pixels = (
        rgba.get_flattened_data()
        if hasattr(rgba, "get_flattened_data")
        else rgba.getdata()
    )
    return sum(
        1
        for red, green, blue, alpha in pixels
        if alpha > 0 and red <= 32 and green >= 224 and blue <= 32
    )


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    red, green, blue, alpha = image.convert("RGBA").split()
    visible = alpha.point(lambda value: 255 if value else 0)
    zero = Image.new("L", image.size, 0)
    return Image.merge(
        "RGBA",
        (
            Image.composite(red, zero, visible),
            Image.composite(green, zero, visible),
            Image.composite(blue, zero, visible),
            alpha,
        ),
    )


def remove_resample_green_spill(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = (
        list(rgba.get_flattened_data())
        if hasattr(rgba, "get_flattened_data")
        else list(rgba.getdata())
    )
    cleaned = [
        (0, 0, 0, 0)
        if alpha > 0 and red <= 32 and green >= 224 and blue <= 32
        else (red, green, blue, alpha)
        for red, green, blue, alpha in pixels
    ]
    rgba.putdata(cleaned)
    return clear_transparent_rgb(rgba)


def validate_source(path: Path, image: Image.Image) -> None:
    if sha256(path) != EXPECTED_SOURCE_SHA256:
        raise ValueError("QT-A1 source SHA-256 does not match the accepted temporary asset")
    if image.size != EXPECTED_SOURCE_SIZE:
        raise ValueError(
            f"QT-A1 source must be {EXPECTED_SOURCE_SIZE}, got {image.size}"
        )
    if image.mode != "RGBA":
        raise ValueError(f"QT-A1 source must be RGBA, got {image.mode}")
    if visible_bbox(image) != EXPECTED_VISIBLE_BBOX:
        raise ValueError(
            "QT-A1 source visible bbox does not match the reviewed deterministic key"
        )
    if green_spill_pixels(image):
        raise ValueError("QT-A1 source contains visible chroma-key green")


def build_runtime(source: Image.Image) -> tuple[Image.Image, Image.Image]:
    cropped = clear_transparent_rgb(source.crop(EXPECTED_VISIBLE_BBOX))
    scaled = remove_resample_green_spill(
        cropped.resize(CONTENT_SIZE, RESAMPLE)
    )
    atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
    atlas.alpha_composite(scaled, (0, 0))
    return scaled, clear_transparent_rgb(atlas)


def slice_contract() -> dict[str, dict[str, object]]:
    names = (
        ("top_left", 0, 0),
        ("top", 1, 0),
        ("top_right", 2, 0),
        ("left", 0, 1),
        ("center", 1, 1),
        ("right", 2, 1),
        ("bottom_left", 0, 2),
        ("bottom", 1, 2),
        ("bottom_right", 2, 2),
    )
    slices: dict[str, dict[str, object]] = {}
    for name, column, row in names:
        box = (
            X_CUTS[column],
            Y_CUTS[row],
            X_CUTS[column + 1],
            Y_CUTS[row + 1],
        )
        slices[name] = {
            "atlas_box_xyxy": list(box),
            "texcoord": {
                "left": box[0] / ATLAS_SIZE[0],
                "right": box[2] / ATLAS_SIZE[0],
                "top": box[1] / ATLAS_SIZE[1],
                "bottom": box[3] / ATLAS_SIZE[1],
            },
        }
    return slices


def tga_descriptor(path: Path) -> int:
    data = path.read_bytes()
    if len(data) < 18:
        raise ValueError("runtime TGA is shorter than its header")
    return data[17]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--source-manifest", type=Path, default=SOURCE_MANIFEST)
    parser.add_argument("--runtime", type=Path, default=RUNTIME)
    parser.add_argument("--runtime-manifest", type=Path, default=RUNTIME_MANIFEST)
    parser.add_argument("--preview", type=Path, default=PREVIEW)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    with Image.open(args.source) as opened:
        source = opened.copy()
    validate_source(args.source, source)
    scaled, atlas = build_runtime(source)

    args.preview.parent.mkdir(parents=True, exist_ok=True)
    scaled.save(args.preview, format="PNG", optimize=True)
    args.runtime.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(args.runtime, format="TGA")

    source_manifest = {
        "schema_version": 1,
        "batch": "QT-A1",
        "version": "V1-temporary",
        "status": "user-accepted-temporary-contract-exception",
        "source": {
            "file": display_path(args.source),
            "sha256": sha256(args.source),
            "width": source.width,
            "height": source.height,
            "mode": source.mode,
            "visible_bbox_exclusive": list(EXPECTED_VISIBLE_BBOX),
            "visible_green_spill_pixels": green_spill_pixels(source),
            **alpha_evidence(source),
        },
        "provenance": {
            "fixed_executor": "@openai/codex@0.143.0",
            "fixed_child_session": "019fb641-556a-77b0-bd27-e05a629a9fea",
            "raw_attempt": (
                "generated/quests/QT/QT-A1/V1/attempt-04/"
                "qt-a1-field-note-shell-v1.png"
            ),
            "raw_attempt_sha256": RAW_ATTEMPT_SHA256,
            "deterministic_derivation": (
                "review_quest_tracker_candidate_v1.py chroma-key output; "
                "no redraw, crop, scale, or retouch in the tracked source"
            ),
            "decision": (
                "2026-07-31 user paused QT-B1 focus/tracked/complete art and "
                "directed the overhaul to use the large tracker background"
            ),
            "exception": (
                "raw native-green and original bbox gates remain failed; the "
                "accepted temporary source is the reviewed deterministic RGBA key"
            ),
        },
        "dynamic_exclusions": [
            "all quest titles, objectives, levels, percentages and node icons",
            "all hover, tracked and complete overlays from deferred QT-B1",
            "all toolbar Button art from deferred QT-A2",
            "all provider scripts, click regions, tooltips and SavedVariables",
        ],
        "game_validated": False,
    }
    args.source_manifest.parent.mkdir(parents=True, exist_ok=True)
    args.source_manifest.write_text(
        json.dumps(source_manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    descriptor = tga_descriptor(args.runtime)
    runtime_manifest = {
        "schema_version": 1,
        "batch": "QT-A1",
        "version": "V1-temporary",
        "runtime_contract": "1.0",
        "status": "runtime-exported-temporary",
        "source": source_manifest["source"],
        "transform": {
            "operation": (
                "crop reviewed Alpha bbox, aspect-preserving resize to 190x512, "
                "remove two resampling-only bright-green edge pixels, then "
                "transparent right padding into 256x512 atlas"
            ),
            "resample": "Pillow Image.Resampling.LANCZOS",
            "crop_xyxy": list(EXPECTED_VISIBLE_BBOX),
            "display_content_size": list(CONTENT_SIZE),
            "atlas_size": list(ATLAS_SIZE),
            "content_box_xyxy": list(CONTENT_BOX),
            "rotation": None,
            "mirror": False,
            "retouch": False,
        },
        "nine_slice": {
            "display_caps": DISPLAY_CAPS,
            "minimum_frame_size": [
                DISPLAY_CAPS["left"] + DISPLAY_CAPS["right"] + 1,
                DISPLAY_CAPS["top"] + DISPLAY_CAPS["bottom"] + 1,
            ],
            "slices": slice_contract(),
        },
        "preview": {
            "file": display_path(args.preview),
            "sha256": sha256(args.preview),
            "width": scaled.width,
            "height": scaled.height,
            "mode": scaled.mode,
            "visible_bbox_exclusive": list(visible_bbox(scaled) or ()),
            "visible_green_spill_pixels": green_spill_pixels(scaled),
            **alpha_evidence(scaled),
        },
        "runtime": {
            "file": display_path(args.runtime),
            "sha256": sha256(args.runtime),
            "width": atlas.width,
            "height": atlas.height,
            "mode": atlas.mode,
            "tga_descriptor": descriptor,
            "tga_top_origin": bool(descriptor & 0x20),
            "visible_bbox_exclusive": list(visible_bbox(atlas) or ()),
            "visible_green_spill_pixels": green_spill_pixels(atlas),
            **alpha_evidence(atlas),
        },
        "frame_contract": {
            "object": "pfQuestMapTracker",
            "provider_width": "dynamic 130..330 UI px",
            "provider_height": "dynamic panel plus entry content",
            "ownership": (
                "one non-interactive nine-slice paper background behind the "
                "provider's live toolbar, entries and text"
            ),
            "row_overlays": "none; QT-B1 is scope-deferred",
            "toolbar_art": "provider fallback; QT-A2 is scope-deferred",
            "display_region_conformance": {
                "status": "display-region-blocked",
                "contract": (
                    "tools/specs/quest_tracker_display_region_v1.json"
                ),
                "first_failure": "FRAME_BELOW_NINE_SLICE_MINIMUM",
                "notes": [
                    (
                        "the provider empty height is 16px, below the declared "
                        "29px nine-slice minimum"
                    ),
                    (
                        "live outer toolbar icons, entry node icons, right text "
                        "edge, and final content intersect decorative caps"
                    ),
                    (
                        "trackerfontsize and per-quest objective count have no "
                        "frozen supported bounds"
                    ),
                ],
            },
        },
        "implementation": {
            "exporter": "tools/build_quest_tracker_paper_v1.py",
            "adapter": "addon/AzerothExpeditionUI/Modules/Quests.lua",
            "imagegen_calls": 0,
            "game_validated": False,
        },
    }
    args.runtime_manifest.write_text(
        json.dumps(runtime_manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(runtime_manifest, ensure_ascii=False))


if __name__ == "__main__":
    main()
