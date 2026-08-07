#!/usr/bin/env python3
"""Promote and export the accepted QS-B1 V7-A purity-ribbon carrier.

This builder is intentionally narrow.  It accepts only the exact user-approved
attempt-05 composite, byte-copies it to durable source, performs the single
authorized proportional LANCZOS reduction, clears RGB where Alpha is zero, and
writes the 32x192 TGA used by the addon.  It does not redraw, crop, bbox-fit,
mirror, stretch, recolour, or synthesize the seven still-pending action motifs.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import struct
from typing import Any

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (
    ROOT
    / "assets"
    / "source"
    / "quests"
    / "qs-b1"
    / "QuestLogSealPurityRibbon_Master_v1.png"
)
RUNTIME = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Quests"
    / "QuestLogSealPurityRibbonV1.tga"
)
EXPECTED_ACCEPTED_SHA256 = (
    "168f527fffa09beb281c7e0bbca6076dcd00e7f827febb6cce9a853f461e05b8"
)
SOURCE_SIZE = (128, 768)
RUNTIME_SIZE = (32, 192)
EXPECTED_SOURCE_BBOX = (9, 0, 119, 767)
RESAMPLE = Image.Resampling.LANCZOS


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=ROOT,
        help="repository root; defaults to the checkout containing this tool",
    )
    parser.add_argument(
        "--promote-from",
        type=Path,
        required=True,
        help="exact accepted attempt-05 composite",
    )
    parser.add_argument(
        "--evidence-dir",
        type=Path,
        default=Path(
            "generated/quests/QUEST-SEALS/QS-B1-V7-A/accepted-runtime"
        ),
    )
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def repo_path(root: Path, path: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def transparent_rgb_nonzero_values(image: Image.Image) -> int:
    rgba = np.asarray(image.convert("RGBA"))
    return int(np.count_nonzero(rgba[rgba[:, :, 3] == 0, :3]))


def green_spill_pixels(image: Image.Image) -> int:
    rgba = np.asarray(image.convert("RGBA"))
    visible = rgba[:, :, 3] > 0
    green = (
        (rgba[:, :, 0] <= 32)
        & (rgba[:, :, 1] >= 224)
        & (rgba[:, :, 2] <= 32)
    )
    return int(np.count_nonzero(visible & green))


def alpha_evidence(image: Image.Image) -> dict[str, int]:
    histogram = image.convert("RGBA").getchannel("A").histogram()
    return {
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
    }


def image_record(root: Path, path: Path, image: Image.Image) -> dict[str, Any]:
    bbox = image.convert("RGBA").getchannel("A").getbbox()
    return {
        "file": repo_path(root, path),
        "sha256": sha256(path),
        "width": image.width,
        "height": image.height,
        "mode": image.mode,
        "visible_bbox_exclusive": list(bbox or ()),
        "visible_green_spill_pixels": green_spill_pixels(image),
        "transparent_rgb_nonzero_values": transparent_rgb_nonzero_values(
            image
        ),
        **alpha_evidence(image),
    }


def tga_header(path: Path) -> dict[str, int | bool]:
    raw = path.read_bytes()[:18]
    if len(raw) != 18:
        raise ValueError("runtime TGA header is incomplete")
    return {
        "image_type": raw[2],
        "width": struct.unpack_from("<H", raw, 12)[0],
        "height": struct.unpack_from("<H", raw, 14)[0],
        "bits_per_pixel": raw[16],
        "descriptor": raw[17],
        "top_origin": bool(raw[17] & 0x20),
    }


def validate_accepted(path: Path, image: Image.Image) -> None:
    if sha256(path) != EXPECTED_ACCEPTED_SHA256:
        raise ValueError("promotion input is not accepted V7-A attempt 5")
    if image.size != SOURCE_SIZE or image.mode != "RGBA":
        raise ValueError("accepted V7-A source must be 128x768 RGBA")
    bbox = image.getchannel("A").getbbox()
    if bbox != EXPECTED_SOURCE_BBOX:
        raise ValueError(
            f"accepted V7-A visible bbox changed: {bbox!r}"
        )
    if transparent_rgb_nonzero_values(image):
        raise ValueError("accepted V7-A transparent RGB is not zero")
    if green_spill_pixels(image):
        raise ValueError("accepted V7-A contains visible chroma-key green")


def load_review_module(root: Path) -> Any:
    path = root / "tools/review_quest_seal_purity_ribbon_candidate_v1.py"
    spec = importlib.util.spec_from_file_location(
        "aeui_qs_b1_v7a_runtime_layout", path
    )
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main() -> None:
    args = parse_args()
    root = args.repo_root.expanduser().resolve()
    promote_from = args.promote_from.expanduser().resolve()
    source = root / SOURCE.relative_to(ROOT)
    runtime = root / RUNTIME.relative_to(ROOT)
    evidence_dir = args.evidence_dir.expanduser()
    if not evidence_dir.is_absolute():
        evidence_dir = root / evidence_dir
    evidence_dir.mkdir(parents=True, exist_ok=True)

    with Image.open(promote_from) as opened:
        accepted = opened.copy()
    validate_accepted(promote_from, accepted)

    source.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(promote_from, source)
    with Image.open(source) as opened:
        durable_source = opened.copy()
    validate_accepted(source, durable_source)

    runtime_image = clear_transparent_rgb(
        durable_source.resize(RUNTIME_SIZE, RESAMPLE)
    )
    if runtime_image.size != RUNTIME_SIZE or runtime_image.mode != "RGBA":
        raise ValueError("runtime export is not 32x192 RGBA")
    if transparent_rgb_nonzero_values(runtime_image):
        raise ValueError("runtime transparent RGB is not zero")
    if green_spill_pixels(runtime_image):
        raise ValueError("runtime export contains visible chroma-key green")

    runtime.parent.mkdir(parents=True, exist_ok=True)
    runtime_image.save(runtime, "TGA")
    preview_path = evidence_dir / "QS-B1-V7A.runtime-master.png"
    runtime_image.save(preview_path, "PNG")

    review = load_review_module(root)
    layout_path = evidence_dir / "QS-B1-V7A.real-layout.png"
    preview_dir = evidence_dir / "detail-previews"
    simulation_path = (
        root
        / "tools/specs/quest_log_seal_purity_ribbon_simulation_v17.json"
    )
    _, state_metrics, layout_checks, previews = review.render_real_layout(
        root,
        simulation_path,
        runtime_image,
        layout_path,
        preview_dir,
    )
    if not all(layout_checks.values()):
        failed = [name for name, passed in layout_checks.items() if not passed]
        raise ValueError(f"real-layout checks failed: {failed}")

    report = {
        "schema": "aeui.quest-log.seal-purity-ribbon.export-report.v1",
        "batch": "QS-B1 V7-A",
        "status": "pass",
        "accepted_input": {
            "file": repo_path(root, promote_from),
            "sha256": sha256(promote_from),
        },
        "source": image_record(root, source, durable_source),
        "transform": {
            "operation": (
                "byte-exact accepted-source promotion, one full-canvas "
                "proportional LANCZOS reduction, transparent RGB zeroing, "
                "and TGA conversion"
            ),
            "resample": "Pillow Image.Resampling.LANCZOS",
            "crop": None,
            "bbox_fit": False,
            "anisotropic_resize": False,
            "mirror": False,
            "rotation": None,
            "retouch": False,
        },
        "runtime": {
            **image_record(root, runtime, runtime_image),
            "tga_header": tga_header(runtime),
        },
        "real_layout": {
            "file": repo_path(root, layout_path),
            "sha256": sha256(layout_path),
            "checks_passed": sum(layout_checks.values()),
            "checks_total": len(layout_checks),
            "checks": layout_checks,
            "state_metrics": state_metrics,
            "detail_previews": previews,
        },
    }
    report_path = evidence_dir / "QS-B1-V7A.export-report.json"
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
