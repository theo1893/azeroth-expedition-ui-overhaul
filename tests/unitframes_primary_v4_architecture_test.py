#!/usr/bin/env python3
"""Static contract checks for the confirmed UF-PRIMARY-V4 architecture."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "tools/specs/unitframes_primary_v4_simulation_v1.json"
DISPLAY = ROOT / "tools/specs/unitframes_primary_v4_simulation_display_region_v1.json"
RENDERER = ROOT / "tools/render_unitframes_primary_v4_simulation_v1.py"
WORK = ROOT / "docs/modules/unitframes/work/UNITFRAMES.CORE.md"
PROGRESS = ROOT / "docs/modules/unitframes/PROGRESS.md"
SUBMODULES = ROOT / "docs/modules/unitframes/SUBMODULES.md"
ART = ROOT / "docs/modules/unitframes/ART_BASELINE.md"
GLOBAL_PROGRESS = ROOT / "docs/PROGRESS.md"
AGENTS = ROOT / "AGENTS.md"


def main() -> None:
    spec = json.loads(SPEC.read_text(encoding="utf-8"))
    assert spec["schema"] == "aeui-unitframes-primary-v4-simulation-v1"
    assert spec["version"] == "UF-PRIMARY-V4-SIM-V1"
    assert spec["status"] == "simulation-confirmed"
    confirmation = spec["user_confirmation"]
    assert confirmation["status"] == "confirmed"
    assert confirmation["accepts_pixels"] is False
    assert confirmation["authorizes_deterministic_candidate_construction"] is True
    assert confirmation["authorizes_raid_a2_samples_as_read_only_inputs"] is True
    assert confirmation["authorizes_imagegen"] is False
    assert confirmation["authorizes_addon_integration"] is False
    assert spec["reopens"]["components"] == ["UF.PLAYER.SHELL", "UF.TARGET.SHELL"]
    assert spec["reopens"]["predecessor_pixels_may_be_reused"] is False

    architecture = spec["architecture"]
    assert architecture["final_asset_granularity"].startswith("one complete independent")
    assert architecture["image_model_owns_ui_geometry"] is False
    preferred = architecture["preferred_material_path"]
    assert preferred["kind"] == "reuse-accepted-unitframes-material-samples"
    assert preferred["imagegen_calls"] == 0
    assert preferred["requires_user_confirmation_before_deterministic_candidate_build"] is True
    assert set(preferred["samples"]) == {"leather", "liner", "brass", "thread"}
    fallback = architecture["inactive_fallback"]
    assert fallback["status"] == "not-authorized"
    assert fallback["maximum_actual_imagegen_calls_if_activated"] == 5

    source = spec["source_contract"]
    assert source["source"] == [1284, 252]
    assert source["runtime"] == [214, 42]
    assert source["live_content_bed_source"] == [42, 36, 1242, 216]
    assert source["live_content_bed_runtime"] == [7, 6, 207, 36]
    assert source["source_three_slice"] == [192, 900, 192]
    assert source["runtime_three_slice"] == [32, 150, 32]
    assert "zero internal seams" in source["standard_width_assembly"]
    assert source["height_policy"].startswith("fixed 42")

    rules = spec["simulation_rules"]
    assert rules["imagegen_usage"] == "0/0"
    assert rules["uses_locked_reference_pixels"] is False
    assert rules["uses_accepted_material_sample_pixels"] is False
    assert rules["uses_accepted_bar_runtime_pixels"] is True
    assert rules["simulation_pixels_may_be_source_or_runtime"] is False

    display = json.loads(DISPLAY.read_text(encoding="utf-8"))
    assert display["schema"] == "aeui-display-region-contract-v1"
    assert display["nine_slice"]["caps"] == {
        "left": 32,
        "right": 32,
        "top": 6,
        "bottom": 6,
    }
    scenarios = {item["id"]: item for item in display["scenarios"]}
    assert set(scenarios) == {
        "player-mana-standard",
        "player-rage-standard",
        "player-focus-standard",
        "player-energy-standard",
        "target-rage-aggro-standard",
        "player-variable-w160",
        "target-variable-w240",
    }
    assert scenarios["player-variable-w160"]["frame"] == [174, 42]
    assert scenarios["target-variable-w240"]["frame"] == [254, 42]

    renderer = RENDERER.read_text(encoding="utf-8")
    assert "simple geometric placeholders" in renderer
    assert "accepted Health and Power runtime textures" in renderer
    assert "imagegen__imagegen" not in renderer
    assert "RaidMaterialLeather_SampleV1" not in renderer

    work = WORK.read_text(encoding="utf-8")
    progress = PROGRESS.read_text(encoding="utf-8")
    submodules = SUBMODULES.read_text(encoding="utf-8")
    art = ART.read_text(encoding="utf-8")
    global_progress = GLOBAL_PROGRESS.read_text(encoding="utf-8")
    agents = AGENTS.read_text(encoding="utf-8")
    for clause in (
        "## UF-PRIMARY V4 新生产架构（当前）",
        "ImageGen 不再拥有任何 UI 几何",
        "source `192/900/192`、runtime `32/150/32`",
        "备用段最多 `5` 次实际 ImageGen",
        "`displayable / simulation-reviewed`",
        "用户确认 `UF-PRIMARY-V4-SIM-V1`",
    ):
        assert clause in work, f"V4 work record missing: {clause}"
    assert "V4 新生产架构与生成前模拟" in progress
    assert "UF-PRIMARY V4 已确认架构与待验收候选" in submodules
    assert "重开的是生产职责，不是新的美术" in art
    assert "Player／Target V4 `P3 candidate-reviewed`" in global_progress
    assert "UF-PRIMARY-V4-CANDIDATE-V1 / P3 / candidate-reviewed" in agents

    print("unitframes primary V4 architecture test passed")


if __name__ == "__main__":
    main()
