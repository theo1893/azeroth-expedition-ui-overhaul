#!/usr/bin/env python3
"""Static contract checks for the compact AEUI asset workflow skill."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / ".codex" / "skills" / "run-aeui-asset-workflow"
IMAGEGEN_WRAPPER = ROOT / ".codex" / "skills" / "imagegen-0-143-0"


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
    missing = [
        path.relative_to(ROOT).as_posix()
        for path in required
        if not path.is_file()
    ]
    assert not missing, f"asset workflow skill is incomplete: {missing}"

    skill = (SKILL / "SKILL.md").read_text(encoding="utf-8")
    assert skill.startswith("---\nname: run-aeui-asset-workflow\n")
    assert "[TODO" not in skill
    require(
        skill,
        (
            "docs/GLOBAL_ART_BASELINE.md",
            "SUBMODULES.md",
            "ART_BASELINE.md",
            "SUBMODULE_ART_BASELINES.md",
            "PROGRESS.md",
            "docs/modules/<module>/work/",
            "## Use the compact document lifecycle",
            "one active Markdown work file",
            "Before executing a prompt, commit",
            "Then delete the component work file",
            "../imagegen-0-143-0/SKILL.md",
            "Do not call the current session's built-in",
            "Do not copy anything into `assets/source/` without explicit user acceptance",
            "A locked image without prompt provenance",
            "“continue” or “next step”",
            "alone does not authorize generation",
            "## Run the bounded autonomous repair loop",
            "at most `5` fixed ImageGen invocations",
            "Attempt 1 is the initial generation",
            "`candidate-reviewed / P3`",
            "`candidate-rejected / P3 / repair-budget-exhausted`",
            "Internal passage",
            "is not user acceptance",
            "`P6-C / component-closed`",
        ),
        "asset workflow skill",
    )
    for obsolete in (
        "docs/ASSET_PIPELINE.md",
        "docs/implementation/OVERHAUL_TRACKER.md",
        "docs/ART_DIRECTION.md",
        "prompt under `prompts/<module>/`",
    ):
        assert obsolete not in skill, f"skill still routes through {obsolete}"

    state_machine = (SKILL / "references" / "state-machine.md").read_text(
        encoding="utf-8"
    )
    require(
        state_machine,
        (
            "docs/modules/<module>/PROGRESS.md",
            "`prompt-draft → prompt-authorized`",
            "`candidate-raw → candidate-reviewed`",
            "`candidate-reviewed → source-accepted`",
            "`source-accepted → runtime-exported`",
            "`runtime-exported → game-validated`",
            "`game-validated → closure-planned`",
            "`closure-planned → component-closed`",
            "`repair-prepared`",
            "最多进入固定执行器 `5` 次",
            "传输失败",
            "candidate-rejected / repair-budget-exhausted",
            "`<authorized-version>.r1`",
            "执行前必须提交 work 文件",
            "完整正文由 Git 历史保存",
            "然后删除 work",
        ),
        "asset workflow state machine",
    )

    review = (SKILL / "references" / "review-checklist.md").read_text(
        encoding="utf-8"
    )
    assert review.index("## 2. 语义、解剖与物理逻辑") < review.index(
        "## 7. 技术像素检查"
    )
    require(
        review,
        (
            "## 自主修复循环判定",
            "最多 `5` 次固定执行器调用中的每个输出",
            "相同首要失败连续出现",
            "内部通过仍不等于用户接受",
            "必须制作一次按真实层序的离线重组",
            "docs/GLOBAL_ART_BASELINE.md",
            "`assets/source/` 派生母版错误提升",
            "预演图只进入 `generated/`",
        ),
        "review checklist",
    )

    repository_sync = (
        SKILL / "references" / "repository-sync.md"
    ).read_text(encoding="utf-8")
    require(
        repository_sync,
        (
            "## 四份长期模块文档",
            "## 单一组件 work",
            "不得新增路线图",
            "`prompts/` 树",
            "首次执行前先提交用户授权的 work",
            "每次调用前提交当前完整执行正文",
            "## 五次自主修复同步",
            "最多调用固定 ImageGen `5` 次",
            "中间失败只更新 work",
            "不得自动创建",
            "## `P6-C` 终态收口",
            "该组件的 work 文件",
            "不得对",
        ),
        "repository sync",
    )

    templates = (
        SKILL / "references" / "record-templates.md"
    ).read_text(encoding="utf-8")
    require(
        templates,
        (
            "## 组件 work 文件",
            "## 美术基准继承",
            "自动修复预算：最多 5 次固定执行器调用，含首次",
            "## 自主修复循环",
            "第一失败门禁",
            "repair-budget-exhausted",
            "## 尝试摘要",
            "SUBMODULE_ART_BASELINES.md",
            "并删除 work",
        ),
        "record templates",
    )

    interface = (SKILL / "agents" / "openai.yaml").read_text(encoding="utf-8")
    require(
        interface,
        (
            'display_name: "AEUI 资产生成与审查"',
            "最多五次自主修复循环",
            'default_prompt: "Use $run-aeui-asset-workflow',
            "at most five fixed ImageGen calls",
        ),
        "skill interface",
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

    imagegen_skill = (IMAGEGEN_WRAPPER / "SKILL.md").read_text(
        encoding="utf-8"
    )
    imagegen_usage = (
        IMAGEGEN_WRAPPER / "references" / "usage.md"
    ).read_text(encoding="utf-8")
    require(
        imagegen_skill,
        (
            "### Windows PowerShell",
            "npx.ps1",
            "npx.cmd",
            "UTF-8 standard input",
            "`-- -`",
            "complete authorized prompt",
        ),
        "fixed imagegen Windows transport",
    )
    require(
        imagegen_usage,
        (
            "UTF-8 stdin",
            "`-- -`",
            "`npx.cmd`",
            "`npx.ps1`",
        ),
        "fixed imagegen usage",
    )

    agents = (ROOT / "AGENTS.md").read_text(encoding="utf-8")
    require(
        agents,
        (
            "## 唯一文档结构与索引",
            "work/*.md",
            "组件达到 `P6-C` 后必须删除",
            "run-aeui-asset-workflow",
            "imagegen-0-143-0",
        ),
        "AGENTS workflow routing",
    )

    for work in sorted((ROOT / "docs" / "modules").glob("*/work/*.md")):
        source = work.read_text(encoding="utf-8")
        require(
            source,
            (
                "子状态：",
                "项目阶段：",
                "固定执行器：",
                "## 美术基准继承",
                "## 组件合同",
                "## 最终执行正文",
                "## 执行记录",
                "## 审查记录",
                "## 尝试摘要",
            ),
            f"active work {work.relative_to(ROOT)}",
        )

    print("asset workflow skill contract test passed")


if __name__ == "__main__":
    main()
