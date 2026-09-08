-- Run from repository root: lua tools/tests/nameplate_modes.lua
-- Focused adapter/provider checks; the client remains the rendering authority.
local function noop() end
unpack = unpack or table.unpack
math.mod = math.mod or math.fmod
strlower, strfind, strlen = string.lower, string.find, string.len
floor, ceil = math.floor, math.ceil
local now, playerName, victim = 10, "First", "self"
local targetGuid, targetName
local nodes = {}
local function node()
  local n = { shown = true, scripts = {}, calls = {}, width = 120, height = 8 }
  setmetatable(n, { __index = function(self, key)
    if not string.find(key, "^%u") then return nil end
    local method = function(object, ...)
      object.calls[key] = (object.calls[key] or 0) + 1
    end
    self[key] = method
    return method
  end })
  function n:GetParent() return self.parent end
  function n:SetParent(parent) self.parent = parent; self.calls.SetParent = (self.calls.SetParent or 0) + 1 end
  function n:SetScript(event, callback) self.scripts[event] = callback end
  function n:GetScript(event) return self.scripts[event] end
  function n:Show() self.shown = true end
  function n:Hide() self.shown = false end
  function n:IsShown() return self.shown end
  function n:IsVisible() return self.shown end
  function n:GetText() return self.text or "Friend" end
  function n:SetText(text) self.text = text end
  function n:SetTexture(texture) self.texture = texture; self.calls.SetTexture = (self.calls.SetTexture or 0) + 1 end
  function n:GetTextColor() return 0, 1, 0 end
  function n:GetStatusBarColor() return 0, 0, 1 end
  function n:GetValue() return 100 end
  function n:GetMinMaxValues() return 0, 100 end
  function n:GetObjectType() return "FontString" end
  function n:GetWidth() return self.width end
  function n:GetHeight() return self.height end
  function n:GetScale() return 1 end
  function n:GetFrameLevel() return 1 end
  function n:GetAlpha() return 1 end
  function n:GetName() return self.guid end
  function n:IsMouseEnabled() return false end
  function n:CreateTexture() return node() end
  return n
end
function CreateFrame(_, name, parent)
  local n = node(); n.parent = parent
  if name then _G[name] = n end
  nodes[#nodes + 1] = n
  return n
end
UIParent = node()
function GetTime() return now end
function GetRealmName() return "Realm" end
function UnitName(unit)
  if unit == "player" then return playerName end
  if unit == "target" then return targetName end
  if string.find(unit, "target$") then return victim end
  return "Friend"
end
function UnitExists(unit)
  if unit == "target" then return targetGuid ~= nil, targetGuid end
  if unit == "mouseover" then return false end
  return true, unit
end
function GetUnitGUID(unit) return unit end
function GetNampowerVersion() return 3, 0, 0 end
function UnitAffectingCombat() return true end
function UnitCanAttack(_, unit) return unit == "enemy" end
function UnitCanAssist() return true end
function UnitIsPlayer() return true end
function UnitIsUnit(unit, other) return other == "player" and unit == "enemytarget" and victim == "self" end
function UnitIsTapped() return false end
function GetUnitData() return "MAGE", 60, nil, true end
function GetGuildInfo() return nil end
function GetStringColor() return .2, .2, .2, 1 end
function strsplit(_, value) return value end
function round(value) return math.floor(value + .5) end
SetCVar, ShowNameplates, HideNameplates = noop, noop, noop
ShowFriendNameplates, HideFriendNameplates = noop, noop
RAID_CLASS_COLORS = { MAGE = { r = .4, g = .8, b = 1 } }
L = { totems = {}, critters = {} }
C = {
  global = { font_size = 12 },
  nameplates = setmetatable({ blacklist = "", showhp = "1", showcastbar = "1",
    targetcastbar = "1", friendclassnamec = "1", friendlyplayer = "1", target = "1",
    showdebuffs = "1", showdebuffs_friendly = "1", showdebuffs_hostile = "1",
    debuffs = { filter = "none", position = "TOP", showstacks = "0" },
    name = { abbreviate = "0" }, hptextformat = "percent" }, { __index = function() return "0" end }),
  unitframes = {},
}
pfUI_config = { unitframes = {}, appearance = { border = { color = "" } } }
pfUI = { api = {}, client = 11200, uf = { raid = { tankrole = { tank = true } } },
  libdebuff_casts = {}, media = {},
  throttle = { Get = function(_, category) return category == "nameplates_target" and .02 or .1 end },
  GetExpeditionComponentOwner = function() return "unitframes" end,
  RegisterModule = function(_, _, _, callback) callback() end,
}
AzerothExpeditionUI = { media = { root = "" }, db = { unitframes = { enabled = true } }, modules = {},
  Print = noop, RegisterModule = function(self, name, module) self.modules[name] = module end }
dofile("addon/AzerothExpeditionUI/Modules/UnitFrames.lua")
dofile("addon/pfUI/modules/nameplates.lua")
local adapter, provider = AzerothExpeditionUI.modules.UnitFrames, pfUI.nameplates
-- Initialize provider config through its real event handler.
this, event = provider, "PLAYER_ENTERING_WORLD"
provider.scripts.OnEvent()
event = nil

local profile = adapter:GetNameplateProfile()
assert(profile.mode == "dps")
profile.mode = "tank"
playerName = "Second"
assert(adapter:GetNameplateProfile().mode == "dps")
playerName = "First"
assert(adapter:GetNameplateProfile() == profile and profile.mode == "tank")
adapter:ApplyNameplateMode()
assert(provider.combatMode == "tank")
profile.mode = "off"; adapter:ApplyNameplateMode()
assert(provider.combatMode == nil and not adapter:IsNameplateTargetCueEnabled())
profile.mode = "dps"; adapter:ApplyNameplateMode()
AzerothExpeditionUI.db.unitframes.enabled = false; adapter:ApplyNameplateMode()
assert(provider.combatMode == nil and profile.mode == "dps")
AzerothExpeditionUI.db.unitframes.enabled = true; adapter:ApplyNameplateMode()

for _, mode in ipairs({ "tank", "healer", "dps" }) do
  local alpha, colour, limit = adapter:GetNameplateStyle(mode, true, false, "self")
  assert(alpha == .65 and colour == nil and limit == 0)
  alpha, colour, limit = adapter:GetNameplateStyle(mode, true, true)
  assert(alpha == 1 and limit == 4)
  assert(select(3, adapter:GetNameplateStyle(mode, false, true)) == 6)
  assert(select(3, adapter:GetNameplateStyle(mode, false, false)) == 2)
end
local _, danger = adapter:GetNameplateStyle("dps", false, false, "self")
assert(danger == select(2, adapter:GetNameplateStyle("tank", false, false, "other")))
assert(select(2, adapter:GetNameplateStyle("dps", false, false, "other")) == nil)
assert(select(2, adapter:GetNameplateStyle("tank", false, false, nil)) == nil)
assert(adapter:GetNameplateAuraPriority(false, false, "debuff", "Polymorph", "other") == 1)
assert(adapter:GetNameplateAuraPriority(false, false, "debuff", "Corruption", "player") == nil)
assert(adapter:GetNameplateAuraPriority(false, true, "debuff", "Corruption", "player") == 2)
assert(adapter:GetNameplateAuraPriority(true, false, "buff", "Ice Block") == nil)

local threatPlate = { cachedGuid = "enemy" }
assert(provider:GetRoleThreat(threatPlate, "enemy") == "self")
victim = "other"
pfUI.libdebuff_casts.enemy = { endTime = now + 2 }
assert(provider:GetRoleThreat(threatPlate, "enemy") == "self", "spell target must not report lost threat")
pfUI.libdebuff_casts.enemy = nil
assert(provider:GetRoleThreat(threatPlate, "enemy") == "other")
victim = "tank"
assert(provider:GetRoleThreat(threatPlate, "enemy") == "tank")
assert(provider:GetRoleThreat(threatPlate, nil) == nil)

-- Repeated hidden/selected cue updates must not repeatedly bind textures.
local cuePlate = { aeuiTargetCueFrame = { texture = node() } }
for i = 1, 100 do adapter:EnsureNameplateTargetCue(cuePlate) end
assert(cuePlate.aeuiTargetCueFrame.texture.calls.SetTexture == 1)
assert(cuePlate.aeuiTargetCueFrame.texture.calls.SetTexCoord == 1)
adapter:RestoreNameplateTargetCue({})

local parent, plate = node(), node()
parent.nameplate, parent.guid = plate, "friend"
plate.parent, plate.cachedGuid, plate.cache = parent, "friend", {}
plate.original = { healthbar = node(), name = node(), level = node(), glow = node(), levelicon = node() }
plate.original.level.text = "60"
plate.original.levelicon:Hide(); plate.original.glow:Hide()
for _, field in ipairs({ "name", "level", "guild", "health", "glow", "targetname", "totem", "castbar", "raidicon", "cluster" }) do
  plate[field] = node()
end
plate.health.backdrop, plate.health.text, plate.totem.icon = node(), node(), node()
plate.raidicon:Hide(); plate.castbar:Hide()
plate.debuffs, plate.combopoints = {}, {}
for i = 1, 5 do plate.combopoints[i] = node() end
local auraReads = 0
libdebuff = { UnitDebuff = function() auraReads = auraReads + 1 end }
provider:OnDataChanged(plate)
assert(plate.namesOnly and not plate.health:IsShown() and plate.name:IsShown())
assert(plate.health.calls.SetValue == nil and auraReads == 0, "names-only must skip hidden health and auras")
local parentWrites = plate.name.calls.SetParent
provider:OnDataChanged(plate)
assert(plate.name.calls.SetParent == parentWrites, "stable names-only layout must not reparent")
this = { GetParent = function() return parent end }
provider.OnValueChanged()
assert(not plate.healthUpdate, "hidden friendly health events must not schedule full work")

-- A target transition bypasses throttle and must show the bar immediately.
targetGuid, targetName = "friend", "Friend"
plate.lasttick = now
local state = { now = now, hasTarget = true, targetGuid = targetGuid, hasMouseover = false }
provider.OnUpdate(parent, state)
assert(plate.istarget and not plate.namesOnly and plate.health:IsShown())
assert(plate.health.calls.SetValue == 1)
local healthWrites = plate.health.calls.SetValue
provider.OnValueChanged(); provider.OnValueChanged()
assert(plate.health.calls.SetValue == healthWrites, "health events should coalesce")
state.now, now = now + .03, now + .03
provider.OnUpdate(parent, state)
assert(plate.health.calls.SetValue == healthWrites + 1)
-- No colour-cache ping-pong despite friendly class-name colouring.
healthWrites = plate.health.calls.SetValue
state.now, now = now + .03, now + .03
provider.OnUpdate(parent, state)
assert(plate.health.calls.SetValue == healthWrites, "class colours must not trigger a full refresh every tick")
-- Conflicting authoritative GUIDs must not fall back to the original alpha=1.
targetGuid, targetName = "different", "Other"
state.targetGuid = targetGuid
provider.OnUpdate(parent, state)
assert(not plate.istarget and plate.namesOnly and not plate.health:IsShown())
-- Actual aura packing: late control and immunity displace early maintenance.
plate.istarget = true
targetName = "Friend"
function plate.original.healthbar:GetStatusBarColor() return 1, 0, 0 end
for i = 1, 16 do
  plate.debuffs[i] = node()
  plate.debuffs[i].icon, plate.debuffs[i].stacks, plate.debuffs[i].cd = node(), node(), node()
end
function libdebuff:UnitDebuff(_, slot)
  if slot > 8 then return end
  return slot == 8 and "Polymorph" or "Corruption", nil, "debuff" .. slot, 1, nil, nil, nil, "player"
end
function plate:UnitBuff(_, slot)
  if slot == 1 then return "Ice Block", "immunity", 1 end
end
provider:OnDataChanged(plate)
assert(plate.debuffs[1].icon.texture == "debuff8")
assert(plate.debuffs[2].icon.texture == "immunity")
assert(plate.debuffs[6]:IsShown() and not plate.debuffs[7]:IsShown())
plate.istarget = nil
provider:OnDataChanged(plate)
assert(plate.debuffs[1].icon.texture == "debuff8" and plate.debuffs[2].icon.texture == "immunity")
assert(not plate.debuffs[3]:IsShown())
-- Missing live aura data hides stale icons, without inventing statuses.
plate.cachedGuid = nil
function parent:GetName() return nil end
provider:OnDataChanged(plate)
assert(not plate.debuffs[1]:IsShown())
print("PASS nameplate modes: profiles, roles, threat, aura priority, cue caching, names-only, event coalescing, target transitions")
