#!/usr/bin/env python3
"""Validate that a fresh checkout contains directly installable AEUI addons."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Any


SCHEMA = "aeui-addon-package-report-v1"
RUNTIME_SUFFIXES = {
    ".blp",
    ".lua",
    ".ogg",
    ".tga",
    ".toc",
    ".ttf",
    ".wav",
    ".xml",
}
TEXT_SUFFIXES = {".lua", ".toc", ".xml"}
FORBIDDEN_RUNTIME_REFERENCES = (
    "assets/source/",
    "generated/",
    "handoff/",
    ".codex/",
    "tools/",
    "/users/",
    "/home/",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Validate a fresh-checkout addon package that can be copied into "
            "Interface/AddOns without a build or generation step."
        )
    )
    parser.add_argument(
        "repo_root",
        type=Path,
        help="repository root containing addon/",
    )
    parser.add_argument(
        "--required-addon",
        action="append",
        default=[],
        help=(
            "addon directory that must be present; may be repeated. "
            "pfUI and AzerothExpeditionUI are always required."
        ),
    )
    parser.add_argument(
        "--report",
        type=Path,
        help="optional JSON report path",
    )
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def is_power_of_two(value: int) -> bool:
    return value > 0 and value & (value - 1) == 0


def tga_size(path: Path) -> tuple[int, int] | None:
    data = path.read_bytes()[:18]
    if len(data) < 18:
        return None
    return (
        int.from_bytes(data[12:14], "little"),
        int.from_bytes(data[14:16], "little"),
    )


def as_repo_path(root: Path, path: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return str(path)


def exact_case_file(path: Path, stop: Path) -> bool:
    """Return True only when every path component has its exact stored case."""

    try:
        relative = path.relative_to(stop)
    except ValueError:
        return False

    current = stop
    if not current.is_dir():
        return False
    for part in relative.parts:
        try:
            names = os.listdir(current)
        except OSError:
            return False
        if part not in names:
            return False
        current = current / part
    return current.is_file()


def add_violation(
    violations: list[dict[str, str]],
    code: str,
    path: str,
    detail: str,
) -> None:
    violations.append({"code": code, "path": path, "detail": detail})


def parse_toc_entries(toc: Path) -> tuple[list[str], list[str]]:
    entries: list[str] = []
    dependencies: list[str] = []
    for raw_line in toc.read_text(encoding="utf-8-sig").splitlines():
        line = raw_line.strip()
        if not line:
            continue
        if line.lower().startswith("## requireddeps:"):
            value = line.split(":", 1)[1]
            dependencies.extend(
                token for token in re.split(r"[\s,]+", value.strip()) if token
            )
            continue
        if line.startswith("#"):
            continue
        entries.append(line.replace("\\", "/"))
    return entries, dependencies


def collect_runtime_manifest_paths(
    value: Any,
    records: list[tuple[str, str | None]],
) -> None:
    if isinstance(value, dict):
        direct_file = value.get("file")
        direct_hash = value.get("sha256")
        if (
            isinstance(direct_file, str)
            and direct_file.startswith("addon/")
            and Path(direct_file).suffix.lower() in RUNTIME_SUFFIXES
        ):
            records.append(
                (
                    direct_file,
                    direct_hash if isinstance(direct_hash, str) else None,
                )
            )
        for child in value.values():
            collect_runtime_manifest_paths(child, records)
    elif isinstance(value, list):
        for child in value:
            collect_runtime_manifest_paths(child, records)
    elif (
        isinstance(value, str)
        and value.startswith("addon/")
        and " " not in value
        and Path(value).suffix.lower() in RUNTIME_SUFFIXES
    ):
        records.append((value, None))


def collect_runtime_texture_records(
    value: object,
    records: list[tuple[str, tuple[int, int]]],
) -> None:
    if isinstance(value, dict):
        file_value = value.get("file")
        texture_size = value.get("texture_size")
        if (
            isinstance(file_value, str)
            and file_value.lower().endswith(".tga")
            and isinstance(texture_size, list)
            and len(texture_size) == 2
            and all(isinstance(item, int) for item in texture_size)
        ):
            records.append((file_value, (texture_size[0], texture_size[1])))
        for child in value.values():
            collect_runtime_texture_records(child, records)
    elif isinstance(value, list):
        for child in value:
            collect_runtime_texture_records(child, records)


def validate_texel_density_records(
    value: object,
    manifest_path: str,
    violations: list[dict[str, str]],
) -> None:
    """Validate opt-in high-density records without burdening legacy assets."""

    if isinstance(value, dict):
        logical_size = value.get("logical_size_ui", value.get("logical_size"))
        sampled_size = value.get("sampled_size")
        density = value.get("texels_per_ui_unit")
        if (
            isinstance(logical_size, list)
            and len(logical_size) == 2
            and all(isinstance(item, int) for item in logical_size)
            and isinstance(sampled_size, list)
            and len(sampled_size) == 2
            and all(isinstance(item, int) for item in sampled_size)
            and isinstance(density, int)
        ):
            expected = [item * density for item in logical_size]
            if density < 1 or sampled_size != expected:
                add_violation(
                    violations,
                    "RUNTIME_TEXEL_DENSITY_MISMATCH",
                    manifest_path,
                    "sampled_size must equal logical UI size multiplied by "
                    f"texels_per_ui_unit; logical={logical_size}, "
                    f"density={density}, sampled={sampled_size}",
                )
            texture_size = value.get("texture_size")
            if (
                isinstance(texture_size, list)
                and len(texture_size) == 2
                and all(isinstance(item, int) for item in texture_size)
                and any(
                    sampled_size[index] > texture_size[index]
                    for index in range(2)
                )
            ):
                add_violation(
                    violations,
                    "RUNTIME_SAMPLE_EXCEEDS_TEXTURE",
                    manifest_path,
                    f"sampled={sampled_size}, texture={texture_size}",
                )
        for child in value.values():
            validate_texel_density_records(child, manifest_path, violations)
    elif isinstance(value, list):
        for child in value:
            validate_texel_density_records(child, manifest_path, violations)


def git_tracked_addon_files(root: Path) -> set[str] | None:
    result = subprocess.run(
        ["git", "-C", str(root), "ls-files", "-z", "--", "addon"],
        check=False,
        capture_output=True,
    )
    if result.returncode != 0:
        return None
    return {
        item.decode("utf-8", errors="surrogateescape")
        for item in result.stdout.split(b"\0")
        if item
    }


def main() -> int:
    args = parse_args()
    root = args.repo_root.expanduser().resolve()
    addon_root = root / "addon"
    violations: list[dict[str, str]] = []
    required_addons = list(
        dict.fromkeys(["pfUI", "AzerothExpeditionUI", *args.required_addon])
    )

    if not addon_root.is_dir():
        add_violation(
            violations,
            "ADDON_ROOT_MISSING",
            "addon",
            "repository does not contain addon/",
        )
        addon_directories: list[Path] = []
    else:
        addon_directories = sorted(
            path
            for path in addon_root.iterdir()
            if path.is_dir() and list(path.glob("*.toc"))
        )

    discovered = {path.name for path in addon_directories}
    for name in required_addons:
        if name not in discovered:
            add_violation(
                violations,
                "REQUIRED_ADDON_MISSING",
                f"addon/{name}",
                "required deployable addon directory or TOC is missing",
            )

    if addon_root.is_dir():
        for path in addon_root.rglob("*"):
            if path.is_symlink():
                add_violation(
                    violations,
                    "ADDON_SYMLINK_FORBIDDEN",
                    as_repo_path(root, path),
                    "runtime packages must not depend on local symlink targets",
                )

    tracked = git_tracked_addon_files(root)
    if tracked is None:
        add_violation(
            violations,
            "GIT_INDEX_UNAVAILABLE",
            ".git",
            "could not read tracked addon files from Git",
        )
        tracked_count = 0
    else:
        tracked_count = len(tracked)
        if addon_root.is_dir():
            for path in addon_root.rglob("*"):
                if not path.is_file() or path.is_symlink():
                    continue
                relative = as_repo_path(root, path)
                if relative not in tracked:
                    add_violation(
                        violations,
                        "ADDON_FILE_UNTRACKED",
                        relative,
                        "fresh checkouts would not receive this runtime file",
                    )
        for relative in tracked:
            path = root / relative
            if not path.is_file():
                add_violation(
                    violations,
                    "TRACKED_ADDON_FILE_MISSING",
                    relative,
                    "Git records a runtime file that is absent from the checkout",
                )

    toc_files: list[str] = []
    loaded_entries: dict[str, set[str]] = {}
    for addon_dir in addon_directories:
        loaded_entries[addon_dir.name] = set()
        for toc in sorted(addon_dir.glob("*.toc")):
            toc_files.append(as_repo_path(root, toc))
            entries, dependencies = parse_toc_entries(toc)
            loaded_entries[addon_dir.name].update(entries)
            for entry in entries:
                target = (addon_dir / Path(entry)).resolve()
                if not exact_case_file(target, addon_dir):
                    add_violation(
                        violations,
                        "TOC_PATH_MISSING_OR_CASE_MISMATCH",
                        as_repo_path(root, toc),
                        f"TOC entry does not resolve with exact case: {entry}",
                    )
            for dependency in dependencies:
                if dependency not in discovered:
                    add_violation(
                        violations,
                        "REQUIRED_DEPENDENCY_MISSING",
                        as_repo_path(root, toc),
                        f"RequiredDeps addon is absent: {dependency}",
                    )

    if addon_root.is_dir():
        for xml in addon_root.rglob("*.xml"):
            source = xml.read_text(encoding="utf-8-sig")
            owning_addon = next(
                (
                    addon_dir
                    for addon_dir in addon_directories
                    if xml.is_relative_to(addon_dir)
                ),
                addon_root,
            )
            for reference in re.findall(
                r'<(?:Include|Script)\s+file="([^"]+)"',
                source,
            ):
                target = (
                    xml.parent / Path(reference.replace("\\", "/"))
                ).resolve()
                if not exact_case_file(target, owning_addon):
                    add_violation(
                        violations,
                        "XML_PATH_MISSING_OR_CASE_MISMATCH",
                        as_repo_path(root, xml),
                        f"XML reference does not resolve with exact case: {reference}",
                    )

        for path in addon_root.rglob("*"):
            if not path.is_file() or path.suffix.lower() not in TEXT_SUFFIXES:
                continue
            source = path.read_text(encoding="utf-8-sig", errors="replace")
            normalized = source.lower().replace("\\", "/")
            for forbidden in FORBIDDEN_RUNTIME_REFERENCES:
                if forbidden in normalized:
                    add_violation(
                        violations,
                        "RUNTIME_DEVELOPMENT_PATH_REFERENCE",
                        as_repo_path(root, path),
                        f"runtime text references development-only path: {forbidden}",
                    )
            if re.search(r"(?:^|[\"'])\s*[a-z]:[\\/]", source, re.I | re.M):
                add_violation(
                    violations,
                    "RUNTIME_ABSOLUTE_PATH_REFERENCE",
                    as_repo_path(root, path),
                    "runtime text contains an absolute Windows path",
                )

    aeui_dir = addon_root / "AzerothExpeditionUI"
    aeui_toc_entries = loaded_entries.get("AzerothExpeditionUI", set())
    if aeui_dir.is_dir():
        for directory in (aeui_dir / "Core", aeui_dir / "Modules"):
            if not directory.is_dir():
                continue
            for lua in sorted(directory.glob("*.lua")):
                entry = lua.relative_to(aeui_dir).as_posix()
                if entry not in aeui_toc_entries:
                    add_violation(
                        violations,
                        "AEUI_RUNTIME_FILE_NOT_LOADED",
                        as_repo_path(root, lua),
                        "Core/Modules Lua file is not listed by an AEUI TOC",
                    )

    manifest_records: list[tuple[str, str | None]] = []
    source_root = root / "assets" / "source"
    if source_root.is_dir():
        for manifest in source_root.rglob("*RuntimeManifest*.json"):
            try:
                data = json.loads(manifest.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError) as error:
                add_violation(
                    violations,
                    "RUNTIME_MANIFEST_INVALID",
                    as_repo_path(root, manifest),
                    str(error),
                )
                continue
            records: list[tuple[str, str | None]] = []
            collect_runtime_manifest_paths(data, records)
            manifest_records.extend(records)
            for relative, expected_hash in records:
                target = root / relative
                if not exact_case_file(target, root):
                    add_violation(
                        violations,
                        "MANIFEST_RUNTIME_MISSING_OR_CASE_MISMATCH",
                        as_repo_path(root, manifest),
                        f"runtime path does not resolve with exact case: {relative}",
                    )
                elif expected_hash and sha256(target) != expected_hash:
                    add_violation(
                        violations,
                        "MANIFEST_RUNTIME_HASH_MISMATCH",
                        relative,
                        f"runtime bytes differ from {as_repo_path(root, manifest)}",
                    )
            texture_records: list[tuple[str, tuple[int, int]]] = []
            collect_runtime_texture_records(data, texture_records)
            for relative, expected_size in texture_records:
                target = root / relative
                if not target.is_file():
                    continue
                actual_size = tga_size(target)
                if (
                    actual_size != expected_size
                    or actual_size is None
                    or not all(is_power_of_two(value) for value in actual_size)
                    or max(actual_size) > 1024
                ):
                    add_violation(
                        violations,
                        "TGA_TEXTURE_CONTAINER_INCOMPATIBLE",
                        relative,
                        "Turtle WoW 1.12 TGA must match its manifest and use "
                        f"power-of-two dimensions no larger than 1024; "
                        f"manifest={expected_size}, actual={actual_size}",
                    )
            validate_texel_density_records(
                data,
                as_repo_path(root, manifest),
                violations,
            )

    report = {
        "schema": SCHEMA,
        "status": "fail" if violations else "pass",
        "repository": str(root),
        "addon_root": "addon",
        "required_addons": required_addons,
        "discovered_addons": sorted(discovered),
        "toc_files": toc_files,
        "tracked_addon_files": tracked_count,
        "runtime_manifest_records": len(set(manifest_records)),
        "build_required_on_target_device": False,
        "deployment": [f"addon/{name}" for name in sorted(discovered)],
        "violations": violations,
    }
    rendered = json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True)
    if args.report:
        report_path = args.report.expanduser()
        if not report_path.is_absolute():
            report_path = root / report_path
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(rendered + "\n", encoding="utf-8")
    print(rendered)
    return 1 if violations else 0


if __name__ == "__main__":
    sys.exit(main())
