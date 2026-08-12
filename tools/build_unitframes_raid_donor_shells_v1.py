#!/usr/bin/env python3
"""Build exact raid-member shells from material-only donor pixels.

ImageGen only generates rough material donors. The image model is deliberately
not allowed to own any UI geometry in this
pipeline.  This builder owns the 592x296 source silhouette, the 74x37 runtime
size, the three-slice safe caps, and the four repair identities.  When
``--simulation`` is used it creates deterministic placeholder materials; those
pixels are review evidence only and must never be promoted into the addon.
"""

from __future__ import annotations

import argparse
import json
import random
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SPEC = ROOT / "tools/specs/unitframes_raid_donor_simulation_v1.json"


@dataclass(frozen=True)
class ShellSet:
    materials: dict[str, Image.Image]
    sources: dict[str, Image.Image]
    runtimes: dict[str, Image.Image]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=Path, default=DEFAULT_SPEC)
    parser.add_argument("--donor", type=Path)
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--preview-output", type=Path)
    parser.add_argument(
        "--simulation",
        action="store_true",
        help="Use deterministic placeholder materials; never production pixels.",
    )
    return parser.parse_args()


def _rgb(hex_value: str) -> tuple[int, int, int]:
    raw = hex_value.lstrip("#")
    return tuple(int(raw[index:index + 2], 16) for index in (0, 2, 4))


def _broad_material(
    size: tuple[int, int],
    base: str,
    seed: int,
    contrast: float,
    strokes: tuple[str, ...],
) -> Image.Image:
    """Create a broad-scale placeholder, not a fake production donor."""
    rng = random.Random(seed)
    image = Image.new("RGB", size, _rgb(base))
    broad = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(broad, "RGBA")
    width, height = size
    stroke_colours = [_rgb(value) for value in strokes]
    for _ in range(34):
        colour = rng.choice(stroke_colours)
        x = rng.randint(-width // 4, width)
        y = rng.randint(-height // 3, height)
        rx = rng.randint(width // 9, width // 2)
        ry = rng.randint(height // 14, height // 3)
        alpha = rng.randint(18, 52)
        draw.ellipse((x, y, x + rx, y + ry), fill=colour + (alpha,))
    broad = broad.filter(ImageFilter.GaussianBlur(max(8, min(size) // 18)))
    image = Image.alpha_composite(image.convert("RGBA"), broad).convert("RGB")

    # Sparse hand-dragged marks keep the placeholder from reading as a flat fill.
    marks = Image.new("RGBA", size, (0, 0, 0, 0))
    mark_draw = ImageDraw.Draw(marks, "RGBA")
    for _ in range(12):
        colour = rng.choice(stroke_colours)
        y = rng.randint(0, height - 1)
        x0 = rng.randint(-20, width // 2)
        x1 = min(width + 20, x0 + rng.randint(width // 5, width * 3 // 4))
        points = []
        for step in range(6):
            x = x0 + (x1 - x0) * step // 5
            points.append((x, y + rng.randint(-7, 7)))
        mark_draw.line(points, fill=colour + (rng.randint(16, 34),), width=rng.randint(2, 7))
    image = Image.alpha_composite(image.convert("RGBA"), marks).convert("RGB")
    return ImageEnhance.Contrast(image).enhance(contrast)


def synthetic_materials(spec: dict) -> dict[str, Image.Image]:
    """Return deterministic non-authoritative simulation materials."""
    size = (512, 288)
    return {
        "leather": _broad_material(
            size, "#382319", 7321, 1.12,
            ("#17100C", "#553724", "#745035", "#2A1B13"),
        ),
        "liner": _broad_material(
            size, "#18120E", 1933, 0.92,
            ("#0C0907", "#2A1E17", "#33251B"),
        ),
        "brass": _broad_material(
            size, "#604822", 8841, 1.08,
            ("#211B12", "#806234", "#957345", "#42351F"),
        ),
        "thread": _broad_material(
            size, "#70553B", 4427, 1.02,
            ("#35281F", "#8C6B4A", "#A1845E", "#4C392A"),
        ),
    }


def load_donor_materials(spec: dict, donor_path: Path) -> dict[str, Image.Image]:
    donor = Image.open(donor_path).convert("RGB")
    expected = tuple(spec["donor_contract"]["canvas"])
    if donor.size != expected:
        raise ValueError(f"donor must be exactly {expected}, got {donor.size}")
    materials: dict[str, Image.Image] = {}
    for material_id, contract in spec["donor_contract"]["cells"].items():
        materials[material_id] = donor.crop(tuple(contract["sample_window"]))
    return materials


def _cover(image: Image.Image, size: tuple[int, int], offset: tuple[int, int]) -> Image.Image:
    scale = max(size[0] / image.width, size[1] / image.height)
    resized = image.resize(
        (round(image.width * scale), round(image.height * scale)),
        Image.Resampling.LANCZOS,
    )
    overflow_x = resized.width - size[0]
    overflow_y = resized.height - size[1]
    x = max(0, min(overflow_x, overflow_x // 2 + offset[0]))
    y = max(0, min(overflow_y, overflow_y // 2 + offset[1]))
    return resized.crop((x, y, x + size[0], y + size[1])).convert("RGBA")


def _base_masks(size: tuple[int, int]) -> tuple[Image.Image, Image.Image]:
    width, height = size
    outer = Image.new("L", size, 0)
    draw = ImageDraw.Draw(outer)
    # Deliberately hand-cut, but exact and repeatable. The top/bottom rails stay
    # inside a 12-20px source rim around the provider content rectangle.
    points = [
        (0, 62), (5, 107), (1, 162), (5, 218), (3, 262),
        (15, 281), (51, 291), (108, 295), (179, 290), (248, 294),
        (316, 291), (380, 295), (451, 290), (521, 294), (568, 291),
        (584, 276), (591, 245), (588, 188), (591, 132), (587, 83),
        (591, 41), (587, 13), (568, 3), (510, 6), (431, 2),
        (368, 4), (300, 0), (235, 5), (174, 1), (108, 6),
        (58, 3), (17, 5), (4, 15),
    ]
    draw.polygon(points, fill=255)

    inner = Image.new("L", size, 0)
    ImageDraw.Draw(inner).rectangle((16, 16, 575, 279), fill=255)
    return outer, inner


def _multiply_shading(image: Image.Image, variant: str) -> Image.Image:
    shade = Image.new("L", image.size, 226)
    draw = ImageDraw.Draw(shade)
    # Warm upper-left catch light; lower/right contact darkness. These fields are
    # intentionally low-frequency so the donor remains the material authority.
    draw.ellipse((-100, -125, 420, 235), fill=255)
    draw.ellipse((205, 155, 710, 430), fill=178)
    if variant in ("B", "D"):
        draw.ellipse((420, 5, 650, 260), fill=200)
    shade = shade.filter(ImageFilter.GaussianBlur(64))
    rgb = ImageChops.multiply(image.convert("RGB"), Image.merge("RGB", (shade, shade, shade)))
    result = rgb.convert("RGBA")
    result.putalpha(image.getchannel("A"))
    return result


def _masked_texture(texture: Image.Image, mask: Image.Image) -> Image.Image:
    result = texture.copy().convert("RGBA")
    result.putalpha(mask)
    return result


def _paint_threads(
    shell: Image.Image,
    thread_texture: Image.Image,
    strokes: tuple[tuple[tuple[int, int], ...], ...],
) -> None:
    mask = Image.new("L", shell.size, 0)
    draw = ImageDraw.Draw(mask)
    for index, points in enumerate(strokes):
        draw.line(points, fill=238, width=5 + index % 2, joint="curve")
        # Uneven tie heads stop the repair from becoming a regular dashed seam.
        for x, y in (points[0], points[-1]):
            radius = 3 + ((x + y + index) % 2)
            draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=235)
    shell.alpha_composite(_masked_texture(thread_texture, mask))


def _apply_variant(
    shell: Image.Image,
    variant: str,
    materials: dict[str, Image.Image],
    outer_mask: Image.Image,
) -> Image.Image:
    size = shell.size
    leather = _cover(materials["leather"], size, (-37, 11))
    brass = _cover(materials["brass"], size, (43, -8))
    thread = _cover(materials["thread"], size, (-9, 6))
    alpha = shell.getchannel("A")

    if variant == "A":
        # A real cut in the upper-left edge, shallow enough to preserve the cap.
        notch = Image.new("L", size, 0)
        ImageDraw.Draw(notch).polygon(
            [(15, 0), (25, 0), (31, 5), (38, 0), (44, 0), (39, 11), (27, 13)],
            fill=255,
        )
        alpha = ImageChops.subtract(alpha, notch)
        shell.putalpha(alpha)
        _paint_threads(
            shell,
            thread,
            (
                ((550, 286), (558, 276), (566, 290)),
                ((570, 289), (577, 274), (584, 285)),
            ),
        )
    elif variant == "B":
        rub = Image.new("L", size, 0)
        rub_draw = ImageDraw.Draw(rub)
        rub_draw.ellipse((548, 249, 588, 291), fill=92)
        rub = rub.filter(ImageFilter.GaussianBlur(9))
        light_leather = ImageEnhance.Brightness(leather).enhance(1.24)
        light_leather.putalpha(ImageChops.multiply(rub, outer_mask))
        shell.alpha_composite(light_leather)
        rivet_mask = Image.new("L", size, 0)
        rivet_draw = ImageDraw.Draw(rivet_mask)
        rivet_draw.ellipse((576, 67, 589, 81), fill=255)
        rivet_draw.ellipse((579, 69, 585, 75), fill=150)
        shell.alpha_composite(_masked_texture(brass, rivet_mask))
    elif variant == "C":
        patch_mask = Image.new("L", size, 0)
        ImageDraw.Draw(patch_mask).polygon(
            [(1, 98), (17, 89), (34, 101), (30, 197), (16, 211), (2, 198)],
            fill=250,
        )
        patch = ImageEnhance.Brightness(leather).enhance(1.18)
        patch.putalpha(ImageChops.multiply(patch_mask, outer_mask))
        shell.alpha_composite(patch)
        _paint_threads(
            shell,
            thread,
            (
                ((18, 102), (24, 119), (17, 137)),
                ((17, 166), (25, 184), (18, 202)),
            ),
        )
    elif variant == "D":
        patch_mask = Image.new("L", size, 0)
        ImageDraw.Draw(patch_mask).polygon(
            [(574, 96), (588, 88), (591, 155), (578, 165), (572, 143)],
            fill=255,
        )
        shell.alpha_composite(_masked_texture(brass, patch_mask))
        split = Image.new("L", size, 0)
        split_draw = ImageDraw.Draw(split)
        # Keep the split entirely in the 16px lower rail; it must never cut the
        # provider Button inset even though it belongs to the left fixed cap.
        split_draw.line(((25, 283), (31, 287), (39, 283), (47, 288)), fill=255, width=3)
        split_draw.line(((31, 287), (28, 290)), fill=210, width=2)
        shell.putalpha(ImageChops.subtract(shell.getchannel("A"), split))
    else:
        raise ValueError(f"unknown variant: {variant}")
    return shell


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    image = image.convert("RGBA")
    alpha = image.getchannel("A")
    zero = Image.new("L", image.size, 0)
    # Clear only fully transparent RGB. Keeping RGB unchanged at alpha 1..254
    # avoids accidentally premultiplying/darkening the antialiased edge twice.
    visible = alpha.point(lambda value: 255 if value else 0)
    channels = [Image.composite(channel, zero, visible) for channel in image.split()[:3]]
    return Image.merge("RGBA", (*channels, alpha))


def build_shells(spec: dict, materials: dict[str, Image.Image]) -> ShellSet:
    source_size = tuple(spec["deterministic_builder"]["normalized_source"])
    runtime_size = tuple(spec["deterministic_builder"]["runtime"])
    outer, inner = _base_masks(source_size)
    rim = ImageChops.subtract(outer, inner)
    sources: dict[str, Image.Image] = {}
    runtimes: dict[str, Image.Image] = {}

    for index, variant in enumerate(spec["deterministic_builder"]["variant_order"]):
        leather = _cover(materials["leather"], source_size, (index * 29 - 38, 7 - index * 3))
        liner = _cover(materials["liner"], source_size, (-index * 19, index * 4 - 9))
        shell = Image.new("RGBA", source_size, (0, 0, 0, 0))
        shell.alpha_composite(_masked_texture(liner, ImageChops.multiply(inner, outer)))
        shell.alpha_composite(_masked_texture(leather, rim))
        shell = _multiply_shading(shell, variant)
        shell = _apply_variant(shell, variant, materials, outer)
        shell = clear_transparent_rgb(shell)
        runtime = shell.resize(runtime_size, Image.Resampling.LANCZOS)
        runtime = clear_transparent_rgb(runtime)
        sources[variant] = shell
        runtimes[variant] = runtime
    return ShellSet(materials=materials, sources=sources, runtimes=runtimes)


def _checker(size: tuple[int, int], step: int = 16) -> Image.Image:
    image = Image.new("RGBA", size, (35, 33, 30, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], step):
        for x in range(0, size[0], step):
            if (x // step + y // step) % 2:
                draw.rectangle((x, y, x + step - 1, y + step - 1), fill=(52, 49, 44, 255))
    return image


def save_shell_set(
    shells: ShellSet,
    output_dir: Path,
    file_tag: str = "simulation",
) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    for variant, source in shells.sources.items():
        source.save(output_dir / f"UF-Raid-A2-{variant}-source-{file_tag}.png")
        shells.runtimes[variant].save(
            output_dir / f"UF-Raid-A2-{variant}-runtime-{file_tag}.png"
        )


def render_source_preview(
    spec: dict,
    shells: ShellSet,
    material_mode: str = "simulation",
) -> Image.Image:
    canvas = Image.new("RGBA", (1380, 950), (22, 20, 18, 255))
    draw = ImageDraw.Draw(canvas)
    draw.text((34, 25), "UF-RAID-A2 · deterministic shell construction", fill=(222, 192, 130, 255))
    mode_note = (
        "PRODUCTION DONOR CANDIDATE · exact geometry and A-D repair masks are Python-owned"
        if material_mode == "candidate"
        else "SIMULATION MATERIALS ONLY · exact geometry and A-D repair masks are authoritative"
    )
    draw.text((34, 52), mode_note, fill=(181, 166, 139, 255))

    for index, material_id in enumerate(("leather", "liner", "brass", "thread")):
        material = shells.materials[material_id].resize((280, 158), Image.Resampling.LANCZOS)
        x = 34 + index * 330
        canvas.alpha_composite(material.convert("RGBA"), (x, 92))
        draw.rectangle((x, 92, x + 279, 249), outline=(101, 79, 50, 255), width=2)
        sample_label = "candidate donor sample" if material_mode == "candidate" else "future donor sample"
        draw.text((x, 258), f"{sample_label}: {material_id}", fill=(173, 158, 132, 255))

    for index, variant in enumerate(("A", "B", "C", "D")):
        x = 34 + (index % 2) * 670
        y = 320 + (index // 2) * 270
        backing = _checker((608, 312), 16)
        canvas.alpha_composite(backing, (x, y))
        canvas.alpha_composite(shells.sources[variant], (x + 8, y + 8))
        draw.rectangle((x, y, x + 607, y + 311), outline=(88, 68, 43, 255), width=2)
        draw.text(
            (x + 8, y + 316),
            f"{variant} · exact 592x296 source · repair mask owned by Python",
            fill=(190, 170, 132, 255),
        )
    return canvas


def main() -> None:
    args = parse_args()
    spec = json.loads(args.spec.resolve().read_text(encoding="utf-8"))
    if bool(args.donor) == bool(args.simulation):
        raise SystemExit("choose exactly one of --donor or --simulation")
    if args.donor:
        materials = load_donor_materials(spec, args.donor.resolve())
    else:
        materials = synthetic_materials(spec)
    shells = build_shells(spec, materials)
    output_dir = args.output_dir or (
        ROOT / "generated/unitframes/raid/simulation/A2-V1/shells"
    )
    material_mode = "candidate" if args.donor else "simulation"
    save_shell_set(shells, output_dir, material_mode)
    if args.preview_output:
        preview_path = args.preview_output.resolve()
    elif args.donor:
        preview_path = output_dir.resolve().parent / "source-preview.png"
    else:
        preview_path = ROOT / spec["outputs"]["source_preview"]
    preview_path.parent.mkdir(parents=True, exist_ok=True)
    render_source_preview(spec, shells, material_mode).save(
        preview_path, format="PNG", compress_level=9
    )
    print(preview_path.resolve())
    print(output_dir.resolve())


if __name__ == "__main__":
    main()
