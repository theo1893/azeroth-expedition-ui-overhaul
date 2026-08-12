#!/usr/bin/env python3
"""Verify the exact P4 Player/Target source promotion and P5 boundary."""

from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageOps


ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))

from build_unitframes_primary_v4_candidates_v1 import (  # noqa: E402
    build_candidates,
    load_materials,
)


SOURCE_DIR = ROOT / "assets/source/unitframes/primary-v4"
MANIFEST_PATH = SOURCE_DIR / "UF-PRIMARY-V4_SourceManifest_v1.json"
SPEC_PATH = ROOT / "tools/specs/unitframes_primary_v4_candidate_v1.json"
PROMOTER_PATH = ROOT / "tools/promote_unitframes_primary_v4_source_v1.py"
ADAPTER_PATH = ROOT / "addon/AzerothExpeditionUI/Modules/UnitFrames.lua"
EXPECTED_SOURCE_SHAS = {
    "player": "331b353f294ae2e658e010ea59763a48bb08ba574b88e150fe3f5a2416bd617b",
    "target": "256086c128561fdfa0717740701581d156ab811d88282c0098f9d3b4595acf81",
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def alpha_counts(image: Image.Image) -> tuple[int, int, int]:
    histogram = image.getchannel("A").histogram()
    return histogram[0], sum(histogram[1:255]), histogram[255]


def main() -> None:
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    spec = json.loads(SPEC_PATH.read_text(encoding="utf-8"))

    assert manifest["schema"] == "aeui-unitframes-primary-v4-source-manifest-v1"
    assert manifest["status"] == "accepted-source"
    assert manifest["phase"] == "P4"
    assert manifest["components"] == ["UF.PLAYER.SHELL", "UF.TARGET.SHELL"]
    acceptance = manifest["user_acceptance"]
    assert acceptance["exact_statement"] == "确认, 进入下一阶段"
    assert acceptance["accepts_exact_candidate_pixels"] is True
    assert acceptance["authorizes_p4_source_promotion"] is True
    assert acceptance["authorizes_p5_runtime_export"] is False
    assert acceptance["authorizes_addon_integration"] is False

    # The P3 candidate contract remains immutable historical provenance.  The
    # later P4 authority lives in this source manifest, not by rewriting P3.
    assert spec["phase"] == "P3"
    assert spec["authorization"]["authorizes_source_promotion"] is False
    assert sha256(SPEC_PATH) == manifest["provenance"]["candidate_spec_sha256"]
    assert PROMOTER_PATH.is_file()

    rebuilt = build_candidates(spec, load_materials(spec))
    accepted: dict[str, Image.Image] = {}
    for role in ("player", "target"):
        record = manifest["sources"][role]
        assert record["sha256"] == EXPECTED_SOURCE_SHAS[role]
        path = ROOT / record["repository_path"]
        assert path.is_file()
        assert path.parent == SOURCE_DIR
        assert sha256(path) == record["sha256"]
        with Image.open(path) as opened:
            image = opened.convert("RGBA")
        accepted[role] = image
        assert image.mode == record["mode"] == "RGBA"
        assert image.size == (record["width"], record["height"]) == (1284, 252)
        assert list(image.getbbox()) == record["visible_bbox_exclusive"]
        assert hashlib.sha256(image.tobytes()).hexdigest() == record["pixel_sha256"]
        assert alpha_counts(image) == (
            record["transparent_pixels"],
            record["partially_transparent_pixels"],
            record["opaque_pixels"],
        )
        assert record["visible_green_spill_pixels"] == 0
        assert record["transparent_rgb_nonzero_pixels"] == 0
        assert record["outside_outer_alpha_pixels"] == 0
        assert record["perimeter_relief_intrusion_pixels"] == 0
        assert record["identity_repair_intrusion_pixels"] == 0
        assert record["live_bed_liner_coverage_ratio"] == 1.0
        assert ImageChops.difference(image, rebuilt.sources[role]).getbbox() is None

    assert ImageChops.difference(accepted["player"], accepted["target"]).getbbox()
    assert ImageChops.difference(
        accepted["player"], ImageOps.mirror(accepted["target"])
    ).getbbox()

    export = manifest["export_contract"]
    assert export["status"] == "not-exported"
    assert export["phase"] == "P5-pending-separate-gate"
    assert export["runtime_media_written"] is False
    assert export["addon_code_modified"] is False
    adapter = ADAPTER_PATH.read_text(encoding="utf-8")
    assert "UnitFramePlayerShellV1" not in adapter
    assert "UnitFrameTargetShellV1" not in adapter

    print("unitframes primary V4 source test passed")


if __name__ == "__main__":
    main()
