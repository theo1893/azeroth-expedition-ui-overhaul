-- Run from repository root: lua tools/test_bigwigs_self_debuffs.lua
local names = { "你哥守护你", "李哥保护你", "李哥守护你", "你哥", "普通团员", "NotYou" }
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
function GetTime() return 100 end
function UnitClass() return "Warrior", "WARRIOR" end
function AceLibrary()
    return setmetatable({ new = function() return {} end }, {
        __index = function(_, key) return key end,
    })
end

local observed, context
local checks, patternChecks = 0, 0
local function record(value) table.insert(observed, value) end
local function loadModule(file, locale, folder)
    local module, L = {}, {}
    function L:RegisterTranslations(language, factory)
        if language == locale then
            for key, value in pairs(factory()) do self[key] = value end
        end
    end
    BigWigs = { ModuleDeclaration = function() return module, L end }
    function module:RegisterYellEngage() end
    dofile("addon/BigWigs/Raids/" .. (folder or "Karazhan") .. "/" .. file .. ".lua")
    local doomHandler = module.DoomOfMedivh
    module.db = { profile = module.defaultDB }
    function module:Sync(message) record("sync " .. message) end
    function module:ShacklesDebuff(player) record("shackles " .. player) end
    function module:Subservience() end
    function module:DoomOfMedivh(count) record("doom " .. count) end
    function module:SetRaidTargetForPlayer(player, mark)
        record("mark " .. player .. " " .. mark)
    end
    context = file .. "/" .. locale
    return module, L, doomHandler
end

local function check(module, message, expected, method)
    observed = {}
    local handler = method and module[method] or module.AfflictionEvent or module.DebuffEvent or module.Event
    handler(module, message)
    local expectedList = type(expected) == "table" and expected or (expected and {expected} or {})
    assert(table.concat(observed, "; ") == table.concat(expectedList, "; "),
        context .. ": " .. message .. " => " .. table.concat(observed, "; ") ..
        "; expected " .. tostring(expected))
    checks = checks + 1
end

for _, locale in ipairs({ "zhCN", "enUS" }) do
    for _, case in ipairs(cases) do
        local module = loadModule(case.file, locale)
        local sync = string.gsub(case.sync, "%d+", tostring(module.revision))
        local expected = "sync " .. sync .. "观察者"
        if case.file == "Mephistroth" then expected = {"shackles 观察者", expected} end
        check(module, string.format(logs[locale].self, case[locale]), expected)
        for _, player in ipairs(names) do
            check(module, string.format(logs[locale].other, player, case[locale]),
                "sync " .. sync .. player)
        end
        check(module, "An unrelated combat log message.", nil)
    end

    local module, _, doomHandler = loadModule("EchoOfMedivh", locale)
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

    if locale == "zhCN" then
        for _, suffix in ipairs({ "（2）。", "(2)。", " （12）。", " (12)。" }) do
            local count = string.find(suffix, "12", 1, true) and 12 or 2
            check(module, "你受到了麦迪文的灾祸效果的影响" .. suffix, "doom " .. count)
            for _, player in ipairs(names) do
                check(module, player .. "受到了麦迪文的灾祸效果的影响" .. suffix, nil)
            end
        end
    end

    -- Exercise the real timer entry too, rather than stopping at the parsed count.
    module.DoomOfMedivh = doomHandler
    local bar, removed
    function module:RemoveBar(text) removed = text end
    function module:IntervalBar(text, low, high, icon, custom, color)
        bar = { text, low, high, icon, custom, color }
    end
    for _, count in ipairs({ 1, 2, 3, 4 }) do
        bar = nil
        local message = locale == "zhCN" and "你受到了麦迪文的灾祸效果的影响（%d）。"
            or "You are afflicted by Doom of Medivh (%d)."
        module:AfflictionEvent(string.format(message, count))
        local title = locale == "zhCN" and "麦迪文的灾祸(%d)" or "Doom of Medivh (%d)"
        assert(bar and bar[1] == string.format(title, count)
            and bar[2] == 14 and bar[3] == 24 and bar[4] == "Spell_Nature_Drowsy"
            and bar[5] == true and bar[6] == (count >= 4 and "red" or count == 3 and "yellow" or "white")
            and removed == string.format(title, count - 1), context .. ": real Doom timer " .. count)
        checks = checks + 1
        bar = nil
        module.db.profile.doom = false
        module:AfflictionEvent(string.format(message, count))
        assert(not bar, context .. ": disabled Doom must not show a timer")
        module.db.profile.doom = true
        checks = checks + 1
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
    local shatter = "sync MephistrothShackleShatter" .. module.revision .. " "
    local selfShatter = locale == "zhCN" and "你的镣铐碎裂" or "Your Shackle Shatter "
    local otherShatter = locale == "zhCN" and "%s的镣铐碎裂" or "%s's Shackle Shatter "
    local damage = locale == "zhCN" and "击中普通团员造成100点奥术伤害。" or "hits Raider for 100 Arcane damage."
    check(module, selfShatter .. damage, shatter .. "观察者", "CastEvent")
    for _, player in ipairs(names) do
        check(module, string.format(otherShatter, player) .. damage, shatter .. player, "CastEvent")
    end
    check(module, "An unrelated combat log message.", nil, "CastEvent")
    if locale == "zhCN" then
        check(module, "你的挣脱镣铐" .. damage, shatter .. "观察者", "CastEvent")
        check(module, names[1] .. "的挣脱镣铐" .. damage, shatter .. names[1], "CastEvent")
    end
    module.db.profile.shackleshatter = false
    check(module, selfShatter .. damage, nil, "CastEvent")

    for _, case in ipairs({
        {file="Karrsh", zhCN="腐蚀之种", enUS="Seed of Corruption",
            gain="KarrshSeedGain30000 ", fade="KarrshSeedFade30000 ", method="Event"},
        {file="Kronn", zhCN="狂热梦境", enUS="Dream Fever",
            gain="KronnFeverGain30002", fade="KronnFeverFade30002", method="FadeEvent"},
    }) do
        local m = loadModule(case.file, locale, "TMH")
        check(m, string.format(logs[locale].self, case[locale]), "sync " .. case.gain .. "观察者")
        local fade = locale == "zhCN" and case.zhCN .. "效果从%s身上消失了。" or
            case.enUS .. " fades from %s."
        check(m, string.format(fade, locale == "zhCN" and "你" or "you"),
            "sync " .. case.fade .. "观察者", case.method)
        for _, player in ipairs(names) do
            check(m, string.format(logs[locale].other, player, case[locale]),
                "sync " .. case.gain .. player)
            check(m, string.format(fade, player), "sync " .. case.fade .. player, case.method)
        end
    end

    local m = loadModule("Perotharn", locale, "TMH")
    function m:Sound() end
    function m:WarningSign() record("warning") end
    function m:RemoveWarningSign() record("clear") end
    local dirk = locale == "zhCN" and "野蛮短刃" or "Dirk of the Beast"
    local fade = locale == "zhCN" and "野蛮短刃效果从%s身上消失了。" or
        "Dirk of the Beast fades from %s."
    check(m, string.format(logs[locale].self, dirk), "warning", "DamageEvent")
    check(m, string.format(fade, locale == "zhCN" and "你" or "you"), "clear", "FadeEvent")
    for _, player in ipairs(names) do
        check(m, string.format(logs[locale].other, player, dirk), nil, "DamageEvent")
        check(m, string.format(fade, player), nil, "FadeEvent")
    end
    m.db.profile.dirk = false
    check(m, string.format(logs[locale].self, dirk), nil, "DamageEvent")
end
print("PASS: BigWigs self-debuffs: " .. checks .. " handler checks across 9 bosses / 2 locales; " ..
    patternChecks .. " King's Curse pattern-only checks")
