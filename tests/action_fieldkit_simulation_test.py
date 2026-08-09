#!/usr/bin/env python3
"""Determinism and provider-geometry checks for AB.FIELDKIT-SIM-V3."""

from __future__ import annotations

import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
RENDERER = ROOT / "tools/render_action_fieldkit_simulation.py"
SPEC = ROOT / "tools/specs/action_fieldkit_v3_simulation.json"
DISPLAY_CONTRACT = ROOT / "tools/specs/action_fieldkit_v3_sim_display_region.json"
DISPLAY_VALIDATOR = ROOT / ".codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py"
CHARACTER_V3 = ROOT / "assets/locked/character/角色属性面板_香草同构收敛_风格确认_v3.png"
ACTION_SLOT = ROOT / "addon/AzerothExpeditionUI/Media/ActionBars/ActionSlotBaseV1.tga"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def render(destination: Path) -> tuple[Path, Path, Path]:
    scene = destination / "scene.png"
    states = destination / "states.png"
    report = destination / "layout-report.json"
    result = subprocess.run(
        [
            sys.executable,
            str(RENDERER),
            str(SPEC),
            "--repo-root",
            str(ROOT),
            "--scene-output",
            str(scene),
            "--states-output",
            str(states),
            "--layout-report",
            str(report),
        ],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    return scene, states, report


def main() -> None:
    spec = json.loads(SPEC.read_text(encoding="utf-8"))
    assert spec["schema"] == "aeui-action-fieldkit-simulation-v1"
    assert spec["version"] == "AB-FIELDKIT-SIM-V3"
    assert spec["batch"] == "AB.FIELDKIT.V1"
    assert spec["imagegen"] == {"used": 0, "limit": 0}
    assert spec["current_device"]["trinket_menu"]["enabled_for_current_character"] is True
    assert spec["current_device"]["auto_bar"]["enabled_for_current_character"] is True
    assert spec["trinket_contract"]["main_frame_horizontal_ui"] == [92, 52]
    assert spec["trinket_contract"]["main_frame_vertical_ui"] == [52, 92]
    assert spec["trinket_contract"]["max_candidates"] == 30
    assert spec["trinket_contract"]["configured_columns_range"] == [1, 30]
    assert spec["consumable_contract"]["max_buttons"] == 24
    assert spec["consumable_contract"]["max_popup_buttons"] == 12
    assert spec["consumable_contract"]["recommended_profile"]["buttons"] == 24
    assert spec["consumable_contract"]["recommended_profile"]["columns"] == 4
    assert spec["consumable_contract"]["recommended_profile"]["rows"] == 6
    assert spec["consumable_contract"]["recommended_profile"]["body_frame_ui"] == [165, 243]
    assert spec["consumable_contract"]["recommended_profile"]["full_visual_frame_with_labels_ui"] == [207, 243]
    assert spec["consumable_contract"]["popup_drawer"]["one_column_range"] == [1, 6]
    assert spec["consumable_contract"]["popup_drawer"]["two_column_range"] == [7, 12]
    assert spec["consumable_contract"]["popup_drawer"]["maximum_rows"] == 6
    hover = spec["consumable_contract"]["popup_hover_transfer"]
    assert hover["corridor_parent"] == "AutoBarPopupFrame"
    assert hover["corridor_mouse_enabled"] is True
    assert hover["right_width_ui"] == 10
    assert hover["grouped_left_width_ui"] == 52
    assert "PopupMouseover" in hover["close_owner"]
    assert spec["dock_contract"]["consumable_side"] == "LEFT"
    assert spec["dock_contract"]["trinket_side"] == "RIGHT"
    assert spec["dock_contract"]["maintenance_loop"] is False
    groups = spec["consumable_contract"]["group_profile"]
    assert [group["slot_range"] for group in groups] == [[1, 8], [9, 16], [17, 24]]
    assert [slot["slot"] for group in groups for slot in group["slots"]] == list(range(1, 25))
    assert groups[1]["slots"][7]["categories"] == []
    assert groups[1]["slots"][7]["provider_entries"] == "numeric item IDs received through AutoBarConfigSlot drag-and-drop"
    assert groups[1]["slots"][7]["max_entries"] == 16
    assert "no audited built-in FLASK category" in groups[1]["slots"][7]["provider_gap"]
    assert len(spec["trinket_scenarios"]) == 9
    assert len(spec["consumable_scenarios"]) == 10
    assert sha256(CHARACTER_V3) == spec["locked_authority"]["sha256"]
    assert sha256(ACTION_SLOT) == spec["locked_authority"]["accepted_action_slot"]["sha256"]

    with tempfile.TemporaryDirectory() as first_dir, tempfile.TemporaryDirectory() as second_dir:
        first = render(Path(first_dir))
        second = render(Path(second_dir))
        assert [sha256(path) for path in first] == [sha256(path) for path in second]
        with Image.open(first[0]) as image:
            assert image.size == (1920, 1080)
            assert image.mode == "RGB"
        with Image.open(first[1]) as image:
            assert image.size == (1920, 1200)
            assert image.mode == "RGB"
        report = json.loads(first[2].read_text(encoding="utf-8"))
        assert report["schema"] == "aeui-action-fieldkit-simulation-report-v1"
        assert report["status"] == "pass"
        assert report["check_count"] == 89
        assert report["violations"] == []
        assert report["imagegen"] == {"used": 0, "limit": 0}
        assert report["scene_boxes_px"] == {
            "actionbar": [713, 827, 1207, 870],
            "consumable": [497, 673, 665, 870],
            "consumable_body": [531, 673, 665, 870],
            "consumable_labels": [[497, 676, 530, 693], [497, 740, 530, 756], [497, 803, 530, 819]],
            "trinket": [1223, 832, 1291, 870],
        }

    contract = json.loads(DISPLAY_CONTRACT.read_text(encoding="utf-8"))
    assert contract["schema"] == "aeui-display-region-contract-v1"
    assert contract["component"] == "AB.FIELDKIT.V1/simulation-v3"
    assert contract["evidence"]["final_runtime"] is False
    assert len(contract["atlas"]["sampled_regions"]) == 4
    assert len(contract["scenarios"]) == 19

    with tempfile.TemporaryDirectory() as temp_dir:
        display_report = Path(temp_dir) / "display-region-report.json"
        result = subprocess.run(
            [
                sys.executable,
                str(DISPLAY_VALIDATOR),
                str(DISPLAY_CONTRACT),
                "--report",
                str(display_report),
            ],
            cwd=ROOT,
            check=False,
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0, result.stdout + result.stderr
        display = json.loads(display_report.read_text(encoding="utf-8"))
    assert display["status"] == "pass"
    assert display["summary"] == {
        "scenario_count": 19,
        "violation_count": 0,
        "first_failure": None,
    }

    print("action fieldkit simulation test passed")


if __name__ == "__main__":
    main()
