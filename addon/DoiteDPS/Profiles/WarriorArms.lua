-- ============================================================================
-- DoiteDPS - two-handed deep Arms Warrior
--
-- One single-target and one AoE rotation share the same Berserker-home engine.
-- Ready instant attacks lead each main-hand cycle; Slam is used at most once
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
        and "常驻狂暴姿态；致死/旋风优先，每个白字周期最多一次猛击并允许配置轻微卡条，斩杀贴近下一刀清怒。"
        or "Berserker home; instant core, one configurable clipped Slam per swing, late-cycle Execute.",
    aoe = zh
        and "横扫后回狂暴姿态；旋风、顺劈、致死优先，斩杀只补多目标核心空档。"
        or "Sweeping into Berserker; Whirlwind, Cleave and Mortal Strike lead.",
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
        cleaveRage = 40,
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
    if (tonumber(profileDB.deepArmsRotationVersion) or 0) < 1 then
        -- The removed stance/Fury-era knobs do not describe this rotation.
        profileDB.rotations = { single = {}, aoe = {} }
        profileDB.deepArmsRotationVersion = 1
    end
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
    CLEAVE = zh and "多目标顺劈排队" or "Queue Cleave for multiple targets",
    SWEEPING_STRIKES = zh and "开启横扫攻击" or "Activate Sweeping Strikes",
    BATTLE_SHOUT = zh and "维持战斗怒吼" or "Maintain Battle Shout",
    SUNDER_ARMOR = zh and "首次施加或剩余不足5秒时补破甲"
        or "Apply Sunder Armor or refresh it below 5 seconds",
    BATTLE_STANCE = zh and "低怒切战斗姿态" or "Enter Battle Stance at low rage",
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

local function Cost(key)
    local def = D:GetSpellDef(key)
    return def and tonumber(def.cost) or 0
end

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

local function NeedsStance(state, stance)
    local current = tonumber(state and state.stance) or 0
    return current > 0 and current ~= stance
end

local function SpellEventMatches(key, spellId)
    spellId = tonumber(spellId)
    local spell = D.Spells and D.Spells[key]
    return spellId and spell and tonumber(spell.spellId) == spellId
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

    if apiDuration > (D.GCD_MAX or 1.5) then
        if apiRemaining > 0.05 then
            P._cooldownUntil[key] = now + apiRemaining
        else
            P._cooldownUntil[key] = nil
        end
    end

    local predicted = P._cooldownUntil[key]
    predicted = predicted and predicted - now or 0
    if predicted <= 0.05 then
        P._cooldownUntil[key] = nil
        predicted = 0
    end
    if predicted > apiRemaining then return predicted end
    return apiRemaining
end

local function Ready(state, key)
    return D:IsKnown(key)
        and (tonumber(state.rage) or 0) >= Cost(key)
        and CooldownRemaining(state, key) <= 0.05
end

local function ReadNumber(fn, arg1, arg2)
    if type(fn) ~= "function" then return nil end
    local ok, value = pcall(fn, arg1, arg2)
    if not ok then return nil end
    return tonumber(value)
end

local function ExpectedWhiteRage(damage, speed, critChance)
    local crit = math.max(0, math.min(100, tonumber(critChance) or 0)) / 100
    local damageRage = ((damage / 230.6) * 7.5 / 1.075)
    return damageRage * (1 + crit)
        + (speed * (3.5 + 4 * crit) / 2.25)
end
P._expectedWhiteRage = ExpectedWhiteRage

local function EstimateNextWhiteRage()
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
    local rage = ExpectedWhiteRage(damage, speed, crit)
    if rage < 0 then return nil end
    return math.floor(rage + 0.5)
end

function P:ResetRuntime()
    self._cooldownUntil = {}
    self._lastSwingProgress = nil
    self._slamUsedInCycle = false
    self._returnHomeAfterOverpower = false
    self._pendingSunderUntil = nil
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

    local key, duration
    for key, duration in pairs(BASE_COOLDOWNS) do
        if SpellEventMatches(key, spellId) then
            self._cooldownUntil[key] = GetTime() + duration
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
    state.battleShout, state.battleShoutRemaining =
        D:GetPlayerBuffState("BATTLE_SHOUT")
    state.sweepingStrikes, state.sweepingRemaining =
        D:GetPlayerBuffState("SWEEPING_STRIKES")
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
    state.predictedMainHandRage = EstimateNextWhiteRage()

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
    if not swing or not swing.active or swing.slamUsed then
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
    if not state.targetTTDConfidence or state.targetBoss then return false end
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
    local lock = math.max(GCD_LOCK, tonumber(state.gcd) or 0)
    return swing.remaining > (lock + ExecuteWindow(state))
end

local function AvoidSlamForTargetLife(state)
    if not state.targetTTDConfidence or state.targetBoss then return false end
    local ttd = tonumber(state.targetTTD)
    local cast = state.swing and tonumber(state.swing.slamCast) or 2.5
    return ttd and ttd > 0 and ttd <= (cast + EXECUTE_INTERRUPT_MARGIN)
end

local function ShouldUseSlam(state)
    if state.stance == 2 or not Ready(state, "SLAM")
        or IsOnSwingQueued(state) or not SlamFits(state)
        or AvoidSlamForTargetLife(state) then
        return false
    end

    if D:IsKnown("MORTAL_STRIKE") then
        local cast = state.swing and tonumber(state.swing.slamCast) or 2.5
        if CooldownRemaining(state, "MORTAL_STRIKE") <= (cast + 0.25) then
            local after = (tonumber(state.rage) or 0) - Cost("SLAM")
                + (tonumber(state.predictedMainHandRage) or 0)
            if after < Cost("MORTAL_STRIKE") then return false end
        end
    end
    return true
end

local function ShouldUseWhirlwind(state)
    if not Ready(state, "WHIRLWIND") then return false end
    if P:NormalizeMode(state.mode) == "aoe" then return true end

    if SlamFits(state)
        and (tonumber(state.rage) or 0)
            < (Cost("WHIRLWIND") + Cost("SLAM")) then
        return false
    end

    local msRemaining = CooldownRemaining(state, "MORTAL_STRIKE")
    if D:IsKnown("MORTAL_STRIKE") and msRemaining <= (GCD_LOCK + 0.10) then
        local available = tonumber(state.rage) or 0
        local swing = state.swing
        if swing and swing.active and swing.remaining
            and swing.remaining <= msRemaining then
            available = available + (tonumber(state.predictedMainHandRage) or 0)
        end
        if available < (Cost("WHIRLWIND") + Cost("MORTAL_STRIKE")) then
            return false
        end
    end
    return true
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
                < (Cost("SUNDER_ARMOR") + Cost("EXECUTE"))
            or not CanFitExecuteFollowup(state)) then
        return nil
    end
    return ApplyGCD(SetAction(action, "SUNDER_ARMOR", R.SUNDER_ARMOR), state)
end

local function ShouldQueueHeroicStrike(state)
    if IsExecutePhase(state) or not D:IsKnown("HEROIC_STRIKE")
        or IsOnSwingQueued(state) or not state.swing or not state.swing.active
        or (tonumber(state.rage) or 0) < Cost("HEROIC_STRIKE") then
        return false
    end
    local predicted = tonumber(state.predictedMainHandRage)
    return predicted ~= nil and (tonumber(state.rage) or 0) + predicted
        >= (tonumber(state.maxRage) or 100)
end

local function ShouldQueueCleave(state, sweepingPending)
    if sweepingPending or not D:IsKnown("CLEAVE") or IsOnSwingQueued(state)
        or not state.swing or not state.swing.active then
        return false
    end
    local threshold = tonumber(RotationValue(state, "cleaveRage")) or 40
    return (tonumber(state.rage) or 0) >= threshold
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
                    >= (Cost("BATTLE_SHOUT") + Cost("EXECUTE"))
                and CanFitExecuteFollowup(state))) then
        return ApplyGCD(SetAction(action, "BATTLE_SHOUT", R.BATTLE_SHOUT), state)
    end

    local sunder = RecommendSunder(action, state)
    if sunder then return sunder end

    if executePhase then
        if Ready(state, "MORTAL_STRIKE")
            and (tonumber(state.rage) or 0)
                >= (Cost("MORTAL_STRIKE") + Cost("EXECUTE"))
            and CanFitExecuteFollowup(state) then
            return ApplyGCD(SetAction(
                action,
                "MORTAL_STRIKE",
                R.MORTAL_STRIKE
            ), state)
        end

        if (tonumber(state.rage) or 0)
                >= (Cost("WHIRLWIND") + Cost("EXECUTE"))
            and CanFitExecuteFollowup(state) then
            local whirlwind = RecommendWhirlwind(action, state)
            if whirlwind then return whirlwind end
        end

        if ShouldUseSlam(state) then
            return ApplyGCD(SetAction(action, "SLAM", R.SLAM), state)
        end
        if ExecuteDue(state) then return RecommendExecute(action, state, false) end
        return WaitAction(action, state)
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

    if ShouldUseSlam(state) then
        return ApplyGCD(SetAction(action, "SLAM", R.SLAM), state)
    end

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

    if state.sweepingStrikes then
        local home = ReturnHome(action, state)
        if home then return home end
    end

    local whirlwind = RecommendWhirlwind(action, state)
    if whirlwind then return whirlwind end

    if ShouldQueueCleave(state, sweepingPending) then
        return SetAction(action, "CLEAVE", R.CLEAVE, "queue")
    end

    if Ready(state, "MORTAL_STRIKE") then
        return ApplyGCD(SetAction(
            action,
            "MORTAL_STRIKE",
            R.MORTAL_STRIKE
        ), state)
    end

    if IsExecutePhase(state) and ExecuteDue(state) then
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
            (tonumber(state.rage) or 0) < Cost("EXECUTE")
        )
    end

    if self:NormalizeMode(state.mode) == "aoe" then
        if RotationValue(state, "useSweepingStrikes") ~= false
            and not state.sweepingStrikes then
            AddCandidate(
                "SWEEPING_STRIKES",
                ForecastCooldown(state, current, "SWEEPING_STRIKES"),
                PRIORITY.SWEEPING_STRIKES,
                (tonumber(state.rage) or 0) < Cost("SWEEPING_STRIKES")
            )
        end
    elseif current.key ~= "SLAM" and D:IsKnown("SLAM")
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
            (tonumber(state.rage) or 0) < Cost("SLAM")
        )
    end

    AddCandidate(
        "MORTAL_STRIKE",
        ForecastCooldown(state, current, "MORTAL_STRIKE"),
        PRIORITY.MORTAL_STRIKE,
        (tonumber(state.rage) or 0) < Cost("MORTAL_STRIKE")
    )
    AddCandidate(
        "WHIRLWIND",
        ForecastCooldown(state, current, "WHIRLWIND"),
        PRIORITY.WHIRLWIND,
        (tonumber(state.rage) or 0) < Cost("WHIRLWIND")
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
