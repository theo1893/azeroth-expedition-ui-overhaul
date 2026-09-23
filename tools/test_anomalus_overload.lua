-- Run from repository root: lua tools/test_anomalus_overload.lua
local module, L = {}, {}
local locale, sent
function L:RegisterTranslations(language, factory)
    if language == "enUS" or language == locale then
        for key, value in pairs(factory()) do self[key] = value end
    end
end
BigWigs = { ModuleDeclaration = function() return module, L end }
function AceLibrary()
    return setmetatable({ new = function() return {} end }, {
        __index = function(_, key) return key end,
    })
end
function UnitName() return "观察者" end
function GetTime() return 100 end
function module:Sync(message) sent = message end
local function check(message, player)
    sent = nil
    module:AfflictionEvent(message)
    assert(sent == "AnomalusArcaneOverload30000 " .. player, message .. ": " .. tostring(sent))
end
for _, language in ipairs({ "zhCN", "enUS" }) do
    locale = language
    dofile("addon/BigWigs/Raids/Karazhan/Anomalus.lua")
    check(language == "zhCN" and "你受到了奥术超载效果的影响。" or
        "You are afflicted by Arcane Overload.", "观察者")
    for _, player in ipairs({ "李哥保护你", "李哥守护你", "普通团员", "NotYou" }) do
        check(player .. (language == "zhCN" and "受到了奥术超载效果的影响。" or
            " is afflicted by Arcane Overload."), player)
    end

    local stackLogs = language == "zhCN" and {
        {"观察者受到了法力束缚打击效果的影响(3)", "观察者", "3"},
        {"你受到了法力束缚打击效果的影响（7）。", "观察者", "7"},
        {"李哥保护你受到了法力束缚打击效果的影响 (12)。", "李哥保护你", "12"},
    } or {
        {"Observer is afflicted by Manabound Strikes (3).", "Observer", "3"},
        {"You are afflicted by Manabound Strikes (7).", "观察者", "7"},
        {"NotYou is afflicted by Manabound Strikes (12).", "NotYou", "12"},
    }
    for _, entry in ipairs(stackLogs) do
        sent = nil
        module:AfflictionEvent(entry[1])
        assert(sent == "AnomalusManaboundStrike30000 " .. entry[2] .. " " .. entry[3],
            "stack log: " .. entry[1] .. " => " .. tostring(sent))
    end
    sent = nil
    module:AfflictionEvent(language == "zhCN" and "法力束缚打击击中观察者造成300点伤害。" or
        "Manabound Strikes hits Observer for 300 damage.")
    assert(sent == nil, "damage must not become a stack gain")

    local bar
    module.db = {profile = {manaboundstrike = true}}
    function module:Bar(text, duration) bar = {text, duration} end
    function module:RemoveBar() bar = nil end
    module:BigWigs_RecvSync("AnomalusManaboundStrike30000", "观察者 3")
    assert(bar and bar[1] == L.bar_manaboundExpire and bar[2] == 60,
        "own stacks show the 60-second expiry bar")
    module:BigWigs_RecvSync("AnomalusManaboundStrikeFade30000", language == "zhCN" and "你" or "you")
    assert(bar == nil, "self fade resolves to the real player and removes the expiry bar")

    local received
    module.ManaboundStrike = function(_, player, count) received = player .. " " .. count end
    for _, payload in ipairs({ "李哥保护你 1", "李哥守护你 12" }) do
        module:BigWigs_RecvSync("AnomalusManaboundStrike30000", payload)
        assert(received == payload)
    end
    received = nil
    module:BigWigs_RecvSync("AnomalusManaboundStrike30000", "bad payload")
    module:BigWigs_RecvSync("AnomalusManaboundStrike30000Extra", "Player 2")
    assert(received == nil)
    if language == "enUS" then
        module:CHAT_MSG_SPELL_AURA_GONE_OTHER("Manabound Strikes fades from Player1.")
        assert(sent == "AnomalusManaboundStrikeFade30000 Player1")
        module:CHAT_MSG_SPELL_AURA_GONE_OTHER("Arcane Dampening fades from Player2.")
        assert(sent == "AnomalusArcaneDampeningFade30000 Player2")
    end
end
print("PASS: Anomalus bomb names, localized stack logs, expiry bars and fade-name matching")
