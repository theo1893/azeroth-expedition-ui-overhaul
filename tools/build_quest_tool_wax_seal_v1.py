#!/usr/bin/env python3
"""Export the accepted QS-A1 seal into a deterministic four-state atlas.

The tracked source is the user-approved V1.r4 appearance after the explicitly
authorized chroma-key, transparent-RGB cleanup and 1024-square normalization.
All states share one resized Alpha mask. Only RGB transforms differ.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import math
import struct
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, ImageEnhance


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (
    ROOT
    / "assets"
    / "source"
    / "quests"
    / "qs-a1"
    / "QuestToolWaxSeal_Master_v1.png"
)
SOURCE_MANIFEST = SOURCE.with_name("QS-A1_SourceManifest_v1.json")
RUNTIME_MANIFEST = SOURCE.with_name("QS-A1_RuntimeManifest_v1.json")
RUNTIME = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestToolWaxSealStatesV1.tga"
)
DISPLAY_CONTRACT = (
    ROOT / "tools" / "specs" / "quest_seals_runtime_display_region_v1.json"
)
PREVIEW_DIR = (
    ROOT
    / "generated"
    / "quests"
    / "QUEST-SEALS"
    / "QS-A1-V1"
    / "accepted-runtime"
)
ATLAS_PREVIEW = PREVIEW_DIR / "QS-A1_V1_r4_runtime_atlas.png"
REAL_LAYOUT_PREVIEW = PREVIEW_DIR / "QS-A1_V1_r4_runtime_real_layout.png"
WIDTH_PREVIEW = PREVIEW_DIR / "QS-A1_V1_r4_runtime_tracker_widths.png"
DISPLAY_REPORT = PREVIEW_DIR / "QS-A1_V1_r4_runtime_display_region.json"

EXPECTED_SOURCE_SHA256 = (
    "377dcdc141ee5487884bfc99dbfd82013a8c4d7cb7200a4414feebb81d72ab75"
)
EXPECTED_SOURCE_SIZE = (1024, 1024)
EXPECTED_SOURCE_BBOX = (192, 200, 832, 824)
RAW_ATTEMPT_SHA256 = (
    "3e972a67a3b27bb28b6b7ef314f0784886d4e16d3de98df022891b08571e4da1"
)
ACCEPTED_CANDIDATE_SHA256 = (
    "d5e5d12e09bd06e9e76f4382eea40b5501f5f6823d58b8693902ab98d8470f75"
)
ATLAS_SIZE = (256, 64)
CELL_SIZE = (64, 64)
VISIBLE_MAX = 60
STATE_ORDER = ("normal", "hover", "pressed", "disabled")
RESAMPLE = Image.Resampling.LANCZOS


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def display_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def pixels(image: Image.Image):
    if hasattr(image, "get_flattened_data"):
        return image.get_flattened_data()
    return image.getdata()


def alpha_evidence(image: Image.Image) -> dict[str, int]:
    histogram = image.getchannel("A").histogram()
    return {
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
    }


def visible_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    return image.getchannel("A").getbbox()


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


def transparent_rgb_nonzero_values(image: Image.Image) -> int:
    return sum(
        int(red != 0) + int(green != 0) + int(blue != 0)
        for red, green, blue, alpha in pixels(image.convert("RGBA"))
        if alpha == 0
    )


def green_spill_pixels(image: Image.Image) -> int:
    return sum(
        1
        for red, green, blue, alpha in pixels(image.convert("RGBA"))
        if alpha > 0 and red <= 32 and green >= 224 and blue <= 32
    )


def remove_resample_green_spill(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    cleaned = [
        (0, 0, 0, 0)
        if alpha > 0 and red <= 32 and green >= 224 and blue <= 32
        else (red, green, blue, alpha)
        for red, green, blue, alpha in pixels(rgba)
    ]
    rgba.putdata(cleaned)
    return clear_transparent_rgb(rgba)


def alpha_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.getchannel("A").tobytes()).hexdigest()


def validate_source(path: Path, source: Image.Image) -> None:
    if sha256(path) != EXPECTED_SOURCE_SHA256:
        raise ValueError("QS-A1 source SHA-256 does not match accepted V1.r4")
    if source.size != EXPECTED_SOURCE_SIZE or source.mode != "RGBA":
        raise ValueError("QS-A1 source must be 1024x1024 RGBA")
    if visible_bbox(source) != EXPECTED_SOURCE_BBOX:
        raise ValueError("QS-A1 normalized source Alpha bbox changed")
    if transparent_rgb_nonzero_values(source):
        raise ValueError("QS-A1 source has nonzero RGB below fully transparent pixels")
    if green_spill_pixels(source):
        raise ValueError("QS-A1 source contains visible chroma-key green")


def resize_visible_source(source: Image.Image) -> Image.Image:
    cropped = clear_transparent_rgb(source.crop(EXPECTED_SOURCE_BBOX))
    ratio = min(VISIBLE_MAX / cropped.width, VISIBLE_MAX / cropped.height)
    size = (
        max(1, round(cropped.width * ratio)),
        max(1, round(cropped.height * ratio)),
    )
    return remove_resample_green_spill(cropped.resize(size, RESAMPLE))


def transform_state(base: Image.Image, state: str) -> Image.Image:
    rgba = base.convert("RGBA")
    alpha = rgba.getchannel("A")
    rgb = rgba.convert("RGB")
    if state == "hover":
        rgb = ImageEnhance.Brightness(rgb).enhance(1.12)
        red, green, blue = rgb.split()
        red = red.point(lambda value: min(255, value + 9))
        rgb = Image.merge("RGB", (red, green, blue))
    elif state == "pressed":
        rgb = ImageEnhance.Brightness(rgb).enhance(0.82)
    elif state == "disabled":
        rgb = ImageEnhance.Color(rgb).enhance(0.25)
        rgb = ImageEnhance.Brightness(rgb).enhance(0.78)
    elif state != "normal":
        raise ValueError(f"unknown state {state}")
    output = rgb.convert("RGBA")
    output.putalpha(alpha)
    return clear_transparent_rgb(output)


def build_atlas(
    source: Image.Image,
) -> tuple[Image.Image, dict[str, dict[str, Any]]]:
    base = resize_visible_source(source)
    atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
    records: dict[str, dict[str, Any]] = {}
    expected_alpha = alpha_sha256(base)
    for index, state in enumerate(STATE_ORDER):
        sprite = transform_state(base, state)
        if alpha_sha256(sprite) != expected_alpha:
            raise ValueError(f"{state} does not preserve the shared Alpha mask")
        cell_x = index * CELL_SIZE[0]
        paste_x = cell_x + (CELL_SIZE[0] - sprite.width) // 2
        paste_y = (CELL_SIZE[1] - sprite.height) // 2
        atlas.alpha_composite(sprite, (paste_x, paste_y))
        cell_box = (
            cell_x,
            0,
            cell_x + CELL_SIZE[0],
            CELL_SIZE[1],
        )
        content_box = (
            paste_x,
            paste_y,
            paste_x + sprite.width,
            paste_y + sprite.height,
        )
        records[state] = {
            "runtime_cell_xyxy": list(cell_box),
            "runtime_content_xyxy": list(content_box),
            "runtime_visible_size": [sprite.width, sprite.height],
            "alpha_sha256": alpha_sha256(sprite),
            "texcoord": {
                "left": cell_box[0] / ATLAS_SIZE[0],
                "right": cell_box[2] / ATLAS_SIZE[0],
                "top": 0.0,
                "bottom": 1.0,
            },
            "rgb_transform": {
                "normal": "none",
                "hover": "brightness 1.12, then +9 red channel",
                "pressed": "brightness 0.82; runtime anchor y +1px when interactive",
                "disabled": "saturation 0.25, then brightness 0.78",
            }[state],
        }
    return clear_transparent_rgb(atlas), records


def save_tga(image: Image.Image, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, format="TGA")


def save_png(image: Image.Image, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, format="PNG", optimize=False, compress_level=9)


def tga_header(path: Path) -> dict[str, Any]:
    data = path.read_bytes()
    if len(data) < 18:
        raise ValueError("runtime TGA is shorter than its header")
    width, height = struct.unpack("<HH", data[12:16])
    return {
        "image_type": data[2],
        "width": width,
        "height": height,
        "bits_per_pixel": data[16],
        "descriptor": data[17],
        "top_origin": bool(data[17] & 0x20),
    }


def load_simulation_module() -> Any:
    path = ROOT / "tools" / "render_quest_seals_simulation_v1.py"
    spec = importlib.util.spec_from_file_location(
        "aeui_qs_runtime_preview", path
    )
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def install_runtime_seal_renderer(module: Any, atlas: Image.Image) -> None:
    original_dashed = module.dashed_rectangle

    def draw_runtime_seal(
        draw: ImageDraw.ImageDraw,
        box: tuple[int, int, int, int],
        state: str = "normal",
        hitbox: bool = False,
    ) -> None:
        index = STATE_ORDER.index(state)
        x, y, width, height = box
        cell = atlas.crop(
            (
                index * CELL_SIZE[0],
                0,
                (index + 1) * CELL_SIZE[0],
                CELL_SIZE[1],
            )
        )
        rendered = clear_transparent_rgb(cell.resize((width, height), RESAMPLE))
        draw._image.alpha_composite(rendered, (x, y + (1 if state == "pressed" else 0)))
        if hitbox:
            original_dashed(
                draw,
                (x - 1, y - 1, x + width, y + height),
                (232, 186, 81, 235),
                width=1,
                dash=3,
            )

    module.draw_seal = draw_runtime_seal


def provider_button_boxes(
    width: int,
    panel_height: int = 16,
) -> dict[str, tuple[int, int, int, int]]:
    size = panel_height - 2
    step = panel_height + 1
    return {
        "btnquest": (1, 1, 1 + size, 1 + size),
        "btndatabase": (1 + step, 1, 1 + step + size, 1 + size),
        "btngiver": (1 + step * 2, 1, 1 + step * 2 + size, 1 + size),
        "btnclose": (width - 1 - size, 1, width - 1, 1 + size),
        "btnsettings": (
            width - 1 - step - size,
            1,
            width - 1 - step,
            1 + size,
        ),
        "btnclean": (
            width - 1 - step * 2 - size,
            1,
            width - 1 - step * 2,
            1 + size,
        ),
        "btnsearch": (
            width - 1 - step * 3 - size,
            1,
            width - 1 - step * 3,
            1 + size,
        ),
    }


def intersection_area(
    first: tuple[int, int, int, int],
    second: tuple[int, int, int, int],
) -> int:
    width = max(0, min(first[2], second[2]) - max(first[0], second[0]))
    height = max(0, min(first[3], second[3]) - max(first[1], second[1]))
    return width * height


def overlay_provider_icons(
    image: Image.Image,
    module: Any,
    frame: tuple[int, int, int, int],
) -> None:
    x, y, width, _height = frame
    kinds = {
        "btnquest": "quests",
        "btndatabase": "database",
        "btngiver": "giver",
        "btnsearch": "search",
        "btnclean": "clean",
        "btnsettings": "settings",
        "btnclose": "close",
    }
    draw = ImageDraw.Draw(image, "RGBA")
    for name, box in provider_button_boxes(width).items():
        x0, y0, x1, y1 = box
        module.draw_provider_icon(
            draw,
            (x + x0, y + y0, x1 - x0, y1 - y0),
            kinds[name],
        )


def render_previews(atlas: Image.Image) -> None:
    module = load_simulation_module()
    install_runtime_seal_renderer(module, atlas)
    spec = json.loads(
        (ROOT / "tools" / "specs" / "quest_seals_simulation_v2.json").read_text(
            encoding="utf-8"
        )
    )
    spec["version"] = "QS-A1 V1.r4 accepted runtime"
    module.render_ingame(ROOT, spec, REAL_LAYOUT_PREVIEW)
    with Image.open(REAL_LAYOUT_PREVIEW) as opened:
        layout = opened.convert("RGBA")
    overlay_provider_icons(layout, module, tuple(spec["tracker"]["frame"]))
    save_png(layout, REAL_LAYOUT_PREVIEW)

    sheet = Image.new("RGBA", (1024, 620), (40, 30, 24, 255))
    fonts = module.build_fonts(ROOT, spec["inputs"])
    draw = ImageDraw.Draw(sheet, "RGBA")
    draw.text(
        (32, 24),
        "QS-A1 当前过渡 runtime · 旧七按钮保留在漆章之上",
        font=fonts["utility_large"],
        fill=(240, 208, 138, 255),
    )
    y = 94
    for width in spec["tracker"]["supported_widths"]:
        frame = (54, y, int(width), 96)
        module.draw_tracker(
            sheet,
            spec["tracker"],
            fonts,
            frame=frame,
            annotate=False,
            compact=True,
        )
        overlay_provider_icons(sheet, module, frame)
        draw.text(
            (410, y + 8),
            f"{width}px：34px 漆章，顶部 outset 18px；按钮仍可见可点",
            font=fonts["utility"],
            fill=(218, 185, 124, 255),
        )
        if int(width) == 130:
            draw.text(
                (410, y + 34),
                "最窄宽度 search 覆盖右下部，giver／clean 各触及 1px 边；功能迁移前保留。",
                font=fonts["utility"],
                fill=(207, 151, 105, 255),
            )
        y += 160
    save_png(sheet, WIDTH_PREVIEW)


def build_display_report(
    atlas: Image.Image,
    records: dict[str, dict[str, Any]],
) -> dict[str, Any]:
    spec = json.loads(DISPLAY_CONTRACT.read_text(encoding="utf-8"))
    module = load_simulation_module()
    quest_log = spec["quest_log"]
    ql_box = quest_log["texture_box_xywh"]
    shell_overlap = module.visible_shell_alpha_overlap(
        ROOT,
        quest_log["shell_runtime"],
        quest_log["frame"][0],
        quest_log["frame"][1],
        ql_box,
        8,
    )
    shared_alpha = len(
        {records[state]["alpha_sha256"] for state in STATE_ORDER}
    ) == 1
    tracker_reports = []
    for width in spec["tracker"]["supported_widths"]:
        seal = ((int(width) - 34) // 2, -18, (int(width) - 34) // 2 + 34, 16)
        overlaps = {
            name: intersection_area(seal, button)
            for name, button in provider_button_boxes(int(width)).items()
            if intersection_area(seal, button)
        }
        tracker_reports.append(
            {
                "width": int(width),
                "seal_box_xyxy": list(seal),
                "horizontally_centered": seal[0] * 2 + 34
                in (int(width), int(width) - 1),
                "bottom_aligns_with_list_start": seal[3] == 16,
                "overlaps_list_content": seal[3] > 16,
                "provider_visual_overlap_pixels": overlaps,
                "provider_interaction_takeover": False,
                "provider_buttons_remain_above_parent_artwork": True,
            }
        )
    adapter = (
        ROOT / "addon" / "AzerothExpeditionUI" / "Modules" / "Quests.lua"
    ).read_text(encoding="utf-8")
    checks = {
        "source_sha_matches_acceptance": sha256(SOURCE) == EXPECTED_SOURCE_SHA256,
        "atlas_size": atlas.size == ATLAS_SIZE,
        "all_states_share_alpha": shared_alpha,
        "all_cells_have_sampling_border": all(
            record["runtime_content_xyxy"][0]
            - record["runtime_cell_xyxy"][0]
            >= 2
            and record["runtime_cell_xyxy"][2]
            - record["runtime_content_xyxy"][2]
            >= 2
            and record["runtime_content_xyxy"][1] >= 2
            and CELL_SIZE[1] - record["runtime_content_xyxy"][3] >= 2
            for record in records.values()
        ),
        "quest_log_shell_alpha_overlap_pixels": shell_overlap,
        "quest_log_shell_alpha_overlap_pass": shell_overlap
        <= quest_log["shell_visible_alpha_overlap_max_pixels"],
        "tracker_geometry_pass": all(
            item["horizontally_centered"]
            and item["bottom_aligns_with_list_start"]
            and not item["overlaps_list_content"]
            for item in tracker_reports
        ),
        "tracker_texture_is_noninteractive": "CreateTexture(nil, \"ARTWORK\")"
        in adapter,
        "tracker_top_clamp_inset_is_implemented": "SetClampRectInsets"
        in adapter
        and "topOutset = 18" in adapter,
        "provider_buttons_are_not_hidden_by_adapter": all(
            f"{name}:Hide()" not in adapter
            for name in (
                "btnquest",
                "btndatabase",
                "btngiver",
                "btnsearch",
                "btnclean",
                "btnsettings",
                "btnclose",
            )
        ),
    }
    overall = "pass" if all(
        value if isinstance(value, bool) else value == 0
        for key, value in checks.items()
        if key != "quest_log_shell_alpha_overlap_pixels"
    ) else "fail"
    return {
        "schema": "aeui.quest-seal.runtime-display-region-report.v1",
        "component": "QS-A1",
        "status": overall,
        "contract": display_path(DISPLAY_CONTRACT),
        "checks": checks,
        "tracker_scenarios": tracker_reports,
        "transitional_layering_exception": (
            "At 130px the provider search icon overlaps the decorative seal and "
            "the giver/clean icons touch one 1px edge strip each. "
            "The icon remains visually and interactively authoritative above the "
            "parent ARTWORK Texture; no provider behavior is hidden. Final visual "
            "cleanup remains gated by QUEST.TRACKER.HUB.MENU functional parity."
        ),
        "target_client_pending": True,
    }


def source_manifest(
    source: Image.Image,
    records: dict[str, dict[str, Any]],
) -> dict[str, Any]:
    return {
        "schema_version": 1,
        "batch": "QS-A1",
        "version": "V1.r4",
        "status": "accepted-source",
        "accepted_on": "2026-07-31",
        "source": {
            "file": SOURCE.name,
            "sha256": sha256(SOURCE),
            "width": source.width,
            "height": source.height,
            "mode": source.mode,
            "visible_bbox_exclusive": list(visible_bbox(source) or ()),
            "visible_green_spill_pixels": green_spill_pixels(source),
            "transparent_rgb_nonzero_values": transparent_rgb_nonzero_values(source),
            **alpha_evidence(source),
        },
        "provenance": {
            "executor": "imagegen-0-143-0",
            "codex_package": "@openai/codex@0.143.0",
            "generation_session": "019fb766-ff17-7cb0-b175-0b8cd2464a76",
            "generation_before_commit": "e032522a5323f61c003fda277af5d3cd0ab13def",
            "raw_attempt": "generated/quests/QUEST-SEALS/QS-A1-V1/attempt-04/raw/QS-A1-V1.r4.png",
            "raw_attempt_sha256": RAW_ATTEMPT_SHA256,
            "accepted_candidate": "generated/quests/QUEST-SEALS/QS-A1-V1/attempt-04/review/QS-A1-V1.r4.normalized-review.png",
            "accepted_candidate_sha256": ACCEPTED_CANDIDATE_SHA256,
            "prompt": "docs/modules/quests/work/QUEST.SEALS.md",
            "prompt_sections": [
                "最终执行正文 — QS-A1 V1",
                "修复执行正文 — QS-A1 V1.r4",
            ],
            "visual_references": [
                "assets/locked/quests/任务详情面板_视觉基准_v1.png",
                "assets/locked/quests/任务追踪面板_视觉基准_v1.png",
            ],
            "deterministic_derivation": (
                "review_quest_seal_candidate_v1.py chroma_key, fully transparent "
                "RGB zeroing, visible-bbox proportional fit to 640px and centering "
                "on a 1024x1024 transparent canvas; then clear 58 LANCZOS-only "
                "chroma-fringe pixels: 32 pure-green pixels at Alpha 1..4 and "
                "26 residual green-dominant pixels at Alpha 3..19"
            ),
        },
        "user_acceptance": {
            "statement": (
                "接受 QS-A1 V1.r4 的运行时视觉，并授权确定性色键、透明 RGB "
                "清零及 1024² 归一化例外进入 P4/P5。"
            ),
            "scope": [
                "accept the V1.r4 runtime appearance and connected wax spread",
                "promote the deterministic 1024x1024 transparent normalization",
                "derive normal, hover, pressed and disabled RGB states from one Alpha",
                "export and integrate without further image generation calls",
            ],
            "historical_failures_not_rewritten": [
                "raw provider output remained 1254x1254 RGB",
                "raw provider background was gradient green rather than exact #00FF00",
            ],
        },
        "logical_components": [
            {
                "id": "QUEST.LOG.CHROME.SEAL",
                "runtime_object": "QuestLogFrame adapter-owned Texture",
                "box_xywh": [600, -18, 28, 28],
                "visible_content_goal": [26, 26],
                "mouse": False,
            },
            {
                "id": "QUEST.TRACKER.HUB.SEAL",
                "runtime_object": "pfQuestMapTracker adapter-owned Texture",
                "box_formula": "x=floor((W-34)/2), y=-18, 34x34",
                "visible_content_goal": [32, 32],
                "mouse": False,
            },
        ],
        "review": {
            "runtime_visual_accepted": True,
            "single_base_object": True,
            "connected_wax_spread": True,
            "small_size_legibility": True,
            "baked_text": False,
            "baked_buttons": False,
            "baked_quest_state": False,
            "display_region_review_before_acceptance": "pass",
        },
        "export_contract": {
            "status": "runtime-exported",
            "operation": (
                "crop accepted Alpha bbox, proportional LANCZOS scale once, center "
                "the shared sprite in four 64x64 cells, derive RGB-only states, "
                "clear resampling-only green fringe, zero transparent RGB and write "
                "one 256x64 RGBA TGA"
            ),
            "runtime_atlas_size": list(ATLAS_SIZE),
            "runtime_cell_size": list(CELL_SIZE),
            "runtime_cell_order": list(STATE_ORDER),
            "runtime_visible_size": records["normal"]["runtime_visible_size"],
            "allowed": [
                "crop only the accepted visible Alpha bbox",
                "proportional resize to at most 60x60 visible pixels",
                "center the same Alpha in each fixed cell",
                "apply the declared RGB-only state transforms",
                "zero RGB only where Alpha is fully transparent",
            ],
            "forbidden_runtime_uses": [
                "load the 1024x1024 source directly in the client",
                "redraw, rotate, mirror, stretch or change the state silhouette",
                "hide or disable the seven provider toolbar Buttons before hub parity",
                "give either current Texture a click region",
                "use the tool seal as complete or failed quest state",
            ],
        },
        "runtime_exports": [
            {
                "contract": "QS-A1 V1.r4 / 1.0",
                "manifest": RUNTIME_MANIFEST.name,
                "file": display_path(RUNTIME),
                "sha256": sha256(RUNTIME),
                "atlas_size": list(ATLAS_SIZE),
                "cell_size": list(CELL_SIZE),
            }
        ],
    }


def runtime_manifest(
    source: Image.Image,
    atlas: Image.Image,
    records: dict[str, dict[str, Any]],
    display_report: dict[str, Any],
) -> dict[str, Any]:
    return {
        "schema_version": 1,
        "batch": "QS-A1",
        "version": "V1.r4",
        "runtime_contract": "1.0",
        "status": "runtime-exported",
        "source": {
            "file": display_path(SOURCE),
            "sha256": sha256(SOURCE),
            "width": source.width,
            "height": source.height,
            "mode": source.mode,
            "visible_bbox_exclusive": list(visible_bbox(source) or ()),
            "visible_green_spill_pixels": green_spill_pixels(source),
            **alpha_evidence(source),
        },
        "transform": {
            "operation": (
                "accepted Alpha bbox crop, one proportional LANCZOS scale, four "
                "deterministic RGB-only state transforms, fixed-cell centering, "
                "resampling-green cleanup, transparent RGB zeroing and TGA conversion"
            ),
            "source_crop_xyxy": list(EXPECTED_SOURCE_BBOX),
            "resample": "Pillow Image.Resampling.LANCZOS",
            "alpha_cleanup": "zero RGB only where Alpha equals 0",
            "rotation": None,
            "mirror": False,
            "retouch": False,
            "atlas_size": list(ATLAS_SIZE),
            "cell_size": list(CELL_SIZE),
            "state_order": list(STATE_ORDER),
            "states": records,
        },
        "runtime": {
            "file": display_path(RUNTIME),
            "sha256": sha256(RUNTIME),
            "width": atlas.width,
            "height": atlas.height,
            "mode": atlas.mode,
            "tga_header": tga_header(RUNTIME),
            "visible_bbox_exclusive": list(visible_bbox(atlas) or ()),
            "visible_green_spill_pixels": green_spill_pixels(atlas),
            "transparent_rgb_nonzero_values": transparent_rgb_nonzero_values(atlas),
            **alpha_evidence(atlas),
        },
        "layout_contract": {
            "quest_log": {
                "object": "QuestLogFrame.aeuiQuestChromeSeal",
                "box_xywh": [600, -18, 28, 28],
                "texcoord_state": "normal full 64x64 cell",
                "visible_content_goal": [26, 26],
                "mouse": False,
            },
            "tracker": {
                "object": "pfQuestMapTracker.aeuiQuestHubSeal",
                "box_formula": "TOP to TOP, x=0, y=18, 34x34",
                "visible_content_goal": [32, 32],
                "top_clamp_inset": 18,
                "mouse": False,
                "provider_toolbar": "visible and functional until hub-menu parity",
            },
        },
        "display_region": {
            "status": display_report["status"],
            "contract": display_path(DISPLAY_CONTRACT),
            "report": display_path(DISPLAY_REPORT),
            "report_sha256": sha256(DISPLAY_REPORT),
            "scenarios": ["QuestLogFrame", "tracker-130", "tracker-230", "tracker-330"],
            "transitional_provider_overlap": (
                "tracker-130 search icon overlap plus 1px giver/clean edge strips; "
                "all provider controls remain above the decorative seal"
            ),
        },
        "simulation": {
            "atlas_preview": {
                "file": display_path(ATLAS_PREVIEW),
                "sha256": sha256(ATLAS_PREVIEW),
                "size": list(atlas.size),
            },
            "real_layout_preview": {
                "file": display_path(REAL_LAYOUT_PREVIEW),
                "sha256": sha256(REAL_LAYOUT_PREVIEW),
                "size": [1536, 1024],
                "provider_buttons": "drawn above the current decorative tracker Texture",
            },
            "tracker_width_preview": {
                "file": display_path(WIDTH_PREVIEW),
                "sha256": sha256(WIDTH_PREVIEW),
                "supported_widths": [130, 230, 330],
            },
        },
        "ownership": {
            "quest_log": "adapter-owned non-interactive OVERLAY Texture",
            "tracker": "adapter-owned non-interactive ARTWORK Texture",
            "future_states": "atlas retained for a separately authorized Button upgrade",
            "provider_buttons": "pfQuest retains objects, scripts, tooltips, mouse and visibility",
        },
        "implementation": {
            "exporter": display_path(Path(__file__)),
            "adapter": "addon/AzerothExpeditionUI/Modules/Quests.lua",
            "source_manifest": display_path(SOURCE_MANIFEST),
            "imagegen_calls_after_acceptance": 0,
            "static_tests_required": True,
            "game_validated": False,
        },
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--source-manifest", type=Path, default=SOURCE_MANIFEST)
    parser.add_argument("--runtime", type=Path, default=RUNTIME)
    parser.add_argument("--runtime-manifest", type=Path, default=RUNTIME_MANIFEST)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    with Image.open(args.source) as opened:
        source = opened.convert("RGBA")
    validate_source(args.source, source)
    atlas, records = build_atlas(source)
    save_tga(atlas, args.runtime)
    save_png(atlas, ATLAS_PREVIEW)

    header = tga_header(args.runtime)
    if (
        header["image_type"] != 2
        or (header["width"], header["height"]) != ATLAS_SIZE
        or header["bits_per_pixel"] != 32
    ):
        raise ValueError(f"unexpected runtime TGA header: {header}")
    if transparent_rgb_nonzero_values(atlas) or green_spill_pixels(atlas):
        raise ValueError("runtime atlas failed Alpha/RGB cleanup")

    render_previews(atlas)
    report = build_display_report(atlas, records)
    DISPLAY_REPORT.parent.mkdir(parents=True, exist_ok=True)
    DISPLAY_REPORT.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    if report["status"] != "pass":
        raise ValueError("QS-A1 final display-region report failed")

    args.source_manifest.write_text(
        json.dumps(source_manifest(source, records), ensure_ascii=False, indent=2)
        + "\n",
        encoding="utf-8",
    )
    args.runtime_manifest.write_text(
        json.dumps(
            runtime_manifest(source, atlas, records, report),
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(json.dumps({
        "source": sha256(args.source),
        "runtime": sha256(args.runtime),
        "display_report": sha256(DISPLAY_REPORT),
        "status": report["status"],
    }, ensure_ascii=False))


if __name__ == "__main__":
    main()
