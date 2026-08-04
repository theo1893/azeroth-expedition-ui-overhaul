#!/usr/bin/env python3
"""Derive a deterministic candidate-self alpha matte for Chat tab sheets."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image

from review_chat_input_dark_candidate_v1 import derive_candidate_rgba


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("raw", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--metrics", type=Path, required=True)
    parser.add_argument(
        "--reject-border-outliers",
        action="store_true",
        help="Ignore a contaminated lowest 1%% of border scores when the gap exceeds 64.",
    )
    args = parser.parse_args()

    raw_path = args.raw.resolve()
    output_path = args.output.resolve()
    metrics_path = args.metrics.resolve()
    raw = Image.open(raw_path).convert("RGB")
    if raw.size != (1536, 1024):
        raise ValueError(f"candidate must be 1536x1024, got {raw.size}")

    keyed, matte = derive_candidate_rgba(
        raw, reject_border_outliers=args.reject_border_outliers
    )
    output_path.parent.mkdir(parents=True, exist_ok=True)
    metrics_path.parent.mkdir(parents=True, exist_ok=True)
    keyed.save(output_path, format="PNG", optimize=False, compress_level=9)
    report = {
        "schema": "aeui-chat-tabs-candidate-key-v1",
        "pixel_source": "candidate-self only",
        "raw": {
            "path": str(raw_path),
            "sha256": sha256(raw_path),
            "size": list(raw.size),
            "mode": raw.mode,
        },
        "keyed": {
            "path": str(output_path),
            "sha256": sha256(output_path),
            "size": list(keyed.size),
            "mode": keyed.mode,
        },
        "matte": matte,
    }
    metrics_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(output_path)
    print(metrics_path)


if __name__ == "__main__":
    main()
