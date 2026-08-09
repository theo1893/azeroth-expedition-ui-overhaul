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
function Frame:ClearAllPoints() self.decorativePoints = {} end
function Frame:SetPoint(...) table.insert(self.decorativePoints, { ... }) end
function Frame:SetAllPoints(target) self.allPoints = target end
function Frame:SetWidth(value) self.width = value end
function Frame:SetHeight(value) self.height = value end
function Frame:GetWidth() return self.width end
function Frame:GetHeight() return self.height end
function Frame:GetLeft() return self.left end
function Frame:GetRight() return self.right end
function Frame:GetTop() return self.top end
function Frame:GetBottom() return self.bottom end
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
    frameLevel = geometry.frameLevel or 2,
    decorativePoints = {},
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
  buttons = {},
  display = {
    rows = 6,
    columns = 4,
    popupToRight = true,
  },
  providerButtonsUpdateCalls = 0,
  providerPopupUpdateCalls = 0,
}
for index = 1, 24 do
  AutoBar.buttons[index] = Split(recommended[index] or "")
end
AutoBar.buttons[16] = { 13446, 20008 }
AutoBar.buttons[18] = {}
function AutoBar:ButtonsUpdate() self.providerButtonsUpdateCalls = self.providerButtonsUpdateCalls + 1 end
function AutoBar:UpdatePopupButtons() self.providerPopupUpdateCalls = self.providerPopupUpdateCalls + 1 end
local autoBarSetupCalls = 0
function AutoBar_SetupVisual() autoBarSetupCalls = autoBarSetupCalls + 1 end

AutoBarFrame = NewFrame("AutoBarFrame", nil, { width = 157, height = 235 })
AutoBarPopupFrame = NewFrame("AutoBarPopupFrame", nil, { width = 153, height = 36 })
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

pfUI = { bars = {} }
AzerothExpeditionUI = {
  media = { root = "Interface\\AddOns\\AzerothExpeditionUI\\Media\\" },
  db = { actionbars = { enabled = true } },
  modules = {},
}
function AzerothExpeditionUI:RegisterModule(name, module) self.modules[name] = module end

dofile(root .. "/addon/AzerothExpeditionUI/Modules/ActionBars.lua")
local module = assert(AzerothExpeditionUI.modules.ActionBars)
module:Initialize()
module:Apply()

assert(module.fieldKitRuntimeContract == "1.0")
assert(module.autoBarFieldKitStatus == "available")
assert(module.autoBarMainButtons == 24)
assert(module.autoBarPopupButtons == 4)
assert(module.autoBarPopupConnectors == 3)
assert(module.autoBarGrouped == true)
assert(AutoBarFrame.aeuiConsumableKitShellV1.shown == true)
assert(table.getn(AutoBarFrame.aeuiConsumableKitLabelsV1) == 3)
assert(AutoBarFrame.aeuiConsumableKitLabelsV1[1].aeuiConsumableKitTextV1.text == "应急")
assert(table.getn(AutoBarFrame.aeuiConsumableKitDividersV1) == 2)
assert(AutoBarFrameButton1.aeuiConsumableKitPocketV1.texture ==
  "Interface\\AddOns\\AzerothExpeditionUI\\Media\\ActionBars\\ActionConsumableKitV1")
assert(math.abs(
  AutoBarFrameButton1.aeuiConsumableKitPocketV1.width /
  AutoBarFrameButton1.aeuiConsumableKitPocketV1.height - 112 / 108
) < 0.0001)

assert(module.trinketFieldKitStatus == "available")
assert(module.trinketMainButtons == 2)
assert(module.trinketMenuButtons == 30)
assert(module.trinketJoinerOrientation == "horizontal")
assert(TrinketMenu_MenuFrame.aeuiTrinketKitShellV1.shown == true)
assert(TrinketMenu_Trinket0NormalTexture.shown == false)
assert(TrinketMenu_Menu1NormalTexture.shown == false)
assert(TrinketMenu_MainFrame.backdrop == nil)
assert(TrinketMenu_MenuFrame.backdrop == nil)
assert(math.abs(
  TrinketMenu_Trinket0.aeuiTrinketKitPocketV1.width /
  TrinketMenu_Trinket0.aeuiTrinketKitPocketV1.height - 110 / 112
) < 0.0001)

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
assert(installedHooks == 5)

local hookedButtonsUpdate = AutoBar.ButtonsUpdate
local hookedPopupUpdate = AutoBar.UpdatePopupButtons
local hookedOrient = TrinketMenu.OrientWindows
local hookedBuild = TrinketMenu.BuildMenu
module:Apply()
assert(installedHooks == 5)
assert(AutoBar.ButtonsUpdate == hookedButtonsUpdate)
assert(AutoBar.UpdatePopupButtons == hookedPopupUpdate)
assert(TrinketMenu.OrientWindows == hookedOrient)
assert(TrinketMenu.BuildMenu == hookedBuild)

AutoBar:ButtonsUpdate()
AutoBar:UpdatePopupButtons()
AutoBar_SetupVisual()
assert(AutoBar.providerButtonsUpdateCalls == 1)
assert(AutoBar.providerPopupUpdateCalls == 1)
assert(autoBarSetupCalls == 1)

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
assert(AutoBarFrame.aeuiConsumableKitLabelsV1[1].shown == false)
AutoBar.display.columns = 4

AzerothExpeditionUI.db.actionbars.enabled = false
module:Apply()
assert(module.autoBarFieldKitStatus == "disabled")
assert(AutoBarFrameButton1.aeuiConsumableKitPocketV1.shown == false)
assert(AutoBarFrame.aeuiConsumableKitShellV1.shown == false)
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
assert(string.find(status, "fieldkit%-contract=1%.0"))
assert(string.find(status, "autobar=missing"))
assert(string.find(status, "trinket=missing"))

print("action field kit module smoke test passed")
