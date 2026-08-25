-- Standalone checks for opt-in tank soft-follow targeting and macro migration.
-- Run from the AddOns directory with:
-- lua DoiteDPS/Tests/TankAssist_spec.lua

if not table.getn then
    table.getn = function(value) return #value end
end

function GetLocale() return "zhCN" end
local now = 100
function GetTime() return now end

local units = {}
local player = {
    name = "Player",
    guid = "PLAYER",
    exists = true,
    player = true,
    friendly = true,
    connected = true,
}
local tank = {
    name = "MainTank",
    guid = "TANK",
    exists = true,
    player = true,
    friendly = true,
    connected = true,
}
local enemyA = {
    name = "EnemyA",
    guid = "ENEMY_A",
    exists = true,
    attackable = true,
    combat = true,
    health = 80,
    healthMax = 100,
}
local enemyB = {
    name = "EnemyB",
    guid = "ENEMY_B",
    exists = true,
    attackable = true,
    combat = true,
    health = 70,
    healthMax = 100,
}
local enemyC = {
    name = "EnemyC",
    guid = "ENEMY_C",
    exists = true,
    attackable = true,
    combat = true,
    health = 60,
    healthMax = 100,
}
local nearest = {
    name = "Nearest",
    guid = "NEAREST",
    exists = true,
    attackable = true,
    combat = true,
    health = 90,
    healthMax = 100,
}
local allEntities = {
    player,
    tank,
    enemyA,
    enemyB,
    enemyC,
    nearest,
}
local targetCycle = nil
local targetCycleCalls = 0
local targetUnitCalls = 0
local lastTarget = nil

units.player = player
units.party1 = tank
units.party1target = enemyA
units.target = tank

function UnitExists(unit)
    local value = units[unit]
    return value and value.exists and true or nil, value and value.guid or nil
end
function GetUnitGUID(unit)
    local value = units[unit]
    return value and value.guid or nil
end
function UnitName(unit)
    local value = units[unit]
    return value and value.name or nil
end
function UnitIsPlayer(unit)
    local value = units[unit]
    return value and value.player and 1 or nil
end
function UnitIsFriend(_, unit)
    local value = units[unit]
    return value and value.friendly and 1 or nil
end
function UnitCanAttack(_, unit)
    local value = units[unit]
    return value and value.attackable and 1 or nil
end
function UnitIsDead(unit)
    local value = units[unit]
    return value and value.dead and 1 or nil
end
function UnitIsDeadOrGhost(unit) return UnitIsDead(unit) end
function UnitAffectingCombat(unit)
    local value = units[unit]
    return value and value.combat and 1 or nil
end
function UnitHealth(unit)
    local value = units[unit]
    return value and value.health or 100
end
function UnitHealthMax(unit)
    local value = units[unit]
    return value and value.healthMax or 100
end
function UnitIsConnected(unit)
    local value = units[unit]
    return value and value.connected and 1 or nil
end
function UnitIsUnit(left, right)
    local leftUnit = units[left]
    local rightUnit = units[right]
    if leftUnit and rightUnit and leftUnit == rightUnit then return 1 end
    if leftUnit and rightUnit and leftUnit.guid and rightUnit.guid
        and leftUnit.guid == rightUnit.guid then
        return 1
    end
    return nil
end
function GetNumRaidMembers() return 0 end
function GetNumPartyMembers() return 1 end
function AssistUnit(unit)
    units.target = units[unit .. "target"]
end
function TargetUnit(unit)
    targetUnitCalls = targetUnitCalls + 1
    lastTarget = units.target
    units.target = units[unit]
    if units.target then return end
    local index = 1
    while index <= table.getn(allEntities) do
        if allEntities[index].guid == unit then
            units.target = allEntities[index]
            return
        end
        index = index + 1
    end
end
function TargetNearestEnemy()
    targetCycleCalls = targetCycleCalls + 1
    lastTarget = units.target
    if targetCycle then
        local currentIndex = 0
        local index = 1
        while index <= table.getn(targetCycle) do
            if targetCycle[index] == units.target then
                currentIndex = index
                break
            end
            index = index + 1
        end
        currentIndex = currentIndex + 1
        if currentIndex > table.getn(targetCycle) then
            currentIndex = 1
        end
        units.target = targetCycle[currentIndex]
        return
    end
    units.target = nearest
end
function TargetLastTarget()
    local current = units.target
    units.target = lastTarget
    lastTarget = current
end
function ClearTarget()
    lastTarget = units.target
    units.target = nil
end
CleveRoids = {
    IsUnitInMeleeRange = function(unit)
        local value = units[unit]
        if value then return value.inMelee end
        return nil
    end,
}
function UnitClass() return "战士", "WARRIOR" end

BOOKTYPE_SPELL = "spell"
SlashCmdList = {}
function CreateFrame()
    return {
        RegisterEvent = function() end,
        SetScript = function() end,
    }
end

dofile("DoiteDPS/Core.lua")
local D = DoiteDPS
DoiteDPSDB = {}
D:InitializeDB()

local passed = 0
local function Expect(name, value)
    assert(value, name)
    passed = passed + 1
end

local assigned, assignedName = D:SetTankAssistFromUnit("target")
Expect(
    "a friendly party player can be assigned by current target",
    assigned and assignedName == "MainTank"
        and D.DB.tankAssistEnabled
        and D.DB.tankAssistName == "MainTank"
)

local status = D:GetTankAssistStatus()
Expect(
    "assigned tank status resolves the current roster token and hostile target",
    status.state == "ready"
        and status.unit == "party1"
        and status.targetUnit == "party1target"
        and status.targetName == "EnemyA"
)

units.target = nil
local changed, source = D:PrepareExecutionTarget(true)
Expect(
    "an empty target assists the tank on the same output press",
    changed and source == "tank"
        and units.target == enemyA
        and D._lastAssistedTargetGUID == "ENEMY_A"
)

units.party1target = enemyB
changed, source = D:PrepareExecutionTarget(true)
Expect(
    "a DDPS-assisted target follows the tank's next target",
    changed and source == "tank"
        and units.target == enemyB
        and D._lastAssistedTargetGUID == "ENEMY_B"
)

units.target = enemyC
changed, source = D:PrepareExecutionTarget(true)
Expect(
    "a manually selected live enemy overrides tank soft-follow",
    not changed and source == "manual"
        and units.target == enemyC
        and D._lastAssistedTargetGUID == nil
)

units.target = nil
changed, source = D:PrepareExecutionTarget(true)
Expect(
    "clearing the manual target resumes tank assistance",
    changed and source == "tank" and units.target == enemyB
)

units.party1target = nil
units.target = nil
changed, source = D:PrepareExecutionTarget(true)
Expect(
    "an unavailable tank target falls back to the existing nearest-enemy behavior",
    changed and source == "nearest"
        and units.target == nearest
        and D._lastAssistedTargetGUID == "NEAREST"
)

units.party1target = enemyA
changed, source = D:PrepareExecutionTarget(true)
Expect(
    "tank assistance resumes after a DDPS-owned nearest-target fallback",
    changed and source == "tank" and units.target == enemyA
)

tank.connected = false
status = D:GetTankAssistStatus()
Expect(
    "an offline assigned tank is reported without targeting in the background",
    status.state == "offline" and units.target == enemyA
)
tank.connected = true

local outsider = {
    name = "Outsider",
    guid = "OUTSIDER",
    exists = true,
    player = true,
    friendly = true,
    connected = true,
}
units.target = outsider
local valid, reason = D:SetTankAssistFromUnit("target")
Expect(
    "a friendly player outside the party cannot be assigned",
    not valid and reason == "not_grouped"
        and D.DB.tankAssistName == "MainTank"
)

units.party1target = nil
units.target = tank
D:SetTankAssistFromUnit("target")
units.target = enemyC
changed, source = D:PrepareExecutionTarget(true)
units.party1target = enemyB
local followChanged, followSource = D:PrepareExecutionTarget(true)
Expect(
    "assigning an unavailable tank never steals a later manual target",
    not changed
        and source == "no_target"
        and not followChanged
        and followSource == "manual"
        and units.target == enemyC
)

-- Without GUIDs, DDPS can acquire an empty target but deliberately does not
-- chase later tank switches over a still-valid target it cannot identify.
tank.guid = nil
enemyA.guid = nil
enemyB.guid = nil
units.party1target = enemyA
units.target = tank
D:SetTankAssistFromUnit("target")
units.target = nil
D:PrepareExecutionTarget(true)
units.party1target = enemyB
changed, source = D:PrepareExecutionTarget(true)
Expect(
    "GUID-less clients preserve a valid current target instead of blind-following",
    not changed and source == "manual" and units.target == enemyA
)

D:ClearTankAssist()
Expect(
    "clearing removes only the tank binding",
    D.DB.tankAssistEnabled == true
        and D.DB.tankAssistName == ""
        and D:GetTankAssistStatus().state == "unassigned"
)

-- Range-aware targeting is opt-in for Warrior execution. Ordinary callers
-- above keep the legacy manual-target behavior.
tank.guid = "TANK"
enemyA.guid = "ENEMY_A"
enemyB.guid = "ENEMY_B"
enemyC.guid = "ENEMY_C"
local castingStateRefreshes = 0
local originalStartAttackCalls = 0
local publicStartAttackCalls = 0
local startAttackTarget = nil
CleveRoids.UpdateCastingState = function()
    castingStateRefreshes = castingStateRefreshes + 1
end
CleveRoids.Hooks = {
    STARTATTACK_SlashCmd = function()
        originalStartAttackCalls = originalStartAttackCalls + 1
        startAttackTarget = units.target
    end,
}
SlashCmdList.STARTATTACK = function()
    publicStartAttackCalls = publicStartAttackCalls + 1
end

enemyC.inMelee = true
units.target = enemyC
targetCycleCalls = 0
targetUnitCalls = 0
changed, source = D:PrepareExecutionTarget(true, true, "MORTAL_STRIKE")
Expect(
    "Warrior output bypasses a blocked public startattack wrapper",
    not changed and units.target == enemyC
        and targetCycleCalls == 0 and targetUnitCalls == 0
        and castingStateRefreshes == 1
        and originalStartAttackCalls == 1
        and publicStartAttackCalls == 0
        and startAttackTarget == enemyC
)

enemyC.inMelee = false
enemyA.inMelee = false
enemyB.inMelee = true
units.target = enemyC
units.party1target = enemyB
targetCycleCalls = 0
targetUnitCalls = 0
changed, source = D:PrepareExecutionTarget(true, true, "MORTAL_STRIKE")
Expect(
    "Warrior execution immediately replaces a proven out-of-range target",
    changed and source == "party_target"
        and units.target == enemyB
        and targetCycleCalls == 0
        and targetUnitCalls == 1
        and D._lastAssistedTargetGUID == "ENEMY_B"
        and startAttackTarget == enemyB
)

-- Current melee validity itself prevents bounce; an unreachable target must
-- never be retained by a timer.
enemyB.inMelee = false
enemyA.inMelee = true
units.party1target = enemyA
changed, source = D:PrepareExecutionTarget(true, true, "MORTAL_STRIKE")
Expect(
    "a DDPS-selected target is replaced immediately once it leaves melee",
    changed and source == "party_target"
        and units.target == enemyA and targetUnitCalls == 2
)
changed, source = D:PrepareExecutionTarget(true, true, "MORTAL_STRIKE")
Expect(
    "the current melee replacement remains stable without a timer",
    not changed and source == "current"
        and units.target == enemyA and targetUnitCalls == 2
)

enemyC.inMelee = false
enemyA.inMelee = false
units.target = enemyC
units.party1target = enemyA
targetCycleCalls = 0
targetUnitCalls = 0
changed, source = D:PrepareExecutionTarget(true, true, "MORTAL_STRIKE")
Expect(
    "no proven candidate keeps the original target instead of cycling",
    not changed and source == "out_of_range"
        and units.target == enemyC
        and targetCycleCalls == 0 and targetUnitCalls == 0
)

enemyC.inMelee = nil
enemyB.inMelee = true
units.target = enemyC
units.party1target = enemyB
targetCycleCalls = 0
targetUnitCalls = 0
changed, source = D:PrepareExecutionTarget(true, true, "MORTAL_STRIKE")
Expect(
    "an unknown range probe never steals the current Warrior target",
    not changed and source == "unknown" and units.target == enemyC
        and targetCycleCalls == 0 and targetUnitCalls == 0
)
targetCycle = nil

units.target = enemyA
enemyA.health = 100
enemyA.healthMax = 100
D:ResetTargetHealthRuntime()
local healthState = {
    now = now,
    targetValid = true,
    targetGUID = enemyA.guid,
}
D:UpdateTargetHealthTrend(healthState)
now = now + 0.40
enemyA.health = 80
healthState.now = now
D:UpdateTargetHealthTrend(healthState)
Expect(
    "the health trend exposes a bounded high-confidence TTD signal",
    healthState.targetTTDConfidence
        and healthState.targetTTD > 1.5
        and healthState.targetTTD < 1.7
        and healthState.targetTimeToExecute > 1.1
        and healthState.targetTimeToExecute < 1.3
)

local updatedActionSpell = 0
local notified = 0
SMP_SUPER = {
    oldLF = {
        "oldLF",
        "icon",
        "#showtooltip\n/startattack\n/run DoiteDPS_Execute(\"single\")",
        "warrior",
    },
    oldCRLF = {
        "oldCRLF",
        "icon",
        "#showtooltip\r\n/startattack\r\n/run DoiteDPS_Execute(\"aoe\")",
        "warrior",
    },
    customized = {
        "customized",
        "icon",
        "#showtooltip\n/startattack\n/say custom\n/run DoiteDPS_Execute(\"single\")",
        "warrior",
    },
}
function SMP_UpdateActionSpell() updatedActionSpell = updatedActionSpell + 1 end
function SMP_NotifyMacroChanged() notified = notified + 1 end

local migrated, available = D:MigrateSuperMacroOutputOrder()
Expect(
    "macro migration reverses only adjacent DDPS/startattack pairs",
    available and migrated == 2
        and string.find(
            SMP_SUPER.oldLF[3],
            "/run DoiteDPS_Execute(\"single\")\n/startattack",
            1,
            true
        )
        and string.find(
            SMP_SUPER.oldCRLF[3],
            "/run DoiteDPS_Execute(\"aoe\")\r\n/startattack",
            1,
            true
        )
        and string.find(SMP_SUPER.customized[3], "/say custom", 1, true)
        and updatedActionSpell == 2
        and notified == 2
)

migrated = D:MigrateSuperMacroOutputOrder()
Expect(
    "macro migration is idempotent",
    migrated == 0 and updatedActionSpell == 2 and notified == 2
)

print("TankAssist_spec: " .. passed .. " checks passed")
