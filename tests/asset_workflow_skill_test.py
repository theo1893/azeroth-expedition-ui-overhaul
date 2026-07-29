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
            "A locked image without its prompt provenance is an incomplete authority",
            "## Resolve visual authority and inheritance",
            "art-inheritance block",
            "`assets/source/` derivative the highest visual authority",
            "“continue” or “next step” alone does not authorize generation",
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
            "原始提示词",
            "“继续”或“下一步”本身不构成生图授权",
            "`assets/source/` 中的派生母版不能",
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
            "原始提示词提取的美术 DNA",
            "`assets/source/` 派生母版错误提升",
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
    require(
        pipeline,
        (
            "原始 prototype／provenance prompt 路径",
            "必须继承／组件级转译／明确不继承／冲突裁决",
            "派生 `assets/source/` 不得反向覆盖",
            "“继续”或“下一步”只允许走到展示提示词",
        ),
        "asset pipeline art-inheritance gate",
    )
    require(
        agents,
        (
            "同时读取产生或语义锁定该图的版本化",
            "`assets/source/` 是",
            "不得在后续提示词中被提升为高于锁定基准",
        ),
        "agent visual-authority gate",
    )

    legacy_executed = {
        "任务详情空卷宗结构母版_生产提示词_QL-A1_v1.md",
        "任务详情可拉伸结构部件_生产提示词_QL-A2_v1.md",
        "任务详情内页沟结构部件_生产提示词_QL-A2_v2.md",
        "任务详情内页沟结构部件_修订提示词_QL-A2_v2.1.md",
        "任务详情对称内页沟结构部件_生产提示词_QL-A2_v3.md",
    }
    for prompt in sorted((ROOT / "prompts").rglob("*.md")):
        source = prompt.read_text(encoding="utf-8")
        if "子状态：`prompt-draft`" not in source:
            continue
        assert prompt.name not in legacy_executed
        require(
            source,
            (
                "## 美术基准继承",
                "基准提示词 provenance",
                "### 权威顺序",
                "### 必须继承的视觉 DNA",
                "### 本批组件级转译",
                "### 明确不继承",
                "### 冲突审计",
            ),
            f"active production prompt {prompt.relative_to(ROOT)}",
        )
        assert "source` 只" in source or "source，只" in source, (
            f"{prompt.relative_to(ROOT)} does not limit derivative source authority"
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
