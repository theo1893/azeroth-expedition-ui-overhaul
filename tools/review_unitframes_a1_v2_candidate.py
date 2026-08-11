#!/usr/bin/env python3
"""Review-only processor for UF-A1 V2 cap and rail production sheets.

The script performs only the deterministic operations authorized by the V2
contract.  Every output stays under ignored ``generated/`` and is neither an
accepted source nor addon runtime media.
"""

from __future__ import annotations

import argparse
from collections import deque
import hashlib
import json
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFont

from review_unitframes_primary_candidate_v1 import (
    CHAT_SOURCE,
    FONT,
    TITLE_FONT,
    checkerboard,
    clear_transparent_rgb,
    connected_chroma_key,
    fit_role,
    paste_unit_frame,
)


ROOT = Path(__file__).resolve().parents[1]
CANVAS = (1536, 1024)
SCALES = (0.64, 0.71, 0.80, 0.90, 1.00, 1.15)

SEGMENTS: dict[str, dict[str, Any]] = {
    "V2-A": {
        "target": (7, 42),
        "roles": (
            ("player-left-cap", (0, 0, 384, 1024), 128),
            ("player-right-cap", (384, 0, 768, 1024), 128),
            ("target-left-cap", (768, 0, 1152, 1024), 128),
            ("target-right-cap", (1152, 0, 1536, 1024), 128),
        ),
    },
    "V2-B": {
        "target": (200, 6),
        "roles": (
            ("player-top-rail", (0, 0, 1536, 256), (168, 110)),
            ("player-bottom-rail", (0, 256, 1536, 512), (168, 110)),
            ("target-top-rail", (0, 512, 1536, 768), (168, 110)),
            ("target-bottom-rail", (0, 768, 1536, 1024), (168, 110)),
        ),
    },
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--segment", choices=tuple(SEGMENTS), required=True)
    parser.add_argument("--raw", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument(
        "--caps-dir",
        type=Path,
        help="review-only V2-A component directory used to assemble V2-B previews",
    )
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


def component_metrics(image: Image.Image) -> dict[str, Any]:
    """Count eight-connected runtime components without adding dependencies."""
    mask = np.asarray(image.convert("RGBA"))[:, :, 3] >= 32
    height, width = mask.shape
    visited = np.zeros_like(mask, dtype=bool)
    sizes: list[int] = []
    for y in range(height):
        for x in range(width):
            if not mask[y, x] or visited[y, x]:
                continue
            queue: deque[tuple[int, int]] = deque([(x, y)])
            visited[y, x] = True
            size = 0
            while queue:
                px, py = queue.popleft()
                size += 1
                for ny in range(max(0, py - 1), min(height, py + 2)):
                    for nx in range(max(0, px - 1), min(width, px + 2)):
                        if mask[ny, nx] and not visited[ny, nx]:
                            visited[ny, nx] = True
                            queue.append((nx, ny))
            sizes.append(size)
    sizes.sort(reverse=True)
    visible = int(mask.sum())
    major = sum(size >= max(2, (sizes[0] * 0.02 if sizes else 2)) for size in sizes)
    largest_fraction = sizes[0] / visible if visible and sizes else 0.0
    return {
        "visible_alpha32_pixels": visible,
        "component_sizes_alpha32": sizes,
        "major_component_count": major,
        "largest_component_fraction": round(largest_fraction, 6),
        "single_physical_mass_pass": major == 1 and largest_fraction >= 0.85,
    }


def contact_metrics(segment: str, role: str, part: Image.Image) -> dict[str, Any]:
    alpha = np.asarray(part.convert("RGBA"))[:, :, 3] >= 32
    if segment == "V2-A":
        inner = alpha[:, -2:] if "left-cap" in role else alpha[:, :2]
        top = float(inner[:7].mean())
        bottom = float(inner[-7:].mean())
        passed = top >= 0.25 and bottom >= 0.25
        return {
            "interface": "inner-edge upper/lower rail contacts",
            "top_coverage": round(top, 6),
            "bottom_coverage": round(bottom, 6),
            "threshold": 0.25,
            "contact_pass": passed,
        }
    left = float(alpha[:, :4].mean())
    right = float(alpha[:, -4:].mean())
    return {
        "interface": "first/last four runtime columns",
        "left_coverage": round(left, 6),
        "right_coverage": round(right, 6),
        "threshold": 0.35,
        "contact_pass": left >= 0.35 and right >= 0.35,
    }


def fallback_rail(top: bool) -> Image.Image:
    image = Image.new("RGBA", (200, 6), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")
    base = (67, 42, 27, 255) if top else (47, 29, 20, 255)
    draw.rectangle((0, 1 if top else 0, 199, 5 if top else 4), fill=base)
    draw.line((0, 1, 199, 1), fill=(118, 76, 39, 180))
    return image


def fallback_cap(left: bool) -> Image.Image:
    image = Image.new("RGBA", (7, 42), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")
    box = (1, 0, 6, 41) if left else (0, 0, 5, 41)
    draw.rectangle(box, fill=(57, 35, 23, 255), outline=(112, 72, 37, 255))
    return image


def load_parts(directory: Path, names: tuple[str, ...]) -> dict[str, Image.Image]:
    result: dict[str, Image.Image] = {}
    for name in names:
        path = directory / f"{name}.png"
        if not path.is_file():
            raise ValueError(f"missing review component: {path}")
        result[name] = Image.open(path).convert("RGBA")
    return result


def role_parts(
    segment: str,
    current: dict[str, Image.Image],
    caps_dir: Path | None,
) -> tuple[dict[str, Image.Image], dict[str, str]]:
    if segment == "V2-A":
        parts = dict(current)
        parts.update({
            "player-top-rail": fallback_rail(True),
            "player-bottom-rail": fallback_rail(False),
            "target-top-rail": fallback_rail(True),
            "target-bottom-rail": fallback_rail(False),
        })
        return parts, {"caps": "candidate", "rails": "deterministic non-authoritative fallback"}
    if caps_dir is None:
        caps = {
            "player-left-cap": fallback_cap(True),
            "player-right-cap": fallback_cap(False),
            "target-left-cap": fallback_cap(True),
            "target-right-cap": fallback_cap(False),
        }
        cap_scope = "deterministic non-authoritative fallback"
    else:
        caps = load_parts(caps_dir, (
            "player-left-cap", "player-right-cap", "target-left-cap", "target-right-cap"
        ))
        cap_scope = "internally passed V2-A review candidate; not accepted source"
    parts = dict(current)
    parts.update(caps)
    return parts, {"caps": cap_scope, "rails": "candidate"}


def assemble_standard(parts: dict[str, Image.Image], role: str) -> Image.Image:
    shell = Image.new("RGBA", (214, 42), (0, 0, 0, 0))
    shell.alpha_composite(parts[f"{role}-top-rail"], (7, 0))
    shell.alpha_composite(parts[f"{role}-bottom-rail"], (7, 36))
    shell.alpha_composite(parts[f"{role}-left-cap"], (0, 0))
    shell.alpha_composite(parts[f"{role}-right-cap"], (207, 0))
    return clear_transparent_rgb(shell)


def assemble_variable(parts: dict[str, Image.Image], role: str, width: int) -> Image.Image:
    shell = Image.new("RGBA", (width + 14, 42), (0, 0, 0, 0))
    top = parts[f"{role}-top-rail"].resize((width, 6), Image.Resampling.BILINEAR)
    bottom = parts[f"{role}-bottom-rail"].resize((width, 6), Image.Resampling.BILINEAR)
    band = Image.new("RGBA", (width + 2, 42), (0, 0, 0, 0))
    band.alpha_composite(top.crop((0, 0, 1, 6)), (0, 0))
    band.alpha_composite(top, (1, 0))
    band.alpha_composite(top.crop((width - 1, 0, width, 6)), (width + 1, 0))
    band.alpha_composite(bottom.crop((0, 0, 1, 6)), (0, 36))
    band.alpha_composite(bottom, (1, 36))
    band.alpha_composite(bottom.crop((width - 1, 0, width, 6)), (width + 1, 36))
    shell.alpha_composite(band, (6, 0))
    shell.alpha_composite(parts[f"{role}-left-cap"], (0, 0))
    shell.alpha_composite(parts[f"{role}-right-cap"], (width + 7, 0))
    return clear_transparent_rgb(shell)


def assembly_metrics(parts: dict[str, Image.Image], role: str) -> dict[str, Any]:
    standard = assemble_standard(parts, role)
    alpha = np.asarray(standard)[:, :, 3]
    safe_intrusion = int((alpha[6:36, 7:207] > 0).sum())
    cap_left = np.asarray(parts[f"{role}-left-cap"])[:, :, 3] >= 32
    cap_right = np.asarray(parts[f"{role}-right-cap"])[:, :, 3] >= 32
    top = np.asarray(parts[f"{role}-top-rail"])[:, :, 3] >= 32
    bottom = np.asarray(parts[f"{role}-bottom-rail"])[:, :, 3] >= 32
    joint_rows = {
        "top-left": int((cap_left[:6, -1] & top[:, 0]).sum()),
        "top-right": int((cap_right[:6, 0] & top[:, -1]).sum()),
        "bottom-left": int((cap_left[-6:, -1] & bottom[:, 0]).sum()),
        "bottom-right": int((cap_right[-6:, 0] & bottom[:, -1]).sum()),
    }
    variables: dict[str, Any] = {}
    for width in (160, 200, 240):
        item = assemble_variable(parts, role, width)
        item_alpha = np.asarray(item)[:, :, 3]
        variables[str(width)] = {
            "size": list(item.size),
            "content_safe_visible_alpha_pixels": int((item_alpha[6:36, 7:width + 7] > 0).sum()),
        }
    return {
        "standard_size": list(standard.size),
        "standard_content_safe_visible_alpha_pixels": safe_intrusion,
        "joint_connected_rows_of_6": joint_rows,
        "joint_pass": min(joint_rows.values()) >= 2,
        "variable_widths": variables,
        "assembly_pass": safe_intrusion == 0
        and min(joint_rows.values()) >= 2
        and all(item["content_safe_visible_alpha_pixels"] == 0 for item in variables.values()),
    }


def render_contact(parts: dict[str, Image.Image], output: Path, segment: str) -> None:
    board = checkerboard((1320, 650), 16)
    draw = ImageDraw.Draw(board, "RGBA")
    title = ImageFont.truetype(str(TITLE_FONT), 24)
    body = ImageFont.truetype(str(FONT), 14)
    draw.rectangle((0, 0, 1320, 72), fill=(22, 19, 16, 246))
    draw.text((28, 22), f"UF-A1 {segment} · deterministic keyed components", font=title, fill=(222, 192, 132, 255))
    x = 48
    y = 110
    for name, part in parts.items():
        scale = 8 if segment == "V2-A" else 4
        zoom = part.resize((part.width * scale, part.height * scale), Image.Resampling.NEAREST)
        if x + zoom.width > 1270:
            x = 48
            y += 250
        board.alpha_composite(zoom, (x, y))
        draw.text((x, y + zoom.height + 10), f"{name} · {part.width}×{part.height}", font=body, fill=(226, 213, 182, 255))
        x += zoom.width + 70
    output.parent.mkdir(parents=True, exist_ok=True)
    board.save(output, format="PNG", optimize=False, compress_level=9)


def render_real_layout(
    parts: dict[str, Image.Image],
    scope: dict[str, str],
    output: Path,
    segment: str,
) -> None:
    image = Image.new("RGBA", (1600, 900), (14, 17, 19, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    for y in range(90, 760, 48):
        for x in range(-24 + (y // 48 % 2) * 22, 1600, 92):
            draw.rectangle((x, y, x + 86, y + 42), fill=(24, 27, 28, 255), outline=(35, 35, 32, 255), width=2)
    title = ImageFont.truetype(str(TITLE_FONT), 24)
    note = ImageFont.truetype(str(FONT), 13)
    draw.text((35, 24), f"UF-A1 {segment} · 100% runtime real-layout preview", font=title, fill=(222, 191, 128, 255))
    draw.text((37, 60), f"Caps: {scope['caps']}; rails: {scope['rails']}. Bars/text use provider geometry.", font=note, fill=(177, 166, 146, 255))
    player = assemble_standard(parts, "player")
    target = assemble_standard(parts, "target")
    paste_unit_frame(image, player, 48, 138, (214, 42), (200, 25), 4, "纳斯雷兹姆 60", "5234 / 5234", 0.82, (78, 128, 59), (48, 89, 151), None, None)
    paste_unit_frame(image, target, 805, 138, (214, 42), (200, 25), 4, "黑石勇士 60+", "74%", 0.74, (139, 50, 42), (87, 49, 116), None, None)
    draw.rectangle((801, 134, 1023, 184), outline=(138, 54, 40, 160), width=2)
    for index in range(5):
        ax = 805 + index * 27
        draw.rectangle((ax, 188, ax + 22, 210), fill=(49, 38, 28, 255), outline=(110, 78, 41, 255))
    if CHAT_SOURCE.exists():
        chat = Image.open(CHAT_SOURCE).convert("RGBA")
        chat.thumbnail((365, 235), Image.Resampling.LANCZOS)
        image.alpha_composite(chat, (25, 645))
    for index in range(12):
        x = 510 + index * 43
        draw.rectangle((x, 822, x + 38, 860), fill=(43, 34, 25, 255), outline=(111, 82, 43, 255), width=2)
        draw.rectangle((x + 5, 827, x + 33, 855), fill=((44 + index * 11) % 120, 49, 74, 255))
    draw.text((1120, 842), "Chat is current accepted source; action bar remains an explicit fallback.", font=note, fill=(154, 142, 124, 255))
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, format="PNG", optimize=False, compress_level=9)


def render_scale_preview(parts: dict[str, Image.Image], output: Path, scope: dict[str, str]) -> None:
    board = checkerboard((1500, 930), 12)
    draw = ImageDraw.Draw(board, "RGBA")
    title = ImageFont.truetype(str(TITLE_FONT), 23)
    body = ImageFont.truetype(str(FONT), 12)
    draw.rectangle((0, 0, 1500, 76), fill=(21, 18, 15, 246))
    draw.text((28, 18), "UF-A1 V2 · standard single-shell scale and variable-width preview", font=title, fill=(222, 191, 128, 255))
    draw.text((30, 50), f"Caps: {scope['caps']}; rails: {scope['rails']}", font=body, fill=(178, 166, 144, 255))
    y = 105
    for role in ("player", "target"):
        standard = assemble_standard(parts, role)
        draw.text((28, y + 12), role.upper(), font=body, fill=(231, 218, 187, 255))
        x = 125
        for scale in SCALES:
            size = (round(214 * scale), round(42 * scale))
            scaled = standard.resize(size, Image.Resampling.BILINEAR)
            board.alpha_composite(scaled, (x, y))
            draw.text((x, y + size[1] + 6), f"{scale:.2f}× {size[0]}×{size[1]}", font=body, fill=(205, 192, 166, 255))
            x += max(180, size[0] + 26)
        y += 145
    for role in ("player", "target"):
        draw.text((28, y + 12), f"{role.upper()} WIDTHS", font=body, fill=(231, 218, 187, 255))
        x = 170
        for width in (160, 200, 240):
            shell = assemble_variable(parts, role, width)
            board.alpha_composite(shell, (x, y))
            draw.text((x, y + 52), f"W={width} · {shell.width}×42", font=body, fill=(205, 192, 166, 255))
            x += shell.width + 100
        y += 150
    output.parent.mkdir(parents=True, exist_ok=True)
    board.save(output, format="PNG", optimize=False, compress_level=9)


def main() -> None:
    args = parse_args()
    raw_path = args.raw.resolve()
    output_dir = args.output_dir.resolve()
    component_dir = output_dir / "components"
    component_dir.mkdir(parents=True, exist_ok=True)
    raw = Image.open(raw_path)
    if raw.size != CANVAS:
        raise ValueError(f"expected canvas {CANVAS}, got {raw.size}")

    config = SEGMENTS[args.segment]
    current: dict[str, Image.Image] = {}
    role_reports: list[dict[str, Any]] = []
    for name, cell_box, required in config["roles"]:
        cell = raw.crop(cell_box)
        keyed, key_metrics = connected_chroma_key(cell, include_center=False)
        fitted, fit_metrics = fit_role(keyed, config["target"])
        bbox = fit_metrics["keyed_bbox_exclusive"]
        isolation = {
            "left": bbox[0],
            "top": bbox[1],
            "right": cell.width - bbox[2],
            "bottom": cell.height - bbox[3],
        }
        if args.segment == "V2-A":
            isolation_pass = min(isolation.values()) >= required
            isolation_contract: Any = required
        else:
            horizontal, vertical = required
            isolation_pass = min(isolation["left"], isolation["right"]) >= horizontal and min(isolation["top"], isolation["bottom"]) >= vertical
            isolation_contract = {"horizontal": horizontal, "vertical": vertical}
        components = component_metrics(fitted)
        contacts = contact_metrics(args.segment, name, fitted)
        role_pass = bool(fit_metrics["ratio_contract_pass"] and isolation_pass and components["single_physical_mass_pass"] and contacts["contact_pass"])
        path = component_dir / f"{name}.png"
        fitted.save(path, format="PNG", optimize=False, compress_level=9)
        current[name] = fitted
        role_reports.append({
            "id": name,
            "cell": list(cell_box),
            "target_size": list(config["target"]),
            "isolation_margins": isolation,
            "required_isolation": isolation_contract,
            "isolation_pass": isolation_pass,
            "output": str(path),
            "output_sha256": sha256(path),
            "pass": role_pass,
            **key_metrics,
            **fit_metrics,
            **components,
            **contacts,
        })

    parts, scope = role_parts(args.segment, current, args.caps_dir.resolve() if args.caps_dir else None)
    contact_path = output_dir / "technical-contact.png"
    layout_path = output_dir / "real-layout-preview.png"
    scale_path = output_dir / "scale-width-preview.png"
    render_contact(current, contact_path, args.segment)
    render_real_layout(parts, scope, layout_path, args.segment)
    render_scale_preview(parts, scale_path, scope)

    assembly = {role: assembly_metrics(parts, role) for role in ("player", "target")}
    segment_pass = all(item["pass"] for item in role_reports)
    if args.segment == "V2-B" and args.caps_dir is not None:
        segment_pass = segment_pass and all(item["assembly_pass"] for item in assembly.values())
    report = {
        "schema": "aeui-unitframes-a1-v2-candidate-review-v1",
        "segment": args.segment,
        "raw": str(raw_path),
        "raw_sha256": sha256(raw_path),
        "raw_size": list(raw.size),
        "raw_mode": raw.mode,
        "deterministic_operations": [
            "fixed-region split",
            "edge-connected chroma key",
            "one-pixel despill",
            "transparent RGB clear",
            "proportional bbox fit without non-uniform scaling",
            "standard-width single-shell review assembly",
            "variable-width three-slice review assembly",
            "100-percent real-layout preview",
            "scale and variable-width preview",
        ],
        "preview_scope": scope,
        "roles": role_reports,
        "assembly": assembly,
        "technical_contact": str(contact_path),
        "technical_contact_sha256": sha256(contact_path),
        "real_layout_preview": str(layout_path),
        "real_layout_preview_sha256": sha256(layout_path),
        "scale_width_preview": str(scale_path),
        "scale_width_preview_sha256": sha256(scale_path),
        "overall_technical_pass": segment_pass,
        "visual_review_required": True,
        "may_be_source": False,
        "may_be_runtime": False,
    }
    report_path = output_dir / "review-report.json"
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(report_path)
    print(contact_path)
    print(layout_path)
    print(scale_path)


if __name__ == "__main__":
    main()
