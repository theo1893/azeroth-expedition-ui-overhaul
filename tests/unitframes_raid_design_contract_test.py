#!/usr/bin/env python3
"""Static checks for the exhausted pfUI raid-frame production contract."""

from __future__ import annotations

import hashlib
import json
import sys
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "tools/specs/unitframes_raid_simulation_v1.json"
PRODUCTION = ROOT / "tools/specs/unitframes_raid_production_v1.json"
DISPLAY = ROOT / "tools/specs/unitframes_raid_simulation_display_region_v1.json"
RENDERER = ROOT / "tools/render_unitframes_raid_simulation_v1.py"
REVIEWER = ROOT / "tools/review_unitframes_raid_candidate_v1.py"
DONOR_SIMULATION = ROOT / "tools/specs/unitframes_raid_donor_simulation_v1.json"
DONOR_PRODUCTION = ROOT / "tools/specs/unitframes_raid_donor_production_v1.json"
DONOR_BUILDER = ROOT / "tools/build_unitframes_raid_donor_shells_v1.py"
DONOR_RENDERER = ROOT / "tools/render_unitframes_raid_donor_simulation_v1.py"
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
    assert production["status"] == "candidate-rejected / repair-budget-exhausted"
    assert production["production_authorized"] is False
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
        "attempts_used": 5,
        "attempts_remaining": 0,
        "process_errors": 2,
        "current_prompt_version": "UF-RAID-A1 V1 final.r4",
        "next_operation": (
            "none; repair budget exhausted; sixth ImageGen call forbidden "
            "without a new explicit contract"
        ),
    }
    terminal = production["terminal_review"]
    assert terminal["result"] == "candidate-rejected / repair-budget-exhausted"
    assert terminal["attempts_used"] == 5
    assert terminal["best_internal_visual_reference"]["attempt"] == 3
    assert terminal["best_internal_visual_reference"]["may_enter_p4"] is False
    assert terminal["final_attempt"]["attempt"] == 5
    assert terminal["final_attempt"]["technical_pass"] is False
    assert terminal["candidate_written"] is False
    assert terminal["source_written"] is False
    assert terminal["runtime_written"] is False
    assert terminal["addon_changed"] is False
    assert terminal["sixth_call_allowed"] is False

    donor_simulation = json.loads(DONOR_SIMULATION.read_text(encoding="utf-8"))
    assert donor_simulation["schema"] == "aeui-unitframes-raid-donor-simulation-v1"
    assert donor_simulation["version"] == "UF-RAID-A2-SIM-V1"
    assert donor_simulation["status"] == "simulation-confirmed"
    decision = donor_simulation["architecture_decision"]
    assert decision["status"] == "user-selected"
    assert decision["authorizes_imagegen"] is False
    assert "material donors" in decision["statement"]
    confirmation = donor_simulation["user_confirmation"]
    assert confirmation["status"] == "confirmed"
    assert confirmation["date"] == "2026-08-12"
    assert confirmation["statement"] == "确认UF-RAID-A2-SIM-V1"
    assert confirmation["accepts_simulation_pixels"] is False
    assert confirmation["production_authorized"] is False
    assert len(confirmation["accepted_visible_direction"]) == 8
    donor_provider = donor_simulation["provider"]
    assert donor_provider["maxraid"] == 40
    assert donor_provider["frame"] == [70, 33]
    assert donor_provider["runtime_shell"] == [74, 37]
    assert donor_provider["member_display_envelope"] == [74, 39]
    assert donor_provider["cluster_visual_envelope"] == [767, 159]
    donor_contract = donor_simulation["donor_contract"]
    assert donor_contract["imagegen_object_count"] == 1
    assert donor_contract["canvas"] == [1536, 1024]
    assert donor_contract["runtime_loaded"] is False
    assert donor_contract["source_promoted_directly"] is False
    assert set(donor_contract["cells"]) == {"leather", "liner", "brass", "thread"}
    for contract in donor_contract["cells"].values():
        cx0, cy0, cx1, cy1 = contract["cell"]
        sx0, sy0, sx1, sy1 = contract["sample_window"]
        assert cx0 < sx0 < sx1 < cx1
        assert cy0 < sy0 < sy1 < cy1

    deterministic = donor_simulation["deterministic_builder"]
    assert deterministic["normalized_source"] == [592, 296]
    assert deterministic["runtime"] == [74, 37]
    assert deterministic["provider_button_source"] == [16, 16, 576, 280]
    assert deterministic["quiet_name_source"] == [40, 48, 552, 232]
    assert deterministic["horizontal_three_slice_source"] == [48, 496, 48]
    assert deterministic["horizontal_three_slice_runtime"] == [6, 62, 6]
    assert deterministic["variant_order"] == ["A", "B", "C", "D"]
    repair_bounds = deterministic["variant_repair_bounds"]
    for variant in ("A", "B", "C", "D"):
        for box in repair_bounds[variant].values():
            x0, y0, x1, y1 = box
            assert 0 <= x0 < x1 <= 592
            assert 0 <= y0 < y1 <= 296
            assert x1 <= 50 or x0 >= 544
    assert Counter(donor_simulation["simulation"]["variant_slot_order"]) == {
        "A": 10, "B": 10, "C": 10, "D": 10,
    }
    assert donor_simulation["simulation"]["imagegen_usage"] == "0/0"
    internal_review = donor_simulation["internal_review"]
    assert internal_review["imagegen_calls"] == 0
    assert internal_review["display_region"] == "7/7 pass; 0 violations"
    assert internal_review["production_authorized"] is False

    donor_production = json.loads(DONOR_PRODUCTION.read_text(encoding="utf-8"))
    assert donor_production["schema"] == "aeui-unitframes-raid-donor-production-v1"
    assert donor_production["version"] == "UF-RAID-A2-DONOR V1"
    assert donor_production["status"] == (
        "repair-budget-exhausted / exception-review-required / 5-of-5"
    )
    assert donor_production["production_authorized"] is False
    assert donor_production["architecture"]["simulation_confirmation"] == {
        "status": "confirmed",
        "date": "2026-08-12",
        "accepts_pixels": False,
        "production_authorized": True,
    }
    assert donor_production["output_contract"]["image_count"] == 1
    assert donor_production["output_contract"]["runtime_loaded"] is False
    completeness = donor_production["prompt_completeness"]
    assert completeness["result"] == "pass-final"
    assert completeness["unknown_execution_critical_values"] == []
    for key, value in completeness.items():
        if key not in {"audit_date", "result", "unknown_execution_critical_values"}:
            assert value is True, key
    assert "Python constructs all exact geometry" in donor_production["prompt_body"]
    assert "Use Image 1 only" in donor_production["prompt_body"]
    assert "Use Image 2 only" in donor_production["prompt_body"]
    assert "Do not use any simulation image" in donor_production["prompt_body"]
    assert "Before returning, verify visibly" in donor_production["prompt_body"]
    assert "No text of any kind" in donor_production["prompt_body"]
    donor_loop = donor_production["repair_loop"]
    assert donor_loop["maximum_actual_imagegen_calls"] == 5
    assert donor_loop["process_errors_count_toward_limit"] is False
    assert donor_loop["execution_state"]["attempts_used"] == 5
    assert donor_loop["execution_state"]["attempts_remaining"] == 0
    assert donor_loop["execution_state"]["process_errors"] == 2
    assert donor_loop["execution_state"]["current_prompt_version"] == (
        "UF-RAID-A2-DONOR V1.r4"
    )
    assert donor_loop["execution_state"]["current_prompt_body_sha256"] == (
        "ed3ec1599512a5b6c42695334bc1466e560ac010b428b3261f4503fba30bb078"
    )
    assert len(donor_production["attempts"]) == 5
    assert [item["attempt"] for item in donor_production["attempts"]] == [1, 2, 3, 4, 5]
    assert donor_production["attempts"][0]["raw_sha256"] == (
        "ac2f7a2adf120f932bb3785c5b2b9dfc83d00a8ed9812421400120cfb86aec23"
    )
    assert donor_production["attempts"][1]["raw_sha256"] == (
        "d6479b8907e3200e8d3b9ebb5e9a3b44aacbbcf531d5f2b0f9036e1fcd30c893"
    )
    assert donor_production["attempts"][2]["raw_sha256"] == (
        "6f54172bfacd4215ba431c3cc34aea7d75c0c391a473042e62c1ee5cc6ff4b28"
    )
    assert donor_production["attempts"][3]["raw_sha256"] == (
        "7750b39de94bd062be6bc7158b0f4a4ca3bf1eea93a1746baedb128a3e70ddab"
    )
    assert donor_production["attempts"][4]["raw_sha256"] == (
        "dad020c26b772a26b856688bc0f5c4cf804b5d0f0ff932846feb37a701a6f159"
    )
    assert len(donor_production["process_error_records"]) == 2
    assert all(
        record["counts_toward_imagegen_budget"] is False
        for record in donor_production["process_error_records"]
    )
    terminal = donor_production["terminal_review"]
    assert terminal["attempts_used"] == 5
    assert terminal["best_runtime_visual_attempt"] == 5
    assert terminal["sample_windows"].startswith("4/4")
    assert terminal["strict_fixed_cells"].startswith("fail")
    assert terminal["display_region"] == "7/7 pass; 0 violations"
    assert terminal["candidate_accepted"] is False
    assert terminal["source_promoted"] is False
    assert terminal["runtime_exported"] is False
    assert terminal["addon_integrated"] is False
    assert terminal["sixth_imagegen_call_forbidden"] is True
    authorization_request = donor_production["authorization_request"]
    assert authorization_request["status"] == "granted"
    assert authorization_request["date"] == "2026-08-12"
    assert authorization_request["user_statement"].startswith(
        "确认授权 UF-RAID-A2-DONOR V1"
    )
    assert authorization_request["exact_version"] == "UF-RAID-A2-DONOR V1"
    assert authorization_request["maximum_actual_imagegen_calls"] == 5
    assert authorization_request["process_errors_count_toward_limit"] is False

    sys.path.insert(0, str(ROOT / "tools"))
    from build_unitframes_raid_donor_shells_v1 import (  # noqa: PLC0415
        build_shells,
        clear_transparent_rgb,
        synthetic_materials,
    )
    shell_set = build_shells(donor_simulation, synthetic_materials(donor_simulation))
    assert set(shell_set.sources) == {"A", "B", "C", "D"}
    assert set(shell_set.runtimes) == {"A", "B", "C", "D"}
    for variant in ("A", "B", "C", "D"):
        source = shell_set.sources[variant]
        runtime = shell_set.runtimes[variant]
        assert source.size == (592, 296)
        assert runtime.size == (74, 37)
        assert source.getbbox() == (0, 0, 592, 296)
        assert runtime.getbbox() == (0, 0, 74, 37)
        assert source.getchannel("A").crop((16, 16, 576, 280)).getextrema() == (255, 255)
        for red, green, blue, alpha in source.getdata():
            if alpha == 0:
                assert (red, green, blue) == (0, 0, 0)
    assert shell_set.sources["A"].getpixel((25, 5))[3] == 0
    assert shell_set.sources["B"].getpixel((25, 5))[3] == 255
    assert shell_set.sources["D"].getpixel((31, 286))[3] < 64
    assert len({shell_set.runtimes[key].tobytes() for key in ("A", "B", "C", "D")}) == 4
    from PIL import Image  # noqa: PLC0415
    alpha_probe = Image.new("RGBA", (2, 1))
    alpha_probe.putdata(((120, 80, 40, 0), (120, 80, 40, 128)))
    cleaned_probe = clear_transparent_rgb(alpha_probe)
    assert cleaned_probe.getpixel((0, 0)) == (0, 0, 0, 0)
    assert cleaned_probe.getpixel((1, 0)) == (120, 80, 40, 128)

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
    assert display["evidence"]["assembly_simulation_spec"] == (
        "tools/specs/unitframes_raid_donor_simulation_v1.json"
    )
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

    donor_builder = DONOR_BUILDER.read_text(encoding="utf-8")
    for clause in (
        "ImageGen only generates rough material donors",
        "def synthetic_materials",
        "def load_donor_materials",
        "def build_shells",
        "def clear_transparent_rgb",
        "choose exactly one of --donor or --simulation",
    ):
        assert clause in donor_builder, f"raid donor builder missing: {clause}"
    donor_renderer = DONOR_RENDERER.read_text(encoding="utf-8")
    for clause in (
        "compose_cluster(spec, shells, 40)",
        "UnitFrameHealthFillV1.tga",
        "UnitFramePowerFillV1.tga",
        "ImageGen 0/0",
        "material-only donor",
    ):
        assert clause in donor_renderer, f"raid donor renderer missing: {clause}"

    work = WORK.read_text(encoding="utf-8")
    for clause in (
        "candidate-rejected / 5/5 / waiting-new-user-direction",
        "ImageGen：`0/0`",
        "不增加一圈共享书框",
        "四个完整外壳变体",
        "7/7 pass",
        "正式生产授权：`true / UF-RAID-A1 V1 final / 2026-08-12`",
        "UF-RAID-A1 V1 final",
        "exactly four complete empty raid-member",
        "pass-final",
        "当前实际生图：`5/5`",
        "UF-RAID-A1 V1 final.r1",
        "UF-RAID-A1 V1 final.r2",
        "UF-RAID-A1 V1 final.r3",
        "UF-RAID-A1 V1 final.r4",
        "019ff4da-2586-7cc1-8174-8de62fab3f64",
        "019ff4e5-8c60-7fb2-a18f-49dda781d752",
        "019ff4eb-de51-7fe1-98cb-570447d68de3",
        "019ff4f2-9d85-7773-bdc8-c60f33f1e3bb",
        "019ff4f8-5010-7df0-9ee0-8a6627b4c507",
        "continuous rope, braid, lacing",
        "Create from scratch one production sheet",
        "repair-budget-exhausted / candidate-rejected / 5/5",
        "UF-RAID-A2-SIM-V1",
        "ImageGen material donor only + Python deterministic shell",
        "production_authorized=false",
        "确认UF-RAID-A2-SIM-V1",
        "UF-RAID-A2-DONOR V1` 正文完整性复检",
        "当前授权状态：`consumed / 2026-08-12 / 5-of-5 / sixth-call-forbidden`",
        "UF-RAID-A2-DONOR V1.r1",
        "ac2f7a2a…ec23",
        "UF-RAID-A2-DONOR V1.r2",
        "d6479b89…c893",
        "UF-RAID-A2-DONOR V1.r3",
        "6f54172b…4b28",
        "UF-RAID-A2-DONOR V1.r4",
        "7750b39d…ddab",
        "dad020c2…f159",
        "sample-window-only",
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
    assert "UF-RAID-A2-SIM-V1" in progress
    assert "exception-review-required" in progress
    assert "模型供材、Python 造壳" in submodule_art
    assert "build_unitframes_raid_donor_shells_v1.py" in submodules
    assert "docs/modules/unitframes/work/UNITFRAMES.RAID.md" in agents

    print("unitframes raid design contract test passed")


if __name__ == "__main__":
    main()
