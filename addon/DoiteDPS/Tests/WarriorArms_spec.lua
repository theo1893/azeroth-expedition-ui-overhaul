-- Focused self-check for the two-handed deep Arms rotation.
-- Run from Interface/AddOns: lua DoiteDPS/Tests/WarriorArms_spec.lua

local now = 100
table.getn = table.getn or function(value) return #value end
function GetTime() return now end
function GetLocale() return "zhCN" end

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
function D:GetRealCooldown() return 0, 0 end
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
    "white rage prediction weights the current 40 percent crit chance",
    math.abs(P._expectedWhiteRage(768.5, 3.5, 40) - 40.4844) < 0.001
)
Check(
    "Sunder maintenance is an opt-in setting for both modes",
    P.RotationDefaults.single.maintainSunder == false
        and P.RotationDefaults.aoe.maintainSunder == false
        and P.ConfigSchema.options[7].key == "maintainSunder"
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
Check("a ready Whirlwind keeps priority during another instant GCD", action.key == "WHIRLWIND")

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
    rage = 45,
    cooldowns = CoreCooldowns(0, 99),
    swing = {
        active = true,
        remaining = 3.0,
        slamCast = 1.5,
        slamCapable = true,
    },
}))
Check("45 rage funds Mortal Strike then Execute", action.key == "MORTAL_STRIKE")

action = P:Recommend(State({
    targetHP = 20,
    rage = 40,
    cooldowns = CoreCooldowns(4, 0),
    swing = {
        active = true,
        remaining = 3.0,
        slamCast = 1.5,
        slamCapable = true,
    },
}))
Check("40 rage funds Whirlwind then Execute", action.key == "WHIRLWIND")

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
    rage = 5,
    stance = 1,
    sweepingStrikes = true,
}))
Check("AoE returns to Berserker after Sweeping", action.key == "BERSERKER_STANCE")

action = P:Recommend(State({
    mode = "aoe",
    rage = 50,
    cooldowns = CoreCooldowns(4, 0, 99, 0),
}))
Check("AoE drains a pending Sweeping window with Whirlwind", action.key == "WHIRLWIND")

action = P:Recommend(State({
    mode = "aoe",
    rage = 40,
    cooldowns = CoreCooldowns(4, 4, 99, 5),
}))
Check("AoE queues Cleave after Sweeping is no longer pending", action.key == "CLEAVE")

local previousCandidates = P._candidates
local forecast = P:BuildForecast(State({
    targetHP = 20,
    rage = 45,
    cooldowns = CoreCooldowns(0, 2),
}), { key = "MORTAL_STRIKE" })
Check("the QTE timeline keeps a compact forecast", forecast[1] ~= nil)
Check("each forecast resets Lua 5.0's cached list size", P._candidates ~= previousCandidates)

print("WarriorArms_spec: " .. passed .. " checks passed")
