-- Config.lua - 副本进度检查插件配置文件
-- 包含副本配置、常量定义等静态数据

-- =============================================================================
-- 常量定义
-- =============================================================================

local LEVEL_THRESHOLD = 55         -- 存储角色信息的最低等级要求（改为1级）
local DISPLAY_LEVEL_THRESHOLD = 55 -- 显示角色进度的最低等级要求（改为55级）
local TIME_ERROR_MARGIN = 3600     -- 时间比较的误差容忍度（1小时），用于卡拉赞副本判断

-- 时区配置：乌龟服服务器在德国（+1时区），相对于本地时区的偏移量（秒）
-- 德国+1时区，香港+8时区，差7小时 = 7 * 3600 = 25200秒
local SERVER_TIMEZONE_OFFSET = -0 * 3600 -- 服务器时间比本地时间慢7小时

-- =============================================================================
-- 副本配置数据
-- =============================================================================

-- 副本名称到ID的映射表
local RAID_NAME_TO_ID = {
    -- 经典60级副本
    ["熔火之心"] = 409,
    ["黑翼之巢"] = 469,
    ["祖尔格拉布"] = 531,
    ["纳克萨玛斯"] = 533,
    ["奥妮克希亚的巢穴"] = 509,
    ["翡翠圣地"] = 540,
    ["安其拉废墟"] = 718,
    ["安其拉神殿"] = 719,
    ["卡拉赞下层大厅"] = 535,
    ["卡拉赞之塔"] = 536,
    -- 英文
    ["Molten Core"] = 409,
    ["Blackwing Lair"] = 469,
    ["Zul'Gurub"] = 531,
    ["Naxxramas"] = 533,
    ["Onyxia's Lair"] = 509,
    ["Emerald Sanctum"] = 540,
    ["Ruins of Ahn'Qiraj"] = 718,
    ["Temple of Ahn'Qiraj"] = 719,
    ["Tower of Karazhan"] = 536,
    ["Lower Karazhan Halls"] = 535,

}

-- 副本重置周期配置
local RAID_RESET_CYCLES = {
    -- 标准7天周期副本（周三中午12点重置）
    [409] = { name = "熔火之心", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
    [469] = { name = "黑翼之巢", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
    [719] = { name = "安其拉神殿", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
    [533] = { name = "纳克萨玛斯", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
    [540] = { name = "翡翠圣地", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
    [536] = { name = "卡拉赞之塔", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },

    -- 固定天数周期副本（使用baseResetTime作为基准）
    [531] = {
        name = "祖尔格拉布",
        cycle = 3 * 24 * 3600,     -- 3天重置周期
        resetDay = 0,              -- 0表示使用固定周期而非每周重置
        resetHour = 12,            -- 中午12点重置
        baseResetTime = 1748649600 -- 基准重置时间（2025年6月6日中午12点）
    },
    [509] = {
        name = "奥妮克希亚的巢穴",
        cycle = 5 * 24 * 3600, -- 5天重置周期
        resetDay = 0,
        resetHour = 12,
        baseResetTime = 1748736000 -- 基准重置时间（2025年6月7日中午12点）
    },
    [718] = {
        name = "安其拉废墟",
        cycle = 3 * 24 * 3600, -- 3天重置周期
        resetDay = 0,
        resetHour = 12,
        baseResetTime = 1748649600 -- 与祖尔格拉布同步
    },

    -- 特殊重置机制副本
    [535] = {
        name = "卡拉赞下层大厅",
        cycle = 5 * 24 * 3600, -- 主要重置周期：5天
        resetDay = 0,
        resetHour = 12,
        baseResetTime = 1748736000, -- 5天周期的基准时间
        weeklyResetDay = 4,         -- 同时参与周三统一重置
        weeklyResetHour = 12        -- 双重置机制：既有5天周期，也有周三重置
    },
}

-- =============================================================================
-- 周常任务配置数据
-- =============================================================================

-- 周常任务名称映射（中英文支持）
local WEEKLY_QUEST_NAMES = {
    -- 武装的召唤系列周常任务
    ["武装的召唤：净化腐化"] = "quest_1",
    ["武装的召唤：地下城探索"] = "quest_2", 
    ["武装的召唤：熔火突袭"] = "quest_3",
    -- 英文版本
    ["Call to Arms: Purge Corruption"] = "quest_1",
    ["Call to Arms: Dungeon Delving"] = "quest_2",
    ["Call to Arms: Molten Core Assault"] = "quest_3",
}

-- 周常任务重置配置
local WEEKLY_QUEST_RESET_CYCLES = {
    ["quest_1"] = { 
        name = "武装的召唤：净化腐化", 
        cycle = 7 * 24 * 3600, 
        resetDay = 5, -- 周四重置
        resetHour = 12 
    },
    ["quest_2"] = { 
        name = "武装的召唤：地下城探索", 
        cycle = 7 * 24 * 3600, 
        resetDay = 5, -- 周四重置
        resetHour = 12 
    },
    ["quest_3"] = { 
        name = "武装的召唤：熔火突袭", 
        cycle = 7 * 24 * 3600, 
        resetDay = 5, -- 周四重置
        resetHour = 12
    },
}

-- 周常任务分组配置
local WEEKLY_QUEST_GROUP = {
    name = "周常任务",
    color = "|cFFFFD700", -- 金色
    quests = { "calltoarms_corruption", "calltoarms_dungeon", "calltoarms_moltencore" }
}

-- =============================================================================
-- 服务器特定配置
-- =============================================================================

-- 服务器特定的副本重置时间配置
local SERVER_SPECIFIC_CONFIGS = {
    -- 拉风服务器配置
    ["Ravenstorm"] = {
        [409] = { name = "熔火之心", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [469] = { name = "黑翼之巢", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [719] = { name = "安其拉神殿", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [533] = { name = "纳克萨玛斯", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [540] = { name = "翡翠圣地", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [536] = { name = "卡拉赞之塔", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [531] = {
            name = "祖尔格拉布",
            cycle = 3 * 24 * 3600,
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749182400
        },
        [509] = {
            name = "奥妮克希亚的巢穴",
            cycle = 5 * 24 * 3600,
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749268800 -- 2025年6月7日中午12点
        },
        [718] = {
            name = "安其拉废墟",
            cycle = 3 * 24 * 3600,
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749182400
        },
        [535] = {
            name = "卡拉赞下层大厅",
            cycle = 5 * 24 * 3600,
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749268800, -- 2025年6月7日中午12点
            -- weeklyResetDay = 4,
            -- weeklyResetHour = 12
        },
    },

    -- 卡拉服务器配置
    ["Karazhan"] = {
        [409] = { name = "熔火之心", cycle = 7 * 24 * 3600, resetDay = 6, resetHour = 12 },
        [469] = { name = "黑翼之巢", cycle = 7 * 24 * 3600, resetDay = 6, resetHour = 12 },
        [719] = { name = "安其拉神殿", cycle = 7 * 24 * 3600, resetDay = 6, resetHour = 12 },
        [533] = { name = "纳克萨玛斯", cycle = 7 * 24 * 3600, resetDay = 6, resetHour = 12 },
        [540] = { name = "翡翠圣地", cycle = 7 * 24 * 3600, resetDay = 6, resetHour = 12 },
        [536] = { name = "卡拉赞之塔", cycle = 7 * 24 * 3600, resetDay = 6, resetHour = 12 },
        [531] = {
            name = "祖尔格拉布",
            cycle = 3 * 24 * 3600,
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749268800 -- 2025年6月7日中午12点
        },
        [509] = {
            name = "奥妮克希亚的巢穴",
            cycle = 5 * 24 * 3600,
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749441600 -- 2025年6月9日中午12点
        },
        [718] = {
            name = "安其拉废墟",
            cycle = 3 * 24 * 3600,
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749268800 -- 与祖尔格拉布同步，2025年6月7日中午12点
        },
        [535] = {
            name = "卡拉赞下层大厅",
            cycle = 5 * 24 * 3600,
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749441600, -- 2025年6月9日中午12点
            -- weeklyResetDay = 6,         -- 周五重置（改为与其他副本一致）
            -- weeklyResetHour = 12
        },
    },

    ["Blood Ring"] = {
        [409] = { name = "熔火之心", cycle = 7 * 24 * 3600, resetDay = 5, resetHour = 12 },
        [469] = { name = "黑翼之巢", cycle = 7 * 24 * 3600, resetDay = 5, resetHour = 12 },
        [719] = { name = "安其拉神殿", cycle = 7 * 24 * 3600, resetDay = 5, resetHour = 12 },
        [533] = { name = "纳克萨玛斯", cycle = 7 * 24 * 3600, resetDay = 5, resetHour = 12 },
        [540] = { name = "翡翠圣地", cycle = 7 * 24 * 3600, resetDay = 5, resetHour = 12 },
        [536] = { name = "卡拉赞之塔", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [531] = {
            name = "祖尔格拉布",
            cycle = 3 * 24 * 3600,
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749355200 -- 2025年6月8日中午12点
        },
        [509] = {
            name = "奥妮克希亚的巢穴",
            cycle = 5 * 24 * 3600,
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749441600 -- 2025年6月9日中午12点
        },
        [718] = {
            name = "安其拉废墟",
            cycle = 3 * 24 * 3600,
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749355200 -- 与祖尔格拉布同步，2025年6月8日中午12点
        },
        [535] = {
            name = "卡拉赞下层大厅",
            cycle = 5 * 24 * 3600,
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749441600, -- 2025年6月9日中午12点
            -- weeklyResetDay = 4,         -- 周三重置
            -- weeklyResetHour = 12
        },
    },
    --欧服Nordanaar
    ["Nordanaar"] = {
        [409] = { name = "熔火之心", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [469] = { name = "黑翼之巢", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [719] = { name = "安其拉神殿", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [533] = { name = "纳克萨玛斯", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [540] = { name = "翡翠圣地", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [536] = { name = "卡拉赞之塔", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },

        -- 固定天数周期副本（使用baseResetTime作为基准）
        [531] = {
            name = "祖尔格拉布",
            cycle = 3 * 24 * 3600,     -- 3天重置周期
            resetDay = 0,              -- 0表示使用固定周期而非每周重置
            resetHour = 12,            -- 中午12点重置
            baseResetTime = 1749268800 -- 2025年6月7日中午12点
        },
        [509] = {
            name = "奥妮克希亚的巢穴",
            cycle = 5 * 24 * 3600, -- 5天重置周期
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749355200 -- 基准重置时间（2025年6月8日中午12点，比Ravenstorm晚一天）
        },
        [718] = {
            name = "安其拉废墟",
            cycle = 3 * 24 * 3600, -- 3天重置周期
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749268800 -- 2025年6月7日中午12点
        },

        -- 特殊重置机制副本
        [535] = {
            name = "卡拉赞下层大厅",
            cycle = 5 * 24 * 3600, -- 主要重置周期：5天
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1749441600, -- 2025年6月9日中午12点
        },
    },
    -- 默认配置（用于未知服务器）
    ["默认"] = {
        [409] = { name = "熔火之心", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [469] = { name = "黑翼之巢", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [719] = { name = "安其拉神殿", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [533] = { name = "纳克萨玛斯", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [540] = { name = "翡翠圣地", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },
        [536] = { name = "卡拉赞之塔", cycle = 7 * 24 * 3600, resetDay = 4, resetHour = 12 },

        -- 固定天数周期副本（使用baseResetTime作为基准）
        [531] = {
            name = "祖尔格拉布",
            cycle = 3 * 24 * 3600,     -- 3天重置周期
            resetDay = 0,              -- 0表示使用固定周期而非每周重置
            resetHour = 12,            -- 中午12点重置
            baseResetTime = 1748649600 -- 基准重置时间（2025年6月6日中午12点）
        },
        [509] = {
            name = "奥妮克希亚的巢穴",
            cycle = 5 * 24 * 3600, -- 5天重置周期
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1748736000 -- 基准重置时间（2025年6月7日中午12点）
        },
        [718] = {
            name = "安其拉废墟",
            cycle = 3 * 24 * 3600, -- 3天重置周期
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1748649600 -- 与祖尔格拉布同步
        },

        -- 特殊重置机制副本
        [535] = {
            name = "卡拉赞下层大厅",
            cycle = 5 * 24 * 3600, -- 主要重置周期：5天
            resetDay = 0,
            resetHour = 12,
            baseResetTime = 1748736000, -- 5天周期的基准时间
            -- weeklyResetDay = 4,         -- 同时参与周三统一重置
            -- weeklyResetHour = 12        -- 双重置机制：既有5天周期，也有周三重置
        },
    }
}

-- 职业颜色配置
local CLASS_COLORS = {
    ["战士"] = "|cFFC79C6E", -- 棕色
    ["圣骑士"] = "|cFFF58CBA", -- 粉色
    ["猎人"] = "|cFFABD473", -- 绿色
    ["盗贼"] = "|cFFFFF569", -- 黄色
    ["牧师"] = "|cFFFFFFFF", -- 白色
    ["萨满祭司"] = "|cFF0070DE", -- 蓝色
    ["法师"] = "|cFF69CCF0", -- 浅蓝色
    ["术士"] = "|cFF9482C9", -- 紫色
    ["德鲁伊"] = "|cFFFF7D0A" -- 橙色
}

-- 副本分组配置
local RAID_GROUPS = {
    {
        name = "短周期副本",
        color = "|cFF0070DE", -- 蓝色
        raids = { 531, 718 }  -- 祖尔格拉布, 安其拉废墟
    },
    {
        name = "中周期副本",
        color = "|cFF9370DB", -- 紫色
        raids = { 535, 509 }  -- 卡拉赞下层, 奥妮克希亚的巢穴
    },
    {
        name = "周重置副本",
        color = "|cFFFF0000",                    -- 红色
        raids = { 409, 469, 719, 533, 540, 536 } -- 其他周重置副本
    }
}

-- 获取当前服务器的副本重置配置
local function GetServerRaidConfig()
    local serverName = GetRealmName()

    local config = SERVER_SPECIFIC_CONFIGS[serverName]

    if not config then
        -- 如果找不到当前服务器配置，使用默认配置
        config = SERVER_SPECIFIC_CONFIGS["默认"]
        if not config then
            -- 如果默认配置也不存在，返回原有配置
            config = RAID_RESET_CYCLES
        end
    end

    return config
end

-- 导出配置给其他模块使用
RaidProgressConfig = {
    LEVEL_THRESHOLD = LEVEL_THRESHOLD,
    DISPLAY_LEVEL_THRESHOLD = DISPLAY_LEVEL_THRESHOLD,
    TIME_ERROR_MARGIN = TIME_ERROR_MARGIN,
    SERVER_TIMEZONE_OFFSET = SERVER_TIMEZONE_OFFSET,
    RAID_NAME_TO_ID = RAID_NAME_TO_ID,
    RAID_RESET_CYCLES = RAID_RESET_CYCLES, -- 保留原有配置作为备用
    CLASS_COLORS = CLASS_COLORS,
    RAID_GROUPS = RAID_GROUPS,
    SERVER_SPECIFIC_CONFIGS = SERVER_SPECIFIC_CONFIGS,
    WEEKLY_QUEST_NAMES = WEEKLY_QUEST_NAMES,
    WEEKLY_QUEST_RESET_CYCLES = WEEKLY_QUEST_RESET_CYCLES,
    WEEKLY_QUEST_GROUP = WEEKLY_QUEST_GROUP,
    GetServerRaidConfig = GetServerRaidConfig
}