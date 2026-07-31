local addon = AzerothExpeditionUI
local Quests = {}
Quests.runtimeContract = "1.9"

local SHELL_TEXTURE =
  addon.media.root .. "Quests\\QuestLogShellV4"
local DIRECTORY_MARK_TEXTURE =
  addon.media.root .. "Quests\\QuestLogDirectoryMarksV1"
local QUEST_TITLE_FONT =
  addon.media.root .. "Fonts\\NotoSerifSC-SemiBold.ttf"
local QUEST_ROW_FONT =
  addon.media.root .. "Fonts\\LXGWWenKaiGB-Medium.ttf"
local TRACKER_PAPER_TEXTURE =
  addon.media.root .. "Quests\\QuestTrackerPaperV1"
local QUEST_SEAL_TEXTURE =
  addon.media.root .. "Quests\\QuestToolWaxSealStatesV1"

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

local DIRECTORY = {
  contract = "1.3",
  rowCount = 23,
  rowWidth = 224,
  rowHeight = 15,
  rowStep = 14,
  textWidth = 190,
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
  leather = {
    base = { 0.20, 0.075, 0.035, 0.96 },
    edge = { 0.55, 0.32, 0.12, 0.90 },
    shadow = { 0.055, 0.022, 0.012, 0.95 },
    hover = { 0.52, 0.27, 0.08, 0.30 },
    pressed = { 0.02, 0.01, 0.005, 0.45 },
    disabled = { 0.08, 0.065, 0.05, 0.58 },
  },
  text = {
    normal = { 0.96, 0.79, 0.42, 1 },
    hover = { 1, 0.91, 0.62, 1 },
    pressed = { 0.86, 0.64, 0.28, 1 },
    disabled = { 0.48, 0.40, 0.30, 1 },
    ink = { 0.24, 0.12, 0.055, 1 },
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
  contract = "1.0",
  topOutset = 18,
  states = {
    normal = { 0, 0.25, 0, 1 },
    hover = { 0.25, 0.5, 0, 1 },
    pressed = { 0.5, 0.75, 0, 1 },
    disabled = { 0.75, 1, 0, 1 },
  },
  questLog = {
    width = 28,
    height = 28,
    left = 600,
    top = -18,
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

function Quests:StylePfQuestTrackerEntries(tracker)
  if not tracker or not tracker.buttons then
    return
  end
  for _, button in pairs(tracker.buttons) do
    if button and not button.aeuiQuestPaperOnlyStyled then
      if button.bg and button.bg.Hide then
        button.bg:Hide()
      elseif button.bg and button.bg.SetAlpha then
        button.bg:SetAlpha(0)
      end
      button.aeuiQuestPaperOnlyStyled = true
    end
  end
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
      Quests:LayoutPfQuestTrackerPaper(tracker, true)
      Quests:StylePfQuestTrackerEntries(tracker)
      Quests:EnsurePfQuestTrackerHubSeal(tracker)
    end
  )
  AppendScript(
    tracker,
    "OnUpdate",
    "aeuiQuestTrackerPaperOnUpdateHooked",
    function()
      Quests:LayoutPfQuestTrackerPaper(tracker)
      Quests:StylePfQuestTrackerEntries(tracker)
    end
  )

  self:LayoutPfQuestTrackerPaper(tracker, true)
  self:StylePfQuestTrackerEntries(tracker)
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
  AppendScript(
    button,
    "OnEnable",
    "aeuiQuestLeatherOnEnableHooked",
    function()
      UpdateLeatherButtonState(button)
    end
  )
  AppendScript(
    button,
    "OnDisable",
    "aeuiQuestLeatherOnDisableHooked",
    function()
      button.aeuiQuestControlPressed = nil
      UpdateLeatherButtonState(button)
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
    button:SetFont(QUEST_TITLE_FONT, 12, "OUTLINE")
  end
  UpdateLeatherButtonState(button)
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
    text:SetFont(
      QUEST_ROW_FONT,
      fontSize or 10,
      "OUTLINE"
    )
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

function Quests:HideDetailScrollbar()
  local scrollbar = QuestLogDetailScrollFrameScrollBar
  if not scrollbar then
    return
  end

  MakeBackdropTransparent(scrollbar)
  local thumb
  if scrollbar.GetThumbTexture then
    thumb = scrollbar:GetThumbTexture()
  end
  HideFrame(thumb)
  HideFrame(
    QuestLogDetailScrollFrameScrollBarScrollUpButton
  )
  HideFrame(
    QuestLogDetailScrollFrameScrollBarScrollDownButton
  )
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

  return title, isHeader, isCollapsed, isComplete
end

function Quests:EnsureDirectoryRows()
  if not QuestLogFrame or not QuestLogListScrollFrame then
    return false
  end

  for index = 1, DIRECTORY.rowCount do
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

      if row.SetFont then
        row:SetFont(QUEST_ROW_FONT, 10, "OUTLINE")
      end
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

      if not row.aeuiQuestListCheck then
        row.aeuiQuestListCheck =
          row:CreateTexture(nil, "ARTWORK")
        row.aeuiQuestListCheck.aeuiQuestManaged = true
        row.aeuiQuestListCheck:SetTexture(
          DIRECTORY_MARK_TEXTURE
        )
        SetSize(row.aeuiQuestListCheck, 10, 10)
        SetSinglePoint(
          row.aeuiQuestListCheck,
          "RIGHT",
          row,
          "RIGHT",
          -2,
          0
        )
      end

      row.aeuiQuestRegionToggle:Hide()
      row.aeuiQuestListCheck:Hide()
      previous = row
    end
  end

  if QuestLogTitleText and QuestLogTitleText.SetFont then
    QuestLogTitleText:SetFont(QUEST_TITLE_FONT, 15, "OUTLINE")
  end
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
      local check = row.aeuiQuestListCheck

      local questIndex = index + offset
      if questIndex <= count then
        local title, isHeader, isCollapsed =
          ReadQuestEntry(questIndex)
        if title and isHeader and toggle then
          HideNativeRegionToggle(row)
          SetDirectoryState(
            toggle,
            isCollapsed and
              DIRECTORY.states.collapsed or
              DIRECTORY.states.expanded
          )
        elseif
          title and
          check and
          type(IsQuestWatched) == "function"
        then
          local watched = false
          watched = IsQuestWatched(questIndex) and true or false
          HideNativeListCheck(index)
          SetDirectoryState(
            check,
            watched and
              DIRECTORY.states.tracked or
              DIRECTORY.states.untracked
          )
        end

      end
    end
  end
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

function Quests:ApplyDetailTextGeometry()
  if QuestLogDetailScrollChildFrame then
    if QuestLogDetailScrollChildFrame.SetWidth then
      QuestLogDetailScrollChildFrame:SetWidth(
        LAYOUT.detail.contentWidth
      )
    end
    if
      QuestLogDetailScrollChildFrame.GetHeight and
      QuestLogDetailScrollChildFrame.SetHeight and
      (
        not QuestLogDetailScrollChildFrame:GetHeight() or
        QuestLogDetailScrollChildFrame:GetHeight() <
          LAYOUT.detail.height
      )
    then
      QuestLogDetailScrollChildFrame:SetHeight(
        LAYOUT.detail.height
      )
    end
  end

  for _, name in ipairs(DETAIL_TEXT_NAMES) do
    local text = _G[name]
    if text and text.SetWidth then
      text:SetWidth(LAYOUT.detail.textWidth)
    end
  end

  local objectiveCount = tonumber(MAX_OBJECTIVES) or 10
  for index = 1, objectiveCount do
    local objective = _G["QuestLogObjective" .. index]
    if objective and objective.SetWidth then
      objective:SetWidth(LAYOUT.detail.objectiveWidth)
    end
  end

  self:HideDetailScrollbar()
  self:InstallDetailMouseWheel()
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
    count:SetFont(QUEST_TITLE_FONT, 12, "OUTLINE")
  end
  if count and count.SetTextColor then
    count:SetTextColor(
      CONTROL.text.ink[1],
      CONTROL.text.ink[2],
      CONTROL.text.ink[3],
      CONTROL.text.ink[4]
    )
  end

  local levelsText = QuestLogFrameLevelsCheckButtonText
  if levelsText then
    if levelsText.SetFont then
      levelsText:SetFont(QUEST_TITLE_FONT, 11, "OUTLINE")
    end
    if levelsText.SetTextColor then
      levelsText:SetTextColor(
        CONTROL.text.ink[1],
        CONTROL.text.ink[2],
        CONTROL.text.ink[3],
        CONTROL.text.ink[4]
      )
    end
  end

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

  self:HideDetailScrollbar()
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
end

addon:RegisterModule("Quests", Quests)
