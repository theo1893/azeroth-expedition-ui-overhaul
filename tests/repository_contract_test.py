#!/usr/bin/env python3
"""Static repository, runtime, and compact-document contract checks."""

from __future__ import annotations

import hashlib
import json
import re
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
    assert pfui.is_dir(), "deployable addon/pfUI fork is missing"
    assert aeui.is_dir(), "addon/AzerothExpeditionUI is missing"
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
        "8.1.0-aeui.3",
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
    ):
        assert_toc_paths(toc)
    for xml in (pfui / "init").glob("*.xml"):
        assert_xml_includes(xml)

    aeui_toc = (aeui / "AzerothExpeditionUI.toc").read_text(
        encoding="utf-8-sig"
    )
    assert "## RequiredDeps: pfUI" in aeui_toc
    assert "## Version: 0.6.0" in aeui_toc
    assert "Modules\\Quests.lua" in aeui_toc
    bootstrap = (aeui / "Core" / "Bootstrap.lua").read_text(encoding="utf-8")
    assert 'addon.version = "0.6.0"' in bootstrap
    assert "chat-runtime=" in bootstrap
    assert "quest-runtime=" in bootstrap
    assert 'elseif command == "quests" then' in bootstrap

    quest_source = (aeui / "Modules" / "Quests.lua").read_text(
        encoding="utf-8"
    )
    assert 'Quests.runtimeContract = "1.2"' in quest_source
    assert "QuestLogShellV4" in quest_source
    assert "QuestLogDirectoryMarksV1" in quest_source
    assert "QuestLogSelectionBookmarkV1" in quest_source
    assert "QuestLogTitleButtonTemplate" in quest_source
    assert "FauxScrollFrame_GetOffset" in quest_source
    assert "IsQuestWatched" in quest_source
    assert "GetQuestLogSelection" in quest_source
    assert "CaptureAndHideNativeTextures" in quest_source
    assert "ToggleDetail" in quest_source
    assert 'addon:RegisterModule("Quests", Quests)' in quest_source
    assert (aeui / "Media" / "Quests" / "QuestLogShellV4.tga").is_file()
    assert (
        aeui / "Media" / "Quests" / "QuestLogDirectoryMarksV1.tga"
    ).is_file()
    assert (
        aeui / "Media" / "Quests" / "QuestLogSelectionBookmarkV1.tga"
    ).is_file()

    for toc_name in ("pfUI.toc", "pfUI-tbc.toc"):
        toc_source = (pfui / toc_name).read_text(encoding="utf-8-sig")
        assert "## Version: 8.1.0-aeui.3" in toc_source

    assert not (aeui / "Media" / "Chat" / "ChatPanelSegment.tga").exists()
    chat_source = (aeui / "Modules" / "Chat.lua").read_text(encoding="utf-8")
    assert "ChatPanelSegment" not in chat_source
    assert "SuppressLegacyInfoPanels" in chat_source
    assert "SuppressRightChat" in chat_source
    assert 'Chat.runtimeContract = "1.6"' in chat_source
    assert "InstallPfUIHooks" in chat_source
    assert "InstallOwnerScaleHook" in chat_source
    assert "ObserveOwnerScale" in chat_source
    assert "RestoreRuntimeLayout" in chat_source
    assert "startupLayoutForce" in chat_source
    assert 'event == "UI_SCALE_CHANGED"' in chat_source
    assert 'text:SetJustifyV("MIDDLE")' in chat_source
    for texture in (
        "ChatBookFrameV3",
        "ChatTabAtlasV3",
        "ChatTabShelfV3",
        "ChatInputAtlasV3",
        "ChatUnreadSealV3",
    ):
        assert texture in chat_source, f"chat adapter does not mount {texture}"

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
    assert 'legacy_info_panels = "0"' in expedition
    assert 'vanilla_fallback = "1"' in expedition
    assert 'native_blizzard_skins = "1"' in expedition
    assert "ApplyExpeditionVisualContract" in expedition
    assert "ShouldUseVanillaModule" in expedition
    assert "ShouldUseVanillaSkin" in expedition
    assert "ShouldUseSingleChatFrame" in expedition

    pfui_chat = (pfui / "modules" / "chat.lua").read_text(encoding="utf-8")
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

    fallback_block = expedition.split(
        "local vanillaModuleGroups = {", 1
    )[1].split("for group, modules", 1)[0]
    fallback_modules = set(re.findall(r'"([^"]+)"', fallback_block))
    modules_xml = (pfui / "init" / "modules.xml").read_text(encoding="utf-8")
    registered_module_files = set(
        re.findall(r'modules\\([^"\\]+)\.lua', modules_xml)
    )
    retained_modules = {
        "gui",
        "unlock",
        "updatenotify",
        "chat",
        "autoshift",
        "autovendor",
        "questitem",
        "sellvalue",
        "eqcompare",
        "custom",
        "gm",
        "feigndeath",
        "pixelperfect",
        "hdgraphic",
        "share",
        "socialmod",
        "screenshot",
        "combatlogfix",
        "macrotweak",
        "turtle-wow",
        "superwow",
    }
    assert not retained_modules & fallback_modules
    unclassified = registered_module_files - fallback_modules - retained_modules
    assert not unclassified, (
        "pfUI modules lack an explicit native-fallback/retained classification: "
        f"{sorted(unclassified)}"
    )

    pfui_core = (pfui / "pfUI.lua").read_text(encoding="utf-8")
    assert "function pfUI:IsModuleEnabled" in pfui_core
    assert "function pfUI:IsSkinEnabled" in pfui_core

    turtle = (pfui / "modules" / "turtle-wow.lua").read_text(encoding="utf-8")
    assert 'pfUI:IsModuleEnabled("player")' in turtle
    for skin in ("Game Menu", "Character", "Inspect", "Profession"):
        assert f'pfUI:IsSkinEnabled("{skin}")' in turtle

    for markdown in ROOT.rglob("*.md"):
        if ".git" not in markdown.parts:
            assert_markdown_links(markdown)

    print("repository contract test passed")


if __name__ == "__main__":
    main()
