#!/usr/bin/env python3
"""Build exact Player/Target V4 candidates from accepted Raid A2 materials.

The four accepted material samples are immutable, read-only inputs.  This tool
owns only deterministic masks, alpha, low-frequency contact lighting, role
repairs, full-source/runtime scaling, and review-only state derivation.  It
never writes assets/source or addon runtime files.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SPEC = ROOT / "tools/specs/unitframes_primary_v4_candidate_v1.json"


@dataclass(frozen=True)
class PrimaryCandidates:
    materials: dict[str, Image.Image]
    sources: dict[str, Image.Image]
    runtimes: dict[str, Image.Image]
    masks: dict[str, dict[str, Image.Image]]
    states: dict[str, Image.Image]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=Path, default=DEFAULT_SPEC)
    parser.add_argument("--output-dir", type=Path)
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_materials(spec: dict) -> dict[str, Image.Image]:
    materials: dict[str, Image.Image] = {}
    for material_id, contract in spec["inputs"]["materials"].items():
        path = ROOT / contract["file"]
        actual = sha256(path)
        if actual != contract["sha256"]:
            raise ValueError(
                f"immutable {material_id} SHA mismatch: {actual} != {contract['sha256']}"
            )
        materials[material_id] = Image.open(path).convert("RGB")
    return materials


def cover_material(
    image: Image.Image,
    size: tuple[int, int],
    offset: tuple[int, int],
    overscan: float = 1.15,
) -> Image.Image:
    """Aspect-preserving cover-fit with enough overscan for distinct crops."""
    scale = max(size[0] / image.width, size[1] / image.height) * overscan
    resized = image.resize(
        (round(image.width * scale), round(image.height * scale)),
        Image.Resampling.LANCZOS,
    )
    overflow_x = resized.width - size[0]
    overflow_y = resized.height - size[1]
    x = max(0, min(overflow_x, overflow_x // 2 + offset[0]))
    y = max(0, min(overflow_y, overflow_y // 2 + offset[1]))
    return resized.crop((x, y, x + size[0], y + size[1])).convert("RGBA")


def masked_texture(texture: Image.Image, mask: Image.Image) -> Image.Image:
    result = texture.convert("RGBA").copy()
    result.putalpha(mask)
    return result


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    image = image.convert("RGBA")
    red, green, blue, alpha = image.split()
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


def _rect_mask(size: tuple[int, int], box: tuple[int, int, int, int]) -> Image.Image:
    mask = Image.new("L", size, 0)
    x0, y0, x1, y1 = box
    ImageDraw.Draw(mask).rectangle((x0, y0, x1 - 1, y1 - 1), fill=255)
    return mask


def _outer_mask(role: str, size: tuple[int, int]) -> Image.Image:
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    if role == "player":
        points = [
            (0, 46), (7, 20), (27, 8), (72, 3), (136, 8), (204, 1),
            (292, 6), (388, 2), (486, 7), (582, 3), (674, 8),
            (770, 2), (866, 7), (954, 4), (1046, 8), (1128, 3),
            (1200, 7), (1254, 2), (1276, 13), (1283, 44), (1278, 91),
            (1283, 142), (1279, 194), (1282, 226), (1267, 244),
            (1224, 250), (1142, 245), (1060, 251), (970, 246),
            (874, 250), (778, 245), (684, 251), (586, 246), (490, 250),
            (394, 245), (300, 251), (216, 245), (140, 250), (74, 244),
            (28, 249), (8, 237), (1, 211), (5, 171), (0, 124), (4, 81),
        ]
    elif role == "target":
        points = [
            (0, 43), (5, 18), (22, 6), (70, 1), (142, 7), (222, 3),
            (314, 8), (410, 2), (504, 7), (600, 4), (696, 9),
            (790, 3), (884, 7), (980, 2), (1072, 8), (1158, 4),
            (1228, 9), (1267, 5), (1281, 22), (1277, 61), (1283, 105),
            (1278, 153), (1283, 199), (1276, 231), (1259, 248),
            (1212, 243), (1132, 251), (1044, 245), (952, 250),
            (860, 244), (764, 251), (668, 245), (574, 250), (480, 244),
            (384, 251), (292, 245), (208, 249), (132, 244), (65, 250),
            (22, 243), (3, 226), (7, 190), (1, 149), (6, 102), (0, 68),
        ]
    else:
        raise ValueError(f"unknown role: {role}")
    draw.polygon(points, fill=255)
    return mask


def _edge_bands(
    outer: Image.Image,
    bed: Image.Image,
) -> tuple[Image.Image, Image.Image]:
    outer_edge = ImageChops.subtract(outer, outer.filter(ImageFilter.MinFilter(11)))
    near_bed = ImageChops.subtract(bed.filter(ImageFilter.MaxFilter(15)), bed)
    near_bed = ImageChops.multiply(near_bed, outer)
    return outer_edge, near_bed


def _low_frequency_shade(image: Image.Image, role: str) -> Image.Image:
    shade = Image.new("L", image.size, 216)
    draw = ImageDraw.Draw(shade)
    draw.ellipse((-170, -185, 760, 325), fill=255)
    draw.ellipse((680, 115, 1510, 480), fill=165 if role == "target" else 174)
    if role == "target":
        draw.ellipse((950, -80, 1390, 210), fill=194)
    shade = shade.filter(ImageFilter.GaussianBlur(105))
    rgb_shade = Image.merge("RGB", (shade, shade, shade))
    rgb = ImageChops.multiply(image.convert("RGB"), rgb_shade)
    result = rgb.convert("RGBA")
    result.putalpha(image.getchannel("A"))
    return result


def _repair_masks(
    role: str,
    size: tuple[int, int],
    rim: Image.Image,
) -> dict[str, Image.Image]:
    masks: dict[str, Image.Image] = {}
    if role == "player":
        brass = Image.new("L", size, 0)
        draw = ImageDraw.Draw(brass)
        draw.polygon(
            [(18, 4), (54, 0), (91, 7), (134, 3), (181, 12),
             (174, 29), (127, 25), (92, 33), (52, 25), (14, 31)],
            fill=242,
        )
        draw.polygon([(7, 22), (25, 26), (32, 72), (19, 95), (5, 82)], fill=215)
        masks["brass"] = ImageChops.multiply(brass, rim)

        thread = Image.new("L", size, 0)
        tdraw = ImageDraw.Draw(thread)
        strokes = (
            ((13, 91), (29, 103), (14, 118), (31, 132)),
            ((12, 151), (30, 163), (13, 181), (28, 195)),
        )
        for index, points in enumerate(strokes):
            tdraw.line(points, fill=245, width=7 + index, joint="curve")
            for x, y in (points[0], points[-1]):
                radius = 4 + index
                tdraw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=235)
        masks["thread"] = ImageChops.multiply(thread, rim)

        rivet = Image.new("L", size, 0)
        rdraw = ImageDraw.Draw(rivet)
        rdraw.ellipse((1244, 219, 1274, 248), fill=238)
        masks["rivet"] = ImageChops.multiply(rivet, rim)
    else:
        fold = Image.new("L", size, 0)
        fdraw = ImageDraw.Draw(fold)
        fdraw.polygon(
            [(16, 5), (54, 0), (92, 8), (143, 3), (174, 13),
             (139, 30), (94, 24), (52, 33), (18, 25)],
            fill=205,
        )
        fdraw.line(((21, 30), (68, 22), (112, 29), (154, 20)), fill=238, width=5)
        masks["fold"] = ImageChops.multiply(fold, rim)

        brass = Image.new("L", size, 0)
        bdraw = ImageDraw.Draw(brass)
        bdraw.polygon(
            [(1127, 232), (1161, 220), (1191, 225), (1220, 216),
             (1245, 223), (1240, 248), (1204, 242), (1168, 250),
             (1139, 243)],
            fill=238,
        )
        bdraw.polygon(
            [(1243, 222), (1249, 189), (1262, 169), (1283, 177),
             (1277, 215), (1282, 238), (1257, 248), (1240, 239)],
            fill=228,
        )
        # Two missing chips keep the scab from reading as one stamped ornament.
        bdraw.polygon([(1185, 224), (1201, 219), (1210, 229), (1196, 238)], fill=0)
        bdraw.polygon([(1243, 228), (1255, 216), (1267, 223), (1257, 237)], fill=0)
        masks["brass"] = ImageChops.multiply(brass, rim)

        split = Image.new("L", size, 0)
        sdraw = ImageDraw.Draw(split)
        sdraw.line(((1162, 232), (1193, 225), (1212, 240), (1230, 225), (1254, 239)), fill=255, width=7)
        sdraw.line(((1212, 240), (1204, 249)), fill=225, width=4)
        masks["split"] = ImageChops.multiply(split, rim)
    return masks


def role_masks(spec: dict, role: str) -> dict[str, Image.Image]:
    size = tuple(spec["geometry"]["source"])
    bed_box = tuple(spec["geometry"]["live_content_bed_source"])
    outer = _outer_mask(role, size)
    bed = _rect_mask(size, bed_box)
    if ImageChops.subtract(bed, outer).getbbox() is not None:
        raise ValueError(f"{role} outer silhouette does not fully contain live bed")
    rim = ImageChops.subtract(outer, bed)
    outer_edge, bed_contact = _edge_bands(outer, bed)
    repairs = _repair_masks(role, size, rim)
    return {
        "outer": outer,
        "bed": bed,
        "rim": rim,
        "outer_edge": outer_edge,
        "bed_contact": bed_contact,
        **{f"repair_{key}": value for key, value in repairs.items()},
    }


def _darken(texture: Image.Image, amount: float) -> Image.Image:
    return ImageEnhance.Brightness(texture).enhance(amount)


def _apply_player_repairs(
    shell: Image.Image,
    textures: dict[str, Image.Image],
    masks: dict[str, Image.Image],
) -> None:
    thread_shadow = ImageChops.offset(masks["repair_thread"], 3, 3)
    thread_shadow = ImageChops.multiply(thread_shadow, masks["rim"])
    shell.alpha_composite(masked_texture(_darken(textures["thread"], 0.42), thread_shadow))
    shell.alpha_composite(masked_texture(_darken(textures["brass"], 0.84), masks["repair_brass"]))
    shell.alpha_composite(
        masked_texture(ImageEnhance.Brightness(textures["thread"]).enhance(1.22), masks["repair_thread"])
    )
    shell.alpha_composite(masked_texture(_darken(textures["brass"], 0.44), masks["repair_rivet"]))
    highlight = Image.new("L", shell.size, 0)
    ImageDraw.Draw(highlight).ellipse((1249, 222, 1260, 232), fill=145)
    highlight = ImageChops.multiply(highlight, masks["repair_rivet"])
    shell.alpha_composite(masked_texture(ImageEnhance.Brightness(textures["brass"]).enhance(1.18), highlight))


def _apply_target_repairs(
    shell: Image.Image,
    textures: dict[str, Image.Image],
    masks: dict[str, Image.Image],
) -> None:
    fold_shadow = masks["repair_fold"].filter(ImageFilter.GaussianBlur(8))
    fold_shadow = ImageChops.multiply(fold_shadow, masks["rim"])
    shell.alpha_composite(masked_texture(_darken(textures["leather"], 0.73), fold_shadow))
    shell.alpha_composite(
        masked_texture(ImageEnhance.Brightness(textures["leather"]).enhance(1.19), masks["repair_fold"])
    )
    brass_shadow = ImageChops.offset(masks["repair_brass"], -3, -2)
    brass_shadow = ImageChops.multiply(brass_shadow, masks["rim"])
    shell.alpha_composite(masked_texture(_darken(textures["brass"], 0.42), brass_shadow))
    shell.alpha_composite(masked_texture(_darken(textures["brass"], 0.60), masks["repair_brass"]))
    shell.alpha_composite(masked_texture(_darken(textures["leather"], 0.28), masks["repair_split"]))


def _state_from_runtime(runtime: Image.Image, role: str) -> Image.Image:
    alpha = runtime.getchannel("A")
    edge = ImageChops.subtract(alpha, alpha.filter(ImageFilter.MinFilter(3)))
    segments = Image.new("L", runtime.size, 0)
    draw = ImageDraw.Draw(segments)
    if role == "player":
        draw.rectangle((9, 0, 78, 7), fill=155)
        draw.rectangle((91, 35, 169, 41), fill=135)
        draw.rectangle((0, 10, 8, 31), fill=125)
        colour = (222, 205, 158)
    else:
        draw.rectangle((104, 0, 197, 7), fill=150)
        draw.rectangle((47, 35, 132, 41), fill=135)
        draw.rectangle((205, 9, 213, 34), fill=155)
        colour = (128, 45, 35)
    mask = ImageChops.multiply(edge, segments).filter(ImageFilter.GaussianBlur(0.65))
    state = Image.new("RGBA", runtime.size, colour + (0,))
    state.putalpha(mask)
    return clear_transparent_rgb(state)


def build_candidates(spec: dict, materials: dict[str, Image.Image]) -> PrimaryCandidates:
    source_size = tuple(spec["geometry"]["source"])
    runtime_size = tuple(spec["geometry"]["runtime"])
    sources: dict[str, Image.Image] = {}
    runtimes: dict[str, Image.Image] = {}
    masks_by_role: dict[str, dict[str, Image.Image]] = {}

    for role in ("player", "target"):
        masks = role_masks(spec, role)
        offsets = spec["construction"]["role_offsets"][role]
        textures = {
            material_id: cover_material(
                material,
                source_size,
                tuple(offsets[material_id]),
            )
            for material_id, material in materials.items()
        }
        shell = Image.new("RGBA", source_size, (0, 0, 0, 0))
        shell.alpha_composite(masked_texture(textures["liner"], masks["bed"]))
        shell.alpha_composite(masked_texture(textures["leather"], masks["rim"]))
        shell = _low_frequency_shade(shell, role)

        # Both bands reuse accepted pixels and only alter low-frequency value.
        shell.alpha_composite(masked_texture(_darken(textures["leather"], 0.45), masks["outer_edge"]))
        shell.alpha_composite(masked_texture(_darken(textures["leather"], 0.58), masks["bed_contact"]))
        if role == "player":
            _apply_player_repairs(shell, textures, masks)
        else:
            _apply_target_repairs(shell, textures, masks)

        shell.putalpha(masks["outer"])
        shell = clear_transparent_rgb(shell)
        runtime = clear_transparent_rgb(
            shell.resize(runtime_size, Image.Resampling.LANCZOS)
        )
        sources[role] = shell
        runtimes[role] = runtime
        masks_by_role[role] = masks

    states = {
        "player_hover": _state_from_runtime(runtimes["player"], "player"),
        "target_aggro": _state_from_runtime(runtimes["target"], "target"),
    }
    return PrimaryCandidates(materials, sources, runtimes, masks_by_role, states)


def save_candidates(
    spec: dict,
    candidates: PrimaryCandidates,
    output_dir: Path,
) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    outputs = spec["outputs"]
    candidates.sources["player"].save(output_dir / outputs["player_source"], compress_level=9)
    candidates.sources["target"].save(output_dir / outputs["target_source"], compress_level=9)
    candidates.runtimes["player"].save(output_dir / outputs["player_runtime_review"], compress_level=9)
    candidates.runtimes["target"].save(output_dir / outputs["target_runtime_review"], compress_level=9)
    candidates.states["player_hover"].save(output_dir / outputs["player_hover_review"], compress_level=9)
    candidates.states["target_aggro"].save(output_dir / outputs["target_aggro_review"], compress_level=9)

    mask_sheet = Image.new("RGBA", (1284, 504), (0, 0, 0, 0))
    colour_map = {
        "rim": (70, 42, 24, 255),
        "repair_brass": (143, 103, 44, 255),
        "repair_thread": (176, 139, 94, 255),
        "repair_rivet": (94, 75, 44, 255),
        "repair_fold": (119, 78, 45, 255),
        "repair_split": (34, 20, 15, 255),
    }
    for row, role in enumerate(("player", "target")):
        y = row * 252
        for mask_id, colour in colour_map.items():
            if mask_id not in candidates.masks[role]:
                continue
            layer = Image.new("RGBA", (1284, 252), colour)
            layer.putalpha(candidates.masks[role][mask_id])
            mask_sheet.alpha_composite(layer, (0, y))
    mask_sheet = clear_transparent_rgb(mask_sheet)
    mask_sheet.save(output_dir / outputs["geometry_masks"], compress_level=9)


def main() -> None:
    args = parse_args()
    spec_path = args.spec.resolve()
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    materials = load_materials(spec)
    candidates = build_candidates(spec, materials)
    output_dir = args.output_dir or ROOT / spec["outputs"]["directory"]
    save_candidates(spec, candidates, output_dir.resolve())
    print(output_dir.resolve())


if __name__ == "__main__":
    main()
