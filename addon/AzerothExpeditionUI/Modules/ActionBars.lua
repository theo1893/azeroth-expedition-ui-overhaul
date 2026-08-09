AzerothExpeditionUI = AzerothExpeditionUI or {}

local addon = AzerothExpeditionUI
local ActionBars = {}

ActionBars.runtimeContract = "1.0"
ActionBars.texturePath = addon.media.root .. "ActionBars\\ActionSlotBaseV1"
ActionBars.firstBar = 1
ActionBars.lastBar = 10
ActionBars.buttonsPerBar = 12
ActionBars.railRuntimeContract = "1.0"
ActionBars.railTexturePath = addon.media.root .. "ActionBars\\ActionRailV1"
ActionBars.firstRailBar = 1
ActionBars.lastRailBar = 12
ActionBars.railCap = 6

local railSliceOrder = {
  "topLeft", "top", "topRight",
  "left", "center", "right",
  "bottomLeft", "bottom", "bottomRight",
}

local railTexCoords = {
  topLeft = { 0.15625, 0.28125, 0.15625, 0.28125 },
  top = { 0.28125, 0.71875, 0.15625, 0.28125 },
  topRight = { 0.71875, 0.84375, 0.15625, 0.28125 },
  left = { 0.15625, 0.28125, 0.28125, 0.71875 },
  center = { 0.28125, 0.71875, 0.28125, 0.71875 },
  right = { 0.71875, 0.84375, 0.28125, 0.71875 },
  bottomLeft = { 0.15625, 0.28125, 0.71875, 0.84375 },
  bottom = { 0.28125, 0.71875, 0.71875, 0.84375 },
  bottomRight = { 0.71875, 0.84375, 0.71875, 0.84375 },
}

local function GetButton(barIndex, buttonIndex)
  if not pfUI or not pfUI.bars or not pfUI.bars[barIndex] then
    return nil
  end
  return pfUI.bars[barIndex][buttonIndex]
end

local function SetTextureEnabled(texture, enabled)
  if enabled then
    texture:Show()
  else
    texture:Hide()
  end
end

local function ConfigureRailAnchors(backdrop, rail)
  local cap = ActionBars.railCap

  rail.topLeft:SetPoint("TOPLEFT", backdrop, "TOPLEFT", 0, 0)
  rail.topLeft:SetWidth(cap)
  rail.topLeft:SetHeight(cap)

  rail.top:SetPoint("TOPLEFT", backdrop, "TOPLEFT", cap, 0)
  rail.top:SetPoint("BOTTOMRIGHT", backdrop, "TOPRIGHT", -cap, -cap)

  rail.topRight:SetPoint("TOPRIGHT", backdrop, "TOPRIGHT", 0, 0)
  rail.topRight:SetWidth(cap)
  rail.topRight:SetHeight(cap)

  rail.left:SetPoint("TOPLEFT", backdrop, "TOPLEFT", 0, -cap)
  rail.left:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMLEFT", cap, cap)

  rail.center:SetPoint("TOPLEFT", backdrop, "TOPLEFT", cap, -cap)
  rail.center:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -cap, cap)

  rail.right:SetPoint("TOPLEFT", backdrop, "TOPRIGHT", -cap, -cap)
  rail.right:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", 0, cap)

  rail.bottomLeft:SetPoint("BOTTOMLEFT", backdrop, "BOTTOMLEFT", 0, 0)
  rail.bottomLeft:SetWidth(cap)
  rail.bottomLeft:SetHeight(cap)

  rail.bottom:SetPoint("TOPLEFT", backdrop, "BOTTOMLEFT", cap, cap)
  rail.bottom:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -cap, 0)

  rail.bottomRight:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", 0, 0)
  rail.bottomRight:SetWidth(cap)
  rail.bottomRight:SetHeight(cap)
end

local function ApplyRailBackdrop(backdrop, enabled)
  if not backdrop then
    return false
  end

  local rail = backdrop.aeuiActionRailV1
  if not rail then
    rail = {}
    for _, key in ipairs(railSliceOrder) do
      local texture = backdrop:CreateTexture(nil, "OVERLAY")
      local texcoord = railTexCoords[key]
      texture:SetTexture(ActionBars.railTexturePath)
      texture:SetTexCoord(
        texcoord[1], texcoord[2], texcoord[3], texcoord[4]
      )
      texture:SetBlendMode("BLEND")
      texture:SetVertexColor(1, 1, 1, 1)
      rail[key] = texture
    end
    ConfigureRailAnchors(backdrop, rail)
    backdrop.aeuiActionRailV1 = rail
  end

  for _, key in ipairs(railSliceOrder) do
    SetTextureEnabled(rail[key], enabled)
  end
  return true
end

local function ApplyButton(button, enabled)
  if not button or not button.backdrop then
    return false
  end

  local backdrop = button.backdrop
  local texture = backdrop.aeuiActionSlotBaseV1
  if not texture then
    texture = backdrop:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints(backdrop)
    texture:SetTexture(ActionBars.texturePath)
    texture:SetTexCoord(0, 1, 0, 1)
    texture:SetBlendMode("BLEND")
    texture:SetVertexColor(1, 1, 1, 1)
    backdrop.aeuiActionSlotBaseV1 = texture
  end

  SetTextureEnabled(texture, enabled)
  return true
end

function ActionBars:Initialize()
  self.providerStatus = "pending"
  self.appliedBars = 0
  self.appliedButtons = 0
  self.appliedRails = 0
  self.appliedMergedRail = false
end

function ActionBars:Apply()
  local enabled = addon.db and addon.db.actionbars and
    addon.db.actionbars.enabled
  local providerAvailable = pfUI and pfUI.bars
  local appliedBars = 0
  local appliedButtons = 0
  local appliedRails = 0
  local appliedMergedRail = false

  if not providerAvailable then
    self.providerStatus = "missing"
    self.appliedBars = 0
    self.appliedButtons = 0
    self.appliedRails = 0
    self.appliedMergedRail = false
    return
  end

  for barIndex = self.firstBar, self.lastBar do
    local barApplied = false
    for buttonIndex = 1, self.buttonsPerBar do
      local button = GetButton(barIndex, buttonIndex)
      if ApplyButton(button, enabled) then
        appliedButtons = appliedButtons + 1
        barApplied = true
      end
    end
    if barApplied then
      appliedBars = appliedBars + 1
    end
  end

  for barIndex = self.firstRailBar, self.lastRailBar do
    local bar = pfUI.bars[barIndex]
    if bar and ApplyRailBackdrop(bar.backdrop, enabled) then
      appliedRails = appliedRails + 1
    end
  end

  local mainBar = pfUI.bars[1]
  local mergedBackdrop = mainBar and mainBar.mergedBackdrop
  if
    mergedBackdrop and
    ApplyRailBackdrop(mergedBackdrop.backdrop, enabled)
  then
    appliedRails = appliedRails + 1
    appliedMergedRail = true
  end

  self.providerStatus = "available"
  self.appliedBars = appliedBars
  self.appliedButtons = appliedButtons
  self.appliedRails = appliedRails
  self.appliedMergedRail = appliedMergedRail
end

function ActionBars:GetRuntimeStatus()
  return
    "contract=" .. tostring(self.runtimeContract) ..
    ",rail-contract=" .. tostring(self.railRuntimeContract) ..
    ",provider=" .. tostring(self.providerStatus or "pending") ..
    ",scope=bars-1-10" ..
    ",rail-scope=bars-1-12+merged-1-6" ..
    ",bars=" .. tostring(self.appliedBars or 0) ..
    ",buttons=" .. tostring(self.appliedButtons or 0) ..
    ",rails=" .. tostring(self.appliedRails or 0) ..
    ",merged=" ..
      tostring(self.appliedMergedRail and "available" or "missing")
end

addon:RegisterModule("ActionBars", ActionBars)
