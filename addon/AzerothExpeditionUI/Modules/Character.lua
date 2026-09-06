local addon = AzerothExpeditionUI
local Character = {}

Character.runtimeContract = "2.1"
Character.texelDensity = 2

local COMPONENT_ROUTES = {
  "character.frame-shell-v3",
  "character.model-background-v3",
  "character.stats-paper-v3",
  "character.resistance-wells-v3",
  "character.slot-base-v3",
  "character.slot-interaction-v3",
}
local TAB_COMPONENT_ROUTE = "character.tabs-v3"
local AMMO_COMPONENT_ROUTE = "character.ammo-slot-v3"
local SECONDARY_LEAF_COMPONENT_ROUTE = "character.secondary-leaf-v3"
local MEDIA = addon.media.root .. "Character\\"
local PARCHMENT_VERTEX_COLOR = { 0.62, 0.62, 0.62 }
local ART = {
  topLeft = {
    path = MEDIA .. "CharacterFrameShellTopLeftV3",
    x = 0,
    y = 0,
    width = 256,
    height = 256,
  },
  topRight = {
    path = MEDIA .. "CharacterFrameShellTopRightV3",
    x = 256,
    y = 0,
    width = 128,
    height = 256,
  },
  bottomLeft = {
    path = MEDIA .. "CharacterFrameShellBottomLeftV3",
    x = 0,
    y = 256,
    width = 256,
    height = 256,
  },
  bottomRight = {
    path = MEDIA .. "CharacterFrameShellBottomRightV3",
    x = 256,
    y = 256,
    width = 128,
    height = 256,
  },
}

local MODEL_BACKGROUND = {
  path = MEDIA .. "CharacterModelBackgroundV3",
  -- PaperDoll-hosted textures render left of the shell's visual opening on
  -- the validated client.  Offset only this substrate to x=69;
  -- CharacterModelFrame keeps its native x=65 anchor.
  x = 69,
  -- The shell opening starts three UI units above the provider model.  Extend
  -- only this visual substrate to y=75 while keeping its lower edge at y=302;
  -- CharacterModelFrame itself remains on native y=78 geometry.
  y = 75,
  -- The provider model remains 233 UI units wide.  The accepted shell's
  -- visual content opening continues to x=312, so only the quiet center of
  -- this backdrop is stretched by 10 UI units to close that visible gap.
  width = 243,
  height = 227,
  texCoord = { 0, 466 / 512, 0, 448 / 512 },
  horizontalCap = 8,
  textureWidth = 512,
}

local STATS_PAPER = {
  path = MEDIA .. "CharacterStatsPaperV3",
  -- Center the 230 UI stats group inside the visual model opening at x=69..312.
  x = 76,
  y = 291,
  width = 230,
  -- BetterCharacterStats lays out six 13 UI rows from y=3 through y=81.
  -- Blizzard's original three-piece paper is therefore 85 UI units tall even
  -- though its owning frame is 78.  Stretch only the quiet middle of the
  -- accepted paper so the bottom row remains on paper.
  height = 85,
  texCoord = { 0, 460 / 512, 0, 156 / 256 },
  verticalCap = 6,
  textureHeight = 256,
  vertexColor = PARCHMENT_VERTEX_COLOR,
}

local SECONDARY_LEAF = {
  path = MEDIA .. "CharacterSecondaryLeafV3",
  x = 25,
  y = 66,
  width = 301,
  height = 382,
  texCoord = { 0, 602 / 1024, 0, 750 / 1024 },
  verticalCap = 8,
  textureHeight = 1024,
  vertexColor = PARCHMENT_VERTEX_COLOR,
}

local SECONDARY_PAGE_PROVIDER_NAMES = {
  "ReputationFrame",
  "SkillFrame",
  "HonorFrame",
  "PVPFrame",
  "ArenaFrame",
}

-- The accepted shell keeps the bottom weapon area transparent.  Reuse a
-- 233x72 crop from the accepted model background beneath that area so pfUI's
-- flat black backdrop cannot show between the stats paper and the shell's
-- lower inner edge.  The same three-part center stretch closes the shell's
-- 10 UI right-side opening gap without stretching either painted edge.
local EQUIPMENT_FOOTER_BACKGROUND = {
  path = MODEL_BACKGROUND.path,
  x = MODEL_BACKGROUND.x,
  y = 369,
  width = 243,
  -- The shell opening ends at y=444; the accepted crop previously stopped at
  -- y=441 and exposed a narrow strip of the provider backdrop.
  height = 75,
  texCoord = { 0, 466 / 512, 304 / 512, 448 / 512 },
  horizontalCap = MODEL_BACKGROUND.horizontalCap,
  textureWidth = MODEL_BACKGROUND.textureWidth,
}

local RESISTANCE_WELLS = {
  {
    path = MEDIA .. "CharacterResistanceWell1V3",
    width = 32,
    height = 29,
    texCoord = { 0, 1, 0, 58 / 64 },
  },
  {
    path = MEDIA .. "CharacterResistanceWell2V3",
    width = 32,
    height = 29,
    texCoord = { 0, 1, 0, 58 / 64 },
  },
  {
    path = MEDIA .. "CharacterResistanceWell3V3",
    width = 32,
    height = 29,
    texCoord = { 0, 1, 0, 58 / 64 },
  },
  {
    path = MEDIA .. "CharacterResistanceWell4V3",
    width = 32,
    height = 29,
    texCoord = { 0, 1, 0, 58 / 64 },
  },
  {
    path = MEDIA .. "CharacterResistanceWell5V3",
    width = 32,
    height = 29,
    texCoord = { 0, 1, 0, 58 / 64 },
  },
}

local SLOT_BASE = {
  path = MEDIA .. "CharacterSlotBaseAtlasV3",
  width = 37,
  height = 37,
  variants = {
    A = { 0, 74 / 256, 0, 74 / 256 },
    B = { 128 / 256, 202 / 256, 0, 74 / 256 },
    C = { 0, 74 / 256, 128 / 256, 202 / 256 },
    D = { 128 / 256, 202 / 256, 128 / 256, 202 / 256 },
  },
}

local SLOT_INTERACTION = {
  path = MEDIA .. "CharacterSlotInteractionAtlasV3",
  width = 37,
  height = 37,
  states = {
    highlight = {
      texCoord = { 0, 74 / 512, 0, 74 / 128 },
      alpha = 1,
    },
    pushed = {
      texCoord = { 128 / 512, 202 / 512, 0, 74 / 128 },
      alpha = 1,
    },
    disabled = {
      texCoord = { 256 / 512, 330 / 512, 0, 74 / 128 },
      alpha = 150 / 255,
    },
  },
}

local AMMO_SLOT = {
  path = MEDIA .. "CharacterAmmoSlotV3",
  width = 27,
  height = 27,
  states = {
    normal = {
      texCoord = { 0, 54 / 128, 0, 54 / 128 },
      alpha = 1,
    },
    highlight = {
      texCoord = { 64 / 128, 118 / 128, 0, 54 / 128 },
      alpha = 1,
    },
    pushed = {
      texCoord = { 0, 54 / 128, 64 / 128, 118 / 128 },
      alpha = 1,
    },
    disabled = {
      texCoord = { 64 / 128, 118 / 128, 64 / 128, 118 / 128 },
      alpha = 1,
    },
  },
}

local CHARACTER_TABS = {
  path = MEDIA .. "CharacterTabsV3",
  height = 28,
  leftWidth = 6,
  rightWidth = 6,
  minWidth = 64,
  textPadding = 32,
  rowInset = 2,
  gap = 3,
  fallbackRowWidth = 344,
  states = {
    normal = {
      left = { 8 / 128, 20 / 128, 4 / 256, 60 / 256 },
      center = { 32 / 128, 48 / 128, 4 / 256, 60 / 256 },
      right = { 60 / 128, 72 / 128, 4 / 256, 60 / 256 },
    },
    hover = {
      left = { 8 / 128, 20 / 128, 68 / 256, 124 / 256 },
      center = { 32 / 128, 48 / 128, 68 / 256, 124 / 256 },
      right = { 60 / 128, 72 / 128, 68 / 256, 124 / 256 },
    },
    pressed = {
      left = { 8 / 128, 20 / 128, 132 / 256, 188 / 256 },
      center = { 32 / 128, 48 / 128, 132 / 256, 188 / 256 },
      right = { 60 / 128, 72 / 128, 132 / 256, 188 / 256 },
    },
    selected = {
      left = { 8 / 128, 20 / 128, 196 / 256, 252 / 256 },
      center = { 32 / 128, 48 / 128, 196 / 256, 252 / 256 },
      right = { 60 / 128, 72 / 128, 196 / 256, 252 / 256 },
    },
  },
}

local CHARACTER_TAB_PAGE_PROVIDERS = {
  [1] = { "PaperDollFrame" },
  [2] = { "PetPaperDollFrame" },
  [3] = { "ReputationFrame" },
  [4] = { "SkillFrame" },
  [5] = { "HonorFrame", "PVPFrame", "ArenaFrame" },
}

local SLOT_VARIANTS = {
  -- Use the neutral rail segment consistently on both vertical columns.
  -- Mixing the four corner-detail variants from slot to slot makes a
  -- mathematically straight native column read as a jagged one in game.
  HeadSlot = "C",
  NeckSlot = "C",
  ShoulderSlot = "C",
  BackSlot = "C",
  ChestSlot = "C",
  ShirtSlot = "C",
  TabardSlot = "C",
  WristSlot = "C",
  HandsSlot = "C",
  WaistSlot = "C",
  LegsSlot = "C",
  FeetSlot = "C",
  Finger0Slot = "C",
  Finger1Slot = "C",
  Trinket0Slot = "C",
  Trinket1Slot = "C",
  MainHandSlot = "A",
  SecondaryHandSlot = "D",
  RangedSlot = "B",
}

-- Keep every registered provider on Blizzard's 1.12 PaperDoll geometry.  The
-- art below is authored for these exact logical rectangles; following a
-- provider after another skin/addon has shifted it makes the model, paper and
-- equipment rails disagree even though each individual texture is sized
-- correctly.
local LEFT_EQUIPMENT_SLOTS = {
  "HeadSlot",
  "NeckSlot",
  "ShoulderSlot",
  "BackSlot",
  "ChestSlot",
  "ShirtSlot",
  "TabardSlot",
  "WristSlot",
}

local RIGHT_EQUIPMENT_SLOTS = {
  "HandsSlot",
  "WaistSlot",
  "LegsSlot",
  "FeetSlot",
  "Finger0Slot",
  "Finger1Slot",
  "Trinket0Slot",
  "Trinket1Slot",
}

local BOTTOM_EQUIPMENT_SLOTS = {
  "MainHandSlot",
  "SecondaryHandSlot",
  "RangedSlot",
}

local CANONICAL_GEOMETRY_FRAME_NAMES = {
  "CharacterModelFrame",
  "CharacterAttributesFrame",
  "BetterCharacterAttributesFrame",
  "CharacterHeadSlot",
  "CharacterNeckSlot",
  "CharacterShoulderSlot",
  "CharacterBackSlot",
  "CharacterChestSlot",
  "CharacterShirtSlot",
  "CharacterTabardSlot",
  "CharacterWristSlot",
  "CharacterHandsSlot",
  "CharacterWaistSlot",
  "CharacterLegsSlot",
  "CharacterFeetSlot",
  "CharacterFinger0Slot",
  "CharacterFinger1Slot",
  "CharacterTrinket0Slot",
  "CharacterTrinket1Slot",
  "CharacterMainHandSlot",
  "CharacterSecondaryHandSlot",
  "CharacterRangedSlot",
  "CharacterAmmoSlot",
}

local PORTRAIT_CANDIDATES = {
  "CharacterFramePortrait",
  "CharacterFramePortraitIcon",
  "CharacterFramePortraitTexture",
}

local function ModuleEnabled()
  return
    addon.db and
    addon.db.character and
    addon.db.character.enabled and
    true or false
end

local function ScopedOwnershipActive()
  if
    not pfUI or
    type(pfUI.GetExpeditionComponentOwner) ~= "function"
  then
    return false
  end
  for _, route in ipairs(COMPONENT_ROUTES) do
    if pfUI:GetExpeditionComponentOwner(route) ~= "character" then
      return false
    end
  end
  return true
end

local function TabOwnershipActive()
  return
    pfUI and
    type(pfUI.GetExpeditionComponentOwner) == "function" and
    pfUI:GetExpeditionComponentOwner(TAB_COMPONENT_ROUTE) == "character" and
    true or false
end

local function AmmoOwnershipActive()
  return
    pfUI and
    type(pfUI.GetExpeditionComponentOwner) == "function" and
    pfUI:GetExpeditionComponentOwner(AMMO_COMPONENT_ROUTE) == "character" and
    true or false
end

local function SecondaryLeafOwnershipActive()
  return
    pfUI and
    type(pfUI.GetExpeditionComponentOwner) == "function" and
    pfUI:GetExpeditionComponentOwner(SECONDARY_LEAF_COMPONENT_ROUTE) ==
      "character" and
    true or false
end

local function FrameShown(frame)
  if not frame then return false end
  if type(frame.IsShown) == "function" then
    return frame:IsShown() and true or false
  end
  return true
end

local function ResolveStatsProvider()
  local betterStats = _G["BetterCharacterAttributesFrame"]
  if betterStats and FrameShown(betterStats) then
    return betterStats, "BetterCharacterAttributesFrame"
  end
  if CharacterAttributesFrame then
    return CharacterAttributesFrame, "CharacterAttributesFrame"
  end
  if betterStats then
    return betterStats, "BetterCharacterAttributesFrame"
  end
  return nil, "missing"
end

local function SetShown(frame, shown)
  if not frame then return end
  if shown and type(frame.Show) == "function" then
    frame:Show()
  elseif not shown and type(frame.Hide) == "function" then
    frame:Hide()
  end
end

local function CaptureFrameGeometry(frame)
  if not frame or frame.aeuiCharacterGeometryRestoreV3 then return end

  local restore = {
    width = frame.GetWidth and frame:GetWidth() or nil,
    height = frame.GetHeight and frame:GetHeight() or nil,
    points = {},
  }
  if frame.GetNumPoints and frame.GetPoint then
    for index = 1, frame:GetNumPoints() do
      local point, relativeTo, relativePoint, x, y = frame:GetPoint(index)
      table.insert(restore.points, {
        point = point,
        relativeTo = relativeTo,
        relativePoint = relativePoint,
        x = x,
        y = y,
      })
    end
  end
  frame.aeuiCharacterGeometryRestoreV3 = restore
end

local function SetCanonicalFrameGeometry(
  frame,
  width,
  height,
  point,
  relativeTo,
  relativePoint,
  x,
  y
)
  if not frame then return false end
  if frame.aeuiCharacterGeometryAppliedV3 then return true end

  CaptureFrameGeometry(frame)
  frame:ClearAllPoints()
  frame:SetWidth(width)
  frame:SetHeight(height)
  frame:SetPoint(point, relativeTo, relativePoint, x, y)
  frame.aeuiCharacterGeometryAppliedV3 = true
  return true
end

local function RestoreFrameGeometry(frame)
  if not frame then return end
  local restore = frame.aeuiCharacterGeometryRestoreV3
  if not restore then
    frame.aeuiCharacterGeometryAppliedV3 = nil
    return
  end

  frame:ClearAllPoints()
  if restore.width then frame:SetWidth(restore.width) end
  if restore.height then frame:SetHeight(restore.height) end
  for _, anchor in ipairs(restore.points) do
    frame:SetPoint(
      anchor.point,
      anchor.relativeTo,
      anchor.relativePoint,
      anchor.x,
      anchor.y
    )
  end
  frame.aeuiCharacterGeometryRestoreV3 = nil
  frame.aeuiCharacterGeometryAppliedV3 = nil
end

local function ApplyVerticalEquipmentRail(slotNames, x)
  local previous = nil
  for index, slotName in ipairs(slotNames) do
    local frame = _G["Character" .. slotName]
    if not frame then return false end

    if index == 1 then
      if not SetCanonicalFrameGeometry(
        frame,
        37,
        37,
        "TOPLEFT",
        PaperDollFrame,
        "TOPLEFT",
        x,
        -74
      ) then return false end
    else
      if not SetCanonicalFrameGeometry(
        frame,
        37,
        37,
        "TOPLEFT",
        previous,
        "BOTTOMLEFT",
        0,
        -4
      ) then return false end
    end
    previous = frame
  end
  return true
end

local function ApplyCanonicalPaperDollGeometry()
  if not PaperDollFrame then return false end

  if not SetCanonicalFrameGeometry(
    CharacterModelFrame,
    233,
    224,
    "TOPLEFT",
    PaperDollFrame,
    "TOPLEFT",
    65,
    -78
  ) then return false end

  if not SetCanonicalFrameGeometry(
    CharacterAttributesFrame,
    230,
    78,
    "TOPLEFT",
    PaperDollFrame,
    "TOPLEFT",
    STATS_PAPER.x,
    -STATS_PAPER.y
  ) then return false end

  local betterStats = _G["BetterCharacterAttributesFrame"]
  if betterStats then
    SetCanonicalFrameGeometry(
      betterStats,
      230,
      78,
      "TOPLEFT",
      PaperDollFrame,
      "TOPLEFT",
      STATS_PAPER.x,
      -STATS_PAPER.y
    )
  end

  if not ApplyVerticalEquipmentRail(LEFT_EQUIPMENT_SLOTS, 20) then
    return false
  end
  if not ApplyVerticalEquipmentRail(RIGHT_EQUIPMENT_SLOTS, 327) then
    return false
  end

  local mainHand = _G["Character" .. BOTTOM_EQUIPMENT_SLOTS[1]]
  local secondaryHand = _G["Character" .. BOTTOM_EQUIPMENT_SLOTS[2]]
  local ranged = _G["Character" .. BOTTOM_EQUIPMENT_SLOTS[3]]
  if not SetCanonicalFrameGeometry(
    mainHand,
    37,
    37,
    "TOPLEFT",
    PaperDollFrame,
    "BOTTOMLEFT",
    122,
    127
  ) then return false end
  if not SetCanonicalFrameGeometry(
    secondaryHand,
    37,
    37,
    "TOPLEFT",
    mainHand,
    "TOPRIGHT",
    5,
    0
  ) then return false end
  if not SetCanonicalFrameGeometry(
    ranged,
    37,
    37,
    "TOPLEFT",
    secondaryHand,
    "TOPRIGHT",
    5,
    0
  ) then return false end

  local ammo = _G["CharacterAmmoSlot"]
  if ammo then
    SetCanonicalFrameGeometry(
      ammo,
      AMMO_SLOT.width,
      AMMO_SLOT.height,
      "LEFT",
      ranged,
      "RIGHT",
      15,
      0
    )
  end
  return true
end

local function RestoreCanonicalPaperDollGeometry()
  for _, name in ipairs(CANONICAL_GEOMETRY_FRAME_NAMES) do
    RestoreFrameGeometry(_G[name])
  end
end

local function CaptureAndHidePortraits()
  if not CharacterFrame then return end
  CharacterFrame.aeuiCharacterPortraitRestore =
    CharacterFrame.aeuiCharacterPortraitRestore or {}
  local restore = CharacterFrame.aeuiCharacterPortraitRestore
  for _, name in ipairs(PORTRAIT_CANDIDATES) do
    local portrait = _G[name]
    if portrait then
      if restore[name] == nil then
        restore[name] = FrameShown(portrait)
      end
      portrait:Hide()
    end
  end
end

local function RestorePortraits()
  if not CharacterFrame then return end
  local restore = CharacterFrame.aeuiCharacterPortraitRestore
  if not restore then return end
  for name, shown in pairs(restore) do
    SetShown(_G[name], shown)
  end
  CharacterFrame.aeuiCharacterPortraitRestore = nil
end

local function ConfigureTexture(texture, definition, anchor)
  texture:ClearAllPoints()
  texture:SetTexture(definition.path)
  texture:SetWidth(definition.width)
  texture:SetHeight(definition.height)
  local texCoord = definition.texCoord or { 0, 1, 0, 1 }
  texture:SetTexCoord(
    texCoord[1],
    texCoord[2],
    texCoord[3],
    texCoord[4]
  )
  if definition.vertexColor then
    texture:SetVertexColor(unpack(definition.vertexColor))
  else
    texture:SetVertexColor(1, 1, 1)
  end
  texture:SetAlpha(1)
  local relativeTo = anchor and anchor.relativeTo or CharacterFrame
  local relativePoint = anchor and anchor.relativePoint or "TOPLEFT"
  local x = anchor and anchor.x or definition.x
  local y = anchor and anchor.y or -definition.y
  texture:SetPoint(
    "TOPLEFT",
    relativeTo,
    relativePoint,
    x,
    y
  )
  texture:Show()
end

local function ConfigureHorizontalTextureSlices(textures, definition, anchor)
  local cap = definition.horizontalCap
  local centerWidth = definition.width - cap * 2
  local capUV =
    cap * Character.texelDensity / definition.textureWidth
  local texCoord = definition.texCoord
  local u0, u1, v0, v1 =
    texCoord[1], texCoord[2], texCoord[3], texCoord[4]
  local parts = {
    {
      width = cap,
      x = 0,
      texCoord = { u0, u0 + capUV, v0, v1 },
    },
    {
      width = centerWidth,
      x = cap,
      texCoord = { u0 + capUV, u1 - capUV, v0, v1 },
    },
    {
      width = cap,
      x = definition.width - cap,
      texCoord = { u1 - capUV, u1, v0, v1 },
    },
  }

  for index, part in ipairs(parts) do
    ConfigureTexture(
      textures[index],
      {
        path = definition.path,
        width = part.width,
        height = definition.height,
        texCoord = part.texCoord,
      },
      {
        relativeTo = anchor.relativeTo,
        relativePoint = anchor.relativePoint,
        x = anchor.x + part.x,
        y = anchor.y,
      }
    )
  end
end

local function ConfigureVerticalTextureSlices(textures, definition, anchor)
  local cap = definition.verticalCap
  local centerHeight = definition.height - cap * 2
  local capUV =
    cap * Character.texelDensity / definition.textureHeight
  local texCoord = definition.texCoord
  local u0, u1, v0, v1 =
    texCoord[1], texCoord[2], texCoord[3], texCoord[4]
  local parts = {
    {
      height = cap,
      y = 0,
      texCoord = { u0, u1, v0, v0 + capUV },
    },
    {
      height = centerHeight,
      y = cap,
      texCoord = { u0, u1, v0 + capUV, v1 - capUV },
    },
    {
      height = cap,
      y = definition.height - cap,
      texCoord = { u0, u1, v1 - capUV, v1 },
    },
  }

  for index, part in ipairs(parts) do
    ConfigureTexture(
      textures[index],
      {
        path = definition.path,
        width = definition.width,
        height = part.height,
        texCoord = part.texCoord,
        vertexColor = definition.vertexColor,
      },
      {
        relativeTo = anchor.relativeTo,
        relativePoint = anchor.relativePoint,
        x = anchor.x,
        y = anchor.y - part.y,
      }
    )
  end
end

local function EnsureTextureSlices(owner, key, count)
  if not owner then return nil end
  if owner[key] then return owner[key] end

  local textures = {}
  for index = 1, count do
    textures[index] = owner:CreateTexture(nil, "BACKGROUND")
  end
  owner[key] = textures
  return textures
end

local function HideTextureSlices(textures)
  if not textures then return end
  for _, texture in ipairs(textures) do
    texture:Hide()
  end
end

local function ConfigureResistanceWell(texture, frame, definition)
  texture:ClearAllPoints()
  texture:SetTexture(definition.path)
  texture:SetWidth(definition.width)
  texture:SetHeight(definition.height)
  local texCoord = definition.texCoord
  texture:SetTexCoord(
    texCoord[1],
    texCoord[2],
    texCoord[3],
    texCoord[4]
  )
  texture:SetVertexColor(1, 1, 1)
  texture:SetAlpha(1)
  texture:SetPoint("CENTER", frame, "CENTER", 0, 0)
  texture:Show()
end

local function EnsureModelBackground()
  return EnsureTextureSlices(
    PaperDollFrame,
    "aeuiCharacterModelBackgroundV3",
    3
  )
end

local function EnsureStatsPaper()
  -- This is created after the accepted model background on the same draw
  -- layer so the paper naturally overlaps its lower edge by 11 UI pixels,
  -- while the original top and bottom paper edges remain unstretched.
  return EnsureTextureSlices(
    PaperDollFrame,
    "aeuiCharacterStatsPaperV3",
    3
  )
end

local function EnsureEquipmentFooterBackground()
  return EnsureTextureSlices(
    PaperDollFrame,
    "aeuiCharacterEquipmentFooterBackgroundV3",
    3
  )
end

local function EnsureSecondaryLeaf(frame)
  if not frame then return nil end
  local texture = frame.aeuiCharacterSecondaryLeafV3
  if not texture then
    -- A provider-owned BACKGROUND is above CharacterFrame's shell BORDER but
    -- below that provider's live labels, bars, buttons and scrollbars.  This
    -- prevents the shell's wide equipment rails from masking the left/right
    -- portions of the paper on Reputation, Skills, Honor, PvP and Arena.
    texture = frame:CreateTexture(nil, "BACKGROUND")
    frame.aeuiCharacterSecondaryLeafV3 = texture
  end
  texture:SetDrawLayer("BACKGROUND")
  return texture
end

local function IsCharacterSubframe(frame)
  local current = frame
  while current do
    if current == CharacterFrame then return true end
    if type(current.GetParent) ~= "function" then return false end
    current = current:GetParent()
  end
  return false
end

local function SecondaryPageShown()
  for _, name in ipairs(SECONDARY_PAGE_PROVIDER_NAMES) do
    local frame = _G[name]
    if frame then
      if type(frame.IsVisible) == "function" then
        if frame:IsVisible() then return true end
      elseif FrameShown(frame) then
        return true
      end
    end
  end
  return false
end

local function ApplySecondaryLeaves()
  local shared =
    CharacterFrame and CharacterFrame.aeuiCharacterSecondaryLeafV3
  if shared then shared:Hide() end

  local count = 0
  local applied = {}
  local seen = {}
  for _, name in ipairs(SECONDARY_PAGE_PROVIDER_NAMES) do
    local frame = _G[name]
    if frame and not seen[frame] and IsCharacterSubframe(frame) then
      seen[frame] = true
      local texture = EnsureSecondaryLeaf(frame)
      if texture then
        local slices = EnsureTextureSlices(frame, "aeuiCharacterSecondarySlices", 3)
        texture:Hide()
        frame.aeuiCharacterSecondaryLeafV3 = slices[1]
        ConfigureVerticalTextureSlices(slices, SECONDARY_LEAF, {
          relativeTo = frame,
          relativePoint = "TOPLEFT",
          x = SECONDARY_LEAF.x,
          y = -SECONDARY_LEAF.y,
        })
        count = count + 1
        table.insert(applied, name)
      end
    end
  end
  return count, table.concat(applied, "+")
end

local function GetSecondaryLeafRuntimeState()
  local total = 0
  local shown = 0
  local visible = 0
  local texturePath = "missing"
  local seen = {}
  for _, name in ipairs(SECONDARY_PAGE_PROVIDER_NAMES) do
    local frame = _G[name]
    if frame and not seen[frame] then
      seen[frame] = true
      local texture = frame.aeuiCharacterSecondaryLeafV3
      if texture then
        total = total + 1
        if texture.IsShown and texture:IsShown() then shown = shown + 1 end
        if texture.IsVisible and texture:IsVisible() then
          visible = visible + 1
        end
        if texture.GetTexture then
          texturePath = texture:GetTexture() or texturePath
        end
      end
    end
  end
  return total, shown, visible, texturePath
end

local function FindResistanceIcon(frame)
  if not frame or not frame.GetRegions then return nil end
  for _, region in ipairs({ frame:GetRegions() }) do
    if
      region and
      region.GetObjectType and
      region:GetObjectType() == "Texture" and
      region.GetTexture
    then
      local path = region:GetTexture()
      if type(path) == "string" and string.find(path, "ResistanceIcons") then
        return region
      end
    end
  end
  return nil
end

local function CaptureAndHideResistanceProvider(frame)
  if not frame then return false end
  if not frame.aeuiCharacterResistanceRestoreV3 then
    local icon = FindResistanceIcon(frame)
    frame.aeuiCharacterResistanceRestoreV3 = {
      backdropShown = FrameShown(frame.backdrop),
      backdropBorderShown = FrameShown(frame.backdrop_border),
      icon = icon,
      iconLayer = icon and icon.GetDrawLayer and icon:GetDrawLayer() or nil,
    }
  end

  local restore = frame.aeuiCharacterResistanceRestoreV3
  if frame.backdrop then frame.backdrop:Hide() end
  if frame.backdrop_border then frame.backdrop_border:Hide() end
  if restore.icon and restore.icon.SetDrawLayer then
    restore.icon:SetDrawLayer("ARTWORK")
  end
  return restore.icon and true or false
end

local function RestoreResistanceProvider(frame)
  if not frame then return end
  local restore = frame.aeuiCharacterResistanceRestoreV3
  if not restore then return end
  SetShown(frame.backdrop, restore.backdropShown)
  SetShown(frame.backdrop_border, restore.backdropBorderShown)
  if restore.icon and restore.icon.SetDrawLayer and restore.iconLayer then
    restore.icon:SetDrawLayer(restore.iconLayer)
  end
  frame.aeuiCharacterResistanceRestoreV3 = nil
end

local function EnsureResistanceWells()
  local wells = {}
  for index = 1, 5 do
    local frame = _G["MagicResFrame" .. index]
    if not frame then return nil end
    if not frame.aeuiCharacterResistanceWellV3 then
      frame.aeuiCharacterResistanceWellV3 =
        frame:CreateTexture(nil, "BACKGROUND")
    end
    wells[index] = frame.aeuiCharacterResistanceWellV3
  end
  return wells
end

local function EnsureSlotBase(frame)
  if frame.aeuiCharacterSlotBaseV3 then
    return frame.aeuiCharacterSlotBaseV3
  end
  local texture = frame:CreateTexture(nil, "ARTWORK")
  frame.aeuiCharacterSlotBaseV3 = texture
  return texture
end

local function CaptureAndHideSlotProvider(frame)
  if not frame.aeuiCharacterSlotRestoreV3 then
    frame.aeuiCharacterSlotRestoreV3 = {
      backdropShown = FrameShown(frame.backdrop),
      backdropBorderShown = FrameShown(frame.backdrop_border),
    }
  end
  if frame.backdrop then frame.backdrop:Hide() end
  if frame.backdrop_border then frame.backdrop_border:Hide() end
end

local function RestoreSlotProvider(frame)
  if not frame then return end
  local texture = frame.aeuiCharacterSlotBaseV3
  if texture then texture:Hide() end
  local restore = frame.aeuiCharacterSlotRestoreV3
  if not restore then return end
  SetShown(frame.backdrop, restore.backdropShown)
  SetShown(frame.backdrop_border, restore.backdropBorderShown)
  frame.aeuiCharacterSlotRestoreV3 = nil
end

local function ConfigureSlotBase(texture, frame, variant)
  local texCoord = SLOT_BASE.variants[variant]
  texture:ClearAllPoints()
  texture:SetTexture(SLOT_BASE.path)
  texture:SetWidth(SLOT_BASE.width)
  texture:SetHeight(SLOT_BASE.height)
  texture:SetTexCoord(
    texCoord[1],
    texCoord[2],
    texCoord[3],
    texCoord[4]
  )
  texture:SetVertexColor(1, 1, 1)
  texture:SetAlpha(1)
  -- Use the native button origin rather than CENTER so odd-sized 37 px
  -- textures cannot acquire half-pixel drift at non-1.0 UI scales.
  texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  texture:Show()
end

local function CaptureTextureState(texture)
  if not texture then
    return { exists = false }
  end

  local state = {
    exists = true,
    path = texture.GetTexture and texture:GetTexture() or nil,
    width = texture.GetWidth and texture:GetWidth() or nil,
    height = texture.GetHeight and texture:GetHeight() or nil,
    alpha = texture.GetAlpha and texture:GetAlpha() or 1,
    texCoord = texture.GetTexCoord and { texture:GetTexCoord() } or nil,
    blendMode = texture.GetBlendMode and texture:GetBlendMode() or nil,
    drawLayer = texture.GetDrawLayer and texture:GetDrawLayer() or nil,
  }
  if texture.GetVertexColor then
    state.vertexColor = { texture:GetVertexColor() }
  end
  if texture.GetNumPoints and texture.GetPoint then
    state.points = {}
    for index = 1, texture:GetNumPoints() do
      local point, relativeTo, relativePoint, x, y =
        texture:GetPoint(index)
      state.points[index] = {
        point = point,
        relativeTo = relativeTo,
        relativePoint = relativePoint,
        x = x,
        y = y,
      }
    end
  end
  return state
end

local function RestoreTextureState(frame, setterName, getterName, state)
  local setter = frame and frame[setterName]
  local getter = frame and frame[getterName]
  if not setter or not getter or not state then return end

  setter(frame, state.exists and state.path or nil)
  local texture = getter(frame)
  if not texture or not state.exists then return end
  if state.width and texture.SetWidth then
    texture:SetWidth(state.width)
  end
  if state.height and texture.SetHeight then
    texture:SetHeight(state.height)
  end
  if state.points and texture.ClearAllPoints and texture.SetPoint then
    texture:ClearAllPoints()
    for _, point in ipairs(state.points) do
      texture:SetPoint(
        point.point,
        point.relativeTo,
        point.relativePoint,
        point.x,
        point.y
      )
    end
  end
  if state.texCoord and texture.SetTexCoord then
    texture:SetTexCoord(unpack(state.texCoord))
  end
  if state.vertexColor and texture.SetVertexColor then
    texture:SetVertexColor(unpack(state.vertexColor))
  end
  if state.alpha and texture.SetAlpha then
    texture:SetAlpha(state.alpha)
  end
  if state.blendMode and texture.SetBlendMode then
    texture:SetBlendMode(state.blendMode)
  end
  if state.drawLayer and texture.SetDrawLayer then
    texture:SetDrawLayer(state.drawLayer)
  end
end

local function CaptureSlotInteractionProvider(frame)
  if frame.aeuiCharacterSlotInteractionRestoreV3 then return end

  local scoreLayer = nil
  if frame.scoreText and frame.scoreText.GetDrawLayer then
    scoreLayer = frame.scoreText:GetDrawLayer()
  end
  frame.aeuiCharacterSlotInteractionRestoreV3 = {
    highlight = CaptureTextureState(frame:GetHighlightTexture()),
    pushed = CaptureTextureState(frame:GetPushedTexture()),
    disabled = CaptureTextureState(frame:GetDisabledTexture()),
    scoreLayer = scoreLayer,
  }
end

local function ConfigureSlotInteractionTexture(
  frame,
  setterName,
  getterName,
  definition,
  contract
)
  contract = contract or SLOT_INTERACTION
  frame[setterName](frame, contract.path)
  local texture = frame[getterName](frame)
  if not texture then return false end

  texture:SetTexCoord(
    definition.texCoord[1],
    definition.texCoord[2],
    definition.texCoord[3],
    definition.texCoord[4]
  )
  texture:SetVertexColor(1, 1, 1)
  texture:SetAlpha(definition.alpha)
  texture:ClearAllPoints()
  texture:SetWidth(contract.width)
  texture:SetHeight(contract.height)
  texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  if texture.SetBlendMode then
    texture:SetBlendMode("BLEND")
  end
  if texture.SetDrawLayer then
    texture:SetDrawLayer("OVERLAY")
  end
  return true
end

local function ConfigureSlotInteractions(frame)
  CaptureSlotInteractionProvider(frame)

  if not ConfigureSlotInteractionTexture(
    frame,
    "SetHighlightTexture",
    "GetHighlightTexture",
    SLOT_INTERACTION.states.highlight
  ) then return false end
  if not ConfigureSlotInteractionTexture(
    frame,
    "SetPushedTexture",
    "GetPushedTexture",
    SLOT_INTERACTION.states.pushed
  ) then return false end
  if not ConfigureSlotInteractionTexture(
    frame,
    "SetDisabledTexture",
    "GetDisabledTexture",
    SLOT_INTERACTION.states.disabled
  ) then return false end

  -- pfUI creates ShaguScore text after the native button-state textures.
  -- Keep that provider-owned dynamic text above the accepted edge overlays.
  if frame.scoreText and frame.scoreText.SetDrawLayer then
    frame.scoreText:SetDrawLayer("HIGHLIGHT")
  end
  return true
end

local function RestoreSlotInteractionProvider(frame)
  if not frame then return end
  local restore = frame.aeuiCharacterSlotInteractionRestoreV3
  if not restore then return end

  RestoreTextureState(
    frame,
    "SetHighlightTexture",
    "GetHighlightTexture",
    restore.highlight
  )
  RestoreTextureState(
    frame,
    "SetPushedTexture",
    "GetPushedTexture",
    restore.pushed
  )
  RestoreTextureState(
    frame,
    "SetDisabledTexture",
    "GetDisabledTexture",
    restore.disabled
  )
  if
    restore.scoreLayer and
    frame.scoreText and
    frame.scoreText.SetDrawLayer
  then
    frame.scoreText:SetDrawLayer(restore.scoreLayer)
  end
  frame.aeuiCharacterSlotInteractionRestoreV3 = nil
end

local function ConfigureAmmoSlotBase(texture, frame)
  local definition = AMMO_SLOT.states.normal
  texture:ClearAllPoints()
  texture:SetTexture(AMMO_SLOT.path)
  texture:SetWidth(AMMO_SLOT.width)
  texture:SetHeight(AMMO_SLOT.height)
  texture:SetTexCoord(
    definition.texCoord[1],
    definition.texCoord[2],
    definition.texCoord[3],
    definition.texCoord[4]
  )
  texture:SetVertexColor(1, 1, 1)
  texture:SetAlpha(definition.alpha)
  texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  texture:Show()
end

local function ConfigureAmmoSlot()
  local frame = _G["CharacterAmmoSlot"]
  if
    not frame or
    not frame.backdrop or
    not frame.SetHighlightTexture or
    not frame.GetHighlightTexture or
    not frame.SetPushedTexture or
    not frame.GetPushedTexture or
    not frame.SetDisabledTexture or
    not frame.GetDisabledTexture
  then
    return false
  end

  CaptureAndHideSlotProvider(frame)
  ConfigureAmmoSlotBase(EnsureSlotBase(frame), frame)
  CaptureSlotInteractionProvider(frame)

  if not ConfigureSlotInteractionTexture(
    frame,
    "SetHighlightTexture",
    "GetHighlightTexture",
    AMMO_SLOT.states.highlight,
    AMMO_SLOT
  ) then return false end
  if not ConfigureSlotInteractionTexture(
    frame,
    "SetPushedTexture",
    "GetPushedTexture",
    AMMO_SLOT.states.pushed,
    AMMO_SLOT
  ) then return false end
  if not ConfigureSlotInteractionTexture(
    frame,
    "SetDisabledTexture",
    "GetDisabledTexture",
    AMMO_SLOT.states.disabled,
    AMMO_SLOT
  ) then return false end

  if frame.scoreText and frame.scoreText.SetDrawLayer then
    frame.scoreText:SetDrawLayer("HIGHLIGHT")
  end
  return true
end

local function RestoreAmmoSlot()
  local frame = _G["CharacterAmmoSlot"]
  RestoreSlotInteractionProvider(frame)
  RestoreSlotProvider(frame)
end

local function EnsureCharacterTabArt(frame)
  if frame.aeuiCharacterTabArtV3 then
    return frame.aeuiCharacterTabArtV3
  end

  local art = {
    left = frame:CreateTexture(nil, "BACKGROUND"),
    center = frame:CreateTexture(nil, "BACKGROUND"),
    right = frame:CreateTexture(nil, "BACKGROUND"),
  }
  frame.aeuiCharacterTabArtV3 = art
  return art
end

local function CaptureAndHideCharacterTabProvider(frame)
  if not frame.aeuiCharacterTabRestoreV3 then
    frame.aeuiCharacterTabRestoreV3 = {
      backdropShown = FrameShown(frame.backdrop),
      backdropBorderShown = FrameShown(frame.backdrop_border),
      width = frame.GetWidth and frame:GetWidth() or nil,
      height = frame.GetHeight and frame:GetHeight() or nil,
    }
  end
  if frame.backdrop then frame.backdrop:Hide() end
  if frame.backdrop_border then frame.backdrop_border:Hide() end
end

local function RestoreCharacterTabProvider(frame)
  if not frame then return end
  local art = frame.aeuiCharacterTabArtV3
  if art then
    for _, texture in pairs(art) do
      texture:Hide()
    end
  end
  local restore = frame.aeuiCharacterTabRestoreV3
  if not restore then return end
  if restore.width then frame:SetWidth(restore.width) end
  if restore.height then frame:SetHeight(restore.height) end
  SetShown(frame.backdrop, restore.backdropShown)
  SetShown(frame.backdrop_border, restore.backdropBorderShown)
  frame.aeuiCharacterTabRestoreV3 = nil
end

local function LayoutCharacterTabs()
  local frames = {}
  local naturalWidths = {}
  local naturalTotal = 0
  for index = 1, 5 do
    local frame = _G["CharacterFrameTab" .. index]
    if frame and FrameShown(frame) then
      local textWidth =
        frame.GetTextWidth and frame:GetTextWidth() or 0
      local naturalWidth = math.max(
        CHARACTER_TABS.minWidth,
        textWidth + CHARACTER_TABS.textPadding
      )
      table.insert(frames, frame)
      table.insert(naturalWidths, naturalWidth)
      naturalTotal = naturalTotal + naturalWidth
    end
  end

  local count = table.getn(frames)
  if count == 0 then return 0 end

  local rowWidth = CHARACTER_TABS.fallbackRowWidth
  if
    CharacterFrame and
    CharacterFrame.backdrop and
    CharacterFrame.backdrop.GetWidth
  then
    rowWidth = CharacterFrame.backdrop:GetWidth() or rowWidth
  end

  local rowInset = CHARACTER_TABS.rowInset
  if frames[1].GetPoint and CharacterFrame and CharacterFrame.backdrop then
    local _, relativeTo, _, x = frames[1]:GetPoint(1)
    if relativeTo == CharacterFrame.backdrop and x and x >= 0 then
      rowInset = x
    end
  end
  rowWidth = rowWidth - rowInset * 2

  local gap = CHARACTER_TABS.gap
  if count > 1 and frames[2].GetPoint then
    local _, relativeTo, _, x = frames[2]:GetPoint(1)
    if relativeTo == frames[1] and x and x >= 0 then
      gap = x
    end
  end

  local contentWidth =
    rowWidth - gap * (count - 1)
  local extraPerTab = 0
  if contentWidth > naturalTotal then
    extraPerTab = (contentWidth - naturalTotal) / count
  end

  for index, frame in ipairs(frames) do
    CaptureAndHideCharacterTabProvider(frame)
    frame:SetWidth(naturalWidths[index] + extraPerTab)
    frame:SetHeight(CHARACTER_TABS.height)
  end
  return count
end

local function ResolveSelectedCharacterTabID()
  -- The actually shown provider is authoritative.  Some Turtle/pfUI paths
  -- update page visibility and font colors without leaving Button:IsEnabled()
  -- in a reliable selected state.
  for index = 1, 5 do
    for _, providerName in ipairs(
      CHARACTER_TAB_PAGE_PROVIDERS[index]
    ) do
      if FrameShown(_G[providerName]) then
        return index, "visible-provider"
      end
    end
  end

  local selected =
    CharacterFrame and tonumber(CharacterFrame.selectedTab) or nil
  if selected then return selected, "character-selectedTab" end

  if
    CharacterFrame and
    type(PanelTemplates_GetSelectedTab) == "function"
  then
    local ok, value = pcall(PanelTemplates_GetSelectedTab, CharacterFrame)
    if ok and tonumber(value) then
      return tonumber(value), "paneltemplates-selectedTab"
    end
  end
  return nil, "button-enabled-fallback"
end

local function ResolveCharacterTabState(frame)
  if frame.aeuiCharacterTabMouseDownV3 then
    return "pressed"
  end

  local selectedID = ResolveSelectedCharacterTabID()
  if selectedID and frame.GetID and frame:GetID() == selectedID then
    return "selected"
  end

  if not selectedID and frame.IsEnabled then
    local enabled = frame:IsEnabled()
    if not enabled or enabled == 0 then
      return "selected"
    end
  end

  if frame.aeuiCharacterTabHoverV3 then
    return "hover"
  end
  return "normal"
end

local function GetCharacterTabRuntimeState()
  local selectedID, selectedSource = ResolveSelectedCharacterTabID()
  local visibleCount = 0
  local artCount = 0
  local backdropCount = 0
  for index = 1, 5 do
    local frame = _G["CharacterFrameTab" .. index]
    if frame and FrameShown(frame) then
      visibleCount = visibleCount + 1
      local art = frame.aeuiCharacterTabArtV3
      if
        art and
        FrameShown(art.left) and
        FrameShown(art.center) and
        FrameShown(art.right)
      then
        artCount = artCount + 1
      end
      if FrameShown(frame.backdrop) then
        backdropCount = backdropCount + 1
      end
    end
  end
  return
    selectedID or 0,
    selectedSource,
    visibleCount,
    artCount,
    backdropCount
end

local function ConfigureCharacterTabPart(
  texture,
  frame,
  texCoord,
  width,
  point,
  relativePoint,
  x
)
  texture:ClearAllPoints()
  texture:SetTexture(CHARACTER_TABS.path)
  texture:SetWidth(width)
  texture:SetHeight(CHARACTER_TABS.height)
  texture:SetTexCoord(
    texCoord[1],
    texCoord[2],
    texCoord[3],
    texCoord[4]
  )
  texture:SetVertexColor(1, 1, 1)
  texture:SetAlpha(1)
  texture:SetPoint(point, frame, relativePoint, x, 0)
  texture:Show()
end

local function ConfigureCharacterTab(frame)
  local art = EnsureCharacterTabArt(frame)
  local stateName = ResolveCharacterTabState(frame)
  local state = CHARACTER_TABS.states[stateName]
  local width = frame:GetWidth() or 0
  local centerWidth =
    width - CHARACTER_TABS.leftWidth - CHARACTER_TABS.rightWidth
  if centerWidth < 1 then centerWidth = 1 end

  ConfigureCharacterTabPart(
    art.left,
    frame,
    state.left,
    CHARACTER_TABS.leftWidth,
    "TOPLEFT",
    "TOPLEFT",
    0
  )
  ConfigureCharacterTabPart(
    art.center,
    frame,
    state.center,
    centerWidth,
    "TOPLEFT",
    "TOPLEFT",
    CHARACTER_TABS.leftWidth
  )
  ConfigureCharacterTabPart(
    art.right,
    frame,
    state.right,
    CHARACTER_TABS.rightWidth,
    "TOPRIGHT",
    "TOPRIGHT",
    0
  )
end

local function RefreshCharacterTab(frame)
  if
    not ModuleEnabled() or
    not ScopedOwnershipActive() or
    not TabOwnershipActive()
  then
    RestoreCharacterTabProvider(frame)
    return
  end
  CaptureAndHideCharacterTabProvider(frame)
  ConfigureCharacterTab(frame)
end

local function RefreshAllCharacterTabs()
  if
    ModuleEnabled() and
    ScopedOwnershipActive() and
    TabOwnershipActive()
  then
    LayoutCharacterTabs()
  end
  for index = 1, 5 do
    local frame = _G["CharacterFrameTab" .. index]
    if frame then RefreshCharacterTab(frame) end
  end
end

local function QueueCharacterTabRefresh()
  if
    not Character.tabHooksReady or
    not ModuleEnabled() or
    not ScopedOwnershipActive() or
    not TabOwnershipActive()
  then
    return
  end

  -- This is a two-frame, one-shot settle pass.  It runs only after a provider
  -- show/tab transition so late pfUI OnShow width/backdrop writes cannot win;
  -- it is not a geometry maintenance loop.
  Character.tabRefreshPasses = 2
  if not Character.tabRefreshFrame then
    local settleFrame = CreateFrame("Frame", nil, UIParent)
    settleFrame:Hide()
    settleFrame:SetScript("OnUpdate", function()
      if
        not Character.tabHooksReady or
        not ModuleEnabled() or
        not ScopedOwnershipActive() or
        not TabOwnershipActive()
      then
        Character.tabRefreshPasses = 0
        settleFrame:Hide()
        return
      end

      local passes = Character.tabRefreshPasses or 0
      if passes <= 0 then
        settleFrame:Hide()
        return
      end
      Character.tabRefreshPasses = passes - 1
      RefreshAllCharacterTabs()
      if Character.tabRefreshPasses <= 0 then
        settleFrame:Hide()
      end
    end)
    Character.tabRefreshFrame = settleFrame
  end
  Character.tabRefreshFrame:Show()
end

local function RefreshCharacterTabsAfterProviderTransition()
  if
    not Character.tabHooksReady or
    not ModuleEnabled() or
    not ScopedOwnershipActive() or
    not TabOwnershipActive()
  then
    return
  end

  RefreshAllCharacterTabs()
  QueueCharacterTabRefresh()
end

local function InstallCharacterTabScriptHook(
  frame,
  scriptName,
  callback
)
  local registry = frame.aeuiCharacterTabHooksV3
  if type(registry) ~= "table" then
    registry = {}
    frame.aeuiCharacterTabHooksV3 = registry
  end

  local current = frame:GetScript(scriptName)
  if registry[scriptName] and current == registry[scriptName] then
    return
  end

  -- pfUI SkinTab uses SetScript during its late skin pass.  Re-wrap whatever
  -- provider script is current instead of trusting a stale boolean sentinel.
  local previous = current
  local wrapper = function()
    if previous then previous() end
    callback()
  end
  registry[scriptName] = wrapper
  frame:SetScript(scriptName, wrapper)
end

local function InstallCharacterTabHooks(frame)
  InstallCharacterTabScriptHook(frame, "OnShow", function()
    RefreshAllCharacterTabs()
    QueueCharacterTabRefresh()
  end)

  InstallCharacterTabScriptHook(frame, "OnHide", function()
    frame.aeuiCharacterTabHoverV3 = nil
    frame.aeuiCharacterTabMouseDownV3 = nil
    RefreshAllCharacterTabs()
    QueueCharacterTabRefresh()
  end)

  InstallCharacterTabScriptHook(frame, "OnEnter", function()
    frame.aeuiCharacterTabHoverV3 = true
    RefreshCharacterTab(frame)
  end)

  InstallCharacterTabScriptHook(frame, "OnLeave", function()
    frame.aeuiCharacterTabHoverV3 = nil
    frame.aeuiCharacterTabMouseDownV3 = nil
    RefreshCharacterTab(frame)
  end)

  InstallCharacterTabScriptHook(frame, "OnMouseDown", function()
    frame.aeuiCharacterTabMouseDownV3 = true
    RefreshCharacterTab(frame)
  end)

  InstallCharacterTabScriptHook(frame, "OnMouseUp", function()
    frame.aeuiCharacterTabMouseDownV3 = nil
    RefreshCharacterTab(frame)
  end)

  InstallCharacterTabScriptHook(frame, "OnClick", function()
    frame.aeuiCharacterTabMouseDownV3 = nil
    RefreshAllCharacterTabs()
    QueueCharacterTabRefresh()
  end)

  -- Vanilla/Turtle 1.12 Buttons do not expose OnEnable or OnDisable script
  -- handlers.  Calling GetScript for either aborts the whole tab installation.
  -- Provider page visibility plus the click/subframe hooks above are the
  -- authoritative selected-state transitions on this client.
end

local function ApplyCharacterTabs()
  local frames = {}
  for index = 1, 5 do
    local frame = _G["CharacterFrameTab" .. index]
    if not frame or not frame.backdrop then
      return nil
    end
    table.insert(frames, frame)
  end
  for _, frame in ipairs(frames) do
    InstallCharacterTabHooks(frame)
  end
  Character.tabHooksReady = true
  RefreshAllCharacterTabs()
  QueueCharacterTabRefresh()
  return table.getn(frames)
end

local function HideCharacterTabs()
  Character.tabHooksReady = false
  Character.tabRefreshPasses = 0
  if Character.tabRefreshFrame then
    Character.tabRefreshFrame:Hide()
  end
  for index = 1, 5 do
    RestoreCharacterTabProvider(_G["CharacterFrameTab" .. index])
  end
end

local function ApplySlotBases()
  local frames = {}
  for slotName, variant in pairs(SLOT_VARIANTS) do
    local frame = _G["Character" .. slotName]
    if not frame or not frame.backdrop then
      return nil
    end
    table.insert(frames, {
      frame = frame,
      variant = variant,
    })
  end

  for _, entry in ipairs(frames) do
    CaptureAndHideSlotProvider(entry.frame)
    ConfigureSlotBase(
      EnsureSlotBase(entry.frame),
      entry.frame,
      entry.variant
    )
  end
  return table.getn(frames)
end

local function ApplySlotInteractions()
  local frames = {}
  for slotName in pairs(SLOT_VARIANTS) do
    local frame = _G["Character" .. slotName]
    if
      not frame or
      not frame.SetHighlightTexture or
      not frame.GetHighlightTexture or
      not frame.SetPushedTexture or
      not frame.GetPushedTexture or
      not frame.SetDisabledTexture or
      not frame.GetDisabledTexture
    then
      return nil
    end
    table.insert(frames, frame)
  end

  for _, frame in ipairs(frames) do
    if not ConfigureSlotInteractions(frame) then
      return nil
    end
  end
  return table.getn(frames)
end

local function EnsureArt()
  if not CharacterFrame then return nil end
  if CharacterFrame.aeuiCharacterShellV3 then
    return CharacterFrame.aeuiCharacterShellV3
  end

  local art = {
    topLeft = CharacterFrame:CreateTexture(nil, "BORDER"),
    topRight = CharacterFrame:CreateTexture(nil, "BORDER"),
    bottomLeft = CharacterFrame:CreateTexture(nil, "BORDER"),
    bottomRight = CharacterFrame:CreateTexture(nil, "BORDER"),
  }
  CharacterFrame.aeuiCharacterShellV3 = art
  return art
end

local function HideArt()
  local art = CharacterFrame and CharacterFrame.aeuiCharacterShellV3
  if not art then return end
  for _, texture in pairs(art) do
    texture:Hide()
  end
end

local function HideModelBackground()
  local textures =
    PaperDollFrame and PaperDollFrame.aeuiCharacterModelBackgroundV3
  HideTextureSlices(textures)
end

local function HideStatsPaper()
  local textures =
    PaperDollFrame and PaperDollFrame.aeuiCharacterStatsPaperV3
  HideTextureSlices(textures)
end

local function HideEquipmentFooterBackground()
  local textures =
    PaperDollFrame and
    PaperDollFrame.aeuiCharacterEquipmentFooterBackgroundV3
  HideTextureSlices(textures)
end

local function HideSecondaryLeaves()
  local shared =
    CharacterFrame and CharacterFrame.aeuiCharacterSecondaryLeafV3
  if shared then shared:Hide() end

  -- Provider visibility normally controls these automatically; explicitly
  -- hide them as well when the Character route is disabled or restored.
  for _, name in ipairs(SECONDARY_PAGE_PROVIDER_NAMES) do
    local frame = _G[name]
    local texture = frame and frame.aeuiCharacterSecondaryLeafV3
    if texture then texture:Hide() end
    if frame then HideTextureSlices(frame.aeuiCharacterSecondarySlices) end
  end
end

local function HideResistanceWells()
  for index = 1, 5 do
    local frame = _G["MagicResFrame" .. index]
    local texture = frame and frame.aeuiCharacterResistanceWellV3
    if texture then texture:Hide() end
    RestoreResistanceProvider(frame)
  end
end

local function HideSlotBases()
  for slotName in pairs(SLOT_VARIANTS) do
    RestoreSlotProvider(_G["Character" .. slotName])
  end
end


local function HideSlotInteractions()
  for slotName in pairs(SLOT_VARIANTS) do
    RestoreSlotInteractionProvider(_G["Character" .. slotName])
  end
end

-- Only these registered controls use the shared accepted leather/brass donor.
-- Provider frames, scripts, values and hit rectangles remain live.
local CONTROL_DROPDOWNS = {
  "PaperDollFrameTitlesDropdown", "PlayerTitleDropDown",
  "PlayerStatFrameLeftDropDown", "PlayerStatFrameRightDropDown",
}
local chromeFrames, controlTextures, controlLabels, controlBars = {}, {}, {}, {}
local scrollHeadings, reputationRows = {}, {}
local pvpBackdrops = {}
local arenaNativeBackdrops, arenaHoverHooks = {}, {}
local CONTROL_MEDIA = addon.media.root .. "GearPlanner\\"

local function ControlsEnabled()
  return ModuleEnabled() and ScopedOwnershipActive() and
    pfUI:GetExpeditionComponentOwner("character.controls") == "character"
end

local function RestoreChrome(frame)
  local saved = chromeFrames[frame]
  if not saved then return end
  saved.art:Hide()
  frame:SetBackdrop(saved.backdrop)
  frame:SetBackdropColor(unpack(saved.color))
  frame:SetBackdropBorderColor(unpack(saved.border))
  chromeFrames[frame] = nil
end

local function ControlChrome(frame, border, behind)
  if not frame or not frame.GetBackdrop then return end
  if not chromeFrames[frame] then
    local art = frame.aeuiCharacterControlArt
    if not art then
      art = CreateFrame("Frame", nil, frame)
      art:SetAllPoints(frame)
      art:SetFrameLevel(math.max(0, frame:GetFrameLevel() - (behind and 1 or 0)))
      art:EnableMouse(false)
      art:SetBackdrop({bgFile = CONTROL_MEDIA .. "GearPlannerLeatherFillV1",
        tile = true, tileSize = 64})
      art:SetBackdropColor(1, 1, 1, 1)
      local uv = {0, 0.125, 0.625, 0.75}
      local x, y = {0, border, -border, 0}, {0, -border, border, 0}
      for row = 1, 3 do
        for column = 1, 3 do
          if row ~= 2 or column ~= 2 then
            local texture = art:CreateTexture(nil, "BORDER")
            texture:SetTexture(CONTROL_MEDIA .. "GearPlannerFrameAtlasV1")
            texture:SetTexCoord(uv[column], uv[column+1], uv[row], uv[row+1])
            texture:SetPoint("TOPLEFT", art,
              (row <= 2 and "TOP" or "BOTTOM") .. (column <= 2 and "LEFT" or "RIGHT"),
              x[column], y[row])
            texture:SetPoint("BOTTOMRIGHT", art,
              (row < 2 and "TOP" or "BOTTOM") .. (column < 2 and "LEFT" or "RIGHT"),
              x[column+1], y[row+1])
          end
        end
      end
      frame.aeuiCharacterControlArt = art
    end
    chromeFrames[frame] = {art = art, backdrop = frame:GetBackdrop(),
      color = {frame:GetBackdropColor()}, border = {frame:GetBackdropBorderColor()}}
  end
  frame:SetBackdrop(nil)
  chromeFrames[frame].art:Show()
end

local function ControlTexture(texture, path, uv)
  if not texture then return end
  if not controlTextures[texture] then
    controlTextures[texture] = CaptureTextureState(texture)
  end
  texture:SetTexture(path)
  texture:SetTexCoord(unpack(uv or {0, 1, 0, 1}))
  texture:SetVertexColor(1, 1, 1, 1)
end

local function ControlButton(button)
  if not button then return end
  ControlChrome(button.backdrop or button, 3)
end

local function ControlLabel(label, anchor, point, x, width)
  if not label or not anchor then return end
  if not controlLabels[label] then
    CaptureFrameGeometry(label)
    controlLabels[label] = label:GetJustifyH()
  end
  label:ClearAllPoints()
  label:SetPoint(point, anchor, point, x, 0)
  label:SetWidth(width)
  label:SetJustifyH(point == "RIGHT" and "RIGHT" or "LEFT")
end

local function ControlBar(bar)
  if not bar then return end
  ControlChrome(bar.backdrop or bar, 2)
  -- Keep status colors and values supplied by reputation, skills and PvP.
  local texture = bar.GetStatusBarTexture and bar:GetStatusBarTexture()
  if texture then
    local path = type(texture) == "string" and texture or texture:GetTexture()
    if not path then return end
    if not controlBars[bar] then controlBars[bar] = path end
    local color = {bar:GetStatusBarColor()}
    bar:SetStatusBarTexture(addon.media.root .. "UnitFrames\\UnitFrameHealthFillV1")
    bar:SetStatusBarColor(unpack(color))
  end
end

local function RemovePvPBackdrop(frame)
  if not frame then return end
  -- The paper supplies these regions' background. Keep the real status bar,
  -- team frame, labels and mouse handlers; only remove pfUI's extra shell.
  for _, key in ipairs({"backdrop", "backdrop_border", "backdrop_shadow"}) do
    local backdrop = frame[key]
    if backdrop then
      if pvpBackdrops[backdrop] == nil then pvpBackdrops[backdrop] = backdrop:GetAlpha() end
      backdrop:SetAlpha(0)
    end
  end
end

local function ClearArenaHover(team)
  if not ControlsEnabled() then return end
  if not arenaNativeBackdrops[team] then
    arenaNativeBackdrops[team] = {backdrop = team:GetBackdrop(),
      color = {team:GetBackdropColor()}, border = {team:GetBackdropBorderColor()}}
  end
  team:SetBackdrop(nil)
  RemovePvPBackdrop(team)
  local highlight = team.GetHighlightTexture and team:GetHighlightTexture()
  if highlight then
    if not controlTextures[highlight] then controlTextures[highlight] = CaptureTextureState(highlight) end
    highlight:SetAlpha(0)
  end
  -- Turtle can draw hover art as an ordinary named region/child instead of
  -- Button:GetHighlightTexture(), and can show it again in OnEnter.
  for _, region in ipairs({team:GetRegions()}) do
    local name = region.GetName and region:GetName() or ""
    local path = region.GetTexture and region:GetTexture()
    if region.GetTexture and ((region.GetDrawLayer and region:GetDrawLayer() == "HIGHLIGHT") or
      string.find(string.lower(name), "highlight", 1, true) or
      (type(path) == "string" and string.find(string.lower(path), "highlight", 1, true))) then
      if not controlTextures[region] then controlTextures[region] = CaptureTextureState(region) end
      region:SetAlpha(0)
    end
  end
  for _, child in ipairs({team:GetChildren()}) do
    local name = child:GetName() or ""
    if string.find(string.lower(name), "highlight", 1, true) then
      if pvpBackdrops[child] == nil then pvpBackdrops[child] = child:GetAlpha() end
      child:SetAlpha(0)
    end
  end
end

local function ControlHeader(header, page)
  if not header or not header.icon then return end
  ControlButton(header.icon)
  local x = 2
  if page and page:GetLeft() and header:GetLeft() then
    x = math.max(x, SECONDARY_LEAF.x + 8 - (header:GetLeft() - page:GetLeft()))
  end
  SetCanonicalFrameGeometry(header.icon, header.icon:GetWidth(), header.icon:GetHeight(),
    "LEFT", header, "LEFT", x, 0)
  local text = header.GetFontString and header:GetFontString()
  ControlLabel(text, header, "LEFT", x + 18, math.max(48, header:GetWidth() - x - 22))
end

local function ListAtTop(scroll)
  if not scroll then return true end
  local offset = type(FauxScrollFrame_GetOffset) == "function" and
    FauxScrollFrame_GetOffset(scroll) or scroll.offset
  return (offset or 0) == 0
end

local function ScrollHeading(object, scroll)
  if not object then return end
  if not scrollHeadings[object] then
    scrollHeadings[object] = {shown = FrameShown(object), scroll = scroll}
  end
  SetShown(object, ListAtTop(scroll) and scrollHeadings[object].shown)
end

local function SpaceReputationRow(frame)
  if not frame then return end
  if not reputationRows[frame] then
    CaptureFrameGeometry(frame)
    reputationRows[frame] = frame.aeuiCharacterGeometryRestoreV3
  end
  -- FauxScrollFrame reuses visible rows. Only the first page reserves space
  -- for its heading; later pages use the entire list area.
  local inset = ListAtTop(ReputationListScrollFrame) and 12 or 0
  frame:ClearAllPoints()
  for _, anchor in ipairs(reputationRows[frame].points) do
    -- Relative row chains inherit the inset from their root.
    local relative = anchor.relativeTo
    local name = type(relative) == "string" and relative or
      (relative and relative.GetName and relative:GetName())
    local chained = name and (string.find(name, "^ReputationBar%d+$") or
      string.find(name, "^ReputationHeader%d+$"))
    frame:SetPoint(anchor.point, relative, anchor.relativePoint, anchor.x,
      (anchor.y or 0) - (chained and 0 or inset))
  end
end

local function AlignSecondaryText(page, frame)
  if not page or not page:IsVisible() or not page:GetTop() then return end
  frame = frame or page
  for _, region in ipairs({frame:GetRegions()}) do
    if region.GetJustifyH and region:GetTop() and region:GetLeft() then
      local point = region:GetPoint(1)
      local y = page:GetTop() - region:GetTop()
      local heading = page == ReputationFrame and frame == page and y >= 40 and y < 76
      local value = (page == HonorFrame or page == PVPFrame) and point and
        string.find(point, "RIGHT", 1, true) and y >= SECONDARY_LEAF.y and
        y < SECONDARY_LEAF.y + SECONDARY_LEAF.height
      if heading or value then
        if not controlLabels[region] then
          CaptureFrameGeometry(region)
          controlLabels[region] = region:GetJustifyH()
        end
        local x = region:GetLeft() - page:GetLeft()
        region:ClearAllPoints()
        if heading then
          region:SetPoint("TOPLEFT", page, "TOPLEFT", math.max(SECONDARY_LEAF.x + 10, x), -76)
          ScrollHeading(region, ReputationListScrollFrame)
        else
          region:SetPoint("TOPRIGHT", page, "TOPLEFT", SECONDARY_LEAF.x + SECONDARY_LEAF.width - 14, -y)
          region:SetJustifyH("RIGHT")
        end
      end
    end
  end
  -- Honor values can live in section Frames, with left-justified text but
  -- RIGHT anchors. Inspect those real sections too, excluding tab Buttons.
  for _, child in ipairs({frame:GetChildren()}) do
    if child:GetObjectType() == "Frame" then AlignSecondaryText(page, child) end
  end
end

local function ControlScrollbar(bar)
  if not bar then return end
  if bar.bg then ControlChrome(bar.bg.backdrop or bar.bg, 2) end
  local name = bar:GetName()
  ControlButton(_G[name .. "ScrollUpButton"])
  ControlButton(_G[name .. "ScrollDownButton"])
  ControlTexture(bar.thumb or bar:GetThumbTexture(),
    CONTROL_MEDIA .. "GearPlannerControlsAtlasV1", {50/1024, 88/1024, 5/128, 34/128})
end

function Character:RefreshCompanionArt()
  local active = ControlsEnabled() and CharacterFrame and CharacterFrame:IsVisible()
    and PaperDollFrame and PaperDollFrame:IsVisible()
  for _, name in ipairs({"StatCompareSelfFrame", "S_ItemTip_InspectFrame"}) do
    local frame = _G[name]
    if frame then
      if active then
        ControlChrome(frame, 6, true)
        ControlChrome(frame.levelBg, 3)
      else
        RestoreChrome(frame)
        if frame.levelBg then RestoreChrome(frame.levelBg) end
      end
      for _, row in ipairs(frame.slotFrames or {}) do
        if row.labelBg then
          if active then ControlChrome(row.labelBg, 2) else RestoreChrome(row.labelBg) end
        end
      end
    end
  end
end

function Character:RefreshControls()
  if not ControlsEnabled() then return end
  for _, name in ipairs(CONTROL_DROPDOWNS) do
    local dropdown = _G[name]
    if dropdown and dropdown.backdrop then
      ControlChrome(dropdown.backdrop, 3)
      ControlButton(_G[name .. "Button"])
      local text = _G[name .. "Text"]
      ControlLabel(text, dropdown.backdrop, "LEFT", 8,
        math.max(10, dropdown.backdrop:GetWidth() - 34))
    end
  end
  for _, name in ipairs({"CharacterFrameCloseButton", "StatCompareSelfFrameCloseButton",
    "SkillDetailStatusBarUnlearnButton", "ReputationDetailCloseButton"}) do
    ControlButton(_G[name])
  end
  for _, name in ipairs({"ReputationListScrollFrameScrollBar", "SkillListScrollFrameScrollBar"}) do
    ControlScrollbar(_G[name])
  end
  for i = 1, (NUM_FACTIONS_DISPLAYED or 15) do
    local bar, header = _G["ReputationBar" .. i], _G["ReputationHeader" .. i]
    SpaceReputationRow(bar)
    SpaceReputationRow(header)
    ControlBar(bar)
    ControlHeader(header, ReputationFrame)
    if bar then
      ControlLabel(_G["ReputationBar" .. i .. "FactionName"], bar, "LEFT", -112, 106)
      ControlLabel(_G["ReputationBar" .. i .. "Reputation"], bar, "RIGHT", -5,
        math.max(10, bar:GetWidth() - 10))
    end
  end
  local collapse = _G["SkillFrameCollapseAllButton"]
  if collapse and SkillFrame then
    SetCanonicalFrameGeometry(collapse, 70, 18, "TOPRIGHT", SkillFrame, "TOPLEFT",
      SECONDARY_LEAF.x + SECONDARY_LEAF.width - 10, -72)
  end
  ControlHeader(collapse, SkillFrame)
  ScrollHeading(collapse, SkillListScrollFrame)
  for i = 1, (SKILLS_TO_DISPLAY or 12) do
    local header, bar = _G["SkillTypeLabel" .. i], _G["SkillRankFrame" .. i]
    ControlHeader(header, SkillFrame)
    ControlBar(bar)
    if bar then
      ControlLabel(_G["SkillRankFrame" .. i .. "SkillName"], bar, "LEFT", 8,
        math.max(10, bar:GetWidth() - 86))
      ControlLabel(_G["SkillRankFrame" .. i .. "SkillRank"], bar, "RIGHT", -8, 72)
    end
  end
  for _, name in ipairs({"HonorFrameProgressBar", "ArenaFramePointsBar", "SkillDetailStatusBar"}) do
    ControlBar(_G[name])
  end
  RemovePvPBackdrop(HonorFrameProgressBar)
  RemovePvPBackdrop(ArenaFramePointsBar)
  for _, prefix in ipairs({"ArenaTeam", "ArenaFrameTeam"}) do
    for i = 1, 5 do
      local team = _G[prefix .. i]
      if team then
        ClearArenaHover(team)
        if not arenaHoverHooks[team] then
          local previous = team:GetScript("OnEnter")
          team:SetScript("OnEnter", function()
            if previous then previous() end
            ClearArenaHover(team)
          end)
          arenaHoverHooks[team] = true
        end
      end
    end
  end
  for _, prefix in ipairs({"HonorFrameTab", "ArenaFrameTab"}) do
    for i = 1, 2 do
      local button = _G[prefix .. i]
      if button and button.backdrop then
        ControlChrome(button.backdrop, 4)
        local art = chromeFrames[button.backdrop].art
        -- PanelTemplates disables the selected real Button.
        local tint = button:IsEnabled() == 0 and 1 or 0.65
        art:SetBackdropColor(tint, tint, tint, 1)
      end
    end
  end
  ControlChrome(ReputationDetailFrame and (ReputationDetailFrame.backdrop or ReputationDetailFrame), 6)
  for _, name in ipairs({"ReputationFrame", "HonorFrame", "PVPFrame"}) do
    AlignSecondaryText(_G[name])
  end
  for object, saved in pairs(scrollHeadings) do
    SetShown(object, ListAtTop(saved.scroll) and saved.shown)
  end
  self:RefreshCompanionArt()
end

local function RestoreControls()
  for team, saved in pairs(arenaNativeBackdrops) do
    team:SetBackdrop(saved.backdrop)
    team:SetBackdropColor(unpack(saved.color))
    team:SetBackdropBorderColor(unpack(saved.border))
  end
  arenaNativeBackdrops = {}
  for backdrop, alpha in pairs(pvpBackdrops) do backdrop:SetAlpha(alpha) end
  pvpBackdrops = {}
  for object, saved in pairs(scrollHeadings) do SetShown(object, saved.shown) end
  for frame in pairs(reputationRows) do RestoreFrameGeometry(frame) end
  scrollHeadings, reputationRows = {}, {}
  for frame in pairs(chromeFrames) do RestoreChrome(frame) end
  for texture, saved in pairs(controlTextures) do
    texture:SetTexture(saved.path)
    if saved.texCoord then texture:SetTexCoord(unpack(saved.texCoord)) end
    if saved.vertexColor then texture:SetVertexColor(unpack(saved.vertexColor)) end
    if saved.blendMode then texture:SetBlendMode(saved.blendMode) end
    if saved.alpha then texture:SetAlpha(saved.alpha) end
  end
  for bar, path in pairs(controlBars) do bar:SetStatusBarTexture(path) end
  for label, justify in pairs(controlLabels) do
    RestoreFrameGeometry(label)
    label:SetJustifyH(justify)
  end
  for _, prefix in ipairs({"ReputationHeader", "SkillTypeLabel"}) do
    for i = 1, math.max(NUM_FACTIONS_DISPLAYED or 15, SKILLS_TO_DISPLAY or 12) do
      local header = _G[prefix .. i]
      if header then RestoreFrameGeometry(header.icon) end
    end
  end
  if SkillFrameCollapseAllButton then
    RestoreFrameGeometry(SkillFrameCollapseAllButton.icon)
    RestoreFrameGeometry(SkillFrameCollapseAllButton)
  end
  controlTextures, controlLabels, controlBars = {}, {}, {}
end

function Character:InstallControlHooks()
  if not self.controlHooks then self.controlHooks = {} end
  if type(hooksecurefunc) ~= "function" then return end
  for _, name in ipairs({"ReputationFrame_Update", "SkillFrame_Update", "SkillFrame_UpdateSkills",
    "HonorFrame_Update", "ArenaFrame_Update", "SCShowFrame", "S_ItemTip_UpdateFrame",
    "CharacterFrame_ShowSubFrame", "PanelTemplates_SetTab"}) do
    if type(_G[name]) == "function" and not self.controlHooks[name] then
      hooksecurefunc(name, function() Character:RefreshControls() end)
      self.controlHooks[name] = true
    end
  end
  -- Run after the actual scroll handler, including its provider Show() calls.
  -- Not every Turtle skill update goes through SkillFrame_Update.
  for _, name in ipairs({"ReputationListScrollFrame", "SkillListScrollFrame"}) do
    for _, spec in ipairs({{name, "OnVerticalScroll"}, {name .. "ScrollBar", "OnValueChanged"}}) do
      local frame, script = _G[spec[1]], spec[2]
      local key = spec[1] .. ":" .. script
      if frame and not self.controlHooks[key] then
        local previous = frame:GetScript(script)
        frame:SetScript(script, function()
          if previous then previous() end
          Character:RefreshControls()
        end)
        self.controlHooks[key] = true
      end
    end
  end
  if not self.controlHooks.dropdown and type(ToggleDropDownMenu) == "function" then
    hooksecurefunc("ToggleDropDownMenu", function(level, value, dropdown)
      local owner = dropdown or UIDROPDOWNMENU_OPEN_MENU
      local owned = false
      for _, name in ipairs(CONTROL_DROPDOWNS) do
        if owner == name or (_G[name] and owner == _G[name]) then owned = true end
      end
      for i = 1, (UIDROPDOWNMENU_MAXLEVELS or 2) do
        for _, suffix in ipairs({"Backdrop", "MenuBackdrop"}) do
          local frame = _G["DropDownList" .. i .. suffix]
          if frame then
            local target = frame.backdrop or frame
            if owned and ControlsEnabled() then ControlChrome(target, 4)
            else RestoreChrome(target) end
          end
        end
      end
    end)
    self.controlHooks.dropdown = true
  end
  if PaperDollFrame and not self.controlController then
    local controller = CreateFrame("Frame", nil, PaperDollFrame)
    controller:SetScript("OnShow", function() Character:RefreshControls() end)
    controller:SetScript("OnHide", function() Character:RefreshCompanionArt() end)
    controller:RegisterEvent("ADDON_LOADED")
    controller:SetScript("OnEvent", function()
      Character:InstallControlHooks()
      if ControlsEnabled() then addon:ScheduleRefresh(0) end
    end)
    self.controlController = controller
  end
end

function Character:Restore()
  RestoreControls()
  if CharacterFrame then
    HideArt()
    HideModelBackground()
    HideStatsPaper()
    HideEquipmentFooterBackground()
    HideSecondaryLeaves()
    HideResistanceWells()
    HideSlotInteractions()
    HideSlotBases()
    RestoreAmmoSlot()
    HideCharacterTabs()
    RestorePortraits()
    RestoreCanonicalPaperDollGeometry()
    CharacterFrame.aeuiCharacterRuntimeContract = nil
  end
  self.statsProviderName = nil
  self.slotInteractionStatus = "inactive"
  self.slotInteractionError = nil
  self.tabStatus = "inactive"
  self.tabError = nil
  self.ammoStatus = "inactive"
  self.ammoError = nil
  self.secondaryLeafStatus = "inactive"
  self.status = "inactive"
  self.applyStage = "restored"
end

function Character:ApplyFrame()
  self.applyStage = "provider-checks"
  if
    not CharacterFrame or
    not PaperDollFrame or
    not CharacterModelFrame or
    not CharacterAttributesFrame or
    not CharacterResistanceFrame
  then
    self.status = "provider-missing"
    return false
  end

  local width = CharacterFrame:GetWidth()
  local height = CharacterFrame:GetHeight()
  if
    not width or
    not height or
    math.abs(width - 384) > 2 or
    math.abs(height - 512) > 2
  then
    self:Restore()
    self.status = "provider-geometry-unsupported"
    return false
  end

  -- Keep pfUI's inner backdrop for every region that is still provider-owned.
  -- The accepted model background only covers the native CharacterModelFrame
  -- rectangle and is parented to PaperDollFrame so it cannot leak into the
  -- Reputation, Skills, Honor or Arena pages.
  if not CharacterFrame.backdrop then
    self:Restore()
    self.status = "pfui-character-skin-missing"
    return false
  end

  self.applyStage = "canonical-paperdoll-geometry"
  if not ApplyCanonicalPaperDollGeometry() then
    self:Restore()
    self.applyStage = "canonical-paperdoll-geometry-failed"
    self.status = "paperdoll-provider-missing"
    return false
  end

  -- Secondary pages are independent of the paper-doll slot treatment.  Apply
  -- each provider's leaf before the equipment interaction pass so a provider-
  -- specific button API failure cannot leave every secondary page on pfUI's
  -- flat fallback backdrop.
  self.applyStage = "secondary-leaf"
  if SecondaryLeafOwnershipActive() then
    local leafCount, providerNames = ApplySecondaryLeaves()
    if leafCount > 0 then
      self.secondaryLeafStatus =
        tostring(leafCount) ..
        "-provider-background-leaves-applied/" .. providerNames
    else
      HideSecondaryLeaves()
      self.secondaryLeafStatus = "provider-missing-fallback"
    end
  else
    HideSecondaryLeaves()
    self.secondaryLeafStatus = "ownership-route-disabled"
  end

  self.applyStage = "shell-art"
  local art = EnsureArt()
  if not art then
    self:Restore()
    self.status = "art-missing"
    return false
  end

  for key, definition in pairs(ART) do
    ConfigureTexture(art[key], definition)
  end
  self.applyStage = "model-background"
  local modelBackground = EnsureModelBackground()
  if not modelBackground then
    self:Restore()
    self.status = "model-background-missing"
    return false
  end
  ConfigureHorizontalTextureSlices(modelBackground, MODEL_BACKGROUND, {
    relativeTo = PaperDollFrame,
    relativePoint = "TOPLEFT",
    x = MODEL_BACKGROUND.x,
    y = -MODEL_BACKGROUND.y,
  })

  self.applyStage = "stats-provider"
  local statsProvider, statsProviderName = ResolveStatsProvider()
  if not statsProvider then
    self:Restore()
    self.status = "stats-provider-missing"
    return false
  end
  self.statsProviderName = statsProviderName

  self.applyStage = "equipment-footer"
  local equipmentFooterBackground = EnsureEquipmentFooterBackground()
  if not equipmentFooterBackground then
    self:Restore()
    self.status = "equipment-footer-background-missing"
    return false
  end
  ConfigureHorizontalTextureSlices(
    equipmentFooterBackground,
    EQUIPMENT_FOOTER_BACKGROUND,
    {
      relativeTo = PaperDollFrame,
      relativePoint = "TOPLEFT",
      x = EQUIPMENT_FOOTER_BACKGROUND.x,
      y = -EQUIPMENT_FOOTER_BACKGROUND.y,
    }
  )

  self.applyStage = "stats-paper"
  local statsPaper = EnsureStatsPaper()
  if not statsPaper then
    self:Restore()
    self.status = "stats-paper-missing"
    return false
  end
  ConfigureVerticalTextureSlices(statsPaper, STATS_PAPER, {
    relativeTo = PaperDollFrame,
    relativePoint = "TOPLEFT",
    x = STATS_PAPER.x,
    y = -STATS_PAPER.y,
  })

  self.applyStage = "resistance-wells"
  local resistanceWells = EnsureResistanceWells()
  if not resistanceWells then
    self:Restore()
    self.status = "resistance-provider-missing"
    return false
  end
  for index, definition in ipairs(RESISTANCE_WELLS) do
    local frame = _G["MagicResFrame" .. index]
    if not CaptureAndHideResistanceProvider(frame) then
      self:Restore()
      self.status = "resistance-icon-missing"
      return false
    end
    ConfigureResistanceWell(resistanceWells[index], frame, definition)
  end

  self.applyStage = "slot-bases"
  local slotCount = ApplySlotBases()
  if slotCount ~= 19 then
    self:Restore()
    self.status = "equipment-slot-provider-missing"
    return false
  end
  self.applyStage = "slot-interactions"
  local interactionOK, slotInteractionCount = pcall(ApplySlotInteractions)
  if interactionOK and slotInteractionCount == 19 then
    self.slotInteractionStatus = "19-provider-states-applied"
    self.slotInteractionError = nil
  else
    pcall(HideSlotInteractions)
    self.slotInteractionStatus = "provider-state-fallback"
    self.slotInteractionError =
      interactionOK and "provider-missing" or tostring(slotInteractionCount)
  end
  self.applyStage = "character-tabs"
  if TabOwnershipActive() then
    local tabOK, tabCount = pcall(ApplyCharacterTabs)
    if tabOK and tabCount == 5 then
      self.tabStatus = "5-provider-tabs-applied"
      self.tabError = nil
    else
      pcall(HideCharacterTabs)
      self.tabStatus = "provider-missing-fallback"
      self.tabError = tabOK and "provider-missing" or tostring(tabCount)
    end
  else
    HideCharacterTabs()
    self.tabStatus = "ownership-route-disabled"
    self.tabError = nil
  end
  self.applyStage = "ammo-slot"
  if AmmoOwnershipActive() then
    local ammoOK, ammoApplied = pcall(ConfigureAmmoSlot)
    if ammoOK and ammoApplied then
      self.ammoStatus = "provider-ammo-applied"
      self.ammoError = nil
    else
      pcall(RestoreAmmoSlot)
      self.ammoStatus = "provider-missing-fallback"
      self.ammoError =
        ammoOK and "provider-missing" or tostring(ammoApplied)
    end
  else
    RestoreAmmoSlot()
    self.ammoStatus = "ownership-route-disabled"
    self.ammoError = nil
  end
  self.applyStage = "portraits"
  CaptureAndHidePortraits()
  self:InstallControlHooks()
  self:RefreshControls()

  -- Finish after every provider-owned apply stage.  pfUI may have written its
  -- tab width/backdrop during the same show transition, so the character tabs
  -- must be the final owner to converge before the finite settle pass runs.
  if
    self.tabHooksReady and
    self.tabStatus == "5-provider-tabs-applied"
  then
    RefreshCharacterTabsAfterProviderTransition()
  end

  CharacterFrame.aeuiCharacterRuntimeContract = self.runtimeContract
  self.status =
    "char-v3-canonical-geometry-and-provider-layers-applied"
  self.applyStage = "complete"
  return true
end

function Character:InstallHooks()
  if not CharacterFrame then return end

  local currentOnShow = CharacterFrame:GetScript("OnShow")
  if currentOnShow ~= self.characterFrameOnShowHookV3 then
    local previousOnShow = currentOnShow
    local wrapper = function()
      if previousOnShow then previousOnShow() end
      if ModuleEnabled() then
        addon:ScheduleRefresh(0)
        RefreshCharacterTabsAfterProviderTransition()
      end
    end
    self.characterFrameOnShowHookV3 = wrapper
    CharacterFrame:SetScript("OnShow", wrapper)
  end

  if
    not self.tabShowSubFrameHooked and
    type(CharacterFrame_ShowSubFrame) == "function" and
    type(hooksecurefunc) == "function"
  then
    hooksecurefunc("CharacterFrame_ShowSubFrame", function()
      RefreshCharacterTabsAfterProviderTransition()
    end)
    self.tabShowSubFrameHooked = true
  end

  if
    not self.tabPanelSetHooked and
    type(PanelTemplates_SetTab) == "function" and
    type(hooksecurefunc) == "function"
  then
    hooksecurefunc("PanelTemplates_SetTab", function(panel)
      if panel == CharacterFrame then
        RefreshCharacterTabsAfterProviderTransition()
      end
    end)
    self.tabPanelSetHooked = true
  end
end

function Character:GetRuntimeStatus()
  local applyFailure =
    addon.moduleFailures and addon.moduleFailures["Character:Apply"]
  local leafTotal, leafShown, leafVisible, leafTexture =
    GetSecondaryLeafRuntimeState()
  local
    tabSelectedID,
    tabSelectedSource,
    tabVisibleCount,
    tabArtCount,
    tabBackdropCount = GetCharacterTabRuntimeState()
  return
    "apply-stage=" .. tostring(self.applyStage or "unknown") ..
    ", apply-error=" .. tostring(applyFailure or "none") ..
    ", shell=" .. tostring(self.status or "unapplied") ..
    ", provider-geometry=384x512/canonical-paperdoll" ..
    ", model-background=243x227@69,75/3-slice/provider=233x224@65,78" ..
    ", equipment-footer-background=243x75@69,369/3-slice-native-crop" ..
    ", stats-paper=230x85@76,291/3-slice/provider=" ..
    tostring(self.statsProviderName or "unresolved") ..
    "/frame=230x78" ..
    ", resistance-wells=5x32x29/provider-anchored" ..
    ", equipment-rails=37x37@left20/right327" ..
    ", equipment-slot-base=19x37x37/atlas-v3" ..
    ", equipment-slot-states=" ..
    tostring(self.slotInteractionStatus or "unresolved") ..
    "/error=" .. tostring(self.slotInteractionError or "none") ..
    ", character-tabs=" .. tostring(self.tabStatus or "unresolved") ..
    "/error=" .. tostring(self.tabError or "none") ..
    "/3-slice/28-ui-high/adaptive-visible-row/min64/text-padding32" ..
    "/selected=" .. tostring(tabSelectedID) ..
    "/selected-source=" .. tostring(tabSelectedSource) ..
    "/visible=" .. tostring(tabVisibleCount) ..
    "/art=" .. tostring(tabArtCount) ..
    "/pfui-backdrops=" .. tostring(tabBackdropCount) ..
    "/settle=" .. tostring(self.tabRefreshPasses or 0) ..
    ", ammo-slot=" .. tostring(self.ammoStatus or "unresolved") ..
    "/error=" .. tostring(self.ammoError or "none") ..
    "/27x27/21x21-safe/atlas-v3" ..
    ", secondary-leaf=" ..
    tostring(self.secondaryLeafStatus or "unresolved") ..
    "/301x382/3-slice/2x/host=provider-background" ..
    "/page-visible=" .. tostring(SecondaryPageShown() and 1 or 0) ..
    "/leaf-total=" .. tostring(leafTotal) ..
    "/leaf-shown=" .. tostring(leafShown) ..
    "/leaf-visible=" .. tostring(leafVisible) ..
    "/leaf-texture=" .. tostring(leafTexture) ..
    ", provider-dynamic-content=live" ..
    ", texel-density=2x/provider-geometry-unchanged" ..
    ", top-left-portrait=hidden"
end

function Character:Initialize()
  self.statsProviderName = nil
  self.slotInteractionStatus = "unapplied"
  self.slotInteractionError = nil
  self.tabStatus = "unapplied"
  self.tabError = nil
  self.tabHooksReady = false
  self.tabRefreshPasses = 0
  self.ammoStatus = "unapplied"
  self.ammoError = nil
  self.secondaryLeafStatus = "unapplied"
  self.status = "unapplied"
  self.applyStage = "initialized"
end

function Character:Apply()
  self.applyStage = "apply-entered"
  self:InstallHooks()
  if not ModuleEnabled() then
    self:Restore()
    return
  end
  if not ScopedOwnershipActive() then
    self:Restore()
    self.status = "ownership-route-disabled"
    return
  end
  self:ApplyFrame()
end

addon:RegisterModule("Character", Character)
