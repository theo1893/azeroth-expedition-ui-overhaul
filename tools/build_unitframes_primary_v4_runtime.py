#!/usr/bin/env python3
"""Export accepted UF-PRIMARY V4 sources into adaptive runtime media.

The accepted Player and Target pixels stay authoritative.  This exporter only
downscales each complete source, clears the provider live bed for the overlay
rim, and derives restrained state-edge masks from the same accepted Alpha.
Lua expands the live opening with a nine-slice; it never stretches the complete
shell as one bitmap.
"""

from __future__ import annotations

import hashlib
import json
import struct
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets/source/unitframes/primary-v4"
SOURCE_MANIFEST = SOURCE_DIR / "UF-PRIMARY-V4_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "UF-PRIMARY-V4_RuntimeManifest_v1.json"
RUNTIME_DIR = ROOT / "addon/AzerothExpeditionUI/Media/UnitFrames"
PREVIEW = (
    ROOT
    / "generated/unitframes/primary/V4/runtime/real-layout-preview.png"
)

SOURCE_SIZE = (1284, 252)
RUNTIME_SIZE = (214, 42)
LIVE_BED = (7, 6, 207, 36)
SLICE_X = (32, 150, 32)
SLICE_Y = (8, 26, 8)
PREVIEW_FRAME_SIZE = (240, 65)
PREVIEW_ART_SIZE = (254, 77)

FONT = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"
TITLE_FONT = (
    ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"
)
HEALTH_TEXTURE = (
    ROOT
    / "addon/AzerothExpeditionUI/Media/UnitFrames/UnitFrameHealthFillV1.tga"
)
POWER_TEXTURE = (
    ROOT
    / "addon/AzerothExpeditionUI/Media/UnitFrames/UnitFramePowerFillV1.tga"
)

ROLES = {
    "player": {
        "component": "UF.PLAYER.SHELL",
        "source": "UnitFramePlayerShell_MasterV1.png",
        "source_sha256": (
            "331b353f294ae2e658e010ea59763a48bb08ba574b88e150fe3f5a2416bd617b"
        ),
        "runtime": "UnitFramePlayerShellV1.tga",
        "rim": "UnitFramePlayerShellRimV1.tga",
        "hover": "UnitFramePlayerHoverRimV1.tga",
        "aggro": "UnitFramePlayerAggroRimV1.tga",
    },
    "target": {
        "component": "UF.TARGET.SHELL",
        "source": "UnitFrameTargetShell_MasterV1.png",
        "source_sha256": (
            "256086c128561fdfa0717740701581d156ab811d88282c0098f9d3b4595acf81"
        ),
        "runtime": "UnitFrameTargetShellV1.tga",
        "rim": "UnitFrameTargetShellRimV1.tga",
        "hover": "UnitFrameTargetHoverRimV1.tga",
        "aggro": "UnitFrameTargetAggroRimV1.tga",
    },
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def repository_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = [
        (0, 0, 0, 0) if alpha == 0 else (red, green, blue, alpha)
        for red, green, blue, alpha in rgba.getdata()
    ]
    clean = Image.new("RGBA", rgba.size)
    clean.putdata(pixels)
    return clean


def visible_green_pixels(image: Image.Image) -> int:
    return sum(
        1
        for red, green, blue, alpha in image.convert("RGBA").getdata()
        if alpha and red <= 32 and green >= 224 and blue <= 32
    )


def transparent_rgb_nonzero(image: Image.Image) -> int:
    return sum(
        1
        for red, green, blue, alpha in image.convert("RGBA").getdata()
        if alpha == 0 and (red or green or blue)
    )


def image_metrics(image: Image.Image) -> dict[str, Any]:
    rgba = image.convert("RGBA")
    alpha = rgba.getchannel("A")
    histogram = alpha.histogram()
    return {
        "size": list(rgba.size),
        "mode": rgba.mode,
        "pixel_sha256": pixel_sha256(rgba),
        "visible_bbox_exclusive": list(alpha.getbbox() or (0, 0, 0, 0)),
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
        "visible_green_spill_pixels": visible_green_pixels(rgba),
        "transparent_rgb_nonzero_pixels": transparent_rgb_nonzero(rgba),
    }


def load_source(role: str, contract: dict[str, str]) -> Image.Image:
    path = SOURCE_DIR / contract["source"]
    if sha256(path) != contract["source_sha256"]:
        raise ValueError(f"accepted {role} source SHA-256 changed: {path}")
    with Image.open(path) as opened:
        source = opened.convert("RGBA")
    if source.size != SOURCE_SIZE:
        raise ValueError(f"accepted {role} source must remain {SOURCE_SIZE}")
    if visible_green_pixels(source) or transparent_rgb_nonzero(source):
        raise ValueError(f"accepted {role} source transparency drifted")
    return source


def make_runtime(source: Image.Image) -> Image.Image:
    return clear_transparent_rgb(
        source.resize(RUNTIME_SIZE, Image.Resampling.LANCZOS)
    )


def make_overlay_rim(runtime: Image.Image) -> Image.Image:
    rim = runtime.copy()
    ImageDraw.Draw(rim).rectangle(
        (LIVE_BED[0], LIVE_BED[1], LIVE_BED[2] - 1, LIVE_BED[3] - 1),
        fill=(0, 0, 0, 0),
    )
    return clear_transparent_rgb(rim)


def state_segments(role: str, state: str) -> list[tuple[int, int, int, int]]:
    if state == "hover" and role == "player":
        return [(0, 0, 92, 11), (0, 0, 15, 28), (132, 31, 214, 42)]
    if state == "hover":
        return [(118, 0, 214, 11), (199, 0, 214, 29), (0, 31, 78, 42)]
    if role == "player":
        return [(0, 0, 42, 42), (168, 31, 214, 42), (82, 34, 150, 42)]
    return [(172, 0, 214, 42), (0, 31, 48, 42), (72, 34, 142, 42)]


def make_state_mask(rim: Image.Image, role: str, state: str) -> Image.Image:
    alpha = rim.getchannel("A")
    eroded = alpha.filter(ImageFilter.MinFilter(3))
    edge = ImageChops.subtract(alpha, eroded).filter(ImageFilter.MaxFilter(3))
    edge = ImageChops.multiply(edge, alpha)

    segments = Image.new("L", RUNTIME_SIZE, 0)
    draw = ImageDraw.Draw(segments)
    for box in state_segments(role, state):
        draw.rectangle(box, fill=255)
    edge = ImageChops.multiply(edge, segments)
    strength = 205 if state == "hover" else 225
    edge = edge.point(lambda value: min(strength, (value * strength + 127) // 255))

    output = Image.new("RGBA", RUNTIME_SIZE, (232, 220, 192, 0))
    output.putalpha(edge)
    return clear_transparent_rgb(output)


def tga_header(path: Path) -> dict[str, Any]:
    data = path.read_bytes()
    if len(data) < 18:
        raise ValueError(f"TGA header is incomplete: {path}")
    width, height = struct.unpack("<HH", data[12:16])
    return {
        "image_type": data[2],
        "width": width,
        "height": height,
        "bits_per_pixel": data[16],
        "descriptor": data[17],
        "top_origin": bool(data[17] & 0x20),
    }


def save_runtime(image: Image.Image, path: Path) -> Image.Image:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="TGA")
    with Image.open(path) as opened:
        roundtrip = opened.convert("RGBA")
    if ImageChops.difference(roundtrip, image).getbbox() is not None:
        raise ValueError(f"TGA roundtrip changed pixels: {path}")
    header = tga_header(path)
    if (
        header["image_type"] != 2
        or header["bits_per_pixel"] != 32
        or (header["width"], header["height"]) != RUNTIME_SIZE
    ):
        raise ValueError(f"invalid runtime TGA: {path}: {header}")
    return roundtrip


def render_nine_slice(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    width, height = size
    x0, x1, x2, x3 = 0, SLICE_X[0], sum(SLICE_X[:2]), RUNTIME_SIZE[0]
    y0, y1, y2, y3 = 0, SLICE_Y[0], sum(SLICE_Y[:2]), RUNTIME_SIZE[1]
    output_widths = (SLICE_X[0], width - SLICE_X[0] - SLICE_X[2], SLICE_X[2])
    output_heights = (SLICE_Y[0], height - SLICE_Y[0] - SLICE_Y[2], SLICE_Y[2])
    x_edges = (x0, x1, x2, x3)
    y_edges = (y0, y1, y2, y3)
    result = Image.new("RGBA", size, (0, 0, 0, 0))
    target_y = 0
    for row, target_height in enumerate(output_heights):
        target_x = 0
        for column, target_width in enumerate(output_widths):
            tile = image.crop(
                (
                    x_edges[column],
                    y_edges[row],
                    x_edges[column + 1],
                    y_edges[row + 1],
                )
            ).resize((target_width, target_height), Image.Resampling.BILINEAR)
            result.alpha_composite(tile, (target_x, target_y))
            target_x += target_width
        target_y += target_height
    return result


def tint(texture: Image.Image, colour: tuple[int, int, int]) -> Image.Image:
    rgba = texture.convert("RGBA")
    pixels = [
        (
            red * colour[0] // 255,
            green * colour[1] // 255,
            blue * colour[2] // 255,
            alpha,
        )
        for red, green, blue, alpha in rgba.getdata()
    ]
    output = Image.new("RGBA", rgba.size)
    output.putdata(pixels)
    return output


def runtime_bar(path: Path, size: tuple[int, int], colour: tuple[int, int, int]) -> Image.Image:
    with Image.open(path) as opened:
        texture = opened.convert("RGBA")
    return tint(texture.resize(size, Image.Resampling.BILINEAR), colour)


def render_preview(outputs: dict[str, dict[str, Image.Image]]) -> None:
    canvas = Image.new("RGBA", (1180, 470), (23, 19, 16, 255))
    draw = ImageDraw.Draw(canvas)
    title = ImageFont.truetype(str(TITLE_FONT), 28)
    body = ImageFont.truetype(str(FONT), 17)
    small = ImageFont.truetype(str(FONT), 13)
    draw.text((34, 24), "UF-PRIMARY V4 · 240×60 Combat Focus 真实几何预演", font=title, fill=(218, 187, 124, 255))
    draw.text((36, 65), "完整锁定纹理经九切片只扩展动态开口；外缘厚度、Player／Target 身份端与状态语义保持独立。", font=small, fill=(174, 161, 137, 255))

    scenes = (
        ("player", (70, 150), "纳斯雷兹姆的灾祸", "悬停", (80, 128, 74), (44, 82, 128), 0.86, 0.72),
        ("target", (640, 150), "熔火巨人", "仇恨", (132, 58, 48), (52, 78, 118), 0.58, 0.35),
    )
    for role, position, name, state_label, health_colour, power_colour, hp, power in scenes:
        x, y = position
        art = outputs[role]
        canvas.alpha_composite(render_nine_slice(art["runtime"], PREVIEW_ART_SIZE), (x, y))
        frame_x, frame_y = x + 7, y + 6
        draw.rectangle((frame_x, frame_y, frame_x + 239, frame_y + 59), fill=(26, 20, 17, 255))
        health_width = max(1, round(240 * hp))
        canvas.alpha_composite(
            runtime_bar(HEALTH_TEXTURE, (health_width, 60), health_colour),
            (frame_x, frame_y),
        )
        draw.rectangle((frame_x, frame_y + 61, frame_x + 239, frame_y + 64), fill=(18, 17, 18, 255))
        power_width = max(1, round(240 * power))
        canvas.alpha_composite(
            runtime_bar(POWER_TEXTURE, (power_width, 4), power_colour),
            (frame_x, frame_y + 61),
        )
        canvas.alpha_composite(render_nine_slice(art["rim"], PREVIEW_ART_SIZE), (x, y))
        state = "hover" if role == "player" else "aggro"
        state_colour = (199, 164, 102) if state == "hover" else (157, 57, 30)
        state_art = tint(render_nine_slice(art[state], PREVIEW_ART_SIZE), state_colour)
        canvas.alpha_composite(state_art, (x, y))
        draw.text((frame_x + 8, frame_y + 19), name, font=body, fill=(239, 228, 202, 255))
        draw.text((frame_x + 231, frame_y + 19), f"{round(hp * 100)}%", font=body, fill=(239, 228, 202, 255), anchor="ra")
        draw.text((x, y + 100), f"{role.title()} · {state_label} · frame 240×65 / art 254×77", font=small, fill=(188, 172, 142, 255))

    draw.text((36, 420), "运行时仍由 pfUI 绘制名称、数值、生命／资源颜色、Aura、点击和事件；预演文字不进入 TGA。", font=small, fill=(160, 150, 132, 255))
    PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(PREVIEW, format="PNG", compress_level=9)


def main() -> int:
    outputs: dict[str, dict[str, Image.Image]] = {}
    runtime_records: dict[str, Any] = {}
    source_records: dict[str, Any] = {}

    for role, contract in ROLES.items():
        source_path = SOURCE_DIR / contract["source"]
        source = load_source(role, contract)
        runtime = make_runtime(source)
        rim = make_overlay_rim(runtime)
        hover = make_state_mask(rim, role, "hover")
        aggro = make_state_mask(rim, role, "aggro")
        role_outputs = {
            "runtime": runtime,
            "rim": rim,
            "hover": hover,
            "aggro": aggro,
        }
        outputs[role] = {}
        runtime_records[role] = {}
        for kind, image in role_outputs.items():
            filename = contract[kind]
            path = RUNTIME_DIR / filename
            roundtrip = save_runtime(image, path)
            outputs[role][kind] = roundtrip
            runtime_records[role][kind] = {
                "file": repository_path(path),
                "sha256": sha256(path),
                "tga_header": tga_header(path),
                "metrics": image_metrics(roundtrip),
            }
        source_records[role] = {
            "component": contract["component"],
            "file": repository_path(source_path),
            "sha256": sha256(source_path),
            "size": list(source.size),
        }

    render_preview(outputs)

    manifest = {
        "schema": "aeui-unitframes-primary-v4-runtime-manifest-v1",
        "status": "runtime-exported-addon-integrated",
        "phase": "P5",
        "module": "unitframes",
        "runtime_contract": "1.3",
        "components": ["UF.PLAYER.SHELL", "UF.TARGET.SHELL"],
        "source_manifest": repository_path(SOURCE_MANIFEST),
        "sources": source_records,
        "runtime": runtime_records,
        "deterministic_export": {
            "tool": "tools/build_unitframes_primary_v4_runtime.py",
            "source_to_runtime": [list(SOURCE_SIZE), list(RUNTIME_SIZE)],
            "operation": "whole-source LANCZOS downscale; live-bed Alpha clear for overlay rim; segmented edge masks derived from accepted rim Alpha",
            "redraw": False,
            "mirror": False,
            "cross_role_pixels": False,
            "imagegen_calls": 0,
        },
        "geometry": {
            "standard_runtime": list(RUNTIME_SIZE),
            "provider_live_bed": list(LIVE_BED),
            "nine_slice_x": list(SLICE_X),
            "nine_slice_y": list(SLICE_Y),
            "art_box_formula": "provider frame width + 14, provider frame height + 12",
            "live_opening_formula": "exact provider frame bounds",
            "complete_bitmap_vertical_stretch": False,
            "identity_caps_fixed": True,
            "provider_geometry_changed": False,
        },
        "adapter": {
            "file": "addon/AzerothExpeditionUI/Modules/UnitFrames.lua",
            "provider_bridge": "addon/pfUI/api/unitframes.lua",
            "ownership": "addon/pfUI/api/expedition.lua",
            "route": "unitframes.primary-shell",
            "frames": ["pfPlayer", "pfTarget"],
            "fallback": "hide AEUI slices and let pfUI rebuild configured backdrops/glows",
        },
        "preview": {
            "file": repository_path(PREVIEW),
            "tracked": False,
            "frame_size": list(PREVIEW_FRAME_SIZE),
            "art_size": list(PREVIEW_ART_SIZE),
        },
        "deployment": {
            "build_required_on_target_device": False,
            "game_validation": "pending Turtle WoW 1.18.1 / P6",
        },
    }
    RUNTIME_MANIFEST.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        "exported UF-PRIMARY V4 runtime: "
        f"{len(ROLES)} roles, {sum(len(value) for value in runtime_records.values())} TGA files"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
