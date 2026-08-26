-- ============================================================================
-- DoiteDPS - two-handed deep Arms Warrior
--
-- One single-target and one AoE rotation share the same Berserker-home engine.
-- Instant attacks lead only when Slam still fits afterward; Slam is used at most once
-- and may delay the next white hit by the configured limit. During Execute, efficient
-- core attacks spend first only when Execute can still land before that hit.
-- ============================================================================

local D = DoiteDPS
local P = {}
D.Profiles.WarriorArms = P

P.key = "WARRIOR_ARMS"
P.CooldownKeys = D.WarriorCooldownKeys

local locale = (GetLocale and GetLocale()) or "enUS"
local zh = locale == "zhCN" or locale == "zhTW"
local UNBRIDLED_WRATH = zh and "怒不可遏" or "Unbridled Wrath"
local UNBRIDLED_WRATH_RAGE_PER_RANK = 0.30

P.ModeOrder = { "single", "aoe" }
P.ModeLabels = {
    single = zh and "双手武器战" or "Two-Handed Arms Warrior",
    aoe = zh and "双手武器战" or "Two-Handed Arms Warrior",
}
P.EntryOrder = { "single", "aoe" }
P.EntryPoints = {
    single = {
        label = zh and "单体出口" or "Single output",
        modes = { "single" },
        default = "single",
        version = 2,
        migrations = { battle = "single" },
    },
    aoe = {
        label = zh and "AOE出口" or "AoE output",
        modes = { "aoe" },
        default = "aoe",
        version = 2,
        migrations = { battle_aoe = "aoe" },
    },
}
P.ModeNotes = {
    single = zh
        and "常驻狂暴姿态；瞬发后仍能接猛击时优先致死/旋风，否则先打安全猛击；斩杀贴近下一刀清怒。"
        or "Berserker home; lead with instants only when Slam still fits, then Execute late in the swing.",
    aoe = zh
        and "横扫后回狂暴姿态；旋风、致死、安全猛击优先，顺劈预留核心怒气，斩杀补空档。"
        or "Sweeping into Berserker; Whirlwind, Mortal Strike and safe Slam lead, with reserved Cleave dumps.",
}

P.RotationDefaults = {
    single = {
        slamClip = 0.17,
        executeSwingWindow = 0.35,
        maintainBattleShout = true,
        battleShoutRefresh = 10,
        maintainSunder = false,
    },
    aoe = {
        executeSwingWindow = 0.35,
        maintainBattleShout = true,
        battleShoutRefresh = 10,
        maintainSunder = false,
        useSweepingStrikes = true,
        cleaveRage = 95,
    },
}

P.ConfigSchema = {
    title = zh and "双手武器战" or "Two-Handed Arms Warrior",
    modes = {
        { key = "single", label = P.ModeLabels.single, note = P.ModeNotes.single },
        { key = "aoe", label = P.ModeLabels.aoe, note = P.ModeNotes.aoe },
    },
    options = {
        {
            type = "number",
            section = zh and "白字节奏" or "Swing timing",
            key = "slamClip",
            label = zh and "猛击最大卡条" or "Maximum Slam swing delay",
            modes = { "single" },
            min = 0,
            max = 0.30,
            step = 0.01,
            suffix = zh and "秒" or "s",
            format = "%.2f",
        },
        {
            type = "number",
            key = "executeSwingWindow",
            label = zh and "斩杀贴刀窗口" or "Execute before-swing window",
            modes = { "single", "aoe" },
            min = 0.10,
            max = 0.80,
            step = 0.05,
            suffix = zh and "秒" or "s",
            format = "%.2f",
        },
        {
            type = "toggle",
            section = zh and "多目标" or "Multi-target",
            key = "useSweepingStrikes",
            label = zh and "横扫攻击参与循环" or "Use Sweeping Strikes",
            modes = { "aoe" },
        },
        {
            type = "number",
            key = "cleaveRage",
            label = zh and "顺劈斩怒气线" or "Cleave rage",
            modes = { "aoe" },
            min = 20,
            max = 130,
            step = 5,
            format = "%d",
        },
        {
            type = "toggle",
            section = zh and "辅助" or "Utility",
            key = "maintainBattleShout",
            label = zh and "维持战斗怒吼" or "Maintain Battle Shout",
            modes = { "single", "aoe" },
        },
        {
            type = "number",
            key = "battleShoutRefresh",
            label = zh and "战吼提前刷新" or "Battle Shout refresh",
            modes = { "single", "aoe" },
            min = 0,
            max = 30,
            step = 5,
            suffix = zh and "秒" or "s",
            format = "%d",
            visibleWhen = { key = "maintainBattleShout", value = true },
        },
        {
            type = "toggle",
            key = "maintainSunder",
            label = zh and "自动维持破甲（5秒补）"
                or "Maintain Sunder Armor (refresh below 5s)",
            modes = { "single", "aoe" },
        },
        {
            type = "toggle",
            scope = "general",
            section = zh and "装备效果" or "Equipment effects",
            key = "tier3TwoPiece",
            label = zh and "T3两件套（横扫/死亡之愿减10怒）"
                or "Tier 3 two-piece (-10 Sweeping/Death Wish rage)",
            modes = { "single", "aoe" },
        },
    },
}

function P:NormalizeMode(mode)
    if mode == "aoe" or mode == "battle_aoe" then return "aoe" end
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
    if not D.GetRotationDB then return defaults end

    local profileDB = D:GetProfileDB(self.key)
    local version = tonumber(profileDB.deepArmsRotationVersion) or 0
    if version < 1 then
        -- The removed stance/Fury-era knobs do not describe this rotation.
        profileDB.rotations = { single = {}, aoe = {} }
        version = 1
    end
    if version < 2 then
        local aoe = profileDB.rotations and profileDB.rotations.aoe
        local cleaveRage = aoe and tonumber(aoe.cleaveRage) or 0
        if aoe and cleaveRage < self.RotationDefaults.aoe.cleaveRage then
            aoe.cleaveRage = self.RotationDefaults.aoe.cleaveRage
        end
        version = 2
    end
    profileDB.deepArmsRotationVersion = version
    return D:GetRotationDB(self.key, mode, defaults)
end

local R = {
    EXECUTE = zh and "贴近下一次白字清空剩余怒气" or "Dump rage just before the next white hit",
    EXECUTE_NOW = zh and "目标即将死亡，立即斩杀" or "Target is about to die - Execute now",
    OVERPOWER = zh and "低怒压制触发" or "Low-rage Overpower proc",
    MORTAL_STRIKE = zh and "致死打击瞬发槽" or "Mortal Strike instant slot",
    WHIRLWIND = zh and "旋风斩瞬发槽" or "Whirlwind instant slot",
    SLAM = zh and "猛击处于允许卡条窗口" or "Slam fits the allowed swing delay",
    HEROIC_STRIKE = zh and "下一刀将溢怒，排队英勇打击" or "Next white hit would cap rage",
    CLEAVE = zh and "预留核心怒气后排队顺劈" or "Queue Cleave after reserving core rage",
    SWEEPING_STRIKES = zh and "开启横扫攻击" or "Activate Sweeping Strikes",
    BATTLE_SHOUT = zh and "维持战斗怒吼" or "Maintain Battle Shout",
    SUNDER_ARMOR = zh and "首次施加或剩余不足5秒时补破甲"
        or "Apply Sunder Armor or refresh it below 5 seconds",
    BATTLE_STANCE = zh and "切换战斗姿态" or "Enter Battle Stance",
    BERSERKER_STANCE = zh and "回到狂暴姿态" or "Return to Berserker Stance",
    QUEUED_HS = zh and "英勇打击已排队" or "Heroic Strike queued",
    QUEUED_CLEAVE = zh and "顺劈斩已排队" or "Cleave queued",
    WAIT_SWING = zh and "等待下一次白字" or "Wait for the next white hit",
    WAIT_RAGE = zh and "等待白字回怒" or "Wait for white-hit rage",
    WAIT_CD = zh and "等待核心技能" or "Wait for core cooldowns",
    FORECAST = zh and "预计可用" or "Expected ready",
}

P._rec = D.Recommendation
P._forecast = D.Forecasts
P._candidates = {}
P._cooldownUntil = {}
P._cooldownCycle = {}
P._apiCooldownActive = {}

local FORECAST_LIMIT = D.FORECAST_LIMIT or 3
local GCD_LOCK = 1.5
local STANCE_RAGE = 25
local EXECUTE_INTERRUPT_MARGIN = 0.20
local BASE_COOLDOWNS = {
    MORTAL_STRIKE = 6,
    OVERPOWER = 5,
    WHIRLWIND = 10,
    SWEEPING_STRIKES = 30,
}

local PRIORITY = {
    EXECUTE = 1,
    OVERPOWER = 2,
    SWEEPING_STRIKES = 3,
    MORTAL_STRIKE = 4,
    WHIRLWIND = 5,
    SLAM = 6,
    CLEAVE = 7,
}

local function Cost(state, key)
    local def = D:GetSpellDef(key)
    local cost = def and tonumber(def.cost) or 0
    if state and state.tier3TwoPiece
        and (key == "SWEEPING_STRIKES" or key == "DEATH_WISH") then
        cost = cost - 10
    end
    return math.max(0, cost)
end
P._rageCost = Cost

local function RotationValue(state, key)
    if state and state.rotationDB and state.rotationDB[key] ~= nil then
        return state.rotationDB[key]
    end
    local defaults = P.RotationDefaults[P:NormalizeMode(state and state.mode)]
    return defaults and defaults[key] or nil
end

local function SetAction(action, key, reason, actionState, eta, uncertain)
    action.key = key
    action.name = D:GetName(key)
    action.texture = D:GetTexture(key)
    action.reason = reason or ""
    action.state = actionState or "ready"
    action.eta = eta
    action.uncertain = uncertain and true or false
    action.timelineCycle = tonumber(P._cooldownCycle[key]) or 0
    action.timelineSlamCast = nil
    return action
end

local function ApplyGCD(action, state)
    if not action or action.key == "HEROIC_STRIKE" or action.key == "CLEAVE" then
        return action
    end
    if (tonumber(state.gcd) or 0) > 0.05 and action.state == "ready" then
        action.state = "gcd"
        action.eta = state.gcd
    end
    return action
end

local function StanceAction(action, key, reason, state)
    return ApplyGCD(SetAction(action, key, reason, "ready"), state)
end

local function IsOnSwingQueued(state)
    local swing = state and state.swing
    return swing and (swing.hsQueued or swing.cleaveQueued or swing.queuePending)
        or false
end

local function IsCleaveQueued(state)
    local swing = state and state.swing
    return swing and (swing.cleaveQueued
        or (swing.queuePending and swing.pendingKey == "CLEAVE")) or false
end

local function AvailableRage(state)
    local rage = tonumber(state and state.rage) or 0
    if P:NormalizeMode(state and state.mode) == "aoe"
        and IsCleaveQueued(state) then
        rage = rage - Cost(state, "CLEAVE")
    end
    if rage < 0 then return 0 end
    return rage
end

local function NeedsStance(state, stance)
    local current = tonumber(state and state.stance) or 0
    return current > 0 and current ~= stance
end

local function SpellEventMatches(key, spellId)
    spellId = tonumber(spellId)
    local spell = D.Spells and D.Spells[key]
    if spellId and spell and tonumber(spell.spellId) == spellId then
        return true
    end
    if not spellId then return false end

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

local function CooldownRemaining(state, key)
    local now = tonumber(state and state.now) or GetTime()
    local entry = state and state.cooldowns and state.cooldowns[key]
    local apiRemaining = entry and tonumber(entry.remaining) or nil
    local apiDuration = entry and tonumber(entry.duration) or nil
    if apiRemaining == nil then
        apiRemaining, apiDuration = D:GetRealCooldown(key, now)
    end
    apiRemaining = tonumber(apiRemaining) or 0
    apiDuration = tonumber(apiDuration) or 0

    if apiDuration > (D.GCD_MAX or 1.5) and apiRemaining > 0.05 then
        if not P._apiCooldownActive[key] then
            P._cooldownCycle[key] =
                (tonumber(P._cooldownCycle[key]) or 0) + 1
        end
        P._apiCooldownActive[key] = true
        P._cooldownUntil[key] = now + apiRemaining
    end

    local predicted = P._cooldownUntil[key]
    predicted = predicted and predicted - now or 0
    if predicted <= 0.05 then
        P._cooldownUntil[key] = nil
        P._apiCooldownActive[key] = false
        predicted = 0
    end
    if predicted > apiRemaining then return predicted end
    return apiRemaining
end

local function Ready(state, key)
    return D:IsKnown(key)
        and AvailableRage(state) >= Cost(state, key)
        and CooldownRemaining(state, key) <= 0.05
end

local function RecordPredictedCooldown(key)
    local duration = BASE_COOLDOWNS[key]
    if not duration then return end
    local deadline = GetTime() + duration
    local existing = P._cooldownUntil[key]
    if not existing or existing < (deadline - 0.50) then
        P._cooldownUntil[key] = deadline
        P._cooldownCycle[key] =
            (tonumber(P._cooldownCycle[key]) or 0) + 1
        P._apiCooldownActive[key] = true
    end
end

local function ReadNumber(fn, arg1, arg2)
    if type(fn) ~= "function" then return nil end
    local ok, value = pcall(fn, arg1, arg2)
    if not ok then return nil end
    return tonumber(value)
end

local function TalentRankByName(tabIndex, wantedName)
    if type(GetTalentInfo) ~= "function" then return 0 end
    local index = 1
    while index <= 30 do
        local ok, name, icon, tier, column, rank = pcall(
            GetTalentInfo,
            tabIndex,
            index
        )
        if not ok or not name then break end
        if name == wantedName then return tonumber(rank) or 0 end
        index = index + 1
    end
    return 0
end

function P:GetUnbridledWrathRank()
    if self._unbridledWrathRank == nil then
        self._unbridledWrathRank = TalentRankByName(2, UNBRIDLED_WRATH)
    end
    return self._unbridledWrathRank
end

local function ExpectedWhiteRage(damage, speed, critChance, unbridledWrathRank)
    local crit = math.max(0, math.min(100, tonumber(critChance) or 0)) / 100
    local talentRank = math.max(
        0,
        math.min(5, tonumber(unbridledWrathRank) or 0)
    )
    local damageRage = ((damage / 230.6) * 7.5 / 1.075)
    return damageRage * (1 + crit)
        + (speed * 3.5 / 2.25)
        + talentRank * UNBRIDLED_WRATH_RAGE_PER_RANK
end
P._expectedWhiteRage = ExpectedWhiteRage

local function EstimateNextWhiteRage(unbridledWrathRank)
    if type(GetEquippedItem) ~= "function"
        or type(GetItemStatsField) ~= "function"
        or type(GetUnitField) ~= "function" then
        return nil
    end

    local ok, weapon = pcall(GetEquippedItem, "player", 16)
    if not ok or not weapon then return nil end
    local itemId = type(weapon) == "table" and weapon.itemId or tonumber(weapon)
    if not itemId then return nil end

    local delay = ReadNumber(GetItemStatsField, itemId, "delay")
    local minimum = ReadNumber(GetUnitField, "player", "minDamage")
    local maximum = ReadNumber(GetUnitField, "player", "maxDamage")
    if not delay or delay <= 0 or not minimum or not maximum then return nil end

    local speed = delay / 1000
    local damage = (minimum + maximum) / 2
    local crit = BCS and ReadNumber(BCS.GetCritChance, BCS) or nil
    local rage = ExpectedWhiteRage(damage, speed, crit, unbridledWrathRank)
    if rage < 0 then return nil end
    return math.floor(rage + 0.5)
end

function P:ResetRuntime()
    self._cooldownUntil = {}
    self._cooldownCycle = {}
    self._apiCooldownActive = {}
    self._lastSwingProgress = nil
    self._slamUsedInCycle = false
    self._returnHomeAfterOverpower = false
    self._pendingSunderUntil = nil
    self._unbridledWrathRank = nil
end

function P:ObserveSwingCycle(swing)
    if not swing or not swing.active then
        self._lastSwingProgress = nil
        self._slamUsedInCycle = false
        if swing then swing.slamUsed = false end
        return
    end

    local progress = tonumber(swing.progress)
    if not progress then
        local speed = tonumber(swing.speed)
        local remaining = tonumber(swing.remaining)
        if speed and speed > 0 and remaining then
            progress = (speed - remaining) / speed
        end
    end

    local previous = tonumber(self._lastSwingProgress)
    if progress and previous and progress < (previous - 0.50) then
        self._slamUsedInCycle = false
    end
    if progress then self._lastSwingProgress = progress end
    swing.slamUsed = self._slamUsedInCycle == true
end

function P:OnEvent(eventName, a1, a2)
    if eventName == "PLAYER_ENTERING_WORLD" then
        self:ResetRuntime()
        return
    end
    if eventName == "SPELLS_CHANGED"
        or eventName == "CHARACTER_POINTS_CHANGED"
        or eventName == "PLAYER_TALENT_UPDATE" then
        self._unbridledWrathRank = nil
        return
    end

    local spellId = nil
    if eventName == "SPELL_CAST_EVENT" and tonumber(a1) == 1 then
        spellId = a2
    elseif eventName == "SPELL_GO_SELF" and (tonumber(a1) or 0) == 0 then
        spellId = a2
    end
    if not spellId then return end

    if SpellEventMatches("SLAM", spellId) then
        self._slamUsedInCycle = true
        return
    end
    if SpellEventMatches("SUNDER_ARMOR", spellId) then
        self._pendingSunderUntil = GetTime() + GCD_LOCK
        return
    end

    local key
    for key in pairs(BASE_COOLDOWNS) do
        if SpellEventMatches(key, spellId) then
            RecordPredictedCooldown(key)
            if key == "OVERPOWER" then
                self._returnHomeAfterOverpower = true
            end
            return
        end
    end
end

function P:BuildState(state)
    state.resourceType = "rage"
    state.timingType = "swing"
    state.rage = D:GetRage()
    state.maxRage = D.GetMaxRage and D:GetMaxRage() or 100
    state.playerHP = D:GetPlayerHealthPercent()
    state.stance = D:GetStance()
    state.profileDB = D:GetProfileDB(self.key)
    state.rotationDB = self:GetRotationDB(state.mode)
    state.tier3TwoPiece = D.DB and D.DB.tier3TwoPiece == true
    state.battleShout, state.battleShoutRemaining =
        D:GetPlayerBuffState("BATTLE_SHOUT")
    state.sweepingStrikes, state.sweepingRemaining, state.sweepingStacks =
        D:GetPlayerBuffState("SWEEPING_STRIKES", true)
    state.overpower, state.overpowerRemaining = D:GetReactiveState("OVERPOWER")
    state.sunderStacks = D:GetTargetDebuffStacks(
        D:GetName("SUNDER_ARMOR"),
        "SUNDER_ARMOR"
    )
    state.sunderRemaining = D:GetTargetDebuffRemaining(
        D:GetName("SUNDER_ARMOR")
    )
    state.swing = D:GetSwingState(state.swing)
    self:ObserveSwingCycle(state.swing)
    state.unbridledWrathRank = self:GetUnbridledWrathRank()
    state.predictedMainHandRage = EstimateNextWhiteRage(
        state.unbridledWrathRank
    )

    local meleeKey = D:IsKnown("MORTAL_STRIKE") and "MORTAL_STRIKE"
        or (D:IsKnown("SLAM") and "SLAM" or nil)
    local inMelee = D:IsMeleeRange("target", meleeKey)
    if inMelee == nil and tonumber(state.targetDistance) then
        inMelee = tonumber(state.targetDistance) <= 5
    end
    state.meleeRangeKey = meleeKey
    state.inMelee = state.targetValid and inMelee == true or false
end

function P:DecorateCooldown(key, entry, state)
    if key == "OVERPOWER" then
        entry.proc = state.overpower
        entry.procRemaining = state.overpowerRemaining
    end
end

local function SlamFits(state, minimumLock)
    local swing = state.swing
    if not swing or not swing.active or swing.slamUsed
        or swing.slamCapable == false then
        return false
    end
    local clip = tonumber(RotationValue(state, "slamClip")) or 0.17
    if clip < 0 then clip = 0 end
    if clip > 0.30 then clip = 0.30 end
    local lock = math.max(
        tonumber(state.gcd) or 0,
        tonumber(minimumLock) or 0
    )
    local remaining = (tonumber(swing.remaining) or 0)
        - lock
    return remaining + clip >= (tonumber(swing.slamCast) or 2.5)
end

local function IsExecutePhase(state)
    return D:IsKnown("EXECUTE") and (tonumber(state.targetHP) or 100) <= 20
end

local function ShortExecuteTarget(state, horizon)
    if not state.targetTTDConfidence then return false end
    local ttd = tonumber(state.targetTTD)
    return ttd and ttd > 0 and ttd <= (tonumber(horizon) or 1.25)
end

local function ExecuteWindow(state)
    local value = tonumber(RotationValue(state, "executeSwingWindow")) or 0.35
    if value < 0.10 then return 0.10 end
    if value > 0.80 then return 0.80 end
    return value
end

local function ExecuteDue(state)
    if not IsExecutePhase(state) or not Ready(state, "EXECUTE")
        or IsOnSwingQueued(state) then
        return false
    end
    if ShortExecuteTarget(state, 1.25) then return true end

    local swing = state.swing
    if not swing or not swing.active or not swing.remaining then return true end
    if swing.remaining <= ExecuteWindow(state) then return true end

    local predicted = tonumber(state.predictedMainHandRage)
    local capRisk = predicted
        and (tonumber(state.rage) or 0) + predicted
            >= (tonumber(state.maxRage) or 100)
    return capRisk and not SlamFits(state) or false
end

local function CanFitExecuteFollowup(state)
    local swing = state.swing
    if not swing or not swing.active or not swing.remaining then return true end
    local lock = (tonumber(state.gcd) or 0) + GCD_LOCK
    return swing.remaining > (lock + ExecuteWindow(state))
end

local function AvoidSlamForTargetLife(state)
    if not state.targetTTDConfidence then return false end
    local ttd = tonumber(state.targetTTD)
    local cast = state.swing and tonumber(state.swing.slamCast) or 2.5
    return ttd and ttd > 0 and ttd <= (cast + EXECUTE_INTERRUPT_MARGIN)
end

local function SwingHitsBy(state, horizon, firstAt)
    local swing = state.swing
    horizon = tonumber(horizon)
    if not horizon or not swing or not swing.active then return 0 end

    local first = tonumber(firstAt) or tonumber(swing.remaining)
    if not first or horizon < first then return 0 end
    local speed = tonumber(swing.speed) or 3.5
    if speed <= 0 then speed = 3.5 end
    return math.floor((horizon - first) / speed) + 1
end

local function RageAfterSpendAt(state, key, horizon, firstRageAt)
    local rage = AvailableRage(state) - Cost(state, key)
    local swing = state.swing
    if not swing or not swing.active then return rage end

    local first = tonumber(firstRageAt) or tonumber(swing.remaining)
    local speed = tonumber(swing.speed) or 3.5
    if speed <= 0 then speed = 3.5 end
    if first and IsOnSwingQueued(state) then first = first + speed end

    local predicted = tonumber(state.predictedMainHandRage) or 0
    if predicted > 0 and first and tonumber(horizon)
        and tonumber(horizon) >= first then
        rage = rage + SwingHitsBy(state, horizon, first) * predicted
    end
    return rage
end

local function SweepingNeedsWhirlwind(state, afterActionAt, actionHits, firstSwingAt)
    if not state.sweepingStrikes or state.stance ~= 3
        or not D:IsKnown("WHIRLWIND") then
        return false
    end

    local waitAt = math.max(
        tonumber(state.gcd) or 0,
        CooldownRemaining(state, "WHIRLWIND")
    )
    afterActionAt = tonumber(afterActionAt) or waitAt

    local remaining = tonumber(state.sweepingRemaining)
    if remaining and waitAt + 0.05 < remaining
        and afterActionAt + 0.05 >= remaining then
        return true
    end

    local stacks = tonumber(state.sweepingStacks)
    if stacks and stacks > 0 then
        local waitHits = SwingHitsBy(state, waitAt)
        local delayedHits = (tonumber(actionHits) or 0)
            + SwingHitsBy(state, afterActionAt, firstSwingAt)
        if stacks - waitHits > 0 and stacks - delayedHits <= 0 then
            return true
        end
    end
    return false
end

local function CanWaitForInstantThenSlam(state, key, minimumLock)
    if not D:IsKnown(key)
        or (key == "WHIRLWIND" and state.stance ~= 3)
        or AvailableRage(state)
            < (Cost(state, key) + Cost(state, "SLAM")) then
        return false
    end
    local swing = state.swing
    local lock = math.max(
        tonumber(state.gcd) or 0,
        tonumber(minimumLock) or 0,
        CooldownRemaining(state, key)
    )
    return lock + GCD_LOCK + (tonumber(swing.slamCast) or 2.5)
        <= (tonumber(swing.remaining) or 0)
end

local function ShouldUseSlam(state, minimumLock)
    local aoe = P:NormalizeMode(state.mode) == "aoe"
    local queued = IsOnSwingQueued(state)
    local aoeCleave = aoe and IsCleaveQueued(state)
    if state.stance == 2 or state.moving or not Ready(state, "SLAM")
        or (queued and not aoeCleave) or not SlamFits(state, minimumLock)
        or AvoidSlamForTargetLife(state) then
        return false
    end

    if IsExecutePhase(state) and not aoe then return true end

    if CanWaitForInstantThenSlam(state, "MORTAL_STRIKE", minimumLock)
        or CanWaitForInstantThenSlam(state, "WHIRLWIND", minimumLock) then
        return false
    end

    if aoe and D:IsKnown("WHIRLWIND") then
        local swing = state.swing
        local start = math.max(
            tonumber(state.gcd) or 0,
            tonumber(minimumLock) or 0
        )
        local slamAt = start + (tonumber(swing.slamCast) or 2.5)
        local firstRageAt = math.max(
            tonumber(swing.remaining) or 0,
            slamAt
        )
        local whirlwindAt = math.max(
            CooldownRemaining(state, "WHIRLWIND"),
            slamAt
        )
        if SweepingNeedsWhirlwind(state, whirlwindAt, 1, firstRageAt) then
            return false
        end
        local rageAtWhirlwind = RageAfterSpendAt(
            state,
            "SLAM",
            whirlwindAt,
            firstRageAt
        )
        if rageAtWhirlwind < Cost(state, "WHIRLWIND") then return false end
    end
    return true
end

local function CanFitSlamExecuteAfterInstant(state)
    local lock = (tonumber(state.gcd) or 0) + GCD_LOCK
    if not ShouldUseSlam(state, lock) then return false end
    local swing = state.swing
    return (tonumber(swing.remaining) or 0) - lock
        - (tonumber(swing.slamCast) or 2.5) > 0.05
end

local function ShouldUseWhirlwind(state)
    if not Ready(state, "WHIRLWIND") then return false end
    if P:NormalizeMode(state.mode) == "aoe" then return true end

    if SlamFits(state)
        and (tonumber(state.rage) or 0)
            < (Cost(state, "WHIRLWIND") + Cost(state, "SLAM")) then
        return false
    end

    local msRemaining = CooldownRemaining(state, "MORTAL_STRIKE")
    local afterWhirlwind = (tonumber(state.gcd) or 0) + GCD_LOCK
    if D:IsKnown("MORTAL_STRIKE")
        and msRemaining <= (afterWhirlwind + 0.10) then
        local mortalStrikeAt = math.max(msRemaining, afterWhirlwind)
        if RageAfterSpendAt(state, "WHIRLWIND", mortalStrikeAt)
            < Cost(state, "MORTAL_STRIKE") then
            return false
        end
    end
    return true
end

local function ShouldUseMortalStrikeAoE(state)
    if not Ready(state, "MORTAL_STRIKE") then return false end
    if not D:IsKnown("WHIRLWIND") or state.stance ~= 3 then return true end

    local start = tonumber(state.gcd) or 0
    local whirlwindRemaining = CooldownRemaining(state, "WHIRLWIND")
    local afterMortalStrike = math.max(
        whirlwindRemaining,
        start + GCD_LOCK
    )
    if SweepingNeedsWhirlwind(state, afterMortalStrike, 1) then
        return false
    end
    if whirlwindRemaining >= start + GCD_LOCK then return true end
    return RageAfterSpendAt(
        state,
        "MORTAL_STRIKE",
        afterMortalStrike
    ) >= Cost(state, "WHIRLWIND")
end

local function CanUseExecuteInstant(state, key, slamNow, slamAfterInstant)
    local rage = tonumber(state.rage) or 0
    if slamAfterInstant then
        return rage >= (Cost(state, key) + Cost(state, "SLAM")
            + Cost(state, "EXECUTE"))
    end
    return not slamNow
        and rage >= (Cost(state, key) + Cost(state, "EXECUTE"))
        and CanFitExecuteFollowup(state)
end

local function BattleShoutNeedsRefresh(state)
    if RotationValue(state, "maintainBattleShout") == false
        or not state.inCombat or not Ready(state, "BATTLE_SHOUT") then
        return false
    end
    if not state.battleShout then return true end
    local remaining = tonumber(state.battleShoutRemaining)
    local refresh = tonumber(RotationValue(state, "battleShoutRefresh")) or 10
    return remaining ~= nil and remaining <= refresh
end

local function SunderNeedsRefresh(state)
    if RotationValue(state, "maintainSunder") ~= true
        or not state.inCombat or not Ready(state, "SUNDER_ARMOR") then
        return false
    end
    local pending = tonumber(P._pendingSunderUntil)
    if pending and pending > (tonumber(state.now) or GetTime()) then
        return false
    end
    if (tonumber(state.sunderStacks) or 0) < 1 then return true end
    local remaining = tonumber(state.sunderRemaining)
    return remaining ~= nil and remaining < 5
end

local function RecommendSunder(action, state)
    if not SunderNeedsRefresh(state) then return nil end
    if IsExecutePhase(state)
        and ((tonumber(state.rage) or 0)
                < (Cost(state, "SUNDER_ARMOR")
                    + Cost(state, "EXECUTE"))
            or not CanFitExecuteFollowup(state)) then
        return nil
    end
    return ApplyGCD(SetAction(action, "SUNDER_ARMOR", R.SUNDER_ARMOR), state)
end

local function ShouldQueueHeroicStrike(state)
    if IsExecutePhase(state) or not D:IsKnown("HEROIC_STRIKE")
        or IsOnSwingQueued(state) or not state.swing or not state.swing.active
        or (tonumber(state.rage) or 0) < Cost(state, "HEROIC_STRIKE") then
        return false
    end
    local predicted = tonumber(state.predictedMainHandRage)
    return predicted ~= nil and (tonumber(state.rage) or 0) + predicted
        >= (tonumber(state.maxRage) or 100)
end

local function ShouldQueueCleave(
    state,
    sweepingPending,
    plannedKey,
    executeDue
)
    if sweepingPending or executeDue or not D:IsKnown("CLEAVE")
        or IsOnSwingQueued(state)
        or not state.swing or not state.swing.active then
        return false
    end

    local rage = AvailableRage(state)
    local plannedCost = plannedKey and Cost(state, plannedKey) or 0
    local projected = rage - plannedCost
    local threshold = tonumber(RotationValue(state, "cleaveRage")) or 95
    local predicted = tonumber(state.predictedMainHandRage)
    local capRisk = predicted ~= nil
        and projected + predicted >= (tonumber(state.maxRage) or 100)
    if projected < threshold and not capRisk then return false end

    local swingAt = tonumber(state.swing.remaining) or 0
    local speed = tonumber(state.swing.speed) or 3.5
    if speed <= 0 then speed = 3.5 end
    local nextRageAt = swingAt + speed
    local reserve = plannedCost
    if plannedKey ~= "WHIRLWIND" and D:IsKnown("WHIRLWIND")
        and CooldownRemaining(state, "WHIRLWIND") <= nextRageAt then
        reserve = reserve + Cost(state, "WHIRLWIND")
    end
    if D:IsKnown("MORTAL_STRIKE")
        and plannedKey ~= "MORTAL_STRIKE"
        and CooldownRemaining(state, "MORTAL_STRIKE") <= nextRageAt then
        reserve = reserve + Cost(state, "MORTAL_STRIKE")
    end
    if rage < (Cost(state, "CLEAVE") + reserve) then return false end

    if state.sweepingStrikes then
        if state.stance ~= 3 then return false end
        local actionLock = tonumber(state.gcd) or 0
        if plannedKey == "SLAM" then
            actionLock = actionLock + (tonumber(state.swing.slamCast) or 2.5)
        elseif plannedKey then
            actionLock = actionLock + GCD_LOCK
        end
        local whirlwindAt = math.max(
            actionLock,
            CooldownRemaining(state, "WHIRLWIND")
        )
        local remaining = tonumber(state.sweepingRemaining)
        if swingAt <= whirlwindAt + 0.05
            and (not remaining or whirlwindAt + 0.05 < remaining)
            and SweepingNeedsWhirlwind(
                state,
                whirlwindAt,
                plannedKey and 3 or 2,
                swingAt + speed
            ) then
            return false
        end
    end
    return true
end

local function CanSwitchHome(state)
    if IsOnSwingQueued(state) then return false end
    if not state.inCombat or state.stance == 2 then return true end
    return (tonumber(state.rage) or 0) <= STANCE_RAGE
end

local function ReturnHome(action, state)
    local force = P._returnHomeAfterOverpower and state.stance == 1
        and not IsOnSwingQueued(state)
    if state.stance == 3 then P._returnHomeAfterOverpower = false end
    if D:IsKnown("BERSERKER_STANCE") and NeedsStance(state, 3)
        and (force or CanSwitchHome(state)) then
        return StanceAction(action, "BERSERKER_STANCE", R.BERSERKER_STANCE, state)
    end
    return nil
end

local function RecommendOverpower(action, state)
    if not state.overpower or not Ready(state, "OVERPOWER") then return nil end
    if state.stance == 1 then
        return ApplyGCD(SetAction(action, "OVERPOWER", R.OVERPOWER), state)
    end
    if (state.stance == 2 or (tonumber(state.rage) or 0) <= STANCE_RAGE)
        and not IsOnSwingQueued(state) and D:IsKnown("BATTLE_STANCE") then
        return StanceAction(action, "BATTLE_STANCE", R.BATTLE_STANCE, state)
    end
    return nil
end

local function RecommendWhirlwind(action, state)
    if not ShouldUseWhirlwind(state) then return nil end
    if NeedsStance(state, 3) then
        if CanSwitchHome(state) then return ReturnHome(action, state) end
        return nil
    end
    return ApplyGCD(SetAction(action, "WHIRLWIND", R.WHIRLWIND), state)
end

local function RecommendExecute(action, state, immediate)
    if not Ready(state, "EXECUTE") then return nil end
    if state.stance == 2 and D:IsKnown("BATTLE_STANCE") then
        return StanceAction(action, "BATTLE_STANCE", R.BATTLE_STANCE, state)
    end
    return ApplyGCD(SetAction(
        action,
        "EXECUTE",
        immediate and R.EXECUTE_NOW or R.EXECUTE
    ), state)
end

local function WaitAction(action, state)
    local swing = state.swing or {}
    if swing.hsQueued then
        return SetAction(action, "HEROIC_STRIKE", R.QUEUED_HS, "queued", swing.remaining)
    elseif swing.cleaveQueued then
        return SetAction(action, "CLEAVE", R.QUEUED_CLEAVE, "queued", swing.remaining)
    elseif (tonumber(state.gcd) or 0) > 0.05 then
        return SetAction(action, "WAIT", D.Text.WAIT_GCD, "gcd", state.gcd)
    elseif swing.active and swing.remaining then
        return SetAction(action, "AUTO_ATTACK", R.WAIT_SWING, "wait", swing.remaining)
    elseif (tonumber(state.rage) or 0) < 15 then
        return SetAction(action, "WAIT", R.WAIT_RAGE, "pool")
    end
    return SetAction(action, "WAIT", R.WAIT_CD, "wait")
end

local function RecommendSingle(action, state)
    local executePhase = IsExecutePhase(state)
    if executePhase and ShortExecuteTarget(state, 1.25) then
        return RecommendExecute(action, state, true)
    end

    if P._returnHomeAfterOverpower then
        local home = ReturnHome(action, state)
        if home then return home end
    end

    local overpower = RecommendOverpower(action, state)
    if overpower then return overpower end

    if BattleShoutNeedsRefresh(state)
        and (not executePhase
            or ((tonumber(state.rage) or 0)
                    >= (Cost(state, "BATTLE_SHOUT")
                        + Cost(state, "EXECUTE"))
                and CanFitExecuteFollowup(state))) then
        return ApplyGCD(SetAction(action, "BATTLE_SHOUT", R.BATTLE_SHOUT), state)
    end

    local sunder = RecommendSunder(action, state)
    if sunder then return sunder end

    if executePhase then
        local slamNow = ShouldUseSlam(state)
        local slamAfterInstant = CanFitSlamExecuteAfterInstant(state)
        if Ready(state, "MORTAL_STRIKE")
            and CanUseExecuteInstant(
                state,
                "MORTAL_STRIKE",
                slamNow,
                slamAfterInstant
            ) then
            return ApplyGCD(SetAction(
                action,
                "MORTAL_STRIKE",
                R.MORTAL_STRIKE
            ), state)
        end

        if CanUseExecuteInstant(
            state,
            "WHIRLWIND",
            slamNow,
            slamAfterInstant
        ) then
            local whirlwind = RecommendWhirlwind(action, state)
            if whirlwind then return whirlwind end
        end

        if slamNow then
            return ApplyGCD(SetAction(action, "SLAM", R.SLAM), state)
        end
        if ExecuteDue(state) then return RecommendExecute(action, state, false) end
        return WaitAction(action, state)
    end

    local slamNow = ShouldUseSlam(state)
    if slamNow then
        return ApplyGCD(SetAction(action, "SLAM", R.SLAM), state)
    end

    if Ready(state, "MORTAL_STRIKE") then
        return ApplyGCD(SetAction(
            action,
            "MORTAL_STRIKE",
            R.MORTAL_STRIKE
        ), state)
    end

    local whirlwind = RecommendWhirlwind(action, state)
    if whirlwind then return whirlwind end

    local home = ReturnHome(action, state)
    if home then return home end

    if ShouldQueueHeroicStrike(state) then
        return SetAction(action, "HEROIC_STRIKE", R.HEROIC_STRIKE, "queue")
    end
    return WaitAction(action, state)
end

local function SweepingPending(action, state)
    if RotationValue(state, "useSweepingStrikes") == false
        or state.sweepingStrikes or not Ready(state, "SWEEPING_STRIKES") then
        return nil, false
    end
    if state.stance == 1 then
        return ApplyGCD(SetAction(
            action,
            "SWEEPING_STRIKES",
            R.SWEEPING_STRIKES
        ), state), true
    end
    if state.stance == 2 or ((tonumber(state.rage) or 0) <= STANCE_RAGE
            and not IsOnSwingQueued(state)) then
        return StanceAction(action, "BATTLE_STANCE", R.BATTLE_STANCE, state), true
    end
    return nil, true
end

local function RecommendAoE(action, state)
    if IsExecutePhase(state) and ShortExecuteTarget(state, 1.25) then
        return RecommendExecute(action, state, true)
    end

    local sweepingAction, sweepingPending = SweepingPending(action, state)
    if sweepingAction then return sweepingAction end

    if sweepingPending then
        local rage = AvailableRage(state)
        local reserve = Cost(state, "SWEEPING_STRIKES")
        if rage >= (Cost(state, "WHIRLWIND") + reserve) then
            local whirlwind = RecommendWhirlwind(action, state)
            if whirlwind then return whirlwind end
        end
        if rage >= (Cost(state, "MORTAL_STRIKE") + reserve)
            and Ready(state, "MORTAL_STRIKE") then
            return ApplyGCD(SetAction(
                action,
                "MORTAL_STRIKE",
                R.MORTAL_STRIKE
            ), state)
        end
        if not IsOnSwingQueued(state)
            and state.stance ~= 1 and D:IsKnown("BATTLE_STANCE") then
            return StanceAction(action, "BATTLE_STANCE", R.BATTLE_STANCE, state)
        end
        return WaitAction(action, state)
    end

    if state.sweepingStrikes then
        local home = ReturnHome(action, state)
        if home then return home end
    end

    local slamNow = ShouldUseSlam(state)
    if not slamNow then
        local whirlwind = RecommendWhirlwind(action, state)
        if whirlwind then return whirlwind end
    end

    local mortalNow = ShouldUseMortalStrikeAoE(state)
    local executeNow = ExecuteDue(state)
    local plannedKey = slamNow and "SLAM"
        or (mortalNow and "MORTAL_STRIKE" or nil)
    if ShouldQueueCleave(
        state,
        sweepingPending,
        plannedKey,
        executeNow
    ) then
        return SetAction(action, "CLEAVE", R.CLEAVE, "queue")
    end

    if slamNow then
        return ApplyGCD(SetAction(action, "SLAM", R.SLAM), state)
    end

    if mortalNow then
        return ApplyGCD(SetAction(
            action,
            "MORTAL_STRIKE",
            R.MORTAL_STRIKE
        ), state)
    end

    if IsExecutePhase(state) and executeNow then
        return RecommendExecute(action, state, false)
    end

    local sunder = RecommendSunder(action, state)
    if sunder then return sunder end

    if BattleShoutNeedsRefresh(state) then
        return ApplyGCD(SetAction(action, "BATTLE_SHOUT", R.BATTLE_SHOUT), state)
    end

    local home = ReturnHome(action, state)
    if home then return home end
    return WaitAction(action, state)
end

function P:Recommend(state)
    local action = self._rec
    if D.testMode then
        local keys = { "MORTAL_STRIKE", "WHIRLWIND", "SLAM", "EXECUTE" }
        local cycle = math.floor(GetTime() / 1.5)
        local index = cycle - math.floor(cycle / table.getn(keys))
            * table.getn(keys) + 1
        return SetAction(action, keys[index], zh and "测试模式" or "Test mode")
    end

    if not state.targetValid then
        return SetAction(action, "WAIT", D.Text.WAIT_TARGET, "disabled")
    end

    if not state.inMelee then
        local home = ReturnHome(action, state)
        if home then return home end
        return SetAction(
            action,
            "WAIT",
            state.targetRangeState == "grace"
                and D.Text.RANGE_GRACE or D.Text.OUT_OF_RANGE,
            "range"
        )
    end

    if not state.inCombat or state.stance == 2 then
        local home = ReturnHome(action, state)
        if home then return home end
    end

    if self:NormalizeMode(state.mode) == "aoe" then
        return RecommendAoE(action, state)
    end
    return RecommendSingle(action, state)
end

local function ClearCandidates()
    -- Lua 5.0 caches table.insert's list size beyond nil assignments.
    P._candidates = {}
end

local function AddCandidate(key, eta, priority, uncertain)
    if not D:IsKnown(key) then return end
    table.insert(P._candidates, {
        key = key,
        eta = math.max(0, tonumber(eta) or 0),
        priority = priority or PRIORITY[key] or 50,
        uncertain = uncertain and true or false,
    })
end

local function CandidateSort(a, b)
    if math.abs((a.eta or 0) - (b.eta or 0)) < 0.05 then
        return (a.priority or 50) < (b.priority or 50)
    end
    return (a.eta or 0) < (b.eta or 0)
end

local function ForecastCooldown(state, current, key)
    local eta = CooldownRemaining(state, key)
    if current.key == key and eta <= 0.05 then
        eta = BASE_COOLDOWNS[key] or GCD_LOCK
    end
    return eta
end

function P:BuildForecast(state, current)
    ClearCandidates()
    if not state.targetValid or not state.inMelee then
        local i = 1
        while i <= FORECAST_LIMIT do
            self._forecast[i] = nil
            i = i + 1
        end
        return self._forecast
    end

    if state.overpower and current.key ~= "OVERPOWER" then
        AddCandidate(
            "OVERPOWER",
            ForecastCooldown(state, current, "OVERPOWER"),
            PRIORITY.OVERPOWER,
            (tonumber(state.rage) or 0) > STANCE_RAGE and state.stance ~= 1
        )
    end

    if IsExecutePhase(state) and current.key ~= "EXECUTE" then
        local eta = 0
        if state.swing and state.swing.active and state.swing.remaining
            and not ShortExecuteTarget(state, 1.25) then
            eta = math.max(0, state.swing.remaining - ExecuteWindow(state))
        end
        AddCandidate(
            "EXECUTE",
            eta,
            PRIORITY.EXECUTE,
            (tonumber(state.rage) or 0) < Cost(state, "EXECUTE")
        )
    end

    if self:NormalizeMode(state.mode) == "aoe" then
        if RotationValue(state, "useSweepingStrikes") ~= false
            and not state.sweepingStrikes then
            AddCandidate(
                "SWEEPING_STRIKES",
                ForecastCooldown(state, current, "SWEEPING_STRIKES"),
                PRIORITY.SWEEPING_STRIKES,
                AvailableRage(state) < Cost(state, "SWEEPING_STRIKES")
            )
        end
    end

    if current.key ~= "SLAM" and D:IsKnown("SLAM")
        and state.swing and state.swing.active and not state.swing.slamUsed then
        local lock = (current.key == "AUTO_ATTACK" or current.key == "WAIT"
            or current.key == "HEROIC_STRIKE" or current.key == "CLEAVE")
            and 0 or GCD_LOCK
        local eta = state.swing.remaining or 0
        if SlamFits(state, lock) then eta = lock end
        AddCandidate(
            "SLAM",
            eta,
            PRIORITY.SLAM,
            AvailableRage(state) < Cost(state, "SLAM")
        )
    end

    AddCandidate(
        "MORTAL_STRIKE",
        ForecastCooldown(state, current, "MORTAL_STRIKE"),
        PRIORITY.MORTAL_STRIKE,
        AvailableRage(state) < Cost(state, "MORTAL_STRIKE")
    )
    AddCandidate(
        "WHIRLWIND",
        ForecastCooldown(state, current, "WHIRLWIND"),
        PRIORITY.WHIRLWIND,
        AvailableRage(state) < Cost(state, "WHIRLWIND")
    )

    table.sort(self._candidates, CandidateSort)
    local outputIndex = 1
    local candidateIndex = 1
    while outputIndex <= FORECAST_LIMIT do
        local candidate = self._candidates[candidateIndex]
        if not candidate then
            self._forecast[outputIndex] = nil
            outputIndex = outputIndex + 1
        else
            if candidate.key ~= current.key then
                local forecast = self._forecast[outputIndex] or {}
                self._forecast[outputIndex] = forecast
                SetAction(
                    forecast,
                    candidate.key,
                    R.FORECAST,
                    "forecast",
                    candidate.eta,
                    candidate.uncertain
                )
                outputIndex = outputIndex + 1
            end
            candidateIndex = candidateIndex + 1
        end
    end
    return self._forecast
end

function P:Evaluate(state)
    local recommendation = self:Recommend(state)
    state.resourceActions = nil
    return recommendation, self:BuildForecast(state, recommendation)
end

function P:ShouldInterruptSlamForExecute(state)
    if not state.casting or not state.targetValid or not state.inMelee
        or not ShortExecuteTarget(state, 3.0) or not Ready(state, "EXECUTE")
        or IsOnSwingQueued(state) then
        return false
    end
    local slam = D:GetSpellDef("SLAM")
    local castId = state.cast and tonumber(state.cast.spellId) or nil
    if state.castName ~= D:GetName("SLAM")
        and (not castId or not slam or castId ~= tonumber(slam.spellId)) then
        return false
    end
    local remaining = tonumber(state.castRemaining) or 0
    local ttd = tonumber(state.targetTTD) or 0
    return remaining > 0.25 and ttd > 0
        and ttd <= (remaining + EXECUTE_INTERRUPT_MARGIN)
end

local function CastRecommendedAction(action)
    if action.key == "HEROIC_STRIKE" or action.key == "CLEAVE" then
        if CastSpellByNameNoQueue then
            CastSpellByNameNoQueue(action.name)
        else
            CastSpellByName(action.name)
        end
    else
        CastSpellByName(action.name)
    end
end

function P:Execute(mode)
    mode = self:NormalizeMode(mode)
    D:SetMode(mode, true)
    local state = D:BuildState()

    if state.casting then
        if self:ShouldInterruptSlamForExecute(state)
            and type(SpellStopCasting) == "function"
            and pcall(SpellStopCasting) then
            CastRecommendedAction(SetAction(
                self._rec,
                "EXECUTE",
                R.EXECUTE_NOW
            ))
            D:Update(true)
            return true
        end
        D:Update(true)
        return false
    end

    local changed = D:PrepareExecutionTarget(true, true, state.meleeRangeKey)
    if changed or not state.targetValid then state = D:BuildState() end

    local action = self:Recommend(state)
    if not action or not action.key or action.key == "WAIT"
        or action.key == "AUTO_ATTACK" or not D:IsKnown(action.key) then
        D:Update(true)
        return false
    end
    if (action.key == "HEROIC_STRIKE" or action.key == "CLEAVE")
        and IsOnSwingQueued(state) then
        D:Update(true)
        return false
    end

    CastRecommendedAction(action)
    if action.key == "HEROIC_STRIKE" or action.key == "CLEAVE" then
        D:MarkOnSwingQueued(action.key, state.swing)
    end
    D:Update(true)
    return true
end
