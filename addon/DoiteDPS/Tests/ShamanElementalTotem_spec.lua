-- Standalone checks for Elemental Shaman fire-totem state tracking.
-- Run from the AddOns directory with:
-- lua DoiteDPS/Tests/ShamanElementalTotem_spec.lua

if not table.getn then
    table.getn = function(value) return #value end
end

local currentTime = 100
local improvedFireTotemsRank = 2
local activeTotem

function GetTime() return currentTime end
function GetNumTalentTabs() return 1 end
function GetNumTalents() return 2 end
function GetTalentInfo(_, index)
    if index == 1 then
        return "Convection", nil, nil, nil, 5
    end
    return "强化火焰图腾", nil, nil, nil, improvedFireTotemsRank
end

FIRE_TOTEM_SLOT = 1
function GetTotemInfo()
    if not activeTotem then return nil end
    return 1,
        activeTotem.name,
        activeTotem.start,
        activeTotem.duration,
        activeTotem.icon
end

DoiteDPS = {
    Trackers = {},
    Names = {
        FLAME_SHOCK = "烈焰震击",
        LAVA_BURST = "熔岩爆裂",
        SEARING_TOTEM = "灼热图腾",
        FIRE_NOVA_TOTEM = "火焰新星图腾",
        MAGMA_TOTEM = "熔岩图腾",
    },
}

local D = DoiteDPS
function D:GetUnitGUID() return nil end
function D:GetDistance() return nil end
function D:IsInRange() return true end
function D:GetProfileDB() return {} end

dofile("DoiteDPS/Trackers/ShamanElemental.lua")
local T = D.Trackers.ShamanElemental

local function BuildState()
    local state = {
        targetValid = true,
        cast = {},
    }
    T:BuildState(state)
    return state
end

local passed = 0
assert(
    T:GetImprovedFireTotemsRank() == 2,
    "Improved Fire Totems should be found by localized talent name"
)
passed = passed + 1

activeTotem = {
    name = "火焰新星图腾",
    start = 100,
    duration = 5,
    icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
}
currentTime = 101
local novaState = BuildState()
assert(
    novaState.fireTotemStateAvailable
        and novaState.fireTotemActive
        and novaState.fireTotemKind == "nova"
        and novaState.fireNovaActivation == 3
        and math.abs(novaState.fireTotemRemaining - 2) < 0.01,
    "rank 2 should reduce Fire Nova activation from five to three seconds"
)
passed = passed + 1

currentTime = 103.1
local explodedNovaState = BuildState()
assert(
    explodedNovaState.fireTotemStateAvailable
        and not explodedNovaState.fireTotemActive
        and explodedNovaState.fireTotemKind == nil,
    "Fire Nova should release the fire slot after its adjusted activation"
)
passed = passed + 1

activeTotem = {
    name = "灼热图腾",
    start = 100,
    duration = 55,
    icon = "Interface\\Icons\\Spell_Fire_SearingTotem",
}
currentTime = 120
local searingState = BuildState()
assert(
    searingState.fireTotemKind == "searing"
        and searingState.fireTotemDuration == 55
        and math.abs(searingState.fireTotemRemaining - 35) < 0.01,
    "Searing Totem should keep the provider's 55-second duration"
)
passed = passed + 1

activeTotem = {
    name = "熔岩图腾",
    start = 100,
    duration = 20,
    icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
}
currentTime = 110
local magmaState = BuildState()
assert(
    magmaState.fireTotemKind == "magma"
        and magmaState.fireTotemDuration == 20
        and math.abs(magmaState.fireTotemRemaining - 10) < 0.01,
    "Magma Totem should keep the provider's 20-second duration"
)
passed = passed + 1

activeTotem = {
    name = "火舌图腾",
    start = 100,
    duration = 120,
    icon = "Interface\\Icons\\Spell_Nature_GuardianWard",
}
currentTime = 110
assert(
    BuildState().fireTotemKind == "utility",
    "non-damage fire totems should be protected as utility totems"
)
passed = passed + 1

local savedGetTotemInfo = GetTotemInfo
GetTotemInfo = nil
assert(
    not BuildState().fireTotemStateAvailable,
    "automatic totems should fail safe when no Totem API provider is loaded"
)
GetTotemInfo = savedGetTotemInfo
passed = passed + 1

improvedFireTotemsRank = 1
T:OnEvent("CHARACTER_POINTS_CHANGED")
activeTotem = nil
local changedTalentState = BuildState()
assert(
    changedTalentState.improvedFireTotemsRank == 1
        and changedTalentState.fireNovaActivation == 4,
    "talent changes should refresh the Fire Nova activation time"
)
passed = passed + 1

print("ShamanElementalTotem_spec: " .. passed .. " checks passed")
