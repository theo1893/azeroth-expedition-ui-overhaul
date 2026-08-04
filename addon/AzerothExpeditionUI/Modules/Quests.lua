local addon = AzerothExpeditionUI
local Quests = {}
Quests.runtimeContract = "1.25"

local THEME = addon.questVisualTheme
local SHELL_TEXTURE = THEME.media.questLogShell
local DIRECTORY_MARK_TEXTURE = THEME.media.directoryMarks
local QUEST_TITLE_FONT = THEME.fonts.panelTitle.path
local TRACKER_PAPER_TEXTURE = THEME.media.trackerPaper
local QUEST_SEAL_TEXTURE = THEME.media.toolSeal

local SHELL = {
  width = 676,
  height = 464,
  texcoord = {
    left = 0,
    right = 0.66015625,
    top = 0,
    bottom = 0.90625,
  },
}

-- These rectangles are layout safe areas inside the accepted fixed shell.
-- They do not own visual art: every row, FontString, item and Button remains a
-- live Blizzard/pfUI object above the non-interactive background Texture.
local LAYOUT = {
  list = {
    left = 64,
    top = 64,
    width = 246,
    height = 324,
  },
  detail = {
    left = 366,
    top = 64,
    width = 246,
    height = 324,
    contentWidth = 224,
    textWidth = 214,
    objectiveWidth = 204,
    rewardSlotWidth = 108,
    rewardSlotHeight = 41,
    rewardNameWidth = 64,
    rewardColumnGap = 8,
    rewardRowGap = 4,
    rewardIconSize = 33,
    rewardContentInset = 4,
    rewardNameGap = 4,
    rewardHeaderGap = 5,
    rewardLabelHeight = 14,
    rewardSectionGap = 5,
    contentBottomPadding = 12,
    contentMaxHeight = 4096,
  },
  titleTop = 28,
  countTop = 52,
  controlsTop = 44,
  closeRight = 18,
  closeTop = 20,
  actionLeft = 62,
  actionBottom = 19,
  actionWidth = 78,
  actionHeight = 22,
  actionGap = 5,
}

-- Quest Log is scoped to AEUI, so pfUI's Quest Log skin (and its item.backdrop)
-- is intentionally not loaded. Build a small adapter-owned visual container
-- around each real Blizzard reward Button instead of styling a frame that does
-- not exist on the scoped runtime path. The container is programmatic fallback
-- art only; it keeps every live icon, count, name, tooltip and click handler.
local REWARD_CONTAINER = {
  backdrop = {
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\BUTTONS\\WHITE8X8",
    tile = false,
    tileSize = 0,
    edgeSize = 1,
    insets = {
      left = 1,
      right = 1,
      top = 1,
      bottom = 1,
    },
  },
  normal = {
    background = { 0.36, 0.22, 0.08, 0.20 },
    border = { 0.31, 0.17, 0.06, 0.72 },
  },
  hover = {
    background = { 0.44, 0.29, 0.11, 0.28 },
    border = { 0.50, 0.31, 0.12, 0.90 },
  },
}

local DIRECTORY = {
  contract = "1.4",
  rowCount = 18,
  providerRowCeiling = 23,
  rowWidth = 246,
  rowHeight = 18,
  rowStep = 18,
  textWidth = 226,
  states = {
    collapsed = {
      width = 12,
      height = 12,
      left = 0.03125,
      right = 0.21875,
      top = 0.125,
      bottom = 0.875,
    },
    expanded = {
      width = 12,
      height = 12,
      left = 0.28125,
      right = 0.46875,
      top = 0.125,
      bottom = 0.875,
    },
    untracked = {
      width = 10,
      height = 10,
      left = 0.546875,
      right = 0.703125,
      top = 0.1875,
      bottom = 0.8125,
    },
    tracked = {
      width = 10,
      height = 10,
      left = 0.796875,
      right = 0.953125,
      top = 0.1875,
      bottom = 0.8125,
    },
  },
}

local CONTROL = {
  contract = "1.0",
  trackSize = 14,
  scrollStep = 28,
  leather = THEME.leather,
  text = {
    normal = THEME.ink.control.normal,
    hover = THEME.ink.control.hover,
    pressed = THEME.ink.control.pressed,
    disabled = THEME.ink.control.disabled,
    ink = THEME.ink.body,
  },
}

local PFQUEST = {
  addons = {
    pfQuest = true,
    ["pfQuest-tbc"] = true,
    ["pfQuest-wotlk"] = true,
    ["pfQuest-turtle"] = true,
  },
  utilityWidth = 72,
  languageWidth = 86,
  utilityHeight = 16,
  actionWidth = 52,
  actionHeight = 20,
  actionGap = 4,
}

local TRACKER_PAPER = {
  contract = "1.0",
  caps = {
    left = 14,
    right = 14,
    top = 12,
    bottom = 16,
  },
  slices = {
    topLeft = { 0, 0.09375, 0, 0.0625 },
    top = { 0.09375, 0.6484375, 0, 0.0625 },
    topRight = { 0.6484375, 0.7421875, 0, 0.0625 },
    left = { 0, 0.09375, 0.0625, 0.890625 },
    center = {
      0.09375,
      0.6484375,
      0.0625,
      0.890625,
    },
    right = {
      0.6484375,
      0.7421875,
      0.0625,
      0.890625,
    },
    bottomLeft = { 0, 0.09375, 0.890625, 1 },
    bottom = { 0.09375, 0.6484375, 0.890625, 1 },
    bottomRight = { 0.6484375, 0.7421875, 0.890625, 1 },
  },
}

local QUEST_SEAL = {
  contract = "1.1",
  topOutset = 18,
  states = {
    normal = { 0, 0.25, 0, 1 },
    hover = { 0.25, 0.5, 0, 1 },
    pressed = { 0.5, 0.75, 0, 1 },
    disabled = { 0.75, 1, 0, 1 },
  },
  questLog = {
    width = 32,
    height = 32,
    left = 576,
    top = 68,
  },
  tracker = {
    width = 34,
    height = 34,
  },
}

local function HasPfQuestQuestLogControls(provider)
  return
    provider and
    (
      provider.buttonOnline or
      provider.buttonLanguage or
      provider.buttonShow or
      provider.buttonHide or
      provider.buttonClean or
      provider.buttonReset
    )
end

local function SetSize(frame, width, height)
  if not frame then
    return
  end
  if frame.SetWidth then
    frame:SetWidth(width)
  end
  if frame.SetHeight then
    frame:SetHeight(height)
  end
end

local function SetSinglePoint(
  frame,
  point,
  relativeTo,
  relativePoint,
  x,
  y
)
  if not frame or not frame.ClearAllPoints or not frame.SetPoint then
    return
  end
  frame:ClearAllPoints()
  frame:SetPoint(point, relativeTo, relativePoint, x, y)
end

local function MakeBackdropTransparent(frame)
  if frame and frame.backdrop then
    if frame.backdrop.SetBackdropColor then
      frame.backdrop:SetBackdropColor(0, 0, 0, 0)
    end
    if frame.backdrop.SetBackdropBorderColor then
      frame.backdrop:SetBackdropBorderColor(0, 0, 0, 0)
    end
    if frame.backdrop.Hide then
      frame.backdrop:Hide()
    end
  end
  if frame and frame.shadow and frame.shadow.SetAlpha then
    frame.shadow:SetAlpha(0)
  end
end

local function IsTexture(region)
  if not region then
    return false
  end
  if region.IsObjectType then
    return region:IsObjectType("Texture")
  end
  if region.GetObjectType then
    return region:GetObjectType() == "Texture"
  end
  return false
end

local function CaptureAndHideNativeTextures(frame)
  if not frame or not frame.GetRegions then
    return
  end

  if not frame.aeuiQuestNativeTextures then
    frame.aeuiQuestNativeTextures = {}
    local regions = { frame:GetRegions() }
    for _, region in ipairs(regions) do
      if
        IsTexture(region) and
        not region.aeuiQuestManaged
      then
        table.insert(frame.aeuiQuestNativeTextures, region)
      end
    end
  end

  for _, region in ipairs(frame.aeuiQuestNativeTextures) do
    if region.Hide then
      region:Hide()
    elseif region.SetAlpha then
      region:SetAlpha(0)
    end
  end
end

local function AppendScript(frame, scriptName, key, callback)
  if not frame or not frame.GetScript or not frame.SetScript then
    return
  end
  if frame[key] then
    return
  end

  frame[key] = true
  local original = frame:GetScript(scriptName)
  frame:SetScript(scriptName, function(a1, a2, a3, a4, a5)
    if original then
      original(a1, a2, a3, a4, a5)
    end
    callback(a1, a2, a3, a4, a5)
  end)
end

local function SetTextColor(text, color)
  if not text or not text.SetTextColor or not color then
    return
  end
  text:SetTextColor(color[1], color[2], color[3], color[4])
end

local function ResolveThemeFontPath(font)
  if not font then
    return nil
  end

  if
    font.providerOwned and
    type(pfUI) == "table" and
    pfUI.font_default
  then
    return pfUI.font_default
  end

  return font.path or font.fallbackPath
end

local function ApplyThemeFont(text, font, fallbackSize)
  if not text or not text.SetFont or not font then
    return
  end

  local size = fallbackSize or font.size
  if text.GetFont then
    local _, currentSize = text:GetFont()
    size = tonumber(currentSize) or size
  end
  if size then
    local path = ResolveThemeFontPath(font)
    if path then
      text:SetFont(path, size, font.flags or "")
    end
  end
end

local function ApplyThemeFontFixed(text, font)
  if not text or not text.SetFont or not font then
    return
  end
  local path = ResolveThemeFontPath(font)
  if path and font.size then
    text:SetFont(path, font.size, font.flags or "")
  end
end

local function ApplyTrackerProviderFont(text)
  if not text or not text.SetFont then
    return
  end

  local role = THEME.fonts.trackerQuestName
  local currentPath
  local currentSize
  if text.GetFont then
    currentPath, currentSize = text:GetFont()
  end

  local providerPath = currentPath
  if type(pfUI) == "table" and pfUI.font_default then
    providerPath = pfUI.font_default
  end
  providerPath = providerPath or role.fallbackPath

  local size = tonumber(currentSize) or role.size
  if providerPath and size then
    text:SetFont(providerPath, size, role.flags or "")
  end
end

local function ClearTextShadow(text)
  if text and text.SetShadowColor then
    text:SetShadowColor(0, 0, 0, 0)
  end
  if text and text.SetShadowOffset then
    text:SetShadowOffset(0, 0)
  end
end

local function ApplyDirectoryFontString(text)
  if not text or not text.SetFont then
    return
  end
  local role = THEME.fonts.questName
  local path = ResolveThemeFontPath(role)
  if path then
    text:SetFont(path, role.size, role.flags or "")
  end
  ClearTextShadow(text)
end

local DIRECTORY_TEXT_SUFFIXES = {
  "Text",
  "Tag",
  "QuestTag",
  "Status",
  "Complete",
}

local function HasVisibleDirectoryText(text)
  if not text or not text.GetText then
    return false
  end
  local value = text:GetText()
  return value and string.find(value, "%S") and true or false
end

local function ContainsDirectoryToken(value, token)
  if not value or not token then
    return false
  end
  local rendered = tostring(token)
  return rendered ~= "" and
    string.find(value, rendered, 1, true) and
    true or false
end

local function ResolveRenderedDirectoryTagInk(
  text,
  questTypeColor,
  completionColor
)
  if not HasVisibleDirectoryText(text) then
    return nil
  end

  local value = text:GetText()
  if ContainsDirectoryToken(value, FAILED) then
    return THEME.ink.failed
  end
  if ContainsDirectoryToken(value, COMPLETE) then
    return completionColor or THEME.ink.complete
  end

  -- QuestLogTitleNTag is the rendered source of truth. Turtle/pfQuest can
  -- show a localized type label even when the API tag used by the adapter is
  -- absent or differs from that label, so every other non-empty Tag uses the
  -- stable quest-type ink instead of inheriting the quest difficulty colour.
  return questTypeColor or THEME.ink.questType
end

local function CollectDirectoryTagTexts(row)
  local texts = {}
  local seen = {}
  local function Add(text)
    if text and text.SetTextColor and not seen[text] then
      seen[text] = true
      table.insert(texts, text)
    end
  end

  if row and row.GetName then
    local name = row:GetName()
    if name then
      Add(_G[name .. "Tag"])
      Add(_G[name .. "QuestTag"])
    end
  end
  if row then
    Add(row.tag)
    Add(row.questTag)
  end
  if row and row.GetRegions then
    for _, region in ipairs({ row:GetRegions() }) do
      local regionName =
        region and region.GetName and region:GetName()
      if
        regionName and
        string.find(string.lower(regionName), "tag", 1, true)
      then
        Add(region)
      end
    end
  end
  return texts
end

local function LockDirectoryTagInk(text, color)
  if not text or not text.SetTextColor then
    return
  end
  if not color then
    text.aeuiQuestSemanticInk = nil
    return
  end

  -- Native QuestLog_Update, selection, hover and late providers all write
  -- directly to this same FontString. A one-shot SetTextColor therefore loses
  -- to whichever writer runs last. Wrap the real FontString setter so every
  -- later write is constrained to its current semantic ink without polling.
  if text.SetTextColor ~= text.aeuiQuestSemanticInkLock then
    local downstream = text.SetTextColor
    local lock = function(self, red, green, blue, alpha)
      local semantic = self.aeuiQuestSemanticInk
      if semantic then
        return downstream(
          self,
          semantic[1],
          semantic[2],
          semantic[3],
          semantic[4]
        )
      end
      return downstream(self, red, green, blue, alpha)
    end
    text.aeuiQuestSemanticInkSetter = downstream
    text.aeuiQuestSemanticInkLock = lock
    text.SetTextColor = lock
  end

  text.aeuiQuestSemanticInk = color
  text:SetTextColor(color[1], color[2], color[3], color[4])
end

local function RestoreDirectoryTagInk(row)
  if not row or not row.GetName then
    return
  end
  local applied
  for _, text in ipairs(CollectDirectoryTagTexts(row)) do
    local color = ResolveRenderedDirectoryTagInk(
      text,
      row.aeuiQuestTypeColor,
      row.aeuiQuestCompletionColor
    )
    if color then
      LockDirectoryTagInk(text, color)
      applied = color
    else
      LockDirectoryTagInk(text, nil)
    end
  end

  row.aeuiQuestRenderedTagColor = applied
  row.aeuiQuestTagInkLocked = applied and true or nil
end

-- Turtle's QuestLogTitle template variants may expose completion and type
-- labels either through the Button's main FontString or as sibling regions.
-- Restyle every real text region after the provider update so those labels do
-- not fall back to Blizzard's smaller outlined font.
local function ApplyDirectoryTypography(
  row,
  statusColor,
  questTypeColor,
  completionColor
)
  if not row then
    return
  end

  row.aeuiQuestTypeColor = questTypeColor
  row.aeuiQuestCompletionColor = completionColor

  ApplyDirectoryFontString(row)
  local mainText
  if row.GetFontString then
    mainText = row:GetFontString()
    ApplyDirectoryFontString(mainText)
  end

  if row.GetRegions then
    local regions = { row:GetRegions() }
    for _, region in ipairs(regions) do
      local isFontString = false
      if region and region.IsObjectType then
        isFontString = region:IsObjectType("FontString")
      elseif region and region.GetObjectType then
        isFontString = region:GetObjectType() == "FontString"
      end
      if isFontString then
        ApplyDirectoryFontString(region)
        if statusColor and region ~= mainText then
          SetTextColor(region, statusColor)
        end
      end
    end
  end

  if row.GetName then
    local name = row:GetName()
    if name then
      for _, suffix in ipairs(DIRECTORY_TEXT_SUFFIXES) do
        local text = _G[name .. suffix]
        ApplyDirectoryFontString(text)
        if text and text ~= mainText then
          local color = statusColor
          if suffix == "Tag" or suffix == "QuestTag" then
            color = ResolveRenderedDirectoryTagInk(
              text,
              questTypeColor,
              completionColor
            )
          elseif suffix == "Complete" then
            color = completionColor or statusColor
          end
          if color then
            SetTextColor(text, color)
          end
        end
      end
    end
  end
  RestoreDirectoryTagInk(row)
end

local function ResolveDirectoryStatusInks(questTag, isComplete)
  local questTypeColor
  if questTag and questTag ~= "" then
    questTypeColor = THEME.ink.questType
  end

  local completionColor
  if isComplete == 1 or isComplete == true then
    completionColor = THEME.ink.complete
  elseif isComplete == -1 or isComplete == "-1" then
    completionColor = THEME.ink.failed
  end

  return
    completionColor or questTypeColor,
    questTypeColor,
    completionColor
end

-- Some Turtle templates keep quest type/completion text inside the main
-- FontString instead of a named sibling. Only recolor markup after the real
-- quest title so provider-owned level and title text keep the shared
-- difficulty ink. A localized questTag in that suffix receives quest-type ink;
-- completion/failure suffixes retain their own semantic ink.
local function FindInlineParenthetical(value, startAt)
  local asciiStart = string.find(value, "(", startAt or 1, true)
  local wideStart = string.find(value, "（", startAt or 1, true)
  local openAt
  local closeToken
  if asciiStart and (not wideStart or asciiStart < wideStart) then
    openAt = asciiStart
    closeToken = ")"
  elseif wideStart then
    openAt = wideStart
    closeToken = "）"
  end
  if not openAt then
    return nil
  end
  local closeAt = string.find(value, closeToken, openAt + 1, true)
  if not closeAt then
    return nil
  end
  return openAt, closeAt + string.len(closeToken) - 1
end

local function ApplyInlineInk(value, first, last, color, baseColor)
  if not first or not last or not color or not color.code then
    return value
  end
  local reset =
    (baseColor and baseColor.code) or THEME.ink.body.code
  return
    string.sub(value, 1, first - 1) ..
    color.code ..
    string.sub(value, first, last) ..
    reset ..
    string.sub(value, last + 1)
end

local function NormalizeDirectoryInlineStatus(
  text,
  title,
  questTag,
  statusColor,
  questTypeColor,
  completionColor,
  baseColor
)
  if
    not text or
    not text.GetText or
    not text.SetText or
    not title or
    not statusColor
  then
    return
  end

  local value = text:GetText()
  if not value then
    return
  end

  local _, titleEnd = string.find(value, title, 1, true)
  if not titleEnd then
    return
  end

  local prefix = string.sub(value, 1, titleEnd)
  local suffix = string.sub(value, titleEnd + 1)
  -- Turtle templates do not consistently expose the localized type label as
  -- a sibling FontString, and some omit an opening color escape entirely.
  -- Remove provider escapes first, then inject semantic ink around the real
  -- rendered parenthetical label instead of merely replacing existing codes.
  local normalized = string.gsub(
    suffix,
    "|[cC]%x%x%x%x%x%x%x%x",
    ""
  )
  normalized = string.gsub(normalized, "|[rR]", "")

  local firstStart, firstEnd = FindInlineParenthetical(normalized, 1)
  local secondStart, secondEnd
  if firstEnd then
    secondStart, secondEnd =
      FindInlineParenthetical(normalized, firstEnd + 1)
  end

  if questTypeColor then
    if not firstStart and questTag then
      local renderedTag = tostring(questTag)
      firstStart, firstEnd =
        string.find(normalized, renderedTag, 1, true)
    end
    if firstStart then
      if completionColor and secondStart then
        normalized = ApplyInlineInk(
          normalized,
          secondStart,
          secondEnd,
          completionColor,
          baseColor
        )
      end
      normalized = ApplyInlineInk(
        normalized,
        firstStart,
        firstEnd,
        questTypeColor,
        baseColor
      )
    elseif normalized ~= "" then
      normalized =
        questTypeColor.code ..
        normalized ..
        ((baseColor and baseColor.code) or THEME.ink.body.code)
    end
  elseif statusColor then
    if firstStart then
      normalized = ApplyInlineInk(
        normalized,
        firstStart,
        firstEnd,
        statusColor,
        baseColor
      )
    elseif normalized ~= "" then
      normalized =
        statusColor.code ..
        normalized ..
        ((baseColor and baseColor.code) or THEME.ink.body.code)
    end
  end
  text:SetText(prefix .. normalized)
end

local function MapDifficultyInk(red, green, blue)
  red = tonumber(red)
  green = tonumber(green)
  blue = tonumber(blue)
  if not red or not green or not blue then
    return THEME.ink.difficulty.normal
  end

  for _, color in pairs(THEME.ink.difficulty) do
    if
      math.abs(red - color[1]) < 0.002 and
      math.abs(green - color[2]) < 0.002 and
      math.abs(blue - color[3]) < 0.002
    then
      return color
    end
  end

  if red >= 0.80 and green <= 0.25 then
    return THEME.ink.difficulty.impossible
  elseif red >= 0.75 and green < 0.75 then
    return THEME.ink.difficulty.hard
  elseif green >= 0.55 and red < 0.65 then
    return THEME.ink.difficulty.easy
  elseif red < 0.70 and green < 0.70 and blue < 0.70 then
    return THEME.ink.difficulty.trivial
  end
  return THEME.ink.difficulty.normal
end

local function ResolveDifficultyInk(level, text)
  level = tonumber(level)
  if level and type(GetDifficultyColor) == "function" then
    local color, green, blue = GetDifficultyColor(level)
    if type(color) == "table" then
      return MapDifficultyInk(color.r, color.g, color.b)
    elseif tonumber(color) then
      return MapDifficultyInk(color, green, blue)
    end
  end

  if level and type(UnitLevel) == "function" then
    local playerLevel = tonumber(UnitLevel("player"))
    if playerLevel then
      local delta = level - playerLevel
      if delta >= 5 then
        return THEME.ink.difficulty.impossible
      elseif delta >= 3 then
        return THEME.ink.difficulty.hard
      elseif delta >= -2 then
        return THEME.ink.difficulty.normal
      elseif delta >= -5 then
        return THEME.ink.difficulty.easy
      end
      return THEME.ink.difficulty.trivial
    end
  end

  if text and text.GetTextColor then
    local red, green, blue = text:GetTextColor()
    if red ~= nil then
      return MapDifficultyInk(red, green, blue)
    end
  end

  return THEME.ink.difficulty.normal
end

-- Quest Log and Tracker task names deliberately share this single resolver.
-- Completion, failure and quest-type labels keep their own semantic ink; the
-- task name itself is always the same difficulty ink on both surfaces.
local function ResolveQuestNameInk(level, text)
  return ResolveDifficultyInk(level, text)
end

function Quests:Initialize()
  self:CaptureQuestLogBaseGeometry()
  self.driver = CreateFrame(
    "Frame",
    "AzerothExpeditionUIQuestDriver",
    UIParent
  )
  self.driver:RegisterEvent("PLAYER_ENTERING_WORLD")
  self.driver:RegisterEvent("ADDON_LOADED")
  self.driver:SetScript("OnEvent", function()
    local loadedAddon = arg1
    if
      event == "PLAYER_ENTERING_WORLD" or
      (
        event == "ADDON_LOADED" and
        (
          loadedAddon == "Blizzard_QuestUI" or
          loadedAddon == "Blizzard_QuestLog" or
          PFQUEST.addons[loadedAddon]
        )
      )
    then
      addon:ScheduleRefresh(0)
    end
  end)
  self:InstallGlobalHooks()
end

function Quests:ScheduleQuestLogReflow(passes)
  local requested = tonumber(passes) or 2
  if requested < 1 then
    requested = 1
  end
  local pending = tonumber(self.questLogReflowPasses) or 0
  if requested > pending then
    self.questLogReflowPasses = requested
  end
  if self.driver and self.driver.SetScript then
    self.driver:SetScript("OnUpdate", function()
      Quests:RunDeferredQuestLogReflow()
    end)
  end
end

-- FontString wrapping and reward anchors are not guaranteed to expose their
-- final screen coordinates in the same frame that pfQuest writes translated
-- text. Reconcile the live rows and detail child for two frames, then stop.
-- This is deliberately finite and never becomes a geometry maintenance loop.
function Quests:RunDeferredQuestLogReflow()
  local pending = tonumber(self.questLogReflowPasses) or 0
  if pending < 1 then
    self.questLogReflowPasses = nil
    if self.driver and self.driver.SetScript then
      self.driver:SetScript("OnUpdate", nil)
    end
    return
  end

  self.questLogReflowPasses = pending - 1
  if
    addon.db and
    addon.db.quests.enabled and
    QuestLogFrame
  then
    self:UpdateDirectoryRows()
    self:ApplyPfQuestQuestLogCompatibility()
    self:ApplyDetailTextGeometry(true)
    self:UpdateActionButtonStates()
  end

  if self.questLogReflowPasses < 1 then
    self.questLogReflowPasses = nil
    if self.driver and self.driver.SetScript then
      self.driver:SetScript("OnUpdate", nil)
    end
  end
end

local function GetPfQuestTracker()
  if pfQuestMapTracker then
    return pfQuestMapTracker
  end
  if pfQuest and pfQuest.tracker then
    return pfQuest.tracker
  end
  return nil
end

local function ConfigureTrackerPaperTexture(texture, texcoord)
  if not texture or not texcoord then
    return
  end
  texture.aeuiQuestManaged = true
  texture:SetTexture(TRACKER_PAPER_TEXTURE)
  texture:SetTexCoord(
    texcoord[1],
    texcoord[2],
    texcoord[3],
    texcoord[4]
  )
  texture:SetVertexColor(1, 1, 1, 1)
  texture:Show()
end

local function ConfigureQuestSealTexture(texture, state)
  if not texture then
    return
  end
  local texcoord = QUEST_SEAL.states[state or "normal"]
  texture.aeuiQuestManaged = true
  texture:SetTexture(QUEST_SEAL_TEXTURE)
  texture:SetTexCoord(
    texcoord[1],
    texcoord[2],
    texcoord[3],
    texcoord[4]
  )
  texture:SetVertexColor(1, 1, 1, 1)
  texture:Show()
end

function Quests:ApplyTrackerSealClampInset(tracker)
  if not tracker or not tracker.SetClampRectInsets then
    return
  end
  if not tracker.aeuiQuestBaseClampInsets then
    local left, right, top, bottom = 0, 0, 0, 0
    if tracker.GetClampRectInsets then
      left, right, top, bottom = tracker:GetClampRectInsets()
      left = tonumber(left) or 0
      right = tonumber(right) or 0
      top = tonumber(top) or 0
      bottom = tonumber(bottom) or 0
    end
    tracker.aeuiQuestBaseClampInsets = {
      left,
      right,
      top,
      bottom,
    }
  end
  local base = tracker.aeuiQuestBaseClampInsets
  tracker:SetClampRectInsets(
    base[1],
    base[2],
    base[3] + QUEST_SEAL.topOutset,
    base[4]
  )
end

function Quests:EnsurePfQuestTrackerHubSeal(tracker)
  if not tracker or not tracker.CreateTexture then
    return
  end
  if not tracker.aeuiQuestHubSeal then
    -- Parent ARTWORK stays below pfQuest's child Button frames. The seal is a
    -- visual underlay only until a separately authorized hub menu preserves
    -- all seven provider actions.
    tracker.aeuiQuestHubSeal = tracker:CreateTexture(nil, "ARTWORK")
  end
  local texture = tracker.aeuiQuestHubSeal
  ConfigureQuestSealTexture(texture, "normal")
  SetSize(
    texture,
    QUEST_SEAL.tracker.width,
    QUEST_SEAL.tracker.height
  )
  SetSinglePoint(
    texture,
    "TOP",
    tracker,
    "TOP",
    0,
    QUEST_SEAL.topOutset
  )
  self:ApplyTrackerSealClampInset(tracker)
  tracker.aeuiQuestSealRuntimeContract = QUEST_SEAL.contract
end

local function AnchorTrackerHorizontal(
  texture,
  left,
  right,
  height,
  verticalPoint
)
  texture:ClearAllPoints()
  texture:SetPoint(
    verticalPoint .. "LEFT",
    left,
    verticalPoint .. "RIGHT",
    0,
    0
  )
  texture:SetPoint(
    verticalPoint .. "RIGHT",
    right,
    verticalPoint .. "LEFT",
    0,
    0
  )
  texture:SetHeight(height)
end

local function AnchorTrackerVertical(
  texture,
  top,
  bottom,
  width,
  horizontalPoint
)
  texture:ClearAllPoints()
  texture:SetPoint(
    "TOP" .. horizontalPoint,
    top,
    "BOTTOM" .. horizontalPoint,
    0,
    0
  )
  texture:SetPoint(
    "BOTTOM" .. horizontalPoint,
    bottom,
    "TOP" .. horizontalPoint,
    0,
    0
  )
  texture:SetWidth(width)
end

function Quests:LayoutPfQuestTrackerPaper(tracker, force)
  if not tracker or not tracker.aeuiQuestPaperSlices then
    return
  end

  local width = tonumber(tracker:GetWidth()) or 0
  local height = tonumber(tracker:GetHeight()) or 0
  if width < 1 or height < 1 then
    return
  end
  if
    not force and
    tracker.aeuiQuestPaperWidth == width and
    tracker.aeuiQuestPaperHeight == height
  then
    return
  end

  local leftWidth = math.min(
    TRACKER_PAPER.caps.left,
    math.max(1, math.floor((width - 1) / 2))
  )
  local rightWidth = math.min(
    TRACKER_PAPER.caps.right,
    math.max(1, width - leftWidth - 1)
  )
  local topHeight = math.min(
    TRACKER_PAPER.caps.top,
    math.max(1, math.floor((height - 1) / 2))
  )
  local bottomHeight = math.min(
    TRACKER_PAPER.caps.bottom,
    math.max(1, height - topHeight - 1)
  )
  local slices = tracker.aeuiQuestPaperSlices

  SetSize(slices.topLeft, leftWidth, topHeight)
  SetSinglePoint(
    slices.topLeft,
    "TOPLEFT",
    tracker,
    "TOPLEFT",
    0,
    0
  )
  SetSize(slices.topRight, rightWidth, topHeight)
  SetSinglePoint(
    slices.topRight,
    "TOPRIGHT",
    tracker,
    "TOPRIGHT",
    0,
    0
  )
  SetSize(slices.bottomLeft, leftWidth, bottomHeight)
  SetSinglePoint(
    slices.bottomLeft,
    "BOTTOMLEFT",
    tracker,
    "BOTTOMLEFT",
    0,
    0
  )
  SetSize(slices.bottomRight, rightWidth, bottomHeight)
  SetSinglePoint(
    slices.bottomRight,
    "BOTTOMRIGHT",
    tracker,
    "BOTTOMRIGHT",
    0,
    0
  )

  AnchorTrackerHorizontal(
    slices.top,
    slices.topLeft,
    slices.topRight,
    topHeight,
    "TOP"
  )
  AnchorTrackerHorizontal(
    slices.bottom,
    slices.bottomLeft,
    slices.bottomRight,
    bottomHeight,
    "BOTTOM"
  )
  AnchorTrackerVertical(
    slices.left,
    slices.topLeft,
    slices.bottomLeft,
    leftWidth,
    "LEFT"
  )
  AnchorTrackerVertical(
    slices.right,
    slices.topRight,
    slices.bottomRight,
    rightWidth,
    "RIGHT"
  )
  slices.center:ClearAllPoints()
  slices.center:SetPoint(
    "TOPLEFT",
    slices.topLeft,
    "BOTTOMRIGHT",
    0,
    0
  )
  slices.center:SetPoint(
    "BOTTOMRIGHT",
    slices.bottomRight,
    "TOPLEFT",
    0,
    0
  )

  tracker.aeuiQuestPaperWidth = width
  tracker.aeuiQuestPaperHeight = height
end

local function GetTextValue(text)
  if text and text.GetText then
    return text:GetText()
  end
  return text and text.text or nil
end

local function SetTextValue(text, value)
  if text and text.SetText and value ~= nil then
    text:SetText(value)
  end
end

local function ReadTrackerLevel(value)
  if not value then
    return nil
  end
  local _, _, level = string.find(value, "^%[(%d+)%+?%]")
  return tonumber(level)
end

local function NormalizeTrackerTitle(value, progressColor)
  if not value then
    return nil
  end
  value = string.gsub(
    value,
    "|cffaaaaaa",
    THEME.ink.muted.code
  )
  value = string.gsub(
    value,
    "|c[fF][fF]%x%x%x%x%x%x(%d+%%)",
    progressColor.code .. "%1"
  )
  return value
end

local function NormalizeTrackerObjective(value)
  if not value then
    return nil
  end
  if not string.find(value, "|r") then
    return string.gsub(
      value,
      "|c[fF][fF][fF][fF][fF][fF][fF][fF]",
      ""
    )
  end
  return string.gsub(
    value,
    "|c[fF][fF][fF][fF][fF][fF][fF][fF]",
    THEME.ink.body.code
  )
end

local function SuppressPfQuestTrackerEntryIcon(button)
  local metrics = THEME.metrics.tracker
  if not button or not metrics.hideEntryIcons then
    return
  end

  local icon = button.icon
  if icon then
    if icon.Hide then
      icon:Hide()
    elseif icon.SetAlpha then
      icon:SetAlpha(0)
    end
  end
  button.aeuiQuestEntryIconThemeContract = THEME.contract
end

function Quests:ApplyPfQuestTrackerEntryTheme(
  tracker,
  button,
  force
)
  if not button then
    return false
  end
  if
    not force and
    button.aeuiQuestVisualThemeContract == THEME.contract
  then
    return false
  end

  SuppressPfQuestTrackerEntryIcon(button)

  local titleText = button.text
  if titleText then
    local value = GetTextValue(titleText)
    local progress = tonumber(button.perc)
    local progressColor = THEME.ink.active
    if progress and progress >= 100 then
      progressColor = THEME.ink.complete
    elseif progress and progress <= 0 then
      progressColor = THEME.ink.incomplete
    end

    local mode = tracker and tracker.mode or "QUEST_TRACKING"
    local titleColor
    if mode == "DATABASE_TRACKING" then
      titleColor = THEME.ink.database
    else
      titleColor = ResolveQuestNameInk(
        button.level or ReadTrackerLevel(value),
        titleText
      )
    end

    SetTextValue(
      titleText,
      NormalizeTrackerTitle(value, progressColor)
    )
    SetTextColor(titleText, titleColor)
    ApplyTrackerProviderFont(titleText)
    ClearTextShadow(titleText)
  end

  if button.objectives then
    for _, objective in pairs(button.objectives) do
      local value = GetTextValue(objective)
      local normalized = NormalizeTrackerObjective(value)
      SetTextValue(objective, normalized)

      local color = THEME.ink.body
      if normalized then
        local _, _, current, required = string.find(
          normalized,
          "(%d+)%s*/%s*(%d+)"
        )
        current = tonumber(current)
        required = tonumber(required)
        if current and required then
          if current >= required then
            color = THEME.ink.complete
          else
            color = THEME.ink.incomplete
          end
        elseif tonumber(button.perc) == 100 then
          color = THEME.ink.complete
        end
      end
      SetTextColor(objective, color)
      ClearTextShadow(objective)
    end
  end

  button.aeuiQuestVisualThemeContract = THEME.contract
  return true
end

function Quests:RefreshPfQuestTrackerWidth(tracker)
  if not tracker or not tracker.buttons or not tracker.SetWidth then
    return
  end

  local width = 100
  local measured = false
  for _, button in pairs(tracker.buttons) do
    if button and not button.empty then
      if button.text and button.text.GetStringWidth then
        width = math.max(width, button.text:GetStringWidth())
        measured = true
      end
      if button.objectives then
        for _, objective in pairs(button.objectives) do
          if
            objective and
            objective.GetStringWidth and
            (
              not objective.IsShown or
              objective:IsShown()
            )
          then
            width = math.max(width, objective:GetStringWidth())
            measured = true
          end
        end
      end
    end
  end

  if measured then
    tracker:SetWidth(math.min(width, 300) + 30)
  end
end

function Quests:ApplyPfQuestTrackerContentSafeHeight(tracker)
  if not tracker or not tracker.SetHeight then
    return
  end

  local metrics = THEME.metrics.tracker
  local contentHeight = metrics.providerPanelHeight
  if tracker.panel and tracker.panel.GetHeight then
    contentHeight =
      tonumber(tracker.panel:GetHeight()) or contentHeight
  end

  if tracker.buttons then
    for _, button in pairs(tracker.buttons) do
      if button and not button.empty and button.GetHeight then
        contentHeight =
          contentHeight + (tonumber(button:GetHeight()) or 0)
      end
    end
  end

  local targetHeight =
    contentHeight + metrics.bottomContentPadding
  if
    not tracker.GetHeight or
    tonumber(tracker:GetHeight()) ~= targetHeight
  then
    tracker:SetHeight(targetHeight)
  end
  tracker.aeuiQuestProviderContentHeight = contentHeight
  tracker.aeuiQuestBottomContentPadding =
    metrics.bottomContentPadding
  tracker.aeuiQuestContentSafeThemeContract = THEME.contract
end

function Quests:InstallPfQuestTrackerEntryThemeHooks(
  tracker,
  button
)
  if not button then
    return
  end

  local function InvalidateEntryTheme()
    -- pfQuest rewrites the dynamic icon during ButtonEvent. Suppress only the
    -- visual Texture immediately so it cannot flash for one frame; theme,
    -- width and height still commit once after the full provider rebuild.
    SuppressPfQuestTrackerEntryIcon(button)
    button.aeuiQuestVisualThemeContract = nil
    tracker.aeuiQuestVisualThemeDirty = true
  end

  AppendScript(
    button,
    "OnEvent",
    "aeuiQuestVisualThemeOnEventHooked",
    InvalidateEntryTheme
  )
  AppendScript(
    button,
    "OnClick",
    "aeuiQuestVisualThemeOnClickHooked",
    InvalidateEntryTheme
  )
  AppendScript(
    button,
    "OnShow",
    "aeuiQuestVisualThemeOnShowHooked",
    InvalidateEntryTheme
  )
end

function Quests:StylePfQuestTrackerEntries(tracker)
  if not tracker or not tracker.buttons then
    return
  end

  local changed = false
  local needsCommit = tracker.aeuiQuestVisualThemeDirty
  for _, button in pairs(tracker.buttons) do
    if button then
      -- pfQuest's own ButtonUpdate may recolor this region after creation.
      -- Keep the provider row rectangle suppressed without touching geometry.
      if button.bg and button.bg.Hide then
        button.bg:Hide()
      elseif button.bg and button.bg.SetAlpha then
        button.bg:SetAlpha(0)
      end
      button.aeuiQuestPaperOnlyStyled = true
      self:InstallPfQuestTrackerEntryThemeHooks(tracker, button)
      if self:ApplyPfQuestTrackerEntryTheme(tracker, button) then
        changed = true
      end
    end
  end

  if
    changed or
    needsCommit or
    tracker.aeuiQuestContentSafeThemeContract ~= THEME.contract
  then
    self:RefreshPfQuestTrackerWidth(tracker)
    self:ApplyPfQuestTrackerContentSafeHeight(tracker)
    tracker.aeuiQuestVisualThemeDirty = nil
  end
  tracker.aeuiQuestVisualThemeContract = THEME.contract
end

function Quests:ApplyPfQuestTrackerPaper()
  local tracker = GetPfQuestTracker()
  if not tracker or not tracker.CreateTexture then
    return
  end

  if tracker.backdrop and tracker.backdrop.bg then
    if tracker.backdrop.bg.Hide then
      tracker.backdrop.bg:Hide()
    elseif tracker.backdrop.bg.SetAlpha then
      tracker.backdrop.bg:SetAlpha(0)
    end
  end

  if not tracker.aeuiQuestPaperSlices then
    tracker.aeuiQuestPaperSlices = {}
    for key, texcoord in pairs(TRACKER_PAPER.slices) do
      local texture = tracker:CreateTexture(nil, "BACKGROUND")
      ConfigureTrackerPaperTexture(texture, texcoord)
      tracker.aeuiQuestPaperSlices[key] = texture
    end
  else
    for key, texture in pairs(tracker.aeuiQuestPaperSlices) do
      ConfigureTrackerPaperTexture(
        texture,
        TRACKER_PAPER.slices[key]
      )
    end
  end

  AppendScript(
    tracker,
    "OnShow",
    "aeuiQuestTrackerPaperOnShowHooked",
    function()
      Quests:StylePfQuestTrackerEntries(tracker)
      Quests:LayoutPfQuestTrackerPaper(tracker, true)
      Quests:EnsurePfQuestTrackerHubSeal(tracker)
    end
  )
  AppendScript(
    tracker,
    "OnUpdate",
    "aeuiQuestTrackerPaperOnUpdateHooked",
    function()
      Quests:StylePfQuestTrackerEntries(tracker)
      Quests:LayoutPfQuestTrackerPaper(tracker)
    end
  )

  self:StylePfQuestTrackerEntries(tracker)
  self:LayoutPfQuestTrackerPaper(tracker, true)
  self:EnsurePfQuestTrackerHubSeal(tracker)
  tracker.aeuiQuestTrackerRuntimeContract =
    TRACKER_PAPER.contract
end

function Quests:CaptureQuestLogBaseGeometry()
  local title = QuestLogDescriptionTitle
  if
    self.questLogDescriptionTitleHeight == nil and
    title and
    title.GetHeight
  then
    local height = tonumber(title:GetHeight()) or 0
    -- AEUI normally loads before pfQuest, but dependency ordering is not a
    -- contract between two pfUI dependants. If the provider is already loaded,
    -- its controls prove that the title has received the provider's +30px
    -- reservation; capture the native height rather than the modified height.
    if HasPfQuestQuestLogControls(pfQuest) then
      height = math.max(0, height - 30)
    end
    self.questLogDescriptionTitleHeight = height
  end
end

function Quests:InstallGlobalPostHook(name, key, callback)
  if type(hooksecurefunc) ~= "function" then
    return
  end

  local current = _G[name]
  if type(current) ~= "function" then
    return
  end

  self.globalPostHooks = self.globalPostHooks or {}
  if self.globalPostHooks[key] == current then
    return
  end

  -- pfUI's Vanilla hooksecurefunc implementation keys wrappers by callback
  -- identity. Use a fresh closure whenever a late provider replaces a global,
  -- then remember the resulting wrapper so normal refreshes stay idempotent.
  local postHook = function(a1, a2, a3, a4, a5)
    callback(a1, a2, a3, a4, a5)
  end
  hooksecurefunc(name, postHook)
  self.globalPostHooks[key] = _G[name]
end

function Quests:InstallGlobalHooks()
  if
    type(QuestLog_OnShow) == "function"
  then
    self:InstallGlobalPostHook(
      "QuestLog_OnShow",
      "questLogOnShow",
      function()
        Quests:Apply()
      end
    )
  end

  if
    type(QuestLog_Update) == "function"
  then
    self:InstallGlobalPostHook(
      "QuestLog_Update",
      "questLogUpdate",
      function()
        Quests:UpdateDirectoryRows()
        Quests:ApplyPfQuestQuestLogCompatibility()
        Quests:UpdateActionButtonStates()
        Quests:ScheduleQuestLogReflow(2)
      end
    )
  end

  if
    type(QuestLog_UpdateQuestDetails) == "function"
  then
    self:InstallGlobalPostHook(
      "QuestLog_UpdateQuestDetails",
      "questLogDetails",
      function()
        Quests:ApplyDetailTextGeometry()
      end
    )
  end

  if type(QuestLogTitleButton_OnEnter) == "function" then
    self:InstallGlobalPostHook(
      "QuestLogTitleButton_OnEnter",
      "questLogTitleEnter",
      function(row)
        RestoreDirectoryTagInk(row or this)
      end
    )
  end

  if type(QuestLogTitleButton_OnLeave) == "function" then
    self:InstallGlobalPostHook(
      "QuestLogTitleButton_OnLeave",
      "questLogTitleLeave",
      function(row)
        RestoreDirectoryTagInk(row or this)
      end
    )
  end
end

function Quests:InstallQuestLogFrameOnShowHook()
  local frame = QuestLogFrame
  if not frame or not frame.GetScript or not frame.SetScript then
    return
  end

  local current = frame:GetScript("OnShow")
  if self.questLogFrameOnShowHook == current then
    return
  end

  local original = current
  local wrapper = function(a1, a2, a3, a4, a5)
    if original then
      original(a1, a2, a3, a4, a5)
    end
    Quests:Apply()
  end
  frame:SetScript("OnShow", wrapper)
  self.questLogFrameOnShowHook = wrapper
end

local function SetDirectoryState(texture, state)
  if not texture or not state then
    return
  end
  texture:SetTexCoord(
    state.left,
    state.right,
    state.top,
    state.bottom
  )
  texture:Show()
end

local function SetTextureColor(texture, color)
  if not texture or not texture.SetTexture or not color then
    return
  end
  texture:SetTexture(
    color[1],
    color[2],
    color[3],
    color[4]
  )
end

local function GetButtonText(button)
  if not button then
    return nil
  end
  if button.txt then
    return button.txt
  end
  if button.GetFontString then
    local text = button:GetFontString()
    if text then
      return text
    end
  end
  if button.GetName then
    local name = button:GetName()
    if name then
      return _G[name .. "Text"]
    end
  end
  return nil
end

local function ClearButtonStateTextures(button)
  if not button then
    return
  end
  if button.SetNormalTexture then
    button:SetNormalTexture("")
  end
  if button.SetHighlightTexture then
    button:SetHighlightTexture("")
  end
  if button.SetPushedTexture then
    button:SetPushedTexture("")
  end
  if button.SetDisabledTexture then
    button:SetDisabledTexture("")
  end
end

local function EnsureControlTexture(button, key, layer)
  if not button or not button.CreateTexture then
    return nil
  end
  if not button[key] then
    button[key] = button:CreateTexture(nil, layer)
    button[key].aeuiQuestManaged = true
  end
  return button[key]
end

local function AnchorHorizontalEdge(texture, button, edge)
  if not texture or not button then
    return
  end
  texture:ClearAllPoints()
  if edge == "TOP" then
    texture:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    texture:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
  else
    texture:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
    texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
  end
  texture:SetHeight(1)
end

local function AnchorVerticalEdge(texture, button, edge)
  if not texture or not button then
    return
  end
  texture:ClearAllPoints()
  if edge == "LEFT" then
    texture:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    texture:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
  else
    texture:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
    texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
  end
  texture:SetWidth(1)
end

local function SetButtonTextColor(button, color)
  local text = GetButtonText(button)
  if text and text.SetTextColor and color then
    text:SetTextColor(
      color[1],
      color[2],
      color[3],
      color[4]
    )
  end
end

local function UpdateLeatherButtonState(button)
  if not button or not button.aeuiQuestLeatherBase then
    return
  end

  local disabled =
    button.IsEnabled and not button:IsEnabled()
  button.aeuiQuestLeatherHover:Hide()
  button.aeuiQuestLeatherPressed:Hide()
  button.aeuiQuestLeatherDisabled:Hide()

  if disabled then
    button.aeuiQuestControlPressed = nil
    button.aeuiQuestLeatherDisabled:Show()
    SetButtonTextColor(button, CONTROL.text.disabled)
  elseif button.aeuiQuestControlPressed then
    button.aeuiQuestLeatherPressed:Show()
    SetButtonTextColor(button, CONTROL.text.pressed)
  elseif button.aeuiQuestControlHovered then
    button.aeuiQuestLeatherHover:Show()
    SetButtonTextColor(button, CONTROL.text.hover)
  else
    SetButtonTextColor(button, CONTROL.text.normal)
  end
end

local function InstallLeatherButtonHooks(button)
  AppendScript(
    button,
    "OnEnter",
    "aeuiQuestLeatherOnEnterHooked",
    function()
      button.aeuiQuestControlHovered = true
      UpdateLeatherButtonState(button)
    end
  )
  AppendScript(
    button,
    "OnLeave",
    "aeuiQuestLeatherOnLeaveHooked",
    function()
      button.aeuiQuestControlHovered = nil
      button.aeuiQuestControlPressed = nil
      UpdateLeatherButtonState(button)
    end
  )
  AppendScript(
    button,
    "OnMouseDown",
    "aeuiQuestLeatherOnMouseDownHooked",
    function(buttonName)
      local mouseButton = buttonName or arg1
      if
        not mouseButton or
        mouseButton == "LeftButton"
      then
        button.aeuiQuestControlPressed = true
        UpdateLeatherButtonState(button)
      end
    end
  )
  AppendScript(
    button,
    "OnMouseUp",
    "aeuiQuestLeatherOnMouseUpHooked",
    function(buttonName)
      local mouseButton = buttonName or arg1
      if
        not mouseButton or
        mouseButton == "LeftButton"
      then
        button.aeuiQuestControlPressed = nil
        UpdateLeatherButtonState(button)
      end
    end
  )
end

local function StyleLeatherButton(button, width, height)
  if not button then
    return
  end

  MakeBackdropTransparent(button)
  ClearButtonStateTextures(button)
  if button.icon and button.icon.Hide then
    button.icon:Hide()
  end
  SetSize(button, width, height)

  if not button.aeuiQuestLeatherBase then
    button.aeuiQuestLeatherBase =
      EnsureControlTexture(
        button,
        "aeuiQuestLeatherBase",
        "BACKGROUND"
      )
    button.aeuiQuestLeatherTop =
      EnsureControlTexture(
        button,
        "aeuiQuestLeatherTop",
        "BORDER"
      )
    button.aeuiQuestLeatherBottom =
      EnsureControlTexture(
        button,
        "aeuiQuestLeatherBottom",
        "BORDER"
      )
    button.aeuiQuestLeatherLeft =
      EnsureControlTexture(
        button,
        "aeuiQuestLeatherLeft",
        "BORDER"
      )
    button.aeuiQuestLeatherRight =
      EnsureControlTexture(
        button,
        "aeuiQuestLeatherRight",
        "BORDER"
      )
    button.aeuiQuestLeatherHover =
      EnsureControlTexture(
        button,
        "aeuiQuestLeatherHover",
        "BACKGROUND"
      )
    button.aeuiQuestLeatherPressed =
      EnsureControlTexture(
        button,
        "aeuiQuestLeatherPressed",
        "BACKGROUND"
      )
    button.aeuiQuestLeatherDisabled =
      EnsureControlTexture(
        button,
        "aeuiQuestLeatherDisabled",
        "BACKGROUND"
      )

    button.aeuiQuestLeatherBase:SetAllPoints(button)
    AnchorHorizontalEdge(
      button.aeuiQuestLeatherTop,
      button,
      "TOP"
    )
    AnchorHorizontalEdge(
      button.aeuiQuestLeatherBottom,
      button,
      "BOTTOM"
    )
    AnchorVerticalEdge(
      button.aeuiQuestLeatherLeft,
      button,
      "LEFT"
    )
    AnchorVerticalEdge(
      button.aeuiQuestLeatherRight,
      button,
      "RIGHT"
    )
    button.aeuiQuestLeatherHover:SetAllPoints(button)
    button.aeuiQuestLeatherPressed:SetAllPoints(button)
    button.aeuiQuestLeatherDisabled:SetAllPoints(button)

    SetTextureColor(
      button.aeuiQuestLeatherBase,
      CONTROL.leather.base
    )
    SetTextureColor(
      button.aeuiQuestLeatherTop,
      CONTROL.leather.edge
    )
    SetTextureColor(
      button.aeuiQuestLeatherBottom,
      CONTROL.leather.shadow
    )
    SetTextureColor(
      button.aeuiQuestLeatherLeft,
      CONTROL.leather.edge
    )
    SetTextureColor(
      button.aeuiQuestLeatherRight,
      CONTROL.leather.shadow
    )
    SetTextureColor(
      button.aeuiQuestLeatherHover,
      CONTROL.leather.hover
    )
    SetTextureColor(
      button.aeuiQuestLeatherPressed,
      CONTROL.leather.pressed
    )
    SetTextureColor(
      button.aeuiQuestLeatherDisabled,
      CONTROL.leather.disabled
    )
    InstallLeatherButtonHooks(button)
  end

  if button.SetFont then
    button:SetFont(
      QUEST_TITLE_FONT,
      12,
      THEME.fonts.panelTitle.flags
    )
  end
  UpdateLeatherButtonState(button)
end

function Quests:UpdateActionButtonStates()
  -- Vanilla 1.12 Buttons do not expose OnEnable or OnDisable script
  -- handlers. Refresh their visual state from Quest Log lifecycle hooks
  -- instead of attempting to register unsupported scripts.
  UpdateLeatherButtonState(QuestLogFrameAbandonButton)
  UpdateLeatherButtonState(QuestFramePushQuestButton)
  UpdateLeatherButtonState(
    QuestFrameExitButton or QuestLogFrameCancelButton
  )
  UpdateLeatherButtonState(QuestLogFrameExpandButton)
end

local function StylePfQuestButton(button, width, height, fontSize)
  if not button then
    return
  end
  if button.SetParent and QuestLogFrame then
    button:SetParent(QuestLogFrame)
  end
  StyleLeatherButton(button, width, height)

  local text = GetButtonText(button)
  if text and text.SetFont then
    local role = THEME.fonts.questName
    local path = ResolveThemeFontPath(role)
    if path then
      text:SetFont(
        path,
        fontSize or 10,
        role.flags or ""
      )
    end
  end
  button.aeuiQuestPfQuestManaged = true
end

function Quests:ApplyPfQuestQuestLogCompatibility()
  local provider = pfQuest
  local frame = QuestLogFrame
  if not provider or not frame then
    return
  end

  if not HasPfQuestQuestLogControls(provider) then
    return
  end

  -- pfQuest reserves 30px inside the scrolling description flow so it can
  -- inject four wide buttons. Restore the native title height captured before
  -- pfQuest loaded; the provider controls are moved to fixed book chrome below.
  local descriptionTitle = QuestLogDescriptionTitle
  if descriptionTitle and descriptionTitle.SetHeight then
    if self.questLogDescriptionTitleHeight ~= nil then
      descriptionTitle:SetHeight(
        self.questLogDescriptionTitleHeight
      )
    elseif
      not descriptionTitle.aeuiQuestPfQuestHeightRestored and
      descriptionTitle.GetHeight
    then
      local currentHeight =
        tonumber(descriptionTitle:GetHeight()) or 0
      descriptionTitle:SetHeight(
        math.max(0, currentHeight - 30)
      )
      descriptionTitle.aeuiQuestPfQuestHeightRestored = true
    end
  end

  local utilityRight =
    LAYOUT.detail.left + LAYOUT.detail.width
  local online = provider.buttonOnline
  local language = provider.buttonLanguage

  if online then
    StylePfQuestButton(
      online,
      PFQUEST.utilityWidth,
      PFQUEST.utilityHeight,
      9
    )
    SetSinglePoint(
      online,
      "TOPRIGHT",
      frame,
      "TOPLEFT",
      utilityRight,
      -LAYOUT.controlsTop
    )
  end

  if language then
    StylePfQuestButton(
      language,
      PFQUEST.languageWidth,
      PFQUEST.utilityHeight,
      9
    )
    if online then
      SetSinglePoint(
        language,
        "RIGHT",
        online,
        "LEFT",
        -PFQUEST.actionGap,
        0
      )
    else
      SetSinglePoint(
        language,
        "TOPRIGHT",
        frame,
        "TOPLEFT",
        utilityRight,
        -LAYOUT.controlsTop
      )
    end
  end

  local actions = {
    provider.buttonShow,
    provider.buttonHide,
    provider.buttonClean,
    provider.buttonReset,
  }
  local visibleActions = {}
  for _, button in ipairs(actions) do
    if button then
      table.insert(visibleActions, button)
    end
  end

  local count = table.getn(visibleActions)
  if count < 1 then
    return
  end
  local totalWidth =
    count * PFQUEST.actionWidth +
    (count - 1) * PFQUEST.actionGap
  local left =
    LAYOUT.detail.left +
    math.floor((LAYOUT.detail.width - totalWidth) / 2)
  local previous
  for _, button in ipairs(visibleActions) do
    StylePfQuestButton(
      button,
      PFQUEST.actionWidth,
      PFQUEST.actionHeight,
      10
    )
    if not previous then
      SetSinglePoint(
        button,
        "BOTTOMLEFT",
        frame,
        "BOTTOMLEFT",
        left,
        LAYOUT.actionBottom
      )
    else
      SetSinglePoint(
        button,
        "LEFT",
        previous,
        "RIGHT",
        PFQUEST.actionGap,
        0
      )
    end
    previous = button
  end
end

local function StyleTrackToggle(button)
  if not button then
    return
  end
  MakeBackdropTransparent(button)
  SetSize(button, CONTROL.trackSize, CONTROL.trackSize)

  if button.SetNormalTexture then
    button:SetNormalTexture(DIRECTORY_MARK_TEXTURE)
  end
  local normal =
    button.GetNormalTexture and button:GetNormalTexture()
  if normal then
    normal:SetTexture(DIRECTORY_MARK_TEXTURE)
    normal:SetTexCoord(
      DIRECTORY.states.untracked.left,
      DIRECTORY.states.untracked.right,
      DIRECTORY.states.untracked.top,
      DIRECTORY.states.untracked.bottom
    )
    SetSize(normal, 10, 10)
    SetSinglePoint(
      normal,
      "CENTER",
      button,
      "CENTER",
      0,
      0
    )
  end

  local checked
  if button.GetCheckedTexture then
    checked = button:GetCheckedTexture()
  end
  checked = checked or QuestLogTrackTracking
  if checked then
    checked:SetTexture(DIRECTORY_MARK_TEXTURE)
    checked:SetTexCoord(
      DIRECTORY.states.tracked.left,
      DIRECTORY.states.tracked.right,
      DIRECTORY.states.tracked.top,
      DIRECTORY.states.tracked.bottom
    )
    SetSize(checked, 10, 10)
    SetSinglePoint(
      checked,
      "CENTER",
      button,
      "CENTER",
      0,
      0
    )
    if button.GetChecked then
      if button:GetChecked() then
        checked:Show()
      else
        checked:Hide()
      end
    end
  end

  if button.SetHighlightTexture then
    button:SetHighlightTexture("")
  end

  if checked and button.GetChecked then
    AppendScript(
      button,
      "OnClick",
      "aeuiQuestInkCheckOnClickHooked",
      function()
        if button.GetChecked and button:GetChecked() then
          checked:Show()
        else
          checked:Hide()
        end
      end
    )
  end
end

local function HideNativeRegionToggle(row)
  if row and row.icon and row.icon.Hide then
    row.icon:Hide()
  end

  if row and row.GetNormalTexture then
    local normal = row:GetNormalTexture()
    if normal and normal.SetAlpha then
      normal:SetAlpha(0)
    end
  end
end

local function HideNativeListCheck(index)
  local check = _G["QuestLogTitle" .. index .. "Check"]
  if check and check.Hide then
    check:Hide()
  elseif check and check.SetAlpha then
    check:SetAlpha(0)
  end
end

local function SuppressNativeSelectionVisual(region)
  if not region then
    return
  end
  if region.SetAlpha then
    region:SetAlpha(0)
  elseif region.Hide then
    region:Hide()
  end
end

local function SuppressNativeRowSelection(row, index)
  SuppressNativeSelectionVisual(QuestLogHighlightFrame)
  SuppressNativeSelectionVisual(
    _G["QuestLogTitle" .. index .. "Highlight"]
  )

  if row and row.GetHighlightTexture then
    SuppressNativeSelectionVisual(row:GetHighlightTexture())
  end
  if row and row.GetPushedTexture then
    SuppressNativeSelectionVisual(row:GetPushedTexture())
  end
end

local function HideFrame(frame)
  if not frame then
    return
  end
  if frame.Hide then
    frame:Hide()
  elseif frame.SetAlpha then
    frame:SetAlpha(0)
  end
  if frame.EnableMouse then
    frame:EnableMouse(false)
  end
end

function Quests:HideCollapseAllButton()
  local button = QuestLogCollapseAllButton
  if not button then
    return
  end

  HideFrame(button.icon)
  if button.Disable then
    button:Disable()
  end
  if not button.aeuiQuestCollapseSuppressed then
    AppendScript(
      button,
      "OnShow",
      "aeuiQuestCollapseSuppressed",
      function()
        HideFrame(button)
      end
    )
  end
  HideFrame(button)
end

local function HideScrollbarChrome(
  scrollbar,
  scrollUpButton,
  scrollDownButton
)
  if not scrollbar then
    return
  end

  MakeBackdropTransparent(scrollbar)
  local thumb
  if scrollbar.GetThumbTexture then
    thumb = scrollbar:GetThumbTexture()
  end
  HideFrame(thumb)
  HideFrame(scrollUpButton)
  HideFrame(scrollDownButton)
  HideFrame(scrollbar.ScrollUpButton)
  HideFrame(scrollbar.ScrollDownButton)

  if not scrollbar.aeuiQuestHideOnShowHooked then
    AppendScript(
      scrollbar,
      "OnShow",
      "aeuiQuestHideOnShowHooked",
      function()
        HideFrame(scrollbar)
      end
    )
  end
  HideFrame(scrollbar)
end

function Quests:HideListScrollbar()
  HideScrollbarChrome(
    QuestLogListScrollFrameScrollBar,
    QuestLogListScrollFrameScrollBarScrollUpButton,
    QuestLogListScrollFrameScrollBarScrollDownButton
  )
end

function Quests:HideDetailScrollbar()
  HideScrollbarChrome(
    QuestLogDetailScrollFrameScrollBar,
    QuestLogDetailScrollFrameScrollBarScrollUpButton,
    QuestLogDetailScrollFrameScrollBarScrollDownButton
  )
end

function Quests:InstallListMouseWheel()
  local list = QuestLogListScrollFrame
  local scrollbar = QuestLogListScrollFrameScrollBar
  if not list or not list.EnableMouseWheel then
    return
  end

  list:EnableMouseWheel(true)
  if list.aeuiQuestMouseWheelHooked then
    return
  end

  AppendScript(
    list,
    "OnMouseWheel",
    "aeuiQuestMouseWheelHooked",
    function(delta)
      local wheel = tonumber(delta) or tonumber(arg1) or 0
      if wheel == 0 then
        return
      end

      if
        scrollbar and
        scrollbar.GetValue and
        scrollbar.SetValue
      then
        local minimum = 0
        local maximum = 0
        if scrollbar.GetMinMaxValues then
          minimum, maximum = scrollbar:GetMinMaxValues()
        end
        minimum = tonumber(minimum) or 0
        maximum = tonumber(maximum) or minimum
        local current = tonumber(scrollbar:GetValue()) or minimum
        local step =
          tonumber(QUESTLOG_QUEST_HEIGHT) or DIRECTORY.rowStep
        local target = current - wheel * step
        if target < minimum then
          target = minimum
        elseif target > maximum then
          target = maximum
        end
        scrollbar:SetValue(target)
        return
      end

      if list.GetVerticalScroll and list.SetVerticalScroll then
        local current = list:GetVerticalScroll() or 0
        local maximum = 0
        if list.GetVerticalScrollRange then
          maximum = list:GetVerticalScrollRange() or 0
        end
        local target = current - wheel * DIRECTORY.rowStep
        if target < 0 then
          target = 0
        elseif target > maximum then
          target = maximum
        end
        list:SetVerticalScroll(target)
      end
    end
  )
end

function Quests:InstallDetailMouseWheel()
  local detail = QuestLogDetailScrollFrame
  if
    not detail or
    not detail.EnableMouseWheel or
    not detail.GetVerticalScroll or
    not detail.SetVerticalScroll
  then
    return
  end

  detail:EnableMouseWheel(true)
  if detail.aeuiQuestMouseWheelHooked then
    return
  end

  AppendScript(
    detail,
    "OnMouseWheel",
    "aeuiQuestMouseWheelHooked",
    function(delta)
      local wheel = tonumber(delta) or tonumber(arg1) or 0
      if wheel == 0 then
        return
      end

      local current = detail:GetVerticalScroll() or 0
      local maximum = 0
      if detail.GetVerticalScrollRange then
        maximum = detail:GetVerticalScrollRange() or 0
      end
      local target =
        current - wheel * CONTROL.scrollStep
      if target < 0 then
        target = 0
      elseif target > maximum then
        target = maximum
      end
      detail:SetVerticalScroll(target)
    end
  )
end

local function ReadQuestEntry(index)
  if type(GetQuestLogTitle) ~= "function" then
    return nil
  end

  local title
  local level
  local questTag
  local suggestedGroup
  local isHeader
  local isCollapsed
  local isComplete

  if
    pfUI and
    pfUI.expansion and
    pfUI.expansion ~= "vanilla"
  then
    title,
      level,
      questTag,
      suggestedGroup,
      isHeader,
      isCollapsed,
      isComplete = GetQuestLogTitle(index)
  else
    title,
      level,
      questTag,
      isHeader,
      isCollapsed,
      isComplete = GetQuestLogTitle(index)
  end

  return
    title,
    level,
    questTag,
    isHeader,
    isCollapsed,
    isComplete
end

function Quests:EnsureDirectoryRows()
  if not QuestLogFrame or not QuestLogListScrollFrame then
    return false
  end

  for index = 1, DIRECTORY.providerRowCeiling do
    local name = "QuestLogTitle" .. index
    local row = _G[name]
    if not row then
      row = CreateFrame(
        "Button",
        name,
        QuestLogFrame,
        "QuestLogTitleButtonTemplate"
      )
    end
    if row and row.SetID then
      row:SetID(index)
    end
  end

  QUESTS_DISPLAYED = DIRECTORY.rowCount
  return true
end

local function HideSurplusDirectoryRows()
  for index = DIRECTORY.rowCount + 1, DIRECTORY.providerRowCeiling do
    local row = _G["QuestLogTitle" .. index]
    if row then
      HideNativeListCheck(index)
      if row.aeuiQuestRegionToggle then
        row.aeuiQuestRegionToggle:Hide()
      end
      if row.aeuiQuestListCheck then
        row.aeuiQuestListCheck:Hide()
      end
      if row.Hide then
        row:Hide()
      end
    end
  end
end

function Quests:LayoutDirectoryRows(force)
  if not self:EnsureDirectoryRows() then
    return false
  end
  if
    not force and
    QuestLogFrame.aeuiQuestDirectoryLayout ==
    DIRECTORY.contract
  then
    return true
  end

  local previous
  for index = 1, DIRECTORY.rowCount do
    local row = _G["QuestLogTitle" .. index]
    if row then
      SuppressNativeRowSelection(row, index)
      SetSize(row, DIRECTORY.rowWidth, DIRECTORY.rowHeight)
      if not previous then
        SetSinglePoint(
          row,
          "TOPLEFT",
          QuestLogListScrollFrame,
          "TOPLEFT",
          0,
          0
        )
      else
        SetSinglePoint(
          row,
          "TOPLEFT",
          previous,
          "BOTTOMLEFT",
          0,
          DIRECTORY.rowHeight - DIRECTORY.rowStep
        )
      end

      ApplyDirectoryTypography(row)
      if row.GetFontString then
        local text = row:GetFontString()
        if text and text.SetWidth then
          text:SetWidth(DIRECTORY.textWidth)
        end
        SetSinglePoint(
          text,
          "LEFT",
          row,
          "LEFT",
          18,
          0
        )
      end

      if row.aeuiQuestSelection then
        row.aeuiQuestSelection:Hide()
      end

      if not row.aeuiQuestRegionToggle then
        row.aeuiQuestRegionToggle =
          row:CreateTexture(nil, "ARTWORK")
        row.aeuiQuestRegionToggle.aeuiQuestManaged = true
        row.aeuiQuestRegionToggle:SetTexture(
          DIRECTORY_MARK_TEXTURE
        )
        SetSize(row.aeuiQuestRegionToggle, 12, 12)
        SetSinglePoint(
          row.aeuiQuestRegionToggle,
          "LEFT",
          row,
          "LEFT",
          1,
          0
        )
      end

      row.aeuiQuestRegionToggle:Hide()
      if row.aeuiQuestListCheck then
        row.aeuiQuestListCheck:Hide()
      end
      HideNativeListCheck(index)
      previous = row
    end
  end

  HideSurplusDirectoryRows()

  if QuestLogTitleText and QuestLogTitleText.SetFont then
    QuestLogTitleText:SetFont(
      QUEST_TITLE_FONT,
      THEME.fonts.panelTitle.size,
      THEME.fonts.panelTitle.flags
    )
  end
  SetTextColor(QuestLogTitleText, THEME.ink.body)
  ClearTextShadow(QuestLogTitleText)
  QuestLogFrame.aeuiQuestDirectoryLayout = DIRECTORY.contract
  return true
end

function Quests:UpdateDirectoryRows()
  if
    not addon.db or
    not addon.db.quests.enabled or
    not QuestLogFrame
  then
    return
  end

  -- Re-assert this event-driven layout after every QuestLog_Update. pfQuest
  -- calls QuestLogTitleButton_Resize after the original update and otherwise
  -- leaves each row at a provider-defined width.
  if not self:LayoutDirectoryRows(true) then
    return
  end

  for index = 1, DIRECTORY.rowCount do
    local row = _G["QuestLogTitle" .. index]
    if row then
      SuppressNativeRowSelection(row, index)
      if row.aeuiQuestRegionToggle then
        row.aeuiQuestRegionToggle:Hide()
      end
      if row.aeuiQuestListCheck then
        row.aeuiQuestListCheck:Hide()
      end
      HideNativeListCheck(index)
      if row.aeuiQuestSelection then
        row.aeuiQuestSelection:Hide()
      end
    end
  end

  if
    type(GetNumQuestLogEntries) ~= "function" or
    type(GetQuestLogTitle) ~= "function"
  then
    return
  end

  local count = GetNumQuestLogEntries() or 0
  local offset = 0
  if
    type(FauxScrollFrame_GetOffset) == "function" and
    QuestLogListScrollFrame
  then
    offset = FauxScrollFrame_GetOffset(
      QuestLogListScrollFrame
    ) or 0
  end

  for index = 1, DIRECTORY.rowCount do
    local row = _G["QuestLogTitle" .. index]
    if row then
      local toggle = row.aeuiQuestRegionToggle
      local questIndex = index + offset
      if questIndex <= count then
        local title, level, questTag, isHeader, isCollapsed,
          isComplete =
          ReadQuestEntry(questIndex)
        local rowText = row.GetFontString and row:GetFontString()
        local rowColor
        local statusColor
        local questTypeColor
        local completionColor
        if isHeader then
          rowColor = THEME.ink.section
        else
          rowColor = ResolveQuestNameInk(level, rowText)
          statusColor, questTypeColor, completionColor =
            ResolveDirectoryStatusInks(questTag, isComplete)
        end
        ApplyDirectoryTypography(
          row,
          statusColor,
          questTypeColor,
          completionColor
        )
        SetTextColor(row, rowColor)
        SetTextColor(rowText, rowColor)
        NormalizeDirectoryInlineStatus(
          rowText,
          title,
          questTag,
          statusColor,
          questTypeColor,
          completionColor,
          rowColor
        )

        if title and isHeader and toggle then
          HideNativeRegionToggle(row)
          SetDirectoryState(
            toggle,
            isCollapsed and
              DIRECTORY.states.collapsed or
              DIRECTORY.states.expanded
          )
        end

      end
    end
  end
  HideSurplusDirectoryRows()
end

local DETAIL_TEXT_NAMES = {
  "QuestLogQuestTitle",
  "QuestLogObjectivesText",
  "QuestLogDescriptionTitle",
  "QuestLogQuestDescription",
  "QuestLogRewardTitleText",
  "QuestLogItemChooseText",
  "QuestLogItemReceiveText",
  "QuestLogRequiredMoneyText",
  "QuestLogSpellLearnText",
  "QuestLogPlayerTitleText",
  "QuestLogHonorFrameHonorReceiveText",
}

-- These strings own wrapped blocks inside the right-page reading column.
-- Keep the two inline money labels out of this list: Blizzard anchors the
-- corresponding MoneyFrame to the label's RIGHT edge, so forcing a full
-- column width pushes the amount beyond the ScrollChild and clips it.
local DETAIL_WRAPPED_TEXT_NAMES = {
  "QuestLogQuestTitle",
  "QuestLogObjectivesText",
  "QuestLogDescriptionTitle",
  "QuestLogQuestDescription",
  "QuestLogRewardTitleText",
  "QuestLogItemChooseText",
  "QuestLogSpellLearnText",
  "QuestLogPlayerTitleText",
  "QuestLogHonorFrameHonorReceiveText",
}

local DETAIL_INLINE_MONEY_TEXT_NAMES = {
  "QuestLogItemReceiveText",
  "QuestLogRequiredMoneyText",
}

local DETAIL_HEADING_TEXT_NAMES = {
  "QuestLogDescriptionTitle",
  "QuestLogRewardTitleText",
}

local DETAIL_LABEL_TEXT_NAMES = {
  "QuestLogItemChooseText",
  "QuestLogItemReceiveText",
  "QuestLogSpellLearnText",
  "QuestLogPlayerTitleText",
  "QuestLogHonorFrameHonorReceiveText",
}

local DETAIL_BODY_TEXT_NAMES = {
  "QuestLogObjectivesText",
  "QuestLogQuestDescription",
  "QuestLogRequiredMoneyText",
}

local DETAIL_MEASURE_FRAME_NAMES = {
  "QuestLogSpellLearnFrame",
  "QuestLogPlayerTitleFrame",
  "QuestLogHonorFrame",
  "QuestLogMoneyFrame",
  "QuestLogRewardMoneyFrame",
  "QuestLogRequiredMoneyFrame",
  "QuestLogXPFrame",
  -- Blizzard moves this 25px spacer below whichever dynamic detail object
  -- was shown last. It is the native authoritative end-of-content marker.
  "QuestLogSpacerFrame",
}

local function IsVisibleDetailObject(object)
  if not object then
    return false
  end
  if object.IsVisible then
    return object:IsVisible()
  end
  if object.IsShown then
    return object:IsShown()
  end
  return true
end

local function AddDetailMeasureObject(objects, object)
  if object then
    table.insert(objects, object)
  end
end

local function CollectDetailMeasureObjects()
  local objects = {}
  for _, name in ipairs(DETAIL_TEXT_NAMES) do
    AddDetailMeasureObject(objects, _G[name])
  end

  local objectiveCount = tonumber(MAX_OBJECTIVES) or 10
  for index = 1, objectiveCount do
    AddDetailMeasureObject(
      objects,
      _G["QuestLogObjective" .. index]
    )
  end

  local rewardCount = tonumber(MAX_NUM_ITEMS) or 6
  for index = 1, rewardCount do
    AddDetailMeasureObject(
      objects,
      _G["QuestLogItem" .. index]
    )
  end

  for _, name in ipairs(DETAIL_MEASURE_FRAME_NAMES) do
    AddDetailMeasureObject(objects, _G[name])
  end
  return objects
end

local function ReadQuestLogRewardCount(name)
  local callback = _G[name]
  if type(callback) ~= "function" then
    return 0
  end
  local value = math.floor(tonumber(callback()) or 0)
  return math.max(0, value)
end

local function HasQuestLogRewardSpell()
  if type(GetQuestLogRewardSpell) ~= "function" then
    return false
  end
  return GetQuestLogRewardSpell() and true or false
end

local function ReadQuestLogRewardMoney()
  if type(GetQuestLogRewardMoney) ~= "function" then
    return 0
  end
  return math.max(0, tonumber(GetQuestLogRewardMoney()) or 0)
end

local function AnchorRewardHeading(heading, previous)
  if
    not previous or
    not IsVisibleDetailObject(heading)
  then
    return false
  end
  SetSinglePoint(
    heading,
    "TOPLEFT",
    previous,
    "BOTTOMLEFT",
    0,
    -LAYOUT.detail.rewardSectionGap
  )
  return true
end

local function IsRewardGeometryManaged(item)
  return
    item and
    item.aeuiRewardGeometryContract and
    addon.db and
    addon.db.quests and
    addon.db.quests.enabled
end

local function IsRewardVisualManaged(item)
  return
    item and
    item.aeuiRewardContainer and
    addon.db and
    addon.db.quests and
    addon.db.quests.enabled
end

local function ApplyRewardGeometryContract(item)
  local contract = item and item.aeuiRewardGeometryContract
  local methods = item and item.aeuiRewardGeometryMethods
  if not contract or not methods then
    return false
  end

  item.aeuiRewardGeometryWriting = true
  methods.clearAllPoints(item)
  methods.setWidth(item, contract.width)
  methods.setHeight(item, contract.height)
  methods.setPoint(
    item,
    contract.point,
    contract.relativeTo,
    contract.relativePoint,
    contract.x,
    contract.y
  )
  item.aeuiRewardGeometryWriting = nil
  return true
end

local function InstallRewardGeometryLock(item)
  if
    not item or
    not item.ClearAllPoints or
    not item.SetPoint or
    not item.SetWidth or
    not item.SetHeight
  then
    return false
  end

  local locks = item.aeuiRewardGeometryLocks
  if
    locks and
    item.ClearAllPoints == locks.clearAllPoints and
    item.SetPoint == locks.setPoint and
    item.SetWidth == locks.setWidth and
    item.SetHeight == locks.setHeight
  then
    return true
  end

  local previousMethods = item.aeuiRewardGeometryMethods
  local previousLocks = locks
  local function ResolveMethod(current, previousLock, previousMethod, hidden)
    if hidden then
      return hidden
    end
    if previousLock and current == previousLock then
      return previousMethod
    end
    return current
  end

  local methods = {
    clearAllPoints = ResolveMethod(
      item.ClearAllPoints,
      previousLocks and previousLocks.clearAllPoints,
      previousMethods and previousMethods.clearAllPoints,
      item.HiddenClearAllPoints
    ),
    setPoint = ResolveMethod(
      item.SetPoint,
      previousLocks and previousLocks.setPoint,
      previousMethods and previousMethods.setPoint,
      item.HiddenSetPoint
    ),
    setWidth = ResolveMethod(
      item.SetWidth,
      previousLocks and previousLocks.setWidth,
      previousMethods and previousMethods.setWidth
    ),
    setHeight = ResolveMethod(
      item.SetHeight,
      previousLocks and previousLocks.setHeight,
      previousMethods and previousMethods.setHeight
    ),
    setAllPoints = ResolveMethod(
      item.SetAllPoints,
      previousLocks and previousLocks.setAllPoints,
      previousMethods and previousMethods.setAllPoints,
      item.HiddenSetAllPoints
    ),
  }
  if
    not methods.clearAllPoints or
    not methods.setPoint or
    not methods.setWidth or
    not methods.setHeight
  then
    return false
  end

  locks = {}
  locks.clearAllPoints = function(self)
    if self.aeuiRewardGeometryWriting or not IsRewardGeometryManaged(self) then
      return methods.clearAllPoints(self)
    end
    return ApplyRewardGeometryContract(self)
  end
  locks.setPoint = function(self, point, relativeTo, relativePoint, x, y)
    if self.aeuiRewardGeometryWriting or not IsRewardGeometryManaged(self) then
      return methods.setPoint(
        self,
        point,
        relativeTo,
        relativePoint,
        x,
        y
      )
    end
    return ApplyRewardGeometryContract(self)
  end
  locks.setWidth = function(self, width)
    if self.aeuiRewardGeometryWriting or not IsRewardGeometryManaged(self) then
      return methods.setWidth(self, width)
    end
    return ApplyRewardGeometryContract(self)
  end
  locks.setHeight = function(self, height)
    if self.aeuiRewardGeometryWriting or not IsRewardGeometryManaged(self) then
      return methods.setHeight(self, height)
    end
    return ApplyRewardGeometryContract(self)
  end
  if methods.setAllPoints then
    locks.setAllPoints = function(self, relativeTo)
      if self.aeuiRewardGeometryWriting or not IsRewardGeometryManaged(self) then
        return methods.setAllPoints(self, relativeTo)
      end
      return ApplyRewardGeometryContract(self)
    end
  end

  item.aeuiRewardGeometryMethods = methods
  item.aeuiRewardGeometryLocks = locks
  item.ClearAllPoints = locks.clearAllPoints
  item.SetPoint = locks.setPoint
  item.SetWidth = locks.setWidth
  item.SetHeight = locks.setHeight
  if locks.setAllPoints then
    item.SetAllPoints = locks.setAllPoints
  end
  item.aeuiRewardGeometrySetterLock = locks.setPoint
  return true
end

local function PrepareRewardSlotGeometry(item)
  if not InstallRewardGeometryLock(item) then
    SetSize(
      item,
      LAYOUT.detail.rewardSlotWidth,
      LAYOUT.detail.rewardSlotHeight
    )
    return
  end

  local contract = item.aeuiRewardGeometryContract
  if contract then
    contract.width = LAYOUT.detail.rewardSlotWidth
    contract.height = LAYOUT.detail.rewardSlotHeight
    ApplyRewardGeometryContract(item)
    return
  end

  local methods = item.aeuiRewardGeometryMethods
  methods.setWidth(item, LAYOUT.detail.rewardSlotWidth)
  methods.setHeight(item, LAYOUT.detail.rewardSlotHeight)
end

local function SetRewardSlotGeometry(
  item,
  point,
  relativeTo,
  relativePoint,
  x,
  y
)
  if not item then
    return
  end
  if not InstallRewardGeometryLock(item) then
    SetSize(
      item,
      LAYOUT.detail.rewardSlotWidth,
      LAYOUT.detail.rewardSlotHeight
    )
    SetSinglePoint(item, point, relativeTo, relativePoint, x, y)
    return
  end

  item.aeuiRewardGeometryContract = {
    width = LAYOUT.detail.rewardSlotWidth,
    height = LAYOUT.detail.rewardSlotHeight,
    point = point,
    relativeTo = relativeTo,
    relativePoint = relativePoint,
    x = x,
    y = y,
  }
  ApplyRewardGeometryContract(item)
end

local function SetRewardContainerState(item, state)
  local container = item and item.aeuiRewardContainer
  local colors = REWARD_CONTAINER[state] or REWARD_CONTAINER.normal
  if not container or not colors then
    return
  end
  if container.SetBackdropColor then
    container:SetBackdropColor(
      colors.background[1],
      colors.background[2],
      colors.background[3],
      colors.background[4]
    )
  end
  if container.SetBackdropBorderColor then
    container:SetBackdropBorderColor(
      colors.border[1],
      colors.border[2],
      colors.border[3],
      colors.border[4]
    )
  end
end

local function SuppressRewardSurface(surface, item)
  if not surface then
    return
  end

  surface.aeuiRewardManagedItem = item
  if surface.Show and surface.Show ~= surface.aeuiRewardSurfaceShowLock then
    local downstream = surface.Show
    local lock = function(self)
      downstream(self)
      if
        IsRewardVisualManaged(self.aeuiRewardManagedItem) and
        self.Hide
      then
        self:Hide()
      end
    end
    surface.aeuiRewardSurfaceShowDownstream = downstream
    surface.aeuiRewardSurfaceShowLock = lock
    surface.Show = lock
  end

  if surface.Hide then
    surface:Hide()
  elseif surface.SetAlpha then
    surface:SetAlpha(0)
  end
end

local function IsRewardStateTexture(item, region)
  if not item or not region then
    return false
  end
  local callbacks = {
    "GetNormalTexture",
    "GetHighlightTexture",
    "GetPushedTexture",
    "GetDisabledTexture",
    "GetCheckedTexture",
  }
  for _, callbackName in ipairs(callbacks) do
    local callback = item[callbackName]
    if callback and callback(item) == region then
      return true
    end
  end
  return false
end

local function SuppressNativeRewardTextures(item, icon)
  if not item or not item.GetRegions then
    return
  end
  if not item.aeuiRewardNativeTextures then
    item.aeuiRewardNativeTextures = {}
    local regions = { item:GetRegions() }
    for _, region in ipairs(regions) do
      if
        IsTexture(region) and
        region ~= icon and
        not IsRewardStateTexture(item, region)
      then
        table.insert(item.aeuiRewardNativeTextures, region)
      end
    end
  end
  for _, region in ipairs(item.aeuiRewardNativeTextures) do
    SuppressRewardSurface(region, item)
  end
end

local function EnsureRewardSlotContainer(item, index)
  if not item then
    return nil
  end

  local objectName = "QuestLogItem" .. index
  local icon = _G[objectName .. "IconTexture"]
  local count = _G[objectName .. "Count"]
  local name = _G[objectName .. "Name"]
  local nativeNameFrame = _G[objectName .. "NameFrame"]
  local container = item.aeuiRewardContainer
  if not container then
    container = CreateFrame("Frame", nil, item)
    container.aeuiQuestManaged = true
    if container.EnableMouse then
      container:EnableMouse(false)
    end
    item.aeuiRewardContainer = container
  end

  if
    container.SetFrameLevel and
    item.GetFrameLevel
  then
    container:SetFrameLevel(item:GetFrameLevel() + 1)
  end
  container:ClearAllPoints()
  container:SetPoint("TOPLEFT", item, "TOPLEFT", 0, 0)
  container:SetPoint("BOTTOMRIGHT", item, "BOTTOMRIGHT", 0, 0)
  if container.SetBackdrop then
    container:SetBackdrop(REWARD_CONTAINER.backdrop)
  end
  if container.Show then
    container:Show()
  end
  SetRewardContainerState(item, "normal")

  if icon then
    if icon.SetParent then
      icon:SetParent(container)
    end
    SetSize(
      icon,
      LAYOUT.detail.rewardIconSize,
      LAYOUT.detail.rewardIconSize
    )
    SetSinglePoint(
      icon,
      "LEFT",
      container,
      "LEFT",
      LAYOUT.detail.rewardContentInset,
      0
    )
    if icon.SetTexCoord then
      icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    if icon.SetDrawLayer then
      icon:SetDrawLayer("OVERLAY")
    end
  end

  if count then
    if count.SetParent then
      count:SetParent(container)
    end
    if icon then
      SetSinglePoint(
        count,
        "BOTTOMRIGHT",
        icon,
        "BOTTOMRIGHT",
        -1,
        1
      )
    end
    if count.SetDrawLayer then
      count:SetDrawLayer("OVERLAY")
    end
  end

  if name then
    if name.SetParent then
      name:SetParent(container)
    end
    if icon then
      SetSinglePoint(
        name,
        "LEFT",
        icon,
        "RIGHT",
        LAYOUT.detail.rewardNameGap,
        0
      )
    end
    if name.SetWidth then
      name:SetWidth(LAYOUT.detail.rewardNameWidth)
    end
    if name.SetJustifyH then
      name:SetJustifyH("LEFT")
    end
    if name.SetDrawLayer then
      name:SetDrawLayer("OVERLAY")
    end
  end

  -- Scoped ownership skips pfUI's Quest Log skin, so the live client normally
  -- reaches this branch with Blizzard's QuestLogItemNNameFrame and no
  -- item.backdrop. Suppress both possible provider surfaces after moving the
  -- dynamic regions into the AEUI container. The Show lock prevents a late
  -- native/provider refresh from restoring either obsolete card face.
  SuppressRewardSurface(nativeNameFrame, item)
  SuppressNativeRewardTextures(item, icon)
  SuppressRewardSurface(item.backdrop, item)
  SuppressRewardSurface(item.backdrop_border, item)

  AppendScript(
    item,
    "OnEnter",
    "aeuiRewardContainerEnterHook",
    function()
      SetRewardContainerState(item, "hover")
    end
  )
  AppendScript(
    item,
    "OnLeave",
    "aeuiRewardContainerLeaveHook",
    function()
      SetRewardContainerState(item, "normal")
    end
  )
  return container
end

local function GetRewardGroupTopGap(heading)
  local labelHeight = LAYOUT.detail.rewardLabelHeight
  if heading and heading.GetHeight then
    labelHeight = math.max(
      labelHeight,
      math.floor(tonumber(heading:GetHeight()) or 0)
    )
  end
  return
    LAYOUT.detail.rewardSectionGap +
    labelHeight +
    LAYOUT.detail.rewardHeaderGap
end

local function LayoutRewardGroup(firstIndex, count, anchor, heading)
  if not anchor or count <= 0 then
    return nil
  end
  local lastRowLeft
  for position = 1, count do
    local index = firstIndex + position - 1
    local item = _G["QuestLogItem" .. index]
    if item then
      if position == 1 then
        SetRewardSlotGeometry(
          item,
          "TOPLEFT",
          anchor,
          "BOTTOMLEFT",
          0,
          -GetRewardGroupTopGap(heading)
        )
      elseif position == math.floor(position / 2) * 2 then
        SetRewardSlotGeometry(
          item,
          "TOPLEFT",
          _G["QuestLogItem" .. (index - 1)],
          "TOPRIGHT",
          LAYOUT.detail.rewardColumnGap,
          0
        )
      else
        SetRewardSlotGeometry(
          item,
          "TOPLEFT",
          _G["QuestLogItem" .. (index - 2)],
          "BOTTOMLEFT",
          0,
          -LAYOUT.detail.rewardRowGap
        )
      end
      if position ~= math.floor(position / 2) * 2 then
        lastRowLeft = item
      end
    end
  end
  return lastRowLeft
end

local function CountVisibleRewardItems(itemCeiling)
  local count = 0
  for index = 1, itemCeiling do
    local item = _G["QuestLogItem" .. index]
    if not IsVisibleDetailObject(item) then
      break
    end
    count = index
  end
  return count
end

local function ApplyDetailRewardGeometry()
  local itemCeiling = tonumber(MAX_NUM_ITEMS) or 6
  for index = 1, itemCeiling do
    local item = _G["QuestLogItem" .. index]
    PrepareRewardSlotGeometry(item)
    EnsureRewardSlotContainer(item, index)

    local name = _G["QuestLogItem" .. index .. "Name"]
    if name and name.SetWidth then
      name:SetWidth(LAYOUT.detail.rewardNameWidth)
    end
    ApplyThemeFontFixed(name, THEME.fonts.detailBody)
    -- Keep the provider's live item-quality colour; only replace the hard to
    -- read face, outline and shadow.
    ClearTextShadow(name)
  end

  local choiceCount = math.min(
    itemCeiling,
    ReadQuestLogRewardCount("GetNumQuestLogChoices")
  )
  local spellCount = HasQuestLogRewardSpell() and 1 or 0
  if choiceCount + spellCount > itemCeiling then
    spellCount = 0
  end
  local rewardCount = math.min(
    itemCeiling - choiceCount - spellCount,
    ReadQuestLogRewardCount("GetNumQuestLogRewards")
  )

  -- Some 1.12-compatible providers update the real QuestLogItem Buttons but
  -- report zero through the stock count functions during their late refresh.
  -- Never leave those visible Buttons on stale native anchors: when every API
  -- count is zero, use the actual visible contiguous item range as the final
  -- layout authority and the visible native section label to classify it.
  if choiceCount + spellCount + rewardCount == 0 then
    local visibleCount = CountVisibleRewardItems(itemCeiling)
    if visibleCount > 0 then
      if IsVisibleDetailObject(QuestLogItemChooseText) then
        choiceCount = visibleCount
      elseif IsVisibleDetailObject(QuestLogSpellLearnText) then
        spellCount = 1
        rewardCount = math.max(0, visibleCount - 1)
      else
        rewardCount = visibleCount
      end
    end
  end

  local previous = QuestLogRewardTitleText
  if choiceCount > 0 then
    local choiceAnchor = previous
    AnchorRewardHeading(QuestLogItemChooseText, choiceAnchor)
    previous =
      LayoutRewardGroup(
        1,
        choiceCount,
        choiceAnchor,
        QuestLogItemChooseText
      ) or
      previous
  end
  if spellCount == 1 then
    local spellAnchor = previous
    AnchorRewardHeading(QuestLogSpellLearnText, spellAnchor)
    previous =
      LayoutRewardGroup(
        choiceCount + 1,
        1,
        spellAnchor,
        QuestLogSpellLearnText
      ) or
      previous
  end
  local rewardAnchor = previous
  if rewardCount > 0 or ReadQuestLogRewardMoney() > 0 then
    AnchorRewardHeading(QuestLogItemReceiveText, rewardAnchor)
  end
  if rewardCount > 0 then
    LayoutRewardGroup(
      choiceCount + spellCount + 1,
      rewardCount,
      rewardAnchor,
      QuestLogItemReceiveText
    )
  end
end

local function MeasureDetailContentHeight()
  local child = QuestLogDetailScrollChildFrame
  if not child or not child.GetTop then
    return nil
  end

  local childTop = tonumber(child:GetTop())
  if not childTop then
    return nil
  end

  local lowestBottom
  for _, object in ipairs(CollectDetailMeasureObjects()) do
    if
      IsVisibleDetailObject(object) and
      object.GetBottom
    then
      local bottom = tonumber(object:GetBottom())
      if
        bottom and
        (not lowestBottom or bottom < lowestBottom)
      then
        lowestBottom = bottom
      end
    end
  end

  if not lowestBottom or lowestBottom > childTop then
    return nil
  end

  local measured =
    math.ceil(
      childTop - lowestBottom +
      LAYOUT.detail.contentBottomPadding
    )
  if measured < LAYOUT.detail.height then
    measured = LAYOUT.detail.height
  elseif measured > LAYOUT.detail.contentMaxHeight then
    measured = LAYOUT.detail.contentMaxHeight
  end
  return measured
end

local function UpdateDetailScrollChildHeight()
  local child = QuestLogDetailScrollChildFrame
  if not child or not child.SetHeight then
    return
  end

  local targetHeight = MeasureDetailContentHeight()
  if not targetHeight then
    local currentHeight =
      child.GetHeight and tonumber(child:GetHeight()) or 0
    targetHeight = math.max(
      currentHeight or 0,
      LAYOUT.detail.height
    )
  end
  child:SetHeight(targetHeight)

  if
    QuestLogDetailScrollFrame and
    QuestLogDetailScrollFrame.UpdateScrollChildRect
  then
    QuestLogDetailScrollFrame:UpdateScrollChildRect()
  end
end

function Quests:ApplyDetailTextTheme()
  local questTitle = QuestLogQuestTitle
  ApplyThemeFontFixed(questTitle, THEME.fonts.detailHeading)
  SetTextColor(questTitle, THEME.ink.section)
  ClearTextShadow(questTitle)

  for _, name in ipairs(DETAIL_HEADING_TEXT_NAMES) do
    local text = _G[name]
    ApplyThemeFontFixed(text, THEME.fonts.detailHeading)
    SetTextColor(text, THEME.ink.section)
    ClearTextShadow(text)
  end

  for _, name in ipairs(DETAIL_LABEL_TEXT_NAMES) do
    local text = _G[name]
    ApplyThemeFontFixed(text, THEME.fonts.detailBody)
    SetTextColor(text, THEME.ink.section)
    ClearTextShadow(text)
  end

  for _, name in ipairs(DETAIL_BODY_TEXT_NAMES) do
    local text = _G[name]
    ApplyThemeFontFixed(text, THEME.fonts.detailBody)
    SetTextColor(text, THEME.ink.body)
    ClearTextShadow(text)
  end

  local objectiveCount = tonumber(MAX_OBJECTIVES) or 10
  for index = 1, objectiveCount do
    local objective = _G["QuestLogObjective" .. index]
    local color = THEME.ink.incomplete
    local done
    if type(GetQuestLogLeaderBoard) == "function" then
      local _, _, finished = GetQuestLogLeaderBoard(index)
      done = finished and true or false
    end
    if not done then
      local value = GetTextValue(objective)
      if value then
        local _, _, current, required = string.find(
          value,
          "(%d+)%s*/%s*(%d+)"
        )
        current = tonumber(current)
        required = tonumber(required)
        done = current and required and current >= required
      end
    end
    if done then
      color = THEME.ink.complete
    end
    ApplyThemeFontFixed(objective, THEME.fonts.detailBody)
    SetTextColor(objective, color)
    ClearTextShadow(objective)
  end
end

function Quests:ApplyDetailTextGeometry(skipDeferred)
  if QuestLogDetailScrollChildFrame then
    if QuestLogDetailScrollChildFrame.SetWidth then
      QuestLogDetailScrollChildFrame:SetWidth(
        LAYOUT.detail.contentWidth
      )
    end
  end

  for _, name in ipairs(DETAIL_WRAPPED_TEXT_NAMES) do
    local text = _G[name]
    if text and text.SetWidth then
      text:SetWidth(LAYOUT.detail.textWidth)
    end
  end

  for _, name in ipairs(DETAIL_INLINE_MONEY_TEXT_NAMES) do
    local text = _G[name]
    if text and text.SetWidth then
      -- FontString width 0 restores Blizzard's intrinsic text width. The
      -- adjacent MoneyFrame then remains inside the 224px content column.
      text:SetWidth(0)
    end
  end

  local objectiveCount = tonumber(MAX_OBJECTIVES) or 10
  for index = 1, objectiveCount do
    local objective = _G["QuestLogObjective" .. index]
    if objective and objective.SetWidth then
      objective:SetWidth(LAYOUT.detail.objectiveWidth)
    end
  end

  ApplyDetailRewardGeometry()

  self:ApplyDetailTextTheme()
  UpdateDetailScrollChildHeight()

  self:HideDetailScrollbar()
  self:InstallDetailMouseWheel()
  if not skipDeferred then
    self:ScheduleQuestLogReflow(2)
  end
end

function Quests:EnsureShell(frame)
  if frame.EnableDrawLayer then
    frame:EnableDrawLayer("BACKGROUND")
  end
  CaptureAndHideNativeTextures(frame)
  CaptureAndHideNativeTextures(QuestLogListScrollFrame)
  CaptureAndHideNativeTextures(QuestLogDetailScrollFrame)
  CaptureAndHideNativeTextures(EmptyQuestLogFrame)
  CaptureAndHideNativeTextures(QuestLogExpandButtonFrame)

  MakeBackdropTransparent(frame)
  MakeBackdropTransparent(QuestLogListScrollFrame)
  MakeBackdropTransparent(QuestLogDetailScrollFrame)

  if not frame.aeuiQuestShell then
    frame.aeuiQuestShell = frame:CreateTexture(nil, "BACKGROUND")
    frame.aeuiQuestShell.aeuiQuestManaged = true
  end

  local texture = frame.aeuiQuestShell
  texture:SetTexture(SHELL_TEXTURE)
  texture:SetTexCoord(
    SHELL.texcoord.left,
    SHELL.texcoord.right,
    SHELL.texcoord.top,
    SHELL.texcoord.bottom
  )
  texture:SetVertexColor(1, 1, 1, 1)
  texture:ClearAllPoints()
  texture:SetAllPoints(frame)
  texture:Show()
end

function Quests:EnsureQuestLogChromeSeal(frame)
  if not frame or not frame.CreateTexture then
    return
  end
  if not frame.aeuiQuestChromeSeal then
    frame.aeuiQuestChromeSeal = frame:CreateTexture(nil, "OVERLAY")
  end
  local texture = frame.aeuiQuestChromeSeal
  ConfigureQuestSealTexture(texture, "normal")
  SetSize(
    texture,
    QUEST_SEAL.questLog.width,
    QUEST_SEAL.questLog.height
  )
  SetSinglePoint(
    texture,
    "TOPLEFT",
    frame,
    "TOPLEFT",
    QUEST_SEAL.questLog.left,
    -QUEST_SEAL.questLog.top
  )
  frame.aeuiQuestSealRuntimeContract = QUEST_SEAL.contract
end

function Quests:ApplyControlVisuals()
  self:HideCollapseAllButton()
  StyleTrackToggle(QuestLogFrameLevelsCheckButton)
  StyleTrackToggle(QuestLogTrack)

  local count = QuestLogQuestCount or QuestLogCount
  if count and count.SetFont then
    count:SetFont(
      QUEST_TITLE_FONT,
      12,
      THEME.fonts.panelTitle.flags
    )
  end
  SetTextColor(count, CONTROL.text.ink)
  ClearTextShadow(count)

  local levelsText = QuestLogFrameLevelsCheckButtonText
  if levelsText then
    if levelsText.SetFont then
      levelsText:SetFont(
        QUEST_TITLE_FONT,
        11,
        THEME.fonts.panelTitle.flags
      )
    end
    SetTextColor(levelsText, CONTROL.text.ink)
    ClearTextShadow(levelsText)
  end

  SetTextColor(QuestLogNoQuestsText, THEME.ink.muted)
  ClearTextShadow(QuestLogNoQuestsText)

  StyleLeatherButton(
    QuestLogFrameAbandonButton,
    LAYOUT.actionWidth,
    LAYOUT.actionHeight
  )
  StyleLeatherButton(
    QuestFramePushQuestButton,
    LAYOUT.actionWidth,
    LAYOUT.actionHeight
  )
  StyleLeatherButton(
    QuestFrameExitButton or QuestLogFrameCancelButton,
    LAYOUT.actionWidth,
    LAYOUT.actionHeight
  )
  StyleLeatherButton(
    QuestLogFrameExpandButton,
    24,
    LAYOUT.actionHeight
  )

  self:HideListScrollbar()
  self:HideDetailScrollbar()
  self:InstallListMouseWheel()
  self:InstallDetailMouseWheel()
end

function Quests:ApplyFrameGeometry()
  local frame = QuestLogFrame
  if not frame then
    return
  end

  SetSize(frame, SHELL.width, SHELL.height)
  self:ApplyControlVisuals()

  SetSinglePoint(
    QuestLogTitleText,
    "TOP",
    frame,
    "TOP",
    0,
    -LAYOUT.titleTop
  )

  local count = QuestLogQuestCount or QuestLogCount
  SetSinglePoint(
    count,
    "TOPRIGHT",
    frame,
    "TOPLEFT",
    LAYOUT.list.left + LAYOUT.list.width,
    -LAYOUT.countTop
  )

  if QuestLogFrameLevelsCheckButton then
    SetSinglePoint(
      QuestLogFrameLevelsCheckButton,
      "TOPLEFT",
      frame,
      "TOPLEFT",
      LAYOUT.list.left + 74,
      -LAYOUT.controlsTop - 2
    )
  end
  if count then
    SetSinglePoint(
      QuestLogTrack,
      "RIGHT",
      count,
      "LEFT",
      -5,
      0
    )
  end
  if QuestLogTrackTitle and QuestLogTrackTitle.Hide then
    QuestLogTrackTitle:Hide()
  end

  SetSinglePoint(
    QuestLogFrameCloseButton,
    "TOPRIGHT",
    frame,
    "TOPRIGHT",
    -LAYOUT.closeRight,
    -LAYOUT.closeTop
  )

  SetSinglePoint(
    QuestLogListScrollFrame,
    "TOPLEFT",
    frame,
    "TOPLEFT",
    LAYOUT.list.left,
    -LAYOUT.list.top
  )
  SetSize(
    QuestLogListScrollFrame,
    LAYOUT.list.width,
    LAYOUT.list.height
  )

  SetSinglePoint(
    QuestLogDetailScrollFrame,
    "TOPLEFT",
    frame,
    "TOPLEFT",
    LAYOUT.detail.left,
    -LAYOUT.detail.top
  )
  SetSize(
    QuestLogDetailScrollFrame,
    LAYOUT.detail.width,
    LAYOUT.detail.height
  )

  self:ApplyDetailTextGeometry()

  SetSinglePoint(
    QuestLogNoQuestsText,
    "CENTER",
    frame,
    "TOPLEFT",
    LAYOUT.list.left + LAYOUT.list.width / 2,
    -(LAYOUT.list.top + LAYOUT.list.height / 2)
  )

  local actions = {}
  if QuestLogFrameAbandonButton then
    table.insert(actions, QuestLogFrameAbandonButton)
  end
  if QuestFramePushQuestButton then
    table.insert(actions, QuestFramePushQuestButton)
  end
  if QuestFrameExitButton or QuestLogFrameCancelButton then
    table.insert(
      actions,
      QuestFrameExitButton or QuestLogFrameCancelButton
    )
  end
  local previous
  for _, button in ipairs(actions) do
    if button then
      SetSize(
        button,
        LAYOUT.actionWidth,
        LAYOUT.actionHeight
      )
      if not previous then
        SetSinglePoint(
          button,
          "BOTTOMLEFT",
          frame,
          "BOTTOMLEFT",
          LAYOUT.actionLeft,
          LAYOUT.actionBottom
        )
      else
        SetSinglePoint(
          button,
          "LEFT",
          previous,
          "RIGHT",
          LAYOUT.actionGap,
          0
        )
      end
      previous = button
    end
  end

  if QuestLogFrameExpandButton then
    SetSinglePoint(
      QuestLogFrameExpandButton,
      "LEFT",
      previous or frame,
      previous and "RIGHT" or "BOTTOMLEFT",
      previous and LAYOUT.actionGap or LAYOUT.actionLeft,
      previous and 0 or LAYOUT.actionBottom
    )
  end
end

function Quests:UpdateDetailToggle()
  local button = QuestLogFrameExpandButton
  local detail = QuestLogDetailScrollFrame
  if not button or not detail then
    return
  end

  if button.SetText then
    button:SetText(detail:IsShown() and "<" or ">")
  end
  button.aeuiQuestDetailVisible = detail:IsShown() and true or nil
end

function Quests:ToggleDetail()
  local detail = QuestLogDetailScrollFrame
  if not detail then
    return
  end

  if detail:IsShown() then
    detail.aeuiQuestHiddenByToggle = true
    detail:Hide()
  else
    detail.aeuiQuestHiddenByToggle = nil
    detail:Show()
    if type(QuestLog_UpdateQuestDetails) == "function" then
      QuestLog_UpdateQuestDetails()
    end
  end

  self:ApplyFrameGeometry()
  self:UpdateDetailToggle()
end

function Quests:EnsureDetailToggle(frame)
  if not QuestLogDetailScrollFrame then
    return
  end

  local button = QuestLogFrameExpandButton
  if not button then
    button = CreateFrame(
      "Button",
      "QuestLogFrameExpandButton",
      frame,
      "UIPanelButtonTemplate"
    )
    SetSize(button, 24, 20)
    button:SetScript("OnClick", function()
      Quests:ToggleDetail()
    end)
    button.aeuiQuestCreated = true
  end

  AppendScript(
    QuestLogDetailScrollFrame,
    "OnHide",
    "aeuiQuestOnHideHooked",
    function()
      Quests:ApplyFrameGeometry()
      Quests:UpdateDetailToggle()
    end
  )
  AppendScript(
    QuestLogDetailScrollFrame,
    "OnShow",
    "aeuiQuestOnShowHooked",
    function()
      Quests:ApplyFrameGeometry()
      Quests:UpdateDetailToggle()
    end
  )

  if EmptyQuestLogFrame then
    AppendScript(
      EmptyQuestLogFrame,
      "OnShow",
      "aeuiQuestEmptyOnShowHooked",
      function()
        if button.Disable then
          button:Disable()
        end
        Quests:UpdateActionButtonStates()
      end
    )
    AppendScript(
      EmptyQuestLogFrame,
      "OnHide",
      "aeuiQuestEmptyOnHideHooked",
      function()
        if button.Enable then
          button:Enable()
        end
        Quests:UpdateActionButtonStates()
      end
    )
    if
      EmptyQuestLogFrame.IsShown and
      EmptyQuestLogFrame:IsShown() and
      button.Disable
    then
      button:Disable()
    end
  end

  self:UpdateDetailToggle()
end

function Quests:GetRuntimeStatus()
  local frame = QuestLogFrame
  local frameContract =
    frame and frame.aeuiQuestRuntimeContract or "unapplied"
  local themeContract =
    frame and frame.aeuiQuestVisualThemeContract or "unapplied"

  local seal = frame and frame.aeuiQuestChromeSeal
  local sealStatus = "missing"
  if seal then
    if seal.IsShown and not seal:IsShown() then
      sealStatus = "hidden"
    else
      sealStatus = "detail-page-32"
    end
  end

  local fontPath = "unavailable"
  local row = _G["QuestLogTitle1"]
  local text = row and row.GetFontString and row:GetFontString()
  if text and text.GetFont then
    fontPath = text:GetFont() or fontPath
  end

  local scrollRange = "unavailable"
  if
    QuestLogDetailScrollFrame and
    QuestLogDetailScrollFrame.GetVerticalScrollRange
  then
    scrollRange =
      tostring(QuestLogDetailScrollFrame:GetVerticalScrollRange() or 0)
  end

  return
    "frame=" .. tostring(frameContract) ..
    ", theme=" .. tostring(themeContract) ..
    ", seal=" .. tostring(sealStatus) ..
    ", tag=semantic-setter-lock" ..
    ", reward=native-container-acyclic-visible-fallback-gap-8" ..
    ", font=" .. tostring(fontPath) ..
    ", detail-range=" .. tostring(scrollRange)
end

function Quests:Apply()
  if not addon.db or not addon.db.quests.enabled then
    return
  end
  self:ApplyPfQuestTrackerPaper()
  if not QuestLogFrame then
    addon:ScheduleRefresh(0.5)
    return
  end

  self:InstallGlobalHooks()
  self:InstallQuestLogFrameOnShowHook()
  self:EnsureShell(QuestLogFrame)
  self:EnsureQuestLogChromeSeal(QuestLogFrame)
  self:EnsureDetailToggle(QuestLogFrame)
  self:ApplyFrameGeometry()
  self:ApplyPfQuestQuestLogCompatibility()
  self:LayoutDirectoryRows()
  self:UpdateDirectoryRows()
  self:UpdateDetailToggle()
  QuestLogFrame.aeuiQuestRuntimeContract = self.runtimeContract
  QuestLogFrame.aeuiQuestVisualThemeContract = THEME.contract
  QuestLogFrame.aeuiQuestTagInkContract = "semantic-setter-lock"
  QuestLogFrame.aeuiQuestRewardLayoutContract =
    "native-container-acyclic-visible-fallback-gap-8"
end

addon:RegisterModule("Quests", Quests)
