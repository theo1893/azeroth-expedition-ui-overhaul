-- ============================================================================
-- DoiteDPS - explicit Warrior rotation catalog
--
-- All supported Warrior rotations stay visible regardless of talents. The
-- public single/AoE entries store a catalog mode and delegate state,
-- recommendation, forecast and execution to the owning profile.
-- ============================================================================

local D = DoiteDPS
local W = {}
D.Profiles.Warrior = W

W.key = "WARRIOR_ALL"

local locale = (GetLocale and GetLocale()) or "enUS"
local zh = (locale == "zhCN" or locale == "zhTW")

-- 目录项合同：
--   key 是保存到配置的公共模式；profileName/profileKey 用于定位所属 Profile；
--   mode 是所属 Profile 的本地模式；entry 限制该项可绑定的宏出口。
-- 本表只负责路由，不包含任何战斗优先级。
local DEFINITIONS = {
    {
        key = "arms_berserker_single",
        profileName = "WarriorArms",
        profileKey = "WARRIOR_ARMS",
        mode = "single",
        entry = "single",
        fallbackLabel = zh and "双手武器战" or "Two-Handed Arms Warrior",
    },
    {
        key = "protection_single",
        profileName = "WarriorProtection",
        profileKey = "WARRIOR_PROTECTION",
        mode = "single",
        entry = "single",
        fallbackLabel = zh and "防战" or "Protection Warrior",
    },
    {
        key = "arms_berserker_aoe",
        profileName = "WarriorArms",
        profileKey = "WARRIOR_ARMS",
        mode = "aoe",
        entry = "aoe",
        fallbackLabel = zh and "双手武器战" or "Two-Handed Arms Warrior",
    },
    {
        key = "protection_aoe",
        profileName = "WarriorProtection",
        profileKey = "WARRIOR_PROTECTION",
        mode = "aoe",
        entry = "aoe",
        fallbackLabel = zh and "防战" or "Protection Warrior",
    },
}

local MODE_BY_KEY = {}
local MODE_BY_STORAGE = {}
W.ModeOrder = {}
W.ModeLabels = {}

local function StorageKey(profileKey, mode)
    return tostring(profileKey or "") .. ":" .. tostring(mode or "")
end

local function GetOwner(definition)
    return definition
        and D.Profiles
        and D.Profiles[definition.profileName]
        or nil
end

local index = 1
while index <= table.getn(DEFINITIONS) do
    local definition = DEFINITIONS[index]
    MODE_BY_KEY[definition.key] = definition
    MODE_BY_STORAGE[
        StorageKey(definition.profileKey, definition.mode)
    ] = definition.key
    W.ModeOrder[index] = definition.key

    local owner = GetOwner(definition)
    local label = owner and owner.GetModeLabel
        and owner:GetModeLabel(definition.mode)
        or definition.fallbackLabel
    W.ModeLabels[definition.key] = label
    index = index + 1
end

W.EntryOrder = { "single", "aoe" }
W.EntryPoints = {
    single = {
        label = zh and "单体出口" or "Single output",
        modes = {
            "arms_berserker_single",
            "protection_single",
        },
        default = "arms_berserker_single",
    },
    aoe = {
        label = zh and "AOE出口" or "AoE output",
        modes = {
            "arms_berserker_aoe",
            "protection_aoe",
        },
        default = "arms_berserker_aoe",
    },
}

local LEGACY_ALIASES = {
    single = "arms_berserker_single",
    battle = "arms_berserker_single",
    arms_battle_single = "arms_berserker_single",
    fury_single = "arms_berserker_single",
    battle_aoe = "arms_berserker_aoe",
    arms_battle_aoe = "arms_berserker_aoe",
    fury_aoe = "arms_berserker_aoe",
    aoe = "arms_berserker_aoe",
}

local function EncodeMode(profileKey, mode)
    return MODE_BY_STORAGE[StorageKey(profileKey, mode)]
end

function W:NormalizeMode(mode)
    mode = tostring(mode or "")
    if MODE_BY_KEY[mode] then return mode end

    local delegateProfileKey = D._warriorDelegateProfileKey
    if delegateProfileKey then
        local delegated = EncodeMode(delegateProfileKey, mode)
        if delegated then return delegated end
    end

    return LEGACY_ALIASES[mode] or self.EntryPoints.single.default
end

function W:ResolveModeProfile(mode)
    local catalogMode = self:NormalizeMode(mode)
    local definition = MODE_BY_KEY[catalogMode]
    return GetOwner(definition), definition and definition.mode or nil,
        catalogMode
end

function W:GetModeLabel(mode)
    return self.ModeLabels[self:NormalizeMode(mode)]
end

function W:GetRotationDefaults(mode)
    local owner, ownerMode = self:ResolveModeProfile(mode)
    if owner and owner.GetRotationDefaults then
        return owner:GetRotationDefaults(ownerMode)
    end
    return {}
end

function W:GetRotationDB(mode)
    local owner, ownerMode = self:ResolveModeProfile(mode)
    if owner and owner.GetRotationDB then
        return owner:GetRotationDB(ownerMode)
    end
    return {}
end

function W:ResetRotationDB(mode)
    local owner, ownerMode = self:ResolveModeProfile(mode)
    if not owner or not owner.key or not owner.GetRotationDefaults then
        return nil
    end
    return D:ResetRotationDB(
        owner.key,
        ownerMode,
        owner:GetRotationDefaults(ownerMode)
    )
end

local function OptionUsesMode(option, mode)
    if type(option and option.modes) ~= "table" then return true end
    local optionIndex = 1
    while optionIndex <= table.getn(option.modes) do
        if option.modes[optionIndex] == mode then return true end
        optionIndex = optionIndex + 1
    end
    return false
end

local function CloneOptionForMode(option, catalogMode, section)
    local clone = {}
    local key, value
    for key, value in pairs(option) do
        if key ~= "modes" then clone[key] = value end
    end
    clone.section = section
    clone.modes = { catalogMode }
    return clone
end

W.ConfigSchema = {
    title = zh and "战士全部循环" or "All Warrior Rotations",
    modes = {},
    options = {},
}

index = 1
while index <= table.getn(DEFINITIONS) do
    local definition = DEFINITIONS[index]
    local owner = GetOwner(definition)
    local note = owner
        and owner.ModeNotes
        and owner.ModeNotes[definition.mode]
        or ""
    W.ConfigSchema.modes[index] = {
        key = definition.key,
        label = W.ModeLabels[definition.key],
        note = note,
    }

    local options = owner
        and owner.ConfigSchema
        and owner.ConfigSchema.options
        or {}
    local optionIndex = 1
    local optionSection = nil
    while optionIndex <= table.getn(options) do
        local option = options[optionIndex]
        if option.section then optionSection = option.section end
        if OptionUsesMode(option, definition.mode) then
            W.ConfigSchema.options[
                table.getn(W.ConfigSchema.options) + 1
            ] = CloneOptionForMode(
                option,
                definition.key,
                optionSection
            )
        end
        optionIndex = optionIndex + 1
    end
    index = index + 1
end

local function AddCooldownKeys(target, seen, keys)
    local keyIndex = 1
    while keyIndex <= table.getn(keys or {}) do
        local key = keys[keyIndex]
        if not seen[key] then
            target[table.getn(target) + 1] = key
            seen[key] = true
        end
        keyIndex = keyIndex + 1
    end
end

W.CooldownKeys = {}
do
    local seen = {}
    AddCooldownKeys(W.CooldownKeys, seen, D.WarriorCooldownKeys)
    AddCooldownKeys(W.CooldownKeys, seen, D.WarriorProtectionCooldownKeys)
end

local function GetLegacyProfile()
    -- This is a one-time compatibility migration only. It preserves the
    -- profile that older releases would have activated, then the saved
    -- catalog bindings become the sole authority on every later update.
    if D.Profiles.WarriorProtection and D:IsKnown("SHIELD_SLAM") then
        return D.Profiles.WarriorProtection
    end
    return D.Profiles.WarriorArms
        or D.Profiles.WarriorProtection
end

local function CatalogModeForEntry(owner, entry)
    if not owner then return nil end
    local ownerMode = D:GetEntryBinding(owner, entry)
    return EncodeMode(owner.key, ownerMode)
end

function W:PrepareEntryBindings(profileDB)
    if type(profileDB) ~= "table"
        or (tonumber(profileDB.warriorCatalogVersion) or 0) >= 2 then
        return
    end

    local previousMode = D.DB and D.DB.mode or "single"
    local legacyProfile = GetLegacyProfile()
    if type(profileDB.entryBindings) ~= "table" then
        profileDB.entryBindings = {}
    end

    local single = LEGACY_ALIASES[profileDB.entryBindings.single]
        or profileDB.entryBindings.single
    if not MODE_BY_KEY[single]
        or MODE_BY_KEY[single].entry ~= "single" then
        single = CatalogModeForEntry(legacyProfile, "single")
            or self.EntryPoints.single.default
    end
    profileDB.entryBindings.single = single

    local aoe = LEGACY_ALIASES[profileDB.entryBindings.aoe]
        or profileDB.entryBindings.aoe
    if not MODE_BY_KEY[aoe]
        or MODE_BY_KEY[aoe].entry ~= "aoe" then
        aoe = CatalogModeForEntry(legacyProfile, "aoe")
            or self.EntryPoints.aoe.default
    end
    profileDB.entryBindings.aoe = aoe

    if D.DB then
        if previousMode == "single" then
            D.DB.mode = single
        elseif previousMode == "aoe" then
            D.DB.mode = aoe
        else
            D.DB.mode = self:NormalizeMode(previousMode)
        end
    end

    profileDB.entryBindingsMigrated = true
    profileDB.warriorCatalogVersion = 2
end

function W:PrepareRuntime()
    if not D.DB then return end
    self:PrepareEntryBindings(D:GetProfileDB(self.key))
end

local PROFILE_NAMES = {
    "WarriorArms",
    "WarriorProtection",
}

function W:ResetRuntime()
    local profileIndex = 1
    while profileIndex <= table.getn(PROFILE_NAMES) do
        local owner = D.Profiles[PROFILE_NAMES[profileIndex]]
        if owner and owner.ResetRuntime then owner:ResetRuntime() end
        profileIndex = profileIndex + 1
    end
end

function W:OnEvent(eventName, a1, a2, a3, a4, a5, a6, a7, a8, a9)
    local profileIndex = 1
    while profileIndex <= table.getn(PROFILE_NAMES) do
        local owner = D.Profiles[PROFILE_NAMES[profileIndex]]
        if owner and owner.OnEvent then
            owner:OnEvent(eventName, a1, a2, a3, a4, a5, a6, a7, a8, a9)
        end
        profileIndex = profileIndex + 1
    end
end

-- 所属 Profile 扩展共享 State 时，临时暴露它的本地模式；完成后恢复
-- Core、Config 与 UI 使用的目录身份。
function W:BuildState(state)
    local owner, ownerMode, catalogMode =
        self:ResolveModeProfile(state and state.mode)
    if not owner or not owner.BuildState then return end

    state.warriorCatalogMode = catalogMode
    state.warriorProfile = owner
    state.warriorProfileMode = ownerMode
    state.mode = ownerMode
    state.profileKey = owner.key
    owner:BuildState(state)

    if not D._warriorDelegateProfileKey then
        state.mode = catalogMode
        state.profileKey = self.key
    end
end

function W:DecorateCooldown(key, entry, state)
    local owner = state and state.warriorProfile
    local ownerMode = state and state.warriorProfileMode
    if not owner or not owner.DecorateCooldown then return end

    local previousMode = state.mode
    state.mode = ownerMode
    owner:DecorateCooldown(key, entry, state)
    state.mode = previousMode
end

function W:Recommend(state)
    local owner, ownerMode, catalogMode = self:ResolveModeProfile(
        state and (state.warriorCatalogMode or state.mode)
    )
    if not owner or not owner.Recommend then return nil end

    local previousMode = state.mode
    local previousProfileKey = state.profileKey
    state.mode = ownerMode
    state.profileKey = owner.key
    local recommendation = owner:Recommend(state)
    state.mode = previousMode or catalogMode
    state.profileKey = previousProfileKey or self.key
    return recommendation
end

-- 推荐与预测作为一个整体委托，确保两者始终来自同一个 Profile 和本地模式。
function W:Evaluate(state)
    local owner, ownerMode, catalogMode = self:ResolveModeProfile(
        state and (state.warriorCatalogMode or state.mode)
    )
    if not owner or not owner.Evaluate then return nil, nil end

    state.mode = ownerMode
    state.profileKey = owner.key
    local recommendation, forecast = owner:Evaluate(state)
    state.mode = catalogMode
    state.profileKey = self.key
    return recommendation, forecast
end

-- 委托标记让执行期间嵌套调用的 Core:BuildState 能解析所属 Profile 的本地模式；
-- pcall 确保出错后仍会恢复两个标记。
function W:Execute(mode)
    local owner, ownerMode, catalogMode = self:ResolveModeProfile(mode)
    if not owner or not owner.Execute then return false end

    local previousProfileKey = D._warriorDelegateProfileKey
    local previousCatalogMode = D._warriorDelegateCatalogMode
    D._warriorDelegateProfileKey = owner.key
    D._warriorDelegateCatalogMode = catalogMode
    local ok, result = pcall(owner.Execute, owner, ownerMode)
    D._warriorDelegateProfileKey = previousProfileKey
    D._warriorDelegateCatalogMode = previousCatalogMode
    if not ok then error(result) end
    return result
end
