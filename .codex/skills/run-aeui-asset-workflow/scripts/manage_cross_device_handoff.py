#!/usr/bin/env python3
"""Publish or validate minimal AEUI cross-device handoff checkpoints."""

from __future__ import annotations

import argparse
import hashlib
import json
import mimetypes
import shutil
import subprocess
import sys
import tempfile
import uuid
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath


SCHEMA = "aeui-cross-device-handoff-v1"
REPORT_SCHEMA = "aeui-cross-device-handoff-report-v1"
MAX_PAYLOADS = 3
MAX_PAYLOAD_BYTES = 16 * 1024 * 1024
MAX_TOTAL_BYTES = 32 * 1024 * 1024
SAFE_TOKEN_CHARS = frozenset(
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-"
)
STATE_POLICIES = {
    "simulation-reviewed": {
        "required": {"review-preview"},
        "allowed": {"review-preview", "review-zoom"},
        "attempt_limit": 0,
    },
    "candidate-reviewed": {
        "required": {"candidate", "real-layout-preview"},
        "allowed": {
            "candidate",
            "real-layout-preview",
            "technical-preview",
        },
        "attempt_limit": 5,
    },
    "repair-prepared": {
        "required": {"edit-input"},
        "allowed": {
            "edit-input",
            "real-layout-preview",
            "technical-preview",
        },
        "attempt_limit": 5,
    },
    "candidate-rejected": {
        "required": {"candidate", "real-layout-preview"},
        "allowed": {
            "candidate",
            "real-layout-preview",
            "technical-preview",
        },
        "attempt_limit": 5,
    },
}
PROTECTED_BRANCHES = {"main", "master"}


class HandoffError(RuntimeError):
    """Raised when a handoff checkpoint violates the repository contract."""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Publish or validate minimal cross-device AEUI handoff checkpoints "
            "without tracking the complete generated/ tree."
        )
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    publish = subparsers.add_parser(
        "publish",
        help="publish one component checkpoint under handoff/",
    )
    publish.add_argument("repo_root", type=Path)
    publish.add_argument("--module", required=True)
    publish.add_argument("--component", required=True)
    publish.add_argument("--state", required=True, choices=sorted(STATE_POLICIES))
    publish.add_argument("--work-file", required=True)
    publish.add_argument("--prompt-version", required=True)
    publish.add_argument("--next-gate", required=True)
    publish.add_argument("--attempts-used", required=True, type=int)
    publish.add_argument("--attempt-limit", required=True, type=int)
    publish.add_argument("--process-errors", default=0, type=int)
    publish.add_argument(
        "--payload",
        action="append",
        default=[],
        metavar="ROLE=PATH",
        help=(
            "checkpoint payload; repeat at most three times. Roles are "
            "state-specific, for example edit-input or review-preview"
        ),
    )
    publish.add_argument(
        "--replace",
        action="store_true",
        help="atomically replace an already valid checkpoint for this component",
    )

    validate = subparsers.add_parser(
        "validate",
        help="validate all or one tracked handoff checkpoint",
    )
    validate.add_argument("repo_root", type=Path)
    validate.add_argument("--module")
    validate.add_argument("--component")
    validate.add_argument("--report", type=Path)
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def safe_token(value: str, label: str) -> str:
    if (
        not value
        or value in {".", ".."}
        or value[0] not in SAFE_TOKEN_CHARS
        or any(character not in SAFE_TOKEN_CHARS for character in value)
    ):
        raise HandoffError(f"{label} must be one safe path token: {value!r}")
    return value


def repo_relative(root: Path, path: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError as error:
        raise HandoffError(f"path escapes repository: {path}") from error


def resolve_repo_file(root: Path, value: str, label: str) -> Path:
    candidate = Path(value).expanduser()
    if not candidate.is_absolute():
        candidate = root / candidate
    candidate = candidate.absolute()
    if candidate.is_symlink():
        raise HandoffError(f"{label} may not be a symlink: {value}")
    try:
        resolved = candidate.resolve(strict=True)
    except (OSError, ValueError) as error:
        raise HandoffError(f"{label} does not exist: {value}") from error
    repo_relative(root, resolved)
    if not resolved.is_file():
        raise HandoffError(f"{label} must be a regular repository file: {value}")
    return resolved


def run_git(root: Path, arguments: list[str]) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(
        ["git", "-C", str(root), *arguments],
        check=False,
        capture_output=True,
    )


def require_repository(root: Path) -> str:
    result = run_git(root, ["rev-parse", "--show-toplevel"])
    if result.returncode != 0:
        raise HandoffError("repo_root is not a Git worktree")
    actual = Path(result.stdout.decode("utf-8").strip()).resolve()
    if actual != root:
        raise HandoffError(f"repo_root must be the worktree root: {actual}")
    head = run_git(root, ["rev-parse", "HEAD"])
    if head.returncode != 0:
        raise HandoffError("repository has no committed HEAD")
    return head.stdout.decode("utf-8").strip()


def current_branch(root: Path) -> str:
    result = run_git(root, ["symbolic-ref", "--quiet", "--short", "HEAD"])
    if result.returncode != 0:
        raise HandoffError("handoff requires a named collaboration branch, not detached HEAD")
    branch = result.stdout.decode("utf-8").strip()
    if not branch:
        raise HandoffError("could not resolve the current collaboration branch")
    return branch


def protected_branches(root: Path) -> set[str]:
    protected = set(PROTECTED_BRANCHES)
    remote_head = run_git(
        root,
        ["symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD"],
    )
    if remote_head.returncode == 0:
        name = remote_head.stdout.decode("utf-8").strip()
        if name.startswith("origin/") and len(name) > len("origin/"):
            protected.add(name[len("origin/") :])
    return protected


def require_clean_tracked_tree(root: Path) -> None:
    result = run_git(root, ["status", "--porcelain", "--untracked-files=no"])
    if result.returncode != 0:
        raise HandoffError("could not inspect tracked worktree state")
    if result.stdout.strip():
        raise HandoffError(
            "tracked worktree is dirty; commit all tracked state before publishing handoff"
        )


def require_committed_work(root: Path, work_file: Path) -> None:
    relative = repo_relative(root, work_file)
    tracked = run_git(root, ["ls-files", "--error-unmatch", "--", relative])
    if tracked.returncode != 0:
        raise HandoffError(f"work file is not tracked: {relative}")
    for arguments, label in (
        (["diff", "--quiet", "--", relative], "unstaged"),
        (["diff", "--cached", "--quiet", "--", relative], "staged"),
    ):
        result = run_git(root, arguments)
        if result.returncode != 0:
            raise HandoffError(
                f"work file has {label} changes; commit it before handoff: {relative}"
            )


def parse_payloads(
    root: Path,
    state: str,
    values: list[str],
) -> list[tuple[str, Path]]:
    if not values:
        raise HandoffError(f"{state} requires checkpoint payloads")
    if len(values) > MAX_PAYLOADS:
        raise HandoffError(f"handoff allows at most {MAX_PAYLOADS} payloads")

    policy = STATE_POLICIES[state]
    records: list[tuple[str, Path]] = []
    roles: set[str] = set()
    total = 0
    for value in values:
        if "=" not in value:
            raise HandoffError(f"payload must use ROLE=PATH: {value!r}")
        role, raw_path = value.split("=", 1)
        safe_token(role, "payload role")
        if role in roles:
            raise HandoffError(f"duplicate payload role: {role}")
        if role not in policy["allowed"]:
            raise HandoffError(f"payload role {role!r} is invalid for {state}")
        source = resolve_repo_file(root, raw_path, f"payload {role}")
        size = source.stat().st_size
        if size > MAX_PAYLOAD_BYTES:
            raise HandoffError(
                f"payload {role} exceeds {MAX_PAYLOAD_BYTES} bytes: {size}"
            )
        total += size
        roles.add(role)
        records.append((role, source))

    missing = sorted(policy["required"] - roles)
    if missing:
        raise HandoffError(f"{state} is missing required payload roles: {missing}")
    if total > MAX_TOTAL_BYTES:
        raise HandoffError(
            f"handoff payload total exceeds {MAX_TOTAL_BYTES} bytes: {total}"
        )
    return records


def validate_attempt_budget(
    state: str,
    used: int,
    limit: int,
    process_errors: int,
) -> None:
    expected_limit = int(STATE_POLICIES[state]["attempt_limit"])
    if limit != expected_limit:
        raise HandoffError(
            f"{state} requires attempt limit {expected_limit}, got {limit}"
        )
    if used < 0 or used > limit:
        raise HandoffError(f"invalid attempt budget: {used}/{limit}")
    if process_errors < 0:
        raise HandoffError("process error count cannot be negative")


def add_violation(
    violations: list[dict[str, str]],
    code: str,
    path: str,
    detail: str,
) -> None:
    violations.append({"code": code, "path": path, "detail": detail})


def validate_checkpoint(
    root: Path,
    checkpoint: Path,
    violations: list[dict[str, str]],
    require_tracked: bool = True,
) -> dict[str, object] | None:
    manifest_path = checkpoint / "manifest.json"
    relative_checkpoint = repo_relative(root, checkpoint)
    if checkpoint.is_symlink():
        add_violation(
            violations,
            "CHECKPOINT_SYMLINK",
            relative_checkpoint,
            "handoff checkpoint must be self-contained in Git",
        )
        return None
    if not manifest_path.is_file() or manifest_path.is_symlink():
        add_violation(
            violations,
            "MANIFEST_MISSING",
            repo_relative(root, manifest_path),
            "checkpoint requires a regular manifest.json",
        )
        return None
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        add_violation(
            violations,
            "MANIFEST_INVALID",
            repo_relative(root, manifest_path),
            str(error),
        )
        return None
    if not isinstance(manifest, dict):
        add_violation(
            violations,
            "MANIFEST_INVALID",
            repo_relative(root, manifest_path),
            "manifest root must be a JSON object",
        )
        return None

    module = checkpoint.parent.name
    component = checkpoint.name
    if manifest.get("schema") != SCHEMA:
        add_violation(
            violations,
            "SCHEMA_INVALID",
            repo_relative(root, manifest_path),
            f"expected {SCHEMA}",
        )
    if manifest.get("module") != module or manifest.get("component") != component:
        add_violation(
            violations,
            "IDENTITY_MISMATCH",
            relative_checkpoint,
            "manifest module/component must match its directory",
        )

    for field in ("prompt_version", "next_gate", "created_at_utc"):
        value = manifest.get(field)
        if not isinstance(value, str) or not value.strip():
            add_violation(
                violations,
                "MANIFEST_FIELD_INVALID",
                repo_relative(root, manifest_path),
                f"{field} must be a non-empty string",
            )

    expected_contract = {
        "authoritative": False,
        "may_be_runtime_input": False,
        "may_be_source_without_explicit_acceptance": False,
        "replace_instead_of_accumulate": True,
        "remove_by_source_acceptance_or_p6_closure": True,
    }
    if manifest.get("contract") != expected_contract:
        add_violation(
            violations,
            "CONTRACT_INVALID",
            repo_relative(root, manifest_path),
            "handoff must remain non-authoritative, replace-only, and disposable",
        )

    state = manifest.get("state")
    policy = STATE_POLICIES.get(state)
    if policy is None:
        add_violation(
            violations,
            "STATE_INVALID",
            repo_relative(root, manifest_path),
            f"unsupported handoff state: {state!r}",
        )

    work_value = manifest.get("work_file")
    work_path: Path | None = None
    if not isinstance(work_value, str) or Path(work_value).is_absolute():
        add_violation(
            violations,
            "WORK_FILE_INVALID",
            repo_relative(root, manifest_path),
            "work_file must be a repository-relative path",
        )
    else:
        try:
            work_path = resolve_repo_file(root, work_value, "work file")
        except HandoffError as error:
            add_violation(
                violations,
                "WORK_FILE_INVALID",
                work_value,
                str(error),
            )
        if work_path is not None:
            relative_work = repo_relative(root, work_path)
            tracked = run_git(
                root,
                ["ls-files", "--error-unmatch", "--", relative_work],
            )
            if tracked.returncode != 0:
                add_violation(
                    violations,
                    "WORK_FILE_UNTRACKED",
                    work_value,
                    "checkpoint work file must be tracked by Git",
                )
            expected_work_hash = manifest.get("work_file_sha256")
            if expected_work_hash != sha256(work_path):
                add_violation(
                    violations,
                    "WORK_FILE_STALE",
                    work_value,
                    "work file changed after this checkpoint; republish handoff",
                )

    base_commit = manifest.get("base_commit")
    if not isinstance(base_commit, str):
        add_violation(
            violations,
            "BASE_COMMIT_INVALID",
            repo_relative(root, manifest_path),
            "base_commit is required",
        )
    else:
        ancestor = run_git(root, ["merge-base", "--is-ancestor", base_commit, "HEAD"])
        if ancestor.returncode != 0:
            add_violation(
                violations,
                "BASE_COMMIT_NOT_ANCESTOR",
                repo_relative(root, manifest_path),
                "checkpoint base commit is not an ancestor of current HEAD",
            )

    branch_value = manifest.get("branch")
    try:
        checkout_branch = current_branch(root)
    except HandoffError as error:
        add_violation(
            violations,
            "CHECKOUT_BRANCH_INVALID",
            repo_relative(root, manifest_path),
            str(error),
        )
        checkout_branch = None
    if not isinstance(branch_value, str) or not branch_value.strip():
        add_violation(
            violations,
            "BRANCH_INVALID",
            repo_relative(root, manifest_path),
            "manifest must name its collaboration branch",
        )
    elif checkout_branch is not None and branch_value != checkout_branch:
        add_violation(
            violations,
            "BRANCH_MISMATCH",
            repo_relative(root, manifest_path),
            f"checkpoint belongs to {branch_value!r}, checkout is {checkout_branch!r}",
        )
    if checkout_branch in protected_branches(root):
        add_violation(
            violations,
            "PROTECTED_BRANCH_HANDOFF",
            repo_relative(root, manifest_path),
            "temporary pixel checkpoints may not enter the default/protected branch",
        )

    budget = manifest.get("attempt_budget")
    if not isinstance(budget, dict):
        add_violation(
            violations,
            "BUDGET_INVALID",
            repo_relative(root, manifest_path),
            "attempt_budget must be an object",
        )
    elif policy is not None:
        used = budget.get("used")
        limit = budget.get("limit")
        process_errors = budget.get("process_errors")
        if not all(type(value) is int for value in (used, limit, process_errors)):
            add_violation(
                violations,
                "BUDGET_INVALID",
                repo_relative(root, manifest_path),
                "attempt budget fields must be integers",
            )
        else:
            try:
                validate_attempt_budget(state, used, limit, process_errors)
            except HandoffError as error:
                add_violation(
                    violations,
                    "BUDGET_INVALID",
                    repo_relative(root, manifest_path),
                    str(error),
                )

    payloads = manifest.get("payloads")
    payload_records = payloads if isinstance(payloads, list) else []
    if not isinstance(payloads, list) or not payload_records:
        add_violation(
            violations,
            "PAYLOADS_INVALID",
            repo_relative(root, manifest_path),
            "payloads must be a non-empty list",
        )
    if len(payload_records) > MAX_PAYLOADS:
        add_violation(
            violations,
            "PAYLOAD_COUNT_EXCEEDED",
            relative_checkpoint,
            f"maximum payload count is {MAX_PAYLOADS}",
        )

    roles: set[str] = set()
    expected_files = {manifest_path.resolve()}
    total_bytes = 0
    for record in payload_records:
        if not isinstance(record, dict):
            add_violation(
                violations,
                "PAYLOAD_RECORD_INVALID",
                relative_checkpoint,
                "payload record must be an object",
            )
            continue
        role = record.get("role")
        file_value = record.get("file")
        if not isinstance(role, str) or role in roles:
            add_violation(
                violations,
                "PAYLOAD_ROLE_INVALID",
                relative_checkpoint,
                f"invalid or duplicate role: {role!r}",
            )
            continue
        roles.add(role)
        if policy is not None and role not in policy["allowed"]:
            add_violation(
                violations,
                "PAYLOAD_ROLE_INVALID",
                relative_checkpoint,
                f"role {role!r} is invalid for {state}",
            )
        if not isinstance(file_value, str):
            add_violation(
                violations,
                "PAYLOAD_PATH_INVALID",
                relative_checkpoint,
                f"payload {role} lacks file path",
            )
            continue
        pure_payload_path = PurePosixPath(file_value)
        raw_payload_path = Path(file_value)
        if (
            raw_payload_path.is_absolute()
            or pure_payload_path.is_absolute()
            or "." in pure_payload_path.parts
            or ".." in pure_payload_path.parts
            or pure_payload_path.as_posix() != file_value
        ):
            add_violation(
                violations,
                "PAYLOAD_PATH_INVALID",
                file_value,
                "payload path must be repository-relative",
            )
            continue
        lexical_payload = (root / raw_payload_path).absolute()
        try:
            lexical_payload.relative_to((checkpoint / "payloads").absolute())
        except ValueError:
            add_violation(
                violations,
                "PAYLOAD_PATH_INVALID",
                file_value,
                "payload must stay inside its component checkpoint",
            )
            continue
        source_value = record.get("source_path")
        if not isinstance(source_value, str):
            add_violation(
                violations,
                "PAYLOAD_SOURCE_INVALID",
                file_value,
                "source_path must record a repository-relative provenance path",
            )
        else:
            pure_source = PurePosixPath(source_value)
            if (
                pure_source.is_absolute()
                or "." in pure_source.parts
                or ".." in pure_source.parts
                or pure_source.as_posix() != source_value
            ):
                add_violation(
                    violations,
                    "PAYLOAD_SOURCE_INVALID",
                    file_value,
                    "source_path must be a canonical repository-relative path",
                )
        media_type = record.get("media_type")
        if not isinstance(media_type, str) or not media_type.strip():
            add_violation(
                violations,
                "PAYLOAD_MEDIA_TYPE_INVALID",
                file_value,
                "media_type must be a non-empty string",
            )
        if lexical_payload.is_symlink():
            add_violation(
                violations,
                "PAYLOAD_MISSING",
                file_value,
                "payload may not be a symlink",
            )
            continue
        try:
            payload_path = lexical_payload.resolve(strict=True)
            payload_path.relative_to(checkpoint.resolve())
        except (OSError, ValueError):
            add_violation(
                violations,
                "PAYLOAD_PATH_INVALID",
                file_value,
                "payload must resolve inside its component checkpoint",
            )
            continue
        expected_files.add(payload_path)
        if not payload_path.is_file():
            add_violation(
                violations,
                "PAYLOAD_MISSING",
                file_value,
                "payload must be a regular tracked handoff file",
            )
            continue
        size = payload_path.stat().st_size
        total_bytes += size
        if size > MAX_PAYLOAD_BYTES:
            add_violation(
                violations,
                "PAYLOAD_TOO_LARGE",
                file_value,
                f"payload exceeds {MAX_PAYLOAD_BYTES} bytes",
            )
        if type(record.get("bytes")) is not int or record.get("bytes") != size:
            add_violation(
                violations,
                "PAYLOAD_SIZE_MISMATCH",
                file_value,
                "manifest byte count does not match payload",
            )
        if record.get("sha256") != sha256(payload_path):
            add_violation(
                violations,
                "PAYLOAD_HASH_MISMATCH",
                file_value,
                "manifest SHA-256 does not match payload",
            )

    if policy is not None:
        missing_roles = sorted(policy["required"] - roles)
        if missing_roles:
            add_violation(
                violations,
                "PAYLOAD_ROLE_MISSING",
                relative_checkpoint,
                f"missing required roles: {missing_roles}",
            )
    if total_bytes > MAX_TOTAL_BYTES:
        add_violation(
            violations,
            "PAYLOAD_TOTAL_EXCEEDED",
            relative_checkpoint,
            f"payload total exceeds {MAX_TOTAL_BYTES} bytes",
        )

    actual_files: set[Path] = set()
    for path in checkpoint.rglob("*"):
        if path.is_symlink():
            add_violation(
                violations,
                "CHECKPOINT_SYMLINK",
                repo_relative(root, path),
                "handoff may not contain symlinks",
            )
        elif path.is_file():
            actual_files.add(path.resolve())
    for extra in sorted(actual_files - expected_files):
        add_violation(
            violations,
            "UNDECLARED_FILE",
            repo_relative(root, extra),
            "every checkpoint file must be declared by manifest",
        )
    if require_tracked:
        for tracked_candidate in sorted(actual_files & expected_files):
            relative = repo_relative(root, tracked_candidate)
            result = run_git(
                root,
                ["ls-files", "--error-unmatch", "--", relative],
            )
            if result.returncode != 0:
                add_violation(
                    violations,
                    "UNTRACKED_CHECKPOINT_FILE",
                    relative,
                    "stage and commit every manifest/payload before cross-device use",
                )
    return manifest


def validate_repository(
    root: Path,
    module_filter: str | None = None,
    component_filter: str | None = None,
    require_tracked: bool = True,
) -> dict[str, object]:
    require_repository(root)
    if component_filter and not module_filter:
        raise HandoffError("--component requires --module")
    if module_filter:
        safe_token(module_filter, "module")
    if component_filter:
        safe_token(component_filter, "component")

    violations: list[dict[str, str]] = []
    manifests: list[dict[str, object]] = []
    handoff_root = root / "handoff"
    checkpoints: list[Path] = []
    if handoff_root.exists() or handoff_root.is_symlink():
        if handoff_root.is_symlink() or not handoff_root.is_dir():
            add_violation(
                violations,
                "HANDOFF_ROOT_INVALID",
                "handoff",
                "handoff must be a regular directory",
            )
        else:
            for child in sorted(handoff_root.iterdir()):
                if child.name.startswith((".stage-", ".backup-")):
                    add_violation(
                        violations,
                        "STALE_TRANSACTION_DIRECTORY",
                        repo_relative(root, child),
                        "remove interrupted handoff staging after inspection",
                    )
                    continue
                if not child.is_dir() or child.is_symlink():
                    add_violation(
                        violations,
                        "MODULE_DIRECTORY_INVALID",
                        repo_relative(root, child),
                        "handoff root may contain only module directories",
                    )
                    continue
                if module_filter and child.name != module_filter:
                    continue
                try:
                    safe_token(child.name, "module")
                except HandoffError as error:
                    add_violation(
                        violations,
                        "MODULE_DIRECTORY_INVALID",
                        repo_relative(root, child),
                        str(error),
                    )
                    continue
                child_entries = sorted(child.iterdir())
                if not child_entries:
                    add_violation(
                        violations,
                        "EMPTY_MODULE_DIRECTORY",
                        repo_relative(root, child),
                        "remove empty handoff module directories",
                    )
                for checkpoint in child_entries:
                    if component_filter and checkpoint.name != component_filter:
                        continue
                    if not checkpoint.is_dir() or checkpoint.is_symlink():
                        add_violation(
                            violations,
                            "COMPONENT_DIRECTORY_INVALID",
                            repo_relative(root, checkpoint),
                            "module handoff may contain only component directories",
                        )
                        continue
                    try:
                        safe_token(checkpoint.name, "component")
                    except HandoffError as error:
                        add_violation(
                            violations,
                            "COMPONENT_DIRECTORY_INVALID",
                            repo_relative(root, checkpoint),
                            str(error),
                        )
                        continue
                    checkpoints.append(checkpoint)

    if (module_filter or component_filter) and not checkpoints:
        target = "handoff"
        if module_filter:
            target += f"/{module_filter}"
        if component_filter:
            target += f"/{component_filter}"
        add_violation(
            violations,
            "FILTER_TARGET_MISSING",
            target,
            "requested handoff checkpoint does not exist",
        )

    for checkpoint in checkpoints:
        manifest = validate_checkpoint(
            root,
            checkpoint,
            violations,
            require_tracked=require_tracked,
        )
        if manifest is not None:
            manifests.append(manifest)

    violations.sort(key=lambda item: (item["code"], item["path"], item["detail"]))
    return {
        "schema": REPORT_SCHEMA,
        "status": "pass" if not violations else "fail",
        "checkpoint_count": len(checkpoints),
        "payload_count": sum(
            len(manifest.get("payloads", []))
            for manifest in manifests
            if isinstance(manifest.get("payloads"), list)
        ),
        "payload_bytes": sum(
            record.get("bytes", 0)
            for manifest in manifests
            for record in manifest.get("payloads", [])
            if isinstance(record, dict)
            and type(record.get("bytes", 0)) is int
        ),
        "git_tracking_verified": require_tracked,
        "checkpoints": [
            {
                "module": manifest.get("module"),
                "component": manifest.get("component"),
                "state": manifest.get("state"),
                "prompt_version": manifest.get("prompt_version"),
                "base_commit": manifest.get("base_commit"),
                "branch": manifest.get("branch"),
            }
            for manifest in manifests
        ],
        "limits": {
            "payloads_per_component": MAX_PAYLOADS,
            "bytes_per_payload": MAX_PAYLOAD_BYTES,
            "bytes_per_component": MAX_TOTAL_BYTES,
        },
        "violations": violations,
    }


def publish(args: argparse.Namespace) -> int:
    root = args.repo_root.expanduser().resolve()
    head = require_repository(root)
    branch = current_branch(root)
    if branch in protected_branches(root):
        raise HandoffError(
            f"refusing to publish temporary pixels on protected branch {branch!r}; "
            "create a short-lived collaboration branch"
        )
    require_clean_tracked_tree(root)
    module = safe_token(args.module, "module")
    component = safe_token(args.component, "component")
    if not args.prompt_version.strip():
        raise HandoffError("prompt version must be non-empty")
    if not args.next_gate.strip():
        raise HandoffError("next gate must be non-empty")
    validate_attempt_budget(
        args.state,
        args.attempts_used,
        args.attempt_limit,
        args.process_errors,
    )
    work_file = resolve_repo_file(root, args.work_file, "work file")
    require_committed_work(root, work_file)
    payloads = parse_payloads(root, args.state, args.payload)

    handoff_root = root / "handoff"
    handoff_root.mkdir(parents=True, exist_ok=True)
    destination = handoff_root / module / component
    destination.parent.mkdir(parents=True, exist_ok=True)
    staging = Path(tempfile.mkdtemp(prefix=".stage-", dir=handoff_root))
    backup: Path | None = None
    installed_new = False
    try:
        staged_checkpoint = staging / module / component
        payload_dir = staged_checkpoint / "payloads"
        payload_dir.mkdir(parents=True)
        records: list[dict[str, object]] = []
        for role, source in payloads:
            suffix = source.suffix.lower() or ".bin"
            target = payload_dir / f"{role}{suffix}"
            shutil.copy2(source, target)
            final_target = destination / "payloads" / target.name
            records.append(
                {
                    "role": role,
                    "file": repo_relative(root, final_target),
                    "source_path": repo_relative(root, source),
                    "sha256": sha256(target),
                    "bytes": target.stat().st_size,
                    "media_type": mimetypes.guess_type(target.name)[0]
                    or "application/octet-stream",
                }
            )
        manifest = {
            "schema": SCHEMA,
            "module": module,
            "component": component,
            "state": args.state,
            "prompt_version": args.prompt_version,
            "work_file": repo_relative(root, work_file),
            "work_file_sha256": sha256(work_file),
            "base_commit": head,
            "branch": branch,
            "created_at_utc": datetime.now(timezone.utc)
            .isoformat(timespec="seconds")
            .replace("+00:00", "Z"),
            "attempt_budget": {
                "used": args.attempts_used,
                "limit": args.attempt_limit,
                "process_errors": args.process_errors,
            },
            "next_gate": args.next_gate,
            "payloads": records,
            "contract": {
                "authoritative": False,
                "may_be_runtime_input": False,
                "may_be_source_without_explicit_acceptance": False,
                "replace_instead_of_accumulate": True,
                "remove_by_source_acceptance_or_p6_closure": True,
            },
        }
        (staged_checkpoint / "manifest.json").write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True)
            + "\n",
            encoding="utf-8",
        )

        if destination.exists() or destination.is_symlink():
            if not args.replace:
                raise HandoffError(
                    f"checkpoint already exists; use --replace: {repo_relative(root, destination)}"
                )
            existing = validate_repository(root, module, component)
            if existing["status"] != "pass" or existing["checkpoint_count"] != 1:
                raise HandoffError(
                    "refusing to replace an invalid or ambiguous existing checkpoint"
                )
            backup = handoff_root / f".backup-{uuid.uuid4().hex}"
            destination.rename(backup)

        staged_checkpoint.rename(destination)
        installed_new = True
        shutil.rmtree(staging)

        checkpoint_violations: list[dict[str, str]] = []
        validate_checkpoint(
            root,
            destination,
            checkpoint_violations,
            require_tracked=False,
        )
        if checkpoint_violations:
            raise HandoffError(
                "published checkpoint failed validation: "
                + json.dumps(checkpoint_violations, ensure_ascii=False)
            )
        if backup is not None:
            shutil.rmtree(backup)
            backup = None
        report = validate_repository(
            root,
            module,
            component,
            require_tracked=False,
        )
        if report["status"] != "pass" or report["checkpoint_count"] != 1:
            raise HandoffError(
                "published checkpoint failed repository validation: "
                + json.dumps(report["violations"], ensure_ascii=False)
            )
        sys.stdout.write(
            json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
        )
        return 0
    except Exception:
        if destination.exists() and installed_new:
            shutil.rmtree(destination)
        if backup is not None and backup.exists():
            backup.rename(destination)
        raise
    finally:
        if staging.exists():
            shutil.rmtree(staging)
        for empty_candidate in (destination.parent, handoff_root):
            try:
                empty_candidate.rmdir()
            except OSError:
                pass


def validate(args: argparse.Namespace) -> int:
    root = args.repo_root.expanduser().resolve()
    report = validate_repository(root, args.module, args.component)
    rendered = json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    if args.report:
        report_path = args.report.expanduser().resolve()
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(rendered, encoding="utf-8")
    sys.stdout.write(rendered)
    return 0 if report["status"] == "pass" else 1


def main() -> int:
    args = parse_args()
    try:
        if args.command == "publish":
            return publish(args)
        return validate(args)
    except HandoffError as error:
        sys.stderr.write(
            json.dumps(
                {"schema": REPORT_SCHEMA, "status": "error", "error": str(error)},
                ensure_ascii=False,
                sort_keys=True,
            )
            + "\n"
        )
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
