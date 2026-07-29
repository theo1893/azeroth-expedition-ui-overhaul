local addon = AzerothExpeditionUI
local Chat = {}

local CHAT_MEDIA = addon.media.root .. "Chat\\"
local BOOK_TEXTURE = CHAT_MEDIA .. "ChatBookFrameV3"
local TAB_FONT =
  addon.media.root .. "Fonts\\LXGWWenKaiGB-Medium.ttf"

local BOOK_UV = {
  left = 0.1337890625,
  right = 0.923828125,
  upper = 0.0625,
  lower = 0.53515625,
  bottom = 0.6083984375,
}

local TEXTURES = {
  tabs = CHAT_MEDIA .. "ChatTabAtlasV3",
  tabShelf = CHAT_MEDIA .. "ChatTabShelfV3",
  input = CHAT_MEDIA .. "ChatInputAtlasV3",
  unread = CHAT_MEDIA .. "ChatUnreadSealV3",
}

local TAB_X = {
  0.0078125,
  0.1015625,
  0.3984375,
  0.4921875,
}

local TAB_Y = {
  normal = { 0.00, 0.25 },
  hover = { 0.25, 0.50 },
  selected = { 0.50, 0.75 },
  disabled = { 0.75, 1.00 },
}

local INPUT_X = {
  0.0078125,
  0.1181640625,
  0.91015625,
  0.9921875,
}

local INPUT_Y = {
  normal = { 0.00, 0.50 },
  focus = { 0.50, 1.00 },
}

local COLORS = {
  text = { 0.900, 0.790, 0.570, 1.00 },
  textSelected = { 0.190, 0.095, 0.035, 1.00 },
  textDisabled = { 0.460, 0.400, 0.320, 1.00 },
}

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
  texture:SetVertexColor(brightness, brightness, brightness, 1)
  texture:ClearAllPoints()
  texture:SetPoint(point1, owner, relativePoint1, x1, y1)
  texture:SetPoint(point2, owner, relativePoint2, x2, y2)
  texture:Show()
end

local function EnsureHorizontalSlices(
  parent,
  key,
  layer,
  texturePath,
  leftWidth,
  rightWidth
)
  if not parent[key] then
    local slices = {
      left = parent:CreateTexture(nil, layer or "BACKGROUND"),
      center = parent:CreateTexture(nil, layer or "BACKGROUND"),
      right = parent:CreateTexture(nil, layer or "BACKGROUND"),
    }

    slices.left:SetWidth(leftWidth)
    slices.left:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    slices.left:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)

    slices.right:SetWidth(rightWidth)
    slices.right:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    slices.right:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)

    slices.center:SetPoint(
      "TOPLEFT",
      slices.left,
      "TOPRIGHT",
      0,
      0
    )
    slices.center:SetPoint(
      "BOTTOMRIGHT",
      slices.right,
      "BOTTOMLEFT",
      0,
      0
    )
    parent[key] = slices
  end

  for _, texture in pairs(parent[key]) do
    texture:SetTexture(texturePath)
    texture:SetVertexColor(1, 1, 1, 1)
    texture:Show()
  end

  return parent[key]
end

local function SetHorizontalSliceTexCoords(slices, x, y)
  slices.left:SetTexCoord(x[1], x[2], y[1], y[2])
  slices.center:SetTexCoord(x[2], x[3], y[1], y[2])
  slices.right:SetTexCoord(x[3], x[4], y[1], y[2])
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

local function HookInputFocusState(editbox)
  if editbox.aeuiFocusHooked or not editbox.GetScript then
    return
  end

  editbox.aeuiFocusHooked = true
  editbox.aeuiOriginalOnEditFocusGained =
    editbox:GetScript("OnEditFocusGained")
  editbox.aeuiOriginalOnEditFocusLost =
    editbox:GetScript("OnEditFocusLost")

  editbox:SetScript("OnEditFocusGained", function()
    editbox.aeuiFocused = true
    if editbox.aeuiOriginalOnEditFocusGained then
      editbox.aeuiOriginalOnEditFocusGained(editbox)
    end
    Chat:UpdateInputState(editbox)
  end)

  editbox:SetScript("OnEditFocusLost", function()
    editbox.aeuiFocused = nil
    if editbox.aeuiOriginalOnEditFocusLost then
      editbox.aeuiOriginalOnEditFocusLost(editbox)
    end
    Chat:UpdateInputState(editbox)
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

local function IsDisabled(tab)
  if tab and tab.IsEnabled then
    return not tab:IsEnabled()
  end
  return false
end

function Chat:Initialize()
  self.driver = CreateFrame(
    "Frame",
    "AzerothExpeditionUIChatDriver",
    UIParent
  )
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

  self:SuppressRightChat()
  local resized = self:EnsureMinimumSize(owner)

  if resized and pfUI.chat.RefreshChat then
    pfUI.chat:RefreshChat()
  end

  self:EnsureBook(owner)
  self:LayoutTabPanel(owner)
  self:LayoutChatFrames(owner)
  self:StyleInput(owner)
  self:SuppressLegacyInfoPanels()
  self:Maintain()
end

function Chat:SuppressRightChat()
  local rightConfig =
    pfUI_config and
    pfUI_config.chat and
    pfUI_config.chat.right
  if rightConfig then
    rightConfig.enable = "0"
  end

  local right = pfUI and pfUI.chat and pfUI.chat.right
  if right and right:IsShown() then
    right:Hide()
  end
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
  if owner.aeuiReadingWash then
    owner.aeuiReadingWash:Hide()
  end

  local brightness = tonumber(addon.db.chat.bookBrightness) or 1.00

  ConfigureBookSlice(
    owner, "center",
    BOOK_UV.left, BOOK_UV.right, BOOK_UV.upper, BOOK_UV.lower,
    "TOPLEFT", "TOPLEFT", 30, -28,
    "BOTTOMRIGHT", "BOTTOMRIGHT", -30, 28,
    brightness
  )
  ConfigureBookSlice(
    owner, "top",
    BOOK_UV.left, BOOK_UV.right, 0, BOOK_UV.upper,
    "TOPLEFT", "TOPLEFT", 30, 0,
    "BOTTOMRIGHT", "TOPRIGHT", -30, -28,
    brightness
  )
  ConfigureBookSlice(
    owner, "bottom",
    BOOK_UV.left, BOOK_UV.right, BOOK_UV.lower, BOOK_UV.bottom,
    "TOPLEFT", "BOTTOMLEFT", 30, 28,
    "BOTTOMRIGHT", "BOTTOMRIGHT", -30, 0,
    brightness
  )
  ConfigureBookSlice(
    owner, "left",
    0, BOOK_UV.left, BOOK_UV.upper, BOOK_UV.lower,
    "TOPLEFT", "TOPLEFT", 0, -28,
    "BOTTOMRIGHT", "BOTTOMLEFT", 30, 28,
    brightness
  )
  ConfigureBookSlice(
    owner, "right",
    BOOK_UV.right, 1, BOOK_UV.upper, BOOK_UV.lower,
    "TOPLEFT", "TOPRIGHT", -30, -28,
    "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 28,
    brightness
  )
  ConfigureBookSlice(
    owner, "topLeft",
    0, BOOK_UV.left, 0, BOOK_UV.upper,
    "TOPLEFT", "TOPLEFT", 0, 0,
    "BOTTOMRIGHT", "TOPLEFT", 30, -28,
    brightness
  )
  ConfigureBookSlice(
    owner, "topRight",
    BOOK_UV.right, 1, 0, BOOK_UV.upper,
    "TOPLEFT", "TOPRIGHT", -30, 0,
    "BOTTOMRIGHT", "TOPRIGHT", 0, -28,
    brightness
  )
  ConfigureBookSlice(
    owner, "bottomLeft",
    0, BOOK_UV.left, BOOK_UV.lower, BOOK_UV.bottom,
    "TOPLEFT", "BOTTOMLEFT", 0, 28,
    "BOTTOMRIGHT", "BOTTOMLEFT", 30, 0,
    brightness
  )
  ConfigureBookSlice(
    owner, "bottomRight",
    BOOK_UV.right, 1, BOOK_UV.lower, BOOK_UV.bottom,
    "TOPLEFT", "BOTTOMRIGHT", -30, 28,
    "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0,
    brightness
  )

  if not owner.aeuiTabShelf then
    owner.aeuiTabShelf = owner:CreateTexture(nil, "BORDER")
  end
  owner.aeuiTabShelf:SetTexture(TEXTURES.tabShelf)
  owner.aeuiTabShelf:SetVertexColor(1, 1, 1, 1)
  owner.aeuiTabShelf:ClearAllPoints()
  owner.aeuiTabShelf:SetPoint(
    "TOPLEFT",
    owner,
    "TOPLEFT",
    30,
    -25
  )
  owner.aeuiTabShelf:SetPoint(
    "TOPRIGHT",
    owner,
    "TOPRIGHT",
    -30,
    -25
  )
  owner.aeuiTabShelf:SetHeight(23)
  owner.aeuiTabShelf:Show()
end

function Chat:LayoutTabPanel(owner)
  if not owner.panelTop then
    return
  end

  owner.panelTop:ClearAllPoints()
  owner.panelTop:SetPoint(
    "TOPLEFT",
    owner,
    "TOPLEFT",
    30,
    0
  )
  owner.panelTop:SetPoint(
    "TOPRIGHT",
    owner,
    "TOPRIGHT",
    -30,
    0
  )
  owner.panelTop:SetHeight(45)

  for index = 1, NUM_CHAT_WINDOWS do
    local frame = getglobal("ChatFrame" .. index)
    local tab = getglobal("ChatFrame" .. index .. "Tab")
    if IsDockedIn(frame, owner) and tab then
      tab:SetWidth(92)
      tab:SetHeight(42)
    end
  end
end

function Chat:LayoutChatFrames(owner)
  for index = 1, NUM_CHAT_WINDOWS do
    local frame = getglobal("ChatFrame" .. index)
    if IsDockedIn(frame, owner) then
      local topInset = 44
      if frame.pfCombatLog and CombatLogQuickButtonFrame_Custom then
        topInset =
          topInset + (CombatLogQuickButtonFrame_Custom:GetHeight() or 0)
      end

      frame:ClearAllPoints()
      frame:SetPoint("TOPLEFT", owner, "TOPLEFT", 30, -topInset)
      frame:SetPoint("BOTTOMRIGHT", owner, "BOTTOMRIGHT", -30, 40)
    end
  end
end

function Chat:StyleTabs(owner)
  for index = 1, NUM_CHAT_WINDOWS do
    local frame = getglobal("ChatFrame" .. index)
    local tab = getglobal("ChatFrame" .. index .. "Tab")
    if IsDockedIn(frame, owner) and tab and tab:IsShown() then
      local text = getglobal("ChatFrame" .. index .. "TabText")
      local flash = getglobal("ChatFrame" .. index .. "TabFlash")
      local state = "normal"

      HookHoverState(tab)
      if IsDisabled(tab) then
        state = "disabled"
      elseif SELECTED_CHAT_FRAME == frame then
        state = "selected"
      elseif tab.aeuiHovered then
        state = "hover"
      end

      local slices = EnsureHorizontalSlices(
        tab,
        "aeuiStateSlices",
        "BACKGROUND",
        TEXTURES.tabs,
        16,
        16
      )
      SetHorizontalSliceTexCoords(slices, TAB_X, TAB_Y[state])
      tab.aeuiStateTexture = slices.center
      tab.aeuiVisualState = state

      if not tab.aeuiUnreadSeal then
        tab.aeuiUnreadSeal = tab:CreateTexture(nil, "OVERLAY")
        tab.aeuiUnreadSeal:SetTexture(TEXTURES.unread)
        tab.aeuiUnreadSeal:SetWidth(16)
        tab.aeuiUnreadSeal:SetHeight(32)
        tab.aeuiUnreadSeal:SetPoint("TOPRIGHT", tab, "TOPRIGHT", 4, 8)
      end

      if flash and flash:IsShown() and state ~= "selected" then
        tab.aeuiUnreadSeal:Show()
      else
        tab.aeuiUnreadSeal:Hide()
      end

      if text then
        if not text.aeuiFontApplied and text.SetFont then
          text:SetFont(TAB_FONT, 13, "OUTLINE")
          text.aeuiFontApplied = true
        end

        local color = COLORS.text
        if state == "selected" then
          color = COLORS.textSelected
        elseif state == "disabled" then
          color = COLORS.textDisabled
        end
        text:SetTextColor(color[1], color[2], color[3], color[4])
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
  input:SetPoint("BOTTOMLEFT", owner, "BOTTOMLEFT", 30, 6)
  input:SetPoint("BOTTOMRIGHT", owner, "BOTTOMRIGHT", -30, 6)
  input:SetHeight(25)

  MakeBackdropTransparent(ChatFrameEditBox)
  local slices = EnsureHorizontalSlices(
    ChatFrameEditBox,
    "aeuiInputSlices",
    "BACKGROUND",
    TEXTURES.input,
    28,
    20
  )
  ChatFrameEditBox.aeuiInputTexture = slices.center
  HookInputFocusState(ChatFrameEditBox)
  self:UpdateInputState(ChatFrameEditBox)

  if ChatFrameEditBox.SetTextInsets then
    ChatFrameEditBox:SetTextInsets(34, 22, 0, 0)
  end
end

function Chat:UpdateInputState(editbox)
  if not editbox or not editbox.aeuiInputSlices then
    return
  end

  local focused = editbox.aeuiFocused
  if editbox.HasFocus then
    focused = editbox:HasFocus()
  end
  local state = focused and "focus" or "normal"
  SetHorizontalSliceTexCoords(
    editbox.aeuiInputSlices,
    INPUT_X,
    INPUT_Y[state]
  )
  editbox.aeuiInputState = state
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

  self:SuppressRightChat()
  if pfUI.chat.hideLock then
    return
  end

  local owner = pfUI.chat.left
  self:StyleTabs(owner)
  self:UpdateInputState(ChatFrameEditBox)
end

addon:RegisterModule("Chat", Chat)
