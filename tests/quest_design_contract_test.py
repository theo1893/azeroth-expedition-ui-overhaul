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
    directory_work = (
        QUESTS / "work" / "QUEST.LOG.DIRECTORY.md"
    ).read_text(encoding="utf-8")
    selection_work = (
        QUESTS / "work" / "QUEST.LOG.SELECTION.md"
    ).read_text(encoding="utf-8")
    status_work = (
        QUESTS / "work" / "QUEST.LOG.STATUS.md"
    ).read_text(encoding="utf-8")
    leftpage_work = (
        QUESTS / "work" / "QUEST.LOG.LEFTPAGE.md"
    ).read_text(encoding="utf-8")
    tracker_work = (
        QUESTS / "work" / "QUEST.TRACKER.CORE.md"
    ).read_text(encoding="utf-8")
    tracker_sim_spec_path = (
        ROOT / "tools" / "specs" / "quest_tracker_simulation_v2.json"
    )
    tracker_sim_spec = json.loads(
        tracker_sim_spec_path.read_text(encoding="utf-8")
    )
    tracker_review_path = (
        ROOT / "tools" / "review_quest_tracker_candidate_v1.py"
    )
    assert tracker_review_path.is_file(), tracker_review_path
    tracker_review = tracker_review_path.read_text(encoding="utf-8")
    require(
        tracker_review,
        (
            "chroma_key",
            "nine_slice",
            "three_slice",
            "real-layout-short-130x180.png",
            "real-layout-quest-230x500.png",
            "real-layout-dense-330x865.png",
            "real-layout-database-230x500.png",
            "tracker_",
            "NotoSansSC-Medium.ttf",
        ),
        "pfQuest tracker candidate review tool",
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
            "`QUEST.LOG.LIST.INSET`",
            "`QUEST.LOG.REGION.BACKPLATE`",
            "`QUEST.LOG.ROW.BACKPLATE`",
            "`QUEST.LOG.LIST.ROW`",
            "`QuestLogTitle1..23`",
            "`QuestLogTitle1..18`",
            "`QuestLogTitleButtonTemplate`",
            "`QUEST.LOG.LIST.CHECK`",
            "不是选择 Button",
            "`QUEST.LOG.SELECTION`",
            "暂停挂载并隐藏",
            "adapter 不再创建、挂载或刷新酒红色书签",
            "目录文字继续从 `x>=18` 起",
            "`QUEST.LOG.TYPE.BADGE`",
            "`QUEST.LOG.TIMER.BADGE`",
            "`GetQuestTimers()`",
            "`GetQuestIndexForTimer()`",
            "`QUEST.LOG.STATE.SEAL`",
            "`224 × 15 UI px`",
            "`14px` 纵向步进",
            "`QUESTS_DISPLAYED = 18`",
            "`224 × 18 UI px`",
            "`18px`",
            "work/QUEST.LOG.LEFTPAGE.md",
            "`QL-B1`",
            "`QL-B2`",
            "`QL-B3`",
            "`x=176..186`",
            "`x=187..197`",
            "`x=198..210`",
            "`155px`",
            "显式登记且经目标客户端证实",
            "`QUEST.LOG.LIST.SCROLL.TRACK`",
            "`QUEST.LOG.LIST.SCROLL.THUMB`",
            "`QUEST.LOG.LIST.SCROLL.UP`",
            "`QUEST.LOG.LIST.SCROLL.DOWN`",
            "`QUEST.LOG.DETAIL.SCROLL.TRACK`",
            "`QUEST.LOG.DETAIL.SCROLL.THUMB`",
            "`QUEST.LOG.DETAIL.SCROLL.UP`",
            "`QUEST.LOG.DETAIL.SCROLL.DOWN`",
            "视觉隐藏且不接收鼠标",
            "`OnMouseWheel`",
            "`28 UI px`",
            "`QUEST.LOG.DETAIL.TITLE`",
            "`QUEST.LOG.DETAIL.DESCRIPTION`",
            "`QUEST.LOG.DETAIL.OBJECTIVES`",
            "`QUEST.LOG.DETAIL.REWARD_TEXT`",
            "`QUEST.LOG.REWARD.SLOT`",
            "无 selected",
            "`QUEST.LOG.ACTION.ABANDON`",
            "`QUEST.LOG.ACTION.SHARE`",
            "`QUEST.LOG.ACTION.EXIT`",
            "程序化暗皮革搭扣四状态",
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
            "`QUEST.LOG.PFQUEST.ONLINE`",
            "`QUEST.LOG.PFQUEST.LANGUAGE`",
            "`QUEST.LOG.PFQUEST.SHOW`",
            "`QUEST.LOG.PFQUEST.HIDE`",
            "`QUEST.LOG.PFQUEST.CLEAN`",
            "`QUEST.LOG.PFQUEST.RESET`",
            "`pfQuestMapTracker`",
            "`QT-SIM V2`",
            "`QUEST.TRACKER.SHELL`",
            "`QUEST.TRACKER.PAPER.TOP`",
            "`QUEST.TRACKER.PAPER.MIDDLE`",
            "`QUEST.TRACKER.PAPER.BOTTOM`",
            "`QUEST.TRACKER.HEADER.STRAP`",
            "`QUEST.TRACKER.MODE.QUESTS`",
            "`QUEST.TRACKER.MODE.DATABASE`",
            "`QUEST.TRACKER.MODE.GIVERS`",
            "`QUEST.TRACKER.ACTION.SEARCH`",
            "`QUEST.TRACKER.ACTION.CLEAN`",
            "`QUEST.TRACKER.ACTION.SETTINGS`",
            "`QUEST.TRACKER.ACTION.CLOSE`",
            "`pfQuestMapButton1..25`",
            "`QUEST.TRACKER.ENTRY.FOCUS`",
            "`QUEST.TRACKER.ENTRY.ICON`",
            "`QUEST.TRACKER.ENTRY.TITLE`",
            "`QUEST.TRACKER.OBJECTIVE`",
            "`QUEST.TRACKER.ENTRY.TRACKED`",
            "`QUEST.TRACKER.ENTRY.COMPLETE`",
            "`130..330 UI px`",
            "`expand_states`",
            "timer／failed",
            "`scope-deferred`",
            "不授权隐藏、删除、重挂",
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
            "`pfQuestMapTracker`",
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
            "`QUEST.LOG.LIST.INSET`",
            "`QUEST.LOG.REGION.BACKPLATE`",
            "`QUEST.LOG.ROW.BACKPLATE`",
            "`18 × 18`",
            "work/QUEST.LOG.LEFTPAGE.md",
            "work/QUEST.LOG.DIRECTORY.md",
            "work/QUEST.LOG.SELECTION.md",
            "`QUEST.LOG.TIMER.BADGE`",
            "未知 tag",
            "work/QUEST.LOG.STATUS.md",
            "`10px`／`10px`／`12px`",
            "不使用单槽优先级",
            "ScrollBar 与操作 Button",
            "Quest Tracker",
            "`QT-SIM V2`",
            "模拟 ImageGen 固定 `0/0`",
            "`130..330 UI px`",
            "视觉基线尚未冻结",
            "`scope-deferred`",
            "work/QUEST.TRACKER.CORE.md",
            "用户已于",
            "确认 `QT-SIM V2`",
            "独立授权 QT-A1／B1 V1",
            "两段当前均为 `prompt-authorized 0/5`",
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
            "`QL-B1 V1`",
            "`QL-B0 V2`",
            "`candidate-rejected / repair-budget-exhausted / P3`",
            "work/QUEST.LOG.LEFTPAGE.md",
            "`QUESTS_DISPLAYED = 18`",
            "`224 × 18px`",
            "A 终止于 `4/5`",
            "`user-rejected /",
            "scope-removed / P3`",
            "B `5/5`",
            "`runtime-exported / P5`",
            "`5/5`",
            "`15px` 行高／`14px` 步进",
            "work/QUEST.LOG.DIRECTORY.md",
            "QuestLogDirectoryMarks_Master_v1.png",
            "QL-B1_SourceManifest_v1.json",
            "QL-B1_RuntimeManifest_v1.json",
            "QuestLogDirectoryMarksV1.tga",
            "e734bbf59da00f7fbc9c75649d33eaf635b5a0c19e1737128dfdce0db58eee8f",
            "c0e5bdffc5ce09872c0da0709a3269245ef424f4dde03335d59ded335dc5fdd5",
            "`QL-B2 V1`",
            "`P5 runtime-exported`",
            "work/QUEST.LOG.SELECTION.md",
            "实际生图 `5/5`",
            "流程错误 `3`",
            "`1.776:1`",
            "确定性 bbox-fit",
            "4f8955410ecfaac6697cabeb9bd076d4bd0f5b5adcc97964cee0b7b49d38efaa",
            "QL-B2_RuntimeManifest_v1.json",
            "QuestLogSelectionBookmarkV1.tga",
            "bab9e8bf6961b743d9591bb148878e9eadbbbbd99eac9a183446bf9c81a770b4",
            "2cd8de894c389f5c7eaf5c5d5388a20b363fa414022dc4dac57eacda1fa79029",
            "build_quest_log_selection_bookmark_v1.py",
            "`P3 repair-budget-exhausted`",
            "work/QUEST.LOG.STATUS.md",
            "QL-B3-A／B／C V1",
            "最坏 `15`",
            "review_quest_log_status_candidate_v1.py",
            "Quest Tracker",
            "provider 对象合同 `P1`",
            "独立授权 QT-A1／B1 V1",
            "QT-A1／B1 V1",
            "`QT-SIM V2`",
            "`simulation-confirmed`、ImageGen `0/0`",
            "回复",
            "确认主体方向",
            "`prompt-authorized / P3 / 0/5`",
            "`scope-deferred 0/5`",
            "QUEST.TRACKER.CORE.md",
            "NPC Quest／Gossip",
            "QL-A1_SourceManifest_v1.json",
            "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5",
            "241402／5650／1325994",
            "未晋级任何 V3.2／V3.3 候选",
        ),
        "quest detailed progress",
    )

    require(
        tracker_work,
        (
            "pfQuest 任务追踪核心工作文件 — QT V2",
            "`repair-prepared`",
            "`pfQuest 7.0.1`",
            "`pfQuest-turtle 7.0.2`",
            "`imagegen-0-143-0`",
            "`@openai/codex@0.143.0`",
            "QT-A1 `2/5`",
            "QT-A2 `0/5`",
            "QT-B1 `0/5`",
            "最坏合计",
            "`10` 次实际生成／修图",
            "`scope-deferred`",
            "流程错误",
            "`pfQuestMapTracker`",
            "`130..330 UI px`",
            "`tracker.btnquest`",
            "`tracker.btndatabase`",
            "`tracker.btngiver`",
            "`tracker.btnsearch`",
            "`tracker.btnclean`",
            "`tracker.btnsettings`",
            "`tracker.btnclose`",
            "`pfQuestMapButton1..25`",
            "`button.tracked`",
            "`button.perc`",
            "`pfMap.highlight`",
            "`expand_states`",
            "`QT-A1 V1`",
            "`QT-A2 V1`",
            "`QT-B1 V1`",
            "生成前模拟实例图 — QT-SIM V2",
            "`simulation-confirmed / 2026-07-31`",
            "`1536 × 1024`",
            "`330 × 865 UI px`",
            "十个任务、十七条目标",
            "deterministic-local-geometry",
            "模拟 ImageGen：`0/0`",
            "tools/specs/quest_tracker_simulation_v2.json",
            "3961a538bae7debf770e4e036e6ac643c2e1ed5ca3c1b9ce959bc61bc5c362fe",
            "render_geometric_mockup.py",
            "`x=1166..1496`、`y=72..937`",
            "矩形、多边形、线段、椭圆和真实字体排版",
            "无生成纹理",
            "本地渲染命令",
            "quest_tracker_core_local_geometry_v2.png",
            "quest_tracker_core_local_geometry_v2_zoom.png",
            "cb54d64f78c100fae94d387c280017f522871d144d0b71aa01fdbb8c1deea4a2",
            "a49b3913591f32b305e18b9802cb3317a1a329f8692af99e7580b679b1f8f360",
            "displayable",
            "3b5c2ca6c1e69c74db5c64978cde351596ece6369d339b7125aee43904eb7d86",
            "03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd",
            "88ecd502e190311c8709a6fd15e2cde6d1f5f288a749e5f5b318f7038e188504",
            "2004 年前后香草魔兽二维手绘位图",
            "用户回复“继续”",
            "确认并写回生产正文的可见条款",
            "活动纸面从顶部直接开始",
            "十个任务、十七条目标",
            "右侧页边",
            "### QT-A1 V1",
            "状态：`production / 已授权`",
            "exactly 1024 × 1536 pixels",
            "The visible paper begins",
            "directly at its upper edge",
            "Do not attach or imply a toolbar",
            "130..330 UI-pixel width range",
            "twenty-five dynamic entries",
            "Input roles and art direction",
            "### QT-A2 V1 — scope-deferred",
            "当前工作树不保留可误执行的正文",
            "### QT-B1 V1",
            "exactly three separate interaction-feedback art objects",
            "outer right page edge",
            "three-slice cleanly",
            "Prompt 完整性预检",
            "`pass / production / 已授权`",
            "未知但执行必需的值：无",
            "Repair envelope 与计数",
            "两段最坏合计 `10` 次",
            "真实排版预演",
            "`130 × 180`",
            "`230 × 500`",
            "`330 × 865`",
            "`scope-deferred / non-authoritative`",
            "本地渲染错误：`0`",
            "本授权不包含 source 晋级",
            "QT-A1 V1.r1 — 完整修复正文",
            "QT-A1 V1.r2 — 完整修复正文",
            "019fb62d-a545-70f3-9ea1-10f1017bb806",
            "019fb638-0608-7be3-b76c-889f2760d373",
            "f22dc61ea2762ca3ce54fa73436737c8ce19926c4e753149f5d42aa3cfdbbaea",
            "e4b6a258ffe4bbf82d4bd6386bf4323df4da983bbe04b8cd218071c94fb1429b",
            "tools/review_quest_tracker_candidate_v1.py",
            "`internal-rejected / repair-prepared / P3`",
        ),
        "pfQuest tracker production final",
    )
    assert tracker_work.index("## 生成前模拟实例图") < tracker_work.index(
        "## 最终执行正文"
    )
    assert "/Users/" not in tracker_work
    assert "QuestWatchLine" not in tracker_work
    assert tracker_sim_spec["canvas"] == {
        "width": 1536,
        "height": 1024,
        "mode": "RGBA",
        "fill": "#344D50FF",
    }
    tracker_sim_layers = tracker_sim_spec["layers"]
    tracker_sim_text = [
        layer["text"]
        for layer in tracker_sim_layers
        if layer["type"] == "text"
    ]
    assert sum(text.startswith("[") for text in tracker_sim_text) == 10
    assert sum(text.startswith("—") for text in tracker_sim_text) == 17
    assert not any(
        text in ("任", "库", "人", "查", "清", "设", "×")
        for text in tracker_sim_text
    )
    assert (
        tracker_sim_spec["output"]
        == "../../generated/quests/QT/simulation/QT-SIM-V2/"
        "quest_tracker_core_local_geometry_v2.png"
    )
    assert "Create a source atlas containing exactly ten separate art objects" not in (
        tracker_work
    )

    require(
        leftpage_work,
        (
            "Quest Log 左页卷宗目录 V2",
            "`QL-B0-A V2`",
            "`QL-B0-B V2`",
            "A／B 均为 `user-rejected / scope-removed`",
            "B 的预算终态同时保留",
            "`user-rejected / scope-removed`",
            "`2026-07-31`",
            "不再增加框",
            "项目阶段：`P3`",
            "授权正文状态：B attempt 1／2／3／4／5 均已完成并退回",
            "用户授权：`2026-07-30`",
            "当前实际生图：A `4/5`；B `5/5`",
            "流程错误：A `4`；B `2`",
            "原授权最坏总预算：`10`",
            "最坏总实际调用变为 `9`",
            "@openai/codex@0.143.0",
            "任务详情面板_视觉基准_v1.png",
            "03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd",
            "QuestLogBookShell_Master_v1.png",
            "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5",
            "`QUEST.LOG.LIST.INSET`",
            "`QUEST.LOG.REGION.BACKPLATE`",
            "`QUEST.LOG.ROW.BACKPLATE`",
            "`QUESTS_DISPLAYED = 18`",
            "`QuestLogTitle1..18`",
            "`262 × 340 UI px`",
            "`246 × 324 UI px`",
            "`224 × 18 UI px`",
            "`x=250..774, y=172..852`",
            "`x=112..912, y=272..336`",
            "`x=112..912, y=688..752`",
            "`normal／hover／pressed／disabled`",
            "`512 × 128`",
            "不生成假图标槽",
            "## 生产正文完整性预检",
            "结论：pass",
            "## 已撤销且不得执行的草案 — QL-B0-A V2.r4",
            "## 已执行正文 — QL-B0-B V2.r3",
            "## 最终执行正文 — QL-B0-B V2.r4",
            "84f6764d4817c2872dbb8800b17de6044698753bcc96887d880a01a2f57c0a2e",
            "## Repair envelope 与计数",
            "`candidate-rejected / repair-budget-exhausted`",
            "019fb343-1f5c-7c83-94d4-a89c7b11451f",
            "c089b2069ec34ac6be089fba36dfc0fa7835e1c208acd7804f277ec30e602224",
            "919f7624b4c9def6c5021ea43a7a5cd0e4be7d65e3bc0e5408d7d8b6a5531260",
            "019fb354-1d02-78f3-8d01-9cde28c841bf",
            "64990bc5dd6f38ee0bce7f746a9335c265a9a15dd385875e4f467b106e329024",
            "1c5e122cb0cdd48bf54e86547b16ce8c0f5c1a8621e40ec760a96be028dee07d",
            "019fb35e-6697-71f3-b2b7-f6033ef290d2",
            "92ce740a8812d2c5fee96ae6152cac482458fa958b683795abf742dc792a723c",
            "4fc83fd50ec4345edba7dd5a3bc8ef243a35ceecac885ca5e228743d559819da",
            "019fb367-828c-71a2-a5b8-088bcf4e1472",
            "f2d03067e47578a8444ec8efb4d9548f185ab320152e8cf9d4fdcd7c9b44ef4f",
            "96ea48421304cfeef52afa9b740998537ca21fbcfa8dab0ba2d33cfdfa042ade",
            "019fb37c-4303-7c13-9208-06c86d57abbe",
            "ddf18110041b24b700077f52fcaeabd48340739966b067edc6495092f574a195",
            "b2b78eac320f1e96ddfafb8b07358d76f6da27b9bd114da26ef0b0f716487299",
            "a91a5f264ddfa2d8cd1e996fa0484148f89789a74af3ae1fb6facf2fef752b71",
            "cd56fa1fd7624183c9c250f01fb400127d721193e8fa5f39ae4b2deaa43a04d3",
            "019fb386-2fd3-76e3-b11b-1828fec80275",
            "0b948e68cb50c1bf10fede8dcb473f6d2b33680f81c6d29366895fae440effab",
            "be68ce6ca3e8a706016b3ddab6c495c31a1c809cceea5f536191de27453e2d17",
            "7c89554e75b866eedc9c9079130659149183646d825b16ba06d82fe4f6c4194f",
            "b355292b9ce42c6dd7a6cf6dce47626deab9bbdc932ef8c843189ce62c0dd0f0",
            "019fb38e-19d1-7a70-9e4a-efdb8bff70c1",
            "5ee6ba57d94006b0833bba1e96074d3ebeab8d3d8e7b8f233ebde3d664030721",
            "7009915ffda52e17d9e0cb11ebbc7f1e1649c8c5cafb8b45412a5d07ff931f78",
            "826ba5b264cb349af71696f9f1346f084eb63c7b68418ec76fdee9d064d0032e",
            "197308e2d2765559903f0d7b9ea27988b8c419be070a9fe437e90d8ed8e3be8e",
            "`authority-blocked / process-error`",
            "B-E2",
            "fixed CLI 未启动；无 child session／result",
            "B attempt 4 上传授权",
            "5ee6ba57d94006b0833bba1e96074d3ebeab8d3d8e7b8f233ebde3d664030721",
            "B attempt 4 审查记录",
            "019fb3a0-832a-7dd2-a880-796d5b824397",
            "290cc9f40b6b3bf4eda0a019cdba42910bc352aed97e9e58533b61c319397091",
            "0ea602b0398a3ee2f97e924502e48e4ffe7c5b23071f7753b9b2a3aa57eb5131",
            "fbb168bca1a7a348d4f4df1fc6c290dafaa660224259d7e728abd52f67f25aea",
            "6f9d5aac8c3d0dc17ce29ca5b965c8fa1f72432290ef65a11a0c822420461ddd",
            "`[137,333]..[1117,411]`",
            "`[137,843]..[1117,921]`",
            "B attempt 5 审查记录",
            "019fb3b4-1ce9-7111-b1aa-6595f9e4a7e2",
            "827b9d199dbc3fff3eb305aeba0c1e60ec742ef7c8b7241072cba015d269b253",
            "492b2d10e15d35c4ee7927b084175fa0492d37551037d02eb92438156a8dac19",
            "8cc51f0bed9e593db04d3788a27b901278398aee872a2e29dde32bcc397bb6b0",
            "a491fb6963674496c5d53a4aa2957efbb809817aeb22238029095638ce946b37",
            "`candidate-rejected / repair-budget-exhausted / P3`",
            "不得调用 attempt 6",
            "`user-rejected / scope-removed`",
            "不建立 A source、manifest、TGA、adapter Texture",
            "## 下一门禁",
            "每段最多 5 次，最坏合计 10 次",
        ),
        "quest left-page V2 prompt contract",
    )
    assert "/Users/" not in leftpage_work
    assert "codex-clipboard-" not in leftpage_work
    assert leftpage_work.count("## 当前执行正文 — QL-B0-A") == 0
    assert leftpage_work.count("## 已撤销且不得执行的草案 — QL-B0-A") == 1
    assert leftpage_work.count("## 最终执行正文 — QL-B0-B") == 1
    assert leftpage_work.count("## 当前执行正文 — QL-B0-B") == 0

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

    require(
        directory_work,
        (
            "版本：`QL-B1 V1`",
            "子状态：`runtime-exported`",
            "项目阶段：`P5`",
            "固定执行器：`imagegen-0-143-0`",
            "当前尝试：`5/5`",
            "QUEST.LOG.REGION.TOGGLE",
            "QUEST.LOG.LIST.CHECK",
            "任务详情面板_视觉基准_v1.png",
            "03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd",
            "QuestLogBookShell_Master_v1.png",
            "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5",
            "## 当前批次边界",
            "`QL-B0`",
            "`QL-B1`",
            "`QL-B2`",
            "`QL-B3`",
            "`QUEST.LOG.COLLAPSE.ALL` 是独立 Button",
            "## 美术基准继承",
            "Image 1 与",
            "Image 2 作为已接受书体的受限材料",
            "不继承 Image 1 的完整书体、逐行卡片",
            "原生／pfUI 的 `+`、`-`",
            "## 组件合同",
            "QuestLogTitleButtonTemplate",
            "`QUESTS_DISPLAYED = 23`",
            "`224 × 15 UI px`",
            "纵向步进 `14px`",
            "`64 × 16` RGBA TGA",
            "`16 × 16` cell",
            "`1024 × 1024`",
            "`2 × 2`",
            "`512 × 512`",
            "`#00FF00`",
            "## 生产正文完整性预检",
            "结论：`pass`",
            "## 最终执行正文",
            "输出恰好一张 `1024 × 1024`",
            "左上格",
            "右上格",
            "左下格",
            "右下格",
            "严格顺时针旋转九十度",
            "只在圈内增加一笔粗短",
            "绝对禁止出现任何文字",
            "## 自主修复循环",
            "最多 `5` 次",
            "固定 SHA 的 Image 1／Image 2",
            "runtime-exported / P5",
            "QL-B1 V1.r3",
            "019fb1e8-db9a-7010-86d1-98008548e4d6",
            "73f719d44a55b01d0ef8bc6f2c07343679a10b155d612941ca72d16869527596",
            "719445d15fb34be4af3ec316eac5bdec51c2061423bae5d7f45b47a3b1128c44",
            "QuestLogDirectoryMarks_Master_v1.png",
            "QL-B1_SourceManifest_v1.json",
            "QL-B1_RuntimeManifest_v1.json",
            "QuestLogDirectoryMarksV1.tga",
            "build_quest_log_directory_marks_v1.py",
            "`676 × 464`／100% runtime",
            "全部 23 个行槽",
            "确定性逐格裁切、等比缩放、居中与 Alpha",
        ),
        "active QL-B1 work",
    )
    assert "/Users/" not in directory_work
    assert directory_work.count("## 最终执行正文") == 1
    assert "attempt 1" in directory_work.lower()
    assert "该接受不声称失败门禁已经客观通过" in directory_work

    require(
        selection_work,
        (
            "版本：`QL-B2 V1`",
            "子状态：`asset-retained / runtime-hidden`",
            "项目阶段：`P5`",
            "固定执行器：`imagegen-0-143-0`",
            "当前实际生图：`5/5`",
            "流程错误：`3`",
            "明确授权 `QL-B2 V1`",
            "用户于 `2026-07-31`",
            "自 runtime contract `1.5` 起不再引用 atlas",
            "恢复显示前需要新的明确确认",
            "`QUEST.LOG.SELECTION`",
            "任务详情面板_视觉基准_v1.png",
            "03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd",
            "QuestLogBookShell_Master_v1.png",
            "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5",
            "## 当前批次边界",
            "## 美术基准继承",
            "Image 1 与 `ART_BASELINE.md`",
            "三状态只允许从一份 source 确定性派生",
            "## 组件合同",
            "`GetQuestLogSelection()`",
            "`FauxScrollFrame_GetOffset(QuestLogListScrollFrame)`",
            "`224 × 15 UI px`",
            "`24 × 14 UI px`",
            "`32 × 16 UI px`",
            "`x=-12 UI px`",
            "`x>=18`",
            "`128 × 16`",
            "全透明保留格",
            "三格 Alpha 必须逐像素相同",
            "三张独立的",
            "`676 × 464`／100% runtime",
            "全部 23 个真实行槽",
            "## 生产正文完整性预检",
            "结论：`pass`",
            "## 最终执行正文",
            "单物件 UI sprite",
            "`384 × 224px` 安全盒",
            "左端必须平直",
            "不能形成三角箭头",
            "纯 `#00FF00`",
            "## 自主修复循环",
            "最多 `5` 次",
            "同一循环的前次输出",
            "QL-B2 V1.r1 完整修复正文",
            "QL-B2 V1.r2 完整修复正文",
            "QL-B2 V1.r3 完整修复正文",
            "QL-B2 V1.r4 完整修复正文",
            "`1.65:1–1.80:1`",
            "within-frozen-envelope / pass",
            "candidate-rejected / repair-budget-exhausted / P3",
            "019fb225-7693-7851-a4da-fade93ace5ca",
            "019fb230-e3d7-7342-bde0-5ad5a5685a15",
            "019fb239-1112-7431-9d5d-b964d7c15b3f",
            "019fb241-145d-7a03-a336-b9547d817439",
            "019fb249-c0d3-7301-9368-af3fbab1ea1e",
            "be75700570931c56aeea7ff46de7823ec233abbd546cf7c2cc32b0557b4f66ce",
            "bdc1d32583e75ca36bb7a4c6f2dcbc5225238c8e12b74543b25c3be8895c5e7c",
            "97c22622c585b9c2a6c5c9de86839a940effcd8131b08c667d58cb88af60aaee",
            "af86a7b32df36c91023ae2866fbc6fe5b879a1c17e6cda5d5ce36bf034eea9dc",
            "ca2731c06ac7c2003a45407741739f722d61d26a4fb0ebedb9149e907bbcf161",
            "`563 × 317`",
            "`24 × 14`",
            "三张独立",
            "全部 23 行",
            "## 确定性 bbox-fit 合同例外与 P4 接受",
            "`352 × 198px`",
            "`4f8955410ecfaac6697cabeb9bd076d4bd0f5b5adcc97964cee0b7b49d38efaa`",
            "`source-accepted / P4`",
            "Alpha 改变像素均为 `0`",
            "`runtime-exported / P5`",
            "## P5 确定性导出与接入",
            "QuestLogSelectionBookmarkV1.tga",
            "QL-B2_RuntimeManifest_v1.json",
            "build_quest_log_selection_bookmark_v1.py",
            "`24 × 14`",
            "`32 × 16`",
            "`128 × 16`",
            "精确有理数 half-up",
            "adapter runtime contract `1.2`",
            "Turtle WoW 实机尚未验证",
        ),
        "active QL-B2 work",
    )
    assert "/Users/" not in selection_work
    assert selection_work.count("## 最终执行正文") == 1
    assert "流程错误单列，不占额度" in selection_work
    assert "不占生图额度" in selection_work

    require(
        status_work,
        (
            "QL-B3 目录任务状态覆盖 V1",
            "`candidate-rejected / repair-budget-exhausted`",
            "`P3`",
            "`imagegen-0-143-0`",
            "`QL-B3-A V1`",
            "`QL-B3-B V1`",
            "`QL-B3-C V1`",
            "QL-B3-A：`5/5`",
            "QL-B3-B：`0/5`",
            "QL-B3-C：`0/5`",
            "多执行正文最坏实际生图数：`15`",
            "03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd",
            "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5",
            "## 美术基准继承",
            "## 组件合同",
            "`x=176..186`",
            "`x=187..197`",
            "`x=198..210`",
            "`155px`",
            "可以在同一任务行同时出现",
            "`1024 × 1024`",
            "`2 × 2`",
            "`64 × 16 RGBA TGA`",
            "`16 × 16 RGBA TGA`",
            "`32 × 16 RGBA TGA`",
            "纯 `#00FF00`",
            "全部 `23` 行",
            "## 生产正文完整性预检",
            "结论：三段均 `pass`",
            "## 最终执行正文 — QL-B3-A V1",
            "## 最终执行正文 — QL-B3-B V1",
            "## 最终执行正文 — QL-B3-C V1",
            "左上 `elite`",
            "右上 `dungeon`",
            "左下 `raid`",
            "右下 `pvp`",
            "一个正面平视、垂直朝上的沙漏压印",
            "左格只放 `complete`，右格只放 `failed`",
            "## QL-B3-A V1.r1 完整修复正文",
            "Image 3 是本段前一次生成",
            "不得超过 `220px`",
            "## QL-B3-A V1.r2 完整修复正文",
            "不超过 `140px`",
            "中心误差均不超过 `8px`",
            "## QL-B3-A V1.r3 完整修复正文",
            "当前可见尺寸的约 `50%`",
            "`192 × 192` 内部盒",
            "## QL-B3-A V1.r4 完整修复正文",
            "本次只修复背景色键",
            "`#09F911`",
            "## 自主修复循环",
            "同一段循环前一次输出",
            "2026-07-30",
            "用户授权范围已经冻结",
            "019fb293-2175-7070-a257-87086887f603",
            "ig_0cb39047645036d8016a6b27c524288191801b7e6dd6d8a610",
            "6bb9996a8b8f83b9185c0d4e1c123f74ce9de0077bec4e2722fc456a5b945364",
            "011c7eda3751aff17b148fa433b8c39b764faa6cf327d3fd8857da054ea079d1",
            "1586abe81346c5a163cab3a5eb2d33c24db11c6cb5d57a3efd1dacabd54d412a",
            "019fb2a0-e316-70b0-ae98-3de032a2fe93",
            "ig_095752b9d2875834016a6b2b5244388191872768206eb8a502",
            "25a0de6f2411797000e062805482ec80a8aa9ab8296db19d2bf14f5537891413",
            "1d06098f3db51f512bab1f3d207d49ea5dd9b7a83c3fd7546285800d4c50be5c",
            "67eac225f1f1a1c227339eb7557c1d99989b72092e08168658cbe523d463714a",
            "`cfa7715`",
            "019fb2a9-8a48-7da2-addf-dfc7e0f29a05",
            "ig_0eae0c803936b5ed016a6b2d8312b881919466d9ff6ef9f738",
            "488cab28a69b88a613dc8123d1c3caa60b4b7c9f76f5bc3a36144b64841374f7",
            "d15bb7aecc7d22fb87afa56577c2e46ce556de2888637efe2ba7c85ce8853b81",
            "aaa11ecb2c3348fbb190bfd51de688516c78e67a2b8549cee7c4aa6715434f38",
            "`36e7921`",
            "019fb2b0-f3b2-7ff2-a6d1-3911625e53bc",
            "ig_02db1bbbb2af7430016a6b2f7019408191afcde04361b058d0",
            "f3a6272a37fc0220cabb1fab45ae52b57a2f65965e8b5bcdf2151df0c9984901",
            "d5aa0ef5dd2a52001d944a438fb8a1199060adcb261ad117b9122b15e582d2a4",
            "da9bf7d92ac72f493445a996ed9eeaa917cd8ef310413ab49291b4635ac99ec4",
            "`9c0f4db`",
            "019fb2b8-f1df-7583-bd8c-a6234a80ee2f",
            "ig_0f3a3221a8a5ddcc016a6b3174f82c81919f2357b8d392fa96",
            "2c6db95eff7d2222d05a7e014bfb1d0def29a81002371cc5d945253d933fd66c",
            "83aac7a09c99e98cf64dc58360126045d4cfa004441f381390fd39280fc5a60c",
            "9c7e3320b8557b2dc75bf0434fc095ac1a7c43c38302b4f4c0ad5e2dd7d1c0d4",
            "E1／E2／E3",
            "| E4 |",
            "candidate-rejected / P3 / repair-budget-exhausted",
            "## 耗尽后的用户决策边界",
            "A 已在 attempt 5 耗尽并停止",
        ),
        "active QL-B3 work",
    )
    assert "/Users/" not in status_work
    assert status_work.count("## 最终执行正文 — QL-B3-") == 3

    status_review_tool = (
        ROOT / "tools" / "review_quest_log_status_candidate_v1.py"
    )
    status_review_source = status_review_tool.read_text(encoding="utf-8")
    require(
        status_review_source,
        (
            "SOURCE_SIZE = (1024, 1024)",
            "ROW_COUNT = 23",
            "TEXT_WIDTH = 155",
            "TYPE_X = 176",
            "TIMER_X = 187",
            "STATE_X = 198",
            "TRACK_X = 212",
            "source_safe_box_pass",
            "non_authoritative_placeholders",
            "real_layout_676x464.png",
            "QuestLogSelectionBookmarkV1.tga",
        ),
        "QL-B3 deterministic review tool",
    )
    compile(
        status_review_source,
        str(status_review_tool),
        "exec",
    )

    selection_source_path = (
        ROOT
        / "assets"
        / "source"
        / "quests"
        / "ql-b2"
        / "QuestLogSelectionBookmark_Master_v1.png"
    )
    selection_manifest_path = selection_source_path.with_name(
        "QL-B2_SourceManifest_v1.json"
    )
    selection_manifest = json.loads(
        selection_manifest_path.read_text(encoding="utf-8")
    )
    selection_source_bytes = selection_source_path.read_bytes()
    assert selection_source_bytes[:8] == b"\x89PNG\r\n\x1a\n"
    assert selection_source_bytes[12:16] == b"IHDR"
    width, height = struct.unpack(">II", selection_source_bytes[16:24])
    assert (width, height, selection_source_bytes[24:26]) == (
        1024,
        1024,
        b"\x08\x06",
    )
    assert selection_manifest["batch"] == "QL-B2"
    assert selection_manifest["version"] == "V1.r4-bbox-fit"
    assert selection_manifest["status"] == "accepted-source"
    assert hashlib.sha256(selection_source_bytes).hexdigest() == (
        selection_manifest["source"]["sha256"]
    )
    assert selection_manifest["source"]["sha256"] == (
        "4f8955410ecfaac6697cabeb9bd076d4bd0f5b5adcc97964cee0b7b49d38efaa"
    )
    assert selection_manifest["source"]["visible_bbox_exclusive"] == [
        336,
        413,
        688,
        611,
    ]
    assert selection_manifest["accepted_contract_exception"][
        "redraw"
    ] is False
    assert selection_manifest["review"]["runtime_visual_accepted"] is True
    assert selection_manifest["review"]["prior_internal_result"] == (
        "candidate-rejected / repair-budget-exhausted"
    )
    assert selection_manifest["export_contract"]["status"] == (
        "runtime-exported"
    )
    assert selection_manifest["export_contract"]["runtime_atlas_size"] == [
        128,
        16,
    ]
    assert len(selection_manifest["runtime_exports"]) == 1
    assert selection_manifest["runtime_exports"][0]["sha256"] == (
        "bab9e8bf6961b743d9591bb148878e9eadbbbbd99eac9a183446bf9c81a770b4"
    )

    selection_runtime_manifest_path = selection_source_path.with_name(
        "QL-B2_RuntimeManifest_v1.json"
    )
    selection_runtime_manifest = json.loads(
        selection_runtime_manifest_path.read_text(encoding="utf-8")
    )
    assert selection_runtime_manifest["status"] == "runtime-exported"
    assert selection_runtime_manifest["runtime_contract"] == "1.0"
    selection_transform = selection_runtime_manifest["transform"]
    assert selection_transform["atlas_size"] == [128, 16]
    assert selection_transform["cell_size"] == [32, 16]
    assert selection_transform["content_size"] == [24, 14]
    assert selection_transform["content_offset"] == [4, 1]
    assert selection_transform["state_order"] == [
        "selected",
        "selected-hover",
        "selected-pressed",
        "reserved-transparent",
    ]
    assert selection_transform["state_alpha_identical"] is True
    assert len(set(selection_transform["state_alpha_sha256"].values())) == 1
    assert next(
        iter(selection_transform["state_alpha_sha256"].values())
    ) == (
        "2cd8de894c389f5c7eaf5c5d5388a20b363fa414022dc4dac57eacda1fa79029"
    )
    selection_states = selection_transform["states"]
    assert selection_states["selected"]["runtime_content_xyxy"] == [
        4,
        1,
        28,
        15,
    ]
    assert selection_states["selected-hover"]["texcoord"]["left"] == 0.25
    assert selection_states["selected-pressed"]["texcoord"]["left"] == 0.5
    assert selection_states["reserved-transparent"]["texcoord"]["left"] == 0.75
    assert selection_runtime_manifest["layout_contract"][
        "selection_anchor"
    ] == {
        "point": "LEFT",
        "relative_point": "LEFT",
        "x": -12,
        "selected_y": 0,
        "hover_y": 0,
        "pressed_y": -1,
    }
    selection_previews = selection_runtime_manifest["simulation"][
        "real_layout_previews"
    ]
    assert set(selection_previews) == {
        "selected",
        "selected-hover",
        "selected-pressed",
    }
    assert all(
        preview["size"] == [676, 464]
        and preview["runtime_scale_percent"] == 100
        for preview in selection_previews.values()
    )
    assert selection_previews["selected"]["sha256"] == (
        "bba74c3591c60efa27c3f3d9c1a3266661d76c7aff7ed46230f8ef2b1ca4baaf"
    )
    assert selection_previews["selected-hover"]["sha256"] == (
        "eac7c0fee22ca7f7eb57449b2710588743f141745510cc6029d2b9478d7a9f40"
    )
    assert selection_previews["selected-pressed"]["sha256"] == (
        "47397145620353eabbca33c20be67fefe9fccc84e7f1334ae577d609e6915eb6"
    )
    selection_runtime_path = (
        ROOT / selection_runtime_manifest["runtime"]["file"]
    )
    selection_runtime_bytes = selection_runtime_path.read_bytes()
    assert hashlib.sha256(selection_runtime_bytes).hexdigest() == (
        selection_runtime_manifest["runtime"]["sha256"]
    )
    assert selection_runtime_manifest["runtime"]["sha256"] == (
        "bab9e8bf6961b743d9591bb148878e9eadbbbbd99eac9a183446bf9c81a770b4"
    )
    assert selection_runtime_bytes[2] == 2
    assert struct.unpack("<HH", selection_runtime_bytes[12:16]) == (128, 16)
    assert selection_runtime_bytes[16] == 32
    selection_builder = (
        ROOT / "tools" / "build_quest_log_selection_bookmark_v1.py"
    )
    compile(
        selection_builder.read_text(encoding="utf-8"),
        str(selection_builder),
        "exec",
    )

    directory_source_path = (
        ROOT
        / "assets"
        / "source"
        / "quests"
        / "ql-b1"
        / "QuestLogDirectoryMarks_Master_v1.png"
    )
    directory_manifest_path = directory_source_path.with_name(
        "QL-B1_SourceManifest_v1.json"
    )
    directory_manifest = json.loads(
        directory_manifest_path.read_text(encoding="utf-8")
    )
    directory_source_bytes = directory_source_path.read_bytes()
    assert directory_source_bytes[:8] == b"\x89PNG\r\n\x1a\n"
    assert directory_source_bytes[12:16] == b"IHDR"
    width, height = struct.unpack(">II", directory_source_bytes[16:24])
    assert (width, height, directory_source_bytes[24:26]) == (
        1024,
        1024,
        b"\x08\x06",
    )
    assert directory_manifest["batch"] == "QL-B1"
    assert directory_manifest["version"] == "V1.r3"
    assert directory_manifest["status"] == "accepted-source"
    assert hashlib.sha256(directory_source_bytes).hexdigest() == (
        directory_manifest["source"]["sha256"]
    )
    assert directory_manifest["review"]["runtime_visual_accepted"] is True
    assert directory_manifest["review"]["prior_internal_result"] == (
        "candidate-rejected / repair-budget-exhausted"
    )
    assert directory_manifest["export_contract"]["status"] == (
        "runtime-exported"
    )
    assert directory_manifest["export_contract"]["runtime_atlas_size"] == [
        64,
        16,
    ]
    assert len(directory_manifest["runtime_exports"]) == 1
    assert directory_manifest["runtime_exports"][0]["sha256"] == (
        "e734bbf59da00f7fbc9c75649d33eaf635b5a0c19e1737128dfdce0db58eee8f"
    )

    directory_runtime_manifest_path = directory_source_path.with_name(
        "QL-B1_RuntimeManifest_v1.json"
    )
    directory_runtime_manifest = json.loads(
        directory_runtime_manifest_path.read_text(encoding="utf-8")
    )
    assert directory_runtime_manifest["status"] == "runtime-exported"
    assert directory_runtime_manifest["runtime_contract"] == "1.0"
    assert directory_runtime_manifest["transform"]["atlas_size"] == [64, 16]
    assert directory_runtime_manifest["transform"]["cell_size"] == [16, 16]
    assert directory_runtime_manifest["transform"]["state_order"] == [
        "collapsed",
        "expanded",
        "untracked",
        "tracked",
    ]
    directory_states = directory_runtime_manifest["transform"]["states"]
    assert directory_states["collapsed"]["runtime_display_size"] == [12, 12]
    assert directory_states["expanded"]["texcoord"]["left"] == 0.28125
    assert directory_states["untracked"]["runtime_display_size"] == [10, 10]
    assert directory_states["tracked"]["texcoord"]["left"] == 0.796875
    assert directory_runtime_manifest["layout_contract"] == {
        "row_objects": "QuestLogTitle1..23",
        "row_count": 23,
        "row_box": [224, 15],
        "row_step": 14,
        "total_height": 323,
        "list_safe_area": [64, 64, 246, 324],
        "right_reserved": 22,
        "region_toggle_display_size": [12, 12],
        "list_check_display_size": [10, 10],
    }
    simulation = directory_runtime_manifest["simulation"][
        "real_layout_preview"
    ]
    assert simulation["size"] == [676, 464]
    assert simulation["runtime_scale_percent"] == 100
    assert simulation["row_count"] == 23
    assert simulation["sha256"] == (
        "c0e5bdffc5ce09872c0da0709a3269245ef424f4dde03335d59ded335dc5fdd5"
    )
    directory_runtime_path = (
        ROOT / directory_runtime_manifest["runtime"]["file"]
    )
    directory_runtime_bytes = directory_runtime_path.read_bytes()
    assert hashlib.sha256(directory_runtime_bytes).hexdigest() == (
        directory_runtime_manifest["runtime"]["sha256"]
    )
    assert directory_runtime_manifest["runtime"]["sha256"] == (
        "e734bbf59da00f7fbc9c75649d33eaf635b5a0c19e1737128dfdce0db58eee8f"
    )
    assert directory_runtime_bytes[2] == 2
    assert struct.unpack("<HH", directory_runtime_bytes[12:16]) == (64, 16)
    assert directory_runtime_bytes[16] == 32
    directory_builder = (
        ROOT / "tools" / "build_quest_log_directory_marks_v1.py"
    )
    compile(
        directory_builder.read_text(encoding="utf-8"),
        str(directory_builder),
        "exec",
    )

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
            'Quests.runtimeContract = "1.7"',
            "QuestLogShellV4",
            "QuestLogDirectoryMarksV1",
            "0.66015625",
            "0.90625",
            "DIRECTORY.rowCount",
            "local CONTROL",
            "QuestLogTitleButtonTemplate",
            "FauxScrollFrame_GetOffset",
            "IsQuestWatched",
            "LXGWWenKaiGB-Medium.ttf",
            "NotoSerifSC-SemiBold.ttf",
            "CaptureAndHideNativeTextures",
            "SuppressNativeRowSelection",
            "HideCollapseAllButton",
            "aeuiQuestCollapseSuppressed",
            "StyleLeatherButton",
            "HideDetailScrollbar",
            "InstallDetailMouseWheel",
            "QuestLogDetailScrollFrameScrollBar",
            "EnableMouseWheel(true)",
            "ApplyDetailTextGeometry",
            "QuestLogHighlightFrame",
            "LAYOUT.detail.contentWidth",
            "QuestLogFrameExpandButton",
            "QuestLog_UpdateQuestDetails",
            "CaptureQuestLogBaseGeometry",
            "HasPfQuestQuestLogControls",
            "InstallGlobalPostHook",
            "InstallQuestLogFrameOnShowHook",
            "ApplyPfQuestQuestLogCompatibility",
            "provider.buttonOnline",
            "provider.buttonLanguage",
            "provider.buttonShow",
            "provider.buttonHide",
            "provider.buttonClean",
            "provider.buttonReset",
            "LayoutDirectoryRows(true)",
            "addon:RegisterModule(\"Quests\", Quests)",
        ),
        "quest runtime adapter",
    )
    assert "QuestLogSelectionBookmarkV1" not in quest_adapter
    assert "InstallSelectionHooks" not in quest_adapter
    assert "GetQuestLogSelection" not in quest_adapter
    assert "StyleCollapseAllButton" not in quest_adapter
    assert "EnableMouse(false)" in quest_adapter
    assert "QuestLogFrame:SetWidth(340)" not in quest_adapter
    assert "..." not in quest_adapter, (
        "quest runtime must remain parseable by Turtle WoW's Lua 5.0; "
        "use fixed script arguments instead of vararg forwarding"
    )

    assert not (ROOT / "prompts" / "quests").exists()
    print("quest design contract test passed")


if __name__ == "__main__":
    main()
