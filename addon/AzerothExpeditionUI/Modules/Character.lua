local addon = AzerothExpeditionUI
local Character = {}

Character.runtimeContract = "2.0"
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
}

local SECONDARY_LEAF = {
  path = MEDIA .. "CharacterSecondaryLeafV3",
  x = 25,
  y = 66,
  width = 301,
  height = 375,
  texCoord = { 0, 602 / 1024, 0, 750 / 1024 },
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
  texture:SetVertexColor(1, 1, 1)
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
        ConfigureTexture(texture, SECONDARY_LEAF, {
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

function Character:Restore()
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
    "/301x375/2x/host=provider-background" ..
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
