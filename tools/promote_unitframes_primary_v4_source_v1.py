#!/usr/bin/env python3
"""Promote the accepted UF-PRIMARY V4 candidates to exact P4 PNG masters.

The ignored P3 candidate directory is optional.  The accepted pixels are
rebuilt from the immutable contract inputs, encoded with the same PNG settings,
and checked against the SHA-bound P4 manifest before either source is written.
This tool never exports runtime media and never writes into addon/.
"""

from __future__ import annotations

import hashlib
import io
import json
import sys
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))

from build_unitframes_primary_v4_candidates_v1 import (  # noqa: E402
    build_candidates,
    load_materials,
)


SPEC_PATH = ROOT / "tools/specs/unitframes_primary_v4_candidate_v1.json"
MANIFEST_PATH = (
    ROOT
    / "assets/source/unitframes/primary-v4/UF-PRIMARY-V4_SourceManifest_v1.json"
)


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_path(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def encode_png(image: Image.Image) -> bytes:
    stream = io.BytesIO()
    image.save(stream, format="PNG", compress_level=9)
    return stream.getvalue()


def alpha_counts(image: Image.Image) -> tuple[int, int, int]:
    histogram = image.getchannel("A").histogram()
    transparent = histogram[0]
    opaque = histogram[255]
    partial = sum(histogram[1:255])
    return transparent, partial, opaque


def main() -> None:
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    spec = json.loads(SPEC_PATH.read_text(encoding="utf-8"))

    assert manifest["status"] == "accepted-source"
    assert manifest["phase"] == "P4"
    acceptance = manifest["user_acceptance"]
    assert acceptance["accepts_exact_candidate_pixels"] is True
    assert acceptance["authorizes_p4_source_promotion"] is True
    assert acceptance["authorizes_p5_runtime_export"] is False
    assert acceptance["authorizes_addon_integration"] is False
    assert sha256_path(SPEC_PATH) == manifest["provenance"]["candidate_spec_sha256"]

    candidates = build_candidates(spec, load_materials(spec))
    payloads: dict[Path, bytes] = {}

    for role in ("player", "target"):
        record = manifest["sources"][role]
        image = candidates.sources[role].convert("RGBA")
        assert list(image.size) == [record["width"], record["height"]]
        assert image.mode == record["mode"]
        assert list(image.getbbox()) == record["visible_bbox_exclusive"]
        assert hashlib.sha256(image.tobytes()).hexdigest() == record["pixel_sha256"]

        transparent, partial, opaque = alpha_counts(image)
        assert transparent == record["transparent_pixels"]
        assert partial == record["partially_transparent_pixels"]
        assert opaque == record["opaque_pixels"]

        payload = encode_png(image)
        actual_sha = sha256_bytes(payload)
        if actual_sha != record["sha256"]:
            raise RuntimeError(
                f"{role} accepted PNG SHA mismatch: {actual_sha} != {record['sha256']}"
            )

        candidate_path = ROOT / record["accepted_candidate"]
        if candidate_path.is_file():
            if sha256_path(candidate_path) != record["sha256"]:
                raise RuntimeError(f"{role} ignored candidate no longer matches acceptance")
            with Image.open(candidate_path) as opened:
                candidate = opened.convert("RGBA")
            if ImageChops.difference(candidate, image).getbbox() is not None:
                raise RuntimeError(f"{role} rebuilt pixels differ from accepted candidate")

        destination = ROOT / record["repository_path"]
        payloads[destination] = payload

    # Both payloads are validated before either tracked source is touched.
    for destination, payload in payloads.items():
        destination.parent.mkdir(parents=True, exist_ok=True)
        if destination.is_file() and destination.read_bytes() == payload:
            continue
        destination.write_bytes(payload)

    summary = {
        "schema": "aeui-unitframes-primary-v4-source-promotion-report-v1",
        "status": "pass",
        "phase": "P4",
        "sources": {
            role: manifest["sources"][role]["sha256"]
            for role in ("player", "target")
        },
        "runtime_exported": False,
        "addon_modified": False,
    }
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
