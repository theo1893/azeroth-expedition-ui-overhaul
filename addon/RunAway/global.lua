RunAway = {}

-- ============================================================================
-- CODE-DEFINED DEFAULTS (Source of Truth - Never saved to disk)
-- These define what raids/bosses/columns exist. If removed from code, they
-- won't be shown even if old saved data references them.
-- ============================================================================
RunAway.codeDefaults = {
    -- Global display scale (applies to all bosses)
    globalScale = 0.8,

    -- Raid hierarchy: raid -> bosses
    raids = {
        ["世界"] = {
            order = 1,
            bosses = { "团队副本训练假人" }
        },
        ["纳克萨玛斯"] = {
            order = 2,
            bosses = { "克尔苏加德" }
        },
        ["卡拉赞之塔"] = {
            order = 3,
            bosses = { "阿诺玛鲁斯", "国王", "桑夫·塔斯达尔", "库鲁尔", "麦迪文的回响", "孟菲斯托斯" }
        },
    },

    -- Boss layouts (referenced by boss name) - defines columns and their display properties
    bossLayouts = {
        ["阿诺玛鲁斯"] = {
            name = "阿诺玛鲁斯",
            columns = {
                {
                    title = "炸弹",
                    filter = "aura:arcaneoverload",
                    width = 90,
                    height = 14,
                    spacing = 4,
                    maxrow = 10,
                    showDistance = true,
                    showTimer = true,
                    showRank = false,
                    sortBy = "timer", -- "timer", "distance", "rank", or nil (no sort)
                    sortOrder = "asc", -- "asc" or "desc"
                    alignment = "center",
                    raidAnnounce = true, -- Send raid message when debuff is gained
                    colors = {
                        bgColor = { 0.3, 0.1, 0.1, 0.9 },
                        borderColor = { 1, 0.2, 0.2, 1 },
                        titleColor = { 1, 0.4, 0.4, 1 }
                    }
                },
                {
                    title = "奥术抑制",
                    filter = "aura:arcanedampening",
                    width = 90,
                    height = 14,
                    spacing = 4,
                    maxrow = 10,
                    showDistance = true,
                    showTimer = true,
                    showRank = false,
                    sortBy = "timer", -- "timer", "distance", "rank", or nil (no sort)
                    sortOrder = "desc", -- "asc" or "desc"
                    alignment = "center",
                    colors = {
                        bgColor = { 0.1, 0.2, 0.1, 0.9 },
                        borderColor = { 0.2, 0.8, 0.2, 1 },
                        titleColor = { 0.4, 1, 0.4, 1 }
                    }
                },
                {
                    title = "异常踩圈",
                    filter = "aura:inthecircle",
                    width = 90,
                    height = 14,
                    spacing = 4,
                    maxrow = 10,
                    showDistance = true,
                    showTimer = false,
                    showRank = false,
                    alignment = "center",
                    raidAnnounce = false,
                    colors = {
                        bgColor = { 0.1, 0.1, 0.3, 0.9 },
                        borderColor = { 0.4, 0.4, 1, 1 },
                        titleColor = { 0.6, 0.6, 1, 1 }
                    }
                }
            }
        },
        ["国王"] = {
            name = "国王",
            columns = {
                {
                    title = "心控",
                    filter = "aura:shadowworddominate",
                    width = 90,
                    height = 14,
                    spacing = 4,
                    maxrow = 10,
                    showDistance = true,
                    showTimer = false,
                    showRank = false,
                    sortBy = nil, -- "timer", "distance", or nil (no sort)
                    sortOrder = "asc", -- "asc" or "desc"
                    alignment = "center",
                    raidAnnounce = true, -- Send raid message when debuff is gained
                    colors = {
                        bgColor = { 0.3, 0.1, 0.1, 0.9 },
                        borderColor = { 1, 0.2, 0.2, 1 },
                        titleColor = { 1, 0.4, 0.4, 1 }
                    }
                },
                {
                    title = "下跪",
                    filter = "aura:brokenheart",
                    width = 90,
                    height = 14,
                    spacing = 4,
                    maxrow = 10,
                    showDistance = true,
                    showTimer = false,
                    showRank = false,
                    sortBy = nil, -- "timer", "distance", or nil (no sort)
                    sortOrder = "desc", -- "asc" or "desc"
                    alignment = "center",
                    raidAnnounce = true, -- Send raid message when debuff is gained
                    colors = {
                        bgColor = { 0.1, 0.2, 0.1, 0.9 },
                        borderColor = { 0.2, 0.8, 0.2, 1 },
                        titleColor = { 0.4, 1, 0.4, 1 }
                    }
                }
            }
        },
        ["库鲁尔"] = {
            name = "库鲁尔",
            columns = {
                {
                    title = "诅咒",
                    filter = "aura:shadowantishadow",
                    width = 90,
                    height = 14,
                    spacing = 4,
                    maxrow = 10,
                    showDistance = true,
                    showTimer = true,
                    showRank = false,
                    sortBy = "timer", -- "timer", "distance", or nil (no sort)
                    sortOrder = "desc", -- "asc" or "desc"
                    alignment = "center",
                    raidAnnounce = true, -- Send raid message when debuff is gained
                    colors = {
                        bgColor = { 0.3, 0.1, 0.1, 0.9 },
                        borderColor = { 1, 0.2, 0.2, 1 },
                        titleColor = { 1, 0.4, 0.4, 1 }
                    }
                },
                {
                    title = "坦克叠层",
                    filter = "aura:shadowraisedead",
                    tankOnly = true,
                    width = 90,
                    height = 14,
                    spacing = 4,
                    maxrow = 10,
                    showDistance = true,
                    showTimer = true,
                    showRank = true,
                    sortBy = "timer", -- "timer", "distance", or nil (no sort)
                    sortOrder = "desc", -- "asc" or "desc"
                    alignment = "center",
                    colors = {
                        bgColor = { 0.3, 0.1, 0.1, 0.9 },
                        borderColor = { 1, 0.2, 0.2, 1 },
                        titleColor = { 1, 0.4, 0.4, 1 }
                    }
                },
            }
        },
        ["麦迪文的回响"] = {
            name = "麦迪文的回响",
            columns = {
                {
                    title = "腐化",
                    filter = "aura:shadowegg",
                    width = 90,
                    height = 14,
                    spacing = 4,
                    maxrow = 10,
                    showDistance = true,
                    showTimer = false,
                    showRank = false,
                    sortBy = "distance", -- "timer", "distance", or nil (no sort)
                    sortOrder = "desc", -- "asc" or "desc"
                    alignment = "center",
                    raidAnnounce = true, -- Send raid message when debuff is gained
                    colors = {
                        bgColor = { 0.3, 0.1, 0.1, 0.9 },
                        borderColor = { 1, 0.2, 0.2, 1 },
                        titleColor = { 1, 0.4, 0.4, 1 }
                    }
                },
            }
        },
        ["克尔苏加德"] = {
            name = "克尔苏加德",
            columns = {
                {
                    title = "冰墓",
                    filter = "aura:frostblast",
                    width = 90,
                    height = 14,
                    spacing = 4,
                    maxrow = 10,
                    showDistance = true,
                    showTimer = false,
                    showRank = false,
                    sortBy = "distance", -- "timer", "distance", or nil (no sort)
                    sortOrder = "asc", -- "asc" or "desc"
                    alignment = "right",
                    colors = {
                        bgColor = { 0.3, 0.1, 0.1, 0.9 },
                        borderColor = { 1, 0.2, 0.2, 1 },
                        titleColor = { 1, 0.4, 0.4, 1 }
                    }
                },
            }
        },
        ["团队副本训练假人"] = {
            name = "团队副本训练假人",
            columns = {
                {
                    title = "绷带",
                    filter = "aura:bandage",
                    width = 90,
                    height = 14,
                    spacing = 4,
                    maxrow = 10,
                    showDistance = true,
                    showTimer = true,
                    showRank = false,
                    sortBy = "distance", -- "timer", "distance", or nil (no sort)
                    sortOrder = "desc", -- "asc" or "desc"
                    alignment = "center",
                    colors = {
                        bgColor = { 0.1, 0.2, 0.1, 0.9 },
                        borderColor = { 0.2, 0.8, 0.2, 1 },
                        titleColor = { 0.4, 1, 0.4, 1 }
                    }
                },
                {
                    title = "治疗之道",
                    filter = "aura:naturehealingway",
                    --filter = "",
                    width = 90,
                    height = 14,
                    spacing = 4,
                    maxrow = 10,
                    showDistance = true,
                    showTimer = true,
                    showRank = true,
                    sortBy = "asc", -- "timer", "distance", or nil (no sort)
                    sortOrder = "desc", -- "asc" or "desc"
                    alignment = "center",
                    raidAnnounce = true, -- Send raid message when debuff is gained
                    colors = {
                        bgColor = { 0.1, 0.2, 0.1, 0.9 },
                        borderColor = { 0.2, 0.8, 0.2, 1 },
                        titleColor = { 0.4, 1, 0.4, 1 }
                    }
                }
            }
        },
        ["孟菲斯托斯"] = {
            name = "孟菲斯托斯",
            columns = {
                {
                    title = "噩梦爬行者",
                    filter = "mob:噩梦爬行者",
                    width = 90,
                    height = 14,
                    spacing = 4,
                    maxrow = 10,
                    showDistance = true,
                    showTimer = false,
                    showRank = false,
                    sortBy = "distance", -- "timer", "distance", or nil (no sort)
                    sortOrder = "asc", -- "asc" or "desc"
                    alignment = "center",
                    raidAnnounce = true, -- Send raid message when mob spawns
                    colors = {
                        bgColor = { 0.3, 0.1, 0.3, 0.9 },
                        borderColor = { 0.8, 0.2, 0.8, 1 },
                        titleColor = { 1, 0.4, 1, 1 }
                    }
                },
            }
        },
        ["桑夫·塔斯达尔"] = {
            name = "桑夫·塔斯达尔",
            columns = {
                {
                    title = "德莱尼虚无行者",
                    filter = "mob:德莱尼虚无行者",
                    width = 90,
                    height = 14,
                    spacing = 4,
                    maxrow = 10,
                    showDistance = true,
                    showTimer = false,
                    showRank = false,
                    sortBy = "distance", -- "timer", "distance", or nil (no sort)
                    sortOrder = "asc", -- "asc" or "desc"
                    alignment = "center",
                    raidAnnounce = true, -- Send raid message when mob spawns
                    colors = {
                        bgColor = { 0.3, 0.1, 0.3, 0.9 },
                        borderColor = { 0.8, 0.2, 0.8, 1 },
                        titleColor = { 1, 0.4, 1, 1 }
                    }
                },
            }
        },
    },

    -- Aura icon and duration mappings
    auras = {
        ["watershield"] = { icon = "Interface\\Icons\\Ability_Shaman_WaterShield", duration = 0 },
        ["naturehealingway"] = { icon = "Interface\\Icons\\Spell_Nature_HealingWay", duration = 15 },
        ["bandage"] = { icon = "Interface\\Icons\\INV_Misc_Bandage_08", duration = 60 },
        ["arcaneoverload"] = { icon = "Interface\\Icons\\Spell_Nature_WispSplode", duration = 15 },
        ["arcanedampening"] = { icon = "Interface\\Icons\\Spell_Nature_AbolishMagic", duration = 45 },
        ["inthecircle"] = { icon = "Interface\\Icons\\Spell_Nature_WispSplode", duration = 15 },
        ["frostblast"] = { icon = "Interface\\Icons\\Spell_Frost_FreezingBreath", duration = 0 },
        ["shadowworddominate"] = { icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate", duration = 0 },
        ["brokenheart"] = { icon = "Interface\\Icons\\Spell_BrokenHeart", duration = 0 },
        ["shadowraisedead"] = { icon = "Interface\\Icons\\Spell_Shadow_RaiseDead", duration = 25 },
        ["shadowantishadow"] = { icon = "Interface\\Icons\\Spell_Shadow_AntiShadow", duration = 20 },
        ["shadowegg"] = { icon = "Interface\\Icons\\INV_Misc_ShadowEgg", duration = 0 },
    },
}

-- ============================================================================
-- USER SETTINGS DEFAULTS (These are what gets saved to disk)
-- Only stores: enabled states, positions - NOT the detailed buff/debuff configs
-- ============================================================================
local userSettingsDefaults = {
    -- Addon enabled state
    enabled = true,
    -- Debug mode
    debug = false,
    -- Raid announce enabled (sends raid message when debuff is gained)
    raidAnnounceEnabled = true,
    -- Death watch enabled (warns when many players die quickly)
    deathWatchEnabled = true,
    -- Global display scale (user configurable)
    globalScale = nil, -- nil means use codeDefaults.globalScale
    -- Single frame position (shared across all bosses)
    framePosition = nil,
    -- Per-boss user settings (only enabled states and position overrides)
    -- Format: bossSettings[bossName] = { enabled = true, columns = { [1] = true, [2] = false } }
    bossSettings = {},
}

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Check if a boss exists in code-defined layouts
RunAway.IsDeclaredBoss = function(bossName)
    return RunAway.codeDefaults.bossLayouts[bossName] ~= nil
end

-- Get the effective layout for a boss (code-defined with user settings applied)
-- Returns nil if boss doesn't exist in code
RunAway.GetBossLayout = function(bossName)
    local codeLayout = RunAway.codeDefaults.bossLayouts[bossName]
    if not codeLayout then
        return nil  -- Boss doesn't exist in code, ignore
    end

    -- Get user settings for this boss (if any)
    local userSettings = RunAway_db.bossSettings and RunAway_db.bossSettings[bossName]

    -- Create a merged layout (code-defined + user enabled states)
    local layout = {
        name = codeLayout.name,
        columns = {}
    }

    -- Copy columns from code, applying user enabled states
    for i, codeColumn in ipairs(codeLayout.columns) do
        local column = {}
        -- Copy all code-defined properties
        for k, v in pairs(codeColumn) do
            column[k] = v
        end
        -- Apply user's enabled setting (default to true if not set)
        if userSettings and userSettings.columns and userSettings.columns[i] ~= nil then
            column.enabled = userSettings.columns[i]
        else
            column.enabled = true  -- Default enabled
        end
        layout.columns[i] = column
    end

    return layout
end

-- Get user's enabled state for a boss
RunAway.IsBossEnabled = function(bossName)
    -- First check if boss exists in code
    if not RunAway.IsDeclaredBoss(bossName) then
        return false
    end

    local userSettings = RunAway_db.bossSettings and RunAway_db.bossSettings[bossName]
    if userSettings and userSettings.enabled ~= nil then
        return userSettings.enabled
    end
    return true  -- Default enabled
end

-- Set user's enabled state for a boss
RunAway.SetBossEnabled = function(bossName, enabled)
    -- Only allow setting for bosses that exist in code
    if not RunAway.IsDeclaredBoss(bossName) then
        return
    end

    if not RunAway_db.bossSettings then
        RunAway_db.bossSettings = {}
    end
    if not RunAway_db.bossSettings[bossName] then
        RunAway_db.bossSettings[bossName] = { enabled = true, columns = {} }
    end
    RunAway_db.bossSettings[bossName].enabled = enabled
end

-- Get user's enabled state for a column
RunAway.IsColumnEnabled = function(bossName, columnIndex)
    -- First check if boss exists in code
    if not RunAway.IsDeclaredBoss(bossName) then
        return false
    end

    -- If boss is disabled, all columns are disabled
    if not RunAway.IsBossEnabled(bossName) then
        return false
    end

    local userSettings = RunAway_db.bossSettings and RunAway_db.bossSettings[bossName]
    if userSettings and userSettings.columns and userSettings.columns[columnIndex] ~= nil then
        return userSettings.columns[columnIndex]
    end
    return true  -- Default enabled
end

-- Set user's enabled state for a column
RunAway.SetColumnEnabled = function(bossName, columnIndex, enabled)
    -- Only allow setting for bosses that exist in code
    if not RunAway.IsDeclaredBoss(bossName) then
        return
    end

    if not RunAway_db.bossSettings then
        RunAway_db.bossSettings = {}
    end
    if not RunAway_db.bossSettings[bossName] then
        RunAway_db.bossSettings[bossName] = { enabled = true, columns = {} }
    end
    if not RunAway_db.bossSettings[bossName].columns then
        RunAway_db.bossSettings[bossName].columns = {}
    end
    RunAway_db.bossSettings[bossName].columns[columnIndex] = enabled
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Initialize saved variables with defaults
-- Must wait for VARIABLES_LOADED event since saved variables load after addon code
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("VARIABLES_LOADED")
initFrame:SetScript("OnEvent", function()
    if not RunAway_db then
        RunAway_db = {}
    end

    -- Apply default user settings if not present
    if RunAway_db.enabled == nil then
        RunAway_db.enabled = userSettingsDefaults.enabled
    end
    if RunAway_db.debug == nil then
        RunAway_db.debug = userSettingsDefaults.debug
    end
    if RunAway_db.raidAnnounceEnabled == nil then
        RunAway_db.raidAnnounceEnabled = userSettingsDefaults.raidAnnounceEnabled
    end
    if RunAway_db.deathWatchEnabled == nil then
        RunAway_db.deathWatchEnabled = userSettingsDefaults.deathWatchEnabled
    end
    if not RunAway_db.bossSettings then
        RunAway_db.bossSettings = {}
    end

    -- Clean up any boss settings for bosses that no longer exist in code
    for bossName in pairs(RunAway_db.bossSettings) do
        if not RunAway.IsDeclaredBoss(bossName) then
            RunAway_db.bossSettings[bossName] = nil
        end
    end

    this:UnregisterEvent("VARIABLES_LOADED")
end)

-- Also ensure RunAway_db exists for other files that load after this one
if not RunAway_db then
    RunAway_db = {}
end

-- Shared UI templates
RunAway.templates = {
    border = {
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    },
    background = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    }
}

-- ============================================================================
-- RAID ANNOUNCE
-- ============================================================================

-- Format player name as clickable link
local function FormatPlayerLink(playerName)
    if not playerName then
        return ""
    end
    -- Format: |cffffffff|Hplayer:Name|h[Name]|h|r
    return string.format("|cffffffff|Hplayer:%s|h[%s]|h|r", playerName, playerName)
end

-- Send raid announcement for debuff gain
-- playerNames: table of player names who gained the debuff
-- title: the column title (debuff name to announce)
-- titleColor: optional RGB color array {r, g, b, a} for the title
RunAway.SendRaidAnnounce = function(playerNames, title, titleColor)
    -- Check if raid announce is enabled
    if not RunAway_db or not RunAway_db.raidAnnounceEnabled then
        return
    end

    -- Must be in a raid
    if GetNumRaidMembers() == 0 then
        return
    end

    -- Build the message with player links
    if not playerNames or table.getn(playerNames) == 0 then
        return
    end

    local playerLinks = {}
    for _, name in ipairs(playerNames) do
        table.insert(playerLinks, FormatPlayerLink(name))
    end

    -- Convert RGB to color code |cAARRGGBB
    local colorCode = "|cffff0000"  -- Default red
    if titleColor then
        local r = titleColor[1] or 1
        local g = titleColor[2] or 0
        local b = titleColor[3] or 0
        local a = titleColor[4] or 1
        -- Format: AA (alpha) RR GG BB in hex
        colorCode = string.format("|c%02x%02x%02x%02x",
                a * 255, r * 255, g * 255, b * 255)
    end

    -- Format: [Player1] [Player2] title!
    local message = table.concat(playerLinks, " ") .. " " .. colorCode .. (title or "debuff") .. "!|r"
    SendChatMessage(message, "RAID")
end

-- Send raid announcement for mob spawn
-- count: number of mobs that spawned
-- title: the column title (mob name to announce)
-- titleColor: optional RGB color array {r, g, b, a} for the title
RunAway.SendMobRaidAnnounce = function(count, title, titleColor)
    -- Check if raid announce is enabled
    if not RunAway_db or not RunAway_db.raidAnnounceEnabled then
        return
    end

    -- Must be in a raid
    if GetNumRaidMembers() == 0 then
        return
    end

    if not count or count == 0 then
        return
    end

    -- Convert RGB to color code |cAARRGGBB
    local colorCode = "|cffff0000"  -- Default red
    if titleColor then
        local r = titleColor[1] or 1
        local g = titleColor[2] or 0
        local b = titleColor[3] or 0
        local a = titleColor[4] or 1
        colorCode = string.format("|c%02x%02x%02x%02x",
                a * 255, r * 255, g * 255, b * 255)
    end

    -- Format: "噩梦爬行者 出现了! x3" or "噩梦爬行者 出现了!" (if only 1)
    local message = colorCode .. (title or "mob") .. " 出现了!|r"
    if count > 1 then
        message = colorCode .. (title or "mob") .. " 出现了! x" .. count .. "|r"
    end
    SendChatMessage(message, "RAID")
end

-- Get column config by auraId (filter key)
RunAway.GetColumnByAuraId = function(auraId)
    for bossName, layout in pairs(RunAway.codeDefaults.bossLayouts) do
        for colIndex, column in ipairs(layout.columns) do
            -- Extract aura key from filter (e.g., "aura:arcaneoverload" -> "arcaneoverload")
            local filterAuraId = column.filter and string.gsub(column.filter, "^aura:", "")
            if filterAuraId == auraId then
                return column, bossName, colIndex
            end
        end
    end
    return nil
end

if not GetPlayerBuffID or not CombatLogAdd or not SpellInfo then
    local notify = CreateFrame("Frame", nil, UIParent)
    notify:SetScript("OnUpdate", function()
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00快|cffffffff跑！|cffffaaaa 未检测到SuperWoW。")
        this:Hide()
    end)

    RunAway.disabled = true
end