local addon = AzerothExpeditionUI
local Quests = {}
Quests.runtimeContract = "1.0"

local SHELL_TEXTURE =
  addon.media.root .. "Quests\\QuestLogShellV4"

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
  },
  titleTop = 28,
  countLeft = 76,
  countTop = 52,
  closeRight = 18,
  closeTop = 20,
  actionLeft = 62,
  actionBottom = 22,
  actionWidth = 78,
  actionGap = 5,
}

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
  frame:SetScript(scriptName, function(...)
    if original then
      original(...)
    end
    callback(...)
  end)
end

function Quests:Initialize()
  self.driver = CreateFrame(
    "Frame",
    "AzerothExpeditionUIQuestDriver",
    UIParent
  )
  self.driver:RegisterEvent("PLAYER_ENTERING_WORLD")
  self.driver:RegisterEvent("ADDON_LOADED")
  self.driver:SetScript("OnEvent", function()
    if
      event == "PLAYER_ENTERING_WORLD" or
      (
        event == "ADDON_LOADED" and
        (
          arg1 == "Blizzard_QuestUI" or
          arg1 == "Blizzard_QuestLog"
        )
      )
    then
      addon:ScheduleRefresh(0)
    end
  end)
  self:InstallGlobalHooks()
end

function Quests:InstallGlobalHooks()
  if self.globalHooksInstalled then
    return
  end

  if
    type(hooksecurefunc) == "function" and
    type(QuestLog_OnShow) == "function"
  then
    self.globalHooksInstalled = true
    hooksecurefunc("QuestLog_OnShow", function()
      Quests:Apply()
    end)
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

function Quests:ApplyFrameGeometry()
  local frame = QuestLogFrame
  if not frame then
    return
  end

  SetSize(frame, SHELL.width, SHELL.height)

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
    "TOPLEFT",
    frame,
    "TOPLEFT",
    LAYOUT.countLeft,
    -LAYOUT.countTop
  )

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

  if QuestLogDetailScrollChildFrame then
    if QuestLogDetailScrollChildFrame.SetWidth then
      QuestLogDetailScrollChildFrame:SetWidth(LAYOUT.detail.width)
    end
    if
      QuestLogDetailScrollChildFrame.GetHeight and
      QuestLogDetailScrollChildFrame.SetHeight and
      (
        not QuestLogDetailScrollChildFrame:GetHeight() or
        QuestLogDetailScrollChildFrame:GetHeight() < LAYOUT.detail.height
      )
    then
      QuestLogDetailScrollChildFrame:SetHeight(LAYOUT.detail.height)
    end
  end

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
      local height =
        button.GetHeight and button:GetHeight() or 20
      if not height or height <= 0 then
        height = 20
      end
      SetSize(button, LAYOUT.actionWidth, height)
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
  if not QuestLogFrame then
    addon:ScheduleRefresh(0.5)
    return
  end

  self:InstallGlobalHooks()
  self:EnsureShell(QuestLogFrame)
  self:EnsureDetailToggle(QuestLogFrame)
  self:ApplyFrameGeometry()
  self:UpdateDetailToggle()
  QuestLogFrame.aeuiQuestRuntimeContract = self.runtimeContract
end

addon:RegisterModule("Quests", Quests)
