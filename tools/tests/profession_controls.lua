-- Run: lua tools/tests/profession_controls.lua
-- Exercise the actual control pass and subsequent native state changes.
local f = assert(io.open('addon/pfUI/skins/blizzard/professions.lua'))
local source = f:read('*a'); f:close()
local helpers = assert(source:match('(  local function WorkbenchPanel.-)  local frames ='))
local noop = function() end
local function widget()
  local w = {enabled=1, scripts={}}
  w.SetBackdrop, w.SetBackdropColor, w.SetPoint, w.SetTexCoord, w.SetTextInsets, w.SetTextColor = noop, noop, noop, noop, noop, noop
  w.SetPoint = function(self,point,...) self.points=self.points or {}; self.points[point]={...} end
  w.ClearAllPoints = function(self) self.points={} end
  w.SetAllPoints = function(self, frame) self.allPoints=frame end
  w.SetWidth = function(self,v) self.width=v end
  w.SetHeight = function(self,v) self.height=v end
  w.GetWidth = function(self) return self.width or 760 end
  w.GetHeight = function(self) return self.height or 548 end
  w.SetTexture = function(self, path) self.path=path end
  w.SetVertexColor = function(self, ...) self.color={...} end
  w.SetStatusBarColor = w.SetVertexColor
  w.SetStatusBarTexture = w.SetTexture
  w.CreateTexture = function(self) local t=widget(); self.textures=self.textures or {}; table.insert(self.textures,t); return t end
  w.SetHighlightTexture = function(self) self.highlight=widget() end
  w.GetHighlightTexture = function(self) return self.highlight end
  w.SetPushedTexture = function(self) self.pushed=widget() end
  w.GetPushedTexture = function(self) return self.pushed end
  w.SetNormalTexture = function(self) self.normal=widget() end
  w.GetNormalTexture = function(self) return self.normal end
  w.GetCheckedTexture = function(self) return self.checked end
  w.SetScript = function(self, key, value) self.scripts[key]=value end
  w.IsEnabled = function(self) return self.enabled end
  w.Enable = function(self) self.enabled=1 end
  w.Disable = function(self) self.enabled=0 end
  w.GetThumbTexture = function(self) return self.thumb end
  w.GetName = function(self) return self.name end
  return w
end
local compatFile = assert(io.open('addon/pfUI/compat/vanilla.lua'))
local compatSource = compatFile:read('*a'); compatFile:close()
pfUI = {hooks={}}
assert(load(assert(compatSource:match('(function hooksecurefunc.-)\ndo %-%- GetItemInfo'))))()

pfUI = {hooks={},media={['img:close']='close'}}
AzerothExpeditionUI = {media={root='AEUI\\'}}
local controls, panel = assert(load(helpers .. 'return WorkbenchControls, WorkbenchPanel'))()
local outer=widget(); outer.backdrop=widget(); outer.backdrop.width=476; outer.backdrop.height=318
outer.backdrop_shadow={Hide=function(self) self.hidden=true end}
panel(outer,16,760,548)
assert(outer.backdrop_shadow.hidden and outer.backdrop.allPoints==outer, "outer backdrop must not extend beyond wood")
assert(#outer.backdrop.textures>12, 'outer frame must tile edges instead of stretching an atlas')
local right, bottom = 0, 0
for _,texture in ipairs(outer.backdrop.textures) do
  assert(not texture.path:find('Title',1,true), 'title plaque must not cover the wood rail')
  assert(texture.width<=128 and texture.height<=128, 'wood strip was stretched')
  local point=texture.points.TOPLEFT
  assert(point[1]==outer, 'outer art must anchor to the real window')
  right=math.max(right,point[3]+texture.width)
  bottom=math.max(bottom,-point[4]+texture.height)
end
assert(right==760 and bottom==548, 'stale backdrop dimensions must not truncate outer art')
for _, name in ipairs({'Craft','TradeSkill'}) do
  local prefix = name == 'Craft' and 'CraftFrame' or 'TradeSkill'
  local template = name == 'Craft' and 'Craft' or 'TradeSkillSkill'
  local function add(key) local w=widget(); w.name=key; _G[key]=w; return w end
  for _, suffix in ipairs({'SubClassDropDown','InvSlotDropDown'}) do
    add(name..suffix); local b=add(name..suffix..'Button'); b.icon=widget(); b.backdrop=widget()
  end
  for _, suffix in ipairs({'ListScrollFrameScrollBar','DetailScrollFrameScrollBar'}) do
    local bar=add(name..suffix); bar.bg=widget(); bar.thumb=widget()
    for _, arrow in ipairs({'ScrollUpButton','ScrollDownButton'}) do
      local button=add(name..suffix..arrow); button.icon=widget(); button.pficonfade=widget()
      button.pficonfade.scripts.OnUpdate=noop
    end
  end
  add(name..'CollapseAllButton').icon=widget()
  for i=1,2 do add(template..i).icon=widget() end
  for _, suffix in ipairs({'DecrementButton','IncrementButton','CreateButton','CreateAllButton','CancelButton','FrameCloseButton'}) do add(name..suffix).icon=widget() end
  add(prefix..'SearchBox'); local clear=add(prefix..'SearchBoxClearButton')
  local click=function() return 'native search clear' end; clear.scripts.OnClick=click
  for _, suffix in ipairs({'Mats','Skill'}) do add(prefix..suffix..'CheckButton').checked=widget() end
  local rank, selected=add(name..'RankFrame'), add(name..'Highlight')
  controls(name,prefix,template,2)
  rank:SetStatusBarColor(0,0,1); selected:SetVertexColor(0,1,0)
  assert(rank.color[1]==.38 and selected.color[1]==1, 'native refresh restored default colors')
  local arrow=_G[name..'ListScrollFrameScrollBarScrollUpButton']
  arrow:Disable(); assert(arrow.icon.color[1]==.3 and arrow.enabled==0, 'disabled state lost')
  arrow:Enable(); assert(arrow.icon.color[1]==1, 'enabled arrow remains grey')
  assert(not arrow.pficonfade.scripts.OnUpdate, 'old grey tint loop still active')
  assert(clear.scripts.OnClick==click, 'native clear handler replaced')
  assert(_G[name..'SubClassDropDown'].aeuiProfessionArt, 'dropdown surface missed')
  local drop=_G[name..'SubClassDropDownButton']
  assert(drop.icon.points.CENTER[1]==drop.backdrop, 'arrow must align to right-hand visual box, not full dropdown hit area')
  assert(_G[template..2].icon.aeuiProfessionArt, 'fold control missed')
end
AzerothExpeditionUI=nil
controls('Missing','Missing','Missing',1) -- No media provider: no styling or global lookup.
-- Shared callbacks must preserve each target's receiver, order and nil returns.
local seen={}
local callback=function(value) table.insert(seen,value) end
local target={first=function(value) return value,nil,'tail' end,
  second=function(value) return value+1 end}
hooksecurefunc(target,'first',callback)
hooksecurefunc(target,'second',callback,true)
local a,b,c=target.first(10)
assert(a==10 and b==nil and c=='tail', 'post-hook lost the original return values')
assert(target.second(20)==21 and seen[1]==10 and seen[2]==20, 'shared callback mixed target chains')
print('PASS profession controls: both hosts, native color refresh, disabled arrows, scripts and fallback')
