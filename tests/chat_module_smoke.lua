local root = assert(arg[1], "repository root argument is required")

table.getn = table.getn or function(value)
  return #value
end
math.mod = math.mod or function(left, right)
  return left % right
end

local clock = 10
function GetTime()
  clock = clock + 0.1
  return clock
end

local Object = {}
Object.__index = Object

local function NewObject(name, parent)
  local value = setmetatable({
    name = name,
    parent = parent,
    width = 0,
    height = 0,
    shown = true,
    points = {},
    scripts = {},
    clearAllPointsCalls = 0,
    setPointCalls = 0,
    setParentCalls = 0,
  }, Object)
  if name then
    _G[name] = value
  end
  return value
end

function Object:RegisterEvent() end
function Object:SetFrameStrata() end
function Object:SetFrameLevel() end
function Object:SetBlendMode() end
function Object:SetAlpha(value) self.alpha = value end
function Object:SetTexture(value) self.texture = value end
function Object:SetVertexColor(...) self.vertexColor = { ... } end
function Object:SetTexCoord(...) self.texcoord = { ... } end
function Object:SetBackdropColor(...) self.backdropColor = { ... } end
function Object:SetBackdropBorderColor(...) self.borderColor = { ... } end
function Object:SetTextColor(...) self.textColor = { ... } end
function Object:SetFont(...) self.font = { ... } end
function Object:SetJustifyH(value) self.justifyH = value end
function Object:SetTextInsets(...) self.textInsets = { ... } end
function Object:SetHeight(value) self.height = value end
function Object:SetWidth(value) self.width = value end
function Object:GetHeight() return self.height end
function Object:GetWidth() return self.width end
function Object:GetParent() return self.parent end
function Object:SetParent(parent)
  self.setParentCalls = self.setParentCalls + 1
  self.parent = parent
end
function Object:IsShown() return self.shown end
function Object:Show() self.shown = true end
function Object:Hide() self.shown = false end
function Object:ClearAllPoints()
  self.clearAllPointsCalls = self.clearAllPointsCalls + 1
  self.points = {}
end
function Object:SetPoint(...)
  self.setPointCalls = self.setPointCalls + 1
  table.insert(self.points, { ... })
end
function Object:SetAllPoints(target) self.allPoints = target end
function Object:SetScript(kind, callback) self.scripts[kind] = callback end
function Object:GetScript(kind) return self.scripts[kind] end
function Object:GetStringWidth() return self.stringWidth or 32 end
function Object:SetNormalTexture(value) self.normalTexture = value end
function Object:SetHighlightTexture(value) self.highlightTexture = value end
function Object:GetRegions() return table.unpack(self.regions or {}) end
function Object:CreateTexture(name)
  return NewObject(name, self)
end

function CreateFrame(_, name, parent)
  return NewObject(name, parent)
end

function getglobal(name)
  return _G[name]
end

function hooksecurefunc(name, callback)
  local original = _G[name]
  _G[name] = function(...)
    local result = original(...)
    callback(...)
    return result
  end
end

function FCF_SelectDockFrame(frame)
  SELECTED_CHAT_FRAME = frame
end

function FCF_DockUpdate() end

UIParent = NewObject("UIParent", nil)
DEFAULT_CHAT_FRAME = {
  messages = {},
  AddMessage = function(self, message)
    table.insert(self.messages, message)
  end,
}
SlashCmdList = {}
function ReloadUI() end

local left = CreateFrame("Frame", "pfChatLeft", UIParent)
left:SetWidth(380)
left:SetHeight(275)
left.backdrop = NewObject(nil, left)
left.panelTop = CreateFrame("Frame", "leftChatPanelTop", left)
left.panelTop.backdrop = NewObject(nil, left.panelTop)

local input = CreateFrame("Frame", "pfChatInputBox", UIParent)
input:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 5, 5)
ChatFrameEditBox = CreateFrame("EditBox", "ChatFrameEditBox", input)
ChatFrameEditBox.backdrop = NewObject(nil, ChatFrameEditBox)

local panel = CreateFrame("Frame", "pfPanelLeft", UIParent)
panel:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 5, 5)
panel.backdrop = NewObject(nil, panel)
panel.left = CreateFrame("Button", nil, panel)
panel.center = CreateFrame("Button", nil, panel)
panel.right = CreateFrame("Button", nil, panel)
for _, segment in ipairs({ panel.left, panel.center, panel.right }) do
  segment.text = NewObject(nil, segment)
end

NUM_CHAT_WINDOWS = 4
for index = 1, NUM_CHAT_WINDOWS do
  local parent = index <= 2 and left or UIParent
  local frame = CreateFrame("ScrollingMessageFrame", "ChatFrame" .. index, parent)
  frame.isDocked = index <= 2
  frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 3, -24)
  local tab = CreateFrame("Button", "ChatFrame" .. index .. "Tab", left.panelTop)
  tab.shown = index <= 2
  tab:SetPoint("LEFT", left.panelTop, "LEFT", (index - 1) * 80, 0)
  NewObject("ChatFrame" .. index .. "TabText", tab)
end
SELECTED_CHAT_FRAME = ChatFrame1

local refreshCount = 0
pfUI = {
  font_default = "pfui-font.ttf",
  chat = {
    left = left,
    editbox = input,
    RefreshChat = function()
      refreshCount = refreshCount + 1
    end,
  },
  panel = {
    left = panel,
  },
}

dofile(root .. "\\addon\\AzerothExpeditionUI\\Core\\Bootstrap.lua")
dofile(root .. "\\addon\\AzerothExpeditionUI\\Modules\\Chat.lua")

AzerothExpeditionUI:Initialize()
AzerothExpeditionUI:Refresh()

assert(left:GetWidth() == 440, "chat minimum width was not applied")
assert(left:GetHeight() == 320, "chat minimum height was not applied")
assert(left.aeuiBookSlices, "book nine-slice textures were not created")
for _, key in ipairs({
  "center",
  "top",
  "bottom",
  "left",
  "right",
  "topLeft",
  "topRight",
  "bottomLeft",
  "bottomRight",
}) do
  assert(left.aeuiBookSlices[key], "missing book slice: " .. key)
end
assert(
  left.aeuiBookSlices.bottom.texcoord[4] == 0.572265625,
  "book texture coordinate does not match the runtime asset"
)
assert(#ChatFrame1.points == 2, "docked chat frame was not inset")
assert(#input.points == 2, "pfUI input frame was not integrated")
assert(panel:GetWidth() == 348, "pfUI panel was not fitted to the book")
assert(panel.left.aeuiPanelTexture, "pfUI panel segment was not skinned")
assert(#ChatFrame1Tab.points == 1, "pfUI chat tab anchor was not preserved")
assert(ChatFrame1Tab.aeuiStateTexture, "chat tab state texture was not applied")
assert(
  ChatFrame1Tab.aeuiStateTexture.texture:find("ChatTabSelected"),
  "selected chat tab texture was not applied"
)
assert(refreshCount >= 1, "pfUI chat refresh was not retained")

local geometryTargets = {
  ChatFrame1,
  ChatFrame1Tab,
  input,
  panel,
}
local geometrySnapshot = {}
for _, target in ipairs(geometryTargets) do
  geometrySnapshot[target] = {
    clearAllPointsCalls = target.clearAllPointsCalls,
    setPointCalls = target.setPointCalls,
    setParentCalls = target.setParentCalls,
  }
end

FCF_SelectDockFrame(ChatFrame2)
assert(
  ChatFrame2Tab.aeuiStateTexture.texture:find("ChatTabSelected"),
  "tab selection state did not update synchronously"
)
assert(
  ChatFrame1Tab.aeuiStateTexture.texture:find("ChatTabNormal"),
  "previous tab did not return to its normal state"
)

for _, target in ipairs(geometryTargets) do
  local snapshot = geometrySnapshot[target]
  assert(
    target.clearAllPointsCalls == snapshot.clearAllPointsCalls,
    target.name .. " geometry was cleared during visual maintenance"
  )
  assert(
    target.setPointCalls == snapshot.setPointCalls,
    target.name .. " anchor changed during visual maintenance"
  )
  assert(
    target.setParentCalls == snapshot.setParentCalls,
    target.name .. " parent changed during visual maintenance"
  )
end

pfUI.chat.hideLock = true
SELECTED_CHAT_FRAME = ChatFrame1
AzerothExpeditionUI.modules.Chat:Maintain()
assert(
  ChatFrame2Tab.aeuiStateTexture.texture:find("ChatTabSelected"),
  "visual maintenance ran while pfUI was moving a chat frame"
)
pfUI.chat.hideLock = false
AzerothExpeditionUI.modules.Chat:Maintain()
assert(
  ChatFrame1Tab.aeuiStateTexture.texture:find("ChatTabSelected"),
  "visual maintenance did not resume after pfUI movement"
)

ChatFrame2Tab.scripts.OnEnter()
assert(
  ChatFrame2Tab.aeuiStateTexture.texture:find("ChatTabHover"),
  "chat tab hover state was not applied immediately"
)
ChatFrame2Tab.scripts.OnLeave()
assert(
  ChatFrame2Tab.aeuiStateTexture.texture:find("ChatTabNormal"),
  "chat tab hover state was not cleared immediately"
)

print("chat module smoke test passed")
