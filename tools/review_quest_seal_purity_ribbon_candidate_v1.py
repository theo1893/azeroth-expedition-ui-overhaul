#!/usr/bin/env python3
"""Review one QS-B1 V7-A material donor without promoting any asset.

The provider raw is immutable.  This reviewer applies only the authorized
deterministic contract: square normalization, the fixed central crop, the
tracked antialiased polygon mask, accepted QS-A1 Alpha-only contact darkening,
transparent-RGB clearing, proportional 32x192 reduction, dynamic prefix/tail
assembly, and the exact six Quest Log display scenarios.  Every output remains
under ignored generated/ and is review evidence, never source or addon runtime.
"""

from __future__ import annotations

import argparse
from collections import deque
import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont


RESAMPLE = Image.Resampling.LANCZOS


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("raw", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument(
        "--production-contract",
        type=Path,
        default=Path(
            "tools/specs/quest_log_seal_purity_ribbon_production_v7a.json"
        ),
    )
    parser.add_argument(
        "--simulation-spec",
        type=Path,
        default=Path(
            "tools/specs/quest_log_seal_purity_ribbon_simulation_v17.json"
        ),
    )
    parser.add_argument(
        "--display-template",
        type=Path,
        default=Path(
            "tools/specs/quest_log_seal_purity_ribbon_simulation_v17_display_region.json"
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


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    return image.convert("RGBA").getchannel("A").getbbox()


def component_count(
    image: Image.Image, alpha_threshold: int = 8
) -> tuple[int, int]:
    alpha = np.asarray(image.convert("RGBA"))[:, :, 3]
    visible = alpha >= alpha_threshold
    visited = np.zeros(visible.shape, dtype=bool)
    height, width = visible.shape
    count = 0
    largest = 0
    for start_y, start_x in np.argwhere(visible & ~visited):
        if visited[start_y, start_x]:
            continue
        count += 1
        size = 0
        queue: deque[tuple[int, int]] = deque(
            [(int(start_x), int(start_y))]
        )
        visited[start_y, start_x] = True
        while queue:
            x, y = queue.popleft()
            size += 1
            for nx, ny in (
                (x - 1, y),
                (x + 1, y),
                (x, y - 1),
                (x, y + 1),
            ):
                if (
                    0 <= nx < width
                    and 0 <= ny < height
                    and visible[ny, nx]
                    and not visited[ny, nx]
                ):
                    visited[ny, nx] = True
                    queue.append((nx, ny))
        largest = max(largest, size)
    return count, largest


def build_mask(contract: dict[str, Any]) -> Image.Image:
    width, height = contract["alpha_mask"]["canvas"]
    # The source mask is four times the final 32x192 runtime geometry.  A
    # further 4x rasterization gives deterministic antialiasing at source size.
    scale = 4
    high = Image.new("L", (width * scale, height * scale), 0)
    points = [
        (int(point[0]) * scale, int(point[1]) * scale)
        for point in contract["alpha_mask"]["points"]
    ]
    ImageDraw.Draw(high).polygon(points, fill=255)
    return high.resize((width, height), RESAMPLE)


def build_wax_projection(
    root: Path, contract: dict[str, Any]
) -> tuple[Image.Image, dict[str, Any]]:
    wax = contract["wax_contact"]
    path = resolve(root, wax["wax_source"])
    if sha256(path) != wax["wax_source_sha256"]:
        raise ValueError("accepted QS-A1 wax SHA-256 changed")
    with Image.open(path) as opened:
        source = clear_transparent_rgb(opened)
    bbox = alpha_bbox(source)
    if bbox is None:
        raise ValueError("accepted QS-A1 wax has no Alpha")
    cropped_alpha = source.getchannel("A").crop(bbox)
    width, height = wax["source_projection_size"]
    visible_max = min(width, height) - 8
    ratio = min(visible_max / cropped_alpha.width, visible_max / cropped_alpha.height)
    visible_size = (
        max(1, round(cropped_alpha.width * ratio)),
        max(1, round(cropped_alpha.height * ratio)),
    )
    visible_alpha = cropped_alpha.resize(visible_size, RESAMPLE)
    projection = Image.new("L", (width, height), 0)
    projection.paste(
        visible_alpha,
        ((width - visible_size[0]) // 2, (height - visible_size[1]) // 2),
    )
    return projection, {
        "source": str(path),
        "source_sha256": sha256(path),
        "source_visible_bbox_exclusive": list(bbox),
        "projection_size": list(projection.size),
        "projection_visible_bbox_exclusive": list(projection.getbbox() or ()),
    }


def place_projection(
    projection: Image.Image,
    canvas_size: tuple[int, int],
    offset: tuple[int, int],
) -> Image.Image:
    output = Image.new("L", canvas_size, 0)
    dst_x = max(0, offset[0])
    dst_y = max(0, offset[1])
    src_x = max(0, -offset[0])
    src_y = max(0, -offset[1])
    width = min(projection.width - src_x, canvas_size[0] - dst_x)
    height = min(projection.height - src_y, canvas_size[1] - dst_y)
    if width > 0 and height > 0:
        output.paste(
            projection.crop((src_x, src_y, src_x + width, src_y + height)),
            (dst_x, dst_y),
        )
    return output


def normalize_and_compose(
    raw: Image.Image,
    root: Path,
    contract: dict[str, Any],
) -> tuple[
    Image.Image,
    Image.Image,
    Image.Image,
    Image.Image,
    Image.Image,
    Image.Image,
    dict[str, Any],
]:
    normal = contract["deterministic_normalization"]
    target = tuple(normal["normalized_canvas"])
    if raw.width != raw.height:
        raise ValueError("V7-A provider raw must be exactly square for isotropic normalization")
    normalized = raw.convert("RGB").resize(target, RESAMPLE)
    crop_box = tuple(int(value) for value in normal["fixed_crop"])
    crop = normalized.crop(crop_box)
    expected_crop = tuple(normal["candidate_source_size"])
    if crop.size != expected_crop:
        raise ValueError("fixed V7-A crop size changed")
    mask = build_mask(contract)
    projection, projection_metrics = build_wax_projection(root, contract)
    contact = place_projection(
        projection,
        crop.size,
        tuple(contract["wax_contact"]["source_projection_offset"]),
    )

    rgba = np.asarray(crop.convert("RGBA")).copy()
    mask_array = np.asarray(mask, dtype=np.uint8)
    contact_array = np.asarray(contact, dtype=np.float32)
    factor = 1.0 - 0.16 * (contact_array / 255.0)
    inside = mask_array > 0
    rgb = rgba[:, :, :3].astype(np.float32)
    rgb[inside] *= factor[inside, None]
    rgba[:, :, :3] = np.clip(np.rint(rgb), 0, 255).astype(np.uint8)
    rgba[:, :, 3] = mask_array
    rgba[mask_array == 0, :3] = 0
    composite = clear_transparent_rgb(Image.fromarray(rgba, "RGBA"))
    runtime = clear_transparent_rgb(
        composite.resize(tuple(contract["alpha_mask"]["runtime_size"]), RESAMPLE)
    )
    return normalized, crop, mask, contact, composite, runtime, {
        "raw_mode": raw.mode,
        "raw_size": list(raw.size),
        "raw_square": raw.width == raw.height,
        "normalized_size": list(normalized.size),
        "normalization": "whole-square isotropic LANCZOS",
        "crop_box": list(crop_box),
        "crop_size": list(crop.size),
        "mask_bbox_exclusive": list(mask.getbbox() or ()),
        "contact_bbox_exclusive": list(contact.getbbox() or ()),
        "composite_bbox_exclusive": list(alpha_bbox(composite) or ()),
        "wax_projection": projection_metrics,
        "contact_formula": contract["wax_contact"]["rgb_multiplier"],
    }


def texture_metrics(image: Image.Image) -> dict[str, Any]:
    rgb = np.asarray(image.convert("RGB"), dtype=np.float32)
    luma = 0.2126 * rgb[:, :, 0] + 0.7152 * rgb[:, :, 1] + 0.0722 * rgb[:, :, 2]
    column_means = luma.mean(axis=0)
    row_means = luma.mean(axis=1)
    blurred = np.asarray(
        Image.fromarray(np.clip(luma, 0, 255).astype(np.uint8), "L").filter(
            ImageFilter.GaussianBlur(2.0)
        ),
        dtype=np.float32,
    )
    column_jumps = np.abs(np.diff(column_means))
    row_jumps = np.abs(np.diff(row_means))
    return {
        "mean_rgb": [float(value) for value in rgb.mean(axis=(0, 1))],
        "mean_luma": float(luma.mean()),
        "luma_stddev": float(luma.std()),
        "max_adjacent_column_mean_jump": float(column_jumps.max()),
        "max_column_jump_after_x": int(column_jumps.argmax()),
        "max_adjacent_row_mean_jump": float(row_jumps.max()),
        "max_row_jump_after_y": int(row_jumps.argmax()),
        "mean_high_frequency_luma_residual": float(np.abs(luma - blurred).mean()),
    }


def render_contact_sheet(
    root: Path,
    raw: Image.Image,
    normalized: Image.Image,
    crop: Image.Image,
    mask: Image.Image,
    contact: Image.Image,
    composite: Image.Image,
    runtime: Image.Image,
    output: Path,
    attempt: str,
) -> None:
    sheet = Image.new("RGBA", (1700, 1040), (31, 25, 21, 255))
    draw = ImageDraw.Draw(sheet, "RGBA")
    title = ImageFont.truetype(
        str(root / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"),
        22,
    )
    body = ImageFont.truetype(
        str(root / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"),
        15,
    )
    draw.text((28, 22), f"QS-B1 V7-A donor 确定性审查 · {attempt}", font=title, fill=(235, 201, 132, 255))
    raw_preview = raw.convert("RGBA")
    raw_preview.thumbnail((390, 390), RESAMPLE)
    sheet.alpha_composite(raw_preview, (28, 84))
    draw.text((28, 490), "A · untouched provider raw", font=body, fill=(219, 183, 116, 255))

    normalized_preview = normalized.convert("RGBA").resize((390, 390), RESAMPLE)
    sheet.alpha_composite(normalized_preview, (28, 540))
    draw.rectangle((198, 589, 248, 882), outline=(237, 190, 79, 255), width=2)
    draw.text((28, 948), "B · 1024² + fixed [448,128,576,896] crop", font=body, fill=(219, 183, 116, 255))

    sheet.alpha_composite(crop.convert("RGBA"), (450, 118))
    draw.text((450, 84), "C · 128×768 donor crop", font=body, fill=(219, 183, 116, 255))

    mask_view = Image.new("RGBA", mask.size, (218, 210, 188, 255))
    mask_view.putalpha(mask)
    sheet.alpha_composite(mask_view, (610, 118))
    draw.text((610, 84), "D · tracked polygon Alpha", font=body, fill=(219, 183, 116, 255))

    contact_view = Image.new("RGBA", contact.size, (106, 45, 39, 255))
    contact_view.putalpha(contact)
    sheet.alpha_composite(contact_view, (770, 118))
    draw.text((770, 84), "E · QS-A1 Alpha contact", font=body, fill=(219, 183, 116, 255))

    checker = Image.new("RGBA", (160, 792), (58, 49, 42, 255))
    checker_draw = ImageDraw.Draw(checker)
    for y in range(0, 792, 12):
        for x in range(0, 160, 12):
            if (x // 12 + y // 12) % 2:
                checker_draw.rectangle((x, y, x + 11, y + 11), fill=(87, 75, 64, 255))
    checker.alpha_composite(composite, (16, 12))
    sheet.alpha_composite(checker, (930, 106))
    draw.text((930, 84), "F · candidate composite", font=body, fill=(219, 183, 116, 255))

    runtime_board = checker.copy()
    runtime_board.alpha_composite(runtime.resize((128, 768), Image.Resampling.NEAREST), (16, 12))
    sheet.alpha_composite(runtime_board, (1110, 106))
    draw.text((1110, 84), "G · 32×192 runtime ×4", font=body, fill=(219, 183, 116, 255))

    notes = [
        "raw → isotropic 1024² → fixed crop；无 bbox-fit、镜像或自由重绘",
        "tracked mask 独占轮廓／Alpha；QS-A1 只贡献 Alpha 接触压暗，不复制蜡 RGB",
        "候选仍在 generated/；不写 source、runtime、atlas 或 addon。",
    ]
    for index, note in enumerate(notes):
        draw.text((1300, 126 + index * 55), note, font=body, fill=(208, 177, 117, 255))
    sheet.save(output, "PNG")


def render_real_layout(
    root: Path,
    simulation_spec_path: Path,
    runtime_master: Image.Image,
    output: Path,
    preview_dir: Path,
) -> tuple[dict[str, Any], list[dict[str, Any]], dict[str, bool], dict[str, dict[str, Any]]]:
    module = load_module(
        root / "tools/render_quest_log_seal_layered_actions_simulation_v2.py",
        "aeui_qs_b1_v7a_layout",
    )
    spec = module.load_simulation_spec(simulation_spec_path, root)
    spec["_repo_root"] = str(root)
    module.substrate_master_v4 = lambda _spec: runtime_master.copy()
    base = module.load_base_module(root)
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
    draw.text((30, 22), "QS-B1 V7-A · 正式 donor candidate · 真实 Quest Log 六态排版", font=fonts["board_title"], fill=(237, 201, 128, 255))
    draw.text((30, 52), "只替换连续载体材质；tracked mask、QS-A1 火漆、七纹章几何占位、真实书壳／文字／奖励仍按冻结层序装配。", font=fonts["board_body"], fill=(203, 173, 113, 255))
    preview_dir.mkdir(parents=True, exist_ok=True)
    metrics: list[dict[str, Any]] = []
    previews: dict[str, dict[str, Any]] = {}
    for origin, state in zip(
        [tuple(value) for value in spec["presentation"]["origins"]],
        spec["states"],
    ):
        draw.text((origin[0], origin[1] - 27), state["label"], font=fonts["board_body"], fill=(237, 201, 128, 255))
        module.draw_state(base, canvas, shell, seal, origin, spec, fonts, state)
        metrics.append(module.state_metrics(spec, state))
        content = module.draw_detail_content(base, spec, fonts, seal, state)
        _, _, viewport_width, viewport_height = spec["layout"]["detail_viewport"]
        offset = state["scroll_offset"]
        preview = content.crop((0, offset, viewport_width, offset + viewport_height))
        preview_path = preview_dir / f"{state['id']}.png"
        preview.save(preview_path, "PNG")
        previews[state["id"]] = {
            "path": str(preview_path),
            "sha256": sha256(preview_path),
            "size": list(preview.size),
        }
    draw.text((30, 1172), "候选范围仅为载体 donor；纹章仍是已确认 V15 色彩角色的非权威几何占位。P3 review intermediate，不创建 source/runtime/addon。", font=fonts["board_small"], fill=(213, 179, 113, 255))
    canvas.save(output, "PNG")

    by_id = {item["id"]: item for item in metrics}
    closed = by_id["closed-top"]
    seven = by_id["open-all-seven"]
    five = by_id["open-filtered-five"]
    three = by_id["open-filtered-three-disabled"]
    partial = by_id["filtered-five-partial-scroll"]
    full = by_id["filtered-five-fully-scrolled-out"]
    tail_height = spec["layout"]["substrate_tail_size"][1]
    first_reward_y = min(box[1] for box in spec["layout"]["reward_slots_content"])
    seven_tail_end = module.tail_box(spec, spec["states"][1])[1] + tail_height
    five_tail_end = module.tail_box(spec, spec["states"][2])[1] + tail_height
    three_tail_end = module.tail_box(spec, spec["states"][3])[1] + tail_height
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
        "five_reward_gap_76": first_reward_y - five_tail_end == 76,
        "three_exact_order": three["visible_actions"] == ["share", "show", "abandon"],
        "three_no_blank_slots": len(three["buttons"]) == 3 and module.contiguous(three["buttons"]),
        "three_background_shortens_88": seven["background_height"] - three["background_height"] == 88,
        "three_tail_moves_88": seven_tail_end - three_tail_end == 88,
        "three_reward_gap_120": first_reward_y - three_tail_end == 120,
        "disabled_remains_in_flow": any(item["id"] == "show" for item in three["buttons"]),
        "disabled_has_no_hitbox": three["enabled_action_count"] == 2,
        "partial_clips_first_action": partial["buttons"][0]["visible_area"] < 32 * 22 and not partial["buttons"][0]["hitbox_enabled"],
        "partial_contiguous": module.contiguous(partial["buttons"]),
        "partial_disabled_reset": not next(item for item in partial["buttons"] if item["id"] == "reset")["hitbox_enabled"],
        "partial_expected_enabled": partial["enabled_action_count"] == 3,
        "full_background_zero": full["background_visible_area"] == 0,
        "full_hitboxes_zero": full["enabled_action_count"] == 0,
        "all_detail_previews_are_246x324": all(item["size"] == [246, 324] for item in previews.values()),
    }
    return spec, metrics, checks, previews


def build_display_contract(
    template: dict[str, Any],
    contract: dict[str, Any],
    raw: Path,
    composite: Path,
    real_layout: Path,
    previews: dict[str, dict[str, Any]],
    output: Path,
    attempt: str,
) -> None:
    display = json.loads(json.dumps(template))
    display["component"] = f"QS-B1/QUEST.LOG.ACTION.SEAL_MENU.SUBSTRATE.MAX/V7-A/{attempt}"
    display["evidence"] = {
        "provider": "QuestLogDetailScrollFrame + QuestLogDetailScrollChild",
        "adapter": "addon/AzerothExpeditionUI/Modules/Quests.lua",
        "candidate_raw": str(raw),
        "candidate_composite": str(composite),
        "candidate_real_layout": str(real_layout),
        "exact_detail_previews": previews,
        "substrate_ownership": "one visual-only 32x192 carrier master; dynamic prefix plus one 14px asymmetric tail; no motif or action ownership",
        "wax_ownership": "accepted QS-A1 remains a separate top-layer object; only its Alpha darkens carrier RGB deterministically",
        "motif_ownership": "seven independent sources and Buttons; V15 geometry placeholders remain non-authoritative here",
        "candidate_source": False,
        "final_runtime": False,
    }
    source_size = contract["alpha_mask"]["canvas"]
    display["atlas"] = {
        "size": source_size,
        "visible_bbox": [0, 0, source_size[0], source_size[1]],
        "require_exact_visible_coverage": True,
        "sampled_regions": [
            {"id": "substrate.canonical-composite", "box": [0, 0, source_size[0], source_size[1]]}
        ],
    }
    display["nine_slice"] = {
        "caps": {"left": 1, "right": 1, "top": 1, "bottom": 1},
        "minimum_frame_size": [3, 3],
    }
    output.write_text(json.dumps(display, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    args = parse_args()
    root = args.repo_root.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    raw_path = args.raw.resolve()
    contract_path = resolve(root, args.production_contract)
    simulation_path = resolve(root, args.simulation_spec)
    contract = json.loads(contract_path.read_text(encoding="utf-8"))
    if contract["version"] != "QS-B1 V7-A" or not contract["executor"]["authorized"]:
        raise ValueError("V7-A production contract is not the authorized version")
    with Image.open(raw_path) as opened:
        raw = opened.copy()

    normalized, crop, mask, contact, composite, runtime, construction = normalize_and_compose(raw, root, contract)
    components, largest_component = component_count(composite)
    base = args.attempt
    paths = {
        "normalized": output_dir / f"{base}.normalized-donor.png",
        "crop": output_dir / f"{base}.fixed-crop.png",
        "mask": output_dir / f"{base}.mask.png",
        "contact": output_dir / f"{base}.wax-contact-alpha.png",
        "composite": output_dir / f"{base}.composite.png",
        "runtime": output_dir / f"{base}.runtime-master-review.png",
        "contact_sheet": output_dir / f"{base}.contact-sheet.png",
        "real_layout": output_dir / f"{base}.real-layout.png",
        "display_contract": output_dir / f"{base}.display-region-contract.json",
        "report": output_dir / f"{base}.review.json",
    }
    normalized.save(paths["normalized"], "PNG")
    crop.save(paths["crop"], "PNG")
    mask.save(paths["mask"], "PNG")
    contact.save(paths["contact"], "PNG")
    composite.save(paths["composite"], "PNG")
    runtime.save(paths["runtime"], "PNG")
    render_contact_sheet(root, raw, normalized, crop, mask, contact, composite, runtime, paths["contact_sheet"], args.attempt)
    simulation, state_metrics, layout_checks, previews = render_real_layout(
        root, simulation_path, runtime, paths["real_layout"], output_dir / f"{base}.detail-previews"
    )
    display_template = json.loads(resolve(root, args.display_template).read_text(encoding="utf-8"))
    build_display_contract(display_template, contract, raw_path, paths["composite"], paths["real_layout"], previews, paths["display_contract"], args.attempt)

    source_rgba = np.asarray(composite.convert("RGBA"))
    runtime_rgba = np.asarray(runtime.convert("RGBA"))
    checks = {
        "raw_canvas_is_exactly_square": raw.width == raw.height,
        "raw_mode_is_rgb_or_rgba": raw.mode in ("RGB", "RGBA"),
        "deterministic_canvas_is_1024_square": construction["normalized_size"] == [1024, 1024],
        "fixed_crop_contract_is_exact": construction["crop_box"] == [448, 128, 576, 896],
        "fixed_crop_is_128x768": construction["crop_size"] == [128, 768],
        "mask_has_31_tracked_points": len(contract["alpha_mask"]["points"]) == 31,
        "composite_is_128x768_rgba": composite.size == (128, 768) and composite.mode == "RGBA",
        "composite_is_one_connected_object": components == 1,
        "composite_transparent_rgb_is_zero": bool(np.all(source_rgba[source_rgba[:, :, 3] == 0, :3] == 0)),
        "contact_uses_alpha_without_wax_rgb": contract["wax_contact"]["wax_pixels_are_never_copied_into_carrier_source"],
        "runtime_is_exactly_32x192": runtime.size == (32, 192),
        "runtime_transparent_rgb_is_zero": bool(np.all(runtime_rgba[runtime_rgba[:, :, 3] == 0, :3] == 0)),
        "all_real_layout_geometry_checks_pass": all(layout_checks.values()),
    }
    first_failed = next((name for name, passed in checks.items() if not passed), None)
    report = {
        "schema": "aeui.quest-seal-menu.purity-ribbon-candidate-review.v1",
        "batch": "QS-B1 V7-A",
        "attempt": args.attempt,
        "repo_commit_before_generation": args.repo_commit,
        "fixed_executor_session_id": args.session_id,
        "raw": {"path": str(raw_path), "sha256": sha256(raw_path), "size": list(raw.size), "mode": raw.mode},
        "contracts": {
            "production": {"path": str(contract_path), "sha256": sha256(contract_path)},
            "simulation": {"path": str(simulation_path), "sha256": sha256(simulation_path)},
        },
        "deterministic_construction": construction,
        "connected_components": {"count": components, "largest_visible_pixels": largest_component, "alpha_threshold": 8},
        "texture_metrics": {"fixed_crop": texture_metrics(crop), "runtime": texture_metrics(runtime.convert("RGB"))},
        "layout_checks": layout_checks,
        "layout_checks_passed": sum(layout_checks.values()),
        "layout_checks_total": len(layout_checks),
        "checks": checks,
        "checks_passed": sum(checks.values()),
        "checks_total": len(checks),
        "first_automated_failure": first_failed,
        "technical_status": "pass" if first_failed is None else "fail",
        "real_layout": {
            "path": str(paths["real_layout"]),
            "sha256": sha256(paths["real_layout"]),
            "frame": simulation["frame"],
            "detail_viewport": simulation["layout"]["detail_viewport"],
            "quest_rows": simulation["content"]["quest_rows"],
            "reward_slots": simulation["content"]["reward_slots"],
            "state_metrics": state_metrics,
            "detail_previews": previews,
            "motifs": "non-authoritative V15 geometry placeholders",
        },
        "display_region_contract": {"path": str(paths["display_contract"]), "sha256": sha256(paths["display_contract"])},
        "outputs": {name: {"path": str(path), "sha256": sha256(path)} for name, path in paths.items() if name != "report"},
        "promotion": {"source_written": False, "runtime_written": False, "addon_changed": False},
    }
    paths["report"].write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
