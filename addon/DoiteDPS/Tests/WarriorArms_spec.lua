-- Focused self-check for the shared two-handed Arms/Fury rotation.
-- Run from Interface/AddOns: lua DoiteDPS/Tests/WarriorArms_spec.lua

local now = 100
local unbridledWrathRank = 0
local improvedExecuteRank = 0
local improvedHeroicStrikeRank = 0
local ravagerRank = 0
local flurryRank = 0
table.getn = table.getn or function(value) return #value end
function GetTime() return now end
function GetLocale() return "zhCN" end
function GetTalentInfo(tab, index)
    if tab == 1 and index == 1 then
        return "强化英勇打击", nil, 1, 1, improvedHeroicStrikeRank, 3
    end
    if tab == 2 and index == 1 then
        return "怒不可遏", nil, 1, 1, unbridledWrathRank, 5
    end
    if tab == 2 and index == 2 then
        return "强化斩杀", nil, 2, 1, improvedExecuteRank, 2
    end
    if tab == 2 and index == 3 then
        return "碾碎", nil, 5, 1, ravagerRank, 3
    end
    if tab == 2 and index == 4 then
        return "乱舞", nil, 6, 3, flurryRank, 5
    end
    return nil
end

local known = {}
local defs = {
    BATTLE_STANCE = { name = "战斗姿态", cost = 0 },
    BERSERKER_STANCE = { name = "狂暴姿态", cost = 0 },
    EXECUTE = { name = "斩杀", cost = 15 },
    OVERPOWER = { name = "压制", cost = 5 },
    MORTAL_STRIKE = { name = "致死打击", cost = 30 },
    BLOODTHIRST = { name = "嗜血", cost = 30 },
    WHIRLWIND = { name = "旋风斩", cost = 25 },
    SLAM = { name = "猛击", cost = 15 },
    HEROIC_STRIKE = { name = "英勇打击", cost = 15 },
    CLEAVE = { name = "顺劈斩", cost = 20 },
    SWEEPING_STRIKES = { name = "横扫攻击", cost = 20 },
    DEATH_WISH = { name = "死亡之愿", cost = 10 },
    BATTLE_SHOUT = { name = "战斗怒吼", cost = 10 },
    SUNDER_ARMOR = { name = "破甲攻击", cost = 10 },
}

DoiteDPS = {
    Recommendation = {},
    Forecasts = {},
    Profiles = {},
    Spells = {},
    WarriorCooldownKeys = {},
    FORECAST_LIMIT = 3,
    GCD_MAX = 1.5,
    Text = {
        WAIT_TARGET = "等待目标",
        WAIT_GCD = "等待公共冷却",
        RANGE_GRACE = "短暂超距",
        OUT_OF_RANGE = "超距",
    },
}
local D = DoiteDPS
local nextSpellId = 1000

for key, def in pairs(defs) do
    def.texture = key
    nextSpellId = nextSpellId + 1
    D.Spells[key] = { spellId = nextSpellId }
    known[key] = true
end
known.BLOODTHIRST = false

function D:GetSpellDef(key) return defs[key] end
function D:GetName(key)
    return defs[key] and defs[key].name or key
end
function D:GetTexture(key)
    return defs[key] and defs[key].texture or key
end
function D:IsKnown(key) return known[key] == true end
function D:GetNonGCDCooldown() return 0, 0 end
function D:GetProfileDB()
    self._profileDB = self._profileDB or {}
    return self._profileDB
end
function D:GetRotationDB(_, mode, defaults)
    local db = self:GetProfileDB()
    db.rotations = db.rotations or {}
    db.rotations[mode] = db.rotations[mode] or {}
    for key, value in pairs(defaults or {}) do
        if db.rotations[mode][key] == nil then
            db.rotations[mode][key] = value
        end
    end
    return db.rotations[mode]
end

dofile("DoiteDPS/Profiles/WarriorArms.lua")
local P = D.Profiles.WarriorArms

local function CoreCooldowns(ms, ww, overpower, sweeping)
    return {
        MORTAL_STRIKE = { remaining = ms or 99, duration = 6 },
        WHIRLWIND = { remaining = ww or 99, duration = 10 },
        OVERPOWER = { remaining = overpower or 99, duration = 5 },
        SWEEPING_STRIKES = { remaining = sweeping or 99, duration = 30 },
    }
end

local function State(values)
    local state = {
        now = now,
        mode = "single",
        targetValid = true,
        inMelee = true,
        inCombat = true,
        targetHP = 100,
        rage = 30,
        maxRage = 100,
        stance = 3,
        gcd = 0,
        cooldowns = CoreCooldowns(),
        rotationDB = P.RotationDefaults.single,
        battleShout = true,
        battleShoutRemaining = 60,
        sunderStacks = 1,
        sunderRemaining = 20,
        sweepingStrikes = false,
        overpower = false,
        targetBoss = false,
        tier3TwoPiece = false,
        predictedMainHandRage = 15,
        swing = {
            active = true,
            remaining = 1.0,
            speed = 3.5,
            slamCast = 1.5,
            slamCapable = true,
            hsQueued = false,
            cleaveQueued = false,
            queuePending = false,
        },
    }
    for key, value in pairs(values or {}) do state[key] = value end
    if state.mode == "aoe" and not (values and values.rotationDB) then
        state.rotationDB = P.RotationDefaults.aoe
    end
    P:ResetRuntime()
    return state
end

local passed = 0
local function Check(label, condition)
    assert(condition, label)
    passed = passed + 1
end

local function ForecastByKey(forecast, key)
    local index = 1
    while index <= table.getn(forecast or {}) do
        if forecast[index] and forecast[index].key == key then
            return forecast[index]
        end
        index = index + 1
    end
    return nil
end

Check(
    "the shared two-handed rotation retains its single and AoE modes",
    table.getn(P.ModeOrder) == 2
        and P.ModeOrder[1] == "single"
        and P.ModeOrder[2] == "aoe"
        and P.ModeLabels.single == "双手战士"
)
local configOptions = {}
for _, option in ipairs(P.ConfigSchema.options) do configOptions[option.key] = option end
Check(
    "Slam exposes a 0.17-second clip limit instead of a safety margin",
    P.RotationDefaults.single.slamClip == 0.17
        and P.RotationDefaults.single.slamSafety == nil
        and configOptions.slamClip.max == 0.30
)
Check(
    "both modes expose Slam timing and retain the original Execute defaults",
    P.RotationDefaults.aoe.slamClip == 0.17
        and configOptions.slamClip.modes[2] == "aoe"
        and P.RotationDefaults.single.executeLead == 0.55
        and P.RotationDefaults.aoe.executeLead == 0.55
        and P.RotationDefaults.single.furyExecuteExtraRage == 10
        and P.RotationDefaults.aoe.furyProtectNextSlam == true
)
Check(
    "white rage prediction applies crit only to the damage component",
    math.abs(P._expectedWhiteRage(746.4286, 3.7, 40) - 37.3718) < 0.001
)
Check(
    "five ranks of Unbridled Wrath add 1.5 expected two-handed rage",
    math.abs(P._expectedWhiteRage(746.4286, 3.7, 40, 5) - 38.8718) < 0.001
)
unbridledWrathRank = 5
Check("the current Unbridled Wrath rank is detected", P:GetUnbridledWrathRank() == 5)
unbridledWrathRank = 0
P:OnEvent("CHARACTER_POINTS_CHANGED")
Check("talent changes refresh Unbridled Wrath", P:GetUnbridledWrathRank() == 0)
improvedExecuteRank = 2
P:OnEvent("CHARACTER_POINTS_CHANGED")
Check("the current Improved Execute rank is detected", P:GetImprovedExecuteRank() == 2)
improvedExecuteRank = 0
P:OnEvent("CHARACTER_POINTS_CHANGED")
Check("talent changes refresh Improved Execute", P:GetImprovedExecuteRank() == 0)
Check(
    "Sunder maintenance is an opt-in setting for both modes",
    P.RotationDefaults.single.maintainSunder == false
        and P.RotationDefaults.aoe.maintainSunder == false
        and configOptions.maintainSunder
)
Check("AoE Cleave defaults to a high-rage dump", P.RotationDefaults.aoe.cleaveRage == 95)

D._profileDB = {
    deepArmsRotationVersion = 1,
    rotations = { single = {}, aoe = { cleaveRage = 40 } },
}
local migratedArmsAoE = P:GetRotationDB("aoe")
Check(
    "the old low Cleave default migrates once",
    migratedArmsAoE.cleaveRage == 95
        and D._profileDB.deepArmsRotationVersion == 2
)
D._profileDB = nil

Check(
    "Tier 3 two-piece is one character-wide Arms setting",
    configOptions.tier3TwoPiece.scope == "general"
        and configOptions.tier3TwoPiece.modes[1] == "single"
        and configOptions.tier3TwoPiece.modes[2] == "aoe"
)
Check(
    "base Sweeping Strikes and Death Wish costs remain unchanged",
    P._rageCost(State(), "SWEEPING_STRIKES") == 20
        and P._rageCost(State(), "DEATH_WISH") == 10
)
Check(
    "Tier 3 two-piece reduces both affected costs by ten rage",
    P._rageCost(State({ tier3TwoPiece = true }), "SWEEPING_STRIKES") == 10
        and P._rageCost(State({ tier3TwoPiece = true }), "DEATH_WISH") == 0
)

P:ResetRuntime()
local observedSwing = { active = true, progress = 0.70 }
P:ObserveSwingCycle(observedSwing)
P:OnEvent("SPELL_CAST_EVENT", 1, D.Spells.SLAM.spellId)
P:ObserveSwingCycle(observedSwing)
Check("a confirmed Slam is consumed inside its white-hit cycle", observedSwing.slamUsed)
local firstSwingCycle = observedSwing.cycle
observedSwing = { active = true, progress = 0.10 }
P:ObserveSwingCycle(observedSwing)
Check(
    "white-hit progress rollover opens a fresh prediction cycle",
    not observedSwing.slamUsed
        and observedSwing.cycle == firstSwingCycle + 1
)

local action = P:Recommend(State({
    rage = 80,
    cooldowns = CoreCooldowns(0, 0),
    swing = {
        active = true,
        remaining = 3.70,
        speed = 3.70,
        slamCast = 1.961,
        slamCapable = true,
    },
}))
Check("a 3.7-speed cycle opens with Mortal Strike", action.key == "MORTAL_STRIKE")

action = P:Recommend(State({
    rage = 44,
    cooldowns = CoreCooldowns(0, 0),
    swing = {
        active = true,
        remaining = 3.63,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("Whirlwind preserves Slam when Mortal Strike cannot", action.key == "WHIRLWIND")

action = P:Recommend(State({
    rage = 45,
    cooldowns = CoreCooldowns(0, 0),
    swing = {
        active = true,
        remaining = 3.63,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("Mortal Strike leads once it can still fund Slam", action.key == "MORTAL_STRIKE")

action = P:Recommend(State({
    rage = 130,
    maxRage = 130,
    cooldowns = CoreCooldowns(0, 0),
    swing = {
        active = true,
        remaining = 3.26,
        speed = 3.55,
        slamCast = 1.92,
        slamCapable = true,
    },
}))
Check("configured Slam clip also permits an instant before Slam", action.key == "MORTAL_STRIKE")

action = P:Recommend(State({
    rage = 130,
    maxRage = 130,
    cooldowns = CoreCooldowns(0, 0),
    rotationDB = { slamClip = 0.15 },
    swing = {
        active = true,
        remaining = 3.26,
        speed = 3.55,
        slamCast = 1.92,
        slamCapable = true,
    },
}))
Check("instant-before-Slam obeys a lower configured clip limit", action.key == "SLAM")

action = P:Recommend(State({
    rage = 80,
    cooldowns = CoreCooldowns(4, 0),
    swing = {
        active = true,
        remaining = 1.0,
        speed = 3.70,
        slamCast = 1.961,
        slamCapable = true,
    },
}))
Check("a ready late Whirlwind is never blocked by the Slam phase", action.key == "WHIRLWIND")

action = P:Recommend(State({
    rage = 30,
    cooldowns = CoreCooldowns(4, 0),
    swing = {
        active = true,
        remaining = 3.5,
        speed = 3.5,
        slamCast = 1.5,
        slamCapable = true,
    },
}))
Check("low rage may use Slam early when no stronger instant is affordable", action.key == "SLAM")

action = P:Recommend(State({
    rage = 60,
    cooldowns = CoreCooldowns(0.5, 99),
    swing = {
        active = true,
        remaining = 3.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("single Slam keeps its real conflict slot ahead of Mortal Strike", action.key == "SLAM")

action = P:Recommend(State({
    rage = 60,
    cooldowns = CoreCooldowns(1.8, 99),
    swing = {
        active = true,
        remaining = 3.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("single Slam remains worthwhile across the full conflict window", action.key == "SLAM")

action = P:Recommend(State({
    rage = 20,
    predictedMainHandRage = 36,
    cooldowns = CoreCooldowns(0.5, 99),
    swing = {
        active = true,
        remaining = 3.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("single Slam never reserves rage for a near-ready Mortal Strike", action.key == "SLAM")

action = P:Recommend(State({
    rage = 20,
    predictedMainHandRage = 15,
    cooldowns = CoreCooldowns(0.5, 99),
    swing = {
        active = true,
        remaining = 3.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("single Slam keeps its rage efficiency ahead of Mortal Strike", action.key == "SLAM")

action = P:Recommend(State({
    rage = 60,
    cooldowns = CoreCooldowns(0.08, 99),
    swing = {
        active = true,
        remaining = 3.63,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("single waits for a free Mortal Strike then Slam sequence", action.key == "AUTO_ATTACK")

action = P:Recommend(State({
    rage = 30,
    cooldowns = CoreCooldowns(0.08, 99),
    swing = {
        active = true,
        remaining = 3.63,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("a free timing slot does not override single-target Slam efficiency", action.key == "SLAM")

action = P:Recommend(State({
    rage = 60,
    cooldowns = CoreCooldowns(0, 99),
    swing = {
        active = true,
        remaining = 2.2,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("a ready Mortal Strike cannot delete the current safe Slam", action.key == "SLAM")

action = P:Recommend(State({
    rage = 30,
    predictedMainHandRage = 36,
    cooldowns = CoreCooldowns(0.5, 0),
    swing = {
        active = true,
        remaining = 1.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("a white hit during Whirlwind's GCD still funds Mortal Strike", action.key == "WHIRLWIND")

action = P:Recommend(State({
    rage = 30,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 1.80,
        speed = 3.63,
        slamCast = 1.96,
        slamCapable = true,
    },
}))
Check("the default clip limit permits 0.16 seconds of Slam delay", action.key == "SLAM")

action = P:Recommend(State({
    rage = 30,
    cooldowns = CoreCooldowns(4, 4),
    rotationDB = { slamClip = 0.15 },
    swing = {
        active = true,
        remaining = 1.80,
        speed = 3.63,
        slamCast = 1.96,
        slamCapable = true,
    },
}))
Check("a lower configured clip limit rejects the same Slam", action.key == "AUTO_ATTACK")

action = P:Recommend(State({
    rage = 80,
    gcd = 0.90,
    cooldowns = CoreCooldowns(4, 0),
    swing = {
        active = true,
        remaining = 3.20,
        speed = 3.8,
        slamCast = 1.92,
        slamCapable = true,
    },
}))
Check("a ready Whirlwind cannot delete a safe Slam during the current GCD", action.key == "SLAM")

action = P:Recommend(State({
    rage = 80,
    cooldowns = CoreCooldowns(4, 0),
    swing = {
        active = true,
        remaining = 1.80,
        speed = 3.5,
        slamCast = 1.5,
        slamCapable = true,
        slamUsed = true,
    },
}))
Check("a late Whirlwind remains available after Slam", action.key == "WHIRLWIND")

action = P:Recommend(State({
    rage = 80,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 3.45,
        speed = 3.5,
        slamCast = 1.5,
        slamCapable = true,
        slamUsed = true,
    },
}))
Check("one white-hit cycle never recommends a second Slam", action.key == "AUTO_ATTACK")

action = P:Recommend(State({
    rage = 25,
    overpower = true,
    cooldowns = CoreCooldowns(4, 4, 0),
}))
Check("Overpower dances only at retained rage", action.key == "BATTLE_STANCE")

action = P:Recommend(State({
    rage = 26,
    overpower = true,
    cooldowns = CoreCooldowns(4, 4, 0),
}))
Check("Overpower does not burn rage above 25", action.key ~= "BATTLE_STANCE")

action = P:Recommend(State({
    rage = 30,
    sunderStacks = 0,
    cooldowns = CoreCooldowns(4, 4),
    swing = { active = true, remaining = 1.0, slamUsed = true },
}))
Check("disabled Sunder maintenance never enters the rotation", action.key ~= "SUNDER_ARMOR")

action = P:Recommend(State({
    rage = 30,
    rotationDB = { maintainSunder = true },
    sunderStacks = 0,
    cooldowns = CoreCooldowns(4, 4),
}))
Check("enabled Sunder maintenance opens combat with one application", action.key == "SUNDER_ARMOR")

action = P:Recommend(State({
    rage = 30,
    rotationDB = { maintainSunder = true },
    sunderStacks = 1,
    sunderRemaining = 5.0,
    cooldowns = CoreCooldowns(4, 4),
    swing = { active = true, remaining = 1.0, slamUsed = true },
}))
Check("Sunder is not refreshed at exactly five seconds", action.key ~= "SUNDER_ARMOR")

action = P:Recommend(State({
    rage = 30,
    rotationDB = { maintainSunder = true },
    sunderStacks = 1,
    sunderRemaining = 4.9,
    cooldowns = CoreCooldowns(4, 4),
}))
Check("Sunder refreshes below five seconds", action.key == "SUNDER_ARMOR")

local pendingSunder = State({
    rage = 30,
    rotationDB = { maintainSunder = true },
    sunderStacks = 0,
    cooldowns = CoreCooldowns(4, 4),
    swing = { active = true, remaining = 1.0, slamUsed = true },
})
P:OnEvent("SPELL_CAST_EVENT", 1, D.Spells.SUNDER_ARMOR.spellId)
action = P:Recommend(pendingSunder)
Check("a confirmed Sunder is not immediately repeated", action.key ~= "SUNDER_ARMOR")

action = P:Recommend(State({
    targetHP = 20,
    rage = 20,
    rotationDB = { maintainSunder = true },
    sunderStacks = 0,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 3.0,
        slamCast = 1.5,
        slamCapable = true,
    },
}))
Check("execute phase reserves its last rage instead of Sundering", action.key ~= "SUNDER_ARMOR")

local afterOverpower = State({
    rage = 60,
    stance = 1,
    cooldowns = CoreCooldowns(4, 4, 5),
})
P:OnEvent("SPELL_CAST_EVENT", 1, D.Spells.OVERPOWER.spellId)
action = P:Recommend(afterOverpower)
Check("a confirmed Overpower returns to Berserker at high rage", action.key == "BERSERKER_STANCE")

action = P:Recommend(State({
    targetHP = 20,
    rage = 25,
    battleShout = false,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 3.0,
        slamCast = 1.5,
        slamCapable = true,
    },
}))
Check("execute phase refreshes Battle Shout while reserving Execute", action.key == "BATTLE_SHOUT")

action = P:Recommend(State({
    targetHP = 20,
    rage = 60,
    cooldowns = CoreCooldowns(0, 99),
    swing = {
        active = true,
        remaining = 3.0,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("60 rage funds Mortal Strike without requiring same-cycle Slam", action.key == "MORTAL_STRIKE")

action = P:Recommend(State({
    targetHP = 20,
    rage = 59,
    cooldowns = CoreCooldowns(0, 99),
    swing = {
        active = true,
        remaining = 3.0,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("59 rage stays below the Mortal Strike execute reserve", action.key == "SLAM")

action = P:Recommend(State({
    targetHP = 20,
    rage = 55,
    cooldowns = CoreCooldowns(4, 0),
    swing = {
        active = true,
        remaining = 3.0,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("55 rage funds Whirlwind without requiring same-cycle Slam", action.key == "WHIRLWIND")

action = P:Recommend(State({
    targetHP = 20,
    rage = 54,
    cooldowns = CoreCooldowns(4, 0),
    swing = {
        active = true,
        remaining = 3.0,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("54 rage stays below the Whirlwind execute reserve", action.key == "SLAM")

action = P:Recommend(State({
    targetHP = 20,
    rage = 30,
    gcd = 1.5,
    cooldowns = CoreCooldowns(6, 0),
    swing = {
        active = true,
        remaining = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("a second instant never displaces the cycle's Slam", action.key == "SLAM")

action = P:Recommend(State({
    targetHP = 20,
    rage = 15,
    cooldowns = CoreCooldowns(6, 10),
    swing = {
        active = true,
        remaining = 0.50,
        slamUsed = true,
        slamCapable = true,
    },
}))
Check("the minimum Execute lands inside the safe pre-white window", action.key == "EXECUTE")

action = P:Recommend(State({
    targetHP = 20,
    rage = 15,
    gcd = 0.25,
    cooldowns = CoreCooldowns(6, 10),
    swing = {
        active = true,
        remaining = 0.55,
        slamUsed = true,
        slamCapable = true,
    },
}))
Check("Execute never enters Nampower while its GCD is still locked", action.key ~= "EXECUTE")

action = P:Recommend(State({
    targetHP = 20,
    rage = 45,
    cooldowns = CoreCooldowns(0, 99),
    swing = {
        active = true,
        remaining = 3.0,
        slamUsed = true,
        slamCapable = true,
    },
}))
Check("45 rage falls back to Mortal Strike then Execute after Slam", action.key == "MORTAL_STRIKE")

action = P:Recommend(State({
    targetHP = 20,
    rage = 40,
    cooldowns = CoreCooldowns(4, 0),
    swing = {
        active = true,
        remaining = 3.0,
        slamUsed = true,
        slamCapable = true,
    },
}))
Check("40 rage falls back to Whirlwind then Execute after Slam", action.key == "WHIRLWIND")

action = P:Recommend(State({
    targetHP = 20,
    rage = 35,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 3.0,
        slamCast = 1.5,
        slamCapable = true,
    },
}))
Check("long execute windows retain an efficient permitted Slam", action.key == "SLAM")

action = P:Recommend(State({
    targetHP = 20,
    rage = 20,
    battleShout = false,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 3.0,
        slamCast = 1.5,
        slamCapable = true,
    },
}))
Check("execute phase never spends its last rage on Battle Shout", action.key == "SLAM")

action = P:Recommend(State({
    targetHP = 20,
    rage = 35,
    battleShout = false,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 0.50,
        slamCast = 1.5,
        slamCapable = true,
    },
}))
Check("Execute beats a missing Battle Shout inside its safe swing window", action.key == "EXECUTE")

action = P:Recommend(State({
    targetHP = 20,
    rage = 70,
    cooldowns = CoreCooldowns(0, 0),
    swing = {
        active = true,
        remaining = 0.20,
        slamCast = 1.5,
        slamCapable = true,
    },
}))
Check("a missed Execute window cannot spill across the white hit", action.key ~= "EXECUTE")

action = P:Recommend(State({
    targetHP = 20,
    rage = 35,
    cooldowns = CoreCooldowns(4, 4),
    targetHealthCurrent = 5000,
    targetHealthMax = 25000,
    targetHealthSource = "nampower",
    swing = {
        active = true,
        remaining = 0.50,
        speed = 3.5,
        slamCast = 1.5,
        slamCapable = true,
    },
}))
Check(
    "a nonlethal target remains the normal timed Execute",
    action.key == "EXECUTE"
        and action.reason == "贴近下一次白字清空剩余怒气"
)

action = P:Recommend(State({
    targetHP = 9,
    rage = 35,
    cooldowns = CoreCooldowns(4, 4),
    targetHealthCurrent = 1,
    targetHealthMax = 10000,
    targetHealthSource = "nampower",
    swing = {
        active = true,
        remaining = 3.0,
        slamCast = 1.5,
        slamCapable = true,
    },
}))
Check(
    "exact low target health does not trigger an early Execute",
    action.key == "SLAM"
)

local nextSwingForecast = P:BuildForecast(State({
    targetHP = 9,
    rage = 35,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 3.45,
        speed = 3.5,
        slamCapable = false,
    },
}), { key = "AUTO_ATTACK" })
local nextSwingExecute = ForecastByKey(nextSwingForecast, "EXECUTE")
Check(
    "the new swing forecasts Execute at its tail instead of its start",
    nextSwingExecute and nextSwingExecute.eta > 2.85
        and nextSwingExecute.eta < 2.95
)

local lockedTailForecast = P:BuildForecast(State({
    targetHP = 20,
    rage = 35,
    gcd = 0.15,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 0.30,
        speed = 3.5,
        slamCapable = false,
    },
}), { key = "AUTO_ATTACK" })
local lockedTailExecute = ForecastByKey(lockedTailForecast, "EXECUTE")
Check(
    "a GCD that misses the safe tail moves Execute to the next cycle",
    lockedTailExecute and lockedTailExecute.eta > 3.20
        and lockedTailExecute.eta < 3.30
)

-- Reproduce the live failure: a tail Execute expires, the next white hit adds
-- rage, and repeated input must not turn that old occurrence into a new cast.
local oldExecuteSetMode = D.SetMode
local oldExecuteBuildState = D.BuildState
local oldExecutePrepareTarget = D.PrepareExecutionTarget
local oldExecuteUpdate = D.Update
local oldExecuteCast = CastSpellByName
local oldExecuteCastNoQueue = CastSpellByNameNoQueue
local oldSpellStopCasting = SpellStopCasting
local executeState = nil
local genericExecuteCasts = {}
local immediateExecuteCasts = {}
local stoppedExecuteCasts = 0
D.SetMode = function() end
D.BuildState = function() return executeState end
D.PrepareExecutionTarget = function() return false, "current" end
D.Update = function() end
CastSpellByName = function(name) table.insert(genericExecuteCasts, name) end
CastSpellByNameNoQueue = function(name)
    table.insert(immediateExecuteCasts, name)
end
SpellStopCasting = function()
    stoppedExecuteCasts = stoppedExecuteCasts + 1
end

executeState = State({
    targetHP = 9,
    rage = 15,
    gcd = 0.20,
    targetHealthCurrent = 590,
    targetHealthMax = 10000,
    targetHealthSource = "nampower",
    casting = true,
    castName = D:GetName("SLAM"),
    castRemaining = 0.40,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 0.70,
        speed = 3.5,
        slamCast = 1.5,
        slamCapable = true,
    },
})
local castingResult = P:Execute("single")
Check(
    "DDPS never cancels Slam for low target health",
    not castingResult and stoppedExecuteCasts == 0
        and table.getn(genericExecuteCasts) == 0
        and table.getn(immediateExecuteCasts) == 0
)

executeState = State({
    targetHP = 9,
    rage = 15,
    moving = true,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 0.20,
        speed = 3.5,
        slamCapable = false,
    },
})
local expiredTailResult = P:Execute("single")
executeState = State({
    targetHP = 9,
    rage = 35,
    moving = true,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 3.45,
        speed = 3.5,
        slamCapable = false,
    },
})
local nextSwingResult = P:Execute("single")
Check(
    "an expired Execute cannot consume rage at the next swing start",
    not expiredTailResult and not nextSwingResult
        and table.getn(genericExecuteCasts) == 0
        and table.getn(immediateExecuteCasts) == 0
)

executeState = State({
    targetHP = 20,
    rage = 15,
    moving = true,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 0.50,
        speed = 3.5,
        slamCapable = false,
    },
})
local safeExecuteResult = P:Execute("single")
Check(
    "a safe-window Execute bypasses Nampower's generic queue",
    safeExecuteResult
        and table.getn(genericExecuteCasts) == 0
        and table.getn(immediateExecuteCasts) == 1
        and immediateExecuteCasts[1] == "斩杀"
)

executeState = State({
    targetHP = 20,
    rage = 15,
    gcd = 0.20,
    moving = true,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 0.50,
        speed = 3.5,
        slamCapable = false,
    },
})
local lockedExecuteResult = P:Execute("single")
Check(
    "a GCD-locked Execute never reaches either cast API",
    not lockedExecuteResult
        and table.getn(genericExecuteCasts) == 0
        and table.getn(immediateExecuteCasts) == 1
)

D.SetMode = oldExecuteSetMode
D.BuildState = oldExecuteBuildState
D.PrepareExecutionTarget = oldExecutePrepareTarget
D.Update = oldExecuteUpdate
CastSpellByName = oldExecuteCast
CastSpellByNameNoQueue = oldExecuteCastNoQueue
SpellStopCasting = oldSpellStopCasting

action = P:Recommend(State({
    targetHP = 20,
    rage = 45,
    gcd = 0.9,
    cooldowns = CoreCooldowns(0, 99),
    swing = {
        active = true,
        remaining = 2.60,
        slamUsed = true,
        slamCapable = true,
    },
}))
Check("current and following GCD are both reserved before Execute", action.key == "WAIT")

action = P:Recommend(State({
    rage = 30,
    moving = true,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 3.0,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("Slam remains available while moving", action.key == "SLAM")

action = P:Recommend(State({
    rage = 90,
    predictedMainHandRage = 15,
    cooldowns = CoreCooldowns(4, 4),
}))
Check("Heroic Strike queues only for a predicted cap", action.key == "HEROIC_STRIKE")

action = P:Recommend(State({
    rage = 90,
    predictedMainHandRage = 15,
    cooldowns = CoreCooldowns(4, 4),
    swing = {
        active = true,
        remaining = 0.20,
        speed = 3.5,
        slamCast = 1.5,
        slamCapable = false,
    },
}))
Check(
    "Heroic Strike never enters the next swing from the timer tail",
    action.key ~= "HEROIC_STRIKE"
)

action = P:Recommend(State({
    rage = 110,
    maxRage = 130,
    predictedMainHandRage = 15,
    cooldowns = CoreCooldowns(4, 4),
}))
Check("130 rage cap is respected", action.key ~= "HEROIC_STRIKE")

action = P:Recommend(State({
    rage = 120,
    maxRage = 130,
    predictedMainHandRage = 15,
    cooldowns = CoreCooldowns(4, 4),
}))
Check("Heroic Strike uses the real 130 rage cap", action.key == "HEROIC_STRIKE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 25,
    overpower = true,
    cooldowns = CoreCooldowns(4, 4, 0, 5),
}))
Check("AoE retains the low-rage Overpower stance dance", action.key == "BATTLE_STANCE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 25,
    stance = 3,
    cooldowns = CoreCooldowns(4, 4, 99, 0),
}))
Check("AoE enters Battle Stance for Sweeping at low rage", action.key == "BATTLE_STANCE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 25,
    stance = 1,
    cooldowns = CoreCooldowns(4, 4, 99, 0),
}))
Check("AoE activates Sweeping Strikes", action.key == "SWEEPING_STRIKES")

action = P:Recommend(State({
    mode = "aoe",
    rage = 10,
    stance = 1,
    tier3TwoPiece = true,
    cooldowns = CoreCooldowns(4, 4, 99, 0),
}))
Check("Tier 3 two-piece permits Sweeping Strikes at ten rage", action.key == "SWEEPING_STRIKES")

action = P:Recommend(State({
    mode = "aoe",
    rage = 10,
    stance = 1,
    cooldowns = CoreCooldowns(4, 4, 99, 0),
}))
Check("base Sweeping Strikes still requires twenty rage", action.key ~= "SWEEPING_STRIKES")

action = P:Recommend(State({
    mode = "aoe",
    rage = 80,
    stance = 1,
    sweepingStrikes = true,
}))
Check("AoE returns to Berserker after Sweeping at high rage", action.key == "BERSERKER_STANCE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 80,
    stance = 1,
    sweepingStrikes = true,
    swing = {
        active = true,
        remaining = 1.0,
        speed = 3.5,
        slamCast = 1.5,
        slamCapable = true,
        cleaveQueued = true,
    },
}))
Check("a queued Cleave still blocks the post-Sweeping stance switch", action.key ~= "BERSERKER_STANCE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 50,
    cooldowns = CoreCooldowns(4, 0, 99, 0),
}))
Check("AoE preserves Whirlwind for pending Sweeping", action.key == "BATTLE_STANCE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 75,
    cooldowns = CoreCooldowns(0, 4, 99, 0),
}))
Check("AoE may spend Mortal Strike before pending Sweeping", action.key == "MORTAL_STRIKE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 130,
    maxRage = 130,
    cooldowns = CoreCooldowns(0, 0, 99, 0),
}))
Check("high-rage pending Sweeping spends Mortal Strike but preserves Whirlwind", action.key == "MORTAL_STRIKE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 40,
    cooldowns = CoreCooldowns(4, 0, 99, 0),
    swing = {
        active = true,
        remaining = 3.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("pending Sweeping reserves rage and blocks repeat Slam", action.key == "BATTLE_STANCE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 100,
    cooldowns = CoreCooldowns(4, 4, 99, 0),
}))
Check("AoE forces Battle Stance after its available Sweeping drains", action.key == "BATTLE_STANCE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 40,
    cooldowns = CoreCooldowns(4, 4, 99, 5),
}))
Check("AoE never Cleaves below its Whirlwind reserve", action.key ~= "CLEAVE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 45,
    cooldowns = CoreCooldowns(4, 4, 99, 5),
}))
Check("AoE never treats forty-five rage as a Cleave dump", action.key ~= "CLEAVE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 94,
    maxRage = 130,
    predictedMainHandRage = 36,
    cooldowns = CoreCooldowns(4, 4, 99, 5),
}))
Check("AoE Cleaves when the next white would cap rage", action.key == "CLEAVE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 100,
    maxRage = 130,
    predictedMainHandRage = 36,
    cooldowns = CoreCooldowns(4, 4, 99, 5),
    swing = {
        active = true,
        remaining = 3.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("high current rage preserves the early Slam before Cleave", action.key == "SLAM")

action = P:Recommend(State({
    mode = "aoe",
    targetHP = 20,
    rage = 120,
    maxRage = 130,
    predictedMainHandRage = 36,
    cooldowns = CoreCooldowns(4, 4, 99, 5),
    swing = {
        active = true,
        remaining = 0.50,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = false,
    },
}))
Check("a due Execute cannot be replaced by Cleave", action.key == "EXECUTE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 45,
    cooldowns = CoreCooldowns(0, 4, 99, 5),
}))
Check("AoE preserves an immediately ready Mortal Strike before Cleave", action.key == "MORTAL_STRIKE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 40,
    cooldowns = CoreCooldowns(0, 4, 99, 5),
    swing = {
        active = true,
        remaining = 1.0,
        speed = 3.5,
        slamCast = 1.5,
        cleaveQueued = true,
    },
}))
Check("a queued Cleave's rage cannot be spent by Mortal Strike", action.key ~= "MORTAL_STRIKE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 15,
    cooldowns = CoreCooldowns(4, 4, 99, 5),
    swing = {
        active = true,
        remaining = 3.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("AoE Slam reserves rage for Whirlwind after a weak predicted white hit", action.key == "AUTO_ATTACK")

action = P:Recommend(State({
    mode = "aoe",
    rage = 35,
    cooldowns = CoreCooldowns(4, 4, 99, 5),
    swing = {
        active = true,
        remaining = 3.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
        cleaveQueued = true,
    },
}))
Check("a queued Cleave contributes no predicted rage before Whirlwind", action.key == "CLEAVE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 60,
    cooldowns = CoreCooldowns(0.5, 4, 99, 5),
    swing = {
        active = true,
        remaining = 3.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("AoE Slam never yields to Mortal Strike alone", action.key == "SLAM")

action = P:Recommend(State({
    mode = "aoe",
    rage = 35,
    predictedMainHandRage = 36,
    cooldowns = CoreCooldowns(4, 0.8, 99, 5),
    swing = {
        active = true,
        remaining = 3.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("AoE Slam reserves insufficient rage for a near-ready Whirlwind", action.key == "AUTO_ATTACK")

action = P:Recommend(State({
    mode = "aoe",
    rage = 40,
    predictedMainHandRage = 36,
    cooldowns = CoreCooldowns(4, 0.8, 99, 5),
    swing = {
        active = true,
        remaining = 3.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("AoE may Slam when it already preserves Whirlwind rage", action.key == "SLAM")

action = P:Recommend(State({
    mode = "aoe",
    rage = 25,
    predictedMainHandRage = 36,
    cooldowns = CoreCooldowns(4, 3, 99, 5),
    swing = {
        active = true,
        remaining = 2.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("AoE may Slam when a normal white hit funds Whirlwind first", action.key == "SLAM")

action = P:Recommend(State({
    mode = "aoe",
    rage = 80,
    cooldowns = CoreCooldowns(0, 0, 99, 5),
    swing = {
        active = true,
        remaining = 2.2,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("AoE ready Whirlwind outranks a funded safe Slam", action.key == "WHIRLWIND")

action = P:Recommend(State({
    mode = "aoe",
    rage = 40,
    sweepingStrikes = true,
    sweepingRemaining = 5,
    sweepingStacks = 1,
    cooldowns = CoreCooldowns(4, 0, 99, 5),
    swing = {
        active = true,
        remaining = 2.2,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("the last Sweeping charge makes Slam yield to Whirlwind", action.key == "WHIRLWIND")

action = P:Recommend(State({
    mode = "aoe",
    rage = 40,
    sweepingStrikes = true,
    sweepingRemaining = 5,
    sweepingStacks = 1,
    cooldowns = CoreCooldowns(4, 0.5, 99, 5),
    swing = {
        active = true,
        remaining = 2.2,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = true,
    },
}))
Check("the last Sweeping charge still waits for near-ready Whirlwind", action.key == "AUTO_ATTACK")

action = P:Recommend(State({
    mode = "aoe",
    rage = 42,
    predictedMainHandRage = 36,
    cooldowns = CoreCooldowns(0, 0.5, 99, 5),
    swing = {
        active = true,
        remaining = 2.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = false,
    },
}))
Check("AoE Mortal Strike preserves rage for a near-ready Whirlwind", action.key == "AUTO_ATTACK")

action = P:Recommend(State({
    mode = "aoe",
    rage = 42,
    predictedMainHandRage = 36,
    cooldowns = CoreCooldowns(0, 0.5, 99, 5),
    swing = {
        active = true,
        remaining = 1.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = false,
    },
}))
Check("a normal white during Mortal Strike's GCD funds Whirlwind", action.key == "MORTAL_STRIKE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 70,
    predictedMainHandRage = 36,
    cooldowns = CoreCooldowns(0, 0.5, 99, 5),
    swing = {
        active = true,
        remaining = 1.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = false,
        cleaveQueued = true,
    },
}))
Check("a queued Cleave cannot fund Whirlwind after Mortal Strike", action.key == "CLEAVE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 120,
    maxRage = 130,
    predictedMainHandRage = 36,
    sweepingStrikes = true,
    sweepingRemaining = 5,
    sweepingStacks = 2,
    cooldowns = CoreCooldowns(4, 0.8, 99, 5),
    swing = {
        active = true,
        remaining = 0.5,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = false,
    },
}))
Check("Cleave preserves the last Sweeping charge for Whirlwind", action.key ~= "CLEAVE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 120,
    maxRage = 130,
    predictedMainHandRage = 36,
    sweepingStrikes = true,
    sweepingRemaining = 5,
    sweepingStacks = 3,
    cooldowns = CoreCooldowns(4, 0.8, 99, 5),
    swing = {
        active = true,
        remaining = 0.75,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = false,
    },
}))
Check("Cleave may spend Sweeping charges that Whirlwind does not need", action.key == "CLEAVE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 120,
    maxRage = 130,
    predictedMainHandRage = 36,
    sweepingStrikes = true,
    sweepingRemaining = 5,
    sweepingStacks = 3,
    cooldowns = CoreCooldowns(4, 0.8, 99, 5),
    swing = {
        active = true,
        remaining = 0.20,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = false,
    },
}))
Check(
    "Cleave never enters the next swing from the timer tail",
    action.key ~= "CLEAVE"
)

for mode, key in pairs({ single = "HEROIC_STRIKE", aoe = "CLEAVE" }) do
    local state = State({ mode = mode, rage = 100 })
    state.swing.remaining = 0.21
    Check(key .. " can queue just before the 0.20s guard",
        P:Recommend(state).key == key)
    state.swing.remaining = 0.20
    Check(key .. " cannot queue at the 0.20s boundary",
        P:Recommend(state).key ~= key)
end

action = P:Recommend(State({
    mode = "aoe",
    rage = 60,
    sweepingStrikes = true,
    sweepingRemaining = 1.0,
    sweepingStacks = 5,
    cooldowns = CoreCooldowns(0, 0.5, 99, 5),
    swing = {
        active = true,
        remaining = 3.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = false,
    },
}))
Check("Mortal Strike waits when its GCD would expire Sweeping", action.key == "AUTO_ATTACK")

action = P:Recommend(State({
    mode = "aoe",
    rage = 60,
    sweepingStrikes = true,
    sweepingRemaining = 5,
    sweepingStacks = 1,
    cooldowns = CoreCooldowns(0, 0.5, 99, 5),
    swing = {
        active = true,
        remaining = 3.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = false,
    },
}))
Check("Mortal Strike preserves the last Sweeping charge for Whirlwind", action.key == "AUTO_ATTACK")

action = P:Recommend(State({
    mode = "aoe",
    rage = 60,
    sweepingStrikes = true,
    sweepingRemaining = 5,
    sweepingStacks = 2,
    cooldowns = CoreCooldowns(0, 0.5, 99, 5),
    swing = {
        active = true,
        remaining = 1.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = false,
    },
}))
Check("Mortal Strike cannot let the next white consume all Sweeping charges", action.key == "AUTO_ATTACK")

action = P:Recommend(State({
    mode = "aoe",
    rage = 60,
    sweepingStrikes = true,
    sweepingRemaining = 5,
    sweepingStacks = 2,
    cooldowns = CoreCooldowns(0, 0.5, 99, 5),
    swing = {
        active = true,
        remaining = 3.0,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = false,
    },
}))
Check("Mortal Strike may spend one of two Sweeping charges", action.key == "MORTAL_STRIKE")

local cooldownState = State({
    rage = 80,
    cooldowns = CoreCooldowns(0, 0),
    swing = { active = false },
})
P:OnEvent("SPELL_CAST_EVENT", 1, D.Spells.MORTAL_STRIKE.spellId)
P:OnEvent("SPELL_CAST_EVENT", 1, D.Spells.WHIRLWIND.spellId)
local cooldownForecast = P:BuildForecast(cooldownState, { key = "WAIT" })
local mortalForecast = ForecastByKey(cooldownForecast, "MORTAL_STRIKE")
local whirlwindForecast = ForecastByKey(cooldownForecast, "WHIRLWIND")
Check(
    "Mortal Strike restarts on the timeline at its ability cooldown",
    mortalForecast and mortalForecast.eta >= 5.9
        and mortalForecast.timelineCycle == 1
)
Check(
    "Whirlwind restarts on the timeline at its ability cooldown",
    whirlwindForecast and whirlwindForecast.eta >= 9.9
        and whirlwindForecast.timelineCycle == 1
)

local previousCandidates = P._candidates
local forecast = P:BuildForecast(State({
    targetHP = 20,
    rage = 45,
    cooldowns = CoreCooldowns(0, 2),
}), { key = "MORTAL_STRIKE" })
Check("the QTE timeline keeps a compact forecast", forecast[1] ~= nil)
Check("each forecast resets Lua 5.0's cached list size", P._candidates ~= previousCandidates)

-- Heroic Strike cannot occupy the start of a swing, even if Slam is blocked.
do
    for _, gcd in ipairs({ 0, 1.5 }) do
        local early = State({ rage = 100, gcd = gcd, cooldowns = CoreCooldowns(0, 5) })
        early.swing.remaining, early.swing.slamUsed = 3.45, true
        Check("fresh swing rejects Heroic Strike with GCD " .. gcd,
            P:Recommend(early).key ~= "HEROIC_STRIKE")
    end
    local boundary = State({ rage = 100 })
    boundary.swing.slamUsed = true
    boundary.swing.remaining = 1.751
    Check("Heroic Strike waits until the second half",
        P:Recommend(boundary).key ~= "HEROIC_STRIKE")
    boundary.swing.remaining = 1.75
    Check("funded Heroic Strike can queue at the midpoint",
        P:Recommend(boundary).key == "HEROIC_STRIKE")
end

-- A queued dump must remain available while a core action waits for its GCD.
local dumpState = State({
    rage = 100, gcd = 1, cooldowns = CoreCooldowns(0, 5),
    swing = { active = true, remaining = 0.8, speed = 3.5,
        slamCast = 1.5, slamUsed = true },
})
Check("GCD-locked Mortal Strike permits funded Heroic Strike",
    P:Recommend(dumpState).key == "HEROIC_STRIKE")
dumpState.swing.hsQueued = true
dumpState.rage = 40
Check("queued Heroic Strike rage cannot also fund Mortal Strike",
    P:Recommend(dumpState).key ~= "MORTAL_STRIKE")

dumpState = State({ rage = 100, cooldowns = CoreCooldowns(5, 5) })
dumpState.predictedMainHandRage = nil
Check("full rage permits Heroic Strike without prediction APIs",
    P:Recommend(dumpState).key == "HEROIC_STRIKE")
dumpState.rage = 99
Check("missing prediction does not invent overflow below the cap",
    P:Recommend(dumpState).key ~= "HEROIC_STRIKE")

dumpState = State({ rage = 60, gcd = 1, predictedMainHandRage = 50,
    cooldowns = CoreCooldowns(0, 0) })
Check("predicted overflow cannot spend reserved core rage",
    P:Recommend(dumpState).key ~= "HEROIC_STRIKE")

dumpState = State({ rage = 100, gcd = 0.5,
    cooldowns = CoreCooldowns(0, 5),
    swing = { active = true, remaining = 3, speed = 3.5, slamCast = 1.5 },
})
Check("a safe single-target Slam window is not replaced by Heroic Strike",
    P:Recommend(dumpState).key ~= "HEROIC_STRIKE")

dumpState = State({ mode = "aoe", rage = 100, gcd = 1,
    cooldowns = CoreCooldowns(5, 0),
    swing = { active = true, remaining = 0.8, speed = 3.5,
        slamCast = 1.5, slamUsed = true },
})
Check("GCD-locked Whirlwind permits funded Cleave",
    P:Recommend(dumpState).key == "CLEAVE")
dumpState.swing.queuePending = true
dumpState.swing.pendingKey = "CLEAVE"
Check("pending Cleave is not queued twice during the GCD",
    P:Recommend(dumpState).key == "WHIRLWIND")

dumpState = State({ mode = "aoe", rage = 100,
    predictedMainHandRage = 20, cooldowns = CoreCooldowns(0, 5) })
Check("Cleave uses current rage rather than rage after planned Mortal Strike",
    P:Recommend(dumpState).key == "CLEAVE")
dumpState.swing.cleaveQueued = true
Check("funded Mortal Strike follows queued Cleave",
    P:Recommend(dumpState).key == "MORTAL_STRIKE")

dumpState = State({ mode = "aoe", rage = 100,
    cooldowns = CoreCooldowns(4, 4, 99, 5),
    swing = { active = true, remaining = 3, speed = 3.63, slamCast = 2 },
})
Check("high-rage AoE preserves a funded Slam before Cleave",
    P:Recommend(dumpState).key == "SLAM")
dumpState.swing.cleaveQueued = true
Check("queued Cleave preserves the funded Slam",
    P:Recommend(dumpState).key == "SLAM")

dumpState = State({ mode = "aoe", rage = 100, gcd = 1,
    cooldowns = CoreCooldowns(0, 5, 99, 0) })
Check("GCD dump cannot bypass preparation for Sweeping Strikes",
    P:Recommend(dumpState).key ~= "CLEAVE")

for rank = 0, 3 do
    improvedHeroicStrikeRank = rank
    ravagerRank = rank
    P:OnEvent("CHARACTER_POINTS_CHANGED")
    Check("Heroic Strike cost follows talent rank " .. rank,
        P._rageCost(nil, "HEROIC_STRIKE") == 15 - rank)
    Check("Cleave cost follows Ravager rank " .. rank,
        P._rageCost(nil, "CLEAVE") == 20 - rank)
end
for rank = 0, 2 do
    improvedExecuteRank = rank
    P:OnEvent("PLAYER_TALENT_UPDATE")
    Check("Execute readiness and reserves share talented cost " .. rank,
        P._rageCost(nil, "EXECUTE") == (rank == 2 and 10 or (rank == 1 and 13 or 15)))
end

local talented = State({ targetHP = 20, rage = 55,
    cooldowns = CoreCooldowns(0, 99),
    swing = { active = true, remaining = 4, speed = 4, slamCast = 2 },
})
Check("Improved Execute permits Mortal Strike plus Slam plus Execute at 55 rage",
    P:Recommend(talented).key == "MORTAL_STRIKE")
talented.rage = 54
Check("the talented three-action budget still rejects 54 rage",
    P:Recommend(talented).key ~= "MORTAL_STRIKE")

talented = State({ rage = 41, gcd = 1, cooldowns = CoreCooldowns(0, 99),
    swing = { active = true, remaining = 0.8, speed = 3.5,
        slamCast = 2, hsQueued = true },
})
Check("queued talented Heroic Strike reserves twelve rage",
    P:Recommend(talented).key ~= "MORTAL_STRIKE")
talented.rage = 42
Check("forty-two rage funds queued talented Heroic Strike and Mortal Strike",
    P:Recommend(talented).key == "MORTAL_STRIKE")

talented = State({ cooldowns = CoreCooldowns(99, 0) })
local talentedForecast = P:BuildForecast(talented, { key = "WHIRLWIND" })
Check("Ravager predicts an eight-second Whirlwind cycle",
    ForecastByKey(P._candidates, "WHIRLWIND").eta == 8)
P:OnEvent("SPELL_CAST_EVENT", 1, D.Spells.WHIRLWIND.spellId)
Check("Ravager event cooldown is eight seconds",
    P._cooldownUntil.WHIRLWIND == now + 8)
talented.cooldowns.WHIRLWIND = { remaining = 8, duration = 8 }
talentedForecast = P:BuildForecast(talented, { key = "WAIT" })
Check("actual API cooldown overrides prediction without a second talent reduction",
    ForecastByKey(talentedForecast, "WHIRLWIND").eta == 8)
improvedHeroicStrikeRank, ravagerRank, improvedExecuteRank = 0, 0, 0
P:OnEvent("SPELLS_CHANGED")
Check("respec clears talented costs and stale Whirlwind prediction",
    P._rageCost(nil, "HEROIC_STRIKE") == 15
        and P._rageCost(nil, "CLEAVE") == 20
        and P._rageCost(nil, "EXECUTE") == 15
        and P._cooldownUntil.WHIRLWIND == nil)

local oldTalentInfo, oldPrint, oldPfUI = GetTalentInfo, D.Print, pfUI
local debugLines, debugWrites = {}, 0
D.Print = function(_, message) table.insert(debugLines, message) end
pfUI = { swingtimer = { api = { AppendTrace = function(kind, detail)
    Check("talent snapshot uses the shared trace event", kind == "DDPS_TALENTS")
    debugWrites = debugWrites + 1
    return true
end } } }
GetTalentInfo = function(tab, index)
    if tab == 1 then
        local names = { "强化英勇打击", "双手武器专精", "无边怒火", "精准砍杀" }
        if names[index] then return names[index], nil, 1, index, 3, 3 end
    elseif tab == 2 then
        if index == 1 then return "怒不可遏", nil, 1, 1, 0, 5 end
        if index == 2 then return "强化斩杀", nil, 2, 1, 2, 2 end
        if index == 3 then return "碾碎", nil, 5, 1, 3, 3 end
    end
end
local oldManaMax = UnitManaMax
UnitManaMax = function() return 130 end
local debugState = State({ maxRage = 130 })
P:DebugTalents(debugState)
Check("disabled talent debug does not print or write", #debugLines == 0 and debugWrites == 0)
D.debugMode = true
P:DebugTalents(debugState)
local snapshot = table.concat(debugLines, "\n")
Check("snapshot distinguishes a detected zero-point talent",
    string.find(snapshot, "怒不可遏=0/5 read=found", 1, true) ~= nil)
Check("snapshot reports the actual talented costs and cap",
    string.find(snapshot, "HS=12 Cleave=17 Execute=10 WW-model=8s", 1, true) ~= nil
        and string.find(snapshot, "apiMax=130 usedMax=130 match=true", 1, true) ~= nil)
local lineCount = #debugLines
P:DebugTalents(debugState)
Check("unchanged frames do not repeat talent logs", #debugLines == lineCount and debugWrites == 1)
P:OnEvent("PLAYER_TALENT_UPDATE")
P:DebugTalents(debugState)
Check("talent changes emit a fresh snapshot", debugWrites == 2)
GetTalentInfo = nil
P:OnEvent("PLAYER_TALENT_UPDATE")
P:DebugTalents(debugState)
Check("missing talent API is reported instead of looking like zero points",
    string.find(table.concat(debugLines, "\n"), "read=api-missing", 1, true) ~= nil)
GetTalentInfo = function() return nil end
pfUI = nil
P:OnEvent("PLAYER_TALENT_UPDATE")
P:DebugTalents(debugState)
snapshot = table.concat(debugLines, "\n")
Check("missing talent and missing writer still produce readable diagnostics",
    string.find(snapshot, "read=not-found", 1, true) ~= nil
        and string.find(snapshot, "file=unavailable", 1, true) ~= nil)
D.debugMode = false
P:DebugTalents(debugState)
GetTalentInfo, D.Print, pfUI, UnitManaMax = oldTalentInfo, oldPrint, oldPfUI, oldManaMax
P:ResetRuntime()

-- The same saved mode must work for Fury with or without Bloodthirst.
do
    known.MORTAL_STRIKE = false
    flurryRank, improvedExecuteRank = 5, 2
    local function FuryState(values)
        local options = {
            targetHP = 20, rage = 40, predictedMainHandRage = 30,
            cooldowns = CoreCooldowns(99, 4, 99, 30),
            swing = { active = true, remaining = 0.5, speed = 2.55,
                slamCast = 1.92, slamCapable = true, slamUsed = true },
        }
        for key, value in pairs(values or {}) do options[key] = value end
        return State(options)
    end
    local function Swing(remaining, used)
        return { active = true, remaining = remaining, speed = 2.55,
            slamCast = 1.92, slamCapable = true, slamUsed = used }
    end

    local cases = {
        { "Fury keeps the formerly blocked 60-rage Whirlwind",
            { rage = 60, swing = Swing(1.55), cooldowns = CoreCooldowns(99, 0) }, "WHIRLWIND" },
        { "Fury does not reserve Execute rage before Whirlwind",
            { rage = 25, swing = Swing(1.55), cooldowns = CoreCooldowns(99, 0) }, "WHIRLWIND" },
        { "Fury keeps a full-rage Slam window",
            { rage = 100, swing = Swing(2.55) }, "SLAM" },
        { "Fury AoE keeps a full-rage Slam window before Cleave",
            { mode = "aoe", rage = 100, swing = Swing(2.55) }, "SLAM" },
        { "Fury AoE does not queue Cleave at swing start during GCD",
            { mode = "aoe", rage = 100, gcd = 1.5, swing = Swing(2.55, true) }, "WAIT" },
        { "Fury single does not queue Heroic Strike at swing start during GCD",
            { rage = 100, gcd = 1.5, swing = Swing(2.55, true) }, "WAIT" },
        { "Fury AoE preserves a safe Slam even in the second half",
            { mode = "aoe", rage = 100, swing = {
                active = true, remaining = 2, speed = 4, slamCast = 1.5,
                slamCapable = true } }, "SLAM" },
        { "Fury can spend its last fifteen rage on safe Slam",
            { rage = 15, swing = Swing(2.55) }, "SLAM" },
        { "Fury tail Execute cannot delete the next fast-swing Slam",
            {}, "AUTO_ATTACK" },
        { "Fury can Execute early when the next white funds its core",
            { rage = 10, swing = Swing(2) }, "EXECUTE" },
        { "Execute drains all rage and cannot starve the next Slam",
            { rage = 10, swing = Swing(2), predictedMainHandRage = 10 }, "AUTO_ATTACK" },
        { "Fury waits for an affordable near-ready Whirlwind",
            { swing = Swing(2, true), cooldowns = CoreCooldowns(99, 0.4) }, "AUTO_ATTACK" },
        { "Execute cannot delay a Whirlwind funded by the next white",
            { rage = 10, swing = Swing(0.8, true), cooldowns = CoreCooldowns(99, 0) }, "AUTO_ATTACK" },
        { "Fury may queue Heroic Strike below twenty percent",
            { rage = 95 }, "HEROIC_STRIKE" },
        { "overflow does not permit high-rage Execute",
            { predictedMainHandRage = 70, cooldowns = CoreCooldowns(99, 2) }, "AUTO_ATTACK" },
        { "overflow does not bypass next Slam timing at low rage",
            { rage = 10, predictedMainHandRage = 100 }, "AUTO_ATTACK" },
        { "queued Heroic Strike does not suppress an affordable Fury Slam",
            { rage = 60, swing = { active = true, remaining = 2.55, speed = 2.55,
                slamCast = 1.92, slamCapable = true, hsQueued = true } }, "SLAM" },
        { "Fury AoE Whirlwind keeps priority over Execute and Slam",
            { mode = "aoe", rage = 60, swing = Swing(2.55),
                cooldowns = CoreCooldowns(99, 0, 99, 30) }, "WHIRLWIND" },
        { "Fury AoE can Cleave instead of forcing a tail Execute",
            { mode = "aoe", rage = 95 }, "CLEAVE" },
        { "Fury AoE does not spend next Whirlwind funding on Cleave or Execute",
            { mode = "aoe", rage = 25, predictedMainHandRage = 70,
                cooldowns = CoreCooldowns(99, 0.4, 99, 30) }, "AUTO_ATTACK" },
        { "Fury prepares learned Sweeping Strikes",
            { mode = "aoe", rage = 20, cooldowns = CoreCooldowns(99, 4, 99, 0) }, "BATTLE_STANCE" },
        { "Fury activates learned Sweeping Strikes",
            { mode = "aoe", rage = 20, stance = 1,
                cooldowns = CoreCooldowns(99, 4, 99, 0) }, "SWEEPING_STRIKES" },
        { "Fury returns to Berserker after Sweeping Strikes",
            { mode = "aoe", stance = 1, sweepingStrikes = true }, "BERSERKER_STANCE" },
        { "missing swing provider still permits normal Fury instants",
            { rage = 25, swing = { active = false }, cooldowns = CoreCooldowns(99, 0) }, "WHIRLWIND" },
        { "missing swing provider pauses automatic Fury Execute",
            { rage = 10, swing = { active = false } }, "WAIT" },
    }
    for _, case in ipairs(cases) do
        local state = FuryState(case[2])
        local rec = P:Recommend(state)
        Check(case[1] .. " (got " .. tostring(rec.key) .. ")", rec.key == case[3])
    end

    for rank = 0, 2 do
        improvedExecuteRank = rank
        P:OnEvent("CHARACTER_POINTS_CHANGED")
        local cap = P._rageCost(nil, "EXECUTE") + 10
        for _, mode in ipairs({ "single", "aoe" }) do
            local low = FuryState({ mode = mode, rage = cap, swing = Swing(2, true) })
            Check("Fury Execute includes low-rage cap " .. rank .. " " .. mode,
                P:Recommend(low).key == "EXECUTE")
            low.rage = cap + 1
            local rec, forecast = P:Evaluate(low)
            Check("Fury holds rage above cap " .. rank .. " " .. mode,
                rec.key == "AUTO_ATTACK" and not ForecastByKey(forecast, "EXECUTE"))
        end
    end
    improvedExecuteRank = 2
    P:OnEvent("CHARACTER_POINTS_CHANGED")

    local state = FuryState()
    local rec, forecast = P:Evaluate(state)
    Check("Fury forecasts do not invent a per-swing Execute or unknown strikes",
        rec.key == "AUTO_ATTACK" and not ForecastByKey(forecast, "EXECUTE")
            and not ForecastByKey(forecast, "MORTAL_STRIKE")
            and not ForecastByKey(forecast, "BLOODTHIRST"))
    Check("Flurry identifies Fury without Bloodthirst", P:IsFury())
    flurryRank = 0
    Check("Fury selection does not depend on a temporary aura", P:IsFury())
    P:OnEvent("CHARACTER_POINTS_CHANGED")
    Check("respec immediately restores the Arms policy", not P:IsFury())
    flurryRank = 5
    P:OnEvent("SPELLS_CHANGED")
    Check("learning Flurry restores Fury without reloading", P:IsFury())

    known.SWEEPING_STRIKES = false
    state = FuryState({ mode = "aoe", rage = 25, cooldowns = CoreCooldowns(99, 0, 99, 0) })
    Check("unknown Sweeping Strikes never blocks Fury AoE", P:Recommend(state).key == "WHIRLWIND")
    known.SWEEPING_STRIKES = true

    known.BLOODTHIRST, flurryRank = true, 0
    state = FuryState({ rage = 30, swing = Swing(1.55) })
    state.cooldowns.BLOODTHIRST = { remaining = 0, duration = 6 }
    Check("learned Bloodthirst participates without requiring Flurry",
        P:IsFury() and P:Recommend(state).key == "BLOODTHIRST")
    state.mode = "aoe"
    Check("learned Bloodthirst participates in AoE", P:Recommend(state).key == "BLOODTHIRST")
    forecast = P:BuildForecast(state, { key = "WAIT" })
    Check("learned Bloodthirst appears in the timeline", ForecastByKey(forecast, "BLOODTHIRST") ~= nil)
    P:OnEvent("SPELL_CAST_EVENT", 1, D.Spells.BLOODTHIRST.spellId)
    Check("Bloodthirst cast events predict its six-second cooldown",
        P._cooldownUntil.BLOODTHIRST == now + 6)
    Check("the predicted Bloodthirst cooldown prevents duplicate recommendations",
        P:Recommend(state).key ~= "BLOODTHIRST")

    state = FuryState({ rage = 60, swing = Swing(4), cooldowns = CoreCooldowns(99, 0) })
    state.swing.speed = 4
    state.cooldowns.BLOODTHIRST = { remaining = 0.3, duration = 6 }
    Check("waiting for Bloodthirst plus Slam does not slip in an extra Whirlwind",
        P:Recommend(state).key == "AUTO_ATTACK")

    -- Exercise the actual keypress path, including its final Execute guard.
    known.BLOODTHIRST, flurryRank = false, 5
    local live = FuryState({ rage = 10, swing = Swing(2) })
    local casts = {}
    D.SetMode = function() end
    D.BuildState = function() return live end
    D.PrepareExecutionTarget = function() return false end
    D.Update = function() end
    CastSpellByName = function(name) table.insert(casts, "queued:" .. name) end
    CastSpellByNameNoQueue = function(name) table.insert(casts, name) end
    Check("Fury executes an approved early opportunity without generic spell queuing",
        P:Execute("single") and #casts == 1 and casts[1] == "斩杀")
    live = FuryState({ rage = 21, swing = Swing(2, true) })
    Check("the real execution path rejects Execute above the low-rage cap",
        not P:Execute("single") and #casts == 1)
    live = FuryState()
    Check("the real execution path rejects a destructive tail Execute",
        not P:Execute("single") and #casts == 1)
    live = FuryState({ rage = 10, swing = Swing(2), gcd = 0.2 })
    Check("Fury Execute cannot enter the spell queue during GCD",
        not P:Execute("single") and #casts == 1)
    live = FuryState({ rage = 10, swing = Swing(2), casting = true })
    Check("Fury never interrupts an active cast for Execute",
        not P:Execute("single") and #casts == 1)
    live = FuryState({ rage = 10, swing = Swing(0.2), predictedMainHandRage = 100 })
    Check("Fury retains the server swing-boundary guard",
        not P:Execute("single") and #casts == 1)

    live = FuryState({ rage = 25, swing = Swing(2, true),
        rotationDB = { furyExecuteExtraRage = 15 } })
    Check("configured extra rage reaches the actual Execute path",
        P:Execute("single") and #casts == 2 and casts[2] == "斩杀")
    live.rotationDB.furyExecuteExtraRage = 10
    Check("lowering the extra rage cap blocks that same keypress",
        not P:Execute("single") and #casts == 2)

    live = FuryState({ rage = 10,
        rotationDB = { furyProtectNextSlam = false } })
    Check("next-Slam protection can be disabled for a real tail Execute",
        P:Execute("single") and #casts == 3)
    live.rotationDB.furyProtectNextSlam = true
    Check("restoring next-Slam protection rejects the same tail Execute",
        not P:Execute("single") and #casts == 3)
    live.rotationDB.useSlamExecute = false
    Check("a disabled Execute-phase Slam keeps no future timing reserve",
        P:Execute("single") and #casts == 4)

    live = FuryState({ rage = 15, swing = Swing(2.55),
        rotationDB = { useSlamExecute = false } })
    Check("disabling Slam frees the current window for Execute",
        P:Execute("single") and #casts == 5 and casts[5] == "斩杀")
    live.gcd = 0.2
    Check("disabled Slam does not bypass the Execute GCD guard",
        not P:Execute("single") and #casts == 5)
    live.gcd, live.swing.remaining = 0, 0.2
    Check("disabled Slam does not bypass the final swing guard",
        not P:Execute("single") and #casts == 5)

    live = FuryState({ rage = 10, swing = Swing(2),
        rotationDB = { furyProtectNextSlam = false },
        cooldowns = CoreCooldowns(99, 0.4) })
    live.swing.remaining = 0.5
    Check("disabling next-Slam protection still protects a funded imminent Whirlwind",
        not P:Execute("single") and #casts == 5)
    live.rotationDB.useWhirlwindExecute = false
    Check("disabling Whirlwind removes its Execute hold",
        P:Execute("single") and #casts == 6)

    live = FuryState({ rage = 41, swing = Swing(2, true),
        rotationDB = { furyExecuteExtraRage = 999 } })
    Check("saved extra rage above the supported range is clamped",
        not P:Execute("single") and #casts == 6)
    live.rage, live.rotationDB.furyExecuteExtraRage = 10, -10
    Check("negative saved extra rage clamps to minimum-cost Execute",
        P:Execute("single") and #casts == 7)
    D.SetMode, D.BuildState = oldExecuteSetMode, oldExecuteBuildState
    D.PrepareExecutionTarget, D.Update = oldExecutePrepareTarget, oldExecuteUpdate
    CastSpellByName, CastSpellByNameNoQueue = oldExecuteCast, oldExecuteCastNoQueue

    known.MORTAL_STRIKE = true
    flurryRank, improvedExecuteRank = 0, 0
    P:ResetRuntime()
end

-- A synchronous spell event can refresh the shared recommendation during casting.
do
    local oldSetMode, oldBuildState = D.SetMode, D.BuildState
    local oldPrepare, oldUpdate = D.PrepareExecutionTarget, D.Update
    local oldMark, oldTrace = D.MarkOnSwingQueued, D.TraceSwingExecution
    local oldCast, oldNoQueue = CastSpellByName, CastSpellByNameNoQueue
    local live, marked, traced, castName
    D.SetMode = function() end
    D.BuildState = function() return live end
    D.PrepareExecutionTarget = function() return false end
    D.Update = function() end
    D.MarkOnSwingQueued = function(_, key) marked = key end
    D.TraceSwingExecution = function(_, _, _, _, action) traced = action.key end
    for _, key in ipairs({ "SLAM", "HEROIC_STRIKE", "CLEAVE" }) do
        live = State({ rage = 100, mode = key == "CLEAVE" and "aoe" or "single" })
        if key == "SLAM" then live.swing.remaining = 3.4 end
        marked, traced, castName = nil, nil, nil
        CastSpellByName = function(name)
            castName = name
            local refreshed = State({ rage = 100 })
            if key ~= "SLAM" then refreshed.swing.remaining = 3.4 end
            P:Recommend(refreshed)
        end
        CastSpellByNameNoQueue = CastSpellByName
        Check(key .. " execution survives a synchronous recommendation refresh",
            P:Execute(live.mode) and castName == D:GetName(key)
                and traced == key and marked == (key ~= "SLAM" and key or nil))
    end
    D.SetMode, D.BuildState = oldSetMode, oldBuildState
    D.PrepareExecutionTarget, D.Update = oldPrepare, oldUpdate
    D.MarkOnSwingQueued, D.TraceSwingExecution = oldMark, oldTrace
    CastSpellByName, CastSpellByNameNoQueue = oldCast, oldNoQueue
end

-- Each phase switch changes the public recommendation and forecast in both modes.
do
    local cases = {
        { "SLAM", "useSlam", 15 },
        { "OVERPOWER", "useOverpower", 5 },
        { "WHIRLWIND", "useWhirlwind", 55 },
        { "MORTAL_STRIKE", "useStrike", 60 },
        { "BLOODTHIRST", "useStrike", 60 },
    }
    for _, mode in ipairs({ "single", "aoe" }) do
        for _, hp in ipairs({ 100, 20 }) do
            for _, case in ipairs(cases) do
                known.BLOODTHIRST = case[1] == "BLOODTHIRST"
                local state = State({ mode = mode, targetHP = hp, rage = case[3],
                    rotationDB = {}, overpower = case[1] == "OVERPOWER",
                    stance = case[1] == "OVERPOWER" and 1 or 3,
                    swing = { active = true, remaining = 3.7, speed = 3.7,
                        slamCast = 2, slamCapable = true } })
                state.cooldowns[case[1]] = { remaining = 0, duration = 6 }
                local label = mode .. " " .. hp .. "% " .. case[1]
                Check(label .. " baseline recommends the enabled spell",
                    P:Recommend(state).key == case[1])
                state.rotationDB[case[2] .. (hp <= 20 and "Execute" or "")] = false
                local rec, forecast = P:Evaluate(state)
                Check(label .. " disabled spell leaves recommendations and forecasts",
                    rec.key ~= case[1] and not ForecastByKey(forecast, case[1]))
                state.targetHP = hp == 20 and 100 or 20
                Check(label .. " opposite phase remains enabled",
                    P:Recommend(state).key == case[1])
            end
        end
    end
    known.BLOODTHIRST = false

    local state = State({ rage = 25, rotationDB = { useSlam = false },
        cooldowns = CoreCooldowns(99, 0),
        swing = { active = true, remaining = 3, speed = 3.5,
            slamCast = 2, slamCapable = true } })
    Check("disabled Slam removes Whirlwind's current Slam rage reserve",
        P:Recommend(state).key == "WHIRLWIND")
    state = State({ mode = "aoe", rage = 15, predictedMainHandRage = 5,
        rotationDB = { useWhirlwind = false }, cooldowns = CoreCooldowns(99, 1),
        sweepingStrikes = true, sweepingRemaining = 4, sweepingStacks = 1,
        swing = { active = true, remaining = 3, speed = 3.5,
            slamCast = 2, slamCapable = true } })
    Check("disabled AoE Whirlwind reserves neither rage nor Sweeping charges",
        P:Recommend(state).key == "SLAM")
    state = State({ rage = 5, overpower = true, rotationDB = { useOverpower = false },
        cooldowns = CoreCooldowns(99, 99, 0) })
    Check("disabled Overpower does not request a stance dance",
        P:Recommend(state).key ~= "BATTLE_STANCE")

    known.BLOODTHIRST = true
    state = State({ rage = 25, rotationDB = { useStrike = false },
        cooldowns = CoreCooldowns(99, 0) })
    state.cooldowns.BLOODTHIRST = { remaining = 0.2, duration = 6 }
    Check("disabled Bloodthirst removes its near-ready rage hold without changing Fury",
        P:IsFury() and P:Recommend(state).key == "WHIRLWIND")
    known.BLOODTHIRST = false

    flurryRank = 5
    state = State({ rage = 45, predictedMainHandRage = 55,
        rotationDB = { useSlam = false, useStrike = false, useWhirlwind = false },
        cooldowns = CoreCooldowns(0, 0),
        swing = { active = true, remaining = 1.5, speed = 3.5,
            slamCast = 1.5, slamCapable = true } })
    Check("disabled core skills reserve neither timing nor rage before Heroic Strike",
        P:Recommend(state).key == "HEROIC_STRIKE")
    state.mode = "aoe"
    Check("disabled core skills release the same Cleave budget",
        P:Recommend(state).key == "CLEAVE")
    flurryRank = 0

    state = State({ mode = "aoe", rage = 30, rotationDB = { slamClip = 0.25 },
        swing = { active = true, remaining = 1.8, speed = 3.5,
            slamCast = 2, slamCapable = true } })
    Check("AoE uses its configured Slam clip allowance", P:Recommend(state).key == "SLAM")
    state.rotationDB.slamClip = 0.10
    Check("lowering AoE clip rejects the same late Slam", P:Recommend(state).key ~= "SLAM")

    local oldSetMode, oldBuildState = D.SetMode, D.BuildState
    local oldPrepare, oldUpdate = D.PrepareExecutionTarget, D.Update
    local oldCast, oldNoQueue = CastSpellByName, CastSpellByNameNoQueue
    local castName
    D.SetMode, D.Update = function() end, function() end
    D.PrepareExecutionTarget = function() return false end
    D.BuildState = function() return state end
    CastSpellByNameNoQueue = function(name) castName = name end
    CastSpellByName = function() error("Execute entered the generic queue") end
    for _, mode in ipairs({ "single", "aoe" }) do
        state = State({ mode = mode, targetHP = 20, rage = 15,
            rotationDB = { executeLead = 0.75 },
            swing = { active = true, remaining = 0.6, speed = 3.5,
                slamCast = 2, slamCapable = true, slamUsed = true } })
        castName = nil
        Check(mode .. " extended lead time changes actual Execute timing",
            P:Execute(mode) and castName == "斩杀")
        state.rotationDB.executeLead = 0.35
        local rec, forecast = P:Evaluate(state)
        local execute = ForecastByKey(forecast, "EXECUTE")
        Check(mode .. " shortened lead is shared by recommendation, forecast and execution",
            rec.key ~= "EXECUTE" and execute and math.abs(execute.eta - 0.25) < 0.001
                and not P:Execute(mode))
        state.rotationDB.executeLead, state.swing.remaining = 999, 1.1
        Check(mode .. " saved lead is clamped before execution", not P:Execute(mode))
        state.rotationDB.executeLead, state.swing.remaining = 0.75, 0.20
        Check(mode .. " configured lead preserves the swing boundary", not P:Execute(mode))
    end
    D.SetMode, D.BuildState = oldSetMode, oldBuildState
    D.PrepareExecutionTarget, D.Update = oldPrepare, oldUpdate
    CastSpellByName, CastSpellByNameNoQueue = oldCast, oldNoQueue
end

print("WarriorArms_spec: " .. passed .. " checks passed")
