-- lua tools/test_combination_layout.lua
unpack = unpack or table.unpack
table.getn = table.getn or function(t) return #t end
math.mod = math.mod or math.fmod
string.gfind = string.gfind or string.gmatch
local geometryWrites = 0
local Node = {}; Node.__index = Node
local function node(parent) return setmetatable({point={"CENTER"}, scale=1, bottom=100, parent=parent},Node) end
function Node:GetNumPoints() return 1 end
function Node:GetPoint() return unpack(self.point) end
function Node:ClearAllPoints() self.point={} end
function Node:SetPoint(...) self.point={...}; geometryWrites=geometryWrites+1 end
function Node:SetAllPoints(target) self.allPoints=target end
function Node:SetScale(v) self.scale=v end
function Node:GetEffectiveScale() return self.scale * (self.parent and self.parent:GetEffectiveScale() or 1) end
function Node:GetWidth() return self.width or 40 end
function Node:GetHeight() return self.height or 40 end
function Node:SetWidth(v) self.width=v; geometryWrites=geometryWrites+1 end
function Node:SetHeight(v) self.height=v; geometryWrites=geometryWrites+1 end
function Node:IsShown() return not self.hidden end
function Node:Show() self.hidden=false end
function Node:Hide() self.hidden=true end
function Node:CreateTexture() return node(self) end
function Node:CreateFontString() return node(self) end
function Node:SetTexture(v) self.texture=v end
function Node:SetTexCoord(...) self.texcoord={...} end
function Node:SetAlpha(v) self.alpha=v end
function Node:SetScript(k,v) self[k]=v end
function Node:GetScript(k) return self[k] end
function Node:GetFrameLevel() return 1 end
for _, name in ipairs({"SetFrameLevel", "SetFrameStrata", "EnableMouse", "SetBlendMode",
  "SetVertexColor", "RegisterForClicks", "SetFont", "SetTextColor", "SetShadowColor",
  "SetShadowOffset", "SetJustifyH", "SetJustifyV", "SetText", "SetMinMaxValues",
  "SetValue", "SetStatusBarTexture", "SetStatusBarColor"}) do Node[name]=function() end end
function Node:SetFont(_, size) self.fontSize=size end
function Node:SetText(value) self.text=value or "" end
function Node:GetStringWidth()
  local width, maximum = 0, 0
  for character in string.gfind(self.text or "", "[^\128-\191][\128-\191]*") do
    if character == "\n" then
      maximum=math.max(maximum,width); width=0
    else
      local advance=string.len(character)>1 and 1 or (character=="W" and .9 or .5)
      width=width+advance*(self.fontSize or 10)
    end
  end
  return math.max(maximum,width)
end
function Node:GetBottom() return self.bottom end
function Node:GetLeft() return self.left end
function Node:GetRight() return self.right end
function Node:GetTop() return self.top end
function Node:GetCenter() return self.centerX,self.centerY end
UIParent=node()
CreateFrame=function(_,_,parent) return node(parent) end
UnitClass=function() return "Mage", "MAGE" end
UnitName=function() return "ShelfTest" end
GetRealmName=function() return "Realm" end
local main, top, stance, trinkets = node(UIParent),node(UIParent),node(UIParent),node(UIParent)
local globals={pfActionBarStances=stance, TrinketMenu_MainFrame=trinkets}
getglobal=function(name) return globals[name] end
pfUI={bars={[1]=main,[6]=top,[11]=stance}}
pfUI_config={}
AzerothExpeditionUI={media={root=""}, modules={}, db={actionbars={enabled=true,fieldKitBound=true}},
  RegisterModule=function(self,name,module) self.modules[name]=module end}
dofile("addon/AzerothExpeditionUI/Modules/ActionBars.lua")
local actions=AzerothExpeditionUI.modules.ActionBars
local function close(a,b) assert(math.abs(a-b)<0.00001, tostring(a).." ~= "..tostring(b)) end
assert(actions:ApplyStanceDockPosition(true))
assert(stance.point[1]=="TOPRIGHT" and stance.point[2]==main and stance.point[5]==-8)
assert(actions:ApplyTrinketDockPosition(true))
assert(trinkets.point[1]=="TOPLEFT" and trinkets.point[2]==top and trinkets.point[5]==8)
actions:ApplyStanceDockPosition(false)
actions:ApplyTrinketDockPosition(false)
assert(stance.point[1]=="CENTER" and trinkets.point[1]=="CENTER")
local shell=node(main); shell.width=417; main.backdrop=shell
local merged=node(UIParent); merged.backdrop=node(merged); merged.backdrop.width=333.6
main:SetWidth(329.6)
main._size={329.6,35}
top._size={329.6,34}
shell:SetPoint("TOPLEFT",main,"TOPLEFT",-2,2)
merged.backdrop:SetPoint("TOPLEFT",merged,"TOPLEFT",-2,2)
merged.backdrop.top=172
top.top=170; top.backdrop=node(top); top.backdrop.top=172; top.backdrop:Hide()
top.backdrop:SetPoint("TOPLEFT",top,"TOPLEFT",-2,2)
main.mergedBackdrop=merged
assert(actions:GetActionBarVisualFrame(main)==merged.backdrop)
local supplyProfile={version=4,slots={[1]=true,[8]=true}}
AzerothExpeditionUI.db.actionbars.supplyProfiles={["ShelfTest - Realm"]=supplyProfile}
main[1]=node(main); main[1]:SetWidth(28)
actions.supplyFrame=node(UIParent)
actions.supplyFrame.buttons={}
for i=1,24 do
  local button=node(actions.supplyFrame)
  button.icon=node(button)
  actions.supplyFrame.buttons[i]=button
end
assert(actions:LayoutSupplyButtons())
assert(actions:ApplySupplyDockPosition())
assert(actions.supplyFrame.point[2]==merged.backdrop and actions.supplyFrame.point[5]==0)
close(actions.supplyFrame:GetHeight()*actions.supplyFrame:GetEffectiveScale(),72)
close(actions.supplyFrame.point[4]*actions.supplyFrame:GetEffectiveScale(),-8)
for _, button in ipairs(actions.supplyFrame.buttons) do
  close(button.icon:GetWidth()*button:GetEffectiveScale(),main[1]:GetWidth()*main[1]:GetEffectiveScale())
  assert(button.icon.point[1]=="CENTER" and button.icon.point[2]==button)
end
-- Loading/moving the deck can expose stale or missing screen bounds.
-- Those bounds must never resize the supply buttons.
for _, bounds in ipairs({{900,0},{0,0},{}}) do
  merged.backdrop.top,merged.backdrop.bottom=bounds[1],bounds[2]
  actions.supplyFrame:SetScale(12)
  actions:ApplySupplyDockPosition()
  close(actions.supplyFrame.scale,.96)
end
merged.backdrop.top,merged.backdrop.bottom=172,100
local topSize=top._size
top._size=nil
actions.supplyFrame:SetScale(12)
actions:ApplySupplyDockPosition()
close(actions.supplyFrame.scale,1)
top._size=topSize
top:Hide()
actions.supplyFrame:SetScale(12)
actions:ApplySupplyDockPosition()
close(actions.supplyFrame.scale,1)
top:Show()
for _, rows in ipairs({1,3,2}) do
  supplyProfile.slots={[1]=true,[rows*4]=true}
  actions:LayoutSupplyButtons(); actions:ApplySupplyDockPosition()
  close(actions.supplyFrame.scale,.96)
  assert(actions.supplyFrame:GetHeight()==42+(rows-1)*33)
  assert(actions.supplyFrame.point[1]=="BOTTOMRIGHT" and actions.supplyFrame.point[5]==0)
end
UIParent.scale=.711111
actions:ApplySupplyDockPosition()
close(actions.supplyFrame:GetHeight()*actions.supplyFrame:GetEffectiveScale(),72*UIParent.scale)
local supplyIcon=actions.supplyFrame.buttons[1].icon
close(supplyIcon:GetWidth()*supplyIcon:GetEffectiveScale(),28*UIParent.scale)
UIParent.scale=1
UIParent.centerX,UIParent.centerY=1000,500
actions.supplyFrame.centerX,actions.supplyFrame.centerY=500,200
AzerothExpeditionUI.db.actionbars.fieldKitBound=false
actions:ApplySupplyDockPosition()
assert(actions.supplyFrame.scale==1 and actions.supplyFrame.point[1]=="CENTER")
close(supplyIcon:GetWidth(),28)
assert(actions.supplyFrame.point[4]==-520 and actions.supplyFrame.point[5]==-308)
AzerothExpeditionUI.db.actionbars.fieldKitBound=true
merged:Hide()
top.backdrop:Show()
assert(actions:GetActionBarVisualFrame(main)==shell)
actions:ApplySupplyDockPosition()
assert(actions.supplyFrame.point[2]==shell)
shell:Hide()
assert(actions:GetActionBarVisualFrame(main)==main)
shell:Show(); merged:Show()
dofile("addon/AzerothExpeditionUI/Modules/TargetMarkers.lua")
local markers=AzerothExpeditionUI.modules.TargetMarkers
assert(markers:ApplyAnchor())
close(markers.frame.scale,0.8)
assert(markers.frame.point[1]=="TOPLEFT" and markers.frame.point[2]==merged.backdrop)
close(markers.panel:GetWidth()*markers.frame:GetEffectiveScale(),merged.backdrop:GetWidth()*merged.backdrop:GetEffectiveScale())
close(markers.frame.point[4]+markers.panel.point[4],0) -- Visible left edges coincide.
close((markers.frame.point[5]+markers.panel.point[5])*markers.frame:GetEffectiveScale(),-8*main:GetEffectiveScale())
close(merged.backdrop:GetBottom()*merged.backdrop:GetEffectiveScale() -
  8*main:GetEffectiveScale() - markers.panel:GetHeight()*markers.frame:GetEffectiveScale(),0)
for _, cell in pairs(markers.cells) do
  close(cell:GetHeight(),markers.frame:GetHeight())
  close(cell.icon:GetWidth(),28)
  assert(cell.selected:GetHeight()<2 and cell.hover.allPoints==cell)
end
local tank=markers.tankButton
close(tank:GetHeight()*tank.scale,markers.panel:GetHeight())
close(tank.base:GetHeight()*tank.scale,markers.panel:GetHeight())
close(tank.point[5]*tank.scale,markers.panel.point[5])
close(markers.panel.point[4]-tank:GetWidth()*tank.scale,markers.tankButtonGap)
-- Vanilla's merged shell is sized by cross-frame anchors, so its width
-- readback may already include UIParent scale. The explicit bar stays 329.6.
for _, uiScale in ipairs({.711111, .64, 1}) do
  UIParent.scale=uiScale
  main.width=329.6*uiScale
  merged.backdrop.width=333.6*uiScale
  markers:ApplyAnchor()
  close(markers.frame.scale,.8)
  close(markers.panel:GetWidth()*markers.frame:GetEffectiveScale(),333.6*uiScale)
  close(markers.cells[8].icon:GetWidth()*markers.frame:GetEffectiveScale(),22.4*uiScale)
end
assert(stance.point[2]==tank and stance.point[3]=="TOPLEFT")
AzerothExpeditionUI.db.actionbars.markersEnabled=false
actions:ApplyStanceDockPosition(true)
assert(stance.point[2]==main)
AzerothExpeditionUI.db.actionbars.markersEnabled=true
local fallback=node(markers.frame)
assert(markers:InstallTankButtonFallback(fallback))
close(fallback:GetHeight()*fallback.scale,markers.panel:GetHeight())
close(fallback.base:GetHeight()*fallback.scale,markers.panel:GetHeight())
merged:Hide()
main:SetWidth(413)
main._size[1]=413
main.scale=1.25
markers:ApplyAnchor()
close(markers.frame.scale,1.25)
main:SetWidth(496); main._size[1]=496; shell.width=500
markers:ApplyAnchor()
close(markers.panel:GetWidth()*markers.frame:GetEffectiveScale(),500*main:GetEffectiveScale())
UIParent.scale=.711111
main.parent=UIParent
markers:ApplyAnchor()
close(markers.panel:GetWidth()*markers.frame:GetEffectiveScale(),500*main:GetEffectiveScale())
close(shell:GetBottom()*shell:GetEffectiveScale()-8*main:GetEffectiveScale()-
  markers.panel:GetHeight()*markers.frame:GetEffectiveScale(),0)
UIParent.scale=1
main:SetWidth(413); main._size[1]=413; shell.width=417
local pet=node(); pet.bottom=90; pet.left=200; pet[1]=node()
globals.pfActionBarPet=pet; pfUI.bars[12]=pet
markers:ApplyAnchor()
assert(markers.frame.point[2]==shell)
close(markers.frame.point[4]+markers.panel.point[4],0)
close(shell:GetBottom()*shell:GetEffectiveScale() +
  (markers.frame.point[5]+markers.panel.point[5])*markers.frame:GetEffectiveScale(),
  pet:GetBottom()*pet:GetEffectiveScale()-8*main:GetEffectiveScale())
AzerothExpeditionUI.db.actionbars.fieldKitBound=false
markers:ApplyAnchor()
assert(markers.frame.scale==1 and markers.anchorStatus=="pet-row")
assert(markers.frame:GetHeight()==markers.cellSize)
close(tank:GetHeight()*tank.scale,markers.panel:GetHeight())
print("PASS combination: visible shell alignment, fitted marker width, equal-height shield, provider fallback and pet clearance")

-- Exercise the real marker updates with variable-width glyphs and small fallback rows.
local oldUnitName=UnitName
local markedName, dead, exists="桂月初一",false,true
UnitExists=function(unit) return exists and (unit=="mark5" or unit=="target") end
UnitName=function(unit) return unit=="mark5" and markedName or oldUnitName(unit) end
UnitHealth=function() return 100 end
UnitHealthMax=function() return 100 end
UnitIsDead=function() return dead end
UnitIsUnit=function(a,b) return a=="target" and b=="mark5" end
SetRaidTarget=function() error("display updates must not change real raid markers") end
local cell=markers.cells[5]
for _, height in ipairs({48,60,71,72,73,74,100}) do
  markers:LayoutGrid(height)
  local iconSize=cell.icon:GetWidth()
  assert(-cell.icon.point[5]+iconSize <= -cell.name.point[5])
  assert(-cell.name.point[5]+cell.name:GetHeight() <= height-cell.healthText.point[5]-cell.healthText:GetHeight())
  assert(cell.healthText.point[5] >= cell.healthBackground.point[5]+cell.healthBackground:GetHeight())
  for _, name in ipairs({"桂月初一","疯狂古姆","桂月小猎猎","黑石塔精英召唤师","WWWWiiii"}) do
    markedName=name
    local writes=geometryWrites
    assert(markers:UpdateCell(cell))
    assert(geometryWrites==writes, "data refresh changed marker geometry")
    assert(cell.name:GetStringWidth()<=42 and cell.healthText:GetStringWidth()<=42)
    assert(string.gsub(cell.name.text,"\n","")==name, "a fitting name was lost")
    assert(cell.healthText.text=="100%" and cell.icon.alpha==1 and not cell.selected.hidden)
    close(cell.icon:GetWidth(),iconSize)
  end
  markedName="黑石塔精英召唤师的超长名字"
  markers:UpdateCell(cell)
  assert(cell.name:GetStringWidth()<=42 and string.sub(cell.name.text,-3)=="…")
  assert(cell.unitName==markedName, "tooltip must retain the complete name")
  dead=true
  local writes=geometryWrites
  assert(not markers:UpdateCell(cell) and cell.name.text=="" and cell.health.hidden)
  assert(geometryWrites==writes and cell.icon.alpha==.56 and cell.selected.hidden)
  close(cell.icon:GetWidth(),iconSize)
  dead=false
  assert(markers:UpdateCell(cell) and cell.name.text~="")
  exists=false
  assert(not markers:UpdateCell(cell) and cell.name.text=="" and cell.healthText.text=="")
  exists=true
end
local targeted
TargetUnit=function(unit) targeted=unit end
markers:HandleCellClick(cell,"LeftButton")
assert(targeted=="mark5")
markers:SetEnabled(false)
assert(markers.frame.hidden)
markers:SetEnabled(true)
assert(not markers.frame.hidden)
UnitName=oldUnitName
UnitExists,UnitHealth,UnitHealthMax,UnitIsDead,UnitIsUnit,SetRaidTarget,TargetUnit=nil,nil,nil,nil,nil,nil,nil
print("PASS marker contents: measured UTF-8 names, full 100%, fixed identity, compact rows, death, click and disable")

-- The shaman row follows the player's upper-left corner.
AzerothExpeditionUI.db.actionbars.fieldKitBound=true
UnitClass=function() return "Shaman", "SHAMAN" end
function Node:GetWidth() return self.width or 40 end
local archi=node(); globals.ArchiTotemFrame=archi
local player=node(); player.scale=.8; globals.pfPlayer=player
for _, suffix in ipairs({"Earth1","Fire1","Water1","Air1","AllTotems"}) do
  globals["ArchiTotemButton_"..suffix]=node()
  globals["ArchiTotemButton_"..suffix].scale=0.8
end
globals.ArchiTotemDragHandle=node(); globals.ArchiTotemDragHandle.width=20
assert(actions:ApplyArchiTotemDockPosition(true))
assert(archi.point[2]==player and archi.point[4]==-72 and archi.point[5]==116)
globals.ArchiTotemButton_Recall=node(); globals.ArchiTotemButton_Recall.scale=0.8
globals.ArchiTotemButton_PresetManager=node(); globals.ArchiTotemButton_PresetManager.scale=0.8
actions:ApplyArchiTotemDockPosition(true)
assert(archi.point[4]==-72)
archi.left=100
globals.ArchiTotemButton_PresetManager.right=450
actions:ApplyArchiTotemDockPosition(true)
assert(archi.point[4]==-72)
actions:ApplyArchiTotemDockPosition(false)
assert(archi.point[1]=="CENTER")
print("PASS shaman: player-relative anchor, optional controls and anchor restoration")

function Node:GetTexCoord() return unpack(self.texcoord or {0,1,0,1}) end
function Node:GetName() return self.name end
function Node:GetDrawLayer() return self.layer or "BACKGROUND" end
function Node:SetDrawLayer(v) self.layer=v end
pfUI.GetExpeditionComponentOwner=function() return "actionbars" end
local name="ArchiTotemButton_Earth1"
local button=globals[name]; button.name=name
local icon=node(); globals[name.."Texture"]=icon
local normal=node(); globals[name.."NormalTexture"]=normal
actions:ApplyArchiTotemArt(true)
assert(icon.layer=="ARTWORK" and normal.hidden and button.aeuiTotemPocket.texture==actions.consumableKitTexturePath)
assert(icon.texcoord[1]==.08 and icon.texcoord[2]==.92)
assert(button.point[1]=="CENTER") -- Skin never moves provider buttons or replaces clicks.
actions:ApplyArchiTotemArt(false)
assert(icon.layer=="BACKGROUND" and icon.point[1]=="CENTER" and not normal.hidden)
assert(icon.texcoord[1]==0 and icon.texcoord[2]==1)
assert(button.aeuiTotemPocket.hidden)
local pocket=node(); pocket.top=110
local first=node(); first.aeuiTrinketKitPocketV1=pocket
globals.TrinketMenu_Trinket0=first; trinkets.top=100
top.backdrop=node()
actions:ApplyTrinketDockPosition(true)
assert(trinkets.point[2]==top and trinkets.point[5]==8)
print("PASS overhaul: native icon/normal restoration and visible trinket-shell alignment")

function Node:GetFont() return unpack(self.font or {"native-font", 14, ""}) end
function Node:SetFont(...) self.font={...} end
function Node:GetTextColor() return unpack(self.color or {1,1,0,1}) end
function Node:SetTextColor(...) self.color={...} end
function Node:GetAlpha() return self.alpha or 1 end
function Node:SetAlpha(v) self.alpha=v end
local duration, cooldown, bg=node(),node(),node()
duration.value="2:17"; cooldown.value="8"; duration.hidden=true
globals.EarthDurationText=duration
globals[name.."CooldownText"]=cooldown
globals[name.."CooldownBg"]=bg
actions:ApplyArchiTotemArt(true)
assert(duration.point[1]=="BOTTOM" and duration.point[5]==3 and duration.font[2]==12)
assert(cooldown.point[1]=="CENTER" and cooldown.point[5]==4 and cooldown.font[2]==16)
assert(duration.hidden and duration.value=="2:17" and cooldown.value=="8" and bg.alpha==0)
duration:SetPoint("CENTER",button,"CENTER",0,26) -- Provider direction change.
actions:ApplyArchiTotemArt(true)
assert(duration.point[1]=="BOTTOM")
actions:ApplyArchiTotemArt(false)
assert(duration.point[1]=="CENTER" and duration.font[1]=="native-font" and bg.alpha==1)
assert(duration.hidden and duration.value=="2:17")
print("PASS totem timers: separate anchors, provider text/visibility, repeat apply and restoration")

local file=assert(io.open("addon/AzerothExpeditionUI/Modules/ActionBars.lua","r"))
local source=file:read("*a"); file:close()
local cropBody=assert(source:match("(local function SetTrinketButtonNativeNormal.-)local function SetTrinketBackdrop"))
local crop=assert((loadstring or load)("local GetGlobal=getglobal; local function GetProviderNormalTexture(b) return getglobal(b:GetName()..'NormalTexture') end; " .. cropBody .. " return SetTrinketButtonNativeNormal"))()
for _, buttonName in ipairs({"TrinketMenu_Trinket0","TrinketMenu_Menu1"}) do
  local item=node(); item.name=buttonName
  local image=node(); globals[buttonName.."Icon"]=image
  crop(item,false); crop(item,false)
  assert(image.texcoord[1]==.08 and image.texcoord[2]==.92)
  crop(item,true)
  assert(image.texcoord[1]==0 and image.texcoord[2]==1)
end
print("PASS trinket crop: equipped/candidate icons and repeat-apply restoration")

UnitName=function() return "ShelfTest" end
GetRealmName=function() return "Realm" end
TrinketMenuOptions={KeepOpen="OFF",Columns=4}
TrinketMenuPerOptions={MenuDock="BOTTOMLEFT",MenuOrient="HORIZONTAL"}
local builds=0
TrinketMenu={DockWindows=function() end,BuildMenu=function()
  builds=builds+1
  actions:ConfigureTrinketShelf(true) -- Provider skin hook can re-enter.
end}
actions:ConfigureTrinketShelf(true)
assert(builds==1 and TrinketMenuOptions.KeepOpen=="ON" and TrinketMenuOptions.Columns==3)
assert(TrinketMenuPerOptions.MenuDock=="TOPLEFT" and TrinketMenuPerOptions.MainDock=="BOTTOMLEFT")
actions:ConfigureTrinketShelf(true)
assert(builds==1)
actions:ConfigureTrinketShelf(false)
assert(TrinketMenuOptions.KeepOpen=="OFF" and TrinketMenuOptions.Columns==4)
assert(TrinketMenuPerOptions.MenuDock=="BOTTOMLEFT" and TrinketMenuPerOptions.MainDock==nil)
assert(TrinketMenuOptions.MenuOnShift==nil)
print("PASS trinket shelf: native persistence, three-column dock, re-entry and original settings restored")

actions:ConfigureTrinketShelf(true)
local shelfState=AzerothExpeditionUI.db.actionbars.trinketShelfProfiles["ShelfTest - Realm"]
shelfState[9],shelfState[10],shelfState[11]=nil,nil,nil -- Existing shelf before resize lock upgrade.
TrinketMenuPerOptions.MainScale,TrinketMenuPerOptions.MenuScale=1.2,.65
TrinketMenuOptions.Locked="OFF"
globals.TrinketMenu_MenuFrame=node()
local locked=false
TrinketMenu.ReflectLock=function() locked=TrinketMenuOptions.Locked=="ON" end
TrinketMenu.FrameToScale=trinkets
actions:ConfigureTrinketShelf(true)
assert(trinkets.scale==.88 and globals.TrinketMenu_MenuFrame.scale==.88 and locked)
assert(TrinketMenu.FrameToScale==nil)
actions:ConfigureTrinketShelf(false)
assert(trinkets.scale==1.2 and globals.TrinketMenu_MenuFrame.scale==.65 and not locked)
print("PASS resize recovery: existing shelf migration, matched sizes, native lock and restoration")

actions:ConfigureTrinketShelf(true)
shelfState=AzerothExpeditionUI.db.actionbars.trinketShelfProfiles["ShelfTest - Realm"]
shelfState.mainSizeUpgraded=nil
shelfState.menuSizeAligned=nil
TrinketMenuPerOptions.MenuScale=.8
TrinketMenuPerOptions.MainScale=.8
actions:ConfigureTrinketShelf(true)
assert(trinkets.scale==.88 and globals.TrinketMenu_MenuFrame.scale==.88)
assert(globals.TrinketMenu_MenuFrame.point[2]==trinkets)
assert(globals.TrinketMenu_MenuFrame.point[3]=="BOTTOMLEFT" and globals.TrinketMenu_MenuFrame.point[5]==-2)
actions:ConfigureTrinketShelf(false)
assert(trinkets.scale==1.2)

globals.pfPlayer,globals.pfTarget=node(),node()
pfUI_config.position={
  pfPlayer={anchor="BOTTOM",parent="UIParent",xpos=actions.focusPlayerX,ypos=480,scale=.8},
  pfTarget={anchor="BOTTOM",parent="UIParent",xpos=actions.focusTargetX,ypos=480,scale=.8},
}
InCombatLockdown=function() return true end
actions:CompactFocusDebuffSpace()
assert(pfUI_config.position.pfPlayer.ypos==480)
InCombatLockdown=function() return false end
actions:CompactFocusDebuffSpace()
assert(pfUI_config.position.pfPlayer.ypos==actions.focusUnitY and globals.pfTarget.point[5]==actions.focusUnitY)
pfUI_config.position.pfPlayer.ypos=490
actions:CompactFocusDebuffSpace()
assert(pfUI_config.position.pfPlayer.ypos==490)
print("PASS compact spacing: saved/live migration, combat guard and custom position preserved")
