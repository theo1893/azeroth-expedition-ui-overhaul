#!/usr/bin/env python3
"""Deterministically export the accepted CHAT.INPUT.DARK.V1 source.

The accepted source contains two canonical 1386x176 RGBA state cells.  This
tool validates that exact source, resamples each cell into the established
1024x256 two-row atlas, preserves the shared Alpha silhouette, clears only
fully transparent RGB (plus impossible dominant-green resampling spill), and
writes the final Turtle WoW TGA.  It never redraws or bakes EditBox content.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (
    ROOT
    / "assets"
    / "source"
    / "chat"
    / "input-dark-v1"
    / "ChatInput_Dark_V1_r3.png"
)
RUNTIME = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Chat"
    / "ChatInputDarkV1.tga"
)
RUNTIME_MANIFEST = SOURCE.with_name(
    "ChatInput_Dark_V1_RuntimeManifest_v1.json"
)
ARTIFACT_DIR = (
    ROOT
    / "generated"
    / "chat"
    / "core"
    / "CHAT.INPUT.DARK.V1"
    / "runtime-v1"
)

SOURCE_SHA256 = (
    "4df36bc607a024ca0a2355f5d20ff985f61cbf3304073a65e33caa978c50cda0"
)
SOURCE_SIZE = (1536, 1024)
SOURCE_VISIBLE_BBOX = (72, 198, 1416, 613)
SOURCE_CELLS = {
    "normal": (51, 187, 1437, 363),
    "focus": (51, 448, 1437, 624),
}
ATLAS_SIZE = (1024, 256)
ATLAS_BOXES = {
    "normal": (8, 4, 1016, 124),
    "focus": (8, 132, 1016, 252),
}
ATLAS_X_PIXELS = (8, 121, 932, 1016)
RUNTIME_CAPS = (28, 20)
RUNTIME_HEIGHT = 25
TEXT_INSETS = (34, 22, 0, 0)
SUPPORTED_WIDTHS = (380, 480)
RESAMPLE = Image.Resampling.LANCZOS


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def display_path(path: Path) -> str:
    try:
        return path.resolve().relative_to(ROOT).as_posix()
    except ValueError:
        return str(path.resolve())


def alpha_evidence(image: Image.Image) -> dict[str, Any]:
    alpha = image.getchannel("A")
    histogram = alpha.histogram()
    return {
        "visible_bbox_exclusive": list(alpha.getbbox() or ()),
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
    }


def pixel_hygiene(image: Image.Image) -> dict[str, int]:
    values = np.asarray(image.convert("RGBA"), dtype=np.uint8)
    values_i16 = values.astype(np.int16)
    visible_green = (
        (values[:, :, 3] > 0)
        & (values[:, :, 1] >= 96)
        & (values_i16[:, :, 1] >= values_i16[:, :, 0] + 32)
        & (values_i16[:, :, 1] >= values_i16[:, :, 2] + 32)
    )
    transparent = values[:, :, 3] == 0
    return {
        "visible_green_spill_pixels": int(visible_green.sum()),
        "transparent_rgb_nonzero_values": int(
            np.count_nonzero(values[transparent, :3])
        ),
    }


def validate_source(path: Path, image: Image.Image) -> None:
    if sha256(path) != SOURCE_SHA256:
        raise ValueError("input source SHA-256 does not match accepted P4 source")
    if image.size != SOURCE_SIZE or image.mode != "RGBA":
        raise ValueError(
            f"input source must be {SOURCE_SIZE} RGBA, got {image.size} {image.mode}"
        )
    if image.getchannel("A").getbbox() != SOURCE_VISIBLE_BBOX:
        raise ValueError("input source visible bbox does not match its contract")
    hygiene = pixel_hygiene(image)
    if hygiene != {
        "visible_green_spill_pixels": 0,
        "transparent_rgb_nonzero_values": 0,
    }:
        raise ValueError(f"input source pixel hygiene failed: {hygiene}")

    cells = {state: image.crop(box) for state, box in SOURCE_CELLS.items()}
    if any(cell.size != (1386, 176) for cell in cells.values()):
        raise ValueError("canonical input cells must both be 1386x176")
    if (
        cells["normal"].getchannel("A").tobytes()
        != cells["focus"].getchannel("A").tobytes()
    ):
        raise ValueError("accepted normal/focus source Alpha must be byte-identical")
    if any(cell.getchannel("A").getextrema() != (0, 255) for cell in cells.values()):
        raise ValueError("each accepted state must contain transparent and opaque pixels")


def sanitize_strip(image: Image.Image) -> tuple[Image.Image, dict[str, int]]:
    values = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    values_i16 = values.astype(np.int16)
    visible_green = (
        (values[:, :, 3] > 0)
        & (values[:, :, 1] >= 96)
        & (values_i16[:, :, 1] >= values_i16[:, :, 0] + 32)
        & (values_i16[:, :, 1] >= values_i16[:, :, 2] + 32)
    )
    cap = np.minimum(
        values_i16[:, :, 1],
        np.maximum(values_i16[:, :, 0], values_i16[:, :, 2]) + 4,
    ).astype(np.uint8)
    values[:, :, 1][visible_green] = cap[visible_green]
    transparent = values[:, :, 3] == 0
    transparent_rgb_nonzero_before = int(
        np.count_nonzero(values[transparent, :3])
    )
    values[transparent, :3] = 0
    return Image.fromarray(values, mode="RGBA"), {
        "visible_green_pixels_capped": int(visible_green.sum()),
        "transparent_rgb_values_cleared": transparent_rgb_nonzero_before,
    }


def build_atlas(source: Image.Image) -> tuple[Image.Image, dict[str, Any]]:
    strips: dict[str, Image.Image] = {}
    cleanup: dict[str, dict[str, int]] = {}
    for state in ("normal", "focus"):
        resized = source.crop(SOURCE_CELLS[state]).resize((1008, 120), RESAMPLE)
        strips[state], cleanup[state] = sanitize_strip(resized)

    normal_alpha = np.asarray(strips["normal"].getchannel("A"), dtype=np.uint8)
    focus_alpha = np.asarray(strips["focus"].getchannel("A"), dtype=np.uint8)
    pre_intersection_difference = int(np.count_nonzero(normal_alpha != focus_alpha))
    shared_alpha = np.minimum(normal_alpha, focus_alpha)
    for state in ("normal", "focus"):
        strips[state].putalpha(Image.fromarray(shared_alpha, mode="L"))
        strips[state], post_cleanup = sanitize_strip(strips[state])
        cleanup[state]["post_shared_transparent_rgb_values_cleared"] = post_cleanup[
            "transparent_rgb_values_cleared"
        ]
        cleanup[state]["post_shared_visible_green_pixels_capped"] = post_cleanup[
            "visible_green_pixels_capped"
        ]

    atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
    atlas.alpha_composite(strips["normal"], ATLAS_BOXES["normal"][:2])
    atlas.alpha_composite(strips["focus"], ATLAS_BOXES["focus"][:2])
    atlas, atlas_cleanup = sanitize_strip(atlas)

    if (
        strips["normal"].getchannel("A").tobytes()
        != strips["focus"].getchannel("A").tobytes()
    ):
        raise ValueError("runtime normal/focus Alpha must be byte-identical")
    if pixel_hygiene(atlas) != {
        "visible_green_spill_pixels": 0,
        "transparent_rgb_nonzero_values": 0,
    }:
        raise ValueError("runtime atlas pixel hygiene failed")

    return atlas, {
        "state_cleanup": cleanup,
        "atlas_cleanup": atlas_cleanup,
        "pre_intersection_alpha_difference_pixels": pre_intersection_difference,
        "shared_alpha_bbox_local": list(
            strips["normal"].getchannel("A").getbbox() or ()
        ),
        "normal_focus_alpha_equal": True,
    }


def build_input(
    atlas: Image.Image,
    state: str,
    width: int,
    height: int = RUNTIME_HEIGHT,
) -> Image.Image:
    if state not in ("normal", "focus"):
        raise ValueError(f"unknown input state: {state}")
    if width < RUNTIME_CAPS[0] + RUNTIME_CAPS[1] + 1:
        raise ValueError(f"input width is below slice minimum: {width}")
    row = 0 if state == "normal" else 1
    source_y = (row * 128, row * 128 + 128)
    target_x = (0, RUNTIME_CAPS[0], width - RUNTIME_CAPS[1], width)
    output = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    for index in range(3):
        patch = atlas.crop(
            (
                ATLAS_X_PIXELS[index],
                source_y[0],
                ATLAS_X_PIXELS[index + 1],
                source_y[1],
            )
        ).resize(
            (target_x[index + 1] - target_x[index], height),
            RESAMPLE,
        )
        output.alpha_composite(patch, (target_x[index], 0))
    return output


def save_tga(image: Image.Image, path: Path) -> None:
    if image.mode != "RGBA" or image.size != ATLAS_SIZE:
        raise ValueError(f"runtime atlas must be {ATLAS_SIZE} RGBA")
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="TGA")


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=False, compress_level=9)


def build_manifest(
    source_path: Path,
    source: Image.Image,
    runtime_path: Path,
    atlas: Image.Image,
    artifact_dir: Path,
    export_metrics: dict[str, Any],
) -> dict[str, Any]:
    return {
        "schema_version": 1,
        "module": "chat",
        "batch": "CHAT.INPUT.DARK.V1",
        "component": "CHAT.INPUT",
        "accepted_version": "CHAT.INPUT.DARK.V1.r3 attempt 4",
        "runtime_contract": "1.20",
        "status": "runtime-exported",
        "phase": "P5",
        "source": {
            "file": display_path(source_path),
            "sha256": sha256(source_path),
            "width": source.width,
            "height": source.height,
            "mode": source.mode,
            **alpha_evidence(source),
            **pixel_hygiene(source),
        },
        "deterministic_export": {
            "operation": (
                "crop the two accepted 1386x176 canonical cells; LANCZOS "
                "resample each to 1008x120; enforce per-pixel minimum shared "
                "Alpha; cap only impossible dominant-green resampling spill; "
                "clear fully transparent RGB; place in fixed 1024x256 rows; "
                "serialize RGBA TGA"
            ),
            "foreign_source_pixels_mixed": False,
            "redraw": False,
            "text_or_behavior_baked": False,
            "source_cells_xyxy": {
                state: list(box) for state, box in SOURCE_CELLS.items()
            },
            "atlas_state_boxes_xyxy": {
                state: list(box) for state, box in ATLAS_BOXES.items()
            },
            "atlas_x_pixels": list(ATLAS_X_PIXELS),
            "normalized_x_uv": [value / ATLAS_SIZE[0] for value in ATLAS_X_PIXELS],
            "normalized_state_y_uv": {
                "normal": [0.0, 0.5],
                "focus": [0.5, 1.0],
            },
            "runtime_caps_lr": list(RUNTIME_CAPS),
            "runtime_height": RUNTIME_HEIGHT,
            "text_insets_lrtb": list(TEXT_INSETS),
            "supported_runtime_sizes": [
                [width, RUNTIME_HEIGHT] for width in SUPPORTED_WIDTHS
            ],
            **export_metrics,
        },
        "runtime_export": {
            "file": display_path(runtime_path),
            "sha256": sha256(runtime_path),
            "width": atlas.width,
            "height": atlas.height,
            "mode": atlas.mode,
            "logical_sampled_bbox": [8, 4, 1016, 252],
            **alpha_evidence(atlas),
            **pixel_hygiene(atlas),
        },
        "adapter": {
            "file": "addon/AzerothExpeditionUI/Modules/Chat.lua",
            "provider": ["pfUI.chat.editbox", "ChatFrameEditBox"],
            "runtime_owner": "ChatFrameEditBox visual slices only",
            "texture_instances": 3,
            "state_rows": ["normal", "focus"],
            "preserved_behavior": [
                "focus and activation",
                "caret and dynamic text",
                "IME",
                "channel header",
                "AltArrowKey and input history",
                "keyboard events and hit geometry",
            ],
            "fallback": (
                "addon/AzerothExpeditionUI/Media/Chat/ChatInputAtlasV3.tga "
                "retained until game validation and explicit fallback cleanup"
            ),
        },
        "review_artifacts": {
            "atlas_png": display_path(
                artifact_dir / "ChatInputDarkV1_RuntimeAtlas.png"
            ),
            "normal_380x25": display_path(
                artifact_dir / "ChatInputDarkV1_normal_380x25.png"
            ),
            "focus_380x25": display_path(
                artifact_dir / "ChatInputDarkV1_focus_380x25.png"
            ),
            "focus_480x25": display_path(
                artifact_dir / "ChatInputDarkV1_focus_480x25.png"
            ),
            "real_layout_spec": (
                "tools/specs/chat_input_dark_runtime_preview_v1.json"
            ),
            "display_region_contract": (
                "tools/specs/chat_input_dark_runtime_display_region_v1.json"
            ),
        },
        "forbidden_runtime_uses": [
            "do not load the accepted 1536x1024 source directly in game",
            "do not stretch one whole state instead of the three horizontal slices",
            "do not bake input text, headers, caret, IME or history into the atlas",
            "do not alter ChatFrameEditBox scripts, keyboard behavior or SavedVariables",
            "do not reuse this asset as frame, tab, unread, language or legacy panel art",
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
    atlas, export_metrics = build_atlas(source)
    save_tga(atlas, args.runtime)

    save_png(atlas, args.artifact_dir / "ChatInputDarkV1_RuntimeAtlas.png")
    save_png(
        build_input(atlas, "normal", 380),
        args.artifact_dir / "ChatInputDarkV1_normal_380x25.png",
    )
    save_png(
        build_input(atlas, "focus", 380),
        args.artifact_dir / "ChatInputDarkV1_focus_380x25.png",
    )
    save_png(
        build_input(atlas, "focus", 480),
        args.artifact_dir / "ChatInputDarkV1_focus_480x25.png",
    )

    manifest = build_manifest(
        args.source,
        source,
        args.runtime,
        atlas,
        args.artifact_dir,
        export_metrics,
    )
    args.manifest.parent.mkdir(parents=True, exist_ok=True)
    args.manifest.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(manifest, ensure_ascii=False))


if __name__ == "__main__":
    main()
