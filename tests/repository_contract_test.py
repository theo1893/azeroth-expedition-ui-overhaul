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
    assert (pfui / "AEUI_FORK.md").is_file(), "pfUI fork manifest is missing"

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

    assert not (aeui / "Media" / "Chat" / "ChatPanelSegment.tga").exists()
    chat_source = (aeui / "Modules" / "Chat.lua").read_text(encoding="utf-8")
    assert "ChatPanelSegment" not in chat_source
    assert "SuppressLegacyInfoPanels" in chat_source

    expedition = (pfui / "api" / "expedition.lua").read_text(encoding="utf-8")
    assert 'legacy_info_panels = "0"' in expedition
    assert "ApplyExpeditionVisualContract" in expedition

    for markdown in ROOT.rglob("*.md"):
        if ".git" not in markdown.parts:
            assert_markdown_links(markdown)

    print("repository contract test passed")


if __name__ == "__main__":
    main()
