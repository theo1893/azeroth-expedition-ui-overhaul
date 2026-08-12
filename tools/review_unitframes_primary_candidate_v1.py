#!/usr/bin/env python3
"""Deterministically key, fit, and preview UF-PRIMARY production candidates.

Outputs are review-only ignored artifacts. They are never source or runtime media.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[1]
GREEN = np.array((0, 255, 0), dtype=np.uint8)
FONT = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"
TITLE_FONT = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"
CHAT_SOURCE = ROOT / "assets/source/chat/frame-full-v1/ChatBookFrame_Full_V1_r1.png"

BATCHES: dict[str, dict[str, Any]] = {
    "A1": {
        "canvas": (1536, 1024),
        "cell_margin": 96,
        "roles": [
            {"id": "player", "cell": (0, 0, 1536, 512), "target": (214, 42), "safe": (7, 6, 207, 36)},
            {"id": "target", "cell": (0, 512, 1536, 1024), "target": (214, 42), "safe": (7, 6, 207, 36)},
        ],
    },
    "A2": {
        "canvas": (1024, 1024),
        "cell_margin": 72,
        "roles": [
            {"id": "targettarget", "cell": (0, 0, 1024, 512), "target": (112, 34), "safe": (6, 6, 106, 28)},
            {"id": "focus", "cell": (0, 512, 1024, 1024), "target": (112, 39), "safe": (6, 6, 106, 33)},
        ],
    },
    "B1": {
        "canvas": (1024, 1024),
        "cell_margin": 80,
        "roles": [
            {"id": "health", "cell": (0, 0, 1024, 512), "target": (64, 32), "safe": None},
            {"id": "power", "cell": (0, 512, 1024, 1024), "target": (64, 16), "safe": None},
        ],
    },
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--batch", choices=sorted(BATCHES), required=True)
    parser.add_argument("--raw", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--context-dir", type=Path, action="append", default=[])
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    alpha = np.asarray(image.convert("RGBA"))[:, :, 3]
    ys, xs = np.where(alpha > 0)
    if not len(xs):
        return None
    return int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    array = np.asarray(image.convert("RGBA")).copy()
    array[array[:, :, 3] == 0, :3] = 0
    return Image.fromarray(array, "RGBA")


def connected_chroma_key(raw: Image.Image, include_center: bool) -> tuple[Image.Image, dict[str, Any]]:
    """Remove green connected to outer edges and, for shells, the declared centre hole."""
    rgb = np.asarray(raw.convert("RGB")).copy()
    red = rgb[:, :, 0].astype(np.int16)
    green = rgb[:, :, 1].astype(np.int16)
    blue = rgb[:, :, 2].astype(np.int16)
    score = green - np.maximum(red, blue)
    chroma = (green >= 95) & (score >= 28)
    flood = Image.fromarray(np.where(chroma, 0, 255).astype(np.uint8), "L").copy()
    width, height = raw.size
    edge_seeds: list[tuple[int, int]] = []
    pixels = np.asarray(flood)
    for x in range(width):
        if pixels[0, x] == 0:
            edge_seeds.append((x, 0))
            break
        if pixels[height - 1, x] == 0:
            edge_seeds.append((x, height - 1))
            break
    for y in range(height):
        if pixels[y, 0] == 0:
            edge_seeds.append((0, y))
            break
        if pixels[y, width - 1] == 0:
            edge_seeds.append((width - 1, y))
            break
    if not edge_seeds:
        raise ValueError("no edge-connected chroma seed found")
    for seed in edge_seeds:
        if flood.getpixel(seed) == 0:
            ImageDraw.floodfill(flood, seed, 128, thresh=0)
    edge_connected = np.asarray(flood) == 128

    center_connected = np.zeros((height, width), dtype=bool)
    center_seed = (width // 2, height // 2)
    if include_center and flood.getpixel(center_seed) == 0:
        ImageDraw.floodfill(flood, center_seed, 64, thresh=0)
        center_connected = np.asarray(flood) == 64

    removed = edge_connected | center_connected
    alpha = np.where(removed, 0, 255).astype(np.uint8)
    removed_mask = Image.fromarray((removed * 255).astype(np.uint8), "L")
    ring = np.asarray(removed_mask.filter(ImageFilter.MaxFilter(3))) > 0
    ring &= ~removed
    rgb[:, :, 1][ring] = np.minimum(
        rgb[:, :, 1][ring],
        np.maximum(rgb[:, :, 0][ring], rgb[:, :, 2][ring]),
    )
    rgb[alpha == 0] = 0
    keyed = clear_transparent_rgb(Image.fromarray(np.dstack((rgb, alpha)), "RGBA"))
    exact_green = np.all(np.asarray(raw.convert("RGB")) == GREEN, axis=2)
    return keyed, {
        "chroma_predicate_pixels": int(chroma.sum()),
        "edge_connected_removed_pixels": int(edge_connected.sum()),
        "center_connected_removed_pixels": int(center_connected.sum()),
        "source_exact_00ff00_pixels": int(exact_green.sum()),
        "center_seed_removed": bool(center_connected[center_seed[1], center_seed[0]]) if include_center else None,
    }


def fit_role(keyed: Image.Image, target: tuple[int, int]) -> tuple[Image.Image, dict[str, Any]]:
    bbox = alpha_bbox(keyed)
    if bbox is None:
        raise ValueError("candidate has no visible object after chroma key")
    crop = clear_transparent_rgb(keyed.crop(bbox))
    source_ratio = crop.width / crop.height
    target_ratio = target[0] / target[1]
    ratio_error = abs(source_ratio - target_ratio) / target_ratio * 100.0
    scale = min(target[0] / crop.width, target[1] / crop.height)
    fitted_size = (max(1, round(crop.width * scale)), max(1, round(crop.height * scale)))
    fitted = crop.resize(fitted_size, Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", target, (0, 0, 0, 0))
    offset = ((target[0] - fitted.width) // 2, (target[1] - fitted.height) // 2)
    canvas.alpha_composite(fitted, offset)
    return clear_transparent_rgb(canvas), {
        "keyed_bbox_exclusive": list(bbox),
        "keyed_bbox_size": [crop.width, crop.height],
        "source_ratio": round(source_ratio, 6),
        "target_ratio": round(target_ratio, 6),
        "ratio_error_percent": round(ratio_error, 6),
        "ratio_contract_pass": ratio_error <= 1.0,
        "fitted_size": list(fitted_size),
        "fit_offset": list(offset),
        "non_uniform_scaling": False,
    }


def checkerboard(size: tuple[int, int], step: int = 12) -> Image.Image:
    image = Image.new("RGBA", size, (61, 58, 53, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], step):
        for x in range(0, size[0], step):
            if (x // step + y // step) % 2:
                draw.rectangle((x, y, x + step - 1, y + step - 1), fill=(88, 83, 75, 255))
    return image


def tint_donor(donor: Image.Image | None, size: tuple[int, int], color: tuple[int, int, int]) -> Image.Image:
    if donor is None:
        return Image.new("RGBA", size, color + (255,))
    gray = donor.convert("L").resize(size, Image.Resampling.BILINEAR)
    tinted = ImageOps.colorize(gray, black=(12, 10, 8), white=color).convert("RGBA")
    return tinted


def paste_unit_frame(
    image: Image.Image,
    shell: Image.Image | None,
    x: int,
    y: int,
    outer: tuple[int, int],
    hp: tuple[int, int],
    power_height: int,
    name: str,
    value: str,
    health_fraction: float,
    health_color: tuple[int, int, int],
    power_color: tuple[int, int, int],
    health_donor: Image.Image | None,
    power_donor: Image.Image | None,
) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    margin_x = (outer[0] - hp[0]) // 2
    top = 6
    gap = 1
    hp_base = Image.new("RGBA", hp, (26, 19, 14, 255))
    fill_width = max(1, round(hp[0] * health_fraction))
    hp_fill = tint_donor(health_donor, (fill_width, hp[1]), health_color)
    hp_base.alpha_composite(hp_fill, (0, 0))
    image.alpha_composite(hp_base, (x + margin_x, y + top))
    py = y + top + hp[1] + gap
    power_base = Image.new("RGBA", (hp[0], max(1, power_height)), (20, 15, 13, 255))
    power_fill = tint_donor(power_donor, power_base.size, power_color)
    power_base.alpha_composite(power_fill, (0, 0))
    image.alpha_composite(power_base, (x + margin_x, py))
    if shell is None:
        draw.rectangle((x, y, x + outer[0] - 1, y + outer[1] - 1), outline=(121, 91, 54, 255), width=2)
    else:
        image.alpha_composite(shell, (x, y))
    font = ImageFont.truetype(str(FONT), 11)
    draw.text((x + margin_x + 5, y + top + hp[1] // 2), name, font=font, fill=(236, 220, 181, 255), anchor="lm")
    draw.text((x + margin_x + hp[0] - 5, y + top + hp[1] // 2), value, font=font, fill=(241, 226, 188, 255), anchor="rm")


def load_context(current: dict[str, Image.Image], context_dirs: list[Path]) -> dict[str, Image.Image]:
    result: dict[str, Image.Image] = {}
    for directory in context_dirs:
        for role in ("player", "target", "targettarget", "focus", "health", "power"):
            path = directory.resolve() / f"{role}.png"
            if path.exists():
                result[role] = Image.open(path).convert("RGBA")
    result.update(current)
    return result


def render_contact(processed: dict[str, Image.Image], output: Path) -> None:
    image = checkerboard((1200, 520), 16)
    draw = ImageDraw.Draw(image, "RGBA")
    title = ImageFont.truetype(str(TITLE_FONT), 24)
    body = ImageFont.truetype(str(FONT), 14)
    draw.rectangle((0, 0, 1200, 70), fill=(22, 19, 16, 245))
    draw.text((28, 22), "UF-PRIMARY candidate · deterministic keyed runtime parts", font=title, fill=(222, 192, 132, 255))
    x, y = 40, 110
    for index, (role, part) in enumerate(processed.items()):
        scale = min(4, max(1, 450 // max(part.width, 1)))
        zoom = part.resize((part.width * scale, part.height * scale), Image.Resampling.NEAREST)
        if index and x + zoom.width > 1160:
            x, y = 40, y + 190
        image.alpha_composite(zoom, (x, y))
        draw.text((x, y + zoom.height + 10), f"{role} · {part.width}×{part.height} · {scale}× nearest preview", font=body, fill=(225, 212, 182, 255))
        x += zoom.width + 80
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, format="PNG", optimize=False, compress_level=9)


def render_real_layout(parts: dict[str, Image.Image], output: Path, batch: str) -> None:
    image = Image.new("RGBA", (1600, 900), (14, 17, 19, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    for y in range(90, 760, 48):
        for x in range(-24 + (y // 48 % 2) * 22, 1600, 92):
            draw.rectangle((x, y, x + 86, y + 42), fill=(24, 27, 28, 255), outline=(35, 35, 32, 255), width=2)
    title = ImageFont.truetype(str(TITLE_FONT), 24)
    note = ImageFont.truetype(str(FONT), 13)
    draw.text((35, 24), f"UF-{batch} production candidate · 100% runtime layout", font=title, fill=(222, 191, 128, 255))
    draw.text((37, 60), "Unit-frame pixels and bar geometry are exact; screen anchors and unfinished neighbours remain non-authoritative.", font=note, fill=(177, 166, 146, 255))

    paste_unit_frame(image, parts.get("player"), 48, 138, (214, 42), (200, 25), 4, "纳斯雷兹姆 60", "5234 / 5234", 0.82, (78, 128, 59), (48, 89, 151), parts.get("health"), parts.get("power"))
    paste_unit_frame(image, parts.get("target"), 805, 138, (214, 42), (200, 25), 4, "黑石勇士 60+", "74%", 0.74, (139, 50, 42), (87, 49, 116), parts.get("health"), parts.get("power"))
    paste_unit_frame(image, parts.get("targettarget"), 912, 312, (112, 34), (100, 20), 1, "治疗者", "91%", 0.91, (65, 116, 59), (45, 74, 123), parts.get("health"), parts.get("power"))
    paste_unit_frame(image, parts.get("focus"), 912, 407, (112, 39), (100, 25), 1, "控场目标", "63%", 0.63, (127, 75, 46), (51, 82, 128), parts.get("health"), parts.get("power"))

    if CHAT_SOURCE.exists():
        chat = Image.open(CHAT_SOURCE).convert("RGBA")
        chat.thumbnail((365, 235), Image.Resampling.LANCZOS)
        image.alpha_composite(chat, (25, 645))
    for index in range(12):
        x = 510 + index * 43
        draw.rectangle((x, 822, x + 38, 860), fill=(43, 34, 25, 255), outline=(111, 82, 43, 255), width=2)
        draw.rectangle((x + 5, 827, x + 33, 855), fill=((44 + index * 11) % 120, 49, 74, 255))
    draw.polygon([(460, 860), (493, 822), (506, 843), (492, 881)], fill=(92, 68, 37, 255), outline=(131, 95, 46, 255))
    draw.polygon([(1026, 843), (1040, 822), (1072, 860), (1040, 881)], fill=(92, 68, 37, 255), outline=(131, 95, 46, 255))
    draw.text((1145, 842), "Current Chat source; action bar is an explicit fallback placeholder", font=note, fill=(154, 142, 124, 255))
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, format="PNG", optimize=False, compress_level=9)


def main() -> None:
    args = parse_args()
    contract = BATCHES[args.batch]
    raw_path = args.raw.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    raw = Image.open(raw_path)
    if raw.size != contract["canvas"]:
        raise ValueError(f"expected canvas {contract['canvas']}, got {raw.size}")

    processed: dict[str, Image.Image] = {}
    role_reports: list[dict[str, Any]] = []
    for role in contract["roles"]:
        cell = raw.crop(role["cell"])
        keyed, key_metrics = connected_chroma_key(cell, include_center=args.batch in {"A1", "A2"})
        fitted, fit_metrics = fit_role(keyed, role["target"])
        bbox = fit_metrics["keyed_bbox_exclusive"]
        cell_width = role["cell"][2] - role["cell"][0]
        cell_height = role["cell"][3] - role["cell"][1]
        isolation = {
            "left": bbox[0],
            "top": bbox[1],
            "right": cell_width - bbox[2],
            "bottom": cell_height - bbox[3],
        }
        safe_alpha_pixels = None
        if role["safe"] is not None:
            alpha = np.asarray(fitted)[:, :, 3]
            x0, y0, x1, y1 = role["safe"]
            safe_alpha_pixels = int((alpha[y0:y1, x0:x1] > 0).sum())
        color_cast_mean = None
        if args.batch == "B1":
            rgb = np.asarray(keyed.convert("RGB"), dtype=np.int16)
            alpha = np.asarray(keyed)[:, :, 3] > 0
            visible = rgb[alpha]
            color_cast_mean = float(np.abs(visible - visible.mean(axis=1, keepdims=True)).mean()) if len(visible) else 999.0
        role_pass = (
            fit_metrics["ratio_contract_pass"]
            and min(isolation.values()) >= contract["cell_margin"]
            and (safe_alpha_pixels in (None, 0))
            and (key_metrics["center_seed_removed"] in (None, True))
            and (color_cast_mean is None or color_cast_mean <= 3.0)
        )
        part_path = output_dir / f"{role['id']}.png"
        fitted.save(part_path, format="PNG", optimize=False, compress_level=9)
        processed[role["id"]] = fitted
        role_reports.append({
            "id": role["id"],
            "cell": list(role["cell"]),
            "target_size": list(role["target"]),
            "safe_zone": list(role["safe"]) if role["safe"] else None,
            "safe_zone_visible_alpha_pixels": safe_alpha_pixels,
            "isolation_margins": isolation,
            "required_isolation": contract["cell_margin"],
            "color_cast_mean": round(color_cast_mean, 6) if color_cast_mean is not None else None,
            "output": str(part_path),
            "output_sha256": sha256(part_path),
            "pass": role_pass,
            **key_metrics,
            **fit_metrics,
        })

    contact = output_dir.parent / "technical-contact.png"
    preview = output_dir.parent / "real-layout-preview.png"
    render_contact(processed, contact)
    context = load_context(processed, args.context_dir)
    render_real_layout(context, preview, args.batch)
    report = {
        "schema": "aeui-unitframes-candidate-review-v1",
        "batch": args.batch,
        "raw": str(raw_path),
        "raw_sha256": sha256(raw_path),
        "raw_size": list(raw.size),
        "raw_mode": raw.mode,
        "deterministic_operations": [
            "fixed-cell split",
            "connected chroma key from outer edge and declared shell content corridor",
            "one-pixel despill",
            "transparent RGB clear",
            "proportional bbox fit without non-uniform scaling",
            "100-percent runtime real-layout preview",
        ],
        "roles": role_reports,
        "technical_contact": str(contact),
        "technical_contact_sha256": sha256(contact),
        "real_layout_preview": str(preview),
        "real_layout_preview_sha256": sha256(preview),
        "overall_technical_pass": all(item["pass"] for item in role_reports),
        "authoritative_scope": "candidate pixels at exact runtime size; provider bar geometry and dynamic content",
        "non_authoritative_scope": "screen anchors and unfinished neighbour fallbacks",
        "may_be_source": False,
        "may_be_runtime": False,
    }
    report_path = output_dir.parent / "review-report.json"
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(report_path)
    print(contact)
    print(preview)


if __name__ == "__main__":
    main()
