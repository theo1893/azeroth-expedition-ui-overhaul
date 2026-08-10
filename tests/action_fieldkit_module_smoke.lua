local root = assert(arg[1], "repository root argument is required")
math.mod = math.mod or math.fmod
table.getn = table.getn or function(value) return #value end
unpack = unpack or table.unpack

local Texture = {}
Texture.__index = Texture
function Texture:SetAllPoints(target) self.allPoints = target end
function Texture:SetPoint(...) table.insert(self.points, { ... }) end
function Texture:SetWidth(value) self.width = value end
function Texture:SetHeight(value) self.height = value end
function Texture:SetTexture(value) self.texture = value end
function Texture:SetTexCoord(...) self.texcoord = { ... } end
function Texture:SetBlendMode(value) self.blendMode = value end
function Texture:SetVertexColor(...) self.vertexColor = { ... } end
function Texture:Show() self.shown = true end
function Texture:Hide() self.shown = false end

local FontString = {}
FontString.__index = FontString
function FontString:SetAllPoints(target) self.allPoints = target end
function FontString:SetJustifyH(value) self.justifyH = value end
function FontString:SetJustifyV(value) self.justifyV = value end
function FontString:SetTextColor(...) self.color = { ... } end
function FontString:SetText(value) self.text = value end

local Frame = {}
Frame.__index = Frame
function Frame:CreateTexture(_, layer)
  local texture = setmetatable({
    parent = self,
    layer = layer,
    points = {},
    shown = true,
  }, Texture)
  table.insert(self.textures, texture)
  return texture
end
function Frame:CreateFontString(_, layer, template)
  local font = setmetatable({
    parent = self,
    layer = layer,
    template = template,
  }, FontString)
  table.insert(self.fonts, font)
  return font
end
function Frame:EnableMouse(value) self.mouseEnabled = value end
function Frame:GetFrameLevel() return self.frameLevel end
function Frame:SetFrameLevel(value) self.frameLevel = value end
function Frame:GetParent() return self.parent end
function Frame:SetParent(value) self.parent = value end
function Frame:GetScript(name) return self.scripts[name] end
function Frame:SetScript(name, callback) self.scripts[name] = callback end
function Frame:ClearAllPoints() self.decorativePoints = {} end
function Frame:SetPoint(...) table.insert(self.decorativePoints, { ... }) end
function Frame:GetNumPoints() return table.getn(self.decorativePoints) end
function Frame:GetPoint(index) return unpack(self.decorativePoints[index]) end
function Frame:SetAllPoints(target) self.allPoints = target end
function Frame:SetWidth(value) self.width = value end
function Frame:SetHeight(value) self.height = value end
function Frame:GetWidth() return self.width end
function Frame:GetHeight() return self.height end
function Frame:GetLeft() return self.left end
function Frame:GetRight() return self.right end
function Frame:GetTop() return self.top end
function Frame:GetBottom() return self.bottom end
function Frame:GetCenter()
  return (self.left + self.right) / 2, (self.top + self.bottom) / 2
end
function Frame:GetEffectiveScale() return self.scale or 1 end
function Frame:GetName() return self.name end
function Frame:IsShown() return self.shown end
function Frame:Show() self.shown = true end
function Frame:Hide() self.shown = false end
function Frame:SetBackdrop(value)
  self.backdrop = value
  self.setBackdropCalls = self.setBackdropCalls + 1
end
function Frame:SetBackdropColor(...) self.backdropColor = { ... } end
function Frame:SetBackdropBorderColor(...) self.borderColor = { ... } end
function Frame:SetHitRectInsets(...) self.hitRect = { ... } end
function Frame:GetHitRectInsets() return unpack(self.hitRect) end

local function NewFrame(name, parent, geometry)
  geometry = geometry or {}
  return setmetatable({
    name = name,
    parent = parent,
    width = geometry.width or 1,
    height = geometry.height or 1,
    left = geometry.left or 0,
    right = geometry.right or (geometry.left or 0) + (geometry.width or 1),
    top = geometry.top or (geometry.bottom or 0) + (geometry.height or 1),
    bottom = geometry.bottom or 0,
    shown = geometry.shown ~= false,
    forceHidden = geometry.forceHidden,
    scale = geometry.scale or 1,
    frameLevel = geometry.frameLevel or 2,
    decorativePoints = geometry.points or {},
    textures = {},
    fonts = {},
    scripts = geometry.scripts or { OnClick = function() end },
    hitRect = geometry.hitRect or { -2, -2, -2, -2 },
    setBackdropCalls = 0,
  }, Frame)
end

function CreateFrame(_, _, parent)
  return NewFrame(nil, parent, { frameLevel = parent:GetFrameLevel() })
end

function getglobal(name) return _G[name] end

local installedHooks = 0
function hooksecurefunc(target, name, callback)
  local owner = target
  if type(target) == "string" then
    callback = name
    name = target
    owner = _G
  end
  local original = assert(owner[name])
  owner[name] = function(...)
    local results = { original(...) }
    callback(...)
    return unpack(results)
  end
  installedHooks = installedHooks + 1
end

function UnitClass() return "Mage", "MAGE" end
function GetScreenWidth() return 1920 end
function GetScreenHeight() return 1080 end
local mouseFocus
function GetMouseFocus() return mouseFocus end

local function Split(value)
  local result = {}
  local iterator = string.gmatch or string.gfind
  for item in iterator(value, "[^|]+") do
    table.insert(result, item)
  end
  return result
end

local recommended = {
  [1] = "HEALPOTIONS|PVP_HEALPOTIONS|ALTERAC_HEAL",
  [2] = "HEALTHSTONE|WHIPPER_ROOT",
  [3] = "RUNES|MANAPOTIONS|PVP_MANAPOTIONS|ALTERAC_MANA|MANASTONE|TEAS",
  [4] = "REJUVENATION_POTIONS|NIGHT_DRAGONS_BREATH|UNGORO_RESTORE",
  [5] = "BANDAGES|ALTERAC_BANDAGES|WARSONG_BANDAGES|ARATHI_BANDAGES",
  [6] = "ANTI_VENOM",
  [7] = "ACTION_POTIONS|PROTECTION_DAMAGE",
  [8] = "SWIFTNESSPOTIONS|ZANZA",
  [9] = "POTION_AGILITY|POTION_STRENGTH|POTION_SPELLPOWER|BUFF_ATTACKPOWER|BUFF_ATTACKSPEED",
  [10] = "POTION_FORTITUDE|POTION_INTELLECT|POTION_WISDOM|POTION_DEFENSE|POTION_TROLL|BUFF_DODGE",
  [11] = "PROTECTION_ARCANE|PROTECTION_FIRE|PROTECTION_FROST|PROTECTION_NATURE|PROTECTION_SHADOW|PROTECTION_SPELLS|PROTECTION_HOLY",
  [12] = "SCROLL_AGILITY|SCROLL_INTELLECT|SCROLL_PROTECTION|SCROLL_SPIRIT|SCROLL_STAMINA|SCROLL_STRENGTH",
  [13] = "FOOD|FOOD_PERCENT|FOOD_CONJURED",
  [14] = "WATER|WATER_PERCENT|WATER_CONJURED|WATER_SPIRIT",
  [15] = "FOOD_STAMINA|FOOD_AGILITY|FOOD_MANAREGEN|FOOD_HPREGEN|FOOD_STRENGTH|FOOD_INTELLIGENCE|FOOD_SPELLPOWER|DRINK_STAMINA|FOOD_WATER",
  [17] = "SHARPENINGSTONES|WEIGHTSTONE|MANA_OIL|WIZARD_OIL",
  [19] = "HEARTHSTONE",
  [20] = "MOUNTS_TROLL|MOUNTS_ORC|MOUNTS_UNDEAD|MOUNTS_TAUREN|MOUNTS_HUMAN|MOUNTS_NIGHTELF|MOUNTS_DWARF|MOUNTS_GNOME|MOUNTS_SPECIAL|MOUNTS_QIRAJI",
  [21] = "EXPLOSIVES",
  [22] = "FISHINGITEMS",
  [23] = "HOURGLASS_SAND|BATTLE_STANDARD|BATTLE_STANDARD_AV",
  [24] = "QUESTUSEITEMS|QUESTSTARTITEMS",
}

AutoBar = {
  currentPlayer = "Mage - TestRealm",
  buttons = {},
  display = {
    rows = 6,
    columns = 4,
    popupToRight = true,
  },
  providerButtonsUpdateCalls = 0,
  providerPopupUpdateCalls = 0,
  providerSetPopupCalls = 0,
  scheduledEvents = {},
}
for index = 1, 24 do
  AutoBar.buttons[index] = Split(recommended[index] or "")
end
AutoBar.buttons[16] = { 13446, 20008 }
AutoBar.buttons[18] = {}
function AutoBar:ButtonsUpdate() self.providerButtonsUpdateCalls = self.providerButtonsUpdateCalls + 1 end
function AutoBar:UpdatePopupButtons(baseButton)
  self.providerPopupUpdateCalls = self.providerPopupUpdateCalls + 1
  if not baseButton then return end
  for index = 1, 12 do
    local button = _G["AutoBarPopupFrame_Button" .. index]
    if button and button.shown then
      button:ClearAllPoints()
      if index == 1 then
        button:SetPoint("LEFT", baseButton, "RIGHT", 3, 0)
      else
        button:SetPoint(
          "LEFT", _G["AutoBarPopupFrame_Button" .. (index - 1)],
          "RIGHT", 3, 0
        )
      end
      button:SetHitRectInsets(-2, -2, -20, -20)
    end
  end
end
function AutoBar:SetPopupButton(button)
  self.providerSetPopupCalls = self.providerSetPopupCalls + 1
  self.providerSetPopupButton = button
  if button.noPopup then
    AutoBarPopupFrame:Hide()
    return
  end
  self:UpdatePopupButtons(button)
  AutoBarPopupFrame:Show()
end
function AutoBar:ScheduleEvent(name, callback, delay, ...)
  self.scheduledEvents[name] = {
    callback = callback,
    delay = delay,
    arguments = { ... },
  }
  return name
end
function AutoBar:CancelScheduledEvent(name)
  self.scheduledEvents[name] = nil
end
function AutoBar:RunScheduledEvent(name)
  local scheduled = self.scheduledEvents[name]
  assert(scheduled)
  self.scheduledEvents[name] = nil
  return scheduled.callback(unpack(scheduled.arguments))
end
function AutoBar:DragStop()
  self.providerDragStopCalls = (self.providerDragStopCalls or 0) + 1
end
local autoBarSetupCalls = 0
function AutoBar_SetupVisual() autoBarSetupCalls = autoBarSetupCalls + 1 end
local autoBarConfigToggleCalls = 0
function AutoBarConfig_Toggle()
  autoBarConfigToggleCalls = autoBarConfigToggleCalls + 1
end

AutoBar_Config = {
  [AutoBar.currentPlayer] = {
    profile = { layout = 2, layoutProfile = "_SHARED1" },
    buttons = { [1] = { "ORIGINAL" } },
    display = {
      rows = 1,
      columns = 24,
      position = { x = 321, y = 654 },
      popupToTop = true,
    },
  },
}
AutoBarProfile = {}
function AutoBarProfile.Initialize() end
function AutoBarProfile:ProfileChanged()
  AutoBar.buttons = AutoBar_Config[AutoBar.currentPlayer].buttons
  AutoBar.display = AutoBar_Config[AutoBar.currentPlayer].display
  AutoBar_SetupVisual()
end

AutoBarFrame = NewFrame("AutoBarFrame", nil, { width = 157, height = 235 })
AutoBarAnchorFrameHandle = NewFrame("AutoBarAnchorFrameHandle", nil, {
  left = 92,
  bottom = 92,
  width = 16,
  height = 16,
  scale = 0.6,
  points = { { "CENTER", nil, "BOTTOMLEFT", 100, 100 } },
})
local function providerPopupOnLeave()
  AutoBarPopupFrame:Hide()
end
AutoBarPopupFrame = NewFrame("AutoBarPopupFrame", nil, {
  width = 153,
  height = 36,
  scripts = { OnLeave = providerPopupOnLeave },
})
local autoBarSnapshots = {}
for index = 1, 24 do
  local column = math.mod(index - 1, 4)
  local row = math.floor((index - 1) / 4)
  local item = NewFrame("AutoBarFrameButton" .. index, AutoBarFrame, {
    left = 100 + column * 39,
    bottom = 100 + row * 39,
    width = 36,
    height = 36,
  })
  item.effectiveButton = index
  _G[item.name] = item
  autoBarSnapshots[item] = {
    parent = item.parent,
    width = item.width,
    height = item.height,
    left = item.left,
    right = item.right,
    top = item.top,
    bottom = item.bottom,
    scripts = item.scripts,
    hitRect = item.hitRect,
  }
end
for index = 1, 12 do
  local item = NewFrame("AutoBarPopupFrame_Button" .. index, AutoBarPopupFrame, {
    left = 300 + (index - 1) * 39,
    bottom = 300,
    width = 36,
    height = 36,
    shown = index <= 4,
  })
  _G[item.name] = item
end

TrinketMenu = {
  providerOrientCalls = 0,
  providerBuildCalls = 0,
}
function TrinketMenu.OrientWindows() TrinketMenu.providerOrientCalls = TrinketMenu.providerOrientCalls + 1 end
function TrinketMenu.BuildMenu() TrinketMenu.providerBuildCalls = TrinketMenu.providerBuildCalls + 1 end
function TrinketMenu.MainFrame_OnMouseUp()
  TrinketMenu.providerMouseUpCalls =
    (TrinketMenu.providerMouseUpCalls or 0) + 1
end
TrinketMenuOptions = { Locked = "OFF", KeepDocked = "ON" }
TrinketMenuPerOptions = { MainOrient = "HORIZONTAL", MenuOrient = "VERTICAL" }
TrinketMenuQueue = { Enabled = { [0] = 1 } }

TrinketMenu_MainFrame = NewFrame("TrinketMenu_MainFrame", nil, { width = 92, height = 52 })
TrinketMenu_MenuFrame = NewFrame("TrinketMenu_MenuFrame", nil, { width = 172, height = 92 })
local nativeBackdrop = { id = "native" }
TrinketMenu_MainFrame.backdrop = nativeBackdrop
TrinketMenu_MenuFrame.backdrop = nativeBackdrop
local trinketSnapshots = {}
for index = 0, 1 do
  local item = NewFrame("TrinketMenu_Trinket" .. index, TrinketMenu_MainFrame, {
    left = 500 + index * 40,
    bottom = 500,
    width = 36,
    height = 36,
  })
  _G[item.name] = item
  local normal = setmetatable({ shown = true, points = {} }, Texture)
  _G[item.name .. "NormalTexture"] = normal
  trinketSnapshots[item] = {
    parent = item.parent,
    width = item.width,
    height = item.height,
    scripts = item.scripts,
    hitRect = item.hitRect,
  }
end
for index = 1, 30 do
  local item = NewFrame("TrinketMenu_Menu" .. index, TrinketMenu_MenuFrame, {
    left = 600 + math.mod(index - 1, 4) * 40,
    bottom = 600 - math.floor((index - 1) / 4) * 40,
    width = 36,
    height = 36,
    shown = index <= 8,
  })
  _G[item.name] = item
  _G[item.name .. "NormalTexture"] =
    setmetatable({ shown = true, points = {} }, Texture)
end
local queueSnapshot = TrinketMenuQueue.Enabled
local optionsSnapshot = TrinketMenuOptions
local perOptionsSnapshot = TrinketMenuPerOptions

UIParent = NewFrame("UIParent", nil, { width = 1920, height = 1080 })
pfUI = { bars = {}, movables = {} }
pfUI.bars[1] = NewFrame("pfActionBarMain", nil, {
  left = 300,
  bottom = 100,
  width = 494,
  height = 43,
  points = { { "BOTTOM", nil, "BOTTOM", 0, 0 } },
})
pfUI.bars[1].SetPoint = function(self, anchor, relative, relativeAnchor, x, y)
  table.insert(self.decorativePoints, {
    anchor, relative, relativeAnchor, x, y,
  })
  if relative == UIParent and anchor == "BOTTOM" and
    relativeAnchor == "BOTTOM"
  then
    self.left = (GetScreenWidth() - self.width) / 2 + (x or 0)
    self.right = self.left + self.width
    self.bottom = y or 0
    self.top = self.bottom + self.height
  end
end
pfUI.bars[6] = NewFrame("pfActionBarTop", nil, {
  left = 300,
  bottom = 143,
  width = 494,
  height = 43,
  points = { { "BOTTOM", nil, "BOTTOM", 0, 43 } },
})
function pfUI.bars:UpdateConfig()
  self[6]:ClearAllPoints()
  self[6]:SetPoint("BOTTOM", UIParent, "BOTTOM", 321, 654)
end
pfUI.movables.pfActionBarMain = pfUI.bars[1]
pfUI.movables.pfActionBarTop = pfUI.bars[6]
pfUI.unlock = NewFrame("pfUnlock", UIParent, { shown = false })
pfUI.unlock:SetScript("OnShow", function()
  for _, frame in pairs(pfUI.movables) do
    frame.drag = frame.drag or NewFrame(frame:GetName() .. "Drag", UIParent)
    frame.drag:Show()
  end
  pfUI.bars:UpdateConfig()
end)
pfUI.unlock:SetScript("OnHide", function()
  for _, frame in pairs(pfUI.movables) do
    assert(frame.drag, frame:GetName() .. " missing unlock drag")
    frame.drag:Hide()
  end
end)
pfUI_config = {
  bars = { bar1 = { spacing = "1" } },
  position = {},
}
AzerothExpeditionUI = {
  media = { root = "Interface\\AddOns\\AzerothExpeditionUI\\Media\\" },
  db = { actionbars = {
    enabled = true,
    autoBarPopupMode = "AUTO",
    fieldKitBound = true,
    consumableDocked = true,
    trinketDocked = true,
  } },
  modules = {},
}
function AzerothExpeditionUI:RegisterModule(name, module) self.modules[name] = module end

dofile(root .. "/addon/AzerothExpeditionUI/Modules/ActionBars.lua")
local module = assert(AzerothExpeditionUI.modules.ActionBars)
module:Initialize()
module:Apply()

assert(module.fieldKitRuntimeContract == "1.8")
assert(module.actionBarStackStatus == "12x2-bound")
assert(pfUI.bars[6].decorativePoints[1][1] == "BOTTOM")
assert(pfUI.bars[6].decorativePoints[1][2] == pfUI.bars[1])
assert(pfUI.bars[6].decorativePoints[1][3] == "TOP")
assert(pfUI.movables.pfActionBarTop == pfUI.bars[6])
pfUI.unlock.shown = true
pfUI.unlock:GetScript("OnShow")()
assert(pfUI.bars[1].drag and pfUI.bars[1].drag.shown == true)
assert(pfUI.bars[6].drag and pfUI.bars[6].drag.shown == false)
assert(pfUI.bars[6].decorativePoints[1][2] == pfUI.bars[1])
local unlockUndocked = module:SetFieldKitDocking(false)
assert(unlockUndocked == true)
assert(pfUI.bars[6].drag.shown == true)
local unlockRedocked = module:SetFieldKitDocking(true)
assert(unlockRedocked == true)
assert(pfUI.bars[6].drag.shown == false)
pfUI.unlock.shown = false
local unlockHideOk, unlockHideError = pcall(
  pfUI.unlock:GetScript("OnHide")
)
assert(unlockHideOk, unlockHideError)
assert(pfUI.movables.pfActionBarTop == pfUI.bars[6])
assert(module.actionBarStackStatus == "12x2-bound")
assert(module.autoBarFieldKitStatus == "available")
assert(module.autoBarMainButtons == 24)
assert(module.autoBarPopupButtons == 4)
assert(module.autoBarPopupConnectors == 3)
assert(module.autoBarPopupLayout == "native")
assert(module.autoBarGrouped == true)
assert(module.consumableDockStatus == "left")
local consumableDockAnchor = AutoBarAnchorFrameHandle.decorativePoints[1]
local projectedHandleCenter =
  pfUI.bars[1].left +
  consumableDockAnchor[4] * AutoBarAnchorFrameHandle.scale
local originalHandleCenter =
  AutoBarAnchorFrameHandle:GetCenter() * AutoBarAnchorFrameHandle.scale
local originalVisualRight = AutoBarFrameButton4:GetRight() + 6
local projectedVisualRight =
  projectedHandleCenter + originalVisualRight - originalHandleCenter
assert(math.abs(
  pfUI.bars[1].left - projectedVisualRight - module.consumableDockGap
) < 0.0001)
assert(AutoBarFrame.aeuiConsumableKitShellV1.shown == true)
assert(AutoBarFrame.aeuiConsumableKitLabelsV1 == nil)
assert(table.getn(AutoBarFrame.aeuiConsumableKitDividersV1) == 2)
assert(AutoBarFrameButton1.aeuiConsumableKitPocketV1.texture ==
  "Interface\\AddOns\\AzerothExpeditionUI\\Media\\ActionBars\\ActionConsumableKitV1")
assert(AutoBarFrameButton1.aeuiConsumableKitPocketV1.parent ==
  AutoBarFrameButton1.aeuiConsumableKitPocketV1Holder)
assert(AutoBarFrameButton1.aeuiConsumableKitPocketV1Holder.parent ==
  AutoBarFrameButton1)
assert(AutoBarFrameButton1.aeuiConsumableKitPocketV1Holder.frameLevel ==
  AutoBarFrameButton1.frameLevel - 1)
assert(math.abs(
  AutoBarFrameButton1.aeuiConsumableKitPocketV1.width /
  AutoBarFrameButton1.aeuiConsumableKitPocketV1.height - 112 / 108
) < 0.0001)

assert(module.trinketFieldKitStatus == "available")
assert(module.trinketMainButtons == 2)
assert(module.trinketMenuButtons == 30)
assert(module.trinketJoinerOrientation == "horizontal")
assert(module.trinketDockStatus == "right")
assert(TrinketMenu_MenuFrame.aeuiTrinketKitShellV1.shown == true)
assert(TrinketMenu_Trinket0NormalTexture.shown == false)
assert(TrinketMenu_Menu1NormalTexture.shown == false)
assert(TrinketMenu_MainFrame.backdrop == nil)
assert(TrinketMenu_MenuFrame.backdrop == nil)
assert(math.abs(
  TrinketMenu_Trinket0.aeuiTrinketKitPocketV1.width /
  TrinketMenu_Trinket0.aeuiTrinketKitPocketV1.height - 110 / 112
) < 0.0001)
assert(TrinketMenu_Trinket0.aeuiTrinketKitPocketV1.parent ==
  TrinketMenu_Trinket0.aeuiTrinketKitPocketV1Holder)
assert(TrinketMenu_Trinket0.aeuiTrinketKitPocketV1Holder.parent ==
  TrinketMenu_Trinket0)
assert(TrinketMenu_Trinket0.aeuiTrinketKitPocketV1Holder.frameLevel ==
  TrinketMenu_Trinket0.frameLevel - 1)

for item, before in pairs(autoBarSnapshots) do
  assert(item.parent == before.parent)
  assert(item.width == before.width and item.height == before.height)
  assert(item.left == before.left and item.right == before.right)
  assert(item.top == before.top and item.bottom == before.bottom)
  assert(item.scripts == before.scripts and item.hitRect == before.hitRect)
end
for item, before in pairs(trinketSnapshots) do
  assert(item.parent == before.parent)
  assert(item.width == before.width and item.height == before.height)
  assert(item.scripts == before.scripts and item.hitRect == before.hitRect)
end
assert(TrinketMenuOptions == optionsSnapshot)
assert(TrinketMenuPerOptions == perOptionsSnapshot)
assert(TrinketMenuQueue.Enabled == queueSnapshot)
assert(installedHooks == 8)

local hookedButtonsUpdate = AutoBar.ButtonsUpdate
local hookedPopupUpdate = AutoBar.UpdatePopupButtons
local hookedOrient = TrinketMenu.OrientWindows
local hookedBuild = TrinketMenu.BuildMenu
local hookedAutoBarDragStop = AutoBar.DragStop
local hookedTrinketMouseUp = TrinketMenu.MainFrame_OnMouseUp
local wrappedSetPopupButton = AutoBar.SetPopupButton
module:Apply()
assert(installedHooks == 8)
assert(AutoBar.ButtonsUpdate == hookedButtonsUpdate)
assert(AutoBar.UpdatePopupButtons == hookedPopupUpdate)
assert(TrinketMenu.OrientWindows == hookedOrient)
assert(TrinketMenu.BuildMenu == hookedBuild)
assert(AutoBar.DragStop == hookedAutoBarDragStop)
assert(TrinketMenu.MainFrame_OnMouseUp == hookedTrinketMouseUp)
assert(AutoBar.SetPopupButton == wrappedSetPopupButton)

AutoBar:ButtonsUpdate()
AutoBar:UpdatePopupButtons(AutoBarFrameButton1)
AutoBar_SetupVisual()
assert(AutoBar.providerButtonsUpdateCalls == 1)
assert(AutoBar.providerPopupUpdateCalls == 1)
assert(autoBarSetupCalls == 1)
assert(module.autoBarPopupLayout == "drawer-1x4")
assert(module.autoBarPopupSide == "left")
assert(module.autoBarPopupHover == "intent-bridge")
assert(module.autoBarPopupConnectors == 1)
assert(AutoBarPopupFrame.aeuiConsumableKitDrawerSpineV1.shown == true)
assert(AutoBarPopupFrame_Button1.decorativePoints[1][1] == "TOPRIGHT")
local hoverBridge = AutoBarPopupFrame.aeuiConsumableKitDrawerHoverBridgeV1
assert(hoverBridge)
assert(hoverBridge.parent == AutoBarPopupFrame)
assert(hoverBridge.mouseEnabled == true)
assert(hoverBridge.shown == true)
assert(hoverBridge.width == 10)
assert(hoverBridge.decorativePoints[1][1] == "TOPRIGHT")
assert(hoverBridge.decorativePoints[1][2] == AutoBarFrame.aeuiConsumableKitShellV1)
assert(hoverBridge.decorativePoints[1][3] == "TOPLEFT")
assert(hoverBridge.decorativePoints[2][1] == "BOTTOMRIGHT")
assert(hoverBridge.decorativePoints[2][3] == "BOTTOMLEFT")
assert(hoverBridge:GetParent() == AutoBarPopupFrame)
local function ProviderAcceptsPopupFocus(focus)
  return focus and (
    focus:GetParent() == AutoBarFrame or
    focus:GetParent() == AutoBarPopupFrame
  )
end
assert(ProviderAcceptsPopupFocus(hoverBridge))
assert(AutoBarPopupFrame:GetScript("OnLeave") ~= providerPopupOnLeave)
AutoBarPopupFrame.shown = true
AutoBarPopupFrame:GetScript("OnLeave")()
assert(AutoBarPopupFrame.shown == true)

local function SetPopupVisible(count)
  for index = 1, 12 do
    _G["AutoBarPopupFrame_Button" .. index].shown = index <= count
  end
  AutoBar:UpdatePopupButtons(AutoBarFrameButton1)
end

SetPopupVisible(1)
assert(module.autoBarPopupLayout == "drawer-1x1")
SetPopupVisible(6)
assert(module.autoBarPopupLayout == "drawer-1x6")
SetPopupVisible(7)
assert(module.autoBarPopupLayout == "drawer-2x4")
SetPopupVisible(12)
assert(module.autoBarPopupLayout == "drawer-2x6")

local popupRight = module:SetAutoBarPopupMode("right")
assert(popupRight == true)
assert(module.autoBarPopupSide == "right")
assert(hoverBridge.width == 10)
assert(hoverBridge.decorativePoints[1][1] == "TOPLEFT")
assert(hoverBridge.decorativePoints[1][3] == "TOPRIGHT")
assert(hoverBridge.decorativePoints[2][1] == "BOTTOMLEFT")
assert(hoverBridge.decorativePoints[2][3] == "BOTTOMRIGHT")
assert(ProviderAcceptsPopupFocus(hoverBridge))

local setPopupCallsBeforeTraverse = AutoBar.providerSetPopupCalls
mouseFocus = AutoBarFrameButton2
AutoBar:SetPopupButton(AutoBarFrameButton2)
assert(AutoBar.providerSetPopupCalls == setPopupCallsBeforeTraverse)
assert(AutoBar.scheduledEvents[module.popupIntentEvent])
assert(AutoBar.scheduledEvents[module.popupIntentEvent].delay == 0.30)
assert(module.autoBarPopupIntentButton == AutoBarFrameButton2)

mouseFocus = AutoBarFrameButton3
AutoBar:SetPopupButton(AutoBarFrameButton3)
assert(AutoBar.providerSetPopupCalls == setPopupCallsBeforeTraverse)
assert(module.autoBarPopupIntentButton == AutoBarFrameButton3)
mouseFocus = hoverBridge
AutoBar:RunScheduledEvent(module.popupIntentEvent)
assert(AutoBar.providerSetPopupCalls == setPopupCallsBeforeTraverse)
assert(AutoBarPopupFrame.shown == true)
assert(AutoBarPopupFrame.aeuiConsumableKitPopupBaseButtonV1 ==
  AutoBarFrameButton1)

mouseFocus = AutoBarFrameButton4
AutoBar:SetPopupButton(AutoBarFrameButton4)
assert(AutoBar.providerSetPopupCalls == setPopupCallsBeforeTraverse)
AutoBar:RunScheduledEvent(module.popupIntentEvent)
assert(AutoBar.providerSetPopupCalls == setPopupCallsBeforeTraverse + 1)
assert(AutoBar.providerSetPopupButton == AutoBarFrameButton4)
assert(AutoBarPopupFrame.aeuiConsumableKitPopupBaseButtonV1 ==
  AutoBarFrameButton4)

local popupNative, popupNativeMessage = module:SetAutoBarPopupMode("native")
assert(popupNative == true)
assert(string.find(popupNativeMessage, "native", 1, true))
assert(module.autoBarPopupLayout == "native")
assert(module.autoBarPopupHover == "provider")
assert(AutoBarPopupFrame_Button1.decorativePoints[1][1] == "LEFT")
assert(hoverBridge.shown == false)
assert(AutoBarPopupFrame:GetScript("OnLeave") == providerPopupOnLeave)
local setPopupCallsBeforeNative = AutoBar.providerSetPopupCalls
mouseFocus = AutoBarFrameButton5
AutoBar:SetPopupButton(AutoBarFrameButton5)
assert(AutoBar.providerSetPopupCalls == setPopupCallsBeforeNative + 1)
assert(AutoBar.scheduledEvents[module.popupIntentEvent] == nil)
local popupAuto = module:SetAutoBarPopupMode("auto")
assert(popupAuto == true)
assert(module.autoBarPopupLayout == "drawer-2x6")
assert(module.autoBarPopupHover == "intent-bridge")
assert(hoverBridge.shown == true)

local providerScheduleEvent = AutoBar.ScheduleEvent
local providerCancelScheduledEvent = AutoBar.CancelScheduledEvent
AutoBar.ScheduleEvent = nil
AutoBar.CancelScheduledEvent = nil
local setPopupCallsBeforeSchedulerFallback = AutoBar.providerSetPopupCalls
mouseFocus = AutoBarFrameButton6
AutoBar:SetPopupButton(AutoBarFrameButton6)
assert(AutoBar.providerSetPopupCalls ==
  setPopupCallsBeforeSchedulerFallback + 1)
assert(module.autoBarPopupHover == "bridge")
AutoBar.ScheduleEvent = providerScheduleEvent
AutoBar.CancelScheduledEvent = providerCancelScheduledEvent
module:ApplyAutoBarPopup(true)
assert(module.autoBarPopupHover == "intent-bridge")

local opened, openMessage = module:OpenAutoBarConfig()
assert(opened == true)
assert(autoBarConfigToggleCalls == 1)
assert(string.find(openMessage, "/aeui autobar apply", 1, true))

local applied, applyMessage = module:ApplyRecommendedAutoBarProfile()
assert(applied == true)
assert(string.find(applyMessage, "4x6", 1, true))
local appliedConfig = AutoBar_Config[AutoBar.currentPlayer]
assert(appliedConfig.profile.useCharacter == true)
assert(appliedConfig.profile.useShared == false)
assert(appliedConfig.profile.useClass == false)
assert(appliedConfig.profile.useBasic == false)
assert(appliedConfig.profile.layout == 1)
assert(appliedConfig.profile.layoutProfile == AutoBar.currentPlayer)
assert(appliedConfig.display.rows == 6)
assert(appliedConfig.display.columns == 4)
assert(appliedConfig.display.gapping == 3)
assert(appliedConfig.display.buttonWidth == 36)
assert(appliedConfig.display.buttonHeight == 36)
assert(appliedConfig.display.alignButtons == 1)
assert(appliedConfig.display.showEmptyButtons == true)
assert(appliedConfig.display.showCategoryIcon == true)
assert(appliedConfig.display.popupToTop == true)
assert(appliedConfig.display.position.x == 321)
assert(appliedConfig.display.position.y == 654)
assert(appliedConfig.buttons[1][1] == "HEALPOTIONS")
assert(appliedConfig.buttons[3][1] == "RUNES")
assert(appliedConfig.buttons[16][1] == 13446)
assert(appliedConfig.buttons[16][2] == 20008)
local savedBackup = AzerothExpeditionUI.db.actionbars.autoBarBackups[
  AutoBar.currentPlayer
]
assert(savedBackup)
assert(savedBackup ~= appliedConfig)
assert(savedBackup.buttons[1][1] == "ORIGINAL")
assert(savedBackup.display.rows == 1)

local restored, restoreMessage = module:RestoreAutoBarProfile()
assert(restored == true)
assert(string.find(restoreMessage, "restored", 1, true))
assert(AutoBar_Config[AutoBar.currentPlayer].buttons[1][1] == "ORIGINAL")
assert(AutoBar_Config[AutoBar.currentPlayer].display.rows == 1)
assert(AzerothExpeditionUI.db.actionbars.autoBarBackups[
  AutoBar.currentPlayer
] == nil)

local undocked, undockMessage = module:SetFieldKitDocking(false)
assert(undocked == true)
assert(string.find(undockMessage, "unbound", 1, true))
assert(AzerothExpeditionUI.db.actionbars.fieldKitBound == false)
assert(AzerothExpeditionUI.db.actionbars.consumableDocked == false)
assert(AzerothExpeditionUI.db.actionbars.trinketDocked == false)
assert(module.actionBarStackStatus == "free")
assert(pfUI.movables.pfActionBarTop == pfUI.bars[6])
assert(module.consumableDockStatus == "free")
assert(module.trinketDockStatus == "free")
local redocked, redockMessage = module:SetFieldKitDocking(true)
assert(redocked == true)
assert(string.find(redockMessage, "consumables left", 1, true))
assert(AzerothExpeditionUI.db.actionbars.fieldKitBound == true)
assert(module.actionBarStackStatus == "12x2-bound")
assert(pfUI.movables.pfActionBarTop == pfUI.bars[6])
assert(module.consumableDockStatus == "left")
assert(module.trinketDockStatus == "right")

local reset, resetMessage = module:ResetCombatDeckPosition()
assert(reset == true)
assert(string.find(resetMessage, "BOTTOM (0, 175)", 1, true))
assert(AzerothExpeditionUI.db.actionbars.combatDeckLayoutVersion == 1)
assert(pfUI_config.position.pfActionBarMain.xpos == 0)
assert(pfUI_config.position.pfActionBarMain.ypos == 175)
assert(pfUI.bars[1].decorativePoints[1][1] == "BOTTOM")
assert(pfUI.bars[1].decorativePoints[1][2] == UIParent)

for index = 1, 24 do
  local button = _G["AutoBarFrameButton" .. index]
  button.left = button.left - 200
  button.right = button.right - 200
end
AutoBar:DragStop()
assert(AzerothExpeditionUI.db.actionbars.fieldKitBound == true)
assert(AzerothExpeditionUI.db.actionbars.consumableDocked == true)
assert(module.consumableDockStatus == "left")
for index = 1, 24 do
  local button = _G["AutoBarFrameButton" .. index]
  button.left = button.left + 200
  button.right = button.right + 200
end
AutoBar:DragStop()
assert(AzerothExpeditionUI.db.actionbars.consumableDocked == true)
assert(module.consumableDockStatus == "left")

TrinketMenu_MainFrame.left = 100
TrinketMenu_MainFrame.right = 192
TrinketMenu_MainFrame.bottom = 100
TrinketMenu_MainFrame.top = 152
arg1 = "LeftButton"
TrinketMenu.MainFrame_OnMouseUp()
assert(AzerothExpeditionUI.db.actionbars.fieldKitBound == true)
assert(AzerothExpeditionUI.db.actionbars.trinketDocked == true)
assert(module.trinketDockStatus == "right")
TrinketMenu_MainFrame.left = 810
TrinketMenu_MainFrame.right = 902
TrinketMenu_MainFrame.bottom = 100
TrinketMenu_MainFrame.top = 152
TrinketMenu.MainFrame_OnMouseUp()
assert(AzerothExpeditionUI.db.actionbars.trinketDocked == true)
assert(module.trinketDockStatus == "right")
assert(TrinketMenuPerOptions.XPos == nil)
assert(TrinketMenuPerOptions.YPos == nil)
arg1 = nil

TrinketMenu_MainFrame.width = 52
TrinketMenu_MainFrame.height = 92
TrinketMenu.OrientWindows()
TrinketMenu.BuildMenu()
assert(TrinketMenu.providerOrientCalls == 1)
assert(TrinketMenu.providerBuildCalls == 1)
assert(module.trinketJoinerOrientation == "vertical")

AutoBar.display.columns = 6
module:ApplyAutoBarFieldKit(true)
assert(module.autoBarGrouped == false)
assert(AutoBarFrame.aeuiConsumableKitLabelsV1 == nil)
assert(module.autoBarPopupLayout == "native")
assert(module.autoBarPopupHover == "provider")
assert(hoverBridge.shown == false)
assert(AutoBarPopupFrame:GetScript("OnLeave") == providerPopupOnLeave)
local setPopupCallsBeforeMismatch = AutoBar.providerSetPopupCalls
mouseFocus = AutoBarFrameButton6
AutoBar:SetPopupButton(AutoBarFrameButton6)
assert(AutoBar.providerSetPopupCalls == setPopupCallsBeforeMismatch + 1)
assert(AutoBar.scheduledEvents[module.popupIntentEvent] == nil)
AutoBar.display.columns = 4

AzerothExpeditionUI.db.actionbars.enabled = false
module:Apply()
assert(module.autoBarFieldKitStatus == "disabled")
assert(AutoBarFrameButton1.aeuiConsumableKitPocketV1.shown == false)
assert(AutoBarFrame.aeuiConsumableKitShellV1.shown == false)
assert(hoverBridge.shown == false)
assert(AutoBarPopupFrame:GetScript("OnLeave") == providerPopupOnLeave)
assert(module.trinketFieldKitStatus == "disabled")
assert(TrinketMenu_Trinket0.aeuiTrinketKitPocketV1.shown == false)
assert(TrinketMenu_Trinket0NormalTexture.shown == true)
assert(TrinketMenu_Menu1NormalTexture.shown == true)
assert(TrinketMenu_MainFrame.backdrop ~= nil)
assert(TrinketMenu_MenuFrame.backdrop ~= nil)
assert(TrinketMenu_MenuFrame.aeuiTrinketKitShellV1.shown == false)

AutoBar = nil
TrinketMenu = nil
AutoBarFrame = nil
AutoBarPopupFrame = nil
TrinketMenu_MainFrame = nil
TrinketMenu_MenuFrame = nil
module:Apply()
assert(module.autoBarFieldKitStatus == "missing")
assert(module.trinketFieldKitStatus == "missing")
local status = module:GetRuntimeStatus()
assert(string.find(status, "fieldkit%-contract=1%.8"))
assert(string.find(status, "fieldkit%-binding=bound"))
assert(string.find(status, "autobar=missing"))
assert(string.find(status, "autobar%-popup%-hover=missing"))
assert(string.find(status, "trinket=missing"))

print("action field kit module smoke test passed")
