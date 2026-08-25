-- Standalone check for the non-destructive Protection action-bar installer.
-- Run from the AddOns directory with:
-- lua DoiteDPS/Tests/ActionBarProtection_spec.lua

if not table.getn then
    table.getn = function(value) return #value end
end

StaticPopupDialogs = {}
SlashCmdList = {}
SAVE = "save"
CANCEL = "cancel"

function UnitName() return "大斧黑牛" end
function GetCVar(key)
    if key == "realmName" then return "Basin of Stars" end
    return "0"
end
function UIDropDownMenu_Initialize() end
function getglobal() return {} end
function cos() return 0 end
function sin() return 0 end

MAX_SKILLLINE_TABS = 1
BOOKTYPE_SPELL = "spell"
local spellBook = {
    { "战斗怒吼", "等级 1" },
    { "战斗怒吼", "等级 2" },
    { "战斗怒吼", "等级 3" },
    { "战斗怒吼", "等级 4" },
    { "战斗怒吼", "等级 5" },
    { "战斗怒吼", "等级 6" },
}
function GetSpellTabInfo(tab)
    if tab == 1 then return "武器", nil, 0, #spellBook end
    return nil
end
function GetSpellName(index)
    local entry = spellBook[index]
    if entry then return entry[1], entry[2] end
    return nil
end

ActionBarProfiles_IconFrame = {
    SetPoint = function() end,
}

ABP_Layout = {
    ["大斧黑牛 of Basin of Stars"] = {
        ["狂暴战"] = {
            items = { [111] = "炉石" },
            spells = {
                [13] = { name = "战斗怒吼", rank = "等级 5" },
                [33] = { name = "优质治疗药水" },
                [64] = { name = "雷霆一击" },
                [65] = { name = "缴械" },
                [66] = { name = "战斗怒吼", rank = "等级 5" },
                [75] = { name = "旧斩杀" },
                [76] = { name = "断筋" },
                [77] = { name = "破甲攻击" },
                [88] = { name = "断筋" },
                [89] = { name = "破甲攻击" },
                [100] = { name = "断筋" },
                [101] = { name = "破甲攻击" },
            },
            macros = {
                [73] = "狂暴单体宏",
                [74] = "狂暴aoe宏",
            },
            doiteLayoutVersion = 3,
        },
        ["武器战"] = {
            items = { [111] = "炉石" },
            spells = {
                [13] = { name = "战斗怒吼", rank = "等级 5" },
                [33] = { name = "优质治疗药水" },
                [64] = { name = "雷霆一击" },
                [65] = { name = "缴械" },
                [66] = { name = "战斗怒吼", rank = "等级 5" },
                [75] = { name = "旧斩杀" },
                [76] = { name = "断筋" },
                [77] = { name = "破甲攻击" },
                [88] = { name = "断筋" },
                [89] = { name = "破甲攻击" },
                [100] = { name = "断筋" },
                [101] = { name = "破甲攻击" },
            },
            macros = {
                [73] = "武器单体宏",
                [74] = "武器aoe宏",
            },
            doiteLayoutVersion = 3,
        },
        ["防战"] = {
            items = {
                [111] = "炉石",
                [112] = "盾T自定义物品",
            },
            spells = {
                [13] = { name = "战斗怒吼", rank = "等级 5" },
                [33] = { name = "优质治疗药水" },
            },
            macros = { [73] = "旧防战宏" },
            doiteProtectionLayoutVersion = 2,
        },
    },
}

dofile("ActionBarProfiles/ActionBarProfiles.lua")

event = "VARIABLES_LOADED"
ABP_OnEvent()

local profile = ABP_Layout["大斧黑牛 of Basin of Stars"]["防战"]
assert(profile.doiteProtectionLayoutVersion == 3, "layout version missing")
assert(profile.items[111] == "炉石", "shared item bar was not preserved")
assert(profile.items[112] == "盾T自定义物品", "tank utility bar was not preserved")
assert(profile.spells[33].name == "优质治疗药水", "shared utility slot was not preserved")
assert(profile.spells[13].rank == "等级 6", "Protection Battle Shout rank was not upgraded")
assert(profile.spells[75] == nil, "old stance spell was not cleared")

local pages = { 73, 85, 97 }
local dpsProfiles = {
    ABP_Layout["大斧黑牛 of Basin of Stars"]["武器战"],
    ABP_Layout["大斧黑牛 of Basin of Stars"]["狂暴战"],
}
local dpsIndex = 1
while dpsIndex <= #dpsProfiles do
    local dps = dpsProfiles[dpsIndex]
    assert(dps.doiteCommonKeysVersion == 2, "common-key version missing")
    assert(dps.spells[13].rank == "等级 6", "shared Battle Shout rank mismatch")
    assert(dps.spells[66].rank == "等级 6", "Alt-Q Battle Shout rank mismatch")
    assert(dps.spells[64] == nil, "old Alt-4 Thunder Clap was not cleared")
    assert(dps.macros[64] == "战士断筋宏", "Alt-4 Hamstring mismatch")
    assert(dps.spells[65] == nil, "old Alt-5 Disarm was not cleared")
    assert(dps.macros[65] == "惩戒切姿态宏", "Alt-5 Mocking Blow mismatch")

    local dpsPageIndex = 1
    while dpsPageIndex <= #pages do
        local base = pages[dpsPageIndex]
        assert(dps.macros[base + 3] == "战士破甲宏", "DPS 4 Sunder mismatch")
        assert(dps.spells[base + 3] == nil, "old DPS 4 spell was not cleared")
        assert(dps.macros[base + 4] == "战士雷霆宏", "DPS 5 Thunder Clap mismatch")
        assert(dps.spells[base + 4] == nil, "old DPS 5 spell was not cleared")
        assert(dps.macros[base + 11] == "战士缴械宏", "DPS = Disarm mismatch")
        dpsPageIndex = dpsPageIndex + 1
    end
    dpsIndex = dpsIndex + 1
end

local expectedPage = {
    [0] = "防战单体仇恨宏",
    [1] = "防战AOE仇恨宏",
    [2] = "战士防御盾挡",
    [3] = "防战手动破甲宏",
    [4] = "战士缴械宏",
    [5] = "防战狂暴之怒宏",
    [6] = "防战血性狂怒宏",
    [7] = "战士盾击宏",
    [8] = "战士破胆怒吼宏",
    [9] = "战士援护宏",
    [10] = "防战血性狂暴宏",
    [11] = "战士雷霆宏",
}
local index = 1
while index <= #pages do
    local base = pages[index]
    local offset = 0
    while offset <= 11 do
        assert(
            profile.macros[base + offset] == expectedPage[offset],
            "stance page mismatch at offset " .. offset
        )
        offset = offset + 1
    end
    index = index + 1
end

assert(profile.macros[61] == "战士冲锋开怪宏", "Alt-1 Charge mismatch")
assert(profile.macros[62] == "战士拦截宏", "Alt-2 Intercept mismatch")
assert(profile.macros[63] == "战士嘲讽切姿态宏", "Alt-3 Taunt mismatch")
assert(profile.macros[64] == "战士断筋宏", "Alt-4 Hamstring mismatch")
assert(profile.macros[65] == "惩戒切姿态宏", "Alt-5 Mocking Blow mismatch")
assert(profile.macros[66] == "防战战吼宏", "Alt-Q Battle Shout mismatch")
assert(profile.macros[67] == "防战挫志宏", "Alt-E Demo Shout mismatch")
assert(profile.macros[68] == "战士盾墙宏", "Alt-R Shield Wall mismatch")
assert(profile.macros[69] == "战士破釜宏", "Alt-F Last Stand mismatch")
assert(profile.macros[70] == "防战挑战怒吼宏", "Alt-T Challenging Shout mismatch")
assert(profile.macros[71] == "战士反击风暴宏", "Alt-G Retaliation mismatch")
assert(profile.macros[72] == "战士鲁莽宏", "Shift-G Recklessness mismatch")

local hasExecute = false
local slot = 61
while slot <= 108 do
    if profile.macros[slot] == "战士手动斩杀宏"
        or (profile.spells[slot] and profile.spells[slot].name == "斩杀") then
        hasExecute = true
        break
    end
    slot = slot + 1
end
assert(not hasExecute, "Protection action bar must not contain Execute")

profile.macros[73] = "玩家自定义"
ABP_OnEvent()
assert(
    profile.macros[73] == "玩家自定义",
    "versioned installer overwrote an already-installed layout"
)

local macroSource = assert(io.open("SuperMacroPlus/SuperMacroPlus.lua", "rb"))
local macroText = macroSource:read("*a")
macroSource:close()
local provisionedNames = {
    "防战单体仇恨宏",
    "防战AOE仇恨宏",
    "防战手动破甲宏",
    "战士破甲宏",
    "战士防御盾挡",
    "战士手动斩杀宏",
    "防战挫志宏",
    "防战战吼宏",
    "防战挑战怒吼宏",
    "防战血性狂暴宏",
    "防战狂暴之怒宏",
    "防战血性狂怒宏",
    "防战缴械宏",
    "战士断筋宏",
    "战士破胆怒吼宏",
    "战士缴械宏",
}
index = 1
while index <= #provisionedNames do
    assert(
        string.find(macroText, provisionedNames[index], 1, true),
        "missing provisioned macro " .. provisionedNames[index]
    )
    index = index + 1
end

assert(
    string.find(macroText, "/cast [stance:2] 盾牌格挡", 1, true),
    "Shield Block macro must cast only after reaching Defensive Stance"
)

assert(
    string.find(
        macroText,
        "/run DoiteDPS_Execute(\\\"single\\\")\\n/startattack",
        1,
        true
    ),
    "managed single-target macro must resolve the DDPS target before auto attack"
)
assert(
    string.find(
        macroText,
        "/run DoiteDPS_Execute(\\\"aoe\\\")\\n/startattack",
        1,
        true
    ),
    "managed AOE macro must resolve the DDPS target before auto attack"
)

print("ActionBarProtection_spec: 119 checks passed")
