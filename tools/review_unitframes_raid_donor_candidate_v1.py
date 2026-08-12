#!/usr/bin/env python3
"""Review one UF-RAID-A2 material donor and its deterministic shell contract."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import sys

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PRODUCTION = ROOT / "tools/specs/unitframes_raid_donor_production_v1.json"
DEFAULT_SIMULATION = ROOT / "tools/specs/unitframes_raid_donor_simulation_v1.json"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--production-spec", type=Path, default=DEFAULT_PRODUCTION)
    parser.add_argument("--simulation-spec", type=Path, default=DEFAULT_SIMULATION)
    parser.add_argument("--report", type=Path, required=True)
    parser.add_argument("--cell-tolerance", type=int, default=3)
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def relative(path: Path) -> str:
    resolved = path.resolve()
    try:
        return resolved.relative_to(ROOT).as_posix()
    except ValueError:
        return str(resolved)


def green_mask(rgb: np.ndarray) -> np.ndarray:
    channels = rgb.astype(np.int16)
    red = channels[:, :, 0]
    green = channels[:, :, 1]
    blue = channels[:, :, 2]
    return (green >= 160) & (green >= red + 55) & (green >= blue + 55)


def detected_material_bbox(
    material_mask: np.ndarray,
    quadrant: tuple[int, int, int, int],
) -> list[int] | None:
    x0, y0, x1, y1 = quadrant
    ys, xs = np.where(material_mask[y0:y1, x0:x1])
    if not len(xs):
        return None
    return [
        int(x0 + xs.min()),
        int(y0 + ys.min()),
        int(x0 + xs.max() + 1),
        int(y0 + ys.max() + 1),
    ]


def box_delta(actual: list[int] | None, expected: list[int]) -> list[int] | None:
    if actual is None:
        return None
    return [int(actual[index] - expected[index]) for index in range(4)]


def material_metrics(
    rgb: np.ndarray,
    green: np.ndarray,
    contract: dict,
    quadrant: tuple[int, int, int, int],
    tolerance: int,
) -> dict:
    cell = [int(value) for value in contract["cell"]]
    sample = [int(value) for value in contract["sample_window"]]
    x0, y0, x1, y1 = cell
    sx0, sy0, sx1, sy1 = sample
    actual = detected_material_bbox(~green, quadrant)
    delta = box_delta(actual, cell)
    exact_enough = delta is not None and max(abs(value) for value in delta) <= tolerance
    sample_rgb = rgb[sy0:sy1, sx0:sx1].astype(np.float64)
    luminance = (
        0.2126 * sample_rgb[:, :, 0]
        + 0.7152 * sample_rgb[:, :, 1]
        + 0.0722 * sample_rgb[:, :, 2]
    )
    gradient_x = np.abs(np.diff(luminance, axis=1)).mean()
    gradient_y = np.abs(np.diff(luminance, axis=0)).mean()
    return {
        "cell": cell,
        "sample_window": sample,
        "detected_material_bbox": actual,
        "detected_minus_contract": delta,
        "cell_bbox_within_tolerance": exact_enough,
        "cell_tolerance_px": tolerance,
        "green_pixels_in_contract_cell": int(green[y0:y1, x0:x1].sum()),
        "green_pixels_in_sample_window": int(green[sy0:sy1, sx0:sx1].sum()),
        "sample_rgb_mean": [
            round(float(sample_rgb[:, :, channel].mean()), 3) for channel in range(3)
        ],
        "sample_luminance_mean": round(float(luminance.mean()), 3),
        "sample_luminance_stddev": round(float(luminance.std()), 3),
        "sample_mean_edge_delta": round(float((gradient_x + gradient_y) / 2), 3),
    }


def shell_metrics(simulation: dict, candidate: Path) -> dict:
    sys.path.insert(0, str(ROOT / "tools"))
    from build_unitframes_raid_donor_shells_v1 import (  # noqa: PLC0415
        build_shells,
        load_donor_materials,
    )

    shells = build_shells(simulation, load_donor_materials(simulation, candidate))
    inset = simulation["deterministic_builder"]["provider_button_source"]
    ix0, iy0, ix1, iy1 = inset
    records = {}
    all_pass = True
    for variant in simulation["deterministic_builder"]["variant_order"]:
        source = shells.sources[variant]
        runtime = shells.runtimes[variant]
        source_array = np.asarray(source)
        runtime_array = np.asarray(runtime)
        source_alpha = source_array[:, :, 3]
        runtime_alpha = runtime_array[:, :, 3]
        source_dirty = int(
            np.any(source_array[:, :, :3] != 0, axis=2)[source_alpha == 0].sum()
        )
        runtime_dirty = int(
            np.any(runtime_array[:, :, :3] != 0, axis=2)[runtime_alpha == 0].sum()
        )
        inset_opaque = bool(np.all(source_alpha[iy0:iy1, ix0:ix1] == 255))
        variant_pass = (
            source.size == (592, 296)
            and runtime.size == (74, 37)
            and inset_opaque
            and source_dirty == 0
            and runtime_dirty == 0
        )
        all_pass = all_pass and variant_pass
        records[variant] = {
            "source_size": list(source.size),
            "runtime_size": list(runtime.size),
            "provider_inset_fully_opaque": inset_opaque,
            "source_transparent_rgb_dirty_pixels": source_dirty,
            "runtime_transparent_rgb_dirty_pixels": runtime_dirty,
            "source_alpha_pixels": {
                "transparent": int((source_alpha == 0).sum()),
                "partial": int(((source_alpha > 0) & (source_alpha < 255)).sum()),
                "opaque": int((source_alpha == 255).sum()),
            },
            "runtime_alpha_pixels": {
                "transparent": int((runtime_alpha == 0).sum()),
                "partial": int(((runtime_alpha > 0) & (runtime_alpha < 255)).sum()),
                "opaque": int((runtime_alpha == 255).sum()),
            },
            "pass": variant_pass,
        }
    return {"variants": records, "pass": all_pass}


def main() -> None:
    args = parse_args()
    candidate = args.candidate.resolve()
    production = json.loads(args.production_spec.resolve().read_text(encoding="utf-8"))
    simulation = json.loads(args.simulation_spec.resolve().read_text(encoding="utf-8"))
    with Image.open(candidate) as opened:
        source_mode = opened.mode
        source_format = opened.format
        image = opened.convert("RGB")
    rgb = np.asarray(image)
    green = green_mask(rgb)
    exact_green = np.all(rgb == np.array([0, 255, 0], dtype=np.uint8), axis=2)
    quadrants = {
        "leather": (0, 0, 768, 512),
        "liner": (768, 0, 1536, 512),
        "brass": (0, 512, 768, 1024),
        "thread": (768, 512, 1536, 1024),
    }
    materials = {
        material_id: material_metrics(
            rgb,
            green,
            contract,
            quadrants[material_id],
            args.cell_tolerance,
        )
        for material_id, contract in production["output_contract"]["cells"].items()
    }
    canvas_pass = image.size == (1536, 1024) and source_mode == "RGB"
    samples_pass = all(
        metrics["green_pixels_in_sample_window"] == 0
        for metrics in materials.values()
    )
    cells_pass = all(
        metrics["green_pixels_in_contract_cell"] == 0
        and metrics["cell_bbox_within_tolerance"]
        for metrics in materials.values()
    )
    shells = shell_metrics(simulation, candidate)
    technical_pass = canvas_pass and samples_pass and cells_pass and shells["pass"]
    report = {
        "schema": "aeui-unitframes-raid-donor-candidate-review-v1",
        "candidate": relative(candidate),
        "sha256": sha256(candidate),
        "format": source_format,
        "source_mode": source_mode,
        "size": list(image.size),
        "canvas_pass": canvas_pass,
        "green_pixels": {
            "exact_00ff00": int(exact_green.sum()),
            "dominant_chroma_key": int(green.sum()),
        },
        "materials": materials,
        "sample_windows_pass": samples_pass,
        "fixed_cells_pass": cells_pass,
        "deterministic_shells": shells,
        "technical_pass": technical_pass,
        "result": "technical-pass" if technical_pass else "technical-fail",
        "semantic_warning": (
            "Metrics do not prove hand-painted period style, material identity, "
            "microtexture scale, focal restraint or runtime visual hierarchy."
        ),
    }
    args.report.resolve().parent.mkdir(parents=True, exist_ok=True)
    args.report.resolve().write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
