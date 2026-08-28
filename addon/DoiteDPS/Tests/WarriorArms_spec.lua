-- Focused self-check for the two-handed deep Arms rotation.
-- Run from Interface/AddOns: lua DoiteDPS/Tests/WarriorArms_spec.lua

local now = 100
local unbridledWrathRank = 0
table.getn = table.getn or function(value) return #value end
function GetTime() return now end
function GetLocale() return "zhCN" end
function GetTalentInfo(tab, index)
    if tab == 2 and index == 1 then
        return "怒不可遏", nil, 1, 1, unbridledWrathRank, 5
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
        targetTTDConfidence = false,
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
    "only the single and AoE deep-Arms modes remain",
    table.getn(P.ModeOrder) == 2
        and P.ModeOrder[1] == "single"
        and P.ModeOrder[2] == "aoe"
        and P.ModeLabels.single == "双手武器战"
)
Check(
    "Slam exposes a 0.17-second clip limit instead of a safety margin",
    P.RotationDefaults.single.slamClip == 0.17
        and P.RotationDefaults.single.slamSafety == nil
        and P.ConfigSchema.options[1].key == "slamClip"
        and P.ConfigSchema.options[1].max == 0.30
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
Check(
    "Sunder maintenance is an opt-in setting for both modes",
    P.RotationDefaults.single.maintainSunder == false
        and P.RotationDefaults.aoe.maintainSunder == false
        and P.ConfigSchema.options[7].key == "maintainSunder"
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
    P.ConfigSchema.options[8].key == "tier3TwoPiece"
        and P.ConfigSchema.options[8].scope == "general"
        and P.ConfigSchema.options[8].modes[1] == "single"
        and P.ConfigSchema.options[8].modes[2] == "aoe"
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
observedSwing = { active = true, progress = 0.10 }
P:ObserveSwingCycle(observedSwing)
Check("white-hit progress rollover opens a fresh Slam cycle", not observedSwing.slamUsed)

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
        remaining = 0.13,
        slamUsed = true,
        slamCapable = true,
    },
}))
Check("the minimum Execute lands after Slam and before the white hit", action.key == "EXECUTE")

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
        remaining = 0.20,
        slamCast = 1.5,
        slamCapable = true,
    },
}))
Check("Execute beats a missing Battle Shout before the next white hit", action.key == "EXECUTE")

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
Check("a late swing rejects MS/WW combos and Executes", action.key == "EXECUTE")

action = P:Recommend(State({
    targetHP = 20,
    rage = 35,
    cooldowns = CoreCooldowns(4, 4),
    targetTTDConfidence = true,
    targetTTD = 0.8,
}))
Check("a short-lived target is Executed immediately", action.key == "EXECUTE")

action = P:Recommend(State({
    targetHP = 20,
    rage = 35,
    cooldowns = CoreCooldowns(4, 4),
    targetTTDConfidence = true,
    targetTTD = 0.8,
    targetBoss = true,
}))
Check("a dying boss is also Executed immediately", action.key == "EXECUTE")

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
Check("Slam is never recommended while moving", action.key == "AUTO_ATTACK")

action = P:Recommend(State({
    rage = 90,
    predictedMainHandRage = 15,
    cooldowns = CoreCooldowns(4, 4),
}))
Check("Heroic Strike queues only for a predicted cap", action.key == "HEROIC_STRIKE")

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
Check("AoE drains a pending Sweeping window with Whirlwind", action.key == "WHIRLWIND")

action = P:Recommend(State({
    mode = "aoe",
    rage = 75,
    cooldowns = CoreCooldowns(0, 4, 99, 0),
}))
Check("AoE drains a pending Sweeping window with Mortal Strike", action.key == "MORTAL_STRIKE")

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
Check("a safe Slam removes a false Cleave cap risk", action.key == "SLAM")

action = P:Recommend(State({
    mode = "aoe",
    targetHP = 20,
    rage = 120,
    maxRage = 130,
    predictedMainHandRage = 36,
    cooldowns = CoreCooldowns(4, 4, 99, 5),
    swing = {
        active = true,
        remaining = 0.2,
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
        remaining = 0.5,
        speed = 3.63,
        slamCast = 2.0,
        slamCapable = false,
    },
}))
Check("Cleave may spend Sweeping charges that Whirlwind does not need", action.key == "CLEAVE")

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

print("WarriorArms_spec: " .. passed .. " checks passed")
