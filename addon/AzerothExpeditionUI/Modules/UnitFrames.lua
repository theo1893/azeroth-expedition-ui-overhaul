local addon = AzerothExpeditionUI
local UnitFrames = {}
UnitFrames.runtimeContract = "1.2"

local MEDIA = addon.media.root .. "UnitFrames\\"
local HEALTH_TEXTURE = MEDIA .. "UnitFrameHealthFillV1"
local POWER_TEXTURE = MEDIA .. "UnitFramePowerFillV1"

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
local RAID_STANDARD_WIDTH = 70
local RAID_ART_HEIGHT = 37
local RAID_LEFT_CAP = 6
local RAID_CENTRE = 62
local RAID_RIGHT_CAP = 6
local RAID_UV_LEFT = RAID_LEFT_CAP / 74
local RAID_UV_RIGHT = (RAID_LEFT_CAP + RAID_CENTRE) / 74

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
  texture:SetTexCoord(left, right, 0, 1)
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

function UnitFrames:IsPrimaryEnabled()
  return
    ModuleEnabled() and
    RouteOwned("unitframes.health-fill") and
    RouteOwned("unitframes.power-fill")
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
    self:IsRaidEnabled() or
    self:IsPortraitConfigurationEnabled()
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
  if not frame or (frame.label and frame.label ~= "raid") then
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
    ConfigureTexture(textures.full, path, 0, 1)
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
    ConfigureTexture(textures.right, path, RAID_UV_RIGHT, 1)
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

function UnitFrames:Apply()
  local frames = pfUI and pfUI.uf
  local primaryEnabled = self:IsPrimaryEnabled()
  local raidEnabled = self:IsRaidEnabled()
  local portraitsEnabled = self:IsPortraitConfigurationEnabled()
  local primaryApplied = 0
  local raidApplied = 0

  if portraitsEnabled then
    self:ApplyPortraitConfiguration()
  else
    self:RestorePortraitConfiguration()
  end

  if frames then
    for _, key in ipairs(PRIMARY_FRAME_KEYS) do
      local frame = frames[key]
      if primaryEnabled then
        if self:ApplyFrame(frame) then primaryApplied = primaryApplied + 1 end
      else
        self:RestoreFrame(frame)
      end
    end

    local raid = frames.raid
    if raid then
      for slot = 1, 40 do
        local frame = raid[slot]
        if frame then
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
  self.appliedRaidFrameCount = raidApplied
end

function UnitFrames:Initialize()
  self:Apply()
end

function UnitFrames:GetRuntimeStatus()
  return
    "contract=" .. tostring(self.runtimeContract) ..
    ", enabled=" .. tostring(self:IsEnabled()) ..
    ", primary-bars=" .. tostring(self.appliedFrameCount or 0) .. "/4" ..
    ", raid-shells=" .. tostring(self.appliedRaidFrameCount or 0) .. "/40" ..
    ", portraits=" .. tostring(self.disabledPortraitConfigCount or 0) ..
      "/" .. tostring(PORTRAIT_CONFIG_COUNT) ..
    ", marker-trackers=" ..
      tostring(self.disabledPortraitTrackerCount or 0) .. "/2" ..
    ", raid-slices=6/62/6" ..
    ", scope=all-pfui-unitframe-portraits,player,target,targettarget,focus,pfRaid1..40" ..
    ", fallback=pfui-configured-portraits-bars-and-raid-backdrops"
end

addon:RegisterModule("UnitFrames", UnitFrames)
