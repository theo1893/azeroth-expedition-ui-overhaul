-- Focused self-check for the reduced Warrior catalog.
-- Run from Interface/AddOns: lua DoiteDPS/Tests/WarriorCatalog_spec.lua

table.getn = table.getn or function(value) return #value end
function GetLocale() return "zhCN" end

DoiteDPS = {
    Profiles = {},
    WarriorCooldownKeys = { "MORTAL_STRIKE" },
    WarriorProtectionCooldownKeys = { "SHIELD_SLAM" },
    DB = { mode = "fury_aoe" },
}
local D = DoiteDPS
local profileDBs = {}
local known = { SHIELD_SLAM = false }

function D:IsKnown(key) return known[key] == true end
function D:GetProfileDB(key)
    profileDBs[key] = profileDBs[key] or {}
    return profileDBs[key]
end
function D:GetEntryBinding(profile, entry)
    return profile.EntryPoints[entry].default
end
function D:ResetRotationDB(profileKey, mode, defaults)
    return { profileKey = profileKey, mode = mode, defaults = defaults }
end

local function Owner(key, label)
    local owner = {
        key = key,
        ModeOrder = { "single", "aoe" },
        ModeLabels = { single = label, aoe = label },
        ModeNotes = { single = label, aoe = label },
        EntryPoints = {
            single = { default = "single" },
            aoe = { default = "aoe" },
        },
        ConfigSchema = { options = {} },
        events = 0,
        resets = 0,
    }
    function owner:NormalizeMode(mode)
        return mode == "aoe" and "aoe" or "single"
    end
    function owner:GetModeLabel(mode)
        return self.ModeLabels[self:NormalizeMode(mode)]
    end
    function owner:GetRotationDefaults(mode)
        return { owner = self.key, mode = self:NormalizeMode(mode) }
    end
    function owner:GetRotationDB(mode)
        return { owner = self.key, mode = self:NormalizeMode(mode) }
    end
    function owner:BuildState(state)
        state.delegatedTo = self.key .. ":" .. state.mode
    end
    function owner:Recommend(state)
        return { key = self.key, mode = state.mode }
    end
    function owner:Evaluate(state)
        return self:Recommend(state), { self.key }
    end
    function owner:Execute(mode)
        self.executed = mode
        return true
    end
    function owner:OnEvent() self.events = self.events + 1 end
    function owner:ResetRuntime() self.resets = self.resets + 1 end
    return owner
end

local arms = Owner("WARRIOR_ARMS", "双手武器战")
local protection = Owner("WARRIOR_PROTECTION", "防战")
D.Profiles.WarriorArms = arms
D.Profiles.WarriorProtection = protection

dofile("DoiteDPS/Profiles/Warrior.lua")
local W = D.Profiles.Warrior

local passed = 0
local function Check(label, condition)
    assert(condition, label)
    passed = passed + 1
end

Check(
    "catalog contains only Arms and Protection single/AoE",
    table.getn(W.ModeOrder) == 4
        and W.ModeLabels.arms_berserker_single == "双手武器战"
        and W.ModeLabels.arms_berserker_aoe == "双手武器战"
        and W.ModeLabels.protection_single == "防战"
        and W.ModeLabels.protection_aoe == "防战"
        and W.ModeLabels.arms_battle_single == nil
        and W.ModeLabels.fury_single == nil
)

Check(
    "each fixed output has exactly two choices",
    table.getn(W.EntryPoints.single.modes) == 2
        and table.getn(W.EntryPoints.aoe.modes) == 2
        and W.EntryPoints.single.default == "arms_berserker_single"
        and W.EntryPoints.aoe.default == "arms_berserker_aoe"
)

local saved = {
    warriorCatalogVersion = 1,
    entryBindings = {
        single = "arms_battle_single",
        aoe = "fury_aoe",
    },
}
W:PrepareEntryBindings(saved)
Check(
    "removed stance/Fury bindings migrate to deep Arms",
    saved.entryBindings.single == "arms_berserker_single"
        and saved.entryBindings.aoe == "arms_berserker_aoe"
        and saved.warriorCatalogVersion == 2
        and D.DB.mode == "arms_berserker_aoe"
)

local protectionSaved = {
    warriorCatalogVersion = 1,
    entryBindings = {
        single = "protection_single",
        aoe = "protection_aoe",
    },
}
D.DB.mode = "protection_single"
W:PrepareEntryBindings(protectionSaved)
Check(
    "Protection bindings remain intact",
    protectionSaved.entryBindings.single == "protection_single"
        and protectionSaved.entryBindings.aoe == "protection_aoe"
        and D.DB.mode == "protection_single"
)

Check(
    "legacy mode aliases resolve without exposing removed rotations",
    W:NormalizeMode("battle") == "arms_berserker_single"
        and W:NormalizeMode("fury_single") == "arms_berserker_single"
        and W:NormalizeMode("battle_aoe") == "arms_berserker_aoe"
        and W:NormalizeMode("fury_aoe") == "arms_berserker_aoe"
)

local owner, mode = W:ResolveModeProfile("protection_aoe")
Check(
    "catalog delegates to the selected owner",
    owner == protection and mode == "aoe"
)

local state = { mode = "arms_berserker_single" }
W:BuildState(state)
Check(
    "state delegation restores the catalog mode",
    state.delegatedTo == "WARRIOR_ARMS:single"
        and state.mode == "arms_berserker_single"
        and state.profileKey == "WARRIOR_ALL"
)

W:OnEvent("SPELLS_CHANGED")
W:ResetRuntime()
Check(
    "events and resets reach only the two loaded Warrior owners",
    arms.events == 1 and protection.events == 1
        and arms.resets == 1 and protection.resets == 1
)

Check(
    "execution delegates through the fixed output catalog",
    W:Execute("arms_berserker_aoe") == true and arms.executed == "aoe"
)

print("WarriorCatalog_spec: " .. passed .. " checks passed")
