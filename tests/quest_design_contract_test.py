#!/usr/bin/env python3
"""Static contract checks for the offline quest-module design package."""

from __future__ import annotations

import hashlib
import json
import struct
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
    ql_a2_v1_prompt_path = (
        ROOT
        / "prompts"
        / "quests"
        / "任务详情可拉伸结构部件_生产提示词_QL-A2_v1.md"
    )
    ql_a2_v2_prompt_path = (
        ROOT
        / "prompts"
        / "quests"
        / "任务详情内页沟结构部件_生产提示词_QL-A2_v2.md"
    )
    ql_a2_v2_1_prompt_path = (
        ROOT
        / "prompts"
        / "quests"
        / "任务详情内页沟结构部件_修订提示词_QL-A2_v2.1.md"
    )
    tracker_prompt_path = (
        ROOT / "prompts" / "quests" / "任务追踪组件资产_生产提示词_v2.md"
    )
    tracker_path = (
        ROOT / "docs" / "implementation" / "OVERHAUL_TRACKER.md"
    )
    ql_a1_source_path = (
        ROOT
        / "assets"
        / "source"
        / "quests"
        / "ql-a1"
        / "QuestLogBookShell_Master_v1.png"
    )
    ql_a1_manifest_path = ql_a1_source_path.with_name(
        "QL-A1_SourceManifest_v1.json"
    )

    spec = spec_path.read_text(encoding="utf-8")
    log_prompt = log_prompt_path.read_text(encoding="utf-8")
    ql_a1_prompt = ql_a1_prompt_path.read_text(encoding="utf-8")
    ql_a2_v1_prompt = ql_a2_v1_prompt_path.read_text(encoding="utf-8")
    ql_a2_v2_prompt = ql_a2_v2_prompt_path.read_text(encoding="utf-8")
    ql_a2_v2_1_prompt = ql_a2_v2_1_prompt_path.read_text(encoding="utf-8")
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
            "空卷宗结构母版已经用户确认并达到 `P4`",
            "QuestLogBookShell_Master_v1.png",
            "QL-A1_SourceManifest_v1.json",
            "不能直接充当",
            "`QL-A2 V1` 的五对象方案已因外置封脊朝向",
            "`QL-A2 V2.1` 已生成精确八组逻辑对象的透明候选并达到 `P3`",
            "任务详情可拉伸结构部件_生产提示词_QL-A2_v1.md",
            "任务详情内页沟结构部件_生产提示词_QL-A2_v2.md",
            "任务详情内页沟结构部件_修订提示词_QL-A2_v2.1.md",
            "`QUEST.LOG.SPINE` 只保留为“中央装订结构包”的父级兼容名称",
            "QUEST.LOG.GUTTER.UNDERLAY",
            "QUEST.LOG.GUTTER.LEFT_FOLD",
            "QUEST.LOG.GUTTER.RIGHT_FOLD",
            "QUEST.LOG.GUTTER.STITCH",
            "QUEST.LOG.GUTTER.TOP",
            "QUEST.LOG.GUTTER.BOTTOM",
            "左右物理纸页保持近等宽",
            "左 `42%`／右 `58%` 只指 runtime 文字阅读",
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
    assert "书脊必须从中段内部提取 `140 × 60`" not in spec, (
        "rejected QL-A2 V1 tiling assumption is still active"
    )

    require(
        log_prompt,
        (
            "production-draft",
            "`QL-A1` 已确认并达到 `P4`",
            "`QL-A2 V1` 已否决",
            "`QL-A2 V2.1`\n  已形成 `P3` 候选",
            "等待复审 `QL-A2 V2.1`",
            "任务详情空卷宗结构母版_生产提示词_QL-A1_v1.md",
            "任务详情可拉伸结构部件_生产提示词_QL-A2_v1.md",
            "任务详情内页沟结构部件_生产提示词_QL-A2_v2.md",
            "任务详情内页沟结构部件_修订提示词_QL-A2_v2.1.md",
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
            "用户已于 `2026-07-29` 确认执行结果",
            "透明源母版达到 `P4`",
            "imagegen-0-143-0",
            "@openai/codex@0.143.0",
            "019fac35-620b-78d3-8b46-2e1f02105f74",
            "generated/quests/QL-A1/v1/QL-A1_v1_raw.png",
            "generated/quests/QL-A1/v1/QL-A1_v1.png",
            "QuestLogBookShell_Master_v1.png",
            "QL-A1_SourceManifest_v1.json",
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
        ql_a2_v1_prompt,
        (
            "类型：`production`",
            "状态：`rejected`",
            "用户于 `2026-07-29` 复审后否决",
            "imagegen-0-143-0",
            "@openai/codex@0.143.0",
            "019fac4a-c73e-71c1-a6bd-a94a86627b3e",
            "generated/quests/QL-A2/v1/QL-A2_v1_raw.png",
            "generated/quests/QL-A2/v1/QL-A2_v1.png",
            "从外部观察的凸起封脊",
            "上下端件压死翻页空间",
            "透视、曲面法线和图层关系不一致",
            "42.1%／57.9%",
            "140 × 60",
            "任务详情内页沟结构部件_生产提示词_QL-A2_v2.md",
            "不得进入源资产、crop manifest 或 runtime",
        ),
        "rejected QL-A2 V1 prompt",
    )
    ql_a2_v1_body = ql_a2_v1_prompt.split(
        "## 已确认提示词正文\n\n", 1
    )[1].strip()
    assert not ql_a2_v1_body.startswith("Execution instruction:"), (
        "QL-A2 V1 creative body was replaced by execution metadata"
    )
    assert "/Users/" not in ql_a2_v1_body, (
        "QL-A2 V1 creative body contains a machine-specific absolute path"
    )
    assert "QL-B" not in ql_a2_v1_prompt, (
        "rejected QL-A2 V1 prompt contains an unauthorized later batch"
    )

    require(
        ql_a2_v2_prompt,
        (
            "类型：`production`",
            "首轮 V2 已修正双页视角",
            "V2.1 已形成 `P3` 候选",
            "imagegen-0-143-0",
            "@openai/codex@0.143.0",
            "QuestLogBookShell_Master_v1.png",
            "任务详情面板_视觉基准_v1.png",
            "任务详情内页沟结构部件_修订提示词_QL-A2_v2.1.md",
            "精确 `8` 组",
            "QUEST.LOG.LIST.PAPER",
            "QUEST.LOG.DETAIL.PAPER",
            "QUEST.LOG.GUTTER.UNDERLAY",
            "QUEST.LOG.GUTTER.LEFT_FOLD",
            "QUEST.LOG.GUTTER.RIGHT_FOLD",
            "QUEST.LOG.GUTTER.STITCH",
            "QUEST.LOG.GUTTER.TOP",
            "QUEST.LOG.GUTTER.BOTTOM",
            "对象 1：左页非对称九宫格纸面",
            "对象 2：右页非对称九宫格纸面",
            "对象 3：内部页沟底层",
            "对象 4：左页内折过渡层",
            "对象 5：右页内折过渡层",
            "对象 6：内部装订缝线周期",
            "对象 7：顶部装订收口",
            "对象 8：底部装订收口",
            "两块纸面使用近似相同的物理宽度",
            "`42%／58%` 只代表未来左／右文字阅读安全区",
            "最底层是已经确认的封皮与外围页叠",
            "纸页必须从视觉上覆盖页沟两侧",
            "明确禁止外置封脊",
        ),
        "QL-A2 V2 eight-object production prompt",
    )
    ql_a2_v2_body = ql_a2_v2_prompt.split(
        "## 已确认提示词正文\n\n", 1
    )[1].strip()
    assert not ql_a2_v2_body.startswith("Execution instruction:"), (
        "QL-A2 V2 creative body was replaced by execution metadata"
    )
    assert "/Users/" not in ql_a2_v2_body, (
        "QL-A2 V2 creative body contains a machine-specific absolute path"
    )
    assert "QL-B" not in ql_a2_v2_prompt, (
        "QL-A2 V2 prompt contains an unauthorized later batch"
    )

    require(
        ql_a2_v2_1_prompt,
        (
            "类型：`production-edit`",
            "达到 `P3` 候选",
            "019fac8e-bae8-73f2-af89-674e925b0068",
            "ig_0e15261f6bc2a618016a699d6f4f5481919c35afcaa581e3fc",
            "ig_0bda33a80800f83f016a699ddd6dbc8191a674cb8b33717482",
            "generated/quests/QL-A2/v2/QL-A2_v2_1_raw.png",
            "generated/quests/QL-A2/v2/QL-A2_v2.png",
            "generated/quests/QL-A2/v2/QL-A2_v2_reassembly_preview.png",
            "e0f04181a297f37f48dbfd568c374e0578e9cace24106a3adcdee613d5cf57ff",
            "c4f3b41c8108776ddeb69cd092627e605fe2bfa41c28822f491a151cd327a461",
            "745186／57546／770132",
            "可见绿色残留 `0`",
            "六个下排对象横向分离",
            "没有外置封脊、皮革底板、跨页横梁或大型端帽",
            "`42%／58%`：只用于 runtime 左／右文字阅读安全区",
            "Critical composition: The final lower row MUST contain exactly SIX",
            "Internal stitch cycle: ONLY rope pixels",
            "group 4 has no backing plate behind the rope",
            "groups 5 and 6 are side-by-side, not stacked",
        ),
        "QL-A2 V2.1 production edit prompt and execution record",
    )
    ql_a2_v2_1_body = ql_a2_v2_1_prompt.split(
        "## 已确认修订提示词正文\n\n", 1
    )[1].split("\n## 固定执行器最终 revised_prompt", 1)[0].strip()
    assert "/Users/" not in ql_a2_v2_1_body, (
        "QL-A2 V2.1 creative body contains a machine-specific absolute path"
    )
    assert "QL-B" not in ql_a2_v2_1_prompt, (
        "QL-A2 V2.1 prompt contains an unauthorized later batch"
    )

    manifest = json.loads(ql_a1_manifest_path.read_text(encoding="utf-8"))
    source_bytes = ql_a1_source_path.read_bytes()
    source_sha256 = hashlib.sha256(source_bytes).hexdigest()
    assert source_bytes[:8] == b"\x89PNG\r\n\x1a\n", (
        "accepted QL-A1 source is not a PNG"
    )
    assert source_bytes[12:16] == b"IHDR", (
        "accepted QL-A1 source is missing its PNG IHDR"
    )
    width, height = struct.unpack(">II", source_bytes[16:24])
    assert (width, height, source_bytes[24], source_bytes[25]) == (
        1514,
        1039,
        8,
        6,
    ), "accepted QL-A1 source must be 1514x1039 8-bit RGBA"
    assert manifest["batch"] == "QL-A1"
    assert manifest["status"] == "accepted-source"
    assert manifest["source"] == {
        "file": "QuestLogBookShell_Master_v1.png",
        "sha256": "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5",
        "width": 1514,
        "height": 1039,
        "mode": "RGBA",
        "transparent_pixels": 241402,
        "partially_transparent_pixels": 5650,
        "opaque_pixels": 1325994,
        "visible_green_spill_pixels": 0,
    }
    assert source_sha256 == manifest["source"]["sha256"], (
        "accepted QL-A1 source no longer matches its manifest"
    )
    assert {
        component["id"] for component in manifest["logical_components"]
    } == {
        "QUEST.LOG.SHELL",
        "QUEST.LOG.LIST.PAPER",
        "QUEST.LOG.DETAIL.PAPER",
        "QUEST.LOG.SPINE",
    }
    assert "near equal width" in manifest["review"]["physical_pages"]
    assert manifest["review"]["runtime_reading_area_target"] == (
        "left 42 percent, right 58 percent"
    )
    assert manifest["crop_contract"]["status"] == "deferred"
    assert manifest["crop_contract"]["whole_image_runtime_allowed"] is False
    assert manifest["runtime_exports"] == []
    for key in ("prompt", "visual_reference"):
        linked_path = (
            ql_a1_manifest_path.parent / manifest["provenance"][key]
        ).resolve()
        assert linked_path.is_file(), (
            f"QL-A1 manifest provenance link is missing: {key}"
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
            "`QL-A1` 空卷宗透明源母版达到 `P4`",
            "`QL-A2 V1` 已退回",
            "八对象 `V2.1` 透明候选达到 `P3`",
            "任务详情空卷宗结构母版_生产提示词_QL-A1_v1.md",
            "任务详情可拉伸结构部件_生产提示词_QL-A2_v1.md",
            "任务详情内页沟结构部件_生产提示词_QL-A2_v2.md",
            "任务详情内页沟结构部件_修订提示词_QL-A2_v2.1.md",
            "QuestLogBookShell_Master_v1.png",
            "QL-A1_SourceManifest_v1.json",
            "1514 × 1039",
            "241402／5650／1325994",
            "42%／58%",
            "接近等宽的物理双页已经接受",
            "整张源图不得进入 runtime",
            "用户视觉复审未通过；正式退回",
            "019fac4a-c73e-71c1-a6bd-a94a86627b3e",
            "42.1%／57.9%",
            "`140 × 60` 周期假定作废",
            "019fac8e-bae8-73f2-af89-674e925b0068",
            "ig_0bda33a80800f83f016a699ddd6dbc8191a674cb8b33717482",
            "c4f3b41c8108776ddeb69cd092627e605fe2bfa41c28822f491a151cd327a461",
            "745186／57546／770132",
            "八组为近等宽左右纸面",
            "`42%／58%` 仅为 runtime 文字安全区",
            "`QUEST.LOG.SPINE`",
            "`P2 parent`",
            "`QUEST.LOG.GUTTER.UNDERLAY`",
            "`QUEST.LOG.GUTTER.LEFT_FOLD`",
            "`QUEST.LOG.GUTTER.RIGHT_FOLD`",
            "`QUEST.LOG.GUTTER.STITCH`",
            "`QUEST.LOG.GUTTER.TOP`",
            "`QUEST.LOG.GUTTER.BOTTOM`",
            "只有麻线，无皮革底板",
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
    assert "QL-A2` 上端／中段／下端候选通过五对象检查" not in tracker, (
        "tracker still treats the rejected three-part exterior spine as active"
    )

    print("quest design contract test passed")


if __name__ == "__main__":
    main()
