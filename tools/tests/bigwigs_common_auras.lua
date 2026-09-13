-- Run: lua tools/tests/bigwigs_common_auras.lua
local class, events, registered = "DRUID", {}, {}
function GetLocale() return "zhCN" end
function UnitClass() return ({DRUID="Druid", SHAMAN="Shaman", WARRIOR="Warrior"})[class], class end
function UnitName(unit) return unit == "player" and "Me" or "WrongTarget" end
function UnitRace() return "Dwarf" end
function TargetByName(unit) _G.clickedUnit=unit end
function GetTalentInfo() return nil,nil,nil,nil,0 end
local libraries = {}
local function library(name)
    if libraries[name] then return libraries[name] end
    local lib=setmetatable({}, {__index=function(_, key) return key end})
    function lib:new() return library("locale") end
    function lib:RegisterTranslations(locale, fn)
        if locale == "enUS" or locale == GetLocale() then
            for k,v in pairs(fn()) do self[k]=v == true and k or v end
        end
    end
    libraries[name]=lib
    return lib
end
AceLibrary=library
BigWigs={NewModule=function()
    return {
        RegisterEvent=function(_, event) registered[event]=true end,
        TriggerEvent=function(_, ...) events[#events+1]={...} end,
        SetCandyBarOnClick=function(self, id, fn, unit) self.click={id,fn,unit} end,
    }
end}
dofile("addon/BigWigs/Plugins/CommonAuras.lua")
local m=BigWigsCommonAuras
m.db={profile={}}
for k,v in pairs(m.defaultDB) do m.db.profile[k]=v end
m:OnEnable()
assert(registered.CHAT_MSG_SPELL_SELF_BUFF and registered.SpellStatus_SpellCastInstant)
local function sent(callback, expected)
    events={}; callback()
    assert(#events==1 and events[1][1]=="BigWigs_SendSync" and events[1][2]==expected, expected)
end
sent(function() m:SpellStatus_SpellCastInstant(12,"Barkskin") end,"BWCABS 2.16.1")
sent(function() m:SpellStatus_SpellCastInstant(13,"狂暴") end,"BWCAFR 2.16.1")
sent(function() m:CHAT_MSG_SPELL_SELF_BUFF("你施放了树皮术。") end,"BWCABS 2.16.1")
sent(function() m:CHAT_MSG_SPELL_SELF_BUFF("You cast Berserk.") end,"BWCAFR 2.16.1")
events={}; m:SpellStatus_SpellCastInstant(45708,"狂暴回复")
assert(#events==0,"spellbook slots and similar names must not trigger Berserk")
class="SHAMAN"
sent(function() m:CHAT_MSG_SPELL_SELF_BUFF("你对Tank施放了灵魂连接。") end,"BWCASL 2.16.1 Tank")
sent(function() m:CHAT_MSG_SPELL_SELF_BUFF("You cast Spirit Link on Tank.") end,"BWCASL 2.16.1 Tank")
sent(function() m:CHAT_MSG_SPELL_SELF_BUFF("你施放了灵魂连接。") end,"BWCASL 2.16.1 Me")
events={}; m:CHAT_MSG_SPELL_SELF_BUFF("你施放了狂暴。")
assert(#events==0,"Berserk is druid-only")
for _, case in ipairs({{"BWCABS","barkskin",12,"树皮术"},
    {"BWCAFR","berserk",20,"狂暴"},{"BWCASL","spiritlink",20,"灵魂连接"}}) do
    local sync,key,duration,label=case[1],case[2],case[3],case[4]
    local payload="2.16.1"..(sync=="BWCASL" and " Tank" or "")
    events={}; m:BigWigs_RecvSync(sync,payload,"Caster")
    local target=sync=="BWCASL" and "Tank" or "Caster"
    assert(#events==2 and events[2][1]=="BigWigs_StartBar")
    assert(events[2][3]==target.." "..label and events[2][4]==duration)
    assert(m.click[1]=="BigWigsBar "..events[2][3],"click handler uses the real bar ID")
    m.click[2](nil,nil,m.click[3]); assert(clickedUnit==target)
    m.consoleOptions.args[key].set(false)
    assert(not m.consoleOptions.args[key].get())
    events={}; m:BigWigs_RecvSync(sync,payload,"Caster"); assert(#events==0,"toggle disables display")
    m.consoleOptions.args[key].set(true)
end
for _, payload in ipairs({"", "2.16.0", "bad", "2.16.1", "2.16.0 Tank"}) do
    events={}; m:BigWigs_RecvSync("BWCASL",payload,"Caster")
    assert(#events==0,"malformed/incomplete/old link packets are rejected")
end
class="WARRIOR"
sent(function() m:SpellStatus_SpellCastInstant(1,"Shield Wall") end,"BWCASW 10")
print("PASS common auras: casts, actual link targets, protocol, durations, toggles, clicks, Shield Wall")
