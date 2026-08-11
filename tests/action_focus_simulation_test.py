#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RENDERER = ROOT / "tools" / "render_action_bars_simulation.py"
SPEC = ROOT / "tools" / "specs" / "action_bars_core_simulation_v11.json"
SIMULATION_DISPLAY = (
    ROOT / "tools" / "specs" / "action_bars_core_simulation_v11_display_region.json"
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


def test_focus_v11_font_doite_and_side_cluster_proposal() -> None:
    renderer = load_renderer()
    spec = renderer.load_spec(SPEC, ROOT)

    assert spec["version"] == "ACTION-BARS-CORE-SIM-V11"
    assert spec["layout_contract"]["runtime_change_in_this_simulation"] is True
    assert spec["layout_contract"]["layout_mode"] == "compact-stack-v11"
    assert spec["runtime_projection_proposal"]["combat_local_scale"] == {
        "player_target": 0.8,
        "targettarget": 0.68,
        "cast_swing": 1.0,
        "stance": 0.72,
        "doitedps": 0.82,
    }
    assert spec["consumables"]["labels_visible"] is False
    assert spec["consumables"]["buttons"] == 13
    assert spec["consumables"]["rows"] == 4
    assert spec["totem_satellite"]["direction"] == "down"
    assert spec["totem_satellite"]["popup_count"] == 7

    report = renderer.validate_layout(spec)
    assert report["status"] == "pass"
    assert report["violations"] == []
    assert len(report["checks"]) == 68

    frames = {item["id"]: item for item in spec["unit_frames"]["frames"]}
    player = frames["UF.PLAYER.ADJACENCY"]
    target = frames["UF.TARGET.ADJACENCY"]
    target_target = frames["UF.TARGETTARGET.ADJACENCY"]
    assert target["screen_box"][0] - player["screen_box"][2] == 7
    assert target_target["screen_box"][0] - target["screen_box"][2] == 6
    assert player["screen_box"][1::2] == target["screen_box"][1::2]
    assert abs(
        round(sum(target["screen_box"][1::2]) / 2)
        - round(sum(target_target["screen_box"][1::2]) / 2)
    ) == 1
    assert player["screen_box"][2] - player["screen_box"][0] == 229
    assert target["screen_box"][2] - target["screen_box"][0] == 229
    assert target_target["screen_box"][2] - target_target["screen_box"][0] == 195
    assert all(frame["name_font"] == "body" for frame in frames.values())
    assert all(frame["level_font"] == "small" for frame in frames.values())
    assert all(frame["health_font"] == "small" for frame in frames.values())

    all_strips = [
        strip
        for frame in (player, target, target_target)
        for strip in frame["aura_strips"]
    ]
    assert player["aura_strips"][0]["direction"] == "ltr"
    assert player["aura_strips"][1]["direction"] == "ltr"
    assert target["aura_strips"][0]["direction"] == "rtl"
    assert target["aura_strips"][1]["direction"] == "rtl"
    assert target_target["aura_strips"][0]["direction"] == "rtl"
    assert target_target["aura_strips"][1]["direction"] == "rtl"
    assert [strip["size"] for strip in all_strips] == [22, 22, 22, 22, 19, 19]
    assert [strip["gap"] for strip in all_strips] == [7, 7, 7, 7, 6, 6]
    assert [len(strip["auras"]) for strip in all_strips] == [8, 8, 8, 16, 8, 8]
    assert all(strip["per_row"] == 8 for strip in all_strips)
    assert player["aura_strips"][0]["origin"][0] == player["screen_box"][0]
    assert player["aura_strips"][1]["origin"][0] == player["screen_box"][0]
    assert target["aura_strips"][0]["origin"][0] + 22 == target["screen_box"][2]
    assert target_target["aura_strips"][0]["origin"][0] + 19 == target_target["screen_box"][2]
    recommendation = spec["unit_frames"]["profile_recommendation"]["proposed_shared"]
    assert recommendation["customfont_role"] == "client-system"
    assert recommendation["customfont_size_ui"] == 18
    assert recommendation["customfont_style"] == "OUTLINE"
    assert recommendation["aura_size_ui"] == 23
    assert recommendation["aura_per_row"] == 8
    assert 23 + 7 * (23 + 7) == 233
    target_debuffs = target["aura_strips"][1]
    assert len(target_debuffs["auras"]) == 16
    assert target_debuffs["per_row"] == 8
    target_debuff_bottom = (
        target_debuffs["origin"][1]
        + target_debuffs["size"]
        + target_debuffs["size"]
        + target_debuffs["row_gap"]
    )

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
    offhand = renderer.indicator_box(swings["SWING.OFFHAND"], ui_scale)
    for readout in (player_cast, target_cast, swing, offhand):
        assert readout[2] - readout[0] == 293
        assert readout[3] - readout[1] == 14
        assert round((readout[0] + readout[2]) / 2) == 960
    assert target_cast[1] - player_cast[3] == 3
    assert swing[1] - target_cast[3] == 3
    assert offhand[1] - swing[3] == 2
    assert player_cast[1] - target_debuff_bottom == 3

    projection = spec["runtime_projection_proposal"]
    assert projection["player"]["xpos_ui"] == -160
    assert projection["target"]["xpos_ui"] == 105
    assert projection["player"]["ypos_ui"] == 485
    assert projection["target"]["ypos_ui"] == 485
    assert projection["targettarget"]["xpos_ui"] == 393
    assert projection["targettarget"]["ypos_ui"] == 576
    assert "RIGHT of pfTarget + 8 UI" in projection["targettarget"]["live_anchor"]
    assert projection["player_castbar"]["xpos_ui"] == 0
    assert projection["target_castbar"]["xpos_ui"] == 0
    assert projection["swing_main_and_ranged"]["xpos_ui"] == 0
    assert projection["player_castbar"]["ypos_ui"] == 316
    assert projection["target_castbar"]["ypos_ui"] == 300
    assert projection["swing_main_and_ranged"]["ypos_ui"] == 284
    assert projection["auras"] == {
        "size_ui": 23,
        "provider_gap_ui": 7,
        "per_row": 8,
        "row_span_ui": 233,
        "row_slack_ui": 7,
    }
    assert projection["fieldkit"]["consumable_and_trinket_y_offset_ui"] == -20
    assert projection["doitedps"]["xpos_ui"] == 850
    assert projection["doitedps"]["ypos_ui"] == -615
    assert projection["unit_font"] == {
        "role": "client STANDARD_TEXT_FONT",
        "customfont": 1,
        "customfont_size_ui": 18,
        "customfont_style": "OUTLINE",
        "scope": ["player", "target", "ttarget"],
    }
    assert spec["consumables"]["screen_origin"][1] == 757
    assert spec["trinkets"]["screen_origin"][1] == 850

    side = spec["side_cluster"]
    assert side["proposal_only"] is True
    assert [item["id"] for item in side["bars"]] == [
        "AB.BAR2.PAGING",
        "AB.BAR4.VERTICAL",
        "AB.BAR5.LEFT",
        "AB.BAR3.RIGHT",
    ]
    assert all(item["buttons"] == 12 for item in side["bars"])
    assert all((item["cols"], item["rows"]) == (3, 4) for item in side["bars"])
    side_boxes = [renderer.bar_geometry(item, ui_scale) for item in side["bars"]]
    assert side_boxes[1][0] - (side_boxes[0][0] + side_boxes[0][2]) == 6
    assert side_boxes[2][1] - (side_boxes[0][1] + side_boxes[0][3]) == 6
    assert max(item[0] + item[2] for item in side_boxes) == 1892
    assert min(item[0] for item in side_boxes) == 1738
    assert max(item[1] + item[3] for item in side_boxes) == 748
    assert min(item[1] for item in side_boxes) == 546

    display = json.loads(SIMULATION_DISPLAY.read_text(encoding="utf-8"))
    assert display["component"] == "AB.FOCUS.LAYOUT.V1/simulation-v11"
    assert display["evidence"]["final_runtime"] is False
    assert display["evidence"]["source_screenshot_focus_sha256"].startswith(
        "06da8388"
    )
    assert display["evidence"]["source_screenshot_sidebars_sha256"].startswith(
        "6abe43c7"
    )
    assert len(display["scenarios"]) == 3

    runtime = json.loads(RUNTIME_DISPLAY.read_text(encoding="utf-8"))
    assert runtime["component"] == "AB.FOCUS.LAYOUT.V1/runtime-v2.2"
    assert runtime["evidence"]["final_runtime"] is True
    assert runtime["evidence"]["adapter"].endswith("Modules/ActionBars.lua")
    assert runtime["evidence"]["accepted_simulation_spec"].endswith(
        "action_bars_core_simulation_v11.json"
    )
    formula = runtime["evidence"]["layout_formula"]
    assert "Combat Deck BOTTOM (0,175)" in formula
    assert "TargetTarget fallback BOTTOM (393,576)" in formula
    assert "Player/Target BOTTOM (-160,485)/(105,485)" in formula
    assert "Aura 23 UI" in formula
    assert "STANDARD_TEXT_FONT at local size 18" in formula
    assert "y offset -20" in formula
    assert "Player Cast BOTTOM (0,316)" in formula
    assert "Target Cast BOTTOM (0,300)" in formula
    assert "Swing BOTTOM (0,284)" in formula
    assert "DoiteDPS TOPLEFT (850,-615)" in formula
    assert "GetScreenHeight()/1080" not in formula
    assert len(runtime["scenarios"]) == 12


if __name__ == "__main__":
    test_focus_v11_font_doite_and_side_cluster_proposal()
    print("action focus simulation test passed")
