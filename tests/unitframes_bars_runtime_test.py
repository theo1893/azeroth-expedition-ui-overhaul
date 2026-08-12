#!/usr/bin/env python3
"""Deterministic P4/P5 checks for accepted UF-B1 V2 bar media."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[1]
EXPORTER = ROOT / "tools/build_unitframes_bars_v2_runtime.py"
SOURCE_DIR = ROOT / "assets/source/unitframes/bars-v2"
HEALTH_SOURCE = SOURCE_DIR / "UnitFrameHealthFill_Master_v1.png"
POWER_SOURCE = SOURCE_DIR / "UnitFramePowerFill_Master_v1.png"
SOURCE_MANIFEST = SOURCE_DIR / "UF-B1-V2_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "UF-B1-V2_RuntimeManifest_v1.json"
HEALTH_RUNTIME = (
    ROOT
    / "addon/AzerothExpeditionUI/Media/UnitFrames/UnitFrameHealthFillV1.tga"
)
POWER_RUNTIME = (
    ROOT
    / "addon/AzerothExpeditionUI/Media/UnitFrames/UnitFramePowerFillV1.tga"
)
DISPLAY_CONTRACT = (
    ROOT / "tools/specs/unitframes_bars_v2_runtime_display_region_v1.json"
)
DISPLAY_VALIDATOR = (
    ROOT
    / ".codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py"
)


def load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    exporter = load_module("aeui_unitframes_bars_exporter", EXPORTER)
    with Image.open(HEALTH_SOURCE) as opened:
        health_source = opened.convert("RGBA")
    with Image.open(POWER_SOURCE) as opened:
        power_source = opened.convert("RGBA")
    exporter.validate_source(
        HEALTH_SOURCE,
        health_source,
        exporter.EXPECTED_HEALTH_SHA256,
        exporter.HEALTH_SOURCE_SIZE,
    )
    exporter.validate_source(
        POWER_SOURCE,
        power_source,
        exporter.EXPECTED_POWER_SHA256,
        exporter.POWER_SOURCE_SIZE,
    )

    expected_health = exporter.build_runtime(
        health_source,
        exporter.HEALTH_RUNTIME_SIZE,
    )
    expected_power = exporter.build_runtime(
        power_source,
        exporter.POWER_RUNTIME_SIZE,
    )
    with Image.open(HEALTH_RUNTIME) as opened:
        tracked_health = opened.convert("RGBA")
    with Image.open(POWER_RUNTIME) as opened:
        tracked_power = opened.convert("RGBA")
    assert tracked_health.size == (64, 32)
    assert tracked_power.size == (64, 16)
    assert ImageChops.difference(expected_health, tracked_health).getbbox() is None
    assert ImageChops.difference(expected_power, tracked_power).getbbox() is None
    assert exporter.unequal_rgb_pixels(tracked_health) == 0
    assert exporter.unequal_rgb_pixels(tracked_power) == 0
    assert exporter.visible_green_pixels(tracked_health) == 0
    assert exporter.visible_green_pixels(tracked_power) == 0
    assert exporter.transparent_rgb_nonzero(tracked_health) == 0
    assert exporter.transparent_rgb_nonzero(tracked_power) == 0

    source_manifest = json.loads(SOURCE_MANIFEST.read_text(encoding="utf-8"))
    runtime_manifest = json.loads(RUNTIME_MANIFEST.read_text(encoding="utf-8"))
    assert source_manifest["status"] == "accepted-source"
    assert source_manifest["accepted_on"] == "2026-08-11"
    assert source_manifest["user_acceptance"]["exact_statement"] == (
        "接受 B1 attempt 3 的运行时视觉"
    )
    assert source_manifest["sources"]["health"]["sha256"] == sha256(HEALTH_SOURCE)
    assert source_manifest["sources"]["power"]["sha256"] == sha256(POWER_SOURCE)
    assert source_manifest["export_contract"]["status"] == "runtime-exported"
    assert runtime_manifest["status"] == "runtime-exported"
    assert runtime_manifest["phase"] == "P5"
    assert runtime_manifest["runtime_contract"] == "1.0"
    assert runtime_manifest["runtime"]["health"]["sha256"] == sha256(HEALTH_RUNTIME)
    assert runtime_manifest["runtime"]["power"]["sha256"] == sha256(POWER_RUNTIME)
    assert runtime_manifest["runtime"]["health"]["metrics"]["equal_channel"] is True
    assert runtime_manifest["runtime"]["power"]["metrics"]["equal_channel"] is True
    assert runtime_manifest["adapter"]["frames"] == [
        "player",
        "target",
        "targettarget",
        "focus",
    ]
    assert runtime_manifest["deployment"]["build_required_on_target_device"] is False
    assert runtime_manifest["deployment"]["game_validation"].endswith("/ P6")

    validator = load_module("aeui_display_region_validator", DISPLAY_VALIDATOR)
    contract = json.loads(DISPLAY_CONTRACT.read_text(encoding="utf-8"))
    report = validator.validate_contract(contract)
    assert report["status"] == "pass"
    assert report["summary"] == {
        "scenario_count": 9,
        "violation_count": 0,
        "first_failure": None,
    }

    unitframes_source = (
        ROOT / "addon/AzerothExpeditionUI/Modules/UnitFrames.lua"
    ).read_text(encoding="utf-8")
    assert 'UnitFrames.runtimeContract = "1.2"' in unitframes_source
    assert "frame.aeuiHealthBarTexture = HEALTH_TEXTURE" in unitframes_source
    assert "frame.aeuiPowerBarTexture = POWER_TEXTURE" in unitframes_source
    assert '"player"' in unitframes_source
    assert '"targettarget"' in unitframes_source
    assert '"focus"' in unitframes_source
    assert '"raid"' not in unitframes_source.split(
        "local PRIMARY_FRAME_KEYS", 1
    )[1].split("}", 1)[0]

    bridge = (ROOT / "addon/pfUI/api/unitframes.lua").read_text(encoding="utf-8")
    assert (
        "f.aeuiHealthBarTexture or pfUI.media[f.config.bartexture]"
        in bridge
    )
    assert (
        "f.aeuiPowerBarTexture or pfUI.media[f.config.pbartexture]"
        in bridge
    )
    assert "ApplyExpeditionPortraitGuard" in bridge
    assert "unit.aeuiPortraitDisabled" in bridge
    assert "unit.portrait:Hide()" in bridge
    assert "unit.portrait.model.update = nil" in bridge
    raidmarkers = (
        ROOT / "addon/pfUI/modules/raidmarkers.lua"
    ).read_text(encoding="utf-8")
    marktracking = (
        ROOT / "addon/pfUI/modules/marktracking.lua"
    ).read_text(encoding="utf-8")
    assert "function pfUI.raidmarkers:SetPortraitsEnabled" in raidmarkers
    assert "function pfUI.marktracking:SetPortraitsEnabled" in marktracking
    toc = (
        ROOT / "addon/AzerothExpeditionUI/AzerothExpeditionUI.toc"
    ).read_text(encoding="utf-8")
    assert "Modules\\UnitFrames.lua" in toc

    result = subprocess.run(
        [
            "lua",
            str(ROOT / "tests/unitframes_module_smoke.lua"),
            str(ROOT),
        ],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    assert "unitframes module smoke test passed" in result.stdout
    print("unitframes bars runtime test passed")


if __name__ == "__main__":
    main()
