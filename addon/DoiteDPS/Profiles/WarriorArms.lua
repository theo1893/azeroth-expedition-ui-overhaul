-- ============================================================================
-- DoiteDPS - 双手战士循环（武器／狂暴）
--
-- 单体与 AOE 循环共用同一套常驻狂暴姿态逻辑。
-- 只有瞬发后仍能接猛击时才优先瞬发；每个白字周期最多使用一次猛击，允许卡条
-- 不超过配置上限。深武器保留定时斩杀；狂暴按天赋启用常规技能优先的斩杀策略。
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
local IMPROVED_EXECUTE = zh and "强化斩杀" or "Improved Execute"
local IMPROVED_HEROIC_STRIKE = zh and "强化英勇打击" or "Improved Heroic Strike"
local RAVAGER = zh and "碾碎" or "Ravager"
local FLURRY = zh and "乱舞" or "Flurry"

P.ModeOrder = { "single", "aoe" }
P.ModeLabels = {
    single = zh and "双手战士" or "Two-Handed Warrior",
    aoe = zh and "双手战士" or "Two-Handed Warrior",
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
        and "常驻狂暴姿态，按天赋适配武器/狂暴；深武器保留定时斩杀，狂暴保护常规技能与下一轮猛击，嗜血仅在学会时参与。"
        or "Adapts to Arms/Fury talents in Berserker Stance. Arms times Execute; Fury protects core attacks and the next Slam. Bloodthirst is optional.",
    aoe = zh
        and "学会横扫时先准备横扫再回狂暴姿态；旋风、安全猛击及已学会的致死/嗜血优先，顺劈预留核心怒气，狂暴斩杀不抢占下一轮技能。"
        or "Use learned Sweeping Strikes, then Berserker. Prioritize Whirlwind, safe Slam and learned strikes; reserve core rage for Cleave and Fury Execute.",
}

P.RotationDefaults = {
    single = {
        slamClip = 0.17,
        executeLead = 0.55,
        furyExecuteExtraRage = 10,
        furyProtectNextSlam = true,
        maintainBattleShout = true,
        battleShoutRefresh = 10,
        maintainSunder = false,
    },
    aoe = {
        slamClip = 0.17,
        executeLead = 0.55,
        furyExecuteExtraRage = 10,
        furyProtectNextSlam = true,
        maintainBattleShout = true,
        battleShoutRefresh = 10,
        maintainSunder = false,
        useSweepingStrikes = true,
        cleaveRage = 95,
    },
}

P.ConfigSchema = {
    title = zh and "双手战士" or "Two-Handed Warrior",
    modes = {
        { key = "single", label = P.ModeLabels.single, note = P.ModeNotes.single },
        { key = "aoe", label = P.ModeLabels.aoe, note = P.ModeNotes.aoe },
    },
    options = {
        {
            type = "toggle",
            section = zh and "辅助与装备" or "Utility & equipment",
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
            section = zh and "辅助与装备" or "Utility & equipment",
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
            key = "tier3TwoPiece",
            label = zh and "T3两件：横扫/死愿减10怒"
                or "Tier 3 two-piece (-10 Sweeping/Death Wish rage)",
            modes = { "single", "aoe" },
        },
    },
}

-- 两阶段共用已学技能事实，只按当前模式的开关改变推荐与资源预算。
local SKILL_OPTIONS = {
    SLAM = "useSlam",
    OVERPOWER = "useOverpower",
    WHIRLWIND = "useWhirlwind",
    MORTAL_STRIKE = "useStrike",
    BLOODTHIRST = "useStrike",
}
local skills = {
    { "useSlam", zh and "猛击" or "Slam" },
    { "useOverpower", zh and "压制" or "Overpower" },
    { "useWhirlwind", zh and "旋风斩" or "Whirlwind" },
    { "useStrike", zh and "嗜血／致死打击" or "Bloodthirst / Mortal Strike" },
}
for index, skill in ipairs(skills) do
    for _, suffix in ipairs({ "", "Execute" }) do
        local key = skill[1] .. suffix
        for _, defaults in pairs(P.RotationDefaults) do defaults[key] = true end
        table.insert(P.ConfigSchema.options, {
            type = "toggle",
            section = index == 1 and suffix == ""
                and (zh and "技能开关" or "Skill switches") or nil,
            layoutGroup = skill[1],
            key = key,
            label = (suffix == "" and (zh and "非斩杀：" or "Normal: ")
                or (zh and "斩杀：" or "Execute: ")) .. skill[2],
            modes = { "single", "aoe" },
        })
    end
end
table.insert(P.ConfigSchema.options, {
    type = "number",
    section = zh and "节奏与怒气" or "Timing & rage",
    layoutGroup = "timing",
    key = "slamClip",
    label = zh and "猛击最大卡条" or "Maximum Slam swing delay",
    modes = { "single", "aoe" },
    min = 0,
    max = 0.30,
    step = 0.01,
    suffix = zh and "秒" or "s",
    format = "%.2f",
})
table.insert(P.ConfigSchema.options, {
    type = "number",
    layoutGroup = "timing",
    key = "executeLead",
    label = zh and "武器斩杀提前时间" or "Arms Execute lead time",
    modes = { "single", "aoe" },
    min = 0.25,
    max = 1.0,
    step = 0.05,
    suffix = zh and "秒" or "s",
    format = "%.2f",
})
table.insert(P.ConfigSchema.options, {
    type = "number",
    layoutGroup = "timing",
    key = "furyExecuteExtraRage",
    label = zh and "狂暴斩杀额外怒气上限" or "Fury Execute extra rage cap",
    modes = { "single", "aoe" },
    min = 0,
    max = 30,
    step = 5,
    format = "%d",
})
table.insert(P.ConfigSchema.options, {
    type = "toggle",
    layoutGroup = "timing",
    key = "furyProtectNextSlam",
    label = zh and "狂暴斩杀保护下轮猛击" or "Fury Execute protects next Slam",
    modes = { "single", "aoe" },
    visibleWhen = { key = "useSlamExecute", value = true },
})

-- 将旧群体模式映射到 aoe，其余入口统一使用 single，兼容已有宏绑定。
function P:NormalizeMode(mode)
    if mode == "aoe" or mode == "battle_aoe" then return "aoe" end
    return "single"
end

-- 取得归一化模式的界面名称。
function P:GetModeLabel(mode)
    return self.ModeLabels[self:NormalizeMode(mode)]
end

-- 取得单体或群体模式对应的默认配置表。
function P:GetRotationDefaults(mode)
    return self.RotationDefaults[self:NormalizeMode(mode)]
end

-- 按版本迁移旧循环参数，再取得当前角色按单体／群体分别保存的配置。
function P:GetRotationDB(mode)
    mode = self:NormalizeMode(mode)
    local defaults = self:GetRotationDefaults(mode)
    if not D.GetRotationDB then return defaults end

    local profileDB = D:GetProfileDB(self.key)
    local version = tonumber(profileDB.deepArmsRotationVersion) or 0
    if version < 1 then
        -- 旧版姿态／狂暴循环的参数已不适用，只在首次迁移时清理。
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
    FURY_EXECUTE = zh and "常规技能空档斩杀，保护下一轮输出" or "Execute between core attacks without starving the next cycle",
    OVERPOWER = zh and "低怒压制触发" or "Low-rage Overpower proc",
    MORTAL_STRIKE = zh and "致死打击瞬发槽" or "Mortal Strike instant slot",
    BLOODTHIRST = zh and "嗜血瞬发槽" or "Bloodthirst instant slot",
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

-- _rec/_forecast 是 Core 复用的输出记录。其余表仅保存本 Profile 的运行时状态：
-- 候选暂存、预测冷却截止时间、时间线周期标识，以及 API 是否已确认该次冷却。
P._rec = D.Recommendation
P._forecast = D.Forecasts
P._candidates = {}
P._cooldownUntil = {}
P._cooldownCycle = {}
P._apiCooldownActive = {}
P._swingCycle = 0

local FORECAST_LIMIT = D.FORECAST_LIMIT or 3
local GCD_LOCK = 1.5
local STANCE_RAGE = 25
local EXECUTE_TAIL_GUARD = 0.20
local ON_SWING_QUEUE_GUARD = 0.20
local BASE_COOLDOWNS = {
    MORTAL_STRIKE = 6,
    BLOODTHIRST = 6,
    OVERPOWER = 5,
    WHIRLWIND = 10,
    SWEEPING_STRIKES = 30,
}
local CORE_STRIKES = { "MORTAL_STRIKE", "BLOODTHIRST", "WHIRLWIND" }

local PRIORITY = {
    EXECUTE = 1,
    OVERPOWER = 2,
    SWEEPING_STRIKES = 3,
    MORTAL_STRIKE = 4,
    BLOODTHIRST = 4,
    WHIRLWIND = 5,
    SLAM = 6,
    CLEAVE = 7,
}

-- 取得用于事件预估的基础冷却；旋风按碾碎天赋扣除 1／1.5／2 秒。
local function BaseCooldown(key)
    local duration = BASE_COOLDOWNS[key]
    if key == "WHIRLWIND" then
        local rank = P:GetRavagerRank()
        duration = duration - (rank > 0 and (0.5 + 0.5 * rank) or 0)
    end
    return duration
end

-- 已学嗜血时选嗜血，否则返回致死键；调用处仍须检查技能是否已学会。
local function StrikeKey()
    return D:IsKnown("BLOODTHIRST") and "BLOODTHIRST" or "MORTAL_STRIKE"
end

-- 计算天赋与套装减耗后的技能成本；斩杀这里只返回最低施放成本，实际会清空余怒。
local function Cost(state, key)
    local def = D:GetSpellDef(key)
    local cost = def and tonumber(def.cost) or 0
    if key == "HEROIC_STRIKE" then
        cost = cost - P:GetImprovedHeroicStrikeRank()
    elseif key == "CLEAVE" then
        cost = cost - P:GetRavagerRank()
    elseif key == "EXECUTE" then
        local rank = P:GetImprovedExecuteRank()
        cost = cost - (rank == 2 and 5 or (rank == 1 and 2 or 0))
    end
    if state and state.tier3TwoPiece
        and (key == "SWEEPING_STRIKES" or key == "DEATH_WISH") then
        cost = cost - 10
    end
    return math.max(0, cost)
end
P._rageCost = Cost

-- 优先读取当前角色的循环设置，未设置的项目回退到该模式默认值。
local function RotationValue(state, key)
    if state and state.rotationDB and state.rotationDB[key] ~= nil then
        return state.rotationDB[key]
    end
    local defaults = P.RotationDefaults[P:NormalizeMode(state and state.mode)]
    return defaults and defaults[key] or nil
end

local function IsExecutePhase(state)
    return D:IsKnown("EXECUTE") and (tonumber(state.targetHP) or 100) <= 20
end

-- 关闭技能同时从推荐、预测及其他技能的预留预算中移除；不修改天赋与技能书。
local function Enabled(state, key)
    local option = SKILL_OPTIONS[key]
    if option and IsExecutePhase(state) then option = option .. "Execute" end
    return D:IsKnown(key) and (not option or RotationValue(state, option) ~= false)
end

-- 填充复用的建议／预测记录，并清理上一次动作留下的时间线字段。
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

-- 给普通技能附加 GCD 等待状态；英勇／顺劈属于下一刀排队动作，不附加此标记。
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

-- 构造切姿态建议，并同步当前 GCD 的展示状态。
local function StanceAction(action, key, reason, state)
    return ApplyGCD(SetAction(action, key, reason, "ready"), state)
end

-- 检查已确认或仍待确认的英勇／顺劈队列，避免重复排队或误用已预留的怒气。
local function IsOnSwingQueued(state)
    local swing = state and state.swing
    return swing and (swing.hsQueued or swing.cleaveQueued or swing.queuePending)
        or false
end

-- 区分顺劈与英勇队列，包含已经发出但尚未得到客户端确认的顺劈请求。
local function IsCleaveQueued(state)
    local swing = state and state.swing
    return swing and (swing.cleaveQueued
        or (swing.queuePending and swing.pendingKey == "CLEAVE")) or false
end

-- 扣除已排队英勇／顺劈的成本，得到仍可分配给其他技能的怒气。
local function AvailableRage(state)
    local rage = tonumber(state and state.rage) or 0
    if IsOnSwingQueued(state) then
        rage = rage - Cost(state, IsCleaveQueued(state) and "CLEAVE" or "HEROIC_STRIKE")
    end
    if rage < 0 then return 0 end
    return rage
end

-- 当前姿态已知且不同于目标姿态时，才认为需要切换。
local function NeedsStance(state, stance)
    local current = tonumber(state and state.stance) or 0
    return current > 0 and current ~= stance
end

-- 优先按技能 ID 匹配施法事件，其他等级的同名技能可通过本地化名称匹配。
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

-- 合并客户端独立冷却与施法事件预估，避免冷却尚未同步时重复推荐同一技能。
local function CooldownRemaining(state, key)
    local now = tonumber(state and state.now) or GetTime()
    local entry = state and state.cooldowns and state.cooldowns[key]
    local apiRemaining = entry and tonumber(entry.remaining) or nil
    local apiDuration = entry and tonumber(entry.duration) or nil
    if apiRemaining == nil then
        apiRemaining, apiDuration = D:GetNonGCDCooldown(key, now)
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

-- 只检查已学技能、可用怒气和独立冷却；GCD、姿态与白字窗口由后续决策处理。
local function Ready(state, key)
    return Enabled(state, key)
        and AvailableRage(state) >= Cost(state, key)
        and CooldownRemaining(state, key) <= 0.05
end

-- 收到施法事件后预写冷却截止时间，并对重复回调去重，维护时间线周期编号。
local function RecordPredictedCooldown(key)
    local duration = BaseCooldown(key)
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

-- 安全读取可选 API 的数值；接口缺失、调用失败或结果非数值时返回 nil。
local function ReadNumber(fn, arg1, arg2)
    if type(fn) ~= "function" then return nil end
    local ok, value = pcall(fn, arg1, arg2)
    if not ok then return nil end
    return tonumber(value)
end

-- 按名称或指定行列查找天赋，返回等级与读取状态；失败时以零等级供调用方回退。
local function TalentRank(tabIndex, wantedName, wantedTier, wantedColumn)
    if type(GetTalentInfo) ~= "function" then return 0, "api-missing" end
    local index = 1
    while index <= 30 do
        local ok, name, icon, tier, column, rank = pcall(
            GetTalentInfo,
            tabIndex,
            index
        )
        if not ok then return 0, "api-error" end
        if not name then break end
        if name == wantedName
            or (wantedTier and tonumber(tier) == wantedTier
                and tonumber(column) == wantedColumn) then
            if not tonumber(rank) then return 0, "invalid-rank" end
            return tonumber(rank), "found"
        end
        index = index + 1
    end
    return 0, "not-found"
end

-- 缓存怒不可遏等级，用于下一刀回怒期望；天赋变化事件会清除此缓存。
function P:GetUnbridledWrathRank()
    if self._unbridledWrathRank == nil then
        self._unbridledWrathRank = TalentRank(2, UNBRIDLED_WRATH)
    end
    return self._unbridledWrathRank
end

-- 缓存强化斩杀等级，用于计算最低斩杀成本与深武器的预留怒气。
function P:GetImprovedExecuteRank()
    if self._improvedExecuteRank == nil then
        self._improvedExecuteRank = math.max(0, math.min(2, (TalentRank(2, IMPROVED_EXECUTE))))
    end
    return self._improvedExecuteRank
end

-- 缓存强化英勇打击等级，使排队成本与实际天赋减耗一致。
function P:GetImprovedHeroicStrikeRank()
    if self._improvedHeroicStrikeRank == nil then
        self._improvedHeroicStrikeRank = math.max(0, math.min(3,
            (TalentRank(1, IMPROVED_HEROIC_STRIKE))))
    end
    return self._improvedHeroicStrikeRank
end

-- 缓存碾碎等级，同时用于旋风冷却与顺劈成本的修正。
function P:GetRavagerRank()
    if self._ravagerRank == nil then
        self._ravagerRank = math.max(0, math.min(3, (TalentRank(2, RAVAGER))))
    end
    return self._ravagerRank
end

-- 按已点乱舞天赋选择狂暴策略，不依赖当前是否有乱舞 Buff。
-- 嗜血也能识别未点乱舞的深狂暴，但无嗜血的双手狂暴不受影响。
function P:IsFury()
    if self._flurryRank == nil then
        self._flurryRank = TalentRank(2, FLURRY)
    end
    return self._flurryRank > 0 or D:IsKnown("BLOODTHIRST")
end

-- 合并暴击加权伤害项、固定速度项与怒不可遏期望，估算一刀正常白字的回怒。
-- speed 使用武器基础速度，不是乱舞等加速后的实际白字间隔。
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

-- 从装备与单位面板读取伤害、基础速度和暴击，估计下一刀回怒；必要数据缺失时返回 nil。
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
    -- 客户端单位伤害已包含双手武器专精等修正，不能再乘一次 1.06。
    local damage = (minimum + maximum) / 2
    local crit = BCS and ReadNumber(BCS.GetCritChance, BCS) or nil
    local rage = ExpectedWhiteRage(damage, speed, crit, unbridledWrathRank)
    if rage < 0 then return nil end
    return math.floor(rage + 0.5)
end

-- 清理当前角色会话的冷却、白字周期和天赋缓存，避免切角色或循环后沿用旧状态。
function P:ResetRuntime()
    self._cooldownUntil = {}
    self._cooldownCycle = {}
    self._apiCooldownActive = {}
    self._lastSwingProgress = nil
    self._swingCycle = 0
    self._slamUsedInCycle = false
    self._returnToBerserkerAfterOverpower = false
    self._pendingSunderUntil = nil
    self._unbridledWrathRank = nil
    self._improvedExecuteRank = nil
    self._improvedHeroicStrikeRank = nil
    self._ravagerRank = nil
    self._flurryRank = nil
    self._talentDebugLogged = nil
end

-- 通过白字进度回绕识别新周期，重置“每个周期最多一次猛击”的标记。
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
    if progress and (not previous or progress < (previous - 0.50)) then
        self._swingCycle = (tonumber(self._swingCycle) or 0) + 1
    end
    if progress and previous and progress < (previous - 0.50) then
        self._slamUsedInCycle = false
    end
    if progress then self._lastSwingProgress = progress end
    swing.cycle = tonumber(self._swingCycle) or 0
    swing.slamUsed = self._slamUsedInCycle == true
end

-- 天赋／技能变化时清缓存；施法事件更新猛击次数、破甲防重标记和独立技能冷却。
function P:OnEvent(eventName, a1, a2)
    if eventName == "PLAYER_ENTERING_WORLD" then
        self:ResetRuntime()
        return
    end
    if eventName == "SPELLS_CHANGED"
        or eventName == "CHARACTER_POINTS_CHANGED"
        or eventName == "PLAYER_TALENT_UPDATE" then
        self._unbridledWrathRank = nil
        self._improvedExecuteRank = nil
        self._improvedHeroicStrikeRank = nil
        self._ravagerRank = nil
        self._flurryRank = nil
        self._talentDebugLogged = nil
        self._cooldownUntil = {}
        self._apiCooldownActive = {}
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
                self._returnToBerserkerAfterOverpower = true
            end
            return
        end
    end
end

-- 一次开启／天赋变更只输出一份快照，不在每帧记录变化的怒气或伤害。
function P:DebugTalents(state)
    if not D.debugMode then self._talentDebugLogged = nil; return end
    if self._talentDebugLogged then return end
    self._talentDebugLogged = true
    local talents = {
        { 1, IMPROVED_HEROIC_STRIKE, 3 },
        { 1, zh and "双手武器专精" or "Two-Handed Weapon Specialization", 3 },
        { 1, zh and "无边怒火" or "Boundless Anger", 3 },
        { 1, zh and "精准砍杀" or "Precision Cut", 3 },
        { 2, RAVAGER, 3 },
        { 2, IMPROVED_EXECUTE, 2 },
        { 2, UNBRIDLED_WRATH, 5 },
        { 2, FLURRY, 5 },
    }
    local lines = {}
    local ranks = {}
    local i
    for i = 1, table.getn(talents) do
        local talent = talents[i]
        local rank, status = TalentRank(talent[1], talent[2])
        ranks[i] = rank
        table.insert(lines, string.format("%s=%s/%d read=%s",
            talent[2], tostring(rank), talent[3], status))
    end
    local actualMax = ReadNumber(UnitManaMax, "player")
    table.insert(lines, "rotation=" .. (self:IsFury() and "fury" or "arms"))
    local _, wwDuration = D:GetNonGCDCooldown("WHIRLWIND", state.now)
    table.insert(lines, string.format(
        "computed: HS=%s Cleave=%s Execute=%s WW-model=%gs WW-api=%ss",
        tostring(Cost(state, "HEROIC_STRIKE")), tostring(Cost(state, "CLEAVE")),
        tostring(Cost(state, "EXECUTE")), BaseCooldown("WHIRLWIND"),
        tostring(wwDuration)))
    table.insert(lines, string.format(
        "rage: modelMax=%s apiMax=%s usedMax=%s match=%s; nextWhite=%s",
        tostring(100 + 10 * ranks[3]), tostring(actualMax), tostring(state.maxRage),
        tostring(actualMax == 100 + 10 * ranks[3]), tostring(state.predictedMainHandRage)))
    table.insert(lines, string.format(
        "damage: twoHand-model=%s unitMin=%s unitMax=%s (API already modified); executeExtraMultiplier=%s (analysis only)",
        tostring(1 + 0.02 * ranks[2]),
        tostring(ReadNumber(GetUnitField, "player", "minDamage")),
        tostring(ReadNumber(GetUnitField, "player", "maxDamage")),
        tostring(1 + 0.25 * ranks[4])))
    local api = pfUI and pfUI.swingtimer and pfUI.swingtimer.api
    local ok, written = false, false
    if api and type(api.AppendTrace) == "function" then
        ok, written = pcall(api.AppendTrace, "DDPS_TALENTS", table.concat(lines, " | "))
    end
    for i = 1, table.getn(lines) do D:Print("[talents] " .. lines[i]) end
    D:Print("[talents] file=" .. (ok and written and "written" or "unavailable")
        .. "; WW-api=0 means no active cooldown; nil means unavailable")
end

-- 向 Core.State 补充双手战士决策所需的怒气、光环、白字时序与真实近战距离。
function P:BuildState(state)
    -- 资源与配置输入。
    state.resourceType = "rage"
    state.timingType = "swing"
    state.rage = D:GetRage()
    -- UnitManaMax 已包含无边怒火：满级为 130，不能再额外加 30。
    state.maxRage = D.GetMaxRage and D:GetMaxRage() or 100
    state.playerHP = D:GetPlayerHealthPercent()
    state.stance = D:GetStance()
    state.profileDB = D:GetProfileDB(self.key)
    state.rotationDB = self:GetRotationDB(state.mode)
    state.tier3TwoPiece = D.DB and D.DB.tier3TwoPiece == true
    -- 光环与触发状态输入。
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
    -- 白字时序与下一刀预期怒气共同决定猛击和下一刀排队技能。
    state.swing = D:GetSwingState(state.swing)
    self:ObserveSwingCycle(state.swing)
    state.unbridledWrathRank = self:GetUnbridledWrathRank()
    state.predictedMainHandRage = EstimateNextWhiteRage(
        state.unbridledWrathRank
    )
    self:DebugTalents(state)

    -- 使用已学会的近战技能作为权威距离探针。
    local strike = StrikeKey()
    local meleeKey = D:IsKnown(strike) and strike
        or (D:IsKnown("SLAM") and "SLAM" or nil)
    local inMelee = D:IsMeleeRange("target", meleeKey)
    if inMelee == nil and tonumber(state.targetDistance) then
        inMelee = tonumber(state.targetDistance) <= 5
    end
    state.meleeRangeKey = meleeKey
    state.inMelee = state.targetValid and inMelee == true or false
end

-- 为压制的冷却展示项补充触发状态与触发剩余时间。
function P:DecorateCooldown(key, entry, state)
    if key == "OVERPOWER" then
        entry.proc = state.overpower
        entry.procRemaining = state.overpowerRemaining
    end
end

-- 取得允许猛击延迟白字的秒数，默认 0.17 秒，并限制在配置支持的范围内。
local function SlamClip(state)
    return math.max(0, math.min(0.30,
        tonumber(RotationValue(state, "slamClip")) or 0.17))
end

-- 当前／前置动作锁结束后，若一次猛击能在允许的白字卡条范围内完成，则返回 true。
-- 此处只检查白字周期和时间，不判断怒气是否足够。
local function SlamFits(state, minimumLock)
    local swing = state.swing
    if not Enabled(state, "SLAM") or not swing or not swing.active or swing.slamUsed
        or swing.slamCapable == false then
        return false
    end
    local lock = math.max(
        tonumber(state.gcd) or 0,
        tonumber(minimumLock) or 0
    )
    local remaining = (tonumber(swing.remaining) or 0)
        - lock
    return remaining + SlamClip(state) >= (tonumber(swing.slamCast) or 2.5)
end

-- 最后 0.20 秒的提交保护固定，玩家只调整贴刀窗口何时开始。
local function ExecuteLead(state)
    return math.max(0.25, math.min(1.0,
        tonumber(RotationValue(state, "executeLead")) or 0.55))
end

-- 深武器贴刀窗口：GCD 已解锁，白字剩余时间默认处于 (0.20, 0.55] 秒。
local function CanCastExecuteOnCurrentSwing(state)
    local swing = state and state.swing
    local remaining = swing and tonumber(swing.remaining)
    if not swing or not swing.active or not remaining then return false end
    return (tonumber(state.gcd) or 0) <= 0.05
        and remaining > EXECUTE_TAIL_GUARD
        and remaining <= ExecuteLead(state)
end

-- 本地白字计时可能落后于服务器，最后 0.20 秒内不再提交英勇／顺劈排队请求。
-- 英勇／顺劈只在后半周期泄怒，不因 GCD 或猛击次数标记而抢占新周期起点。
local function CanQueueOnCurrentSwing(state)
    local swing = state and state.swing
    local remaining = swing and tonumber(swing.remaining)
    local speed = swing and tonumber(swing.speed)
    if not remaining or not speed or speed <= 0 or remaining > speed * 0.5 then
        return false
    end
    return swing and swing.active and remaining
        and remaining > ON_SWING_QUEUE_GUARD
end

-- 深武器前置瞬发的时间限制：当前 GCD 与一次瞬发结束后，仍留有安全斩杀窗口。
-- 无白字数据时不额外拦截前置瞬发；斩杀自身仍需单独通过窗口检查。
local function CanFitExecuteFollowup(state)
    local swing = state.swing
    if not swing or not swing.active or not swing.remaining then return true end
    local lock = (tonumber(state.gcd) or 0) + GCD_LOCK
    return swing.remaining > (lock + EXECUTE_TAIL_GUARD)
end

-- 计算未来 horizon 秒内预计到达的白字次数；firstAt 可指定第一刀的相对到达时间。
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

-- 估算支付固定技能成本后，到 horizon 秒时的怒气；已排队的那刀不计正常白字收入。
-- 不适用于清空全部余怒的斩杀；firstRageAt 可用于推迟猛击期间的首笔白字回怒。
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

-- 比较直接等旋风与先做其他动作两条路径，判断后者是否会耗尽横扫层数或拖过持续时间。
local function SweepingNeedsWhirlwind(state, afterActionAt, actionHits, firstSwingAt)
    if not state.sweepingStrikes or state.stance ~= 3
        or not Enabled(state, "WHIRLWIND") then
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

-- 检查等待指定瞬发冷却并释放后，是否仍有足够怒气和白字时间完成本轮猛击。
local function CanWaitForInstantThenSlam(state, key, minimumLock)
    if not Enabled(state, key)
        or (key == "WHIRLWIND" and state.stance ~= 3)
        or AvailableRage(state)
            < (Cost(state, key) + Cost(state, "SLAM")) then
        return false
    end
    local lock = math.max(
        tonumber(state.gcd) or 0,
        tonumber(minimumLock) or 0,
        CooldownRemaining(state, key)
    )
    return SlamFits(state, lock + GCD_LOCK)
end

-- 返回 (useSlamNow, instantBeforeSlam)。第二个值表示先打该瞬发后，仍保留足够
-- 怒气和白字时间接一次猛击。
local function ShouldUseSlam(state, minimumLock)
    local aoe = P:NormalizeMode(state.mode) == "aoe"
    local queued = IsOnSwingQueued(state)
    local aoeCleave = aoe and IsCleaveQueued(state)
    if state.stance == 2 or not Ready(state, "SLAM")
        or (queued and not aoeCleave and not P:IsFury())
        or not SlamFits(state, minimumLock) then
        return false
    end

    if IsExecutePhase(state) and not aoe and not P:IsFury() then return true end

    local strike = StrikeKey()
    if CanWaitForInstantThenSlam(state, strike, minimumLock) then
        return false, strike
    end
    if CanWaitForInstantThenSlam(state, "WHIRLWIND", minimumLock) then
        return false, "WHIRLWIND"
    end

    if aoe and Enabled(state, "WHIRLWIND") then
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

-- 群体中就绪旋风优先；单体还需保留安全猛击及近期嗜血／致死所需的怒气。
local function ShouldUseWhirlwind(state)
    if not Ready(state, "WHIRLWIND") then return false end
    if P:NormalizeMode(state.mode) == "aoe" then return true end

    if SlamFits(state)
        and (tonumber(state.rage) or 0)
            < (Cost(state, "WHIRLWIND") + Cost(state, "SLAM")) then
        return false
    end

    local strike = StrikeKey()
    local strikeRemaining = CooldownRemaining(state, strike)
    local afterWhirlwind = (tonumber(state.gcd) or 0) + GCD_LOCK
    if Enabled(state, strike)
        and strikeRemaining <= (afterWhirlwind + 0.10) then
        local strikeAt = math.max(strikeRemaining, afterWhirlwind)
        if RageAfterSpendAt(state, "WHIRLWIND", strikeAt)
            < Cost(state, strike) then
            return false
        end
    end
    return true
end

-- 判断群体中能否穿插已学的嗜血／致死，保护旋风的横扫覆盖和怒气预算。
local function ShouldUseStrikeAoE(state)
    local strike = StrikeKey()
    if not Ready(state, strike) then return false end
    if not Enabled(state, "WHIRLWIND") or state.stance ~= 3 then return true end

    local start = tonumber(state.gcd) or 0
    local whirlwindRemaining = CooldownRemaining(state, "WHIRLWIND")
    local afterStrike = math.max(
        whirlwindRemaining,
        start + GCD_LOCK
    )
    if SweepingNeedsWhirlwind(state, afterStrike, 1) then
        return false
    end
    if whirlwindRemaining >= start + GCD_LOCK then return true end
    return RageAfterSpendAt(
        state,
        strike,
        afterStrike
    ) >= Cost(state, "WHIRLWIND")
end

-- 狂暴斩杀机会判断：保护当前安全猛击、近期可负担的瞬发及下一轮猛击时间／怒气。
-- 额外耗怒上限默认 10；下轮猛击保护可单独关闭，当前猛击与核心瞬发保护始终保留。
-- 斩杀阶段、最低怒气与排队状态由 ExecuteDue 统一检查。
local function FuryExecuteFits(state)
    if state.casting or (tonumber(state.gcd) or 0) > 0.05 then return false end
    local swing = state.swing
    local remaining = swing and tonumber(swing.remaining)
    local speed = swing and tonumber(swing.speed)
    if not swing or not swing.active or not remaining or not speed or speed <= 0
        or remaining <= EXECUTE_TAIL_GUARD then return false end
    if Ready(state, "SLAM") and SlamFits(state) then return false end

    local rage = AvailableRage(state)
    local extraRage = math.max(0, math.min(30,
        tonumber(RotationValue(state, "furyExecuteExtraRage")) or 10))
    if rage > Cost(state, "EXECUTE") + extraRage then return false end
    -- ponytail: 只复用正常白字回怒期望，不模拟风怒或受击回怒；实机日志证明必要时再扩展。
    local predicted = math.max(0, tonumber(state.predictedMainHandRage) or 0)
    local horizon = math.max(remaining, GCD_LOCK)
    local i
    for i = 1, table.getn(CORE_STRIKES) do
        local key = CORE_STRIKES[i]
        if Enabled(state, key) and (key ~= "WHIRLWIND" or state.stance == 3) then
            local cost = Cost(state, key)
            local at = math.max(CooldownRemaining(state, key),
                rage < cost and remaining or 0)
            if at <= horizon then
                local income = SwingHitsBy(state, at) * predicted
                -- 斩杀消耗全部当前怒气；不能让原本可用的瞬发丢失 GCD 窗口或施放资金。
                if rage + income >= cost
                    and (at < GCD_LOCK or income < cost) then return false end
            end
        end
    end

    if RotationValue(state, "furyProtectNextSlam") ~= false
        and Enabled(state, "SLAM") and swing.slamCapable ~= false then
        local start = math.max(remaining, GCD_LOCK)
        if start + (tonumber(swing.slamCast) or 2.5)
            > remaining + speed + SlamClip(state) then return false end
        local income = SwingHitsBy(state, start) * predicted
        if rage + income >= Cost(state, "SLAM")
            and income < Cost(state, "SLAM") then return false end
    end
    return true
end

-- 斩杀的共同入口：确认阶段、怒气与队列状态，再按天赋选择贴刀或机会判定。
-- 推荐、预测与实际按键执行均复用此处，避免各自放行条件不同。
local function ExecuteDue(state)
    if not IsExecutePhase(state) or not Ready(state, "EXECUTE")
        or IsOnSwingQueued(state) then return false end
    if P:IsFury() then return FuryExecuteFits(state) end
    return CanCastExecuteOnCurrentSwing(state)
end

-- 深武器斩杀阶段的预算门槛：保留斩杀怒气；当前可打猛击时也保留猛击怒气；同时要求
-- 下一次白字前至少还能容纳一个后续动作窗口。
local function CanUseInstantBeforeExecute(state, key, slamNow)
    local rage = tonumber(state.rage) or 0
    local reserve = Cost(state, "EXECUTE")
    if slamNow then reserve = reserve + Cost(state, "SLAM") end
    return rage >= (Cost(state, key) + reserve)
        and CanFitExecuteFollowup(state)
end

-- 按配置检查战斗中是否需要补战吼，同时确认最低怒气与独立冷却。
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

-- 首次破甲或剩余不足五秒时请求补破甲，已确认施法的 GCD 内防止重复建议。
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

-- 构造破甲建议；仅深武器在斩杀阶段额外保留后续斩杀的怒气和时间。
local function RecommendSunder(action, state)
    if not SunderNeedsRefresh(state) then return nil end
    if IsExecutePhase(state) and not P:IsFury()
        and ((tonumber(state.rage) or 0)
                < (Cost(state, "SUNDER_ARMOR")
                    + Cost(state, "EXECUTE"))
            or not CanFitExecuteFollowup(state)) then
        return nil
    end
    return ApplyGCD(SetAction(action, "SUNDER_ARMOR", R.SUNDER_ARMOR), state)
end

-- 排队会替换眼前白字；下一笔正常白字收入前，先留出计划动作与核心技能成本。
-- plannedKey 是尚未释放的计划动作；狂暴另外预留下一轮猛击成本。
local function OnSwingReserve(state, plannedKey)
    local speed = tonumber(state.swing.speed) or 3.5
    if speed <= 0 then speed = 3.5 end
    local nextRageAt = (tonumber(state.swing.remaining) or 0)
        + speed
    local reserve = plannedKey and Cost(state, plannedKey) or 0
    if plannedKey ~= "WHIRLWIND" and Enabled(state, "WHIRLWIND")
        and CooldownRemaining(state, "WHIRLWIND") <= nextRageAt then
        reserve = reserve + Cost(state, "WHIRLWIND")
    end
    local strike = StrikeKey()
    if plannedKey ~= strike and Enabled(state, strike)
        and CooldownRemaining(state, strike) <= nextRageAt then
        reserve = reserve + Cost(state, strike)
    end
    if P:IsFury() and Enabled(state, "SLAM") and state.swing.slamCapable ~= false then
        reserve = reserve + Cost(state, "SLAM")
    end
    return reserve
end

-- 预计下一刀触顶且核心预算充足时才排队英勇，避开猛击窗口与白字尾部。
-- 深武器在斩杀阶段关闭此出口，狂暴保留它处理溢怒。
local function ShouldQueueHeroicStrike(state, plannedKey)
    if (IsExecutePhase(state) and not P:IsFury()) or not D:IsKnown("HEROIC_STRIKE")
        or IsOnSwingQueued(state) or not CanQueueOnCurrentSwing(state)
        or SlamFits(state)
        or (tonumber(state.rage) or 0)
            < Cost(state, "HEROIC_STRIKE") + OnSwingReserve(state, plannedKey) then
        return false
    end
    local predicted = tonumber(state.predictedMainHandRage) or 0
    return (tonumber(state.rage) or 0) + predicted
        >= (tonumber(state.maxRage) or 100)
end

-- 顺劈只用于泄怒，不是核心动作：必须预留当前计划 GCD 技能，以及即将可用的
-- 已学核心瞬发的怒气，并保护横扫层数。
-- 深武器到点斩杀时禁止顺劈，狂暴则继续按资源与横扫预算判断。
local function ShouldQueueCleave(
    state,
    sweepingPending,
    plannedKey,
    executeDue
)
    if sweepingPending or (executeDue and not P:IsFury()) or not D:IsKnown("CLEAVE")
        or IsOnSwingQueued(state)
        or not CanQueueOnCurrentSwing(state) or SlamFits(state) then
        return false
    end

    local rage = AvailableRage(state)
    local plannedCost = plannedKey and Cost(state, plannedKey) or 0
    local projected = rage - plannedCost
    local threshold = tonumber(RotationValue(state, "cleaveRage")) or 95
    local predicted = tonumber(state.predictedMainHandRage)
    local capRisk = predicted ~= nil
        and projected + predicted >= (tonumber(state.maxRage) or 100)
    if rage < threshold and not capRisk then return false end

    local swingAt = tonumber(state.swing.remaining) or 0
    local speed = tonumber(state.swing.speed) or 3.5
    if speed <= 0 then speed = 3.5 end
    local reserve = OnSwingReserve(state, plannedKey)
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

-- 普通回狂暴的保护：排队时不切；战斗中非防御姿态只在可保留的低怒范围内切换。
local function CanSwitchToBerserkerStance(state)
    if IsOnSwingQueued(state) then return false end
    if not state.inCombat or state.stance == 2 then return true end
    return (tonumber(state.rage) or 0) <= STANCE_RAGE
end

-- 构造回狂暴姿态建议；压制往返或群体横扫完成后，可绕过普通切姿态的低怒限制。
local function RecommendBerserkerStance(action, state)
    local returnRequired = state.stance == 1 and not IsOnSwingQueued(state)
        and (P._returnToBerserkerAfterOverpower
            or (state.sweepingStrikes
                and P:NormalizeMode(state.mode) == "aoe"))
    if state.stance == 3 then P._returnToBerserkerAfterOverpower = false end
    if D:IsKnown("BERSERKER_STANCE") and NeedsStance(state, 3)
        and (returnRequired or CanSwitchToBerserkerStance(state)) then
        return StanceAction(action, "BERSERKER_STANCE", R.BERSERKER_STANCE, state)
    end
    return nil
end

-- 有可用压制触发时生成建议，需要转战斗姿态则检查怒气与下一刀队列。
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

-- 通过旋风优先级检查后生成建议；必要且允许时，先返回切狂暴姿态动作。
local function RecommendWhirlwind(action, state)
    if not ShouldUseWhirlwind(state) then return nil end
    if NeedsStance(state, 3) then
        if CanSwitchToBerserkerStance(state) then
            return RecommendBerserkerStance(action, state)
        end
        return nil
    end
    return ApplyGCD(SetAction(action, "WHIRLWIND", R.WHIRLWIND), state)
end

-- 构造斩杀及对应流派的原因说明；防御姿态下先建议转战斗姿态。
-- 完整斩杀条件由调用方的 ExecuteDue 校验，此处不重复决定技能优先级。
local function RecommendExecute(action, state)
    if not Ready(state, "EXECUTE") then return nil end
    if state.stance == 2 and D:IsKnown("BATTLE_STANCE") then
        return StanceAction(action, "BATTLE_STANCE", R.BATTLE_STANCE, state)
    end
    return ApplyGCD(SetAction(action, "EXECUTE",
        P:IsFury() and R.FURY_EXECUTE or R.EXECUTE), state)
end

-- 按已确认队列、GCD、白字与怒气情况，生成当前无法施放技能的等待说明。
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

-- 单体优先级分组（从高到低）：
-- 压制姿态往返 → 安全维护技能 → 深武器斩杀阶段怒气预算 →
-- 常规瞬发／猛击配对 → 泄怒／狂暴机会斩杀或等待。
local function RecommendSingle(action, state)
    local executePhase = IsExecutePhase(state)
    local fury = P:IsFury()

    if P._returnToBerserkerAfterOverpower then
        local berserkerAction = RecommendBerserkerStance(action, state)
        if berserkerAction then return berserkerAction end
    end

    local overpower = RecommendOverpower(action, state)
    if overpower then return overpower end

    if BattleShoutNeedsRefresh(state)
        and (not executePhase or fury
            or ((tonumber(state.rage) or 0)
                    >= (Cost(state, "BATTLE_SHOUT")
                        + Cost(state, "EXECUTE"))
                and CanFitExecuteFollowup(state))) then
        return ApplyGCD(SetAction(action, "BATTLE_SHOUT", R.BATTLE_SHOUT), state)
    end

    local sunder = RecommendSunder(action, state)
    if sunder then return sunder end

    if executePhase and not fury then
        local slamNow = ShouldUseSlam(state)
        if Ready(state, "MORTAL_STRIKE")
            and CanUseInstantBeforeExecute(state, "MORTAL_STRIKE", slamNow) then
            return ApplyGCD(SetAction(
                action,
                "MORTAL_STRIKE",
                R.MORTAL_STRIKE
            ), state)
        end

        if CanUseInstantBeforeExecute(state, "WHIRLWIND", slamNow) then
            local whirlwind = RecommendWhirlwind(action, state)
            if whirlwind then return whirlwind end
        end

        if slamNow then
            return ApplyGCD(SetAction(action, "SLAM", R.SLAM), state)
        end
        if ExecuteDue(state) then return RecommendExecute(action, state) end
        return WaitAction(action, state)
    end

    local slamNow, instantBeforeSlam = ShouldUseSlam(state)
    if slamNow then
        return ApplyGCD(SetAction(action, "SLAM", R.SLAM), state)
    end

    if instantBeforeSlam == "WHIRLWIND" or (fury and instantBeforeSlam) then
        if Ready(state, instantBeforeSlam) then
            return ApplyGCD(SetAction(
                action,
                instantBeforeSlam,
                R[instantBeforeSlam]
            ), state)
        end
        return WaitAction(action, state)
    end

    local strike = StrikeKey()
    if Ready(state, strike) then
        return ApplyGCD(SetAction(
            action,
            strike,
            R[strike]
        ), state)
    end

    local whirlwind = RecommendWhirlwind(action, state)
    if whirlwind then return whirlwind end

    local berserkerAction = RecommendBerserkerStance(action, state)
    if berserkerAction then return berserkerAction end

    if ShouldQueueHeroicStrike(state) then
        return SetAction(action, "HEROIC_STRIKE", R.HEROIC_STRIKE, "queue")
    end
    if fury and ExecuteDue(state) then return RecommendExecute(action, state) end
    return WaitAction(action, state)
end

-- 返回横扫／切姿态建议与“正在准备横扫”标记；未学、关闭或未就绪时跳过准备。
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

-- AOE 优先级分组（从高到低）：
-- 低怒压制 → 准备／开启横扫 → 返回狂暴姿态 → 旋风 → 受保护的顺劈泄怒 →
-- 猛击／已学致死或嗜血／斩杀 → 维护技能。
local function RecommendAoE(action, state)
    local overpower = RecommendOverpower(action, state)
    if overpower then return overpower end

    local sweepingAction, sweepingPending = SweepingPending(action, state)
    if sweepingAction then return sweepingAction end

    if sweepingPending then
        local rage = AvailableRage(state)
        local reserve = Cost(state, "SWEEPING_STRIKES")
        local strike = StrikeKey()
        if rage >= (Cost(state, strike) + reserve)
            and Ready(state, strike) then
            return ApplyGCD(SetAction(
                action,
                strike,
                R[strike]
            ), state)
        end
        if not IsOnSwingQueued(state)
            and state.stance ~= 1 and D:IsKnown("BATTLE_STANCE") then
            return StanceAction(action, "BATTLE_STANCE", R.BATTLE_STANCE, state)
        end
        return WaitAction(action, state)
    end

    if state.sweepingStrikes then
        local berserkerAction = RecommendBerserkerStance(action, state)
        if berserkerAction then return berserkerAction end
    end

    local whirlwind = RecommendWhirlwind(action, state)
    if whirlwind then return whirlwind end

    local slamNow = ShouldUseSlam(state)
    local strike = StrikeKey()
    local strikeNow = ShouldUseStrikeAoE(state)
    local executeNow = ExecuteDue(state)
    local plannedKey = slamNow and "SLAM"
        or (strikeNow and strike or nil)
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

    if strikeNow then
        return ApplyGCD(SetAction(
            action,
            strike,
            R[strike]
        ), state)
    end

    if IsExecutePhase(state) and executeNow then
        return RecommendExecute(action, state)
    end

    local sunder = RecommendSunder(action, state)
    if sunder then return sunder end

    if BattleShoutNeedsRefresh(state) then
        return ApplyGCD(SetAction(action, "BATTLE_SHOUT", R.BATTLE_SHOUT), state)
    end

    local berserkerAction = RecommendBerserkerStance(action, state)
    if berserkerAction then return berserkerAction end
    return WaitAction(action, state)
end

-- 统一推荐入口：先处理目标、距离和姿态，再分发单体／群体；GCD 中仍可独立建议排队泄怒。
function P:Recommend(state)
    local action = self._rec
    if not state.targetValid then
        return SetAction(action, "WAIT", D.Text.WAIT_TARGET, "disabled")
    end

    if not state.inMelee then
        local berserkerAction = RecommendBerserkerStance(action, state)
        if berserkerAction then return berserkerAction end
        return SetAction(
            action,
            "WAIT",
            state.targetRangeState == "grace"
                and D.Text.RANGE_GRACE or D.Text.OUT_OF_RANGE,
            "range"
        )
    end

    if not state.inCombat or state.stance == 2 then
        local berserkerAction = RecommendBerserkerStance(action, state)
        if berserkerAction then return berserkerAction end
    end

    local aoe = self:NormalizeMode(state.mode) == "aoe"
    if aoe then
        action = RecommendAoE(action, state)
    else
        action = RecommendSingle(action, state)
    end

    -- 等待 GCD 的普通技能不能占住不受 GCD 限制的下一刀排队机会。
    -- 姿态、横扫和斩杀仍独占其原有决策窗口。
    if action.state == "gcd" and (action.key == "MORTAL_STRIKE" or action.key == "BLOODTHIRST"
        or action.key == "WHIRLWIND" or action.key == "SLAM"
        or action.key == "BATTLE_SHOUT" or action.key == "SUNDER_ARMOR") then
        if aoe then
            local sweepingPending = RotationValue(state, "useSweepingStrikes") ~= false
                and not state.sweepingStrikes and Ready(state, "SWEEPING_STRIKES")
            if ShouldQueueCleave(state, sweepingPending, action.key, ExecuteDue(state)) then
                return SetAction(action, "CLEAVE", R.CLEAVE, "queue")
            end
        elseif action.key ~= "SLAM" and ShouldQueueHeroicStrike(state, action.key) then
            return SetAction(action, "HEROIC_STRIKE", R.HEROIC_STRIKE, "queue")
        end
    end
    return action
end

-- 重建候选表；Lua 5.0 的 table.insert 长度缓存可能在旧元素赋 nil 后仍然保留。
local function ClearCandidates()
    P._candidates = {}
end

-- 只添加当前阶段启用且已学的预测候选。
local function AddCandidate(state, key, eta, priority, uncertain)
    if not Enabled(state, key) then return end
    table.insert(P._candidates, {
        key = key,
        eta = math.max(0, tonumber(eta) or 0),
        priority = priority or PRIORITY[key] or 50,
        uncertain = uncertain and true or false,
    })
end

-- 预计时间接近时按技能优先级排序，其余按预计可用时间先后排列。
local function CandidateSort(a, b)
    if math.abs((a.eta or 0) - (b.eta or 0)) < 0.05 then
        return (a.priority or 50) < (b.priority or 50)
    end
    return (a.eta or 0) < (b.eta or 0)
end

-- 预测下一次可用时间；当前正在推荐的就绪技能视为即将施放，向后推一个基础冷却。
local function ForecastCooldown(state, current, key)
    local eta = CooldownRemaining(state, key)
    if current.key == key and eta <= 0.05 then
        eta = BaseCooldown(key) or GCD_LOCK
    end
    return eta
end

-- 预测只供参考：独立估算各动作可用时间，先按 ETA、再按优先级排序，并排除当前
-- 动作；不会递归模拟未来推荐，也不会修改战斗状态。
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
            state,
            "OVERPOWER",
            ForecastCooldown(state, current, "OVERPOWER"),
            PRIORITY.OVERPOWER,
            (tonumber(state.rage) or 0) > STANCE_RAGE and state.stance ~= 1
        )
    end

    if IsExecutePhase(state) and current.key ~= "EXECUTE" then
        local eta = nil
        local swing = state.swing
        local remaining = swing and tonumber(swing.remaining)
        if self:IsFury() then
            -- 狂暴斩杀不保证每刀出现；只复用执行条件展示当前确实成立的机会。
            if (current.key == "WAIT" or current.key == "AUTO_ATTACK")
                and ExecuteDue(state) then eta = 0 end
        elseif swing and swing.active and remaining then
            local windowStart = ExecuteLead(state)
            local wait = math.max(
                0,
                tonumber(state.gcd) or 0,
                remaining - windowStart
            )
            if remaining - wait > EXECUTE_TAIL_GUARD then
                eta = wait
            else
                local speed = tonumber(swing.speed) or 0
                if speed > windowStart then
                    eta = remaining + speed - windowStart
                end
            end
        end
        if eta then
            AddCandidate(
                state,
                "EXECUTE",
                eta,
                PRIORITY.EXECUTE,
                (tonumber(state.rage) or 0) < Cost(state, "EXECUTE")
            )
        end
    end

    if self:NormalizeMode(state.mode) == "aoe" then
        if RotationValue(state, "useSweepingStrikes") ~= false
            and not state.sweepingStrikes then
            AddCandidate(
                state,
                "SWEEPING_STRIKES",
                ForecastCooldown(state, current, "SWEEPING_STRIKES"),
                PRIORITY.SWEEPING_STRIKES,
                AvailableRage(state) < Cost(state, "SWEEPING_STRIKES")
            )
        end
    end

    if current.key ~= "SLAM" and Enabled(state, "SLAM")
        and state.swing and state.swing.active and not state.swing.slamUsed then
        local lock = (current.key == "AUTO_ATTACK" or current.key == "WAIT"
            or current.key == "HEROIC_STRIKE" or current.key == "CLEAVE")
            and 0 or GCD_LOCK
        local eta = state.swing.remaining or 0
        if SlamFits(state, lock) then eta = lock end
        AddCandidate(
            state,
            "SLAM",
            eta,
            PRIORITY.SLAM,
            AvailableRage(state) < Cost(state, "SLAM")
        )
    end

    local strike = StrikeKey()
    AddCandidate(
        state,
        strike,
        ForecastCooldown(state, current, strike),
        PRIORITY[strike],
        AvailableRage(state) < Cost(state, strike)
    )
    AddCandidate(
        state,
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

-- 成对返回当前建议与后续预测，并清除不属于本循环的资源动作列表。
function P:Evaluate(state)
    local recommendation = self:Recommend(state)
    state.resourceActions = nil
    return recommendation, self:BuildForecast(state, recommendation)
end

-- 英勇／顺劈／斩杀优先使用不进入通用法术队列的 API，接口缺失时回退到原生施法。
local function CastRecommendedAction(action)
    if action.key == "HEROIC_STRIKE" or action.key == "CLEAVE"
        or action.key == "EXECUTE" then
        if CastSpellByNameNoQueue then
            CastSpellByNameNoQueue(action.name)
        else
            CastSpellByName(action.name)
        end
    else
        CastSpellByName(action.name)
    end
end

-- 向可选白字追踪接口记录本次按键执行结果；追踪器缺失时直接跳过。
local function TraceExecute(mode, state, action, result)
    if D.TraceSwingExecution then
        D:TraceSwingExecution("arms", mode, state, action, result)
    end
end

-- 玩家按键触发的执行路径。任何换目标后都重新构建 State，避免根据旧目标的观测
-- 结果施放技能。读条期间直接退出，斩杀与下一刀排队动作在施放前再次校验条件。
function P:Execute(mode)
    mode = self:NormalizeMode(mode)
    D:SetMode(mode, true)
    local state = D:BuildState()
    if state.casting then
        TraceExecute(mode, state, nil, "casting")
        D:Update(true)
        return false
    end

    local changed = D:PrepareExecutionTarget(true, true, state.meleeRangeKey)
    if changed or not state.targetValid then state = D:BuildState() end

    local action = self:Recommend(state)
    if not action or not action.key or action.key == "WAIT"
        or action.key == "AUTO_ATTACK" or not Enabled(state, action.key) then
        TraceExecute(mode, state, action, "wait")
        D:Update(true)
        return false
    end
    if action.key == "EXECUTE" and not ExecuteDue(state) then
        TraceExecute(mode, state, action, "execute-window-closed")
        D:Update(true)
        return false
    end
    if (action.key == "HEROIC_STRIKE" or action.key == "CLEAVE")
        and (IsOnSwingQueued(state) or not CanQueueOnCurrentSwing(state)) then
        TraceExecute(mode, state, action, "on-swing-guard")
        D:Update(true)
        return false
    end

    -- 施法事件可同步刷新 self._rec；队列登记和日志必须保留本次实际提交的动作。
    local submitted = {}
    for key, value in pairs(action) do submitted[key] = value end
    action = submitted
    CastRecommendedAction(action)
    if action.key == "HEROIC_STRIKE" or action.key == "CLEAVE" then
        D:MarkOnSwingQueued(action.key, state.swing)
    end
    TraceExecute(mode, state, action, "cast")
    D:Update(true)
    return true
end
