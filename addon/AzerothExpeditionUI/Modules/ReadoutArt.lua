local addon = AzerothExpeditionUI
local Art = {}
local media = addon.media.root .. "ActionBars\\Readouts\\"
local function Enabled(route)
  return addon.db and addon.db.actionbars and addon.db.actionbars.enabled and
    pfUI and pfUI.GetExpeditionComponentOwner and
    pfUI:GetExpeditionComponentOwner(route or "actionbars.readout-art") == "actionbars"
end

local function Shown(frame, value)
  if frame then if value then frame:Show() else frame:Hide() end end
end

local function Shell(frame, enabled, anchor)
  if not frame then return false end
  anchor = anchor or frame
  local art = frame.aeuiReadoutArt
  if not enabled then
    if art then
      for _, texture in ipairs(art.slices) do texture:Hide() end
      art.bed:Hide()
      Shown(frame.backdrop, art.backdrop)
      Shown(frame.backdrop_shadow, art.shadow)
      art.active = false
    end
    return false
  end
  if not art then
    art = { slices = {} }
    art.bed = frame:CreateTexture(nil, "BACKGROUND")
    art.bed:SetTexture(0.15, 0.14, 0.12, 1)
    art.bed:SetAllPoints(anchor)
    -- Logical UVs address the 1024x32 two-texel container.
    local u, v = {0, 4/512, 258/512, 262/512}, {0, 1/16, 13/16, 14/16}
    local x, y = {-1, 3, -3, 1}, {1, 0, 0, -1}
    for row = 1, 3 do
      for column = 1, 3 do
        local texture = frame:CreateTexture(nil, "BACKGROUND")
        texture:SetTexture(media .. "ReadoutShellV1")
        texture:SetTexCoord(u[column], u[column+1], v[row], v[row+1])
        texture:SetPoint("TOPLEFT", anchor,
          (row <= 2 and "TOP" or "BOTTOM") .. (column <= 2 and "LEFT" or "RIGHT"),
          x[column], y[row])
        texture:SetPoint("BOTTOMRIGHT", anchor,
          (row+1 <= 2 and "TOP" or "BOTTOM") .. (column+1 <= 2 and "LEFT" or "RIGHT"),
          x[column+1], y[row+1])
        table.insert(art.slices, texture)
      end
    end
    frame.aeuiReadoutArt = art
  end
  if not art.active then
    art.backdrop = frame.backdrop and frame.backdrop:IsShown()
    art.shadow = frame.backdrop_shadow and frame.backdrop_shadow:IsShown()
  end
  Shown(frame.backdrop, false)
  Shown(frame.backdrop_shadow, false)
  art.bed:Show()
  for _, texture in ipairs(art.slices) do texture:Show() end
  art.active = true
  return true
end

local function Fill(object, path, enabled, statusbar, fallback)
  if not object then return end
  if enabled then
    if not object.aeuiReadoutFill then
      local texture = object
      if statusbar then
        texture = object.GetStatusBarTexture and object:GetStatusBarTexture()
      end
      local original = type(texture) == "string" and texture or
        (texture and texture.GetTexture and texture:GetTexture()) or fallback
      if not original then return end
      object.aeuiReadoutFill = original
    end
  elseif object.aeuiReadoutFill then
    path = object.aeuiReadoutFill
    object.aeuiReadoutFill = nil
  else
    return
  end
  if statusbar then object:SetStatusBarTexture(path) else object:SetTexture(path) end
end

local function DoiteSkin(frame, enabled, bare, anchor)
  if not frame then return end
  local state = frame.aeuiDoiteSkin
  if not state and not enabled then return end
  if not state then
    state = {setBorder = frame.SetBackdropBorderColor}
    state.signal = frame:CreateTexture(nil, "OVERLAY")
    state.signal:SetPoint("BOTTOMLEFT", anchor or frame, "BOTTOMLEFT", 1, 0)
    state.signal:SetPoint("BOTTOMRIGHT", anchor or frame, "BOTTOMRIGHT", -1, 0)
    state.signal:SetHeight(1)
    state.signal:Hide()
    frame.aeuiDoiteSkin = state
    frame.SetBackdropBorderColor = function(self, r, g, b, a)
      state.setBorder(self, r, g, b, a)
      if state.active then
        state.border = {r, g, b, a or 1}
        state.signal:SetTexture(r, g, b, a or 1)
      end
    end
  end
  if enabled and not state.active then
    state.backdrop = frame:GetBackdrop()
    state.background = {frame:GetBackdropColor()}
    state.border = {frame:GetBackdropBorderColor()}
    frame:SetBackdrop(nil)
  end
  Shell(frame, enabled, anchor)
  if enabled then
    state.active = true
    frame.aeuiReadoutArt.bed:SetTexture(0.10, 0.065, 0.04, 0.55)
    if bare then
      frame.aeuiReadoutArt.bed:Hide()
      for _, texture in ipairs(frame.aeuiReadoutArt.slices) do texture:Hide() end
    end
    Shown(state.signal, not bare)
    frame:SetBackdropBorderColor(unpack(state.border))
  elseif state.active then
    state.active = false
    state.signal:Hide()
    frame:SetBackdrop(state.backdrop)
    frame:SetBackdropColor(unpack(state.background))
    state.setBorder(frame, unpack(state.border))
  end
end

function Art:ApplyDoite()
  local ui = DoiteDPS and DoiteDPS.UI
  if not ui then return end
  local enabled = Enabled("actionbars.doite-art")
  for _, key in ipairs({"readySlot", "currentIcon", "currentGhost",
    "resourceRoot", "tankAssistBadge"}) do
    DoiteSkin(ui[key], enabled, key == "currentIcon" or key == "currentGhost",
      key == "readySlot" and ui.currentIcon or nil)
  end
  for _, key in ipairs({"forecastIcons", "resourceIcons"}) do
    for _, frame in ipairs(ui[key] or {}) do DoiteSkin(frame, enabled) end
  end
  if ui.track and ui.railShadow then
    local rail = ui.track.aeuiDoiteRail
    if enabled and not rail then
      rail = ui.track:CreateTexture(nil, "BACKGROUND")
      rail:SetTexture(media .. "CastFillV1")
      rail:SetVertexColor(0.65, 0.48, 0.27, 0.65)
      rail:SetAllPoints(ui.railShadow)
      ui.track.aeuiDoiteRail = rail
    end
    Shown(rail, enabled)
    if enabled and ui.track.aeuiDoiteShadowShown == nil then
      ui.track.aeuiDoiteShadowShown = ui.railShadow:IsShown() and true or false
    end
    if enabled then
      ui.railShadow:Hide()
    elseif ui.track.aeuiDoiteShadowShown ~= nil then
      Shown(ui.railShadow, ui.track.aeuiDoiteShadowShown)
      ui.track.aeuiDoiteShadowShown = nil
    end
  end
  self.doiteApplied = enabled
end

local function SkinDoiteAura(key)
  if type(key) ~= "string" then return end
  local data = DoiteAurasDB and DoiteAurasDB.spells and DoiteAurasDB.spells[key]
  local frame = getglobal("DoiteIcon_" .. key)
  if not frame or not frame.icon or not data or data.type == "Bar" then return end
  local enabled = Enabled("actionbars.doiteauras-art")
  local art = frame.aeuiReadoutArt
  if art and art.active == (enabled and true or false) and
    art.providerBackdrop == frame.backdrop then return end
  if art and art.providerBackdrop ~= frame.backdrop then art.active = false end
  Shell(frame, enabled)
  art = frame.aeuiReadoutArt
  if art then
    art.providerBackdrop = frame.backdrop
    -- DoiteAuras icons occupy BACKGROUND: keep only the rim above them.
    art.bed:Hide()
    for i, texture in ipairs(art.slices) do
      texture:SetDrawLayer("ARTWORK")
      if i == 5 then texture:Hide() end
    end
  end
end

function Art:ApplyDoiteAuras()
  if not DoiteAurasDB or not DoiteAurasDB.spells then return end
  for key in pairs(DoiteAurasDB.spells) do SkinDoiteAura(key) end
  if not self.doiteAurasHooked and type(DoiteAuras_GetIconFrame) == "function" and
    type(hooksecurefunc) == "function" then
    hooksecurefunc("DoiteAuras_GetIconFrame", SkinDoiteAura)
    if type(DoiteAuras_ApplyBorderToAllIcons) == "function" then
      hooksecurefunc("DoiteAuras_ApplyBorderToAllIcons", function() Art:ApplyDoiteAuras() end)
    end
    self.doiteAurasHooked = true
  end
end

function Art:Apply()
  local enabled = Enabled()
  local count = 0
  local castbars = pfUI and pfUI.castbar
  local config = pfUI_config or {}
  local appearance = config.appearance and config.appearance.castbar
  local castTexture = appearance and pfUI and pfUI.media and pfUI.media[appearance.texture]
  local swingTexture = config.unitframes and config.unitframes.swingtimertexture or
    "Interface\\AddOns\\pfUI\\img\\bar"
  for _, role in ipairs({"player", "target", "focus"}) do
    local cast = castbars and castbars[role]
    if cast then
      if Shell(cast.bar, enabled) then count = count + 1 end
      Shell(cast.icon, enabled)
      Fill(cast.bar, media .. "CastFillV1", enabled, true, castTexture)
    end
  end
  local swing = pfUI and pfUI.swingtimer
  for _, role in ipairs({"mainhand", "offhand", "ranged"}) do
    local frame = swing and swing[role]
    if frame then
      if Shell(frame, enabled) then count = count + 1 end
      if role == "ranged" then
        for _, key in ipairs({"left", "right", "warn"}) do
          Fill(frame[key], media .. "SwingFillV1", enabled, false)
        end
      else
        Fill(frame, media .. "SwingFillV1", enabled, true, swingTexture)
      end
    end
  end
  self.appliedCount = count
  self:ApplyDoite()
  self:ApplyDoiteAuras()
end

function Art:Initialize()
  self:Apply()
  local listener = CreateFrame("Frame")
  listener:RegisterEvent("ADDON_LOADED")
  listener:SetScript("OnEvent", function()
    if arg1 == "DoiteDPS" then Art:ApplyDoite() end
    if arg1 == "DoiteAuras" then Art:ApplyDoiteAuras() end
  end)
  self.listener = listener
end
function Art:GetRuntimeStatus()
  return "contract=1.0, readouts=" .. tostring(self.appliedCount or 0) ..
    "/6, border=1UI, textures=2x, fallback=pfui, doite=" ..
    (self.doiteApplied and "active" or "inactive")
end
addon:RegisterModule("ReadoutArt", Art)
