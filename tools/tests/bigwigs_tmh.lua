-- Run from repository root: lua tools/tests/bigwigs_tmh.lua
local function read(path)
    local f = assert(io.open(path, "rb")); local s = f:read("*a"); f:close(); return s
end
local locale, libraries, modules = (arg and arg[1]) or "zhCN", {}, {}
local noop = function() end
local function translations(name)
    if libraries[name] then return libraries[name] end
    local t = {Debug=noop, SetStrictness=noop}
    function t:RegisterTranslations(lang, fn)
        if lang == "enUS" or lang == locale then
            for k,v in pairs(fn()) do self[k] = v == true and k or v end
        end
    end
    libraries[name] = t
    return t
end
AceLibrary = setmetatable({HasInstance=function() return true end,
    IsNewVersion=function() return true end, Register=noop}, {__call=function(_, name)
    if name == "AceLocale-2.2" then
        return {new=function(_, key) return translations(key) end,
            GetLibraryVersion=function() return 1, 1 end}
    end
    return assert(libraries[name], name)
end})
dofile("addon/!Libs/Babble/Babble-Boss-2.2/Babble-Boss-2.2.lua")
libraries["Babble-Zone-2.2"] = {["Timbermaw Hold"]="木喉要塞"}
libraries["Babble-Class-2.2"] = {Shaman="萨满祭司"}
libraries.BigWigs = {["Timbermaw Hold"]="木喉要塞"}
local api = {}
for _, path in ipairs({"addon/BigWigs/Core.lua",
    "addon/!Libs/Ace2/AceEvent-2.0/AceEvent-2.0.lua",
    "addon/!Libs/CandyBar-2.2/CandyBar-2.2.lua"}) do
    local source = read(path)
    for method in source:gmatch("function [%w_.]+:([%w_]+)%(") do api[method]=noop end
    for method in source:gmatch('"([%w_]+CandyBar[%w_]*)"') do api[method]=noop end
end
function api:RegisterEvent(event, handler) self.events[event]=handler or event end
function api:Bar(text, duration) assert(text and duration); self.lastBar={text,duration} end
function api:ScheduleEvent(id, handler) assert(type(handler)=="function" or type(handler)=="string", id) end
function api:ScheduleRepeatingEvent(id, handler) self:ScheduleEvent(id, handler) end
function api:Sync(sync) self.lastSync=sync end
function api:GetAvailableRaidMark() return 1 end
function api:WarningSign(...) self.warned=true end
function api:RemoveWarningSign() self.warned=false end
function api:Sound(sound) self.lastSound=sound end
local units = {player="Me"}
function UnitName(unit) return units[unit] end
function UnitClass() return "战士", "WARRIOR" end
function UnitExists(unit) return units[unit] ~= nil end
function GetNumRaidMembers() return 2 end
function UnitHealth() return 80 end
function UnitHealthMax() return 100 end
local debuffs = {}
function UnitDebuff(_, i) if debuffs[i] then return "texture", 1, nil, debuffs[i] end end
function UnitIsEnemy() return true end
function UnitIsVisible() return true end
function CheckInteractDistance() return false end
function SendChatMessage() end
BigWigs = {ModuleDeclaration=function(self, boss)
    local name=assert(libraries["Babble-Boss-2.2"][boss], boss)
    local m=setmetatable({translatedName=name, events={}}, {__index=api})
    modules[boss]=m
    self.lastLocale=translations("BigWigs"..name)
    return m, self.lastLocale
end, CheckForBossDeath=noop}
local count=0
for entry in read("addon/BigWigs/BigWigs.toc"):gmatch("[^\r\n]+") do
    if entry:find("Raids\\TMH\\",1,true) then
        local path="addon/BigWigs/"..entry:gsub("\\","/")
        assert(loadfile(path))()
        for key in read(path):gmatch('L%["([^"]+)"%]') do
            assert(BigWigs.lastLocale[key], path..": missing locale key "..key)
        end
        count=count+1
    end
end
assert(count==12, "support plus all eleven TMH modules must load")
for _, m in pairs(modules) do
    m.db={profile={}}
    for _, option in ipairs(m.toggleoptions) do
        if option ~= -1 then m.db.profile[option]=true end
    end
    m.db.profile.hpframe=false -- real frame layout is verified in game
    m:OnSetup(); m:OnEnable(); m:OnEngage()
    for event, handler in pairs(m.events) do
        assert(type(m[handler])=="function", event.." -> "..handler)
    end
end
local ormanos=modules["Ormanos the Cracked"]
units.raid2target=ormanos.translatedName
debuffs={11719,1714,11398,8692}
assert(math.abs(ormanos:GetCastTimeCoefficient()-2.56)<.001, "only highest rank per slow family")
units.raid2target=nil
assert(ormanos:GetCastTimeCoefficient()==1, "missing live unit uses base timing")
local selenaxx=modules["Selenaxx Foulheart"]
units.raid1target=selenaxx.translatedName
selenaxx:CheckBossHealth(); assert(selenaxx.hp85, "health thresholds use live raid targets")
selenaxx:AfflictionEvent(locale=="zhCN" and "你受到了毁灭之雨效果的影响"
    or "You are afflicted by Rain of Destruction.")
assert(selenaxx.warned and selenaxx.lastSound=="Info", "rain gain shows warning and sound")
selenaxx.lastSound=nil
selenaxx:AfflictionEvent(locale=="zhCN" and "塞雷纳克斯·腐心的毁灭之雨使你受到100点伤害"
    or "You suffer 100 Fire damage from Selenaxx Foulheart's Rain of Destruction.")
assert(selenaxx.lastSound=="Info", "rain damage ticks repeat the sound")
selenaxx:FadesEvent(locale=="zhCN" and "毁灭之雨效果从你身上消失了"
    or "Rain of Destruction fades from you.")
assert(not selenaxx.warned and selenaxx.lastSound=="Long", "rain fade clears warning")
local peroth=modules["Peroth'arn"]
assert(peroth.events.CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE=="DamageEvent")
peroth:BigWigs_RecvSync("PerothShieldGain"..peroth.revision)
peroth:BigWigs_RecvSync("PerothShieldFade"..peroth.revision)
assert(peroth.events.CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE=="DamageEvent", "shield fade keeps flame events")
peroth:DamageEvent(locale=="zhCN" and "你受到了净化烈焰效果的影响"
    or "You are afflicted by Flames of Purgation.")
local trioch=modules.Trioch
trioch:Event(locale=="zhCN" and "提里奥克用巨大的冰锥瞄准了%t和Me"
    or "Trioch aims a giant ice lance at %t and Me")
assert(trioch.iceTargets.Me, "unresolved first target must not discard the second")
trioch:CorrosionMark("Me"); trioch:OozeDead(); trioch:OozePoisonEnd()
trioch:CorrosionMark("Me"); assert(not trioch.oozeDeadFired, "each ooze wave resets death detection")
for _, m in pairs(modules) do m:OnDisengage() end
print("PASS BigWigs TMH: load/locale, lifecycle, live units, slows, shield event routing, ice and ooze")
