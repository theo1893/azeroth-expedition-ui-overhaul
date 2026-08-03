#!/usr/bin/env python3
"""Promote and export the accepted dark Chat frame and input strip.

The accepted frame is exported through the established V3 nine-slice geometry.
The accepted single-state input strip is packed into the existing two-state
atlas contract; focus is a deterministic warm lift of the same source pixels.
The stable V3 tabs, shelf and unread seal remain untouched and are referenced
by hash in the runtime manifest.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw

import build_chat_v3_runtime_assets as v3


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets" / "source" / "chat" / "dark-v1"
V3_SOURCE_DIR = ROOT / "assets" / "source" / "chat" / "v3"
RUNTIME_DIR = ROOT / "addon" / "AzerothExpeditionUI" / "Media" / "Chat"
GENERATED_DIR = ROOT / "generated" / "chat" / "dark-v1"

FRAME_CANDIDATE = (
    ROOT
    / "generated"
    / "chat"
    / "core"
    / "CHAT.FRAME.FULL.V1"
    / "attempt-02"
    / "review"
    / "ChatBookFrame_Full_V1_r1_attempt02.transparent.png"
)
INPUT_CANDIDATE = (
    ROOT
    / "generated"
    / "chat_pfui_hq"
    / "imagegen_v4"
    / "candidate"
    / "ChatInputStrip.tga"
)

FRAME_SOURCE = SOURCE_DIR / "ChatBookFrame_Dark_Master_v1.png"
INPUT_SOURCE = SOURCE_DIR / "ChatInputStrip_Dark_Master_v1.png"
SOURCE_MANIFEST = SOURCE_DIR / "ChatDarkV1_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "ChatDarkV1_RuntimeManifest_v1.json"

BOOK_RUNTIME = "ChatBookFrameDarkV1.tga"
INPUT_RUNTIME = "ChatInputAtlasDarkV1.tga"
EXPECTED_FRAME_SIZE = (1608, 978)
EXPECTED_INPUT_SIZE = (512, 64)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--promote-from-candidates",
        action="store_true",
        help="Create accepted source PNGs from the reviewed candidate files",
    )
    parser.add_argument("--frame-candidate", type=Path, default=FRAME_CANDIDATE)
    parser.add_argument("--input-candidate", type=Path, default=INPUT_CANDIDATE)
    parser.add_argument("--source-dir", type=Path, default=SOURCE_DIR)
    parser.add_argument("--runtime-dir", type=Path, default=RUNTIME_DIR)
    parser.add_argument("--artifact-dir", type=Path, default=GENERATED_DIR)
    return parser.parse_args()


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


def validate_exact_size(name: str, image: Image.Image, expected: tuple[int, int]) -> None:
    if image.size != expected:
        raise ValueError(f"{name} must be {expected}, got {image.size}")
    if image.mode != "RGBA":
        raise ValueError(f"{name} must be RGBA, got {image.mode}")


def sanitize_frame_fringe(image: Image.Image) -> Image.Image:
    """Clear imperceptible alpha-1 chroma remnants without redrawing art."""

    output = image.copy()
    output.putdata(
        [
            (0, 0, 0, 0) if pixel[3] <= 1 else pixel
            for pixel in output.getdata()
        ]
    )
    return output


def write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def promote_sources(args: argparse.Namespace) -> None:
    frame_candidate = Image.open(args.frame_candidate).convert("RGBA")
    input_candidate = Image.open(args.input_candidate).convert("RGBA")
    validate_exact_size("frame candidate", frame_candidate, EXPECTED_FRAME_SIZE)
    validate_exact_size("input candidate", input_candidate, EXPECTED_INPUT_SIZE)

    accepted_frame = sanitize_frame_fringe(frame_candidate)
    alpha_minimum, alpha_maximum = accepted_frame.getchannel("A").getextrema()
    if alpha_minimum != 0 or alpha_maximum != 255:
        raise ValueError("accepted frame must contain transparent and opaque pixels")

    source_dir = args.source_dir
    source_dir.mkdir(parents=True, exist_ok=True)
    frame_source = source_dir / FRAME_SOURCE.name
    input_source = source_dir / INPUT_SOURCE.name
    accepted_frame.save(frame_source, format="PNG", optimize=False, compress_level=9)
    input_candidate.save(input_source, format="PNG", optimize=False, compress_level=9)

    source_manifest = {
        "schema_version": 1,
        "module": "chat",
        "batch": "CHAT.CORE.DARK.V1",
        "accepted_version": "Dark V1",
        "status": "accepted-source",
        "accepted_on": "2026-08-03",
        "acceptance": (
            "The user requested integration after confirming the cross-device "
            "chat frame, input strip and color mapping update."
        ),
        "sources": [
            {
                "component": "CHAT.FRAME",
                "file": frame_source.name,
                "sha256": sha256(frame_source),
                "width": accepted_frame.width,
                "height": accepted_frame.height,
                "mode": accepted_frame.mode,
                **alpha_evidence(accepted_frame),
                "candidate": {
                    "file": display_path(args.frame_candidate),
                    "sha256": sha256(args.frame_candidate),
                    "normalization": (
                        "whole-candidate promotion; only alpha <= 1 fringe pixels "
                        "were cleared to transparent"
                    ),
                },
                "provenance": {
                    "executor": "imagegen-0-143-0",
                    "codex_package": "@openai/codex@0.143.0",
                    "generation_session": "019fc27e-f6fb-7d90-ac30-5fbdfef99c11",
                    "result_ids": [
                        "ig_0008a6d335a216a8016a6f3b35b41481919d0752e2d83926a4"
                    ],
                },
            },
            {
                "component": "CHAT.INPUT",
                "file": input_source.name,
                "sha256": sha256(input_source),
                "width": input_candidate.width,
                "height": input_candidate.height,
                "mode": input_candidate.mode,
                **alpha_evidence(input_candidate),
                "candidate": {
                    "file": display_path(args.input_candidate),
                    "sha256": sha256(args.input_candidate),
                    "normalization": "lossless RGBA container conversion only",
                },
                "provenance": {
                    "executor": "imagegen-0-143-0",
                    "generation_session": None,
                    "result_ids": [],
                    "provenance_gap": (
                        "The synchronized input candidate predates retained "
                        "provider session metadata; no IDs were invented."
                    ),
                },
            },
        ],
        "stable_dependencies": {
            "tabs": "../v3/ChatTabs_Master_v3.png",
            "unread": "../v3/ChatControls_Master_v3.png",
        },
        "prompt_contracts": {
            "global": "../../../../docs/GLOBAL_ART_BASELINE.md",
            "module": "../../../../docs/modules/chat/ART_BASELINE.md",
            "submodules": (
                "../../../../docs/modules/chat/SUBMODULE_ART_BASELINES.md"
            ),
            "work": "../../../../docs/modules/chat/work/CHAT.CORE.V3.md",
        },
        "runtime_contract": {
            "version": "1.19",
            "single_chat_frame": True,
            "exporter": "../../../../tools/build_chat_dark_v1_runtime_assets.py",
            "runtime_manifest": RUNTIME_MANIFEST.name,
        },
        "forbidden_runtime_uses": [
            "do not load high-resolution source masters directly in game",
            "do not bake tabs, text, unread state or dynamic input text into the frame",
            "do not instantiate a right-side chat book or legacy information bar",
        ],
    }
    write_json(source_dir / SOURCE_MANIFEST.name, source_manifest)


def warm_focus_state(normal: Image.Image) -> Image.Image:
    red, green, blue, alpha = normal.split()
    red = red.point(lambda value: min(255, (value * 110 + 50) // 100))
    green = green.point(lambda value: min(255, (value * 108 + 50) // 100))
    blue = blue.point(lambda value: min(255, (value * 105 + 50) // 100))
    return Image.merge("RGBA", (red, green, blue, alpha))


def build_input_atlas(input_strip: Image.Image) -> tuple[Image.Image, Image.Image, Image.Image]:
    normal = input_strip.resize((1008, 120), v3.RESAMPLE)
    focus = warm_focus_state(normal)
    atlas = Image.new("RGBA", (1024, 256), (0, 0, 0, 0))
    atlas.alpha_composite(normal, (8, 4))
    atlas.alpha_composite(focus, (8, 132))
    return atlas, normal, focus


def build_runtime_input(
    atlas: Image.Image,
    state_index: int,
    size: tuple[int, int] = (380, 25),
) -> Image.Image:
    width, height = size
    row_top = state_index * 128
    source_x = v3.INPUT_ATLAS_X_PIXELS
    target_x = (0, 28, width - 20, width)
    output = Image.new("RGBA", size, (0, 0, 0, 0))
    for index in range(3):
        patch = atlas.crop(
            (source_x[index], row_top, source_x[index + 1], row_top + 128)
        )
        patch = patch.resize(
            (target_x[index + 1] - target_x[index], height), v3.RESAMPLE
        )
        output.alpha_composite(patch, (target_x[index], 0))
    return output


def build_runtime_assembly(
    book_preview: Image.Image,
    tab_atlas: Image.Image,
    shelf: Image.Image,
    input_atlas: Image.Image,
) -> Image.Image:
    output = book_preview.copy()
    output.alpha_composite(
        shelf.resize((380, v3.TAB_SHELF_RUNTIME_HEIGHT), v3.RESAMPLE),
        (30, v3.TAB_SHELF_TOP_OFFSET),
    )
    for index, state in enumerate((2, 0, 0, 0)):
        output.alpha_composite(
            v3.build_runtime_tab(tab_atlas, state),
            (30 + index * (v3.TAB_RUNTIME_WIDTH + v3.TAB_RUNTIME_GAP), 2),
        )
    output.alpha_composite(build_runtime_input(input_atlas, 1), (30, 289))
    return output


def checkerboard(size: tuple[int, int]) -> Image.Image:
    output = Image.new("RGBA", size, (38, 31, 24, 255))
    draw = ImageDraw.Draw(output)
    for y in range(0, size[1], 16):
        for x in range(0, size[0], 16):
            if (x // 16 + y // 16) % 2 == 0:
                draw.rectangle((x, y, x + 15, y + 15), fill=(55, 45, 34, 255))
    return output


def main() -> None:
    args = parse_args()
    args.source_dir = args.source_dir.resolve()
    args.runtime_dir = args.runtime_dir.resolve()
    args.artifact_dir = args.artifact_dir.resolve()
    args.frame_candidate = args.frame_candidate.resolve()
    args.input_candidate = args.input_candidate.resolve()

    if args.promote_from_candidates:
        promote_sources(args)

    frame_source = args.source_dir / FRAME_SOURCE.name
    input_source = args.source_dir / INPUT_SOURCE.name
    if not frame_source.is_file() or not input_source.is_file():
        raise FileNotFoundError(
            "accepted dark sources are missing; run once with "
            "--promote-from-candidates"
        )

    frame = Image.open(frame_source).convert("RGBA")
    input_strip = Image.open(input_source).convert("RGBA")
    tabs_source = Image.open(V3_SOURCE_DIR / "ChatTabs_Master_v3.png").convert("RGBA")
    controls_source = Image.open(
        V3_SOURCE_DIR / "ChatControls_Master_v3.png"
    ).convert("RGBA")
    validate_exact_size("accepted frame", frame, EXPECTED_FRAME_SIZE)
    validate_exact_size("accepted input", input_strip, EXPECTED_INPUT_SIZE)
    v3.validate_source("frame", frame, (v3.BOOK_SOURCE_CUTS,))
    v3.validate_source(
        "tabs", tabs_source, (v3.TAB_SHELF_BOX,) + v3.TAB_BOXES
    )
    v3.validate_source("controls", controls_source, (v3.SEAL_BOX,))

    book = v3.build_book(frame)
    book_preview = v3.build_book_preview(book)
    tab_atlas = v3.build_tab_atlas(tabs_source)
    shelf = v3.build_tab_shelf(tabs_source)
    input_atlas, normal_input, focus_input = build_input_atlas(input_strip)

    runtime_paths = {
        "book": args.runtime_dir / BOOK_RUNTIME,
        "input": args.runtime_dir / INPUT_RUNTIME,
    }
    v3.save_tga(book, runtime_paths["book"])
    v3.save_tga(input_atlas, runtime_paths["input"])

    args.artifact_dir.mkdir(parents=True, exist_ok=True)
    v3.save_png(book, args.artifact_dir / "ChatBookFrameDarkV1_RuntimeAtlas.png")
    v3.save_png(book_preview, args.artifact_dir / "ChatBookFrameDarkV1_440x320.png")
    v3.save_png(input_atlas, args.artifact_dir / "ChatInputAtlasDarkV1.png")
    v3.save_png(normal_input, args.artifact_dir / "ChatInputDarkV1_Normal.png")
    v3.save_png(focus_input, args.artifact_dir / "ChatInputDarkV1_Focus.png")
    assembly = build_runtime_assembly(book_preview, tab_atlas, shelf, input_atlas)
    review = checkerboard((480, 360))
    review.alpha_composite(assembly, (20, 20))
    v3.save_png(review, args.artifact_dir / "ChatDarkV1_RuntimeAssembly_440x320.png")

    display_report_path = args.artifact_dir / "ChatDarkV1_RuntimeDisplayRegion.json"
    display_region = {
        "contract": "tools/specs/chat_dark_v1_runtime_display_region.json",
        "report": display_path(display_report_path),
        "status": "pending",
    }
    if display_report_path.is_file():
        display_report = json.loads(display_report_path.read_text(encoding="utf-8"))
        display_region.update(
            {
                "status": display_report.get("status", "invalid"),
                "sha256": sha256(display_report_path),
                "violation_count": display_report.get("summary", {}).get(
                    "violation_count"
                ),
            }
        )

    source_manifest = args.source_dir / SOURCE_MANIFEST.name
    runtime_manifest = {
        "schema_version": 1,
        "batch": "CHAT.CORE.DARK.V1",
        "runtime_contract": "1.19",
        "status": "runtime-exported",
        "single_chat_frame": True,
        "source_manifest": display_path(source_manifest),
        "sources": {
            "frame": {
                "file": display_path(frame_source),
                "sha256": sha256(frame_source),
                "size": list(frame.size),
                "mode": frame.mode,
                **alpha_evidence(frame),
            },
            "input": {
                "file": display_path(input_source),
                "sha256": sha256(input_source),
                "size": list(input_strip.size),
                "mode": input_strip.mode,
                **alpha_evidence(input_strip),
            },
        },
        "stable_v3_dependencies": {
            "tabs": {
                "file": display_path(V3_SOURCE_DIR / "ChatTabs_Master_v3.png"),
                "sha256": sha256(V3_SOURCE_DIR / "ChatTabs_Master_v3.png"),
            },
            "tab_runtime": {
                "file": display_path(args.runtime_dir / "ChatTabAtlasV3.tga"),
                "sha256": sha256(args.runtime_dir / "ChatTabAtlasV3.tga"),
            },
            "tab_shelf_runtime": {
                "file": display_path(args.runtime_dir / "ChatTabShelfV3.tga"),
                "sha256": sha256(args.runtime_dir / "ChatTabShelfV3.tga"),
            },
            "unread_runtime": {
                "file": display_path(args.runtime_dir / "ChatUnreadSealV3.tga"),
                "sha256": sha256(args.runtime_dir / "ChatUnreadSealV3.tga"),
            },
        },
        "book": {
            "atlas": list(v3.BOOK_CANVAS),
            "cuts": v3.BOOK_RUNTIME_CUTS,
            "runtime_border": v3.BOOK_RUNTIME_BORDER,
            "content_safe_area": [30, 32, 410, 280],
        },
        "input": {
            "atlas": [1024, 256],
            "state_rows": {"normal": [0.0, 0.5], "focus": [0.5, 1.0]},
            "x_pixels": list(v3.INPUT_ATLAS_X_PIXELS),
            "runtime": {"size": [380, 25], "left": 28, "right": 20},
            "focus_derivation": {
                "source": "normal accepted pixels",
                "red_percent": 110,
                "green_percent": 108,
                "blue_percent": 105,
                "alpha": "unchanged",
            },
        },
        "runtime_exports": {
            name: {
                "file": display_path(path),
                "sha256": sha256(path),
                "size": list(book.size if name == "book" else input_atlas.size),
                "mode": "RGBA",
            }
            for name, path in runtime_paths.items()
        },
        "review": {
            "runtime_assembly": display_path(
                args.artifact_dir / "ChatDarkV1_RuntimeAssembly_440x320.png"
            ),
            "display_region": display_region,
        },
        "forbidden_runtime_uses": [
            "do not load high-resolution source masters directly in game",
            "do not bake tabs, text, unread state or dynamic input text into the frame",
            "do not instantiate a right-side chat book or legacy information bar",
        ],
    }
    write_json(args.source_dir / RUNTIME_MANIFEST.name, runtime_manifest)
    print(json.dumps(runtime_manifest, ensure_ascii=False))


if __name__ == "__main__":
    main()
