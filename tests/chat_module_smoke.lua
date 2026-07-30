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
    scale = 1,
    shown = true,
    points = {},
    scripts = {},
    enabled = true,
    focused = false,
    clearAllPointsCalls = 0,
    setPointCalls = 0,
    setParentCalls = 0,
    setWidthCalls = 0,
    setHeightCalls = 0,
    hitRectCalls = 0,
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
function Object:SetFrameStrata() end
function Object:SetFrameLevel() end
function Object:EnableDrawLayer(value) self.enabledDrawLayer = value end
function Object:SetBlendMode() end
function Object:SetAlpha(value) self.alpha = value end
function Object:SetTexture(value) self.texture = value end
function Object:GetTexture() return self.texture end
function Object:SetVertexColor(...) self.vertexColor = { ... } end
function Object:SetTexCoord(...) self.texcoord = { ... } end
function Object:SetBackdropColor(...) self.backdropColor = { ... } end
function Object:SetBackdropBorderColor(...) self.borderColor = { ... } end
function Object:SetTextColor(...) self.textColor = { ... } end
function Object:SetFont(...) self.font = { ... } end
function Object:SetJustifyH(value) self.justifyH = value end
function Object:SetJustifyV(value) self.justifyV = value end
function Object:SetTextInsets(...) self.textInsets = { ... } end
function Object:SetHitRectInsets(...)
  self.hitRectCalls = self.hitRectCalls + 1
  self.hitRectInsets = { ... }
end
function Object:SetHeight(value)
  self.setHeightCalls = self.setHeightCalls + 1
  self.height = value
end
function Object:SetWidth(value)
  self.setWidthCalls = self.setWidthCalls + 1
  self.width = value
end
function Object:GetHeight() return self.height end
function Object:GetWidth() return self.width end
function Object:SetScale(value) self.scale = value end
function Object:GetScale() return self.scale end
function Object:GetEffectiveScale()
  local parentScale = 1
  if
    type(self.parent) == "table" and
    self.parent.GetEffectiveScale
  then
    parentScale = self.parent:GetEffectiveScale()
  end
  return self.scale * parentScale
end
function Object:GetParent() return self.parent end
function Object:SetParent(parent)
  self.setParentCalls = self.setParentCalls + 1
  self.parent = parent
end
function Object:IsShown() return self.shown end
function Object:IsEnabled() return self.enabled end
function Object:HasFocus() return self.focused end
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
function Object:GetPoint(index)
  local point = self.points[index or 1]
  if point then
    return table.unpack(point)
  end
end
function Object:GetNumPoints() return #self.points end
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

local simulateNativeSelectionLayout = false
function FCF_SelectDockFrame(frame)
  SELECTED_CHAT_FRAME = frame
  if simulateNativeSelectionLayout then
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", pfChatLeft, "TOPLEFT", 5, -25)
    frame:SetPoint(
      "BOTTOMRIGHT",
      pfChatLeft,
      "BOTTOMRIGHT",
      -5,
      25
    )
  end
end

local simulateNativeDockLayout = false
function FCF_DockUpdate()
  if not simulateNativeDockLayout then
    return
  end

  for index = 1, NUM_CHAT_WINDOWS do
    local tab = _G["ChatFrame" .. index .. "Tab"]
    tab:ClearAllPoints()
    tab:SetPoint(
      "LEFT",
      leftChatPanelTop,
      "LEFT",
      (index - 1) * 72,
      0
    )
    tab:SetWidth(72)
    tab:SetHeight(18)
  end
end

local simulateNativeSaveDockLayout = false
function FCF_SaveDock()
  if not simulateNativeSaveDockLayout then
    return
  end

  for index = 1, NUM_CHAT_WINDOWS do
    local frame = _G["ChatFrame" .. index]
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", pfChatLeft, "TOPLEFT", 5, -25)
    frame:SetPoint(
      "BOTTOMRIGHT",
      pfChatLeft,
      "BOTTOMRIGHT",
      -5,
      25
    )
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

local rightChat = CreateFrame("Frame", "pfChatRight", UIParent)
rightChat:SetWidth(380)
rightChat:SetHeight(180)
rightChat.backdrop = NewObject(nil, rightChat)
rightChat.panelTop = CreateFrame("Frame", "rightChatPanelTop", rightChat)

local panel = CreateFrame("Frame", "pfPanelLeft", UIParent)
panel:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 5, 5)
panel.backdrop = NewObject(nil, panel)
panel.left = CreateFrame("Button", nil, panel)
panel.center = CreateFrame("Button", nil, panel)
panel.right = CreateFrame("Button", nil, panel)
for _, segment in ipairs({ panel.left, panel.center, panel.right }) do
  segment.text = NewObject(nil, segment)
end
local rightPanel = CreateFrame("Frame", "pfPanelRight", UIParent)
local minimapPanel = CreateFrame("Frame", "pfPanelMinimap", UIParent)

NUM_CHAT_WINDOWS = 4
for index = 1, NUM_CHAT_WINDOWS do
  local parent = left
  local frame = CreateFrame("ScrollingMessageFrame", "ChatFrame" .. index, parent)
  frame.isDocked = true
  frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 3, -24)
  local tab = CreateFrame("Button", "ChatFrame" .. index .. "Tab", left.panelTop)
  tab.shown = true
  tab:SetPoint("LEFT", left.panelTop, "LEFT", (index - 1) * 80, 0)
  NewObject("ChatFrame" .. index .. "TabText", tab)
  local flash = NewObject("ChatFrame" .. index .. "TabFlash", tab)
  flash:Hide()
end
SELECTED_CHAT_FRAME = ChatFrame1
DOCKED_CHAT_FRAMES = {
  ChatFrame1,
  ChatFrame2,
  ChatFrame3,
  ChatFrame4,
}

local refreshCount = 0
local simulatePfUIRefreshLayout = false
pfUI = {
  font_default = "pfui-font.ttf",
  chat = {
    left = left,
    right = rightChat,
    editbox = input,
    RefreshChat = function()
      refreshCount = refreshCount + 1
      if simulatePfUIRefreshLayout then
        for index = 1, NUM_CHAT_WINDOWS do
          local frame = _G["ChatFrame" .. index]
          local text = _G["ChatFrame" .. index .. "TabText"]
          frame:ClearAllPoints()
          frame:SetPoint("TOPLEFT", left, "TOPLEFT", 5, -25)
          frame:SetPoint(
            "BOTTOMRIGHT",
            left,
            "BOTTOMRIGHT",
            -5,
            25
          )
          text:ClearAllPoints()
          text:SetPoint("BOTTOM", text.parent, "BOTTOM", 0, 1)
          text:SetWidth(32)
          text:SetHeight(14)
          text:SetJustifyH("LEFT")
          text:SetJustifyV("BOTTOM")
        end
      end
    end,
  },
  panel = {
    left = panel,
    right = rightPanel,
    minimap = minimapPanel,
  },
}
left.OnMove = function()
  pfUI.chat:RefreshChat()
end
pfUI_config = {
  chat = {
    right = {
      enable = "1",
    },
  },
  appearance = {
    expedition = {
      enabled = "1",
      vanilla_fallback = "1",
      native_blizzard_skins = "1",
      legacy_info_panels = "0",
    },
  },
}

dofile(root .. "/addon/AzerothExpeditionUI/Core/Bootstrap.lua")
dofile(root .. "/addon/AzerothExpeditionUI/Modules/Chat.lua")

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
  left.aeuiBookSlices.bottom.texcoord[4] == 0.6083984375,
  "book texture coordinate does not match the runtime asset"
)
assert(
  left.aeuiBookSlices.center.texture:find("ChatBookFrameV3"),
  "V3 chat book texture was not mounted"
)
assert(
  left.enabledDrawLayer == "BACKGROUND" and
    left.aeuiBookRuntimeVersion == "1.7",
  "chat book background layer or runtime marker was not restored"
)
left.aeuiBookSlices.center:SetTexture(nil)
left.aeuiBookRuntimeVersion = nil
AzerothExpeditionUI.modules.Chat:Maintain()
assert(
  left.aeuiBookSlices.center.texture:find("ChatBookFrameV3") and
    left.aeuiBookRecoveredAt,
  "chat maintenance did not recover a stripped book texture"
)
assert(#ChatFrame1.points == 2, "docked chat frame was not inset")
assert(#input.points == 2, "pfUI input frame was not integrated")
assert(not rightChat:IsShown(), "right chat container was not suppressed")
assert(
  pfUI_config.chat.right.enable == "0",
  "right chat configuration was not disabled"
)
assert(not panel:IsShown(), "left legacy info panel was not suppressed")
assert(not rightPanel:IsShown(), "right legacy info panel was not suppressed")
assert(not minimapPanel:IsShown(), "minimap legacy info panel was not suppressed")
assert(not panel.left.aeuiPanelTexture, "retired panel art was still created")
assert(#ChatFrame1Tab.points == 1, "pfUI chat tab anchor was not preserved")
assert(ChatFrame1Tab.aeuiStateTexture, "chat tab state texture was not applied")
assert(
  ChatFrame1Tab.aeuiStateTexture.texture:find("ChatTabAtlasV3"),
  "V3 chat tab atlas was not applied"
)
assert(
  ChatFrame1Tab.aeuiVisualState == "selected",
  "selected chat tab state was not applied"
)
assert(
  ChatFrame1TabText.textColor[1] >= 0.95 and
  ChatFrame1TabText.textColor[2] >= 0.80,
  "selected chat tab text does not remain readable"
)
assert(
  #ChatFrame1TabText.points == 1 and
  ChatFrame1TabText.points[1][1] == "CENTER" and
  ChatFrame1TabText.points[1][2] == ChatFrame1Tab and
  ChatFrame1TabText.points[1][3] == "CENTER" and
  ChatFrame1TabText.justifyH == "CENTER" and
  ChatFrame1TabText.justifyV == "MIDDLE",
  "chat tab text was not centered inside the runtime button"
)
assert(
  ChatFrame1TabText:GetWidth() == 80 and
  ChatFrame1TabText:GetHeight() == 18 and
  ChatFrame1TabText.aeuiManaged,
  "chat tab text safe area was not applied"
)
assert(ChatFrame1Tab:GetWidth() == 92, "chat tab width contract changed")
assert(ChatFrame1Tab:GetHeight() == 30, "chat tab height contract changed")
assert(
  ChatFrame1Tab.hitRectInsets[4] == -8,
  "chat tab hit area was not extended over the lower visual body"
)
assert(
  left.panelTop:GetHeight() == 32,
  "compact chat tab panel height was not applied"
)
assert(
  left.aeuiTabShelf:GetHeight() == 16 and
  left.aeuiTabShelf.points[1][5] == -18,
  "compact tab shelf geometry was not applied"
)
assert(
  ChatFrame1.points[1][5] == -32,
  "chat text did not reclaim the space below the compact tabs"
)
assert(
  left.aeuiTabLayoutCount == 4,
  "docked chat tab count was not recorded"
)
assert(
  ChatFrame2Tab.points[1][4] == 95 and
  ChatFrame4Tab.points[1][4] == 285,
  "four docked chat tabs do not use the three-pixel runtime gap"
)
assert(
  ChatFrame1Tab.aeuiStateSlices.left.aeuiManaged,
  "AEUI tab slices were not protected from pfUI region resizing"
)
assert(
  ChatFrameEditBox.aeuiInputState == "normal",
  "chat input did not start in its normal state"
)
assert(refreshCount >= 1, "pfUI chat refresh was not retained")

local chatModule = AzerothExpeditionUI.modules.Chat
assert(
  chatModule.startupLayoutAt,
  "startup tab finalization was not scheduled"
)
for index = 1, NUM_CHAT_WINDOWS do
  local tab = _G["ChatFrame" .. index .. "Tab"]
  tab:ClearAllPoints()
  tab:SetPoint(
    "LEFT",
    leftChatPanelTop,
    "LEFT",
    (index - 1) * 72,
    0
  )
  tab:SetWidth(72)
  tab:SetHeight(18)
end
clock = chatModule.startupLayoutAt + 0.01
chatModule.driver.scripts.OnUpdate()
assert(
  ChatFrame1Tab:GetHeight() == 30 and
  ChatFrame4Tab.points[1][4] == 285,
  "late startup layout was not corrected without a tab click"
)
assert(
  left.aeuiStartupLayoutFinalized and
  chatModule.startupLayoutAt == nil,
  "startup layout finalization did not complete exactly once"
)

SlashCmdList.AZEROTHEXPEDITIONUI("status")
local statusMessage =
  DEFAULT_CHAT_FRAME.messages[#DEFAULT_CHAT_FRAME.messages] or ""
assert(
  string.find(statusMessage, "route=native-first", 1, true),
  "status command did not report the native-first route"
)
assert(
  string.find(statusMessage, "chat-runtime=1.7", 1, true),
  "status command did not report the chat runtime contract"
)
assert(
  string.find(statusMessage, "blizzard-skins=native", 1, true),
  "status command did not report native Blizzard skins"
)

local scaleTabWidthCalls = ChatFrame1Tab.setWidthCalls
local scaleTabHeightCalls = ChatFrame1Tab.setHeightCalls
local scaleTabPointCalls = ChatFrame1Tab.setPointCalls
local scaleTextWidthCalls = ChatFrame1TabText.setWidthCalls
local scaleFramePointCalls = ChatFrame1.setPointCalls
local scaleHitRectCalls = ChatFrame1Tab.hitRectCalls
event = "UI_SCALE_CHANGED"
chatModule.driver.scripts.OnEvent()
event = nil
assert(
  chatModule.startupLayoutForce,
  "UI scale change did not schedule a forced runtime layout"
)
local scaleLayoutAt = chatModule.startupLayoutAt
AzerothExpeditionUI:Refresh()
assert(
  chatModule.startupLayoutForce and
  chatModule.startupLayoutAt == scaleLayoutAt,
  "normal addon refresh discarded the pending scale reflow"
)
assert(
  ChatFrame1Tab.setWidthCalls == scaleTabWidthCalls and
  ChatFrame1Tab.setHeightCalls == scaleTabHeightCalls,
  "normal refresh rewrote clean tab geometry before scale settle"
)
clock = chatModule.startupLayoutAt + 0.01
chatModule.driver.scripts.OnUpdate()
assert(
  ChatFrame1Tab.setWidthCalls > scaleTabWidthCalls and
  ChatFrame1Tab.setHeightCalls > scaleTabHeightCalls and
  ChatFrame1Tab.setPointCalls > scaleTabPointCalls and
  ChatFrame1TabText.setWidthCalls > scaleTextWidthCalls and
  ChatFrame1.setPointCalls > scaleFramePointCalls and
  ChatFrame1Tab.hitRectCalls > scaleHitRectCalls,
  "UI scale settle did not force a one-shot geometry reflow"
)
assert(
  left.aeuiScaleLayoutFinalized and
  not chatModule.startupLayoutForce and
  not chatModule.runtimeLayoutForce,
  "UI scale forced reflow did not finish exactly once"
)

local ownerScaleTabWidthCalls = ChatFrame1Tab.setWidthCalls
local ownerScaleTabHeightCalls = ChatFrame1Tab.setHeightCalls
local ownerScaleTabPointCalls = ChatFrame1Tab.setPointCalls
local ownerScaleFramePointCalls = ChatFrame1.setPointCalls
left:SetScale(1.2)
left:OnMove()
assert(
  left.aeuiObservedScale == 1.2 and
  left.aeuiScaleChangeCount == 1,
  "pfUI owner scale change was not observed through pfChatLeft.OnMove"
)
assert(
  ChatFrame1Tab.setWidthCalls > ownerScaleTabWidthCalls and
  ChatFrame1Tab.setHeightCalls > ownerScaleTabHeightCalls and
  ChatFrame1Tab.setPointCalls > ownerScaleTabPointCalls and
  ChatFrame1.setPointCalls > ownerScaleFramePointCalls,
  "pfUI owner scale change did not force an immediate tab reflow"
)

local moveOnlyTabWidthCalls = ChatFrame1Tab.setWidthCalls
local moveOnlyTabPointCalls = ChatFrame1Tab.setPointCalls
local moveOnlyFramePointCalls = ChatFrame1.setPointCalls
left:OnMove()
assert(
  ChatFrame1Tab.setWidthCalls == moveOnlyTabWidthCalls and
  ChatFrame1Tab.setPointCalls == moveOnlyTabPointCalls and
  ChatFrame1.setPointCalls == moveOnlyFramePointCalls,
  "ordinary pfUI movement forced clean geometry without a scale edge"
)

local effectiveScaleTabWidthCalls = ChatFrame1Tab.setWidthCalls
local effectiveScaleTabPointCalls = ChatFrame1Tab.setPointCalls
UIParent:SetScale(0.8)
chatModule:Maintain()
assert(
  left.aeuiObservedEffectiveScale == 0.96 and
  left.aeuiScaleChangeCount == 2,
  "effective UI scale edge was not observed without UI_SCALE_CHANGED"
)
assert(
  ChatFrame1Tab.setWidthCalls > effectiveScaleTabWidthCalls and
  ChatFrame1Tab.setPointCalls > effectiveScaleTabPointCalls,
  "effective UI scale edge did not force a one-shot tab reflow"
)

local geometryTargets = {
  ChatFrame1,
  ChatFrame1Tab,
  ChatFrame1TabText,
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
  ChatFrame2Tab.aeuiVisualState == "selected",
  "tab selection state did not update synchronously"
)
assert(
  ChatFrame1Tab.aeuiVisualState == "normal",
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

simulateNativeSelectionLayout = true
FCF_SelectDockFrame(ChatFrame3)
simulateNativeSelectionLayout = false
assert(
  ChatFrame3.points[1][4] == 30 and
  ChatFrame3.points[1][5] == -32 and
  ChatFrame3.points[2][4] == -30 and
  ChatFrame3.points[2][5] == 40,
  "tab selection did not restore the chat content safe area"
)

simulatePfUIRefreshLayout = true
pfUI.chat:RefreshChat()
simulatePfUIRefreshLayout = false
assert(
  ChatFrame1.points[1][4] == 30 and
  ChatFrame1.points[1][5] == -32 and
  ChatFrame1.points[2][4] == -30 and
  ChatFrame1.points[2][5] == 40,
  "pfUI RefreshChat overrode the chat content safe area"
)
assert(
  ChatFrame1TabText.points[1][1] == "CENTER" and
  ChatFrame1TabText.justifyH == "CENTER" and
  ChatFrame1TabText.justifyV == "MIDDLE",
  "pfUI RefreshChat overrode the centered tab text"
)

simulateNativeSaveDockLayout = true
FCF_SaveDock()
simulateNativeSaveDockLayout = false
assert(
  ChatFrame1.points[1][4] == 30 and
  ChatFrame1.points[2][4] == -30,
  "FCF_SaveDock overrode the chat content safe area"
)

pfUI.chat.hideLock = true
SELECTED_CHAT_FRAME = ChatFrame1
simulatePfUIRefreshLayout = true
pfUI.chat:RefreshChat()
simulatePfUIRefreshLayout = false
assert(
  chatModule.runtimeLayoutPending and
  ChatFrame1.points[1][4] == 5,
  "pfUI movement did not defer the runtime layout restore"
)
pfUI.chat.hideLock = false
chatModule.driver.scripts.OnUpdate()
assert(
  not chatModule.runtimeLayoutPending and
  ChatFrame1.points[1][4] == 30 and
  ChatFrame1.points[2][4] == -30 and
  ChatFrame1Tab.aeuiVisualState == "selected",
  "runtime layout did not restore once after pfUI movement"
)

ChatFrame2Tab.scripts.OnEnter()
assert(
  ChatFrame2Tab.aeuiVisualState == "hover",
  "chat tab hover state was not applied immediately"
)
ChatFrame2Tab.scripts.OnLeave()
assert(
  ChatFrame2Tab.aeuiVisualState == "normal",
  "chat tab hover state was not cleared immediately"
)

ChatFrame2Tab.enabled = false
AzerothExpeditionUI.modules.Chat:Maintain()
assert(
  ChatFrame2Tab.aeuiVisualState == "disabled",
  "disabled chat tab state was not applied"
)
ChatFrame2Tab.enabled = true

simulateNativeDockLayout = true
FCF_DockUpdate()
simulateNativeDockLayout = false
assert(
  ChatFrame1Tab:GetWidth() == 92 and
  ChatFrame4Tab:GetWidth() == 92,
  "native dock refresh overrode the AEUI tab width"
)
assert(
  ChatFrame1Tab:GetHeight() == 30 and
  ChatFrame4Tab:GetHeight() == 30,
  "native dock refresh overrode the AEUI tab height"
)
assert(
  ChatFrame1Tab.points[1][5] == -2 and
  ChatFrame4Tab.points[1][4] == 285,
  "AEUI tab geometry was not restored synchronously after docking"
)

ChatFrame2TabFlash:Show()
AzerothExpeditionUI.modules.Chat:Maintain()
assert(
  ChatFrame2Tab.aeuiUnreadSeal:IsShown(),
  "unread seal did not follow the native tab flash semantic"
)
ChatFrame2TabFlash:Hide()

ChatFrameEditBox.focused = true
ChatFrameEditBox.scripts.OnEditFocusGained()
assert(
  ChatFrameEditBox.aeuiInputState == "focus",
  "focused chat input atlas state was not applied"
)
ChatFrameEditBox.focused = false
ChatFrameEditBox.scripts.OnEditFocusLost()
assert(
  ChatFrameEditBox.aeuiInputState == "normal",
  "chat input did not return to its normal atlas state"
)

local healthyProbeCalls = 0
AzerothExpeditionUI:RegisterModule("FailureProbe", {
  Apply = function()
    error("intentional module isolation probe")
  end,
})
AzerothExpeditionUI:RegisterModule("HealthyProbe", {
  Apply = function()
    healthyProbeCalls = healthyProbeCalls + 1
  end,
})
AzerothExpeditionUI:Refresh()
assert(
  healthyProbeCalls == 1 and
    AzerothExpeditionUI.moduleFailures["FailureProbe:Apply"],
  "one failed module prevented an unrelated module refresh"
)
AzerothExpeditionUI.modules.FailureProbe = nil
AzerothExpeditionUI.modules.HealthyProbe = nil

print("chat module smoke test passed")
