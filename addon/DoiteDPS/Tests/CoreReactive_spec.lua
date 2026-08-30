-- Standalone checks for reactive-proc and cross-profile session handling.
-- Run from the AddOns directory with:
-- lua DoiteDPS/Tests/CoreReactive_spec.lua

if not table.getn then
    table.getn = function(value) return #value end
end

function GetLocale() return "zhCN" end
local now = 100
function GetTime() return now end
function UnitExists() return true, "UNIT_EXISTS_GUID" end
function GetUnitGUID(unit)
    if unit == "player" then return "NP_PLAYER" end
    return "NP_TARGET"
end

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
local passed = 0

local function Expect(name, value)
    assert(value, name)
    passed = passed + 1
end

local function ContainsKey(values, expected)
    local index = 1
    while index <= table.getn(values or {}) do
        if values[index] == expected then return true end
        index = index + 1
    end
    return false
end

Expect(
    "Elemental Mastery is registered as a tracked Shaman cooldown",
    D.Names.ELEMENTAL_MASTERY == "元素掌握"
        and D.SpellDefs.ELEMENTAL_MASTERY
        and D.SpellDefs.ELEMENTAL_MASTERY.texture
            == "Interface\\Icons\\Spell_Nature_WispHeal"
        and ContainsKey(D.SpellOrder, "ELEMENTAL_MASTERY")
        and ContainsKey(D.ShamanCooldownKeys, "ELEMENTAL_MASTERY")
)

Expect(
    "unit GUID lookup prefers the Nampower 1.12 API",
    D:GetUnitGUID("target") == "NP_TARGET"
        and D:GetUnitGUID("player") == "NP_PLAYER"
)

local testRage = 130
local testMaxRage = 130
function UnitMana() return testRage end
function UnitManaMax() return testMaxRage end
Expect(
    "Warrior rage uses the real Boundless Anger cap",
    D:GetMaxRage() == 130 and D:GetRage() == 130
)
testMaxRage = 120
Expect(
    "rage is clamped only to the character's real maximum",
    D:GetRage() == 120
)

D.Spells.SWEEPING_STRIKES = { spellId = 12328 }
DoitePlayerAuras = {
    HasBuff = function(name) return name == "横扫攻击" end,
    GetBuffStacks = function(name)
        if name == "横扫攻击" then return 3 end
    end,
}
DoiteAuras_GetPlayerAuraRemainingSeconds = function(name)
    if name == "横扫攻击" then return 4.25 end
end
local sweepingActive, sweepingRemaining, sweepingStacks =
    D:GetPlayerBuffState("SWEEPING_STRIKES", true)
Expect(
    "DoiteAuras supplies Sweeping Strikes time and charges",
    sweepingActive == true
        and sweepingRemaining == 4.25
        and sweepingStacks == 3
)
DoitePlayerAuras = nil
DoiteAuras_GetPlayerAuraRemainingSeconds = nil

D.IsUsable = function() return true, false end

DoiteDPSDB = {}
D:InitializeDB()
local freshShaman = D:GetProfileDB("SHAMAN_ELEMENTAL")
Expect(
    "new Shaman settings default to conserve mode with all damage totems enabled",
    freshShaman.singleOutputMode == "conserve"
        and freshShaman.aoeOutputMode == "conserve"
        and freshShaman.enableSearingTotem == true
        and freshShaman.enableFireNovaTotem == true
        and freshShaman.enableMagmaTotem == true
)

DoiteDPSDB = {
    profileSettings = {
        SHAMAN_ELEMENTAL = {
            outputMode = "burst",
            enablePvEDamageTotems = false,
        },
    },
}
D:InitializeDB()
local migratedShaman = D:GetProfileDB("SHAMAN_ELEMENTAL")
Expect(
    "the shared Shaman mode migrates to both rotations with the old totem value",
    migratedShaman.singleOutputMode == "burst"
        and migratedShaman.aoeOutputMode == "burst"
        and migratedShaman.enableSearingTotem == false
        and migratedShaman.enableFireNovaTotem == false
        and migratedShaman.enableMagmaTotem == false
)

migratedShaman.singleOutputMode = "conserve"
D:InitializeProfileDB()
Expect(
    "separate Shaman output modes survive later default synchronization",
    migratedShaman.singleOutputMode == "conserve"
        and migratedShaman.aoeOutputMode == "burst"
)

DoiteDPSDB = {
    profileSettings = {
        SHAMAN_ELEMENTAL = {
            enablePvPBurst = true,
        },
    },
}
D:InitializeDB()
local preChoiceShaman = D:GetProfileDB("SHAMAN_ELEMENTAL")
Expect(
    "the pre-choice PvP toggle still migrates both rotations to burst",
    preChoiceShaman.singleOutputMode == "burst"
        and preChoiceShaman.aoeOutputMode == "burst"
)

local rotation = D:GetRotationDB(
    "TEST_PROFILE",
    "battle",
    { enabled = true, threshold = 30 }
)
Expect(
    "data-driven rotation defaults are created for new profiles",
    rotation.enabled == true and rotation.threshold == 30
)
rotation.threshold = 45
local preservedRotation = D:GetRotationDB(
    "TEST_PROFILE",
    "battle",
    { enabled = true, threshold = 30 }
)
Expect(
    "custom rotation values survive default synchronization",
    preservedRotation.threshold == 45
)
local resetRotation = D:ResetRotationDB(
    "TEST_PROFILE",
    "battle",
    { enabled = true, threshold = 30 }
)
Expect(
    "rotation reset restores declared defaults",
    resetRotation.enabled == true and resetRotation.threshold == 30
)
DoiteDPSDB.mode = "battle_aoe"
D:InitializeDB()
Expect(
    "database initialization preserves the Battle AoE internal mode",
    D.DB.mode == "battle_aoe"
)
D.DB.mode = "single"

local armsProfile = { key = "WARRIOR_ARMS" }
local protectionProfile = { key = "WARRIOR_PROTECTION" }
D.Profiles.WarriorArms = armsProfile
D.Profiles.WarriorProtection = protectionProfile
local knowsShieldSlam = false
D.IsKnown = function(self, key)
    if key == "SHIELD_SLAM" then return knowsShieldSlam end
    return false
end
Expect(
    "warrior fallback uses Arms without a loaded catalog",
    D:GetActiveProfile("WARRIOR") == armsProfile
)
knowsShieldSlam = true
Expect(
    "learned Shield Slam does not replace the visible Warrior profile",
    D:GetActiveProfile("WARRIOR") == armsProfile
)
local warriorCatalog = { key = "WARRIOR_ALL" }
D.Profiles.Warrior = warriorCatalog
Expect(
    "loaded Warrior catalog is active regardless of deep talents",
    D:GetActiveProfile("WARRIOR") == warriorCatalog
)
D.Profiles.Warrior = nil
knowsShieldSlam = false

local modeProfile = {
    key = "MODE_TEST",
    ModeOrder = { "single", "battle", "aoe", "elemental_pvp_close" },
    ModeLabels = {
        single = "狂暴单体",
        battle = "战斗单体",
        aoe = "狂暴AOE",
        elemental_pvp_close = "电萨PvP近战",
    },
    EntryOrder = { "single", "aoe", "pvp_close" },
    EntryPoints = {
        single = {
            label = "单体出口",
            modes = { "single", "battle" },
            default = "single",
        },
        aoe = {
            label = "AOE出口",
            modes = { "aoe" },
            default = "aoe",
        },
        pvp_close = {
            label = "电萨近战出口",
            modes = { "elemental_pvp_close" },
            default = "elemental_pvp_close",
        },
    },
    NormalizeMode = function(self, mode)
        if mode == "battle" then return "battle" end
        if mode == "aoe" then return "aoe" end
        if mode == "elemental_pvp_close" then
            return "elemental_pvp_close"
        end
        return "single"
    end,
    GetModeLabel = function(self, mode)
        return self.ModeLabels[self:NormalizeMode(mode)]
    end,
}
Expect(
    "profile-owned mode normalization preserves Battle single",
    D:NormalizeModeForProfile(modeProfile, "battle") == "battle"
)
Expect(
    "class-specific PvP close output is not synthesized for other profiles",
    D:GetEntryDefinition({ EntryPoints = {} }, "pvp_close") == nil
)
Expect(
    "default rotation name comes from the profile",
    D:GetRotationName(modeProfile, "battle") == "战斗单体"
)
local renamed, renamedValue = D:SetRotationName(
    modeProfile,
    "battle",
    "练级单体"
)
Expect(
    "rotation name can be customized",
    renamed and renamedValue == "练级单体"
        and D:GetRotationName(modeProfile, "battle") == "练级单体"
)
Expect(
    "rotation names remain display metadata",
    D:GetRotationName(modeProfile, "battle") == "练级单体"
)
D.DB.mode = "battle"
Expect(
    "first single binding migration preserves the active compatible mode",
    D:GetEntryBinding(modeProfile, "single") == "battle"
        and D:GetEntryBinding(modeProfile, "aoe") == "aoe"
        and D:GetEntryBinding(modeProfile, "pvp_close")
            == "elemental_pvp_close"
)
local rebound, reboundMode = D:SetEntryBinding(
    modeProfile,
    "single",
    "single"
)
Expect(
    "single output can be rebound to another compatible rotation",
    rebound and reboundMode == "single"
        and D:GetEntryBinding(modeProfile, "single") == "single"
)
local invalidBinding = D:SetEntryBinding(
    modeProfile,
    "single",
    "aoe"
)
Expect(
    "single output rejects an incompatible AoE rotation",
    invalidBinding == false
)
D:SetEntryBinding(modeProfile, "single", "battle")
D.DB.mode = "single"
Expect(
    "saved output binding is independent from the currently previewed mode",
    D:GetEntryBinding(modeProfile, "single") == "battle"
)
local executedNamedMode = nil
modeProfile.Execute = function(self, mode)
    executedNamedMode = mode
    return true
end
D.GetActiveProfile = function() return modeProfile end
Expect(
    "mode switching by public entry selects the bound bottom rotation",
    D:SetModeByEntry("single", true) == true
        and D.DB.mode == "battle"
)
Expect(
    "single public output resolves to its selected bottom rotation",
    D:Execute("single") == true and executedNamedMode == "battle"
)
executedNamedMode = nil
Expect(
    "aoe public output resolves independently",
    D:Execute("aoe") == true and executedNamedMode == "aoe"
)
executedNamedMode = nil
Expect(
    "profile-owned PvP close output resolves independently",
    D:Execute("pvp_close") == true
        and executedNamedMode == "elemental_pvp_close"
)
executedNamedMode = nil
Expect(
    "rotation display names are no longer executable",
    D:Execute("练级单体") == false and executedNamedMode == nil
)
Expect(
    "public execution rejects bottom mode ids and unknown entries",
    D:Execute("battle") == false
        and D:Execute("battle_single") == false
        and D:Execute("elemental_pvp_close") == false
        and D:Execute("不存在的循环") == false
)
executedNamedMode = nil
Expect(
    "internal state machine can still execute its stable mode id",
    D:ExecuteMode("battle") == true and executedNamedMode == "battle"
)
local reservedAccepted = D:SetRotationName(
    modeProfile,
    "single",
    "single"
)
Expect(
    "internal mode ids cannot be reused as custom names",
    reservedAccepted == false
)
local closeEntryNameAccepted = D:SetRotationName(
    modeProfile,
    "elemental_pvp_close",
    "pvp_close"
)
Expect(
    "the dedicated PvP close entry key remains reserved",
    closeEntryNameAccepted == false
)
local duplicateAccepted = D:SetRotationName(
    modeProfile,
    "single",
    "练级单体"
)
Expect(
    "duplicate rotation names are rejected",
    duplicateAccepted == false
)
D:ResetRotationName(modeProfile, "battle")
Expect(
    "rotation name reset restores the profile label",
    D:GetRotationName(modeProfile, "battle") == "战斗单体"
)

local entryMigrationProfile = {
    key = "ENTRY_MIGRATION_TEST",
    ModeOrder = { "single", "battle_aoe", "aoe" },
    EntryOrder = { "single", "aoe" },
    EntryPoints = {
        single = {
            modes = { "single" },
            default = "single",
        },
        aoe = {
            modes = { "battle_aoe", "aoe" },
            default = "battle_aoe",
            version = 1,
            migrations = {
                aoe = "battle_aoe",
            },
        },
    },
    NormalizeMode = function(self, mode)
        if mode == "battle_aoe" then return "battle_aoe" end
        if mode == "aoe" then return "aoe" end
        return "single"
    end,
}
local entryMigrationDB = D:GetProfileDB(entryMigrationProfile.key)
entryMigrationDB.entryBindings = { aoe = "aoe" }
entryMigrationDB.entryBindingsMigrated = true
D.DB.mode = "aoe"
Expect(
    "versioned output migration moves an existing AoE binding once",
    D:GetEntryBinding(entryMigrationProfile, "aoe") == "battle_aoe"
        and entryMigrationDB.entryBindingVersions.aoe == 1
        and D.DB.mode == "battle_aoe"
)
D:SetEntryBinding(entryMigrationProfile, "aoe", "aoe")
Expect(
    "a post-migration player choice is not overwritten again",
    D:GetEntryBinding(entryMigrationProfile, "aoe") == "aoe"
)
D.DB.mode = "single"

CleveRoids = {
    reactiveProcs = {
        [D.Names.OVERPOWER] = { expiry = 104 },
    },
    HasReactiveProc = function() return false end,
}

local active = D:GetReactiveState("OVERPOWER")
Expect(
    "authoritative tracker false blocks stale IsSpellUsable fallback",
    active == false
)

CleveRoids.HasReactiveProc = function() return true end
local procActive, remaining = D:GetReactiveState("OVERPOWER")
Expect(
    "active tracked Overpower is returned with remaining time",
    procActive == true and remaining == 4
)

CleveRoids = nil
local fallbackActive = D:GetReactiveState("OVERPOWER")
Expect(
    "IsSpellUsable remains a fallback without the tracker",
    fallbackActive == true
)

local hsQueuedByApi = false
local cleaveQueuedByApi = false
D.Spells.HEROIC_STRIKE = { spellId = 25286 }
pfUI = {
    swingtimer = {
        api = {
            IsMHActive = function() return true end,
            GetMHTimer = function() return 1.2 end,
            GetMHSpeed = function() return 3.0 end,
            IsHSQueued = function() return hsQueuedByApi end,
            IsCleaveQueued = function() return cleaveQueuedByApi end,
        },
    },
}
local attemptedSwing = { remaining = 1.2, speed = 3.0 }
D:MarkOnSwingQueued(
    "HEROIC_STRIKE",
    attemptedSwing
)
Expect(
    "a local cast attempt is pending but not presented as a real queue",
    attemptedSwing.hsQueued == false
        and attemptedSwing.cleaveQueued == false
        and attemptedSwing.queuePending == true
        and attemptedSwing.pendingKey == "HEROIC_STRIKE"
)
local bridgedQueue = D:GetSwingState({})
Expect(
    "an authoritative provider keeps an unconfirmed attempt out of the queue display",
    bridgedQueue.hsQueued == false
        and bridgedQueue.cleaveQueued == false
        and bridgedQueue.queuePending == true
        and bridgedQueue.queueConfirmed == false
        and bridgedQueue.pendingKey == "HEROIC_STRIKE"
)
hsQueuedByApi = true
local confirmedQueue = D:GetSwingState({})
Expect(
    "authoritative queue state confirms the local Heroic Strike latch",
    confirmedQueue.hsQueued == true
        and confirmedQueue.queueConfirmed == true
        and confirmedQueue.queuePending == false
        and D._pendingOnSwing
        and D._pendingOnSwing.confirmed == true
)
hsQueuedByApi = false
local resolvedQueue = D:GetSwingState({})
Expect(
    "queue-pop keeps the confirmed Heroic Strike hidden and input-locked",
    resolvedQueue.hsQueued == false
        and resolvedQueue.queuePending == true
        and resolvedQueue.pendingKey == "HEROIC_STRIKE"
        and D._pendingOnSwing
        and D._pendingOnSwing.confirmed == true
)
local ignoredResult = D:ResolveOnSwingQueued(12345)
local matchedResult = D:ResolveOnSwingQueued(25286)
Expect(
    "only the matching on-swing result releases the input lock",
    ignoredResult == false and matchedResult == true
        and D._pendingOnSwing == nil
)

cleaveQueuedByApi = true
local observedProviderCleave = D:GetSwingState({})
Expect(
    "a newly observed provider Cleave is trusted for the current swing",
    observedProviderCleave.cleaveQueued == true
        and observedProviderCleave.queueConfirmed == true
        and observedProviderCleave.queueStale == false
)
now = 101.6
local staleProviderCleave = D:GetSwingState({})
Expect(
    "a provider Cleave cannot outlive the predicted main-hand swing",
    staleProviderCleave.cleaveQueued == false
        and staleProviderCleave.queueConfirmed == false
        and staleProviderCleave.queueStale == true
        and staleProviderCleave.staleKey == "CLEAVE"
)
now = 102
local stillStaleProviderCleave = D:GetSwingState({})
Expect(
    "the same stale provider flag is not reaccepted on every refresh",
    stillStaleProviderCleave.cleaveQueued == false
        and stillStaleProviderCleave.queueStale == true
)
cleaveQueuedByApi = false
D:GetSwingState({})
cleaveQueuedByApi = true
local freshProviderCleave = D:GetSwingState({})
Expect(
    "a real provider clear allows a later Cleave queue to be observed",
    freshProviderCleave.cleaveQueued == true
        and freshProviderCleave.queueStale == false
)
cleaveQueuedByApi = false
now = 100
D:GetSwingState({})

D:MarkOnSwingQueued("CLEAVE", { remaining = 1.2, speed = 3.0 })
local unconfirmedCleave = D:GetSwingState({})
Expect(
    "an unconfirmed Cleave stays a hidden attempt lock",
    unconfirmedCleave.cleaveQueued == false
        and unconfirmedCleave.queuePending == true
        and unconfirmedCleave.pendingKey == "CLEAVE"
)
now = 100.8
local rejectedCleave = D:GetSwingState({})
Expect(
    "a Cleave rejected by the authoritative provider expires without a fake queue",
    rejectedCleave.cleaveQueued == false
        and rejectedCleave.queuePending == false
        and D._pendingOnSwing == nil
)
now = 100

pfUI.swingtimer.api.IsHSQueued = nil
D:MarkOnSwingQueued(
    "HEROIC_STRIKE",
    { remaining = 2.0, speed = 3.0 }
)
now = 101
local partialApiQueue = D:GetSwingState({})
Expect(
    "an unrelated Cleave API does not expire the Heroic Strike latch",
    partialApiQueue.hsQueued == true
        and partialApiQueue.queuePending == true
)
D:ClearOnSwingQueued()
now = 100

pfUI = nil
CleveRoids = {
    GetSwingTimerRaw = function() return 1.0, 3.0 end,
}
D:MarkOnSwingQueued("CLEAVE", { remaining = 1.0, speed = 3.0 })
local fallbackQueue = D:GetSwingState({})
Expect(
    "next-swing latch works without an authoritative queue provider",
    fallbackQueue.cleaveQueued == true
        and fallbackQueue.hsQueued == false
)
now = 101.5
local expiredQueue = D:GetSwingState({})
Expect(
    "providerless next-swing latch expires after the predicted swing",
    expiredQueue.cleaveQueued == false and D._pendingOnSwing == nil
)
now = 100

CleveRoids = {
    reactiveProcs = {
        [D.Names.OVERPOWER] = { expiry = 104 },
    },
}
D:ClearReactiveState()
Expect(
    "session reset clears the external Overpower proc table",
    CleveRoids.reactiveProcs[D.Names.OVERPOWER] == nil
)

local uiResetCount = 0
D.UI = {
    ResetRuntimeState = function()
        uiResetCount = uiResetCount + 1
    end,
}
D.State = { clearcasting = 2 }
D._lastKnownStance = 3
D._lastKnownStanceAt = 99
D._activeProfileKey = "SHAMAN_ELEMENTAL"
D._pendingOnSwing = { key = "HEROIC_STRIKE" }
D:ResetCharacterRuntime()
Expect(
    "character reset clears class state and UI runtime",
    next(D.State) == nil
        and D._lastKnownStance == nil
        and D._activeProfileKey == nil
        and D._pendingOnSwing == nil
        and uiResetCount == 1
)

print("CoreReactive_spec: " .. passed .. " checks passed")
