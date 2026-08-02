local root = assert(arg[1], "repository root argument is required")

strfind = string.find
setfenv = setfenv or function() end

local statusTexture = "Interface\\TargetingFrame\\UI-StatusBar"
local pfuiBarTexture = "Interface\\AddOns\\pfUI\\img\\bar"

-- Simulate an existing profile last saved under the former global fallback
-- contract. ApplyExpeditionVisualContract must migrate it once before routing.
pfUI_config = {
  appearance = {
    expedition = {
      enabled = "1",
      vanilla_fallback = "1",
      native_blizzard_skins = "1",
      legacy_info_panels = "0",
      alpha_floor = "0.92",
      single_chat_frame = "1",
    },
    border = {
      background = "0.38,0.25,0.12,1",
      color = "0.64,0.48,0.25,1",
      shadow = "1",
      shadow_intensity = "0.45",
    },
    castbar = {
      texture = statusTexture,
    },
  },
  bars = {
    gryphons = {
      texture = "Gryphon",
      color = "1,1,1,1",
      size = "96",
    },
  },
  panel = {
    left = { left = "none", center = "none", right = "none" },
    right = { left = "none", center = "none", right = "none" },
    other = { minimap = "none" },
  },
  unitframes = {
    player = {
      bartexture = statusTexture,
      health = "keep-functional-value",
    },
  },
  global = {
    autosell = "0",
    autorepair = "1",
    font_blizzard = "1",
  },
  chat = {
    right = {
      enable = "1",
    },
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

assert(pfUI.expedition.version == 3)
assert(pfUI.expedition.ownership == "scoped-v1")
assert(pfUI_config.appearance.expedition.ownership == "scoped-v1")
assert(pfUI_config.appearance.expedition.alpha_floor == nil)
assert(pfUI_config.appearance.expedition.vanilla_fallback == "0")
assert(pfUI_config.appearance.expedition.native_blizzard_skins == "0")
assert(pfUI_config.appearance.expedition.legacy_info_panels == "1")
assert(
  pfUI:ShouldUseSingleChatFrame(),
  "scoped route did not retain the single chat journal"
)
assert(
  pfUI_config.chat.right.enable == "0",
  "pfUI right chat remained enabled"
)

-- Values force-written by the retired global contract migrate back to the
-- recorded pfUI 8.1.0 defaults.
local border = pfUI_config.appearance.border
assert(border.background == "0,0,0,1")
assert(border.color == "0.2,0.2,0.2,1")
assert(border.shadow == "0")
assert(border.shadow_intensity == ".35")
assert(pfUI_config.global.font_blizzard == "0")
assert(pfUI_config.bars.gryphons.texture == "None")
assert(pfUI_config.bars.gryphons.color == ".6,.6,.6,1")
assert(pfUI_config.bars.gryphons.size == "64")
assert(pfUI_config.panel.left.left == "guild")
assert(pfUI_config.panel.left.center == "durability")
assert(pfUI_config.panel.left.right == "friends")
assert(pfUI_config.panel.right.left == "fps")
assert(pfUI_config.panel.right.center == "time")
assert(pfUI_config.panel.right.right == "gold")
assert(pfUI_config.panel.other.minimap == "zone")
assert(pfUI_config.unitframes.player.bartexture == pfuiBarTexture)
assert(pfUI_config.appearance.castbar.texture == pfuiBarTexture)

-- Only explicit Chat auxiliaries yield to AEUI. The main chat provider, the
-- config GUI and every unrelated pfUI component must load normally.
for _, name in ipairs({ "chatcopy", "whisperproxy", "bubbles" }) do
  local owned, owner = pfUI:ShouldUseVanillaModule(name)
  assert(owned, name .. " was not routed to AEUI Chat")
  assert(owner == "chat", name .. " has the wrong owner")
end

for _, name in ipairs({
  "gui", "skin", "panel", "actionbar", "minimap", "player", "raid",
  "bags", "loot", "nameplates", "chat", "autovendor", "questitem",
  "sellvalue", "turtle-wow", "superwow",
}) do
  assert(
    not pfUI:ShouldUseVanillaModule(name),
    name .. " must remain owned by pfUI"
  )
end

local questOwned, questOwner = pfUI:ShouldUseVanillaSkin("Quest Log")
assert(questOwned, "Quest Log skin was not routed to AEUI Quests")
assert(questOwner == "quests", "Quest Log skin has the wrong owner")
for _, name in ipairs({
  "Game Menu", "Character", "Gossip and Quest", "Spellbook", "Mailbox",
}) do
  assert(
    not pfUI:ShouldUseVanillaSkin(name),
    name .. " skin must remain owned by pfUI"
  )
end

-- Functional and unrelated user settings survive both migration and routing.
assert(pfUI_config.global.autosell == "0")
assert(pfUI_config.global.autorepair == "1")
assert(pfUI_config.chat.global.fadeout == "1")
assert(pfUI_config.unitframes.player.health == "keep-functional-value")

-- After migration, subsequent config edits are never rewritten by AEUI.
pfUI_config.appearance.border.background = "custom-background"
pfUI_config.panel.left.left = "custom-panel"
pfUI_config.unitframes.player.bartexture = "custom-bar"
pfUI:ApplyExpeditionVisualContract()
assert(pfUI_config.appearance.border.background == "custom-background")
assert(pfUI_config.panel.left.left == "custom-panel")
assert(pfUI_config.unitframes.player.bartexture == "custom-bar")

-- Disabling the scoped route restores every pfUI module and skin.
pfUI_config.appearance.expedition.enabled = "0"
assert(not pfUI:ShouldUseVanillaModule("chatcopy"))
assert(not pfUI:ShouldUseVanillaSkin("Quest Log"))

local panelFile = assert(io.open(root .. "/addon/pfUI/modules/panel.lua", "rb"))
local panelSource = panelFile:read("*a")
panelFile:close()
assert(
  string.find(panelSource, '"guild"', 1, true) and
  string.find(panelSource, '"bagspace"', 1, true) and
  string.find(panelSource, '"fps"', 1, true),
  "pfUI panel widget providers are missing"
)
assert(
  string.find(panelSource, "function pfUI.panel:OutputPanel", 1, true),
  "pfUI panel output behavior is missing"
)

local chatFile = assert(io.open(root .. "/addon/pfUI/modules/chat.lua", "rb"))
local chatSource = chatFile:read("*a")
chatFile:close()
assert(
  string.find(chatSource, "ApplyExpeditionMessagePalette", 1, true) and
    string.find(chatSource, "chat:ApplyMessagePalette", 1, true),
  "pfUI chat final output lacks the scoped AEUI palette bridge"
)

local menuFile = assert(io.open(
  root .. "/addon/pfUI/skins/blizzard/game_menu.lua",
  "rb"
))
local menuSource = menuFile:read("*a")
menuFile:close()
assert(
  string.find(menuSource, "GameMenuButtonPFUI", 1, true) and
  string.find(menuSource, "pfUI.gui:Show()", 1, true),
  "pfUI Game Menu configuration entry is missing"
)

print("pfUI scoped ownership contract test passed")
