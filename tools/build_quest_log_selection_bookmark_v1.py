#!/usr/bin/env python3
"""Build the accepted QL-B2 selection atlas and real-layout previews.

The accepted 1024 x 1024 source is immutable. This exporter crops only its
visible Alpha bounds, scales the object proportionally to 24 x 14 pixels,
derives hover and pressed RGB with the accepted fixed formulas, preserves
pixel-identical Alpha, and places the three states plus one transparent
reserved cell in a 128 x 16 RGBA TGA.

The three review images are rendered from the exported atlas at the exact
Quest Log row geometry. They therefore exercise the same padding, UV cells,
z-order, and pressed anchor offset used by the Lua adapter.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import struct
from fractions import Fraction
from pathlib import Path
from typing import Any, Callable

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (
    ROOT
    / "assets"
    / "source"
    / "quests"
    / "ql-b2"
    / "QuestLogSelectionBookmark_Master_v1.png"
)
SOURCE_MANIFEST = SOURCE.with_name("QL-B2_SourceManifest_v1.json")
RUNTIME = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestLogSelectionBookmarkV1.tga"
)
RUNTIME_MANIFEST = SOURCE.with_name("QL-B2_RuntimeManifest_v1.json")
PREVIEW_DIR = (
    ROOT
    / "generated"
    / "quests"
    / "QL-B2"
    / "v1"
    / "accepted"
    / "previews"
)
ATLAS_PREVIEW = (
    PREVIEW_DIR / "QL-B2_V1_r4_bboxfit_runtime_atlas.png"
)
REAL_LAYOUT_PREVIEWS = {
    "selected": (
        PREVIEW_DIR / "QL-B2_V1_r4_bboxfit_selected_676x464.png"
    ),
    "selected-hover": (
        PREVIEW_DIR / "QL-B2_V1_r4_bboxfit_selected-hover_676x464.png"
    ),
    "selected-pressed": (
        PREVIEW_DIR / "QL-B2_V1_r4_bboxfit_selected-pressed_676x464.png"
    ),
}
QL_B1_BUILDER = ROOT / "tools" / "build_quest_log_directory_marks_v1.py"
B1_ATLAS = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestLogDirectoryMarksV1.tga"
)
B1_MANIFEST = (
    ROOT
    / "assets"
    / "source"
    / "quests"
    / "ql-b1"
    / "QL-B1_RuntimeManifest_v1.json"
)

EXPECTED_SOURCE_SHA256 = (
    "4f8955410ecfaac6697cabeb9bd076d4bd0f5b5adcc97964cee0b7b49d38efaa"
)
EXPECTED_SOURCE_SIZE = (1024, 1024)
EXPECTED_SOURCE_BBOX = (336, 413, 688, 611)
ATLAS_SIZE = (128, 16)
CELL_SIZE = (32, 16)
CONTENT_SIZE = (24, 14)
CONTENT_OFFSET = (4, 1)
STATE_ORDER = (
    "selected",
    "selected-hover",
    "selected-pressed",
    "reserved-transparent",
)
SELECTED_ROW = 7
RESAMPLE = Image.Resampling.LANCZOS


def load_ql_b1_builder() -> Any:
    """Load the repository builder without colliding with a site-package."""
    spec = importlib.util.spec_from_file_location(
        "aeui_ql_b1_builder",
        QL_B1_BUILDER,
    )
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load QL-B1 builder: {QL_B1_BUILDER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
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


def validate_source(path: Path, image: Image.Image) -> None:
    if sha256(path) != EXPECTED_SOURCE_SHA256:
        raise ValueError("QL-B2 source SHA-256 does not match the accepted asset")
    if image.size != EXPECTED_SOURCE_SIZE:
        raise ValueError(
            f"QL-B2 source must be {EXPECTED_SOURCE_SIZE}, got {image.size}"
        )
    if image.mode != "RGBA":
        raise ValueError(f"QL-B2 source must be RGBA, got {image.mode}")
    if image.getchannel("A").getbbox() != EXPECTED_SOURCE_BBOX:
        raise ValueError(
            "QL-B2 source visible bounds do not match the accepted bbox-fit asset"
        )
    if green_spill_pixels(image):
        raise ValueError("QL-B2 source contains visible chroma-key green")


def scale_source(image: Image.Image) -> Image.Image:
    bounds = image.getchannel("A").getbbox()
    if not bounds:
        raise ValueError("QL-B2 source has no visible pixels")
    visible = clear_transparent_rgb(image.crop(bounds))
    ratio = min(
        Fraction(CONTENT_SIZE[0], visible.width),
        Fraction(CONTENT_SIZE[1], visible.height),
    )

    def round_half_up(value: Fraction) -> int:
        return (value.numerator * 2 + value.denominator) // (
            value.denominator * 2
        )

    size = (
        max(1, round_half_up(visible.width * ratio)),
        max(1, round_half_up(visible.height * ratio)),
    )
    if size != CONTENT_SIZE:
        raise ValueError(
            f"accepted QL-B2 source must export to {CONTENT_SIZE}, got {size}"
        )
    return clear_transparent_rgb(visible.resize(size, RESAMPLE))


def selected_rgb(red: int, green: int, blue: int) -> tuple[int, int, int]:
    return red, green, blue


def hover_rgb(red: int, green: int, blue: int) -> tuple[int, int, int]:
    return (
        min(255, round(red * 1.07 + 2)),
        min(255, round(green * 1.04 + 1)),
        round(blue * 0.96),
    )


def pressed_rgb(red: int, green: int, blue: int) -> tuple[int, int, int]:
    return (
        round(red * 0.82),
        round(green * 0.80),
        round(blue * 0.78),
    )


def derive_state(
    base: Image.Image,
    transform: Callable[[int, int, int], tuple[int, int, int]],
) -> Image.Image:
    output = base.copy()
    pixels = output.load()
    for y in range(output.height):
        for x in range(output.width):
            red, green, blue, alpha = pixels[x, y]
            if alpha == 0:
                pixels[x, y] = (0, 0, 0, 0)
            else:
                out_red, out_green, out_blue = transform(red, green, blue)
                pixels[x, y] = (
                    out_red,
                    out_green,
                    out_blue,
                    alpha,
                )
    return clear_transparent_rgb(output)


def build_atlas(
    source: Image.Image,
) -> tuple[Image.Image, dict[str, dict[str, Any]]]:
    base = scale_source(source)
    sprites = {
        "selected": derive_state(base, selected_rgb),
        "selected-hover": derive_state(base, hover_rgb),
        "selected-pressed": derive_state(base, pressed_rgb),
    }
    alpha_bytes = sprites["selected"].getchannel("A").tobytes()
    for state in ("selected-hover", "selected-pressed"):
        if sprites[state].getchannel("A").tobytes() != alpha_bytes:
            raise ValueError(f"{state} Alpha differs from selected")

    atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
    records: dict[str, dict[str, Any]] = {}
    for index, state in enumerate(STATE_ORDER):
        cell_left = index * CELL_SIZE[0]
        cell_box = (
            cell_left,
            0,
            cell_left + CELL_SIZE[0],
            CELL_SIZE[1],
        )
        content_box = (
            cell_left + CONTENT_OFFSET[0],
            CONTENT_OFFSET[1],
            cell_left + CONTENT_OFFSET[0] + CONTENT_SIZE[0],
            CONTENT_OFFSET[1] + CONTENT_SIZE[1],
        )
        if state != "reserved-transparent":
            atlas.alpha_composite(
                sprites[state],
                (content_box[0], content_box[1]),
            )
        records[state] = {
            "component": (
                "QUEST.LOG.SELECTION"
                if state != "reserved-transparent"
                else None
            ),
            "runtime_cell_xyxy": list(cell_box),
            "runtime_content_xyxy": list(content_box),
            "runtime_display_size": (
                list(CONTENT_SIZE)
                if state != "reserved-transparent"
                else [0, 0]
            ),
            "texcoord": {
                "left": cell_box[0] / ATLAS_SIZE[0],
                "right": cell_box[2] / ATLAS_SIZE[0],
                "top": 0.0,
                "bottom": 1.0,
            },
            "content_texcoord": {
                "left": content_box[0] / ATLAS_SIZE[0],
                "right": content_box[2] / ATLAS_SIZE[0],
                "top": content_box[1] / ATLAS_SIZE[1],
                "bottom": content_box[3] / ATLAS_SIZE[1],
            },
        }

    atlas = clear_transparent_rgb(atlas)
    reserved = atlas.crop(tuple(records["reserved-transparent"][
        "runtime_cell_xyxy"
    ]))
    if reserved.getbbox() is not None:
        raise ValueError("QL-B2 reserved atlas cell is not fully transparent")
    return atlas, records


def load_b1_runtime() -> tuple[Image.Image, dict[str, dict[str, Any]]]:
    with Image.open(B1_ATLAS) as opened:
        atlas = opened.convert("RGBA")
    manifest = json.loads(B1_MANIFEST.read_text(encoding="utf-8"))
    return atlas, manifest["transform"]["states"]


def paste_b1_sprite(
    preview: Image.Image,
    atlas: Image.Image,
    record: dict[str, Any],
    xy: tuple[int, int],
) -> None:
    sprite = atlas.crop(tuple(record["runtime_content_xyxy"]))
    preview.alpha_composite(sprite, xy)


def state_cell(
    atlas: Image.Image,
    record: dict[str, Any],
) -> Image.Image:
    return atlas.crop(tuple(record["runtime_cell_xyxy"]))


def render_real_layout_preview(
    state: str,
    atlas: Image.Image,
    records: dict[str, dict[str, Any]],
) -> Image.Image:
    ql_b1 = load_ql_b1_builder()
    with Image.open(ql_b1.SHELL_RUNTIME) as opened:
        shell_atlas = opened.convert("RGBA")
    preview = shell_atlas.crop((0, 0, *ql_b1.SHELL_DISPLAY_SIZE))
    b1_atlas, b1_records = load_b1_runtime()
    draw = ImageDraw.Draw(preview, "RGBA")
    title_font = ql_b1.font(ql_b1.TITLE_FONT, 15)
    row_font = ql_b1.font(ql_b1.ROW_FONT, 10)
    row_header_font = ql_b1.font(ql_b1.ROW_FONT, 11)
    body_font = ql_b1.font(ql_b1.BODY_FONT, 9)
    body_heading_font = ql_b1.font(ql_b1.TITLE_FONT, 11)

    ql_b1.draw_text(
        draw,
        (300, 27),
        "任务日志",
        title_font,
        (49, 26, 16, 255),
    )
    ql_b1.draw_text(
        draw,
        (76, 49),
        "任务  18 / 20",
        row_font,
        (76, 43, 25, 235),
    )

    bookmark = state_cell(atlas, records[state])
    for index, (kind, label, tracked) in enumerate(ql_b1.QUEST_ROWS):
        row_x = ql_b1.LIST_ORIGIN[0]
        row_y = ql_b1.LIST_ORIGIN[1] + index * ql_b1.ROW_STEP

        if index == SELECTED_ROW:
            # A 32 x 16 Texture is centered on the 224 x 15 row. The visible
            # sprite begins at x=-8 after 4 px left padding. In raster space,
            # the runtime y=-1 pressed anchor moves the Texture down by 1 px.
            texture_y = row_y - 1
            if state == "selected-pressed":
                texture_y += 1
            preview.alpha_composite(bookmark, (row_x - 12, texture_y))

        if kind == "header-expanded":
            paste_b1_sprite(
                preview,
                b1_atlas,
                b1_records["expanded"],
                (row_x + 1, row_y + 1),
            )
            ql_b1.draw_text(
                draw,
                (row_x + 16, row_y + 1),
                label,
                row_header_font,
                (72, 38, 19, 255),
            )
        elif kind == "header-collapsed":
            paste_b1_sprite(
                preview,
                b1_atlas,
                b1_records["collapsed"],
                (row_x + 1, row_y + 1),
            )
            ql_b1.draw_text(
                draw,
                (row_x + 16, row_y + 1),
                label,
                row_header_font,
                (72, 38, 19, 255),
            )
        else:
            mark = "tracked" if tracked else "untracked"
            paste_b1_sprite(
                preview,
                b1_atlas,
                b1_records[mark],
                (row_x + ql_b1.ROW_BOX[0] - 12, row_y + 2),
            )
            row_color = (
                (57, 30, 19, 255)
                if index == SELECTED_ROW
                else (
                    (62, 39, 23, 255)
                    if tracked
                    else (89, 61, 38, 235)
                )
            )
            ql_b1.draw_text(
                draw,
                (row_x + 18, row_y + 2),
                label,
                row_font,
                row_color,
            )

    detail_left = 374
    detail_width = 226
    ql_b1.draw_text(
        draw,
        (detail_left, 68),
        "达基萨斯将军之死",
        title_font,
        (55, 28, 17, 255),
    )
    ql_b1.draw_text(
        draw,
        (detail_left, 91),
        "黑石塔上层",
        row_font,
        (105, 57, 28, 235),
    )
    description = (
        "深入黑石塔上层，击败达基萨斯将军，并将他的首级带回暴风城。"
        "这份远征卷宗经过反复翻阅，边缘仍留有旧日战火的痕迹。"
    )
    y = 111
    for line in ql_b1.wrap_text(
        draw,
        description,
        body_font,
        detail_width,
    ):
        ql_b1.draw_text(
            draw,
            (detail_left, y),
            line,
            body_font,
            (69, 48, 31, 245),
        )
        y += 13
    y += 5
    ql_b1.draw_text(
        draw,
        (detail_left, y),
        "任务目标",
        body_heading_font,
        (64, 31, 18, 255),
    )
    y += 19
    for line in (
        "• 达基萨斯将军的首级  0 / 1",
        "• 返回暴风城复命",
        "• 小队成员必须存活",
    ):
        ql_b1.draw_text(
            draw,
            (detail_left, y),
            line,
            body_font,
            (74, 49, 31, 245),
        )
        y += 14
    y += 5
    ql_b1.draw_text(
        draw,
        (detail_left, y),
        "奖励",
        body_heading_font,
        (64, 31, 18, 255),
    )
    y += 19
    ql_b1.draw_text(
        draw,
        (detail_left, y),
        "你将获得：  9 金  80 银",
        body_font,
        (74, 49, 31, 245),
    )

    # QL-C controls remain the current non-authoritative fallback.
    for x, label in ((62, "放弃任务"), (145, "共享任务"), (228, "退出")):
        draw.rounded_rectangle(
            (x, 421, x + 78, 441),
            radius=3,
            fill=(51, 34, 25, 220),
            outline=(116, 78, 44, 235),
            width=1,
        )
        bounds = draw.textbbox((0, 0), label, font=row_font)
        ql_b1.draw_text(
            draw,
            (x + (78 - (bounds[2] - bounds[0])) // 2, 425),
            label,
            row_font,
            (225, 184, 108, 255),
        )
    ql_b1.draw_text(
        draw,
        (314, 425),
        "›",
        title_font,
        (82, 47, 27, 255),
    )
    return preview


def save_png(image: Image.Image, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, format="PNG", optimize=True)


def save_tga(image: Image.Image, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, format="TGA")


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


def update_source_manifest(
    path: Path,
    runtime_manifest: Path,
    runtime_path: Path,
) -> None:
    manifest = json.loads(path.read_text(encoding="utf-8"))
    manifest["export_contract"]["status"] = "runtime-exported"
    manifest["runtime_exports"] = [
        {
            "contract": "QL-B2 V1.r4-bbox-fit / 1.0",
            "manifest": runtime_manifest.name,
            "file": display_path(runtime_path),
            "sha256": sha256(runtime_path),
            "atlas_size": list(ATLAS_SIZE),
            "cell_size": list(CELL_SIZE),
            "content_size": list(CONTENT_SIZE),
        }
    ]
    path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--source-manifest", type=Path, default=SOURCE_MANIFEST)
    parser.add_argument("--runtime", type=Path, default=RUNTIME)
    parser.add_argument("--manifest", type=Path, default=RUNTIME_MANIFEST)
    parser.add_argument("--atlas-preview", type=Path, default=ATLAS_PREVIEW)
    parser.add_argument(
        "--preview-dir",
        type=Path,
        default=PREVIEW_DIR,
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    with Image.open(args.source) as opened:
        source = opened.convert("RGBA")
    validate_source(args.source, source)
    atlas, records = build_atlas(source)
    save_tga(atlas, args.runtime)
    save_png(atlas, args.atlas_preview)

    preview_paths = {
        state: args.preview_dir / path.name
        for state, path in REAL_LAYOUT_PREVIEWS.items()
    }
    previews: dict[str, Image.Image] = {}
    for state in ("selected", "selected-hover", "selected-pressed"):
        previews[state] = render_real_layout_preview(state, atlas, records)
        save_png(previews[state], preview_paths[state])

    header = tga_header(args.runtime)
    if (
        header["image_type"] != 2
        or (header["width"], header["height"]) != ATLAS_SIZE
        or header["bits_per_pixel"] != 32
    ):
        raise ValueError(f"unexpected runtime TGA header: {header}")

    state_alpha_hashes = {}
    for state in ("selected", "selected-hover", "selected-pressed"):
        cell = state_cell(atlas, records[state])
        state_alpha_hashes[state] = hashlib.sha256(
            cell.getchannel("A").tobytes()
        ).hexdigest()
    if len(set(state_alpha_hashes.values())) != 1:
        raise ValueError("exported QL-B2 state-cell Alpha hashes differ")

    manifest = {
        "schema_version": 1,
        "batch": "QL-B2",
        "version": "V1.r4-bbox-fit",
        "runtime_contract": "1.0",
        "status": "runtime-exported",
        "source": {
            "file": display_path(args.source),
            "sha256": sha256(args.source),
            "width": source.width,
            "height": source.height,
            "mode": source.mode,
            "visible_bbox_exclusive": visible_bbox(source),
            "visible_green_spill_pixels": green_spill_pixels(source),
            **alpha_evidence(source),
        },
        "transform": {
            "operation": (
                "visible-alpha-bounds crop, proportional LANCZOS scale to "
                "24 x 14, fixed selected-hover and selected-pressed RGB "
                "derivation, centering in 32 x 16 cells and transparent "
                "atlas assembly"
            ),
            "resample": "Pillow Image.Resampling.LANCZOS",
            "alpha_cleanup": (
                "zero RGB only where alpha is fully transparent; preserve "
                "pixel-identical alpha for all three visible states"
            ),
            "rotation": None,
            "mirror": False,
            "stretch": False,
            "retouch": False,
            "atlas_size": list(ATLAS_SIZE),
            "cell_size": list(CELL_SIZE),
            "content_size": list(CONTENT_SIZE),
            "content_offset": list(CONTENT_OFFSET),
            "state_order": list(STATE_ORDER),
            "hover_rgb": {
                "red": "min(255, round(R * 1.07 + 2))",
                "green": "min(255, round(G * 1.04 + 1))",
                "blue": "round(B * 0.96)",
            },
            "pressed_rgb": {
                "red": "round(R * 0.82)",
                "green": "round(G * 0.80)",
                "blue": "round(B * 0.78)",
            },
            "state_alpha_sha256": state_alpha_hashes,
            "state_alpha_identical": True,
            "states": records,
        },
        "runtime": {
            "file": display_path(args.runtime),
            "sha256": sha256(args.runtime),
            "width": atlas.width,
            "height": atlas.height,
            "mode": atlas.mode,
            "tga_header": header,
            "visible_bbox_exclusive": visible_bbox(atlas),
            "visible_green_spill_pixels": green_spill_pixels(atlas),
            **alpha_evidence(atlas),
        },
        "simulation": {
            "atlas_preview": {
                "file": display_path(args.atlas_preview),
                "sha256": sha256(args.atlas_preview),
                "size": list(atlas.size),
            },
            "real_layout_previews": {
                state: {
                    "file": display_path(preview_paths[state]),
                    "sha256": sha256(preview_paths[state]),
                    "size": list(previews[state].size),
                    "runtime_scale_percent": 100,
                }
                for state in (
                    "selected",
                    "selected-hover",
                    "selected-pressed",
                )
            },
            "shared_contract": {
                "shell": display_path(
                    load_ql_b1_builder().SHELL_RUNTIME
                ),
                "row_count": 23,
                "row_box": [224, 15],
                "row_step": 14,
                "list_origin": [64, 64],
                "selected_visible_row": 8,
                "content": (
                    "representative localized quest titles, levels, headers, "
                    "tracking states and right-page text at realistic density"
                ),
                "z_order": [
                    "QL-A2 accepted runtime shell",
                    "QL-B2 accepted runtime bookmark",
                    "QL-B1 accepted runtime marks",
                    "runtime-localized text",
                    "simplified placeholders for pending QL-C controls",
                ],
                "authoritative_for": [
                    "QL-B2 target-size state legibility",
                    "actual atlas cell padding and adapter anchor geometry",
                    "23-row density, text safe area and z-order review",
                ],
                "not_authoritative_for": [
                    "pending QL-B3, QL-C or QL-D artwork",
                    "Turtle WoW rendering, filtering, hit regions or font loading",
                ],
            },
        },
        "layout_contract": {
            "row_objects": "QuestLogTitle1..23",
            "row_count": 23,
            "row_box": [224, 15],
            "row_step": 14,
            "selection_texture_size": list(CELL_SIZE),
            "selection_visible_size": list(CONTENT_SIZE),
            "selection_anchor": {
                "point": "LEFT",
                "relative_point": "LEFT",
                "x": -12,
                "selected_y": 0,
                "hover_y": 0,
                "pressed_y": -1,
            },
            "visible_row_local_x_inclusive": [-8, 15],
            "dynamic_text_safe_x_min": 18,
            "draw_layer": "BORDER",
        },
        "state_mapping": {
            "quest_index": (
                "visible row id + FauxScrollFrame_GetOffset("
                "QuestLogListScrollFrame)"
            ),
            "selected_index": "GetQuestLogSelection()",
            "unselected": "hide QL-B2 Texture",
            "selected": (
                "matching visible non-header row without hover or left press"
            ),
            "selected-hover": (
                "matching visible non-header row with appended OnEnter state"
            ),
            "selected-pressed": (
                "matching visible non-header row while left button is down"
            ),
        },
        "ownership": {
            "row_button": (
                "QuestLogTitleN retains its hit region and all original scripts"
            ),
            "selection": (
                "non-interactive BORDER Texture attached to QuestLogTitleN; "
                "at most one visible non-header row"
            ),
            "hover_and_press": (
                "adapter appends state refresh after original row scripts; "
                "pressed movement is an anchor-only y=-1 offset"
            ),
            "fallback": (
                "missing API, source/runtime media, invisible selection or "
                "header selection hides the overlay and preserves native "
                "selection, click, scroll and SavedVariables behavior"
            ),
        },
        "implementation": {
            "exporter": display_path(Path(__file__)),
            "adapter": "addon/AzerothExpeditionUI/Modules/Quests.lua",
            "source_manifest": display_path(args.source_manifest),
            "imagegen_calls_after_acceptance": 0,
            "static_tests_required": True,
            "game_validated": False,
        },
    }
    args.manifest.parent.mkdir(parents=True, exist_ok=True)
    args.manifest.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    update_source_manifest(
        args.source_manifest,
        args.manifest,
        args.runtime,
    )
    print(json.dumps(manifest, ensure_ascii=False))


if __name__ == "__main__":
    main()
