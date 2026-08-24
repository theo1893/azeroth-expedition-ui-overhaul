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
ActionBars.fieldKitRuntimeContract = "2.9"
ActionBars.focusLayoutRuntimeContract = "3.0"
ActionBars.focusLayoutVersion = 18
ActionBars.focusLayoutBackupVersion = 1
ActionBars.focusUnitDefaultVersion = 2
ActionBars.focusUnitDefaultBackupVersion = 1
ActionBars.sideBarGroupRuntimeContract = "1.0"
ActionBars.sideBarGroupLayoutVersion = 1
ActionBars.sideBarGroupBackupVersion = 1
ActionBars.autoBarDefaultModeVersion = 1
ActionBars.autoBarClassScopeVersion = 1
ActionBars.focusCoordinateSpace = "game-native-v1"
ActionBars.comfortUIScaleVersion = 2
ActionBars.comfortUIScaleTier = 8
ActionBars.comfortUIScaleValue = 0.71111111111111
-- ACTION-BARS-CORE-SIM-V11 keeps global pfUI tier 8 and the accepted Combat
-- Deck geometry. The provider-owned DoiteDPS two-row union keeps its vertical
-- safe lane and shifts left as a whole to clear the central combat view,
-- uses the client system face for the three local unit frames, and implements
-- the accepted right-side cluster as one reversible mover. Runtime v3.0 keeps
-- the Aura icons at their readable size, expands each primary unit frame to
-- one 16-icon row, grows both primary Aura wings away from the centre, and
-- lowers the pair to close the space above the unchanged readout stack.
ActionBars.focusUnitScale = 0.8
ActionBars.focusTargetTargetScale = 0.68
ActionBars.focusReadoutScale = 1
ActionBars.focusStanceScale = 1
ActionBars.focusStanceIconSize = "25"
-- Warrior stances and the shaman ArchiTotem row are mutually exclusive
-- class satellites. Keep their visible centres on one Combat Deck slot.
ActionBars.combatDeckClassDockXOffset = -128
ActionBars.combatDeckStanceGap = 0
ActionBars.focusDoiteScale = 0.82
-- At the current pfUI border contract each 23 UI Aura advances by 30 UI.
-- Sixteen cells therefore occupy the complete 480 UI primary-frame width.
ActionBars.focusUnitWidth = 480
ActionBars.focusUnitHeight = 48
ActionBars.focusTargetTargetWidth = 240
ActionBars.focusTargetTargetHeight = 60
ActionBars.focusUnitFontRole = "system"
ActionBars.focusUnitFontSize = 18
ActionBars.focusUnitFontStyle = "OUTLINE"
ActionBars.focusAuraSize = 23
ActionBars.focusTargetTargetAuraSize = 23
ActionBars.focusAuraPerRow = 16
ActionBars.focusTargetTargetAuraPerRow = 8
ActionBars.focusPrimaryGap = 64
ActionBars.focusReadoutWidth = 260
ActionBars.focusReadoutHeight = 12
ActionBars.focusTargetTargetGap = 8
ActionBars.sideBarGroupFormFactor = "3 x 4"
ActionBars.sideBarGroupIconSize = "20"
ActionBars.sideBarGroupSpacing = "1"
ActionBars.sideBarGroupScale = 1.2
ActionBars.sideBarGroupGap = 6
ActionBars.sideBarGroupAutoProfile = "大奶黑牛 - Basin of Stars"
ActionBars.trinketKitTexturePath =
  addon.media.root .. "ActionBars\\ActionTrinketKitV1"
ActionBars.consumableKitTexturePath =
  addon.media.root .. "ActionBars\\ActionConsumableKitV1"
ActionBars.fieldKitCap = 6
ActionBars.fieldKitPocketPadding = 4
ActionBars.fieldKitShellPadding = 6
ActionBars.consumableDockGap = 12
ActionBars.autoBarDockColumns = 4
ActionBars.trinketDockGap = 8
ActionBars.fieldKitDockYOffset = -20
ActionBars.actionBarStackOverlap = 1
ActionBars.popupDrawerGap = 6
ActionBars.popupDrawerMaxRows = 6
ActionBars.popupIntentDelay = 0.30
ActionBars.popupIntentEvent = "AEUI_AutoBarPopupIntent"
ActionBars.autoBarProviderDockName = "pfActionBarMain"
ActionBars.autoBarDockBackupVersion = 1
-- AutoBar may rewrite its drag handle after every visual refresh. The bound
-- Field Kit therefore docks the real visible buttons to a four-column AEUI
-- root whose bottom-right edge follows the main action bar. Provider refresh
-- hooks reapply that grid at event boundaries; no OnUpdate position loop is
-- used.
ActionBars.autoBarRefreshDelay = 0
ActionBars.autoBarRefreshEvent = "AEUI_AutoBarFieldKitRefresh"
-- The former -10 UI offset only centered ArchiTotem's visible union. Shift
-- that union another 128 UI left so all four downward element columns clear
-- the Target Markers icon board at the provider's current 0.8 scale.
ActionBars.archiTotemDockXOffset =
  ActionBars.combatDeckClassDockXOffset - 10
-- Keep the provider row below the XP rail with a compact five-pixel visual
-- clearance; the provider's root still omits its unscaled drag handle.
ActionBars.archiTotemDockYOffset = -39

-- AutoBar 1.31's zhCN locale omits these seven category descriptions. The
-- provider still creates the categories, so its configuration tooltip later
-- concatenates nil and errors. Repair only missing runtime labels; category
-- contents, profile data, and SavedVariables remain provider-owned.
local autoBarCategoryDescriptionFallbacks = {
  POTION_SPELLPOWER = {
    zhCN = "法术强度药剂",
    default = "Spellpower Potions",
  },
  TEAS = {
    zhCN = "茶",
    default = "Tea",
  },
  ZANZA = {
    zhCN = "赞扎药剂",
    default = "Zanza",
  },
  DRINK_STAMINA = {
    zhCN = "饮料：耐力加成",
    default = "Drink: Stamina Bonus",
  },
  FOOD_SPELLPOWER = {
    zhCN = "食物：法术强度加成",
    default = "Food: Spellpower Bonus",
  },
  QUESTSTARTITEMS = {
    zhCN = "任务起始物品",
    default = "Items that Start Quests",
  },
  QUESTUSEITEMS = {
    zhCN = "任务使用物品",
    default = "Items Used During Quests",
  },
}

-- Runtime v2.2 uses the exact Turtle WoW 1.12 coordinates consumed by
-- Frame:SetPoint and pfUI.api.LoadMovable. They are relative to UIParent at
-- the required pfUI tier 8. Do not project them through GetScreenWidth,
-- effective scale, physical pixels, or frame readback: those are different
-- coordinate spaces in this client.
ActionBars.combatDeckX = 0
ActionBars.combatDeckY = 175
-- 480 local UI at scale 0.8 is 384 game UI. Centres at +/-224 keep a
-- compact 64 UI sight lane between the two primary frames. Two outward Aura
-- rows consume 48 game UI below y=408, leaving 32 UI above the player castbar.
ActionBars.focusPlayerX = -224
ActionBars.focusTargetX = 224
ActionBars.focusTargetTargetX = 512
ActionBars.focusUnitY = 408
ActionBars.focusTargetTargetY = 408
ActionBars.focusCastPlayerX = 0
ActionBars.focusCastTargetX = 0
ActionBars.focusCastY = 316
ActionBars.focusTargetCastY = 300
ActionBars.focusSwingX = 0
ActionBars.focusSwingY = 284
ActionBars.focusStanceX = 0
ActionBars.focusStanceY = 255
ActionBars.focusDoiteX = 650
ActionBars.focusDoiteY = -615

local sideBarGroupDefinitions = {
  {
    index = 2,
    config = "bar2",
    name = "pfActionBarPaging",
    homeX = -133,
    homeY = -68,
  },
  {
    index = 4,
    config = "bar4",
    name = "pfActionBarVertical",
    homeX = -35,
    homeY = -68,
  },
  {
    index = 5,
    config = "bar5",
    name = "pfActionBarLeft",
    homeX = -133,
    homeY = -196,
  },
  {
    index = 3,
    config = "bar3",
    name = "pfActionBarRight",
    homeX = -35,
    homeY = -196,
  },
}

local sideBarLegacyPositions = {
  pfActionBarPaging = { x = -102, y = 4 },
  pfActionBarVertical = { x = -68, y = 4 },
  pfActionBarLeft = { x = -34, y = 3 },
  pfActionBarRight = { x = 0, y = 3 },
}

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

local fieldKitSliceOrder = {
  "topLeft", "top", "topRight",
  "left", "center", "right",
  "bottomLeft", "bottom", "bottomRight",
}

local connectorSliceOrder = { "start", "middle", "end" }

local trinketKitTexCoords = {
  A = { 0.017578125, 0.232421875, 0.015625, 0.234375 },
  B = { 0.265625, 0.484375, 0.015625, 0.232421875 },
  C = {
    topLeft = { 0.015625, 0.103515625, 0.26953125, 0.357421875 },
    top = { 0.103515625, 0.427734375, 0.26953125, 0.357421875 },
    topRight = { 0.427734375, 0.515625, 0.26953125, 0.357421875 },
    left = { 0.015625, 0.103515625, 0.357421875, 0.673828125 },
    center = { 0.103515625, 0.427734375, 0.357421875, 0.673828125 },
    right = { 0.427734375, 0.515625, 0.357421875, 0.673828125 },
    bottomLeft = { 0.015625, 0.103515625, 0.673828125, 0.76171875 },
    bottom = { 0.103515625, 0.427734375, 0.673828125, 0.76171875 },
    bottomRight = { 0.427734375, 0.515625, 0.673828125, 0.76171875 },
  },
  horizontal = {
    start = { 0.515625, 0.57421875, 0.044921875, 0.203125 },
    middle = { 0.57421875, 0.92578125, 0.044921875, 0.203125 },
    ["end"] = { 0.92578125, 0.984375, 0.044921875, 0.203125 },
  },
  vertical = {
    start = { 0.794921875, 0.953125, 0.28125, 0.33984375 },
    middle = { 0.794921875, 0.953125, 0.33984375, 0.69140625 },
    ["end"] = { 0.794921875, 0.953125, 0.69140625, 0.75 },
  },
}

local consumableKitTexCoords = {
  A = { 0.015625, 0.234375, 0.01953125, 0.23046875 },
  B = { 0.265625, 0.484375, 0.017578125, 0.232421875 },
  C = {
    topLeft = { 0.015625, 0.10546875, 0.265625, 0.35546875 },
    top = { 0.10546875, 0.42578125, 0.265625, 0.35546875 },
    topRight = { 0.42578125, 0.515625, 0.265625, 0.35546875 },
    left = { 0.015625, 0.10546875, 0.35546875, 0.67578125 },
    center = { 0.10546875, 0.42578125, 0.35546875, 0.67578125 },
    right = { 0.42578125, 0.515625, 0.35546875, 0.67578125 },
    bottomLeft = { 0.015625, 0.10546875, 0.67578125, 0.765625 },
    bottom = { 0.10546875, 0.42578125, 0.67578125, 0.765625 },
    bottomRight = { 0.42578125, 0.515625, 0.67578125, 0.765625 },
  },
  horizontal = {
    start = { 0.515625, 0.57421875, 0.083984375, 0.1640625 },
    middle = { 0.57421875, 0.92578125, 0.083984375, 0.1640625 },
    ["end"] = { 0.92578125, 0.984375, 0.083984375, 0.1640625 },
  },
  vertical = {
    start = { 0.833984375, 0.9140625, 0.28125, 0.33984375 },
    middle = { 0.833984375, 0.9140625, 0.33984375, 0.69140625 },
    ["end"] = { 0.833984375, 0.9140625, 0.69140625, 0.75 },
  },
}

local trinketKitSpriteSizes = {
  A = { 110, 112 },
  B = { 112, 111 },
}

local consumableKitSpriteSizes = {
  A = { 112, 108 },
  B = { 112, 110 },
}

local nativeTrinketBackdrop = {
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true,
  tileSize = 16,
  edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local recommendedAutoBarSlots = {
  [1] = "HEALPOTIONS|PVP_HEALPOTIONS|ALTERAC_HEAL",
  [2] = "HEALTHSTONE|WHIPPER_ROOT",
  [4] = "REJUVENATION_POTIONS|NIGHT_DRAGONS_BREATH|UNGORO_RESTORE",
  [5] = "BANDAGES|ALTERAC_BANDAGES|WARSONG_BANDAGES|ARATHI_BANDAGES",
  [6] = "ANTI_VENOM",
  [7] = "ACTION_POTIONS|PROTECTION_DAMAGE",
  [8] = "SWIFTNESSPOTIONS|ZANZA",
  [9] = "POTION_AGILITY|POTION_STRENGTH|POTION_SPELLPOWER|BUFF_ATTACKPOWER|BUFF_ATTACKSPEED",
  [10] = "POTION_FORTITUDE|POTION_INTELLECT|POTION_WISDOM|POTION_DEFENSE|POTION_TROLL|BUFF_DODGE",
  [11] = "PROTECTION_ARCANE|PROTECTION_FIRE|PROTECTION_FROST|PROTECTION_NATURE|PROTECTION_SHADOW|PROTECTION_SPELLS|PROTECTION_HOLY",
  [12] = "SCROLL_AGILITY|SCROLL_INTELLECT|SCROLL_PROTECTION|SCROLL_SPIRIT|SCROLL_STAMINA|SCROLL_STRENGTH",
  [13] = "FOOD|FOOD_PERCENT|FOOD_CONJURED",
  [14] = "WATER|WATER_PERCENT|WATER_CONJURED|WATER_SPIRIT",
  [15] = "FOOD_STAMINA|FOOD_AGILITY|FOOD_MANAREGEN|FOOD_HPREGEN|FOOD_STRENGTH|FOOD_INTELLIGENCE|FOOD_SPELLPOWER|DRINK_STAMINA|FOOD_WATER",
  [17] = "SHARPENINGSTONES|WEIGHTSTONE|MANA_OIL|WIZARD_OIL",
  [19] = "HEARTHSTONE",
  [20] = "MOUNTS_TROLL|MOUNTS_ORC|MOUNTS_UNDEAD|MOUNTS_TAUREN|MOUNTS_HUMAN|MOUNTS_NIGHTELF|MOUNTS_DWARF|MOUNTS_GNOME|MOUNTS_SPECIAL|MOUNTS_QIRAJI",
  [21] = "EXPLOSIVES",
  [22] = "FISHINGITEMS",
  [23] = "HOURGLASS_SAND|BATTLE_STANDARD|BATTLE_STANDARD_AV",
  [24] = "QUESTUSEITEMS|QUESTSTARTITEMS",
}

local autoBarClassSlot3 = {
  WARRIOR = "RAGEPOTIONS",
  ROGUE = "ENERGYPOTIONS",
}

local autoBarManaSlot3 =
  "RUNES|MANAPOTIONS|PVP_MANAPOTIONS|ALTERAC_MANA|MANASTONE|TEAS"

local autoBarClassSlot18 = {
  ROGUE = "POISON-WOUND|POISON-CRIPPLING|POISON-AGITATING|POISON-MINDNUMBING|POISON-CORROSIVE|POISON-DEADLY|POISON-INSTANT|POISON-DISSOLVENT",
  HUNTER = "FOOD_PET_BREAD|FOOD_PET_CHEESE|FOOD_PET_FISH|FOOD_PET_FRUIT|FOOD_PET_FUNGUS|FOOD_PET_MEAT|ARROWS|BULLETS",
  WARLOCK = "SOULSHARDS",
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

local function SetTexCoord(texture, texcoord)
  texture:SetTexCoord(
    texcoord[1], texcoord[2], texcoord[3], texcoord[4]
  )
end

local function CreateDecorationFrame(parent)
  local frame = CreateFrame("Frame", nil, parent)
  frame:EnableMouse(false)
  if parent.GetFrameLevel and frame.SetFrameLevel then
    frame:SetFrameLevel(parent:GetFrameLevel())
  end
  return frame
end

local function CreatePocketDecorationFrame(button)
  local frame = CreateFrame("Frame", nil, button)
  frame:EnableMouse(false)
  frame:SetAllPoints(button)
  if button.GetFrameLevel and frame.SetFrameLevel then
    frame:SetFrameLevel(math.max(0, button:GetFrameLevel() - 1))
  end
  return frame
end

local function ConfigureNineSliceAnchors(frame, slices, cap)
  slices.topLeft:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  slices.topLeft:SetWidth(cap)
  slices.topLeft:SetHeight(cap)

  slices.top:SetPoint("TOPLEFT", frame, "TOPLEFT", cap, 0)
  slices.top:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -cap, -cap)

  slices.topRight:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  slices.topRight:SetWidth(cap)
  slices.topRight:SetHeight(cap)

  slices.left:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -cap)
  slices.left:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", cap, cap)

  slices.center:SetPoint("TOPLEFT", frame, "TOPLEFT", cap, -cap)
  slices.center:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -cap, cap)

  slices.right:SetPoint("TOPLEFT", frame, "TOPRIGHT", -cap, -cap)
  slices.right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, cap)

  slices.bottomLeft:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
  slices.bottomLeft:SetWidth(cap)
  slices.bottomLeft:SetHeight(cap)

  slices.bottom:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", cap, cap)
  slices.bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -cap, 0)

  slices.bottomRight:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  slices.bottomRight:SetWidth(cap)
  slices.bottomRight:SetHeight(cap)
end

local function EnsureNineSlice(frame, key, texturePath, texcoords, cap)
  local slices = frame[key]
  if not slices then
    slices = {}
    for _, name in ipairs(fieldKitSliceOrder) do
      local texture = frame:CreateTexture(nil, "BACKGROUND")
      texture:SetTexture(texturePath)
      SetTexCoord(texture, texcoords[name])
      texture:SetBlendMode("BLEND")
      texture:SetVertexColor(1, 1, 1, 1)
      slices[name] = texture
    end
    ConfigureNineSliceAnchors(frame, slices, cap)
    frame[key] = slices
  end
  return slices
end

local function SetNineSliceEnabled(slices, enabled)
  if not slices then
    return
  end
  for _, name in ipairs(fieldKitSliceOrder) do
    SetTextureEnabled(slices[name], enabled)
  end
end

local function ConfigureHorizontalConnector(frame, slices, cap)
  slices.start:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  slices.start:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
  slices.start:SetWidth(cap)

  slices.middle:SetPoint("TOPLEFT", frame, "TOPLEFT", cap, 0)
  slices.middle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -cap, 0)

  slices["end"]:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  slices["end"]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  slices["end"]:SetWidth(cap)
end

local function ConfigureVerticalConnector(frame, slices, cap)
  slices.start:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  slices.start:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  slices.start:SetHeight(cap)

  slices.middle:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -cap)
  slices.middle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, cap)

  slices["end"]:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
  slices["end"]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  slices["end"]:SetHeight(cap)
end

local function EnsureConnector(
  frame, key, texturePath, texcoords, orientation, cap
)
  local slices = frame[key]
  if not slices then
    slices = {}
    for _, name in ipairs(connectorSliceOrder) do
      local texture = frame:CreateTexture(nil, "BACKGROUND")
      texture:SetTexture(texturePath)
      SetTexCoord(texture, texcoords[name])
      texture:SetBlendMode("BLEND")
      texture:SetVertexColor(1, 1, 1, 1)
      slices[name] = texture
    end
    if orientation == "VERTICAL" then
      ConfigureVerticalConnector(frame, slices, cap)
    else
      ConfigureHorizontalConnector(frame, slices, cap)
    end
    frame[key] = slices
  end
  return slices
end

local function SetConnectorEnabled(slices, enabled)
  if not slices then
    return
  end
  for _, name in ipairs(connectorSliceOrder) do
    SetTextureEnabled(slices[name], enabled)
  end
end

local function ApplyPocket(
  button, key, texturePath, texcoord, sourceSize, enabled, padding
)
  if not button then
    return false
  end
  local holderKey = key .. "Holder"
  local holder = button[holderKey]
  if not holder then
    holder = CreatePocketDecorationFrame(button)
    button[holderKey] = holder
  elseif button.GetFrameLevel and holder.SetFrameLevel then
    holder:SetFrameLevel(math.max(0, button:GetFrameLevel() - 1))
  end
  local texture = button[key]
  if not texture then
    texture = holder:CreateTexture(nil, "BACKGROUND")
    texture:SetPoint("CENTER", button, "CENTER", 0, 0)
    texture:SetTexture(texturePath)
    SetTexCoord(texture, texcoord)
    texture:SetBlendMode("BLEND")
    texture:SetVertexColor(1, 1, 1, 1)
    button[key] = texture
  end
  if button.GetWidth and button.GetHeight then
    local maximumWidth = button:GetWidth() + padding * 2
    local maximumHeight = button:GetHeight() + padding * 2
    local scale = math.min(
      maximumWidth / sourceSize[1], maximumHeight / sourceSize[2]
    )
    texture:SetWidth(sourceSize[1] * scale)
    texture:SetHeight(sourceSize[2] * scale)
  end
  SetTextureEnabled(texture, enabled)
  return true
end

local function GetGlobal(name)
  if type(getglobal) == "function" then
    return getglobal(name)
  end
  if _G then
    return _G[name]
  end
  return nil
end

local function GetSystemUnitFont()
  local systemFont = GetGlobal("STANDARD_TEXT_FONT")
  if type(systemFont) == "string" and systemFont ~= "" then
    return systemFont
  end

  local gameFont = GetGlobal("GameFontNormal")
  if gameFont and type(gameFont.GetFont) == "function" then
    local ok, font = pcall(gameFont.GetFont, gameFont)
    if ok and type(font) == "string" and font ~= "" then
      return font
    end
  end

  if pfUI and type(pfUI.font_default) == "string" and
    pfUI.font_default ~= ""
  then
    return pfUI.font_default
  end
  local global = pfUI_config and pfUI_config.global
  if global and type(global.font_default) == "string" and
    global.font_default ~= ""
  then
    return global.font_default
  end
  return "Fonts\\FRIZQT__.TTF"
end

local function FontPathMatches(left, right)
  local function Normalize(path)
    return string.lower(string.gsub(tostring(path or ""), "/", "\\"))
  end
  return Normalize(left) == Normalize(right)
end

local function GetProviderNormalTexture(button)
  if not button or not button.GetName then
    return nil
  end
  local name = button:GetName()
  if not name then
    return nil
  end
  return GetGlobal(name .. "NormalTexture")
end

local function SetTrinketButtonNativeNormal(button, enabled)
  local texture = GetProviderNormalTexture(button)
  if not texture then
    return
  end
  if enabled then
    texture:Show()
  else
    texture:Hide()
  end
end

local function SetTrinketBackdrop(frame, useNative)
  if not frame or not frame.SetBackdrop then
    return
  end
  local state = useNative and "native" or "aeui"
  if frame.aeuiFieldKitBackdropState == state then
    return
  end
  if useNative then
    frame:SetBackdrop(nativeTrinketBackdrop)
    if frame.SetBackdropColor then
      frame:SetBackdropColor(1, 1, 1, 1)
    end
    if frame.SetBackdropBorderColor then
      frame:SetBackdropBorderColor(1, 1, 1, 1)
    end
  else
    frame:SetBackdrop(nil)
  end
  frame.aeuiFieldKitBackdropState = state
end

local function IsVisibleButton(button)
  return button and button.IsShown and button:IsShown() and
    not button.forceHidden and button.GetLeft and button:GetLeft() and
    button.GetRight and button:GetRight() and button.GetTop and
    button:GetTop() and button.GetBottom and button:GetBottom()
end

local function GetButtonExtremes(first, last, prefix)
  local result = {
    count = 0,
    left = nil,
    right = nil,
    top = nil,
    bottom = nil,
    leftValue = nil,
    rightValue = nil,
    topValue = nil,
    bottomValue = nil,
  }
  for index = first, last do
    local button = GetGlobal(prefix .. index)
    if IsVisibleButton(button) then
      local left = button:GetLeft()
      local right = button:GetRight()
      local top = button:GetTop()
      local bottom = button:GetBottom()
      result.count = result.count + 1
      if not result.leftValue or left < result.leftValue then
        result.leftValue = left
        result.left = button
      end
      if not result.rightValue or right > result.rightValue then
        result.rightValue = right
        result.right = button
      end
      if not result.topValue or top > result.topValue then
        result.topValue = top
        result.top = button
      end
      if not result.bottomValue or bottom < result.bottomValue then
        result.bottomValue = bottom
        result.bottom = button
      end
    end
  end
  return result
end

local function GetFrameScale(frame)
  if frame and frame.GetEffectiveScale then
    local scale = tonumber(frame:GetEffectiveScale())
    if scale and scale > 0 then
      return scale
    end
  end
  return 1
end

local function GetFrameCenter(frame)
  if not frame then
    return nil, nil
  end
  if frame.GetCenter then
    local x, y = frame:GetCenter()
    if x and y then
      return x, y
    end
  end
  if frame.GetLeft and frame.GetRight and
    frame.GetTop and frame.GetBottom
  then
    local left = frame:GetLeft()
    local right = frame:GetRight()
    local top = frame:GetTop()
    local bottom = frame:GetBottom()
    if left and right and top and bottom then
      return (left + right) / 2, (top + bottom) / 2
    end
  end
  return nil, nil
end

local function CaptureFrameAnchors(frame)
  if not frame or not frame.GetNumPoints or not frame.GetPoint then
    return nil
  end
  local points = {}
  for index = 1, frame:GetNumPoints() do
    points[index] = { frame:GetPoint(index) }
  end
  return points
end

local function RestoreFrameAnchors(frame, points)
  if not frame or not points or not frame.ClearAllPoints or
    not frame.SetPoint
  then
    return false
  end
  frame:ClearAllPoints()
  for index = 1, table.getn(points) do
    frame:SetPoint(unpack(points[index]))
  end
  return true
end

local function CaptureButtonLayout(button)
  local layout = { points = CaptureFrameAnchors(button) }
  if button and button.GetHitRectInsets then
    local left, right, top, bottom = button:GetHitRectInsets()
    layout.hitRect = { left, right, top, bottom }
  end
  return layout
end

local function RestoreButtonLayout(button, layout)
  if not button or not layout then
    return false
  end
  RestoreFrameAnchors(button, layout.points)
  if layout.hitRect and button.SetHitRectInsets then
    button:SetHitRectInsets(unpack(layout.hitRect))
  end
  return true
end

local function GetMainActionBarFrame()
  if pfUI and pfUI.bars and pfUI.bars[1] then
    return pfUI.bars[1]
  end
  return GetGlobal("pfActionBarMain")
end

local function GetTopActionBarFrame()
  if pfUI and pfUI.bars and pfUI.bars[6] then
    return pfUI.bars[6]
  end
  return GetGlobal("pfActionBarTop")
end

local function RoundCoordinate(value)
  if value < 0 then
    return math.ceil(value - 0.5)
  end
  return math.floor(value + 0.5)
end

local function SavePfUIPosition(name, anchor, x, y, scale)
  if not pfUI_config then
    return false
  end
  if type(pfUI_config.position) ~= "table" then
    pfUI_config.position = {}
  end
  local position = pfUI_config.position[name] or {}
  pfUI_config.position[name] = position
  position.xpos = RoundCoordinate(x)
  position.ypos = RoundCoordinate(y)
  position.anchor = anchor
  position.parent = "UIParent"
  if scale then
    position.scale = scale
  end
  return true
end

local function FocusPositionMatches(name, anchor, x, y, scale)
  local positions = pfUI_config and pfUI_config.position
  local position = positions and positions[name]
  x = tonumber(x)
  y = tonumber(y)
  scale = tonumber(scale)
  if type(position) ~= "table" or not x or not y or not scale then
    return false
  end
  return position.anchor == anchor and position.parent == "UIParent" and
    math.abs((tonumber(position.xpos) or 100000) - x) <= 1 and
    math.abs((tonumber(position.ypos) or 100000) - y) <= 1 and
    math.abs((tonumber(position.scale) or 100000) - scale) <= 0.001
end

local function FrameCoordinatePixels(frame, method)
  if not frame or not frame[method] then
    return nil
  end
  local value = frame[method](frame)
  if not value then
    return nil
  end
  return value * GetFrameScale(frame)
end

local function ApplyFramePosition(frame, anchor, x, y, scale)
  if not frame or not UIParent or not frame.ClearAllPoints or
    not frame.SetPoint
  then
    return false
  end
  if scale and frame.SetScale then
    frame:SetScale(scale)
  end
  frame:ClearAllPoints()
  frame:SetPoint(
    anchor, UIParent, anchor,
    RoundCoordinate(x), RoundCoordinate(y)
  )
  return true
end

local function CopyPlainTable(value, seen)
  if type(value) ~= "table" then
    return value
  end
  seen = seen or {}
  if seen[value] then
    return seen[value]
  end
  local result = {}
  seen[value] = result
  for key, item in pairs(value) do
    result[CopyPlainTable(key, seen)] = CopyPlainTable(item, seen)
  end
  return result
end

local focusPositionNames = {
  "pfActionBarMain",
  "pfActionBarTop",
  "pfPlayer",
  "pfTarget",
  "pfTargetTarget",
  "pfPlayerCastbar",
  "pfTargetCastbar",
  "pfSwingTimerMainhand",
  "pfSwingTimerRanged",
  "pfActionBarStances",
}

local function GetNativeFocusLayout()
  return {
    coordinateSpace = ActionBars.focusCoordinateSpace,
    deckX = ActionBars.combatDeckX,
    deckY = ActionBars.combatDeckY,
    playerX = ActionBars.focusPlayerX,
    playerY = ActionBars.focusUnitY,
    targetX = ActionBars.focusTargetX,
    targetY = ActionBars.focusUnitY,
    targetTargetX = ActionBars.focusTargetTargetX,
    targetTargetY = ActionBars.focusTargetTargetY,
    playerCastX = ActionBars.focusCastPlayerX,
    playerCastY = ActionBars.focusCastY,
    targetCastX = ActionBars.focusCastTargetX,
    targetCastY = ActionBars.focusTargetCastY,
    swingX = ActionBars.focusSwingX,
    swingY = ActionBars.focusSwingY,
    stanceX = ActionBars.focusStanceX,
    stanceY = ActionBars.focusStanceY,
    stanceScale = ActionBars.focusStanceScale,
    stanceIconSize = tonumber(ActionBars.focusStanceIconSize),
    doiteX = ActionBars.focusDoiteX,
    doiteY = ActionBars.focusDoiteY,
    unitFontRole = ActionBars.focusUnitFontRole,
    unitFontSize = ActionBars.focusUnitFontSize,
  }
end

local function CaptureField(source, key)
  if type(source) ~= "table" or source[key] == nil then
    return { present = false }
  end
  return {
    present = true,
    value = CopyPlainTable(source[key]),
  }
end

local function RestoreField(target, key, captured)
  if type(target) ~= "table" or type(captured) ~= "table" then
    return false
  end
  if captured.present then
    target[key] = CopyPlainTable(captured.value)
  else
    target[key] = nil
  end
  return true
end

local focusUnitDefaultPositionNames = {
  "pfPlayer",
  "pfTarget",
  "pfTargetTarget",
}

local function CaptureFocusUnitDefaultBackup(state)
  if type(state) ~= "table" or type(state.backup) == "table" then
    return false
  end
  local positions = pfUI_config and pfUI_config.position or {}
  local unitframes = pfUI_config and pfUI_config.unitframes or {}
  local backup = {
    version = ActionBars.focusUnitDefaultBackupVersion,
    positions = {},
    unitframes = {
      player = CaptureField(unitframes, "player"),
      target = CaptureField(unitframes, "target"),
      ttarget = CaptureField(unitframes, "ttarget"),
    },
  }
  for index = 1, table.getn(focusUnitDefaultPositionNames) do
    local name = focusUnitDefaultPositionNames[index]
    backup.positions[name] = CaptureField(positions, name)
  end
  state.backup = backup
  return true
end

local function GetCharacterProfileKey()
  if type(UnitName) ~= "function" or type(GetRealmName) ~= "function" then
    return nil
  end
  local name = UnitName("player")
  local realm = GetRealmName()
  if not name or name == "" or not realm or realm == "" then
    return nil
  end
  return tostring(name) .. " - " .. tostring(realm)
end

local function GetSideBarGroupProfileKey()
  return GetCharacterProfileKey()
end

local function GetFocusUnitDefaultState(create)
  local database = addon.db and addon.db.actionbars
  local profileKey = GetCharacterProfileKey()
  if not database or not profileKey then
    return nil, profileKey
  end
  if create and type(database.focusUnitDefaultProfiles) ~= "table" then
    database.focusUnitDefaultProfiles = {}
  end
  local profiles = database.focusUnitDefaultProfiles
  if type(profiles) ~= "table" then
    return nil, profileKey
  end
  if create and type(profiles[profileKey]) ~= "table" then
    profiles[profileKey] = {}
  end
  return profiles[profileKey], profileKey
end

local function FocusUnitDefaultLayoutActive()
  local state = GetFocusUnitDefaultState(false)
  return state and state.optOut ~= true and
    state.layoutVersion == ActionBars.focusUnitDefaultVersion
end

local function FocusUnitDefaultOptedOut()
  local state = GetFocusUnitDefaultState(false)
  return state and state.optOut == true
end

local function GetSideBarGroupState(create)
  local database = addon.db and addon.db.actionbars
  local profileKey = GetSideBarGroupProfileKey()
  if not database or not profileKey then
    return nil, profileKey
  end
  if create and type(database.sideBarGroupProfiles) ~= "table" then
    database.sideBarGroupProfiles = {}
  end
  local profiles = database.sideBarGroupProfiles
  if type(profiles) ~= "table" then
    return nil, profileKey
  end
  if create and type(profiles[profileKey]) ~= "table" then
    profiles[profileKey] = {}
  end
  return profiles[profileKey], profileKey
end

local function SideBarGroupBound()
  local state = GetSideBarGroupState(false)
  return state and state.bound == true
end

local function GetSideBarFrame(definition)
  local bars = pfUI and pfUI.bars
  return bars and bars[definition.index] or GetGlobal(definition.name)
end

local function SideBarPositionMatches(name, x, y, scale)
  local positions = pfUI_config and pfUI_config.position
  local position = positions and positions[name]
  return type(position) == "table" and
    position.anchor == "RIGHT" and position.parent == "UIParent" and
    math.abs((tonumber(position.xpos) or 100000) - x) <= 1 and
    math.abs((tonumber(position.ypos) or 100000) - y) <= 1 and
    math.abs((tonumber(position.scale) or 100000) - scale) <= 0.001
end

local function SideBarLegacyProfileMatches()
  if GetSideBarGroupProfileKey() ~= ActionBars.sideBarGroupAutoProfile or
    not pfUI_config or type(pfUI_config.bars) ~= "table"
  then
    return false
  end
  for index = 1, table.getn(sideBarGroupDefinitions) do
    local definition = sideBarGroupDefinitions[index]
    local config = pfUI_config.bars[definition.config]
    local position = sideBarLegacyPositions[definition.name]
    if type(config) ~= "table" or config.buttons ~= "12" or
      config.formfactor ~= "1 x 12" or config.icon_size ~= "20" or
      config.spacing ~= "1" or not position or
      not SideBarPositionMatches(
        definition.name, position.x, position.y,
        ActionBars.sideBarGroupScale
      )
    then
      return false
    end
  end
  return true
end

local function CaptureSideBarGroupBackup(state)
  if type(state) ~= "table" or not pfUI_config then
    return false
  end
  local bars = pfUI_config.bars or {}
  local positions = pfUI_config.position or {}
  local backup = {
    version = ActionBars.sideBarGroupBackupVersion,
    bars = {},
    positions = {},
  }
  for index = 1, table.getn(sideBarGroupDefinitions) do
    local definition = sideBarGroupDefinitions[index]
    local config = bars[definition.config] or {}
    backup.bars[definition.config] = {
      formfactor = CaptureField(config, "formfactor"),
      icon_size = CaptureField(config, "icon_size"),
      spacing = CaptureField(config, "spacing"),
    }
    backup.positions[definition.name] =
      CaptureField(positions, definition.name)
  end
  state.backup = backup
  return true
end

local function GetSideBarGroupScale()
  local positions = pfUI_config and pfUI_config.position
  local position = positions and positions.pfActionBarPaging
  local scale = position and tonumber(position.scale)
  local root = GetSideBarFrame(sideBarGroupDefinitions[1])
  if not scale and root and root.GetScale then
    scale = tonumber(root:GetScale())
  end
  return scale or ActionBars.sideBarGroupScale
end

local function SaveSideBarGroupHomePositions()
  local saved = 0
  for index = 1, table.getn(sideBarGroupDefinitions) do
    local definition = sideBarGroupDefinitions[index]
    if SavePfUIPosition(
      definition.name,
      "RIGHT",
      definition.homeX,
      definition.homeY,
      ActionBars.sideBarGroupScale
    ) then
      saved = saved + 1
    end
  end
  return saved == table.getn(sideBarGroupDefinitions)
end

local function ConfigureSideBarGroupProfile(resetHome)
  if not pfUI_config or type(pfUI_config.bars) ~= "table" then
    return false, false
  end
  for index = 1, table.getn(sideBarGroupDefinitions) do
    local definition = sideBarGroupDefinitions[index]
    local config = pfUI_config.bars[definition.config]
    if type(config) ~= "table" or tostring(config.buttons) ~= "12" then
      return false, false
    end
  end
  pfUI_config.position = pfUI_config.position or {}
  local changed = false
  if resetHome or not pfUI_config.position.pfActionBarPaging then
    SaveSideBarGroupHomePositions()
    changed = true
  end
  local scale = GetSideBarGroupScale()
  for index = 1, table.getn(sideBarGroupDefinitions) do
    local definition = sideBarGroupDefinitions[index]
    local config = pfUI_config.bars[definition.config]
    if config.formfactor ~= ActionBars.sideBarGroupFormFactor then
      config.formfactor = ActionBars.sideBarGroupFormFactor
      changed = true
    end
    if config.icon_size ~= ActionBars.sideBarGroupIconSize then
      config.icon_size = ActionBars.sideBarGroupIconSize
      changed = true
    end
    if config.spacing ~= ActionBars.sideBarGroupSpacing then
      config.spacing = ActionBars.sideBarGroupSpacing
      changed = true
    end
    local position = pfUI_config.position[definition.name]
    if type(position) ~= "table" then
      SavePfUIPosition(
        definition.name,
        "RIGHT",
        definition.homeX,
        definition.homeY,
        scale
      )
      changed = true
    elseif math.abs((tonumber(position.scale) or 0) - scale) > 0.001 then
      position.scale = scale
      changed = true
    end
  end
  return true, changed
end

function ActionBars:ApplySideBarGroupAnchors()
  if not SideBarGroupBound() then
    self.sideBarGroupStatus = "free"
    return false
  end
  local root = GetSideBarFrame(sideBarGroupDefinitions[1])
  local topRight = GetSideBarFrame(sideBarGroupDefinitions[2])
  local bottomLeft = GetSideBarFrame(sideBarGroupDefinitions[3])
  local bottomRight = GetSideBarFrame(sideBarGroupDefinitions[4])
  if not root or not topRight or not bottomLeft or not bottomRight then
    self.sideBarGroupStatus = "unavailable"
    return false
  end

  local scale = GetSideBarGroupScale()
  for _, frame in pairs({ root, topRight, bottomLeft, bottomRight }) do
    if frame.SetParent then
      frame:SetParent(UIParent)
    end
    if frame.SetScale then
      frame:SetScale(scale)
    end
  end
  topRight:ClearAllPoints()
  topRight:SetPoint(
    "TOPLEFT", root, "TOPRIGHT", self.sideBarGroupGap, 0
  )
  bottomLeft:ClearAllPoints()
  bottomLeft:SetPoint(
    "TOPLEFT", root, "BOTTOMLEFT", 0, -self.sideBarGroupGap
  )
  bottomRight:ClearAllPoints()
  bottomRight:SetPoint(
    "TOPLEFT", bottomLeft, "TOPRIGHT", self.sideBarGroupGap, 0
  )
  self.sideBarGroupStatus = "bound-6x8"
  return true
end

function ActionBars:SyncSideBarGroupScale()
  if not SideBarGroupBound() then
    return false
  end
  local root = GetSideBarFrame(sideBarGroupDefinitions[1])
  local scale = root and root.GetScale and tonumber(root:GetScale())
  if not scale then
    return false
  end
  pfUI_config.position = pfUI_config.position or {}
  for index = 1, table.getn(sideBarGroupDefinitions) do
    local definition = sideBarGroupDefinitions[index]
    local frame = GetSideBarFrame(definition)
    if frame and frame.SetScale then
      frame:SetScale(scale)
    end
    local position = pfUI_config.position[definition.name] or {}
    pfUI_config.position[definition.name] = position
    position.scale = scale
  end
  self:ApplySideBarGroupAnchors()
  return true
end

function ActionBars:PersistSideBarGroupPositions()
  if not SideBarGroupBound() or not pfUI_config then
    return false
  end
  local converted = {}
  local converter = pfUI and pfUI.api and pfUI.api.ConvertFrameAnchor
  if type(converter) ~= "function" then
    return false
  end
  local scale = GetSideBarGroupScale()
  for index = 1, table.getn(sideBarGroupDefinitions) do
    local definition = sideBarGroupDefinitions[index]
    local frame = GetSideBarFrame(definition)
    if not frame then
      return false
    end
    local ok, anchor, x, y = pcall(converter, frame, "RIGHT")
    if not ok or not anchor or not x or not y then
      return false
    end
    converted[index] = { anchor, x, y }
  end
  for index = 1, table.getn(sideBarGroupDefinitions) do
    local definition = sideBarGroupDefinitions[index]
    local position = converted[index]
    SavePfUIPosition(
      definition.name, position[1], position[2], position[3], scale
    )
  end
  self:ApplySideBarGroupAnchors()
  return true
end

function ActionBars:RefreshSideBarGroupBars()
  local bars = pfUI and pfUI.bars
  if not bars or type(bars.UpdateConfig) ~= "function" then
    self.sideBarGroupStatus = "unavailable"
    return false
  end
  self.sideBarGroupUpdating = true
  local ok = pcall(bars.UpdateConfig, bars)
  self.sideBarGroupUpdating = false
  self:ApplySideBarGroupAnchors()
  self:UpdateFieldKitUnlockMover()
  return ok
end

function ActionBars:MigrateSideBarGroupDefault()
  local state = GetSideBarGroupState(false)
  if state or not SideBarLegacyProfileMatches() then
    return false
  end
  state = GetSideBarGroupState(true)
  if not state then
    return false
  end
  CaptureSideBarGroupBackup(state)
  state.bound = true
  state.layoutVersion = self.sideBarGroupLayoutVersion
  state.migration = "exact-v11-profile"
  local configured = ConfigureSideBarGroupProfile(true)
  if configured then
    self:RefreshSideBarGroupBars()
    self.sideBarGroupMigration = "applied"
    return true
  end
  state.bound = false
  self.sideBarGroupMigration = "failed"
  return false
end

function ActionBars:MaintainSideBarGroup()
  if not SideBarGroupBound() then
    self.sideBarGroupStatus = "free"
    self:UpdateFieldKitUnlockMover()
    return false
  end
  local configured, changed = ConfigureSideBarGroupProfile(false)
  if not configured then
    self.sideBarGroupStatus = "signature-mismatch"
    return false
  end
  if changed and not self.sideBarGroupUpdating then
    return self:RefreshSideBarGroupBars()
  end
  self:ApplySideBarGroupAnchors()
  self:UpdateFieldKitUnlockMover()
  return true
end

function ActionBars:SetSideBarGroupBinding(bound)
  if type(InCombatLockdown) == "function" and InCombatLockdown() then
    self.sideBarGroupStatus = "combat-locked"
    return false, "Leave combat before changing the side-bar group."
  end
  if not pfUI_config or type(pfUI_config.bars) ~= "table" then
    self.sideBarGroupStatus = "unavailable"
    return false, "The pfUI character action-bar profile is unavailable."
  end
  local state, profileKey = GetSideBarGroupState(true)
  if not state then
    self.sideBarGroupStatus = "unavailable"
    return false, "The current character profile key is unavailable."
  end

  if bound then
    if not state.bound then
      CaptureSideBarGroupBackup(state)
      state.bound = true
      state.layoutVersion = self.sideBarGroupLayoutVersion
      state.migration = "manual"
      local configured = ConfigureSideBarGroupProfile(true)
      if not configured then
        state.bound = false
        self.sideBarGroupStatus = "signature-mismatch"
        return false, "All four side bars must contain 12 buttons."
      end
      self:RefreshSideBarGroupBars()
    else
      self:MaintainSideBarGroup()
    end
    return true,
      "Side bars grouped for " .. tostring(profileKey) ..
      ": Paging/Vertical over Left/Right, each 3x4, with one 6x8 mover. Per-bar content, keybind, paging, visibility, and autohide settings remain independent."
  end

  if not state.bound then
    self.sideBarGroupStatus = "free"
    return true, "The four side bars are already independent."
  end
  local backup = state.backup
  if type(backup) ~= "table" or
    backup.version ~= self.sideBarGroupBackupVersion
  then
    self.sideBarGroupStatus = "no-backup"
    return false, "No compatible pre-group side-bar backup exists."
  end
  state.bound = false
  local bars = pfUI_config.bars or {}
  pfUI_config.position = pfUI_config.position or {}
  for index = 1, table.getn(sideBarGroupDefinitions) do
    local definition = sideBarGroupDefinitions[index]
    local config = bars[definition.config]
    local savedConfig = backup.bars and backup.bars[definition.config]
    if type(config) == "table" and type(savedConfig) == "table" then
      RestoreField(config, "formfactor", savedConfig.formfactor)
      RestoreField(config, "icon_size", savedConfig.icon_size)
      RestoreField(config, "spacing", savedConfig.spacing)
    end
    RestoreField(
      pfUI_config.position,
      definition.name,
      backup.positions and backup.positions[definition.name]
    )
  end
  self:RefreshSideBarGroupBars()
  for index = 1, table.getn(sideBarGroupDefinitions) do
    local definition = sideBarGroupDefinitions[index]
    local frame = GetSideBarFrame(definition)
    if frame and pfUI and pfUI.api and
      type(pfUI.api.LoadMovable) == "function"
    then
      pcall(pfUI.api.LoadMovable, frame)
    end
  end
  self:UpdateFieldKitUnlockMover()
  self.sideBarGroupStatus = "free-restored"
  return true,
    "Side bars ungrouped; their pre-group form factors, spacing, scale, and positions were restored. Per-bar content changes made while grouped were kept."
end

function ActionBars:ResetSideBarGroupPosition()
  if type(InCombatLockdown) == "function" and InCombatLockdown() then
    return false, "Leave combat before resetting the side-bar group."
  end
  if not SideBarGroupBound() then
    return false, "Bind the four side bars before resetting their group home."
  end
  SaveSideBarGroupHomePositions()
  local root = GetSideBarFrame(sideBarGroupDefinitions[1])
  ApplyFramePosition(
    root,
    "RIGHT",
    sideBarGroupDefinitions[1].homeX,
    sideBarGroupDefinitions[1].homeY,
    self.sideBarGroupScale
  )
  self:SyncSideBarGroupScale()
  self:PersistSideBarGroupPositions()
  self:UpdateFieldKitUnlockMover()
  self.sideBarGroupStatus = "bound-6x8-home"
  return true,
    "The 6x8 side-bar group returned to its accepted right-side home."
end

local function CaptureCombatFocusBackup()
  local database = addon.db and addon.db.actionbars
  if not database or database.combatFocusBackup then
    return false
  end
  local positions = pfUI_config and pfUI_config.position or {}
  local bars = pfUI_config and pfUI_config.bars or {}
  local unitframes = pfUI_config and pfUI_config.unitframes or {}
  local castbars = pfUI_config and pfUI_config.castbar or {}
  local global = pfUI_config and pfUI_config.global or {}
  local backup = {
    version = ActionBars.focusLayoutBackupVersion,
    positions = {},
    bars = {
      bar11 = {
        icon_size = CaptureField(bars.bar11, "icon_size"),
      },
    },
    unitframes = {
      player = CaptureField(unitframes, "player"),
      target = CaptureField(unitframes, "target"),
      ttarget = CaptureField(unitframes, "ttarget"),
      swingtimerwidth = CaptureField(unitframes, "swingtimerwidth"),
      swingtimerheight = CaptureField(unitframes, "swingtimerheight"),
    },
    castbar = {
      player = CaptureField(castbars, "player"),
      target = CaptureField(castbars, "target"),
    },
    pixelperfect = CaptureField(global, "pixelperfect"),
    doitePresent = type(DoiteDPSDB) == "table",
    doite = {
      point = CaptureField(DoiteDPSDB, "point"),
      relativePoint = CaptureField(DoiteDPSDB, "relativePoint"),
      x = CaptureField(DoiteDPSDB, "x"),
      y = CaptureField(DoiteDPSDB, "y"),
      scale = CaptureField(DoiteDPSDB, "scale"),
    },
    actionbars = {
      fieldKitBound = CaptureField(database, "fieldKitBound"),
      consumableDocked = CaptureField(database, "consumableDocked"),
      trinketDocked = CaptureField(database, "trinketDocked"),
      combatDeckLayoutVersion =
        CaptureField(database, "combatDeckLayoutVersion"),
      combatFocusLayoutVersion =
        CaptureField(database, "combatFocusLayoutVersion"),
      combatFocusProjection =
        CaptureField(database, "combatFocusProjection"),
      comfortUIScaleVersion =
        CaptureField(database, "comfortUIScaleVersion"),
    },
  }
  for index = 1, table.getn(focusPositionNames) do
    local name = focusPositionNames[index]
    backup.positions[name] = CaptureField(positions, name)
  end
  local options = GetGlobal("ArchiTotem_Options")
  local appearance = type(options) == "table" and options.Apperance
  backup.archiDirection = CaptureField(appearance, "direction")
  database.combatFocusBackup = backup
  return true
end

local function UpgradeCombatFocusBackup()
  local database = addon.db and addon.db.actionbars
  local backup = database and database.combatFocusBackup
  if type(backup) ~= "table" or
    backup.version ~= ActionBars.focusLayoutBackupVersion
  then
    return false
  end

  local changed = false
  backup.positions = backup.positions or {}
  if backup.positions.pfTargetTarget == nil then
    local positions = pfUI_config and pfUI_config.position or {}
    backup.positions.pfTargetTarget =
      CaptureField(positions, "pfTargetTarget")
    changed = true
  end
  backup.bars = backup.bars or {}
  backup.bars.bar11 = backup.bars.bar11 or {}
  if backup.bars.bar11.icon_size == nil then
    local bars = pfUI_config and pfUI_config.bars or {}
    backup.bars.bar11.icon_size = CaptureField(
      bars.bar11, "icon_size"
    )
    changed = true
  end
  backup.unitframes = backup.unitframes or {}
  if backup.unitframes.ttarget == nil then
    local unitframes = pfUI_config and pfUI_config.unitframes or {}
    backup.unitframes.ttarget = CaptureField(unitframes, "ttarget")
    changed = true
  end
  return changed
end

local function CombatFocusLayoutActive()
  local database = addon.db and addon.db.actionbars
  local projection = database and database.combatFocusProjection
  return database and
    database.combatFocusLayoutVersion == ActionBars.focusLayoutVersion and
    type(projection) == "table" and
    projection.coordinateSpace == ActionBars.focusCoordinateSpace
end

local function FocusUnitLayoutActive()
  return FocusUnitDefaultLayoutActive() or CombatFocusLayoutActive()
end

local focusUnitFontStrings = {
  "hpLeftText",
  "hpRightText",
  "hpCenterText",
  "powerLeftText",
  "powerRightText",
  "powerCenterText",
  "infoTopCenterText",
}

local function GetFocusUnitFrame(key)
  local unitframes = pfUI and pfUI.uf
  if key == "ttarget" then
    return unitframes and unitframes.targettarget or
      GetGlobal("pfTargetTarget")
  elseif key == "player" then
    return unitframes and unitframes.player or GetGlobal("pfPlayer")
  elseif key == "target" then
    return unitframes and unitframes.target or GetGlobal("pfTarget")
  end
  return nil
end

local function ApplyLiveFocusUnitFont(frame)
  if not frame then
    return 0
  end
  local applied = 0
  local font = GetSystemUnitFont()
  for index = 1, table.getn(focusUnitFontStrings) do
    local fontString = frame[focusUnitFontStrings[index]]
    if fontString and type(fontString.SetFont) == "function" then
      local ok = pcall(
        fontString.SetFont,
        fontString,
        font,
        ActionBars.focusUnitFontSize,
        ActionBars.focusUnitFontStyle
      )
      if ok then
        applied = applied + 1
      end
    end
  end
  return applied
end

function ActionBars:ApplyFocusUnitFonts(force)
  if not force and not FocusUnitLayoutActive() then
    self.focusUnitFontLive = 0
    return 0
  end
  local applied = 0
  applied = applied + ApplyLiveFocusUnitFont(GetFocusUnitFrame("player"))
  applied = applied + ApplyLiveFocusUnitFont(GetFocusUnitFrame("target"))
  applied = applied + ApplyLiveFocusUnitFont(GetFocusUnitFrame("ttarget"))
  self.focusUnitFontLive = applied
  return applied
end

function ActionBars:InstallFocusUnitFontHooks()
  if type(hooksecurefunc) ~= "function" then
    return false
  end
  local installed = false
  for _, key in pairs({ "player", "target", "ttarget" }) do
    local frame = GetFocusUnitFrame(key)
    if frame and type(frame.UpdateConfig) == "function" and
      not frame.aeuiFocusUnitFontHookV1
    then
      local hookedFrame = frame
      frame.aeuiFocusUnitFontHookV1 = true
      hooksecurefunc(frame, "UpdateConfig", function()
        if not ActionBars.focusFontSuppressed and
          FocusUnitLayoutActive()
        then
          ApplyLiveFocusUnitFont(hookedFrame)
        end
      end)
      installed = true
    end
  end
  self.focusUnitFontHooks = installed or self.focusUnitFontHooks
  return installed
end

local function ShouldMigrateCombatFocusLayout()
  local database = addon.db and addon.db.actionbars
  local projection = database and database.combatFocusProjection
  local version = database and database.combatFocusLayoutVersion
  if not database or
    (version ~= 7 and version ~= 8 and version ~= 9 and version ~= 10 and
      version ~= 11 and version ~= 12 and version ~= 13 and
      version ~= 14 and version ~= 15 and version ~= 16 and
      version ~= 17) or
    type(projection) ~= "table" or
    projection.coordinateSpace ~= ActionBars.focusCoordinateSpace or
    not pfUI_config
  then
    return false
  end

  local unitframes = pfUI_config.unitframes or {}
  local castbars = pfUI_config.castbar or {}
  local bars = pfUI_config.bars or {}
  local positions = pfUI_config.position or {}
  local mainPosition = positions.pfActionBarMain
  local player = unitframes.player or {}
  local target = unitframes.target or {}
  local targetTarget = unitframes.ttarget or {}
  local playerCast = castbars.player or {}
  local targetCast = castbars.target or {}
  local stanceConfig = bars.bar11 or {}
  local oldDoiteX =
    (version == 15 or version == 16 or version == 17) and 650 or
    ((version == 9 or version == 10 or version == 11 or version == 12 or
      version == 13 or version == 14) and 850 or 1012)
  local oldDoiteY = version == 8 and -780 or
    ((version == 13 or version == 14 or version == 15 or version == 16 or
      version == 17) and
      -615 or -647)
  local doiteMatches = type(DoiteDPSDB) ~= "table" or
    (DoiteDPSDB.point == "TOPLEFT" and
      DoiteDPSDB.relativePoint == "TOPLEFT" and
      math.abs((tonumber(DoiteDPSDB.x) or 100000) - oldDoiteX) <= 0.01 and
      math.abs((tonumber(DoiteDPSDB.y) or 100000) - oldDoiteY) <= 0.01 and
      math.abs((tonumber(DoiteDPSDB.scale) or 100000) - 0.82) <= 0.001)
  local deckMatches = type(mainPosition) == "table" and
    mainPosition.anchor == "BOTTOM" and
    mainPosition.parent == "UIParent" and
    math.abs((tonumber(mainPosition.xpos) or 100000) - 0) <= 1 and
    math.abs((tonumber(mainPosition.ypos) or 100000) - 175) <= 1
  local archiOptions = GetGlobal("ArchiTotem_Options")
  local archiAppearance = type(archiOptions) == "table" and
    archiOptions.Apperance
  local archiMatches = type(archiAppearance) ~= "table" or
    archiAppearance.direction == "down"

  if database.fieldKitBound ~= true or not deckMatches or
    not archiMatches or not doiteMatches
  then
    return false
  end

  if version == 7 then
    return FocusPositionMatches(
        "pfPlayer", "BOTTOM", -212, 492, 0.75
      ) and FocusPositionMatches(
        "pfTarget", "BOTTOM", 213, 492, 0.75
      ) and FocusPositionMatches(
        "pfPlayerCastbar", "BOTTOM", -212, 454, 0.75
      ) and FocusPositionMatches(
        "pfTargetCastbar", "BOTTOM", 213, 454, 0.75
      ) and FocusPositionMatches(
        "pfSwingTimerMainhand", "CENTER", 0, -67, 0.82
      ) and FocusPositionMatches(
        "pfSwingTimerRanged", "CENTER", 0, -67, 0.82
      ) and FocusPositionMatches(
        "pfActionBarStances", "TOP", 0, -919, 0.82
      ) and player.width == "280" and player.height == "72" and
      player.buffs == "TOPLEFT" and player.debuffs == "TOPRIGHT" and
      player.buffperrow == "6" and player.debuffperrow == "6" and
      target.width == "280" and target.height == "72" and
      target.buffs == "TOPLEFT" and target.debuffs == "TOPRIGHT" and
      target.buffperrow == "6" and target.debuffperrow == "6" and
      playerCast.width == "-1" and playerCast.height == "22" and
      targetCast.width == "-1" and targetCast.height == "22" and
      unitframes.swingtimerwidth == "200" and
      unitframes.swingtimerheight == "12"
  end

  local function AuraOffsetsMatch(config)
    return tostring(config.buffoffx) == "0" and
      tostring(config.buffoffy) == "0" and
      tostring(config.debuffoffx) == "0" and
      tostring(config.debuffoffy) == "0"
  end

  if version == 8 then
    return FocusPositionMatches(
      "pfPlayer", "BOTTOM", -190, 500, 0.68
    ) and FocusPositionMatches(
      "pfTarget", "BOTTOM", 190, 500, 0.68
    ) and FocusPositionMatches(
      "pfTargetTarget", "BOTTOM", 414, 500, 0.62
    ) and FocusPositionMatches(
      "pfPlayerCastbar", "BOTTOM", -196, 430, 0.72
    ) and FocusPositionMatches(
      "pfTargetCastbar", "BOTTOM", 196, 430, 0.72
    ) and FocusPositionMatches(
      "pfSwingTimerMainhand", "BOTTOM", 0, 430, 0.72
    ) and FocusPositionMatches(
      "pfSwingTimerRanged", "BOTTOM", 0, 430, 0.72
    ) and FocusPositionMatches(
      "pfActionBarStances", "BOTTOM", 0, 255, 0.72
    ) and player.width == "240" and player.height == "60" and
    player.buffs == "TOPLEFT" and player.debuffs == "BOTTOMLEFT" and
    player.buffsize == "18" and player.debuffsize == "18" and
    player.buffperrow == "8" and player.debuffperrow == "8" and
    AuraOffsetsMatch(player) and
    target.width == "240" and target.height == "60" and
    target.buffs == "TOPRIGHT" and target.debuffs == "BOTTOMRIGHT" and
    target.buffsize == "18" and target.debuffsize == "18" and
    target.buffperrow == "8" and target.debuffperrow == "8" and
    AuraOffsetsMatch(target) and
    targetTarget.width == "132" and targetTarget.height == "30" and
    targetTarget.buffs == "TOPRIGHT" and
    targetTarget.debuffs == "BOTTOMRIGHT" and
    targetTarget.buffsize == "14" and
    targetTarget.debuffsize == "14" and
    targetTarget.buffperrow == "8" and
    targetTarget.debuffperrow == "8" and
    AuraOffsetsMatch(targetTarget) and
    playerCast.width == "180" and playerCast.height == "16" and
    targetCast.width == "180" and targetCast.height == "16" and
      unitframes.swingtimerwidth == "180" and
      unitframes.swingtimerheight == "16"
  end

  local function DefaultUnitFontMatches(config)
    return tostring(config.customfont) == "0" and
      tostring(config.customfont_size) == "12"
  end

  local function ConfiguredUnitFontMatches(config)
    return tostring(config.customfont) == "1" and
      tostring(config.customfont_size) == "14"
  end

  local function Version12UnitFontMatches(config)
    local global = pfUI_config.global or {}
    return ConfiguredUnitFontMatches(config) and
      FontPathMatches(config.customfont_name, global.font_unit) and
      tostring(config.customfont_style or "OUTLINE") ==
        tostring(global.font_unit_style or "OUTLINE")
  end

  local function SystemUnitFontMatches(config)
    return tostring(config.customfont) == "1" and
      tostring(config.customfont_size) == "18" and
      FontPathMatches(config.customfont_name, GetSystemUnitFont()) and
      tostring(config.customfont_style or "OUTLINE") == "OUTLINE"
  end

  -- ApplyFocusUnitDefaults runs before this migration and upgrades the exact
  -- v17 primary frames to the new outward 16x2 contract. Match that upgraded
  -- unit subset together with the untouched v17 readout/deck signature, then
  -- persist the complete layout as v18.
  if version == 17 then
    return FocusPositionMatches(
        "pfPlayer", "BOTTOM", ActionBars.focusPlayerX,
        ActionBars.focusUnitY, ActionBars.focusUnitScale
      ) and FocusPositionMatches(
        "pfTarget", "BOTTOM", ActionBars.focusTargetX,
        ActionBars.focusUnitY, ActionBars.focusUnitScale
      ) and FocusPositionMatches(
        "pfTargetTarget", "BOTTOM", ActionBars.focusTargetTargetX,
        ActionBars.focusTargetTargetY,
        ActionBars.focusTargetTargetScale
      ) and FocusPositionMatches(
        "pfPlayerCastbar", "BOTTOM", 0, 316, 1
      ) and FocusPositionMatches(
        "pfTargetCastbar", "BOTTOM", 0, 300, 1
      ) and FocusPositionMatches(
        "pfSwingTimerMainhand", "BOTTOM", 0, 284, 1
      ) and FocusPositionMatches(
        "pfSwingTimerRanged", "BOTTOM", 0, 284, 1
      ) and FocusPositionMatches(
        "pfActionBarStances", "BOTTOM", 0, 255, 1
      ) and stanceConfig.icon_size == ActionBars.focusStanceIconSize and
      player.width == tostring(ActionBars.focusUnitWidth) and
      player.height == tostring(ActionBars.focusUnitHeight) and
      player.buffs == "TOPRIGHT" and
      player.debuffs == "BOTTOMRIGHT" and
      player.buffsize == tostring(ActionBars.focusAuraSize) and
      player.debuffsize == tostring(ActionBars.focusAuraSize) and
      player.buffperrow == tostring(ActionBars.focusAuraPerRow) and
      player.debuffperrow == tostring(ActionBars.focusAuraPerRow) and
      AuraOffsetsMatch(player) and SystemUnitFontMatches(player) and
      target.width == tostring(ActionBars.focusUnitWidth) and
      target.height == tostring(ActionBars.focusUnitHeight) and
      target.buffs == "TOPLEFT" and
      target.debuffs == "BOTTOMLEFT" and
      target.buffsize == tostring(ActionBars.focusAuraSize) and
      target.debuffsize == tostring(ActionBars.focusAuraSize) and
      target.buffperrow == tostring(ActionBars.focusAuraPerRow) and
      target.debuffperrow == tostring(ActionBars.focusAuraPerRow) and
      AuraOffsetsMatch(target) and SystemUnitFontMatches(target) and
      targetTarget.width ==
        tostring(ActionBars.focusTargetTargetWidth) and
      targetTarget.height ==
        tostring(ActionBars.focusTargetTargetHeight) and
      targetTarget.buffs == "TOPLEFT" and
      targetTarget.debuffs == "BOTTOMLEFT" and
      targetTarget.buffsize ==
        tostring(ActionBars.focusTargetTargetAuraSize) and
      targetTarget.debuffsize ==
        tostring(ActionBars.focusTargetTargetAuraSize) and
      targetTarget.buffperrow ==
        tostring(ActionBars.focusTargetTargetAuraPerRow) and
      targetTarget.debuffperrow ==
        tostring(ActionBars.focusTargetTargetAuraPerRow) and
      AuraOffsetsMatch(targetTarget) and
      SystemUnitFontMatches(targetTarget) and
      playerCast.width == tostring(ActionBars.focusReadoutWidth) and
      playerCast.height == tostring(ActionBars.focusReadoutHeight) and
      targetCast.width == tostring(ActionBars.focusReadoutWidth) and
      targetCast.height == tostring(ActionBars.focusReadoutHeight) and
      unitframes.swingtimerwidth ==
        tostring(ActionBars.focusReadoutWidth) and
      unitframes.swingtimerheight ==
        tostring(ActionBars.focusReadoutHeight)
  end

  if version == 12 or version == 13 or version == 14 or version == 15 or
    version == 16
  then
    local function ExpectedUnitFontMatches(config)
      if version == 13 or version == 14 or version == 15 or version == 16 then
        return SystemUnitFontMatches(config)
      end
      return Version12UnitFontMatches(config)
    end
    local upgradedStance = version == 15 or version == 16
    local stanceScale = upgradedStance and 1 or 0.72
    local stanceIconMatches = not upgradedStance or
      (version == 15 and (
        stanceConfig.icon_size == "18" or
        stanceConfig.icon_size == "25"
      )) or
      (version == 16 and stanceConfig.icon_size == "25")
    return FocusPositionMatches(
        "pfPlayer", "BOTTOM", -160, 485, 0.8
      ) and FocusPositionMatches(
        "pfTarget", "BOTTOM", 105, 485, 0.8
      ) and FocusPositionMatches(
        "pfTargetTarget", "BOTTOM", 393, 576, 0.68
      ) and FocusPositionMatches(
        "pfPlayerCastbar", "BOTTOM", 0, 316, 1
      ) and FocusPositionMatches(
        "pfTargetCastbar", "BOTTOM", 0, 300, 1
      ) and FocusPositionMatches(
        "pfSwingTimerMainhand", "BOTTOM", 0, 284, 1
      ) and FocusPositionMatches(
        "pfSwingTimerRanged", "BOTTOM", 0, 284, 1
      ) and FocusPositionMatches(
        "pfActionBarStances", "BOTTOM", 0, 255, stanceScale
      ) and player.width == "240" and player.height == "60" and
      player.buffs == "TOPLEFT" and player.debuffs == "BOTTOMLEFT" and
      player.buffsize == "23" and player.debuffsize == "23" and
      player.buffperrow == "8" and player.debuffperrow == "8" and
      AuraOffsetsMatch(player) and ExpectedUnitFontMatches(player) and
      target.width == "240" and target.height == "60" and
      target.buffs == "TOPRIGHT" and target.debuffs == "BOTTOMRIGHT" and
      target.buffsize == "23" and target.debuffsize == "23" and
      target.buffperrow == "8" and target.debuffperrow == "8" and
      AuraOffsetsMatch(target) and ExpectedUnitFontMatches(target) and
      targetTarget.width == "240" and targetTarget.height == "60" and
      targetTarget.buffs == "TOPRIGHT" and
      targetTarget.debuffs == "BOTTOMRIGHT" and
      targetTarget.buffsize == "23" and
      targetTarget.debuffsize == "23" and
      targetTarget.buffperrow == "8" and
      targetTarget.debuffperrow == "8" and
      AuraOffsetsMatch(targetTarget) and
      ExpectedUnitFontMatches(targetTarget) and
      playerCast.width == "260" and playerCast.height == "12" and
      targetCast.width == "260" and targetCast.height == "12" and
      unitframes.swingtimerwidth == "260" and
      unitframes.swingtimerheight == "12" and stanceIconMatches
  end

  if version == 11 then
    return FocusPositionMatches(
        "pfPlayer", "BOTTOM", -160, 455, 0.8
      ) and FocusPositionMatches(
        "pfTarget", "BOTTOM", 105, 455, 0.8
      ) and FocusPositionMatches(
        "pfTargetTarget", "BOTTOM", 393, 541, 0.68
      ) and FocusPositionMatches(
        "pfPlayerCastbar", "BOTTOM", 0, 316, 1
      ) and FocusPositionMatches(
        "pfTargetCastbar", "BOTTOM", 0, 300, 1
      ) and FocusPositionMatches(
        "pfSwingTimerMainhand", "BOTTOM", 0, 284, 1
      ) and FocusPositionMatches(
        "pfSwingTimerRanged", "BOTTOM", 0, 284, 1
      ) and FocusPositionMatches(
        "pfActionBarStances", "BOTTOM", 0, 255, 0.72
      ) and player.width == "240" and player.height == "60" and
      player.buffs == "TOPLEFT" and player.debuffs == "BOTTOMLEFT" and
      player.buffsize == "27" and player.debuffsize == "27" and
      player.buffperrow == "8" and player.debuffperrow == "8" and
      AuraOffsetsMatch(player) and ConfiguredUnitFontMatches(player) and
      target.width == "240" and target.height == "60" and
      target.buffs == "TOPRIGHT" and target.debuffs == "BOTTOMRIGHT" and
      target.buffsize == "27" and target.debuffsize == "27" and
      target.buffperrow == "8" and target.debuffperrow == "8" and
      AuraOffsetsMatch(target) and ConfiguredUnitFontMatches(target) and
      targetTarget.width == "240" and targetTarget.height == "60" and
      targetTarget.buffs == "TOPRIGHT" and
      targetTarget.debuffs == "BOTTOMRIGHT" and
      targetTarget.buffsize == "27" and
      targetTarget.debuffsize == "27" and
      targetTarget.buffperrow == "8" and
      targetTarget.debuffperrow == "8" and
      AuraOffsetsMatch(targetTarget) and
      ConfiguredUnitFontMatches(targetTarget) and
      playerCast.width == "260" and playerCast.height == "12" and
      targetCast.width == "260" and targetCast.height == "12" and
      unitframes.swingtimerwidth == "260" and
      unitframes.swingtimerheight == "12"
  end

  if version == 10 then
    local oldScaleSignature = FocusPositionMatches(
        "pfPlayer", "BOTTOM", -160, 535, 0.68
      ) and FocusPositionMatches(
        "pfTarget", "BOTTOM", 105, 535, 0.68
      ) and FocusPositionMatches(
        "pfPlayerCastbar", "BOTTOM", 0, 443, 0.72
      ) and FocusPositionMatches(
        "pfTargetCastbar", "BOTTOM", 0, 423, 0.72
      ) and FocusPositionMatches(
        "pfSwingTimerMainhand", "BOTTOM", 0, 403, 0.72
      ) and FocusPositionMatches(
        "pfSwingTimerRanged", "BOTTOM", 0, 403, 0.72
      )
    local userScaleSignature = FocusPositionMatches(
        "pfPlayer", "BOTTOM", -160, 535, 0.8
      ) and FocusPositionMatches(
        "pfTarget", "BOTTOM", 105, 535, 0.8
      ) and FocusPositionMatches(
        "pfPlayerCastbar", "BOTTOM", 0, 443, 1
      ) and FocusPositionMatches(
        "pfTargetCastbar", "BOTTOM", 0, 423, 1
      ) and FocusPositionMatches(
        "pfSwingTimerMainhand", "BOTTOM", 0, 403, 1
      ) and FocusPositionMatches(
        "pfSwingTimerRanged", "BOTTOM", 0, 403, 1
      )
    return (oldScaleSignature or userScaleSignature) and
      FocusPositionMatches(
        "pfTargetTarget", "BOTTOM", 353, 535, 0.68
      ) and FocusPositionMatches(
        "pfActionBarStances", "BOTTOM", 0, 255, 0.72
      ) and player.width == "240" and player.height == "60" and
      player.buffs == "TOPLEFT" and player.debuffs == "BOTTOMLEFT" and
      player.buffsize == "27" and player.debuffsize == "27" and
      player.buffperrow == "8" and player.debuffperrow == "8" and
      AuraOffsetsMatch(player) and ConfiguredUnitFontMatches(player) and
      target.width == "240" and target.height == "60" and
      target.buffs == "TOPRIGHT" and target.debuffs == "BOTTOMRIGHT" and
      target.buffsize == "27" and target.debuffsize == "27" and
      target.buffperrow == "8" and target.debuffperrow == "8" and
      AuraOffsetsMatch(target) and ConfiguredUnitFontMatches(target) and
      targetTarget.width == "240" and targetTarget.height == "60" and
      targetTarget.buffs == "TOPRIGHT" and
      targetTarget.debuffs == "BOTTOMRIGHT" and
      targetTarget.buffsize == "27" and
      targetTarget.debuffsize == "27" and
      targetTarget.buffperrow == "8" and
      targetTarget.debuffperrow == "8" and
      AuraOffsetsMatch(targetTarget) and
      ConfiguredUnitFontMatches(targetTarget) and
      playerCast.width == "260" and playerCast.height == "12" and
      targetCast.width == "260" and targetCast.height == "12" and
      unitframes.swingtimerwidth == "260" and
      unitframes.swingtimerheight == "12"
  end

  return FocusPositionMatches(
      "pfPlayer", "BOTTOM", -150, 535, 0.68
    ) and FocusPositionMatches(
      "pfTarget", "BOTTOM", 190, 535, 0.68
    ) and FocusPositionMatches(
      "pfTargetTarget", "BOTTOM", 190, 651, 0.68
    ) and FocusPositionMatches(
      "pfPlayerCastbar", "BOTTOM", -100, 443, 0.72
    ) and FocusPositionMatches(
      "pfTargetCastbar", "BOTTOM", 100, 443, 0.72
    ) and FocusPositionMatches(
      "pfSwingTimerMainhand", "BOTTOM", 0, 421, 0.72
    ) and FocusPositionMatches(
      "pfSwingTimerRanged", "BOTTOM", 0, 421, 0.72
    ) and FocusPositionMatches(
      "pfActionBarStances", "BOTTOM", 0, 255, 0.72
    ) and player.width == "240" and player.height == "60" and
    player.buffs == "TOPLEFT" and player.debuffs == "BOTTOMLEFT" and
    player.buffsize == "22" and player.debuffsize == "22" and
    player.buffperrow == "8" and player.debuffperrow == "8" and
    AuraOffsetsMatch(player) and DefaultUnitFontMatches(player) and
    target.width == "240" and target.height == "60" and
    target.buffs == "TOPRIGHT" and target.debuffs == "BOTTOMRIGHT" and
    target.buffsize == "22" and target.debuffsize == "22" and
    target.buffperrow == "8" and target.debuffperrow == "8" and
    AuraOffsetsMatch(target) and DefaultUnitFontMatches(target) and
    targetTarget.width == "240" and targetTarget.height == "60" and
    targetTarget.buffs == "TOPRIGHT" and
    targetTarget.debuffs == "BOTTOMRIGHT" and
    targetTarget.buffsize == "22" and
    targetTarget.debuffsize == "22" and
    targetTarget.buffperrow == "8" and
    targetTarget.debuffperrow == "8" and
    AuraOffsetsMatch(targetTarget) and
    DefaultUnitFontMatches(targetTarget) and
    playerCast.width == "180" and playerCast.height == "16" and
    targetCast.width == "180" and targetCast.height == "16" and
    unitframes.swingtimerwidth == "180" and
    unitframes.swingtimerheight == "16"
end

local function CombatFocusLayoutSaved()
  if not pfUI_config or not CombatFocusLayoutActive() then
    return false
  end
  local database = addon.db and addon.db.actionbars
  local projection = database and database.combatFocusProjection
  if type(projection) ~= "table" or
    projection.coordinateSpace ~= ActionBars.focusCoordinateSpace
  then
    return false
  end
  local layout = GetNativeFocusLayout()
  local unitframes = pfUI_config.unitframes or {}
  local castbars = pfUI_config.castbar or {}
  local bars = pfUI_config.bars or {}
  local stanceConfig = bars.bar11 or {}
  local player = unitframes.player or {}
  local target = unitframes.target or {}
  local targetTarget = unitframes.ttarget or {}
  local playerCast = castbars.player or {}
  local targetCast = castbars.target or {}
  local doiteMatches = type(DoiteDPSDB) ~= "table" or
    (DoiteDPSDB.point == "TOPLEFT" and
      DoiteDPSDB.relativePoint == "TOPLEFT" and
      math.abs((tonumber(DoiteDPSDB.x) or 100000) -
        layout.doiteX) <= 0.01 and
      math.abs((tonumber(DoiteDPSDB.y) or 100000) -
        layout.doiteY) <= 0.01 and
      math.abs((tonumber(DoiteDPSDB.scale) or 100000) -
        ActionBars.focusDoiteScale) <= 0.001)
  local function UnitFontConfigured(config)
    return config.customfont == "1" and
      config.customfont_size == tostring(ActionBars.focusUnitFontSize) and
      FontPathMatches(config.customfont_name, GetSystemUnitFont()) and
      config.customfont_style == ActionBars.focusUnitFontStyle
  end

  return FocusPositionMatches(
      "pfPlayer", "BOTTOM", layout.playerX, layout.playerY,
      ActionBars.focusUnitScale
    ) and FocusPositionMatches(
      "pfTarget", "BOTTOM", layout.targetX, layout.targetY,
      ActionBars.focusUnitScale
    ) and FocusPositionMatches(
      "pfTargetTarget", "BOTTOM", layout.targetTargetX,
      layout.targetTargetY, ActionBars.focusTargetTargetScale
    ) and FocusPositionMatches(
      "pfPlayerCastbar", "BOTTOM", layout.playerCastX,
      layout.playerCastY, ActionBars.focusReadoutScale
    ) and FocusPositionMatches(
      "pfTargetCastbar", "BOTTOM", layout.targetCastX,
      layout.targetCastY, ActionBars.focusReadoutScale
    ) and FocusPositionMatches(
      "pfSwingTimerMainhand", "BOTTOM", layout.swingX,
      layout.swingY, ActionBars.focusReadoutScale
    ) and FocusPositionMatches(
      "pfSwingTimerRanged", "BOTTOM", layout.swingX,
      layout.swingY, ActionBars.focusReadoutScale
    ) and FocusPositionMatches(
      "pfActionBarStances", "BOTTOM", layout.stanceX,
      layout.stanceY, ActionBars.focusStanceScale
    ) and stanceConfig.icon_size == ActionBars.focusStanceIconSize and
    player.width == tostring(ActionBars.focusUnitWidth) and
    player.height == tostring(ActionBars.focusUnitHeight) and
    player.buffs == "TOPRIGHT" and player.debuffs == "BOTTOMRIGHT" and
    player.buffsize == tostring(ActionBars.focusAuraSize) and
    player.debuffsize == tostring(ActionBars.focusAuraSize) and
    player.buffoffx == "0" and player.buffoffy == "0" and
    player.debuffoffx == "0" and player.debuffoffy == "0" and
    player.buffperrow == tostring(ActionBars.focusAuraPerRow) and
    player.debuffperrow == tostring(ActionBars.focusAuraPerRow) and
    UnitFontConfigured(player) and
    target.width == tostring(ActionBars.focusUnitWidth) and
    target.height == tostring(ActionBars.focusUnitHeight) and
    target.buffs == "TOPLEFT" and target.debuffs == "BOTTOMLEFT" and
    target.buffsize == tostring(ActionBars.focusAuraSize) and
    target.debuffsize == tostring(ActionBars.focusAuraSize) and
    target.buffoffx == "0" and target.buffoffy == "0" and
    target.debuffoffx == "0" and target.debuffoffy == "0" and
    target.buffperrow == tostring(ActionBars.focusAuraPerRow) and
    target.debuffperrow == tostring(ActionBars.focusAuraPerRow) and
    UnitFontConfigured(target) and
    targetTarget.width == tostring(ActionBars.focusTargetTargetWidth) and
    targetTarget.height == tostring(ActionBars.focusTargetTargetHeight) and
    targetTarget.buffs == "TOPLEFT" and
    targetTarget.debuffs == "BOTTOMLEFT" and
    targetTarget.buffsize ==
      tostring(ActionBars.focusTargetTargetAuraSize) and
    targetTarget.debuffsize ==
      tostring(ActionBars.focusTargetTargetAuraSize) and
    targetTarget.buffoffx == "0" and targetTarget.buffoffy == "0" and
    targetTarget.debuffoffx == "0" and
    targetTarget.debuffoffy == "0" and
    targetTarget.buffperrow ==
      tostring(ActionBars.focusTargetTargetAuraPerRow) and
    targetTarget.debuffperrow ==
      tostring(ActionBars.focusTargetTargetAuraPerRow) and
    UnitFontConfigured(targetTarget) and
    playerCast.width == tostring(ActionBars.focusReadoutWidth) and
    playerCast.height == tostring(ActionBars.focusReadoutHeight) and
    targetCast.width == tostring(ActionBars.focusReadoutWidth) and
    targetCast.height == tostring(ActionBars.focusReadoutHeight) and
    unitframes.swingtimerwidth ==
      tostring(ActionBars.focusReadoutWidth) and
    unitframes.swingtimerheight ==
      tostring(ActionBars.focusReadoutHeight) and doiteMatches
end

local function ComfortUIScaleConfigured()
  local global = pfUI_config and pfUI_config.global
  return global and tonumber(global.pixelperfect) ==
    ActionBars.comfortUIScaleTier
end

local function ApplyComfortUIScaleValue()
  local updated = false
  if pfUI and pfUI.pixelperfect and
    type(pfUI.pixelperfect.UpdateConfig) == "function"
  then
    updated = pcall(pfUI.pixelperfect.UpdateConfig)
  end
  if not updated then
    if type(SetCVar) == "function" then
      SetCVar("uiScale", ActionBars.comfortUIScaleValue)
      SetCVar("useUiScale", 1)
    end
    if UIParent and UIParent.SetScale then
      UIParent:SetScale(ActionBars.comfortUIScaleValue)
      updated = true
    end
  end
  return updated
end

local function ConfigureFocusUnitFrame(
  key, name, x, y, scale, width, height, buffs, debuffs, auraSize,
  auraPerRow
)
  local unitframes = pfUI_config and pfUI_config.unitframes
  local config = unitframes and unitframes[key]
  if type(config) ~= "table" then
    return false, false
  end

  config.visible = "1"
  config.width = tostring(width)
  config.height = tostring(height)
  config.buffs = buffs
  config.debuffs = debuffs
  config.buffsize = tostring(auraSize)
  config.debuffsize = tostring(auraSize)
  config.buffoffx = "0"
  config.buffoffy = "0"
  config.debuffoffx = "0"
  config.debuffoffy = "0"
  config.buffperrow = tostring(auraPerRow)
  config.debuffperrow = tostring(auraPerRow)
  config.customfont = "1"
  config.customfont_name = GetSystemUnitFont()
  config.customfont_size = tostring(ActionBars.focusUnitFontSize)
  config.customfont_style = ActionBars.focusUnitFontStyle

  local saved = SavePfUIPosition(
    name, "BOTTOM", x, y, scale
  )
  local frame = GetFocusUnitFrame(key) or GetGlobal(name)
  if frame and type(frame.UpdateFrameSize) == "function" then
    pcall(frame.UpdateFrameSize, frame)
  end
  if frame and type(frame.UpdateConfig) == "function" then
    pcall(frame.UpdateConfig, frame)
  end
  ApplyLiveFocusUnitFont(frame)
  local applied = ApplyFramePosition(
    frame, "BOTTOM", x, y, scale
  )
  return saved, applied
end

function ActionBars:ApplyFocusUnitDefaults()
  if type(InCombatLockdown) == "function" and InCombatLockdown() then
    self.focusUnitDefaultStatus = "combat-pending"
    return false
  end
  if not UIParent or not pfUI_config then
    self.focusUnitDefaultStatus = "unavailable"
    return false
  end

  local state, profileKey = GetFocusUnitDefaultState(true)
  if not state then
    self.focusUnitDefaultStatus = "profile-unavailable"
    return false
  end
  if state.optOut == true then
    self.focusUnitDefaultStatus = "profile-opt-out"
    return false
  end
  if state.layoutVersion == self.focusUnitDefaultVersion then
    self.focusUnitDefaultStatus = "profile-saved"
    return false
  end

  CaptureFocusUnitDefaultBackup(state)
  local layout = GetNativeFocusLayout()
  local configured = 0
  local live = 0
  local saved, applied = ConfigureFocusUnitFrame(
    "player", "pfPlayer", layout.playerX, layout.playerY,
    self.focusUnitScale, self.focusUnitWidth, self.focusUnitHeight,
    "TOPRIGHT", "BOTTOMRIGHT", self.focusAuraSize,
    self.focusAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusUnitFrame(
    "target", "pfTarget", layout.targetX, layout.targetY,
    self.focusUnitScale, self.focusUnitWidth, self.focusUnitHeight,
    "TOPLEFT", "BOTTOMLEFT", self.focusAuraSize,
    self.focusAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusUnitFrame(
    "ttarget", "pfTargetTarget",
    layout.targetTargetX, layout.targetTargetY,
    self.focusTargetTargetScale,
    self.focusTargetTargetWidth, self.focusTargetTargetHeight,
    "TOPLEFT", "BOTTOMLEFT", self.focusTargetTargetAuraSize,
    self.focusTargetTargetAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)

  if configured < 3 then
    self.focusUnitDefaultStatus = "profile-pending"
    return false
  end
  state.layoutVersion = self.focusUnitDefaultVersion
  state.mode = "unit-default"
  state.optOut = nil
  self.focusUnitDefaultProfile = profileKey
  self.focusUnitDefaultStatus = "profile-applied"
  self.focusLayoutConfigured = configured
  self.focusLayoutLive = live
  return true
end

local function CopiedPrimaryUnitLayoutNeedsCompaction()
  local database = addon.db and addon.db.actionbars
  if not database or
    (tonumber(database.combatFocusLayoutVersion) or 0) ~= 0 or
    not pfUI_config
  then
    return false
  end

  local unitframes = pfUI_config.unitframes or {}
  local castbars = pfUI_config.castbar or {}
  local player = unitframes.player or {}
  local target = unitframes.target or {}
  local playerCast = castbars.player or {}
  local targetCast = castbars.target or {}

  return FocusPositionMatches(
      "pfPlayer", "BOTTOM", -160, 485, 0.8
    ) and FocusPositionMatches(
      "pfTarget", "BOTTOM", 105, 485, 0.8
    ) and FocusPositionMatches(
      "pfTargetTarget", "BOTTOM", 393, 576, 0.68
    ) and FocusPositionMatches(
      "pfPlayerCastbar", "BOTTOM", 0, 316, 1
    ) and FocusPositionMatches(
      "pfTargetCastbar", "BOTTOM", 0, 300, 1
    ) and tostring(player.width) == "240" and
    tostring(player.height) == "60" and
    tostring(player.pheight) == "10" and
    tostring(player.pspace) == "-3" and
    tostring(target.width) == "240" and
    tostring(target.height) == "60" and
    tostring(target.pheight) == "10" and
    tostring(target.pspace) == "-3" and
    tostring(playerCast.width) == "260" and
    tostring(playerCast.height) == "12" and
    tostring(targetCast.width) == "260" and
    tostring(targetCast.height) == "12"
end

function ActionBars:MigrateCopiedPrimaryUnitLayout()
  if not CopiedPrimaryUnitLayoutNeedsCompaction() then
    return false
  end

  local layout = GetNativeFocusLayout()
  local configured = 0
  local live = 0
  local saved, applied = ConfigureFocusUnitFrame(
    "player", "pfPlayer", layout.playerX, layout.playerY,
    self.focusUnitScale, self.focusUnitWidth, self.focusUnitHeight,
    "TOPRIGHT", "BOTTOMRIGHT", self.focusAuraSize,
    self.focusAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusUnitFrame(
    "target", "pfTarget", layout.targetX, layout.targetY,
    self.focusUnitScale, self.focusUnitWidth, self.focusUnitHeight,
    "TOPLEFT", "BOTTOMLEFT", self.focusAuraSize,
    self.focusAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusUnitFrame(
    "ttarget", "pfTargetTarget",
    layout.targetTargetX, layout.targetTargetY,
    self.focusTargetTargetScale,
    self.focusTargetTargetWidth, self.focusTargetTargetHeight,
    "TOPLEFT", "BOTTOMLEFT", self.focusTargetTargetAuraSize,
    self.focusTargetTargetAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)

  self.focusLayoutConfigured = configured
  self.focusLayoutLive = live
  self.focusLayoutStatus = "primary-units-outward-16x2"
  return true
end

local function ConfigureFocusCastBar(key, name, x, y)
  local castbars = pfUI_config and pfUI_config.castbar
  local config = castbars and castbars[key]
  if type(config) ~= "table" then
    return false, false
  end
  config.width = tostring(ActionBars.focusReadoutWidth)
  config.height = tostring(ActionBars.focusReadoutHeight)
  local saved = SavePfUIPosition(
    name, "BOTTOM", x, y, ActionBars.focusReadoutScale
  )
  local frame = pfUI and pfUI.castbar and pfUI.castbar[key] or
    GetGlobal(name)
  if frame and frame.SetWidth then
    frame:SetWidth(ActionBars.focusReadoutWidth)
  end
  if frame and frame.SetHeight then
    frame:SetHeight(ActionBars.focusReadoutHeight)
  end
  local applied = ApplyFramePosition(
    frame, "BOTTOM", x, y, ActionBars.focusReadoutScale
  )
  return saved, applied
end

local function ConfigureFocusSwingTimers(x, y)
  local unitframes = pfUI_config and pfUI_config.unitframes
  if type(unitframes) ~= "table" then
    return 0, 0
  end
  unitframes.swingtimerwidth = tostring(ActionBars.focusReadoutWidth)
  unitframes.swingtimerheight = tostring(ActionBars.focusReadoutHeight)

  local main = pfUI and pfUI.swingtimer and pfUI.swingtimer.mainhand or
    GetGlobal("pfSwingTimerMainhand")
  local offhand = pfUI and pfUI.swingtimer and pfUI.swingtimer.offhand or
    GetGlobal("pfSwingTimerOffhand")
  local ranged = pfUI and pfUI.swingtimer and pfUI.swingtimer.ranged or
    GetGlobal("pfSwingTimerRanged")
  local frames = { main, ranged }
  local names = { "pfSwingTimerMainhand", "pfSwingTimerRanged" }
  local visible = 0
  local saved = 0
  for index = 1, 2 do
    local frame = frames[index]
    if SavePfUIPosition(
      names[index], "BOTTOM", x, y,
      ActionBars.focusReadoutScale
    ) then
      saved = saved + 1
    end
    if frame then
      if frame.SetWidth then
        frame:SetWidth(ActionBars.focusReadoutWidth)
      end
      if frame.SetHeight then
        frame:SetHeight(ActionBars.focusReadoutHeight)
      end
      local applied = ApplyFramePosition(
        frame, "BOTTOM", x, y, ActionBars.focusReadoutScale
      )
      if applied then
        visible = visible + 1
      end
    end
  end
  if offhand then
    if offhand.SetScale then
      offhand:SetScale(ActionBars.focusReadoutScale)
    end
    if offhand.SetWidth then
      offhand:SetWidth(ActionBars.focusReadoutWidth)
    end
    if offhand.SetHeight then
      offhand:SetHeight(ActionBars.focusReadoutHeight)
    end
    if main and offhand.ClearAllPoints and offhand.SetPoint then
      offhand:ClearAllPoints()
      offhand:SetPoint("TOP", main, "BOTTOM", 0, -2)
    end
  end
  return saved, visible
end

local function AttachFocusTargetTarget()
  local target = pfUI and pfUI.uf and pfUI.uf.target or
    GetGlobal("pfTarget")
  local targetTarget = pfUI and pfUI.uf and pfUI.uf.targettarget or
    GetGlobal("pfTargetTarget")
  if not target or not targetTarget or
    not targetTarget.ClearAllPoints or not targetTarget.SetPoint
  then
    return false
  end
  if targetTarget.SetScale then
    targetTarget:SetScale(ActionBars.focusTargetTargetScale)
  end
  targetTarget:ClearAllPoints()
  targetTarget:SetPoint(
    "LEFT", target, "RIGHT", ActionBars.focusTargetTargetGap, 0
  )
  return true
end

function ActionBars:ApplyFocusRelativeAnchors()
  if not FocusUnitLayoutActive() then
    return false
  end
  return AttachFocusTargetTarget()
end

local function ConfigureFocusDoiteDPS(x, y)
  if type(DoiteDPSDB) ~= "table" then
    return false, false
  end
  local frame = GetGlobal("DoiteDPSMainFrame")
  DoiteDPSDB.point = "TOPLEFT"
  DoiteDPSDB.relativePoint = "TOPLEFT"
  DoiteDPSDB.x = x
  DoiteDPSDB.y = y
  DoiteDPSDB.scale = ActionBars.focusDoiteScale
  return true, ApplyFramePosition(
    frame, "TOPLEFT", x, y, ActionBars.focusDoiteScale
  )
end

function ActionBars:SynchronizeDoitePosition()
  if self.doitePositionSynchronized or type(DoiteDPSDB) ~= "table" then
    return false
  end
  local frame = GetGlobal("DoiteDPSMainFrame")
  if not frame then
    return false
  end
  DoiteDPSDB.point = "TOPLEFT"
  DoiteDPSDB.relativePoint = "TOPLEFT"
  DoiteDPSDB.x = self.focusDoiteX
  DoiteDPSDB.y = self.focusDoiteY
  local database = addon.db and addon.db.actionbars
  local projection = database and database.combatFocusProjection
  if type(projection) == "table" and
    projection.coordinateSpace == self.focusCoordinateSpace
  then
    projection.doiteX = self.focusDoiteX
    projection.doiteY = self.focusDoiteY
  end
  local applied = ApplyFramePosition(
    frame, "TOPLEFT", self.focusDoiteX, self.focusDoiteY,
    tonumber(DoiteDPSDB.scale) or 1
  )
  local resource = GetGlobal("DoiteDPSResourceStatusFrame")
  if resource and resource.SetScale then
    resource:SetScale(tonumber(DoiteDPSDB.scale) or 1)
  end
  self.doitePositionSynchronized = applied and true or false
  self.focusLayoutDoite = applied and "all-profiles-synchronized" or
    "synchronization-pending"
  return applied
end

local function CombatFocusStanceUpgradeEligible()
  local database = addon.db and addon.db.actionbars
  local projection = database and database.combatFocusProjection
  local version = database and database.combatFocusLayoutVersion
  local bars = pfUI_config and pfUI_config.bars
  local config = bars and bars.bar11
  local positions = pfUI_config and pfUI_config.position
  local position = positions and positions.pfActionBarStances
  local scale = position and tonumber(position.scale)
  local legacyScale = scale and (
    math.abs(scale - 0.7) <= 0.001 or
    math.abs(scale - 0.72) <= 0.001 or
    (version == 15 and math.abs(scale - 1) <= 0.001)
  )
  return database and (version == 14 or version == 15) and
    type(projection) == "table" and
    projection.coordinateSpace == ActionBars.focusCoordinateSpace and
    type(config) == "table" and
    tonumber(config.icon_size) == 18 and
    type(position) == "table" and position.anchor == "BOTTOM" and
    position.parent == "UIParent" and
    math.abs((tonumber(position.xpos) or 100000) -
      ActionBars.focusStanceX) <= 1 and
    math.abs((tonumber(position.ypos) or 100000) -
      ActionBars.focusStanceY) <= 1 and legacyScale
end

function ActionBars:ApplyFocusStanceContract(resetPosition, forceProvider)
  local bars = pfUI_config and pfUI_config.bars
  local config = bars and bars.bar11
  local positions = pfUI_config and pfUI_config.position
  if type(config) ~= "table" or type(positions) ~= "table" then
    self.focusStanceStatus = "unavailable"
    return false, false
  end

  local changed = config.icon_size ~= self.focusStanceIconSize
  config.icon_size = self.focusStanceIconSize

  local position = positions.pfActionBarStances
  local saved
  if resetPosition or type(position) ~= "table" then
    local layout = GetNativeFocusLayout()
    saved = SavePfUIPosition(
      "pfActionBarStances", "BOTTOM", layout.stanceX, layout.stanceY,
      self.focusStanceScale
    )
  else
    changed = changed or
      math.abs((tonumber(position.scale) or 100000) -
        self.focusStanceScale) > 0.001
    position.scale = self.focusStanceScale
    saved = true
  end

  local providerRefreshed = false
  local provider = pfUI and pfUI.bars
  if (changed or forceProvider) and provider and
    type(provider.UpdateConfig) == "function" and
    not self.focusStanceUpdating
  then
    self.focusStanceUpdating = true
    providerRefreshed = pcall(provider.UpdateConfig, provider)
    self.focusStanceUpdating = false
  end

  local frame = GetGlobal("pfActionBarStances")
  local applied = false
  if resetPosition then
    local layout = GetNativeFocusLayout()
    applied = ApplyFramePosition(
      frame, "BOTTOM", layout.stanceX, layout.stanceY,
      self.focusStanceScale
    )
  elseif frame and frame.SetScale then
    frame:SetScale(self.focusStanceScale)
    applied = true
  end

  self.focusStanceStatus = providerRefreshed and
    "provider-refreshed" or (applied and "applied" or "saved")
  return saved, applied
end

function ActionBars:UpgradeCombatFocusStanceContract()
  if not CombatFocusStanceUpgradeEligible() then
    return false
  end
  CaptureCombatFocusBackup()
  UpgradeCombatFocusBackup()
  local saved, applied = self:ApplyFocusStanceContract(false, true)
  if not saved then
    return false
  end
  local database = addon.db and addon.db.actionbars
  local projection = database and database.combatFocusProjection
  database.combatFocusLayoutVersion = self.focusLayoutVersion
  projection.stanceScale = self.focusStanceScale
  projection.stanceIconSize = tonumber(self.focusStanceIconSize)
  self.focusLayoutConfigured = 1
  self.focusLayoutLive = applied and 1 or 0
  self.focusLayoutStatus = "stance-upgraded"
  return true
end

function ActionBars:ApplyCombatFocusLayoutPreset()
  if type(InCombatLockdown) == "function" and InCombatLockdown() then
    self.focusLayoutStatus = "combat-locked"
    return false, "Leave combat before applying the Combat Focus layout."
  end
  if not UIParent or not pfUI_config then
    self.focusLayoutStatus = "unavailable"
    return false, "UIParent or the pfUI character profile is unavailable."
  end
  if not ComfortUIScaleConfigured() then
    self.focusLayoutStatus = "scale-required"
    return false,
      "Combat Focus native coordinates require pfUI tier 8. Run /aeui focuslayout comfort."
  end

  CaptureCombatFocusBackup()
  UpgradeCombatFocusBackup()
  local deckApplied, deckMessage = self:ResetCombatDeckPosition()
  if not deckApplied then
    self.focusLayoutStatus = "unavailable"
    return false, tostring(deckMessage)
  end
  local configured = 0
  local live = 0
  local layout = GetNativeFocusLayout()

  local saved, applied = ConfigureFocusUnitFrame(
    "player", "pfPlayer", layout.playerX, layout.playerY,
    self.focusUnitScale, self.focusUnitWidth, self.focusUnitHeight,
    "TOPRIGHT", "BOTTOMRIGHT", self.focusAuraSize,
    self.focusAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusUnitFrame(
    "target", "pfTarget", layout.targetX, layout.targetY,
    self.focusUnitScale, self.focusUnitWidth, self.focusUnitHeight,
    "TOPLEFT", "BOTTOMLEFT", self.focusAuraSize,
    self.focusAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusUnitFrame(
    "ttarget", "pfTargetTarget",
    layout.targetTargetX, layout.targetTargetY,
    self.focusTargetTargetScale,
    self.focusTargetTargetWidth, self.focusTargetTargetHeight,
    "TOPLEFT", "BOTTOMLEFT", self.focusTargetTargetAuraSize,
    self.focusTargetTargetAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)

  saved, applied = ConfigureFocusCastBar(
    "player", "pfPlayerCastbar",
    layout.playerCastX, layout.playerCastY
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusCastBar(
    "target", "pfTargetCastbar",
    layout.targetCastX, layout.targetCastY
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)

  local swingConfigured, swingLive = ConfigureFocusSwingTimers(
    layout.swingX, layout.swingY
  )
  configured = configured + swingConfigured
  live = live + swingLive

  AttachFocusTargetTarget()

  local stanceSaved, stanceApplied =
    self:ApplyFocusStanceContract(true, true)
  if stanceApplied then
    live = live + 1
  end
  configured = configured + (stanceSaved and 1 or 0)

  local doiteSaved, doiteApplied = ConfigureFocusDoiteDPS(
    layout.doiteX, layout.doiteY
  )
  configured = configured + (doiteSaved and 1 or 0)
  live = live + (doiteApplied and 1 or 0)

  -- This is the only normal AEUI path that writes ArchiTotem appearance
  -- options. Refresh and binding merely observe the provider's direction.
  local archiDirectionApplied = self:RequestArchiTotemDownDirection()

  configured = configured + 1
  live = live + 1

  local database = addon.db and addon.db.actionbars
  if database then
    database.combatFocusLayoutVersion = self.focusLayoutVersion
    database.combatFocusProjection = layout
  end
  local defaultState, defaultProfile = GetFocusUnitDefaultState(true)
  if defaultState then
    defaultState.layoutVersion = self.focusUnitDefaultVersion
    defaultState.mode = "full"
    defaultState.optOut = nil
    self.focusUnitDefaultProfile = defaultProfile
    self.focusUnitDefaultStatus = "profile-full"
  end
  self:InstallFocusUnitFontHooks()
  self:ApplyFocusUnitFonts(true)
  self.focusLayoutConfigured = configured
  self.focusLayoutLive = live
  self.focusLayoutDoite = doiteSaved and "preserved" or "missing"
  self.focusLayoutArchiTotem =
    self.archiTotemDirectionStatus or "missing"
  self.focusLayoutStatus = "applied"
  self.focusLayoutMousePolicy = "visible-controls-only"
  local archiMessage = archiDirectionApplied and
    " Detected ArchiTotem was kept provider-owned and requested to open downward." or
    " ArchiTotem was unavailable or inapplicable and remained fail-open."
  return true,
    "Combat Focus layout applied with direct Turtle WoW game coordinates: player and target use 240x48 at 0.8 with 18-point client-system unit text and a lower 480-UI bottom anchor; the compact 240x60 target-of-target remains at 0.68 and follows the Target alignment without resizing; 23x23 auras use pfUI's real seven-UI border step and fit eight per row; two lower aura rows remain clear of the unchanged centered 260x12 player-cast, target-cast, and Swing stack at 1.0. The stance bar uses 25 UI provider icons at full local scale 1.0 for readable warrior controls, while the provider-owned DoiteDPS timeline and resource row remain in their own safe lane. Provider visibility, lock state, and native translucency were preserved without screen-pixel projection or coordinate readback." ..
    archiMessage
end

local function RestoreConfigField(container, key, captured)
  if type(container) ~= "table" or type(captured) ~= "table" then
    return false
  end
  if not captured.present then
    container[key] = nil
    return true
  end
  if type(captured.value) ~= "table" then
    container[key] = captured.value
    return true
  end
  local target = container[key]
  if type(target) ~= "table" then
    target = {}
    container[key] = target
  end
  for field in pairs(target) do
    target[field] = nil
  end
  for field, value in pairs(captured.value) do
    target[CopyPlainTable(field)] = CopyPlainTable(value)
  end
  return true
end

local function GetFocusMovableFrame(name)
  if name == "pfActionBarMain" then
    return GetMainActionBarFrame()
  elseif name == "pfActionBarTop" then
    return GetTopActionBarFrame()
  elseif name == "pfPlayer" then
    return pfUI and pfUI.uf and pfUI.uf.player or GetGlobal(name)
  elseif name == "pfTarget" then
    return pfUI and pfUI.uf and pfUI.uf.target or GetGlobal(name)
  elseif name == "pfTargetTarget" then
    return pfUI and pfUI.uf and pfUI.uf.targettarget or GetGlobal(name)
  elseif name == "pfPlayerCastbar" then
    return pfUI and pfUI.castbar and pfUI.castbar.player or GetGlobal(name)
  elseif name == "pfTargetCastbar" then
    return pfUI and pfUI.castbar and pfUI.castbar.target or GetGlobal(name)
  elseif name == "pfSwingTimerMainhand" then
    return pfUI and pfUI.swingtimer and pfUI.swingtimer.mainhand or
      GetGlobal(name)
  elseif name == "pfSwingTimerRanged" then
    return pfUI and pfUI.swingtimer and pfUI.swingtimer.ranged or
      GetGlobal(name)
  end
  return GetGlobal(name)
end

local function ReloadRestoredMovable(name)
  local frame = GetFocusMovableFrame(name)
  if not frame then
    return false
  end
  if pfUI and pfUI.api and type(pfUI.api.LoadMovable) == "function" then
    local ok = pcall(pfUI.api.LoadMovable, frame)
    if ok then
      return true
    end
  end
  local position = pfUI_config and pfUI_config.position and
    pfUI_config.position[name]
  if type(position) ~= "table" then
    return false
  end
  return ApplyFramePosition(
    frame, position.anchor or "CENTER",
    tonumber(position.xpos) or 0, tonumber(position.ypos) or 0,
    tonumber(position.scale)
  )
end

function ActionBars:RestoreFocusUnitDefaults()
  if type(InCombatLockdown) == "function" and InCombatLockdown() then
    self.focusUnitDefaultStatus = "combat-locked"
    return false, "Leave combat before restoring the unit-frame defaults."
  end
  if not pfUI_config then
    self.focusUnitDefaultStatus = "unavailable"
    return false, "The pfUI character profile is unavailable."
  end
  local state = GetFocusUnitDefaultState(false)
  local backup = state and state.backup
  if type(backup) ~= "table" or
    backup.version ~= self.focusUnitDefaultBackupVersion
  then
    self.focusUnitDefaultStatus = "no-backup"
    return false, "No compatible pre-default unit-frame backup exists."
  end

  pfUI_config.position = pfUI_config.position or {}
  for index = 1, table.getn(focusUnitDefaultPositionNames) do
    local name = focusUnitDefaultPositionNames[index]
    RestoreField(
      pfUI_config.position, name,
      backup.positions and backup.positions[name]
    )
  end

  pfUI_config.unitframes = pfUI_config.unitframes or {}
  local unitframes = backup.unitframes or {}
  RestoreConfigField(pfUI_config.unitframes, "player", unitframes.player)
  RestoreConfigField(pfUI_config.unitframes, "target", unitframes.target)
  RestoreConfigField(pfUI_config.unitframes, "ttarget", unitframes.ttarget)

  local frames = {
    GetFocusUnitFrame("player"),
    GetFocusUnitFrame("target"),
    GetFocusUnitFrame("ttarget"),
  }
  self.focusFontSuppressed = true
  for index = 1, table.getn(frames) do
    local frame = frames[index]
    if frame and type(frame.UpdateFrameSize) == "function" then
      pcall(frame.UpdateFrameSize, frame)
    end
    if frame and type(frame.UpdateConfig) == "function" then
      pcall(frame.UpdateConfig, frame)
    end
  end
  self.focusFontSuppressed = false
  for index = 1, table.getn(focusUnitDefaultPositionNames) do
    ReloadRestoredMovable(focusUnitDefaultPositionNames[index])
  end

  state.layoutVersion = 0
  state.mode = "restored"
  state.optOut = true
  self.focusUnitDefaultStatus = "profile-restored"
  self.focusLayoutStatus = "unit-default-restored"
  self.focusLayoutConfigured = 0
  self.focusLayoutLive = 0
  self.focusUnitFontLive = 0
  return true,
    "The current character's pre-default Player, Target, and TargetTarget layout was restored. Reload once so pfUI can rebuild the original frames."
end

function ActionBars:RestoreCombatFocusLayoutPreset()
  if type(InCombatLockdown) == "function" and InCombatLockdown() then
    self.focusLayoutStatus = "combat-locked"
    return false, "Leave combat before restoring the Combat Focus layout."
  end
  local database = addon.db and addon.db.actionbars
  local defaultState = GetFocusUnitDefaultState(false)
  if defaultState and defaultState.mode == "unit-default" and
    defaultState.layoutVersion == self.focusUnitDefaultVersion
  then
    return self:RestoreFocusUnitDefaults()
  end
  local backup = database and database.combatFocusBackup
  if type(backup) ~= "table" or
    backup.version ~= self.focusLayoutBackupVersion
  then
    self.focusLayoutStatus = "no-backup"
    return false, "No compatible pre-Combat-Focus backup exists."
  end
  if not pfUI_config then
    self.focusLayoutStatus = "unavailable"
    return false, "The pfUI character profile is unavailable."
  end

  pfUI_config.position = pfUI_config.position or {}
  for index = 1, table.getn(focusPositionNames) do
    local name = focusPositionNames[index]
    RestoreField(
      pfUI_config.position, name, backup.positions and
        backup.positions[name]
    )
  end

  pfUI_config.unitframes = pfUI_config.unitframes or {}
  local unitframes = backup.unitframes or {}
  RestoreConfigField(pfUI_config.unitframes, "player", unitframes.player)
  RestoreConfigField(pfUI_config.unitframes, "target", unitframes.target)
  RestoreConfigField(pfUI_config.unitframes, "ttarget", unitframes.ttarget)
  RestoreField(
    pfUI_config.unitframes, "swingtimerwidth",
    unitframes.swingtimerwidth
  )
  RestoreField(
    pfUI_config.unitframes, "swingtimerheight",
    unitframes.swingtimerheight
  )

  pfUI_config.castbar = pfUI_config.castbar or {}
  local castbar = backup.castbar or {}
  RestoreConfigField(pfUI_config.castbar, "player", castbar.player)
  RestoreConfigField(pfUI_config.castbar, "target", castbar.target)

  pfUI_config.bars = pfUI_config.bars or {}
  pfUI_config.bars.bar11 = pfUI_config.bars.bar11 or {}
  local savedBars = backup.bars or {}
  local savedStance = savedBars.bar11 or {}
  RestoreField(
    pfUI_config.bars.bar11, "icon_size", savedStance.icon_size
  )
  local barProvider = pfUI and pfUI.bars
  if barProvider and type(barProvider.UpdateConfig) == "function" then
    self.focusStanceUpdating = true
    pcall(barProvider.UpdateConfig, barProvider)
    self.focusStanceUpdating = false
  end

  local frames = {
    pfUI and pfUI.uf and pfUI.uf.player,
    pfUI and pfUI.uf and pfUI.uf.target,
    pfUI and pfUI.uf and pfUI.uf.targettarget,
  }
  self.focusFontSuppressed = true
  for index = 1, table.getn(frames) do
    local frame = frames[index]
    if frame and type(frame.UpdateFrameSize) == "function" then
      pcall(frame.UpdateFrameSize, frame)
    end
    if frame and type(frame.UpdateConfig) == "function" then
      pcall(frame.UpdateConfig, frame)
    end
  end
  self.focusFontSuppressed = false

  for index = 1, table.getn(focusPositionNames) do
    ReloadRestoredMovable(focusPositionNames[index])
  end

  if backup.doitePresent and type(DoiteDPSDB) == "table" then
    local doite = backup.doite or {}
    RestoreField(DoiteDPSDB, "point", doite.point)
    RestoreField(DoiteDPSDB, "relativePoint", doite.relativePoint)
    RestoreField(DoiteDPSDB, "x", doite.x)
    RestoreField(DoiteDPSDB, "y", doite.y)
    RestoreField(DoiteDPSDB, "scale", doite.scale)
    local frame = GetGlobal("DoiteDPSMainFrame")
    if frame and frame.ClearAllPoints and frame.SetPoint then
      if frame.SetScale and tonumber(DoiteDPSDB.scale) then
        frame:SetScale(tonumber(DoiteDPSDB.scale))
      end
      frame:ClearAllPoints()
      frame:SetPoint(
        DoiteDPSDB.point or "CENTER", UIParent,
        DoiteDPSDB.relativePoint or DoiteDPSDB.point or "CENTER",
        tonumber(DoiteDPSDB.x) or 0,
        tonumber(DoiteDPSDB.y) or 0
      )
    end
  end

  pfUI_config.global = pfUI_config.global or {}
  RestoreField(
    pfUI_config.global, "pixelperfect", backup.pixelperfect
  )
  if backup.pixelperfect and backup.pixelperfect.present then
    ApplyComfortUIScaleValue()
  end

  local actionbarBackup = backup.actionbars or {}
  RestoreField(database, "fieldKitBound", actionbarBackup.fieldKitBound)
  RestoreField(database, "consumableDocked", actionbarBackup.consumableDocked)
  RestoreField(database, "trinketDocked", actionbarBackup.trinketDocked)
  RestoreField(
    database, "combatDeckLayoutVersion",
    actionbarBackup.combatDeckLayoutVersion
  )
  RestoreField(
    database, "combatFocusLayoutVersion",
    actionbarBackup.combatFocusLayoutVersion
  )
  RestoreField(
    database, "combatFocusProjection",
    actionbarBackup.combatFocusProjection
  )
  RestoreField(
    database, "comfortUIScaleVersion",
    actionbarBackup.comfortUIScaleVersion
  )

  local archi = backup.archiDirection
  local setArchiDirection = GetGlobal("ArchiTotem_SetDirection")
  if archi and archi.present and type(setArchiDirection) == "function" then
    pcall(setArchiDirection, archi.value)
  end
  if actionbarBackup.fieldKitBound and
    actionbarBackup.fieldKitBound.present
  then
    self:SetFieldKitDocking(actionbarBackup.fieldKitBound.value == true)
  end

  database.combatFocusBackup = nil
  local restoredState = GetFocusUnitDefaultState(false)
  if restoredState then
    restoredState.layoutVersion = 0
    restoredState.mode = "restored"
    restoredState.optOut = true
  end
  self.focusLayoutStatus = "restored"
  self.focusLayoutConfigured = 0
  self.focusLayoutLive = 0
  self.focusUnitFontLive = 0
  self.focusFontSuppressed = false
  self.focusLayoutDoite = "restored"
  self.focusLayoutArchiTotem = "restored"
  self.comfortUIScaleStatus = ComfortUIScaleConfigured() and
    "saved" or "custom"
  return true,
    "The pre-Combat-Focus pfUI and provider profile was restored. Reload once so every provider can rebuild its original dimensions."
end

function ActionBars:ApplyComfortUIScalePreset()
  if type(InCombatLockdown) == "function" and InCombatLockdown() then
    self.comfortUIScaleStatus = "combat-locked"
    return false, "Leave combat before applying the Comfort UI scale."
  end
  if not pfUI_config or type(pfUI_config.global) ~= "table" then
    self.comfortUIScaleStatus = "unavailable"
    return false, "The pfUI character profile is unavailable."
  end

  CaptureCombatFocusBackup()
  pfUI_config.global.pixelperfect =
    tostring(self.comfortUIScaleTier)
  if not ApplyComfortUIScaleValue() then
    self.comfortUIScaleStatus = "unavailable"
    return false, "pfUI or UIParent could not apply the Comfort UI scale."
  end

  local database = addon.db and addon.db.actionbars
  if database then
    database.comfortUIScaleVersion = self.comfortUIScaleVersion
  end
  self.comfortUIScaleStatus = "applied"

  local layoutOk, layoutMessage = self:ApplyCombatFocusLayoutPreset()
  if not layoutOk then
    return false,
      "Comfort UI scale applied, but Combat Focus could not be re-anchored: " ..
      tostring(layoutMessage)
  end
  return true,
    "Comfort UI scale applied: pfUI tier 8 (0.711111), compact game-coordinate Combat Focus scales 0.68/0.62/0.72, and provider-native visibility preserved. Reload if a third-party frame does not redraw immediately."
end

local function SlotSignature(slot)
  if type(slot) ~= "table" then
    return ""
  end
  local values = {}
  for index = 1, table.getn(slot) do
    values[index] = tostring(slot[index])
  end
  return table.concat(values, "|")
end

local function ManualSlotMatches(slot)
  if type(slot) ~= "table" then
    return false
  end
  if table.getn(slot) > 16 then
    return false
  end
  for index = 1, table.getn(slot) do
    if type(slot[index]) ~= "number" then
      return false
    end
  end
  return true
end

local function GetPlayerClassToken()
  if type(UnitClass) ~= "function" then
    return nil
  end
  local ignored, class = UnitClass("player")
  return class
end

local archiTotemRequiredObjects = {
  "ArchiTotemButton_Earth1",
  "ArchiTotemButton_Fire1",
  "ArchiTotemButton_Water1",
  "ArchiTotemButton_Air1",
  "ArchiTotemDragHandle",
  "ArchiTotemButton_AllTotems",
}

local function AuditArchiTotemProvider()
  if GetPlayerClassToken() ~= "SHAMAN" then
    return nil, "non-shaman"
  end
  local frame = GetGlobal("ArchiTotemFrame")
  if not frame or not frame.ClearAllPoints or not frame.SetPoint then
    return nil, "missing"
  end
  for index = 1, table.getn(archiTotemRequiredObjects) do
    if not GetGlobal(archiTotemRequiredObjects[index]) then
      return nil, "signature-mismatch"
    end
  end
  if frame.IsShown and not frame:IsShown() then
    return nil, "hidden"
  end
  return frame, "available"
end

local function GetArchiTotemDirection()
  local options = GetGlobal("ArchiTotem_Options")
  local appearance = type(options) == "table" and options.Apperance
  if type(appearance) ~= "table" then
    return nil
  end
  return appearance.direction
end

function ActionBars:RequestArchiTotemDownDirection()
  local frame, status = AuditArchiTotemProvider()
  if not frame then
    self.archiTotemDirectionStatus = status
    return false
  end
  local setDirection = GetGlobal("ArchiTotem_SetDirection")
  if type(setDirection) ~= "function" or not GetArchiTotemDirection() then
    self.archiTotemDirectionStatus = "direction-unavailable"
    return false
  end
  if GetArchiTotemDirection() ~= "down" then
    local ok = pcall(setDirection, "down")
    if not ok then
      self.archiTotemDirectionStatus = "direction-error"
      return false
    end
  end
  local direction = GetArchiTotemDirection()
  self.archiTotemDirectionStatus = direction or "unknown"
  return direction == "down"
end

local function SplitSlotSignature(signature)
  local result = {}
  if not signature or signature == "" then
    return result
  end
  local iterator = string.gfind or string.gmatch
  for value in iterator(signature, "[^|]+") do
    table.insert(result, value)
  end
  return result
end

local function CopyManualSlot(slot)
  if not ManualSlotMatches(slot) then
    return {}
  end
  local result = {}
  for index = 1, table.getn(slot) do
    result[index] = slot[index]
  end
  return result
end

local function RecommendedAutoBarSlot(index, class, manualSlot)
  if index == 16 then
    return CopyManualSlot(manualSlot)
  end
  local signature = recommendedAutoBarSlots[index]
  if index == 3 then
    signature = autoBarClassSlot3[class] or autoBarManaSlot3
  elseif index == 18 then
    signature = autoBarClassSlot18[class] or ""
  end
  return SplitSlotSignature(signature)
end

local function RefreshAutoBarProfile()
  if not AutoBarProfile or
    type(AutoBarProfile.Initialize) ~= "function" or
    type(AutoBarProfile.ProfileChanged) ~= "function"
  then
    return false, "AutoBar 1.31 profile API is unavailable."
  end
  AutoBarProfile.Initialize()
  AutoBarProfile:ProfileChanged()
  return true
end

local function AutoBarProfileMatches()
  if not AutoBar or type(AutoBar.buttons) ~= "table" then
    return false
  end
  local class = GetPlayerClassToken()
  local slot3 = autoBarClassSlot3[class] or autoBarManaSlot3
  local slot18 = autoBarClassSlot18[class] or ""
  for index = 1, 24 do
    if index == 16 then
      if not ManualSlotMatches(AutoBar.buttons[index]) then
        return false
      end
    else
      local expected = recommendedAutoBarSlots[index]
      if index == 3 then
        expected = slot3
      elseif index == 18 then
        expected = slot18
      end
      if SlotSignature(AutoBar.buttons[index]) ~= (expected or "") then
        return false
      end
    end
  end
  return true
end

local function AutoBarOptionEnabled(value)
  return value == true or value == 1 or value == "1"
end

local function AutoBarConfigCurationEnabled()
  return addon.db and addon.db.actionbars and
    addon.db.actionbars.enabled
end

local function GetAutoBarClassProfileKey()
  if type(AutoBarProfile) ~= "table" then
    return nil
  end
  local classProfile = AutoBarProfile.CLASSPROFILE
  if not classProfile then
    local class = GetPlayerClassToken()
    if class then
      classProfile = "_" .. class
    end
  end
  return classProfile
end

local function AutoBarClassScopeActive(profile, classProfile)
  return type(profile) == "table" and classProfile and
    not AutoBarOptionEnabled(profile.useCharacter) and
    not AutoBarOptionEnabled(profile.useShared) and
    AutoBarOptionEnabled(profile.useClass) and
    not AutoBarOptionEnabled(profile.useBasic) and
    tonumber(profile.edit) == 3
end

local function AutoBarSelectedTab()
  local player = AutoBar and AutoBar.currentPlayer
  local current = player and AutoBar_Config and AutoBar_Config[player]
  local display = current and current.display
  return display and tonumber(display.selectedTab) or 1
end

local function SetAutoBarConfigFrameShown(name, shown)
  local frame = GetGlobal(name)
  if not frame then
    return false
  end
  if shown and frame.Show then
    frame:Show()
  elseif not shown and frame.Hide then
    frame:Hide()
  else
    return false
  end
  return true
end

function ActionBars:RestoreAutoBarConfigCuration()
  local layout = self.autoBarConfigOriginalLayout
  if layout then
    RestoreFrameAnchors(GetGlobal("AutoBarConfigFrameTab3"), layout.tab3)
    RestoreFrameAnchors(GetGlobal("AutoBarConfigFrameSlots"), layout.slots)
  end

  for _, name in pairs({
    "AutoBarConfigFrameTab1",
    "AutoBarConfigFrameTab2",
    "AutoBarConfigFrameTab3",
    "AutoBarConfigFrameTab4",
    "AutoBarConfigFrameTab5",
    "AutoBarConfigFrameResetDisplay",
    "AutoBarConfigFrameRevertButton",
  }) do
    SetAutoBarConfigFrameShown(name, true)
  end

  local selectedTab = AutoBarSelectedTab()
  if not self.autoBarConfigSelecting and AutoBarConfig and
    type(AutoBarConfig.TabButtonOnClick) == "function" and
    selectedTab >= 1 and selectedTab <= 5
  then
    self.autoBarConfigSelecting = true
    pcall(AutoBarConfig.TabButtonOnClick, AutoBarConfig, selectedTab)
    self.autoBarConfigSelecting = false
  end
  SetAutoBarConfigFrameShown(
    "AutoBarConfigFrameSlotsView",
    selectedTab == 1 or selectedTab == 5
  )
  SetAutoBarConfigFrameShown(
    "AutoBarConfigFrameLayout1",
    selectedTab ~= 1
  )
  SetAutoBarConfigFrameShown(
    "AutoBarConfigFrameLayout2",
    selectedTab ~= 1
  )

  local player = AutoBar and AutoBar.currentPlayer
  local current = player and AutoBar_Config and AutoBar_Config[player]
  local profile = current and current.profile
  SetAutoBarConfigFrameShown(
    "AutoBarConfigFrameSlotsEdit1",
    profile and AutoBarOptionEnabled(profile.useCharacter)
  )
  SetAutoBarConfigFrameShown(
    "AutoBarConfigFrameSlotsEdit2",
    profile and AutoBarOptionEnabled(profile.useShared)
  )
  SetAutoBarConfigFrameShown(
    "AutoBarConfigFrameSlotsEdit3",
    profile and AutoBarOptionEnabled(profile.useClass)
  )
  SetAutoBarConfigFrameShown(
    "AutoBarConfigFrameSlotsEdit4",
    profile and AutoBarOptionEnabled(profile.useBasic)
  )
  self.autoBarConfigCurationStatus = "native"
  return true
end

function ActionBars:ApplyAutoBarConfigCuration()
  local configFrame = GetGlobal("AutoBarConfigFrame")
  local tab1 = GetGlobal("AutoBarConfigFrameTab1")
  local tab3 = GetGlobal("AutoBarConfigFrameTab3")
  local slots = GetGlobal("AutoBarConfigFrameSlots")
  if not configFrame or not tab1 or not tab3 or not slots then
    self.autoBarConfigCurationStatus = "unavailable"
    return false
  end

  local player = AutoBar and AutoBar.currentPlayer
  local current = player and AutoBar_Config and AutoBar_Config[player]
  local profile = current and current.profile
  local classProfile = GetAutoBarClassProfileKey()
  local database = addon.db and addon.db.actionbars
  local optOut = database and database.autoBarClassScopeOptOut
  if not AutoBarConfigCurationEnabled() or
    (player and type(optOut) == "table" and optOut[player]) or
    not AutoBarClassScopeActive(profile, classProfile)
  then
    return self:RestoreAutoBarConfigCuration()
  end

  if not self.autoBarConfigOriginalLayout then
    self.autoBarConfigOriginalLayout = {
      tab3 = CaptureFrameAnchors(tab3),
      slots = CaptureFrameAnchors(slots),
    }
  end

  local selectedTab = AutoBarSelectedTab()
  if selectedTab ~= 1 and selectedTab ~= 3 then
    current.display = current.display or {}
    current.display.selectedTab = 1
    if not self.autoBarConfigSelecting and AutoBarConfig and
      type(AutoBarConfig.TabButtonOnClick) == "function"
    then
      self.autoBarConfigSelecting = true
      pcall(AutoBarConfig.TabButtonOnClick, AutoBarConfig, 1)
      self.autoBarConfigSelecting = false
    end
  end

  if tab3.ClearAllPoints and tab3.SetPoint then
    tab3:ClearAllPoints()
    tab3:SetPoint("TOPLEFT", tab1, "TOPRIGHT", 0, 0)
  end
  if slots.ClearAllPoints and slots.SetPoint then
    slots:ClearAllPoints()
    slots:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 10, -100)
    slots:SetPoint("TOPRIGHT", configFrame, "TOPRIGHT", -10, -100)
  end

  SetAutoBarConfigFrameShown("AutoBarConfigFrameTab1", true)
  SetAutoBarConfigFrameShown("AutoBarConfigFrameTab3", true)
  for _, name in pairs({
    "AutoBarConfigFrameTab2",
    "AutoBarConfigFrameTab4",
    "AutoBarConfigFrameTab5",
    "AutoBarConfigFrameResetDisplay",
    "AutoBarConfigFrameRevertButton",
    "AutoBarConfigFrameSlotsView",
    "AutoBarConfigFrameSlotsEdit1",
    "AutoBarConfigFrameSlotsEdit2",
    "AutoBarConfigFrameSlotsEdit3",
    "AutoBarConfigFrameSlotsEdit4",
    "AutoBarConfigFrameLayout1",
    "AutoBarConfigFrameLayout2",
  }) do
    SetAutoBarConfigFrameShown(name, false)
  end

  self.autoBarConfigCurationStatus = "class-only"
  return true
end

function ActionBars:MigrateAutoBarClassScope()
  if self.autoBarClassScopeUpdating or not AutoBarConfigCurationEnabled() or
    not AutoBar or type(AutoBar_Config) ~= "table" or
    type(AutoBarProfile) ~= "table" or
    type(AutoBarProfile.Initialize) ~= "function"
  then
    return false
  end

  local database = addon.db and addon.db.actionbars
  local player = AutoBar.currentPlayer
  local current = player and AutoBar_Config[player]
  if not database or not player or type(current) ~= "table" then
    self.autoBarClassScopeStatus = "unavailable"
    return false
  end

  database.autoBarClassScopeOptOut =
    database.autoBarClassScopeOptOut or {}
  if database.autoBarClassScopeOptOut[player] then
    self.autoBarClassScopeStatus = "restored"
    return false
  end

  self.autoBarClassScopeUpdating = true
  local initialized = pcall(AutoBarProfile.Initialize)
  local classProfile = initialized and GetAutoBarClassProfileKey() or nil
  local classConfig = classProfile and AutoBar_Config[classProfile]
  if not initialized or not classProfile or type(classConfig) ~= "table" then
    self.autoBarClassScopeUpdating = false
    self.autoBarClassScopeStatus = "unavailable"
    return false
  end

  local currentBefore = CopyPlainTable(current)
  current.profile = current.profile or {}
  current.display = current.display or {}
  local profile = current.profile
  local alreadyActive = AutoBarClassScopeActive(profile, classProfile)
  local selectedTabChanged = false
  if tonumber(current.display.selectedTab) ~= 1 and
    tonumber(current.display.selectedTab) ~= 3
  then
    current.display.selectedTab = 1
    selectedTabChanged = true
  end

  database.autoBarClassScopePlayerVersions =
    database.autoBarClassScopePlayerVersions or {}
  database.autoBarClassScopeClassVersions =
    database.autoBarClassScopeClassVersions or {}
  database.autoBarClassScopeProfiles =
    database.autoBarClassScopeProfiles or {}
  database.autoBarClassScopePlayerBackups =
    database.autoBarClassScopePlayerBackups or {}
  database.autoBarClassScopeBackups =
    database.autoBarClassScopeBackups or {}

  local playerVersions = database.autoBarClassScopePlayerVersions
  local classVersions = database.autoBarClassScopeClassVersions
  if alreadyActive and
    playerVersions[player] == self.autoBarClassScopeVersion and
    classVersions[classProfile] == self.autoBarClassScopeVersion
  then
    self.autoBarClassScopeUpdating = false
    self.autoBarClassScopeStatus = "class-only"
    if selectedTabChanged then
      self:ApplyAutoBarConfigCuration()
    end
    return false
  end

  local classBefore = CopyPlainTable(classConfig)
  local seededClass = classVersions[classProfile] ~= self.autoBarClassScopeVersion
  local sourceButtons = type(AutoBar.buttons) == "table" and
    AutoBar.buttons or current.buttons
  if seededClass and type(sourceButtons) ~= "table" then
    AutoBar_Config[player] = currentBefore
    self.autoBarClassScopeUpdating = false
    self.autoBarClassScopeStatus = "buttons-unavailable"
    return false
  end

  local madePlayerBackup = false
  local madeClassBackup = false
  if not database.autoBarClassScopePlayerBackups[player] then
    local existingBackups = database.autoBarBackups
    local existingBackup = type(existingBackups) == "table" and
      existingBackups[player]
    database.autoBarClassScopePlayerBackups[player] =
      CopyPlainTable(existingBackup or currentBefore)
    madePlayerBackup = true
  end
  if seededClass and not database.autoBarClassScopeBackups[classProfile] then
    database.autoBarClassScopeBackups[classProfile] = classBefore
    madeClassBackup = true
  end
  local previousProfileKey = database.autoBarClassScopeProfiles[player]
  database.autoBarClassScopeProfiles[player] = classProfile

  if seededClass then
    classConfig.buttons = CopyPlainTable(sourceButtons)
  end
  profile.useCharacter = false
  profile.useShared = false
  profile.useClass = true
  profile.useBasic = false
  profile.edit = 3
  profile.editing = classProfile
  profile.shared = profile.shared or "_SHARED1"

  local ok, refreshed, message = pcall(RefreshAutoBarProfile)
  if not ok or not refreshed then
    AutoBar_Config[player] = currentBefore
    if seededClass then
      AutoBar_Config[classProfile] = classBefore
    end
    if madePlayerBackup then
      database.autoBarClassScopePlayerBackups[player] = nil
    end
    if madeClassBackup then
      database.autoBarClassScopeBackups[classProfile] = nil
    end
    database.autoBarClassScopeProfiles[player] = previousProfileKey
    pcall(RefreshAutoBarProfile)
    self.autoBarClassScopeUpdating = false
    self.autoBarClassScopeStatus = "error"
    self.autoBarClassScopeMessage = message
    return false
  end

  playerVersions[player] = self.autoBarClassScopeVersion
  classVersions[classProfile] = self.autoBarClassScopeVersion
  database.autoBarClassScopeOptOut[player] = nil
  self.autoBarClassScopeUpdating = false
  self.autoBarClassScopeStatus = "class-only"
  self:ApplyAutoBarConfigCuration()
  return not alreadyActive or seededClass or selectedTabChanged
end

function ActionBars:OpenAutoBarConfig()
  local toggle = GetGlobal("AutoBarConfig_Toggle")
  if not AutoBar or type(toggle) ~= "function" then
    self.autoBarPresetStatus = "missing"
    return false, "AutoBar is not enabled. Enable it at character select, then /reload."
  end
  self:RepairAutoBarCategoryDescriptions()
  self:InstallFieldKitHooks()
  self:MigrateAutoBarClassScope()
  self:ApplyAutoBarConfigCuration()
  toggle()
  if not self.autoBarConfigShowHooked then
    self:SettleAutoBarFieldKitRefresh()
  end
  self.autoBarPresetStatus = "config-opened"
  return true,
    "AutoBar config opened. Use /aeui autobar apply for the AEUI compact preset."
end

local function AutoBarCategoryDescription(category)
  local fallback = autoBarCategoryDescriptionFallbacks[category]
  if fallback then
    local locale = type(GetLocale) == "function" and GetLocale() or nil
    return fallback[locale] or fallback.default
  end
  return tostring(category)
end

function ActionBars:RepairAutoBarCategoryDescriptions()
  if type(AutoBar_Category_Info) ~= "table" then
    self.autoBarCategoryDescriptionStatus = "unavailable"
    return false
  end

  local repaired = 0
  for category, info in pairs(AutoBar_Category_Info) do
    if type(info) == "table" and
      (type(info.description) ~= "string" or info.description == "")
    then
      info.description = AutoBarCategoryDescription(category)
      repaired = repaired + 1
    end
  end

  if repaired > 0 then
    self.autoBarCategoryDescriptionsRepaired =
      (self.autoBarCategoryDescriptionsRepaired or 0) + repaired
    self.autoBarCategoryDescriptionStatus = "repaired"
  elseif (self.autoBarCategoryDescriptionsRepaired or 0) > 0 then
    self.autoBarCategoryDescriptionStatus = "repaired"
  else
    self.autoBarCategoryDescriptionStatus = "native"
  end
  return true
end

local function AutoBarDisplayFlag(value)
  return value == true or value == 1 or value == "1"
end

local function AutoBarBaseDisplayMatches(display)
  return type(display) == "table" and
    tonumber(display.rows) == 6 and
    tonumber(display.columns) == 4 and
    tonumber(display.gapping) == 3 and
    tonumber(display.alpha) == 10 and
    tonumber(display.buttonWidth) == 36 and
    tonumber(display.buttonHeight) == 36 and
    tonumber(display.alignButtons) == 1 and
    not AutoBarDisplayFlag(display.widthHeightUnlocked) and
    not AutoBarDisplayFlag(display.popupDisable) and
    not AutoBarDisplayFlag(display.popupOnShift)
end

local function RecordAutoBarDefaultMode(player)
  local database = addon.db and addon.db.actionbars
  if not database or not player then
    return false
  end
  database.autoBarDefaultModeVersions =
    database.autoBarDefaultModeVersions or {}
  database.autoBarDefaultModeVersions[player] =
    ActionBars.autoBarDefaultModeVersion
  return true
end

function ActionBars:MigrateAutoBarDefaultMode()
  if not AutoBar or type(AutoBar_Config) ~= "table" then
    return false
  end
  local database = addon.db and addon.db.actionbars
  local player = AutoBar.currentPlayer
  local current = player and AutoBar_Config[player]
  local versions = database and database.autoBarDefaultModeVersions
  if not database or not player or type(current) ~= "table" or
    (type(versions) == "table" and
      versions[player] == self.autoBarDefaultModeVersion)
  then
    return false
  end

  local display = current.display
  if not AutoBarProfileMatches() or
    not AutoBarBaseDisplayMatches(display)
  then
    return false
  end

  local compact = not AutoBarDisplayFlag(display.showEmptyButtons) and
    not AutoBarDisplayFlag(display.showCategoryIcon)
  if compact and AutoBarDisplayFlag(display.hideDragHandle) then
    RecordAutoBarDefaultMode(player)
    self.autoBarPresetStatus = "compact-current"
    return false
  end

  local backups = database.autoBarBackups
  local previouslyApplied = type(backups) == "table" and
    type(backups[player]) == "table"
  local legacyFullMode = AutoBarDisplayFlag(display.showEmptyButtons) and
    AutoBarDisplayFlag(display.showCategoryIcon)
  if not previouslyApplied or not legacyFullMode then
    return false
  end

  local before = CopyPlainTable(current)
  display.showEmptyButtons = false
  display.showCategoryIcon = false
  display.hideDragHandle = 1
  local ok, refreshed, message = pcall(RefreshAutoBarProfile)
  if not ok or not refreshed then
    AutoBar_Config[player] = before
    pcall(RefreshAutoBarProfile)
    self.autoBarPresetStatus = "migration-error"
    self.autoBarPresetMessage = message
    return false
  end

  RecordAutoBarDefaultMode(player)
  self.autoBarPresetStatus = "compact-migrated"
  return true
end

function ActionBars:ApplyRecommendedAutoBarProfile()
  if not AutoBar or type(AutoBar_Config) ~= "table" then
    self.autoBarPresetStatus = "missing"
    return false, "AutoBar is not enabled. Enable it at character select, then /reload."
  end
  local player = AutoBar.currentPlayer
  local current = player and AutoBar_Config[player]
  if not player or type(current) ~= "table" then
    self.autoBarPresetStatus = "unavailable"
    return false, "AutoBar has not initialized the current character profile yet."
  end

  local database = addon.db and addon.db.actionbars
  if not database then
    self.autoBarPresetStatus = "unavailable"
    return false, "AEUI action bar settings are unavailable."
  end
  local initialized = pcall(AutoBarProfile.Initialize)
  local classProfile = initialized and GetAutoBarClassProfileKey() or nil
  local classConfig = classProfile and AutoBar_Config[classProfile]
  if not initialized or not classProfile or type(classConfig) ~= "table" then
    self.autoBarPresetStatus = "unavailable"
    return false, "AutoBar has not initialized the current class profile yet."
  end

  local before = CopyPlainTable(current)
  local classBefore = CopyPlainTable(classConfig)
  local manualSlot = AutoBar.buttons and AutoBar.buttons[16]
  local profile = current.profile or {}
  current.profile = profile
  profile.useCharacter = false
  profile.useShared = false
  profile.useClass = true
  profile.useBasic = false
  profile.layout = 1
  profile.layoutProfile = player
  profile.edit = 3
  profile.editing = classProfile
  profile.shared = profile.shared or "_SHARED1"

  classConfig.buttons = {}
  local class = GetPlayerClassToken()
  for index = 1, 24 do
    classConfig.buttons[index] =
      RecommendedAutoBarSlot(index, class, manualSlot)
  end

  current.display = current.display or {}
  local display = current.display
  display.rows = 6
  display.columns = 4
  display.gapping = 3
  display.alpha = 10
  display.buttonWidth = 36
  display.buttonHeight = 36
  display.widthHeightUnlocked = false
  display.alignButtons = 1
  display.showEmptyButtons = false
  display.showCategoryIcon = false
  display.hideDragHandle = 1
  display.popupDisable = false
  display.popupOnShift = false
  if tonumber(display.selectedTab) ~= 1 and
    tonumber(display.selectedTab) ~= 3
  then
    display.selectedTab = 1
  end

  self.autoBarClassScopeUpdating = true
  local ok, refreshed, message = pcall(RefreshAutoBarProfile)
  self.autoBarClassScopeUpdating = false
  if not ok or not refreshed then
    AutoBar_Config[player] = before
    AutoBar_Config[classProfile] = classBefore
    pcall(RefreshAutoBarProfile)
    self.autoBarPresetStatus = "error"
    return false, message or "AutoBar rejected the AEUI preset; the profile was restored."
  end

  database.autoBarBackups = database.autoBarBackups or {}
  if not database.autoBarBackups[player] then
    database.autoBarBackups[player] = before
  end
  database.autoBarClassScopePlayerVersions =
    database.autoBarClassScopePlayerVersions or {}
  database.autoBarClassScopeClassVersions =
    database.autoBarClassScopeClassVersions or {}
  database.autoBarClassScopeProfiles =
    database.autoBarClassScopeProfiles or {}
  database.autoBarClassScopePlayerBackups =
    database.autoBarClassScopePlayerBackups or {}
  database.autoBarClassScopeBackups =
    database.autoBarClassScopeBackups or {}
  database.autoBarClassScopeOptOut =
    database.autoBarClassScopeOptOut or {}
  if not database.autoBarClassScopePlayerBackups[player] then
    database.autoBarClassScopePlayerBackups[player] =
      CopyPlainTable(database.autoBarBackups[player] or before)
  end
  if not database.autoBarClassScopeBackups[classProfile] then
    database.autoBarClassScopeBackups[classProfile] = classBefore
  end
  database.autoBarClassScopePlayerVersions[player] =
    self.autoBarClassScopeVersion
  database.autoBarClassScopeClassVersions[classProfile] =
    self.autoBarClassScopeVersion
  database.autoBarClassScopeProfiles[player] = classProfile
  database.autoBarClassScopeOptOut[player] = nil
  RecordAutoBarDefaultMode(player)
  self.autoBarClassScopeStatus = "class-only"
  self:ApplyAutoBarConfigCuration()
  self.autoBarPresetStatus = "applied"
  return true,
    "AEUI AutoBar compact preset applied to this class: 24 logical categories, only currently available categories shown in a dynamic grid up to 4x6, with the external popup drawer."
end

function ActionBars:RestoreAutoBarProfile()
  if not AutoBar or type(AutoBar_Config) ~= "table" then
    self.autoBarPresetStatus = "missing"
    return false, "AutoBar is not enabled."
  end
  local player = AutoBar.currentPlayer
  local database = addon.db and addon.db.actionbars
  local backups = database and database.autoBarBackups
  local backup = player and backups and backups[player]
  local scopeBackups = database and
    database.autoBarClassScopePlayerBackups
  local scopeBackup = player and scopeBackups and scopeBackups[player]
  local profileKeys = database and database.autoBarClassScopeProfiles
  local classProfile = player and profileKeys and profileKeys[player]
  classProfile = classProfile or GetAutoBarClassProfileKey()
  local classBackups = database and database.autoBarClassScopeBackups
  local classBackup = classProfile and classBackups and
    classBackups[classProfile]
  if type(backup) ~= "table" and type(scopeBackup) ~= "table" then
    self.autoBarPresetStatus = "no-backup"
    return false, "No AEUI AutoBar backup exists for this character."
  end

  local before = CopyPlainTable(AutoBar_Config[player])
  local classBefore = classProfile and AutoBar_Config[classProfile] and
    CopyPlainTable(AutoBar_Config[classProfile])
  AutoBar_Config[player] = CopyPlainTable(scopeBackup or backup)
  if type(classBackup) == "table" then
    AutoBar_Config[classProfile] = CopyPlainTable(classBackup)
  end
  self.autoBarClassScopeUpdating = true
  local ok, refreshed, message = pcall(RefreshAutoBarProfile)
  self.autoBarClassScopeUpdating = false
  if not ok or not refreshed then
    AutoBar_Config[player] = before
    if classBefore then
      AutoBar_Config[classProfile] = classBefore
    end
    pcall(RefreshAutoBarProfile)
    self.autoBarPresetStatus = "error"
    return false, message or "AutoBar restore failed; the active profile was kept."
  end
  if backups then
    backups[player] = nil
  end
  if scopeBackups then
    scopeBackups[player] = nil
  end
  if classBackups and type(classBackup) == "table" then
    classBackups[classProfile] = nil
  end
  if profileKeys then
    profileKeys[player] = nil
  end
  local playerVersions = database.autoBarClassScopePlayerVersions
  if type(playerVersions) == "table" then
    playerVersions[player] = nil
  end
  local classVersions = database.autoBarClassScopeClassVersions
  if type(classVersions) == "table" and type(classBackup) == "table" then
    classVersions[classProfile] = nil
  end
  database.autoBarClassScopeOptOut =
    database.autoBarClassScopeOptOut or {}
  database.autoBarClassScopeOptOut[player] = true
  local versions = database.autoBarDefaultModeVersions
  if type(versions) == "table" then
    versions[player] = nil
  end
  self.autoBarClassScopeStatus = "restored"
  self:RestoreAutoBarConfigCuration()
  self.autoBarPresetStatus = "restored"
  return true, "AutoBar profile and class slots restored from the pre-AEUI backup."
end

local function NormalizePopupMode(mode)
  mode = string.upper(tostring(mode or "AUTO"))
  if mode == "AUTO" or mode == "LEFT" or mode == "RIGHT" or
    mode == "NATIVE"
  then
    return mode
  end
  return nil
end

local function GetPopupMode()
  local configured = addon.db and addon.db.actionbars and
    addon.db.actionbars.autoBarPopupMode
  return NormalizePopupMode(configured) or "AUTO"
end

function ActionBars:SetAutoBarPopupMode(mode)
  local normalized = NormalizePopupMode(mode)
  if not normalized then
    return false, "Popup mode must be auto, left, right, or native."
  end
  addon.db.actionbars.autoBarPopupMode = normalized
  self:ApplyAutoBarPopup(
    addon.db and addon.db.actionbars and addon.db.actionbars.enabled
  )
  if addon.db and addon.db.actionbars and
    addon.db.actionbars.fieldKitBound == true
  then
    return true, "Bound Field Kit popup remains fixed left; " ..
      string.lower(normalized) .. " is saved for the unbound AutoBar."
  end
  return true, "AutoBar popup mode set to " .. string.lower(normalized) .. "."
end

local function AutoBarGroupingMatches(visibleCount)
  local display = AutoBar and AutoBar.display
  return visibleCount == 24 and display and
    tonumber(display.rows) == 6 and tonumber(display.columns) == 4 and
    AutoBarProfileMatches()
end

local function AutoBarRecommendedLayoutMatches(visibleCount)
  local display = AutoBar and AutoBar.display
  return visibleCount > 0 and visibleCount <= 24 and display and
    tonumber(display.rows) == 6 and tonumber(display.columns) == 4 and
    AutoBarProfileMatches()
end

local function ConfigureShellBounds(shell, bounds, padding)
  if not shell or bounds.count == 0 then
    return false
  end
  shell:ClearAllPoints()
  shell:SetPoint("LEFT", bounds.left, "LEFT", -padding, 0)
  shell:SetPoint("RIGHT", bounds.right, "RIGHT", padding, 0)
  shell:SetPoint("TOP", bounds.top, "TOP", 0, padding)
  shell:SetPoint("BOTTOM", bounds.bottom, "BOTTOM", 0, -padding)
  return true
end

local function ConfigureDivider(divider, overall, first, second)
  local upper = first
  local lower = second
  if second.topValue > first.topValue then
    upper = second
    lower = first
  end
  divider:ClearAllPoints()
  divider:SetPoint("LEFT", overall.left, "LEFT", 0, 0)
  divider:SetPoint("RIGHT", overall.right, "RIGHT", 0, 0)
  divider:SetPoint("TOP", upper.bottom, "BOTTOM", 0, 0)
  divider:SetPoint("BOTTOM", lower.top, "TOP", 0, 0)
end

local function SortPopupButtons(buttons, horizontal)
  table.sort(buttons, function(left, right)
    if horizontal then
      return left:GetLeft() < right:GetLeft()
    end
    return left:GetBottom() < right:GetBottom()
  end)
end

local function FieldKitEnabled()
  return addon.db and addon.db.actionbars and
    addon.db.actionbars.enabled
end

local function SafeFieldKitApply(methodName, argument)
  local method = ActionBars[methodName]
  if type(method) ~= "function" then
    return
  end
  local ok = pcall(
    method, ActionBars, FieldKitEnabled(), argument
  )
  if not ok then
    if methodName == "ApplyTrinketFieldKit" then
      ActionBars.trinketFieldKitStatus = "error"
    else
      ActionBars.autoBarFieldKitStatus = "error"
    end
  end
end

local function GetFieldKitDatabase()
  return addon.db and addon.db.actionbars
end

local function FieldKitBound()
  local database = GetFieldKitDatabase()
  return database and database.fieldKitBound == true
end

local function GetAutoBarLayoutProfile()
  local player = AutoBar and AutoBar.currentPlayer
  local current = player and AutoBar_Config and AutoBar_Config[player]
  local profile = current and current.profile
  if not player or type(current) ~= "table" then
    return nil, nil
  end
  local key = type(profile) == "table" and profile.layoutProfile
  if not key and type(profile) == "table" then
    if tonumber(profile.layout) == 1 then
      key = player
    else
      key = profile.shared
    end
  end
  if not key or type(AutoBar_Config[key]) ~= "table" then
    key = player
  end
  local config = AutoBar_Config[key]
  config.display = config.display or {}
  return key, config.display
end

function ActionBars:CaptureAutoBarProviderDockBackup()
  local database = GetFieldKitDatabase()
  local key, display = GetAutoBarLayoutProfile()
  if not database or not key or type(display) ~= "table" then
    return false
  end
  database.autoBarDockBackups = database.autoBarDockBackups or {}
  if database.autoBarDockBackups[key] then
    return true
  end
  database.autoBarDockBackups[key] = {
    version = self.autoBarDockBackupVersion,
    docking = CaptureField(display, "docking"),
    dockShiftX = CaptureField(display, "dockShiftX"),
    dockShiftY = CaptureField(display, "dockShiftY"),
  }
  return true
end

function ActionBars:RegisterAutoBarProviderDock(xOffset, yOffset)
  local frames = AutoBarConfig and AutoBarConfig.dockingFrames
  if type(frames) ~= "table" then
    self.autoBarProviderDockStatus = "unsupported"
    return false
  end
  frames[self.autoBarProviderDockName] = {
    text = "AEUI Combat Deck",
    offset = {
      x = xOffset,
      y = yOffset,
      point = "CENTER",
      relative = "BOTTOMLEFT",
    },
  }
  self.autoBarProviderDockStatus = "registered"
  return true
end

function ActionBars:ApplyAutoBarProviderDock(xOffset, yOffset)
  local key, display = GetAutoBarLayoutProfile()
  if not key or type(display) ~= "table" or
    not self:RegisterAutoBarProviderDock(xOffset, yOffset)
  then
    return false
  end
  self:CaptureAutoBarProviderDockBackup()
  display.docking = self.autoBarProviderDockName
  display.dockShiftX = 0
  display.dockShiftY = 0
  self.autoBarProviderDockProfile = key
  self.autoBarProviderDockStatus = "bound"
  return true
end

function ActionBars:RestoreAutoBarProviderDock()
  local database = GetFieldKitDatabase()
  local backups = database and database.autoBarDockBackups
  local restored = false
  if type(backups) == "table" and type(AutoBar_Config) == "table" then
    for key, backup in pairs(backups) do
      local config = AutoBar_Config[key]
      local display = type(config) == "table" and config.display
      if type(display) == "table" and type(backup) == "table" and
        backup.version == self.autoBarDockBackupVersion
      then
        RestoreField(display, "docking", backup.docking)
        RestoreField(display, "dockShiftX", backup.dockShiftX)
        RestoreField(display, "dockShiftY", backup.dockShiftY)
        restored = true
      end
    end
    database.autoBarDockBackups = nil
  end
  local frames = AutoBarConfig and AutoBarConfig.dockingFrames
  if type(frames) == "table" then
    frames[self.autoBarProviderDockName] = nil
  end
  self.autoBarProviderDockProfile = nil
  self.autoBarProviderDockStatus = restored and "restored" or "free"
  return restored
end

function ActionBars:PrepareLogout()
  -- The provider serializes display.docking verbatim. Keep the AEUI-only
  -- docking token out of SavedVariables so AutoBar can always initialize
  -- safely before pfUI/AEUI on the next login; Apply() reinstalls the native
  -- runtime dock after both providers are available.
  self:RestoreAutoBarProviderDock()
  return true
end

function ActionBars:RestoreSideBarGroupMover()
  local root = GetSideBarFrame(sideBarGroupDefinitions[1])
  local drag = root and root.drag
  local unlock = pfUI and pfUI.unlock
  if not drag then
    return false
  end
  local state = drag.aeuiSideBarGroupMoverV1
  if state and state.points then
    RestoreFrameAnchors(drag, state.points)
  elseif drag.SetAllPoints then
    drag:SetAllPoints(root)
  end
  if state and state.label and drag.text and drag.text.SetText then
    drag.text:SetText(state.label)
  end
  if unlock and unlock.IsShown and unlock:IsShown() then
    for index = 2, table.getn(sideBarGroupDefinitions) do
      local frame = GetSideBarFrame(sideBarGroupDefinitions[index])
      if frame and frame.drag then
        frame.drag:Show()
      end
    end
  end
  return true
end

function ActionBars:ConfigureSideBarGroupMover()
  if not SideBarGroupBound() then
    return self:RestoreSideBarGroupMover()
  end
  local root = GetSideBarFrame(sideBarGroupDefinitions[1])
  local bottomRight = GetSideBarFrame(sideBarGroupDefinitions[4])
  local drag = root and root.drag
  if not root or not bottomRight or not drag or
    not drag.ClearAllPoints or not drag.SetPoint
  then
    return false
  end

  local state = drag.aeuiSideBarGroupMoverV1
  if not state then
    state = {
      points = CaptureFrameAnchors(drag),
      label = drag.text and drag.text.GetText and drag.text:GetText() or
        "ActionBarPaging",
      mouseWheel = drag.GetScript and drag:GetScript("OnMouseWheel"),
      dragStop = drag.GetScript and drag:GetScript("OnDragStop"),
      click = drag.GetScript and drag:GetScript("OnClick"),
    }
    drag.aeuiSideBarGroupMoverV1 = state
    if drag.SetScript then
      drag:SetScript("OnMouseWheel", function()
        if state.mouseWheel then
          state.mouseWheel()
        end
        if SideBarGroupBound() then
          ActionBars:SyncSideBarGroupScale()
          ActionBars:PersistSideBarGroupPositions()
          ActionBars:ConfigureSideBarGroupMover()
        end
      end)
      drag:SetScript("OnDragStop", function()
        if state.dragStop then
          state.dragStop()
        end
        if SideBarGroupBound() then
          ActionBars:SyncSideBarGroupScale()
          ActionBars:PersistSideBarGroupPositions()
          ActionBars:ConfigureSideBarGroupMover()
        end
      end)
      drag:SetScript("OnClick", function()
        if SideBarGroupBound() and arg1 == "MiddleButton" then
          ActionBars:ResetSideBarGroupPosition()
          return
        end
        if state.click then
          state.click()
        end
      end)
    end
  end

  drag:ClearAllPoints()
  drag:SetPoint("TOPLEFT", root, "TOPLEFT", 0, 0)
  drag:SetPoint("BOTTOMRIGHT", bottomRight, "BOTTOMRIGHT", 0, 0)
  if drag.text and drag.text.SetText then
    drag.text:SetText("Side Bars 6 x 8")
  end
  drag:Show()
  for index = 2, table.getn(sideBarGroupDefinitions) do
    local frame = GetSideBarFrame(sideBarGroupDefinitions[index])
    if frame and frame.drag then
      frame.drag:Hide()
    end
  end
  return true
end

function ActionBars:UpdateFieldKitUnlockMover()
  local unlock = pfUI and pfUI.unlock
  local top = GetTopActionBarFrame()
  if not unlock or type(unlock.IsShown) ~= "function" or
    not unlock:IsShown()
  then
    return false
  end

  local hidden = false
  if FieldKitEnabled() and FieldKitBound() then
    if top and top.drag then
      top.drag:Hide()
      hidden = true
    end
  elseif top and top.drag then
    top.drag:Show()
  end

  local targetTarget = pfUI and pfUI.uf and pfUI.uf.targettarget or
    GetGlobal("pfTargetTarget")
  if targetTarget and targetTarget.drag then
    if FocusUnitLayoutActive() then
      targetTarget.drag:Hide()
      hidden = true
    else
      targetTarget.drag:Show()
    end
  end
  local stance = GetGlobal("pfActionBarStances")
  if stance and stance.drag then
    if CombatFocusLayoutActive() or
      (FieldKitEnabled() and FieldKitBound())
    then
      stance.drag:Hide()
      hidden = true
    else
      stance.drag:Show()
    end
  end
  if SideBarGroupBound() then
    if self:ConfigureSideBarGroupMover() then
      hidden = true
    end
  else
    self:RestoreSideBarGroupMover()
  end
  return hidden
end

function ActionBars:InstallFieldKitUnlockHooks()
  local unlock = pfUI and pfUI.unlock
  if self.fieldKitUnlockHooked or not unlock or
    type(unlock.GetScript) ~= "function" or
    type(unlock.SetScript) ~= "function"
  then
    return false
  end

  local originalShow = unlock:GetScript("OnShow")
  local originalHide = unlock:GetScript("OnHide")
  unlock:SetScript("OnShow", function()
    if originalShow then
      originalShow()
    end
    ActionBars:UpdateFieldKitUnlockMover()
  end)
  unlock:SetScript("OnHide", function()
    if originalHide then
      originalHide()
    end
    ActionBars:ApplyCombatDeckGroup()
    ActionBars:ApplyFocusRelativeAnchors()
    if SideBarGroupBound() then
      ActionBars:ApplySideBarGroupAnchors()
      ActionBars:PersistSideBarGroupPositions()
    end
  end)
  self.fieldKitUnlockHooked = true
  return true
end

local function GetActionBarStackOverlap()
  local bars = pfUI_config and pfUI_config.bars
  local configured = bars and bars.bar1 and bars.bar1.spacing
  return tonumber(configured) or ActionBars.actionBarStackOverlap
end

function ActionBars:ApplyActionBarStackPosition(enabled)
  local main = GetMainActionBarFrame()
  local top = GetTopActionBarFrame()
  local bound = FieldKitBound()

  if not enabled or not bound then
    if self.actionBarStackApplied then
      RestoreFrameAnchors(top, self.actionBarTopFreeAnchors)
    end
    self.actionBarStackApplied = false
    self.actionBarTopFreeAnchors = nil
    self.actionBarStackStatus = enabled and "free" or "disabled"
    self:UpdateFieldKitUnlockMover()
    return false
  end

  if not main or not top or main == top then
    self.actionBarStackStatus = "unavailable"
    return false
  end

  if not self.actionBarStackApplied then
    self.actionBarTopFreeAnchors = CaptureFrameAnchors(top)
  end

  top:ClearAllPoints()
  top:SetPoint(
    "BOTTOM", main, "TOP", 0, -GetActionBarStackOverlap()
  )
  if type(top.OnMove) == "function" then
    pcall(top.OnMove, top)
  end
  self.actionBarStackApplied = true
  self.actionBarStackStatus = "12x2-bound"
  self:UpdateFieldKitUnlockMover()
  return true
end

function ActionBars:ApplyStanceDockPosition(enabled)
  local bound = FieldKitBound()
  local frame = GetGlobal("pfActionBarStances")

  if not enabled or not bound then
    if self.stanceDockApplied then
      RestoreFrameAnchors(frame, self.stanceFreeAnchors)
    end
    self.stanceDockApplied = false
    self.stanceFreeAnchors = nil
    self.stanceDockStatus = enabled and "free" or "disabled"
    return false
  end

  local main = GetMainActionBarFrame()
  if not frame or not main or not frame.ClearAllPoints or
    not frame.SetPoint
  then
    self.stanceDockStatus = "unavailable"
    return false
  end

  if not self.stanceDockApplied then
    local anchors = CaptureFrameAnchors(frame)
    if not anchors or table.getn(anchors) == 0 then
      self.stanceDockStatus = "unavailable"
      return false
    end
    self.stanceFreeAnchors = anchors
  end

  -- Position belongs to the Combat Deck combination, not Combat Focus. This
  -- keeps copied or fresh account-level AEUI data from leaving warrior
  -- stances at the old centre while ArchiTotem occupies the class slot.
  frame:ClearAllPoints()
  frame:SetPoint(
    "TOP", main, "BOTTOM", self.combatDeckClassDockXOffset,
    -self.combatDeckStanceGap
  )
  if CombatFocusLayoutActive() and frame.SetScale then
    frame:SetScale(self.focusStanceScale)
  end
  self.stanceDockApplied = true
  self.stanceDockStatus = "shared-class-slot"
  return true
end

function ActionBars:ApplyCombatDeckGroup()
  if not FieldKitEnabled() or not FieldKitBound() then
    self:ApplyStanceDockPosition(FieldKitEnabled())
    self:UpdateFieldKitUnlockMover()
    self.combatDeckGroupStatus = "free"
    return false
  end

  local main = GetMainActionBarFrame()
  if not main then
    self.combatDeckGroupStatus = "unavailable"
    return false
  end

  self:ApplyActionBarStackPosition(true)
  self:ApplyStanceDockPosition(true)

  local handle = GetGlobal("AutoBarAnchorFrameHandle")
  local bounds = GetButtonExtremes(1, 24, "AutoBarFrameButton")
  if handle then
    self:ApplyConsumableDockPosition(true, bounds)
    self:ApplyAutoBarDragHandlePolicy(true)
  end
  self:ApplyTrinketDockPosition(true)
  self:ApplyArchiTotemDockPosition(true)
  self.combatDeckGroupStatus = "bound"
  return true
end

local function InstallCombatDeckFrameScript(frame, scriptName)
  if not frame or type(frame.GetScript) ~= "function" or
    type(frame.SetScript) ~= "function"
  then
    return false
  end
  frame.aeuiCombatDeckScripts = frame.aeuiCombatDeckScripts or {}
  local current = frame:GetScript(scriptName)
  local existing = frame.aeuiCombatDeckScripts[scriptName]
  if existing and current == existing.wrapper then
    return true
  end
  local state = { original = current }
  state.wrapper = function()
    if state.original then
      state.original()
    end
    ActionBars:InstallCombatDeckGroupHooks()
    ActionBars:ApplyCombatDeckGroup()
  end
  frame.aeuiCombatDeckScripts[scriptName] = state
  frame:SetScript(scriptName, state.wrapper)
  return true
end

function ActionBars:InstallCombatDeckGroupHooks()
  if not self.combatDeckAutoBarWrapper and
    type(GetGlobal("AutoBar_SetupVisual")) == "function"
  then
    self.combatDeckAutoBarOriginal = GetGlobal("AutoBar_SetupVisual")
    self.combatDeckAutoBarWrapper = function()
      ActionBars.combatDeckAutoBarOriginal()
      ActionBars:ApplyCombatDeckGroup()
    end
    AutoBar_SetupVisual = self.combatDeckAutoBarWrapper
  end

  InstallCombatDeckFrameScript(
    GetGlobal("pfActionBarStances"), "OnEvent"
  )
  local pet = GetGlobal("pfActionBarPet")
  InstallCombatDeckFrameScript(pet, "OnEvent")
  InstallCombatDeckFrameScript(pet, "OnShow")
  InstallCombatDeckFrameScript(pet, "OnHide")
end

local function ConsumableVisualEdges(bounds)
  if not bounds or bounds.count == 0 or not bounds.right or
    not bounds.bottom
  then
    return nil, nil
  end
  local right = FrameCoordinatePixels(bounds.right, "GetRight")
  local bottom = FrameCoordinatePixels(bounds.bottom, "GetBottom")
  if not right or not bottom then
    return nil, nil
  end
  right = right +
    ActionBars.fieldKitShellPadding * GetFrameScale(bounds.right)
  bottom = bottom -
    ActionBars.fieldKitShellPadding * GetFrameScale(bounds.bottom)
  return right, bottom
end

local function AutoBarLocalVisualOffsets(handle)
  if not handle then
    return nil, nil, nil
  end

  local rightEdge = nil
  local bottomEdge = nil
  local rackScale = nil
  local count = 0

  for index = 1, 24 do
    local button = GetGlobal("AutoBarFrameButton" .. index)
    if button and button.IsShown and button:IsShown() and
      not button.forceHidden
    then
      if not button.GetPoint or not button.GetWidth or
        not button.GetHeight
      then
        return nil, nil, nil
      end

      local point, relative, relativePoint, xOffset, yOffset =
        button:GetPoint(1)
      if type(relative) == "string" then
        relative = GetGlobal(relative)
      end
      if relative ~= handle or relativePoint ~= "CENTER" then
        return nil, nil, nil
      end

      point = tostring(point or "")
      xOffset = tonumber(xOffset) or 0
      yOffset = tonumber(yOffset) or 0
      local width = tonumber(button:GetWidth())
      local height = tonumber(button:GetHeight())
      if not width or not height then
        return nil, nil, nil
      end
      local buttonScale = GetFrameScale(button)
      if rackScale and math.abs(buttonScale - rackScale) > 0.0001 then
        return nil, nil, nil
      end
      rackScale = buttonScale

      local right = xOffset + width / 2
      if string.find(point, "LEFT", 1, true) then
        right = xOffset + width
      elseif string.find(point, "RIGHT", 1, true) then
        right = xOffset
      end

      local bottom = yOffset - height / 2
      if string.find(point, "BOTTOM", 1, true) then
        bottom = yOffset
      elseif string.find(point, "TOP", 1, true) then
        bottom = yOffset - height
      end

      right = right * buttonScale
      bottom = bottom * buttonScale
      count = count + 1
      if not rightEdge or right > rightEdge then
        rightEdge = right
      end
      if not bottomEdge or bottom < bottomEdge then
        bottomEdge = bottom
      end
    end
  end

  if count == 0 or not rightEdge or not bottomEdge or not rackScale then
    return nil, nil, nil
  end

  return
    rightEdge + ActionBars.fieldKitShellPadding * rackScale,
    bottomEdge - ActionBars.fieldKitShellPadding * rackScale,
    rackScale
end

local function AutoBarProviderVisualOffsets()
  local display = AutoBar and AutoBar.display
  if type(display) ~= "table" or not AutoBar or
    type(AutoBar.AssignButtons) ~= "function"
  then
    return nil, nil, nil
  end

  local ok, assigned = pcall(AutoBar.AssignButtons, AutoBar)
  local rows = math.max(1, math.floor(tonumber(display.rows) or 1))
  local columns = math.max(
    1, math.floor(tonumber(display.columns) or 1)
  )
  local count = ok and math.min(
    math.max(0, math.floor(tonumber(assigned) or 0)),
    rows * columns,
    24
  ) or 0
  if count == 0 then
    return nil, nil, nil
  end

  local first = GetGlobal("AutoBarFrameButton1")
  local width = tonumber(display.buttonWidth) or
    (first and first.GetWidth and tonumber(first:GetWidth())) or 36
  local height = tonumber(display.buttonHeight) or
    (first and first.GetHeight and tonumber(first:GetHeight())) or 36
  local gap = tonumber(display.gapping) or 3
  local align = tonumber(display.alignButtons) or 1
  local displayedColumns = math.min(count, columns)
  local displayedRows = math.floor((count - 1) / columns) + 1
  local xStep = width + gap
  local yStep = height + gap
  local point = "BOTTOMLEFT"
  local centerShiftX = 0
  local centerShiftY = 0

  if align == 2 then
    centerShiftX = -0.5 * displayedColumns * xStep + gap / 2
  elseif align == 3 then
    xStep = -xStep
    point = "BOTTOMRIGHT"
  elseif align == 4 then
    xStep = -xStep
    point = "BOTTOMRIGHT"
    centerShiftY = -0.5 * displayedRows * yStep + gap / 2
  elseif align == 5 then
    centerShiftX = -0.5 * displayedColumns * xStep + gap / 2
    centerShiftY = -0.5 * displayedRows * yStep + gap / 2
  elseif align == 6 then
    centerShiftY = -0.5 * displayedRows * yStep + gap / 2
  elseif align == 7 then
    xStep = -xStep
    yStep = -yStep
    point = "TOPRIGHT"
  elseif align == 8 then
    yStep = -yStep
    point = "TOPLEFT"
    centerShiftX = -0.5 * displayedColumns * xStep + gap / 2
  elseif align == 9 then
    yStep = -yStep
    point = "TOPLEFT"
  end

  local rightEdge = nil
  local bottomEdge = nil
  for index = 1, count do
    local xOffset = math.mod(index - 1, columns) * xStep +
      centerShiftX
    local yOffset = math.floor((index - 1) / columns) * yStep +
      centerShiftY
    local right = xOffset + width / 2
    local bottom = yOffset - height / 2
    if string.find(point, "LEFT", 1, true) then
      right = xOffset + width
    elseif string.find(point, "RIGHT", 1, true) then
      right = xOffset
    end
    if string.find(point, "BOTTOM", 1, true) then
      bottom = yOffset
    elseif string.find(point, "TOP", 1, true) then
      bottom = yOffset - height
    end
    if not rightEdge or right > rightEdge then
      rightEdge = right
    end
    if not bottomEdge or bottom < bottomEdge then
      bottomEdge = bottom
    end
  end

  local rackScale = GetFrameScale(first)
  return
    (rightEdge + ActionBars.fieldKitShellPadding) * rackScale,
    (bottomEdge - ActionBars.fieldKitShellPadding) * rackScale,
    rackScale
end

local function AutoBarVisualOffsets(handle)
  local right, bottom, scale = AutoBarProviderVisualOffsets()
  if right and bottom and scale then
    return right, bottom, scale, "provider-layout"
  end
  right, bottom, scale = AutoBarLocalVisualOffsets(handle)
  return right, bottom, scale, "provider-local"
end

function ActionBars:ResolveAutoBarBoundOffsets(handle)
  local handleScale = GetFrameScale(handle)
  local rightDelta, bottomDelta, rackScale =
    AutoBarVisualOffsets(handle)
  if rightDelta and bottomDelta and rackScale then
    return
      (-self.consumableDockGap * rackScale - rightDelta) / handleScale,
      (self.fieldKitDockYOffset * rackScale - bottomDelta) / handleScale
  end
  return self.autoBarBoundOffsetX, self.autoBarBoundOffsetY
end

function ActionBars:InstallAutoBarHandlePointLock()
  local handle = GetGlobal("AutoBarAnchorFrameHandle")
  if not handle or type(handle.SetPoint) ~= "function" then
    self.autoBarHandlePointLockStatus = "missing"
    return false
  end

  local state = handle.aeuiCombatDeckPointLockV1
  if state and handle.SetPoint == state.wrapper then
    self.autoBarHandlePointLockStatus = "locked"
    return true
  end

  state = { original = handle.SetPoint }
  state.wrapper = function(frame, ...)
    local arguments = arg
    if FieldKitEnabled() and FieldKitBound() then
      local main = GetMainActionBarFrame()
      local xOffset, yOffset =
        ActionBars:ResolveAutoBarBoundOffsets(frame)
      if main and xOffset and yOffset then
        state.original(
          frame, "CENTER", main, "BOTTOMLEFT", xOffset, yOffset
        )
        ActionBars.autoBarDockApplied = true
        ActionBars.autoBarBoundOffsetX = xOffset
        ActionBars.autoBarBoundOffsetY = yOffset
        ActionBars.autoBarBoundAnchors = CaptureFrameAnchors(frame)
        ActionBars.autoBarAnchorBasis = "setpoint-lock"
        ActionBars.consumableDockStatus = "left"
        ActionBars.autoBarHandlePointLockStatus = "locked"
        return
      end
    end
    return state.original(frame, unpack(arguments))
  end
  handle.aeuiCombatDeckPointLockV1 = state
  handle.SetPoint = state.wrapper
  self.autoBarHandlePointLockStatus = "locked"
  return true
end

function ActionBars:RestoreAutoBarHandlePointLock()
  local handle = GetGlobal("AutoBarAnchorFrameHandle")
  local state = handle and handle.aeuiCombatDeckPointLockV1
  if state and handle.SetPoint == state.wrapper then
    handle.SetPoint = state.original
  end
  if handle then
    handle.aeuiCombatDeckPointLockV1 = nil
  end
  self.autoBarHandlePointLockStatus = "free"
end

local function GetVisibleAutoBarButtons()
  local buttons = {}
  for index = 1, 24 do
    local button = GetGlobal("AutoBarFrameButton" .. index)
    if button and button.IsShown and button:IsShown() and
      not button.forceHidden and button.effectiveButton
    then
      table.insert(buttons, button)
    end
  end
  return buttons
end

function ActionBars:GetAutoBarDockRoot(main)
  local root = self.autoBarDockRoot or
    GetGlobal("AzerothExpeditionUIAutoBarDockRoot")
  if not root then
    root = CreateFrame(
      "Frame", "AzerothExpeditionUIAutoBarDockRoot", UIParent
    )
    root:Hide()
  end
  self.autoBarDockRoot = root
  root:ClearAllPoints()
  root:SetPoint(
    "BOTTOMRIGHT", main, "BOTTOMLEFT",
    -self.consumableDockGap, self.fieldKitDockYOffset
  )
  return root
end

function ActionBars:RestoreAutoBarButtonDock()
  local layouts = self.autoBarNativeButtonAnchors
  if type(layouts) == "table" then
    for index = 1, 24 do
      RestoreFrameAnchors(
        GetGlobal("AutoBarFrameButton" .. index), layouts[index]
      )
    end
  end
  local root = self.autoBarDockRoot or
    GetGlobal("AzerothExpeditionUIAutoBarDockRoot")
  if root then
    root:Hide()
  end
  self.autoBarNativeButtonAnchors = nil
  self.autoBarDockApplied = false
  self.autoBarDockRowsApplied = nil
  self.autoBarDockGrowth = nil
end

function ActionBars:ApplyAutoBarButtonDock(enabled)
  if not enabled or not FieldKitBound() then
    self:RestoreAutoBarButtonDock()
    self.autoBarAnchorBasis = enabled and "free" or "disabled"
    self.consumableDockStatus = enabled and "free" or "disabled"
    return false
  end

  local main = GetMainActionBarFrame()
  local buttons = GetVisibleAutoBarButtons()
  if not main or table.getn(buttons) == 0 then
    self.autoBarAnchorBasis = "layout-pending"
    self.consumableDockStatus = "unavailable"
    return false
  end

  local root = self:GetAutoBarDockRoot(main)
  local handle = GetGlobal("AutoBarAnchorFrameHandle")
  local padding = self.fieldKitShellPadding
  local gap = tonumber(AutoBar and AutoBar.display and
    AutoBar.display.gapping) or 3
  local count = table.getn(buttons)
  local columns = math.min(self.autoBarDockColumns, count)
  local rows = math.floor((count - 1) / self.autoBarDockColumns) + 1
  local buttonWidth = 0
  local buttonHeight = 0

  self.autoBarNativeButtonAnchors =
    self.autoBarNativeButtonAnchors or {}
  for index = 1, count do
    local button = buttons[index]
    local _, relative = button:GetPoint(1)
    if type(relative) == "string" then
      relative = GetGlobal(relative)
    end
    if relative == handle then
      local _, _, buttonIndex = string.find(
        button:GetName() or "", "(%d+)$"
      )
      buttonIndex = tonumber(buttonIndex)
      if buttonIndex then
        self.autoBarNativeButtonAnchors[buttonIndex] =
          CaptureFrameAnchors(button)
      end
    end
    buttonWidth = math.max(
      buttonWidth, tonumber(button:GetWidth()) or 0
    )
    buttonHeight = math.max(
      buttonHeight, tonumber(button:GetHeight()) or 0
    )
  end

  local width = padding * 2 + columns * buttonWidth +
    math.max(0, columns - 1) * gap
  local height = padding * 2 + rows * buttonHeight +
    math.max(0, rows - 1) * gap
  root:SetWidth(math.max(1, width))
  root:SetHeight(math.max(1, height))
  root:Show()

  -- The first row is the bottom row. Its right edge stays fixed to the main
  -- action bar through root:BOTTOMRIGHT -> main:BOTTOMLEFT. Buttons fill four
  -- columns left-to-right, then each new row grows upward.
  for index = 1, count do
    local button = buttons[index]
    local column = math.mod(index - 1, self.autoBarDockColumns)
    local row = math.floor((index - 1) / self.autoBarDockColumns)
    button:ClearAllPoints()
    if row == 0 and column == 0 then
      button:SetPoint(
        "BOTTOMLEFT", root, "BOTTOMLEFT", padding, padding
      )
    elseif column == 0 then
      button:SetPoint(
        "BOTTOMLEFT", buttons[index - self.autoBarDockColumns],
        "TOPLEFT", 0, gap
      )
    else
      button:SetPoint("LEFT", buttons[index - 1], "RIGHT", gap, 0)
    end
  end

  self.autoBarDockApplied = true
  self.autoBarBoundAnchors = nil
  self.autoBarBoundOffsetX = nil
  self.autoBarBoundOffsetY = nil
  self.autoBarDockRowsApplied = rows
  self.autoBarDockGrowth = "up"
  self.autoBarAnchorBasis = "button-grid-4col-up"
  self.autoBarProviderDockStatus = "bypassed-button-grid"
  self.consumableDockStatus = "left"
  return true
end

function ActionBars:ApplyConsumableDockPosition(enabled, bounds)
  -- AutoBar's drag handle is not its visual root: SetupVisual positions every
  -- button against that handle and may rewrite it again.  Dock the actual
  -- visible buttons to one AEUI root instead, exactly as TrinketMenu docks its
  -- own root.  Provider layout changes remain internal to the next refresh.
  self:RestoreAutoBarHandlePointLock()
  self:RestoreAutoBarProviderDock()
  return self:ApplyAutoBarButtonDock(enabled)
end

function ActionBars:ApplyAutoBarDragHandlePolicy(enabled)
  local handle = GetGlobal("AutoBarAnchorFrameHandle")
  if not handle then
    self.autoBarDragHandleStatus = "missing"
    return false
  end

  if enabled and FieldKitBound() then
    if type(handle.Hide) ~= "function" then
      self.autoBarDragHandleStatus = "unsupported"
      return false
    end
    handle:Hide()
    self.autoBarDragHandleStatus = "hidden-bound"
    return true
  end

  local display = AutoBar and AutoBar.display
  if type(display) ~= "table" then
    self.autoBarDragHandleStatus = "provider"
    return false
  end

  if AutoBarDisplayFlag(display.hideDragHandle) then
    if type(handle.Hide) ~= "function" then
      self.autoBarDragHandleStatus = "unsupported"
      return false
    end
    handle:Hide()
    self.autoBarDragHandleStatus = "hidden-provider"
  else
    if type(handle.Show) ~= "function" then
      self.autoBarDragHandleStatus = "unsupported"
      return false
    end
    handle:Show()
    self.autoBarDragHandleStatus = "visible-provider"
  end
  return true
end

function ActionBars:RestoreAutoBarBoundAnchor()
  return self:ApplyAutoBarButtonDock(FieldKitEnabled())
end

function ActionBars:ApplyTrinketDockPosition(enabled)
  local docked = FieldKitBound()
  local frame = GetGlobal("TrinketMenu_MainFrame")
  local main = GetMainActionBarFrame()

  if not enabled or not docked then
    if self.trinketDockApplied then
      RestoreFrameAnchors(frame, self.trinketUndockedAnchors)
    end
    self.trinketDockApplied = false
    self.trinketUndockedAnchors = nil
    self.trinketDockStatus = enabled and "free" or "disabled"
    return false
  end
  if not frame or not main then
    self.trinketDockStatus = "unavailable"
    return false
  end
  if not self.trinketDockApplied then
    self.trinketUndockedAnchors = CaptureFrameAnchors(frame)
  end
  frame:ClearAllPoints()
  frame:SetPoint(
    "BOTTOMLEFT", main, "BOTTOMRIGHT",
    self.trinketDockGap, self.fieldKitDockYOffset
  )
  self.trinketDockApplied = true
  self.trinketDockStatus = "right"
  return true
end

function ActionBars:ApplyArchiTotemDockPosition(enabled)
  local bound = FieldKitBound()
  local frame = GetGlobal("ArchiTotemFrame")

  if not enabled or not bound then
    if self.archiTotemDockApplied then
      RestoreFrameAnchors(frame, self.archiTotemFreeAnchors)
    end
    self.archiTotemDockApplied = false
    self.archiTotemFreeAnchors = nil
    self.archiTotemDockStatus = enabled and "free" or "disabled"
    return false
  end

  local auditedFrame, providerStatus = AuditArchiTotemProvider()
  local main = GetMainActionBarFrame()
  if not auditedFrame or not main then
    if self.archiTotemDockApplied then
      RestoreFrameAnchors(frame, self.archiTotemFreeAnchors)
    end
    self.archiTotemDockApplied = false
    self.archiTotemFreeAnchors = nil
    self.archiTotemDockStatus = auditedFrame and
      "unavailable" or providerStatus
    self.archiTotemDirectionStatus =
      GetArchiTotemDirection() or providerStatus
    return false
  end

  if not self.archiTotemDockApplied then
    local anchors = CaptureFrameAnchors(auditedFrame)
    if not anchors or table.getn(anchors) == 0 then
      self.archiTotemDockStatus = "unavailable"
      return false
    end
    self.archiTotemFreeAnchors = anchors
  end

  auditedFrame:ClearAllPoints()
  -- ArchiTotem 1.7 omits its unscaled 20 UI drag handle from the root width.
  -- The -138 UI x offset combines the old -10 UI visible-union correction
  -- with the new 128 UI separation from the marker icon board.
  auditedFrame:SetPoint(
    "CENTER", main, "BOTTOM",
    self.archiTotemDockXOffset,
    self.archiTotemDockYOffset
  )
  self.archiTotemDockApplied = true
  self.archiTotemDockStatus = "bottom-left-separated"
  self.archiTotemDirectionStatus =
    GetArchiTotemDirection() or "unknown"
  return true
end

function ActionBars:HandleAutoBarDragStop()
  if not FieldKitEnabled() then
    return
  end
  if not FieldKitBound() then
    self.consumableDockStatus = "free"
    return
  end
  local bounds = GetButtonExtremes(1, 24, "AutoBarFrameButton")
  self:ApplyConsumableDockPosition(true, bounds)
  self:ApplyAutoBarDragHandlePolicy(true)
end

function ActionBars:HandleTrinketDragStop()
  if not FieldKitEnabled() then
    return
  end
  if not FieldKitBound() then
    self.trinketDockStatus = "free"
    return
  end
  self:ApplyTrinketDockPosition(true)
end

function ActionBars:HandleArchiTotemDragStop()
  if not FieldKitEnabled() then
    return
  end
  if not FieldKitBound() then
    self.archiTotemDockStatus = "free"
    return
  end
  self:ApplyArchiTotemDockPosition(true)
end

local function RefreshTargetMarkerAnchor()
  local markers = addon.modules and addon.modules.TargetMarkers
  if not markers or type(markers.ApplyAnchor) ~= "function" then
    return
  end
  pcall(markers.ApplyAnchor, markers)
end

function ActionBars:SetFieldKitDocking(docked)
  local database = GetFieldKitDatabase()
  if not database then
    return false, "Action bar settings are unavailable."
  end
  database.fieldKitBound = docked and true or false
  -- Keep the v1.2 keys synchronized for SavedVariables compatibility.
  database.consumableDocked = database.fieldKitBound
  database.trinketDocked = database.fieldKitBound
  if docked then
    self:ApplyActionBarStackPosition(FieldKitEnabled())
    self:ApplyStanceDockPosition(FieldKitEnabled())
    local bounds = GetButtonExtremes(1, 24, "AutoBarFrameButton")
    self:ApplyConsumableDockPosition(FieldKitEnabled(), bounds)
    self:ApplyAutoBarDragHandlePolicy(FieldKitEnabled())
    self:ApplyTrinketDockPosition(FieldKitEnabled())
    self:ApplyArchiTotemDockPosition(FieldKitEnabled())
    RefreshTargetMarkerAnchor()
    self:UpdateFieldKitUnlockMover()
    return true,
      "Combat Deck bound: consumables left and trinkets right share a 20 UI lower dock, 12x2 action bars stay centered, and warrior stances or detected ArchiTotem share the class slot below-left of the marker list. Move the main action bar to move the whole deck."
  end
  self:ApplyActionBarStackPosition(FieldKitEnabled())
  self:ApplyStanceDockPosition(FieldKitEnabled())
  self:ApplyConsumableDockPosition(FieldKitEnabled())
  self:ApplyAutoBarDragHandlePolicy(FieldKitEnabled())
  self:ApplyTrinketDockPosition(FieldKitEnabled())
  self:ApplyArchiTotemDockPosition(FieldKitEnabled())
  RefreshTargetMarkerAnchor()
  self:UpdateFieldKitUnlockMover()
  self.consumableDockStatus = "free"
  self.trinketDockStatus = "free"
  self.archiTotemDockStatus = "free"
  return true,
    "Combat Deck unbound; action bars, Field Kit providers, and ArchiTotem are independent."
end

function ActionBars:ResetCombatDeckPosition()
  if type(InCombatLockdown) == "function" and InCombatLockdown() then
    return false, "Leave combat before resetting the Combat Deck position."
  end
  local main = GetMainActionBarFrame()
  if not main or not UIParent then
    return false, "The main action bar or UIParent is unavailable."
  end

  if main.SetParent then
    main:SetParent(UIParent)
  end
  local applied = ApplyFramePosition(
    main, "BOTTOM", self.combatDeckX, self.combatDeckY
  )
  if not applied then
    return false, "The main action bar could not use its game coordinates."
  end

  if pfUI_config and type(pfUI_config.position) == "table" and
    main.GetName
  then
    local name = main:GetName()
    SavePfUIPosition(
      name, "BOTTOM", self.combatDeckX, self.combatDeckY,
      main.GetScale and tonumber(main:GetScale()) or nil
    )
  end

  local database = GetFieldKitDatabase()
  if database then
    database.combatDeckLayoutVersion = 1
  end
  self:SetFieldKitDocking(true)
  return true,
    "Combat Deck reset to BOTTOM (0, 175) in Turtle WoW game coordinates and strongly bound."
end

local function EnsureAutoBarShell(frame)
  local shell = frame.aeuiConsumableKitShellV1
  if not shell then
    shell = CreateDecorationFrame(frame)
    EnsureNineSlice(
      shell,
      "aeuiConsumableKitNineSliceV1",
      ActionBars.consumableKitTexturePath,
      consumableKitTexCoords.C,
      ActionBars.fieldKitCap
    )
    frame.aeuiConsumableKitShellV1 = shell
  end
  return shell
end

local function EnsureAutoBarDivider(frame, index)
  frame.aeuiConsumableKitDividersV1 =
    frame.aeuiConsumableKitDividersV1 or {}
  local divider = frame.aeuiConsumableKitDividersV1[index]
  if not divider then
    divider = CreateDecorationFrame(frame)
    EnsureConnector(
      divider,
      "aeuiConsumableKitDividerV1",
      ActionBars.consumableKitTexturePath,
      consumableKitTexCoords.horizontal,
      "HORIZONTAL",
      2
    )
    frame.aeuiConsumableKitDividersV1[index] = divider
  end
  return divider
end

local function SetAutoBarGroupingEnabled(frame, enabled, overall)
  local labels = frame.aeuiConsumableKitLabelsV1
  local dividers = frame.aeuiConsumableKitDividersV1
  if not enabled then
    if labels then
      for index = 1, table.getn(labels) do
        labels[index]:Hide()
      end
    end
    if dividers then
      for index = 1, table.getn(dividers) do
        dividers[index]:Hide()
      end
    end
    return false
  end

  local group1 = GetButtonExtremes(1, 8, "AutoBarFrameButton")
  local group2 = GetButtonExtremes(9, 16, "AutoBarFrameButton")
  local group3 = GetButtonExtremes(17, 24, "AutoBarFrameButton")
  if group1.count ~= 8 or group2.count ~= 8 or group3.count ~= 8 then
    SetAutoBarGroupingEnabled(frame, false, overall)
    return false
  end

  -- The three divider bands and the pocket art already communicate the
  -- emergency/buff/utility grouping. Keep the semantic dividers, but retire
  -- the external text plaques and reclaim their horizontal footprint.
  if labels then
    for index = 1, table.getn(labels) do
      labels[index]:Hide()
    end
  end

  local divider1 = EnsureAutoBarDivider(frame, 1)
  local divider2 = EnsureAutoBarDivider(frame, 2)
  ConfigureDivider(divider1, overall, group1, group2)
  ConfigureDivider(divider2, overall, group2, group3)
  divider1:Show()
  divider2:Show()
  return true
end

local function EnsurePopupConnector(frame, index, orientation)
  frame.aeuiConsumableKitConnectorsV1 =
    frame.aeuiConsumableKitConnectorsV1 or {}
  local holder = frame.aeuiConsumableKitConnectorsV1[index]
  if not holder then
    holder = {
      horizontal = CreateDecorationFrame(frame),
      vertical = CreateDecorationFrame(frame),
    }
    EnsureConnector(
      holder.horizontal,
      "aeuiConsumableKitConnectorV1",
      ActionBars.consumableKitTexturePath,
      consumableKitTexCoords.horizontal,
      "HORIZONTAL",
      6
    )
    EnsureConnector(
      holder.vertical,
      "aeuiConsumableKitConnectorV1",
      ActionBars.consumableKitTexturePath,
      consumableKitTexCoords.vertical,
      "VERTICAL",
      6
    )
    frame.aeuiConsumableKitConnectorsV1[index] = holder
  end
  if orientation == "VERTICAL" then
    holder.horizontal:Hide()
    holder.vertical:Show()
    return holder.vertical
  end
  holder.vertical:Hide()
  holder.horizontal:Show()
  return holder.horizontal
end

local function HideUnusedPopupConnectors(frame, firstUnused)
  local connectors = frame.aeuiConsumableKitConnectorsV1
  if not connectors then
    return
  end
  for index = firstUnused, table.getn(connectors) do
    connectors[index].horizontal:Hide()
    connectors[index].vertical:Hide()
  end
end

local function EnsureAutoBarDrawerSpine(frame)
  local spine = frame.aeuiConsumableKitDrawerSpineV1
  if not spine then
    spine = CreateDecorationFrame(frame)
    EnsureConnector(
      spine,
      "aeuiConsumableKitDrawerSpineSlicesV1",
      ActionBars.consumableKitTexturePath,
      consumableKitTexCoords.vertical,
      "VERTICAL",
      3
    )
    frame.aeuiConsumableKitDrawerSpineV1 = spine
  end
  return spine
end

local function HideAutoBarDrawerSpine(frame)
  local spine = frame and frame.aeuiConsumableKitDrawerSpineV1
  if spine then
    spine:Hide()
  end
end

local function AutoBarDrawerOnLeave()
  -- AutoBar's repeating PopupMouseover event remains responsible for close.
  -- Its stock XML OnLeave only understands the original popup-frame bounds,
  -- which no longer contain an external drawer.
end

local function EnsureAutoBarDrawerHoverBridge(frame)
  local bridge = frame.aeuiConsumableKitDrawerHoverBridgeV1
  if not bridge then
    bridge = CreateFrame("Frame", nil, frame)
    bridge:EnableMouse(true)
    if frame.GetFrameLevel and bridge.SetFrameLevel then
      bridge:SetFrameLevel(frame:GetFrameLevel() + 1)
    end
    frame.aeuiConsumableKitDrawerHoverBridgeV1 = bridge
  end
  return bridge
end

local function ActivateAutoBarDrawerInteraction(
  frame, shell, side, width
)
  local bridge = EnsureAutoBarDrawerHoverBridge(frame)
  bridge:ClearAllPoints()
  bridge:SetWidth(width)
  if side == "LEFT" then
    bridge:SetPoint("TOPRIGHT", shell, "TOPLEFT", 0, 0)
    bridge:SetPoint("BOTTOMRIGHT", shell, "BOTTOMLEFT", 0, 0)
  else
    bridge:SetPoint("TOPLEFT", shell, "TOPRIGHT", 0, 0)
    bridge:SetPoint("BOTTOMLEFT", shell, "BOTTOMRIGHT", 0, 0)
  end
  bridge:Show()

  if not frame.aeuiConsumableKitNativeOnLeaveCapturedV1 and
    frame.GetScript and frame.SetScript
  then
    frame.aeuiConsumableKitNativeOnLeaveV1 = frame:GetScript("OnLeave")
    frame.aeuiConsumableKitNativeOnLeaveCapturedV1 = true
  end
  if frame.aeuiConsumableKitNativeOnLeaveCapturedV1 and frame.SetScript then
    frame:SetScript("OnLeave", AutoBarDrawerOnLeave)
  end
end

local function DeactivateAutoBarDrawerInteraction(frame)
  if not frame then
    return
  end
  local bridge = frame.aeuiConsumableKitDrawerHoverBridgeV1
  if bridge then
    bridge:Hide()
  end
  if frame.aeuiConsumableKitNativeOnLeaveCapturedV1 and frame.SetScript then
    frame:SetScript(
      "OnLeave", frame.aeuiConsumableKitNativeOnLeaveV1
    )
  end
end

local function CapturePopupNativeLayouts(frame, buttons)
  frame.aeuiConsumableKitNativePopupLayoutsV1 = {}
  for index = 1, table.getn(buttons) do
    local button = buttons[index]
    frame.aeuiConsumableKitNativePopupLayoutsV1[button] =
      CaptureButtonLayout(button)
  end
end

local function RestorePopupNativeLayouts(frame, buttons)
  local layouts = frame.aeuiConsumableKitNativePopupLayoutsV1
  if not layouts then
    return false
  end
  for index = 1, table.getn(buttons) do
    local button = buttons[index]
    RestoreButtonLayout(button, layouts[button])
  end
  frame.aeuiConsumableKitDrawerActiveV1 = false
  return true
end

local function ResolveAutoBarDrawerSide(frame)
  local mode = GetPopupMode()
  if mode == "LEFT" or mode == "RIGHT" then
    return mode
  end
  local database = GetFieldKitDatabase()
  if FieldKitBound() and
    ActionBars.autoBarDockApplied
  then
    return "LEFT"
  end

  local rack = GetGlobal("AutoBarFrame")
  local shell = rack and rack.aeuiConsumableKitShellV1
  if not shell or not shell.GetLeft or not shell.GetRight or
    type(GetScreenWidth) ~= "function"
  then
    return "RIGHT"
  end
  local left = shell:GetLeft()
  local right = shell:GetRight()
  local screenWidth = GetScreenWidth()
  if not left or not right or not screenWidth then
    return "RIGHT"
  end
  if left >= screenWidth - right then
    return "LEFT"
  end
  return "RIGHT"
end

local function ConfigureAutoBarDrawer(frame, buttons, side)
  local rack = GetGlobal("AutoBarFrame")
  local shell = rack and rack.aeuiConsumableKitShellV1
  local count = table.getn(buttons)
  if not shell or count == 0 then
    return false, 0, 0
  end

  local rows = count
  if count > ActionBars.popupDrawerMaxRows then
    rows = math.ceil(count / 2)
  end
  rows = math.min(rows, ActionBars.popupDrawerMaxRows)
  local columns = math.ceil(count / rows)
  local first = buttons[1]
  local width = first:GetWidth()
  local height = first:GetHeight()
  local display = AutoBar and AutoBar.display or {}
  local gap = tonumber(display.gapping) or 3
  local hitInset = -math.ceil(gap / 2)
  local labelOffset = 0

  first:ClearAllPoints()
  if side == "LEFT" then
    first:SetPoint(
      "TOPRIGHT", shell, "TOPLEFT",
      -(labelOffset + ActionBars.popupDrawerGap +
        ActionBars.fieldKitPocketPadding),
      -ActionBars.fieldKitPocketPadding
    )
  else
    first:SetPoint(
      "TOPLEFT", shell, "TOPRIGHT",
      ActionBars.popupDrawerGap + ActionBars.fieldKitPocketPadding,
      -ActionBars.fieldKitPocketPadding
    )
  end
  if first.SetHitRectInsets then
    first:SetHitRectInsets(hitInset, hitInset, hitInset, hitInset)
  end

  for index = 2, count do
    local button = buttons[index]
    local zero = index - 1
    local column = math.floor(zero / rows)
    local row = math.mod(zero, rows)
    button:ClearAllPoints()
    if side == "LEFT" then
      button:SetPoint(
        "TOPRIGHT", first, "TOPRIGHT",
        -column * (width + gap), -row * (height + gap)
      )
    else
      button:SetPoint(
        "TOPLEFT", first, "TOPLEFT",
        column * (width + gap), -row * (height + gap)
      )
    end
    if button.SetHitRectInsets then
      button:SetHitRectInsets(hitInset, hitInset, hitInset, hitInset)
    end
  end

  local spine = EnsureAutoBarDrawerSpine(frame)
  local lastNear = buttons[math.min(rows, count)]
  spine:ClearAllPoints()
  spine:SetPoint(
    "TOP", first, "TOP", 0, ActionBars.fieldKitPocketPadding
  )
  spine:SetPoint(
    "BOTTOM", lastNear, "BOTTOM", 0,
    -ActionBars.fieldKitPocketPadding
  )
  spine:SetWidth(6)
  if side == "LEFT" then
    spine:SetPoint(
      "RIGHT", first, "RIGHT",
      ActionBars.fieldKitPocketPadding + ActionBars.popupDrawerGap, 0
    )
  else
    spine:SetPoint(
      "LEFT", first, "LEFT",
      -(ActionBars.fieldKitPocketPadding + ActionBars.popupDrawerGap), 0
    )
  end
  spine:Show()
  local hoverWidth = ActionBars.popupDrawerGap +
    ActionBars.fieldKitPocketPadding
  if side == "LEFT" then
    hoverWidth = hoverWidth + labelOffset
  end
  ActivateAutoBarDrawerInteraction(
    frame,
    shell,
    side,
    hoverWidth
  )
  frame.aeuiConsumableKitDrawerActiveV1 = true
  return true, rows, columns
end

local function ConfigureNativePopupConnectors(frame, buttons)
  if table.getn(buttons) < 2 then
    HideUnusedPopupConnectors(frame, 1)
    return 0
  end
  local display = AutoBar and AutoBar.display or {}
  local horizontal = display.popupToLeft or display.popupToRight
  SortPopupButtons(buttons, horizontal)
  for index = 1, table.getn(buttons) - 1 do
    local connector
    if horizontal then
      connector = EnsurePopupConnector(frame, index, "HORIZONTAL")
      connector:ClearAllPoints()
      connector:SetPoint("LEFT", buttons[index], "CENTER", 0, 0)
      connector:SetPoint("RIGHT", buttons[index + 1], "CENTER", 0, 0)
      connector:SetHeight(8)
    else
      connector = EnsurePopupConnector(frame, index, "VERTICAL")
      connector:ClearAllPoints()
      connector:SetPoint("BOTTOM", buttons[index], "CENTER", 0, 0)
      connector:SetPoint("TOP", buttons[index + 1], "CENTER", 0, 0)
      connector:SetWidth(8)
    end
  end
  HideUnusedPopupConnectors(frame, table.getn(buttons))
  return table.getn(buttons) - 1
end

function ActionBars:ApplyAutoBarPopup(enabled, baseButton)
  local frame = GetGlobal("AutoBarPopupFrame")
  if not frame then
    self:CancelAutoBarPopupIntent()
    self.autoBarPopupButtons = 0
    self.autoBarPopupConnectors = 0
    self.autoBarPopupLayout = "missing"
    self.autoBarPopupSide = "none"
    self.autoBarPopupHover = "missing"
    return false
  end

  local buttons = {}
  for index = 1, 12 do
    local item = GetGlobal("AutoBarPopupFrame_Button" .. index)
    if item then
      ApplyPocket(
        item,
        "aeuiConsumableKitPocketV1",
        self.consumableKitTexturePath,
        consumableKitTexCoords.B,
        consumableKitSpriteSizes.B,
        enabled,
        self.fieldKitPocketPadding
      )
      if IsVisibleButton(item) then
        table.insert(buttons, item)
      end
    end
  end

  if baseButton then
    frame.aeuiConsumableKitPopupBaseButtonV1 = baseButton
    CapturePopupNativeLayouts(frame, buttons)
  end
  local activeBase = baseButton or
    frame.aeuiConsumableKitPopupBaseButtonV1
  local mainBounds = GetButtonExtremes(1, 24, "AutoBarFrameButton")
  -- Once the Field Kit owns the visible four-column rack, its popup geometry
  -- is independent of the category profile. Custom class slots and manual
  -- item entries must not make AutoBar fall back to an icon-local top popup.
  local integratedDrawer = enabled and activeBase and FieldKitBound() and
    mainBounds.count > 0 and mainBounds.count <= 24
  local drawerEnabled = integratedDrawer or
    (enabled and activeBase and GetPopupMode() ~= "NATIVE" and
      AutoBarRecommendedLayoutMatches(mainBounds.count))

  if drawerEnabled then
    HideUnusedPopupConnectors(frame, 1)
    local side = integratedDrawer and "LEFT" or
      ResolveAutoBarDrawerSide(frame)
    local configured, rows, columns =
      ConfigureAutoBarDrawer(frame, buttons, side)
    if configured then
      self.autoBarPopupButtons = table.getn(buttons)
      self.autoBarPopupConnectors = 1
      self.autoBarPopupLayout =
        "drawer-" .. tostring(columns) .. "x" .. tostring(rows)
      self.autoBarPopupSide = string.lower(side)
      if self.autoBarPopupIntentWrapped and AutoBar and
        type(AutoBar.ScheduleEvent) == "function" and
        type(AutoBar.CancelScheduledEvent) == "function"
      then
        self.autoBarPopupHover = "intent-bridge"
      else
        self.autoBarPopupHover = "bridge"
      end
      return true
    end
  end

  self:CancelAutoBarPopupIntent()
  if frame.aeuiConsumableKitDrawerActiveV1 then
    RestorePopupNativeLayouts(frame, buttons)
  end
  HideAutoBarDrawerSpine(frame)
  DeactivateAutoBarDrawerInteraction(frame)
  self.autoBarPopupHover = "provider"

  if not enabled or table.getn(buttons) < 2 then
    HideUnusedPopupConnectors(frame, 1)
    self.autoBarPopupButtons = table.getn(buttons)
    self.autoBarPopupConnectors = 0
    self.autoBarPopupLayout = enabled and "native" or "disabled"
    self.autoBarPopupSide = "provider"
    return true
  end

  self.autoBarPopupButtons = table.getn(buttons)
  self.autoBarPopupConnectors =
    ConfigureNativePopupConnectors(frame, buttons)
  self.autoBarPopupLayout = "native"
  self.autoBarPopupSide = "provider"
  return true
end

function ActionBars:ApplyAutoBarFieldKit(enabled)
  local frame = GetGlobal("AutoBarFrame")
  if not AutoBar or not frame then
    self.autoBarFieldKitStatus = "missing"
    self.autoBarDragHandleStatus = "missing"
    self.autoBarMainButtons = 0
    self.autoBarGrouped = false
    self.consumableDockStatus = "unavailable"
    self:ApplyAutoBarPopup(false)
    return false
  end

  for index = 1, 24 do
    ApplyPocket(
      GetGlobal("AutoBarFrameButton" .. index),
      "aeuiConsumableKitPocketV1",
      self.consumableKitTexturePath,
      consumableKitTexCoords.A,
      consumableKitSpriteSizes.A,
      enabled,
      self.fieldKitPocketPadding
    )
  end

  -- Establish the real four-column button grid before measuring its shell.
  -- This keeps the first /reload frame on the same geometry as later
  -- ButtonsUpdate refreshes instead of briefly measuring provider points.
  self:ApplyConsumableDockPosition(enabled)
  local bounds = GetButtonExtremes(1, 24, "AutoBarFrameButton")
  local shell = EnsureAutoBarShell(frame)
  local shellAvailable = ConfigureShellBounds(shell, bounds, 6)
  if enabled and shellAvailable then
    shell:Show()
  else
    shell:Hide()
  end

  local grouped = enabled and shellAvailable and
    AutoBarGroupingMatches(bounds.count)
  self.autoBarGrouped =
    SetAutoBarGroupingEnabled(frame, grouped, bounds)
  self.autoBarMainButtons = bounds.count
  self.autoBarFieldKitStatus = enabled and "available" or "disabled"
  self:ApplyAutoBarDragHandlePolicy(enabled)
  self:ApplyAutoBarPopup(enabled)
  return true
end

local function EnsureTrinketJoiner(frame)
  local joiner = frame.aeuiTrinketKitJoinerV1
  if not joiner then
    joiner = {
      horizontal = CreateDecorationFrame(frame),
      vertical = CreateDecorationFrame(frame),
    }
    EnsureConnector(
      joiner.horizontal,
      "aeuiTrinketKitConnectorV1",
      ActionBars.trinketKitTexturePath,
      trinketKitTexCoords.horizontal,
      "HORIZONTAL",
      4
    )
    EnsureConnector(
      joiner.vertical,
      "aeuiTrinketKitConnectorV1",
      ActionBars.trinketKitTexturePath,
      trinketKitTexCoords.vertical,
      "VERTICAL",
      4
    )
    frame.aeuiTrinketKitJoinerV1 = joiner
  end
  return joiner
end

local function ConfigureTrinketJoiner(frame, first, second, enabled)
  local joiner = EnsureTrinketJoiner(frame)
  if not enabled or not first or not second then
    joiner.horizontal:Hide()
    joiner.vertical:Hide()
    return "hidden"
  end

  if frame:GetWidth() >= frame:GetHeight() then
    joiner.vertical:Hide()
    joiner.horizontal:ClearAllPoints()
    joiner.horizontal:SetPoint("LEFT", first, "CENTER", 0, 0)
    joiner.horizontal:SetPoint("RIGHT", second, "CENTER", 0, 0)
    joiner.horizontal:SetHeight(10)
    joiner.horizontal:Show()
    return "horizontal"
  end

  joiner.horizontal:Hide()
  joiner.vertical:ClearAllPoints()
  joiner.vertical:SetPoint("TOP", first, "CENTER", 0, 0)
  joiner.vertical:SetPoint("BOTTOM", second, "CENTER", 0, 0)
  joiner.vertical:SetWidth(10)
  joiner.vertical:Show()
  return "vertical"
end

local function EnsureTrinketMenuShell(frame)
  local shell = frame.aeuiTrinketKitShellV1
  if not shell then
    shell = CreateDecorationFrame(frame)
    shell:SetAllPoints(frame)
    EnsureNineSlice(
      shell,
      "aeuiTrinketKitNineSliceV1",
      ActionBars.trinketKitTexturePath,
      trinketKitTexCoords.C,
      ActionBars.fieldKitCap
    )
    frame.aeuiTrinketKitShellV1 = shell
  end
  return shell
end

function ActionBars:ApplyTrinketFieldKit(enabled)
  local main = GetGlobal("TrinketMenu_MainFrame")
  local menu = GetGlobal("TrinketMenu_MenuFrame")
  if not TrinketMenu or not main or not menu then
    self.trinketFieldKitStatus = "missing"
    self.trinketMainButtons = 0
    self.trinketMenuButtons = 0
    self.trinketJoinerOrientation = "missing"
    self.trinketDockStatus = "unavailable"
    return false
  end

  local first = GetGlobal("TrinketMenu_Trinket0")
  local second = GetGlobal("TrinketMenu_Trinket1")
  local mainButtons = { first, second }
  local appliedMain = 0
  for index = 1, 2 do
    local item = mainButtons[index]
    if ApplyPocket(
      item,
      "aeuiTrinketKitPocketV1",
      self.trinketKitTexturePath,
      trinketKitTexCoords.A,
      trinketKitSpriteSizes.A,
      enabled,
      self.fieldKitPocketPadding
    ) then
      SetTrinketButtonNativeNormal(item, not enabled)
      appliedMain = appliedMain + 1
    end
  end

  local appliedMenu = 0
  for index = 1, 30 do
    local item = GetGlobal("TrinketMenu_Menu" .. index)
    if ApplyPocket(
      item,
      "aeuiTrinketKitCandidatePocketV1",
      self.trinketKitTexturePath,
      trinketKitTexCoords.B,
      trinketKitSpriteSizes.B,
      enabled,
      self.fieldKitPocketPadding
    ) then
      SetTrinketButtonNativeNormal(item, not enabled)
      appliedMenu = appliedMenu + 1
    end
  end

  local shell = EnsureTrinketMenuShell(menu)
  if enabled then
    shell:Show()
  else
    shell:Hide()
  end
  SetTrinketBackdrop(main, not enabled)
  SetTrinketBackdrop(menu, not enabled)

  self.trinketJoinerOrientation =
    ConfigureTrinketJoiner(main, first, second, enabled)
  self.trinketMainButtons = appliedMain
  self.trinketMenuButtons = appliedMenu
  self.trinketFieldKitStatus = enabled and "available" or "disabled"
  self:ApplyTrinketDockPosition(enabled)
  return true
end

function ActionBars:CancelAutoBarPopupIntent()
  local provider = self.autoBarPopupIntentProvider
  if provider and type(provider.CancelScheduledEvent) == "function" then
    pcall(
      provider.CancelScheduledEvent,
      provider,
      self.popupIntentEvent
    )
  end
  self.autoBarPopupIntentProvider = nil
  self.autoBarPopupIntentButton = nil
end

function ActionBars:ShouldDeferAutoBarPopup(provider, button)
  if provider ~= AutoBar or not FieldKitEnabled() or not button then
    return false
  end
  if type(provider.ScheduleEvent) ~= "function" or
    type(provider.CancelScheduledEvent) ~= "function" or
    type(GetMouseFocus) ~= "function"
  then
    return false
  end

  local rack = GetGlobal("AutoBarFrame")
  local frame = GetGlobal("AutoBarPopupFrame")
  if not rack or not frame or
    not frame.aeuiConsumableKitDrawerActiveV1 or
    not frame.IsShown or not frame:IsShown() or
    frame.aeuiConsumableKitPopupBaseButtonV1 == button
  then
    return false
  end
  if not button.GetParent or button:GetParent() ~= rack or
    GetMouseFocus() ~= button
  then
    return false
  end
  return true
end

function ActionBars:CommitAutoBarPopupIntent()
  local provider = self.autoBarPopupIntentProvider
  local button = self.autoBarPopupIntentButton
  self.autoBarPopupIntentProvider = nil
  self.autoBarPopupIntentButton = nil

  local original = self.autoBarSetPopupButtonOriginal
  if type(original) ~= "function" then
    return
  end
  local ok, shouldCommit = pcall(
    self.ShouldDeferAutoBarPopup,
    self,
    provider,
    button
  )
  if ok and shouldCommit then
    return original(provider, button)
  end
end

function ActionBars:HandleAutoBarSetPopupButton(provider, button)
  local original = self.autoBarSetPopupButtonOriginal
  if type(original) ~= "function" then
    return
  end

  local ok, shouldDefer = pcall(
    self.ShouldDeferAutoBarPopup,
    self,
    provider,
    button
  )
  if not ok or not shouldDefer then
    self:CancelAutoBarPopupIntent()
    return original(provider, button)
  end

  if self.autoBarPopupIntentProvider == provider and
    self.autoBarPopupIntentButton == button
  then
    return
  end

  self:CancelAutoBarPopupIntent()
  self.autoBarPopupIntentProvider = provider
  self.autoBarPopupIntentButton = button
  local scheduled = pcall(
    provider.ScheduleEvent,
    provider,
    self.popupIntentEvent,
    self.CommitAutoBarPopupIntent,
    self.popupIntentDelay,
    self
  )
  if not scheduled then
    self.autoBarPopupIntentProvider = nil
    self.autoBarPopupIntentButton = nil
    return original(provider, button)
  end
end

function ActionBars:InstallAutoBarPopupIntentGuard()
  if self.autoBarPopupIntentWrapped then
    return true
  end
  if not AutoBar or type(AutoBar.SetPopupButton) ~= "function" then
    return false
  end

  self.autoBarSetPopupButtonOriginal = AutoBar.SetPopupButton
  self.autoBarSetPopupButtonWrapper = function(provider, button)
    return ActionBars:HandleAutoBarSetPopupButton(provider, button)
  end
  AutoBar.SetPopupButton = self.autoBarSetPopupButtonWrapper
  self.autoBarPopupIntentWrapped = true
  return true
end

function ActionBars:CommitAutoBarFieldKitRefresh()
  self.autoBarRefreshProvider = nil
  self.autoBarRefreshStatus = "settled"
  self:RepairAutoBarCategoryDescriptions()
  SafeFieldKitApply("ApplyAutoBarFieldKit")
end

function ActionBars:SettleAutoBarFieldKitRefresh()
  self:RestoreAutoBarBoundAnchor()
  self:ApplyAutoBarDragHandlePolicy(FieldKitEnabled())
  return self:QueueAutoBarFieldKitRefresh()
end

function ActionBars:QueueAutoBarFieldKitRefresh()
  local provider = AutoBar
  self:RepairAutoBarCategoryDescriptions()
  if provider and type(provider.ScheduleEvent) == "function" and
    type(provider.CancelScheduledEvent) == "function"
  then
    pcall(
      provider.CancelScheduledEvent,
      provider,
      self.autoBarRefreshEvent
    )
    local ok, event = pcall(
      provider.ScheduleEvent,
      provider,
      self.autoBarRefreshEvent,
      self.CommitAutoBarFieldKitRefresh,
      self.autoBarRefreshDelay,
      self
    )
    if ok and event then
      self.autoBarRefreshProvider = provider
      self.autoBarRefreshStatus = "queued"
      return true
    end
  end

  self.autoBarRefreshProvider = nil
  self.autoBarRefreshStatus = "immediate"
  SafeFieldKitApply("ApplyAutoBarFieldKit")
  return false
end

function ActionBars:InstallFieldKitHooks()
  self:InstallFieldKitUnlockHooks()
  self:InstallCombatDeckGroupHooks()

  if AutoBar then
    self:InstallAutoBarPopupIntentGuard()
  end

  if type(hooksecurefunc) ~= "function" then
    return
  end

  if not self.actionBarConfigHooked and pfUI and pfUI.bars and
    type(pfUI.bars.UpdateConfig) == "function"
  then
    self.actionBarConfigHooked = true
    hooksecurefunc(pfUI.bars, "UpdateConfig", function()
      local grouped = pcall(
        ActionBars.MaintainSideBarGroup,
        ActionBars
      )
      if not grouped then
        ActionBars.sideBarGroupStatus = "error"
      end
      local ok = pcall(
        ActionBars.ApplyActionBarStackPosition,
        ActionBars,
        FieldKitEnabled()
      )
      if not ok then
        ActionBars.actionBarStackStatus = "error"
      end
      if CombatFocusLayoutActive() and
        not ActionBars.focusStanceUpdating
      then
        local stanceOk = pcall(
          ActionBars.ApplyFocusStanceContract,
          ActionBars,
          false,
          false
        )
        if not stanceOk then
          ActionBars.focusStanceStatus = "error"
        end
      end
      ActionBars:InstallCombatDeckGroupHooks()
      ActionBars:ApplyCombatDeckGroup()
    end)
  end

  if AutoBar then
    if not self.autoBarSetupHooked and
      type(GetGlobal("AutoBar_SetupVisual")) == "function"
    then
      self.autoBarSetupHooked = true
      hooksecurefunc("AutoBar_SetupVisual", function()
        ActionBars:SettleAutoBarFieldKitRefresh()
      end)
    end
    if not self.autoBarConfigShowHooked and
      type(AutoBarConfig) == "table" and
      type(AutoBarConfig.OnShow) == "function"
    then
      self.autoBarConfigShowHooked = true
      hooksecurefunc(AutoBarConfig, "OnShow", function()
        ActionBars:MigrateAutoBarClassScope()
        ActionBars:ApplyAutoBarConfigCuration()
        ActionBars:SettleAutoBarFieldKitRefresh()
      end)
    end
    if not self.autoBarConfigTabHooked and
      type(AutoBarConfig) == "table" and
      type(AutoBarConfig.TabButtonOnClick) == "function"
    then
      self.autoBarConfigTabHooked = true
      hooksecurefunc(AutoBarConfig, "TabButtonOnClick", function()
        if not ActionBars.autoBarConfigSelecting then
          ActionBars:ApplyAutoBarConfigCuration()
        end
      end)
    end
    if not self.autoBarButtonsHooked and
      type(AutoBar.ButtonsUpdate) == "function"
    then
      self.autoBarButtonsHooked = true
      hooksecurefunc(AutoBar, "ButtonsUpdate", function()
        ActionBars:ApplyAutoBarButtonDock(FieldKitEnabled())
        ActionBars:QueueAutoBarFieldKitRefresh()
      end)
    end
    if not self.autoBarPopupHooked and
      type(AutoBar.UpdatePopupButtons) == "function"
    then
      self.autoBarPopupHooked = true
      hooksecurefunc(AutoBar, "UpdatePopupButtons", function(owner, baseButton)
        SafeFieldKitApply("ApplyAutoBarPopup", baseButton)
      end)
    end
    if not self.autoBarDragStopHooked and
      type(AutoBar.DragStop) == "function"
    then
      self.autoBarDragStopHooked = true
      hooksecurefunc(AutoBar, "DragStop", function()
        ActionBars:HandleAutoBarDragStop()
      end)
    end
  end

  if TrinketMenu then
    if not self.trinketOrientHooked and
      type(TrinketMenu.OrientWindows) == "function"
    then
      self.trinketOrientHooked = true
      hooksecurefunc(TrinketMenu, "OrientWindows", function()
        SafeFieldKitApply("ApplyTrinketFieldKit")
      end)
    end
    if not self.trinketBuildHooked and
      type(TrinketMenu.BuildMenu) == "function"
    then
      self.trinketBuildHooked = true
      hooksecurefunc(TrinketMenu, "BuildMenu", function()
        SafeFieldKitApply("ApplyTrinketFieldKit")
      end)
    end
    if not self.trinketDragStopHooked and
      type(TrinketMenu.MainFrame_OnMouseUp) == "function"
    then
      self.trinketDragStopHooked = true
      hooksecurefunc(TrinketMenu, "MainFrame_OnMouseUp", function()
        if arg1 == "LeftButton" then
          ActionBars:HandleTrinketDragStop()
        end
      end)
    end
  end

  if not self.archiTotemDragStopHooked and
    type(GetGlobal("ArchiTotem_DragHandle_OnDragStop")) == "function"
  then
    self.archiTotemDragStopHooked = true
    hooksecurefunc("ArchiTotem_DragHandle_OnDragStop", function()
      local ok = pcall(
        ActionBars.HandleArchiTotemDragStop, ActionBars
      )
      if not ok then
        ActionBars.archiTotemDockStatus = "error"
      end
    end)
  end
end

function ActionBars:Initialize()
  self.providerStatus = "pending"
  self.appliedBars = 0
  self.appliedButtons = 0
  self.appliedRails = 0
  self.appliedMergedRail = false
  self.autoBarFieldKitStatus = "pending"
  self.autoBarMainButtons = 0
  self.autoBarPopupButtons = 0
  self.autoBarPopupConnectors = 0
  self.autoBarPopupLayout = "pending"
  self.autoBarPopupSide = "pending"
  self.autoBarPopupHover = "pending"
  self.autoBarPopupIntentProvider = nil
  self.autoBarPopupIntentButton = nil
  self.autoBarRefreshProvider = nil
  self.autoBarRefreshStatus = "ready"
  self.autoBarDockApplied = false
  self.autoBarBoundAnchors = nil
  self.autoBarBoundOffsetX = nil
  self.autoBarBoundOffsetY = nil
  self.autoBarAnchorBasis = "pending"
  self.autoBarHandlePointLockStatus = "pending"
  self.autoBarProviderDockProfile = nil
  self.autoBarProviderDockStatus = "pending"
  self.autoBarDragHandleStatus = "pending"
  self.autoBarCategoryDescriptionStatus = "pending"
  self.autoBarCategoryDescriptionsRepaired = 0
  self.autoBarGrouped = false
  self.autoBarPresetStatus = "ready"
  self.autoBarClassScopeStatus = "pending"
  self.autoBarClassScopeUpdating = false
  self.autoBarConfigCurationStatus = "pending"
  self.autoBarConfigSelecting = false
  self.autoBarConfigOriginalLayout = nil
  self.actionBarStackStatus = "pending"
  self.sideBarGroupStatus = SideBarGroupBound() and "bound" or "free"
  self.sideBarGroupMigration = "pending"
  self.sideBarGroupUpdating = false
  self.consumableDockStatus = "pending"
  self.trinketFieldKitStatus = "pending"
  self.trinketMainButtons = 0
  self.trinketMenuButtons = 0
  self.trinketJoinerOrientation = "pending"
  self.trinketDockStatus = "pending"
  self.archiTotemDockStatus = "pending"
  self.archiTotemDirectionStatus =
    GetArchiTotemDirection() or "pending"
  self.archiTotemDockApplied = false
  self.archiTotemFreeAnchors = nil
  self.stanceDockStatus = "pending"
  self.stanceDockApplied = false
  self.stanceFreeAnchors = nil
  self.focusLayoutStatus = CombatFocusLayoutSaved() and "saved" or "ready"
  self.focusLayoutConfigured = 0
  self.focusLayoutLive = 0
  self.focusUnitDefaultStatus = FocusUnitDefaultLayoutActive() and
    "profile-saved" or "ready"
  self.focusUnitDefaultProfile = GetCharacterProfileKey()
  self.focusLayoutDoite = "pending"
  self.doitePositionSynchronized = false
  self.focusLayoutArchiTotem = "pending"
  self.focusLayoutMousePolicy = "visible-controls-only"
  self.focusStanceStatus = "pending"
  self.focusStanceUpdating = false
  self.combatDeckGroupStatus = "pending"
  self.comfortUIScaleStatus = ComfortUIScaleConfigured() and
    "saved" or "custom"
end

function ActionBars:Apply()
  local enabled = addon.db and addon.db.actionbars and
    addon.db.actionbars.enabled
  local providerAvailable = pfUI and pfUI.bars
  local appliedBars = 0
  local appliedButtons = 0
  local appliedRails = 0
  local appliedMergedRail = false
  -- Apply the current unit-frame contract once per character before touching
  -- any optional action-bar provider. Later integrations cannot block it, and
  -- the per-character version prevents refreshes from overwriting user edits.
  local focusUnitDefaultsApplied = false
  if enabled then
    focusUnitDefaultsApplied = self:ApplyFocusUnitDefaults()
  end
  local copiedPrimaryLayoutMigrated = false
  if enabled and not focusUnitDefaultsApplied and
    not FocusUnitDefaultOptedOut()
  then
    copiedPrimaryLayoutMigrated =
      self:MigrateCopiedPrimaryUnitLayout()
  end

  if not providerAvailable then
    self.providerStatus = "missing"
    self.appliedBars = 0
    self.appliedButtons = 0
    self.appliedRails = 0
    self.appliedMergedRail = false
  else
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

  self:RepairAutoBarCategoryDescriptions()
  self:InstallFieldKitHooks()
  self:InstallFocusUnitFontHooks()
  self:MigrateSideBarGroupDefault()
  self:MaintainSideBarGroup()
  self:ApplyActionBarStackPosition(enabled)
  self:MigrateAutoBarClassScope()
  self:ApplyAutoBarConfigCuration()
  self:MigrateAutoBarDefaultMode()
  self:ApplyAutoBarFieldKit(enabled)
  self:ApplyTrinketFieldKit(enabled)
  self:ApplyArchiTotemDockPosition(enabled)

  -- Upgrade only exact preceding AEUI game-coordinate contracts. Restored or
  -- custom non-DDPS fields are not matched by this signature and remain
  -- untouched; DDPS position is synchronized separately once per UI session.
  if copiedPrimaryLayoutMigrated then
    -- Copied character profiles can carry the exact Combat Focus unit-frame
    -- geometry while the account-level AEUI layout flag remains unset.
    -- Compact the two exact primary-frame matches and keep TargetTarget
    -- aligned; leave every readout and unrelated copied position untouched.
  elseif ShouldMigrateCombatFocusLayout() and ComfortUIScaleConfigured() then
    self:ApplyCombatFocusLayoutPreset()
  elseif CombatFocusStanceUpgradeEligible() and
    ComfortUIScaleConfigured()
  then
    self:UpgradeCombatFocusStanceContract()
  elseif CombatFocusLayoutActive() then
    self:ApplyFocusStanceContract(false, false)
  end
  if FocusUnitLayoutActive() then
    self:ApplyFocusRelativeAnchors()
    self:ApplyFocusUnitFonts()
  end
  self:SynchronizeDoitePosition()

  self:InstallCombatDeckGroupHooks()
  self:ApplyCombatDeckGroup()

  -- The offhand timer has no independent pfUI movable entry. Restore its
  -- one-shot equal-size compensation when the focus contract is active; no
  -- position or size is maintained by an OnUpdate loop.
  if CombatFocusLayoutActive() then
    local offhand = pfUI and pfUI.swingtimer and pfUI.swingtimer.offhand
    local main = pfUI and pfUI.swingtimer and pfUI.swingtimer.mainhand
    if offhand then
      if offhand.SetScale then
        offhand:SetScale(self.focusReadoutScale)
      end
      if offhand.SetWidth then
        offhand:SetWidth(self.focusReadoutWidth)
      end
      if offhand.SetHeight then
        offhand:SetHeight(self.focusReadoutHeight)
      end
      if main and offhand.ClearAllPoints and offhand.SetPoint then
        offhand:ClearAllPoints()
        offhand:SetPoint("TOP", main, "BOTTOM", 0, -2)
      end
    end
  end
end

function ActionBars:GetRuntimeStatus()
  local global = pfUI_config and pfUI_config.global
  local uiScaleTier = global and global.pixelperfect or "unknown"
  return
    "contract=" .. tostring(self.runtimeContract) ..
    ",rail-contract=" .. tostring(self.railRuntimeContract) ..
    ",fieldkit-contract=" .. tostring(self.fieldKitRuntimeContract) ..
    ",sidebar-group-contract=" ..
      tostring(self.sideBarGroupRuntimeContract) ..
    ",sidebar-group=" ..
      tostring(self.sideBarGroupStatus or "free") ..
    ",sidebar-group-binding=" ..
      tostring(SideBarGroupBound() and "bound" or "free") ..
    ",sidebar-group-profile=" ..
      tostring(GetSideBarGroupProfileKey() or "unavailable") ..
    ",focus-layout-contract=" ..
      tostring(self.focusLayoutRuntimeContract) ..
    ",focus-layout=" .. tostring(self.focusLayoutStatus or "ready") ..
    ",focus-unit-default-version=" ..
      tostring(self.focusUnitDefaultVersion) ..
    ",focus-unit-default=" ..
      tostring(self.focusUnitDefaultStatus or "ready") ..
    ",focus-unit-default-profile=" ..
      tostring(self.focusUnitDefaultProfile or
        GetCharacterProfileKey() or "unavailable") ..
    ",focus-layout-configured=" ..
      tostring(self.focusLayoutConfigured or 0) ..
    ",focus-layout-live=" .. tostring(self.focusLayoutLive or 0) ..
    ",focus-layout-doite=" ..
      tostring(self.focusLayoutDoite or "pending") ..
    ",focus-layout-architotem=" ..
      tostring(self.focusLayoutArchiTotem or "pending") ..
    ",focus-layout-mouse=" ..
      tostring(self.focusLayoutMousePolicy or "visible-controls-only") ..
    ",focus-layout-anchor=ui-parent+target-dependent" ..
    ",focus-layout-coordinate-space=" ..
      tostring(self.focusCoordinateSpace) ..
    ",focus-layout-unit-scale=" ..
      tostring(self.focusUnitScale) ..
    ",focus-layout-targettarget-scale=" ..
      tostring(self.focusTargetTargetScale) ..
    ",focus-layout-readout-scale=" ..
      tostring(self.focusReadoutScale) ..
    ",focus-layout-stance-scale=" ..
      tostring(self.focusStanceScale) ..
    ",focus-layout-stance-icon-size=" ..
      tostring(self.focusStanceIconSize) ..
    ",focus-layout-stance-status=" ..
      tostring(self.focusStanceStatus or "pending") ..
    ",focus-layout-readout-size=" ..
      tostring(self.focusReadoutWidth) .. "x" ..
      tostring(self.focusReadoutHeight) ..
    ",focus-layout-unit-size=" ..
      tostring(self.focusUnitWidth) .. "x" ..
      tostring(self.focusUnitHeight) ..
    ",focus-layout-unit-y=" .. tostring(self.focusUnitY) ..
    ",focus-layout-primary-gap=" .. tostring(self.focusPrimaryGap) ..
    ",focus-layout-aura-size=" .. tostring(self.focusAuraSize) ..
    ",focus-layout-aura-per-row=" ..
      tostring(self.focusAuraPerRow) ..
    ",focus-layout-targettarget-aura-per-row=" ..
      tostring(self.focusTargetTargetAuraPerRow) ..
    ",focus-layout-aura-growth=player-left+target-right" ..
    ",focus-layout-unit-font-size=" ..
      tostring(self.focusUnitFontSize) ..
    ",focus-layout-unit-font=" ..
      tostring(self.focusUnitFontRole) ..
    ",focus-layout-unit-font-live=" ..
      tostring(self.focusUnitFontLive or 0) ..
    ",focus-ui-scale=" ..
      tostring(self.comfortUIScaleStatus or "custom") ..
    ",focus-ui-scale-tier=" .. tostring(uiScaleTier) ..
    ",focus-ui-scale-target=" .. tostring(self.comfortUIScaleTier) ..
    ",fieldkit-binding=" ..
      tostring(FieldKitBound() and "bound" or "free") ..
    ",actionbar-stack=" ..
      tostring(self.actionBarStackStatus or "pending") ..
    ",combat-deck-group=" ..
      tostring(self.combatDeckGroupStatus or "pending") ..
    ",provider=" .. tostring(self.providerStatus or "pending") ..
    ",scope=bars-1-10" ..
    ",rail-scope=bars-1-12+merged-1-6" ..
    ",bars=" .. tostring(self.appliedBars or 0) ..
    ",buttons=" .. tostring(self.appliedButtons or 0) ..
    ",rails=" .. tostring(self.appliedRails or 0) ..
    ",merged=" ..
      tostring(self.appliedMergedRail and "available" or "missing") ..
    ",autobar=" .. tostring(self.autoBarFieldKitStatus or "pending") ..
    ",autobar-main=" .. tostring(self.autoBarMainButtons or 0) ..
    ",autobar-popup=" .. tostring(self.autoBarPopupButtons or 0) ..
    ",autobar-connectors=" ..
      tostring(self.autoBarPopupConnectors or 0) ..
    ",autobar-popup-layout=" ..
      tostring(self.autoBarPopupLayout or "pending") ..
    ",autobar-popup-side=" ..
      tostring(self.autoBarPopupSide or "pending") ..
    ",autobar-popup-hover=" ..
      tostring(self.autoBarPopupHover or "pending") ..
    ",autobar-groups=" ..
      tostring(self.autoBarGrouped and "semantic-no-labels" or "adaptive") ..
    ",autobar-preset=" ..
      tostring(self.autoBarPresetStatus or "ready") ..
    ",autobar-slot-scope=" ..
      tostring(self.autoBarClassScopeStatus or "pending") ..
    ",autobar-config-ui=" ..
      tostring(self.autoBarConfigCurationStatus or "pending") ..
    ",autobar-config-descriptions=" ..
      tostring(self.autoBarCategoryDescriptionStatus or "pending") ..
    ",autobar-config-description-fixes=" ..
      tostring(self.autoBarCategoryDescriptionsRepaired or 0) ..
    ",autobar-refresh=" ..
      tostring(self.autoBarRefreshStatus or "ready") ..
    ",autobar-anchor-basis=" ..
      tostring(self.autoBarAnchorBasis or "pending") ..
    ",autobar-point-lock=" ..
      tostring(self.autoBarHandlePointLockStatus or "pending") ..
    ",autobar-provider-dock=" ..
      tostring(self.autoBarProviderDockStatus or "pending") ..
    ",autobar-drag-handle=" ..
      tostring(self.autoBarDragHandleStatus or "pending") ..
    ",consumable-dock=" ..
      tostring(self.consumableDockStatus or "pending") ..
    ",trinket=" .. tostring(self.trinketFieldKitStatus or "pending") ..
    ",trinket-main=" .. tostring(self.trinketMainButtons or 0) ..
    ",trinket-menu=" .. tostring(self.trinketMenuButtons or 0) ..
    ",trinket-joiner=" ..
      tostring(self.trinketJoinerOrientation or "pending") ..
    ",trinket-dock=" ..
      tostring(self.trinketDockStatus or "pending") ..
    ",stance-dock=" ..
      tostring(self.stanceDockStatus or "pending") ..
    ",architotem-dock=" ..
      tostring(self.archiTotemDockStatus or "pending") ..
    ",architotem-direction=" ..
      tostring(self.archiTotemDirectionStatus or "pending")
end

addon:RegisterModule("ActionBars", ActionBars)
