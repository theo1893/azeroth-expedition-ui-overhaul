#!/usr/bin/env python3
"""Deterministic media, adapter, and display checks for AB.RAIL.V1."""

from __future__ import annotations

import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))

import build_action_rail_v1_runtime as builder  # noqa: E402


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    source_path = ROOT / builder.SOURCE_REL
    runtime_path = ROOT / builder.RUNTIME_REL
    source_manifest_path = ROOT / builder.SOURCE_MANIFEST_REL
    runtime_manifest_path = ROOT / builder.RUNTIME_MANIFEST_REL
    contract_path = ROOT / builder.DISPLAY_CONTRACT_REL
    adapter_path = ROOT / builder.ADAPTER_REL
    p6_evidence_path = (
        ROOT
        / "assets/references/actionbars/p6/AB-RAIL-V1_P6Evidence_v1.json"
    )
    p6_screenshot_path = (
        ROOT
        / "assets/references/actionbars/p6/AB-RAIL-V1_TurtleWoW_P6_2026-08-09.png"
    )

    source = builder.validate_source(source_path)
    rebuilt = builder.build_runtime(source)
    assert builder.pixel_sha256(rebuilt) == (
        builder.EXPECTED_RUNTIME_PIXEL_SHA256
    )
    assert builder.alpha_bbox(rebuilt) == builder.RUNTIME_OBJECT_BOX
    assert builder.visible_green_spill_pixels(rebuilt) == 0
    assert builder.transparent_rgb_nonzero_values(rebuilt) == 0

    header = runtime_path.read_bytes()[:18]
    assert header[16] == 32
    assert header[17] == 8
    with Image.open(runtime_path) as opened:
        tracked_runtime = opened.convert("RGBA")
    assert tracked_runtime.size == builder.RUNTIME_ATLAS_SIZE
    assert tracked_runtime.tobytes() == rebuilt.tobytes()

    runtime_manifest = json.loads(
        runtime_manifest_path.read_text(encoding="utf-8")
    )
    source_manifest = json.loads(
        source_manifest_path.read_text(encoding="utf-8")
    )
    p6_evidence = json.loads(p6_evidence_path.read_text(encoding="utf-8"))
    assert runtime_manifest["runtime_contract"] == "1.0"
    assert runtime_manifest["status"] == "game-validated"
    assert runtime_manifest["phase"] == "P6"
    assert runtime_manifest["source"]["sha256"] == sha256(source_path)
    runtime_record = runtime_manifest["runtime_export"]
    assert runtime_record["file"] == builder.RUNTIME_REL.as_posix()
    assert runtime_record["sha256"] == sha256(runtime_path)
    assert runtime_record["pixel_sha256"] == (
        builder.EXPECTED_RUNTIME_PIXEL_SHA256
    )
    assert runtime_record["bits_per_pixel"] == 32
    assert runtime_record["descriptor"] == 8
    assert runtime_record["visible_bbox_exclusive"] == [40, 40, 216, 216]
    assert runtime_record["visible_green_spill_pixels"] == 0
    assert runtime_record["transparent_rgb_nonzero_values"] == 0

    transform = runtime_manifest["transform"]
    assert transform["source_crop_exclusive"] == [160, 160, 864, 864]
    assert transform["source_slice_boundaries"] == [0, 128, 576, 704]
    assert transform["runtime_atlas_size"] == [256, 256]
    assert transform["runtime_visible_bbox_exclusive"] == [40, 40, 216, 216]
    assert transform["runtime_slice_boundaries"] == [40, 72, 184, 216]
    assert transform["runtime_cell_sizes"] == [32, 112, 32]
    assert transform["runtime_cap_ui"] == 6
    assert transform["texcoords"] == builder.texcoords()
    assert runtime_manifest["deterministic_export"][
        "imagegen_calls_after_acceptance"
    ] == 0
    assert runtime_manifest["deterministic_export"]["attempt_6_allowed"] is False
    assert runtime_manifest["deterministic_export"]["exporter_sha256"] == (
        sha256(ROOT / "tools/build_action_rail_v1_runtime.py")
    )

    adapter_record = runtime_manifest["adapter"]
    assert adapter_record["sha256"] == sha256(adapter_path)
    assert adapter_record["logical_bars"] == list(range(1, 13))
    assert adapter_record["merged_pair"] == [1, 6]
    assert adapter_record["maximum_rail_backdrops"] == 13
    assert adapter_record["textures_per_rail"] == 9
    assert adapter_record["maximum_texture_instances"] == 117
    assert adapter_record["provider_geometry_writes"] is False
    assert adapter_record["provider_behavior_replaced"] is False
    assert runtime_manifest["addon_entrypoints"]["addon_version"] == "0.8.10"
    package = runtime_manifest["package_validation"]
    assert package["status"] == "pass"
    assert package["violations"] == 0
    assert package["build_required_on_target_device"] is False
    game_validation = runtime_manifest["game_validation"]
    assert game_validation["status"] == "pass"
    assert game_validation["phase"] == "P6"
    assert game_validation["validated_on"] == "2026-08-09"
    assert game_validation["aggregate_p6_checklist"] == "pass"
    assert game_validation["additional_imagegen_calls"] == 0
    assert game_validation["evidence_record_sha256"] == sha256(
        p6_evidence_path
    )
    assert game_validation["screenshot_sha256"] == sha256(p6_screenshot_path)

    assert source_manifest["status"] == "game-validated"
    assert source_manifest["workflow_state"] == "game-validated"
    assert source_manifest["project_phase"] == "P6"
    export = source_manifest["export_contract"]
    assert export["status"] == "exported"
    assert export["runtime_file"] == builder.RUNTIME_REL.as_posix()
    assert export["runtime_sha256"] == sha256(runtime_path)
    assert export["runtime_atlas_size"] == [256, 256]
    assert export["runtime_visible_bbox_exclusive"] == [40, 40, 216, 216]
    assert export["runtime_nine_slice_boundaries"] == [40, 72, 184, 216]
    assert export["runtime_cell_sizes"] == [32, 112, 32]
    assert export["runtime_uv"] == builder.texcoords()
    assert export["runtime_cap_ui"] == 6
    assert export["imagegen_calls_after_acceptance"] == 0
    assert source_manifest["runtime_exports"]["action_rail_v1"][
        "sha256"
    ] == sha256(runtime_path)
    assert source_manifest["p5_validation"]["real_layout_scenarios"] == (
        "8/8 pass"
    )
    assert source_manifest["p5_validation"]["display_region_violations"] == 0
    assert source_manifest["p5_validation"]["addon_package"]["status"] == (
        "pass"
    )
    assert source_manifest["p5_validation"]["game_validated"] is True
    assert source_manifest["p6_validation"]["status"] == "pass"
    assert source_manifest["p6_validation"][
        "evidence_record_sha256"
    ] == sha256(p6_evidence_path)
    assert source_manifest["p6_validation"]["screenshot_sha256"] == sha256(
        p6_screenshot_path
    )

    assert p6_evidence["schema"] == "aeui-component-p6-evidence-v1"
    assert p6_evidence["status"] == "game-validated"
    assert p6_evidence["phase"] == "P6"
    assert p6_evidence["user_validation"]["explicit_checks"] == {
        "horizontal_vertical_and_multirow_rail": "pass",
        "bar_1_6_merged_outer_rail_without_internal_seam": "pass",
        "drag_scale_and_visibility_follow": "pass",
        "stance_and_pet_rail": "pass",
        "actionbars_toggle_native_pfui_fail_open": "pass",
        "status_reports_rail_contract_1_0": "pass",
    }
    assert p6_evidence["user_validation"]["aggregate_checklist"]["status"] == (
        "pass"
    )
    assert p6_evidence["production_budget"][
        "additional_generations_for_p6"
    ] == 0
    assert p6_evidence["production_budget"]["attempt_6_allowed"] is False
    assert p6_evidence["closure"]["status"] == "pending"
    with Image.open(p6_screenshot_path) as opened:
        assert opened.format == "PNG"
        assert opened.mode == "RGB"
        assert opened.size == (580, 129)

    contract = json.loads(contract_path.read_text(encoding="utf-8"))
    assert contract["component"] == "AB.RAIL.V1/runtime-v1"
    assert contract["evidence"]["final_runtime"] is True
    assert contract["atlas"]["size"] == [256, 256]
    assert contract["atlas"]["visible_bbox"] == [40, 40, 216, 216]
    assert len(contract["atlas"]["sampled_regions"]) == 9
    assert len(contract["scenarios"]) == 8
    assert [item["frame"] for item in contract["scenarios"]] == [
        [32, 32],
        [26, 26],
        [510, 48],
        [222, 78],
        [142, 108],
        [60, 654],
        [302, 232],
        [510, 90],
    ]
    with tempfile.TemporaryDirectory() as temp_dir:
        report = Path(temp_dir) / "display-report.json"
        result = subprocess.run(
            [
                sys.executable,
                str(ROOT / builder.DISPLAY_VALIDATOR_REL),
                str(contract_path),
                "--report",
                str(report),
            ],
            cwd=ROOT,
            check=False,
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0, result.stdout + result.stderr
        display = json.loads(report.read_text(encoding="utf-8"))
    assert display["status"] == "pass"
    assert display["summary"]["scenario_count"] == 8
    assert display["summary"]["violation_count"] == 0

    adapter = adapter_path.read_text(encoding="utf-8")
    assert 'ActionBars.railRuntimeContract = "1.0"' in adapter
    assert '"ActionBars\\\\ActionRailV1"' in adapter
    assert "ActionBars.firstRailBar = 1" in adapter
    assert "ActionBars.lastRailBar = 12" in adapter
    assert "ActionBars.railCap = 6" in adapter
    assert 'backdrop:CreateTexture(nil, "OVERLAY")' in adapter
    assert "ApplyRailBackdrop(mergedBackdrop.backdrop, enabled)" in adapter
    assert "bar:SetParent" not in adapter
    assert "bar:SetPoint" not in adapter
    assert "bar:SetWidth" not in adapter
    assert "bar:SetHeight" not in adapter
    assert "button:SetParent" not in adapter

    toc = (ROOT / builder.TOC_REL).read_text(encoding="utf-8-sig")
    bootstrap = (ROOT / builder.BOOTSTRAP_REL).read_text(encoding="utf-8")
    assert "## Version: 0.8.10" in toc
    assert 'addon.version = "0.8.10"' in bootstrap
    assert "Modules\\ActionBars.lua" in toc

    print("action rail runtime test passed")


if __name__ == "__main__":
    main()
