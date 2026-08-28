-- ============================================================================
-- DoiteDPS - Shield Protection Warrior profile
-- Turtle WoW / Vanilla 1.12 / Lua 5.0
--
-- The public macro entries remain "single" and "aoe". Both rotations stay in
-- Defensive Stance and require a one-handed weapon plus shield.
-- ============================================================================

local D = DoiteDPS
local P = {}
D.Profiles.WarriorProtection = P

local locale = (GetLocale and GetLocale()) or "enUS"
local zh = (locale == "zhCN" or locale == "zhTW")
local PROTECTION_DEFAULTS_VERSION = 1

P.key = "WARRIOR_PROTECTION"
P.CooldownKeys = D.WarriorProtectionCooldownKeys
    or D.WarriorCooldownKeys

P.ModeOrder = { "single", "aoe" }
P.ModeLabels = {
    single = zh and "防战" or "Protection Warrior",
    aoe = zh and "防战" or "Protection Warrior",
}
P.EntryOrder = { "single", "aoe" }
P.EntryPoints = {
    single = {
        label = zh and "单体宏出口" or "Single macro entry",
        modes = { "single" },
        default = "single",
    },
    aoe = {
        label = zh and "AOE宏出口" or "AoE macro entry",
        modes = { "aoe" },
        default = "aoe",
    },
}
P.ModeNotes = {
    single = zh
        and "防御姿态：震荡猛击起手，盾牌猛击与复仇构成主轴，英勇打击只在保留核心怒气后泄怒。"
        or "Defensive Stance: Concussion Blow opener, Shield Slam/Revenge core, guarded Heroic Strike dump.",
    aoe = zh
        and "防御姿态：雷霆一击和首次挫志覆盖群体，顺劈泄怒；其余公共冷却用于主目标并配合手动切目标破甲。"
        or "Defensive Stance: Thunder Clap and initial Demo coverage, Cleave dump, then tab-Sunder priority targets.",
}

P.RotationDefaults = {
    single = {
        useConcussionBlow = true,
        useShieldSlam = true,
        useRevenge = true,
        useThunderClap = false,
        maintainDemoralizingShout = false,
        sunderStrategy = "auto",
        useHeroicStrike = true,
        heroicRage = 60,
        shieldBlockStrategy = "off",
        shieldBlockRage = 35,
    },
    aoe = {
        useConcussionBlow = true,
        useShieldSlam = true,
        useRevenge = true,
        useThunderClap = true,
        maintainDemoralizingShout = true,
        sunderStrategy = "auto",
        useCleave = true,
        cleaveRage = 60,
        shieldBlockStrategy = "off",
        shieldBlockRage = 40,
    },
}

P.ConfigSchema = {
    title = zh and "盾T防战" or "Shield Protection Warrior",
    modes = {
        {
            key = "single",
            label = P.ModeLabels.single,
            note = P.ModeNotes.single,
        },
        {
            key = "aoe",
            label = P.ModeLabels.aoe,
            note = P.ModeNotes.aoe,
        },
    },
    options = {
        {
            type = "toggle",
            section = zh and "核心仇恨" or "Core threat",
            key = "useConcussionBlow",
            label = zh and "震荡猛击参与循环" or "Use Concussion Blow",
            modes = { "single", "aoe" },
        },
        {
            type = "toggle",
            key = "useShieldSlam",
            label = zh and "盾牌猛击参与循环" or "Use Shield Slam",
            modes = { "single", "aoe" },
        },
        {
            type = "toggle",
            key = "useRevenge",
            label = zh and "复仇参与循环" or "Use Revenge",
            modes = { "single", "aoe" },
        },
        {
            type = "choice",
            key = "sunderStrategy",
            label = zh and "破甲攻击策略" or "Sunder Armor strategy",
            modes = { "single", "aoe" },
            values = {
                {
                    value = "auto",
                    label = zh and "自动加入循环" or "Automatic",
                },
                {
                    value = "manual",
                    label = zh and "仅手动按键" or "Manual only",
                },
            },
        },
        {
            type = "toggle",
            section = zh and "群体与减伤" or "Area and mitigation",
            key = "useThunderClap",
            label = zh and "雷霆一击参与循环" or "Use Thunder Clap",
            modes = { "single", "aoe" },
        },
        {
            type = "toggle",
            key = "maintainDemoralizingShout",
            label = zh and "首次覆盖挫志怒吼" or "Apply Demoralizing Shout",
            modes = { "single", "aoe" },
        },
        {
            type = "choice",
            key = "shieldBlockStrategy",
            label = zh and "自动盾挡策略" or "Automatic Shield Block",
            modes = { "single", "aoe" },
            values = {
                { value = "off", label = zh and "关闭" or "Off" },
                {
                    value = "revenge",
                    label = zh and "核心空档引导复仇"
                        or "Prime Revenge in core gaps",
                },
                {
                    value = "mitigation",
                    label = zh and "主动减伤（高压）"
                        or "Active mitigation (high pressure)",
                },
            },
        },
        {
            type = "number",
            key = "shieldBlockRage",
            label = zh and "盾挡最低怒气" or "Shield Block minimum rage",
            modes = { "single", "aoe" },
            min = 20,
            max = 100,
            step = 5,
            format = "%d",
            visibleWhen = {
                key = "shieldBlockStrategy",
                notValue = "off",
            },
        },
        {
            type = "toggle",
            section = zh and "泄怒" or "Rage dumps",
            key = "useHeroicStrike",
            label = zh and "英勇打击参与泄怒" or "Use Heroic Strike",
            modes = { "single" },
        },
        {
            type = "number",
            key = "heroicRage",
            label = zh and "英勇打击最低怒气" or "Heroic Strike minimum rage",
            modes = { "single" },
            min = 30,
            max = 100,
            step = 5,
            format = "%d",
            visibleWhen = {
                key = "useHeroicStrike",
                value = true,
            },
        },
        {
            type = "toggle",
            key = "useCleave",
            label = zh and "顺劈斩参与泄怒" or "Use Cleave",
            modes = { "aoe" },
        },
        {
            type = "number",
            key = "cleaveRage",
            label = zh and "顺劈斩最低怒气" or "Cleave minimum rage",
            modes = { "aoe" },
            min = 30,
            max = 100,
            step = 5,
            format = "%d",
            visibleWhen = {
                key = "useCleave",
                value = true,
            },
        },
    },
}

function P:NormalizeMode(mode)
    if mode == "aoe" then return "aoe" end
    return "single"
end

function P:GetModeLabel(mode)
    return self.ModeLabels[self:NormalizeMode(mode)]
end

function P:GetRotationDefaults(mode)
    return self.RotationDefaults[self:NormalizeMode(mode)]
end

function P:GetRotationDB(mode)
    mode = self:NormalizeMode(mode)
    local defaults = self:GetRotationDefaults(mode)
    if D.GetRotationDB then
        local profileDB = D:GetProfileDB(self.key)
        if (tonumber(profileDB.protectionDefaultsVersion) or 0)
            < PROTECTION_DEFAULTS_VERSION then
            local aoe = D:GetRotationDB(
                self.key,
                "aoe",
                self.RotationDefaults.aoe
            )
            -- Version 0 shipped the AoE preset with Concussion Blow off.
            -- Promote existing characters to the new explicit tank policy.
            aoe.useConcussionBlow = true
            profileDB.protectionDefaultsVersion =
                PROTECTION_DEFAULTS_VERSION
        end
        return D:GetRotationDB(self.key, mode, defaults)
    end
    return defaults
end

local R = {
    DEFENSIVE_STANCE = zh and "进入防御姿态获得完整仇恨加成"
        or "Enter Defensive Stance for full threat",
    CONCUSSION_BLOW = zh and "高爆发起手仇恨" or "High snap threat",
    SHIELD_SLAM = zh and "盾牌猛击优先" or "Shield Slam priority",
    REVENGE = zh and "高效率复仇仇恨" or "Efficient Revenge threat",
    REVENGE_EXPIRING = zh and "复仇窗口即将结束" or "Revenge window expiring",
    THUNDER_CLAP = zh and "雷霆一击建立群体仇恨" or "Thunder Clap area threat",
    DEMORALIZING_SHOUT = zh and "首次覆盖挫志并建立群体仇恨"
        or "Initial Demoralizing Shout coverage",
    SUNDER_STACK = zh and "建立五层或临近结束时刷新破甲"
        or "Build or refresh Sunder Armor",
    HEROIC_STRIKE = zh and "保留核心怒气后的英勇泄怒"
        or "Heroic Strike after core reserve",
    CLEAVE = zh and "保留群体核心怒气后的顺劈泄怒"
        or "Cleave after area-core reserve",
    SHIELD_BLOCK = zh and "核心空档用盾挡引导复仇"
        or "Prime Revenge with Shield Block in a core gap",
    SHIELD_BLOCK_MITIGATION = zh and "高压主动盾挡减伤"
        or "Use Shield Block for active mitigation",
    QUEUED_HS = zh and "英勇打击已排队，等待主手白字"
        or "Heroic Strike queued",
    QUEUED_CLEAVE = zh and "顺劈斩已排队，等待主手白字"
        or "Cleave queued",
    NO_SHIELD = zh and "请装备单手武器和盾牌"
        or "Equip a one-handed weapon and shield",
    WAIT_RAGE = zh and "等待怒气制造仇恨" or "Wait for rage",
    WAIT_SWING = zh and "等待下一次白字" or "Wait for next auto attack",
    WAIT_CD = zh and "等待核心仇恨技能" or "Wait for core threat cooldowns",
}

P._rec = D.Recommendation
P._forecast = D.Forecasts
P._forecastCandidates = {}
P._predictedCooldownUntil = {}
P._cooldownCycle = {}
P._apiCooldownActive = {}
P._pendingDemoralizingUntil = nil
P._pendingSunderUntil = nil

local FORECAST_LIMIT = D.FORECAST_LIMIT or 3
local ROTATION_LOCK = 1.5
local STANCE_LOCK = 1.0
local QUEUE_LOCK = 0.15
local SUNDER_MAX_STACKS = 5
local SUNDER_REFRESH_WINDOW = 5
local IMPROVED_SHIELD_SLAM = zh and "强化盾牌猛击"
    or "Improved Shield Slam"
local IMPROVED_REVENGE = zh and "强化复仇" or "Improved Revenge"

local function Max(a, b)
    a = tonumber(a) or 0
    b = tonumber(b) or 0
    if a > b then return a end
    return b
end

local function Clamp(value, low, high)
    value = tonumber(value) or low
    if value < low then return low end
    if value > high then return high end
    return value
end

local function TalentRankByName(tabIndex, wantedName)
    if not GetTalentInfo or not wantedName then return 0 end
    local index = 1
    while index <= 30 do
        local ok, name, icon, tier, column, rank = pcall(
            GetTalentInfo,
            tabIndex,
            index
        )
        if not ok or not name then break end
        if name == wantedName then
            return tonumber(rank) or 0
        end
        index = index + 1
    end
    return 0
end

function P:GetProtectionTalentRanks()
    if self._talentRanksValid then
        return self._improvedShieldSlamRank or 0,
            self._improvedRevengeRank or 0
    end
    self._improvedShieldSlamRank =
        TalentRankByName(3, IMPROVED_SHIELD_SLAM)
    self._improvedRevengeRank =
        TalentRankByName(3, IMPROVED_REVENGE)
    self._talentRanksValid = true
    return self._improvedShieldSlamRank,
        self._improvedRevengeRank
end

local function RotationValue(state, key)
    if state and state.rotationDB
        and state.rotationDB[key] ~= nil then
        return state.rotationDB[key]
    end
    local mode = P:NormalizeMode(state and state.mode)
    local defaults = P.RotationDefaults[mode]
        or P.RotationDefaults.single
    return defaults[key]
end

local function RotationEnabled(state, key)
    local value = RotationValue(state, key)
    return value ~= false and value ~= 0 and value ~= "off"
end

local function Cost(state, key)
    local def = D:GetSpellDef(key)
    local cost = def and tonumber(def.cost) or 0
    if cost < 0 then cost = 0 end
    return cost
end

local function IsOnSwingQueued(state)
    local swing = state and state.swing
    return swing and (
        swing.hsQueued
        or swing.cleaveQueued
        or swing.queuePending
    ) or false
end

local function CooldownDuration(state, key)
    if key == "SHIELD_SLAM" then
        local rank = tonumber(state and state.improvedShieldSlamRank) or 0
        return Max(4.5, 6 - (rank * 0.75))
    elseif key == "REVENGE" then
        local rank = tonumber(state and state.improvedRevengeRank) or 0
        return Max(4.5, 6 - (rank * 0.5))
    elseif key == "THUNDER_CLAP" then
        return 4
    elseif key == "SHIELD_BLOCK" then
        return 5
    elseif key == "CONCUSSION_BLOW" then
        return 45
    end
    return nil
end

local function CooldownRemaining(state, key)
    local entry = state.cooldowns and state.cooldowns[key]
    local now = tonumber(state.now) or GetTime()
    local apiRemaining = 0
    local apiDuration = 0

    if entry then
        apiRemaining = tonumber(entry.remaining) or 0
        apiDuration = tonumber(entry.duration) or 0
    else
        apiRemaining, apiDuration = D:GetRealCooldown(key, now)
        apiRemaining = tonumber(apiRemaining) or 0
        apiDuration = tonumber(apiDuration) or 0
    end

    if apiDuration > D.GCD_MAX then
        if apiRemaining > 0.05 then
            if not P._apiCooldownActive[key] then
                P._cooldownCycle[key] =
                    (tonumber(P._cooldownCycle[key]) or 0) + 1
            end
            P._apiCooldownActive[key] = true
            P._predictedCooldownUntil[key] = now + apiRemaining
        else
            P._apiCooldownActive[key] = false
            P._predictedCooldownUntil[key] = nil
        end
        return apiRemaining
    end

    local predictedUntil = P._predictedCooldownUntil[key]
    local predictedRemaining = predictedUntil
        and (predictedUntil - now) or 0
    if predictedRemaining <= 0.05 then
        P._apiCooldownActive[key] = false
        P._predictedCooldownUntil[key] = nil
        predictedRemaining = 0
    end
    return Max(apiRemaining, predictedRemaining)
end

local function SpellEventMatchesKey(key, spellIdValue)
    local spellId = tonumber(spellIdValue)
    if not spellId or spellId <= 0 then return false end

    local spell = D.Spells and D.Spells[key]
    if spell and tonumber(spell.spellId) == spellId then
        return true
    end

    local eventName = nil
    if GetSpellNameAndRankForId then
        local ok, name = pcall(GetSpellNameAndRankForId, spellId)
        if ok then eventName = name end
    end
    if not eventName and GetSpellRecField then
        local ok, name = pcall(GetSpellRecField, spellId, "name")
        if ok then eventName = name end
    end
    return eventName ~= nil and eventName == D:GetName(key)
end

local function RecordPredictedCooldown(key, state)
    local duration = CooldownDuration(state, key)
    if not duration or duration <= 0 then return end
    local now = GetTime()
    local deadline = now + duration
    local existing = P._predictedCooldownUntil[key]
    if not existing or existing < (deadline - 0.50) then
        P._predictedCooldownUntil[key] = deadline
        P._cooldownCycle[key] =
            (tonumber(P._cooldownCycle[key]) or 0) + 1
        P._apiCooldownActive[key] = true
    end
end

local function HasNamedPlayerBuff(name)
    if not name or not DoitePlayerAuras
        or not DoitePlayerAuras.HasBuff then
        return false
    end
    local ok, active = pcall(DoitePlayerAuras.HasBuff, name)
    return ok and active and true or false
end

local function GetEquipLocation(link)
    if not link or not GetItemInfo then return nil end
    local ok, name, itemLink, quality, level, minLevel, itemType,
        subType, stackCount, equipLoc = pcall(GetItemInfo, link)
    if not ok then return nil end
    return equipLoc
end

function P:DetectShield()
    if not GetInventoryItemLink then return true end
    local link = GetInventoryItemLink("player", 17)
    if not link then return false end
    local equipLoc = GetEquipLocation(link)
    if equipLoc == "INVTYPE_SHIELD" then return true end
    if equipLoc ~= nil then return false end
    -- Item data can be uncached for a frame after zoning/equipping. Keep the
    -- profile live; IsSpellUsable still prevents an invalid Shield Slam cast.
    return true
end

local function TargetingPlayer()
    if UnitExists and not UnitExists("targettarget") then
        return false
    end
    if UnitIsUnit and UnitExists and UnitExists("targettarget") then
        local ok, result = pcall(UnitIsUnit, "targettarget", "player")
        if ok then return result and true or false end
    end
    if UnitName and UnitExists and UnitExists("targettarget") then
        local okTarget, targetName = pcall(UnitName, "targettarget")
        local okPlayer, playerName = pcall(UnitName, "player")
        if okTarget and okPlayer and targetName and playerName then
            return targetName == playerName
        end
    end
    return false
end

function P:BuildState(state)
    state.resourceType = "rage"
    state.timingType = "swing"
    state.rage = D:GetRage()
    state.playerHP = D:GetPlayerHealthPercent()
    state.stance = D:GetStance()
    state.profileDB = D:GetProfileDB(self.key)
    state.rotationDB = self:GetRotationDB(state.mode)
    state.hasShield = self:DetectShield()
    state.targetingPlayer = TargetingPlayer()
    state.improvedShieldSlamRank, state.improvedRevengeRank =
        self:GetProtectionTalentRanks()
    state.revengeActive, state.revengeRemaining =
        D:GetReactiveState("REVENGE")
    state.shieldBlockBuff, state.shieldBlockRemaining =
        D:GetPlayerBuffState("SHIELD_BLOCK")
    state.improvedShieldSlamBuff =
        HasNamedPlayerBuff(IMPROVED_SHIELD_SLAM)
    state.demoralizingShout = D:HasTargetDebuff(
        D:GetName("DEMORALIZING_SHOUT")
    )
    state.sunderStacks = D:GetTargetDebuffStacks(
        D:GetName("SUNDER_ARMOR"),
        "SUNDER_ARMOR"
    )
    state.sunderRemaining = D:GetTargetDebuffRemaining(
        D:GetName("SUNDER_ARMOR")
    )
    state.swing = D:GetSwingState(state.swing)

    local inMelee = D:IsMeleeRange("target", "SHIELD_SLAM")
    if inMelee == nil and tonumber(state.targetDistance) then
        inMelee = tonumber(state.targetDistance) <= 5
    end
    state.meleeRangeKey = "SHIELD_SLAM"
    state.inMelee = state.targetValid and inMelee == true or false
end

function P:DecorateCooldown(key, entry, state)
    if key == "REVENGE" then
        entry.proc = state.revengeActive and true or false
        entry.procRemaining = state.revengeRemaining
    end
end

function P:ResetRuntime()
    self._predictedCooldownUntil = {}
    self._cooldownCycle = {}
    self._apiCooldownActive = {}
    self._pendingDemoralizingUntil = nil
    self._pendingSunderUntil = nil
    self._talentRanksValid = nil
    self._improvedShieldSlamRank = nil
    self._improvedRevengeRank = nil
end

function P:OnEvent(eventName, a1, a2)
    if eventName == "SPELLS_CHANGED"
        or eventName == "CHARACTER_POINTS_CHANGED"
        or eventName == "PLAYER_TALENT_UPDATE" then
        self._talentRanksValid = nil
        return
    end
    if eventName == "PLAYER_ENTERING_WORLD" then
        self:ResetRuntime()
        return
    end

    local spellId = nil
    if eventName == "SPELL_CAST_EVENT" then
        if tonumber(a1) ~= 1 then return end
        spellId = a2
    elseif eventName == "SPELL_GO_SELF" then
        local itemId = tonumber(a1) or 0
        if itemId ~= 0 then return end
        spellId = a2
    else
        return
    end

    local keys = {
        "CONCUSSION_BLOW",
        "SHIELD_SLAM",
        "REVENGE",
        "THUNDER_CLAP",
        "SHIELD_BLOCK",
    }
    local index = 1
    while index <= table.getn(keys) do
        local key = keys[index]
        if SpellEventMatchesKey(key, spellId) then
            RecordPredictedCooldown(key, D.State)
            break
        end
        index = index + 1
    end

    if SpellEventMatchesKey("DEMORALIZING_SHOUT", spellId) then
        self._pendingDemoralizingUntil = GetTime() + ROTATION_LOCK
    end
    if SpellEventMatchesKey("SUNDER_ARMOR", spellId) then
        self._pendingSunderUntil = GetTime() + ROTATION_LOCK
    end
end

local function CanAfford(state, key)
    return (tonumber(state.rage) or 0) >= Cost(state, key)
end

local function Ready(state, key)
    if not D:IsKnown(key)
        or CooldownRemaining(state, key) > 0.05
        or not CanAfford(state, key) then
        return false
    end
    if key == "REVENGE" then
        return state.revengeActive and true or false
    end
    return true
end

local function SetAction(action, key, reason, actionState, eta, uncertain, state)
    action.key = key
    action.name = D:GetName(key)
    action.texture = D:GetTexture(key)
    action.reason = reason or ""
    action.state = actionState or "ready"
    action.eta = eta
    action.uncertain = uncertain and true or false
    action.cost = Cost(state, key)
    action.timelineCycle = tonumber(P._cooldownCycle[key]) or 0
    action.timelineSlamCast = nil
    return action
end

local function ApplyGCD(action, state)
    if not action then return action end
    if action.key == "HEROIC_STRIKE"
        or action.key == "CLEAVE"
        or action.key == "SHIELD_BLOCK" then
        return action
    end
    if state.gcd and state.gcd > 0.05 and action.state == "ready" then
        action.state = "gcd"
        action.eta = state.gcd
    end
    return action
end

local function SetReadyAction(action, key, reason, state)
    SetAction(action, key, reason, "ready", nil, false, state)
    return ApplyGCD(action, state)
end

local function DemoralizingNeedsApply(state)
    if not RotationEnabled(state, "maintainDemoralizingShout")
        or not D:IsKnown("DEMORALIZING_SHOUT") then
        return false
    end
    if state.demoralizingShout then return false end
    local pending = tonumber(P._pendingDemoralizingUntil)
    return not pending or pending <= (tonumber(state.now) or GetTime())
end

local function ImmediateCoreReserve(state, window)
    window = tonumber(window) or ROTATION_LOCK
    local reserve = 0
    local mode = P:NormalizeMode(state.mode)
    local keys
    if mode == "aoe" then
        keys = {
            "THUNDER_CLAP",
            "CONCUSSION_BLOW",
            "SHIELD_SLAM",
            "REVENGE",
        }
    else
        keys = { "CONCUSSION_BLOW", "SHIELD_SLAM", "REVENGE" }
    end
    local index = 1
    while index <= table.getn(keys) do
        local key = keys[index]
        -- Explicit mapping avoids depending on localized names or camel-case
        -- behavior in the 1.12 Lua runtime.
        local option = key == "THUNDER_CLAP" and "useThunderClap"
            or key == "CONCUSSION_BLOW" and "useConcussionBlow"
            or key == "SHIELD_SLAM" and "useShieldSlam"
            or "useRevenge"
        if RotationEnabled(state, option)
            and D:IsKnown(key)
            and CooldownRemaining(state, key) <= window then
            if key ~= "REVENGE" or state.revengeActive then
                reserve = reserve + Cost(state, key)
            end
        end
        index = index + 1
    end
    return reserve
end

local function SunderNeeded(state, stacks)
    if RotationValue(state, "sunderStrategy") ~= "auto" then
        return false
    end
    local pending = tonumber(P._pendingSunderUntil)
    if pending and pending > (tonumber(state.now) or GetTime()) then
        return false
    end
    stacks = tonumber(stacks)
    if stacks == nil then
        stacks = tonumber(state.sunderStacks) or 0
    end
    local remaining = tonumber(state.sunderRemaining)
    return stacks < SUNDER_MAX_STACKS
        or (remaining ~= nil and remaining < SUNDER_REFRESH_WINDOW)
end

local function SunderCoreHoldUntil(state, window)
    window = tonumber(window) or ROTATION_LOCK
    local holdUntil = 0

    if RotationEnabled(state, "useConcussionBlow")
        and D:IsKnown("CONCUSSION_BLOW") then
        local remaining = Max(
            0,
            CooldownRemaining(state, "CONCUSSION_BLOW")
        )
        if remaining <= window then
            holdUntil = Max(holdUntil, remaining + ROTATION_LOCK)
        end
    end

    if RotationEnabled(state, "useShieldSlam")
        and D:IsKnown("SHIELD_SLAM") then
        local remaining = Max(
            0,
            CooldownRemaining(state, "SHIELD_SLAM")
        )
        if remaining <= window then
            holdUntil = Max(holdUntil, remaining + ROTATION_LOCK)
        end
    end

    return holdUntil
end

local function SunderCoreWindow(state)
    return ROTATION_LOCK
        + Max(0, tonumber(state.gcd) or 0)
end

local function DumpThreshold(state, key)
    local configured
    if key == "CLEAVE" then
        configured = RotationValue(state, "cleaveRage")
    else
        configured = RotationValue(state, "heroicRage")
    end
    local swing = state.swing
    local window = swing and tonumber(swing.remaining) or ROTATION_LOCK
    if window < ROTATION_LOCK then window = ROTATION_LOCK end
    local protected = Cost(state, key)
        + ImmediateCoreReserve(state, window)
    return Max(Clamp(configured or 60, 30, 100), protected)
end

local function ShouldUseDump(state)
    if IsOnSwingQueued(state) then return nil end
    local mode = P:NormalizeMode(state.mode)
    local key = mode == "aoe" and "CLEAVE" or "HEROIC_STRIKE"
    local option = mode == "aoe" and "useCleave" or "useHeroicStrike"
    if not RotationEnabled(state, option) or not D:IsKnown(key) then
        return nil
    end
    if (tonumber(state.rage) or 0) < DumpThreshold(state, key) then
        return nil
    end
    return key
end

local function ShieldBlockMinimumRage(state)
    return Clamp(
        RotationValue(state, "shieldBlockRage") or 35,
        20,
        100
    )
end

local function ShieldBlockStrategy(state)
    local strategy = RotationValue(state, "shieldBlockStrategy")
    if strategy == "revenge" or strategy == "mitigation" then
        return strategy
    end
    return "off"
end

local function ShieldBlockReason(state)
    if ShieldBlockStrategy(state) == "mitigation" then
        return R.SHIELD_BLOCK_MITIGATION
    end
    return R.SHIELD_BLOCK
end

local function ShouldUseShieldBlock(state)
    local strategy = ShieldBlockStrategy(state)
    if strategy == "off"
        or not state.targetingPlayer
        or state.shieldBlockBuff
        or state.improvedShieldSlamBuff
        or not Ready(state, "SHIELD_BLOCK") then
        return false
    end
    local minimum = ShieldBlockMinimumRage(state)
    if (tonumber(state.rage) or 0) < minimum then return false end
    if strategy == "revenge" then
        if state.revengeActive then return false end
        if RotationEnabled(state, "useShieldSlam")
            and CooldownRemaining(state, "SHIELD_SLAM") <= ROTATION_LOCK then
            return false
        end
    end
    return true
end

local function QueuedAction(action, state)
    local swing = state.swing
    if not swing then return nil end
    if swing.hsQueued then
        return SetAction(
            action,
            "HEROIC_STRIKE",
            R.QUEUED_HS,
            "queued",
            swing.remaining,
            false,
            state
        )
    elseif swing.cleaveQueued then
        return SetAction(
            action,
            "CLEAVE",
            R.QUEUED_CLEAVE,
            "queued",
            swing.remaining,
            false,
            state
        )
    end
    return nil
end

function P:Recommend(state)
    local action = self._rec

    if D.testMode then
        local testKeys = {
            "CONCUSSION_BLOW",
            "SHIELD_SLAM",
            "REVENGE",
            "THUNDER_CLAP",
        }
        local index = math.floor(GetTime() / 1.5)
        index = (index - (math.floor(index / 4) * 4)) + 1
        return SetAction(
            action,
            testKeys[index],
            zh and "测试模式：盾T图标自动轮换"
                or "Test mode: cycling tank recommendations",
            "ready",
            nil,
            false,
            state
        )
    end

    if not state.targetValid then
        return SetAction(
            action,
            "WAIT",
            D.Text.WAIT_TARGET,
            "disabled",
            nil,
            false,
            state
        )
    end

    if not state.hasShield then
        return SetAction(
            action,
            "WAIT",
            R.NO_SHIELD,
            "disabled",
            nil,
            false,
            state
        )
    end

    if tonumber(state.stance) ~= 2 then
        return SetReadyAction(
            action,
            "DEFENSIVE_STANCE",
            R.DEFENSIVE_STANCE,
            state
        )
    end

    if not state.inMelee then
        return SetAction(
            action,
            "WAIT",
            D.Text.OUT_OF_RANGE,
            "range",
            nil,
            false,
            state
        )
    end

    local mode = self:NormalizeMode(state.mode)
    local dumpKey = ShouldUseDump(state)

    -- On-swing attacks can be armed during the GCD. Doing this before the
    -- normal core checks prevents the macro from repeatedly retrying a spell
    -- that cannot yet fire while rage is already near the cap.
    if state.gcd and state.gcd > 0.05 then
        -- Shield Block is usable during the GCD. Check it before the queued
        -- on-swing state, otherwise a pending Heroic Strike or Cleave can
        -- starve automatic Shield Block for an entire swing and immediately
        -- queue another dump on the following press.
        if ShouldUseShieldBlock(state) then
            return SetReadyAction(
                action,
                "SHIELD_BLOCK",
                ShieldBlockReason(state),
                state
            )
        end
        if dumpKey then
            return SetAction(
                action,
                dumpKey,
                dumpKey == "CLEAVE" and R.CLEAVE or R.HEROIC_STRIKE,
                "queue",
                nil,
                false,
                state
            )
        end
        local queued = QueuedAction(action, state)
        if queued then return queued end
    end

    local revengeRemaining = tonumber(state.revengeRemaining)
    if RotationEnabled(state, "useRevenge")
        and Ready(state, "REVENGE")
        and revengeRemaining
        and revengeRemaining <= (ROTATION_LOCK + 0.15) then
        return SetReadyAction(
            action,
            "REVENGE",
            R.REVENGE_EXPIRING,
            state
        )
    end

    -- Active mitigation is an explicit high-pressure policy. Once an
    -- expiring Revenge has been secured above, use off-GCD Shield Block before
    -- ordinary threat actions; the following key press can still cast the GCD
    -- skill without losing a full rotation slot.
    if ShieldBlockStrategy(state) == "mitigation"
        and ShouldUseShieldBlock(state) then
        return SetReadyAction(
            action,
            "SHIELD_BLOCK",
            ShieldBlockReason(state),
            state
        )
    end

    -- Apart from an expiring Revenge window above, AoE uses Concussion Blow
    -- as its highest-priority GCD threat action. Stance changes and off-GCD
    -- Shield Block handling remain separate.
    if mode == "aoe"
        and RotationEnabled(state, "useConcussionBlow")
        and Ready(state, "CONCUSSION_BLOW") then
        return SetReadyAction(
            action,
            "CONCUSSION_BLOW",
            R.CONCUSSION_BLOW,
            state
        )
    end

    if mode == "aoe" and RotationEnabled(state, "useThunderClap")
        and Ready(state, "THUNDER_CLAP") then
        return SetReadyAction(action, "THUNDER_CLAP", R.THUNDER_CLAP, state)
    end

    if DemoralizingNeedsApply(state)
        and Ready(state, "DEMORALIZING_SHOUT") then
        return SetReadyAction(
            action,
            "DEMORALIZING_SHOUT",
            R.DEMORALIZING_SHOUT,
            state
        )
    end

    if mode ~= "aoe"
        and RotationEnabled(state, "useConcussionBlow")
        and Ready(state, "CONCUSSION_BLOW") then
        return SetReadyAction(
            action,
            "CONCUSSION_BLOW",
            R.CONCUSSION_BLOW,
            state
        )
    end

    if RotationEnabled(state, "useShieldSlam")
        and Ready(state, "SHIELD_SLAM") then
        return SetReadyAction(action, "SHIELD_SLAM", R.SHIELD_SLAM, state)
    end

    if RotationEnabled(state, "useRevenge")
        and Ready(state, "REVENGE") then
        return SetReadyAction(action, "REVENGE", R.REVENGE, state)
    end

    if mode == "single" and RotationEnabled(state, "useThunderClap")
        and Ready(state, "THUNDER_CLAP") then
        return SetReadyAction(action, "THUNDER_CLAP", R.THUNDER_CLAP, state)
    end

    if dumpKey then
        return SetAction(
            action,
            dumpKey,
            dumpKey == "CLEAVE" and R.CLEAVE or R.HEROIC_STRIKE,
            "queue",
            nil,
            false,
            state
        )
    end

    if ShouldUseShieldBlock(state) then
        return SetReadyAction(
            action,
            "SHIELD_BLOCK",
            ShieldBlockReason(state),
            state
        )
    end

    if SunderNeeded(state)
        and SunderCoreHoldUntil(
            state,
            SunderCoreWindow(state)
        ) <= 0
        and Ready(state, "SUNDER_ARMOR") then
        return SetReadyAction(
            action,
            "SUNDER_ARMOR",
            R.SUNDER_STACK,
            state
        )
    end

    local queued = QueuedAction(action, state)
    if queued then return queued end

    if state.gcd and state.gcd > 0.05 then
        return SetAction(
            action,
            "WAIT",
            D.Text.WAIT_GCD,
            "gcd",
            state.gcd,
            false,
            state
        )
    end

    if state.swing and state.swing.active and state.swing.remaining then
        return SetAction(
            action,
            "AUTO_ATTACK",
            R.WAIT_SWING,
            "wait",
            state.swing.remaining,
            false,
            state
        )
    end

    if (tonumber(state.rage) or 0) < 10 then
        return SetAction(
            action,
            "WAIT",
            R.WAIT_RAGE,
            "pool",
            nil,
            false,
            state
        )
    end

    return SetAction(
        action,
        "WAIT",
        R.WAIT_CD,
        "wait",
        nil,
        false,
        state
    )
end

local FORECAST_PRIORITY_SINGLE = {
    DEFENSIVE_STANCE = 1,
    MITIGATION_SHIELD_BLOCK = 2,
    CONCUSSION_BLOW = 3,
    SHIELD_SLAM = 4,
    REVENGE = 5,
    SHIELD_BLOCK = 6,
    THUNDER_CLAP = 7,
    HEROIC_STRIKE = 8,
    SUNDER_ARMOR = 9,
    DEMORALIZING_SHOUT = 10,
}

local FORECAST_PRIORITY_AOE = {
    DEFENSIVE_STANCE = 1,
    MITIGATION_SHIELD_BLOCK = 2,
    CONCUSSION_BLOW = 3,
    THUNDER_CLAP = 4,
    DEMORALIZING_SHOUT = 5,
    SHIELD_SLAM = 6,
    REVENGE = 7,
    SHIELD_BLOCK = 8,
    CLEAVE = 9,
    SUNDER_ARMOR = 10,
}

local function ClearArray(value)
    local index = table.getn(value)
    while index >= 1 do
        value[index] = nil
        index = index - 1
    end
end

local function ForecastActionLock(state, current)
    if not current or not current.key then
        return tonumber(state.gcd) or 0
    end
    if current.key == "DEFENSIVE_STANCE" then
        return Max(tonumber(state.gcd), STANCE_LOCK)
    elseif current.key == "HEROIC_STRIKE"
        or current.key == "CLEAVE"
        or current.key == "SHIELD_BLOCK" then
        return QUEUE_LOCK
    elseif current.key ~= "WAIT"
        and current.key ~= "AUTO_ATTACK" then
        return Max(tonumber(state.gcd), ROTATION_LOCK)
    end
    return tonumber(state.gcd) or 0
end

local function ForecastReadyAt(state, key, current)
    local readyAt = CooldownRemaining(state, key)
    local cycleOffset = 0
    if current and current.key == key then
        local duration = CooldownDuration(state, key)
        if duration then
            readyAt = (tonumber(state.gcd) or 0) + duration
            cycleOffset = 1
        end
    end
    return readyAt, cycleOffset
end

local function AddForecastCandidate(
    candidates,
    seen,
    state,
    key,
    eta,
    priority,
    uncertain,
    cycleOffset,
    reason
)
    if not key or seen[key] or not D:IsKnown(key) then return end
    seen[key] = true
    candidates[table.getn(candidates) + 1] = {
        key = key,
        name = D:GetName(key),
        texture = D:GetTexture(key),
        reason = reason or R[key] or "",
        state = "forecast",
        eta = Max(0, eta),
        priority = tonumber(priority) or 9,
        uncertain = uncertain and true or false,
        cost = Cost(state, key),
        timelineCycle = (tonumber(P._cooldownCycle[key]) or 0)
            + (tonumber(cycleOffset) or 0),
        timelineSlamCast = nil,
    }
end

local function AddCoreForecast(
    candidates,
    seen,
    state,
    current,
    key,
    option,
    cursor,
    priority
)
    if not RotationEnabled(state, option) then return end
    if key == "REVENGE" and not state.revengeActive then return end
    local readyAt, cycle = ForecastReadyAt(state, key, current)
    AddForecastCandidate(
        candidates,
        seen,
        state,
        key,
        Max(cursor, readyAt),
        priority,
        (tonumber(state.rage) or 0) < Cost(state, key),
        cycle
    )
end

local function AddShieldBlockForecast(
    candidates,
    seen,
    state,
    current,
    cursor,
    projectedRage,
    projectedStance,
    priority
)
    local strategy = ShieldBlockStrategy(state)
    if strategy == "off" or not D:IsKnown("SHIELD_BLOCK") then
        return
    end
    local mitigation = strategy == "mitigation"

    local currentKey = current and current.key or nil
    local readyAt, cycle = ForecastReadyAt(
        state,
        "SHIELD_BLOCK",
        current
    )
    local eta = Max(QUEUE_LOCK, readyAt)
    local uncertain = false
    local conditionalDelay = Max(cursor, ROTATION_LOCK)

    -- These conditions block an immediate cast, but most are transient. Keep
    -- Shield Block on the timeline and mark it conditional instead of deleting
    -- it from the forecast altogether.
    if projectedStance ~= 2 or not state.targetingPlayer then
        eta = Max(eta, conditionalDelay)
        uncertain = true
    end
    if not mitigation
        and state.revengeActive
        and currentKey ~= "REVENGE" then
        eta = Max(eta, conditionalDelay)
        uncertain = true
    end
    if state.shieldBlockBuff then
        eta = Max(
            eta,
            tonumber(state.shieldBlockRemaining) or conditionalDelay
        )
        uncertain = true
    end
    if state.improvedShieldSlamBuff then
        eta = Max(eta, conditionalDelay)
        uncertain = true
    end

    if RotationEnabled(state, "useShieldSlam") then
        local shieldSlamReady = CooldownRemaining(state, "SHIELD_SLAM")
        if currentKey == "SHIELD_SLAM" then
            -- The current Shield Slam can create its own block layer. The
            -- exact consumption time depends on the next incoming attack.
            eta = Max(eta, cursor)
            uncertain = true
        elseif not mitigation and shieldSlamReady <= ROTATION_LOCK then
            eta = Max(eta, shieldSlamReady + QUEUE_LOCK)
            uncertain = true
        end
    end

    if projectedRage < ShieldBlockMinimumRage(state) then
        eta = Max(eta, conditionalDelay)
        uncertain = true
    end

    AddForecastCandidate(
        candidates,
        seen,
        state,
        "SHIELD_BLOCK",
        eta,
        priority,
        uncertain,
        cycle,
        ShieldBlockReason(state)
    )
end

function P:BuildForecast(state, current)
    local output = self._forecast
    local candidates = self._forecastCandidates
    ClearArray(output)
    ClearArray(candidates)

    if not state.targetValid or not state.hasShield then
        return output
    end

    local seen = {}
    local cursor = ForecastActionLock(state, current)
    local currentKey = current and current.key or nil
    local projectedRage = tonumber(state.rage) or 0
    local projectedSunderStacks = tonumber(state.sunderStacks) or 0
    local projectedStance = tonumber(state.stance) or 0
    local mode = self:NormalizeMode(state.mode)
    local priorities = mode == "aoe"
        and FORECAST_PRIORITY_AOE or FORECAST_PRIORITY_SINGLE

    if currentKey == "DEFENSIVE_STANCE" then
        projectedStance = 2
    elseif currentKey and currentKey ~= "WAIT"
        and currentKey ~= "AUTO_ATTACK" then
        projectedRage = projectedRage - Cost(state, currentKey)
        if projectedRage < 0 then projectedRage = 0 end
    end
    if currentKey == "SUNDER_ARMOR" then
        projectedSunderStacks = projectedSunderStacks + 1
    end

    if projectedStance ~= 2 and currentKey ~= "DEFENSIVE_STANCE" then
        AddForecastCandidate(
            candidates,
            seen,
            state,
            "DEFENSIVE_STANCE",
            cursor,
            priorities.DEFENSIVE_STANCE,
            false,
            0
        )
    end

    if not state.inMelee then
        local index = 1
        while index <= table.getn(candidates)
            and table.getn(output) < FORECAST_LIMIT do
            output[table.getn(output) + 1] = candidates[index]
            index = index + 1
        end
        return output
    end

    if mode == "aoe" then
        AddCoreForecast(
            candidates, seen, state, current, "THUNDER_CLAP",
            "useThunderClap", cursor, priorities.THUNDER_CLAP
        )
        if DemoralizingNeedsApply(state)
            and currentKey ~= "DEMORALIZING_SHOUT" then
            AddForecastCandidate(
                candidates,
                seen,
                state,
                "DEMORALIZING_SHOUT",
                cursor,
                priorities.DEMORALIZING_SHOUT,
                projectedRage < Cost(state, "DEMORALIZING_SHOUT"),
                0
            )
        end
    end

    AddCoreForecast(
        candidates, seen, state, current, "CONCUSSION_BLOW",
        "useConcussionBlow", cursor, priorities.CONCUSSION_BLOW
    )
    AddCoreForecast(
        candidates, seen, state, current, "SHIELD_SLAM",
        "useShieldSlam", cursor, priorities.SHIELD_SLAM
    )
    local revengePriority = priorities.REVENGE
    local revengeRemaining = tonumber(state.revengeRemaining)
    if revengeRemaining
        and revengeRemaining <= (ROTATION_LOCK + 0.15) then
        revengePriority = 1
    end
    AddCoreForecast(
        candidates, seen, state, current, "REVENGE",
        "useRevenge", cursor, revengePriority
    )

    if mode == "single" then
        AddCoreForecast(
            candidates, seen, state, current, "THUNDER_CLAP",
            "useThunderClap", cursor, priorities.THUNDER_CLAP
        )
        if DemoralizingNeedsApply(state)
            and currentKey ~= "DEMORALIZING_SHOUT" then
            AddForecastCandidate(
                candidates,
                seen,
                state,
                "DEMORALIZING_SHOUT",
                cursor,
                priorities.DEMORALIZING_SHOUT,
                projectedRage < Cost(state, "DEMORALIZING_SHOUT"),
                0
            )
        end
    end

    local dumpKey = mode == "aoe" and "CLEAVE" or "HEROIC_STRIKE"
    local dumpOption = mode == "aoe" and "useCleave" or "useHeroicStrike"
    if RotationEnabled(state, dumpOption)
        and currentKey ~= dumpKey
        and not IsOnSwingQueued(state)
        and projectedRage >= DumpThreshold(state, dumpKey) then
        AddForecastCandidate(
            candidates,
            seen,
            state,
            dumpKey,
            cursor,
            priorities[dumpKey],
            false,
            0
        )
    end

    local shieldBlockPriority = priorities.SHIELD_BLOCK
    if ShieldBlockStrategy(state) == "mitigation" then
        shieldBlockPriority = priorities.MITIGATION_SHIELD_BLOCK
    end
    AddShieldBlockForecast(
        candidates,
        seen,
        state,
        current,
        cursor,
        projectedRage,
        projectedStance,
        shieldBlockPriority
    )

    if SunderNeeded(state, projectedSunderStacks)
        and not (currentKey == "SUNDER_ARMOR"
            and projectedSunderStacks >= SUNDER_MAX_STACKS) then
        -- Sunder is a true filler. When Concussion Blow or Shield Slam will
        -- be ready within one GCD, schedule Sunder only after that core slot.
        local sunderEta = Max(
            cursor,
            SunderCoreHoldUntil(
                state,
                cursor + ROTATION_LOCK
            )
        )
        AddForecastCandidate(
            candidates,
            seen,
            state,
            "SUNDER_ARMOR",
            sunderEta,
            priorities.SUNDER_ARMOR,
            projectedRage < Cost(state, "SUNDER_ARMOR"),
            0,
            R.SUNDER_STACK
        )
    end

    table.sort(candidates, function(left, right)
        local leftEta = tonumber(left.eta) or 0
        local rightEta = tonumber(right.eta) or 0
        if math.abs(leftEta - rightEta) > 0.01 then
            return leftEta < rightEta
        end
        return (tonumber(left.priority) or 9)
            < (tonumber(right.priority) or 9)
    end)

    local nextFree = 0
    local index = 1
    while index <= table.getn(candidates)
        and table.getn(output) < FORECAST_LIMIT do
        local candidate = candidates[index]
        local scheduled = Max(candidate.eta, nextFree)
        candidate.eta = scheduled
        output[table.getn(output) + 1] = candidate
        if candidate.key == "DEFENSIVE_STANCE" then
            nextFree = scheduled + STANCE_LOCK
        elseif candidate.key == "HEROIC_STRIKE"
            or candidate.key == "CLEAVE" then
            nextFree = scheduled + QUEUE_LOCK
        elseif candidate.key == "SHIELD_BLOCK" then
            nextFree = scheduled + QUEUE_LOCK
        else
            nextFree = scheduled + ROTATION_LOCK
        end
        index = index + 1
    end
    return output
end

function P:Evaluate(state)
    local recommendation = self:Recommend(state)
    state.resourceActions = nil
    return recommendation, self:BuildForecast(state, recommendation)
end

local function CastRecommendedAction(action)
    if action.key == "HEROIC_STRIKE"
        or action.key == "CLEAVE"
        or action.key == "SHIELD_BLOCK" then
        -- Native on-swing attacks and off-GCD Shield Block must not enter
        -- Nampower's generic spell queue. A queued Shield Block could replace
        -- the next core skill instead of firing immediately.
        if CastSpellByNameNoQueue then
            CastSpellByNameNoQueue(action.name)
        else
            CastSpellByName(action.name)
        end
    else
        CastSpellByName(action.name)
    end
end

local function DebugExecute(mode, state, action, result)
    if not D.debugMode then return end
    D:Print(string.format(
        "execute profile=protection mode=%s action=%s state=%s rage=%d stance=%d shield=%s melee=%s sunder=%d revenge=%s result=%s",
        tostring(mode),
        tostring(action and action.name or "none"),
        tostring(action and action.state or "none"),
        tonumber(state and state.rage) or 0,
        tonumber(state and state.stance) or 0,
        tostring(state and state.hasShield == true),
        tostring(state and state.inMelee == true),
        tonumber(state and state.sunderStacks) or 0,
        tostring(state and state.revengeActive == true),
        tostring(result)
    ))
end

function P:Execute(mode)
    mode = self:NormalizeMode(mode)
    D:SetMode(mode, true)
    local state = D:BuildState()
    local targetChanged = D:PrepareExecutionTarget(
        true,
        true,
        state.meleeRangeKey
    )
    if targetChanged or not state.targetValid then
        state = D:BuildState()
    end
    local action = self:Recommend(state)

    if not action or not action.key
        or action.key == "WAIT"
        or action.key == "AUTO_ATTACK"
        or not D:IsKnown(action.key) then
        DebugExecute(mode, state, action, "wait")
        D:Update(true)
        return false
    end

    if (action.key == "HEROIC_STRIKE" or action.key == "CLEAVE")
        and IsOnSwingQueued(state) then
        DebugExecute(mode, state, action, "on-swing-already-queued")
        D:Update(true)
        return false
    end

    DebugExecute(mode, state, action, "cast")
    CastRecommendedAction(action)
    if action.key == "HEROIC_STRIKE" or action.key == "CLEAVE" then
        D:MarkOnSwingQueued(action.key, state.swing)
    elseif action.key == "SUNDER_ARMOR" then
        -- Aura stack updates can trail a successful cast by one refresh.
        -- Hold duplicate generic-queue attempts until the current GCD ends;
        -- the spell event refreshes this guard when the cast is confirmed.
        self._pendingSunderUntil = GetTime() + ROTATION_LOCK
    elseif action.state == "ready"
        and CooldownDuration(state, action.key) then
        RecordPredictedCooldown(action.key, state)
    elseif action.state == "ready"
        and action.key == "DEMORALIZING_SHOUT" then
        self._pendingDemoralizingUntil = GetTime() + ROTATION_LOCK
    end

    D:Update(true)
    return true
end
