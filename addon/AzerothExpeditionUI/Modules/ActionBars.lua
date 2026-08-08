AzerothExpeditionUI = AzerothExpeditionUI or {}

local addon = AzerothExpeditionUI
local ActionBars = {}

ActionBars.runtimeContract = "1.0"
ActionBars.texturePath = addon.media.root .. "ActionBars\\ActionSlotBaseV1"
ActionBars.firstBar = 1
ActionBars.lastBar = 10
ActionBars.buttonsPerBar = 12

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
end

function ActionBars:Apply()
  local enabled = addon.db and addon.db.actionbars and
    addon.db.actionbars.enabled
  local providerAvailable = pfUI and pfUI.bars
  local appliedBars = 0
  local appliedButtons = 0

  if not providerAvailable then
    self.providerStatus = "missing"
    self.appliedBars = 0
    self.appliedButtons = 0
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

  self.providerStatus = "available"
  self.appliedBars = appliedBars
  self.appliedButtons = appliedButtons
end

function ActionBars:GetRuntimeStatus()
  return
    "contract=" .. tostring(self.runtimeContract) ..
    ",provider=" .. tostring(self.providerStatus or "pending") ..
    ",scope=bars-1-10" ..
    ",bars=" .. tostring(self.appliedBars or 0) ..
    ",buttons=" .. tostring(self.appliedButtons or 0)
end

addon:RegisterModule("ActionBars", ActionBars)
