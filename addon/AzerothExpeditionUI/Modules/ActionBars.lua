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
ActionBars.fieldKitRuntimeContract = "1.0"
ActionBars.trinketKitTexturePath =
  addon.media.root .. "ActionBars\\ActionTrinketKitV1"
ActionBars.consumableKitTexturePath =
  addon.media.root .. "ActionBars\\ActionConsumableKitV1"
ActionBars.fieldKitCap = 6
ActionBars.fieldKitPocketPadding = 4

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
  local texture = button[key]
  if not texture then
    texture = button:CreateTexture(nil, "BACKGROUND")
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

local function AutoBarProfileMatches()
  if not AutoBar or type(AutoBar.buttons) ~= "table" then
    return false
  end
  local class = nil
  if type(UnitClass) == "function" then
    local ignored
    ignored, class = UnitClass("player")
  end
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

local function SafeFieldKitApply(methodName)
  local method = ActionBars[methodName]
  if type(method) ~= "function" then
    return
  end
  local ok = pcall(method, ActionBars, FieldKitEnabled())
  if not ok then
    if methodName == "ApplyTrinketFieldKit" then
      ActionBars.trinketFieldKitStatus = "error"
    else
      ActionBars.autoBarFieldKitStatus = "error"
    end
  end
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

function ActionBars:ApplyAutoBarPopup(enabled)
  local frame = GetGlobal("AutoBarPopupFrame")
  if not frame then
    self.autoBarPopupButtons = 0
    self.autoBarPopupConnectors = 0
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

  if not enabled or table.getn(buttons) < 2 then
    HideUnusedPopupConnectors(frame, 1)
    self.autoBarPopupButtons = table.getn(buttons)
    self.autoBarPopupConnectors = 0
    return true
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
  self.autoBarPopupButtons = table.getn(buttons)
  self.autoBarPopupConnectors = table.getn(buttons) - 1
  return true
end

function ActionBars:ApplyAutoBarFieldKit(enabled)
  local frame = GetGlobal("AutoBarFrame")
  if not AutoBar or not frame then
    self.autoBarFieldKitStatus = "missing"
    self.autoBarMainButtons = 0
    self.autoBarGrouped = false
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
  return true
end

function ActionBars:InstallFieldKitHooks()
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
      hooksecurefunc(AutoBar, "UpdatePopupButtons", function()
        SafeFieldKitApply("ApplyAutoBarPopup")
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
  self.autoBarGrouped = false
  self.trinketFieldKitStatus = "pending"
  self.trinketMainButtons = 0
  self.trinketMenuButtons = 0
  self.trinketJoinerOrientation = "pending"
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
  self:ApplyAutoBarFieldKit(enabled)
  self:ApplyTrinketFieldKit(enabled)
end

function ActionBars:GetRuntimeStatus()
  return
    "contract=" .. tostring(self.runtimeContract) ..
    ",rail-contract=" .. tostring(self.railRuntimeContract) ..
    ",fieldkit-contract=" .. tostring(self.fieldKitRuntimeContract) ..
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
    ",autobar-groups=" ..
      tostring(self.autoBarGrouped and "semantic" or "adaptive") ..
    ",trinket=" .. tostring(self.trinketFieldKitStatus or "pending") ..
    ",trinket-main=" .. tostring(self.trinketMainButtons or 0) ..
    ",trinket-menu=" .. tostring(self.trinketMenuButtons or 0) ..
    ",trinket-joiner=" ..
      tostring(self.trinketJoinerOrientation or "pending")
end

addon:RegisterModule("ActionBars", ActionBars)
