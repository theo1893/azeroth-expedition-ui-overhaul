#!/usr/bin/env python3
"""Determinism and geometry checks for the AB.RAIL.V1 local simulation."""

from __future__ import annotations

import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
RENDERER = ROOT / "tools/render_action_rail_simulation.py"
SPEC = ROOT / "tools/specs/action_rail_v1_simulation.json"
DISPLAY_CONTRACT = ROOT / "tools/specs/action_rail_v1_sim_display_region.json"
DISPLAY_VALIDATOR = (
    ROOT
    / ".codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py"
)
EXPECTED_SLOT_SHA256 = (
    "5c49a1db452560251422060545625b311e182ef5b8689be996aeda005b8e23ca"
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def render(destination: Path) -> tuple[Path, Path, Path]:
    scene = destination / "scene.png"
    layouts = destination / "layouts.png"
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
            "--layouts-output",
            str(layouts),
            "--layout-report",
            str(report),
        ],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    return scene, layouts, report


def main() -> None:
    spec = json.loads(SPEC.read_text(encoding="utf-8"))
    assert spec["schema"] == "aeui-action-rail-simulation-v1"
    assert spec["version"] == "AB-RAIL-SIM-V1"
    assert spec["component"] == "AB.RAIL.V1"
    assert spec["imagegen"] == {"used": 0, "limit": 0}
    assert spec["rail_contract"]["logical_objects"] == 1
    assert spec["rail_contract"]["states"] == ["normal"]
    assert spec["rail_contract"]["runtime_cap_ui"] == 6
    assert spec["rail_contract"]["ornament_edge_ui"] == 2
    assert spec["rail_contract"]["source_canvas"] == [1024, 1024]
    assert spec["rail_contract"]["source_object_bbox"] == [160, 160, 864, 864]
    assert spec["rail_contract"]["source_stretch_center_canvas"] == [288, 288, 736, 736]
    assert len(spec["scenarios"]) == 8
    assert {item["id"] for item in spec["scenarios"]} >= {
        "single-minimum-1x1",
        "main-confirmed-12x1",
        "compact-supported-6x2",
        "auxiliary-supported-4x3",
        "vertical-maximum-icon-1x12",
        "merged-main-top-12x1-pair",
    }

    slot_path = ROOT / spec["accepted_neighbor"]["path"]
    assert sha256(slot_path) == EXPECTED_SLOT_SHA256
    assert spec["accepted_neighbor"]["sha256"] == EXPECTED_SLOT_SHA256

    with tempfile.TemporaryDirectory() as first_dir, tempfile.TemporaryDirectory() as second_dir:
        first = render(Path(first_dir))
        second = render(Path(second_dir))
        assert [sha256(path) for path in first] == [sha256(path) for path in second]

        with Image.open(first[0]) as scene:
            assert scene.size == (1920, 1080)
            assert scene.mode == "RGB"
        with Image.open(first[1]) as layouts:
            assert layouts.size == (1920, 1180)
            assert layouts.mode == "RGB"

        report = json.loads(first[2].read_text(encoding="utf-8"))
        assert report["schema"] == "aeui-action-rail-simulation-report-v1"
        assert report["status"] == "pass"
        assert report["scenario_count"] == 8
        assert report["violations"] == []
        assert report["imagegen"] == {"used": 0, "limit": 0}
        assert all(not item["ornament_button_overlaps"] for item in report["scenarios"])
        assert all(item["button_regions_contained"] for item in report["scenarios"])
        assert all(min(item["center_px"]) >= 1 for item in report["scenarios"])

    contract = json.loads(DISPLAY_CONTRACT.read_text(encoding="utf-8"))
    assert contract["schema"] == "aeui-display-region-contract-v1"
    assert contract["component"] == "AB.RAIL.V1/simulation-v1"
    assert contract["evidence"]["final_runtime"] is False
    assert contract["nine_slice"] == {
        "caps": {"left": 6, "right": 6, "top": 6, "bottom": 6},
        "minimum_frame_size": [13, 13],
    }
    assert len(contract["atlas"]["sampled_regions"]) == 9
    assert len(contract["scenarios"]) == 8

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
        "scenario_count": 8,
        "violation_count": 0,
        "first_failure": None,
    }

    print("action rail simulation test passed")


if __name__ == "__main__":
    main()
