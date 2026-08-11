#!/usr/bin/env python3
"""Run one fixed Codex 0.143.0 ImageGen attempt from a tracked prompt body.

This is a transport wrapper only. It extracts a complete prompt section
verbatim, validates fixed reference hashes, starts Codex 0.143.0 in an empty
temporary workspace, and copies provider outputs into an ignored review
directory. It never reviews or promotes an asset.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
IMAGE_SUFFIXES = {".png", ".webp", ".jpg", ".jpeg"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--prompt-doc", type=Path, required=True)
    parser.add_argument("--prompt-heading", required=True)
    parser.add_argument("--contract", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--session-id", required=True)
    parser.add_argument("--repo-root", type=Path, default=ROOT)
    parser.add_argument("--edit", type=Path)
    parser.add_argument(
        "--fenced-body",
        action="store_true",
        help="extract only the single ```text fenced body beneath the heading",
    )
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def resolve(root: Path, value: str | Path) -> Path:
    path = Path(value)
    return path if path.is_absolute() else root / path


def extract_prompt(path: Path, heading: str, fenced_body: bool = False) -> str:
    lines = path.read_text(encoding="utf-8").splitlines()
    try:
        start = lines.index(heading)
    except ValueError as error:
        raise ValueError(f"prompt heading not found: {heading}") from error
    end = len(lines)
    for index in range(start + 1, len(lines)):
        if lines[index].startswith(("## ", "### ")):
            end = index
            break
    selected = lines[start + 1 : end]
    if fenced_body:
        openings = [index for index, line in enumerate(selected) if line == "```text"]
        if len(openings) != 1:
            raise ValueError("expected exactly one ```text prompt fence")
        opening = openings[0]
        try:
            closing = selected.index("```", opening + 1)
        except ValueError as error:
            raise ValueError("prompt text fence is not closed") from error
        if any(line.startswith("```") for line in selected[closing + 1 :]):
            raise ValueError("unexpected prompt fence after selected body")
        selected = selected[opening + 1 : closing]
    body = "\n".join(selected) + "\n"
    if not body.strip():
        raise ValueError("tracked prompt body is empty")
    return body


def display(root: Path, path: Path) -> str:
    resolved = path.resolve()
    try:
        return resolved.relative_to(root).as_posix()
    except ValueError:
        return str(resolved)


def collect_images(
    workspace: Path, stdout: str
) -> tuple[list[Path], list[Path], str | None]:
    provider_native: set[Path] = set()
    child_saved: set[Path] = set()
    generated = workspace / "generated"
    if generated.exists():
        for path in generated.rglob("*"):
            if path.is_file() and path.suffix.lower() in IMAGE_SUFFIXES:
                child_saved.add(path.resolve())
    session_match = re.search(
        r"^session id:\s*([0-9a-f-]+)\s*$",
        stdout,
        flags=re.IGNORECASE | re.MULTILINE,
    )
    session_id = session_match.group(1) if session_match else None
    if session_id:
        native_dir = Path.home() / ".codex" / "generated_images" / session_id
        if native_dir.exists():
            for path in native_dir.rglob("*"):
                if path.is_file() and path.suffix.lower() in IMAGE_SUFFIXES:
                    provider_native.add(path.resolve())
    order = lambda item: (item.stat().st_mtime_ns, str(item))
    return sorted(provider_native, key=order), sorted(child_saved, key=order), session_id


def main() -> int:
    args = parse_args()
    root = args.repo_root.resolve()
    prompt_doc = resolve(root, args.prompt_doc)
    contract_path = resolve(root, args.contract)
    output_dir = resolve(root, args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    contract: dict[str, Any] = json.loads(contract_path.read_text(encoding="utf-8"))
    if not contract.get("executor", {}).get("authorized"):
        raise ValueError("production contract is not authorized")
    references = contract.get("fixed_references", [])
    if len(references) != 2:
        raise ValueError("this fixed attempt requires exactly Image 1 and Image 2")
    images: list[Path] = []
    image_records: list[dict[str, Any]] = []
    for expected_number, reference in enumerate(references, start=1):
        if reference.get("image") != expected_number:
            raise ValueError("fixed reference order changed")
        path = resolve(root, reference["path"])
        actual = sha256(path)
        if actual != reference["sha256"]:
            raise ValueError(f"Image {expected_number} SHA-256 changed")
        images.append(path)
        image_records.append(
            {
                "image": expected_number,
                "path": display(root, path),
                "sha256": actual,
                "role": "fixed production reference",
            }
        )
    if args.edit:
        edit_path = resolve(root, args.edit)
        if not edit_path.is_file():
            raise ValueError("authorized Image 3 edit input does not exist")
        images.append(edit_path)
        image_records.append(
            {
                "image": 3,
                "path": display(root, edit_path),
                "sha256": sha256(edit_path),
                "role": "same-segment immediately previous candidate edit input",
            }
        )

    body = extract_prompt(prompt_doc, args.prompt_heading, fenced_body=args.fenced_body)
    instruction_lines = [
        "Execution instruction:",
        "This process is already running inside fixed @openai/codex 0.143.0.",
        "Use the built-in image_gen capability directly.",
        "Do not invoke any repository wrapper, npx command, or another Codex process.",
    ]
    for record in image_records:
        instruction_lines.append(
            f"Image {record['image']} is the uploaded file at {resolve(root, record['path'])}."
        )
    instruction_lines.extend(
        [
            "Generate or edit exactly one bitmap according to the complete prompt above.",
            "Do not resize, crop, key, composite, repaint, or otherwise post-process the direct image_gen output.",
            "Copy the direct image_gen output byte-for-byte when placing it in the requested generated path.",
            f"Save the resulting bitmap under ./generated/{args.attempt}.png.",
            "Return the absolute saved path. Do not perform review or promotion.",
        ]
    )
    child_prompt = "$imagegen " + body + "\n\n" + "\n".join(instruction_lines)

    workspace = Path(tempfile.mkdtemp(prefix=f"aeui-{args.attempt}-"))
    (workspace / "generated").mkdir(parents=True, exist_ok=True)
    command = [
        "npx",
        "--yes",
        "--package=@openai/codex@0.143.0",
        "--",
        "codex",
        "exec",
        "-C",
        str(workspace),
        "-s",
        "workspace-write",
        "--skip-git-repo-check",
        "-m",
        "gpt-5.5",
        "-c",
        'model_reasoning_effort="medium"',
    ]
    for image in images:
        command.extend(["-i", str(image.resolve())])
    command.extend(["--", child_prompt])

    print(f"fixed-imagegen-session={args.session_id}", flush=True)
    print(f"prompt-body-sha256={hashlib.sha256(body.encode('utf-8')).hexdigest()}", flush=True)
    print(f"temporary-workspace={workspace}", flush=True)
    process = subprocess.Popen(
        command,
        cwd=workspace,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )
    output_lines: list[str] = []
    assert process.stdout is not None
    for line in process.stdout:
        print(line, end="", flush=True)
        output_lines.append(line)
    return_code = process.wait()
    stdout = "".join(output_lines)
    (output_dir / f"{args.attempt}.executor.log").write_text(stdout, encoding="utf-8")

    provider_images, child_images, codex_session_id = collect_images(workspace, stdout)
    copied: list[dict[str, Any]] = []
    for index, source in enumerate(provider_images, start=1):
        suffix = source.suffix.lower() if source.suffix.lower() in IMAGE_SUFFIXES else ".png"
        target = output_dir / f"{args.attempt}.provider-native-{index:02d}{suffix}"
        shutil.copy2(source, target)
        copied.append(
            {
                "source_path": str(source),
                "path": display(root, target),
                "sha256": sha256(target),
                "size_bytes": target.stat().st_size,
            }
        )
    child_copied: list[dict[str, Any]] = []
    for index, source in enumerate(child_images, start=1):
        suffix = source.suffix.lower() if source.suffix.lower() in IMAGE_SUFFIXES else ".png"
        target = output_dir / f"{args.attempt}.child-saved-{index:02d}{suffix}"
        shutil.copy2(source, target)
        child_copied.append(
            {
                "source_path": str(source),
                "path": display(root, target),
                "sha256": sha256(target),
                "size_bytes": target.stat().st_size,
            }
        )
    summary = {
        "schema": "aeui.fixed-imagegen-attempt.v1",
        "session_id": args.session_id,
        "attempt": args.attempt,
        "executor": "@openai/codex@0.143.0",
        "prompt_doc": display(root, prompt_doc),
        "prompt_heading": args.prompt_heading,
        "prompt_body_format": "fenced-text" if args.fenced_body else "heading-section",
        "prompt_body_sha256": hashlib.sha256(body.encode("utf-8")).hexdigest(),
        "images": image_records,
        "process_return_code": return_code,
        "codex_session_id": codex_session_id,
        "provider_outputs": copied,
        "provider_output_count": len(copied),
        "child_saved_outputs": child_copied,
        "child_saved_output_count": len(child_copied),
        "countable_output": bool(copied or child_copied),
        "temporary_workspace": str(workspace),
    }
    summary_path = output_dir / f"{args.attempt}.executor.json"
    summary_path.write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(summary, ensure_ascii=False, indent=2), flush=True)
    if return_code != 0 and not (copied or child_copied):
        return return_code or 2
    if not (copied or child_copied):
        return 3
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
