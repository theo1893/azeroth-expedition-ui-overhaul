local addon = AzerothExpeditionUI
local Map = {}
Map.runtimeContract = "1.1"

local MEDIA = addon.media.root .. "Map\\"

local WORLD = {
  rodTop = MEDIA .. "MapWorldRodTopV1",
  rodBottom = MEDIA .. "MapWorldRodBottomV1",
  edgeLeft = MEDIA .. "MapWorldPaperEdgeLeftV1",
  edgeRight = MEDIA .. "MapWorldPaperEdgeRightV1",
  outsetLeft = 50,
  outsetRight = 50,
  outsetTop = 72,
  outsetBottom = 72,
  rodHeight = 72,
  rodCapWidth = 102,
  edgeWidth = 58,
  edgeCapHeight = 40,
  edgeLeftOffset = -32,
  edgeRightOffset = -26,
  edgeTopOffset = 10,
  edgeExtraHeight = 22,
  rodTextureHeight = 128,
  rodLogicalHeight = 109,
  edgeTextureWidth = 128,
  edgeLogicalWidth = 118,
}

local MINI = {
  referenceContent = 140,
  ring = {
    path = MEDIA .. "MapMiniCompassRingV1",
    width = 184,
    height = 184,
    textureWidth = 256,
    textureHeight = 256,
  },
  north = {
    path = MEDIA .. "MapMiniNorthV1",
    width = 42,
    height = 58,
    textureWidth = 64,
    textureHeight = 64,
  },
  west = {
    path = MEDIA .. "MapMiniDirectionWestV1",
    width = 50,
    height = 36,
    textureWidth = 64,
    textureHeight = 64,
  },
  east = {
    path = MEDIA .. "MapMiniDirectionEastV1",
    width = 50,
    height = 36,
    textureWidth = 64,
    textureHeight = 64,
  },
  south = {
    path = MEDIA .. "MapMiniDirectionSouthV1",
    width = 38,
    height = 42,
    textureWidth = 64,
    textureHeight = 64,
  },
  plaque = {
    path = MEDIA .. "MapMiniInfoPlaqueV1",
    width = 150,
    height = 44,
    textureWidth = 256,
    textureHeight = 64,
  },
}

local function ModuleEnabled()
  return
    addon.db and
    addon.db.map and
    addon.db.map.enabled and
    true or false
end

local function FrameShown(frame)
  if not frame then return false end
  if type(frame.IsShown) == "function" then
    return frame:IsShown() and true or false
  end
  return true
end

local function SetShown(frame, shown)
  if not frame then return end
  if shown and type(frame.Show) == "function" then
    frame:Show()
  elseif not shown and type(frame.Hide) == "function" then
    frame:Hide()
  end
end

local function CaptureBackdropState(frame)
  if not frame then return end
  frame.aeuiMapBackdropRestore = frame.aeuiMapBackdropRestore or {}
  local restore = frame.aeuiMapBackdropRestore
  if frame.backdrop and restore.backdrop == nil then
    restore.backdrop = FrameShown(frame.backdrop)
  end
  if frame.backdrop_shadow and restore.shadow == nil then
    restore.shadow = FrameShown(frame.backdrop_shadow)
  end
end

local function HideProviderBackdrop(frame)
  if not frame then return end
  CaptureBackdropState(frame)
  if frame.backdrop then frame.backdrop:Hide() end
  if frame.backdrop_shadow then frame.backdrop_shadow:Hide() end
end

local function RestoreProviderBackdrop(frame)
  if not frame then return end
  local restore = frame.aeuiMapBackdropRestore
  if not restore then return end
  if restore.backdrop ~= nil and frame.backdrop then
    SetShown(frame.backdrop, restore.backdrop)
  end
  if restore.shadow ~= nil and frame.backdrop_shadow then
    SetShown(frame.backdrop_shadow, restore.shadow)
  end
  frame.aeuiMapBackdropRestore = nil
end

local function ConfigureTexture(texture, path, width, height, texCoord)
  texture:ClearAllPoints()
  texture:SetTexture(path)
  texture:SetWidth(width)
  texture:SetHeight(height)
  texture:SetTexCoord(
    texCoord[1], texCoord[2], texCoord[3], texCoord[4]
  )
  texture:SetVertexColor(1, 1, 1)
  texture:SetAlpha(1)
  texture:Show()
end

local function HideTextureSet(textures)
  if not textures then return end
  for _, group in pairs(textures) do
    if group and type(group.Hide) == "function" then
      group:Hide()
    elseif type(group) == "table" then
      for _, texture in pairs(group) do
        if texture and type(texture.Hide) == "function" then
          texture:Hide()
        end
      end
    end
  end
end

local function EnsureWorldArt()
  if not WorldMapFrame or not WorldMapButton then return nil end
  if WorldMapFrame.aeuiMapWorldArt then
    return WorldMapFrame.aeuiMapWorldArt
  end

  local art = CreateFrame(
    "Frame",
    "AzerothExpeditionUIWorldMapArt",
    WorldMapFrame
  )
  art:EnableMouse(false)
  art:SetAllPoints(WorldMapFrame)
  local contentLevel = WorldMapButton:GetFrameLevel() or 1
  art:SetFrameLevel(math.max(0, contentLevel - 1))

  art.textures = {
    edgeLeft = {
      art:CreateTexture(nil, "ARTWORK"),
      art:CreateTexture(nil, "ARTWORK"),
      art:CreateTexture(nil, "ARTWORK"),
    },
    edgeRight = {
      art:CreateTexture(nil, "ARTWORK"),
      art:CreateTexture(nil, "ARTWORK"),
      art:CreateTexture(nil, "ARTWORK"),
    },
    rodTop = {
      art:CreateTexture(nil, "ARTWORK"),
      art:CreateTexture(nil, "ARTWORK"),
      art:CreateTexture(nil, "ARTWORK"),
    },
    rodBottom = {
      art:CreateTexture(nil, "ARTWORK"),
      art:CreateTexture(nil, "ARTWORK"),
      art:CreateTexture(nil, "ARTWORK"),
    },
  }
  WorldMapFrame.aeuiMapWorldArt = art
  return art
end

local function LayoutHorizontal(
  textures,
  path,
  anchor,
  point,
  relativePoint,
  x,
  y,
  totalWidth,
  height
)
  local cap = WORLD.rodCapWidth
  local centre = totalWidth - cap - cap
  if centre < 1 then return false end
  local bottom = WORLD.rodLogicalHeight / WORLD.rodTextureHeight

  ConfigureTexture(textures[1], path, cap, height, { 0, 0.15, 0, bottom })
  ConfigureTexture(textures[2], path, centre, height, { 0.15, 0.85, 0, bottom })
  ConfigureTexture(textures[3], path, cap, height, { 0.85, 1, 0, bottom })

  textures[1]:SetPoint(point, anchor, relativePoint, x, y)
  textures[2]:SetPoint("LEFT", textures[1], "RIGHT", 0, 0)
  textures[3]:SetPoint("LEFT", textures[2], "RIGHT", 0, 0)
  return true
end

local function LayoutVertical(
  textures,
  path,
  anchor,
  x,
  y,
  width,
  totalHeight
)
  local cap = WORLD.edgeCapHeight
  local centre = totalHeight - cap - cap
  if centre < 1 then return false end
  local right = WORLD.edgeLogicalWidth / WORLD.edgeTextureWidth

  ConfigureTexture(textures[1], path, width, cap, { 0, right, 0, 0.16 })
  ConfigureTexture(textures[2], path, width, centre, { 0, right, 0.16, 0.84 })
  ConfigureTexture(textures[3], path, width, cap, { 0, right, 0.84, 1 })

  textures[1]:SetPoint("TOPLEFT", anchor, "TOPLEFT", x, y)
  textures[2]:SetPoint("TOP", textures[1], "BOTTOM", 0, 0)
  textures[3]:SetPoint("TOP", textures[2], "BOTTOM", 0, 0)
  return true
end

function Map:RestoreWorld()
  if WorldMapFrame then
    local art = WorldMapFrame.aeuiMapWorldArt
    if art then
      art:Hide()
      HideTextureSet(art.textures)
    end
    RestoreProviderBackdrop(WorldMapFrame)
    WorldMapFrame.aeuiMapWorldRuntimeContract = nil
  end
  self.worldStatus = "inactive"
end

function Map:ApplyWorld()
  if Cartographer or METAMAP_TITLE then
    self:RestoreWorld()
    self.worldStatus = "other-map-provider"
    return false
  end
  if not WorldMapFrame or not WorldMapButton then
    self:RestoreWorld()
    self.worldStatus = "provider-missing"
    return false
  end

  local width = WorldMapButton:GetWidth()
  local height = WorldMapButton:GetHeight()
  if not width or not height or width <= 0 or height <= 0 then
    self:RestoreWorld()
    self.worldStatus = "provider-size-missing"
    return false
  end

  local art = EnsureWorldArt()
  if not art then
    self:RestoreWorld()
    self.worldStatus = "art-frame-missing"
    return false
  end

  local totalWidth = width + WORLD.outsetLeft + WORLD.outsetRight
  local edgeHeight = height + WORLD.edgeExtraHeight
  local ok = true
  ok = LayoutVertical(
    art.textures.edgeLeft,
    WORLD.edgeLeft,
    WorldMapButton,
    WORLD.edgeLeftOffset,
    WORLD.edgeTopOffset,
    WORLD.edgeWidth,
    edgeHeight
  ) and ok
  ok = LayoutVertical(
    art.textures.edgeRight,
    WORLD.edgeRight,
    WorldMapButton,
    width + WORLD.edgeRightOffset,
    WORLD.edgeTopOffset,
    WORLD.edgeWidth,
    edgeHeight
  ) and ok
  ok = LayoutHorizontal(
    art.textures.rodTop,
    WORLD.rodTop,
    WorldMapButton,
    "TOPLEFT",
    "TOPLEFT",
    -WORLD.outsetLeft,
    WORLD.outsetTop,
    totalWidth,
    WORLD.rodHeight
  ) and ok
  ok = LayoutHorizontal(
    art.textures.rodBottom,
    WORLD.rodBottom,
    WorldMapButton,
    "BOTTOMLEFT",
    "BOTTOMLEFT",
    -WORLD.outsetLeft,
    -WORLD.outsetBottom,
    totalWidth,
    WORLD.rodHeight
  ) and ok

  if not ok then
    self:RestoreWorld()
    self.worldStatus = "geometry-invalid"
    return false
  end

  HideProviderBackdrop(WorldMapFrame)
  art:Show()
  WorldMapFrame.aeuiMapWorldRuntimeContract = self.runtimeContract
  self.worldStatus = "world-a1-applied"
  return true
end

local function CaptureAnchor(frame)
  if not frame or frame.aeuiMapAnchorRestore then return end
  local point, relativeTo, relativePoint, x, y = frame:GetPoint()
  frame.aeuiMapAnchorRestore = {
    point = point,
    relativeTo = relativeTo,
    relativePoint = relativePoint,
    x = x,
    y = y,
    width = frame:GetWidth(),
  }
end

local function RestoreAnchor(frame)
  if not frame or not frame.aeuiMapAnchorRestore then return end
  local restore = frame.aeuiMapAnchorRestore
  frame:ClearAllPoints()
  if restore.point then
    frame:SetPoint(
      restore.point,
      restore.relativeTo,
      restore.relativePoint,
      restore.x,
      restore.y
    )
  end
  if restore.width then frame:SetWidth(restore.width) end
  frame.aeuiMapAnchorRestore = nil
end

local function EnsureMiniArt()
  if not pfUI or not pfUI.minimap or not Minimap then return nil end
  if pfUI.minimap.aeuiMapMiniArt then
    return pfUI.minimap.aeuiMapMiniArt
  end

  local art = CreateFrame(
    "Frame",
    "AzerothExpeditionUIMinimapArt",
    pfUI.minimap
  )
  art:EnableMouse(false)
  art:SetAllPoints(pfUI.minimap)
  art:SetFrameLevel((Minimap:GetFrameLevel() or 1) + 1)
  art.textures = {
    ring = art:CreateTexture(nil, "ARTWORK"),
    north = art:CreateTexture(nil, "ARTWORK"),
    west = art:CreateTexture(nil, "ARTWORK"),
    east = art:CreateTexture(nil, "ARTWORK"),
    south = art:CreateTexture(nil, "ARTWORK"),
    plaque = art:CreateTexture(nil, "ARTWORK"),
  }
  pfUI.minimap.aeuiMapMiniArt = art
  return art
end

local function LayoutMiniTexture(texture, definition, scale)
  ConfigureTexture(
    texture,
    definition.path,
    definition.width * scale,
    definition.height * scale,
    {
      0,
      definition.width / definition.textureWidth,
      0,
      definition.height / definition.textureHeight,
    }
  )
end

local function FarmModeActive()
  return
    pfUI and
    pfUI.farmmap and
    type(pfUI.farmmap.IsShown) == "function" and
    pfUI.farmmap:IsShown() and
    true or false
end

function Map:RestoreMini()
  if pfUI and pfUI.minimap then
    local art = pfUI.minimap.aeuiMapMiniArt
    if art then
      art:Hide()
      HideTextureSet(art.textures)
    end
    RestoreProviderBackdrop(pfUI.minimap)
    pfUI.minimap.aeuiMapMiniRuntimeContract = nil
  end
  if pfUI then
    RestoreAnchor(pfUI.minimapZone)
    RestoreAnchor(pfUI.minimapCoordinates)
  end
  self.miniStatus = "inactive"
end

function Map:ApplyMini()
  if not pfUI or not pfUI.minimap or not Minimap then
    self:RestoreMini()
    self.miniStatus = "provider-missing"
    return false
  end
  if FarmModeActive() then
    self:RestoreMini()
    self.miniStatus = "farmmode-provider"
    return false
  end

  local width = Minimap:GetWidth()
  local height = Minimap:GetHeight()
  if
    not width or
    not height or
    width <= 0 or
    height <= 0 or
    math.abs(width - height) > 2
  then
    self:RestoreMini()
    self.miniStatus = "provider-geometry-unsupported"
    return false
  end

  local scale = width / MINI.referenceContent
  if scale <= 0 then
    self:RestoreMini()
    self.miniStatus = "provider-scale-invalid"
    return false
  end

  local art = EnsureMiniArt()
  if not art then
    self:RestoreMini()
    self.miniStatus = "art-frame-missing"
    return false
  end
  local textures = art.textures
  LayoutMiniTexture(textures.ring, MINI.ring, scale)
  LayoutMiniTexture(textures.north, MINI.north, scale)
  LayoutMiniTexture(textures.west, MINI.west, scale)
  LayoutMiniTexture(textures.east, MINI.east, scale)
  LayoutMiniTexture(textures.south, MINI.south, scale)
  LayoutMiniTexture(textures.plaque, MINI.plaque, scale)

  textures.ring:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
  textures.north:SetPoint("BOTTOM", Minimap, "TOP", 0, -12 * scale)
  textures.west:SetPoint("RIGHT", Minimap, "LEFT", 6 * scale, 0)
  textures.east:SetPoint("LEFT", Minimap, "RIGHT", -6 * scale, 0)
  textures.south:SetPoint("TOP", Minimap, "BOTTOM", 0, 4 * scale)
  textures.plaque:SetPoint("TOP", Minimap, "BOTTOM", 0, -26 * scale)

  if pfUI.minimapZone then
    CaptureAnchor(pfUI.minimapZone)
    pfUI.minimapZone:ClearAllPoints()
    pfUI.minimapZone:SetPoint(
      "TOP",
      Minimap,
      "BOTTOM",
      0,
      -31 * scale
    )
    pfUI.minimapZone:SetWidth(136 * scale)
  end
  if pfUI.minimapCoordinates then
    CaptureAnchor(pfUI.minimapCoordinates)
    pfUI.minimapCoordinates:ClearAllPoints()
    pfUI.minimapCoordinates:SetPoint(
      "TOP",
      Minimap,
      "BOTTOM",
      0,
      -49 * scale
    )
    pfUI.minimapCoordinates:SetWidth(136 * scale)
  end

  HideProviderBackdrop(pfUI.minimap)
  art:Show()
  pfUI.minimap.aeuiMapMiniRuntimeContract = self.runtimeContract
  self.miniStatus = "mini-a1-applied"
  return true
end

function Map:InstallHooks()
  if
    WorldMapFrame and
    not WorldMapFrame.aeuiMapWorldShowHooked and
    type(HookScript) == "function"
  then
    WorldMapFrame.aeuiMapWorldShowHooked = true
    HookScript(WorldMapFrame, "OnShow", function()
      if ModuleEnabled() then
        addon:ScheduleRefresh(0)
      end
    end)
  end

  if
    pfUI and
    pfUI.farmmap and
    not pfUI.farmmap.aeuiMapFarmModeHooked and
    type(HookScript) == "function"
  then
    pfUI.farmmap.aeuiMapFarmModeHooked = true
    HookScript(pfUI.farmmap, "OnShow", function()
      Map:RestoreMini()
      Map.miniStatus = "farmmode-provider"
    end)
    HookScript(pfUI.farmmap, "OnHide", function()
      if ModuleEnabled() then
        addon:ScheduleRefresh(0)
      end
    end)
  end
end

function Map:GetRuntimeStatus()
  return
    "world=" .. tostring(self.worldStatus or "unapplied") ..
    ", mini=" .. tostring(self.miniStatus or "unapplied") ..
    ", controls=provider-live" ..
    ", pfquest=provider-live" ..
    ", farmmode=separate-provider" ..
    ", texture-containers=pot-1.12"
end

function Map:Initialize()
  self.worldStatus = "unapplied"
  self.miniStatus = "unapplied"
end

function Map:Apply()
  self:InstallHooks()
  if not ModuleEnabled() then
    self:RestoreWorld()
    self:RestoreMini()
    return
  end
  self:ApplyWorld()
  self:ApplyMini()
end

addon:RegisterModule("Map", Map)
