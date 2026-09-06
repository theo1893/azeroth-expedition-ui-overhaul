-- lua tools/test_architotem_recall.lua [path/to/ArchiTotem/Data/Presets.lua]
ArchiTotemLocale = {["Totemic Recall"]="图腾召回"}
ArchiTotem_TotemData = {ArchiTotemButton_Recall={cooldown=6}}
local data=ArchiTotem_TotemData.ArchiTotemButton_Recall
local now,start,duration=100,0,0
GetTime=function() return now end
GetSpellName=function() return "图腾召回" end
ArchiTotem_GetSpellId=function() return 1 end
GetSpellCooldown=function() return start,duration,1 end
local casts,clears=0,0
CastSpellByName=function() casts=casts+1 end
ArchiTotem_UpdatePresetManagerDisplay=function() clears=clears+1 end
local function text() return {Hide=function(self) self.hidden=true end} end
EarthDurationText=text()
ArchiTotemButton_RecallCooldownText=text()
ArchiTotemButton_RecallCooldownBg=text()
dofile(arg[1] or "D:/Softwares/TurtleWoW/Interface/AddOns/ArchiTotem/Data/Presets.lua")
ArchiTotemActiveTotem={Earth={duration=120}}
ArchiTotem_RecallTotems() -- Failed cast: no client cooldown.
assert(casts==1 and not data.cooldownstarted and ArchiTotemActiveTotem.Earth and clears==0)
start,duration=100,1.5 -- GCD alone cannot confirm recall.
ArchiTotem_SyncRecallCooldown()
assert(not data.cooldownstarted and ArchiTotemActiveTotem.Earth)
start,duration=100.2,6 -- Delayed server confirmation.
now=100.3
ArchiTotem_SyncRecallCooldown()
assert(data.cooldownstarted==100.2 and data.cooldown==6 and not ArchiTotemActiveTotem.Earth and clears==1)
ArchiTotemActiveTotem={Earth={duration=120}}
now=101
ArchiTotem_RecallTotems() -- Click during existing cooldown cannot restart it or clear new totems.
assert(data.cooldownstarted==100.2 and ArchiTotemActiveTotem.Earth and clears==1)
now,start,duration=110,0,0
ArchiTotem_SyncRecallCooldown()
assert(not data.cooldownstarted and ArchiTotemButton_RecallCooldownText.hidden)
ArchiTotem_RecallTotems() -- Pending failed attempt must expire.
now=114; start=114; duration=6
ArchiTotem_SyncRecallCooldown()
assert(ArchiTotemActiveTotem.Earth and clears==1)
print("PASS recall: failed cast, GCD, delayed confirmation, repeated click, expiry and stale pending")
