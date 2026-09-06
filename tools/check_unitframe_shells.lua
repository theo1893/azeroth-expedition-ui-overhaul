-- Run from the repository root: lua tools/check_unitframe_shells.lua
local Frame = {}
Frame.__index = Frame
local function frame()
  return setmetatable({ shown = true }, Frame)
end
function Frame:CreateTexture() return frame() end
function Frame:Show() self.shown = true end
function Frame:Hide() self.shown = false end
function Frame:IsShown() return self.shown end
function Frame:SetTexture(value) self.texture = value end
function Frame:SetTexCoord(...) self.uv = {...} end
function Frame:SetWidth(value) self.width = value end
function Frame:SetHeight(value) self.height = value end
function Frame:GetWidth() return self.width end
function Frame:GetHeight() return self.height end
function Frame:SetPoint(...) self.point = {...} end
function Frame:ClearAllPoints() end
function Frame:SetAllPoints() end
function Frame:SetFrameLevel() end
function Frame:SetFrameStrata() end
function Frame:SetVertexColor(...) self.colour = {...} end
function Frame:SetAlpha() end
function Frame:SetBackdrop() end
function Frame:GetBackdropBorderColor() return 0, 1, 0, 1 end
function Frame:GetDrawLayer() return self.layer or "BACKGROUND" end
function Frame:SetDrawLayer(layer) self.layer = layer end
function Frame:UpdateConfig()
  self.hp.backdrop:Show()
  self.power.backdrop:Show()
end
CreateFrame = frame
local routes = {
  ["unitframes.primary-thin-shell"] = "unitframes",
  ["unitframes.primary-aura-rim"] = "unitframes",
  ["unitframes.standalone-aura-rim"] = "unitframes",
  ["unitframes.raid-aura-rim"] = "unitframes",
}
pfUI = { uf = {}, GetExpeditionComponentOwner = function(_, key) return routes[key] end }
AzerothExpeditionUI = {
  media = {root = "Interface\\AddOns\\AzerothExpeditionUI\\Media\\"},
  db = {unitframes = {enabled = true}},
  RegisterModule = function(self, _, module) self.module = module end,
}
dofile("addon/AzerothExpeditionUI/Modules/UnitFrames.lua")
local module = AzerothExpeditionUI.module
for role, variant in pairs({player = "A", target = "B", targettarget = "C", focus = "D"}) do
  local unit = frame()
  local width = role == "focus" and 100 or 240
  unit.width = width
  unit.hp, unit.power = {backdrop = frame()}, {backdrop = frame()}
  for _, kind in ipairs({"buffs", "debuffs"}) do
    local button = frame()
    button.width, button.height = 15.33, 15.33
    button.backdrop = frame()
    button.texture, button.cd, button.stacks = {}, {}, {}
    unit[kind] = {button}
  end
  pfUI.uf[role] = unit
  for _, height in ipairs({61, 65, 59.5, 27}) do
    unit.height = height
    assert(module:ApplyThinShell(unit, role))
    local slices = unit.aeuiThinShellSlices
    assert(slices.top.height == 6 and slices.bottom.height == 6)
    assert(slices.topLeft.width == 6 and slices.top.width == width - 8)
    assert(slices.centre.height == height - 8)
    assert(slices.bottom.uv[4] == 37/64)
    assert(slices.topLeft.point[4] == -2 and slices.topLeft.point[5] == 2)
    assert(unit.width == width and unit.height == height)
    assert(not unit.hp.backdrop.shown and not unit.power.backdrop.shown)
    assert(string.find(unit.aeuiThinShell, "RaidMemberShell" .. variant .. "V1", 1, true))
    local button = unit.debuffs[1]
    assert(unit.aeuiAuraBorder == 2)
    assert(not button.backdrop.shown and button.aeuiAuraThinSlices.top.shown)
    assert(button.width == 15.33 and button.height == 15.33)
    assert(button.aeuiAuraThinSlices.topLeft.point[4] == -2)
    button:aeuiAuraTint(0, 0.6, 1)
    assert(button.aeuiAuraThinSlices.top.colour[2] == 0.6)
  end
  routes["unitframes.primary-thin-shell"] = nil
  unit:aeuiPrimaryRefreshVisual()
  assert(unit.hp.backdrop.shown and unit.power.backdrop.shown)
  assert(not unit.aeuiThinShell and not unit.aeuiThinShellSlices.top.shown)
  assert(unit.buffs[1].backdrop.shown and unit.debuffs[1].backdrop.shown)
  assert(not unit.debuffs[1].aeuiAuraThinSlices.top.shown)
  assert(not unit.debuffs[1].aeuiAuraTint)
  assert(unit.aeuiAuraBorder == nil)
  routes["unitframes.primary-thin-shell"] = "unitframes"
end
assert(not module:ApplyThinShell(pfUI.uf.target, "focus"))
local button = frame()
button.width, button.height = 32, 32
button.backdrop, button.backdrop_shadow, button.texture = frame(), frame(), frame()
button.mode = "HARMFUL"
pfUI.buff = {debuffs = {buttons = {button}}}
module:ApplyStandaloneAuraShells()
assert(button.texture.layer == "ARTWORK" and not button.backdrop.shown)
assert(not button.backdrop_shadow.shown and button.aeuiAuraThinSlices.top.colour[2] == 1)
button.mode = "HELPFUL"
button:aeuiAuraRefreshColour()
assert(button.aeuiAuraThinSlices.top.colour[1] == 1)
AzerothExpeditionUI.db.unitframes.enabled = false
module:ApplyStandaloneAuraShells()
assert(button.backdrop.shown and button.backdrop_shadow.shown)
assert(button.texture.layer == "BACKGROUND" and not button.aeuiAuraRefreshColour)
assert(not pfUI.buff.aeuiRefreshAuraShells)
assert(not module:ApplyThinShell(pfUI.uf.player, "player"))
assert(not module:IsPrimaryShellEnabled("target"))
print("PASS Raid A2 primary thin shells: geometry, variants, role isolation and fallback")

AzerothExpeditionUI.db.unitframes.enabled = true
local raid = {label = "player", buffs = {}, debuffs = {}}
for _, kind in ipairs({"buffs", "debuffs"}) do
  local icon = frame()
  icon.width, icon.height, icon.backdrop = 12, 12, frame()
  raid[kind][1] = icon
end
module:ApplyRaidAuraShells(raid)
assert(not raid.buffs[1].backdrop.shown and not raid.debuffs[1].backdrop.shown)
assert(raid.debuffs[1].aeuiAuraThinSlices.top.colour[2] == 1)
assert(raid.aeuiAuraBorder == nil) -- Preserve the raid provider's existing spacing.
raid.debuffs[1].width = 16
raid:aeuiRaidAuraRefresh()
assert(raid.debuffs[1].width == 16 and raid.debuffs[1].height == 12)
routes["unitframes.raid-aura-rim"] = nil
raid:aeuiRaidAuraRefresh()
assert(raid.buffs[1].backdrop.shown and raid.debuffs[1].backdrop.shown)
assert(not raid.aeuiRaidAuraRefresh and not raid.debuffs[1].aeuiAuraTint)
print("PASS raid auras: solo alias, native geometry/spacing, refresh, debuff tint and route fallback")

-- Raid object identity survives solo/party aliases and the provider's preview.
function Frame:SetStatusBarTexture(texture) self.barTexture = texture end
pfUI.media = { ["img:bar"] = "native" }
local member = frame()
member.width, member.height = 70, 33
member.config = {}
member.hp = {bar = frame(), backdrop = frame()}
member.power = {bar = frame(), backdrop = frame()}
pfUI.uf.raid = {member}
for _, label in ipairs({"raid", "player", "party", "raid"}) do
  member.label = label
  assert(module:ApplyFrame(member))
  assert(module:ApplyRaidFrame(member, 1), "raid shell rejected alias " .. label)
  member.hp.backdrop:Show()
  member.power.backdrop:Show()
  -- Execute the actual callback dispatch at the end of provider UpdateConfig.
  local file = assert(io.open("addon/pfUI/api/unitframes.lua", "r"))
  local source = file:read("*a")
  file:close()
  local dispatch = assert(source:match("  %-%- AEUI may attach a narrowly scoped Raid media refresh callback%..-(  if.-)  %-%- AEUI may likewise"))
  local loader = loadstring or load
  assert(loader("local f = ...\n" .. dispatch))(member)
  assert(not member.hp.backdrop.shown and not member.power.backdrop.shown,
    "provider skipped raid refresh for " .. label)
  assert(member.aeuiRaidShellTextures.full.shown)
  assert(member.hp.bar.barTexture == member.aeuiHealthBarTexture)
end
assert(not module:ApplyRaidFrame(pfUI.uf.player, 1))
module:RestoreRaidFrame(member)
module:RestoreFrame(member)
assert(member.hp.backdrop.shown and member.power.backdrop.shown)
assert(member.hp.bar.barTexture == "native" and not member.aeuiRaidRefreshVisual)
assert(not member.aeuiRaidShellTextures.full.shown)
print("PASS raid skin: roster aliases, provider refresh, object isolation and restore")
