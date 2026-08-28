-- ============================================================================
-- DoiteDPS - data-driven, class-aware configuration panel
-- Profiles describe modes and options; this file only renders the schema.
-- Turtle WoW / Vanilla 1.12 / Lua 5.0
-- ============================================================================

local D = DoiteDPS
local C = {}
D.Config = C

-- Profile 的 ConfigSchema 合同：
--   modes[] = { key, label, note }；modeGroups[] 只负责标签页分组。
--   options[] 使用 type/key/modes、控件元数据和可选的 scope。
--   scope 为 "general" 时写 D.DB，为 "profile" 时写 Profile DB；
--   省略 scope 时写当前模式的 Rotation DB。visibleWhen 只控制界面显隐。
local locale = (GetLocale and GetLocale()) or "enUS"
local zh = locale == "zhCN" or locale == "zhTW"

local PANEL_WIDTH = 520
local ROW_HEIGHT = 25
local SECTION_HEIGHT = 22
local CONTENT_LEFT = 20
local CONTENT_WIDTH = PANEL_WIDTH - 40
local COLUMN_GAP = 14
local COLUMN_WIDTH = math.floor((CONTENT_WIDTH - COLUMN_GAP) / 2)
local MODE_CARD_HEIGHT = 34
local MODE_GROUP_LABEL_WIDTH = 70
local MODE_GROUP_GAP = 8
local MODE_TAB_GAP = 5
local MODE_ROW_HEIGHT = 27

local COLOR = {
    panel = { 0.04, 0.05, 0.09, 1.00 },
    panelBorder = { 0.42, 0.43, 0.50, 1.00 },
    rowHover = { 0.17, 0.18, 0.25, 0.62 },
    card = { 0.09, 0.10, 0.16, 0.82 },
    gold = { 1.00, 0.80, 0.00, 1.00 },
    text = { 0.94, 0.94, 0.96, 1.00 },
    muted = { 0.66, 0.70, 0.78, 1.00 },
    green = { 0.42, 0.90, 0.55, 1.00 },
    orange = { 1.00, 0.58, 0.22, 1.00 },
}

local function GetClassAccent()
    local _, class = UnitClass("player")
    if class == "WARRIOR" then
        return 0.78, 0.61, 0.43
    elseif class == "SHAMAN" then
        return 0.00, 0.44, 0.87
    end
    return 0.44, 0.70, 0.86
end

local function CreateSectionHeader(parent, text)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetWidth(CONTENT_WIDTH)
    frame:SetHeight(SECTION_HEIGHT)

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", frame, "LEFT", 0, 1)
    label:SetWidth(138)
    label:SetJustifyH("LEFT")
    label:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    label:SetTextColor(
        COLOR.gold[1],
        COLOR.gold[2],
        COLOR.gold[3],
        COLOR.gold[4]
    )
    label:SetText(text or "")
    frame.label = label

    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    line:SetTexCoord(0.81, 0.94, 0.5, 1)
    line:SetVertexColor(0.42, 0.42, 0.48, 0.72)
    line:SetHeight(2)
    line:SetPoint("LEFT", frame, "LEFT", 140, 0)
    line:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    frame.line = line

    frame.SetText = function(self, value)
        self.label:SetText(value or "")
    end
    return frame
end

local function AddRowBackground(frame)
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    bg:SetAllPoints(frame)
    bg:SetVertexColor(1, 1, 1, 1)
    bg:Hide()
    frame.rowBackground = bg

    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function()
        this.rowBackground:Show()
        this.rowBackground:SetVertexColor(
            COLOR.rowHover[1],
            COLOR.rowHover[2],
            COLOR.rowHover[3],
            COLOR.rowHover[4]
        )
    end)
    frame:SetScript("OnLeave", function()
        this.rowBackground:Hide()
    end)
end

local function ShowCycleHint(owner)
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetText(
        zh and "切换选项" or "Change selection",
        1,
        0.82,
        0
    )
    GameTooltip:AddLine(
        zh and "左键：下一项" or "Left click: next",
        0.85,
        0.85,
        0.85
    )
    GameTooltip:AddLine(
        zh and "右键：上一项" or "Right click: previous",
        0.85,
        0.85,
        0.85
    )
    GameTooltip:Show()
end

local GENERAL_OPTIONS = {
    {
        type = "toggle",
        scope = "general",
        key = "showResource",
        label = zh and "显示当前怒气/魔法" or "Show current resource",
    },
    {
        type = "toggle",
        scope = "general",
        key = "showForecast",
        label = zh and "显示后续技能时间轴" or "Show forecast timeline",
    },
    {
        type = "toggle",
        scope = "general",
        key = "showOnlyCombat",
        label = zh and "仅在战斗中显示" or "Show only in combat",
    },
    {
        type = "toggle",
        scope = "general",
        key = "locked",
        label = zh and "锁定主界面位置" or "Lock main frame",
    },
    {
        type = "toggle",
        scope = "general",
        key = "tankAssistEnabled",
        label = zh and "启用软跟随坦克" or "Enable soft tank assist",
    },
}

local panel = CreateFrame("Frame", "DoiteDPSConfigPanel", UIParent)
C.panel = panel
panel:SetWidth(PANEL_WIDTH)
panel:SetHeight(240)
panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
panel:SetFrameStrata("DIALOG")
panel:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
panel:SetBackdropColor(
    COLOR.panel[1],
    COLOR.panel[2],
    COLOR.panel[3],
    COLOR.panel[4]
)
panel:SetBackdropBorderColor(
    COLOR.panelBorder[1],
    COLOR.panelBorder[2],
    COLOR.panelBorder[3],
    COLOR.panelBorder[4]
)
panel:SetScale(0.90)
panel:EnableMouse(true)
panel:SetMovable(true)
if panel.SetClampedToScreen then
    panel:SetClampedToScreen(true)
end
panel:RegisterForDrag("LeftButton")
panel:SetScript("OnDragStart", function() this:StartMoving() end)
panel:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
panel:Hide()

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -12)
title:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
title:SetText("|cff6FA8DCDoiteDPS|r")

local version = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
version:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -42, -13)
version:SetTextColor(0.55, 0.62, 0.72, 1)
version:SetText("v" .. D.VERSION)

local closeButton = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -2, -2)

local profileTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
profileTitle:SetPoint("TOP", panel, "TOP", 0, -11)
profileTitle:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
C.profileTitle = profileTitle

local headerDivider = panel:CreateTexture(nil, "ARTWORK")
headerDivider:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
headerDivider:SetTexCoord(0.81, 0.94, 0.5, 1)
headerDivider:SetVertexColor(0.48, 0.48, 0.54, 0.85)
headerDivider:SetWidth(PANEL_WIDTH - 12)
headerDivider:SetHeight(3)
headerDivider:SetPoint("TOP", panel, "TOP", 0, -34)

local entryTitle = CreateSectionHeader(
    panel,
    zh and "宏出口" or "Macro outputs"
)
C.entryTitle = entryTitle

local rotationTitle = CreateSectionHeader(
    panel,
    zh and "循环管理" or "Rotation management"
)
C.rotationTitle = rotationTitle

local modeCard = CreateFrame("Frame", "DoiteDPSConfigModeCard", panel)
modeCard:SetWidth(CONTENT_WIDTH)
modeCard:SetHeight(MODE_CARD_HEIGHT)
modeCard:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true,
    tileSize = 16,
    edgeSize = 0,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
})
modeCard:SetBackdropColor(
    COLOR.card[1],
    COLOR.card[2],
    COLOR.card[3],
    COLOR.card[4]
)
C.modeCard = modeCard

local modeAccent = modeCard:CreateTexture(nil, "ARTWORK")
modeAccent:SetWidth(3)
modeAccent:SetPoint("TOPLEFT", modeCard, "TOPLEFT", 0, 0)
modeAccent:SetPoint("BOTTOMLEFT", modeCard, "BOTTOMLEFT", 0, 0)
C.modeAccent = modeAccent

local presetStatus = modeCard:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalSmall"
)
presetStatus:SetPoint("RIGHT", modeCard, "RIGHT", -10, 0)
presetStatus:SetWidth(66)
presetStatus:SetJustifyH("RIGHT")
presetStatus:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
C.presetStatus = presetStatus

local modeNote = modeCard:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalSmall"
)
modeNote:SetPoint("LEFT", modeCard, "LEFT", 12, 0)
modeNote:SetWidth(CONTENT_WIDTH - 100)
modeNote:SetHeight(MODE_CARD_HEIGHT - 8)
modeNote:SetJustifyH("LEFT")
modeNote:SetJustifyV("MIDDLE")
modeNote:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
modeNote:SetTextColor(
    COLOR.muted[1],
    COLOR.muted[2],
    COLOR.muted[3],
    COLOR.muted[4]
)
C.modeNote = modeNote

local rotationNameLabel = panel:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalSmall"
)
rotationNameLabel:SetWidth(76)
rotationNameLabel:SetJustifyH("LEFT")
rotationNameLabel:SetText(zh and "循环名称" or "Rotation name")
rotationNameLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
rotationNameLabel:SetTextColor(
    COLOR.text[1],
    COLOR.text[2],
    COLOR.text[3],
    COLOR.text[4]
)
C.rotationNameLabel = rotationNameLabel

local rotationNameEdit = CreateFrame(
    "EditBox",
    "DoiteDPSConfigRotationNameEdit",
    panel,
    "InputBoxTemplate"
)
rotationNameEdit:SetWidth(230)
rotationNameEdit:SetHeight(20)
rotationNameEdit:SetFont("Fonts\\FRIZQT__.TTF", 11)
rotationNameEdit:SetAutoFocus(false)
rotationNameEdit:SetMaxLetters(48)
rotationNameEdit:SetScript("OnEnterPressed", function()
    C:SaveRotationName()
end)
rotationNameEdit:SetScript("OnEscapePressed", function()
    this:ClearFocus()
    C:Refresh()
end)
C.rotationNameEdit = rotationNameEdit

local saveNameButton = CreateFrame(
    "Button",
    "DoiteDPSConfigSaveRotationName",
    panel,
    "UIPanelButtonTemplate"
)
saveNameButton:SetWidth(54)
saveNameButton:SetHeight(21)
saveNameButton:SetFont("Fonts\\FRIZQT__.TTF", 11)
saveNameButton:SetText(zh and "保存" or "Save")
saveNameButton:SetScript("OnClick", function()
    C:SaveRotationName()
end)
C.saveNameButton = saveNameButton

local resetNameButton = CreateFrame(
    "Button",
    "DoiteDPSConfigResetRotationName",
    panel,
    "UIPanelButtonTemplate"
)
resetNameButton:SetWidth(67)
resetNameButton:SetHeight(21)
resetNameButton:SetFont("Fonts\\FRIZQT__.TTF", 11)
resetNameButton:SetText(zh and "默认名称" or "Default")
resetNameButton:SetScript("OnClick", function()
    C:ResetRotationName()
end)
C.resetNameButton = resetNameButton

local generalTitle = CreateSectionHeader(
    panel,
    zh and "通用设置" or "General settings"
)
C.generalTitle = generalTitle

local tankAssistTitle = CreateSectionHeader(
    panel,
    zh and "协助坦克" or "Tank assist"
)
C.tankAssistTitle = tankAssistTitle

local tankAssistRow = CreateFrame(
    "Frame",
    "DoiteDPSConfigTankAssistRow",
    panel
)
tankAssistRow:SetWidth(CONTENT_WIDTH)
tankAssistRow:SetHeight(ROW_HEIGHT)
AddRowBackground(tankAssistRow)
C.tankAssistRow = tankAssistRow

local tankAssistStatus = tankAssistRow:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalSmall"
)
tankAssistStatus:SetPoint("LEFT", tankAssistRow, "LEFT", 8, 0)
tankAssistStatus:SetWidth(300)
tankAssistStatus:SetJustifyH("LEFT")
tankAssistStatus:SetTextColor(
    COLOR.muted[1],
    COLOR.muted[2],
    COLOR.muted[3],
    COLOR.muted[4]
)
C.tankAssistStatus = tankAssistStatus

local clearTankButton = CreateFrame(
    "Button",
    "DoiteDPSConfigClearTank",
    tankAssistRow,
    "UIPanelButtonTemplate"
)
clearTankButton:SetWidth(54)
clearTankButton:SetHeight(21)
clearTankButton:SetPoint("RIGHT", tankAssistRow, "RIGHT", -6, 0)
clearTankButton:SetFont("Fonts\\FRIZQT__.TTF", 11)
clearTankButton:SetText(zh and "清除" or "Clear")
clearTankButton:SetScript("OnClick", function()
    C:ClearTank()
end)
C.clearTankButton = clearTankButton

local assignTankButton = CreateFrame(
    "Button",
    "DoiteDPSConfigAssignTank",
    tankAssistRow,
    "UIPanelButtonTemplate"
)
assignTankButton:SetWidth(102)
assignTankButton:SetHeight(21)
assignTankButton:SetPoint(
    "RIGHT",
    clearTankButton,
    "LEFT",
    -6,
    0
)
assignTankButton:SetFont("Fonts\\FRIZQT__.TTF", 11)
assignTankButton:SetText(zh and "指定当前目标" or "Assign target")
assignTankButton:SetScript("OnClick", function()
    C:SetTankFromTarget()
end)
C.assignTankButton = assignTankButton

local resetButton = CreateFrame(
    "Button",
    "DoiteDPSConfigResetMode",
    panel,
    "UIPanelButtonTemplate"
)
resetButton:SetWidth(100)
resetButton:SetHeight(22)
resetButton:SetFont("Fonts\\FRIZQT__.TTF", 11)
resetButton:SetText(zh and "恢复推荐" or "Reset")
resetButton:SetScript("OnClick", function()
    C:ResetEditingMode()
end)
resetButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:SetText(
        zh and "恢复当前循环" or "Reset current rotation",
        1,
        0.82,
        0
    )
    GameTooltip:AddLine(
        zh and "仅恢复当前循环参数，不修改宏出口和循环名称。"
            or "Resets only this rotation's options; macro outputs and its name stay unchanged.",
        0.85,
        0.85,
        0.85,
        1
    )
    GameTooltip:Show()
end)
resetButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
C.resetButton = resetButton

-- 职业、模式或条件选项变化时，Refresh 会重建可见控件；这里复用控件对象，
-- 池内对象不持有任何配置值。
C.tabPool = {}
C.entryPool = {}
C.modeGroupPool = {}
C.sectionPool = {}
C.togglePool = {}
C.choicePool = {}
C.numberPool = {}

local function ModeMatches(option, mode)
    if not option or type(option.modes) ~= "table" then
        return true
    end
    local index = 1
    while index <= table.getn(option.modes) do
        if option.modes[index] == mode then
            return true
        end
        index = index + 1
    end
    return false
end

local function BuildConditionalLayoutParents(schema, mode)
    local parents = {}
    local options = schema and schema.options or {}
    local index = 1
    while index <= table.getn(options) do
        local option = options[index]
        local condition = option and option.visibleWhen or nil
        if ModeMatches(option, mode)
            and type(condition) == "table"
            and condition.key then
            parents[tostring(condition.key)] = true
        end
        index = index + 1
    end
    return parents
end

local function GetOptionLayoutGroup(option, conditionalParents)
    if not option then return nil end
    if option.layoutGroup then
        return "layout:" .. tostring(option.layoutGroup)
    end

    local condition = option.visibleWhen
    if type(condition) == "table" and condition.key then
        return "conditional:" .. tostring(condition.key)
    end
    if option.key
        and conditionalParents[tostring(option.key)] then
        return "conditional:" .. tostring(option.key)
    end
    return nil
end

local function Clamp(value, low, high)
    value = tonumber(value) or low
    if value < low then return low end
    if value > high then return high end
    return value
end

local function ValuesEqual(a, b)
    if type(a) == "number" or type(b) == "number" then
        return math.abs((tonumber(a) or 0) - (tonumber(b) or 0)) < 0.001
    end
    return a == b
end

function C:GetProfile()
    return D:GetActiveProfile()
end

function C:GetSchema(profile)
    return profile and profile.ConfigSchema or nil
end

function C:GetModeDefinition(schema, mode)
    local definition = self:FindModeDefinition(schema, mode)
    if definition then return definition end
    return schema and schema.modes and schema.modes[1] or nil
end

function C:FindModeDefinition(schema, mode)
    if not schema or type(schema.modes) ~= "table" then
        return nil
    end
    local index = 1
    while index <= table.getn(schema.modes) do
        if schema.modes[index].key == mode then
            return schema.modes[index]
        end
        index = index + 1
    end
    return nil
end

function C:GetModeGroups(profile, schema)
    if schema and type(schema.modeGroups) == "table"
        and table.getn(schema.modeGroups) > 0 then
        return schema.modeGroups
    end

    local groups = {
        {
            key = "single",
            modes = D:GetEntryModes(profile, "single"),
        },
        {
            key = "aoe",
            modes = D:GetEntryModes(profile, "aoe"),
        },
    }
    local assigned = {}
    local groupIndex = 1
    while groupIndex <= table.getn(groups) do
        local modes = groups[groupIndex].modes or {}
        local modeIndex = 1
        while modeIndex <= table.getn(modes) do
            assigned[modes[modeIndex]] = true
            modeIndex = modeIndex + 1
        end
        groupIndex = groupIndex + 1
    end

    local otherModes = {}
    local modeIndex = 1
    while modeIndex <= table.getn(schema and schema.modes or {}) do
        local mode = schema.modes[modeIndex].key
        if not assigned[mode] then
            otherModes[table.getn(otherModes) + 1] = mode
        end
        modeIndex = modeIndex + 1
    end
    if table.getn(otherModes) > 0 then
        groups[table.getn(groups) + 1] = {
            key = "other",
            modes = otherModes,
        }
    end
    return groups
end

function C:GetModeGroupLabel(group)
    if group and group.label then return group.label end
    local key = group and group.key or "other"
    if key == "single" then
        return zh and "单体循环" or "Single rotations"
    elseif key == "aoe" then
        return zh and "群体循环" or "Group rotations"
    end
    return zh and "其他循环" or "Other rotations"
end

function C:ReadOption(profile, mode, option)
    if not option then return nil end
    if option.scope == "general" then
        return D.DB and D.DB[option.key]
    elseif option.scope == "profile" then
        return D:GetProfileDB(profile.key)[option.key]
    end

    if profile and profile.GetRotationDB then
        return profile:GetRotationDB(mode)[option.key]
    end
    return nil
end

function C:WriteOption(profile, mode, option, value)
    if option.scope == "general" then
        D.DB[option.key] = value
    elseif option.scope == "profile" then
        D:GetProfileDB(profile.key)[option.key] = value
    elseif profile and profile.GetRotationDB then
        profile:GetRotationDB(mode)[option.key] = value
    end
end

function C:GetOptionDefault(profile, mode, option)
    if option.scope == "general" then
        return D.DEFAULTS and D.DEFAULTS[option.key]
    elseif option.scope == "profile" then
        local defaults = D.PROFILE_DEFAULTS
            and D.PROFILE_DEFAULTS[profile.key]
        return defaults and defaults[option.key]
    elseif profile and profile.GetRotationDefaults then
        local defaults = profile:GetRotationDefaults(mode)
        return defaults and defaults[option.key]
    end
    return nil
end

function C:OptionVisible(profile, mode, option)
    if not ModeMatches(option, mode) then
        return false
    end
    local condition = option.visibleWhen
    if not condition then
        return true
    end
    local value = self:ReadOption(profile, mode, {
        key = condition.key,
        scope = condition.scope or option.scope,
    })
    if condition.value ~= nil then
        return value == condition.value
    elseif condition.notValue ~= nil then
        return value ~= condition.notValue
    end
    return value == true or value == 1
end

function C:IsModeDefault(profile, schema, mode)
    if not profile or not schema then return true end
    local index = 1
    while index <= table.getn(schema.options or {}) do
        local option = schema.options[index]
        if ModeMatches(option, mode) then
            local current = self:ReadOption(profile, mode, option)
            local default = self:GetOptionDefault(profile, mode, option)
            if default ~= nil and not ValuesEqual(current, default) then
                return false
            end
        end
        index = index + 1
    end
    return true
end

local function HidePool(pool)
    local index = 1
    while index <= table.getn(pool) do
        pool[index]:Hide()
        index = index + 1
    end
end

local function CreateTab(index)
    local button = CreateFrame(
        "Button",
        "DoiteDPSConfigModeTab" .. tostring(index),
        panel
    )
    button:SetHeight(23)
    button:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })

    local label = button:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalSmall"
    )
    label:SetPoint("CENTER", button, "CENTER", 0, 0)
    label:SetWidth(118)
    label:SetJustifyH("CENTER")
    label:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    button.label = label
    button.SetText = function(self, value)
        self.label:SetText(value or "")
    end

    button:SetScript("OnClick", function()
        C:SelectMode(this.modeKey)
    end)
    button:SetScript("OnEnter", function()
        if this.selected then return end
        local r, g, b = GetClassAccent()
        this:SetBackdropBorderColor(r, g, b, 0.72)
        this:SetBackdropColor(0.14, 0.15, 0.22, 0.92)
    end)
    button:SetScript("OnLeave", function()
        if this.selected then return end
        this:SetBackdropBorderColor(0.34, 0.35, 0.42, 0.82)
        this:SetBackdropColor(0.08, 0.09, 0.14, 0.78)
    end)
    C.tabPool[index] = button
    return button
end

local function CreateModeGroupLabel(index)
    local label = panel:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalSmall"
    )
    label:SetWidth(MODE_GROUP_LABEL_WIDTH)
    label:SetHeight(23)
    label:SetJustifyH("LEFT")
    label:SetJustifyV("MIDDLE")
    label:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    label:SetTextColor(
        COLOR.gold[1],
        COLOR.gold[2],
        COLOR.gold[3],
        COLOR.gold[4]
    )
    C.modeGroupPool[index] = label
    return label
end

local function StyleModeTab(button, selected)
    local r, g, b = GetClassAccent()
    button.selected = selected and true or false
    if selected then
        button:SetBackdropColor(0.16, 0.14, 0.10, 0.94)
        button:SetBackdropBorderColor(r, g, b, 1.00)
        button.label:SetTextColor(
            COLOR.gold[1],
            COLOR.gold[2],
            COLOR.gold[3],
            COLOR.gold[4]
        )
    else
        button:SetBackdropColor(0.08, 0.09, 0.14, 0.78)
        button:SetBackdropBorderColor(0.34, 0.35, 0.42, 0.82)
        button.label:SetTextColor(
            COLOR.muted[1],
            COLOR.muted[2],
            COLOR.muted[3],
            COLOR.muted[4]
        )
    end
end

local function CreateSection(index)
    local frame = CreateSectionHeader(panel, "")
    C.sectionPool[index] = frame
    return frame
end

local function CreateToggle(index)
    local frame = CreateFrame(
        "Frame",
        "DoiteDPSConfigToggleRow" .. tostring(index),
        panel
    )
    frame:SetWidth(COLUMN_WIDTH)
    frame:SetHeight(ROW_HEIGHT)
    AddRowBackground(frame)

    local check = CreateFrame(
        "CheckButton",
        "DoiteDPSConfigToggle" .. tostring(index),
        frame,
        "UICheckButtonTemplate"
    )
    check:SetWidth(21)
    check:SetHeight(21)
    check:SetPoint("LEFT", frame, "LEFT", 3, 0)
    check:SetScale(0.90)
    check.owner = frame
    check:SetScript("OnClick", function()
        local owner = this.owner
        C:ApplyOption(
            owner.profile,
            owner.mode,
            owner.option,
            this:GetChecked() and true or false
        )
    end)
    frame.check = check

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", frame, "LEFT", 31, 0)
    label:SetWidth(COLUMN_WIDTH - 36)
    label:SetJustifyH("LEFT")
    label:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    label:SetTextColor(
        COLOR.text[1],
        COLOR.text[2],
        COLOR.text[3],
        COLOR.text[4]
    )
    frame.label = label
    frame:SetScript("OnMouseUp", function()
        local owner = this
        if not owner.option then return end
        local checked = owner.check:GetChecked() and true or false
        C:ApplyOption(
            owner.profile,
            owner.mode,
            owner.option,
            not checked
        )
    end)

    C.togglePool[index] = frame
    return frame
end

local function CreateChoice(index)
    local frame = CreateFrame(
        "Frame",
        "DoiteDPSConfigChoiceRow" .. tostring(index),
        panel
    )
    frame:SetWidth(COLUMN_WIDTH)
    frame:SetHeight(ROW_HEIGHT)
    AddRowBackground(frame)

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", frame, "LEFT", 8, 0)
    label:SetWidth(COLUMN_WIDTH - 126)
    label:SetJustifyH("LEFT")
    label:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    label:SetTextColor(
        COLOR.text[1],
        COLOR.text[2],
        COLOR.text[3],
        COLOR.text[4]
    )
    frame.label = label

    local button = CreateFrame(
        "Button",
        "DoiteDPSConfigChoice" .. tostring(index),
        frame,
        "UIPanelButtonTemplate"
    )
    button:SetWidth(112)
    button:SetHeight(21)
    button:SetPoint("RIGHT", frame, "RIGHT", -4, 0)
    button:SetFont("Fonts\\FRIZQT__.TTF", 11)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button.owner = frame
    button:SetScript("OnClick", function()
        C:CycleChoice(this.owner, arg1 == "RightButton" and -1 or 1)
    end)
    button:SetScript("OnEnter", function()
        ShowCycleHint(this)
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    frame.button = button

    C.choicePool[index] = frame
    return frame
end

local function CreateEntryControl(index)
    local frame = CreateFrame(
        "Frame",
        "DoiteDPSConfigEntryRow" .. tostring(index),
        panel
    )
    frame:SetWidth(COLUMN_WIDTH)
    frame:SetHeight(ROW_HEIGHT)
    AddRowBackground(frame)

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", frame, "LEFT", 8, 0)
    label:SetWidth(76)
    label:SetJustifyH("LEFT")
    label:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    label:SetTextColor(
        COLOR.muted[1],
        COLOR.muted[2],
        COLOR.muted[3],
        COLOR.muted[4]
    )
    frame.label = label

    local button = CreateFrame(
        "Button",
        "DoiteDPSConfigEntryChoice" .. tostring(index),
        frame,
        "UIPanelButtonTemplate"
    )
    button:SetWidth(COLUMN_WIDTH - 90)
    button:SetHeight(21)
    button:SetPoint("RIGHT", frame, "RIGHT", -4, 0)
    button:SetFont("Fonts\\FRIZQT__.TTF", 11)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button.owner = frame
    button:SetScript("OnClick", function()
        C:CycleEntryBinding(
            this.owner,
            arg1 == "RightButton" and -1 or 1
        )
    end)
    button:SetScript("OnEnter", function()
        ShowCycleHint(this)
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    frame.button = button

    C.entryPool[index] = frame
    return frame
end

local function CreateNumber(index)
    local frame = CreateFrame(
        "Frame",
        "DoiteDPSConfigNumberRow" .. tostring(index),
        panel
    )
    frame:SetWidth(COLUMN_WIDTH)
    frame:SetHeight(ROW_HEIGHT)
    AddRowBackground(frame)

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", frame, "LEFT", 8, 0)
    label:SetWidth(COLUMN_WIDTH - 106)
    label:SetJustifyH("LEFT")
    label:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    label:SetTextColor(
        COLOR.text[1],
        COLOR.text[2],
        COLOR.text[3],
        COLOR.text[4]
    )
    frame.label = label

    local minus = CreateFrame(
        "Button",
        "DoiteDPSConfigNumberMinus" .. tostring(index),
        frame,
        "UIPanelButtonTemplate"
    )
    minus:SetWidth(22)
    minus:SetHeight(21)
    minus:SetPoint("RIGHT", frame, "RIGHT", -80, 0)
    minus:SetText("-")
    minus.owner = frame
    minus:SetScript("OnClick", function()
        C:AdjustNumber(this.owner, -1)
    end)
    frame.minus = minus

    local value = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    value:SetPoint("LEFT", minus, "RIGHT", 4, 0)
    value:SetWidth(48)
    value:SetJustifyH("CENTER")
    value:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    value:SetTextColor(1.00, 0.82, 0.25, 1)
    frame.value = value

    local plus = CreateFrame(
        "Button",
        "DoiteDPSConfigNumberPlus" .. tostring(index),
        frame,
        "UIPanelButtonTemplate"
    )
    plus:SetWidth(22)
    plus:SetHeight(21)
    plus:SetPoint("LEFT", value, "RIGHT", 4, 0)
    plus:SetText("+")
    plus.owner = frame
    plus:SetScript("OnClick", function()
        C:AdjustNumber(this.owner, 1)
    end)
    frame.plus = plus

    C.numberPool[index] = frame
    return frame
end

function C:AcquireTab(index)
    return self.tabPool[index] or CreateTab(index)
end

function C:AcquireEntryControl(index)
    return self.entryPool[index] or CreateEntryControl(index)
end

function C:AcquireModeGroupLabel(index)
    return self.modeGroupPool[index] or CreateModeGroupLabel(index)
end

function C:AcquireSection(index)
    return self.sectionPool[index] or CreateSection(index)
end

function C:AcquireControl(optionType, index)
    if optionType == "choice" then
        return self.choicePool[index] or CreateChoice(index)
    elseif optionType == "number" then
        return self.numberPool[index] or CreateNumber(index)
    end
    return self.togglePool[index] or CreateToggle(index)
end

function C:ApplyOption(profile, mode, option, value)
    if not profile and option.scope ~= "general" then return end
    self:WriteOption(profile, mode, option, value)

    if option.scope == "general" and option.key == "locked" then
        if not value then
            D.DB.enabled = true
        end
        if D.UI and D.UI.ApplyLock then
            D.UI:ApplyLock()
        end
    end

    D:Update(true)
    self:Refresh()
end

function C:UpdateTankAssistStatus()
    local status = D:GetTankAssistStatus()
    self.tankAssistStatus:SetText(D:GetTankAssistStatusText(status))
    if status.name and status.name ~= "" then
        self.clearTankButton:Enable()
    else
        self.clearTankButton:Disable()
    end
end

function C:SetTankFromTarget()
    local ok, nameOrReason = D:SetTankAssistFromUnit("target")
    if ok then
        D:Print((zh and "已指定协助坦克：" or
            "Assist tank assigned: ") .. nameOrReason)
    else
        D:Print(D:GetTankAssistAssignmentError(nameOrReason))
    end
    D:Update(true)
    self:Refresh()
end

function C:ClearTank()
    D:ClearTankAssist()
    D:Print(zh and "已清除协助坦克。" or "Assist tank cleared.")
    D:Update(true)
    self:Refresh()
end

function C:CycleChoice(control, direction)
    local option = control.option
    local values = option and option.values or {}
    local count = table.getn(values)
    if count <= 0 then return end

    local current = self:ReadOption(control.profile, control.mode, option)
    local currentIndex = 1
    local index = 1
    while index <= count do
        if values[index].value == current then
            currentIndex = index
            break
        end
        index = index + 1
    end

    currentIndex = currentIndex + (direction or 1)
    if currentIndex > count then currentIndex = 1 end
    if currentIndex < 1 then currentIndex = count end
    self:ApplyOption(
        control.profile,
        control.mode,
        option,
        values[currentIndex].value
    )
end

function C:CycleEntryBinding(control, direction)
    local profile = control and control.profile
    local entry = control and control.entry
    if not profile or not entry then return end

    local modes = D:GetEntryModes(profile, entry)
    local count = table.getn(modes)
    if count <= 0 then return end

    local current = D:GetEntryBinding(profile, entry)
    local currentIndex = 1
    local index = 1
    while index <= count do
        if modes[index] == current then
            currentIndex = index
            break
        end
        index = index + 1
    end

    currentIndex = currentIndex + (direction or 1)
    if currentIndex > count then currentIndex = 1 end
    if currentIndex < 1 then currentIndex = count end

    local saved, mode = D:SetEntryBinding(
        profile,
        entry,
        modes[currentIndex]
    )
    if not saved then
        D:Print(mode)
        return
    end

    self.editMode = mode
    self.profileKey = profile.key
    D:SetMode(mode, true)
    self:Refresh()
end

function C:BindEntryControl(control, profile, entry)
    local modes = D:GetEntryModes(profile, entry)
    local mode = D:GetEntryBinding(profile, entry)
    local entryDefinition = profile.EntryPoints
        and profile.EntryPoints[entry]
    local label = entryDefinition and entryDefinition.label
    if not label then
        if entry == "single" then
            label = zh and "单体宏" or "Single macro"
        elseif entry == "aoe" then
            label = zh and "AOE宏" or "AoE macro"
        else
            label = tostring(entry)
        end
    end
    control.profile = profile
    control.entry = entry
    control.label:SetText(label)
    control.button:SetText(D:GetRotationName(profile, mode))
    if table.getn(modes) > 1 then
        control.button:Enable()
    else
        control.button:Disable()
    end
end

function C:AdjustNumber(control, direction)
    local option = control.option
    local current = tonumber(
        self:ReadOption(control.profile, control.mode, option)
    ) or tonumber(self:GetOptionDefault(
        control.profile,
        control.mode,
        option
    )) or 0
    local step = tonumber(option.step) or 1
    local value = Clamp(
        current + (step * (direction or 1)),
        tonumber(option.min) or current,
        tonumber(option.max) or current
    )
    self:ApplyOption(control.profile, control.mode, option, value)
end

function C:SelectMode(mode)
    local profile = self:GetProfile()
    if not profile then return end
    mode = D:NormalizeModeForProfile(profile, mode)
    self.editMode = mode
    self.profileKey = profile.key
    D:SetMode(mode, true)
    self:Refresh()
end

function C:SaveRotationName()
    local profile = self:GetProfile()
    if not profile then return end
    local mode = D:NormalizeModeForProfile(
        profile,
        self.editMode or D.DB.mode
    )
    local name = self.rotationNameEdit:GetText()
    local saved, result = D:SetRotationName(profile, mode, name)
    self.rotationNameEdit:ClearFocus()
    if not saved then
        D:Print(result)
        self.rotationNameEdit:SetText(D:GetRotationName(profile, mode))
        return
    end

    D:Update(true)
    D:Print(
        (zh and "循环名称：" or "Rotation name: ")
            .. tostring(result)
    )
    self:Refresh()
end

function C:ResetRotationName()
    local profile = self:GetProfile()
    if not profile then return end
    local mode = D:NormalizeModeForProfile(
        profile,
        self.editMode or D.DB.mode
    )
    D:ResetRotationName(profile, mode)
    self.rotationNameEdit:ClearFocus()
    D:Update(true)
    self:Refresh()
end

function C:ResetEditingMode()
    local profile = self:GetProfile()
    local schema = self:GetSchema(profile)
    if not profile or not schema then return end
    local mode = D:NormalizeModeForProfile(
        profile,
        self.editMode or D.DB.mode
    )

    if profile.ResetRotationDB then
        profile:ResetRotationDB(mode)
    elseif profile.GetRotationDefaults then
        D:ResetRotationDB(
            profile.key,
            mode,
            profile:GetRotationDefaults(mode)
        )
    end

    local index = 1
    while index <= table.getn(schema.options or {}) do
        local option = schema.options[index]
        if ModeMatches(option, mode) and option.scope == "profile" then
            local default = self:GetOptionDefault(profile, mode, option)
            if default ~= nil then
                D:GetProfileDB(profile.key)[option.key] = default
            end
        end
        index = index + 1
    end

    D:Update(true)
    self:Refresh()
end

function C:BindControl(control, profile, mode, option)
    control.profile = profile
    control.mode = mode
    control.option = option
    control.label:SetText(option.label or option.key)

    local current = self:ReadOption(profile, mode, option)
    if option.type == "choice" then
        local label = tostring(current or "")
        local index = 1
        while index <= table.getn(option.values or {}) do
            if option.values[index].value == current then
                label = option.values[index].label
                break
            end
            index = index + 1
        end
        control.button:SetText(label)
    elseif option.type == "number" then
        local format = option.format or "%.0f"
        local value = tonumber(current) or 0
        control.value:SetText(
            string.format(format, value) .. (option.suffix or "")
        )
        if value > (tonumber(option.min) or value) then
            control.minus:Enable()
        else
            control.minus:Disable()
        end
        if value < (tonumber(option.max) or value) then
            control.plus:Enable()
        else
            control.plus:Disable()
        end
    else
        local checked = current == true or current == 1
        control.check:SetChecked(checked and 1 or 0)
    end
end

function C:Refresh()
    if not D.DB then D:InitializeDB() end

    HidePool(self.tabPool)
    HidePool(self.entryPool)
    HidePool(self.modeGroupPool)
    HidePool(self.sectionPool)
    HidePool(self.togglePool)
    HidePool(self.choicePool)
    HidePool(self.numberPool)

    local profile = self:GetProfile()
    local schema = self:GetSchema(profile)
    local accentR, accentG, accentB = GetClassAccent()
    local nextY = -45
    local usedToggleCount = 0

    self.profileTitle:SetTextColor(accentR, accentG, accentB, 1)
    self.profileTitle:SetText(zh and "设置" or "Settings")
    self.modeAccent:SetTexture(accentR, accentG, accentB, 1)

    if not schema then
        self.presetStatus:SetText("")
        self.presetStatus:Hide()
        self.entryTitle:Hide()
        self.rotationTitle:Hide()
        self.modeCard:ClearAllPoints()
        self.modeCard:SetPoint(
            "TOPLEFT",
            panel,
            "TOPLEFT",
            CONTENT_LEFT,
            nextY
        )
        self.modeCard:Show()
        self.modeNote:SetText(
            zh and "当前职业暂无专用循环设置。"
                or "No rotation settings are available for this class."
        )
        self.modeNote:Show()
        nextY = nextY - MODE_CARD_HEIGHT - 8
        self.rotationNameLabel:Hide()
        self.rotationNameEdit:Hide()
        self.saveNameButton:Hide()
        self.resetNameButton:Hide()
        self.resetButton:Hide()
    else
        if self.profileKey ~= profile.key then
            self.profileKey = profile.key
            self.editMode = nil
        end
        local mode = D:NormalizeModeForProfile(
            profile,
            self.editMode or D.DB.mode
        )
        self.editMode = mode

        self.entryTitle:ClearAllPoints()
        self.entryTitle:SetPoint(
            "TOPLEFT",
            panel,
            "TOPLEFT",
            CONTENT_LEFT,
            nextY
        )
        self.entryTitle:Show()
        nextY = nextY - SECTION_HEIGHT

        local entries = D:GetEntryOrder(profile)
        local entryIndex = 1
        local entryColumn = 0
        while entryIndex <= table.getn(entries) do
            local entry = D:NormalizeEntryPoint(entries[entryIndex])
            if entry then
                local entryControl = self:AcquireEntryControl(entryIndex)
                entryControl:ClearAllPoints()
                entryControl:SetPoint(
                    "TOPLEFT",
                    panel,
                    "TOPLEFT",
                    CONTENT_LEFT
                        + (entryColumn * (COLUMN_WIDTH + COLUMN_GAP)),
                    nextY
                )
                self:BindEntryControl(entryControl, profile, entry)
                entryControl:Show()
                entryColumn = entryColumn + 1
                if entryColumn >= 2 then
                    nextY = nextY - ROW_HEIGHT
                    entryColumn = 0
                end
            end
            entryIndex = entryIndex + 1
        end
        if entryColumn > 0 then
            nextY = nextY - ROW_HEIGHT
        end
        nextY = nextY - 4

        self.rotationTitle:ClearAllPoints()
        self.rotationTitle:SetPoint(
            "TOPLEFT",
            panel,
            "TOPLEFT",
            CONTENT_LEFT,
            nextY
        )
        self.rotationTitle:Show()
        nextY = nextY - SECTION_HEIGHT

        local modeGroups = self:GetModeGroups(profile, schema)
        local tabAreaLeft = CONTENT_LEFT
            + MODE_GROUP_LABEL_WIDTH + MODE_GROUP_GAP
        local tabAreaWidth = CONTENT_WIDTH
            - MODE_GROUP_LABEL_WIDTH - MODE_GROUP_GAP
        local tabIndex = 0
        local groupIndex = 1
        while groupIndex <= table.getn(modeGroups) do
            local group = modeGroups[groupIndex]
            local groupModes = group.modes or {}
            local groupModeCount = table.getn(groupModes)
            local tabColumns = math.min(groupModeCount, 4)
            if tabColumns < 1 then tabColumns = 1 end
            local tabRows = math.ceil(groupModeCount / tabColumns)
            if tabRows < 1 then tabRows = 1 end
            local tabWidth = math.floor(
                (tabAreaWidth
                    - ((tabColumns - 1) * MODE_TAB_GAP))
                    / tabColumns
            )

            local groupLabel = self:AcquireModeGroupLabel(groupIndex)
            groupLabel:ClearAllPoints()
            groupLabel:SetPoint(
                "TOPLEFT",
                panel,
                "TOPLEFT",
                CONTENT_LEFT,
                nextY
            )
            groupLabel:SetText(self:GetModeGroupLabel(group))
            groupLabel:Show()

            local groupModeIndex = 1
            while groupModeIndex <= groupModeCount do
                local definition = self:FindModeDefinition(
                    schema,
                    groupModes[groupModeIndex]
                )
                if definition then
                    tabIndex = tabIndex + 1
                    local tab = self:AcquireTab(tabIndex)
                    local tabRow = math.floor(
                        (groupModeIndex - 1) / tabColumns
                    )
                    local tabColumn = (groupModeIndex - 1)
                        - (tabRow * tabColumns)
                    tab.modeKey = definition.key
                    tab:SetWidth(tabWidth)
                    tab:ClearAllPoints()
                    tab:SetPoint(
                        "TOPLEFT",
                        panel,
                        "TOPLEFT",
                        tabAreaLeft
                            + (tabColumn
                                * (tabWidth + MODE_TAB_GAP)),
                        nextY - (tabRow * MODE_ROW_HEIGHT)
                    )
                    tab.label:SetWidth(tabWidth - 8)
                    tab:SetText(D:GetRotationName(
                        profile,
                        definition.key
                    ))
                    local selected = definition.key == mode
                    StyleModeTab(tab, selected)
                    if selected then
                        tab:Disable()
                    else
                        tab:Enable()
                    end
                    tab:Show()
                end
                groupModeIndex = groupModeIndex + 1
            end
            nextY = nextY - (tabRows * MODE_ROW_HEIGHT)
            groupIndex = groupIndex + 1
        end

        local modeDefinition = self:GetModeDefinition(schema, mode)
        self.modeCard:ClearAllPoints()
        self.modeCard:SetPoint(
            "TOPLEFT",
            panel,
            "TOPLEFT",
            CONTENT_LEFT,
            nextY
        )
        self.modeCard:Show()
        self.modeNote:SetText(
            modeDefinition and modeDefinition.note or ""
        )
        self.modeNote:Show()
        local isDefault = self:IsModeDefault(profile, schema, mode)
        if isDefault then
            self.presetStatus:SetText(
                zh and "推荐配置" or "Recommended"
            )
            self.presetStatus:Show()
            self.presetStatus:SetTextColor(
                COLOR.green[1],
                COLOR.green[2],
                COLOR.green[3],
                COLOR.green[4]
            )
            self.modeNote:SetWidth(CONTENT_WIDTH - 100)
            self.resetButton:Hide()
        else
            self.presetStatus:Hide()
            self.modeNote:SetWidth(CONTENT_WIDTH - 132)
            self.resetButton:ClearAllPoints()
            self.resetButton:SetPoint(
                "RIGHT",
                self.modeCard,
                "RIGHT",
                -8,
                0
            )
            self.resetButton:Show()
        end
        nextY = nextY - MODE_CARD_HEIGHT - 6

        self.rotationNameLabel:ClearAllPoints()
        self.rotationNameLabel:SetPoint(
            "TOPLEFT",
            panel,
            "TOPLEFT",
            CONTENT_LEFT,
            nextY - 4
        )
        self.rotationNameLabel:Show()

        self.rotationNameEdit:ClearAllPoints()
        self.rotationNameEdit:SetPoint(
            "TOPLEFT",
            panel,
            "TOPLEFT",
            CONTENT_LEFT + 80,
            nextY
        )
        self.rotationNameEdit:SetText(D:GetRotationName(profile, mode))
        self.rotationNameEdit:Show()

        self.saveNameButton:ClearAllPoints()
        self.saveNameButton:SetPoint(
            "TOPLEFT",
            panel,
            "TOPLEFT",
            CONTENT_LEFT + 316,
            nextY
        )
        self.saveNameButton:Show()

        self.resetNameButton:ClearAllPoints()
        self.resetNameButton:SetPoint(
            "TOPLEFT",
            panel,
            "TOPLEFT",
            CONTENT_LEFT + 376,
            nextY
        )
        self.resetNameButton:Show()
        nextY = nextY - ROW_HEIGHT - 4

        local sectionIndex = 0
        local toggleIndex = 0
        local choiceIndex = 0
        local numberIndex = 0
        local currentSection = nil
        local optionColumn = 0
        local activeOptionGroup = nil
        local conditionalParents =
            BuildConditionalLayoutParents(schema, mode)
        local index = 1
        while index <= table.getn(schema.options or {}) do
            local option = schema.options[index]
            if ModeMatches(option, mode) then
                if option.section and option.section ~= currentSection then
                    if optionColumn > 0 then
                        nextY = nextY - ROW_HEIGHT
                        optionColumn = 0
                    end
                    activeOptionGroup = nil
                    currentSection = option.section
                    sectionIndex = sectionIndex + 1
                    local section = self:AcquireSection(sectionIndex)
                    section:ClearAllPoints()
                    section:SetPoint(
                        "TOPLEFT",
                        panel,
                        "TOPLEFT",
                        CONTENT_LEFT,
                        nextY
                    )
                    section:SetText(option.section)
                    section:Show()
                    nextY = nextY - SECTION_HEIGHT
                end

                -- A skill selector and every conditional setting controlled
                -- by it form one atomic layout group. The group always starts
                -- on a fresh row and never shares an unfinished row with a
                -- different skill. This keeps pairs such as Overpower + rage
                -- limit and Rend + health threshold together even when an
                -- unrelated option is added or removed above them.
                local optionGroup = GetOptionLayoutGroup(
                    option,
                    conditionalParents
                )
                if optionGroup ~= activeOptionGroup then
                    if optionColumn > 0
                        and (activeOptionGroup or optionGroup) then
                        nextY = nextY - ROW_HEIGHT
                        optionColumn = 0
                    end
                    activeOptionGroup = optionGroup
                end

                -- Every option that belongs to this rotation owns a stable
                -- grid slot. Conditional visibility only hides its control;
                -- it must not pull later skill settings into another column
                -- or row when the controlling value changes.
                if self:OptionVisible(profile, mode, option) then
                    local control
                    if option.type == "choice" then
                        choiceIndex = choiceIndex + 1
                        control = self:AcquireControl("choice", choiceIndex)
                    elseif option.type == "number" then
                        numberIndex = numberIndex + 1
                        control = self:AcquireControl("number", numberIndex)
                    else
                        toggleIndex = toggleIndex + 1
                        control = self:AcquireControl("toggle", toggleIndex)
                    end
                    control:ClearAllPoints()
                    control:SetPoint(
                        "TOPLEFT",
                        panel,
                        "TOPLEFT",
                        CONTENT_LEFT
                            + (optionColumn
                                * (COLUMN_WIDTH + COLUMN_GAP)),
                        nextY
                    )
                    self:BindControl(control, profile, mode, option)
                    control:Show()
                end
                optionColumn = optionColumn + 1
                if optionColumn >= 2 then
                    nextY = nextY - ROW_HEIGHT
                    optionColumn = 0
                end
            end
            index = index + 1
        end
        if optionColumn > 0 then
            nextY = nextY - ROW_HEIGHT
        end
        usedToggleCount = toggleIndex

    end

    self.generalTitle:ClearAllPoints()
    self.generalTitle:SetPoint(
        "TOPLEFT",
        panel,
        "TOPLEFT",
        CONTENT_LEFT,
        nextY
    )
    self.generalTitle:Show()
    nextY = nextY - SECTION_HEIGHT

    local generalIndex = 1
    local generalToggleBase = usedToggleCount
    local generalColumn = 0
    while generalIndex <= table.getn(GENERAL_OPTIONS) do
        local poolIndex = generalToggleBase + generalIndex
        local control = self:AcquireControl("toggle", poolIndex)
        control:ClearAllPoints()
        control:SetPoint(
            "TOPLEFT",
            panel,
            "TOPLEFT",
            CONTENT_LEFT
                + (generalColumn * (COLUMN_WIDTH + COLUMN_GAP)),
            nextY
        )
        self:BindControl(
            control,
            profile,
            self.editMode,
            GENERAL_OPTIONS[generalIndex]
        )
        control:Show()
        generalColumn = generalColumn + 1
        if generalColumn >= 2 then
            nextY = nextY - ROW_HEIGHT
            generalColumn = 0
        end
        generalIndex = generalIndex + 1
    end
    if generalColumn > 0 then
        nextY = nextY - ROW_HEIGHT
    end

    self.tankAssistTitle:ClearAllPoints()
    self.tankAssistTitle:SetPoint(
        "TOPLEFT",
        panel,
        "TOPLEFT",
        CONTENT_LEFT,
        nextY
    )
    self.tankAssistTitle:Show()
    nextY = nextY - SECTION_HEIGHT

    self.tankAssistRow:ClearAllPoints()
    self.tankAssistRow:SetPoint(
        "TOPLEFT",
        panel,
        "TOPLEFT",
        CONTENT_LEFT,
        nextY
    )
    self.tankAssistRow:Show()
    self:UpdateTankAssistStatus()
    nextY = nextY - ROW_HEIGHT - 2

    panel:SetHeight(math.max(210, (-nextY) + 12))
end

function C:Sync()
    self:Refresh()
end

function C:Toggle()
    if panel:IsVisible() then
        panel:Hide()
    else
        self:Refresh()
        panel:Show()
    end
end

-- --------------------------------------------------------------------------
-- Minimap button
-- --------------------------------------------------------------------------

local minimapButton = CreateFrame("Button", "DoiteDPSMinimapButton", Minimap)
C.minimapButton = minimapButton
minimapButton:SetWidth(31)
minimapButton:SetHeight(31)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8)
minimapButton:EnableMouse(true)
minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
minimapButton:RegisterForDrag("LeftButton")
minimapButton:SetHighlightTexture(
    "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
)

local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
icon:SetTexture("Interface\\Icons\\Spell_Nature_Lightning")
icon:SetWidth(20)
icon:SetHeight(20)
icon:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)
icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
minimapButton.icon = icon

local border = minimapButton:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetWidth(54)
border:SetHeight(54)
border:SetPoint("TOPLEFT", minimapButton, "TOPLEFT", -2, 2)

local function UpdateMinimapPosition()
    if not D.DB then D:InitializeDB() end
    local _, class = UnitClass("player")
    if class == "WARRIOR" then
        icon:SetTexture("Interface\\Icons\\Ability_Warrior_SavageBlow")
    else
        icon:SetTexture("Interface\\Icons\\Spell_Nature_Lightning")
    end

    local angle = math.rad(tonumber(D.DB.minimapAngle) or -45)
    minimapButton:ClearAllPoints()
    minimapButton:SetPoint(
        "CENTER",
        Minimap,
        "CENTER",
        math.cos(angle) * 80,
        math.sin(angle) * 80
    )
    if D.DB.showMinimap then
        minimapButton:Show()
    else
        minimapButton:Hide()
    end
end
C.UpdateMinimapPosition = UpdateMinimapPosition

minimapButton:SetScript("OnDragStart", function()
    this.dragging = true
end)
minimapButton:SetScript("OnDragStop", function()
    this.dragging = false
end)
minimapButton:SetScript("OnUpdate", function()
    if not this.dragging then return end
    local minimapX, minimapY = Minimap:GetCenter()
    local cursorX, cursorY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    cursorX = cursorX / scale
    cursorY = cursorY / scale
    D.DB.minimapAngle = math.deg(
        math.atan2(cursorY - minimapY, cursorX - minimapX)
    )
    UpdateMinimapPosition()
end)
minimapButton:SetScript("OnClick", function()
    if arg1 == "RightButton" then
        D.DB.enabled = not D.DB.enabled
        D:Update(true)
    else
        C:Toggle()
    end
end)
minimapButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:SetText("|cff6FA8DCDoiteDPS|r", 1, 1, 1)
    GameTooltip:AddLine(
        zh and "左键：配置" or "Left click: configure",
        0.8,
        0.8,
        0.8
    )
    GameTooltip:AddLine(
        zh and "右键：显示/隐藏监控" or "Right click: show/hide",
        0.8,
        0.8,
        0.8
    )
    GameTooltip:AddLine(
        zh and "拖动：移动按钮" or "Drag: move button",
        0.8,
        0.8,
        0.8
    )
    GameTooltip:Show()
end)
minimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

if not D.DB then D:InitializeDB() end
C:Sync()
UpdateMinimapPosition()
