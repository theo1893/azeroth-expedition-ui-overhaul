-- Run: lua tools/tests/bottom_layout.lua
table.getn = table.getn or function(t) return #t end
unpack = unpack or table.unpack
local class, combat = 'WARRIOR', false
function UnitName() return 'LayoutTest' end
function GetRealmName() return 'Realm' end
function UnitClass() return 'Warrior', class end
function InCombatLockdown() return combat end
local function frame(name, scale)
  return {
    GetName=function() return name end,
    GetScale=function(self) return self.scale or scale end,
    GetNumPoints=function() return 1 end,
    GetPoint=function() return "CENTER", UIParent, "CENTER", 0, 0 end,
    SetScale=function(self,v) self.scale=v end,
    GetLeft=function() return 50 end, GetBottom=function() return 160 end,
    SetParent=function() end, ClearAllPoints=function() end,
    SetPoint=function(self,...) self.point={...} end,
    SetWidth=function() end, SetHeight=function() end,
  }
end
UIParent={}
pfActionBarStances=frame('pfActionBarStances',1)
local main=frame('pfActionBarMain',1.2)
pfUI={bars={[1]=main},castbar={player=frame('cast1',1),target=frame('cast2',1)},
  swingtimer={mainhand=frame('swing',1),ranged=frame('ranged',1)}}
pfUI_config={position={},castbar={player={},target={}},unitframes={}}
AzerothExpeditionUI={media={root=''}, db={actionbars={enabled=true,fieldKitBound=true,combatFocusBackup={}}},
  RegisterModule=function(self,_,m) self.actions=m end}
dofile('addon/AzerothExpeditionUI/Modules/ActionBars.lua')
local a=AzerothExpeditionUI.actions
a.SetFieldKitDocking=function() end -- skin/group hooks have their own provider lifecycle
combat=true; assert(not a:ApplyBottomLayoutTrial())
combat=false; assert(a:ApplyBottomLayoutTrial())
assert(pfUI_config.position.pfActionBarMain.ypos==80 and pfUI_config.position.pfActionBarMain.xpos==-18)
assert(pfUI_config.position.pfPlayerCastbar.ypos==183 and pfUI_config.position.pfTargetCastbar.ypos==195)
assert(pfUI_config.position.pfSwingTimerMainhand.ypos==171)
assert(pfUI_config.position.pfPlayerCastbar.xpos==-22, "warrior readouts return to the shared center")
a:ApplyStanceDockPosition(true)
assert(pfActionBarStances.point[1]=='TOPRIGHT' and pfActionBarStances.point[2]==main and pfActionBarStances.point[4]==-64,
  'warrior stance follows the main action bar, left of the marker controls')
main.point={'custom'}; assert(not a:ApplyBottomLayoutTrial() and main.point[1]=='custom', 'one-time migration preserves later edits')
local state=AzerothExpeditionUI.db.actionbars.focusUnitDefaultProfiles['LayoutTest - Realm']
state.bottomTrialVersion=nil; state.bottomTrialStance={xpos=50,ypos=160}
assert(a:ApplyBottomLayoutTrial() and not state.bottomTrialStance and main.point[1]=='custom',
  'upgrade clears fixed stances without resetting a moved main bar')
state.bottomTrialApplied=nil; state.bottomTrialVersion=nil; state.optOut=true
assert(not a:ApplyBottomLayoutTrial(), 'restored layouts remain opted out')
print('PASS bottom layout: migration, readouts, warrior position, combat deferral, opt-out')

local trinket=frame('TrinketMenu_MainFrame',.88)
TrinketMenu_MainFrame=trinket
local first=frame('TrinketMenu_Trinket0',.88)
TrinketMenu_Trinket0=first
function first:GetPoint() return 'TOPLEFT',trinket,'TOPLEFT',8,-8 end
function first:GetHeight() return 32 end
first.aeuiTrinketKitPocketV1={GetHeight=function() return 40 end,
  GetTop=function() error('must not read screen coordinates for docking') end}
local top=frame('pfActionBarTop',1.2)
pfUI.bars[6]=top
a.trinketDockApplied=true
a:ApplyTrinketDockPosition(true)
assert(trinket.point[2]==top and trinket.point[3]=='TOPRIGHT' and trinket.point[5]==4,
  'trinkets must follow the actual top action row with a local inset')
print('PASS trinket docking: relative anchor, local art inset, no screen readback')

AzerothExpeditionUI.db.actionbars.supplyProfiles={['LayoutTest - Realm']={slots={}}}
a.supplyFrame=frame('Supply',1)
assert(a:ApplySupplyDockPosition())
assert(a.supplyFrame.point[1]=='BOTTOMRIGHT' and a.supplyFrame.point[2]==main
  and a.supplyFrame.point[3]=='BOTTOMLEFT' and a.supplyFrame.point[5]==0,
  'supply growth must leave its bottom fixed above stance and marker controls')
print('PASS supply docking: fixed bottom, upward growth')

local function background(alpha)
  return {GetAlpha=function(self) return self.alpha or alpha end,
    SetAlpha=function(self, value) self.alpha=value end}
end
pfActionBarStances.backdrop=background(.8)
pfActionBarStances.backdrop_shadow=background(.6)
pfActionBarStances.backdrop.aeuiStanceAlpha=.8
pfActionBarStances.backdrop_shadow.aeuiStanceAlpha=.6
local native={edgeFile='pfui'}
local backdrop={native=native}
function backdrop:GetBackdrop() return self.native end
function backdrop:SetBackdrop(v) self.native=v end
function backdrop:GetBackdropColor() return .1,.2,.3,1 end
function backdrop:GetBackdropBorderColor() return .4,.5,.6,1 end
function backdrop:SetBackdropColor() end
function backdrop:SetBackdropBorderColor() end
local texture={SetAllPoints=function() end,SetTexture=function() end,SetTexCoord=function() end,
  SetBlendMode=function() end,SetVertexColor=function() end,
  Show=function(self) self.shown=true end,Hide=function(self) self.shown=false end}
function backdrop:CreateTexture() return texture end
pfUI.bars[11]={[1]={backdrop=backdrop}}
a:ApplyStanceDockPosition(true)
assert(pfActionBarStances.backdrop.alpha==.8 and pfActionBarStances.backdrop_shadow.alpha==.6,
  'shared AEUI rail holder must remain visible')
assert(backdrop.native==nil and texture.shown, 'remove only native button backdrop, keep AEUI slot art')
a:ApplyStanceDockPosition(true)
a:ApplyStanceDockPosition(false)
assert(backdrop.native==native and not texture.shown, 'restore native button backdrop on disable')
print('PASS warrior stance: AEUI art visible, native button backdrop removed, reversible')
