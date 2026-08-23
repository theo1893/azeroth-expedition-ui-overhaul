#!/usr/bin/env python3
"""Export accepted UF-B1 V2 bar donors and final runtime evidence."""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
import subprocess
import sys
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageStat


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets/source/unitframes/bars-v2"
HEALTH_SOURCE = SOURCE_DIR / "UnitFrameHealthFill_Master_v1.png"
POWER_SOURCE = SOURCE_DIR / "UnitFramePowerFill_Master_v1.png"
SOURCE_MANIFEST = SOURCE_DIR / "UF-B1-V2_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "UF-B1-V2_RuntimeManifest_v1.json"
RUNTIME_DIR = ROOT / "addon/AzerothExpeditionUI/Media/UnitFrames"
HEALTH_RUNTIME = RUNTIME_DIR / "UnitFrameHealthFillV1.tga"
POWER_RUNTIME = RUNTIME_DIR / "UnitFramePowerFillV1.tga"
DISPLAY_CONTRACT = (
    ROOT / "tools/specs/unitframes_bars_v2_runtime_display_region_v1.json"
)
DISPLAY_VALIDATOR = (
    ROOT
    / ".codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py"
)
PREVIEW_DIR = ROOT / "generated/unitframes/bars/V2/runtime"
RUNTIME_ATLAS_PREVIEW = PREVIEW_DIR / "runtime-review-atlas.png"
REAL_LAYOUT_PREVIEW = PREVIEW_DIR / "real-layout-preview.png"
REAL_LAYOUT_METRICS = PREVIEW_DIR / "real-layout-metrics.json"
DISPLAY_REPORT = PREVIEW_DIR / "display-region-report.json"

EXPECTED_HEALTH_SHA256 = (
    "8d19ffe95d5314b463d88be793568667aa555460a955364a636e6ddc76508e1f"
)
EXPECTED_POWER_SHA256 = (
    "0668eddbb6c7644312eecc3c1d03f555b937d5307e48444ca520a6674cb387f1"
)
HEALTH_SOURCE_SIZE = (256, 128)
POWER_SOURCE_SIZE = (256, 64)
HEALTH_LOGICAL_SIZE = (64, 32)
POWER_LOGICAL_SIZE = (64, 16)
HEALTH_RUNTIME_SIZE = (128, 64)
POWER_RUNTIME_SIZE = (128, 32)
TEXELS_PER_UI = 2
RESAMPLE = Image.Resampling.LANCZOS
FONT = ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSansSC-Medium.ttf"
TITLE_FONT = (
    ROOT / "addon/AzerothExpeditionUI/Media/Fonts/NotoSerifSC-SemiBold.ttf"
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--health-source", type=Path, default=HEALTH_SOURCE)
    parser.add_argument("--power-source", type=Path, default=POWER_SOURCE)
    parser.add_argument("--health-runtime", type=Path, default=HEALTH_RUNTIME)
    parser.add_argument("--power-runtime", type=Path, default=POWER_RUNTIME)
    parser.add_argument("--source-manifest", type=Path, default=SOURCE_MANIFEST)
    parser.add_argument("--runtime-manifest", type=Path, default=RUNTIME_MANIFEST)
    parser.add_argument("--preview-dir", type=Path, default=PREVIEW_DIR)
    parser.add_argument("--display-contract", type=Path, default=DISPLAY_CONTRACT)
    return parser.parse_args()


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def repository_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def clear_transparent_rgb(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = []
    for red, green, blue, alpha in rgba.getdata():
        if alpha == 0:
            pixels.append((0, 0, 0, 0))
        else:
            pixels.append((red, green, blue, alpha))
    clean = Image.new("RGBA", rgba.size)
    clean.putdata(pixels)
    return clean


def alpha_evidence(image: Image.Image) -> dict[str, int]:
    histogram = image.getchannel("A").histogram()
    return {
        "transparent_pixels": histogram[0],
        "partially_transparent_pixels": sum(histogram[1:255]),
        "opaque_pixels": histogram[255],
    }


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


def unequal_rgb_pixels(image: Image.Image) -> int:
    return sum(
        1
        for red, green, blue, alpha in image.convert("RGBA").getdata()
        if alpha and not (red == green == blue)
    )


def validate_source(
    path: Path,
    image: Image.Image,
    expected_sha256: str,
    expected_size: tuple[int, int],
) -> None:
    if sha256(path) != expected_sha256:
        raise ValueError(f"accepted source SHA-256 changed: {path}")
    if image.mode != "RGBA" or image.size != expected_size:
        raise ValueError(
            f"accepted source must be {expected_size} RGBA, "
            f"got {image.size} {image.mode}: {path}"
        )
    if image.getchannel("A").getbbox() != (0, 0, *expected_size):
        raise ValueError(f"accepted source no longer covers its full donor: {path}")
    if visible_green_pixels(image):
        raise ValueError(f"accepted source contains visible green spill: {path}")
    if transparent_rgb_nonzero(image):
        raise ValueError(f"accepted source contains dirty transparent RGB: {path}")
    if unequal_rgb_pixels(image):
        raise ValueError(f"accepted source is no longer equal-channel grayscale: {path}")


def build_runtime(source: Image.Image, size: tuple[int, int]) -> Image.Image:
    return clear_transparent_rgb(source.resize(size, RESAMPLE))


def save_tga(image: Image.Image, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, format="TGA")


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


def verify_runtime_roundtrip(
    path: Path,
    expected: Image.Image,
    size: tuple[int, int],
) -> Image.Image:
    with Image.open(path) as opened:
        roundtrip = opened.convert("RGBA")
    if roundtrip.size != size:
        raise ValueError(f"runtime TGA size changed: {path}")
    if ImageChops.difference(roundtrip, expected).getbbox() is not None:
        raise ValueError(f"runtime TGA roundtrip changed pixels: {path}")
    header = tga_header(path)
    if (
        header["image_type"] != 2
        or (header["width"], header["height"]) != size
        or header["bits_per_pixel"] != 32
    ):
        raise ValueError(f"runtime TGA header is invalid: {header}")
    return roundtrip


def grayscale_metrics(image: Image.Image) -> dict[str, Any]:
    rgba = image.convert("RGBA")
    alpha = rgba.getchannel("A")
    values = [
        red
        for red, green, blue, opacity in rgba.getdata()
        if opacity >= 128
    ]
    stat = ImageStat.Stat(Image.new("L", (len(values), 1), 0))
    if values:
        value_image = Image.new("L", (len(values), 1))
        value_image.putdata(values)
        stat = ImageStat.Stat(value_image)
    return {
        "size": list(rgba.size),
        "mode": rgba.mode,
        "pixel_sha256": pixel_sha256(rgba),
        "visible_bbox_exclusive": list(alpha.getbbox() or (0, 0, 0, 0)),
        "equal_channel": unequal_rgb_pixels(rgba) == 0,
        "value_mean_alpha_gte_128": round(stat.mean[0], 6) if values else 0.0,
        "value_stddev_alpha_gte_128": (
            round(stat.stddev[0], 6) if values else 0.0
        ),
        "visible_green_spill_pixels": visible_green_pixels(rgba),
        "transparent_rgb_nonzero_values": transparent_rgb_nonzero(rgba),
        **alpha_evidence(rgba),
    }


def font(size: int, title: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(TITLE_FONT if title else FONT), size)


def tint_texture(
    texture: Image.Image,
    colour: tuple[int, int, int],
    size: tuple[int, int],
) -> Image.Image:
    resized = texture.resize(size, RESAMPLE).convert("RGBA")
    output = []
    for grey, _, _, alpha in resized.getdata():
        output.append(
            (
                (grey * colour[0] + 127) // 255,
                (grey * colour[1] + 127) // 255,
                (grey * colour[2] + 127) // 255,
                alpha,
            )
        )
    tinted = Image.new("RGBA", size)
    tinted.putdata(output)
    return clear_transparent_rgb(tinted)


def draw_fallback_frame(
    scene: Image.Image,
    draw: ImageDraw.ImageDraw,
    health: Image.Image,
    power: Image.Image,
    *,
    frame_xy: tuple[int, int],
    frame_size: tuple[int, int],
    health_box: tuple[int, int, int, int],
    power_box: tuple[int, int, int, int],
    label: str,
    health_colour: tuple[int, int, int],
    power_colour: tuple[int, int, int],
    health_fraction: float,
    power_fraction: float,
) -> dict[str, Any]:
    x, y = frame_xy
    width, height = frame_size
    draw.rectangle(
        (x, y, x + width - 1, y + height - 1),
        fill=(22, 16, 13, 255),
        outline=(100, 69, 36, 255),
        width=2,
    )
    hx0, hy0, hx1, hy1 = health_box
    px0, py0, px1, py1 = power_box
    health_width = max(1, round((hx1 - hx0) * health_fraction))
    power_width = max(1, round((px1 - px0) * power_fraction))
    scene.alpha_composite(
        tint_texture(
            health,
            health_colour,
            (health_width, hy1 - hy0),
        ),
        (x + hx0, y + hy0),
    )
    scene.alpha_composite(
        tint_texture(
            power,
            power_colour,
            (power_width, py1 - py0),
        ),
        (x + px0, y + py0),
    )
    text_y = y + hy0 + max(7, (hy1 - hy0) // 2)
    draw.text(
        (x + hx0 + 4, text_y),
        label,
        font=font(10),
        fill=(238, 222, 184, 255),
        anchor="lm",
    )
    draw.text(
        (x + hx1 - 4, text_y),
        f"{round(health_fraction * 100)}%",
        font=font(9),
        fill=(239, 226, 194, 255),
        anchor="rm",
    )
    return {
        "frame_xywh": [x, y, width, height],
        "health_box_xyxy": list(health_box),
        "power_box_xyxy": list(power_box),
        "health_fraction": health_fraction,
        "power_fraction": power_fraction,
    }


def render_real_layout(
    health: Image.Image,
    power: Image.Image,
    destination: Path,
) -> dict[str, Any]:
    scene = Image.new("RGBA", (1600, 900), (13, 16, 18, 255))
    draw = ImageDraw.Draw(scene, "RGBA")
    for y in range(88, 900, 48):
        offset = 44 if (y // 48) % 2 else 0
        for x in range(-40 + offset, 1600, 96):
            draw.polygon(
                [(x, y + 3), (x + 87, y), (x + 91, y + 40), (x + 2, y + 44)],
                fill=(24, 27, 27, 255),
                outline=(37, 36, 32, 255),
            )
    draw.rectangle((0, 0, 1600, 78), fill=(18, 16, 14, 250))
    draw.text(
        (30, 15),
        "UF-B1 V2 · final runtime bars at 100% UI pixels",
        font=font(24, True),
        fill=(225, 196, 139, 255),
    )
    draw.text(
        (32, 49),
        "Accepted bar media is authoritative; unfinished shells remain pfUI fallback.",
        font=font(12),
        fill=(190, 171, 142, 255),
    )

    cases = [
        (
            "Player · Mana",
            (90, 130),
            (214, 42),
            (7, 6, 207, 31),
            (7, 32, 207, 36),
            (102, 206, 92),
            (128, 128, 255),
            0.93,
            0.72,
        ),
        (
            "Player · Rage",
            (90, 228),
            (214, 42),
            (7, 6, 207, 31),
            (7, 32, 207, 36),
            (103, 202, 89),
            (255, 128, 128),
            0.78,
            0.64,
        ),
        (
            "Player · Focus",
            (90, 326),
            (214, 42),
            (7, 6, 207, 31),
            (7, 32, 207, 36),
            (102, 198, 88),
            (255, 191, 96),
            0.66,
            0.81,
        ),
        (
            "Player · Energy",
            (90, 424),
            (214, 42),
            (7, 6, 207, 31),
            (7, 32, 207, 36),
            (104, 204, 90),
            (255, 255, 128),
            0.84,
            0.57,
        ),
        (
            "Target · Hostile",
            (410, 130),
            (214, 42),
            (7, 6, 207, 31),
            (7, 32, 207, 36),
            (255, 95, 82),
            (128, 128, 255),
            0.58,
            0.89,
        ),
        (
            "TargetTarget",
            (410, 228),
            (112, 34),
            (6, 6, 106, 26),
            (6, 27, 106, 28),
            (112, 204, 96),
            (255, 128, 128),
            0.71,
            0.42,
        ),
        (
            "Focus",
            (410, 326),
            (112, 39),
            (6, 6, 106, 31),
            (6, 32, 106, 33),
            (108, 201, 94),
            (128, 128, 255),
            0.87,
            0.75,
        ),
    ]
    layout: dict[str, Any] = {}
    for case in cases:
        (
            label,
            frame_xy,
            frame_size,
            health_box,
            power_box,
            health_colour,
            power_colour,
            health_fraction,
            power_fraction,
        ) = case
        draw.text(
            (frame_xy[0], frame_xy[1] - 21),
            label,
            font=font(12),
            fill=(207, 188, 154, 255),
        )
        layout[label] = draw_fallback_frame(
            scene,
            draw,
            health,
            power,
            frame_xy=frame_xy,
            frame_size=frame_size,
            health_box=health_box,
            power_box=power_box,
            label="远征者 60",
            health_colour=health_colour,
            power_colour=power_colour,
            health_fraction=health_fraction,
            power_fraction=power_fraction,
        )

    draw.text(
        (760, 112),
        "Accepted 2× runtime · 2× nearest",
        font=font(15, True),
        fill=(211, 187, 137, 255),
    )
    health_zoom = health.resize((256, 128), Image.Resampling.NEAREST)
    power_zoom = power.resize((256, 64), Image.Resampling.NEAREST)
    scene.alpha_composite(health_zoom, (760, 150))
    scene.alpha_composite(power_zoom, (760, 320))
    draw.text(
        (760, 285),
        "Health 128×64 sampled / 64×32 UI",
        font=font(12),
        fill=(184, 169, 141, 255),
    )
    draw.text(
        (760, 392),
        "Power 128×32 sampled / 64×16 UI",
        font=font(12),
        fill=(184, 169, 141, 255),
    )

    draw.text(
        (1110, 112),
        "Provider tint parity",
        font=font(15, True),
        fill=(211, 187, 137, 255),
    )
    tint_cases = [
        ("Health", health, (102, 206, 92), 25),
        ("Mana", power, (128, 128, 255), 12),
        ("Rage", power, (255, 128, 128), 12),
        ("Focus", power, (255, 191, 96), 12),
        ("Energy", power, (255, 255, 128), 12),
    ]
    for index, (label, donor, colour, height) in enumerate(tint_cases):
        y = 156 + index * 68
        draw.text(
            (1110, y - 18),
            label,
            font=font(11),
            fill=(194, 179, 151, 255),
        )
        scene.alpha_composite(tint_texture(donor, colour, (390, height)), (1110, y))

    draw.text(
        (760, 490),
        "Runtime ownership retained by pfUI",
        font=font(15, True),
        fill=(211, 187, 137, 255),
    )
    for index, line in enumerate(
        (
            "SetStatusBarColor and UnitPowerType still supply all semantic colour.",
            "Value animation and horizontal clipping are unchanged.",
            "Names, numbers, icons, hitboxes, events and SavedVariables stay live.",
            "No Player/Target shell candidate is used in this export.",
        )
    ):
        draw.text(
            (760, 526 + index * 28),
            line,
            font=font(12),
            fill=(180, 165, 137, 255),
        )

    destination.parent.mkdir(parents=True, exist_ok=True)
    scene.save(destination, "PNG", optimize=False, compress_level=9)
    return {
        "schema": "aeui-unitframes-bars-v2-real-layout-v1",
        "canvas": [1600, 900],
        "ui_pixel_scale": "1 image pixel = 1 UI pixel",
        "authoritative": {
            "health_runtime_pixels": True,
            "power_runtime_pixels": True,
            "bar_geometry": True,
            "provider_tints": True,
            "fallback_shell_art": False,
        },
        "layout": layout,
    }


def run_display_validator(contract: Path, report: Path) -> dict[str, Any]:
    report.parent.mkdir(parents=True, exist_ok=True)
    result = subprocess.run(
        [
            sys.executable,
            str(DISPLAY_VALIDATOR),
            str(contract),
            "--report",
            str(report),
        ],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise ValueError(
            "Unit Frames runtime display-region validation failed: "
            + result.stdout
            + result.stderr
        )
    value = json.loads(report.read_text(encoding="utf-8"))
    if value.get("status") != "pass":
        raise ValueError("Unit Frames runtime display-region report did not pass")
    return value


def update_source_manifest(
    path: Path,
    health_runtime: Path,
    power_runtime: Path,
) -> None:
    value = json.loads(path.read_text(encoding="utf-8"))
    value["export_contract"]["status"] = "runtime-exported"
    value["export_contract"]["runtime_exports"] = [
        {
            "component": "UF.BAR.HEALTH.FILL",
            "file": repository_path(health_runtime),
            "sha256": sha256(health_runtime),
            "size": list(HEALTH_RUNTIME_SIZE),
            "logical_size": list(HEALTH_LOGICAL_SIZE),
            "texels_per_ui": TEXELS_PER_UI,
        },
        {
            "component": "UF.BAR.POWER.FILL",
            "file": repository_path(power_runtime),
            "sha256": sha256(power_runtime),
            "size": list(POWER_RUNTIME_SIZE),
            "logical_size": list(POWER_LOGICAL_SIZE),
            "texels_per_ui": TEXELS_PER_UI,
        },
    ]
    path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def write_runtime_manifest(
    path: Path,
    health_source: Path,
    power_source: Path,
    health_runtime: Path,
    power_runtime: Path,
    health_image: Image.Image,
    power_image: Image.Image,
    layout: dict[str, Any],
    display_report: dict[str, Any],
) -> None:
    value = {
        "schema": "aeui-unitframes-bars-v2-runtime-manifest-v1",
        "status": "runtime-exported",
        "phase": "P5",
        "runtime_contract": "1.1",
        "module": "unitframes",
        "components": [
            "UF.BAR.HEALTH.FILL",
            "UF.BAR.POWER.FILL",
        ],
        "source_manifest": repository_path(SOURCE_MANIFEST),
        "sources": {
            "health": {
                "file": repository_path(health_source),
                "sha256": sha256(health_source),
                "size": list(HEALTH_SOURCE_SIZE),
            },
            "power": {
                "file": repository_path(power_source),
                "sha256": sha256(power_source),
                "size": list(POWER_SOURCE_SIZE),
            },
        },
        "runtime": {
            "health": {
                "file": repository_path(health_runtime),
                "sha256": sha256(health_runtime),
                "tga_header": tga_header(health_runtime),
                "metrics": grayscale_metrics(health_image),
                "logical_size": list(HEALTH_LOGICAL_SIZE),
                "sampled_size": list(HEALTH_RUNTIME_SIZE),
                "texels_per_ui": TEXELS_PER_UI,
            },
            "power": {
                "file": repository_path(power_runtime),
                "sha256": sha256(power_runtime),
                "tga_header": tga_header(power_runtime),
                "metrics": grayscale_metrics(power_image),
                "logical_size": list(POWER_LOGICAL_SIZE),
                "sampled_size": list(POWER_RUNTIME_SIZE),
                "texels_per_ui": TEXELS_PER_UI,
            },
        },
        "deterministic_export": {
            "tool": "tools/build_unitframes_bars_v2_runtime.py",
            "operation": "independent whole-source LANCZOS resize, transparent RGB clear, 32-bit RGBA TGA write",
            "health_source_to_runtime": [list(HEALTH_SOURCE_SIZE), list(HEALTH_RUNTIME_SIZE)],
            "power_source_to_runtime": [list(POWER_SOURCE_SIZE), list(POWER_RUNTIME_SIZE)],
            "density": "2 texels per UI unit",
            "crop": False,
            "redraw": False,
            "mirror": False,
            "foreign_source_pixels_mixed": False,
            "dynamic_content_baked": False,
        },
        "adapter": {
            "file": "addon/AzerothExpeditionUI/Modules/UnitFrames.lua",
            "toc": "addon/AzerothExpeditionUI/AzerothExpeditionUI.toc",
            "provider_bridge": "addon/pfUI/api/unitframes.lua",
            "provider_ownership": "addon/pfUI/api/expedition.lua",
            "frames": ["player", "target", "targettarget", "focus"],
            "health_marker": "frame.aeuiHealthBarTexture",
            "power_marker": "frame.aeuiPowerBarTexture",
            "preserved_provider_behaviour": [
                "SetStatusBarColor health and reaction colours",
                "UnitPowerType Mana, Rage, Focus and Energy colours",
                "value animation and clipping",
                "bar backgrounds",
                "text and icon layers",
                "events, hitboxes and SavedVariables",
            ],
            "fallback": "clear AEUI markers and restore each frame.config bartexture/pbartexture through pfUI.media",
            "unowned_frames": [
                "party",
                "raid",
                "pet",
                "pet-target",
                "focus-target",
                "fallback",
            ],
        },
        "real_layout": {
            "file": repository_path(REAL_LAYOUT_PREVIEW),
            "sha256": sha256(REAL_LAYOUT_PREVIEW),
            "metrics": repository_path(REAL_LAYOUT_METRICS),
            "metrics_sha256": sha256(REAL_LAYOUT_METRICS),
            "scenario_count": len(layout["layout"]),
            "ui_pixel_scale": layout["ui_pixel_scale"],
            "unfinished_shell_fallback_is_authoritative": False,
        },
        "display_region": {
            "contract": repository_path(DISPLAY_CONTRACT),
            "report": repository_path(DISPLAY_REPORT),
            "report_sha256": sha256(DISPLAY_REPORT),
            "status": display_report["status"],
            "scenario_count": display_report["summary"]["scenario_count"],
            "violation_count": display_report["summary"]["violation_count"],
            "first_failure": display_report["summary"]["first_failure"],
        },
        "deployment": {
            "addon_directories": [
                "addon/pfUI",
                "addon/AzerothExpeditionUI",
            ],
            "build_required_on_target_device": False,
            "game_validation": "pending Turtle WoW 1.18.1 / P6",
        },
    }
    path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def main() -> None:
    args = parse_args()
    with Image.open(args.health_source) as opened:
        health_source = opened.convert("RGBA")
    with Image.open(args.power_source) as opened:
        power_source = opened.convert("RGBA")
    validate_source(
        args.health_source,
        health_source,
        EXPECTED_HEALTH_SHA256,
        HEALTH_SOURCE_SIZE,
    )
    validate_source(
        args.power_source,
        power_source,
        EXPECTED_POWER_SHA256,
        POWER_SOURCE_SIZE,
    )

    health_runtime_image = build_runtime(health_source, HEALTH_RUNTIME_SIZE)
    power_runtime_image = build_runtime(power_source, POWER_RUNTIME_SIZE)
    for name, image in (
        ("health", health_runtime_image),
        ("power", power_runtime_image),
    ):
        if unequal_rgb_pixels(image):
            raise ValueError(f"{name} runtime is not equal-channel grayscale")
        if visible_green_pixels(image) or transparent_rgb_nonzero(image):
            raise ValueError(f"{name} runtime Alpha hygiene failed")

    save_tga(health_runtime_image, args.health_runtime)
    save_tga(power_runtime_image, args.power_runtime)
    health_roundtrip = verify_runtime_roundtrip(
        args.health_runtime,
        health_runtime_image,
        HEALTH_RUNTIME_SIZE,
    )
    power_roundtrip = verify_runtime_roundtrip(
        args.power_runtime,
        power_runtime_image,
        POWER_RUNTIME_SIZE,
    )

    args.preview_dir.mkdir(parents=True, exist_ok=True)
    atlas = Image.new("RGBA", (64, 48), (0, 0, 0, 0))
    atlas.alpha_composite(health_roundtrip, (0, 0))
    atlas.alpha_composite(power_roundtrip, (0, 32))
    atlas.save(RUNTIME_ATLAS_PREVIEW, "PNG", optimize=False, compress_level=9)

    layout = render_real_layout(
        health_roundtrip,
        power_roundtrip,
        REAL_LAYOUT_PREVIEW,
    )
    REAL_LAYOUT_METRICS.write_text(
        json.dumps(layout, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    display_report = run_display_validator(
        args.display_contract,
        DISPLAY_REPORT,
    )
    update_source_manifest(
        args.source_manifest,
        args.health_runtime,
        args.power_runtime,
    )
    write_runtime_manifest(
        args.runtime_manifest,
        args.health_source,
        args.power_source,
        args.health_runtime,
        args.power_runtime,
        health_roundtrip,
        power_roundtrip,
        layout,
        display_report,
    )
    print(
        json.dumps(
            {
                "status": "runtime-exported",
                "health_runtime": {
                    "path": str(args.health_runtime),
                    "sha256": sha256(args.health_runtime),
                },
                "power_runtime": {
                    "path": str(args.power_runtime),
                    "sha256": sha256(args.power_runtime),
                },
                "real_layout": {
                    "path": str(REAL_LAYOUT_PREVIEW),
                    "sha256": sha256(REAL_LAYOUT_PREVIEW),
                },
                "display_region": display_report["summary"],
            },
            ensure_ascii=False,
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
