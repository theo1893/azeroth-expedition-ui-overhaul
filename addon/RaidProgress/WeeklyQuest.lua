-- WeeklyQuest.lua - 周常任务检测和管理模块
-- 负责检测并存储周常任务的完成状态

-- =============================================================================
-- 周常任务管理器
-- =============================================================================

-- 用于检测周常任务的函数 (增强版，支持模糊匹配)
local function DetectWeeklyQuest(questName)
    if not questName or not RaidProgressConfig.WEEKLY_QUEST_NAMES then
        return nil
    end
    
    -- 首先尝试精确匹配
    local questId = RaidProgressConfig.WEEKLY_QUEST_NAMES[questName]
    if questId then
        return questId
    end
    
    -- 尝试模糊匹配
    for configQuestName, questId in pairs(RaidProgressConfig.WEEKLY_QUEST_NAMES) do
        -- 检查任务名称中是否包含关键词
        if string.find(questName, "武装的召唤") or string.find(questName, "Call to Arms") then
            -- 检查具体的任务类型
            if (string.find(questName, "净化") or string.find(questName, "腐化")) and questId == "quest_1" then
                return questId
            elseif (string.find(questName, "地下城") or string.find(questName, "探索")) and questId == "quest_2" then
                return questId
            elseif (string.find(questName, "熔火") or string.find(questName, "突袭")) and questId == "quest_3" then
                return questId
            end
        end
        
        -- 部分字符串匹配
        if string.find(questName, configQuestName) or string.find(configQuestName, questName) then
            return questId
        end
    end
    
    return nil
end

-- 扫描任务日志中的周常任务 (WoW 1.12 兼容版本)
local function ScanQuestLogForWeeklyQuests()
    local weeklyQuests = {}
    local numQuests = GetNumQuestLogEntries()
    
    RaidProgressUtils.DebugPrint(string.format("开始扫描任务日志，共有 %d 个任务", numQuests))
    
    for i = 1, numQuests do
        local questTitle, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i)
        
        if questTitle and not isHeader then
            RaidProgressUtils.DebugPrint(string.format("检查任务 %d: %s (标签:%s, 完成:%s)", 
                i, questTitle, tostring(questTag), tostring(isComplete)))
            
            -- 检查是否是周常任务
            local questId = DetectWeeklyQuest(questTitle)
            if questId then
                -- 选择任务获取更多信息
                SelectQuestLogEntry(i)
                
                -- 在1.12中，isComplete通常是最可靠的完成状态指示器
                local isCompleted = (isComplete == 1) or (isComplete == true)
                
                -- 如果isComplete不可靠，尝试其他方法
                if not isCompleted then
                    local questDescription, questObjectives = GetQuestLogQuestText()
                    -- 检查目标文本中是否包含完成标识
                    if questObjectives then
                        isCompleted = (string.find(questObjectives, "完成") ~= nil) or 
                                    (string.find(questObjectives, "Complete") ~= nil) or
                                    (string.find(questObjectives, "完毕") ~= nil) or
                                    (string.find(questObjectives, "已完成") ~= nil)
                    end
                    
                    -- 检查任务标签
                    if questTag and (questTag == "完成" or questTag == "Complete") then
                        isCompleted = true
                    end
                end
                
                weeklyQuests[questId] = {
                    name = questTitle,
                    completed = isCompleted,
                    questLogIndex = i,
                    timestamp = time(),
                    level = level,
                    questTag = questTag
                }
                
                RaidProgressUtils.DebugPrint(string.format("找到周常任务：%s (%s) - %s", 
                    questTitle, questId, isCompleted and "已完成" or "进行中"))
            end
        end
    end
    
    RaidProgressUtils.DebugPrint(string.format("扫描完成，发现 %d 个周常任务", 
        RaidProgressUtils.CountTableElements(weeklyQuests)))
    
    return weeklyQuests
end

-- 更新角色的周常任务数据
local function UpdateCharacterWeeklyQuests(fullName)
    local charData = RaidProgressDB.characters[fullName]
    if not charData then
        RaidProgressUtils.DebugPrint("角色数据不存在：" .. tostring(fullName))
        return
    end
    
    -- 确保周常任务数据结构存在
    if not charData.weeklyQuests then
        charData.weeklyQuests = {}
    end
    
    -- 扫描当前任务日志
    local currentQuests = ScanQuestLogForWeeklyQuests()
    
    -- 更新周常任务状态
    for questId, questData in pairs(currentQuests) do
        if not charData.weeklyQuests[questId] then
            charData.weeklyQuests[questId] = {}
        end
        
        -- 更新任务状态
        charData.weeklyQuests[questId].completed = questData.completed
        charData.weeklyQuests[questId].lastUpdate = questData.timestamp
        charData.weeklyQuests[questId].name = questData.name
        
        -- 如果任务刚刚完成，记录完成时间
        if questData.completed and not charData.weeklyQuests[questId].completionTime then
            charData.weeklyQuests[questId].completionTime = questData.timestamp
        end
          -- 计算下次重置时间
        local questConfig = RaidProgressConfig.WEEKLY_QUEST_RESET_CYCLES[questId]
        if questConfig then
            local nextReset = CalculateNextResetTime(questConfig)
            charData.weeklyQuests[questId].resetTime = nextReset
        end
    end
    
    -- 清理过期的周常任务数据
    local currentTime = time()
    for questId, questData in pairs(charData.weeklyQuests) do
        if questData.resetTime and currentTime > questData.resetTime then
            -- 重置过期的任务
            questData.completed = false
            questData.completionTime = nil
              -- 重新计算下次重置时间
            local questConfig = RaidProgressConfig.WEEKLY_QUEST_RESET_CYCLES[questId]
            if questConfig then
                local nextReset = CalculateNextResetTime(questConfig)
                questData.resetTime = nextReset
            end
        end
    end
end

-- 获取所有角色的周常任务状态
local function GetAllCharactersWeeklyQuests()
    local result = {}
    
    if not RaidProgressDB or not RaidProgressDB.characters then
        return result
    end
    
    for fullName, charData in pairs(RaidProgressDB.characters) do
        if charData.weeklyQuests then
            result[fullName] = {}
            for questId, questData in pairs(charData.weeklyQuests) do
                result[fullName][questId] = {
                    name = questData.name,
                    completed = questData.completed,
                    resetTime = questData.resetTime,
                    completionTime = questData.completionTime
                }
            end
        end
    end
    
    return result
end

-- 检查是否有周常任务即将重置
local function CheckWeeklyQuestResets()
    local warnings = {}
    local currentTime = time()
    local warningThreshold = 24 * 3600 -- 24小时预警
    
    if not RaidProgressDB or not RaidProgressDB.characters then
        return warnings
    end
    
    for fullName, charData in pairs(RaidProgressDB.characters) do
        if charData.weeklyQuests then
            for questId, questData in pairs(charData.weeklyQuests) do
                if questData.resetTime and not questData.completed then
                    local timeLeft = questData.resetTime - currentTime
                    if timeLeft > 0 and timeLeft <= warningThreshold then
                        table.insert(warnings, {
                            character = fullName,
                            questName = questData.name,
                            questId = questId,
                            timeLeft = timeLeft
                        })
                    end
                end
            end
        end
    end
    
    return warnings
end

-- 调试：打印所有任务日志中的任务
local function DebugPrintAllQuests()
    local numQuests = GetNumQuestLogEntries()
    print(string.format("|cFFFFFF00=== 任务日志调试 (共%d个任务) ===|r", numQuests))
    
    for i = 1, numQuests do
        local questTitle, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i)
        
        if questTitle then
            if isHeader then
                print(string.format("|cFFFFAAAA[分类] %s|r", questTitle))
            else
                local statusText = ""
                if isComplete == 1 or isComplete == true then
                    statusText = "|cFF00FF00已完成|r"
                else
                    statusText = "|cFFFF0000进行中|r"
                end
                
                local tagText = questTag and ("["..questTag.."]") or ""
                print(string.format("  %d. |cFFFFFFFF%s|r %s (等级:%s) %s", 
                    i, questTitle, statusText, tostring(level), tagText))
                
                -- 检查是否可能是周常任务
                if string.find(questTitle, "武装") or string.find(questTitle, "召唤") or
                   string.find(questTitle, "净化") or string.find(questTitle, "地下城") or
                   string.find(questTitle, "熔火") or string.find(questTitle, "腐化") then
                    print(string.format("    |cFFFFAA00>>> 可能是周常任务!|r"))
                end
            end
        end
    end
    
    print("|cFFFFFF00=== 调试结束 ===|r")
end

-- 格式化周常任务重置时间
local function FormatWeeklyQuestResetTime(questId)
    local questConfig = RaidProgressConfig.WEEKLY_QUEST_RESET_CYCLES[questId]
    if not questConfig then
        return "未知重置时间"
    end
      local currentTime = time()
    local nextReset = CalculateNextResetTime(questConfig)
    
    return FormatResetTime(nextReset)
end

-- 导出周常任务管理器
RaidProgressWeeklyQuest = {
    DetectWeeklyQuest = DetectWeeklyQuest,
    ScanQuestLogForWeeklyQuests = ScanQuestLogForWeeklyQuests,
    UpdateCharacterWeeklyQuests = UpdateCharacterWeeklyQuests,
    GetAllCharactersWeeklyQuests = GetAllCharactersWeeklyQuests,
    CheckWeeklyQuestResets = CheckWeeklyQuestResets,
    FormatWeeklyQuestResetTime = FormatWeeklyQuestResetTime,
    DebugPrintAllQuests = DebugPrintAllQuests  -- 调试函数
}
