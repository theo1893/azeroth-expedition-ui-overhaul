#!/usr/bin/env python3
"""Static contract checks for the compact quest module package."""

from __future__ import annotations

import hashlib
import json
import struct
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
QUESTS = ROOT / "docs" / "modules" / "quests"


def require(source: str, values: tuple[str, ...], label: str) -> None:
    missing = [value for value in values if value not in source]
    assert not missing, f"{label} is missing required entries: {missing}"


def main() -> None:
    submodules = (QUESTS / "SUBMODULES.md").read_text(encoding="utf-8")
    art = (QUESTS / "ART_BASELINE.md").read_text(encoding="utf-8")
    sub_art = (
        QUESTS / "SUBMODULE_ART_BASELINES.md"
    ).read_text(encoding="utf-8")
    progress = (QUESTS / "PROGRESS.md").read_text(encoding="utf-8")
    work = (QUESTS / "work" / "QUEST.LOG.GUTTER.md").read_text(
        encoding="utf-8"
    )

    require(
        submodules,
        (
            "skins/blizzard/questlog.lua",
            "skins/blizzard/gossipquest.lua",
            "modules/questitem.lua",
            "`QuestLogFrame`",
            "`676 × 464 UI px`",
            "`x=338`",
            "`42%`／右 `58%`",
            "不得缩成",
            "`QUEST.LOG.SHELL`",
            "`QUEST.LOG.LIST.PAPER`",
            "`QUEST.LOG.DETAIL.PAPER`",
            "`QUEST.LOG.GUTTER.UNDERLAY`",
            "`QUEST.LOG.GUTTER.LEFT_FOLD`",
            "`QUEST.LOG.GUTTER.RIGHT_FOLD`",
            "`QUEST.LOG.GUTTER.STITCH`",
            "`QUEST.LOG.GUTTER.TOP`",
            "`QUEST.LOG.GUTTER.BOTTOM`",
            "不再分别对应可加载 Texture",
            "固定尺寸，不重复、不拉伸",
            "禁止在 SHELL 上烘焙",
            "`QUEST.LOG.REGION.TOGGLE`",
            "`QUEST.LOG.LIST.ROW`",
            "`QUEST.LOG.LIST.CHECK`",
            "不是选择 Button",
            "`QUEST.LOG.SELECTION`",
            "`QUEST.LOG.LIST.SCROLL.TRACK`",
            "`QUEST.LOG.LIST.SCROLL.THUMB`",
            "`QUEST.LOG.LIST.SCROLL.UP`",
            "`QUEST.LOG.LIST.SCROLL.DOWN`",
            "`QUEST.LOG.DETAIL.SCROLL.TRACK`",
            "`QUEST.LOG.DETAIL.SCROLL.THUMB`",
            "`QUEST.LOG.DETAIL.SCROLL.UP`",
            "`QUEST.LOG.DETAIL.SCROLL.DOWN`",
            "`QUEST.LOG.DETAIL.TITLE`",
            "`QUEST.LOG.DETAIL.DESCRIPTION`",
            "`QUEST.LOG.DETAIL.OBJECTIVES`",
            "`QUEST.LOG.DETAIL.REWARD_TEXT`",
            "`QUEST.LOG.REWARD.SLOT`",
            "无 selected",
            "`QUEST.LOG.ACTION.ABANDON`",
            "`QUEST.LOG.ACTION.SHARE`",
            "`QUEST.LOG.ACTION.EXIT`",
            "`QUEST.DIALOG.QUEST.SHELL`",
            "`QUEST.DIALOG.GOSSIP.SHELL`",
            "`QUEST.DIALOG.QUEST.PORTRAIT`",
            "`QUEST.DIALOG.GOSSIP.PORTRAIT`",
            "`QUEST.DIALOG.QUEST.GREETING.PANEL`",
            "`QUEST.DIALOG.GOSSIP.GREETING.PANEL`",
            "`QUEST.DIALOG.QUEST.DETAIL.PANEL`",
            "`QUEST.DIALOG.QUEST.PROGRESS.PANEL`",
            "`QUEST.DIALOG.QUEST.REWARD.PANEL`",
            "`QUEST.DIALOG.ACTION.DECLINE`",
            "`QUEST.DIALOG.ACTION.ACCEPT`",
            "`QUEST.DIALOG.ACTION.COMPLETE_QUEST`",
            "`QUEST.DIALOG.ITEM.PROGRESS`",
            "`QUEST.DIALOG.ITEM.DETAIL`",
            "`QUEST.DIALOG.ITEM.REWARD.SLOT`",
            "`QUEST.DIALOG.ITEM.REWARD.SELECTION`",
            "`QUEST.TRACKER.HEADER`",
            "`QUEST.TRACKER.PAPER`",
            "provider 未提供",
            "`QUEST.ITEM.TOOLTIP`",
            "`QUEST.ITEM.QUICKBUTTON`",
        ),
        "quest submodule contract",
    )
    for panel in (
        "QUEST.GREETING",
        "GOSSIP.GREETING",
        "QUEST.DETAIL",
        "QUEST.PROGRESS",
        "QUEST.REWARD",
    ):
        for part in ("TRACK", "THUMB", "UP", "DOWN"):
            component_id = f"`QUEST.DIALOG.{panel}.SCROLL.{part}`"
            assert component_id in submodules, (
                f"missing scroll component {component_id}"
            )
    for action in (
        "QUEST_GREETING_GOODBYE",
        "GOSSIP_GREETING_GOODBYE",
        "DECLINE",
        "ACCEPT",
        "GOODBYE",
        "COMPLETE",
        "CANCEL",
        "COMPLETE_QUEST",
    ):
        assert f"`QUEST.DIALOG.ACTION.{action}`" in submodules

    require(
        art,
        (
            "GLOBAL_ART_BASELINE.md",
            "任务详情面板_视觉基准_v1.png",
            "任务追踪面板_视觉基准_v1.png",
            "正式卷宗系统",
            "双页公会任务卷宗",
            "纵向“行军便笺”",
            "物理双页保持近 1:1",
            "主要阅读区必须",
            "Tracker 必须等待真实外部 provider",
        ),
        "quest main art baseline",
    )
    require(
        sub_art,
        (
            "`QUEST.LOG.SHELL`／QL-A1",
            "QuestLogBookShell_Master_v1.png",
            "019fac35-620b-78d3-8b46-2e1f02105f74",
            "`LIST.PAPER`／`DETAIL.PAPER`／`GUTTER.*`",
            "QL-A2 V4",
            "不再作为独立生图对象",
            "固定显示尺寸为 `676 × 464`",
            "`GUTTER.*` 仅保留逻辑",
            "work/QUEST.LOG.GUTTER.md",
            "左页目录状态",
            "ScrollBar 与操作 Button",
            "Quest Tracker",
            "当前没有美术基线 Prompt",
            "完整执行正文、会话和 diff 保留在 Git",
        ),
        "quest submodule art baselines",
    )

    require(
        progress,
        (
            "`QL-A1` 空卷宗结构 source",
            "`P4`",
            "`QL-A2 V3.2` 已终止",
            "`QL-A2 V3.3`",
            "`P3` 部分执行",
            "B1 underlay＋folds",
            "B2 单枚 stitch",
            "B3 top／bottom closures",
            "B1 已耗尽 `5/5`",
            "B2 已耗尽 `5/5`",
            "B3 已耗尽 `5/5`",
            "`candidate-rejected / repair-budget-exhausted`",
            "合计 `15/15`",
            "`QL-A2 V4`",
            "`runtime-exported / P5`",
            "`676 × 464`",
            "固定执行器 `0/0`",
            "`1024 × 512` TGA",
            "Quests.lua",
            "QL-A1_RuntimeManifest_v1.json",
            "1b6b21cd3db74202051a2ceb8b5ba1d91ca7beb636accf247603edbc3cfeb40e",
            "Quest Tracker",
            "外部 provider `P0`",
            "NPC Quest／Gossip",
            "QL-A1_SourceManifest_v1.json",
            "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5",
            "241402／5650／1325994",
            "未晋级任何 V3.2／V3.3 候选",
        ),
        "quest detailed progress",
    )

    require(
        work,
        (
            "版本：`QL-A2 V4`",
            "子状态：`runtime-exported`",
            "项目阶段：`P5`",
            "deterministic-export / static-integration",
            "V4 不调用 ImageGen；`0/0`",
            "用户授权：`2026-07-30`",
            "QuestLogBookShell_Master_v1.png",
            "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5",
            "QL-A2_V4_SHELL_676x464.preview.png",
            "3a075d8e094fc8d3b72cf8b5fc4a5a6add020ddbcd6f1e768a841423c5b0e910",
            "QuestLogShellV4.tga",
            "QL-A1_RuntimeManifest_v1.json",
            "build_quest_log_shell_v4.py",
            "Modules/Quests.lua",
            "## V3.3 终态复核与纠错",
            "合计 `15/15`",
            "**语义／物理失败**",
            "多圈交叠、装饰性凯尔特／航海绳结",
            "禁止挽救、缩放或晋级 V3.3 B3",
            "## 美术基准继承",
            "QL-A1 source 是用户已接受的结构母版",
            "不把任务标题、任务行、等级、计数",
            "不把 Close、Expand、Levels、两套 ScrollBar",
            "## 组件合同 — V4 运行时所有权",
            "`QUEST.LOG.SHELL`",
            "`QUEST.LOG.LIST.PAPER`",
            "`QUEST.LOG.DETAIL.PAPER`",
            "`QUEST.LOG.GUTTER.UNDERLAY`",
            "`QUEST.LOG.GUTTER.STITCH`",
            "`QUEST.LOG.GUTTER.TOP`／`BOTTOM`",
            "不再创建独立 Texture",
            "Close、",
            "ScrollBar、行状态、奖励槽和操作 Button",
            "## 状态合同",
            "`list-only`",
            "从 `676` 缩到 `340` 宽",
            "## 确定性导出合同",
            "`1514 × 1039 RGBA`",
            "`676 × 464 UI px`",
            "`1024 × 512 RGBA TGA`",
            "`u=0..0.66015625`、`v=0..0.90625`",
            "QuestLogShellV4.tga",
            "tools/build_quest_log_shell_v4.py",
            "透明／半透明／不透明像素",
            "`45159／6974／261531`",
            "## ImageGen 与修复预算",
            "V4 没有 ImageGen 执行正文",
            "固定执行器预算：`0/0`",
            "## 审查记录",
            "`runtime-exported / P5`",
            "Turtle WoW `1.18.1` 实机验证",
        ),
        "active QL-A2 work",
    )
    assert "## 最终执行正文" in work
    assert "不适用。V4 是确定性导出合同" in work
    assert "/Users/" not in work
    assert "固定执行器预算：`0/0`" in work

    source_path = (
        ROOT
        / "assets"
        / "source"
        / "quests"
        / "ql-a1"
        / "QuestLogBookShell_Master_v1.png"
    )
    manifest_path = source_path.with_name("QL-A1_SourceManifest_v1.json")
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    source_bytes = source_path.read_bytes()
    assert source_bytes[:8] == b"\x89PNG\r\n\x1a\n"
    assert source_bytes[12:16] == b"IHDR"
    width, height = struct.unpack(">II", source_bytes[16:24])
    assert (width, height, source_bytes[24], source_bytes[25]) == (
        1514,
        1039,
        8,
        6,
    )
    assert manifest["schema_version"] == 2
    assert manifest["batch"] == "QL-A1"
    assert manifest["status"] == "accepted-source"
    assert hashlib.sha256(source_bytes).hexdigest() == (
        manifest["source"]["sha256"]
    )
    assert manifest["provenance"]["prompt"].endswith(
        "docs/modules/quests/SUBMODULE_ART_BASELINES.md"
    )
    assert manifest["provenance"]["prompt_section"] == (
        "QUEST.LOG.SHELL / QL-A1"
    )
    for key in ("prompt", "visual_reference"):
        linked = (manifest_path.parent / manifest["provenance"][key]).resolve()
        assert linked.is_file(), f"missing QL-A1 provenance: {key}"
    assert manifest["crop_contract"]["whole_image_runtime_allowed"] is False
    assert (
        manifest["crop_contract"]["deterministic_full_frame_export_allowed"]
        is True
    )
    assert manifest["crop_contract"]["status"] == "resolved-ql-a2-v4"

    runtime_manifest_path = source_path.with_name(
        "QL-A1_RuntimeManifest_v1.json"
    )
    runtime_manifest = json.loads(
        runtime_manifest_path.read_text(encoding="utf-8")
    )
    assert runtime_manifest["status"] == "runtime-exported"
    assert runtime_manifest["batch"] == "QL-A2"
    assert runtime_manifest["version"] == "V4"
    assert runtime_manifest["runtime_contract"] == "1.0"
    assert runtime_manifest["transform"]["display_size"] == [676, 464]
    assert runtime_manifest["transform"]["atlas_size"] == [1024, 512]
    assert runtime_manifest["transform"]["content_box"] == [0, 0, 676, 464]
    assert runtime_manifest["transform"]["texcoord"] == {
        "left": 0.0,
        "right": 0.66015625,
        "top": 0.0,
        "bottom": 0.90625,
    }
    assert runtime_manifest["frame_contract"]["fixed_size"] is True
    assert runtime_manifest["frame_contract"]["stretch"] is False
    assert "full 676 x 464 shell" in (
        runtime_manifest["frame_contract"]["list_only"]
    )
    assert runtime_manifest["implementation"]["imagegen_calls"] == 0
    assert runtime_manifest["implementation"]["game_validated"] is False

    runtime_path = ROOT / runtime_manifest["runtime"]["file"]
    runtime_bytes = runtime_path.read_bytes()
    assert hashlib.sha256(runtime_bytes).hexdigest() == (
        runtime_manifest["runtime"]["sha256"]
    )
    assert runtime_manifest["runtime"]["sha256"] == (
        "1b6b21cd3db74202051a2ceb8b5ba1d91ca7beb636accf247603edbc3cfeb40e"
    )
    assert runtime_bytes[2] == 2
    assert struct.unpack("<HH", runtime_bytes[12:16]) == (1024, 512)
    assert runtime_bytes[16] == 32

    quest_adapter = (
        ROOT
        / "addon"
        / "AzerothExpeditionUI"
        / "Modules"
        / "Quests.lua"
    ).read_text(encoding="utf-8")
    require(
        quest_adapter,
        (
            'Quests.runtimeContract = "1.0"',
            "QuestLogShellV4",
            "0.66015625",
            "0.90625",
            "CaptureAndHideNativeTextures",
            "QuestLogFrameExpandButton",
            "QuestLog_UpdateQuestDetails",
            "addon:RegisterModule(\"Quests\", Quests)",
        ),
        "quest runtime adapter",
    )
    assert "EnableMouse" not in quest_adapter
    assert "QuestLogFrame:SetWidth(340)" not in quest_adapter

    assert not (ROOT / "prompts" / "quests").exists()
    print("quest design contract test passed")


if __name__ == "__main__":
    main()
