#!/usr/bin/env python3
"""Static contract checks for the offline quest-module design package."""

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def require(source: str, values: tuple[str, ...], label: str) -> None:
    missing = [value for value in values if value not in source]
    assert not missing, f"{label} is missing required entries: {missing}"


def main() -> None:
    spec_path = ROOT / "docs" / "implementation" / "QUEST_COMPONENT_SPEC.md"
    log_prompt_path = (
        ROOT / "prompts" / "quests" / "任务详情组件资产_生产提示词_v2.md"
    )
    ql_a1_prompt_path = (
        ROOT
        / "prompts"
        / "quests"
        / "任务详情空卷宗结构母版_生产提示词_QL-A1_v1.md"
    )
    tracker_prompt_path = (
        ROOT / "prompts" / "quests" / "任务追踪组件资产_生产提示词_v2.md"
    )
    tracker_path = (
        ROOT / "docs" / "implementation" / "OVERHAUL_TRACKER.md"
    )

    spec = spec_path.read_text(encoding="utf-8")
    log_prompt = log_prompt_path.read_text(encoding="utf-8")
    ql_a1_prompt = ql_a1_prompt_path.read_text(encoding="utf-8")
    tracker_prompt = tracker_prompt_path.read_text(encoding="utf-8")
    tracker = tracker_path.read_text(encoding="utf-8")

    require(
        spec,
        (
            "QuestLogFrame",
            "QuestLogListScrollFrameScrollBar",
            "QuestLogDetailScrollFrameScrollBar",
            "QuestLogFrameCloseButton",
            "QuestLogFrameAbandonButton",
            "QuestFramePushQuestButton",
            "QL-A1",
            "已经生成本地透明候选",
            "外部插件",
            "QuestWatchFrame",
            "假设已作废",
            "deferred-compatibility-draft",
            "兼容 `P0`",
            "QUEST.ITEM.TOOLTIP",
            "QUEST.ITEM.QUICKBUTTON",
        ),
        "quest component specification",
    )
    assert "第一 provider 是香草 `QuestWatchFrame`" not in spec, (
        "quest tracker still assumes the native QuestWatchFrame provider"
    )

    require(
        log_prompt,
        (
            "production-draft",
            "`QL-A1` 已冻结到独立 production 文件并执行",
            "等待用户复审 `QL-A1` 候选",
            "任务详情空卷宗结构母版_生产提示词_QL-A1_v1.md",
            "imagegen-0-143-0",
            "@openai/codex@0.143.0",
            "执行块 QL-A1",
            "执行块 QL-B1",
            "执行块 QL-C1",
            "执行块 QL-D",
            "真正 RGBA 透明背景",
            "#00FF00",
            "不得生成中文、英文、数字、伪文字",
        ),
        "quest-log production prompt",
    )

    require(
        ql_a1_prompt,
        (
            "类型：`production`",
            "用户已于 `2026-07-29` 确认并执行",
            "imagegen-0-143-0",
            "@openai/codex@0.143.0",
            "019fac35-620b-78d3-8b46-2e1f02105f74",
            "generated/quests/QL-A1/v1/QL-A1_v1_raw.png",
            "generated/quests/QL-A1/v1/QL-A1_v1.png",
            "执行块 QL-A1",
            "真正 RGBA 透明背景",
            "#00FF00",
            "不得生成中文、英文、数字、伪文字",
        ),
        "confirmed QL-A1 production prompt",
    )
    assert "执行块 QL-A2" not in ql_a1_prompt, (
        "confirmed QL-A1 prompt contains an unauthorized later batch"
    )

    common_start = log_prompt.index("## 共同前缀")
    common_end = log_prompt.index("\n---", common_start) + len("\n---")
    ql_a1_start = log_prompt.index("## 执行块 QL-A1")
    ql_a1_end = log_prompt.index("\n---", ql_a1_start) + len("\n---")
    expected_ql_a1_body = (
        log_prompt[common_start:common_end]
        + "\n"
        + log_prompt[ql_a1_start:ql_a1_end]
    )
    frozen_ql_a1_body = ql_a1_prompt.split(
        "## 已确认提示词正文\n\n", 1
    )[1].strip()
    assert frozen_ql_a1_body == expected_ql_a1_body, (
        "confirmed QL-A1 prompt no longer matches the executed draft body"
    )

    require(
        tracker_prompt,
        (
            "deferred-compatibility-draft",
            "执行状态：禁止执行",
            "不得把原生 `QuestWatchFrame`",
            "imagegen-0-143-0",
            "@openai/codex@0.143.0",
            "视觉预拆分 QT-A1",
            "视觉预拆分 QT-A2",
            "视觉预拆分 QT-A3",
            "视觉预拆分 QT-B1",
            "视觉预拆分 QT-B2",
            "真正 RGBA 透明背景",
            "#00FF00",
            "不得生成任务名称、目标文字、数字、伪文字",
        ),
        "quest-tracker production prompt",
    )

    require(
        tracker,
        (
            "`QUEST.LOG.SHELL`",
            "`P3`",
            "任务详情空卷宗结构母版_生产提示词_QL-A1_v1.md",
            "1514 × 1039",
            "241402／5650／1325994",
            "42%／58%",
            "`QUEST.LOG.ACTION.ABANDON`",
            "`QUEST.LOG.ACTION.SHARE`",
            "`QUEST.LOG.ACTION.EXIT`",
            "`QUEST.TRACKER.HEADER`",
            "`QUEST.TRACKER.PAPER`",
            "`QUEST.TRACKER.BOTTOM`",
            "`P2 visual／P0 compat`",
            "外部 provider",
            "deferred compatibility draft",
            "`QUEST.ITEM.TOOLTIP`",
            "`QUEST.ITEM.QUICKBUTTON`",
            "任务详情组件资产_生产提示词_v2.md",
            "任务追踪组件资产_生产提示词_v2.md",
        ),
        "overhaul tracker quest rows",
    )

    assert "| `QUEST.ITEM` | 任务物品快捷按钮" not in tracker, (
        "tracker still misclassifies pfUI questitem as a quick button"
    )
    assert "adapter 层锚定 `QuestWatchFrame`" not in tracker, (
        "overhaul tracker still binds tracker art to native QuestWatchFrame"
    )
    assert "`QuestWatchLine1..MAX_QUESTWATCH_LINES`" not in tracker, (
        "overhaul tracker still assumes native QuestWatchLine objects"
    )

    print("quest design contract test passed")


if __name__ == "__main__":
    main()
