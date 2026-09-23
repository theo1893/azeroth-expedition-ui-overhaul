-- Run from repository root: lua tools/test_bigwigs_missing_units.lua
-- The client rejects made-up unit tokens instead of treating them as missing units.
local current, bossUnit, health, bars, messages, lastCastUnit
function UnitName() return "CityTester" end
function UnitClass() return "Warrior", "WARRIOR" end
function GetTime() return 100 end
function SendChatMessage() end
function UnitExists(unit)
    assert(unit == "target", "invalid unit token: " .. tostring(unit))
    return bossUnit ~= nil
end
function AceLibrary()
    return setmetatable({new = function() return {} end}, {
        __index = function(_, key) return key end,
    })
end
BigWigs = {}
function BigWigs:GetUnitIdByName() return bossUnit end
function BigWigs:GetHealthPercent(unit, round)
    if not unit then return end
    assert(UnitExists(unit), "missing live target")
    return health and (round and math.floor(health) or health)
end
function BigWigs:GetCastTimeCoefficient(unit)
    if unit then assert(UnitExists(unit)) end
    lastCastUnit = unit
    return 1
end
function BigWigs:ModuleDeclaration()
    local module, L = {}, {}
    function L:RegisterTranslations(locale, factory)
        if locale == "enUS" or locale == "zhCN" then
            for key, value in pairs(factory()) do L[key] = value end
        end
    end
    function module:RegisterYellEngage() end
    function module:Message(text) messages[text] = true end
    function module:Bar(text, duration) bars[text] = duration end
    function module:RemoveBar(text) bars[text] = nil end
    function module:CancelDelayedBar() end
    function module:DelayedIntervalBar() end
    function module:Sound() end
    function module:SetRaidTargetForPlayer() end
    function module:RestorePreviousRaidTargetForPlayer() end
    current = module
    return module, L
end

dofile("addon/BigWigs/Raids/Karazhan/Rupturan.lua")
local rupturan = current
rupturan.db = {profile = rupturan.defaultDB}
for _, outcome in ipairs({"投掷巨石没有击中", "投掷巨石击中"}) do
    bars, messages = {}, {}
    rupturan:OnEngage()
    assert(rupturan:GetHealth() == 100, "no boss keeps the existing inactive health fallback")
    rupturan:ThrowBoulder("CityTester")
    rupturan:ThrowBoulderOutcome(outcome)
    assert(not bars["机会窗口"], "no boss must not produce a low-health kill window")
end
rupturan:IgniteEarth()
assert(lastCastUnit == nil, "cast-time lookup receives no invented unit token")

bossUnit, health = "target", 14.9
bars, messages = {}, {}
rupturan:OnEngage()
assert(rupturan:GetHealth() == 14)
rupturan:ThrowBoulder("CityTester")
assert(bars["机会窗口"] == 1.7, "real low-health boss still warns before a living stone spawns")
rupturan:ThrowBoulderOutcome("投掷巨石没有击中")
assert(bars["机会窗口"] == 18, "miss still opens the low-health kill window")
rupturan:ThrowBoulder("CityTester")
rupturan:ThrowBoulderOutcome("投掷巨石击中")
assert(not bars["机会窗口"], "hit still closes the kill window")
health = nil
assert(rupturan:GetHealth() == 100, "unavailable health keeps the safe fallback")

bossUnit, health = nil, nil
for _, file in ipairs({"Incantagos", "SanvTasdal"}) do
    dofile("addon/BigWigs/Raids/Karazhan/" .. file .. ".lua")
    current.db = {profile = current.defaultDB}
    current:OnSetup()
    bars, messages = {}, {}
    current:CheckBossHealth()
    assert(next(messages) == nil, file .. " must not invent a health threshold without a boss")
end
print("PASS: missing boss units, boulder outcomes and real low-health opportunity windows")
