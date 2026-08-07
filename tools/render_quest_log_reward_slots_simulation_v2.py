#!/usr/bin/env python3
"""Render QL-D V2 with the accepted current Quest Log neighbours."""

from __future__ import annotations

import argparse
import json
import platform
import sys
from pathlib import Path

import PIL
from PIL import Image

from render_quest_log_reward_slots_simulation_v1 import render, resolve, sha256


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    return parser.parse_args()


def compose_current_neighbours(
    root: Path,
    spec: dict[str, object],
    report: dict[str, object],
) -> dict[str, object]:
    inputs = spec["inputs"]
    outputs = spec["outputs"]
    layout = spec["layout"]
    preview_path = resolve(root, outputs["preview"])
    review_path = resolve(root, outputs["review_2x"])
    report_path = resolve(root, outputs["report"])
    carrier_path = resolve(root, inputs["seal_carrier"])
    seal_path = resolve(root, inputs["seal_atlas"])

    image = Image.open(preview_path).convert("RGBA")
    carrier = Image.open(carrier_path).convert("RGBA")
    seal_atlas = Image.open(seal_path).convert("RGBA")

    carrier_x, carrier_y, carrier_width, carrier_height = layout[
        "seal_carrier_root"
    ]
    carrier_root = carrier.crop((0, 0, carrier_width, carrier_height))
    image.alpha_composite(carrier_root, (carrier_x, carrier_y))

    # The carrier is ARTWORK and the accepted seal is OVERLAY in runtime.
    # Reapply the normal seal after the root so the 24 px contact reads as a
    # physical wax-over-carrier overlap rather than two unrelated layers.
    seal_x, seal_y, seal_width, seal_height = layout["seal_visual"]
    seal_cell_width = seal_atlas.width // 4
    seal = seal_atlas.crop((0, 0, seal_cell_width, seal_atlas.height))
    seal = seal.resize((seal_width, seal_height), Image.Resampling.LANCZOS)
    image.alpha_composite(seal, (seal_x, seal_y))

    image.save(preview_path, optimize=True)
    review = image.resize(
        (image.width * 2, image.height * 2),
        Image.Resampling.NEAREST,
    )
    review.save(review_path, optimize=True)

    report["schema"] = "aeui.quest-log.reward-slots.simulation-report.v2"
    report["inputs"]["seal_carrier"] = {
        "path": inputs["seal_carrier"],
        "sha256": sha256(carrier_path),
    }
    report["outputs"]["preview"]["sha256"] = sha256(preview_path)
    report["outputs"]["review_2x"]["sha256"] = sha256(review_path)
    report["current_runtime_neighbours"] = [
        "QuestLogShellV4",
        "QS-A1 wax seal",
        "QS-B1 V7-A collapsed carrier root",
    ]
    report["z_order"] = [
        "QuestLogShellV4",
        "reward slot simulation and dynamic example content",
        "QS-B1 V7-A carrier root (ARTWORK)",
        "QS-A1 wax seal (OVERLAY)",
    ]
    report["environment"] = {
        "sys_executable": sys.executable,
        "python": platform.python_version(),
        "pillow": PIL.__version__,
        "os": platform.system(),
    }
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return report


def main() -> int:
    args = parse_args()
    root = args.repo_root.resolve()
    spec = json.loads(args.spec.read_text(encoding="utf-8"))
    report = render(root, spec)
    report = compose_current_neighbours(root, spec, report)
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
