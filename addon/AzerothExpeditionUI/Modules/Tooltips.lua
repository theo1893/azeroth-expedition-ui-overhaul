local addon = AzerothExpeditionUI
local Tooltips = {}
local names = {"GameTooltip", "ItemRefTooltip", "ShoppingTooltip1",
  "ShoppingTooltip2", "WorldMapTooltip", "AtlasLootTooltip"}

local function Enabled()
  return addon.db and addon.db.tooltips and addon.db.tooltips.enabled and
    pfUI and pfUI.GetExpeditionComponentOwner and
    pfUI:GetExpeditionComponentOwner("tooltips.shells") == "tooltips"
end

local function Tint(art, r, g, b, a)
  for _, texture in ipairs(art.slices) do
    texture:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
  end
end

local function Skin(frame, enabled, health)
  if not frame or not frame.backdrop then return false end
  local art = frame.aeuiTooltipArt
  if not art and not enabled then return false end
  if not art then
    local backdrop = frame.backdrop
    art = {slices = {}, backdrop = backdrop, setBackdrop = backdrop.SetBackdrop}
    frame.aeuiTooltipArt = art
    art.bed = backdrop:CreateTexture(nil, "BACKGROUND")
    art.bed:SetAllPoints(frame)
    -- The readout donor has a one-UI rim and a transparent interior.
    local u, v = {0, 4/512, 258/512, 262/512}, {0, 1/16, 13/16, 14/16}
    local x, y = {-1, 3, -3, 1}, {1, 0, 0, -1}
    local path = addon.media.root .. "ActionBars\\Readouts\\ReadoutShellV1"
    for row = 1, 3 do
      for column = 1, 3 do
        if row ~= 2 or column ~= 2 then
          local texture = backdrop:CreateTexture(nil, "ARTWORK")
          texture:SetTexture(path)
          texture:SetTexCoord(u[column], u[column+1], v[row], v[row+1])
          texture:SetPoint("TOPLEFT", frame,
            (row <= 2 and "TOP" or "BOTTOM") .. (column <= 2 and "LEFT" or "RIGHT"),
            x[column], y[row])
          texture:SetPoint("BOTTOMRIGHT", frame,
            (row+1 <= 2 and "TOP" or "BOTTOM") .. (column+1 <= 2 and "LEFT" or "RIGHT"),
            x[column+1], y[row+1])
          table.insert(art.slices, texture)
        end
      end
    end
    -- Map/third-party skins may rebuild their backdrop on each show.
    backdrop.SetBackdrop = function(self, value)
      if art.active then art.original = value; value = nil end
      art.setBackdrop(self, value)
    end
    for _, object in ipairs({frame, backdrop}) do
      local original = object.SetBackdropBorderColor
      object.SetBackdropBorderColor = function(self, r, g, b, a)
        original(self, r, g, b, a)
        if art.active then
          art.border = {r, g, b, a or 1}
          Tint(art, r, g, b, a)
        end
      end
    end
  end
  if enabled then
    if not art.active then
      art.original = art.backdrop:GetBackdrop()
      art.background = {art.backdrop:GetBackdropColor()}
      art.border = {art.backdrop:GetBackdropBorderColor()}
      art.shadow = frame.backdrop_shadow and frame.backdrop_shadow:IsShown()
      art.extraBorder = frame.backdrop_border and frame.backdrop_border:IsShown()
      if health then
        local texture = frame.GetStatusBarTexture and frame:GetStatusBarTexture()
        art.fill = type(texture) == "string" and texture or
          (texture and texture.GetTexture and texture:GetTexture())
        local config = pfUI_config and pfUI_config.tooltip
        art.fill = art.fill or (config and config.statusbar and pfUI.media and
          pfUI.media[config.statusbar.texture])
      end
      art.active = true
      Tint(art, 1, 1, 1, 1)
    end
    art.setBackdrop(art.backdrop, nil)
    local config = pfUI_config and pfUI_config.tooltip
    art.bed:SetTexture(0.10, 0.065, 0.04, tonumber(config and config.alpha) or 1)
    art.bed:Show()
    for _, texture in ipairs(art.slices) do texture:Show() end
    if frame.backdrop_shadow then frame.backdrop_shadow:Hide() end
    if frame.backdrop_border then frame.backdrop_border:Hide() end
    if health and art.fill then
      frame:SetStatusBarTexture(addon.media.root .. "UnitFrames\\UnitFrameHealthFillV1")
    end
  elseif art.active then
    art.active = false
    art.bed:Hide()
    for _, texture in ipairs(art.slices) do texture:Hide() end
    art.setBackdrop(art.backdrop, art.original)
    art.backdrop:SetBackdropColor(unpack(art.background))
    art.backdrop:SetBackdropBorderColor(unpack(art.border))
    if frame.backdrop_shadow and art.shadow then frame.backdrop_shadow:Show() end
    if frame.backdrop_border and art.extraBorder then frame.backdrop_border:Show() end
    if health and art.fill then frame:SetStatusBarTexture(art.fill) end
  end
  return enabled
end

function Tooltips:Apply()
  local enabled, count = Enabled(), 0
  for _, name in ipairs(names) do
    local frame = getglobal(name)
    if frame then
      if not frame.aeuiTooltipHook then
        local original = frame:GetScript("OnShow")
        frame:SetScript("OnShow", function()
          if original then original() end
          Skin(frame, Enabled())
        end)
        frame.aeuiTooltipHook = true
      end
      if Skin(frame, enabled) then count = count + 1 end
    end
  end
  Skin(getglobal("GameTooltipStatusBar"), enabled, true)
  self.appliedCount = count
end

function Tooltips:Initialize()
  self:Apply()
  local events = CreateFrame("Frame")
  events:RegisterEvent("ADDON_LOADED")
  events:SetScript("OnEvent", function() Tooltips:Apply() end)
  self.events = events
end

function Tooltips:GetRuntimeStatus()
  return "contract=1.0, shells=" .. tostring(self.appliedCount or 0) ..
    ", textures=2x, fallback=pfui"
end
addon:RegisterModule("Tooltips", Tooltips)
