local addon = AzerothExpeditionUI
local Chat = {}
Chat.runtimeContract = "1.18"

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
  textSelected = { 1.000, 0.880, 0.620, 1.00 },
  textDisabled = { 0.460, 0.400, 0.320, 1.00 },
}

local TAB_LAYOUT = {
  preferredWidth = 92,
  height = 30,
  gap = 3,
  topOffset = 2,
  panelHeight = 32,
  shelfTopOffset = 18,
  shelfHeight = 16,
  contentTopInset = 32,
  hitBottomExtension = 8,
  startupSettleDelay = 0.50,
  textHorizontalInset = 6,
  textHeight = 18,
}

local CHAT_TEXT_DEFAULT_SIZE = 12
local CHAT_TEXT_LINE_SPACING = 3
local CHAT_TEXT_SHADOW_COLOR = { 0, 0, 0, 0 }
local CHAT_TEXT_SHADOW_OFFSET = { 0, 0 }

local function RGB8(red, green, blue)
  return { red / 255, green / 255, blue / 255 }
end

-- Preserve the familiar Vanilla channel hues, then lower their luminance into
-- parchment ink. These are proportional darkened forms of the default colors,
-- targeting at least 4.5:1 against the accepted book's representative paper
-- color (#CDA155). Party and raid intentionally remain separate families.
local CHAT_TEXT_PALETTE = {
  say = RGB8(61, 61, 61),
  channel = RGB8(77, 57, 57),
  system = RGB8(64, 64, 0),
  guild = RGB8(18, 71, 18),
  party = RGB8(59, 59, 89),
  raid = RGB8(98, 49, 0),
  whisper = RGB8(90, 45, 90),
  danger = RGB8(117, 29, 29),
  emote = RGB8(97, 49, 24),
}

local CHAT_BASE_COLOR_RULES = {
  {
    target = "whisper",
    types = {
      "WHISPER", "WHISPER_INFORM", "REPLY",
      "MONSTER_WHISPER", "MONSTER_BOSS_WHISPER",
    },
  },
  {
    target = "guild",
    types = {
      "GUILD", "OFFICER", "LOOT", "MONEY",
      "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN",
      "COMBAT_FACTION_CHANGE", "SKILL",
    },
  },
  {
    target = "party",
    types = { "PARTY", "PARTY_LEADER" },
  },
  {
    target = "raid",
    types = {
      "RAID", "RAID_LEADER",
      "BATTLEGROUND", "BATTLEGROUND_LEADER",
      "BATTLEGROUND_SYSTEM_ALLIANCE",
    },
  },
  {
    target = "danger",
    types = {
      "YELL", "RAID_WARNING", "ERROR", "MONSTER_YELL",
      "MONSTER_BOSS_EMOTE", "BATTLEGROUND_SYSTEM_HORDE",
    },
  },
  {
    target = "emote",
    types = { "EMOTE", "TEXT_EMOTE", "MONSTER_EMOTE" },
  },
  {
    target = "system",
    types = {
      "SYSTEM", "IGNORED", "AFK", "DND", "FILTERED",
      "CHANNEL_JOIN", "CHANNEL_LEAVE", "CHANNEL_LIST",
      "CHANNEL_NOTICE", "CHANNEL_NOTICE_USER",
      "BATTLEGROUND_SYSTEM_NEUTRAL", "OPENING",
      "TRADESKILLS", "PET_INFO", "COMBAT_MISC_INFO",
    },
  },
  {
    target = "channel",
    types = {
      "CHANNEL", "CHANNEL1", "CHANNEL2", "CHANNEL3",
      "CHANNEL4", "CHANNEL5", "CHANNEL6", "CHANNEL7",
      "CHANNEL8", "CHANNEL9", "CHANNEL10",
    },
  },
  {
    target = "say",
    types = { "SAY", "MONSTER_SAY" },
  },
}

-- Exact colors emitted by ChatMOD 1.1, pfUI's class tinting and Vanilla
-- item quality links. Values keep their source hue identity and only lower
-- display luminance; payloads and global provider colors are never changed.
local CHAT_INLINE_COLOR_MAP = {
  -- ChatMOD timestamp, URL and generic accents.
  ff33ccff = "ff103e4e",
  ff00ffff = "ff004141",
  ff00ccff = "ff003f4f",
  ff66ffe6 = "ff1a403a",
  ff9999ee = "ff363655",
  ffff0000 = "ff7a0000",
  ffff1919 = "ff760c0c",
  ffff7f3f = "ff5b2d17",
  ffffff00 = "ff3c3c00",
  ffff9c00 = "ff533200",
  ffff00ff = "ff6b006b",
  ff10ff10 = "ff044404",
  ff00ff00 = "ff004400",
  ff3fbf3f = "ff164216",
  ff0000ff = "ff0000c8",
  ff006cff = "ff00367f",
  ffb2b2b2 = "ff393939",
  ff7f7f7f = "ff393939",
  ffa0a0a0 = "ff393939",
  a0a0a0a0 = "a0393939",
  fff86256 = "ff622722",

  -- DPSMate report accents seen in raid chat.
  ffff8080 = "ff592d2d",
  ff8cff80 = "ff234020",

  -- Nine Vanilla class colors, proportionally darkened rather than reassigned.
  ffc79c6e = "ff4b3b2a",
  fff58cba = "ff583243",
  ffabd473 = "ff354224",
  fffff569 = "ff423f1b",
  ffffffff = "ff333333",
  ff0070de = "ff003d7a",
  ff69ccf0 = "ff22424e",
  ff9482c9 = "ff413959",
  ffff7d0a = "ff633004",

  -- Known Vanilla item-quality colors; links remain links and keep hue.
  ff9d9d9d = "ff393939",
  ff1eff00 = "ff084400",
  ff0070dd = "ff003971",
  ffa335ee = "ff551c7b",
  ffff8000 = "ff5b2e00",
  ffe6cc80 = "ff413924",
}

local CHAT_INLINE_CONTRAST_TARGET = 4.8
local CHAT_INLINE_PAPER_COLOR = { 205, 161, 85 }
local CHAT_INLINE_COLOR_CACHE = {}
local CHAT_INLINE_COLOR_TARGETS = {}

for _, target in pairs(CHAT_INLINE_COLOR_MAP) do
  CHAT_INLINE_COLOR_TARGETS[target] = true
end

local function LinearizeColorChannel(value)
  local encoded = value / 255
  if encoded <= 0.04045 then
    return encoded / 12.92
  end
  return ((encoded + 0.055) / 1.055) ^ 2.4
end

local function RelativeLuminance(red, green, blue)
  return
    0.2126 * LinearizeColorChannel(red) +
    0.7152 * LinearizeColorChannel(green) +
    0.0722 * LinearizeColorChannel(blue)
end

local CHAT_INLINE_PAPER_LUMINANCE = RelativeLuminance(
  CHAT_INLINE_PAPER_COLOR[1],
  CHAT_INLINE_PAPER_COLOR[2],
  CHAT_INLINE_PAPER_COLOR[3]
)

local function InlineContrast(red, green, blue)
  return
    (CHAT_INLINE_PAPER_LUMINANCE + 0.05) /
    (RelativeLuminance(red, green, blue) + 0.05)
end

-- Third-party addons can inject colors AEUI has never audited. Preserve dark
-- custom colors exactly; only colors that are too bright for the paper are
-- scaled toward black. Scaling all RGB channels equally retains their hue and
-- saturation while avoiding an ever-growing destructive replacement list.
local function AdaptUnknownInlineColor(color)
  -- The provider chain can legitimately pass through more than one AEUI
  -- bridge. Deterministic outputs are terminal even when a class target sits
  -- at the 4.5:1 base-text threshold instead of the 4.8:1 unknown-color clamp.
  if CHAT_INLINE_COLOR_TARGETS[color] then
    return nil
  end

  local cached = CHAT_INLINE_COLOR_CACHE[color]
  if cached ~= nil then
    if cached then
      return cached
    end
    return nil
  end

  local alpha = string.sub(color, 1, 2)
  local red = tonumber(string.sub(color, 3, 4), 16)
  local green = tonumber(string.sub(color, 5, 6), 16)
  local blue = tonumber(string.sub(color, 7, 8), 16)
  if not red or not green or not blue then
    CHAT_INLINE_COLOR_CACHE[color] = false
    return nil
  end

  if InlineContrast(red, green, blue) >= CHAT_INLINE_CONTRAST_TARGET then
    CHAT_INLINE_COLOR_CACHE[color] = false
    return nil
  end

  local lower = 0
  local upper = 1
  for _ = 1, 12 do
    local scale = (lower + upper) / 2
    local testRed = math.floor(red * scale + 0.5)
    local testGreen = math.floor(green * scale + 0.5)
    local testBlue = math.floor(blue * scale + 0.5)
    if InlineContrast(testRed, testGreen, testBlue) >=
      CHAT_INLINE_CONTRAST_TARGET
    then
      lower = scale
    else
      upper = scale
    end
  end

  local replacement = alpha .. string.format(
    "%02x%02x%02x",
    math.floor(red * lower + 0.5),
    math.floor(green * lower + 0.5),
    math.floor(blue * lower + 0.5)
  )
  CHAT_INLINE_COLOR_CACHE[color] = replacement
  return replacement
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
    slices.left.aeuiManaged = true
    slices.center.aeuiManaged = true
    slices.right.aeuiManaged = true
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

local function NearlyEqual(left, right)
  return
    type(left) == "number" and
    type(right) == "number" and
    math.abs(left - right) < 0.01
end

local function GetOwnerScale(owner)
  local scale = 1
  local effectiveScale = 1

  if owner and owner.GetScale then
    scale = tonumber(owner:GetScale()) or scale
  end
  if owner and owner.GetEffectiveScale then
    effectiveScale =
      tonumber(owner:GetEffectiveScale()) or scale
  else
    effectiveScale = scale
  end

  return scale, effectiveScale
end

local function PointCountMatches(region, expected)
  return
    not region.GetNumPoints or
    region:GetNumPoints() == expected
end

local function PointMatches(
  region,
  index,
  point,
  relativeTo,
  relativePoint,
  x,
  y
)
  if not region.GetPoint then
    return false
  end

  local actualPoint,
    actualRelativeTo,
    actualRelativePoint,
    actualX,
    actualY = region:GetPoint(index)

  return
    actualPoint == point and
    actualRelativeTo == relativeTo and
    actualRelativePoint == relativePoint and
    NearlyEqual(actualX, x) and
    NearlyEqual(actualY, y)
end

local function AddDockedTab(tabs, seen, owner, frame)
  if not IsDockedIn(frame, owner) then
    return
  end

  for index = 1, NUM_CHAT_WINDOWS do
    if frame == getglobal("ChatFrame" .. index) then
      local tab = getglobal("ChatFrame" .. index .. "Tab")
      if tab and tab:IsShown() and not seen[tab] then
        table.insert(tabs, tab)
        seen[tab] = true
      end
      return
    end
  end
end

local function GetDockedTabs(owner)
  local tabs = {}
  local seen = {}

  if DOCKED_CHAT_FRAMES then
    for _, frame in ipairs(DOCKED_CHAT_FRAMES) do
      AddDockedTab(tabs, seen, owner, frame)
    end
  end

  for index = 1, NUM_CHAT_WINDOWS do
    AddDockedTab(
      tabs,
      seen,
      owner,
      getglobal("ChatFrame" .. index)
    )
  end

  return tabs
end

local function GetTabText(tab)
  for index = 1, NUM_CHAT_WINDOWS do
    if tab == getglobal("ChatFrame" .. index .. "Tab") then
      return getglobal("ChatFrame" .. index .. "TabText")
    end
  end
end

function Chat:Initialize()
  self.driver = CreateFrame(
    "Frame",
    "AzerothExpeditionUIChatDriver",
    UIParent
  )
  self:InstallHooks()
  self:InstallPfUIHooks()
  self.driver:RegisterEvent("PLAYER_ENTERING_WORLD")
  self.driver:RegisterEvent("UI_SCALE_CHANGED")
  self.driver:SetScript("OnEvent", function()
    Chat:ScheduleStartupLayout(
      TAB_LAYOUT.startupSettleDelay,
      event == "UI_SCALE_CHANGED"
    )
  end)
  self.driver:SetScript("OnUpdate", function()
    if not addon.db or not addon.db.chat.enabled then
      return
    end

    local now = GetTime()
    Chat:ProcessStartupLayout(now)
    if Chat.runtimeLayoutPending then
      Chat:RestoreRuntimeLayout()
    end
    if Chat.nextMaintain and now < Chat.nextMaintain then
      return
    end

    Chat.nextMaintain =
      now + (addon.db.chat.maintainInterval or 0.25)
    Chat:Maintain()
  end)
end

function Chat:ScheduleStartupLayout(delay, force)
  local targetAt =
    GetTime() + (delay or TAB_LAYOUT.startupSettleDelay)
  if
    not force and
    self.startupLayoutForce and
    self.startupLayoutAt
  then
    return
  end
  if force then
    self.startupLayoutForce = true
  end
  self.startupLayoutAt = targetAt
end

function Chat:ProcessStartupLayout(now)
  if not self.startupLayoutAt or now < self.startupLayoutAt then
    return
  end
  if not addon.db or not addon.db.chat.enabled then
    self.startupLayoutAt = nil
    self.startupLayoutForce = nil
    return
  end
  if not pfUI or not pfUI.chat or not pfUI.chat.left then
    self.startupLayoutAt = now + 0.10
    return
  end
  if pfUI.chat.hideLock then
    self.startupLayoutAt = now + 0.10
    return
  end

  local owner = pfUI.chat.left
  local force = self.startupLayoutForce
  self.startupLayoutAt = nil
  self.startupLayoutForce = nil
  self.runtimeLayoutPending = true
  if force then
    self.runtimeLayoutForce = true
  end
  self:RestoreRuntimeLayout()
  if self.runtimeLayoutPending then
    self.startupLayoutAt = now + 0.10
    if force then
      self.startupLayoutForce = true
    end
    return
  end
  owner.aeuiStartupLayoutFinalized = true
  owner.aeuiStartupLayoutFinalizedAt = now
  if force then
    owner.aeuiScaleLayoutFinalized = true
    owner.aeuiScaleLayoutFinalizedAt = now
  end
end

function Chat:InstallHooks()
  if self.hooksInstalled or type(hooksecurefunc) ~= "function" then
    return
  end

  self.hooksInstalled = true

  if type(getglobal("FCF_SelectDockFrame")) == "function" then
    hooksecurefunc("FCF_SelectDockFrame", function()
      Chat:OnRuntimeLayoutChanged()
    end)
  end

  if type(getglobal("FCF_DockUpdate")) == "function" then
    hooksecurefunc("FCF_DockUpdate", function()
      Chat:OnRuntimeLayoutChanged()
    end)
  end

  if type(getglobal("FCF_SaveDock")) == "function" then
    hooksecurefunc("FCF_SaveDock", function()
      Chat:OnRuntimeLayoutChanged()
    end)
  end

  if type(getglobal("FCF_SetChatWindowFontSize")) == "function" then
    hooksecurefunc("FCF_SetChatWindowFontSize", function(frame)
      if
        pfUI and
        pfUI.chat and
        IsDockedIn(frame, pfUI.chat.left)
      then
        Chat:OnRuntimeLayoutChanged()
      end
    end)
  end
end

function Chat:InstallPfUIHooks()
  if not pfUI or not pfUI.chat then
    return
  end

  if
    not self.pfUIRefreshHooked and
    type(pfUI.chat.RefreshChat) == "function"
  then
    self.pfUIRefreshHooked = true
    self.originalPfUIRefreshChat = pfUI.chat.RefreshChat
    pfUI.chat.RefreshChat = function(chat)
      local result = Chat.originalPfUIRefreshChat(chat)
      Chat:OnRuntimeLayoutChanged()
      return result
    end
  end

  self:InstallOwnerScaleHook(pfUI.chat.left)
end

function Chat:InstallOwnerScaleHook(owner)
  if not owner or owner.aeuiScaleMoveHooked then
    return
  end

  owner.aeuiScaleMoveHooked = true
  owner.aeuiOriginalOnMove = owner.OnMove
  owner.OnMove = function(frame)
    if owner.aeuiOriginalOnMove then
      owner.aeuiOriginalOnMove(frame)
    end
    Chat:ObserveOwnerScale(owner, true)
  end
  self:CaptureOwnerScale(owner)
end

function Chat:CaptureOwnerScale(owner)
  local scale, effectiveScale = GetOwnerScale(owner)
  local changed =
    self.ownerScale ~= nil and
    (
      not NearlyEqual(scale, self.ownerScale) or
      not NearlyEqual(effectiveScale, self.ownerEffectiveScale)
    )

  self.ownerScale = scale
  self.ownerEffectiveScale = effectiveScale
  owner.aeuiObservedScale = scale
  owner.aeuiObservedEffectiveScale = effectiveScale
  return changed
end

function Chat:ObserveOwnerScale(owner, immediate)
  if not owner or not self:CaptureOwnerScale(owner) then
    return false
  end

  owner.aeuiScaleChangeCount =
    (owner.aeuiScaleChangeCount or 0) + 1
  if not addon.db or not addon.db.chat.enabled then
    return true
  end

  if immediate then
    if self.startupLayoutForce then
      self.startupLayoutAt = nil
      self.startupLayoutForce = nil
    end
    self:OnRuntimeLayoutChanged(true)
  else
    self:ScheduleStartupLayout(
      TAB_LAYOUT.startupSettleDelay,
      true
    )
  end

  return true
end

function Chat:OnRuntimeLayoutChanged(force)
  self.runtimeLayoutPending = true
  if force then
    self.runtimeLayoutForce = true
  end
  self:RestoreRuntimeLayout()
end

function Chat:RestoreRuntimeLayout()
  if not addon.db or not addon.db.chat.enabled then
    self.runtimeLayoutPending = nil
    self.runtimeLayoutForce = nil
    return
  end
  if not pfUI or not pfUI.chat or not pfUI.chat.left then
    return
  end
  if pfUI.chat.hideLock then
    return
  end

  local owner = pfUI.chat.left
  local force = self.runtimeLayoutForce
  self.runtimeLayoutPending = nil
  self.runtimeLayoutForce = nil
  self:EnsureBookVisible(owner)
  self:LayoutTabPanel(owner, force)
  self:LayoutChatFrames(owner, force)
  self:StyleTabs(owner)
  owner.aeuiRuntimeLayoutVersion = self.runtimeContract
  if force then
    owner.aeuiScaleLayoutFinalized = true
    owner.aeuiScaleLayoutFinalizedAt = GetTime()
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
  self:InstallPfUIHooks()
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
  self:OnRuntimeLayoutChanged()
  self:StyleInput(owner)
  self:SuppressChatInfoPanels()
  self:Maintain()
  self:ScheduleStartupLayout(TAB_LAYOUT.startupSettleDelay)
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
  if owner.EnableDrawLayer then
    owner:EnableDrawLayer("BACKGROUND")
  end
  MakeBackdropTransparent(owner)
  MakeBackdropTransparent(owner.panelTop)

  if owner.aeuiBookTexture then
    owner.aeuiBookTexture:Hide()
  end
  if owner.aeuiReadingWash then
    owner.aeuiReadingWash:Hide()
    owner.aeuiReadingWash:SetTexture(nil)
    owner.aeuiReadingWash.aeuiRuntimeVersion = nil
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
    -TAB_LAYOUT.shelfTopOffset
  )
  owner.aeuiTabShelf:SetPoint(
    "TOPRIGHT",
    owner,
    "TOPRIGHT",
    -30,
    -TAB_LAYOUT.shelfTopOffset
  )
  owner.aeuiTabShelf:SetHeight(TAB_LAYOUT.shelfHeight)
  owner.aeuiTabShelf:Show()
  owner.aeuiBookRuntimeVersion = self.runtimeContract
end

function Chat:EnsureBookVisible(owner)
  if not owner then
    return
  end

  local slices = owner.aeuiBookSlices
  local center = slices and slices.center
  local shelf = owner.aeuiTabShelf
  local missing =
    not center or
    not center.IsShown or
    not center:IsShown() or
    not shelf or
    not shelf.IsShown or
    not shelf:IsShown()

  if
    not missing and
    center.GetTexture and
    not center:GetTexture()
  then
    missing = true
  end
  if
    not missing and
    shelf.GetTexture and
    not shelf:GetTexture()
  then
    missing = true
  end
  if
    owner.aeuiBookRuntimeVersion ~= self.runtimeContract
  then
    missing = true
  end

  if missing then
    self:EnsureBook(owner)
    owner.aeuiBookRecoveredAt = GetTime()
  end
end

function Chat:StyleChatFrameText(frame, force)
  local currentFont
  local currentSize
  local currentFlags
  if frame.GetFont then
    currentFont, currentSize, currentFlags = frame:GetFont()
  end

  local fontSize = tonumber(currentSize)
  if not fontSize or fontSize <= 0 then
    fontSize =
      tonumber(frame.aeuiTextFontSize) or CHAT_TEXT_DEFAULT_SIZE
  end

  local providerFont = currentFont
  if not providerFont or providerFont == "" then
    providerFont =
      (pfUI and pfUI.font_default) or frame.aeuiTextFontPath
  end

  local styleNeedsApply =
    force or
    not currentFont or
    not providerFont or
    (currentFlags and currentFlags ~= "") or
    frame.aeuiTextStyleVersion ~= self.runtimeContract

  if frame.SetFont and providerFont and styleNeedsApply then
    -- Omitting font flags removes pfUI's full OUTLINE while preserving both
    -- the provider-owned font and the user's font size.
    frame:SetFont(providerFont, fontSize)
  end
  if frame.SetShadowColor and styleNeedsApply then
    frame:SetShadowColor(
      CHAT_TEXT_SHADOW_COLOR[1],
      CHAT_TEXT_SHADOW_COLOR[2],
      CHAT_TEXT_SHADOW_COLOR[3],
      CHAT_TEXT_SHADOW_COLOR[4]
    )
  end
  if frame.SetShadowOffset and styleNeedsApply then
    frame:SetShadowOffset(
      CHAT_TEXT_SHADOW_OFFSET[1],
      CHAT_TEXT_SHADOW_OFFSET[2]
    )
  end

  frame.aeuiTextFontPath = providerFont
  frame.aeuiTextFontSize = fontSize
  frame.aeuiTextFontFlags = nil
  frame.aeuiTextStyleVersion = self.runtimeContract
end

function Chat:TransformBaseMessageColor(red, green, blue)
  if type(ChatTypeInfo) ~= "table" then
    return red, green, blue
  end

  for _, rule in ipairs(CHAT_BASE_COLOR_RULES) do
    for _, chatType in ipairs(rule.types) do
      local source = ChatTypeInfo[chatType]
      if
        source and
        NearlyEqual(red, source.r) and
        NearlyEqual(green, source.g) and
        NearlyEqual(blue, source.b)
      then
        local target = CHAT_TEXT_PALETTE[rule.target]
        return target[1], target[2], target[3]
      end
    end
  end

  return red, green, blue
end

function Chat:NormalizeInlineMessageColors(text)
  if type(text) ~= "string" then
    return text
  end

  return string.gsub(
    text,
    "|([cC])([0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]" ..
      "[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])",
    function(marker, color)
      local normalizedColor = string.lower(color)
      local replacement =
        CHAT_INLINE_COLOR_MAP[normalizedColor] or
        AdaptUnknownInlineColor(normalizedColor)
      if replacement then
        return "|c" .. replacement
      end
      return "|" .. marker .. color
    end
  )
end

function Chat:IsMessagePaletteManaged(frame)
  return
    frame and
    frame.GetParent and
    addon.db and
    addon.db.chat and
    addon.db.chat.enabled and
    pfUI and
    pfUI.chat and
    frame:GetParent() == pfUI.chat.left
end

function Chat:ApplyMessagePalette(frame, text, red, green, blue)
  if self:IsMessagePaletteManaged(frame) then
    local originalText = text
    local originalRed = red
    local originalGreen = green
    local originalBlue = blue

    text = self:NormalizeInlineMessageColors(text)
    red, green, blue =
      self:TransformBaseMessageColor(red, green, blue)

    self.messagePaletteCalls = (self.messagePaletteCalls or 0) + 1
    frame.aeuiMessagePaletteCalls =
      (frame.aeuiMessagePaletteCalls or 0) + 1
    if
      text ~= originalText or
      red ~= originalRed or
      green ~= originalGreen or
      blue ~= originalBlue
    then
      self.messagePaletteMutations =
        (self.messagePaletteMutations or 0) + 1
      frame.aeuiMessagePaletteMutations =
        (frame.aeuiMessagePaletteMutations or 0) + 1
    end
  end

  return text, red, green, blue
end

function Chat:InstallChatMODFinalColorHook(frame)
  if not frame or type(frame.ORG_AddMessage) ~= "function" then
    return
  end

  if frame.ORG_AddMessage == frame.aeuiChatMODFinalColorWrapper then
    frame.aeuiChatMODFinalColorVersion = self.runtimeContract
    return
  end

  local providerAddMessage = frame.ORG_AddMessage
  local wrapper = function(
    self,
    text,
    red,
    green,
    blue,
    alpha,
    messageId
  )
    text, red, green, blue =
      Chat:ApplyMessagePalette(self, text, red, green, blue)
    return providerAddMessage(
      self,
      text,
      red,
      green,
      blue,
      alpha,
      messageId
    )
  end

  frame.aeuiChatMODFinalColorWrapper = wrapper
  frame.ORG_AddMessage = wrapper
  frame.aeuiChatMODFinalColorVersion = self.runtimeContract
end

function Chat:InstallMessageColorHook(frame)
  self:InstallChatMODFinalColorHook(frame)

  if
    not frame or
    frame.aeuiMessageColorHooked or
    type(frame.HookAddMessage) ~= "function"
  then
    return
  end

  frame.aeuiProviderHookAddMessage = frame.HookAddMessage
  frame.HookAddMessage = function(
    self,
    text,
    red,
    green,
    blue,
    alpha,
    messageId
  )
    text, red, green, blue =
      Chat:ApplyMessagePalette(self, text, red, green, blue)

    return self:aeuiProviderHookAddMessage(
      text,
      red,
      green,
      blue,
      alpha,
      messageId
    )
  end
  frame.aeuiMessageColorHooked = true
  frame.aeuiMessageColorVersion = self.runtimeContract
end

function Chat:EnsureMessageColorHooks(owner)
  for index = 1, NUM_CHAT_WINDOWS do
    local frame = getglobal("ChatFrame" .. index)
    if frame and frame.GetParent and frame:GetParent() == owner then
      self:InstallMessageColorHook(frame)
    end
  end
end

function Chat:GetMessageColorStatus()
  local managed = 0
  local hooked = 0
  local final = 0
  local count = tonumber(NUM_CHAT_WINDOWS) or 0

  for index = 1, count do
    local frame = getglobal("ChatFrame" .. index)
    if frame then
      if self:IsMessagePaletteManaged(frame) then
        managed = managed + 1
      end
      if frame.aeuiMessageColorHooked then
        hooked = hooked + 1
      end
      if
        frame.aeuiChatMODFinalColorWrapper and
        frame.ORG_AddMessage == frame.aeuiChatMODFinalColorWrapper
      then
        final = final + 1
      end
    end
  end

  return
    "m" .. managed ..
    "/h" .. hooked ..
    "/f" .. final ..
    "/c" .. (self.messagePaletteCalls or 0) ..
    "/x" .. (self.messagePaletteMutations or 0)
end

function Chat:LayoutTabPanel(owner, force)
  if not owner.panelTop then
    return
  end

  if
    force or
    not PointCountMatches(owner.panelTop, 2) or
    not PointMatches(
      owner.panelTop,
      1,
      "TOPLEFT",
      owner,
      "TOPLEFT",
      30,
      0
    ) or
    not PointMatches(
      owner.panelTop,
      2,
      "TOPRIGHT",
      owner,
      "TOPRIGHT",
      -30,
      0
    ) or
    not NearlyEqual(
      owner.panelTop:GetHeight(),
      TAB_LAYOUT.panelHeight
    )
  then
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
    owner.panelTop:SetHeight(TAB_LAYOUT.panelHeight)
  end

  self:LayoutDockedTabs(owner, force)
end

function Chat:LayoutTabText(tab, text, force)
  if not text then
    return
  end

  local width =
    (tab:GetWidth() or 0) -
    TAB_LAYOUT.textHorizontalInset * 2
  if width < 1 then
    width = 1
  end

  if
    force or
    not PointCountMatches(text, 1) or
    not PointMatches(
      text,
      1,
      "CENTER",
      tab,
      "CENTER",
      0,
      0
    ) or
    not NearlyEqual(text:GetWidth(), width) or
    not NearlyEqual(text:GetHeight(), TAB_LAYOUT.textHeight)
  then
    text:ClearAllPoints()
    text:SetPoint("CENTER", tab, "CENTER", 0, 0)
    text:SetWidth(width)
    text:SetHeight(TAB_LAYOUT.textHeight)
  end

  if text.SetJustifyH then
    text:SetJustifyH("CENTER")
  end
  if text.SetJustifyV then
    text:SetJustifyV("MIDDLE")
  end
  text.aeuiManaged = true
  text.aeuiTextLayoutVersion = self.runtimeContract
end

function Chat:LayoutDockedTabs(owner, force)
  if not owner or not owner.panelTop then
    return
  end

  local tabs = GetDockedTabs(owner)
  local count = table.getn(tabs)
  if count == 0 then
    return
  end

  local availableWidth = owner.panelTop:GetWidth()
  if not availableWidth or availableWidth <= 0 then
    availableWidth = owner:GetWidth() - 60
  end

  local width = TAB_LAYOUT.preferredWidth
  local maximumWidth =
    (availableWidth - TAB_LAYOUT.gap * (count - 1)) / count
  if maximumWidth < width then
    width = math.floor(maximumWidth)
  end

  local x = 0
  for index, tab in ipairs(tabs) do
    if
      force or
      not PointCountMatches(tab, 1) or
      not PointMatches(
        tab,
        1,
        "TOPLEFT",
        owner.panelTop,
        "TOPLEFT",
        x,
        -TAB_LAYOUT.topOffset
      ) or
      not NearlyEqual(tab:GetWidth(), width) or
      not NearlyEqual(tab:GetHeight(), TAB_LAYOUT.height)
    then
      tab:ClearAllPoints()
      tab:SetPoint(
        "TOPLEFT",
        owner.panelTop,
        "TOPLEFT",
        x,
        -TAB_LAYOUT.topOffset
      )
      tab:SetWidth(width)
      tab:SetHeight(TAB_LAYOUT.height)
    end
    if
      tab.SetHitRectInsets and
      (
        force or
        tab.aeuiHitRectVersion ~= self.runtimeContract
      )
    then
      tab:SetHitRectInsets(
        0,
        0,
        0,
        -TAB_LAYOUT.hitBottomExtension
      )
      tab.aeuiHitRectVersion = self.runtimeContract
    end
    self:LayoutTabText(tab, GetTabText(tab), force)
    tab.aeuiLayoutIndex = index
    tab.aeuiLayoutWidth = width
    x = x + width + TAB_LAYOUT.gap
  end

  owner.aeuiTabLayoutCount = count
  owner.aeuiTabLayoutWidth = width
end

function Chat:LayoutChatFrames(owner, force)
  for index = 1, NUM_CHAT_WINDOWS do
    local frame = getglobal("ChatFrame" .. index)
    if IsDockedIn(frame, owner) then
      self:InstallMessageColorHook(frame)
      self:StyleChatFrameText(frame, force)
      if frame.SetSpacing then
        local spacing
        if frame.GetSpacing then
          spacing = frame:GetSpacing()
        end
        if
          spacing == nil or
          not NearlyEqual(spacing, CHAT_TEXT_LINE_SPACING) or
          frame.aeuiTextMetricsVersion ~= self.runtimeContract
        then
          frame:SetSpacing(CHAT_TEXT_LINE_SPACING)
        end
        frame.aeuiTextLineSpacing = CHAT_TEXT_LINE_SPACING
        frame.aeuiTextMetricsVersion = self.runtimeContract
      end

      local topInset = TAB_LAYOUT.contentTopInset
      if frame.pfCombatLog and CombatLogQuickButtonFrame_Custom then
        topInset =
          topInset + (CombatLogQuickButtonFrame_Custom:GetHeight() or 0)
      end

      if
        force or
        not PointCountMatches(frame, 2) or
        not PointMatches(
          frame,
          1,
          "TOPLEFT",
          owner,
          "TOPLEFT",
          30,
          -topInset
        ) or
        not PointMatches(
          frame,
          2,
          "BOTTOMRIGHT",
          owner,
          "BOTTOMRIGHT",
          -30,
          40
        )
      then
        frame:ClearAllPoints()
        frame:SetPoint(
          "TOPLEFT",
          owner,
          "TOPLEFT",
          30,
          -topInset
        )
        frame:SetPoint(
          "BOTTOMRIGHT",
          owner,
          "BOTTOMRIGHT",
          -30,
          40
        )
      end
      frame.aeuiContentLayoutVersion = self.runtimeContract
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
        tab.aeuiUnreadSeal.aeuiManaged = true
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

function Chat:SuppressChatInfoPanel(panel)
  if not panel then
    return
  end

  if not panel.aeuiChatInfoPanelHideHook and panel.SetScript then
    local originalOnShow = panel.GetScript and panel:GetScript("OnShow")
    panel:SetScript("OnShow", function()
      if originalOnShow then
        originalOnShow()
      end
      if addon.db and addon.db.chat and addon.db.chat.enabled then
        panel:Hide()
      end
    end)
    panel.aeuiChatInfoPanelHideHook = true
  end

  if panel:IsShown() then
    panel:Hide()
  end
end

function Chat:SuppressChatInfoPanels()
  local panels = pfUI and pfUI.panel
  if not panels then
    return
  end

  -- These two bars are visually attached to pfUI's left/right chat frames.
  -- Keep the panel provider and its configuration loaded, and leave the
  -- independent minimap panel untouched.
  self:SuppressChatInfoPanel(panels.left)
  self:SuppressChatInfoPanel(panels.right)
end

function Chat:Maintain()
  if not addon.db or not addon.db.chat.enabled then
    return
  end
  if not pfUI or not pfUI.chat or not pfUI.chat.left then
    return
  end

  self:SuppressRightChat()
  self:SuppressChatInfoPanels()
  if pfUI.chat.hideLock then
    return
  end

  local owner = pfUI.chat.left
  self:EnsureMessageColorHooks(owner)
  self:EnsureBookVisible(owner)
  self:ObserveOwnerScale(owner, true)
  if self.runtimeLayoutPending then
    self:RestoreRuntimeLayout()
    if self.runtimeLayoutPending then
      return
    end
  end
  self:StyleTabs(owner)
  self:UpdateInputState(ChatFrameEditBox)
end

addon:RegisterModule("Chat", Chat)
