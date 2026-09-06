-- lua tools/test_readout_art.lua
local Node = {}; Node.__index = Node
local function node(texture)
  return setmetatable({texture = texture, shown = true, points = {}}, Node)
end
function Node:Show() self.shown = true end
function Node:Hide() self.shown = false end
function Node:IsShown() return self.shown end
function Node:CreateTexture() return node() end
function Node:SetTexture(value) self.texture = value end
function Node:GetTexture() return self.texture end
function Node:SetStatusBarTexture(value) self.fill.texture = value end
function Node:GetStatusBarTexture() return self.fill end
function Node:SetAllPoints() end
function Node:SetTexCoord(...) self.uv = {...} end
function Node:SetPoint(point, relative, anchor, x, y)
  self.points[point] = {relative = relative, anchor = anchor, x = x, y = y}
end
local function bar()
  local frame = node()
  frame.fill, frame.backdrop, frame.backdrop_shadow = node("original"), node(), node()
  frame.value, frame.colour, frame.width, frame.height = 0.4, "provider", 260, 12
  return frame
end
AzerothExpeditionUI = {media = {root = "test/"}, db = {actionbars = {enabled = true}},
  RegisterModule = function(self, _, module) self.module = module end}
local owned = true
pfUI = {GetExpeditionComponentOwner = function() return owned and "actionbars" end,
  castbar = {player = {bar = bar(), icon = bar()}, target = {bar = bar(), icon = bar()},
    focus = {bar = bar(), icon = bar()}},
  swingtimer = {mainhand = bar(), offhand = bar(), ranged = bar()}}
for _, key in ipairs({"left", "right", "warn"}) do
  pfUI.swingtimer.ranged[key] = node("original-" .. key)
end
dofile("addon/AzerothExpeditionUI/Modules/ReadoutArt.lua")
local art = AzerothExpeditionUI.module
local focus = pfUI.castbar.focus
focus.bar.width, focus.bar.height = 180, 10
art:Apply()
assert(art.appliedCount == 6)
assert(focus.bar.fill.texture == "test/ActionBars\\Readouts\\CastFillV1")
assert(focus.bar.width == 180 and focus.bar.height == 10)
assert(focus.icon.aeuiReadoutArt.active and not focus.icon.backdrop.shown)
local cast = pfUI.castbar.player.bar
assert(cast.fill.texture == "test/ActionBars\\Readouts\\CastFillV1")
assert(cast.value == 0.4 and cast.colour == "provider" and cast.width == 260 and cast.height == 12)
assert(not cast.backdrop.shown and not cast.backdrop_shadow.shown)
-- The center anchors span the provider; resizing never depends on cached dimensions.
local centre = cast.aeuiReadoutArt.slices[5]
assert(centre.points.TOPLEFT.anchor == "TOPLEFT" and centre.points.TOPLEFT.x == 3)
assert(centre.points.BOTTOMRIGHT.anchor == "BOTTOMRIGHT" and centre.points.BOTTOMRIGHT.x == -3)
assert(centre.uv[3] == 1/16 and centre.uv[4] == 13/16)
art:Apply() -- must not overwrite the original texture/backdrop snapshot
owned = false
art:Apply()
assert(cast.fill.texture == "original" and cast.backdrop.shown and cast.backdrop_shadow.shown)
assert(not centre.shown)
assert(focus.bar.fill.texture == "original" and focus.bar.backdrop.shown)
assert(not focus.icon.aeuiReadoutArt.active and focus.icon.backdrop.shown)
assert(pfUI.swingtimer.ranged.warn.texture == "original-warn")
pfUI.castbar, pfUI.swingtimer = nil, nil
art:Apply()
assert(art.appliedCount == 0)
print("PASS readout art: geometry, provider state, repeat apply, route fallback and missing provider")

-- Migrate the preceding castbar order once, without moving custom layouts.
GetGlobal = function() end
UIParent = {}
function Node:ClearAllPoints() self.points = {} end
function Node:SetScale(value) self.scale = value end
dofile("addon/AzerothExpeditionUI/Modules/ActionBars.lua")
local actionbars = AzerothExpeditionUI.module
pfUI.castbar = {player = node(), target = node()}
pfUI_config = {position = {
  pfPlayerCastbar = {anchor = "BOTTOM", parent = "UIParent", xpos = 0, ypos = 316, scale = 1},
  pfTargetCastbar = {anchor = "BOTTOM", parent = "UIParent", xpos = 0, ypos = 300, scale = 1},
}}
InCombatLockdown = function() return true end
assert(not actionbars:MigrateFocusCastbarOrder())
InCombatLockdown = function() return false end
assert(actionbars:MigrateFocusCastbarOrder())
assert(pfUI_config.position.pfPlayerCastbar.ypos == 300)
assert(pfUI_config.position.pfTargetCastbar.ypos == 316)
assert(pfUI.castbar.player.points.BOTTOM.y == 300)
assert(pfUI.castbar.target.points.BOTTOM.y == 316)
assert(actionbars.focusSwingY == 284)
assert(not actionbars:MigrateFocusCastbarOrder())
pfUI_config.position.pfPlayerCastbar.ypos = 320
assert(not actionbars:MigrateFocusCastbarOrder())
assert(pfUI_config.position.pfPlayerCastbar.ypos == 320)
print("PASS castbar order: saved/live positions, combat guard, repeat apply and custom positions")

unpack = unpack or table.unpack
function Node:SetVertexColor(...) self.tint = {...} end
function Node:SetHeight(value) self.height = value end
function Node:SetBackdrop(value) self.nativeBackdrop = value end
function Node:GetBackdrop() return self.nativeBackdrop end
function Node:SetBackdropColor(...) self.background = {...} end
function Node:GetBackdropColor() return unpack(self.background) end
function Node:SetBackdropBorderColor(...) self.border = {...} end
function Node:GetBackdropBorderColor() return unpack(self.border) end
local function doiteIcon()
  local frame = node()
  frame.nativeBackdrop = {edgeFile = "native"}
  frame.background, frame.border = {.01,.02,.03,.88}, {.2,.9,.3,1}
  frame.actionKey, frame.time, frame.width = "LIGHTNING_BOLT", "1.5", 34
  return frame
end
local future = doiteIcon()
DoiteDPS = {UI = {readySlot = doiteIcon(), currentIcon = doiteIcon(),
  currentGhost = doiteIcon(), resourceRoot = doiteIcon(), tankAssistBadge = doiteIcon(),
  forecastIcons = {future}, resourceIcons = {doiteIcon()}, track = node(), railShadow = node()}}
owned = true
art:ApplyDoite()
assert(future.nativeBackdrop == nil and future.aeuiReadoutArt.active)
future:SetBackdropBorderColor(1,.55,.12,1)
assert(future.aeuiDoiteSkin.signal.texture == 1)
assert(future.aeuiDoiteSkin.border[2] == .55 and future.aeuiDoiteSkin.signal.shown)
assert(not DoiteDPS.UI.currentIcon.aeuiReadoutArt.bed.shown)
assert(not DoiteDPS.UI.currentGhost.aeuiReadoutArt.slices[1].shown)
assert(not DoiteDPS.UI.railShadow.shown)
assert(DoiteDPS.UI.readySlot.aeuiReadoutArt.slices[1].points.TOPLEFT.relative == DoiteDPS.UI.currentIcon)
art:ApplyDoite()
assert(future.actionKey == "LIGHTNING_BOLT" and future.time == "1.5" and future.width == 34)
assert(DoiteDPS.UI.track.aeuiDoiteRail.shown)
owned = false
art:ApplyDoite()
assert(future.nativeBackdrop.edgeFile == "native" and future.border[2] == .55)
assert(not future.aeuiReadoutArt.active and not DoiteDPS.UI.track.aeuiDoiteRail.shown)
assert(DoiteDPS.UI.railShadow.shown and not future.aeuiDoiteSkin.signal.shown)
DoiteDPS = nil
art:ApplyDoite()
print("PASS DDPS art: dynamic colors, native geometry/content, repeat apply, restoration and absent provider")

function Node:SetDrawLayer(value) self.layer = value end
local aura, excluded = bar(), bar()
aura.icon, excluded.icon = node("spell"), node("bar")
local auraGlobals = {DoiteIcon_spell = aura, DoiteIcon_bar = excluded}
getglobal = function(name) return auraGlobals[name] end
DoiteAurasDB = {spells = {spell = {type = "Buff"}, bar = {type = "Bar"}}}
owned = true
art:ApplyDoiteAuras()
assert(not aura.backdrop.shown and not aura.aeuiReadoutArt.bed.shown)
assert(aura.aeuiReadoutArt.slices[1].layer == "ARTWORK" and not aura.aeuiReadoutArt.slices[5].shown)
assert(not excluded.aeuiReadoutArt and aura.icon.texture == "spell")
local firstArt = aura.aeuiReadoutArt
art:ApplyDoiteAuras()
assert(aura.aeuiReadoutArt == firstArt)
aura.backdrop = node() -- Provider rebuilds its border from settings.
art:ApplyDoiteAuras()
assert(not aura.backdrop.shown)
owned = false
art:ApplyDoiteAuras()
assert(aura.backdrop.shown and not firstArt.slices[1].shown)
print("PASS DoiteAuras: icon layer, bar exclusion, rebuilt border, repeat apply and restoration")
