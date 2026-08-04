#!/usr/bin/env python3
"""Static contract checks for the compact AEUI asset workflow skill."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
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
        SKILL / "references" / "display-region-gate.md",
        SKILL / "references" / "prompt-completeness.md",
        SKILL / "references" / "bounded-repair-loop.md",
        SKILL / "references" / "repository-sync.md",
        SKILL / "references" / "record-templates.md",
        SKILL / "scripts" / "inspect_candidate.py",
        SKILL / "scripts" / "render_geometric_mockup.py",
        SKILL / "scripts" / "validate_addon_package.py",
        SKILL / "scripts" / "validate_display_regions.py",
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
            "## Resolve the Python runtime",
            "`uname -s` returns `Darwin`",
            "`conda run -n py312 python`",
            "do not fall back to",
            "/usr/bin/python3",
            "Linux: use `python3`",
            "Windows PowerShell: use `py -3`",
            "selected interpreter and `--version`",
            "## Use the compact document lifecycle",
            "one active Markdown work file",
            "Before executing a production prompt",
            "Then delete the component work file",
            "../imagegen-0-143-0/SKILL.md",
            "Do not call the current session's built-in",
            "Do not copy anything into `assets/source/` without explicit user acceptance",
            "A locked image without prompt provenance",
            "## Make execution bodies complete, not merely longer",
            "`.rN` execution body must be self-contained",
            "do not set a word-count minimum",
            "self-contained prompt completeness audit",
            "prompt-completeness.md",
            "“Continue” or “next step”",
            "never authorizes ImageGen",
            "## Simulate before production",
            "mandatory low-cost direction gate",
            "scripts/render_geometric_mockup.py",
            "simple geometric primitives",
            "ImageGen usage as `0/0`",
            "current accepted/runtime",
            "representative dynamic content and information density",
            "Simulation confirmation never accepts source pixels",
            "cannot be copied",
            "production edit/reference input",
            "## Run the bounded autonomous repair loop",
            "bounded-repair-loop.md",
            "including attempt 1",
            "provider result proves",
            "does not consume the `0/5` image budget",
            "neither condition is user acceptance",
            "mandatory post-candidate real-layout",
            "candidate real-layout simulation",
            "`100%` runtime size",
            "display-region-gate.md",
            "Background coverage alone is insufficient",
            "`display-region-blocked`",
            "fresh-checkout-installable addon runtime",
            "validate_addon_package.py",
            "Interface/AddOns",
            "must not run an exporter, ImageGen, Python, a patch script",
            "addon-package gate result",
            "23-row Quest Log asset",
            "sparse demo",
            "`P6-C / component-closed`",
        ),
        "asset workflow skill",
    )
    assert skill.index("## Simulate before production") < skill.index("## Generate")
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
            "`prompt-draft → simulation-reviewed`",
            "`simulation-reviewed → simulation-confirmed`",
            "`simulation-confirmed → prompt-authorized`",
            "自包含生产正文完整性",
            "不按字数判定",
            "`candidate-raw → candidate-reviewed`",
            "`candidate-reviewed → source-accepted`",
            "`source-accepted → runtime-exported`",
            "fresh-checkout addon package",
            "validate_addon_package.py",
            "软链接、Junction",
            "`display-region-blocked`",
            "`runtime-exported → game-validated`",
            "`game-validated → closure-planned`",
            "`closure-planned → component-closed`",
            "`repair-prepared`",
            "授权的生产执行正文最多产生",
            "`5` 次实际 ImageGen 生图／修图",
            "生成前模拟固定为本地确定性几何渲染",
            "实际 ImageGen 为 `0/0`",
            "没有 ImageGen 计数或执行授权",
            "模拟图不得复制",
            "不得作为正式资产 edit／reference 输入",
            "流程错误",
            "不占生产生图额度",
            "candidate-rejected / repair-budget-exhausted",
            "`<authorized-version>.r1`",
            "每次生产执行前必须提交 work 文件",
            "完整正文由 Git 历史保存",
            "真实对象数量",
            "现实信息密度",
            "稀疏样例与 contact sheet",
            "然后删除 work",
        ),
        "asset workflow state machine",
    )
    assert state_machine.index("  → simulation-confirmed") < state_machine.index(
        "  → prompt-authorized"
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
            "## 生成前模拟实例图门禁",
            "游戏里大概是什么感觉",
            "代表性的真实对象数量",
            "本地确定性脚本",
            "实际 ImageGen 固定为 `0/0`",
            "不得调用 ImageGen",
            "不能证明最终手绘笔触",
            "用户未明确确认具体模拟版本前",
            "## 自主修复循环判定",
            "## 0. 执行正文与传输一致性",
            "完整授权正文或完整 `.rN` 正文",
            "revised prompt",
            "最多 `5` 次实际 ImageGen 生图／修图中的每个输出",
            "无候选的流程错误",
            "不占 `0/5`",
            "相同首要失败连续出现",
            "内部通过仍不等于用户接受",
            "必须制作一次按真实层序的离线重组",
            "docs/GLOBAL_ART_BASELINE.md",
            "`assets/source/` 派生母版错误提升",
            "每次 generate 或 edit 后",
            "全部 23 个行槽",
            "当前最新的新 UI",
            "简化占位",
            "预演图只进入 `generated/`",
            "实际展示区域门禁",
            "人为指定的固定高度",
            "背景覆盖",
        ),
        "review checklist",
    )

    display_region = (
        SKILL / "references" / "display-region-gate.md"
    ).read_text(encoding="utf-8")
    require(
        display_region,
        (
            "## 四层区域",
            "`frame coverage`",
            "`content conformance`",
            "`interaction conformance`",
            "`preview fidelity`",
            "空状态也必须检查",
            "容量包络图",
            "validate_display_regions.py",
            "`aeui-display-region-contract-v1`",
            "动态文字、图标、Button 可见区",
            "`display-region-blocked`",
        ),
        "display-region gate",
    )

    prompt_completeness = (
        SKILL / "references" / "prompt-completeness.md"
    ).read_text(encoding="utf-8")
    require(
        prompt_completeness,
        (
            "每个 production／`.rN` 正文都必须自包含",
            "不设字数下限",
            "对象／状态数量",
            "每张图片输入的权威",
            "Canvas、排布、cell 顺序",
            "文字／图标安静区",
            "Alpha／色键",
            "执行必需值未知时返回组件合同",
        ),
        "prompt completeness reference",
    )

    bounded_loop = (
        SKILL / "references" / "bounded-repair-loop.md"
    ).read_text(encoding="utf-8")
    require(
        bounded_loop,
        (
            "最多使用 `5` 次实际 ImageGen",
            "attempt 1 是首次候选",
            "provider result ID",
            "process error",
            "不改变 `0/5`",
            "`candidate-reviewed / P3`",
            "same as before except",
            "`candidate-rejected / P3 / repair-budget-exhausted`",
            "不消耗 ImageGen",
        ),
        "bounded repair loop reference",
    )

    repository_sync = (
        SKILL / "references" / "repository-sync.md"
    ).read_text(encoding="utf-8")
    require(
        repository_sync,
        (
            "## 四份长期模块文档",
            "## 单一组件 work",
            "## 生成前模拟同步",
            "本地确定性脚本直接渲染",
            "不需要逐版本执行授权",
            "ImageGen 固定为 `0/0`",
            "不得上传参考图",
            "`generated/<module>/<batch>/simulation/<version>/`",
            "| `simulate` |",
            "自包含生产正文的紧凑完整性预检",
            "不得新增路线图",
            "`prompts/` 树",
            "模拟可在提交前确定性渲染",
            "本地模拟渲染后把 specification",
            "## 五次自主修复同步",
            "最多产生固定 ImageGen `5` 次实际生图／修图",
            "独立流程错误表",
            "不占实际生图次数",
            "中间失败只更新 work",
            "不得自动创建",
            "## `P6-C` 终态收口",
            "## P5 本机插件接入与跨设备可用门禁",
            "aeui-addon-package-report-v1",
            "build_required_on_target_device=false",
            "只需拉取并把这些目录放入 `Interface/AddOns`",
            "该组件的 work 文件",
            "不得对",
            "macOS 必须使用 `conda run -n py312 python`",
            "不得静默回退到系统 `python3`",
            "Windows PowerShell 优先 `py -3`",
            "实际 `sys.executable` 与版本",
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
            "## 生成前模拟实例图",
            "模拟 ImageGen：0/0",
            "本地渲染错误：0",
            "与正式资产 ImageGen 正文分开",
            "不涉及 ImageGen",
            "模拟像素本身永远不能成为源资产",
            "## 生产正文完整性预检",
            "不以字数判定",
            "完整、自包含正文",
            "自动修复预算：最多 5 次实际 ImageGen 生图／修图，含首次",
            "当前实际生图：0/5",
            "流程错误：0",
            "| 流程错误 |",
            "## 自主修复循环",
            "第一失败门禁",
            "repair-budget-exhausted",
            "真实排版预演",
            "真实对象",
            "现实信息密度",
            "实际展示区域合同／报告",
            "provider 公式",
            "## 尝试摘要",
            "## P5 插件接入记录",
            "fresh-checkout package 证据",
            "build_required_on_target_device：false",
            "不修改 Lua/pfUI",
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
            "真实展示区门禁",
            'default_prompt: "Use $run-aeui-asset-workflow',
            "preview it locally",
            "provider-to-art display regions",
            "five-generation review-repair workflow",
            "fresh-checkout-installable addon package",
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

    geometric_script = SKILL / "scripts" / "render_geometric_mockup.py"
    compile(
        geometric_script.read_text(encoding="utf-8"),
        str(geometric_script),
        "exec",
    )
    geometric_help = subprocess.run(
        [sys.executable, str(geometric_script), "--help"],
        check=False,
        capture_output=True,
        text=True,
    )
    assert geometric_help.returncode == 0, geometric_help.stderr
    assert "rect, rounded_rect, polygon, line, ellipse, text" in geometric_help.stdout

    display_script = SKILL / "scripts" / "validate_display_regions.py"
    compile(
        display_script.read_text(encoding="utf-8"),
        str(display_script),
        "exec",
    )
    display_help = subprocess.run(
        [sys.executable, str(display_script), "--help"],
        check=False,
        capture_output=True,
        text=True,
    )
    assert display_help.returncode == 0, display_help.stderr
    assert "Validate exact UI display regions" in display_help.stdout

    package_script = SKILL / "scripts" / "validate_addon_package.py"
    compile(
        package_script.read_text(encoding="utf-8"),
        str(package_script),
        "exec",
    )
    package_help = subprocess.run(
        [sys.executable, str(package_script), "--help"],
        check=False,
        capture_output=True,
        text=True,
    )
    assert package_help.returncode == 0, package_help.stderr
    assert "Validate a fresh-checkout addon package" in package_help.stdout
    package_result = subprocess.run(
        [sys.executable, str(package_script), str(ROOT)],
        check=False,
        capture_output=True,
        text=True,
    )
    assert package_result.returncode == 0, (
        package_result.stdout + package_result.stderr
    )
    package_report = json.loads(package_result.stdout)
    assert package_report["status"] == "pass"
    assert package_report["build_required_on_target_device"] is False
    assert package_report["violations"] == []

    passing_contract = {
        "schema": "aeui-display-region-contract-v1",
        "component": "TEST.COMPONENT",
        "atlas": {
            "size": [3, 3],
            "visible_bbox": [0, 0, 3, 3],
            "require_exact_visible_coverage": True,
            "sampled_regions": [{"id": "all", "box": [0, 0, 3, 3]}],
        },
        "nine_slice": {
            "caps": {"left": 1, "right": 1, "top": 1, "bottom": 1},
            "minimum_frame_size": [3, 3],
        },
        "scenarios": [
            {
                "id": "default",
                "frame": [5, 5],
                "preview_frame": [5, 5],
                "zones": {"content": [1, 1, 4, 4]},
                "regions": [
                    {
                        "id": "text",
                        "box": [1, 1, 4, 4],
                        "zone": "content",
                    }
                ],
            }
        ],
    }
    failing_contract = json.loads(json.dumps(passing_contract))
    failing_contract["scenarios"][0]["preview_frame"] = [5, 6]
    with tempfile.TemporaryDirectory() as temporary:
        temporary_path = Path(temporary)
        passing_path = temporary_path / "passing.json"
        failing_path = temporary_path / "failing.json"
        passing_path.write_text(
            json.dumps(passing_contract),
            encoding="utf-8",
        )
        failing_path.write_text(
            json.dumps(failing_contract),
            encoding="utf-8",
        )
        passing_result = subprocess.run(
            [sys.executable, str(display_script), str(passing_path)],
            check=False,
            capture_output=True,
            text=True,
        )
        assert passing_result.returncode == 0, passing_result.stderr
        assert '"status": "pass"' in passing_result.stdout
        failing_result = subprocess.run(
            [sys.executable, str(display_script), str(failing_path)],
            check=False,
            capture_output=True,
            text=True,
        )
        assert failing_result.returncode == 1, failing_result.stderr
        assert "PREVIEW_FRAME_MISMATCH" in failing_result.stdout

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
            "-s workspace-write",
            "must use its built-in `image_gen`",
            "must not start another `codex`／`npx` subprocess",
            "any observed recursive",
            "`npx --package=@openai/codex@0.143.0",
            "## Counting semantics for bounded parent workflows",
            "process error does not consume",
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
            "-s workspace-write",
            "must use its own built-in `image_gen`",
            "must not invoke the wrapper",
            "does not consume the image",
        ),
        "fixed imagegen usage",
    )
    for forbidden in (
        "every invocation counts, including transport",
        "调用失败、提示词截断和不可用输出也占用",
        "执行器调用失败也\n  占用次数",
    ):
        assert forbidden not in (
            skill + state_machine + review + repository_sync + templates
        ), f"workflow still counts process errors as image calls: {forbidden}"

    agents = (ROOT / "AGENTS.md").read_text(encoding="utf-8")
    require(
        agents,
        (
            "## 唯一文档结构与索引",
            "work/*.md",
            "组件达到 `P6-C` 后必须删除",
            "run-aeui-asset-workflow",
            "imagegen-0-143-0",
            "fresh-checkout",
            "另一台设备不得再生成资产",
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
