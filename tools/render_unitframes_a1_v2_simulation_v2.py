#!/usr/bin/env python3
"""Render UF-A1 V2 scale-safe runtime simulations without ImageGen.

The production sources remain four independent pieces per role. At the default
width this preview deterministically precomposes one shell texture. At other
widths it simulates a three-slice runtime with a center band below fixed caps.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFont

from render_unitframes_a1_v2_simulation_v1 import piece_layer


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SPEC = ROOT / "tools/specs/unitframes_a1_v2_simulation_v2.json"
BODY_FONT = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"
TITLE_FONT = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=Path, default=DEFAULT_SPEC)
    return parser.parse_args()


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size)


def rgba(value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[index:index + 2], 16) for index in (0, 2, 4)) + (alpha,)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def floor_coord(value: float) -> int:
    return int(math.floor(value + 1e-9))


def ceil_coord(value: float) -> int:
    return int(math.ceil(value - 1e-9))


def outward_box(box: tuple[int, int, int, int], scale: float) -> tuple[int, int, int, int]:
    x0, y0, x1, y1 = box
    return (
        floor_coord(x0 * scale),
        floor_coord(y0 * scale),
        ceil_coord(x1 * scale),
        ceil_coord(y1 * scale),
    )


def inward_box(box: tuple[int, int, int, int], scale: float) -> tuple[int, int, int, int]:
    x0, y0, x1, y1 = box
    return (
        ceil_coord(x0 * scale),
        ceil_coord(y0 * scale),
        floor_coord(x1 * scale),
        floor_coord(y1 * scale),
    )


def source_parts(spec: dict[str, Any], role: str) -> dict[str, Image.Image]:
    """Build independent geometric source stand-ins with robust join contacts."""
    size = (214, 42)
    palette = spec["palette"]
    layers = {
        piece: piece_layer(size, role, piece, palette)
        for piece in ("left_cap", "top_rail", "bottom_rail", "right_cap")
    }
    parts = {
        "left_cap": layers["left_cap"].crop((0, 0, 7, 42)),
        "top_rail": layers["top_rail"].crop((7, 0, 207, 6)),
        "bottom_rail": layers["bottom_rail"].crop((7, 36, 207, 42)),
        "right_cap": layers["right_cap"].crop((207, 0, 214, 42)),
    }

    leather = rgba(palette["leather"])
    leather_mid = rgba(palette["leather_mid"])
    liner = rgba(palette["liner"])

    # Quiet solid source interfaces. These remain inside decorative-only areas.
    left_draw = ImageDraw.Draw(parts["left_cap"], "RGBA")
    left_draw.rectangle((5, 2, 6, 5), fill=leather)
    left_draw.rectangle((5, 36, 6, 40), fill=leather_mid)
    left_draw.point((6, 5), fill=liner)
    left_draw.point((6, 36), fill=liner)

    right_draw = ImageDraw.Draw(parts["right_cap"], "RGBA")
    right_draw.rectangle((0, 2, 1, 5), fill=leather)
    right_draw.rectangle((0, 36, 1, 40), fill=leather_mid)
    right_draw.point((0, 5), fill=liner)
    right_draw.point((0, 36), fill=liner)

    top_draw = ImageDraw.Draw(parts["top_rail"], "RGBA")
    top_draw.rectangle((0, 2, 1, 5), fill=leather)
    top_draw.rectangle((198, 2, 199, 5), fill=leather)
    top_draw.line((0, 5, 1, 5), fill=liner, width=1)
    top_draw.line((198, 5, 199, 5), fill=liner, width=1)

    bottom_draw = ImageDraw.Draw(parts["bottom_rail"], "RGBA")
    bottom_draw.rectangle((0, 0, 1, 4), fill=leather_mid)
    bottom_draw.rectangle((198, 0, 199, 4), fill=leather_mid)
    bottom_draw.line((0, 0, 1, 0), fill=liner, width=1)
    bottom_draw.line((198, 0, 199, 0), fill=liner, width=1)
    return parts


def resize_horizontal(image: Image.Image, width: int) -> Image.Image:
    return image.resize((width, image.height), Image.Resampling.BILINEAR)


def extrude_column(image: Image.Image, source_x: int) -> Image.Image:
    return image.crop((source_x, 0, source_x + 1, image.height))


def center_band(parts: dict[str, Image.Image], content_width: int) -> Image.Image:
    """Build W+2 center band: 1px endpoint extrusion under each fixed cap."""
    result = Image.new("RGBA", (content_width + 2, 42), (0, 0, 0, 0))
    top = resize_horizontal(parts["top_rail"], content_width)
    bottom = resize_horizontal(parts["bottom_rail"], content_width)
    result.alpha_composite(top, (1, 0))
    result.alpha_composite(bottom, (1, 36))
    result.alpha_composite(extrude_column(top, 0), (0, 0))
    result.alpha_composite(extrude_column(top, top.width - 1), (content_width + 1, 0))
    result.alpha_composite(extrude_column(bottom, 0), (0, 36))
    result.alpha_composite(
        extrude_column(bottom, bottom.width - 1),
        (content_width + 1, 36),
    )
    return result


def standard_composite(parts: dict[str, Image.Image]) -> Image.Image:
    """Default W=200 runtime: one texture, therefore zero internal runtime seams."""
    result = Image.new("RGBA", (214, 42), (0, 0, 0, 0))
    result.alpha_composite(center_band(parts, 200), (6, 0))
    result.alpha_composite(parts["left_cap"], (0, 0))
    result.alpha_composite(parts["right_cap"], (207, 0))
    return result


def logical_dynamic_base(
    content_width: int,
    role: str,
    name: str,
    value: str,
    health_fraction: float,
) -> Image.Image:
    outer_width = content_width + 14
    image = Image.new("RGBA", (outer_width, 42), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")
    health_color = (74, 121, 58, 255) if role == "player" else (132, 48, 41, 255)
    power_color = (45, 88, 150, 255) if role == "player" else (84, 48, 112, 255)
    x0, x1 = 7, content_width + 7
    draw.rectangle((x0, 6, x1 - 1, 30), fill=(25, 18, 13, 255))
    fill_width = max(1, round(content_width * health_fraction))
    draw.rectangle((x0, 6, x0 + fill_width - 1, 30), fill=health_color)
    draw.line((x0 + 2, 7, x0 + fill_width - 2, 7), fill=(220, 196, 136, 45), width=1)
    draw.rectangle((x0, 32, x1 - 1, 35), fill=power_color)
    body = font(BODY_FONT, 11)
    draw.text((x0 + 5, 18), name, font=body, fill=(236, 219, 180, 255), anchor="lm")
    draw.text((x1 - 5, 18), value, font=body, fill=(243, 226, 188, 255), anchor="rm")
    return image


def role_values(role: str) -> tuple[str, str, float]:
    if role == "player":
        return "纳斯雷兹姆 60", "5234 / 5234", 0.82
    return "黑石勇士 60+", "74%", 0.74


def scale_image(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    return image.resize((max(1, size[0]), max(1, size[1])), Image.Resampling.BILINEAR)


def standard_physical(
    spec: dict[str, Any], role: str, scale: float
) -> tuple[Image.Image, Image.Image, dict[str, Any]]:
    parts = source_parts(spec, role)
    shell = standard_composite(parts)
    name, value, fraction = role_values(role)
    base = logical_dynamic_base(200, role, name, value, fraction)
    size = (ceil_coord(214 * scale), ceil_coord(42 * scale))
    physical_shell = scale_image(shell, size)
    physical = scale_image(base, size)
    physical.alpha_composite(physical_shell)
    safe = inward_box((7, 6, 207, 36), scale)
    alpha = np.asarray(physical_shell.getchannel("A"))
    sx0, sy0, sx1, sy1 = safe
    interior = alpha[sy0:sy1, sx0:sx1]
    opaque_intrusion = int(np.count_nonzero(interior >= 128))
    any_fringe = int(np.count_nonzero(interior > 0))
    return physical, physical_shell, {
        "effective_scale": scale,
        "physical_size": list(size),
        "cap_physical_pixels": ceil_coord(7 * scale),
        "rail_physical_pixels": ceil_coord(6 * scale),
        "runtime_texture_count": 1,
        "runtime_internal_seams": 0,
        "safe_inward_box": list(safe),
        "opaque_shell_pixels_in_safe": opaque_intrusion,
        "filtered_alpha_pixels_in_safe": any_fringe,
    }


def three_slice_shell_physical(
    spec: dict[str, Any], role: str, content_width: int, scale: float
) -> tuple[Image.Image, dict[str, Any]]:
    parts = source_parts(spec, role)
    band = center_band(parts, content_width)
    outer_width = content_width + 14
    physical_size = (ceil_coord(outer_width * scale), ceil_coord(42 * scale))
    shell = Image.new("RGBA", physical_size, (0, 0, 0, 0))

    center_box = outward_box((6, 0, content_width + 8, 42), scale)
    left_box = outward_box((0, 0, 7, 42), scale)
    right_box = outward_box((content_width + 7, 0, outer_width, 42), scale)

    def paste_part(part: Image.Image, box: tuple[int, int, int, int]) -> None:
        x0, y0, x1, y1 = box
        resized = scale_image(part, (x1 - x0, y1 - y0))
        shell.alpha_composite(resized, (x0, y0))

    # The band is lower in z-order; fixed caps cover the overlap.
    paste_part(band, center_box)
    paste_part(parts["left_cap"], left_box)
    paste_part(parts["right_cap"], right_box)

    safe = inward_box((7, 6, content_width + 7, 36), scale)
    alpha = np.asarray(shell.getchannel("A"))
    sx0, sy0, sx1, sy1 = safe
    interior = alpha[sy0:sy1, sx0:sx1]

    left_overlap = max(0, left_box[2] - center_box[0])
    right_overlap = max(0, center_box[2] - right_box[0])
    contact_ranges = [
        inward_box((0, 2, outer_width, 6), scale)[1:4:2],
        inward_box((0, 36, outer_width, 41), scale)[1:4:2],
    ]
    seam_gap_pixels = 0
    for boundary in (7, content_width + 7):
        bx0 = max(0, floor_coord((boundary - 1) * scale))
        bx1 = min(physical_size[0], ceil_coord((boundary + 1) * scale))
        for y0, y1 in contact_ranges:
            if bx1 > bx0 and y1 > y0:
                seam_gap_pixels += int(np.count_nonzero(alpha[y0:y1, bx0:bx1] == 0))

    return shell, {
        "role": role,
        "content_width": content_width,
        "effective_scale": scale,
        "physical_size": list(physical_size),
        "left_box": list(left_box),
        "center_box": list(center_box),
        "right_box": list(right_box),
        "left_overlap_physical_pixels": left_overlap,
        "right_overlap_physical_pixels": right_overlap,
        "seam_contact_gap_pixels": seam_gap_pixels,
        "safe_inward_box": list(safe),
        "opaque_shell_pixels_in_safe": int(np.count_nonzero(interior >= 128)),
        "filtered_alpha_pixels_in_safe": int(np.count_nonzero(interior > 0)),
    }


def three_slice_physical(
    spec: dict[str, Any], role: str, content_width: int, scale: float
) -> tuple[Image.Image, dict[str, Any]]:
    shell, metrics = three_slice_shell_physical(spec, role, content_width, scale)
    name, value, fraction = role_values(role)
    base = logical_dynamic_base(content_width, role, name, value, fraction)
    physical = scale_image(base, tuple(metrics["physical_size"]))
    physical.alpha_composite(shell)
    return physical, metrics


def checker_tile(size: tuple[int, int]) -> Image.Image:
    image = Image.new("RGBA", size, (29, 27, 24, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    step = 12
    for y in range(0, size[1], step):
        for x in range(0, size[0], step):
            if (x // step + y // step) % 2:
                draw.rectangle((x, y, x + step - 1, y + step - 1), fill=(43, 40, 35, 255))
    return image


def render_scale_matrix(
    spec: dict[str, Any], standard_metrics: dict[str, list[dict[str, Any]]]
) -> Image.Image:
    image = Image.new("RGBA", (1800, 1100), (17, 16, 14, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    title = font(TITLE_FONT, 28)
    label = font(BODY_FONT, 15)
    small = font(BODY_FONT, 13)
    draw.text((42, 28), "UF-A1 V2-SIM.V2 · 标准单壳有效缩放矩阵", font=title, fill=(217, 185, 120, 255))
    draw.text((44, 70), "每个角色在默认 214×42 下只挂载一张合成 shell；上方为实际物理像素，下方为 2×最近邻审阅。ImageGen 0/0。", font=label, fill=(174, 163, 143, 255))
    draw.text((44, 96), "BILINEAR 仅近似客户端采样；可据此审视重量与细节存活，不能替代 Turtle WoW P6。", font=small, fill=(145, 137, 123, 255))

    scales = spec["scale_review"]["effective_scales"]
    for role_index, role in enumerate(("player", "target")):
        for index, scale in enumerate(scales):
            row = role_index * 2 + index // 3
            column = index % 3
            x = 44 + column * 582
            y = 134 + row * 236
            frame, _, metrics = standard_physical(spec, role, scale)
            tile = checker_tile((548, 210))
            tile_draw = ImageDraw.Draw(tile, "RGBA")
            role_label = "Player" if role == "player" else "Target"
            tile_draw.text((14, 10), f"{role_label} · effective scale {scale:.2f}", font=label, fill=(213, 184, 132, 255))
            tile_draw.text(
                (14, 36),
                f"physical {frame.width}×{frame.height}px · cap≈{metrics['cap_physical_pixels']}px · rail≈{metrics['rail_physical_pixels']}px · seams 0",
                font=small,
                fill=(161, 151, 135, 255),
            )
            tile.alpha_composite(frame, (18, 66))
            magnified = frame.resize((frame.width * 2, frame.height * 2), Image.Resampling.NEAREST)
            tile.alpha_composite(magnified, (18, 108))
            tile_draw.text((356, 70), "实际像素", font=small, fill=(132, 123, 109, 255))
            tile_draw.text((356, 112), "2×审阅", font=small, fill=(132, 123, 109, 255))
            image.alpha_composite(tile, (x, y))

    draw.text((46, 1070), "判断重点：低缩放下关键身份不能依赖单个 runtime 像素；标准路径内部无 Texture 接缝。", font=label, fill=(201, 171, 115, 255))
    return image


def draw_architecture(image: Image.Image, spec: dict[str, Any]) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    title = font(TITLE_FONT, 28)
    label = font(BODY_FONT, 15)
    small = font(BODY_FONT, 13)
    draw.text((42, 28), "UF-A1 V2-SIM.V2 · Source → Runtime 装配合同", font=title, fill=(217, 185, 120, 255))
    draw.text((44, 69), "八个独立 source 保留资产粒度；标准宽度导出单壳，可变宽度才启用三段式。", font=label, fill=(174, 163, 143, 255))

    x0, y0 = 60, 128
    colors = [(137, 84, 46, 255), (105, 78, 40, 255), (78, 56, 33, 255), (148, 103, 48, 255)]
    names = ["左端帽\n7×42", "上轨\n200×6", "下轨\n200×6", "右端帽\n7×42"]
    widths = [56, 280, 280, 56]
    xpos = x0
    for color, name, width in zip(colors, names, widths):
        draw.rectangle((xpos, y0, xpos + width, y0 + 78), fill=color, outline=(190, 151, 89, 255), width=2)
        draw.multiline_text((xpos + width // 2, y0 + 39), name, font=small, fill=(237, 218, 175, 255), anchor="mm", align="center")
        xpos += width + 18
    draw.text((60, 222), "每个角色四件；Player／Target 从零独立绘制", font=small, fill=(156, 146, 130, 255))

    draw.line((790, 166, 930, 166), fill=(153, 116, 60, 255), width=3)
    draw.polygon([(930, 166), (914, 156), (914, 176)], fill=(153, 116, 60, 255))
    draw.text((815, 130), "P4/P5 确定性导出", font=small, fill=(183, 159, 113, 255))

    player = standard_composite(source_parts(spec, "player")).resize((642, 126), Image.Resampling.NEAREST)
    image.alpha_composite(player, (1010, 116))
    draw.text((1010, 252), "默认 W=200：一张 214×42 RGBA shell／role；内部接缝=0", font=small, fill=(184, 164, 126, 255))

    draw.line((40, 286, 1760, 286), fill=(83, 63, 38, 255), width=1)
    draw.text((50, 304), "可变宽度三段式（中央带在端帽下方，各重叠 1 logical px；只发生在上下角落）", font=label, fill=(205, 176, 120, 255))


def render_runtime_contract(
    spec: dict[str, Any], variable_metrics: list[dict[str, Any]]
) -> Image.Image:
    image = Image.new("RGBA", (1800, 980), (17, 16, 14, 255))
    draw_architecture(image, spec)
    draw = ImageDraw.Draw(image, "RGBA")
    label = font(BODY_FONT, 15)
    small = font(BODY_FONT, 13)
    widths = spec["variable_width_runtime"]["supported_preview_content_widths"]
    scales = spec["scale_review"]["width_matrix_scales"]

    for row, scale in enumerate(scales):
        for column, width in enumerate(widths):
            x = 45 + column * 585
            y = 348 + row * 272
            tile = checker_tile((550, 244))
            tile_draw = ImageDraw.Draw(tile, "RGBA")
            tile_draw.text((14, 10), f"content W={width} · outer={width + 14}×42 · scale={scale:.2f}", font=label, fill=(213, 184, 132, 255))
            player, pm = three_slice_physical(spec, "player", width, scale)
            target, tm = three_slice_physical(spec, "target", width, scale)
            factor = 2
            player_zoom = player.resize((player.width * factor, player.height * factor), Image.Resampling.NEAREST)
            target_zoom = target.resize((target.width * factor, target.height * factor), Image.Resampling.NEAREST)
            tile.alpha_composite(player_zoom, (16, 55))
            tile.alpha_composite(target_zoom, (16, 137))
            tile_draw.text(
                (14, 216),
                f"L/R overlap={pm['left_overlap_physical_pixels']}/{pm['right_overlap_physical_pixels']}px · seam gaps P/T={pm['seam_contact_gap_pixels']}/{tm['seam_contact_gap_pixels']}",
                font=small,
                fill=(157, 148, 133, 255),
            )
            image.alpha_composite(tile, (x, y))

    draw.text((50, 914), "三段层序：动态条 → 中央带 → 固定端帽 → runtime 文字／图标。端帽遮住重叠区，动态安全区不变。", font=label, fill=(203, 174, 117, 255))
    draw.text((50, 944), "高度变化不在合同内：不得把 42px shell 纵向拉伸；需要其他高度时建立独立规格。", font=label, fill=(171, 153, 120, 255))
    return image


def validate_source_geometry(spec: dict[str, Any]) -> dict[str, Any]:
    reports: dict[str, Any] = {}
    overall = True
    for role in ("player", "target"):
        parts = source_parts(spec, role)
        standard = standard_composite(parts)
        alpha = np.asarray(standard.getchannel("A"))
        logical_safe = alpha[6:36, 7:207]
        intrusion = int(np.count_nonzero(logical_safe))
        role_pass = intrusion == 0 and standard.size == (214, 42)
        overall &= role_pass
        reports[role] = {
            "source_piece_count": 4,
            "standard_runtime_size": [214, 42],
            "standard_runtime_texture_count": 1,
            "standard_runtime_internal_seams": 0,
            "logical_shell_alpha_pixels_in_content_safe": intrusion,
            "status": "pass" if role_pass else "fail",
        }
    return {"status": "pass" if overall else "fail", "roles": reports}


def main() -> None:
    args = parse_args()
    spec_path = args.spec.resolve()
    spec = json.loads(spec_path.read_text(encoding="utf-8"))

    source_report = validate_source_geometry(spec)
    standard_metrics: dict[str, list[dict[str, Any]]] = {"player": [], "target": []}
    for role in standard_metrics:
        for scale in spec["scale_review"]["effective_scales"]:
            _, _, metrics = standard_physical(spec, role, scale)
            standard_metrics[role].append(metrics)

    variable_metrics: list[dict[str, Any]] = []
    for role in ("player", "target"):
        for width in spec["variable_width_runtime"]["supported_preview_content_widths"]:
            for scale in spec["scale_review"]["width_matrix_scales"]:
                _, metrics = three_slice_physical(spec, role, width, scale)
                variable_metrics.append(metrics)

    violations: list[dict[str, Any]] = []
    if source_report["status"] != "pass":
        violations.append({"code": "SOURCE_TO_STANDARD_COMPOSITE_FAILED"})
    for role, items in standard_metrics.items():
        for metrics in items:
            if metrics["runtime_internal_seams"] != 0:
                violations.append({"code": "STANDARD_RUNTIME_INTERNAL_SEAM", "role": role, "scale": metrics["effective_scale"]})
            if metrics["opaque_shell_pixels_in_safe"]:
                violations.append({"code": "STANDARD_OPAQUE_SAFE_INTRUSION", "role": role, "scale": metrics["effective_scale"], "pixels": metrics["opaque_shell_pixels_in_safe"]})
    for metrics in variable_metrics:
        if metrics["seam_contact_gap_pixels"]:
            violations.append({"code": "THREE_SLICE_CONTACT_GAP", **metrics})
        if metrics["opaque_shell_pixels_in_safe"]:
            violations.append({"code": "THREE_SLICE_OPAQUE_SAFE_INTRUSION", **metrics})
        if min(metrics["left_overlap_physical_pixels"], metrics["right_overlap_physical_pixels"]) < 1:
            violations.append({"code": "THREE_SLICE_PHYSICAL_OVERLAP_COLLAPSED", **metrics})

    output_scale = ROOT / spec["outputs"]["scale_matrix"]
    output_contract = ROOT / spec["outputs"]["runtime_contract"]
    output_scale.parent.mkdir(parents=True, exist_ok=True)
    render_scale_matrix(spec, standard_metrics).save(output_scale, format="PNG", optimize=False, compress_level=9)
    render_runtime_contract(spec, variable_metrics).save(output_contract, format="PNG", optimize=False, compress_level=9)

    report = {
        "schema": "aeui-unitframes-a1-v2-scale-simulation-report-v1",
        "version": spec["version"],
        "status": "pass" if not violations else "fail",
        "imagegen_calls": 0,
        "specification_path": str(spec_path.relative_to(ROOT)),
        "specification_sha256": sha256(spec_path),
        "source_geometry": source_report,
        "standard_scale_matrix": standard_metrics,
        "variable_width_three_slice_matrix": variable_metrics,
        "violations": violations,
        "scale_matrix_path": str(output_scale.relative_to(ROOT)),
        "scale_matrix_sha256": sha256(output_scale),
        "runtime_contract_path": str(output_contract.relative_to(ROOT)),
        "runtime_contract_sha256": sha256(output_contract),
        "filter_fidelity": spec["scale_review"]["filter_simulation"],
    }
    report_path = ROOT / spec["outputs"]["report"]
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    if violations:
        raise SystemExit(json.dumps(report, ensure_ascii=False, indent=2))
    print(output_scale.resolve())
    print(output_contract.resolve())
    print(report_path.resolve())


if __name__ == "__main__":
    main()
