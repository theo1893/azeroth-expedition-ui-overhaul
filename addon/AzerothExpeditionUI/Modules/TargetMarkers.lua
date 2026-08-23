AzerothExpeditionUI = AzerothExpeditionUI or {}

local addon = AzerothExpeditionUI
local TargetMarkers = {}

TargetMarkers.runtimeContract = "2.3"
TargetMarkers.cellSize = 48
TargetMarkers.cellGap = 3
TargetMarkers.columns = 4
TargetMarkers.rows = 2
TargetMarkers.emptyIconSize = 30
TargetMarkers.activeIconSize = 15
TargetMarkers.nameFontSize = 10
TargetMarkers.longNameFontSize = 9
TargetMarkers.panelCap = 6
TargetMarkers.panelPadding = 6
TargetMarkers.tankButtonGap = 8
TargetMarkers.bulkButtonGap = 8
TargetMarkers.fallbackGap = 20
TargetMarkers.satelliteGap = 5
TargetMarkers.archiTotemOffset = 34
-- ActionBars moves the bound ArchiTotem 128 UI left. Offset back by the same
-- amount so the marker list keeps its established Combat Deck position while
-- the provider-owned downward totem columns remain beside it.
TargetMarkers.archiTotemHorizontalOffset = 128
TargetMarkers.refreshInterval = 0.50
TargetMarkers.markerKitTexturePath =
  addon.media.root .. "ActionBars\\ActionConsumableKitV1"
TargetMarkers.healthTexturePath =
  "Interface\\TargetingFrame\\UI-StatusBar"
TargetMarkers.raidIconTexturePath =
  "Interface\\TargetingFrame\\UI-RaidTargetingIcons"

-- Kill-priority order, matching the familiar GRTT skull-first 4x2 grid.
local markerOrder = { 8, 7, 6, 5, 4, 3, 2, 1 }

local panelSliceOrder = {
  "topLeft", "top", "topRight",
  "left", "center", "right",
  "bottomLeft", "bottom", "bottomRight",
}

-- Accepted ActionConsumableKitV1 runtime UVs. Cell C is the neutral filled
-- leather nine-slice; cell B is its lighter standalone pocket.
local markerPanelTexCoords = {
  topLeft = { 0.015625, 0.10546875, 0.265625, 0.35546875 },
  top = { 0.10546875, 0.42578125, 0.265625, 0.35546875 },
  topRight = { 0.42578125, 0.515625, 0.265625, 0.35546875 },
  left = { 0.015625, 0.10546875, 0.35546875, 0.67578125 },
  center = { 0.10546875, 0.42578125, 0.35546875, 0.67578125 },
  right = { 0.42578125, 0.515625, 0.35546875, 0.67578125 },
  bottomLeft = { 0.015625, 0.10546875, 0.67578125, 0.765625 },
  bottom = { 0.10546875, 0.42578125, 0.67578125, 0.765625 },
  bottomRight = { 0.42578125, 0.515625, 0.67578125, 0.765625 },
}

local bulkPocketTexCoord = {
  0.265625, 0.484375, 0.017578125, 0.232421875,
}

local markerColors = {
  [1] = { 1.00, 0.90, 0.00 },
  [2] = { 1.00, 0.50, 0.00 },
  [3] = { 0.80, 0.10, 0.90 },
  [4] = { 0.10, 0.85, 0.10 },
  [5] = { 0.72, 0.78, 0.84 },
  [6] = { 0.10, 0.48, 1.00 },
  [7] = { 0.95, 0.12, 0.10 },
  [8] = { 0.92, 0.92, 0.88 },
}

local tankStateColors = {
  ["disabled"] = { 0.62, 0.62, 0.62 },
  ["unassigned"] = { 0.72, 0.72, 0.68 },
  ["unavailable"] = { 0.94, 0.44, 0.32 },
  ["offline"] = { 0.94, 0.44, 0.32 },
  ["dead"] = { 0.94, 0.44, 0.32 },
  ["no_target"] = { 1.00, 0.78, 0.28 },
  ["ready"] = { 0.38, 0.94, 0.48 },
  ["provider_unavailable"] = { 0.94, 0.44, 0.32 },
  ["unknown"] = { 0.82, 0.78, 0.68 },
}

local markerFallbackNames = {
  [1] = "Star",
  [2] = "Circle",
  [3] = "Diamond",
  [4] = "Triangle",
  [5] = "Moon",
  [6] = "Square",
  [7] = "Cross",
  [8] = "Skull",
}

local function GetGlobal(name)
  if type(getglobal) == "function" then
    return getglobal(name)
  end
  if _G then
    return _G[name]
  end
  return nil
end

local function GetSystemFont()
  local systemFont = GetGlobal("STANDARD_TEXT_FONT")
  if type(systemFont) == "string" and systemFont ~= "" then
    return systemFont
  end
  if pfUI and type(pfUI.font_default) == "string" and
    pfUI.font_default ~= ""
  then
    return pfUI.font_default
  end
  return "Fonts\\FRIZQT__.TTF"
end

local function MarkerEnabled()
  local database = addon.db and addon.db.actionbars
  return database and database.enabled and
    database.markersEnabled ~= false
end

local function MarkerName(index)
  local localized = GetGlobal("RAID_TARGET_" .. tostring(index))
  if type(localized) == "string" and localized ~= "" then
    return localized
  end
  return markerFallbackNames[index] or tostring(index)
end

local function MarkerToken(index)
  return "mark" .. tostring(index)
end

local function SafeUnitExists(unit)
  if type(UnitExists) ~= "function" then
    return false
  end
  local ok, exists = pcall(UnitExists, unit)
  return ok and exists and true or false
end

local function SafeUnitGuid(unit)
  if type(UnitExists) ~= "function" then
    return nil
  end
  local ok, exists, guid = pcall(UnitExists, unit)
  if ok and exists and type(guid) == "string" and guid ~= "" then
    return guid
  end
  return nil
end

local function FrameShown(frame)
  if not frame then
    return false
  end
  if frame.IsVisible then
    return frame:IsVisible()
  end
  return frame.IsShown and frame:IsShown()
end

local function FrameBottom(frame)
  if not FrameShown(frame) or not frame.GetBottom then
    return nil
  end
  return frame:GetBottom()
end

local function GetMainActionBar()
  if pfUI and pfUI.bars and pfUI.bars[1] then
    return pfUI.bars[1]
  end
  return GetGlobal("pfActionBarMain")
end

local function BarHasVisibleButtons(barIndex)
  if not pfUI or not pfUI.bars or not pfUI.bars[barIndex] then
    return false
  end
  local bar = pfUI.bars[barIndex]
  for index = 1, 12 do
    local button = bar[index]
    if button and button.IsShown and button:IsShown() then
      return true
    end
  end
  return false
end

local function GetLowerPfUIBar(main)
  local mainBottom = FrameBottom(main)
  if not mainBottom then
    return nil, nil
  end

  local candidates = {
    { frame = GetGlobal("pfActionBarStances"), index = 11,
      status = "stance" },
    { frame = GetGlobal("pfActionBarPet"), index = 12,
      status = "pet" },
  }
  local selected = nil
  local selectedBottom = mainBottom
  local selectedStatus = nil

  for _, candidate in ipairs(candidates) do
    local bottom = FrameBottom(candidate.frame)
    if bottom and bottom < selectedBottom - 2 and
      BarHasVisibleButtons(candidate.index)
    then
      selected = candidate.frame
      selectedBottom = bottom
      selectedStatus = candidate.status
    end
  end
  return selected, selectedStatus
end

local function ArchiTotemVisible()
  local frame = GetGlobal("ArchiTotemFrame")
  local first = GetGlobal("ArchiTotemButton_Earth1")
  if not FrameShown(frame) or not FrameShown(first) then
    return nil
  end
  return frame
end

local function ArchiTotemUsesSeparatedAnchor(frame, main)
  local database = addon.db and addon.db.actionbars
  if not frame or not frame.ClearAllPoints or not frame.SetPoint or
    not main or not database or not database.enabled or
    database.fieldKitBound ~= true
  then
    return false
  end
  local required = {
    "ArchiTotemButton_Fire1",
    "ArchiTotemButton_Water1",
    "ArchiTotemButton_Air1",
    "ArchiTotemDragHandle",
    "ArchiTotemButton_AllTotems",
  }
  for _, name in ipairs(required) do
    if not GetGlobal(name) then
      return false
    end
  end
  return true
end

local function StanceUsesSeparatedAnchor(frame, main, horizontalOffset)
  if not frame or not main or not frame.GetPoint then
    return false
  end
  local point, relative, relativePoint, xOffset = frame:GetPoint(1)
  return point == "TOP" and relative == main and
    relativePoint == "BOTTOM" and
    math.abs((tonumber(xOffset) or 100000) + horizontalOffset) <= 1
end

local function CanManageMarkers()
  local raidCount = type(GetNumRaidMembers) == "function" and
    GetNumRaidMembers() or 0
  if raidCount > 0 then
    local leader = type(IsRaidLeader) == "function" and IsRaidLeader()
    local officer = type(IsRaidOfficer) == "function" and IsRaidOfficer()
    return leader or officer
  end

  local partyCount = type(GetNumPartyMembers) == "function" and
    GetNumPartyMembers() or 0
  if partyCount > 0 and type(IsPartyLeader) == "function" then
    return IsPartyLeader()
  end
  return true
end

local function CountHDLGroup(records, groupId)
  if type(records) ~= "table" or groupId == nil then
    return 0
  end
  local count = 0
  for _, data in pairs(records) do
    if type(data) == "table" and data[2] == groupId then
      count = count + 1
    end
  end
  return count
end

local function SetMarker(unit, index)
  if type(SetRaidTarget) ~= "function" then
    return false
  end
  local ok = pcall(SetRaidTarget, unit, index)
  return ok
end

local function ConfigureMarkerIcon(texture, index)
  -- Vanilla's SetRaidTargetIconTexture only applies atlas coordinates; unlike
  -- later clients it does not guarantee that the Texture has a file assigned.
  texture:SetTexture(TargetMarkers.raidIconTexturePath)
  if type(SetRaidTargetIconTexture) == "function" then
    SetRaidTargetIconTexture(texture, index)
    return
  end

  local popupButton = UnitPopupButtons and
    UnitPopupButtons["RAID_TARGET_" .. tostring(index)]
  if popupButton and popupButton.tCoordLeft and
    popupButton.tCoordRight and popupButton.tCoordTop and
    popupButton.tCoordBottom
  then
    texture:SetTexCoord(
      popupButton.tCoordLeft, popupButton.tCoordRight,
      popupButton.tCoordTop, popupButton.tCoordBottom
    )
    return
  end

  local left = math.mod(index - 1, 4) * 0.25
  local top = math.floor((index - 1) / 4) * 0.5
  texture:SetTexCoord(left, left + 0.25, top, top + 0.5)
end

local function SetCellFont(fontString, size)
  fontString:SetFont(GetSystemFont(), size, "OUTLINE")
  fontString:SetTextColor(1, 1, 1, 1)
  fontString:SetShadowColor(0, 0, 0, 0.9)
  fontString:SetShadowOffset(1, -1)
end

local function Utf8CharacterCount(text)
  if type(text) ~= "string" or text == "" then
    return 0
  end
  local _, count = string.gsub(text, "[^\128-\191]", "")
  return count
end

local function SetAdaptiveCellName(cell, name)
  local characters = Utf8CharacterCount(name)
  local bytes = string.len(name or "")
  local hasMultibyteCharacters = bytes > characters
  local fontSize = TargetMarkers.nameFontSize
  if (hasMultibyteCharacters and characters > 8) or
    (not hasMultibyteCharacters and characters > 14)
  then
    fontSize = TargetMarkers.longNameFontSize
  end
  if cell.nameFontSize ~= fontSize then
    SetCellFont(cell.name, fontSize)
    cell.nameFontSize = fontSize
  end
  cell.name:SetText(name)
end

local function SetMarkerIdentityLayout(cell, active)
  local layout = active and "active-corner" or "empty-center"
  if cell.identityLayout == layout then
    return
  end

  cell.icon:ClearAllPoints()
  cell.iconShadow:ClearAllPoints()
  if active then
    cell.iconShadow:SetWidth(TargetMarkers.activeIconSize + 2)
    cell.iconShadow:SetHeight(TargetMarkers.activeIconSize + 2)
    cell.iconShadow:SetPoint("BOTTOMLEFT", cell, "BOTTOMLEFT", 2, 6)
    cell.iconShadow:SetAlpha(0.72)

    cell.icon:SetWidth(TargetMarkers.activeIconSize)
    cell.icon:SetHeight(TargetMarkers.activeIconSize)
    cell.icon:SetPoint("BOTTOMLEFT", cell, "BOTTOMLEFT", 3, 7)
    cell.icon:SetAlpha(1)
  else
    cell.iconShadow:SetWidth(TargetMarkers.emptyIconSize + 2)
    cell.iconShadow:SetHeight(TargetMarkers.emptyIconSize + 2)
    cell.iconShadow:SetPoint("CENTER", cell, "CENTER", 1, 1)
    cell.iconShadow:SetAlpha(0.52)

    cell.icon:SetWidth(TargetMarkers.emptyIconSize)
    cell.icon:SetHeight(TargetMarkers.emptyIconSize)
    cell.icon:SetPoint("CENTER", cell, "CENTER", 0, 2)
    cell.icon:SetAlpha(0.92)
  end
  cell.identityLayout = layout
end

local function ResetCellDisplay(cell)
  cell:SetAlpha(1)
  SetMarkerIdentityLayout(cell, false)
  cell.name:SetText("")
  cell.healthText:SetText("")
  cell.health:SetValue(0)
  cell.health:Hide()
  cell.healthBackground:Hide()
  cell.selected:Hide()
  cell.active = false
  cell.unitName = nil
  cell.healthValue = nil
  cell.healthMaximum = nil
  return false
end

local function SetTextureCoordinates(texture, texcoord)
  texture:SetTexCoord(
    texcoord[1], texcoord[2], texcoord[3], texcoord[4]
  )
end

local function CreateMarkerPanel(parent, width, height, leftOffset)
  local padding = TargetMarkers.panelPadding
  local cap = TargetMarkers.panelCap
  local panel = CreateFrame("Frame", nil, parent)
  panel:SetPoint(
    "TOPLEFT", parent, "TOPLEFT",
    (leftOffset or 0) - padding, padding
  )
  panel:SetWidth(width + padding * 2)
  panel:SetHeight(height + padding * 2)
  if panel.SetFrameLevel and parent.GetFrameLevel then
    panel:SetFrameLevel(parent:GetFrameLevel())
  end
  panel:EnableMouse(false)
  panel:SetAlpha(0.96)

  local slices = {}
  for _, key in ipairs(panelSliceOrder) do
    local texture = panel:CreateTexture(nil, "BACKGROUND")
    texture:SetTexture(TargetMarkers.markerKitTexturePath)
    SetTextureCoordinates(texture, markerPanelTexCoords[key])
    texture:SetBlendMode("BLEND")
    slices[key] = texture
  end

  slices.topLeft:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
  slices.topLeft:SetWidth(cap)
  slices.topLeft:SetHeight(cap)

  slices.top:SetPoint("TOPLEFT", panel, "TOPLEFT", cap, 0)
  slices.top:SetPoint("BOTTOMRIGHT", panel, "TOPRIGHT", -cap, -cap)

  slices.topRight:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
  slices.topRight:SetWidth(cap)
  slices.topRight:SetHeight(cap)

  slices.left:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -cap)
  slices.left:SetPoint("BOTTOMRIGHT", panel, "BOTTOMLEFT", cap, cap)

  slices.center:SetPoint("TOPLEFT", panel, "TOPLEFT", cap, -cap)
  slices.center:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -cap, cap)

  slices.right:SetPoint("TOPLEFT", panel, "TOPRIGHT", -cap, -cap)
  slices.right:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, cap)

  slices.bottomLeft:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)
  slices.bottomLeft:SetWidth(cap)
  slices.bottomLeft:SetHeight(cap)

  slices.bottom:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", cap, cap)
  slices.bottom:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -cap, 0)

  slices.bottomRight:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
  slices.bottomRight:SetWidth(cap)
  slices.bottomRight:SetHeight(cap)

  panel.slices = slices
  return panel
end

local function CreateBulkPocket(owner)
  local texture = owner:CreateTexture(nil, "BACKGROUND")
  texture:SetWidth(TargetMarkers.cellSize)
  texture:SetHeight(TargetMarkers.cellSize - 1)
  texture:SetPoint("CENTER", owner, "CENTER", 0, 0)
  texture:SetTexture(TargetMarkers.markerKitTexturePath)
  SetTextureCoordinates(texture, bulkPocketTexCoord)
  texture:SetBlendMode("BLEND")
  texture:SetAlpha(0.96)
  return texture
end

function TargetMarkers:CreateCell(parent, position, markerIndex, leftOffset)
  local size = self.cellSize
  local gap = self.cellGap
  local column = math.mod(position - 1, self.columns)
  local row = math.floor((position - 1) / self.columns)

  local cell = CreateFrame(
    "Button",
    "AzerothExpeditionUIMarker" .. tostring(markerIndex),
    parent
  )
  cell:SetWidth(size)
  cell:SetHeight(size)
  cell:SetPoint(
    "TOPLEFT", parent, "TOPLEFT",
    (leftOffset or 0) + column * (size + gap),
    -row * (size + gap)
  )
  cell:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  cell.markerIndex = markerIndex
  cell.unitToken = MarkerToken(markerIndex)
  cell.label = "mark"
  cell.id = markerIndex

  cell.iconShadow = cell:CreateTexture(nil, "ARTWORK")
  ConfigureMarkerIcon(cell.iconShadow, markerIndex)
  cell.iconShadow:SetVertexColor(0.06, 0.025, 0.01, 1)

  cell.icon = cell:CreateTexture(nil, "ARTWORK")
  ConfigureMarkerIcon(cell.icon, markerIndex)
  SetMarkerIdentityLayout(cell, false)

  cell.healthBackground = cell:CreateTexture(nil, "ARTWORK")
  cell.healthBackground:SetPoint("BOTTOMLEFT", cell, "BOTTOMLEFT", 3, 3)
  cell.healthBackground:SetPoint(
    "BOTTOMRIGHT", cell, "BOTTOMRIGHT", -3, 3
  )
  cell.healthBackground:SetHeight(3)
  cell.healthBackground:SetTexture(0.05, 0.025, 0.015, 0.95)

  cell.health = CreateFrame("StatusBar", nil, cell)
  cell.health:SetPoint("BOTTOMLEFT", cell, "BOTTOMLEFT", 3, 3)
  cell.health:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT", -3, 3)
  cell.health:SetHeight(3)
  cell.health:SetMinMaxValues(0, 1)
  cell.health:SetValue(0)
  cell.health:SetStatusBarTexture(self.healthTexturePath)
  local color = markerColors[markerIndex]
  cell.health:SetStatusBarColor(
    color[1] * 0.78, color[2] * 0.78, color[3] * 0.78
  )

  cell.name = cell:CreateFontString(nil, "OVERLAY")
  cell.name:SetPoint("TOPLEFT", cell, "TOPLEFT", 3, -3)
  cell.name:SetPoint("TOPRIGHT", cell, "TOPRIGHT", -3, -3)
  cell.name:SetHeight(22)
  cell.name:SetJustifyH("CENTER")
  cell.name:SetJustifyV("TOP")
  SetCellFont(cell.name, self.nameFontSize)
  cell.nameFontSize = self.nameFontSize

  cell.healthText = cell:CreateFontString(nil, "OVERLAY")
  cell.healthText:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT", -3, 7)
  cell.healthText:SetWidth(26)
  cell.healthText:SetHeight(10)
  cell.healthText:SetJustifyH("RIGHT")
  SetCellFont(cell.healthText, 9)

  cell.selected = cell:CreateTexture(nil, "OVERLAY")
  cell.selected:SetWidth(38)
  cell.selected:SetHeight(38)
  cell.selected:SetPoint("CENTER", cell, "CENTER", 0, 1)
  cell.selected:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
  cell.selected:SetBlendMode("ADD")
  cell.selected:SetVertexColor(color[1], color[2], color[3], 0.9)
  cell.selected:Hide()

  cell.hover = cell:CreateTexture(nil, "HIGHLIGHT")
  cell.hover:SetWidth(38)
  cell.hover:SetHeight(38)
  cell.hover:SetPoint("CENTER", cell, "CENTER", 0, 1)
  cell.hover:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
  cell.hover:SetBlendMode("ADD")
  cell.hover:SetVertexColor(1, 0.82, 0.42, 0.65)

  cell:SetScript("OnClick", function()
    TargetMarkers:HandleCellClick(this, arg1)
  end)
  cell:SetScript("OnEnter", function()
    TargetMarkers:ShowCellTooltip(this)
  end)
  cell:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)

  return cell
end

function TargetMarkers:GetDDPSTankProvider()
  local provider = GetGlobal("DoiteDPS")
  if type(provider) ~= "table" then
    return nil, "ddps-missing"
  end
  if type(provider.SetTankAssistFromUnit) ~= "function" or
    type(provider.ClearTankAssist) ~= "function"
  then
    return nil, "tank-api-missing"
  end
  return provider, "ready"
end

function TargetMarkers:GetDDPSTankStatus(provider)
  if type(provider) ~= "table" or
    type(provider.GetTankAssistStatus) ~= "function"
  then
    return nil, "status-unavailable"
  end
  local ok, status = pcall(provider.GetTankAssistStatus, provider)
  if not ok or type(status) ~= "table" then
    return nil, "status-error"
  end
  return status, status.state or "unknown"
end

function TargetMarkers:GetDDPSTankStatusText(provider, status)
  if type(provider) == "table" and
    type(provider.GetTankAssistStatusText) == "function"
  then
    local ok, text = pcall(
      provider.GetTankAssistStatusText, provider, status
    )
    if ok and type(text) == "string" and text ~= "" then
      return text
    end
  end
  return "DDPS 坦克状态暂时不可读取。"
end

function TargetMarkers:UpdateTankButtonState(provider)
  local button = self.tankButton
  if not button or self.tankButtonStatus ~= "visible" then
    return false
  end

  provider = provider or self:GetDDPSTankProvider()
  local status = nil
  local state = "provider_unavailable"
  if provider then
    status, state = self:GetDDPSTankStatus(provider)
  end
  self.tankState = state
  self.tankName = status and status.name or nil

  local color = tankStateColors[state] or tankStateColors.unknown
  if button.state then
    button.state:SetVertexColor(color[1], color[2], color[3], 0.82)
  end
  if button.label then
    button.label:SetTextColor(color[1], color[2], color[3], 1)
  end
  if state == "disabled" or state == "unassigned" or
    state == "status-unavailable" or state == "status-error"
  then
    if button.icon then button.icon:SetAlpha(0.62) end
    if button.state then button.state:Hide() end
  else
    if button.icon then button.icon:SetAlpha(1) end
    if button.state then button.state:Show() end
  end
  return true
end

function TargetMarkers:UpdateTankButton()
  if not self.tankButton then
    return false
  end
  local provider, status = self:GetDDPSTankProvider()
  self.tankProviderStatus = status
  self.tankButton:Show()
  self.tankButtonStatus = "visible"
  self:UpdateTankButtonState(provider)
  return true
end

function TargetMarkers:InstallTankButtonFallback(button)
  if not button then
    return false
  end
  button:SetWidth(self.cellSize)
  button:SetHeight(self.cellSize)
  button:ClearAllPoints()
  button:SetPoint("LEFT", self.frame, "LEFT", 0, 0)
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

  if not button.base then
    button.base = button:CreateTexture(nil, "BACKGROUND")
    button.base:SetWidth(self.cellSize)
    button.base:SetHeight(self.cellSize - 1)
    button.base:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.base:SetTexture(0.16, 0.055, 0.025, 0.96)
  end
  if not button.icon then
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetWidth(30)
    button.icon:SetHeight(30)
    button.icon:SetPoint("CENTER", button, "CENTER", 0, 1)
    button.icon:SetTexture("Interface\\Icons\\INV_Shield_06")
  end
  if not button.label then
    button.label = button:CreateFontString(nil, "OVERLAY")
    button.label:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 5)
    button.label:SetWidth(10)
    button.label:SetHeight(10)
    button.label:SetText("T")
    SetCellFont(button.label, 9)
  end

  button:SetScript("OnClick", function()
    TargetMarkers:HandleTankClick(arg1)
  end)
  button:SetScript("OnEnter", function()
    TargetMarkers:ShowTankTooltip(this)
  end)
  button:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)
  button:Show()
  return true
end

function TargetMarkers:KeepTankButtonVisible(errorText)
  self.tankButtonError = tostring(errorText or "unknown")
  self.tankState = "unknown"
  if self.tankButton then
    pcall(self.InstallTankButtonFallback, self, self.tankButton)
    self.tankButton:Show()
    self.tankButtonStatus = "visible"
  else
    self.tankButtonStatus = "error"
  end
  if not self.tankButtonErrorReported then
    addon:Print(
      "DDPS 坦克按钮已切换为基础可见模式。"
    )
    self.tankButtonErrorReported = true
  end
  return self.tankButton ~= nil
end

function TargetMarkers:CreateTankButtonSafely(parent)
  local ok, button = pcall(self.CreateTankButton, self, parent)
  if not ok then
    self:KeepTankButtonVisible(button)
    return self.tankButton
  end

  local updateOk, updateError = pcall(self.UpdateTankButton, self)
  if not updateOk then
    self:KeepTankButtonVisible(updateError)
  end
  return button
end

function TargetMarkers:UpdateTankButtonSafely()
  if not self.tankButton then
    return false
  end
  local ok, result = pcall(self.UpdateTankButton, self)
  if not ok then
    return self:KeepTankButtonVisible(result)
  end
  return result
end

function TargetMarkers:ShowTankTooltip(button)
  if not button or not GameTooltip then
    return
  end
  GameTooltip:SetOwner(button, "ANCHOR_TOP")
  GameTooltip:SetText("DDPS 协助坦克")

  local provider, providerStatus = self:GetDDPSTankProvider()
  if provider then
    local status = self:GetDDPSTankStatus(provider)
    GameTooltip:AddLine(
      self:GetDDPSTankStatusText(provider, status),
      0.88, 0.90, 0.96
    )
  else
    GameTooltip:AddLine(
      providerStatus == "tank-api-missing" and
        "当前 DDPS 版本没有坦克协助接口。" or "DDPS 未加载。",
      0.94, 0.44, 0.32
    )
  end
  GameTooltip:AddLine(
    "左键：将当前队伍／团队玩家设为坦克",
    0.92, 0.86, 0.72
  )
  GameTooltip:AddLine("右键：清除已指定坦克", 0.92, 0.86, 0.72)
  GameTooltip:AddLine(
    "仅在按下 DDPS 输出键时跟随；手动敌对目标优先。",
    0.66, 0.72, 0.82
  )
  GameTooltip:Show()
end

function TargetMarkers:RefreshDDPSTankProvider(provider)
  if type(provider) ~= "table" then
    return
  end
  if type(provider.Update) == "function" then
    pcall(provider.Update, provider, true)
  end
  local config = provider.Config
  if type(config) == "table" and type(config.Refresh) == "function" then
    pcall(config.Refresh, config)
  end
end

function TargetMarkers:GetTankAssignmentError(provider, reason)
  if type(provider) == "table" and
    type(provider.GetTankAssistAssignmentError) == "function"
  then
    local ok, message = pcall(
      provider.GetTankAssistAssignmentError, provider, reason
    )
    if ok and type(message) == "string" and message ~= "" then
      return message
    end
  end
  return "请先选中队伍或团队中的坦克。"
end

function TargetMarkers:HandleTankClick(mouseButton)
  if not MarkerEnabled() then
    return
  end
  local provider = self:GetDDPSTankProvider()
  if not provider then
    addon:Print("DDPS 坦克协助接口不可用。")
    return
  end

  if mouseButton == "RightButton" then
    local callOk, cleared = pcall(provider.ClearTankAssist, provider)
    if not callOk or not cleared then
      addon:Print("DDPS 协助坦克清除失败。")
      return
    end
    self.lastTankStatus = "cleared"
    addon:Print("已清除 DDPS 协助坦克。")
  else
    local callOk, assigned, nameOrReason = pcall(
      provider.SetTankAssistFromUnit, provider, "target"
    )
    if not callOk then
      self.lastTankStatus = "provider-error"
      addon:Print("DDPS 协助坦克指定失败。")
      return
    end
    if not assigned then
      self.lastTankStatus = tostring(nameOrReason or "invalid-target")
      addon:Print(self:GetTankAssignmentError(provider, nameOrReason))
      return
    end
    self.lastTankStatus = "assigned"
    addon:Print("已指定 DDPS 协助坦克：" .. tostring(nameOrReason))
  end

  self:RefreshDDPSTankProvider(provider)
  self:UpdateTankButtonState(provider)
end

function TargetMarkers:CreateTankButton(parent)
  if self.tankButton then
    return self.tankButton
  end

  local button = CreateFrame(
    "Button", "AzerothExpeditionUIDDPSTankButton", parent
  )
  self.tankButton = button
  button:SetWidth(self.cellSize)
  button:SetHeight(self.cellSize)
  button:SetPoint("LEFT", parent, "LEFT", 0, 0)
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

  button.base = CreateBulkPocket(button)

  button.icon = button:CreateTexture(nil, "ARTWORK")
  button.icon:SetWidth(30)
  button.icon:SetHeight(30)
  button.icon:SetPoint("CENTER", button, "CENTER", 0, 1)
  button.icon:SetTexture("Interface\\Icons\\INV_Shield_06")
  button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

  button.state = button:CreateTexture(nil, "OVERLAY")
  button.state:SetWidth(38)
  button.state:SetHeight(38)
  button.state:SetPoint("CENTER", button, "CENTER", 0, 1)
  button.state:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
  button.state:SetBlendMode("ADD")
  button.state:Hide()

  button.label = button:CreateFontString(nil, "OVERLAY")
  button.label:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 5)
  button.label:SetWidth(10)
  button.label:SetHeight(10)
  button.label:SetJustifyH("RIGHT")
  button.label:SetText("T")
  SetCellFont(button.label, 9)

  button.hover = button:CreateTexture(nil, "HIGHLIGHT")
  button.hover:SetWidth(38)
  button.hover:SetHeight(38)
  button.hover:SetPoint("CENTER", button, "CENTER", 0, 1)
  button.hover:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
  button.hover:SetBlendMode("ADD")
  button.hover:SetVertexColor(1, 0.82, 0.42, 0.65)

  button:SetScript("OnClick", function()
    TargetMarkers:HandleTankClick(arg1)
  end)
  button:SetScript("OnEnter", function()
    TargetMarkers:ShowTankTooltip(this)
  end)
  button:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)
  -- The entry itself is never provider-conditional. Provider or cosmetic
  -- failures are represented by its state and tooltip, not by hiding it.
  button:Show()

  return button
end

function TargetMarkers:GetHDLBulkProvider()
  if not GetGlobal("SUPERWOW_VERSION") then
    return nil, "superwow-missing"
  end

  local provider = GetGlobal("HDLUI")
  if type(provider) ~= "table" then
    return nil, "hdl-missing"
  end
  if type(provider.SJQKAmark) ~= "function" or
    type(provider.markToUid) ~= "table"
  then
    return nil, "hdl-bulk-missing"
  end
  return provider, "ready"
end

function TargetMarkers:GetHDLBulkTargetContext()
  local provider, providerStatus = self:GetHDLBulkProvider()
  if not provider then
    return nil, providerStatus
  end
  if not SafeUnitExists("target") then
    return nil, "target-missing"
  end

  local guid = SafeUnitGuid("target")
  if not guid then
    return nil, "target-guid-missing"
  end
  local data = provider.markToUid[guid]
  if type(data) ~= "table" or data[2] == nil then
    return nil, "target-unregistered"
  end

  return {
    provider = provider,
    guid = guid,
    data = data,
    groupId = data[2],
    groupCount = CountHDLGroup(provider.markToUid, data[2]),
  }, "ready"
end

function TargetMarkers:BulkStatusMessage(status)
  local messages = {
    ["superwow-missing"] = "需要 SuperWoW 才能按原始 GUID 标记怪群。",
    ["hdl-missing"] = "HDLRaidTools 未加载。",
    ["hdl-bulk-missing"] = "HDLRaidTools 一键标记 provider 不可用。",
    ["target-missing"] = "请先选中怪群中的一个目标。",
    ["target-guid-missing"] = "当前目标没有可用的 SuperWoW GUID。",
    ["target-unregistered"] = "当前目标不在 HDLRaidTools 登记的怪群表中。",
    ["target-marked"] = "当前目标已有团队标记；请选择该组中未标记的目标。",
    ["permission-missing"] = "需要队长、团长或团队助理的标记权限。",
  }
  return messages[status] or "一键怪群标记当前不可用。"
end

function TargetMarkers:UpdateBulkButton()
  if not self.bulkButton then
    return false
  end
  local provider, status = self:GetHDLBulkProvider()
  self.bulkProviderStatus = status
  if provider then
    if self.frame and self.bulkGridWidth then
      self.frame:SetWidth(self.bulkGridWidth)
    end
    self.bulkButton:SetAlpha(1)
    self.bulkButton.title:SetTextColor(1, 0.82, 0.42, 1)
    self.bulkButton.subtitle:SetTextColor(0.92, 0.86, 0.72, 1)
    self.bulkButton:Show()
    self.bulkButtonStatus = "visible"
  else
    self.bulkButton:Hide()
    if self.frame and self.baseGridWidth then
      self.frame:SetWidth(self.baseGridWidth)
    end
    self.bulkButtonStatus = "provider-hidden"
  end
  return true
end

function TargetMarkers:DisableBrokenBulkButton(errorText)
  self.bulkButtonStatus = "error"
  self.bulkButtonError = tostring(errorText or "unknown")
  if self.bulkButton and self.bulkButton.Hide then
    self.bulkButton:Hide()
  end
  if self.frame and self.baseGridWidth then
    self.frame:SetWidth(self.baseGridWidth)
  end
  if not self.bulkButtonErrorReported then
    addon:Print(
      "一键标记按钮加载失败；基础 4x2 标记栏仍保持可用。"
    )
    self.bulkButtonErrorReported = true
  end
end

function TargetMarkers:CreateBulkButtonSafely(parent)
  local ok, button = pcall(self.CreateBulkButton, self, parent)
  if not ok then
    self:DisableBrokenBulkButton(button)
    return nil
  end

  local updateOk, updateError = pcall(self.UpdateBulkButton, self)
  if not updateOk then
    self:DisableBrokenBulkButton(updateError)
    return nil
  end
  return button
end

function TargetMarkers:UpdateBulkButtonSafely()
  if not self.bulkButton or self.bulkButtonStatus == "error" then
    return false
  end
  local ok, result = pcall(self.UpdateBulkButton, self)
  if not ok then
    self:DisableBrokenBulkButton(result)
    return false
  end
  return result
end

function TargetMarkers:ShowBulkTooltip(button)
  if not button or not GameTooltip then
    return
  end
  GameTooltip:SetOwner(button, "ANCHOR_TOP")
  GameTooltip:SetText("HDL 一键怪群标记")
  GameTooltip:AddLine(
    "选中已登记怪群中的任意未标记目标，然后点击。",
    0.92, 0.86, 0.72
  )
  GameTooltip:AddLine(
    "按 HDLRaidTools 预设顺序一次分配骷髅至星标。",
    0.82, 0.78, 0.68
  )

  local context, status = self:GetHDLBulkTargetContext()
  if context then
    GameTooltip:AddLine(
      "当前怪群：" .. tostring(context.groupId) ..
      "（登记 " .. tostring(context.groupCount) .. " 个目标）",
      0.42, 0.92, 0.52
    )
  else
    GameTooltip:AddLine(self:BulkStatusMessage(status), 0.92, 0.48, 0.34)
  end
  GameTooltip:AddLine(
    "需要 HDLRaidTools、SuperWoW 和团队标记权限。",
    0.66, 0.62, 0.56
  )
  GameTooltip:Show()
end

function TargetMarkers:HandleBulkClick()
  if not MarkerEnabled() then
    return
  end
  if not CanManageMarkers() then
    self.lastBulkStatus = "permission-missing"
    addon:Print(self:BulkStatusMessage(self.lastBulkStatus))
    return
  end

  local context, status = self:GetHDLBulkTargetContext()
  if not context then
    self.lastBulkStatus = status
    addon:Print(self:BulkStatusMessage(status))
    return
  end

  local currentMarker = type(GetRaidTargetIndex) == "function" and
    GetRaidTargetIndex("target") or nil
  if currentMarker then
    self.lastBulkStatus = "target-marked"
    addon:Print(self:BulkStatusMessage(self.lastBulkStatus))
    return
  end

  local ok, result = pcall(context.provider.SJQKAmark)
  if type(TargetUnit) == "function" then
    pcall(TargetUnit, context.guid)
  end
  if not ok then
    self.lastBulkStatus = "provider-error"
    addon:Print("HDLRaidTools 一键标记失败：" .. tostring(result))
    return
  end

  self.lastBulkStatus = "triggered"
  self.lastBulkGroup = context.groupId
  self.lastBulkCount = context.groupCount
  addon:Print(
    "已触发怪群 " .. tostring(context.groupId) ..
    " 的一键标记（登记 " .. tostring(context.groupCount) .. " 个目标）。"
  )
  self:UpdateCells()
end

function TargetMarkers:CreateBulkButton(parent)
  if self.bulkButton then
    return self.bulkButton
  end

  local button = CreateFrame(
    "Button", "AzerothExpeditionUIMarkerBulkButton", parent
  )
  -- Register the optional child immediately. If a later cosmetic call is not
  -- supported by a specific Vanilla client, CreateGrid can still recover and
  -- show the already-complete manual marker grid without recreating names.
  self.bulkButton = button
  button:SetWidth(self.cellSize)
  button:SetHeight(self.cellSize)
  button:SetPoint(
    "LEFT", parent, "LEFT",
    self.tankControlSpan + self.manualGridWidth + self.bulkButtonGap, 0
  )
  button:RegisterForClicks("LeftButtonUp")

  button.base = CreateBulkPocket(button)

  button.title = button:CreateFontString(nil, "OVERLAY")
  button.title:SetPoint("CENTER", button, "CENTER", 0, 7)
  button.title:SetWidth(self.cellSize - 8)
  button.title:SetHeight(12)
  button.title:SetJustifyH("CENTER")
  button.title:SetText("一键")
  SetCellFont(button.title, 11)

  button.subtitle = button:CreateFontString(nil, "OVERLAY")
  button.subtitle:SetPoint("CENTER", button, "CENTER", 0, -8)
  button.subtitle:SetWidth(self.cellSize - 8)
  button.subtitle:SetHeight(11)
  button.subtitle:SetJustifyH("CENTER")
  button.subtitle:SetText("标记")
  SetCellFont(button.subtitle, 10)

  button.hover = button:CreateTexture(nil, "HIGHLIGHT")
  button.hover:SetWidth(36)
  button.hover:SetHeight(36)
  button.hover:SetPoint("CENTER", button, "CENTER", 0, 0)
  button.hover:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
  button.hover:SetBlendMode("ADD")
  button.hover:SetVertexColor(1, 0.82, 0.42, 0.65)

  button:SetScript("OnClick", function()
    TargetMarkers:HandleBulkClick()
  end)
  button:SetScript("OnEnter", function()
    TargetMarkers:ShowBulkTooltip(this)
  end)
  button:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)
  -- Hidden until UpdateBulkButton verifies the complete external provider.
  button:Hide()

  return button
end

function TargetMarkers:CreateGrid()
  if self.frame then
    return self.frame
  end

  local manualGridWidth = self.columns * self.cellSize +
    (self.columns - 1) * self.cellGap
  local tankControlSpan = self.cellSize + self.tankButtonGap
  local baseGridWidth = tankControlSpan + manualGridWidth
  local bulkGridWidth = baseGridWidth + self.bulkButtonGap + self.cellSize
  local height = self.rows * self.cellSize +
    (self.rows - 1) * self.cellGap
  self.manualGridWidth = manualGridWidth
  self.tankControlSpan = tankControlSpan
  self.baseGridWidth = baseGridWidth
  self.bulkGridWidth = bulkGridWidth
  local frame = CreateFrame(
    "Frame", "AzerothExpeditionUIMarkerGrid", UIParent
  )
  -- The 4x2 grid is the core feature. Own it before constructing any optional
  -- provider controls so a provider/UI error can never strand it hidden.
  self.frame = frame
  frame:SetWidth(baseGridWidth)
  frame:SetHeight(height)
  -- Keep the marker Buttons below ArchiTotem's provider strata as a defensive
  -- fallback for unusual provider scales, even though the bound layout now
  -- separates the downward totem columns from the marker list horizontally.
  frame:SetFrameStrata("BACKGROUND")
  frame:EnableMouse(false)
  frame:Hide()

  self.panel = CreateMarkerPanel(
    frame, manualGridWidth, height, tankControlSpan
  )

  self.cells = {}
  for position, markerIndex in ipairs(markerOrder) do
    self.cells[markerIndex] =
      self:CreateCell(frame, position, markerIndex, tankControlSpan)
  end
  self:CreateTankButtonSafely(frame)
  self:CreateBulkButtonSafely(frame)
  return frame
end

function TargetMarkers:ApplyAnchor()
  local frame = self:CreateGrid()
  local main = GetMainActionBar()
  local horizontalOffset = 0
  self.tankAnchorOffset = 0
  frame:ClearAllPoints()

  local archiTotem = ArchiTotemVisible()
  if archiTotem then
    local separated = ArchiTotemUsesSeparatedAnchor(archiTotem, main)
    local archiHorizontalOffset = separated and
      self.archiTotemHorizontalOffset or 0
    -- ArchiTotem's 80 UI root is taller than its closed 40 UI button row.
    -- Anchor from its centre so the marker grid follows the real visible row
    -- without inheriting the root's unused lower half.
    frame:SetPoint(
      "TOP", archiTotem, "CENTER",
      archiHorizontalOffset, -self.archiTotemOffset
    )
    self.anchorStatus = separated and
      "architotem-separated-row" or "architotem-row"
    return true
  end

  if main then
    local lowerBar, lowerStatus = GetLowerPfUIBar(main)
    if lowerBar then
      local separated = lowerStatus == "stance" and
        StanceUsesSeparatedAnchor(
          lowerBar, main, self.archiTotemHorizontalOffset
        )
      local lowerHorizontalOffset = separated and
        self.archiTotemHorizontalOffset or horizontalOffset
      frame:SetPoint(
        "TOP", lowerBar, "BOTTOM", lowerHorizontalOffset,
        -self.satelliteGap
      )
      self.anchorStatus = separated and "stance-separated-row" or
        lowerStatus .. "-row"
    else
      -- No class satellite exists: consume the same reserved row directly
      -- below the main action deck instead of leaving an empty gap.
      frame:SetPoint(
        "TOP", main, "BOTTOM", horizontalOffset, -self.fallbackGap
      )
      self.anchorStatus = "reserved-special-row"
    end
    return true
  end

  frame:SetPoint("BOTTOM", UIParent, "BOTTOM", horizontalOffset, 22)
  self.anchorStatus = "ui-parent-fallback"
  return false
end

function TargetMarkers:UpdateCell(cell)
  if not cell then
    return false
  end

  local token = cell.unitToken
  local active = SafeUnitExists(token)
  local color = markerColors[cell.markerIndex]
  if not active then
    return ResetCellDisplay(cell)
  end

  local name = UnitName(token) or MarkerName(cell.markerIndex)
  local health = tonumber(UnitHealth(token)) or 0
  local maximum = tonumber(UnitHealthMax(token)) or 0
  local percent = 0
  if maximum > 0 then
    percent = math.max(0, math.min(1, health / maximum))
  end

  -- Death only clears AEUI's local cell. The real raid marker remains owned by
  -- the client/provider and can still be cleared explicitly with Shift+RightClick.
  if type(UnitIsDead) == "function" and UnitIsDead(token) then
    return ResetCellDisplay(cell)
  end

  cell:SetAlpha(1)
  SetMarkerIdentityLayout(cell, true)
  SetAdaptiveCellName(cell, name)
  cell.health:SetValue(percent)
  cell.health:Show()
  cell.healthBackground:Show()
  cell.healthText:SetText(math.floor(percent * 100 + 0.5) .. "%")
  cell.name:SetTextColor(1, 1, 1, 1)

  local selected = type(UnitIsUnit) == "function" and
    SafeUnitExists("target") and UnitIsUnit("target", token)
  if selected then
    cell.selected:Show()
  else
    cell.selected:Hide()
  end
  cell.health:SetStatusBarColor(
    color[1] * 0.78, color[2] * 0.78, color[3] * 0.78
  )
  cell.active = true
  cell.unitName = name
  cell.healthValue = health
  cell.healthMaximum = maximum
  return true
end

function TargetMarkers:UpdateCells()
  if not self.frame or not MarkerEnabled() then
    return
  end

  local active = 0
  for _, markerIndex in ipairs(markerOrder) do
    if self:UpdateCell(self.cells[markerIndex]) then
      active = active + 1
    end
  end
  self.activeMarkers = active
  self.tokenStatus = type(UnitExists) == "function" and
    "mark1-8" or "missing"
  self:UpdateTankButtonState()
end

function TargetMarkers:ShowCellTooltip(cell)
  if not cell or not GameTooltip then
    return
  end
  GameTooltip:SetOwner(cell, "ANCHOR_TOP")
  local title = MarkerName(cell.markerIndex)
  if cell.active and cell.unitName then
    title = title .. " - " .. cell.unitName
  else
    title = title .. " - 未使用"
  end
  GameTooltip:SetText(title)
  if cell.active and cell.healthMaximum and cell.healthMaximum > 0 then
    GameTooltip:AddLine(
      tostring(cell.healthValue) .. " / " ..
      tostring(cell.healthMaximum), 0.82, 0.78, 0.68
    )
  end
  GameTooltip:AddLine("左键：选中已标记目标", 0.92, 0.86, 0.72)
  GameTooltip:AddLine(
    "右键：把当前目标设为此标记；再次右键取消",
    0.92, 0.86, 0.72
  )
  GameTooltip:AddLine(
    "Shift + 右键：清除此标记", 0.74, 0.68, 0.58
  )
  GameTooltip:Show()
end

function TargetMarkers:HandleCellClick(cell, mouseButton)
  if not cell or not MarkerEnabled() then
    return
  end

  if mouseButton == "LeftButton" then
    if SafeUnitExists(cell.unitToken) and type(TargetUnit) == "function" then
      TargetUnit(cell.unitToken)
      self:UpdateCells()
    else
      addon:Print(MarkerName(cell.markerIndex) .. " currently has no target.")
    end
    return
  end

  if mouseButton ~= "RightButton" then
    return
  end
  if not CanManageMarkers() then
    addon:Print("raid markers require party leader or raid leader/assist.")
    return
  end

  if IsShiftKeyDown() then
    if SafeUnitExists(cell.unitToken) then
      if not SetMarker(cell.unitToken, 0) then
        addon:Print("unable to clear " .. MarkerName(cell.markerIndex) .. ".")
      end
    end
    self:UpdateCells()
    return
  end

  if not SafeUnitExists("target") then
    addon:Print("select a target before assigning " ..
      MarkerName(cell.markerIndex) .. ".")
    return
  end

  local current = type(GetRaidTargetIndex) == "function" and
    GetRaidTargetIndex("target") or nil
  local nextIndex = current == cell.markerIndex and 0 or cell.markerIndex
  if not SetMarker("target", nextIndex) then
    addon:Print("unable to change raid marker.")
  end
  self:UpdateCells()
end

function TargetMarkers:SetEnabled(enabled)
  local database = addon.db and addon.db.actionbars
  if not database then
    return false, "ActionBars database is unavailable."
  end
  database.markersEnabled = enabled and true or false
  self:Apply()
  return true, "marker grid " .. (enabled and "enabled" or "disabled") .. "."
end

function TargetMarkers:InstallEvents()
  if self.eventFrame then
    return
  end
  local frame = CreateFrame(
    "Frame", "AzerothExpeditionUIMarkerEventFrame", UIParent
  )
  frame:RegisterEvent("ADDON_LOADED")
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("PLAYER_TARGET_CHANGED")
  frame:RegisterEvent("RAID_TARGET_UPDATE")
  frame:RegisterEvent("UNIT_HEALTH")
  frame:RegisterEvent("UNIT_MAXHEALTH")
  frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
  frame:RegisterEvent("RAID_ROSTER_UPDATE")
  frame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
  frame:RegisterEvent("PET_BAR_UPDATE")
  frame:RegisterEvent("UNIT_PET")
  frame:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" or event == "ADDON_LOADED" or
      event == "UPDATE_SHAPESHIFT_FORMS" or event == "PET_BAR_UPDATE" or
      event == "UNIT_PET"
    then
      TargetMarkers:Apply()
    else
      TargetMarkers:UpdateCells()
    end
  end)
  frame:SetScript("OnUpdate", function()
    if not MarkerEnabled() or not TargetMarkers.frame or
      not TargetMarkers.frame:IsShown()
    then
      return
    end
    TargetMarkers.elapsed = (TargetMarkers.elapsed or 0) + arg1
    if TargetMarkers.elapsed < TargetMarkers.refreshInterval then
      return
    end
    TargetMarkers.elapsed = 0
    -- Data-only fallback for marked units entering range without an event.
    -- Geometry is never maintained from this polling path.
    TargetMarkers:UpdateCells()
  end)
  self.eventFrame = frame
end

function TargetMarkers:Initialize()
  self.anchorStatus = "pending"
  self.tokenStatus = "pending"
  self.activeMarkers = 0
  self.lastTankStatus = "idle"
  self.tankButtonStatus = "pending"
  self.tankProviderStatus = "pending"
  self.tankState = "pending"
  self.tankName = nil
  self.tankAnchorOffset = 0
  self.tankButtonError = nil
  self.tankButtonErrorReported = false
  self.lastBulkStatus = "idle"
  self.bulkButtonStatus = "pending"
  self.bulkProviderStatus = "pending"
  self.bulkButtonError = nil
  self.bulkButtonErrorReported = false
  self.elapsed = 0
  self:CreateGrid()
  self:InstallEvents()
end

function TargetMarkers:Apply()
  local frame = self:CreateGrid()
  if not MarkerEnabled() then
    frame:Hide()
    self.anchorStatus = "disabled"
    self.activeMarkers = 0
    return
  end
  self:UpdateTankButtonSafely()
  self:ApplyAnchor()
  frame:Show()
  self:UpdateBulkButtonSafely()
  self:UpdateCells()
end

function TargetMarkers:GetRuntimeStatus()
  return
    "contract=" .. tostring(self.runtimeContract) ..
    ",enabled=" .. tostring(MarkerEnabled() and "yes" or "no") ..
    ",layout=4x2-square" ..
    ",style=shared-leather-board" ..
    ",order=skull-first" ..
    ",active=" .. tostring(self.activeMarkers or 0) ..
    ",tokens=" .. tostring(self.tokenStatus or "pending") ..
    ",anchor=" .. tostring(self.anchorStatus or "pending") ..
    ",strata=BACKGROUND" ..
    ",identity=empty-center+active-bottom-left" ..
    ",text=top-two-line-adaptive" ..
    ",dead=local-clear-only" ..
    ",input=left-target+right-mark+shift-right-clear" ..
    ",tank=ddps-assist" ..
    ",tank-layout=fixed-in-frame-left" ..
    ",tank-input=left-assign+right-clear" ..
    ",tank-ui=" .. tostring(self.tankButtonStatus or "pending") ..
    ",tank-provider=" .. tostring(self.tankProviderStatus or "pending") ..
    ",tank-state=" .. tostring(self.tankState or "pending") ..
    ",tank-last=" .. tostring(self.lastTankStatus or "idle") ..
    ",tank-offset=" .. tostring(self.tankAnchorOffset or 0) ..
    ",tank-error=" .. tostring(self.tankButtonError or "none") ..
    ",bulk=hdl-one-click" ..
    ",bulk-layout=conditional-in-frame-right" ..
    ",bulk-ui=" .. tostring(self.bulkButtonStatus or "pending") ..
    ",bulk-provider=" .. tostring(self.bulkProviderStatus or "pending") ..
    ",bulk-last=" .. tostring(self.lastBulkStatus or "idle") ..
    ",bulk-error=" .. tostring(self.bulkButtonError or "none")
end

addon:RegisterModule("TargetMarkers", TargetMarkers)
