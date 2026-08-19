-- Azeroth Expedition scoped ownership contract.
--
-- pfUI remains the default owner for every module and Blizzard skin unless
-- the exact object is listed below. AzerothExpeditionUI may then adapt the
-- retained pfUI provider or replace only that listed presentation.
setfenv(1, pfUI:GetEnvironment())

local STATUS_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"
local PFUI_STATUS_TEXTURE = pfUI.media["img:bar"]

pfUI.expedition = {
  version = 14,
  ownership = "scoped-v1",

  -- The main pfUI chat module stays loaded because AEUI uses its frames,
  -- events, SavedVariables and interaction. Only unfinished auxiliary chat
  -- presentations remain outside the active route.
  module_owners = {
    chatcopy = "chat",
    whisperproxy = "chat",
    bubbles = "chat",
  },

  -- AEUI owns the Quest Log book. Every other Blizzard skin, including the
  -- Game Menu skin that exposes the pfUI configuration button, stays in pfUI.
  skin_owners = {
    ["Quest Log"] = "quests",
  },

  -- Unit Frames remain fully provided by pfUI. AEUI owns only these concrete
  -- visual donors, raid-member shells and dynamic portrait presentation;
  -- frame construction, updates, roster assignment and interaction do not
  -- yield to another module.
  component_owners = {
    ["unitframes.health-fill"] = "unitframes",
    ["unitframes.power-fill"] = "unitframes",
    ["unitframes.player-shell-v5"] = "unitframes",
    ["unitframes.raid-shell"] = "unitframes",
    ["unitframes.raid-health-fill"] = "unitframes",
    ["unitframes.raid-power-fill"] = "unitframes",
    ["unitframes.dynamic-portraits"] = "unitframes",
    ["character.frame-shell-v3"] = "character",
    ["character.model-background-v3"] = "character",
    ["character.stats-paper-v3"] = "character",
    ["character.resistance-wells-v3"] = "character",
    ["character.slot-base-v3"] = "character",
    ["character.slot-interaction-v3"] = "character",
    ["character.tabs-v3"] = "character",
    ["character.ammo-slot-v3"] = "character",
  },
}

local function GetExpeditionConfig()
  local config = _G.pfUI_config
  return config and
    config.appearance and
    config.appearance.expedition
end

local function IsScopedRouteEnabled()
  local expedition = GetExpeditionConfig()
  return expedition and expedition.enabled == "1"
end

function pfUI:GetExpeditionModuleOwner(name)
  if not IsScopedRouteEnabled() then return nil end
  return pfUI.expedition.module_owners[name]
end

function pfUI:GetExpeditionSkinOwner(name)
  if not IsScopedRouteEnabled() then return nil end
  return pfUI.expedition.skin_owners[name]
end

function pfUI:GetExpeditionComponentOwner(name)
  if not IsScopedRouteEnabled() then return nil end
  return pfUI.expedition.component_owners[name]
end

-- Compatibility names retained for the pfUI loader. A true result now means
-- only that the named module/skin is explicitly owned by AEUI, not that a
-- broad class of pfUI presentation should fall back to Blizzard.
function pfUI:ShouldUseVanillaModule(name)
  local owner = pfUI:GetExpeditionModuleOwner(name)
  return owner and true or false, owner
end

function pfUI:ShouldUseVanillaSkin(name)
  local owner = pfUI:GetExpeditionSkinOwner(name)
  return owner and true or false, owner
end

function pfUI:ShouldUseSingleChatFrame()
  local expedition = GetExpeditionConfig()
  return expedition and
    expedition.enabled == "1" and
    expedition.single_chat_frame == "1" and
    true or false
end

local textureKeys = {
  bartexture = true,
  healthtexture = true,
  pbartexture = true,
}

local function RestorePfUIStatusTextures(config)
  if type(config) ~= "table" then return end

  for key, value in pairs(config) do
    if type(value) == "table" then
      RestorePfUIStatusTextures(value)
    elseif textureKeys[key] and value == STATUS_TEXTURE then
      config[key] = PFUI_STATUS_TEXTURE
    elseif key == "texture" and value == STATUS_TEXTURE then
      config[key] = PFUI_STATUS_TEXTURE
    end
  end
end

local function RestoreLegacyPanelSlot(group, key, value)
  if group and group[key] == "none" then
    group[key] = value
  end
end

local function MigrateGlobalFallback(config, expedition)
  local legacyContract =
    expedition.vanilla_fallback == "1" or
    expedition.native_blizzard_skins == "1" or
    expedition.legacy_info_panels == "0" or
    expedition.alpha_floor ~= nil
  if not legacyContract then
    return
  end

  -- These values were force-written by the former global visual contract.
  -- Restore the recorded pfUI 8.1.0 defaults only when the forced value is
  -- still present, then leave future edits entirely to the pfUI config UI.
  local border = config.appearance and config.appearance.border
  if border then
    if border.background == "0.38,0.25,0.12,1" then
      border.background = "0,0,0,1"
    end
    if border.color == "0.64,0.48,0.25,1" then
      border.color = "0.2,0.2,0.2,1"
    end
    if border.shadow == "1" then border.shadow = "0" end
    if border.shadow_intensity == "0.45" or
       border.shadow_intensity == ".45" then
      border.shadow_intensity = ".35"
    end
  end

  if config.global and config.global.font_blizzard == "1" then
    config.global.font_blizzard = "0"
  end

  local gryphons = config.bars and config.bars.gryphons
  if gryphons then
    if gryphons.texture == "Gryphon" then gryphons.texture = "None" end
    if gryphons.color == "1,1,1,1" then gryphons.color = ".6,.6,.6,1" end
    if gryphons.size == "96" then gryphons.size = "64" end
  end

  local panel = config.panel
  if panel then
    RestoreLegacyPanelSlot(panel.left, "left", "guild")
    RestoreLegacyPanelSlot(panel.left, "center", "durability")
    RestoreLegacyPanelSlot(panel.left, "right", "friends")
    RestoreLegacyPanelSlot(panel.right, "left", "fps")
    RestoreLegacyPanelSlot(panel.right, "center", "time")
    RestoreLegacyPanelSlot(panel.right, "right", "gold")
    RestoreLegacyPanelSlot(panel.other, "minimap", "zone")
  end

  RestorePfUIStatusTextures(config)
end

function pfUI:ApplyExpeditionVisualContract()
  local config = _G.pfUI_config
  if type(config) ~= "table" then return end

  config.appearance = config.appearance or {}
  config.appearance.expedition = config.appearance.expedition or {}
  local expedition = config.appearance.expedition

  if expedition.enabled == nil then expedition.enabled = "1" end
  if expedition.single_chat_frame == nil then
    expedition.single_chat_frame = "1"
  end
  if expedition.vanilla_fallback == nil then
    expedition.vanilla_fallback = "0"
  end
  if expedition.native_blizzard_skins == nil then
    expedition.native_blizzard_skins = "0"
  end

  MigrateGlobalFallback(config, expedition)

  -- Retire the former broad route even for existing SavedVariables. These
  -- compatibility fields remain so older profiles cannot reactivate it.
  expedition.ownership = pfUI.expedition.ownership
  expedition.alpha_floor = nil
  expedition.vanilla_fallback = "0"
  expedition.native_blizzard_skins = "0"
  expedition.legacy_info_panels = "1"

  if expedition.enabled ~= "1" then return end

  -- This is the only setting enforced outside the route maps: AEUI Chat is a
  -- single journal and reclaims the secondary message groups in ChatFrame1.
  if expedition.single_chat_frame == "1" then
    config.chat = config.chat or {}
    config.chat.right = config.chat.right or {}
    config.chat.right.enable = "0"
  end
end
