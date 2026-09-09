-- Run from repository root: lua tools/test_anomalus_overload.lua
local module, L = {}, {}
local locale, sent
function L:RegisterTranslations(language, factory)
    if language == locale then
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
print("PASS: Anomalus bomb names, stack payloads and fade-name matching")
