-- 引入服务器配置 (baseResetTime均设置为北京时间)
local SERVER_CONFIGS = {
        
    --群星盆地配置
    ["Basin of Stars"] = {
        -- 7天冷却副本
        [1] = {name = "熔火之心", resetDays = 7, baseResetTime = 1784174400}, -- 2026年7月16日中午12点
        [2] = {name = "黑翼之巢", resetDays = 7, baseResetTime = 1784174400},
        [3] = {name = "安其拉神殿", resetDays = 7, baseResetTime = 1784174400},
        [4] = {name = "纳克萨玛斯", resetDays = 7, baseResetTime = 1784174400},
        [5] = {name = "翡翠圣殿", resetDays = 7, baseResetTime = 1784174400},
        [6] = {name = "卡拉赞之塔", resetDays = 7, baseResetTime = 1784174400},
		[11] = {name = "木喉要塞", resetDays = 7, baseResetTime = 1784174400}, 
        
        -- 5天冷却副本
        [7] = {name = "卡拉赞下层大厅", resetDays = 5, baseResetTime = 1784260800}, -- 2026年7月17日中午12点
        [8] = {name = "奥妮克希亚的巢穴", resetDays = 5, baseResetTime = 1784260800},
        
        -- 3天冷却副本
        [9] = {name = "祖尔格拉布", resetDays = 3, baseResetTime = 1784347200}, -- 2026年7月18日中午12点
        [10] = {name = "安其拉废墟", resetDays = 3, baseResetTime = 1784347200}
    },  
        
    -- 基赫纳斯配置
    ["Gehennas"] = {
        -- 7天冷却副本
        [1] = {name = "熔火之心", resetDays = 7, baseResetTime = 1761537600}, --2025年10月27日中午12点
        [2] = {name = "黑翼之巢", resetDays = 7, baseResetTime = 1761537600},
        [3] = {name = "安其拉神殿", resetDays = 7, baseResetTime = 1761537600},
        -- [4] = {name = "纳克萨玛斯", resetDays = 7, baseResetTime = 1761537600},
        [5] = {name = "翡翠圣殿", resetDays = 7, baseResetTime = 1761537600},
        -- [6] = {name = "卡拉赞之塔", resetDays = 7, baseResetTime = 1761537600},
        
        -- 5天冷却副本
        [7] = {name = "卡拉赞下层大厅", resetDays = 5, baseResetTime = 1774065600}, 
        [8] = {name = "奥妮克希亚的巢穴", resetDays = 5, baseResetTime = 1774065600}, --2026年3月21日中午12点
        
        -- -- 3天冷却副本
        [9] = {name = "祖尔格拉布", resetDays = 3, baseResetTime = 1769486400}, --2026年1月27日中午12点
        [10] = {name = "安其拉废墟", resetDays = 3, baseResetTime = 1769486400}
    },
	
	--永歌荒野
	["Eversong Wilds"] = {       
		-- 7天冷却副本
        [1] = {name = "熔火之心", resetDays = 7, baseResetTime = 1782014400}, --2026年6月21日中午12点
        -- [2] = {name = "黑翼之巢", resetDays = 7, baseResetTime = 1760673600},
        -- [3] = {name = "安其拉神殿", resetDays = 7, baseResetTime = 1760673600},
        -- [4] = {name = "纳克萨玛斯", resetDays = 7, baseResetTime = 1760673600},
        -- [5] = {name = "翡翠圣殿", resetDays = 7, baseResetTime = 1760673600},
        -- [6] = {name = "卡拉赞之塔", resetDays = 7, baseResetTime = 1760673600},
		-- [11] = {name = "木喉要塞", resetDays = 7, baseResetTime = 1774584000}, 
        
        -- 5天冷却副本
        -- [7] = {name = "卡拉赞下层大厅", resetDays = 5, baseResetTime = 1760673600}, 
        [8] = {name = "奥妮克希亚的巢穴", resetDays = 5, baseResetTime = 1782014400},  --2026年6月21日中午12点
        
        -- -- 3天冷却副本
        -- [9] = {name = "祖尔格拉布", resetDays = 3, baseResetTime = 1760673600},
        -- [10] = {name = "安其拉废墟", resetDays = 3, baseResetTime = 1760673600}
    },		
	
	-- 特殊服务器
    -- ["XXXXXXX"] = {
        -- special = true, -- 添加特殊标记
        -- message = "目前无法获取服务器团本重置时间信息，后续更新"
		
		-- -- 7天冷却副本
        -- [1] = {name = "熔火之心", resetDays = 7, baseResetTime = 1757044800}, 
        -- [2] = {name = "黑翼之巢", resetDays = 7, baseResetTime = 1757044800},
        -- [3] = {name = "安其拉神殿", resetDays = 7, baseResetTime = 1757044800},
        -- [4] = {name = "纳克萨玛斯", resetDays = 7, baseResetTime = 1757044800},
        -- [5] = {name = "翡翠圣殿", resetDays = 7, baseResetTime = 1757044800},
        -- [6] = {name = "卡拉赞之塔", resetDays = 7, baseResetTime = 1757044800},
        
        -- -- 5天冷却副本
        -- [7] = {name = "卡拉赞下层大厅", resetDays = 5, baseResetTime = 1757217600},
        -- [8] = {name = "奥妮克希亚的巢穴", resetDays = 5, baseResetTime = 1757217600},
        
        -- -- 3天冷却副本
        -- [9] = {name = "祖尔格拉布", resetDays = 3, baseResetTime = 1757304000},
        -- [10] = {name = "安其拉废墟", resetDays = 3, baseResetTime = 1757304000}
    --},
}

-- 按重置周期分组（保持不变）
local RAID_GROUPS = {
    {
        name = "7天CD副本",
        color = "|cFFFF8000", -- 橙色
        raids = {1, 2, 3, 4, 5, 6, 11}
    },
    {
        name = "5天CD副本",
        color = "|cFF9370DB", -- 紫色
        raids = {7, 8}
    },
    {
        name = "3天CD副本",
        color = "|cFF0070DE", -- 蓝色
        raids = {9, 10}
    }
}

-- 暗月马戏团配置
local DARKMOON_FAIRE_CONFIG = {
    baseResetTime = 1779552000, -- 基准时间：2026年5月24日0点（北京时间），此时在雷霆崖
    resetDays = 7, -- 7天轮换一次
    locations = {
        [0] = "雷霆崖",
        [1] = "闪金镇"
    }
}

-- 祖格隐藏boss配置
local ZG_HIDDEN_BOSS_CONFIG = {
    baseResetTime = 1777910400, -- 基准时间：2026年5月5日0点（北京时间），此时是雷纳塔基
    resetDays = 14, -- 14天轮换一次（两周）
    bosses = {
        [0] = "雷纳塔基",
        [1] = "乌苏雷", 
        [2] = "格里雷克",
        [3] = "哈扎拉尔"
    }
}

-- 双倍战场配置
local BATTLEGROUND_BONUS_CONFIG = {
    baseResetTime = 1779465600, -- 基准时间：2026年5月23日0点（北京时间），此时是血环
    resetDays = 1, -- 1天轮换一次
    battlegrounds = {
        [0] = "血环竞技场",
        [1] = "荆棘峡谷", 
        [2] = "奥特兰克山谷",
        [3] = "战歌峡谷",
        [4] = "阿拉希盆地"
    }
}

-- 时区偏移（亚服服务器时间比本地时间慢7小时，欧服慢8小时)
--local SERVER_TIMEZONE_OFFSET = 7 * 3600

-- 获取当前服务器配置
local function GetCurrentServerConfig()
    local serverName = GetRealmName() or "默认"
    local config = SERVER_CONFIGS[serverName]
    
    -- 如果找不到当前服务器配置，使用默认配置
    if not config then
        config = SERVER_CONFIGS["默认"]
    end
    
    return config, serverName
end

-- 获取当前服务器的副本配置
local RAID_CONFIG, CURRENT_SERVER_NAME = GetCurrentServerConfig()

-- =============================================================================
-- 工具函数
-- =============================================================================

-- 获取本地时间(北京时间)
local function GetCurrentTime()
    return time()
end

-- 格式化剩余时间
local function FormatTimeLeft(timeLeft)
    if timeLeft <= 0 then return "已重置" end

    local days = math.floor(timeLeft / 86400)
    local hours = math.floor(math.mod(timeLeft, 86400) / 3600)
    local minutes = math.floor(math.mod(timeLeft, 3600) / 60)

    if days > 0 then
        return string.format("%d天%d小时%d分", days, hours, minutes)
    elseif hours > 0 then
        return string.format("%d小时%d分", hours, minutes)
    else
        return string.format("%d分钟", minutes)
    end
end

-- 计算下一个重置时间
local function CalculateNextResetTime(raidID)
    local config = RAID_CONFIG[raidID]
    if not config or not config.baseResetTime then return nil end
    
    --local currentTime = GetCurrentTime() - SERVER_TIMEZONE_OFFSET
	local currentTime = GetCurrentTime()
    local cycle = config.resetDays * 24 * 3600
    local baseTime = config.baseResetTime
    
    -- 计算下一个重置时间
    local timeSinceBase = currentTime - baseTime
    local cyclesSinceBase = math.floor(timeSinceBase / cycle)
    local nextReset = baseTime + (cyclesSinceBase + 1) * cycle
    
    -- 返回重置时间
    --return nextReset + SERVER_TIMEZONE_OFFSET
	return nextReset
end

-- 获取暗月马戏团信息
local function GetDarkmoonFaireInfo()
    local currentTime = GetCurrentTime()
    local cycle = DARKMOON_FAIRE_CONFIG.resetDays * 24 * 3600
    local baseTime = DARKMOON_FAIRE_CONFIG.baseResetTime
    
    -- 计算当前周期数
    local timeSinceBase = currentTime - baseTime
    local cyclesSinceBase = math.floor(timeSinceBase / cycle)
    
    -- 确定当前位置
    local currentLocation = DARKMOON_FAIRE_CONFIG.locations[math.mod(cyclesSinceBase, 2)]
    
    -- 计算下次轮换时间
    local nextReset = baseTime + (cyclesSinceBase + 1) * cycle
    local timeLeft = nextReset - currentTime
    
    -- 计算下次位置
    local nextLocation = DARKMOON_FAIRE_CONFIG.locations[math.mod(cyclesSinceBase + 1, 2)]
    
    return currentLocation, nextLocation, timeLeft
end

-- 获取祖格隐藏boss信息
local function GetZGHiddenBossInfo()
    local currentTime = GetCurrentTime()
    local cycle = ZG_HIDDEN_BOSS_CONFIG.resetDays * 24 * 3600
    local baseTime = ZG_HIDDEN_BOSS_CONFIG.baseResetTime
    
    -- 计算当前周期数
    local timeSinceBase = currentTime - baseTime
    local cyclesSinceBase = math.floor(timeSinceBase / cycle)
    
    -- 确定当前boss
    local currentBoss = ZG_HIDDEN_BOSS_CONFIG.bosses[math.mod(cyclesSinceBase, 4)]
    
    -- 计算下次轮换时间
    local nextReset = baseTime + (cyclesSinceBase + 1) * cycle
    local timeLeft = nextReset - currentTime
    
    -- 计算下次boss
    local nextBoss = ZG_HIDDEN_BOSS_CONFIG.bosses[math.mod(cyclesSinceBase + 1, 4)]
    
    return currentBoss, nextBoss, timeLeft
end

-- 获取双倍战场信息
local function GetBattlegroundBonusInfo()
    local currentTime = GetCurrentTime()
    local cycle = BATTLEGROUND_BONUS_CONFIG.resetDays * 24 * 3600
    local baseTime = BATTLEGROUND_BONUS_CONFIG.baseResetTime
    
    -- 计算当前周期数
    local timeSinceBase = currentTime - baseTime
    local cyclesSinceBase = math.floor(timeSinceBase / cycle)
    
    -- 确定当前战场
    local currentBattleground = BATTLEGROUND_BONUS_CONFIG.battlegrounds[math.mod(cyclesSinceBase, 5)]
    
    -- 计算下次轮换时间
    local nextReset = baseTime + (cyclesSinceBase + 1) * cycle
    local timeLeft = nextReset - currentTime
    
    -- 计算下次战场
    local nextBattleground = BATTLEGROUND_BONUS_CONFIG.battlegrounds[math.mod(cyclesSinceBase + 1, 5)]
    
    return currentBattleground, nextBattleground, timeLeft
end

-- 获取副本名称到ID的映射
local function CreateRaidNameToIDMap()
    local map = {}
    for id, config in pairs(RAID_CONFIG) do
        if type(config) == "table" and not config.special then -- 跳过特殊服务器
            map[config.name] = id
            -- 添加可能的英文名称
            if config.name == "熔火之心" then map["Molten Core"] = id
            elseif config.name == "黑翼之巢" then map["Blackwing Lair"] = id
            elseif config.name == "安其拉神殿" then map["Ahn'Qiraj Temple"] = id
            elseif config.name == "纳克萨玛斯" then map["Naxxramas"] = id
            elseif config.name == "翡翠圣殿" then map["Emerald Sanctum"] = id
            elseif config.name == "卡拉赞之塔" then map["Tower of Karazhan"] = id
            elseif config.name == "卡拉赞下层大厅" then map["Lower Karazhan Halls"] = id
            elseif config.name == "奥妮克希亚的巢穴" then map["Onyxia's Lair"] = id
            elseif config.name == "祖尔格拉布" then map["Zul'Gurub"] = id
            elseif config.name == "安其拉废墟" then map["Ruins of Ahn'Qiraj"] = id
			elseif config.name == "木喉要塞" then map["Timbermaw Hold"] = id
            end
        end
    end
    return map
end

local RAID_NAME_TO_ID = CreateRaidNameToIDMap()

-- =============================================================================
-- 界面创建
-- =============================================================================

-- 创建界面元素
local diminfo_RaidCD = CreateFrame("Button", "diminfo_RaidCD", UIParent)
local Text = diminfo_RaidCD:CreateFontString(nil, "OVERLAY")
Text:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
Text:SetPoint("RIGHT", diminfo_Time, "LEFT", -20, 0)
diminfo_RaidCD:SetAllPoints(Text)

-- 存储副本锁定状态
local myList = {}
local lastUpdateTime = 0

-- =============================================================================
-- 核心功能
-- =============================================================================

-- 获取玩家等级
local function GetPlayerLevel()
    return UnitLevel("player")
end

-- 检查是否是满级玩家
local function IsMaxLevelPlayer()
    return GetPlayerLevel() >= 60
end

-- 获取副本锁定状态
local function GetMySavedInstances()
    -- 如果是特殊服务器，不需要获取副本信息
    if RAID_CONFIG.special then
        return
    end
	
	-- 如果不是满级玩家，不需要获取副本信息
    if not IsMaxLevelPlayer() then
        return
    end
    
    local n = GetNumSavedInstances()
    
    -- 清空之前的列表
    for id, _ in pairs(RAID_CONFIG) do
        if type(RAID_CONFIG[id]) == "table" then -- 只处理正常的副本配置
            myList[id] = 0 -- 0表示未锁定
        end
    end
    
    -- 检查已保存的副本
    for i = 1, n do
        local instanceName, lockedId, reset = GetSavedInstanceInfo(i)
        
        if instanceName then
            -- 尝试通过名称查找副本ID
            local raidID = RAID_NAME_TO_ID[instanceName]
            
            -- 如果直接匹配失败，尝试模糊匹配
            if not raidID then
                for name, id in pairs(RAID_NAME_TO_ID) do
                    if string.find(instanceName, name) then
                        raidID = id
                        break
                    end
                end
            end
            
            if raidID then
                myList[raidID] = lockedId
            end
        end
    end
    
    lastUpdateTime = GetCurrentTime()
end

-- 更新显示文本
local function UpdateDisplay()
    -- 如果是特殊服务器，显示特殊文本
    if RAID_CONFIG.special then
        Text:SetText("|cff00ff00团本CD (N/A)|r")
        return
    end
	
	-- 如果不是满级玩家，显示简化文本
    if not IsMaxLevelPlayer() then
        Text:SetText("|cff00ff00活动信息|r")
        return
    end
    
    GetMySavedInstances()
    
    local lockedCount = 0
    for _, locked in pairs(myList) do
        if locked ~= 0 then
            lockedCount = lockedCount + 1
        end
    end
    
    Text:SetText("|cff00ff00团本CD (" .. lockedCount .. ")|r")
end

-- 强制刷新副本信息
local function ForceUpdateRaidData()
    -- 如果是特殊服务器，不需要刷新
    if RAID_CONFIG.special then
        return
    end
	
	-- 如果不是满级玩家，不需要刷新副本信息
    if not IsMaxLevelPlayer() then
        return
    end
    
    RequestRaidInfo() -- 请求更新副本信息
    UpdateDisplay() -- 立即更新显示
end

-- 获取数组长度（兼容1.12版本）
local function GetTableLength(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- 定义显示工具提示的函数
local function ShowRaidCDTooltip()
    GameTooltip:SetOwner(diminfo_RaidCD, "ANCHOR_BOTTOMRIGHT")
    GameTooltip:ClearLines()
    
    -- 如果是特殊服务器，显示特殊消息
    if RAID_CONFIG.special then
	    GameTooltip:AddLine("团本锁定状态 - " .. CURRENT_SERVER_NAME)
        GameTooltip:AddLine("|cffff0000" .. RAID_CONFIG.message .. "|r")
        GameTooltip:AddLine(" ")
        GameTooltip:Show()
        return
    end
    
    local currentTime = GetCurrentTime()
	local playerLevel = GetPlayerLevel()
	
	-- 如果不是满级玩家，只显示马戏团和双倍战场信息
    if not IsMaxLevelPlayer() then
        GameTooltip:AddLine("活动信息 - " .. CURRENT_SERVER_NAME .. " (等级 " .. playerLevel .. ")")
        GameTooltip:AddLine(" ")
        
        -- 添加暗月马戏团信息
        local currentLocation, nextLocation, timeLeft = GetDarkmoonFaireInfo()
        GameTooltip:AddLine("|cffff0000暗月马戏团|r")
        GameTooltip:AddLine("  当前: |cff00ff00" .. currentLocation .. "|r")
        GameTooltip:AddLine("  下次: |cff00ff00" .. nextLocation .. " (" .. FormatTimeLeft(timeLeft) .. ")|r")
        GameTooltip:AddLine(" ")
        
        -- 添加双倍战场信息
        local currentBG, nextBG, bgTimeLeft = GetBattlegroundBonusInfo()
        GameTooltip:AddLine("|cffff0000双倍战场|r")
        GameTooltip:AddLine("  今日: |cff00ff00" .. currentBG .. "|r")
        GameTooltip:AddLine("  明日: |cff00ff00" .. nextBG .. " (" .. FormatTimeLeft(bgTimeLeft) .. ")|r")
        GameTooltip:AddLine(" ")
        
        -- 添加提示信息
        GameTooltip:AddLine("达到60级后显示完整团本信息", .3, 1, .6)
        GameTooltip:AddLine("左键:集合石", .3, 1, .6)
        
        GameTooltip:Show()
        return
    end
    
    -- 满级玩家显示完整信息
    GameTooltip:AddLine("团本锁定状态 - " .. CURRENT_SERVER_NAME)
    
    -- 按重置周期分组显示副本状态
    for _, group in ipairs(RAID_GROUPS) do
        -- 添加组标题
        GameTooltip:AddLine(group.color .. group.name .. "|r")
        
        -- 为每个副本单独显示重置时间
        for _, raidId in ipairs(group.raids) do
            local raidInfo = RAID_CONFIG[raidId]
            if raidInfo then
                local raidName = raidInfo.name
                local nextReset = CalculateNextResetTime(raidId)
                local timeLeft = nextReset and (nextReset - currentTime) or 0
                
                if myList[raidId] ~= 0 then
                    -- 副本已锁定，显示锁定ID和重置时间
                    GameTooltip:AddLine("  |cffff0000" .. raidName .. "|cffff0000 - 锁定ID: " .. myList[raidId] .. " (重置: " .. FormatTimeLeft(timeLeft) .. ")")
                else
                    -- 副本未锁定，显示重置时间
                    GameTooltip:AddLine("  |cff00ff00" .. raidName .. "|r - 未锁定 (重置: " .. FormatTimeLeft(timeLeft) .. ")")
                end
            end
        end
        GameTooltip:AddLine(" ")
    end    
	
    -- 添加暗月马戏团信息
    local currentLocation, nextLocation, timeLeft = GetDarkmoonFaireInfo()
    GameTooltip:AddLine("|cffff0000暗月马戏团|r")
    GameTooltip:AddLine("  当前: |cff00ff00" .. currentLocation .. "|r    下次: |cff00ff00" .. nextLocation .. " (" .. FormatTimeLeft(timeLeft) .. ")|r"  )
    --GameTooltip:AddLine("  下次轮换: |cff00ff00" .. nextLocation .. " (" .. FormatTimeLeft(timeLeft) .. ")|r")
    GameTooltip:AddLine(" ")
    
    -- 添加祖格隐藏boss信息
    local currentBoss, nextBoss, zgTimeLeft = GetZGHiddenBossInfo()
    GameTooltip:AddLine("|cffff0000祖格隐藏BOSS|r")
    GameTooltip:AddLine("  本轮: |cff00ff00" .. currentBoss .. "|r    下轮: |cff00ff00" .. nextBoss .. " (" .. FormatTimeLeft(zgTimeLeft) .. ")|r")
    --GameTooltip:AddLine("  下轮BOSS: |cff00ff00" .. nextBoss .. " (" .. FormatTimeLeft(zgTimeLeft) .. ")|r")
    GameTooltip:AddLine(" ")
    
    -- 添加双倍战场信息
    local currentBG, nextBG, bgTimeLeft = GetBattlegroundBonusInfo()
    GameTooltip:AddLine("|cffff0000双倍战场|r")
    GameTooltip:AddLine("  今日: |cff00ff00" .. currentBG .. "|r    明日: |cff00ff00" .. nextBG .. " (" .. FormatTimeLeft(bgTimeLeft) .. ")|r")
    --GameTooltip:AddLine("  明日战场: |cff00ff00" .. nextBG .. " (" .. FormatTimeLeft(bgTimeLeft) .. ")|r")
    GameTooltip:AddLine(" ")
    
    -- 添加最后更新时间
    GameTooltip:AddLine("最后更新: " .. date("%H:%M:%S", lastUpdateTime) .. ";  左键:集合石;  右键:手动刷新", .3, 1, .6)
    
    GameTooltip:Show()
end

-- 鼠标悬停显示详细信息
diminfo_RaidCD:SetScript("OnEnter", ShowRaidCDTooltip)

diminfo_RaidCD:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- 添加左键右键点击功能
diminfo_RaidCD:SetScript("OnMouseDown", function()
    if arg1 == "RightButton" then
        -- 如果是特殊服务器，不执行刷新操作
        if not RAID_CONFIG.special then
            ForceUpdateRaidData()
            ShowRaidCDTooltip()
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00团本CD信息已手动刷新|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000当前服务器暂不支持团本CD功能|r")
        end
    elseif arg1 == "LeftButton" then
        -- 左键点击打开集合石主界面
        if Meeting and Meeting.Toggle then
            Meeting:Toggle()
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000未找到集合石插件|r")
        end
    end
end)

-- =============================================================================
-- 事件触发
-- =============================================================================

-- 延时函数
local function Schedule(delay, func)
    local frame = CreateFrame("Frame")
    local elapsed = 0
    
    frame:SetScript("OnUpdate", function()        
        local sinceLastUpdate = arg1 or 0
        elapsed = elapsed + sinceLastUpdate
        if elapsed >= delay then
            func()
            this:SetScript("OnUpdate", nil)
        end
    end)
    
    return frame
end

-- 注册事件来更新显示
diminfo_RaidCD:RegisterEvent("PLAYER_ENTERING_WORLD")
diminfo_RaidCD:RegisterEvent("CHAT_MSG_SYSTEM")
diminfo_RaidCD:RegisterEvent("PLAYER_LEVEL_UP") -- 添加等级变化事件

diminfo_RaidCD:SetScript("OnEvent", function()
    local event = event
    local msg = arg1
    
    if event == "PLAYER_ENTERING_WORLD" then
        -- 重新获取服务器配置（可能在切换角色或服务器后变化）
        RAID_CONFIG, CURRENT_SERVER_NAME = GetCurrentServerConfig()
        RAID_NAME_TO_ID = CreateRaidNameToIDMap()
        
        -- 使用延时函数，等待2秒后更新数据
        Schedule(2, function()
            ForceUpdateRaidData()
        end)
		
	elseif event == "PLAYER_LEVEL_UP" then
        -- 玩家升级时更新显示
        UpdateDisplay()	
        
    elseif event == "CHAT_MSG_SYSTEM" then
        -- 调试信息
        --DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[DEBUG] 事件: "..tostring(event).." 消息: "..tostring(msg).."|r")
        
        -- 系统信息关键字触发
        if msg and (string.find(msg, "保存") or string.find(msg, "saved")) then
            --DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[DEBUG] 系统信息关键字触发，将更新数据|r")
            
            Schedule(2, function()                
                RequestRaidInfo()
            end)
            
            Schedule(4, function()                
                ForceUpdateRaidData()
            end)
			
			Schedule(6, function()                
                ForceUpdateRaidData()
            end)
        end
    end
end)

-- 初始显示
UpdateDisplay()