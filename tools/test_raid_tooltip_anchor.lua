-- lua tools/test_raid_tooltip_anchor.lua
local file=assert(io.open("addon/pfUI/modules/tooltip.lua","r"))
local source=file:read("*a"); file:close()
local body=assert(source:match("(function pfUI%.tooltip:AnchorRaidTooltip.-)  local units ="))
local loader=loadstring or load
local function rect(l,r,b,t,s)
  return {GetLeft=function() return l end, GetRight=function() return r end,
    GetBottom=function() return b end, GetTop=function() return t end,
    GetEffectiveScale=function() return s or 1 end, IsVisible=function() return true end}
end
C={tooltip={position="cursor"}}
UIParent={GetEffectiveScale=function() return 1 end,
  GetWidth=function() return 1000 end, GetHeight=function() return 700 end}
pfUI={tooltip={},uf={raid={}}}
assert(loader(body))()
local tip={GetEffectiveScale=function() return .8 end,
  GetWidth=function() return 250 end, GetHeight=function() return 150 end,
  ClearAllPoints=function(self) self.point=nil end,
  SetPoint=function(self,...) self.point={...} end}
local owner={label="player", cache_raid=1} -- Solo self-in-raid uses player, not raid.
pfUI.uf.raid={rect(20,100,100,200),rect(100,220,100,200)}
pfUI.tooltip:AnchorRaidTooltip(tip,owner)
assert(tip.point[4]*.8==232) -- Outside the whole raid, not merely the hovered cell.
owner.label="party"
pfUI.uf.raid={rect(850,950,100,200)}
pfUI.tooltip:AnchorRaidTooltip(tip,owner)
assert(tip.point[4]*.8==638)
owner.label="raid"
pfUI.uf.raid={rect(100,950,300,600)}
pfUI.tooltip:AnchorRaidTooltip(tip,owner)
assert(tip.point[5]*.8==272) -- Lower gap also reserves the tooltip health bar.
pfUI.uf.raid={rect(100,950,30,160)}
pfUI.tooltip:AnchorRaidTooltip(tip,owner)
assert(tip.point[5]*.8==292)
local point=tip.point
pfUI.tooltip:AnchorRaidTooltip(tip,{label="target"})
assert(tip.point==point)
pfUI.tooltip:AnchorRaidTooltip(tip,{label="player",cache_raid=0})
assert(tip.point==point) -- The ordinary player frame must still follow the cursor.
C.tooltip.position="free"
pfUI.tooltip:AnchorRaidTooltip(tip,owner)
assert(tip.point==point)
print("PASS raid tooltip: raid union, right/left/below/above, scale conversion and other modes untouched")
