#!/usr/bin/env python3
"""Review one QS-B1 V3-A blank substrate candidate.

The raw provider image remains untouched.  Outputs are ignored review
intermediates only.  This script applies only the deterministic operations
authorized by the V3-A contract: square-canvas normalization, edge-connected
chroma keying, transparent-RGB clearing, proportional bbox fitting, fixed
prefix/tail extraction, and exact Quest Log real-layout assembly.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

from review_quest_seal_ribbon_candidate_v2 import (
    CANVAS,
    RESAMPLE,
    TARGET_BBOX,
    alpha_bbox,
    clear_transparent_rgb,
    edge_connected_chroma_key,
    proportional_fit,
)


RUNTIME_MASTER_SIZE = (32, 174)
RUNTIME_PREFIX_HEIGHT = 166
RUNTIME_TAIL_HEIGHT = 8
CUTS_SOURCE = (48, 136, 224, 312, 400, 488, 576, 664)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("raw", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument(
        "--spec",
        type=Path,
        default=Path(
            "tools/specs/quest_log_seal_layered_actions_simulation_v12.json"
        ),
    )
    parser.add_argument(
        "--display-template",
        type=Path,
        default=Path(
            "tools/specs/quest_log_seal_actions_simulation_v12_display_region.json"
        ),
    )
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--repo-commit", required=True)
    parser.add_argument("--session-id", required=True)
    return parser.parse_args()


def resolve(root: Path, value: str | Path) -> Path:
    path = Path(value)
    return path if path.is_absolute() else root / path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_module(path: Path, name: str) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def component_count(image: Image.Image) -> tuple[int, int]:
    alpha = np.asarray(image.convert("RGBA"))[:, :, 3]
    visible = alpha > 0
    if not visible.any():
        return 0, 0
    mask = Image.fromarray(np.where(visible, 1, 0).astype(np.uint8), "L").copy()
    count = 0
    largest = 0
    while True:
        array = np.asarray(mask)
        ys, xs = np.where(array == 1)
        if not len(xs):
            break
        count += 1
        ImageDraw.floodfill(mask, (int(xs[0]), int(ys[0])), 2, thresh=0)
        size = int((np.asarray(mask) == 2).sum())
        largest = max(largest, size)
        mask_array = np.asarray(mask).copy()
        mask_array[mask_array == 2] = 0
        mask = Image.fromarray(mask_array.astype(np.uint8), "L")
    return count, largest


def runtime_master_from_normalized(normalized: Image.Image) -> Image.Image:
    target = clear_transparent_rgb(normalized.crop(TARGET_BBOX))
    return clear_transparent_rgb(target.resize(RUNTIME_MASTER_SIZE, RESAMPLE))


def candidate_substrate(
    runtime_master: Image.Image, visible_count: int, menu_open: bool
) -> Image.Image:
    prefix = runtime_master.crop((0, 0, 32, RUNTIME_PREFIX_HEIGHT))
    if not menu_open:
        return clear_transparent_rgb(prefix.crop((0, 0, 32, 12)))
    prefix_height = 12 + visible_count * 22
    result = Image.new(
        "RGBA", (32, prefix_height + RUNTIME_TAIL_HEIGHT), (0, 0, 0, 0)
    )
    result.alpha_composite(prefix.crop((0, 0, 32, prefix_height)), (0, 0))
    result.alpha_composite(
        runtime_master.crop((0, 166, 32, 174)), (0, prefix_height)
    )
    return clear_transparent_rgb(result)


def runtime_metrics(runtime_master: Image.Image) -> dict[str, Any]:
    rgba = np.asarray(runtime_master.convert("RGBA"))
    alpha = rgba[:, :, 3]
    luma = (
        0.2126 * rgba[:, :, 0]
        + 0.7152 * rgba[:, :, 1]
        + 0.0722 * rgba[:, :, 2]
    )
    bbox = alpha_bbox(runtime_master)
    cuts: list[dict[str, Any]] = []
    for source_cut in CUTS_SOURCE:
        runtime_cut = source_cut // 4
        upper = max(0, runtime_cut - 2)
        lower = min(runtime_master.height, runtime_cut + 2)
        band = alpha[upper:lower]
        cuts.append(
            {
                "source_y": source_cut,
                "runtime_y": runtime_cut,
                "alpha_coverage": float((band > 0).mean()) if band.size else 0.0,
                "row_luma_jump": float(
                    abs(
                        luma[max(0, runtime_cut - 1)][
                            alpha[max(0, runtime_cut - 1)] > 0
                        ].mean()
                        - luma[min(runtime_master.height - 1, runtime_cut)][
                            alpha[min(runtime_master.height - 1, runtime_cut)] > 0
                        ].mean()
                    )
                )
                if (alpha[max(0, runtime_cut - 1)] > 0).any()
                and (alpha[min(runtime_master.height - 1, runtime_cut)] > 0).any()
                else None,
            }
        )

    seam_metrics: list[dict[str, Any]] = []
    tail_top = rgba[166]
    for visible_count in (1, 3, 5, 7):
        cutoff = 12 + visible_count * 22
        prefix_row = rgba[cutoff - 1]
        mask = (prefix_row[:, 3] > 0) & (tail_top[:, 3] > 0)
        delta = (
            float(
                np.abs(
                    prefix_row[mask, :3].astype(np.int16)
                    - tail_top[mask, :3].astype(np.int16)
                ).mean()
            )
            if mask.any()
            else None
        )
        seam_metrics.append(
            {
                "visible_count": visible_count,
                "prefix_height": cutoff,
                "overlap_pixels": int(mask.sum()),
                "mean_rgb_delta_to_tail": delta,
            }
        )

    gray = Image.fromarray(luma.astype(np.uint8), "L")
    blurred = np.asarray(gray.filter(ImageFilter.GaussianBlur(2.0))).astype(np.float32)
    high_frequency = np.abs(luma.astype(np.float32) - blurred)
    visible = alpha > 0
    return {
        "visible_bbox_exclusive": list(bbox or ()),
        "visible_pixels": int(visible.sum()),
        "transparent_rgb_zero": bool(np.all(rgba[alpha == 0, :3] == 0)),
        "mean_high_frequency_luma_residual": float(high_frequency[visible].mean())
        if visible.any()
        else None,
        "cut_bands": cuts,
        "dynamic_tail_seams": seam_metrics,
    }


def checker(size: tuple[int, int], block: int = 16) -> Image.Image:
    image = Image.new("RGBA", size, (52, 44, 37, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], block):
        for x in range(0, size[0], block):
            if (x // block + y // block) % 2:
                draw.rectangle(
                    (x, y, x + block - 1, y + block - 1),
                    fill=(83, 72, 62, 255),
                )
    return image


def render_contact_sheet(
    root: Path,
    raw: Image.Image,
    normalized: Image.Image,
    runtime_master: Image.Image,
    output: Path,
    attempt: str,
    fit: dict[str, Any],
) -> None:
    sheet = Image.new("RGBA", (1600, 1000), (31, 25, 21, 255))
    draw = ImageDraw.Draw(sheet, "RGBA")
    title = ImageFont.truetype(
        str(root / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"),
        22,
    )
    body = ImageFont.truetype(
        str(root / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"),
        15,
    )
    draw.text(
        (28, 22),
        f"QS-B1 V3-A 候选技术审查 · {attempt}",
        font=title,
        fill=(235, 201, 132, 255),
    )

    raw_preview = raw.convert("RGBA")
    raw_preview.thumbnail((500, 820), RESAMPLE)
    sheet.alpha_composite(raw_preview, (28, 70))
    draw.text((28, 910), "A · untouched provider raw", font=body, fill=(219, 183, 116, 255))

    normalized_preview = checker((512, 512))
    normalized_preview.alpha_composite(normalized.resize((512, 512), RESAMPLE))
    nx, ny = 550, 70
    sheet.alpha_composite(normalized_preview, (nx, ny))
    draw.rectangle(
        (
            nx + TARGET_BBOX[0] // 2,
            ny + TARGET_BBOX[1] // 2,
            nx + TARGET_BBOX[2] // 2,
            ny + TARGET_BBOX[3] // 2,
        ),
        outline=(237, 190, 79, 255),
        width=2,
    )
    for source_cut in CUTS_SOURCE:
        y = ny + (TARGET_BBOX[1] + source_cut) // 2
        draw.line(
            (nx + TARGET_BBOX[0] // 2, y, nx + TARGET_BBOX[2] // 2, y),
            fill=(141, 71, 52, 210),
            width=1,
        )
    draw.text((550, 603), "B · 1024² keyed + proportional bbox-fit", font=body, fill=(219, 183, 116, 255))

    runtime_big = runtime_master.resize((128, 696), Image.Resampling.NEAREST)
    runtime_board = checker((240, 760), 12)
    runtime_board.alpha_composite(runtime_big, (56, 30))
    sheet.alpha_composite(runtime_board, (1110, 70))
    draw.text((1110, 845), "C · canonical runtime master ×4", font=body, fill=(219, 183, 116, 255))

    labels = (
        f"raw visible: {fit['raw_visible_size'][0]}×{fit['raw_visible_size'][1]}",
        f"raw aspect: {fit['raw_visible_aspect']:.4f}",
        f"target aspect: {fit['target_visible_aspect']:.4f}",
        f"aspect error: {fit['relative_aspect_error']:.1%}",
        f"fit object: {fit['normalized_object_size'][0]}×{fit['normalized_object_size'][1]}",
    )
    for index, value in enumerate(labels):
        draw.text((1365, 90 + index * 26), value, font=body, fill=(213, 179, 113, 255))
    draw.text(
        (550, 930),
        "红线仅为 review 切点，不属于候选；所有输出仍在 generated/，不是 source/runtime。",
        font=body,
        fill=(190, 157, 101, 255),
    )
    sheet.save(output, "PNG")


def render_real_layout(
    root: Path,
    spec: dict[str, Any],
    runtime_master: Image.Image,
    output: Path,
) -> tuple[list[dict[str, Any]], dict[str, bool]]:
    module = load_module(
        root / "tools/render_quest_log_seal_layered_actions_simulation_v1.py",
        "aeui_qs_b1_v3a_layout",
    )
    base = module.load_base_module(root)
    module.substrate_art = lambda visible_count, menu_open: candidate_substrate(
        runtime_master, visible_count, menu_open
    )
    title_path = resolve(root, spec["inputs"]["title_font"])
    body_path = resolve(root, spec["inputs"]["body_font"])
    fonts = {
        "title": base.load_font(title_path, 16),
        "detail_title": base.load_font(title_path, 15),
        "heading": base.load_font(title_path, 11),
        "body": base.load_font(body_path, 10),
        "row": base.load_font(body_path, 10),
        "small": base.load_font(body_path, 9),
        "reward": base.load_font(body_path, 8),
        "board_title": base.load_font(title_path, 19),
        "board_body": base.load_font(body_path, 11),
        "board_small": base.load_font(body_path, 10),
    }
    shell, seal = base.load_inputs(root, spec)
    canvas = Image.new("RGBA", tuple(spec["canvas"]), module.BOARD)
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rectangle((0, 626, canvas.width, canvas.height), fill=module.BOARD_LOWER)
    for x in range(-90, canvas.width + 120, 150):
        draw.polygon(
            [(x, 626), (x + 126, 626), (x + 190, canvas.height), (x + 14, canvas.height)],
            fill=(67, 47, 32, 155),
            outline=(40, 28, 20, 180),
        )
    draw.text(
        (30, 22),
        "QS-B1 V3-A · 候选空白布底 · 真实 Quest Log 排版",
        font=fonts["board_title"],
        fill=(237, 201, 128, 255),
    )
    draw.text(
        (30, 52),
        "布底像素来自本次正式候选；纹章仍是 V12 本地几何占位，仅用于核对遮挡、动态长度和层序，不代表 V3-B 美术。",
        font=fonts["board_body"],
        fill=(203, 173, 113, 255),
    )
    metrics: list[dict[str, Any]] = []
    for origin, state in zip(
        [tuple(value) for value in spec["presentation"]["origins"]],
        spec["states"],
    ):
        draw.text(
            (origin[0], origin[1] - 27),
            state["label"],
            font=fonts["board_body"],
            fill=(237, 201, 128, 255),
        )
        module.draw_state(base, canvas, shell, seal, origin, spec, fonts, state)
        metrics.append(module.state_metrics(spec, state))
    draw.text(
        (30, 1172),
        "候选范围：仅空白 substrate。QS-A1 火漆、真实书壳、18 行任务、真实正文和 4 个奖励槽为当前 accepted/runtime 邻接 UI。",
        font=fonts["board_small"],
        fill=(213, 179, 113, 255),
    )
    draw.text(
        (30, 1195),
        "本图是 ignored P3 review intermediate；不创建 source、runtime、atlas 或 addon 接入。",
        font=fonts["board_small"],
        fill=(192, 159, 103, 255),
    )
    canvas.save(output, "PNG")

    by_id = {item["id"]: item for item in metrics}
    closed = by_id["closed-top"]
    seven = by_id["open-all-seven"]
    five = by_id["open-filtered-five"]
    three = by_id["open-filtered-three-disabled"]
    partial = by_id["filtered-five-partial-scroll"]
    full = by_id["filtered-five-fully-scrolled-out"]
    first_reward_y = min(box[1] for box in spec["layout"]["reward_slots_content"])
    seven_tail_end = module.tail_box(spec, spec["states"][1])[1] + 8
    five_tail_end = module.tail_box(spec, spec["states"][2])[1] + 8
    three_tail_end = module.tail_box(spec, spec["states"][3])[1] + 8
    checks = {
        "frame_is_676x464": spec["frame"] == [676, 464],
        "detail_viewport_is_real_246x324": spec["layout"]["detail_viewport"] == [366, 64, 246, 324],
        "quest_rows_are_18": spec["content"]["quest_rows"] == 18,
        "reward_slots_are_4": spec["content"]["reward_slots"] == 4,
        "closed_has_no_action_buttons": not closed["buttons"],
        "closed_root_visible": closed["root_visible_area"] > 0,
        "seven_independent_buttons": len(seven["buttons"]) == 7,
        "seven_enabled": seven["enabled_action_count"] == 7,
        "seven_contiguous": module.contiguous(seven["buttons"]),
        "seven_reward_gap_32": first_reward_y - seven_tail_end == 32,
        "five_exact_order": five["visible_actions"] == ["share", "detail", "show", "reset", "abandon"],
        "five_no_blank_slots": len(five["buttons"]) == 5 and module.contiguous(five["buttons"]),
        "five_background_shortens_44": seven["background_height"] - five["background_height"] == 44,
        "five_tail_moves_44": seven_tail_end - five_tail_end == 44,
        "three_exact_order": three["visible_actions"] == ["share", "show", "abandon"],
        "three_no_blank_slots": len(three["buttons"]) == 3 and module.contiguous(three["buttons"]),
        "three_background_shortens_88": seven["background_height"] - three["background_height"] == 88,
        "three_tail_moves_88": seven_tail_end - three_tail_end == 88,
        "disabled_remains_in_flow": any(item["id"] == "show" for item in three["buttons"]),
        "disabled_has_no_hitbox": three["enabled_action_count"] == 2,
        "partial_clips_first_action": partial["buttons"][0]["visible_area"] < 32 * 22 and not partial["buttons"][0]["hitbox_enabled"],
        "partial_contiguous": module.contiguous(partial["buttons"]),
        "partial_disabled_reset": not next(item for item in partial["buttons"] if item["id"] == "reset")["hitbox_enabled"],
        "partial_expected_enabled": partial["enabled_action_count"] == 3,
        "full_background_zero": full["background_visible_area"] == 0,
        "full_hitboxes_zero": full["enabled_action_count"] == 0,
    }
    return metrics, checks


def build_display_contract(
    template: dict[str, Any],
    raw: Path,
    normalized: Path,
    real_layout: Path,
    output: Path,
    attempt: str,
) -> None:
    contract = json.loads(json.dumps(template))
    contract["component"] = f"QS-B1/QUEST.LOG.ACTION.SEAL_MENU/V3-A/{attempt}"
    contract["evidence"] = {
        "provider": "QuestLogDetailScrollFrame + QuestLogDetailScrollChild",
        "adapter": "addon/AzerothExpeditionUI/Modules/Quests.lua",
        "candidate_raw": str(raw),
        "candidate_normalized_review": str(normalized),
        "candidate_real_layout": str(real_layout),
        "substrate_ownership": "one visual-only maximum prefix plus tail; no motif or action ownership",
        "motif_ownership": "V12 geometry placeholders are non-authoritative in this V3-A-only review",
        "candidate_source": False,
        "final_runtime": False,
    }
    contract["atlas"] = {
        "size": [128, 256],
        "visible_bbox": [16, 0, 112, 166],
        "require_exact_visible_coverage": False,
        "sampled_regions": [
            {"id": "substrate.maximum-prefix", "box": [16, 0, 48, 166]},
            {"id": "substrate.tail", "box": [80, 0, 112, 8]},
        ],
    }
    output.write_text(json.dumps(contract, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    raw = Image.open(args.raw).convert("RGB")
    raw_square = raw.width == raw.height
    if not raw_square:
        raise ValueError("V3-A raw must be square before deterministic normalization")
    canvas_normalized = raw
    if raw.size != CANVAS:
        canvas_normalized = raw.resize(CANVAS, RESAMPLE)
    keyed, chroma = edge_connected_chroma_key(canvas_normalized)
    normalized, fit = proportional_fit(keyed)
    runtime_master = runtime_master_from_normalized(normalized)
    components, largest_component = component_count(keyed)
    runtime = runtime_metrics(runtime_master)

    keyed_path = output_dir / f"{args.attempt}.keyed.png"
    normalized_path = output_dir / f"{args.attempt}.normalized-review.png"
    runtime_path = output_dir / f"{args.attempt}.runtime-master-review.png"
    contact_path = output_dir / f"{args.attempt}.contact-sheet.png"
    real_layout_path = output_dir / f"{args.attempt}.real-layout.png"
    display_contract_path = output_dir / f"{args.attempt}.display-region-contract.json"
    report_path = output_dir / f"{args.attempt}.review.json"
    keyed.save(keyed_path, "PNG")
    normalized.save(normalized_path, "PNG")
    runtime_master.save(runtime_path, "PNG")
    render_contact_sheet(root, raw, normalized, runtime_master, contact_path, args.attempt, fit)

    spec = json.loads(resolve(root, args.spec).read_text(encoding="utf-8"))
    state_metrics, layout_checks = render_real_layout(
        root, spec, runtime_master, real_layout_path
    )
    display_template = json.loads(
        resolve(root, args.display_template).read_text(encoding="utf-8")
    )
    build_display_contract(
        display_template,
        args.raw.resolve(),
        normalized_path,
        real_layout_path,
        display_contract_path,
        args.attempt,
    )

    checks = {
        "raw_canvas_is_square": raw_square,
        "deterministic_canvas_is_1024_square": canvas_normalized.size == CANVAS,
        "one_connected_visible_object": components == 1,
        "normalized_visible_bbox_exactly_128x696": fit["normalized_visible_bbox_exclusive"] == list(TARGET_BBOX),
        "visible_aspect_within_one_percent": fit["relative_aspect_error"] <= 0.01,
        "runtime_visible_bbox_exactly_32x174": runtime["visible_bbox_exclusive"] == [0, 0, 32, 174],
        "transparent_rgb_is_zero": runtime["transparent_rgb_zero"],
        "all_dynamic_cut_bands_have_cloth": all(item["alpha_coverage"] >= 0.75 for item in runtime["cut_bands"]),
        "all_real_layout_geometry_checks_pass": all(layout_checks.values()),
    }
    first_failed = next((name for name, passed in checks.items() if not passed), None)
    report = {
        "schema": "aeui.quest-seal-menu.substrate-candidate-review.v3",
        "batch": "QS-B1 V3-A",
        "attempt": args.attempt,
        "repo_commit_before_generation": args.repo_commit,
        "fixed_executor_session_id": args.session_id,
        "raw": {
            "path": str(args.raw.resolve()),
            "sha256": sha256(args.raw),
            "size": list(raw.size),
            "mode": raw.mode,
            **chroma,
        },
        "fit": fit,
        "connected_components": {
            "count": components,
            "largest_visible_pixels": largest_component,
        },
        "runtime_master": runtime,
        "layout_checks": layout_checks,
        "layout_checks_passed": sum(layout_checks.values()),
        "layout_checks_total": len(layout_checks),
        "checks": checks,
        "checks_passed": sum(checks.values()),
        "checks_total": len(checks),
        "first_automated_failure": first_failed,
        "technical_status": "pass" if first_failed is None else "fail",
        "real_layout": {
            "path": str(real_layout_path),
            "sha256": sha256(real_layout_path),
            "frame": spec["frame"],
            "detail_viewport": spec["layout"]["detail_viewport"],
            "quest_rows": spec["content"]["quest_rows"],
            "reward_slots": spec["content"]["reward_slots"],
            "state_metrics": state_metrics,
            "v3b_motifs": "non-authoritative V12 local geometry placeholders",
        },
        "display_region_contract": {
            "path": str(display_contract_path),
            "sha256": sha256(display_contract_path),
        },
        "outputs": {
            "keyed": {"path": str(keyed_path), "sha256": sha256(keyed_path)},
            "normalized": {"path": str(normalized_path), "sha256": sha256(normalized_path)},
            "runtime_master_review": {"path": str(runtime_path), "sha256": sha256(runtime_path)},
            "contact_sheet": {"path": str(contact_path), "sha256": sha256(contact_path)},
        },
        "promotion": {
            "source_written": False,
            "runtime_written": False,
            "addon_changed": False,
        },
    }
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
