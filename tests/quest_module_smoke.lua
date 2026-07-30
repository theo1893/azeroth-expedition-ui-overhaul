local root = assert(arg[1], "repository root argument is required")

table.getn = table.getn or function(value)
  return #value
end

local clock = 10
function GetTime()
  clock = clock + 0.1
  return clock
end

local Object = {}
Object.__index = Object

local function NewObject(name, parent, objectType)
  local value = setmetatable({
    name = name,
    parent = parent,
    objectType = objectType or "Frame",
    width = 0,
    height = 0,
    shown = true,
    enabled = true,
    points = {},
    scripts = {},
    regions = {},
  }, Object)
  if name then
    _G[name] = value
  end
  return value
end

function Object:RegisterEvent(value)
  self.events = self.events or {}
  self.events[value] = true
end
function Object:GetName() return self.name end
function Object:GetObjectType() return self.objectType end
function Object:IsObjectType(value) return self.objectType == value end
function Object:SetTexture(...)
  self.textureArgs = { ... }
  if select("#", ...) == 1 then
    self.texture = select(1, ...)
  else
    self.texture = nil
  end
end
function Object:SetTexCoord(...) self.texcoord = { ... } end
function Object:SetVertexColor(...) self.vertexColor = { ... } end
function Object:SetBackdropColor(...) self.backdropColor = { ... } end
function Object:SetBackdropBorderColor(...) self.borderColor = { ... } end
function Object:SetAlpha(value) self.alpha = value end
function Object:SetText(value)
  self.text = value
  if self.fontString then
    self.fontString.text = value
  end
end
function Object:GetText() return self.text end
function Object:SetTextColor(...) self.textColor = { ... } end
function Object:SetID(value) self.id = value end
function Object:GetID() return self.id end
function Object:SetFont(...) self.font = { ... } end
function Object:GetFontString() return self.fontString end
function Object:SetWidth(value) self.width = value end
function Object:SetHeight(value) self.height = value end
function Object:GetWidth() return self.width end
function Object:GetHeight() return self.height end
function Object:ClearAllPoints() self.points = {} end
function Object:SetPoint(...) table.insert(self.points, { ... }) end
function Object:GetPoint(index)
  local point = self.points[index or 1]
  if point then
    return table.unpack(point)
  end
end
function Object:SetAllPoints(target) self.allPoints = target end
function Object:SetScript(kind, callback) self.scripts[kind] = callback end
function Object:GetScript(kind) return self.scripts[kind] end
function Object:IsShown() return self.shown end
function Object:Show()
  local changed = not self.shown
  self.shown = true
  if changed and self.scripts.OnShow then
    self.scripts.OnShow()
  end
end
function Object:Hide()
  local changed = self.shown
  self.shown = false
  if changed and self.scripts.OnHide then
    self.scripts.OnHide()
  end
end
function Object:Enable()
  local changed = not self.enabled
  self.enabled = true
  if changed and self.scripts.OnEnable then
    self.scripts.OnEnable()
  end
end
function Object:Disable()
  local changed = self.enabled
  self.enabled = false
  if changed and self.scripts.OnDisable then
    self.scripts.OnDisable()
  end
end
function Object:IsEnabled() return self.enabled end
function Object:EnableMouse(value) self.mouseEnabled = value end
function Object:EnableMouseWheel(value) self.mouseWheelEnabled = value end
function Object:GetVerticalScroll() return self.verticalScroll or 0 end
function Object:SetVerticalScroll(value) self.verticalScroll = value end
function Object:GetVerticalScrollRange()
  return self.verticalScrollRange or 0
end
function Object:GetRegions() return table.unpack(self.regions) end
function Object:CreateTexture(name, layer)
  local texture = NewObject(name, self, "Texture")
  texture.layer = layer
  table.insert(self.regions, texture)
  return texture
end
function Object:GetNormalTexture() return self.normalTexture end
function Object:GetHighlightTexture() return self.highlightTexture end
function Object:GetPushedTexture() return self.pushedTexture end
function Object:GetDisabledTexture() return self.disabledTexture end
function Object:GetCheckedTexture() return self.checkedTexture end
function Object:GetThumbTexture() return self.thumbTexture end
function Object:GetChecked() return self.checked end
function Object:SetChecked(value) self.checked = value and true or false end
function Object:SetNormalTexture(value)
  if not self.normalTexture then
    self.normalTexture =
      NewObject(self.name and self.name .. "NormalTexture", self, "Texture")
  end
  self.normalTexture:SetTexture(value)
end
function Object:SetHighlightTexture(value)
  if not self.highlightTexture then
    self.highlightTexture =
      NewObject(self.name and self.name .. "Highlight", self, "Texture")
  end
  self.highlightTexture:SetTexture(value)
end
function Object:SetPushedTexture(value)
  if not self.pushedTexture then
    self.pushedTexture =
      NewObject(self.name and self.name .. "PushedTexture", self, "Texture")
  end
  self.pushedTexture:SetTexture(value)
end
function Object:SetDisabledTexture(value)
  if not self.disabledTexture then
    self.disabledTexture =
      NewObject(self.name and self.name .. "DisabledTexture", self, "Texture")
  end
  self.disabledTexture:SetTexture(value)
end
function Object:SetCheckedTexture(value)
  if not self.checkedTexture then
    self.checkedTexture =
      NewObject(self.name and self.name .. "CheckedTexture", self, "Texture")
  end
  self.checkedTexture:SetTexture(value)
end

function CreateFrame(objectType, name, parent, template)
  local frame = NewObject(name, parent, objectType)
  frame.template = template
  if objectType == "Button" or objectType == "CheckButton" then
    frame.fontString =
      NewObject(name and name .. "Text", frame, "FontString")
    frame.normalTexture =
      NewObject(name and name .. "NormalTexture", frame, "Texture")
    frame.highlightTexture =
      NewObject(name and name .. "Highlight", frame, "Texture")
    frame.pushedTexture =
      NewObject(name and name .. "PushedTexture", frame, "Texture")
    frame.disabledTexture =
      NewObject(name and name .. "DisabledTexture", frame, "Texture")
    if objectType == "CheckButton" then
      frame.checkedTexture =
        NewObject(name and name .. "CheckedTexture", frame, "Texture")
    end
  end
  if template == "QuestLogTitleButtonTemplate" then
    NewObject(name and name .. "Check", frame, "Texture")
  end
  return frame
end

function hooksecurefunc(name, callback)
  local original = _G[name]
  _G[name] = function(...)
    local result = original(...)
    callback(...)
    return result
  end
end

UIParent = NewObject("UIParent", nil)
DEFAULT_CHAT_FRAME = {
  messages = {},
  AddMessage = function(self, message)
    table.insert(self.messages, message)
  end,
}
SlashCmdList = {}
function ReloadUI() end

local questLogShowCalls = 0
function QuestLog_OnShow()
  questLogShowCalls = questLogShowCalls + 1
end

local detailUpdateCalls = 0
function QuestLog_UpdateQuestDetails()
  detailUpdateCalls = detailUpdateCalls + 1
  if QuestLogQuestDescription then
    QuestLogQuestDescription:SetWidth(270)
  end
end

local questLogUpdateCalls = 0
local fauxOffset = 0
local selectedQuestIndex = 2
local watched = {
  [3] = true,
}
local questEntries = {
  { "东瘟疫之地", 0, nil, true, false, nil },
  { "爱与家庭", 60, nil, false, nil, nil },
  { "达隆郡的战斗", 60, nil, false, nil, nil },
  { "冬泉谷", 0, nil, true, true, nil },
}
function GetNumQuestLogEntries()
  return table.getn(questEntries)
end
function GetQuestLogTitle(index)
  return table.unpack(questEntries[index], 1, 6)
end
function IsQuestWatched(index)
  return watched[index]
end
function FauxScrollFrame_GetOffset()
  return fauxOffset
end
function GetQuestLogSelection()
  return selectedQuestIndex
end
function QuestLog_Update()
  questLogUpdateCalls = questLogUpdateCalls + 1
  if QuestLogHighlightFrame then
    QuestLogHighlightFrame:SetAlpha(1)
    QuestLogHighlightFrame:Show()
  end
  for index = 1, 23 do
    local row = _G["QuestLogTitle" .. index]
    if row and row.highlightTexture then
      row.highlightTexture:SetAlpha(1)
    end
    local check = _G["QuestLogTitle" .. index .. "Check"]
    if check then
      check:Show()
    end
  end
end

QuestLogFrame = CreateFrame("Frame", "QuestLogFrame", UIParent)
QuestLogFrame:SetWidth(512)
QuestLogFrame:SetHeight(440)
QuestLogHighlightFrame =
  CreateFrame("Frame", "QuestLogHighlightFrame", QuestLogFrame)
local nativeFrameTexture =
  QuestLogFrame:CreateTexture("QuestLogNativeTexture", "BACKGROUND")

QuestLogTitleText =
  NewObject("QuestLogTitleText", QuestLogFrame, "FontString")
QuestLogTitleText:SetText("任务日志")
QuestLogQuestCount =
  NewObject("QuestLogQuestCount", QuestLogFrame, "FontString")
QuestLogQuestCount:SetText("12/20")
QuestLogCollapseAllButton =
  CreateFrame("Button", "QuestLogCollapseAllButton", QuestLogFrame)
QuestLogCollapseAllButton:SetText("全部")
QuestLogCollapseAllButton.icon =
  CreateFrame(
    "Button",
    "QuestLogCollapseAllButtonCollapseButton",
    QuestLogCollapseAllButton
  )
QuestLogCollapseAllButton.icon.mouseEnabled = true
QuestLogCollapseAllButton.icon.text =
  NewObject(
    "QuestLogCollapseAllButtonCollapseButtonText",
    QuestLogCollapseAllButton.icon,
    "FontString"
  )
QuestLogFrameLevelsCheckButton =
  CreateFrame("CheckButton", "QuestLogFrameLevelsCheckButton", QuestLogFrame)
QuestLogFrameLevelsCheckButton:SetChecked(true)
QuestLogTrack =
  CreateFrame("CheckButton", "QuestLogTrack", QuestLogFrame)
QuestLogTrackTitle =
  NewObject("QuestLogTrackTitle", QuestLogTrack, "FontString")
QuestLogFrameCloseButton =
  CreateFrame("Button", "QuestLogFrameCloseButton", QuestLogFrame)

QuestLogListScrollFrame =
  CreateFrame("ScrollFrame", "QuestLogListScrollFrame", QuestLogFrame)
local nativeListTexture =
  QuestLogListScrollFrame:CreateTexture(
    "QuestLogNativeListTexture",
    "BACKGROUND"
  )
QuestLogListScrollFrameScrollBar =
  CreateFrame(
    "Slider",
    "QuestLogListScrollFrameScrollBar",
    QuestLogListScrollFrame
  )
QuestLogListScrollFrameScrollBar.mouseEnabled = true
QuestLogListScrollFrameScrollBar.thumbTexture =
  QuestLogListScrollFrameScrollBar:CreateTexture(
    "QuestLogListScrollFrameScrollBarThumbTexture",
    "ARTWORK"
  )

QuestLogDetailScrollFrame =
  CreateFrame("ScrollFrame", "QuestLogDetailScrollFrame", QuestLogFrame)
QuestLogDetailScrollFrame.verticalScrollRange = 140
local detailWheelCalls = 0
QuestLogDetailScrollFrame:SetScript("OnMouseWheel", function()
  detailWheelCalls = detailWheelCalls + 1
end)
local nativeDetailTexture =
  QuestLogDetailScrollFrame:CreateTexture(
    "QuestLogNativeDetailTexture",
    "BACKGROUND"
  )
QuestLogDetailScrollFrameScrollBar =
  CreateFrame(
    "Slider",
    "QuestLogDetailScrollFrameScrollBar",
    QuestLogDetailScrollFrame
  )
QuestLogDetailScrollFrameScrollBar.mouseEnabled = true
QuestLogDetailScrollFrameScrollBar.thumbTexture =
  QuestLogDetailScrollFrameScrollBar:CreateTexture(
    "QuestLogDetailScrollFrameScrollBarThumbTexture",
    "ARTWORK"
  )
QuestLogDetailScrollFrameScrollBarScrollUpButton =
  CreateFrame(
    "Button",
    "QuestLogDetailScrollFrameScrollBarScrollUpButton",
    QuestLogDetailScrollFrameScrollBar
  )
QuestLogDetailScrollFrameScrollBarScrollDownButton =
  CreateFrame(
    "Button",
    "QuestLogDetailScrollFrameScrollBarScrollDownButton",
    QuestLogDetailScrollFrameScrollBar
  )
QuestLogDetailScrollChildFrame =
  CreateFrame(
    "Frame",
    "QuestLogDetailScrollChildFrame",
    QuestLogDetailScrollFrame
  )
QuestLogDetailScrollChildFrame:SetHeight(120)
MAX_OBJECTIVES = 3
for _, name in ipairs({
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
}) do
  local text =
    NewObject(name, QuestLogDetailScrollChildFrame, "FontString")
  text:SetWidth(270)
end
for index = 1, MAX_OBJECTIVES do
  local objective = NewObject(
    "QuestLogObjective" .. index,
    QuestLogDetailScrollChildFrame,
    "FontString"
  )
  objective:SetWidth(260)
end

local detailOnHideCalls = 0
local detailOnShowCalls = 0
QuestLogDetailScrollFrame:SetScript("OnHide", function()
  detailOnHideCalls = detailOnHideCalls + 1
end)
QuestLogDetailScrollFrame:SetScript("OnShow", function()
  detailOnShowCalls = detailOnShowCalls + 1
end)

EmptyQuestLogFrame =
  CreateFrame("Frame", "EmptyQuestLogFrame", QuestLogFrame)
local nativeEmptyTexture =
  EmptyQuestLogFrame:CreateTexture(
    "QuestLogNativeEmptyTexture",
    "BACKGROUND"
  )
QuestLogExpandButtonFrame =
  CreateFrame("Frame", "QuestLogExpandButtonFrame", QuestLogFrame)
local nativeExpandTexture =
  QuestLogExpandButtonFrame:CreateTexture(
    "QuestLogNativeExpandTexture",
    "BACKGROUND"
  )
QuestLogNoQuestsText =
  NewObject("QuestLogNoQuestsText", EmptyQuestLogFrame, "FontString")

local originalQuestRowClickCalls = 0
local originalQuestRowEnterCalls = 0
local originalQuestRowLeaveCalls = 0
local originalQuestRowMouseDownCalls = 0
local originalQuestRowMouseUpCalls = 0
local originalQuestRowClick = function()
  originalQuestRowClickCalls = originalQuestRowClickCalls + 1
end
local originalQuestRowEnter = function()
  originalQuestRowEnterCalls = originalQuestRowEnterCalls + 1
end
local originalQuestRowLeave = function()
  originalQuestRowLeaveCalls = originalQuestRowLeaveCalls + 1
end
local originalQuestRowMouseDown = function()
  originalQuestRowMouseDownCalls =
    originalQuestRowMouseDownCalls + 1
end
local originalQuestRowMouseUp = function()
  originalQuestRowMouseUpCalls =
    originalQuestRowMouseUpCalls + 1
end
for index = 1, 6 do
  local row = CreateFrame(
    "Button",
    "QuestLogTitle" .. index,
    QuestLogFrame,
    "QuestLogTitleButtonTemplate"
  )
  row:SetID(index)
  row:SetScript("OnClick", originalQuestRowClick)
  row:SetScript("OnEnter", originalQuestRowEnter)
  row:SetScript("OnLeave", originalQuestRowLeave)
  row:SetScript("OnMouseDown", originalQuestRowMouseDown)
  row:SetScript("OnMouseUp", originalQuestRowMouseUp)
end

QuestLogFrameAbandonButton =
  CreateFrame("Button", "QuestLogFrameAbandonButton", QuestLogFrame)
QuestLogFrameAbandonButton:SetHeight(20)
QuestLogFrameAbandonButton:SetText("放弃任务")
QuestFramePushQuestButton =
  CreateFrame("Button", "QuestFramePushQuestButton", QuestLogFrame)
QuestFramePushQuestButton:SetHeight(20)
QuestFramePushQuestButton:SetText("共享任务")
QuestFrameExitButton =
  CreateFrame("Button", "QuestFrameExitButton", QuestLogFrame)
QuestFrameExitButton:SetHeight(20)
QuestFrameExitButton:SetText("退出")

local abandonCalls = 0
local abandonScript = function()
  abandonCalls = abandonCalls + 1
end
QuestLogFrameAbandonButton:SetScript("OnClick", abandonScript)

pfUI = {}
AzerothExpeditionUIDB = {
  sentinel = "preserve",
  quests = {
    enabled = true,
    artVersion = 4,
  },
}

dofile(root .. "/addon/AzerothExpeditionUI/Core/Bootstrap.lua")
dofile(root .. "/addon/AzerothExpeditionUI/Modules/Quests.lua")

AzerothExpeditionUI:Initialize()
AzerothExpeditionUI:Refresh()

assert(QuestLogFrame:GetWidth() == 676, "quest shell width was not applied")
assert(QuestLogFrame:GetHeight() == 464, "quest shell height was not applied")
assert(
  QuestLogFrame.aeuiQuestRuntimeContract == "1.6",
  "quest runtime contract was not recorded"
)
assert(QuestLogFrame.aeuiQuestShell, "quest shell texture was not created")
assert(
  QuestLogFrame.aeuiQuestShell.texture:find("QuestLogShellV4"),
  "quest shell runtime texture was not mounted"
)
assert(
  QuestLogFrame.aeuiQuestShell.layer == "BACKGROUND",
  "quest shell must remain a non-interactive background layer"
)
assert(
  QuestLogFrame.aeuiQuestShell.texcoord[2] == 0.66015625 and
  QuestLogFrame.aeuiQuestShell.texcoord[4] == 0.90625,
  "quest shell UV does not match the runtime manifest"
)

for _, nativeTexture in ipairs({
  nativeFrameTexture,
  nativeListTexture,
  nativeDetailTexture,
  nativeEmptyTexture,
  nativeExpandTexture,
}) do
  assert(
    not nativeTexture:IsShown(),
    "native decorative texture remained above the accepted shell"
  )
end

assert(QuestLogTitleText:GetText() == "任务日志")
assert(QuestLogQuestCount:GetText() == "12/20")
assert(QuestLogListScrollFrame:GetWidth() == 246)
assert(QuestLogListScrollFrame:GetHeight() == 324)
assert(QuestLogDetailScrollFrame:GetWidth() == 246)
assert(QuestLogDetailScrollFrame:GetHeight() == 324)
assert(QuestLogDetailScrollChildFrame:GetWidth() == 224)
assert(QuestLogDetailScrollChildFrame:GetHeight() == 324)
for _, name in ipairs({
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
}) do
  assert(
    _G[name]:GetWidth() == 214,
    name .. " exceeded the right-page text safe area"
  )
end
for index = 1, MAX_OBJECTIVES do
  assert(
    _G["QuestLogObjective" .. index]:GetWidth() == 204,
    "quest objective exceeded the inset text safe area"
  )
end
local countPoint, countRelative, countRelativePoint, countX, countY =
  QuestLogQuestCount:GetPoint()
assert(
  countPoint == "TOPRIGHT" and
    countRelative == QuestLogFrame and
    countRelativePoint == "TOPLEFT" and
    countX == 310 and
    countY == -52,
  "quest count was not constrained to the left-page control row"
)
assert(
  not QuestLogCollapseAllButton:IsShown() and
    not QuestLogCollapseAllButton:IsEnabled() and
    QuestLogCollapseAllButton.mouseEnabled == false,
  "collapse-all button remained visible or interactive"
)
assert(
  not QuestLogCollapseAllButton.icon:IsShown() and
    QuestLogCollapseAllButton.icon.mouseEnabled == false and
    not QuestLogCollapseAllButton.aeuiQuestInkWash,
  "pfUI collapse glyph or retired ink treatment remained active"
)
QuestLogCollapseAllButton:Show()
assert(
  not QuestLogCollapseAllButton:IsShown(),
  "collapse-all button returned after an external Show call"
)
local levelsPoint, levelsRelative, levelsRelativePoint,
  levelsX, levelsY =
  QuestLogFrameLevelsCheckButton:GetPoint()
assert(
  levelsPoint == "TOPLEFT" and
    levelsRelative == QuestLogFrame and
    levelsRelativePoint == "TOPLEFT" and
    levelsX == 138 and
    levelsY == -46,
  "quest-level control still depended on the removed collapse button"
)
assert(
  QuestLogQuestCount.font[1]:find("NotoSerifSC%-SemiBold.ttf") and
    QuestLogQuestCount.textColor[1] == 0.24,
  "quest count did not receive the book-ink typography"
)
local trackPoint, trackRelative =
  QuestLogTrack:GetPoint()
assert(
  trackPoint == "RIGHT" and trackRelative == QuestLogQuestCount,
  "tracking control was not kept beside the quest count"
)
assert(
  not QuestLogTrackTitle:IsShown(),
  "native tracking label overlapped the quest count"
)
for _, toggle in ipairs({
  QuestLogFrameLevelsCheckButton,
  QuestLogTrack,
}) do
  assert(
    toggle:GetWidth() == 14 and toggle:GetHeight() == 14,
    "top tracking control did not use the compact ink-mark hit box"
  )
  assert(
    toggle:GetNormalTexture().texture:find(
      "QuestLogDirectoryMarksV1"
    ) and
      toggle:GetCheckedTexture().texture:find(
        "QuestLogDirectoryMarksV1"
      ),
    "top tracking control did not reuse the accepted ink atlas"
  )
end
assert(
  QuestLogFrameAbandonButton:GetScript("OnClick") == abandonScript,
  "quest action behavior was replaced by the visual adapter"
)
for _, button in ipairs({
  QuestLogFrameAbandonButton,
  QuestFramePushQuestButton,
  QuestFrameExitButton,
}) do
  assert(
    button:GetWidth() == 78 and button:GetHeight() == 22,
    "bottom action button geometry is outside the shell safe area"
  )
  assert(
    button.aeuiQuestLeatherBase and
      button.aeuiQuestLeatherTop and
      button.aeuiQuestLeatherBottom and
      button.aeuiQuestLeatherHover and
      button.aeuiQuestLeatherPressed and
      button.aeuiQuestLeatherDisabled,
    "bottom action button did not receive the leather clasp treatment"
  )
  assert(
    button.font[1]:find("NotoSerifSC%-SemiBold.ttf"),
    "bottom action button did not use the quest title font"
  )
end
assert(
  not QuestLogDetailScrollFrameScrollBar:IsShown() and
    not QuestLogDetailScrollFrameScrollBar.thumbTexture:IsShown() and
    not QuestLogDetailScrollFrameScrollBarScrollUpButton:IsShown() and
    not QuestLogDetailScrollFrameScrollBarScrollDownButton:IsShown(),
  "right-page scrollbar chrome remained visible"
)
assert(
  QuestLogDetailScrollFrameScrollBar.mouseEnabled == false and
    QuestLogDetailScrollFrame.mouseWheelEnabled == true,
  "hidden detail scrollbar did not hand reading control to the page"
)
assert(
  QuestLogListScrollFrameScrollBar:IsShown() and
    QuestLogListScrollFrameScrollBar.mouseEnabled == true,
  "left-page list scrollbar was hidden with the detail scrollbar"
)
assert(AzerothExpeditionUIDB.sentinel == "preserve")

assert(QUESTS_DISPLAYED == 23, "quest row count was not expanded to 23")
for index = 1, 23 do
  local row = _G["QuestLogTitle" .. index]
  assert(row, "missing QuestLogTitle" .. index)
  assert(row:GetID() == index, "quest row ID was not preserved")
  assert(
    row:GetWidth() == 224 and row:GetHeight() == 15,
    "quest row geometry does not match QL-B0"
  )
  assert(
    row.highlightTexture.alpha == 0 and
      row.pushedTexture.alpha == 0,
    "native row selection visual remained visible"
  )
  assert(
    row.aeuiQuestRegionToggle and
      row.aeuiQuestListCheck,
    "quest directory overlays were not created"
  )
  assert(
    row.aeuiQuestRegionToggle.texture:find(
      "QuestLogDirectoryMarksV1"
    ),
    "quest region toggle did not mount the accepted atlas"
  )
  assert(
    row.aeuiQuestListCheck.texture:find(
      "QuestLogDirectoryMarksV1"
    ),
    "quest tracking mark did not mount the accepted atlas"
  )
  assert(
    not row.aeuiQuestSelection or
      not row.aeuiQuestSelection:IsShown(),
    "wine-red selection bookmark should be hidden"
  )
  local _, _, _, textX, textY = row.fontString:GetPoint()
  assert(
    textX == 18 and textY == 0,
    "quest text did not preserve the directory-mark safe area"
  )
end
assert(
  QuestLogHighlightFrame.alpha == 0,
  "native full-row selection frame remained visible"
)
assert(
  QuestLogTitle1.aeuiQuestRegionToggle:IsShown() and
  QuestLogTitle1.aeuiQuestRegionToggle.texcoord[1] == 0.28125,
  "expanded region state was not mapped: shown=" ..
    tostring(QuestLogTitle1.aeuiQuestRegionToggle:IsShown()) ..
    ", left=" ..
    tostring(
      QuestLogTitle1.aeuiQuestRegionToggle.texcoord and
      QuestLogTitle1.aeuiQuestRegionToggle.texcoord[1]
    )
)
assert(
  QuestLogTitle4.aeuiQuestRegionToggle:IsShown() and
  QuestLogTitle4.aeuiQuestRegionToggle.texcoord[1] == 0.03125,
  "collapsed region state was not mapped"
)
assert(
  QuestLogTitle2.aeuiQuestListCheck:IsShown() and
  QuestLogTitle2.aeuiQuestListCheck.texcoord[1] == 0.546875,
  "untracked quest state was not mapped"
)
assert(
  QuestLogTitle3.aeuiQuestListCheck:IsShown() and
  QuestLogTitle3.aeuiQuestListCheck.texcoord[1] == 0.796875,
  "tracked quest state was not mapped"
)
assert(
  not QuestLogTitle3Check:IsShown(),
  "native quest tracking texture remained visible"
)

assert(
  QuestLogTitle2:GetScript("OnEnter") == originalQuestRowEnter and
    QuestLogTitle2:GetScript("OnLeave") == originalQuestRowLeave and
    QuestLogTitle2:GetScript("OnMouseDown") ==
      originalQuestRowMouseDown and
    QuestLogTitle2:GetScript("OnMouseUp") ==
      originalQuestRowMouseUp and
    QuestLogTitle2:GetScript("OnClick") == originalQuestRowClick,
  "hiding the bookmark must not wrap quest-row interaction"
)

QuestLogTitle2:GetScript("OnEnter")()
assert(originalQuestRowEnterCalls == 1)
QuestLogTitle2:GetScript("OnMouseDown")("RightButton")
assert(originalQuestRowMouseDownCalls == 1)
QuestLogTitle2:GetScript("OnMouseDown")("LeftButton")
assert(originalQuestRowMouseDownCalls == 2)
QuestLogTitle2:GetScript("OnMouseUp")("LeftButton")
assert(originalQuestRowMouseUpCalls == 1)
QuestLogTitle2:GetScript("OnLeave")()
assert(originalQuestRowLeaveCalls == 1)
QuestLogTitle2:GetScript("OnClick")()
assert(
  originalQuestRowClickCalls == 1,
  "existing quest row OnClick behavior was not preserved"
)

selectedQuestIndex = 3
QuestLog_Update()
selectedQuestIndex = 2
QuestLog_Update()
for index = 1, 23 do
  assert(
    not _G["QuestLogTitle" .. index].aeuiQuestSelection or
      not _G["QuestLogTitle" .. index].aeuiQuestSelection:IsShown(),
    "selection refresh restored the hidden wine-red bookmark"
  )
end
assert(
  QuestLogTitle1.font[1]:find("LXGWWenKaiGB%-Medium.ttf"),
  "quest row font does not match the module baseline"
)
assert(
  QuestLogTitleText.font[1]:find("NotoSerifSC%-SemiBold.ttf"),
  "quest title font does not match the module baseline"
)

watched[2] = true
local updateCallsBeforeTrackingRefresh = questLogUpdateCalls
QuestLog_Update()
assert(
  questLogUpdateCalls == updateCallsBeforeTrackingRefresh + 1,
  "native QuestLog_Update was replaced"
)
assert(
  QuestLogHighlightFrame.alpha == 0 and
    QuestLogTitle2.highlightTexture.alpha == 0,
  "native selection visuals returned after QuestLog_Update"
)
assert(
  QuestLogTitle2.aeuiQuestListCheck.texcoord[1] == 0.796875,
  "tracking-state refresh hook did not update the runtime sprite"
)
assert(
  not QuestLogTitle2Check:IsShown(),
  "native tracking texture returned above the accepted sprite"
)

fauxOffset = 1
QuestLog_Update()
assert(
  not QuestLogTitle1.aeuiQuestRegionToggle:IsShown() and
  QuestLogTitle1.aeuiQuestListCheck:IsShown(),
  "scroll offset was not applied to the visible row mapping"
)
fauxOffset = 0
QuestLog_Update()

local savedIsQuestWatched = IsQuestWatched
IsQuestWatched = nil
QuestLog_Update()
assert(
  not QuestLogTitle2.aeuiQuestListCheck:IsShown(),
  "AEUI tracking art guessed a state without the tracking API"
)
assert(
  QuestLogTitle2Check:IsShown(),
  "native tracking art was not preserved when its API was unavailable"
)
IsQuestWatched = savedIsQuestWatched
QuestLog_Update()

local detailWheel = QuestLogDetailScrollFrame:GetScript("OnMouseWheel")
detailWheel(-1)
assert(
  detailWheelCalls == 1 and
    QuestLogDetailScrollFrame:GetVerticalScroll() == 28,
  "detail mouse wheel did not preserve the native script and scroll down"
)
detailWheel(-10)
assert(
  QuestLogDetailScrollFrame:GetVerticalScroll() == 140,
  "detail mouse wheel did not clamp to the scroll range"
)
detailWheel(10)
assert(
  QuestLogDetailScrollFrame:GetVerticalScroll() == 0,
  "detail mouse wheel did not clamp at the top of the page"
)
QuestLogDetailScrollFrameScrollBar:Show()
assert(
  not QuestLogDetailScrollFrameScrollBar:IsShown(),
  "detail scrollbar returned after an external Show call"
)

local abandonEnter =
  QuestLogFrameAbandonButton:GetScript("OnEnter")
local abandonLeave =
  QuestLogFrameAbandonButton:GetScript("OnLeave")
local abandonDown =
  QuestLogFrameAbandonButton:GetScript("OnMouseDown")
local abandonUp =
  QuestLogFrameAbandonButton:GetScript("OnMouseUp")
abandonEnter()
assert(
  QuestLogFrameAbandonButton.aeuiQuestLeatherHover:IsShown(),
  "bottom action hover state was not rendered"
)
abandonDown("RightButton")
assert(
  not QuestLogFrameAbandonButton.aeuiQuestLeatherPressed:IsShown(),
  "right click incorrectly activated the action pressed state"
)
abandonDown("LeftButton")
assert(
  QuestLogFrameAbandonButton.aeuiQuestLeatherPressed:IsShown(),
  "left click did not activate the action pressed state"
)
abandonUp("LeftButton")
assert(
  QuestLogFrameAbandonButton.aeuiQuestLeatherHover:IsShown() and
    not QuestLogFrameAbandonButton.aeuiQuestLeatherPressed:IsShown(),
  "mouse-up did not restore the action hover state"
)
abandonLeave()
QuestLogFrameAbandonButton:Disable()
assert(
  QuestLogFrameAbandonButton.aeuiQuestLeatherDisabled:IsShown(),
  "disabled action button did not receive its muted state"
)
QuestLogFrameAbandonButton:Enable()
assert(
  not QuestLogFrameAbandonButton.aeuiQuestLeatherDisabled:IsShown(),
  "enabled action button retained its disabled overlay"
)

assert(QuestLogFrameExpandButton, "real detail toggle Button was not created")
assert(
  QuestLogFrameExpandButton.template == "UIPanelButtonTemplate",
  "detail toggle did not use a real Button template"
)
assert(
  QuestLogFrameExpandButton:GetWidth() == 24 and
    QuestLogFrameExpandButton:GetHeight() == 22 and
    QuestLogFrameExpandButton.aeuiQuestLeatherBase,
  "detail toggle did not join the bottom leather control row"
)
QuestLogFrameExpandButton:GetScript("OnClick")()
assert(
  not QuestLogDetailScrollFrame:IsShown(),
  "detail toggle did not hide right-page dynamic content"
)
assert(
  QuestLogFrame:GetWidth() == 676 and QuestLogFrame:GetHeight() == 464,
  "list-only state physically collapsed the static book"
)
assert(detailOnHideCalls == 1, "original detail OnHide script was not preserved")

QuestLogFrameExpandButton:GetScript("OnClick")()
assert(QuestLogDetailScrollFrame:IsShown())
assert(detailOnShowCalls == 1, "original detail OnShow script was not preserved")
assert(detailUpdateCalls == 1, "detail content was not refreshed after reopening")
assert(
  QuestLogQuestDescription:GetWidth() == 214,
  "detail refresh restored the clipped native text width"
)

EmptyQuestLogFrame:Hide()
EmptyQuestLogFrame:Show()
assert(
  not QuestLogFrameExpandButton:IsEnabled(),
  "empty quest log did not disable the detail toggle"
)
EmptyQuestLogFrame:Hide()
assert(
  QuestLogFrameExpandButton:IsEnabled(),
  "detail toggle did not recover when the empty state ended"
)

QuestLog_OnShow()
assert(questLogShowCalls == 1, "native QuestLog_OnShow behavior was lost")
assert(
  QuestLogFrame:GetWidth() == 676 and
  QuestLogFrame.aeuiQuestShell:IsShown(),
  "quest shell did not survive the native OnShow path"
)

QuestLogFrameAbandonButton:GetScript("OnClick")()
assert(abandonCalls == 1)
QuestLogTitle1:GetScript("OnClick")()
assert(originalQuestRowClickCalls == 2)

print("quest module smoke test passed")
