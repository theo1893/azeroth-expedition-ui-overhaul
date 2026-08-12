local root = assert(arg[1], "repository root argument is required")
table.getn = table.getn or function(value) return #value end
unpack = unpack or table.unpack

local Frame = {}
Frame.__index = Frame
local PhysicalRect

local FontString = {}
FontString.__index = FontString

function FontString:SetFont(path, size, style)
  self.path = path
  self.size = size
  self.style = style
  self.calls = self.calls + 1
end

local function NewFontString()
  return setmetatable({ calls = 0 }, FontString)
end

local focusFontFields = {
  "hpLeftText", "hpRightText", "hpCenterText",
  "powerLeftText", "powerRightText", "powerCenterText",
}

function Frame:GetName() return self.name end
function Frame:GetWidth() return self.width end
function Frame:GetHeight() return self.height end
function Frame:SetWidth(value) self.width = value end
function Frame:SetHeight(value) self.height = value end
function Frame:GetParent() return self.parent end
function Frame:SetParent(value) self.parent = value end
function Frame:SetScale(value) self.scale = value end
function Frame:GetScale() return self.scale or 1 end
function Frame:GetEffectiveScale()
  if self == UIParent then
    return self.scale or 1
  end
  local parent = self.parent or UIParent
  local parentScale = parent and parent.GetEffectiveScale and
    parent:GetEffectiveScale() or 1
  return (self.scale or 1) * parentScale
end
function Frame:GetCenter()
  local left, bottom, right, top = PhysicalRect(self)
  if not left then return nil, nil end
  local scale = self:GetEffectiveScale()
  return (left + right) / 2 / scale, (bottom + top) / 2 / scale
end
function Frame:GetLeft()
  local left = PhysicalRect(self)
  return left and left / self:GetEffectiveScale() or nil
end
function Frame:GetRight()
  local left, bottom, right = PhysicalRect(self)
  return right and right / self:GetEffectiveScale() or nil
end
function Frame:GetBottom()
  local left, bottom = PhysicalRect(self)
  return bottom and bottom / self:GetEffectiveScale() or nil
end
function Frame:GetTop()
  local left, bottom, right, top = PhysicalRect(self)
  return top and top / self:GetEffectiveScale() or nil
end
function Frame:IsShown() return self.shown ~= false end
function Frame:ClearAllPoints() self.points = {} end
function Frame:SetPoint(...)
  table.insert(self.points, { ... })
end
function Frame:GetNumPoints() return table.getn(self.points) end
function Frame:GetPoint(index) return unpack(self.points[index]) end
function Frame:UpdateConfig()
  self.updateConfigCalls = self.updateConfigCalls + 1
  -- Emulate a late pfUI/provider redraw that writes its old unit face after
  -- SavedVariables changed. AEUI's post-hook must restore the live strings.
  for _, field in pairs(focusFontFields) do
    local fontString = self[field]
    if fontString then
      fontString:SetFont(
        "Interface\\AddOns\\pfUI\\fonts\\BigNoodleTitling.ttf",
        14,
        "OUTLINE"
      )
    end
  end
  if self.infoTopCenterText then
    self.infoTopCenterText:SetFont(
      "Interface\\AddOns\\pfUI\\fonts\\BigNoodleTitling.ttf",
      14,
      "OUTLINE"
    )
  end
end
function Frame:UpdateFrameSize() self.updateSizeCalls = self.updateSizeCalls + 1 end
function Frame:SetAlpha(value)
  self.alpha = value
  self.alphaCalls = self.alphaCalls + 1
end

local function NewFrame(name, width, height)
  return setmetatable({
    name = name,
    width = width or 1,
    height = height or 1,
    scale = 1,
    points = {},
    shown = true,
    updateConfigCalls = 0,
    updateSizeCalls = 0,
    alphaCalls = 0,
  }, Frame)
end

-- The game renders through a normalized 768-high UI root, while Turtle's
-- GetScreenWidth/GetScreenHeight report the physical 1920x1080 mode. Runtime
-- v2.4 must never feed those physical dimensions into Frame:SetPoint.
local rootWidth = 1920 * 768 / 1080
local rootHeight = 768
local uiScale = 0.81269841269841
UIParent = NewFrame("UIParent", rootWidth, rootHeight)
function UIParent:SetScale(value)
  self.scale = value
end
local screenWidthCalls = 0
local screenHeightCalls = 0
function GetScreenWidth()
  screenWidthCalls = screenWidthCalls + 1
  return 1920
end
function GetScreenHeight()
  screenHeightCalls = screenHeightCalls + 1
  return 1080
end

local function AnchorCoordinate(anchor, left, bottom, right, top)
  local x
  local y
  if string.find(anchor, "LEFT", 1, true) then
    x = left
  elseif string.find(anchor, "RIGHT", 1, true) then
    x = right
  else
    x = (left + right) / 2
  end
  if string.find(anchor, "BOTTOM", 1, true) then
    y = bottom
  elseif string.find(anchor, "TOP", 1, true) then
    y = top
  else
    y = (bottom + top) / 2
  end
  return x, y
end

PhysicalRect = function(frame)
  local effectiveScale = frame:GetEffectiveScale()
  if frame == UIParent then
    return 0, 0, rootWidth, rootHeight
  end
  local point = frame.points[1]
  if not point then return nil, nil, nil, nil end
  local anchor = point[1]
  local relative = point[2] or UIParent
  local relativeAnchor = point[3] or anchor
  local relativeLeft, relativeBottom, relativeRight, relativeTop =
    PhysicalRect(relative)
  if not relativeLeft then return nil, nil, nil, nil end
  local targetX, targetY = AnchorCoordinate(
    relativeAnchor, relativeLeft, relativeBottom, relativeRight, relativeTop
  )
  -- Anchor offsets use the scaled coordinate space of the frame whose point
  -- is being anchored, not the coordinate space of UIParent.
  targetX = targetX + (point[4] or 0) * effectiveScale
  targetY = targetY + (point[5] or 0) * effectiveScale
  local width = frame.width * effectiveScale
  local height = frame.height * effectiveScale
  local ownX, ownY = AnchorCoordinate(anchor, 0, 0, width, height)
  local left = targetX - ownX
  local bottom = targetY - ownY
  return left, bottom, left + width, bottom + height
end

local cvars = { uiScale = uiScale, useUiScale = 1 }
function SetCVar(name, value) cvars[name] = tonumber(value) or value end

local player = NewFrame("pfPlayer", 200, 46)
local target = NewFrame("pfTarget", 200, 46)
local targetTarget = NewFrame("pfTargetTarget", 100, 17)
for _, frame in pairs({ player, target, targetTarget }) do
  for _, field in pairs(focusFontFields) do
    frame[field] = NewFontString()
  end
end
player.infoTopCenterText = NewFontString()
local playerCast = NewFrame("pfPlayerCastbar", 300, 16)
local targetCast = NewFrame("pfTargetCastbar", 200, 16)
local swingMain = NewFrame("pfSwingTimerMainhand", 180, 10)
local swingOffhand = NewFrame("pfSwingTimerOffhand", 180, 10)
local swingRanged = NewFrame("pfSwingTimerRanged", 180, 10)
local stance = NewFrame("pfActionBarStances", 200, 24)
local mainBar = NewFrame("pfActionBarMain", 500, 44)
local topBar = NewFrame("pfActionBarTop", 400, 34)
local doite = NewFrame("DoiteDPSMainFrame", 318, 46)
local archiTotem = NewFrame("ArchiTotemFrame", 192, 80)
local archiEarth = NewFrame("ArchiTotemButton_Earth1", 40, 40)
local archiFire = NewFrame("ArchiTotemButton_Fire1", 40, 40)
local archiWater = NewFrame("ArchiTotemButton_Water1", 40, 40)
local archiAir = NewFrame("ArchiTotemButton_Air1", 40, 40)
local archiHandle = NewFrame("ArchiTotemDragHandle", 20, 20)
local archiAll = NewFrame("ArchiTotemButton_AllTotems", 40, 40)

doite:SetParent(UIParent)
mainBar:SetScale(1.2)
mainBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 100)
topBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 140)
archiTotem:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 603, -790)

_G.pfPlayer = player
_G.pfTarget = target
_G.pfTargetTarget = targetTarget
_G.pfPlayerCastbar = playerCast
_G.pfTargetCastbar = targetCast
_G.pfSwingTimerMainhand = swingMain
_G.pfSwingTimerOffhand = swingOffhand
_G.pfSwingTimerRanged = swingRanged
_G.pfActionBarStances = stance
_G.pfActionBarMain = mainBar
_G.pfActionBarTop = topBar
_G.DoiteDPSMainFrame = doite
_G.ArchiTotemFrame = archiTotem
_G.ArchiTotemButton_Earth1 = archiEarth
_G.ArchiTotemButton_Fire1 = archiFire
_G.ArchiTotemButton_Water1 = archiWater
_G.ArchiTotemButton_Air1 = archiAir
_G.ArchiTotemDragHandle = archiHandle
_G.ArchiTotemButton_AllTotems = archiAll

function getglobal(name) return _G[name] end
STANDARD_TEXT_FONT = "Fonts\\FZBWJW.TTF"
function InCombatLockdown() return false end
function UnitClass() return "Shaman", "SHAMAN" end

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

ArchiTotem_Options = {
  Apperance = {
    scale = "0.8",
    direction = "up",
    showrecallbutton = true,
    showpresetmanagerbutton = false,
    locked = false,
  },
}
local archiDirectionCalls = 0
function ArchiTotem_SetDirection(direction)
  archiDirectionCalls = archiDirectionCalls + 1
  ArchiTotem_Options.Apperance.direction = direction
end
local archiDragStopCalls = 0
function ArchiTotem_DragHandle_OnDragStop()
  archiDragStopCalls = archiDragStopCalls + 1
end

pfUI_config = {
  global = {
    pixelperfect = "7",
    font_unit = "Interface\\AddOns\\pfUI\\fonts\\BigNoodleTitling.ttf",
    font_unit_style = "OUTLINE",
  },
  position = {
    pfActionBarMain = { scale = 1.2 },
  },
  bars = { bar1 = { spacing = "1" } },
  unitframes = {
    player = {
      width = "200", height = "46", buffs = "TOPLEFT",
      debuffs = "TOPRIGHT", buffperrow = "4", debuffperrow = "4",
      customfont = "0", customfont_size = "12",
      customfont_name = "Interface\\AddOns\\pfUI\\fonts\\BigNoodleTitling.ttf",
      customfont_style = "OUTLINE",
    },
    target = {
      width = "200", height = "46", buffs = "TOPLEFT",
      debuffs = "TOPRIGHT", buffperrow = "4", debuffperrow = "4",
      customfont = "0", customfont_size = "12",
      customfont_name = "Interface\\AddOns\\pfUI\\fonts\\BigNoodleTitling.ttf",
      customfont_style = "OUTLINE",
    },
    ttarget = {
      visible = "1", width = "100", height = "17",
      buffs = "off", debuffs = "off",
      buffsize = "16", debuffsize = "16",
      buffperrow = "4", debuffperrow = "4",
      customfont = "0", customfont_size = "12",
      customfont_name = "Interface\\AddOns\\pfUI\\fonts\\BigNoodleTitling.ttf",
      customfont_style = "OUTLINE",
    },
    swingtimerwidth = "180",
    swingtimerheight = "10",
  },
  castbar = {
    player = { width = "300", height = "-1" },
    target = { width = "-1", height = "-1" },
  },
}

player.config = pfUI_config.unitframes.player
target.config = pfUI_config.unitframes.target
targetTarget.config = pfUI_config.unitframes.ttarget

pfUI = {
  bars = { [1] = mainBar, [6] = topBar },
  uf = {
    player = player,
    target = target,
    targettarget = targetTarget,
  },
  castbar = { player = playerCast, target = targetCast },
  swingtimer = {
    mainhand = swingMain,
    offhand = swingOffhand,
    ranged = swingRanged,
  },
  movables = {},
  pixelperfect = {},
}
function pfUI.pixelperfect.UpdateConfig()
  local scales = {
    [7] = 0.81269841269841,
    [8] = 0.71111111111111,
  }
  local scale = assert(scales[tonumber(pfUI_config.global.pixelperfect)])
  SetCVar("uiScale", scale)
  SetCVar("useUiScale", 1)
  UIParent:SetScale(scale)
end

DoiteDPSDB = {
  point = "CENTER",
  relativePoint = "CENTER",
  x = 18,
  y = -125,
  scale = 1,
  locked = true,
  enabled = false,
  showOnlyCombat = false,
  showForecast = true,
  showResource = true,
  showCooldowns = true,
}

AzerothExpeditionUI = {
  media = { root = "Interface\\AddOns\\AzerothExpeditionUI\\Media\\" },
  db = {
    actionbars = {
      enabled = true,
      fieldKitBound = true,
      combatFocusLayoutVersion = 1,
    },
  },
  modules = {},
}
function AzerothExpeditionUI:RegisterModule(name, module)
  self.modules[name] = module
end

dofile(root .. "/addon/AzerothExpeditionUI/Modules/ActionBars.lua")
local module = assert(AzerothExpeditionUI.modules.ActionBars)
module:Initialize()
assert(module.focusLayoutStatus == "ready")
assert(module.comfortUIScaleStatus == "custom")

local directOk, directMessage = module:ApplyCombatFocusLayoutPreset()
assert(directOk == false)
assert(string.find(directMessage, "require pfUI tier 8", 1, true))
assert(module.focusLayoutStatus == "scale-required")
assert(AzerothExpeditionUI.db.actionbars.combatFocusBackup == nil)
assert(mainBar.points[1][4] == 0)
assert(mainBar.points[1][5] == 100)

local ok, message = module:ApplyComfortUIScalePreset()
assert(ok == true)
assert(string.find(message, "Comfort UI scale applied", 1, true))
assert(module.focusLayoutRuntimeContract == "2.4")
assert(module.fieldKitRuntimeContract == "2.6")
assert(module.focusLayoutStatus == "applied")
assert(module.focusLayoutConfigured == 10)
assert(module.focusLayoutLive == 10)
assert(module.focusLayoutMousePolicy == "visible-controls-only")
assert(module.comfortUIScaleStatus == "applied")
assert(pfUI_config.global.pixelperfect == "8")
assert(math.abs(cvars.uiScale - 0.71111111111111) < 0.000001)
assert(cvars.useUiScale == 1)
assert(math.abs(UIParent:GetScale() - 0.71111111111111) < 0.000001)

local function AssertPosition(name, anchor, x, y, scale)
  local position = assert(pfUI_config.position[name])
  assert(position.anchor == anchor)
  assert(position.xpos == x)
  assert(position.ypos == y)
  assert(position.parent == "UIParent")
  assert(position.scale == scale)
end

AssertPosition("pfActionBarMain", "BOTTOM", 0, 175, 1.2)

local expected = assert(
  AzerothExpeditionUI.db.actionbars.combatFocusProjection
)
assert(expected.coordinateSpace == "game-native-v1")
assert(expected.deckX == 0)
assert(expected.deckY == 175)
assert(expected.playerX == -160)
assert(expected.playerY == 485)
assert(expected.targetX == 105)
assert(expected.targetY == 485)
assert(expected.targetTargetX == 393)
assert(expected.targetTargetY == 576)
assert(expected.playerCastX == 0)
assert(expected.playerCastY == 316)
assert(expected.targetCastX == 0)
assert(expected.targetCastY == 300)
assert(expected.swingX == 0)
assert(expected.swingY == 284)
assert(expected.stanceX == 0)
assert(expected.stanceY == 255)
assert(expected.doiteX == 850)
assert(expected.doiteY == -615)
assert(expected.unitFontRole == "system")
assert(expected.unitFontSize == 18)
assert(screenWidthCalls == 0)
assert(screenHeightCalls == 0)

AssertPosition(
  "pfPlayer", "BOTTOM", expected.playerX, expected.playerY, 0.8
)
AssertPosition(
  "pfTarget", "BOTTOM", expected.targetX, expected.targetY, 0.8
)
AssertPosition(
  "pfTargetTarget", "BOTTOM", expected.targetTargetX,
  expected.targetTargetY, 0.68
)
AssertPosition(
  "pfPlayerCastbar", "BOTTOM", expected.playerCastX,
  expected.playerCastY, 1
)
AssertPosition(
  "pfTargetCastbar", "BOTTOM", expected.targetCastX,
  expected.targetCastY, 1
)
AssertPosition(
  "pfSwingTimerMainhand", "BOTTOM", expected.swingX, expected.swingY, 1
)
AssertPosition(
  "pfSwingTimerRanged", "BOTTOM", expected.swingX, expected.swingY, 1
)
AssertPosition(
  "pfActionBarStances", "BOTTOM", expected.stanceX, expected.stanceY, 1
)

-- V10 is expressed entirely in Turtle's game coordinate space. TargetTarget
-- is the only dependent anchor; all timing readouts share one centerline on
-- distinct rows.
assert(player.points[1][4] == -160)
assert(target.points[1][4] == 105)
assert(player.points[1][5] == target.points[1][5])
assert(targetTarget.points[1][1] == "LEFT")
assert(targetTarget.points[1][2] == target)
assert(targetTarget.points[1][3] == "RIGHT")
assert(targetTarget.points[1][4] == 8)
assert(targetTarget.points[1][5] == 0)
assert(playerCast.points[1][5] > swingMain.points[1][5])
assert(playerCast.points[1][5] > targetCast.points[1][5])
assert(targetCast.points[1][5] > swingMain.points[1][5])
assert(playerCast.points[1][4] == 0)
assert(targetCast.points[1][4] == 0)
assert(swingMain.points[1][4] == 0)
local playerLeft, playerBottom, playerRight = PhysicalRect(player)
local targetLeft, targetBottom, targetRight = PhysicalRect(target)
local targetTargetLeft, targetTargetBottom = PhysicalRect(targetTarget)
assert(playerRight < targetLeft)
assert(targetRight < targetTargetLeft)
assert(math.abs(
  targetTargetLeft - targetRight - 8 * targetTarget:GetEffectiveScale()
) < 0.001)
assert(math.abs(
  (targetBottom + target:GetHeight() * target:GetEffectiveScale() / 2) -
  (targetTargetBottom +
    targetTarget:GetHeight() * targetTarget:GetEffectiveScale() / 2)
) < 0.001)
local playerCastCenter = playerCast:GetCenter()
local targetCastCenter = targetCast:GetCenter()
local swingCenter = swingMain:GetCenter()
assert(math.abs(playerCastCenter - targetCastCenter) < 0.001)
assert(math.abs(targetCastCenter - swingCenter) < 0.001)

assert(module.focusUnitScale == 0.8)
assert(module.focusTargetTargetScale == 0.68)
assert(module.focusReadoutScale == 1)
assert(module.focusStanceScale == 1)
assert(module.focusUnitFontRole == "system")
assert(module.focusUnitFontSize == 18)
for _, frame in pairs({ player, target }) do
  assert(math.abs(frame.scale - 0.8) < 0.001)
end
assert(math.abs(targetTarget.scale - 0.68) < 0.001)
for _, frame in pairs({
  playerCast, targetCast, swingMain, swingOffhand, swingRanged,
}) do
  assert(math.abs(frame.scale - 1) < 0.001)
end
assert(math.abs(stance.scale - 1) < 0.001)
assert(math.abs(doite.scale - 0.82) < 0.001)

local playerConfig = pfUI_config.unitframes.player
local targetConfig = pfUI_config.unitframes.target
local targetTargetConfig = pfUI_config.unitframes.ttarget
for _, config in pairs({ playerConfig, targetConfig }) do
  assert(config.width == "240")
  assert(config.height == "60")
  assert(config.buffsize == "23")
  assert(config.debuffsize == "23")
  assert(config.buffoffx == "0")
  assert(config.buffoffy == "0")
  assert(config.debuffoffx == "0")
  assert(config.debuffoffy == "0")
  assert(config.buffperrow == "8")
  assert(config.debuffperrow == "8")
  assert(config.customfont == "1")
  assert(config.customfont_size == "18")
  assert(config.customfont_name == STANDARD_TEXT_FONT)
  assert(config.customfont_style == "OUTLINE")
end
assert(playerConfig.buffs == "TOPLEFT")
assert(playerConfig.debuffs == "BOTTOMLEFT")
assert(targetConfig.buffs == "TOPRIGHT")
assert(targetConfig.debuffs == "BOTTOMRIGHT")
assert(targetTargetConfig.visible == "1")
assert(targetTargetConfig.width == "240")
assert(targetTargetConfig.height == "60")
assert(targetTargetConfig.buffs == "TOPRIGHT")
assert(targetTargetConfig.debuffs == "BOTTOMRIGHT")
assert(targetTargetConfig.buffsize == "23")
assert(targetTargetConfig.debuffsize == "23")
assert(targetTargetConfig.buffoffx == "0")
assert(targetTargetConfig.buffoffy == "0")
assert(targetTargetConfig.debuffoffx == "0")
assert(targetTargetConfig.debuffoffy == "0")
assert(targetTargetConfig.buffperrow == "8")
assert(targetTargetConfig.debuffperrow == "8")
assert(targetTargetConfig.customfont == "1")
assert(targetTargetConfig.customfont_size == "18")
assert(targetTargetConfig.customfont_name == STANDARD_TEXT_FONT)
assert(targetTargetConfig.customfont_style == "OUTLINE")
assert(23 + 7 * (23 + 7) == 233)
assert(240 - (23 + 7 * (23 + 7)) == 7)
assert(player.updateConfigCalls == 1)
assert(target.updateConfigCalls == 1)
assert(targetTarget.updateConfigCalls == 1)
assert(player.updateSizeCalls == 1)
assert(target.updateSizeCalls == 1)
assert(targetTarget.updateSizeCalls == 1)

local function AssertLiveSystemFont(frame)
  for _, field in pairs(focusFontFields) do
    local fontString = assert(frame[field])
    assert(fontString.path == STANDARD_TEXT_FONT)
    assert(fontString.size == 18)
    assert(fontString.style == "OUTLINE")
  end
end
AssertLiveSystemFont(player)
AssertLiveSystemFont(target)
AssertLiveSystemFont(targetTarget)
assert(player.infoTopCenterText.path == STANDARD_TEXT_FONT)
assert(player.infoTopCenterText.size == 18)
assert(player.infoTopCenterText.style == "OUTLINE")
assert(module.focusUnitFontLive == 19)

-- A later pfUI UpdateConfig writes the provider face first; the installed
-- post-hooks must leave all three live unit frames on the system face at 18.
player:UpdateConfig()
target:UpdateConfig()
targetTarget:UpdateConfig()
AssertLiveSystemFont(player)
AssertLiveSystemFont(target)
AssertLiveSystemFont(targetTarget)
assert(player.infoTopCenterText.path == STANDARD_TEXT_FONT)
assert(player.infoTopCenterText.size == 18)

assert(pfUI_config.castbar.player.width == "260")
assert(pfUI_config.castbar.player.height == "12")
assert(pfUI_config.castbar.target.width == "260")
assert(pfUI_config.castbar.target.height == "12")
assert(playerCast.width == 260 and playerCast.height == 12)
assert(targetCast.width == 260 and targetCast.height == 12)

assert(pfUI_config.unitframes.swingtimerwidth == "260")
assert(pfUI_config.unitframes.swingtimerheight == "12")
assert(swingMain.width == 260 and swingMain.height == 12)
assert(swingOffhand.width == 260 and swingOffhand.height == 12)
assert(swingRanged.width == 260 and swingRanged.height == 12)
assert(swingOffhand.points[1][1] == "TOP")
assert(swingOffhand.points[1][2] == swingMain)
assert(swingOffhand.points[1][3] == "BOTTOM")
assert(swingOffhand.points[1][5] == -2)

assert(DoiteDPSDB.point == "TOPLEFT")
assert(DoiteDPSDB.relativePoint == "TOPLEFT")
assert(math.abs(DoiteDPSDB.x - expected.doiteX) < 0.001)
assert(math.abs(DoiteDPSDB.y - expected.doiteY) < 0.001)
assert(math.abs(DoiteDPSDB.scale - 0.82) < 0.001)
assert(DoiteDPSDB.locked == true)
assert(DoiteDPSDB.enabled == false)
assert(DoiteDPSDB.showOnlyCombat == false)
assert(DoiteDPSDB.showForecast == true)
assert(DoiteDPSDB.showResource == true)
assert(DoiteDPSDB.showCooldowns == true)

assert(ArchiTotem_Options.Apperance.direction == "down")
assert(ArchiTotem_Options.Apperance.scale == "0.8")
assert(ArchiTotem_Options.Apperance.showrecallbutton == true)
assert(ArchiTotem_Options.Apperance.showpresetmanagerbutton == false)
assert(ArchiTotem_Options.Apperance.locked == false)
assert(archiDirectionCalls == 1)
assert(module.archiTotemDockStatus == "bottom")
assert(module.archiTotemDirectionStatus == "down")
local archiPoint = archiTotem.points[1]
assert(archiPoint[1] == "CENTER")
assert(archiPoint[2] == mainBar)
assert(archiPoint[3] == "BOTTOM")
assert(archiPoint[4] == -10)
assert(archiPoint[5] == -39)

module:InstallFieldKitHooks()
assert(installedHooks == 4)
archiTotem:ClearAllPoints()
archiTotem:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 900, -700)
ArchiTotem_DragHandle_OnDragStop()
assert(archiDragStopCalls == 1)
assert(archiTotem.points[1][1] == "CENTER")
assert(archiTotem.points[1][2] == mainBar)
assert(module.archiTotemDockStatus == "bottom")

local unbound = module:SetFieldKitDocking(false)
assert(unbound == true)
assert(archiTotem.points[1][1] == "TOPLEFT")
assert(archiTotem.points[1][2] == UIParent)
assert(archiTotem.points[1][3] == "TOPLEFT")
assert(archiTotem.points[1][4] == 603)
assert(archiTotem.points[1][5] == -790)
assert(module.archiTotemDockStatus == "free")
local rebound = module:SetFieldKitDocking(true)
assert(rebound == true)
assert(archiTotem.points[1][1] == "CENTER")
assert(archiTotem.points[1][2] == mainBar)

archiTotem.shown = false
module:ApplyArchiTotemDockPosition(true)
assert(module.archiTotemDockStatus == "hidden")
assert(archiTotem.points[1][1] == "TOPLEFT")
archiTotem.shown = true
module:ApplyArchiTotemDockPosition(true)
assert(module.archiTotemDockStatus == "bottom")

-- Ordinary refresh/binding observes provider direction without rewriting it.
ArchiTotem_Options.Apperance.direction = "up"
module:ApplyArchiTotemDockPosition(true)
assert(ArchiTotem_Options.Apperance.direction == "up")
assert(archiDirectionCalls == 1)
assert(module.archiTotemDirectionStatus == "up")

assert(AzerothExpeditionUI.db.actionbars.fieldKitBound == true)
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 15)
assert(AzerothExpeditionUI.db.actionbars.comfortUIScaleVersion == 2)

for _, frame in pairs({
  player, target, targetTarget, playerCast, targetCast, swingMain, swingOffhand,
  swingRanged, stance, mainBar, topBar, doite,
}) do
  assert(frame.alphaCalls == 0)
end
for _, frame in pairs({
  player, target, targetTarget, playerCast, targetCast, swingMain, swingRanged,
  stance,
}) do
  assert(frame.parent == nil)
end
assert(doite.parent == UIParent)

local status = module:GetRuntimeStatus()
assert(string.find(status, "focus%-layout%-contract=2%.4"))
assert(string.find(status, "focus%-layout=applied"))
assert(string.find(status, "focus%-layout%-mouse=visible%-controls%-only"))
assert(string.find(
  status,
  "focus%-layout%-anchor=ui%-parent%+target%-dependent"
))
assert(string.find(
  status,
  "focus%-layout%-coordinate%-space=game%-native%-v1"
))
assert(string.find(status, "focus%-layout%-unit%-scale=0%.8"))
assert(string.find(status, "focus%-layout%-targettarget%-scale=0%.68"))
assert(string.find(status, "focus%-layout%-readout%-scale=1"))
assert(string.find(status, "focus%-layout%-stance%-scale=1"))
assert(string.find(status, "focus%-layout%-readout%-size=260x12"))
assert(string.find(status, "focus%-layout%-unit%-font%-size=18"))
assert(string.find(status, "focus%-layout%-unit%-font=system"))
assert(string.find(status, "focus%-layout%-unit%-font%-live=19"))
assert(string.find(status, "focus%-ui%-scale=applied"))
assert(string.find(status, "focus%-ui%-scale%-tier=8"))
assert(string.find(status, "focus%-ui%-scale%-target=8"))
assert(string.find(status, "architotem%-dock=bottom"))
assert(string.find(status, "architotem%-direction=up"))

-- Ordinary module refresh must not maintain the focus geometry. The saved
-- one-shot profile remains recognizable, but a user's live move is untouched.
player:ClearAllPoints()
player:SetPoint("BOTTOM", UIParent, "BOTTOM", 123, 456)
module:Apply()
assert(player.points[1][1] == "BOTTOM")
assert(player.points[1][2] == UIParent)
assert(player.points[1][4] == 123)
assert(player.points[1][5] == 456)

module:Initialize()
assert(module.focusLayoutStatus == "saved")
assert(module.comfortUIScaleStatus == "saved")

local restored, restoreMessage = module:RestoreCombatFocusLayoutPreset()
assert(restored == true)
assert(string.find(restoreMessage, "pre%-Combat%-Focus"))
assert(module.focusLayoutStatus == "restored")
assert(module.comfortUIScaleStatus == "custom")
assert(AzerothExpeditionUI.db.actionbars.combatFocusBackup == nil)
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 1)
assert(AzerothExpeditionUI.db.actionbars.combatFocusProjection == nil)
assert(AzerothExpeditionUI.db.actionbars.comfortUIScaleVersion == nil)
assert(pfUI_config.global.pixelperfect == "7")
assert(math.abs(UIParent:GetScale() - 0.81269841269841) < 0.000001)
assert(pfUI_config.position.pfActionBarMain.scale == 1.2)
assert(pfUI_config.position.pfActionBarMain.anchor == nil)
assert(pfUI_config.position.pfPlayer == nil)
assert(pfUI_config.position.pfTarget == nil)
assert(pfUI_config.position.pfTargetTarget == nil)
assert(pfUI_config.unitframes.player.width == "200")
assert(pfUI_config.unitframes.player.height == "46")
assert(pfUI_config.unitframes.player.buffperrow == "4")
assert(pfUI_config.unitframes.player.customfont == "0")
assert(pfUI_config.unitframes.player.customfont_size == "12")
assert(pfUI_config.unitframes.target.width == "200")
assert(pfUI_config.unitframes.target.customfont == "0")
assert(pfUI_config.unitframes.target.customfont_size == "12")
assert(pfUI_config.unitframes.ttarget.width == "100")
assert(pfUI_config.unitframes.ttarget.height == "17")
assert(pfUI_config.unitframes.ttarget.buffs == "off")
assert(pfUI_config.unitframes.ttarget.debuffs == "off")
assert(pfUI_config.unitframes.ttarget.customfont == "0")
assert(pfUI_config.unitframes.ttarget.customfont_size == "12")
assert(pfUI_config.castbar.player.width == "300")
assert(pfUI_config.castbar.player.height == "-1")
assert(pfUI_config.unitframes.swingtimerwidth == "180")
assert(pfUI_config.unitframes.swingtimerheight == "10")
assert(DoiteDPSDB.point == "CENTER")
assert(DoiteDPSDB.relativePoint == "CENTER")
assert(DoiteDPSDB.x == 18)
assert(DoiteDPSDB.y == -125)
assert(DoiteDPSDB.scale == 1)
assert(ArchiTotem_Options.Apperance.direction == "up")

-- A live 0.8.14 profile may still have a version-1 backup that predates
-- TargetTarget ownership. V10 must extend that backup before its one-shot
-- version-8-to-14 migration, so restore remains lossless.
pfUI_config.global.pixelperfect = "8"
pfUI.pixelperfect.UpdateConfig()
local function legacyPosition(anchor, x, y, scale)
  return {
    anchor = anchor,
    parent = "UIParent",
    xpos = x,
    ypos = y,
    scale = scale,
  }
end
pfUI_config.position.pfPlayer =
  legacyPosition("BOTTOM", -190, 500, 0.68)
pfUI_config.position.pfActionBarMain =
  legacyPosition("BOTTOM", 0, 175, 1.2)
pfUI_config.position.pfTarget =
  legacyPosition("BOTTOM", 190, 500, 0.68)
pfUI_config.position.pfTargetTarget =
  legacyPosition("BOTTOM", 414, 500, 0.62)
pfUI_config.position.pfPlayerCastbar =
  legacyPosition("BOTTOM", -196, 430, 0.72)
pfUI_config.position.pfTargetCastbar =
  legacyPosition("BOTTOM", 196, 430, 0.72)
pfUI_config.position.pfSwingTimerMainhand =
  legacyPosition("BOTTOM", 0, 430, 0.72)
pfUI_config.position.pfSwingTimerRanged =
  legacyPosition("BOTTOM", 0, 430, 0.72)
pfUI_config.position.pfActionBarStances =
  legacyPosition("BOTTOM", 0, 255, 0.72)
for _, config in pairs({
  pfUI_config.unitframes.player,
  pfUI_config.unitframes.target,
}) do
  config.width = "240"
  config.height = "60"
  config.buffsize = "18"
  config.debuffsize = "18"
  config.buffperrow = "8"
  config.debuffperrow = "8"
  config.buffoffx = "0"
  config.buffoffy = "0"
  config.debuffoffx = "0"
  config.debuffoffy = "0"
end
pfUI_config.unitframes.player.buffs = "TOPLEFT"
pfUI_config.unitframes.player.debuffs = "BOTTOMLEFT"
pfUI_config.unitframes.target.buffs = "TOPRIGHT"
pfUI_config.unitframes.target.debuffs = "BOTTOMRIGHT"
local oldTargetTargetConfig = pfUI_config.unitframes.ttarget
oldTargetTargetConfig.visible = "1"
oldTargetTargetConfig.width = "132"
oldTargetTargetConfig.height = "30"
oldTargetTargetConfig.buffs = "TOPRIGHT"
oldTargetTargetConfig.debuffs = "BOTTOMRIGHT"
oldTargetTargetConfig.buffsize = "14"
oldTargetTargetConfig.debuffsize = "14"
oldTargetTargetConfig.buffperrow = "8"
oldTargetTargetConfig.debuffperrow = "8"
oldTargetTargetConfig.buffoffx = "0"
oldTargetTargetConfig.buffoffy = "0"
oldTargetTargetConfig.debuffoffx = "0"
oldTargetTargetConfig.debuffoffy = "0"
pfUI_config.castbar.player.width = "180"
pfUI_config.castbar.player.height = "16"
pfUI_config.castbar.target.width = "180"
pfUI_config.castbar.target.height = "16"
pfUI_config.unitframes.swingtimerwidth = "180"
pfUI_config.unitframes.swingtimerheight = "16"
DoiteDPSDB.point = "TOPLEFT"
DoiteDPSDB.relativePoint = "TOPLEFT"
DoiteDPSDB.x = 1012
DoiteDPSDB.y = -780
DoiteDPSDB.scale = 0.82
ArchiTotem_Options.Apperance.direction = "down"
AzerothExpeditionUI.db.actionbars.fieldKitBound = true
AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion = 8
AzerothExpeditionUI.db.actionbars.combatFocusProjection = {
  coordinateSpace = "game-native-v1",
}
AzerothExpeditionUI.db.actionbars.combatFocusBackup = {
  version = 1,
  positions = {},
  unitframes = {},
  castbar = {},
  actionbars = {},
}

-- A manually adjusted v8 profile is not the exact migration signature and
-- must stay untouched until the user explicitly reapplies the preset.
pfUI_config.position.pfPlayer.xpos = -180
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 8)

pfUI_config.position.pfPlayer.xpos = -190
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 15)
local upgradedBackup =
  assert(AzerothExpeditionUI.db.actionbars.combatFocusBackup)
assert(upgradedBackup.positions.pfTargetTarget.present == true)
assert(upgradedBackup.positions.pfTargetTarget.value.xpos == 414)
assert(upgradedBackup.unitframes.ttarget.present == true)
assert(upgradedBackup.unitframes.ttarget.value.width == "132")
assert(upgradedBackup.unitframes.ttarget.value.buffs == "TOPRIGHT")
assert(screenWidthCalls == 0)
assert(screenHeightCalls == 0)

-- A live in-memory v9 session can be newer than the persisted v8 snapshot.
-- Only its exact untouched geometry and default local font signature may
-- migrate automatically to v15.
pfUI_config.position.pfPlayer =
  legacyPosition("BOTTOM", -150, 535, 0.68)
pfUI_config.position.pfTarget =
  legacyPosition("BOTTOM", 190, 535, 0.68)
pfUI_config.position.pfTargetTarget =
  legacyPosition("BOTTOM", 190, 651, 0.68)
pfUI_config.position.pfPlayerCastbar =
  legacyPosition("BOTTOM", -100, 443, 0.72)
pfUI_config.position.pfTargetCastbar =
  legacyPosition("BOTTOM", 100, 443, 0.72)
pfUI_config.position.pfSwingTimerMainhand =
  legacyPosition("BOTTOM", 0, 421, 0.72)
pfUI_config.position.pfSwingTimerRanged =
  legacyPosition("BOTTOM", 0, 421, 0.72)
pfUI_config.position.pfActionBarStances =
  legacyPosition("BOTTOM", 0, 255, 0.72)
for _, config in pairs({
  pfUI_config.unitframes.player,
  pfUI_config.unitframes.target,
  pfUI_config.unitframes.ttarget,
}) do
  config.visible = "1"
  config.width = "240"
  config.height = "60"
  config.buffsize = "22"
  config.debuffsize = "22"
  config.buffperrow = "8"
  config.debuffperrow = "8"
  config.buffoffx = "0"
  config.buffoffy = "0"
  config.debuffoffx = "0"
  config.debuffoffy = "0"
  config.customfont = "0"
  config.customfont_size = "12"
end
pfUI_config.unitframes.player.buffs = "TOPLEFT"
pfUI_config.unitframes.player.debuffs = "BOTTOMLEFT"
pfUI_config.unitframes.target.buffs = "TOPRIGHT"
pfUI_config.unitframes.target.debuffs = "BOTTOMRIGHT"
pfUI_config.unitframes.ttarget.buffs = "TOPRIGHT"
pfUI_config.unitframes.ttarget.debuffs = "BOTTOMRIGHT"
pfUI_config.castbar.player.width = "180"
pfUI_config.castbar.player.height = "16"
pfUI_config.castbar.target.width = "180"
pfUI_config.castbar.target.height = "16"
pfUI_config.unitframes.swingtimerwidth = "180"
pfUI_config.unitframes.swingtimerheight = "16"
DoiteDPSDB.x = 850
DoiteDPSDB.y = -647
DoiteDPSDB.scale = 0.82
AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion = 9
AzerothExpeditionUI.db.actionbars.combatFocusProjection = {
  coordinateSpace = "game-native-v1",
}

pfUI_config.unitframes.player.customfont_size = "13"
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 9)

pfUI_config.unitframes.player.customfont_size = "12"
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 15)

-- The currently persisted target-device snapshot can still be the exact
-- v7 game-coordinate contract if the in-memory v8 session has not yet been
-- written. It must also jump directly to v15 on the next load.
pfUI_config.position.pfPlayer =
  legacyPosition("BOTTOM", -212, 492, 0.75)
pfUI_config.position.pfTarget =
  legacyPosition("BOTTOM", 213, 492, 0.75)
pfUI_config.position.pfPlayerCastbar =
  legacyPosition("BOTTOM", -212, 454, 0.75)
pfUI_config.position.pfTargetCastbar =
  legacyPosition("BOTTOM", 213, 454, 0.75)
pfUI_config.position.pfSwingTimerMainhand =
  legacyPosition("CENTER", 0, -67, 0.82)
pfUI_config.position.pfSwingTimerRanged =
  legacyPosition("CENTER", 0, -67, 0.82)
pfUI_config.position.pfActionBarStances =
  legacyPosition("TOP", 0, -919, 0.82)
for _, config in pairs({
  pfUI_config.unitframes.player,
  pfUI_config.unitframes.target,
}) do
  config.width = "280"
  config.height = "72"
  config.buffs = "TOPLEFT"
  config.debuffs = "TOPRIGHT"
  config.buffperrow = "6"
  config.debuffperrow = "6"
end
pfUI_config.castbar.player.width = "-1"
pfUI_config.castbar.player.height = "22"
pfUI_config.castbar.target.width = "-1"
pfUI_config.castbar.target.height = "22"
pfUI_config.unitframes.swingtimerwidth = "200"
pfUI_config.unitframes.swingtimerheight = "12"
DoiteDPSDB.x = 1012
DoiteDPSDB.y = -647
DoiteDPSDB.scale = 0.82
AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion = 7
AzerothExpeditionUI.db.actionbars.combatFocusProjection = {
  coordinateSpace = "game-native-v1",
}
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 15)
assert(screenWidthCalls == 0)
assert(screenHeightCalls == 0)

-- Profile v10 exists in two safe signatures: the untouched AEUI v8 projection and
-- the user's scale-only edit on 大奶黑牛. Both migrate to the reflowed V12;
-- any additional manual coordinate edit remains untouched.
local function ConfigureV10Signature(unitScale, readoutScale)
  pfUI_config.position.pfPlayer =
    legacyPosition("BOTTOM", -160, 535, unitScale)
  pfUI_config.position.pfTarget =
    legacyPosition("BOTTOM", 105, 535, unitScale)
  pfUI_config.position.pfTargetTarget =
    legacyPosition("BOTTOM", 353, 535, 0.68)
  pfUI_config.position.pfPlayerCastbar =
    legacyPosition("BOTTOM", 0, 443, readoutScale)
  pfUI_config.position.pfTargetCastbar =
    legacyPosition("BOTTOM", 0, 423, readoutScale)
  pfUI_config.position.pfSwingTimerMainhand =
    legacyPosition("BOTTOM", 0, 403, readoutScale)
  pfUI_config.position.pfSwingTimerRanged =
    legacyPosition("BOTTOM", 0, 403, readoutScale)
  pfUI_config.position.pfActionBarStances =
    legacyPosition("BOTTOM", 0, 255, 0.72)
  for _, config in pairs({
    pfUI_config.unitframes.player,
    pfUI_config.unitframes.target,
    pfUI_config.unitframes.ttarget,
  }) do
    config.visible = "1"
    config.width = "240"
    config.height = "60"
    config.buffsize = "27"
    config.debuffsize = "27"
    config.buffperrow = "8"
    config.debuffperrow = "8"
    config.buffoffx = "0"
    config.buffoffy = "0"
    config.debuffoffx = "0"
    config.debuffoffy = "0"
    config.customfont = "1"
    config.customfont_size = "14"
  end
  pfUI_config.unitframes.player.buffs = "TOPLEFT"
  pfUI_config.unitframes.player.debuffs = "BOTTOMLEFT"
  pfUI_config.unitframes.target.buffs = "TOPRIGHT"
  pfUI_config.unitframes.target.debuffs = "BOTTOMRIGHT"
  pfUI_config.unitframes.ttarget.buffs = "TOPRIGHT"
  pfUI_config.unitframes.ttarget.debuffs = "BOTTOMRIGHT"
  pfUI_config.castbar.player.width = "260"
  pfUI_config.castbar.player.height = "12"
  pfUI_config.castbar.target.width = "260"
  pfUI_config.castbar.target.height = "12"
  pfUI_config.unitframes.swingtimerwidth = "260"
  pfUI_config.unitframes.swingtimerheight = "12"
  DoiteDPSDB.x = 850
  DoiteDPSDB.y = -647
  DoiteDPSDB.scale = 0.82
  ArchiTotem_Options.Apperance.direction = "down"
  AzerothExpeditionUI.db.actionbars.fieldKitBound = true
  AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion = 10
  AzerothExpeditionUI.db.actionbars.combatFocusProjection = {
    coordinateSpace = "game-native-v1",
  }
end

ConfigureV10Signature(0.68, 0.72)
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 15)

ConfigureV10Signature(0.8, 1)
pfUI_config.position.pfTarget.ypos = 533
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 10)
pfUI_config.position.pfTarget.ypos = 535
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 15)
assert(pfUI_config.position.pfPlayer.ypos == 485)
assert(pfUI_config.position.pfTarget.ypos == 485)
assert(pfUI_config.position.pfPlayer.scale == 0.8)
assert(pfUI_config.position.pfTarget.scale == 0.8)
assert(pfUI_config.position.pfPlayerCastbar.ypos == 316)
assert(pfUI_config.position.pfTargetCastbar.ypos == 300)
assert(pfUI_config.position.pfSwingTimerMainhand.ypos == 284)
assert(pfUI_config.position.pfPlayerCastbar.scale == 1)
assert(pfUI_config.position.pfActionBarStances.scale == 1)

-- The exact V11 snapshot migrates once to V15. A one-coordinate manual edit
-- still protects the profile.
ConfigureV10Signature(0.8, 1)
pfUI_config.position.pfPlayer.ypos = 455
pfUI_config.position.pfTarget.ypos = 455
pfUI_config.position.pfTargetTarget =
  legacyPosition("BOTTOM", 393, 541, 0.68)
pfUI_config.position.pfPlayerCastbar =
  legacyPosition("BOTTOM", 0, 316, 1)
pfUI_config.position.pfTargetCastbar =
  legacyPosition("BOTTOM", 0, 300, 1)
pfUI_config.position.pfSwingTimerMainhand =
  legacyPosition("BOTTOM", 0, 284, 1)
pfUI_config.position.pfSwingTimerRanged =
  legacyPosition("BOTTOM", 0, 284, 1)
AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion = 11

pfUI_config.position.pfTarget.ypos = 453
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 11)
pfUI_config.position.pfTarget.ypos = 455
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 15)
assert(pfUI_config.position.pfPlayer.ypos == 485)
assert(pfUI_config.position.pfTarget.ypos == 485)
assert(pfUI_config.position.pfTargetTarget.ypos == 576)
assert(pfUI_config.unitframes.target.buffsize == "23")
assert(pfUI_config.unitframes.target.debuffsize == "23")

-- The exact V12 snapshot currently persisted by 大奶黑牛 receives only the
-- requested font and DoiteDPS-lane repair. A manually selected font protects
-- the profile until the preset is explicitly applied again.
for _, config in pairs({
  pfUI_config.unitframes.player,
  pfUI_config.unitframes.target,
  pfUI_config.unitframes.ttarget,
}) do
  config.customfont = "1"
  config.customfont_name = pfUI_config.global.font_unit
  config.customfont_size = "14"
  config.customfont_style = pfUI_config.global.font_unit_style
end
DoiteDPSDB.x = 850
DoiteDPSDB.y = -647
DoiteDPSDB.scale = 0.82
pfUI_config.position.pfActionBarStances.scale = 0.72
AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion = 12
AzerothExpeditionUI.db.actionbars.combatFocusProjection = {
  coordinateSpace = "game-native-v1",
}

pfUI_config.unitframes.target.customfont_name = STANDARD_TEXT_FONT
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 12)
assert(DoiteDPSDB.y == -647)

pfUI_config.unitframes.target.customfont_name = pfUI_config.global.font_unit
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 15)
assert(DoiteDPSDB.y == -615)
for _, config in pairs({
  pfUI_config.unitframes.player,
  pfUI_config.unitframes.target,
  pfUI_config.unitframes.ttarget,
}) do
  assert(config.customfont_name == STANDARD_TEXT_FONT)
  assert(config.customfont_size == "18")
  assert(config.customfont_style == "OUTLINE")
end

-- The exact V13 SavedVariables now seen on the target device must migrate
-- once to V15 so the live FontString post-hooks become part of the contract.
pfUI_config.position.pfActionBarStances.scale = 0.72
AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion = 13
AzerothExpeditionUI.db.actionbars.combatFocusProjection = {
  coordinateSpace = "game-native-v1",
}
pfUI_config.unitframes.target.customfont_size = "17"
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 13)
pfUI_config.unitframes.target.customfont_size = "18"
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 15)
AssertLiveSystemFont(player)
AssertLiveSystemFont(target)
AssertLiveSystemFont(targetTarget)

-- The exact V14 layout receives only the requested stance-size repair. A
-- manual stance scale still protects the profile until the preset is applied
-- explicitly or the exact prior contract is restored.
AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion = 14
AzerothExpeditionUI.db.actionbars.combatFocusProjection = {
  coordinateSpace = "game-native-v1",
}
pfUI_config.position.pfActionBarStances.scale = 0.8
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 14)
pfUI_config.position.pfActionBarStances.scale = 0.72
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 15)
assert(pfUI_config.position.pfActionBarStances.scale == 1)
assert(math.abs(stance.scale - 1) < 0.001)

print("action focus layout module smoke test passed")
