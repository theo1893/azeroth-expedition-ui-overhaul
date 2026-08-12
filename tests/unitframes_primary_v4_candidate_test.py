#!/usr/bin/env python3
"""Deterministic contract checks for UF-PRIMARY-V4-CANDIDATE-V1."""

from __future__ import annotations

import json
import sys
from pathlib import Path

from PIL import ImageChops, ImageOps


ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))

from build_unitframes_primary_v4_candidates_v1 import (  # noqa: E402
    build_candidates,
    load_materials,
    sha256,
)


SPEC_PATH = ROOT / "tools/specs/unitframes_primary_v4_candidate_v1.json"
DISPLAY_PATH = ROOT / "tools/specs/unitframes_primary_v4_candidate_display_region_v1.json"
SIMULATION_PATH = ROOT / "tools/specs/unitframes_primary_v4_simulation_v1.json"
BUILDER_PATH = ROOT / "tools/build_unitframes_primary_v4_candidates_v1.py"
REVIEWER_PATH = ROOT / "tools/review_unitframes_primary_v4_candidates_v1.py"
WORK_PATH = ROOT / "docs/modules/unitframes/work/UNITFRAMES.CORE.md"
PROGRESS_PATH = ROOT / "docs/modules/unitframes/PROGRESS.md"


def nonzero(mask) -> int:
    return sum(mask.convert("L").histogram()[1:])


def main() -> None:
    spec = json.loads(SPEC_PATH.read_text(encoding="utf-8"))
    simulation = json.loads(SIMULATION_PATH.read_text(encoding="utf-8"))
    display = json.loads(DISPLAY_PATH.read_text(encoding="utf-8"))
    assert spec["schema"] == "aeui-unitframes-primary-v4-candidate-v1"
    assert spec["version"] == "UF-PRIMARY-V4-CANDIDATE-V1"
    assert spec["phase"] == "P3"
    assert simulation["status"] == "simulation-confirmed"
    assert spec["authorization"]["authorizes_exact_candidate_construction"] is True
    assert spec["authorization"]["authorizes_imagegen"] is False
    assert spec["authorization"]["authorizes_source_promotion"] is False
    assert spec["authorization"]["authorizes_addon_integration"] is False

    assert spec["geometry"]["source"] == [1284, 252]
    assert spec["geometry"]["runtime"] == [214, 42]
    assert spec["geometry"]["live_content_bed_source"] == [42, 36, 1242, 216]
    assert spec["geometry"]["source_three_slice"] == [192, 900, 192]
    assert spec["geometry"]["runtime_three_slice"] == [32, 150, 32]
    assert spec["geometry"]["standard_width_uses_one_complete_texture"] is True
    assert spec["geometry"]["independent_vertical_stretching"] is False
    assert spec["construction"]["imagegen_calls"] == 0

    for group in ("materials", "bars"):
        for contract in spec["inputs"][group].values():
            assert sha256(ROOT / contract["file"]) == contract["sha256"]

    candidates = build_candidates(spec, load_materials(spec))
    bed = candidates.masks["player"]["bed"]
    for role in ("player", "target"):
        assert candidates.sources[role].size == (1284, 252)
        assert candidates.sources[role].mode == "RGBA"
        assert candidates.runtimes[role].size == (214, 42)
        assert candidates.runtimes[role].mode == "RGBA"
        assert nonzero(
            ImageChops.multiply(candidates.masks[role]["rim"], bed)
        ) == 0
        for mask_id, mask in candidates.masks[role].items():
            if mask_id.startswith("repair_"):
                assert nonzero(ImageChops.multiply(mask, bed)) == 0

    assert ImageChops.difference(
        candidates.sources["player"], candidates.sources["target"]
    ).getbbox() is not None
    assert ImageChops.difference(
        candidates.sources["player"], ImageOps.mirror(candidates.sources["target"])
    ).getbbox() is not None
    assert candidates.masks["player"]["repair_brass"].getbbox()[2] <= 192
    assert candidates.masks["player"]["repair_thread"].getbbox()[2] <= 192
    assert candidates.masks["player"]["repair_rivet"].getbbox()[0] >= 1092
    assert candidates.masks["target"]["repair_fold"].getbbox()[2] <= 192
    assert candidates.masks["target"]["repair_brass"].getbbox()[0] >= 1092
    assert candidates.masks["target"]["repair_split"].getbbox()[0] >= 1092

    assert display["schema"] == "aeui-display-region-contract-v1"
    assert len(display["scenarios"]) == 10
    assert display["nine_slice"]["caps"] == {
        "left": 32, "right": 32, "top": 6, "bottom": 6
    }
    builder = BUILDER_PATH.read_text(encoding="utf-8")
    reviewer = REVIEWER_PATH.read_text(encoding="utf-8")
    assert "imagegen__imagegen" not in builder
    assert 'ROOT / "assets/source' not in builder
    assert 'ROOT / "addon/AzerothExpeditionUI/Media/UnitFrames' not in builder
    assert "render_real_layout_review" in reviewer
    assert "validate_display_regions.py" in reviewer

    work = WORK_PATH.read_text(encoding="utf-8")
    progress = PROGRESS_PATH.read_text(encoding="utf-8")
    for clause in (
        "UF-PRIMARY-V4-CANDIDATE-V1",
        "candidate-reviewed / user-acceptance-pending",
        "ImageGen `0/0`",
        "10/10 pass",
        "pixels 前不得",
    ):
        assert clause in work or clause in progress, clause

    print("unitframes primary V4 candidate test passed")


if __name__ == "__main__":
    main()
