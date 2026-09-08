local checkCount = 0
local function Check(value, message)
  if not value then
    error(message or "check failed", 2)
  end
  checkCount = checkCount + 1
end

table.getn = table.getn or function(value)
  return #value
end

local function NewTexture()
  local texture = {}
  function texture:SetAllPoints() end
  function texture:SetTexture(value)
    self.texture = value
  end
  function texture:SetVertexColor(r, g, b, a)
    self.color = { r, g, b, a }
  end
  function texture:SetHeight(value)
    self.height = value
  end
  function texture:SetWidth(value)
    self.width = value
  end
  function texture:ClearAllPoints()
    self.point = nil
  end
  function texture:SetPoint(...)
    self.point = { ... }
  end
  return texture
end

local function NewFontString()
  local text = {}
  function text:SetPoint(...) self.point = { ... } end
  function text:SetShadowOffset() end
  function text:SetText(value) self.value = value end
  function text:SetTextColor(r, g, b, a)
    self.color = { r, g, b, a }
  end
  return text
end

local namedFrames = {}
CreateFrame = function(_, name)
  local frame = {
    shown = true,
    scripts = {},
  }
  function frame:SetWidth(value) self.width = value end
  function frame:SetHeight(value) self.height = value end
  function frame:SetFrameStrata(value) self.strata = value end
  function frame:SetFrameLevel(value) self.level = value end
  function frame:EnableMouse(value) self.mouse = value end
  function frame:CreateTexture() return NewTexture() end
  function frame:CreateFontString() return NewFontString() end
  function frame:SetScript(scriptName, handler)
    self.scripts[scriptName] = handler
  end
  function frame:Hide() self.shown = false end
  function frame:Show() self.shown = true end
  function frame:IsShown() return self.shown and 1 or nil end
  function frame:ClearAllPoints() self.point = nil end
  function frame:SetPoint(...)
    self.point = { ... }
  end
  function frame:SetScale(value) self.scale = value end
  function frame:SetAlpha(value) self.alpha = value end
  if name then
    namedFrames[name] = frame
  end
  return frame
end

GetLocale = function()
  return "zhCN"
end

local currentClass = "WARRIOR"
UnitClass = function()
  return currentClass, currentClass
end

UIParent = {
  centerX = 500,
  centerY = 400,
  scale = 1,
}
function UIParent:GetCenter()
  return self.centerX, self.centerY
end
function UIParent:GetEffectiveScale()
  return self.scale
end

DoiteDPSMainFrame = {
  centerX = 500,
  centerY = 275,
  scale = 1,
  shown = true,
}
function DoiteDPSMainFrame:GetCenter()
  return self.centerX, self.centerY
end
function DoiteDPSMainFrame:GetEffectiveScale()
  return self.scale
end
function DoiteDPSMainFrame:IsShown()
  return self.shown and 1 or nil
end

local iconFrames = {
  resourceOne = {
    _daShouldShow = false,
    _daSliding = false,
    shown = true,
  },
  resourceTwo = {
    _daShouldShow = false,
    _daSliding = false,
    shown = false,
  },
  statusOne = {
    _daShouldShow = false,
    _daSliding = false,
    shown = false,
  },
  shamanOne = {
    _daShouldShow = false,
    _daSliding = false,
    shown = false,
  },
}
for _, frame in pairs(iconFrames) do
  function frame:IsShown()
    return self.shown and 1 or nil
  end
end
DoiteAuras_GetIconFrame = function(key)
  return iconFrames[key]
end

GameTooltip = {
  lines = {},
}
function GameTooltip:SetOwner(owner, anchor)
  self.owner = owner
  self.anchor = anchor
  self.lines = {}
end
function GameTooltip:AddLine(text, r, g, b)
  self.lines[table.getn(self.lines) + 1] = {
    text = text,
    r = r,
    g = g,
    b = b,
  }
end
function GameTooltip:Show()
  self.shown = true
end
function GameTooltip:Hide()
  self.shown = false
end

DoiteAurasDB = {
  spells = {
    resourceOne = {
      displayName = "血性狂暴",
      group = "测试资源",
      order = 2,
      isLeader = true,
      offsetX = -114,
      offsetY = -83,
      scale = 1,
    },
    resourceTwo = {
      displayName = "狂暴之怒",
      group = "测试资源",
      order = 1,
    },
    statusOne = {
      displayName = "战斗怒吼",
      group = "测试持续",
      order = 1,
      isLeader = true,
      offsetX = 35,
      offsetY = -83,
      scale = 1,
    },
    shamanOne = {
      displayName = "节能施法",
      group = "测试触发",
      order = 1,
      isLeader = true,
      offsetX = 35,
      offsetY = -83,
      scale = 1,
    },
  },
}

dofile("DoiteAuras/Modules/DoiteMonitorGroupLabels.lua")

DoiteAurasMonitorLabels:Register("WARRIOR", {
  {
    name = "测试资源",
    dx = -114,
    dy = 42,
    label = "资源",
    labelWidth = 36,
    labelSide = "TOP",
    labelColor = { 1, 0.67, 0.2 },
  },
  {
    name = "测试持续",
    dx = 35,
    dy = 42,
    label = "持续",
    labelWidth = 36,
    labelSide = "TOP",
    labelColor = { 0.36, 1, 0.55 },
  },
  {
    name = "空组",
    dx = 100,
    dy = -42,
    label = "空",
    labelWidth = 28,
    labelSide = "BOTTOM",
  },
})

Check(
    DoiteAuras_UpdateMonitorGroupLabels() == false,
    "inactive groups should not create visual clutter"
)

local resourceLabel =
    DoiteAurasMonitorLabels:GetFrame("WARRIOR", 1)
local statusLabel =
    DoiteAurasMonitorLabels:GetFrame("WARRIOR", 2)
local emptyLabel =
    DoiteAurasMonitorLabels:GetFrame("WARRIOR", 3)

Check(resourceLabel.shown == false, "inactive resource label should hide")
Check(statusLabel.shown == false, "inactive status label should hide")
Check(emptyLabel.shown == false, "groups without monitors should stay hidden")
Check(resourceLabel.text.value == "资源", "short label text missing")
Check(resourceLabel.width == 36, "configured label width missing")
Check(
    resourceLabel.background == nil and resourceLabel.accent == nil,
    "lightweight labels should not have badges or accent bars"
)

iconFrames.resourceOne._daShouldShow = true
Check(
    DoiteAuras_UpdateMonitorGroupLabels() == true,
    "active groups should display their label"
)
Check(resourceLabel.shown == true, "active resource label should show")
Check(statusLabel.shown == false, "unrelated inactive label should stay hidden")
Check(resourceLabel.point[4] == -114, "resource label x anchor is wrong")
Check(resourceLabel.point[5] == -64, "top label should sit above icons")
Check(resourceLabel.alpha == 0.92, "active label alpha is wrong")
Check(resourceLabel._doiteActive == true, "active state is wrong")

this = resourceLabel
resourceLabel.scripts.OnEnter()
Check(GameTooltip.shown == true, "label tooltip should open")
Check(GameTooltip.owner == resourceLabel, "tooltip owner is wrong")
Check(GameTooltip.lines[1].text == "测试资源", "tooltip title is wrong")
Check(
    GameTooltip.lines[3].text == "- 狂暴之怒",
    "tooltip members should use group priority order"
)
Check(
    GameTooltip.lines[4].text == "- 血性狂暴"
        and GameTooltip.lines[4].g == 1,
    "active tooltip member should be highlighted"
)
resourceLabel.scripts.OnLeave()
Check(GameTooltip.shown == false, "label tooltip should close")

DoiteDPSMainFrame.shown = false
DoiteAuras_UpdateMonitorGroupLabels()
Check(
    resourceLabel.shown == true,
    "active labels should survive a hidden timeline"
)
Check(
    statusLabel.shown == false,
    "inactive labels should hide with the timeline"
)

iconFrames.resourceOne._daShouldShow = false
DoiteAuras_UpdateMonitorGroupLabels()
Check(
    resourceLabel.shown == false,
    "inactive label should hide when timeline is hidden"
)

iconFrames.resourceTwo._daSliding = 1
DoiteAuras_UpdateMonitorGroupLabels()
Check(
    resourceLabel.shown == true and resourceLabel.alpha == 0.92,
    "sliding icons should activate their group label"
)

DoiteDPSMainFrame.shown = true
DoiteDPSMainFrame.centerX = 530
DoiteDPSMainFrame.centerY = 290
DoiteAurasDB.spells.resourceOne.offsetX = -84
DoiteAurasDB.spells.resourceOne.offsetY = -68
DoiteAuras_UpdateMonitorGroupLabels()
Check(
    resourceLabel.point[4] == -84
        and resourceLabel.point[5] == -49,
    "labels should follow DoiteDPS movement"
)

DoiteAurasMonitorLabels:Register("SHAMAN", {
  {
    name = "测试触发",
    dx = 35,
    dy = 42,
    label = "触发",
    labelWidth = 36,
    labelSide = "TOP",
    labelColor = { 0.36, 1, 0.55 },
  },
})
currentClass = "SHAMAN"
iconFrames.shamanOne._daShouldShow = true
DoiteAuras_UpdateMonitorGroupLabels()
local shamanLabel =
    DoiteAurasMonitorLabels:GetFrame("SHAMAN", 1)
Check(resourceLabel.shown == false, "other class labels should hide")
Check(shamanLabel.shown == true, "current class labels should show")

DoiteAuras_SetMonitorGroupLabelsEnabled(false)
Check(shamanLabel.shown == false, "disabled labels should hide")
Check(
    DoiteAurasDB.monitorGroupLabels == false,
    "label preference should be stored"
)

DoiteAuras_SetMonitorGroupLabelsEnabled(true)
Check(shamanLabel.shown == true, "re-enabled labels should return")

currentClass = "WARRIOR"
DoiteDPSMainFrame.centerX = 550
DoiteAurasDB.spells.resourceOne.offsetX = -64
arg1 = 0.11
this = namedFrames.DoiteAurasMonitorGroupLabelUpdater
namedFrames.DoiteAurasMonitorGroupLabelUpdater.scripts.OnUpdate()
Check(
    resourceLabel.point[4] == -64,
    "updater heartbeat should track DoiteDPS automatically"
)

print(
    "DoiteMonitorGroupLabels_spec: "
        .. checkCount
        .. " checks passed"
)
