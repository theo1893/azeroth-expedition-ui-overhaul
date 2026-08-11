local addon = AzerothExpeditionUI
local UnitFrames = {}
UnitFrames.runtimeContract = "1.0"

local MEDIA = addon.media.root .. "UnitFrames\\"
local HEALTH_TEXTURE = MEDIA .. "UnitFrameHealthFillV1"
local POWER_TEXTURE = MEDIA .. "UnitFramePowerFillV1"

-- This batch intentionally owns only the four units in the accepted contract.
-- Party, raid, pet, focus-target and fallback frames retain configured pfUI
-- media until their own component contracts are accepted.
local FRAME_KEYS = {
  "player",
  "target",
  "targettarget",
  "focus",
}

local function GetConfiguredTexture(frame, key)
  if not frame or not frame.config or not pfUI or not pfUI.media then
    return nil
  end

  local configured = frame.config[key]
  if configured and pfUI.media[configured] then
    return pfUI.media[configured]
  end
  return pfUI.media["img:bar"]
end

local function CanSetTexture(statusBar)
  return statusBar and type(statusBar.SetStatusBarTexture) == "function"
end

function UnitFrames:IsEnabled()
  if not addon.db or not addon.db.unitframes then
    return false
  end
  if not addon.db.unitframes.enabled then
    return false
  end
  if not pfUI or not pfUI.GetExpeditionComponentOwner then
    return false
  end

  return
    pfUI:GetExpeditionComponentOwner("unitframes.health-fill") ==
      "unitframes" and
    pfUI:GetExpeditionComponentOwner("unitframes.power-fill") ==
      "unitframes"
end

function UnitFrames:ApplyFrame(frame)
  if not frame then
    return false
  end

  local healthBar = frame.hp and frame.hp.bar
  local powerBar = frame.power and frame.power.bar
  if not CanSetTexture(healthBar) or not CanSetTexture(powerBar) then
    return false
  end

  frame.aeuiHealthBarTexture = HEALTH_TEXTURE
  frame.aeuiPowerBarTexture = POWER_TEXTURE
  healthBar:SetStatusBarTexture(HEALTH_TEXTURE)
  powerBar:SetStatusBarTexture(POWER_TEXTURE)
  frame.aeuiUnitFrameBarsContract = self.runtimeContract
  return true
end

function UnitFrames:RestoreFrame(frame)
  if not frame then
    return false
  end

  local healthBar = frame.hp and frame.hp.bar
  local powerBar = frame.power and frame.power.bar
  frame.aeuiHealthBarTexture = nil
  frame.aeuiPowerBarTexture = nil
  frame.aeuiUnitFrameBarsContract = nil

  if CanSetTexture(healthBar) then
    local texture = GetConfiguredTexture(frame, "bartexture")
    if texture then
      healthBar:SetStatusBarTexture(texture)
    end
  end
  if CanSetTexture(powerBar) then
    local texture = GetConfiguredTexture(frame, "pbartexture")
    if texture then
      powerBar:SetStatusBarTexture(texture)
    end
  end
  return true
end

function UnitFrames:Apply()
  local enabled = self:IsEnabled()
  local frames = pfUI and pfUI.uf
  local applied = 0

  if frames then
    for _, key in ipairs(FRAME_KEYS) do
      local frame = frames[key]
      if enabled then
        if self:ApplyFrame(frame) then
          applied = applied + 1
        end
      else
        self:RestoreFrame(frame)
      end
    end
  end

  self.appliedFrameCount = applied
end

function UnitFrames:Initialize()
  self:Apply()
end

function UnitFrames:GetRuntimeStatus()
  return
    "contract=" .. tostring(self.runtimeContract) ..
    ", enabled=" .. tostring(self:IsEnabled()) ..
    ", frames=" .. tostring(self.appliedFrameCount or 0) .. "/4" ..
    ", scope=player,target,targettarget,focus" ..
    ", fallback=pfui-configured-bars"
end

addon:RegisterModule("UnitFrames", UnitFrames)
