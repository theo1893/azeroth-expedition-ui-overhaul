#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = (
    ROOT
    / "tools"
    / "specs"
    / "action_sidebars_group_v1_runtime_display_region.json"
)
ACTION_BARS = ROOT / "addon" / "AzerothExpeditionUI" / "Modules" / "ActionBars.lua"
BOOTSTRAP = ROOT / "addon" / "AzerothExpeditionUI" / "Core" / "Bootstrap.lua"


def test_sidebars_group_runtime_contract() -> None:
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    assert contract["schema"] == "aeui-display-region-contract-v1"
    assert contract["component"] == "AB.SIDEBARS.GROUP.V1/runtime-v1.0"
    assert contract["evidence"]["final_runtime"] is True
    assert "大奶黑牛 - Basin of Stars" in contract["evidence"]["runtime_scope"]
    assert "one expanded bar2 mover" in contract["evidence"]["runtime_scope"]
    assert "no OnUpdate geometry loop" in contract["evidence"]["runtime_scope"]
    assert len(contract["scenarios"]) == 3

    grouped = contract["scenarios"][0]
    assert grouped["frame"] == [154, 202]
    assert [region["id"] for region in grouped["regions"]] == [
        "bar2-paging-3x4",
        "bar4-vertical-3x4",
        "bar5-left-3x4",
        "bar3-right-3x4",
    ]
    assert [region["box"] for region in grouped["regions"]] == [
        [0, 0, 74, 98],
        [80, 0, 154, 98],
        [0, 104, 74, 202],
        [80, 104, 154, 202],
    ]

    source = ACTION_BARS.read_text(encoding="utf-8")
    assert 'ActionBars.sideBarGroupRuntimeContract = "1.0"' in source
    assert 'ActionBars.sideBarGroupFormFactor = "3 x 4"' in source
    assert 'ActionBars.sideBarGroupAutoProfile = "大奶黑牛 - Basin of Stars"' in source
    assert "function ActionBars:SetSideBarGroupBinding(bound)" in source
    assert "function ActionBars:ConfigureSideBarGroupMover()" in source
    assert "function ActionBars:PersistSideBarGroupPositions()" in source
    assert "sideBarGroupDefinitions" in source
    assert "OnUpdate" not in source[source.index("local sideBarGroupDefinitions"):source.index("local function CaptureCombatFocusBackup")]

    bootstrap = BOOTSTRAP.read_text(encoding="utf-8")
    assert 'addon.version = "0.8.25"' in bootstrap
    assert 'string.find(command, "^sidebars")' in bootstrap
    assert "/aeui sidebars [bind|unbind|home|status]" in bootstrap


if __name__ == "__main__":
    test_sidebars_group_runtime_contract()
    print("action sidebars group runtime test passed")
