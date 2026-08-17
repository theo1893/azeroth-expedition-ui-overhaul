local addon = AzerothExpeditionUI
local Map = {}
Map.runtimeContract = "2.4"
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
    path = MEDIA .. "MapMiniFrameV2",
    width = 184,
    height = 184,
    textureWidth = 256,
    textureHeight = 256,
  },
  mask = {
    path = MEDIA .. "MapMiniMaskV2",
  },
  toggleBody = {
    path = MEDIA .. "MapMiniAddonToggleBodyV2",
    width = 28,
    height = 25,
    textureWidth = 32,
    textureHeight = 32,
  },
  toggleGlyph = {
    down = MEDIA .. "MapMiniAddonToggleGlyphDownV2",
    up = MEDIA .. "MapMiniAddonToggleGlyphUpV2",
    left = MEDIA .. "MapMiniAddonToggleGlyphLeftV2",
    right = MEDIA .. "MapMiniAddonToggleGlyphRightV2",
    horizontalWidth = 10,
    horizontalHeight = 8,
    horizontalTextureWidth = 16,
    horizontalTextureHeight = 8,
    verticalWidth = 8,
    verticalHeight = 10,
    verticalTextureWidth = 8,
    verticalTextureHeight = 16,
  },
  socket = {
    path = MEDIA .. "MapMiniAddonSocketV2",
    width = 22,
    height = 22,
    textureWidth = 32,
    textureHeight = 32,
  },
  tray = {
    path = MEDIA .. "MapMiniAddonTrayV2",
    logicalWidth = 270,
    logicalHeight = 64,
    textureWidth = 512,
    textureHeight = 64,
    cutX1 = 0.13,
    cutX2 = 0.87,
    cutY1 = 0.25,
    cutY2 = 0.75,
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
    height = frame:GetHeight(),
    frameLevel =
      type(frame.GetFrameLevel) == "function" and
      frame:GetFrameLevel() or nil,
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
  if restore.height then frame:SetHeight(restore.height) end
  if restore.frameLevel and type(frame.SetFrameLevel) == "function" then
    frame:SetFrameLevel(restore.frameLevel)
  end
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

local function PositionDynamicText(scale)
  if pfUI.minimapZone then
    CaptureAnchor(pfUI.minimapZone)
    pfUI.minimapZone:ClearAllPoints()
    pfUI.minimapZone:SetPoint("TOP", Minimap, "TOP", 0, -7 * scale)
    pfUI.minimapZone:SetWidth(116 * scale)
    pfUI.minimapZone:SetFrameLevel((Minimap:GetFrameLevel() or 1) + 5)
  end

  if pfUI.minimapCoordinates then
    CaptureAnchor(pfUI.minimapCoordinates)
    local location =
      pfUI_config and
      pfUI_config.appearance and
      pfUI_config.appearance.minimap and
      pfUI_config.appearance.minimap.coordsloc or
      "bottomleft"
    pfUI.minimapCoordinates:ClearAllPoints()
    if location == "topleft" then
      pfUI.minimapCoordinates:SetPoint(
        "TOPLEFT", Minimap, "TOPLEFT", 12 * scale, -15 * scale
      )
    elseif location == "topright" then
      pfUI.minimapCoordinates:SetPoint(
        "TOPRIGHT", Minimap, "TOPRIGHT", -12 * scale, -15 * scale
      )
    elseif location == "bottomright" then
      pfUI.minimapCoordinates:SetPoint(
        "BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -12 * scale, 9 * scale
      )
    else
      pfUI.minimapCoordinates:SetPoint(
        "BOTTOMLEFT", Minimap, "BOTTOMLEFT", 12 * scale, 9 * scale
      )
    end
    pfUI.minimapCoordinates:SetWidth(116 * scale)
    pfUI.minimapCoordinates:SetFrameLevel((Minimap:GetFrameLevel() or 1) + 5)
  end
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
  point,
  relativePoint,
  x,
  y,
  scale
)
  if not frame then return end
  CaptureAnchor(frame)
  HideProviderBackdrop(frame)
  frame:ClearAllPoints()
  frame:SetPoint(point, Minimap, relativePoint, x * scale, y * scale)
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
    icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 3 * scale, -3 * scale)
    icon:SetWidth(16 * scale)
    icon:SetHeight(16 * scale)
  end
end

local function StyleStatusObjects(scale)
  if pfUI.tracking then
    StyleStatusSocket(
      pfUI.tracking,
      pfUI.tracking.icon,
      "TOPLEFT",
      "TOPLEFT",
      -10,
      4,
      scale
    )
  end
  if MiniMapMailFrame then
    StyleStatusSocket(
      MiniMapMailFrame,
      MiniMapMailIcon,
      "TOPRIGHT",
      "TOPRIGHT",
      10,
      4,
      scale
    )
  end
  if MiniMapBattlefieldFrame then
    StyleStatusSocket(
      MiniMapBattlefieldFrame,
      MiniMapBattlefieldIcon,
      "BOTTOMRIGHT",
      "BOTTOMRIGHT",
      10,
      -4,
      scale
    )
  end
  if pfUI.minimap and pfUI.minimap.pvpicon then
    StyleStatusSocket(
      pfUI.minimap.pvpicon,
      pfUI.minimap.pvpicon.texture,
      "BOTTOMRIGHT",
      "BOTTOMRIGHT",
      10,
      19,
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

local function PlaceSlice(texture, frame, point, relativePoint, x, y, width, height, uv)
  texture:ClearAllPoints()
  texture:SetTexture(MINI.tray.path)
  texture:SetTexCoord(uv[1], uv[2], uv[3], uv[4])
  texture:SetWidth(width)
  texture:SetHeight(height)
  texture:SetPoint(point, frame, relativePoint, x, y)
  texture:SetVertexColor(1, 1, 1)
  texture:SetAlpha(1)
  texture:Show()
end

local function LayoutNineSlice(frame, scale)
  local textures = EnsureNineSlice(frame)
  if not textures then return end
  local width = frame:GetWidth()
  local height = frame:GetHeight()
  if not width or not height or width <= 0 or height <= 0 then return end

  local capX = math.min(10 * scale, width / 3)
  local capY = math.min(6 * scale, height / 3)
  local centreWidth = math.max(1, width - capX - capX)
  local centreHeight = math.max(1, height - capY - capY)
  local uMax = MINI.tray.logicalWidth / MINI.tray.textureWidth
  local vMax = MINI.tray.logicalHeight / MINI.tray.textureHeight
  local xs = {
    0,
    MINI.tray.cutX1 * uMax,
    MINI.tray.cutX2 * uMax,
    uMax,
  }
  local ys = {
    0,
    MINI.tray.cutY1 * vMax,
    MINI.tray.cutY2 * vMax,
    vMax,
  }
  local widths = { capX, centreWidth, capX }
  local heights = { capY, centreHeight, capY }
  local index = 1
  local offsetY = 0
  for row = 1, 3 do
    local offsetX = 0
    for column = 1, 3 do
      PlaceSlice(
        textures[index],
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
  local rowSize = GetAddonRowSize()
  local buttonSize = 21 * scale
  local gap = 2 * scale
  local padding = 2 * scale
  local horizontal = position == "bottom" or position == "top"
  local primary = math.min(rowSize, count)
  local secondary = math.ceil(count / rowSize)
  local width
  local height
  if horizontal then
    width = primary * buttonSize + (primary - 1) * gap + padding * 2
    height = secondary * buttonSize + (secondary - 1) * gap + padding * 2
  else
    width = secondary * buttonSize + (secondary - 1) * gap + padding * 2
    height = primary * buttonSize + (primary - 1) * gap + padding * 2
  end
  container:SetWidth(width)
  container:SetHeight(height)

  for index, entry in ipairs(entries) do
    local group = math.floor((index - 1) / rowSize)
    local item = (index - 1) - group * rowSize
    local groupStart = group * rowSize
    local groupCount = math.min(rowSize, count - groupStart)
    local groupSpan = groupCount * buttonSize + (groupCount - 1) * gap
    local x
    local y
    if horizontal then
      x = (width - groupSpan) / 2 + buttonSize / 2 + item * (buttonSize + gap)
      y = -(padding + buttonSize / 2 + group * (buttonSize + gap))
    else
      x = padding + buttonSize / 2 + group * (buttonSize + gap)
      y = -((height - groupSpan) / 2 + buttonSize / 2 + item * (buttonSize + gap))
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

local function EnsureToggleArt(button)
  if not button then return nil end
  if not button.aeuiMapToggleBody then
    button.aeuiMapToggleBody = button:CreateTexture(nil, "BACKGROUND")
    button.aeuiMapToggleBody:SetAllPoints(button)
    button.aeuiMapToggleGlyph = button:CreateTexture(nil, "ARTWORK")
    button.aeuiMapToggleGlyph:SetPoint("CENTER", button, "CENTER", 0, 0)
  end
  SetLogicalTexture(button.aeuiMapToggleBody, MINI.toggleBody)
  if button.icon then button.icon:Hide() end
  HideProviderBackdrop(button)
  return button.aeuiMapToggleGlyph
end

local function SetToggleGlyph(button, direction, scale)
  local glyph = EnsureToggleArt(button)
  if not glyph then return end
  local definition = MINI.toggleGlyph
  glyph:SetTexture(definition[direction])
  glyph:ClearAllPoints()
  glyph:SetPoint("CENTER", button, "CENTER", 0, 0)
  if direction == "left" or direction == "right" then
    glyph:SetWidth(definition.verticalWidth * scale)
    glyph:SetHeight(definition.verticalHeight * scale)
    glyph:SetTexCoord(
      0,
      definition.verticalWidth / definition.verticalTextureWidth,
      0,
      definition.verticalHeight / definition.verticalTextureHeight
    )
  else
    glyph:SetWidth(definition.horizontalWidth * scale)
    glyph:SetHeight(definition.horizontalHeight * scale)
    glyph:SetTexCoord(
      0,
      definition.horizontalWidth / definition.horizontalTextureWidth,
      0,
      definition.horizontalHeight / definition.horizontalTextureHeight
    )
  end
  glyph:SetVertexColor(1, 1, 1)
  glyph:Show()
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

local function AnchorAddonFrames(container, button, position, scale)
  container:ClearAllPoints()
  button:ClearAllPoints()
  button:SetWidth(MINI.toggleBody.width * scale)
  button:SetHeight(MINI.toggleBody.height * scale)
  if position == "bottom" then
    container:SetPoint("TOP", Minimap, "BOTTOM", 0, -31 * scale)
    button:SetPoint("TOP", Minimap, "BOTTOM", 0, -11 * scale)
  elseif position == "top" then
    container:SetPoint("BOTTOM", Minimap, "TOP", 0, 31 * scale)
    button:SetPoint("BOTTOM", Minimap, "TOP", 0, 11 * scale)
  elseif position == "left" then
    container:SetPoint("RIGHT", Minimap, "LEFT", -31 * scale, 0)
    button:SetPoint("RIGHT", Minimap, "LEFT", -10 * scale, 0)
  else
    container:SetPoint("LEFT", Minimap, "RIGHT", 31 * scale, 0)
    button:SetPoint("LEFT", Minimap, "RIGHT", 10 * scale, 0)
  end
end

function Map:StyleAddonButtons(scale)
  if not pfUI or not pfUI.addonbuttons or not pfUI.addonbuttons.minimapbutton then
    self.addonButtonCount = 0
    return
  end
  local container = pfUI.addonbuttons
  local button = container.minimapbutton
  if not MiniModuleEnabled() or not ProviderVisible() then
    if container:IsShown() then
      container.aeuiMapRestoreShown = true
      container:Hide()
    end
    button:Hide()
    self.addonButtonCount = 0
    return
  end

  HideProviderBackdrop(container)
  local entries = GetAddonEntries(container)
  local position = GetAddonPosition()
  local count = LayoutAddonEntries(container, entries, position, scale)
  self.addonButtonCount = count
  if count == 0 then
    container:Hide()
    button:Hide()
    HideNineSlice(container)
    return
  end

  AnchorAddonFrames(container, button, position, scale)
  LayoutNineSlice(container, scale)
  EnsureToggleArt(button)
  button:Show()
  SetToggleGlyph(button, ToggleDirection(position, container:IsShown()), scale)
end

function Map:RestoreAddonButtons()
  if not pfUI or not pfUI.addonbuttons then return end
  local container = pfUI.addonbuttons
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
    if button.aeuiMapToggleBody then button.aeuiMapToggleBody:Hide() end
    if button.aeuiMapToggleGlyph then button.aeuiMapToggleGlyph:Hide() end
    if button.icon then button.icon:Show() end
    RestoreProviderBackdrop(button)
    button:SetWidth(16)
    button:SetHeight(16)
  end
  if container.aeuiOriginalProcessButtons then
    self.restoringMini = true
    container.aeuiOriginalProcessButtons(container)
    self.restoringMini = nil
  end
end

local function LocalizedFarmReturn()
  local locale = type(GetLocale) == "function" and GetLocale() or ""
  if locale == "zhCN" or locale == "zhTW" then return "返回小地图" end
  return "RETURN TO MINIMAP"
end

function Map:StyleFarmMode()
  if not pfUI or not pfUI.farmmap then return end
  local art = pfUI.minimap and pfUI.minimap.aeuiMapMiniArt
  if art then art:Hide() end
  if pfUI.addonbuttons then
    if pfUI.addonbuttons:IsShown() then
      pfUI.addonbuttons.aeuiMapRestoreShown = true
      pfUI.addonbuttons:Hide()
    end
    if pfUI.addonbuttons.minimapbutton then
      pfUI.addonbuttons.minimapbutton:Hide()
    end
  end
  HideProviderBackdrop(pfUI.farmmap)
  local button = pfUI.farmmap.button
  if not button then return end
  CaptureAnchor(button)
  if button.txt and button.aeuiMapOriginalText == nil then
    button.aeuiMapOriginalText = button.txt:GetText()
    button.aeuiMapOriginalTextColor = { button.txt:GetTextColor() }
  end
  button:ClearAllPoints()
  button:SetPoint("LEFT", pfUI.farmmap, "RIGHT", 10, 0)
  button:SetWidth(92)
  button:SetHeight(25)
  button:SetFrameStrata("HIGH")
  HideProviderBackdrop(button)
  LayoutNineSlice(button, 1)
  if button.txt then
    button.txt:SetText(LocalizedFarmReturn())
    button.txt:SetTextColor(0.90, 0.82, 0.66)
  end
  button:Show()
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
  if pfUI then
    RestoreAnchor(pfUI.minimapZone)
    RestoreAnchor(pfUI.minimapCoordinates)
  end
  RestoreStatusObjects()
  RestoreStandaloneStatusWithProvider()
  self:RestoreAddonButtons()
  self:RestoreFarmModeStyle()
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

  local art = EnsureMiniArt()
  if not art then
    self:RestoreMini()
    self.miniStatus = "art-frame-missing"
    return false
  end
  art:ClearAllPoints()
  art:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
  art:SetWidth(MINI.frame.width * scale)
  art:SetHeight(MINI.frame.height * scale)
  SetLogicalTexture(art.texture, MINI.frame)
  ApplyRoundProviderMask()
  PositionDynamicText(scale)
  StyleStatusObjects(scale)
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
  self.miniStatus = "mini-v2-applied-round"
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
          SetToggleGlyph(
            container.minimapbutton,
            ToggleDirection(GetAddonPosition(), false),
            MiniScale()
          )
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
          if button.aeuiMapToggleBody then
            button.aeuiMapToggleBody:SetVertexColor(1, 0.84, 0.58)
          end
        end)
        HookScript(container.minimapbutton, "OnLeave", function()
          local button = container.minimapbutton
          if button.aeuiMapToggleBody then
            button.aeuiMapToggleBody:SetVertexColor(1, 1, 1)
          end
        end)
        HookScript(container.minimapbutton, "OnMouseDown", function()
          local button = container.minimapbutton
          if button.aeuiMapToggleBody then
            button.aeuiMapToggleBody:SetVertexColor(0.68, 0.58, 0.46)
          end
        end)
        HookScript(container.minimapbutton, "OnMouseUp", function()
          local button = container.minimapbutton
          if button.aeuiMapToggleBody then
            button.aeuiMapToggleBody:SetVertexColor(1, 1, 1)
          end
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
    ", addons=" .. tostring(self.addonButtonCount or 0) ..
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
