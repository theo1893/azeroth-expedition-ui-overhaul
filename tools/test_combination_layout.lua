-- lua tools/test_combination_layout.lua
unpack = unpack or table.unpack
table.getn = table.getn or function(t) return #t end
local Node = {}; Node.__index = Node
local function node() return setmetatable({point={"CENTER"}, scale=1, bottom=100},Node) end
function Node:GetNumPoints() return 1 end
function Node:GetPoint() return unpack(self.point) end
function Node:ClearAllPoints() self.point={} end
function Node:SetPoint(...) self.point={...} end
function Node:SetScale(v) self.scale=v end
function Node:GetEffectiveScale() return self.scale end
function Node:IsShown() return true end
function Node:GetBottom() return self.bottom end
function Node:GetLeft() return self.left end
function Node:GetRight() return self.right end
function Node:GetTop() return self.top end
UIParent=node()
local main, top, stance, trinkets = node(),node(),node(),node()
local globals={pfActionBarStances=stance, TrinketMenu_MainFrame=trinkets}
getglobal=function(name) return globals[name] end
pfUI={bars={[1]=main,[6]=top,[11]=stance}}
pfUI_config={}
AzerothExpeditionUI={media={root=""}, modules={}, db={actionbars={enabled=true,fieldKitBound=true}},
  RegisterModule=function(self,name,module) self.modules[name]=module end}
dofile("addon/AzerothExpeditionUI/Modules/ActionBars.lua")
local actions=AzerothExpeditionUI.modules.ActionBars
assert(actions:ApplyStanceDockPosition(true))
assert(stance.point[1]=="TOPLEFT" and stance.point[2]==main and stance.point[5]==-8)
assert(actions:ApplyTrinketDockPosition(true))
assert(trinkets.point[1]=="TOPLEFT" and trinkets.point[2]==top and trinkets.point[5]==0)
actions:ApplyStanceDockPosition(false)
actions:ApplyTrinketDockPosition(false)
assert(stance.point[1]=="CENTER" and trinkets.point[1]=="CENTER")
dofile("addon/AzerothExpeditionUI/Modules/TargetMarkers.lua")
local markers=AzerothExpeditionUI.modules.TargetMarkers
markers.frame=node() -- Exercise the real anchoring without constructing interactive cells.
assert(markers:ApplyAnchor())
assert(markers.frame.scale==0.8 and markers.frame.point[1]=="TOPRIGHT")
assert(markers.frame.point[2]==main)
main.scale=1.25
markers:ApplyAnchor()
assert(markers.frame.scale==1)
local pet=node(); pet.bottom=50; pet[1]=node()
globals.pfActionBarPet=pet; pfUI.bars[12]=pet
markers:ApplyAnchor()
assert(markers.frame.point[2]==pet)
AzerothExpeditionUI.db.actionbars.fieldKitBound=false
markers:ApplyAnchor()
assert(markers.frame.scale==1 and markers.anchorStatus=="pet-row")
print("PASS combination: aligned docks, restoration, compact scale, pet clearance and unbound fallback")

-- Shaman's closed row includes the unscaled handle and optional buttons.
AzerothExpeditionUI.db.actionbars.fieldKitBound=true
UnitClass=function() return "Shaman", "SHAMAN" end
function Node:GetWidth() return self.width or 40 end
function Node:GetHeight() return 40 end
local archi=node(); globals.ArchiTotemFrame=archi
for _, suffix in ipairs({"Earth1","Fire1","Water1","Air1","AllTotems"}) do
  globals["ArchiTotemButton_"..suffix]=node()
  globals["ArchiTotemButton_"..suffix].scale=0.8
end
globals.ArchiTotemDragHandle=node(); globals.ArchiTotemDragHandle.width=20
assert(actions:ApplyArchiTotemDockPosition(true))
assert(archi.point[2]==markers.frame and archi.point[4]==-190 and archi.point[5]==-10)
globals.ArchiTotemButton_Recall=node(); globals.ArchiTotemButton_Recall.scale=0.8
globals.ArchiTotemButton_PresetManager=node(); globals.ArchiTotemButton_PresetManager.scale=0.8
actions:ApplyArchiTotemDockPosition(true)
assert(archi.point[4]==-254) -- Added controls move the whole row left, retaining the gap.
archi.left=100
globals.ArchiTotemButton_PresetManager.right=450
actions:ApplyArchiTotemDockPosition(true)
assert(archi.point[4]==-270) -- Actual scaled edges override nominal summed widths.
actions:ApplyArchiTotemDockPosition(false)
assert(archi.point[1]=="CENTER")
print("PASS shaman: actual row width, optional controls, top alignment and anchor restoration")

function Node:EnableMouse() end
function Node:SetAllPoints() end
function Node:CreateTexture() return node() end
function Node:SetTexture(v) self.texture=v end
function Node:SetTexCoord(...) self.texcoord={...} end
function Node:GetTexCoord() return unpack(self.texcoord or {0,1,0,1}) end
function Node:SetBlendMode() end
function Node:SetVertexColor() end
function Node:SetWidth(v) self.width=v end
function Node:SetHeight(v) self.height=v end
function Node:Show() self.hidden=false end
function Node:Hide() self.hidden=true end
function Node:IsShown() return not self.hidden end
function Node:GetName() return self.name end
function Node:GetDrawLayer() return self.layer or "BACKGROUND" end
function Node:SetDrawLayer(v) self.layer=v end
CreateFrame=function() return node() end
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
assert(trinkets.point[2]==top.backdrop and trinkets.point[5]==-10)
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
assert(builds==1 and TrinketMenuOptions.KeepOpen=="ON" and TrinketMenuOptions.Columns==2)
assert(TrinketMenuPerOptions.MenuDock=="TOPLEFT" and TrinketMenuPerOptions.MainDock=="BOTTOMLEFT")
actions:ConfigureTrinketShelf(true)
assert(builds==1)
actions:ConfigureTrinketShelf(false)
assert(TrinketMenuOptions.KeepOpen=="OFF" and TrinketMenuOptions.Columns==4)
assert(TrinketMenuPerOptions.MenuDock=="BOTTOMLEFT" and TrinketMenuPerOptions.MainDock==nil)
assert(TrinketMenuOptions.MenuOnShift==nil)
print("PASS trinket shelf: native persistence, two-column dock, re-entry and original settings restored")

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
assert(pfUI_config.position.pfPlayer.ypos==470 and globals.pfTarget.point[5]==470)
pfUI_config.position.pfPlayer.ypos=490
actions:CompactFocusDebuffSpace()
assert(pfUI_config.position.pfPlayer.ypos==490)
print("PASS compact spacing: saved/live migration, combat guard and custom position preserved")
