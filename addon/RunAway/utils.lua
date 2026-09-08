if RunAway.disabled then
    return
end

local utils = {}

-- ============================================================================
-- Arcane Overload tracking for Arcane Dampening timing
-- Stores timestamp when arcaneoverload detected, used to calculate dampening window
-- ============================================================================
utils.arcaneOverloadHistory = {}  -- [unitName] = timestamp when overload detected

-- ============================================================================
-- InTheCircle tracking for circle detection during Anomalus fight
-- Stores timestamp when inthecircle detected (exactly 1 debuff, not 2 like overload)
-- ============================================================================
utils.inTheCircleHistory = {}  -- [unitName] = timestamp when in-the-circle detected

-- ============================================================================
-- Kruul Mark of the Highlord tracking
-- Uses exact combat-log messages instead of the shared aura icon.
-- ============================================================================
utils.kruulMarkHistory = {}  -- [unitName] = timestamp when the mark was applied

-- ============================================================================
-- King encounter aura tracking
-- Charming Presence is shown as mind control; Dark Subservience as kneeling.
-- ============================================================================
utils.kingAuraHistory = {
    ["shadowworddominate"] = {},
    ["brokenheart"] = {},
}

-- ============================================================================
-- Aura timer tracking for remaining time calculation
-- Stores timestamp when aura first detected: [guid][auraId] = startTime
-- ============================================================================
utils.auraTimers = {}

-- Stores previous aura ranks to detect increases: [guid][auraId] = previousRank
-- ============================================================================
utils.auraRanks = {}

-- Reset Arcane Overload tracking (called when boss combat ends)
utils.ResetArcaneOverloadHistory = function()
    utils.arcaneOverloadHistory = {}
end

-- Reset InTheCircle tracking (called when boss combat ends)
utils.ResetInTheCircleHistory = function()
    utils.inTheCircleHistory = {}
end

-- Reset Kruul Mark of the Highlord tracking (called when boss combat ends)
utils.ResetKruulMarkHistory = function()
    utils.kruulMarkHistory = {}
end

-- Reset King encounter aura tracking (called when boss combat ends)
utils.ResetKingAuraHistory = function()
    utils.kingAuraHistory = {
        ["shadowworddominate"] = {},
        ["brokenheart"] = {},
    }
end

-- Reset Aura Rank tracking (called when boss combat ends)
utils.ResetAuraRanks = function()
    utils.auraRanks = {}
end

-- Clean up aura timers for units no longer tracked
utils.CleanupAuraTimers = function(trackedGuids)
    for guid in pairs(utils.auraTimers) do
        if not trackedGuids[guid] then
            utils.auraTimers[guid] = nil
        end
    end

    -- Also clean up aura rank tracking for units no longer tracked
    for guid in pairs(utils.auraRanks) do
        if not trackedGuids[guid] then
            utils.auraRanks[guid] = nil
        end
    end
end

-- Clear a specific aura timer (when aura disappears)
utils.ClearAuraTimer = function(guid, auraId)
    if utils.auraTimers[guid] then
        utils.auraTimers[guid][auraId] = nil
        -- Clean up empty guid entry
        local hasTimers = false
        for _ in pairs(utils.auraTimers[guid]) do
            hasTimers = true
            break
        end
        if not hasTimers then
            utils.auraTimers[guid] = nil
        end
    end

    -- Also clear the rank tracking for this aura
    if utils.auraRanks[guid] then
        utils.auraRanks[guid][auraId] = nil
        -- Clean up empty guid entry
        local hasRanks = false
        for _ in pairs(utils.auraRanks[guid]) do
            hasRanks = true
            break
        end
        if not hasRanks then
            utils.auraRanks[guid] = nil
        end
    end
end

-- ============================================================================
-- Performance: Cache global functions locally
-- This avoids global table lookups on every function call (significant in OnUpdate)
-- ============================================================================
local pairs = pairs
local type = type
local tonumber = tonumber
local unpack = unpack
local floor = math.floor
local min = math.min
local max = math.max
local huge = math.huge
local format = string.format
local gsub = string.gsub
local strrep = string.rep
local find = string.find

-- Cache WoW API functions
local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitLevel = UnitLevel
local UnitClassification = UnitClassification
local UnitReaction = UnitReaction
local UnitDebuff = UnitDebuff
local UnitBuff = UnitBuff
local UnitName = UnitName
local UnitIsDead = UnitIsDead
local CheckInteractDistance = CheckInteractDistance
local GetDifficultyColor = GetDifficultyColor
local GetTime = GetTime

-- ============================================================================
-- Kruul Mark of the Highlord combat-log tracking
-- These triggers mirror the working BigWigs Kruul module. The gain events are
-- registered for self, party, and friendly players in core.lua.
-- ============================================================================
local KRUUL_MARK_GAIN_SELF = "你受到了大领主印记效果的影响"
local KRUUL_MARK_GAIN_OTHER = "(.+)受到了大领主印记效果的影响"
local KRUUL_MARK_FADE_SELF = "大领主印记效果从你身上消失了"
local KRUUL_MARK_FADE_OTHER = "大领主印记效果从(.+)身上消失了"

utils.TrackKruulMarkGain = function(message)
    if not message then
        return nil
    end

    local playerName
    if find(message, KRUUL_MARK_GAIN_SELF) then
        playerName = UnitName("player")
    else
        local _, _, matchedName = find(message, KRUUL_MARK_GAIN_OTHER)
        playerName = matchedName
    end

    if playerName and playerName ~= "" then
        utils.kruulMarkHistory[playerName] = GetTime()
        return playerName
    end

    return nil
end

utils.TrackKruulMarkFade = function(message)
    if not message then
        return nil
    end

    local playerName
    if find(message, KRUUL_MARK_FADE_SELF) then
        playerName = UnitName("player")
    else
        local _, _, matchedName = find(message, KRUUL_MARK_FADE_OTHER)
        playerName = matchedName
    end

    if playerName and playerName ~= "" then
        utils.kruulMarkHistory[playerName] = nil
        return playerName
    end

    return nil
end

-- ============================================================================
-- King encounter combat-log tracking
-- These triggers mirror the working BigWigs ChessFight module.
-- ============================================================================
local KING_SUBSERVIENCE_GAIN_SELF = "^你受到了黑暗屈从效果的影响"
local KING_SUBSERVIENCE_GAIN_OTHER = "^(.+)受到了黑暗屈从效果的影响"
local KING_SUBSERVIENCE_FADE = "^黑暗屈从效果从(.+)身上消失了"
local KING_CHARM_GAIN_SELF = "^你受到了魅惑之心效果的影响"
local KING_CHARM_GAIN_OTHER = "^(.+)受到了魅惑之心效果的影响"
local KING_CHARM_FADE = "^魅惑之心效果从(.+)身上消失了"

local function MatchKingAuraGain(message, selfTrigger, otherTrigger)
    if find(message, selfTrigger) then
        return UnitName("player")
    end

    local _, _, playerName = find(message, otherTrigger)
    return playerName
end

local function MatchKingAuraFade(message, fadeTrigger)
    local _, _, playerName = find(message, fadeTrigger)
    if playerName == "你" then
        return UnitName("player")
    end
    return playerName
end

utils.TrackKingAuraGain = function(message)
    if not message then
        return nil, nil
    end

    local auraId = "brokenheart"
    local playerName = MatchKingAuraGain(
            message, KING_SUBSERVIENCE_GAIN_SELF, KING_SUBSERVIENCE_GAIN_OTHER)

    if not playerName then
        auraId = "shadowworddominate"
        playerName = MatchKingAuraGain(
                message, KING_CHARM_GAIN_SELF, KING_CHARM_GAIN_OTHER)
    end

    local history = utils.kingAuraHistory[auraId]
    if playerName and playerName ~= "" and history then
        history[playerName] = GetTime()
        return auraId, playerName
    end

    return nil, nil
end


utils.TrackKingAuraFade = function(message)
    if not message then
        return nil, nil
    end

    local auraId = "brokenheart"
    local playerName = MatchKingAuraFade(message, KING_SUBSERVIENCE_FADE)

    if not playerName then
        auraId = "shadowworddominate"
        playerName = MatchKingAuraFade(message, KING_CHARM_FADE)
    end

    local history = utils.kingAuraHistory[auraId]
    if playerName and playerName ~= "" and history then
        history[playerName] = nil
        return auraId, playerName
    end

    return nil, nil
end

-- ============================================================================
-- String split utility (optimized)
-- ============================================================================
utils.strsplit = function(delimiter, subject)
    if not subject then
        return nil
    end
    local delim = delimiter or ":"
    local fields = {}
    local n = 0
    local pattern = "([^" .. delim .. "]+)"
    gsub(subject, pattern, function(c)
        n = n + 1
        fields[n] = c
    end)
    return unpack(fields)
end

-- ============================================================================
-- RGB to hex color string (optimized)
-- ============================================================================
local _r, _g, _b, _a
utils.rgbhex = function(r, g, b, a)
    local t = type(r)
    if t == "table" then
        if r.r then
            _r, _g, _b, _a = r.r, r.g, r.b, r.a or 1
        elseif r[3] then
            _r, _g, _b, _a = r[1], r[2], r[3], r[4] or 1
        else
            return ""
        end
    elseif t == "number" then
        _r, _g, _b, _a = r, g, b, a or 1
    else
        return ""
    end

    -- Clamp values to 0-1 range
    if _r > 1 then
        _r = 1
    end
    if _g > 1 then
        _g = 1
    end
    if _b > 1 then
        _b = 1
    end
    if _a > 1 then
        _a = 1
    end

    return format("|c%02x%02x%02x%02x", _a * 255, _r * 255, _g * 255, _b * 255)
end

-- ============================================================================
-- Unit color functions (optimized with local caching)
-- ============================================================================
utils.GetReactionColor = function(unitstr)
    local reaction = UnitReaction(unitstr, "player")
    local color = reaction and UnitReactionColor[reaction]
    local r, g, b = 0.8, 0.8, 0.8

    if color then
        r, g, b = color.r, color.g, color.b
    end

    return utils.rgbhex(r, g, b), r, g, b
end

utils.GetUnitColor = function(unitstr)
    if UnitIsPlayer(unitstr) then
        local _, class = UnitClass(unitstr)
        local classColor = class and RAID_CLASS_COLORS[class]

        if classColor then
            return utils.rgbhex(classColor.r, classColor.g, classColor.b), classColor.r, classColor.g, classColor.b
        end
        return utils.rgbhex(0.8, 0.8, 0.8), 0.8, 0.8, 0.8
    end

    return utils.GetReactionColor(unitstr)
end

utils.GetLevelColor = function(unitstr)
    local level = UnitLevel(unitstr)
    local color = GetDifficultyColor(level)
    local r, g, b = 0.8, 0.8, 0.8

    if color then
        r, g, b = color.r, color.g, color.b
    end

    return utils.rgbhex(r, g, b), r, g, b
end

-- ============================================================================
-- Level string with elite classification (optimized)
-- ============================================================================
-- Pre-defined suffix lookup table (avoids string comparisons in hot path)
local eliteSuffix = {
    worldboss = "B",
    rareelite = "R+",
    elite = "+",
    rare = "R"
}

utils.GetLevelString = function(unitstr)
    local level = UnitLevel(unitstr)
    local levelStr = level == -1 and "??" or level

    local elite = UnitClassification(unitstr)
    local suffix = eliteSuffix[elite]

    if suffix then
        return levelStr .. suffix
    end
    return levelStr
end

-- ============================================================================
-- Distance calculation (optimized)
-- ============================================================================
-- Cache the UnitXP API check (only check once)
local hasUnitXPDistance = nil

-- Pre-defined distance strings (avoids string creation in hot path)
local DIST_INFINITY = "∞"
local DIST_LESS_10 = "<9.9"
local DIST_LESS_11 = "<11"
local DIST_LESS_28 = "≤28"
local DIST_MORE_28 = ">28"

utils.GetDistance = function(unit)
    -- Check UnitXP availability once and cache result
    if hasUnitXPDistance == nil then
        hasUnitXPDistance = pcall(UnitXP, "nop", "nop")
    end

    if hasUnitXPDistance then
        local rawDistance = UnitXP("distanceBetween", "player", unit)
        if not rawDistance then
            return DIST_INFINITY, huge
        end
        return format("%.1f", rawDistance), rawDistance
    end

    -- Fallback: Range check mode (check from closest to farthest)
    if CheckInteractDistance(unit, 3) then
        return DIST_LESS_10, 9.9
    elseif CheckInteractDistance(unit, 2) then
        return DIST_LESS_11, 11
    elseif CheckInteractDistance(unit, 4) or CheckInteractDistance(unit, 1) then
        return DIST_LESS_28, 28
    end

    return DIST_MORE_28, 29
end

-- ============================================================================
-- Aura checking (optimized)
-- Uses code-defined auras as source of truth
-- Returns: (auraExists, remainingTime, rank) - remainingTime is calculated from internal timer
-- ============================================================================
utils.CheckAura = function(unit, auraId)
    if not auraId then
        return false, 0, 0
    end

    -- Use code-defined auras (not saved data)
    local auras = RunAway.codeDefaults.auras
    if not auras then
        return false, 0, 0
    end

    local auraData = auras[auraId]
    if not auraData then
        return false, 0, 0
    end

    local targetIcon = auraData.icon
    local duration = auraData.duration
    local now = GetTime()

    -- Helper function to calculate remaining time with timer tracking
    local function getRemainingTime(guid, auraIdKey, auraDuration, currentRank)
        if not utils.auraTimers[guid] then
            utils.auraTimers[guid] = {}
        end

        if not utils.auraRanks[guid] then
            utils.auraRanks[guid] = {}
        end

        -- Check if rank increased
        local previousRank = utils.auraRanks[guid][auraIdKey]
        local rankIncreased = previousRank and currentRank and currentRank > previousRank

        -- Reset timer if rank increased
        if rankIncreased then
            utils.auraTimers[guid][auraIdKey] = now
        end

        local timerStart = utils.auraTimers[guid][auraIdKey]
        if timerStart then
            local remaining = auraDuration - (now - timerStart)
            if remaining < 0 then
                remaining = 0
            end
            -- Store current rank for next check
            utils.auraRanks[guid][auraIdKey] = currentRank
            return remaining
        else
            -- First time seeing this aura, start timer and store rank
            utils.auraTimers[guid][auraIdKey] = now
            utils.auraRanks[guid][auraIdKey] = currentRank
            return auraDuration
        end
    end

    -- Special case: the King's mind control and kneeling mechanics are
    -- identified by exact combat-log text, not their aura icons.
    if auraId == "shadowworddominate" or auraId == "brokenheart" then
        local unitName = UnitName(unit)
        local history = utils.kingAuraHistory[auraId]

        if unitName and history and history[unitName] then
            return true, 0, 1
        end

        utils.ClearAuraTimer(unit, auraId)
        return false, 0, 0
    end

    -- Special case: Kruul's curse is identified by its exact combat-log text.
    -- Its icon is also used by ordinary shadow-protection buffs, so icon
    -- scanning would report unrelated buffs as the curse.
    if auraId == "shadowantishadow" then
        local unitName = UnitName(unit)
        local appliedAt = unitName and utils.kruulMarkHistory[unitName]

        if appliedAt then
            local remaining = duration - (now - appliedAt)
            if remaining > 0 then
                return true, remaining, 1
            end
            utils.kruulMarkHistory[unitName] = nil
        end

        utils.ClearAuraTimer(unit, auraId)
        return false, 0, 0
    end

    -- Special case: arcaneoverload requires 2 debuffs with the same icon
    if auraId == "arcaneoverload" then
        local i = 1
        local count = 0
        local buffIcon = UnitDebuff(unit, i)
        while buffIcon do
            if buffIcon == targetIcon then
                count = count + 1
                if count >= 2 then
                    -- Record timestamp only when overload is first detected
                    local unitName = UnitName(unit)
                    if unitName and not utils.arcaneOverloadHistory[unitName] then
                        utils.arcaneOverloadHistory[unitName] = now
                    end
                    local remaining = getRemainingTime(unit, auraId, duration )
                    return true, remaining, 1
                end
            end
            i = i + 1
            buffIcon = UnitDebuff(unit, i)
        end
        -- Aura not found, clear timer
        utils.ClearAuraTimer(unit, auraId)
        return false, 0, 0
    end

    -- Special case: arcanedampening shows after arcaneoverload fades (time-based)
    -- Sequence: arcaneoverload (2 stacks) -> fades after overload duration -> arcanedampening for its duration
    if auraId == "arcanedampening" then
        local unitName = UnitName(unit)
        if not unitName then
            return false, 0, 0
        end

        -- Clear history and skip if unit is dead
        if UnitIsDead(unit) then
            utils.arcaneOverloadHistory[unitName] = nil
            utils.ClearAuraTimer(unit, auraId)
            return false, 0, 0
        end

        local overloadStart = utils.arcaneOverloadHistory[unitName]
        if not overloadStart then
            utils.ClearAuraTimer(unit, auraId)
            return false, 0, 0
        end

        -- Get overload duration to know when it fades (from code-defined auras)
        local overloadData = RunAway.codeDefaults.auras["arcaneoverload"]
        local overloadDuration = overloadData and overloadData.duration or 0

        local elapsed = now - overloadStart

        -- Still in overload phase
        if elapsed < overloadDuration then
            utils.ClearAuraTimer(unit, auraId)
            return false, 0, 0
        end

        -- In dampening phase: show for its duration after overload fades
        local dampeningElapsed = elapsed - overloadDuration
        if dampeningElapsed < duration then
            -- For arcanedampening, remaining time is calculated from overload end
            local remaining = duration - dampeningElapsed
            if remaining < 0 then
                remaining = 0
            end
            return true, remaining, 1
        end

        -- Both phases complete, reset for next cycle
        utils.arcaneOverloadHistory[unitName] = nil
        utils.ClearAuraTimer(unit, auraId)
        return false, 0, 0
    end

    -- Special case: inthecircle has only 1 debuff (not 2 like arcaneoverload)
    -- Players with arcanedampening are NOT inthecircle (dampening prevents circle detection)
    if auraId == "inthecircle" then
        local unitName = UnitName(unit)
        if not unitName then
            return false, 0, 0
        end

        -- Skip if player has arcanedampening active
        -- Check if they're in the dampening phase
        local overloadStart = utils.arcaneOverloadHistory[unitName]
        if overloadStart then
            local overloadData = RunAway.codeDefaults.auras["arcaneoverload"]
            local overloadDuration = overloadData and overloadData.duration or 0
            local dampeningData = RunAway.codeDefaults.auras["arcanedampening"]
            local dampeningDuration = dampeningData and dampeningData.duration or 0

            local elapsed = now - overloadStart
            -- If in dampening phase (between overloadDuration and overloadDuration + dampeningDuration)
            if elapsed >= overloadDuration and elapsed < (overloadDuration + dampeningDuration) then
                -- Player has arcanedampening - cannot be inthecircle
                utils.inTheCircleHistory[unitName] = nil
                utils.ClearAuraTimer(unit, auraId)
                return false, 0, 0
            end
        end

        -- Check for exactly 1 debuff with the target icon
        local i = 1
        local count = 0
        local buffIcon = UnitDebuff(unit, i)
        while buffIcon do
            if buffIcon == targetIcon then
                count = count + 1
            end
            i = i + 1
            buffIcon = UnitDebuff(unit, i)
        end

        -- InTheCircle: exactly 1 debuff (not 2 like arcaneoverload)
        if count == 1 then
            if not utils.inTheCircleHistory[unitName] then
                utils.inTheCircleHistory[unitName] = now
            end
            local remaining = getRemainingTime(unit, auraId, duration, 1)
            return true, remaining, 1
        end

        -- Not in circle - but preserve history for dead players
        -- Dead players lose all debuffs, but we want to remember they were in the circle
        if not UnitIsDead(unit) then
            utils.inTheCircleHistory[unitName] = nil
            utils.ClearAuraTimer(unit, auraId)
        end
        return false, 0, 0
    end

    -- Check debuffs (iterate with local index)
    local i = 1
    local buffIcon, buffRank = UnitDebuff(unit, i)
    while buffIcon do
        if buffIcon == targetIcon then
            local currentRank = tonumber(buffRank) or 0
            local remaining = getRemainingTime(unit, auraId, duration, currentRank)

            return true, remaining, currentRank
        end
        i = i + 1
        buffIcon, buffRank = UnitDebuff(unit, i)
    end

    ---- TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ---- Check buffs (start from index 1, not where debuffs left off!)
    local j = 1
    buffIcon, buffRank = UnitBuff(unit, j)
    while buffIcon do
        if buffIcon == targetIcon then
            local currentRank = tonumber(buffRank) or 0
            local remaining = getRemainingTime(unit, auraId, duration, currentRank)

            --print(buffIcon, buffRank, remaining)
            return true, remaining, currentRank
        end
        j = j + 1
        buffIcon, buffRank = UnitBuff(unit, j)
    end

    ---- ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！

    -- Aura not found, clear timer
    utils.ClearAuraTimer(unit, auraId)
    return false, 0, 0
end

-- ============================================================================
-- Tank detection for tankOnly filter
-- Criteria:
--   1. Class must be Warrior, Druid, or Paladin
--   2. Max health > 8000
-- ============================================================================
local TANK_CLASSES = {
    ["WARRIOR"] = true,
    ["DRUID"] = true,
    ["PALADIN"] = true,
}

utils.IsTank = function(guid)
    if not UnitExists(guid) then
        return false
    end

    -- Check class
    local _, classToken = UnitClass(guid)
    if not TANK_CLASSES[classToken] then
        return false
    end

    -- Check max health > 8000
    local maxHealth = UnitHealthMax(guid)
    if not maxHealth or maxHealth <= 8000 then
        return false
    end

    return true
end

-- ============================================================================
-- Table utilities (optimized)
-- ============================================================================
utils.CountTable = function(tbl)
    if not tbl then
        return 0
    end
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- Display table contents for debugging
utils.PrintTable = function(tbl, indent, prefix)
    if not tbl then
        print(prefix or "", "nil")
        return
    end

    indent = indent or 0
    prefix = prefix or ""
    local indentStr = strrep("  ", indent)

    if type(tbl) ~= "table" then
        print(prefix .. indentStr .. tostring(tbl))
        return
    end

    print(prefix .. indentStr .. "{")
    for k, v in pairs(tbl) do
        local keyStr = tostring(k)
        local valueStr = ""

        if type(v) == "table" then
            -- Recursive call for nested tables
            utils.PrintTable(v, indent + 1, prefix .. indentStr .. keyStr .. " = ")
        else
            valueStr = tostring(v)
            if type(v) == "string" then
                valueStr = "\"" .. valueStr .. "\""
            end
            print(prefix .. indentStr .. "  " .. keyStr .. " = " .. valueStr)
        end
    end
    print(prefix .. indentStr .. "}")
end

---- Simple table printer for arrays
--utils.PrintArray = function(arr, prefix)
--    if not arr then
--        print((prefix or "") .. "Array: nil")
--        return
--    end
--
--    prefix = prefix or ""
--    print(prefix .. "Array (" .. #arr .. " items):")
--
--    for i = 1, #arr do
--        local v = arr[i]
--        local valueStr = tostring(v)
--        if type(v) == "string" then
--            valueStr = "\"" .. valueStr .. "\""
--        end
--        print(prefix .. "  [" .. i .. "] = " .. valueStr)
--    end
--end

RunAway.utils = utils
