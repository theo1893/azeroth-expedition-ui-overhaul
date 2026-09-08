if RunAway.disabled then
    return
end

-- ============================================================================
-- Slash Commands
-- ============================================================================
SLASH_RUNAWAY1 = "/runaway"

SlashCmdList["RUNAWAY"] = function(msg)
    if RunAway.disabled then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[快跑！]|r |cffff0000未检测到SuperWoW，插件已禁用。|r")
        return
    end
    msg = string.lower(msg or "")
    if msg == "on" or msg == "enable" then
        RunAway_db.enabled = true
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[快跑！]|r |cff00ff00已启用|r")
    elseif msg == "off" or msg == "disable" then
        RunAway_db.enabled = false
        if RunAway.core then
            RunAway.core.ResetStatus()
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[快跑！]|r |cffff0000已禁用|r")
    elseif msg == "debug" then
        RunAway_db.debug = not RunAway_db.debug
        local status = RunAway_db.debug and "|cff00ff00开启|r" or "|cffff0000关闭|r"
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[快跑！]|r 调试模式 " .. status)
    elseif msg == "announce" or msg == "ann" then
        RunAway_db.raidAnnounceEnabled = not RunAway_db.raidAnnounceEnabled
        local status = RunAway_db.raidAnnounceEnabled and "|cff00ff00开启|r" or "|cffff0000关闭|r"
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[快跑！]|r 团队通报 " .. status)
    elseif msg == "help" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[快跑！]|r 命令帮助:")
        DEFAULT_CHAT_FRAME:AddMessage("  /runaway - 显示状态")
        DEFAULT_CHAT_FRAME:AddMessage("  /runaway on/off - 启用/禁用插件")
        DEFAULT_CHAT_FRAME:AddMessage("  /runaway debug - 切换调试模式")
        DEFAULT_CHAT_FRAME:AddMessage("  /runaway announce - 切换团队通报")
    else
        local status = RunAway_db.enabled and "|cff00ff00启用|r" or "|cffff0000禁用|r"
        local debug = RunAway_db.debug and "|cff00ff00开启|r" or "|cffff0000关闭|r"
        local announce = RunAway_db.raidAnnounceEnabled and "|cff00ff00开启|r" or "|cffff0000关闭|r"
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[快跑！]|r 状态: " .. status .. " | 调试: " .. debug .. " | 团队通报: " .. announce)
    end
end

-- ============================================================================
-- Performance: Cache global functions locally
-- ============================================================================
local pairs = pairs
local type = type
local tinsert = table.insert
local tconcat = table.concat
local getn = table.getn
local format = string.format

-- Cache WoW API functions
local UnitExists = UnitExists
local UnitName = UnitName
local UnitIsDead = UnitIsDead
local UnitAffectingCombat = UnitAffectingCombat
local GetTime = GetTime

local utils = RunAway.utils
local core = CreateFrame("Frame", nil, WorldFrame)

core.guids = {}

-- Boss combat tracking variables
core.isBossCombat = false
core.currentBosses = {}
core.resetAlreadyCalled = false  -- Guard to prevent repeated resets

-- Check if a boss has any enabled columns
-- Uses code-defined layouts as source of truth, with user settings for enabled state
core.HasEnabledColumns = function(bossName)
    -- First check if boss exists in code
    if not RunAway.IsDeclaredBoss(bossName) then
        return false
    end

    -- Check boss-level enabled state
    if not RunAway.IsBossEnabled(bossName) then
        return false
    end

    -- Get the effective layout (code-defined with user enabled settings)
    local layout = RunAway.GetBossLayout(bossName)
    if not layout or not layout.columns then
        return false
    end

    for _, column in ipairs(layout.columns) do
        -- Check enabled state (already merged from user settings)
        if column.enabled then
            return true
        end
    end

    return false
end

-- Check if a unit is a boss (derives from code-defined bossLayouts)
-- Returns false if boss doesn't exist in code or all columns are disabled
core.ShouldMonitor = function(unit)
    if not UnitExists(unit) then
        return false
    end

    local unitName = UnitName(unit)
    -- Check if boss exists in CODE-DEFINED layouts (not saved data)
    if unitName and RunAway.IsDeclaredBoss(unitName) then
        -- Check if any columns are enabled for this boss
        if core.HasEnabledColumns(unitName) then
            return true
        end
    end

    return false
end

-- Reset all status for boss combat and UI
core.ResetStatus = function()
    -- Core status reset
    core.guids = {}
    core.isBossCombat = false
    core.resetAlreadyCalled = false

    -- Clear all current bosses
    for guid in pairs(core.currentBosses) do
        core.currentBosses[guid] = false
    end

    -- Reset arcane overload history for new encounter
    utils.ResetArcaneOverloadHistory()

    -- Reset InTheCircle tracking for new encounter
    utils.ResetInTheCircleHistory()

    -- Reset Kruul Mark of the Highlord tracking for new encounter
    utils.ResetKruulMarkHistory()

    -- Reset King encounter aura tracking for new encounter
    utils.ResetKingAuraHistory()

    -- Reset aura rank tracking for new encounter
    utils.ResetAuraRanks()

    -- Reset aura timers for new encounter
    utils.auraTimers = {}

    -- Reset raid announce tracking
    if RunAway.ui and RunAway.ui.ResetRaidAnnounceTracking then
        RunAway.ui.ResetRaidAnnounceTracking()
    end

    -- Reset deathwatch announce flag for new encounter
    if RunAway.deathWatch then
        RunAway.deathWatch.ResetAnnounceFlag()
    end

    -- UI status reset
    if RunAway.ui then
        -- Clear UI timers
        RunAway.ui.timers = {}

        -- Reset current boss name so title updates on next encounter
        RunAway.ui.currentBossName = nil

        -- Clear root frame completely (not just hide)
        if RunAway.ui.rootFrame then
            -- Hide the frame first
            RunAway.ui.rootFrame:Hide()

            -- Clear and delete all bars and columns
            if RunAway.ui.rootFrame.columns then
                for _, column in pairs(RunAway.ui.rootFrame.columns) do
                    if column.bars then
                        for bar_guid, bar in pairs(column.bars) do
                            bar:Hide()
                            bar = nil  -- Clear bar reference
                            column.bars[bar_guid] = nil  -- Remove from column bars
                        end
                        column.bars = nil  -- Clear bars table
                    end
                    column:Hide()
                    column = nil  -- Clear column reference
                end
                RunAway.ui.rootFrame.columns = nil  -- Clear columns table
            end

            -- Delete the root frame itself
            RunAway.ui.rootFrame:ClearAllPoints()
            RunAway.ui.rootFrame = nil  -- Remove root frame reference
        end
    end
end

core.add = function(unit)
    -- Skip if addon is disabled
    if not RunAway_db.enabled then
        return
    end

    local exists, guid = UnitExists(unit)
    if not exists or not guid then
        return
    end

    local _, distanceValue = utils.GetDistance(unit)
    local shouldMonitor = core.ShouldMonitor(unit)

    -- Handle boss units
    if shouldMonitor then
        -- Boss died - reset all status (only once per death)
        if UnitIsDead(unit) then
            if not core.resetAlreadyCalled then
                local bossName = UnitName(unit) or "Unknown"
                core.resetAlreadyCalled = true
                core.ResetStatus()
                -- Reset deathwatch announce flag directly (not via ResetStatus)
                if RunAway.deathWatch and RunAway.deathWatch.ResetAnnounceFlag then
                    RunAway.deathWatch.ResetAnnounceFlag()
                end
            end
            return
        end

        -- Only enter boss combat if: boss is nearby, player in combat, and boss in combat
        local isNearby = distanceValue < 100
        local playerInCombat = UnitAffectingCombat("player")
        local bossInCombat = UnitAffectingCombat(unit)

        if isNearby and playerInCombat and bossInCombat then
            core.isBossCombat = true
            core.resetAlreadyCalled = false  -- Reset flag for new encounter
            local bossName = UnitName(unit)
            core.currentBosses[guid] = bossName or true
        else
            return
        end
    elseif not core.isBossCombat then
        -- Skip non-boss units when not in boss combat
        return
    end

    -- Track unit during boss combat
    core.guids[guid] = { time = GetTime(), distance = distanceValue }
end

-- unitstr
--core:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
--core:RegisterEvent("PLAYER_TARGET_CHANGED")
core:RegisterEvent("PLAYER_ENTERING_WORLD")

-- arg1
core:RegisterEvent("UNIT_COMBAT")
--core:RegisterEvent("UNIT_HAPPINESS")
core:RegisterEvent("UNIT_MODEL_CHANGED")
core:RegisterEvent("UNIT_PORTRAIT_UPDATE")
core:RegisterEvent("UNIT_FACTION")
core:RegisterEvent("UNIT_FLAGS")
core:RegisterEvent("UNIT_AURA")
core:RegisterEvent("UNIT_HEALTH")
core:RegisterEvent("UNIT_MANA")
core:RegisterEvent("UNIT_CASTEVENT")

-- Exact combat-log driven encounter auras: listen for the player, the
-- player's party, and friendly players in other raid groups.
core:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
core:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
core:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE")
core:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
core:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY")
core:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")

core:SetScript("OnEvent", function()
    if event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE"
            or event == "CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE"
            or event == "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE" then
        if RunAway_db.enabled then
            utils.TrackKruulMarkGain(arg1)
            utils.TrackKingAuraGain(arg1)
        end
    elseif event == "CHAT_MSG_SPELL_AURA_GONE_SELF"
            or event == "CHAT_MSG_SPELL_AURA_GONE_PARTY"
            or event == "CHAT_MSG_SPELL_AURA_GONE_OTHER" then
        if RunAway_db.enabled then
            utils.TrackKruulMarkFade(arg1)
            utils.TrackKingAuraFade(arg1)
        end
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        this.add("mouseover")
    elseif event == "PLAYER_ENTERING_WORLD" then
        this.add("player")
    elseif event == "PLAYER_TARGET_CHANGED" then
        this.add("target")
    else
        this.add(arg1)
    end
end)

-- Debug output frame
local debugFrame = CreateFrame("Frame")
local debugLastUpdate = 0
local debugInterval = 1  -- Output every 1 second

-- Count table entries (local optimized version)
local function CountTable(t)
    if not t then return 0 end
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- Get boss names from currentBosses
local function GetBossNames()
    local names = {}
    local n = 0
    for guid, nameOrActive in pairs(core.currentBosses) do
        if nameOrActive then
            n = n + 1
            if type(nameOrActive) == "string" then
                names[n] = nameOrActive
            else
                names[n] = "Unknown"
            end
        end
    end
    if n == 0 then
        return "无"
    end
    return tconcat(names, ", ")
end

-- Pre-defined strings for debug output
local DEBUG_YES = "|cff00ff00是|r"
local DEBUG_NO = "|cffff0000否|r"

debugFrame:SetScript("OnUpdate", function()
    -- Early exit if debug is disabled (most common case)
    local db = RunAway_db
    if not db or not db.debug then
        return
    end

    local now = GetTime()
    if now - debugLastUpdate < debugInterval then
        return
    end
    debugLastUpdate = now

    -- Build debug output
    local guidsCount = CountTable(core.guids)
    local inCombat = UnitAffectingCombat("player") and "是" or "否"
    local bossNames = GetBossNames()

    DEFAULT_CHAT_FRAME:AddMessage(format(
        "|cffffcc00[快跑！调试]|r 玩家战斗:%s | Boss战斗:%s | 追踪单位:%d | Boss:%s",
        inCombat,
        core.isBossCombat and DEBUG_YES or DEBUG_NO,
        guidsCount,
        bossNames
    ))
end)

RunAway.core = core
