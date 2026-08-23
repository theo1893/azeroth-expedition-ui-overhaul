#!/usr/bin/env python3
"""Promote and export the accepted CHAR-V3-F1-TABS V3 pixels.

The four accepted 176x80 sources remain authoritative. Runtime construction
only crops the frozen left/center/right sample regions, reduces them to two
texels per UI unit, packs a POT atlas, and exports a Turtle WoW-compatible TGA.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import struct
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets/source/character/tabs-v3"
MEDIA_DIR = ROOT / "addon/AzerothExpeditionUI/Media/Character"
PROMOTION_DIR = (
    ROOT / "generated/character/tabs-v3/attempt-2/processed"
)

SOURCE_MANIFEST = SOURCE_DIR / "CHAR-V3-F1-TABS_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "CHAR-V3-F1-TABS_RuntimeManifest_v1.json"
ATLAS_MASTER = SOURCE_DIR / "CharacterTabsV3_RuntimeAtlas.png"
RUNTIME_TGA = MEDIA_DIR / "CharacterTabsV3.tga"

TEXEL_DENSITY = 2
SOURCE_SIZE = (176, 80)
ATLAS_SIZE = (128, 256)
TAB_LOGICAL_HEIGHT = 28
TAB_SAMPLED_HEIGHT = TAB_LOGICAL_HEIGHT * TEXEL_DENSITY

STATES: dict[str, dict[str, str | int]] = {
    "normal": {
        "source_name": "CharacterTabNormal_SourceV3.png",
        "promotion_name": "CharacterTab_normal_SourceV3.png",
        "sha256": "eb513dc3163a7eb91490899d2ad663ca441f810731d8ecc475d487dc8fc54fad",
        "atlas_y": 4,
    },
    "hover": {
        "source_name": "CharacterTabHover_SourceV3.png",
        "promotion_name": "CharacterTab_hover_SourceV3.png",
        "sha256": "7c8084ab924585efe19f1a199073255d213610d18aa69f344e17c9fa6b4eb380",
        "atlas_y": 68,
    },
    "pressed": {
        "source_name": "CharacterTabPressed_SourceV3.png",
        "promotion_name": "CharacterTab_pressed_SourceV3.png",
        "sha256": "36f2512e79751b7dd92aadadf5fdaff1687f28bc7247a419d00916a273353275",
        "atlas_y": 132,
    },
    "selected": {
        "source_name": "CharacterTabSelected_SourceV3.png",
        "promotion_name": "CharacterTab_selected_SourceV3.png",
        "sha256": "50624701ba8feeb3d33ec1024902bff2194d701dc6f4fd1e97f65e2dc21ee016",
        "atlas_y": 196,
    },
}

PARTS = {
    "left": {
        "source_box": (0, 0, 24, 80),
        "sampled_size": (12, TAB_SAMPLED_HEIGHT),
        "logical_size_ui": (6, TAB_LOGICAL_HEIGHT),
        "atlas_x": 8,
    },
    "center": {
        "source_box": (72, 0, 104, 80),
        "sampled_size": (16, TAB_SAMPLED_HEIGHT),
        "logical_size_ui": (8, TAB_LOGICAL_HEIGHT),
        "atlas_x": 32,
    },
    "right": {
        "source_box": (152, 0, 176, 80),
        "sampled_size": (12, TAB_SAMPLED_HEIGHT),
        "logical_size_ui": (6, TAB_LOGICAL_HEIGHT),
        "atlas_x": 60,
    },
}

USER_ACCEPTANCE = (
    "接受 CHAR-V3-F1-TABS V3 attempt 2 的 exact pixels，并允许提升 "
    "source/runtime、装配 POT atlas 与接入 addon。"
)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def repo_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    rgba[rgba[..., 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def transparent_rgb_nonzero(image: Image.Image) -> int:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8)
    transparent = rgba[..., 3] == 0
    return int(np.count_nonzero(rgba[transparent, :3]))


def green_dominant_pixels(image: Image.Image) -> int:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8)
    rgb = rgba[..., :3].astype(np.int16)
    return int(
        np.count_nonzero(
            (rgba[..., 3] > 0)
            & (rgb[..., 1] > 12)
            & (rgb[..., 1] > rgb[..., 0] * 1.08)
            & (rgb[..., 1] > rgb[..., 2] * 1.08)
        )
    )


def image_metrics(image: Image.Image) -> dict[str, Any]:
    rgba = image.convert("RGBA")
    return {
        "size": list(rgba.size),
        "pixel_sha256": pixel_sha256(rgba),
        "visible_bbox_exclusive": list(
            rgba.getchannel("A").getbbox() or (0, 0, 0, 0)
        ),
        "transparent_rgb_nonzero_pixels": transparent_rgb_nonzero(rgba),
        "green_dominant_pixels": green_dominant_pixels(rgba),
    }


def tga_header(path: Path) -> dict[str, Any]:
    data = path.read_bytes()
    if len(data) < 18:
        raise ValueError(f"incomplete TGA header: {path}")
    width, height = struct.unpack("<HH", data[12:16])
    return {
        "image_type": data[2],
        "width": width,
        "height": height,
        "bits_per_pixel": data[16],
        "descriptor": data[17],
        "top_origin": bool(data[17] & 0x20),
    }


def save_tga(path: Path, image: Image.Image) -> Image.Image:
    rgba = clear_transparent_rgb(image)
    if rgba.size != ATLAS_SIZE:
        raise ValueError(f"runtime atlas must remain {ATLAS_SIZE}: {rgba.size}")
    path.parent.mkdir(parents=True, exist_ok=True)
    rgba.save(path, format="TGA")
    with Image.open(path) as opened:
        roundtrip = opened.convert("RGBA")
    if ImageChops.difference(roundtrip, rgba).getbbox() is not None:
        raise ValueError("TGA roundtrip changed accepted runtime pixels")
    header = tga_header(path)
    if (
        header["image_type"] != 2
        or header["bits_per_pixel"] != 32
        or (header["width"], header["height"]) != ATLAS_SIZE
        or max(ATLAS_SIZE) > 1024
    ):
        raise ValueError(f"invalid Turtle WoW TGA: {header}")
    return roundtrip


def promote_sources() -> None:
    SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    for state, definition in STATES.items():
        source = PROMOTION_DIR / str(definition["promotion_name"])
        expected = str(definition["sha256"])
        if not source.is_file():
            raise FileNotFoundError(f"accepted promotion input missing: {source}")
        if sha256(source) != expected:
            raise ValueError(f"accepted exact pixels changed before promotion: {state}")
        target = SOURCE_DIR / str(definition["source_name"])
        shutil.copyfile(source, target)
        if sha256(target) != expected:
            raise ValueError(f"promotion changed exact bytes: {state}")


def load_sources() -> dict[str, Image.Image]:
    sources: dict[str, Image.Image] = {}
    for state, definition in STATES.items():
        path = SOURCE_DIR / str(definition["source_name"])
        expected = str(definition["sha256"])
        if not path.is_file() or sha256(path) != expected:
            raise ValueError(f"accepted source missing or changed: {path}")
        with Image.open(path) as opened:
            source = opened.convert("RGBA")
        if source.size != SOURCE_SIZE:
            raise ValueError(f"accepted source geometry changed: {state}={source.size}")
        metrics = image_metrics(source)
        if (
            metrics["transparent_rgb_nonzero_pixels"] != 0
            or metrics["green_dominant_pixels"] != 0
        ):
            raise ValueError(f"accepted source transparency/chroma check failed: {state}")
        sources[state] = source
    return sources


def build_atlas(
    sources: dict[str, Image.Image],
) -> tuple[Image.Image, dict[str, dict[str, Any]]]:
    atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
    runtime_states: dict[str, dict[str, Any]] = {}
    for state, definition in STATES.items():
        y = int(definition["atlas_y"])
        runtime_states[state] = {}
        for part_name, part_definition in PARTS.items():
            box = tuple(part_definition["source_box"])
            sampled_size = tuple(part_definition["sampled_size"])
            logical_size = tuple(part_definition["logical_size_ui"])
            sampled = clear_transparent_rgb(
                sources[state].crop(box).resize(
                    sampled_size,
                    # BOX downsamples the accepted painted source without the
                    # four one-pixel green overshoots produced by Lanczos at
                    # the enlarged 56-texel runtime height.
                    Image.Resampling.BOX,
                )
            )
            x = int(part_definition["atlas_x"])
            atlas.alpha_composite(sampled, (x, y))
            runtime_states[state][part_name] = {
                "cell_origin": [x, y],
                "logical_size_ui": list(logical_size),
                "sampled_size": list(sampled_size),
                "texels_per_ui_unit": TEXEL_DENSITY,
                "uv": [
                    x / ATLAS_SIZE[0],
                    (x + sampled.width) / ATLAS_SIZE[0],
                    y / ATLAS_SIZE[1],
                    (y + sampled.height) / ATLAS_SIZE[1],
                ],
                "sampled_pixel_sha256": pixel_sha256(sampled),
            }
    atlas = clear_transparent_rgb(atlas)
    if transparent_rgb_nonzero(atlas) or green_dominant_pixels(atlas):
        raise ValueError("runtime atlas transparency/chroma check failed")
    return atlas, runtime_states


def write_manifests(
    sources: dict[str, Image.Image],
    atlas: Image.Image,
    runtime_states: dict[str, dict[str, Any]],
    roundtrip: Image.Image,
) -> None:
    source_assets: dict[str, Any] = {}
    for state, definition in STATES.items():
        path = SOURCE_DIR / str(definition["source_name"])
        source_assets[state] = {
            "file": repo_path(path),
            "sha256": sha256(path),
            "metrics": image_metrics(sources[state]),
        }
    source_assets["atlas_runtime_master"] = {
        "file": repo_path(ATLAS_MASTER),
        "sha256": sha256(ATLAS_MASTER),
        "metrics": image_metrics(atlas),
    }

    source_payload = {
        "schema": "aeui-character-v3-f1-tabs-source-manifest-v1",
        "schema_version": 1,
        "module": "character",
        "batch": "CHAR-V3-F1-TABS V3 final",
        "component": "CHAR.TABS",
        "status": "runtime-exported",
        "phase": "P5",
        "accepted_on": "2026-08-19",
        "user_acceptance": {
            "statement": USER_ACCEPTANCE,
            "accepts_exact_pixels": True,
            "source_promotion_authorized": True,
            "runtime_export_authorized": True,
            "addon_integration_authorized": True,
        },
        "provenance": {
            "executor": "imagegen-0-143-0",
            "global_prompt": "docs/GLOBAL_ART_BASELINE.md",
            "module_prompt": "docs/modules/character/ART_BASELINE.md",
            "submodule_prompt": "docs/modules/character/SUBMODULE_ART_BASELINES.md#chartabs",
            "contract": "CHAR-V3-F1-TABS V3 final",
            "selected_attempt": 2,
            "actual_imagegen_calls": 2,
            "raw_candidate_sha256": "7e927c5a9c4af76a957b26aabcb9f75aa6b493e67e29eb3a3aa18c29b3d9edf0",
            "postprocess": (
                "equal-axis square normalization, fixed quadrant split, "
                "edge-connected chroma key and despill, transparent RGB clear, "
                "proportional bbox-fit to four accepted 176x80 sources"
            ),
            "fixed_references": {
                "geometry": "023fecfbfc81ac7edc39bdbbc6a03b707f830955422c27fec3fde5242299295e",
                "material": "efdf1763620bf7000c14be87f99d0a2035387bd81a628d24ba87faa3540563ed",
                "character_lock": "b5c364482adaace09af9b5196d2e8d4f7ef79d3b21706e189d94c106ba6ec2ba",
            },
        },
        "deterministic_transform": {
            "source_size_each": list(SOURCE_SIZE),
            "state_order": list(STATES),
            "source_slice_boxes_exclusive": {
                name: list(definition["source_box"])
                for name, definition in PARTS.items()
            },
            "runtime_sampled_sizes": {
                name: list(definition["sampled_size"])
                for name, definition in PARTS.items()
            },
            "runtime_atlas_size": list(ATLAS_SIZE),
            "runtime_resampling": "Pillow BOX",
            "texels_per_ui_unit": TEXEL_DENSITY,
            "horizontal_stretch_part": "center only",
            "accepted_source_pixels_modified_during_promotion": False,
            "painted_or_synthesized_pixels_during_promotion": 0,
        },
        "accepted_assets": source_assets,
    }

    runtime_payload = {
        "schema": "aeui-character-v3-f1-tabs-runtime-manifest-v1",
        "schema_version": 1,
        "module": "character",
        "batch": "CHAR-V3-F1-TABS V3 final",
        "component": "CHAR.TABS",
        "status": "runtime-exported",
        "phase": "P5",
        "runtime_contract": "2.1",
        "source_manifest": repo_path(SOURCE_MANIFEST),
        "runtime": {
            "file": repo_path(RUNTIME_TGA),
            "sha256": sha256(RUNTIME_TGA),
            "texture_size": list(roundtrip.size),
            "pixel_sha256": pixel_sha256(roundtrip),
            "texels_per_ui_unit": TEXEL_DENSITY,
            "tga": tga_header(RUNTIME_TGA),
            "states": runtime_states,
        },
        "layout_contract": {
            "ownership_route": "character.tabs-v3",
            "provider": "CharacterFrameTab1..5 after pfUI Character SkinTab",
            "logical_height_ui": TAB_LOGICAL_HEIGHT,
            "dynamic_width": (
                "visible tabs share the pfUI Character backdrop width; each keeps "
                "at least max(64 UI, provider text width + 32 UI)"
            ),
            "left_cap_ui": 6,
            "right_cap_ui": 6,
            "center_width_ui": "TabWidth - 12",
            "runtime_stretch": "horizontal center only",
            "state_mapping": {
                "normal": "enabled idle",
                "hover": "enabled OnEnter",
                "pressed": "enabled OnMouseDown",
                "selected": "PanelTemplates disabled selected tab",
            },
            "provider_geometry_changed": True,
            "provider_text_clicks_and_reflow": "live",
            "pet_hidden_reflow": "adapter recalculates the visible provider row",
            "fallback": "restore pfUI tab backdrop when module or ownership route is inactive",
            "texels_per_ui_unit": TEXEL_DENSITY,
        },
        "texel_density": {
            "texels_per_ui_unit": TEXEL_DENSITY,
            "ui_geometry_changed": True,
            "target_physical_scale": "up to 2 screen pixels per UI unit",
        },
    }

    SOURCE_MANIFEST.write_text(
        json.dumps(source_payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    RUNTIME_MANIFEST.write_text(
        json.dumps(runtime_payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--promote",
        action="store_true",
        help="copy the user-accepted exact sources from ignored generated data",
    )
    args = parser.parse_args()

    if args.promote:
        promote_sources()
    sources = load_sources()
    atlas, runtime_states = build_atlas(sources)
    SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    atlas.save(ATLAS_MASTER, format="PNG")
    roundtrip = save_tga(RUNTIME_TGA, atlas)
    write_manifests(sources, atlas, runtime_states, roundtrip)
    print(
        "exported CHAR-V3-F1-TABS V3; "
        f"source={repo_path(SOURCE_DIR)}; runtime={repo_path(RUNTIME_TGA)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
