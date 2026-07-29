local addon = AzerothExpeditionUI
local Chat = {}

local WHITE_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local CHAT_MEDIA = addon.media.root .. "Chat\\"
local BOOK_TEXTURE = CHAT_MEDIA .. "ChatBookFrame"

-- The source art occupies the top 586 pixels of a 1024 x 1024 texture.
-- These cuts follow the inner parchment edge and let the frame behave as a
-- nine-slice without requiring a modern NineSlice API.
local BOOK_UV = {
  left = 0.111328125,
  right = 0.845703125,
  upper = 0.091796875,
  lower = 0.490234375,
  bottom = 0.572265625,
}

local TEXTURES = {
  tabNormal = CHAT_MEDIA .. "ChatTabNormal",
  tabHover = CHAT_MEDIA .. "ChatTabHover",
  tabSelected = CHAT_MEDIA .. "ChatTabSelected",
  tabShelf = CHAT_MEDIA .. "ChatTabShelf",
  input = CHAT_MEDIA .. "ChatInputStrip",
  waxSeal = CHAT_MEDIA .. "ChatWaxSeal",
}

local COLORS = {
  ink = { 0.105, 0.060, 0.025, 0.20 },
  text = { 0.900, 0.790, 0.570, 1.00 },
  textSelected = { 0.190, 0.095, 0.035, 1.00 },
}

local TAB_TINTS = {
  { 1.00, 0.96, 0.88, 1 },
  { 0.94, 0.88, 0.78, 1 },
  { 0.98, 0.91, 0.80, 1 },
  { 0.92, 0.86, 0.76, 1 },
  { 0.96, 0.90, 0.82, 1 },
  { 0.90, 0.84, 0.74, 1 },
}

local function SetTextureColor(texture, color)
  texture:SetTexture(WHITE_TEXTURE)
  texture:SetVertexColor(color[1], color[2], color[3], color[4])
end

local function EnsureComponentTexture(parent, key, layer, texturePath)
  if not parent[key] then
    parent[key] = parent:CreateTexture(nil, layer or "BACKGROUND")
    parent[key]:SetAllPoints(parent)
  end
  parent[key]:SetTexture(texturePath)
  return parent[key]
end

local function ConfigureBookSlice(
  owner,
  key,
  left,
  right,
  top,
  bottom,
  point1,
  relativePoint1,
  x1,
  y1,
  point2,
  relativePoint2,
  x2,
  y2,
  brightness
)
  owner.aeuiBookSlices = owner.aeuiBookSlices or {}

  local texture = owner.aeuiBookSlices[key]
  if not texture then
    texture = owner:CreateTexture(nil, "BACKGROUND")
    owner.aeuiBookSlices[key] = texture
  end

  texture:SetTexture(BOOK_TEXTURE)
  texture:SetTexCoord(left, right, top, bottom)
  texture:SetBlendMode("BLEND")
  texture:SetVertexColor(
    brightness,
    brightness * 0.94,
    brightness * 0.82,
    1
  )
  texture:ClearAllPoints()
  texture:SetPoint(point1, owner, relativePoint1, x1, y1)
  texture:SetPoint(point2, owner, relativePoint2, x2, y2)
  texture:Show()
end

local function HookHoverState(frame)
  if frame.aeuiHoverHooked or not frame.GetScript then
    return
  end

  frame.aeuiHoverHooked = true
  frame.aeuiOriginalOnEnter = frame:GetScript("OnEnter")
  frame.aeuiOriginalOnLeave = frame:GetScript("OnLeave")

  frame:SetScript("OnEnter", function()
    frame.aeuiHovered = true
    if frame.aeuiOriginalOnEnter then
      frame.aeuiOriginalOnEnter(frame)
    end
    Chat:Maintain()
  end)

  frame:SetScript("OnLeave", function()
    frame.aeuiHovered = nil
    if frame.aeuiOriginalOnLeave then
      frame.aeuiOriginalOnLeave(frame)
    end
    Chat:Maintain()
  end)
end

local function MakeBackdropTransparent(frame)
  if frame and frame.backdrop then
    frame.backdrop:SetBackdropColor(0, 0, 0, 0)
    frame.backdrop:SetBackdropBorderColor(0, 0, 0, 0)
  end
  if frame and frame.shadow then
    frame.shadow:SetAlpha(0)
  end
end

local function IsDockedIn(frame, owner)
  return frame and frame.isDocked and frame:GetParent() == owner
end

function Chat:Initialize()
  self.driver = CreateFrame("Frame", "AzerothExpeditionUIChatDriver", UIParent)
  self:InstallHooks()
  self.driver:SetScript("OnUpdate", function()
    if not addon.db or not addon.db.chat.enabled then
      return
    end

    local now = GetTime()
    if Chat.nextMaintain and now < Chat.nextMaintain then
      return
    end

    Chat.nextMaintain =
      now + (addon.db.chat.maintainInterval or 0.25)
    Chat:Maintain()
  end)
end

function Chat:InstallHooks()
  if self.hooksInstalled or type(hooksecurefunc) ~= "function" then
    return
  end

  self.hooksInstalled = true

  if type(getglobal("FCF_SelectDockFrame")) == "function" then
    hooksecurefunc("FCF_SelectDockFrame", function()
      Chat:Maintain()
    end)
  end

  if type(getglobal("FCF_DockUpdate")) == "function" then
    hooksecurefunc("FCF_DockUpdate", function()
      Chat:Maintain()
    end)
  end

end

function Chat:Apply()
  if not addon.db.chat.enabled then
    return
  end

  if not pfUI or not pfUI.chat or not pfUI.chat.left then
    addon:ScheduleRefresh(0.5)
    return
  end

  local owner = pfUI.chat.left
  if pfUI.chat.hideLock then
    addon:ScheduleRefresh(0.1)
    return
  end

  local resized = self:EnsureMinimumSize(owner)

  if resized and pfUI.chat.RefreshChat then
    pfUI.chat:RefreshChat()
  end

  self:EnsureBook(owner)
  self:LayoutChatFrames(owner)
  self:StyleInput(owner)
  self:SuppressLegacyInfoPanels()
  self:Maintain()
end

function Chat:EnsureMinimumSize(owner)
  local resized = false
  local minimumWidth = tonumber(addon.db.chat.minimumWidth) or 440
  local minimumHeight = tonumber(addon.db.chat.minimumHeight) or 320

  if owner:GetWidth() < minimumWidth then
    owner:SetWidth(minimumWidth)
    resized = true
  end
  if owner:GetHeight() < minimumHeight then
    owner:SetHeight(minimumHeight)
    resized = true
  end

  return resized
end

function Chat:EnsureBook(owner)
  MakeBackdropTransparent(owner)
  MakeBackdropTransparent(owner.panelTop)

  if owner.aeuiBookTexture then
    owner.aeuiBookTexture:Hide()
  end

  local brightness = tonumber(addon.db.chat.bookBrightness) or 0.78

  ConfigureBookSlice(
    owner, "center",
    BOOK_UV.left, BOOK_UV.right, BOOK_UV.upper, BOOK_UV.lower,
    "TOPLEFT", "TOPLEFT", 42, -50,
    "BOTTOMRIGHT", "BOTTOMRIGHT", -42, 58,
    brightness
  )
  ConfigureBookSlice(
    owner, "top",
    BOOK_UV.left, BOOK_UV.right, 0, BOOK_UV.upper,
    "TOPLEFT", "TOPLEFT", 42, 26,
    "BOTTOMRIGHT", "TOPRIGHT", -42, -50,
    brightness
  )
  ConfigureBookSlice(
    owner, "bottom",
    BOOK_UV.left, BOOK_UV.right, BOOK_UV.lower, BOOK_UV.bottom,
    "TOPLEFT", "BOTTOMLEFT", 42, 58,
    "BOTTOMRIGHT", "BOTTOMRIGHT", -42, -16,
    brightness
  )
  ConfigureBookSlice(
    owner, "left",
    0, BOOK_UV.left, BOOK_UV.upper, BOOK_UV.lower,
    "TOPLEFT", "TOPLEFT", -10, -50,
    "BOTTOMRIGHT", "BOTTOMLEFT", 42, 58,
    brightness
  )
  ConfigureBookSlice(
    owner, "right",
    BOOK_UV.right, 1, BOOK_UV.upper, BOOK_UV.lower,
    "TOPLEFT", "TOPRIGHT", -42, -50,
    "BOTTOMRIGHT", "BOTTOMRIGHT", 10, 58,
    brightness
  )
  ConfigureBookSlice(
    owner, "topLeft",
    0, BOOK_UV.left, 0, BOOK_UV.upper,
    "TOPLEFT", "TOPLEFT", -10, 26,
    "BOTTOMRIGHT", "TOPLEFT", 42, -50,
    brightness
  )
  ConfigureBookSlice(
    owner, "topRight",
    BOOK_UV.right, 1, 0, BOOK_UV.upper,
    "TOPLEFT", "TOPRIGHT", -42, 26,
    "BOTTOMRIGHT", "TOPRIGHT", 10, -50,
    brightness
  )
  ConfigureBookSlice(
    owner, "bottomLeft",
    0, BOOK_UV.left, BOOK_UV.lower, BOOK_UV.bottom,
    "TOPLEFT", "BOTTOMLEFT", -10, 58,
    "BOTTOMRIGHT", "BOTTOMLEFT", 42, -16,
    brightness
  )
  ConfigureBookSlice(
    owner, "bottomRight",
    BOOK_UV.right, 1, BOOK_UV.lower, BOOK_UV.bottom,
    "TOPLEFT", "BOTTOMRIGHT", -42, 58,
    "BOTTOMRIGHT", "BOTTOMRIGHT", 10, -16,
    brightness
  )

  if not owner.aeuiTabShelf then
    owner.aeuiTabShelf = owner:CreateTexture(nil, "BORDER")
    owner.aeuiTabShelf:SetTexture(TEXTURES.tabShelf)
  end
  owner.aeuiTabShelf:ClearAllPoints()
  owner.aeuiTabShelf:SetPoint("TOPLEFT", owner, "TOPLEFT", 35, 24)
  owner.aeuiTabShelf:SetPoint("TOPRIGHT", owner, "TOPRIGHT", -35, 24)
  owner.aeuiTabShelf:SetHeight(64)
  owner.aeuiTabShelf:Show()

  if not owner.aeuiReadingWash then
    owner.aeuiReadingWash = owner:CreateTexture(nil, "BACKGROUND")
  end
  owner.aeuiReadingWash:ClearAllPoints()
  owner.aeuiReadingWash:SetPoint("TOPLEFT", owner, "TOPLEFT", 38, -47)
  owner.aeuiReadingWash:SetPoint(
    "BOTTOMRIGHT",
    owner,
    "BOTTOMRIGHT",
    -38,
    57
  )
  SetTextureColor(owner.aeuiReadingWash, COLORS.ink)
end

function Chat:LayoutChatFrames(owner)
  for index = 1, NUM_CHAT_WINDOWS do
    local frame = getglobal("ChatFrame" .. index)
    if IsDockedIn(frame, owner) then
      local topInset = 50
      if frame.pfCombatLog and CombatLogQuickButtonFrame_Custom then
        topInset =
          topInset + (CombatLogQuickButtonFrame_Custom:GetHeight() or 0)
      end

      frame:ClearAllPoints()
      frame:SetPoint("TOPLEFT", owner, "TOPLEFT", 42, -topInset)
      frame:SetPoint("BOTTOMRIGHT", owner, "BOTTOMRIGHT", -42, 58)
    end
  end
end

function Chat:StyleTabs(owner)
  local visualIndex = 0
  for index = 1, NUM_CHAT_WINDOWS do
    local frame = getglobal("ChatFrame" .. index)
    local tab = getglobal("ChatFrame" .. index .. "Tab")
    if IsDockedIn(frame, owner) and tab and tab:IsShown() then
      visualIndex = visualIndex + 1

      local text = getglobal("ChatFrame" .. index .. "TabText")
      local flash = getglobal("ChatFrame" .. index .. "TabFlash")
      local selected = SELECTED_CHAT_FRAME == frame
      local texturePath = TEXTURES.tabNormal

      HookHoverState(tab)
      if selected then
        texturePath = TEXTURES.tabSelected
      elseif tab.aeuiHovered then
        texturePath = TEXTURES.tabHover
      end

      local stateTexture = EnsureComponentTexture(
        tab,
        "aeuiStateTexture",
        "BACKGROUND",
        texturePath
      )
      local tint = TAB_TINTS[visualIndex] or TAB_TINTS[1]
      stateTexture:SetVertexColor(tint[1], tint[2], tint[3], tint[4])

      if not tab.aeuiUnreadSeal then
        tab.aeuiUnreadSeal = tab:CreateTexture(nil, "OVERLAY")
        tab.aeuiUnreadSeal:SetTexture(TEXTURES.waxSeal)
        tab.aeuiUnreadSeal:SetWidth(15)
        tab.aeuiUnreadSeal:SetHeight(15)
        tab.aeuiUnreadSeal:SetPoint("TOPRIGHT", tab, "TOPRIGHT", 4, 5)
      end

      if flash and flash:IsShown() and not selected then
        tab.aeuiUnreadSeal:Show()
      else
        tab.aeuiUnreadSeal:Hide()
      end

      if text then
        if selected then
          text:SetTextColor(
            COLORS.textSelected[1],
            COLORS.textSelected[2],
            COLORS.textSelected[3],
            COLORS.textSelected[4]
          )
        else
          text:SetTextColor(
            COLORS.text[1],
            COLORS.text[2],
            COLORS.text[3],
            COLORS.text[4]
          )
        end
      end
    end
  end
end

function Chat:StyleInput(owner)
  if not pfUI.chat.editbox or not ChatFrameEditBox then
    return
  end

  local input = pfUI.chat.editbox
  input:ClearAllPoints()
  input:SetPoint("BOTTOMLEFT", owner, "BOTTOMLEFT", 45, 29)
  input:SetPoint("BOTTOMRIGHT", owner, "BOTTOMRIGHT", -45, 29)
  input:SetHeight(26)

  MakeBackdropTransparent(ChatFrameEditBox)
  EnsureComponentTexture(
    ChatFrameEditBox,
    "aeuiInputTexture",
    "BACKGROUND",
    TEXTURES.input
  )
  if ChatFrameEditBox.SetTextInsets then
    ChatFrameEditBox:SetTextInsets(12, 12, 0, 0)
  end
end

function Chat:SuppressLegacyInfoPanels()
  if not pfUI.panel then
    return
  end

  local expedition =
    pfUI_config and
    pfUI_config.appearance and
    pfUI_config.appearance.expedition
  if expedition and expedition.legacy_info_panels == "1" then
    return
  end

  for _, panel in ipairs({
    pfUI.panel.left,
    pfUI.panel.right,
    pfUI.panel.minimap,
  }) do
    if panel then panel:Hide() end
  end
end

function Chat:Maintain()
  if not addon.db or not addon.db.chat.enabled then
    return
  end
  if not pfUI or not pfUI.chat or not pfUI.chat.left then
    return
  end
  if pfUI.chat.hideLock then
    return
  end

  local owner = pfUI.chat.left
  self:StyleTabs(owner)
end

addon:RegisterModule("Chat", Chat)
