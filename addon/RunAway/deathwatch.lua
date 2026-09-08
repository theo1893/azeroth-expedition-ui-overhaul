if RunAway.disabled then
    return
end

-- ============================================================================
-- Anomalus Bomb Wipe Detector
-- Only works for Anomalus (阿诺玛鲁斯) boss
-- Detects raid wipes and correlates with bomb (炸弹) explosions
-- ============================================================================

local GetTime = GetTime
local format = string.format

-- Death tracking
local recentDeaths = {}  -- [playerName] = deathTime
local DEATH_WINDOW = 1.0  -- Time window in seconds
local DEATH_THRESHOLD = 5  -- Minimum deaths to trigger warning
local announcedThisCombat = false  -- Only announce once per boss encounter

-- Bomb wipe analysis
local BOMB_LOOKBACK_TIME = 15.0  -- How many seconds back to look for bombs
local BOMB_DURATION = 15.0  -- Arcane Overload duration (from auras table)
local MAX_BOMB_DIFF = 1.5  -- Maximum seconds from bomb explosion to wipe to consider it related

-- Circle wipe analysis
local CIRCLE_LOOKBACK_TIME = 15.0  -- How many seconds back to look for circle
local MAX_CIRCLE_DIFF = 2.0  -- Maximum seconds from circle to wipe to consider it related

-- Test mode for debugging
local testMode = false

-- ============================================================================
-- Helper: Check if we're fighting Anomalus
-- ============================================================================
local function IsAnomalusCombat()
    if not RunAway.core or not RunAway.core.currentBosses then
        return false
    end

    -- Check if any current boss is Anomalus
    for guid, bossName in pairs(RunAway.core.currentBosses) do
        if bossName == "阿诺玛鲁斯" then
            return true
        end
    end

    return false
end

-- ============================================================================
-- Helper: Find the most likely bomb culprits for a wipe
-- Returns: primaryPlayer, primaryTimestamp, primaryDiff, secondaryPlayer, secondaryDiff
-- ============================================================================
local function FindBombCulprit(wipeTimestamp)
    if not RunAway.utils or not RunAway.utils.arcaneOverloadHistory then
        return nil, nil, nil, nil, nil
    end

    local primaryPlayer, primaryTimestamp, primaryDiff = nil, nil, nil
    local secondaryPlayer, secondaryDiff = nil, nil
    local minTimeDiff = BOMB_LOOKBACK_TIME  -- Initialize to max lookback time
    local secondMinTimeDiff = BOMB_LOOKBACK_TIME

    -- Iterate through bomb history to find the bombs that exploded closest to wipe
    for playerName, bombTimestamp in pairs(RunAway.utils.arcaneOverloadHistory) do
        -- Calculate when the bomb exploded (bomb start + duration)
        local explodeTime = bombTimestamp + BOMB_DURATION

        -- Calculate time difference from wipe to bomb explosion
        local timeDiff = wipeTimestamp - explodeTime

        -- Only consider bombs that exploded within BOMB_LOOKBACK_TIME seconds before wipe
        if timeDiff >= 0 and timeDiff <= BOMB_LOOKBACK_TIME then
            if timeDiff < minTimeDiff then
                -- Current primary becomes secondary
                secondaryPlayer, secondaryDiff = primaryPlayer, primaryDiff
                secondMinTimeDiff = minTimeDiff

                -- New primary
                minTimeDiff = timeDiff
                primaryPlayer = playerName
                primaryTimestamp = explodeTime
                primaryDiff = timeDiff
            elseif timeDiff < secondMinTimeDiff then
                -- Update secondary only
                secondMinTimeDiff = timeDiff
                secondaryPlayer = playerName
                secondaryDiff = timeDiff
            end
        end
    end

    -- If the closest bomb is too far away (>2s), consider it unrelated
    if primaryDiff and primaryDiff > MAX_BOMB_DIFF then
        return nil, nil, nil, nil, nil
    end

    return primaryPlayer, primaryTimestamp, primaryDiff, secondaryPlayer, secondaryDiff
end

-- ============================================================================
-- Helper: Find players who were in the circle when wipe occurred
-- Returns: table of { name, timestamp }
-- ============================================================================
local function FindCirclePlayers(wipeTimestamp)
    if not RunAway.utils then
        return {}
    end
    if not RunAway.utils.inTheCircleHistory then
        return {}
    end

    local circlePlayers = {}
    local currentTime = wipeTimestamp

    for playerName, circleTimestamp in pairs(RunAway.utils.inTheCircleHistory) do
        -- Calculate how long ago they were in the circle
        local timeDiff = currentTime - circleTimestamp

        -- Only consider circle within the lookback window
        if timeDiff >= 0 and timeDiff <= 1.5 then
            table.insert(circlePlayers, { name = playerName, timestamp = circleTimestamp })
        end
    end

    return circlePlayers
end

-- Check if global debug is enabled
local function IsDebugEnabled()
    return RunAway_db and RunAway_db.debug
end

-- Create event frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH")

-- Process deaths and check for raid wipe (Anomalus only)
local function CheckRaidWipe()
    local currentTime = GetTime()

    -- Clean up old deaths outside the window
    for playerName, deathTime in pairs(recentDeaths) do
        if currentTime - deathTime > DEATH_WINDOW then
            recentDeaths[playerName] = nil
        end
    end

    -- Count deaths in window
    local deathCount = 0
    for _ in pairs(recentDeaths) do
        deathCount = deathCount + 1
    end

    -- Check if threshold reached and not yet announced this combat
    if deathCount >= DEATH_THRESHOLD and not announcedThisCombat then
        -- Skip boss combat check when in test mode
        if not testMode and not IsAnomalusCombat() then
            if IsDebugEnabled() then
                DEFAULT_CHAT_FRAME:AddMessage("|cff99ccff[DW Debug]|r |cffffcc00Wipe detected but not Anomalus - skipping|r")
            end
            return
        end

        announcedThisCombat = true

        if IsDebugEnabled() then
            DEFAULT_CHAT_FRAME:AddMessage("|cff99ccff[DW Debug]|r |cff00ff00ANNOUNCING|r - " .. deathCount .. " deaths (Anomalus)")
        end

        -- Find the bomb culprit
        local culpritName, _, timeDiff, secondCulpritName, secondTimeDiff = FindBombCulprit(currentTime)

        -- Find players in the circle
        local circlePlayers = FindCirclePlayers(currentTime)

        -- Build and send warning message (using simple string concatenation)
        local message
        local hasBomb = culpritName ~= nil
        local hasCircle = table.getn(circlePlayers) > 0

        if hasBomb and hasCircle then
            local timeDiffStr = format("%.1f", timeDiff)
            local names = {}
            for _, player in ipairs(circlePlayers) do
                table.insert(names, player.name)
            end
            local circleNames = table.concat(names, ", ")
            message = "|cffff0000团灭预警: " .. deathCount .. "人死亡! 炸弹: " .. culpritName .. " (+" .. timeDiffStr .. "s) 异常踩圈: " .. circleNames .. "|r"
        elseif hasBomb then
            local timeDiffStr = format("%.1f", timeDiff)
            message = "|cffff0000团灭预警: " .. deathCount .. "人死亡! 炸弹: " .. culpritName .. " (+" .. timeDiffStr .. "s)|r"
        elseif hasCircle then
            local names = {}
            for _, player in ipairs(circlePlayers) do
                table.insert(names, player.name)
            end
            local circleNames = table.concat(names, ", ")
            message = "|cffff0000团灭预警: " .. deathCount .. "人死亡! 异常踩圈: " .. circleNames .. "|r"
        else
            message = "|cffff0000团灭预警: " .. deathCount .. "人死亡! 无炸弹来源|r"
        end

        SendChatMessage(message, "RAID")

        -- Also print locally
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[快跑！]|r " .. message)

        -- Debug: show bomb history
        if IsDebugEnabled() and RunAway.utils and RunAway.utils.arcaneOverloadHistory then
            DEFAULT_CHAT_FRAME:AddMessage("|cff99ccff[DW Debug]|r |cff00ff00当前炸弹记录:|r")
            for pname, ptime in pairs(RunAway.utils.arcaneOverloadHistory) do
                local agoStr = string.format("%.1f", currentTime - ptime)
                DEFAULT_CHAT_FRAME:AddMessage("|cff99ccff[DW Debug]|r   " .. (pname or "?") .. " - " .. agoStr .. "s ago")
            end
        end

        -- Clear deaths after announce to prevent spam
        recentDeaths = {}
    end
end

-- Simulate a death (for testing in town) - defined AFTER CheckRaidWipe
local function SimulateDeath(playerName)
    playerName = playerName or "TestPlayer" .. math.random(1, 40)
    local currentTime = GetTime()
    recentDeaths[playerName] = currentTime

    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[DeathWatch Test]|r Simulated death: |cffff0000" .. playerName .. "|r")

    CheckRaidWipe()
end

eventFrame:SetScript("OnEvent", function()
    if event == "CHAT_MSG_COMBAT_FRIENDLY_DEATH" then
        -- Check if death watch is enabled
        if not RunAway_db or not RunAway_db.deathWatchEnabled then
            return
        end

        -- Skip raid check in test mode
        if not testMode then
            -- Must be in a raid
            if GetNumRaidMembers() == 0 then
                return
            end

            -- Only track deaths during Anomalus combat
            if not IsAnomalusCombat() then
                return
            end
        end

        if arg1 then
            if IsDebugEnabled() then
                DEFAULT_CHAT_FRAME:AddMessage("|cff99ccff[DW Debug]|r |cffffcc00" .. arg1 .. "|r")
            end

            -- Parse player name from death message
            local _, _, playerName = string.find(arg1, "(.+) dies")
            if not playerName then
                _, _, playerName = string.find(arg1, "(.+)死亡了")
            end
            if not playerName then
                _, _, playerName = string.find(arg1, "(.+) has died")
            end

            if playerName then
                local currentTime = GetTime()
                recentDeaths[playerName] = currentTime
                CheckRaidWipe()
            end
        end
    end
end)

-- ============================================================================
-- Test Slash Command
-- ============================================================================
SLASH_DEATHWATCH1 = "/deathwatch"
SLASH_DEATHWATCH2 = "/dw"

SlashCmdList["DEATHWATCH"] = function(msg)
    msg = string.lower(msg or "")

    if msg == "test" or msg == "simulate" then
        -- Simulate 10 deaths at once to trigger warning
        testMode = true
        recentDeaths = {}
        announcedThisCombat = false  -- Reset flag for testing
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Test mode: |cff00ff00enabled|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Simulating 10 deaths...")

        -- Simulate multiple bombs at different times to test culprit selection
        if not RunAway.utils.arcaneOverloadHistory then
            RunAway.utils.arcaneOverloadHistory = {}
        end
        if not RunAway.utils.inTheCircleHistory then
            RunAway.utils.inTheCircleHistory = {}
        end

        -- Create bombers with different explosion times to test threshold logic
        -- MAX_BOMB_DIFF = 2.0s: bombs exploded >2s before wipe are considered unrelated
        local testBombers = {
            { name = "JustBomber", secondsAgo = 0.3 },      -- 0.3s ago - primary culprit
            { name = "CloseBomber", secondsAgo = 1.5 },      -- 1.5s ago - secondary culprit (for comparison)
            { name = "BorderlineBomber", secondsAgo = 2.5 }, -- 2.5s ago - too far, should NOT be selected
            { name = "OldBomber", secondsAgo = 10.0 },       -- 10s ago - too far, should NOT be selected
        }

        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Simulating |cffff00004|r bombs...")

        for _, bomber in ipairs(testBombers) do
            local bombTime = GetTime() - BOMB_DURATION - bomber.secondsAgo
            RunAway.utils.arcaneOverloadHistory[bomber.name] = bombTime
            local secondsStr = string.format("%.1f", bomber.secondsAgo)
            DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r   |cffff0000[" .. bomber.name .. "]|r bomb exploded |cffff0000" .. secondsStr .. "s|r ago")
        end

        -- Simulate players in the circle
        local testCirclePlayers = {
            { name = "CirclePlayer1", secondsAgo = 0.5 },
            { name = "CirclePlayer2", secondsAgo = 1.0 },
            { name = "CirclePlayer3", secondsAgo = 8.0 },  -- Too far, should NOT show
        }

        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Simulating |cffff00003|r players in circle...")

        for _, circlePlayer in ipairs(testCirclePlayers) do
            local circleTime = GetTime() - circlePlayer.secondsAgo
            RunAway.utils.inTheCircleHistory[circlePlayer.name] = circleTime
            local secondsStr = string.format("%.1f", circlePlayer.secondsAgo)
            DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r   |cff0000ff[" .. circlePlayer.name .. "]|r in circle for |cff0000ff" .. secondsStr .. "s|r")
        end

        for i = 1, 10 do
            SimulateDeath("TestPlayer" .. i)
        end

        testMode = false
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Tip: Use /dw clear to reset flag and test again")

    elseif msg == "notest" or msg == "nofound" then
        -- Test when no bomb is within 2s threshold (should show "unable to find bomb source")
        testMode = true
        recentDeaths = {}
        announcedThisCombat = false
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Test mode: |cff00ff00enabled|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Testing NO bomb found (all bombs >2s ago)...")

        if not RunAway.utils.arcaneOverloadHistory then
            RunAway.utils.arcaneOverloadHistory = {}
        end

        -- All bombs are >2s away, should return "no bomb found"
        local noMatchBombers = {
            { name = "OldBomber1", secondsAgo = 3.0 },
            { name = "OldBomber2", secondsAgo = 5.0 },
            { name = "OldBomber3", secondsAgo = 12.0 },
        }

        for _, bomber in ipairs(noMatchBombers) do
            local bombTime = GetTime() - BOMB_DURATION - bomber.secondsAgo
            RunAway.utils.arcaneOverloadHistory[bomber.name] = bombTime
            local secondsStr = string.format("%.1f", bomber.secondsAgo)
            DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r   |cffff0000[" .. bomber.name .. "]|r bomb exploded |cffff0000" .. secondsStr .. "s|r ago")
        end

        for i = 1, 10 do
            SimulateDeath("TestPlayer" .. i)
        end

        testMode = false
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Tip: Use /dw clear to reset flag and test again")

    elseif msg == "single" then
        -- Simulate a single death
        testMode = true
        SimulateDeath("SinglePlayer")
        local count = 0
        for _ in pairs(recentDeaths) do
            count = count + 1
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Current death count: " .. count)
        testMode = false

    elseif msg == "clear" then
        -- Clear tracked deaths and reset announce flag
        recentDeaths = {}
        announcedThisCombat = false
        if RunAway.utils then
            RunAway.utils.arcaneOverloadHistory = {}
            RunAway.utils.inTheCircleHistory = {}
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Death tracking cleared (announce flag reset)")

    elseif msg == "count" then
        -- Show current death count and flag state
        local count = 0
        for _ in pairs(recentDeaths) do
            count = count + 1
        end
        local flagState = announcedThisCombat and "|cffff0000ALREADY ANNOUNCED|r" or "|cff00ff00READY|r"
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Deaths: |cffff0000" .. count .. "|r / " .. DEATH_THRESHOLD .. " | Flag: " .. flagState)

        -- Show bomb history if available
        if RunAway.utils and RunAway.utils.arcaneOverloadHistory then
            local bombCount = 0
            for _ in pairs(RunAway.utils.arcaneOverloadHistory) do
                bombCount = bombCount + 1
            end
            DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Active bombs: |cffff0000" .. bombCount .. "|r")
            for pname, ptime in pairs(RunAway.utils.arcaneOverloadHistory) do
                local ago = format("%.1f", GetTime() - ptime)
                local explodeIn = format("%.1f", BOMB_DURATION - (GetTime() - ptime))
                DEFAULT_CHAT_FRAME:AddMessage("  |cffffcc00" .. (pname or "?") .. "|r - started " .. ago .. "s ago, explodes in " .. explodeIn .. "s")
            end
        end

        -- Show circle history if available
        if RunAway.utils and RunAway.utils.inTheCircleHistory then
            local circleCount = 0
            for _ in pairs(RunAway.utils.inTheCircleHistory) do
                circleCount = circleCount + 1
            end
            DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r In circle: |cff0000ff" .. circleCount .. "|r")
            for pname, ptime in pairs(RunAway.utils.inTheCircleHistory) do
                local ago = format("%.1f", GetTime() - ptime)
                DEFAULT_CHAT_FRAME:AddMessage("  |cff0000ff" .. (pname or "?") .. "|r - in circle for " .. ago .. "s")
            end
        end

    elseif msg == "on" or msg == "enable" then
        RunAway_db.deathWatchEnabled = true
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r |cff00ff00Enabled|r")

    elseif msg == "off" or msg == "disable" then
        RunAway_db.deathWatchEnabled = false
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r |cffff0000Disabled|r")

    elseif msg == "help" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Commands:")
        DEFAULT_CHAT_FRAME:AddMessage("  /dw test - Simulate 10 deaths with bomb (finds culprit)")
        DEFAULT_CHAT_FRAME:AddMessage("  /dw notest - Simulate 10 deaths with no bomb (no culprit)")
        DEFAULT_CHAT_FRAME:AddMessage("  /dw single - Simulate 1 death (no warning)")
        DEFAULT_CHAT_FRAME:AddMessage("  /dw clear - Clear deaths and reset announce flag")
        DEFAULT_CHAT_FRAME:AddMessage("  /dw count - Show current death count")
        DEFAULT_CHAT_FRAME:AddMessage("  /dw on/off - Enable/Disable death watch")
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffff99仅对阿诺玛鲁斯战斗有效|r")
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffff99Debug: Use /runaway debug to toggle|r")

    else
        local enabled = RunAway_db and RunAway_db.deathWatchEnabled ~= false
        local status = enabled and "|cff00ff00ON|r" or "|cffff0000OFF|r"
        local bossStatus = IsAnomalusCombat() and "|cff00ff00阿诺玛鲁斯战斗中|r" or "|cffffcc00未在阿诺玛鲁斯战斗|r"
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Status: " .. status .. " | " .. bossStatus)
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[炸弹团灭检测]|r Use /dw help for commands")
    end
end

-- Export to RunAway namespace
RunAway.deathWatch = {
    SetEnabled = function(enabled)
        if not RunAway_db then return end
        RunAway_db.deathWatchEnabled = enabled
    end,
    IsEnabled = function()
        return RunAway_db and RunAway_db.deathWatchEnabled ~= false
    end,
    GetThreshold = function()
        return DEATH_THRESHOLD
    end,
    GetWindow = function()
        return DEATH_WINDOW
    end,
    SimulateDeath = SimulateDeath,
    GetDeathCount = function()
        local count = 0
        for _ in pairs(recentDeaths) do
            count = count + 1
        end
        return count
    end,
    ClearDeaths = function()
        recentDeaths = {}
    end,
    ResetAnnounceFlag = function()
        announcedThisCombat = false
        if IsDebugEnabled() then
            DEFAULT_CHAT_FRAME:AddMessage("|cff99ccff[DW]|r |cff00ff00Flag reset - ready for next encounter|r")
        end
    end,
    IsAnomalusCombat = IsAnomalusCombat,
    FindBombCulprit = FindBombCulprit,
    BOMB_LOOKBACK_TIME = BOMB_LOOKBACK_TIME,
    BOMB_DURATION = BOMB_DURATION,
}