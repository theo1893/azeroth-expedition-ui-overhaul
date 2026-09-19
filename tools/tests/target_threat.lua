-- lua tools/tests/target_threat.lua
-- Exercise the shared threat consumer and pfUI's real aura placement together.
setfenv = setfenv or function() end
unpack = unpack or table.unpack
table.getn = table.getn or function(t) return #t end
string.gfind = string.gfind or string.gmatch
math.mod = math.mod or math.fmod
floor, ceil, abs = math.floor, math.ceil, math.abs
local writes, now, guid, hostile, dead, combat, sent = 0, 10, "0x1234", true, false, true, 0
local Node = {}; Node.__index = function(self, key)
  if Node[key] then return Node[key] end
  if string.find(key, "^%u") then return function() end end
end
local function node(parent) return setmetatable({parent=parent,visible=true,width=23,height=23},Node) end
function Node:SetPoint(...) self.point={...}; writes=writes+1 end
function Node:GetPoint() return unpack(self.point or {}) end
function Node:SetWidth(v) self.width=v; writes=writes+1 end
function Node:SetHeight(v) self.height=v; writes=writes+1 end
function Node:GetWidth() return self.width end
function Node:GetHeight() return self.height end
function Node:SetFrameLevel(v) self.level=v end
function Node:GetFrameLevel() return self.level or 1 end
function Node:CreateTexture() return node(self) end
function Node:CreateFontString() return node(self) end
function Node:SetText(v) self.text=v end
function Node:SetValue(v) self.value=v end
function Node:SetStatusBarColor(...) self.colour={...} end
function Node:SetStatusBarTexture(v) self.fill=node(self); self.fill.texture=v end
function Node:GetStatusBarTexture() return self.fill end
function Node:Show() self.visible=true end
function Node:Hide() self.visible=false end
function Node:IsShown() return self.visible end
function Node:EnableMouse(v) self.mouse=v end
function Node:GetName() return self.name end
function Node:GetBackdropBorderColor() return .8,0,0,1 end
function CreateFrame(_,name,parent) local f=node(parent); f.name=name; return f end
function GetTime() return now end
function UnitExists() return true,guid end
function UnitName(unit) return unit=="player" and "Me" or unit=="targettarget" and "Tank" or "Dummy" end
function UnitIsUnit() return false end
function UnitCanAttack() return hostile end
function UnitIsPlayer() return false end
function UnitIsDead() return dead end
function UnitAffectingCombat() return combat end
function GetNumRaidMembers() return 0 end
function GetNumPartyMembers() return 1 end
function SendAddonMessage() sent=sent+1 end
function GetBorderSize() return 3,3 end
function CooldownFrame_SetTimer() end
function UnitBuff(_,i) if i<=16 then return "buff",1 end end
function UnitDebuff(_,i) if i<=16 then return "debuff",1 end end
UIParent,SlashCmdList,StaticPopupDialogs=node(),{},{}
DebuffTypeColor={none={r=.8,g=0,b=0}}
C={appearance={border={force_blizz="0"}},unitframes={}}
local route=true
pfUI={api={},media={},font_unit="test-font",GetEnvironment=function() return _G end,
  GetExpeditionComponentOwner=function() return route and "unitframes" or nil end}
dofile("addon/pfUI/api/unitframes.lua")
local target=node(UIParent); target.name="pfTarget"; target.label="target"
target.width,target.height=240,61
target.hp,target.power=node(target),node(target)
target.hp.bar,target.power.bar=node(target.hp),node(target.power)
target.hp.backdrop,target.power.backdrop=node(),node()
target.config={portraitheight="-1",buffs="TOPRIGHT",debuffs="BOTTOMRIGHT",bufflimit=16,debufflimit=16,
  buffsize=23,debuffsize=23,buffperrow=8,debuffperrow=8,bufffilter="none",debufffilter="none",
  selfdebuff="0",debuff_indicator="0"}
target.buffs,target.debuffs={},{}
for _,icons in ipairs({target.buffs,target.debuffs}) do
  for i=1,16 do
    icons[i]=node(target); icons[i].texture=node(); icons[i].backdrop=node()
    icons[i].stacks=node(); icons[i].cd=node(); icons[i]:SetFrameLevel(12)
  end
end
pfUI.uf.target=target
pfUI.uf.DetectBuff=function(_,unit,i) return UnitBuff(unit,i) end
AzerothExpeditionUI={media={root=""},db={unitframes={enabled=true}},Print=function() end,
  RegisterModule=function(self,_,value) self.module=value end}
dofile("addon/AzerothExpeditionUI/Modules/UnitFrames.lua")
local u=AzerothExpeditionUI.module; u.nameplateMode="dps"
assert(u:ApplyThinShell(target,"target"))
local rail=target.aeuiTargetThreatRail
assert(rail and not rail:IsShown() and rail.height==12 and rail.mouse==false)
assert(target.aeuiBottomAuraInset==12 and target.width==240 and target.height==61)
local function checkAuras(offset)
  pfUI.uf:RefreshUnit(target,"aura")
  assert(target.debuffs[1].point[5]==-5-offset and target.debuffs[9].point[5]==-33-offset)
  assert(target.debuffs[8].point[4]==-196 and target.buffs[1].point[5]==5)
  assert(target.debuffs[1].level==12 and target.debuffs[1].width==23)
end
checkAuras(12)
for _,ratio in ipairs({0,42,70,92,115}) do
  u.threatSnapshot={guid="1234",time=now,holder="Tank",mobs={},rows={Tank={value=100},Me={value=ratio}}}
  u:UpdateTargetThreat()
  assert(rail:IsShown() and rail.value==math.min(100,ratio) and rail.text.text==ratio.."%")
  assert(target.aeuiThinShellSlices.centre.height==65 and target.aeuiBottomAuraInset==12)
  local before=writes; u:UpdateTargetThreat(); assert(writes==before,"steady data rewrote geometry")
end
assert(sent==0,"display must not issue network requests")
now=13; u:UpdateTargetThreat()
assert(not rail:IsShown() and target.aeuiThinShellSlices.centre.height==53)
checkAuras(12)
u.threatSnapshot.time=now; hostile=false; u:UpdateTargetThreat(); assert(not rail:IsShown())
hostile=true; dead=true; u:UpdateTargetThreat(); assert(not rail:IsShown())
dead=false; guid="0x1235"; u:ClearNameplateThreat(); assert(not rail:IsShown())
checkAuras(12)
guid="0x1234"; u.threatMockStart=now; now=now+6; u:UpdateTargetThreat()
assert(rail:IsShown() and rail.text.text=="50%" and sent==0)
u:SetTargetThreatEnabled(false); assert(not rail:IsShown() and not target.aeuiBottomAuraInset)
checkAuras(0)
u:SetTargetThreatEnabled(true); checkAuras(12)
u.nameplateMode=nil; u:ApplyTargetThreat(); assert(not rail:IsShown() and not target.aeuiBottomAuraInset)
u.nameplateMode="dps"; u:ApplyTargetThreat(); checkAuras(12)
u.threatMockStart=nil; combat=false; u:UpdateNameplateThreat(); assert(not rail:IsShown())
checkAuras(12)
route=false; u:ApplyThinShell(target,"target")
assert(not rail:IsShown() and not target.aeuiBottomAuraInset and not target.aeuiThinShell)
route=true; u:ApplyThinShell(target,"target")
AzerothExpeditionUI.db.unitframes.enabled=false; u:ApplyThinShell(target,"target")
assert(not rail:IsShown() and not target.aeuiBottomAuraInset)
local other=node(); u:ApplyTargetThreat(other); assert(not other.aeuiTargetThreatRail)
print("PASS target threat: shared ratios, zero/overflow, stable two-row Debuffs, stale/target/death/hostile cleanup, mock, scope and fallback")
