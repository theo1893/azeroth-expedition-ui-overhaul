-- Run: lua tools/tests/distance_tag.lua
unpack = unpack or table.unpack
table.getn = table.getn or function(t) return #t end
local function noop() end
local function node()
  local n = { shown=true, width=20, height=20, points=0, scripts={}, uv={0,1,0,1} }
  setmetatable(n,{__index=function(_,k) if k:match('^%u') then return noop end end})
  function n:SetPoint(...) self.point={...}; self.points=self.points+1 end
  function n:GetPoint() return unpack(self.point or {'CENTER',UIParent,'CENTER',0,0}) end
  function n:GetAlpha() return self.alpha or 1 end
  function n:SetAlpha(v) self.alpha=v end
  function n:SetTexCoord(...) self.uv={...} end
  function n:GetTexCoord() return unpack(self.uv) end
  function n:SetWidth(v) self.width=v end
  function n:SetHeight(v) self.height=v end
  function n:GetWidth() return self.width end
  function n:GetHeight() return self.height end
  function n:SetText(v) self.value=v end
  function n:GetText() return self.value end
  function n:GetStringWidth() return #(self.value or '')*6 end
  function n:SetTextColor(...) self.colour={...} end
  function n:SetTexture(v) self.texture=v end
  function n:Show() self.shown=true end
  function n:Hide() self.shown=false end
  function n:IsShown() return self.shown end
  function n:SetScript(k,v) self.scripts[k]=v end
  function n:CreateTexture() return node() end
  function n:CreateFontString() return node() end
  return n
end
function CreateFrame() return node() end
UIParent=node()
GetBorderSize=function() return 1,1 end
GetLocale=function() return 'zhCN' end
UnitClass=function() return 'HUNTER' end
UpdateMovable=noop
SlashCmdList={}
local now,dist,sight,behind,melee,target,sounds=1,4.8,true,false,true,true,0
function GetTime() return now end
function UnitExists(unit) return unit=='pet' or target end
function UnitAffectingCombat() return true end
function GetNumPartyMembers() return 0 end
function GetNumRaidMembers() return 0 end
function PlaySoundFile() sounds=sounds+1 end
function UnitXP(op,_,unit,kind)
  if op=='distanceBetween' then
    if unit=='pet' then return 12.3 end
    if kind then return melee and 0 or 9 end
    return dist
  elseif op=='inSight' then return sight
  elseif op=='behind' then return behind end
  return true
end
function strsplit(_,s) local t={} for v in s:gmatch('[^,]+') do t[#t+1]=v end return unpack(t) end
pfUI_config={unitframes={distance_indicator='1',distance_indicator_show_prefix='1',distance_indicator_sound_only_group='1',distance_indicator_pet_mode='1'}}
C=pfUI_config
pfUI={api={},uf={player=node(),target=node()},movables={},media={['img:oeye']='native-open',['img:ceye']='native-closed'},
  GetExpeditionComponentOwner=function() return 'unitframes' end,
  RegisterModule=function(_,_,_,f) f() end}
AzerothExpeditionUI={media={root=''},db={unitframes={enabled=true}},
 RegisterModule=function(self,_,m) self.module=m end}
dofile('addon/AzerothExpeditionUI/Modules/UnitFrames.lua')
local adapter=AzerothExpeditionUI.module
adapter:ApplyDistanceIndicator() -- provider may not exist yet
assert(pfUI.aeuiDistanceIndicatorSkin)
dofile('addon/pfUI/modules/unitxp.lua')
local f=pfUI.distanceIndicator
local originalFramePoint, originalTextPoint = {f:GetPoint()}, {f.text:GetPoint()}
local function tick() now=now+.2; this=f; f.scripts.OnUpdate() end
tick()
assert(f.text:GetText()=='4.8' and sounds==0, 'solo audio gating must not skip facing readout')
assert(f.icon.texture:find('DistanceEyeOpenV1') and math.abs(f.icon.height-11.9)<.001)
assert(f.aeuiDistanceArt.slices[1]:IsShown() and f.petText:GetText()=='12.3')
local function assertReadoutClearance()
  local pieces=f.aeuiDistanceArt.slices
  local rightCapLeft=pieces[1].point[4]+pieces[1].width+pieces[2].width
  assert(rightCapLeft-math.max(f.text:GetWidth(),f.text:GetStringWidth())>=6,
    'digits need 6 UI clearance before fixed brass cap')
  assert(pieces[3].width==14 and pieces[3].uv[1]==116/256,
    'all brass pixels must stay in fixed right cap')
end
assertReadoutClearance()
assert(f.icon.width==17 and f.icon:GetAlpha()==.8)
local function assertDock()
  local art=f.aeuiDistanceArt
  assert(f.point[1]=='BOTTOM' and f.point[2]==art.dock and f.point[3]=='CENTER' and f.point[5]==0)
  assert(art.dock.point[1]=='RIGHT' and art.dock.point[2]==pfUI.uf.target and art.dock.point[3]=='LEFT',
    'dock must follow the vertical center of the primary frames')
  assert(f.text.point[5]==-(tonumber(C.unitframes.distance_indicator_font_size) or 13)/2,
    'tag background must be vertically centered in the gap')
  local textWidth=math.max(f.text:GetWidth(),f.text:GetStringWidth())
  local left=art.slices[1].point[4]
  local width=art.slices[1].width+art.slices[2].width+art.slices[3].width
  assert(math.abs(f.text.point[4]-textWidth/2+left+width/2)<.001,
    'the entire tag, not just digits, must be centered')
  assert(f.text.point[1]=='BOTTOM', 'prefix grows upward')
end
assertDock()
local frameWrites,textWrites,dockWrites=f.points,f.text.points,f.aeuiDistanceArt.dock.points
local writes=f.icon.points
tick(); assert(f.icon.points==writes,'stable readings must not relayout')
assert(f.points==frameWrites and f.text.points==textWrites and f.aeuiDistanceArt.dock.points==dockWrites,
  'stable docking must not rewrite anchors')
sight=false; tick(); assert(f.icon.texture:find('DistanceEyeBlockedV1'))
behind=true; tick(); assert(f.text:GetText()=='近战\n4.8'); assertReadoutClearance(); assertDock()
melee=false; tick(); assert(f.text:GetText()=='盲区\n4.8')
C.unitframes.distance_indicator_outsight_icon='0'; tick(); assert(not f.icon:IsShown())
C.unitframes.distance_indicator_outsight_icon='1'; dist=123.4; tick()
assert(f.aeuiDistanceArt.slices[2].width>47,'long readout must expand center')
assertReadoutClearance(); assertDock()
local player=pfUI.uf.player
pfUI.uf.player=nil; tick()
assert(f.point[1]==originalFramePoint[1] and not f.aeuiDistanceArt.framePoint,'missing frame restores standalone location')
pfUI.uf.player=player; tick(); assertDock()
target=false; tick(); assert(not f.aeuiDistanceArt.slices[1]:IsShown() and f.petText:IsShown())
target=true; dist=nil; tick(); assert(not f.aeuiDistanceArt.slices[1]:IsShown())
dist=4.8; melee=true; behind=false; tick()
AzerothExpeditionUI.db.unitframes.enabled=false; adapter:ApplyDistanceIndicator()
assert(not f.aeuiDistanceArt.slices[1]:IsShown() and f.icon.height==20 and f.icon.uv[2]==1 and f.icon:GetAlpha()==1)
for i=1,5 do
  assert(f.point[i]==originalFramePoint[i] and f.text.point[i]==originalTextPoint[i], 'fallback restores original anchor')
end
tick(); assert(f.text:GetText()=='打脸\n4.8' and f.icon.texture=='native-closed')
f.icon:SetWidth(24); f.icon:SetHeight(24)
AzerothExpeditionUI.db.unitframes.enabled=true; adapter:ApplyDistanceIndicator(); tick()
assert(f.text:GetText()=='4.8')
AzerothExpeditionUI.db.unitframes.enabled=false; adapter:ApplyDistanceIndicator()
assert(f.icon.width==24 and f.icon.height==24,'reenable must preserve current native geometry on rollback')
-- Direction atlas: ahead/left/behind/right, player rotation and missing data.
math.atan2 = math.atan2 or math.atan
math.mod = math.mod or math.fmod
local tx,ty,heading=10,0,0
function UnitPosition(unit) if unit=="player" then return 0,0,0 end return tx,ty,0 end
pfQuestCompat={GetPlayerFacing=function() return heading end}
assert(adapter:GetDistanceDirectionCell()==0)
tx,ty=0,10; assert(adapter:GetDistanceDirectionCell()==27)
tx,ty=-10,0; assert(adapter:GetDistanceDirectionCell()==54)
tx,ty=0,-10; assert(adapter:GetDistanceDirectionCell()==81)
tx,ty,heading=10,0,math.pi/2; assert(adapter:GetDistanceDirectionCell()==81)
heading=0
AzerothExpeditionUI.db.unitframes.enabled=true; adapter:ApplyDistanceIndicator(); tick()
assert(f.aeuiDistanceArt.direction:IsShown() and f.aeuiDistanceArt.direction.uv[1]==0)
assertDock()
assert(f.aeuiDistanceArt.direction.width==16 and f.aeuiDistanceArt.direction.height==16)
assert(f.aeuiDistanceArt.direction.texture=="UnitFrames\\DistanceDirectionV1")
tx,ty=0,10; tick()
assert(f.aeuiDistanceArt.direction.uv[1]==11*32/512 and f.aeuiDistanceArt.direction.uv[3]==32/256,
  'left direction must use cell 27 in the new 16-column atlas')
local withDirection=f.aeuiDistanceArt.slices[2].width
tx=nil; tick()
assert(not f.aeuiDistanceArt.direction:IsShown())
assert(f.aeuiDistanceArt.slices[2].width==withDirection-20)
assert(f.text:GetText()=='4.8', 'coordinate failure must preserve distance')
tx,ty=0,0; assert(adapter:GetDistanceDirectionCell()==nil)
UnitPosition=nil; assert(adapter:GetDistanceDirectionCell()==nil)
AzerothExpeditionUI.db.unitframes.enabled=false; adapter:ApplyDistanceIndicator()
assert(not f.aeuiDistanceArt.direction:IsShown())
print('PASS distance tag: real provider states, solo audio, pet/no target, caching, long values, fallback')

-- The default gap must migrate once per character and preserve later edits.
UnitName=function() return 'Test' end
GetRealmName=function() return 'Realm' end
pfUI.uf={}
pfUI_config.unitframes.player={}
pfUI_config.unitframes.target={}
pfUI_config.unitframes.ttarget={}
local state={layoutVersion=8}
AzerothExpeditionUI.db.actionbars={focusUnitDefaultProfiles={['Test - Realm']=state}}
dofile('addon/AzerothExpeditionUI/Modules/ActionBars.lua')
local bars=AzerothExpeditionUI.module
assert(bars:ApplyFocusUnitDefaults() and state.layoutVersion==9)
local positions=pfUI_config.position
assert(positions.pfPlayer.ypos==322 and positions.pfTarget.ypos==322,
  'both primary frames move down by two 30 UI aura rows')
assert((positions.pfTarget.xpos-positions.pfPlayer.xpos-bars.focusUnitWidth)*bars.focusUnitScale==160)
positions.pfPlayer.xpos=-200
assert(not bars:ApplyFocusUnitDefaults() and positions.pfPlayer.xpos==-200)
state.layoutVersion=6; state.optOut=true
assert(not bars:ApplyFocusUnitDefaults() and positions.pfPlayer.xpos==-200)
print('PASS distance gap: per-character defaults, one-time migration, manual edits and opt-out')
