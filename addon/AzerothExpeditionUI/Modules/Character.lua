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
  x = 65,
  y = 78,
  width = 233,
  height = 224,
  texCoord = { 0, 466 / 512, 0, 448 / 512 },
}

local STATS_PAPER = {
  path = MEDIA .. "CharacterStatsPaperV3",
  x = 67,
  y = 291,
  width = 230,
  height = 78,
  texCoord = { 0, 460 / 512, 0, 156 / 256 },
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

-- The accepted shell keeps the native bottom weapon area transparent.  Reuse
-- a native-size 233x72 crop from the accepted model background beneath that
-- area so pfUI's flat black backdrop cannot show between the stats paper and
-- the shell's lower inner edge.  No generated pixels are stretched or rebuilt.
local EQUIPMENT_FOOTER_BACKGROUND = {
  path = MODEL_BACKGROUND.path,
  x = 65,
  y = 369,
  width = 233,
  height = 72,
  texCoord = { 0, 466 / 512, 304 / 512, 448 / 512 },
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
  height = 20,
  leftWidth = 6,
  rightWidth = 6,
  states = {
    normal = {
      left = { 8 / 128, 20 / 128, 8 / 256, 48 / 256 },
      center = { 32 / 128, 48 / 128, 8 / 256, 48 / 256 },
      right = { 60 / 128, 72 / 128, 8 / 256, 48 / 256 },
    },
    hover = {
      left = { 8 / 128, 20 / 128, 64 / 256, 104 / 256 },
      center = { 32 / 128, 48 / 128, 64 / 256, 104 / 256 },
      right = { 60 / 128, 72 / 128, 64 / 256, 104 / 256 },
    },
    pressed = {
      left = { 8 / 128, 20 / 128, 120 / 256, 160 / 256 },
      center = { 32 / 128, 48 / 128, 120 / 256, 160 / 256 },
      right = { 60 / 128, 72 / 128, 120 / 256, 160 / 256 },
    },
    selected = {
      left = { 8 / 128, 20 / 128, 176 / 256, 216 / 256 },
      center = { 32 / 128, 48 / 128, 176 / 256, 216 / 256 },
      right = { 60 / 128, 72 / 128, 176 / 256, 216 / 256 },
    },
  },
}

local SLOT_VARIANTS = {
  HeadSlot = "A",
  ChestSlot = "A",
  FeetSlot = "A",
  Finger1Slot = "A",
  RangedSlot = "A",
  NeckSlot = "B",
  ShirtSlot = "B",
  HandsSlot = "B",
  Finger0Slot = "B",
  MainHandSlot = "B",
  ShoulderSlot = "C",
  TabardSlot = "C",
  WaistSlot = "C",
  Trinket1Slot = "C",
  BackSlot = "D",
  WristSlot = "D",
  LegsSlot = "D",
  Trinket0Slot = "D",
  SecondaryHandSlot = "D",
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
  if not PaperDollFrame then return nil end
  if PaperDollFrame.aeuiCharacterModelBackgroundV3 then
    return PaperDollFrame.aeuiCharacterModelBackgroundV3
  end

  local texture = PaperDollFrame:CreateTexture(nil, "BACKGROUND")
  PaperDollFrame.aeuiCharacterModelBackgroundV3 = texture
  return texture
end

local function EnsureStatsPaper()
  if not PaperDollFrame then return nil end
  if PaperDollFrame.aeuiCharacterStatsPaperV3 then
    return PaperDollFrame.aeuiCharacterStatsPaperV3
  end

  -- This is created after the accepted model background on the same draw
  -- layer so the paper naturally overlaps its lower edge by 11 UI pixels,
  -- while CharacterAttributesFrame text and controls remain above it.
  local texture = PaperDollFrame:CreateTexture(nil, "BACKGROUND")
  PaperDollFrame.aeuiCharacterStatsPaperV3 = texture
  return texture
end

local function EnsureEquipmentFooterBackground()
  if not PaperDollFrame then return nil end
  if PaperDollFrame.aeuiCharacterEquipmentFooterBackgroundV3 then
    return PaperDollFrame.aeuiCharacterEquipmentFooterBackgroundV3
  end

  local texture = PaperDollFrame:CreateTexture(nil, "BACKGROUND")
  PaperDollFrame.aeuiCharacterEquipmentFooterBackgroundV3 = texture
  return texture
end

local function EnsureSecondaryLeaf(frame)
  if not frame then return nil end
  if frame.aeuiCharacterSecondaryLeafV3 then
    return frame.aeuiCharacterSecondaryLeafV3
  end

  -- Each provider owns its own leaf so native page visibility controls it.
  -- BACKGROUND keeps live labels, bars, buttons and scrollbars above the art.
  local texture = frame:CreateTexture(nil, "BACKGROUND")
  frame.aeuiCharacterSecondaryLeafV3 = texture
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

local function ApplySecondaryLeaves()
  local count = 0
  local applied = {}
  for _, name in ipairs(SECONDARY_PAGE_PROVIDER_NAMES) do
    local frame = _G[name]
    if frame and IsCharacterSubframe(frame) then
      local texture = EnsureSecondaryLeaf(frame)
      if texture then
        ConfigureTexture(texture, SECONDARY_LEAF)
        count = count + 1
        table.insert(applied, name)
      end
    end
  end
  return count, table.concat(applied, "+")
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
  SetShown(frame.backdrop, restore.backdropShown)
  SetShown(frame.backdrop_border, restore.backdropBorderShown)
  frame.aeuiCharacterTabRestoreV3 = nil
end

local function ResolveCharacterTabState(frame)
  if frame.IsEnabled then
    local enabled = frame:IsEnabled()
    if not enabled or enabled == 0 then
      return "selected"
    end
  end
  if frame.aeuiCharacterTabMouseDownV3 then
    return "pressed"
  end
  if frame.aeuiCharacterTabHoverV3 then
    return "hover"
  end
  return "normal"
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
  for index = 1, 5 do
    local frame = _G["CharacterFrameTab" .. index]
    if frame then RefreshCharacterTab(frame) end
  end
end

local function InstallCharacterTabHooks(frame)
  if frame.aeuiCharacterTabHooksV3 then return end
  frame.aeuiCharacterTabHooksV3 = true

  local previousOnShow = frame:GetScript("OnShow")
  frame:SetScript("OnShow", function()
    if previousOnShow then previousOnShow() end
    RefreshCharacterTab(frame)
  end)

  local previousOnHide = frame:GetScript("OnHide")
  frame:SetScript("OnHide", function()
    if previousOnHide then previousOnHide() end
    frame.aeuiCharacterTabHoverV3 = nil
    frame.aeuiCharacterTabMouseDownV3 = nil
  end)

  local previousOnEnter = frame:GetScript("OnEnter")
  frame:SetScript("OnEnter", function()
    if previousOnEnter then previousOnEnter() end
    frame.aeuiCharacterTabHoverV3 = true
    RefreshCharacterTab(frame)
  end)

  local previousOnLeave = frame:GetScript("OnLeave")
  frame:SetScript("OnLeave", function()
    if previousOnLeave then previousOnLeave() end
    frame.aeuiCharacterTabHoverV3 = nil
    frame.aeuiCharacterTabMouseDownV3 = nil
    RefreshCharacterTab(frame)
  end)

  local previousOnMouseDown = frame:GetScript("OnMouseDown")
  frame:SetScript("OnMouseDown", function()
    if previousOnMouseDown then previousOnMouseDown() end
    frame.aeuiCharacterTabMouseDownV3 = true
    RefreshCharacterTab(frame)
  end)

  local previousOnMouseUp = frame:GetScript("OnMouseUp")
  frame:SetScript("OnMouseUp", function()
    if previousOnMouseUp then previousOnMouseUp() end
    frame.aeuiCharacterTabMouseDownV3 = nil
    RefreshCharacterTab(frame)
  end)

  local previousOnClick = frame:GetScript("OnClick")
  frame:SetScript("OnClick", function()
    if previousOnClick then previousOnClick() end
    frame.aeuiCharacterTabMouseDownV3 = nil
    RefreshAllCharacterTabs()
  end)

  local previousOnEnable = frame:GetScript("OnEnable")
  frame:SetScript("OnEnable", function()
    if previousOnEnable then previousOnEnable() end
    RefreshAllCharacterTabs()
  end)

  local previousOnDisable = frame:GetScript("OnDisable")
  frame:SetScript("OnDisable", function()
    if previousOnDisable then previousOnDisable() end
    RefreshAllCharacterTabs()
  end)
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
    RefreshCharacterTab(frame)
  end
  return table.getn(frames)
end

local function HideCharacterTabs()
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
  local texture =
    PaperDollFrame and PaperDollFrame.aeuiCharacterModelBackgroundV3
  if texture then texture:Hide() end
end

local function HideStatsPaper()
  local texture =
    PaperDollFrame and PaperDollFrame.aeuiCharacterStatsPaperV3
  if texture then texture:Hide() end
end

local function HideEquipmentFooterBackground()
  local texture =
    PaperDollFrame and
    PaperDollFrame.aeuiCharacterEquipmentFooterBackgroundV3
  if texture then texture:Hide() end
end

local function HideSecondaryLeaves()
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
    CharacterFrame.aeuiCharacterRuntimeContract = nil
  end
  self.statsProviderName = nil
  self.tabStatus = "inactive"
  self.ammoStatus = "inactive"
  self.secondaryLeafStatus = "inactive"
  self.status = "inactive"
end

function Character:ApplyFrame()
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

  local art = EnsureArt()
  if not art then
    self:Restore()
    self.status = "art-missing"
    return false
  end

  for key, definition in pairs(ART) do
    ConfigureTexture(art[key], definition)
  end
  local modelBackground = EnsureModelBackground()
  if not modelBackground then
    self:Restore()
    self.status = "model-background-missing"
    return false
  end
  ConfigureTexture(modelBackground, MODEL_BACKGROUND, {
    relativeTo = CharacterModelFrame,
    relativePoint = "TOPLEFT",
    x = 0,
    y = 0,
  })

  local statsProvider, statsProviderName = ResolveStatsProvider()
  if not statsProvider then
    self:Restore()
    self.status = "stats-provider-missing"
    return false
  end
  self.statsProviderName = statsProviderName

  local equipmentFooterBackground = EnsureEquipmentFooterBackground()
  if not equipmentFooterBackground then
    self:Restore()
    self.status = "equipment-footer-background-missing"
    return false
  end
  ConfigureTexture(
    equipmentFooterBackground,
    EQUIPMENT_FOOTER_BACKGROUND,
    {
      relativeTo = statsProvider,
      relativePoint = "BOTTOMLEFT",
      x = -2,
      y = 0,
    }
  )

  local statsPaper = EnsureStatsPaper()
  if not statsPaper then
    self:Restore()
    self.status = "stats-paper-missing"
    return false
  end
  ConfigureTexture(statsPaper, STATS_PAPER, {
    relativeTo = statsProvider,
    relativePoint = "TOPLEFT",
    x = 0,
    y = 0,
  })

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

  local slotCount = ApplySlotBases()
  if slotCount ~= 19 then
    self:Restore()
    self.status = "equipment-slot-provider-missing"
    return false
  end
  local slotInteractionCount = ApplySlotInteractions()
  if slotInteractionCount ~= 19 then
    self:Restore()
    self.status = "equipment-slot-state-provider-missing"
    return false
  end
  if TabOwnershipActive() then
    local tabCount = ApplyCharacterTabs()
    if tabCount == 5 then
      self.tabStatus = "5-provider-tabs-applied"
    else
      HideCharacterTabs()
      self.tabStatus = "provider-missing-fallback"
    end
  else
    HideCharacterTabs()
    self.tabStatus = "ownership-route-disabled"
  end
  if AmmoOwnershipActive() then
    if ConfigureAmmoSlot() then
      self.ammoStatus = "provider-ammo-applied"
    else
      RestoreAmmoSlot()
      self.ammoStatus = "provider-missing-fallback"
    end
  else
    RestoreAmmoSlot()
    self.ammoStatus = "ownership-route-disabled"
  end
  if SecondaryLeafOwnershipActive() then
    local leafCount, providerNames = ApplySecondaryLeaves()
    if leafCount > 0 then
      self.secondaryLeafStatus =
        tostring(leafCount) .. "-provider-leaves-applied/" .. providerNames
    else
      HideSecondaryLeaves()
      self.secondaryLeafStatus = "provider-missing-fallback"
    end
  else
    HideSecondaryLeaves()
    self.secondaryLeafStatus = "ownership-route-disabled"
  end
  CaptureAndHidePortraits()

  CharacterFrame.aeuiCharacterRuntimeContract = self.runtimeContract
  self.status =
    "char-v3-provider-aligned-layers-secondary-leaf-and-slot-states-applied"
  return true
end

function Character:InstallHooks()
  if not CharacterFrame or CharacterFrame.aeuiCharacterShowHooked then
    return
  end
  CharacterFrame.aeuiCharacterShowHooked = true
  local previous = CharacterFrame:GetScript("OnShow")
  CharacterFrame:SetScript("OnShow", function()
    if previous then previous() end
    if ModuleEnabled() then
      addon:ScheduleRefresh(0)
    end
  end)
end

function Character:GetRuntimeStatus()
  return
    "shell=" .. tostring(self.status or "unapplied") ..
    ", provider-geometry=384x512" ..
    ", model-background=233x224@65,78" ..
    ", equipment-footer-background=233x72@65,369/native-crop" ..
    ", stats-paper=230x78/provider=" ..
    tostring(self.statsProviderName or "unresolved") ..
    ", resistance-wells=5x32x29/provider-anchored" ..
    ", equipment-slot-base=19x37x37/atlas-v3" ..
    ", equipment-slot-states=19xhover/pressed/disabled/atlas-v3" ..
    ", character-tabs=" .. tostring(self.tabStatus or "unresolved") ..
    "/3-slice/20-ui-high/dynamic-width" ..
    ", ammo-slot=" .. tostring(self.ammoStatus or "unresolved") ..
    "/27x27/21x21-safe/atlas-v3" ..
    ", secondary-leaf=" ..
    tostring(self.secondaryLeafStatus or "unresolved") ..
    "/301x375/2x" ..
    ", provider-dynamic-content=live" ..
    ", texel-density=2x/logical-geometry-unchanged" ..
    ", top-left-portrait=hidden"
end

function Character:Initialize()
  self.statsProviderName = nil
  self.tabStatus = "unapplied"
  self.ammoStatus = "unapplied"
  self.secondaryLeafStatus = "unapplied"
  self.status = "unapplied"
end

function Character:Apply()
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
