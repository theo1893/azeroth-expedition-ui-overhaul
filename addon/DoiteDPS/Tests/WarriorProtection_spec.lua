-- Standalone logic checks for the shield Protection Warrior profile.
-- Run from the AddOns directory with:
-- lua DoiteDPS/Tests/WarriorProtection_spec.lua

if not table.getn then
    table.getn = function(value) return #value end
end

local now = 100
function GetTime() return now end
function GetLocale() return "zhCN" end

local costs = {
    DEFENSIVE_STANCE = 0,
    CONCUSSION_BLOW = 15,
    SHIELD_SLAM = 20,
    REVENGE = 5,
    THUNDER_CLAP = 20,
    DEMORALIZING_SHOUT = 10,
    SUNDER_ARMOR = 10,
    SHIELD_BLOCK = 10,
    HEROIC_STRIKE = 15,
    CLEAVE = 20,
}

DoiteDPS = {
    Profiles = {},
    WarriorProtectionCooldownKeys = {},
    WarriorCooldownKeys = {},
    Recommendation = {},
    Forecasts = {},
    Spells = {},
    Names = {},
    Text = {
        WAIT_TARGET = "wait target",
        OUT_OF_RANGE = "out of range",
        WAIT_GCD = "wait gcd",
    },
    DB = {},
    State = {},
    GCD_MAX = 1.6,
    FORECAST_LIMIT = 3,
}

local D = DoiteDPS
local profileDB = {}
local rotationDB = {}

for key, cost in pairs(costs) do
    D.Spells[key] = {
        name = key,
        cost = cost,
        texture = key,
        spellId = 1000,
    }
    D.Names[key] = key
end
D.Spells.CONCUSSION_BLOW.spellId = 12809
D.Spells.SHIELD_SLAM.spellId = 23922
D.Spells.REVENGE.spellId = 11601
D.Spells.THUNDER_CLAP.spellId = 11580
D.Spells.SHIELD_BLOCK.spellId = 2565
D.Names.AUTO_ATTACK = "AUTO_ATTACK"
D.Names.WAIT = "WAIT"

function D:IsKnown(key)
    return costs[key] ~= nil
        or key == "AUTO_ATTACK"
        or key == "WAIT"
end
function D:GetSpellDef(key) return self.Spells[key] end
function D:GetName(key) return self.Names[key] or key end
function D:GetTexture(key) return key end
function D:GetRealCooldown() return 0, 0 end
function D:GetProfileDB() return profileDB end
function D:GetRotationDB(profileKey, mode, defaults)
    rotationDB[mode] = rotationDB[mode] or {}
    for key, value in pairs(defaults) do
        if rotationDB[mode][key] == nil then
            rotationDB[mode][key] = value
        end
    end
    return rotationDB[mode]
end
function D:GetRage() return 50 end
function D:GetPlayerHealthPercent() return 100 end
function D:GetStance() return 2 end
function D:GetReactiveState() return false, nil end
function D:GetPlayerBuffState() return false, nil end
function D:HasTargetDebuff() return false end
function D:GetTargetDebuffStacks() return 0 end
function D:GetTargetDebuffRemaining() return nil end
function D:GetSwingState(reuse) return reuse end
function D:IsMeleeRange() return true end
function D:Print() end

local markedOnSwing = nil
function D:MarkOnSwingQueued(key, swing)
    markedOnSwing = key
    if swing then
        swing.hsQueued = key == "HEROIC_STRIKE"
        swing.cleaveQueued = key == "CLEAVE"
    end
    return true
end

function GetTalentInfo() return nil end

dofile("DoiteDPS/Profiles/WarriorProtection.lua")
local P = D.Profiles.WarriorProtection

local cooldownKeys = {
    "CONCUSSION_BLOW",
    "SHIELD_SLAM",
    "REVENGE",
    "THUNDER_CLAP",
    "DEMORALIZING_SHOUT",
    "SUNDER_ARMOR",
    "SHIELD_BLOCK",
    "HEROIC_STRIKE",
    "CLEAVE",
}

local function State(changes)
    local state = {
        now = now,
        targetValid = true,
        targetHP = 100,
        inMelee = true,
        inCombat = true,
        mode = "single",
        rage = 50,
        playerHP = 100,
        stance = 2,
        gcd = 0,
        hasShield = true,
        targetingPlayer = true,
        improvedShieldSlamRank = 2,
        improvedRevengeRank = 3,
        revengeActive = false,
        revengeRemaining = nil,
        shieldBlockBuff = false,
        shieldBlockRemaining = nil,
        improvedShieldSlamBuff = false,
        demoralizingShout = true,
        sunderStacks = 0,
        sunderRemaining = nil,
        cooldowns = {},
        swing = {
            active = true,
            remaining = 1.2,
            speed = 2.6,
            hsQueued = false,
            cleaveQueued = false,
        },
    }
    local index = 1
    while index <= #cooldownKeys do
        state.cooldowns[cooldownKeys[index]] = {
            remaining = 0,
            duration = 0,
        }
        index = index + 1
    end
    for key, value in pairs(changes or {}) do
        if key == "cd" then
            for spellKey, remaining in pairs(value) do
                state.cooldowns[spellKey] = {
                    remaining = remaining,
                    duration = 0,
                }
            end
        elseif key == "rotation" then
            state.rotationDB = value
        else
            state[key] = value
        end
    end
    return state
end

local passed = 0

assert(
    P.ModeLabels.single == "防战"
        and P.ModeLabels.aoe == "防战",
    "Protection single/AoE labels should both use the specialization name"
)
passed = passed + 1

local function ExpectLua50Upvalues(name, callback)
    local upvalues = 0
    local environmentUpvalues = 0
    while debug and debug.getupvalue do
        local upvalueName = debug.getupvalue(callback, upvalues + 1)
        if not upvalueName then break end
        upvalues = upvalues + 1
        if upvalueName == "_ENV" then
            environmentUpvalues = environmentUpvalues + 1
        end
    end
    assert(
        (upvalues - environmentUpvalues) <= 32,
        name .. " exceeds the Lua 5.0 upvalue limit"
    )
    passed = passed + 1
end

local function Expect(name, expected, state)
    P:ResetRuntime()
    local actual = P:Recommend(state).key
    assert(
        actual == expected,
        name .. ": expected " .. expected .. ", got " .. tostring(actual)
    )
    passed = passed + 1
end

local function ForecastContains(state, currentKey, expectedKey)
    P:ResetRuntime()
    local forecast = P:BuildForecast(state, { key = currentKey })
    local index = 1
    while index <= #forecast do
        if forecast[index] and forecast[index].key == expectedKey then
            return true, forecast[index], forecast
        end
        index = index + 1
    end
    return false, nil, forecast
end

ExpectLua50Upvalues("Recommend", P.Recommend)
ExpectLua50Upvalues("BuildForecast", P.BuildForecast)
ExpectLua50Upvalues("Execute", P.Execute)

assert(
    P.RotationDefaults.single.sunderStrategy == "auto"
        and P.RotationDefaults.aoe.sunderStrategy == "auto"
        and P.RotationDefaults.aoe.useConcussionBlow == true,
    "Protection defaults must include automatic Sunder and AoE Concussion Blow"
)
local sunderOption = nil
local shieldBlockOption = nil
local shieldBlockRageOption = nil
local optionIndex = 1
while optionIndex <= #P.ConfigSchema.options do
    local option = P.ConfigSchema.options[optionIndex]
    if option.key == "sunderStrategy" then
        sunderOption = option
    elseif option.key == "shieldBlockStrategy" then
        shieldBlockOption = option
    elseif option.key == "shieldBlockRage" then
        shieldBlockRageOption = option
    end
    optionIndex = optionIndex + 1
end
assert(
    sunderOption
        and sunderOption.type == "choice"
        and sunderOption.values[1].value == "auto"
        and sunderOption.values[2].value == "manual",
    "Protection Sunder must offer automatic and manual-only policies"
)
assert(
    shieldBlockOption
        and shieldBlockOption.type == "choice"
        and shieldBlockOption.values[1].value == "off"
        and shieldBlockOption.values[2].value == "revenge"
        and shieldBlockOption.values[3].value == "mitigation"
        and shieldBlockRageOption
        and shieldBlockRageOption.visibleWhen.notValue == "off",
    "Protection Shield Block must offer off, Revenge-primer, and active-mitigation policies"
)
passed = passed + 3

rotationDB.aoe = { useConcussionBlow = false }
profileDB.protectionDefaultsVersion = nil
local migratedAoE = P:GetRotationDB("aoe")
assert(
    migratedAoE.useConcussionBlow == true
        and profileDB.protectionDefaultsVersion == 1,
    "legacy Protection AoE must migrate Concussion Blow on"
)
passed = passed + 1

Expect(
    "invalid target disables the rotation",
    "WAIT",
    State({ targetValid = false })
)
Expect(
    "missing shield disables the rotation",
    "WAIT",
    State({ hasShield = false })
)
Expect(
    "off-stance tank returns to Defensive Stance",
    "DEFENSIVE_STANCE",
    State({ stance = 1 })
)
Expect(
    "an expiring Revenge window overrides the normal opener",
    "REVENGE",
    State({ revengeActive = true, revengeRemaining = 1 })
)
Expect(
    "single threat opens with Concussion Blow",
    "CONCUSSION_BLOW",
    State({ revengeActive = true, revengeRemaining = 4 })
)
Expect(
    "single threat follows with Shield Slam",
    "SHIELD_SLAM",
    State({
        revengeActive = true,
        revengeRemaining = 4,
        cd = { CONCUSSION_BLOW = 30 },
    })
)
Expect(
    "single threat follows Shield Slam with Revenge",
    "REVENGE",
    State({
        revengeActive = true,
        revengeRemaining = 4,
        cd = { CONCUSSION_BLOW = 30, SHIELD_SLAM = 4 },
    })
)
Expect(
    "single high rage queues Heroic Strike after core reserve",
    "HEROIC_STRIKE",
    State({
        rage = 80,
        cd = {
            CONCUSSION_BLOW = 30,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "single core gap uses automatic Sunder",
    "SUNDER_ARMOR",
    State({
        rage = 20,
        sunderStacks = 4,
        cd = {
            CONCUSSION_BLOW = 30,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "single Sunder yields to imminent Concussion Blow",
    "AUTO_ATTACK",
    State({
        rage = 20,
        sunderStacks = 4,
        cd = {
            CONCUSSION_BLOW = 1.0,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "single Sunder yields to imminent Shield Slam",
    "AUTO_ATTACK",
    State({
        rage = 20,
        sunderStacks = 4,
        cd = {
            CONCUSSION_BLOW = 30,
            SHIELD_SLAM = 1.0,
            REVENGE = 4,
        },
    })
)
Expect(
    "single Sunder preserves rage for ready Concussion Blow",
    "AUTO_ATTACK",
    State({
        rage = 10,
        sunderStacks = 4,
        cd = {
            CONCUSSION_BLOW = 0,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "single Sunder may fill a gap longer than one GCD",
    "SUNDER_ARMOR",
    State({
        rage = 20,
        sunderStacks = 4,
        cd = {
            CONCUSSION_BLOW = 1.6,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "queued Sunder yields when core returns during its next GCD",
    "WAIT",
    State({
        rage = 20,
        gcd = 1.0,
        sunderStacks = 4,
        cd = {
            CONCUSSION_BLOW = 2.0,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "queued Sunder remains available beyond its full cast window",
    "SUNDER_ARMOR",
    State({
        rage = 20,
        gcd = 1.0,
        sunderStacks = 4,
        cd = {
            CONCUSSION_BLOW = 2.6,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "single automatic Sunder stops at five stacks",
    "AUTO_ATTACK",
    State({
        rage = 20,
        sunderStacks = 5,
        sunderRemaining = 20,
        cd = {
            CONCUSSION_BLOW = 30,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "single automatic Sunder refreshes five stacks below five seconds",
    "SUNDER_ARMOR",
    State({
        rage = 20,
        sunderStacks = 5,
        sunderRemaining = 4.9,
        cd = {
            CONCUSSION_BLOW = 30,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "manual-only Sunder stays out of the recommendation",
    "AUTO_ATTACK",
    State({
        rage = 20,
        rotation = { sunderStrategy = "manual" },
        cd = {
            CONCUSSION_BLOW = 30,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)

Expect(
    "AoE expiring Revenge still overrides Concussion Blow",
    "REVENGE",
    State({
        mode = "aoe",
        revengeActive = true,
        revengeRemaining = 1,
    })
)
Expect(
    "AoE Concussion Blow is the highest normal AoE priority",
    "CONCUSSION_BLOW",
    State({
        mode = "aoe",
        revengeActive = true,
        revengeRemaining = 4,
    })
)
Expect(
    "AoE applies initial Demoralizing Shout coverage",
    "DEMORALIZING_SHOUT",
    State({
        mode = "aoe",
        demoralizingShout = false,
        cd = { CONCUSSION_BLOW = 30, THUNDER_CLAP = 4 },
    })
)
Expect(
    "AoE follows unavailable Concussion Blow with Thunder Clap",
    "THUNDER_CLAP",
    State({ mode = "aoe", cd = { CONCUSSION_BLOW = 30 } })
)
Expect(
    "AoE can disable Concussion Blow after the default migration",
    "SHIELD_SLAM",
    State({
        mode = "aoe",
        rotation = { useConcussionBlow = false },
        cd = { THUNDER_CLAP = 4 },
    })
)
Expect(
    "AoE follows Concussion Blow with Shield Slam",
    "SHIELD_SLAM",
    State({
        mode = "aoe",
        cd = { THUNDER_CLAP = 4, CONCUSSION_BLOW = 30 },
    })
)
Expect(
    "AoE high rage queues Cleave after area-core reserve",
    "CLEAVE",
    State({
        mode = "aoe",
        rage = 80,
        cd = {
            THUNDER_CLAP = 4,
            CONCUSSION_BLOW = 30,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "AoE medium rage has an automatic Sunder outlet",
    "SUNDER_ARMOR",
    State({
        mode = "aoe",
        rage = 35,
        sunderStacks = 4,
        cd = {
            THUNDER_CLAP = 4,
            CONCUSSION_BLOW = 30,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "AoE Sunder yields to imminent Concussion Blow",
    "AUTO_ATTACK",
    State({
        mode = "aoe",
        rage = 35,
        sunderStacks = 4,
        cd = {
            THUNDER_CLAP = 4,
            CONCUSSION_BLOW = 1.0,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "AoE Sunder yields to imminent Shield Slam",
    "AUTO_ATTACK",
    State({
        mode = "aoe",
        rage = 35,
        sunderStacks = 4,
        cd = {
            THUNDER_CLAP = 4,
            CONCUSSION_BLOW = 30,
            SHIELD_SLAM = 1.0,
            REVENGE = 4,
        },
    })
)
Expect(
    "AoE automatic Sunder stops at five stacks",
    "AUTO_ATTACK",
    State({
        mode = "aoe",
        rage = 35,
        sunderStacks = 5,
        cd = {
            THUNDER_CLAP = 4,
            CONCUSSION_BLOW = 30,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)

Expect(
    "Shield Block does not enter the default pure-threat rotation",
    "SUNDER_ARMOR",
    State({
        rage = 40,
        cd = {
            CONCUSSION_BLOW = 30,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "optional Shield Block primes Revenge in a core gap",
    "SHIELD_BLOCK",
    State({
        rage = 40,
        rotation = {
            shieldBlockStrategy = "revenge",
            sunderStrategy = "auto",
        },
        cd = {
            CONCUSSION_BLOW = 30,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "Shield Block is not starved by an on-swing dump during the GCD",
    "SHIELD_BLOCK",
    State({
        rage = 80,
        gcd = 1.0,
        rotation = {
            shieldBlockStrategy = "revenge",
            sunderStrategy = "auto",
        },
        cd = {
            CONCUSSION_BLOW = 30,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)
Expect(
    "active mitigation Shield Block outranks normal AoE threat actions",
    "SHIELD_BLOCK",
    State({
        mode = "aoe",
        rage = 50,
        revengeActive = true,
        revengeRemaining = 4,
        rotation = {
            shieldBlockStrategy = "mitigation",
            shieldBlockRage = 40,
            sunderStrategy = "auto",
        },
    })
)
Expect(
    "expiring Revenge remains ahead of active mitigation Shield Block",
    "REVENGE",
    State({
        mode = "aoe",
        rage = 50,
        revengeActive = true,
        revengeRemaining = 1,
        rotation = {
            shieldBlockStrategy = "mitigation",
            shieldBlockRage = 40,
            sunderStrategy = "auto",
        },
    })
)

local mitigationDuringGCD = State({
    rage = 50,
    gcd = 1.0,
    revengeActive = true,
    revengeRemaining = 1,
    rotation = {
        shieldBlockStrategy = "mitigation",
        shieldBlockRage = 30,
        sunderStrategy = "auto",
    },
})
P:ResetRuntime()
local mitigationDuringGCDAction = P:Recommend(mitigationDuringGCD)
assert(
    mitigationDuringGCDAction.key == "SHIELD_BLOCK"
        and mitigationDuringGCDAction.state == "ready",
    "active mitigation Shield Block must remain immediately castable during the GCD"
)
passed = passed + 1

Expect(
    "active mitigation does not overwrite an existing Shield Block layer",
    "CONCUSSION_BLOW",
    State({
        rage = 50,
        shieldBlockBuff = true,
        rotation = {
            shieldBlockStrategy = "mitigation",
            shieldBlockRage = 30,
            sunderStrategy = "auto",
        },
    })
)
Expect(
    "active mitigation still respects its configured rage floor",
    "SUNDER_ARMOR",
    State({
        rage = 29,
        rotation = {
            shieldBlockStrategy = "mitigation",
            shieldBlockRage = 30,
            sunderStrategy = "auto",
        },
        cd = {
            CONCUSSION_BLOW = 30,
            SHIELD_SLAM = 4,
            REVENGE = 4,
        },
    })
)

local urgentForecastState = State({
    mode = "aoe",
    revengeActive = true,
    revengeRemaining = 1,
})
P:ResetRuntime()
local urgentForecast = P:BuildForecast(
    urgentForecastState,
    { key = "AUTO_ATTACK" }
)
assert(
    urgentForecast[1] and urgentForecast[1].key == "REVENGE",
    "expiring Revenge must lead the AoE Protection forecast"
)
passed = passed + 1

local normalAoEForecastState = State({
    mode = "aoe",
    revengeActive = true,
    revengeRemaining = 4,
})
P:ResetRuntime()
local normalAoEForecast = P:BuildForecast(
    normalAoEForecastState,
    { key = "AUTO_ATTACK" }
)
assert(
    normalAoEForecast[1]
        and normalAoEForecast[1].key == "CONCUSSION_BLOW",
    "Concussion Blow must lead the normal AoE Protection forecast"
)
passed = passed + 1

local disabledConcussionForecastState = State({
    mode = "aoe",
    rotation = { useConcussionBlow = false },
    cd = { THUNDER_CLAP = 4 },
})
local hasDisabledConcussion = ForecastContains(
    disabledConcussionForecastState,
    "AUTO_ATTACK",
    "CONCUSSION_BLOW"
)
assert(
    not hasDisabledConcussion,
    "disabled AoE Concussion Blow must stay out of the Protection forecast"
)
passed = passed + 1

local mitigationAfterRevengeState = State({
    rage = 50,
    revengeActive = true,
    revengeRemaining = 1,
    rotation = {
        shieldBlockStrategy = "mitigation",
        shieldBlockRage = 30,
        sunderStrategy = "auto",
    },
})
P:ResetRuntime()
local mitigationAfterRevengeForecast = P:BuildForecast(
    mitigationAfterRevengeState,
    { key = "REVENGE" }
)
assert(
    mitigationAfterRevengeForecast[1]
        and mitigationAfterRevengeForecast[1].key == "SHIELD_BLOCK"
        and mitigationAfterRevengeForecast[1].eta <= 0.15,
    "active mitigation Shield Block must immediately follow expiring Revenge"
)
passed = passed + 1

local afterMitigationShieldBlockState = State({
    rage = 50,
    rotation = {
        shieldBlockStrategy = "mitigation",
        shieldBlockRage = 30,
        sunderStrategy = "auto",
    },
})
P:ResetRuntime()
local afterMitigationShieldBlockForecast = P:BuildForecast(
    afterMitigationShieldBlockState,
    { key = "SHIELD_BLOCK" }
)
assert(
    afterMitigationShieldBlockForecast[1]
        and afterMitigationShieldBlockForecast[1].key == "CONCUSSION_BLOW"
        and afterMitigationShieldBlockForecast[1].eta <= 0.15,
    "a current off-GCD Shield Block must not delay the next threat action"
)
passed = passed + 1

local shieldBlockAfterShieldSlamState = State({
    rage = 50,
    rotation = {
        shieldBlockStrategy = "revenge",
        sunderStrategy = "manual",
    },
    cd = {
        CONCUSSION_BLOW = 30,
        REVENGE = 4,
    },
})
local hasShieldBlockAfterShieldSlam, shieldBlockAfterShieldSlam =
    ForecastContains(
        shieldBlockAfterShieldSlamState,
        "SHIELD_SLAM",
        "SHIELD_BLOCK"
    )
assert(
    hasShieldBlockAfterShieldSlam
        and shieldBlockAfterShieldSlam.uncertain == true
        and shieldBlockAfterShieldSlam.eta >= 1.5,
    "Shield Block must remain as a conditional forecast after Shield Slam"
)
passed = passed + 1

local shieldBlockCooldownState = State({
    rage = 40,
    rotation = {
        shieldBlockStrategy = "revenge",
        sunderStrategy = "manual",
    },
    cd = {
        CONCUSSION_BLOW = 30,
        SHIELD_SLAM = 4,
        REVENGE = 4,
        SHIELD_BLOCK = 3,
    },
})
local hasCooldownShieldBlock, cooldownShieldBlock = ForecastContains(
    shieldBlockCooldownState,
    "AUTO_ATTACK",
    "SHIELD_BLOCK"
)
assert(
    hasCooldownShieldBlock
        and cooldownShieldBlock.uncertain == false
        and cooldownShieldBlock.eta >= 3,
    "Shield Block cooldown must delay rather than remove its forecast"
)
passed = passed + 1

local conditionalShieldBlockState = State({
    rage = 40,
    targetingPlayer = false,
    rotation = {
        shieldBlockStrategy = "revenge",
        sunderStrategy = "manual",
    },
    cd = {
        CONCUSSION_BLOW = 30,
        SHIELD_SLAM = 4,
        REVENGE = 4,
    },
})
local hasConditionalShieldBlock, conditionalShieldBlock = ForecastContains(
    conditionalShieldBlockState,
    "AUTO_ATTACK",
    "SHIELD_BLOCK"
)
assert(
    hasConditionalShieldBlock
        and conditionalShieldBlock.uncertain == true,
    "enabled Shield Block must remain visible while waiting for incoming aggro"
)
passed = passed + 1

local disabledShieldBlockForecastState = State({
    rage = 40,
    rotation = {
        shieldBlockStrategy = "off",
        sunderStrategy = "manual",
    },
    cd = {
        CONCUSSION_BLOW = 30,
        SHIELD_SLAM = 4,
        REVENGE = 4,
    },
})
local hasDisabledShieldBlock = ForecastContains(
    disabledShieldBlockForecastState,
    "AUTO_ATTACK",
    "SHIELD_BLOCK"
)
assert(
    not hasDisabledShieldBlock,
    "disabled Shield Block must stay out of the forecast"
)
passed = passed + 1

local manualForecastState = State({
    rotation = { sunderStrategy = "manual" },
    cd = {
        CONCUSSION_BLOW = 30,
        SHIELD_SLAM = 4,
        REVENGE = 4,
    },
})
local hasManualSunder = ForecastContains(
    manualForecastState,
    "AUTO_ATTACK",
    "SUNDER_ARMOR"
)
assert(
    not hasManualSunder,
    "manual-only Sunder must stay out of the Protection forecast"
)
passed = passed + 1

local function SunderOnlyState(mode, stacks, remaining)
    return State({
        mode = mode,
        rage = 50,
        sunderStacks = stacks,
        sunderRemaining = remaining,
        rotation = {
            useConcussionBlow = false,
            useShieldSlam = false,
            useRevenge = false,
            useThunderClap = false,
            maintainDemoralizingShout = false,
            shieldBlockStrategy = "off",
            useHeroicStrike = false,
            useCleave = false,
            sunderStrategy = "auto",
        },
    })
end

local hasFullSingleSunder = ForecastContains(
    SunderOnlyState("single", 5),
    "AUTO_ATTACK",
    "SUNDER_ARMOR"
)
assert(
    not hasFullSingleSunder,
    "five-stack single target must not forecast another Sunder"
)
passed = passed + 1

local hasFullAoESunder = ForecastContains(
    SunderOnlyState("aoe", 5),
    "AUTO_ATTACK",
    "SUNDER_ARMOR"
)
assert(
    not hasFullAoESunder,
    "five-stack AoE target must not forecast another Sunder"
)
passed = passed + 1

local hasExpiringFullSunder = ForecastContains(
    SunderOnlyState("single", 5, 4.9),
    "AUTO_ATTACK",
    "SUNDER_ARMOR"
)
assert(
    hasExpiringFullSunder,
    "an expiring five-stack target must forecast one Sunder refresh"
)
passed = passed + 1

local hasRepeatedRefresh = ForecastContains(
    SunderOnlyState("single", 5, 4.9),
    "SUNDER_ARMOR",
    "SUNDER_ARMOR"
)
assert(
    not hasRepeatedRefresh,
    "a current five-stack refresh must not forecast another Sunder"
)
passed = passed + 1

local hasProjectedFullSunder = ForecastContains(
    SunderOnlyState("single", 4),
    "SUNDER_ARMOR",
    "SUNDER_ARMOR"
)
assert(
    not hasProjectedFullSunder,
    "a current fourth-to-fifth Sunder must not forecast a redundant sixth cast"
)
passed = passed + 1

local hasProjectedFourthSunder = ForecastContains(
    SunderOnlyState("single", 3),
    "SUNDER_ARMOR",
    "SUNDER_ARMOR"
)
assert(
    hasProjectedFourthSunder,
    "a current third-to-fourth Sunder may still forecast the fifth stack"
)
passed = passed + 1

local function AssertCoreForecastBeforeSunder(
    mode,
    coreKey,
    currentKey,
    remaining
)
    remaining = tonumber(remaining) or 1.0
    local state = State({
        mode = mode,
        rage = 50,
        sunderStacks = 4,
        rotation = {
            useConcussionBlow = coreKey == "CONCUSSION_BLOW",
            useShieldSlam = coreKey == "SHIELD_SLAM",
            useRevenge = false,
            useThunderClap = false,
            maintainDemoralizingShout = false,
            shieldBlockStrategy = "off",
            useHeroicStrike = false,
            useCleave = false,
            sunderStrategy = "auto",
        },
        cd = {
            [coreKey] = remaining,
        },
    })
    P:ResetRuntime()
    local forecast = P:BuildForecast(
        state,
        { key = currentKey or "AUTO_ATTACK" }
    )
    local coreIndex = nil
    local sunderIndex = nil
    local sunderEta = nil
    local index = 1
    while index <= table.getn(forecast) do
        if forecast[index].key == coreKey then
            coreIndex = index
        elseif forecast[index].key == "SUNDER_ARMOR" then
            sunderIndex = index
            sunderEta = tonumber(forecast[index].eta)
        end
        index = index + 1
    end
    assert(
        coreIndex and sunderIndex
            and coreIndex < sunderIndex
            and sunderEta
            and sunderEta >= (remaining + 1.5),
        mode .. " forecast must place " .. coreKey .. " before Sunder"
    )
    passed = passed + 1
end

AssertCoreForecastBeforeSunder("single", "CONCUSSION_BLOW")
AssertCoreForecastBeforeSunder("single", "SHIELD_SLAM")
AssertCoreForecastBeforeSunder("aoe", "CONCUSSION_BLOW")
AssertCoreForecastBeforeSunder("aoe", "SHIELD_SLAM")
AssertCoreForecastBeforeSunder(
    "aoe",
    "SHIELD_SLAM",
    "THUNDER_CLAP",
    2.0
)

local executedState = nil
local executedSpell = nil
local executedNoQueue = false
local prepareTargetCalls = 0
local preparedRequireMelee = nil
local preparedMeleeKey = nil
function D:SetMode(mode) self.DB.mode = mode end
function D:BuildState() return executedState end
function D:PrepareExecutionTarget(_, requireMelee, meleeKey)
    prepareTargetCalls = prepareTargetCalls + 1
    preparedRequireMelee = requireMelee
    preparedMeleeKey = meleeKey
    return false, "current"
end
function D:Update() end
function CastSpellByName(name)
    executedSpell = name
    executedNoQueue = false
end
function CastSpellByNameNoQueue(name)
    executedSpell = name
    executedNoQueue = true
end

executedState = State({
    meleeRangeKey = "SHIELD_SLAM",
    cd = { CONCUSSION_BLOW = 30 },
})
P:ResetRuntime()
executedSpell = nil
local executeResult = P:Execute("single")
assert(
    executeResult == true
        and executedSpell == "SHIELD_SLAM"
        and prepareTargetCalls == 1
        and preparedRequireMelee == true
        and preparedMeleeKey == "SHIELD_SLAM",
    "single macro must cast its displayed Shield Slam"
)
passed = passed + 1

executedState = State({
    rage = 80,
    gcd = 1.0,
    rotation = {
        shieldBlockStrategy = "revenge",
        sunderStrategy = "auto",
    },
    cd = {
        CONCUSSION_BLOW = 30,
        SHIELD_SLAM = 4,
        REVENGE = 4,
    },
})
P:ResetRuntime()
executedSpell = nil
executedNoQueue = false
executeResult = P:Execute("single")
assert(
    executeResult == true
        and executedSpell == "SHIELD_BLOCK"
        and executedNoQueue == true,
    "automatic Shield Block must bypass the generic spell queue"
)
passed = passed + 1

executedState = State({
    rage = 20,
    sunderStacks = 4,
    cd = {
        CONCUSSION_BLOW = 30,
        SHIELD_SLAM = 4,
        REVENGE = 4,
    },
})
P:ResetRuntime()
executedSpell = nil
executeResult = P:Execute("single")
assert(
    executeResult == true and executedSpell == "SUNDER_ARMOR",
    "automatic Sunder must still cast below five stacks"
)
executedSpell = nil
executeResult = P:Execute("single")
assert(
    executeResult == false and executedSpell == nil,
    "a pending Sunder must block duplicate queue attempts while stacks update"
)
passed = passed + 2

executedState = State({
    rage = 20,
    sunderStacks = 4,
    cd = {
        CONCUSSION_BLOW = 1.0,
        SHIELD_SLAM = 4,
        REVENGE = 4,
    },
})
P:ResetRuntime()
executedSpell = nil
executeResult = P:Execute("single")
assert(
    executeResult == false and executedSpell == nil,
    "the macro must not cast Sunder before an imminent core skill"
)
passed = passed + 1

executedState = State({
    rage = 20,
    gcd = 1.0,
    sunderStacks = 4,
    cd = {
        CONCUSSION_BLOW = 2.0,
        SHIELD_SLAM = 4,
        REVENGE = 4,
    },
})
P:ResetRuntime()
executedSpell = nil
executeResult = P:Execute("single")
assert(
    executeResult == false and executedSpell == nil,
    "the macro must not queue Sunder when core returns during its GCD"
)
passed = passed + 1

executedState = State({
    rage = 20,
    sunderStacks = 5,
    cd = {
        CONCUSSION_BLOW = 30,
        SHIELD_SLAM = 4,
        REVENGE = 4,
    },
})
P:ResetRuntime()
executedSpell = nil
executeResult = P:Execute("single")
assert(
    executeResult == false and executedSpell == nil,
    "the Protection macro must not cast Sunder on a five-stack target"
)
passed = passed + 1

executedState = State({
    mode = "aoe",
    rage = 80,
    cd = {
        THUNDER_CLAP = 4,
        CONCUSSION_BLOW = 30,
        SHIELD_SLAM = 4,
        REVENGE = 4,
    },
})
P:ResetRuntime()
markedOnSwing = nil
executedSpell = nil
executeResult = P:Execute("aoe")
assert(
    executeResult == true
        and executedSpell == "CLEAVE"
        and markedOnSwing == "CLEAVE",
    "AoE macro must cast and latch its displayed Cleave"
)
passed = passed + 1

print("WarriorProtection_spec: " .. passed .. " checks passed")
