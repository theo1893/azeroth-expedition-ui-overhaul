#!/usr/bin/env python3
"""Render UF-A1 V2's deterministic four-piece perimeter simulation.

This is a pre-ImageGen geometry preview. It deliberately contains no pixels from
the rejected UF-A1 V1 production attempts and cannot become source/runtime art.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SPEC = ROOT / "tools/specs/unitframes_a1_v2_simulation_v1.json"
BODY_FONT = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"
TITLE_FONT = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=Path, default=DEFAULT_SPEC)
    return parser.parse_args()


def rgba(value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[index:index + 2], 16) for index in (0, 2, 4)) + (alpha,)


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def piece_layer(
    size: tuple[int, int],
    role: str,
    piece: str,
    palette: dict[str, str],
) -> Image.Image:
    """Draw one exact runtime piece without crossing its declared rectangle."""
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")
    leather = rgba(palette["leather"])
    leather_mid = rgba(palette["leather_mid"])
    liner = rgba(palette["liner"])
    brass = rgba(palette["brass"])
    brass_dim = rgba(palette["brass_dim"])

    if piece == "top_rail":
        draw.polygon(
            [(7, 2), (27, 0), (55, 1), (91, 0), (128, 1), (165, 0),
             (193, 1), (206, 0), (206, 5), (173, 4), (132, 5),
             (92, 4), (49, 5), (18, 4), (7, 5)],
            fill=leather,
        )
        draw.line([(8, 4), (53, 4), (92, 3), (132, 4), (173, 3), (205, 4)], fill=liner, width=1)
        if role == "player":
            draw.line((33, 1, 57, 1), fill=brass_dim, width=1)
            draw.line((143, 1, 158, 1), fill=(137, 94, 45, 210), width=1)
        else:
            draw.line((65, 1, 82, 1), fill=brass_dim, width=1)
            draw.line((177, 2, 195, 1), fill=(128, 86, 40, 220), width=1)
        draw.point((116 if role == "player" else 41, 2), fill=(178, 127, 66, 150))

    elif piece == "bottom_rail":
        draw.polygon(
            [(7, 36), (31, 37), (68, 36), (103, 37), (139, 36),
             (179, 37), (206, 36), (206, 40), (190, 41), (153, 40),
             (112, 41), (73, 40), (36, 41), (8, 39)],
            fill=leather_mid,
        )
        draw.line([(8, 36), (42, 37), (80, 36), (121, 37), (162, 36), (205, 37)], fill=liner, width=1)
        if role == "player":
            draw.line((74, 39, 91, 40), fill=brass_dim, width=1)
            draw.line((181, 39, 197, 38), fill=(119, 78, 39, 205), width=1)
        else:
            draw.line((20, 39, 42, 38), fill=brass_dim, width=1)
            draw.line((118, 40, 137, 39), fill=(126, 82, 40, 205), width=1)

    elif piece == "left_cap":
        draw.polygon(
            [(2, 1), (6, 0), (6, 41), (2, 40), (0, 34), (1, 25),
             (0, 16), (1, 7)],
            fill=leather_mid,
        )
        draw.line((6, 2, 6, 39), fill=liner, width=1)
        if role == "player":
            draw.line([(2, 3), (1, 14), (2, 27), (1, 38)], fill=brass_dim, width=2)
            draw.line((3, 12, 6, 15), fill=(150, 105, 59, 255), width=1)
            draw.line((3, 19, 6, 17), fill=(139, 94, 52, 255), width=1)
            draw.line((3, 28, 6, 31), fill=(150, 105, 59, 255), width=1)
        else:
            draw.line([(3, 3), (2, 12), (3, 23), (2, 38)], fill=(112, 75, 41, 220), width=1)
            draw.line((4, 6, 5, 34), fill=(163, 116, 61, 130), width=1)

    elif piece == "right_cap":
        draw.polygon(
            [(207, 0), (212, 1), (213, 8), (212, 17), (213, 27),
             (212, 38), (209, 41), (207, 40)],
            fill=leather_mid,
        )
        draw.line((207, 2, 207, 39), fill=liner, width=1)
        if role == "player":
            draw.line((210, 4, 211, 35), fill=(112, 75, 41, 190), width=1)
            draw.point((210, 30), fill=brass)
        else:
            draw.polygon(
                [(208, 7), (212, 5), (212, 17), (211, 21), (213, 25),
                 (212, 34), (208, 36)],
                fill=brass_dim,
            )
            draw.line([(209, 8), (211, 12), (209, 17), (212, 22), (209, 30)], fill=brass, width=1)
            draw.point((210, 10), fill=(193, 142, 74, 255))
            draw.point((211, 31), fill=(83, 55, 29, 255))
    else:
        raise ValueError(f"unknown piece: {piece}")

    return image


def build_shell(
    spec: dict[str, Any], role: str
) -> tuple[Image.Image, dict[str, Image.Image]]:
    size = tuple(spec["shell"]["size"])
    layers = {
        piece: piece_layer(size, role, piece, spec["palette"])
        for piece in spec["shell"]["pieces"]
    }
    shell = Image.new("RGBA", size, (0, 0, 0, 0))
    for piece in ("top_rail", "bottom_rail", "left_cap", "right_cap"):
        shell.alpha_composite(layers[piece])
    return shell, layers


def rim(shell: Image.Image, color: tuple[int, int, int, int], role: str) -> Image.Image:
    alpha = shell.getchannel("A")
    expanded = alpha.filter(ImageFilter.MaxFilter(5))
    source = np.asarray(alpha, dtype=np.int16)
    ring = np.maximum(0, np.asarray(expanded, dtype=np.int16) - source).astype(np.uint8)
    mask = np.zeros_like(ring)
    if role == "target":
        mask[:, 188:] = ring[:, 188:]
        mask[34:, 118:] = np.maximum(mask[34:, 118:], ring[34:, 118:])
        mask[:8, 204:] = np.maximum(mask[:8, 204:], ring[:8, 204:])
    else:
        mask[:8, :68] = ring[:8, :68]
        mask[34:, 18:82] = np.maximum(mask[34:, 18:82], ring[34:, 18:82])
    mask = (mask.astype(np.float32) * (color[3] / 255.0)).astype(np.uint8)
    result = Image.new("RGBA", shell.size, color[:3] + (0,))
    result.putalpha(Image.fromarray(mask, "L"))
    return result


def dynamic_frame(
    spec: dict[str, Any],
    role: str,
    name: str,
    value: str,
    health_fraction: float,
    health_color: tuple[int, int, int, int],
    power_color: tuple[int, int, int, int],
    show_state: bool = False,
) -> Image.Image:
    shell, _ = build_shell(spec, role)
    image = Image.new("RGBA", tuple(spec["shell"]["size"]), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")
    x0, y0, x1, y1 = spec["shell"]["content_safe"]
    draw.rectangle((x0, y0, x1 - 1, y0 + 24), fill=(25, 18, 13, 255))
    fill = max(1, round((x1 - x0) * health_fraction))
    draw.rectangle((x0, y0, x0 + fill - 1, y0 + 24), fill=health_color)
    draw.line((x0 + 2, y0 + 1, x0 + fill - 2, y0 + 1), fill=(220, 196, 136, 45), width=1)
    draw.rectangle((x0, y0 + 26, x1 - 1, y1 - 1), fill=(20, 15, 12, 255))
    draw.rectangle((x0, y0 + 26, x1 - 1, y1 - 1), fill=power_color)
    if show_state:
        image.alpha_composite(rim(shell, (137, 43, 25, 175), role))
    image.alpha_composite(shell)
    body = font(BODY_FONT, 11)
    draw = ImageDraw.Draw(image, "RGBA")
    draw.text((x0 + 5, y0 + 12), name, font=body, fill=(236, 219, 180, 255), anchor="lm")
    draw.text((x1 - 5, y0 + 12), value, font=body, fill=(243, 226, 188, 255), anchor="rm")
    return image


def background(image: Image.Image) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle((0, 0, image.width, image.height), fill=(14, 17, 19, 255))
    for y in range(88, image.height - 150, 54):
        offset = 18 if (y // 54) % 2 else 0
        for x in range(-20 + offset, image.width, 96):
            draw.rectangle((x, y, x + 88, y + 47), fill=(24, 27, 28, 255), outline=(35, 35, 32, 255), width=2)
    draw.rectangle((0, image.height - 154, image.width, image.height), fill=(18, 15, 12, 255))


def neighbours(image: Image.Image, spec: dict[str, Any]) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    palette = spec["palette"]
    draw.polygon([(16, 680), (326, 671), (344, 888), (12, 892)], fill=rgba(palette["leather"]), outline=rgba(palette["brass_dim"]))
    draw.polygon([(30, 704), (314, 696), (326, 865), (28, 873)], fill=(62, 48, 35, 255), outline=(112, 77, 40, 255))
    small = font(BODY_FONT, 12)
    draw.text((47, 723), "[公会] 今晚黑翼之巢 19:30 集合", font=small, fill=(90, 196, 96, 255))
    draw.text((47, 748), "[小队] 消耗品与灵魂石已准备。", font=small, fill=(158, 151, 230, 255))
    draw.text((47, 773), "[系统] 你获得了：远征补给。", font=small, fill=(235, 203, 81, 255))
    x0, y0 = 480, 830
    for index in range(12):
        x = x0 + index * 43
        draw.rectangle((x, y0, x + 38, y0 + 38), fill=(45, 36, 26, 255), outline=rgba(palette["brass_dim"]), width=2)
        draw.rectangle((x + 5, y0 + 5, x + 33, y0 + 33), fill=((45 + index * 11) % 120, 48, 73, 255))
    draw.polygon([(430, 868), (461, 831), (474, 850), (461, 887)], fill=(96, 72, 38, 255), outline=rgba(palette["brass"]))
    draw.polygon([(1008, 850), (1022, 831), (1053, 868), (1022, 887)], fill=(96, 72, 38, 255), outline=rgba(palette["brass"]))


def render_scene(spec: dict[str, Any]) -> Image.Image:
    canvas = spec["canvas"]
    image = Image.new("RGBA", (canvas["width"], canvas["height"]), (0, 0, 0, 255))
    background(image)
    neighbours(image, spec)
    draw = ImageDraw.Draw(image, "RGBA")
    title = font(TITLE_FONT, 24)
    note = font(BODY_FONT, 13)
    draw.text((38, 30), "UF-A1 V2-SIM · 四件式外缘装配 · 100% 运行时", font=title, fill=(214, 184, 120, 255))
    draw.text((40, 67), "Player／Target 仍为 214×42；四件装饰全部位于 7px 端帽与 6px 上下轨，200×30 动态区零覆盖。ImageGen 0/0。", font=note, fill=(173, 164, 146, 255))
    draw.text((40, 91), "屏幕锚点与微纹理非权威；资源外接、真实条尺寸、点击区与装饰排除区为权威。", font=note, fill=(145, 138, 124, 255))

    player = dynamic_frame(spec, "player", "纳斯雷兹姆 60", "5234 / 5234", 0.82, (74, 121, 58, 255), (45, 88, 150, 255))
    target = dynamic_frame(spec, "target", "黑石勇士 60+", "74%", 0.74, (132, 48, 41, 255), (84, 48, 112, 255), show_state=True)
    px, py = spec["roles"]["player"]["placement"]
    tx, ty = spec["roles"]["target"]["placement"]
    image.alpha_composite(player, (px, py))
    image.alpha_composite(target, (tx, ty))
    draw.text((px, py - 19), "Player · 左端固定修补", font=note, fill=(190, 169, 129, 255))
    draw.text((tx, ty - 19), "Target · 右端固定破损片", font=note, fill=(190, 169, 129, 255))
    for index, color in enumerate(((88, 86, 155, 255), (144, 76, 61, 255), (57, 107, 134, 255), (116, 91, 44, 255))):
        draw.rectangle((tx + 7 + index * 24, ty + 47, tx + 27 + index * 24, ty + 67), fill=color, outline=(123, 91, 48, 255))
    draw.text((1180, 846), "Chat／动作条：邻接几何，仅综合色参考", font=note, fill=(142, 131, 114, 255))
    return image


def occupancy_map(spec: dict[str, Any], role: str, scale: int = 3) -> Image.Image:
    width, height = spec["shell"]["size"]
    image = Image.new("RGBA", (width, height), (21, 19, 17, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    colors = {
        "left_cap": (142, 87, 48, 255),
        "top_rail": (112, 83, 42, 255),
        "bottom_rail": (88, 63, 36, 255),
        "right_cap": (151, 106, 48, 255),
    }
    for piece, box in spec["shell"]["pieces"].items():
        x0, y0, x1, y1 = box
        draw.rectangle((x0, y0, x1 - 1, y1 - 1), fill=colors[piece])
    x0, y0, x1, y1 = spec["shell"]["content_safe"]
    draw.rectangle((x0, y0, x1 - 1, y1 - 1), fill=(44, 88, 61, 255))
    draw.rectangle((x0, y0, x1 - 1, y1 - 1), outline=(196, 175, 126, 255), width=1)
    return image.resize((width * scale, height * scale), Image.Resampling.NEAREST)


def render_assembly(spec: dict[str, Any]) -> Image.Image:
    image = Image.new("RGBA", (1600, 900), (20, 18, 16, 255))
    draw = ImageDraw.Draw(image, "RGBA")
    title = font(TITLE_FONT, 27)
    label = font(BODY_FONT, 15)
    small = font(BODY_FONT, 13)
    draw.text((38, 30), "UF-A1 V2-SIM · 结构审阅板", font=title, fill=(216, 184, 119, 255))
    draw.text((40, 70), "上：3×最近邻视觉审阅；中：精确占用图；下：四件 source 职责。所有尺寸仍以 100% runtime 像素计。", font=label, fill=(172, 160, 139, 255))

    frames = {
        "player": dynamic_frame(spec, "player", "纳斯雷兹姆 60", "5234 / 5234", 0.82, (74, 121, 58, 255), (45, 88, 150, 255)),
        "target": dynamic_frame(spec, "target", "黑石勇士 60+", "74%", 0.74, (132, 48, 41, 255), (84, 48, 112, 255), show_state=True),
    }
    for index, role in enumerate(("player", "target")):
        x = 72 + index * 760
        enlarged = frames[role].resize((642, 126), Image.Resampling.NEAREST)
        image.alpha_composite(enlarged, (x, 142))
        draw.text((x, 115), f"{role.title()} · 214×42 → 3×", font=label, fill=(206, 179, 126, 255))
        draw.text((x, 284), "端帽不再是宽 U 形构件；它只占左右各 7px。", font=small, fill=(155, 145, 128, 255))

        occ = occupancy_map(spec, role, 3)
        image.alpha_composite(occ, (x, 356))
        draw.text((x, 329), "精确四件占用：棕＝装饰；绿＝200×30 provider／Button 区", font=small, fill=(184, 166, 130, 255))

    y = 548
    draw.line((40, y - 22, 1560, y - 22), fill=(86, 66, 39, 255), width=1)
    rows = [
        ("LEFT CAP", "7×42", "固定宽；Player 左修补／Target 左磨亮折边；不可横向拉伸"),
        ("TOP RAIL", "200×6", "独立横轨；长中心安静；未来只允许横向延展"),
        ("BOTTOM RAIL", "200×6", "独立横轨；磨损节奏不复制上轨；未来只允许横向延展"),
        ("RIGHT CAP", "7×42", "固定宽；Player 右铆钉／Target 右破损压片；不可横向拉伸"),
    ]
    swatches = ((142, 87, 48, 255), (112, 83, 42, 255), (88, 63, 36, 255), (151, 106, 48, 255))
    for index, ((name, size, description), swatch) in enumerate(zip(rows, swatches)):
        row_y = y + index * 66
        draw.rectangle((52, row_y, 85, row_y + 32), fill=swatch, outline=(191, 157, 95, 255))
        draw.text((105, row_y + 2), name, font=label, fill=(220, 194, 144, 255))
        draw.text((248, row_y + 2), size, font=label, fill=(184, 166, 130, 255))
        draw.text((340, row_y + 2), description, font=label, fill=(166, 157, 141, 255))
    draw.text((52, 826), "冻结约束：四件彼此不重叠；装饰 Alpha ∩ content-safe = 0；Player／Target 八件均独立，不镜像、不复用 V1 失败像素。", font=label, fill=(205, 174, 117, 255))
    return image


def validate_simulation(
    spec: dict[str, Any],
    shells: dict[str, tuple[Image.Image, dict[str, Image.Image]]],
) -> dict[str, Any]:
    safe = spec["shell"]["content_safe"]
    size = tuple(spec["shell"]["size"])
    role_reports: dict[str, Any] = {}
    overall = True
    for role, (shell, layers) in shells.items():
        alpha = np.asarray(shell.getchannel("A"))
        x0, y0, x1, y1 = safe
        safe_pixels = int(np.count_nonzero(alpha[y0:y1, x0:x1]))
        layer_arrays = []
        piece_reports: dict[str, Any] = {}
        for piece, layer in layers.items():
            box = spec["shell"]["pieces"][piece]
            lx0, ly0, lx1, ly1 = box
            layer_alpha = np.asarray(layer.getchannel("A"))
            allowed = np.zeros_like(layer_alpha, dtype=bool)
            allowed[ly0:ly1, lx0:lx1] = True
            outside = int(np.count_nonzero((layer_alpha > 0) & ~allowed))
            piece_reports[piece] = {
                "declared_box": box,
                "visible_pixels_outside_declared_box": outside,
            }
            layer_arrays.append(layer_alpha > 0)
            overall &= outside == 0
        overlap = int(np.count_nonzero(np.sum(layer_arrays, axis=0) > 1))
        role_pass = safe_pixels == 0 and overlap == 0
        overall &= role_pass
        role_reports[role] = {
            "shell_size": list(size),
            "content_safe": safe,
            "decoration_alpha_pixels_in_content_safe": safe_pixels,
            "piece_overlap_pixels": overlap,
            "pieces": piece_reports,
            "status": "pass" if role_pass else "fail",
        }
    return {
        "schema": "aeui-unitframes-a1-v2-simulation-report-v1",
        "version": spec["version"],
        "status": "pass" if overall else "fail",
        "imagegen_calls": 0,
        "rejected_v1_pixels_reused": False,
        "provider_frame_hitbox_unchanged": spec["provider"]["frame_hitbox_unchanged"],
        "roles": role_reports,
    }


def main() -> None:
    args = parse_args()
    spec_path = args.spec.resolve()
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    shells = {role: build_shell(spec, role) for role in ("player", "target")}
    report = validate_simulation(spec, shells)
    if report["status"] != "pass":
        raise SystemExit(json.dumps(report, ensure_ascii=False, indent=2))

    outputs = spec["outputs"]
    for key, rendered in (("scene", render_scene(spec)), ("assembly", render_assembly(spec))):
        output = ROOT / outputs[key]
        output.parent.mkdir(parents=True, exist_ok=True)
        rendered.save(output, format="PNG", optimize=False, compress_level=9)
        report[f"{key}_path"] = str(output.relative_to(ROOT))
        report[f"{key}_sha256"] = sha256(output)

    report["specification_path"] = str(spec_path.relative_to(ROOT))
    report["specification_sha256"] = sha256(spec_path)
    report_path = ROOT / outputs["report"]
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print((ROOT / outputs["scene"]).resolve())
    print((ROOT / outputs["assembly"]).resolve())
    print(report_path.resolve())


if __name__ == "__main__":
    main()
