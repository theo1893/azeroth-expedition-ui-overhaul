#!/usr/bin/env python3
"""Deterministic P5 runtime and provider-bridge checks for Field Kit V1."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
BUILDER_PATH = ROOT / "tools/build_action_fieldkit_v1_runtime.py"
VALIDATOR = (
    ROOT
    / ".codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py"
)


def load_builder():
    sys.path.insert(0, str(ROOT / "tools"))
    spec = importlib.util.spec_from_file_location("fieldkit_builder", BUILDER_PATH)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    builder = load_builder()
    adapter_path = ROOT / builder.ADAPTER_REL
    adapter = adapter_path.read_text(encoding="utf-8")
    adapter_sha = sha256(adapter_path)

    expected_scenarios = {"trinket": 9, "consumable": 7}
    for key, case in builder.CASES.items():
        source = builder.validate_source(ROOT / case["source"], case)
        rebuilt, layout, sprites = builder.build_runtime(source, case)
        assert builder.pixel_sha256(rebuilt) == (
            case["expected_runtime_pixel_sha256"]
        )
        assert builder.visible_green_spill_pixels(rebuilt) == 0
        assert builder.transparent_rgb_nonzero_values(rebuilt) == 0
        assert sprites["D_VERTICAL"].tobytes() == sprites["D"].transpose(
            Image.Transpose.ROTATE_90
        ).tobytes()

        runtime_path = ROOT / case["runtime"]
        header = runtime_path.read_bytes()[:18]
        assert len(header) == 18
        assert header[16] == 32
        with Image.open(runtime_path) as opened:
            runtime = opened.convert("RGBA")
        assert runtime.size == builder.ATLAS_SIZE
        assert runtime.tobytes() == rebuilt.tobytes()

        manifest = json.loads(
            (ROOT / case["runtime_manifest"]).read_text(encoding="utf-8")
        )
        assert manifest["runtime_contract"] == "1.0"
        assert manifest["status"] == "runtime-exported"
        assert manifest["phase"] == "P5"
        assert manifest["runtime_export"]["sha256"] == sha256(runtime_path)
        assert manifest["runtime_export"]["pixel_sha256"] == (
            case["expected_runtime_pixel_sha256"]
        )
        assert manifest["transform"]["runtime_layout"] == layout
        assert manifest["adapter"]["sha256"] == adapter_sha
        assert manifest["adapter"]["visual_layers_only"] is True
        assert manifest["adapter"]["provider_geometry_writes"] is False
        assert manifest["adapter"]["provider_behavior_replaced"] is False
        assert manifest["adapter"]["saved_variables_written"] is False
        assert manifest["adapter"]["autobar_enabled_or_profile_applied"] is False
        assert manifest["package_validation"]["status"] == "pass"
        assert manifest["package_validation"]["violations"] == 0
        assert manifest["package_validation"][
            "build_required_on_target_device"
        ] is False

        contract_path = ROOT / case["display_contract"]
        contract = json.loads(contract_path.read_text(encoding="utf-8"))
        assert len(contract["atlas"]["sampled_regions"]) == 17
        assert len(contract["scenarios"]) == expected_scenarios[key]
        with tempfile.TemporaryDirectory() as temporary:
            report = Path(temporary) / "display-region-report.json"
            subprocess.run(
                [
                    sys.executable,
                    str(VALIDATOR),
                    str(contract_path),
                    "--report",
                    str(report),
                ],
                cwd=ROOT,
                check=True,
            )
            result = json.loads(report.read_text(encoding="utf-8"))
        assert result["status"] == "pass"
        assert result["summary"]["scenario_count"] == expected_scenarios[key]
        assert result["summary"]["violation_count"] == 0

    for required in (
        'ActionBars.fieldKitRuntimeContract = "1.0"',
        "ActionTrinketKitV1",
        "ActionConsumableKitV1",
        "ApplyAutoBarFieldKit",
        "ApplyAutoBarPopup",
        "ApplyTrinketFieldKit",
        "InstallFieldKitHooks",
        'hooksecurefunc("AutoBar_SetupVisual"',
        'hooksecurefunc(AutoBar, "ButtonsUpdate"',
        'hooksecurefunc(AutoBar, "UpdatePopupButtons"',
        'hooksecurefunc(TrinketMenu, "OrientWindows"',
        'hooksecurefunc(TrinketMenu, "BuildMenu"',
        "AutoBarProfileMatches",
        'local names = { "应急", "增益", "工具" }',
    ):
        assert required in adapter

    for forbidden in (
        r"AutoBar\.display\.[A-Za-z_]+\s*=",
        r"AutoBar\.buttons\s*=",
        r"AutoBar\.buttons\[[^\]]+\]\s*=",
        r"TrinketMenuOptions\.[A-Za-z_]+\s*=",
        r"TrinketMenuPerOptions\.[A-Za-z_]+\s*=",
        r"TrinketMenuQueue\.[A-Za-z_]+\s*=",
        r"\bbutton:SetParent\(",
        r"\bbutton:SetPoint\(",
        r"\bbutton:SetWidth\(",
        r"\bbutton:SetHeight\(",
        r"\bbutton:SetScript\(",
    ):
        assert re.search(forbidden, adapter) is None

    assert "LoadAddOn(" not in adapter
    assert "AutoBar_SetupVisual()" not in adapter
    assert "TrinketMenu.OrientWindows()" not in adapter
    assert "TrinketMenu.BuildMenu()" not in adapter
    print("action field kit runtime test passed")


if __name__ == "__main__":
    main()
