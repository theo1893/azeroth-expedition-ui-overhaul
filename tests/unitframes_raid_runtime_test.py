#!/usr/bin/env python3
"""Rebuild and verify the accepted UF-RAID-A2 P4/P5 runtime contract."""

from __future__ import annotations

import hashlib
import json
import struct
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets/source/unitframes/raid-a2"
SOURCE_MANIFEST = SOURCE_DIR / "UF-RAID-A2_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "UF-RAID-A2_RuntimeManifest_v1.json"
PRODUCTION = ROOT / "tools/specs/unitframes_raid_donor_production_v1.json"
SIMULATION = ROOT / "tools/specs/unitframes_raid_donor_simulation_v1.json"
DISPLAY = ROOT / "tools/specs/unitframes_raid_runtime_display_region_v1.json"
ADAPTER = ROOT / "addon/AzerothExpeditionUI/Modules/UnitFrames.lua"
BRIDGE = ROOT / "addon/pfUI/api/unitframes.lua"
OWNERSHIP = ROOT / "addon/pfUI/api/expedition.lua"

EXPECTED_ACCEPTANCE = (
    "接受 UF-RAID-A2-DONOR V1 attempt 5 的运行时视觉，并授权 "
    "sample-window-only 确定性合同例外进入 P4/P5；仅豁免未消费外围 field "
    "bbox 的最大 19px 偏差，其余固定 sample window、Python 外壳、A–D 维修、"
    "透明清理、592×296 source、74×37 runtime、6/62/6 三切片及 40 人排版"
    "合同保持不变。"
)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    source_manifest = json.loads(SOURCE_MANIFEST.read_text(encoding="utf-8"))
    runtime_manifest = json.loads(RUNTIME_MANIFEST.read_text(encoding="utf-8"))
    production = json.loads(PRODUCTION.read_text(encoding="utf-8"))
    simulation = json.loads(SIMULATION.read_text(encoding="utf-8"))

    assert source_manifest["status"] == "accepted-source"
    assert source_manifest["phase"] == "P4"
    acceptance = source_manifest["user_acceptance"]
    assert acceptance["exact_statement"] == EXPECTED_ACCEPTANCE
    assert acceptance["accepts_exact_attempt"] == 5
    assert acceptance["exception_scope"] == (
        "unused outer field bbox only; maximum deviation 19px"
    )
    assert acceptance["sample_windows_accepted"] is True
    assert acceptance["outer_field_pixels_accepted"] is False
    exception = source_manifest["sample_window_exception"]
    assert exception["promotion_rule"] == (
        "only the four fixed 512x288 crops are persisted"
    )
    assert exception["raw_donor_promoted"] is False
    assert exception["unconsumed_outer_field_promoted"] is False
    assert exception["crop_coordinates_frozen"] is True

    raw_path = source_manifest["provenance"]["provider_raw_path"]
    tracked = subprocess.run(
        ["git", "ls-files", "--error-unmatch", raw_path],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    assert tracked.returncode != 0, "provider raw must remain ignored intermediate data"

    sys.path.insert(0, str(ROOT / "tools"))
    from build_unitframes_raid_donor_shells_v1 import (  # noqa: PLC0415
        build_shells,
        clear_transparent_rgb,
    )

    materials: dict[str, Image.Image] = {}
    production_cells = production["output_contract"]["cells"]
    for material_id, record in source_manifest["accepted_material_samples"].items():
        path = ROOT / record["file"]
        assert sha256(path) == record["sha256"]
        with Image.open(path) as opened:
            material = opened.copy()
        assert material.mode == "RGB"
        assert material.size == (512, 288)
        assert record["raw_sample_window"] == production_cells[material_id]["sample_window"]
        assert record["visible_green_spill_pixels"] == 0
        materials[material_id] = material

    rebuilt = build_shells(simulation, materials)
    runtime_pixels: set[bytes] = set()
    assert runtime_manifest["status"] == "runtime-exported"
    assert runtime_manifest["phase"] == "P5"
    assert runtime_manifest["runtime_contract"] == "1.1"
    assert runtime_manifest["source_manifest_sha256"] == sha256(SOURCE_MANIFEST)
    deterministic = runtime_manifest["deterministic_export"]
    assert deterministic["source_to_runtime"] == [[592, 296], [74, 37]]
    assert deterministic["source_three_slice"] == [48, 496, 48]
    assert deterministic["runtime_three_slice"] == [6, 62, 6]
    assert deterministic["standard_width_uses_complete_texture"] is True
    assert deterministic["variable_width_uses_three_texture_objects_with_uv_slices"] is True

    for variant in ("A", "B", "C", "D"):
        source_record = source_manifest["shell_sources"][variant]
        source_path = ROOT / source_record["file"]
        assert sha256(source_path) == source_record["sha256"]
        with Image.open(source_path) as opened:
            source = opened.convert("RGBA")
        assert source.size == (592, 296)
        assert ImageChops.difference(source, rebuilt.sources[variant]).getbbox() is None
        assert source_record["metrics"]["transparent_rgb_nonzero_values"] == 0
        assert source_record["metrics"]["visible_green_spill_pixels"] == 0

        runtime_record = runtime_manifest["runtime"][variant]
        runtime_path = ROOT / runtime_record["file"]
        assert sha256(runtime_path) == runtime_record["sha256"]
        with Image.open(runtime_path) as opened:
            runtime = opened.convert("RGBA")
        expected = clear_transparent_rgb(
            source.resize((74, 37), Image.Resampling.LANCZOS)
        )
        assert ImageChops.difference(runtime, expected).getbbox() is None
        runtime_pixels.add(runtime.tobytes())
        assert runtime_record["metrics"]["transparent_rgb_nonzero_values"] == 0
        assert runtime_record["metrics"]["visible_green_spill_pixels"] == 0

        data = runtime_path.read_bytes()
        width, height = struct.unpack("<HH", data[12:16])
        assert data[2] == 2
        assert (width, height) == (74, 37)
        assert data[16] == 32

    assert len(runtime_pixels) == 4

    display = json.loads(DISPLAY.read_text(encoding="utf-8"))
    assert display["evidence"]["sample_window_only_exception"].startswith(
        "only unused outer donor field bbox"
    )
    assert display["evidence"]["final_runtime"] is True
    assert display["atlas"]["runtime_packing"].startswith("virtual review grid")
    assert display["nine_slice"]["caps"] == {
        "left": 6, "right": 6, "top": 2, "bottom": 2,
    }
    assert len(display["scenarios"]) == 7

    adapter = ADAPTER.read_text(encoding="utf-8")
    for clause in (
        'UnitFrames.runtimeContract = "1.2"',
        'local RAID_LEFT_CAP = 6',
        'local RAID_CENTRE = 62',
        'local RAID_RIGHT_CAP = 6',
        'frame.aeuiRaidShellAssembly = "complete-74x37"',
        'frame.aeuiRaidShellAssembly = "three-slice-6-centre-6"',
        'scope=all-pfui-unitframe-portraits,player,target,targettarget,focus,pfRaid1..40',
    ):
        assert clause in adapter
    bridge = BRIDGE.read_text(encoding="utf-8")
    assert 'f.label == "raid" and' in bridge
    assert 'type(f.aeuiRaidRefreshVisual) == "function"' in bridge
    assert "f:aeuiRaidRefreshVisual()" in bridge
    ownership = OWNERSHIP.read_text(encoding="utf-8")
    for component in (
        '"unitframes.raid-shell"',
        '"unitframes.raid-health-fill"',
        '"unitframes.raid-power-fill"',
    ):
        assert component in ownership

    deployment = runtime_manifest["deployment"]
    assert deployment["build_required_on_target_device"] is False
    package_gate = deployment["addon_package_gate"]
    assert package_gate["status"] == "present"
    assert package_gate["package_status"] == "pass"
    assert package_gate["build_required_on_target_device"] is False
    assert package_gate["violations"] == []
    assert deployment["game_validation"] == "pending Turtle WoW 1.18.1 / P6"

    print("unitframes raid runtime test passed")


if __name__ == "__main__":
    main()
