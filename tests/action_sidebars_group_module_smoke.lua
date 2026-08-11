local root = assert(arg[1], "repository root argument is required")
table.getn = table.getn or function(value) return #value end
unpack = unpack or table.unpack

local Frame = {}
Frame.__index = Frame

function Frame:GetName() return self.name end
function Frame:GetParent() return self.parent end
function Frame:SetParent(parent) self.parent = parent end
function Frame:GetScale() return self.scale or 1 end
function Frame:SetScale(scale) self.scale = scale end
function Frame:GetWidth() return self.width end
function Frame:GetHeight() return self.height end
function Frame:SetWidth(width) self.width = width end
function Frame:SetHeight(height) self.height = height end
function Frame:ClearAllPoints() self.points = {} end
function Frame:SetPoint(...)
  table.insert(self.points, { ... })
end
function Frame:GetNumPoints() return table.getn(self.points) end
function Frame:GetPoint(index) return unpack(self.points[index]) end
function Frame:SetAllPoints(frame)
  self:ClearAllPoints()
  self:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  self:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
end
function Frame:Show() self.shown = true end
function Frame:Hide() self.shown = false end
function Frame:IsShown() return self.shown == true end
function Frame:GetScript(name) return self.scripts[name] end
function Frame:SetScript(name, script) self.scripts[name] = script end

local function NewFrame(name, width, height)
  return setmetatable({
    name = name,
    width = width or 76,
    height = height or 101,
    scale = 1.2,
    points = {},
    scripts = {},
    shown = true,
  }, Frame)
end

local Text = {}
Text.__index = Text
function Text:GetText() return self.value end
function Text:SetText(value) self.value = value end

local function AddMover(frame, label)
  local mover = NewFrame(frame.name .. "Drag", frame.width, frame.height)
  mover.frame = frame
  mover.text = setmetatable({ value = label }, Text)
  mover:SetAllPoints(frame)
  mover:SetScript("OnMouseWheel", function()
    local owner = this.frame
    owner:SetScale(owner:GetScale() + arg1 / 10)
    pfUI_config.position[owner:GetName()].scale = owner:GetScale()
  end)
  mover:SetScript("OnDragStop", function()
    local owner = this.frame
    owner:ClearAllPoints()
    owner:SetPoint("RIGHT", UIParent, "RIGHT", -150, -80)
    local position = pfUI_config.position[owner:GetName()]
    position.anchor = "RIGHT"
    position.parent = "UIParent"
    position.xpos = -150
    position.ypos = -80
  end)
  mover:SetScript("OnClick", function() end)
  frame.drag = mover
end

UIParent = NewFrame("UIParent", 1920, 1080)
local paging = NewFrame("pfActionBarPaging")
local vertical = NewFrame("pfActionBarVertical")
local left = NewFrame("pfActionBarLeft")
local right = NewFrame("pfActionBarRight")
for _, pair in pairs({
  { paging, "ActionBarPaging" },
  { vertical, "ActionBarVertical" },
  { left, "ActionBarLeft" },
  { right, "ActionBarRight" },
}) do
  AddMover(pair[1], pair[2])
end

_G.pfActionBarPaging = paging
_G.pfActionBarVertical = vertical
_G.pfActionBarLeft = left
_G.pfActionBarRight = right
function getglobal(name) return _G[name] end

local currentName = "大奶黑牛"
function UnitName() return currentName end
function GetRealmName() return "Basin of Stars" end
function InCombatLockdown() return false end
STANDARD_TEXT_FONT = "Fonts\\FZBWJW.TTF"

local function LegacyBar(pageable)
  return {
    buttons = "12",
    formfactor = "1 x 12",
    icon_size = "20",
    spacing = "1",
    enable = "1",
    pageable = pageable or "0",
    autohide = "0",
    showkeybind = "1",
    showmacro = "1",
  }
end

local function LegacyPosition(x, y)
  return {
    anchor = "RIGHT",
    parent = "UIParent",
    xpos = x,
    ypos = y,
    scale = 1.2,
  }
end

pfUI_config = {
  global = { pixelperfect = "8" },
  bars = {
    bar1 = { spacing = "1" },
    bar2 = LegacyBar("0"),
    bar3 = LegacyBar("0"),
    bar4 = LegacyBar("0"),
    bar5 = LegacyBar("0"),
  },
  position = {
    pfActionBarPaging = LegacyPosition(-102, 4),
    pfActionBarVertical = LegacyPosition(-68, 4),
    pfActionBarLeft = LegacyPosition(-34, 3),
    pfActionBarRight = LegacyPosition(0, 3),
  },
  unitframes = {},
  castbar = {},
}

local function LoadMovable(frame)
  local position = pfUI_config.position[frame:GetName()]
  if not position then return end
  frame:SetParent(UIParent)
  frame:SetScale(position.scale or 1)
  frame:ClearAllPoints()
  frame:SetPoint(
    position.anchor or "RIGHT",
    UIParent,
    position.anchor or "RIGHT",
    position.xpos or 0,
    position.ypos or 0
  )
end

local groupOffsets = {
  pfActionBarPaging = { 0, 0 },
  pfActionBarVertical = { 98, 0 },
  pfActionBarLeft = { 0, -128 },
  pfActionBarRight = { 98, -128 },
}

local function ConvertFrameAnchor(frame, anchor)
  local rootPoint = paging.points[1]
  local rootX = rootPoint and rootPoint[4] or
    pfUI_config.position.pfActionBarPaging.xpos
  local rootY = rootPoint and rootPoint[5] or
    pfUI_config.position.pfActionBarPaging.ypos
  local offset = assert(groupOffsets[frame:GetName()])
  return anchor, rootX + offset[1], rootY + offset[2]
end

local updateCalls = 0
local bars = {
  [2] = paging,
  [3] = right,
  [4] = vertical,
  [5] = left,
}
function bars:UpdateConfig()
  updateCalls = updateCalls + 1
  for _, frame in pairs({ paging, vertical, left, right }) do
    LoadMovable(frame)
  end
end

local unlock = NewFrame("pfUnlock")
unlock.shown = true

pfUI = {
  bars = bars,
  api = {
    LoadMovable = LoadMovable,
    ConvertFrameAnchor = ConvertFrameAnchor,
  },
  unlock = unlock,
  movables = {
    pfActionBarPaging = paging,
    pfActionBarVertical = vertical,
    pfActionBarLeft = left,
    pfActionBarRight = right,
  },
}

function hooksecurefunc(target, name, callback)
  local original = assert(target[name])
  target[name] = function(...)
    local results = { original(...) }
    callback(...)
    return unpack(results)
  end
end

AzerothExpeditionUI = {
  media = { root = "Interface\\AddOns\\AzerothExpeditionUI\\Media\\" },
  db = {
    actionbars = {
      enabled = true,
      fieldKitBound = false,
      sideBarGroupProfiles = {},
    },
  },
  modules = {},
}
function AzerothExpeditionUI:RegisterModule(name, module)
  self.modules[name] = module
end

dofile(root .. "/addon/AzerothExpeditionUI/Modules/ActionBars.lua")
local module = assert(AzerothExpeditionUI.modules.ActionBars)
module:Initialize()
module:Apply()

local profile = assert(
  AzerothExpeditionUI.db.actionbars.sideBarGroupProfiles[
    "大奶黑牛 - Basin of Stars"
  ]
)
assert(profile.bound == true)
assert(profile.layoutVersion == 1)
assert(profile.migration == "exact-v11-profile")
assert(profile.backup.version == 1)
assert(profile.backup.bars.bar2.formfactor.value == "1 x 12")
assert(profile.backup.positions.pfActionBarPaging.value.xpos == -102)

for _, key in pairs({ "bar2", "bar3", "bar4", "bar5" }) do
  local config = pfUI_config.bars[key]
  assert(config.formfactor == "3 x 4")
  assert(config.icon_size == "20")
  assert(config.spacing == "1")
  assert(config.buttons == "12")
  assert(config.autohide == "0")
  assert(config.showkeybind == "1")
end
assert(pfUI_config.position.pfActionBarPaging.xpos == -133)
assert(pfUI_config.position.pfActionBarPaging.ypos == -68)
assert(pfUI_config.position.pfActionBarVertical.xpos == -35)
assert(pfUI_config.position.pfActionBarVertical.ypos == -68)
assert(pfUI_config.position.pfActionBarLeft.xpos == -133)
assert(pfUI_config.position.pfActionBarLeft.ypos == -196)
assert(pfUI_config.position.pfActionBarRight.xpos == -35)
assert(pfUI_config.position.pfActionBarRight.ypos == -196)

assert(vertical.points[1][1] == "TOPLEFT")
assert(vertical.points[1][2] == paging)
assert(vertical.points[1][3] == "TOPRIGHT")
assert(vertical.points[1][4] == 6)
assert(left.points[1][2] == paging)
assert(left.points[1][3] == "BOTTOMLEFT")
assert(left.points[1][5] == -6)
assert(right.points[1][2] == left)
assert(right.points[1][3] == "TOPRIGHT")
assert(paging.drag.text:GetText() == "Side Bars 6 x 8")
assert(paging.drag.shown == true)
assert(vertical.drag.shown == false)
assert(left.drag.shown == false)
assert(right.drag.shown == false)
assert(table.getn(paging.drag.points) == 2)
assert(paging.drag.points[2][2] == right)

-- Provider content settings remain individual while grouped; a geometry edit
-- is reasserted at the UpdateConfig boundary without losing that content edit.
pfUI_config.bars.bar4.formfactor = "12 x 1"
pfUI_config.bars.bar4.pageable = "1"
local beforeRefresh = updateCalls
pfUI.bars:UpdateConfig()
assert(updateCalls == beforeRefresh + 2)
assert(pfUI_config.bars.bar4.formfactor == "3 x 4")
assert(pfUI_config.bars.bar4.pageable == "1")
assert(vertical.points[1][2] == paging)

-- Scrolling the single mover synchronizes all four provider scales.
this = paging.drag
arg1 = 1
paging.drag:GetScript("OnMouseWheel")()
this = nil
arg1 = nil
for _, frame in pairs({ paging, vertical, left, right }) do
  assert(math.abs(frame:GetScale() - 1.3) < 0.001)
  assert(math.abs(
    pfUI_config.position[frame:GetName()].scale - 1.3
  ) < 0.001)
end

-- Dragging the one visible mover persists the whole union, then restores the
-- dependent 2x2 anchors rather than leaving four independent movers.
this = paging.drag
paging.drag:GetScript("OnDragStop")()
this = nil
assert(pfUI_config.position.pfActionBarPaging.xpos == -150)
assert(pfUI_config.position.pfActionBarPaging.ypos == -80)
assert(pfUI_config.position.pfActionBarVertical.xpos == -52)
assert(pfUI_config.position.pfActionBarLeft.ypos == -208)
assert(vertical.points[1][2] == paging)
assert(right.points[1][2] == left)

-- Middle-click is group-home, not pfUI's paging-bar-only reset.
this = paging.drag
arg1 = "MiddleButton"
paging.drag:GetScript("OnClick")()
this = nil
arg1 = nil
assert(pfUI_config.position.pfActionBarPaging.xpos == -133)
assert(pfUI_config.position.pfActionBarPaging.ypos == -68)
assert(pfUI_config.position.pfActionBarRight.xpos == -35)
assert(pfUI_config.position.pfActionBarRight.ypos == -196)

local unbound, unboundMessage = module:SetSideBarGroupBinding(false)
assert(unbound == true)
assert(string.find(unboundMessage, "ungrouped", 1, true))
assert(profile.bound == false)
for _, key in pairs({ "bar2", "bar3", "bar4", "bar5" }) do
  assert(pfUI_config.bars[key].formfactor == "1 x 12")
  assert(pfUI_config.bars[key].icon_size == "20")
  assert(pfUI_config.bars[key].spacing == "1")
end
assert(pfUI_config.bars.bar4.pageable == "1")
assert(pfUI_config.position.pfActionBarPaging.xpos == -102)
assert(pfUI_config.position.pfActionBarPaging.ypos == 4)
assert(pfUI_config.position.pfActionBarVertical.xpos == -68)
assert(pfUI_config.position.pfActionBarLeft.xpos == -34)
assert(pfUI_config.position.pfActionBarRight.xpos == 0)
assert(paging.drag.text:GetText() == "ActionBarPaging")
assert(vertical.drag.shown == true)
assert(left.drag.shown == true)
assert(right.drag.shown == true)

-- Binding state is character/profile scoped; another character remains free.
currentName = "另一个角色"
module:MaintainSideBarGroup()
assert(module.sideBarGroupStatus == "free")
assert(
  AzerothExpeditionUI.db.actionbars.sideBarGroupProfiles[
    "另一个角色 - Basin of Stars"
  ] == nil
)

-- A manual bind with an invalid bar count fails before changing any of the
-- four geometry profiles or their saved positions.
pfUI_config.bars.bar5.buttons = "11"
local failedBind, failedMessage = module:SetSideBarGroupBinding(true)
assert(failedBind == false)
assert(string.find(failedMessage, "12 buttons", 1, true))
assert(pfUI_config.bars.bar2.formfactor == "1 x 12")
assert(pfUI_config.bars.bar4.formfactor == "1 x 12")
assert(pfUI_config.position.pfActionBarPaging.xpos == -102)
assert(pfUI_config.position.pfActionBarRight.xpos == 0)
assert(
  AzerothExpeditionUI.db.actionbars.sideBarGroupProfiles[
    "另一个角色 - Basin of Stars"
  ].bound == false
)

local status = module:GetRuntimeStatus()
assert(string.find(status, "sidebar%-group%-contract=1%.0"))
assert(string.find(status, "sidebar%-group%-binding=free"))

print("action sidebars group module smoke test passed")
