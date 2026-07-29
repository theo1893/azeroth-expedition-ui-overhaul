local root = assert(arg[1], "repository root argument is required")

strfind = string.find
setfenv = setfenv or function() end

pfUI_config = {
  appearance = {
    expedition = {},
    border = {
      background = "0,0,0,0.2",
      color = "0,0,0,1",
      shadow = "0",
    },
    castbar = {
      texture = "Interface\\AddOns\\pfUI\\img\\bar",
    },
  },
  bars = {
    gryphons = {
      texture = "None",
      color = ".6,.6,.6,1",
      size = "64",
    },
  },
  panel = {
    left = { left = "guild", center = "bagspace", right = "durability" },
    right = { left = "fps", center = "time", right = "gold" },
    other = { minimap = "zone" },
  },
  unitframes = {
    player = {
      bartexture = "Interface\\AddOns\\pfUI-CustomMedia\\bars\\pfUI-F.tga",
      health = "keep-functional-value",
    },
  },
  global = {
    autosell = "0",
    autorepair = "1",
    font_blizzard = "0",
  },
  chat = {
    global = {
      fadeout = "1",
    },
  },
}

pfUI = {
  media = setmetatable({}, {
    __index = function(_, key)
      return "Interface\\AddOns\\pfUI\\" .. string.gsub(key, ":", "\\")
    end,
  }),
}

function pfUI:GetEnvironment()
  return _G
end

dofile(root .. "/addon/pfUI/api/expedition.lua")
pfUI:ApplyExpeditionVisualContract()

local border = pfUI_config.appearance.border
assert(border.background == "0.38,0.25,0.12,1")
assert(border.color == "0.64,0.48,0.25,1")
assert(border.shadow == "1")
assert(tonumber(border.shadow_intensity) >= 0.45)
assert(tonumber(pfUI.expedition.alpha_floor) >= 0.92)
assert(pfUI_config.global.font_blizzard == "1")

local vanillaModules = {
  actionbar = "action_bars",
  panel = "system_surfaces",
  minimap = "navigation",
  player = "unit_frames",
  raid = "unit_frames",
  bags = "inventory_and_loot",
  loot = "inventory_and_loot",
  nameplates = "combat_hud",
}
for name, expectedGroup in pairs(vanillaModules) do
  local fallback, group = pfUI:ShouldUseVanillaModule(name)
  assert(fallback, name .. " did not route to its native presentation")
  assert(group == expectedGroup, name .. " has the wrong fallback group")
end

for _, name in ipairs({
  "chat", "gui", "autovendor", "questitem", "sellvalue",
  "turtle-wow", "superwow",
}) do
  assert(
    not pfUI:ShouldUseVanillaModule(name),
    name .. " is a retained behavior module and must remain loaded"
  )
end
assert(
  pfUI:ShouldUseVanillaSkin("Character"),
  "Blizzard window skins did not route to native presentation"
)

for _, value in pairs(pfUI_config.panel.left) do
  assert(value == "none", "left chat info slot remains visible")
end
for _, value in pairs(pfUI_config.panel.right) do
  assert(value == "none", "right chat info slot remains visible")
end
assert(pfUI_config.panel.other.minimap == "none")

assert(pfUI_config.bars.gryphons.texture == "Gryphon")
assert(pfUI_config.bars.gryphons.size == "96")
assert(
  pfUI_config.unitframes.player.bartexture ==
    "Interface\\TargetingFrame\\UI-StatusBar",
  "flat unit-frame status texture was not replaced"
)
assert(
  pfUI_config.appearance.castbar.texture ==
    "Interface\\TargetingFrame\\UI-StatusBar",
  "flat castbar texture was not replaced"
)

-- Non-visual behavior settings must survive the visual migration unchanged.
assert(pfUI_config.global.autosell == "0")
assert(pfUI_config.global.autorepair == "1")
assert(pfUI_config.chat.global.fadeout == "1")
assert(pfUI_config.unitframes.player.health == "keep-functional-value")

local panelFile = assert(io.open(root .. "/addon/pfUI/modules/panel.lua", "rb"))
local panelSource = panelFile:read("*a")
panelFile:close()
assert(
  string.find(panelSource, '"guild"', 1, true) and
  string.find(panelSource, '"bagspace"', 1, true) and
  string.find(panelSource, '"fps"', 1, true),
  "pfUI panel widget providers were removed instead of only being unmounted"
)
assert(
  string.find(panelSource, "function pfUI.panel:OutputPanel", 1, true),
  "pfUI panel output behavior is missing"
)

-- The compatibility opt-in keeps the original output selection available.
pfUI_config.appearance.expedition.legacy_info_panels = "1"
pfUI_config.panel.left.left = "guild"
pfUI_config.panel.right.left = "fps"
pfUI_config.panel.other.minimap = "zone"
pfUI:ApplyExpeditionVisualContract()
assert(pfUI_config.panel.left.left == "guild")
assert(pfUI_config.panel.right.left == "fps")
assert(pfUI_config.panel.other.minimap == "zone")

-- Both routing layers are opt-out for upstream comparison and emergency
-- compatibility checks.
pfUI_config.appearance.expedition.vanilla_fallback = "0"
pfUI_config.appearance.expedition.native_blizzard_skins = "0"
assert(not pfUI:ShouldUseVanillaModule("actionbar"))
assert(not pfUI:ShouldUseVanillaSkin("Character"))

print("pfUI expedition visual contract test passed")
