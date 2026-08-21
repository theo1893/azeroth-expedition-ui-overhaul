local addon = AzerothExpeditionUI
local Map = {}
Map.runtimeContract = "7.0"
Map.worldIntegrationPaused = true
Map.miniIntegrationPaused = false

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
  frame = {
    path = MEDIA .. "MapMiniCompassCradleV3",
    width = 220,
    height = 264,
    textureWidth = 256,
    textureHeight = 512,
    holeX = 110,
    holeY = 110,
  },
  mask = {
    path = MEDIA .. "MapMiniMaskV3",
  },
  info = {
    centerX = 110,
    width = 104,
    rowHeight = 14,
    upperCenterY = 219,
    lowerCenterY = 236,
  },
  addonSling = {
    path = MEDIA .. "MapMiniAddonSlingMasterV7",
    logicalWidth = 120,
    logicalHeight = 340,
    sampledWidth = 240,
    sampledHeight = 680,
    texelsPerUI = 2,
    textureWidth = 256,
    textureHeight = 1024,
    masterX = 94,
    masterY = 142,
    iconCenterX = 102,
    iconCenterY = 16,
    hitbox = 28,
    closedStartX = 84,
    closedHeight = 36,
    entryLeft = 91,
    entryTop = 140,
    entrySize = 21,
    entryPitch = 24,
    maxRows = 8,
    tiers = {
      { maximum = 8, startX = 84 },
      { maximum = 16, startX = 60 },
      { maximum = 24, startX = 36 },
      { maximum = 30, startX = 8 },
    },
  },
  latch = {
    top = {
      normal = MEDIA .. "MapMiniAddonLatchTopNormalV3",
      hover = MEDIA .. "MapMiniAddonLatchTopHoverV3",
      pressed = MEDIA .. "MapMiniAddonLatchTopPressedV3",
      width = 38,
      height = 24,
      textureWidth = 64,
      textureHeight = 32,
    },
    left = {
      normal = MEDIA .. "MapMiniAddonLatchLeftNormalV3",
      hover = MEDIA .. "MapMiniAddonLatchLeftHoverV3",
      pressed = MEDIA .. "MapMiniAddonLatchLeftPressedV3",
      width = 24,
      height = 38,
      textureWidth = 32,
      textureHeight = 64,
    },
    right = {
      normal = MEDIA .. "MapMiniAddonLatchRightNormalV3",
      hover = MEDIA .. "MapMiniAddonLatchRightHoverV3",
      pressed = MEDIA .. "MapMiniAddonLatchRightPressedV3",
      width = 24,
      height = 38,
      textureWidth = 32,
      textureHeight = 64,
    },
  },
  glyph = {
    up = {
      path = MEDIA .. "MapMiniAddonGlyphUpV3",
      width = 10,
      height = 12,
      textureWidth = 16,
      textureHeight = 16,
    },
    down = {
      path = MEDIA .. "MapMiniAddonGlyphDownV3",
      width = 10,
      height = 12,
      textureWidth = 16,
      textureHeight = 16,
    },
    left = {
      path = MEDIA .. "MapMiniAddonGlyphLeftV3",
      width = 12,
      height = 10,
      textureWidth = 16,
      textureHeight = 16,
    },
    right = {
      path = MEDIA .. "MapMiniAddonGlyphRightV3",
      width = 12,
      height = 10,
      textureWidth = 16,
      textureHeight = 16,
    },
  },
  socket = {
    path = MEDIA .. "MapMiniStatusSocketV3",
    width = 24,
    height = 24,
    textureWidth = 32,
    textureHeight = 32,
  },
  tray = {
    top = {
      path = MEDIA .. "MapMiniAddonTrayTopV4",
      logicalWidth = 270,
      logicalHeight = 74,
      textureWidth = 512,
      textureHeight = 128,
      cutX1 = 12,
      cutX2 = 252,
      cutY1 = 10,
      cutY2 = 62,
    },
    left = {
      path = MEDIA .. "MapMiniAddonTrayLeftV4",
      logicalWidth = 74,
      logicalHeight = 270,
      textureWidth = 128,
      textureHeight = 512,
      cutX1 = 10,
      cutX2 = 62,
      cutY1 = 18,
      cutY2 = 258,
    },
    right = {
      path = MEDIA .. "MapMiniAddonTrayRightV4",
      logicalWidth = 74,
      logicalHeight = 270,
      textureWidth = 128,
      textureHeight = 512,
      cutX1 = 12,
      cutX2 = 64,
      cutY1 = 12,
      cutY2 = 252,
    },
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
  if
    restore.directCaptured == nil and
    type(frame.GetBackdrop) == "function"
  then
    restore.directCaptured = true
    restore.direct = frame:GetBackdrop()
    if restore.direct and type(frame.GetBackdropColor) == "function" then
      restore.directColor = { frame:GetBackdropColor() }
    end
    if restore.direct and type(frame.GetBackdropBorderColor) == "function" then
      restore.directBorderColor = { frame:GetBackdropBorderColor() }
    end
  end
end

local function HideProviderBackdrop(frame)
  if not frame then return end
  CaptureBackdropState(frame)
  if frame.backdrop then frame.backdrop:Hide() end
  if frame.backdrop_shadow then frame.backdrop_shadow:Hide() end
  local restore = frame.aeuiMapBackdropRestore
  if
    restore and
    restore.direct and
    type(frame.SetBackdrop) == "function"
  then
    frame:SetBackdrop(nil)
  end
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
  if restore.directCaptured and type(frame.SetBackdrop) == "function" then
    frame:SetBackdrop(restore.direct)
    if
      restore.direct and
      restore.directColor and
      type(frame.SetBackdropColor) == "function"
    then
      frame:SetBackdropColor(
        restore.directColor[1] or 1,
        restore.directColor[2] or 1,
        restore.directColor[3] or 1,
        restore.directColor[4] or 1
      )
    end
    if
      restore.direct and
      restore.directBorderColor and
      type(frame.SetBackdropBorderColor) == "function"
    then
      frame:SetBackdropBorderColor(
        restore.directBorderColor[1] or 1,
        restore.directBorderColor[2] or 1,
        restore.directBorderColor[3] or 1,
        restore.directBorderColor[4] or 1
      )
    end
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
  local points = {}
  if
    type(frame.GetNumPoints) == "function" and
    type(frame.GetPoint) == "function"
  then
    local count = frame:GetNumPoints() or 0
    for index = 1, count do
      table.insert(points, { frame:GetPoint(index) })
    end
  elseif type(frame.GetPoint) == "function" then
    table.insert(points, { frame:GetPoint() })
  end
  frame.aeuiMapAnchorRestore = {
    points = points,
    width = frame:GetWidth(),
    height = frame:GetHeight(),
    scale =
      type(frame.GetScale) == "function" and
      frame:GetScale() or nil,
    frameStrata =
      type(frame.GetFrameStrata) == "function" and
      frame:GetFrameStrata() or nil,
    frameLevel =
      type(frame.GetFrameLevel) == "function" and
      frame:GetFrameLevel() or nil,
  }
end

local function RestoreAnchor(frame)
  if not frame or not frame.aeuiMapAnchorRestore then return end
  local restore = frame.aeuiMapAnchorRestore
  if restore.scale and type(frame.SetScale) == "function" then
    frame:SetScale(restore.scale)
  end
  if restore.width then frame:SetWidth(restore.width) end
  if restore.height then frame:SetHeight(restore.height) end
  frame:ClearAllPoints()
  for _, point in ipairs(restore.points or {}) do
    if point[1] then frame:SetPoint(unpack(point)) end
  end
  if restore.frameStrata and type(frame.SetFrameStrata) == "function" then
    frame:SetFrameStrata(restore.frameStrata)
  end
  if restore.frameLevel and type(frame.SetFrameLevel) == "function" then
    frame:SetFrameLevel(restore.frameLevel)
  end
  frame.aeuiMapAnchorRestore = nil
end

local function MatchEffectiveScale(frame, relativeTo)
  if not frame or not relativeTo or type(frame.SetScale) ~= "function" then
    return
  end
  local parent = type(frame.GetParent) == "function" and frame:GetParent()
  if
    not parent or
    type(parent.GetEffectiveScale) ~= "function" or
    type(relativeTo.GetEffectiveScale) ~= "function"
  then
    return
  end
  local parentScale = parent:GetEffectiveScale()
  local relativeScale = relativeTo:GetEffectiveScale()
  if parentScale and parentScale > 0 and relativeScale and relativeScale > 0 then
    frame:SetScale(relativeScale / parentScale)
  end
end

local function MiniProviderAnchor(frame)
  if not frame or type(frame.GetPoint) ~= "function" then return nil end
  local point, relativeTo, relativePoint, x, y = frame:GetPoint()
  if not point then return nil end
  return {
    point = point,
    relativeTo = relativeTo or UIParent,
    relativePoint = relativePoint or point,
    x = x or 0,
    y = y or 0,
  }
end

local function SameMiniProviderAnchor(left, right)
  if not left or not right then return false end
  return
    left.point == right.point and
    left.relativeTo == right.relativeTo and
    left.relativePoint == right.relativePoint and
    math.abs((left.x or 0) - (right.x or 0)) < 0.01 and
    math.abs((left.y or 0) - (right.y or 0)) < 0.01
end

local function HorizontalAnchorKind(point)
  if string.find(point or "", "LEFT", 1, true) then return "left" end
  if string.find(point or "", "RIGHT", 1, true) then return "right" end
  return "center"
end

local function VerticalAnchorKind(point)
  if string.find(point or "", "TOP", 1, true) then return "top" end
  if string.find(point or "", "BOTTOM", 1, true) then return "bottom" end
  return "center"
end

local function ApplyMiniProviderSafety()
  if not pfUI or not pfUI.minimap then return end
  local frame = pfUI.minimap
  local current = MiniProviderAnchor(frame)
  if not current then return end

  local state = frame.aeuiMapProviderAnchorRestore
  if not state or not SameMiniProviderAnchor(current, state.applied) then
    state = { original = current }
    frame.aeuiMapProviderAnchorRestore = state
  end

  local source = state.original
  local relativeTo = source.relativeTo or UIParent
  if
    not relativeTo or
    type(frame.GetEffectiveScale) ~= "function" or
    type(relativeTo.GetEffectiveScale) ~= "function"
  then
    state.applied = current
    return
  end
  local relativeScale = relativeTo:GetEffectiveScale()
  local frameScale = frame:GetEffectiveScale()
  if not relativeScale or relativeScale <= 0 or not frameScale or frameScale <= 0 then
    state.applied = current
    return
  end

  local contentScale = 1
  if Minimap and type(Minimap.GetWidth) == "function" then
    local contentWidth = Minimap:GetWidth()
    if contentWidth and contentWidth > 0 then
      contentScale = contentWidth / MINI.referenceContent
    end
  end
  local ratio = frameScale / relativeScale * contentScale
  local margin = 2
  local leftExtension =
    (MINI.frame.holeX - MINI.referenceContent / 2) * ratio
  local rightExtension =
    (MINI.frame.width - MINI.frame.holeX - MINI.referenceContent / 2) * ratio
  local topExtension =
    (MINI.frame.holeY - MINI.referenceContent / 2) * ratio
  local bottomExtension =
    (MINI.frame.height - MINI.frame.holeY - MINI.referenceContent / 2) * ratio
  local x = source.x
  local y = source.y
  local horizontal = HorizontalAnchorKind(source.point)
  local relativeHorizontal = HorizontalAnchorKind(source.relativePoint)
  local vertical = VerticalAnchorKind(source.point)
  local relativeVertical = VerticalAnchorKind(source.relativePoint)

  if horizontal == relativeHorizontal then
    if horizontal == "left" then
      x = math.max(x, leftExtension + margin)
    elseif horizontal == "right" then
      x = math.min(x, -(rightExtension + margin))
    elseif type(relativeTo.GetWidth) == "function" then
      local halfWidth = relativeTo:GetWidth() / 2
      local shellLeft = MINI.frame.holeX * ratio
      local shellRight = (MINI.frame.width - MINI.frame.holeX) * ratio
      x = math.max(-halfWidth + shellLeft + margin, x)
      x = math.min(halfWidth - shellRight - margin, x)
    end
  end

  if vertical == relativeVertical then
    if vertical == "top" then
      y = math.min(y, -(topExtension + margin))
    elseif vertical == "bottom" then
      y = math.max(y, bottomExtension + margin)
    elseif type(relativeTo.GetHeight) == "function" then
      local halfHeight = relativeTo:GetHeight() / 2
      local shellTop = MINI.frame.holeY * ratio
      local shellBottom = (MINI.frame.height - MINI.frame.holeY) * ratio
      y = math.max(-halfHeight + shellBottom + margin, y)
      y = math.min(halfHeight - shellTop - margin, y)
    end
  end

  state.applied = {
    point = source.point,
    relativeTo = relativeTo,
    relativePoint = source.relativePoint,
    x = x,
    y = y,
  }
  if not SameMiniProviderAnchor(source, state.applied) then
    if not SameMiniProviderAnchor(current, state.applied) then
      frame:ClearAllPoints()
      frame:SetPoint(
        state.applied.point,
        state.applied.relativeTo,
        state.applied.relativePoint,
        state.applied.x,
        state.applied.y
      )
    end
    Map.miniSafetyStatus = "screen-inset"
  else
    Map.miniSafetyStatus = "unchanged"
  end
end

local function RestoreMiniProviderSafety()
  if not pfUI or not pfUI.minimap then return end
  local frame = pfUI.minimap
  local state = frame.aeuiMapProviderAnchorRestore
  if not state then return end
  local current = MiniProviderAnchor(frame)
  if current and state.applied and not SameMiniProviderAnchor(current, state.applied) then
    state.original = current
  end
  local restore = state.original
  if restore then
    frame:ClearAllPoints()
    frame:SetPoint(
      restore.point,
      restore.relativeTo,
      restore.relativePoint,
      restore.x,
      restore.y
    )
  end
  frame.aeuiMapProviderAnchorRestore = nil
  Map.miniSafetyStatus = "restored"
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
  art:SetFrameLevel((Minimap:GetFrameLevel() or 1) + 3)
  art.texture = art:CreateTexture(nil, "ARTWORK")
  art.texture:SetAllPoints(art)
  pfUI.minimap.aeuiMapMiniArt = art
  return art
end

local function FarmModeActive()
  return
    pfUI and
    pfUI.farmmap and
    type(pfUI.farmmap.IsShown) == "function" and
    pfUI.farmmap:IsShown() and
    true or false
end

local function MiniModuleEnabled()
  return ModuleEnabled() and not Map.miniIntegrationPaused
end

local function ProviderVisible()
  if FarmModeActive() then return false end
  if not Minimap or not FrameShown(Minimap) then return false end
  if pfUI and pfUI.minimap and pfUI.minimap:GetAlpha() <= 0.01 then
    return false
  end
  return true
end

local function MiniScale()
  if not Minimap then return 1 end
  local width = Minimap:GetWidth()
  if not width or width <= 0 then return 1 end
  return width / MINI.referenceContent
end

local function SetLogicalTexture(texture, definition)
  texture:SetTexture(definition.path)
  texture:SetTexCoord(
    0,
    definition.width / definition.textureWidth,
    0,
    definition.height / definition.textureHeight
  )
  texture:SetVertexColor(1, 1, 1)
  texture:SetAlpha(1)
  texture:Show()
end

local function ApplyRoundProviderMask()
  if Minimap and type(Minimap.SetMaskTexture) == "function" then
    Minimap:SetMaskTexture(MINI.mask.path)
    Minimap.aeuiRoundMaskApplied = true
  end
end

local function RestoreProviderMask()
  if
    Minimap and
    type(Minimap.SetMaskTexture) == "function" and
    pfUI and
    pfUI.media and
    pfUI.media["img:minimap"]
  then
    Minimap:SetMaskTexture(pfUI.media["img:minimap"])
    Minimap.aeuiRoundMaskApplied = nil
  end
end

local function SetFrameAlphaSuppressed(frame, suppressed)
  if not frame or type(frame.SetAlpha) ~= "function" then return end
  if suppressed then
    if frame.aeuiMapAlphaRestore == nil then
      frame.aeuiMapAlphaRestore = frame:GetAlpha()
    end
    frame:SetAlpha(0)
  elseif frame.aeuiMapAlphaRestore ~= nil then
    frame:SetAlpha(frame.aeuiMapAlphaRestore)
    frame.aeuiMapAlphaRestore = nil
  end
end

local function CenterInfoText(text)
  if not text then return end
  if not text.aeuiMapInfoJustifyCaptured then
    text.aeuiMapInfoJustifyCaptured = true
    if type(text.GetJustifyH) == "function" then
      text.aeuiMapInfoJustifyHRestore = text:GetJustifyH()
    end
    if type(text.GetJustifyV) == "function" then
      text.aeuiMapInfoJustifyVRestore = text:GetJustifyV()
    end
  end
  if type(text.SetJustifyH) == "function" then
    text:SetJustifyH("CENTER")
  end
  if type(text.SetJustifyV) == "function" then
    text:SetJustifyV("MIDDLE")
  end
end

local function RestoreInfoText(text)
  if not text or not text.aeuiMapInfoJustifyCaptured then return end
  if
    text.aeuiMapInfoJustifyHRestore and
    type(text.SetJustifyH) == "function"
  then
    text:SetJustifyH(text.aeuiMapInfoJustifyHRestore)
  end
  if
    text.aeuiMapInfoJustifyVRestore and
    type(text.SetJustifyV) == "function"
  then
    text:SetJustifyV(text.aeuiMapInfoJustifyVRestore)
  end
  text.aeuiMapInfoJustifyCaptured = nil
  text.aeuiMapInfoJustifyHRestore = nil
  text.aeuiMapInfoJustifyVRestore = nil
end

local function GetCoordinateMode()
  return
    pfUI_config and
    pfUI_config.appearance and
    pfUI_config.appearance.minimap and
    pfUI_config.appearance.minimap.coordstext or
    "off"
end

local function ApplyCoordinateVisibility()
  if not pfUI or not pfUI.minimapCoordinates then return end
  if GetCoordinateMode() == "off" then
    pfUI.minimapCoordinates:Hide()
  else
    -- The V3 coordinate row sits outside Minimap's hover region. Keep every
    -- enabled provider mode visible here so the lower cradle row cannot vanish.
    pfUI.minimapCoordinates:Show()
  end
end

local function RestoreCoordinateVisibility()
  if not pfUI or not pfUI.minimapCoordinates then return end
  if GetCoordinateMode() == "on" then
    pfUI.minimapCoordinates:Show()
  else
    pfUI.minimapCoordinates:Hide()
  end
end

local function EnsureMiniPanelProxy(art)
  if not art then return nil end
  if art.aeuiMapPanelProxy then return art.aeuiMapPanelProxy end
  local proxy = CreateFrame(
    "Button",
    "AzerothExpeditionUIMinimapPanelProxy",
    art
  )
  proxy:EnableMouse(true)
  if type(proxy.RegisterForClicks) == "function" then
    proxy:RegisterForClicks("LeftButtonUp")
  end
  proxy:SetFrameLevel((art:GetFrameLevel() or 1) + 3)
  art.aeuiMapPanelProxy = proxy
  return proxy
end

local function RestoreMiniPanelProvider()
  local panel = pfUI and pfUI.panel and pfUI.panel.minimap
  local art = pfUI and pfUI.minimap and pfUI.minimap.aeuiMapMiniArt
  local proxy = art and art.aeuiMapPanelProxy
  if proxy then proxy:Hide() end
  if not panel then return end
  RestoreAnchor(panel)
  if panel.text then
    RestoreAnchor(panel.text)
    RestoreInfoText(panel.text)
  end
  RestoreProviderBackdrop(panel)
  if
    panel.aeuiMapMouseRestore ~= nil and
    type(panel.EnableMouse) == "function"
  then
    panel:EnableMouse(panel.aeuiMapMouseRestore)
    panel.aeuiMapMouseRestore = nil
  end
  Map.miniPanelStatus = "restored"
end

local function StyleMiniPanelProvider(art, scale)
  local panel = pfUI and pfUI.panel and pfUI.panel.minimap
  local panelValue =
    pfUI_config and
    pfUI_config.panel and
    pfUI_config.panel.other and
    pfUI_config.panel.other.minimap or
    "none"
  if not panel or not panel.text or panelValue == "none" then
    RestoreMiniPanelProvider()
    Map.miniPanelStatus = "none"
    return false
  end

  CaptureAnchor(panel)
  CaptureAnchor(panel.text)
  HideProviderBackdrop(panel)
  local panelAutohide =
    pfUI_config and
    pfUI_config.panel and
    pfUI_config.panel.hide_minimap == "1"
  if
    not panelAutohide and
    panel.aeuiMapMouseRestore == nil and
    type(panel.IsMouseEnabled) == "function"
  then
    panel.aeuiMapMouseRestore = panel:IsMouseEnabled() and true or false
  end
  if
    not panelAutohide and
    panel.aeuiMapMouseRestore ~= nil and
    type(panel.EnableMouse) == "function"
  then
    panel:EnableMouse(false)
  end
  if
    type(panel.SetFrameStrata) == "function" and
    type(art.GetFrameStrata) == "function"
  then
    panel:SetFrameStrata(art:GetFrameStrata())
  end
  if type(panel.SetFrameLevel) == "function" then
    panel:SetFrameLevel((art:GetFrameLevel() or 1) + 3)
  end

  local proxy = EnsureMiniPanelProxy(art)
  proxy:ClearAllPoints()
  proxy:SetPoint(
    "CENTER",
    art,
    "TOPLEFT",
    MINI.info.centerX * scale,
    -MINI.info.upperCenterY * scale
  )
  proxy:SetWidth(MINI.info.width * scale)
  proxy:SetHeight(MINI.info.rowHeight * scale)
  proxy:SetFrameLevel((art:GetFrameLevel() or 1) + 3)
  for _, script in ipairs({
    "OnClick",
    "OnEnter",
    "OnLeave",
    "OnMouseDown",
    "OnMouseUp",
  }) do
    proxy:SetScript(script, panel:GetScript(script))
  end
  if FrameShown(panel) then proxy:Show() else proxy:Hide() end

  panel.text:ClearAllPoints()
  panel.text:SetPoint("TOPLEFT", proxy, "TOPLEFT", 0, 0)
  panel.text:SetPoint("BOTTOMRIGHT", proxy, "BOTTOMRIGHT", 0, 0)
  CenterInfoText(panel.text)
  Map.miniPanelStatus = "bridged-" .. tostring(panelValue)
  return true
end

local function PositionDynamicText(art, scale)
  if not art then return end
  local panelProvidesPrimaryText = StyleMiniPanelProvider(art, scale)
  if pfUI.minimapZone then
    CaptureAnchor(pfUI.minimapZone)
    pfUI.minimapZone:ClearAllPoints()
    pfUI.minimapZone:SetPoint(
      "CENTER",
      art,
      "TOPLEFT",
      MINI.info.centerX * scale,
      -MINI.info.upperCenterY * scale
    )
    pfUI.minimapZone:SetWidth(MINI.info.width * scale)
    pfUI.minimapZone:SetHeight(MINI.info.rowHeight * scale)
    pfUI.minimapZone:SetFrameLevel((Minimap:GetFrameLevel() or 1) + 5)
    CenterInfoText(pfUI.minimapZone.text)
    SetFrameAlphaSuppressed(pfUI.minimapZone, panelProvidesPrimaryText)
  end

  if pfUI.minimapCoordinates then
    CaptureAnchor(pfUI.minimapCoordinates)
    pfUI.minimapCoordinates:ClearAllPoints()
    pfUI.minimapCoordinates:SetPoint(
      "CENTER",
      art,
      "TOPLEFT",
      MINI.info.centerX * scale,
      -MINI.info.lowerCenterY * scale
    )
    pfUI.minimapCoordinates:SetWidth(MINI.info.width * scale)
    pfUI.minimapCoordinates:SetHeight(MINI.info.rowHeight * scale)
    if pfUI.minimapCoordinates.text then
      CenterInfoText(pfUI.minimapCoordinates.text)
    end
    pfUI.minimapCoordinates:SetFrameLevel((Minimap:GetFrameLevel() or 1) + 5)
    ApplyCoordinateVisibility()
  end
end

local function RestoreDynamicText()
  if not pfUI then return end
  SetFrameAlphaSuppressed(pfUI.minimapZone, false)
  RestoreAnchor(pfUI.minimapZone)
  RestoreAnchor(pfUI.minimapCoordinates)
  if pfUI.minimapZone then RestoreInfoText(pfUI.minimapZone.text) end
  if pfUI.minimapCoordinates then
    RestoreInfoText(pfUI.minimapCoordinates.text)
  end
  RestoreCoordinateVisibility()
  RestoreMiniPanelProvider()
end

local function EnsureSocketTexture(frame)
  if not frame then return nil end
  if not frame.aeuiMapSocket then
    frame.aeuiMapSocket = frame:CreateTexture(nil, "OVERLAY")
  end
  local texture = frame.aeuiMapSocket
  SetLogicalTexture(texture, MINI.socket)
  return texture
end

local function StyleStatusSocket(
  frame,
  icon,
  art,
  x,
  y,
  scale
)
  if not frame or not art then return end
  CaptureAnchor(frame)
  MatchEffectiveScale(frame, art)
  HideProviderBackdrop(frame)
  if type(frame.SetFrameStrata) == "function" then
    frame:SetFrameStrata("HIGH")
  end
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", art, "TOPLEFT", x * scale, -y * scale)
  frame:SetWidth(MINI.socket.width * scale)
  frame:SetHeight(MINI.socket.height * scale)
  if type(frame.SetFrameLevel) == "function" then
    frame:SetFrameLevel((Minimap:GetFrameLevel() or 1) + 6)
  end

  local socket = EnsureSocketTexture(frame)
  socket:ClearAllPoints()
  socket:SetAllPoints(frame)
  if icon then
    CaptureAnchor(icon)
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 4 * scale, -4 * scale)
    icon:SetWidth(16 * scale)
    icon:SetHeight(16 * scale)
  end
end

local function StyleStatusObjects(art, scale)
  if pfUI.tracking then
    StyleStatusSocket(
      pfUI.tracking,
      pfUI.tracking.icon,
      art,
      12,
      25,
      scale
    )
  end
  if MiniMapMailFrame then
    StyleStatusSocket(
      MiniMapMailFrame,
      MiniMapMailIcon,
      art,
      184,
      25,
      scale
    )
  end
  if MiniMapBattlefieldFrame then
    StyleStatusSocket(
      MiniMapBattlefieldFrame,
      MiniMapBattlefieldIcon,
      art,
      184,
      168,
      scale
    )
  end
  if pfUI.minimap and pfUI.minimap.pvpicon then
    StyleStatusSocket(
      pfUI.minimap.pvpicon,
      pfUI.minimap.pvpicon.texture,
      art,
      12,
      168,
      scale
    )
  end
end

local function HideStandaloneStatusWithProvider()
  if pfUI and pfUI.tracking and pfUI.tracking:IsShown() then
    pfUI.tracking.aeuiMapHiddenWithProvider = true
    pfUI.tracking:Hide()
  end
end

local function RestoreStandaloneStatusWithProvider()
  if
    pfUI and
    pfUI.tracking and
    pfUI.tracking.aeuiMapHiddenWithProvider
  then
    pfUI.tracking.aeuiMapHiddenWithProvider = nil
    if type(pfUI.tracking.RefreshMenu) == "function" then
      pfUI.tracking:RefreshMenu()
    else
      pfUI.tracking:Show()
    end
  end
end

local function RestoreStatusObject(frame, icon)
  if not frame then return end
  if frame.aeuiMapSocket then frame.aeuiMapSocket:Hide() end
  RestoreProviderBackdrop(frame)
  RestoreAnchor(frame)
  RestoreAnchor(icon)
end

local function RestoreStatusObjects()
  RestoreStatusObject(
    pfUI and pfUI.tracking,
    pfUI and pfUI.tracking and pfUI.tracking.icon
  )
  RestoreStatusObject(MiniMapMailFrame, MiniMapMailIcon)
  RestoreStatusObject(MiniMapBattlefieldFrame, MiniMapBattlefieldIcon)
  RestoreStatusObject(
    pfUI and pfUI.minimap and pfUI.minimap.pvpicon,
    pfUI and
      pfUI.minimap and
      pfUI.minimap.pvpicon and
      pfUI.minimap.pvpicon.texture
  )
end

local function EnsureNineSlice(frame)
  if not frame then return nil end
  if frame.aeuiMapNineSlice then return frame.aeuiMapNineSlice end
  local textures = {}
  for index = 1, 9 do
    textures[index] = frame:CreateTexture(nil, "BACKGROUND")
  end
  frame.aeuiMapNineSlice = textures
  return textures
end

local function PlaceSlice(
  texture,
  path,
  frame,
  point,
  relativePoint,
  x,
  y,
  width,
  height,
  uv
)
  texture:ClearAllPoints()
  texture:SetTexture(path)
  texture:SetTexCoord(uv[1], uv[2], uv[3], uv[4])
  texture:SetWidth(width)
  texture:SetHeight(height)
  texture:SetPoint(point, frame, relativePoint, x, y)
  texture:SetVertexColor(1, 1, 1)
  texture:SetAlpha(1)
  texture:Show()
end

local function LayoutNineSlice(frame, scale, position)
  local textures = EnsureNineSlice(frame)
  if not textures then return end
  local definition = MINI.tray[position or "bottom"]
  if not definition then return end
  local width = frame:GetWidth()
  local height = frame:GetHeight()
  if not width or not height or width <= 0 or height <= 0 then return end

  local capLeft = math.min(definition.cutX1 * scale, width / 3)
  local capRight = math.min(
    (definition.logicalWidth - definition.cutX2) * scale,
    width / 3
  )
  local capTop = math.min(definition.cutY1 * scale, height / 3)
  local capBottom = math.min(
    (definition.logicalHeight - definition.cutY2) * scale,
    height / 3
  )
  local centreWidth = math.max(1, width - capLeft - capRight)
  local centreHeight = math.max(1, height - capTop - capBottom)
  local xs = {
    0,
    definition.cutX1 / definition.textureWidth,
    definition.cutX2 / definition.textureWidth,
    definition.logicalWidth / definition.textureWidth,
  }
  local ys = {
    0,
    definition.cutY1 / definition.textureHeight,
    definition.cutY2 / definition.textureHeight,
    definition.logicalHeight / definition.textureHeight,
  }
  local widths = { capLeft, centreWidth, capRight }
  local heights = { capTop, centreHeight, capBottom }
  local index = 1
  local offsetY = 0
  for row = 1, 3 do
    local offsetX = 0
    for column = 1, 3 do
      PlaceSlice(
        textures[index],
        definition.path,
        frame,
        "TOPLEFT",
        "TOPLEFT",
        offsetX,
        -offsetY,
        widths[column],
        heights[row],
        { xs[column], xs[column + 1], ys[row], ys[row + 1] }
      )
      offsetX = offsetX + widths[column]
      index = index + 1
    end
    offsetY = offsetY + heights[row]
  end
end

local function HideNineSlice(frame)
  if not frame or not frame.aeuiMapNineSlice then return end
  for _, texture in pairs(frame.aeuiMapNineSlice) do
    texture:Hide()
  end
end

local function GetAddonPosition()
  local position =
    pfUI_config and
    pfUI_config.abuttons and
    pfUI_config.abuttons.position or
    "bottom"
  if
    position ~= "bottom" and
    position ~= "left" and
    position ~= "top" and
    position ~= "right"
  then
    position = "bottom"
  end
  return position
end

local function GetAddonRowSize()
  local value =
    pfUI_config and
    pfUI_config.abuttons and
    tonumber(pfUI_config.abuttons.rowsize) or
    6
  if value < 1 then value = 6 end
  return value
end

local function GetTopAddonFrame(frame, container)
  if not frame then return nil end
  local top = frame
  local guard = 0
  while top:GetParent() and top:GetParent() ~= container and guard < 12 do
    top = top:GetParent()
    guard = guard + 1
  end
  if top:GetParent() == container then return top end
  return nil
end

local function GetAddonEntries(container)
  local entries = {}
  if not container or not container.buttons then return entries end
  for _, name in ipairs(container.buttons) do
    local frame = _G[name]
    if frame and FrameShown(frame) then
      local top = GetTopAddonFrame(frame, container)
      if top then
        table.insert(entries, { frame = frame, top = top })
      end
    end
  end
  return entries
end

local function RelativeEffectiveScale(frame, relativeTo)
  if
    not frame or
    not relativeTo or
    type(frame.GetEffectiveScale) ~= "function" or
    type(relativeTo.GetEffectiveScale) ~= "function"
  then
    return 1
  end
  local frameScale = frame:GetEffectiveScale()
  local relativeScale = relativeTo:GetEffectiveScale()
  if not frameScale or frameScale <= 0 or not relativeScale or relativeScale <= 0 then
    return 1
  end
  return frameScale / relativeScale
end

local function LayoutAddonEntries(container, entries, position, scale)
  local count = table.getn(entries)
  if count == 0 then return 0, 0, 0 end
  local definition = MINI.tray[position]
  if not definition then return 0, 0, 0 end
  local rowSize = GetAddonRowSize()
  local buttonSize = 21 * scale
  local gap = 2 * scale
  local safety = 2 * scale
  local paddingLeft = definition.cutX1 * scale + safety
  local paddingRight =
    (definition.logicalWidth - definition.cutX2) * scale + safety
  local paddingTop = definition.cutY1 * scale + safety
  local paddingBottom =
    (definition.logicalHeight - definition.cutY2) * scale + safety
  local horizontal = position == "bottom" or position == "top"
  local lineSize = rowSize
  if horizontal then
    -- Bottom/top rolls should read horizontally. Preserve rowsize as the
    -- minimum run, then widen dense collections instead of growing a tall
    -- hanging sheet. Thirty buttons become three rows of ten.
    lineSize = math.max(rowSize, math.ceil(count / 3))
  end
  local primary = math.min(lineSize, count)
  local secondary = math.ceil(count / lineSize)
  local width
  local height
  if horizontal then
    width =
      primary * buttonSize +
      (primary - 1) * gap +
      paddingLeft +
      paddingRight
    height =
      secondary * buttonSize +
      (secondary - 1) * gap +
      paddingTop +
      paddingBottom
  else
    width =
      secondary * buttonSize +
      (secondary - 1) * gap +
      paddingLeft +
      paddingRight
    height =
      primary * buttonSize +
      (primary - 1) * gap +
      paddingTop +
      paddingBottom
  end
  container:SetWidth(width)
  container:SetHeight(height)

  for index, entry in ipairs(entries) do
    local group = math.floor((index - 1) / lineSize)
    local item = (index - 1) - group * lineSize
    local groupStart = group * lineSize
    local groupCount = math.min(lineSize, count - groupStart)
    local groupSpan = groupCount * buttonSize + (groupCount - 1) * gap
    local x
    local y
    if horizontal then
      local interiorWidth = width - paddingLeft - paddingRight
      x =
        paddingLeft +
        (interiorWidth - groupSpan) / 2 +
        buttonSize / 2 +
        item * (buttonSize + gap)
      y = -(paddingTop + buttonSize / 2 + group * (buttonSize + gap))
    else
      local interiorHeight = height - paddingTop - paddingBottom
      x = paddingLeft + buttonSize / 2 + group * (buttonSize + gap)
      y = -(
        paddingTop +
        (interiorHeight - groupSpan) / 2 +
        buttonSize / 2 +
        item * (buttonSize + gap)
      )
    end
    local frameScale = RelativeEffectiveScale(entry.frame, container)
    entry.frame:ClearAllPoints()
    entry.frame:SetPoint("CENTER", container, "TOPLEFT", x / frameScale, y / frameScale)
    if entry.top ~= entry.frame then
      local topScale = RelativeEffectiveScale(entry.top, container)
      entry.top:ClearAllPoints()
      entry.top:SetPoint("CENTER", container, "TOPLEFT", x / topScale, y / topScale)
    end
  end
  return count, width, height
end

local function AddonSlingTier(count)
  local tiers = MINI.addonSling.tiers
  for _, tier in ipairs(tiers) do
    if count <= tier.maximum then return tier end
  end
  return tiers[table.getn(tiers)]
end

local function EnsureAddonSlingTexture(art)
  if not art then return nil end
  if not art.aeuiMapAddonSling then
    art.aeuiMapAddonSling = art:CreateTexture(nil, "OVERLAY")
  end
  return art.aeuiMapAddonSling
end

local function HideAddonSlingTexture(art)
  if art and art.aeuiMapAddonSling then
    art.aeuiMapAddonSling:Hide()
  end
end

local function SetAddonSlingTexture(art, count, expanded, scale)
  if not art or count < 1 then
    HideAddonSlingTexture(art)
    return nil
  end
  local definition = MINI.addonSling
  local tier = AddonSlingTier(count)
  local startX = expanded and tier.startX or definition.closedStartX
  local logicalHeight = expanded and definition.logicalHeight or definition.closedHeight
  local texelsPerUI = definition.texelsPerUI
  local texture = EnsureAddonSlingTexture(art)
  texture:ClearAllPoints()
  texture:SetPoint(
    "TOPLEFT",
    art,
    "TOPLEFT",
    (definition.masterX + startX) * scale,
    -definition.masterY * scale
  )
  texture:SetWidth((definition.logicalWidth - startX) * scale)
  texture:SetHeight(logicalHeight * scale)
  texture:SetTexture(definition.path)
  texture:SetTexCoord(
    startX * texelsPerUI / definition.textureWidth,
    definition.sampledWidth / definition.textureWidth,
    0,
    logicalHeight * texelsPerUI / definition.textureHeight
  )
  texture:SetVertexColor(1, 1, 1)
  texture:SetAlpha(1)
  texture:Show()
  return tier
end

local function LayoutAddonSlingEntries(container, entries, art, scale)
  local count = table.getn(entries)
  if count == 0 or not art then return count, nil end
  local definition = MINI.addonSling
  local tier = AddonSlingTier(count)
  local cropWidth = definition.logicalWidth - tier.startX
  container:ClearAllPoints()
  container:SetPoint(
    "TOPLEFT",
    art,
    "TOPLEFT",
    (definition.masterX + tier.startX) * scale,
    -definition.masterY * scale
  )
  container:SetWidth(cropWidth * scale)
  container:SetHeight(definition.logicalHeight * scale)

  for index, entry in ipairs(entries) do
    local column = math.floor((index - 1) / definition.maxRows)
    local row = (index - 1) - column * definition.maxRows
    local x = (
      definition.entryLeft -
      column * definition.entryPitch -
      tier.startX +
      definition.entrySize / 2
    ) * scale
    local y = (
      definition.entryTop +
      row * definition.entryPitch +
      definition.entrySize / 2
    ) * scale
    local frameScale = RelativeEffectiveScale(entry.frame, container)
    entry.frame:ClearAllPoints()
    entry.frame:SetPoint(
      "CENTER",
      container,
      "TOPLEFT",
      x / frameScale,
      -y / frameScale
    )
    if entry.top ~= entry.frame then
      local topScale = RelativeEffectiveScale(entry.top, container)
      entry.top:ClearAllPoints()
      entry.top:SetPoint(
        "CENTER",
        container,
        "TOPLEFT",
        x / topScale,
        -y / topScale
      )
    end
  end
  return count, tier
end

local function EnsureToggleArt(button)
  if not button then return nil end
  if not button.aeuiMapToggleBody then
    if type(button.GetFrameStrata) == "function" then
      button.aeuiMapOriginalFrameStrata = button:GetFrameStrata()
    end
    if type(button.GetFrameLevel) == "function" then
      button.aeuiMapOriginalFrameLevel = button:GetFrameLevel()
    end
    button.aeuiMapToggleBody = button:CreateTexture(nil, "BORDER")
    button.aeuiMapToggleBody:SetAllPoints(button)
    button.aeuiMapToggleGlyph = button:CreateTexture(nil, "ARTWORK")
    button.aeuiMapToggleGlyph:SetPoint("CENTER", button, "CENTER", 0, 0)
  end
  -- Keep the real clickable provider Button above all decorative art.
  if type(button.SetFrameStrata) == "function" then
    button:SetFrameStrata("DIALOG")
  end
  if button.icon then button.icon:Hide() end
  if button.aeuiMapConnector then button.aeuiMapConnector:Hide() end
  HideProviderBackdrop(button)
  return button.aeuiMapToggleGlyph
end

local function PrepareAddonSlingButton(button, art, scale)
  if not button or not art then return false end
  EnsureToggleArt(button)
  if button.aeuiMapToggleBody then button.aeuiMapToggleBody:Hide() end
  if button.aeuiMapToggleGlyph then button.aeuiMapToggleGlyph:Hide() end
  button:ClearAllPoints()
  button:SetWidth(MINI.addonSling.hitbox * scale)
  button:SetHeight(MINI.addonSling.hitbox * scale)
  button:SetPoint(
    "CENTER",
    art,
    "TOPLEFT",
    (MINI.addonSling.masterX + MINI.addonSling.iconCenterX) * scale,
    -(MINI.addonSling.masterY + MINI.addonSling.iconCenterY) * scale
  )
  return true
end

local function SetComponentTexture(texture, path, definition)
  texture:SetTexture(path)
  texture:SetTexCoord(
    0,
    definition.width / definition.textureWidth,
    0,
    definition.height / definition.textureHeight
  )
  texture:SetVertexColor(1, 1, 1)
  texture:SetAlpha(1)
  texture:Show()
end

local function SetToggleBodyState(button, position, state)
  if not button then return end
  EnsureToggleArt(button)
  local definition = MINI.latch[position]
  if not definition then return end
  local path = definition[state or "normal"] or definition.normal
  SetComponentTexture(button.aeuiMapToggleBody, path, definition)
  button.aeuiMapToggleState = state or "normal"
  button.aeuiMapTogglePosition = position
end

local function SetToggleGlyph(button, direction, scale)
  local glyph = EnsureToggleArt(button)
  if not glyph then return end
  local definition = MINI.glyph[direction]
  if not definition then return end
  glyph:ClearAllPoints()
  glyph:SetPoint("CENTER", button, "CENTER", 0, 0)
  glyph:SetWidth(definition.width * scale)
  glyph:SetHeight(definition.height * scale)
  SetComponentTexture(glyph, definition.path, definition)
end

local function ToggleDirection(position, expanded)
  if position == "bottom" then
    return expanded and "up" or "down"
  elseif position == "top" then
    return expanded and "down" or "up"
  elseif position == "left" then
    return expanded and "right" or "left"
  else
    return expanded and "left" or "right"
  end
end

local function AnchorAddonFrames(container, button, art, position, scale)
  if not art then return false end
  local latch = MINI.latch[position]
  if not latch then return false end
  container:ClearAllPoints()
  button:ClearAllPoints()
  button:SetWidth(latch.width * scale)
  button:SetHeight(latch.height * scale)
  if position == "top" then
    button:SetPoint("TOPLEFT", art, "TOPLEFT", 142 * scale, -17 * scale)
    container:SetPoint("BOTTOM", art, "TOPLEFT", 161 * scale, -21 * scale)
  elseif position == "left" then
    button:SetPoint("TOPLEFT", art, "TOPLEFT", -11 * scale, -92 * scale)
    container:SetPoint("RIGHT", art, "TOPLEFT", -7 * scale, -111 * scale)
  else
    button:SetPoint("TOPLEFT", art, "TOPLEFT", 207 * scale, -92 * scale)
    container:SetPoint("LEFT", art, "TOPLEFT", 227 * scale, -111 * scale)
  end
  return true
end

function Map:StyleAddonButtons(scale)
  if not pfUI or not pfUI.addonbuttons or not pfUI.addonbuttons.minimapbutton then
    self.addonButtonCount = 0
    return
  end
  local container = pfUI.addonbuttons
  local button = container.minimapbutton
  local art = pfUI.minimap and pfUI.minimap.aeuiMapMiniArt
  if not MiniModuleEnabled() or not ProviderVisible() then
    if container:IsShown() then
      container.aeuiMapRestoreShown = true
      container:Hide()
    end
    if button.aeuiMapConnector then button.aeuiMapConnector:Hide() end
    button:Hide()
    HideAddonSlingTexture(art)
    self.addonButtonCount = 0
    return
  end

  HideProviderBackdrop(container)
  local entries = GetAddonEntries(container)
  local position = GetAddonPosition()
  if position == "bottom" then
    local count = table.getn(entries)
    self.addonButtonCount = count
    HideNineSlice(container)
    if count == 0 then
      container:Hide()
      button:Hide()
      HideAddonSlingTexture(art)
      if button.aeuiMapConnector then button.aeuiMapConnector:Hide() end
      return
    end
    if not art or not PrepareAddonSlingButton(button, art, scale) then
      container:Hide()
      button:Hide()
      HideAddonSlingTexture(art)
      return
    end
    LayoutAddonSlingEntries(container, entries, art, scale)
    button:Show()
    SetAddonSlingTexture(art, count, container:IsShown(), scale)
    return
  end

  HideAddonSlingTexture(art)
  local count = LayoutAddonEntries(container, entries, position, scale)
  self.addonButtonCount = count
  if count == 0 then
    container:Hide()
    button:Hide()
    HideNineSlice(container)
    if button.aeuiMapConnector then button.aeuiMapConnector:Hide() end
    return
  end

  if not AnchorAddonFrames(container, button, art, position, scale) then
    container:Hide()
    button:Hide()
    HideNineSlice(container)
    return
  end
  LayoutNineSlice(container, scale, position)
  EnsureToggleArt(button)
  SetToggleBodyState(button, position, "normal")
  button:Show()
  local expanded = container:IsShown()
  SetToggleGlyph(button, ToggleDirection(position, expanded), scale)
end

function Map:RestoreAddonButtons()
  if not pfUI or not pfUI.addonbuttons then return end
  local container = pfUI.addonbuttons
  local art = pfUI.minimap and pfUI.minimap.aeuiMapMiniArt
  HideAddonSlingTexture(art)
  HideNineSlice(container)
  RestoreProviderBackdrop(container)
  if container.buttons then
    for _, name in ipairs(container.buttons) do
      local frame = _G[name]
      if frame and frame.aeuiMapSocket then
        frame.aeuiMapSocket:Hide()
        frame.aeuiMapSocket:SetVertexColor(1, 1, 1)
      end
    end
  end
  local button = container.minimapbutton
  if button then
    if button.aeuiMapConnector then button.aeuiMapConnector:Hide() end
    if button.aeuiMapToggleBody then button.aeuiMapToggleBody:Hide() end
    if button.aeuiMapToggleGlyph then button.aeuiMapToggleGlyph:Hide() end
    if button.icon then button.icon:Show() end
    RestoreProviderBackdrop(button)
    if
      button.aeuiMapOriginalFrameStrata and
      type(button.SetFrameStrata) == "function"
    then
      button:SetFrameStrata(button.aeuiMapOriginalFrameStrata)
    end
    if
      button.aeuiMapOriginalFrameLevel and
      type(button.SetFrameLevel) == "function"
    then
      button:SetFrameLevel(button.aeuiMapOriginalFrameLevel)
    end
    button:SetWidth(16)
    button:SetHeight(16)
  end
  if container.aeuiOriginalProcessButtons then
    self.restoringMini = true
    container.aeuiOriginalProcessButtons(container)
    self.restoringMini = nil
  end
end

function Map:StyleFarmMode()
  if not pfUI or not pfUI.farmmap then return end
  -- FarmMode is a separate 300x300 provider.  Restore its own pfUI visuals;
  -- the permanent compass, cradle, latch and tool roll must not be reused.
  self:RestoreFarmModeStyle()
  RestoreProviderBackdrop(pfUI.minimap)
  RestoreProviderMask()
  RestoreDynamicText()
  RestoreStatusObjects()
  RestoreStandaloneStatusWithProvider()
  RestoreMiniProviderSafety()
  local art = pfUI.minimap and pfUI.minimap.aeuiMapMiniArt
  if art then art:Hide() end
  if pfUI.addonbuttons then
    if pfUI.addonbuttons:IsShown() then
      pfUI.addonbuttons.aeuiMapRestoreShown = true
      pfUI.addonbuttons:Hide()
    end
    if pfUI.addonbuttons.minimapbutton then
      if pfUI.addonbuttons.minimapbutton.aeuiMapConnector then
        pfUI.addonbuttons.minimapbutton.aeuiMapConnector:Hide()
      end
      pfUI.addonbuttons.minimapbutton:Hide()
    end
  end
end

function Map:RestoreFarmModeStyle()
  if not pfUI or not pfUI.farmmap then return end
  RestoreProviderBackdrop(pfUI.farmmap)
  local button = pfUI.farmmap.button
  if not button then return end
  HideNineSlice(button)
  RestoreProviderBackdrop(button)
  RestoreAnchor(button)
  if button.txt and button.aeuiMapOriginalText ~= nil then
    button.txt:SetText(button.aeuiMapOriginalText)
    if button.aeuiMapOriginalTextColor then
      button.txt:SetTextColor(unpack(button.aeuiMapOriginalTextColor))
    end
  end
  button:SetFrameStrata("MEDIUM")
end

function Map:RestoreMini()
  if pfUI and pfUI.minimap then
    local art = pfUI.minimap.aeuiMapMiniArt
    if art then
      art:Hide()
      if art.texture then art.texture:Hide() end
    end
    RestoreProviderBackdrop(pfUI.minimap)
    pfUI.minimap.aeuiMapMiniRuntimeContract = nil
  end
  RestoreProviderMask()
  RestoreDynamicText()
  RestoreStatusObjects()
  RestoreStandaloneStatusWithProvider()
  self:RestoreAddonButtons()
  self:RestoreFarmModeStyle()
  RestoreMiniProviderSafety()
  self.miniStatus = "inactive"
end

function Map:ApplyMini()
  if not pfUI or not pfUI.minimap or not Minimap then
    self:RestoreMini()
    self.miniStatus = "provider-missing"
    return false
  end
  if FarmModeActive() then
    self:StyleFarmMode()
    self.miniStatus = "farmmode-provider"
    return true
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

  ApplyMiniProviderSafety()
  local art = EnsureMiniArt()
  if not art then
    self:RestoreMini()
    self.miniStatus = "art-frame-missing"
    return false
  end
  art:ClearAllPoints()
  art:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -40 * scale, 40 * scale)
  art:SetWidth(MINI.frame.width * scale)
  art:SetHeight(MINI.frame.height * scale)
  SetLogicalTexture(art.texture, MINI.frame)
  ApplyRoundProviderMask()
  PositionDynamicText(art, scale)
  StyleStatusObjects(art, scale)
  HideProviderBackdrop(pfUI.minimap)
  self:RestoreFarmModeStyle()
  if ProviderVisible() then
    RestoreStandaloneStatusWithProvider()
    art:Show()
    self:StyleAddonButtons(scale)
    if
      pfUI.addonbuttons and
      pfUI.addonbuttons.aeuiMapRestoreShown and
      self.addonButtonCount > 0 and
      not UnitAffectingCombat("player")
    then
      pfUI.addonbuttons.aeuiMapRestoreShown = nil
      pfUI.addonbuttons:Show()
      self:StyleAddonButtons(scale)
    end
  else
    HideStandaloneStatusWithProvider()
    art:Hide()
    self:StyleAddonButtons(scale)
    self.miniStatus = "provider-hidden"
    return true
  end
  pfUI.minimap.aeuiMapMiniRuntimeContract = self.runtimeContract
  self.miniStatus = "mini-v7-integrated-light-sling"
  return true
end

local function SetAddonToggleInteractionState(button, state)
  local position = GetAddonPosition()
  if position == "bottom" then
    -- V7's exact-pixels master is state-stable. The real Button still owns
    -- input, but hover/pressed must not resurrect the retired V5 base.
    if button.aeuiMapToggleBody then button.aeuiMapToggleBody:Hide() end
    if button.aeuiMapToggleGlyph then button.aeuiMapToggleGlyph:Hide() end
    return
  end
  SetToggleBodyState(button, position, state)
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
    pfUI.minimap and
    not pfUI.minimap.aeuiMapDragHooked and
    type(HookScript) == "function"
  then
    pfUI.minimap.aeuiMapDragHooked = true
    HookScript(pfUI.minimap, "OnDragStop", function()
      if MiniModuleEnabled() then addon:ScheduleRefresh(0) end
    end)
  end

  if
    Minimap and
    not Minimap.aeuiMapCoordinateVisibilityHooked and
    type(HookScript) == "function"
  then
    Minimap.aeuiMapCoordinateVisibilityHooked = true
    HookScript(Minimap, "OnEnter", function()
      if MiniModuleEnabled() and not FarmModeActive() then
        ApplyCoordinateVisibility()
      end
    end)
    HookScript(Minimap, "OnLeave", function()
      if MiniModuleEnabled() and not FarmModeActive() then
        ApplyCoordinateVisibility()
      end
    end)
  end

  if
    pfUI and
    pfUI.panel and
    pfUI.panel.minimap and
    not pfUI.panel.minimap.aeuiMapPanelHooked and
    type(HookScript) == "function"
  then
    local panel = pfUI.panel.minimap
    panel.aeuiMapPanelHooked = true
    HookScript(panel, "OnShow", function()
      if MiniModuleEnabled() and not FarmModeActive() then
        addon:ScheduleRefresh(0)
      end
    end)
    HookScript(panel, "OnHide", function()
      local art = pfUI.minimap and pfUI.minimap.aeuiMapMiniArt
      if art and art.aeuiMapPanelProxy then
        art.aeuiMapPanelProxy:Hide()
      end
    end)
  end

  if
    pfUI and
    pfUI.addonbuttons and
    pfUI.addonbuttons.ProcessButtons and
    not pfUI.addonbuttons.aeuiMapProcessWrapped
  then
    local container = pfUI.addonbuttons
    container.aeuiMapProcessWrapped = true
    container.aeuiOriginalProcessButtons = container.ProcessButtons
    container.ProcessButtons = function(self)
      container.aeuiOriginalProcessButtons(self)
      if not Map.restoringMini and MiniModuleEnabled() then
        Map:StyleAddonButtons(MiniScale())
      end
    end
    if type(HookScript) == "function" then
      HookScript(container, "OnShow", function()
        if MiniModuleEnabled() then
          Map:StyleAddonButtons(MiniScale())
        end
      end)
      HookScript(container, "OnHide", function()
        if MiniModuleEnabled() and container.minimapbutton then
          if GetAddonPosition() == "bottom" then
            Map:StyleAddonButtons(MiniScale())
          else
            local button = container.minimapbutton
            SetToggleGlyph(
              button,
              ToggleDirection(GetAddonPosition(), false),
              MiniScale()
            )
            SetToggleBodyState(button, GetAddonPosition(), "normal")
          end
        end
      end)
      if container.minimapbutton then
        HookScript(container.minimapbutton, "OnClick", function()
          if MiniModuleEnabled() then
            Map:StyleAddonButtons(MiniScale())
          end
        end)
        HookScript(container.minimapbutton, "OnEnter", function()
          local button = container.minimapbutton
          SetAddonToggleInteractionState(button, "hover")
        end)
        HookScript(container.minimapbutton, "OnLeave", function()
          local button = container.minimapbutton
          SetAddonToggleInteractionState(button, "normal")
        end)
        HookScript(container.minimapbutton, "OnMouseDown", function()
          local button = container.minimapbutton
          SetAddonToggleInteractionState(button, "pressed")
        end)
        HookScript(container.minimapbutton, "OnMouseUp", function()
          local button = container.minimapbutton
          SetAddonToggleInteractionState(button, "hover")
        end)
      end
    end
  end

  if not self.toggleMinimapHooked and type(hooksecurefunc) == "function" then
    self.toggleMinimapHooked = true
    hooksecurefunc("ToggleMinimap", function()
      if MiniModuleEnabled() then addon:ScheduleRefresh(0) end
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
      Map:StyleFarmMode()
      Map.miniStatus = "farmmode-provider"
    end)
    HookScript(pfUI.farmmap, "OnHide", function()
      Map:RestoreFarmModeStyle()
      if MiniModuleEnabled() then
        addon:ScheduleRefresh(0)
      end
    end)
  end
end

function Map:GetRuntimeStatus()
  return
    "world=" .. tostring(self.worldStatus or "unapplied") ..
    ", mini=" .. tostring(self.miniStatus or "unapplied") ..
    ", mask=round-hard-boundary" ..
    ", info=external-cradle" ..
    ", info-provider=" .. tostring(self.miniPanelStatus or "native") ..
    ", edge-safety=" .. tostring(self.miniSafetyStatus or "unapplied") ..
    ", addons=" .. tostring(self.addonButtonCount or 0) ..
    ", addon-tray=v7-bottom-integrated-sling-v4-nonbottom-fallback" ..
    ", addon-toggle=v7-same-master-uv-crop" ..
    ", addon-connector=retired" ..
    ", controls=provider-live" ..
    ", pfquest=provider-live" ..
    ", farmmode=separate-provider" ..
    ", texture-containers=pot-1.12"
end

function Map:Initialize()
  self.worldStatus = "unapplied"
  self.miniStatus = "unapplied"
  self.miniPanelStatus = "unapplied"
  self.miniSafetyStatus = "unapplied"
end

function Map:Apply()
  self:InstallHooks()
  if not ModuleEnabled() then
    self:RestoreWorld()
    self:RestoreMini()
    return
  end
  if self.worldIntegrationPaused then
    self:RestoreWorld()
    self.worldStatus = "paused"
  else
    self:ApplyWorld()
  end
  if self.miniIntegrationPaused then
    self:RestoreMini()
    self.miniStatus = "paused"
  else
    self:ApplyMini()
  end
end

addon:RegisterModule("Map", Map)
