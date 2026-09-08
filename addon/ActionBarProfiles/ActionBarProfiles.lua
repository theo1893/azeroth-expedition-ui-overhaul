-- ActionBarProfiles.lua (WoW 1.12)
-- 经过Sunelgy优化的轻量版本：按需扫描 / 降低Tooltip与拾取操作 / 避免不必要表分配
-- 作者：Sunelgy在原作者基础上优化，武藤纯子酱修复宏逻辑

local ABP_PlayerName = nil
local MAX_ACTIONS = 144

local CMD_SAVE   = "保存"
local CMD_LOAD   = "加载"
local CMD_REMOVE = "删除"
local CMD_LIST   = "列表"

local function hasElements(T)
    if type(T) ~= "table" then return 0 end
    for _ in pairs(T) do
        return 1
    end
    return 0
end

local function ABP_GetTooltipLine1()
    local left, right = nil, nil
    if ABP_TooltipTextLeft1 and ABP_TooltipTextLeft1:IsShown() then
        left = ABP_TooltipTextLeft1:GetText()
    end
    if ABP_TooltipTextRight1 and ABP_TooltipTextRight1:IsShown() then
        right = ABP_TooltipTextRight1:GetText()
    end
    return left, right
end

local function ABP_ComposeSpellKey(name, rankText)
    if not name or name == "" then return nil end
    if rankText and rankText ~= "" then
        return name .. " " .. rankText
    end
    return name
end

local function ABP_PickupMacroByName(macroName, slot)
    if not macroName or macroName == "" then return false end

    -- SMP_Carrier is an implementation detail, never a profile macro. Older
    -- profiles may contain it if a Plus action mapping was temporarily lost.
    if macroName == "SMP_Carrier" then
        macroName = SMP_GetManagedActionName and SMP_GetManagedActionName(slot) or nil
        if not macroName then return false end
    end

    -- Prefer SuperMacroPlus when both addons contain a migrated macro with the
    -- same name. The action text came from the currently active Plus mapping.
    if GetSuperMacroPlusInfo and GetSuperMacroPlusInfo(macroName, "texture") then
        PickupMacro(0, macroName)
        return true
    end
    if GetSuperMacroInfo and GetSuperMacroInfo(macroName, "texture") then
        PickupMacro(0, macroName)
        return true
    end

    local macroIndex = GetMacroIndexByName(macroName)
    if macroIndex and macroIndex > 0 then
        PickupMacro(macroIndex)
        return true
    end
    return false
end

local function ABP_Msg(msg)
    if DEFAULT_CHAT_FRAME and msg then
        DEFAULT_CHAT_FRAME:AddMessage(msg)
    end
end

local ABP_DOITE_PROTECTION_PLAYER = "大斧黑牛 of Basin of Stars"
local ABP_DOITE_PROTECTION_LAYOUT_VERSION = 3
local ABP_DOITE_COMMON_KEYS_VERSION = 2

local function ABP_CopyTable(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do
        result[key] = ABP_CopyTable(child)
    end
    return result
end

local function ABP_ClearActionRange(profile, firstSlot, lastSlot)
    local maps = { profile.spells, profile.macros, profile.items }
    local mapIndex = 1
    while mapIndex <= table.getn(maps) do
        local map = maps[mapIndex]
        local slot = firstSlot
        while slot <= lastSlot do
            map[slot] = nil
            slot = slot + 1
        end
        mapIndex = mapIndex + 1
    end
end

local function ABP_SetMacro(profile, slot, macroName)
    profile.spells[slot] = nil
    profile.items[slot] = nil
    profile.macros[slot] = macroName
end

local ABP_DOITE_WARRIOR_PROFILES = {
    ["武器战"] = true,
    ["狂暴战"] = true,
    ["防战"] = true,
}

local function ABP_FindHighestBattleShoutRank()
    if not GetSpellTabInfo or not GetSpellName then return nil, nil end
    local maxTabs = tonumber(MAX_SKILLLINE_TABS) or 0
    if maxTabs <= 0 then return nil, nil end

    local bestName = nil
    local bestRank = nil
    local bestRankNumber = nil
    local bestBookIndex = nil
    local tab = 1
    while tab <= maxTabs do
        local tabName, _, offset, numSpells = GetSpellTabInfo(tab)
        if tabName then
            local spellIndex = (tonumber(offset) or 0) + 1
            local lastSpell = (tonumber(offset) or 0)
                + (tonumber(numSpells) or 0)
            while spellIndex <= lastSpell do
                local spellName, rankText = GetSpellName(
                    spellIndex,
                    BOOKTYPE_SPELL
                )
                if spellName == "战斗怒吼"
                    or spellName == "Battle Shout" then
                    local _, _, rankNumberText = string.find(
                        rankText or "",
                        "(%d+)"
                    )
                    local rankNumber = tonumber(rankNumberText)
                    local better = not bestName
                        or (rankNumber and (
                            not bestRankNumber
                            or rankNumber > bestRankNumber
                        ))
                        or (not rankNumber
                            and not bestRankNumber
                            and spellIndex > (bestBookIndex or 0))
                    if better then
                        bestName = spellName
                        bestRank = rankText ~= "" and rankText or nil
                        bestRankNumber = rankNumber
                        bestBookIndex = spellIndex
                    end
                end
                spellIndex = spellIndex + 1
            end
        end
        tab = tab + 1
    end
    return bestName, bestRank
end

-- Stored spell actions retain an exact rank. Keep the managed Warrior layouts
-- on the character's current highest Battle Shout so learning a new rank does
-- not make profile switching clear the slot as an "unlearned" old spell.
local function ABP_SyncDoiteBattleShoutRanks(profileName)
    if ABP_PlayerName ~= ABP_DOITE_PROTECTION_PLAYER then return false end
    if profileName and not ABP_DOITE_WARRIOR_PROFILES[profileName] then
        return false
    end

    local spellName, rankText = ABP_FindHighestBattleShoutRank()
    if not spellName then return false end
    local profiles = ABP_Layout and ABP_Layout[ABP_PlayerName]
    if not profiles then return false end

    local changed = false
    for name in pairs(ABP_DOITE_WARRIOR_PROFILES) do
        if not profileName or name == profileName then
            local profile = profiles[name]
            local spells = profile and profile.spells
            if spells then
                for _, info in pairs(spells) do
                    if type(info) == "table"
                        and (info.name == "战斗怒吼"
                            or info.name == "Battle Shout") then
                        if info.name ~= spellName or info.rank ~= rankText then
                            info.name = spellName
                            info.rank = rankText
                            changed = true
                        end
                    end
                end
            end
        end
    end
    return changed
end

local ABP_DOITE_WARRIOR_PROFILES = {
    ["武器战"] = true,
    ["狂暴战"] = true,
    ["防战"] = true,
}

local function ABP_FindHighestBattleShoutRank()
    if not GetSpellTabInfo or not GetSpellName then return nil, nil end
    local maxTabs = tonumber(MAX_SKILLLINE_TABS) or 0
    if maxTabs <= 0 then return nil, nil end

    local bestName = nil
    local bestRank = nil
    local bestRankNumber = nil
    local bestBookIndex = nil
    local tab = 1
    while tab <= maxTabs do
        local tabName, _, offset, numSpells = GetSpellTabInfo(tab)
        if tabName then
            local spellIndex = (tonumber(offset) or 0) + 1
            local lastSpell = (tonumber(offset) or 0)
                + (tonumber(numSpells) or 0)
            while spellIndex <= lastSpell do
                local spellName, rankText = GetSpellName(
                    spellIndex,
                    BOOKTYPE_SPELL
                )
                if spellName == "战斗怒吼"
                    or spellName == "Battle Shout" then
                    local _, _, rankNumberText = string.find(
                        rankText or "",
                        "(%d+)"
                    )
                    local rankNumber = tonumber(rankNumberText)
                    local better = not bestName
                        or (rankNumber and (
                            not bestRankNumber
                            or rankNumber > bestRankNumber
                        ))
                        or (not rankNumber
                            and not bestRankNumber
                            and spellIndex > (bestBookIndex or 0))
                    if better then
                        bestName = spellName
                        bestRank = rankText ~= "" and rankText or nil
                        bestRankNumber = rankNumber
                        bestBookIndex = spellIndex
                    end
                end
                spellIndex = spellIndex + 1
            end
        end
        tab = tab + 1
    end
    return bestName, bestRank
end

-- Stored spell actions retain an exact rank. Keep the managed Warrior layouts
-- on the character's current highest Battle Shout so learning a new rank does
-- not make profile switching clear the slot as an "unlearned" old spell.
local function ABP_SyncDoiteBattleShoutRanks(profileName)
    if ABP_PlayerName ~= ABP_DOITE_PROTECTION_PLAYER then return false end
    if profileName and not ABP_DOITE_WARRIOR_PROFILES[profileName] then
        return false
    end

    local spellName, rankText = ABP_FindHighestBattleShoutRank()
    if not spellName then return false end
    local profiles = ABP_Layout and ABP_Layout[ABP_PlayerName]
    if not profiles then return false end

    local changed = false
    for name in pairs(ABP_DOITE_WARRIOR_PROFILES) do
        if not profileName or name == profileName then
            local profile = profiles[name]
            local spells = profile and profile.spells
            if spells then
                for _, info in pairs(spells) do
                    if type(info) == "table"
                        and (info.name == "战斗怒吼"
                            or info.name == "Battle Shout") then
                        if info.name ~= spellName or info.rank ~= rankText then
                            info.name = spellName
                            info.rank = rankText
                            changed = true
                        end
                    end
                end
            end
        end
    end
    return changed
end

-- Weapon and Fury share these muscle-memory keys. Version 2 also moves
-- Hamstring to Alt-4 and standardizes 4 Sunder / 5 Thunder Clap on every
-- stance page. Taunt, Mocking Blow, defensive cooldowns and = Disarm stay put.
local function ABP_InstallDoiteCommonWarriorKeys()
    if ABP_PlayerName ~= ABP_DOITE_PROTECTION_PLAYER then return end
    local profiles = ABP_Layout[ABP_PlayerName]
    local names = { "武器战", "狂暴战" }
    local nameIndex = 1
    while nameIndex <= table.getn(names) do
        local profile = profiles[names[nameIndex]]
        if profile and tonumber(profile.doiteCommonKeysVersion or 0)
            < ABP_DOITE_COMMON_KEYS_VERSION then
            profile.spells = profile.spells or {}
            profile.macros = profile.macros or {}
            profile.items = profile.items or {}
            ABP_SetMacro(profile, 64, "战士断筋宏")
            ABP_SetMacro(profile, 65, "惩戒切姿态宏")

            local stancePages = { 73, 85, 97 }
            local pageIndex = 1
            while pageIndex <= table.getn(stancePages) do
                ABP_SetMacro(
                    profile,
                    stancePages[pageIndex] + 3,
                    "战士破甲宏"
                )
                ABP_SetMacro(
                    profile,
                    stancePages[pageIndex] + 4,
                    "战士雷霆宏"
                )
                ABP_SetMacro(
                    profile,
                    stancePages[pageIndex] + 11,
                    "战士缴械宏"
                )
                pageIndex = pageIndex + 1
            end
            profile.doiteCommonKeysVersion =
                ABP_DOITE_COMMON_KEYS_VERSION
        end
        nameIndex = nameIndex + 1
    end
end

-- Seed a deterministic shield-tank layout without changing the active bars.
-- The player explicitly applies it with /abp 防战 after login or /reload.
local function ABP_InstallDoiteProtectionProfile()
    if ABP_PlayerName ~= ABP_DOITE_PROTECTION_PLAYER then return end

    local profiles = ABP_Layout[ABP_PlayerName]
    local existing = profiles["防战"]
    local existingVersion = existing
        and tonumber(existing.doiteProtectionLayoutVersion or 0)
        or 0
    if existingVersion >= ABP_DOITE_PROTECTION_LAYOUT_VERSION then
        return
    end

    -- Migrate an installed tank profile in place so its utility bars remain
    -- untouched. A first installation still inherits those bars from DPS.
    local source = existingVersion > 0 and existing
        or profiles["狂暴战"]
        or profiles["武器战"]
        or existing
        or {}
    local profile = ABP_CopyTable(source)
    profile.spells = profile.spells or {}
    profile.macros = profile.macros or {}
    profile.items = profile.items or {}
    ABP_ClearActionRange(profile, 61, 108)

    local stancePages = { 73, 85, 97 }
    local pageIndex = 1
    while pageIndex <= table.getn(stancePages) do
        local base = stancePages[pageIndex]
        profile.macros[base] = "防战单体仇恨宏"
        profile.macros[base + 1] = "防战AOE仇恨宏"
        profile.macros[base + 2] = "战士防御盾挡"
        profile.macros[base + 3] = "防战手动破甲宏"
        profile.macros[base + 4] = "战士缴械宏"
        profile.macros[base + 5] = "防战狂暴之怒宏"
        profile.macros[base + 6] = "防战血性狂怒宏"
        profile.macros[base + 7] = "战士盾击宏"
        profile.macros[base + 8] = "战士破胆怒吼宏"
        profile.macros[base + 9] = "战士援护宏"
        profile.macros[base + 10] = "防战血性狂暴宏"
        profile.macros[base + 11] = "战士雷霆宏"
        pageIndex = pageIndex + 1
    end

    -- Existing character bindings map 61-71 to Alt-1..Alt-G and slot 72 to
    -- Shift-G. Tank Alt-4 holds the infrequent Hamstring; manual Thunder Clap
    -- moves to = because the AoE macro already handles its normal use.
    profile.macros[61] = "战士冲锋开怪宏"
    profile.macros[62] = "战士拦截宏"
    profile.macros[63] = "战士嘲讽切姿态宏"
    profile.macros[64] = "战士断筋宏"
    profile.macros[65] = "惩戒切姿态宏"
    profile.macros[66] = "防战战吼宏"
    profile.macros[67] = "防战挫志宏"
    profile.macros[68] = "战士盾墙宏"
    profile.macros[69] = "战士破釜宏"
    profile.macros[70] = "防战挑战怒吼宏"
    profile.macros[71] = "战士反击风暴宏"
    profile.macros[72] = "战士鲁莽宏"

    profile.doiteProtectionLayoutVersion =
        ABP_DOITE_PROTECTION_LAYOUT_VERSION
    profiles["防战"] = profile
end

local function ABP_TooltipAttach()
    if ABP_Tooltip and ABP_Tooltip.SetOwner then
        ABP_Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    end
end

function ABP_SaveProfile(profileName)
    if not profileName or profileName == "" then return end
    if not ABP_PlayerName then return end
    if not ABP_Layout then ABP_Layout = {} end
    if not ABP_Layout[ABP_PlayerName] then ABP_Layout[ABP_PlayerName] = {} end

    ABP_Layout[ABP_PlayerName][profileName] = {
        spells = {},  -- [slot] = { name=, rank= }
        macros = {},  -- [slot] = macroName
        items  = {},  -- [slot] = itemName
    }

    ABP_TooltipAttach()

    local scStatus = GetCVar("autoSelfCast")
    SetCVar("autoSelfCast", 0)

    for i = 1, MAX_ACTIONS do
        if HasAction(i) then
            local macroName = GetActionText(i)
            if macroName == "SMP_Carrier" then
                macroName = SMP_GetManagedActionName and SMP_GetManagedActionName(i) or nil
            end
            local internalCarrier = SMP_IsCarrierAction and SMP_IsCarrierAction(i)
            if internalCarrier and not macroName then
                -- An orphaned internal carrier has no user action to save.
            elseif macroName and macroName ~= "" then
                ABP_Layout[ABP_PlayerName][profileName].macros[i] = macroName
            else
                ABP_Tooltip:ClearLines()
                ABP_Tooltip:SetAction(i)

                local isSpell = false
                do
                    PickupAction(i)
                    isSpell = CursorHasSpell()
                    PlaceAction(i)
                end

                if isSpell then
                    local spellName, rankText = ABP_GetTooltipLine1()
                    ABP_Layout[ABP_PlayerName][profileName].spells[i] = {
                        name = spellName,
                        rank = rankText, -- 字符串或 nil
                    }
                else
                    local itemName = (select(1, ABP_GetTooltipLine1()))
                    if itemName and itemName ~= "" then
                        ABP_Layout[ABP_PlayerName][profileName].items[i] = itemName
                    end
                end
            end
        end
    end

    SetCVar("autoSelfCast", scStatus)
    ABP_Msg('配置文件 "' .. profileName .. '" 已保存.')
end

local function ABP_BuildNeededSpellMap(neededSpellKeys)
    local result = {}  -- [spellKey] = spellID
    if not neededSpellKeys or not next(neededSpellKeys) then return result end

    local remaining = {}
    local remainingCount = 0
    for key in pairs(neededSpellKeys) do
        remaining[key] = true
        remainingCount = remainingCount + 1
    end

    for tab = 1, MAX_SKILLLINE_TABS do
        local name, _, offset, numSpells = GetSpellTabInfo(tab)
        if not name then break end
        for s = offset + 1, offset + numSpells do
            local n, r = GetSpellName(s, BOOKTYPE_SPELL)
            local key = ABP_ComposeSpellKey(n, (r ~= "" and r or nil))
            if key and remaining[key] then
                result[key] = s
                remaining[key] = nil
                remainingCount = remainingCount - 1
                if remainingCount == 0 then
                    return result
                end
            end
        end
    end
    return result
end

local function ABP_FindItemsInEquipment(neededItems)
    local equipMap = {} -- [itemName] = slotId
    if not neededItems or not next(neededItems) then return equipMap end

    ABP_TooltipAttach()
    local remaining = {}
    local leftCount = 0
    for name in pairs(neededItems) do remaining[name] = true; leftCount = leftCount + 1 end

    for slot = 1, 19 do
        ABP_Tooltip:ClearLines()
        local hasItem = ABP_Tooltip:SetInventoryItem("player", slot)
        if hasItem then
            local itemName = (select(1, ABP_GetTooltipLine1()))
            if itemName and remaining[itemName] then
                equipMap[itemName] = slot
                remaining[itemName] = nil
                leftCount = leftCount - 1
                if leftCount == 0 then
                    break
                end
            end
        end
    end
    return equipMap
end

local function ABP_FindItemsInBags(neededItems)
    local bagMap = {} -- [itemName] = { bag=, slot= }
    if not neededItems or not next(neededItems) then return bagMap end

    ABP_TooltipAttach()
    local remaining = {}
    local leftCount = 0
    for name in pairs(neededItems) do remaining[name] = true; leftCount = leftCount + 1 end

    for bag = 0, NUM_BAG_SLOTS do
        local slots = GetContainerNumSlots(bag)
        if slots and slots > 0 then
            for slot = 1, slots do
                local texture = (select(1, GetContainerItemInfo(bag, slot)))
                if texture then
                    ABP_Tooltip:ClearLines()
                    ABP_Tooltip:SetBagItem(bag, slot)
                    local itemName = (select(1, ABP_GetTooltipLine1()))
                    if itemName and remaining[itemName] then
                        bagMap[itemName] = { bag = bag, slot = slot }
                        remaining[itemName] = nil
                        leftCount = leftCount - 1
                        if leftCount == 0 then
                            return bagMap
                        end
                    end
                end
            end
        end
    end
    return bagMap
end

function ABP_LoadProfile(profileName)
    if not ABP_PlayerName or not ABP_Layout or not ABP_Layout[ABP_PlayerName]
       or not ABP_Layout[ABP_PlayerName][profileName] then
        ABP_Msg('配置文件 "' .. tostring(profileName) .. '" 以前没有保存，无法加载.')
        return
    end

    ABP_SyncDoiteBattleShoutRanks(profileName)
    ABP_SyncDoiteBattleShoutRanks(profileName)
    local profile = ABP_Layout[ABP_PlayerName][profileName]
    local spells = profile.spells or {}
    local macros = profile.macros or {}
    local items  = profile.items  or {}

    local neededSpellKeys = {}
    local neededItemNames = {}

    for slot, info in pairs(spells) do
        local key = ABP_ComposeSpellKey(info.name, info.rank)
        if key then neededSpellKeys[key] = true end
    end
    for slot, itemName in pairs(items) do
        if itemName and itemName ~= "" then neededItemNames[itemName] = true end
    end

    local spellKeyToId   = ABP_BuildNeededSpellMap(neededSpellKeys)
    local equipItemToId  = ABP_FindItemsInEquipment(neededItemNames)

    do
        local remaining = {}
        for name in pairs(neededItemNames) do
            if not equipItemToId[name] then remaining[name] = true end
        end
        var_bagMap = ABP_FindItemsInBags(remaining)
    end
    local bagItemToLoc = var_bagMap or {}

    ABP_TooltipAttach()
    local scStatus = GetCVar("autoSelfCast")
    SetCVar("autoSelfCast", 0)

    for i = 1, MAX_ACTIONS do
        repeat
            local sp = spells[i]
            if sp then
                local key = ABP_ComposeSpellKey(sp.name, sp.rank)
                local sid = key and spellKeyToId[key] or nil
                if not sid then
                    ABP_Msg('法术 "' .. (key or "?") .. '" 目前还没有学会。')
                    if HasAction(i) then PickupAction(i); ClearCursor() end
                    break
                end
                PickupSpell(sid, BOOKTYPE_SPELL)
                PlaceAction(i)
                break
            end

            local mname = macros[i]
            if mname and mname ~= "" then
                local picked = ABP_PickupMacroByName(mname, i)
                if picked then
                    PlaceAction(i)
                end
                if not picked then
                    if HasAction(i) then PickupAction(i); ClearCursor() end
                end
                break
            end

            local iname = items[i]
            if iname and iname ~= "" then
                local eslot = equipItemToId[iname]
                if eslot then
                    PickupInventoryItem(eslot)
                    PlaceAction(i)
                    break
                end
                local loc = bagItemToLoc[iname]
                if loc then
                    PickupContainerItem(loc.bag, loc.slot)
                    PlaceAction(i)
                    break
                end
                if HasAction(i) then PickupAction(i); ClearCursor() end
                break
            end

            if HasAction(i) then PickupAction(i); ClearCursor() end
        until true
    end

    SetCVar("autoSelfCast", scStatus)
    ABP_Msg('配置文件 "' .. profileName .. '" 已加载.')
end

-- One-time, character-scoped layout requested for 冠军水管.  The Alt row is
-- fixed at slots 61-72; the three Warrior stance pages start at 73, 85 and 97.
-- Clear the whole owned range first so stale consumables cannot survive in an
-- unspecified button.
local ABP_CHAMPION_LAYOUT_PLAYER = "冠军水管 of Basin of Stars"
local ABP_CHAMPION_LAYOUT_VERSION = 1
local ABP_CHAMPION_LAYOUT_MARKER = "__championUnifiedWarriorLayoutVersion"
local ABP_CHAMPION_LAYOUT_BACKUP = "冠军水管-统一布局前"
local ABP_CHAMPION_STANCE_STARTS = { 73, 85, 97 }
local ABP_CHAMPION_ALT_MACROS = {
    [61] = "战士冲拦援宏",       -- Alt+1
    [62] = "战士缴械宏",         -- Alt+2
    [63] = "战士断筋宏",         -- Alt+3
    [66] = "战士盾墙宏",         -- Alt+Q
    [67] = "防战挑战怒吼宏",     -- Alt+E
    [68] = "防战狂暴之怒宏",     -- Alt+R
}
local ABP_CHAMPION_STANCE_MACROS = {
    [0]  = "狂暴单体宏",         -- 1
    [1]  = "狂暴aoe宏",          -- 2
    [3]  = "战士破甲宏",         -- 4
    [5]  = "战士破釜宏",         -- Q
    [6]  = "战士嘲讽切姿态宏",   -- E
    [7]  = "战士打断宏",         -- R
    [8]  = "战士破胆怒吼宏",     -- T
    [9]  = "惩戒切姿态宏",       -- F
    [10] = "防战血性狂暴宏",     -- G
}

local function ABP_FindHighestSpellBookEntry(primaryName, fallbackName)
    if not GetSpellTabInfo or not GetSpellName then return nil end
    local maxTabs = tonumber(MAX_SKILLLINE_TABS) or 0
    if maxTabs <= 0 then return nil end

    local bestIndex, bestRankNumber = nil, nil
    local tab = 1
    while tab <= maxTabs do
        local tabName, _, offset, numSpells = GetSpellTabInfo(tab)
        if tabName then
            local spellIndex = (tonumber(offset) or 0) + 1
            local lastSpell = (tonumber(offset) or 0)
                + (tonumber(numSpells) or 0)
            while spellIndex <= lastSpell do
                local spellName, rankText = GetSpellName(
                    spellIndex,
                    BOOKTYPE_SPELL
                )
                if spellName == primaryName or spellName == fallbackName then
                    local _, _, rankNumberText = string.find(
                        rankText or "",
                        "(%d+)"
                    )
                    local rankNumber = tonumber(rankNumberText)
                    local better = not bestIndex
                        or (rankNumber and (
                            not bestRankNumber
                            or rankNumber > bestRankNumber
                        ))
                        or (not rankNumber
                            and not bestRankNumber
                            and spellIndex > bestIndex)
                    if better then
                        bestIndex = spellIndex
                        bestRankNumber = rankNumber
                    end
                end
                spellIndex = spellIndex + 1
            end
        end
        tab = tab + 1
    end
    return bestIndex
end

local function ABP_ChampionMacroExists(macroName)
    if GetSuperMacroPlusInfo
       and GetSuperMacroPlusInfo(macroName, "texture") then
        return true
    end
    if GetSuperMacroInfo and GetSuperMacroInfo(macroName, "texture") then
        return true
    end
    local macroIndex = GetMacroIndexByName(macroName)
    return macroIndex and macroIndex > 0
end

local function ABP_CollectChampionMissingMacros()
    local missing, seen = {}, {}
    local function check(macroName)
        if not seen[macroName] then
            seen[macroName] = true
            if not ABP_ChampionMacroExists(macroName) then
                table.insert(missing, macroName)
            end
        end
    end
    for _, macroName in pairs(ABP_CHAMPION_ALT_MACROS) do
        check(macroName)
    end
    for _, macroName in pairs(ABP_CHAMPION_STANCE_MACROS) do
        check(macroName)
    end
    return missing
end

local function ABP_ClearChampionAction(slot)
    if HasAction(slot) then
        PickupAction(slot)
        ClearCursor()
    end
    if type(SMP_ACTION) == "table" then
        SMP_ACTION[slot] = nil
    end
end

local function ABP_PlaceChampionMacro(slot, macroName)
    if not ABP_PickupMacroByName(macroName, slot) then
        ClearCursor()
        return false
    end
    PlaceAction(slot)
    ClearCursor()
    if SMP_GetManagedActionName then
        return SMP_GetManagedActionName(slot) == macroName
    end
    return GetActionText(slot) == macroName
end

local function ABP_ApplyChampionUnifiedWarriorLayout()
    if ABP_PlayerName ~= ABP_CHAMPION_LAYOUT_PLAYER then return "skip" end
    if type(ABP_Layout) ~= "table" then return "skip" end
    if tonumber(ABP_Layout[ABP_CHAMPION_LAYOUT_MARKER] or 0)
       >= ABP_CHAMPION_LAYOUT_VERSION then
        return "skip"
    end
    if UnitAffectingCombat and UnitAffectingCombat("player") then
        return "combat"
    end

    local executeSpellId = ABP_FindHighestSpellBookEntry("斩杀", "Execute")
    local missingMacros = ABP_CollectChampionMissingMacros()
    if not executeSpellId or table.getn(missingMacros) > 0 then
        local missingNames = table.concat(missingMacros, "、")
        if not executeSpellId then
            if missingNames ~= "" then missingNames = missingNames .. "、" end
            missingNames = missingNames .. "斩杀"
        end
        ABP_Msg("ActionBarProfiles: 统一战士布局未执行；未找到：" .. missingNames .. ".")
        return "missing"
    end

    local profiles = ABP_Layout[ABP_PlayerName]
    if type(profiles) == "table"
       and not profiles[ABP_CHAMPION_LAYOUT_BACKUP] then
        ABP_SaveProfile(ABP_CHAMPION_LAYOUT_BACKUP)
    end

    local scStatus = GetCVar("autoSelfCast")
    local expected, placed = 0, 0
    SetCVar("autoSelfCast", 0)
    ClearCursor()

    for slot = 61, 108 do
        ABP_ClearChampionAction(slot)
    end
    if SMP_RebuildActionRecovery then SMP_RebuildActionRecovery() end

    for slot, macroName in pairs(ABP_CHAMPION_ALT_MACROS) do
        expected = expected + 1
        if ABP_PlaceChampionMacro(slot, macroName) then
            placed = placed + 1
        end
    end

    local page = 1
    while page <= table.getn(ABP_CHAMPION_STANCE_STARTS) do
        local startSlot = ABP_CHAMPION_STANCE_STARTS[page]
        for offset, macroName in pairs(ABP_CHAMPION_STANCE_MACROS) do
            expected = expected + 1
            if ABP_PlaceChampionMacro(startSlot + offset, macroName) then
                placed = placed + 1
            end
        end

        expected = expected + 1
        PickupSpell(executeSpellId, BOOKTYPE_SPELL)
        PlaceAction(startSlot + 2)
        ClearCursor()
        if HasAction(startSlot + 2) then placed = placed + 1 end
        page = page + 1
    end

    if SMP_RebuildActionRecovery then SMP_RebuildActionRecovery() end
    SetCVar("autoSelfCast", scStatus)

    if placed == expected then
        ABP_Layout[ABP_CHAMPION_LAYOUT_MARKER] =
            ABP_CHAMPION_LAYOUT_VERSION
        ABP_Msg("ActionBarProfiles: 已应用冠军水管统一战士布局：" .. placed .. "/" .. expected .. ".")
        return "done"
    end

    ABP_Msg("ActionBarProfiles: 统一战士布局只写入 " .. placed .. "/" .. expected .. "；请 /reload 重试。")
    return "missing"
end

function ABP_ListProfiles()
    if not ABP_PlayerName or not ABP_Layout or not ABP_Layout[ABP_PlayerName]
       or hasElements(ABP_Layout[ABP_PlayerName]) == 0 then
        ABP_Msg("你没有为这个人物保存的配置文件.")
        return
    end
    ABP_Msg("这个人物的配置文件有:")
    for profileName in pairs(ABP_Layout[ABP_PlayerName]) do
        ABP_Msg(profileName)
    end
end

function ABP_RemoveProfile(profileName)
    if not ABP_PlayerName or not ABP_Layout
       or not ABP_Layout[ABP_PlayerName]
       or not ABP_Layout[ABP_PlayerName][profileName] then
        ABP_Msg("你没有配置文件 '" .. tostring(profileName) .. "' 保存在这个人物上.")
        return
    end
    ABP_Layout[ABP_PlayerName][profileName] = nil
    ABP_Msg("配置文件 '" .. profileName .. "' 已经删除.")
end

function ABP_OnLoad()
    this:RegisterEvent("VARIABLES_LOADED")
    this:RegisterEvent("PLAYER_ENTERING_WORLD")
    SLASH_ABP1 = "/ABP"
    SlashCmdList["ABP"] = function(msg) ABP_SlashCommand(msg or "") end
end

function ABP_OnEvent()
    if event == "VARIABLES_LOADED" then
        ABP_PlayerName = UnitName("player") .. " of " .. GetCVar("realmName")

        if not ABP_Layout then ABP_Layout = {} end
        if not ABP_Layout[ABP_PlayerName] then ABP_Layout[ABP_PlayerName] = {} end

        ABP_InstallDoiteCommonWarriorKeys()
        ABP_InstallDoiteProtectionProfile()
        ABP_SyncDoiteBattleShoutRanks()
        ABP_SyncDoiteBattleShoutRanks()

        if ABP_ButtonPosition == nil then ABP_ButtonPosition = 60 end

        UIDropDownMenu_Initialize(getglobal("ABP_DropDownMenu"), ABP_DropDownMenu_OnLoad, "MENU")
        ABPButton_UpdatePosition()
    elseif event == "PLAYER_ENTERING_WORLD" then
        local result = ABP_ApplyChampionUnifiedWarriorLayout()
        if result == "combat" then this:RegisterEvent("PLAYER_REGEN_ENABLED") end
    elseif event == "PLAYER_REGEN_ENABLED" then
        this:UnregisterEvent("PLAYER_REGEN_ENABLED")
        ABP_ApplyChampionUnifiedWarriorLayout()
    end
end

function ABP_SlashCommand(msg)
    msg = msg or ""
    if msg == "" then
        ABP_Msg("ActionBarProfiles, 由Kronos的<Vanguard>制作, 60addons汉化")
        ABP_Msg("/abp 保存 [配置文件名字]")
        ABP_Msg("/abp 加载 [配置文件名字]")
        ABP_Msg("/abp 删除 [配置文件名字]")
        ABP_Msg("/abp 列表")
        return
    end

    for profileName in string.gfind(msg, CMD_SAVE .. " (.*)") do
        ABP_SaveProfile(profileName)
        return
    end
    for profileName in string.gfind(msg, CMD_LOAD .. " (.*)") do
        ABP_LoadProfile(profileName)
        return
    end
    for profileName in string.gfind(msg, CMD_REMOVE .. " (.*)") do
        ABP_RemoveProfile(profileName)
        return
    end
    if string.find(msg, CMD_LIST, 1, true) then
        ABP_ListProfiles()
        return
    end
end

function ABP_DropDownMenu_OnLoad()
    if UIDROPDOWNMENU_MENU_VALUE == "Delete menu" then
        UIDropDownMenu_AddButton({
            text = "选择要删除的布局",
            isTitle = true,
            owner = this:GetParent(),
            justifyH = "CENTER",
        }, UIDROPDOWNMENU_MENU_LEVEL)

        local list = ABP_Layout and ABP_Layout[ABP_PlayerName] or nil
        if list then
            for profileName in pairs(list) do
                UIDropDownMenu_AddButton({
                    text = profileName,
                    value = profileName,
                    func = function() ABP_RemoveProfile(this:GetText()) end,
                    notCheckable = 1,
                    owner = this:GetParent(),
                }, UIDROPDOWNMENU_MENU_LEVEL)
            end
        end
        return
    end

    UIDropDownMenu_AddButton({
        text = UnitName("player") .. "的动作条",
        isTitle = true,
        owner = this:GetParent(),
        justifyH = "CENTER",
    }, UIDROPDOWNMENU_MENU_LEVEL)

    local list = ABP_Layout and ABP_Layout[ABP_PlayerName] or nil
    if list then
        for profileName in pairs(list) do
            UIDropDownMenu_AddButton({
                text = profileName,
                func = function() ABP_LoadProfile(this:GetText()) end,
                notCheckable = 1,
                owner = this:GetParent(),
            }, UIDROPDOWNMENU_MENU_LEVEL)
        end
    end

    UIDropDownMenu_AddButton({
        text = "选项",
        isTitle = true,
        justifyH = "CENTER",
    }, UIDROPDOWNMENU_MENU_LEVEL)

    UIDropDownMenu_AddButton({
        text = "保存当前动作条的布局",
        func = function() StaticPopup_Show("ABP_NewProfile") end,
        notCheckable = 1,
        owner = this:GetParent(),
    }, UIDROPDOWNMENU_MENU_LEVEL)

    UIDropDownMenu_AddButton({
        text = "删除一个布局",
        value = "Delete menu",
        notCheckable = 1,
        hasArrow = true,
    }, UIDROPDOWNMENU_MENU_LEVEL)
end

local ABP_ButtonRadius = 78

function ABPButton_UpdatePosition()
    ActionBarProfiles_IconFrame:SetPoint(
        "TOPLEFT", "Minimap", "TOPLEFT",
        54 - (ABP_ButtonRadius * cos(ABP_ButtonPosition)),
        (ABP_ButtonRadius * sin(ABP_ButtonPosition)) - 55
    )
end

function ABPButton_BeingDragged()
    local xpos, ypos = GetCursorPosition()
    local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
    xpos = xmin - xpos / UIParent:GetScale() + 70
    ypos = ypos / UIParent:GetScale() - ymin - 70
    ABPButton_SetPosition(math.deg(math.atan2(ypos, xpos)))
end

function ABPButton_SetPosition(v)
    if v < 0 then v = v + 360 end
    ABP_ButtonPosition = v
    ABPButton_UpdatePosition()
end

StaticPopupDialogs["ABP_NewProfile"] = {
    text = "为当前动作条保存输入一个名称",
    button1 = SAVE,
    button2 = CANCEL,
    OnAccept = function()
        local profileName = getglobal(this:GetParent():GetName() .. "EditBox"):GetText()
        ABP_SaveProfile(profileName)
        getglobal(this:GetParent():GetName() .. "EditBox"):SetText("")
    end,
    EditBoxOnEnterPressed = function()
        local profileName = this:GetText()
        ABP_SaveProfile(profileName)
        this:SetText("")
        this:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    hasEditBox = true,
    preferredIndex = 3,
}

-- ---------------------------------------------------------------------------
-- Manual warrior profile shortcut
--
-- ActionBarProfiles does not change active bars during login. The shortcuts
-- below explicitly load one of the player's saved warrior layouts.
-- ---------------------------------------------------------------------------

local ABP_OriginalSlashCommand = ABP_SlashCommand
function ABP_SlashCommand(msg)
    msg = msg or ""
    if msg == "武器战" then
        ABP_LoadProfile("武器战")
        return
    elseif msg == "狂暴战" then
        ABP_LoadProfile("狂暴战")
        return
    elseif msg == "防战" then
        ABP_LoadProfile("防战")
        return
    end

    ABP_OriginalSlashCommand(msg)
    if msg == "" then
        ABP_Msg("/abp 武器战|狂暴战|防战 － 手动加载对应方案")
    end
end
