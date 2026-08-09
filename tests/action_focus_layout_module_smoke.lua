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

local uiScale = 0.81269841269841
UIParent = NewFrame("UIParent", 1920 / uiScale, 1080 / uiScale)
function UIParent:SetScale(value)
  self.scale = value
  self.width = 1920 / value
  self.height = 1080 / value
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
    return 0, 0, frame.width * effectiveScale,
      frame.height * effectiveScale
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
  local relativeScale = relative:GetEffectiveScale()
  targetX = targetX + (point[4] or 0) * relativeScale
  targetY = targetY + (point[5] or 0) * relativeScale
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
local playerCast = NewFrame("pfPlayerCastbar", 300, 16)
local targetCast = NewFrame("pfTargetCastbar", 200, 16)
local swingMain = NewFrame("pfSwingTimerMainhand", 180, 10)
local swingOffhand = NewFrame("pfSwingTimerOffhand", 180, 10)
local swingRanged = NewFrame("pfSwingTimerRanged", 180, 10)
local stance = NewFrame("pfActionBarStances", 200, 24)
local mainBar = NewFrame("pfActionBarMain", 500, 44)
local topBar = NewFrame("pfActionBarTop", 400, 34)
local doite = NewFrame("DoiteDPSMainFrame", 318, 46)
local doiteParent = NewFrame("DoiteDPSProviderRoot", 1, 1)
local archiTotem = NewFrame("ArchiTotemFrame", 192, 80)
local archiEarth = NewFrame("ArchiTotemButton_Earth1", 40, 40)
local archiFire = NewFrame("ArchiTotemButton_Fire1", 40, 40)
local archiWater = NewFrame("ArchiTotemButton_Water1", 40, 40)
local archiAir = NewFrame("ArchiTotemButton_Air1", 40, 40)
local archiHandle = NewFrame("ArchiTotemDragHandle", 20, 20)
local archiAll = NewFrame("ArchiTotemButton_AllTotems", 40, 40)

doiteParent:SetParent(UIParent)
doiteParent:SetScale(1.1)
doite:SetParent(doiteParent)
mainBar:SetScale(1.2)
mainBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 100)
topBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 140)
archiTotem:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 603, -790)

_G.pfPlayer = player
_G.pfTarget = target
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

pfUI = {
  bars = { [1] = mainBar, [6] = topBar },
  uf = { player = player, target = target },
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

local ok, message = module:ApplyComfortUIScalePreset()
assert(ok == true)
assert(string.find(message, "Comfort UI scale applied", 1, true))
assert(module.focusLayoutRuntimeContract == "1.4")
assert(module.fieldKitRuntimeContract == "1.6")
assert(module.focusLayoutStatus == "applied")
assert(module.focusLayoutConfigured == 9)
assert(module.focusLayoutLive == 9)
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

AssertPosition("pfActionBarMain", "BOTTOM", 0, 295, 1.2)

local function RoundCoordinate(value)
  if value < 0 then return math.ceil(value - 0.5) end
  return math.floor(value + 0.5)
end

local parentScale = UIParent:GetEffectiveScale()
local parentWidth = UIParent:GetWidth() * parentScale
local parentHeight = UIParent:GetHeight() * parentScale
local mainScale = mainBar:GetEffectiveScale()
local mainCenterX = select(1, mainBar:GetCenter()) * mainScale
local mainTop = mainBar:GetTop() * mainScale
local doiteInheritedScale = doite:GetEffectiveScale() / doite:GetScale()
local expected = {
  playerX = RoundCoordinate((mainCenterX - 159 - parentWidth / 2) /
    parentScale),
  targetX = RoundCoordinate((mainCenterX + 160 - parentWidth / 2) /
    parentScale),
  unitY = RoundCoordinate((mainTop + 106) / parentScale),
  castY = RoundCoordinate((mainTop + 78) / parentScale),
  swingX = RoundCoordinate((mainCenterX - parentWidth / 2) /
    parentScale),
  swingY = RoundCoordinate((
    mainTop + 227 - 12 * 0.82 * parentScale / 2 - parentHeight / 2
  ) / parentScale),
  stanceX = RoundCoordinate((mainCenterX - parentWidth / 2) /
    parentScale),
  stanceY = RoundCoordinate((mainTop + 64 - parentHeight) /
    parentScale),
  doiteX = RoundCoordinate((
    mainCenterX - 318 * 0.82 * doiteInheritedScale / 2
  ) / parentScale),
  doiteY = RoundCoordinate((mainTop + 287 - parentHeight) /
    parentScale),
}

AssertPosition("pfPlayer", "BOTTOM", expected.playerX, expected.unitY, 0.75)
AssertPosition("pfTarget", "BOTTOM", expected.targetX, expected.unitY, 0.75)
AssertPosition(
  "pfPlayerCastbar", "BOTTOM", expected.playerX, expected.castY, 0.75
)
AssertPosition(
  "pfTargetCastbar", "BOTTOM", expected.targetX, expected.castY, 0.75
)
AssertPosition(
  "pfSwingTimerMainhand", "CENTER", expected.swingX, expected.swingY, 0.82
)
AssertPosition(
  "pfSwingTimerRanged", "CENTER", expected.swingX, expected.swingY, 0.82
)
AssertPosition(
  "pfActionBarStances", "TOP", expected.stanceX, expected.stanceY, 0.82
)

-- V5 persists one-shot UIParent coordinates whose physical relationships are
-- resolved from live Bar 1 after the accepted deck reset.
local function Near(actual, expectedValue)
  assert(math.abs(actual - expectedValue) <= 1)
end
Near(parentWidth / 2 + expected.playerX * parentScale - mainCenterX, -159)
Near(parentWidth / 2 + expected.targetX * parentScale - mainCenterX, 160)
Near(expected.unitY * parentScale - mainTop, 106)
Near(expected.castY * parentScale - mainTop, 78)
Near(
  parentHeight / 2 + expected.swingY * parentScale +
    12 * 0.82 * parentScale / 2 - mainTop,
  227
)
Near(parentHeight + expected.stanceY * parentScale - mainTop, 64)
Near(parentHeight + expected.doiteY * parentScale - mainTop, 287)
Near(
  expected.doiteX * parentScale + 318 * 0.82 * doiteInheritedScale / 2,
  mainCenterX
)

assert(module.focusUnitScale == 0.75)
assert(module.focusReadoutScale == 0.82)
for _, frame in pairs({ player, target, playerCast, targetCast }) do
  assert(math.abs(frame.scale - 0.75) < 0.001)
end
for _, frame in pairs({
  swingMain, swingOffhand, swingRanged, stance, doite,
}) do
  assert(math.abs(frame.scale - 0.82) < 0.001)
end

for _, config in pairs({
  pfUI_config.unitframes.player,
  pfUI_config.unitframes.target,
}) do
  assert(config.width == "280")
  assert(config.height == "72")
  assert(config.buffs == "TOPLEFT")
  assert(config.debuffs == "TOPRIGHT")
  assert(config.buffperrow == "6")
  assert(config.debuffperrow == "6")
end
assert(player.updateConfigCalls == 1)
assert(target.updateConfigCalls == 1)
assert(player.updateSizeCalls == 1)
assert(target.updateSizeCalls == 1)

assert(pfUI_config.castbar.player.width == "-1")
assert(pfUI_config.castbar.player.height == "22")
assert(pfUI_config.castbar.target.width == "-1")
assert(pfUI_config.castbar.target.height == "22")
assert(playerCast.width == 280 and playerCast.height == 22)
assert(targetCast.width == 280 and targetCast.height == 22)

assert(pfUI_config.unitframes.swingtimerwidth == "200")
assert(pfUI_config.unitframes.swingtimerheight == "12")
assert(swingMain.width == 200 and swingMain.height == 12)
assert(swingOffhand.width == 200 and swingOffhand.height == 12)
assert(swingRanged.width == 200 and swingRanged.height == 12)
assert(swingOffhand.points[1][1] == "TOP")
assert(swingOffhand.points[1][2] == swingMain)
assert(swingOffhand.points[1][3] == "BOTTOM")
assert(swingOffhand.points[1][5] == -4)

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
assert(archiPoint[5] == -47)

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
assert(AzerothExpeditionUI.db.actionbars.combatFocusLayoutVersion == 5)
assert(AzerothExpeditionUI.db.actionbars.comfortUIScaleVersion == 2)

for _, frame in pairs({
  player, target, playerCast, targetCast, swingMain, swingOffhand,
  swingRanged, stance, mainBar, topBar, doite,
}) do
  assert(frame.alphaCalls == 0)
end
for _, frame in pairs({
  player, target, playerCast, targetCast, swingMain, swingRanged,
  stance,
}) do
  assert(frame.parent == nil)
end
assert(doite.parent == doiteParent)

local status = module:GetRuntimeStatus()
assert(string.find(status, "focus%-layout%-contract=1%.4"))
assert(string.find(status, "focus%-layout=applied"))
assert(string.find(status, "focus%-layout%-mouse=visible%-controls%-only"))
assert(string.find(status, "focus%-layout%-anchor=live%-bar1"))
assert(string.find(status, "focus%-layout%-unit%-scale=0%.75"))
assert(string.find(status, "focus%-layout%-readout%-scale=0%.82"))
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

print("action focus layout module smoke test passed")
