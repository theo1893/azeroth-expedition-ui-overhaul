-- ============================================================================
-- DoiteDPS - compact QTE timeline
-- Actions travel from right to left into one fixed ready slot. Once visible,
-- ETA corrections never rewind an action; a higher-priority insertion may
-- temporarily push the affected queue to the right to preserve spacing.
-- ============================================================================

local D = DoiteDPS
local UI = {}
D.UI = UI

local locale = (GetLocale and GetLocale()) or "enUS"
local zh = (locale == "zhCN" or locale == "zhTW")

local ROOT_WIDTH = 318
local ROOT_HEIGHT = 46
local TRACK_CENTER_Y = -23
local HIT_X = 45
local READY_SLOT_SIZE = 46
local FORECAST_MIN_X = 87
local FORECAST_MAX_X = 294
local FORECAST_SPACING = 38
local TIMELINE_HORIZON = 6.0
local TIMELINE_ACTION_LIMIT = (D.FORECAST_LIMIT or 3) + 1
local FORECAST_POOL_SIZE = TIMELINE_ACTION_LIMIT + 2
local INSERT_OFFSET = 28
local POSITION_EASE_SPEED = 6.0
local FADE_IN_SPEED = 7.0
local FADE_OUT_SPEED = 5.0
local PROMOTION_FADE_OUT_SPEED = 2.2
local PROMOTION_TRAVEL_SPEED = 720
local CURRENT_BLEND_SPEED = 6.0
local SLOT_PROMOTION_STAGE_TIME = 0.05
local SLOT_PROMOTION_MAX_TIME = 0.55
local SLOT_PROMOTION_ARRIVAL_X = HIT_X + 2
local VOLATILE_FORECAST_CONFIRM_TIME = 0.12
local VOLATILE_FORECAST_GRACE_TIME = 0.20
local RESOURCE_STATUS_LIMIT = 3
local RESOURCE_ICON_SIZE = 18
local RESOURCE_COOLDOWN_SIZE = RESOURCE_ICON_SIZE - 4
local RESOURCE_CELL_WIDTH = 58
local RESOURCE_ROOT_PADDING = 4
local RESOURCE_READY_PULSE_SPEED = 2.6
local RESOURCE_READY_BORDER_MIN = 0.58
local RESOURCE_READY_BORDER_MAX = 0.96

-- Slam and the two on-swing rage dumps can become executable from a single
-- rage/swing update. Give those volatile recommendations a short visual path
-- through the timeline even when they were not present in the prior forecast.
-- Other actions use the same hand-off whenever they already own a visible
-- forecast frame, but an unforeseen urgent proc is never presentation-gated.
local SLOT_PROMOTION_KEYS = {
    SLAM = true,
    HEROIC_STRIKE = true,
    CLEAVE = true,
}

local COLOR = {
    blue = { 0.31, 0.67, 0.95 },
    ready = { 0.20, 0.95, 0.35 },
    proc = { 1.00, 0.82, 0.15 },
    gcd = { 1.00, 0.55, 0.12 },
    wait = { 0.35, 0.65, 1.00 },
    pool = { 0.75, 0.40, 1.00 },
    rangeGrace = { 1.00, 0.62, 0.12 },
    range = { 1.00, 0.25, 0.20 },
    disabled = { 0.35, 0.35, 0.35 },
    cooldown = { 0.42, 0.50, 0.64 },
    queue = { 0.15, 0.90, 0.90 },
    casting = { 0.28, 0.84, 1.00 },
    forecast = { 0.55, 0.76, 1.00 },
}

local SHORT_NAMES = {
    BATTLE_STANCE = "战",
    DEFENSIVE_STANCE = "防",
    BERSERKER_STANCE = "狂",
    MORTAL_STRIKE = "MS",
    OVERPOWER = "OP",
    WHIRLWIND = "WW",
    SWEEPING_STRIKES = "SS",
    BATTLE_SHOUT = "BS",
    BERSERKER_RAGE = "BR",
    BLOODRAGE = "BL",
    HEROIC_STRIKE = "HS",
    CLEAVE = "CLV",
    SLAM = "SL",
    EXECUTE = "EX",
    REND = "R",
    CONCUSSION_BLOW = "CB",
    SHIELD_SLAM = "盾",
    REVENGE = "RV",
    THUNDER_CLAP = "TC",
    DEMORALIZING_SHOUT = "DS",
    SUNDER_ARMOR = "SA",
    SHIELD_BLOCK = "SB",
    LIGHTNING_BOLT = "LB",
    CHAIN_LIGHTNING = "CL",
    EARTH_SHOCK = "ES",
    FROST_SHOCK = "FrS",
    FLAME_SHOCK = "FS",
    LAVA_BURST = "LvB",
    EARTHQUAKE = "EQ",
}

local function Clamp(value, low, high)
    value = tonumber(value) or low
    if value < low then return low end
    if value > high then return high end
    return value
end

local function GetStateColor(state)
    if state == "ready" then
        return COLOR.ready
    elseif state == "proc" then
        return COLOR.proc
    elseif state == "gcd" then
        return COLOR.gcd
    elseif state == "pool" then
        return COLOR.pool
    elseif state == "range" then
        return COLOR.range
    elseif state == "queue" or state == "queued" then
        return COLOR.queue
    elseif state == "casting" then
        return COLOR.casting
    elseif state == "forecast" then
        return COLOR.forecast
    elseif state == "disabled" then
        return COLOR.disabled
    elseif state == "cooldown" then
        return COLOR.cooldown
    end
    return COLOR.wait
end

local function FormatTime(value)
    value = tonumber(value)
    if not value or value <= 0.05 then
        return ""
    end
    if value < 10 then
        return string.format("%.1f", value)
    end
    return tostring(math.ceil(value))
end

local function AddBackdrop(frame, edgeSize, alpha)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = edgeSize or 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(0.015, 0.02, 0.03, alpha or 0.88)
    frame:SetBackdropBorderColor(
        COLOR.blue[1],
        COLOR.blue[2],
        COLOR.blue[3],
        0.72
    )
end

local function CreateIcon(name, parent, size)
    local frame = CreateFrame("Frame", name, parent)
    frame:SetWidth(size)
    frame:SetHeight(size)
    AddBackdrop(frame, 7, 0.96)

    local texture = frame:CreateTexture(nil, "ARTWORK")
    texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
    texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    frame.texture = texture

    local shade = frame:CreateTexture(nil, "OVERLAY")
    shade:SetAllPoints(texture)
    shade:SetTexture(0, 0, 0, 0.42)
    shade:Hide()
    frame.shade = shade

    local time = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    time:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    time:SetTextColor(1, 1, 1, 1)
    time:SetText("")
    frame.time = time

    local short = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    short:SetPoint("BOTTOM", frame, "BOTTOM", 0, 2)
    short:SetTextColor(1, 1, 1, 0.98)
    short:SetText("")
    frame.short = short

    local question = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    question:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -1)
    question:SetTextColor(1, 0.82, 0.15, 1)
    question:SetText("?")
    question:Hide()
    frame.question = question

    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function()
        if not this.actionKey then return end
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetText(
            this.actionName or D:GetName(this.actionKey),
            1,
            0.82,
            0
        )
        if this.actionReason and this.actionReason ~= "" then
            GameTooltip:AddLine(this.actionReason, 1, 1, 1, true)
        end
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return frame
end

local root = CreateFrame("Frame", "DoiteDPSMainFrame", UIParent)
UI.root = root
root:SetWidth(ROOT_WIDTH)
root:SetHeight(ROOT_HEIGHT)
root:SetFrameStrata("MEDIUM")
root:SetMovable(true)
if root.SetClampedToScreen then
    root:SetClampedToScreen(true)
end

local info = root:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
info:SetPoint("BOTTOMRIGHT", root, "TOPRIGHT", -4, 2)
info:SetWidth(96)
info:SetJustifyH("RIGHT")
info:SetTextColor(0.52, 0.82, 1.00, 1)
info:SetText("")
info:Hide()
UI.info = info

local track = CreateFrame("Frame", "DoiteDPSTimelineTrack", root)
UI.track = track
track:SetPoint("TOPLEFT", root, "TOPLEFT", 0, 0)
track:SetWidth(ROOT_WIDTH)
track:SetHeight(ROOT_HEIGHT)

local readySlot = CreateFrame("Frame", "DoiteDPSReadySlot", root)
readySlot:SetPoint("CENTER", root, "TOPLEFT", HIT_X, TRACK_CENTER_Y)
readySlot:SetWidth(READY_SLOT_SIZE)
readySlot:SetHeight(READY_SLOT_SIZE)
readySlot:SetFrameLevel(root:GetFrameLevel() + 2)
readySlot:EnableMouse(false)
AddBackdrop(readySlot, 7, 0.88)
readySlot:SetBackdropColor(0.005, 0.008, 0.015, 0.68)
readySlot:SetBackdropBorderColor(
    COLOR.ready[1],
    COLOR.ready[2],
    COLOR.ready[3],
    0.62
)
UI.readySlot = readySlot

local rangeBadge = readySlot:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalSmall"
)
rangeBadge:SetPoint("TOPRIGHT", readySlot, "TOPRIGHT", 5, 5)
rangeBadge:SetText(zh and "远" or "OUT")
rangeBadge:SetTextColor(
    COLOR.range[1],
    COLOR.range[2],
    COLOR.range[3],
    1
)
rangeBadge:Hide()
UI.rangeBadge = rangeBadge

local readySlotEdgeX = HIT_X + (READY_SLOT_SIZE / 2)
local railShadow = track:CreateTexture(nil, "BACKGROUND")
railShadow:SetPoint(
    "CENTER",
    root,
    "TOPLEFT",
    (readySlotEdgeX + FORECAST_MAX_X) / 2,
    TRACK_CENTER_Y
)
railShadow:SetWidth(FORECAST_MAX_X - readySlotEdgeX)
railShadow:SetHeight(3)
railShadow:SetTexture(0, 0, 0, 0.72)
UI.railShadow = railShadow

local readyLead = track:CreateTexture(nil, "BACKGROUND")
readyLead:SetPoint(
    "CENTER",
    root,
    "TOPLEFT",
    (readySlotEdgeX + FORECAST_MIN_X) / 2,
    TRACK_CENTER_Y
)
readyLead:SetWidth(FORECAST_MIN_X - readySlotEdgeX)
readyLead:SetHeight(1)
readyLead:SetTexture(0.20, 0.95, 0.35, 0.38)
UI.readyLead = readyLead

local guide = track:CreateTexture(nil, "BACKGROUND")
guide:SetPoint(
    "CENTER",
    root,
    "TOPLEFT",
    (FORECAST_MIN_X + FORECAST_MAX_X) / 2,
    TRACK_CENTER_Y
)
guide:SetWidth(FORECAST_MAX_X - FORECAST_MIN_X)
guide:SetHeight(1)
guide:SetTexture(0.32, 0.55, 0.82, 0.34)
UI.guide = guide

UI.ticks = {}
local tickIndex = 0
while tickIndex <= 4 do
    local tick = track:CreateTexture(nil, "ARTWORK")
    local tickX = FORECAST_MIN_X +
        (((FORECAST_MAX_X - FORECAST_MIN_X) / 4) * tickIndex)
    local tickSize = 2
    if tickIndex == 0 or tickIndex == 4 then
        tickSize = 3
    end
    tick:SetPoint("CENTER", root, "TOPLEFT", tickX, TRACK_CENTER_Y)
    tick:SetWidth(tickSize)
    tick:SetHeight(tickSize)
    if tickIndex == 0 then
        tick:SetTexture(0.20, 0.95, 0.35, 0.48)
    else
        tick:SetTexture(0.42, 0.65, 0.88, 0.42)
    end
    UI.ticks[tickIndex + 1] = tick
    tickIndex = tickIndex + 1
end

local pendingText = track:CreateFontString(nil, "OVERLAY", "GameFontNormal")
pendingText:SetPoint("CENTER", root, "TOPLEFT", 176, TRACK_CENTER_Y)
pendingText:SetWidth(220)
pendingText:SetJustifyH("CENTER")
pendingText:SetTextColor(0.72, 0.80, 0.92, 1)
pendingText:SetText("")
pendingText:Hide()
UI.pendingText = pendingText

local currentIcon = CreateIcon("DoiteDPSCurrentIcon", root, 38)
currentIcon:SetPoint("CENTER", root, "TOPLEFT", HIT_X, TRACK_CENTER_Y)
currentIcon:SetFrameLevel(root:GetFrameLevel() + 5)
currentIcon:SetBackdropBorderColor(0, 0, 0, 0)
UI.currentIcon = currentIcon

local currentGhost = CreateIcon("DoiteDPSCurrentGhost", root, 38)
currentGhost:SetPoint("CENTER", root, "TOPLEFT", HIT_X, TRACK_CENTER_Y)
currentGhost:SetFrameLevel(root:GetFrameLevel() + 4)
currentGhost:SetBackdropBorderColor(0, 0, 0, 0)
currentGhost:EnableMouse(false)
currentGhost:Hide()
UI.currentGhost = currentGhost
UI.currentBlend = 1

local resourceRoot = CreateFrame(
    "Frame",
    "DoiteDPSResourceStatusFrame",
    UIParent
)
resourceRoot:SetWidth(RESOURCE_CELL_WIDTH + RESOURCE_ROOT_PADDING)
resourceRoot:SetHeight(22)
resourceRoot:SetPoint("BOTTOMLEFT", root, "TOPLEFT", 0, 2)
resourceRoot:SetFrameStrata("MEDIUM")
resourceRoot:SetFrameLevel(root:GetFrameLevel() + 7)
AddBackdrop(resourceRoot, 6, 0.84)
resourceRoot:SetBackdropColor(0.008, 0.012, 0.022, 0.78)
resourceRoot:Hide()
UI.resourceRoot = resourceRoot

local tankAssistBadge = CreateFrame(
    "Frame",
    "DoiteDPSTankAssistBadge",
    root
)
tankAssistBadge:SetWidth(22)
tankAssistBadge:SetHeight(22)
tankAssistBadge:SetPoint("BOTTOMLEFT", root, "TOPLEFT", 182, 2)
tankAssistBadge:SetFrameLevel(root:GetFrameLevel() + 7)
AddBackdrop(tankAssistBadge, 6, 0.84)
tankAssistBadge:SetBackdropColor(0.008, 0.012, 0.022, 0.82)

local tankAssistTexture = tankAssistBadge:CreateTexture(nil, "ARTWORK")
tankAssistTexture:SetPoint(
    "TOPLEFT",
    tankAssistBadge,
    "TOPLEFT",
    3,
    -3
)
tankAssistTexture:SetPoint(
    "BOTTOMRIGHT",
    tankAssistBadge,
    "BOTTOMRIGHT",
    -3,
    3
)
tankAssistTexture:SetTexture("Interface\\Icons\\INV_Shield_06")
tankAssistTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
tankAssistBadge.texture = tankAssistTexture
tankAssistBadge:Hide()
tankAssistBadge:SetScript("OnEnter", function()
    local status = D:GetTankAssistStatus()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:SetText(
        zh and "协助坦克" or "Tank assist",
        1,
        0.82,
        0
    )
    GameTooltip:AddLine(
        D:GetTankAssistStatusText(status),
        0.88,
        0.90,
        0.96,
        1
    )
    GameTooltip:AddLine(
        zh and "仅在按下 DDPS 输出键时切换目标；手动敌对目标优先。"
            or "Targets change only on a DDPS output press; a manual hostile target wins.",
        0.70,
        0.76,
        0.84,
        1
    )
    GameTooltip:Show()
end)
tankAssistBadge:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
UI.tankAssistBadge = tankAssistBadge

UI.resourceIcons = {}
local resourceIndex = 1
while resourceIndex <= RESOURCE_STATUS_LIMIT do
    local resourceIcon = CreateIcon(
        "DoiteDPSResourceIcon" .. tostring(resourceIndex),
        resourceRoot,
        RESOURCE_ICON_SIZE
    )
    resourceIcon:SetPoint(
        "CENTER",
        resourceRoot,
        "TOPLEFT",
        11 + ((resourceIndex - 1) * RESOURCE_CELL_WIDTH),
        -11
    )
    resourceIcon:SetFrameLevel(resourceRoot:GetFrameLevel() + 1)
    resourceIcon.time:Hide()

    local cooldown = CreateFrame(
        "Model",
        resourceIcon:GetName() .. "Cooldown",
        resourceIcon,
        "CooldownFrameTemplate"
    )
    cooldown:ClearAllPoints()
    cooldown:SetWidth(RESOURCE_COOLDOWN_SIZE)
    cooldown:SetHeight(RESOURCE_COOLDOWN_SIZE)
    cooldown:SetPoint("CENTER", resourceIcon, "CENTER", 0, 0)
    cooldown:SetFrameLevel(resourceIcon:GetFrameLevel() + 1)
    cooldown:EnableMouse(false)
    cooldown.noCooldownCount = true
    cooldown:Hide()
    resourceIcon.cooldown = cooldown

    local statusText = resourceIcon:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalSmall"
    )
    statusText:SetPoint("LEFT", resourceIcon, "RIGHT", 3, 0)
    statusText:SetWidth(34)
    statusText:SetJustifyH("LEFT")
    statusText:SetText("")
    resourceIcon.statusText = statusText

    resourceIcon:Hide()
    UI.resourceIcons[resourceIndex] = resourceIcon
    resourceIndex = resourceIndex + 1
end

UI.forecastIcons = {}
local forecastIndex = 1
while forecastIndex <= FORECAST_POOL_SIZE do
    local forecastIcon = CreateIcon(
        "DoiteDPSForecastIcon" .. tostring(forecastIndex),
        root,
        34
    )
    forecastIcon:SetPoint(
        "CENTER",
        root,
        "TOPLEFT",
        FORECAST_MAX_X,
        TRACK_CENTER_Y
    )
    forecastIcon:SetFrameLevel(root:GetFrameLevel() + 3)
    forecastIcon.timelineActive = false
    forecastIcon.timelineLeaving = false
    forecastIcon:Hide()
    UI.forecastIcons[forecastIndex] = forecastIcon
    forecastIndex = forecastIndex + 1
end

local unlockHint = root:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
unlockHint:SetPoint("BOTTOM", root, "TOP", 0, 2)
unlockHint:SetTextColor(0.20, 1.00, 0.35, 1)
unlockHint:SetText(D.Text.UNLOCKED)
unlockHint:Hide()
UI.unlockHint = unlockHint

local function SavePosition()
    if not D.DB then return end
    local point, relativeTo, relativePoint, x, y = root:GetPoint()
    D.DB.point = point or "CENTER"
    D.DB.relativePoint = relativePoint or "CENTER"
    D.DB.x = x or 0
    D.DB.y = y or 0
end

function UI:BeginDrag()
    if D.DB and not D.DB.locked then
        self.dragging = true
        root:StartMoving()
    end
end

function UI:EndDrag()
    if not self.dragging then return end
    self.dragging = false
    root:StopMovingOrSizing()
    SavePosition()
end

local function RegisterDragSurface(frame)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        UI:BeginDrag()
    end)
    frame:SetScript("OnDragStop", function()
        UI:EndDrag()
    end)
end

RegisterDragSurface(root)
RegisterDragSurface(currentIcon)
RegisterDragSurface(resourceRoot)
RegisterDragSurface(tankAssistBadge)
local resourceDragIndex = 1
while resourceDragIndex <= table.getn(UI.resourceIcons) do
    RegisterDragSurface(UI.resourceIcons[resourceDragIndex])
    resourceDragIndex = resourceDragIndex + 1
end
local dragIndex = 1
while dragIndex <= table.getn(UI.forecastIcons) do
    RegisterDragSurface(UI.forecastIcons[dragIndex])
    dragIndex = dragIndex + 1
end

function UI:ApplyLock()
    if not D.DB then return end
    if D.DB.locked and self.dragging then
        self:EndDrag()
    end
    root:EnableMouse(not D.DB.locked)
    resourceRoot:EnableMouse(not D.DB.locked)
    tankAssistBadge:EnableMouse(not D.DB.locked)
    if D.DB.locked then
        self.unlockHint:Hide()
    else
        self.unlockHint:Show()
    end
end

function UI:ApplySettings()
    if not D.DB then
        D:InitializeDB()
    end

    root:ClearAllPoints()
    root:SetPoint(
        D.DB.point or "CENTER",
        UIParent,
        D.DB.relativePoint or "CENTER",
        D.DB.x or 0,
        D.DB.y or -125
    )
    root:SetScale(D.DB.scale or 1)
    resourceRoot:SetScale(D.DB.scale or 1)
    self:ApplyLock()
end

function UI:UpdateTankAssistBadge()
    -- Tank state is presented by the action-bar marker control. Keep the
    -- recommendation timeline free of a second status badge.
    self.tankAssistBadge.tankAssistState = nil
    self.tankAssistBadge.tankAssistText = nil
    self.tankAssistBadge:Hide()
end

function UI:SetIcon(frame, action, showShort, isForecast)
    if not action or not action.key then
        frame:Hide()
        return
    end

    frame:Show()
    frame.actionKey = action.key
    frame.actionName = action.name or D:GetName(action.key)
    frame.actionReason = action.reason or ""
    frame.texture:SetTexture(action.texture or D:GetTexture(action.key))

    local color = isForecast and COLOR.forecast or
        GetStateColor(action.state)
    local borderAlpha = isForecast and 0.72 or 1
    frame:SetBackdropBorderColor(
        color[1],
        color[2],
        color[3],
        borderAlpha
    )

    if not isForecast and (
        action.state == "disabled"
        or action.state == "wait"
        or action.state == "pool"
        or action.state == "range"
        or action.state == "cooldown"
    ) then
        frame.texture:SetVertexColor(0.48, 0.48, 0.52, 1)
        frame.shade:Show()
    elseif not isForecast and action.state == "gcd" then
        frame.texture:SetVertexColor(0.76, 0.76, 0.82, 1)
        frame.shade:Show()
    else
        frame.texture:SetVertexColor(1, 1, 1, 1)
        frame.shade:Hide()
    end

    frame.time:SetText(FormatTime(action.eta))
    if action.uncertain then
        frame.question:Show()
    else
        frame.question:Hide()
    end

    if showShort then
        frame.short:SetText(SHORT_NAMES[action.key] or "")
    else
        frame.short:SetText("")
    end
end

local function ClearResourceCooldown(frame)
    if not frame.cooldown then return end
    frame.cooldownToken = nil
    frame.cooldownStart = nil
    frame.cooldownDuration = nil
    frame.cooldown.start = 0
    frame.cooldown.duration = 0
    frame.cooldown.stopping = 1
    frame.cooldown:Hide()
end

local function SyncResourceCooldown(frame, action)
    local duration = tonumber(action and action.cooldownDuration) or 0
    local start = tonumber(action and action.cooldownStart)
    if not action
        or action.state ~= "cooldown"
        or duration <= 0.05 then
        ClearResourceCooldown(frame)
        return
    end

    if not start then
        local remaining = tonumber(action.eta) or duration
        start = GetTime() + remaining - duration
    end

    local token = tostring(action.key) .. ":" ..
        tostring(action.timelineCycle or 0) .. ":" ..
        tostring(duration)
    if frame.cooldownToken == token then
        return
    end

    frame.cooldownToken = token
    frame.cooldownStart = start
    frame.cooldownDuration = duration
    frame.cooldown.noCooldownCount = true
    frame.cooldown.start = start
    frame.cooldown.duration = duration
    frame.cooldown.stopping = 0
    frame.cooldown:SetSequence(0)
    local progress = Clamp((GetTime() - start) / duration, 0, 1)
    frame.cooldown:SetSequenceTime(0, progress * 1000)
    frame.cooldown:Show()
end

function UI:SyncResourceActions(actions)
    local hasAction = false
    local visibleCount = 0
    local i = 1
    while i <= table.getn(self.resourceIcons) do
        local frame = self.resourceIcons[i]
        local action = actions and actions[i] or nil
        if action then
            hasAction = true
            visibleCount = visibleCount + 1
            self:SetIcon(frame, action, false, false)
            frame.time:Hide()
            frame.resourceState = action.state
            SyncResourceCooldown(frame, action)
            if action.state == "cooldown" then
                frame.statusText:SetText(FormatTime(action.eta))
                frame.statusText:SetTextColor(0.72, 0.80, 0.92, 1)
                frame.texture:SetVertexColor(1, 1, 1, 1)
                frame.shade:Hide()
            else
                frame.statusText:SetText("")
            end
            if action.state == "ready" then
                frame:SetAlpha(1.00)
            elseif action.state == "cooldown" then
                frame:SetAlpha(1.00)
            else
                frame:SetAlpha(0.64)
            end
            frame:Show()
        else
            frame.actionKey = nil
            frame.actionName = nil
            frame.actionReason = nil
            frame.resourceState = nil
            frame.statusText:SetText("")
            frame:SetAlpha(1)
            ClearResourceCooldown(frame)
            frame:Hide()
        end
        i = i + 1
    end
    if hasAction then
        self.resourceRoot:SetWidth(
            (visibleCount * RESOURCE_CELL_WIDTH) + RESOURCE_ROOT_PADDING
        )
        self.resourceRoot:Show()
    else
        self.resourceRoot:Hide()
    end
    self:AnimateResourceStatus()
end

function UI:AnimateResourceStatus()
    local wave = (
        math.sin(GetTime() * RESOURCE_READY_PULSE_SPEED) + 1
    ) * 0.5
    local borderAlpha = RESOURCE_READY_BORDER_MIN + (
        (RESOURCE_READY_BORDER_MAX - RESOURCE_READY_BORDER_MIN) * wave
    )
    local iconAlpha = 0.95 + (0.05 * wave)

    local i = 1
    while i <= table.getn(self.resourceIcons) do
        local frame = self.resourceIcons[i]
        if frame:IsVisible() and frame.resourceState == "ready" then
            frame:SetBackdropBorderColor(
                COLOR.ready[1],
                COLOR.ready[2],
                COLOR.ready[3],
                borderAlpha
            )
            frame:SetAlpha(iconAlpha)
        elseif frame:IsVisible()
            and frame.resourceState == "cooldown"
            and frame.cooldownStart
            and frame.cooldownDuration
            and frame.cooldownDuration > 0 then
            local progress = Clamp(
                (GetTime() - frame.cooldownStart) /
                    frame.cooldownDuration,
                0,
                1
            )
            frame.cooldown:SetSequenceTime(0, progress * 1000)
            frame.cooldown:Show()
        end
        i = i + 1
    end
end

function UI:UpdateReleaseCue(action, noTarget)
    local state = action and action.state or "disabled"
    self.releaseReady = not noTarget and (
        state == "ready"
        or state == "proc"
        or state == "queue"
    )
end

local function ResetForecastFrame(frame)
    frame.timelineUsed = false
    frame.timelineActive = false
    frame.timelineLeaving = false
    frame.timelinePromoted = false
    frame.timelinePromotionCancelled = false
    frame.timelineNew = false
    frame.timelineInserted = false
    frame.timelineCycleRestart = false
    frame.timelineAllowRight = false
    frame.timelineKey = nil
    frame.timelineTarget = nil
    frame.timelineEta = nil
    frame.timelineRank = nil
    frame.timelineCastHeld = nil
    frame.timelineCycle = nil
    frame.timelineSlamCast = nil
    frame.timelineGoalX = nil
    frame.timelineDisplayX = nil
    frame.timelineAlpha = nil
    frame.actionKey = nil
    frame.actionName = nil
    frame.actionReason = nil
    frame.time:SetText("")
    frame.short:SetText("")
    frame.question:Hide()
    frame:SetAlpha(1)
    frame:Hide()
end

function UI:ResetRuntimeState()
    self.lastMode = nil
    self.currentKey = nil
    self.currentState = nil
    self.currentBlend = 1
    self.slotOccupied = false
    self.releaseReady = false
    self.targetRangeState = nil
    self.currentSnapshot = nil
    self.previousSnapshot = nil
    self.previousSnapshotTime = nil

    self.slotPromotionKey = nil
    self.slotPromotionStarted = nil
    self.slotPromotionPhase = nil
    self.slotPromotionTravelKey = nil
    self.slotPromotionArrivedKey = nil
    self.forecastPresence = {}
    self.forecastSyncSerial = 0

    self.castLocked = false
    self.castLockToken = nil
    self.castLockKey = nil
    self.castLockReason = nil
    self.castLockAction = nil
    self.castHeldTimelineAction = nil
    self.pendingTimelineAction = nil
    self.castQueuedForecasts = nil

    self.timelineActions = {}
    self.timelineCycleByKey = {}
    self.activeTimelineFrames = {}
    self.lastAnimationTime = GetTime()

    self.currentIcon:Hide()
    self.currentGhost:Hide()
    local resourceIndex = 1
    while resourceIndex <= table.getn(self.resourceIcons) do
        local resourceIcon = self.resourceIcons[resourceIndex]
        resourceIcon.resourceState = nil
        resourceIcon.statusText:SetText("")
        resourceIcon:SetAlpha(1)
        ClearResourceCooldown(resourceIcon)
        resourceIcon:Hide()
        resourceIndex = resourceIndex + 1
    end
    self.resourceRoot:Hide()
    self.tankAssistBadge:Hide()
    self.rangeBadge:Hide()
    self.pendingText:Hide()
    self.info:SetText("")

    local i = 1
    while i <= table.getn(self.forecastIcons) do
        ResetForecastFrame(self.forecastIcons[i])
        i = i + 1
    end
end

local function FindForecastFrame(self, action)
    local key = action.key
    local actionCycle = tonumber(action.timelineCycle) or 0
    local i = 1
    while i <= table.getn(self.forecastIcons) do
        local frame = self.forecastIcons[i]
        if not frame.timelineUsed
            and frame.timelineActive
            and frame.timelineKey == key
            and (tonumber(frame.timelineCycle) or 0)
                == actionCycle then
            return frame
        end
        i = i + 1
    end

    -- Casting can begin one update after the recommendation has already
    -- promoted this same skill toward the slot. Reclaim that visible frame
    -- for the cast-held action instead of creating a duplicate occurrence.
    if action.timelineCastHeld then
        i = 1
        while i <= table.getn(self.forecastIcons) do
            local frame = self.forecastIcons[i]
            if not frame.timelineUsed
                and frame.timelineLeaving
                and frame.timelinePromoted
                and frame.timelineKey == key
                and (tonumber(frame.timelineCycle) or 0)
                    == actionCycle then
                return frame
            end
            i = i + 1
        end
    end

    -- A volatile forecast can briefly disappear at a swing/core boundary.
    -- If it returns before the old note has finished fading, revive that
    -- occurrence in place rather than spawning a second icon at the right.
    i = 1
    while i <= table.getn(self.forecastIcons) do
        local frame = self.forecastIcons[i]
        if not frame.timelineUsed
            and frame.timelineLeaving
            and not frame.timelinePromoted
            and frame.timelineKey == key
            and (tonumber(frame.timelineCycle) or 0)
                == actionCycle then
            return frame
        end
        i = i + 1
    end

    i = 1
    while i <= table.getn(self.forecastIcons) do
        local frame = self.forecastIcons[i]
        if not frame.timelineUsed
            and not frame.timelineActive
            and not frame.timelineLeaving then
            return frame
        end
        i = i + 1
    end

    local leavingFrame = nil
    local leavingAlpha = 2
    i = 1
    while i <= table.getn(self.forecastIcons) do
        local frame = self.forecastIcons[i]
        local alpha = tonumber(frame.timelineAlpha) or 1
        if not frame.timelineUsed
            and frame.timelineLeaving
            and alpha < leavingAlpha then
            leavingFrame = frame
            leavingAlpha = alpha
        end
        i = i + 1
    end
    if leavingFrame then
        ResetForecastFrame(leavingFrame)
        return leavingFrame
    end

    i = 1
    while i <= table.getn(self.forecastIcons) do
        local frame = self.forecastIcons[i]
        if not frame.timelineUsed then
            ResetForecastFrame(frame)
            return frame
        end
        i = i + 1
    end
    return nil
end

local function ForecastFrameScore(frame)
    local score = tonumber(frame.timelineAlpha) or 0
    if frame.timelineUsed then score = score + 100 end
    if frame.timelineActive then score = score + 20 end
    if frame.timelineLeaving then score = score + 10 end
    if frame.timelinePromoted then score = score + 2 end
    return score
end

local function CollapseDuplicateForecastFrames(self)
    local ownerByKey = {}
    local i = 1
    while i <= table.getn(self.forecastIcons) do
        local frame = self.forecastIcons[i]
        local key = frame.timelineKey
        if key then
            local owner = ownerByKey[key]
            if not owner then
                ownerByKey[key] = frame
            elseif ForecastFrameScore(frame)
                > ForecastFrameScore(owner) then
                ResetForecastFrame(owner)
                ownerByKey[key] = frame
            else
                ResetForecastFrame(frame)
            end
        end
        i = i + 1
    end
end

local function FindVisibleForecastFrame(self, key)
    if not key then return nil end
    local i = 1
    while i <= table.getn(self.forecastIcons) do
        local frame = self.forecastIcons[i]
        if frame.timelineKey == key
            and (frame.timelineActive
                or (frame.timelineLeaving
                    and frame.timelinePromoted)) then
            return frame
        end
        i = i + 1
    end
    return nil
end

local function ShouldPresentForecastAction(
    self,
    action,
    now,
    syncSerial
)
    local key = action and action.key
    if not key or not SLOT_PROMOTION_KEYS[key] then
        return true
    end

    self.forecastPresence = self.forecastPresence or {}
    local presence = self.forecastPresence[key]
    if not presence then
        presence = {}
        self.forecastPresence[key] = presence
    end

    local lastSeen = tonumber(presence.lastSeen)
    local continuous = presence.lastSerial == (syncSerial - 1)
    local returnedDuringGrace = presence.confirmed
        and lastSeen
        and (now - lastSeen) <= VOLATILE_FORECAST_GRACE_TIME
    if not continuous and not returnedDuringGrace then
        presence.firstSeen = now
        presence.confirmed = false
    elseif not presence.firstSeen then
        presence.firstSeen = now
    end

    presence.lastSeen = now
    presence.lastSerial = syncSerial

    if action.timelinePending or action.timelineCastHeld then
        -- The executable action is already waiting for the slot. It must be
        -- visible immediately so its promotion path is never presentation-
        -- blocked by the forecast-only confirmation delay.
        presence.confirmed = true
        return true
    end

    if FindVisibleForecastFrame(self, key) then
        presence.confirmed = true
    elseif not presence.confirmed
        and (now - (tonumber(presence.firstSeen) or now))
            >= VOLATILE_FORECAST_CONFIRM_TIME then
        presence.confirmed = true
    end
    return presence.confirmed and true or false
end

local function HoldConfirmedForecastFrames(self, now, syncSerial)
    local presenceByKey = self.forecastPresence or {}
    local key, presence
    for key, presence in pairs(presenceByKey) do
        if presence.lastSerial ~= syncSerial then
            local lastSeen = tonumber(presence.lastSeen)
            local missingFor = lastSeen and (now - lastSeen) or 999
            if presence.confirmed
                and missingFor <= VOLATILE_FORECAST_GRACE_TIME
                and self.slotPromotionKey ~= key
                and self.slotPromotionTravelKey ~= key
                and self.slotPromotionArrivedKey ~= key
                and not (self.currentKey == key
                    and self.slotOccupied) then
                local i = 1
                while i <= table.getn(self.forecastIcons) do
                    local frame = self.forecastIcons[i]
                    if frame.timelineActive
                        and frame.timelineKey == key then
                        -- Keep the existing note and target; a candidate that
                        -- returns during the grace period reuses this exact
                        -- frame without an alpha/position restart.
                        frame.timelineUsed = true
                        break
                    end
                    i = i + 1
                end
            elseif missingFor > VOLATILE_FORECAST_GRACE_TIME then
                presence.confirmed = false
                presence.firstSeen = nil
            end
        end
    end
end

local function CancelSlotPromotion(self)
    local key = self.slotPromotionKey
    if key then
        local i = 1
        while i <= table.getn(self.forecastIcons) do
            local frame = self.forecastIcons[i]
            if frame.timelineKey == key
                and frame.timelineLeaving
                and frame.timelinePromoted then
                -- The recommendation vanished before reaching the slot.
                -- Let its old note fade on the rail instead of completing a
                -- misleading trip into the ready position.
                frame.timelinePromoted = false
                frame.timelinePromotionCancelled = true
            end
            i = i + 1
        end
    end
    self.slotPromotionKey = nil
    self.slotPromotionStarted = nil
    self.slotPromotionPhase = nil
    self.slotPromotionTravelKey = nil
    self.slotPromotionArrivedKey = nil
end

local function PrepareSlotPromotion(self, action, now)
    self.slotPromotionTravelKey = nil
    self.slotPromotionArrivedKey = nil

    local key = action and action.key
    local state = action and action.state
    local promotable = state == "ready"
        or state == "proc"
        or state == "queue"
        or state == "casting"
        or state == "queued"
    if not D.DB.showForecast
        or not promotable
        or not key
        or key == "WAIT"
        or key == "AUTO_ATTACK" then
        CancelSlotPromotion(self)
        return false, false, false
    end

    if self.slotPromotionKey
        and self.slotPromotionKey ~= key then
        CancelSlotPromotion(self)
    end

    if not self.slotPromotionKey then
        if self.slotOccupied and self.currentKey == key then
            return false, false, false
        end

        local visibleFrame = FindVisibleForecastFrame(self, key)
        if not visibleFrame and not SLOT_PROMOTION_KEYS[key] then
            return false, false, false
        end

        self.slotPromotionKey = key
        self.slotPromotionStarted = now
        -- An action already visible on the rail, including one that jumped
        -- straight to casting/queued between UI refreshes, begins travelling
        -- immediately. A brand-new volatile action first receives one short
        -- visible staging interval on the rail.
        if visibleFrame
            and (tonumber(visibleFrame.timelineAlpha) or 0) >= 0.12 then
            self.slotPromotionStarted =
                now - SLOT_PROMOTION_STAGE_TIME - 0.001
        end
        self.slotPromotionPhase = "stage"
    end

    local elapsed = now -
        (tonumber(self.slotPromotionStarted) or now)
    local visibleFrame = FindVisibleForecastFrame(self, key)
    local displayX = visibleFrame
        and tonumber(visibleFrame.timelineDisplayX) or nil
    local arrived = displayX
        and displayX <= SLOT_PROMOTION_ARRIVAL_X
    if arrived or elapsed >= SLOT_PROMOTION_MAX_TIME then
        self.slotPromotionKey = nil
        self.slotPromotionStarted = nil
        self.slotPromotionPhase = nil
        self.slotPromotionArrivedKey = key
        return false, true, true
    end

    if elapsed < SLOT_PROMOTION_STAGE_TIME then
        self.slotPromotionPhase = "stage"
        return true, false, false
    end

    if not visibleFrame then
        -- A frame can be recycled under a dense four-action queue. Reinsert
        -- the pending action instead of allowing the ready slot to pop in.
        self.slotPromotionPhase = "stage"
        return true, false, false
    end

    self.slotPromotionPhase = "travel"
    self.slotPromotionTravelKey = key
    return true, true, false
end

function UI:SyncForecasts(forecasts, now)
    self.forecastSyncSerial =
        (tonumber(self.forecastSyncSerial) or 0) + 1
    local syncSerial = self.forecastSyncSerial
    if not D.DB.showForecast then
        self.forecastPresence = {}
    end

    local i = 1
    local hadActiveFrames = false
    while i <= table.getn(self.forecastIcons) do
        local frame = self.forecastIcons[i]
        frame.timelineUsed = false
        if frame.timelineActive then
            hadActiveFrames = true
        end
        i = i + 1
    end

    local seenKeys = {}
    local insertionRank = nil
    self.timelineCycleByKey = self.timelineCycleByKey or {}
    if D.DB.showForecast and forecasts then
        local forecastCount = table.getn(forecasts)
        if forecastCount > TIMELINE_ACTION_LIMIT then
            forecastCount = TIMELINE_ACTION_LIMIT
        end

        i = 1
        while i <= forecastCount do
            local action = forecasts[i]
            if action
                and action.key
                and action.key ~= "WAIT"
                and (
                    action.key ~= self.currentKey
                    or action.timelinePending
                )
                and ShouldPresentForecastAction(
                    self,
                    action,
                    now,
                    syncSerial
                )
                and not seenKeys[action.key] then
                seenKeys[action.key] = true
                local frame = FindForecastFrame(self, action)
                if frame then
                    local actionCycle =
                        tonumber(action.timelineCycle) or 0
                    local previousCycle =
                        self.timelineCycleByKey[action.key]
                    local isNew = frame.timelineKey ~= action.key
                        or (tonumber(frame.timelineCycle) or 0)
                            ~= actionCycle
                    local cycleRestart = isNew
                        and actionCycle > 0
                        and previousCycle ~= nil
                        and previousCycle ~= actionCycle
                    local previousRank =
                        tonumber(frame.timelineRank)
                    local previousSlamCast =
                        tonumber(frame.timelineSlamCast)
                    local actionSlamCast =
                        tonumber(action.timelineSlamCast)
                    local slamTimingChanged = previousSlamCast
                        and actionSlamCast
                        and math.abs(
                            previousSlamCast - actionSlamCast
                        ) > 0.03
                    local inserted = false

                    if isNew
                        and not cycleRestart
                        and hadActiveFrames then
                        local compareIndex = 1
                        while compareIndex <=
                            table.getn(self.forecastIcons) do
                            local compareFrame =
                                self.forecastIcons[compareIndex]
                            local compareRank =
                                tonumber(compareFrame.timelineRank) or 99
                            if compareFrame ~= frame
                                and compareFrame.timelineActive
                                and compareRank >= i then
                                inserted = true
                                break
                            end
                            compareIndex = compareIndex + 1
                        end
                    end

                    if actionCycle > 0 then
                        self.timelineCycleByKey[action.key] =
                            actionCycle
                    end
                    local eta = tonumber(action.eta)
                    if not eta then eta = i * 1.5 end
                    eta = Clamp(eta, 0, 30)

                    local desiredTarget = now + eta
                    if isNew or not frame.timelineTarget then
                        frame.timelineTarget = desiredTarget
                    elseif slamTimingChanged then
                        -- Fury's entire sequence can legitimately move when
                        -- Flurry changes Slam from 2.50 to 1.92 seconds (or
                        -- back). Retarget once for that timing transition;
                        -- ordinary per-frame ETA noise remains monotonic.
                        if desiredTarget
                            > (frame.timelineTarget + 0.08) then
                            frame.timelineAllowRight = true
                        end
                        frame.timelineTarget = desiredTarget
                    elseif desiredTarget
                        < (frame.timelineTarget - 0.08) then
                        -- Once a note is visible, later ETA estimates must
                        -- not postpone its physical arrival. Postponing the
                        -- target while forbidding rightward motion creates a
                        -- visible plateau until time catches up. Earlier
                        -- estimates may still accelerate it smoothly left.
                        frame.timelineTarget = desiredTarget
                    end

                    frame.timelineKey = action.key
                    frame.timelineEta = eta
                    frame.timelineRank = i
                    frame.timelineCycle = actionCycle
                    frame.timelineSlamCast = actionSlamCast
                    frame.timelineInserted = inserted
                    frame.timelineCycleRestart = cycleRestart
                    frame.timelineCastHeld =
                        action.timelineCastHeld and true or false
                    frame.timelineUsed = true
                    frame.timelineActive = true
                    frame.timelineLeaving = false
                    frame.timelinePromoted = false
                    frame.timelinePromotionCancelled = false
                    if isNew then
                        frame.timelineNew = true
                        frame.timelineDisplayX = nil
                        frame.timelineAlpha = 0
                    end
                    if previousRank and i > previousRank then
                        frame.timelineAllowRight = true
                    end
                    if inserted and (
                        not insertionRank or i < insertionRank
                    ) then
                        insertionRank = i
                    end
                    self:SetIcon(frame, action, true, true)
                end
            end
            i = i + 1
        end
    end

    HoldConfirmedForecastFrames(self, now, syncSerial)

    if insertionRank then
        i = 1
        while i <= table.getn(self.forecastIcons) do
            local frame = self.forecastIcons[i]
            local rank = tonumber(frame.timelineRank) or 99
            if frame.timelineUsed and rank >= insertionRank then
                frame.timelineAllowRight = true
            end
            i = i + 1
        end
    end

    i = 1
    while i <= table.getn(self.forecastIcons) do
        local frame = self.forecastIcons[i]
        if not frame.timelineUsed then
            if frame.timelineActive then
                if frame.timelineKey == self.slotPromotionTravelKey
                    or frame.timelineKey ==
                        self.slotPromotionArrivedKey then
                    -- Preserve the same physical note while it crosses the
                    -- short lead between the forecast rail and ready slot.
                    frame.timelineActive = false
                    frame.timelineLeaving = true
                    frame.timelinePromoted = true
                    frame.timelinePromotionCancelled = false
                    frame.timelineTarget = nil
                    if (tonumber(frame.timelineAlpha) or 0) < 0.42 then
                        frame.timelineAlpha = 0.42
                    end
                    frame.time:SetText("")
                elseif frame.timelineKey == self.currentKey
                    and self.slotOccupied then
                    -- The queue head has entered the fixed ready slot.
                    -- Remove its timeline copy immediately so the same
                    -- occurrence is never visible in both places.
                    ResetForecastFrame(frame)
                else
                    frame.timelineActive = false
                    frame.timelineLeaving = true
                    frame.timelinePromoted = false
                end
            elseif not frame.timelineLeaving and frame.timelineKey then
                ResetForecastFrame(frame)
            end
        end
        i = i + 1
    end

    CollapseDuplicateForecastFrames(self)
    self.slotPromotionTravelKey = nil
    self.slotPromotionArrivedKey = nil
end

function UI:AnimateTimeline()
    if not root:IsVisible() then return end

    local now = GetTime()
    local delta = now - (self.lastAnimationTime or (now - 0.016))
    self.lastAnimationTime = now
    delta = Clamp(delta, 0, 0.05)
    local positionFactor = Clamp(delta * POSITION_EASE_SPEED, 0, 1)
    self.activeTimelineFrames = self.activeTimelineFrames or {}
    local activeFrames = self.activeTimelineFrames
    local activeCount = table.getn(activeFrames)
    while activeCount >= 1 do
        activeFrames[activeCount] = nil
        activeCount = activeCount - 1
    end
    local i = 1

    while i <= table.getn(self.forecastIcons) do
        local frame = self.forecastIcons[i]
        if frame.timelineActive and frame.timelineTarget then
            local remaining = frame.timelineTarget - now
            local ratio = Clamp(remaining / TIMELINE_HORIZON, 0, 1)
            local nextGoalX = FORECAST_MIN_X +
                (ratio * (FORECAST_MAX_X - FORECAST_MIN_X))

            -- ETA corrections may move the theoretical position right.
            -- Ignore that rewind here; the later queue pass can still grant
            -- a controlled rightward move when a priority insertion occurs.
            if frame.timelineGoalX then
                nextGoalX = math.min(nextGoalX, frame.timelineGoalX)
            end
            if frame.timelineDisplayX then
                nextGoalX = math.min(nextGoalX, frame.timelineDisplayX)
            end
            frame.timelineGoalX = nextGoalX
            frame.timelineDesiredAlpha =
                0.82 + ((1 - ratio) * 0.16)
            activeFrames[table.getn(activeFrames) + 1] = frame
        end
        i = i + 1
    end

    table.sort(activeFrames, function(a, b)
        local aRank = tonumber(a.timelineRank) or 99
        local bRank = tonumber(b.timelineRank) or 99
        if aRank == bRank then
            return a.timelineGoalX < b.timelineGoalX
        end
        return aRank < bRank
    end)

    activeCount = table.getn(activeFrames)
    i = 2
    while i <= activeCount do
        local previous = activeFrames[i - 1]
        local frame = activeFrames[i]
        frame.timelineGoalX = math.max(
            frame.timelineGoalX,
            previous.timelineGoalX + FORECAST_SPACING
        )
        i = i + 1
    end

    if activeCount > 0 then
        local overflow =
            activeFrames[activeCount].timelineGoalX - FORECAST_MAX_X
        if overflow > 0 then
            i = 1
            while i <= activeCount do
                activeFrames[i].timelineGoalX = math.max(
                    FORECAST_MIN_X,
                    activeFrames[i].timelineGoalX - overflow
                )
                i = i + 1
            end
        end
    end

    local spawnOffset = INSERT_OFFSET
    if activeCount > 0 then
        spawnOffset = math.min(
            INSERT_OFFSET,
            math.max(
                0,
                FORECAST_MAX_X -
                    activeFrames[activeCount].timelineGoalX
            )
        )
    end

    i = 1
    while i <= table.getn(self.forecastIcons) do
        local frame = self.forecastIcons[i]
        if frame.timelineActive and frame.timelineGoalX then
            if frame.timelineNew or not frame.timelineDisplayX then
                if frame.timelineInserted then
                    -- A newly inserted priority action appears at its queue
                    -- position while the displaced queue eases to the right.
                    frame.timelineDisplayX =
                        frame.timelineGoalX
                elseif frame.timelineCycleRestart then
                    -- A completed cooldown starts a new occurrence at the
                    -- far-right edge instead of reusing the old position.
                    frame.timelineDisplayX = FORECAST_MAX_X
                else
                    frame.timelineDisplayX = Clamp(
                        frame.timelineGoalX + spawnOffset,
                        FORECAST_MIN_X,
                        FORECAST_MAX_X
                    )
                end
                frame.timelineAlpha = 0
                frame.timelineNew = false
                frame.timelineInserted = false
                frame.timelineCycleRestart = false
            end

            local displayGoalX = frame.timelineGoalX
            if not frame.timelineAllowRight then
                displayGoalX = math.min(
                    displayGoalX,
                    frame.timelineDisplayX
                )
            end
            frame.timelineDisplayX = frame.timelineDisplayX +
                ((displayGoalX - frame.timelineDisplayX)
                    * positionFactor)
            if frame.timelineAllowRight
                and frame.timelineDisplayX >=
                    (frame.timelineGoalX - 0.50) then
                frame.timelineAllowRight = false
            end

            local alphaFactor = Clamp(delta * FADE_IN_SPEED, 0, 1)
            local desiredAlpha =
                tonumber(frame.timelineDesiredAlpha) or 0.92
            frame.timelineAlpha =
                (tonumber(frame.timelineAlpha) or 0) +
                ((desiredAlpha - (tonumber(frame.timelineAlpha) or 0))
                    * alphaFactor)

            frame.timelineX = frame.timelineDisplayX
            frame.time:SetText(FormatTime(frame.timelineTarget - now))
            frame:SetAlpha(frame.timelineAlpha)
            frame:ClearAllPoints()
            frame:SetPoint(
                "CENTER",
                root,
                "TOPLEFT",
                frame.timelineDisplayX,
                TRACK_CENTER_Y
            )
            frame:Show()
        elseif frame.timelineLeaving then
            frame.timelineDisplayX =
                tonumber(frame.timelineDisplayX) or FORECAST_MAX_X
            local promotionInFlight = frame.timelinePromoted
                and self.slotPromotionKey == frame.timelineKey
            if frame.timelinePromoted then
                -- Use bounded linear travel so a note starting farther right
                -- still reaches the ready slot before visual ownership moves.
                frame.timelineDisplayX = math.max(
                    HIT_X,
                    frame.timelineDisplayX -
                        (delta * PROMOTION_TRAVEL_SPEED)
                )
            elseif frame.timelinePromotionCancelled then
                -- Fade at the cancellation point. Returning a partially
                -- promoted note to FORECAST_MIN_X would create a rightward
                -- snap that looks like a second occurrence.
                frame.timelineDisplayX = frame.timelineDisplayX
            else
                frame.timelineDisplayX = math.max(
                    FORECAST_MIN_X,
                    frame.timelineDisplayX - (delta * 18)
                )
            end

            if promotionInFlight then
                frame.timelineAlpha = math.max(
                    tonumber(frame.timelineAlpha) or 0,
                    0.58
                )
            else
                local fadeSpeed = frame.timelinePromoted
                    and PROMOTION_FADE_OUT_SPEED or FADE_OUT_SPEED
                frame.timelineAlpha =
                    (tonumber(frame.timelineAlpha) or 0.9) -
                    (delta * fadeSpeed)
            end
            if frame.timelineAlpha <= 0.02 then
                ResetForecastFrame(frame)
            else
                frame.timelineX = frame.timelineDisplayX
                frame.time:SetText("")
                frame:SetAlpha(frame.timelineAlpha)
                frame:ClearAllPoints()
                frame:SetPoint(
                    "CENTER",
                    root,
                    "TOPLEFT",
                    frame.timelineDisplayX,
                    TRACK_CENTER_Y
                )
                frame:Show()
            end
        end
        i = i + 1
    end

    local pulse = 0.88
    local releaseWave = (math.sin(now * 7) + 1) / 2
    if self.releaseReady then
        pulse = 0.90 + (releaseWave * 0.10)
    end

    self.currentBlend = Clamp(
        (tonumber(self.currentBlend) or 1) +
            (delta * CURRENT_BLEND_SPEED),
        0,
        1
    )
    self.currentIcon:SetAlpha(
        pulse * self.currentBlend
    )
    if self.currentGhost:IsVisible() then
        if self.currentBlend >= 0.99 then
            self.currentGhost:Hide()
        else
            self.currentGhost:SetAlpha(
                (1 - self.currentBlend) * 0.78
            )
        end
    end

    local slotAlpha = 0.42
    if self.releaseReady then
        slotAlpha = 0.76 + (releaseWave * 0.24)
    elseif self.slotOccupied then
        slotAlpha = 0.62
    end
    local slotColor = COLOR.ready
    if self.targetRangeState == "grace" then
        slotColor = COLOR.rangeGrace
    elseif self.targetRangeState == "out" then
        slotColor = COLOR.range
    end
    self.readySlot:SetBackdropBorderColor(
        slotColor[1],
        slotColor[2],
        slotColor[3],
        slotAlpha
    )
end

local function RecommendationLacksResource(state, recommendation)
    if not recommendation then return false end
    if recommendation.state == "pool" then return true end

    local key = recommendation.key
    local def = key and D.SpellDefs and D.SpellDefs[key]
    if not def or def.virtual then return false end

    if state.resourceType == "rage" then
        local cost = tonumber(recommendation.cost)
            or tonumber(def.cost) or 0
        return cost > 0 and (tonumber(state.rage) or 0) < cost
    end

    if D.IsUsable then
        local _, lacksPower = D:IsUsable(key)
        return lacksPower and true or false
    end
    return false
end

local function BuildResourceText(state, recommendation)
    local resourceType = state.resourceType
    local value
    local suffix
    local color

    if resourceType == "rage" then
        value = tonumber(state.rage) or 0
        suffix = zh and "怒" or " rage"
        color = "ffff5a36"
    elseif resourceType == "mana" then
        value = tonumber(state.mana) or 0
        suffix = zh and "蓝" or " mana"
        color = "ff409cff"
    elseif resourceType == "energy" then
        value = tonumber(state.energy) or tonumber(state.mana) or 0
        suffix = zh and "能" or " energy"
        color = "ffffd13d"
    else
        return nil
    end

    if RecommendationLacksResource(state, recommendation) then
        color = "ffff4040"
    end

    return "|c" .. color .. tostring(math.floor(value + 0.5)) ..
        suffix .. "|r"
end

function UI:UpdateResourceText(state, recommendation)
    if not D.DB.showResource then
        self.info:SetText("")
        self.info:Hide()
        return
    end

    local text = BuildResourceText(state, recommendation)
    if not text then
        self.info:SetText("")
        self.info:Hide()
        return
    end

    if D.testMode then
        text = "|cffffff33TEST|r  " .. text
    end
    self.info:SetText(text)
    self.info:Show()
end

local function CopyAction(target, source)
    target.key = source.key
    target.name = source.name
    target.reason = source.reason
    target.state = source.state
    target.eta = source.eta
    target.uncertain = source.uncertain
    target.texture = source.texture
    target.timelineCycle = source.timelineCycle
    target.timelineSlamCast = source.timelineSlamCast
    target.cost = source.cost
end

function UI:BuildTimelineActions(
    action,
    forecasts,
    showInSlot,
    castHeldAction,
    castHoldEta,
    suppressPendingAction
)
    self.timelineActions = self.timelineActions or {}
    local output = self.timelineActions
    local i = table.getn(output)
    while i >= 1 do
        output[i] = nil
        i = i - 1
    end

    local count = 0
    local pendingKey = nil
    if castHeldAction
        and castHeldAction.key
        and castHeldAction.key ~= "WAIT"
        and castHeldAction.key ~= "AUTO_ATTACK"
        and castHeldAction.state ~= "disabled"
        and (not action or castHeldAction.key ~= action.key) then
        -- The cast owns the ready slot until it finishes. Keep the live
        -- recommendation visible at the left edge of the timeline instead
        -- of letting it disappear while it waits for the slot.
        self.castHeldTimelineAction =
            self.castHeldTimelineAction or {}
        CopyAction(self.castHeldTimelineAction, castHeldAction)
        local heldEta = tonumber(castHeldAction.eta) or 0
        local slotWait = tonumber(castHoldEta) or 0
        if slotWait > heldEta then
            heldEta = slotWait
        end
        self.castHeldTimelineAction.eta = heldEta
        self.castHeldTimelineAction.timelinePending = true
        self.castHeldTimelineAction.timelineCastHeld = true
        count = 1
        output[count] = self.castHeldTimelineAction
        pendingKey = castHeldAction.key
    elseif not showInSlot
        and not suppressPendingAction
        and action
        and action.key
        and action.key ~= "WAIT"
        and action.key ~= "AUTO_ATTACK"
        and action.state ~= "disabled" then
        self.pendingTimelineAction =
            self.pendingTimelineAction or {}
        CopyAction(self.pendingTimelineAction, action)
        self.pendingTimelineAction.timelinePending = true
        count = 1
        output[count] = self.pendingTimelineAction
        pendingKey = action.key
    end

    forecasts = forecasts or {}
    local castForecastIndex = 1
    i = 1
    while i <= table.getn(forecasts)
        and count < TIMELINE_ACTION_LIMIT do
        local forecast = forecasts[i]
        if forecast
            and forecast.key
            and forecast.key ~= "WAIT"
            and forecast.key ~= pendingKey then
            local timelineForecast = forecast
            local slotWait = tonumber(castHoldEta) or 0
            if castHeldAction and slotWait > 0 then
                self.castQueuedForecasts =
                    self.castQueuedForecasts or {}
                local castForecast =
                    self.castQueuedForecasts[castForecastIndex]
                if not castForecast then
                    castForecast = {}
                    self.castQueuedForecasts[castForecastIndex] =
                        castForecast
                end
                castForecastIndex = castForecastIndex + 1
                CopyAction(castForecast, forecast)
                castForecast.eta = math.max(
                    tonumber(forecast.eta) or 0,
                    slotWait
                )
                castForecast.timelinePending = nil
                castForecast.timelineCastHeld = nil
                timelineForecast = castForecast
            end
            count = count + 1
            output[count] = timelineForecast
        end
        i = i + 1
    end
    return output
end

local function FindCastActionKey(state)
    local cast = state.cast or {}
    local castId = tonumber(cast.spellId)
    local castName = state.castName or cast.name
    local order = D.SpellOrder or {}
    local i = 1

    while i <= table.getn(order) do
        local key = order[i]
        local spell = D.Spells and D.Spells[key]
        local def = D.SpellDefs and D.SpellDefs[key]
        if castId
            and spell
            and tonumber(spell.spellId) == castId then
            return key
        end
        if castName and (
            (spell and spell.name == castName)
            or (def and def.name == castName)
        ) then
            return key
        end
        i = i + 1
    end
    return nil
end

function UI:GetCastLockedRecommendation(state, recommendation)
    local cast = state.cast or {}
    local casting = state.casting or cast.active
    if not casting then
        self.castLocked = false
        self.castLockToken = nil
        self.castLockKey = nil
        return recommendation
    end

    local castKey = FindCastActionKey(state)
    local castName = state.castName or cast.name
    local castId = tonumber(cast.spellId)
    local token = tostring(castKey or castId or castName or "active-cast")
    local startNewLock =
        not self.castLocked or self.castLockToken ~= token

    if startNewLock then
        local source = nil
        local sourceMatchesCast = false
        local now = tonumber(state.now) or GetTime()
        local previousRecent = self.previousSnapshot
            and self.previousSnapshot.key
            and self.previousSnapshotTime
            and (now - self.previousSnapshotTime) <= 0.75

        if castKey and recommendation.key == castKey then
            source = recommendation
            sourceMatchesCast = true
        elseif self.currentSnapshot
            and self.currentSnapshot.key
            and castKey
            and self.currentSnapshot.key == castKey then
            source = self.currentSnapshot
            sourceMatchesCast = true
        elseif castKey
            and previousRecent
            and self.previousSnapshot.key == castKey then
            source = self.previousSnapshot
            sourceMatchesCast = true
        elseif not castKey
            and self.currentSnapshot
            and self.currentSnapshot.key
            and self.currentSnapshot.key ~= "WAIT"
            and self.currentSnapshot.key ~= "AUTO_ATTACK" then
            source = self.currentSnapshot
        elseif not castKey and previousRecent then
            source = self.previousSnapshot
        elseif not castKey and self.currentSnapshot
            and self.currentSnapshot.key then
            source = self.currentSnapshot
        else
            source = recommendation
        end

        self.castLockAction = self.castLockAction or {}
        CopyAction(self.castLockAction, source)
        if castKey then
            if not sourceMatchesCast then
                self.castLockAction.reason = ""
            end
            self.castLockAction.key = castKey
            self.castLockAction.name = D:GetName(castKey)
            self.castLockAction.texture = D:GetTexture(castKey)
        elseif castName and castName ~= "" then
            self.castLockAction.name = castName
        end

        self.castLockReason = self.castLockAction.reason or ""
        self.castLockToken = token
        self.castLockKey = self.castLockAction.key
        self.castLocked = true
    end

    local remaining = tonumber(state.castRemaining)
        or tonumber(cast.remaining)
        or 0
    self.castLockAction.eta = remaining > 0.05 and remaining or nil
    self.castLockAction.state = "casting"
    self.castLockAction.uncertain = false
    if self.castLockReason ~= "" then
        self.castLockAction.reason = self.castLockReason .. " | " ..
            (zh and "读条完成后更新时间轴" or
                "Timeline unlocks when the cast finishes")
    else
        self.castLockAction.reason =
            zh and "读条完成后更新时间轴" or
                "Timeline unlocks when the cast finishes"
    end
    return self.castLockAction
end

function UI:Update(state, recommendation, forecasts, force)
    if not D.DB or not D.DB.enabled then
        root:Hide()
        resourceRoot:Hide()
        tankAssistBadge:Hide()
        return
    end

    state = state or {}
    if self.lastMode and self.lastMode ~= state.mode then
        self:ResetRuntimeState()
    end
    self.lastMode = state.mode
    self.targetRangeState = state.targetRangeState
    if self.targetRangeState == "grace"
        or self.targetRangeState == "out" then
        local rangeColor = self.targetRangeState == "grace"
            and COLOR.rangeGrace or COLOR.range
        self.rangeBadge:SetTextColor(
            rangeColor[1],
            rangeColor[2],
            rangeColor[3],
            1
        )
        self.rangeBadge:Show()
    else
        self.rangeBadge:Hide()
    end
    recommendation = recommendation or {
        key = "WAIT",
        name = D.Text.WAIT,
        reason = D.Text.WAIT_TARGET,
        state = "disabled",
    }
    local displayRecommendation =
        self:GetCastLockedRecommendation(state, recommendation)
    self:SyncResourceActions(state.resourceActions)

    if D.DB.showOnlyCombat
        and not state.inCombat
        and not D.testMode
        and D.DB.locked then
        CancelSlotPromotion(self)
        self.forecastPresence = {}
        root:Hide()
        tankAssistBadge:Hide()
        return
    end

    root:Show()
    self:UpdateTankAssistBadge()
    self:UpdateResourceText(state, recommendation)

    local noTarget = not state.targetValid and not D.testMode
    if noTarget then
        CancelSlotPromotion(self)
        self.forecastPresence = {}
        self.currentKey = nil
        self.currentState = "disabled"
        self.currentBlend = 1
        self.slotOccupied = false
        self.currentIcon:Hide()
        self.currentGhost:Hide()
        self:UpdateReleaseCue(recommendation, true)
        self.pendingText:SetText("")
        self.pendingText:Hide()
        self:SyncForecasts(nil, GetTime())
    else
        local previousKey = self.currentKey
        self:UpdateReleaseCue(displayRecommendation, false)
        local showInSlot = self.releaseReady
            or displayRecommendation.state == "casting"
            or displayRecommendation.state == "queued"
        local holdForPromotion, suppressPendingAction,
            promotionArrived = PrepareSlotPromotion(
                self,
                displayRecommendation,
                GetTime()
            )
        if holdForPromotion then
            showInSlot = false
        end

        if previousKey
            and previousKey ~= displayRecommendation.key
            and self.slotOccupied
            and self.currentSnapshot
            and self.currentSnapshot.key then
            self.previousSnapshot = self.previousSnapshot or {}
            CopyAction(self.previousSnapshot, self.currentSnapshot)
            self.previousSnapshotTime =
                tonumber(state.now) or GetTime()
            -- The completed slot occurrence disappears immediately. If the
            -- same skill is forecast again, its new cooldown cycle receives
            -- a separate timeline frame at the far-right edge.
            self.currentGhost:Hide()
            self.currentBlend = 1
        elseif not previousKey then
            self.currentGhost:Hide()
            self.currentBlend = 1
        end

        self.currentKey = displayRecommendation.key
        self.currentState = displayRecommendation.state
        self.pendingText:Hide()
        self.slotOccupied = showInSlot
        if showInSlot then
            if promotionArrived then
                self.currentBlend = 0
            end
            self:SetIcon(
                self.currentIcon,
                displayRecommendation,
                true,
                false
            )
            self.currentIcon:SetBackdropBorderColor(0, 0, 0, 0)
            self.currentIcon:Show()
        else
            self.currentIcon:Hide()
        end

        local timelineActions = self:BuildTimelineActions(
            displayRecommendation,
            forecasts,
            showInSlot,
            self.castLocked and recommendation or nil,
            self.castLocked and (
                tonumber(state.castRemaining)
                or tonumber((state.cast or {}).remaining)
                or 0
            ) or nil,
            suppressPendingAction
        )
        self:SyncForecasts(timelineActions, GetTime())

        self.currentSnapshot = self.currentSnapshot or {}
        CopyAction(self.currentSnapshot, displayRecommendation)
    end

    self:AnimateTimeline()
end

root:SetScript("OnUpdate", function()
    UI:AnimateTimeline()
end)
resourceRoot:SetScript("OnUpdate", function()
    UI:AnimateResourceStatus()
end)

if not D.DB then
    D:InitializeDB()
end
UI:ApplySettings()
root:Hide()
