#!/usr/bin/env python3
"""Static repository, runtime, and compact-document contract checks."""

from __future__ import annotations

import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "addon"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def assert_toc_paths(toc: Path) -> None:
    for raw_line in toc.read_text(encoding="utf-8-sig").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("##"):
            continue
        path = toc.parent / Path(line.replace("\\", "/"))
        assert path.is_file(), f"{toc.relative_to(ROOT)} references missing {line}"


def assert_xml_includes(xml: Path) -> None:
    source = xml.read_text(encoding="utf-8-sig")
    for include in re.findall(r'<Include\s+file="([^"]+)"', source):
        path = xml.parent / Path(include.replace("\\", "/"))
        assert path.resolve().is_file(), (
            f"{xml.relative_to(ROOT)} references missing {include}"
        )


def assert_markdown_links(markdown: Path) -> None:
    source = markdown.read_text(encoding="utf-8")
    for target in re.findall(r"!?\[[^\]]*\]\(([^)]+)\)", source):
        target = target.strip()
        if target.startswith(("http://", "https://", "mailto:", "#")):
            continue
        if target.startswith("<") and target.endswith(">"):
            target = target[1:-1]
        target = target.split("#", 1)[0]
        if not target:
            continue
        path = (markdown.parent / target).resolve()
        assert path.exists(), (
            f"{markdown.relative_to(ROOT)} links to missing {target}"
        )


def main() -> None:
    pfui = ADDON / "pfUI"
    aeui = ADDON / "AzerothExpeditionUI"
    pfquest = ADDON / "pfQuest"
    pfquest_turtle = ADDON / "pfQuest-turtle"
    assert pfui.is_dir(), "deployable addon/pfUI fork is missing"
    assert aeui.is_dir(), "addon/AzerothExpeditionUI is missing"
    assert pfquest.is_dir(), "addon/pfQuest provider is missing"
    assert pfquest_turtle.is_dir(), "addon/pfQuest-turtle data pack is missing"
    assert not (ROOT / "third-party" / "pfUI").exists()
    assert (pfui / "LICENSE").is_file(), "pfUI MIT license is missing"

    docs = ROOT / "docs"
    modules = ("chat", "quests", "map", "character")
    durable_names = {
        "SUBMODULES.md",
        "ART_BASELINE.md",
        "SUBMODULE_ART_BASELINES.md",
        "PROGRESS.md",
    }
    expected_durable_docs = {"GLOBAL_ART_BASELINE.md", "PROGRESS.md"}
    for module in modules:
        expected_durable_docs.update(
            f"modules/{module}/{name}" for name in durable_names
        )

    actual_docs = {
        path.relative_to(docs).as_posix()
        for path in docs.rglob("*.md")
    }
    work_docs = {
        path
        for path in actual_docs
        if len(path.split("/")) == 4
        and path.startswith("modules/")
        and "/work/" in path
        and path.endswith(".md")
    }
    actual_durable_docs = actual_docs - work_docs
    assert actual_durable_docs == expected_durable_docs, (
        "project docs escaped the compact topology: "
        f"missing={sorted(expected_durable_docs - actual_durable_docs)}, "
        f"extra={sorted(actual_durable_docs - expected_durable_docs)}"
    )
    for path in work_docs:
        assert path.split("/")[1] in modules, (
            f"work document belongs to an unknown module: {path}"
        )
    assert not (ROOT / "prompts").exists(), (
        "standalone prompts tree must be folded into module baselines/work"
    )
    assert not list(docs.rglob("README.md")), (
        "AGENTS.md is the only project-document index"
    )

    agents = (ROOT / "AGENTS.md").read_text(encoding="utf-8")
    for required in (
        "## 当前整体情况",
        "## 唯一文档结构与索引",
        "## 开发边界",
        "run-aeui-asset-workflow",
        "imagegen-0-143-0",
        "P6-C",
        "8.1.0-aeui.4",
    ):
        assert required in agents, f"AGENTS.md missing {required}"
    for path in sorted(expected_durable_docs | work_docs):
        assert f"docs/{path}" in agents, f"AGENTS.md does not index docs/{path}"

    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    for forbidden in (
        "## 当前状态",
        "## 开发入口",
        "## 资产生产规则",
        "工作流",
        "下一门禁",
        "P6-C",
        ".codex/skills",
    ):
        assert forbidden not in readme, (
            f"README contains development/state rules: {forbidden}"
        )

    global_art = (docs / "GLOBAL_ART_BASELINE.md").read_text(encoding="utf-8")
    global_progress = (docs / "PROGRESS.md").read_text(encoding="utf-8")
    assert "可直接继承的全局 Prompt" in global_art
    assert "2004 年前后" in global_art
    assert "imagegen" not in global_progress.lower(), (
        "global progress must not duplicate generation workflow"
    )
    for module in modules:
        module_dir = docs / "modules" / module
        art = (module_dir / "ART_BASELINE.md").read_text(encoding="utf-8")
        sub_art = (
            module_dir / "SUBMODULE_ART_BASELINES.md"
        ).read_text(encoding="utf-8")
        submodules = (module_dir / "SUBMODULES.md").read_text(encoding="utf-8")
        progress = (module_dir / "PROGRESS.md").read_text(encoding="utf-8")
        assert "GLOBAL_ART_BASELINE.md" in art
        assert "ART_BASELINE.md" in sub_art
        assert "pfUI" in submodules
        assert "下一门禁" in progress or "下一步" in progress

    chat_submodules = (
        docs / "modules" / "chat" / "SUBMODULES.md"
    ).read_text(encoding="utf-8")
    for component_id in (
        "CHAT.FRAME.LEFT",
        "CHAT.FRAME.RIGHT",
        "CHAT.INPUT.LANGUAGE",
        "CHAT.SCROLL.UP",
        "CHAT.SCROLL.DOWN",
        "CHAT.SCROLL.BOTTOM",
        "CHAT.MENU.BUTTON",
        "CHAT.RESIZE",
        "CHAT.POPUP.SHELL",
        "CHAT.POPUP.CHAT",
        "CHAT.POPUP.EMOTE",
        "CHAT.POPUP.LANGUAGE",
        "CHAT.POPUP.VOICE",
        "CHAT.URLCOPY.SHELL",
        "CHAT.URLCOPY.INPUT",
        "CHAT.URLCOPY.CLOSE",
        "CHAT.COPY.TOGGLE",
        "CHAT.COPY.SURFACE",
        "CHAT.COPY.TEXT",
        "CHAT.WHISPER.TOGGLE",
        "CHAT.WHISPER.DIALOG",
    ):
        assert f"`{component_id}`" in chat_submodules, (
            f"chat pfUI object contract missing {component_id}"
        )

    addon_markdown = sorted(ADDON.rglob("*.md"))
    assert not addon_markdown, (
        "addon must contain runtime files and licenses, not Markdown: "
        f"{[path.relative_to(ROOT).as_posix() for path in addon_markdown]}"
    )

    for toc in (
        pfui / "pfUI.toc",
        pfui / "pfUI-tbc.toc",
        aeui / "AzerothExpeditionUI.toc",
        pfquest / "pfQuest.toc",
        pfquest_turtle / "pfQuest-turtle.toc",
    ):
        assert_toc_paths(toc)
    for xml in (pfui / "init").glob("*.xml"):
        assert_xml_includes(xml)

    aeui_toc = (aeui / "AzerothExpeditionUI.toc").read_text(
        encoding="utf-8-sig"
    )
    assert "## RequiredDeps: pfUI" in aeui_toc
    assert "## Version: 0.6.0" in aeui_toc
    assert "Core\\Bootstrap.lua" in aeui_toc
    assert "Modules\\Chat.lua" in aeui_toc
    assert "Modules\\QuestVisualTheme.lua" in aeui_toc
    assert "Modules\\Quests.lua" in aeui_toc
    bootstrap = (aeui / "Core" / "Bootstrap.lua").read_text(encoding="utf-8")
    assert 'addon.version = "0.6.0"' in bootstrap
    assert "chat-runtime=" in bootstrap
    assert "chat-color=" in bootstrap
    assert "quest-runtime=" in bootstrap
    assert 'elseif command == "quests" then' in bootstrap
    assert "function addon:RunModuleMethod" in bootstrap
    assert "pcall(module[methodName], module)" in bootstrap

    quest_source = (aeui / "Modules" / "Quests.lua").read_text(
        encoding="utf-8"
    )
    quest_theme_source = (
        aeui / "Modules" / "QuestVisualTheme.lua"
    ).read_text(encoding="utf-8")
    assert 'contract = "1.6"' in quest_theme_source
    assert "QuestLogShellV4" in quest_theme_source
    assert "QuestLogDirectoryMarksV1" in quest_theme_source
    assert "QuestTrackerPaperV1" in quest_theme_source
    assert "QuestToolWaxSealStatesV1" in quest_theme_source
    assert "NotoSerifSC-SemiBold.ttf" in quest_theme_source
    assert "LXGWWenKaiGB-Medium.ttf" in quest_theme_source
    assert "providerPanelHeight = 16" in quest_theme_source
    assert "bottomContentPadding = 16" in quest_theme_source
    assert "trackerQuestName" in quest_theme_source
    assert "providerOwned = true" in quest_theme_source
    assert "fallbackPath" in quest_theme_source
    assert 'flags = ""' in quest_theme_source
    assert "hideEntryIcons = true" in quest_theme_source
    quest_name_role = quest_theme_source.split(
        "questName = {", 1
    )[1].split("},", 1)[0]
    assert "providerOwned = true" in quest_name_role
    assert "NotoSansSC-Medium.ttf" in quest_name_role
    assert "size = 12" in quest_name_role
    assert 'flags = "OUTLINE"' in quest_name_role
    for shared_ink in (
        "|cff24170f",
        "|cff062a22",
        "|cff440705",
        "|cff2f1236",
        "|cff400909",
        "|cff421704",
        "|cff291d00",
        "|cff052b0f",
        "|cff24211f",
    ):
        assert shared_ink in quest_theme_source

    assert 'Quests.runtimeContract = "1.17"' in quest_source
    assert "ApplyTrackerProviderFont" in quest_source
    assert "ResolveQuestNameInk" in quest_source
    assert quest_source.count("ResolveQuestNameInk(") >= 3
    assert "ApplyDirectoryTypography" in quest_source
    assert "NormalizeDirectoryInlineStatus" in quest_source
    assert "ResolveDirectoryStatusInks" in quest_source
    assert "pfUI.font_default" in quest_source
    assert "addon.questVisualTheme" in quest_source
    assert "ApplyPfQuestTrackerEntryTheme" in quest_source
    assert "InstallPfQuestTrackerEntryThemeHooks" in quest_source
    assert "ApplyPfQuestTrackerContentSafeHeight" in quest_source
    assert "aeuiQuestVisualThemeDirty" in quest_source
    assert "aeuiQuestBottomContentPadding" in quest_source
    assert "SuppressPfQuestTrackerEntryIcon" in quest_source
    assert "aeuiQuestEntryIconThemeContract" in quest_source
    assert "ApplyDetailTextTheme" in quest_source
    assert "aeuiQuestVisualThemeContract" in quest_source
    assert "ApplyPfQuestTrackerPaper" in quest_source
    assert "EnsureQuestLogChromeSeal" in quest_source
    assert "EnsurePfQuestTrackerHubSeal" in quest_source
    assert "SetClampRectInsets" in quest_source
    assert "QuestLogSelectionBookmarkV1" not in quest_source
    assert "QuestLogTitleButtonTemplate" in quest_source
    assert "FauxScrollFrame_GetOffset" in quest_source
    assert "type(IsQuestWatched)" not in quest_source
    assert "row.aeuiQuestListCheck =" not in quest_source
    assert "GetQuestLogSelection" not in quest_source
    assert "CaptureAndHideNativeTextures" in quest_source
    assert "SuppressNativeRowSelection" in quest_source
    assert "ApplyDetailTextGeometry" in quest_source
    assert "ApplyDetailRewardGeometry" in quest_source
    assert "MeasureDetailContentHeight" in quest_source
    assert "UpdateDetailScrollChildHeight" in quest_source
    assert "rewardSlotWidth = 108" in quest_source
    assert "rewardNameWidth = 64" in quest_source
    assert "HideCollapseAllButton" in quest_source
    assert "aeuiQuestCollapseSuppressed" in quest_source
    assert "StyleLeatherButton" in quest_source
    assert "UpdateActionButtonStates" in quest_source
    assert '"OnEnable"' not in quest_source
    assert '"OnDisable"' not in quest_source
    assert "HideDetailScrollbar" in quest_source
    assert "HideListScrollbar" in quest_source
    assert "HideScrollbarChrome" in quest_source
    assert "InstallListMouseWheel" in quest_source
    assert "InstallDetailMouseWheel" in quest_source
    assert "rowCount = 18" in quest_source
    assert "providerRowCeiling = 23" in quest_source
    assert "rowWidth = 246" in quest_source
    assert "rowHeight = 18" in quest_source
    assert "textWidth = 226" in quest_source
    assert "QuestLogDetailScrollFrameScrollBar" in quest_source
    assert "ToggleDetail" in quest_source
    assert "CaptureQuestLogBaseGeometry" in quest_source
    assert "HasPfQuestQuestLogControls" in quest_source
    assert "InstallGlobalPostHook" in quest_source
    assert "InstallQuestLogFrameOnShowHook" in quest_source
    assert "ApplyPfQuestQuestLogCompatibility" in quest_source
    assert "LayoutDirectoryRows(true)" in quest_source
    for provider_object in (
        "buttonOnline",
        "buttonLanguage",
        "buttonShow",
        "buttonHide",
        "buttonClean",
        "buttonReset",
    ):
        assert provider_object in quest_source
    assert 'addon:RegisterModule("Quests", Quests)' in quest_source
    assert (aeui / "Media" / "Quests" / "QuestLogShellV4.tga").is_file()
    assert (
        aeui / "Media" / "Quests" / "QuestLogDirectoryMarksV1.tga"
    ).is_file()
    assert (
        aeui / "Media" / "Quests" / "QuestLogSelectionBookmarkV1.tga"
    ).is_file()
    seal_runtime = (
        aeui / "Media" / "Quests" / "QuestToolWaxSealStatesV1.tga"
    )
    assert seal_runtime.is_file()
    seal_runtime_manifest = json.loads(
        (
            ROOT
            / "assets"
            / "source"
            / "quests"
            / "qs-a1"
            / "QS-A1_RuntimeManifest_v1.json"
        ).read_text(encoding="utf-8")
    )
    assert seal_runtime_manifest["status"] == "runtime-exported"
    assert seal_runtime_manifest["display_region"]["status"] == "pass"
    assert hashlib.sha256(seal_runtime.read_bytes()).hexdigest() == (
        seal_runtime_manifest["runtime"]["sha256"]
    )

    for toc_name in ("pfUI.toc", "pfUI-tbc.toc"):
        toc_source = (pfui / toc_name).read_text(encoding="utf-8-sig")
        assert "## Version: 8.1.0-aeui.4" in toc_source

    pfquest_toc = (pfquest / "pfQuest.toc").read_text(encoding="utf-8-sig")
    assert "## Interface: 11200" in pfquest_toc
    assert "## Version: 7.0.1" in pfquest_toc
    assert "## OptionalDeps: pfUI" in pfquest_toc
    pfquest_turtle_toc = (
        pfquest_turtle / "pfQuest-turtle.toc"
    ).read_text(encoding="utf-8-sig")
    assert "## Interface: 11200" in pfquest_turtle_toc
    assert "## Version: 7.0.2" in pfquest_turtle_toc
    assert "## Dependencies: pfQuest" in pfquest_turtle_toc

    provider_quest = (pfquest / "quest.lua").read_text(encoding="utf-8")
    for provider_object in (
        "pfQuest.buttonOnline",
        "pfQuest.buttonLanguage",
        "pfQuest.buttonShow",
        "pfQuest.buttonHide",
        "pfQuest.buttonClean",
        "pfQuest.buttonReset",
        "QuestLogTitleButton_Resize",
    ):
        assert provider_object in provider_quest
    provider_tracker = (pfquest / "tracker.lua").read_text(encoding="utf-8")
    for provider_object in (
        "pfQuestMapTracker",
        "tracker.btnquest",
        "tracker.btndatabase",
        "tracker.btngiver",
        "tracker.btnsearch",
        "tracker.btnclean",
        "tracker.btnsettings",
        "tracker.btnclose",
        "pfQuestMapButton",
    ):
        assert provider_object in provider_tracker

    assert not (aeui / "Media" / "Chat" / "ChatPanelSegment.tga").exists()
    chat_source = (aeui / "Modules" / "Chat.lua").read_text(encoding="utf-8")
    assert "ChatPanelSegment" not in chat_source
    assert "SuppressLegacyInfoPanels" not in chat_source
    assert "SuppressChatInfoPanels" in chat_source
    assert "panels.minimap" not in chat_source
    assert "SuppressRightChat" in chat_source
    assert 'Chat.runtimeContract = "1.21"' in chat_source
    assert 'Chat.colorContract = "classic-provider"' in chat_source
    assert "ChatBookFrameFullV1" in chat_source
    assert "EnsureBookVisible" in chat_source
    assert 'owner:EnableDrawLayer("BACKGROUND")' in chat_source
    assert "InstallPfUIHooks" in chat_source
    assert "InstallOwnerScaleHook" in chat_source
    assert "ObserveOwnerScale" in chat_source
    assert "RestoreRuntimeLayout" in chat_source
    assert "CHAT_TEXT_LINE_SPACING = 3" in chat_source
    assert "CHAT_TEXT_SHADOW_COLOR" in chat_source
    assert "CHAT_TEXT_SHADOW_COLOR = { 0, 0, 0, 0 }" in chat_source
    assert "CHAT_TEXT_SHADOW_OFFSET = { 0, 0 }" in chat_source
    assert "CHAT_TEXT_PALETTE" not in chat_source
    assert "CHAT_BASE_COLOR_RULES" not in chat_source
    assert "CHAT_INLINE_COLOR_MAP" not in chat_source
    assert "AdaptUnknownInlineColor" not in chat_source
    assert "CHAT_INLINE_COLOR_TARGETS" not in chat_source
    assert "CHAT_INLINE_CONTRAST_TARGET" not in chat_source
    assert "CHAT_INLINE_PAPER_COLOR" not in chat_source
    assert "StyleChatFrameText" in chat_source
    assert "InstallMessageColorHook" not in chat_source
    assert "InstallChatMODFinalColorHook" not in chat_source
    assert "EnsureMessageColorHooks" not in chat_source
    assert "ApplyMessagePalette" not in chat_source
    assert "GetMessageColorStatus" in chat_source
    assert "return self.colorContract" in chat_source
    assert 'getglobal("S_AddMessage")' not in chat_source
    assert "frame.ORG_AddMessage = wrapper" not in chat_source
    assert "TransformBaseMessageColor" not in chat_source
    assert "NormalizeInlineMessageColors" not in chat_source
    for obsolete_parchment_color in (
        "ff4b3b2a",
        "ff583243",
        "ff354224",
        "ff423f1b",
        "ff333333",
        "ff003d7a",
        "ff22424e",
        "ff413959",
        "ff633004",
        "ff592d2d",
        "ff234020",
    ):
        assert obsolete_parchment_color not in chat_source
    assert "NotoSansSC-Medium.ttf" not in chat_source
    assert "READING_WASH_COLOR" not in chat_source
    assert "Interface\\\\Buttons\\\\WHITE8X8" not in chat_source
    assert "ChangeChatColor" not in chat_source
    assert "ChatTypeInfo.CHANNEL =" not in chat_source
    assert "frame:SetSpacing(CHAT_TEXT_LINE_SPACING)" in chat_source
    assert 'getglobal("FCF_SetChatWindowFontSize")' in chat_source
    text_style_block = chat_source.split(
        "function Chat:StyleChatFrameText", 1
    )[1].split("function Chat:LayoutTabPanel", 1)[0]
    assert "frame:SetFont(providerFont, fontSize)" in text_style_block
    assert "frame:SetShadowColor" in text_style_block
    assert "frame:SetShadowOffset" in text_style_block
    assert '"OUTLINE"' not in text_style_block
    assert "startupLayoutForce" in chat_source
    assert 'event == "UI_SCALE_CHANGED"' in chat_source
    assert 'text:SetJustifyV("MIDDLE")' in chat_source
    for texture in (
        "ChatBookFrameFullV1",
        "ChatTabAtlasV3",
        "ChatTabShelfV3",
        "ChatInputDarkV1",
        "ChatUnreadSealV3",
    ):
        assert texture in chat_source, f"chat adapter does not mount {texture}"
    assert (aeui / "Media" / "Chat" / "ChatBookFrameV3.tga").is_file()

    full_frame_manifest_path = (
        ROOT
        / "assets"
        / "source"
        / "chat"
        / "frame-full-v1"
        / "ChatBookFrame_Full_V1_RuntimeManifest_v1.json"
    )
    full_frame_manifest = json.loads(
        full_frame_manifest_path.read_text(encoding="utf-8")
    )
    full_frame_runtime = (
        aeui / "Media" / "Chat" / "ChatBookFrameFullV1.tga"
    )
    assert full_frame_manifest["runtime_contract"] == "1.19"
    assert full_frame_manifest["status"] == "runtime-exported"
    assert full_frame_manifest["single_chat_frame"] is True
    assert full_frame_manifest["source"]["sha256"] == (
        "a97d9c5fa055a119cd5ea7809bdaa51460cddb9674355efcec35f98f6cd2c673"
    )
    assert sha256(full_frame_runtime) == (
        full_frame_manifest["runtime_export"]["sha256"]
    )
    assert full_frame_manifest["runtime_export"]["width"] == 1024
    assert full_frame_manifest["runtime_export"]["height"] == 1024
    assert full_frame_manifest["runtime_export"][
        "visible_green_spill_pixels"
    ] == 0
    assert full_frame_manifest["adapter"]["texture_instances"] == 9
    assert full_frame_manifest["adapter"]["right_frame_instances"] == 0

    input_source_dir = (
        ROOT / "assets" / "source" / "chat" / "input-dark-v1"
    )
    input_source_manifest = json.loads(
        (
            input_source_dir / "ChatInput_Dark_V1_SourceManifest_v1.json"
        ).read_text(encoding="utf-8")
    )
    input_source = input_source_dir / input_source_manifest["source"]["file"]
    assert input_source_manifest["accepted_version"] == (
        "CHAT.INPUT.DARK.V1.r3 attempt 4"
    )
    assert input_source_manifest["status"] == "runtime-exported"
    assert input_source_manifest["phase"] == "P5"
    assert input_source_manifest["source"]["mode"] == "RGBA"
    assert input_source_manifest["source"]["shared_state_alpha"] is True
    assert input_source_manifest["source"]["canonical_state_cells_xyxy"] == {
        "normal": [51, 187, 1437, 363],
        "focus": [51, 448, 1437, 624],
    }
    assert sha256(input_source) == (
        "4df36bc607a024ca0a2355f5d20ff985f61cbf3304073a65e33caa978c50cda0"
    )
    assert sha256(input_source) == input_source_manifest["source"]["sha256"]
    assert input_source_manifest["source"]["pure_green_visible_pixels"] == 0
    assert input_source_manifest["source"][
        "heuristic_green_dominant_visible_pixels"
    ] == 0
    assert input_source_manifest["source"][
        "transparent_rgb_nonzero_values"
    ] == 0
    assert input_source_manifest["user_acceptance"]["statement"] == (
        "接受 CHAT.INPUT.DARK.V1.r3 attempt 4 进入 P4。"
    )
    assert input_source_manifest["provenance"]["imagegen_budget"] == {
        "actual_calls": 4,
        "maximum_calls": 5,
        "process_errors": 4,
        "unconsumed_calls_terminated_on_acceptance": 1,
        "unconsumed_calls_transferable": False,
    }
    assert input_source_manifest["runtime_export_contract"]["status"] == (
        "runtime-exported"
    )
    assert input_source_manifest["runtime_export_contract"]["phase"] == "P5"
    assert input_source_manifest["runtime_export_contract"]["version"] == "1.20"
    assert input_source_manifest["runtime_export_contract"][
        "whole_source_runtime_allowed"
    ] is False
    current_input_runtime = aeui / "Media" / "Chat" / "ChatInputDarkV1.tga"
    assert sha256(current_input_runtime) == input_source_manifest[
        "runtime_export_contract"
    ]["runtime_atlas_sha256"]
    assert (
        aeui / "Media" / "Chat" / "ChatInputAtlasV3.tga"
    ).is_file()
    assert "ChatInputDarkV1" in chat_source

    input_runtime_manifest = json.loads(
        (
            input_source_dir / "ChatInput_Dark_V1_RuntimeManifest_v1.json"
        ).read_text(encoding="utf-8")
    )
    assert input_runtime_manifest["runtime_contract"] == "1.20"
    assert input_runtime_manifest["status"] == "runtime-exported"
    assert input_runtime_manifest["phase"] == "P5"
    assert input_runtime_manifest["source"]["sha256"] == sha256(input_source)
    assert input_runtime_manifest["runtime_export"]["sha256"] == sha256(
        current_input_runtime
    )
    assert input_runtime_manifest["runtime_export"][
        "visible_green_spill_pixels"
    ] == 0
    assert input_runtime_manifest["runtime_export"][
        "transparent_rgb_nonzero_values"
    ] == 0
    assert input_runtime_manifest["deterministic_export"][
        "normal_focus_alpha_equal"
    ] is True
    assert input_runtime_manifest["deterministic_export"][
        "atlas_x_pixels"
    ] == [8, 121, 932, 1016]
    assert input_runtime_manifest["adapter"]["texture_instances"] == 3

    manifest_path = (
        ROOT
        / "assets"
        / "source"
        / "chat"
        / "v3"
        / "ChatV3_RuntimeManifest_v1.json"
    )
    runtime_manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    assert runtime_manifest["runtime_contract"] == "1.6"
    assert runtime_manifest["status"] == "runtime-exported"
    assert runtime_manifest["single_chat_frame"] is True
    tab_runtime = runtime_manifest["tab"]["runtime"]
    assert tab_runtime["height"] == 30
    assert tab_runtime["top_offset"] == 2
    assert tab_runtime["panel_height"] == 32
    assert tab_runtime["content_top_inset"] == 32
    assert tab_runtime["hit_rect_insets"] == [0, 0, 0, -8]
    assert tab_runtime["selected_text_rgba"] == [1.0, 0.88, 0.62, 1.0]
    assert tab_runtime["text_layout"] == {
        "anchor": "CENTER",
        "horizontal_inset": 6,
        "height": 18,
        "justify_h": "CENTER",
        "justify_v": "MIDDLE",
    }
    assert tab_runtime["startup_settle_delay_seconds"] == 0.5
    assert tab_runtime["scale_change_reflow"] == {
        "owner_scale_hook": "pfChatLeft.OnMove",
        "effective_scale_edge_detection": True,
        "event_fallback": "UI_SCALE_CHANGED",
        "event_delay_seconds": 0.5,
        "force_geometry_once": True,
        "ordinary_move_forces_geometry": False,
        "covers": [
            "tab_panel",
            "tabs",
            "tab_text",
            "content_frames",
            "hit_rect",
        ],
    }
    assert tab_runtime["content_safe_area"] == {
        "left": 30,
        "right": 30,
        "top": 32,
        "bottom": 40,
    }
    assert tab_runtime["locked_movement_deferred_once"] is True
    tab_shelf_runtime = runtime_manifest["tab_shelf"]["runtime"]
    assert tab_shelf_runtime["height"] == 16
    assert tab_shelf_runtime["top_offset"] == 18
    for record in runtime_manifest["runtime_exports"].values():
        runtime_path = ROOT / record["file"]
        assert runtime_path.is_file(), f"missing runtime media {record['file']}"
        assert sha256(runtime_path) == record["sha256"], (
            f"runtime hash changed without manifest update: {record['file']}"
        )

    imagegen_wrapper = (
        ROOT / ".codex" / "skills" / "imagegen-0-143-0" / "SKILL.md"
    ).read_text(encoding="utf-8")
    assert "-C /absolute/path/to/empty-temp-directory" in imagegen_wrapper
    assert "-s workspace-write" in imagegen_wrapper
    assert "`--image` is variadic in Codex `0.143.0`" in imagegen_wrapper
    assert "No prompt provided via stdin" in imagegen_wrapper
    assert "must use its built-in `image_gen`" in imagegen_wrapper
    assert "must not start another `codex`／`npx` subprocess" in imagegen_wrapper
    assert "## Read-only child recovery" in imagegen_wrapper

    expedition = (pfui / "api" / "expedition.lua").read_text(encoding="utf-8")
    assert 'ownership = "scoped-v1"' in expedition
    assert 'expedition.vanilla_fallback = "0"' in expedition
    assert 'expedition.native_blizzard_skins = "0"' in expedition
    assert 'expedition.legacy_info_panels = "1"' in expedition
    assert "vanillaModuleGroups" not in expedition
    assert "ApplyExpeditionVisualContract" in expedition
    assert "GetExpeditionModuleOwner" in expedition
    assert "GetExpeditionSkinOwner" in expedition
    assert "ShouldUseVanillaModule" in expedition
    assert "ShouldUseVanillaSkin" in expedition
    assert "ShouldUseSingleChatFrame" in expedition

    pfui_chat = (pfui / "modules" / "chat.lua").read_text(encoding="utf-8")
    assert "ApplyExpeditionMessagePalette" not in pfui_chat
    assert "chat:ApplyMessagePalette" not in pfui_chat
    assert "single-journal route" in pfui_chat
    assert "AddSecondaryMessagesTo(ChatFrame1)" in pfui_chat
    assert "not v.aeuiManaged" in pfui_chat
    assert "not tabtext.aeuiManaged" in pfui_chat
    pfui_unlock = (pfui / "modules" / "unlock.lua").read_text(
        encoding="utf-8"
    )
    assert "frame:SetScale(scale)" in pfui_unlock
    assert "if frame.OnMove then frame:OnMove() end" in pfui_unlock
    for message_group in (
        "COMBAT_XP_GAIN",
        "COMBAT_HONOR_GAIN",
        "COMBAT_FACTION_CHANGE",
        "SKILL",
        "LOOT",
    ):
        assert message_group in pfui_chat

    owner_block = expedition.split("module_owners = {", 1)[1].split(
        "skin_owners = {", 1
    )[0]
    owned_modules = set(
        re.findall(r'^\s*([a-z0-9_-]+)\s*=\s*"chat"', owner_block, re.M)
    )
    assert owned_modules == {"chatcopy", "whisperproxy", "bubbles"}
    modules_xml = (pfui / "init" / "modules.xml").read_text(encoding="utf-8")
    registered_module_files = set(
        re.findall(r'modules\\([^"\\]+)\.lua', modules_xml)
    )
    assert owned_modules <= registered_module_files
    for retained in (
        "gui", "skin", "panel", "actionbar", "minimap", "player", "raid",
        "bags", "loot", "nameplates", "chat", "questitem", "turtle-wow",
    ):
        assert retained in registered_module_files
        assert retained not in owned_modules

    skin_owner_block = expedition.split("skin_owners = {", 1)[1].split(
        "local function GetExpeditionConfig", 1
    )[0]
    assert re.findall(
        r'\["([^"]+)"\]\s*=\s*"quests"', skin_owner_block
    ) == ["Quest Log"]

    pfui_core = (pfui / "pfUI.lua").read_text(encoding="utf-8")
    assert "function pfUI:IsModuleEnabled" in pfui_core
    assert "function pfUI:IsSkinEnabled" in pfui_core
    assert 'bgFile = "Interface\\\\BUTTONS\\\\WHITE8X8"' in pfui_core

    pfui_api = (pfui / "api" / "api.lua").read_text(encoding="utf-8")
    assert "C.appearance.expedition" not in pfui_api
    assert "expedition.compact" not in pfui_api
    assert "expedition.surface" not in pfui_api

    pfui_config_source = (pfui / "api" / "config.lua").read_text(
        encoding="utf-8"
    )
    for restored_default in (
        '"background",       "0,0,0,1"',
        '"color",            "0.2,0.2,0.2,1"',
        '"texture",          "None"',
        '"left",             "guild"',
        '"right",            "gold"',
        '"minimap",          "zone"',
    ):
        assert restored_default in pfui_config_source

    game_menu = (pfui / "skins" / "blizzard" / "game_menu.lua").read_text(
        encoding="utf-8"
    )
    assert "GameMenuButtonPFUI" in game_menu
    assert "pfUI.gui:Show()" in game_menu

    turtle = (pfui / "modules" / "turtle-wow.lua").read_text(encoding="utf-8")
    assert 'pfUI:IsModuleEnabled("player")' in turtle
    for skin in ("Game Menu", "Character", "Inspect", "Profession"):
        assert f'pfUI:IsSkinEnabled("{skin}")' in turtle

    for markdown in ROOT.rglob("*.md"):
        if ".git" not in markdown.parts:
            assert_markdown_links(markdown)

    addon_validator = (
        ROOT
        / ".codex"
        / "skills"
        / "run-aeui-asset-workflow"
        / "scripts"
        / "validate_addon_package.py"
    )
    validator_result = subprocess.run(
        [sys.executable, str(addon_validator), str(ROOT)],
        check=False,
        capture_output=True,
        text=True,
    )
    assert validator_result.returncode == 0, (
        validator_result.stdout + validator_result.stderr
    )
    addon_report = json.loads(validator_result.stdout)
    assert addon_report["schema"] == "aeui-addon-package-report-v1"
    assert addon_report["status"] == "pass"
    assert addon_report["build_required_on_target_device"] is False
    assert addon_report["violations"] == []

    print("repository contract test passed")


if __name__ == "__main__":
    main()
