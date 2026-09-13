-- Run: lua tools/tests/nameplate_threat.lua
table.getn = table.getn or function(t) return #t end
string.gfind = string.gfind or string.gmatch
math.mod = math.mod or math.fmod
local now, guid, victim, combat = 10, '0x0000000000001234', 'Tank', true
local sent = {}
function GetTime() return now end
function UnitExists() return true, guid end
function UnitName(unit) return unit == 'player' and 'Me' or victim end
function UnitAffectingCombat() return combat end
function UnitIsPlayer() return false end
function UnitIsDead() return false end
function UnitCanAttack() return true end
function GetNumRaidMembers() return 10 end
function GetNumPartyMembers() return 0 end
function SendAddonMessage(...) sent[#sent+1] = {...} end
AzerothExpeditionUI = {media={root=''}, RegisterModule=function(self, _, m) self.units=m end}
dofile('addon/AzerothExpeditionUI/Modules/UnitFrames.lua')
local u = AzerothExpeditionUI.units
u.nameplateMode = 'dps'
local function packet(msg, sender)
  u:ReceiveNameplateThreat('TWT', msg, 'RAID', sender or 'Me')
end
local detail = 'TWTv4=Tank:1:1000:100:1;Me:0:1000:100:1;'
u:UpdateNameplateThreat()
assert(sent[1][1] == 'TWT_UDTSv4' and sent[1][2] == 'limit=40')
now=10.6; u:UpdateNameplateThreat(); assert(#sent==1, 'one outstanding request only')
packet(detail, 'Other'); assert(not u.threatSnapshot, 'other player packets must be ignored')
packet('TWTv4=Tank:1:1000:100:1;Me:0:nan:100:1;')
assert(not u.threatSnapshot, 'invalid numbers must reject the snapshot')
u:ReceiveNameplateThreat('OTHER', detail, 'RAID', 'Me')
assert(not u.threatSnapshot, 'unrelated addon messages must be ignored')
u:ReceiveNameplateThreat('TWT_UDTSv4', 'reply:' .. detail, 'RAID', 'Other')
assert(not u.threatSnapshot, 'alternate envelopes still require our own reply')
u:ReceiveNameplateThreat('TWT_UDTSv4', 'reply:' .. detail, 'RAID', 'Me')
assert(u.threatSnapshot and u.threatEnvelope == 'TWT_UDTSv4/RAID/Me',
  'accept the same TWT envelope as ShaguDPS and expose its actual prefix')
assert(u:GetNameplateThreatRisk(guid, 'tank') == 'danger', 'high relative threat must warn')
for _, mode in ipairs({'dps', 'healer'}) do
  u.nameplateMode = mode
  for _, melee in ipairs({true, false}) do
    u.threatSnapshot.rows.Me.melee = melee
    for _, sample in ipairs({{699, false}, {700, 'warning'}, {849, 'warning'}, {850, 'danger'}}) do
      u.threatSnapshot.rows.Me.value = sample[1]
      assert((u:GetNameplateThreatRisk(guid, 'tank') or false) == sample[2],
        'healer/dps thresholds must be 70/85 regardless of melee range')
    end
  end
end
u.nameplateMode = 'dps'
assert(not u:GetNameplateThreatRisk('0x1235', 'tank'), 'target data cannot colour another mob')
now=13; assert(not u:GetNameplateThreatRisk(guid, 'tank'), 'old snapshots expire')
u:ClearNameplateThreat(); u:UpdateNameplateThreat(); assert(#sent==1, 'target changes quarantine requests')
now=15; u:UpdateNameplateThreat(); guid='0x1235'; packet(detail)
assert(not u.threatSnapshot, 'a changed target invalidates pending response')
u:ClearNameplateThreat(); now=17; u.nameplateMode='tank'; victim='Me'; guid='0x1234'
u:UpdateNameplateThreat(); assert(sent[#sent][1]=='TWT_UDTSv4_TM')
packet('TWTv4=Me:1:1000:100:1;Other:0:800:80:1;#TMTv1=Same:4660:Other:80;Same:4661:Other:95;Same:18446744073709551615:Other:75;')
assert(u:GetNameplateThreatRisk('0x1234','self')=='warning')
assert(u:GetNameplateThreatRisk('0x1235','self')=='danger', 'same names remain GUID isolated')
assert(u:GetNameplateThreatRisk('0xffffffffffffffff','self')=='warning', '64-bit decimal GUID stays exact')
assert(not u:GetNameplateThreatRisk('0x1235','other'), 'lost aggro must not use stale runner-up data')
for _, sample in ipairs({{69.9, false}, {70, 'warning'}, {84.9, 'warning'}, {85, 'danger'}}) do
  u.threatSnapshot.mobs['1235'].percent = sample[1]
  assert((u:GetNameplateThreatRisk('0x1235','self') or false) == sample[2], 'TMT thresholds must be 70/85')
  u.threatSnapshot.mobs['1234'] = nil
  u.threatSnapshot.rows.Other.value = sample[1] * 10
  assert((u:GetNameplateThreatRisk('0x1234','self') or false) == sample[2], 'tank target fallback uses 70/85')
end
u:ClearNameplateThreat(); now=19; u:UpdateNameplateThreat()
packet('TWTv4=Me:1:1000:100:1;#TMTv1=')
assert(not u:GetNameplateThreatRisk('0x1235','self'), 'empty group snapshot removes old entries')
combat=false; u:UpdateNameplateThreat(); assert(not u.threatSnapshot and not u.threatPending)
-- Frequent roster updates must not keep pushing target quarantine into the future.
function CreateFrame()
  return {events={}, scripts={},
    RegisterEvent=function(self, name) self.events[name]=true end,
    SetScript=function(self, name, callback) self.scripts[name]=callback end}
end
u:EnsureNameplateThreat()
combat=true
u:ClearNameplateThreat()
local before = #sent
for i=1,4 do
  now=now+.5
  for _, name in ipairs({'RAID_ROSTER_UPDATE', 'PARTY_MEMBERS_CHANGED'}) do
    if u.threatFrame.events[name] then
      event=name; u.threatFrame.scripts.OnEvent()
    end
  end
  u.threatFrame.scripts.OnUpdate()
end
assert(#sent > before, 'roster refreshes must not starve threat polling')

-- RGB interpolation changes colour, not the existing discrete opacity tiers.
guid='0x1234'; combat=true
for _, mode in ipairs({'dps','healer','tank'}) do
  u.nameplateMode=mode
  local base=mode=='tank' and {.38,.62,.48} or {54/255,191/255,224/255}
  local warning, danger={1,.72,.18},{1,.32,.12}
  for _, sample in ipairs({{0,base},{50,base},{60,{(base[1]+1)/2,(base[2]+.72)/2,(base[3]+.18)/2}},
    {70,warning},{77.5,{1,.52,.15}},{85,danger},{120,danger}}) do
    local ratio=sample[1]
    u.threatSnapshot={time=now,guid='1234',holder='Tank',mobs={['1234']={percent=ratio}},
      rows={Tank={value=1000},Me={value=ratio*10}}}
    local alpha, colour, _, displayedRatio=u:GetNameplateStyle(mode,false,false,mode=='tank' and 'self' or 'tank',guid)
    assert(displayedRatio==ratio,'rail receives valid ratios including zero and over-cap values')
    for i=1,3 do assert(math.abs(colour[i]-sample[2][i])<.00001,'linear RGB endpoints/midpoints') end
    local expected=ratio>=85 and 1 or ratio>=70 and .9 or mode=='tank' and .85 or .75
    assert(alpha==expected,'gradient must preserve opacity tiers')
  end
  u.threatSnapshot.time=now-3
  assert(select(4,u:GetNameplateStyle(mode,false,false,mode=='tank' and 'self' or 'tank',guid))==nil,
    'expired data must hide the rail, not display zero')
  local _, colour=u:GetNameplateStyle(mode,false,false,mode=='tank' and 'self' or 'tank',guid)
  for i=1,3 do assert(math.abs(colour[i]-base[i])<.00001,'expired data restores base colour') end
end
print('PASS threat gradient: all roles, endpoints, midpoints, opacity tiers, stale fallback')
event='PLAYER_TARGET_CHANGED'; u.threatFrame.scripts.OnEvent()
assert(not u.threatPending and u.threatNext == now+1.5, 'target changes still quarantine replies')
print('PASS server threat: polling, origin checks, stale/invalid packets, target and GUID isolation, roles')

-- Outdoor parties use the same request path; taking aggro must not hide valid data.
function GetNumRaidMembers() return 0 end
function GetNumPartyMembers() return 1 end
for _, mode in ipairs({'dps','healer'}) do
  u.nameplateMode=mode; victim='Me'; guid='0x1234'; combat=true
  u:ClearNameplateThreat(); now=now+2
  u:UpdateNameplateThreat()
  assert(sent[#sent][3]=='PARTY','ordinary parties must request on PARTY')
  u:ReceiveNameplateThreat('TWT','TWTv4=Me:1:1000:100:1;Other:0:300:30:1;','PARTY','Me')
  local _, colour, _, ratio=u:GetNameplateStyle(mode,false,true,'self',guid)
  assert(ratio==100 and colour[1]==1 and colour[2]==.32,
    'self-held aggro must retain a full danger rail in DPS and healer modes')
  assert(select(4,u:GetNameplateStyle(mode,true,true,'self',guid))==nil,'friendly plates have no rail')
end
print('PASS outdoor party: PARTY replies, DPS/healer self aggro, friendly exclusion')

-- Preview needs neither combat nor a GUID and never fabricates server snapshots.
AzerothExpeditionUI.Print=function() end
combat=false; u.threatSnapshot=nil
assert(u:SetNameplateMode('mock'))
local mockStart=now
for _, sample in ipairs({{0,0},{6,50},{9,75},{12,100},{13,100},{14,0}}) do
  now=mockStart+sample[1]
  assert(select(4,u:GetNameplateStyle('dps',false,true,nil,nil))==sample[2])
  assert(select(4,u:GetNameplateStyle('dps',false,false,nil,nil))==nil)
  assert(select(4,u:GetNameplateStyle('dps',true,true,nil,nil))==nil)
end
local beforeMock=#sent
combat=true; u:UpdateNameplateThreat()
assert(#sent==beforeMock and not u.threatSnapshot,'mock stays local and sends no requests')
assert(u:SetNameplateMode('mock off') and not u.threatMockStart)
assert(select(4,u:GetNameplateStyle('dps',false,true,nil,guid))==nil)
print('PASS threat mock: growth, full hold, loop, target scope, no network, off fallback')
