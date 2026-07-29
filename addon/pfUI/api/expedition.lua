-- Azeroth Expedition visual contract.
--
-- This file is intentionally limited to presentation settings. It does not
-- replace pfUI events, data providers, saved data, clicks, bag operations, or
-- chat handlers.
setfenv(1, pfUI:GetEnvironment())

local STATUS_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"

pfUI.expedition = {
  version = 1,
  alpha_floor = 0.92,
  compact = {
    bgFile = pfUI.media["img:bg"],
    tile = true,
    tileSize = 8,
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 7,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  },
  thin = {
    bgFile = pfUI.media["img:bg"],
    tile = true,
    tileSize = 8,
    edgeFile = pfUI.media["img:border_blizz"],
    edgeSize = 6,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  },
  surface = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    tile = true,
    tileSize = 32,
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
  },
}

local textureKeys = {
  bartexture = true,
  healthtexture = true,
  pbartexture = true,
}

local function ReplaceFlatStatusTextures(config)
  if type(config) ~= "table" then return end

  for key, value in pairs(config) do
    if type(value) == "table" then
      ReplaceFlatStatusTextures(value)
    elseif textureKeys[key] and type(value) == "string" then
      config[key] = STATUS_TEXTURE
    elseif key == "texture" and type(value) == "string" then
      if strfind(value, "\\bars\\pfUI-") or
         strfind(value, "\\pfUI\\img\\bar") then
        config[key] = STATUS_TEXTURE
      end
    end
  end
end

function pfUI:ApplyExpeditionVisualContract()
  local config = _G.pfUI_config
  if type(config) ~= "table" then return end

  config.appearance = config.appearance or {}
  config.appearance.expedition = config.appearance.expedition or {}
  local expedition = config.appearance.expedition

  if expedition.enabled == nil then expedition.enabled = "1" end
  if expedition.alpha_floor == nil then expedition.alpha_floor = "0.92" end
  if expedition.legacy_info_panels == nil then
    expedition.legacy_info_panels = "0"
  end

  if expedition.enabled ~= "1" then return end

  pfUI.expedition.alpha_floor =
    tonumber(expedition.alpha_floor) or pfUI.expedition.alpha_floor

  -- Establish one opaque leather-and-brass baseline for every pfUI backdrop.
  config.appearance.border = config.appearance.border or {}
  config.appearance.border.background = "0.38,0.25,0.12,1"
  config.appearance.border.color = "0.64,0.48,0.25,1"
  config.appearance.border.force_blizz = "0"
  config.appearance.border.shadow = "1"
  config.appearance.border.shadow_intensity = "0.45"

  -- Keep the original widget implementations available, but do not mount
  -- guild, bag-space, latency, clock, gold, or zone readouts under chat.
  if expedition.legacy_info_panels ~= "1" then
    config.panel = config.panel or {}
    config.panel.left = config.panel.left or {}
    config.panel.right = config.panel.right or {}
    config.panel.other = config.panel.other or {}
    config.panel.left.left = "none"
    config.panel.left.center = "none"
    config.panel.left.right = "none"
    config.panel.right.left = "none"
    config.panel.right.center = "none"
    config.panel.right.right = "none"
    config.panel.other.minimap = "none"
  end

  -- Restore the paired vanilla end caps instead of a floating modern strip.
  config.bars = config.bars or {}
  config.bars.gryphons = config.bars.gryphons or {}
  config.bars.gryphons.texture = "Gryphon"
  config.bars.gryphons.color = "1,1,1,1"
  config.bars.gryphons.size = "96"

  -- Replace flat third-party bar media while retaining all bar values,
  -- update events, colors, thresholds, and interaction.
  ReplaceFlatStatusTextures(config)
  config.appearance.castbar = config.appearance.castbar or {}
  config.appearance.castbar.texture = STATUS_TEXTURE
end
