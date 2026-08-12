#!/usr/bin/env python3
"""Static checks for the pre-production pfUI raid-frame contract."""

from __future__ import annotations

import hashlib
import json
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "tools/specs/unitframes_raid_simulation_v1.json"
PRODUCTION = ROOT / "tools/specs/unitframes_raid_production_v1.json"
DISPLAY = ROOT / "tools/specs/unitframes_raid_simulation_display_region_v1.json"
RENDERER = ROOT / "tools/render_unitframes_raid_simulation_v1.py"
REVIEWER = ROOT / "tools/review_unitframes_raid_candidate_v1.py"
WORK = ROOT / "docs/modules/unitframes/work/UNITFRAMES.RAID.md"
SUBMODULES = ROOT / "docs/modules/unitframes/SUBMODULES.md"
SUBMODULE_ART = ROOT / "docs/modules/unitframes/SUBMODULE_ART_BASELINES.md"
PROGRESS = ROOT / "docs/modules/unitframes/PROGRESS.md"
AGENTS = ROOT / "AGENTS.md"
RAID_PROVIDER = ROOT / "addon/pfUI/modules/raid.lua"
UF_PROVIDER = ROOT / "addon/pfUI/api/unitframes.lua"
PROFILE = ROOT / "addon/pfUI/env/profiles.lua"
ADAPTER = ROOT / "addon/AzerothExpeditionUI/Modules/UnitFrames.lua"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    spec = json.loads(SPEC.read_text(encoding="utf-8"))
    assert spec["schema"] == "aeui-unitframes-raid-simulation-v1"
    assert spec["version"] == "UF-RAID-SIM-V1"
    assert spec["status"] == "simulation-confirmed"
    assert spec["imagegen_usage"] == "0/0"
    assert spec["user_confirmation"] == {
        "status": "confirmed",
        "date": "2026-08-12",
        "accepts_pixels": False,
        "production_authorized": False,
    }
    accepted = spec["accepted_visible_direction"]
    assert "no shared outer frame" in accepted["layout"]
    assert "forty-member formation" in accepted["visual_weight"]

    provider = spec["provider"]
    assert provider["maxraid"] == 40
    assert provider["layout"] == [10, 4]
    assert provider["fill"] == "VERTICAL"
    assert provider["raidpadding"] == 5
    assert provider["frame"] == [70, 33]
    assert provider["health"] == [70, 30]
    assert provider["power"] == [70, 2]
    assert provider["health_power_gap"] == 1
    assert provider["pitch"] == [77, 40]
    assert provider["button_cluster_bbox"] == [763, 153]
    assert provider["visual_cluster_bbox_with_shell_and_markers"] == [767, 159]

    architecture = spec["architecture"]
    assert architecture["no_shared_outer_panel"] is True
    shell = architecture["member_shell"]
    assert shell["production_object_count"] == 4
    assert shell["runtime_repeat_count"] == 40
    assert shell["runtime_art_box"] == [74, 37]
    assert shell["provider_button_inset"] == [2, 2, 2, 2]
    assert shell["dynamic_content_baked"] is False
    assert "fail" in shell["vertical_resize"]
    variants = architecture["variant_slot_order"]
    assert len(variants) == 40
    assert Counter(variants) == {"A": 10, "B": 10, "C": 10, "D": 10}
    assert architecture["bars"]["current_addon_scope_includes_raid"] is False
    assert architecture["optional_group_label"]["production_in_this_gate"] is False

    production = json.loads(PRODUCTION.read_text(encoding="utf-8"))
    assert production["schema"] == "aeui-unitframes-raid-production-v1"
    assert production["version"] == "UF-RAID-A1 V1 final"
    assert production["status"] == "repair-prepared"
    assert production["production_authorized"] is True
    assert production["authorization"]["authorized_version"] == (
        "UF-RAID-A1 V1 final"
    )
    assert production["authorization"]["maximum_actual_imagegen_calls"] == 5
    assert production["authorization"]["process_errors_count_toward_limit"] is False
    assert production["simulation_gate"] == {
        "version": "UF-RAID-SIM-V1",
        "status": "simulation-confirmed",
        "date": "2026-08-12",
        "accepts_pixels": False,
    }
    assert production["scope"]["generated_object_count"] == 4
    assert production["scope"]["runtime_repeat_count"] == 40
    assert production["scope"]["state_art"].startswith("derived deterministically")
    assert production["canvas"]["size"] == [1536, 1024]
    assert production["canvas"]["mode"] == "RGB"
    assert production["canvas"]["background"] == "#00FF00"
    cells = production["canvas"]["cells"]
    assert [cell["id"] for cell in cells] == ["A", "B", "C", "D"]
    assert [cell["target_visible_bbox"] for cell in cells] == [
        [88, 108, 680, 404],
        [856, 108, 1448, 404],
        [88, 620, 680, 916],
        [856, 620, 1448, 916],
    ]
    normalized = production["normalized_source"]
    assert normalized["per_variant"] == [592, 296]
    assert normalized["runtime"] == [74, 37]
    assert normalized["horizontal_three_slice_source"] == [48, 496, 48]
    assert normalized["horizontal_three_slice_runtime"] == [6, 62, 6]
    assert len(production["runtime_assignment"]) == 40
    assert Counter(production["runtime_assignment"]) == {
        "A": 10,
        "B": 10,
        "C": 10,
        "D": 10,
    }
    assert production["repair_loop"]["maximum_actual_imagegen_calls"] == 5
    assert production["repair_loop"]["process_errors_count_toward_limit"] is False
    assert production["repair_loop"]["execution_state"] == {
        "attempts_used": 4,
        "attempts_remaining": 1,
        "process_errors": 1,
        "current_prompt_version": "UF-RAID-A1 V1 final.r4",
        "next_operation": (
            "final regenerate from fixed Image 1/2 only; no Image 3; small "
            "440x220 safety sources then authorized bbox normalization"
        ),
    }

    expected_locked = {
        "assets/locked/chat/聊天框视觉基准_v1.png":
            "90e30ba405a2b5cdc707cc229e56c4f64e51d0e4051f1e98dbcd2ec2ee70ee06",
        "assets/locked/chat/聊天框独立艺术资源_v3.png":
            "272528e6d89cc90e5cbb37dce4ae572ddf9de0402078cdcf0ed5804f734faab8",
    }
    for item in spec["locked_references"]:
        assert item["sha256"] == expected_locked[item["path"]]
        assert sha256(ROOT / item["path"]) == item["sha256"]

    display = json.loads(DISPLAY.read_text(encoding="utf-8"))
    assert display["schema"] == "aeui-display-region-contract-v1"
    assert display["atlas"]["size"] == [148, 74]
    assert display["atlas"]["require_exact_visible_coverage"] is True
    assert display["nine_slice"]["caps"] == {
        "left": 6,
        "right": 6,
        "top": 2,
        "bottom": 2,
    }
    scenarios = {item["id"]: item for item in display["scenarios"]}
    assert set(scenarios) == {
        "member-normal-with-raid-marker",
        "member-state-heavy",
        "raid-40-max-vertical-fill",
        "raid-40-max-horizontal-fill",
        "raid-20-typical",
        "raid-for-party-5",
        "member-variable-width-90",
    }
    assert scenarios["member-normal-with-raid-marker"]["frame"] == [74, 39]
    assert scenarios["raid-40-max-vertical-fill"]["frame"] == [767, 159]
    assert scenarios["raid-20-typical"]["frame"] == [382, 159]
    assert scenarios["raid-for-party-5"]["frame"] == [151, 159]

    raid_source = RAID_PROVIDER.read_text(encoding="utf-8")
    for clause in (
        'local maxraid = tonumber(C.unitframes.maxraid)',
        'CreateUnitFrame("Raid", i, C.unitframes.raid)',
        'local layout = pfUI.uf.raid[1].config.raidlayout',
        'local padding = tonumber(pfUI.uf.raid[1].config.raidpadding)',
        'if fill == "VERTICAL" then',
        'for subindex = 1, 5 do',
    ):
        assert clause in raid_source, f"raid provider drifted: {clause}"

    uf_source = UF_PROVIDER.read_text(encoding="utf-8")
    for clause in (
        "local real_height = height + spacing + pheight + 2*default_border",
        'if f.label == "raid" and mod(f.id, 5) == 1 then',
        "f.ressIcon:SetWidth(32)",
        "f.raidIcon:SetWidth(f.config.raidiconsize)",
        "ClickCastFrames[f] = true",
    ):
        assert clause in uf_source, f"unitframe provider drifted: {clause}"

    profile = PROFILE.read_text(encoding="utf-8")
    for clause in (
        '["raidlayout"] = "10x4"',
        '["raidpadding"] = "5"',
        '["raidfill"] = "VERTICAL"',
        '["width"] = "70"',
        '["height"] = "30"',
        '["pheight"] = "2"',
    ):
        assert clause in profile, f"profile geometry drifted: {clause}"

    adapter = ADAPTER.read_text(encoding="utf-8")
    frame_keys = adapter.split("local FRAME_KEYS", 1)[1].split("}", 1)[0]
    assert '"raid"' not in frame_keys
    assert "Party, raid, pet" in adapter

    renderer = RENDERER.read_text(encoding="utf-8")
    for clause in (
        "UnitFrameHealthFillV1.tga",
        "UnitFramePowerFillV1.tga",
        "compose_cluster(spec, 40)",
        "pfRaid1..40",
        "ImageGen 0/0",
    ):
        assert clause in renderer, f"raid simulation renderer missing: {clause}"

    reviewer = REVIEWER.read_text(encoding="utf-8")
    for clause in (
        "connected_chroma_key",
        "runtime_repeat_count",
        "cluster_visual_envelope",
        "diagnostic-proportional-fit-only",
        "member_tile(spec, shells, index)",
        "render_real_layout",
    ):
        assert clause in reviewer, f"raid candidate reviewer missing: {clause}"

    work = WORK.read_text(encoding="utf-8")
    for clause in (
        "repair-prepared / attempt-3-pending",
        "ImageGen：`0/0`",
        "不增加一圈共享书框",
        "四个完整外壳变体",
        "7/7 pass",
        "正式生产授权：`true / UF-RAID-A1 V1 final / 2026-08-12`",
        "UF-RAID-A1 V1 final",
        "exactly four complete empty raid-member",
        "pass-final",
        "当前实际生图：`2/5`",
        "UF-RAID-A1 V1 final.r1",
        "UF-RAID-A1 V1 final.r2",
        "019ff4da-2586-7cc1-8174-8de62fab3f64",
        "019ff4e5-8c60-7fb2-a18f-49dda781d752",
        "continuous rope, braid, lacing",
        "Create from scratch one production sheet",
    ):
        assert clause in work, f"raid work record missing: {clause}"

    submodules = SUBMODULES.read_text(encoding="utf-8")
    submodule_art = SUBMODULE_ART.read_text(encoding="utf-8")
    progress = PROGRESS.read_text(encoding="utf-8")
    agents = AGENTS.read_text(encoding="utf-8")
    assert "## Raid 团队框架批次" in submodules
    assert "UF.RAID.MEMBER.SHELL.A-D" in submodules
    assert "40 个高密度点名名条" in submodule_art
    assert "UF-RAID-SIM-V1" in progress
    assert "UF-RAID-A1 V1 final" in progress
    assert "docs/modules/unitframes/work/UNITFRAMES.RAID.md" in agents

    print("unitframes raid design contract test passed")


if __name__ == "__main__":
    main()
