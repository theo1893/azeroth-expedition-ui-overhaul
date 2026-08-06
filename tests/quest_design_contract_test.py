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
    rewards_work = (
        QUESTS / "work" / "QUEST.LOG.REWARDS.md"
    ).read_text(encoding="utf-8")
    leftpage_work = (
        QUESTS / "work" / "QUEST.LOG.LEFTPAGE.md"
    ).read_text(encoding="utf-8")
    tracker_work = (
        QUESTS / "work" / "QUEST.TRACKER.CORE.md"
    ).read_text(encoding="utf-8")
    seals_work = (
        QUESTS / "work" / "QUEST.SEALS.md"
    ).read_text(encoding="utf-8")
    reward_sim_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_reward_slots_simulation_v1.json"
    )
    reward_sim_spec = json.loads(
        reward_sim_spec_path.read_text(encoding="utf-8")
    )
    reward_display_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_reward_slots_sim_display_region_v1.json"
    )
    reward_display_spec = json.loads(
        reward_display_spec_path.read_text(encoding="utf-8")
    )
    reward_sim_renderer_path = (
        ROOT / "tools" / "render_quest_log_reward_slots_simulation_v1.py"
    )
    reward_sim_renderer = reward_sim_renderer_path.read_text(encoding="utf-8")
    seal_actions_sim_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_actions_simulation_v1.json"
    )
    seal_actions_sim_spec = json.loads(
        seal_actions_sim_spec_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v2_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_actions_simulation_v2.json"
    )
    seal_actions_sim_v2_spec = json.loads(
        seal_actions_sim_v2_spec_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v3_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_actions_simulation_v3.json"
    )
    seal_actions_sim_v3_spec = json.loads(
        seal_actions_sim_v3_spec_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v4_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_actions_simulation_v4.json"
    )
    seal_actions_sim_v4_spec = json.loads(
        seal_actions_sim_v4_spec_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v5_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_actions_simulation_v5.json"
    )
    seal_actions_sim_v5_spec = json.loads(
        seal_actions_sim_v5_spec_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v6_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_actions_simulation_v6.json"
    )
    seal_actions_sim_v6_spec = json.loads(
        seal_actions_sim_v6_spec_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v7_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_actions_simulation_v7.json"
    )
    seal_actions_sim_v7_spec = json.loads(
        seal_actions_sim_v7_spec_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v8_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_actions_simulation_v8.json"
    )
    seal_actions_sim_v8_spec = json.loads(
        seal_actions_sim_v8_spec_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v9_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_actions_simulation_v9.json"
    )
    seal_actions_sim_v9_spec = json.loads(
        seal_actions_sim_v9_spec_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v10_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_actions_simulation_v10.json"
    )
    seal_actions_sim_v10_spec = json.loads(
        seal_actions_sim_v10_spec_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v11_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_actions_simulation_v11.json"
    )
    seal_actions_sim_v11_spec = json.loads(
        seal_actions_sim_v11_spec_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v11_display_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_actions_simulation_v11_display_region.json"
    )
    seal_actions_sim_v11_display = json.loads(
        seal_actions_sim_v11_display_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v11_renderer_path = (
        ROOT / "tools" / "render_quest_log_seal_ribbon_simulation_v1.py"
    )
    assert seal_actions_sim_v11_renderer_path.is_file(), (
        seal_actions_sim_v11_renderer_path
    )
    seal_actions_sim_v11_renderer = (
        seal_actions_sim_v11_renderer_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v12_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_layered_actions_simulation_v12.json"
    )
    seal_actions_sim_v12_spec = json.loads(
        seal_actions_sim_v12_spec_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v12_display_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_actions_simulation_v12_display_region.json"
    )
    seal_actions_sim_v12_display = json.loads(
        seal_actions_sim_v12_display_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_v12_renderer_path = (
        ROOT / "tools" / "render_quest_log_seal_layered_actions_simulation_v1.py"
    )
    assert seal_actions_sim_v12_renderer_path.is_file(), (
        seal_actions_sim_v12_renderer_path
    )
    seal_actions_sim_v12_renderer = (
        seal_actions_sim_v12_renderer_path.read_text(encoding="utf-8")
    )
    seal_substrate_sim_v13_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_substrate_simulation_v13.json"
    )
    seal_substrate_sim_v13_spec = json.loads(
        seal_substrate_sim_v13_spec_path.read_text(encoding="utf-8")
    )
    seal_substrate_sim_v13_display_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_actions_simulation_v13_display_region.json"
    )
    seal_substrate_sim_v13_display = json.loads(
        seal_substrate_sim_v13_display_path.read_text(encoding="utf-8")
    )
    seal_substrate_sim_v13_renderer_path = (
        ROOT / "tools" / "render_quest_log_seal_layered_actions_simulation_v2.py"
    )
    assert seal_substrate_sim_v13_renderer_path.is_file(), (
        seal_substrate_sim_v13_renderer_path
    )
    seal_substrate_sim_v13_renderer = (
        seal_substrate_sim_v13_renderer_path.read_text(encoding="utf-8")
    )
    seal_substrate_sim_v14_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_substrate_simulation_v14.json"
    )
    seal_substrate_sim_v14_spec = json.loads(
        seal_substrate_sim_v14_spec_path.read_text(encoding="utf-8")
    )
    seal_motifs_sim_v15_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_motifs_simulation_v15.json"
    )
    seal_motifs_sim_v15_spec = json.loads(
        seal_motifs_sim_v15_spec_path.read_text(encoding="utf-8")
    )
    seal_motifs_sim_v16_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_log_seal_independent_motifs_simulation_v16.json"
    )
    seal_motifs_sim_v16_spec = json.loads(
        seal_motifs_sim_v16_spec_path.read_text(encoding="utf-8")
    )
    seal_substrate_v5_candidate_reviewer_path = (
        ROOT
        / "tools"
        / "review_quest_seal_menu_substrate_donor_candidate_v1.py"
    )
    assert seal_substrate_v5_candidate_reviewer_path.is_file(), (
        seal_substrate_v5_candidate_reviewer_path
    )
    seal_substrate_v5_candidate_reviewer = (
        seal_substrate_v5_candidate_reviewer_path.read_text(encoding="utf-8")
    )
    seal_motifs_v5_candidate_reviewer_path = (
        ROOT
        / "tools"
        / "review_quest_seal_menu_motifs_candidate_v1.py"
    )
    assert seal_motifs_v5_candidate_reviewer_path.is_file(), (
        seal_motifs_v5_candidate_reviewer_path
    )
    seal_motifs_v5_candidate_reviewer = (
        seal_motifs_v5_candidate_reviewer_path.read_text(encoding="utf-8")
    )
    seal_motifs_v6_candidate_reviewer_path = (
        ROOT
        / "tools"
        / "review_quest_seal_menu_independent_motif_candidate_v1.py"
    )
    assert seal_motifs_v6_candidate_reviewer_path.is_file(), (
        seal_motifs_v6_candidate_reviewer_path
    )
    seal_motifs_v6_candidate_reviewer = (
        seal_motifs_v6_candidate_reviewer_path.read_text(encoding="utf-8")
    )
    seal_actions_sim_renderer = (
        ROOT / "tools" / "render_quest_log_seal_actions_simulation_v1.py"
    )
    action_tab_reviewer_path = (
        ROOT / "tools" / "review_quest_log_action_tab_candidate_v1.py"
    )
    assert action_tab_reviewer_path.is_file(), action_tab_reviewer_path
    action_tab_reviewer = action_tab_reviewer_path.read_text(encoding="utf-8")
    require(
        action_tab_reviewer,
        (
            "edge_connected_chroma_key",
            "clear_edge_connected_green",
            "TARGET_SIZE = (784, 140)",
            "RUNTIME_SIZE = (112, 20)",
            "ATLAS_SIZE = (1024, 32)",
            "runtime_visible_bbox",
            "layout_geometry_25_of_25",
            "right-clamp.png",
            "quest_log_seal_actions_simulation_v9.json",
        ),
        "QS-B1 deterministic candidate reviewer",
    )
    tracker_sim_spec_path = (
        ROOT / "tools" / "specs" / "quest_tracker_simulation_v2.json"
    )
    tracker_sim_spec = json.loads(
        tracker_sim_spec_path.read_text(encoding="utf-8")
    )
    tracker_display_spec_path = (
        ROOT / "tools" / "specs" / "quest_tracker_display_region_v1.json"
    )
    tracker_display_spec = json.loads(
        tracker_display_spec_path.read_text(encoding="utf-8")
    )
    tracker_external_caps_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_tracker_external_caps_simulation_v1.json"
    )
    tracker_external_caps_spec = json.loads(
        tracker_external_caps_spec_path.read_text(encoding="utf-8")
    )
    tracker_direct_paper_spec_path = (
        ROOT
        / "tools"
        / "specs"
        / "quest_tracker_direct_paper_simulation_v1.json"
    )
    tracker_direct_paper_spec = json.loads(
        tracker_direct_paper_spec_path.read_text(encoding="utf-8")
    )
    tracker_external_caps_renderer_path = (
        ROOT / "tools" / "render_quest_tracker_external_caps_simulation_v1.py"
    )
    assert tracker_external_caps_renderer_path.is_file(), (
        tracker_external_caps_renderer_path
    )
    tracker_external_caps_renderer = (
        tracker_external_caps_renderer_path.read_text(encoding="utf-8")
    )
    require(
        tracker_external_caps_renderer,
        (
            "external-cap geometry proposal",
            "draw_external_shell",
            "draw_toolbar",
            "draw_entries",
            "audit_scenario",
            "provider-height-formula",
            "cap.{name}.outside-live",
            "aeui-quest-tracker-external-caps-simulation-report-v1",
            "aeui-quest-tracker-direct-paper-simulation-report-v1",
            "visual-shell-equals-live",
            "exterior book-frame",
        ),
        "pfQuest tracker external-cap simulation renderer",
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
            "provider_frame_height",
            "PROVIDER_PANEL_HEIGHT = 16",
            "PROVIDER_ENTRY_HEIGHT = math.ceil",
            "real-layout-{label}-{width}x{height}.png",
            "superseded_fixed_capacity_previews",
            "tracker_",
            "NotoSansSC-Medium.ttf",
            "B1_ATLAS_SIZE = (1024, 768)",
            '--paper-only',
            '--runtime-paper',
            "runtime_nine_slice",
            "QT-B1 user-paused",
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
            "runtime 全部隐藏且不创建替代命中",
            "`QUEST.LOG.SELECTION`",
            "暂停挂载并隐藏",
            "adapter 不再创建、挂载或刷新酒红色书签",
            "目录文字继续从 `x>=18` 起",
            "`QUEST.LOG.TYPE.BADGE`",
            "`QUEST.LOG.TIMER.BADGE`",
            "`GetQuestTimers()`",
            "`GetQuestIndexForTimer()`",
            "`QUEST.LOG.STATE.SEAL`",
            "`QUESTS_DISPLAYED = 18`",
            "`246 × 18 UI px`",
            "安全宽度 `226px`",
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
            "`QUEST.LOG.ACTION.SEAL_MENU`",
            "`QUEST.LOG.ACTION.SEAL_MENU.SUBSTRATE.MAX`",
            "`QUEST.LOG.ACTION.SEAL_MENU.SUBSTRATE.ROOT`",
            "`QUEST.LOG.ACTION.SEAL_MENU.SUBSTRATE.BODY`",
            "`QUEST.LOG.ACTION.SEAL_MENU.SUBSTRATE.TAIL`",
            "`QUEST.LOG.ACTION.SEAL_MENU.MOTIF.SHARE`",
            "`QUEST.LOG.ACTION.SEAL_MENU.MOTIF.DETAIL`",
            "`QUEST.LOG.ACTION.SEAL_MENU.MOTIF.SHOW`",
            "`QUEST.LOG.ACTION.SEAL_MENU.MOTIF.HIDE`",
            "`QUEST.LOG.ACTION.SEAL_MENU.MOTIF.CLEAN`",
            "`QUEST.LOG.ACTION.SEAL_MENU.MOTIF.RESET`",
            "`QUEST.LOG.ACTION.SEAL_MENU.MOTIF.ABANDON`",
            "`QUEST.LOG.ACTION.SEAL_MENU.BUTTON.SHARE`",
            "`QUEST.LOG.ACTION.SEAL_MENU.BUTTON.DETAIL`",
            "`QUEST.LOG.ACTION.SEAL_MENU.BUTTON.SHOW`",
            "`QUEST.LOG.ACTION.SEAL_MENU.BUTTON.HIDE`",
            "`QUEST.LOG.ACTION.SEAL_MENU.BUTTON.CLEAN`",
            "`QUEST.LOG.ACTION.SEAL_MENU.BUTTON.RESET`",
            "`QUEST.LOG.ACTION.SEAL_MENU.BUTTON.ABANDON`",
            "`QUEST.LOG.ACTION.SEAL_MENU.PAGE_EDGE_MASK`",
            "不含纹章、文字或状态",
            "不得出现 variant 循环",
            "当前程序化暗皮革 fallback",
            "`108×41px` 双列锚点",
            "名称安全宽 `64px`",
            "UpdateScrollChildRect()",
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
            "用户于 `2026-08-05` 明确判定“不可接受”",
            "不得成为 V2 edit input",
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
            "`scope-deferred / user-paused 1/5`",
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
            "`game-validated / P6 / user-confirmed`",
            "`2026-08-05`",
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
            "`246 × 18px`",
            "A 终止于 `4/5`",
            "`user-rejected /",
            "scope-removed / P3`",
            "B `5/5`",
            "`game-validated / P6`",
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
            "`P5 asset-retained / runtime-hidden`",
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
            "`P3 scope-deferred / user-paused / 1/5`",
            "`scope-deferred 0/5`",
            "`display-region-blocked`",
            "`104/256/420/516/136px`",
            "`FRAME_BELOW_NINE_SLICE_MINIMUM`",
            "`QT-GEO V1`",
            "`QT-GEO V2`",
            "`simulation-rendered / awaiting-user-confirmation`",
            "ImageGen `0/0`",
            "外置装饰端帽",
            "四边 outsets 全为 `0px`",
            "`visual-shell-equals-live`",
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
            "`runtime-exported-temporary / display-region-blocked`",
            "`pfQuest 7.0.1`",
            "`pfQuest-turtle 7.0.2`",
            "`imagegen-0-143-0`",
            "`@openai/codex@0.143.0`",
            "QT-A1 `5/5`",
            "QT-A2 `0/5`",
            "QT-B1 `1/5`",
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
            "`scope-deferred / user-paused`",
            "直接使用大块的背景 tracker",
            "旧 V1.r1",
            "Prompt 完整性预检",
            "`pass / production / 已授权`",
            "未知但执行必需的值：无",
            "Repair envelope 与计数",
            "历史合计为 `6/10`",
            "真实排版预演",
            "`130 × 180`",
            "`230 × 500`",
            "`330 × 865`",
            "`scope-deferred / non-authoritative`",
            "本地渲染错误：`0`",
            "本授权不包含 source 晋级",
            "QT-A1 V1.r1 — 完整修复正文",
            "QT-A1 V1.r2 — 完整修复正文",
            "QT-A1 V1.r3 — 完整修复正文",
            "QT-A1 V1.r4 — 完整修复正文",
            "QuestTrackerPaperShell_Temporary_v1.png",
            "QuestTrackerPaperV1.tga",
            "`runtime-exported-temporary / P5`",
            "build_quest_tracker_paper_v1.py",
            "contract `1.8`",
            "`--paper-only`",
            "aad8a8fb800e0932ddd9cf7e2430ba49bf29a0039bf713bdd1fd5c350758a5ea",
            "019fb62d-a545-70f3-9ea1-10f1017bb806",
            "019fb638-0608-7be3-b76c-889f2760d373",
            "019fb63d-2013-70d0-b8b8-465afbc1c61c",
            "019fb641-556a-77b0-bd27-e05a629a9fea",
            "019fb645-e305-7153-bb3e-86742d276bef",
            "019fb64e-9e36-7b93-8dbc-b572a13d5373",
            "f22dc61ea2762ca3ce54fa73436737c8ce19926c4e753149f5d42aa3cfdbbaea",
            "e4b6a258ffe4bbf82d4bd6386bf4323df4da983bbe04b8cd218071c94fb1429b",
            "7f671feb1e66ebee89189813904c16586f32912999739ce213b5ddab955ebd51",
            "13aefd716b129fd2f6b629147b77c0033b8c9db6e3f3c1d71c2a96d7dd347474",
            "319e084802a44161663e39b7243abd178ef64115d46b8922957b21c57eb38415",
            "ff6bf0af0642715894b6dcc7344fb3dd966b947ff6b56e3426197697af6c4bae",
            "f6da60fd48f6a6dee8d37bfc6105880a5421dc97d08e44ce97144e2a15bd6fa7",
            "tools/review_quest_tracker_candidate_v1.py",
            "tools/specs/quest_tracker_display_region_v1.json",
            "`fail / 35 violations`",
            "`FRAME_BELOW_NINE_SLICE_MINIMUM`",
            "外置装饰端帽精确几何预演 — QT-GEO V1",
            "first-scheme-selected",
            "`simulation-rendered / awaiting-user-confirmation`",
            "quest_tracker_external_caps_simulation_v1.json",
            "73a3845aa1c73eba86e4323b5505e0a7c45874aa15958371aa1632f5a0d5babf",
            "render_quest_tracker_external_caps_simulation_v1.py",
            "771252b38f6652c8301bc590018e609958b1fb0cabbcaebfe066c48fdcd27b5a",
            "quest_tracker_external_caps_ingame_v1.png",
            "ea4d2041090bbfc34087ce01eee410d6bf73c46f6daad6215e4e590cb3388983",
            "quest_tracker_external_caps_scenarios_v1.png",
            "0909bc056bc3a07ee7ad74dc52d3c73b2589afff68f5ff178b24e310fdc81bb4",
            "quest_tracker_external_caps_report_v1.json",
            "fde561fcfad1d5a85267cf62f6c3489fe159f2bac2dca7d6e5fc5cedf81110c1",
            "`228 × 44`",
            "`358 × 448`",
            "直接使用 live tracker 纸面预演 — QT-GEO V2",
            "no-exterior-book-frame",
            "quest_tracker_direct_paper_simulation_v1.json",
            "906ea23c2d77c88208ca546feaa4522d1b742978f113f56265beef63c03e475d",
            "e0466cae14513f01866ea768e6858d1886a706d6b24f81f3539292966b55b7a2",
            "quest_tracker_direct_paper_ingame_v1.png",
            "1e865eeb5f679f3b83d49eab7b370ae96d1d4f692d4679d8f590eb35b44e6255",
            "quest_tracker_direct_paper_scenarios_v1.png",
            "f598bf8bc89a336b74bd475782de85896d0c284fe804e0cc8b81b16192fc4ca9",
            "quest_tracker_direct_paper_report_v1.json",
            "cc90edd7c58e07a0a31fcdd37b6dc8ac23aac3d1df3cfd6ae873ae92f2cb0747",
            "`pass / 7 of 7`",
            "`awaiting`",
            "`130 × 104`",
            "`230 × 256`",
            "`330 × 420`",
            "`330 × 516`",
            "`230 × 136`",
            "`internal-rejected / repair-prepared / P3`",
            "`candidate-rejected / repair-budget-exhausted / P3`",
        ),
        "pfQuest tracker production final",
    )

    require(
        seals_work,
        (
            "Quest Log／Tracker 共用漆章",
            "`QS-A1 V1.r4`",
            "`candidate-rejected / user-rejected / repair-budget-exhausted / P3 / 5/5`",
            "QuestToolWaxSeal_Master_v1.png",
            "QS-A1_SourceManifest_v1.json",
            "QS-A1_RuntimeManifest_v1.json",
            "QuestToolWaxSealStatesV1.tga",
            "377dcdc141ee5487884bfc99dbfd82013a8c4d7cb7200a4414feebb81d72ab75",
            "f113e670f1b61be1a50e3cfa16dfce95a2b0d159fc35d986a9b2e1d314a72902",
            "`256 × 64`",
            "normal／hover／pressed／disabled",
            "透明 RGB 清零",
            "SetClampRectInsets",
            "旧七个 provider Button",
            "`5/5`",
            "QS-B1 V3 ImageGen：V3-A `5/5`、V3-B `0/5`",
            "QS-B1 历史流程错误：V1 `1`、V2 `3`、V3 `0`、V4-A `1`",
            "QUEST-LOG-SEAL-SUBSTRATE-SIM-V13",
            "不得进入 `P6`",
        ),
        "accepted QS-A1 work",
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
    assert tracker_display_spec["schema"] == (
        "aeui-display-region-contract-v1"
    )
    assert tracker_display_spec["component"] == "QUEST.TRACKER.SHELL"
    assert tracker_display_spec["atlas"]["visible_bbox"] == [0, 0, 190, 512]
    assert tracker_display_spec["nine_slice"]["caps"] == {
        "left": 14,
        "right": 14,
        "top": 12,
        "bottom": 16,
    }
    assert tracker_display_spec["nine_slice"]["minimum_frame_size"] == [29, 29]
    provider_layout = tracker_display_spec["provider_layout"]
    assert provider_layout["unresolved_bounds"] == [
        (
            "trackerfontsize is free numeric text in pfQuest config and has no "
            "provider min/max"
        ),
        (
            "objective count per quest is data-dependent and has no bound in "
            "tracker.lua"
        ),
    ]
    scenario_frames = {
        scenario["id"]: scenario["frame"]
        for scenario in tracker_display_spec["scenarios"]
    }
    assert scenario_frames == {
        "empty-provider": [200, 16],
        "quest-short-default-font": [130, 104],
        "quest-typical-default-font": [230, 256],
        "quest-dense-default-font": [330, 420],
        "quest-maximum-entry-count-default-font": [330, 516],
        "database-six-entries-default-font": [230, 136],
        "giver-six-entries-default-font": [230, 136],
    }
    for scenario in tracker_display_spec["scenarios"]:
        expected_height = (
            provider_layout["panel_height"]
            + scenario["entry_count"] * provider_layout["entry_height"]
            + scenario["objective_count"] * provider_layout["objective_step"]
        )
        assert scenario["frame"][1] == expected_height
        assert scenario["preview_frame"] == scenario["frame"]
    assert tracker_external_caps_spec["schema"] == (
        "aeui-quest-tracker-external-caps-simulation-v1"
    )
    assert tracker_external_caps_spec["version"] == "QT-GEO-V1"
    assert tracker_external_caps_spec["imagegen"] == {
        "calls": 0,
        "budget": 0,
        "uploads": [],
    }
    assert tracker_external_caps_spec["proposal"]["id"] == (
        "external-decorative-caps"
    )
    assert tracker_external_caps_spec["proposal"]["visual_outsets"] == {
        "left": 14,
        "right": 14,
        "top": 12,
        "bottom": 16,
    }
    assert tracker_external_caps_spec["proposal"]["mouse"] == "disabled"
    assert (
        tracker_external_caps_spec["proposal"]["live_center"]
        == "exactly the provider root rectangle [0,0,width,height]"
    )
    external_frames = {
        scenario["id"]: scenario["frame"]
        for scenario in tracker_external_caps_spec["scenarios"]
    }
    assert external_frames == scenario_frames
    external_provider = tracker_external_caps_spec["provider"]
    for scenario in tracker_external_caps_spec["scenarios"]:
        expected_external_height = (
            external_provider["panel_height"]
            + scenario["entry_count"] * external_provider["entry_height"]
            + sum(scenario["objective_distribution"])
            * external_provider["objective_step"]
        )
        assert scenario["frame"][1] == expected_external_height
        assert len(scenario["objective_distribution"]) == (
            scenario["entry_count"]
        )
    assert tracker_external_caps_spec["ingame_scene"] == {
        "canvas": [1536, 1024],
        "scenario": "quest-dense-default-font",
        "provider_origin": [1166, 92],
        "ui_scale": 1.0,
    }
    assert tracker_external_caps_spec["scenario_board"] == {
        "canvas": [1800, 1240],
        "ui_scale": 1.0,
    }
    assert tracker_external_caps_spec["outputs"] == {
        "directory": "generated/quests/QT/simulation/QT-GEO-V1",
        "ingame": "quest_tracker_external_caps_ingame_v1.png",
        "scenarios": "quest_tracker_external_caps_scenarios_v1.png",
        "report": "quest_tracker_external_caps_report_v1.json",
    }
    assert tracker_direct_paper_spec["schema"] == (
        "aeui-quest-tracker-direct-paper-simulation-v1"
    )
    assert tracker_direct_paper_spec["base_specification"] == (
        "tools/specs/quest_tracker_external_caps_simulation_v1.json"
    )
    assert tracker_direct_paper_spec["version"] == "QT-GEO-V2"
    assert tracker_direct_paper_spec["imagegen"] == {
        "calls": 0,
        "budget": 0,
        "uploads": [],
    }
    assert tracker_direct_paper_spec["proposal"] == {
        "id": "direct-live-paper",
        "visual_outsets": {
            "left": 0,
            "right": 0,
            "top": 0,
            "bottom": 0,
        },
        "live_center": (
            "exactly the provider root rectangle [0,0,width,height]"
        ),
        "boundary_rule": (
            "no exterior book frame, decorative caps, layered page edges, "
            "outline, or cast shadow"
        ),
        "layer": (
            "one adapter-owned non-interactive quiet paper field exactly "
            "matching the provider root"
        ),
        "mouse": "disabled",
        "screen_edge_note": (
            "no visual pixels exist outside the provider root, so saved "
            "screen-edge positions introduce no decorative clipping"
        ),
    }
    assert tracker_direct_paper_spec["ingame_scene"] == {
        "canvas": [1536, 1024],
        "scenario": "quest-dense-default-font",
        "provider_origin": [1166, 92],
        "ui_scale": 1.0,
    }
    assert tracker_direct_paper_spec["scenario_board"] == {
        "canvas": [1800, 1240],
        "ui_scale": 1.0,
    }
    assert tracker_direct_paper_spec["outputs"] == {
        "directory": "generated/quests/QT/simulation/QT-GEO-V2",
        "ingame": "quest_tracker_direct_paper_ingame_v1.png",
        "scenarios": "quest_tracker_direct_paper_scenarios_v1.png",
        "report": "quest_tracker_direct_paper_report_v1.json",
    }
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
            "子状态：`game-validated / user-confirmed`",
            "项目阶段：`P6`",
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
            "`game-validated / P6 / user-confirmed`",
            "`2026-08-05`",
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
            "子状态：`game-validated / user-confirmed`",
            "项目阶段：`P6`（当前活动 runtime 范围）",
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
            "game-validated / P6",
            "`2026-08-05`",
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

    require(
        rewards_work,
        (
            "QL-D Quest Log 奖励槽 V1",
            "`simulation-proposed / awaiting-user-confirmation`",
            "当前几何／fallback `P6 game-validated`；最终美术 `P2`",
            "`2026-08-05`",
            "当前实际 ImageGen 调用：`0/0`",
            "`QUEST.LOG.REWARD.SLOT`",
            "`108 × 41 UI px`",
            "名称安全宽 `64px`",
            "两列间隔",
            "同行间隔",
            "runtime `1.25`",
            "Quest Visual Theme `1.8`",
            "quest_log_reward_slots_simulation_v1.json",
            "render_quest_log_reward_slots_simulation_v1.py",
            "72be6792c80aab4485013205bc57314d2633c93baab0ba5960104f13925a6f1a",
            "430bf6e76d75a6dad928004b22636905a52ee8bdccf4af5a862d895d3957e235",
            "quest_log_reward_slots_sim_display_region_v1.json",
            "0／1／2／4／6",
            "violations `0`",
            "确认不等于生成授权",
        ),
        "active QL-D reward-slot work",
    )
    assert "/Users/" not in rewards_work
    assert reward_sim_spec["schema"] == (
        "aeui.quest-log.reward-slots.simulation.v1"
    )
    assert reward_sim_spec["state"] == (
        "simulation-proposed / awaiting-user-confirmation"
    )
    assert reward_sim_spec["layout"]["detail_content"] == [376, 72, 224, 306]
    assert reward_sim_spec["layout"]["reward_slot_size"] == [108, 41]
    assert reward_sim_spec["layout"]["reward_name_safe_width"] == 64
    assert reward_sim_spec["layout"]["reward_column_gap"] == 8
    assert reward_sim_spec["layout"]["reward_row_gap"] == 4
    assert reward_sim_spec["constraints"]["imagegen_calls"] == 0
    assert reward_sim_spec["constraints"]["new_runtime_bitmap_assets"] == 0
    assert reward_sim_spec["constraints"]["counts_covered_by_display_contract"] == [
        0,
        1,
        2,
        4,
        6,
    ]
    assert len(reward_sim_spec["content"]["items"]) == 6
    assert reward_display_spec["schema"] == "aeui-display-region-contract-v1"
    assert reward_display_spec["atlas"]["size"] == [432, 41]
    assert [scenario["id"] for scenario in reward_display_spec["scenarios"]] == [
        "zero-rewards",
        "one-reward",
        "two-rewards",
        "four-rewards",
        "six-rewards",
    ]
    require(
        reward_sim_renderer,
        (
            "draw_reward_slot",
            "reward_boxes",
            "validate_geometry",
            "reward column gap mismatch",
            "reward row gap mismatch",
            "imagegen_calls",
            "user-visible-direction-confirmation",
        ),
        "QL-D deterministic simulation renderer",
    )
    compile(
        reward_sim_renderer,
        str(reward_sim_renderer_path),
        "exec",
    )

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

    tracker_source_path = (
        ROOT
        / "assets"
        / "source"
        / "quests"
        / "qt-a1"
        / "QuestTrackerPaperShell_Temporary_v1.png"
    )
    tracker_source_manifest = json.loads(
        tracker_source_path.with_name(
            "QT-A1_SourceManifest_v1.json"
        ).read_text(encoding="utf-8")
    )
    tracker_runtime_manifest = json.loads(
        tracker_source_path.with_name(
            "QT-A1_RuntimeManifest_v1.json"
        ).read_text(encoding="utf-8")
    )
    assert tracker_source_manifest["status"] == (
        "user-accepted-temporary-contract-exception"
    )
    assert tracker_source_manifest["source"]["sha256"] == (
        "a9d700cd01f26535ae2035bfa3d8c2cedd7337bfb47d3fa9494ba592d259c59b"
    )
    assert hashlib.sha256(tracker_source_path.read_bytes()).hexdigest() == (
        tracker_source_manifest["source"]["sha256"]
    )
    assert tracker_runtime_manifest["status"] == (
        "runtime-exported-temporary"
    )
    assert tracker_runtime_manifest["runtime_contract"] == "1.0"
    assert tracker_runtime_manifest["transform"]["atlas_size"] == [256, 512]
    assert tracker_runtime_manifest["nine_slice"]["display_caps"] == {
        "left": 14,
        "right": 14,
        "top": 12,
        "bottom": 16,
    }
    assert tracker_runtime_manifest["frame_contract"][
        "row_overlays"
    ] == "none; QT-B1 is scope-deferred"
    display_region_conformance = tracker_runtime_manifest["frame_contract"][
        "display_region_conformance"
    ]
    assert display_region_conformance["status"] == "display-region-blocked"
    assert display_region_conformance["contract"] == (
        "tools/specs/quest_tracker_display_region_v1.json"
    )
    assert display_region_conformance["first_failure"] == (
        "FRAME_BELOW_NINE_SLICE_MINIMUM"
    )
    assert tracker_runtime_manifest["implementation"]["imagegen_calls"] == 0
    assert tracker_runtime_manifest["implementation"]["game_validated"] is False
    tracker_runtime_path = ROOT / tracker_runtime_manifest["runtime"]["file"]
    tracker_runtime_bytes = tracker_runtime_path.read_bytes()
    assert hashlib.sha256(tracker_runtime_bytes).hexdigest() == (
        tracker_runtime_manifest["runtime"]["sha256"]
    )
    assert tracker_runtime_manifest["runtime"]["sha256"] == (
        "c6b1f64034fa69f01709403e592c3350445c9a6739f4b559242be48831666c61"
    )
    assert tracker_runtime_bytes[2] == 2
    assert struct.unpack("<HH", tracker_runtime_bytes[12:16]) == (256, 512)
    assert tracker_runtime_bytes[16] == 32
    assert (
        ROOT / "tools" / "build_quest_tracker_paper_v1.py"
    ).is_file()

    seal_source_path = (
        ROOT
        / "assets"
        / "source"
        / "quests"
        / "qs-a1"
        / "QuestToolWaxSeal_Master_v1.png"
    )
    seal_source_manifest = json.loads(
        seal_source_path.with_name(
            "QS-A1_SourceManifest_v1.json"
        ).read_text(encoding="utf-8")
    )
    seal_runtime_manifest = json.loads(
        seal_source_path.with_name(
            "QS-A1_RuntimeManifest_v1.json"
        ).read_text(encoding="utf-8")
    )
    seal_source_bytes = seal_source_path.read_bytes()
    assert seal_source_bytes[:8] == b"\x89PNG\r\n\x1a\n"
    assert struct.unpack(">II", seal_source_bytes[16:24]) == (1024, 1024)
    assert hashlib.sha256(seal_source_bytes).hexdigest() == (
        "377dcdc141ee5487884bfc99dbfd82013a8c4d7cb7200a4414feebb81d72ab75"
    )
    assert seal_source_manifest["version"] == "V1.r4"
    assert seal_source_manifest["status"] == "accepted-source"
    assert seal_source_manifest["source"]["visible_bbox_exclusive"] == [
        192,
        200,
        832,
        824,
    ]
    assert seal_source_manifest["source"]["visible_green_spill_pixels"] == 0
    assert seal_source_manifest["source"]["transparent_rgb_nonzero_values"] == 0
    assert seal_source_manifest["review"]["runtime_visual_accepted"] is True
    assert seal_source_manifest["export_contract"]["runtime_atlas_size"] == [
        256,
        64,
    ]
    assert seal_runtime_manifest["status"] == "runtime-exported"
    assert seal_runtime_manifest["transform"]["state_order"] == [
        "normal",
        "hover",
        "pressed",
        "disabled",
    ]
    seal_states = seal_runtime_manifest["transform"]["states"]
    assert len({state["alpha_sha256"] for state in seal_states.values()}) == 1
    assert all(
        state["runtime_visible_size"] == [60, 58]
        for state in seal_states.values()
    )
    assert seal_runtime_manifest["display_region"]["status"] == "pass"
    assert seal_runtime_manifest["runtime_contract"] == "1.1"
    assert seal_runtime_manifest["layout_contract"]["quest_log"][
        "box_xywh"
    ] == [576, 68, 32, 32]
    assert seal_runtime_manifest["layout_contract"]["quest_log"][
        "reserved_corner_xywh"
    ] == [572, 64, 40, 40]
    assert seal_runtime_manifest["layout_contract"]["tracker"][
        "top_clamp_inset"
    ] == 18
    seal_runtime_path = ROOT / seal_runtime_manifest["runtime"]["file"]
    seal_runtime_bytes = seal_runtime_path.read_bytes()
    assert hashlib.sha256(seal_runtime_bytes).hexdigest() == (
        "f113e670f1b61be1a50e3cfa16dfce95a2b0d159fc35d986a9b2e1d314a72902"
    )
    assert seal_runtime_bytes[2] == 2
    assert struct.unpack("<HH", seal_runtime_bytes[12:16]) == (256, 64)
    assert seal_runtime_bytes[16] == 32
    seal_builder = ROOT / "tools" / "build_quest_tool_wax_seal_v1.py"
    compile(
        seal_builder.read_text(encoding="utf-8"),
        str(seal_builder),
        "exec",
    )
    compile(
        seal_actions_sim_renderer.read_text(encoding="utf-8"),
        str(seal_actions_sim_renderer),
        "exec",
    )
    assert seal_actions_sim_spec["version"] == (
        "QUEST-LOG-SEAL-ACTIONS-SIM-V1"
    )
    assert seal_actions_sim_spec["frame"] == [676, 464]
    assert seal_actions_sim_spec["layout"]["list"] == [64, 64, 246, 324]
    assert seal_actions_sim_spec["layout"]["detail"] == [366, 64, 246, 324]
    assert seal_actions_sim_spec["layout"]["seal_visual"] == [
        665,
        194,
        32,
        32,
    ]
    assert seal_actions_sim_spec["layout"]["seal_hitbox"] == [
        659,
        190,
        40,
        40,
    ]
    assert len(seal_actions_sim_spec["content"]["menu_actions"]) == 7
    assert seal_actions_sim_spec["constraints"]["imagegen_calls"] == 0
    assert seal_actions_sim_spec["interaction"]["fail_open"] == (
        "keep-original-buttons-visible-until-all-proxies-exist"
    )
    assert seal_actions_sim_v2_spec["version"] == (
        "QUEST-LOG-SEAL-ACTIONS-SIM-V2"
    )
    assert seal_actions_sim_v2_spec["support_type"] == (
        "parchment-seal-tag"
    )
    assert seal_actions_sim_v2_spec["frame"] == [676, 464]
    assert seal_actions_sim_v2_spec["layout"]["page_exit"] == [
        603,
        190,
        34,
        38,
    ]
    assert seal_actions_sim_v2_spec["layout"]["document_tag"] == [
        614,
        197,
        80,
        27,
    ]
    assert seal_actions_sim_v2_spec["layout"]["tag_head"] == [
        672,
        189,
        44,
        44,
    ]
    assert seal_actions_sim_v2_spec["layout"]["seal_visual"] == [
        678,
        195,
        32,
        32,
    ]
    assert len(seal_actions_sim_v2_spec["content"]["menu_actions"]) == 7
    assert seal_actions_sim_v2_spec["constraints"]["imagegen_calls"] == 0
    assert seal_actions_sim_v2_spec["constraints"][
        "tag_root_must_be_occluded_by_page_lip"
    ]
    assert seal_actions_sim_v2_spec["interaction"]["fail_open"] == (
        "keep-original-buttons-visible-until-all-proxies-exist"
    )
    assert seal_actions_sim_v3_spec["version"] == (
        "QUEST-LOG-SEAL-ACTIONS-SIM-V3"
    )
    assert seal_actions_sim_v3_spec["support_type"] == (
        "page-layered-parchment-seal-tag"
    )
    assert seal_actions_sim_v3_spec["frame"] == [676, 464]
    assert seal_actions_sim_v3_spec["layout"][
        "page_lip_source_box"
    ] == [598, 176, 39, 54]
    assert seal_actions_sim_v3_spec["layout"]["tag_root_box"] == [
        608,
        184,
        27,
        27,
    ]
    assert seal_actions_sim_v3_spec["layout"][
        "document_tag_bbox"
    ] == [608, 184, 112, 50]
    assert seal_actions_sim_v3_spec["layout"][
        "menu_connection_box"
    ] == [650, 184, 42, 48]
    assert seal_actions_sim_v3_spec["layout"]["seal_visual"] == [
        684,
        196,
        32,
        32,
    ]
    assert len(seal_actions_sim_v3_spec["content"]["menu_actions"]) == 7
    assert seal_actions_sim_v3_spec["constraints"]["imagegen_calls"] == 0
    assert seal_actions_sim_v3_spec["constraints"][
        "page_lip_reuses_shell_pixels"
    ]
    assert seal_actions_sim_v3_spec["constraints"][
        "tag_is_one_continuous_sheet"
    ]
    assert seal_actions_sim_v3_spec["constraints"][
        "menu_is_same_sheet_unfold"
    ]
    assert seal_actions_sim_v4_spec["version"] == (
        "QUEST-LOG-SEAL-ACTIONS-SIM-V4"
    )
    assert seal_actions_sim_v4_spec["support_type"] == (
        "bottom-page-layered-parchment-bookmark"
    )
    assert seal_actions_sim_v4_spec["frame"] == [676, 464]
    assert seal_actions_sim_v4_spec["layout"][
        "page_lip_source_box"
    ] == [512, 384, 88, 38]
    assert seal_actions_sim_v4_spec["layout"]["tag_root_box"] == [
        540,
        385,
        26,
        25,
    ]
    assert seal_actions_sim_v4_spec["layout"][
        "document_tag_bbox"
    ] == [529, 385, 50, 125]
    assert seal_actions_sim_v4_spec["layout"][
        "menu_connection_box"
    ] == [532, 382, 41, 48]
    assert seal_actions_sim_v4_spec["layout"]["seal_visual"] == [
        537,
        474,
        32,
        32,
    ]
    assert len(seal_actions_sim_v4_spec["content"]["menu_actions"]) == 7
    assert seal_actions_sim_v4_spec["constraints"]["imagegen_calls"] == 0
    assert seal_actions_sim_v4_spec["constraints"]["bookmark_is_vertical"]
    assert seal_actions_sim_v4_spec["constraints"][
        "bookmark_root_is_at_detail_lower_edge"
    ]
    assert seal_actions_sim_v4_spec["constraints"][
        "menu_unfolds_upward_from_bottom"
    ]
    reward_bottom = max(
        box[1] + box[3]
        for box in seal_actions_sim_v4_spec["layout"]["reward_slots"]
    )
    assert seal_actions_sim_v4_spec["layout"]["tag_root_box"][1] >= (
        reward_bottom
    )
    assert seal_actions_sim_v5_spec["version"] == (
        "QUEST-LOG-SEAL-ACTIONS-SIM-V5"
    )
    assert seal_actions_sim_v5_spec["support_type"] == (
        "short-bottom-bookmark-same-page-menu"
    )
    assert seal_actions_sim_v5_spec["frame"] == [676, 464]
    assert seal_actions_sim_v5_spec["visible_book_bottom_y"] == 432
    assert seal_actions_sim_v5_spec["layout"][
        "page_lip_source_box"
    ] == [530, 384, 72, 30]
    assert seal_actions_sim_v5_spec["layout"]["tag_root_box"] == [
        555,
        390,
        26,
        20,
    ]
    assert seal_actions_sim_v5_spec["layout"][
        "document_tag_bbox"
    ] == [546, 390, 46, 78]
    assert seal_actions_sim_v5_spec["layout"]["menu"] == (
        seal_actions_sim_v5_spec["layout"]["detail"]
    )
    assert seal_actions_sim_v5_spec["layout"]["seal_visual"] == [
        554,
        434,
        32,
        32,
    ]
    assert len(seal_actions_sim_v5_spec["content"]["menu_actions"]) == 7
    assert seal_actions_sim_v5_spec["constraints"]["imagegen_calls"] == 0
    assert seal_actions_sim_v5_spec["constraints"][
        "bookmark_visible_length_is_short"
    ]
    assert seal_actions_sim_v5_spec["constraints"][
        "menu_reuses_existing_detail_page_surface"
    ]
    assert seal_actions_sim_v5_spec["constraints"][
        "menu_has_no_secondary_paper_or_popup_plane"
    ]
    assert seal_actions_sim_v6_spec["version"] == (
        "QUEST-LOG-SEAL-ACTIONS-SIM-V6"
    )
    assert seal_actions_sim_v6_spec["support_type"] == (
        "brass-corner-seal-bottom-action-rail"
    )
    assert seal_actions_sim_v6_spec["layout"]["seal_visual"] == [
        636,
        388,
        32,
        32,
    ]
    assert len(seal_actions_sim_v6_spec["layout"]["action_slots"]) == 7
    assert seal_actions_sim_v6_spec["constraints"]["imagegen_calls"] == 0
    assert seal_actions_sim_v7_spec["version"] == (
        "QUEST-LOG-SEAL-ACTIONS-SIM-V7"
    )
    assert seal_actions_sim_v7_spec["support_type"] == (
        "direct-detail-page-seal-right-action-list"
    )
    assert seal_actions_sim_v7_spec["frame"] == [676, 464]
    assert seal_actions_sim_v7_spec["layout"]["seal_reserved_corner"] == [
        572,
        64,
        40,
        40,
    ]
    assert seal_actions_sim_v7_spec["layout"]["seal_visual"] == [
        576,
        68,
        32,
        32,
    ]
    assert seal_actions_sim_v7_spec["layout"]["detail_title_safe"] == [
        376,
        72,
        188,
        28,
    ]
    assert seal_actions_sim_v7_spec["layout"]["right_action_menu"] == [
        488,
        108,
        124,
        186,
    ]
    assert len(seal_actions_sim_v7_spec["layout"]["action_slots"]) == 7
    assert seal_actions_sim_v7_spec["layout"]["action_slots"][-1][1] + (
        seal_actions_sim_v7_spec["layout"]["action_slots"][-1][3]
    ) <= seal_actions_sim_v7_spec["layout"]["reward_slots"][0][1]
    assert seal_actions_sim_v7_spec["constraints"]["imagegen_calls"] == 0
    assert seal_actions_sim_v7_spec["constraints"][
        "direct_wax_on_detail_parchment"
    ]
    assert seal_actions_sim_v7_spec["constraints"][
        "no_secondary_page_or_popup_plane"
    ]
    assert seal_actions_sim_v8_spec["version"] == (
        "QUEST-LOG-SEAL-ACTIONS-SIM-V8"
    )
    assert seal_actions_sim_v8_spec["support_type"] == (
        "direct-detail-page-seal-exterior-ledger-tabs"
    )
    assert seal_actions_sim_v8_spec["frame"] == [676, 464]
    assert seal_actions_sim_v8_spec["right_outset"] == 72
    assert seal_actions_sim_v8_spec["layout"]["seal_visual"] == [
        576,
        68,
        32,
        32,
    ]
    assert seal_actions_sim_v8_spec["layout"][
        "exterior_action_menu"
    ] == [612, 108, 136, 186]
    assert seal_actions_sim_v8_spec["layout"]["page_edge_mask"] == [
        604,
        96,
        24,
        210,
    ]
    assert len(seal_actions_sim_v8_spec["layout"]["action_slots"]) == 7
    assert seal_actions_sim_v8_spec["layout"][
        "exterior_action_menu"
    ][0] == sum(
        (
            seal_actions_sim_v8_spec["layout"]["detail"][0],
            seal_actions_sim_v8_spec["layout"]["detail"][2],
        )
    )
    assert seal_actions_sim_v8_spec["constraints"]["imagegen_calls"] == 0
    assert seal_actions_sim_v8_spec["constraints"][
        "tabs_must_not_occupy_detail_page"
    ]
    assert seal_actions_sim_v8_spec["constraints"][
        "each_action_is_an_independent_button"
    ]
    assert seal_actions_sim_v9_spec["version"] == (
        "QUEST-LOG-SEAL-ACTIONS-SIM-V9"
    )
    assert seal_actions_sim_v9_spec["support_type"] == (
        "direct-detail-page-seal-exterior-ledger-tabs"
    )
    assert seal_actions_sim_v9_spec["tab_style"] == (
        "restrained-archival-index-v1"
    )
    assert seal_actions_sim_v9_spec["frame"] == [676, 464]
    assert seal_actions_sim_v9_spec["right_outset"] == 48
    assert seal_actions_sim_v9_spec["layout"]["seal_visual"] == [
        576,
        68,
        32,
        32,
    ]
    assert seal_actions_sim_v9_spec["layout"][
        "exterior_action_menu"
    ] == [612, 112, 112, 158]
    assert seal_actions_sim_v9_spec["layout"]["page_edge_mask"] == [
        604,
        102,
        24,
        180,
    ]
    assert len(seal_actions_sim_v9_spec["layout"]["action_slots"]) == 7
    assert all(
        slot[2:] == [112, 20]
        for slot in seal_actions_sim_v9_spec["layout"]["action_slots"]
    )
    assert seal_actions_sim_v9_spec["layout"][
        "exterior_action_menu"
    ][0] == sum(
        (
            seal_actions_sim_v9_spec["layout"]["detail"][0],
            seal_actions_sim_v9_spec["layout"]["detail"][2],
        )
    )
    assert seal_actions_sim_v9_spec["constraints"]["imagegen_calls"] == 0
    assert seal_actions_sim_v9_spec["constraints"][
        "tabs_must_not_occupy_detail_page"
    ]
    assert seal_actions_sim_v9_spec["constraints"][
        "each_action_is_an_independent_button"
    ]
    assert seal_actions_sim_v9_spec["constraints"][
        "no_arrowheads_or_per_tab_rivets"
    ]
    assert seal_actions_sim_v9_spec["constraints"][
        "danger_uses_accent_only"
    ]
    assert seal_actions_sim_v10_spec["version"] == (
        "QUEST-LOG-SEAL-ACTIONS-SIM-V10"
    )
    assert seal_actions_sim_v10_spec["design_batch"] == "QS-B1 V2"
    assert seal_actions_sim_v10_spec["support_type"] == (
        "direct-detail-page-seal-exterior-ledger-tabs"
    )
    assert seal_actions_sim_v10_spec["tab_style"] == (
        "irregular-docket-slips-v2"
    )
    assert seal_actions_sim_v10_spec["frame"] == [676, 464]
    assert seal_actions_sim_v10_spec["right_outset"] == 48
    assert seal_actions_sim_v10_spec["layout"]["seal_visual"] == [
        576,
        68,
        32,
        32,
    ]
    assert seal_actions_sim_v10_spec["layout"][
        "exterior_action_menu"
    ] == [612, 112, 112, 158]
    assert seal_actions_sim_v10_spec["layout"][
        "page_edge_mask"
    ] == [604, 102, 24, 180]
    v10_slots = seal_actions_sim_v10_spec["layout"]["action_slots"]
    v10_visible = seal_actions_sim_v10_spec["layout"][
        "action_visible_slips"
    ]
    assert len(v10_slots) == len(v10_visible) == 7
    assert all(slot[2:] == [112, 20] for slot in v10_slots)
    assert [box[2] for box in v10_visible] == [
        99,
        94,
        108,
        101,
        96,
        105,
        98,
    ]
    assert all(
        slot[0] <= visible[0]
        and slot[1] <= visible[1]
        and visible[0] + visible[2] <= slot[0] + slot[2]
        and visible[1] + visible[3] <= slot[1] + slot[3]
        for slot, visible in zip(v10_slots, v10_visible)
    )
    assert seal_actions_sim_v10_spec["constraints"]["imagegen_calls"] == 0
    assert seal_actions_sim_v10_spec["constraints"][
        "each_action_is_an_independent_button"
    ]
    assert seal_actions_sim_v10_spec["constraints"][
        "visible_skin_is_owned_per_button"
    ]
    assert seal_actions_sim_v10_spec["constraints"][
        "no_shared_menu_backing"
    ]
    assert seal_actions_sim_v10_spec["constraints"][
        "no_full_outline_or_bevel"
    ]
    assert seal_actions_sim_v10_spec["constraints"][
        "danger_uses_ink_accent_only"
    ]
    assert seal_actions_sim_v11_spec["version"] == (
        "QUEST-LOG-SEAL-ACTIONS-SIM-V11"
    )
    assert seal_actions_sim_v11_spec["design_batch"] == "QS-B1 V2"
    assert seal_actions_sim_v11_spec["support_type"] == (
        "scroll-child-wax-pinned-action-ribbon"
    )
    assert seal_actions_sim_v11_spec["ribbon_style"] == (
        "azeroth-guild-warrant-ribbon-v1"
    )
    assert seal_actions_sim_v11_spec["frame"] == [676, 464]
    v11_layout = seal_actions_sim_v11_spec["layout"]
    assert v11_layout["detail_viewport"] == [366, 64, 246, 324]
    assert v11_layout["detail_scroll_child"] == [366, 64, 246, 560]
    assert v11_layout["detail_body_width"] == 214
    assert v11_layout["detail_indented_width"] == 204
    assert v11_layout["seal_hitbox_content"] == [206, 0, 40, 40]
    assert v11_layout["seal_visual_content"] == [210, 4, 32, 32]
    assert v11_layout["ribbon_root_content"] == [210, 30, 32, 12]
    v11_segments = v11_layout["ribbon_action_segments_content"]
    assert len(v11_segments) == 7
    assert all(segment[2:] == [32, 22] for segment in v11_segments)
    assert all(
        left[1] + left[3] == right[1]
        for left, right in zip(v11_segments, v11_segments[1:])
    )
    assert v11_layout["ribbon_tail_content"] == [210, 196, 32, 8]
    assert len(v11_layout["reward_slots_content"]) == 4
    assert all(
        reward[2:] == [108, 41]
        for reward in v11_layout["reward_slots_content"]
    )
    assert min(
        reward[1] for reward in v11_layout["reward_slots_content"]
    ) - (
        v11_layout["ribbon_tail_content"][1]
        + v11_layout["ribbon_tail_content"][3]
    ) == 32
    assert [state["scroll_offset"] for state in seal_actions_sim_v11_spec["states"]] == [
        0,
        0,
        52,
        208,
    ]
    assert [
        state["expected_enabled_actions"]
        for state in seal_actions_sim_v11_spec["states"]
    ] == [0, 7, 6, 0]
    assert len(seal_actions_sim_v11_spec["content"]["provider_proxies"]) == 7
    assert len(seal_actions_sim_v11_spec["content"]["motifs"]) == 7
    assert seal_actions_sim_v11_spec["interaction"]["seal_parent"] == (
        "QuestLogDetailScrollChild"
    )
    assert seal_actions_sim_v11_spec["interaction"]["ribbon_parent"] == (
        "QuestLogDetailScrollChild"
    )
    assert seal_actions_sim_v11_spec["constraints"]["imagegen_calls"] == 0
    assert seal_actions_sim_v11_spec["constraints"][
        "each_action_is_an_independent_button"
    ]
    assert seal_actions_sim_v11_spec["constraints"][
        "no_single_ribbon_bitmap_for_seven_hit_regions"
    ]
    assert seal_actions_sim_v11_spec["constraints"][
        "no_page_reflow_or_permanent_text_narrowing"
    ]
    assert seal_actions_sim_v11_spec["constraints"][
        "ribbon_ends_before_rewards"
    ]
    assert seal_actions_sim_v11_display["schema"] == (
        "aeui-display-region-contract-v1"
    )
    assert len(seal_actions_sim_v11_display["scenarios"]) == 4
    assert all(
        scenario["frame"] == [246, 324]
        and scenario["preview_frame"] == [246, 324]
        for scenario in seal_actions_sim_v11_display["scenarios"]
    )
    require(
        seal_actions_sim_v11_renderer,
        (
            "draw_ribbon_root",
            "draw_ribbon_segment",
            "draw_ribbon_tail",
            "state_metrics",
            "partial_scroll_disables_first_clipped_action",
            "fully_scrolled_out_has_zero_action_hitboxes",
            "temporary_body_overlay_px",
            '"calls": 0',
        ),
        "QS-B1 V11 deterministic scroll-ribbon renderer",
    )
    require(
        seals_work,
        (
            "QUEST-LOG-SEAL-ACTIONS-SIM-V1",
            "simulation-reviewed / P2 / superseded-before-confirmation",
            "QuestFramePushQuestButton",
            "QuestLogFrameExpandButton",
            "pfQuest.buttonShow",
            "pfQuest.buttonHide",
            "pfQuest.buttonClean",
            "pfQuest.buttonReset",
            "QuestLogFrameAbandonButton",
            "fail-open",
            "ImageGen：`0/0`",
        ),
        "Quest Log seal action simulation work",
    )
    require(
        seals_work,
        (
            "QUEST-LOG-SEAL-ACTIONS-SIM-V2",
            "羊皮纸火漆封签",
            "superseded-before-confirmation",
            "page_exit=[603,190,34,38]",
            "document_tag=[614,197,80,27]",
            "tag_head=[672,189,44,44]",
            "seal_visual=[678,195,32,32]",
            "a61ac0e3624831103cd9d1db31ffc07a0e55e21dc720b143c9c79196771c8f42",
            "082f4585bcec49244b1ac16a985177520badc6eec0b0ae166254964cc2e8ba1e",
            "ImageGen：`0/0`",
            "用户结论：`user-rejected`",
        ),
        "Quest Log parchment seal-tag simulation work",
    )
    require(
        seals_work,
        (
            "QUEST-LOG-SEAL-ACTIONS-SIM-V3",
            "书页夹层火漆封签",
            "page_lip_source_box=[598,176,39,54]",
            "tag_root_box=[608,184,27,27]",
            "document_tag_bbox=[608,184,112,50]",
            "menu_connection_box=[650,184,42,48]",
            "seal_visual=[684,196,32,32]",
            "86642cfdfaeae0326bc7917769b34f7de2b063cc272dce3d879b6be33ef71310",
            "aec599e88fafb01b317354708b9c43f5fa2872de6c0ec4e24e767e9c39c547ae",
            "ImageGen：`0/0`",
            "用户结论：`user-rejected`",
        ),
        "Quest Log page-layered seal-tag simulation work",
    )
    require(
        seals_work,
        (
            "QUEST-LOG-SEAL-ACTIONS-SIM-V4",
            "右页下缘竖向火漆书签",
            "page_lip_source_box=[512,384,88,38]",
            "tag_root_box=[540,385,26,25]",
            "document_tag_bbox=[529,385,50,125]",
            "menu_connection_box=[532,382,41,48]",
            "seal_visual=[537,474,32,32]",
            "386d625e67c1a0eae6dfda07cc7c4213d65aa992c91ab1f25752311a5b7ecd20",
            "874f240d5eaf12bb47fbe2db9428372897288068880d6ff6568471674d3241c7",
            "ImageGen：`0/0`",
            "用户结论：`user-rejected`",
        ),
        "Quest Log bottom bookmark seal simulation work",
    )
    require(
        seals_work,
        (
            "QUEST-LOG-SEAL-ACTIONS-SIM-V5",
            "短火漆书签与同页事务模式",
            "page_lip_source_box=[530,384,72,30]",
            "tag_root_box=[555,390,26,20]",
            "document_tag_bbox=[546,390,46,78]",
            "menu=[366,64,246,324]",
            "seal_visual=[554,434,32,32]",
            "ef4010a3b6d36350f5bb231cfac5df1fd96e4630a00639f15e586ff765421961",
            "fc62895116ad8d0b5ea1f769e1a3afed681d33b6252210dcc01ed317c59ca9ff",
            "ImageGen：`0/0`",
            "用户结论：`user-rejected`",
        ),
        "Quest Log short bookmark same-page simulation work",
    )
    require(
        seals_work,
        (
            "QUEST-LOG-SEAL-ACTIONS-SIM-V6",
            "包角漆章与下沿事务轨",
            "user-redirected-before-review",
            "fcc62bf3eca59e660649ca57adac6843662c77f454d9c910a5eb71b7762f8f3d",
            "56788f4374ece88a1e758b226bb2317b9e7523ee5a013b3ca89d921bd2f109f3",
            "ImageGen：`0/0`",
        ),
        "Quest Log brass-corner seal simulation work",
    )
    require(
        seals_work,
        (
            "QUEST-LOG-SEAL-ACTIONS-SIM-V7",
            "详情页右上火漆与右侧事务列",
            "seal_visual=[576,68,32,32]",
            "right_action_menu=[488,108,124,186]",
            "ec69f8112ae451c39b07910c8483fe705024b55c7ceef90cce18ae459167d41d",
            "e98e721e8d2005a765bde8ec95cc0576ed1c8cf092bd19285ff27de9dd1e741f",
            "ImageGen：`0/0`",
            "用户结论：`user-rejected`",
        ),
        "Quest Log detail-page seal right-action-list simulation work",
    )
    require(
        seals_work,
        (
            "QUEST-LOG-SEAL-ACTIONS-SIM-V8",
            "详情页火漆与外侧卷宗索引签",
            "exterior_action_menu=[612,108,136,186]",
            "page_edge_mask=[604,96,24,210]",
            "928714893d9f3234dfea7cc497f95f666bd03e2f37aa309862754a41c3ea9279",
            "72e001d2ed5bff88ca0fd39e763aa457fdeae33b92ece9dd08f5a404c62b62fd",
            "ImageGen：`0/0`",
            "用户结论：`user-rejected / 2026-08-03`",
        ),
        "Quest Log exterior ledger-tab simulation work",
    )
    require(
        seals_work,
        (
            "QUEST-LOG-SEAL-ACTIONS-SIM-V9",
            "详情页火漆与克制型书口事务签",
            "exterior_action_menu=[612,112,112,158]",
            "page_edge_mask=[604,102,24,180]",
            "d639e13a539942550c34e1cc2400b9b11c5374279be606324f09fe57bea6d839",
            "58ddce681b587a7124e856b227b0929f771fc50c2c17a80994bfe4cb9f7c4718",
            "ImageGen：`0/0`",
            "用户结论：`confirmed / 2026-08-03`",
            "`QS-B1 V1`",
            "`QUEST.LOG.ACTION.SEAL_MENU.TAB.BASE`",
            "03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd",
            "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5",
            "standard normal／hover／pressed／disabled",
            "danger normal／hover／pressed／disabled",
            "exactly one object",
            "当前实际生图：`5/5`",
            "`QS-B1-INTERACTION V1`",
            "`QS-B1 V1` 已由用户于 `2026-08-05` 以以下原文独立授权",
            "candidate-rejected / user-rejected / repair-budget-exhausted / P3 / 5/5",
            "QS-B1 V1.r4",
            "4.3636:1",
            "runtime-visible `87×20px`",
            "4.2851:1",
            "`86×20px`",
            "5.1456:1",
            "runtime-visible `103×20px`",
            "5.1707:1",
            "187..191px",
            "019fcfd8-d153-7603-b59f-0ee2a979662d",
            "259a5d713e9872f99e91dcb0e8dc39f04f8f5c252ac2e12d416e9baca667751b",
            "1184×193",
            "6.1347:1",
            "112×18px",
            "repair-budget-exhausted",
            "不得执行第六次 ImageGen",
            "用户原文：`不可接受`",
            "作为 edit input",
            "`QS-B1 V2 / prompt-draft`",
            "Reading prompt from stdin... No prompt provided via stdin.",
            "pre-generation transport error",
            "用户回复“接受”",
            "`FALLBACK`",
            "`CLOSED`",
            "`OPEN`",
            "`DISPATCH`",
            "[628,y,96,20]",
            ':Click("LeftButton")',
            "不得建立全屏透明挡板",
            "右上 Close",
        ),
        "Quest Log restrained exterior docket-tab simulation work",
    )
    require(
        seals_work,
        (
            "QS-B1 V2 旧卷宗索引签预演",
            "QUEST-LOG-SEAL-ACTIONS-SIM-V10",
            "`user-superseded-before-confirmation / P2`",
            "99／94／108／101／96／105／98px",
            "`31/31 pass`",
            "3b9d7ac8fa1c4e4a74e3f96cf6c891ea4510d72c53afebcb4523fd5359550f32",
            "69a5bedb50970cac22d764ad164fcf7ec3da2a3b0a5e89fbcd5fec53acac9834",
            "33e681dd3bb4f18f7537198472d136a0b504173a8bfd48b943383748cd9bfffb",
            "31c6afbc7f2feeb07bf37524ad32f9c1624f2d076ef9ac32385eaf8f5b07be3c",
            "ImageGen：`0/0`",
            "本地流程错误：`0`",
            "V1 attempt 1–5",
            "不需要临时 `handoff/`",
            "V10 尚未获得确认",
        ),
        "QS-B1 V10 superseded deterministic simulation work",
    )
    require(
        seals_work,
        (
            "QS-B1 V2 页内火漆授印绶带预演",
            "QUEST-LOG-SEAL-ACTIONS-SIM-V11",
            "`simulation-confirmed / P2`",
            "QuestLogDetailScrollChild",
            "`32×22px`",
            "`14..24px`",
            "`108×41px`",
            "open / scroll 52",
            "open / scroll 208",
            "`21/21 pass`",
            "`4/4` 场景",
            "f720f4f84de42ab3addfd600658a57f06206944e8a72436a1d839d3140fda13c",
            "ImageGen：`0/0`",
            "当前不得生图、上传、导出",
        ),
        "QS-B1 V11 deterministic pre-production simulation work",
    )
    require(
        progress,
        (
            "QUEST-LOG-SEAL-ACTIONS-SIM-V11 / QS-B1 V2",
            "`21/21 pass`",
            "display-region `4/4 pass`",
            "ImageGen `0/0`",
        ),
        "QS-B1 V11 progress",
    )
    require(
        submodules,
        (
            "QUEST-LOG-SEAL-ACTIONS-SIM-V12 / QS-B1 V3",
            "`QUEST.LOG.ACTION.SEAL_MENU.SUBSTRATE.MAX`",
            "`QUEST.LOG.ACTION.SEAL_MENU.SUBSTRATE.ROOT`",
            "`QUEST.LOG.ACTION.SEAL_MENU.SUBSTRATE.BODY`",
            "`QUEST.LOG.ACTION.SEAL_MENU.SUBSTRATE.TAIL`",
            "`QUEST.LOG.ACTION.SEAL_MENU.MOTIF.SHARE`",
            "`QUEST.LOG.ACTION.SEAL_MENU.MOTIF.ABANDON`",
            "`QUEST.LOG.ACTION.SEAL_MENU.BUTTON.SHARE`",
            "`QUEST.LOG.ACTION.SEAL_MENU.BUTTON.ABANDON`",
            "七张独立透明纹章",
            "ScrollChild",
            "不得出现 variant 循环",
        ),
        "QS-B1 V12 layered component ownership",
    )
    require(
        seals_work,
        (
            "QS-B1 V2 页内公会授印绶带母版 — production preparation",
            "`repair-prepared / P3`",
            "imagegen-0-143-0 / @openai/codex@0.143.0",
            "本版本实际 ImageGen：`4/5`",
            "用户生产授权：`2026-08-05`",
            "确认授权 QS-B1 V2",
            "03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd",
            "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5",
            "QuestLogSealRibbon_Master_v2.png",
            "QuestLogSealRibbonStatesV2.tga",
            "一条物理连续的、无火漆的纵向公会誓约亚麻绶带 normal 母版",
            "无鼠标根部、七个独立 Button 分段、无鼠标尾端",
            "[448,164,576,860]",
            "`128×696px`",
            "[448,212,576,300]",
            "[448,740,576,828]",
            "[448,828,576,860]",
            "[16,12,112,76]",
            "runtime atlas 固定为 `512×256`",
            "normal／hover／pressed／disabled",
            "Create exactly one isolated, connected vertical guild oath-ribbon master",
            "aged coarse-woven linen",
            "two compact paired quills",
            "one snapped contract cord",
            "outside the one ribbon must be uniform solid #00FF00",
            "seven and only seven equal 88-pixel action bands",
            "attempt 1 只上传固定 SHA 的 Image 1／2",
            "最多 `5` 次实际 ImageGen generation／edit",
            "流程错误不占生图额度",
            "用户明确接受具体候选前",
            "attempt 1 执行与完整审查",
            "55814b16aa520e55894dbec7bf89c5cb6f1b18d39dae4548234f7b64e2bf4622",
            "没有独立 plain root 和 short tail",
            "禁止上传本稿为 Image 3",
            "完整修复执行正文 — `QS-B1 V2.r1`",
            "This is a fresh regenerate, not an edit.",
            "5.4375",
            "no full-width horizontal seam",
            "attempt 2 仍使用用户已授权的固定执行器",
            "attempt 2 执行与完整审查",
            "fade05990d46671983f931fc2c7e14531d4928c93a4ebb3a87f8046fa9f1fc2a",
            "宽高比 `0.2158`",
            "完整修复执行正文 — `QS-B1 V2.r2`",
            "Edit Image 3 as the immediate prior candidate.",
            "0.00% through 6.90%",
            "Image 3 is edit identity authority only",
            "attempt 3 上传固定 Image 1／2",
            "attempt 3 执行与完整审查",
            "8b55835dd2206f11509c54596708d8774855ea12c382e6d662e90f5e596cc225",
            "组件 safe box",
            "完整修复执行正文 — `QS-B1 V2.r3`",
            "Each motif must fit",
            "box [472,230,552,282]",
            "box [472,758,552,810]",
            "attempt 4 上传固定 Image 1／2",
            "attempt 4 执行与完整审查",
            "214a30a0afd769590c32f17b2d65c4778a0f4bbb683565e28f36eb83ced99ac4",
            "技术审查 `11/12`",
            "完整修复执行正文 — `QS-B1 V2.r4`",
            "surgical ink-only repair",
            "[480,236,544,276]",
            "[480,764,544,804]",
            "V2.r4 最终调用边界",
            "candidate-rejected / repair-budget-exhausted",
        ),
        "QS-B1 V2 complete production prompt and authorization boundary",
    )

    assert seal_actions_sim_v12_spec["schema"] == (
        "aeui.quest-log.seal-layered-actions.simulation.v1"
    )
    assert seal_actions_sim_v12_spec["version"] == (
        "QUEST-LOG-SEAL-ACTIONS-SIM-V12"
    )
    assert seal_actions_sim_v12_spec["design_batch"] == "QS-B1 V3"
    assert seal_actions_sim_v12_spec["frame"] == [676, 464]
    assert seal_actions_sim_v12_spec["content"] == {
        "quest_rows": 18,
        "reward_slots": 4,
    }
    assert seal_actions_sim_v12_spec["layout"]["detail_viewport"] == [
        366,
        64,
        246,
        324,
    ]
    assert [item["id"] for item in seal_actions_sim_v12_spec["actions"]] == [
        "share",
        "detail",
        "show",
        "hide",
        "clean",
        "reset",
        "abandon",
    ]
    v12_states = {
        item["id"]: item for item in seal_actions_sim_v12_spec["states"]
    }
    assert len(v12_states["open-all-seven"]["visible_actions"]) == 7
    assert v12_states["open-filtered-five"]["visible_actions"] == [
        "share",
        "detail",
        "show",
        "reset",
        "abandon",
    ]
    assert v12_states["open-filtered-three-disabled"]["visible_actions"] == [
        "share",
        "show",
        "abandon",
    ]
    assert v12_states["open-filtered-three-disabled"]["disabled_actions"] == [
        "show"
    ]
    assert v12_states["filtered-five-partial-scroll"]["scroll_offset"] == 52
    assert v12_states["filtered-five-fully-scrolled-out"]["scroll_offset"] == 208
    v12_constraints = seal_actions_sim_v12_spec["constraints"]
    assert v12_constraints["imagegen_calls"] == 0
    assert v12_constraints["substrate_is_visual_only_and_receives_no_mouse"]
    assert v12_constraints["substrate_uses_root_body_variants_and_tail"]
    assert v12_constraints["body_variants_are_seamless_and_not_function_owned"]
    assert v12_constraints["motifs_are_seven_independent_transparent_assets"]
    assert v12_constraints["hidden_actions_compact_without_blank_slots"]
    assert v12_constraints["disabled_actions_remain_in_flow"]
    assert v12_constraints["no_motif_is_baked_into_background"]
    assert v12_constraints["no_action_owns_a_cloth_background_slice"]

    assert seal_actions_sim_v12_display["schema"] == (
        "aeui-display-region-contract-v1"
    )
    assert len(seal_actions_sim_v12_display["scenarios"]) == 6
    assert [
        item["id"]
        for item in seal_actions_sim_v12_display["atlas"]["sampled_regions"]
    ] == [
        "motif.share",
        "motif.detail",
        "motif.show",
        "motif.hide",
        "motif.clean",
        "motif.reset",
        "motif.abandon",
    ]
    require(
        seal_actions_sim_v12_renderer,
        (
            "def substrate_art(",
            "def motif_art(",
            "def action_boxes(",
            '"hidden_reflow": "compact-visible-order"',
            '"disabled_reflow": "remain-in-flow"',
            '"imagegen": {"calls": 0, "uploads": 0}',
        ),
        "QS-B1 V12 layered deterministic renderer",
    )
    assert seal_substrate_sim_v13_spec["version"] == (
        "QUEST-LOG-SEAL-SUBSTRATE-SIM-V13"
    )
    assert seal_substrate_sim_v13_spec["design_batch"] == "QS-B1 V4-A"
    v13_mockup = seal_substrate_sim_v13_spec["visual_mockup"]
    assert v13_mockup["canonical_master_size"] == [32, 174]
    assert v13_mockup["dynamic_assembly"] == (
        "prefix-plus-tail-from-one-master"
    )
    assert v13_mockup["tail_notch_count"] == 2
    assert max(v13_mockup["palette"]["base"][:3]) <= 90
    assert max(v13_mockup["palette"]["light_plane"][:3]) <= 120
    assert all(
        point[1] % 22 != 0
        for point in v13_mockup["edge_control_points"]
        if point[1] not in (0, 174)
    )
    assert len(seal_substrate_sim_v13_display["scenarios"]) == 6
    require(
        seal_substrate_sim_v13_renderer,
        (
            "def substrate_master_v4(",
            "def render_zoom_board(",
            '"v4-dark-irregular"',
            '"v4_tail_has_two_unequal_coarse_notches"',
            '"imagegen": {"calls": 0, "uploads": 0}',
        ),
        "QS-B1 V13 dark substrate deterministic renderer",
    )
    assert seal_substrate_sim_v14_spec["version"] == (
        "QUEST-LOG-SEAL-SUBSTRATE-SIM-V14"
    )
    assert seal_substrate_sim_v14_spec["design_batch"] == "QS-B1 V5-A"
    assert seal_substrate_sim_v14_spec["base_spec"] == (
        "tools/specs/quest_log_seal_substrate_simulation_v13.json"
    )
    v14_mockup = seal_substrate_sim_v14_spec["visual_mockup"]
    assert v14_mockup["source_strategy"] == (
        "imagegen-full-frame-material-donor-plus-deterministic-mask"
    )
    assert v14_mockup["donor_normalized_canvas"] == [1024, 1024]
    assert v14_mockup["donor_crop"] == [448, 164, 576, 860]
    assert v14_mockup["canonical_source_size"] == [128, 696]
    assert v14_mockup["deterministic_visible_bbox"] == [0, 0, 128, 696]
    assert v14_mockup["canonical_master_size"] == [32, 174]
    assert v14_mockup["dynamic_assembly"] == (
        "prefix-plus-tail-from-one-master"
    )
    assert v14_mockup["tail_notch_count"] == 2
    mask_points = v14_mockup["mask_polygon_source"]
    assert min(point[0] for point in mask_points) == 0
    assert max(point[0] for point in mask_points) == 127
    assert min(point[1] for point in mask_points) == 0
    assert max(point[1] for point in mask_points) == 695
    assert all(
        abs(point[1] - row) > 8
        for point in v14_mockup["edge_control_points_source"]
        for row in v14_mockup["quiet_crop_rows_source"]
    )
    v14_constraints = seal_substrate_sim_v14_spec["constraints"]
    assert v14_constraints["imagegen_calls"] == 0
    assert v14_constraints["imagegen_owns_surface_only"]
    assert v14_constraints["deterministic_mask_owns_silhouette_and_alpha"]
    assert v14_constraints["no_bbox_fit_or_anisotropic_resize"]
    assert v14_constraints["accepted_candidate_is_composite_not_raw_donor"]
    require(
        seal_substrate_sim_v13_renderer,
        (
            "def load_simulation_spec(",
            "def substrate_source_v5(",
            "def substrate_master_v5(",
            "def render_v5_zoom_board(",
            '"v5-deterministic-mask"',
            '"v5_mask_visible_bbox_is_exact"',
            '"imagegen": "full-frame continuous cloth surface donor only"',
        ),
        "QS-B1 V14 donor/mask deterministic renderer",
    )
    assert seal_motifs_sim_v15_spec["version"] == (
        "QUEST-LOG-SEAL-MOTIFS-SIM-V15"
    )
    assert seal_motifs_sim_v15_spec["design_batch"] == "QS-B1 V5-B"
    assert seal_motifs_sim_v15_spec["base_spec"] == (
        "tools/specs/quest_log_seal_substrate_simulation_v14.json"
    )
    v15_mockup = seal_motifs_sim_v15_spec["visual_mockup"]
    assert v15_mockup["accepted_substrate_source"] == (
        "assets/source/quests/qs-b1/QuestLogSealMenuSubstrate_Master_v1.png"
    )
    assert v15_mockup["accepted_substrate_sha256"] == (
        "6b3207f15d961cbef7471399c9bfb725b475385ce9e66648fc435a9e28111d9c"
    )
    motif_palette = v15_mockup["motif_palette"]
    assert max(motif_palette["guild"]["normal"][:3]) <= 180
    assert min(motif_palette["guild"]["normal"][:3]) > 68
    assert motif_palette["abandon"]["normal"][0] > (
        motif_palette["abandon"]["normal"][1]
    )
    assert motif_palette["abandon"]["normal"][0] > (
        motif_palette["abandon"]["normal"][2]
    )
    assert seal_motifs_sim_v15_spec["constraints"]["imagegen_calls"] == 0
    assert seal_motifs_sim_v15_spec["constraints"][
        "simulation_pixels_are_not_source_or_future_edit_input"
    ]
    assert len(seal_motifs_sim_v15_spec["states"]) == 6
    assert seal_motifs_sim_v15_spec["display_region"]["component"].startswith(
        "QS-B1/QUEST.LOG.ACTION.SEAL_MENU/SIM.V15/"
    )
    require(
        seal_substrate_sim_v13_renderer,
        (
            "accepted_substrate_source",
            "accepted substrate SHA-256 does not match the V15 contract",
            'get("motif_palette")',
            "def materialize_display_region_contract(",
            '"v15_uses_the_exact_accepted_substrate"',
            '"v15_abandon_remains_muted_wine"',
        ),
        "QS-B1 V15 accepted-substrate motif-palette renderer",
    )
    assert seal_motifs_sim_v16_spec["version"] == (
        "QUEST-LOG-SEAL-MOTIFS-SIM-V16"
    )
    assert seal_motifs_sim_v16_spec["design_batch"] == "QS-B1 V6"
    assert seal_motifs_sim_v16_spec["base_spec"] == (
        "tools/specs/quest_log_seal_motifs_simulation_v15.json"
    )
    v16_sources = seal_motifs_sim_v16_spec["production_sources"]
    assert [item["id"] for item in v16_sources] == [
        "share",
        "detail",
        "show",
        "hide",
        "clean",
        "reset",
        "abandon",
    ]
    assert len({item["body"] for item in v16_sources}) == 7
    assert len({item["planned_source"] for item in v16_sources}) == 7
    assert all(item["source_canvas"] == [1024, 1024] for item in v16_sources)
    v16_budget = seal_motifs_sim_v16_spec["production_budget"]
    assert not v16_budget["authorized"]
    assert v16_budget["bodies"] == 7
    assert v16_budget["actual_imagegen_calls_per_body"] == 5
    assert v16_budget["worst_case_actual_imagegen_calls"] == 35
    assert v16_budget["current_actual_imagegen_calls"] == 0
    v16_constraints = seal_motifs_sim_v16_spec["constraints"]
    assert v16_constraints["imagegen_calls"] == 0
    assert v16_constraints["one_semantic_object_per_future_generation_body"]
    assert v16_constraints["no_multi_object_worksheet"]
    assert v16_constraints["v5b_failed_pixels_are_not_inputs"]
    assert v16_constraints["production_is_not_authorized_by_simulation_confirmation"]
    require(
        seal_substrate_sim_v13_renderer,
        (
            "def render_independent_source_topology(",
            '"v16_has_exactly_seven_independent_production_sources"',
            '"v16_each_source_canvas_is_1024_square"',
            '"v16_v5b_failed_pixels_are_not_inputs"',
            '"v16_worst_case_budget_is_35_actual_calls"',
            '"production_source_strategy"',
        ),
        "QS-B1 V16 seven single-object sources simulation renderer",
    )
    require(
        seals_work,
        (
            "QS-B1 V5-B 七枚独立纹章 — V15 生成前模拟",
            "旧 V3-B 的近黑公会印墨",
            "QUEST-LOG-SEAL-MOTIFS-SIM-V15 / QS-B1 V5-B",
            "51/51 pass",
            "display-region `6/6 pass`",
            "ImageGen\n  `0/0`",
            "V15 用户方向确认 — 2026-08-06",
            "该回复精确确认",
            "prompt-authorized / P3 / production 0/5",
            "QS-B1 V5-B 七枚独立旧赭金／酒红纹章 — production preparation",
            "03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd",
            "719445d15fb34be4af3ec316eac5bdec51c2061423bae5d7f45b47a3b1128c44",
            "已接受 V5-A 布底不上传给 ImageGen",
            "Use Image 1 and Image 2 only as fixed visual references.",
            "exactly seven independent",
            "matte, low-saturation aged ochre mineral",
            "muted, greyed, dark old-wine pigment",
            "完整 production Prompt — 已授权冻结",
            "prompt-authorized / P3 / 0/5",
            "V5-B 正式 production 授权冻结点",
            "确认授权 QS-B1 V5-B 最终 production 正文",
            "attempt 1 没有 Image 3",
            "QS-B1 V5-B 模拟 ImageGen：`0/0`；production `5/5`；流程错误 `7`",
            "V5-B 流程错误",
            "No prompt provided via stdin.",
            "最后一个 `-i` 后加入标准 `--` 参数分隔符",
            "流程错误，不占额度；仍为 `0/5`",
            "019fd4f1-ca45-7130-b6da-48e79d0abdf8",
            "6998 bytes",
            "762930e574b4c3fdf0ec6898946e51742d61ccfd9ae09913e018e95035a1dc54",
            "019fd4f3-c53a-75f0-822b-dc71902bb780",
            "codex exec -C <temp> -s workspace-write",
            "禁止读取 wrapper 或再启动 `codex/npx`",
            "019fd4f6-0883-7701-99d4-299a3273c3cd",
            "remote plugin catalog",
            "网络／工具发现流程错误，不占额度",
            "019fd4f8-7c20-77d0-9aa0-cc8d0042ce02",
            "codex exec resume",
            "CLI turn 提前结束流程错误，不占额度",
            "failed to warm remote plugin catalog cache",
            "execution-blocked / prompt-authorized / P3 / 0/5",
            "用户随后明确要求“重试”",
            "019fd504-7d9a-7fc1-8c14-9c35edc605ba",
            "08b150a62804c93f247e09041a7dfa4861515854c94854472fa58cf3a7f0a95e",
            "9/12 pass",
            "all_visible_pixels_stay_inside_safe_boxes",
            "完整 V5-B.r1 production Prompt — attempt 2",
            "NONNEGOTIABLE RENDERING MODE",
            "attempt 2 必须只上传固定",
            "019fd511-0865-7740-9702-fe3a7302142d",
            "8ac1e577b668362109afd3d26d519413643d697acef5bbe337425a94eebb4233",
            "第八空格仍有 `7363` 个可见像素",
            "本地审查流程错误，不占 ImageGen 额度",
            "完整 V5-B.r2 production Prompt — attempt 3",
            "Priority 1 is the exact seven-cell placement",
            "target visible\nbbox for both broken ends together",
            "attempt 3 必须 fresh regenerate",
            "019fd518-7330-7032-b2b4-7bef3def2c64",
            "987c5b4ddc8615262aad8cbf5c19d589fc70cac93756779eea1d2783d948e35a",
            "第八空格已为 `0` 可见像素",
            "完整 V5-B.r3 production Prompt — attempt 4",
            "The first row must be centered at exactly 26.5 percent",
            "absolutely no arrowhead",
            "attempt 4 必须 fresh regenerate",
            "019fd51f-a58a-7d52-85ed-ba4ebf3b1e1e",
            "2c40de66474f3abe4c23f955aa337dd95e69465f5d8056c3a784dcb5e697c601",
            "第八空格\n  有 `5744` 个可见像素",
            "完整 V5-B.r4 production Prompt — attempt 5",
            "The bottom row still has four equal placement slots",
            "No mark may exceed 5.5 percent",
            "这是 `5/5` 最后一次实际调用",
            "019fd527-d402-7c00-8fd2-4d6d0ec932d4",
            "0084d2e19eeb93d75d38044f6acdd0d9903645b876631c76edad1f6afc00747e",
            "ABANDON 是唯一",
            "RESET 另有 `44` 个 visible green spill",
            "candidate-rejected / repair-budget-exhausted / P3 / 5/5",
            "不存在 attempt 6",
        ),
        "QS-B1 V15 confirmation and V5-B active production repair gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6 七张单对象纹章 source — V16 生成前模拟",
            "QUEST-LOG-SEAL-MOTIFS-SIM-V16 / QS-B1 V6",
            "prompt-authorized / P3",
            "59/59 pass",
            "七个独立 production body 合同",
            "V5-B 的五张失败工作表",
            "`1/35 authorized`",
            "confirmed / 2026-08-06",
            "V16 确认本身仍",
            "不构成该授权",
        ),
        "QS-B1 V16 seven independent source simulation gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-A..G 最终 production preparation",
            "QS-B1 V6-A SHARE final production Prompt — authorized / frozen",
            "QS-B1 V6-B DETAIL final production Prompt — authorized / frozen",
            "QS-B1 V6-C SHOW final production Prompt — authorized / frozen",
            "QS-B1 V6-D HIDE final production Prompt — authorized / frozen",
            "QS-B1 V6-E CLEAN final production Prompt — authorized / frozen",
            "QS-B1 V6-F RESET final production Prompt — authorized / frozen",
            "QS-B1 V6-G ABANDON final production Prompt — authorized / frozen",
            "03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd",
            "719445d15fb34be4af3ec316eac5bdec51c2061423bae5d7f45b47a3b1128c44",
            "safe box [160,160,864,864]",
            "uniform exact #00FF00",
            "QS-B1 V6-A..G prompt completeness audit",
            "QS-B1 V6-A..G bounded production and repair envelope",
            "V6-A `1/5`、V6-B..G `0/5`",
            "确认授权 QS-B1 V6-A/B/C/D/E/F/G 最终 production 正文",
            "单段耗尽不阻止其他已授权独立段继续",
            "禁止跨段复用像素",
        ),
        "QS-B1 V6 seven complete production prompts and authorization gate",
    )
    v6_prompt_section = seals_work.split(
        "## QS-B1 V6-A..G 最终 production preparation", 1
    )[1].split("### QS-B1 V6-A..G prompt completeness audit", 1)[0]
    for required_heading in (
        "final production Prompt — authorized / frozen",
        "REFERENCE AUTHORITY",
        "CANVAS, COUNT, AND PLACEMENT",
        "EMBLEM ANATOMY",
        "MATERIAL, COLOR, EDGE, AND ERA",
        "STRICT EXCLUSIONS",
        "FINAL SELF-CHECK",
    ):
        assert v6_prompt_section.count(required_heading) == 7, (
            f"V6 prompt bodies must each contain {required_heading!r}"
        )
    assert v6_prompt_section.count(
        "Use Image 1 and Image 2 only as fixed visual references."
    ) == 7
    assert v6_prompt_section.count("exact square 1024 by 1024 RGB image") == 7
    v6_prompt_flat = " ".join(v6_prompt_section.split())
    assert v6_prompt_flat.count("safe box [160,160,864,864]") == 7
    assert v6_prompt_flat.count("inside [160,160,864,864]") == 7
    for expected_box in (
        "content box [7,5,25,17]",
        "content box [9,4,23,18]",
        "content box [8,4,24,18]",
        "content box [7,6,25,16]",
        "content box [7,5,24,17]",
        "content box [8,7,24,16]",
    ):
        assert expected_box in seals_work, f"missing V6 runtime contract: {expected_box}"
    require(
        seal_motifs_v6_candidate_reviewer,
        (
            "Review one QS-B1 V6 independent single-object motif candidate",
            "edge_connected_chroma_key",
            "whole-square proportional LANCZOS to 1024x1024",
            "visible_bbox_inside_safe_box",
            "visible_green_spill_is_zero",
            "runtime_bbox_inside_content_box",
            "one production candidate + six V16",
            '"source_written": False',
            '"runtime_written": False',
            '"addon_changed": False',
        ),
        "QS-B1 V6 independent motif deterministic candidate reviewer",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-A attempt 1 execution and review",
            "019fd57b-306b-7f70-80f9-cd5dd97c2cfc",
            "1156d694bc5a6d9d12841571bbd878c257b7b7d8422f5dbc8e9d02752211e354",
            "bbox `[153,147,887,839]`",
            "封闭绿色残留 `275`",
            "实物羽毛笔",
            "internal-rejected / repair-prepared / P3 / 1/5",
            "禁止把 attempt 1 作为 Image 3",
            "QS-B1 V6-A.r1 complete production Prompt — repair-prepared / frozen",
            "flat bitmap pigment sprite source",
            "must be no larger than 576 pixels wide by 384 pixels high",
            "create any enclosed hole",
        ),
        "QS-B1 V6-A attempt 1 rejection and complete r1 repair gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-A attempt 2 execution and review",
            "019fd587-b49b-7dd1-af7c-ace29f57eadd",
            "fce2a9d6041849fd777847c13c3add58fc596dd1efa66d28c291dddd84d6e431",
            "bbox `[219,192,819,797]`",
            "可见绿色污染 `316`",
            "median\n  `[206,149,63]`",
            "internal-rejected / repair-prepared / P3 / 2/5",
            "禁止把 attempt 2\n  作为 Image 3",
            "QS-B1 V6-A.r2 complete production Prompt — repair-prepared / frozen",
            "two-dimensional woodblock-transfer pigment glyph",
            "no larger than 560 pixels wide by 360 pixels high",
            "dominant dark muted umber-ochre approximately RGB [116,78,39]",
            "The entire interior of the connected",
            "glyph must remain pigment colored",
        ),
        "QS-B1 V6-A attempt 2 rejection and complete r2 repair gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-A attempt 3 execution and internal pass",
            "019fd58d-832d-7641-855c-47ed7fb1c4d5",
            "c57c3eac4a145af55b20ea4c541d7032d621edc983cc92bed45b376f5faf2deb",
            "bbox `[165,193,835,792]`",
            "可见绿色污染 `0`",
            "自动 `9/9 pass`",
            "median `[121,66,28]`",
            "display-region `6/6 pass`、violations `0`",
            "candidate-reviewed / P3 / production 3/5 / internal-pass",
            "V6-A attempt 4／5 不调用",
            "不写 `assets/source`、runtime、addon",
            "进入 V6-B DETAIL attempt 1",
        ),
        "QS-B1 V6-A internal candidate pass and sequential stop gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-B attempt 1 execution and review",
            "019fd593-536b-7891-bbff-2f17a6b4660c",
            "2a4f1f03eafe2076b1d7c0c894bfb8aba9b835cf760da6bda74290475c787249",
            "bbox `[257,146,773,859]`",
            "可见绿色污染\n  `175333`",
            "现代空心\n  文件图标",
            "internal-rejected / repair-prepared / P3 / 1/5",
            "禁止把 attempt 1 作为 Image 3",
            "QS-B1 V6-B.r1 complete production Prompt — repair-prepared / frozen",
            "compact solid guild-ledger leaf silhouette",
            "exactly two short thick irregular horizontal record strokes",
            "No hollow outline, green interior",
            "between 400 and 480 pixels wide",
        ),
        "QS-B1 V6-B attempt 1 rejection and complete r1 repair gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-B attempt 2 execution and internal pass",
            "019fd599-d573-7993-88d8-eee403b9bffe",
            "8f3f8a9d61bd2617f4ecf7737eb2e845d352d596bdf19cd0a497c634f90cec5c",
            "bbox `[235,176,800,842]`",
            "可见绿色污染 `0`",
            "自动 `9/9 pass`",
            "median `[88,47,18]`",
            "display-region `6/6 pass`、violations `0`",
            "candidate-reviewed / P3 / production 2/5 / internal-pass",
            "V6-B attempt 3／4／5 不调用",
            "进入 V6-C SHOW attempt 1",
        ),
        "QS-B1 V6-B internal candidate pass and sequential stop gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-C attempt 1 execution and review",
            "019fd5a6-0a3b-7b40-8d16-a19e63c82998",
            "772425fc98efc3f8ff035ee8925a9f6b879fce9006a419e8b34a0e273a69ec16",
            "bbox `[117,104,910,917]`",
            "可见绿色污染 `335`",
            "四尖星／金属徽章",
            "median `[222,164,40]`",
            "internal-rejected / repair-prepared / P3 / 1/5",
            "QS-B1 V6-C.r1 complete production Prompt — repair-prepared / frozen",
            "four short,",
            "broad, blunt brush wedges",
            "small solid central pigment pool",
            "No sharp diamond point, spearhead, arrowhead, four-point star",
            "between 400 and 480 pixels wide",
        ),
        "QS-B1 V6-C attempt 1 rejection and complete r1 repair gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-C attempt 2 execution and review",
            "019fd5b0-da65-7861-a2ab-2fe98871652a",
            "61e144845b8c8b2e2d6409d60625f9abe7db98a40867fc76651390b455fdeed9",
            "bbox `[153,135,867,845]`",
            "可见绿色污染 `0`",
            "自动 `8/9`",
            "五个互不连接的对象",
            "internal-rejected / repair-prepared / P3 / 2/5",
            "QS-B1 V6-C.r2 complete production Prompt — repair-prepared / frozen edit",
            "only",
            "edit-identity input",
            "Uniformly scale the complete Image-3 mark down",
            "exactly four short thick irregular pigment bridges",
            "No sharp diamond point, spearhead, arrowhead, four-point star, crosshair, D-pad",
        ),
        "QS-B1 V6-C attempt 2 local edit repair gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-C attempt 3 execution and internal pass",
            "019fd5bc-0011-78b1-9e15-ad57c5e0c1b8",
            "af709d4b31bf291e6cced744604cce1f25649953335679a3b7ba0977447a39a2",
            "bbox `[155,152,860,859]`",
            "左侧\n  仅越 `5px`、顶部仅越 `8px`",
            "可见绿色污染 `0`",
            "四条短粗深褐桥",
            "用户在整批授权中明确允许“等比 bbox-fit”",
            "display-region `6/6 pass`、violations `0`",
            "internal-pass with authorized\n  deterministic bbox-fit exception",
            "V6-C attempt 4／5 不调用",
            "进入 V6-D HIDE attempt 1",
        ),
        "QS-B1 V6-C internal candidate pass with authorized bbox-fit gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-D attempt 1 execution and review",
            "019fd5c7-85eb-75d1-bbc5-204868cc953d",
            "841ff0e130b2183c80a910e98d1fa288d6e605406d1a32d95d0e041e6a0df6b5",
            "bbox `[195,161,830,843]`",
            "可见绿色污染 `160`",
            "median `[211,142,46]`",
            "明亮金色倒角",
            "internal-rejected / repair-prepared / P3 / 1/5",
            "attempt 1 禁止作为 Image 3",
            "QS-B1 V6-D.r1 complete production Prompt — repair-prepared / frozen",
            "four short,\nbroad, blunt, slightly unequal pigment wedges",
            "Across only the central sixty percent",
            "dominant dark muted umber-ochre near RGB [116,78,39]",
            "No sharp diamond point, spearhead, arrowhead, four-point star",
            "计为 V6-D `1/5`、整批 `9/35`",
            "文件落位流程错误：child 首次把 provider 元数据占位名",
        ),
        "QS-B1 V6-D attempt 1 rejection and complete r1 repair gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-D attempt 2 execution and review",
            "019fd5d0-5cb0-7ec1-b065-2423ab9535c6",
            "cd44ae6e34837b08f2b3119f0f11a719348cf897d2c88133e4b7c87d0a59b680",
            "bbox `[222,204,818,808]`",
            "可见绿色污染 `20`",
            "median `[106,55,21]`",
            "右上墨带末端",
            "internal-rejected / repair-prepared / P3 / 2/5",
            "QS-B1 V6-D.r2 complete production Prompt — repair-prepared / frozen edit",
            "only\nedit-identity input",
            "ONLY ALLOWED REPAIR",
            "near normalized box [717,362,720,366]",
            "near [607,609]",
            "near [360,705]",
            "Do not invent a fifth repair zone",
            "计为 V6-D `2/5`、整批 `10/35`",
        ),
        "QS-B1 V6-D attempt 2 local green cleanup edit gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-D attempt 3 execution and review",
            "019fd5d8-4ae9-7111-a803-f374776874a7",
            "b0e91e52b402c724d8be5085bddec2d7925b35008ddef470fba3b2c5d6255698",
            "bbox `[222,204,817,808]`",
            "绿色污染由 `20` 降至 `12`",
            "median\n  `[101,35,8]`",
            "右上墨带末端\n  `[713,361,715,364]`",
            "左下墨带末端 `[344,631,347,634]`",
            "internal-rejected / repair-prepared / P3 / 3/5",
            "QS-B1 V6-D.r3 complete production Prompt — repair-prepared / frozen edit",
            "only\nedit-identity input",
            "ONLY ALLOWED REPAIR: TWO TINY GREEN CLUSTERS",
            "five pixels at the upper-right",
            "seven pixels at the lower-left",
            "计为 V6-D `3/5`、整批 `11/35`",
        ),
        "QS-B1 V6-D attempt 3 two-cluster cleanup edit gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-D attempt 4 execution and review",
            "019fd5de-78a1-7661-af36-73f89e214e7c",
            "e5cb30bf52425378b45bd33dd202a738494ed9cfb5c709e354ed6f42159a9955",
            "bbox `[215,194,833,823]`",
            "绿色污染由 `12` 反增至 `22`",
            "median `[87,27,10]`",
            "[725,356,727,359]` 6px",
            "[341,632,351,643]` 13px",
            "internal-rejected / repair-prepared / P3 / 4/5",
            "QS-B1 V6-D.r4 complete production Prompt — repair-prepared / frozen final edit",
            "only\nedit-identity input",
            "HARD FREEZE OUTSIDE FOUR REPAIR BOXES",
            "ONLY ALLOWED REPAIR: FOUR MICRO INPAINT BOXES",
            "twenty-two green-like defect pixels",
            "计为 V6-D `4/5`、整批 `12/35`",
        ),
        "QS-B1 V6-D attempt 4 final four-box edit gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-D attempt 5 pre-generation flow error E1",
            "019fd5e4-a449-7483-b338-66a6154e0b50",
            "ModuleNotFoundError: No module named 'PIL'",
            "936ebacda3291c5fd8ad0f0862860802f7655c4b99ebb06f9b2698720ba18de2",
            "不是 provider ImageGen 结果",
            "不复制进仓库、不进入候选审查",
            "V6-D 保持 `4/5`",
            "流程错误由 `1` 增至 `2`",
            "必须调用一次 fixed child 的内建 `image_gen`",
        ),
        "QS-B1 V6-D attempt 5 non-counting local-script flow error",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-D attempt 5 execution, review, and exhausted stop",
            "019fd5eb-38b7-7392-a7b3-461f6271e6fc",
            "built-in\n  `image_gen` completed",
            "d03f436e5c631a2989e9a1a6206b23f9a20a958f9f471537bab79938aec634e0",
            "bbox `[210,188,844,835]`",
            "污染由 attempt 4 的 22 降为 `9`",
            "median\n  `[70,22,7]`",
            "attempt 2 是五稿中配色与重量最均衡",
            "candidate-rejected / repair-budget-exhausted / P3 / production 5/5",
            "不得执行 attempt 6",
            "进入 V6-E CLEAN attempt 1",
            "正式计为 V6-D `5/5`、整批 `13/35`",
            "V6-D 流程错误 `3`、全批流程错误 `5`",
        ),
        "QS-B1 V6-D exhausted stop and V6-E continuation gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-E attempt 1 execution and review",
            "019fd5f2-cf80-7be1-9c2c-35686dbc9fad",
            "187dd5aeae3d25e86ae4b9861590ee7707153613921d4633acfc10de87bd4db8",
            "bbox `[178,279,859,751]`",
            "可见绿色\n  污染 `556`",
            "median `[178,136,60]`",
            "明亮赭金",
            "internal-rejected / repair-prepared / P3 / 1/5",
            "attempt 1 禁止作为 Image 3",
            "QS-B1 V6-E.r1 complete production Prompt — repair-prepared / frozen",
            "exactly three separate\nshort broad blunt unequal cartographic trail strokes",
            "dominant dark muted umber-ochre near RGB [112,72,35]",
            "No broom, brush object, wind, waves, water, speed line",
            "计为 V6-E `1/5`、整批 `14/35`",
        ),
        "QS-B1 V6-E attempt 1 rejection and complete r1 repair gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-E attempt 2 execution and review",
            "019fd5fb-7e45-7ff0-b5c3-f93f90646758",
            "fd8d04aec4415c7fceac84cfc51ee64f406a36e4c589600bc1e7a4e1b1a8d79c",
            "bbox `[146,242,879,783]`",
            "可见绿色污染 `0`",
            "median `[100,50,6]`",
            "三条有厚度的旧皮革／木片",
            "缩到真实\n  `14×10px`",
            "internal-rejected / repair-prepared / P3 / 2/5",
            "attempt 2 禁止作为 Image 3",
            "QS-B1 V6-E.r2 complete production Prompt — repair-prepared / frozen",
            "EMBLEM ANATOMY: THREE FLAT IRREGULAR STAMP-BLOTS",
            "NEVER PHYSICAL STRIPS",
            "V6-E `2/5`、整批 `15/35`",
        ),
        "QS-B1 V6-E attempt 2 rejection and complete r2 repair gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-E attempt 3 prompt-transport failure, generation, and rejection",
            "019fd605-e45e-70f2-a695-204e07828171",
            "user block 只包含空 `$imagegen`",
            "b5148670e9c277efd90a19c08c122c6f830e70c075ebd006e13fcf9bced4ee08",
            "1509×1042 RGB",
            "V6 independent raw must be square before normalization",
            "完整双页任务书 UI",
            "计为 V6-E `3/5`、整批 `16/35`",
            "V6-E 流程错误 `1`、\n  全批流程错误 `6`",
            "不得作为 Image 3",
            "attempt 4 必须重试完全相同的 V6-E.r2 正文",
            "9849fd88943d79c0f1151b4a7cb3bd0e19fa5c3596a4edaed46907d7736be80c",
        ),
        "QS-B1 V6-E counted prompt-transport generation and frozen retry gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-E attempt 4 execution and review",
            "019fd60c-7742-79d3-a4df-42da211168cc",
            "dc10437ba22797a639df9f63556133012ec4766a66caec3a9b7b292d948c8a76",
            "bbox `[128,147,920,897]`",
            "visible_green_spill_is_zero",
            "median `[102,50,26]`",
            "`792×750px`",
            "`11×10px`",
            "internal-rejected / repair-prepared / P3 / 4/5",
            "attempt 4 禁止作为 Image 3",
            "QS-B1 V6-E.r3 complete production Prompt — repair-prepared / frozen",
            "WIDE-AND-SHALLOW SILHOUETTE IS THE PRIMARY CONTRACT",
            "visible width-to-height ratio must remain between 2.20 and 2.70",
            "V6-E `4/5`、整批 `17/35`",
        ),
        "QS-B1 V6-E attempt 4 rejection and final r3 repair gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-E attempt 5 execution, review, and exhausted stop",
            "019fd614-253c-7b71-adea-0eaaad77f617",
            "6f85cef0c106ab8efa769b3d08c3fed87780d58262eaa8b211412af4a4ac9eb9",
            "bbox `[115,316,922,725]`",
            "median `[99,47,13]`",
            "`18×9px`",
            "三条菜单横栏",
            "candidate-rejected / repair-budget-exhausted / P3 / production 5/5",
            "不得执行 attempt 6",
            "进入 V6-F RESET attempt 1",
            "V6-E `5/5`、整批 `18/35`",
        ),
        "QS-B1 V6-E exhausted stop and V6-F continuation gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-F attempt 1 execution and review",
            "019fd61c-4f89-7320-959c-17d6e111e298",
            "8142a8fdc474fd71efc63d92fd9612f98674677b9404735da3b3bef3b52423b3",
            "bbox `[185,213,845,817]`",
            "可见绿色\n  污染 `264`",
            "median\n  `[214,170,94]`",
            "字母 g／旋涡",
            "internal-rejected / repair-prepared / P3 / 1/5",
            "attempt 1 禁止作为 Image 3",
            "QS-B1 V6-F.r1 complete production Prompt — repair-prepared / frozen",
            "OPEN HAIRPIN ROUTE, NOT A SPIRAL",
            "V6-F `1/5`、整批 `19/35`",
        ),
        "QS-B1 V6-F attempt 1 rejection and complete r1 repair gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-F attempt 2 execution and review",
            "019fd626-a043-7912-9b5f-d7c1826288e3",
            "f19199c05a91c8b1239c4933fec9db9f19dad640b9a7c7211b27bc211531bc4f",
            "bbox `[141,201,908,828]`",
            "可见绿色污染 `0`",
            "median `[123,60,21]`",
            "问号／字母 C／耳机",
            "internal-rejected / repair-prepared / P3 / 2/5",
            "attempt 2 禁止作为 Image 3",
            "QS-B1 V6-F.r2 complete production Prompt — repair-prepared / frozen",
            "ANGULAR OPEN EXPEDITION ROUTE",
            "V6-F `2/5`、整批 `20/35`",
        ),
        "QS-B1 V6-F attempt 2 rejection and complete r2 repair gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-F attempt 3 execution and review",
            "019fd631-accb-73b0-9510-936ef404b0e1",
            "9cef1b91e42c97ab3b76224a166452367e795699d860ac2907f478c67176c876",
            "bbox `[86,239,940,780]`",
            "可见绿色污染 `26`",
            "median `[121,59,25]`",
            "左向 undo 箭头",
            "internal-rejected / edit-prepared / P3 / 3/5",
            "QS-B1 V6-F.r3 complete production Prompt — edit-prepared / frozen",
            "HARD FREEZE OUTSIDE TWO REPAIR BOXES",
            "Inside normalized [410,520,690,770]",
            "Inside normalized [278,369,294,386]",
            "V6-F `3/5`、整批 `21/35`",
        ),
        "QS-B1 V6-F attempt 3 local edit gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-F attempt 4 execution and review",
            "019fd641-e81b-74a0-8f49-af4bec06925b",
            "37b95d2965f28795ee21e39d9fd6e41a92f5e55a47cb0c7eca770a30eb988b11",
            "bbox `[86,239,940,779]`",
            "可见绿色污染 `0`",
            "mask 异或 `1246`px",
            "158250",
            "internal-rejected / fresh-final-prepared / P3 / 4/5",
            "attempt 4 违反\n  冻结边界",
            "QS-B1 V6-F.r4 complete production Prompt — fresh-final-prepared / frozen",
            "OPEN ANGULAR OUT-AND-BACK EXPEDITION ROUTE",
            "Do not upload, inspect, edit, trace, imitate, or reuse V6-F attempts 1 through 4",
            "V6-F `4/5`、整批 `22/35`",
        ),
        "QS-B1 V6-F attempt 4 freeze rejection and final fresh gate",
    )
    require(
        seals_work,
        (
            "QS-B1 V6-F attempt 5 pre-generation flow error E1",
            "8e19cec",
            "a37ad7cbf84aff6d234809877aad96b0b141e78cbe5ace5a0d8f9ff873b910ba",
            "npm error code EPERM",
            "https://registry.npmjs.org/@openai%2fcodex failed",
            "没有 child session、内建 `image_gen` tool call、provider result 或图片",
            "全批流程错误第 `7` 次、F 段第 `1` 次",
            "V6-F\n  仍为 `4/5`，整批仍为 `22/35`",
        ),
        "QS-B1 V6-F final-attempt non-counting npm flow error",
    )
    require(
        seal_motifs_v5_candidate_reviewer,
        (
            "CANVAS = (1024, 1024)",
            "ACTIONS:",
            "edge_connected_chroma_key",
            "all_visible_pixels_stay_inside_safe_boxes",
            "eighth_cell_is_empty",
            "write_display_region_contract",
            "seven independent review-only transparent motif crops",
            '"source_written": False',
            '"runtime_written": False',
            '"addon_changed": False',
        ),
        "QS-B1 V5-B deterministic candidate reviewer",
    )
    require(
        progress,
        (
            "QUEST-LOG-SEAL-MOTIFS-SIM-V15 / QS-B1 V5-B",
            "旧赭金矿物颜料与放弃项灰暗酒红",
            "candidate-rejected / repair-budget-exhausted / P3 / production 5/5",
            "自动仍为 `10/12`",
            "禁止\nattempt 6",
        ),
        "QS-B1 V15 accepted direction and exhausted V5-B production gate",
    )
    require(
        progress,
        (
            "QUEST-LOG-SEAL-MOTIFS-SIM-V16",
            "prompt-authorized / P3",
            "production 0/35 authorized",
            "V6-A..G",
            "下一动作是 V6-A attempt 1",
        ),
        "QS-B1 V16 current simulation and next gate",
    )
    require(
        sub_art,
        (
            "普通六项使用哑光、低饱和的旧赭金矿物公会颜料",
            "只有放弃任务使用灰暗、退饱和的旧酒红",
            "用户于 `2026-08-06` 回复“接受”",
            "V15 本地几何纹章像素",
        ),
        "QS-B1 V15 stable motif palette baseline",
    )
    require(
        submodules,
        (
            "candidate-rejected / repair-budget-exhausted / P3 / 5/5",
            "MOTIF.SHARE",
            "哑光低饱和旧赭金矿物颜料",
            "MOTIF.ABANDON",
            "灰暗、退饱和的旧酒红颜料",
        ),
        "QS-B1 V15 motif component ownership",
    )
    require(
        submodules,
        (
            "V6 七张独立 `1024²` 单对象 source",
            "V16",
            "prompt-authorized / P3 / production 0/35 authorized",
            "下一动作是固定执行器从 V6-A attempt 1 开始",
        ),
        "QS-B1 V16 stable ownership update",
    )
    require(
        seal_substrate_v5_candidate_reviewer,
        (
            "NORMALIZED_SIZE = (1024, 1024)",
            "MASK_SCALE = 4",
            "def build_mask(",
            'mockup["donor_crop"]',
            "whole-square isotropic LANCZOS",
            "def clear_transparent_rgb(",
            "def render_real_layout(",
            '"exact_detail_previews": previews',
            '"visible_bbox": [0, 0, 128, 696]',
            '"source_written": False',
            '"addon_changed": False',
        ),
        "QS-B1 V5-A deterministic donor candidate reviewer",
    )
    qs_b1_source_path = (
        ROOT
        / "assets"
        / "source"
        / "quests"
        / "qs-b1"
        / "QuestLogSealMenuSubstrate_Master_v1.png"
    )
    qs_b1_source_manifest = json.loads(
        qs_b1_source_path.with_name(
            "QS-B1_SourceManifest_v1.json"
        ).read_text(encoding="utf-8")
    )
    qs_b1_source_bytes = qs_b1_source_path.read_bytes()
    assert qs_b1_source_bytes[:8] == b"\x89PNG\r\n\x1a\n"
    assert struct.unpack(">II", qs_b1_source_bytes[16:24]) == (128, 696)
    assert hashlib.sha256(qs_b1_source_bytes).hexdigest() == (
        "6b3207f15d961cbef7471399c9bfb725b475385ce9e66648fc435a9e28111d9c"
    )
    assert qs_b1_source_manifest["status"] == "accepted-source"
    assert qs_b1_source_manifest["accepted_on"] == "2026-08-06"
    assert qs_b1_source_manifest["source"]["width"] == 128
    assert qs_b1_source_manifest["source"]["height"] == 696
    assert qs_b1_source_manifest["source"]["mode"] == "RGBA"
    assert qs_b1_source_manifest["source"][
        "visible_bbox_exclusive"
    ] == [0, 0, 128, 696]
    assert qs_b1_source_manifest["source"][
        "transparent_rgb_nonzero_values"
    ] == 0
    assert qs_b1_source_manifest["source"][
        "visible_green_dominant_pixels"
    ] == 0
    assert qs_b1_source_manifest["provenance"][
        "generation_session"
    ] == "019fd280-29b2-7be0-add6-f601f2e391d3"
    assert qs_b1_source_manifest["provenance"][
        "actual_imagegen_calls"
    ] == 4
    assert qs_b1_source_manifest["provenance"][
        "unused_calls_after_internal_pass"
    ] == 1
    assert qs_b1_source_manifest["deterministic_derivation"][
        "crop_xyxy"
    ] == [448, 164, 576, 860]
    assert qs_b1_source_manifest["deterministic_derivation"][
        "mask_scale"
    ] == 4
    assert qs_b1_source_manifest["user_acceptance"][
        "exact_statement"
    ] == "接受"
    assert qs_b1_source_manifest["export_contract"]["status"] == (
        "pending-runtime-export"
    )
    assert qs_b1_source_manifest["export_contract"][
        "runtime_file"
    ] is None
    assert not (
        ROOT / "handoff" / "quests" / "QS-B1-V5-A"
    ).exists()
    require(
        seals_work,
        (
            "QS-B1 V5-A 布面供体＋确定性轮廓蒙版",
            "source-accepted / P4 / production 4/5",
            "不走figma, 直接下一步",
            "ImageGen 只负责\n  连续旧布表面",
            "固定裁片",
            "accepted source",
            "QS-B1 V5-A 最终 production prompt — 已授权冻结",
            "This output is NOT a ribbon sprite",
            "[448,164,576,860]",
            "exactly two short, broad, broken dim fold planes",
            "No outer silhouette, narrow ribbon object",
            "流程错误单列且不占额度",
            "禁止 attempt 6",
            "V5-A 正式 production 授权与执行冻结点",
            "确认授权 QS-B1 V5-A 最终 production 正文",
            "review_quest_seal_menu_substrate_donor_candidate_v1.py",
            "最高只到\n  `candidate-reviewed / P3`",
            "019fd242-8cb6-7a22-b110-763fbc8f66b7",
            "ig_072c3f1feddefde3016a73446255608191bf9f1dbc559f5c5c.png",
            "c313ca608921189396b9c72c10bbfbe10be8c2c30373a92d1f05016dd966c45f",
            "b64cce638e1f8f7ec86b0bce0baca3006e534b9899989ae282ae9acdf6e5e9b9",
            "automated `18/18 pass`、真实六态布局 `29/29 pass`",
            "display-region report SHA",
            "uniform microtexture",
            "QS-B1 V5-A.r1 完整修复执行正文",
            "Image 3 is the immediately preceding donor",
            "one centered near y = 254 and one centered near y = 696",
            "current bright bands near normalized y = 388 and y = 564",
            "repair-prepared / P3 / 1/5",
            "019fd25a-b613-76b1-a261-7283d11d7cb0",
            "ig_0e43b77fb0420fbe016a734b4bf508819181f5b7d77b66ee07.png",
            "7ca5117006ce6d5712f30deb5d785f25013394bb7add85ad5d9aaf00023cdca9",
            "00d3fd1f6e44de0b6f93b140a04ed0b69fdf1717ad8ce05befebcb3e2663d736",
            "相同首要失败连续两稿出现",
            "QS-B1 V5-A.r2 完整修复执行正文",
            "There is no Image 3 in this regenerate operation",
            "At 100%\nsource scale there is no small repeated surface information",
            "Paint exactly two broad low-frequency folds",
            "Plane A occupies approximately x = 462..512",
            "repair-prepared / P3 / 2/5",
            "019fd269-f89a-71d0-80c1-a1a0d43f7ac7",
            "ig_0cb7a53f8e02d243016a734e75abe481919ae891b494117576.png",
            "12c2e3f2f346b9196c7a74043a532a95811ee82c00b156b937751353ee679c4d",
            "0d83940a6d0e59e475212388ab349ea81dc13ccd0a2b6ae321de2ef6c6094a4b",
            "两个冻结局部 dim plane",
            "QS-B1 V5-A.r3 完整修复执行正文",
            "Image 3 is the immediately preceding donor and the only edit identity input",
            "For the upper event, repaint the corridor x = 448..575, y = 228..280",
            "For the lower event, repaint the corridor x = 448..575, y = 670..722",
            "repair-prepared / P3 / 3/5",
            "V5-A attempt 4 执行与终局内审",
            "019fd280-29b2-7be0-add6-f601f2e391d3",
            "ig_035225c26a2a6a2e016a73541a34fc8191b106a0260947befe.png",
            "c9ffcc8f1e19977ff10abdeeb9d0f7554cfab02c99768b83c219516d54a9beb1",
            "6b3207f15d961cbef7471399c9bfb725b475385ce9e66648fc435a9e28111d9c",
            "0cf326a54cab55330e9d99df8f05912910a16f79150d26b46d56707e3ff168b2",
            "npm cache `EPERM`",
            "无生成证据的流程错误，不占额度",
            "automated `18/18 pass`、真实六态布局 `29/29 pass`",
            "`6/6 pass`、violations `0`",
            "attempt 5 未调用",
            "V5-A 用户接受与 P4 晋级",
            "用户决定：`2026-08-06` 回复“接受”",
            "assets/source/quests/qs-b1/QuestLogSealMenuSubstrate_Master_v1.png",
            "跨设备检查点：`handoff/quests/QS-B1-V5-A/` 已在 accepted source 与 manifest",
            "尚未发生：runtime 缩放／TGA 导出",
        ),
        "QS-B1 V5-A source acceptance gate",
    )
    require(
        progress,
        (
            "QUEST-LOG-SEAL-SUBSTRATE-SIM-V14 / QS-B1 V5-A",
            "ImageGen 未来只负责全幅连续暗旧布面 donor",
            "source-accepted / P4 / production 4/5",
            "attempt 4\n以固定 Image 1／2＋紧邻 attempt 3 raw",
            "完整美术内审",
            "流程错误 `1`",
            "attempt 5 未调用",
            "QuestLogSealMenuSubstrate_Master_v1.png",
            "跨设备 handoff 已消费",
            "此次接受只覆盖空白连续布底",
        ),
        "QS-B1 V5-A accepted source progress gate",
    )
    require(
        seals_work,
        (
            "接受, 用这一套试试效果",
            "menu V4-A\n  `candidate-rejected / repair-budget-exhausted / P3`",
            "QS-B1 V4-A ImageGen：`5/5`",
            "QS-B1 V4-A 暗色非规则动态空白布底",
            "`prompt-prepared / awaiting-production-authorization / P2`",
            "03dc589abad7187c478ec484cc6565f2c16d2ce52d2d6421251a4de6437453bd",
            "91f9fece41ed375df1fa32e94b18797cbb280c0b5e99478862473589c671edd5",
            "@openai/codex@0.143.0",
            "exactly two unequal coarse blunt upward notches",
            "Do not fill the surface with photographic burlap, uniform weave",
            "y = 212, 300, 388, 476, 564, 652, 740, or 828",
            "production 最终为 `5/5`",
            "纵横比相对 `128:696` 的误差不超过 `1%`",
            "display-region 必须 `6/6`、violations `0`",
            "确认授权 QS-B1 V4-A",
            "授权时子状态：`prompt-authorized / P3`",
            "流程错误 `1`",
            "No prompt provided via stdin.",
            "只在最后一个 `-i` 后加入标准 `--` 参数分隔符",
            "流程错误，不占额度；仍为 `0/5`",
            "019fd163-9fff-7152-aa3c-81334d3b9784",
            "3fdc52c3a061e2d6337ff37cfea31ecdc09543b1ef61ecf817164d29d789e97f",
            "误差 `68.882%`",
            "internal-rejected / 1/5",
            "QS-B1 V4-A.r1 完整修复执行正文",
            "The height is exactly 5.4375 times the width",
            "no individually resolved weave",
            "No notch may exceed 18 source pixels in depth",
            "不使用 attempt 1 作为 Image 3",
            "019fd169-707b-7642-a2e5-6130e64d2c68",
            "fd15d4c27f6050fd7faf6e6824bab0c9f641b966f8df2edef6b04d6bfb85e271",
            "误差 `66.961%`",
            "internal-rejected / 2/5",
            "QS-B1 V4-A.r2 完整修复执行正文",
            "The cloth occupies only 12.5% of canvas width and 68% of canvas height",
            "Leave huge pure-green margins",
            "This is a flat hand-painted UI sprite, not photographed fabric",
            "不上传 attempt 2 或任何旧候选",
            "019fd16f-2f9d-7e61-96e3-4dff4331d68b",
            "74cb222c5d17e107ef25db269da05e79bc8a5638408f332e0828433baac4f22b",
            "误差从 `66.961%`\n  降至 `31.009%`",
            "internal-rejected / 3/5",
            "QS-B1 V4-A.r3 完整修复执行正文",
            "This is not\na scene, close-up, banner presentation, photograph, paper strip or illustration",
            "No folded corner, dog-ear, rolled edge",
            "attempt 3 不作为 Image 3",
            "019fd175-0f3d-7553-8e32-53df867a828b",
            "a3c611463bf7050e2ccc2f304f0ce4989a0730be6723f1f625495581468dd396",
            "误差 `28.845%`",
            "internal-rejected / 4/5",
            "QS-B1 V4-A.r4 完整修复执行正文",
            "At every horizontal scanline the cloth is no wider than 128 pixels",
            "The green negative space must visually dominate the image",
            "attempt 4 不作为 Image 3",
            "禁止\n  attempt 6",
            "019fd17b-35fe-7d01-ba81-cfd857a8129e",
            "e2c3a3d46ddbf4a2de63fcd1bb3c1f271c93d04e3dbcb3c658a82e037d6a1b19",
            "`176×892px`",
            "`7.287%`",
            "`128×649px`",
            "`5/9 pass`",
            "8608743b3670ec2c32c9cd12b969f8079c9ad2594ef125906a3d8a7e02d86103",
            "54bbe35787acce5519f8fc94877a4425285d8198ca8170aceba807ebe9df8856",
            "candidate-rejected / repair-budget-exhausted / P3 / 5/5",
        ),
        "QS-B1 V4-A accepted simulation and production authorization gate",
    )
    require(
        progress,
        (
            "`candidate-rejected / repair-budget-exhausted / P3 / 5/5`",
            "V4-A 完整 production",
            "五次实际 ImageGen 已执行并耗尽",
            "获用户独立生产授权",
        ),
        "QS-B1 V4-A progress gate",
    )
    require(
        sub_art,
        (
            "低饱和烟熏深旧棕",
            "三块大明暗",
            "两段断续暗亮面",
            "尾端恰好\n两处不等宽、粗钝、浅上收缺口",
            "V13 的暗色、非周期宽边与\n双钝缺口 V4-A 方向",
        ),
        "QS-B1 V4-A stable art baseline",
    )
    require(
        submodules,
        (
            "V5-A attempt 4 composite 已于 `2026-08-06` 作为空白布底 source 接受",
            "QuestLogSealMenuSubstrate_Master_v1.png",
            "runtime 最大母版仍为 `32×174px`",
            "综合色为低饱和烟熏深旧棕",
            "尾端恰好两处不等宽、粗钝、浅上收缺口",
            "当前 `source-accepted / P4`，尚未导出或挂载",
        ),
        "QS-B1 V5-A accepted substrate component ownership",
    )
    require(
        seals_work,
        (
            "QS-B1 V2 用户终止与 V3 分层改向",
            "user-superseded-before-attempt-5 / 4/5",
            "attempt 5 **没有调用**",
            "QUEST-LOG-SEAL-ACTIONS-SIM-V12",
            "动态空白旧布底＋七个独立透明纹章",
            "本地几何与交互检查 `35/35 pass`",
            "`6/6 pass`、violations `0`",
            "`hidden` 从 visible order 中移除",
            "disabled",
            "纹章重新烘焙进背景",
            "未来\nImageGen 输入",
        ),
        "QS-B1 V2 terminal record and V3 simulation gate",
    )
    require(
        progress,
        (
            "QUEST-LOG-SEAL-ACTIONS-SIM-V12 / QS-B1 V3",
            "candidate-rejected / user-superseded-before-attempt-5 / 4/5",
            "`35/35 pass`",
            "display-region `6/6 pass`",
            "ImageGen `0/0`",
        ),
        "QS-B1 V3 progress",
    )
    require(
        sub_art,
        (
            "背景和七枚纹章烘焙进一张连续母版",
            "第\n`4/5` 次后明确改向",
            "连续最大长度空白布母版",
            "七个功能各有一张透明纹章\nsource",
            "非周期污渍",
            "独立 `±1px` 视觉重心",
            "hidden 项从 visible order 中移除",
        ),
        "QS-B1 V3 art and ownership baseline",
    )

    quest_adapter = (
        ROOT
        / "addon"
        / "AzerothExpeditionUI"
        / "Modules"
        / "Quests.lua"
    ).read_text(encoding="utf-8")
    quest_theme = (
        ROOT
        / "addon"
        / "AzerothExpeditionUI"
        / "Modules"
        / "QuestVisualTheme.lua"
    ).read_text(encoding="utf-8")
    require(
        quest_theme,
        (
            'contract = "1.8"',
            "QuestLogShellV4",
            "QuestLogDirectoryMarksV1",
            "QuestTrackerPaperV1",
            "QuestToolWaxSealStatesV1",
            "LXGWWenKaiGB-Medium.ttf",
            "NotoSerifSC-SemiBold.ttf",
            "difficulty",
            "questType",
            "|cff2f1236",
            "|cff291d00",
            "complete",
            "incomplete",
            "leather",
            "providerPanelHeight = 16",
            "bottomContentPadding = 16",
            "trackerQuestName",
            "providerOwned = true",
            "fallbackPath",
            'flags = ""',
            "hideEntryIcons = true",
            "size = 12",
        ),
        "shared quest visual theme",
    )
    require(
        quest_adapter,
        (
            'Quests.runtimeContract = "1.25"',
            "ApplyTrackerProviderFont",
            "ResolveQuestNameInk",
            "ApplyDirectoryTypography",
            "DETAIL_INLINE_MONEY_TEXT_NAMES",
            '"QuestLogSpacerFrame"',
            "LayoutRewardGroup",
            "AnchorRewardHeading",
            "ReadQuestLogRewardMoney",
            "EnsureRewardSlotContainer",
            "SuppressRewardSurface",
            "CountVisibleRewardItems",
            "GetRewardGroupTopGap",
            "native-container-acyclic-visible-fallback-gap-8",
            "NormalizeDirectoryInlineStatus",
            "ResolveRenderedDirectoryTagInk",
            "LockDirectoryTagInk",
            "RestoreDirectoryTagInk",
            '"questLogTitleLeave"',
            "ResolveDirectoryStatusInks",
            "pfUI.font_default",
            "addon.questVisualTheme",
            "ApplyPfQuestTrackerPaper",
            "ApplyPfQuestTrackerEntryTheme",
            "InstallPfQuestTrackerEntryThemeHooks",
            "ApplyPfQuestTrackerContentSafeHeight",
            "aeuiQuestVisualThemeDirty",
            "aeuiQuestBottomContentPadding",
            "SuppressPfQuestTrackerEntryIcon",
            "aeuiQuestEntryIconThemeContract",
            "ApplyDetailTextTheme",
            "aeuiQuestVisualThemeContract",
            "aeuiQuestPaperSlices",
            "EnsureQuestLogChromeSeal",
            "EnsurePfQuestTrackerHubSeal",
            "SetClampRectInsets",
            "0.66015625",
            "0.90625",
            "DIRECTORY.rowCount",
            "local CONTROL",
            "QuestLogTitleButtonTemplate",
            "FauxScrollFrame_GetOffset",
            "rowCount = 18",
            "providerRowCeiling = 23",
            "rowWidth = 246",
            "rowHeight = 18",
            "textWidth = 226",
            "CaptureAndHideNativeTextures",
            "SuppressNativeRowSelection",
            "HideCollapseAllButton",
            "aeuiQuestCollapseSuppressed",
            "StyleLeatherButton",
            "UpdateActionButtonStates",
            "HideDetailScrollbar",
            "HideListScrollbar",
            "InstallListMouseWheel",
            "InstallDetailMouseWheel",
            "QuestLogDetailScrollFrameScrollBar",
            "EnableMouseWheel(true)",
            "ApplyDetailTextGeometry",
            "ApplyDetailRewardGeometry",
            "MeasureDetailContentHeight",
            "UpdateDetailScrollChildHeight",
            "rewardSlotWidth = 108",
            "rewardSlotHeight = 41",
            "rewardColumnGap = 8",
            "rewardRowGap = 4",
            "rewardSectionGap = 5",
            "rewardNameWidth = 64",
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
    assert '"OnEnable"' not in quest_adapter
    assert '"OnDisable"' not in quest_adapter
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
