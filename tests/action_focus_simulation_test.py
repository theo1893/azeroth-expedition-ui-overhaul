#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RENDERER = ROOT / "tools" / "render_action_bars_simulation.py"
SPEC = ROOT / "tools" / "specs" / "action_bars_core_simulation_v6.json"
SIMULATION_DISPLAY = (
    ROOT / "tools" / "specs" / "action_bars_core_simulation_v6_display_region.json"
)
RUNTIME_DISPLAY = (
    ROOT / "tools" / "specs" / "action_focus_layout_v1_runtime_display_region.json"
)


def load_renderer():
    module_spec = importlib.util.spec_from_file_location(
        "action_bars_simulation", RENDERER
    )
    assert module_spec and module_spec.loader
    module = importlib.util.module_from_spec(module_spec)
    module_spec.loader.exec_module(module)
    return module


def test_focus_v6_compact_dependent_cluster() -> None:
    renderer = load_renderer()
    spec = renderer.load_spec(SPEC, ROOT)

    assert spec["version"] == "ACTION-BARS-CORE-SIM-V6"
    assert spec["layout_contract"]["runtime_change_in_this_simulation"] is True
    assert spec["layout_contract"]["layout_mode"] == "compact-row-v6"
    assert spec["runtime_projection_proposal"]["combat_local_scale"] == {
        "player_target": 0.68,
        "targettarget": 0.62,
        "cast_swing_stance": 0.72,
        "doitedps": 0.82,
    }
    assert spec["consumables"]["labels_visible"] is False
    assert spec["totem_satellite"]["direction"] == "down"
    assert spec["totem_satellite"]["popup_count"] == 7

    report = renderer.validate_layout(spec)
    assert report["status"] == "pass"
    assert report["violations"] == []
    assert len(report["checks"]) == 36

    frames = {item["id"]: item for item in spec["unit_frames"]["frames"]}
    player = frames["UF.PLAYER.ADJACENCY"]
    target = frames["UF.TARGET.ADJACENCY"]
    target_target = frames["UF.TARGETTARGET.ADJACENCY"]
    assert target["screen_box"][0] - player["screen_box"][2] == 100
    assert target_target["screen_box"][0] - target["screen_box"][2] == 8
    assert player["aura_strips"][0]["direction"] == "ltr"
    assert player["aura_strips"][1]["direction"] == "ltr"
    assert target["aura_strips"][0]["direction"] == "rtl"
    assert target["aura_strips"][1]["direction"] == "rtl"
    assert target_target["aura_strips"][0]["direction"] == "rtl"
    assert target_target["aura_strips"][1]["direction"] == "rtl"

    casts = {
        item["id"]: item
        for item in spec["cast_bars"]["bars"]
        if item.get("visible_in_simulation", True)
    }
    swings = {item["id"]: item for item in spec["swing_timers"]["bars"]}
    ui_scale = float(spec["target"]["ui_scale"])
    player_cast = casts["CAST.PLAYER"]["screen_box"]
    target_cast = casts["CAST.TARGET"]["screen_box"]
    swing = renderer.indicator_box(swings["SWING.MAINHAND"], ui_scale)
    assert player_cast[2] - player_cast[0] == swing[2] - swing[0] == 146
    assert target_cast[2] - target_cast[0] == 146
    assert swing[0] - player_cast[2] == 8
    assert target_cast[0] - swing[2] == 8

    display = json.loads(SIMULATION_DISPLAY.read_text(encoding="utf-8"))
    assert display["component"] == "AB.FOCUS.LAYOUT.V1/simulation-v6"
    assert display["evidence"]["final_runtime"] is False
    assert display["evidence"]["source_screenshot_sha256"].startswith("de56051e")
    assert len(display["scenarios"]) == 6

    runtime = json.loads(RUNTIME_DISPLAY.read_text(encoding="utf-8"))
    assert runtime["component"] == "AB.FOCUS.LAYOUT.V1/runtime-v1.7"
    assert runtime["evidence"]["final_runtime"] is True
    assert runtime["evidence"]["adapter"].endswith("Modules/ActionBars.lua")
    assert runtime["evidence"]["accepted_simulation_spec"].endswith(
        "action_bars_core_simulation_v6.json"
    )
    assert runtime["evidence"]["source_revision_evidence_sha256"].startswith(
        "de56051e"
    )
    formula = runtime["evidence"]["layout_formula"]
    assert "Combat Deck BOTTOM (0,175)" in formula
    assert "TargetTarget fallback BOTTOM (414,500)" in formula
    assert "Player Cast/Swing/Target Cast" in formula
    assert "GetScreenHeight()/1080" not in formula
    assert len(runtime["scenarios"]) == 8


if __name__ == "__main__":
    test_focus_v6_compact_dependent_cluster()
    print("action focus simulation test passed")
