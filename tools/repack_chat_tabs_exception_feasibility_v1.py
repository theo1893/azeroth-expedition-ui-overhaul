#!/usr/bin/env python3
"""Build review-only deterministic CHAT.TABS fit previews.

The tool extracts each complete keyed object from a broad, non-overlapping
search region, scales it uniformly to fit the agreed inner target box, and
translates it onto a clean transparent canvas. It does not redraw candidate
pixels and its outputs are explicitly ineligible for source/runtime promotion
without a later, explicit user-authorized contract exception.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SPEC = ROOT / "tools/specs/chat_tabs_dark_exception_feasibility_v1.json"
RESAMPLE = Image.Resampling.LANCZOS


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=Path, default=DEFAULT_SPEC)
    parser.add_argument(
        "--output-root",
        type=Path,
        default=ROOT / "generated/chat/core/CHAT.TABS.DARK.V2/exception-feasibility-v1",
    )
    return parser.parse_args()


def resolve(path: str | Path) -> Path:
    value = Path(path)
    return value if value.is_absolute() else ROOT / value


def display(path: Path) -> str:
    resolved = path.resolve()
    try:
        return resolved.relative_to(ROOT).as_posix()
    except ValueError:
        return str(resolved)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def absolute_bbox(image: Image.Image, region: list[int]) -> tuple[int, int, int, int]:
    local = image.getchannel("A").crop(tuple(region)).getbbox()
    if local is None:
        raise ValueError(f"no visible pixels in search region {region}")
    return (
        local[0] + region[0],
        local[1] + region[1],
        local[2] + region[0],
        local[3] + region[1],
    )


def fit_box(
    source_box: tuple[int, int, int, int],
    target_box: list[int],
    vertical_alignment: str,
) -> tuple[int, int, int, int]:
    source_width = source_box[2] - source_box[0]
    source_height = source_box[3] - source_box[1]
    target_width = target_box[2] - target_box[0]
    target_height = target_box[3] - target_box[1]
    scale = min(target_width / source_width, target_height / source_height)
    width = max(1, round(source_width * scale))
    height = max(1, round(source_height * scale))
    left = target_box[0] + (target_width - width) // 2
    if vertical_alignment == "bottom":
        top = target_box[3] - height
    elif vertical_alignment == "center":
        top = target_box[1] + (target_height - height) // 2
    else:
        raise ValueError(f"unsupported vertical_alignment: {vertical_alignment}")
    return (left, top, left + width, top + height)


def clean_transparent_rgb(image: Image.Image) -> Image.Image:
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            red, green, blue, alpha = pixels[x, y]
            if alpha == 0 and (red or green or blue):
                pixels[x, y] = (0, 0, 0, 0)
    return image


def build_one(
    donor: dict[str, Any],
    objects: list[dict[str, Any]],
    canvas_size: tuple[int, int],
    output_root: Path,
) -> dict[str, Any]:
    source_path = resolve(donor["path"])
    actual_sha = sha256(source_path)
    if actual_sha != donor["sha256"]:
        raise ValueError(
            f"donor hash mismatch for {donor['id']}: {actual_sha} != {donor['sha256']}"
        )
    source = Image.open(source_path).convert("RGBA")
    if source.size != canvas_size:
        raise ValueError(f"unexpected donor size for {donor['id']}: {source.size}")

    output = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    object_reports: list[dict[str, Any]] = []
    for item in objects:
        source_box = absolute_bbox(source, item["search_region"])
        fitted_box = fit_box(source_box, item["target_box"], item["vertical_alignment"])
        crop = source.crop(source_box)
        resized = crop.resize(
            (fitted_box[2] - fitted_box[0], fitted_box[3] - fitted_box[1]), RESAMPLE
        )
        output.alpha_composite(resized, (fitted_box[0], fitted_box[1]))
        object_reports.append(
            {
                "id": item["id"],
                "search_region": item["search_region"],
                "source_visible_bbox": list(source_box),
                "declared_cell": item["declared_cell"],
                "target_box": item["target_box"],
                "fitted_box": list(fitted_box),
                "scale": round(
                    (fitted_box[2] - fitted_box[0]) / (source_box[2] - source_box[0]),
                    8,
                ),
                "vertical_alignment": item["vertical_alignment"],
            }
        )

    output = clean_transparent_rgb(output)
    destination_dir = output_root / donor["id"]
    destination_dir.mkdir(parents=True, exist_ok=True)
    output_path = destination_dir / "repacked-candidate.png"
    metrics_path = destination_dir / "repack.metrics.json"
    output.save(output_path, format="PNG", optimize=False, compress_level=9)
    report = {
        "schema": "aeui-chat-tabs-deterministic-fit-feasibility-result-v1",
        "component": "CHAT.TABS.DARK.V2",
        "status": "review-only / not-source / not-runtime",
        "donor": {
            "id": donor["id"],
            "label": donor["label"],
            "path": display(source_path),
            "sha256": actual_sha,
        },
        "output": {
            "path": display(output_path),
            "sha256": sha256(output_path),
            "size": list(output.size),
            "mode": output.mode,
        },
        "operation": "complete-object uniform fit and translation only",
        "objects": object_reports,
        "promotion_allowed": False,
    }
    metrics_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    return report


def main() -> None:
    args = parse_args()
    spec_path = resolve(args.spec)
    output_root = resolve(args.output_root)
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    canvas_size = tuple(spec["canvas"])
    reports = [
        build_one(donor, spec["objects"], canvas_size, output_root)
        for donor in spec["donors"]
    ]
    summary_path = output_root / "summary.json"
    summary_path.write_text(
        json.dumps(
            {
                "schema": "aeui-chat-tabs-deterministic-fit-feasibility-summary-v1",
                "spec": {
                    "path": display(spec_path),
                    "sha256": sha256(spec_path),
                },
                "imagegen_calls": 0,
                "external_uploads": 0,
                "results": reports,
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(summary_path)


if __name__ == "__main__":
    main()
