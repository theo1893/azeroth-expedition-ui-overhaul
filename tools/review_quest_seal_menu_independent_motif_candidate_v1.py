#!/usr/bin/env python3
"""Review one QS-B1 V6 independent single-object motif candidate.

The provider raw remains untouched. Derived files under ``generated/`` perform
only the authorized whole-square normalization, edge-connected chroma key,
transparent-RGB clearing, isotropic visible-bbox fit, four-state derivation,
and exact six-scenario Quest Log assembly. Non-target motifs in the assembly
are deterministic V16 placeholders and are explicitly non-authoritative.
This script never writes tracked source, runtime media, or addon files.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFont


CANVAS = (1024, 1024)
SAFE_BOX = (160, 160, 864, 864)
RESAMPLE = Image.Resampling.LANCZOS
STATE_ORDER = ("normal", "hover", "pressed", "disabled")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("raw", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--action", required=True)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument(
        "--spec",
        type=Path,
        default=Path("tools/specs/quest_log_seal_independent_motifs_simulation_v16.json"),
    )
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--prompt-version", required=True)
    parser.add_argument("--repo-commit", required=True)
    parser.add_argument("--session-id", required=True)
    return parser.parse_args()


def load_module(path: Path, name: str) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot import {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def write_display_region_contract(
    root: Path,
    spec: dict[str, Any],
    action: str,
    attempt: str,
    prompt_version: str,
    real_layout_path: Path,
    output_dir: Path,
) -> Path:
    template_path = root / spec["display_region"]["template"]
    contract = json.loads(template_path.read_text(encoding="utf-8"))
    contract["component"] = (
        "QS-B1/QUEST.LOG.ACTION.SEAL_MENU/V6/"
        f"{action}/{attempt}/production-candidate-review"
    )
    contract["evidence"].update(
        {
            "production_prompt_version": prompt_version,
            "production_candidate": str(real_layout_path),
            "background_ownership": (
                "accepted V5-A source reduced to one 32x174 visual-only master; "
                "dynamic prefix plus fixed tail"
            ),
            "motif_ownership": (
                f"{action} uses this independent production candidate; the other "
                "six motifs are deterministic V16 non-authoritative placeholders"
            ),
            "direction_only": False,
            "final_runtime": False,
        }
    )
    output = output_dir / f"{attempt}.display-region-contract.json"
    output.write_text(
        json.dumps(contract, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return output


def render_technical_board(
    raw: Image.Image,
    normalized: Image.Image,
    keyed: Image.Image,
    action: str,
    states: dict[str, Image.Image],
    output: Path,
) -> None:
    canvas = Image.new("RGBA", (1660, 1120), (35, 38, 35, 255))
    draw = ImageDraw.Draw(canvas, "RGBA")
    font = ImageFont.load_default()
    draw.text(
        (24, 20),
        f"QS-B1 V6 {action.upper()} independent candidate technical board",
        font=font,
        fill=(235, 202, 139, 255),
    )
    checker = Image.new("RGBA", (500, 500), (94, 90, 78, 255))
    checker_draw = ImageDraw.Draw(checker)
    for y in range(0, 500, 25):
        for x in range(0, 500, 25):
            if (x // 25 + y // 25) % 2:
                checker_draw.rectangle((x, y, x + 24, y + 24), fill=(135, 127, 106, 255))
    raw_thumb = raw.convert("RGBA").resize((500, 500), Image.Resampling.BILINEAR)
    normalized_thumb = normalized.convert("RGBA").resize((500, 500), Image.Resampling.BILINEAR)
    keyed_thumb = keyed.resize((500, 500), Image.Resampling.BILINEAR)
    keyed_checker = checker.copy()
    keyed_checker.alpha_composite(keyed_thumb)
    canvas.alpha_composite(raw_thumb, (24, 60))
    canvas.alpha_composite(normalized_thumb, (580, 60))
    canvas.alpha_composite(keyed_checker, (1136, 60))
    for x, label in (
        (24, "provider raw"),
        (580, "whole-square 1024 normalized"),
        (1136, "edge-connected keyed review"),
    ):
        draw.text((x, 570), label, font=font, fill=(216, 183, 121, 255))
    draw.text((24, 632), "deterministic four states at 16x nearest zoom", font=font, fill=(216, 183, 121, 255))
    for index, state in enumerate(STATE_ORDER):
        sprite = states[state].resize((512, 352), Image.Resampling.NEAREST)
        x = 24 + (index % 3) * 544
        y = 670 + (index // 3) * 390
        canvas.alpha_composite(sprite, (x, y))
        draw.text((x, y + 356), state, font=font, fill=(216, 183, 121, 255))
    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, "PNG")


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    raw_path = args.raw.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    spec_path = args.spec if args.spec.is_absolute() else root / args.spec

    worksheet = load_module(
        root / "tools/review_quest_seal_menu_motifs_candidate_v1.py",
        "aeui_qs_b1_v6_review_helpers",
    )
    chroma = load_module(
        root / "tools/review_quest_seal_ribbon_candidate_v2.py",
        "aeui_qs_b1_v6_chroma_helper",
    )
    renderer = load_module(
        root / "tools/render_quest_log_seal_layered_actions_simulation_v2.py",
        "aeui_qs_b1_v6_placeholder_renderer",
    )
    spec = renderer.load_simulation_spec(spec_path, root)
    by_id = {item["id"]: item for item in spec["production_sources"]}
    if args.action not in by_id:
        raise ValueError(f"unknown action: {args.action}")
    source_contract = by_id[args.action]

    with Image.open(raw_path) as opened:
        raw = opened.convert("RGB")
    if raw.width != raw.height:
        raise ValueError("V6 independent raw must be square before normalization")
    normalized = raw.resize(CANVAS, RESAMPLE)
    keyed, chroma_metrics = chroma.edge_connected_chroma_key(normalized)
    keyed = worksheet.clear_transparent_rgb(keyed)
    bbox = worksheet.alpha_bbox(keyed)
    if bbox is None:
        raise ValueError("candidate has no visible object after chroma key")
    normal, runtime_fit = worksheet.fit_cell_to_runtime(
        keyed,
        tuple(source_contract["runtime_content_box"]),
    )
    candidate_states = {
        state: worksheet.derive_state(normal, state) for state in STATE_ORDER
    }
    all_states: dict[str, dict[str, Image.Image]] = {}
    for action in worksheet.ACTIONS:
        action_id = action["id"]
        if action_id == args.action:
            all_states[action_id] = candidate_states
        else:
            all_states[action_id] = {
                state: renderer.motif_art(action_id, state, spec) for state in STATE_ORDER
            }

    normalized_path = output_dir / f"{args.attempt}.normalized-rgb.png"
    keyed_path = output_dir / f"{args.attempt}.keyed-review.png"
    sprite_path = output_dir / f"{args.attempt}.runtime-normal-review.png"
    atlas_path = output_dir / f"{args.attempt}.four-state-atlas-review.png"
    board_path = output_dir / f"{args.attempt}.technical-board.png"
    real_layout_path = output_dir / f"{args.attempt}.real-layout.png"
    normalized.save(normalized_path, "PNG")
    keyed.save(keyed_path, "PNG")
    normal.save(sprite_path, "PNG")
    atlas = worksheet.build_atlas(all_states)
    atlas.save(atlas_path, "PNG")
    render_technical_board(raw, normalized, keyed, args.action, candidate_states, board_path)
    state_metrics, merged_spec = worksheet.render_real_layout(
        root,
        spec_path,
        all_states,
        real_layout_path,
        board_title=f"QS-B1 V6 {args.action.upper()} · independent candidate real layout",
        board_subtitle=(
            "accepted V5-A substrate + one production candidate + six V16 "
            "non-authoritative placeholders · exact 676×464 Quest Log geometry"
        ),
    )
    display_contract_path = write_display_region_contract(
        root,
        merged_spec,
        args.action,
        args.attempt,
        args.prompt_version,
        real_layout_path,
        output_dir,
    )

    safe_box = tuple(source_contract["safe_box"])
    runtime_bbox = worksheet.alpha_bbox(normal)
    runtime_box = tuple(source_contract["runtime_content_box"])
    keyed_array = np.asarray(keyed)
    checks = {
        "raw_is_square": raw.width == raw.height,
        "normalized_canvas_is_1024_square": normalized.size == CANVAS,
        "keyed_transparent_rgb_is_zero": bool(
            np.all(keyed_array[:, :, :3][keyed_array[:, :, 3] == 0] == 0)
        ),
        "one_nonempty_semantic_canvas": bbox is not None,
        "visible_bbox_inside_safe_box": bool(bbox and worksheet.contains(safe_box, bbox)),
        "visible_green_spill_is_zero": worksheet.visible_green_spill(keyed) == 0,
        "runtime_bbox_inside_content_box": bool(
            runtime_bbox and worksheet.contains(runtime_box, runtime_bbox)
        ),
        "review_atlas_is_256x128": atlas.size == (256, 128),
        "real_layout_has_six_scenarios": len(state_metrics) == 6,
    }
    first_failed = next((name for name, passed in checks.items() if not passed), None)
    report = {
        "schema": "aeui.quest-log.seal-menu-independent-motif.candidate-review.v1",
        "batch": "QS-B1 V6",
        "action": args.action,
        "attempt": args.attempt,
        "prompt_version": args.prompt_version,
        "repo_commit_before_generation": args.repo_commit,
        "fixed_executor_session_id": args.session_id,
        "raw": {
            "path": str(raw_path),
            "sha256": sha256(raw_path),
            "size": list(raw.size),
            "mode": raw.mode,
        },
        "normalization": {
            "method": "whole-square proportional LANCZOS to 1024x1024",
            "path": str(normalized_path),
            "sha256": sha256(normalized_path),
            **chroma_metrics,
        },
        "candidate": {
            "safe_box_exclusive": list(safe_box),
            "visible_bbox_exclusive": list(bbox),
            "visible_green_spill": worksheet.visible_green_spill(keyed),
            "color": worksheet.color_metrics(keyed),
            "runtime_fit": runtime_fit,
            "keyed_review": {"path": str(keyed_path), "sha256": sha256(keyed_path)},
            "runtime_normal_review": {"path": str(sprite_path), "sha256": sha256(sprite_path)},
        },
        "checks": checks,
        "checks_passed": sum(checks.values()),
        "checks_total": len(checks),
        "first_automated_failure": first_failed,
        "technical_status": "pass" if first_failed is None else "fail",
        "real_layout": {
            "path": str(real_layout_path),
            "sha256": sha256(real_layout_path),
            "frame": merged_spec["frame"],
            "detail_viewport": merged_spec["layout"]["detail_viewport"],
            "state_metrics": state_metrics,
            "non_authoritative_motifs": [
                item["id"] for item in worksheet.ACTIONS if item["id"] != args.action
            ],
        },
        "display_region_contract": {
            "path": str(display_contract_path),
            "sha256": sha256(display_contract_path),
        },
        "outputs": {
            "four_state_atlas_review": {"path": str(atlas_path), "sha256": sha256(atlas_path)},
            "technical_board": {"path": str(board_path), "sha256": sha256(board_path)},
        },
        "promotion": {
            "source_written": False,
            "runtime_written": False,
            "addon_changed": False,
        },
    }
    report_path = output_dir / f"{args.attempt}.review.json"
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
