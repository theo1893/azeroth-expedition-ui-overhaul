#!/usr/bin/env python3
"""Deterministically export the accepted CHAT.TABS.DARK.V2 source.

The accepted P4 sheet contains one shelf and four state cells.  This exporter
validates the exact source, clears RGB only on the thirteen accepted
low-alpha green-edge pixels while preserving Alpha, resamples complete cells
into the established Turtle WoW atlases, and writes two RGBA TGA files.  It
never redraws art or bakes tab text, unread state, geometry, or behavior.
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
    / "tabs-dark-v2"
    / "ChatTabs_Dark_V2_A.png"
)
SOURCE_MANIFEST = SOURCE.with_name("ChatTabs_Dark_V2_SourceManifest_v1.json")
RUNTIME_DIR = ROOT / "addon" / "AzerothExpeditionUI" / "Media" / "Chat"
TAB_RUNTIME = RUNTIME_DIR / "ChatTabAtlasDarkV2.tga"
SHELF_RUNTIME = RUNTIME_DIR / "ChatTabShelfDarkV2.tga"
RUNTIME_MANIFEST = SOURCE.with_name("ChatTabs_Dark_V2_RuntimeManifest_v1.json")
ARTIFACT_DIR = (
    ROOT
    / "generated"
    / "chat"
    / "core"
    / "CHAT.TABS.DARK.V2"
    / "runtime-v2"
)

SOURCE_SHA256 = (
    "616f965bb850605bcb67a98f60660feee35d80f8b95bc2b35ad72487df9a1e3c"
)
SOURCE_SIZE = (1536, 1024)
SOURCE_VISIBLE_BBOX = (80, 118, 1457, 705)
SOURCE_CELLS = {
    "shelf": (64, 96, 1472, 232),
    "normal": (64, 560, 384, 716),
    "hover": (416, 560, 736, 716),
    "selected": (768, 560, 1088, 716),
    "disabled": (1120, 560, 1440, 716),
}
STATE_ORDER = ("normal", "hover", "selected", "disabled")

TAB_ATLAS_SIZE = (512, 512)
TAB_ATLAS_BOXES = {
    state: (4, index * 128 + 4, 252, index * 128 + 124)
    for index, state in enumerate(STATE_ORDER)
}
TAB_ATLAS_X_PIXELS = (4, 52, 204, 252)
TAB_RUNTIME_CAPS = (16, 16)
TAB_RUNTIME_SIZE = (92, 30)
TAB_RUNTIME_GAP = 3
TAB_RUNTIME_TOP_OFFSET = 2
TAB_HIT_BOTTOM_EXTENSION = 8
TAB_TEXT_SAFE_INSET = 6
TAB_TEXT_HEIGHT = 18

SHELF_ATLAS_SIZE = (1024, 64)
SHELF_ATLAS_BOX = (4, 4, 1020, 60)
SHELF_RUNTIME_HEIGHT = 16
SHELF_RUNTIME_TOP_OFFSET = 18
SUPPORTED_FRAME_SIZES = ((440, 320), (540, 420))
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


def green_dominant_mask(values: np.ndarray) -> np.ndarray:
    values_i16 = values.astype(np.int16)
    return (
        (values[:, :, 3] > 0)
        & (values[:, :, 1] >= 128)
        & (values_i16[:, :, 1] >= values_i16[:, :, 0] + 32)
        & (values_i16[:, :, 1] >= values_i16[:, :, 2] + 32)
    )


def pixel_hygiene(image: Image.Image) -> dict[str, int]:
    values = np.asarray(image.convert("RGBA"), dtype=np.uint8)
    transparent = values[:, :, 3] == 0
    exact_green = (
        (values[:, :, 0] <= 4)
        & (values[:, :, 1] >= 251)
        & (values[:, :, 2] <= 4)
        & (values[:, :, 3] > 0)
    )
    return {
        "exact_green_visible_pixels": int(exact_green.sum()),
        "visible_green_spill_pixels": int(green_dominant_mask(values).sum()),
        "transparent_rgb_nonzero_values": int(
            np.count_nonzero(values[transparent, :3])
        ),
    }


def source_cell_evidence(image: Image.Image) -> dict[str, Any]:
    alpha = np.asarray(image.getchannel("A"), dtype=np.uint8)
    allowed = np.zeros((image.height, image.width), dtype=bool)
    cells: dict[str, Any] = {}
    minimum_margin: int | None = None
    for cell_id, (x0, y0, x1, y1) in SOURCE_CELLS.items():
        allowed[y0:y1, x0:x1] = True
        local = image.crop((x0, y0, x1, y1)).getchannel("A")
        bbox = local.getbbox()
        if bbox is None:
            raise ValueError(f"source cell is empty: {cell_id}")
        margins = [
            bbox[0],
            bbox[1],
            local.width - bbox[2],
            local.height - bbox[3],
        ]
        if min(margins) < 4:
            raise ValueError(
                f"source cell lacks four-pixel isolation: {cell_id} {margins}"
            )
        minimum_margin = (
            min(margins)
            if minimum_margin is None
            else min(minimum_margin, *margins)
        )
        cells[cell_id] = {
            "box_xyxy": [x0, y0, x1, y1],
            "visible_bbox_local_exclusive": list(bbox),
            "margins_ltrb": margins,
        }

    outside = int(np.count_nonzero((alpha > 0) & ~allowed))
    if outside:
        raise ValueError(f"visible source pixels outside declared cells: {outside}")
    return {
        "outside_declared_cells_visible_pixels": outside,
        "minimum_cell_margin_pixels": minimum_margin,
        "cells": cells,
    }


def validate_source(path: Path, image: Image.Image) -> dict[str, Any]:
    if sha256(path) != SOURCE_SHA256:
        raise ValueError("tab source SHA-256 does not match accepted P4 source")
    if image.size != SOURCE_SIZE or image.mode != "RGBA":
        raise ValueError(
            f"tab source must be {SOURCE_SIZE} RGBA, got {image.size} {image.mode}"
        )
    if image.getchannel("A").getbbox() != SOURCE_VISIBLE_BBOX:
        raise ValueError("tab source visible bbox does not match its P4 contract")
    hygiene = pixel_hygiene(image)
    if hygiene != {
        "exact_green_visible_pixels": 7,
        "visible_green_spill_pixels": 13,
        "transparent_rgb_nonzero_values": 0,
    }:
        raise ValueError(f"unexpected accepted-source pixel hygiene: {hygiene}")

    values = np.asarray(image, dtype=np.uint8)
    green = green_dominant_mask(values)
    alpha_values = values[:, :, 3][green]
    if alpha_values.size != 13 or int(alpha_values.min()) != 1 or int(alpha_values.max()) != 6:
        raise ValueError("accepted green-edge pixels no longer match alpha 1..6 contract")
    return source_cell_evidence(image)


def clean_accepted_green_edges(
    source: Image.Image,
) -> tuple[Image.Image, dict[str, Any]]:
    values = np.asarray(source.convert("RGBA"), dtype=np.uint8).copy()
    alpha_before = values[:, :, 3].copy()
    green = green_dominant_mask(values)
    low_alpha_green = green & (values[:, :, 3] <= 6)
    if int(low_alpha_green.sum()) != 13 or int(green.sum()) != 13:
        raise ValueError("source cleanup is not limited to the accepted thirteen pixels")
    affected_alpha = values[:, :, 3][low_alpha_green].copy()
    values[low_alpha_green, :3] = 0
    if not np.array_equal(values[:, :, 3], alpha_before):
        raise ValueError("source cleanup changed Alpha")
    cleaned = Image.fromarray(values, mode="RGBA")
    hygiene = pixel_hygiene(cleaned)
    if hygiene != {
        "exact_green_visible_pixels": 0,
        "visible_green_spill_pixels": 0,
        "transparent_rgb_nonzero_values": 0,
    }:
        raise ValueError(f"source RGB-only cleanup failed: {hygiene}")
    return cleaned, {
        "rgb_only_cleared_pixels": int(low_alpha_green.sum()),
        "affected_alpha_min_max": [
            int(affected_alpha.min()),
            int(affected_alpha.max()),
        ],
        "alpha_difference_pixels": 0,
        "post_cleanup": hygiene,
    }


def clear_transparent_rgb(image: Image.Image) -> tuple[Image.Image, int]:
    values = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    transparent = values[:, :, 3] == 0
    changed_values = int(np.count_nonzero(values[transparent, :3]))
    values[transparent, :3] = 0
    return Image.fromarray(values, mode="RGBA"), changed_values


def clear_resampling_green_rgb(
    image: Image.Image,
) -> tuple[Image.Image, dict[str, Any]]:
    """Clear only new green-dominant RGB produced by LANCZOS ringing."""

    values = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    alpha_before = values[:, :, 3].copy()
    green = green_dominant_mask(values)
    affected_alpha = values[:, :, 3][green].copy()
    values[green, :3] = 0
    if not np.array_equal(values[:, :, 3], alpha_before):
        raise ValueError("resampling cleanup changed Alpha")
    cleaned = Image.fromarray(values, mode="RGBA")
    return cleaned, {
        "rgb_only_cleared_pixels": int(green.sum()),
        "affected_alpha_min_max": (
            [int(affected_alpha.min()), int(affected_alpha.max())]
            if affected_alpha.size
            else None
        ),
        "alpha_difference_pixels": 0,
    }


def build_atlases(
    source: Image.Image,
) -> tuple[Image.Image, Image.Image, dict[str, Any]]:
    cleaned, source_cleanup = clean_accepted_green_edges(source)
    tab_atlas = Image.new("RGBA", TAB_ATLAS_SIZE, (0, 0, 0, 0))
    state_cleanup: dict[str, Any] = {}
    for state in STATE_ORDER:
        resized = cleaned.crop(SOURCE_CELLS[state]).resize((248, 120), RESAMPLE)
        resized, ringing_cleanup = clear_resampling_green_rgb(resized)
        resized, cleared = clear_transparent_rgb(resized)
        hygiene = pixel_hygiene(resized)
        if hygiene["visible_green_spill_pixels"] != 0:
            raise ValueError(f"resampled {state} contains visible green spill")
        tab_atlas.alpha_composite(resized, TAB_ATLAS_BOXES[state][:2])
        state_cleanup[state] = {
            "lanczos_green_ringing_cleanup": ringing_cleanup,
            "transparent_rgb_values_cleared": cleared,
            **hygiene,
        }
    tab_atlas, tab_cleared = clear_transparent_rgb(tab_atlas)

    shelf_atlas = Image.new("RGBA", SHELF_ATLAS_SIZE, (0, 0, 0, 0))
    shelf = cleaned.crop(SOURCE_CELLS["shelf"]).resize((1016, 56), RESAMPLE)
    shelf, shelf_ringing_cleanup = clear_resampling_green_rgb(shelf)
    shelf, shelf_cleared = clear_transparent_rgb(shelf)
    shelf_hygiene = pixel_hygiene(shelf)
    if shelf_hygiene["visible_green_spill_pixels"] != 0:
        raise ValueError("resampled shelf contains visible green spill")
    shelf_atlas.alpha_composite(shelf, SHELF_ATLAS_BOX[:2])
    shelf_atlas, shelf_atlas_cleared = clear_transparent_rgb(shelf_atlas)

    for label, atlas in (("tab", tab_atlas), ("shelf", shelf_atlas)):
        hygiene = pixel_hygiene(atlas)
        if hygiene["visible_green_spill_pixels"] != 0:
            raise ValueError(f"runtime {label} atlas contains visible green spill")
        if hygiene["transparent_rgb_nonzero_values"] != 0:
            raise ValueError(f"runtime {label} atlas has dirty transparent RGB")

    return tab_atlas, shelf_atlas, {
        "source_cleanup": source_cleanup,
        "state_cleanup": state_cleanup,
        "tab_atlas_transparent_rgb_values_cleared": tab_cleared,
        "shelf_cleanup": {
            "lanczos_green_ringing_cleanup": shelf_ringing_cleanup,
            "transparent_rgb_values_cleared": shelf_cleared,
            **shelf_hygiene,
        },
        "shelf_atlas_transparent_rgb_values_cleared": shelf_atlas_cleared,
    }


def build_runtime_tab(
    atlas: Image.Image,
    state: str,
    width: int = TAB_RUNTIME_SIZE[0],
    height: int = TAB_RUNTIME_SIZE[1],
) -> Image.Image:
    if state not in STATE_ORDER:
        raise ValueError(f"unknown tab state: {state}")
    if width < TAB_RUNTIME_CAPS[0] + TAB_RUNTIME_CAPS[1] + 1:
        raise ValueError(f"tab width is below slice minimum: {width}")
    row = STATE_ORDER.index(state)
    source_y = (row * 128, row * 128 + 128)
    target_x = (0, TAB_RUNTIME_CAPS[0], width - TAB_RUNTIME_CAPS[1], width)
    output = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    for index in range(3):
        patch = atlas.crop(
            (
                TAB_ATLAS_X_PIXELS[index],
                source_y[0],
                TAB_ATLAS_X_PIXELS[index + 1],
                source_y[1],
            )
        ).resize(
            (target_x[index + 1] - target_x[index], height),
            RESAMPLE,
        )
        output.alpha_composite(patch, (target_x[index], 0))
    return output


def build_runtime_shelf(
    atlas: Image.Image,
    width: int,
    height: int = SHELF_RUNTIME_HEIGHT,
) -> Image.Image:
    if width < 1 or height < 1:
        raise ValueError("shelf runtime dimensions must be positive")
    return atlas.resize((width, height), RESAMPLE)


def save_tga(image: Image.Image, path: Path, expected_size: tuple[int, int]) -> None:
    if image.mode != "RGBA" or image.size != expected_size:
        raise ValueError(
            f"runtime atlas must be {expected_size} RGBA, got {image.size} {image.mode}"
        )
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="TGA")


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=False, compress_level=9)


def optional_artifact(path: Path) -> dict[str, Any]:
    record: dict[str, Any] = {"file": display_path(path), "status": "pending"}
    if path.is_file():
        record.update({"status": "present", "sha256": sha256(path)})
    return record


def optional_package_report(path: Path) -> dict[str, Any]:
    record = optional_artifact(path)
    if path.is_file():
        payload = json.loads(path.read_text(encoding="utf-8"))
        record.update(
            {
                "schema": payload.get("schema"),
                "package_status": payload.get("status"),
                "build_required_on_target_device": payload.get(
                    "build_required_on_target_device"
                ),
                "violations": payload.get("violations", []),
            }
        )
    return record


def build_manifest(
    source_path: Path,
    source: Image.Image,
    source_cells: dict[str, Any],
    tab_path: Path,
    tab_atlas: Image.Image,
    shelf_path: Path,
    shelf_atlas: Image.Image,
    artifact_dir: Path,
    export_metrics: dict[str, Any],
) -> dict[str, Any]:
    preview_path = artifact_dir / "ChatTabsDarkV2_runtime_real_layout.png"
    metrics_path = artifact_dir / "ChatTabsDarkV2_runtime_real_layout.metrics.json"
    report_path = artifact_dir / "ChatTabsDarkV2_runtime_display-region-report.json"
    package_report_path = artifact_dir / "addon-package-report.json"
    return {
        "schema_version": 1,
        "module": "chat",
        "batch": "CHAT.TABS.DARK.V2",
        "component": "CHAT.TABS / CHAT.TAB_SHELF",
        "accepted_version": "CHAT.TABS.DARK.V2 deterministic re-layout exception A",
        "runtime_contract": "1.22",
        "status": "runtime-exported",
        "phase": "P5",
        "source": {
            "file": display_path(source_path),
            "source_manifest": display_path(SOURCE_MANIFEST),
            "sha256": sha256(source_path),
            "width": source.width,
            "height": source.height,
            "mode": source.mode,
            **alpha_evidence(source),
            **pixel_hygiene(source),
            **source_cells,
        },
        "deterministic_export": {
            "operation": (
                "validate the exact accepted P4 sheet; clear RGB only on its "
                "thirteen alpha-1..6 green-dominant edge pixels while preserving "
                "Alpha; crop five complete declared cells; LANCZOS-resample four "
                "states to 248x120 and the shelf to 1016x56; clear RGB only on any "
                "new low-alpha green-dominant LANCZOS ringing while preserving Alpha; "
                "clear fully transparent RGB; place into fixed power-of-two atlases; "
                "serialize RGBA TGA"
            ),
            "foreign_source_pixels_mixed": False,
            "redraw": False,
            "text_unread_or_behavior_baked": False,
            "source_cells_xyxy": {
                key: list(value) for key, value in SOURCE_CELLS.items()
            },
            "tab_atlas_state_boxes_xyxy": {
                key: list(value) for key, value in TAB_ATLAS_BOXES.items()
            },
            "tab_atlas_x_pixels": list(TAB_ATLAS_X_PIXELS),
            "normalized_x_uv": [
                value / TAB_ATLAS_SIZE[0] for value in TAB_ATLAS_X_PIXELS
            ],
            "normalized_state_y_uv": {
                state: [index * 0.25, (index + 1) * 0.25]
                for index, state in enumerate(STATE_ORDER)
            },
            "runtime_caps_lr": list(TAB_RUNTIME_CAPS),
            "runtime_tab_size": list(TAB_RUNTIME_SIZE),
            "runtime_tab_gap": TAB_RUNTIME_GAP,
            "runtime_tab_top_offset": TAB_RUNTIME_TOP_OFFSET,
            "runtime_hit_bottom_extension": TAB_HIT_BOTTOM_EXTENSION,
            "runtime_text_safe_inset": TAB_TEXT_SAFE_INSET,
            "runtime_text_height": TAB_TEXT_HEIGHT,
            "shelf_atlas_box_xyxy": list(SHELF_ATLAS_BOX),
            "runtime_shelf_height": SHELF_RUNTIME_HEIGHT,
            "runtime_shelf_top_offset": SHELF_RUNTIME_TOP_OFFSET,
            "supported_frame_sizes": [list(size) for size in SUPPORTED_FRAME_SIZES],
            **export_metrics,
        },
        "runtime_exports": {
            "tabs": {
                "file": display_path(tab_path),
                "sha256": sha256(tab_path),
                "width": tab_atlas.width,
                "height": tab_atlas.height,
                "mode": tab_atlas.mode,
                "logical_sampled_bbox": [4, 0, 252, 512],
                **alpha_evidence(tab_atlas),
                **pixel_hygiene(tab_atlas),
            },
            "shelf": {
                "file": display_path(shelf_path),
                "sha256": sha256(shelf_path),
                "width": shelf_atlas.width,
                "height": shelf_atlas.height,
                "mode": shelf_atlas.mode,
                "logical_sampled_bbox": [0, 0, 1024, 64],
                **alpha_evidence(shelf_atlas),
                **pixel_hygiene(shelf_atlas),
            },
        },
        "adapter": {
            "file": "addon/AzerothExpeditionUI/Modules/Chat.lua",
            "provider": [
                "pfUI.chat.left.panelTop",
                "left ChatFrameNTab",
                "left ChatFrameNTabText",
            ],
            "runtime_owner": "one shelf Texture plus three visual Texture slices per visible tab",
            "states": list(STATE_ORDER),
            "preserved_behavior": [
                "tab Button geometry and click handling",
                "docking and selection",
                "runtime-owned localized tab text",
                "native flash semantics through the independent unread seal",
                "hover, disabled and selected state selection",
                "one-shot startup and scale-edge reflow",
                "SavedVariables and all chat message behavior",
            ],
            "fallback": [
                "addon/AzerothExpeditionUI/Media/Chat/ChatTabAtlasV3.tga",
                "addon/AzerothExpeditionUI/Media/Chat/ChatTabShelfV3.tga",
            ],
        },
        "review_artifacts": {
            "tab_atlas_png": display_path(
                artifact_dir / "ChatTabAtlasDarkV2_RuntimeAtlas.png"
            ),
            "shelf_atlas_png": display_path(
                artifact_dir / "ChatTabShelfDarkV2_RuntimeAtlas.png"
            ),
            "four_state_strip": display_path(
                artifact_dir / "ChatTabsDarkV2_four_states_100pct.png"
            ),
            "real_layout_spec": "tools/specs/chat_tabs_dark_runtime_preview_v2.json",
            "display_region_contract": "tools/specs/chat_tabs_dark_runtime_display_region_v2.json",
            "real_layout": optional_artifact(preview_path),
            "real_layout_metrics": optional_artifact(metrics_path),
            "display_region_report": optional_artifact(report_path),
        },
        "addon_package_gate": optional_package_report(package_report_path),
        "forbidden_runtime_uses": [
            "do not load the accepted 1536x1024 source sheet directly in game",
            "do not display the five-object sheet as one background",
            "do not stretch a complete state instead of the three horizontal slices",
            "do not bake tab text, unread state, channel names, buttons or chat content",
            "do not change tab Button geometry, hit boxes, events, SavedVariables or nonvisual behavior",
            "do not delete the V3 tab and shelf fallback before game validation and explicit cleanup",
        ],
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--tab-runtime", type=Path, default=TAB_RUNTIME)
    parser.add_argument("--shelf-runtime", type=Path, default=SHELF_RUNTIME)
    parser.add_argument("--manifest", type=Path, default=RUNTIME_MANIFEST)
    parser.add_argument("--artifact-dir", type=Path, default=ARTIFACT_DIR)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    source = Image.open(args.source).convert("RGBA")
    cell_evidence = validate_source(args.source, source)
    tab_atlas, shelf_atlas, export_metrics = build_atlases(source)
    save_tga(tab_atlas, args.tab_runtime, TAB_ATLAS_SIZE)
    save_tga(shelf_atlas, args.shelf_runtime, SHELF_ATLAS_SIZE)

    save_png(tab_atlas, args.artifact_dir / "ChatTabAtlasDarkV2_RuntimeAtlas.png")
    save_png(shelf_atlas, args.artifact_dir / "ChatTabShelfDarkV2_RuntimeAtlas.png")
    strip = Image.new("RGBA", (4 * TAB_RUNTIME_SIZE[0] + 3 * TAB_RUNTIME_GAP, 40), (0, 0, 0, 0))
    for index, state in enumerate(STATE_ORDER):
        strip.alpha_composite(
            build_runtime_tab(tab_atlas, state),
            (index * (TAB_RUNTIME_SIZE[0] + TAB_RUNTIME_GAP), 0),
        )
    save_png(strip, args.artifact_dir / "ChatTabsDarkV2_four_states_100pct.png")

    manifest = build_manifest(
        args.source,
        source,
        cell_evidence,
        args.tab_runtime,
        tab_atlas,
        args.shelf_runtime,
        shelf_atlas,
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
