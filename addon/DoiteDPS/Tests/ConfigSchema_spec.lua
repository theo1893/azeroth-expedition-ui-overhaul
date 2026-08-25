-- Standalone smoke checks for the data-driven configuration renderer.
-- Run from the AddOns directory with:
-- lua DoiteDPS/Tests/ConfigSchema_spec.lua

if not table.getn then
    table.getn = function(value) return #value end
end

function GetLocale() return "zhCN" end
function UnitClass() return "战士", "WARRIOR" end
function GetCursorPosition() return 0, 0 end

local Widget = {}
Widget.__index = Widget

local function NewWidget()
    return setmetatable({
        visible = true,
        checked = nil,
        enabled = true,
    }, Widget)
end

function Widget:CreateFontString() return NewWidget() end
function Widget:CreateTexture() return NewWidget() end
function Widget:SetScript(name, callback) self[name] = callback end
function Widget:Show() self.visible = true end
function Widget:Hide() self.visible = false end
function Widget:IsVisible() return self.visible end
function Widget:SetChecked(value) self.checked = value end
function Widget:GetChecked() return self.checked end
function Widget:Enable() self.enabled = true end
function Widget:Disable() self.enabled = false end
function Widget:GetEffectiveScale() return 1 end
function Widget:GetCenter() return 0, 0 end

setmetatable(Widget, {
    __index = function()
        return function() end
    end,
})

local function AddNoop(name)
    Widget[name] = function() end
end

local noops = {
    "SetWidth",
    "SetHeight",
    "SetPoint",
    "SetFrameStrata",
    "SetFrameLevel",
    "SetBackdrop",
    "SetBackdropColor",
    "EnableMouse",
    "SetMovable",
    "SetClampedToScreen",
    "RegisterForDrag",
    "RegisterForClicks",
    "SetHighlightTexture",
    "SetText",
    "SetTextColor",
    "SetJustifyH",
    "SetJustifyV",
    "SetTexture",
    "SetTexCoord",
    "ClearAllPoints",
}
local noopIndex = 1
while noopIndex <= table.getn(noops) do
    AddNoop(noops[noopIndex])
    noopIndex = noopIndex + 1
end
function Widget:SetText(value) self.text = value end
function Widget:GetText() return self.text end
function Widget:ClearFocus() self.focused = false end
function Widget:SetWidth(value) self.width = value end
function Widget:SetHeight(value) self.height = value end
function Widget:SetScale(value) self.scale = value end
function Widget:SetPoint(point, relativeTo, relativePoint, x, y)
    self.point = {
        point,
        relativeTo,
        relativePoint,
        x or 0,
        y or 0,
    }
end
function Widget:ClearAllPoints() self.point = nil end

UIParent = NewWidget()
Minimap = NewWidget()
GameTooltip = NewWidget()

function CreateFrame()
    return NewWidget()
end

local profileDB = {
    sharedOption = true,
    rotations = {},
    rotationNames = {},
    entryBindings = {
        single = "single",
        aoe = "aoe",
    },
}

DoiteDPS = {
    VERSION = "test",
    DEFAULTS = {
        showResource = true,
        showForecast = true,
        showOnlyCombat = false,
        locked = true,
        tankAssistEnabled = false,
        tankAssistName = "",
    },
    PROFILE_DEFAULTS = {
        TEST = {
            sharedOption = true,
        },
    },
    DB = {
        mode = "single",
        showResource = true,
        showForecast = true,
        showOnlyCombat = false,
        locked = true,
        tankAssistEnabled = false,
        tankAssistName = "",
        enabled = true,
        minimapAngle = -45,
        showMinimap = true,
    },
    UI = {
        ApplyLock = function() end,
    },
}

local D = DoiteDPS
local profile = {
    key = "TEST",
    EntryOrder = { "single", "aoe" },
    EntryPoints = {
        single = {
            label = "单体出口",
            modes = { "single", "battle" },
            default = "single",
        },
        aoe = {
            label = "AOE出口",
            modes = { "aoe" },
            default = "aoe",
        },
    },
    RotationDefaults = {
        single = {
            stance = 30,
            strategy = "normal",
            threshold = 30,
            rendStrategy = "high_hp",
            rendHealth = 70,
        },
        battle = {
            stance = 30,
            strategy = "safe",
            threshold = 50,
            rendStrategy = "high_hp",
            rendHealth = 70,
        },
        aoe = {
            stance = 30,
            strategy = "normal",
            threshold = 30,
            rendStrategy = "high_hp",
            rendHealth = 70,
        },
    },
}

profile.ConfigSchema = {
    title = "测试配置",
    modes = {
        { key = "single", label = "狂暴单体", note = "single" },
        { key = "battle", label = "战斗单体", note = "battle" },
        { key = "aoe", label = "狂暴群体", note = "aoe" },
    },
    options = {
        {
            type = "number",
            section = "循环",
            key = "stance",
            label = "独立配置",
            modes = { "single", "battle" },
            min = 0,
            max = 100,
            step = 5,
        },
        {
            type = "choice",
            key = "strategy",
            label = "策略",
            modes = { "single", "battle" },
            values = {
                { value = "normal", label = "常规" },
                { value = "safe", label = "稳健" },
            },
        },
        {
            type = "number",
            key = "threshold",
            label = "阈值",
            modes = { "single", "battle" },
            min = 0,
            max = 100,
            step = 5,
            visibleWhen = {
                key = "strategy",
                value = "safe",
            },
        },
        {
            type = "choice",
            key = "rendStrategy",
            label = "撕裂策略",
            modes = { "single", "battle" },
            values = {
                { value = "off", label = "关闭" },
                { value = "high_hp", label = "仅高血量" },
            },
        },
        {
            type = "number",
            key = "rendHealth",
            label = "撕裂最低目标血量",
            modes = { "single", "battle" },
            min = 20,
            max = 100,
            step = 10,
            visibleWhen = {
                key = "rendStrategy",
                value = "high_hp",
            },
        },
        {
            type = "toggle",
            scope = "profile",
            key = "sharedOption",
            label = "共享选项",
            modes = { "single", "battle" },
        },
    },
}

function profile:NormalizeMode(mode)
    if mode == "battle" then return "battle" end
    if mode == "aoe" then return "aoe" end
    return "single"
end

function profile:GetModeLabel(mode)
    mode = self:NormalizeMode(mode)
    local index = 1
    while index <= table.getn(self.ConfigSchema.modes) do
        if self.ConfigSchema.modes[index].key == mode then
            return self.ConfigSchema.modes[index].label
        end
        index = index + 1
    end
end

function profile:GetRotationDefaults(mode)
    return self.RotationDefaults[self:NormalizeMode(mode)]
end

function D:GetActiveProfile() return profile end
function D:NormalizeModeForProfile(activeProfile, mode)
    return activeProfile:NormalizeMode(mode)
end
function D:NormalizeEntryPoint(entry)
    if entry == "single" or entry == "aoe" then return entry end
end
function D:GetEntryOrder(activeProfile)
    return activeProfile.EntryOrder
end
function D:GetEntryModes(activeProfile, entry)
    return activeProfile.EntryPoints[entry].modes
end
function D:GetEntryBinding(_, entry)
    return profileDB.entryBindings[entry]
end
function D:SetEntryBinding(_, entry, mode)
    profileDB.entryBindings[entry] = mode
    return true, mode
end
function D:GetProfileDB() return profileDB end
function D:InitializeDB() end
function D:Update() end
function D:SetMode(mode)
    self.DB.mode = profile:NormalizeMode(mode)
end
function D:GetRotationName(activeProfile, mode)
    mode = activeProfile:NormalizeMode(mode)
    return profileDB.rotationNames[mode]
        or activeProfile:GetModeLabel(mode)
end
function D:SetRotationName(activeProfile, mode, name)
    mode = activeProfile:NormalizeMode(mode)
    profileDB.rotationNames[mode] = name
    return true, name
end
function D:ResetRotationName(activeProfile, mode)
    mode = activeProfile:NormalizeMode(mode)
    profileDB.rotationNames[mode] = nil
    return true
end
function D:Print() end
function D:ResetTankAssistRuntime() end
function D:GetTankAssistStatus()
    if not self.DB.tankAssistEnabled then
        return { state = "disabled", name = self.DB.tankAssistName or "" }
    end
    if not self.DB.tankAssistName or self.DB.tankAssistName == "" then
        return { state = "unassigned", name = "" }
    end
    return {
        state = "ready",
        name = self.DB.tankAssistName,
        targetName = "训练假人",
    }
end
function D:GetTankAssistStatusText(status)
    if status.state == "disabled" then return "坦克协助：关闭" end
    if status.state == "unassigned" then return "坦克：未指定" end
    return "坦克：" .. status.name .. " → " .. status.targetName
end
function D:SetTankAssistFromUnit()
    self.DB.tankAssistEnabled = true
    self.DB.tankAssistName = "主坦克"
    return true, self.DB.tankAssistName
end
function D:ClearTankAssist()
    self.DB.tankAssistName = ""
    return true
end
function D:GetTankAssistAssignmentError() return "指定失败" end

local function Fill(target, defaults)
    local key, value
    for key, value in pairs(defaults) do
        if target[key] == nil then target[key] = value end
    end
end

function D:GetRotationDB(_, mode, defaults)
    profileDB.rotations[mode] = profileDB.rotations[mode] or {}
    Fill(profileDB.rotations[mode], defaults)
    return profileDB.rotations[mode]
end

function D:ResetRotationDB(_, mode, defaults)
    profileDB.rotations[mode] = {}
    return self:GetRotationDB("TEST", mode, defaults)
end

function profile:GetRotationDB(mode)
    mode = self:NormalizeMode(mode)
    return D:GetRotationDB(self.key, mode, self.RotationDefaults[mode])
end

dofile("DoiteDPS/Config.lua")
local C = D.Config
local passed = 0

local function Expect(name, result)
    assert(result, name)
    passed = passed + 1
end

Expect(
    "renderer selects the profile's current mode",
    C.editMode == "single"
        and C.profileTitle.text == "设置"
)

Expect(
    "Cat-style panel uses the wider two-column frame",
    C.panel.width == 520 and C.panel.scale == 0.90
)

Expect(
    "macro outputs share one aligned row",
    C.entryPool[1].point[5] == C.entryPool[2].point[5]
        and C.entryPool[1].point[4] < C.entryPool[2].point[4]
)

local fixedSharedX = C.togglePool[1].point[4]
local fixedSharedY = C.togglePool[1].point[5]
Expect(
    "a leading standalone option cannot split a skill setting group",
    fixedSharedX == C.choicePool[1].point[4]
        and fixedSharedY < C.choicePool[1].point[5]
        and C.numberPool[1].point[5] > C.choicePool[1].point[5]
)

Expect(
    "a second conditional skill keeps both settings on one row",
    C.numberPool[2].point[5] == C.choicePool[2].point[5]
        and C.numberPool[2].point[4] > C.choicePool[2].point[4]
        and fixedSharedY < C.choicePool[2].point[5]
)

C:SelectMode("battle")
Expect(
    "revealing a dependent option does not move later skill settings",
    C.numberPool[2].visible == true
        and C.numberPool[2].point[5] == C.choicePool[1].point[5]
        and C.numberPool[2].point[4] > C.choicePool[1].point[4]
        and C.togglePool[1].point[4] == fixedSharedX
        and C.togglePool[1].point[5] == fixedSharedY
)
C:SelectMode("single")

Expect(
    "rotation tabs expose a selected visual state",
    C.tabPool[1].selected == true
        and C.tabPool[2].selected == false
        and C.tabPool[3].selected == false
)

Expect(
    "all profiles separate single and group rotations into labeled rows",
    C.rotationTitle.label.text == "循环管理"
        and C.modeGroupPool[1].text == "单体循环"
        and C.modeGroupPool[2].text == "群体循环"
        and C.tabPool[1].point[5] == C.tabPool[2].point[5]
        and C.tabPool[3].point[5] < C.tabPool[1].point[5]
        and C.tabPool[3].point[4] == C.tabPool[1].point[4]
)

Expect(
    "general display controls use the same two-column rhythm",
    C.togglePool[2].point[5] == C.togglePool[3].point[5]
        and C.togglePool[2].point[4] < C.togglePool[3].point[4]
        and C.togglePool[4].point[5] < C.togglePool[2].point[5]
)

Expect(
    "tank assist controls occupy a dedicated full-width row",
    C.tankAssistTitle.visible == true
        and C.tankAssistRow.visible == true
        and C.tankAssistStatus.text == "坦克协助：关闭"
        and C.clearTankButton.enabled == false
)

C:SetTankFromTarget()
Expect(
    "assigning the current group target enables and displays tank assist",
    D.DB.tankAssistEnabled == true
        and D.DB.tankAssistName == "主坦克"
        and C.tankAssistStatus.text == "坦克：主坦克 → 训练假人"
        and C.clearTankButton.enabled == true
)

C:ClearTank()
Expect(
    "clearing the tank preserves the feature toggle but removes the binding",
    D.DB.tankAssistEnabled == true
        and D.DB.tankAssistName == ""
        and C.tankAssistStatus.text == "坦克：未指定"
        and C.clearTankButton.enabled == false
)

Expect(
    "active rotation summary card remains visible",
    C.modeCard.visible == true
        and C.presetStatus.text == "推荐配置"
        and C.presetStatus.visible == true
        and C.resetButton.visible == false
)

Expect(
    "option rows stay transparent until hovered",
    C.togglePool[1].rowBackground.visible == false
        and C.choicePool[1].rowBackground.visible == false
)

Expect(
    "cycle controls expose hover instructions",
    type(C.entryPool[1].button.OnEnter) == "function"
        and type(C.choicePool[1].button.OnEnter) == "function"
)

C:CycleEntryBinding(C.entryPool[1], 1)
Expect(
    "single output selector binds to Battle single",
    profileDB.entryBindings.single == "battle"
        and C.editMode == "battle"
        and D.DB.mode == "battle"
)

C:CycleEntryBinding(C.entryPool[1], -1)
Expect(
    "single output selector can return to Berserker single",
    profileDB.entryBindings.single == "single"
        and C.editMode == "single"
        and D.DB.mode == "single"
)

C:SelectMode("battle")
Expect(
    "mode tabs preserve the explicit Battle single mode",
    C.editMode == "battle" and D.DB.mode == "battle"
)

C.rotationNameEdit:SetText("练级循环")
C:SaveRotationName()
Expect(
    "configuration page saves a custom rotation name",
    profileDB.rotationNames.battle == "练级循环"
        and C.rotationNameEdit:GetText() == "练级循环"
)

C:ResetRotationName()
Expect(
    "configuration page restores the default rotation name",
    profileDB.rotationNames.battle == nil
        and C.rotationNameEdit:GetText() == "战斗单体"
)

local strategyOption = profile.ConfigSchema.options[2]
C:ApplyOption(profile, "battle", strategyOption, "normal")
Expect(
    "rotation option writes to the selected mode only",
    profile:GetRotationDB("battle").strategy == "normal"
        and profile:GetRotationDB("single").strategy == "normal"
)
Expect(
    "custom rotation replaces the status with an inline reset action",
    C.presetStatus.visible == false
        and C.resetButton.visible == true
        and C.resetButton.point[2] == C.modeCard
)

local sharedOption = profile.ConfigSchema.options[6]
C:ApplyOption(profile, "battle", sharedOption, false)
Expect(
    "profile-scoped option is stored outside the rotation",
    profileDB.sharedOption == false
)

C:ResetEditingMode()
Expect(
    "reset restores rotation and profile defaults",
    profile:GetRotationDB("battle").strategy == "safe"
        and profileDB.sharedOption == true
        and C.presetStatus.visible == true
        and C.resetButton.visible == false
)

local originalModes = profile.ConfigSchema.modes
local originalModeGroups = profile.ConfigSchema.modeGroups
profile.ConfigSchema.modes = {}
local wideIndex = 1
while wideIndex <= 8 do
    profile.ConfigSchema.modes[wideIndex] = {
        key = wideIndex == 1 and "single" or ("mode" .. wideIndex),
        label = "循环" .. wideIndex,
        note = "wide",
    }
    wideIndex = wideIndex + 1
end
profile.ConfigSchema.modeGroups = {
    {
        key = "single",
        modes = { "single", "mode2", "mode3", "mode4" },
    },
    {
        key = "aoe",
        modes = { "mode5", "mode6", "mode7", "mode8" },
    },
}
C:Refresh()
Expect(
    "four single and four group rotations stay in separate aligned rows",
    C.tabPool[1].point[5] == C.tabPool[4].point[5]
        and C.tabPool[5].point[5] < C.tabPool[1].point[5]
        and C.tabPool[5].point[4] == C.tabPool[1].point[4]
        and C.tabPool[8].point[5] == C.tabPool[5].point[5]
        and C.modeGroupPool[1].text == "单体循环"
        and C.modeGroupPool[2].text == "群体循环"
)
profile.ConfigSchema.modes = originalModes
profile.ConfigSchema.modeGroups = originalModeGroups

print("ConfigSchema_spec: " .. passed .. " checks passed")
