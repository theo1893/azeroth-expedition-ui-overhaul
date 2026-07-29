#!/usr/bin/env python3
"""Static repository contract checks without third-party dependencies."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "addon"


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
    assert not (ROOT / "third-party" / "pfUI").exists(), (
        "a duplicate read-only pfUI snapshot remains in third-party"
    )
    assert (pfui / "LICENSE").is_file(), "pfUI MIT license is missing"
    docs = ROOT / "docs"
    assert (docs / "README.md").is_file(), "central documentation index is missing"
    assert (docs / "WORKFLOW.md").is_file(), "documentation workflow is missing"
    assert (docs / "pfui" / "PFUI_FORK.md").is_file(), (
        "central pfUI fork manifest is missing"
    )
    agents_source = (ROOT / "AGENTS.md").read_text(encoding="utf-8")
    assert "## 模块信息路由" in agents_source
    assert "run-aeui-asset-workflow" in agents_source
    assert "imagegen-0-143-0" in agents_source
    assert "P6-C" in agents_source
    for forbidden in (
        "## 聊天模块当前边界",
        "## 任务模块当前边界",
        "QL-A1",
        "QL-A2",
        "V3 A／B／C",
        "440 × 320",
        "QuestWatchFrame",
        "questitem.lua",
    ):
        assert forbidden not in agents_source, (
            "AGENTS.md contains module-specific mutable state: "
            f"{forbidden}"
        )
    addon_markdown = sorted(ADDON.rglob("*.md"))
    assert not addon_markdown, (
        "addon must contain runtime files and required licenses, not Markdown: "
        f"{[path.relative_to(ROOT).as_posix() for path in addon_markdown]}"
    )

    closure_documents = (
        docs / "ASSET_PIPELINE.md",
        docs / "WORKFLOW.md",
        docs / "repository" / "ASSETS.md",
        docs / "repository" / "PROMPTS.md",
        docs / "implementation" / "IMPLEMENTATION_ROADMAP.md",
        docs / "implementation" / "OVERHAUL_TRACKER.md",
    )
    for document in closure_documents:
        source = document.read_text(encoding="utf-8")
        assert "P6-C" in source, (
            f"{document.relative_to(ROOT)} lacks the terminal cleanup gate"
        )

    tracker_source = (
        docs / "implementation" / "OVERHAUL_TRACKER.md"
    ).read_text(encoding="utf-8")
    component_table = tracker_source.split("## 组件级改造表", 1)[1]
    for line in component_table.splitlines():
        if not line.startswith("|") or "`P6-C`" not in line:
            continue
        assert "generated/" not in line, (
            "closed component still references generated intermediates: "
            f"{line}"
        )
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        assert cells[-1] == "已关闭", (
            "closed component must not retain a next action: "
            f"{line}"
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
    assert "## Version: 0.4.1" in aeui_toc
    bootstrap = (aeui / "Core" / "Bootstrap.lua").read_text(
        encoding="utf-8"
    )
    assert 'addon.version = "0.4.1"' in bootstrap

    for toc_name in ("pfUI.toc", "pfUI-tbc.toc"):
        toc_source = (pfui / toc_name).read_text(encoding="utf-8-sig")
        assert "## Version: 8.1.0-aeui.2" in toc_source

    assert not (aeui / "Media" / "Chat" / "ChatPanelSegment.tga").exists()
    chat_source = (aeui / "Modules" / "Chat.lua").read_text(encoding="utf-8")
    assert "ChatPanelSegment" not in chat_source
    assert "SuppressLegacyInfoPanels" in chat_source

    imagegen_wrapper = (
        ROOT / ".codex" / "skills" / "imagegen-0-143-0" / "SKILL.md"
    ).read_text(encoding="utf-8")
    assert "-C /absolute/path/to/empty-temp-directory" in imagegen_wrapper
    assert "`--image` is variadic in Codex `0.143.0`" in imagegen_wrapper
    assert "No prompt provided via stdin" in imagegen_wrapper
    assert "## Read-only child recovery" in imagegen_wrapper

    expedition = (pfui / "api" / "expedition.lua").read_text(encoding="utf-8")
    assert 'legacy_info_panels = "0"' in expedition
    assert 'vanilla_fallback = "1"' in expedition
    assert 'native_blizzard_skins = "1"' in expedition
    assert "ApplyExpeditionVisualContract" in expedition
    assert "ShouldUseVanillaModule" in expedition
    assert "ShouldUseVanillaSkin" in expedition

    fallback_block = expedition.split(
        "local vanillaModuleGroups = {", 1
    )[1].split("for group, modules", 1)[0]
    fallback_modules = set(re.findall(r'"([^"]+)"', fallback_block))
    modules_xml = (pfui / "init" / "modules.xml").read_text(
        encoding="utf-8"
    )
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
    assert not retained_modules & fallback_modules, (
        "a retained behavior module was routed out of the runtime: "
        f"{sorted(retained_modules & fallback_modules)}"
    )
    unclassified = (
        registered_module_files - fallback_modules - retained_modules
    )
    assert not unclassified, (
        "pfUI modules lack an explicit native-fallback/retained classification: "
        f"{sorted(unclassified)}"
    )

    pfui_core = (pfui / "pfUI.lua").read_text(encoding="utf-8")
    assert "function pfUI:IsModuleEnabled" in pfui_core
    assert "function pfUI:IsSkinEnabled" in pfui_core
    assert "if not pfUI:IsModuleEnabled(m) then return end" in pfui_core
    assert "if not pfUI:IsSkinEnabled(s) then return end" in pfui_core

    turtle = (pfui / "modules" / "turtle-wow.lua").read_text(
        encoding="utf-8"
    )
    assert 'pfUI:IsModuleEnabled("player")' in turtle
    for skin in ("Game Menu", "Character", "Inspect", "Profession"):
        assert f'pfUI:IsSkinEnabled("{skin}")' in turtle

    for markdown in ROOT.rglob("*.md"):
        if ".git" not in markdown.parts:
            assert_markdown_links(markdown)

    documentation_index = (docs / "README.md").read_text(encoding="utf-8")
    unindexed_docs = [
        path.relative_to(docs).as_posix()
        for path in sorted(docs.rglob("*.md"))
        if path != docs / "README.md"
        and path.relative_to(docs).as_posix() not in documentation_index
    ]
    assert not unindexed_docs, (
        "docs/README.md does not index central documents: "
        f"{unindexed_docs}"
    )

    print("repository contract test passed")


if __name__ == "__main__":
    main()
