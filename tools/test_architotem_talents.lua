-- lua tools/test_architotem_talents.lua [path/to/ArchiTotem/Data/Core.lua]
getfenv = getfenv or function() return _G end
GetAddOnMetadata = function() return "test" end
UnitClass = function() return "Shaman", "SHAMAN" end
local mastery, fire = 1, 2
GetNumTalentTabs = function() return 1 end
GetNumTalents = function() return 2 end
GetTalentInfo = function(tab, index)
  if tab ~= 1 then return end
  if index == 1 then return "图腾掌握", nil, nil, nil, mastery end
  if index == 2 then return "强化火焰图腾", nil, nil, nil, fire end
end
dofile(arg[1] or "D:/Softwares/TurtleWoW/Interface/AddOns/ArchiTotem/Data/Core.lua")
ArchiTotem_Print = function() end
ArchiTotem_Options = {Apperance={shownumericcooldowns=true}}
local friendly = {name="Windfury Totem",duration=120,cooldown=0}
local nova = {name="Fire Nova Totem",duration=5,cooldown=15}
for points = 0, 2 do
  fire = points
  ArchiTotem_UpdateTalents()
  assert(ArchiTotem_GetEffectiveDuration(nova)==5-points)
  assert(ArchiTotem_GetEffectiveDuration(friendly)==144)
end
for _, name in ipairs({"Searing Totem","Magma Totem","Earthbind Totem","Stoneclaw Totem","Sentry Totem"}) do
  assert(ArchiTotem_GetEffectiveDuration({name=name,duration=20})==20)
end
mastery,fire=0,0
ArchiTotem_UpdateTalents()
assert(ArchiTotem_GetEffectiveDuration(friendly)==120)
assert(ArchiTotem_GetEffectiveDuration(nova)==5)
-- The existing manual mastery override must not bypass fire talent scanning.
ArchiTotem_Options.ForceTotemicMastery=true; fire=2
ArchiTotem_UpdateTalents()
assert(ArchiTotem_GetEffectiveDuration(friendly)==144)
assert(ArchiTotem_GetEffectiveDuration(nova)==3 and nova.cooldown==15 and nova.duration==5)
-- Exercise the real display loop; emulate Vanilla's table iteration on newer Lua.
local function iterable(t)
  return setmetatable(t,{__call=function(self,_,key) return next(self,key) end})
end
local function text()
  return {Hide=function(self) self.hidden=true end, Show=function(self) self.hidden=false end,
    SetText=function(self,v) self.value=v end}
end
GetTime=function() return 100 end
friendly.casted=100; nova.casted=100
ArchiTotemActiveTotem=iterable({Air=friendly,Fire=nova})
ArchiTotem_TotemData=iterable({})
AirDurationText,FireDurationText=text(),text()
this={TimeSinceLastUpdate=0}
ArchiTotem_OnUpdate(.2)
assert(AirDurationText.value=="2:24" and FireDurationText.value=="0:03")
GetTime=function() return 103 end
ArchiTotem_OnUpdate(.2)
assert(FireDurationText.hidden and not ArchiTotemActiveTotem.Fire)
assert(friendly.duration==120 and nova.duration==5 and nova.cooldown==15)
print("PASS ArchiTotem talents: ranks, friendly scope, no compounding, respec, overrides and live timer expiry")
