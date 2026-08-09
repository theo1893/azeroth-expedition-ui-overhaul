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
ActionBars.fieldKitRuntimeContract = "1.7"
ActionBars.focusLayoutRuntimeContract = "1.6"
ActionBars.focusLayoutVersion = 7
ActionBars.focusLayoutBackupVersion = 1
ActionBars.focusCoordinateSpace = "game-native-v1"
ActionBars.comfortUIScaleVersion = 2
ActionBars.comfortUIScaleTier = 8
ActionBars.comfortUIScaleValue = 0.71111111111111
-- ACTION-BARS-CORE-SIM-V5 keeps global pfUI tier 8 and the accepted Combat
-- Deck unchanged. Unit frames and their paired cast bars return to 0.75 to
-- clear the player silhouette; compact timing/readout providers stay at 0.82.
ActionBars.focusUnitScale = 0.75
ActionBars.focusReadoutScale = 0.82
ActionBars.focusDoiteScale = 0.82
ActionBars.trinketKitTexturePath =
  addon.media.root .. "ActionBars\\ActionTrinketKitV1"
ActionBars.consumableKitTexturePath =
  addon.media.root .. "ActionBars\\ActionConsumableKitV1"
ActionBars.fieldKitCap = 6
ActionBars.fieldKitPocketPadding = 4
ActionBars.fieldKitShellPadding = 6
ActionBars.consumableDockGap = 48
ActionBars.trinketDockGap = 16
ActionBars.actionBarStackOverlap = 1
ActionBars.popupDrawerGap = 6
ActionBars.popupDrawerMaxRows = 6
ActionBars.popupIntentDelay = 0.30
ActionBars.popupIntentEvent = "AEUI_AutoBarPopupIntent"
ActionBars.archiTotemDockXOffset = -10
-- V4: 12 px XP rail + 13 px clearance + half of the 26 px provider row,
-- converted through the audited 0.812698 UI scale, rounds to 47 UI.
ActionBars.archiTotemDockYOffset = -47

-- Runtime v1.6 uses the exact Turtle WoW 1.12 coordinates consumed by
-- Frame:SetPoint and pfUI.api.LoadMovable. They are relative to UIParent at
-- the required pfUI tier 8. Do not project them through GetScreenWidth,
-- effective scale, physical pixels, or frame readback: those are different
-- coordinate spaces in this client.
ActionBars.combatDeckX = 0
ActionBars.combatDeckY = 175
ActionBars.focusPlayerX = -212
ActionBars.focusTargetX = 213
ActionBars.focusUnitY = 492
ActionBars.focusCastY = 454
ActionBars.focusSwingX = 0
ActionBars.focusSwingY = -67
ActionBars.focusStanceX = 0
ActionBars.focusStanceY = -919
ActionBars.focusDoiteX = 1012
ActionBars.focusDoiteY = -647

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
    playerCastX = ActionBars.focusPlayerX,
    playerCastY = ActionBars.focusCastY,
    targetCastX = ActionBars.focusTargetX,
    targetCastY = ActionBars.focusCastY,
    swingX = ActionBars.focusSwingX,
    swingY = ActionBars.focusSwingY,
    stanceX = ActionBars.focusStanceX,
    stanceY = ActionBars.focusStanceY,
    doiteX = ActionBars.focusDoiteX,
    doiteY = ActionBars.focusDoiteY,
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

local function CaptureCombatFocusBackup()
  local database = addon.db and addon.db.actionbars
  if not database or database.combatFocusBackup then
    return false
  end
  local positions = pfUI_config and pfUI_config.position or {}
  local unitframes = pfUI_config and pfUI_config.unitframes or {}
  local castbars = pfUI_config and pfUI_config.castbar or {}
  local global = pfUI_config and pfUI_config.global or {}
  local backup = {
    version = ActionBars.focusLayoutBackupVersion,
    positions = {},
    unitframes = {
      player = CaptureField(unitframes, "player"),
      target = CaptureField(unitframes, "target"),
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

local function CombatFocusLayoutSaved()
  if not pfUI_config then
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
  local player = unitframes.player or {}
  local target = unitframes.target or {}
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

  return FocusPositionMatches(
      "pfPlayer", "BOTTOM", layout.playerX, layout.playerY,
      ActionBars.focusUnitScale
    ) and FocusPositionMatches(
      "pfTarget", "BOTTOM", layout.targetX, layout.targetY,
      ActionBars.focusUnitScale
    ) and FocusPositionMatches(
      "pfPlayerCastbar", "BOTTOM", layout.playerCastX,
      layout.playerCastY, ActionBars.focusUnitScale
    ) and FocusPositionMatches(
      "pfTargetCastbar", "BOTTOM", layout.targetCastX,
      layout.targetCastY, ActionBars.focusUnitScale
    ) and FocusPositionMatches(
      "pfSwingTimerMainhand", "CENTER", layout.swingX,
      layout.swingY, ActionBars.focusReadoutScale
    ) and FocusPositionMatches(
      "pfSwingTimerRanged", "CENTER", layout.swingX,
      layout.swingY, ActionBars.focusReadoutScale
    ) and FocusPositionMatches(
      "pfActionBarStances", "TOP", layout.stanceX,
      layout.stanceY, ActionBars.focusReadoutScale
    ) and player.width == "280" and player.height == "72" and
    player.buffs == "TOPLEFT" and player.debuffs == "TOPRIGHT" and
    player.buffperrow == "6" and player.debuffperrow == "6" and
    target.width == "280" and target.height == "72" and
    target.buffs == "TOPLEFT" and target.debuffs == "TOPRIGHT" and
    target.buffperrow == "6" and target.debuffperrow == "6" and
    playerCast.width == "-1" and playerCast.height == "22" and
    targetCast.width == "-1" and targetCast.height == "22" and
    unitframes.swingtimerwidth == "200" and
    unitframes.swingtimerheight == "12" and doiteMatches
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

local function ConfigureFocusUnitFrame(key, name, x, y)
  local unitframes = pfUI_config and pfUI_config.unitframes
  local config = unitframes and unitframes[key]
  if type(config) ~= "table" then
    return false, false
  end

  config.width = "280"
  config.height = "72"
  config.buffs = "TOPLEFT"
  config.debuffs = "TOPRIGHT"
  config.buffperrow = "6"
  config.debuffperrow = "6"

  local saved = SavePfUIPosition(
    name, "BOTTOM", x, y, ActionBars.focusUnitScale
  )
  local frame = pfUI and pfUI.uf and pfUI.uf[key] or GetGlobal(name)
  if frame and type(frame.UpdateFrameSize) == "function" then
    pcall(frame.UpdateFrameSize, frame)
  end
  if frame and type(frame.UpdateConfig) == "function" then
    pcall(frame.UpdateConfig, frame)
  end
  local applied = ApplyFramePosition(
    frame, "BOTTOM", x, y, ActionBars.focusUnitScale
  )
  return saved, applied
end

local function ConfigureFocusCastBar(key, name, x, y)
  local castbars = pfUI_config and pfUI_config.castbar
  local config = castbars and castbars[key]
  if type(config) ~= "table" then
    return false, false
  end
  config.width = "-1"
  config.height = "22"
  local saved = SavePfUIPosition(
    name, "BOTTOM", x, y, ActionBars.focusUnitScale
  )
  local frame = pfUI and pfUI.castbar and pfUI.castbar[key] or
    GetGlobal(name)
  if frame and frame.SetWidth then
    frame:SetWidth(280)
  end
  if frame and frame.SetHeight then
    frame:SetHeight(22)
  end
  local applied = ApplyFramePosition(
    frame, "BOTTOM", x, y, ActionBars.focusUnitScale
  )
  return saved, applied
end

local function ConfigureFocusSwingTimers(x, y)
  local unitframes = pfUI_config and pfUI_config.unitframes
  if type(unitframes) ~= "table" then
    return 0, 0
  end
  unitframes.swingtimerwidth = "200"
  unitframes.swingtimerheight = "12"

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
      names[index], "CENTER", x, y,
      ActionBars.focusReadoutScale
    ) then
      saved = saved + 1
    end
    if frame then
      if frame.SetWidth then frame:SetWidth(200) end
      if frame.SetHeight then frame:SetHeight(12) end
      local applied = ApplyFramePosition(
        frame, "CENTER", x, y, ActionBars.focusReadoutScale
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
    if offhand.SetWidth then offhand:SetWidth(200) end
    if offhand.SetHeight then offhand:SetHeight(12) end
    if main and offhand.ClearAllPoints and offhand.SetPoint then
      offhand:ClearAllPoints()
      offhand:SetPoint("TOP", main, "BOTTOM", 0, -4)
    end
  end
  return saved, visible
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
  local deckApplied, deckMessage = self:ResetCombatDeckPosition()
  if not deckApplied then
    self.focusLayoutStatus = "unavailable"
    return false, tostring(deckMessage)
  end
  local configured = 0
  local live = 0
  local layout = GetNativeFocusLayout()

  local saved, applied = ConfigureFocusUnitFrame(
    "player", "pfPlayer", layout.playerX, layout.playerY
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusUnitFrame(
    "target", "pfTarget", layout.targetX, layout.targetY
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

  local stanceSaved = SavePfUIPosition(
    "pfActionBarStances", "TOP", layout.stanceX, layout.stanceY,
    self.focusReadoutScale
  )
  local stanceApplied = ApplyFramePosition(
    GetGlobal("pfActionBarStances"), "TOP",
    layout.stanceX, layout.stanceY,
    self.focusReadoutScale
  )
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
    "Combat Focus layout applied with direct Turtle WoW game coordinates relative to UIParent: player/target and paired cast bars use 0.75; swing timers, stance bar, and detected DoiteDPS use 0.82. No screen-pixel projection, scale multiplication, probe, or coordinate readback was used. Provider visibility, lock state, and native translucency were preserved." ..
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

function ActionBars:RestoreCombatFocusLayoutPreset()
  if type(InCombatLockdown) == "function" and InCombatLockdown() then
    self.focusLayoutStatus = "combat-locked"
    return false, "Leave combat before restoring the Combat Focus layout."
  end
  local database = addon.db and addon.db.actionbars
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

  local frames = {
    pfUI and pfUI.uf and pfUI.uf.player,
    pfUI and pfUI.uf and pfUI.uf.target,
  }
  for index = 1, table.getn(frames) do
    local frame = frames[index]
    if frame and type(frame.UpdateFrameSize) == "function" then
      pcall(frame.UpdateFrameSize, frame)
    end
    if frame and type(frame.UpdateConfig) == "function" then
      pcall(frame.UpdateConfig, frame)
    end
  end

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
  self.focusLayoutStatus = "restored"
  self.focusLayoutConfigured = 0
  self.focusLayoutLive = 0
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
    "Comfort UI scale applied: pfUI tier 8 (0.711111), direct game-coordinate Combat Focus scales 0.75/0.82, and provider-native visibility preserved. Reload if a third-party frame does not redraw immediately."
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

function ActionBars:OpenAutoBarConfig()
  local toggle = GetGlobal("AutoBarConfig_Toggle")
  if not AutoBar or type(toggle) ~= "function" then
    self.autoBarPresetStatus = "missing"
    return false, "AutoBar is not enabled. Enable it at character select, then /reload."
  end
  toggle()
  self.autoBarPresetStatus = "config-opened"
  return true,
    "AutoBar config opened. Use /aeui autobar apply for the AEUI 4x6 preset."
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

  local before = CopyPlainTable(current)
  local manualSlot = AutoBar.buttons and AutoBar.buttons[16]
  local profile = current.profile or {}
  current.profile = profile
  profile.useCharacter = true
  profile.useShared = false
  profile.useClass = false
  profile.useBasic = false
  profile.layout = 1
  profile.layoutProfile = player
  profile.edit = 1
  profile.editing = player
  profile.shared = profile.shared or "_SHARED1"

  current.buttons = {}
  local class = GetPlayerClassToken()
  for index = 1, 24 do
    current.buttons[index] =
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
  display.showEmptyButtons = true
  display.showCategoryIcon = true
  display.popupDisable = false
  display.popupOnShift = false

  local ok, refreshed, message = pcall(RefreshAutoBarProfile)
  if not ok or not refreshed then
    AutoBar_Config[player] = before
    pcall(RefreshAutoBarProfile)
    self.autoBarPresetStatus = "error"
    return false, message or "AutoBar rejected the AEUI preset; the profile was restored."
  end

  addon.db.actionbars.autoBarBackups =
    addon.db.actionbars.autoBarBackups or {}
  if not addon.db.actionbars.autoBarBackups[player] then
    addon.db.actionbars.autoBarBackups[player] = before
  end
  self.autoBarPresetStatus = "applied"
  return true,
    "AEUI AutoBar preset applied to this character: 4x6, 24 slots, grouped categories, external popup drawer."
end

function ActionBars:RestoreAutoBarProfile()
  if not AutoBar or type(AutoBar_Config) ~= "table" then
    self.autoBarPresetStatus = "missing"
    return false, "AutoBar is not enabled."
  end
  local player = AutoBar.currentPlayer
  local backups = addon.db and addon.db.actionbars and
    addon.db.actionbars.autoBarBackups
  local backup = player and backups and backups[player]
  if type(backup) ~= "table" then
    self.autoBarPresetStatus = "no-backup"
    return false, "No AEUI AutoBar backup exists for this character."
  end

  local before = CopyPlainTable(AutoBar_Config[player])
  AutoBar_Config[player] = CopyPlainTable(backup)
  local ok, refreshed, message = pcall(RefreshAutoBarProfile)
  if not ok or not refreshed then
    AutoBar_Config[player] = before
    pcall(RefreshAutoBarProfile)
    self.autoBarPresetStatus = "error"
    return false, message or "AutoBar restore failed; the active profile was kept."
  end
  backups[player] = nil
  self.autoBarPresetStatus = "restored"
  return true, "AutoBar profile restored from the pre-AEUI backup."
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
  return true, "AutoBar popup mode set to " .. string.lower(normalized) .. "."
end

local function AutoBarGroupingMatches(visibleCount)
  local display = AutoBar and AutoBar.display
  return visibleCount == 24 and display and
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

local function ConfigureGroupLabel(label, shell, bounds)
  label:ClearAllPoints()
  label:SetPoint("RIGHT", shell, "LEFT", -2, 0)
  label:SetPoint("TOP", bounds.top, "TOP", 0, 2)
  label:SetWidth(40)
  label:SetHeight(20)
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

function ActionBars:UpdateFieldKitUnlockMover()
  local unlock = pfUI and pfUI.unlock
  local top = GetTopActionBarFrame()
  if not unlock or not top or not top.drag or
    type(unlock.IsShown) ~= "function" or not unlock:IsShown()
  then
    return false
  end

  if FieldKitEnabled() and FieldKitBound() then
    top.drag:Hide()
    return true
  end

  top.drag:Show()
  return false
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
    if FieldKitEnabled() and FieldKitBound() then
      ActionBars:ApplyActionBarStackPosition(true)
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

function ActionBars:ApplyConsumableDockPosition(enabled, bounds)
  local docked = FieldKitBound()
  local handle = GetGlobal("AutoBarAnchorFrameHandle")
  local main = GetMainActionBarFrame()

  if not enabled or not docked then
    if self.autoBarDockApplied then
      RestoreFrameAnchors(handle, self.autoBarUndockedAnchors)
    end
    self.autoBarDockApplied = false
    self.autoBarUndockedAnchors = nil
    self.consumableDockStatus = enabled and "free" or "disabled"
    return false
  end
  if not handle or not main or not bounds or bounds.count == 0 then
    self.consumableDockStatus = "unavailable"
    return false
  end

  local rightPixels, bottomPixels = ConsumableVisualEdges(bounds)
  local centerX, centerY = GetFrameCenter(handle)
  local mainLeft = FrameCoordinatePixels(main, "GetLeft")
  local mainBottom = FrameCoordinatePixels(main, "GetBottom")
  if not rightPixels or not bottomPixels or not centerX or not centerY or
    not mainLeft or not mainBottom
  then
    self.consumableDockStatus = "unavailable"
    return false
  end

  if not self.autoBarDockApplied then
    self.autoBarUndockedAnchors = CaptureFrameAnchors(handle)
  end
  local handleScale = GetFrameScale(handle)
  local rackScale = GetFrameScale(bounds.right)
  local centerXPixels = centerX * handleScale
  local centerYPixels = centerY * handleScale
  local rightDelta = rightPixels - centerXPixels
  local bottomDelta = bottomPixels - centerYPixels
  local xOffset =
    (-self.consumableDockGap * rackScale - rightDelta) / handleScale
  local yOffset = -bottomDelta / handleScale

  handle:ClearAllPoints()
  handle:SetPoint(
    "CENTER", main, "BOTTOMLEFT", xOffset, yOffset
  )
  self.autoBarDockApplied = true
  self.consumableDockStatus = "left"
  return true
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
    "BOTTOMLEFT", main, "BOTTOMRIGHT", self.trinketDockGap, 0
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
  -- The -10 UI x offset centers the real visible union, not the stale root.
  auditedFrame:SetPoint(
    "CENTER", main, "BOTTOM",
    self.archiTotemDockXOffset,
    self.archiTotemDockYOffset
  )
  self.archiTotemDockApplied = true
  self.archiTotemDockStatus = "bottom"
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
    local bounds = GetButtonExtremes(1, 24, "AutoBarFrameButton")
    self:ApplyConsumableDockPosition(FieldKitEnabled(), bounds)
    self:ApplyTrinketDockPosition(FieldKitEnabled())
    self:ApplyArchiTotemDockPosition(FieldKitEnabled())
    return true,
      "Combat Deck bound: consumables left, 12x2 action bars centered, trinkets right, and detected ArchiTotem below. Move the main action bar to move the whole deck."
  end
  self:ApplyActionBarStackPosition(FieldKitEnabled())
  self:ApplyConsumableDockPosition(FieldKitEnabled())
  self:ApplyTrinketDockPosition(FieldKitEnabled())
  self:ApplyArchiTotemDockPosition(FieldKitEnabled())
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

local function EnsureAutoBarGroupLabel(frame, index, text)
  frame.aeuiConsumableKitLabelsV1 =
    frame.aeuiConsumableKitLabelsV1 or {}
  local label = frame.aeuiConsumableKitLabelsV1[index]
  if not label then
    label = CreateDecorationFrame(frame)
    EnsureNineSlice(
      label,
      "aeuiConsumableKitLabelNineSliceV1",
      ActionBars.consumableKitTexturePath,
      consumableKitTexCoords.C,
      ActionBars.fieldKitCap
    )
    local font = label:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    font:SetAllPoints(label)
    font:SetJustifyH("CENTER")
    font:SetJustifyV("MIDDLE")
    font:SetTextColor(1, 0.82, 0.25, 1)
    label.aeuiConsumableKitTextV1 = font
    frame.aeuiConsumableKitLabelsV1[index] = label
  end
  label.aeuiConsumableKitTextV1:SetText(text)
  return label
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

  local names = { "应急", "增益", "工具" }
  local groups = { group1, group2, group3 }
  for index = 1, 3 do
    local label = EnsureAutoBarGroupLabel(frame, index, names[index])
    ConfigureGroupLabel(label, frame.aeuiConsumableKitShellV1, groups[index])
    label:Show()
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
  if ActionBars.autoBarGrouped then
    left = left - 42
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
  local labelOffset = ActionBars.autoBarGrouped and 42 or 0

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
  local drawerEnabled = enabled and activeBase and
    GetPopupMode() ~= "NATIVE" and
    AutoBarGroupingMatches(mainBounds.count)

  if drawerEnabled then
    HideUnusedPopupConnectors(frame, 1)
    local side = ResolveAutoBarDrawerSide(frame)
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
    self.autoBarMainButtons = 0
    self.autoBarGrouped = false
    self.consumableDockStatus = "unavailable"
    self:ApplyAutoBarPopup(false)
    return false
  end

  local bounds = GetButtonExtremes(1, 24, "AutoBarFrameButton")
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
  self:ApplyConsumableDockPosition(enabled, bounds)
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

function ActionBars:InstallFieldKitHooks()
  self:InstallFieldKitUnlockHooks()

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
      local ok = pcall(
        ActionBars.ApplyActionBarStackPosition,
        ActionBars,
        FieldKitEnabled()
      )
      if not ok then
        ActionBars.actionBarStackStatus = "error"
      end
    end)
  end

  if AutoBar then
    if not self.autoBarSetupHooked and
      type(GetGlobal("AutoBar_SetupVisual")) == "function"
    then
      self.autoBarSetupHooked = true
      hooksecurefunc("AutoBar_SetupVisual", function()
        SafeFieldKitApply("ApplyAutoBarFieldKit")
      end)
    end
    if not self.autoBarButtonsHooked and
      type(AutoBar.ButtonsUpdate) == "function"
    then
      self.autoBarButtonsHooked = true
      hooksecurefunc(AutoBar, "ButtonsUpdate", function()
        SafeFieldKitApply("ApplyAutoBarFieldKit")
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
  self.autoBarGrouped = false
  self.autoBarPresetStatus = "ready"
  self.actionBarStackStatus = "pending"
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
  self.focusLayoutStatus = CombatFocusLayoutSaved() and "saved" or "ready"
  self.focusLayoutConfigured = 0
  self.focusLayoutLive = 0
  self.focusLayoutDoite = "pending"
  self.focusLayoutArchiTotem = "pending"
  self.focusLayoutMousePolicy = "visible-controls-only"
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

  self:InstallFieldKitHooks()
  self:ApplyActionBarStackPosition(enabled)
  self:ApplyAutoBarFieldKit(enabled)
  self:ApplyTrinketFieldKit(enabled)
  self:ApplyArchiTotemDockPosition(enabled)

  -- The offhand timer has no independent pfUI movable entry. Restore its
  -- one-shot display compensation when the rest of the saved focus signature
  -- is present; no position or size is maintained here.
  if CombatFocusLayoutSaved() then
    local offhand = pfUI and pfUI.swingtimer and pfUI.swingtimer.offhand
    if offhand and offhand.SetScale then
      offhand:SetScale(self.focusReadoutScale)
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
    ",focus-layout-contract=" ..
      tostring(self.focusLayoutRuntimeContract) ..
    ",focus-layout=" .. tostring(self.focusLayoutStatus or "ready") ..
    ",focus-layout-configured=" ..
      tostring(self.focusLayoutConfigured or 0) ..
    ",focus-layout-live=" .. tostring(self.focusLayoutLive or 0) ..
    ",focus-layout-doite=" ..
      tostring(self.focusLayoutDoite or "pending") ..
    ",focus-layout-architotem=" ..
      tostring(self.focusLayoutArchiTotem or "pending") ..
    ",focus-layout-mouse=" ..
      tostring(self.focusLayoutMousePolicy or "visible-controls-only") ..
    ",focus-layout-anchor=ui-parent" ..
    ",focus-layout-coordinate-space=" ..
      tostring(self.focusCoordinateSpace) ..
    ",focus-layout-unit-scale=" ..
      tostring(self.focusUnitScale) ..
    ",focus-layout-readout-scale=" ..
      tostring(self.focusReadoutScale) ..
    ",focus-ui-scale=" ..
      tostring(self.comfortUIScaleStatus or "custom") ..
    ",focus-ui-scale-tier=" .. tostring(uiScaleTier) ..
    ",focus-ui-scale-target=" .. tostring(self.comfortUIScaleTier) ..
    ",fieldkit-binding=" ..
      tostring(FieldKitBound() and "bound" or "free") ..
    ",actionbar-stack=" ..
      tostring(self.actionBarStackStatus or "pending") ..
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
      tostring(self.autoBarGrouped and "semantic" or "adaptive") ..
    ",autobar-preset=" ..
      tostring(self.autoBarPresetStatus or "ready") ..
    ",consumable-dock=" ..
      tostring(self.consumableDockStatus or "pending") ..
    ",trinket=" .. tostring(self.trinketFieldKitStatus or "pending") ..
    ",trinket-main=" .. tostring(self.trinketMainButtons or 0) ..
    ",trinket-menu=" .. tostring(self.trinketMenuButtons or 0) ..
    ",trinket-joiner=" ..
      tostring(self.trinketJoinerOrientation or "pending") ..
    ",trinket-dock=" ..
      tostring(self.trinketDockStatus or "pending") ..
    ",architotem-dock=" ..
      tostring(self.archiTotemDockStatus or "pending") ..
    ",architotem-direction=" ..
      tostring(self.archiTotemDirectionStatus or "pending")
end

addon:RegisterModule("ActionBars", ActionBars)
