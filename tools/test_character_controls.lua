-- lua tools/test_character_controls.lua
unpack = unpack or table.unpack
local Node = {}; Node.__index = Node
local function node(name)
  return setmetatable({name=name, shown=true, width=120, height=20, points={}, scripts={},
    color={0.1,0.2,0.3,0.9}, border={0.4,0.5,0.6,1}, uv={0,1,0,1},
    texture="provider-texture", justify="CENTER", backdropValue={bgFile="provider"}}, Node)
end
function Node:GetName() return self.name end
function Node:GetDrawLayer() return self.layer or "ARTWORK" end
function Node:GetFrameLevel() return 4 end
function Node:SetFrameLevel(value) self.level=value end
function Node:EnableMouse(value) self.mouse=value end
function Node:SetAllPoints(value) self.anchor=value end
function Node:CreateTexture() return node() end
function Node:SetBackdrop(value) self.backdropValue=value end
function Node:GetBackdrop() return self.backdropValue end
function Node:GetBackdropColor() return unpack(self.color) end
function Node:SetBackdropColor(...) self.color={...} end
function Node:GetBackdropBorderColor() return unpack(self.border) end
function Node:SetBackdropBorderColor(...) self.border={...} end
function Node:SetTexture(value) self.texture=value end
function Node:GetTexture() return self.texture end
function Node:GetHighlightTexture() return self.highlight end
function Node:GetBlendMode() return self.blend or "ADD" end
function Node:SetBlendMode(value) self.blend=value end
function Node:SetTexCoord(...) self.uv={...} end
function Node:GetTexCoord() return unpack(self.uv) end
function Node:SetVertexColor(...) self.tint={...} end
function Node:GetVertexColor() return unpack(self.tint or {1,1,1,1}) end
function Node:GetAlpha() return self.alpha or 1 end
function Node:SetAlpha(value) self.alpha=value end
function Node:GetWidth() return self.width end
function Node:GetHeight() return self.height end
function Node:GetTop() return self.top end
function Node:GetLeft() return self.left end
function Node:GetRegions() return unpack(self.regions or {}) end
function Node:GetChildren() return unpack(self.children or {}) end
function Node:GetObjectType() return "Frame" end
function Node:GetFontString() return self.label end
function Node:SetWidth(value) self.width=value end
function Node:SetHeight(value) self.height=value end
function Node:SetPoint(...) table.insert(self.points,{...}) end
function Node:ClearAllPoints() self.points={} end
function Node:GetNumPoints() return #self.points end
function Node:GetPoint(i) return unpack(self.points[i]) end
function Node:GetJustifyH() return self.justify end
function Node:SetJustifyH(value) self.justify=value end
function Node:Show() self.shown=true end
function Node:Hide() self.shown=false end
function Node:IsShown() return self.shown end
function Node:IsVisible() return self.shown end
function Node:GetScript(key) return self.scripts[key] end
function Node:SetScript(key, value) self.scripts[key]=value end
function Node:RegisterEvent(value) self.event=value end
function Node:GetStatusBarTexture() return self.fill end
function Node:SetStatusBarTexture(value) self.fill:SetTexture(value) end
function Node:GetStatusBarColor() return unpack(self.statusColor) end
function Node:SetStatusBarColor(...) self.statusColor={...} end
CreateFrame=function() return node() end
local hooks={}
hooksecurefunc=function(name, callback) hooks[name]=callback end
ToggleDropDownMenu=function() end
SCShowFrame=function() end
ReputationFrame_Update=function() end
FauxScrollFrame_GetOffset=function(frame) return frame.offset or 0 end
local owned=true
pfUI={GetExpeditionComponentOwner=function() if owned then return "character" end end}
AzerothExpeditionUI={media={root="test/"}, db={character={enabled=true}},
  RegisterModule=function(self, _, module) self.module=module end}
dofile("addon/AzerothExpeditionUI/Modules/Character.lua")
local character=AzerothExpeditionUI.module
character:Initialize()
local slice
for i=1,60 do
  local name, value=debug.getupvalue(character.ApplyFrame,i)
  if name=="ConfigureVerticalTextureSlices" then slice=value; break end
end
assert(slice)
local paper={node(),node(),node()}
slice(paper,{path="paper",width=301,height=382,verticalCap=8,textureHeight=1024,
  texCoord={0,602/1024,0,750/1024},vertexColor={0.62,0.62,0.62}},
  {relativeTo=node(),relativePoint="TOPLEFT",x=25,y=-66})
assert(paper[1].height==8 and paper[2].height==366 and paper[3].height==8)
assert(paper[3].points[1][5]==-440 and paper[3].tint[1]==0.62)
CharacterFrame=node(); PaperDollFrame=node()
PlayerStatFrameLeftDropDown=node(); PlayerStatFrameLeftDropDown.backdrop=node()
PlayerStatFrameLeftDropDownButton=node(); PlayerStatFrameLeftDropDownButton.backdrop=node()
PlayerStatFrameLeftDropDownText=node()
PlayerStatFrameLeftDropDownText:SetPoint("CENTER", PlayerStatFrameLeftDropDown)
DropDownList1Backdrop=node(); DropDownList1Backdrop.backdrop=node()
ReputationBar1=node(); ReputationBar1.backdrop=node(); ReputationBar1.fill=node()
ReputationBar1.statusColor={0.2,0.7,0.3,1}
StatCompareSelfFrame=node()
ReputationFrame=node(); ReputationFrame.top=500; ReputationFrame.left=0
ReputationListScrollFrame=node(); ReputationListScrollFrame.offset=0
SkillListScrollFrame=node(); SkillListScrollFrame.offset=0
ReputationBar1:SetPoint("TOPLEFT",ReputationFrame,"TOPLEFT",147,-90)
local heading=node(); heading.top=444; heading.left=70
heading:SetPoint("TOPLEFT",ReputationFrame,"TOPLEFT",70,-56)
ReputationFrame.regions={heading}
SkillFrame=node(); SkillFrame.left=0
SkillFrameCollapseAllButton=node(); SkillFrameCollapseAllButton.width=30
SkillFrameCollapseAllButton.icon=node(); SkillFrameCollapseAllButton.label=node()
local skillScrollCalls=0
SkillListScrollFrame:SetScript("OnVerticalScroll",function()
  skillScrollCalls=skillScrollCalls+1
  SkillListScrollFrame.offset=arg1 / 20
  SkillFrameCollapseAllButton:Show() -- Provider refresh can show it again.
end)
HonorFrame=node(); HonorFrame.top=500; HonorFrame.left=0
HonorFrameProgressBar=node(); HonorFrameProgressBar.backdrop=node()
HonorFrameProgressBar.backdrop.alpha=0.75
ArenaTeam1=node(); ArenaTeam1.backdrop=node(); ArenaTeam1.backdrop_border=node()
ArenaTeam1.highlight=node()
local arenaOutline=node("ArenaTeam1Highlight")
local arenaOverlay=node("ArenaTeam1HighlightFrame")
ArenaTeam1.regions={arenaOutline}; ArenaTeam1.children={arenaOverlay}
local arenaEnterCalls=0
ArenaTeam1:SetScript("OnEnter",function()
  arenaEnterCalls=arenaEnterCalls+1
  arenaOutline:SetAlpha(1); arenaOverlay:SetAlpha(1)
  ArenaTeam1:SetBackdrop({bgFile="provider"})
end)
ArenaFrameTeam2=node(); ArenaFrameTeam2.backdrop=node()
local teamClick=function() end
ArenaTeam1:SetScript("OnMouseDown",teamClick)
local section=node(); local value=node(); value.top=360; value.left=315; value.justify="LEFT"
value:SetPoint("TOPRIGHT",section,"TOPRIGHT",0,0)
section.regions={value}; HonorFrame.children={section}
local click=function() end
PlayerStatFrameLeftDropDownButton:SetScript("OnClick", click)
character:InstallControlHooks()
character:RefreshControls()
assert(PlayerStatFrameLeftDropDown.backdrop:GetBackdrop()==nil)
assert(PlayerStatFrameLeftDropDownButton:GetScript("OnClick")==click)
assert(PlayerStatFrameLeftDropDownText.justify=="LEFT")
assert(ReputationBar1.statusColor[2]==0.7)
assert(StatCompareSelfFrame.aeuiCharacterControlArt:IsShown())
assert(HonorFrameProgressBar.backdrop:GetAlpha()==0 and HonorFrameProgressBar:IsShown())
assert(ArenaTeam1.backdrop:GetAlpha()==0 and ArenaTeam1.backdrop_border:GetAlpha()==0)
assert(ArenaTeam1.highlight:GetAlpha()==0 and arenaOutline:GetAlpha()==0)
ArenaTeam1:GetScript("OnEnter")()
assert(arenaEnterCalls==1 and arenaOutline:GetAlpha()==0 and arenaOverlay:GetAlpha()==0)
assert(ArenaTeam1:GetBackdrop()==nil)
assert(ArenaFrameTeam2.backdrop:GetAlpha()==0 and ArenaTeam1:GetScript("OnMouseDown")==teamClick)
assert(heading.points[1][5]==-76)
assert(ReputationBar1.points[1][5]==-102)
assert(SkillFrameCollapseAllButton.label.width>=48)
assert(SkillFrameCollapseAllButton.points[1][4]==316)
assert(value.points[1][4]==312 and value.points[1][5]==-140 and value.justify=="RIGHT")
ReputationListScrollFrame.offset=4; SkillListScrollFrame.offset=3
hooks.ReputationFrame_Update()
assert(not heading:IsShown() and not SkillFrameCollapseAllButton:IsShown())
assert(ReputationBar1.points[1][5]==-90)
ReputationListScrollFrame.offset=0; SkillListScrollFrame.offset=0
hooks.ReputationFrame_Update()
assert(heading:IsShown() and SkillFrameCollapseAllButton:IsShown())
assert(ReputationBar1.points[1][5]==-102) -- No accumulated inset on refresh.
arg1=60; SkillListScrollFrame:GetScript("OnVerticalScroll")()
assert(skillScrollCalls==1 and not SkillFrameCollapseAllButton:IsShown())
arg1=0; SkillListScrollFrame:GetScript("OnVerticalScroll")()
assert(skillScrollCalls==2 and SkillFrameCollapseAllButton:IsShown())
arg1=nil
hooks.ToggleDropDownMenu(1,nil,PlayerStatFrameLeftDropDown)
assert(DropDownList1Backdrop.backdrop:GetBackdrop()==nil)
hooks.ToggleDropDownMenu(1,nil,node("UnrelatedDropdown"))
assert(DropDownList1Backdrop.backdrop:GetBackdrop().bgFile=="provider")
S_ItemTip_InspectFrame=node() -- Created lazily by the equipment provider.
character:RefreshControls()
assert(S_ItemTip_InspectFrame.aeuiCharacterControlArt:IsShown())
PaperDollFrame:Hide(); character:RefreshCompanionArt()
assert(StatCompareSelfFrame:GetBackdrop().bgFile=="provider")
assert(S_ItemTip_InspectFrame:GetBackdrop().bgFile=="provider")
-- Restore the targeted controls without constructing the unrelated PaperDoll suite.
CharacterFrame=nil
AzerothExpeditionUI.db.character.enabled=false
character:Restore()
assert(PlayerStatFrameLeftDropDown.backdrop:GetBackdrop().bgFile=="provider")
assert(PlayerStatFrameLeftDropDownText.justify=="CENTER")
assert(PlayerStatFrameLeftDropDownText.width==120)
assert(PlayerStatFrameLeftDropDownText.points[1][1]=="CENTER")
assert(ReputationBar1.fill.texture=="provider-texture")
assert(HonorFrameProgressBar.backdrop:GetAlpha()==0.75)
assert(ArenaTeam1.backdrop:GetAlpha()==1 and ArenaTeam1.backdrop_border:GetAlpha()==1)
assert(ArenaTeam1.highlight.texture=="provider-texture" and ArenaTeam1.highlight:GetBlendMode()=="ADD")
assert(ArenaTeam1.highlight:GetAlpha()==1 and arenaOutline:GetAlpha()==1 and arenaOverlay:GetAlpha()==1)
assert(ArenaTeam1:GetBackdrop().bgFile=="provider")
assert(ArenaFrameTeam2.backdrop:GetAlpha()==1)
assert(heading.points[1][5]==-56)
assert(ReputationBar1.points[1][5]==-90)
assert(value.justify=="LEFT" and value.points[1][2]==section)
assert(SkillFrameCollapseAllButton.width==30)
AzerothExpeditionUI.db.character.enabled=true; owned=false
character:RefreshControls()
assert(PlayerStatFrameLeftDropDown.backdrop:GetBackdrop().bgFile=="provider")
print("PASS character controls: provider clicks/colors, scoped menu, late companion, page hide and restore")
