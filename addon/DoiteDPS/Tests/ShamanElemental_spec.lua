-- Standalone checks for Elemental profile participation settings.
-- Run from the AddOns directory with:
-- lua DoiteDPS/Tests/ShamanElemental_spec.lua

if not table.getn then
    table.getn = function(value) return #value end
end

function GetTime() return 100 end
function GetLocale() return "zhCN" end

local known = {
    FLAME_SHOCK = true,
    FROST_SHOCK = true,
    LAVA_BURST = true,
    ELEMENTAL_MASTERY = true,
    WAR_STOMP = true,
    CHAIN_LIGHTNING = true,
    LIGHTNING_BOLT = true,
    LIGHTNING_STRIKE = true,
    STORMSTRIKE = true,
    EARTH_SHOCK = true,
    EARTHQUAKE = true,
    SEARING_TOTEM = true,
    FIRE_NOVA_TOTEM = true,
    MAGMA_TOTEM = true,
    HORDE_INSIGNIA = true,
}

local tracker = {}
function tracker:PredictFlameShockRemaining(remaining)
    return tonumber(remaining) or 0
end
function tracker:BuildState() end
function tracker:OnEvent() end
function tracker:SetLastCastReason(reason)
    self.lastCastReason = reason
end

DoiteDPS = {
    Profiles = {},
    Trackers = { ShamanElemental = tracker },
    ShamanCooldownKeys = {},
    Names = {
        FLAME_SHOCK = "FLAME_SHOCK",
        FROST_SHOCK = "FROST_SHOCK",
        LAVA_BURST = "LAVA_BURST",
        ELEMENTAL_MASTERY = "ELEMENTAL_MASTERY",
        WAR_STOMP = "WAR_STOMP",
        CHAIN_LIGHTNING = "CHAIN_LIGHTNING",
        LIGHTNING_BOLT = "LIGHTNING_BOLT",
        LIGHTNING_STRIKE = "LIGHTNING_STRIKE",
        STORMSTRIKE = "STORMSTRIKE",
        EARTH_SHOCK = "EARTH_SHOCK",
        EARTHQUAKE = "EARTHQUAKE",
        SEARING_TOTEM = "SEARING_TOTEM",
        FIRE_NOVA_TOTEM = "FIRE_NOVA_TOTEM",
        MAGMA_TOTEM = "MAGMA_TOTEM",
        HORDE_INSIGNIA = "HORDE_INSIGNIA",
    },
    FORECAST_LIMIT = 3,
}

local D = DoiteDPS
function D:IsKnown(key) return known[key] and true or false end
function D:GetName(key) return self.Names[key] or key end
function D:GetTexture(key) return key end
function D:GetRealCooldown() return 0 end
function D:GetProfileDB() return self.profileDB end
function D:IsMeleeRange() return true end

dofile("DoiteDPS/Profiles/ShamanElemental.lua")
local P = D.Profiles.ShamanElemental

local function Profile(changes)
    local db = {
        enhancePvPShock = "earth",
        singleOutputMode = "conserve",
        aoeOutputMode = "conserve",
        enableCL = true,
        enableCLAoE = true,
        enableQuakeAoE = true,
        enableESMoving = true,
        enableFSLB = true,
        enableSearingTotem = true,
        enableFireNovaTotem = true,
        enableMagmaTotem = true,
    }
    for key, value in pairs(changes or {}) do
        db[key] = value
    end
    return db
end

local function State(db, changes)
    local state = {
        now = 100,
        profileDB = db,
        targetValid = true,
        targetDistance = 5,
        inRange = true,
        closeInRange = true,
        meleeInRange = true,
        moving = false,
        mode = "single",
        casting = false,
        castRemaining = 0,
        gcd = 0,
        castName = nil,
        lavaBurstFlying = false,
        lavaBurstTravel = 1.5,
        flameShock = false,
        flameShockRemaining = 0,
        clearcasting = 0,
        controlLost = false,
        hordeInsigniaSlot = nil,
        fireTotemStateAvailable = false,
        fireTotemActive = false,
        fireTotemKind = nil,
        fireTotemRemaining = 0,
        fireNovaActivation = 3,
        cooldowns = {
            FLAME_SHOCK = { remaining = 0 },
            FROST_SHOCK = { remaining = 0 },
            LAVA_BURST = { remaining = 0 },
            ELEMENTAL_MASTERY = { remaining = 0 },
            WAR_STOMP = { remaining = 0 },
            CHAIN_LIGHTNING = { remaining = 0 },
            LIGHTNING_STRIKE = { remaining = 0 },
            STORMSTRIKE = { remaining = 0 },
            EARTH_SHOCK = { remaining = 0 },
            EARTHQUAKE = { remaining = 0 },
            SEARING_TOTEM = { remaining = 0 },
            FIRE_NOVA_TOTEM = { remaining = 0 },
            MAGMA_TOTEM = { remaining = 0 },
        },
    }
    for key, value in pairs(changes or {}) do
        state[key] = value
    end
    return state
end

local passed = 0
local hasAutoTarget = false
local hasSmartAoETarget = false
local singleOutputModeOption
local aoeOutputModeOption
local optionIndex = 1
while optionIndex <= table.getn(P.ConfigSchema.options) do
    local option = P.ConfigSchema.options[optionIndex]
    if option.key == "singleOutputMode" then
        singleOutputModeOption = option
    elseif option.key == "aoeOutputMode" then
        aoeOutputModeOption = option
    end
    if option.key == "enableAutoTarget" then hasAutoTarget = true end
    if option.key == "enableAoETarget" then hasSmartAoETarget = true end
    optionIndex = optionIndex + 1
end
assert(
    singleOutputModeOption
        and aoeOutputModeOption
        and singleOutputModeOption.type == "choice"
        and aoeOutputModeOption.type == "choice"
        and singleOutputModeOption.label == "模式"
        and aoeOutputModeOption.label == "模式"
        and singleOutputModeOption.values[1].value == "conserve"
        and singleOutputModeOption.values[1].label == "节能模式"
        and singleOutputModeOption.values[2].value == "burst"
        and singleOutputModeOption.values[2].label == "爆发模式",
    "single and AoE should expose separate conserve/burst choices"
)
assert(not hasAutoTarget,
    "automatic nearest-enemy targeting should be fixed behavior, not a setting")
assert(not hasSmartAoETarget and P.SelectAoETarget == nil,
    "the old smart AoE target-cycling feature must be removed")
passed = passed + 1

assert(
    table.getn(P.ModeOrder) == 5
        and P.ModeOrder[3] == "elemental_pvp_close"
        and P.ModeOrder[4] == "enhance_pvp_melee"
        and P.ModeOrder[5] == "enhance_pvp_ranged"
        and table.getn(P.EntryOrder) == 3
        and P.EntryOrder[3] == "pvp_close"
        and P.EntryPoints.pvp_close.modes[1] == "elemental_pvp_close"
        and P.EntryPoints.single.modes[2] == "enhance_pvp_melee"
        and P.EntryPoints.aoe.modes[2] == "enhance_pvp_ranged",
    "Shaman should expose a separate Elemental close-PvP entry without changing the existing output bindings"
)
assert(
    P.ConfigSchema.title == "萨满输出"
        and table.getn(P.ConfigSchema.modeGroups) == 2
        and P.ConfigSchema.modeGroups[1].key == "single"
        and table.getn(P.ConfigSchema.modeGroups[1].modes) == 3
        and P.ConfigSchema.modeGroups[1].modes[1] == "single"
        and P.ConfigSchema.modeGroups[1].modes[2]
            == "elemental_pvp_close"
        and P.ConfigSchema.modeGroups[1].modes[3]
            == "enhance_pvp_melee"
        and P.ConfigSchema.modeGroups[2].key == "aoe"
        and table.getn(P.ConfigSchema.modeGroups[2].modes) == 2
        and P.ConfigSchema.modeGroups[2].modes[1] == "aoe"
        and P.ConfigSchema.modeGroups[2].modes[2]
            == "enhance_pvp_ranged"
        and P.ModeLabels.elemental_pvp_close == "电萨PvP近战"
        and P.ModeLabels.enhance_pvp_melee == "增强PvP近战"
        and P.ModeLabels.enhance_pvp_ranged == "增强PvP远程",
    "the Shaman configuration should group all five rotations without hiding its dedicated close-PvP entry"
)
passed = passed + 1

local function ConfigOptionsForMode(mode)
    local visible = {}
    local index = 1
    while index <= table.getn(P.ConfigSchema.options) do
        local option = P.ConfigSchema.options[index]
        local matches = type(option.modes) ~= "table"
        local modeIndex = 1
        while not matches and modeIndex <= table.getn(option.modes) do
            if option.modes[modeIndex] == mode then matches = true end
            modeIndex = modeIndex + 1
        end
        if matches then
            visible[table.getn(visible) + 1] = option
        end
        index = index + 1
    end
    return visible
end

local singleConfig = ConfigOptionsForMode("single")
assert(
    table.getn(singleConfig) == 5
        and singleConfig[1].key == "singleOutputMode"
        and singleConfig[1].section == "输出模式"
        and singleConfig[2].key == "enableFSLB"
        and singleConfig[2].section == "单体循环技能"
        and singleConfig[3].key == "enableCL"
        and singleConfig[3].label == "闪电链"
        and singleConfig[4].key == "enableSearingTotem"
        and singleConfig[4].section == "伤害图腾"
        and singleConfig[5].key == "enableESMoving",
    "single config should separate output mode, skills, and Searing Totem"
)

local aoeConfig = ConfigOptionsForMode("aoe")
assert(
    table.getn(aoeConfig) == 6
        and aoeConfig[1].key == "aoeOutputMode"
        and aoeConfig[1].section == "输出模式"
        and aoeConfig[2].key == "enableQuakeAoE"
        and aoeConfig[2].section == "群体循环技能"
        and aoeConfig[2].label == "地震术"
        and aoeConfig[3].key == "enableCLAoE"
        and aoeConfig[3].label == "闪电链"
        and aoeConfig[4].key == "enableFireNovaTotem"
        and aoeConfig[4].section == "伤害图腾"
        and aoeConfig[5].key == "enableMagmaTotem"
        and aoeConfig[6].key == "enableESMoving",
    "AoE config should expose plain skill and independent totem toggles"
)
local enhanceMeleeConfig = ConfigOptionsForMode("enhance_pvp_melee")
assert(
    table.getn(enhanceMeleeConfig) == 1
        and enhanceMeleeConfig[1].type == "choice"
        and enhanceMeleeConfig[1].key == "enhancePvPShock"
        and table.getn(enhanceMeleeConfig[1].values) == 4
        and enhanceMeleeConfig[1].values[1].value == "earth"
        and enhanceMeleeConfig[1].values[2].value == "frost"
        and enhanceMeleeConfig[1].values[3].value == "flame"
        and enhanceMeleeConfig[1].values[4].value == "off"
        and table.getn(ConfigOptionsForMode("elemental_pvp_close")) == 0
        and table.getn(ConfigOptionsForMode("enhance_pvp_ranged")) == 0,
    "fixed PvP rotations should not reuse the configurable PvE skill switches"
)
passed = passed + 1

local function ExpectRecommendation(name, expected, state)
    local recommendation = P:Recommend(state)
    assert(
        recommendation.key == expected,
        name .. ": expected " .. expected
            .. ", got " .. tostring(recommendation.key)
    )
    passed = passed + 1
end

local function Contains(forecast, key)
    local index = 1
    while index <= 3 do
        if forecast[index] and forecast[index].key == key then
            return true
        end
        index = index + 1
    end
    return false
end

local function ExpectForecastPresence(name, state, expected)
    local recommendation, forecast = P:Evaluate(state)
    for key, present in pairs(expected) do
        local actual = Contains(forecast, key)
        assert(
            actual == present,
            name .. ": " .. key .. " expected "
                .. tostring(present) .. ", got " .. tostring(actual)
                .. " (current=" .. tostring(recommendation.key) .. ")"
        )
    end
    passed = passed + 1
end

local singleBurstOnly = Profile({
    singleOutputMode = "burst",
    aoeOutputMode = "conserve",
})
ExpectRecommendation(
    "single burst does not force the AoE rotation into burst mode",
    "CHAIN_LIGHTNING",
    State(singleBurstOnly, {
        clearcasting = 0,
    })
)
ExpectRecommendation(
    "AoE remains in conserve mode when only single is burst",
    "LIGHTNING_BOLT",
    State(singleBurstOnly, {
        mode = "aoe",
        clearcasting = 0,
    })
)

local aoeBurstOnly = Profile({
    singleOutputMode = "conserve",
    aoeOutputMode = "burst",
})
ExpectRecommendation(
    "single remains in conserve mode when only AoE is burst",
    "EARTH_SHOCK",
    State(aoeBurstOnly, {
        moving = true,
        clearcasting = 0,
    })
)
ExpectRecommendation(
    "AoE burst does not force the single rotation into burst mode",
    "EARTHQUAKE",
    State(aoeBurstOnly, {
        mode = "aoe",
        clearcasting = 0,
    })
)

ExpectRecommendation(
    "single burst keeps enabled moving Earth Shock ahead of cast-time spells",
    "EARTH_SHOCK",
    State(Profile({ singleOutputMode = "burst" }), {
        moving = true,
        clearcasting = 0,
    })
)

ExpectRecommendation(
    "AoE burst keeps enabled moving Earth Shock ahead of cast-time spells",
    "EARTH_SHOCK",
    State(Profile({ aoeOutputMode = "burst" }), {
        mode = "aoe",
        moving = true,
        clearcasting = 0,
    })
)

ExpectRecommendation(
    "burst mode respects a disabled moving Earth Shock toggle",
    "CHAIN_LIGHTNING",
    State(Profile({
        singleOutputMode = "burst",
        enableESMoving = false,
    }), {
        moving = true,
        clearcasting = 0,
    })
)

ExpectRecommendation(
    "enabled combo recommends Flame Shock",
    "FLAME_SHOCK",
    State(Profile())
)

ExpectRecommendation(
    "disabled combo falls back to Lightning Bolt",
    "LIGHTNING_BOLT",
    State(Profile({ enableFSLB = false }))
)

ExpectRecommendation(
    "single rotation starts a checked Searing Totem when the fire slot is empty",
    "SEARING_TOTEM",
    State(Profile({ enableFSLB = false }), {
        fireTotemStateAvailable = true,
    })
)

ExpectRecommendation(
    "single rotation allows Searing Totem at exactly 25 yards",
    "SEARING_TOTEM",
    State(Profile({ enableFSLB = false }), {
        targetDistance = 25,
        fireTotemStateAvailable = true,
    })
)

ExpectRecommendation(
    "single rotation skips Searing Totem beyond 25 yards",
    "LIGHTNING_BOLT",
    State(Profile({ enableFSLB = false }), {
        targetDistance = 25.01,
        fireTotemStateAvailable = true,
    })
)

local singleUnknownTotemDistance = State(
    Profile({ enableFSLB = false }),
    { fireTotemStateAvailable = true }
)
singleUnknownTotemDistance.targetDistance = nil
ExpectRecommendation(
    "single rotation skips Searing Totem when distance is unknown",
    "LIGHTNING_BOLT",
    singleUnknownTotemDistance
)

ExpectRecommendation(
    "disabled Searing Totem falls back to the spell rotation",
    "LIGHTNING_BOLT",
    State(Profile({
        enableFSLB = false,
        enableSearingTotem = false,
    }), {
        fireTotemStateAvailable = true,
    })
)

ExpectRecommendation(
    "single rotation replaces an active Magma Totem with Searing Totem",
    "SEARING_TOTEM",
    State(Profile({ enableFSLB = false }), {
        fireTotemStateAvailable = true,
        fireTotemActive = true,
        fireTotemKind = "magma",
        fireTotemRemaining = 12,
    })
)

ExpectRecommendation(
    "single rotation does not overwrite Fire Nova before activation",
    "LIGHTNING_BOLT",
    State(Profile({ enableFSLB = false }), {
        fireTotemStateAvailable = true,
        fireTotemActive = true,
        fireTotemKind = "nova",
        fireTotemRemaining = 2,
    })
)

ExpectRecommendation(
    "single rotation protects a utility fire totem",
    "LIGHTNING_BOLT",
    State(Profile({ enableFSLB = false }), {
        fireTotemStateAvailable = true,
        fireTotemActive = true,
        fireTotemKind = "utility",
        fireTotemRemaining = 90,
    })
)

ExpectRecommendation(
    "AoE starts with a checked Fire Nova Totem",
    "FIRE_NOVA_TOTEM",
    State(Profile(), {
        mode = "aoe",
        fireTotemStateAvailable = true,
    })
)

ExpectRecommendation(
    "AoE allows Fire Nova Totem at exactly 8 yards",
    "FIRE_NOVA_TOTEM",
    State(Profile(), {
        mode = "aoe",
        targetDistance = 8,
        fireTotemStateAvailable = true,
    })
)

ExpectRecommendation(
    "AoE skips Fire Nova and Magma Totems beyond 8 yards",
    "LIGHTNING_BOLT",
    State(Profile(), {
        mode = "aoe",
        targetDistance = 8.01,
        fireTotemStateAvailable = true,
    })
)

ExpectRecommendation(
    "AoE locks the fire slot while Fire Nova is activating",
    "LIGHTNING_BOLT",
    State(Profile(), {
        mode = "aoe",
        fireTotemStateAvailable = true,
        fireTotemActive = true,
        fireTotemKind = "nova",
        fireTotemRemaining = 2,
    })
)

local aoeAfterNova = State(Profile(), {
    mode = "aoe",
    fireTotemStateAvailable = true,
})
aoeAfterNova.cooldowns.FIRE_NOVA_TOTEM.remaining = 12
ExpectRecommendation(
    "AoE follows Fire Nova with a checked Magma Totem",
    "MAGMA_TOTEM",
    aoeAfterNova
)

local distantAoEAfterNova = State(Profile(), {
    mode = "aoe",
    targetDistance = 9,
    fireTotemStateAvailable = true,
})
distantAoEAfterNova.cooldowns.FIRE_NOVA_TOTEM.remaining = 12
ExpectRecommendation(
    "AoE skips Magma Totem beyond 8 yards",
    "LIGHTNING_BOLT",
    distantAoEAfterNova
)

ExpectRecommendation(
    "AoE lets Magma Totem finish even when Fire Nova is ready",
    "LIGHTNING_BOLT",
    State(Profile(), {
        mode = "aoe",
        fireTotemStateAvailable = true,
        fireTotemActive = true,
        fireTotemKind = "magma",
        fireTotemRemaining = 8,
    })
)

local aoeWithoutNova = State(Profile({
    enableFireNovaTotem = false,
}), {
    mode = "aoe",
    fireTotemStateAvailable = true,
})
ExpectRecommendation(
    "disabling Fire Nova leaves checked Magma Totem in the AoE rotation",
    "MAGMA_TOTEM",
    aoeWithoutNova
)

local aoeWithoutMagma = State(Profile({
    enableMagmaTotem = false,
}), {
    mode = "aoe",
    fireTotemStateAvailable = true,
})
ExpectRecommendation(
    "disabling Magma leaves checked Fire Nova Totem in the AoE rotation",
    "FIRE_NOVA_TOTEM",
    aoeWithoutMagma
)

local burstSingleTotem = State(Profile({
    singleOutputMode = "burst",
}), {
    fireTotemStateAvailable = true,
})
burstSingleTotem.cooldowns.CHAIN_LIGHTNING.remaining = 4
ExpectRecommendation(
    "burst mode includes a checked Searing Totem before its filler",
    "SEARING_TOTEM",
    burstSingleTotem
)

ExpectRecommendation(
    "Elemental close PvP starts with a ready Elemental Mastery",
    "ELEMENTAL_MASTERY",
    State(Profile({
        enableCL = false,
        enableESMoving = false,
        enableSearingTotem = true,
    }), {
        mode = "elemental_pvp_close",
        fireTotemStateAvailable = true,
    })
)

local elementalCloseStomp = State(Profile(), {
    mode = "elemental_pvp_close",
})
elementalCloseStomp.cooldowns.ELEMENTAL_MASTERY.remaining = 180
ExpectRecommendation(
    "Elemental close PvP falls back from Elemental Mastery to War Stomp",
    "WAR_STOMP",
    elementalCloseStomp
)

local elementalCloseChain = State(Profile(), {
    mode = "elemental_pvp_close",
})
elementalCloseChain.cooldowns.ELEMENTAL_MASTERY.remaining = 180
elementalCloseChain.cooldowns.WAR_STOMP.remaining = 90
ExpectRecommendation(
    "Elemental close PvP falls back from War Stomp to Chain Lightning",
    "CHAIN_LIGHTNING",
    elementalCloseChain
)

known.ELEMENTAL_MASTERY = false
ExpectRecommendation(
    "Elemental close PvP skips an unlearned Elemental Mastery",
    "WAR_STOMP",
    State(Profile(), {
        mode = "elemental_pvp_close",
    })
)
known.ELEMENTAL_MASTERY = true

known.WAR_STOMP = false
local elementalCloseNoRacial = State(Profile(), {
    mode = "elemental_pvp_close",
})
elementalCloseNoRacial.cooldowns.ELEMENTAL_MASTERY.remaining = 180
ExpectRecommendation(
    "Elemental close PvP skips an unlearned racial",
    "CHAIN_LIGHTNING",
    elementalCloseNoRacial
)
known.WAR_STOMP = true

local elementalCloseMoving = State(Profile({
    enableESMoving = false,
}), {
    mode = "elemental_pvp_close",
    moving = true,
})
elementalCloseMoving.cooldowns.ELEMENTAL_MASTERY.remaining = 180
ExpectRecommendation(
    "Elemental close PvP moves Earth Shock ahead of War Stomp and cast-time spells",
    "EARTH_SHOCK",
    elementalCloseMoving
)

local elementalCloseMovingShockCooldown = State(Profile(), {
    mode = "elemental_pvp_close",
    moving = true,
})
elementalCloseMovingShockCooldown.cooldowns.ELEMENTAL_MASTERY.remaining = 180
elementalCloseMovingShockCooldown.cooldowns.EARTH_SHOCK.remaining = 4
ExpectRecommendation(
    "Elemental close PvP returns to War Stomp when moving Earth Shock is cooling down",
    "WAR_STOMP",
    elementalCloseMovingShockCooldown
)

local elementalCloseShock = State(Profile(), {
    mode = "elemental_pvp_close",
})
elementalCloseShock.cooldowns.ELEMENTAL_MASTERY.remaining = 180
elementalCloseShock.cooldowns.WAR_STOMP.remaining = 90
elementalCloseShock.cooldowns.CHAIN_LIGHTNING.remaining = 4
ExpectRecommendation(
    "Elemental close PvP falls back from Chain Lightning to Earth Shock",
    "EARTH_SHOCK",
    elementalCloseShock
)

local elementalCloseBolt = State(Profile(), {
    mode = "elemental_pvp_close",
})
elementalCloseBolt.cooldowns.ELEMENTAL_MASTERY.remaining = 180
elementalCloseBolt.cooldowns.WAR_STOMP.remaining = 90
elementalCloseBolt.cooldowns.CHAIN_LIGHTNING.remaining = 4
elementalCloseBolt.cooldowns.EARTH_SHOCK.remaining = 4
ExpectRecommendation(
    "Elemental close PvP uses Lightning Bolt as its lowest priority",
    "LIGHTNING_BOLT",
    elementalCloseBolt
)

local elementalCloseDistant = State(Profile(), {
    mode = "elemental_pvp_close",
    closeInRange = false,
})
elementalCloseDistant.cooldowns.ELEMENTAL_MASTERY.remaining = 180
ExpectRecommendation(
    "Elemental close PvP skips War Stomp when the target is not close",
    "CHAIN_LIGHTNING",
    elementalCloseDistant
)

local elementalCloseOutOfRange = State(Profile(), {
    mode = "elemental_pvp_close",
    closeInRange = false,
    inRange = false,
})
elementalCloseOutOfRange.cooldowns.WAR_STOMP.remaining = 90
ExpectRecommendation(
    "Elemental close PvP waits when no damage spell is in range",
    "WAIT",
    elementalCloseOutOfRange
)

ExpectRecommendation(
    "Enhancement PvP melee starts with Stormstrike",
    "STORMSTRIKE",
    State(Profile(), {
        mode = "enhance_pvp_melee",
        fireTotemStateAvailable = true,
    })
)

local enhanceMeleeLightningStrike = State(Profile(), {
    mode = "enhance_pvp_melee",
})
enhanceMeleeLightningStrike.cooldowns.STORMSTRIKE.remaining = 4
ExpectRecommendation(
    "Enhancement PvP melee falls back to Lightning Strike",
    "LIGHTNING_STRIKE",
    enhanceMeleeLightningStrike
)

local enhanceMeleeEarthShock = State(Profile(), {
    mode = "enhance_pvp_melee",
})
enhanceMeleeEarthShock.cooldowns.STORMSTRIKE.remaining = 4
enhanceMeleeEarthShock.cooldowns.LIGHTNING_STRIKE.remaining = 4
ExpectRecommendation(
    "Enhancement PvP melee falls back to Earth Shock",
    "EARTH_SHOCK",
    enhanceMeleeEarthShock
)

local enhanceMeleeFrostShock = State(Profile({
    enhancePvPShock = "frost",
}), {
    mode = "enhance_pvp_melee",
})
enhanceMeleeFrostShock.cooldowns.STORMSTRIKE.remaining = 4
enhanceMeleeFrostShock.cooldowns.LIGHTNING_STRIKE.remaining = 4
ExpectRecommendation(
    "Enhancement PvP melee can use Frost Shock",
    "FROST_SHOCK",
    enhanceMeleeFrostShock
)

local enhanceMeleeFlameShock = State(Profile({
    enhancePvPShock = "flame",
}), {
    mode = "enhance_pvp_melee",
})
enhanceMeleeFlameShock.cooldowns.STORMSTRIKE.remaining = 4
enhanceMeleeFlameShock.cooldowns.LIGHTNING_STRIKE.remaining = 4
ExpectRecommendation(
    "Enhancement PvP melee can use Flame Shock",
    "FLAME_SHOCK",
    enhanceMeleeFlameShock
)

local enhanceMeleeNoShock = State(Profile({
    enhancePvPShock = "off",
}), {
    mode = "enhance_pvp_melee",
})
enhanceMeleeNoShock.cooldowns.STORMSTRIKE.remaining = 4
enhanceMeleeNoShock.cooldowns.LIGHTNING_STRIKE.remaining = 4
ExpectRecommendation(
    "Enhancement PvP melee can disable automatic shocks",
    "WAIT",
    enhanceMeleeNoShock
)

local enhanceMeleeWaiting = State(Profile(), {
    mode = "enhance_pvp_melee",
})
enhanceMeleeWaiting.cooldowns.LIGHTNING_STRIKE.remaining = 4
enhanceMeleeWaiting.cooldowns.STORMSTRIKE.remaining = 4
enhanceMeleeWaiting.cooldowns.EARTH_SHOCK.remaining = 4
ExpectRecommendation(
    "Enhancement PvP melee waits when its core skills and selected shock are cooling down",
    "WAIT",
    enhanceMeleeWaiting
)

ExpectRecommendation(
    "Enhancement PvP melee does not substitute ranged spells outside melee range",
    "WAIT",
    State(Profile(), {
        mode = "enhance_pvp_melee",
        meleeInRange = false,
    })
)

ExpectRecommendation(
    "Enhancement PvP ranged starts with Chain Lightning",
    "CHAIN_LIGHTNING",
    State(Profile({
        enableCL = false,
        enableCLAoE = false,
    }), {
        mode = "enhance_pvp_ranged",
        fireTotemStateAvailable = true,
    })
)

local enhanceRangedBolt = State(Profile(), {
    mode = "enhance_pvp_ranged",
})
enhanceRangedBolt.cooldowns.CHAIN_LIGHTNING.remaining = 4
ExpectRecommendation(
    "Enhancement PvP ranged falls back to Lightning Bolt",
    "LIGHTNING_BOLT",
    enhanceRangedBolt
)

ExpectRecommendation(
    "Enhancement PvP ranged respects spell range",
    "WAIT",
    State(Profile(), {
        mode = "enhance_pvp_ranged",
        inRange = false,
    })
)

ExpectRecommendation(
    "Enhancement PvP uses a ready Horde insignia before target checks",
    "HORDE_INSIGNIA",
    State(Profile(), {
        mode = "enhance_pvp_melee",
        targetValid = false,
        inRange = false,
        meleeInRange = false,
        controlLost = true,
        hordeInsigniaSlot = 13,
    })
)

local elementalCloseRecommendation, elementalCloseForecast = P:Evaluate(
    State(Profile(), {
        mode = "elemental_pvp_close",
        fireTotemStateAvailable = true,
    })
)
assert(
    elementalCloseRecommendation.key == "ELEMENTAL_MASTERY"
        and elementalCloseForecast[1]
        and elementalCloseForecast[1].key == "WAR_STOMP"
        and elementalCloseForecast[2]
        and elementalCloseForecast[2].key == "CHAIN_LIGHTNING"
        and elementalCloseForecast[3]
        and elementalCloseForecast[3].key == "EARTH_SHOCK"
        and not Contains(elementalCloseForecast, "LIGHTNING_BOLT")
        and not Contains(elementalCloseForecast, "SEARING_TOTEM")
        and not Contains(elementalCloseForecast, "MAGMA_TOTEM"),
    "Elemental close PvP forecast should put Elemental Mastery before the damage priority and keep totems manual"
)
passed = passed + 1

local elementalCloseMovingRecommendation, elementalCloseMovingForecast = P:Evaluate(
    State(Profile(), {
        mode = "elemental_pvp_close",
        moving = true,
    })
)
assert(
    elementalCloseMovingRecommendation.key == "ELEMENTAL_MASTERY"
        and elementalCloseMovingForecast[1]
        and elementalCloseMovingForecast[1].key == "EARTH_SHOCK"
        and elementalCloseMovingForecast[2]
        and elementalCloseMovingForecast[2].key == "WAR_STOMP"
        and elementalCloseMovingForecast[3]
        and elementalCloseMovingForecast[3].key == "CHAIN_LIGHTNING",
    "Elemental close PvP forecast should move Earth Shock directly behind Elemental Mastery while moving"
)
passed = passed + 1

local elementalCloseNoMasteryState = State(Profile(), {
    mode = "elemental_pvp_close",
})
elementalCloseNoMasteryState.cooldowns.ELEMENTAL_MASTERY.remaining = 180
local elementalCloseNoMasteryRecommendation, elementalCloseNoMasteryForecast =
    P:Evaluate(elementalCloseNoMasteryState)
assert(
    elementalCloseNoMasteryRecommendation.key == "WAR_STOMP"
        and elementalCloseNoMasteryForecast[1]
        and elementalCloseNoMasteryForecast[1].key == "CHAIN_LIGHTNING"
        and elementalCloseNoMasteryForecast[2]
        and elementalCloseNoMasteryForecast[2].key == "EARTH_SHOCK"
        and elementalCloseNoMasteryForecast[3]
        and elementalCloseNoMasteryForecast[3].key == "LIGHTNING_BOLT",
    "Elemental close PvP forecast should retain the lower damage priority while Elemental Mastery cools down"
)
passed = passed + 1

local enhanceMeleeRecommendation, enhanceMeleeForecast = P:Evaluate(
    State(Profile(), {
        mode = "enhance_pvp_melee",
    })
)
assert(
    enhanceMeleeRecommendation.key == "STORMSTRIKE"
        and enhanceMeleeForecast[1]
        and enhanceMeleeForecast[1].key == "LIGHTNING_STRIKE"
        and enhanceMeleeForecast[2]
        and enhanceMeleeForecast[2].key == "EARTH_SHOCK"
        and not Contains(enhanceMeleeForecast, "SEARING_TOTEM")
        and not Contains(enhanceMeleeForecast, "MAGMA_TOTEM"),
    "Enhancement PvP melee forecast should preserve its fixed priority and manual totems"
)
passed = passed + 1

local _, enhanceFrostForecast = P:Evaluate(
    State(Profile({ enhancePvPShock = "frost" }), {
        mode = "enhance_pvp_melee",
    })
)
assert(
    enhanceFrostForecast[1]
        and enhanceFrostForecast[1].key == "LIGHTNING_STRIKE"
        and enhanceFrostForecast[2]
        and enhanceFrostForecast[2].key == "FROST_SHOCK"
        and not Contains(enhanceFrostForecast, "EARTH_SHOCK")
        and not Contains(enhanceFrostForecast, "FLAME_SHOCK"),
    "Enhancement PvP forecast should use only the selected Frost Shock"
)
passed = passed + 1

local _, enhanceNoShockForecast = P:Evaluate(
    State(Profile({ enhancePvPShock = "off" }), {
        mode = "enhance_pvp_melee",
    })
)
assert(
    enhanceNoShockForecast[1]
        and enhanceNoShockForecast[1].key == "LIGHTNING_STRIKE"
        and not enhanceNoShockForecast[2]
        and not Contains(enhanceNoShockForecast, "EARTH_SHOCK")
        and not Contains(enhanceNoShockForecast, "FROST_SHOCK")
        and not Contains(enhanceNoShockForecast, "FLAME_SHOCK"),
    "Enhancement PvP forecast should remove every shock when automatic shocks are disabled"
)
passed = passed + 1

local enhanceRangedRecommendation, enhanceRangedForecast = P:Evaluate(
    State(Profile(), {
        mode = "enhance_pvp_ranged",
    })
)
assert(
    enhanceRangedRecommendation.key == "CHAIN_LIGHTNING"
        and enhanceRangedForecast[1]
        and enhanceRangedForecast[1].key == "LIGHTNING_BOLT"
        and not Contains(enhanceRangedForecast, "EARTHQUAKE")
        and not Contains(enhanceRangedForecast, "FIRE_NOVA_TOTEM"),
    "Enhancement PvP ranged forecast should contain only Chain Lightning and Lightning Bolt"
)
passed = passed + 1

ExpectForecastPresence(
    "single forecast waits for Fire Nova before showing Searing Totem",
    State(Profile({ enableFSLB = false }), {
        fireTotemStateAvailable = true,
        fireTotemActive = true,
        fireTotemKind = "nova",
        fireTotemRemaining = 2,
    }),
    {
        SEARING_TOTEM = true,
    }
)

ExpectForecastPresence(
    "AoE forecast follows an active Fire Nova with Magma Totem",
    State(Profile(), {
        mode = "aoe",
        fireTotemStateAvailable = true,
        fireTotemActive = true,
        fireTotemKind = "nova",
        fireTotemRemaining = 2,
    }),
    {
        MAGMA_TOTEM = true,
    }
)

ExpectForecastPresence(
    "damage totems are absent from forecast outside their range",
    State(Profile(), {
        mode = "aoe",
        targetDistance = 8.01,
        fireTotemStateAvailable = true,
    }),
    {
        FIRE_NOVA_TOTEM = false,
        MAGMA_TOTEM = false,
    }
)

ExpectForecastPresence(
    "burst forecast includes the checked single-target damage totem",
    State(Profile({ singleOutputMode = "burst" }), {
        fireTotemStateAvailable = true,
    }),
    {
        SEARING_TOTEM = true,
        FIRE_NOVA_TOTEM = false,
        MAGMA_TOTEM = false,
    }
)

ExpectForecastPresence(
    "disabled Searing Totem is absent from the burst forecast",
    State(Profile({
        singleOutputMode = "burst",
        enableSearingTotem = false,
    }), {
        fireTotemStateAvailable = true,
    }),
    {
        SEARING_TOTEM = false,
    }
)

ExpectForecastPresence(
    "disabled Magma Totem is absent from the AoE forecast",
    State(Profile({ enableMagmaTotem = false }), {
        mode = "aoe",
        fireTotemStateAvailable = true,
        fireTotemActive = true,
        fireTotemKind = "nova",
        fireTotemRemaining = 2,
    }),
    {
        FIRE_NOVA_TOTEM = false,
        MAGMA_TOTEM = false,
    }
)

ExpectForecastPresence(
    "enabled combo appears in forecast",
    State(Profile(), {
        flameShock = true,
        flameShockRemaining = 8,
    }),
    {
        FLAME_SHOCK = true,
        LAVA_BURST = true,
    }
)

ExpectForecastPresence(
    "disabled combo is absent from forecast",
    State(Profile({ enableFSLB = false }), {
        flameShock = true,
        flameShockRemaining = 8,
    }),
    {
        FLAME_SHOCK = false,
        LAVA_BURST = false,
    }
)

ExpectForecastPresence(
    "single Chain Lightning toggle filters forecast",
    State(Profile({
        enableFSLB = false,
        enableCL = false,
    })),
    {
        CHAIN_LIGHTNING = false,
    }
)

ExpectForecastPresence(
    "single Chain Lightning remains when enabled",
    State(Profile({ enableFSLB = false })),
    {
        CHAIN_LIGHTNING = true,
    }
)

ExpectForecastPresence(
    "AoE Chain Lightning toggle filters forecast",
    State(Profile({ enableCLAoE = false }), {
        mode = "aoe",
    }),
    {
        CHAIN_LIGHTNING = false,
    }
)

ExpectForecastPresence(
    "AoE Chain Lightning remains when enabled",
    State(Profile(), {
        mode = "aoe",
    }),
    {
        CHAIN_LIGHTNING = true,
    }
)

ExpectForecastPresence(
    "AoE Earthquake toggle filters the burst forecast",
    State(Profile({
        aoeOutputMode = "burst",
        enableQuakeAoE = false,
    }), {
        mode = "aoe",
    }),
    {
        EARTHQUAKE = false,
    }
)

ExpectRecommendation(
    "burst mode single ignores Clearcasting and setup spells",
    "CHAIN_LIGHTNING",
    State(Profile({ singleOutputMode = "burst" }), {
        clearcasting = 0,
    })
)

local pvpInsigniaCases = {
    {
        name = "Elemental single burst",
        mode = "single",
        db = Profile({ singleOutputMode = "burst" }),
        slot = 13,
    },
    {
        name = "Elemental AoE burst",
        mode = "aoe",
        db = Profile({ aoeOutputMode = "burst" }),
        slot = 14,
    },
    {
        name = "Elemental close PvP",
        mode = "elemental_pvp_close",
        db = Profile(),
        slot = 13,
    },
    {
        name = "Enhancement melee PvP",
        mode = "enhance_pvp_melee",
        db = Profile(),
        slot = 13,
    },
    {
        name = "Enhancement ranged PvP",
        mode = "enhance_pvp_ranged",
        db = Profile(),
        slot = 14,
    },
}
local pvpInsigniaIndex = 1
while pvpInsigniaIndex <= table.getn(pvpInsigniaCases) do
    local case = pvpInsigniaCases[pvpInsigniaIndex]
    ExpectRecommendation(
        case.name .. " uses a ready Horde insignia before target/range checks",
        "HORDE_INSIGNIA",
        State(case.db, {
            mode = case.mode,
            targetValid = false,
            inRange = false,
            meleeInRange = false,
            controlLost = true,
            hordeInsigniaSlot = case.slot,
        })
    )
    assert(
        P._rec.inventorySlot == case.slot,
        case.name .. " must retain the equipped insignia slot"
    )
    pvpInsigniaIndex = pvpInsigniaIndex + 1
end

local insigniaRecommendation, insigniaForecast = P:Evaluate(
    State(Profile({ singleOutputMode = "burst" }), {
        controlLost = true,
        hordeInsigniaSlot = 13,
    })
)
assert(
    insigniaRecommendation.key == "HORDE_INSIGNIA"
        and insigniaForecast[1]
        and insigniaForecast[1].key == "CHAIN_LIGHTNING"
        and insigniaForecast[1].eta == 0,
    "off-GCD Horde insignia should not delay the next PvP damage forecast"
)
passed = passed + 1

ExpectRecommendation(
    "normal rotation never uses the Horde insignia",
    "WAIT",
    State(Profile(), {
        targetValid = false,
        inRange = false,
        controlLost = true,
        hordeInsigniaSlot = 13,
    })
)

ExpectRecommendation(
    "burst mode skips the Horde insignia while in full control",
    "CHAIN_LIGHTNING",
    State(Profile({ singleOutputMode = "burst" }), {
        controlLost = false,
        hordeInsigniaSlot = 13,
    })
)

ExpectRecommendation(
    "burst mode keeps its damage priority when no insignia is ready",
    "CHAIN_LIGHTNING",
    State(Profile({ singleOutputMode = "burst" }), {
        controlLost = true,
        hordeInsigniaSlot = nil,
    })
)

local burstSingleFallback = State(Profile({ singleOutputMode = "burst" }))
burstSingleFallback.cooldowns.CHAIN_LIGHTNING.remaining = 3
ExpectRecommendation(
    "burst mode single falls back to Lightning Bolt",
    "LIGHTNING_BOLT",
    burstSingleFallback
)

ExpectRecommendation(
    "burst mode AoE starts with Earthquake without Clearcasting",
    "EARTHQUAKE",
    State(Profile({ aoeOutputMode = "burst" }), {
        mode = "aoe",
        clearcasting = 0,
    })
)

local burstAoEChain = State(Profile({ aoeOutputMode = "burst" }), {
    mode = "aoe",
})
burstAoEChain.cooldowns.EARTHQUAKE.remaining = 4
ExpectRecommendation(
    "burst mode AoE falls back from Earthquake to Chain Lightning",
    "CHAIN_LIGHTNING",
    burstAoEChain
)

ExpectRecommendation(
    "unchecked Earthquake does not participate in burst AoE",
    "CHAIN_LIGHTNING",
    State(Profile({
        aoeOutputMode = "burst",
        enableQuakeAoE = false,
    }), {
        mode = "aoe",
    })
)

local burstAoEWithoutChain = State(Profile({
    aoeOutputMode = "burst",
    enableCLAoE = false,
}), {
    mode = "aoe",
})
burstAoEWithoutChain.cooldowns.EARTHQUAKE.remaining = 4
ExpectRecommendation(
    "unchecked Chain Lightning does not participate in burst AoE",
    "LIGHTNING_BOLT",
    burstAoEWithoutChain
)

ExpectRecommendation(
    "burst AoE includes checked damage totems before Lightning Bolt",
    "FIRE_NOVA_TOTEM",
    State(Profile({
        aoeOutputMode = "burst",
        enableQuakeAoE = false,
        enableCLAoE = false,
    }), {
        mode = "aoe",
        fireTotemStateAvailable = true,
    })
)

local burstAoEBolt = State(Profile({ aoeOutputMode = "burst" }), {
    mode = "aoe",
})
burstAoEBolt.cooldowns.EARTHQUAKE.remaining = 4
burstAoEBolt.cooldowns.CHAIN_LIGHTNING.remaining = 4
ExpectRecommendation(
    "burst mode AoE falls back from Chain Lightning to Lightning Bolt",
    "LIGHTNING_BOLT",
    burstAoEBolt
)

local burstForecastState = State(Profile({ singleOutputMode = "burst" }))
burstForecastState.cooldowns.CHAIN_LIGHTNING.remaining = 3
local burstRecommendation, burstForecast = P:Evaluate(burstForecastState)
assert(
    burstRecommendation.key == "LIGHTNING_BOLT",
    "burst mode should fill a Chain Lightning cooldown with Lightning Bolt"
)
local burstChainForecast
local burstIndex = 1
while burstIndex <= 3 do
    if burstForecast[burstIndex]
        and burstForecast[burstIndex].key == "CHAIN_LIGHTNING" then
        burstChainForecast = burstForecast[burstIndex]
        break
    end
    burstIndex = burstIndex + 1
end
assert(
    burstChainForecast and burstChainForecast.uncertain == false,
    "burst forecast must not wait on Clearcasting"
)
assert(
    not Contains(burstForecast, "FLAME_SHOCK")
        and not Contains(burstForecast, "LAVA_BURST"),
    "burst forecast must exclude Flame Shock and Lava Burst setup"
)
passed = passed + 1

local burstAoEForecastState = State(Profile({ aoeOutputMode = "burst" }), {
    mode = "aoe",
})
burstAoEForecastState.cooldowns.EARTHQUAKE.remaining = 1
local burstAoERecommendation, burstAoEForecast = P:Evaluate(
    burstAoEForecastState
)
assert(
    burstAoERecommendation.key == "CHAIN_LIGHTNING"
        and burstAoEForecast[1]
        and burstAoEForecast[1].key == "EARTHQUAKE"
        and burstAoEForecast[2]
        and burstAoEForecast[2].key == "LIGHTNING_BOLT",
    "burst AoE forecast must retain Earthquake, Chain Lightning, and Lightning Bolt order"
)
passed = passed + 1

local inventoryLinks = {
    [13] = "|cff0070dd|Hitem:18845:0:0:0|h[Insignia of the Horde]|h|r",
    [14] = "|cff1eff00|Hitem:12345:0:0:0|h[Other Trinket]|h|r",
}
local inventoryCooldowns = {
    [13] = { 0, 0, 1 },
    [14] = { 0, 0, 1 },
}
local inventoryLocked = {}
function GetInventoryItemLink(_, slot)
    return inventoryLinks[slot]
end
function GetInventoryItemCooldown(_, slot)
    local cooldown = inventoryCooldowns[slot]
    return cooldown[1], cooldown[2], cooldown[3]
end
function IsInventoryItemLocked(slot)
    return inventoryLocked[slot] and true or false
end

assert(
    P:GetReadyHordeInsigniaSlot(100) == 13,
    "equipped ready Horde insignia should resolve to slot 13"
)
inventoryCooldowns[13] = { 95, 10, 1 }
assert(
    P:GetReadyHordeInsigniaSlot(100) == nil,
    "Horde insignia on cooldown must not be selected"
)
inventoryCooldowns[13] = { 0, 0, 1 }
inventoryLocked[13] = true
assert(
    P:GetReadyHordeInsigniaSlot(100) == nil,
    "locked Horde insignia must not be selected"
)
inventoryLocked[13] = nil
inventoryLinks[13] = nil
inventoryLinks[14] =
    "|cff0070dd|Hitem:18834:0:0:0|h[Insignia of the Horde]|h|r"
assert(
    P:GetReadyHordeInsigniaSlot(100) == 14,
    "another class variant of the Horde insignia should be recognized"
)
passed = passed + 1

local onTaxi = false
local deadOrGhost = false
local hasFullControl = false
function UnitOnTaxi() return onTaxi and 1 or nil end
function UnitIsDeadOrGhost() return deadOrGhost and 1 or nil end
function HasFullControl() return hasFullControl and 1 or nil end

assert(P:IsControlLost(), "HasFullControl false should report control loss")
hasFullControl = true
assert(not P:IsControlLost(), "HasFullControl true should report full control")
hasFullControl = false
onTaxi = true
assert(not P:IsControlLost(), "taxi travel must not trigger the PvP insignia")
onTaxi = false
deadOrGhost = true
assert(not P:IsControlLost(), "death must not trigger the PvP insignia")
deadOrGhost = false
passed = passed + 1

D.profileDB = Profile({ singleOutputMode = "burst" })
local builtState = { now = 100 }
P:BuildState(builtState)
assert(
    builtState.controlLost and builtState.hordeInsigniaSlot == 14,
    "burst state should preserve the ready-insignia behavior while control is lost"
)
passed = passed + 1

D.profileDB = Profile()
local builtElementalCloseState = {
    now = 100,
    mode = "elemental_pvp_close",
    targetValid = true,
    targetDistance = 8,
}
P:BuildState(builtElementalCloseState)
assert(
    builtElementalCloseState.controlLost
        and builtElementalCloseState.hordeInsigniaSlot == 14
        and builtElementalCloseState.closeInRange,
    "Elemental close PvP should always build insignia and eight-yard range state"
)
passed = passed + 1

D.profileDB = Profile()
local builtEnhanceState = {
    now = 100,
    mode = "enhance_pvp_melee",
    targetValid = true,
}
P:BuildState(builtEnhanceState)
assert(
    builtEnhanceState.controlLost
        and builtEnhanceState.hordeInsigniaSlot == 14
        and builtEnhanceState.meleeInRange,
    "Enhancement PvP should always build trinket and melee-range state without the Elemental PvP toggle"
)
passed = passed + 1

HasFullControl = nil
P:OnEvent("PLAYER_CONTROL_LOST")
assert(P:IsControlLost(), "control-loss event should support clients without HasFullControl")
P:OnEvent("PLAYER_CONTROL_GAINED")
assert(not P:IsControlLost(), "control-gained event should clear the fallback state")
passed = passed + 1

local executeState = State(Profile({ singleOutputMode = "burst" }), {
    targetValid = false,
    inRange = false,
    controlLost = true,
    hordeInsigniaSlot = 13,
})
D.profileDB = executeState.profileDB
function D:SetMode() return true end
function D:BuildState() return executeState end
function D:Update() end
local usedInventorySlot
function UseInventoryItem(slot) usedInventorySlot = slot end
local targetNearestCalls = 0
function TargetNearestEnemy()
    targetNearestCalls = targetNearestCalls + 1
end
function CastSpellByName()
    error("damage spell must not be cast before the Horde insignia")
end

local executeInsigniaIndex = 1
while executeInsigniaIndex <= table.getn(pvpInsigniaCases) do
    local case = pvpInsigniaCases[executeInsigniaIndex]
    executeState.mode = case.mode
    executeState.profileDB = case.db
    executeState.hordeInsigniaSlot = case.slot
    D.profileDB = case.db
    usedInventorySlot = nil
    targetNearestCalls = 0

    assert(
        P:Execute(case.mode),
        case.name .. " Horde insignia execution should succeed"
    )
    assert(
        usedInventorySlot == case.slot,
        case.name .. " must use the recommended equipment slot"
    )
    assert(
        targetNearestCalls == 0,
        case.name .. " must break control before automatic target selection"
    )
    passed = passed + 1
    executeInsigniaIndex = executeInsigniaIndex + 1
end

local targetPresent = false
local castSpellName
function UnitExists(unit)
    return unit == "target" and targetPresent and 1 or nil
end
function UnitIsDead() return nil end
function UnitCanAttack(_, unit)
    return unit == "target" and targetPresent and 1 or nil
end
function TargetNearestEnemy()
    targetNearestCalls = targetNearestCalls + 1
    targetPresent = true
end
function CastSpellByName(name)
    castSpellName = name
end
function D:PrepareExecutionTarget()
    if targetPresent then
        return false, "current"
    end
    TargetNearestEnemy()
    return targetPresent and true or false,
        targetPresent and "nearest" or "none"
end

local autoPvEDB = Profile({ enableFSLB = false })
local autoPvENoTarget = State(autoPvEDB, {
    targetValid = false,
    inRange = false,
})
local autoPvETarget = State(autoPvEDB)
D.profileDB = autoPvEDB
function D:BuildState()
    return targetPresent and autoPvETarget or autoPvENoTarget
end
targetPresent = false
targetNearestCalls = 0
castSpellName = nil
assert(P:Execute("single"),
    "PvE execution should acquire a target and cast on the same key press")
assert(targetNearestCalls == 1 and castSpellName == "LIGHTNING_BOLT",
    "PvE automatic targeting should select only once and continue the rotation")
passed = passed + 1

local autoPvPDB = Profile({ singleOutputMode = "burst" })
local autoPvPNoTarget = State(autoPvPDB, {
    targetValid = false,
    inRange = false,
})
local autoPvPTarget = State(autoPvPDB, {
    fireTotemStateAvailable = true,
})
D.profileDB = autoPvPDB
function D:BuildState()
    return targetPresent and autoPvPTarget or autoPvPNoTarget
end
targetPresent = false
targetNearestCalls = 0
castSpellName = nil
assert(P:Execute("single"),
    "PvP execution should acquire a target and cast on the same key press")
assert(targetNearestCalls == 1 and castSpellName == "CHAIN_LIGHTNING",
    "PvP automatic targeting must retain the unchanged damage priority")
passed = passed + 1

local autoElementalCloseDB = Profile()
local autoElementalCloseNoTarget = State(autoElementalCloseDB, {
    mode = "elemental_pvp_close",
    targetValid = false,
    inRange = false,
    closeInRange = false,
})
local autoElementalCloseTarget = State(autoElementalCloseDB, {
    mode = "elemental_pvp_close",
    closeInRange = true,
})
D.profileDB = autoElementalCloseDB
function D:BuildState()
    return targetPresent and autoElementalCloseTarget
        or autoElementalCloseNoTarget
end
targetPresent = false
targetNearestCalls = 0
castSpellName = nil
assert(P:Execute("elemental_pvp_close"),
    "Elemental close PvP should acquire a target and cast on the same key press")
assert(targetNearestCalls == 1 and castSpellName == "ELEMENTAL_MASTERY",
    "Elemental close PvP automatic targeting should continue into Elemental Mastery")
passed = passed + 1

local autoEnhanceDB = Profile()
local autoEnhanceNoTarget = State(autoEnhanceDB, {
    mode = "enhance_pvp_melee",
    targetValid = false,
    inRange = false,
    meleeInRange = false,
})
local autoEnhanceTarget = State(autoEnhanceDB, {
    mode = "enhance_pvp_melee",
})
D.profileDB = autoEnhanceDB
function D:BuildState()
    return targetPresent and autoEnhanceTarget or autoEnhanceNoTarget
end
targetPresent = false
targetNearestCalls = 0
castSpellName = nil
assert(P:Execute("enhance_pvp_melee"),
    "Enhancement PvP should acquire a target and cast on the same key press")
assert(targetNearestCalls == 1 and castSpellName == "STORMSTRIKE",
    "Enhancement PvP automatic targeting should continue into its melee priority")
passed = passed + 1

local legacyDisabledTargetDB = Profile({
    enableFSLB = false,
    enableAutoTarget = false,
})
local legacyDisabledNoTarget = State(legacyDisabledTargetDB, {
    targetValid = false,
    inRange = false,
})
local legacyDisabledTarget = State(legacyDisabledTargetDB)
D.profileDB = legacyDisabledTargetDB
function D:BuildState()
    return targetPresent and legacyDisabledTarget or legacyDisabledNoTarget
end
targetPresent = false
targetNearestCalls = 0
castSpellName = nil
assert(P:Execute("single"),
    "a stale saved false value must not disable fixed automatic targeting")
assert(targetNearestCalls == 1 and castSpellName == "LIGHTNING_BOLT",
    "fixed automatic targeting should ignore the removed configuration field")
passed = passed + 1

print("ShamanElemental_spec: " .. passed .. " checks passed")
