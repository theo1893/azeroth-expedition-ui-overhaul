local addon = AzerothExpeditionUI
local Spellbook = {}
Spellbook.runtimeContract = "1.0"
Spellbook.integrationPaused = true

local MEDIA = addon.media.root .. "Spellbook\\"
local ART = {
  topLeft = {
    path = MEDIA .. "SpellbookFramePageFieldTopLeftV1",
    x = 0,
    y = 0,
    width = 256,
    height = 256,
  },
  topRight = {
    path = MEDIA .. "SpellbookFramePageFieldTopRightV1",
    x = 256,
    y = 0,
    width = 128,
    height = 256,
  },
  bottomLeft = {
    path = MEDIA .. "SpellbookFramePageFieldBottomLeftV1",
    x = 0,
    y = 256,
    width = 256,
    height = 256,
  },
  bottomRight = {
    path = MEDIA .. "SpellbookFramePageFieldBottomRightV1",
    x = 256,
    y = 256,
    width = 128,
    height = 256,
  },
}

local ICON_CANDIDATES = {
  "SpellBookFrameIcon",
  "SpellBookFrameIconTexture",
  "SpellBookFramePortrait",
  "SpellBookFramePortraitIcon",
  "SpellBookIconTexture",
}

local function ModuleEnabled()
  return
    not Spellbook.integrationPaused and
    addon.db and
    addon.db.spellbook and
    addon.db.spellbook.enabled and
    true or false
end

local function ScopedOwnershipActive()
  local expedition =
    pfUI_config and
    pfUI_config.appearance and
    pfUI_config.appearance.expedition
  return
    expedition and
    expedition.enabled == "1" and
    expedition.ownership == "scoped-v1" and
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

local function CaptureProviderRegions()
  if not SpellBookFrame or SpellBookFrame.aeuiSpellbookProviderRegions then
    return
  end
  local captured = {}
  for _, region in ipairs({ SpellBookFrame:GetRegions() }) do
    if
      region and
      type(region.GetObjectType) == "function" and
      region:GetObjectType() == "Texture"
    then
      table.insert(captured, {
        region = region,
        shown = FrameShown(region),
      })
    end
  end
  SpellBookFrame.aeuiSpellbookProviderRegions = captured
end

local function HideProviderRegions()
  CaptureProviderRegions()
  local captured =
    SpellBookFrame and SpellBookFrame.aeuiSpellbookProviderRegions
  if not captured then return end
  for _, state in ipairs(captured) do
    state.region:Hide()
  end
end

local function RestoreProviderRegions()
  local captured =
    SpellBookFrame and SpellBookFrame.aeuiSpellbookProviderRegions
  if not captured then return end
  for _, state in ipairs(captured) do
    SetShown(state.region, state.shown)
  end
end

local function CaptureAndHideProviderBackdrop()
  if not SpellBookFrame then return end
  SpellBookFrame.aeuiSpellbookBackdropRestore =
    SpellBookFrame.aeuiSpellbookBackdropRestore or {}
  local restore = SpellBookFrame.aeuiSpellbookBackdropRestore
  if SpellBookFrame.backdrop and restore.backdrop == nil then
    restore.backdrop = FrameShown(SpellBookFrame.backdrop)
  end
  if SpellBookFrame.backdrop_shadow and restore.shadow == nil then
    restore.shadow = FrameShown(SpellBookFrame.backdrop_shadow)
  end
  if SpellBookFrame.backdrop then SpellBookFrame.backdrop:Hide() end
  if SpellBookFrame.backdrop_shadow then
    SpellBookFrame.backdrop_shadow:Hide()
  end
end

local function RestoreProviderBackdrop()
  if not SpellBookFrame then return end
  local restore = SpellBookFrame.aeuiSpellbookBackdropRestore
  if not restore then return end
  if restore.backdrop ~= nil and SpellBookFrame.backdrop then
    SetShown(SpellBookFrame.backdrop, restore.backdrop)
  end
  if restore.shadow ~= nil and SpellBookFrame.backdrop_shadow then
    SetShown(SpellBookFrame.backdrop_shadow, restore.shadow)
  end
  SpellBookFrame.aeuiSpellbookBackdropRestore = nil
end

local function CaptureAndHideNamedIcons()
  if not SpellBookFrame then return end
  SpellBookFrame.aeuiSpellbookIconRestore =
    SpellBookFrame.aeuiSpellbookIconRestore or {}
  local restore = SpellBookFrame.aeuiSpellbookIconRestore
  for _, name in ipairs(ICON_CANDIDATES) do
    local icon = _G[name]
    if icon then
      if restore[name] == nil then
        restore[name] = FrameShown(icon)
      end
      icon:Hide()
    end
  end
end

local function RestoreNamedIcons()
  if not SpellBookFrame then return end
  local restore = SpellBookFrame.aeuiSpellbookIconRestore
  if not restore then return end
  for name, shown in pairs(restore) do
    SetShown(_G[name], shown)
  end
  SpellBookFrame.aeuiSpellbookIconRestore = nil
end

local function ConfigureTexture(texture, definition)
  texture:ClearAllPoints()
  texture:SetTexture(definition.path)
  texture:SetWidth(definition.width)
  texture:SetHeight(definition.height)
  texture:SetTexCoord(0, 1, 0, 1)
  texture:SetVertexColor(1, 1, 1)
  texture:SetAlpha(1)
  texture:SetPoint(
    "TOPLEFT",
    SpellBookFrame,
    "TOPLEFT",
    definition.x,
    -definition.y
  )
  texture:Show()
end

local function EnsureArt()
  if not SpellBookFrame then return nil end
  if SpellBookFrame.aeuiSpellbookArt then
    return SpellBookFrame.aeuiSpellbookArt
  end

  -- Capture every provider-owned direct texture before AEUI creates its own.
  -- This includes the native top-left Spellbook/Class icon when present.
  CaptureProviderRegions()
  local art = {
    topLeft = SpellBookFrame:CreateTexture(nil, "BACKGROUND"),
    topRight = SpellBookFrame:CreateTexture(nil, "BACKGROUND"),
    bottomLeft = SpellBookFrame:CreateTexture(nil, "BACKGROUND"),
    bottomRight = SpellBookFrame:CreateTexture(nil, "BACKGROUND"),
  }
  SpellBookFrame.aeuiSpellbookArt = art
  return art
end

local function HideArt()
  local art = SpellBookFrame and SpellBookFrame.aeuiSpellbookArt
  if not art then return end
  for _, texture in pairs(art) do
    texture:Hide()
  end
end

function Spellbook:Restore()
  if SpellBookFrame then
    HideArt()
    RestoreProviderRegions()
    RestoreProviderBackdrop()
    RestoreNamedIcons()
    SpellBookFrame.aeuiSpellbookRuntimeContract = nil
  end
  self.status = "inactive"
end

function Spellbook:ApplyFrame()
  if not SpellBookFrame then
    self.status = "provider-missing"
    return false
  end

  local width = SpellBookFrame:GetWidth()
  local height = SpellBookFrame:GetHeight()
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

  local art = EnsureArt()
  if not art then
    self:Restore()
    self.status = "art-missing"
    return false
  end

  CaptureAndHideNamedIcons()
  HideProviderRegions()
  CaptureAndHideProviderBackdrop()
  for key, definition in pairs(ART) do
    ConfigureTexture(art[key], definition)
  end

  SpellBookFrame.aeuiSpellbookRuntimeContract = self.runtimeContract
  self.status = "sb-a2-applied"
  return true
end

function Spellbook:InstallHooks()
  if
    not SpellBookFrame or
    SpellBookFrame.aeuiSpellbookShowHooked
  then
    return
  end
  SpellBookFrame.aeuiSpellbookShowHooked = true
  local previous = SpellBookFrame:GetScript("OnShow")
  SpellBookFrame:SetScript("OnShow", function()
    if previous then previous() end
    if ModuleEnabled() then
      addon:ScheduleRefresh(0)
    end
  end)
end

function Spellbook:GetRuntimeStatus()
  return
    "frame=" .. tostring(self.status or "unapplied") ..
    ", provider-geometry=384x512" ..
    ", provider-controls=live" ..
    ", top-left-icon=hidden"
end

function Spellbook:Initialize()
  self.status = "unapplied"
end

function Spellbook:Apply()
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

addon:RegisterModule("Spellbook", Spellbook)
