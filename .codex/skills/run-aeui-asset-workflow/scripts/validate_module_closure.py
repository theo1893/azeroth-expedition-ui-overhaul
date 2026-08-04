#!/usr/bin/env python3
"""Validate that an accepted AEUI module has no intermediate repository data."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path, PurePosixPath


SCHEMA = "aeui-module-closure-report-v1"
DURABLE_DOCS = (
    "SUBMODULES.md",
    "ART_BASELINE.md",
    "SUBMODULE_ART_BASELINES.md",
    "PROGRESS.md",
)
TEXT_SUFFIXES = {".json", ".md", ".txt"}
SAFE_TOKEN = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]*$")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Validate terminal AEUI module cleanup after whole-module P6 "
            "acceptance. This command is read-only and never deletes files."
        )
    )
    parser.add_argument("repo_root", type=Path, help="AEUI repository root")
    parser.add_argument(
        "module",
        help="module directory name under docs/modules and generated",
    )
    parser.add_argument(
        "--generated-alias",
        action="append",
        default=[],
        help=(
            "legacy module token used in generated paths; may be repeated "
            "(for example quest or ql)"
        ),
    )
    parser.add_argument(
        "--legacy-generated-path",
        action="append",
        default=[],
        help=(
            "exact repository-relative legacy generated path that must be "
            "absent; may be repeated"
        ),
    )
    parser.add_argument("--report", type=Path, help="optional JSON report path")
    return parser.parse_args()


def add_violation(
    violations: list[dict[str, str]],
    code: str,
    path: str,
    detail: str,
) -> None:
    violations.append({"code": code, "path": path, "detail": detail})


def repo_path(root: Path, path: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return str(path)


def validate_token(parser: argparse.ArgumentParser, value: str, label: str) -> str:
    if not SAFE_TOKEN.fullmatch(value) or value in {".", ".."}:
        parser.error(f"{label} must be one safe path token: {value!r}")
    return value.casefold()


def parse_legacy_path(
    parser: argparse.ArgumentParser,
    value: str,
) -> PurePosixPath:
    normalized = value.replace("\\", "/")
    path = PurePosixPath(normalized)
    if (
        path.is_absolute()
        or ".." in path.parts
        or not path.parts
        or path.parts[0] != "generated"
        or len(path.parts) == 1
    ):
        parser.error(
            "--legacy-generated-path must be an exact child of generated/: "
            f"{value!r}"
        )
    return path


def component_matches_alias(component: str, aliases: set[str]) -> bool:
    value = component.casefold()
    return any(
        value == alias
        or value.startswith(f"{alias}-")
        or value.startswith(f"{alias}_")
        for alias in aliases
    )


def owned_prefix(relative: PurePosixPath, aliases: set[str]) -> PurePosixPath | None:
    for index, component in enumerate(relative.parts):
        if component_matches_alias(component, aliases):
            return PurePosixPath(*relative.parts[: index + 1])
    return None


def is_under(relative: PurePosixPath, parent: PurePosixPath) -> bool:
    return relative == parent or parent in relative.parents


def minimize_paths(paths: set[PurePosixPath]) -> list[PurePosixPath]:
    result: list[PurePosixPath] = []
    for path in sorted(paths, key=lambda item: (len(item.parts), item.as_posix())):
        if not any(is_under(path, parent) for parent in result):
            result.append(path)
    return result


def collect_generated_roots(
    root: Path,
    aliases: set[str],
    explicit: list[PurePosixPath],
) -> list[PurePosixPath]:
    generated = root / "generated"
    owned: set[PurePosixPath] = set()
    if generated.is_dir():
        for path in generated.rglob("*"):
            relative = PurePosixPath(path.relative_to(generated).as_posix())
            prefix = owned_prefix(relative, aliases)
            if prefix is not None:
                owned.add(PurePosixPath("generated") / prefix)
    for path in explicit:
        absolute = root / Path(path.as_posix())
        if absolute.exists() or absolute.is_symlink():
            owned.add(path)
    return minimize_paths(owned)


def git_tracked_generated(root: Path) -> list[PurePosixPath] | None:
    result = subprocess.run(
        ["git", "-C", str(root), "ls-files", "-z", "--", "generated"],
        check=False,
        capture_output=True,
    )
    if result.returncode != 0:
        return None
    return [
        PurePosixPath(item.decode("utf-8", errors="surrogateescape"))
        for item in result.stdout.split(b"\0")
        if item
    ]


def generated_reference_is_owned(text: str, aliases: set[str]) -> bool:
    normalized = text.replace("\\", "/").casefold()
    for match in re.finditer(r"generated/[^\s\]\[\)\(<>`\"']+", normalized):
        token = match.group(0).rstrip(".,;:，。；：")
        path = PurePosixPath(token)
        if len(path.parts) > 1 and owned_prefix(
            PurePosixPath(*path.parts[1:]), aliases
        ) is not None:
            return True
    return False


def collect_stale_references(
    root: Path,
    module_dir: Path,
    module: str,
    aliases: set[str],
) -> list[dict[str, object]]:
    scoped: list[tuple[Path, bool]] = []
    for name in DURABLE_DOCS:
        path = module_dir / name
        if path.is_file():
            scoped.append((path, True))

    source_root = root / "assets" / "source" / module
    if source_root.is_dir():
        for path in source_root.rglob("*"):
            if path.is_file() and path.suffix.casefold() in TEXT_SUFFIXES:
                scoped.append((path, True))

    for path in (root / "AGENTS.md", root / "docs" / "PROGRESS.md"):
        if path.is_file():
            scoped.append((path, False))

    records: list[dict[str, object]] = []
    for path, reject_any_generated in scoped:
        try:
            lines = path.read_text(encoding="utf-8").splitlines()
        except (OSError, UnicodeError):
            continue
        for line_number, line in enumerate(lines, start=1):
            normalized = line.replace("\\", "/").casefold()
            if "generated/" not in normalized:
                continue
            if path.suffix.casefold() == ".md":
                markdown_targets = re.findall(
                    r"!?\[[^\]]*\]\(([^)]+)\)",
                    line,
                )
                is_stale = any(
                    "generated/" in target.replace("\\", "/").casefold()
                    and (
                        reject_any_generated
                        or generated_reference_is_owned(target, aliases)
                    )
                    for target in markdown_targets
                )
            else:
                is_stale = reject_any_generated or generated_reference_is_owned(
                    line,
                    aliases,
                )
            if is_stale:
                records.append(
                    {
                        "path": repo_path(root, path),
                        "line": line_number,
                        "text": line.strip()[:240],
                    }
                )
    return records


def main() -> int:
    args = parse_args()
    validation_parser = argparse.ArgumentParser(prog=Path(sys.argv[0]).name)

    root = args.repo_root.expanduser().resolve()
    module = validate_token(validation_parser, args.module, "module")
    aliases = {module}
    if module.endswith("s") and len(module) > 2:
        aliases.add(module[:-1])
    aliases.update(
        validate_token(validation_parser, value, "generated alias")
        for value in args.generated_alias
    )
    explicit = [
        parse_legacy_path(validation_parser, value)
        for value in args.legacy_generated_path
    ]

    violations: list[dict[str, str]] = []
    module_dir = root / "docs" / "modules" / module
    missing_docs: list[str] = []
    for name in DURABLE_DOCS:
        path = module_dir / name
        if not path.is_file():
            relative = repo_path(root, path)
            missing_docs.append(relative)
            add_violation(
                violations,
                "MODULE_DOC_MISSING",
                relative,
                "terminal module closure retains all four durable module documents",
            )

    progress = module_dir / "PROGRESS.md"
    progress_text = (
        progress.read_text(encoding="utf-8") if progress.is_file() else ""
    )
    if "P6-C / module-closed" not in progress_text:
        add_violation(
            violations,
            "MODULE_NOT_CLOSED",
            repo_path(root, progress),
            "module progress lacks the exact P6-C / module-closed terminal marker",
        )
    if "模块验收范围" not in progress_text and "module acceptance scope" not in progress_text.casefold():
        add_violation(
            violations,
            "MODULE_ACCEPTANCE_SCOPE_MISSING",
            repo_path(root, progress),
            "module progress must freeze the whole-module P6 acceptance scope",
        )
    if "P6 实机证据" not in progress_text and "p6 validation evidence" not in progress_text.casefold():
        add_violation(
            violations,
            "MODULE_P6_EVIDENCE_MISSING",
            repo_path(root, progress),
            "module progress must retain concise real-client P6 evidence",
        )

    work_dir = module_dir / "work"
    work_entries: list[str] = []
    if work_dir.exists() or work_dir.is_symlink():
        if work_dir.is_dir() and not work_dir.is_symlink():
            work_entries = sorted(
                repo_path(root, path) for path in work_dir.rglob("*")
            )
        else:
            work_entries = [repo_path(root, work_dir)]
        add_violation(
            violations,
            "WORK_DIRECTORY_REMAINS",
            repo_path(root, work_dir),
            "module-closed state must remove the entire work directory",
        )

    generated_roots = collect_generated_roots(root, aliases, explicit)
    for path in generated_roots:
        add_violation(
            violations,
            "GENERATED_DATA_REMAINS",
            path.as_posix(),
            "module-owned generated data remains after terminal cleanup",
        )

    tracked = git_tracked_generated(root)
    tracked_owned: list[str] = []
    if tracked is None:
        add_violation(
            violations,
            "GIT_INDEX_UNAVAILABLE",
            ".git",
            "could not inspect tracked generated files",
        )
    else:
        for path in tracked:
            relative_to_generated = PurePosixPath(*path.parts[1:])
            alias_owned = owned_prefix(relative_to_generated, aliases) is not None
            explicit_owned = any(is_under(path, target) for target in explicit)
            if alias_owned or explicit_owned:
                tracked_owned.append(path.as_posix())
        for path in tracked_owned:
            add_violation(
                violations,
                "TRACKED_GENERATED_DATA_REMAINS",
                path,
                "Git index still contains module-owned generated data",
            )

    stale_references = collect_stale_references(
        root,
        module_dir,
        module,
        aliases,
    )
    for record in stale_references:
        add_violation(
            violations,
            "STALE_GENERATED_REFERENCE",
            f"{record['path']}:{record['line']}",
            "durable module state still references deleted or ephemeral generated data",
        )

    violations.sort(key=lambda item: (item["code"], item["path"], item["detail"]))
    report = {
        "schema": SCHEMA,
        "module": module,
        "status": "pass" if not violations else "fail",
        "terminal_marker": "P6-C / module-closed",
        "generated_aliases": sorted(aliases),
        "legacy_generated_paths": [path.as_posix() for path in explicit],
        "generated_roots_remaining": [path.as_posix() for path in generated_roots],
        "tracked_generated_files_remaining": sorted(tracked_owned),
        "work_directory_present": work_dir.exists() or work_dir.is_symlink(),
        "work_entries_remaining": work_entries,
        "missing_durable_docs": missing_docs,
        "stale_generated_references": stale_references,
        "violations": violations,
    }
    rendered = json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    if args.report:
        report_path = args.report.expanduser().resolve()
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(rendered, encoding="utf-8")
    sys.stdout.write(rendered)
    return 0 if not violations else 1


if __name__ == "__main__":
    raise SystemExit(main())
