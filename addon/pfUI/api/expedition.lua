-- Azeroth Expedition visual contract.
--
-- This file is intentionally limited to presentation routing and settings.
-- It does not rewrite pfUI events, data providers, saved data, or chat
-- handlers. UI-owning modules may be routed to the client's native equivalent.
setfenv(1, pfUI:GetEnvironment())

local STATUS_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"

pfUI.expedition = {
  version = 2,
  alpha_floor = 0.92,
  vanilla_modules = {},
  vanilla_module_groups = {},
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

-- Until a subsystem has a component-level overhaul, keep the corresponding
-- Blizzard/Turtle WoW presentation instead of loading pfUI's modern
-- replacement. Functional modules which do not own a visible presentation
-- are deliberately absent from this table.
local vanillaModuleGroups = {
  action_bars = {
    "actionbar", "gryphons", "hunterbar", "hoverbind",
  },
  chat_auxiliary = {
    "whisperproxy", "chatcopy", "bubbles",
  },
  navigation = {
    "minimap", "tracking", "farmmode", "addonbuttons",
    "map", "mapcolors", "mapreveal", "marktracking",
  },
  unit_frames = {
    "player", "target", "focus", "targettarget", "targettargettarget",
    "pet", "pettarget", "group", "raid", "mouseover", "uf_tukui",
  },
  combat_hud = {
    "castbar", "combopoints", "swingtimer", "energytick",
    "mirrortimers", "buff", "buffwatch", "totems", "nameplates",
    "nampower", "unitxp", "xpbar", "infight", "raidmarkers",
  },
  inventory_and_loot = {
    "bags", "itemclick", "unusable", "cooldown", "loot", "roll",
  },
  system_surfaces = {
    "skin", "tooltip", "panel", "addons", "firstrun",
    "thirdparty", "thirdparty-vanilla", "thirdparty-tbc",
    "bgscore", "easteregg", "afkcam", "addoncompat",
  },
}

for group, modules in pairs(vanillaModuleGroups) do
  for _, name in ipairs(modules) do
    pfUI.expedition.vanilla_modules[name] = true
    pfUI.expedition.vanilla_module_groups[name] = group
  end
end

local function GetExpeditionConfig()
  local config = _G.pfUI_config
  return config and
    config.appearance and
    config.appearance.expedition
end

function pfUI:ShouldUseVanillaModule(name)
  local expedition = GetExpeditionConfig()
  if not expedition or expedition.enabled ~= "1" then
    return false
  end
  if expedition.vanilla_fallback ~= "1" then
    return false
  end

  return pfUI.expedition.vanilla_modules[name] and true or false,
    pfUI.expedition.vanilla_module_groups[name]
end

function pfUI:ShouldUseVanillaSkin()
  local expedition = GetExpeditionConfig()
  return expedition and
    expedition.enabled == "1" and
    expedition.native_blizzard_skins == "1" and
    true or false
end

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
  if expedition.vanilla_fallback == nil then
    expedition.vanilla_fallback = "1"
  end
  if expedition.native_blizzard_skins == nil then
    expedition.native_blizzard_skins = "1"
  end
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

  -- Do not let the Modern profile replace the typography of native frames.
  -- Module-specific fonts are applied later by AzerothExpeditionUI.
  if expedition.vanilla_fallback == "1" then
    config.global = config.global or {}
    config.global.font_blizzard = "1"
  end

  -- The panel module is normally routed out. Keep every slot empty as a second
  -- guard for explicit module opt-in and upstream comparison.
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

  -- Compatibility baseline for explicit pfUI action-bar opt-in. The default
  -- native route already shows the client's paired gryphon end caps.
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
