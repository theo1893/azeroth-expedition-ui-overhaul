local root = assert(arg[1], "repository root argument is required")
table.getn = table.getn or function(value) return #value end
unpack = unpack or table.unpack

local Frame = {}
Frame.__index = Frame
local PhysicalRect

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
function Frame:UpdateConfig() self.updateConfigCalls = self.updateConfigCalls + 1 end
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
-- v1.6 must never feed those physical dimensions into Frame:SetPoint.
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
  global = { pixelperfect = "7" },
  position = {
    pfActionBarMain = { scale = 1.2 },
  },
  bars = { bar1 = { spacing = "1" } },
  unitframes = {
    player = {
      width = "200", height = "46", buffs = "TOPLEFT",
      debuffs = "TOPRIGHT", buffperrow = "4", debuffperrow = "4",
    },
    target = {
      width = "200", height = "46", buffs = "TOPLEFT",
      debuffs = "TOPRIGHT", buffperrow = "4", debuffperrow = "4",
    },
    ttarget = {
      visible = "1", width = "100", height = "17",
      buffs = "off", debuffs = "off",
      buffsize = "16", debuffsize = "16",
      buffperrow = "4", debuffperrow = "4",
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
assert(module.focusLayoutRuntimeContract == "1.7")
assert(module.fieldKitRuntimeContract == "1.8")
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
assert(expected.playerX == -190)
assert(expected.playerY == 500)
assert(expected.targetX == 190)
assert(expected.targetY == 500)
assert(expected.targetTargetX == 414)
assert(expected.targetTargetY == 500)
assert(expected.playerCastX == -196)
assert(expected.playerCastY == 430)
assert(expected.targetCastX == 196)
assert(expected.targetCastY == 430)
assert(expected.swingX == 0)
assert(expected.swingY == 430)
assert(expected.stanceX == 0)
assert(expected.stanceY == 255)
assert(expected.doiteX == 1012)
assert(expected.doiteY == -780)
assert(screenWidthCalls == 0)
assert(screenHeightCalls == 0)

AssertPosition(
  "pfPlayer", "BOTTOM", expected.playerX, expected.playerY, 0.68
)
AssertPosition(
  "pfTarget", "BOTTOM", expected.targetX, expected.targetY, 0.68
)
AssertPosition(
  "pfTargetTarget", "BOTTOM", expected.targetTargetX,
  expected.targetTargetY, 0.62
)
AssertPosition(
  "pfPlayerCastbar", "BOTTOM", expected.playerCastX,
  expected.playerCastY, 0.72
)
AssertPosition(
  "pfTargetCastbar", "BOTTOM", expected.targetCastX,
  expected.targetCastY, 0.72
)
AssertPosition(
  "pfSwingTimerMainhand", "BOTTOM", expected.swingX, expected.swingY, 0.72
)
AssertPosition(
  "pfSwingTimerRanged", "BOTTOM", expected.swingX, expected.swingY, 0.72
)
AssertPosition(
  "pfActionBarStances", "BOTTOM", expected.stanceX, expected.stanceY, 0.72
)

-- V6 is expressed entirely in Turtle's game coordinate space. The target's
-- target is the only dependent anchor; all three readout columns share one
-- baseline, width, height and scale.
assert(player.points[1][4] == -target.points[1][4])
assert(player.points[1][5] == target.points[1][5])
assert(targetTarget.points[1][1] == "LEFT")
assert(targetTarget.points[1][2] == target)
assert(targetTarget.points[1][3] == "RIGHT")
assert(targetTarget.points[1][4] == 8)
assert(targetTarget.points[1][5] == 0)
assert(playerCast.points[1][5] == swingMain.points[1][5])
assert(swingMain.points[1][5] == targetCast.points[1][5])
assert(playerCast.points[1][4] == -targetCast.points[1][4])
assert(swingMain.points[1][4] == 0)

assert(module.focusUnitScale == 0.68)
assert(module.focusTargetTargetScale == 0.62)
assert(module.focusReadoutScale == 0.72)
for _, frame in pairs({ player, target }) do
  assert(math.abs(frame.scale - 0.68) < 0.001)
end
assert(math.abs(targetTarget.scale - 0.62) < 0.001)
for _, frame in pairs({
  playerCast, targetCast, swingMain, swingOffhand, swingRanged, stance,
}) do
  assert(math.abs(frame.scale - 0.72) < 0.001)
end
assert(math.abs(doite.scale - 0.82) < 0.001)

local playerConfig = pfUI_config.unitframes.player
local targetConfig = pfUI_config.unitframes.target
local targetTargetConfig = pfUI_config.unitframes.ttarget
for _, config in pairs({ playerConfig, targetConfig }) do
  assert(config.width == "240")
  assert(config.height == "60")
  assert(config.buffsize == "18")
  assert(config.debuffsize == "18")
  assert(config.buffperrow == "8")
  assert(config.debuffperrow == "8")
end
assert(playerConfig.buffs == "TOPLEFT")
assert(playerConfig.debuffs == "BOTTOMLEFT")
assert(targetConfig.buffs == "TOPRIGHT")
assert(targetConfig.debuffs == "BOTTOMRIGHT")
assert(targetTargetConfig.visible == "1")
assert(targetTargetConfig.width == "132")
assert(targetTargetConfig.height == "30")
assert(targetTargetConfig.buffs == "TOPRIGHT")
assert(targetTargetConfig.debuffs == "BOTTOMRIGHT")
assert(targetTargetConfig.buffsize == "14")
assert(targetTargetConfig.debuffsize == "14")
assert(targetTargetConfig.buffperrow == "8")
assert(targetTargetConfig.debuffperrow == "8")
assert(player.updateConfigCalls == 1)
assert(target.updateConfigCalls == 1)
assert(targetTarget.updateConfigCalls == 1)
assert(player.updateSizeCalls == 1)
assert(target.updateSizeCalls == 1)
assert(targetTarget.updateSizeCalls == 1)

assert(pfUI_config.castbar.player.width == "180")
assert(pfUI_config.castbar.player.height == "16")
assert(pfUI_config.castbar.target.width == "180")
assert(pfUI_config.castbar.target.height == "16")
assert(playerCast.width == 180 and playerCast.height == 16)
assert(targetCast.width == 180 and targetCast.height == 16)

assert(pfUI_config.unitframes.swingtimerwidth == "180")
assert(pfUI_config.unitframes.swingtimerheight == "16")
assert(swingMain.width == 180 and swingMain.height == 16)
assert(swingOffhand.width == 180 and swingOffhand.height == 16)
assert(swingRanged.width == 180 and swingRanged.height == 16)
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
assert(installedHooks == 1)
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
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 8)
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
assert(string.find(status, "focus%-layout%-contract=1%.7"))
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
assert(string.find(status, "focus%-layout%-unit%-scale=0%.68"))
assert(string.find(status, "focus%-layout%-targettarget%-scale=0%.62"))
assert(string.find(status, "focus%-layout%-readout%-scale=0%.72"))
assert(string.find(status, "focus%-layout%-readout%-size=180x16"))
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
assert(pfUI_config.unitframes.target.width == "200")
assert(pfUI_config.unitframes.ttarget.width == "100")
assert(pfUI_config.unitframes.ttarget.height == "17")
assert(pfUI_config.unitframes.ttarget.buffs == "off")
assert(pfUI_config.unitframes.ttarget.debuffs == "off")
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

-- A live 0.8.13 profile already has a version-1 backup that predates
-- TargetTarget ownership. V6 must extend that backup before its one-shot
-- version-7-to-8 migration, so restore remains lossless.
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
  legacyPosition("BOTTOM", -212, 492, 0.75)
pfUI_config.position.pfActionBarMain =
  legacyPosition("BOTTOM", 0, 175, 1.2)
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
DoiteDPSDB.point = "TOPLEFT"
DoiteDPSDB.relativePoint = "TOPLEFT"
DoiteDPSDB.x = 1012
DoiteDPSDB.y = -647
DoiteDPSDB.scale = 0.82
ArchiTotem_Options.Apperance.direction = "down"
AzerothExpeditionUI.db.actionbars.fieldKitBound = true
AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion = 7
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

-- A manually adjusted v7 profile is not the exact migration signature and
-- must stay untouched until the user explicitly reapplies the preset.
pfUI_config.position.pfPlayer.xpos = -200
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 7)

pfUI_config.position.pfPlayer.xpos = -212
module:Apply()
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 8)
local upgradedBackup =
  assert(AzerothExpeditionUI.db.actionbars.combatFocusBackup)
assert(upgradedBackup.positions.pfTargetTarget.present == false)
assert(upgradedBackup.unitframes.ttarget.present == true)
assert(upgradedBackup.unitframes.ttarget.value.width == "100")
assert(upgradedBackup.unitframes.ttarget.value.buffs == "off")
assert(screenWidthCalls == 0)
assert(screenHeightCalls == 0)

print("action focus layout module smoke test passed")
