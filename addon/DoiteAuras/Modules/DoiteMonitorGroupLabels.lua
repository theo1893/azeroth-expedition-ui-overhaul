---------------------------------------------------------------
-- DoiteMonitorGroupLabels.lua
-- 战士/萨满职业监控的轻量分组标签。
-- 标签使用与监控组相同的 DoiteDPS 锚点，不参与图标布局。
---------------------------------------------------------------

local UPDATE_INTERVAL = 0.10
local LABEL_HEIGHT = 13
local LABEL_OFFSET = 19

local locale = (GetLocale and GetLocale()) or "zhCN"
local zh = locale == "zhCN" or locale == "zhTW"

local Labels = _G["DoiteAurasMonitorLabels"] or {}
_G["DoiteAurasMonitorLabels"] = Labels

Labels.registry = Labels.registry or {}
Labels.frames = Labels.frames or {}

local function IsTrue(value)
  return value == true or value == 1
end

local function IsFrameShown(frame)
  if not frame or not frame.IsShown then
    return false
  end
  return IsTrue(frame:IsShown())
end

local function GetIconFrame(key)
  if DoiteAuras_GetIconFrame then
    local frame = DoiteAuras_GetIconFrame(key)
    if frame then
      return frame
    end
  end
  return _G["DoiteIcon_" .. tostring(key)]
end

local function IsIconActive(key)
  local frame = GetIconFrame(key)
  if not frame then
    return false
  end

  if IsTrue(frame._daShouldShow) or IsTrue(frame._daSliding) then
    return true
  end

  if frame._daShouldShow == nil and frame._daSliding == nil then
    return IsFrameShown(frame)
  end
  return false
end

local function GetTimelineAnchor()
  local ui = UIParent
  if not ui or not ui.GetCenter then
    return 0, -125, 1
  end

  local uiX, uiY = ui:GetCenter()
  local uiScale =
      (ui.GetEffectiveScale and ui:GetEffectiveScale()) or 1
  if not uiX or not uiY or not uiScale or uiScale <= 0 then
    return 0, -125, 1
  end

  local root = _G["DoiteDPSMainFrame"]
  if not root or not root.GetCenter then
    return 0, -125, 1
  end

  local rootX, rootY = root:GetCenter()
  if not rootX or not rootY then
    return 0, -125, 1
  end

  local rootScale =
      (root.GetEffectiveScale and root:GetEffectiveScale()) or uiScale
  if not rootScale or rootScale <= 0 then
    rootScale = uiScale
  end

  local centerX = ((rootX * rootScale) - (uiX * uiScale)) / uiScale
  local centerY = ((rootY * rootScale) - (uiY * uiScale)) / uiScale
  return centerX, centerY, rootScale / uiScale
end

local function RoundTenth(value)
  if value >= 0 then
    return math.floor(value * 10 + 0.5) / 10
  end
  return math.ceil(value * 10 - 0.5) / 10
end

local function GetClassTag()
  if not UnitClass then
    return ""
  end
  local _, classTag = UnitClass("player")
  return classTag and string.upper(classTag) or ""
end

local function GetMemberEntries(groupName)
  local entries = {}
  local spells = DoiteAurasDB and DoiteAurasDB.spells
  if not spells then
    return entries
  end

  local key, data
  for key, data in pairs(spells) do
    if data and data.group == groupName then
      entries[table.getn(entries) + 1] = {
        key = key,
        data = data,
        active = IsIconActive(key),
      }
    end
  end

  table.sort(entries, function(left, right)
    local leftOrder = tonumber(left.data.order) or 999
    local rightOrder = tonumber(right.data.order) or 999
    if leftOrder == rightOrder then
      return tostring(left.key) < tostring(right.key)
    end
    return leftOrder < rightOrder
  end)
  return entries
end

local function GetEntryName(entry)
  local data = entry and entry.data
  if not data then
    return entry and tostring(entry.key) or ""
  end
  return data.shownName
      or data.displayName
      or data.spellName
      or data.name
      or tostring(entry.key)
end

local function OnLabelEnter()
  local frame = this
  local spec = frame and frame._doiteMonitorLabelSpec
  if not spec or not GameTooltip then
    return
  end

  local color = spec.labelColor or { 0.75, 0.85, 1.00 }
  local anchor = spec.labelSide == "TOP"
      and "ANCHOR_TOP"
      or "ANCHOR_BOTTOM"
  GameTooltip:SetOwner(frame, anchor)
  GameTooltip:AddLine(spec.name, color[1], color[2], color[3])
  GameTooltip:AddLine(
      zh and "包含监控：" or "Monitors:",
      0.72,
      0.72,
      0.72
  )

  local entries = GetMemberEntries(spec.name)
  local index
  for index = 1, table.getn(entries) do
    local entry = entries[index]
    local name = "- " .. GetEntryName(entry)
    if entry.active then
      GameTooltip:AddLine(name, 0.38, 1.00, 0.55)
    else
      GameTooltip:AddLine(name, 0.78, 0.78, 0.78)
    end
  end
  GameTooltip:Show()
end

local function OnLabelLeave()
  if GameTooltip then
    GameTooltip:Hide()
  end
end

local function CreateLabelFrame()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetWidth(44)
  frame:SetHeight(LABEL_HEIGHT)
  frame:SetFrameStrata("MEDIUM")
  if frame.SetFrameLevel then
    frame:SetFrameLevel(20)
  end
  frame:EnableMouse(true)

  local text = frame:CreateFontString(
      nil,
      "OVERLAY",
      "GameFontNormalSmall"
  )
  text:SetPoint("CENTER", frame, "CENTER", 0, 0)
  if text.SetShadowOffset then
    text:SetShadowOffset(1, -1)
  end
  frame.text = text

  frame:SetScript("OnEnter", OnLabelEnter)
  frame:SetScript("OnLeave", OnLabelLeave)
  frame:Hide()
  return frame
end

local function ApplySpec(frame, spec)
  local width = tonumber(spec.labelWidth) or 44

  frame._doiteMonitorLabelSpec = spec
  frame:SetWidth(width)
  frame:SetHeight(LABEL_HEIGHT)
  frame.text:SetText(spec.label or spec.name)
  frame.text:SetTextColor(0.72, 0.82, 0.90, 1)
end

function Labels:Register(classTag, groups)
  classTag = classTag and string.upper(classTag) or ""
  if classTag == "" or not groups then
    return
  end

  self.registry[classTag] = groups
  self.frames[classTag] = self.frames[classTag] or {}
  local classFrames = self.frames[classTag]
  local index

  for index = 1, table.getn(groups) do
    local frame = classFrames[index]
    if not frame then
      frame = CreateLabelFrame()
      classFrames[index] = frame
    end
    ApplySpec(frame, groups[index])
  end

  for index = table.getn(groups) + 1, table.getn(classFrames) do
    classFrames[index]:Hide()
  end
end

local function GetGroupState(groupName)
  local hasMembers = false
  local active = false
  local leader
  local editKey = _G["DoiteEdit_CurrentKey"]
  local spells = DoiteAurasDB and DoiteAurasDB.spells
  if not spells then
    return false, false, nil
  end

  local key, data
  for key, data in pairs(spells) do
    if data and data.group == groupName then
      hasMembers = true
      if data.isLeader == true then
        leader = data
      end
      if key == editKey or IsIconActive(key) then
        active = true
      end
    end
  end
  return hasMembers, active, leader
end

local function HideOtherClasses(currentClass)
  local classTag, classFrames
  for classTag, classFrames in pairs(Labels.frames) do
    if classTag ~= currentClass then
      local index
      for index = 1, table.getn(classFrames) do
        classFrames[index]:Hide()
      end
    end
  end
end

function Labels:Update()
  local classTag = GetClassTag()
  HideOtherClasses(classTag)

  local groups = self.registry[classTag]
  local classFrames = self.frames[classTag]
  if not groups or not classFrames then
    return false
  end

  if DoiteAurasDB and DoiteAurasDB.monitorGroupLabels == false then
    local hiddenIndex
    for hiddenIndex = 1, table.getn(classFrames) do
      classFrames[hiddenIndex]:Hide()
    end
    return false
  end

  local centerX, centerY, relativeScale = GetTimelineAnchor()
  local anyShown = false
  local index

  for index = 1, table.getn(groups) do
    local spec = groups[index]
    local frame = classFrames[index]
    local hasMembers, active, leader = GetGroupState(spec.name)

    if hasMembers and active then
      local direction = spec.labelSide == "TOP" and 1 or -1
      local offset = tonumber(spec.labelOffset) or LABEL_OFFSET
      local leaderX = leader and tonumber(leader.offsetX)
      local leaderY = leader and tonumber(leader.offsetY)
      local labelScale = relativeScale
      local x, y

      if leaderX and leaderY then
        labelScale = tonumber(leader.scale) or 1
        x = RoundTenth(leaderX)
        y = RoundTenth(
            leaderY + direction * offset * labelScale
        )
      else
        x = RoundTenth(centerX + spec.dx * relativeScale)
        y = RoundTenth(
            centerY
                + (spec.dy + direction * offset) * relativeScale
        )
      end

      if frame._doiteX ~= x or frame._doiteY ~= y then
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
        frame._doiteX = x
        frame._doiteY = y
      end
      if frame._doiteScale ~= labelScale then
        frame:SetScale(labelScale)
        frame._doiteScale = labelScale
      end

      frame._doiteActive = true
      frame:SetAlpha(0.92)
      frame:Show()
      anyShown = true
    else
      frame:Hide()
    end
  end
  return anyShown
end

function Labels:GetFrame(classTag, index)
  classTag = classTag and string.upper(classTag) or ""
  local classFrames = self.frames[classTag]
  return classFrames and classFrames[index] or nil
end

_G["DoiteAuras_UpdateMonitorGroupLabels"] = function()
  return Labels:Update()
end

_G["DoiteAuras_SetMonitorGroupLabelsEnabled"] = function(enabled)
  DoiteAurasDB = DoiteAurasDB or {}
  DoiteAurasDB.monitorGroupLabels = enabled and true or false
  Labels:Update()
end

local updater = CreateFrame(
    "Frame",
    "DoiteAurasMonitorGroupLabelUpdater"
)
local elapsed = 0
updater:SetScript("OnUpdate", function()
  elapsed = elapsed + (arg1 or 0)
  if elapsed < UPDATE_INTERVAL then
    return
  end
  elapsed = 0
  Labels:Update()
end)
