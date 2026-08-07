local addon = AzerothExpeditionUI
local media = addon.media.root

-- One runtime visual contract feeds both Quest Log and pfQuest Tracker.
-- The two surfaces intentionally keep different physical silhouettes (archive
-- book versus field note), while all shared materials, typography roles and
-- semantic ink colors live here so a later art revision has one entry point.
addon.questVisualTheme = {
  contract = "1.10",
  media = {
    questLogShell = media .. "Quests\\QuestLogShellV4",
    directoryMarks = media .. "Quests\\QuestLogDirectoryMarksV1",
    trackerPaper = media .. "Quests\\QuestTrackerPaperV1",
    toolSeal = media .. "Quests\\QuestToolWaxSealStatesV1",
    sealMenuCarrier = media .. "Quests\\QuestLogSealPurityRibbonV1",
    rewardSlotStates = media .. "Quests\\QuestLogRewardSlotStatesV1",
  },
  fonts = {
    panelTitle = {
      path = media .. "Fonts\\NotoSerifSC-SemiBold.ttf",
      size = 15,
      flags = "OUTLINE",
    },
    questName = {
      -- Quest names follow the same pfUI standard face used by the rest of
      -- the live interface. The bundled Noto Sans face is only a fallback for
      -- unusual load orders where pfUI has not resolved font_default yet.
      providerOwned = true,
      path = media .. "Fonts\\NotoSansSC-Medium.ttf",
      fallbackPath = media .. "Fonts\\NotoSansSC-Medium.ttf",
      size = 12,
      flags = "",
    },
    detailHeading = {
      path = media .. "Fonts\\NotoSerifSC-SemiBold.ttf",
      size = 14,
      flags = "",
    },
    detailBody = {
      -- Long Chinese reading text follows the same high-legibility client
      -- face as the live interface instead of Blizzard's outlined QuestFont.
      providerOwned = true,
      path = media .. "Fonts\\NotoSansSC-Medium.ttf",
      fallbackPath = media .. "Fonts\\NotoSansSC-Medium.ttf",
      size = 12,
      flags = "",
    },
    trackerQuestName = {
      providerOwned = true,
      fallbackPath = media .. "Fonts\\LXGWWenKaiGB-Medium.ttf",
      size = 10,
      flags = "",
    },
  },
  metrics = {
    tracker = {
      providerPanelHeight = 16,
      bottomContentPadding = 16,
      hideEntryIcons = true,
    },
  },
  ink = {
    -- Quiet book inks.
    body = { 0.141, 0.090, 0.059, 1, code = "|cff24170f" },
    section = { 0.231, 0.145, 0.090, 1, code = "|cff3b2517" },
    muted = { 0.400, 0.318, 0.231, 1, code = "|cff66513b" },

    -- Shared Quest Log / Tracker semantics. The darkest representative area
    -- of the accepted parchment is about #B08444; these inks stay near or
    -- above 4.5:1 there without using an outline or luminous HUD colors.
    complete = { 0.024, 0.165, 0.133, 1, code = "|cff062a22" },
    active = { 0.196, 0.106, 0.000, 1, code = "|cff321b00" },
    incomplete = { 0.267, 0.027, 0.020, 1, code = "|cff440705" },
    failed = { 0.220, 0.020, 0.020, 1, code = "|cff380505" },
    database = { 0.035, 0.153, 0.184, 1, code = "|cff09272f" },
    questType = { 0.184, 0.071, 0.212, 1, code = "|cff2f1236" },
    difficulty = {
      impossible = { 0.251, 0.035, 0.035, 1, code = "|cff400909" },
      hard = { 0.259, 0.090, 0.016, 1, code = "|cff421704" },
      normal = { 0.161, 0.114, 0.000, 1, code = "|cff291d00" },
      easy = { 0.020, 0.169, 0.059, 1, code = "|cff052b0f" },
      trivial = { 0.141, 0.129, 0.122, 1, code = "|cff24211f" },
    },
    control = {
      normal = { 0.96, 0.79, 0.42, 1 },
      hover = { 1, 0.91, 0.62, 1 },
      pressed = { 0.86, 0.64, 0.28, 1 },
      disabled = { 0.48, 0.40, 0.30, 1 },
    },
  },
  leather = {
    base = { 0.20, 0.075, 0.035, 0.96 },
    edge = { 0.55, 0.32, 0.12, 0.90 },
    shadow = { 0.055, 0.022, 0.012, 0.95 },
    hover = { 0.52, 0.27, 0.08, 0.30 },
    pressed = { 0.02, 0.01, 0.005, 0.45 },
    disabled = { 0.08, 0.065, 0.05, 0.58 },
  },
}
