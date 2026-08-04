#!/usr/bin/env python3
"""Deterministic CHAT.TABS.DARK.V2 export and final-evidence checks."""

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
TOOL = ROOT / "tools" / "build_chat_tabs_dark_v2_runtime.py"
SOURCE = (
    ROOT
    / "assets"
    / "source"
    / "chat"
    / "tabs-dark-v2"
    / "ChatTabs_Dark_V2_A.png"
)
TAB_RUNTIME = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Chat"
    / "ChatTabAtlasDarkV2.tga"
)
SHELF_RUNTIME = TAB_RUNTIME.with_name("ChatTabShelfDarkV2.tga")
TAB_FALLBACK = TAB_RUNTIME.with_name("ChatTabAtlasV3.tga")
SHELF_FALLBACK = TAB_RUNTIME.with_name("ChatTabShelfV3.tga")
MANIFEST = SOURCE.with_name("ChatTabs_Dark_V2_RuntimeManifest_v1.json")
RENDERER = ROOT / "tools" / "render_chat_tabs_dark_runtime_v2.py"
PREVIEW_SPEC = ROOT / "tools" / "specs" / "chat_tabs_dark_runtime_preview_v2.json"
DISPLAY_CONTRACT = (
    ROOT / "tools" / "specs" / "chat_tabs_dark_runtime_display_region_v2.json"
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
    exporter = load_module("chat_tabs_dark_export", TOOL)
    source = Image.open(SOURCE).convert("RGBA")
    source_cells = exporter.validate_source(SOURCE, source)
    rebuilt_tabs, rebuilt_shelf, cleanup = exporter.build_atlases(source)
    tracked_tabs = Image.open(TAB_RUNTIME).convert("RGBA")
    tracked_shelf = Image.open(SHELF_RUNTIME).convert("RGBA")
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))

    assert source_cells["outside_declared_cells_visible_pixels"] == 0
    assert source_cells["minimum_cell_margin_pixels"] == 6
    assert rebuilt_tabs.size == tracked_tabs.size == (512, 512)
    assert rebuilt_shelf.size == tracked_shelf.size == (1024, 64)
    assert rebuilt_tabs.tobytes() == tracked_tabs.tobytes()
    assert rebuilt_shelf.tobytes() == tracked_shelf.tobytes()

    assert cleanup["source_cleanup"] == {
        "rgb_only_cleared_pixels": 13,
        "affected_alpha_min_max": [1, 6],
        "alpha_difference_pixels": 0,
        "post_cleanup": {
            "exact_green_visible_pixels": 0,
            "visible_green_spill_pixels": 0,
            "transparent_rgb_nonzero_values": 0,
        },
    }
    assert cleanup["state_cleanup"]["hover"][
        "lanczos_green_ringing_cleanup"
    ]["rgb_only_cleared_pixels"] == 11
    assert cleanup["state_cleanup"]["disabled"][
        "lanczos_green_ringing_cleanup"
    ]["rgb_only_cleared_pixels"] == 4
    assert cleanup["shelf_cleanup"]["lanczos_green_ringing_cleanup"] == {
        "rgb_only_cleared_pixels": 8,
        "affected_alpha_min_max": [1, 34],
        "alpha_difference_pixels": 0,
    }

    assert manifest["runtime_contract"] == "1.22"
    assert manifest["status"] == "runtime-exported"
    assert manifest["phase"] == "P5"
    assert manifest["source"]["sha256"] == sha256(SOURCE)
    assert manifest["runtime_exports"]["tabs"]["sha256"] == sha256(TAB_RUNTIME)
    assert manifest["runtime_exports"]["shelf"]["sha256"] == sha256(SHELF_RUNTIME)
    for record in manifest["runtime_exports"].values():
        assert record["visible_green_spill_pixels"] == 0
        assert record["transparent_rgb_nonzero_values"] == 0
    assert manifest["deterministic_export"]["foreign_source_pixels_mixed"] is False
    assert manifest["deterministic_export"]["redraw"] is False
    assert manifest["deterministic_export"]["text_unread_or_behavior_baked"] is False
    assert manifest["deterministic_export"]["tab_atlas_x_pixels"] == [4, 52, 204, 252]
    assert manifest["deterministic_export"]["runtime_caps_lr"] == [16, 16]
    assert manifest["deterministic_export"]["runtime_tab_size"] == [92, 30]
    assert TAB_FALLBACK.is_file() and SHELF_FALLBACK.is_file()

    for state in exporter.STATE_ORDER:
        assembled = exporter.build_runtime_tab(tracked_tabs, state)
        assert assembled.size == (92, 30)
        assert assembled.getchannel("A").getbbox() is not None
    for state in exporter.STATE_ORDER:
        compressed = exporter.build_runtime_tab(tracked_tabs, state, 73)
        assert compressed.size == (73, 30)
        assert compressed.getchannel("A").getbbox() is not None
    assert exporter.build_runtime_shelf(tracked_shelf, 380).size == (380, 16)
    assert exporter.build_runtime_shelf(tracked_shelf, 480).size == (480, 16)

    validator = load_module("aeui_display_region_validator", DISPLAY_VALIDATOR)
    contract = json.loads(DISPLAY_CONTRACT.read_text(encoding="utf-8"))
    report = validator.validate_contract(contract)
    assert report["status"] == "pass"
    assert report["summary"] == {
        "scenario_count": 6,
        "violation_count": 0,
        "first_failure": None,
    }

    with tempfile.TemporaryDirectory(prefix="aeui-chat-tabs-runtime-") as temp:
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
    assert metrics["runtime_contract"] == "1.22"
    assert metrics["inputs"]["tabs"]["sha256"] == sha256(TAB_RUNTIME)
    assert metrics["inputs"]["shelf"]["sha256"] == sha256(SHELF_RUNTIME)
    assert len(metrics["layout"]) == 6
    assert all(item["truncated"] == 0 for item in metrics["layout"].values())
    assert metrics["layout"]["overflow-five-tabs-440"]["tab_width"] == 73

    chat_source = (
        ROOT / "addon" / "AzerothExpeditionUI" / "Modules" / "Chat.lua"
    ).read_text(encoding="utf-8")
    assert 'Chat.runtimeContract = "1.22"' in chat_source
    assert 'tabs = CHAT_MEDIA .. "ChatTabAtlasDarkV2"' in chat_source
    assert 'tabShelf = CHAT_MEDIA .. "ChatTabShelfDarkV2"' in chat_source
    print("chat dark-tabs runtime test passed")


if __name__ == "__main__":
    main()
