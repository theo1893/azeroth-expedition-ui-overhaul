#!/usr/bin/env python3
"""Deterministic CHAT.INPUT.DARK.V1 export and final-evidence checks."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools" / "build_chat_input_dark_v1_runtime.py"
SOURCE = (
    ROOT
    / "assets"
    / "source"
    / "chat"
    / "input-dark-v1"
    / "ChatInput_Dark_V1_r3.png"
)
RUNTIME = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Chat"
    / "ChatInputDarkV1.tga"
)
FALLBACK = RUNTIME.with_name("ChatInputAtlasV3.tga")
MANIFEST = SOURCE.with_name("ChatInput_Dark_V1_RuntimeManifest_v1.json")
RENDERER = ROOT / "tools" / "render_chat_input_dark_runtime_v1.py"
PREVIEW_SPEC = ROOT / "tools" / "specs" / "chat_input_dark_runtime_preview_v1.json"
DISPLAY_CONTRACT = (
    ROOT / "tools" / "specs" / "chat_input_dark_runtime_display_region_v1.json"
)
DISPLAY_VALIDATOR = (
    ROOT
    / ".codex"
    / "skills"
    / "run-aeui-asset-workflow"
    / "scripts"
    / "validate_display_regions.py"
)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main() -> None:
    exporter = load_module("chat_input_dark_export", TOOL)
    source = Image.open(SOURCE).convert("RGBA")
    exporter.validate_source(SOURCE, source)
    rebuilt, cleanup = exporter.build_atlas(source)
    tracked = Image.open(RUNTIME).convert("RGBA")
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))

    assert rebuilt.size == tracked.size == (1024, 256)
    assert rebuilt.mode == tracked.mode == "RGBA"
    assert rebuilt.tobytes() == tracked.tobytes()
    assert cleanup["pre_intersection_alpha_difference_pixels"] == 0
    assert cleanup["normal_focus_alpha_equal"] is True
    assert cleanup["shared_alpha_bbox_local"] == [13, 5, 995, 115]
    assert cleanup["state_cleanup"]["normal"]["visible_green_pixels_capped"] == 119
    assert cleanup["state_cleanup"]["focus"]["visible_green_pixels_capped"] == 98

    assert manifest["runtime_contract"] == "1.20"
    assert manifest["status"] == "runtime-exported"
    assert manifest["phase"] == "P5"
    assert manifest["source"]["sha256"] == sha256(SOURCE)
    assert manifest["runtime_export"]["sha256"] == sha256(RUNTIME)
    assert manifest["runtime_export"]["visible_green_spill_pixels"] == 0
    assert manifest["runtime_export"]["transparent_rgb_nonzero_values"] == 0
    assert manifest["deterministic_export"]["foreign_source_pixels_mixed"] is False
    assert manifest["deterministic_export"]["text_or_behavior_baked"] is False
    assert manifest["deterministic_export"]["atlas_x_pixels"] == [8, 121, 932, 1016]
    assert manifest["deterministic_export"]["runtime_caps_lr"] == [28, 20]
    assert manifest["deterministic_export"]["text_insets_lrtb"] == [34, 22, 0, 0]
    assert manifest["adapter"]["texture_instances"] == 3
    assert FALLBACK.is_file()

    normal_alpha = tracked.crop((8, 4, 1016, 124)).getchannel("A")
    focus_alpha = tracked.crop((8, 132, 1016, 252)).getchannel("A")
    assert normal_alpha.tobytes() == focus_alpha.tobytes()
    for state, width in (("normal", 380), ("focus", 380), ("focus", 480)):
        assembled = exporter.build_input(tracked, state, width)
        assert assembled.size == (width, 25)
        assert assembled.getchannel("A").getbbox() is not None

    validator = load_module("aeui_display_region_validator", DISPLAY_VALIDATOR)
    contract = json.loads(DISPLAY_CONTRACT.read_text(encoding="utf-8"))
    report = validator.validate_contract(contract)
    assert report["status"] == "pass"
    assert report["summary"] == {
        "scenario_count": 5,
        "violation_count": 0,
        "first_failure": None,
    }
    with tempfile.TemporaryDirectory(prefix="aeui-chat-input-runtime-") as temp:
        output = Path(temp) / "real-layout.png"
        metrics_path = Path(temp) / "real-layout.metrics.json"
        subprocess.run(
            [
                sys.executable,
                str(RENDERER),
                str(PREVIEW_SPEC),
                "--output",
                str(output),
                "--metrics",
                str(metrics_path),
            ],
            check=True,
            cwd=ROOT,
            capture_output=True,
            text=True,
        )
        assert output.is_file()
        metrics = json.loads(metrics_path.read_text(encoding="utf-8"))
    assert metrics["runtime_contract"] == "1.20"
    assert metrics["inputs"]["input"]["sha256"] == sha256(RUNTIME)
    assert metrics["contract"] == {
        "atlas_x_pixels": [8, 121, 932, 1016],
        "runtime_caps": [28, 20],
        "runtime_height": 25,
        "text_insets": [34, 22, 0, 0],
        "normal_focus_alpha_equal": True,
    }
    assert len(metrics["layout"]) == 5
    assert all(
        scenario["truncated"] == 0 for scenario in metrics["layout"].values()
    )

    chat_source = (
        ROOT / "addon" / "AzerothExpeditionUI" / "Modules" / "Chat.lua"
    ).read_text(encoding="utf-8")
    assert 'Chat.runtimeContract = "1.21"' in chat_source
    assert 'input = CHAT_MEDIA .. "ChatInputDarkV1"' in chat_source
    assert "ChatInputAtlasV3" not in chat_source
    print("chat dark-input runtime test passed")


if __name__ == "__main__":
    main()
