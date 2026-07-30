#!/usr/bin/env python3
"""Static contract checks for the compact quest module package."""

from __future__ import annotations

import hashlib
import json
import re
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
            "`QL-A2 V3.2` 已终止",
            "`QL-A2 V3.3`",
            "`P3` 部分执行",
            "B1 underlay＋folds",
            "B2 单枚 stitch",
            "B3 top／bottom closures",
            "B1 已耗尽 `5/5`",
            "`prompt-authorized 0/5`",
            "合计 `5/15`",
            "整批装配被 B1 阻塞",
            "Quest Tracker",
            "外部 provider `P0`",
            "NPC Quest／Gossip",
            "QL-A1_SourceManifest_v1.json",
            "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5",
            "241402／5650／1325994",
            "accepted source 或 runtime",
        ),
        "quest detailed progress",
    )

    require(
        work,
        (
            "版本：`QL-A2 V3.3`",
            "项目阶段：`P3`",
            "类型：`production`",
            "当前操作：",
            "用户授权：用户于 `2026-07-30` 明确确认",
            "允许 B1",
            "允许 B2／B3",
            "固定执行器：`imagegen-0-143-0`",
            "`V3.3-B1 / FOLDS`",
            "`V3.3-B2 / STITCH`",
            "`V3.3-B3 / CLOSURES`",
            "`V3.3-B1`：最多 `5`",
            "`V3.3-B2`：最多 `5`",
            "`V3.3-B3`：最多 `5`",
            "最坏总调用数：`15`",
            "Image 2 职责：只上传给 `V3.3-B1`",
            "B2／B3 禁止上传 Image 2",
            "47669c2d5c8243d47bc08cbe417be07bf74121a8a0e2aa8cae749ac109a106d8",
            "14fbcbaf5dedb6cdbffb1a74899a47489fcedc1020cf91d2de9d9acfc3817614",
            "## 美术基准继承",
            "Image 1 是用户锁定的任务详情视觉基准，是最高视觉权威",
            "Image 2 是已接受的 QL-A1 结构 source",
            "Image 2 不能覆盖",
            "Image 1 的美术权威",
            "运行时仍恰好是 `8` 个",
            "## 组件合同",
            "### B1 — FOLDS 源合同",
            "固定 `3 × 1` 隐形单元",
            "### B2 — STITCH 源合同",
            "恰好一个居中的横向 stitch",
            "最终 atlas 可见宽",
            "`160px`",
            "### B3 — CLOSURES 源合同",
            "左右两个 `768 × 1024` 隐形单元",
            "`45%–60%`",
            "不超过 `96 × 72px`",
            "最终 B atlas 为 `1536 × 1024 RGBA`",
            "Alpha bbox 加至少 `8px`",
            "3、5、7 个离散 stitch 预演",
            "## 生产正文完整性预检",
            "采用最高详细度",
            "未知但执行必需的值：无",
            "结论：`pass`",
            "## 最终执行正文",
            "### V3.3-B1",
            "### V3.3-B2 — STITCH",
            "### V3.3-B3 — CLOSURES",
            "## 固定执行映射",
            "QL-A2_V3_3_B1_FOLDS.raw.png",
            "QL-A2_V3_3_B2_STITCH.raw.png",
            "QL-A2_V3_3_B3_CLOSURES.raw.png",
            "## 自主修复循环",
            "### 共同不可变边界",
            "三个独立授权正文，各最多 `5` 次",
            "最坏总计 `15` 次",
            "不得跨段互传输出",
            "同一段前次输出只在对象数量、身份、透视和格位已通过",
            "### V3.3-B1 尝试表",
            "### V3.3-B2 尝试表",
            "### V3.3-B3 尝试表",
            "## 执行记录",
            "## 审查记录",
            "用户尚未发生的结论：没有候选接受",
            "最终 source：无",
        ),
        "active QL-A2 work",
    )
    execution_bodies = work.split("## 最终执行正文\n\n", 1)[1].split(
        "\n## 固定执行映射", 1
    )[0]
    assert "/Users/" not in execution_bodies
    assert execution_bodies.count("### V3.3-B") == 3
    assert any(
        f"子状态：`{state}`" in work
        for state in (
            "prompt-authorized",
            "candidate-raw",
            "repair-prepared",
            "candidate-reviewed",
            "candidate-rejected",
        )
    )
    call_counts = re.search(
        r"固定执行器调用：B1 `([0-5])/5`；B2 `([0-5])/5`；"
        r"B3 `([0-5])/5`；合计 `((?:[0-9]|1[0-5]))/15`",
        work,
    )
    assert call_counts is not None
    b1_calls, b2_calls, b3_calls, total_calls = map(
        int, call_counts.groups()
    )
    assert b1_calls + b2_calls + b3_calls == total_calls

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
