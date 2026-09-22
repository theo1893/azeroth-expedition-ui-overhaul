-- Run: lua tools/tests/bigwigs_golden.lua [zhCN|enUS]
-- Focused provider-boundary checks. Real frame layout and combat timing need the client.
local locale = (arg and arg[1]) or "zhCN"
if arg and arg[2] == "extended" then SetAutoloot = function() end end
table.getn = table.getn or function(t) return #t end
math.mod = math.mod or math.fmod
unpack = unpack or table.unpack
tinsert, tremove = table.insert, table.remove
local now, epoch, sent, units = 100, 1000000, {}, {}
local noop = function() end
local function read(path)
    local f = assert(io.open(path, "rb")); local s = f:read("*a"); f:close(); return s
end
local function frame()
    local f = {shown=false, scripts={}}
    function f:Show() self.shown=true end
    function f:Hide() self.shown=false end
    function f:IsShown() return self.shown end
    f.IsVisible=f.IsShown
    function f:SetScript(key, fn) self.scripts[key]=fn end
    function f:SetText(value) self.text=value end
    function f:GetText() return self.text end
    function f:GetCenter() return 0,0 end
    function f:GetEffectiveScale() return 1 end
    function f:CreateTexture() return frame() end
    function f:CreateFontString() return frame() end
    return setmetatable(f,{__index=function() return noop end})
end
function CreateFrame(_, name, parent)
    local f=frame()
    if name then _G[name]=f end
    if parent then
        parent.children = rawget(parent,"children") or {}
        table.insert(parent.children,f)
    end
    return f
end
UIParent, WorldFrame, DEFAULT_CHAT_FRAME = frame(), frame(), frame()
ChatFrame1, STANDARD_TEXT_FONT, SlashCmdList = DEFAULT_CHAT_FRAME, "font", {}
function GetLocale() return locale end
function GetTime() return now end
function time() return epoch end
function GetNumRaidMembers() return 2 end
function GetNumPartyMembers() return 0 end
function UnitName(unit) return unit=="player" and "Me" or units[unit] end
function UnitExists(unit) return units[unit]~=nil, units[unit] and "0xF130000000000001" end
function UnitClass() return "Warrior","WARRIOR" end
function UnitRace() return "Human" end
function UnitInRaid() return true end
function UnitIsPlayer(unit) return unit=="player" or unit=="raid1" or unit=="raid2" end
function UnitHealth() return 80 end
function UnitHealthMax() return 100 end
function UnitMana() return 20 end
function UnitManaMax() return 100 end
function UnitResistance(_, school) return 0, school*10 end
function UnitArmor() return 100, 200 end
function UnitBuff() end
local debuffs={}
function UnitDebuff(_, i) if debuffs[i] then return "texture",1,nil,debuffs[i] end end
function GetTalentInfo() return nil,nil,nil,nil,0 end
function SetCVar() end
function SendChatMessage(...) sent[#sent+1]={...} end
function getglobal(name) return _G[name] end
local libraries, locales, defaults, modules = {}, {}, {}, {}
local function translations(name)
    if locales[name] then return locales[name] end
    local t={Debug=noop,SetStrictness=noop}
    function t:RegisterTranslations(lang, factory)
        if lang=="enUS" or lang==locale then
            for k,v in pairs(factory()) do
                if lang==locale or self[k]==nil then self[k]=v==true and k or v end
            end
        end
    end
    function t:HasTranslation(key) return self[key]~=nil end
    function t:HasReverseTranslation(value)
        for k,v in pairs(self) do if v==value then return true end end
        return false
    end
    function t:GetReverseTranslation(value)
        for k,v in pairs(self) do if v==value then return k end end
    end
    locales[name]=t; return t
end
local api={SetModuleMixins=noop,RegisterDB=noop,RegisterChatCommand=noop,
    Debug=noop,SetDebugging=noop,Print=noop,RemoveWarningSign=noop,RemoveIcon=noop,
    RegisterCandyBarGroup=noop,SetCandyBarGroupPoint=noop,SetCandyBarGroupGrowth=noop}
function api:ToString() return self.name end
function api:RegisterEvent(event,handler) self.events[event]=handler or event end
function api:IsEventRegistered(event) return self.events[event]~=nil end
function api:UnregisterEvent(event) self.events[event]=nil end
function api:ScheduleEvent(id,callback,delay,...) self.schedules[id]={callback,delay,...} end
api.ScheduleRepeatingEvent=api.ScheduleEvent
function api:CancelScheduledEvent(id) self.schedules[id]=nil end
function api:CancelAllScheduledEvents() self.schedules={} end
function api:IsEventScheduled(id) return self.schedules[id]~=nil end
function api:TriggerEvent(...) sent[#sent+1]={...} end
function api:IsModuleActive(module) return type(module)=="table" and module.active end
function api:ToggleModuleActive(module,active) if type(module)=="table" then module.active=active end end
function api:RegisterDefaults(name,kind,values) defaults[name]=values end
function api:AcquireDBNamespace(name) return {profile=defaults[name] or {},char={}} end
local function addon()
    local core=setmetatable({modulePrototype={},events={},schedules={}},{__index=api})
    function core:NewModule(name)
        local m=setmetatable({name=name,events={},schedules={}}, {__index=function(_,key)
            return self.modulePrototype[key] or api[key]
        end})
        modules[name]=m; return m
    end
    return core
end
libraries["AceLocale-2.2"]={new=function(_,name) return translations(name) end,
    GetLibraryVersion=function() return 1,1 end}
libraries["AceAddon-2.0"]={new=addon}
libraries["Surface-1.0"]={Register=noop}
libraries["Babble-Zone-2.2"]=setmetatable({HasTranslation=function() return true end,
    HasReverseTranslation=function() return false end},{__index=function(_,k) return k end})
libraries["Babble-Class-2.2"]=setmetatable({}, {__index=function(_,k) return k end})
libraries["Babble-Spell-2.2"]=libraries["Babble-Class-2.2"]
libraries["Tablet-2.0"]={IsRegistered=function() return false end}
libraries["Dewdrop-2.0"]={}
libraries["PaintChips-2.0"]={}
AceLibrary=setmetatable({HasInstance=function() return true end,IsNewVersion=function() return true end,
    Register=function(_,lib,name) libraries[name]=lib end}, {__call=function(_,name)
    return assert(libraries[name],name)
end})
dofile("addon/!Libs/Babble/Babble-Boss-2.2/Babble-Boss-2.2.lua")
dofile("addon/BigWigs/Core.lua")
local bossLibrary=libraries["Babble-Boss-2.2"]
local imported={"BWL/Alchemists","BWL/Ezzel","MC/TwinGolems","MC/Incindis","MC/Thaurissan",
    "Naxxramas/ConstructTrash","Karazhan/KaraTrash","Karazhan/Anomalus","Karazhan/ChessFight",
    "Karazhan/EchoOfMedivh","Karazhan/Incantagos","Karazhan/KeeperGnarlmoon","Karazhan/Mephistroth",
    "Karazhan/Rupturan","Karazhan/SanvTasdal","Karazhan/LordBlackwaldII","AQ40/Cthun","MC/Ragnaros",
    "MC/CoreHound","BWL/Firemaw","BWL/Ebonroc","BWL/Flamegor","BWL/Broodlord","BWL/Nefarian",
    "BWL/Razorgore","Naxxramas/Horsemen","Naxxramas/Kelthuzad","Naxxramas/Maexxna"}
local count=0
for _,path in ipairs(imported) do dofile("addon/BigWigs/Raids/"..path..".lua") end
for name,m in pairs(modules) do
    BigWigs:RegisterModule(name,m)
    local L=locales["BigWigs"..name]
    for _,key in ipairs(m.toggleoptions or {}) do
        if key~=-1 and key~="bosskill" then
            for _,suffix in ipairs({"_cmd","_name","_desc"}) do
                assert(L[key..suffix],m.bossSync..": missing "..key..suffix)
            end
        end
    end
    m:OnSetup(); m:OnEnable()
    for event,handler in pairs(m.events) do
        assert(type(handler)=="function" or type(m[handler])=="function",m.bossSync..": "..event.." -> "..tostring(handler))
    end
    count=count+1
end
assert(count==#imported,"every added/rewritten encounter registers")
local anomalus=modules[bossLibrary["Anomalus"]]
assert(anomalus.db.profile.monitorfontsize==12 and anomalus.db.profile.monitorscale==1,
    "numeric monitor defaults survive core registration")
local chess=modules[bossLibrary["King"]]
assert(chess,"chess module remains addressable by its existing name")
chess.db.profile={subservience=false}
chess:OnRegister()
assert(chess.db.profile.subservienceyou==false and chess.db.profile.subservienceothers==false,
    "old disabled warning migrates to the split warning options")
units.raid1target="Live boss"
assert(BigWigs:GetUnitIdByName("Live boss",1)=="raid1target")
debuffs={11719,1714,11398,8692,5760}
assert(math.abs(BigWigs:GetCastTimeCoefficient("raid1target")-2.56)<.001,
    "only the strongest slow in each family affects cast time")
assert(BigWigs:GetCastTimeCoefficient(nil)==1 and BigWigs:GetHealthPercent(nil)==nil)
assert(BigWigs:RaidTargetLookup("Triangle")==4)
assert(BigWigs:OffsetGUID("0xF130000000000001",1)=="0xF130000000000002")
assert(BigWigs:OffsetGUID("raid1target",1)==nil)
assert(BigWigs:CancelAuraId(1)==false,"missing extension does not call a missing API")

dofile("addon/BigWigs/Plugins/ResistCheck.lua")
local resist=BigWigsResistCheck
BigWigs:RegisterModule(resist.name,resist)
resist.UpdateTablet=noop
resist:OnEnable()
units.raid1,units.raid2="Me","Raider"
resist:QueryResistance(0)
assert(resist.responseTable.Me==200,"physical check reports effective armor")
resist:BigWigs_RecvSync("BWRR","250 Me","Raider")
resist:BigWigs_RecvSync("BWRR","250 Me","Raider")
assert(resist.responses==2 and resist.responseTable.Raider==250,"duplicate replies do not inflate responders")
resist:BigWigs_RecvSync("BWRR","999 Me","Outsider")
resist:BigWigs_RecvSync("BWRR","bad Me","Raider")
assert(resist.responseTable.Outsider==nil and resist.responseTable.Raider==250)
resist:OnDisable(); assert(not resist.queryRunning and not resist.schedules.BigWigsResistanceQuery)

dofile("addon/BigWigs/Plugins/WorldBossCooldown.lua")
local cd=BigWigsWorldBossCooldown
BigWigs:RegisterModule(cd.name,cd)
cd.EnsurePanel,cd.RefreshPanel=noop,noop
cd:OnEnable()
assert(cd.events.CHAT_MSG_SYSTEM=="OnSystemMessage" and cd.schedules.BigWigsWorldBossCooldownRefresh)
local boss={bossSync="Azuregos",ToString=function() return bossLibrary["Azuregos"] end}
cd:EndBossfight(boss)
assert(cd.db.char.worldBossKills[boss:ToString()]==epoch and cd.db.profile.worldBossKills==nil)
cd:EndBossfight({bossSync="Anomalus",ToString=function() return "Anomalus" end})
assert(cd.db.char.worldBossKills.Anomalus==nil,"instance bosses never get world lockouts")
local locked="你绝对不允许从 "..boss:ToString().." 处获得战利品，因为个人锁定权限"
cd:OnSystemMessage(locked)
assert(cd.db.char.worldBossKills[boss:ToString()]==nil and cd.db.char.worldBossLocked[boss:ToString()])
cd:EndBossfight(boss)
assert(cd.db.char.worldBossKills[boss:ToString()]==nil,"lock message before victory does not stamp a false kill")
local previous=cd.db.char
cd.db.char={}; cd:EnsureData()
assert(next(cd.db.char.worldBossKills)==nil and previous.worldBossLocked[boss:ToString()],"characters have separate lockouts")
cd:OnDisable(); assert(not cd.schedules.BigWigsWorldBossCooldownRefresh)

-- Test the actual bar bridge with a small CandyBar state double; it keeps the
-- library's start/stop/pause contract, while the client remains the layout oracle.
local candy={var={handlers={}},UpdateGroup=noop,Update=noop}
libraries["CandyBar-2.2"]=candy
libraries["PaintChips-2.0"].GetRGBPercent=function() return true,1,1,1 end
libraries["Surface-1.0"].Fetch=function() return "texture" end
libraries["Surface-1.0"].List=function() return {} end
function api:RegisterCandyBar(id,duration,text,icon)
    assert(type(duration)=="number" and duration>0)
    candy.var.handlers[id]={time=duration,text=text,icon=icon,frame=frame()}
end
function api:RegisterCandyBarWithGroup(id,group) candy.var.handlers[id].group=group end
function api:StartCandyBar(id)
    local b=candy.var.handlers[id]
    b.starttime,b.endtime,b.running,b.elapsed=now,now+b.time,true,0
    b.frame:Show()
end
function api:PauseCandyBar(id)
    local b=candy.var.handlers[id]; b.running=nil; b.paused=true
end
function api:SetCandyBarFade(id,fade) candy.var.handlers[id].fadetime=fade end
function api:SetCandyBarOnClick(id,fn,a1)
    local b=candy.var.handlers[id]; b.onclick,b.onclick1=fn,a1
end
function api:UnregisterCandyBar(id)
    local b=candy.var.handlers[id]; if b then b.frame:Hide() end
    candy.var.handlers[id]=nil
end
function api:CandyBarStatus(id)
    local b=candy.var.handlers[id]
    if b then return true,b.time,now-b.starttime,b.running,b.paused end
end
for _,key in ipairs({"SetCandyBarTexture","SetCandyBarWidth","SetCandyBarHeight","SetCandyBarReversed",
    "SetCandyBarScale","SetCandyBarTimeFormat","SetCandyBarBackgroundColorRGB"}) do api[key]=noop end
function candy:SetText(id,text) self.var.handlers[id].text=text end
function UnitIsDead() return false end
function IsControlKeyDown() return false end
function IsShiftKeyDown() return false end
function SecondsToTime(value) return tostring(value) end
function api:TriggerEvent(event,...)
    if event=="BigWigs_BarsChanged" and BigWigsVerticalBars and BigWigsVerticalBars.active then
        BigWigsVerticalBars:RefreshBars()
    elseif event=="BigWigs_StartBar" then BigWigsBars:BigWigs_StartBar(...)
    else sent[#sent+1]={event,...} end
end
dofile("addon/BigWigs/Plugins/Bars.lua")
local bars=BigWigsBars
BigWigs:RegisterModule(bars.name,bars)
bars.db.profile.emphasize=false
bars.frames={anchor={candyBarGroupId="normal"}}
dofile("addon/BigWigs/Plugins/VerticalBars.lua")
local vertical=BigWigsVerticalBars
BigWigs:RegisterModule(vertical.name,vertical)
local menu=BigWigs.cmdtable.args[locales.BigWigs["plugin"]].args[vertical.consoleCmd]
assert(menu==vertical.consoleOptions and not menu.args.enable.get(),"panel registers a default-off timeline")
local originalEnable=BigWigs.EnableModule
function BigWigs:EnableModule(name)
    assert(name==vertical:ToString())
    vertical:OnEnable()
end
menu.args.enable.set(false)
assert(not vertical.active and not vertical.frames,"disabling an idle timeline does not start it")
local owner=BigWigs:NewModule("test owner")
bars:BigWigs_StartBar(owner,"timer",20,"icon")
local timer=candy.var.handlers["BigWigsBar timer"]
assert(timer.frame:IsShown())
menu.args.enable.set(true)
assert(vertical.active and menu.args.enable.get(),"panel can activate an idle timeline")
assert(not timer.frame:IsShown() and timer.running and timer.endtime==120)
bars:BigWigs_StartHPBar(owner,"health",100,"icon",true,"Green")
bars:BigWigs_StartCounterBar(owner,"counter",10,"icon",true,"Green")
assert(candy.var.handlers["BigWigsBar health"].frame:IsShown())
assert(candy.var.handlers["BigWigsBar counter"].frame:IsShown())
bars:BigWigs_StartMonitorBar(owner,"monitor","icon","raid1target","health","Boss")
assert(candy.var.handlers["BigWigsBar monitor"].frame:IsShown(),"resource monitors remain horizontal")
now=105
bars:BigWigs_StartBar(owner,"timer",20,"icon")
timer=candy.var.handlers["BigWigsBar timer"]
assert(timer.endtime==125,"same-duration refresh resets the real expiry")
local clicked
owner:SetCandyBarOnClick("BigWigsBar timer",function(_,_,target) clicked=target end,"Raider")
vertical:UpdateAllIcons()
for _,widget in ipairs(vertical.frames.anchor.children) do
    if rawget(widget,"barId")=="BigWigsBar timer" then
        this,arg1=widget,"LeftButton"; widget.scripts.OnClick()
    end
end
assert(clicked=="Raider","timeline uses the provider's latest click target")
bars:BigWigs_StartIntervalBar(owner,"interval",14,24,"icon")
local interval=candy.var.handlers["BigWigsBar interval"]
assert(interval.endtime==119 and interval.fadetime==10)
now=120; interval.running=nil; interval.fading=true
vertical:RefreshBars(); vertical:UpdateAllIcons()
local intervalVisible=false
for _,widget in ipairs(vertical.frames.anchor.children) do
    if rawget(widget,"barId")=="BigWigsBar interval" and widget:IsShown() then intervalVisible=true end
end
assert(intervalVisible,"interval warning remains after its minimum time")
menu.args.enable.set(false)
assert(timer.frame:IsShown() and timer.endtime==125 and interval.frame:IsShown(),"fallback retains active/interval bars")
vertical.db.profile.enabled=true; vertical:UpdateVisibility(); vertical:OnDisable()
assert(timer.frame:IsShown(),"module disable restores hidden provider bars")
BigWigs.EnableModule=originalEnable
bars:Disable(owner)
assert(next(candy.var.handlers)==nil,"module reset removes all adjacent cached bars")
print("PASS Golden integration: "..locale.." encounter registration/options, live units, slows, armor/replies, character lockouts and fallbacks")
print("PASS Golden bars: timer refresh, interval tails, resource bars, live click callbacks, display fallback and owner cleanup")
