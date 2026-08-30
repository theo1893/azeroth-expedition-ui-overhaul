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
ActionBars.fieldKitRuntimeContract = "3.0"
ActionBars.focusLayoutRuntimeContract = "3.5"
ActionBars.focusLayoutVersion = 21
ActionBars.focusLayoutBackupVersion = 1
ActionBars.focusUnitDefaultVersion = 5
ActionBars.focusUnitDefaultBackupVersion = 1
ActionBars.sideBarGroupRuntimeContract = "1.0"
ActionBars.sideBarGroupLayoutVersion = 1
ActionBars.sideBarGroupBackupVersion = 1
ActionBars.focusCoordinateSpace = "game-native-v1"
ActionBars.comfortUIScaleVersion = 2
ActionBars.comfortUIScaleTier = 8
ActionBars.comfortUIScaleValue = 0.71111111111111
-- ACTION-BARS-CORE-SIM-V11 keeps global pfUI tier 8 and the accepted Combat
-- Deck geometry. The provider-owned DoiteDPS two-row union keeps its vertical
-- safe lane and shifts left as a whole to clear the central combat view,
-- uses the client system face for the three local unit frames, and implements
-- the accepted right-side cluster as one reversible mover. Runtime v3.3
-- restores the compact primary frames and their readable eight-icon Aura
-- rows, with room for four full Debuff rows above the unchanged readout stack.
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
-- Eight cells occupy 233 UI and fit the complete 240 UI primary frame.
ActionBars.focusUnitWidth = 240
ActionBars.focusUnitHeight = 48
ActionBars.focusTargetTargetWidth = 240
ActionBars.focusTargetTargetHeight = 60
ActionBars.focusUnitFontRole = "system"
ActionBars.focusUnitFontSize = 18
ActionBars.focusUnitFontStyle = "OUTLINE"
ActionBars.focusAuraSize = 23
ActionBars.focusTargetTargetAuraSize = 23
ActionBars.focusAuraPerRow = 8
ActionBars.focusTargetTargetAuraPerRow = 8
ActionBars.focusPrimaryGap = 73
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
ActionBars.supplyDockGap = 12
ActionBars.trinketDockGap = 8
ActionBars.fieldKitDockYOffset = -20
ActionBars.actionBarStackOverlap = 1
ActionBars.popupDrawerGap = 6
ActionBars.popupDrawerMaxRows = 6
ActionBars.supplyPopupIntentDelay = 0.30
ActionBars.supplyRuntimeContract = "2.1"
ActionBars.supplyProfileVersion = 4
ActionBars.supplyMaxSlots = 24
ActionBars.supplyMaxItems = 12
ActionBars.supplyColumns = 4
ActionBars.supplyButtonSize = 36
ActionBars.supplyButtonGap = 3
ActionBars.supplyPopupCloseDelay = 0.30
ActionBars.supplyFallbackIcon = "Interface\\Icons\\INV_Misc_Gift_01"
-- The former -10 UI offset only centered ArchiTotem's visible union. Shift
-- that union another 128 UI left so all four downward element columns clear
-- the Target Markers icon board at the provider's current 0.8 scale.
ActionBars.archiTotemDockXOffset =
  ActionBars.combatDeckClassDockXOffset - 10
-- Keep the provider row below the XP rail with a compact five-pixel visual
-- clearance; the provider's root still omits its unscaled drag handle.
ActionBars.archiTotemDockYOffset = -39

-- Runtime v2.2 uses the exact Turtle WoW 1.12 coordinates consumed by
-- Frame:SetPoint and pfUI.api.LoadMovable. They are relative to UIParent at
-- the required pfUI tier 8. Do not project them through GetScreenWidth,
-- effective scale, physical pixels, or frame readback: those are different
-- coordinate spaces in this client.
ActionBars.combatDeckX = 0
ActionBars.combatDeckY = 175
-- 240 local UI at scale 0.8 is 192 game UI. The 265 UI centre distance keeps
-- 73 UI between the primary frames, while y=480 leaves four Debuff rows clear
-- of the unchanged player-cast, target-cast, and Swing readout stack.
ActionBars.focusPlayerX = -160
ActionBars.focusTargetX = 105
ActionBars.focusTargetTargetX = 393
ActionBars.focusUnitY = 480
ActionBars.focusTargetTargetY = 570
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
  elseif key == "focus" then
    return unitframes and unitframes.focus or GetGlobal("pfFocus")
  end
  return nil
end

local playerSkillBuffs
local criticalTargetDebuffs = {
  ["精灵之火"] = true,
  ["精灵之火（野性）"] = true,
  ["破甲攻击"] = true,
  ["破甲"] = true,
  ["雷霆一击"] = true,
  ["挫志怒吼"] = true,
  ["虚弱诅咒"] = true,
  ["鲁莽诅咒"] = true,
  ["元素诅咒"] = true,
  ["暗影诅咒"] = true,
  ["语言诅咒"] = true,
  ["疲劳诅咒"] = true,
}

local function GetPlayerSkillBuffs()
  if playerSkillBuffs then return playerSkillBuffs end
  if type(GetSpellName) ~= "function" then return nil end
  playerSkillBuffs = {}
  for index = 1, 1024 do
    local name = GetSpellName(index, BOOKTYPE_SPELL or "spell")
    if not name then break end
    playerSkillBuffs[string.lower(name)] = true
  end
  return playerSkillBuffs
end

local function FocusAuraPolicy(
  frame, unitstr, kind, name, caster, auraSlot
)
  local player = GetFocusUnitFrame("player")
  if frame == player then
    if kind == "debuff" then return true end
    local skills = name and GetPlayerSkillBuffs()
    if not skills then return nil end
    return skills[string.lower(name)] and true or false
  end

  local hostile = type(UnitCanAttack) == "function" and
    UnitCanAttack("player", unitstr)
  local friendly = type(UnitIsFriend) == "function" and
    UnitIsFriend("player", unitstr)
  if not hostile and not friendly then return nil end
  if hostile then
    if kind == "buff" then return true end
    local provider = pfUI and pfUI.api and pfUI.api.libdebuff
    if not provider then return nil end
    return caster == "player" or criticalTargetDebuffs[name] == true
  end
  return true
end

ActionBars.FocusAuraPolicy = FocusAuraPolicy

local function VisitFocusAuraFrames(callback)
  for _, key in pairs({ "player", "target", "ttarget", "focus" }) do
    local frame = GetFocusUnitFrame(key)
    if frame then callback(frame) end
  end
end

function ActionBars:ApplyFocusAuraPolicy(enabled)
  local applied = 0
  if pfUI and pfUI.api then
    if enabled then
      pfUI.api.aeuiAuraPolicy = FocusAuraPolicy
    elseif pfUI.api.aeuiAuraPolicy == FocusAuraPolicy then
      pfUI.api.aeuiAuraPolicy = nil
    end
  end
  VisitFocusAuraFrames(function(frame)
    if enabled then
      frame.aeuiAuraPolicy = FocusAuraPolicy
      applied = applied + 1
    elseif frame.aeuiAuraPolicy == FocusAuraPolicy then
      frame.aeuiAuraPolicy = nil
    end
    frame.update_aura = true
  end)

  if enabled and not self.focusAuraPolicyWatcher then
    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("SPELLS_CHANGED")
    watcher:SetScript("OnEvent", function()
      playerSkillBuffs = nil
      VisitFocusAuraFrames(function(frame)
        frame.update_aura = true
      end)
    end)
    self.focusAuraPolicyWatcher = watcher
  end
  self.focusAuraPolicyStatus = enabled and
    (applied > 0 and "active" or "provider-missing") or "off"
  return applied
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
      version ~= 17 and version ~= 18 and version ~= 19 and
      version ~= 20) or
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
    (version == 15 or version == 16 or version == 17 or version == 18 or
      version == 19 or version == 20) and
      650 or
    ((version == 9 or version == 10 or version == 11 or version == 12 or
      version == 13 or version == 14) and 850 or 1012)
  local oldDoiteY = version == 8 and -780 or
    ((version == 13 or version == 14 or version == 15 or version == 16 or
      version == 17 or version == 18 or version == 19 or version == 20) and
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

  -- ApplyFocusUnitDefaults runs before this migration and restores the exact
  -- v17-v20 primary frames to the compact 8x4 contract. Match that upgraded
  -- unit subset together with the untouched readout/deck signature, then
  -- persist the complete layout as v21.
  if version == 17 or version == 18 or version == 19 or version == 20 then
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
      player.buffs == "TOPLEFT" and
      player.debuffs == "BOTTOMLEFT" and
      player.buffsize == tostring(ActionBars.focusAuraSize) and
      player.debuffsize == tostring(ActionBars.focusAuraSize) and
      player.buffperrow == tostring(ActionBars.focusAuraPerRow) and
      player.debuffperrow == tostring(ActionBars.focusAuraPerRow) and
      AuraOffsetsMatch(player) and SystemUnitFontMatches(player) and
      target.width == tostring(ActionBars.focusUnitWidth) and
      target.height == tostring(ActionBars.focusUnitHeight) and
      target.buffs == "TOPRIGHT" and
      target.debuffs == "BOTTOMRIGHT" and
      target.buffsize == tostring(ActionBars.focusAuraSize) and
      target.debuffsize == tostring(ActionBars.focusAuraSize) and
      target.buffperrow == tostring(ActionBars.focusAuraPerRow) and
      target.debuffperrow == tostring(ActionBars.focusAuraPerRow) and
      AuraOffsetsMatch(target) and SystemUnitFontMatches(target) and
      targetTarget.width ==
        tostring(ActionBars.focusTargetTargetWidth) and
      targetTarget.height ==
        tostring(ActionBars.focusTargetTargetHeight) and
      targetTarget.buffs == "TOPRIGHT" and
      targetTarget.debuffs == "BOTTOMRIGHT" and
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
    player.buffs == "TOPLEFT" and player.debuffs == "BOTTOMLEFT" and
    player.buffsize == tostring(ActionBars.focusAuraSize) and
    player.debuffsize == tostring(ActionBars.focusAuraSize) and
    player.buffoffx == "0" and player.buffoffy == "0" and
    player.debuffoffx == "0" and player.debuffoffy == "0" and
    player.buffperrow == tostring(ActionBars.focusAuraPerRow) and
    player.debuffperrow == tostring(ActionBars.focusAuraPerRow) and
    UnitFontConfigured(player) and
    target.width == tostring(ActionBars.focusUnitWidth) and
    target.height == tostring(ActionBars.focusUnitHeight) and
    target.buffs == "TOPRIGHT" and target.debuffs == "BOTTOMRIGHT" and
    target.buffsize == tostring(ActionBars.focusAuraSize) and
    target.debuffsize == tostring(ActionBars.focusAuraSize) and
    target.buffoffx == "0" and target.buffoffy == "0" and
    target.debuffoffx == "0" and target.debuffoffy == "0" and
    target.buffperrow == tostring(ActionBars.focusAuraPerRow) and
    target.debuffperrow == tostring(ActionBars.focusAuraPerRow) and
    UnitFontConfigured(target) and
    targetTarget.width == tostring(ActionBars.focusTargetTargetWidth) and
    targetTarget.height == tostring(ActionBars.focusTargetTargetHeight) and
    targetTarget.buffs == "TOPRIGHT" and
    targetTarget.debuffs == "BOTTOMRIGHT" and
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
    "TOPLEFT", "BOTTOMLEFT", self.focusAuraSize,
    self.focusAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusUnitFrame(
    "target", "pfTarget", layout.targetX, layout.targetY,
    self.focusUnitScale, self.focusUnitWidth, self.focusUnitHeight,
    "TOPRIGHT", "BOTTOMRIGHT", self.focusAuraSize,
    self.focusAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusUnitFrame(
    "ttarget", "pfTargetTarget",
    layout.targetTargetX, layout.targetTargetY,
    self.focusTargetTargetScale,
    self.focusTargetTargetWidth, self.focusTargetTargetHeight,
    "TOPRIGHT", "BOTTOMRIGHT", self.focusTargetTargetAuraSize,
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
    "TOPLEFT", "BOTTOMLEFT", self.focusAuraSize,
    self.focusAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusUnitFrame(
    "target", "pfTarget", layout.targetX, layout.targetY,
    self.focusUnitScale, self.focusUnitWidth, self.focusUnitHeight,
    "TOPRIGHT", "BOTTOMRIGHT", self.focusAuraSize,
    self.focusAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusUnitFrame(
    "ttarget", "pfTargetTarget",
    layout.targetTargetX, layout.targetTargetY,
    self.focusTargetTargetScale,
    self.focusTargetTargetWidth, self.focusTargetTargetHeight,
    "TOPRIGHT", "BOTTOMRIGHT", self.focusTargetTargetAuraSize,
    self.focusTargetTargetAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)

  self.focusLayoutConfigured = configured
  self.focusLayoutLive = live
  self.focusLayoutStatus = "primary-units-compact-8x4"
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
    "TOPLEFT", "BOTTOMLEFT", self.focusAuraSize,
    self.focusAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusUnitFrame(
    "target", "pfTarget", layout.targetX, layout.targetY,
    self.focusUnitScale, self.focusUnitWidth, self.focusUnitHeight,
    "TOPRIGHT", "BOTTOMRIGHT", self.focusAuraSize,
    self.focusAuraPerRow
  )
  configured = configured + (saved and 1 or 0)
  live = live + (applied and 1 or 0)
  saved, applied = ConfigureFocusUnitFrame(
    "ttarget", "pfTargetTarget",
    layout.targetTargetX, layout.targetTargetY,
    self.focusTargetTargetScale,
    self.focusTargetTargetWidth, self.focusTargetTargetHeight,
    "TOPRIGHT", "BOTTOMRIGHT", self.focusTargetTargetAuraSize,
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
    "Combat Focus layout applied with direct Turtle WoW game coordinates: player and target use 240x48 at 0.8 with 18-point client-system unit text and a 480-UI bottom anchor; the compact 240x60 target-of-target remains at 0.68 and follows the Target alignment without resizing; 23x23 auras use pfUI's real seven-UI border step and fit eight per row, leaving all four lower Debuff rows clear of the unchanged centered 260x12 player-cast, target-cast, and Swing stack at 1.0. The stance bar uses 25 UI provider icons at full local scale 1.0 for readable warrior controls, while the provider-owned DoiteDPS timeline and resource row remain in their own safe lane. Provider visibility, lock state, and native translucency were preserved without screen-pixel projection or coordinate readback." ..
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

local function FieldKitEnabled()
  return addon.db and addon.db.actionbars and
    addon.db.actionbars.enabled
end

local function ApplyTrinketFieldKitSafely()
  local ok = pcall(
    ActionBars.ApplyTrinketFieldKit, ActionBars, FieldKitEnabled()
  )
  if not ok then ActionBars.trinketFieldKitStatus = "error" end
end

local function GetFieldKitDatabase()
  return addon.db and addon.db.actionbars
end

local function FieldKitBound()
  local database = GetFieldKitDatabase()
  return database and database.fieldKitBound == true
end

local function ParseSupplyItemId(value)
  if type(value) == "number" then
    value = math.floor(value)
    return value > 0 and value or nil
  end
  local text = tostring(value or "")
  local _, _, itemId = string.find(text, "item:(%d+)")
  if not itemId then
    _, _, itemId = string.find(text, "^%s*(%d+)%s*$")
  end
  itemId = math.floor(tonumber(itemId) or 0)
  return itemId > 0 and itemId or nil
end

local function NormalizeSupplyDraggedItemId(value)
  if type(value) ~= "number" then return nil end
  value = math.floor(value)
  return value > 0 and value or nil
end

local function GetSupplyBagItem(bag, slot)
  local info = type(GetBagItem) == "function" and GetBagItem(bag, slot)
  local itemId = info and ParseSupplyItemId(info.itemId)
  if not itemId and type(GetContainerItemLink) == "function" then
    itemId = ParseSupplyItemId(GetContainerItemLink(bag, slot))
  end
  return itemId, info
end

local function ClearSupplyDrag()
  ActionBars.supplyDragItemId = nil
end

local function NormalizeSupplyMinimum(value)
  value = math.floor(tonumber(value) or 1)
  return math.max(1, math.min(value, 999))
end

local function NormalizeSupplyName(value)
  local name = tostring(value or "")
  name = string.gsub(name, "^%s+", "")
  name = string.gsub(name, "%s+$", "")
  return name ~= "" and name or nil
end

local function NormalizeSupplySlots(profile)
  if type(profile) ~= "table" then
    return {}
  end
  local source = type(profile.slots) == "table" and profile.slots or {}
  local slots = {}
  local seen = {}
  for index = 1, ActionBars.supplyMaxSlots do
    local entry = source[index]
    local items = {}
    local itemSource = type(entry) == "table" and entry.items
    if type(itemSource) == "table" then
      for itemIndex = 1, ActionBars.supplyMaxItems do
        local item = itemSource[itemIndex]
        local itemId = type(item) == "table" and
          ParseSupplyItemId(item.itemId or item[1]) or
          ParseSupplyItemId(item)
        if itemId and not seen[itemId] then
          seen[itemId] = true
          table.insert(items, {
            itemId = itemId,
            minimum = NormalizeSupplyMinimum(
              type(item) == "table" and item.minimum or nil
            ),
          })
        end
      end
    else
      local itemId = type(entry) == "table" and
        ParseSupplyItemId(entry.itemId or entry[1]) or
        ParseSupplyItemId(entry)
      if itemId and not seen[itemId] then
        seen[itemId] = true
        table.insert(items, { itemId = itemId, minimum = 1 })
      end
    end
    if table.getn(items) > 0 then
      local primary = type(entry) == "table" and
        ParseSupplyItemId(
          entry.primaryItemId or entry.activeItemId or entry.itemId
        ) or nil
      local primaryFound = false
      for itemIndex = 1, table.getn(items) do
        if items[itemIndex].itemId == primary then
          primaryFound = true
          break
        end
      end
      slots[index] = {
        name = type(entry) == "table" and
          NormalizeSupplyName(entry.name) or nil,
        primaryItemId = primaryFound and primary or items[1].itemId,
        items = items,
      }
    end
  end
  profile.slots = slots
  return slots
end

local function GetSupplySlotStats(profile)
  local slots = type(profile) == "table" and profile.slots
  if type(slots) ~= "table" then return 0, 0 end
  local count = 0
  local last = 0
  for index = 1, ActionBars.supplyMaxSlots do
    if slots[index] then
      count = count + 1
      last = index
    end
  end
  return count, last
end

local function MoveSupplyGroup(slots, source, destination)
  if type(slots) ~= "table" or not slots[source] or
    destination < 1 or destination > ActionBars.supplyMaxSlots or
    source == destination
  then
    return false
  end
  slots[source], slots[destination] =
    slots[destination], slots[source]
  return true
end

local function GetSupplyPrimary(group)
  if not group or type(group.items) ~= "table" then return nil end
  for index = 1, table.getn(group.items) do
    if group.items[index].itemId == group.primaryItemId then
      return group.items[index], index
    end
  end
  return group.items[1], 1
end

local function GetSupplyGroupName(group, index)
  if group and group.name then return group.name end
  if group and table.getn(group.items or {}) == 1 then
    local name = GetItemInfo(group.items[1].itemId)
    if not name and type(GetItemStatsField) == "function" then
      name = GetItemStatsField(group.items[1].itemId, "displayName")
    end
    if name then return name end
  end
  return "补给组 " .. tostring(index or "")
end

local function FindSupplyItem(profile, itemId)
  if not profile then return nil, nil end
  for groupIndex = 1, ActionBars.supplyMaxSlots do
    local group = profile.slots[groupIndex]
    if group then
      for itemIndex = 1, table.getn(group.items) do
        if group.items[itemIndex].itemId == itemId then
          return groupIndex, itemIndex
        end
      end
    end
  end
  return nil, nil
end

local function GetSupplyProfile(create)
  local database = GetFieldKitDatabase()
  local profileKey = GetCharacterProfileKey()
  if not database or not profileKey then
    return nil, profileKey
  end
  if create and type(database.supplyProfiles) ~= "table" then
    database.supplyProfiles = {}
  end
  local profiles = database.supplyProfiles
  if type(profiles) ~= "table" then
    return nil, profileKey
  end
  if create and type(profiles[profileKey]) ~= "table" then
    profiles[profileKey] = {
      version = ActionBars.supplyProfileVersion,
      slots = {},
    }
  end
  local profile = profiles[profileKey]
  if profile then
    if profile.version ~= ActionBars.supplyProfileVersion then
      NormalizeSupplySlots(profile)
    end
    profile.version = ActionBars.supplyProfileVersion
  end
  return profile, profileKey
end

local function GetSupplyItemInfo(itemId)
  local name, link, quality, level, minimumLevel, itemType, subType,
    stackCount, texture = GetItemInfo(itemId)
  local location = ActionBars.supplyLocations and
    ActionBars.supplyLocations[itemId]
  if not texture and location then
    texture = location.texture
  end
  if type(GetItemStatsField) == "function" then
    name = name or GetItemStatsField(itemId, "displayName")
    if not texture and type(GetItemIconTexture) == "function" then
      local displayId = GetItemStatsField(itemId, "displayInfoID")
      texture = displayId and GetItemIconTexture(displayId)
      if texture and not string.find(texture, "\\") then
        texture = "Interface\\Icons\\" .. texture
      end
    end
  end
  if not name and link then
    local _, _, linkedName = string.find(link, "%[(.-)%]")
    name = linkedName
  end
  return name, link or ("item:" .. itemId .. ":0:0:0"), texture
end

local function SupplyCount(itemId)
  return ActionBars.supplyCounts and
    ActionBars.supplyCounts[itemId] or 0
end

local function AddSpecialFrameName(name)
  if not UISpecialFrames then return end
  for index = 1, table.getn(UISpecialFrames) do
    if UISpecialFrames[index] == name then return end
  end
  table.insert(UISpecialFrames, name)
end

function ActionBars:ShowSupplyItemTooltip(button, itemId, anchor)
  if not itemId or not GameTooltip then return end
  local location = self.supplyLocations and self.supplyLocations[itemId]
  local name, link = GetSupplyItemInfo(itemId)
  GameTooltip:SetOwner(button, anchor or "ANCHOR_RIGHT")
  if location and type(GameTooltip.SetBagItem) == "function" then
    GameTooltip:SetBagItem(location.bag, location.slot)
  elseif link and type(GameTooltip.SetHyperlink) == "function" then
    local ok = pcall(GameTooltip.SetHyperlink, GameTooltip, link)
    if not ok then
      GameTooltip:SetText(name or ("物品 #" .. itemId))
    end
  else
    GameTooltip:SetText(name or ("物品 #" .. itemId))
  end
  GameTooltip:Show()
end

function ActionBars:ShowSupplyTooltip(button)
  local profile = GetSupplyProfile(false)
  local group = profile and profile.slots[button.supplyIndex]
  local item = GetSupplyPrimary(group)
  self:ShowSupplyItemTooltip(button, item and item.itemId)
end

function ActionBars:UseSupplyItem(itemId)
  local location = itemId and self.supplyLocations and
    self.supplyLocations[itemId]
  if not location then
    addon:Print(itemId and
      ("补给缺货：itemID " .. itemId) or "这个补给槽为空。")
    return false
  end
  UseContainerItem(location.bag, location.slot)
  return true
end

function ActionBars:UseSupplySlot(index)
  local profile = GetSupplyProfile(false)
  local group = profile and profile.slots[index]
  local item = GetSupplyPrimary(group)
  if not self:UseSupplyItem(item and item.itemId) then
    if group then self:ShowSupplyPopup(index) end
    return false
  end
  self:HideSupplyPopup()
  return true
end

local function SetSupplyCooldown(button, itemId)
  local location = itemId and ActionBars.supplyLocations and
    ActionBars.supplyLocations[itemId]
  if location and type(GetContainerItemCooldown) == "function" and
    type(CooldownFrame_SetTimer) == "function"
  then
    local start, duration, enabled = GetContainerItemCooldown(
      location.bag, location.slot
    )
    CooldownFrame_SetTimer(
      button.cooldown, start or 0, duration or 0, enabled or 0
    )
  elseif button.cooldown and type(CooldownFrame_SetTimer) == "function" then
    CooldownFrame_SetTimer(button.cooldown, 0, 0, 0)
  end
end

local function CreateSupplyButton(root, index)
  local name = "AzerothExpeditionUISupplyButton" .. index
  local button = CreateFrame("Button", name, root)
  button:SetWidth(ActionBars.supplyButtonSize)
  button:SetHeight(ActionBars.supplyButtonSize)
  button:SetFrameLevel(root:GetFrameLevel() + 2)
  button.supplyIndex = index
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  button:RegisterForDrag("LeftButton")

  ApplyPocket(
    button,
    "aeuiSupplyPocketV1",
    ActionBars.consumableKitTexturePath,
    consumableKitTexCoords.A,
    consumableKitSpriteSizes.A,
    true,
    ActionBars.fieldKitPocketPadding
  )

  button.icon = button:CreateTexture(nil, "ARTWORK")
  button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4)
  button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 4)

  button.stock = button:CreateFontString(
    nil, "OVERLAY", "GameFontNormalSmall"
  )
  button.stock:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
  button.stock:SetJustifyH("RIGHT")

  button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
  button.highlight:SetAllPoints(button.icon)
  button.highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
  button.highlight:SetBlendMode("ADD")

  button.cooldown = CreateFrame(
    "Model", name .. "Cooldown", button, "CooldownFrameTemplate"
  )
  button.cooldown:SetAllPoints(button.icon)
  button.cooldown.pfCooldownType = "NOGCD"

  button:SetScript("OnClick", function()
    if arg1 == "RightButton" then
      ActionBars:ShowSupplyPopup(button.supplyIndex)
    else
      ActionBars:UseSupplySlot(button.supplyIndex)
    end
  end)
  button:SetScript("OnEnter", function()
    ActionBars:CancelSupplyPopupClose()
    ActionBars:ShowSupplyTooltip(button)
    ActionBars:ScheduleSupplyPopup(button.supplyIndex)
  end)
  button:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
    ActionBars:ScheduleSupplyPopupClose()
  end)
  button:SetScript("OnDragStart", function()
    if not FieldKitBound() and IsShiftKeyDown() then
      ActionBars:HideSupplyPopup()
      root:StartMoving()
      root.aeuiSupplyMoving = true
    end
  end)
  button:SetScript("OnDragStop", function()
    if root.aeuiSupplyMoving then
      root:StopMovingOrSizing()
      root.aeuiSupplyMoving = nil
      ActionBars:SaveSupplyFreePosition()
    end
  end)
  button:Hide()
  return button
end

local function CreateSupplyPopupButton(parent, index)
  local name = "AzerothExpeditionUISupplyPopupButton" .. index
  local button = CreateFrame("Button", name, parent)
  button:SetWidth(ActionBars.supplyButtonSize)
  button:SetHeight(ActionBars.supplyButtonSize)
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  ApplyPocket(
    button,
    "aeuiSupplyPopupPocketV1",
    ActionBars.consumableKitTexturePath,
    consumableKitTexCoords.B,
    consumableKitSpriteSizes.B,
    true,
    ActionBars.fieldKitPocketPadding
  )
  button.icon = button:CreateTexture(nil, "ARTWORK")
  button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4)
  button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 4)
  button.stock = button:CreateFontString(
    nil, "OVERLAY", "GameFontNormalSmall"
  )
  button.stock:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
  button.primary = button:CreateFontString(
    nil, "OVERLAY", "GameFontNormalSmall"
  )
  button.primary:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
  button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
  button.highlight:SetAllPoints(button.icon)
  button.highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
  button.highlight:SetBlendMode("ADD")
  button.cooldown = CreateFrame(
    "Model", name .. "Cooldown", button, "CooldownFrameTemplate"
  )
  button.cooldown:SetAllPoints(button.icon)
  button.cooldown.pfCooldownType = "NOGCD"
  button:SetScript("OnClick", function()
    if arg1 == "RightButton" then
      ActionBars:SetSupplyPrimary(
        ActionBars.supplyPopupOwnerIndex, button.supplyItemId
      )
    else
      ActionBars:UseSupplyItem(button.supplyItemId)
    end
    ActionBars:HideSupplyPopup()
  end)
  button:SetScript("OnEnter", function()
    ActionBars:CancelSupplyPopupIntent()
    ActionBars:ShowSupplyItemTooltip(
      button,
      button.supplyItemId,
      ActionBars.supplyPopupSide == "LEFT" and
        "ANCHOR_LEFT" or "ANCHOR_RIGHT"
    )
  end)
  button:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
    ActionBars:ScheduleSupplyPopupClose()
  end)
  button:Hide()
  return button
end

function ActionBars:EnsureSupplyPopup()
  if self.supplyPopup then return self.supplyPopup end
  local popup = CreateFrame(
    "Frame", "AzerothExpeditionUISupplyPopup", UIParent
  )
  popup:SetFrameStrata("HIGH")
  popup:SetClampedToScreen(true)
  popup:EnableMouse(true)
  popup.buttons = {}
  for index = 1, self.supplyMaxItems do
    popup.buttons[index] = CreateSupplyPopupButton(popup, index)
  end
  popup.spine = CreateDecorationFrame(popup)
  EnsureConnector(
    popup.spine,
    "aeuiSupplyPopupSpineV1",
    self.consumableKitTexturePath,
    consumableKitTexCoords.vertical,
    "VERTICAL",
    3
  )
  popup.bridge = CreateFrame("Frame", nil, popup)
  popup.bridge:EnableMouse(true)
  popup:SetScript("OnEnter", function()
    ActionBars:CancelSupplyPopupIntent()
  end)
  popup:SetScript("OnLeave", function()
    ActionBars:ScheduleSupplyPopupClose()
  end)
  popup.bridge:SetScript("OnEnter", function()
    ActionBars:CancelSupplyPopupIntent()
  end)
  popup.bridge:SetScript("OnLeave", function()
    ActionBars:ScheduleSupplyPopupClose()
  end)
  popup:Hide()
  self.supplyPopup = popup
  return popup
end

function ActionBars:SetSupplyPopupTimer(active)
  if not active and not self.supplyPopupTimer then return end
  if not self.supplyPopupTimer then
    self.supplyPopupTimer = CreateFrame("Frame", nil, UIParent)
  end
  self.supplyPopupTimer:SetScript(
    "OnUpdate",
    active and function() ActionBars:ProcessSupplyPopupTimer() end or nil
  )
end

function ActionBars:ProcessSupplyPopupTimer()
  local now = GetTime()
  if self.supplyPopupOpenAt and now >= self.supplyPopupOpenAt then
    local index = self.supplyPopupPendingIndex
    self.supplyPopupOpenAt = nil
    self.supplyPopupPendingIndex = nil
    self:ShowSupplyPopup(index)
  end
  if self.supplyPopupCloseAt and now >= self.supplyPopupCloseAt then
    self:HideSupplyPopup()
  end
  if not self.supplyPopupOpenAt and not self.supplyPopupCloseAt then
    self:SetSupplyPopupTimer(false)
  end
end

function ActionBars:ScheduleSupplyPopup(index)
  local profile = GetSupplyProfile(false)
  local group = profile and profile.slots[index]
  if not group or table.getn(group.items) < 2 then
    if self.supplyPopupOwnerIndex and
      self.supplyPopupOwnerIndex ~= index
    then
      self.supplyPopupCloseAt = GetTime() + self.supplyPopupIntentDelay
      self:SetSupplyPopupTimer(true)
    end
    return
  end
  if self.supplyPopupOwnerIndex == index and self.supplyPopup and
    self.supplyPopup:IsShown()
  then
    self.supplyPopupOpenAt = nil
    self.supplyPopupPendingIndex = nil
    return
  end
  self.supplyPopupCloseAt = nil
  self.supplyPopupPendingIndex = index
  self.supplyPopupOpenAt = GetTime() + self.supplyPopupIntentDelay
  self:SetSupplyPopupTimer(true)
end

function ActionBars:ScheduleSupplyPopupClose()
  self.supplyPopupOpenAt = nil
  self.supplyPopupPendingIndex = nil
  if self.supplyPopup and self.supplyPopup:IsShown() then
    self.supplyPopupCloseAt = GetTime() + self.supplyPopupCloseDelay
    self:SetSupplyPopupTimer(true)
  else
    self:SetSupplyPopupTimer(false)
  end
end

function ActionBars:CancelSupplyPopupClose()
  self.supplyPopupCloseAt = nil
  self:SetSupplyPopupTimer(self.supplyPopupOpenAt ~= nil)
end

function ActionBars:CancelSupplyPopupIntent()
  self.supplyPopupOpenAt = nil
  self.supplyPopupPendingIndex = nil
  self:CancelSupplyPopupClose()
end

function ActionBars:HideSupplyPopup()
  if self.supplyPopup then self.supplyPopup:Hide() end
  self.supplyPopupOpenAt = nil
  self.supplyPopupCloseAt = nil
  self.supplyPopupPendingIndex = nil
  self.supplyPopupOwnerIndex = nil
  self.supplyPopupSide = nil
  self.supplyPopupStatus = "closed"
  self:SetSupplyPopupTimer(false)
end

function ActionBars:RefreshSupplyPopup()
  local popup = self.supplyPopup
  local profile = GetSupplyProfile(false)
  local group = profile and profile.slots[self.supplyPopupOwnerIndex]
  if not popup or not group then return end
  for index = 1, self.supplyMaxItems do
    local button = popup.buttons[index]
    local item = group.items[index]
    if item then
      local _, _, texture = GetSupplyItemInfo(item.itemId)
      local count = SupplyCount(item.itemId)
      button.supplyItemId = item.itemId
      button.icon:SetTexture(texture or self.supplyFallbackIcon)
      button.stock:SetText(count)
      button.primary:SetText(
        group.primaryItemId == item.itemId and "主" or ""
      )
      button.primary:SetTextColor(1, 0.76, 0.28)
      if count == 0 then
        button.icon:SetVertexColor(0.38, 0.28, 0.28, 1)
        button.stock:SetTextColor(1, 0.28, 0.22)
      else
        button.icon:SetVertexColor(1, 1, 1, 1)
        button.stock:SetTextColor(1, 1, 1)
      end
      SetSupplyCooldown(button, item.itemId)
      button:Show()
    else
      button.supplyItemId = nil
      button:Hide()
    end
  end
end

function ActionBars:ShowSupplyPopup(index)
  local profile = GetSupplyProfile(false)
  local group = profile and profile.slots[index]
  local owner = self.supplyFrame and self.supplyFrame.buttons[index]
  local count = group and table.getn(group.items) or 0
  if not owner or count == 0 then return false end

  local popup = self:EnsureSupplyPopup()
  local rows = math.min(count, self.popupDrawerMaxRows)
  if count > self.popupDrawerMaxRows then rows = math.ceil(count / 2) end
  local columns = math.ceil(count / rows)
  local size = self.supplyButtonSize
  local gap = self.supplyButtonGap
  local rootX = self.supplyFrame:GetCenter()
  local parentX = UIParent:GetCenter()
  local side = "RIGHT"
  if FieldKitBound() or
    (rootX and parentX and rootX >= parentX)
  then
    side = "LEFT"
  end

  popup:SetWidth(columns * size + math.max(0, columns - 1) * gap)
  popup:SetHeight(rows * size + math.max(0, rows - 1) * gap)
  popup:ClearAllPoints()
  if side == "LEFT" then
    popup:SetPoint(
      "BOTTOMRIGHT", self.supplyFrame, "BOTTOMLEFT",
      -self.popupDrawerGap, self.fieldKitShellPadding
    )
  else
    popup:SetPoint(
      "BOTTOMLEFT", self.supplyFrame, "BOTTOMRIGHT",
      self.popupDrawerGap, self.fieldKitShellPadding
    )
  end
  for itemIndex = 1, count do
    local button = popup.buttons[itemIndex]
    local zero = itemIndex - 1
    local column = math.floor(zero / rows)
    local row = math.mod(zero, rows)
    button:ClearAllPoints()
    if side == "LEFT" then
      button:SetPoint(
        "BOTTOMRIGHT", popup, "BOTTOMRIGHT",
        -column * (size + gap), row * (size + gap)
      )
    else
      button:SetPoint(
        "BOTTOMLEFT", popup, "BOTTOMLEFT",
        column * (size + gap), row * (size + gap)
      )
    end
  end

  local lastNear = popup.buttons[math.min(rows, count)]
  popup.spine:ClearAllPoints()
  popup.spine:SetPoint("BOTTOM", popup.buttons[1], "BOTTOM", 0, -3)
  popup.spine:SetPoint("TOP", lastNear, "TOP", 0, 3)
  popup.spine:SetWidth(6)
  popup.bridge:ClearAllPoints()
  popup.bridge:SetWidth(
    self.popupDrawerGap + self.fieldKitShellPadding
  )
  if side == "LEFT" then
    popup.spine:SetPoint("LEFT", popup, "RIGHT", 0, 0)
    popup.bridge:SetPoint(
      "TOPRIGHT", self.supplyFrame, "TOPLEFT",
      self.fieldKitShellPadding, 0
    )
    popup.bridge:SetPoint(
      "BOTTOMRIGHT", self.supplyFrame, "BOTTOMLEFT",
      self.fieldKitShellPadding, 0
    )
  else
    popup.spine:SetPoint("RIGHT", popup, "LEFT", 0, 0)
    popup.bridge:SetPoint(
      "TOPLEFT", self.supplyFrame, "TOPRIGHT",
      -self.fieldKitShellPadding, 0
    )
    popup.bridge:SetPoint(
      "BOTTOMLEFT", self.supplyFrame, "BOTTOMRIGHT",
      -self.fieldKitShellPadding, 0
    )
  end
  self.supplyPopupOwnerIndex = index
  self.supplyPopupSide = side
  self.supplyPopupOpenAt = nil
  self.supplyPopupCloseAt = nil
  self:RefreshSupplyPopup()
  popup:Show()
  popup.spine:Show()
  popup.bridge:Show()
  self.supplyPopupStatus =
    "open-" .. string.lower(side) .. "-" .. columns .. "x" .. rows
  self:SetSupplyPopupTimer(false)
  return true
end

function ActionBars:EnsureSupplyFrame()
  local root = self.supplyFrame or
    GetGlobal("AzerothExpeditionUISupplyFrame")
  if root then return root end

  root = CreateFrame(
    "Frame", "AzerothExpeditionUISupplyFrame", UIParent
  )
  root:SetWidth(1)
  root:SetHeight(1)
  root:SetFrameStrata("MEDIUM")
  root:SetMovable(true)
  root:SetClampedToScreen(true)
  root:EnableMouse(true)
  root:SetScript("OnEnter", function()
    ActionBars:CancelSupplyPopupClose()
  end)
  root:SetScript("OnLeave", function()
    ActionBars:ScheduleSupplyPopupClose()
  end)

  local shell = CreateDecorationFrame(root)
  shell:SetAllPoints(root)
  EnsureNineSlice(
    shell,
    "aeuiSupplyNineSliceV1",
    self.consumableKitTexturePath,
    consumableKitTexCoords.C,
    self.fieldKitCap
  )
  root.aeuiSupplyShell = shell
  root.buttons = {}
  for index = 1, self.supplyMaxSlots do
    root.buttons[index] = CreateSupplyButton(root, index)
  end
  root:Hide()
  self.supplyFrame = root
  return root
end

function ActionBars:SaveSupplyFreePosition()
  local root = self.supplyFrame
  local profile = GetSupplyProfile(true)
  local x, y = GetFrameCenter(root)
  local parentX, parentY = GetFrameCenter(UIParent)
  if not root or not profile or not x or not y or
    not parentX or not parentY
  then
    return false
  end
  profile.position = {
    x = RoundCoordinate(x - parentX),
    y = RoundCoordinate(y - parentY),
  }
  return true
end

function ActionBars:ApplySupplyDockPosition()
  local root = self.supplyFrame
  local profile = GetSupplyProfile(false)
  if not root or not profile then return false end

  if FieldKitBound() then
    local main = GetMainActionBarFrame()
    if not main then
      self.supplyDockStatus = "unavailable"
      return false
    end
    root:ClearAllPoints()
    root:SetPoint(
      "BOTTOMRIGHT", main, "BOTTOMLEFT",
      -self.supplyDockGap, self.fieldKitDockYOffset
    )
    root.aeuiSupplyWasBound = true
    self.supplyDockStatus = "left"
    return true
  end

  if root.aeuiSupplyWasBound then
    self:SaveSupplyFreePosition()
  end
  local position = profile.position or { x = -260, y = -160 }
  root:ClearAllPoints()
  root:SetPoint(
    "CENTER", UIParent, "CENTER",
    tonumber(position.x) or -260,
    tonumber(position.y) or -160
  )
  root.aeuiSupplyWasBound = nil
  self.supplyDockStatus = "free"
  return true
end

function ActionBars:LayoutSupplyButtons()
  local root = self.supplyFrame
  local profile = GetSupplyProfile(false)
  local slots = profile and profile.slots or {}
  local count, last = GetSupplySlotStats(profile)
  if not root or count == 0 then return false end

  local columns = math.min(self.supplyColumns, last)
  local rows = math.floor((last - 1) / self.supplyColumns) + 1
  local padding = self.fieldKitShellPadding
  root:SetWidth(
    padding * 2 + columns * self.supplyButtonSize +
    math.max(0, columns - 1) * self.supplyButtonGap
  )
  root:SetHeight(
    padding * 2 + rows * self.supplyButtonSize +
    math.max(0, rows - 1) * self.supplyButtonGap
  )

  for index = 1, self.supplyMaxSlots do
    local button = root.buttons[index]
    button:ClearAllPoints()
    if slots[index] then
      local column = math.mod(index - 1, self.supplyColumns)
      local row = math.floor((index - 1) / self.supplyColumns)
      button:SetPoint(
        "BOTTOMLEFT", root, "BOTTOMLEFT",
        padding + column * (self.supplyButtonSize + self.supplyButtonGap),
        padding + row * (self.supplyButtonSize + self.supplyButtonGap)
      )
      button:Show()
    else
      button:Hide()
    end
  end
  self.supplyConfigured = count
  return true
end

function ActionBars:RefreshSupplyButtons()
  local root = self.supplyFrame
  local profile = GetSupplyProfile(false)
  if not root or not profile then return end

  local missingTotal = 0
  local itemTotal = 0
  for index = 1, self.supplyMaxSlots do
    local group = profile.slots[index]
    if group then
      local item = GetSupplyPrimary(group)
      local button = root.buttons[index]
      local _, _, texture = GetSupplyItemInfo(item.itemId)
      local count = SupplyCount(item.itemId)
      for itemIndex = 1, table.getn(group.items) do
        local member = group.items[itemIndex]
        local memberCount = SupplyCount(member.itemId)
        itemTotal = itemTotal + 1
        if memberCount == 0 then
          missingTotal = missingTotal + 1
        end
      end
      button.icon:SetTexture(texture or self.supplyFallbackIcon)
      button.stock:SetText(count)
      if count == 0 then
        button.icon:SetVertexColor(0.38, 0.28, 0.28, 1)
        button.stock:SetTextColor(1, 0.28, 0.22)
      else
        button.icon:SetVertexColor(1, 1, 1, 1)
        button.stock:SetTextColor(1, 1, 1)
      end
      SetSupplyCooldown(button, item.itemId)
    end
  end
  self.supplyItems = itemTotal
  self.supplyZero = missingTotal
  if self.supplyPopup and self.supplyPopup:IsShown() then
    self:RefreshSupplyPopup()
  end
end

function ActionBars:ScanSupplyInventory()
  local profile = GetSupplyProfile(false)
  local wanted = {}
  if profile then
    for index = 1, self.supplyMaxSlots do
      local group = profile.slots[index]
      if group then
        for itemIndex = 1, table.getn(group.items) do
          wanted[group.items[itemIndex].itemId] = true
        end
      end
    end
  end

  local counts = {}
  local locations = {}
  for bag = 0, 4 do
    local slots = GetContainerNumSlots(bag) or 0
    for slot = 1, slots do
      local itemId, info = GetSupplyBagItem(bag, slot)
      if itemId and wanted[itemId] then
        local texture, count, locked = GetContainerItemInfo(bag, slot)
        if not count or count == 0 then
          count = info and info.stackCount
        end
        count = math.abs(tonumber(count) or 1)
        counts[itemId] = (counts[itemId] or 0) + count
        if not locations[itemId] or
          (locations[itemId].locked and not locked)
        then
          locations[itemId] = {
            bag = bag,
            slot = slot,
            locked = locked,
            texture = texture,
          }
        end
      end
    end
  end
  self.supplyCounts = counts
  self.supplyLocations = locations
  self:RefreshSupplyButtons()
  if self.supplyManager and self.supplyManager:IsShown() then
    self:RefreshSupplyManager(false)
  end
end

function ActionBars:InstallSupplyEvents()
  if self.supplyEventFrame then return true end
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:RegisterEvent("BAG_UPDATE")
  frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
  frame:RegisterEvent("ITEM_LOCK_CHANGED")
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:SetScript("OnEvent", function()
    ActionBars:ScanSupplyInventory()
  end)
  self.supplyEventFrame = frame
  return true
end

function ActionBars:InstallSupplyDragHook()
  local supplyHook = pfUI and pfUI.env and pfUI.env.hooksecurefunc
  if self.supplyDragHooked or type(supplyHook) ~= "function" or
    type(PickupContainerItem) ~= "function"
  then
    return self.supplyDragHooked == true
  end
  supplyHook("PickupContainerItem", function(bag, slot)
    ClearSupplyDrag()
    if CursorHasItem() then return end
    bag = tonumber(bag)
    slot = tonumber(slot)
    if not bag or bag < 0 or bag > 4 or not slot or slot < 1 then
      return
    end
    ActionBars.supplyDragItemId = GetSupplyBagItem(bag, slot)
  end, true)
  if type(PickupInventoryItem) == "function" then
    supplyHook("PickupInventoryItem", function()
      ClearSupplyDrag()
    end, true)
  end
  if type(PickupBagFromSlot) == "function" then
    supplyHook("PickupBagFromSlot", function()
      ClearSupplyDrag()
    end, true)
  end
  if type(ClearCursor) == "function" then
    supplyHook("ClearCursor", function()
      ClearSupplyDrag()
    end)
  end
  self.supplyDragHooked = true
  return true
end

function ActionBars:ApplySupplyKit(enabled)
  local database = GetFieldKitDatabase()
  local profile = GetSupplyProfile(false)
  local configured = GetSupplySlotStats(profile)
  local active = enabled and database and
    database.suppliesEnabled ~= false and configured > 0
  local root = self.supplyFrame
  if not active then
    if root then root:Hide() end
    self:HideSupplyPopup()
    self.supplyConfigured = configured
    if configured == 0 then
      self.supplyItems = 0
      self.supplyZero = 0
    end
    self.supplyStatus = enabled and
      (database and database.suppliesEnabled == false and
        "disabled" or "empty") or "route-disabled"
    self.supplyDockStatus = "hidden"
    return false
  end

  root = self:EnsureSupplyFrame()
  self:LayoutSupplyButtons()
  self:ApplySupplyDockPosition()
  root:Show()
  self.supplyStatus = "available"
  self:ScanSupplyInventory()
  return true
end

function ActionBars:RefreshSupplyRoute()
  local enabled = FieldKitEnabled()
  self:ApplySupplyKit(enabled)
  self:ApplyCombatDeckGroup()
end

function ActionBars:SetSupplySlot(index, itemId)
  local profile = GetSupplyProfile(true)
  itemId = NormalizeSupplyDraggedItemId(itemId)
  if not profile or not itemId then
    return false, "只能从背包拖入物品。"
  end
  local slots = profile.slots
  index = math.max(1, math.min(
    math.floor(tonumber(index) or 1),
    self.supplyMaxSlots
  ))
  local existingGroup, existingItem = FindSupplyItem(profile, itemId)
  if existingGroup then
    self.selectedSupplySlot = existingGroup
    self.selectedSupplyMember = existingItem
    self:RefreshSupplyManager(true)
    return true, "这个物品已在补给组中。"
  end
  local group = slots[index]
  if group and table.getn(group.items) >= self.supplyMaxItems then
    return false, "每个补给组最多 12 个物品。"
  end
  if not group then
    local count = GetSupplySlotStats(profile)
    if count >= self.supplyMaxSlots then
      return false, "补给栏最多 24 个组。"
    end
    group = {
      primaryItemId = itemId,
      items = {},
    }
    slots[index] = group
  end
  table.insert(group.items, { itemId = itemId, minimum = 1 })
  self.selectedSupplySlot = index
  self.selectedSupplyMember = table.getn(group.items)
  self:HideSupplyPopup()
  self:RefreshSupplyRoute()
  self:RefreshSupplyManager(true)
  return true, table.getn(group.items) == 1 and
    "已创建补给组。" or "已加入当前补给组。"
end

function ActionBars:RemoveSupplySlot(index)
  local profile = GetSupplyProfile(false)
  index = math.floor(tonumber(index) or 0)
  if not profile or not profile.slots[index] then
    return false, "这个补给槽不存在。"
  end
  profile.slots[index] = nil
  self.selectedSupplySlot = index
  self.selectedSupplyMember = 1
  self:HideSupplyPopup()
  self:RefreshSupplyRoute()
  self:RefreshSupplyManager(true)
  return true, "已移除补给组。"
end

function ActionBars:MoveSupplySlotTo(index, destination)
  local profile = GetSupplyProfile(false)
  index = math.floor(tonumber(index) or 0)
  destination = math.floor(tonumber(destination) or 0)
  if not profile or not profile.slots[index] then
    return false, "这个补给组不存在。"
  end
  if not MoveSupplyGroup(profile.slots, index, destination) then
    return false, "目标槽位无效。"
  end
  self.selectedSupplySlot = destination
  self:HideSupplyPopup()
  self:RefreshSupplyRoute()
  self:RefreshSupplyManager(true)
  return true, "补给组已移至槽位 " .. destination .. "。"
end

function ActionBars:MoveSupplySlot(index, delta)
  index = math.floor(tonumber(index) or 0)
  delta = delta < 0 and -1 or 1
  return self:MoveSupplySlotTo(index, index + delta)
end

function ActionBars:SetSupplyGroupName(index, name)
  local profile = GetSupplyProfile(false)
  local group = profile and profile.slots[index]
  if not group then return false, "这个补给组不存在。" end
  group.name = NormalizeSupplyName(name)
  self:RefreshSupplyManager(true)
  return true, "补给组名称已保存。"
end

function ActionBars:SetSupplyPrimary(index, itemId)
  local profile = GetSupplyProfile(false)
  local group = profile and profile.slots[index]
  local _, itemIndex = GetSupplyPrimary(group)
  if group then
    for candidate = 1, table.getn(group.items) do
      if group.items[candidate].itemId == itemId then
        itemIndex = candidate
        break
      end
    end
  end
  local item = group and group.items[itemIndex]
  if not item or item.itemId ~= itemId then
    return false, "这个物品不在当前补给组。"
  end
  group.primaryItemId = itemId
  self.selectedSupplySlot = index
  self.selectedSupplyMember = itemIndex
  self:RefreshSupplyButtons()
  self:RefreshSupplyManager(true)
  return true, "已设为主格物品。"
end

function ActionBars:RemoveSupplyItem(index, itemIndex)
  local profile = GetSupplyProfile(false)
  local group = profile and profile.slots[index]
  local item = group and group.items[itemIndex]
  if not item then return false, "这个组内物品不存在。" end
  table.remove(group.items, itemIndex)
  if table.getn(group.items) == 0 then
    profile.slots[index] = nil
    self.selectedSupplySlot = index
    self.selectedSupplyMember = 1
  else
    if group.primaryItemId == item.itemId then
      group.primaryItemId = group.items[1].itemId
    end
    self.selectedSupplyMember = math.max(
      1, math.min(itemIndex, table.getn(group.items))
    )
  end
  self:HideSupplyPopup()
  self:RefreshSupplyRoute()
  self:RefreshSupplyManager(true)
  return true, "已移除组内物品。"
end

function ActionBars:MoveSupplyItem(index, itemIndex, delta)
  local profile = GetSupplyProfile(false)
  local group = profile and profile.slots[index]
  itemIndex = math.floor(tonumber(itemIndex) or 0)
  delta = delta < 0 and -1 or 1
  local destination = itemIndex + delta
  if not group or not group.items[itemIndex] or
    not group.items[destination]
  then
    return false, "已经到达这一端。"
  end
  group.items[itemIndex], group.items[destination] =
    group.items[destination], group.items[itemIndex]
  self.selectedSupplyMember = destination
  self:HideSupplyPopup()
  self:RefreshSupplyManager(true)
  return true, "组内顺序已调整。"
end

function ActionBars:SetSuppliesEnabled(enabled)
  local database = GetFieldKitDatabase()
  if not database then
    return false, "Action Bars 配置不可用。"
  end
  database.suppliesEnabled = enabled and true or false
  self:RefreshSupplyRoute()
  self:RefreshSupplyManager(true)
  return true, enabled and
    "AEUI 补给栏已启用。" or
    "AEUI 补给栏已停用。"
end

function ActionBars:AssignSupplyFromCursor(index)
  local itemId = self.supplyDragItemId
  if not CursorHasItem() or not itemId then
    self:SetSupplyManagerStatus("只能从背包拖入物品。", true)
    return false
  end
  ClearCursor()
  local ok, message = self:SetSupplySlot(index, itemId)
  self:SetSupplyManagerStatus(message, not ok)
  return ok
end

function ActionBars:SetSupplyManagerStatus(message, isError)
  local frame = self.supplyManager
  if not frame or not frame.status then return end
  frame.status:SetText(message or "")
  if isError then
    frame.status:SetTextColor(1, 0.35, 0.25)
  else
    frame.status:SetTextColor(0.9, 0.78, 0.5)
  end
end

local function CreateSupplyManagerButton(parent, text, width)
  local button = CreateFrame(
    "Button", nil, parent, "UIPanelButtonTemplate"
  )
  button:SetWidth(width)
  button:SetHeight(22)
  button:SetText(text)
  return button
end

local function SetSupplyManagerEditEnabled(edit, enabled)
  edit:EnableMouse(enabled)
  edit:EnableKeyboard(enabled)
  if not enabled then edit:ClearFocus() end
end

local function CreateSupplyManagerCell(parent, index)
  local cell = CreateFrame("Button", nil, parent)
  cell:SetWidth(38)
  cell:SetHeight(38)
  cell.supplyIndex = index
  cell:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  cell:RegisterForDrag("LeftButton")
  cell:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
  })
  ApplyPocket(
    cell,
    "aeuiSupplyManagerPocketV1",
    ActionBars.consumableKitTexturePath,
    consumableKitTexCoords.A,
    consumableKitSpriteSizes.A,
    true,
    ActionBars.fieldKitPocketPadding
  )
  cell.icon = cell:CreateTexture(nil, "ARTWORK")
  cell.icon:SetPoint("TOPLEFT", cell, "TOPLEFT", 5, -5)
  cell.icon:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT", -5, 5)
  cell.slot = cell:CreateFontString(
    nil, "OVERLAY", "GameFontNormalSmall"
  )
  cell.slot:SetPoint("TOPLEFT", cell, "TOPLEFT", 3, -2)
  cell.stock = cell:CreateFontString(
    nil, "OVERLAY", "GameFontNormalSmall"
  )
  cell.stock:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT", -3, 3)
  cell.plus = cell:CreateFontString(
    nil, "OVERLAY", "GameFontNormalLarge"
  )
  cell.plus:SetPoint("CENTER", cell, "CENTER", 0, 0)
  cell:SetScript("OnClick", function()
    if CursorHasItem() then
      ActionBars:AssignSupplyFromCursor(cell.supplyIndex)
      return
    end
    local profile = GetSupplyProfile(false)
    local source = ActionBars.selectedSupplySlot
    if arg1 == "RightButton" and source ~= cell.supplyIndex and
      profile and profile.slots[source]
    then
      local ok, message = ActionBars:MoveSupplySlotTo(
        source, cell.supplyIndex
      )
      ActionBars:SetSupplyManagerStatus(message, not ok)
      return
    end
    ActionBars:SelectSupplySlot(cell.supplyIndex)
  end)
  cell:SetScript("OnReceiveDrag", function()
    ActionBars:AssignSupplyFromCursor(cell.supplyIndex)
  end)
  cell:SetScript("OnEnter", function()
    local profile = GetSupplyProfile(false)
    if profile and profile.slots[cell.supplyIndex] then
      ActionBars:ShowSupplyTooltip(cell)
      if GameTooltip then
        GameTooltip:AddLine("右键：把当前选中组移到这个槽位。")
        GameTooltip:Show()
      end
    elseif GameTooltip then
      GameTooltip:SetOwner(cell, "ANCHOR_RIGHT")
      GameTooltip:SetText("空补给槽")
      GameTooltip:AddLine("从背包把物品拖到这个槽位。")
      GameTooltip:AddLine("右键：把当前选中组移到这里。")
      GameTooltip:Show()
    end
  end)
  cell:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)
  return cell
end

local function CreateSupplyManagerMemberCell(parent, index)
  local cell = CreateFrame("Button", nil, parent)
  cell:SetWidth(38)
  cell:SetHeight(38)
  cell.memberIndex = index
  cell:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  cell:RegisterForDrag("LeftButton")
  cell:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
  })
  ApplyPocket(
    cell,
    "aeuiSupplyManagerMemberPocketV1",
    ActionBars.consumableKitTexturePath,
    consumableKitTexCoords.B,
    consumableKitSpriteSizes.B,
    true,
    ActionBars.fieldKitPocketPadding
  )
  cell.icon = cell:CreateTexture(nil, "ARTWORK")
  cell.icon:SetPoint("TOPLEFT", cell, "TOPLEFT", 5, -5)
  cell.icon:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT", -5, 5)
  cell.primary = cell:CreateFontString(
    nil, "OVERLAY", "GameFontNormalSmall"
  )
  cell.primary:SetPoint("TOPLEFT", cell, "TOPLEFT", 3, -2)
  cell.stock = cell:CreateFontString(
    nil, "OVERLAY", "GameFontNormalSmall"
  )
  cell.stock:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT", -3, 3)
  cell.plus = cell:CreateFontString(
    nil, "OVERLAY", "GameFontNormalLarge"
  )
  cell.plus:SetPoint("CENTER", cell, "CENTER", 0, 0)
  cell:SetScript("OnClick", function()
    if CursorHasItem() then
      ActionBars:AssignSupplyFromCursor(ActionBars.selectedSupplySlot)
      return
    end
    local profile = GetSupplyProfile(false)
    local group = profile and
      profile.slots[ActionBars.selectedSupplySlot]
    local item = group and group.items[cell.memberIndex]
    if not item then return end
    ActionBars:SelectSupplyMember(cell.memberIndex)
    if arg1 == "RightButton" and item then
      local ok, message = ActionBars:SetSupplyPrimary(
        ActionBars.selectedSupplySlot, item.itemId
      )
      ActionBars:SetSupplyManagerStatus(message, not ok)
    end
  end)
  cell:SetScript("OnReceiveDrag", function()
    ActionBars:AssignSupplyFromCursor(ActionBars.selectedSupplySlot)
  end)
  cell:SetScript("OnEnter", function()
    local profile = GetSupplyProfile(false)
    local group = profile and
      profile.slots[ActionBars.selectedSupplySlot]
    local item = group and group.items[cell.memberIndex]
    if item then
      ActionBars:ShowSupplyItemTooltip(cell, item.itemId)
    elseif GameTooltip then
      GameTooltip:SetOwner(cell, "ANCHOR_RIGHT")
      GameTooltip:SetText("空组内槽")
      GameTooltip:AddLine("从背包拖入物品，加入当前补给组。")
      GameTooltip:Show()
    end
  end)
  cell:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)
  return cell
end

function ActionBars:EnsureSupplyManager()
  if self.supplyManager then return self.supplyManager end
  local frame = CreateFrame(
    "Frame", "AzerothExpeditionUISupplyManager", UIParent
  )
  frame:SetWidth(540)
  frame:SetHeight(420)
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
  frame:SetFrameStrata("DIALOG")
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:SetClampedToScreen(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function() frame:StartMoving() end)
  frame:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
  end)
  frame:SetBackdrop(nativeTrinketBackdrop)
  frame:SetBackdropColor(0.05, 0.035, 0.02, 0.96)
  frame:SetBackdropBorderColor(0.58, 0.39, 0.2, 1)

  local art = CreateDecorationFrame(frame)
  art:SetAllPoints(frame)
  EnsureNineSlice(
    art,
    "aeuiSupplyManagerNineSliceV1",
    self.consumableKitTexturePath,
    consumableKitTexCoords.C,
    self.fieldKitCap
  )

  local title = frame:CreateFontString(
    nil, "OVERLAY", "GameFontNormalLarge"
  )
  title:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -15)
  title:SetText("AEUI 补给栏")

  frame.profile = frame:CreateFontString(
    nil, "OVERLAY", "GameFontNormalSmall"
  )
  frame.profile:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -40)
  frame.profile:SetTextColor(0.75, 0.68, 0.55)

  local help = frame:CreateFontString(
    nil, "OVERLAY", "GameFontHighlightSmall"
  )
  help:SetPoint("TOPLEFT", frame, "TOPLEFT", 216, -42)
  help:SetText("拖入创建／加入组；组格右键移动；组内右键设主")

  local close = CreateFrame(
    "Button", nil, frame, "UIPanelCloseButton"
  )
  close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)

  frame.cells = {}
  for index = 1, self.supplyMaxSlots do
    local cell = CreateSupplyManagerCell(frame, index)
    local column = math.mod(index - 1, self.supplyColumns)
    local row = math.floor((index - 1) / self.supplyColumns)
    cell:SetPoint(
      "TOPLEFT", frame, "TOPLEFT",
      20 + column * 44, -64 - row * 44
    )
    frame.cells[index] = cell
  end

  frame.selected = frame:CreateFontString(
    nil, "OVERLAY", "GameFontNormal"
  )
  frame.selected:SetPoint("TOPLEFT", frame, "TOPLEFT", 216, -74)
  frame.selected:SetWidth(304)
  frame.selected:SetJustifyH("LEFT")

  frame.nameLabel = frame:CreateFontString(
    nil, "OVERLAY", "GameFontNormalSmall"
  )
  frame.nameLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 216, -96)
  frame.nameLabel:SetText("组名")
  frame.nameEdit = CreateFrame(
    "EditBox", nil, frame, "InputBoxTemplate"
  )
  frame.nameEdit:SetWidth(160)
  frame.nameEdit:SetHeight(22)
  frame.nameEdit:SetPoint("TOPLEFT", frame, "TOPLEFT", 258, -87)
  frame.nameEdit:SetAutoFocus(false)
  frame.nameEdit:SetMaxLetters(24)
  frame.nameSave = CreateSupplyManagerButton(frame, "保存组名", 80)
  frame.nameSave:SetPoint("TOPLEFT", frame, "TOPLEFT", 432, -87)

  frame.membersLabel = frame:CreateFontString(
    nil, "OVERLAY", "GameFontNormalSmall"
  )
  frame.membersLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 216, -124)
  frame.membersLabel:SetText("组内物品（稳定顺序）")
  frame.memberCells = {}
  for index = 1, self.supplyMaxItems do
    local cell = CreateSupplyManagerMemberCell(frame, index)
    local column = math.mod(index - 1, 6)
    local row = math.floor((index - 1) / 6)
    cell:SetPoint(
      "TOPLEFT", frame, "TOPLEFT",
      218 + column * 44, -140 - row * 44
    )
    frame.memberCells[index] = cell
  end

  frame.memberSelected = frame:CreateFontString(
    nil, "OVERLAY", "GameFontNormalSmall"
  )
  frame.memberSelected:SetPoint("TOPLEFT", frame, "TOPLEFT", 216, -230)
  frame.memberSelected:SetWidth(304)
  frame.memberSelected:SetJustifyH("LEFT")

  frame.primary = CreateSupplyManagerButton(frame, "设为主格", 80)
  frame.primary:SetPoint("TOPLEFT", frame, "TOPLEFT", 216, -249)
  frame.removeItem = CreateSupplyManagerButton(frame, "移除物品", 80)
  frame.removeItem:SetPoint("LEFT", frame.primary, "RIGHT", 6, 0)
  frame.itemUp = CreateSupplyManagerButton(frame, "物品前移", 80)
  frame.itemUp:SetPoint("TOPLEFT", frame, "TOPLEFT", 216, -282)
  frame.itemDown = CreateSupplyManagerButton(frame, "物品后移", 80)
  frame.itemDown:SetPoint("LEFT", frame.itemUp, "RIGHT", 6, 0)

  frame.delete = CreateSupplyManagerButton(frame, "删除组", 74)
  frame.delete:SetPoint("TOPLEFT", frame, "TOPLEFT", 216, -320)
  frame.up = CreateSupplyManagerButton(frame, "槽位前移", 74)
  frame.up:SetPoint("LEFT", frame.delete, "RIGHT", 6, 0)
  frame.down = CreateSupplyManagerButton(frame, "槽位后移", 74)
  frame.down:SetPoint("LEFT", frame.up, "RIGHT", 6, 0)
  frame.toggle = CreateSupplyManagerButton(frame, "停用补给栏", 112)
  frame.toggle:SetPoint("TOPLEFT", frame, "TOPLEFT", 216, -352)

  frame.status = frame:CreateFontString(
    nil, "OVERLAY", "GameFontNormalSmall"
  )
  frame.status:SetPoint("TOPLEFT", frame, "TOPLEFT", 216, -386)
  frame.status:SetWidth(304)
  frame.status:SetJustifyH("LEFT")
  frame.status:SetTextColor(0.9, 0.78, 0.5)
  frame.status:SetText("主格左键使用；悬停或右键展开候选。")
  local function SaveGroupName()
    local ok, message = ActionBars:SetSupplyGroupName(
      ActionBars.selectedSupplySlot, frame.nameEdit:GetText()
    )
    frame.nameEdit:ClearFocus()
    ActionBars:SetSupplyManagerStatus(message, not ok)
  end
  frame.nameSave:SetScript("OnClick", SaveGroupName)
  frame.nameEdit:SetScript("OnEnterPressed", SaveGroupName)
  frame.nameEdit:SetScript("OnEscapePressed", function()
    frame.nameEdit:ClearFocus()
    ActionBars:RefreshSupplyManager(true)
  end)
  frame.primary:SetScript("OnClick", function()
    local profile = GetSupplyProfile(false)
    local group = profile and
      profile.slots[ActionBars.selectedSupplySlot]
    local item = group and
      group.items[ActionBars.selectedSupplyMember]
    local ok, message = ActionBars:SetSupplyPrimary(
      ActionBars.selectedSupplySlot, item and item.itemId
    )
    ActionBars:SetSupplyManagerStatus(message, not ok)
  end)
  frame.removeItem:SetScript("OnClick", function()
    local ok, message = ActionBars:RemoveSupplyItem(
      ActionBars.selectedSupplySlot, ActionBars.selectedSupplyMember
    )
    ActionBars:SetSupplyManagerStatus(message, not ok)
  end)
  frame.itemUp:SetScript("OnClick", function()
    local ok, message = ActionBars:MoveSupplyItem(
      ActionBars.selectedSupplySlot,
      ActionBars.selectedSupplyMember,
      -1
    )
    ActionBars:SetSupplyManagerStatus(message, not ok)
  end)
  frame.itemDown:SetScript("OnClick", function()
    local ok, message = ActionBars:MoveSupplyItem(
      ActionBars.selectedSupplySlot,
      ActionBars.selectedSupplyMember,
      1
    )
    ActionBars:SetSupplyManagerStatus(message, not ok)
  end)
  frame.delete:SetScript("OnClick", function()
    local ok, message = ActionBars:RemoveSupplySlot(
      ActionBars.selectedSupplySlot
    )
    ActionBars:SetSupplyManagerStatus(message, not ok)
  end)
  frame.up:SetScript("OnClick", function()
    local ok, message = ActionBars:MoveSupplySlot(
      ActionBars.selectedSupplySlot, -1
    )
    ActionBars:SetSupplyManagerStatus(message, not ok)
  end)
  frame.down:SetScript("OnClick", function()
    local ok, message = ActionBars:MoveSupplySlot(
      ActionBars.selectedSupplySlot, 1
    )
    ActionBars:SetSupplyManagerStatus(message, not ok)
  end)
  frame.toggle:SetScript("OnClick", function()
    local database = GetFieldKitDatabase()
    local ok, message = ActionBars:SetSuppliesEnabled(
      database and database.suppliesEnabled == false
    )
    ActionBars:SetSupplyManagerStatus(message, not ok)
  end)

  frame:Hide()
  AddSpecialFrameName(frame:GetName())
  self.supplyManager = frame
  return frame
end

function ActionBars:RefreshSupplyManager(refreshSelection)
  local frame = self.supplyManager
  local profile, profileKey = GetSupplyProfile(true)
  if not frame or not profile then return end
  self.selectedSupplySlot = math.max(1, math.min(
    tonumber(self.selectedSupplySlot) or 1,
    self.supplyMaxSlots
  ))
  frame.profile:SetText(
    "角色配置：" .. tostring(profileKey or "不可用")
  )

  for index = 1, self.supplyMaxSlots do
    local cell = frame.cells[index]
    local group = profile.slots[index]
    cell.slot:SetText(index)
    if group then
      local item = GetSupplyPrimary(group)
      local _, _, texture = GetSupplyItemInfo(item.itemId)
      local stock = SupplyCount(item.itemId)
      cell.icon:SetTexture(texture or self.supplyFallbackIcon)
      cell.icon:Show()
      cell.plus:SetText("")
      cell.stock:SetText(stock)
      if stock == 0 then
        cell.icon:SetVertexColor(0.38, 0.28, 0.28, 1)
        cell.stock:SetTextColor(1, 0.28, 0.22)
      else
        cell.icon:SetVertexColor(1, 1, 1, 1)
        cell.stock:SetTextColor(1, 1, 1)
      end
    else
      cell.icon:Hide()
      cell.stock:SetText("")
      cell.plus:SetText("+")
    end
    if index == self.selectedSupplySlot then
      cell:SetBackdropBorderColor(1, 0.72, 0.25, 1)
    else
      cell:SetBackdropBorderColor(0.28, 0.22, 0.16, 0.65)
    end
  end

  local database = GetFieldKitDatabase()
  frame.toggle:SetText(
    database and database.suppliesEnabled == false and
      "启用补给栏" or "停用补给栏"
  )
  local group = profile.slots[self.selectedSupplySlot]
  local memberCount = group and table.getn(group.items) or 0
  self.selectedSupplyMember = math.max(1, math.min(
    tonumber(self.selectedSupplyMember) or 1,
    math.max(1, memberCount)
  ))
  for index = 1, self.supplyMaxItems do
    local cell = frame.memberCells[index]
    local item = group and group.items[index]
    if item then
      local _, _, texture = GetSupplyItemInfo(item.itemId)
      local stock = SupplyCount(item.itemId)
      cell.icon:SetTexture(texture or self.supplyFallbackIcon)
      cell.icon:Show()
      cell.plus:SetText("")
      cell.primary:SetText(
        group.primaryItemId == item.itemId and "主" or ""
      )
      cell.primary:SetTextColor(1, 0.76, 0.28)
      cell.stock:SetText(stock)
      if stock == 0 then
        cell.icon:SetVertexColor(0.38, 0.28, 0.28, 1)
        cell.stock:SetTextColor(1, 0.28, 0.22)
      else
        cell.icon:SetVertexColor(1, 1, 1, 1)
        cell.stock:SetTextColor(1, 1, 1)
      end
    else
      cell.icon:Hide()
      cell.stock:SetText("")
      cell.primary:SetText("")
      cell.plus:SetText(index == memberCount + 1 and "+" or "")
    end
    if group and index == self.selectedSupplyMember then
      cell:SetBackdropBorderColor(1, 0.72, 0.25, 1)
    else
      cell:SetBackdropBorderColor(0.28, 0.22, 0.16, 0.65)
    end
  end
  local selectedItem = group and group.items[self.selectedSupplyMember]
  if selectedItem then
    local name = GetSupplyItemInfo(selectedItem.itemId)
    frame.memberSelected:SetText(
      tostring(name or ("物品 #" .. selectedItem.itemId)) ..
      " · 库存 " .. SupplyCount(selectedItem.itemId)
    )
  else
    frame.memberSelected:SetText("从背包拖入物品，加入当前组。")
  end
  if not refreshSelection then return end

  if group then
    frame.selected:SetText(
      "组 " .. self.selectedSupplySlot .. " · " ..
      GetSupplyGroupName(group, self.selectedSupplySlot) ..
      " · " .. memberCount .. " 项"
    )
    frame.nameEdit:SetText(group.name or "")
    frame.nameSave:Enable()
    frame.delete:Enable()
    frame.up:Enable()
    frame.down:Enable()
  else
    frame.selected:SetText(
      "组 " .. self.selectedSupplySlot .. " · 从背包拖入以创建"
    )
    frame.nameEdit:SetText("")
    frame.nameSave:Disable()
    frame.delete:Disable()
    frame.up:Disable()
    frame.down:Disable()
  end
  SetSupplyManagerEditEnabled(frame.nameEdit, group ~= nil)

  local item = selectedItem
  if item then
    frame.primary:Enable()
    frame.removeItem:Enable()
    frame.itemUp:Enable()
    frame.itemDown:Enable()
  else
    frame.primary:Disable()
    frame.removeItem:Disable()
    frame.itemUp:Disable()
    frame.itemDown:Disable()
  end
end

function ActionBars:SelectSupplySlot(index)
  local profile = GetSupplyProfile(true)
  if not profile then return false end
  self.selectedSupplySlot = math.max(1, math.min(
    math.floor(tonumber(index) or 1),
    self.supplyMaxSlots
  ))
  self.selectedSupplyMember = 1
  self:RefreshSupplyManager(true)
  return true
end

function ActionBars:SelectSupplyMember(index)
  local profile = GetSupplyProfile(true)
  local group = profile and profile.slots[self.selectedSupplySlot]
  if not group then return false end
  self.selectedSupplyMember = math.max(1, math.min(
    math.floor(tonumber(index) or 1), table.getn(group.items)
  ))
  self:RefreshSupplyManager(true)
  return true
end

function ActionBars:OpenSupplyManager()
  if not GetSupplyProfile(true) then
    return false, "当前角色补给配置不可用。"
  end
  if not CursorHasItem() then ClearSupplyDrag() end
  local frame = self:EnsureSupplyManager()
  self:ScanSupplyInventory()
  self:RefreshSupplyManager(true)
  frame:Show()
  return true, "已打开 AEUI 补给栏管理。"
end

function ActionBars:ToggleSupplyManager()
  local frame = self:EnsureSupplyManager()
  if frame:IsShown() then
    frame:Hide()
    return true, "已关闭 AEUI 补给栏管理。"
  end
  return self:OpenSupplyManager()
end

function ActionBars:RunSupplySelfCheck()
  local profile = {
    slots = {
      [2] = { itemId = "item:13446:0:0:0", target = "5" },
      [4] = { itemId = 0, target = 99 },
      [7] = {
        name = " 抗性药水 ",
        activeItemId = 201,
        items = {
          { itemId = "200", minimum = 5 },
          { itemId = "201", minimum = 0 },
          { itemId = "13446", minimum = 9 },
        },
      },
      [9] = { itemId = "200" },
    },
  }
  local slots = NormalizeSupplySlots(profile)
  local slotCount, lastSlot = GetSupplySlotStats(profile)
  local first = {}
  local fourth = {}
  local moveSlots = { [1] = first, [4] = fourth }
  local moved = MoveSupplyGroup(moveSlots, 1, 3)
  local swapped = MoveSupplyGroup(moveSlots, 3, 4)
  local positionsWork = moved and swapped and
    not moveSlots[1] and moveSlots[3] == fourth and
    moveSlots[4] == first
  local dragged = NormalizeSupplyDraggedItemId(20452.9)
  local rejectsManual =
    not NormalizeSupplyDraggedItemId("20452") and
    not NormalizeSupplyDraggedItemId(
      "|Hitem:20452:0:0:0|h[沙漠肉丸子]|h"
    )
  local ok = self.supplyDragHooked == true and
    slotCount == 2 and lastSlot == 7 and positionsWork and
    slots[2].primaryItemId == 13446 and
    table.getn(slots[2].items) == 1 and
    slots[2].items[1].minimum == 1 and
    slots[7].name == "抗性药水" and
    slots[7].primaryItemId == 201 and
    table.getn(slots[7].items) == 2 and
    slots[7].items[1].itemId == 200 and
    slots[7].items[1].minimum == 5 and
    slots[7].items[2].itemId == 201 and
    slots[7].items[2].minimum == 1 and dragged == 20452 and
    rejectsManual
  return ok, ok and
    "补给栏 self-check 通过。" or
    "补给栏 self-check 失败：拖入钩子／槽位／迁移／去重边界异常。"
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
  self:ApplySupplyDockPosition()
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
  InstallCombatDeckFrameScript(
    GetGlobal("pfActionBarStances"), "OnEvent"
  )
  local pet = GetGlobal("pfActionBarPet")
  InstallCombatDeckFrameScript(pet, "OnEvent")
  InstallCombatDeckFrameScript(pet, "OnShow")
  InstallCombatDeckFrameScript(pet, "OnHide")
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
  if docked then
    self:ApplyActionBarStackPosition(FieldKitEnabled())
    self:ApplyStanceDockPosition(FieldKitEnabled())
    self:ApplySupplyDockPosition()
    self:ApplyTrinketDockPosition(FieldKitEnabled())
    self:ApplyArchiTotemDockPosition(FieldKitEnabled())
    RefreshTargetMarkerAnchor()
    self:UpdateFieldKitUnlockMover()
    return true,
      "Combat Deck bound: supplies left and trinkets right share a 20 UI lower dock, 12x2 action bars stay centered, and warrior stances or detected ArchiTotem share the class slot below-left of the marker list. Move the main action bar to move the whole deck."
  end
  self:ApplyActionBarStackPosition(FieldKitEnabled())
  self:ApplyStanceDockPosition(FieldKitEnabled())
  self:ApplySupplyDockPosition()
  self:ApplyTrinketDockPosition(FieldKitEnabled())
  self:ApplyArchiTotemDockPosition(FieldKitEnabled())
  RefreshTargetMarkerAnchor()
  self:UpdateFieldKitUnlockMover()
  self.trinketDockStatus = "free"
  self.archiTotemDockStatus = "free"
  return true,
    "Combat Deck unbound; action bars, Supply, TrinketMenu, and ArchiTotem are independent."
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

function ActionBars:InstallFieldKitHooks()
  self:InstallFieldKitUnlockHooks()
  self:InstallCombatDeckGroupHooks()

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

  if TrinketMenu then
    if not self.trinketOrientHooked and
      type(TrinketMenu.OrientWindows) == "function"
    then
      self.trinketOrientHooked = true
      hooksecurefunc(TrinketMenu, "OrientWindows", function()
        ApplyTrinketFieldKitSafely()
      end)
    end
    if not self.trinketBuildHooked and
      type(TrinketMenu.BuildMenu) == "function"
    then
      self.trinketBuildHooked = true
      hooksecurefunc(TrinketMenu, "BuildMenu", function()
        ApplyTrinketFieldKitSafely()
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
  self.supplyStatus = "pending"
  self.supplyDockStatus = "pending"
  self.supplyConfigured = 0
  self.supplyItems = 0
  self.supplyZero = 0
  self.supplyPopupStatus = "closed"
  self.selectedSupplySlot = 1
  self.selectedSupplyMember = 1
  self.supplyCounts = {}
  self.supplyLocations = {}
  self.actionBarStackStatus = "pending"
  self.sideBarGroupStatus = SideBarGroupBound() and "bound" or "free"
  self.sideBarGroupMigration = "pending"
  self.sideBarGroupUpdating = false
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
  self.focusAuraPolicyStatus = "pending"
  self.focusStanceStatus = "pending"
  self.focusStanceUpdating = false
  self.combatDeckGroupStatus = "pending"
  self.comfortUIScaleStatus = ComfortUIScaleConfigured() and
    "saved" or "custom"
  self:InstallSupplyEvents()
  self:InstallSupplyDragHook()
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
  self:ApplyFocusAuraPolicy(enabled)

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
  self:InstallFocusUnitFontHooks()
  self:MigrateSideBarGroupDefault()
  self:MaintainSideBarGroup()
  self:ApplyActionBarStackPosition(enabled)
  self:ApplySupplyKit(enabled)
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
  local _, supplyProfileKey = GetSupplyProfile(false)
  return
    "contract=" .. tostring(self.runtimeContract) ..
    ",rail-contract=" .. tostring(self.railRuntimeContract) ..
    ",fieldkit-contract=" .. tostring(self.fieldKitRuntimeContract) ..
    ",supplies-contract=" .. tostring(self.supplyRuntimeContract) ..
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
    ",focus-layout-aura-policy=" ..
      tostring(self.focusAuraPolicyStatus or "pending") ..
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
    ",focus-layout-aura-growth=player-right+target-left" ..
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
    ",supplies=" .. tostring(self.supplyStatus or "pending") ..
    ",supplies-profile=" ..
      tostring(supplyProfileKey or "unavailable") ..
    ",supplies-configured=" .. tostring(self.supplyConfigured or 0) ..
    ",supplies-items=" .. tostring(self.supplyItems or 0) ..
    ",supplies-zero=" .. tostring(self.supplyZero or 0) ..
    ",supplies-popup=" ..
      tostring(self.supplyPopupStatus or "closed") ..
    ",supplies-dock=" ..
      tostring(self.supplyDockStatus or "pending") ..
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
