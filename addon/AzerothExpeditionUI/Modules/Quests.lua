local addon = AzerothExpeditionUI
local Quests = {}
Quests.runtimeContract = "1.2"

local SHELL_TEXTURE =
  addon.media.root .. "Quests\\QuestLogShellV4"
local DIRECTORY_MARK_TEXTURE =
  addon.media.root .. "Quests\\QuestLogDirectoryMarksV1"
local SELECTION_TEXTURE =
  addon.media.root .. "Quests\\QuestLogSelectionBookmarkV1"
local QUEST_TITLE_FONT =
  addon.media.root .. "Fonts\\NotoSerifSC-SemiBold.ttf"
local QUEST_ROW_FONT =
  addon.media.root .. "Fonts\\LXGWWenKaiGB-Medium.ttf"

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

local DIRECTORY = {
  contract = "1.1",
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

local SELECTION = {
  contract = "1.0",
  width = 32,
  height = 16,
  x = -12,
  states = {
    selected = {
      left = 0,
      right = 0.25,
      top = 0,
      bottom = 1,
      y = 0,
    },
    hover = {
      left = 0.25,
      right = 0.5,
      top = 0,
      bottom = 1,
      y = 0,
    },
    pressed = {
      left = 0.5,
      right = 0.75,
      top = 0,
      bottom = 1,
      y = -1,
    },
  },
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
  if type(hooksecurefunc) ~= "function" then
    return
  end

  if
    not self.questLogOnShowHookInstalled and
    type(QuestLog_OnShow) == "function"
  then
    self.questLogOnShowHookInstalled = true
    hooksecurefunc("QuestLog_OnShow", function()
      Quests:Apply()
    end)
  end

  if
    not self.questLogUpdateHookInstalled and
    type(QuestLog_Update) == "function"
  then
    self.questLogUpdateHookInstalled = true
    hooksecurefunc("QuestLog_Update", function()
      Quests:UpdateDirectoryRows()
    end)
  end
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

local function SetSelectionState(row, texture, state)
  if not row or not texture or not state then
    return
  end
  texture:SetTexCoord(
    state.left,
    state.right,
    state.top,
    state.bottom
  )
  SetSinglePoint(
    texture,
    "LEFT",
    row,
    "LEFT",
    SELECTION.x,
    state.y
  )
  texture:Show()
end

local function InstallSelectionHooks(row)
  if not row then
    return
  end

  AppendScript(
    row,
    "OnEnter",
    "aeuiQuestSelectionOnEnterHooked",
    function()
      row.aeuiQuestSelectionHovered = true
      Quests:UpdateDirectoryRows()
    end
  )
  AppendScript(
    row,
    "OnLeave",
    "aeuiQuestSelectionOnLeaveHooked",
    function()
      row.aeuiQuestSelectionHovered = nil
      row.aeuiQuestSelectionPressed = nil
      Quests:UpdateDirectoryRows()
    end
  )
  AppendScript(
    row,
    "OnMouseDown",
    "aeuiQuestSelectionOnMouseDownHooked",
    function(button)
      local mouseButton = button or arg1
      if mouseButton == "LeftButton" then
        row.aeuiQuestSelectionPressed = true
        Quests:UpdateDirectoryRows()
      end
    end
  )
  AppendScript(
    row,
    "OnMouseUp",
    "aeuiQuestSelectionOnMouseUpHooked",
    function(button)
      local mouseButton = button or arg1
      if
        not mouseButton or
        mouseButton == "LeftButton"
      then
        row.aeuiQuestSelectionPressed = nil
        Quests:UpdateDirectoryRows()
      end
    end
  )
  AppendScript(
    row,
    "OnClick",
    "aeuiQuestSelectionOnClickHooked",
    function()
      row.aeuiQuestSelectionPressed = nil
      Quests:UpdateDirectoryRows()
    end
  )
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

function Quests:LayoutDirectoryRows()
  if not self:EnsureDirectoryRows() then
    return false
  end
  if
    QuestLogFrame.aeuiQuestDirectoryLayout ==
    DIRECTORY.contract
  then
    return true
  end

  local previous
  for index = 1, DIRECTORY.rowCount do
    local row = _G["QuestLogTitle" .. index]
    if row then
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

      if not row.aeuiQuestSelection then
        row.aeuiQuestSelection =
          row:CreateTexture(nil, "BORDER")
        row.aeuiQuestSelection.aeuiQuestManaged = true
        row.aeuiQuestSelection:SetTexture(
          SELECTION_TEXTURE
        )
        SetSize(
          row.aeuiQuestSelection,
          SELECTION.width,
          SELECTION.height
        )
      end
      InstallSelectionHooks(row)

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

      row.aeuiQuestSelection:Hide()
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

  if not self:LayoutDirectoryRows() then
    return
  end

  for index = 1, DIRECTORY.rowCount do
    local row = _G["QuestLogTitle" .. index]
    if row then
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
  local selection
  if type(GetQuestLogSelection) == "function" then
    selection = tonumber(GetQuestLogSelection())
    if not selection or selection < 1 then
      selection = nil
    end
  end
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
      local selectionTexture = row.aeuiQuestSelection

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

        if
          title and
          not isHeader and
          selection and
          questIndex == selection and
          selectionTexture
        then
          local selectionState = SELECTION.states.selected
          if row.aeuiQuestSelectionPressed then
            selectionState = SELECTION.states.pressed
          elseif row.aeuiQuestSelectionHovered then
            selectionState = SELECTION.states.hover
          end
          SetSelectionState(
            row,
            selectionTexture,
            selectionState
          )
        end
      end
    end
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
  self:LayoutDirectoryRows()
  self:UpdateDirectoryRows()
  self:UpdateDetailToggle()
  QuestLogFrame.aeuiQuestRuntimeContract = self.runtimeContract
end

addon:RegisterModule("Quests", Quests)
