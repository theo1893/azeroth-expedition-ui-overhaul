unpack = unpack or table.unpack
local N = {}; N.__index=N
local function node() return setmetatable({color={0,0,0,1},border={1,1,1,1},backdrop={bgFile='native'}},N) end
function N:GetBackdrop() return self.backdrop end
function N:SetBackdrop(v) self.backdrop=v end
function N:GetBackdropColor() return unpack(self.color) end
function N:SetBackdropColor(...) self.color={...} end
function N:GetBackdropBorderColor() return unpack(self.border) end
function N:SetBackdropBorderColor(...) self.border={...} end
function N:GetFrameLevel() return 2 end
function N:SetFrameLevel() end
function N:SetAllPoints(v) self.anchor=v end
function N:EnableMouse(v) assert(v==false) end
function N:CreateTexture(_, layer)
  local texture=node(); texture.owner=self; texture.layer=layer; return texture
end
function N:SetTexture(v) self.texture=v end
function N:GetDrawLayer() return self.layer or 'ARTWORK' end
function N:SetDrawLayer(v) self.layer=v end
function N:GetTexture() return self.texture end
function N:SetTexCoord(...) self.uv={...} end
function N:GetTexCoord() return unpack(self.uv or {0,1,0,1}) end
function N:SetPoint(...) self.points=self.points or {}; table.insert(self.points,{...}) end
function N:GetNumPoints() return #(self.points or {}) end
function N:GetPoint(i) return unpack(self.points[i]) end
function N:ClearAllPoints() self.points={}; self.anchor=nil end
function N:SetVertexColor(...) self.tint={...} end
function N:GetVertexColor() return unpack(self.tint or {1,1,1,1}) end
function N:GetShadowColor() return unpack(self.shadow or {0,0,0,0.25}) end
function N:SetShadowColor(...) self.shadow={...} end
function N:SetTextColor(...) self.textColor={...} end
function N:GetWidth() return self.width or 35 end
function N:SetWidth(v) self.width=v end
function N:GetHeight() return self.height or 35 end
function N:SetHeight(v) self.height=v end
function N:GetStringWidth() return 21 end
function N:Show() self.shown=true end
function N:Hide() self.shown=false end
function N:RegisterEvent() end
function N:SetScript() end
CreateFrame=node
AzerothExpeditionUI={media={root='test/'},db={bagshui={enabled=true}},RegisterModule=function(self,_,v) self.module=v end}
pfUI={GetExpeditionComponentOwner=function() return 'bagshui' end}
dofile('addon/AzerothExpeditionUI/Modules/Bagshui.lua')
local skin=AzerothExpeditionUI.module
skin:Initialize() -- missing provider is safe
local invProto={UpdateWindow=function(self)
  self.calls=(self.calls or 0)+1
  if self.settings then self.layoutMargin=self.settings.itemMargin end
  if self.failLayout then error('provider layout failure') end
  return 42
end}
local uiProto={SetGroupColors=function(self,g) g:SetBackdropColor(1,1,0,1); g:SetBackdropBorderColor(1,1,0,1) end}
local inv=setmetatable({uiFrame=node(),online=true},{__index=invProto})
local group=node()
local label, text = node(), node()
label.bagshuiData={text=text}
group.bagshuiData={labelFrame=label,text=text}
local toolbar = node()
local function slot()
  local button=node()
  local parts={normalTexture=node(),highlightTexture=node(),pushedTexture=node(),
    iconTexture=node(),border=node(),innerGlow=node(),count=node(),cooldown=node()}
  for _, texture in pairs(parts) do
    texture:SetTexture('provider'); texture:SetPoint('CENTER',button,'CENTER',0,0)
  end
  parts.normalTexture:SetDrawLayer('OVERLAY')
  button.bagshuiData={buttonComponents=parts}
  return button
end
local item, bag = slot(), slot()
item.bagshuiData.item={quality=4}
item.bagshuiData.qualityColor={r=0.64,g=0.21,b=0.93}
item.bagshuiData.buttonComponents.innerGlow:SetVertexColor(0.64,0.21,0.93,0.4)
item.bagshuiData.buttonComponents.border:SetBackdropBorderColor(0.64,0.21,0.93,1)
inv.ui=setmetatable({inventory=inv,frames={groups={group},searchBox=node()},
  buttons={toolbar={search=toolbar},itemSlots={item},bagSlots={bag}}},{__index=uiProto})
Bagshui={prototypes={Inventory=invProto,InventoryUi=uiProto},components={Bags=inv}}
skin:Apply()
assert(inv.uiFrame.backdrop==nil and inv.uiFrame.aeuiBagshuiArt.shown)
assert(not label.aeuiBagshuiTag)
assert(text:GetDrawLayer()=='ARTWORK')
assert(toolbar.aeuiBagshuiArt.shown and text.shadow==nil)
assert(not inv.uiFrame.aeuiBagshuiArt.wash)
assert(inv.uiFrame.aeuiBagshuiArt.color[1]==0.48)
local qualityBorder=item.bagshuiData.buttonComponents.border
local dye=qualityBorder.aeuiQualityRim
assert(dye and qualityBorder.border[4]==0 and dye.textures[1].shown)
assert(dye.textures[1].tint[3]<0.93)
local glow=item.bagshuiData.buttonComponents.innerGlow
assert(glow.tint[4]==0) -- existing glow disappears on activation
glow:SetVertexColor(0.64,0.21,0.93,0.15)
assert(glow.tint[4]==0) -- later provider updates cannot restore duplicate quality
glow:SetVertexColor(1,1,0,0.5)
assert(glow.tint[4]==0.5) -- selection feedback passes through
glow:SetVertexColor(0.64,0.21,0.93,0.4)
qualityBorder:SetBackdropBorderColor(0.64,0.21,0.93,0.15)
assert(dye.textures[1].tint[4]==0.15) -- search dimming is exact
qualityBorder:SetBackdropBorderColor(1,1,0,0.8)
assert(not dye.textures[1].shown and qualityBorder.border[4]==0.8) -- container feedback
qualityBorder:SetBackdropBorderColor(0.64,0.21,0.93,0.7)
assert(toolbar.aeuiBagshuiArt.bed.owner==toolbar)
assert(toolbar.aeuiBagshuiArt.slices[1].owner==toolbar)
for _, button in ipairs({item,bag}) do
  local p=button.bagshuiData.buttonComponents
  assert(p.normalTexture.texture=='test/Character\\CharacterSlotBaseAtlasV3')
  assert(p.normalTexture.anchor==button and p.highlightTexture.anchor==button)
  assert(p.normalTexture:GetDrawLayer()=='ARTWORK' and p.count:GetDrawLayer()=='OVERLAY')
  assert(p.iconTexture.texture=='provider' and p.cooldown.texture=='provider')
  assert(p.border.backdrop.bgFile=='native')
end
-- Search/lock colors applied by the provider must survive another layout update.
item.bagshuiData.buttonComponents.normalTexture:SetVertexColor(1,1,1,0.15)
assert(inv:UpdateWindow()==42 and inv.calls==1)
assert(item.bagshuiData.buttonComponents.normalTexture.tint[4]==0.15)
local pooled=slot(); table.insert(inv.ui.buttons.itemSlots,pooled); inv:UpdateWindow()
assert(pooled.bagshuiData.buttonComponents.normalTexture.anchor==pooled)
inv.editMode=true; inv.ui:SetGroupColors(group)
assert(group.color[1]==1 and group.color[2]==1) -- provider edit feedback
assert(not label.aeuiBagshuiTag and text.shadow==nil)
inv.editMode=false; inv.ui:SetGroupColors(group)
assert(group.color[1]==0.17)
local target=node(); inv.ui:SetGroupColors(target)
assert(target.color[1]==1) -- move target stays provider owned
inv.online=false; inv:UpdateWindow()
assert(inv.uiFrame.aeuiBagshuiArt.slices[1].tint[2]==0.35)
local other=setmetatable({uiFrame=node()},{__index=invProto})
other:UpdateWindow(); assert(not other.uiFrame.aeuiBagshuiArt)
AzerothExpeditionUI.db.bagshui.enabled=false; skin:Apply()
assert(inv.uiFrame.backdrop.bgFile=='native' and not inv.uiFrame.aeuiBagshuiArt.shown)
assert(group.color[1]==1)
assert(not dye.textures[1].shown and qualityBorder.border[4]==0.7)
assert(glow.tint[4]==0.4) -- disable restores the latest provider glow
assert(not toolbar.aeuiBagshuiArt.shown and not label.aeuiBagshuiTag)
assert(text:GetDrawLayer()=='ARTWORK')
assert(not toolbar.aeuiBagshuiArt.bed.shown and not toolbar.aeuiBagshuiArt.slices[1].shown)
assert(text.shadow==nil)
for _, button in ipairs({item,bag,pooled}) do
  local texture=button.bagshuiData.buttonComponents.normalTexture
  assert(texture.texture=='provider' and texture.points[1][1]=='CENTER')
  assert(texture.anchor==nil and texture.uv[2]==1)
  assert(texture:GetDrawLayer()=='OVERLAY')
  assert(button.bagshuiData.buttonComponents.count:GetDrawLayer()=='ARTWORK')
end
AzerothExpeditionUI.db.bagshui.enabled=true; skin:Apply()
assert(inv.uiFrame.aeuiBagshuiArt.shown)
assert(toolbar.aeuiBagshuiArt.bed.shown and toolbar.aeuiBagshuiArt.slices[1].shown)
assert(glow.tint[4]==0) -- re-enable removes it again
inv.settings=setmetatable({}, {__index={itemMargin=2},
  __newindex=function() error('must not write provider settings') end})
skin:Apply()
assert(inv.layoutMargin==0 and inv.settings.itemMargin==2 and rawget(inv.settings,'itemMargin')==nil)
inv.failLayout=true
assert(not pcall(inv.UpdateWindow,inv))
assert(inv.settings.itemMargin==2 and rawget(inv.settings,'itemMargin')==nil)
inv.failLayout=false
AzerothExpeditionUI.db.bagshui.enabled=false; skin:Apply()
assert(inv.layoutMargin==2)
print('Bagshui checks passed: scope, states, restore, compact layout without saved writes')
