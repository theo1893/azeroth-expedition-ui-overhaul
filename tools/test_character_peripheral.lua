-- Focused adapter checks; the Turtle client remains the visual authority.
unpack = unpack or table.unpack
local Node = {}; Node.__index = Node
local function node(name, parent, kind)
  local frame = setmetatable({name=name, parent=parent, kind=kind or "Frame", shown=true,
    width=100, height=20, points={}, scripts={}, regions={}, alpha=1, enabled=1,
    value={bgFile="provider"}, color={.1,.2,.3,.8}, border={.4,.5,.6,1},
    uv={0,1,0,1}, tint={1,1,1,1}, texture="provider-texture"}, Node)
  if name then _G[name] = frame end
  return frame
end
function Node:GetName() return self.name end
function Node:GetParent() return self.parent end
function Node:GetObjectType() return self.kind end
function Node:GetFrameLevel() return 4 end
function Node:SetFrameLevel() end
function Node:EnableMouse() end
function Node:GetWidth() return self.width end
function Node:GetHeight() return self.height end
function Node:SetWidth(value) self.width=value end
function Node:SetHeight(value) self.height=value end
function Node:SetAllPoints(value) self.anchor=value end
function Node:SetPoint(...) table.insert(self.points,{...}) end
function Node:ClearAllPoints() self.points={} end
function Node:GetNumPoints() return #self.points end
function Node:GetPoint(i) return unpack(self.points[i]) end
function Node:GetAlpha() return self.alpha end
function Node:SetAlpha(value) self.alpha=value end
function Node:Show() self.shown=true end
function Node:Hide() self.shown=false end
function Node:IsShown() return self.shown end
function Node:IsVisible() return self.shown end
function Node:GetBackdrop() return self.value end
function Node:SetBackdrop(value) self.value=value end
function Node:GetBackdropColor() return unpack(self.color) end
function Node:SetBackdropColor(...) self.color={...} end
function Node:GetBackdropBorderColor() return unpack(self.border) end
function Node:SetBackdropBorderColor(...) self.border={...} end
function Node:SetTexture(value) self.texture=value end
function Node:GetTexture() return self.texture end
function Node:SetTexCoord(...) self.uv={...} end
function Node:GetTexCoord() return unpack(self.uv) end
function Node:SetVertexColor(...) self.tint={...} end
function Node:GetVertexColor() return unpack(self.tint) end
function Node:GetBlendMode() return self.blend or "ADD" end
function Node:SetBlendMode(value) self.blend=value end
function Node:GetDrawLayer() return self.layer or "ARTWORK" end
function Node:SetDrawLayer(value) self.layer=value end
function Node:GetRegions() return unpack(self.regions) end
function Node:CreateTexture(name, layer)
  local texture=node(name,self,"Texture"); texture.layer=layer
  table.insert(self.regions,texture); return texture
end
function Node:GetScript(key) return self.scripts[key] end
function Node:SetScript(key, value)
  assert(key~="OnEnable" and key~="OnDisable", "not a Vanilla script")
  assert(key~="OnUpdate", "peripheral adapter must not poll geometry")
  self.scripts[key]=value
end
function Node:RegisterEvent() end
function Node:IsEnabled() return self.enabled end
function Node:Enable() self.enabled=1 end
function Node:Disable() self.enabled=0 end
function Node:GetButtonState() return self.buttonState or "NORMAL" end
function Node:GetHighlightTexture() return self.highlight end
function Node:GetPushedTexture() return self.pushed end
function Node:SetHighlightTexture(value)
  self.highlight=self.highlight or self:CreateTexture()
  self.highlight:SetTexture(value)
end
function Node:GetThumbTexture() return self.thumb end
function Node:GetStatusBarTexture() return self.fill end
function Node:SetStatusBarTexture(value) self.fill:SetTexture(value) end
function Node:GetStatusBarColor() return .7,.2,.1,1 end
function Node:SetStatusBarColor(...) self.statusColor={...} end

CreateFrame=function(kind,name,parent) return node(name,parent,kind) end
MouseIsOver=function() return false end
local function host(name)
  local frame=node(name); frame.width=384; frame.height=512
  frame.backdrop=node(nil,frame); frame.backdrop_shadow=node(nil,frame)
  return frame
end
local function button(name,parent)
  local frame=node(name,parent,"Button")
  frame.highlight=frame:CreateTexture(); frame.pushed=frame:CreateTexture()
  frame.backdrop=node(nil,frame)
  return frame
end
local hooks, disabledSkins, disabledRoutes = {}, {}, {}
hooksecurefunc=function(name, callback) hooks[name]=callback end
PanelTemplates_SetTab=function() end
InspectPaperDollItemSlotButton_Update=function() end
InspectFrame_Show=function() end
pfUI={IsSkinEnabled=function(_,skin) return not disabledSkins[skin] end,
  GetExpeditionComponentOwner=function(_,route) if not disabledRoutes[route] then return "character" end end}
AzerothExpeditionUI={media={root="test/"}, db={character={enabled=true}},
  RegisterModule=function(self,_,module) self.module=module end}
dofile("addon/AzerothExpeditionUI/Modules/Character.lua")
local character=AzerothExpeditionUI.module
character:Initialize()
character:RefreshPeripheralWindows() -- Inspect loads on demand.
assert(string.find(character.peripheralStatus,"inspect=not%-loaded"))

host("InspectFrame"); node("InspectPaperDollFrame",InspectFrame)
node("StatCompareTargetFrame"); node("S_ItemTip_InspectFrame")
local slot=button("InspectHeadSlot",InspectPaperDollFrame)
slot.width=37; slot.height=37; slot:SetPoint("LEFT",InspectPaperDollFrame,"LEFT",8,0)
local icon=node("InspectHeadSlotIconTexture",slot.backdrop,"Texture")
local model=node("InspectModelFrame",InspectPaperDollFrame,"PlayerModel")
local tab=button("InspectFrameTab1",InspectFrame); InspectFrame.selectedTab=1
button("InspectFrameCloseButton",InspectFrame)
node("InspectHonorFrame",InspectFrame)
host("DressUpFrame"); local reset=button("DressUpFrameResetButton",DressUpFrame)
host("TabardFrame"); local accept=button("TabardFrameAcceptButton",TabardFrame)
host("ItemTextFrame"); local scroll=node("ItemTextScrollFrame",ItemTextFrame)
scroll.width=292; scroll.height=360
local stationery=scroll:CreateTexture(); stationery:SetTexture("Interface\\Stationery\\StationeryTest1")
local html=node("ItemTextPageText",scroll,"SimpleHTML"); html.text="live book text"
local nextPage=button("ItemTextNextPageButton",ItemTextFrame)
local foreign=node("ForeignHost")
node("TWTalentFrame",foreign) -- Never acquire a talent provider outside Inspect.
local talent=button("TWTalentFrameTalent1",TWTalentFrame)
local calls=0
for _,frame in ipairs({slot,reset,accept,nextPage}) do
  frame:SetScript("OnClick",function() calls=calls+1 end)
end
character:InstallPeripheralHooks()
character:RefreshPeripheralWindows()
assert(string.find(character.peripheralStatus,"inspect=active"),character.peripheralStatus)
for _,frame in ipairs({InspectFrame,DressUpFrame,TabardFrame,ItemTextFrame}) do
  assert(frame.aeuiCharacterPeripheralContract=="2.2",character.peripheralStatus)
  assert(frame.backdrop:GetBackdrop()==nil and frame.backdrop:IsShown())
  assert(frame.backdrop_shadow:GetAlpha()==0)
  assert(frame.width==384 and frame.height==512)
end
assert(icon.parent==slot.backdrop and slot.backdrop:GetAlpha()==1 and icon:IsShown())
assert(slot.points[1][4]==8 and slot.width==37 and model.parent==InspectPaperDollFrame)
assert(slot.pushed:GetAlpha()==0 and string.find(slot.highlight:GetTexture(),"CharacterSlotInteractionAtlasV3"))
assert(stationery:GetAlpha()==0 and html.text=="live book text")
assert(talent:GetBackdrop().bgFile=="provider")
assert(StatCompareTargetFrame:GetBackdrop()==nil and S_ItemTip_InspectFrame:GetBackdrop()==nil)
InspectPaperDollFrame:Hide(); InspectPaperDollFrame:GetScript("OnHide")()
assert(StatCompareTargetFrame:GetBackdrop().bgFile=="provider")
InspectPaperDollFrame:Show(); InspectPaperDollFrame:GetScript("OnShow")()
assert(StatCompareTargetFrame:GetBackdrop()==nil)
for _,frame in ipairs({slot,reset,accept,nextPage}) do frame:GetScript("OnClick")() end
assert(calls==4)

-- Turtle's first InspectFrame_Show can run its skin after the host OnShow.
for _,texture in ipairs(tab.regions) do texture:SetTexture("") end
for _,texture in ipairs(InspectHonorFrame.regions) do texture:SetTexture("") end
local lateShows=0
tab:SetScript("OnShow",function() lateShows=lateShows+1 end)
hooks.InspectFrame_Show()
local repaired=false
for _,texture in ipairs(tab.regions) do
  if texture:GetTexture()=="test/Character\\CharacterTabsV3" then repaired=true end
end
assert(repaired,"late provider skin must not erase the accepted tab art")
tab:GetScript("OnShow")()
assert(lateShows==1)

-- A cached inventory update must not resurrect black slot borders or hide icons.
slot.backdrop:SetBackdrop({bgFile="refreshed-provider"})
slot.backdrop:SetBackdropBorderColor(.9,.1,.7,1)
hooks.InspectPaperDollItemSlotButton_Update(slot)
assert(slot.backdrop:GetBackdrop()==nil and icon:IsShown())
nextPage:Disable()
local dimmed=false
for _,texture in ipairs(nextPage.regions) do
  if texture:GetTexture()=="test/Character\\CharacterTabsV3" and texture:GetAlpha()==.45 then dimmed=true end
end
assert(dimmed,"page button must reflect live Disable() without OnUpdate")

TWTalentFrame.parent=InspectFrame
character:RefreshPeripheralWindows()
assert(talent:GetBackdrop()==nil)
disabledRoutes["character.inspect-windows"]=true
character:RefreshPeripheralWindows()
assert(InspectFrame.backdrop:GetBackdrop().bgFile=="provider")
assert(slot.backdrop:GetBackdrop().bgFile=="refreshed-provider")
assert(slot.backdrop.border[1]==.9 and slot.pushed:GetAlpha()==1)
assert(slot.highlight:GetTexture()=="provider-texture" and slot.highlight:GetBlendMode()=="ADD")
assert(talent:GetBackdrop().bgFile=="provider" and DressUpFrame.backdrop:GetBackdrop()==nil)
disabledRoutes["character.inspect-windows"]=nil
disabledSkins["Guild Tabard"]=true
DressUpFrame.width=500
character:RefreshPeripheralWindows()
assert(DressUpFrame.backdrop:GetBackdrop().bgFile=="provider")
assert(TabardFrame.backdrop:GetBackdrop().bgFile=="provider")
assert(InspectFrame.aeuiCharacterPeripheralContract=="2.2")

AzerothExpeditionUI.db.character.enabled=false
character:Restore()
assert(stationery:GetAlpha()==1 and html.text=="live book text")
assert(ItemTextFrame.backdrop:GetBackdrop().bgFile=="provider")
assert(InspectFrame.backdrop_shadow:GetAlpha()==1 and icon:IsShown())
for _,frame in ipairs({slot,reset,accept,nextPage}) do frame:GetScript("OnClick")() end
assert(calls==8 and ItemTextFrame.backdrop:GetBackdrop().bgFile=="provider")
character:Restore() -- Idempotent fallback preserves the provider's latest state.
AzerothExpeditionUI.db.character.enabled=true
DressUpFrame.width=384; disabledSkins["Guild Tabard"]=nil
character:RefreshPeripheralWindows()
assert(InspectFrame.aeuiCharacterPeripheralContract=="2.2")
assert(DressUpFrame.backdrop:GetBackdrop()==nil and stationery:GetAlpha()==0)
character:RefreshPeripheralWindows()
reset:GetScript("OnClick")()
assert(calls==9,"refresh must not multiply provider click handlers")
print("PASS character peripheral: lazy hosts, live icons/clicks, read-only slots, scoped talents, updates and independent fallback")
