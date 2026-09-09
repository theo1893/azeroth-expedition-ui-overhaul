-- Run from repository root: lua tools/test_bigwigs_self_debuffs.lua
local names = { "李哥保护你", "李哥守护你", "你哥", "普通团员", "NotYou" }
local logs = {
    zhCN = { self = "你受到了%s效果的影响。", other = "%s受到了%s效果的影响。" },
    enUS = { self = "You are afflicted by %s.", other = "%s is afflicted by %s." },
}
local cases = {
    { file = "Anomalus", zhCN = "奥术超载", enUS = "Arcane Overload",
        sync = "AnomalusArcaneOverload30000 " },
    { file = "ChessFight", zhCN = "黑暗屈从", enUS = "Dark Subservience",
        sync = "ChessSubservience30002 " },
    { file = "EchoOfMedivh", zhCN = "麦迪文的腐化", enUS = "Corruption of Medivh",
        sync = "EchoMedivhCorruption30001 " },
    { file = "Kruul", zhCN = "大领主印记", enUS = "Mark of the Highlord",
        sync = "KruulMarkOfTheLord30001" },
    { file = "Mephistroth", zhCN = "军团镣铐", enUS = "Shackles of the Legion",
        sync = "MephistrothShacklesDebuff30002 " },
    { file = "SanvTasdal", zhCN = "相位转换", enUS = "Phase Shifted",
        sync = "SanvTasdalPhaseShifted30001 " },
}

function UnitName() return "观察者" end
function UnitClass() return "Warrior", "WARRIOR" end
function AceLibrary()
    return setmetatable({ new = function() return {} end }, {
        __index = function(_, key) return key end,
    })
end

local observed, context
local checks, patternChecks = 0, 0
local function record(value) table.insert(observed, value) end
local function loadModule(file, locale)
    local module, L = {}, {}
    function L:RegisterTranslations(language, factory)
        if language == locale then
            for key, value in pairs(factory()) do self[key] = value end
        end
    end
    BigWigs = { ModuleDeclaration = function() return module, L end }
    function module:RegisterYellEngage() end
    dofile("addon/BigWigs/Raids/Karazhan/" .. file .. ".lua")
    module.db = { profile = module.defaultDB }
    function module:Sync(message) record("sync " .. message) end
    function module:ShacklesDebuff(player) record("shackles " .. player) end
    function module:DoomOfMedivh(count) record("doom " .. count) end
    function module:SetRaidTargetForPlayer(player, mark)
        record("mark " .. player .. " " .. mark)
    end
    context = file .. "/" .. locale
    return module, L
end

local function check(module, message, expected)
    observed = {}
    local handler = module.AfflictionEvent or module.Event
    handler(module, message)
    assert(#observed == (expected and 1 or 0) and observed[1] == expected,
        context .. ": " .. message .. " => " .. table.concat(observed, "; ") ..
        "; expected " .. tostring(expected))
    checks = checks + 1
end

for _, locale in ipairs({ "zhCN", "enUS" }) do
    for _, case in ipairs(cases) do
        local module = loadModule(case.file, locale)
        local expected = "sync " .. case.sync .. "观察者"
        if case.file == "Mephistroth" then expected = "shackles 观察者" end
        check(module, string.format(logs[locale].self, case[locale]), expected)
        for _, player in ipairs(names) do
            check(module, string.format(logs[locale].other, player, case[locale]),
                "sync " .. case.sync .. player)
        end
        check(module, "An unrelated combat log message.", nil)
    end

    local module = loadModule("EchoOfMedivh", locale)
    for _, count in ipairs({ 1, 12 }) do
        local selfLog = locale == "zhCN" and "你受到了麦迪文的灾祸效果的影响（%d）。" or
            "You are afflicted by Doom of Medivh (%d)."
        local otherLog = locale == "zhCN" and "%s受到了麦迪文的灾祸效果的影响（%d）。" or
            "%s is afflicted by Doom of Medivh (%d)."
        check(module, string.format(selfLog, count), "doom " .. count)
        for _, player in ipairs(names) do
            check(module, string.format(otherLog, player, count), nil)
        end
    end

    local module, L = loadModule("ChessFight", locale)
    local charm = locale == "zhCN" and "魅惑之心" or "Charming Presence"
    check(module, string.format(logs[locale].self, charm), "mark 观察者 7")
    for _, player in ipairs(names) do
        check(module, string.format(logs[locale].other, player, charm), "mark " .. player .. " 7")
    end
    module.db.profile.markmindcontrol = false
    check(module, string.format(logs[locale].self, charm), nil)
    check(module, string.format(logs[locale].other, names[1], charm), nil)

    -- King's Curse is checked through UnitDebuff during Subservience; the
    -- unused landing pattern below has no event-handler behavior to exercise.
    local curse = locale == "zhCN" and "国王的诅咒" or "King's Curse"
    assert(string.find(string.format(logs[locale].self, curse), L.trigger_kingscurseYou),
        context .. ": King's Curse must match the local player")
    patternChecks = patternChecks + 1
    for _, player in ipairs(names) do
        assert(not string.find(string.format(logs[locale].other, player, curse), L.trigger_kingscurseYou),
            context .. ": King's Curse must not match " .. player .. " as the local player")
        patternChecks = patternChecks + 1
    end

    module = loadModule("Mephistroth", locale)
    module.db.profile.shackleshatter = true
    local shatter = "sync MephistrothShackleShatter30002 "
    local selfShatter = locale == "zhCN" and "你的镣铐碎裂" or "Your Shackle Shatter "
    local otherShatter = locale == "zhCN" and "%s的镣铐碎裂" or "%s's Shackle Shatter "
    local damage = locale == "zhCN" and "击中普通团员造成100点奥术伤害。" or "hits Raider for 100 Arcane damage."
    check(module, selfShatter .. damage, shatter .. "观察者")
    for _, player in ipairs(names) do
        check(module, string.format(otherShatter, player) .. damage, shatter .. player)
    end
    check(module, "An unrelated combat log message.", nil)
    module.db.profile.shackleshatter = false
    check(module, selfShatter .. damage, nil)
end
print("PASS: BigWigs self-debuffs: " .. checks .. " handler checks across 6 bosses / 2 locales; " ..
    patternChecks .. " King's Curse pattern-only checks")
