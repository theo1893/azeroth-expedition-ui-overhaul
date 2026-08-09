#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RENDERER = ROOT / "tools" / "render_action_bars_simulation.py"
SPEC = ROOT / "tools" / "specs" / "action_bars_core_simulation_v4.json"
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


def test_focus_v4_layout_and_architotem_footprint() -> None:
    renderer = load_renderer()
    spec = renderer.load_spec(SPEC, ROOT)

    assert spec["version"] == "ACTION-BARS-CORE-SIM-V4"
    assert spec["layout_contract"]["runtime_change_in_this_simulation"] is False
    assert spec["totem_satellite"]["provider"].startswith("ArchiTotem 1.7")
    assert spec["totem_satellite"]["direction"] == "down"
    assert spec["totem_satellite"]["popup_count"] == 7
    assert spec["totem_satellite"]["binding_policy"].startswith(
        "fieldKitBound uses Bar 1"
    )

    report = renderer.validate_layout(spec)
    assert report["status"] == "pass"
    assert report["violations"] == []
    assert len(report["checks"]) == 54

    geometry = renderer.totem_geometry(
        spec["totem_satellite"], float(spec["target"]["ui_scale"])
    )
    assert geometry["button"] == 26
    assert geometry["handle"] == 16
    assert geometry["width"] == 172
    assert geometry["popup_bottom"] == 1077

    player, target = spec["unit_frames"]["frames"]
    assert target["screen_box"][0] - player["screen_box"][2] == 34
    assert player["screen_box"][0] == 681
    assert target["screen_box"][2] == 1239

    runtime = json.loads(RUNTIME_DISPLAY.read_text(encoding="utf-8"))
    assert runtime["component"] == "AB.FOCUS.LAYOUT.V1/runtime-v1.3"
    assert runtime["evidence"]["final_runtime"] is True
    assert runtime["evidence"]["adapter"].endswith("Modules/ActionBars.lua")
    assert len(runtime["scenarios"]) == 7

    linear_growth = 0.82 / 0.75 - 1
    area_growth = (0.82 / 0.75) ** 2 - 1
    assert 0.09 < linear_growth < 0.10
    assert 0.19 < area_growth < 0.20


if __name__ == "__main__":
    test_focus_v4_layout_and_architotem_footprint()
    print("action focus simulation test passed")
