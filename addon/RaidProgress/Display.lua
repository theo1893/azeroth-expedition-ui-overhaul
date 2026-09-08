-- filepath: c:\游戏\TurtleWoW\Interface\AddOns\RaidProgress\Display.lua
-- Display.lua - 显示相关函数

-- 格式化角色副本进度显示
function FormatCharacterProgress(charData, raidConfigs)
    if not charData or not charData.raids then return "无数据" end
    
    local result = {}
    for raidID, config in pairs(raidConfigs) do
        local progress = charData.raids[raidID]
        if progress then
            local status = progress.completed and "已完成" or "未完成"
            table.insert(result, config.name .. ":" .. status)
        end
    end
    
    return table.concat(result, ", ")
end

-- 格式化重置时间显示
function FormatResetTime(timestamp)
    if not timestamp or timestamp <= 0 then return "已重置" end
    
    local timeLeft = timestamp - time()
    if timeLeft <= 0 then return "已重置" end
    
    local days = math.floor(timeLeft / 86400)
    local hours = math.floor((timeLeft - days * 86400) / 3600)
    local minutes = math.floor((timeLeft - days * 86400 - hours * 3600) / 60)
    
    if days > 0 then
        return string.format("%d天%d小时", days, hours)
    elseif hours > 0 then
        return string.format("%d小时%d分钟", hours, minutes)
    else
        return string.format("%d分钟", minutes)
    end
end

-- 格式化周常任务状态显示
function FormatWeeklyQuestStatus(questData)
    if not questData then return "无数据" end
    
    local result = {}
    for questID, questInfo in pairs(questData) do
        local status = questInfo.completed and "|cFF00FF00已完成|r" or "|cFFFF0000未完成|r"
        local questName = questInfo.questName or ("任务" .. questID)
        table.insert(result, questName .. ":" .. status)
    end
    
    return table.concat(result, ", ")
end

-- 导出函数
_G.FormatCharacterProgress = FormatCharacterProgress
_G.FormatResetTime = FormatResetTime
_G.FormatWeeklyQuestStatus = FormatWeeklyQuestStatus

-- 创建 RaidProgressDisplay 对象以保持兼容性
RaidProgressDisplay = {
    FormatTimeLeft = FormatResetTime,
    FormatCharacterProgress = FormatCharacterProgress,
    FormatWeeklyQuestStatus = FormatWeeklyQuestStatus,
    
    -- 获取副本名称通过ID
    GetRaidNameByID = function(raidID)
        if not RaidProgressConfig or not RaidProgressConfig.RAID_NAME_TO_ID then
            return "未知副本"
        end
        
        for name, id in pairs(RaidProgressConfig.RAID_NAME_TO_ID) do
            if id == raidID then
                return name
            end
        end
        return "未知副本 (ID:" .. tostring(raidID) .. ")"
    end,
    
    -- 打印分隔线
    PrintSeparator = function()
        print("=" .. string.rep("=", 50))
    end,
    
    -- 打印角色头部信息
    PrintCharacterHeader = function(fullName, class, level)
        local colorCode = ""
        if RaidProgressConfig and RaidProgressConfig.CLASS_COLORS then
            colorCode = RaidProgressConfig.CLASS_COLORS[class] or "|cFFFFFFFF"
        end
        print(string.format("%s%s|r (等级 %d)", colorCode, fullName, level or 0))
    end,
    
    -- 简化的进度显示函数
    PrintCharacterProgressByGroup = function(charData)
        if not charData or not charData.progress then
            return false
        end
        
        local hasProgress = false
        local currentTime = time()
        
        for raidID, progressData in pairs(charData.progress) do
            if progressData.resetTime and progressData.resetTime > currentTime then
                hasProgress = true
                local raidName = RaidProgressDisplay.GetRaidNameByID(raidID)
                local timeLeft = progressData.resetTime - currentTime
                print(string.format("  %s: %s", raidName, FormatResetTime(timeLeft)))
            end
        end
        
        return hasProgress
    end,
    
    -- 打印角色周常任务状态
    PrintCharacterWeeklyQuests = function(charData, fullName)
        if not charData or not charData.weeklyQuests then
            return false
        end
        
        local hasQuests = false
        for questID, questInfo in pairs(charData.weeklyQuests) do
            if not hasQuests then
                print(string.format("  |cFFFFAA00周常任务:|r"))
                hasQuests = true
            end
            
            local statusColor = questInfo.completed and "|cFF00FF00" or "|cFFFF0000"
            local statusText = questInfo.completed and "已完成" or "未完成"
            local questName = questInfo.questName or ("任务" .. questID)
            
            print(string.format("    %s - %s%s|r", questName, statusColor, statusText))
            
            -- 显示重置时间信息
            if questInfo.resetTime and questInfo.resetTime > 0 then
                local resetText = FormatResetTime(questInfo.resetTime)
                print(string.format("      重置: %s", resetText))
            end
        end
        
        return hasQuests
    end,
    
    -- 简化的全部副本状态显示
    PrintAllRaidsStatusByGroup = function()
        print("  功能开发中，请使用表格界面查看详细信息")
    end,
    
    -- 简化的重置时间表显示
    PrintResetScheduleByGroup = function()
        print("  功能开发中，请使用表格界面查看详细信息")
    end
}