#!/usr/bin/env python3
"""Build and inspect the deterministic CHAT.FRAME dark-paper assembly mask.

The ImageGen candidate is a surface donor only. This tool owns all geometry:
it preserves the accepted V3 source canvas and alpha, applies donor pixels only
inside the fixed paper mask, and emits ignored review artifacts until a source
candidate is explicitly accepted.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps


ROOT = Path(__file__).resolve().parents[1]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--donor", type=Path)
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("generated/chat/core/CHAT.FRAME.PAPER.V1/assembly"),
    )
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def resolve(path: str | Path) -> Path:
    candidate = Path(path)
    return candidate if candidate.is_absolute() else ROOT / candidate


def polygon_mask(size: tuple[int, int], points: list[list[int]]) -> Image.Image:
    output = Image.new("L", size, 0)
    ImageDraw.Draw(output).polygon([tuple(point) for point in points], fill=255)
    return output


def build_mask(spec: dict[str, Any], source: Image.Image) -> Image.Image:
    size = tuple(spec["mask"]["size"])
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    for region in spec["mask"]["editable_polygons"]:
        draw.polygon(
            [tuple(point) for point in region["points"]],
            fill=int(region["value"]),
        )
    radius = int(spec["mask"].get("feather_radius", 0))
    if radius:
        mask = mask.filter(ImageFilter.GaussianBlur(radius=radius))
    minimum_luminance = int(spec["mask"].get("minimum_source_luminance", 0))
    source_luma = ImageOps.grayscale(source.convert("RGB"))
    if minimum_luminance:
        eligible = source_luma.point(
            lambda value: 255 if value >= minimum_luminance else 0
        )
        mask = ImageChops.multiply(mask, eligible)
    for region in spec["mask"].get("conditional_protection", []):
        area = polygon_mask(size, region["points"])
        threshold = int(region["preserve_when_luminance_below"])
        darker = source_luma.point(lambda value: 255 if value < threshold else 0)
        protected = ImageChops.multiply(area, darker)
        mask = ImageChops.subtract(mask, protected)
    draw = ImageDraw.Draw(mask)
    for region in spec["mask"].get("protected_polygons", []):
        draw.polygon([tuple(point) for point in region["points"]], fill=0)
    return mask


def shade_donor(source: Image.Image, donor: Image.Image) -> Image.Image:
    donor_rgb = ImageOps.fit(
        donor.convert("RGB"), source.size, method=Image.Resampling.LANCZOS
    )
    source_luma = ImageOps.grayscale(source.convert("RGB"))
    shade = source_luma.point(
        lambda value: max(150, min(242, round(190 + (value - 128) * 0.35)))
    )
    shade_rgb = Image.merge("RGB", (shade, shade, shade))
    multiplied = ImageChops.multiply(donor_rgb, shade_rgb)
    # Normalize the brightest permitted shade back to the donor value so that
    # central paper remains near #18120D while stacked edges retain depth.
    return multiplied.point(lambda value: min(255, round(value * 255 / 242)))


def count_nonzero(channel: Image.Image) -> int:
    histogram = channel.histogram()
    return sum(histogram[1:])


def main() -> None:
    args = parse_args()
    spec_path = args.spec.resolve()
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    source_path = resolve(spec["source"]["path"])
    source = Image.open(source_path).convert("RGBA")
    if list(source.size) != spec["source"]["size"]:
        raise ValueError(f"source size mismatch: {source.size}")
    if sha256(source_path) != spec["source"]["sha256"]:
        raise ValueError("source SHA-256 mismatch")

    output_dir = resolve(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    mask = build_mask(spec, source)
    mask_path = output_dir / "ChatBookPaperMaskV1.png"
    mask.save(mask_path, format="PNG", optimize=False, compress_level=9)

    overlay_color = Image.new("RGBA", source.size, (20, 205, 255, 118))
    overlay_alpha = mask.point(lambda value: round(value * 0.46))
    overlay_color.putalpha(overlay_alpha)
    overlay = Image.alpha_composite(source, overlay_color)
    overlay_path = output_dir / "ChatBookPaperMaskV1.overlay.png"
    overlay.save(overlay_path, format="PNG", optimize=False, compress_level=9)

    report: dict[str, Any] = {
        "schema": "aeui-chat-dark-paper-assembly-report-v1",
        "version": spec["version"],
        "source": {
            "path": source_path.relative_to(ROOT).as_posix(),
            "sha256": sha256(source_path),
            "size": list(source.size),
            "mode": source.mode,
        },
        "mask": {
            "path": mask_path.relative_to(ROOT).as_posix(),
            "sha256": sha256(mask_path),
            "nonzero_pixels": count_nonzero(mask),
            "total_pixels": source.width * source.height,
        },
        "overlay": {
            "path": overlay_path.relative_to(ROOT).as_posix(),
            "sha256": sha256(overlay_path),
        },
        "donor": None,
        "assembly": None,
    }

    if args.donor:
        donor_path = args.donor.resolve()
        donor = Image.open(donor_path)
        shaded_donor = shade_donor(source, donor)
        assembled_rgb = Image.composite(shaded_donor, source.convert("RGB"), mask)
        assembled = assembled_rgb.convert("RGBA")
        assembled.putalpha(source.getchannel("A"))
        assembled_path = output_dir / "ChatBookFrame_Master_darkpaper_v1.candidate.png"
        assembled.save(assembled_path, format="PNG", optimize=False, compress_level=9)

        alpha_difference = ImageChops.difference(
            source.getchannel("A"), assembled.getchannel("A")
        )
        outside_mask = mask.point(lambda value: 255 if value == 0 else 0)
        rgb_difference = ImageChops.difference(
            source.convert("RGB"), assembled.convert("RGB")
        ).convert("L")
        outside_difference = ImageChops.multiply(rgb_difference, outside_mask)
        report["donor"] = {
            "path": donor_path.as_posix(),
            "sha256": sha256(donor_path),
            "size": list(donor.size),
            "mode": donor.mode,
        }
        report["assembly"] = {
            "path": assembled_path.relative_to(ROOT).as_posix(),
            "sha256": sha256(assembled_path),
            "size": list(assembled.size),
            "mode": assembled.mode,
            "alpha_difference_pixels": count_nonzero(alpha_difference),
            "outside_mask_rgb_difference_pixels": count_nonzero(outside_difference),
        }

    report_path = output_dir / "ChatBookPaperAssemblyV1.report.json"
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(mask_path.resolve())
    print(overlay_path.resolve())
    print(report_path.resolve())


if __name__ == "__main__":
    main()
