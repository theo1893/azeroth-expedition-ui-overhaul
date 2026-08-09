#!/usr/bin/env python3
"""Tracked P5 source and runtime provenance checks for Field Kit."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
EXACT_ACCEPTANCE = (
    "接受 AB.TRINKET.KIT.V1 第4稿与 AB.CONSUMABLE.KIT.V1 第1稿"
)
CASES = (
    {
        "component": "AB.TRINKET.KIT.V1",
        "accepted_version": "AB.TRINKET.KIT.V1.r3 / attempt 4 canonical",
        "source": ROOT
        / "assets/source/actionbars/ab-trinket-kit/ActionTrinketKit_Master_v1.png",
        "manifest": ROOT
        / "assets/source/actionbars/ab-trinket-kit/AB-TRINKET-KIT-V1_SourceManifest_v1.json",
        "runtime_manifest": ROOT
        / "assets/source/actionbars/ab-trinket-kit/AB-TRINKET-KIT-V1_RuntimeManifest_v1.json",
        "runtime": ROOT
        / "addon/AzerothExpeditionUI/Media/ActionBars/ActionTrinketKitV1.tga",
        "runtime_file": "addon/AzerothExpeditionUI/Media/ActionBars/ActionTrinketKitV1.tga",
        "runtime_sha256": "3614d9a86e1dc25399e6623ddfad398618070e8f78117ec0f0b997b9b3f9f455",
        "runtime_pixel_sha256": "0961d750d7436665a333d948ba010a212c5de6f87c51ab59a10ed8af86ac4aef",
        "sha256": "82dd2260757616912a7ef78658cc230f66d89614613d64e85f8116cac284c012",
        "bbox": (80, 80, 944, 941),
        "counts": (646693, 16995, 384888),
        "calls": 4,
        "unused": 1,
        "cells": {
            "A": ((82, 80, 429, 432), [82, 80, 83, 80]),
            "B": ((80, 81, 432, 430), [80, 81, 80, 82]),
            "C": ((80, 82, 432, 429), [80, 82, 80, 83]),
            "D": ((80, 196, 432, 315), [80, 196, 80, 197]),
        },
    },
    {
        "component": "AB.CONSUMABLE.KIT.V1",
        "accepted_version": (
            "AB.CONSUMABLE.KIT.V1.transport / attempt 1 canonical"
        ),
        "source": ROOT
        / "assets/source/actionbars/ab-consumable-kit/ActionConsumableKit_Master_v1.png",
        "manifest": ROOT
        / "assets/source/actionbars/ab-consumable-kit/AB-CONSUMABLE-KIT-V1_SourceManifest_v1.json",
        "runtime_manifest": ROOT
        / "assets/source/actionbars/ab-consumable-kit/AB-CONSUMABLE-KIT-V1_RuntimeManifest_v1.json",
        "runtime": ROOT
        / "addon/AzerothExpeditionUI/Media/ActionBars/ActionConsumableKitV1.tga",
        "runtime_file": "addon/AzerothExpeditionUI/Media/ActionBars/ActionConsumableKitV1.tga",
        "runtime_sha256": "c48f6292336446d2cc0cbbfc811cde9903b06eeb41e6c9f4db49e4f13fd9320e",
        "runtime_pixel_sha256": "658f826f5ffb52f77530d5e288f99ac9511db1317129aea7f64c4c8e7ea4e30d",
        "sha256": "623f29c5e16ea73c50778b462c2d79a4eb2dd4928b9a1d94f30876f13caa2419",
        "bbox": (80, 83, 944, 944),
        "counts": (670302, 17423, 360851),
        "calls": 1,
        "unused": 4,
        "cells": {
            "A": ((80, 87, 432, 425), [80, 87, 80, 87]),
            "B": ((80, 83, 432, 429), [80, 83, 80, 83]),
            "C": ((80, 80, 432, 432), [80, 80, 80, 80]),
            "D": ((80, 226, 432, 286), [80, 226, 80, 226]),
        },
    },
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    for case in CASES:
        source_path = case["source"]
        manifest = json.loads(case["manifest"].read_text(encoding="utf-8"))
        runtime_manifest = json.loads(
            case["runtime_manifest"].read_text(encoding="utf-8")
        )

        assert sha256(source_path) == case["sha256"]
        assert manifest["schema_version"] == 1
        assert manifest["module"] == "actionbars"
        assert manifest["batch"] == "AB.FIELDKIT.V1"
        assert manifest["component"] == case["component"]
        assert manifest["accepted_version"] == case["accepted_version"]
        assert manifest["status"] == "runtime-exported"
        assert manifest["workflow_state"] == "runtime-exported"
        assert manifest["project_phase"] == "P5"
        assert manifest["source"]["sha256"] == case["sha256"]
        assert manifest["provenance"]["accepted_candidate_sha256"] == (
            case["sha256"]
        )
        assert manifest["provenance"]["actual_imagegen_calls_in_loop"] == (
            case["calls"]
        )
        assert manifest["provenance"]["unused_authorized_calls"] == (
            case["unused"]
        )
        assert (
            manifest["provenance"]["additional_imagegen_calls_after_acceptance"]
            == 0
        )
        assert manifest["provenance"]["attempt_6_allowed"] is False
        assert manifest["user_acceptance"]["exact_statement"] == (
            EXACT_ACCEPTANCE
        )
        assert manifest["user_acceptance"]["accepted_candidate_sha256"] == (
            case["sha256"]
        )
        assert manifest["handoff"]["status"] == "not-published"
        assert manifest["export_contract"]["status"] == "exported"
        assert manifest["export_contract"]["runtime_file"] == (
            case["runtime_file"]
        )
        assert manifest["export_contract"]["runtime_sha256"] == (
            case["runtime_sha256"]
        )
        assert manifest["export_contract"]["imagegen_calls_after_acceptance"] == 0
        assert manifest["p5_validation"]["display_region_violations"] == 0
        expected_scenarios = 9 if case["component"] == "AB.TRINKET.KIT.V1" else 10
        assert manifest["p5_validation"]["real_layout_scenarios"] == (
            f"{expected_scenarios}/{expected_scenarios} pass"
        )
        assert manifest["p5_validation"]["game_validated"] is False

        assert sha256(case["runtime"]) == case["runtime_sha256"]
        assert runtime_manifest["runtime_contract"] == "1.4"
        assert runtime_manifest["status"] == "runtime-exported"
        assert runtime_manifest["phase"] == "P5"
        assert runtime_manifest["source"]["sha256"] == case["sha256"]
        assert runtime_manifest["runtime_export"]["file"] == case["runtime_file"]
        assert runtime_manifest["runtime_export"]["sha256"] == (
            case["runtime_sha256"]
        )
        assert runtime_manifest["runtime_export"]["pixel_sha256"] == (
            case["runtime_pixel_sha256"]
        )
        assert runtime_manifest["adapter"]["visual_layers_only"] is False
        assert runtime_manifest["adapter"]["visual_and_layout_adapter"] is True
        assert runtime_manifest["adapter"]["provider_geometry_writes"] is True
        assert runtime_manifest["adapter"]["provider_behavior_replaced"] is False
        assert runtime_manifest["adapter"]["saved_variables_written"] is True
        assert runtime_manifest["adapter"][
            "provider_saved_variables_written_automatically"
        ] is False
        assert runtime_manifest["adapter"][
            "aeui_saved_variables_written_on_drag_stop"
        ] is True
        assert runtime_manifest["adapter"]["autobar_enabled_or_profile_applied"] is False
        assert runtime_manifest["game_validation"]["status"] == "pending-retest"

        with Image.open(source_path) as opened:
            assert opened.format == "PNG"
            assert opened.mode == "RGBA"
            assert opened.size == (1024, 1024)
            source = opened.copy()

        alpha = source.getchannel("A")
        assert alpha.getbbox() == case["bbox"]
        pixels = list(source.getdata())
        transparent = sum(1 for *_, value in pixels if value == 0)
        partial = sum(1 for *_, value in pixels if 0 < value < 255)
        opaque = sum(1 for *_, value in pixels if value == 255)
        visible_green = sum(
            1
            for red, green, blue, value in pixels
            if value > 0 and red == 0 and green == 255 and blue == 0
        )
        transparent_rgb_nonzero = sum(
            1
            for red, green, blue, value in pixels
            if value == 0 and (red != 0 or green != 0 or blue != 0)
        )
        assert (transparent, partial, opaque) == case["counts"]
        source_record = manifest["source"]
        assert source_record["visible_bbox_exclusive"] == list(case["bbox"])
        assert source_record["transparent_pixels"] == transparent
        assert source_record["partially_transparent_pixels"] == partial
        assert source_record["opaque_pixels"] == opaque
        assert source_record["visible_green_spill_pixels"] == visible_green == 0
        assert (
            source_record["transparent_rgb_nonzero_values"]
            == transparent_rgb_nonzero
            == 0
        )

        for index, cell_name in enumerate(("A", "B", "C", "D")):
            left = 512 if index % 2 else 0
            top = 512 if index // 2 else 0
            cell_alpha = alpha.crop((left, top, left + 512, top + 512))
            expected_bbox, expected_margins = case["cells"][cell_name]
            assert cell_alpha.getbbox() == expected_bbox
            cell_record = source_record["cells"][cell_name]
            assert cell_record["visible_bbox_local_exclusive"] == list(
                expected_bbox
            )
            assert cell_record["margins_ltrb"] == expected_margins
            assert cell_record["minimum_margin"] == 80

        assert [item["cell"] for item in manifest["logical_components"]] == [
            "A",
            "B",
            "C",
            "D",
        ]

    print("action field kit source test passed")


if __name__ == "__main__":
    main()
