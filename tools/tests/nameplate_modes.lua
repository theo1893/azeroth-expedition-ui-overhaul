-- Run from repository root: lua tools/tests/nameplate_modes.lua
-- Focused adapter/provider checks; the client remains the rendering authority.
local function noop() end
UnitCastingInfo, UnitChannelInfo = noop, noop
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
  function n:SetPoint(...) self.point = {...}; self.pointsByAnchor = self.pointsByAnchor or {}; if self.point[1] then self.pointsByAnchor[self.point[1]] = self.point end; self.calls.SetPoint = (self.calls.SetPoint or 0) + 1 end
  function n:GetDrawLayer() return self.layer or "BACKGROUND" end
  function n:SetDrawLayer(layer) self.layer=layer end
  function n:GetFont() return unpack(self.font or {"default",14,"OUTLINE"}) end
  function n:SetFont(...) self.font={...} end
  function n:CreateFontString() return node() end
  function n:GetNumPoints() return self.point and 1 or 0 end
  function n:GetPoint() return unpack(self.point or {}) end
  function n:GetStringWidth() return #(self.text or '') * 5 end
  function n:GetJustifyH() return self.justify or 'RIGHT' end
  function n:SetJustifyH(value) self.justify=value end
  function n:SetWidth(value) self.width=value end
  function n:SetHeight(value) self.height=value end
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
  function n:GetScale() return self.scale or 1 end
  function n:SetScale(value) self.scale=value; self.calls.SetScale=(self.calls.SetScale or 0)+1 end
  function n:SetAlpha(value) self.alpha=value end
  function n:GetFrameLevel() return 1 end
  function n:GetAlpha() return self.alpha or 1 end
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
assert(provider.combatMode == "tank" and provider.combatHealthHeight == 18)
profile.mode = "off"; adapter:ApplyNameplateMode()
assert(provider.combatMode == nil and provider.combatHealthHeight == nil and not adapter:IsNameplateTargetCueEnabled())
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
local neutral = select(2, adapter:GetNameplateStyle("dps", false, false, "other"))
assert(neutral[3] > neutral[1] and neutral ~= danger, 'ordinary enemies must be cool-coloured, distinct from danger')
assert(select(2, adapter:GetNameplateStyle("healer", false, false, nil)) == neutral,
  'healer/dps share a neutral fallback even without threat data')
assert(neutral[1]==54/255 and neutral[2]==191/255 and neutral[3]==224/255)
assert(adapter:GetNameplateStyle("healer", false, false, nil)==.75)
assert(adapter:GetNameplateStyle("dps", false, false, "self")==1)
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

local r, g, b, a = adapter:GetNameplateHealthColour(.2, .1, .05, .7)
assert(math.abs(r-.65)<.001 and math.abs(g/r-.5)<.001 and a==.7, "brightness floor preserves hue and alpha")
assert(select(1, adapter:GetNameplateHealthColour(1,.2,.1,1))==1)
AzerothExpeditionUI.db.unitframes.enabled=false
assert(adapter:GetNameplateHealthHeight()==nil)
assert(select(1, adapter:GetNameplateHealthColour(.2,.1,.05,1))==.2)
AzerothExpeditionUI.db.unitframes.enabled=true

-- Only the actual health fill is replaced; changed provider settings survive rollback.
local fillPlate = { health = node(), castbar = node() }
local health = fillPlate.health
health.backdrop, health.backdrop_shadow = node(), node()
health.backdrop_shadow:Hide()
function health.backdrop:GetBackdropColor() return .1,.1,.1,.8 end
health.fill = "native-A"
function health:GetStatusBarTexture() return self.fill end
function health:SetStatusBarTexture(path) self.fill = path; self.fillWrites = (self.fillWrites or 0) + 1 end
profile.mode = "dps"
assert(adapter:ApplyNameplateHealthFill(fillPlate))
assert(health.fill == "ActionBars\\Readouts\\CastFillV1")
assert(not health.backdrop:IsShown() and not health.backdrop_shadow:IsShown())
assert(health.aeuiNameplateChrome.bed:IsShown(), "border removal must retain empty-health bed")
assert(health.aeuiNameplateChrome.rim.top:IsShown(), "leather rim connects the end clasps")
local bedAnchors = health.aeuiNameplateChrome.bed.calls.SetAllPoints
local fillWrites = health.fillWrites
adapter:ApplyNameplateHealthFill(fillPlate)
assert(health.fillWrites == fillWrites, "unchanged fill must not rebind")
assert(health.aeuiNameplateChrome.bed.calls.SetAllPoints == bedAnchors)
assert(health.calls.SetStatusBarColor == nil and fillPlate.castbar.calls.SetStatusBarTexture == nil)
health.fill = "native-B" -- pfUI OnConfigChange resets its configured texture first.
adapter:ApplyNameplateHealthFill(fillPlate)
profile.mode = "off"; adapter:ApplyNameplateHealthFill(fillPlate)
assert(health.fill == "native-B" and health.aeuiNameplateHealthTexture == nil)
assert(health.backdrop:IsShown() and not health.backdrop_shadow:IsShown() and not health.aeuiNameplateChrome.bed:IsShown(), "fallback restores original chrome visibility")
assert(not health.aeuiNameplateChrome.rim.top:IsShown(), "fallback removes leather rim")
profile.mode = "dps"; adapter:ApplyNameplateHealthFill(fillPlate)
AzerothExpeditionUI.db.unitframes.enabled = false
adapter:ApplyNameplateHealthFill(fillPlate)
assert(health.fill == "native-B")
AzerothExpeditionUI.db.unitframes.enabled = true
assert(not adapter:ApplyNameplateHealthFill(nil))

-- Native texture regions must render above the opaque bed, with rollback.
local layeredBar, nativeFill = node(), node()
nativeFill.texture="native-fill"
function nativeFill:GetTexture() return self.texture end
function layeredBar:GetStatusBarTexture() return nativeFill end
function layeredBar:SetStatusBarTexture(path) nativeFill:SetTexture(path) end
adapter:SetNameplateBarFill(layeredBar,true)
assert(nativeFill:GetDrawLayer()=="ARTWORK", "bed must not occlude native fill")
adapter:SetNameplateBarFill(layeredBar,true)
adapter:SetNameplateBarFill(layeredBar,false)
assert(nativeFill:GetDrawLayer()=="BACKGROUND" and nativeFill.texture=="native-fill")

-- Detail skins share accepted material and restore native icon/text presentation.
local detail={health=node(), name=node(), guild=node(), cluster=node(), castbar=node(), totem=node(), debuffs={}, combopoints={}}
local cast=detail.castbar
cast:SetHeight(12); cast.text,cast.spell,cast.icon,cast.backdrop=node(),node(),node(),node()
cast.text:SetPoint("RIGHT",cast,"LEFT",-4,0); cast.spell:SetPoint("CENTER",cast,"CENTER",0,0)
cast.icon.tex,cast.icon.backdrop=node(),node(); cast.icon:SetWidth(24); cast.icon:SetHeight(24)
cast.fill="native-cast"
function cast:GetStatusBarTexture() return self.fill end
function cast:SetStatusBarTexture(path) self.fill=path; self.fillWrites=(self.fillWrites or 0)+1 end
detail.totem.icon,detail.totem.backdrop=node(),node()
detail.debuffs[1]=node(); detail.debuffs[1].icon=node(); detail.debuffs[1]:SetHeight(20)
detail.combopoints[1]=node(); detail.combopoints[1].tex,detail.combopoints[1].backdrop=node(),node()
adapter:ApplyNameplateDetails(detail)
assert(cast.fill=="ActionBars\\Readouts\\CastFillV1" and not cast.backdrop:IsShown())
assert(cast.text.point[2]==cast and cast.text.point[3]=="RIGHT" and cast.spell.justify=="LEFT")
assert(not cast.icon.backdrop:IsShown() and detail.debuffs[1].aeuiAuraThinSlices.top:IsShown())
assert(detail.debuffs[1].icon.layer=="ARTWORK", "native aura artwork stays above its rim")
assert(not detail.combopoints[1].tex:IsShown() and detail.combopoints[1].aeuiCopperPip:IsShown())
local castRim=cast.aeuiNameplateChrome.rim
assert(castRim.top.pointsByAnchor.TOPLEFT[2]==cast and castRim.bottom.pointsByAnchor.BOTTOMRIGHT[2]==cast)
assert(castRim.left.pointsByAnchor.TOPLEFT[3]=="TOPLEFT" and castRim.left.pointsByAnchor.BOTTOMRIGHT[3]=="BOTTOMLEFT",
  "rim must track live top AND bottom instead of a cached height")
assert(castRim.top.calls.SetHeight==nil and castRim.left.calls.SetHeight==nil,
  "native bar size must be the sole vertical authority")
local detailWrites=cast.text.calls.SetPoint
local rimWrites=cast.aeuiNameplateChrome.rim.top.calls.SetPoint
adapter:ApplyNameplateDetails(detail)
assert(cast.text.calls.SetPoint==detailWrites and cast.aeuiNameplateChrome.rim.top.calls.SetPoint==rimWrites,
  "stable data updates must not relayout the cast rail")
assert(detail.cluster.point[4]==30)
cast:Hide(); adapter:LayoutNameplateDetails(detail); assert(detail.cluster.point[4]==12)
profile.mode="off"; adapter:ApplyNameplateDetails(detail)
assert(cast.fill=="native-cast" and cast.backdrop:IsShown() and cast.icon.backdrop:IsShown())
assert(cast.text.point[3]=="LEFT" and not detail.debuffs[1].aeuiAuraThinSlices.top:IsShown())
assert(detail.debuffs[1].icon.layer=="BACKGROUND")
assert(detail.combopoints[1].tex:IsShown() and not detail.combopoints[1].aeuiCopperPip:IsShown())
profile.mode="dps"

-- Full strip remains fixed while the real StatusBar excludes the level area.
local identity = node()
identity.health, identity.name, identity.level, identity.totem, identity.castbar = node(), node(), node(), node(), node()
identity.totem:Hide()
identity.level:SetParent(identity)
identity.health.text = node()
identity.health:SetPoint("TOP", identity.name, "BOTTOM", 0, -4)
identity.level:SetPoint("RIGHT", identity.health, "LEFT", -5, 0)
identity.castbar:SetPoint("TOPLEFT", identity.health, "BOTTOMLEFT", 0, -3)
identity.name:SetText("Training Dummy"); identity.level:SetText("60")
adapter:RefreshNameplateIdentity(identity)
assert(identity.aeuiIdentity.active and identity.health.width == 101)
assert(identity.level:GetParent()==identity.health, "level must draw above the bed")
assert(math.abs(select(2,identity.level:GetFont())-11.9)<.001)
assert(identity.aeuiIdentity.names[1].height>=identity.name:GetHeight()+6)
assert(identity.aeuiIdentity.divider.width==3 and identity.aeuiIdentity.divider.height==16)
assert(identity.level.point[2] == identity.aeuiIdentity.bounds and identity.health.text.justify == "CENTER")
assert(identity.castbar.point[2] == identity.aeuiIdentity.bounds, "castbar must retain full-strip alignment")
local identityWrites=identity.health.calls.SetPoint
adapter:RefreshNameplateIdentity(identity)
assert(identity.health.calls.SetPoint==identityWrites, "stable identity must not relayout")
identity.level:SetText("60+"); adapter:RefreshNameplateIdentity(identity)
assert(identity.health.width==96 and identity.health.aeuiIdentityWidth==120)
local originalHealthHeight=identity.health.height
identity.threatRail=node()
adapter:RefreshNameplateIdentity(identity)
assert(identity.health.height==originalHealthHeight,'threat extension must not stretch health')
assert(identity.aeuiIdentity.bounds.pointsByAnchor.BOTTOMRIGHT[5]==-8,'common shell extends down by 8')
assert(identity.aeuiIdentity.caps.LEFT.height==originalHealthHeight+10,'caps enclose both areas')
assert(identity.castbar.point[2]==identity.aeuiIdentity.bounds,'cast follows extended shell')
local extendedWrites=identity.health.calls.SetPoint
adapter:RefreshNameplateIdentity(identity)
assert(identity.health.calls.SetPoint==extendedWrites,'steady threat must not rewrite layout')
identity.threatRail:Hide(); adapter:RefreshNameplateIdentity(identity)
assert(identity.aeuiIdentity.bounds.pointsByAnchor.BOTTOMRIGHT[5]==0,'missing threat collapses shell')
identity.health.text:SetText("7.07m / 55m extended readout")
adapter:RefreshNameplateIdentity(identity)
assert(identity.health.width >= identity.health.text:GetStringWidth()+12, "full readout must fit without ellipsis")
local expandedWidth=identity.health.width
identity.health.text:SetText("1%")
adapter:RefreshNameplateIdentity(identity)
assert(identity.health.width==expandedWidth, "shorter tick must not shrink and jitter")
identity.namesOnly=true; identity.health:Hide()
adapter:RefreshNameplateIdentity(identity)
assert(not identity.aeuiIdentity.active and identity.health.width==120 and identity.level:GetParent()==identity)
assert(identity.level.point[2]==identity.name, "names-only must retain native name anchor")
assert(select(2,identity.level:GetFont())==14, "fallback restores level font")
assert(identity.castbar.point[2]==identity.health)
identity.namesOnly=false; identity.health:Show(); identity.level:SetPoint("RIGHT",identity.health,"LEFT",-5,0)
adapter:RefreshNameplateIdentity(identity)
profile.mode="off"; adapter:RefreshNameplateIdentity(identity)
assert(identity.health.width==120 and identity.health.point[5]==-4 and identity.health.text.justify=="RIGHT")
profile.mode="dps"

-- Exercise the installed provider hooks: rebuilding config must not compound insets.
local realProvider = pfUI.nameplates
local configuredWidth = 120
local hooked = { OnCreate = function() end, OnUpdate = function() end }
function hooked:OnDataChanged(plate) plate.nameLayout="health" end
function hooked.OnConfigChange(frame)
  local plate=frame.nameplate
  plate.health:SetWidth(configuredWidth)
  plate.health:SetPoint("TOP",plate.name,"BOTTOM",0,-4)
  plate.level:SetPoint("RIGHT",plate.health,"LEFT",-5,0)
  hooked:OnDataChanged(plate)
end
pfUI.nameplates=hooked
adapter:InstallNameplateTargetCueHooks()
hooked.OnConfigChange({nameplate=identity})
assert(identity.health.width==96)
configuredWidth=140; hooked.OnConfigChange({nameplate=identity})
assert(identity.health.width==116 and identity.aeuiIdentity.healthWidth==140)
profile.mode="off"; hooked.OnConfigChange({nameplate=identity})
assert(identity.health.width==140 and not identity.aeuiIdentity.active)
profile.mode="dps"; pfUI.nameplates=realProvider

-- Repeated hidden/selected cue updates must not repeatedly bind textures.
local cuePlate = { aeuiTargetCueFrame = { texture = node() } }
for i = 1, 100 do adapter:EnsureNameplateTargetCue(cuePlate) end
assert(cuePlate.aeuiTargetCueFrame.texture.calls.SetTexture == 1)
assert(cuePlate.aeuiTargetCueFrame.texture.calls.SetTexCoord == 1)
adapter:RestoreNameplateTargetCue({})

local selected = node()
selected.name, selected.health, selected.totem, selected.level = node(), node(), node(), node()
selected.totem:Hide()
selected.istarget = true
adapter.nameplateTargetCueActive = true
adapter:RefreshNameplateTargetCue(selected)
local cue = selected.aeuiTargetCueFrame
assert(cue:IsShown() and cue.brackets:GetParent() == cue)
assert(selected.level.point[4] == -14, "selected clasp must reserve level clearance")
local levelWrites = selected.level.calls.SetPoint
local anchors = cue.brackets.calls.SetAllPoints
adapter:RefreshNameplateTargetCue(selected)
assert(cue.brackets.calls.SetAllPoints == anchors, "stable brackets must not relayout")
assert(selected.level.calls.SetPoint == levelWrites, "stable target must not move level every update")
selected.istarget = false
adapter:RefreshNameplateTargetCue(selected)
assert(not cue:IsShown(), "old target must hide arrow and brackets together")
assert(selected.level.point[4] == -5 and not selected.aeuiTargetLevelGap, "old target restores level gap")
selected.istarget = true
adapter:RefreshNameplateTargetCue(selected)
selected.health:Hide()
adapter:RefreshNameplateTargetCue(selected)
assert(cue:IsShown() and not cue.brackets:IsShown(), "hidden health keeps arrow but hides clasps")
selected.health:Show()
adapter:RefreshNameplateTargetCue(selected)
assert(cue.brackets:IsShown() and selected.level.point[4] == -14)
adapter:RestoreNameplateTargetCue(selected)
assert(selected.level.point[4] == -5 and not selected.aeuiTargetLevelGap, "fallback restores level")
assert(not cue:IsShown(), "fallback must hide all personal target decoration")

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
assert(plate:GetScale()==1.15 and plate:GetAlpha()==1, "target is enlarged and opaque")
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
assert(plate:GetScale()==1 and plate:GetAlpha()<=.65, "old target shrinks and fades")
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
-- Temporary target visibility preserves existing categories and hides extras.
NAMEPLATES_ON, FRIENDNAMEPLATES_ON = true, nil
targetGuid, targetName = "friend", "Friend"
provider:UpdateTargetVisibility()
assert(NAMEPLATES_ON and FRIENDNAMEPLATES_ON and provider.targetOnlyFriendly)
function plate.original.healthbar:GetStatusBarColor() return 0, 1, 0 end
plate.istarget=nil; provider:OnDataChanged(plate)
assert(not plate:IsShown(), "temporary friendly category must hide non-target friends")
plate.istarget=true; provider:OnDataChanged(plate)
assert(plate:IsShown() and plate.health:IsShown())
targetGuid,targetName=nil,nil; provider:UpdateTargetVisibility()
assert(NAMEPLATES_ON and not FRIENDNAMEPLATES_ON and not provider.targetVisibilityBase)
local oldCanAttack=UnitCanAttack
function UnitCanAttack(_,unit) return unit=="target" end
NAMEPLATES_ON=nil; targetGuid="enemy"
provider:UpdateTargetVisibility()
assert(NAMEPLATES_ON and provider.targetOnlyHostile)
provider.combatMode=nil; provider:UpdateTargetVisibility()
assert(not NAMEPLATES_ON and not provider.targetOnlyHostile)
UnitCanAttack=oldCanAttack
provider.combatMode="dps"
targetGuid,targetName="friend","Friend"
plate.cachedGuid="friend"
function parent:GetName() return "friend" end
NAMEPLATES_ON,FRIENDNAMEPLATES_ON=true,nil
local friendShows,hostileShows=0,0
function ShowFriendNameplates()
  friendShows=friendShows+1
  provider.OnShow(parent)
  assert(plate.istarget, "synchronous OnShow must see current target")
end
function ShowNameplates() hostileShows=hostileShows+1 end
provider:UpdateTargetVisibility()
provider:UpdateTargetVisibility()
assert(friendShows==1 and hostileShows==0)
targetGuid="other-friend"; provider:UpdateTargetVisibility()
assert(friendShows==1, "same category target switch must not reopen engine plates")
targetGuid=nil; provider:UpdateTargetVisibility()
assert(not FRIENDNAMEPLATES_ON and NAMEPLATES_ON)
-- Fresh/recycled overlays remain invisible until native placement has had a tick,
-- then expose final geometry and target scale together (even inside the throttle).
provider.combatMode="dps"
targetGuid,targetName="friend","Friend"
plate.cachedGuid="friend"
provider:UpdateTargetVisibility()
provider.OnShow(parent)
assert(plate:GetAlpha()==0 and plate.aeuiShowPending==1)
local revealState={now=now,hasTarget=true,targetGuid="friend",hasMouseover=false}
plate.lasttick=now
provider.OnUpdate(parent,revealState)
assert(plate:GetAlpha()==0 and plate.aeuiShowPending==0, "first native layout pass stays hidden")
now=now+.001; revealState.now=now
provider.OnUpdate(parent,revealState)
assert(plate:GetAlpha()==1 and plate:GetScale()==1.15 and plate.aeuiShowPending==nil,
  "reveal must use final target scale and bypass the old throttle")
local stableScale=plate.calls.SetScale
now=now+.03; revealState.now=now
provider.OnUpdate(parent,revealState)
assert(plate:GetScale()==1.15 and plate.calls.SetScale==stableScale,
  "revealed target must not shrink on the following refresh")
local dataChanged = provider.OnDataChanged
provider.OnDataChanged = function() end
plate.friendly=false; plate.namesOnly=false
plate.raidicon:Hide(); plate.castbar:Hide()
revealState.targetGuid='other'; targetGuid='other'
for _, mode in ipairs({'healer','dps'}) do
  provider.combatMode=mode
  for _, alpha in ipairs({.75,.9,1}) do
    plate.roleAlpha=alpha
    now=now+.2; revealState.now=now
    provider.OnUpdate(parent,revealState)
    local expected = alpha == 1 and 1 or alpha == .9 and .85 or .6
    assert(plate:GetAlpha()==expected, 'selected target preserves danger but dims ordinary and warning enemies')
    revealState.hasTarget=false
    now=now+.2; revealState.now=now
    provider.OnUpdate(parent,revealState)
    assert(plate:GetAlpha()==alpha, 'clearing target restores normal hostile opacity')
    revealState.hasTarget=true
  end
  plate.roleAlpha=.75; plate.raidicon:Show()
  now=now+.2; revealState.now=now
  provider.OnUpdate(parent,revealState)
  assert(plate:GetAlpha()>=.85, 'marked non-target remains readable')
  plate.raidicon:Hide()
end
provider.OnDataChanged = dataChanged
-- The rail inherits health visibility; missing data and disabled roles hide it.
do
  local testPlate = {health=node()}
  provider.combatMode='dps'
  provider:UpdateThreatRail(testPlate,nil,{1,.7,.2})
  assert(not testPlate.threatRail,'missing data must not allocate a rail')
  provider:UpdateThreatRail(testPlate,78,{1,.7,.2})
  local rail=testPlate.threatRail
  assert(rail:IsShown() and rail.parent==testPlate.health and rail.height==8)
  assert(rail.text:GetText()=='78%','threat label contains only the percentage')
  assert(rail.pointsByAnchor.TOPLEFT[3]=='BOTTOMLEFT','threat sits below original health')
  local value
  function rail:SetValue(v) value=v end
  for _, ratio in ipairs({0,35,120}) do
    provider:UpdateThreatRail(testPlate,ratio,{1,.7,.2})
    assert(value==math.min(100,ratio) and rail:IsShown())
  end
  assert(rail.calls.SetPoint==2,'updates must not rewrite rail geometry')
  provider:UpdateThreatRail(testPlate,nil,{1,.7,.2}); assert(not rail:IsShown())
  testPlate.friendly=true
  provider:UpdateThreatRail(testPlate,78,{1,.7,.2}); assert(not rail:IsShown())
  testPlate.friendly=false; provider.combatMode=nil
  provider:UpdateThreatRail(testPlate,78,{1,.7,.2}); assert(not rail:IsShown())
end
print("PASS nameplate modes: profiles, roles, threat, aura priority, cue caching, names-only, event coalescing, target transitions, hostile readability")
