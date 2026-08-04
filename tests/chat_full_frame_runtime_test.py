#!/usr/bin/env python3
"""Deterministic CHAT.FRAME.FULL.V1 export and evidence checks."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools" / "build_chat_full_frame_v1_runtime.py"
SOURCE = (
    ROOT
    / "assets"
    / "source"
    / "chat"
    / "frame-full-v1"
    / "ChatBookFrame_Full_V1_r1.png"
)
RUNTIME = (
    ROOT
    / "addon"
    / "AzerothExpeditionUI"
    / "Media"
    / "Chat"
    / "ChatBookFrameFullV1.tga"
)
MANIFEST = SOURCE.with_name("ChatBookFrame_Full_V1_RuntimeManifest_v1.json")
REPORT = (
    ROOT
    / "generated"
    / "chat"
    / "core"
    / "CHAT.FRAME.FULL.V1"
    / "runtime-v1"
    / "ChatFullFrame_runtime_display-region-report.json"
)
METRICS = REPORT.with_name(
    "ChatFullFrame_runtime_real_layout_v1.metrics.json"
)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_exporter():
    spec = importlib.util.spec_from_file_location("chat_full_frame_export", TOOL)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main() -> None:
    exporter = load_exporter()
    source = Image.open(SOURCE).convert("RGBA")
    exporter.validate_source(SOURCE, source)
    rebuilt, cleanup = exporter.build_atlas(source)
    tracked = Image.open(RUNTIME).convert("RGBA")
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))

    assert cleanup == {
        "cleared_pixel_count": 50,
        "highest_affected_alpha": 13,
        "alpha_limit": 16,
    }
    assert rebuilt.size == tracked.size == (1024, 1024)
    assert rebuilt.mode == tracked.mode == "RGBA"
    assert rebuilt.tobytes() == tracked.tobytes()
    assert sha256(RUNTIME) == manifest["runtime_export"]["sha256"]
    assert manifest["runtime_contract"] == "1.19"
    assert manifest["deterministic_export"][
        "foreign_source_pixels_mixed"
    ] is False
    assert manifest["deterministic_export"][
        "low_alpha_ringing_cleanup"
    ] == cleanup
    assert manifest["runtime_export"]["visible_bbox_exclusive"] == [
        14,
        14,
        1010,
        608,
    ]
    assert manifest["runtime_export"]["pure_green_visible_pixels"] == 0
    assert manifest["runtime_export"]["visible_green_spill_pixels"] == 0

    for size in ((440, 320), (540, 420)):
        frame = exporter.build_frame(tracked, size)
        assert frame.size == size
        assert frame.mode == "RGBA"
        assert frame.getchannel("A").getbbox() is not None

    report = json.loads(REPORT.read_text(encoding="utf-8"))
    assert report["status"] == "pass"
    assert report["summary"] == {
        "scenario_count": 5,
        "violation_count": 0,
        "first_failure": None,
    }
    metrics = json.loads(METRICS.read_text(encoding="utf-8"))
    assert metrics["runtime_contract"] == "1.19"
    assert metrics["inputs"]["frame"]["sha256"] == sha256(RUNTIME)
    assert len(metrics["layout"]) == 5
    print("chat full-frame runtime test passed")


if __name__ == "__main__":
    main()
