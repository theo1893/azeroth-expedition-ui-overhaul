-- Standalone presentation checks for the QTE timeline.
-- Run from the AddOns directory with:
-- lua DoiteDPS/Tests/UITransition_spec.lua

if not table.getn then
    table.getn = function(value) return #value end
end

local now = 100
function GetTime() return now end
function GetLocale() return "zhCN" end

local Frame = {}

local function NewFrame(name)
    return setmetatable({
        name = name,
        visible = true,
        alpha = 1,
        frameLevel = 1,
        scripts = {},
    }, Frame)
end

function Frame:Show() self.visible = true end
function Frame:Hide() self.visible = false end
function Frame:IsVisible() return self.visible end
function Frame:SetAlpha(value) self.alpha = value end
function Frame:SetText(value) self.text = value end
function Frame:GetName() return self.name end
function Frame:GetFrameLevel() return self.frameLevel or 1 end
function Frame:SetFrameLevel(value) self.frameLevel = value end
function Frame:SetScript(name, callback) self.scripts[name] = callback end
function Frame:CreateTexture() return NewFrame() end
function Frame:CreateFontString() return NewFrame() end
function Frame:GetPoint()
    return "CENTER", UIParent, "CENTER", 0, 0
end

local noOpMethods = {
    "SetWidth",
    "SetHeight",
    "SetBackdrop",
    "SetBackdropColor",
    "SetBackdropBorderColor",
    "SetPoint",
    "SetTexCoord",
    "EnableMouse",
    "SetMovable",
    "SetClampedToScreen",
    "SetFrameStrata",
    "SetAllPoints",
    "SetTexture",
    "SetTextColor",
    "SetJustifyH",
    "RegisterForDrag",
    "ClearAllPoints",
    "SetScale",
    "StartMoving",
    "StopMovingOrSizing",
    "SetVertexColor",
    "SetSequence",
    "SetSequenceTime",
}
local noOpIndex = 1
while noOpIndex <= table.getn(noOpMethods) do
    Frame[noOpMethods[noOpIndex]] = function() end
    noOpIndex = noOpIndex + 1
end
function Frame:SetBackdropBorderColor(r, g, b, a)
    self.borderColor = { r, g, b, a }
end
function Frame:SetTextColor(r, g, b, a)
    self.textColor = { r, g, b, a }
end
Frame.__index = Frame

UIParent = NewFrame("UIParent")
GameTooltip = NewFrame("GameTooltip")
function CreateFrame(_, name)
    return NewFrame(name)
end

DoiteDPS = {
    FORECAST_LIMIT = 3,
    DB = {
        enabled = true,
        showForecast = true,
        showResource = false,
        showOnlyCombat = false,
        locked = true,
        tankAssistEnabled = false,
        tankAssistName = "",
        point = "CENTER",
        relativePoint = "CENTER",
        x = 0,
        y = -125,
        scale = 1,
    },
    Text = {
        UNLOCKED = "unlocked",
        WAIT = "wait",
        WAIT_TARGET = "wait target",
    },
    SpellDefs = {},
    Spells = {},
    Names = {},
}

local D = DoiteDPS
function D:GetName(key) return self.Names[key] or key end
function D:GetTexture(key) return key end
function D:InitializeDB() end
local tankAssistStatus = { state = "disabled", name = "" }
function D:GetTankAssistStatus() return tankAssistStatus end
function D:GetTankAssistStatusText(status)
    return status.state .. ":" .. tostring(status.name or "")
end

dofile("DoiteDPS/UI.lua")
local UI = D.UI
local passed = 0

local function ExpectLua50Upvalues(name, callback)
    local upvalues = 0
    local environmentUpvalues = 0
    while debug and debug.getupvalue do
        local upvalueName = debug.getupvalue(callback, upvalues + 1)
        if not upvalueName then break end
        upvalues = upvalues + 1
        if upvalueName == "_ENV" then
            environmentUpvalues = environmentUpvalues + 1
        end
    end
    assert(
        (upvalues - environmentUpvalues) <= 32,
        name .. " exceeds the Lua 5.0 upvalue limit"
    )
    passed = passed + 1
end

ExpectLua50Upvalues("UI.Update", UI.Update)
ExpectLua50Upvalues("UI.SyncForecasts", UI.SyncForecasts)
ExpectLua50Upvalues("UI.AnimateTimeline", UI.AnimateTimeline)

local function State()
    return {
        targetValid = true,
        inCombat = true,
        mode = "single",
        resourceType = "rage",
        rage = 70,
        now = now,
        casting = false,
        cast = {},
    }
end

local function Action(key, state, eta)
    return {
        key = key,
        name = key,
        reason = key,
        state = state,
        eta = eta,
        texture = key,
    }
end

local function FindTimelineFrame(key)
    local i = 1
    while i <= table.getn(UI.forecastIcons) do
        local frame = UI.forecastIcons[i]
        if frame.timelineKey == key then return frame end
        i = i + 1
    end
    return nil
end

local function RenderFor(duration)
    local finish = now + duration
    while now < finish do
        now = math.min(finish, now + 0.01)
        UI:AnimateTimeline()
    end
end

local function Update(action, forecasts)
    local state = State()
    state.now = now
    UI:Update(state, action, forecasts or {}, true)
end

local function UpdateAtSwing(cycle, action, forecasts)
    local state = State()
    state.now = now
    state.swing = { active = true, cycle = cycle }
    UI:Update(state, action, forecasts or {}, true)
end

UI:ResetRuntimeState()
tankAssistStatus = {
    state = "ready",
    name = "MainTank",
    targetName = "Enemy",
}
D.DB.tankAssistEnabled = true
D.DB.tankAssistName = "MainTank"
Update(Action("BLOODTHIRST", "ready"))
assert(
    not UI.tankAssistBadge:IsVisible(),
    "an assigned tank should not add a shield badge to the timeline"
)
tankAssistStatus = { state = "no_target", name = "MainTank" }
Update(Action("BLOODTHIRST", "ready"))
assert(
    not UI.tankAssistBadge:IsVisible(),
    "a tank without a target should not add a shield badge to the timeline"
)
tankAssistStatus = { state = "disabled", name = "MainTank" }
D.DB.tankAssistEnabled = false
Update(Action("BLOODTHIRST", "ready"))
assert(
    not UI.tankAssistBadge:IsVisible(),
    "the tank badge should disappear while soft assist is disabled"
)
passed = passed + 3

UI:ResetRuntimeState()
local noTargetState = State()
noTargetState.targetValid = false
UI:Update(
    noTargetState,
    {
        key = "WAIT",
        name = D.Text.WAIT,
        reason = D.Text.WAIT_TARGET,
        state = "disabled",
    },
    {},
    true
)
assert(
    not UI.pendingText:IsVisible() and UI.pendingText.text == "",
    "the no-target state should leave the timeline visually empty"
)
passed = passed + 1

local rangeAction = {
    key = "WAIT",
    name = D.Text.WAIT,
    reason = "range",
    state = "range",
}
local graceRangeState = State()
graceRangeState.targetRangeState = "grace"
UI:Update(graceRangeState, rangeAction, {}, true)
UI:AnimateTimeline()
assert(
    UI.rangeBadge:IsVisible()
        and UI.targetRangeState == "grace"
        and UI.readySlot.borderColor
        and UI.readySlot.borderColor[2] == 0.62,
    "brief melee loss must use the amber range badge and slot border"
)
local outRangeState = State()
outRangeState.targetRangeState = "out"
UI:Update(outRangeState, rangeAction, {}, true)
UI:AnimateTimeline()
assert(
    UI.rangeBadge:IsVisible()
        and UI.targetRangeState == "out"
        and UI.readySlot.borderColor
        and UI.readySlot.borderColor[2] == 0.25,
    "persistent melee loss must use the red range badge and slot border"
)
local meleeRangeState = State()
meleeRangeState.targetRangeState = "melee"
UI:Update(meleeRangeState, Action("BLOODTHIRST", "ready"), {}, true)
assert(
    not UI.rangeBadge:IsVisible(),
    "the range badge must clear as soon as the target returns to melee"
)
passed = passed + 3

local function UpdateCastingSlam()
    local state = State()
    state.casting = true
    state.castName = "SLAM"
    state.castRemaining = 1.92
    state.cast = {
        active = true,
        name = "SLAM",
        spellId = 1464,
        remaining = 1.92,
    }
    UI:Update(
        state,
        Action("SLAM", "casting", 1.92),
        {},
        true
    )
end

local function DrivePromotion(updateCallback)
    local steps = 0
    while not UI.currentIcon:IsVisible() and steps < 12 do
        RenderFor(0.05)
        updateCallback()
        steps = steps + 1
    end
    return steps
end

-- A volatile forecast must survive more than one reactive refresh before an
-- icon is created. A single Slam candidate is ignored instead of flashing.
UI:ResetRuntimeState()
Update(
    Action("BLOODTHIRST", "ready"),
    { Action("SLAM", "forecast", 2.0) }
)
assert(
    FindTimelineFrame("SLAM") == nil,
    "a one-refresh Slam forecast must not create a timeline frame"
)
RenderFor(0.05)
Update(Action("BLOODTHIRST", "ready"))
assert(
    FindTimelineFrame("SLAM") == nil,
    "a rejected one-refresh Slam forecast must remain invisible"
)
passed = passed + 2

-- A continuously valid Slam appears after confirmation. Once visible, one
-- missing refresh is absorbed and a quick return reuses the same frame.
now = now + 1
UI:ResetRuntimeState()
Update(
    Action("BLOODTHIRST", "ready"),
    { Action("SLAM", "forecast", 2.0) }
)
RenderFor(0.06)
Update(
    Action("BLOODTHIRST", "ready"),
    { Action("SLAM", "forecast", 1.94) }
)
assert(
    FindTimelineFrame("SLAM") == nil,
    "Slam should remain hidden before the confirmation interval"
)
RenderFor(0.07)
Update(
    Action("BLOODTHIRST", "ready"),
    { Action("SLAM", "forecast", 1.87) }
)
local stableSlam = FindTimelineFrame("SLAM")
assert(
    stableSlam and stableSlam.timelineActive,
    "a continuously valid Slam forecast should appear after confirmation"
)
RenderFor(0.05)
Update(Action("BLOODTHIRST", "ready"))
assert(
    FindTimelineFrame("SLAM") == stableSlam
        and stableSlam.timelineActive,
    "one missing Slam refresh should keep the existing frame visible"
)
RenderFor(0.05)
Update(
    Action("BLOODTHIRST", "ready"),
    { Action("SLAM", "forecast", 1.77) }
)
assert(
    FindTimelineFrame("SLAM") == stableSlam
        and stableSlam.timelineActive
        and not stableSlam.timelineNew,
    "a Slam returning during grace should reuse its frame without restarting"
)
RenderFor(0.21)
Update(Action("BLOODTHIRST", "ready"))
assert(
    stableSlam.timelineLeaving
        and not stableSlam.timelinePromoted,
    "a genuinely expired Slam forecast should leave after the grace interval"
)
passed = passed + 5

-- A dump that was already forecast must keep the same physical timeline note
-- and travel through the lead before the ready slot takes over.
UI:ResetRuntimeState()
Update(
    Action("BLOODTHIRST", "ready"),
    { Action("HEROIC_STRIKE", "forecast", 0.25) }
)
RenderFor(0.06)
Update(
    Action("BLOODTHIRST", "ready"),
    { Action("HEROIC_STRIKE", "forecast", 0.19) }
)
RenderFor(0.07)
Update(
    Action("BLOODTHIRST", "ready"),
    { Action("HEROIC_STRIKE", "forecast", 0.12) }
)
local heroicFrame = FindTimelineFrame("HEROIC_STRIKE")
assert(
    heroicFrame and heroicFrame.timelineActive,
    "forecast Heroic Strike should own a live timeline frame"
)
RenderFor(0.06)

Update(Action("HEROIC_STRIKE", "queue"))
assert(
    not UI.currentIcon:IsVisible()
        and heroicFrame.timelineLeaving
        and heroicFrame.timelinePromoted,
    "forecast Heroic Strike must start travelling before entering the slot"
        .. " visible=" .. tostring(UI.currentIcon:IsVisible())
        .. " active=" .. tostring(heroicFrame.timelineActive)
        .. " leaving=" .. tostring(heroicFrame.timelineLeaving)
        .. " promoted=" .. tostring(heroicFrame.timelinePromoted)
        .. " phase=" .. tostring(UI.slotPromotionPhase)
)
local heroicStartX = heroicFrame.timelineDisplayX
RenderFor(0.08)
assert(
    heroicFrame.timelineDisplayX < heroicStartX,
    "promoted Heroic Strike should move left toward the ready slot"
)
Update(Action("HEROIC_STRIKE", "queue"))
assert(
    not UI.currentIcon:IsVisible(),
    "the ready slot should remain empty during promotion travel"
)
RenderFor(0.07)
Update(Action("HEROIC_STRIKE", "queue"))
assert(
    UI.currentIcon:IsVisible()
        and UI.currentIcon.actionKey == "HEROIC_STRIKE"
        and UI.currentBlend < 1
        and heroicFrame.timelinePromoted,
    "the ready slot should fade in only after Heroic Strike reaches it"
)
passed = passed + 4

-- Volatile fillers/dumps must receive the same short timeline lead even when
-- a prior forecast could not include them.
local volatileActions = {
    { key = "SLAM", state = "ready" },
    { key = "HEROIC_STRIKE", state = "queue" },
    { key = "CLEAVE", state = "queue" },
}
local volatileIndex = 1
while volatileIndex <= table.getn(volatileActions) do
    local entry = volatileActions[volatileIndex]
    now = now + 1
    UI:ResetRuntimeState()
    Update(Action("AUTO_ATTACK", "wait"))
    Update(Action(entry.key, entry.state))
    local frame = FindTimelineFrame(entry.key)
    assert(
        not UI.currentIcon:IsVisible()
            and frame
            and frame.timelineActive
            and not frame.timelinePromoted,
        entry.key .. " should stage on the timeline instead of appearing directly"
    )
    passed = passed + 1
    volatileIndex = volatileIndex + 1
end

-- A one-tick Slam window may fade from the rail, but must never flash in the
-- ready slot. This is presentation-only; the executable profile is unchanged.
now = now + 1
UI:ResetRuntimeState()
Update(Action("AUTO_ATTACK", "wait"))
Update(Action("SLAM", "ready"))
RenderFor(0.02)
Update(Action("AUTO_ATTACK", "wait"))
local cancelledSlam = FindTimelineFrame("SLAM")
assert(
    not UI.currentIcon:IsVisible()
        and (not cancelledSlam or not cancelledSlam.timelinePromoted),
    "a transient Slam recommendation must not complete promotion"
)
passed = passed + 1

-- A next-swing queue confirmation is authoritative, but visual ownership
-- remains on the moving note until that same note reaches the slot.
now = now + 1
UI:ResetRuntimeState()
Update(Action("AUTO_ATTACK", "wait"))
Update(Action("CLEAVE", "queue"))
RenderFor(0.02)
Update(Action("CLEAVE", "queued"))
local queuedCleave = FindTimelineFrame("CLEAVE")
assert(
    not UI.currentIcon:IsVisible()
        and queuedCleave
        and queuedCleave.timelineActive,
    "queued Cleave must remain on its staged note before travel"
)
RenderFor(0.04)
Update(Action("CLEAVE", "queued"))
assert(
    not UI.currentIcon:IsVisible()
        and queuedCleave.timelineLeaving
        and queuedCleave.timelinePromoted,
    "queued Cleave must travel instead of popping into the slot"
)
DrivePromotion(function()
    Update(Action("CLEAVE", "queued"))
end)
assert(
    UI.currentIcon:IsVisible()
        and UI.currentIcon.actionKey == "CLEAVE"
        and queuedCleave.timelineDisplayX <= 47,
    "queued Cleave slot ownership must wait for physical arrival"
)
passed = passed + 3

-- Slam can begin casting while its cosmetic lead is still in progress. Keep
-- the casting state on the moving occurrence until it physically arrives.
now = now + 1
UI:ResetRuntimeState()
Update(Action("AUTO_ATTACK", "wait"))
Update(Action("SLAM", "ready"))
RenderFor(0.02)
UpdateCastingSlam()
local castingSlam = FindTimelineFrame("SLAM")
assert(
    not UI.currentIcon:IsVisible()
        and castingSlam
        and castingSlam.timelineActive,
    "casting Slam must retain its staged timeline occurrence"
)
RenderFor(0.04)
UpdateCastingSlam()
assert(
    not UI.currentIcon:IsVisible()
        and castingSlam.timelinePromoted,
    "casting Slam must begin travelling before slot takeover"
)
DrivePromotion(UpdateCastingSlam)
assert(
    UI.currentIcon:IsVisible()
        and UI.currentIcon.actionKey == "SLAM"
        and castingSlam.timelineDisplayX <= 47,
    "casting Slam slot ownership must wait for physical arrival"
)
passed = passed + 3

-- Reproduce the real one-button race: the previous UI refresh contains only
-- a stable forecast, then Execute casts Slam before any SLAM-ready refresh.
D.SpellOrder = { "SLAM" }
D.Spells.SLAM = { name = "SLAM", spellId = 1464 }
now = now + 1
UI:ResetRuntimeState()
Update(
    Action("BLOODTHIRST", "ready"),
    { Action("SLAM", "forecast", 1.50) }
)
RenderFor(0.13)
Update(
    Action("BLOODTHIRST", "ready"),
    { Action("SLAM", "forecast", 1.37) }
)
RenderFor(0.03)
local directCastSlam = FindTimelineFrame("SLAM")
UpdateCastingSlam()
assert(
    directCastSlam
        and FindTimelineFrame("SLAM") == directCastSlam
        and directCastSlam.timelinePromoted
        and not UI.currentIcon:IsVisible(),
    "forecast-to-casting Slam must reuse the forecast frame"
)
DrivePromotion(UpdateCastingSlam)
assert(
    UI.currentIcon:IsVisible()
        and UI.currentIcon.actionKey == "SLAM"
        and directCastSlam.timelineDisplayX <= 47,
    "direct-cast Slam must reach the slot before takeover"
)
passed = passed + 2

-- The same skipped presentation state occurs when a macro directly latches
-- an on-swing dump between UI refreshes.
now = now + 1
UI:ResetRuntimeState()
Update(
    Action("BLOODTHIRST", "ready"),
    { Action("HEROIC_STRIKE", "forecast", 1.50) }
)
RenderFor(0.13)
Update(
    Action("BLOODTHIRST", "ready"),
    { Action("HEROIC_STRIKE", "forecast", 1.37) }
)
RenderFor(0.03)
local directQueuedHeroic = FindTimelineFrame("HEROIC_STRIKE")
Update(Action("HEROIC_STRIKE", "queued"))
assert(
    directQueuedHeroic
        and FindTimelineFrame("HEROIC_STRIKE") ==
            directQueuedHeroic
        and directQueuedHeroic.timelinePromoted
        and not UI.currentIcon:IsVisible(),
    "forecast-to-queued Heroic Strike must reuse the forecast frame"
)
DrivePromotion(function()
    Update(Action("HEROIC_STRIKE", "queued"))
end)
assert(
    UI.currentIcon:IsVisible()
        and UI.currentIcon.actionKey == "HEROIC_STRIKE"
        and directQueuedHeroic.timelineDisplayX <= 47,
    "direct-queued Heroic Strike must reach the slot before takeover"
)
passed = passed + 2

-- Swing-scoped predictions expire at the white-hit boundary. A fresh action
-- may be predicted in the next cycle, but the old physical note cannot cross.
local swingScopedKeys = { "HEROIC_STRIKE", "CLEAVE", "EXECUTE" }
local swingScopedIndex = 1
while swingScopedIndex <= table.getn(swingScopedKeys) do
    local key = swingScopedKeys[swingScopedIndex]
    now = now + 1
    UI:ResetRuntimeState()
    UpdateAtSwing(
        1,
        Action("BLOODTHIRST", "ready"),
        { Action(key, "forecast", 0.20) }
    )
    RenderFor(0.13)
    UpdateAtSwing(
        1,
        Action("BLOODTHIRST", "ready"),
        { Action(key, "forecast", 0.07) }
    )
    assert(
        FindTimelineFrame(key),
        key .. " should exist in its originating swing"
    )

    UpdateAtSwing(2, Action("BLOODTHIRST", "ready"))
    assert(
        FindTimelineFrame(key) == nil,
        key .. " must expire instead of crossing into the next swing"
    )
    passed = passed + 1
    swingScopedIndex = swingScopedIndex + 1
end

print("UITransition_spec: " .. passed .. " checks passed")
