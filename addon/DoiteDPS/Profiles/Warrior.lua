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
        fallbackLabel = zh and "双手战士" or "Two-Handed Warrior",
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
        fallbackLabel = zh and "双手战士" or "Two-Handed Warrior",
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
    if eventName == "PLAYER_ENTERING_WORLD" and self.weaponSwap then
        self:FinishWeaponSwap(false)
    end
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
    if self.weaponSwap then return false end
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

-- Explicit role swap: only a player command starts this short equipment job.
-- Recommendations never equip items or cast spells. Commit both public entries
-- only after the client reports the complete weapon set in slots 16/17.
local function WeaponKey(link)
    local _, _, key = string.find(link or "", "(item:[^|]+)")
    return key
end

local function EquippedKey(slot)
    return WeaponKey(GetInventoryItemLink("player", slot))
end

local function EquipLocation(link)
    if not link then return nil end
    local name, itemLink, quality, level, itemType, subType, count, location =
        GetItemInfo(link)
    return location
end

local function FindWeapon(key)
    local bag, slot
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            if WeaponKey(GetContainerItemLink(bag, slot)) == key then
                return bag, slot
            end
        end
    end
end

local function EmptyBackpackSlot()
    -- ponytail: use the always-general backpack; scan bag families if support
    -- for an entirely full backpack with empty specialty/normal bags is needed.
    local slot
    for slot = 1, GetContainerNumSlots(0) do
        if not GetContainerItemLink(0, slot) then return slot end
    end
end

local function WeaponError(message)
    D:Print(message)
    return false
end

function W:IsWeaponAllowed(role, slot, key)
    local location = EquipLocation(key)
    if role == "dps" and slot == "main" then
        return location == "INVTYPE_2HWEAPON"
    elseif role == "tank" and slot == "main" then
        return location == "INVTYPE_WEAPON" or location == "INVTYPE_WEAPONMAINHAND"
    elseif role == "tank" and slot == "off" then
        return location == "INVTYPE_SHIELD"
    end
    return false
end

function W:SetWeapon(role, slot, key)
    if self.weaponSwap then
        return WeaponError(zh and "正在切换武器，请稍候。" or "Weapon swap in progress.")
    end
    if (role ~= "dps" and role ~= "tank") or (slot ~= "main" and slot ~= "off")
        or (role == "dps" and slot == "off") then return false end
    if key and not self:IsWeaponAllowed(role, slot, key) then return false end
    local db = D:GetProfileDB(self.key)
    db.weaponSets = db.weaponSets or {}
    db.weaponSets[role] = db.weaponSets[role] or {}
    db.weaponSets[role][slot] = key
    if D.Config and D.Config.Sync then D.Config:Sync() end
    return true
end

function W:SaveWeapons(role)
    if self.weaponSwap then
        return WeaponError(zh and "正在切换武器，请稍候。" or "Weapon swap in progress.")
    end
    if role ~= "dps" and role ~= "tank" then return false end
    local main = GetInventoryItemLink("player", 16)
    local off = GetInventoryItemLink("player", 17)
    if role == "dps" then
        -- The current damage catalog contains only the two-handed Arms owner.
        if not self:IsWeaponAllowed(role, "main", main) then
            return WeaponError(zh and "当前输出循环为双手武器战，请先装备输出双手武器。"
                or "The damage rotation requires an equipped two-handed weapon.")
        end
        off = nil
    elseif not self:IsWeaponAllowed(role, "main", main)
        or not self:IsWeaponAllowed(role, "off", off) then
        return WeaponError(zh and "请先装备坦克单手武器和盾牌。"
            or "Equip a tank one-handed weapon and shield first.")
    end
    local db = D:GetProfileDB(self.key)
    db.weaponSets = db.weaponSets or {}
    db.weaponSets[role] = { main = WeaponKey(main), off = WeaponKey(off) }
    if D.Config and D.Config.Sync then D.Config:Sync() end
    D:Print((role == "tank" and (zh and "已保存坦克武器：" or "Tank weapons saved: ")
        or (zh and "已保存输出武器：" or "Damage weapon saved: "))
        .. main .. (off and (" / " .. off) or ""))
    return true
end

function W:FinishWeaponSwap(success)
    local job = self.weaponSwap
    self.weaponSwap = nil
    if self.weaponFrame then self.weaponFrame:Hide() end
    if not job then return end
    if not success then
        D:Print(zh and "武器切换未完成，循环未更改；请检查装备、物品锁定及背包空格后重按。部分装备可能已切换。"
            or "Weapon swap incomplete; rotations unchanged. Check gear, item locks and bag space, then retry. Some gear may have changed.")
        return
    end
    local prefix = job.role == "tank" and "protection_" or "arms_berserker_"
    D:SetEntryBinding(self, "single", prefix .. "single")
    D:SetEntryBinding(self, "aoe", prefix .. "aoe")
    D:SetMode(prefix .. job.entry, true)
    if D.Config and D.Config.Sync then D.Config:Sync() end
    D:Print(job.role == "tank"
        and (zh and "已切换：剑盾 + 防战循环（单体／AOE）。" or "Switched to weapon/shield + Protection (single/AoE).")
        or (zh and "已切换：输出武器 + 武器战循环（单体／AOE）。" or "Switched to damage weapon + Arms (single/AoE)."))
end

function W:AdvanceWeaponSwap()
    local job = self.weaponSwap
    if not job then return end
    local _, class = UnitClass("player")
    if class ~= "WARRIOR" or job.db ~= D.DB or GetTime() > job.deadline
        or CursorHasItem() then
        self:FinishWeaponSwap(false)
        return
    end
    local main, off = EquippedKey(16), EquippedKey(17)
    if main == job.set.main and off == job.set.off then
        self:FinishWeaponSwap(true)
        return
    end
    -- One request per slot, wait for acknowledgement before touching the next.
    if job.waitSlot then
        if EquippedKey(job.waitSlot) ~= job.waitKey then return end
        job.waitSlot = nil
    end
    if not job.set.off and off then
        local empty = EmptyBackpackSlot()
        if not empty then self:FinishWeaponSwap(false); return end
        job.waitSlot, job.waitKey = 17, nil
        PickupInventoryItem(17)
        if CursorHasItem() then PickupContainerItem(0, empty) end
    else
        local inventorySlot = main ~= job.set.main and 16 or 17
        local key = inventorySlot == 16 and job.set.main or job.set.off
        local bag, slot = FindWeapon(key)
        if not bag then self:FinishWeaponSwap(false); return end
        local texture, count, locked = GetContainerItemInfo(bag, slot)
        if locked then return end
        job.waitSlot, job.waitKey = inventorySlot, key
        PickupContainerItem(bag, slot)
        if CursorHasItem() then EquipCursorItem(inventorySlot) end
    end
    -- Return any unaccepted/displaced cursor item; never destroy or overwrite it.
    if CursorHasItem() then
        ClearCursor()
        self:FinishWeaponSwap(false)
    end
end

function W:SwitchRole(role)
    if self.weaponSwap then return true end -- Repeated clicks cannot reverse an unfinished swap.
    local mode = self:NormalizeMode(D.DB.mode)
    if not role or role == "toggle" then
        role = MODE_BY_KEY[mode].profileKey == "WARRIOR_PROTECTION" and "dps" or "tank"
    end
    if role ~= "dps" and role ~= "tank" then
        return WeaponError("/ddps role toggle|dps|tank")
    end
    local sets = D:GetProfileDB(self.key).weaponSets
    local set = sets and sets[role]
    if not set or not set.main or (role == "tank" and not set.off) then
        return WeaponError(zh and "请先装备并保存该武器方案：/ddps weapons save dps 或 /ddps weapons save tank"
            or "Equip and save this set first: /ddps weapons save dps or /ddps weapons save tank")
    end
    if CursorHasItem() then
        return WeaponError(zh and "请先放下鼠标上的物品。" or "Put down the cursor item first.")
    end
    local slots = { 16, 17 }
    local index
    for index = 1, 2 do
        local key = index == 1 and set.main or set.off
        if key and EquippedKey(slots[index]) ~= key and not FindWeapon(key) then
            return WeaponError(zh and "所需武器不在装备位或随身背包中，未切换。"
                or "Required weapon missing from equipment/bags; no swap started.")
        end
    end
    if not set.off and EquippedKey(17) and not EmptyBackpackSlot() then
        return WeaponError(zh and "请在主背包留出一个空格用于收起盾牌。"
            or "Leave one empty backpack slot to store the shield.")
    end
    self.weaponSwap = {
        role = role, set = set, entry = MODE_BY_KEY[mode].entry,
        db = D.DB, deadline = GetTime() + 5,
    }
    if not self.weaponFrame then
        self.weaponFrame = CreateFrame("Frame")
        self.weaponFrame:SetScript("OnUpdate", function()
            if not W.weaponSwap then return end
            local now = GetTime()
            if now < (W.weaponSwap.nextCheck or 0) then return end
            W.weaponSwap.nextCheck = now + 0.1
            W:AdvanceWeaponSwap()
        end)
    end
    self.weaponFrame:Show()
    self:AdvanceWeaponSwap()
    return true
end

function DoiteDPS_WarriorRole(role)
    local profile = D:GetActiveProfile()
    if profile ~= W then
        return WeaponError(zh and "此命令仅支持战士。" or "This command is Warrior-only.")
    end
    if not D.DB then D:InitializeDB() end
    return W:SwitchRole(role)
end
