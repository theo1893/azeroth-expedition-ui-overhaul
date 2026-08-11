#!/usr/bin/env python3
"""Static contract checks for the active Unit Frames V3 design."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / "docs/modules/unitframes/work/UNITFRAMES.CORE.md"
SUBMODULES = ROOT / "docs/modules/unitframes/SUBMODULES.md"
SUBMODULE_ART = ROOT / "docs/modules/unitframes/SUBMODULE_ART_BASELINES.md"
SIM_SPEC = ROOT / "tools/specs/unitframes_primary_v3_simulation_v1.json"
DISPLAY_SPEC = (
    ROOT
    / "tools/specs/unitframes_primary_v3_simulation_display_region_v1.json"
)
RENDERER = ROOT / "tools/render_unitframes_primary_v3_simulation_v1.py"
REVIEWER = ROOT / "tools/review_unitframes_primary_v3_candidate.py"
BARS_REVIEWER = ROOT / "tools/review_unitframes_bars_v2_candidate.py"
LEGACY_V2 = ROOT / "tools/specs/unitframes_a1_v2a_production_v2.json"


def extract_fenced_body(source: str, heading: str) -> str:
    after = source.split(heading, 1)[1]
    opening = after.index("```text") + len("```text")
    closing = after.index("```", opening)
    return after[opening:closing]


def assert_clauses(body: str, clauses: tuple[str, ...]) -> None:
    normalized = " ".join(body.split())
    for clause in clauses:
        assert clause in normalized, f"active Unit Frames final missing: {clause}"


def main() -> None:
    sim = json.loads(SIM_SPEC.read_text(encoding="utf-8"))
    assert sim["schema"] == "aeui-unitframes-primary-v3-simulation-v1"
    assert sim["version"] == "UF-PRIMARY-V3-SIM-V1"
    assert sim["status"] == "simulation-confirmed"
    confirmation = sim["user_confirmation"]
    assert confirmation["date"] == "2026-08-11"
    assert confirmation["version"] == "UF-PRIMARY-V3-SIM-V1"
    assert confirmation["accepts_pixels"] is False
    assert confirmation["production_authorized"] is True
    authorization = confirmation["production_authorization"]
    assert authorization["versions"] == [
        "UF-A1 V3-A final",
        "UF-A1 V3-B final",
        "UF-B1 V2 final",
    ]
    assert authorization["actual_generation_limit_per_version"] == 5
    assert authorization["worst_case_actual_generations"] == 15
    assert authorization["process_errors_count_against_limit"] is False
    assert len(confirmation["accepted_visible_direction"]) == 6
    architecture = sim["architecture"]
    assert architecture["dynamic_content_baked"] is False
    assert architecture["runtime_height"] == 42
    assert "one complete source" in architecture["standard_shell"]
    postprocess = architecture["postprocess"]
    assert postprocess["target_source_bbox"] == [1284, 252]
    assert postprocess["target_runtime"] == [214, 42]
    assert postprocess["maximum_aspect_error_percent"] == 8
    assert postprocess["maximum_anisotropy_percent"] == 8
    assert postprocess["python_may_invent_art"] is False

    runtime = sim["runtime"]
    assert runtime["player"] == {
        "hp": [200, 25],
        "power": [200, 4],
        "shell": [214, 42],
    }
    assert runtime["target"]["shell"] == [214, 42]
    assert runtime["health_texture"] == [64, 32]
    assert runtime["power_texture"] == [64, 16]
    assert [item["unit_power_type"] for item in sim["power_types"]] == [0, 1, 2, 3]
    assert [item["id"] for item in sim["power_types"]] == [
        "mana",
        "rage",
        "focus",
        "energy",
    ]
    assert sim["imagegen_usage"] == "0/0"

    display = json.loads(DISPLAY_SPEC.read_text(encoding="utf-8"))
    assert display["schema"] == "aeui-display-region-contract-v1"
    assert display["nine_slice"]["caps"] == {
        "left": 7,
        "right": 7,
        "top": 6,
        "bottom": 6,
    }
    scenarios = {item["id"]: item for item in display["scenarios"]}
    assert set(scenarios) == {
        "player-mana-standard",
        "player-rage-standard",
        "player-focus-standard",
        "player-energy-standard",
        "target-rage-standard",
        "player-variable-w160",
        "target-variable-w240",
    }
    assert scenarios["player-mana-standard"]["frame"] == [214, 42]
    assert scenarios["player-variable-w160"]["frame"] == [174, 42]
    assert scenarios["target-variable-w240"]["frame"] == [254, 42]

    work = WORK.read_text(encoding="utf-8")
    normalized_work = " ".join(work.split())
    assert "UF-A1 V3-A exhausted / UF-A1 V3-B exhausted / UF-B1 attempt 2 rejected-repairable" in work
    assert "accepted UF-PRIMARY-V3-SIM-V1 / 2026-08-11" in work
    assert "production / authorized / 2026-08-11" in work
    assert "完整性结论：`pass-final`" in work
    assert "正式生产：`authorized / 2026-08-11`" in work
    assert "## 自主修复循环" in work
    assert "Python 不得补画皮革" in work
    assert "UnitPowerType" in work
    assert "Mana／Rage／Focus／Energy" in work
    assert "V1、V2 的逐稿正文" in work
    assert "repair-budget-exhausted / candidate-rejected" in normalized_work
    assert "6355" in work
    assert "one-connected-opening" in work
    assert "1425×224" in work
    assert "90627" in work
    assert "22649" in work
    assert "B1 确定性候选门禁" in work

    player = extract_fenced_body(work, "### `UF-A1 V3-A final`")
    assert_clauses(
        player,
        (
            "exactly one front-facing orthographic horizontal shell",
            "Do not create an atlas, separate caps, multiple outputs",
            "close to 1284 by 252",
            "discarded saddle leather",
            "The Player identity is heavier on the left",
            "preserve Vanilla information density",
            "Let leather carry the structure and keep brass local",
            "Draw no health colour, power colour",
            "Before returning, verify that the image contains exactly one complete Player",
        ),
    )
    player_r1 = extract_fenced_body(work, "### `UF-A1 V3-A final.r1`")
    assert_clauses(
        player_r1,
        (
            "Edit Image 3 into one corrected complete empty Player",
            "two separate green slots and the full-width leather divider",
            "all pixels in the inner rectangle from x 42 through x 1241",
            "Do not preserve Image 3's two-slot anatomy",
            "compress it into the extreme 42-pixel end band",
            "exactly one uninterrupted green opening",
        ),
    )
    player_r2 = extract_fenced_body(work, "### `UF-A1 V3-A final.r2`")
    assert_clauses(
        player_r2,
        (
            "Preserve Image 3's successful single connected physical perimeter",
            "at least the central 1200 by 180 region",
            "remove roughly three quarters of the wide left and right leather plaques",
            "left and right structural bands are only about 7 pixels each",
            "nearly continuous evenly spaced edge stitches",
            "no safe-core intrusion",
        ),
    )
    player_r3 = extract_fenced_body(work, "### `UF-A1 V3-A final.r3`")
    assert_clauses(
        player_r3,
        (
            "Uniformly reduce and recentre the whole object",
            "begins around x 74 instead of x 42",
            "Move only the inner face of the left end outward by about 32 pixels",
            "cutting away roughly another five runtime pixels",
            "Break each long highlight into several unequal matte fragments",
            "no alpha-bearing structure in the hard core",
        ),
    )
    player_r4 = extract_fenced_body(work, "### `UF-A1 V3-A final.r4`")
    assert_clauses(
        player_r4,
        (
            "changes only overall occupancy and the thickness of the two vertical end bands",
            "bbox is 1392 by 281",
            "vertical sides as visually thin as the top and bottom rails",
            "move the left inner edge 29 pixels farther left",
            "Replace the removed end material with uniform pure #00FF00",
            "zero structure in the hard safe core",
        ),
    )
    target = extract_fenced_body(work, "### `UF-A1 V3-B final`")
    assert_clauses(
        target,
        (
            "exactly one front-facing orthographic horizontal shell",
            "Do not copy or mirror a Player candidate",
            "shares the Player shell's expedition-era painted weight",
            "Its right end carries one short damaged oxidized brass",
            "Add no enemy red",
            "Before returning, verify that the image contains exactly one complete Target",
        ),
    )
    target_r1 = extract_fenced_body(work, "### `UF-A1 V3-B final.r1`")
    assert_clauses(
        target_r1,
        (
            "bbox is 1354 by 305",
            "at least 1200 by 180 pixels",
            "Remove most of both broad end blocks",
            "At right, retain one short damaged oxidized-brass compression tab",
            "remove Image 3's bright full-height gold plate",
            "zero hard-safe-core structure",
        ),
    )
    target_r2 = extract_fenced_body(work, "### `UF-A1 V3-B final.r2`")
    assert_clauses(
        target_r2,
        (
            "changes only canvas occupancy and the thickness of the four sides",
            "normalized opening currently begins around x 88",
            "move the left inner edge about 46 pixels left",
            "final opening is at least 1200 by 180",
            "Compress the dark damaged right brass tab",
            "zero hard-core structure",
        ),
    )
    target_r3 = extract_fenced_body(work, "### `UF-A1 V3-B final.r3`")
    assert_clauses(
        target_r3,
        (
            "changes only overall bbox proportion and the two vertical side thicknesses",
            "measures 1380 by 246",
            "reduce total width by about 96 pixels",
            "normalized opening currently spans about x 80..1208",
            "move the left inner edge about 38 pixels left",
            "zero hard safe-core structure",
        ),
    )
    target_r4 = extract_fenced_body(work, "### `UF-A1 V3-B final.r4`")
    assert_clauses(
        target_r4,
        (
            "bounded final repair of the immediately previous Target image only",
            "outer material bbox must be approximately x 126 through 1409",
            "opening must fully cover absolute canvas rectangle x 168 through 1367",
            "hard core x 174 through 1361 and y 428 through 595",
            "Replace its industrial finish",
            "Remove the current repeating pebble embossing",
            "Explicitly discard Image 3's geometry",
            "no industrial repetition",
        ),
    )
    bars = extract_fenced_body(work, "### `UF-B1 V2 final`")
    assert_clauses(
        bars,
        (
            "exactly two separate neutral grayscale StatusBar material swatches",
            "equal red, green and blue channels",
            "Mana, Rage, Focus and Energy colours at runtime",
            "64 by 32 for Health and 64 by 16 for Power",
            "At 100 percent runtime size, preserve the confirmed hierarchy",
            "Mana blue, Rage red, Focus orange-brown and Energy yellow",
            "Before returning, verify exactly two isolated swatches",
        ),
    )
    bars_r1 = extract_fenced_body(work, "### `UF-B1 V2 final.r1`")
    assert_clauses(
        bars_r1,
        (
            "Edit Image 1 into one corrected production sheet",
            "Health material as one connected 512 by 256 rectangle",
            "Power material as one connected 512 by 128 rectangle",
            "Do not preserve Image 1's wrong proportions",
            "Every material pixel is neutral grayscale",
            "Health bbox x256..767/y128..383",
            "Power bbox x256..767/y640..767",
        ),
    )
    bars_r2 = extract_fenced_body(work, "### `UF-B1 V2 final.r2`")
    assert_clauses(
        bars_r2,
        (
            "changes only the Power rectangle height and vertical position",
            "Freeze Image 1's Health swatch exactly",
            "Power swatch",
            "exactly x 180 through 843",
            "y 680 through 845",
            "664 by 166 pixels and exact 4:1 ratio",
            "Preserve Image 1's successful neutral equal-channel grey",
        ),
    )

    submodules = SUBMODULES.read_text(encoding="utf-8")
    assert "UF-A1 V3 完整外壳 source → runtime 合同" in submodules
    assert "纵横比误差不得超过 `8%`" in submodules
    assert "`UnitPowerType` 的 `0/1/2/3`" in submodules
    submodule_art = SUBMODULE_ART.read_text(encoding="utf-8")
    assert "旧马鞍带、盾牌背带或帐篷捆扎皮" in submodule_art
    assert "透明母版归一化为" in submodule_art
    assert "`SetStatusBarColor` 乘色" in submodule_art

    renderer_source = RENDERER.read_text(encoding="utf-8")
    assert "One continuous, hand-cut shell silhouette" in renderer_source
    assert "power_types" in renderer_source
    assert "imagegen__imagegen" not in renderer_source

    reviewer_source = REVIEWER.read_text(encoding="utf-8")
    assert "connected_component_stats" in reviewer_source
    assert "scanline run union-find" in reviewer_source
    assert "one-connected-opening" in reviewer_source
    assert "candidate is emitted only" in reviewer_source
    assert '"may_be_source": False' in reviewer_source

    bars_reviewer_source = BARS_REVIEWER.read_text(encoding="utf-8")
    for clause in (
        "UF-B1 V2 Health/Power material candidates",
        "exactly-two-isolated-swatches",
        "equal-channel luminance conversion after residual-chroma gates",
        "HEALTH_RUNTIME = (64, 32)",
        "POWER_RUNTIME = (64, 16)",
        "candidate donors are emitted only after every objective gate",
        '"may_be_source": False',
        '"may_be_runtime": False',
    ):
        assert clause in bars_reviewer_source, f"B1 reviewer missing: {clause}"

    legacy = json.loads(LEGACY_V2.read_text(encoding="utf-8"))
    assert legacy["status"] == "candidate-rejected / repair-budget-exhausted"
    assert legacy["attempts_used"] == 5
    assert legacy["executor"]["authorized"] is False
    assert legacy["terminal_review"]["may_be_source"] is False
    assert legacy["terminal_review"]["may_be_runtime"] is False

    print("unitframes design contract test passed")


if __name__ == "__main__":
    main()
