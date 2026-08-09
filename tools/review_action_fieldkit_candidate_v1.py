#!/usr/bin/env python3
"""Review AB.TRINKET.KIT.V1 or AB.CONSUMABLE.KIT.V1 candidates.

The provider output is always kept untouched.  Legacy opaque checkerboard raws
may still be normalized for failure inspection.  For the authorized chroma
transport amendment, this reviewer instead consumes an exact canonical RGBA
atlas plus its deterministic provenance report.  Neither path promotes pixels
to source or runtime.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
from pathlib import Path
from typing import Any, Callable

from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageOps, ImageStat

import render_action_fieldkit_simulation as simulation
import render_action_bars_simulation as core


CELL_BOXES = {
    "A": (0, 0, 512, 512),
    "B": (512, 0, 1024, 512),
    "C": (0, 512, 512, 1024),
    "D": (512, 512, 1024, 1024),
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--component", required=True, choices=("trinket", "consumable"))
    parser.add_argument("--raw", required=True, type=Path)
    parser.add_argument("--canonical", type=Path)
    parser.add_argument("--canonicalization-report", type=Path)
    parser.add_argument("--spec", required=True, type=Path)
    parser.add_argument("--display-template", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    return parser.parse_args()


def resolve(root: Path, value: str | Path) -> Path:
    path = Path(value)
    return path if path.is_absolute() else root / path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def transparent_rgb_nonzero(image: Image.Image) -> int:
    count = 0
    for red, green, blue, alpha in image.convert("RGBA").getdata():
        if alpha == 0 and (red != 0 or green != 0 or blue != 0):
            count += 1
    return count


def validate_canonical_provenance(
    report: dict[str, Any],
    *,
    component_name: str,
    attempt: str,
    raw_path: Path,
    canonical_path: Path,
) -> None:
    if report.get("schema") != "aeui-action-fieldkit-canonicalization-v1":
        raise ValueError("unexpected Field Kit canonicalization report schema")
    if report.get("component") != component_name:
        raise ValueError("canonicalization component does not match review component")
    if report.get("attempt") != attempt:
        raise ValueError("canonicalization attempt does not match review attempt")
    if report.get("status") != "pass":
        raise ValueError("canonicalization report did not pass")
    if report.get("raw", {}).get("sha256") != sha256(raw_path):
        raise ValueError("canonicalization raw SHA does not match review raw")
    if report.get("canonical", {}).get("sha256") != sha256(canonical_path):
        raise ValueError("canonicalization canonical SHA does not match review input")


def bbox_or_empty(image: Image.Image) -> tuple[int, int, int, int]:
    return image.getchannel("A").getbbox() or (0, 0, 0, 0)


def derive_review_rgba(raw: Image.Image) -> tuple[Image.Image, dict[str, Any]]:
    """Normalize to 1024 RGBA without claiming that the raw provider output passed."""

    source_has_alpha = "A" in raw.getbands()
    rgba = raw.convert("RGBA")
    alpha_extrema = rgba.getchannel("A").getextrema()
    usable_alpha = source_has_alpha and alpha_extrema[0] == 0 and alpha_extrema[1] > 0
    if usable_alpha:
        derived = rgba
        method = "provider alpha"
    else:
        rgb = raw.convert("RGB")
        gray = ImageOps.grayscale(rgb)
        # ImageGen commonly renders a 238/255 checkerboard.  The strict raw
        # contract still fails; this conservative threshold exists only so the
        # object can be placed into review scenes without painting the checker.
        mask = gray.point(lambda value: 255 if value < 226 else 0, mode="L")
        derived = rgb.convert("RGBA")
        derived.putalpha(mask)
        method = "review-only light-checker threshold (luma < 226)"

    original_size = derived.size
    if derived.size != (1024, 1024):
        derived = derived.resize((1024, 1024), Image.Resampling.LANCZOS)
        method += "; whole-canvas LANCZOS normalization to 1024"
    return derived, {
        "source_has_alpha_channel": source_has_alpha,
        "source_alpha_extrema": list(alpha_extrema),
        "source_has_usable_transparency": usable_alpha,
        "source_size": list(original_size),
        "method": method,
        "review_only": True,
    }


def visible_green_spill(image: Image.Image) -> dict[str, int]:
    exact = 0
    dominant = 0
    for red, green, blue, alpha in image.convert("RGBA").getdata():
        if alpha == 0:
            continue
        if red <= 4 and green >= 251 and blue <= 4:
            exact += 1
        if green >= 128 and green >= red + 32 and green >= blue + 32:
            dominant += 1
    return {"exact_00ff00": exact, "heuristic_green_dominant": dominant}


def cell_metrics(normalized: Image.Image) -> tuple[dict[str, Any], dict[str, Image.Image]]:
    metrics: dict[str, Any] = {}
    sprites: dict[str, Image.Image] = {}
    for identifier, box in CELL_BOXES.items():
        cell = normalized.crop(box)
        bbox = bbox_or_empty(cell)
        if bbox == (0, 0, 0, 0):
            margins = [512, 512, 512, 512]
            sprite = Image.new("RGBA", (1, 1), (0, 0, 0, 0))
        else:
            margins = [bbox[0], bbox[1], 512 - bbox[2], 512 - bbox[3]]
            sprite = cell.crop(bbox)
        metrics[identifier] = {
            "cell": list(box),
            "visible_bbox_local": list(bbox),
            "margins": margins,
            "minimum_margin": min(margins),
            "touches_edge": any(value == 0 for value in margins),
            "nonempty": bbox != (0, 0, 0, 0),
        }
        sprites[identifier] = sprite
    return metrics, sprites


def paste_fitted(canvas: Image.Image, sprite: Image.Image, box: tuple[int, int, int, int]) -> None:
    width = max(1, box[2] - box[0])
    height = max(1, box[3] - box[1])
    fitted = sprite.resize((width, height), Image.Resampling.LANCZOS)
    canvas.alpha_composite(fitted, (box[0], box[1]))


def nine_slice(sprite: Image.Image, size: tuple[int, int], destination_cap: int) -> Image.Image:
    width, height = size
    source_cap = max(1, round(min(sprite.size) * 0.18))
    source_cap = min(source_cap, (sprite.width - 1) // 2, (sprite.height - 1) // 2)
    cap = max(1, min(destination_cap, (width - 1) // 2, (height - 1) // 2))
    sx = (0, source_cap, sprite.width - source_cap, sprite.width)
    sy = (0, source_cap, sprite.height - source_cap, sprite.height)
    tx = (0, cap, width - cap, width)
    ty = (0, cap, height - cap, height)
    output = Image.new("RGBA", size, (0, 0, 0, 0))
    for row in range(3):
        for column in range(3):
            source = sprite.crop((sx[column], sy[row], sx[column + 1], sy[row + 1]))
            target = (tx[column], ty[row], tx[column + 1], ty[row + 1])
            resized = source.resize(
                (target[2] - target[0], target[3] - target[1]),
                Image.Resampling.LANCZOS,
            )
            output.alpha_composite(resized, (target[0], target[1]))
    return output


def paste_nine_slice(
    canvas: Image.Image,
    sprite: Image.Image,
    box: tuple[int, int, int, int],
    cap: int,
) -> None:
    assembled = nine_slice(sprite, (box[2] - box[0], box[3] - box[1]), cap)
    canvas.alpha_composite(assembled, (box[0], box[1]))


def dynamic_button(
    image: Image.Image,
    box: tuple[int, int, int, int],
    index: int,
    fonts: dict[str, ImageFont.FreeTypeFont],
    *,
    cooldown: bool = False,
    count: str = "",
    queued: bool = False,
    selected: bool = False,
) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    x0, y0, x1, y1 = box
    width = x1 - x0
    inset = max(2, round(width * 0.10))
    icon = (x0 + inset, y0 + inset, x1 - inset, y1 - inset)
    background, glyph = simulation.icon_colors(index)
    draw.rectangle(icon, fill=core.rgba(background), outline=core.rgba("#100d0b"), width=1)
    core.draw_glyph(draw, icon, index + 3, core.rgba(glyph, 220))
    if cooldown:
        draw.rectangle(icon, fill=core.rgba("#050607", 145))
        simulation.text(
            draw,
            ((x0 + x1) // 2, (y0 + y1) // 2),
            "18",
            fonts["micro"],
            "#f1e6c7",
            anchor="mm",
        )
    if selected:
        draw.rounded_rectangle(
            (x0 + 1, y0 + 1, x1 - 1, y1 - 1),
            radius=max(2, width // 8),
            outline=core.rgba("#c09155"),
            width=max(1, width // 14),
        )
    if count:
        simulation.text(draw, (x1 - 2, y1 - 1), count, fonts["micro"], "#f1d18e", anchor="rd")
    if queued:
        queue_size = max(8, round(width * 0.5))
        queue_box = (
            x0 - max(1, width // 18),
            y0 - max(1, width // 18),
            x0 - max(1, width // 18) + queue_size,
            y0 - max(1, width // 18) + queue_size,
        )
        draw.rounded_rectangle(queue_box, radius=2, fill=core.rgba("#21170f"), outline=core.rgba("#c09a52"))
        qx0, qy0, qx1, qy1 = queue_box
        draw.polygon(
            [(qx0 + 3, qy0 + 3), (qx1 - 3, (qy0 + qy1) // 2), (qx0 + 3, qy1 - 3)],
            fill=core.rgba("#d7b069"),
        )


def trinket_drawers(sprites: dict[str, Image.Image]) -> tuple[Callable[..., Any], Callable[..., Any]]:
    def draw_main(
        image: Image.Image,
        origin: tuple[int, int],
        orientation: str,
        factor: float,
        fonts: dict[str, ImageFont.FreeTypeFont],
        _palette: dict[str, str],
        *,
        queue_slots: list[int] | None = None,
        label: str = "",
    ) -> tuple[int, int, int, int]:
        geometry = simulation.trinket_main_geometry(orientation)
        width, height = (round(value * factor) for value in geometry["frame"])
        x, y = origin
        frame = (x, y, x + width, y + height)
        buttons = [simulation.offset_box(simulation.scale_box(raw, factor), x, y) for raw in geometry["buttons"]]
        for button in buttons:
            expansion = max(1, round(2 * factor))
            paste_fitted(image, sprites["A"], (button[0] - expansion, button[1] - expansion, button[2] + expansion, button[3] + expansion))
        first, second = buttons
        if orientation.upper() == "HORIZONTAL":
            joiner = (first[2], first[1] + (first[3] - first[1]) // 3, second[0], first[3] - (first[3] - first[1]) // 3)
        else:
            rotated = sprites["D"].rotate(90, expand=True)
            sprites_local = rotated
            joiner = (first[0] + (first[2] - first[0]) // 3, first[3], first[2] - (first[2] - first[0]) // 3, second[1])
            paste_fitted(image, sprites_local, joiner)
        if orientation.upper() == "HORIZONTAL":
            paste_fitted(image, sprites["D"], joiner)
        for index, button in enumerate(buttons):
            dynamic_button(image, button, index + 40, fonts, cooldown=index == 1, queued=index in (queue_slots or []), selected=index == 0)
        if label:
            simulation.text(ImageDraw.Draw(image, "RGBA"), ((frame[0] + frame[2]) // 2, frame[1] - max(10, round(11 * factor))), label, fonts["tiny"], "#e0c994", anchor="ms")
        return frame

    def draw_menu(
        image: Image.Image,
        origin: tuple[int, int],
        config: dict[str, Any],
        factor: float,
        fonts: dict[str, ImageFont.FreeTypeFont],
        _palette: dict[str, str],
    ) -> tuple[int, int, int, int] | None:
        geometry = simulation.trinket_menu_geometry(config)
        if geometry["hidden"]:
            return None
        width, height = (round(value * factor) for value in geometry["frame"])
        x, y = origin
        frame = (x, y, x + width, y + height)
        paste_nine_slice(image, sprites["C"], frame, max(2, round(5 * factor)))
        for index, raw in enumerate(geometry["buttons"]):
            button = simulation.offset_box(simulation.scale_box(raw, factor), x, y)
            expansion = max(1, round(2 * factor))
            paste_fitted(image, sprites["B"], (button[0] - expansion, button[1] - expansion, button[2] + expansion, button[3] + expansion))
            dynamic_button(image, button, index + 60, fonts, cooldown=index in {2, 6, 17}, selected=index == 4)
        return frame

    return draw_main, draw_menu


def consumable_drawers(
    sprites: dict[str, Image.Image],
) -> tuple[Callable[..., Any], Callable[..., Any], Callable[..., Any]]:
    def draw_buttons(
        image: Image.Image,
        geometry: dict[str, Any],
        origin: tuple[int, int],
        factor: float,
        fonts: dict[str, ImageFont.FreeTypeFont],
        sprite: Image.Image,
    ) -> None:
        x, y = origin
        for index, raw in enumerate(geometry["buttons"]):
            button = simulation.offset_box(simulation.scale_box(raw, factor), x, y)
            paste_fitted(image, sprite, button)
            dynamic_button(
                image,
                button,
                index,
                fonts,
                cooldown=index in {1, 6, 10, 18},
                count="" if index in {3, 11, 19, 23} else str((index * 3 + 5) % 21 + 1),
            )

    def draw_rack(
        image: Image.Image,
        origin: tuple[int, int],
        config: dict[str, Any],
        factor: float,
        fonts: dict[str, ImageFont.FreeTypeFont],
        _palette: dict[str, str],
        *,
        label: str = "",
    ) -> tuple[int, int, int, int]:
        geometry = simulation.autobar_rack_geometry(config)
        width, height = (round(value * factor) for value in geometry["frame"])
        x, y = origin
        frame = (x, y, x + width, y + height)
        paste_nine_slice(image, sprites["C"], frame, max(2, round(5 * factor)))
        draw_buttons(image, geometry, origin, factor, fonts, sprites["A"])
        if label:
            simulation.text(ImageDraw.Draw(image, "RGBA"), ((frame[0] + frame[2]) // 2, frame[1] - max(10, round(11 * factor))), label, fonts["tiny"], "#e0c994", anchor="ms")
        return frame

    def draw_grouped(
        image: Image.Image,
        origin: tuple[int, int],
        config: dict[str, Any],
        factor: float,
        fonts: dict[str, ImageFont.FreeTypeFont],
        _palette: dict[str, str],
        *,
        label: str = "",
    ) -> dict[str, Any]:
        geometry = simulation.autobar_grouped_rack_geometry(config)
        x, y = origin
        body = simulation.offset_box(simulation.scale_box(geometry["body_frame"], factor), x, y)
        full = (x, y, x + round(geometry["frame"][0] * factor), y + round(geometry["frame"][1] * factor))
        paste_nine_slice(image, sprites["C"], body, max(2, round(5 * factor)))
        for raw in geometry["group_dividers"]:
            divider = simulation.offset_box(simulation.scale_box(raw, factor), x, y)
            paste_fitted(image, sprites["D"], divider)
        labels: list[tuple[int, int, int, int]] = []
        draw = ImageDraw.Draw(image, "RGBA")
        for group, raw in zip(geometry["groups"], geometry["group_labels"]):
            tab = simulation.offset_box(simulation.scale_box(raw, factor), x, y)
            labels.append(tab)
            paste_nine_slice(image, sprites["C"], tab, max(2, round(4 * factor)))
            simulation.text(draw, ((tab[0] + tab[2]) // 2, (tab[1] + tab[3]) // 2 + 1), str(group["label"]), fonts["micro"], "#e0c994", anchor="mm")
        draw_buttons(image, geometry, origin, factor, fonts, sprites["A"])
        if label:
            simulation.text(draw, ((body[0] + body[2]) // 2, full[1] - max(10, round(11 * factor))), label, fonts["tiny"], "#e0c994", anchor="ms")
        return {"full": full, "body": body, "labels": labels}

    def draw_popup(
        image: Image.Image,
        origin: tuple[int, int],
        config: dict[str, Any],
        factor: float,
        fonts: dict[str, ImageFont.FreeTypeFont],
        _palette: dict[str, str],
    ) -> tuple[int, int, int, int]:
        geometry = simulation.autobar_popup_geometry(config)
        width, height = (round(value * factor) for value in geometry["frame"])
        x, y = origin
        buttons = [simulation.offset_box(simulation.scale_box(raw, factor), x, y) for raw in geometry["buttons"]]
        for index, button in enumerate(buttons):
            paste_fitted(image, sprites["B"], button)
            dynamic_button(image, button, index + 20, fonts, cooldown=index == 3, count=str(index + 1), selected=index == 1)
            if index:
                previous = buttons[index - 1]
                if config["direction"].upper() in {"TOP", "BOTTOM"}:
                    strip = (button[0] + (button[2] - button[0]) // 3, min(previous[3], button[3]), button[2] - (button[2] - button[0]) // 3, max(previous[1], button[1]))
                    paste_fitted(image, sprites["D"].rotate(90, expand=True), strip)
                else:
                    strip = (min(previous[2], button[2]), button[1] + (button[3] - button[1]) // 3, max(previous[0], button[0]), button[3] - (button[3] - button[1]) // 3)
                    paste_fitted(image, sprites["D"], strip)
        return (x, y, x + width, y + height)

    return draw_rack, draw_grouped, draw_popup


def render_supported_board(
    root: Path,
    spec: dict[str, Any],
    component: str,
    output: Path,
) -> None:
    base = core.load_spec(resolve(root, spec["base_scene_spec"]).resolve(), root)
    fonts = {name: core.load_font(root, definition) for name, definition in base["fonts"].items()}
    palette = {**base["palette"], **spec["palette"]}
    ui_scale = float(spec["target"]["ui_scale"])
    image = Image.new("RGBA", (1920, 1200), core.rgba("#111613"))
    draw = ImageDraw.Draw(image, "RGBA")
    title = "AB.TRINKET.KIT.V1" if component == "trinket" else "AB.CONSUMABLE.KIT.V1"
    simulation.text(draw, (38, 28), f"{title} · exact supported layouts", fonts["title"], "#edd7a2")
    simulation.text(draw, (38, 70), "Candidate base pixels + deterministic provider-owned icons/states; all sizes below use target-device UI scale.", fonts["small"], "#bdae8d")
    if component == "trinket":
        scenarios = [
            ("main H current", (40, 150), lambda: simulation.draw_trinket_main(image, (40, 150), "HORIZONTAL", ui_scale * 0.9043710231781006, fonts, palette, queue_slots=[0])),
            ("main V", (180, 150), lambda: simulation.draw_trinket_main(image, (180, 150), "VERTICAL", ui_scale, fonts, palette, queue_slots=[1])),
            ("menu 1 / 4 cols", (300, 150), lambda: simulation.draw_trinket_menu(image, (300, 150), {"count": 1, "orientation": "VERTICAL", "set_columns": True, "columns": 4}, ui_scale, fonts, palette)),
            ("menu 8 / 4 cols", (480, 150), lambda: simulation.draw_trinket_menu(image, (480, 150), {"count": 8, "orientation": "VERTICAL", "set_columns": True, "columns": 4}, ui_scale, fonts, palette)),
            ("menu 30 / 4 cols", (680, 150), lambda: simulation.draw_trinket_menu(image, (680, 150), {"count": 30, "orientation": "VERTICAL", "set_columns": True, "columns": 4}, ui_scale, fonts, palette)),
            ("menu 30 / auto 5", (880, 150), lambda: simulation.draw_trinket_menu(image, (880, 150), {"count": 30, "orientation": "VERTICAL", "set_columns": False, "columns": 5}, ui_scale, fonts, palette)),
            ("menu H / 8", (1120, 150), lambda: simulation.draw_trinket_menu(image, (1120, 150), {"count": 8, "orientation": "HORIZONTAL", "set_columns": True, "columns": 4}, ui_scale, fonts, palette)),
            ("menu 30 columns", (40, 620), lambda: simulation.draw_trinket_menu(image, (40, 620), {"count": 30, "orientation": "VERTICAL", "set_columns": True, "columns": 30}, ui_scale, fonts, palette)),
        ]
    else:
        groups = spec["consumable_contract"]["recommended_profile"]["groups"]
        scenarios = [
            ("rack 1x1", (40, 150), lambda: simulation.draw_rack(image, (40, 150), {"count": 1, "columns": 1, "rows": 1}, ui_scale, fonts, palette)),
            ("rack 5x2", (160, 150), lambda: simulation.draw_rack(image, (160, 150), {"count": 10, "columns": 5, "rows": 2}, ui_scale, fonts, palette)),
            ("grouped 4x6", (400, 150), lambda: simulation.draw_grouped_rack(image, (400, 150), {"count": 24, "columns": 4, "rows": 6, "groups": groups, "group_label_width_ui": 40, "group_label_gap_ui": 2, "group_label_height_ui": 20}, ui_scale, fonts, palette)),
            ("rack 24x1", (700, 150), lambda: simulation.draw_rack(image, (700, 150), {"count": 24, "columns": 24, "rows": 1}, ui_scale, fonts, palette)),
            ("rack 1x24", (40, 350), lambda: simulation.draw_rack(image, (40, 350), {"count": 24, "columns": 1, "rows": 24}, ui_scale, fonts, palette)),
            ("popup TOP 6", (180, 430), lambda: simulation.draw_popup(image, (180, 430), {"count": 6, "direction": "TOP"}, ui_scale, fonts, palette)),
            ("popup RIGHT 12", (400, 620), lambda: simulation.draw_popup(image, (400, 620), {"count": 12, "direction": "RIGHT"}, ui_scale, fonts, palette)),
        ]
    for label, origin, renderer in scenarios:
        simulation.text(draw, (origin[0], origin[1] - 24), label, fonts["tiny"], "#d8c49a")
        renderer()
    if component == "trinket":
        simulation.text(draw, (1450, 150), "0 candidates: menu hidden", fonts["small"], "#d8c49a")
    output.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(output, format="PNG", optimize=False, compress_level=9)


def render_cell_board(normalized: Image.Image, metrics: dict[str, Any], output: Path) -> None:
    board = Image.new("RGBA", (1280, 1280), (18, 22, 20, 255))
    draw = ImageDraw.Draw(board, "RGBA")
    font = ImageFont.load_default(size=18)
    title = ImageFont.load_default(size=28)
    draw.text((32, 24), "Field Kit candidate · normalized review cells", font=title, fill=(235, 215, 170, 255))
    positions = {"A": (32, 96), "B": (656, 96), "C": (32, 704), "D": (656, 704)}
    for identifier, position in positions.items():
        cell = normalized.crop(CELL_BOXES[identifier]).resize((560, 560), Image.Resampling.NEAREST)
        checker = Image.new("RGBA", cell.size, (232, 232, 232, 255))
        checker_draw = ImageDraw.Draw(checker)
        for y in range(0, cell.height, 24):
            for x in range(0, cell.width, 24):
                if (x // 24 + y // 24) % 2:
                    checker_draw.rectangle((x, y, x + 23, y + 23), fill=(250, 250, 250, 255))
        checker.alpha_composite(cell)
        board.alpha_composite(checker, position)
        item = metrics[identifier]
        draw.text((position[0], position[1] - 28), f"{identifier} · bbox={item['visible_bbox_local']} · margins={item['margins']}", font=font, fill=(224, 204, 157, 255))
    output.parent.mkdir(parents=True, exist_ok=True)
    board.convert("RGB").save(output, format="PNG", optimize=False, compress_level=9)


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    raw_path = resolve(root, args.raw).resolve()
    spec_path = resolve(root, args.spec).resolve()
    display_template = resolve(root, args.display_template).resolve()
    output_dir = resolve(root, args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    with Image.open(raw_path) as opened:
        opened.load()
        source_format = opened.format
        source_mode = opened.mode
        raw = opened.copy()

    component_name = "AB.TRINKET.KIT.V1" if args.component == "trinket" else "AB.CONSUMABLE.KIT.V1"
    canonical_provenance: dict[str, Any] | None = None
    if args.canonical is not None:
        if args.canonicalization_report is None:
            raise ValueError("--canonical requires --canonicalization-report")
        canonical_path = resolve(root, args.canonical).resolve()
        canonical_report_path = resolve(root, args.canonicalization_report).resolve()
        canonical_provenance = json.loads(canonical_report_path.read_text(encoding="utf-8"))
        validate_canonical_provenance(
            canonical_provenance,
            component_name=component_name,
            attempt=args.attempt,
            raw_path=raw_path,
            canonical_path=canonical_path,
        )
        with Image.open(canonical_path) as opened:
            opened.load()
            normalized_source_mode = opened.mode
            normalized = opened.copy()
        normalized_path = canonical_path
        derivation = {
            "method": "authorized deterministic chroma transport canonical",
            "review_only": False,
            "candidate_is_unaccepted": True,
            "canonicalization_report": str(canonical_report_path),
            "canonicalization_report_sha256": sha256(canonical_report_path),
            "source_mode": normalized_source_mode,
            "source_size": list(normalized.size),
        }
    else:
        if args.canonicalization_report is not None:
            raise ValueError("--canonicalization-report requires --canonical")
        normalized, derivation = derive_review_rgba(raw)
        normalized_path = output_dir / f"AB.{args.component.upper()}.KIT.V1.{args.attempt}.normalized-transparent-review.png"
        normalized.save(normalized_path)
    metrics, sprites = cell_metrics(normalized)

    original = {
        "trinket_main": simulation.draw_trinket_main,
        "trinket_menu": simulation.draw_trinket_menu,
        "rack": simulation.draw_rack,
        "grouped": simulation.draw_grouped_rack,
        "popup": simulation.draw_popup,
    }
    if args.component == "trinket":
        simulation.draw_trinket_main, simulation.draw_trinket_menu = trinket_drawers(sprites)
    else:
        simulation.draw_rack, simulation.draw_grouped_rack, simulation.draw_popup = consumable_drawers(sprites)
    try:
        review_spec = copy.deepcopy(spec)
        name = component_name
        review_spec["scene_annotations"] = {
            "title": f"{name} · {args.attempt} 正式候选真实排版",
            "subtitle": "只有当前 Kit 的静态基底来自候选；图标、冷却、Queue、数量与文字仍是 provider 动态层",
            "note": "100% 目标设备物理像素 · review-only · 非 source/runtime",
            "rules_title": "当前候选审查",
            "rules": [
                "原始 provider raw 与本地 canonical provenance 分开审查",
                "四个 cell 必须各自完整且有至少 80 px 透明安全区",
                "所有真实 Button hit box 与 provider 动态层保持不变",
                "支持布局使用同一候选 cell，不从模拟像素取材",
            ],
        }
        scene_path = output_dir / f"{name}.{args.attempt}.real-layout-1920x1080.png"
        scene_boxes = simulation.draw_scene(root, review_spec, scene_path)
        board_path = output_dir / f"{name}.{args.attempt}.supported-layouts-board.png"
        render_supported_board(root, review_spec, args.component, board_path)
    finally:
        simulation.draw_trinket_main = original["trinket_main"]
        simulation.draw_trinket_menu = original["trinket_menu"]
        simulation.draw_rack = original["rack"]
        simulation.draw_grouped_rack = original["grouped"]
        simulation.draw_popup = original["popup"]

    cell_board_path = output_dir / f"AB.{args.component.upper()}.KIT.V1.{args.attempt}.cell-review.png"
    render_cell_board(normalized, metrics, cell_board_path)

    display = json.loads(display_template.read_text(encoding="utf-8"))
    display["component"] = f"{component_name}/production-candidate"
    display["evidence"]["scene_simulation"] = str(scene_path)
    display["evidence"]["state_simulation"] = str(board_path)
    display["evidence"]["atlas_role"] = (
        "exact authorized canonical candidate sampling; unaccepted and not source or runtime"
        if canonical_provenance is not None
        else "review-only failure derivation; not source or runtime"
    )
    display["atlas"] = {
        "size": [1024, 1024],
        "visible_bbox": list(bbox_or_empty(normalized)),
        "require_exact_visible_coverage": False,
        "sampled_regions": [
            {
                "id": f"candidate.cell-{identifier}",
                "box": [
                    box[0] + metrics[identifier]["visible_bbox_local"][0],
                    box[1] + metrics[identifier]["visible_bbox_local"][1],
                    box[0] + metrics[identifier]["visible_bbox_local"][2],
                    box[1] + metrics[identifier]["visible_bbox_local"][3],
                ],
            }
            for identifier, box in CELL_BOXES.items()
            if metrics[identifier]["nonempty"]
        ],
    }
    contract_path = output_dir / "display-region-contract.json"
    write_json(contract_path, display)

    raw_rgba = raw.convert("RGBA")
    raw_alpha_extrema = raw_rgba.getchannel("A").getextrema()
    source_has_alpha = "A" in raw.getbands()
    raw_transparent = source_has_alpha and raw_alpha_extrema[0] == 0
    normalized_rgba = normalized.convert("RGBA")
    normalized_alpha_extrema = normalized_rgba.getchannel("A").getextrema()
    shared_checks = {
        "four_cells_nonempty": all(item["nonempty"] for item in metrics.values()),
        "four_cells_minimum_80px_margin": all(item["minimum_margin"] >= 80 for item in metrics.values()),
        "no_cell_touches_edge": all(not item["touches_edge"] for item in metrics.values()),
        "visible_green_spill_zero": all(value == 0 for value in visible_green_spill(normalized_rgba).values()),
        "transparent_rgb_zero": transparent_rgb_nonzero(normalized_rgba) == 0,
    }
    if canonical_provenance is not None:
        checks = {
            "canonical_exact_1024_canvas": normalized.size == (1024, 1024),
            "canonical_rgba_mode": normalized.mode == "RGBA",
            "canonical_has_true_transparency": normalized_alpha_extrema[0] == 0 and normalized_alpha_extrema[1] > 0,
            "canonical_provenance_pass": canonical_provenance.get("status") == "pass",
            **shared_checks,
        }
    else:
        checks = {
            "raw_exact_1024_canvas": raw.size == (1024, 1024),
            "raw_rgba_mode": source_mode == "RGBA",
            "raw_has_true_transparency": raw_transparent,
            **shared_checks,
        }
    center_quiet = {}
    for identifier in ("A", "B", "C"):
        crop = normalized.crop(CELL_BOXES[identifier]).crop((176, 176, 336, 336)).convert("RGB")
        center_quiet[identifier] = {
            "luma_stddev": round(ImageStat.Stat(ImageOps.grayscale(crop)).stddev[0], 4),
            "high_frequency_mean": "visual verdict required",
        }

    report = {
        "schema": "aeui-action-fieldkit-candidate-review-v1",
        "component": component_name,
        "attempt": args.attempt,
        "candidate_is_source": False,
        "candidate_is_runtime": False,
        "review_subject": "canonical" if canonical_provenance is not None else "legacy-review-derivation",
        "raw": {
            "path": str(raw_path),
            "sha256": sha256(raw_path),
            "format": source_format,
            "mode": source_mode,
            "size": list(raw.size),
            "alpha_extrema_after_rgba_conversion": list(raw_alpha_extrema),
            "visible_green_spill": visible_green_spill(raw_rgba),
        },
        "canonicalization_provenance": (
            {
                "schema": canonical_provenance.get("schema"),
                "status": canonical_provenance.get("status"),
                "raw_sha256": canonical_provenance.get("raw", {}).get("sha256"),
                "canonical_sha256": canonical_provenance.get("canonical", {}).get("sha256"),
            }
            if canonical_provenance is not None
            else None
        ),
        "review_derivation": derivation,
        "normalized_review": {
            "path": str(normalized_path),
            "sha256": sha256(normalized_path),
            "mode": normalized.mode,
            "size": list(normalized.size),
            "alpha_extrema": list(normalized_alpha_extrema),
            "transparent_rgb_nonzero_pixels": transparent_rgb_nonzero(normalized_rgba),
            "visible_green_spill": visible_green_spill(normalized_rgba),
            "visible_bbox": list(bbox_or_empty(normalized)),
            "cells": metrics,
            "center_quiet_metrics": center_quiet,
        },
        "contract_checks": checks,
        "status": "pass" if all(checks.values()) else "fail",
        "failures": [identifier for identifier, passed in checks.items() if not passed],
        "real_layout": {
            "scene": {"path": str(scene_path), "sha256": sha256(scene_path), "size": list(Image.open(scene_path).size)},
            "supported_layouts": {"path": str(board_path), "sha256": sha256(board_path), "size": list(Image.open(board_path).size)},
            "cell_review": {"path": str(cell_board_path), "sha256": sha256(cell_board_path), "size": list(Image.open(cell_board_path).size)},
            "scene_boxes": scene_boxes,
            "candidate_pixels": f"{component_name} static bases only",
            "dynamic_pixels": "deterministic provider-owned icons, counts, cooldowns, selection and Queue",
            "surrounding_pixels": "confirmed V3 direction simulation; non-authoritative",
        },
        "display_region_contract": {"path": str(contract_path), "sha256": sha256(contract_path)},
        "semantic_warning": "Numeric checks do not prove object identity, perspective, art direction, quiet centers, or rotational validity.",
    }
    write_json(output_dir / "candidate-review.json", report)
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
