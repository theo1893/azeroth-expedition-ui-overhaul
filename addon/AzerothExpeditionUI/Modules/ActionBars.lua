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
ActionBars.fieldKitRuntimeContract = "1.5"
ActionBars.focusLayoutRuntimeContract = "1.0"
ActionBars.focusLayoutVersion = 1
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
ActionBars.combatDeckBottomRatio = 210 / 1080
ActionBars.popupDrawerGap = 6
ActionBars.popupDrawerMaxRows = 6
ActionBars.popupIntentDelay = 0.30
ActionBars.popupIntentEvent = "AEUI_AutoBarPopupIntent"

-- ACTION-BARS-CORE-SIM-V3 is a 1920x1080 composition.  Store its anchors as
-- UIParent ratios so the one-shot preset retains the same composition when a
-- user keeps the 16:9 layout but changes resolution.  No maintenance loop
-- rewrites these positions after the preset has been applied.
ActionBars.focusUnitCenterOffsetRatio = 159.5 / 1920
ActionBars.focusUnitBottomRatio = 380 / 1080
ActionBars.focusCastBottomRatio = 352 / 1080
ActionBars.focusSwingCenterYOffsetRatio = -35 / 1080
ActionBars.focusStanceTopRatio = 744 / 1080
ActionBars.focusDoiteLeftRatio = 831 / 1920
ActionBars.focusDoiteTopRatio = 514 / 1080

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
  if type(position) ~= "table" then
    return false
  end
  return position.anchor == anchor and position.parent == "UIParent" and
    math.abs((tonumber(position.xpos) or 100000) - x) <= 1 and
    math.abs((tonumber(position.ypos) or 100000) - y) <= 1 and
    math.abs((tonumber(position.scale) or 100000) - scale) <= 0.001
end

local function CombatFocusLayoutSaved()
  if not UIParent or not UIParent.GetWidth or not UIParent.GetHeight or
    not pfUI_config
  then
    return false
  end
  local width = UIParent:GetWidth()
  local height = UIParent:GetHeight()
  local unitX = RoundCoordinate(
    width * ActionBars.focusUnitCenterOffsetRatio
  )
  local unitY = RoundCoordinate(height * ActionBars.focusUnitBottomRatio)
  local castY = RoundCoordinate(height * ActionBars.focusCastBottomRatio)
  local swingY = RoundCoordinate(
    height * ActionBars.focusSwingCenterYOffsetRatio
  )
  local stanceY = RoundCoordinate(
    -height * ActionBars.focusStanceTopRatio
  )
  local unitframes = pfUI_config.unitframes or {}
  local castbars = pfUI_config.castbar or {}
  local player = unitframes.player or {}
  local target = unitframes.target or {}
  local playerCast = castbars.player or {}
  local targetCast = castbars.target or {}

  return FocusPositionMatches(
      "pfPlayer", "BOTTOM", -unitX, unitY, 1.05
    ) and FocusPositionMatches(
      "pfTarget", "BOTTOM", unitX, unitY, 1.05
    ) and FocusPositionMatches(
      "pfPlayerCastbar", "BOTTOM", -unitX, castY, 1.05
    ) and FocusPositionMatches(
      "pfTargetCastbar", "BOTTOM", unitX, castY, 1.05
    ) and FocusPositionMatches(
      "pfSwingTimerMainhand", "CENTER", 0, swingY, 1
    ) and FocusPositionMatches(
      "pfSwingTimerRanged", "CENTER", 0, swingY, 1
    ) and FocusPositionMatches(
      "pfActionBarStances", "TOP", 0, stanceY, 1
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

  SavePfUIPosition(name, "BOTTOM", x, y, 1.05)
  local frame = pfUI and pfUI.uf and pfUI.uf[key] or GetGlobal(name)
  if frame and type(frame.UpdateConfig) == "function" then
    pcall(frame.UpdateConfig, frame)
  elseif frame and type(frame.UpdateFrameSize) == "function" then
    pcall(frame.UpdateFrameSize, frame)
  end
  return true, ApplyFramePosition(frame, "BOTTOM", x, y, 1.05)
end

local function ConfigureFocusCastBar(key, name, x, y)
  local castbars = pfUI_config and pfUI_config.castbar
  local config = castbars and castbars[key]
  if type(config) ~= "table" then
    return false, false
  end
  config.width = "-1"
  config.height = "22"
  SavePfUIPosition(name, "BOTTOM", x, y, 1.05)

  local frame = pfUI and pfUI.castbar and pfUI.castbar[key] or
    GetGlobal(name)
  if frame and frame.SetWidth then
    frame:SetWidth(280)
  end
  if frame and frame.SetHeight then
    frame:SetHeight(22)
  end
  return true, ApplyFramePosition(frame, "BOTTOM", x, y, 1.05)
end

local function ConfigureFocusSwingTimers(y)
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
  for index = 1, 2 do
    local frame = frames[index]
    SavePfUIPosition(names[index], "CENTER", 0, y, 1)
    if frame then
      if frame.SetWidth then frame:SetWidth(200) end
      if frame.SetHeight then frame:SetHeight(12) end
      if ApplyFramePosition(frame, "CENTER", 0, y, 1) then
        visible = visible + 1
      end
    end
  end
  if offhand then
    if offhand.SetWidth then offhand:SetWidth(200) end
    if offhand.SetHeight then offhand:SetHeight(12) end
    if main and offhand.ClearAllPoints and offhand.SetPoint then
      offhand:ClearAllPoints()
      offhand:SetPoint("TOP", main, "BOTTOM", 0, -4)
    end
  end
  return 2, visible
end

local function ConfigureFocusDoiteDPS(width, height)
  if type(DoiteDPSDB) ~= "table" then
    return false, false
  end
  local x = width * ActionBars.focusDoiteLeftRatio
  local y = -height * ActionBars.focusDoiteTopRatio
  DoiteDPSDB.point = "TOPLEFT"
  DoiteDPSDB.relativePoint = "TOPLEFT"
  DoiteDPSDB.x = x
  DoiteDPSDB.y = y

  local frame = GetGlobal("DoiteDPSMainFrame")
  return true, ApplyFramePosition(
    frame, "TOPLEFT", x, y, DoiteDPSDB.scale or 1
  )
end

function ActionBars:ApplyCombatFocusLayoutPreset()
  if type(InCombatLockdown) == "function" and InCombatLockdown() then
    self.focusLayoutStatus = "combat-locked"
    return false, "Leave combat before applying the Combat Focus layout."
  end
  if not UIParent or not UIParent.GetWidth or not UIParent.GetHeight or
    not pfUI_config
  then
    self.focusLayoutStatus = "unavailable"
    return false, "UIParent or the pfUI character profile is unavailable."
  end

  local width = UIParent:GetWidth()
  local height = UIParent:GetHeight()
  local unitX = width * self.focusUnitCenterOffsetRatio
  local unitY = height * self.focusUnitBottomRatio
  local castY = height * self.focusCastBottomRatio
  local swingY = height * self.focusSwingCenterYOffsetRatio
  local stanceY = -height * self.focusStanceTopRatio
  local configured = 0
  local live = 0

  local saved, applied = ConfigureFocusUnitFrame(
    "player", "pfPlayer", -unitX, unitY
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusUnitFrame(
    "target", "pfTarget", unitX, unitY
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)

  saved, applied = ConfigureFocusCastBar(
    "player", "pfPlayerCastbar", -unitX, castY
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusCastBar(
    "target", "pfTargetCastbar", unitX, castY
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)

  local swingConfigured, swingLive = ConfigureFocusSwingTimers(swingY)
  configured = configured + swingConfigured
  live = live + swingLive

  SavePfUIPosition("pfActionBarStances", "TOP", 0, stanceY, 1)
  if ApplyFramePosition(
    GetGlobal("pfActionBarStances"), "TOP", 0, stanceY, 1
  ) then
    live = live + 1
  end
  configured = configured + 1

  local doiteSaved, doiteApplied = ConfigureFocusDoiteDPS(width, height)
  configured = configured + (doiteSaved and 1 or 0)
  live = live + (doiteApplied and 1 or 0)

  local deckApplied = self:ResetCombatDeckPosition()
  if deckApplied then
    configured = configured + 1
    live = live + 1
  end

  local database = addon.db and addon.db.actionbars
  if database then
    database.combatFocusLayoutVersion = self.focusLayoutVersion
  end
  self.focusLayoutConfigured = configured
  self.focusLayoutLive = live
  self.focusLayoutDoite = doiteSaved and "preserved" or "missing"
  self.focusLayoutStatus = "applied"
  self.focusLayoutMousePolicy = "visible-controls-only"
  return true,
    "Combat Focus layout applied: player/target, paired cast bars, swing timers, stance bar, Combat Deck, and detected DoiteDPS. Provider visibility, lock state, and native translucency were preserved."
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
    if self.actionBarTopMovableCaptured and pfUI and pfUI.movables and
      self.actionBarTopMovableName
    then
      pfUI.movables[self.actionBarTopMovableName] =
        self.actionBarTopMovableEntry
    end
    self.actionBarStackApplied = false
    self.actionBarTopFreeAnchors = nil
    self.actionBarTopMovableCaptured = false
    self.actionBarTopMovableName = nil
    self.actionBarTopMovableEntry = nil
    self.actionBarStackStatus = enabled and "free" or "disabled"
    return false
  end

  if not main or not top or main == top then
    self.actionBarStackStatus = "unavailable"
    return false
  end

  if not self.actionBarStackApplied then
    self.actionBarTopFreeAnchors = CaptureFrameAnchors(top)
  end
  if not self.actionBarTopMovableCaptured and pfUI and pfUI.movables and
    top.GetName
  then
    self.actionBarTopMovableName = top:GetName()
    self.actionBarTopMovableEntry =
      pfUI.movables[self.actionBarTopMovableName]
    self.actionBarTopMovableCaptured = true
  end
  if self.actionBarTopMovableCaptured and pfUI and pfUI.movables then
    pfUI.movables[self.actionBarTopMovableName] = nil
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
    return true,
      "Combat Deck bound: consumables left, 12x2 action bars centered, trinkets right. Move the main action bar to move the whole deck."
  end
  self:ApplyActionBarStackPosition(FieldKitEnabled())
  self:ApplyConsumableDockPosition(FieldKitEnabled())
  self:ApplyTrinketDockPosition(FieldKitEnabled())
  self.consumableDockStatus = "free"
  self.trinketDockStatus = "free"
  return true, "Combat Deck unbound; action bars and both provider positions are independent."
end

function ActionBars:ResetCombatDeckPosition()
  if type(InCombatLockdown) == "function" and InCombatLockdown() then
    return false, "Leave combat before resetting the Combat Deck position."
  end
  local main = GetMainActionBarFrame()
  if not main or not UIParent or not UIParent.GetHeight then
    return false, "The main action bar or UIParent is unavailable."
  end

  local offset = UIParent:GetHeight() * self.combatDeckBottomRatio
  if main.SetParent then
    main:SetParent(UIParent)
  end
  main:ClearAllPoints()
  main:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, offset)

  if pfUI_config and type(pfUI_config.position) == "table" and
    main.GetName
  then
    local name = main:GetName()
    pfUI_config.position[name] = pfUI_config.position[name] or {}
    local position = pfUI_config.position[name]
    position.xpos = 0
    position.ypos = math.floor(offset + 0.5)
    position.anchor = "BOTTOM"
    position.parent = "UIParent"
  end

  local database = GetFieldKitDatabase()
  if database then
    database.combatDeckLayoutVersion = 1
  end
  self:SetFieldKitDocking(true)
  return true,
    "Combat Deck reset to the accepted center-lower layout and strongly bound."
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
  if AutoBar then
    self:InstallAutoBarPopupIntentGuard()
  end

  if type(hooksecurefunc) ~= "function" then
    return
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
  self.focusLayoutStatus = CombatFocusLayoutSaved() and "saved" or "ready"
  self.focusLayoutConfigured = 0
  self.focusLayoutLive = 0
  self.focusLayoutDoite = "pending"
  self.focusLayoutMousePolicy = "visible-controls-only"
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
end

function ActionBars:GetRuntimeStatus()
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
    ",focus-layout-mouse=" ..
      tostring(self.focusLayoutMousePolicy or "visible-controls-only") ..
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
      tostring(self.trinketDockStatus or "pending")
end

addon:RegisterModule("ActionBars", ActionBars)
