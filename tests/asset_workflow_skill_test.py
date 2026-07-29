#!/usr/bin/env python3
"""Static contract checks for the repository-local asset workflow skill."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / ".codex" / "skills" / "run-aeui-asset-workflow"


def require(source: str, values: tuple[str, ...], label: str) -> None:
    missing = [value for value in values if value not in source]
    assert not missing, f"{label} is missing required entries: {missing}"


def main() -> None:
    required = (
        SKILL / "SKILL.md",
        SKILL / "agents" / "openai.yaml",
        SKILL / "references" / "state-machine.md",
        SKILL / "references" / "review-checklist.md",
        SKILL / "references" / "repository-sync.md",
        SKILL / "references" / "record-templates.md",
        SKILL / "scripts" / "inspect_candidate.py",
    )
    missing = [path.relative_to(ROOT).as_posix() for path in required if not path.is_file()]
    assert not missing, f"asset workflow skill is incomplete: {missing}"

    skill = (SKILL / "SKILL.md").read_text(encoding="utf-8")
    assert skill.startswith("---\nname: run-aeui-asset-workflow\n")
    assert "[TODO" not in skill
    require(
        skill,
        (
            "../imagegen-0-143-0/SKILL.md",
            "Do not call the current session's built-in",
            "Do not copy anything into `assets/source/` without explicit user acceptance",
            "semantic structure has been checked",
            "[state-machine.md](references/state-machine.md)",
            "[review-checklist.md](references/review-checklist.md)",
            "[repository-sync.md](references/repository-sync.md)",
            "[record-templates.md](references/record-templates.md)",
            "inspect_candidate.py",
            "| finish, close, compact, clean completed work | `close`",
            "Do not remove intermediate or superseded files before `P6`",
            "## Close after P6",
            "`P6-C / component-closed`",
            "Do not describe ignored generated files as durable cross-device assets",
        ),
        "asset workflow skill",
    )

    state_machine = (SKILL / "references" / "state-machine.md").read_text(
        encoding="utf-8"
    )
    require(
        state_machine,
        (
            "`prompt-draft → prompt-authorized`",
            "`candidate-raw → candidate-reviewed`",
            "`candidate-reviewed → source-accepted`",
            "`source-accepted → runtime-exported`",
            "`runtime-exported → game-validated`",
            "`game-validated → closure-planned`",
            "`closure-planned → component-closed`",
            "技术指标",
            "用户明确接受具体候选",
            "执行过的提示词正文不可原地覆盖",
            "完整历史由 Git 保存",
        ),
        "asset workflow state machine",
    )

    review = (SKILL / "references" / "review-checklist.md").read_text(
        encoding="utf-8"
    )
    semantic_index = review.index("## 2. 语义、解剖与物理逻辑")
    technical_index = review.index("## 7. 技术像素检查")
    assert semantic_index < technical_index, (
        "technical checks must not precede semantic/physical review"
    )
    require(
        review,
        (
            "连通区数量、尺寸和透明度不能证明",
            "必须制作一次按真实层序的离线重组",
            "现代 HUD 语言",
            "预演图只进入 `generated/`",
            "`通过`、`有条件通过` 或 `退回`",
        ),
        "asset review checklist",
    )

    interface = (SKILL / "agents" / "openai.yaml").read_text(encoding="utf-8")
    require(
        interface,
        (
            'display_name: "AEUI 资产生成与审查"',
            "short_description:",
            'default_prompt: "Use $run-aeui-asset-workflow',
        ),
        "asset workflow interface metadata",
    )

    script = SKILL / "scripts" / "inspect_candidate.py"
    compile(script.read_text(encoding="utf-8"), str(script), "exec")
    help_result = subprocess.run(
        [sys.executable, str(script), "--help"],
        check=False,
        capture_output=True,
        text=True,
    )
    assert help_result.returncode == 0, help_result.stderr
    assert "ID=x0,y0,x1,y1" in help_result.stdout

    pipeline = (ROOT / "docs" / "ASSET_PIPELINE.md").read_text(encoding="utf-8")
    workflow = (ROOT / "docs" / "WORKFLOW.md").read_text(encoding="utf-8")
    agents = (ROOT / "AGENTS.md").read_text(encoding="utf-8")
    for source, label in (
        (pipeline, "asset pipeline"),
        (workflow, "documentation workflow"),
        (agents, "agent instructions"),
    ):
        assert "run-aeui-asset-workflow" in source, (
            f"{label} does not route work through the workflow skill"
        )
        assert "P6-C" in source, (
            f"{label} does not require terminal component closure"
        )

    repository_sync = (
        SKILL / "references" / "repository-sync.md"
    ).read_text(encoding="utf-8")
    require(
        repository_sync,
        (
            "## `P6-C` 终态收口",
            "### 保留",
            "### 清理",
            "精确清单",
            "不得对",
            "独立提交",
        ),
        "terminal cleanup rules",
    )

    print("asset workflow skill contract test passed")


if __name__ == "__main__":
    main()
