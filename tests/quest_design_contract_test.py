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
            "`676 × 440 UI px`",
            "`x=338`",
            "`42%`／右 `58%`",
            "`QUEST.LOG.SHELL`",
            "`QUEST.LOG.LIST.PAPER`",
            "`QUEST.LOG.DETAIL.PAPER`",
            "`QUEST.LOG.GUTTER.UNDERLAY`",
            "`QUEST.LOG.GUTTER.LEFT_FOLD`",
            "`QUEST.LOG.GUTTER.RIGHT_FOLD`",
            "`QUEST.LOG.GUTTER.STITCH`",
            "`QUEST.LOG.GUTTER.TOP`",
            "`QUEST.LOG.GUTTER.BOTTOM`",
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
            "中央至少 80%",
            "短横向粗麻针脚站",
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
            "`QL-A2 V3.2`",
            "`prompt-draft / P2`",
            "V3.2-A／B",
            "A／B\n  已分别冻结最多 `5` 次自主生成－审查－修复预算",
            "最坏总调用数为 `10`",
            "Quest Tracker",
            "外部 provider `P0`",
            "NPC Quest／Gossip",
            "QL-A1_SourceManifest_v1.json",
            "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5",
            "241402／5650／1325994",
            "用户于 `2026-07-30` 明确授权执行正文",
        ),
        "quest detailed progress",
    )

    require(
        work,
        (
            "版本：`QL-A2 V3.2`",
            "子状态：`prompt-authorized`",
            "项目阶段：`P3`",
            "执行状态：已授权，固定执行器尚未调用",
            "确认授权 QL-A2 V3.2-A/B",
            "### V3.2-A — PAGES",
            "### V3.2-B — GUTTER",
            "## 尝试摘要",
            "019fac4a-c73e-71c1-a6bd-a94a86627b3e",
            "019fac8e-bae8-73f2-af89-674e925b0068",
            "019fad38-517b-7ca1-82af-853b0ddc68f2",
            "44e3cf1b01625b4c9e810229a6d33a9bcf381bb9bc0dc9feda06384034c0a0cc",
            "## 美术基准继承",
            "Image 1 是用户锁定的任务详情视觉基准，是最高视觉权威",
            "Image 2 是已经接受的 QL-A1 结构 source",
            "Image 2 不得覆盖 Image 1",
            "V3.2-A `PAGES` 目标画布",
            "V3.2-B `GUTTER` 目标画布",
            "恰好包含 `8` 组",
            "每页中央至少 `85%`",
            "3、5、7 个针脚站",
            "## 生产正文完整性预检",
            "采用最高详细度层级",
            "未知但执行必需的值：无",
            "当前 V3.2-A／B 已达到可执行详细度",
            "本次审计不改变 V3.2 的执行正文",
            "## 最终执行正文",
            "### 固定执行映射",
            "自动修复预算",
            "`V3.2-A`：最多 `5`",
            "`V3.2-B`：最多 `5`",
            "最坏总调用数：`10`",
            "## 自主修复循环",
            "### 共同不可变边界",
            "A 输出不能成为 B 的参考",
            "若组合预演暴露某一目标的问题，只恢复该目标",
            "`candidate-rejected / P3 / repair-budget-exhausted`",
            "`V3.2-A.r1`",
            "`V3.2-A.r4`",
            "`V3.2-B.r1`",
            "`V3.2-B.r4`",
            "attempt-01",
            "attempt-02`–`attempt-05",
            "QL-A2_V3_2_A_PAGES.raw.png",
            "QL-A2_V3_2_B_GUTTER.raw.png",
            "47d14363049424b8c32b0eb486a87a0287adb4cc2af8f92e9416f0651cb796ea",
            "019faed6-8104-7ef2-94f7-8d80c5c885bc",
            "结论：`prompt-authorized / P3`",
            "这不是候选接受",
            "最终 source：无",
        ),
        "active QL-A2 work",
    )
    assert "/Users/" not in work.split(
        "## 最终执行正文\n\n", 1
    )[1].split("\n## 执行记录", 1)[0]

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

    assert not (ROOT / "prompts" / "quests").exists()
    print("quest design contract test passed")


if __name__ == "__main__":
    main()
