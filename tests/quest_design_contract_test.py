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
    tracker_prompt_path = (
        ROOT / "prompts" / "quests" / "任务追踪组件资产_生产提示词_v2.md"
    )
    tracker_path = (
        ROOT / "docs" / "implementation" / "OVERHAUL_TRACKER.md"
    )

    spec = spec_path.read_text(encoding="utf-8")
    log_prompt = log_prompt_path.read_text(encoding="utf-8")
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
            "当前唯一",
            "QL-A1",
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
            "当前唯一待确认执行块为 `QL-A1`",
            "当前生产队列：`QL-A1`",
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
