#!/usr/bin/env python3
"""Promote and export the accepted UF-RAID-A2 sample-window contract.

Only the four fixed attempt-5 sample windows are promoted.  The rejected,
unused outer donor fields never enter ``assets/source`` or the addon.  The
accepted samples feed the existing deterministic shell builder; runtime media
is then exported from the four exact 592x296 RGBA masters.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
import subprocess
import sys
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops

from build_unitframes_raid_donor_shells_v1 import (
    ShellSet,
    build_shells,
    clear_transparent_rgb,
    load_donor_materials,
    render_source_preview,
)
from render_unitframes_raid_donor_simulation_v1 import render_review, render_scene


ROOT = Path(__file__).resolve().parents[1]
SPEC_PATH = ROOT / "tools/specs/unitframes_raid_donor_simulation_v1.json"
SOURCE_DIR = ROOT / "assets/source/unitframes/raid-a2"
SOURCE_MANIFEST = SOURCE_DIR / "UF-RAID-A2_SourceManifest_v1.json"
RUNTIME_MANIFEST = SOURCE_DIR / "UF-RAID-A2_RuntimeManifest_v1.json"
RUNTIME_DIR = ROOT / "addon/AzerothExpeditionUI/Media/UnitFrames"
PREVIEW_DIR = ROOT / "generated/unitframes/raid/A2/runtime"
DISPLAY_CONTRACT = ROOT / "tools/specs/unitframes_raid_runtime_display_region_v1.json"
DISPLAY_VALIDATOR = (
    ROOT / ".codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py"
)
DISPLAY_REPORT = PREVIEW_DIR / "display-region-report.json"

RAW_PATH = (
    ROOT
    / "generated/unitframes/raid/A2/DONOR-V1/attempt-05/"
    "uf-raid-a2-donor-v1-attempt-05.provider-native-01.png"
)
RAW_SHA256 = "dad020c26b772a26b856688bc0f5c4cf804b5d0f0ff932846feb37a701a6f159"
TECHNICAL_REPORT_SHA256 = (
    "9018df186f4710fa90156b6001a93326630a4b0894287262b97e5374fc3ee5e6"
)
EXECUTOR_SESSION = "019ff547-a187-70d2-b123-f6b2960ae9eb"
PROVIDER_RESULT = "ig_08662f5db7697b89016a7c3ba4bae08191a3c895ac74d50469"

MATERIAL_FILES = {
    "leather": "RaidMaterialLeather_SampleV1.png",
    "liner": "RaidMaterialLiner_SampleV1.png",
    "brass": "RaidMaterialBrass_SampleV1.png",
    "thread": "RaidMaterialThread_SampleV1.png",
}
SOURCE_FILES = {
    variant: f"RaidMemberShell{variant}_MasterV1.png"
    for variant in ("A", "B", "C", "D")
}
RUNTIME_FILES = {
    variant: f"RaidMemberShell{variant}V1.tga"
    for variant in ("A", "B", "C", "D")
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--promote-donor",
        type=Path,
        help="Exact accepted attempt-5 raw; only fixed sample windows are copied.",
    )
    parser.add_argument("--spec", type=Path, default=SPEC_PATH)
    parser.add_argument("--source-dir", type=Path, default=SOURCE_DIR)
    parser.add_argument("--runtime-dir", type=Path, default=RUNTIME_DIR)
    parser.add_argument("--preview-dir", type=Path, default=PREVIEW_DIR)
    parser.add_argument("--display-contract", type=Path, default=DISPLAY_CONTRACT)
    return parser.parse_args()


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pixel_sha256(image: Image.Image) -> str:
    return hashlib.sha256(image.convert("RGBA").tobytes()).hexdigest()


def repository_path(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


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
        "transparent_rgb_nonzero_values": transparent_rgb_nonzero(rgba),
    }


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", compress_level=9)


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


def verify_tga(path: Path, expected: Image.Image) -> Image.Image:
    with Image.open(path) as opened:
        roundtrip = opened.convert("RGBA")
    if roundtrip.size != (74, 37):
        raise ValueError(f"runtime must be 74x37: {path}")
    if ImageChops.difference(roundtrip, expected).getbbox() is not None:
        raise ValueError(f"runtime TGA changed pixels: {path}")
    header = tga_header(path)
    if (
        header["image_type"] != 2
        or header["bits_per_pixel"] != 32
        or (header["width"], header["height"]) != (74, 37)
    ):
        raise ValueError(f"invalid runtime TGA header: {path}: {header}")
    return roundtrip


def promote_exact_windows(spec: dict, donor_path: Path, source_dir: Path) -> None:
    donor_path = donor_path.resolve()
    if sha256(donor_path) != RAW_SHA256:
        raise ValueError("only exact UF-RAID-A2 attempt-5 raw may be promoted")
    with Image.open(donor_path) as opened:
        if opened.size != (1536, 1024) or opened.mode != "RGB":
            raise ValueError("accepted raw must remain 1536x1024 RGB")

    materials = load_donor_materials(spec, donor_path)
    for material_id, material in materials.items():
        if material.size != (512, 288) or material.mode != "RGB":
            raise ValueError(f"invalid fixed sample window: {material_id}")
        if visible_green_pixels(material):
            raise ValueError(f"accepted sample contains green: {material_id}")
        save_png(material, source_dir / MATERIAL_FILES[material_id])

    shells = build_shells(spec, materials)
    for variant, source in shells.sources.items():
        if source.size != (592, 296) or source.mode != "RGBA":
            raise ValueError(f"invalid deterministic source: {variant}")
        if source.getchannel("A").crop((16, 16, 576, 280)).getextrema() != (255, 255):
            raise ValueError(f"provider inset is not opaque: {variant}")
        if visible_green_pixels(source) or transparent_rgb_nonzero(source):
            raise ValueError(f"source transparency contract failed: {variant}")
        save_png(source, source_dir / SOURCE_FILES[variant])


def load_accepted_sources(
    spec: dict,
    source_dir: Path,
) -> tuple[dict[str, Image.Image], dict[str, Image.Image]]:
    materials: dict[str, Image.Image] = {}
    for material_id, filename in MATERIAL_FILES.items():
        path = source_dir / filename
        image = Image.open(path).convert("RGB")
        if image.size != (512, 288) or visible_green_pixels(image):
            raise ValueError(f"accepted material sample drifted: {path}")
        materials[material_id] = image

    rebuilt = build_shells(spec, materials)
    sources: dict[str, Image.Image] = {}
    for variant, filename in SOURCE_FILES.items():
        path = source_dir / filename
        source = Image.open(path).convert("RGBA")
        if source.size != (592, 296):
            raise ValueError(f"accepted shell source drifted: {path}")
        if ImageChops.difference(source, rebuilt.sources[variant]).getbbox() is not None:
            raise ValueError(f"source no longer matches deterministic builder: {variant}")
        if visible_green_pixels(source) or transparent_rgb_nonzero(source):
            raise ValueError(f"accepted shell transparency drifted: {variant}")
        sources[variant] = source
    return materials, sources


def export_runtime(
    sources: dict[str, Image.Image],
    runtime_dir: Path,
) -> dict[str, Image.Image]:
    runtimes: dict[str, Image.Image] = {}
    runtime_dir.mkdir(parents=True, exist_ok=True)
    for variant, source in sources.items():
        runtime = clear_transparent_rgb(
            source.resize((74, 37), Image.Resampling.LANCZOS)
        )
        path = runtime_dir / RUNTIME_FILES[variant]
        runtime.save(path, format="TGA")
        runtimes[variant] = verify_tga(path, runtime)
    return runtimes


def run_display_gate(contract: Path, report: Path) -> dict[str, Any]:
    report.parent.mkdir(parents=True, exist_ok=True)
    command = [
        sys.executable,
        str(DISPLAY_VALIDATOR),
        str(contract.resolve()),
        "--report",
        str(report.resolve()),
    ]
    subprocess.run(command, cwd=ROOT, check=True)
    payload = json.loads(report.read_text(encoding="utf-8"))
    if payload.get("status") != "pass":
        raise ValueError(f"display-region gate failed: {payload}")
    return payload


def package_gate_record(path: Path) -> dict[str, Any]:
    record: dict[str, Any] = {
        "file": repository_path(path),
        "status": "pending",
    }
    if not path.is_file():
        return record
    payload = json.loads(path.read_text(encoding="utf-8"))
    record.update(
        {
            "status": "present",
            "sha256": sha256(path),
            "schema": payload.get("schema"),
            "package_status": payload.get("status"),
            "build_required_on_target_device": payload.get(
                "build_required_on_target_device"
            ),
            "violations": payload.get("violations", []),
        }
    )
    return record


def write_manifests(
    spec: dict,
    source_dir: Path,
    runtime_dir: Path,
    preview_dir: Path,
    materials: dict[str, Image.Image],
    sources: dict[str, Image.Image],
    runtimes: dict[str, Image.Image],
    display_payload: dict[str, Any],
) -> None:
    material_records: dict[str, Any] = {}
    for material_id, filename in MATERIAL_FILES.items():
        path = source_dir / filename
        contract = spec["donor_contract"]["cells"][material_id]
        material_records[material_id] = {
            "file": repository_path(path),
            "sha256": sha256(path),
            "size": [512, 288],
            "mode": "RGB",
            "raw_sample_window": contract["sample_window"],
            "role": contract["role"],
            "visible_green_spill_pixels": visible_green_pixels(materials[material_id]),
        }

    source_records: dict[str, Any] = {}
    runtime_records: dict[str, Any] = {}
    for variant in ("A", "B", "C", "D"):
        source_path = source_dir / SOURCE_FILES[variant]
        runtime_path = runtime_dir / RUNTIME_FILES[variant]
        source_records[variant] = {
            "component": f"UF.RAID.MEMBER.SHELL.{variant}",
            "file": repository_path(source_path),
            "sha256": sha256(source_path),
            "metrics": image_metrics(sources[variant]),
        }
        runtime_records[variant] = {
            "component": f"UF.RAID.MEMBER.SHELL.{variant}",
            "file": repository_path(runtime_path),
            "sha256": sha256(runtime_path),
            "tga_header": tga_header(runtime_path),
            "metrics": image_metrics(runtimes[variant]),
            "full_uv": [0.0, 1.0, 0.0, 1.0],
            "three_slice_uv": {
                "left": [0.0, 0.08108108108108109, 0.0, 1.0],
                "centre": [0.08108108108108109, 0.918918918918919, 0.0, 1.0],
                "right": [0.918918918918919, 1.0, 0.0, 1.0],
            },
        }

    source_preview = preview_dir / "source-preview.png"
    real_scene = preview_dir / "real-layout-scene.png"
    real_review = preview_dir / "real-layout-review.png"
    display_report = preview_dir / "display-region-report.json"
    package_report = preview_dir / "addon-package-report.json"

    source_manifest = {
        "schema": "aeui-unitframes-raid-a2-source-manifest-v1",
        "schema_version": 1,
        "module": "unitframes",
        "batch": "UF-RAID-A2-DONOR V1",
        "components": [
            "UF.RAID.MEMBER.SHELL.A",
            "UF.RAID.MEMBER.SHELL.B",
            "UF.RAID.MEMBER.SHELL.C",
            "UF.RAID.MEMBER.SHELL.D",
        ],
        "status": "accepted-source",
        "phase": "P4",
        "accepted_on": "2026-08-12",
        "user_acceptance": {
            "exact_statement": (
                "接受 UF-RAID-A2-DONOR V1 attempt 5 的运行时视觉，并授权 "
                "sample-window-only 确定性合同例外进入 P4/P5；仅豁免未消费"
                "外围 field bbox 的最大 19px 偏差，其余固定 sample window、"
                "Python 外壳、A–D 维修、透明清理、592×296 source、74×37 "
                "runtime、6/62/6 三切片及 40 人排版合同保持不变。"
            ),
            "accepts_exact_attempt": 5,
            "accepts_runtime_visual": True,
            "exception_scope": "unused outer field bbox only; maximum deviation 19px",
            "sample_windows_accepted": True,
            "outer_field_pixels_accepted": False,
            "p4_p5_authorized": True,
        },
        "provenance": {
            "executor": "imagegen-0-143-0",
            "codex_package": "@openai/codex@0.143.0",
            "session_id": EXECUTOR_SESSION,
            "provider_result": PROVIDER_RESULT,
            "provider_raw_path": repository_path(RAW_PATH),
            "provider_raw_sha256": RAW_SHA256,
            "technical_report_sha256": TECHNICAL_REPORT_SHA256,
            "prompt_version": "UF-RAID-A2-DONOR V1.r4",
            "prompt_body_sha256": (
                "ed3ec1599512a5b6c42695334bc1466e560ac010b428b3261f4503fba30bb078"
            ),
            "prompt": "docs/modules/unitframes/SUBMODULE_ART_BASELINES.md#ufraidmembershella-d",
            "actual_imagegen_calls": 5,
            "remaining_imagegen_calls": 0,
            "process_errors": 2,
            "sixth_call_forbidden": True,
        },
        "sample_window_exception": {
            "strict_outer_field_gate": "failed; maximum bbox deviation 19px",
            "consumed_sample_windows": "4/4 pass; zero dominant-green pixels",
            "promotion_rule": "only the four fixed 512x288 crops are persisted",
            "raw_donor_promoted": False,
            "unconsumed_outer_field_promoted": False,
            "crop_coordinates_frozen": True,
        },
        "accepted_material_samples": material_records,
        "shell_sources": source_records,
        "deterministic_builder": {
            "tool": "tools/build_unitframes_raid_donor_shells_v1.py",
            "normalized_source": [592, 296],
            "provider_inset": [16, 16, 576, 280],
            "quiet_name_zone": [40, 48, 552, 232],
            "source_three_slice": [48, 496, 48],
            "runtime_three_slice": [6, 62, 6],
            "variant_order": ["A", "B", "C", "D"],
            "repairs": spec["deterministic_builder"]["variant_repair_bounds"],
            "generative_postprocess": False,
        },
        "visual_authority": {
            "global_prompt": "docs/GLOBAL_ART_BASELINE.md",
            "module_prompt": "docs/modules/unitframes/ART_BASELINE.md",
            "submodule_prompt": "docs/modules/unitframes/SUBMODULE_ART_BASELINES.md#ufraidmembershella-d",
            "component_contract": "docs/modules/unitframes/SUBMODULES.md",
            "locked_references": [
                "assets/locked/chat/聊天框视觉基准_v1.png",
                "assets/locked/chat/聊天框独立艺术资源_v3.png",
            ],
            "simulation_pixels_are_authority": False,
            "rejected_a1_pixels_are_authority": False,
        },
        "runtime_mapping": {
            "provider": "pfRaid1..pfRaid40",
            "slot_assignment": spec["simulation"]["variant_slot_order"],
            "runtime_repeat_count": 40,
            "provider_button": [70, 33],
            "runtime_shell": [74, 37],
            "height_mismatch": "fail-open to pfUI",
        },
        "forbidden_runtime_uses": [
            "load the attempt-5 raw donor or material sample PNGs from Lua",
            "consume pixels outside the four fixed sample windows",
            "bake names, values, colours, auras, raid glyphs or state into shell art",
            "change Secure Button geometry, hitboxes, roster, events or SavedVariables",
            "vertically stretch the shell when provider height differs from 33px",
        ],
        "export_contract": {
            "status": "runtime-exported",
            "tool": "tools/build_unitframes_raid_a2_runtime.py",
            "runtime_manifest": repository_path(RUNTIME_MANIFEST),
            "operation": (
                "whole-source LANCZOS 592x296 to 74x37, transparent RGB clear, "
                "four independent 32-bit RGBA TGA files, 6/62/6 UV slices"
            ),
        },
        "review_evidence": {
            "source_preview": repository_path(source_preview),
            "source_preview_sha256": sha256(source_preview),
            "real_layout_scene": repository_path(real_scene),
            "real_layout_scene_sha256": sha256(real_scene),
            "real_layout_review": repository_path(real_review),
            "real_layout_review_sha256": sha256(real_review),
            "display_region_report": repository_path(display_report),
            "display_region_report_sha256": sha256(display_report),
            "display_region_status": display_payload["status"],
        },
    }
    SOURCE_MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    SOURCE_MANIFEST.write_text(
        json.dumps(source_manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    runtime_manifest = {
        "schema": "aeui-unitframes-raid-a2-runtime-manifest-v1",
        "status": "runtime-exported",
        "phase": "P5",
        "runtime_contract": "1.1",
        "module": "unitframes",
        "components": source_manifest["components"],
        "source_manifest": repository_path(SOURCE_MANIFEST),
        "source_manifest_sha256": sha256(SOURCE_MANIFEST),
        "runtime": runtime_records,
        "deterministic_export": {
            "tool": "tools/build_unitframes_raid_a2_runtime.py",
            "source_to_runtime": [[592, 296], [74, 37]],
            "resample": "Pillow LANCZOS",
            "transparent_rgb_clear": True,
            "source_three_slice": [48, 496, 48],
            "runtime_three_slice": [6, 62, 6],
            "standard_width_uses_complete_texture": True,
            "variable_width_uses_three_texture_objects_with_uv_slices": True,
            "vertical_stretch": False,
            "redraw": False,
            "mirror": False,
            "foreign_pixels_mixed": False,
        },
        "adapter": {
            "file": "addon/AzerothExpeditionUI/Modules/UnitFrames.lua",
            "provider_bridge": "addon/pfUI/api/unitframes.lua",
            "provider_ownership": "addon/pfUI/api/expedition.lua",
            "frames": "pfRaid1..pfRaid40 only",
            "full_texture_at_width_70": True,
            "three_slice_for_other_widths": True,
            "height_33_required": True,
            "provider_hitbox_changed": False,
            "fallback": "remove AEUI shell and restore pfUI backdrops/bar media",
        },
        "real_layout": {
            "scene": repository_path(real_scene),
            "scene_sha256": sha256(real_scene),
            "review": repository_path(real_review),
            "review_sha256": sha256(real_review),
            "object_count": 40,
            "formation": "10x4 VERTICAL",
            "cluster_visual_envelope": [767, 159],
            "ui_pixel_scale": "1 image pixel = 1 UI pixel",
        },
        "display_region": {
            "contract": repository_path(DISPLAY_CONTRACT),
            "report": repository_path(DISPLAY_REPORT),
            "report_sha256": sha256(DISPLAY_REPORT),
            "status": display_payload["status"],
            "scenario_count": len(display_payload.get("scenarios", [])),
            "violation_count": len(display_payload.get("violations", [])),
            "first_failure": display_payload.get("first_failure"),
        },
        "deployment": {
            "addon_directories": ["addon/pfUI", "addon/AzerothExpeditionUI"],
            "build_required_on_target_device": False,
            "addon_package_gate": package_gate_record(package_report),
            "game_validation": "pending Turtle WoW 1.18.1 / P6",
        },
    }
    RUNTIME_MANIFEST.write_text(
        json.dumps(runtime_manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def main() -> None:
    args = parse_args()
    spec = json.loads(args.spec.resolve().read_text(encoding="utf-8"))
    source_dir = args.source_dir.resolve()
    runtime_dir = args.runtime_dir.resolve()
    preview_dir = args.preview_dir.resolve()
    source_dir.mkdir(parents=True, exist_ok=True)
    preview_dir.mkdir(parents=True, exist_ok=True)

    if args.promote_donor:
        promote_exact_windows(spec, args.promote_donor, source_dir)

    materials, sources = load_accepted_sources(spec, source_dir)
    runtimes = export_runtime(sources, runtime_dir)
    shell_set = ShellSet(materials=materials, sources=sources, runtimes=runtimes)

    source_preview = preview_dir / "source-preview.png"
    real_scene = preview_dir / "real-layout-scene.png"
    real_review = preview_dir / "real-layout-review.png"
    save_png(render_source_preview(spec, shell_set, "accepted"), source_preview)
    save_png(
        render_scene(spec, shell_set, candidate=True, accepted_runtime=True),
        real_scene,
    )
    save_png(
        render_review(spec, shell_set, candidate=True, accepted_runtime=True),
        real_review,
    )

    display_payload = run_display_gate(args.display_contract, DISPLAY_REPORT)
    write_manifests(
        spec,
        source_dir,
        runtime_dir,
        preview_dir,
        materials,
        sources,
        runtimes,
        display_payload,
    )
    print(SOURCE_MANIFEST.resolve())
    print(RUNTIME_MANIFEST.resolve())
    for variant in ("A", "B", "C", "D"):
        print((runtime_dir / RUNTIME_FILES[variant]).resolve())
    print(real_review.resolve())


if __name__ == "__main__":
    main()
