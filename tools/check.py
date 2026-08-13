#!/usr/bin/env python3
"""Small, explicit checks for AEUI development.

This is intentionally not a unit-test runner. Turtle WoW remains the behavioral
authority; these checks only catch syntax, repository, and packaging mistakes.
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
AEUI = ROOT / "addon" / "AzerothExpeditionUI"
TOC = AEUI / "AzerothExpeditionUI.toc"
BOOTSTRAP = AEUI / "Core" / "Bootstrap.lua"

MODULE_FILES = {
    "core": (
        "addon/AzerothExpeditionUI/Core/Bootstrap.lua",
        "addon/pfUI/pfUI.lua",
        "addon/pfUI/api/expedition.lua",
    ),
    "actionbars": (
        "addon/AzerothExpeditionUI/Modules/ActionBars.lua",
        "addon/pfUI/modules/actionbar.lua",
        "addon/pfUI/modules/castbar.lua",
        "addon/pfUI/modules/swingtimer.lua",
    ),
    "chat": (
        "addon/AzerothExpeditionUI/Modules/Chat.lua",
        "addon/pfUI/modules/chat.lua",
    ),
    "quests": (
        "addon/AzerothExpeditionUI/Modules/Quests.lua",
        "addon/AzerothExpeditionUI/Modules/QuestVisualTheme.lua",
    ),
    "unitframes": (
        "addon/AzerothExpeditionUI/Modules/UnitFrames.lua",
        "addon/pfUI/api/unitframes.lua",
        "addon/pfUI/modules/raid.lua",
    ),
}


class CheckError(RuntimeError):
    pass


def command(args: list[str], *, capture: bool = True) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        args,
        cwd=ROOT,
        text=True,
        errors="replace",
        capture_output=capture,
        check=False,
    )
    if result.returncode:
        detail = (result.stdout or "") + (result.stderr or "")
        raise CheckError(f"{' '.join(args)} failed\n{detail.strip()}")
    return result


def repository_sanity() -> None:
    command(["git", "diff", "--check", "HEAD", "--", "."])

    if not TOC.is_file() or not BOOTSTRAP.is_file():
        raise CheckError("AEUI TOC or Bootstrap.lua is missing")

    toc_text = TOC.read_text(encoding="utf-8-sig")
    bootstrap_text = BOOTSTRAP.read_text(encoding="utf-8")
    toc_match = re.search(r"^## Version:\s*(\S+)\s*$", toc_text, re.MULTILINE)
    lua_match = re.search(r'addon\.version\s*=\s*"([^"]+)"', bootstrap_text)
    if not toc_match or not lua_match or toc_match.group(1) != lua_match.group(1):
        raise CheckError("TOC and Bootstrap versions do not match")

    for raw in toc_text.splitlines():
        entry = raw.strip()
        if not entry or entry.startswith("#"):
            continue
        target = AEUI / entry.replace("\\", "/")
        if not target.is_file():
            raise CheckError(f"TOC entry is missing: {entry}")

    markdown = sorted((ROOT / "addon").rglob("*.md"))
    if markdown:
        raise CheckError(f"Markdown is not allowed in addon/: {markdown[0]}")

    work_docs = sorted((ROOT / "docs" / "modules").glob("*/work/*.md"))
    if work_docs:
        raise CheckError(f"legacy work ledger found: {work_docs[0].relative_to(ROOT)}")

    for manifest in (ROOT / "assets" / "source").rglob("*Manifest*.json"):
        try:
            data = json.loads(manifest.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            raise CheckError(f"invalid manifest {manifest.relative_to(ROOT)}: {error}")
        if "RuntimeManifest" in manifest.name:
            reject_mutable_hashes(data, manifest)


def reject_mutable_hashes(value: object, manifest: Path) -> None:
    if isinstance(value, dict):
        file_value = value.get("file")
        if isinstance(file_value, str) and file_value.lower().endswith((".lua", ".toc")):
            if "sha256" in value:
                raise CheckError(
                    f"mutable code hash must be removed: {manifest.relative_to(ROOT)} -> {file_value}"
                )
        for child in value.values():
            reject_mutable_hashes(child, manifest)
    elif isinstance(value, list):
        for child in value:
            reject_mutable_hashes(child, manifest)


def changed_lua() -> set[Path]:
    paths: set[Path] = set()
    for args in (
        ["git", "diff", "--name-only", "HEAD", "--", "addon"],
        ["git", "ls-files", "--others", "--exclude-standard", "--", "addon"],
    ):
        output = command(args).stdout
        for line in output.splitlines():
            path = ROOT / line
            if path.suffix.lower() == ".lua" and path.is_file():
                paths.add(path)
    return paths


def lua_syntax(paths: set[Path]) -> int:
    if not paths:
        return 0
    luac = shutil.which("luac")
    if not luac:
        raise CheckError("luac is required for Lua syntax checking")
    ordered = sorted(paths)
    command([luac, "-p", *[str(path) for path in ordered]])
    return len(ordered)


def module_lua(module: str) -> set[Path]:
    if module == "all":
        paths = set(AEUI.rglob("*.lua"))
        for relatives in MODULE_FILES.values():
            paths.update(
                ROOT / relative
                for relative in relatives
                if (ROOT / relative).is_file()
            )
        return paths
    return {
        ROOT / relative
        for relative in MODULE_FILES.get(module, ())
        if (ROOT / relative).is_file()
    }


def package_check() -> tuple[int, int]:
    validator = (
        ROOT
        / ".codex"
        / "skills"
        / "run-aeui-asset-workflow"
        / "scripts"
        / "validate_addon_package.py"
    )
    result = command([sys.executable, str(validator), str(ROOT)])
    report = json.loads(result.stdout)
    return int(report.get("tracked_addon_files", 0)), int(
        report.get("runtime_manifest_records", 0)
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run the smallest useful AEUI check")
    parser.add_argument("mode", choices=("quick", "assets", "release"))
    parser.add_argument(
        "--module",
        choices=(*MODULE_FILES.keys(), "all"),
        default=None,
        help="owning module; quick defaults to changed Lua files",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        repository_sanity()
        lua_paths = changed_lua()
        if args.module:
            lua_paths.update(module_lua(args.module))
        if args.mode == "release":
            lua_paths.update(module_lua("all"))
        lua_count = lua_syntax(lua_paths)

        package_files = manifest_records = 0
        if args.mode in ("assets", "release"):
            package_files, manifest_records = package_check()
    except CheckError as error:
        print(f"FAIL: {error}", file=sys.stderr)
        return 1

    summary = f"PASS {args.mode}: repository; Lua files={lua_count}"
    if args.mode in ("assets", "release"):
        summary += f"; addon files={package_files}; manifest records={manifest_records}"
    print(summary)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
