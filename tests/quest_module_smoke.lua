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
function Object:GetObjectType() return self.objectType end
function Object:IsObjectType(value) return self.objectType == value end
function Object:SetTexture(value) self.texture = value end
function Object:SetTexCoord(...) self.texcoord = { ... } end
function Object:SetVertexColor(...) self.vertexColor = { ... } end
function Object:SetBackdropColor(...) self.backdropColor = { ... } end
function Object:SetBackdropBorderColor(...) self.borderColor = { ... } end
function Object:SetAlpha(value) self.alpha = value end
function Object:SetText(value) self.text = value end
function Object:GetText() return self.text end
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
function Object:Enable() self.enabled = true end
function Object:Disable() self.enabled = false end
function Object:IsEnabled() return self.enabled end
function Object:GetRegions() return table.unpack(self.regions) end
function Object:CreateTexture(name, layer)
  local texture = NewObject(name, self, "Texture")
  texture.layer = layer
  table.insert(self.regions, texture)
  return texture
end

function CreateFrame(objectType, name, parent, template)
  local frame = NewObject(name, parent, objectType)
  frame.template = template
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
end

QuestLogFrame = CreateFrame("Frame", "QuestLogFrame", UIParent)
QuestLogFrame:SetWidth(512)
QuestLogFrame:SetHeight(440)
local nativeFrameTexture =
  QuestLogFrame:CreateTexture("QuestLogNativeTexture", "BACKGROUND")

QuestLogTitleText =
  NewObject("QuestLogTitleText", QuestLogFrame, "FontString")
QuestLogTitleText:SetText("任务日志")
QuestLogQuestCount =
  NewObject("QuestLogQuestCount", QuestLogFrame, "FontString")
QuestLogQuestCount:SetText("12/20")
QuestLogFrameCloseButton =
  CreateFrame("Button", "QuestLogFrameCloseButton", QuestLogFrame)

QuestLogListScrollFrame =
  CreateFrame("ScrollFrame", "QuestLogListScrollFrame", QuestLogFrame)
local nativeListTexture =
  QuestLogListScrollFrame:CreateTexture(
    "QuestLogNativeListTexture",
    "BACKGROUND"
  )

QuestLogDetailScrollFrame =
  CreateFrame("ScrollFrame", "QuestLogDetailScrollFrame", QuestLogFrame)
local nativeDetailTexture =
  QuestLogDetailScrollFrame:CreateTexture(
    "QuestLogNativeDetailTexture",
    "BACKGROUND"
  )
QuestLogDetailScrollChildFrame =
  CreateFrame(
    "Frame",
    "QuestLogDetailScrollChildFrame",
    QuestLogDetailScrollFrame
  )
QuestLogDetailScrollChildFrame:SetHeight(120)

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

QuestLogFrameAbandonButton =
  CreateFrame("Button", "QuestLogFrameAbandonButton", QuestLogFrame)
QuestLogFrameAbandonButton:SetHeight(20)
QuestFramePushQuestButton =
  CreateFrame("Button", "QuestFramePushQuestButton", QuestLogFrame)
QuestFramePushQuestButton:SetHeight(20)
QuestFrameExitButton =
  CreateFrame("Button", "QuestFrameExitButton", QuestLogFrame)
QuestFrameExitButton:SetHeight(20)

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
  QuestLogFrame.aeuiQuestRuntimeContract == "1.0",
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
assert(QuestLogDetailScrollChildFrame:GetWidth() == 246)
assert(QuestLogDetailScrollChildFrame:GetHeight() == 324)
assert(
  QuestLogFrameAbandonButton:GetScript("OnClick") == abandonScript,
  "quest action behavior was replaced by the visual adapter"
)
assert(AzerothExpeditionUIDB.sentinel == "preserve")

assert(QuestLogFrameExpandButton, "real detail toggle Button was not created")
assert(
  QuestLogFrameExpandButton.template == "UIPanelButtonTemplate",
  "detail toggle did not use a real Button template"
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

print("quest module smoke test passed")
