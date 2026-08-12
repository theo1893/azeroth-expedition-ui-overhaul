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
function GetLocale() return "zhCN" end
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

AutoBar_Category_Info = {
  POTION_SPELLPOWER = {},
  TEAS = {},
  ZANZA = {},
  DRINK_STAMINA = {},
  FOOD_SPELLPOWER = {},
  QUESTSTARTITEMS = {},
  QUESTUSEITEMS = {},
  FUTURE_PROVIDER_CATEGORY = {},
  NATIVE_DESCRIPTION = { description = "Provider description" },
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
local providerSetupReanchors = false
function AutoBar_SetupVisual()
  autoBarSetupCalls = autoBarSetupCalls + 1
  if AutoBarAnchorFrameHandle then
    -- AutoBar 1.31 can expose the real XML handle during SetupVisual even
    -- though the compact AEUI profile requests hideDragHandle.
    AutoBarAnchorFrameHandle:Show()
  end
  if providerSetupReanchors then
    AutoBar:ButtonsUpdate()
    AutoBarAnchorFrameHandle:ClearAllPoints()
    AutoBarAnchorFrameHandle:SetPoint(
      "CENTER", UIParent, "BOTTOMLEFT", 321, 654
    )
  end
end
local autoBarConfigOnShowCalls = 0
local providerConfigOnShowReanchors = false
AutoBarConfig = {}
local function NewAutoBarConfigFrame(name, points)
  local frame = NewFrame(name, nil, { points = points or {} })
  _G[name] = frame
  return frame
end

AutoBarConfigFrame = NewAutoBarConfigFrame("AutoBarConfigFrame")
for index = 1, 5 do
  local relative = index == 1 and AutoBarConfigFrame or
    _G["AutoBarConfigFrameTab" .. (index - 1)]
  NewAutoBarConfigFrame("AutoBarConfigFrameTab" .. index, {
    { "TOPLEFT", relative, index == 1 and "BOTTOMLEFT" or "TOPRIGHT",
      index == 1 and 150 or 0, index == 1 and 9 or 0 },
  })
end
AutoBarConfigFrameResetDisplay =
  NewAutoBarConfigFrame("AutoBarConfigFrameResetDisplay")
AutoBarConfigFrameRevertButton =
  NewAutoBarConfigFrame("AutoBarConfigFrameRevertButton")
AutoBarConfigFrameSlotsView =
  NewAutoBarConfigFrame("AutoBarConfigFrameSlotsView")
AutoBarConfigFrameSlots = NewAutoBarConfigFrame(
  "AutoBarConfigFrameSlots",
  {
    { "BOTTOMLEFT", AutoBarConfigFrame, "BOTTOMLEFT", 10, 45 },
    { "BOTTOMRIGHT", AutoBarConfigFrame, "BOTTOMRIGHT", -10, 45 },
  }
)
for index = 1, 4 do
  NewAutoBarConfigFrame("AutoBarConfigFrameSlotsEdit" .. index)
end
AutoBarConfigFrameLayout1 =
  NewAutoBarConfigFrame("AutoBarConfigFrameLayout1")
AutoBarConfigFrameLayout2 =
  NewAutoBarConfigFrame("AutoBarConfigFrameLayout2")
for _, name in pairs({ "Bar", "Buttons", "Popup", "Profile" }) do
  NewAutoBarConfigFrame("AutoBarConfigFrame" .. name)
end

function AutoBarConfig:TabButtonOnClick(tabId)
  AutoBar_Config[AutoBar.currentPlayer].display.selectedTab = tabId
  local panels = { "Slots", "Bar", "Buttons", "Popup", "Profile" }
  for index, name in pairs(panels) do
    local frame = _G["AutoBarConfigFrame" .. name]
    if index == tabId then frame:Show() else frame:Hide() end
  end
  if tabId == 1 or tabId == 5 then
    AutoBarConfigFrameSlotsView:Show()
  else
    AutoBarConfigFrameSlotsView:Hide()
  end
  if tabId == 1 then
    AutoBarConfigFrameLayout1:Hide()
    AutoBarConfigFrameLayout2:Hide()
  else
    AutoBarConfigFrameLayout1:Show()
    AutoBarConfigFrameLayout2:Show()
  end
end

function AutoBarConfig.OnShow()
  autoBarConfigOnShowCalls = autoBarConfigOnShowCalls + 1
  for index = 1, 5 do
    _G["AutoBarConfigFrameTab" .. index]:Show()
  end
  AutoBarConfigFrameResetDisplay:Show()
  AutoBarConfigFrameRevertButton:Show()
  for index = 1, 4 do
    _G["AutoBarConfigFrameSlotsEdit" .. index]:Show()
  end
  AutoBarConfig:TabButtonOnClick(
    AutoBar_Config[AutoBar.currentPlayer].display.selectedTab or 1
  )
  AutoBar_SetupVisual()
  if providerConfigOnShowReanchors then
    AutoBarAnchorFrameHandle:ClearAllPoints()
    AutoBarAnchorFrameHandle:SetPoint(
      "CENTER", UIParent, "BOTTOMLEFT", 555, 213
    )
  end
end
local autoBarConfigToggleCalls = 0
function AutoBarConfig_Toggle()
  autoBarConfigToggleCalls = autoBarConfigToggleCalls + 1
  AutoBarConfig.OnShow()
end

local providerClassButtons = {}
for index = 1, 24 do
  providerClassButtons[index] = {}
end
providerClassButtons[1] = { "CLASS_DEFAULT" }

AutoBar_Config = {
  [AutoBar.currentPlayer] = {
    profile = {
      useCharacter = true,
      useShared = false,
      useClass = false,
      useBasic = false,
      layout = 2,
      layoutProfile = "_SHARED1",
      edit = 1,
      editing = AutoBar.currentPlayer,
      shared = "_SHARED1",
    },
    buttons = { [1] = { "ORIGINAL" } },
    display = {
      rows = 6,
      columns = 4,
      gapping = 9,
      position = { x = 321, y = 654 },
      popupToTop = true,
      selectedTab = 2,
    },
  },
  ["_MAGE"] = {
    profile = {},
    buttons = providerClassButtons,
    display = {},
  },
}
AutoBarProfile = { CLASSPROFILE = "_MAGE" }
function AutoBarProfile.Initialize() end
function AutoBarProfile:ProfileChanged()
  local current = AutoBar_Config[AutoBar.currentPlayer]
  if current.profile.useClass then
    AutoBar.buttons = AutoBar_Config[self.CLASSPROFILE].buttons
  else
    AutoBar.buttons = current.buttons
  end
  AutoBar.display = current.display
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
    left = 60 + column * 39,
    bottom = 60 + row * 39,
    width = 36,
    height = 36,
    points = {
      {
        "BOTTOMLEFT", AutoBarAnchorFrameHandle, "CENTER",
        column * 39, row * 39,
      },
    },
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

assert(module.fieldKitRuntimeContract == "2.6")
assert(module.autoBarCategoryDescriptionStatus == "repaired")
assert(module.autoBarCategoryDescriptionsRepaired == 8)
assert(AutoBar_Category_Info.POTION_SPELLPOWER.description ==
  "法术强度药剂")
assert(AutoBar_Category_Info.TEAS.description == "茶")
assert(AutoBar_Category_Info.ZANZA.description == "赞扎药剂")
assert(AutoBar_Category_Info.DRINK_STAMINA.description ==
  "饮料：耐力加成")
assert(AutoBar_Category_Info.FOOD_SPELLPOWER.description ==
  "食物：法术强度加成")
assert(AutoBar_Category_Info.QUESTSTARTITEMS.description ==
  "任务起始物品")
assert(AutoBar_Category_Info.QUESTUSEITEMS.description ==
  "任务使用物品")
assert(AutoBar_Category_Info.FUTURE_PROVIDER_CATEGORY.description ==
  "FUTURE_PROVIDER_CATEGORY")
assert(AutoBar_Category_Info.NATIVE_DESCRIPTION.description ==
  "Provider description")
for _, info in pairs(AutoBar_Category_Info) do
  local tooltip = "category: " .. info.description
  assert(type(tooltip) == "string")
end
local initialConfig = AutoBar_Config[AutoBar.currentPlayer]
local initialClassConfig = AutoBar_Config[AutoBarProfile.CLASSPROFILE]
assert(initialConfig.display.rows == 6)
assert(initialConfig.display.gapping == 9)
assert(initialConfig.display.selectedTab == 1)
assert(initialConfig.profile.useCharacter == false)
assert(initialConfig.profile.useShared == false)
assert(initialConfig.profile.useClass == true)
assert(initialConfig.profile.useBasic == false)
assert(initialConfig.profile.edit == 3)
assert(initialConfig.profile.editing == AutoBarProfile.CLASSPROFILE)
assert(initialConfig.buttons[1][1] == "ORIGINAL")
assert(initialClassConfig.buttons[1][1] == "HEALPOTIONS")
assert(initialClassConfig.buttons[16][1] == 13446)
assert(initialClassConfig.buttons[16][2] == 20008)
assert(module.autoBarClassScopeStatus == "class-only")
assert(module.autoBarConfigCurationStatus == "class-only")
assert(AutoBarConfigFrameTab1.shown == true)
assert(AutoBarConfigFrameTab2.shown == false)
assert(AutoBarConfigFrameTab3.shown == true)
assert(AutoBarConfigFrameTab4.shown == false)
assert(AutoBarConfigFrameTab5.shown == false)
assert(AutoBarConfigFrameResetDisplay.shown == false)
assert(AutoBarConfigFrameRevertButton.shown == false)
assert(AutoBarConfigFrameSlotsView.shown == false)
for index = 1, 4 do
  assert(_G["AutoBarConfigFrameSlotsEdit" .. index].shown == false)
end
assert(AutoBarConfigFrameLayout1.shown == false)
assert(AutoBarConfigFrameLayout2.shown == false)
assert(AutoBarConfigFrameTab3.decorativePoints[1][2] ==
  AutoBarConfigFrameTab1)
assert(AutoBarConfigFrameSlots.decorativePoints[1][1] == "TOPLEFT")
assert(AutoBarConfigFrameSlots.decorativePoints[2][1] == "TOPRIGHT")
assert(AzerothExpeditionUI.db.actionbars.autoBarClassScopePlayerVersions[
  AutoBar.currentPlayer
] == 1)
assert(AzerothExpeditionUI.db.actionbars.autoBarClassScopeClassVersions[
  AutoBarProfile.CLASSPROFILE
] == 1)
assert(AzerothExpeditionUI.db.actionbars.autoBarDefaultModeVersions == nil)
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
assert(AutoBarAnchorFrameHandle.shown == false)
assert(module.autoBarDragHandleStatus == "hidden-bound")
assert(string.find(
  module:GetRuntimeStatus(), "autobar%-drag%-handle=hidden%-bound"
))
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
local autoBarButtonScale = AutoBarFrameButton4:GetEffectiveScale()
local originalVisualRight =
  (AutoBarFrameButton4:GetRight() + 6) * autoBarButtonScale
local projectedVisualRight =
  projectedHandleCenter + originalVisualRight - originalHandleCenter
assert(math.abs(
  pfUI.bars[1].left - projectedVisualRight -
  module.consumableDockGap * autoBarButtonScale
) < 0.0001)
local projectedHandleCenterY =
  pfUI.bars[1].bottom +
  consumableDockAnchor[5] * AutoBarAnchorFrameHandle.scale
local _, originalHandleCenterY = AutoBarAnchorFrameHandle:GetCenter()
local originalVisualBottom =
  (AutoBarFrameButton1:GetBottom() - 6) * autoBarButtonScale
local projectedVisualBottom =
  projectedHandleCenterY + originalVisualBottom -
  originalHandleCenterY * AutoBarAnchorFrameHandle.scale
assert(math.abs(
  projectedVisualBottom -
  (pfUI.bars[1].bottom +
    module.fieldKitDockYOffset * autoBarButtonScale)
) < 0.0001)
assert(module.autoBarAnchorBasis == "provider-local")
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
assert(TrinketMenu_MainFrame.decorativePoints[1][5] ==
  module.fieldKitDockYOffset)
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
assert(installedHooks == 10)

local hookedButtonsUpdate = AutoBar.ButtonsUpdate
local hookedPopupUpdate = AutoBar.UpdatePopupButtons
local hookedOrient = TrinketMenu.OrientWindows
local hookedBuild = TrinketMenu.BuildMenu
local hookedAutoBarDragStop = AutoBar.DragStop
local hookedAutoBarConfigOnShow = AutoBarConfig.OnShow
local hookedAutoBarConfigTab = AutoBarConfig.TabButtonOnClick
local hookedTrinketMouseUp = TrinketMenu.MainFrame_OnMouseUp
local wrappedSetPopupButton = AutoBar.SetPopupButton
module:Apply()
assert(installedHooks == 10)
assert(AutoBar.ButtonsUpdate == hookedButtonsUpdate)
assert(AutoBar.UpdatePopupButtons == hookedPopupUpdate)
assert(TrinketMenu.OrientWindows == hookedOrient)
assert(TrinketMenu.BuildMenu == hookedBuild)
assert(AutoBar.DragStop == hookedAutoBarDragStop)
assert(AutoBarConfig.OnShow == hookedAutoBarConfigOnShow)
assert(AutoBarConfig.TabButtonOnClick == hookedAutoBarConfigTab)
assert(TrinketMenu.MainFrame_OnMouseUp == hookedTrinketMouseUp)
assert(AutoBar.SetPopupButton == wrappedSetPopupButton)
autoBarSetupCalls = 0

AutoBar:ButtonsUpdate()
assert(AutoBar.providerButtonsUpdateCalls == 1)
assert(AutoBar.scheduledEvents[module.autoBarRefreshEvent])
assert(AutoBar.scheduledEvents[module.autoBarRefreshEvent].delay == 0)
assert(module.autoBarRefreshStatus == "queued")
AutoBar:RunScheduledEvent(module.autoBarRefreshEvent)
assert(module.autoBarRefreshStatus == "settled")

AutoBar:UpdatePopupButtons(AutoBarFrameButton1)
AutoBar_SetupVisual()
assert(AutoBarAnchorFrameHandle.shown == false)
assert(module.autoBarDragHandleStatus == "hidden-bound")
assert(AutoBar.providerPopupUpdateCalls == 1)
assert(autoBarSetupCalls == 1)
assert(AutoBar.scheduledEvents[module.autoBarRefreshEvent])
assert(module.autoBarRefreshStatus == "queued")
AutoBar:RunScheduledEvent(module.autoBarRefreshEvent)
assert(module.autoBarRefreshStatus == "settled")

-- AutoBar's real SetupVisual calls ButtonsUpdate before restoring its saved
-- handle position. Its post-hook must cancel the zero-delay ButtonsUpdate
-- refresh and restore the AEUI anchor in the same input event, before the
-- provider's temporary anchor can render.
local settledDockAnchor = AutoBarAnchorFrameHandle.decorativePoints[1]
local settledDockX = settledDockAnchor[4]
local settledDockY = settledDockAnchor[5]
providerSetupReanchors = true
AutoBar_SetupVisual()
assert(AutoBarAnchorFrameHandle.shown == false)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][2] == pfUI.bars[1])
assert(AutoBarAnchorFrameHandle.decorativePoints[1][4] == settledDockX)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][5] == settledDockY)
assert(AutoBar.scheduledEvents[module.autoBarRefreshEvent])
assert(module.autoBarRefreshStatus == "queued")
AutoBar:RunScheduledEvent(module.autoBarRefreshEvent)
assert(module.autoBarRefreshStatus == "settled")
AutoBar_SetupVisual()
assert(AutoBarAnchorFrameHandle.shown == false)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][2] == pfUI.bars[1])
assert(AutoBarAnchorFrameHandle.decorativePoints[1][4] == settledDockX)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][5] == settledDockY)
assert(AutoBar.scheduledEvents[module.autoBarRefreshEvent])
assert(module.autoBarRefreshStatus == "queued")
AutoBar:RunScheduledEvent(module.autoBarRefreshEvent)
assert(module.autoBarRefreshStatus == "settled")
providerSetupReanchors = false

-- Opening the configuration page is a separate provider lifecycle boundary.
-- Even if its initialization writes a free profile position after a nested
-- SetupVisual, the OnShow post-hook must restore the cached Combat Deck
-- anchor synchronously and defer only the geometry-dependent rebuild.
providerConfigOnShowReanchors = true
AutoBarConfig.OnShow()
assert(AutoBarAnchorFrameHandle.shown == false)
assert(autoBarConfigOnShowCalls == 1)
assert(AutoBarConfigFrameTab2.shown == false)
assert(AutoBarConfigFrameTab4.shown == false)
assert(AutoBarConfigFrameTab5.shown == false)
assert(AutoBarConfigFrameResetDisplay.shown == false)
assert(AutoBarConfigFrameRevertButton.shown == false)
assert(AutoBarConfigFrameSlotsView.shown == false)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][2] == pfUI.bars[1])
assert(AutoBarAnchorFrameHandle.decorativePoints[1][4] == settledDockX)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][5] == settledDockY)
assert(AutoBar.scheduledEvents[module.autoBarRefreshEvent])
assert(module.autoBarRefreshStatus == "queued")
AutoBar:RunScheduledEvent(module.autoBarRefreshEvent)
assert(module.autoBarRefreshStatus == "settled")
providerConfigOnShowReanchors = false
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
local refreshFallback = module:QueueAutoBarFieldKitRefresh()
assert(refreshFallback == false)
assert(module.autoBarRefreshStatus == "immediate")
AutoBar.ScheduleEvent = providerScheduleEvent
AutoBar.CancelScheduledEvent = providerCancelScheduledEvent
module:ApplyAutoBarPopup(true)
assert(module.autoBarPopupHover == "intent-bridge")

local opened, openMessage = module:OpenAutoBarConfig()
assert(opened == true)
assert(autoBarConfigToggleCalls == 1)
assert(autoBarConfigOnShowCalls == 2)
assert(AutoBarConfigFrameTab2.shown == false)
assert(AutoBarConfigFrameTab4.shown == false)
assert(AutoBarConfigFrameTab5.shown == false)
AutoBarConfig:TabButtonOnClick(4)
assert(AutoBar_Config[AutoBar.currentPlayer].display.selectedTab == 1)
assert(AutoBarConfigFramePopup.shown == false)
assert(AutoBarConfigFrameSlots.shown == true)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][2] == pfUI.bars[1])
assert(AutoBar.scheduledEvents[module.autoBarRefreshEvent])
AutoBar:RunScheduledEvent(module.autoBarRefreshEvent)
assert(string.find(openMessage, "/aeui autobar apply", 1, true))

-- The provider can move its handle to the saved free position while WoW still
-- reports the previous frame's button coordinates. Repeated profile applies
-- must therefore be independent of world-space GetLeft/GetRight values.
local function ShiftAutoBarWorldGeometry(xDelta, yDelta)
  for index = 1, 24 do
    local button = _G["AutoBarFrameButton" .. index]
    button.left = button.left + xDelta
    button.right = button.right + xDelta
    button.bottom = button.bottom + yDelta
    button.top = button.top + yDelta
  end
end

providerSetupReanchors = true
ShiftAutoBarWorldGeometry(480, 210)
local applied, applyMessage = module:ApplyRecommendedAutoBarProfile()
assert(applied == true)
assert(string.find(applyMessage, "4x6", 1, true))
assert(AutoBarAnchorFrameHandle.decorativePoints[1][2] == pfUI.bars[1])
assert(AutoBarAnchorFrameHandle.decorativePoints[1][4] == settledDockX)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][5] == settledDockY)
assert(AutoBar.scheduledEvents[module.autoBarRefreshEvent])
AutoBar:RunScheduledEvent(module.autoBarRefreshEvent)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][4] == settledDockX)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][5] == settledDockY)
assert(module.autoBarAnchorBasis == "provider-local")

ShiftAutoBarWorldGeometry(-960, -420)
local appliedAgain = module:ApplyRecommendedAutoBarProfile()
assert(appliedAgain == true)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][2] == pfUI.bars[1])
assert(AutoBarAnchorFrameHandle.decorativePoints[1][4] == settledDockX)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][5] == settledDockY)
assert(AutoBar.scheduledEvents[module.autoBarRefreshEvent])
AutoBar:RunScheduledEvent(module.autoBarRefreshEvent)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][4] == settledDockX)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][5] == settledDockY)
assert(module.autoBarAnchorBasis == "provider-local")

-- A future provider layout that does not expose the direct handle-relative
-- point contract must retain the last proven anchor instead of falling back
-- to the deliberately stale world coordinates above.
local incompatibleButton = AutoBarFrameButton1
local incompatiblePoint = { incompatibleButton:GetPoint(1) }
incompatibleButton:ClearAllPoints()
incompatibleButton:SetPoint("BOTTOMLEFT", UIParent, "CENTER", 0, 0)
module:ApplyAutoBarFieldKit(true)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][4] == settledDockX)
assert(AutoBarAnchorFrameHandle.decorativePoints[1][5] == settledDockY)
assert(module.autoBarAnchorBasis == "cached")
incompatibleButton:ClearAllPoints()
incompatibleButton:SetPoint(unpack(incompatiblePoint))
module:ApplyAutoBarFieldKit(true)
assert(module.autoBarAnchorBasis == "provider-local")
ShiftAutoBarWorldGeometry(480, 210)
providerSetupReanchors = false

local appliedConfig = AutoBar_Config[AutoBar.currentPlayer]
local appliedClassConfig = AutoBar_Config[AutoBarProfile.CLASSPROFILE]
assert(appliedConfig.profile.useCharacter == false)
assert(appliedConfig.profile.useShared == false)
assert(appliedConfig.profile.useClass == true)
assert(appliedConfig.profile.useBasic == false)
assert(appliedConfig.profile.layout == 1)
assert(appliedConfig.profile.layoutProfile == AutoBar.currentPlayer)
assert(appliedConfig.display.rows == 6)
assert(appliedConfig.display.columns == 4)
assert(appliedConfig.display.gapping == 3)
assert(appliedConfig.display.buttonWidth == 36)
assert(appliedConfig.display.buttonHeight == 36)
assert(appliedConfig.display.alignButtons == 1)
assert(appliedConfig.display.showEmptyButtons == false)
assert(appliedConfig.display.showCategoryIcon == false)
assert(appliedConfig.display.hideDragHandle == 1)
assert(appliedConfig.display.popupToTop == true)
assert(appliedConfig.display.position.x == 321)
assert(appliedConfig.display.position.y == 654)
assert(appliedConfig.profile.edit == 3)
assert(appliedConfig.profile.editing == AutoBarProfile.CLASSPROFILE)
assert(appliedConfig.buttons[1][1] == "ORIGINAL")
assert(appliedClassConfig.buttons[1][1] == "HEALPOTIONS")
assert(appliedClassConfig.buttons[3][1] == "RUNES")
assert(appliedClassConfig.buttons[16][1] == 13446)
assert(appliedClassConfig.buttons[16][2] == 20008)
local savedBackup = AzerothExpeditionUI.db.actionbars.autoBarBackups[
  AutoBar.currentPlayer
]
assert(savedBackup)
assert(savedBackup ~= appliedConfig)
assert(savedBackup.buttons[1][1] == "ORIGINAL")
assert(savedBackup.display.rows == 6)
assert(savedBackup.display.gapping == 9)
local scopeBackup = AzerothExpeditionUI.db.actionbars.
  autoBarClassScopePlayerBackups[AutoBar.currentPlayer]
assert(scopeBackup.profile.useCharacter == true)
assert(scopeBackup.profile.useClass == false)
assert(AzerothExpeditionUI.db.actionbars.autoBarDefaultModeVersions[
  AutoBar.currentPlayer
] == 1)

-- An exact prior AEUI full-grid profile migrates once to the inventory-aware
-- compact display. The category map and the user's pre-AEUI backup are kept.
appliedConfig.display.showEmptyButtons = true
appliedConfig.display.showCategoryIcon = true
appliedConfig.display.hideDragHandle = nil
AzerothExpeditionUI.db.actionbars.autoBarDefaultModeVersions[
  AutoBar.currentPlayer
] = nil
AutoBarProfile:ProfileChanged()
local migratedCompact = module:MigrateAutoBarDefaultMode()
assert(migratedCompact == true)
assert(appliedConfig.display.showEmptyButtons == false)
assert(appliedConfig.display.showCategoryIcon == false)
assert(appliedConfig.display.hideDragHandle == 1)
assert(module.autoBarPresetStatus == "compact-migrated")
assert(AzerothExpeditionUI.db.actionbars.autoBarBackups[
  AutoBar.currentPlayer
] == savedBackup)

-- Compact inventories can expose fewer than 24 buttons while retaining the
-- AEUI drawer. Semantic group dividers remain disabled until all 24 are shown.
for index = 14, 24 do
  _G["AutoBarFrameButton" .. index]:Hide()
end
module:ApplyAutoBarFieldKit(true)
assert(module.autoBarMainButtons == 13)
assert(module.autoBarGrouped == false)
assert(module.autoBarPopupLayout == "drawer-2x6")
for index = 14, 24 do
  _G["AutoBarFrameButton" .. index]:Show()
end
module:ApplyAutoBarFieldKit(true)
assert(module.autoBarMainButtons == 24)
assert(module.autoBarGrouped == true)

local restored, restoreMessage = module:RestoreAutoBarProfile()
assert(restored == true)
assert(string.find(restoreMessage, "restored", 1, true))
assert(AutoBar_Config[AutoBar.currentPlayer].buttons[1][1] == "ORIGINAL")
assert(AutoBar_Config[AutoBar.currentPlayer].display.rows == 6)
assert(AutoBar_Config[AutoBar.currentPlayer].display.gapping == 9)
assert(AutoBar_Config[AutoBar.currentPlayer].profile.useCharacter == true)
assert(AutoBar_Config[AutoBar.currentPlayer].profile.useClass == false)
assert(AutoBar_Config[AutoBarProfile.CLASSPROFILE].buttons[1][1] ==
  "CLASS_DEFAULT")
assert(AzerothExpeditionUI.db.actionbars.autoBarClassScopeOptOut[
  AutoBar.currentPlayer
] == true)
assert(module.autoBarConfigCurationStatus == "native")
assert(AutoBarConfigFrameTab2.shown == true)
assert(AutoBarConfigFrameTab4.shown == true)
assert(AutoBarConfigFrameTab5.shown == true)
assert(AutoBarConfigFrameResetDisplay.shown == true)
assert(AutoBarConfigFrameRevertButton.shown == true)
assert(AzerothExpeditionUI.db.actionbars.autoBarBackups[
  AutoBar.currentPlayer
] == nil)
assert(AzerothExpeditionUI.db.actionbars.autoBarDefaultModeVersions[
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
assert(AutoBarAnchorFrameHandle.shown == true)
assert(module.autoBarDragHandleStatus == "visible-provider")
local redocked, redockMessage = module:SetFieldKitDocking(true)
assert(redocked == true)
assert(string.find(redockMessage, "consumables left", 1, true))
assert(AzerothExpeditionUI.db.actionbars.fieldKitBound == true)
assert(module.actionBarStackStatus == "12x2-bound")
assert(pfUI.movables.pfActionBarTop == pfUI.bars[6])
assert(module.consumableDockStatus == "left")
assert(module.trinketDockStatus == "right")
assert(AutoBarAnchorFrameHandle.shown == false)
assert(module.autoBarDragHandleStatus == "hidden-bound")

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
assert(AutoBarAnchorFrameHandle.shown == true)
assert(module.autoBarDragHandleStatus == "visible-provider")
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
assert(string.find(status, "fieldkit%-contract=2%.6"))
assert(string.find(status, "autobar%-drag%-handle=missing"))
assert(string.find(status, "autobar%-slot%-scope=restored"))
assert(string.find(status, "autobar%-config%-ui=native"))
assert(string.find(status, "autobar%-config%-descriptions=repaired"))
assert(string.find(status, "autobar%-config%-description%-fixes=8"))
assert(string.find(status, "fieldkit%-binding=bound"))
assert(string.find(status, "autobar=missing"))
assert(string.find(status, "autobar%-popup%-hover=missing"))
assert(string.find(status, "trinket=missing"))

print("action field kit module smoke test passed")
