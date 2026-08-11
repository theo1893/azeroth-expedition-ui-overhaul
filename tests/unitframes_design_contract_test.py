#!/usr/bin/env python3
"""Static contract checks for the active Unit Frames production draft."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / "docs/modules/unitframes/work/UNITFRAMES.CORE.md"
SPEC = ROOT / "tools/specs/unitframes_a1_v2a_production_v2.json"


def extract_fenced_body(source: str, heading: str) -> str:
    after = source.split(heading, 1)[1]
    opening = after.index("```text") + len("```text")
    closing = after.index("```", opening)
    return after[opening:closing]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    spec = json.loads(SPEC.read_text(encoding="utf-8"))
    assert spec["schema"] == "aeui-unitframes-a1-v2a-production-v2"
    assert spec["status"] == "prompt-authorized"
    assert spec["authorized_on"] == "2026-08-11"
    assert spec["executor"]["authorized"] is True
    assert spec["attempts_used"] == 0
    assert spec["attempt_limit"] == 5
    assert spec["prior_version"]["attempts_used"] == 5
    assert spec["prior_version"]["may_be_edit_or_reference_input"] is False
    for expected_number, reference in enumerate(spec["fixed_references"], start=1):
        assert reference["image"] == expected_number
        assert sha256(ROOT / reference["path"]) == reference["sha256"]

    generation = spec["generation_unit"]
    assert generation["calls_per_attempt"] == 1
    assert generation["outputs_per_attempt"] == 1
    assert generation["canvas"] == [1536, 1024]
    assert generation["single_sheet"] is True
    assert generation["contains_all_roles"] is True
    assert generation["separate_per_cap_generation_forbidden"] is True
    assert generation["post_generation_multi_image_stitching_forbidden"] is True

    layout = spec["layout"]
    assert layout["cell_size"] == [384, 1024]
    assert layout["cell_count"] == 4
    assert layout["declared_bbox"] == [128, 768]
    assert layout["runtime_target"] == [7, 42]
    assert layout["required_isolation"] == 128
    roles = layout["roles"]
    assert [item["id"] for item in roles] == [
        "player-left-cap",
        "player-right-cap",
        "target-left-cap",
        "target-right-cap",
    ]
    for item in roles:
        x0, y0, x1, y1 = item["bbox_exclusive"]
        assert (x1 - x0, y1 - y0) == (128, 768)

    source = WORK.read_text(encoding="utf-8")
    heading = spec["prompt_heading"]
    assert source.count(heading) == 1
    body = extract_fenced_body(source, heading)
    body_with_transport_newline = body.strip("\n") + "\n"
    assert hashlib.sha256(body_with_transport_newline.encode("utf-8")).hexdigest() == (
        spec["prompt_body_sha256"]
    )
    normalized_body = " ".join(body.split())
    required = (
        "exactly one production sprite-sheet image",
        "One generation call must return one single 1536 by 1024 RGB image",
        "Do not return four files",
        "exactly 128 pixels wide and exactly 768 pixels high",
        "between 5.94:1 and 6.06:1",
        "Player left cap",
        "Player right cap",
        "Target left cap",
        "Target right cap",
        "128 pixels of pure green",
        "visual weight comes from colour masses",
        "nearest the inner joining edge",
        "Draw no health or power fill",
        "The only non-green pixels belong to the four declared cap masses",
    )
    for clause in required:
        assert clause in normalized_body, (
            f"active Unit Frames prompt missing: {clause}"
        )
    print("unitframes design contract test passed")


if __name__ == "__main__":
    main()
