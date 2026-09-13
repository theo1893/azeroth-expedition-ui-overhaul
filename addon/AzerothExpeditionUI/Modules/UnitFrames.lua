local addon = AzerothExpeditionUI
local UnitFrames = {}
UnitFrames.runtimeContract = "2.2"

local MEDIA = addon.media.root .. "UnitFrames\\"
local HEALTH_TEXTURE = MEDIA .. "UnitFrameHealthFillV1"
local POWER_TEXTURE = MEDIA .. "UnitFramePowerFillV1"

local NAMEPLATE_TARGET_CUE = {
  texture = MEDIA .. "NameplateTargetCueV2",
  route = "unitframes.nameplate-target-cue",
  width = 24,
  height = 24,
  u1 = 8 / 64,
  u2 = 56 / 64,
  v1 = 8 / 64,
  v2 = 56 / 64,
  nameGap = 4,
  raidGap = 4,
}

local PLAYER_V5 = {
  base = MEDIA .. "UnitFramePlayerShellV5",
  sourceWidth = 254,
  sourceHeight = 77,
  -- Logical container dimensions preserve the 2x sampled texture UVs.
  textureWidth = 256,
  textureHeight = 128,
  providerWidth = 240,
  outsetLeft = 7,
  outsetTop = 6,
  leftCap = 7,
  centreWidth = 240,
  rightCap = 7,
  topCap = 16,
  centreHeight = 55,
  bottomCap = 6,
  assembly = "height-adaptive-v5-fixed-top-and-bottom",
}

local PRIMARY_GEOMETRY = {
  sourceWidth = 214,
  sourceHeight = 42,
  textureWidth = 256,
  textureHeight = 64,
  leftCap = 32,
  centreWidth = 150,
  rightCap = 32,
  topCap = 8,
  centreHeight = 26,
  bottomCap = 8,
  outsetLeft = 7,
  outsetRight = 7,
  outsetTop = 6,
  outsetBottom = 6,
  assembly = "nine-slice-32/150/32-8/26/8",
}

local TARGETTARGET_GEOMETRY = {
  sourceWidth = 112,
  sourceHeight = 34,
  textureWidth = 128,
  textureHeight = 64,
  leftCap = 20,
  centreWidth = 72,
  rightCap = 20,
  topCap = 6,
  centreHeight = 22,
  bottomCap = 6,
  outsetLeft = 6,
  outsetRight = 6,
  outsetTop = 6,
  outsetBottom = 6,
  assembly = "nine-slice-20/72/20-6/22/6",
}

local FOCUS_GEOMETRY = {
  sourceWidth = 112,
  sourceHeight = 43,
  textureWidth = 128,
  textureHeight = 64,
  leftCap = 24,
  centreWidth = 64,
  rightCap = 24,
  topCap = 10,
  centreHeight = 27,
  bottomCap = 6,
  outsetLeft = 6,
  outsetRight = 6,
  outsetTop = 10,
  outsetBottom = 6,
  assembly = "nine-slice-24/64/24-10/27/6",
}

-- The existing scoped shell route owns every explicitly registered role.
-- Geometry stays role-local so compact frames never inherit primary caps.
local PRIMARY_SHELLS = {
  player = {
    base = MEDIA .. "UnitFramePlayerShellV1",
    rim = MEDIA .. "UnitFramePlayerShellRimV1",
    hover = MEDIA .. "UnitFramePlayerHoverRimV1",
    aggro = MEDIA .. "UnitFramePlayerAggroRimV1",
    geometry = PRIMARY_GEOMETRY,
  },
  target = {
    base = MEDIA .. "UnitFrameTargetShellV1",
    rim = MEDIA .. "UnitFrameTargetShellRimV1",
    hover = MEDIA .. "UnitFrameTargetHoverRimV1",
    aggro = MEDIA .. "UnitFrameTargetAggroRimV1",
    geometry = PRIMARY_GEOMETRY,
  },
  targettarget = {
    base = MEDIA .. "UnitFrameTargetTargetShellV1",
    rim = MEDIA .. "UnitFrameTargetTargetShellRimV1",
    hover = MEDIA .. "UnitFrameTargetTargetHoverRimV1",
    aggro = MEDIA .. "UnitFrameTargetTargetAggroRimV1",
    geometry = TARGETTARGET_GEOMETRY,
  },
  focus = {
    base = MEDIA .. "UnitFrameFocusShellV1",
    rim = MEDIA .. "UnitFrameFocusShellRimV1",
    hover = MEDIA .. "UnitFrameFocusHoverRimV1",
    aggro = MEDIA .. "UnitFrameFocusAggroRimV1",
    geometry = FOCUS_GEOMETRY,
  },
}

local PRIMARY_SLICE_ORDER = {
  "topLeft", "top", "topRight",
  "left", "centre", "right",
  "bottomLeft", "bottom", "bottomRight",
}

local PRIMARY_FRAME_KEYS = {
  "player",
  "target",
  "targettarget",
  "focus",
}

local PORTRAIT_CONFIG_KEYS = {
  "player",
  "target",
  "focus",
  "focustarget",
  "group",
  "grouptarget",
  "grouppet",
  "raid",
  "ttarget",
  "pet",
  "ptarget",
  "fallback",
  "tttarget",
}
local PORTRAIT_CONFIG_COUNT = 13

local PORTRAIT_NIL_BACKUP = "__AEUI_NIL__"
local RAID_MARKER_PORTRAIT_KEY = "raidmarkershowportrait"

local RAID_VARIANTS = {
  "A", "C", "B", "D", "D", "B", "A", "C", "B", "D",
  "C", "A", "C", "A", "D", "B", "A", "D", "B", "C",
  "B", "C", "A", "D", "D", "A", "C", "B", "C", "B",
  "D", "A", "A", "C", "D", "B", "D", "B", "C", "A",
}

local RAID_TEXTURES = {
  A = MEDIA .. "RaidMemberShellAV1",
  B = MEDIA .. "RaidMemberShellBV1",
  C = MEDIA .. "RaidMemberShellCV1",
  D = MEDIA .. "RaidMemberShellDV1",
}

local RAID_HEIGHT = 33
local THIN_VARIANTS = { player = "A", target = "B", targettarget = "C", focus = "D" }
-- Reuse the Raid A2 pixels at their original border thickness on primary frames.
local THIN_GEOMETRY = {
  sourceWidth = 74, sourceHeight = 37,
  textureWidth = 128, textureHeight = 64, -- logical dimensions of the 2x container
  leftCap = 6, centreWidth = 62, rightCap = 6,
  topCap = 6, centreHeight = 25, bottomCap = 6,
  outsetLeft = 2, outsetTop = 2,
}
local RAID_STANDARD_WIDTH = 70
local RAID_ART_HEIGHT = 37
local RAID_LEFT_CAP = 6
local RAID_CENTRE = 62
local RAID_RIGHT_CAP = 6
local RAID_TEXELS_PER_UI = 2
local RAID_TEXTURE_WIDTH = 256
local RAID_TEXTURE_HEIGHT = 128
local RAID_UV_LEFT = RAID_LEFT_CAP * RAID_TEXELS_PER_UI / RAID_TEXTURE_WIDTH
local RAID_UV_RIGHT =
  (RAID_LEFT_CAP + RAID_CENTRE) * RAID_TEXELS_PER_UI /
    RAID_TEXTURE_WIDTH
local RAID_UV_FULL_RIGHT =
  74 * RAID_TEXELS_PER_UI / RAID_TEXTURE_WIDTH
local RAID_UV_BOTTOM =
  RAID_ART_HEIGHT * RAID_TEXELS_PER_UI / RAID_TEXTURE_HEIGHT

local function GetConfiguredTexture(frame, key)
  if not frame or not frame.config or not pfUI or not pfUI.media then
    return nil
  end

  local configured = frame.config[key]
  if configured and pfUI.media[configured] then
    return pfUI.media[configured]
  end
  return pfUI.media["img:bar"]
end

local function CanSetTexture(statusBar)
  return statusBar and type(statusBar.SetStatusBarTexture) == "function"
end

local function RouteOwned(name)
  return
    pfUI and
    pfUI.GetExpeditionComponentOwner and
    pfUI:GetExpeditionComponentOwner(name) == "unitframes"
end

local function ModuleEnabled()
  return
    addon.db and
    addon.db.unitframes and
    addon.db.unitframes.enabled and
    true or false
end

local function PortraitRouteOwned()
  return
    ModuleEnabled() and
    RouteOwned("unitframes.dynamic-portraits")
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

local function ForEachWorldNameplate(callback)
  if not WorldFrame or type(callback) ~= "function" then return 0 end

  local count = 0
  local children = { WorldFrame:GetChildren() }
  for _, parent in pairs(children) do
    local nameplate = parent and parent.nameplate
    if nameplate then
      callback(nameplate)
      count = count + 1
    end
  end
  return count
end

local function RaidIconUsesTopPosition()
  local config = pfUI_config and pfUI_config.nameplates
  local position = config and config.raidiconpos
  return
    type(position) == "string" and
    string.find(string.upper(position), "TOP") and
    true or false
end

local function CaptureRaidBackdropState(frame)
  if frame.aeuiRaidBackdropRestore then return end
  frame.aeuiRaidBackdropRestore = {
    hp = frame.hp and frame.hp.backdrop and FrameShown(frame.hp.backdrop),
    power =
      frame.power and
      frame.power.backdrop and
      FrameShown(frame.power.backdrop),
  }
end

local function HideRaidBackdrops(frame)
  CaptureRaidBackdropState(frame)
  if frame.hp and frame.hp.backdrop then
    frame.hp.backdrop:Hide()
  end
  if frame.power and frame.power.backdrop then
    frame.power.backdrop:Hide()
  end
end

local function RestoreRaidBackdrops(frame)
  local restore = frame.aeuiRaidBackdropRestore
  if not restore then return end
  if frame.hp and frame.hp.backdrop and restore.hp ~= nil then
    SetShown(frame.hp.backdrop, restore.hp)
  end
  if frame.power and frame.power.backdrop and restore.power ~= nil then
    SetShown(frame.power.backdrop, restore.power)
  end
  frame.aeuiRaidBackdropRestore = nil
end

local function EnsureRaidTextures(frame)
  if frame.aeuiRaidShellTextures then
    return frame.aeuiRaidShellTextures
  end
  if type(frame.CreateTexture) ~= "function" then return nil end

  local textures = {
    full = frame:CreateTexture(nil, "BACKGROUND"),
    left = frame:CreateTexture(nil, "BACKGROUND"),
    centre = frame:CreateTexture(nil, "BACKGROUND"),
    right = frame:CreateTexture(nil, "BACKGROUND"),
  }
  frame.aeuiRaidShellTextures = textures
  return textures
end

local function HideRaidTextures(frame)
  local textures = frame and frame.aeuiRaidShellTextures
  if not textures then return end
  for _, texture in pairs(textures) do
    texture:Hide()
  end
end

local function EnsurePrimarySlices(owner, field, layer)
  if not owner or type(owner.CreateTexture) ~= "function" then
    return nil
  end
  if owner[field] then return owner[field] end

  local slices = {}
  for _, name in ipairs(PRIMARY_SLICE_ORDER) do
    slices[name] = owner:CreateTexture(nil, layer or "ARTWORK")
  end
  owner[field] = slices
  return slices
end

local function SetPrimarySlicesShown(slices, shown)
  if not slices then return end
  for _, name in ipairs(PRIMARY_SLICE_ORDER) do
    local texture = slices[name]
    if texture then
      if shown then texture:Show() else texture:Hide() end
    end
  end
end

local function SetPrimarySlicesColour(slices, red, green, blue, alpha)
  if not slices then return end
  for _, name in ipairs(PRIMARY_SLICE_ORDER) do
    local texture = slices[name]
    if texture then
      texture:SetVertexColor(red, green, blue)
      texture:SetAlpha(alpha or 1)
    end
  end
end

local function ConfigurePrimarySlice(texture, path, coords, width, height)
  texture:ClearAllPoints()
  texture:SetTexture(path)
  texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
  texture:SetWidth(width)
  texture:SetHeight(height)
end

local function LayoutPrimarySlices(
  slices, path, frame, artWidth, artHeight, geometry
)
  if not slices or not path or not frame or not geometry then return false end

  local centreWidth = artWidth - geometry.leftCap - geometry.rightCap
  local centreHeight = artHeight - geometry.topCap - geometry.bottomCap
  if centreWidth < 1 or centreHeight < 1 then return false end

  local uvX1 = geometry.leftCap / geometry.textureWidth
  local uvX2 =
    (geometry.leftCap + geometry.centreWidth) / geometry.textureWidth
  local uvXMax = geometry.sourceWidth / geometry.textureWidth
  local uvY1 = geometry.topCap / geometry.textureHeight
  local uvY2 =
    (geometry.topCap + geometry.centreHeight) / geometry.textureHeight
  local uvYMax = geometry.sourceHeight / geometry.textureHeight
  local texCoords = {
    topLeft = { 0, uvX1, 0, uvY1 },
    top = { uvX1, uvX2, 0, uvY1 },
    topRight = { uvX2, uvXMax, 0, uvY1 },
    left = { 0, uvX1, uvY1, uvY2 },
    centre = { uvX1, uvX2, uvY1, uvY2 },
    right = { uvX2, uvXMax, uvY1, uvY2 },
    bottomLeft = { 0, uvX1, uvY2, uvYMax },
    bottom = { uvX1, uvX2, uvY2, uvYMax },
    bottomRight = { uvX2, uvXMax, uvY2, uvYMax },
  }

  ConfigurePrimarySlice(
    slices.topLeft, path, texCoords.topLeft,
    geometry.leftCap, geometry.topCap
  )
  ConfigurePrimarySlice(
    slices.top, path, texCoords.top,
    centreWidth, geometry.topCap
  )
  ConfigurePrimarySlice(
    slices.topRight, path, texCoords.topRight,
    geometry.rightCap, geometry.topCap
  )
  ConfigurePrimarySlice(
    slices.left, path, texCoords.left,
    geometry.leftCap, centreHeight
  )
  ConfigurePrimarySlice(
    slices.centre, path, texCoords.centre,
    centreWidth, centreHeight
  )
  ConfigurePrimarySlice(
    slices.right, path, texCoords.right,
    geometry.rightCap, centreHeight
  )
  ConfigurePrimarySlice(
    slices.bottomLeft, path, texCoords.bottomLeft,
    geometry.leftCap, geometry.bottomCap
  )
  ConfigurePrimarySlice(
    slices.bottom, path, texCoords.bottom,
    centreWidth, geometry.bottomCap
  )
  ConfigurePrimarySlice(
    slices.bottomRight, path, texCoords.bottomRight,
    geometry.rightCap, geometry.bottomCap
  )

  slices.topLeft:SetPoint(
    "TOPLEFT", frame, "TOPLEFT", -geometry.outsetLeft, geometry.outsetTop
  )
  slices.top:SetPoint("LEFT", slices.topLeft, "RIGHT", 0, 0)
  slices.topRight:SetPoint("LEFT", slices.top, "RIGHT", 0, 0)
  slices.left:SetPoint("TOP", slices.topLeft, "BOTTOM", 0, 0)
  slices.centre:SetPoint("LEFT", slices.left, "RIGHT", 0, 0)
  slices.right:SetPoint("LEFT", slices.centre, "RIGHT", 0, 0)
  slices.bottomLeft:SetPoint("TOP", slices.left, "BOTTOM", 0, 0)
  slices.bottom:SetPoint("LEFT", slices.bottomLeft, "RIGHT", 0, 0)
  slices.bottomRight:SetPoint("LEFT", slices.bottom, "RIGHT", 0, 0)
  SetPrimarySlicesShown(slices, true)
  return true
end

local function EnsurePrimaryOverlay(frame)
  if frame.aeuiPrimaryShellOverlay then
    return frame.aeuiPrimaryShellOverlay
  end
  if type(CreateFrame) ~= "function" then return nil end

  local overlay = CreateFrame("Frame", nil, frame)
  overlay:SetAllPoints(frame)
  overlay:SetFrameLevel(10)
  frame.aeuiPrimaryShellOverlay = overlay
  return overlay
end

local function EnsurePlayerV5Overlay(frame)
  if frame.aeuiPlayerV5Overlay then
    return frame.aeuiPlayerV5Overlay
  end
  if type(CreateFrame) ~= "function" then return nil end

  local overlay = CreateFrame("Frame", nil, frame)
  overlay:SetAllPoints(frame)
  overlay:SetFrameLevel(10)
  frame.aeuiPlayerV5Overlay = overlay
  return overlay
end

local function HidePlayerV5Chrome(frame)
  if not frame.aeuiPlayerV5ChromeRestore then
    frame.aeuiPlayerV5ChromeRestore = {
      health = frame.hp and frame.hp.backdrop and
        FrameShown(frame.hp.backdrop) or false,
      power = frame.power and frame.power.backdrop and
        FrameShown(frame.power.backdrop) or false,
      shadow = frame.backdrop_shadow and
        FrameShown(frame.backdrop_shadow) or false,
    }
  end

  if frame.hp and frame.hp.backdrop then frame.hp.backdrop:Hide() end
  if frame.power and frame.power.backdrop then frame.power.backdrop:Hide() end
  if frame.backdrop_shadow then frame.backdrop_shadow:Hide() end
end

local function RestorePlayerV5Chrome(frame)
  local restore = frame and frame.aeuiPlayerV5ChromeRestore
  if not restore then return end

  if frame.hp and frame.hp.backdrop then
    SetShown(frame.hp.backdrop, restore.health)
  end
  if frame.power and frame.power.backdrop then
    SetShown(frame.power.backdrop, restore.power)
  end
  if frame.backdrop_shadow then
    SetShown(frame.backdrop_shadow, restore.shadow)
  end
  frame.aeuiPlayerV5ChromeRestore = nil
end

local function HidePrimaryChrome(frame)
  if frame.hp and frame.hp.backdrop then frame.hp.backdrop:Hide() end
  if frame.power and frame.power.backdrop then frame.power.backdrop:Hide() end

  if frame.backdrop_shadow then
    if frame.aeuiPrimaryShadowRestore == nil then
      frame.aeuiPrimaryShadowRestore = {
        shown = FrameShown(frame.backdrop_shadow),
      }
    end
    frame.backdrop_shadow:Hide()
  end

  if frame.glow and type(frame.glow.SetBackdrop) == "function" then
    frame.glow:SetBackdrop(nil)
    frame.glow:SetFrameStrata("MEDIUM")
    frame.glow:SetFrameLevel(11)
  end
  if frame.hoverglow and type(frame.hoverglow.SetBackdrop) == "function" then
    frame.hoverglow:SetBackdrop(nil)
    frame.hoverglow:SetFrameStrata("MEDIUM")
    frame.hoverglow:SetFrameLevel(12)
  end
end

local function FrameDimension(frame, method, configKey)
  if frame and type(frame[method]) == "function" then
    local value = tonumber(frame[method](frame))
    if value then return value end
  end
  return frame and frame.config and tonumber(frame.config[configKey]) or nil
end

local function Round(value)
  return math.floor(value + 0.5)
end

local function ConfigureTexture(texture, path, left, right)
  texture:SetTexture(path)
  texture:SetTexCoord(left, right, 0, RAID_UV_BOTTOM)
  texture:SetHeight(RAID_ART_HEIGHT)
end

local function DecodePortraitBackup(value)
  if value == PORTRAIT_NIL_BACKUP then return nil end
  return value
end

local function BackupAndDisable(backups, key, config, field, disabledValue)
  if type(backups) ~= "table" or type(config) ~= "table" then
    return false
  end

  local value = config[field]
  if backups[key] == nil or value ~= disabledValue then
    backups[key] = value == nil and PORTRAIT_NIL_BACKUP or value
  end

  if value == disabledValue then return false end
  config[field] = disabledValue
  return true
end

local function RestorePortraitValue(backups, key, config, field)
  if type(backups) ~= "table" or type(config) ~= "table" then
    return false
  end

  local value = backups[key]
  if value == nil then return false end
  config[field] = DecodePortraitBackup(value)
  backups[key] = nil
  return true
end

local function RefreshPortraitFrame(frame)
  if not frame then return false end

  local provider = pfUI and pfUI.uf
  if provider and type(provider.UpdateFrameSize) == "function" then
    pcall(provider.UpdateFrameSize, frame)
  elseif type(frame.UpdateFrameSize) == "function" then
    pcall(frame.UpdateFrameSize, frame)
  end

  if provider and type(provider.UpdateConfig) == "function" then
    pcall(provider.UpdateConfig, frame)
  elseif type(frame.UpdateConfig) == "function" then
    pcall(frame.UpdateConfig, frame)
  end

  if frame.portrait then
    if frame.config and frame.config.portrait == "off" then
      if type(frame.portrait.Hide) == "function" then
        frame.portrait:Hide()
      end
    elseif type(frame.portrait.Show) == "function" then
      frame.portrait:Show()
    end
  end
  return true
end

local function SetMarkerTrackerPortraits(tracker, enabled)
  if not tracker or type(tracker.SetPortraitsEnabled) ~= "function" then
    return false
  end
  return pcall(
    tracker.SetPortraitsEnabled,
    tracker,
    enabled and true or false
  )
end

function UnitFrames:GetPortraitBackupRoot(create)
  local unitframes = addon.db and addon.db.unitframes
  if not unitframes then return nil end
  if create and type(unitframes.portraitConfigBackups) ~= "table" then
    unitframes.portraitConfigBackups = {}
  end
  return unitframes.portraitConfigBackups
end

function UnitFrames:GetPortraitProfileKey()
  local global = pfUI_config and pfUI_config.global
  local profile = global and global.profile
  if profile == nil or profile == "" then return "default" end
  return tostring(profile)
end

function UnitFrames:GetPortraitBackups(create)
  local root = self:GetPortraitBackupRoot(create)
  if type(root) ~= "table" then return nil end

  local profile = self:GetPortraitProfileKey()
  if
    root[profile] == nil and
    (root[RAID_MARKER_PORTRAIT_KEY] ~= nil or
      root[PORTRAIT_CONFIG_KEYS[1]] ~= nil)
  then
    local legacy = {}
    for _, key in ipairs(PORTRAIT_CONFIG_KEYS) do
      if root[key] ~= nil then
        legacy[key] = root[key]
        root[key] = nil
      end
    end
    if root[RAID_MARKER_PORTRAIT_KEY] ~= nil then
      legacy[RAID_MARKER_PORTRAIT_KEY] =
        root[RAID_MARKER_PORTRAIT_KEY]
      root[RAID_MARKER_PORTRAIT_KEY] = nil
    end
    root[profile] = legacy
  end
  if create and type(root[profile]) ~= "table" then
    root[profile] = {}
  end
  return root[profile], root, profile
end

function UnitFrames:GetPortraitConfigKey(config)
  local unitframes = pfUI_config and pfUI_config.unitframes
  if type(config) ~= "table" or type(unitframes) ~= "table" then
    return nil
  end

  for _, key in ipairs(PORTRAIT_CONFIG_KEYS) do
    if unitframes[key] == config then return key end
  end
  return nil
end

function UnitFrames:GuardPortraitFrame(frame)
  if not PortraitRouteOwned() or not frame then return false end

  local key = self:GetPortraitConfigKey(frame.config)
  local backups = self:GetPortraitBackups(true)
  if not key or not backups then return false end

  local changed = BackupAndDisable(
    backups,
    key,
    frame.config,
    "portrait",
    "off"
  )
  if not frame.aeuiPortraitDisabled then changed = true end
  frame.aeuiPortraitDisabled = true
  frame.aeuiUnitFramePortraitContract = self.runtimeContract
  return changed
end

local function ExpeditionPortraitGuard(frame)
  UnitFrames:GuardPortraitFrame(frame)
end

function UnitFrames:InstallPortraitGuard()
  local expedition = pfUI and pfUI.expedition
  if not expedition then return false end
  expedition.unitFramePortraitGuard = ExpeditionPortraitGuard
  return true
end

function UnitFrames:RemovePortraitGuard()
  local expedition = pfUI and pfUI.expedition
  if
    expedition and
    expedition.unitFramePortraitGuard == ExpeditionPortraitGuard
  then
    expedition.unitFramePortraitGuard = nil
    return true
  end
  return false
end

function UnitFrames:ApplyPortraitConfiguration()
  local unitframes = pfUI_config and pfUI_config.unitframes
  local frames = pfUI and pfUI.uf and pfUI.uf.frames
  local backups = self:GetPortraitBackups(true)
  if type(unitframes) ~= "table" or not backups then return false end

  self:InstallPortraitGuard()

  local configurationChanged = false
  local configured = 0
  for _, key in ipairs(PORTRAIT_CONFIG_KEYS) do
    local config = unitframes[key]
    if type(config) == "table" then
      configured = configured + 1
      if BackupAndDisable(backups, key, config, "portrait", "off") then
        configurationChanged = true
      end
    end
  end

  if BackupAndDisable(
    backups,
    RAID_MARKER_PORTRAIT_KEY,
    unitframes,
    RAID_MARKER_PORTRAIT_KEY,
    "0"
  ) then
    configurationChanged = true
  end

  local refreshed = 0
  if type(frames) == "table" then
    for _, frame in pairs(frames) do
      local markerChanged = self:GuardPortraitFrame(frame)
      if configurationChanged or markerChanged then
        if RefreshPortraitFrame(frame) then refreshed = refreshed + 1 end
      end
    end
  end

  local trackers = 0
  if SetMarkerTrackerPortraits(pfUI and pfUI.raidmarkers, false) then
    trackers = trackers + 1
  end
  if SetMarkerTrackerPortraits(pfUI and pfUI.marktracking, false) then
    trackers = trackers + 1
  end

  self.disabledPortraitConfigCount = configured
  self.refreshedPortraitFrameCount = refreshed
  self.disabledPortraitTrackerCount = trackers
  return true
end

function UnitFrames:RestorePortraitConfiguration()
  self:RemovePortraitGuard()

  local unitframes = pfUI_config and pfUI_config.unitframes
  local frames = pfUI and pfUI.uf and pfUI.uf.frames
  local backups, backupRoot, profileKey = self:GetPortraitBackups(false)
  local configurationChanged = false

  if type(unitframes) == "table" and type(backups) == "table" then
    for _, key in ipairs(PORTRAIT_CONFIG_KEYS) do
      if RestorePortraitValue(
        backups,
        key,
        unitframes[key],
        "portrait"
      ) then
        configurationChanged = true
      end
    end
    if RestorePortraitValue(
      backups,
      RAID_MARKER_PORTRAIT_KEY,
      unitframes,
      RAID_MARKER_PORTRAIT_KEY
    ) then
      configurationChanged = true
    end
    if backupRoot then backupRoot[profileKey] = nil end
  end

  local refreshed = 0
  if type(frames) == "table" then
    for _, frame in pairs(frames) do
      local markerChanged =
        frame.aeuiPortraitDisabled or
        frame.aeuiUnitFramePortraitContract
      frame.aeuiPortraitDisabled = nil
      frame.aeuiUnitFramePortraitContract = nil
      if configurationChanged or markerChanged then
        if RefreshPortraitFrame(frame) then refreshed = refreshed + 1 end
      end
    end
  end

  if type(unitframes) == "table" then
    local markerPortraitsEnabled =
      unitframes[RAID_MARKER_PORTRAIT_KEY] ~= "0"
    SetMarkerTrackerPortraits(
      pfUI and pfUI.raidmarkers,
      markerPortraitsEnabled
    )
    SetMarkerTrackerPortraits(
      pfUI and pfUI.marktracking,
      markerPortraitsEnabled
    )
  end

  self.disabledPortraitConfigCount = 0
  self.refreshedPortraitFrameCount = refreshed
  self.disabledPortraitTrackerCount = 0
  return true
end

function UnitFrames:IsPortraitConfigurationEnabled()
  return PortraitRouteOwned()
end

-- Saved per character; provider configuration remains untouched for fallback.
function UnitFrames:GetNameplateProfile()
  if not addon.db or not addon.db.unitframes then return end
  local name, realm = UnitName("player"), GetRealmName()
  if not name or name == "" or not realm or realm == "" then return end
  local config = addon.db.unitframes
  config.nameplateProfiles = config.nameplateProfiles or {}
  local key = name .. " - " .. realm
  local profile = config.nameplateProfiles[key]
  if type(profile) ~= "table" then
    profile = { mode = "dps" }
    config.nameplateProfiles[key] = profile
  end
  if profile.mode ~= "tank" and profile.mode ~= "healer" and
    profile.mode ~= "dps" and profile.mode ~= "off" then
    profile.mode = "dps"
  end
  return profile
end

local NAMEPLATE_ROLE_COLOURS = {
  neutral = { 54/255, 191/255, 224/255 },
  safe = { .38, .62, .48 },
  tank = { .42, .58, .75 },
  danger = { 1, .32, .12 },
  warning = { 1, .72, .18 },
}

-- ponytail: explicit enUS/zhCN control/immunity names; extend with verified effects.
-- This list does not classify dangerous casts.
local NAMEPLATE_IMPORTANT_AURAS = {
  ["Polymorph"] = true, ["变形术"] = true,
  ["Banish"] = true, ["放逐术"] = true,
  ["Shackle Undead"] = true, ["束缚亡灵"] = true,
  ["Hibernate"] = true, ["休眠"] = true,
  ["Sap"] = true, ["闷棍"] = true,
  ["Freezing Trap Effect"] = true, ["冰冻陷阱效果"] = true,
  ["Fear"] = true, ["恐惧术"] = true,
  ["Psychic Scream"] = true, ["心灵尖啸"] = true,
  ["Blind"] = true, ["致盲"] = true,
  ["Kidney Shot"] = true, ["肾击"] = true,
  ["Hammer of Justice"] = true, ["制裁之锤"] = true,
  ["Ice Block"] = true, ["寒冰屏障"] = true,
  ["Divine Shield"] = true, ["圣盾术"] = true,
  ["Blessing of Protection"] = true, ["保护祝福"] = true,
}

-- TWT is an asynchronous target-only snapshot; TMT is GUID-keyed runner-up data.
-- Never persist either across sessions or infer zero threat from missing rows.
local function ThreatGUID(value)
  if type(value) ~= "string" then return nil end
  value = string.lower(value)
  local _, _, hex = string.find(value, "^0x(%x+)$")
  if not hex then
    if not string.find(value, "^%d+$") or string.len(value) > 20 then return nil end
    hex = ""
    while value ~= "" do
      local quotient, remainder = "", 0
      for i = 1, string.len(value) do
        local digit = remainder * 10 + tonumber(string.sub(value, i, i))
        local q = math.floor(digit / 16)
        if quotient ~= "" or q > 0 then quotient = quotient .. q end
        remainder = math.mod(digit, 16)
      end
      hex = string.sub("0123456789abcdef", remainder + 1, remainder + 1) .. hex
      value = quotient
    end
  end
  hex = string.gsub(hex, "^0+", "")
  if hex == "" or string.len(hex) > 16 then return nil end
  return hex
end

local function ThreatNumber(value)
  local n = tonumber(value)
  if n and n >= 0 and n < math.huge then return n end
end

function UnitFrames:ClearNameplateThreat()
  self.threatSnapshot, self.threatPending = nil, nil
  self.threatNext = GetTime() + 1.5
end

function UnitFrames:ReceiveNameplateThreat(prefix, message, channel, sender)
  local pending, now = self.threatPending, GetTime()
  -- Match the TWT envelope used by ShaguDPS; reply prefixes need not be exactly TWT.
  if type(prefix) ~= "string" or not string.find(prefix, "TWT", 1, true) or
    type(message) ~= "string" or string.len(message) > 16384 then return end
  local start = string.find(message, "TWTv4=", 1, true)
  if not start then return end
  self.threatSeen = (self.threatSeen or 0) + 1
  self.threatEnvelope = prefix .. "/" .. tostring(channel) .. "/" .. tostring(sender)
  if not self.nameplateMode or not pending or now - pending.time > 1 or
    (channel ~= pending.channel and channel ~= "WHISPER") or sender ~= UnitName("player") then return end
  local _, guid = UnitExists("target")
  if guid ~= pending.guid or not UnitAffectingCombat("player") then return end
  local _, _, detail, group = string.find(string.sub(message, start), "^TWTv4=([^#]*)#?(.*)$")
  if not detail then return end
  local rows, holder = {}, nil
  for row in string.gfind(detail, "[^;]+") do
    local _, _, name, tank, raw, pct, melee = string.find(row, "^([^:]+):([01]):([^:]+):([^:]+):([01])$")
    raw, pct = ThreatNumber(raw), ThreatNumber(pct)
    if not name or not raw or not pct or rows[name] then return end
    rows[name] = {value=raw, percent=pct, tank=tank == "1", melee=melee == "1"}
    if tank == "1" then
      if holder then return end
      holder = name
    end
  end
  -- ponytail: no request ID/GUID in TWT; quarantine and victim check reduce
  -- late-reply ambiguity. Exact correlation requires a server protocol change.
  if not holder or holder ~= UnitName("targettarget") then return end
  local mobs = {}
  if pending.mode == "tank" and string.sub(group, 1, 6) == "TMTv1=" then
    for row in string.gfind(string.sub(group, 7), "[^;]+") do
      local _, _, creature, mob, name, pct = string.find(row, "^([^:]+):([^:]+):([^:]+):([^:]+)$")
      mob, pct = ThreatGUID(mob), ThreatNumber(pct)
      if mob and pct and not mobs[mob] then mobs[mob] = {name=name, percent=pct} end
    end
  end
  self.threatSnapshot = {guid=ThreatGUID(guid), time=now, rows=rows, mobs=mobs, holder=holder}
  self.threatPending = nil
  self.threatReceived = (self.threatReceived or 0) + 1
end

function UnitFrames:UpdateNameplateThreat()
  local now = GetTime()
  if self.threatMockStart or not self.nameplateMode or not UnitAffectingCombat("player") then
    self.threatSnapshot, self.threatPending = nil, nil
    return
  end
  if now < (self.threatNext or 0) then return end
  self.threatNext = now + .5
  if self.threatPending and now - self.threatPending.time <= 1 then return end
  self.threatPending = nil
  local exists, guid = UnitExists("target")
  local raid, party = GetNumRaidMembers(), GetNumPartyMembers()
  if not exists or not ThreatGUID(guid) or UnitIsPlayer("target") or UnitIsDead("target") or
    not UnitCanAttack("player", "target") or (raid == 0 and party == 0) then return end
  local channel = raid > 0 and "RAID" or "PARTY"
  self.threatPending = {guid=guid, time=now, channel=channel, mode=self.nameplateMode}
  SendAddonMessage("TWT_UDTSv4" .. (self.nameplateMode == "tank" and "_TM" or ""), "limit=40", channel)
end

function UnitFrames:EnsureNameplateThreat()
  if self.threatFrame then return end
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("CHAT_MSG_ADDON")
  frame:RegisterEvent("PLAYER_TARGET_CHANGED")
  frame:RegisterEvent("PLAYER_REGEN_ENABLED")
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  -- 名单刷新不改变当前目标；重置隔离期会让频繁团队更新饿死请求。
  frame:SetScript("OnEvent", function()
    if event == "CHAT_MSG_ADDON" then
      UnitFrames:ReceiveNameplateThreat(arg1, arg2, arg3, arg4)
    else
      UnitFrames:ClearNameplateThreat()
    end
  end)
  frame:SetScript("OnUpdate", function() UnitFrames:UpdateNameplateThreat() end)
  self.threatFrame = frame
end

function UnitFrames:GetNameplateThreatRisk(guid, victim)
  local snapshot = self.threatSnapshot
  if not snapshot or GetTime() - snapshot.time > 2 or not UnitAffectingCombat("player") then return end
  guid = ThreatGUID(guid)
  if not guid then return end
  local mode, me = self.nameplateMode, UnitName("player")
  if mode == "tank" and victim == "self" then
    local mob = snapshot.mobs[guid]
    if mob then return mob.percent >= 85 and "danger" or mob.percent >= 70 and "warning" or nil, mob.percent end
  end
  local _, current = UnitExists("target")
  if guid ~= snapshot.guid or guid ~= ThreatGUID(current) then return end
  local own, tank = snapshot.rows[me], snapshot.rows[snapshot.holder]
  if not own or not tank or tank.value <= 0 then return end
  if mode == "tank" then
    if victim ~= "self" or not own.tank then return end
    local ratio = 0
    for name, row in pairs(snapshot.rows) do
      if name ~= me then ratio = math.max(ratio, row.value / tank.value * 100) end
    end
    return ratio >= 85 and "danger" or ratio >= 70 and "warning" or nil, ratio
  elseif mode == "dps" or mode == "healer" then
    local ratio = own.value / tank.value * 100
    return ratio >= 85 and "danger" or ratio >= 70 and "warning" or nil, ratio
  end
end

function UnitFrames:GetNameplateStyle(mode, friendly, target, threat, guid)
  local colour
  if not friendly then
    if mode == "tank" then
      colour = threat == "self" and NAMEPLATE_ROLE_COLOURS.safe or
        threat == "tank" and NAMEPLATE_ROLE_COLOURS.tank or
        threat == "other" and NAMEPLATE_ROLE_COLOURS.danger or nil
    elseif mode == "healer" or mode == "dps" then
      colour = threat == "self" and NAMEPLATE_ROLE_COLOURS.danger or NAMEPLATE_ROLE_COLOURS.neutral
    end
  end
  local baseColour = colour
  local risk, ratio
  if not friendly then
    if self.threatMockStart and target then
      -- Local preview only: 12 seconds to full, hold 2 seconds, then repeat.
      ratio = math.min(100, math.mod(GetTime() - self.threatMockStart, 14) / 12 * 100)
      risk = ratio >= 85 and "danger" or ratio >= 70 and "warning" or nil
      baseColour = mode == "tank" and NAMEPLATE_ROLE_COLOURS.safe or NAMEPLATE_ROLE_COLOURS.neutral
      colour = baseColour
    else
      risk, ratio = self:GetNameplateThreatRisk(guid, threat)
    end
  end
  if risk then colour = NAMEPLATE_ROLE_COLOURS[risk] end
  local alpha = target and 1 or friendly and .65 or
    colour == NAMEPLATE_ROLE_COLOURS.danger and 1 or
    colour == NAMEPLATE_ROLE_COLOURS.warning and .9 or
    (mode == "healer" or mode == "dps") and .75 or .85
  -- Interpolate RGB by the latest ratio; alpha still uses the discrete risk tier.
  if baseColour and ratio and ratio > 50 and ratio < 85 then
    local from = ratio < 70 and baseColour or NAMEPLATE_ROLE_COLOURS.warning
    local to = ratio < 70 and NAMEPLATE_ROLE_COLOURS.warning or NAMEPLATE_ROLE_COLOURS.danger
    local fraction = ratio < 70 and (ratio - 50) / 20 or (ratio - 70) / 15
    colour = {
      from[1] + (to[1] - from[1]) * fraction,
      from[2] + (to[2] - from[2]) * fraction,
      from[3] + (to[3] - from[3]) * fraction,
    }
  end
  local limit = friendly and (target and 4 or 0) or (target and 6 or 2)
  return alpha, colour, limit, ratio
end

function UnitFrames:GetNameplateAuraPriority(friendly, target, kind, name, caster)
  if friendly then return target and (kind == "debuff" and 1 or 2) or nil end
  if NAMEPLATE_IMPORTANT_AURAS[name] then return 1 end
  if target and kind == "debuff" and caster == "player" then return 2 end
end

function UnitFrames:ApplyNameplateMode()
  local profile = self:GetNameplateProfile()
  local provider = pfUI and pfUI.nameplates
  local mode = profile and profile.mode
  if not ModuleEnabled() or not RouteOwned("unitframes.nameplate-combat-mode") or mode == "off" then
    mode = nil
  end
  if self.nameplateMode ~= mode then self:ClearNameplateThreat() end
  self.nameplateMode = mode
  if not mode then self.threatMockStart = nil end
  self:EnsureNameplateThreat()
  if mode then self.threatFrame:Show() else self.threatFrame:Hide() end
  if provider and provider.SetCombatMode then
    provider:SetCombatMode(mode, self)
  end
end

function UnitFrames:SetNameplateMode(mode)
  if mode == "mock" or mode == "mock off" then
    if mode == "mock" and not self.nameplateMode then
      addon:Print("请先 /aeui plates dps 启用姓名板职责，再 /aeui plates mock。")
      return false
    end
    self.threatMockStart = mode == "mock" and GetTime() or nil
    self:ClearNameplateThreat()
    addon:Print(self.threatMockStart and
      "仇恨 MOCK 已开启：选中敌方目标，12 秒从 0% 增至 100%，停留 2 秒后循环；非真实仇恨。/aeui plates mock off 关闭，重载自动清除。" or
      "仇恨 MOCK 已关闭，恢复真实数据。")
    return true
  end
  if mode ~= "tank" and mode ~= "healer" and mode ~= "dps" and mode ~= "off" then
    addon:Print("/aeui plates tank | healer | dps | off | status | mock | mock off")
    return false
  end
  local profile = self:GetNameplateProfile()
  if not profile then return false end
  profile.mode = mode
  self:ApplyNameplateMode()
  self:ApplyNameplateTargetCue()
  if pfUI and pfUI.gui and pfUI.gui.RefreshConfigVisibility then
    pfUI.gui:RefreshConfigVisibility()
  end
  addon:Print(self:GetNameplateModeStatus())
  return true
end

function UnitFrames:GetNameplateModeStatus()
  local profile = self:GetNameplateProfile()
  local provider = pfUI and pfUI.nameplates
  return "plates saved=" .. tostring(profile and profile.mode or "unavailable") ..
    ", active=" .. tostring(provider and provider.combatMode or "off") ..
    ", provider=" .. tostring(provider and provider.SetCombatMode ~= nil or false) ..
    ", threat-packets=" .. tostring(self.threatReceived or 0) ..
    "/" .. tostring(self.threatSeen or 0) ..
    ", threat-source=" .. tostring(self.threatEnvelope or "none") ..
    ", threat-mock=" .. (self.threatMockStart and "ON (not real threat)" or "off")
end

function UnitFrames:IsNameplateTargetCueEnabled()
  local profile = self:GetNameplateProfile()
  return
    profile and profile.mode ~= "off" and
    ModuleEnabled() and
    RouteOwned(NAMEPLATE_TARGET_CUE.route)
end

function UnitFrames:EnsureNameplateTargetCue(nameplate)
  if not nameplate then return nil end

  local holder = nameplate.aeuiTargetCueFrame
  if not holder then
    holder = CreateFrame("Frame", nil, nameplate)
    holder:SetWidth(NAMEPLATE_TARGET_CUE.width)
    holder:SetHeight(NAMEPLATE_TARGET_CUE.height)
    holder:SetFrameLevel(nameplate:GetFrameLevel() + 9)
    holder:EnableMouse(false)

    holder.texture = holder:CreateTexture(nil, "OVERLAY")
    holder.texture:SetAllPoints(holder)
    holder.brackets = CreateFrame("Frame", nil, holder)
    holder.brackets:SetAllPoints(nameplate.health)
    holder.brackets:EnableMouse(false)
    for _, side in ipairs({ "LEFT", "RIGHT" }) do
      local clasp = holder.brackets:CreateTexture(nil, "OVERLAY")
      holder.brackets[side] = clasp
      clasp:SetTexture(MEDIA .. "NameplateTargetClasp" .. side .. "V2")
      clasp:SetTexCoord(6 / 32, 26 / 32, 12 / 64, 52 / 64)
      clasp:SetWidth(10)
      clasp:SetHeight(20)
      clasp:SetVertexColor(.82, .78, .70)
      clasp:SetPoint(side == "LEFT" and "RIGHT" or "LEFT", nameplate.health,
        side, side == "LEFT" and -1 or 1, 0)
    end
    nameplate.aeuiTargetCueFrame = holder
  end

  if holder.aeuiTargetCueContract ~= self.runtimeContract then
    holder.texture:SetTexture(NAMEPLATE_TARGET_CUE.texture)
    holder.texture:SetTexCoord(
      NAMEPLATE_TARGET_CUE.u1,
      NAMEPLATE_TARGET_CUE.u2,
      NAMEPLATE_TARGET_CUE.v1,
      NAMEPLATE_TARGET_CUE.v2
    )
    holder.aeuiTargetCueContract = self.runtimeContract
  end
  return holder
end

function UnitFrames:LayoutNameplateTargetCue(nameplate, holder)
  if not nameplate or not holder or not nameplate.name then return false end

  local bounds = nameplate.health.aeuiIdentityBounds or nameplate.health
  local claspHeight = nameplate.health:GetHeight() + 2 +
    (FrameShown(nameplate.threatRail) and 8 or 0)
  if holder.aeuiClaspHeight ~= claspHeight then
    holder.brackets.LEFT:SetHeight(claspHeight)
    holder.brackets.RIGHT:SetHeight(claspHeight)
    holder.aeuiClaspHeight = claspHeight
  end
  if holder.aeuiClaspAnchor ~= bounds then
    holder.brackets:ClearAllPoints()
    holder.brackets:SetAllPoints(bounds)
    for _, side in ipairs({ "LEFT", "RIGHT" }) do
      local clasp = holder.brackets[side]
      clasp:ClearAllPoints()
      clasp:SetPoint(side == "LEFT" and "RIGHT" or "LEFT", bounds, side,
        side == "LEFT" and -1 or 1, 0)
    end
    holder.aeuiClaspAnchor = bounds
  end

  local raidIcon = nameplate.raidicon
  local stackAboveRaid =
    raidIcon and
    FrameShown(raidIcon) and
    RaidIconUsesTopPosition()
  local anchorKey = stackAboveRaid and "raid" or "name"

  if holder.aeuiTargetCueAnchor ~= anchorKey then
    holder:ClearAllPoints()
    if stackAboveRaid then
      holder:SetPoint(
        "BOTTOM",
        raidIcon,
        "TOP",
        0,
        NAMEPLATE_TARGET_CUE.raidGap
      )
    else
      holder:SetPoint(
        "BOTTOM",
        nameplate.name,
        "TOP",
        0,
        NAMEPLATE_TARGET_CUE.nameGap
      )
    end
    holder.aeuiTargetCueAnchor = anchorKey
  end
  return true
end

-- Only selection/visibility transitions move the level; provider layout uses
-- the same gap when it rebuilds the health/name layout.
function UnitFrames:SetNameplateClaspState(nameplate, shown)
  local holder = nameplate.aeuiTargetCueFrame
  if holder and holder.brackets and holder.aeuiClaspsVisible ~= shown then
    SetShown(holder.brackets, shown)
    holder.aeuiClaspsVisible = shown
  end
  local inset = nameplate.aeuiIdentity and nameplate.aeuiIdentity.active
  local gap = not inset and shown and 14 or nil
  if nameplate.aeuiTargetLevelGap ~= gap then
    nameplate.aeuiTargetLevelGap = gap
    if not inset and nameplate.level and FrameShown(nameplate.health) then
      nameplate.level:SetPoint("RIGHT", nameplate.health, "LEFT", -(gap or 5), 0)
    end
  end
end

function UnitFrames:RestoreNameplateTargetCue(nameplate)
  if nameplate then self:SetNameplateClaspState(nameplate, false) end
  local holder = nameplate and nameplate.aeuiTargetCueFrame
  if not holder then return false end

  if holder.aeuiTargetCueVisible ~= false then
    holder:Hide()
    holder.aeuiTargetCueVisible = false
  end
  if holder.aeuiTargetCueContract then
    holder.texture:SetTexture(nil)
    holder.aeuiTargetCueContract = nil
  end
  return true
end

function UnitFrames:RefreshNameplateTargetCue(nameplate)
  if not nameplate then return false end
  if not self.nameplateTargetCueActive then
    return self:RestoreNameplateTargetCue(nameplate)
  end

  local holder = self:EnsureNameplateTargetCue(nameplate)
  if not holder then return false end
  self:LayoutNameplateTargetCue(nameplate, holder)

  local shown =
    nameplate.istarget and
    FrameShown(nameplate.name) and
    not FrameShown(nameplate.totem) and
    true or false
  self:SetNameplateClaspState(nameplate, shown and FrameShown(nameplate.health) or false)
  if holder.aeuiTargetCueVisible ~= shown then
    SetShown(holder, shown)
    holder.aeuiTargetCueVisible = shown
    if nameplate.aeuiDetailsLayout then nameplate.aeuiDetailsLayout() end
  end
  return true
end

-- Keep adjacent provider information on the full identity strip, not its inset fill.
local function ReanchorNameplateDetails(plate, from, to)
  local function move(object)
    if not object or not object.GetNumPoints then return end
    for i = 1, object:GetNumPoints() do
      local point, relative, relativePoint, x, y = object:GetPoint(i)
      if relative == from then object:SetPoint(point, to, relativePoint, x, y) end
    end
  end
  move(plate.castbar)
  move(plate.raidicon)
  move(plate.guild)
  move(plate.glow)
  move(plate.debuffs and plate.debuffs[1])
  for _, object in ipairs(plate.combopoints or {}) do move(object) end
end

function UnitFrames:RestoreNameplateIdentity(plate)
  local art = plate and plate.aeuiIdentity
  if not art or not art.active then return end
  local health = plate.health
  ReanchorNameplateDetails(plate, art.bounds, health)
  health:ClearAllPoints()
  health:SetPoint(unpack(art.healthPoint))
  health:SetWidth(art.healthWidth)
  health.text:SetJustifyH(art.justify)
  if art.levelParent then plate.level:SetParent(art.levelParent) end
  if art.levelFont then plate.level:SetFont(unpack(art.levelFont)) end
  plate.level:ClearAllPoints()
  if plate.namesOnly then plate.level:SetPoint("RIGHT", plate.name, "LEFT", -3, 0)
  else plate.level:SetPoint(unpack(art.levelPoint)) end
  health.aeuiIdentityBounds, health.aeuiIdentityWidth = nil, nil
  art.bounds:Hide()
  art.active, art.layout, art.readoutWidth, art.measureKey = false, nil, nil, nil
  if health.aeuiNameplateChrome and health.aeuiNameplateChrome.active then
    self:SetNameplateHealthBorder(health, true)
  end
end

function UnitFrames:RefreshNameplateIdentity(plate)
  if not plate or not plate.health or not plate.level or not plate.name then return end
  local profile = self:GetNameplateProfile()
  local enabled = profile and profile.mode ~= "off" and ModuleEnabled() and
    RouteOwned("unitframes.nameplate-health-fill")
  local health = plate.health
  if not enabled or plate.namesOnly or not FrameShown(health) or FrameShown(plate.totem) then
    self:RestoreNameplateIdentity(plate)
    return
  end
  local art = plate.aeuiIdentity
  if not art then
    art = { names = {}, caps = {} }
    art.measure = health:CreateFontString(nil, "OVERLAY")
    art.measure:Hide()
    art.bounds = CreateFrame("Frame", nil, health)
    art.bounds:SetFrameLevel(health:GetFrameLevel())
    art.bounds:EnableMouse(false)
    art.bed = art.bounds:CreateTexture(nil, "BACKGROUND")
    art.bed:SetTexture(.10, .075, .05, 1)
    art.divider = art.bounds:CreateTexture(nil, "ARTWORK")
    art.divider:SetTexture(MEDIA .. "NameplateIdentityDividerV1")
    art.divider:SetTexCoord(0, 4/8, 4/32, 23/32)
    art.divider:SetWidth(3)
    art.divider:SetHeight(16)
    for _, side in ipairs({ "LEFT", "RIGHT" }) do
      local cap = art.bounds:CreateTexture(nil, "ARTWORK")
      cap:SetTexture(MEDIA .. "NameplateIdentityCap" .. side .. "V1")
      cap:SetTexCoord(0, 16/32, 0, 40/64)
      cap:SetWidth(8)
      cap:SetHeight(20)
      cap:SetPoint(side == "LEFT" and "RIGHT" or "LEFT", art.bounds, side, 0, 0)
      art.caps[side] = cap
    end
    local edges = { 0, 12, 116, 128 }
    for i = 1, 3 do
      local backing = art.bounds:CreateTexture(nil, "BACKGROUND")
      backing:SetTexture(MEDIA .. "NameplateIdentityNameV1")
      backing:SetTexCoord(edges[i]/128, edges[i+1]/128, 0, 20/32)
      backing:SetHeight(10)
      art.names[i] = backing
    end
    plate.aeuiIdentity = art
  end
  if not art.active then
    art.healthPoint, art.levelPoint = { health:GetPoint() }, { plate.level:GetPoint() }
    art.healthWidth, art.justify = health:GetWidth(), health.text:GetJustifyH()
    art.levelParent = plate.level:GetParent()
    art.levelFont = { plate.level:GetFont() }
    plate.level:SetFont(art.levelFont[1], art.levelFont[2] * .85, art.levelFont[3])
    plate.level:SetParent(health)
    art.active = true
  end
  local levelWidth = math.max(12, plate.level:GetStringWidth() + 4)
  local inset = levelWidth + 5
  local font, size, flags = health.text:GetFont()
  local text = health.text:GetText() or ""
  local measureKey = font .. ":" .. size .. ":" .. tostring(flags) .. ":" .. text
  if art.measureKey ~= measureKey then
    art.measure:SetFont(font, size, flags)
    art.measure:SetText(text)
    -- Measure an unbounded copy, since the visible FontString can be ellipsized.
    -- Keep the widest reading this activation to avoid width jitter each tick.
    art.readoutWidth = math.max(art.readoutWidth or 0, art.measure:GetStringWidth())
    art.measureKey = measureKey
  end
  local fullWidth = math.max(art.healthWidth, inset + math.max(40, (art.readoutWidth or 0) + 12))
  local nameWidth = math.max(16, plate.name:GetStringWidth() + 12)
  local nameHeight = math.max(10, plate.name:GetHeight() + 6)
  local extra = FrameShown(plate.threatRail) and 8 or 0
  if plate.threatRail and not plate.threatRail.aeuiFill then
    local rail = plate.threatRail
    rail:SetStatusBarTexture(addon.media.root .. "ActionBars\\Readouts\\CastFillV1")
    local fill = rail:GetStatusBarTexture()
    if type(fill) == "table" or type(fill) == "userdata" then fill:SetDrawLayer("ARTWORK") end
    rail.aeuiFill = true
  end
  local key = fullWidth .. ":" .. levelWidth .. ":" .. nameWidth .. ":" .. nameHeight .. ":" .. extra
  if art.layout ~= key then
    health:ClearAllPoints()
    health:SetPoint("TOP", plate.name, "BOTTOM", inset / 2, -4)
    health:SetWidth(fullWidth - inset)
    art.bounds:ClearAllPoints()
    art.bounds:SetPoint("TOPLEFT", health, "TOPLEFT", -inset, 0)
    art.bounds:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", 0, -extra)
    art.bed:ClearAllPoints()
    art.bed:SetPoint("TOPLEFT", art.bounds, "TOPLEFT", 0, 0)
    art.bed:SetPoint("BOTTOMRIGHT", health, "BOTTOMLEFT", 0, -extra)
    art.divider:ClearAllPoints()
    art.divider:SetPoint("CENTER", art.bounds, "LEFT", levelWidth + 1.5, 0)
    art.divider:SetHeight(16 + extra)
    for _, cap in pairs(art.caps) do cap:SetHeight(health:GetHeight() + extra + 2) end
    plate.level:ClearAllPoints()
    plate.level:SetPoint("CENTER", art.bounds, "LEFT", levelWidth / 2, extra / 2)
    health.text:SetJustifyH("CENTER")
    local widths = { 6, nameWidth - 12, 6 }
    for i = 1, 3 do
      local backing = art.names[i]
      backing:ClearAllPoints()
      backing:SetWidth(widths[i])
      backing:SetHeight(nameHeight)
      if i == 1 then backing:SetPoint("BOTTOMLEFT", plate.name, "BOTTOM", -nameWidth/2, -3)
      else backing:SetPoint("BOTTOMLEFT", art.names[i-1], "BOTTOMRIGHT", 0, 0) end
    end
    health.aeuiIdentityBounds, health.aeuiIdentityWidth = art.bounds, fullWidth
    ReanchorNameplateDetails(plate, health, art.bounds)
    art.layout = key
    if health.aeuiNameplateChrome and health.aeuiNameplateChrome.active then
      self:SetNameplateHealthBorder(health, true)
    end
  end
  art.bounds:Show()
end

function UnitFrames:GetNameplateHealthHeight()
  if ModuleEnabled() and RouteOwned("unitframes.nameplate-health-fill") then return 18 end
end

function UnitFrames:GetNameplateHealthColour(r, g, b, a)
  if not self:GetNameplateHealthHeight() then return r, g, b, a end
  local peak = math.max(r, g, b)
  if peak > 0 and peak < .65 then
    local gain = .65 / peak
    return r * gain, g * gain, b * gain, a
  elseif peak == 0 then
    return .45, .45, .45, a
  end
  return r, g, b, a
end

function UnitFrames:SetNameplateHealthBorder(health, enabled)
  local chrome = health.aeuiNameplateChrome
  if enabled and health.backdrop then
    if not chrome then
      chrome = { bed = health:CreateTexture(nil, "BACKGROUND") }
      chrome.bed:SetAllPoints(health)
      health.aeuiNameplateChrome = chrome
    end
    if not chrome.active then
      chrome.backdrop = FrameShown(health.backdrop)
      chrome.shadow = FrameShown(health.backdrop_shadow)
    end
    -- Opaque empty-health bed and the accepted cast-rail's 1 UI leather rim.
    chrome.bed:SetTexture(.10, .075, .05, 1)
    chrome.rim = EnsurePrimarySlices(health, "aeuiNameplateRim", "BACKGROUND")
    local anchor = health.aeuiIdentityBounds or health
    if chrome.anchor ~= anchor then
      -- Match the player's readout shell: both ends of every slice follow
      -- the live StatusBar bounds, even when hidden frames finish layout later.
      local u, v = {0, 4/512, 258/512, 262/512}, {0, 1/16, 13/16, 14/16}
      local x, y = {-1, 3, -3, 1}, {1, 0, 0, -1}
      local names = { {"topLeft","top","topRight"}, {"left","centre","right"}, {"bottomLeft","bottom","bottomRight"} }
      for row = 1, 3 do
        for column = 1, 3 do
          local texture = chrome.rim[names[row][column]]
          texture:ClearAllPoints()
          texture:SetTexture(addon.media.root .. "ActionBars\\Readouts\\ReadoutShellV1")
          texture:SetTexCoord(u[column],u[column+1],v[row],v[row+1])
          texture:SetPoint("TOPLEFT", anchor,
            (row <= 2 and "TOP" or "BOTTOM") .. (column <= 2 and "LEFT" or "RIGHT"), x[column],y[row])
          texture:SetPoint("BOTTOMRIGHT", anchor,
            (row+1 <= 2 and "TOP" or "BOTTOM") .. (column+1 <= 2 and "LEFT" or "RIGHT"), x[column+1],y[row+1])
        end
      end
      chrome.anchor = anchor
    end
    SetPrimarySlicesShown(chrome.rim, true)
    chrome.bed:Show()
    health.backdrop:Hide()
    SetShown(health.backdrop_shadow, false)
    chrome.active = true
  elseif chrome and chrome.active then
    chrome.bed:Hide()
    SetPrimarySlicesShown(chrome.rim, false)
    SetShown(health.backdrop, chrome.backdrop)
    SetShown(health.backdrop_shadow, chrome.shadow)
    chrome.active = false
  end
end

function UnitFrames:ApplyNameplateHealthFill(nameplate)
  local profile = self:GetNameplateProfile()
  local enabled = profile and profile.mode ~= "off" and ModuleEnabled() and
    RouteOwned("unitframes.nameplate-health-fill")
  return self:SetNameplateBarFill(nameplate and nameplate.health, enabled)
end

function UnitFrames:SetNameplateBarFill(health, enabled)
  if not CanSetTexture(health) then return false end
  local path = addon.media.root .. "ActionBars\\Readouts\\CastFillV1"
  local texture = health.GetStatusBarTexture and health:GetStatusBarTexture()
  local current = type(texture) == "string" and texture or
    (texture and texture.GetTexture and texture:GetTexture())
  if enabled then
    if current ~= path then
      -- Config changes supply a fresh provider texture before this hook runs.
      if not current then return false end
      health.aeuiNameplateHealthTexture = current
      health:SetStatusBarTexture(path)
    end
    -- Native StatusBars may expose their fill on BACKGROUND. Our opaque bed
    -- must never cover that fill; leave UVs and progress clipping to StatusBar.
    local fill = health:GetStatusBarTexture()
    if type(fill) ~= "string" and fill and fill.GetDrawLayer and fill.SetDrawLayer then
      if not health.aeuiNameplateFillLayer then
        health.aeuiNameplateFillLayer = fill:GetDrawLayer()
      end
      fill:SetDrawLayer("ARTWORK")
    end
    self:SetNameplateHealthBorder(health, true)
    return true
  elseif health.aeuiNameplateHealthTexture then
    health:SetStatusBarTexture(current and current ~= path and current or health.aeuiNameplateHealthTexture)
    health.aeuiNameplateHealthTexture = nil
  end
  if health.aeuiNameplateFillLayer then
    local fill = health:GetStatusBarTexture()
    if type(fill) ~= "string" and fill and fill.SetDrawLayer then
      fill:SetDrawLayer(health.aeuiNameplateFillLayer)
    end
    health.aeuiNameplateFillLayer = nil
  end
  self:SetNameplateHealthBorder(health, false)
  return false
end

function UnitFrames:InstallNameplateTargetCueHooks()
  local provider = pfUI and pfUI.nameplates
  if not provider then return false end
  if provider.aeuiTargetCueHooksInstalled then return true end
  if
    type(provider.OnCreate) ~= "function" or
    type(provider.OnConfigChange) ~= "function" or
    type(provider.OnUpdate) ~= "function"
  then
    return false
  end

  local originalOnDataChanged = provider.OnDataChanged
  if type(originalOnDataChanged) == "function" then
    provider.OnDataChanged = function(owner, plate)
      local result = originalOnDataChanged(owner, plate)
      UnitFrames:RefreshNameplateIdentity(plate)
      UnitFrames:ApplyNameplateDetails(plate)
      return result
    end
  end

  local originalOnCreate = provider.OnCreate
  provider.OnCreate = function(frame)
    local result = originalOnCreate(frame)
    UnitFrames:ApplyNameplateHealthFill(frame and frame.nameplate)
    UnitFrames:RefreshNameplateTargetCue(frame and frame.nameplate)
    return result
  end

  local originalOnConfigChange = provider.OnConfigChange
  provider.OnConfigChange = function(frame)
    UnitFrames:RestoreNameplateIdentity(frame and frame.nameplate)
    UnitFrames:ApplyNameplateDetails(frame and frame.nameplate, true)
    local result = originalOnConfigChange(frame)
    local nameplate = frame and frame.nameplate
    local holder = nameplate and nameplate.aeuiTargetCueFrame
    if holder then holder.aeuiTargetCueAnchor = nil end
    UnitFrames:ApplyNameplateHealthFill(nameplate)
    UnitFrames:ApplyNameplateDetails(nameplate)
    UnitFrames:RefreshNameplateTargetCue(nameplate)
    return result
  end

  local originalOnUpdate = provider.OnUpdate
  provider.OnUpdate = function(frame, state)
    local result = originalOnUpdate(frame, state)
    -- The provider may return early from its throttle. Only the old/new
    -- selected plate needs a cue refresh; hidden cues have no per-frame work.
    local plate = frame and frame.nameplate
    local holder = plate and plate.aeuiTargetCueFrame
    if plate and (plate.istarget or (holder and holder.aeuiTargetCueVisible)) then
      UnitFrames:RefreshNameplateTargetCue(plate)
    end
    return result
  end

  provider.aeuiTargetCueHooksInstalled = true
  provider.aeuiTargetCueHookContract = self.runtimeContract
  return true
end

function UnitFrames:ApplyNameplateTargetCue()
  self.nameplateTargetCueActive = self:IsNameplateTargetCueEnabled()
  local providerReady = self:InstallNameplateTargetCueHooks()
  local applied = 0

  ForEachWorldNameplate(function(nameplate)
    self:RefreshNameplateIdentity(nameplate)
    self:ApplyNameplateHealthFill(nameplate)
    self:ApplyNameplateDetails(nameplate)
    if self:RefreshNameplateTargetCue(nameplate) then
      applied = applied + 1
    end
  end)
  self.appliedNameplateTargetCueCount = applied
  return providerReady
end

function UnitFrames:IsPrimaryEnabled()
  return
    ModuleEnabled() and
    RouteOwned("unitframes.health-fill") and
    RouteOwned("unitframes.power-fill")
end

function UnitFrames:IsPrimaryShellEnabled(role)
  return
    ModuleEnabled() and
    (RouteOwned("unitframes.primary-shell") or
      ((not role or role == "target") and RouteOwned("unitframes.target-shell-v4")))
end

function UnitFrames:IsPlayerShellV5Enabled()
  return
    ModuleEnabled() and
    RouteOwned("unitframes.player-shell-v5")
end

function UnitFrames:IsRaidEnabled()
  return
    ModuleEnabled() and
    RouteOwned("unitframes.raid-shell") and
    RouteOwned("unitframes.raid-health-fill") and
    RouteOwned("unitframes.raid-power-fill")
end

function UnitFrames:IsEnabled()
  return
    self:IsPrimaryEnabled() or
    (ModuleEnabled() and RouteOwned("unitframes.nameplate-details")) or
    (ModuleEnabled() and RouteOwned("unitframes.nameplate-health-fill")) or
    (ModuleEnabled() and RouteOwned("unitframes.distance-indicator")) or
    (ModuleEnabled() and RouteOwned("unitframes.standalone-aura-rim")) or
    (ModuleEnabled() and RouteOwned("unitframes.primary-thin-shell")) or
    self:IsPlayerShellV5Enabled() or
    self:IsPrimaryShellEnabled() or
    self:IsRaidEnabled() or
    self:IsNameplateTargetCueEnabled() or
    self:IsPortraitConfigurationEnabled()
end

local function ExpeditionPrimaryVisualRefresh(frame)
  local role = frame and frame.aeuiPrimaryShellRole
  if role and UnitFrames:IsPrimaryShellEnabled(role) then
    UnitFrames:ApplyPrimaryShell(frame, role)
  else
    UnitFrames:RestorePrimaryShell(frame)
  end
end

local function ExpeditionPlayerV5VisualRefresh(frame)
  if UnitFrames:IsPlayerShellV5Enabled() then
    UnitFrames:ApplyPlayerV5Shell(frame)
  else
    UnitFrames:RestorePlayerV5Shell(frame)
  end
end

function UnitFrames:ApplyPlayerV5Shell(frame)
  local registeredFrame = pfUI and pfUI.uf and pfUI.uf.player
  if not frame or registeredFrame ~= frame then return false end

  local width = FrameDimension(frame, "GetWidth", "width")
  local height = FrameDimension(frame, "GetHeight", "height")
  if
    not width or not height or
    Round(width) ~= PLAYER_V5.providerWidth or
    height + 12 <= PLAYER_V5.topCap + PLAYER_V5.bottomCap
  then
    self:RestorePlayerV5Shell(frame)
    return false
  end

  local overlay = EnsurePlayerV5Overlay(frame)
  local slices = overlay and EnsurePrimarySlices(overlay, "aeuiPlayerV5Slices", "ARTWORK")
  if not slices or not LayoutPrimarySlices(
    slices, PLAYER_V5.base, frame, width + 14, height + 12, PLAYER_V5
  ) then
    self:RestorePlayerV5Shell(frame)
    return false
  end

  SetPrimarySlicesColour(slices, 1, 1, 1, 1)
  overlay:Show()
  HidePlayerV5Chrome(frame)

  frame.aeuiPlayerV5ShellTexture = PLAYER_V5.base
  frame.aeuiPlayerV5ShellAssembly = PLAYER_V5.assembly
  frame.aeuiPlayerV5ShellContract = self.runtimeContract
  frame.aeuiPrimaryRefreshVisual = ExpeditionPlayerV5VisualRefresh
  return true
end

function UnitFrames:RestorePlayerV5Shell(frame)
  if not frame then return false end
  local applied = frame.aeuiPlayerV5ShellContract and true or false

  if frame.aeuiPrimaryRefreshVisual == ExpeditionPlayerV5VisualRefresh then
    frame.aeuiPrimaryRefreshVisual = nil
  end
  if frame.aeuiPlayerV5Overlay then
    frame.aeuiPlayerV5Overlay:Hide()
  end
  RestorePlayerV5Chrome(frame)

  frame.aeuiPlayerV5ShellTexture = nil
  frame.aeuiPlayerV5ShellAssembly = nil
  frame.aeuiPlayerV5ShellContract = nil

  if
    applied and
    not frame.aeuiPlayerV5Restoring and
    type(frame.UpdateConfig) == "function"
  then
    frame.aeuiPlayerV5Restoring = true
    pcall(frame.UpdateConfig, frame)
    frame.aeuiPlayerV5Restoring = nil
  end
  return applied
end

function UnitFrames:ApplyPrimaryShell(frame, role)
  local contract = role and PRIMARY_SHELLS[role]
  local registeredFrame = pfUI and pfUI.uf and role and pfUI.uf[role]
  if not frame or not contract or registeredFrame ~= frame then
    return false
  end

  local geometry = contract.geometry
  local width = FrameDimension(frame, "GetWidth", "width")
  local height = FrameDimension(frame, "GetHeight", "height")
  local artWidth =
    width and width + geometry.outsetLeft + geometry.outsetRight or nil
  local artHeight =
    height and height + geometry.outsetTop + geometry.outsetBottom or nil
  if
    not artWidth or not artHeight or
    artWidth <= geometry.leftCap + geometry.rightCap or
    artHeight <= geometry.topCap + geometry.bottomCap
  then
    self:RestorePrimaryShell(frame)
    return false
  end

  local background = EnsurePrimarySlices(
    frame, "aeuiPrimaryShellBackgroundSlices", "BACKGROUND"
  )
  local overlay = EnsurePrimaryOverlay(frame)
  local rim = overlay and EnsurePrimarySlices(
    overlay, "aeuiPrimaryShellRimSlices", "ARTWORK"
  )
  local hover = frame.hoverglow and EnsurePrimarySlices(
    frame.hoverglow, "aeuiPrimaryHoverSlices", "ARTWORK"
  )
  local aggro = frame.glow and EnsurePrimarySlices(
    frame.glow, "aeuiPrimaryAggroSlices", "ARTWORK"
  )
  if not background or not overlay or not rim or not hover or not aggro then
    self:RestorePrimaryShell(frame)
    return false
  end

  if
    not LayoutPrimarySlices(background, contract.base, frame, artWidth, artHeight, geometry) or
    not LayoutPrimarySlices(rim, contract.rim, frame, artWidth, artHeight, geometry) or
    not LayoutPrimarySlices(hover, contract.hover, frame, artWidth, artHeight, geometry) or
    not LayoutPrimarySlices(aggro, contract.aggro, frame, artWidth, artHeight, geometry)
  then
    self:RestorePrimaryShell(frame)
    return false
  end

  SetPrimarySlicesColour(background, 1, 1, 1, 1)
  SetPrimarySlicesColour(rim, 1, 1, 1, 1)
  SetPrimarySlicesColour(hover, 0.78, 0.64, 0.40, 0.82)
  SetPrimarySlicesColour(aggro, 0.62, 0.22, 0.10, 0.88)
  overlay:Show()
  HidePrimaryChrome(frame)

  frame.aeuiPrimaryShellRole = role
  frame.aeuiPrimaryShellTexture = contract.base
  frame.aeuiPrimaryShellAssembly = geometry.assembly
  frame.aeuiPrimaryShellArtWidth = artWidth
  frame.aeuiPrimaryShellArtHeight = artHeight
  frame.aeuiPrimaryShellContract = self.runtimeContract
  frame.aeuiPrimaryRefreshVisual = ExpeditionPrimaryVisualRefresh
  return true
end

function UnitFrames:RestorePrimaryShell(frame)
  if not frame then return false end
  local applied = frame.aeuiPrimaryShellContract and true or false

  frame.aeuiPrimaryRefreshVisual = nil
  SetPrimarySlicesShown(frame.aeuiPrimaryShellBackgroundSlices, false)
  if frame.aeuiPrimaryShellOverlay then
    SetPrimarySlicesShown(
      frame.aeuiPrimaryShellOverlay.aeuiPrimaryShellRimSlices,
      false
    )
    frame.aeuiPrimaryShellOverlay:Hide()
  end
  if frame.hoverglow then
    SetPrimarySlicesShown(frame.hoverglow.aeuiPrimaryHoverSlices, false)
  end
  if frame.glow then
    SetPrimarySlicesShown(frame.glow.aeuiPrimaryAggroSlices, false)
  end

  local shadow = frame.aeuiPrimaryShadowRestore
  if shadow and frame.backdrop_shadow then
    SetShown(frame.backdrop_shadow, shadow.shown)
  end
  frame.aeuiPrimaryShadowRestore = nil
  frame.aeuiPrimaryShellRole = nil
  frame.aeuiPrimaryShellTexture = nil
  frame.aeuiPrimaryShellAssembly = nil
  frame.aeuiPrimaryShellArtWidth = nil
  frame.aeuiPrimaryShellArtHeight = nil
  frame.aeuiPrimaryShellContract = nil

  if
    applied and
    not frame.aeuiPrimaryShellRestoring and
    type(frame.UpdateConfig) == "function"
  then
    frame.aeuiPrimaryShellRestoring = true
    pcall(frame.UpdateConfig, frame)
    frame.aeuiPrimaryShellRestoring = nil
  end
  return applied
end

function UnitFrames:ApplyFrame(frame)
  if not frame then return false end

  local healthBar = frame.hp and frame.hp.bar
  local powerBar = frame.power and frame.power.bar
  if not CanSetTexture(healthBar) or not CanSetTexture(powerBar) then
    return false
  end

  frame.aeuiHealthBarTexture = HEALTH_TEXTURE
  frame.aeuiPowerBarTexture = POWER_TEXTURE
  healthBar:SetStatusBarTexture(HEALTH_TEXTURE)
  powerBar:SetStatusBarTexture(POWER_TEXTURE)
  frame.aeuiUnitFrameBarsContract = self.runtimeContract
  return true
end

function UnitFrames:RestoreFrame(frame)
  if not frame then return false end

  local healthBar = frame.hp and frame.hp.bar
  local powerBar = frame.power and frame.power.bar
  frame.aeuiHealthBarTexture = nil
  frame.aeuiPowerBarTexture = nil
  frame.aeuiUnitFrameBarsContract = nil

  if CanSetTexture(healthBar) then
    local texture = GetConfiguredTexture(frame, "bartexture")
    if texture then healthBar:SetStatusBarTexture(texture) end
  end
  if CanSetTexture(powerBar) then
    local texture = GetConfiguredTexture(frame, "pbartexture")
    if texture then powerBar:SetStatusBarTexture(texture) end
  end
  return true
end

function UnitFrames:ApplyRaidFrame(frame, slot)
  -- pfRaid objects also represent player/party units in solo, group and preview.
  local raid = pfUI and pfUI.uf and pfUI.uf.raid
  if not frame or not raid or not slot or raid[slot] ~= frame then
    return false
  end

  local width = FrameDimension(frame, "GetWidth", "width")
  local height = FrameDimension(frame, "GetHeight", "height")
  if not width or not height or Round(height) ~= RAID_HEIGHT or width < 9 then
    self:RestoreRaidFrame(frame)
    self:RestoreFrame(frame)
    return false
  end

  local variant = RAID_VARIANTS[slot]
  local path = variant and RAID_TEXTURES[variant]
  local textures = path and EnsureRaidTextures(frame)
  if not textures then
    self:RestoreRaidFrame(frame)
    self:RestoreFrame(frame)
    return false
  end

  for _, texture in pairs(textures) do
    texture:ClearAllPoints()
    texture:SetTexture(path)
  end

  if Round(width) == RAID_STANDARD_WIDTH then
    ConfigureTexture(textures.full, path, 0, RAID_UV_FULL_RIGHT)
    textures.full:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
    textures.full:SetWidth(width + 4)
    textures.full:Show()
    textures.left:Hide()
    textures.centre:Hide()
    textures.right:Hide()
    frame.aeuiRaidShellAssembly = "complete-74x37"
  else
    ConfigureTexture(textures.left, path, 0, RAID_UV_LEFT)
    ConfigureTexture(textures.centre, path, RAID_UV_LEFT, RAID_UV_RIGHT)
    ConfigureTexture(textures.right, path, RAID_UV_RIGHT, RAID_UV_FULL_RIGHT)
    textures.left:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
    textures.left:SetWidth(RAID_LEFT_CAP)
    textures.centre:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, 2)
    textures.centre:SetWidth(width - 8)
    textures.right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, 2)
    textures.right:SetWidth(RAID_RIGHT_CAP)
    textures.full:Hide()
    textures.left:Show()
    textures.centre:Show()
    textures.right:Show()
    frame.aeuiRaidShellAssembly = "three-slice-6-centre-6"
  end

  HideRaidBackdrops(frame)
  frame.aeuiRaidSlot = slot
  frame.aeuiRaidShellVariant = variant
  frame.aeuiRaidShellTexture = path
  frame.aeuiRaidShellContract = self.runtimeContract
  frame.aeuiRaidRefreshVisual = function(target)
    UnitFrames:ApplyRaidFrame(target, target.aeuiRaidSlot)
  end
  return true
end

function UnitFrames:RestoreRaidFrame(frame)
  if not frame then return false end
  frame.aeuiRaidRefreshVisual = nil
  HideRaidTextures(frame)
  RestoreRaidBackdrops(frame)
  frame.aeuiRaidSlot = nil
  frame.aeuiRaidShellVariant = nil
  frame.aeuiRaidShellTexture = nil
  frame.aeuiRaidShellContract = nil
  frame.aeuiRaidShellAssembly = nil
  return true
end

local function TintAuraThinShell(button, r, g, b)
  SetPrimarySlicesColour(button.aeuiAuraThinSlices, r, g, b, 1)
end

local function ApplyAuraButtonThinShell(button, path)
  local width = FrameDimension(button, "GetWidth", "width")
  local height = FrameDimension(button, "GetHeight", "height")
  if path and width and height and width > 8 and height > 8 then
    local slices = EnsurePrimarySlices(button, "aeuiAuraThinSlices", "BACKGROUND")
    if LayoutPrimarySlices(slices, path, button, width + 4, height + 4, THIN_GEOMETRY) then
      if button.backdrop then
        if button.aeuiAuraBackdropShown == nil then button.aeuiAuraBackdropShown = FrameShown(button.backdrop) end
        button.backdrop:Hide()
      end
      if button.backdrop_shadow then
        if button.aeuiAuraShadowShown == nil then
          button.aeuiAuraShadowShown = FrameShown(button.backdrop_shadow)
        end
        button.backdrop_shadow:Hide()
      end
      -- The standalone provider creates icons on BACKGROUND, unlike unit-frame auras.
      local icon = button.texture or button.icon or button.tex
      if icon and icon.GetDrawLayer and icon.SetDrawLayer then
        if not button.aeuiAuraIconLayer then
          button.aeuiAuraIconLayer = icon:GetDrawLayer()
          button.aeuiAuraIcon = icon
        end
        icon:SetDrawLayer("ARTWORK")
      end
      SetPrimarySlicesColour(slices, 1, 1, 1, 1)
      button.aeuiAuraTint = TintAuraThinShell
      return true
    end
  end
  SetPrimarySlicesShown(button.aeuiAuraThinSlices, false)
  if button.aeuiAuraBackdropShown ~= nil then
    SetShown(button.backdrop, button.aeuiAuraBackdropShown)
    button.aeuiAuraBackdropShown = nil
  end
  if button.aeuiAuraShadowShown ~= nil then
    SetShown(button.backdrop_shadow, button.aeuiAuraShadowShown)
    button.aeuiAuraShadowShown = nil
  end
  if button.aeuiAuraIconLayer then
    button.aeuiAuraIcon:SetDrawLayer(button.aeuiAuraIconLayer)
    button.aeuiAuraIcon = nil
    button.aeuiAuraIconLayer = nil
  end
  button.aeuiAuraTint = nil
  return false
end

function UnitFrames:GetNameplateCastHeight()
  local profile = self:GetNameplateProfile()
  if profile and profile.mode ~= "off" and ModuleEnabled() and RouteOwned("unitframes.nameplate-details") then
    return 12
  end
end

function UnitFrames:LayoutNameplateDetails(plate)
  local art = plate and plate.aeuiDetails
  if not art or not art.active then return end
  if plate.guild then
    local cue = plate.aeuiTargetCueFrame
    local anchor = cue and FrameShown(cue) and cue or plate.name
    local _, relative = plate.guild:GetPoint()
    if art.guildAnchor ~= anchor or relative ~= anchor then
      plate.guild:ClearAllPoints()
      plate.guild:SetPoint("BOTTOM", anchor, "TOP", 0, 2)
      art.guildAnchor = anchor
    end
  end
  if not plate.cluster then return end
  local cast = plate.castbar
  local offset = cast and FrameShown(cast) and cast.icon:GetWidth() + 6 or 12
  local bounds = plate.health.aeuiIdentityBounds or plate.health
  if art.clusterOffset ~= offset or art.clusterAnchor ~= bounds then
    plate.cluster:ClearAllPoints()
    plate.cluster:SetPoint("LEFT", bounds, "RIGHT", offset, 0)
    art.clusterOffset, art.clusterAnchor = offset, bounds
  end
end

function UnitFrames:ApplyNameplateDetails(plate, restore)
  if not plate or not plate.castbar or not plate.castbar.spell then return end
  local enabled = not restore and self:GetNameplateCastHeight() ~= nil
  local cast = plate.castbar
  local art = plate.aeuiDetails
  if enabled and not art then art = {}; plate.aeuiDetails = art end
  local materialKey = tostring(enabled) .. ":" .. cast:GetWidth() .. ":" .. cast:GetHeight()
  if not art or art.materialKey ~= materialKey then
    self:SetNameplateBarFill(cast, enabled)
    if art then art.materialKey = materialKey end
  end
  if enabled and not art.active then
    art.timePoint, art.spellPoint = {cast.text:GetPoint()}, {cast.spell:GetPoint()}
    art.timeWidth, art.timeJustify = cast.text:GetWidth(), cast.text:GetJustifyH()
    art.spellJustify = cast.spell:GetJustifyH()
    art.timeFont, art.spellFont = {cast.text:GetFont()}, {cast.spell:GetFont()}
    art.timeColour = {cast.text:GetTextColor()}
    art.guildPoint = plate.guild and {plate.guild:GetPoint()}
    art.clusterPoint = plate.cluster and {plate.cluster:GetPoint()}
    local size = math.max(8, math.min(art.spellFont[2], cast:GetHeight()-2))
    cast.text:ClearAllPoints()
    cast.text:SetPoint("RIGHT", cast, "RIGHT", -3, 0)
    cast.text:SetWidth(32)
    cast.text:SetJustifyH("RIGHT")
    cast.text:SetFont(art.timeFont[1], size, art.timeFont[3])
    cast.text:SetTextColor(1,1,1,1)
    cast.spell:ClearAllPoints()
    cast.spell:SetPoint("LEFT", cast, "LEFT", 3, 0)
    cast.spell:SetPoint("RIGHT", cast.text, "LEFT", -3, 0)
    cast.spell:SetJustifyH("LEFT")
    cast.spell:SetFont(art.spellFont[1], size, art.spellFont[3])
    if plate.guild then
      plate.guild:ClearAllPoints()
      plate.guild:SetPoint("BOTTOM", plate.name, "TOP", 0, 2)
    end
    art.active = true
    plate.aeuiDetailsLayout = function() UnitFrames:LayoutNameplateDetails(plate) end
  elseif not enabled and art and art.active then
    cast.text:ClearAllPoints(); cast.text:SetPoint(unpack(art.timePoint))
    cast.text:SetWidth(art.timeWidth); cast.text:SetJustifyH(art.timeJustify)
    cast.text:SetFont(unpack(art.timeFont)); cast.text:SetTextColor(unpack(art.timeColour))
    cast.spell:ClearAllPoints(); cast.spell:SetPoint(unpack(art.spellPoint))
    cast.spell:SetJustifyH(art.spellJustify); cast.spell:SetFont(unpack(art.spellFont))
    if art.guildPoint then plate.guild:ClearAllPoints(); plate.guild:SetPoint(unpack(art.guildPoint)) end
    if art.clusterPoint then plate.cluster:ClearAllPoints(); plate.cluster:SetPoint(unpack(art.clusterPoint)) end
    art.active, art.clusterOffset, art.clusterAnchor, art.guildAnchor = false, nil, nil, nil
    plate.aeuiDetailsLayout = nil
  end
  local function icon(button)
    if not button then return end
    local key = tostring(enabled) .. ":" .. button:GetWidth() .. ":" .. button:GetHeight()
    if button.aeuiNameplateIconSize ~= key then
      ApplyAuraButtonThinShell(button, enabled and RAID_TEXTURES.A or nil)
      button.aeuiNameplateIconSize = key
    end
  end
  icon(cast.icon)
  icon(plate.totem)
  for _, button in ipairs(plate.debuffs or {}) do icon(button) end
  for _, button in ipairs(plate.combopoints or {}) do
    local pip = button.aeuiCopperPip
    if enabled and not pip then
      pip = button:CreateTexture(nil, "OVERLAY")
      pip:SetTexture(MEDIA .. "NameplateIdentityDividerV1")
      pip:SetTexCoord(0, 4/8, 4/32, 23/32)
      pip:SetWidth(3); pip:SetHeight(5); pip:SetPoint("CENTER", button, "CENTER", 0, 0)
      button.aeuiCopperPip = pip
    end
    if enabled then
      if button.aeuiPipOriginal == nil then
        button.aeuiPipOriginal = {texture=FrameShown(button.tex), backdrop=FrameShown(button.backdrop)}
      end
      SetShown(button.tex, false); SetShown(button.backdrop, false); pip:Show()
    elseif button.aeuiPipOriginal then
      SetShown(pip, false); SetShown(button.tex, button.aeuiPipOriginal.texture)
      SetShown(button.backdrop, button.aeuiPipOriginal.backdrop); button.aeuiPipOriginal = nil
    end
  end
  if enabled then self:LayoutNameplateDetails(plate) end
end

function UnitFrames:ApplyAuraThinShells(frame, path)
  if not frame then return end
  if not RouteOwned("unitframes.primary-aura-rim") then path = nil end
  frame.aeuiAuraBorder = path and 2 or nil
  for _, kind in ipairs({ "buffs", "debuffs" }) do
    for _, button in pairs(frame[kind] or {}) do
      ApplyAuraButtonThinShell(button, path)
    end
  end
  frame.update_aura = true
end

local function RefreshStandaloneAuraColour(button)
  if button.mode == "HELPFUL" then
    TintAuraThinShell(button, 1, 1, 1)
  elseif button.backdrop and button.backdrop.GetBackdropBorderColor then
    TintAuraThinShell(button, button.backdrop:GetBackdropBorderColor())
  end
end

function UnitFrames:ApplyRaidAuraShells(frame)
  local enabled = ModuleEnabled() and RouteOwned("unitframes.raid-aura-rim")
  for _, kind in ipairs({"buffs", "debuffs"}) do
    local path = enabled and RAID_TEXTURES[kind == "debuffs" and "B" or "A"] or nil
    for _, button in pairs(frame[kind] or {}) do
      if ApplyAuraButtonThinShell(button, path) and kind == "debuffs" and
        button.backdrop.GetBackdropBorderColor then
        TintAuraThinShell(button, button.backdrop:GetBackdropBorderColor())
      end
    end
  end
  frame.aeuiRaidAuraRefresh = enabled and function(target)
    UnitFrames:ApplyRaidAuraShells(target)
  end or nil
end

function UnitFrames:ApplyStandaloneAuraShells()
  local provider = pfUI and pfUI.buff
  if not provider then return end
  local enabled = ModuleEnabled() and RouteOwned("unitframes.standalone-aura-rim")
  for _, kind in ipairs({ "buffs", "debuffs", "wepbuffs" }) do
    local group = provider[kind]
    for _, button in pairs(group and group.buttons or {}) do
      local path = enabled and RAID_TEXTURES[kind == "debuffs" and "B" or "A"] or nil
      local applied = ApplyAuraButtonThinShell(button, path)
      button.aeuiAuraRefreshColour = applied and RefreshStandaloneAuraColour or nil
      if applied then RefreshStandaloneAuraColour(button) end
    end
  end
  provider.aeuiRefreshAuraShells = enabled and function()
    UnitFrames:ApplyStandaloneAuraShells()
  end or nil
end

function UnitFrames:RestoreThinShell(frame)
  if not frame or not frame.aeuiThinShell then return end
  self:ApplyAuraThinShells(frame, nil)
  frame.aeuiPrimaryRefreshVisual = nil
  SetPrimarySlicesShown(frame.aeuiThinShellSlices, false)
  RestorePlayerV5Chrome(frame)
  frame.aeuiThinShell = nil
end

function UnitFrames:ApplyThinShell(frame, role)
  if not frame or not THIN_VARIANTS[role] or
    not pfUI or not pfUI.uf or pfUI.uf[role] ~= frame then return false end
  local width = FrameDimension(frame, "GetWidth", "width")
  local height = FrameDimension(frame, "GetHeight", "height")
  if not ModuleEnabled() or not RouteOwned("unitframes.primary-thin-shell") or
    not width or not height or width <= 8 or height <= 8 then
    self:RestoreThinShell(frame)
    return false
  end
  local slices = EnsurePrimarySlices(frame, "aeuiThinShellSlices", "BACKGROUND")
  local path = RAID_TEXTURES[THIN_VARIANTS[role]]
  if not LayoutPrimarySlices(slices, path, frame, width + 4, height + 4, THIN_GEOMETRY) then
    self:RestoreThinShell(frame)
    return false
  end
  SetPrimarySlicesColour(slices, 1, 1, 1, 1)
  HidePlayerV5Chrome(frame)
  self:ApplyAuraThinShells(frame, path)
  frame.aeuiThinShell = path
  frame.aeuiPrimaryRefreshVisual = function(target)
    UnitFrames:ApplyThinShell(target, role)
  end
  return true
end

function UnitFrames:RestoreDistanceIndicatorDock(frame)
  local art = frame and frame.aeuiDistanceArt
  if not art or not art.framePoint then return end
  frame:ClearAllPoints()
  frame:SetPoint(unpack(art.framePoint))
  frame.text:ClearAllPoints()
  frame.text:SetPoint(unpack(art.textPoint))
  art.framePoint, art.textPoint = nil, nil
end

-- The provider retains distance/state updates; these textures only wrap its readout.
-- SuperWoW world XY uses north/west axes. Like pfQuest, convert the bearing
-- relative to player facing into one of the existing arrow atlas's 108 cells.
function UnitFrames:GetDistanceDirectionCell()
  local facing = GetPlayerFacing or (pfQuestCompat and pfQuestCompat.GetPlayerFacing)
  if type(UnitPosition) ~= "function" or type(facing) ~= "function" or
    type(math.atan2) ~= "function" or not UnitExists("target") then return nil end
  local okPlayer, px, py = pcall(UnitPosition, "player")
  local okTarget, tx, ty = pcall(UnitPosition, "target")
  local okFacing, heading = pcall(facing)
  if not okPlayer or not okTarget or not okFacing then return nil end
  for _, value in ipairs({px or false, py or false, tx or false, ty or false, heading or false}) do
    if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then return nil end
  end
  local dx, dy = tx - px, ty - py
  if dx*dx + dy*dy < .0001 then return nil end
  local turn = math.atan2(dy, dx) - heading
  return math.mod(math.mod(math.floor(turn / (2*math.pi) * 108 + .5), 108) + 108, 108)
end

function UnitFrames:RefreshDistanceIndicator(frame)
  if not frame or not frame.text or not frame.icon then return end
  local art = frame.aeuiDistanceArt
  if not art then
    art = { slices = {} }
    for i = 1, 3 do
      local texture = frame:CreateTexture(nil, "BACKGROUND")
      texture:SetTexture(MEDIA .. "DistanceTagV1")
      texture:SetVertexColor(.75, .75, .75, .85)
      local starts, ends = { 0, 22, 116 }, { 22, 116, 144 }
      texture:SetTexCoord(starts[i] / 256, ends[i] / 256, 0, 36 / 64)
      art.slices[i] = texture
    end
    art.direction = frame:CreateTexture(nil, "OVERLAY")
    art.direction:SetTexture(MEDIA .. "DistanceDirectionV1")
    art.direction:SetWidth(16)
    art.direction:SetHeight(16)
    art.direction:SetVertexColor(1, 1, 1, 1)
    art.direction:Hide()
    frame.aeuiDistanceArt = art
  end
  if not art.active then
    art.point, art.uv = { frame.icon:GetPoint() }, { frame.icon:GetTexCoord() }
    art.width, art.height = frame.icon:GetWidth(), frame.icon:GetHeight()
    art.alpha = frame.icon:GetAlpha()
    frame.icon:SetAlpha(.8)
    art.active = true
  end
  -- Also handles immediate activation while an old provider readout is visible.
  local value = frame.text:GetText() or ""
  if string.find(value, "^打脸\n") then
    value = string.gsub(value, "^打脸\n", "")
    frame.text:SetText(value)
  end
  local shown = value ~= ""
  if art.shown ~= shown then
    for i = 1, 3 do SetShown(art.slices[i], shown) end
    art.shown = shown
  end
  if not shown then art.direction:Hide(); return end
  local directionCell = self:GetDistanceDirectionCell()
  SetShown(art.direction, directionCell ~= nil)
  if directionCell ~= nil and art.directionCell ~= directionCell then
    local column, row = math.mod(directionCell, 16), math.floor(directionCell / 16)
    art.direction:SetTexCoord(column*32/512, (column+1)*32/512, row*32/256, (row+1)*32/256)
    art.directionCell = directionCell
  end
  local cfg = pfUI_config.unitframes
  local fontSize = tonumber(cfg.distance_indicator_font_size) or 13
  local iconShown = FrameShown(frame.icon)
  local iconWidth = (tonumber(cfg.distance_indicator_icon_size) or 20) * .85
  local iconHeight = iconWidth * .7
  local left = -(iconShown and (iconWidth + 18) or 11)
  -- Reserve the entire brass cap plus 6 UI of clear space after the digits.
  local textWidth = math.max(frame.text:GetWidth(), frame.text:GetStringWidth())
  local width = math.max(72, textWidth - left + 14 + 6 + (directionCell ~= nil and 20 or 0))
  local height = math.max(18, fontSize + 5, iconShown and iconHeight + 4 or 0)
  local player = pfUI.uf and pfUI.uf.player
  local target = pfUI.uf and pfUI.uf.target
  local key = width .. ":" .. height .. ":" .. fontSize .. ":" .. iconWidth .. ":" .. tostring(iconShown) ..
    ":" .. tostring(player) .. ":" .. tostring(target)
  if art.layout ~= key then
    if player and target then
      if not art.dock then
        art.dock = CreateFrame("Frame", nil, UIParent)
        art.dock:EnableMouse(false)
        art.dock:SetHeight(1)
      end
      -- Native relative anchors follow both unit frames, including their scale,
      -- without polling screen coordinates or rewriting anchors every update.
      if art.player ~= player or art.target ~= target then
        art.dock:ClearAllPoints()
        art.dock:SetPoint("LEFT", player, "RIGHT", 0, 0)
        art.dock:SetPoint("RIGHT", target, "LEFT", 0, 0)
        art.player, art.target = player, target
      end
      if not art.framePoint then
        art.framePoint, art.textPoint = { frame:GetPoint() }, { frame.text:GetPoint() }
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOM", art.dock, "CENTER", 0, 0)
      end
      -- Center the complete tag in the gap, below Buffs and above Debuffs.
      -- Keep the numeric baseline fixed when provider prefix lines appear.
      frame.text:ClearAllPoints()
      frame.text:SetPoint("BOTTOM", frame, "BOTTOM",
        textWidth / 2 - left - width / 2, -fontSize / 2)
    else
      self:RestoreDistanceIndicatorDock(frame)
    end
    local sizes = { 11, width - 25, 14 }
    for i = 1, 3 do
      local texture = art.slices[i]
      texture:ClearAllPoints()
      texture:SetWidth(sizes[i])
      texture:SetHeight(height)
      if i == 1 then
        texture:SetPoint("BOTTOMLEFT", frame.text, "BOTTOMLEFT", left, -(height - fontSize) / 2)
      else
        texture:SetPoint("BOTTOMLEFT", art.slices[i-1], "BOTTOMRIGHT", 0, 0)
      end
    end
    art.direction:ClearAllPoints()
    art.direction:SetPoint("BOTTOMLEFT", frame.text, "BOTTOMRIGHT", 6, (fontSize - 16) / 2)
    frame.icon:ClearAllPoints()
    frame.icon:SetPoint("BOTTOMLEFT", frame.text, "BOTTOMLEFT", -(iconWidth + 7), (fontSize - iconHeight) / 2)
    frame.icon:SetWidth(iconWidth)
    frame.icon:SetHeight(iconHeight)
    frame.icon:SetTexCoord(0, 40 / 64, 0, 28 / 32)
    art.layout = key
  end
end

function UnitFrames:ApplyDistanceIndicator()
  if not pfUI then return end
  local enabled = ModuleEnabled() and RouteOwned("unitframes.distance-indicator")
  if enabled then
    if not self.distanceSkin then
      self.distanceSkin = {
        insight = MEDIA .. "DistanceEyeOpenV1", outsight = MEDIA .. "DistanceEyeBlockedV1",
        refresh = function(frame) UnitFrames:RefreshDistanceIndicator(frame) end,
      }
    end
    pfUI.aeuiDistanceIndicatorSkin = self.distanceSkin
    self:RefreshDistanceIndicator(pfUI.distanceIndicator)
  else
    pfUI.aeuiDistanceIndicatorSkin = nil
    local frame = pfUI.distanceIndicator
    local art = frame and frame.aeuiDistanceArt
    if art then
      self:RestoreDistanceIndicatorDock(frame)
      art.direction:Hide()
      for i = 1, 3 do art.slices[i]:Hide() end
      frame.icon:ClearAllPoints()
      frame.icon:SetPoint(unpack(art.point))
      frame.icon:SetWidth(art.width)
      frame.icon:SetHeight(art.height)
      frame.icon:SetAlpha(art.alpha or 1)
      frame.icon:SetTexCoord(unpack(art.uv))
      frame.icon:SetTexture(pfUI.media[frame.aeuiDistanceOutOfSight and "img:ceye" or "img:oeye"])
      art.shown, art.layout, art.active = false, nil, false
    end
  end
  self.distanceIndicatorActive = enabled
end

function UnitFrames:Apply()
  local frames = pfUI and pfUI.uf
  local primaryEnabled = self:IsPrimaryEnabled()
  local playerShellV5Enabled = self:IsPlayerShellV5Enabled()
  local raidEnabled = self:IsRaidEnabled()
  local portraitsEnabled = self:IsPortraitConfigurationEnabled()
  local primaryApplied = 0
  local primaryShellApplied = 0
  local playerShellV5Applied = 0
  local raidApplied = 0
  local thinApplied = 0

  self:ApplyDistanceIndicator()
  self:ApplyStandaloneAuraShells()
  self:ApplyNameplateMode()
  self:ApplyNameplateTargetCue()

  if portraitsEnabled then
    self:ApplyPortraitConfiguration()
  else
    self:RestorePortraitConfiguration()
  end

  if frames then
    for _, key in ipairs(PRIMARY_FRAME_KEYS) do
      local frame = frames[key]
      self:RestoreThinShell(frame)
      if primaryEnabled then
        if self:ApplyFrame(frame) then primaryApplied = primaryApplied + 1 end
      else
        self:RestoreFrame(frame)
      end

      if PRIMARY_SHELLS[key] then
        if key == "player" and playerShellV5Enabled then
          self:RestorePrimaryShell(frame)
        elseif self:IsPrimaryShellEnabled(key) then
          if self:ApplyPrimaryShell(frame, key) then
            primaryShellApplied = primaryShellApplied + 1
          end
        else
          self:RestorePrimaryShell(frame)
        end
      end

      if key == "player" then
        if playerShellV5Enabled then
          if self:ApplyPlayerV5Shell(frame) then
            playerShellV5Applied = playerShellV5Applied + 1
          end
        else
          self:RestorePlayerV5Shell(frame)
        end
      end
      if THIN_VARIANTS[key] then
        if self:ApplyThinShell(frame, key) then thinApplied = thinApplied + 1 end
      end
    end

    local raid = frames.raid
    if raid then
      for slot = 1, 40 do
        local frame = raid[slot]
        if frame then
          self:ApplyRaidAuraShells(frame)
          if raidEnabled and self:ApplyFrame(frame) and self:ApplyRaidFrame(frame, slot) then
            raidApplied = raidApplied + 1
          else
            self:RestoreRaidFrame(frame)
            self:RestoreFrame(frame)
          end
        end
      end
    end
  end

  self.appliedFrameCount = primaryApplied
  self.appliedPrimaryShellCount = primaryShellApplied
  self.appliedPlayerShellV5Count = playerShellV5Applied
  self.appliedRaidFrameCount = raidApplied
  self.appliedThinShellCount = thinApplied
end

function UnitFrames:Initialize()
  self:Apply()
end

function UnitFrames:GetRuntimeStatus()
  return
    "contract=" .. tostring(self.runtimeContract) ..
    ", " .. self:GetNameplateModeStatus() ..
    ", distance-tag=" .. tostring(self.distanceIndicatorActive) ..
    ", primary-thin-shells=" .. tostring(self.appliedThinShellCount or 0) .. "/4" ..
    ", enabled=" .. tostring(self:IsEnabled()) ..
    ", primary-bars=" .. tostring(self.appliedFrameCount or 0) .. "/4" ..
    ", primary-shells=" ..
      tostring(self.appliedPrimaryShellCount or 0) .. "/4" ..
    ", player-shell-v5=" ..
      tostring(self.appliedPlayerShellV5Count or 0) .. "/1" ..
    ", raid-shells=" .. tostring(self.appliedRaidFrameCount or 0) .. "/40" ..
    ", nameplate-target-cue=" ..
      tostring(self.nameplateTargetCueActive) ..
      "/" .. tostring(self.appliedNameplateTargetCueCount or 0) ..
    ", portraits=" .. tostring(self.disabledPortraitConfigCount or 0) ..
      "/" .. tostring(PORTRAIT_CONFIG_COUNT) ..
    ", marker-trackers=" ..
      tostring(self.disabledPortraitTrackerCount or 0) .. "/2" ..
    ", primary-slices=32/150/32-8/26/8" ..
    ", player-v5=height-adaptive@240" ..
    ", targettarget-slices=20/72/20-6/22/6" ..
    ", focus-slices=24/64/24-10/27/6" ..
    ", raid-slices=6/62/6" ..
    ", texture-containers=pot-1.12" ..
    ", scope=all-pfui-unitframe-portraits,player,target,targettarget,focus,pfRaid1..40,pfUI.nameplates" ..
    ", fallback=pfui-configured-portraits-bars-primary-chrome-raid-backdrops-and-no-personal-target-cue"
end

addon:RegisterModule("UnitFrames", UnitFrames)
