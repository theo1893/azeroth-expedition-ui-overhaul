-- lua tools/test_tooltips.lua
unpack = unpack or table.unpack
local Node = {}; Node.__index = Node
local function node() return setmetatable({shown=true, scripts={}, points={}}, Node) end
function Node:CreateTexture() return node() end
function Node:SetTexture(...) self.texture={...} end
function Node:SetAllPoints(frame) self.anchor=frame end
function Node:SetTexCoord(...) self.uv={...} end
function Node:SetPoint(...) table.insert(self.points, {...}) end
function Node:SetVertexColor(...) self.tint={...} end
function Node:Show() self.shown=true end
function Node:Hide() self.shown=false end
function Node:IsShown() return self.shown end
function Node:GetScript(key) return self.scripts[key] end
function Node:SetScript(key, value) self.scripts[key]=value end
function Node:SetBackdrop(value) self.backdropValue=value end
function Node:GetBackdrop() return self.backdropValue end
function Node:GetBackdropColor() return 0.2,0.2,0.2,1 end
function Node:SetBackdropColor(...) self.background={...} end
function Node:GetBackdropBorderColor() return 0.5,0.5,0.5,1 end
function Node:SetBackdropBorderColor(...) self.border={...} end
function Node:GetStatusBarTexture() return "provider-fill" end
function Node:SetStatusBarTexture(value) self.fill=value end
local function tip()
  local frame=node()
  frame.backdrop, frame.backdrop_shadow=node(),node()
  frame.backdrop:SetBackdrop("provider-shell")
  return frame
end
local frames={GameTooltip=tip(), ItemRefTooltip=tip(), WorldMapTooltip=tip(), GameTooltipStatusBar=tip()}
local nativeShows=0
frames.WorldMapTooltip:SetScript("OnShow", function()
  nativeShows=nativeShows+1
  frames.WorldMapTooltip.backdrop:SetBackdrop("rebuilt-map-shell")
end)
-- Vanilla exposes lowercase getglobal; no invented global helper in the mock.
GetGlobal=nil
getglobal=function(name) return frames[name] end
function Node:RegisterEvent(name) self.event=name end
CreateFrame=function() return node() end
local owned=true
pfUI={GetExpeditionComponentOwner=function() if owned then return "tooltips" end end}
pfUI_config={tooltip={alpha="0.9"}}
AzerothExpeditionUI={media={root="test/"}, db={tooltips={enabled=true}},
  RegisterModule=function(self, _, module) self.module=module end}
dofile("addon/AzerothExpeditionUI/Modules/Tooltips.lua")
local module=AzerothExpeditionUI.module
module:Initialize()
assert(module.events.event=="ADDON_LOADED")
local frame=frames.GameTooltip
local art=frame.aeuiTooltipArt
assert(module.appliedCount==3 and #art.slices==8)
assert(frame.backdrop:IsShown()) -- ItemRef close button is parented to this frame.
assert(frame.backdrop:GetBackdrop()==nil and not frame.backdrop_shadow:IsShown())
assert(art.slices[1].texture[1]=="test/ActionBars\\Readouts\\ReadoutShellV1")
assert(art.slices[2].uv[4]-art.slices[2].uv[3]==1/16)
assert(art.slices[2].points[1][5]==1 and art.slices[2].points[2][5]==0)
assert(frames.GameTooltipStatusBar.fill=="test/UnitFrames\\UnitFrameHealthFillV1")
frame:SetBackdropBorderColor(1,0,0,1)
assert(art.slices[1].tint[2]==0)
frames.WorldMapTooltip.scripts.OnShow()
assert(nativeShows==1 and frames.WorldMapTooltip.backdrop:GetBackdrop()==nil)
frames.AtlasLootTooltip=tip() -- Late provider discovery.
module.events.scripts.OnEvent()
assert(module.appliedCount==4)
AzerothExpeditionUI.db.tooltips.enabled=false
module:Apply()
assert(frame.backdrop:GetBackdrop()=="provider-shell" and frame.backdrop_shadow:IsShown())
assert(not art.bed:IsShown() and not art.slices[1]:IsShown())
assert(frames.WorldMapTooltip.backdrop:GetBackdrop()=="rebuilt-map-shell")
assert(frames.GameTooltipStatusBar.fill=="provider-fill")
AzerothExpeditionUI.db.tooltips.enabled=true
module:Apply()
owned=false
module:Apply()
assert(frame.backdrop:GetBackdrop()=="provider-shell")
print("PASS tooltips: scoped frames, semantic colour, map rebuild, late provider, enable/disable and fallback")
