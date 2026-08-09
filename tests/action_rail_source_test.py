#!/usr/bin/env python3
"""Tracked source and manifest checks for accepted AB.RAIL.V1."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (
    ROOT / "assets/source/actionbars/ab-rail/ActionRail_Master_v1.png"
)
MANIFEST = SOURCE.with_name("AB-RAIL-V1_SourceManifest_v1.json")
P6_EVIDENCE = (
    ROOT
    / "assets/references/actionbars/p6/AB-RAIL-V1_P6Evidence_v1.json"
)
P6_SCREENSHOT = (
    ROOT
    / "assets/references/actionbars/p6/AB-RAIL-V1_TurtleWoW_P6_2026-08-09.png"
)
EXPECTED_SHA256 = (
    "7c49995d45b88f5ac12020c4b158027674b7ab7ed6e44a992e643f2ef6bd32e9"
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))

    assert sha256(SOURCE) == EXPECTED_SHA256
    assert manifest["schema_version"] == 1
    assert manifest["module"] == "actionbars"
    assert manifest["batch"] == "AB.RAIL.V1"
    assert manifest["component"] == "AB.RAIL"
    assert manifest["status"] == "game-validated"
    assert manifest["workflow_state"] == "game-validated"
    assert manifest["project_phase"] == "P6"
    assert manifest["source"]["sha256"] == EXPECTED_SHA256
    assert manifest["provenance"]["actual_imagegen_calls_in_loop"] == 5
    assert manifest["provenance"]["process_errors_without_generation"] == 0
    assert manifest["provenance"]["additional_imagegen_calls_after_acceptance"] == 0
    assert manifest["provenance"]["attempt_6_allowed"] is False
    assert manifest["user_acceptance"]["exact_statement"] == (
        "接受 AB.RAIL.V1 第5稿"
    )
    assert manifest["user_acceptance"]["accepted_candidate_sha256"] == (
        EXPECTED_SHA256
    )

    with Image.open(SOURCE) as opened:
        assert opened.format == "PNG"
        assert opened.mode == "RGBA"
        assert opened.size == (1024, 1024)
        source = opened.copy()

    assert source.getchannel("A").getbbox() == (160, 160, 864, 864)
    pixels = list(source.getdata())
    transparent = sum(1 for _, _, _, alpha in pixels if alpha == 0)
    partial = sum(1 for _, _, _, alpha in pixels if 0 < alpha < 255)
    opaque = sum(1 for _, _, _, alpha in pixels if alpha == 255)
    visible_green = sum(
        1
        for red, green, blue, alpha in pixels
        if alpha > 0 and red == 0 and green == 255 and blue == 0
    )
    transparent_rgb_nonzero = sum(
        1
        for red, green, blue, alpha in pixels
        if alpha == 0 and (red != 0 or green != 0 or blue != 0)
    )
    source_record = manifest["source"]
    assert [transparent, partial, opaque] == [555871, 12483, 480222]
    assert source_record["visible_bbox_exclusive"] == [160, 160, 864, 864]
    assert source_record["visible_size"] == [704, 704]
    assert source_record["transparent_pixels"] == transparent
    assert source_record["partially_transparent_pixels"] == partial
    assert source_record["opaque_pixels"] == opaque
    assert source_record["visible_green_spill_pixels"] == visible_green == 0
    assert (
        source_record["transparent_rgb_nonzero_values"]
        == transparent_rgb_nonzero
        == 0
    )

    export = manifest["export_contract"]
    assert export["status"] == "exported"
    assert export["authorization"] == (
        "user instruction '进行下一步' on 2026-08-09"
    )
    assert export["runtime_file"] == (
        "addon/AzerothExpeditionUI/Media/ActionBars/ActionRailV1.tga"
    )
    assert export["accepted_source_crop_exclusive"] == [160, 160, 864, 864]
    assert export["accepted_source_crop_size"] == [704, 704]
    assert export["source_nine_slice_boundaries"] == [0, 128, 576, 704]
    assert export["source_stretch_center"] == [128, 128, 576, 576]
    assert export["runtime_atlas_size"] == [256, 256]
    assert export["runtime_visible_bbox_exclusive"] == [40, 40, 216, 216]
    assert export["runtime_nine_slice_boundaries"] == [40, 72, 184, 216]
    assert export["runtime_cell_sizes"] == [32, 112, 32]
    assert export["runtime_cap_ui"] == 6
    assert export["imagegen_calls_after_acceptance"] == 0

    review = manifest["review"]
    assert review["source_visual_accepted"] is True
    assert review["technical_checks"] == "4/4 pass"
    assert review["real_layout_scenarios"] == "8/8 pass"
    assert review["display_region_violations"] == 0

    assert manifest["p5_validation"]["real_layout_scenarios"] == "8/8 pass"
    assert manifest["p5_validation"]["display_region_violations"] == 0
    assert manifest["p5_validation"]["game_validated"] is True

    p6 = manifest["p6_validation"]
    assert p6["status"] == "pass"
    assert p6["validated_on"] == "2026-08-09"
    assert p6["aggregate_p6_checklist"] == "pass"
    assert p6["additional_imagegen_calls"] == 0
    assert p6["evidence_record_sha256"] == sha256(P6_EVIDENCE)
    assert p6["screenshot_sha256"] == sha256(P6_SCREENSHOT)

    evidence = json.loads(P6_EVIDENCE.read_text(encoding="utf-8"))
    assert evidence["schema"] == "aeui-component-p6-evidence-v1"
    assert evidence["status"] == "game-validated"
    assert evidence["phase"] == "P6"
    assert evidence["screenshot"]["sha256"] == sha256(P6_SCREENSHOT)
    assert evidence["closure"]["status"] == "pending"

    with Image.open(P6_SCREENSHOT) as opened:
        assert opened.format == "PNG"
        assert opened.mode == "RGB"
        assert opened.size == (580, 129)

    print("action rail source test passed")


if __name__ == "__main__":
    main()
