local addon = AzerothExpeditionUI
local Bags = {}
local names = {"Bags", "Bank", "Keyring"}
local records = {}
local slotTextures = {}
local textLayers = {}
local qualityRims = {}
local media = addon.media.root .. "Bagshui\\"
local controls = addon.media.root .. "GearPlanner\\"
local slotMedia = addon.media.root .. "Character\\"

local function IsQualityColor(info, r, g, b)
  local quality = info.qualityColor
  return info.item and quality and math.abs(r-quality.r) < 0.0001 and
    math.abs(g-quality.g) < 0.0001 and math.abs(b-quality.b) < 0.0001
end

local function QualityRim(button)
  local info = button.bagshuiData
  local border = info.buttonComponents.border
  if not border or not info.item then return end
  local rim = border.aeuiQualityRim
  if not rim then
    rim = {textures = {}, setColor = border.SetBackdropBorderColor}
    border.aeuiQualityRim = rim
    -- One UI of dye inside the leather edge; no change to provider geometry.
    local anchors = {
      {"TOPLEFT", "TOPRIGHT", 2, -2, -2, -3},
      {"BOTTOMLEFT", "BOTTOMRIGHT", 2, 3, -2, 2},
      {"TOPLEFT", "BOTTOMLEFT", 2, -3, 3, 3},
      {"TOPRIGHT", "BOTTOMRIGHT", -3, -3, -2, 3},
    }
    for _, p in ipairs(anchors) do
      local t = border:CreateTexture(nil, "BORDER")
      t:SetTexture(1, 1, 1, 1)
      t:SetPoint("TOPLEFT", button, p[1], p[3], p[4])
      t:SetPoint("BOTTOMRIGHT", button, p[2], p[5], p[6])
      table.insert(rim.textures, t)
    end
    border.SetBackdropBorderColor = function(self, r, g, b, a)
      rim.color = {r, g, b, a or 1}
      local dye = rim.active and IsQualityColor(info, r, g, b)
      rim.setColor(self, r, g, b, dye and 0 or a)
      for _, t in ipairs(rim.textures) do
        if dye then
          local red, green, blue = 0.43, 0.36, 0.27
          if (info.item.quality or 0) > 1 then
            local gray = (r+g+b)/3
            red, green, blue = (r*0.75+gray*0.25)*0.72,
              (g*0.75+gray*0.25)*0.72, (b*0.75+gray*0.25)*0.72
          end
          t:SetVertexColor(red, green, blue, a or 1)
          t:Show()
        else t:Hide() end
      end
    end
    -- Bagshui also paints quality through a separate, oversized glow texture.
    -- Suppress that duplicate, while retaining its container-selection color.
    local glow = info.buttonComponents.innerGlow
    if glow then
      rim.glow = glow
      local setColor = glow.SetVertexColor
      glow.SetVertexColor = function(self, r, g, b, a)
        rim.glowColor = {r, g, b, a or 1}
        setColor(self, r, g, b,
          rim.active and IsQualityColor(info, r, g, b) and 0 or a)
      end
    end
  end
  if not rim.active then
    rim.color = {border:GetBackdropBorderColor()}
    if rim.glow then rim.glowColor = {rim.glow:GetVertexColor()} end
    rim.active = true
    qualityRims[border] = rim
    border:SetBackdropBorderColor(unpack(rim.color))
    if rim.glow then rim.glow:SetVertexColor(unpack(rim.glowColor)) end
  end
end

local function ForegroundText(text)
  if not text then return end
  if not textLayers[text] then textLayers[text] = text:GetDrawLayer() end
  text:SetDrawLayer("OVERLAY")
end

local function SlotTexture(texture, button, path, uv, layer)
  if not texture or slotTextures[texture] then return end
  local saved = {path = texture:GetTexture(), uv = {texture:GetTexCoord()},
    width = texture:GetWidth(), height = texture:GetHeight(), points = {},
    layer = texture:GetDrawLayer()}
  for i = 1, texture:GetNumPoints() do
    table.insert(saved.points, {texture:GetPoint(i)})
  end
  slotTextures[texture] = saved
  texture:SetTexture(slotMedia .. path)
  texture:SetTexCoord(unpack(uv))
  texture:ClearAllPoints()
  texture:SetAllPoints(button)
  if layer then texture:SetDrawLayer(layer) end
  -- Provider keeps control of vertex color, alpha, visibility and blend mode.
end

local function Slot(button)
  local parts = button.bagshuiData and button.bagshuiData.buttonComponents
  if not parts then return end
  SlotTexture(parts.normalTexture, button, "CharacterSlotBaseAtlasV3",
    {0, 74/256, 128/256, 202/256}, "ARTWORK")
  SlotTexture(parts.highlightTexture, button, "CharacterSlotInteractionAtlasV3",
    {0, 74/512, 0, 74/128})
  SlotTexture(parts.pushedTexture, button, "CharacterSlotInteractionAtlasV3",
    {128/512, 202/512, 0, 74/128})
  ForegroundText(parts.count)
  ForegroundText(parts.stock)
  QualityRim(button)
end

local function ShowShell(art, visible)
  local method = visible and "Show" or "Hide"
  art[method](art)
  if art.bed then art.bed[method](art.bed) end
  for _, texture in ipairs(art.slices) do texture[method](texture) end
end

local function Enabled()
  return addon.db and addon.db.bagshui and addon.db.bagshui.enabled and
    pfUI and pfUI.GetExpeditionComponentOwner and
    pfUI:GetExpeditionComponentOwner("bagshui.inventory-art") == "bagshui"
end

local function Owned(inventory)
  if not Bagshui or not Bagshui.components then return false end
  for _, name in ipairs(names) do
    if inventory == Bagshui.components[name] then return true end
  end
  return false
end

-- Art follows actual frames; no provider anchors, dimensions or scripts change.
local function Shell(frame, window)
  if not frame then return end
  local saved = records[frame]
  if not saved then
    saved = {backdrop = frame:GetBackdrop(), color = {frame:GetBackdropColor()},
      border = {frame:GetBackdropBorderColor()}}
    records[frame] = saved
    local art = frame.aeuiBagshuiArt
    if not art then
      art = CreateFrame("Frame", nil, frame)
      art:SetAllPoints(frame)
      art:SetFrameLevel(math.max(0, frame:GetFrameLevel() - (window and 0 or 1)))
      art:EnableMouse(false)
      frame.aeuiBagshuiArt = art
      do
        -- Extend the rim outward, leaving the provider's content clearance intact.
        local u = window and {0, 0.125, 0.875, 1} or {0, 0.125, 0.625, 0.75}
        local x = window and {-10, 2, -2, 10} or {0, 3, -3, 0}
        local y = window and {10, -2, 2, -10} or {0, -3, 3, 0}
        art.slices = {}
        for row = 1, 3 do
          for col = 1, 3 do
            if row ~= 2 or col ~= 2 then
              -- Control art belongs to the button's draw layers, below its icon.
              local t = (window and art or frame):CreateTexture(nil, "BORDER")
              t:SetTexture(window and media .. "SatchelFrameV1" or controls .. "GearPlannerFrameAtlasV1")
              t:SetTexCoord(u[col], u[col+1], u[row], u[row+1])
              t:SetPoint("TOPLEFT", frame,
                (row <= 2 and "TOP" or "BOTTOM") .. (col <= 2 and "LEFT" or "RIGHT"), x[col], y[row])
              t:SetPoint("BOTTOMRIGHT", frame,
                (row < 2 and "TOP" or "BOTTOM") .. (col < 2 and "LEFT" or "RIGHT"), x[col+1], y[row+1])
              table.insert(art.slices, t)
            end
          end
        end
      end
    end
    saved.art = art
    if window then
      art:SetBackdrop({bgFile = media .. "SatchelClothV1", tile = true, tileSize = 64})
      -- Tint the backdrop itself; a full-window ARTWORK wash can cover labels.
      art:SetBackdropColor(0.48, 0.46, 0.42, 1)
    elseif not art.bed then
      art.bed = frame:CreateTexture(nil, "BACKGROUND")
      art.bed:SetAllPoints(frame)
      art.bed:SetTexture(controls .. "GearPlannerLeatherFillV1")
    end
  end
  frame:SetBackdrop(nil)
  ShowShell(saved.art, true)
  return saved.art
end

local function Group(ui, group)
  if not Owned(ui.inventory) then return end
  if not Enabled() or ui.inventory.editMode then return end
  -- Move targets are intentionally excluded: their yellow feedback is functional.
  local actual = false
  for _, candidate in pairs(ui.frames.groups) do
    if candidate == group then actual = true; break end
  end
  if not actual then return end
  group:SetBackdropColor(0.17, 0.12, 0.07, 0.28)
  group:SetBackdropBorderColor(0.48, 0.36, 0.20, 0.45)

end

local function ApplyInventory(inventory)
  if not Enabled() or not Owned(inventory) or not inventory.ui or not inventory.uiFrame then return end
  local ui = inventory.ui
  local art = Shell(inventory.uiFrame, true)
  -- Bagshui uses a red border to identify another character's cached inventory.
  if art and art.slices then
    for _, t in ipairs(art.slices) do
      t:SetVertexColor(1, inventory.online and 1 or 0.35, inventory.online and 1 or 0.3, 1)
    end
  end
  for _, group in pairs(ui.frames.groups or {}) do Group(ui, group) end
  Shell(ui.frames.searchBox)
  for _, button in pairs(ui.buttons and ui.buttons.toolbar or {}) do
    Shell(button)
  end
  for _, kind in ipairs({"itemSlots", "bagSlots"}) do
    for _, button in pairs(ui.buttons and ui.buttons[kind] or {}) do Slot(button) end
  end
end

function Bags:Apply()
  if not Enabled() then
    for border, rim in pairs(qualityRims) do
      rim.active = false
      border:SetBackdropBorderColor(unpack(rim.color))
      if rim.glow then rim.glow:SetVertexColor(unpack(rim.glowColor)) end
      qualityRims[border] = nil
    end
    for text, layer in pairs(textLayers) do
      text:SetDrawLayer(layer)
      textLayers[text] = nil
    end
    for texture, saved in pairs(slotTextures) do
      texture:SetTexture(saved.path)
      texture:SetTexCoord(unpack(saved.uv))
      texture:SetDrawLayer(saved.layer)
      texture:ClearAllPoints()
      texture:SetWidth(saved.width)
      texture:SetHeight(saved.height)
      for _, point in ipairs(saved.points) do texture:SetPoint(unpack(point)) end
      slotTextures[texture] = nil
    end
    for frame, saved in pairs(records) do
      ShowShell(saved.art, false)
      frame:SetBackdrop(saved.backdrop)
      frame:SetBackdropColor(unpack(saved.color))
      frame:SetBackdropBorderColor(unpack(saved.border))
      records[frame] = nil
    end
  end
  if not Bagshui or not Bagshui.prototypes then return end
  local prototype = Bagshui.prototypes.Inventory
  local uiPrototype = Bagshui.prototypes.InventoryUi
  if not prototype or not uiPrototype then return end
  if not self.hooked then
    self.hooked = true
    local original = prototype.UpdateWindow
    prototype.UpdateWindow = function(inventory)
      local compact = Enabled() and Owned(inventory) and inventory.settings and true or false
      if Owned(inventory) and inventory.aeuiCompactItems ~= compact then
        inventory.aeuiCompactItems = compact
        inventory.windowUpdateNeeded = true
      end
      local result
      if compact then
        -- Read-only layout override: bypass Settings.__newindex/SavedVariables,
        -- and restore even if the provider throws. Native border clearance remains.
        local settings = inventory.settings
        local margin = rawget(settings, "itemMargin")
        rawset(settings, "itemMargin", 0)
        local ok, value = pcall(original, inventory)
        rawset(settings, "itemMargin", margin)
        if not ok then error(value) end
        result = value
      else result = original(inventory) end
      ApplyInventory(inventory)
      return result
    end
    local colors = uiPrototype.SetGroupColors
    uiPrototype.SetGroupColors = function(ui, group, mouseDown)
      colors(ui, group, mouseDown)
      Group(ui, group)
    end
  end
  for _, name in ipairs(names) do
    local inventory = Bagshui.components[name]
    if inventory and inventory.ui then
      if inventory.settings and inventory.aeuiCompactItems ~= (Enabled() and true or false) then
        inventory:UpdateWindow()
      end
      if Enabled() then ApplyInventory(inventory)
      else
        for _, group in pairs(inventory.ui.frames.groups or {}) do
          inventory.ui:SetGroupColors(group)
        end
      end
    end
  end
end

function Bags:Initialize()
  self:Apply()
  local events = CreateFrame("Frame")
  events:RegisterEvent("ADDON_LOADED")
  events:SetScript("OnEvent", function() Bags:Apply() end)
  self.events = events
end

function Bags:GetRuntimeStatus()
  return "contract=1.3, provider=" .. (Bagshui and "Bagshui" or "missing") ..
    ", enabled=" .. tostring(Enabled() and true or false) .. ", textures=2x"
end
addon:RegisterModule("Bagshui", Bags)
