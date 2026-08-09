#!/usr/bin/env python3
"""Deterministic media, adapter, and display checks for AB.SLOT.BASE.V1."""

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

import build_action_slot_base_v1_runtime as builder  # noqa: E402


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
        / "assets/references/actionbars/p6/AB-SLOT-BASE-V1_P6Evidence_v1.json"
    )
    p6_screenshot_path = (
        ROOT
        / "assets/references/actionbars/p6/AB-SLOT-BASE-V1_TurtleWoW_P6_2026-08-08.png"
    )

    source = builder.validate_source(source_path)
    rebuilt = builder.build_runtime(source)
    assert builder.pixel_sha256(rebuilt) == builder.EXPECTED_RUNTIME_PIXEL_SHA256

    header = runtime_path.read_bytes()[:18]
    assert header[16] == 32
    assert header[17] == 8
    with Image.open(runtime_path) as opened:
        tracked_runtime = opened.convert("RGBA")
    assert tracked_runtime.size == (128, 128)
    assert tracked_runtime.tobytes() == rebuilt.tobytes()
    assert tracked_runtime.getchannel("A").getbbox() == (0, 0, 128, 128)
    assert builder.visible_green_spill_pixels(tracked_runtime) == 0
    assert builder.transparent_rgb_nonzero_values(tracked_runtime) == 0

    runtime_manifest = json.loads(
        runtime_manifest_path.read_text(encoding="utf-8")
    )
    source_manifest = json.loads(source_manifest_path.read_text(encoding="utf-8"))
    p6_evidence = json.loads(p6_evidence_path.read_text(encoding="utf-8"))
    assert runtime_manifest["runtime_contract"] == "1.0"
    assert runtime_manifest["status"] == "game-validated"
    assert runtime_manifest["phase"] == "P6"
    assert runtime_manifest["source"]["sha256"] == sha256(source_path)
    runtime_record = runtime_manifest["runtime_export"]
    assert runtime_record["file"] == builder.RUNTIME_REL.as_posix()
    assert runtime_record["sha256"] == sha256(runtime_path)
    assert runtime_record["pixel_sha256"] == builder.EXPECTED_RUNTIME_PIXEL_SHA256
    assert runtime_record["bits_per_pixel"] == 32
    assert runtime_record["descriptor"] == 8
    assert runtime_record["visible_green_spill_pixels"] == 0
    assert runtime_record["transparent_rgb_nonzero_values"] == 0
    assert runtime_manifest["transform"]["source_crop_exclusive"] == [
        200,
        200,
        824,
        824,
    ]
    assert runtime_manifest["transform"]["runtime_size"] == [128, 128]
    assert runtime_manifest["transform"]["texcoord"] == {
        "left": 0.0,
        "right": 1.0,
        "top": 0.0,
        "bottom": 1.0,
    }
    assert runtime_manifest["deterministic_export"][
        "imagegen_calls_after_acceptance"
    ] == 0
    assert runtime_manifest["adapter"]["logical_bars"] == list(range(1, 11))
    assert runtime_manifest["adapter"]["excluded_provider_bars"] == [11, 12]
    assert runtime_manifest["adapter"]["provider_behavior_replaced"] is False
    game_validation = runtime_manifest["game_validation"]
    assert game_validation["status"] == "pass"
    assert game_validation["phase"] == "P6"
    assert game_validation["aggregate_p6_checklist"] == "pass"
    assert game_validation["additional_imagegen_calls"] == 0
    assert game_validation["evidence_record_sha256"] == sha256(p6_evidence_path)
    assert game_validation["screenshot_sha256"] == sha256(p6_screenshot_path)
    assert runtime_manifest["deterministic_export"]["exporter_sha256"] == sha256(
        ROOT / "tools/build_action_slot_base_v1_runtime.py"
    )
    assert runtime_manifest["adapter"]["sha256"] == sha256(adapter_path)

    assert source_manifest["status"] == "game-validated"
    assert source_manifest["workflow_state"] == "game-validated"
    assert source_manifest["project_phase"] == "P6"
    assert source_manifest["export_contract"]["status"] == "exported"
    assert source_manifest["export_contract"][
        "imagegen_calls_after_acceptance"
    ] == 0
    assert source_manifest["runtime_exports"]["action_slot_base_v1"][
        "sha256"
    ] == sha256(runtime_path)
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
    assert p6_evidence["screenshot"]["sha256"] == sha256(p6_screenshot_path)
    assert p6_evidence["user_validation"]["explicit_checks"] == {
        "cooldown": "pass",
        "out_of_range_red": "pass",
        "pressed_feedback": "pass",
        "overall_actionbar_functionality": "pass",
    }
    assert p6_evidence["user_validation"]["aggregate_checklist"]["status"] == "pass"
    assert p6_evidence["production_budget"]["additional_generations_for_p6"] == 0
    assert p6_evidence["production_budget"]["attempt_6_allowed"] is False
    with Image.open(p6_screenshot_path) as opened:
        assert opened.size == (694, 156)
        assert opened.mode == "RGB"
        assert opened.format == "PNG"

    contract = json.loads(contract_path.read_text(encoding="utf-8"))
    assert contract["component"] == "AB.SLOT.BASE.V1/runtime-v1"
    assert contract["evidence"]["final_runtime"] is True
    assert contract["atlas"]["visible_bbox"] == [0, 0, 128, 128]
    assert len(contract["scenarios"]) == 5
    assert [item["frame"] for item in contract["scenarios"]] == [
        [23, 23],
        [493, 43],
        [195, 66],
        [112, 85],
        [46, 528],
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
    assert display["summary"]["scenario_count"] == 5
    assert display["summary"]["violation_count"] == 0

    adapter = adapter_path.read_text(encoding="utf-8")
    assert 'ActionBars.runtimeContract = "1.0"' in adapter
    assert '"ActionBars\\\\ActionSlotBaseV1"' in adapter
    assert "ActionBars.firstBar = 1" in adapter
    assert "ActionBars.lastBar = 10" in adapter
    assert 'backdrop:CreateTexture(nil, "ARTWORK")' in adapter
    assert "texture:SetAllPoints(backdrop)" in adapter
    assert "texture:SetTexCoord(0, 1, 0, 1)" in adapter
    assert "button:SetParent" not in adapter
    assert "button:SetPoint" not in adapter
    assert "button:SetWidth" not in adapter
    assert "button:SetHeight" not in adapter
    assert "button:SetHitRectInsets" not in adapter

    toc = (
        ROOT / "addon/AzerothExpeditionUI/AzerothExpeditionUI.toc"
    ).read_text(encoding="utf-8-sig")
    assert "## Version: 0.8.1" in toc
    assert "Modules\\ActionBars.lua" in toc

    print("actionbars runtime test passed")


if __name__ == "__main__":
    main()
