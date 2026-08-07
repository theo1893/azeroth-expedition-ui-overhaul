#!/usr/bin/env python3
"""Promote the user-selected QL-D V3 attempt 4 canonical candidate.

The generation directory is intentionally ignored by Git.  This one-time
promotion validates the exact reviewed bytes before copying them into the
tracked P4 source inventory.  Once the tracked source exists with the frozen
SHA, the script is idempotent and does not require the ignored candidate.
"""

from __future__ import annotations

import hashlib
import shutil
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
CANDIDATE = (
    ROOT
    / "generated"
    / "quests"
    / "ql-d-reward-slots"
    / "production"
    / "V3"
    / "attempt-04"
    / "review"
    / "ql-d-v3-attempt-04.canonical-review.png"
)
SOURCE = (
    ROOT
    / "assets"
    / "source"
    / "quests"
    / "ql-d"
    / "QuestLogRewardSlot_Master_v1.png"
)
EXPECTED_SHA256 = (
    "816aeedd3ea8a890b5d6d39da2ce10771509afadfcfa92025024b736384347c5"
)
EXPECTED_SIZE = (1080, 410)
EXPECTED_MODE = "RGBA"
EXPECTED_VISIBLE_BBOX = (20, 16, 1060, 392)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate(path: Path) -> None:
    if sha256(path) != EXPECTED_SHA256:
        raise ValueError(f"unexpected QL-D source bytes: {path}")
    with Image.open(path) as image:
        if image.size != EXPECTED_SIZE or image.mode != EXPECTED_MODE:
            raise ValueError(
                f"QL-D source must be {EXPECTED_SIZE} {EXPECTED_MODE}, "
                f"got {image.size} {image.mode}"
            )
        if image.getchannel("A").getbbox() != EXPECTED_VISIBLE_BBOX:
            raise ValueError("QL-D source visible bbox changed")
        red, green, blue, alpha = image.convert("RGBA").split()
        visible_green = 0
        transparent_rgb = 0
        for r, g, b, a in zip(
            red.getdata(), green.getdata(), blue.getdata(), alpha.getdata()
        ):
            if a and r <= 32 and g >= 224 and b <= 32:
                visible_green += 1
            if not a and (r or g or b):
                transparent_rgb += 1
        if visible_green or transparent_rgb:
            raise ValueError(
                "QL-D source contains visible green or non-zero transparent RGB"
            )


def main() -> None:
    if SOURCE.is_file():
        validate(SOURCE)
        print(f"already promoted: {SOURCE.relative_to(ROOT)}")
        return
    if not CANDIDATE.is_file():
        raise FileNotFoundError(
            "ignored attempt-04 canonical candidate is unavailable and the "
            "tracked source does not exist"
        )
    validate(CANDIDATE)
    SOURCE.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(CANDIDATE, SOURCE)
    validate(SOURCE)
    print(f"promoted: {SOURCE.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
