#!/usr/bin/env python3
"""Validate atlas, nine-slice, preview, and live UI display-region contracts."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


SCHEMA = "aeui-display-region-contract-v1"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Validate exact UI display regions. Boxes use top-left-origin, "
            "right/bottom-exclusive xyxy coordinates."
        )
    )
    parser.add_argument("contract", type=Path)
    parser.add_argument("--report", type=Path)
    return parser.parse_args()


def as_pair(value: Any, label: str) -> tuple[int, int]:
    if (
        not isinstance(value, list)
        or len(value) != 2
        or not all(isinstance(item, int) for item in value)
    ):
        raise ValueError(f"{label} must be [width, height] integers")
    if value[0] <= 0 or value[1] <= 0:
        raise ValueError(f"{label} dimensions must be positive")
    return value[0], value[1]


def as_box(value: Any, label: str) -> tuple[int, int, int, int]:
    if (
        not isinstance(value, list)
        or len(value) != 4
        or not all(isinstance(item, int) for item in value)
    ):
        raise ValueError(f"{label} must be [x0, y0, x1, y1] integers")
    x0, y0, x1, y1 = value
    if x1 <= x0 or y1 <= y0:
        raise ValueError(f"{label} must have positive area")
    return x0, y0, x1, y1


def area(box: tuple[int, int, int, int]) -> int:
    return (box[2] - box[0]) * (box[3] - box[1])


def contains(
    outer: tuple[int, int, int, int],
    inner: tuple[int, int, int, int],
) -> bool:
    return (
        outer[0] <= inner[0]
        and outer[1] <= inner[1]
        and outer[2] >= inner[2]
        and outer[3] >= inner[3]
    )


def intersection_area(
    left: tuple[int, int, int, int],
    right: tuple[int, int, int, int],
) -> int:
    width = max(0, min(left[2], right[2]) - max(left[0], right[0]))
    height = max(0, min(left[3], right[3]) - max(left[1], right[1]))
    return width * height


def overflow(
    zone: tuple[int, int, int, int],
    region: tuple[int, int, int, int],
) -> dict[str, int]:
    return {
        "left": max(0, zone[0] - region[0]),
        "top": max(0, zone[1] - region[1]),
        "right": max(0, region[2] - zone[2]),
        "bottom": max(0, region[3] - zone[3]),
    }


def add_violation(
    violations: list[dict[str, Any]],
    code: str,
    message: str,
    **evidence: Any,
) -> None:
    violations.append({"code": code, "message": message, **evidence})


def validate_contract(spec: dict[str, Any]) -> dict[str, Any]:
    if spec.get("schema") != SCHEMA:
        raise ValueError(f"contract schema must be {SCHEMA}")
    component = spec.get("component")
    if not isinstance(component, str) or not component:
        raise ValueError("component must be a non-empty string")

    violations: list[dict[str, Any]] = []
    checks: list[dict[str, Any]] = []

    atlas = spec.get("atlas")
    if not isinstance(atlas, dict):
        raise ValueError("atlas must be an object")
    atlas_width, atlas_height = as_pair(atlas.get("size"), "atlas.size")
    atlas_box = (0, 0, atlas_width, atlas_height)
    visible_box = as_box(atlas.get("visible_bbox"), "atlas.visible_bbox")
    if not contains(atlas_box, visible_box):
        add_violation(
            violations,
            "ATLAS_VISIBLE_BBOX_OUT_OF_BOUNDS",
            "The declared visible bbox is outside the atlas.",
            atlas_box=list(atlas_box),
            visible_bbox=list(visible_box),
        )

    sampled = atlas.get("sampled_regions")
    if not isinstance(sampled, list) or not sampled:
        raise ValueError("atlas.sampled_regions must be a non-empty array")
    sampled_boxes: list[tuple[str, tuple[int, int, int, int]]] = []
    for index, item in enumerate(sampled):
        if not isinstance(item, dict):
            raise ValueError(f"atlas.sampled_regions[{index}] must be an object")
        region_id = item.get("id")
        if not isinstance(region_id, str) or not region_id:
            raise ValueError(
                f"atlas.sampled_regions[{index}].id must be a non-empty string"
            )
        box = as_box(item.get("box"), f"atlas.sampled_regions[{index}].box")
        sampled_boxes.append((region_id, box))
        if not contains(atlas_box, box):
            add_violation(
                violations,
                "ATLAS_SAMPLE_OUT_OF_BOUNDS",
                "A sampled atlas region is outside the atlas.",
                region=region_id,
                box=list(box),
            )
        if not contains(visible_box, box):
            add_violation(
                violations,
                "ATLAS_SAMPLE_OUTSIDE_VISIBLE_BBOX",
                "A sampled atlas region includes undeclared padding.",
                region=region_id,
                box=list(box),
                visible_bbox=list(visible_box),
            )

    sampled_area = sum(area(box) for _, box in sampled_boxes)
    overlap_pairs: list[list[str]] = []
    for index, (left_id, left_box) in enumerate(sampled_boxes):
        for right_id, right_box in sampled_boxes[index + 1 :]:
            if intersection_area(left_box, right_box):
                overlap_pairs.append([left_id, right_id])
    if overlap_pairs:
        add_violation(
            violations,
            "ATLAS_SAMPLE_OVERLAP",
            "Sampled atlas regions overlap.",
            pairs=overlap_pairs,
        )
    if atlas.get("require_exact_visible_coverage", False):
        if sampled_area != area(visible_box) or overlap_pairs:
            add_violation(
                violations,
                "ATLAS_VISIBLE_COVERAGE_MISMATCH",
                "Sampled regions do not partition the visible bbox exactly.",
                sampled_area=sampled_area,
                visible_area=area(visible_box),
            )
    checks.append(
        {
            "id": "atlas_sampling",
            "sampled_area": sampled_area,
            "visible_area": area(visible_box),
            "regions": len(sampled_boxes),
        }
    )

    nine_slice = spec.get("nine_slice")
    if not isinstance(nine_slice, dict):
        raise ValueError("nine_slice must be an object")
    caps = nine_slice.get("caps")
    if not isinstance(caps, dict):
        raise ValueError("nine_slice.caps must be an object")
    cap_values: dict[str, int] = {}
    for edge in ("left", "right", "top", "bottom"):
        value = caps.get(edge)
        if not isinstance(value, int) or value <= 0:
            raise ValueError(f"nine_slice.caps.{edge} must be a positive integer")
        cap_values[edge] = value
    minimum = as_pair(nine_slice.get("minimum_frame_size"), "minimum_frame_size")
    expected_minimum = (
        cap_values["left"] + cap_values["right"] + 1,
        cap_values["top"] + cap_values["bottom"] + 1,
    )
    if minimum != expected_minimum:
        add_violation(
            violations,
            "NINE_SLICE_MINIMUM_MISMATCH",
            "Declared minimum frame size does not equal caps plus a 1px center.",
            declared=list(minimum),
            expected=list(expected_minimum),
        )

    provider_layout = spec.get("provider_layout", {})
    if not isinstance(provider_layout, dict):
        raise ValueError("provider_layout must be an object when present")
    scenarios = spec.get("scenarios")
    if not isinstance(scenarios, list) or not scenarios:
        raise ValueError("scenarios must be a non-empty array")

    scenario_reports: list[dict[str, Any]] = []
    for index, scenario in enumerate(scenarios):
        if not isinstance(scenario, dict):
            raise ValueError(f"scenarios[{index}] must be an object")
        scenario_id = scenario.get("id")
        if not isinstance(scenario_id, str) or not scenario_id:
            raise ValueError(f"scenarios[{index}].id must be a non-empty string")
        width, height = as_pair(scenario.get("frame"), f"{scenario_id}.frame")
        frame_box = (0, 0, width, height)
        before = len(violations)

        if width < minimum[0] or height < minimum[1]:
            add_violation(
                violations,
                "FRAME_BELOW_NINE_SLICE_MINIMUM",
                "The provider frame is smaller than the declared nine-slice minimum.",
                scenario=scenario_id,
                frame=[width, height],
                minimum=list(minimum),
            )
        center_width = width - cap_values["left"] - cap_values["right"]
        center_height = height - cap_values["top"] - cap_values["bottom"]
        if center_width < 1 or center_height < 1:
            add_violation(
                violations,
                "NINE_SLICE_CENTER_COLLAPSED",
                "The declared caps leave no positive center region.",
                scenario=scenario_id,
                center=[center_width, center_height],
            )

        if provider_layout:
            for key in ("panel_height", "entry_height", "objective_step"):
                if not isinstance(provider_layout.get(key), int):
                    raise ValueError(f"provider_layout.{key} must be an integer")
            entry_count = scenario.get("entry_count")
            objective_count = scenario.get("objective_count")
            if not isinstance(entry_count, int) or entry_count < 0:
                raise ValueError(f"{scenario_id}.entry_count must be >= 0")
            if not isinstance(objective_count, int) or objective_count < 0:
                raise ValueError(f"{scenario_id}.objective_count must be >= 0")
            derived_height = (
                provider_layout["panel_height"]
                + entry_count * provider_layout["entry_height"]
                + objective_count * provider_layout["objective_step"]
            )
            if derived_height != height:
                add_violation(
                    violations,
                    "PROVIDER_HEIGHT_FORMULA_MISMATCH",
                    "Scenario height does not match the provider layout formula.",
                    scenario=scenario_id,
                    frame_height=height,
                    derived_height=derived_height,
                )

        preview_frame = scenario.get("preview_frame")
        if preview_frame is not None:
            preview_size = as_pair(
                preview_frame,
                f"{scenario_id}.preview_frame",
            )
            if preview_size != (width, height):
                add_violation(
                    violations,
                    "PREVIEW_FRAME_MISMATCH",
                    "The real-layout preview does not use the actual provider frame.",
                    scenario=scenario_id,
                    frame=[width, height],
                    preview_frame=list(preview_size),
                )

        zones_raw = scenario.get("zones")
        if not isinstance(zones_raw, dict) or not zones_raw:
            raise ValueError(f"{scenario_id}.zones must be a non-empty object")
        zones: dict[str, tuple[int, int, int, int]] = {}
        for zone_id, value in zones_raw.items():
            zone_box = as_box(value, f"{scenario_id}.zones.{zone_id}")
            zones[zone_id] = zone_box
            if not contains(frame_box, zone_box):
                add_violation(
                    violations,
                    "ZONE_OUTSIDE_FRAME",
                    "A declared safe zone is outside the provider frame.",
                    scenario=scenario_id,
                    zone=zone_id,
                    box=list(zone_box),
                    frame=list(frame_box),
                )

        regions_raw = scenario.get("regions", [])
        if not isinstance(regions_raw, list):
            raise ValueError(f"{scenario_id}.regions must be an array")
        for region_index, region in enumerate(regions_raw):
            if not isinstance(region, dict):
                raise ValueError(
                    f"{scenario_id}.regions[{region_index}] must be an object"
                )
            region_id = region.get("id")
            zone_id = region.get("zone")
            if not isinstance(region_id, str) or not region_id:
                raise ValueError(
                    f"{scenario_id}.regions[{region_index}].id is invalid"
                )
            if zone_id not in zones:
                raise ValueError(
                    f"{scenario_id}.{region_id} references unknown zone {zone_id}"
                )
            region_box = as_box(
                region.get("box"),
                f"{scenario_id}.{region_id}.box",
            )
            if not contains(frame_box, region_box):
                add_violation(
                    violations,
                    "LIVE_REGION_OUTSIDE_FRAME",
                    "A live visible region is outside the provider frame.",
                    scenario=scenario_id,
                    region=region_id,
                    box=list(region_box),
                    frame=list(frame_box),
                )
            if not contains(zones[zone_id], region_box):
                add_violation(
                    violations,
                    "LIVE_REGION_OUTSIDE_SAFE_ZONE",
                    "A live visible region intersects decorative or unsafe pixels.",
                    scenario=scenario_id,
                    region=region_id,
                    kind=region.get("kind", "visual"),
                    zone=zone_id,
                    box=list(region_box),
                    zone_box=list(zones[zone_id]),
                    overflow=overflow(zones[zone_id], region_box),
                )

        scenario_reports.append(
            {
                "id": scenario_id,
                "frame": [width, height],
                "status": "pass" if len(violations) == before else "fail",
                "violation_count": len(violations) - before,
            }
        )

    unresolved_bounds = provider_layout.get("unresolved_bounds", [])
    if not isinstance(unresolved_bounds, list) or not all(
        isinstance(item, str) and item for item in unresolved_bounds
    ):
        raise ValueError(
            "provider_layout.unresolved_bounds must be an array of strings"
        )
    if unresolved_bounds:
        add_violation(
            violations,
            "UNRESOLVED_PROVIDER_BOUNDS",
            "One or more provider dimensions have no frozen supported bound.",
            bounds=unresolved_bounds,
        )

    return {
        "schema": "aeui-display-region-report-v1",
        "component": component,
        "status": "pass" if not violations else "fail",
        "summary": {
            "scenario_count": len(scenarios),
            "violation_count": len(violations),
            "first_failure": violations[0]["code"] if violations else None,
        },
        "checks": checks,
        "scenarios": scenario_reports,
        "violations": violations,
    }


def main() -> int:
    args = parse_args()
    try:
        spec = json.loads(args.contract.read_text(encoding="utf-8"))
        report = validate_contract(spec)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"display-region contract error: {error}", file=sys.stderr)
        return 2

    rendered = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(rendered, encoding="utf-8")
    print(rendered, end="")
    return 0 if report["status"] == "pass" else 1


if __name__ == "__main__":
    raise SystemExit(main())
