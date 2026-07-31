#!/usr/bin/env python3
"""Review one QS-A1 wax-seal candidate in its exact Quest UI geometry."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFont


SOURCE_CANVAS = (1024, 1024)
SOURCE_VISIBLE_TARGET = 640
SOURCE_SAFE_MARGIN = 180
GREEN = np.array((0, 255, 0), dtype=np.uint8)
RESAMPLE = Image.Resampling.LANCZOS


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("raw", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--repo-commit", required=True)
    parser.add_argument("--session-id", required=True)
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size=size)


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    alpha = np.asarray(image.getchannel("A"))
    ys, xs = np.where(alpha > 0)
    if not len(xs):
        return None
    return int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def chroma_key(raw: Image.Image) -> tuple[Image.Image, dict[str, Any]]:
    rgb = np.asarray(raw.convert("RGB")).copy()
    original = rgb.copy()
    red = rgb[:, :, 0].astype(np.int16)
    green = rgb[:, :, 1].astype(np.int16)
    blue = rgb[:, :, 2].astype(np.int16)
    score = green - np.maximum(red, blue)
    background = score >= 45
    alpha = np.clip((45 - score) * (255 / 30), 0, 255).astype(np.uint8)
    alpha[score >= 45] = 0
    alpha[score <= 15] = 255
    partial = (alpha > 0) & (alpha < 255)
    rgb[:, :, 1][partial] = np.minimum(
        rgb[:, :, 1][partial],
        np.maximum(rgb[:, :, 0][partial], rgb[:, :, 2][partial]),
    )
    rgb[alpha == 0] = 0
    keyed = clear_transparent_rgb(Image.fromarray(np.dstack((rgb, alpha)), "RGBA"))
    background_pixels = original[background]
    exact_green = np.all(original == GREEN, axis=2)
    background_unique = (
        len(np.unique(background_pixels, axis=0))
        if len(background_pixels)
        else 0
    )
    metrics: dict[str, Any] = {
        "source_size": list(raw.size),
        "source_mode": raw.mode,
        "source_exact_00ff00_pixels": int(exact_green.sum()),
        "source_background_pixels": int(background.sum()),
        "source_background_exact_ratio": (
            float(exact_green[background].mean())
            if int(background.sum())
            else 0.0
        ),
        "source_background_unique_rgb": int(background_unique),
        "transparent_pixels": int((alpha == 0).sum()),
        "partial_pixels": int(partial.sum()),
        "opaque_pixels": int((alpha == 255).sum()),
        "transparent_bbox": list(alpha_bbox(keyed) or ()),
    }
    return keyed, metrics


def fit_visible(
    keyed: Image.Image,
    canvas: tuple[int, int] = SOURCE_CANVAS,
    visible_target: int = SOURCE_VISIBLE_TARGET,
) -> tuple[Image.Image, dict[str, Any]]:
    bbox = alpha_bbox(keyed)
    if bbox is None:
        raise ValueError("candidate has no visible object after chroma key")
    crop = clear_transparent_rgb(keyed.crop(bbox))
    ratio = min(visible_target / crop.width, visible_target / crop.height)
    size = (
        max(1, round(crop.width * ratio)),
        max(1, round(crop.height * ratio)),
    )
    resized = clear_transparent_rgb(crop.resize(size, RESAMPLE))
    output = Image.new("RGBA", canvas, (0, 0, 0, 0))
    paste = (
        (canvas[0] - resized.width) // 2,
        (canvas[1] - resized.height) // 2,
    )
    output.alpha_composite(resized, paste)
    normalized_bbox = alpha_bbox(output)
    return output, {
        "raw_visible_bbox_exclusive": list(bbox),
        "raw_visible_size": [bbox[2] - bbox[0], bbox[3] - bbox[1]],
        "normalized_visible_bbox_exclusive": list(normalized_bbox or ()),
        "normalized_visible_size": list(size),
        "normalization_scale": ratio,
    }


def source_contract(
    raw: Image.Image,
    metrics: dict[str, Any],
) -> dict[str, Any]:
    bbox = metrics.get("transparent_bbox", [])
    if len(bbox) == 4:
        left, top, right, bottom = bbox
        raw_width = right - left
        raw_height = bottom - top
        raw_margins = [left, top, raw.width - right, raw.height - bottom]
        scale_x = SOURCE_CANVAS[0] / raw.width
        scale_y = SOURCE_CANVAS[1] / raw.height
        canonical_bbox = [
            left * scale_x,
            top * scale_y,
            right * scale_x,
            bottom * scale_y,
        ]
        width = canonical_bbox[2] - canonical_bbox[0]
        height = canonical_bbox[3] - canonical_bbox[1]
        margins = [
            canonical_bbox[0],
            canonical_bbox[1],
            SOURCE_CANVAS[0] - canonical_bbox[2],
            SOURCE_CANVAS[1] - canonical_bbox[3],
        ]
        center_error = [
            abs(
                (canonical_bbox[0] + canonical_bbox[2]) / 2
                - SOURCE_CANVAS[0] / 2
            ),
            abs(
                (canonical_bbox[1] + canonical_bbox[3]) / 2
                - SOURCE_CANVAS[1] / 2
            ),
        ]
    else:
        raw_width = raw_height = width = height = 0
        raw_margins = [0, 0, 0, 0]
        canonical_bbox = []
        margins = [0, 0, 0, 0]
        center_error = [SOURCE_CANVAS[0] / 2, SOURCE_CANVAS[1] / 2]
    exact_background = (
        metrics["source_background_pixels"] > 0
        and metrics["source_background_exact_ratio"] == 1.0
        and metrics["source_background_unique_rgb"] == 1
    )
    checks = {
        "source_canvas_1024_square": raw.size == SOURCE_CANVAS,
        "source_has_one_contiguous_primary_object": width > 0 and height > 0,
        "source_bbox_about_640": (
            576 <= width <= 704 and 576 <= height <= 704
        ),
        "source_safe_margins_at_least_180": min(margins) >= SOURCE_SAFE_MARGIN,
        "source_center_error_at_most_24": max(center_error) <= 24,
        "source_background_exact_00ff00": exact_background,
        "source_not_edge_clipped": min(margins) > 0,
    }
    return {
        "raw_visible_bbox_exclusive": bbox,
        "raw_visible_size": [raw_width, raw_height],
        "raw_safe_margins_ltrb": raw_margins,
        "canonical_1024_bbox_exclusive": canonical_bbox,
        "canonical_1024_visible_size": [width, height],
        "canonical_1024_safe_margins_ltrb": margins,
        "canonical_1024_center_error_xy": center_error,
        "checks": checks,
        "overall": "pass" if all(checks.values()) else "fail",
    }


def load_simulation_module(repo: Path) -> Any:
    path = repo / "tools" / "render_quest_seals_simulation_v1.py"
    spec = importlib.util.spec_from_file_location(
        "aeui_quest_seals_simulation_for_candidate_review",
        path,
    )
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def runtime_sprite(
    normalized: Image.Image,
    visible_size: int,
    state: str = "normal",
) -> Image.Image:
    bbox = alpha_bbox(normalized)
    if bbox is None:
        return Image.new("RGBA", (visible_size, visible_size), (0, 0, 0, 0))
    crop = clear_transparent_rgb(normalized.crop(bbox))
    if state == "hover":
        crop = ImageEnhance.Brightness(crop).enhance(1.12)
        rgba = np.asarray(crop).copy()
        visible = rgba[:, :, 3] > 0
        rgba[:, :, 0][visible] = np.minimum(
            255, rgba[:, :, 0][visible].astype(np.uint16) + 9
        ).astype(np.uint8)
        crop = Image.fromarray(rgba, "RGBA")
    elif state == "pressed":
        crop = ImageEnhance.Brightness(crop).enhance(0.82)
    elif state == "disabled":
        crop = ImageEnhance.Color(crop).enhance(0.25)
        crop = ImageEnhance.Brightness(crop).enhance(0.78)
    ratio = min(visible_size / crop.width, visible_size / crop.height)
    size = (
        max(1, round(crop.width * ratio)),
        max(1, round(crop.height * ratio)),
    )
    return clear_transparent_rgb(crop.resize(size, RESAMPLE))


def install_candidate_renderer(module: Any, normalized: Image.Image) -> None:
    original_dashed = module.dashed_rectangle

    def draw_candidate(
        draw: ImageDraw.ImageDraw,
        box: tuple[int, int, int, int],
        state: str = "normal",
        hitbox: bool = False,
    ) -> None:
        x, y, width, height = box
        target = max(1, min(width, height) - 2)
        sprite = runtime_sprite(normalized, target, state)
        paste_x = x + (width - sprite.width) // 2
        paste_y = y + (height - sprite.height) // 2
        if state == "pressed":
            paste_y += 1
        draw._image.alpha_composite(sprite, (paste_x, paste_y))
        if hitbox:
            original_dashed(
                draw,
                (x - 1, y - 1, x + width, y + height),
                (232, 186, 81, 235),
                width=1,
                dash=3,
            )

    module.draw_seal = draw_candidate


def checker(size: tuple[int, int], block: int = 16) -> Image.Image:
    image = Image.new("RGBA", size, (52, 43, 37, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], block):
        for x in range(0, size[0], block):
            if (x // block + y // block) % 2:
                draw.rectangle(
                    (x, y, x + block - 1, y + block - 1),
                    fill=(81, 70, 60, 255),
                )
    return image


def render_contact_sheet(
    repo: Path,
    raw: Image.Image,
    normalized: Image.Image,
    output: Path,
    attempt: str,
    source_checks: dict[str, Any],
) -> None:
    sheet = Image.new("RGBA", (1536, 900), (35, 27, 22, 255))
    draw = ImageDraw.Draw(sheet, "RGBA")
    title = font(
        repo
        / "addon"
        / "AzerothExpeditionUI"
        / "Media"
        / "Fonts"
        / "NotoSansSC-Medium.ttf",
        22,
    )
    body = font(
        repo
        / "addon"
        / "AzerothExpeditionUI"
        / "Media"
        / "Fonts"
        / "NotoSansSC-Medium.ttf",
        16,
    )
    draw.text((32, 24), f"QS-A1 候选审查 · {attempt}", font=title, fill=(235, 202, 135, 255))
    raw_preview = raw.copy()
    raw_preview.thumbnail((450, 450), RESAMPLE)
    sheet.alpha_composite(raw_preview.convert("RGBA"), (32, 78))
    draw.text((32, 544), "原始输出（未修改）", font=body, fill=(218, 185, 124, 255))

    transparent_panel = checker((450, 450))
    bbox = alpha_bbox(normalized)
    if bbox:
        crop = normalized.crop(bbox)
        crop.thumbnail((390, 390), RESAMPLE)
        transparent_panel.alpha_composite(
            crop,
            (
                (450 - crop.width) // 2,
                (450 - crop.height) // 2,
            ),
        )
    sheet.alpha_composite(transparent_panel, (518, 78))
    draw.text((518, 544), "确定性色键＋640px 归一化预览", font=body, fill=(218, 185, 124, 255))

    sample = Image.new("RGBA", (500, 450), (173, 132, 75, 255))
    sample_draw = ImageDraw.Draw(sample, "RGBA")
    sample_draw.rectangle((0, 0, 499, 449), outline=(71, 40, 24, 255), width=5)
    for index, (label, box_size, visible_size) in enumerate(
        (("Quest Log 28px", 28, 26), ("Tracker 34px", 34, 32))
    ):
        y = 54 + index * 184
        sprite = runtime_sprite(normalized, visible_size)
        x = 62
        sample.alpha_composite(
            sprite,
            (
                x + (box_size - sprite.width) // 2,
                y + (box_size - sprite.height) // 2,
            ),
        )
        zoom = sprite.resize((sprite.width * 8, sprite.height * 8), Image.Resampling.NEAREST)
        sample.alpha_composite(zoom, (190, y - 18))
        sample_draw.rectangle(
            (x, y, x + box_size - 1, y + box_size - 1),
            outline=(232, 186, 81, 255),
            width=1,
        )
        sample_draw.text((62, y + 48), label, font=body, fill=(61, 35, 21, 255))
        sample_draw.text((190, y + 250 if index else y + 220), "", font=body)
    sheet.alpha_composite(sample, (1004, 78))
    draw.text((1004, 544), "真实 1× 尺寸与 8× 最近邻检查", font=body, fill=(218, 185, 124, 255))

    failed = [
        name for name, passed in source_checks["checks"].items() if not passed
    ]
    draw.text(
        (32, 620),
        "机器源合同：" + source_checks["overall"],
        font=title,
        fill=(112, 205, 113, 255)
        if source_checks["overall"] == "pass"
        else (229, 111, 85, 255),
    )
    draw.multiline_text(
        (32, 664),
        "失败项：" + ("、".join(failed) if failed else "无"),
        font=body,
        fill=(211, 184, 132, 255),
        spacing=8,
    )
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output, "PNG", optimize=False, compress_level=9)


def display_region_report(
    repo: Path,
    spec: dict[str, Any],
) -> dict[str, Any]:
    ql = spec["quest_log"]
    shell_overlap = load_simulation_module(repo).visible_shell_alpha_overlap(
        repo,
        spec["inputs"]["quest_log_shell"],
        ql["frame"][2],
        ql["frame"][3],
        ql["seal"]["box"],
        int(ql["seal"].get("alpha_overlap_threshold", 8)),
    )
    tracker = []
    seal_size = int(spec["tracker"]["seal"]["size"])
    top_outset = int(spec["tracker"]["seal"]["top_outset"])
    for width in spec["tracker"]["supported_widths"]:
        box = [
            (int(width) - seal_size) // 2,
            -top_outset,
            seal_size,
            seal_size,
        ]
        tracker.append(
            {
                "width": int(width),
                "hub_seal_box": box,
                "visible_content": [32, 32],
                "horizontally_centered": box[0] * 2 + seal_size
                in (int(width), int(width) - 1),
                "bottom_aligns_with_list_start": box[1] + box[3]
                == int(spec["tracker"]["panel_height"]),
                "overlaps_list": box[1] + box[3]
                > int(spec["tracker"]["panel_height"]),
            }
        )
    checks = {
        "quest_log_box": ql["seal"]["box"],
        "quest_log_visible_content": [26, 26],
        "quest_log_visible_shell_alpha_overlap_pixels": shell_overlap,
        "quest_log_top_outset": 18,
        "tracker_paper_outsets": [0, 0, 0, 0],
        "tracker_seal_top_outset": top_outset,
        "tracker_widths": tracker,
        "screen_top_clamp": "P5 pending; requires Turtle WoW device",
    }
    passed = (
        shell_overlap == 0
        and all(
            item["horizontally_centered"]
            and item["bottom_aligns_with_list_start"]
            and not item["overlaps_list"]
            for item in tracker
        )
    )
    return {
        "schema": "aeui.quest-seal.display-region-report.v1",
        "overall": "pass" if passed else "fail",
        "checks": checks,
    }


def main() -> None:
    args = parse_args()
    repo = args.repo_root.resolve()
    raw_path = args.raw.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    raw = Image.open(raw_path).convert("RGB")
    keyed, pixel_metrics = chroma_key(raw)
    normalized, normalization = fit_visible(keyed)
    source_checks = source_contract(raw, pixel_metrics)

    transparent_path = output_dir / f"{args.attempt}.transparent.png"
    normalized_path = output_dir / f"{args.attempt}.normalized-review.png"
    contact_path = output_dir / f"{args.attempt}.contact-sheet.png"
    ingame_path = output_dir / f"{args.attempt}.real-layout.png"
    contract_path = output_dir / f"{args.attempt}.component-layout.png"
    metrics_path = output_dir / f"{args.attempt}.metrics.json"
    display_path = output_dir / f"{args.attempt}.display-region.json"
    keyed.save(transparent_path, "PNG", optimize=False, compress_level=9)
    normalized.save(normalized_path, "PNG", optimize=False, compress_level=9)

    spec_path = repo / "tools" / "specs" / "quest_seals_simulation_v2.json"
    simulation_spec = json.loads(spec_path.read_text(encoding="utf-8"))
    simulation_spec["version"] = args.attempt
    renderer = load_simulation_module(repo)
    install_candidate_renderer(renderer, normalized)
    renderer.render_ingame(repo, simulation_spec, ingame_path)
    renderer.render_contract(repo, simulation_spec, contract_path)
    render_contact_sheet(
        repo,
        raw,
        normalized,
        contact_path,
        args.attempt,
        source_checks,
    )
    display = display_region_report(repo, simulation_spec)
    display.update(
        {
            "attempt": args.attempt,
            "repo_commit": args.repo_commit,
            "session_id": args.session_id,
            "source_candidate_sha256": sha256(raw_path),
            "outputs": {
                "real_layout": {
                    "path": str(ingame_path.relative_to(repo)),
                    "sha256": sha256(ingame_path),
                },
                "component_layout": {
                    "path": str(contract_path.relative_to(repo)),
                    "sha256": sha256(contract_path),
                },
            },
        }
    )
    display_path.write_text(
        json.dumps(display, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    metrics = {
        "schema": "aeui.quest-seal.candidate-review.v1",
        "attempt": args.attempt,
        "repo_commit": args.repo_commit,
        "session_id": args.session_id,
        "raw": {
            "path": str(raw_path.relative_to(repo)),
            "sha256": sha256(raw_path),
        },
        "pixel_metrics": pixel_metrics,
        "normalization_preview": normalization,
        "source_contract": source_checks,
        "display_region": display["overall"],
        "visual_review": "pending",
        "outputs": {
            "transparent": {
                "path": str(transparent_path.relative_to(repo)),
                "sha256": sha256(transparent_path),
            },
            "normalized_review": {
                "path": str(normalized_path.relative_to(repo)),
                "sha256": sha256(normalized_path),
            },
            "contact_sheet": {
                "path": str(contact_path.relative_to(repo)),
                "sha256": sha256(contact_path),
            },
            "real_layout": {
                "path": str(ingame_path.relative_to(repo)),
                "sha256": sha256(ingame_path),
            },
            "component_layout": {
                "path": str(contract_path.relative_to(repo)),
                "sha256": sha256(contract_path),
            },
            "display_region": {
                "path": str(display_path.relative_to(repo)),
                "sha256": sha256(display_path),
            },
        },
    }
    metrics_path.write_text(
        json.dumps(metrics, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(transparent_path)
    print(normalized_path)
    print(contact_path)
    print(ingame_path)
    print(contract_path)
    print(metrics_path)
    print(display_path)


if __name__ == "__main__":
    main()
