-- RaidProgress.lua - 副本进度检查插件（乌龟服多角色版）
-- 核心插件逻辑，包含Ace2插件初始化和主要业务逻辑

-- =============================================================================
-- 兼容性函数（WoW 1.12支持）
-- =============================================================================

-- WoW 1.12兼容的mod函数，直接定义为全局函数
function mod(a, b)
    return a - math.floor(a / b) * b
end

-- =============================================================================
-- 全局变量和插件初始化
-- =============================================================================

-- 全局数据库，存储所有角色的副本进度信息
RaidProgressDB = RaidProgressDB or { characters = {} }

-- 创建 Ace2 插件对象
local RaidProgress = AceLibrary("AceAddon-2.0"):new(
    "AceEvent-2.0",
    "AceDB-2.0",
    "AceConsole-2.0",
    "FuBarPlugin-2.0"
)

-- 注册到全局命名空间（保持向后兼容）
_G["RaidProgress"] = RaidProgress

-- FuBar 显示的图标
RaidProgress.hasIcon = "Interface\\Icons\\INV_Misc_PocketWatch_01"

-- =============================================================================
-- 数据库操作函数
-- =============================================================================

-- 确保角色数据结构存在
local function EnsureCharacterData(fullName)
    if not RaidProgressDB.characters[fullName] then
        RaidProgressDB.characters[fullName] = {
            info = {},
            progress = {}
        }
    end

    local charData = RaidProgressDB.characters[fullName]
    if not charData.info then charData.info = {} end
    if not charData.progress then charData.progress = {} end

    return charData
end

-- =============================================================================
-- 副本识别和匹配函数
-- =============================================================================

-- 优化的副本匹配逻辑
local function FindInstanceID(name)
    if not name then return nil end
    
    local instanceID = RaidProgressConfig.RAID_NAME_TO_ID[name]
    if instanceID then 
        RaidProgressUtils.DebugPrint(string.format("直接匹配副本：%s -> %d", name, instanceID))
        return instanceID 
    end

    for raidName, id in pairs(RaidProgressConfig.RAID_NAME_TO_ID) do
        if string.find(name, raidName) or string.find(raidName, name) then
            RaidProgressUtils.DebugPrint(string.format("模糊匹配副本：%s 匹配到 %s -> %d", name, raidName, id))
            return id
        end
    end

    RaidProgressUtils.DebugPrint(string.format("未找到匹配的副本：%s", name))
    return nil
end

-- 根据重置时间判断卡拉赞是上层还是下层（使用服务器配置）
local function GetKarazhanInstanceID(resetTime)
    local resetTimestamp = RaidProgressUtils.GetCurrentTime() + resetTime
    local resetDate = date("*t", resetTimestamp)    local serverConfig = RaidProgressUtils.GetCurrentServerConfig()
    local lowerConfig = serverConfig[535]
    if lowerConfig then
        local nextLowerReset = CalculateNextResetTime(lowerConfig)
        if math.abs(resetTimestamp - nextLowerReset) <= RaidProgressConfig.TIME_ERROR_MARGIN then
            return 535
        end
    end

    if resetDate.wday == 4 and resetDate.hour >= 11 and resetDate.hour <= 13 then
        return 536
    end

    return 535
end

-- =============================================================================
-- 核心业务逻辑函数
-- =============================================================================

-- 初始化插件
function RaidProgress:OnInitialize()
    self:RegisterDB("RaidProgressDB")
    
    if not RaidProgressDB then
        RaidProgressDB = { characters = {} }
    end
    if not RaidProgressDB.characters then
        RaidProgressDB.characters = {}
    end    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    self:RegisterEvent("QUEST_LOG_UPDATE", "OnQuestLogUpdate")
    self:CreateSlashCommands()
    self:InitializeOptions()
    self.OnMenuRequest = self.options    local serverName = RaidProgressUtils.GetSafeServerName()
    local hasServerConfig = RaidProgressUtils.HasServerSpecificConfig()
    
    if hasServerConfig then
        print(string.format("|cFFFFFF00副本进度检查 2.0|r: 表格界面版已加载 (服务器: %s)。输入 /rp 查看进度。", serverName))
    else
        print(string.format("|cFFFFFF00副本进度检查 2.0|r: 表格界面版已加载 (服务器: %s, 使用默认配置)。输入 /rp 查看进度。", serverName))
    end
end

function RaidProgress:OnEnable()
    self:UpdateCharacterInfo()
end

function RaidProgress:OnPlayerEnteringWorld()
    self:UpdateCharacterInfo()
    self:UpdateAllInstances()
    
    -- 延迟扫描周常任务，确保任务日志已加载
    self:ScheduleEvent(function()
        self:UpdateWeeklyQuests()
    end, 3)
end

-- 更新角色信息
function RaidProgress:UpdateCharacterInfo()
    local playerInfo = RaidProgressUtils.SafeGetPlayerInfo()
    
    if playerInfo.level >= RaidProgressConfig.LEVEL_THRESHOLD then
        local charData = EnsureCharacterData(playerInfo.fullName)
        charData.info.class = playerInfo.class
        charData.info.level = playerInfo.level
        charData.info.lastUpdate = time()
        
        RaidProgressUtils.DebugPrint(string.format("已更新角色信息：%s (%s %d级)", 
            playerInfo.name, playerInfo.class, playerInfo.level))
    end
end

-- 更新所有副本状态
function RaidProgress:UpdateAllInstances()
    RaidProgressUtils.UpdateCurrentTime()
    
    local playerInfo = RaidProgressUtils.SafeGetPlayerInfo()
    local charData = EnsureCharacterData(playerInfo.fullName)
    
    RaidProgressUtils.DebugPrint(string.format("开始扫描副本，当前有 %d 个已保存的副本", GetNumSavedInstances()))
    
    for i = 1, GetNumSavedInstances() do
        local instanceName, instanceID, instanceReset = GetSavedInstanceInfo(i)
        
        RaidProgressUtils.DebugPrint(string.format("副本 %d: 名称=%s, ID=%s, 重置时间=%d秒", 
            i, instanceName or "nil", tostring(instanceID), instanceReset or 0))
        
        local raidID = FindInstanceID(instanceName)
        
        if raidID then
            if string.find(instanceName, "卡拉赞") then
                raidID = GetKarazhanInstanceID(instanceReset)
                RaidProgressUtils.DebugPrint(string.format("卡拉赞特殊处理：%s -> %d", instanceName, raidID))
            end
            
            charData.progress[raidID] = {
                resetTime = RaidProgressUtils.GetCurrentTime() + instanceReset,
                lastUpdate = RaidProgressUtils.GetCurrentTime(),
                instanceName = instanceName
            }
            
            RaidProgressUtils.DebugPrint(string.format("已保存副本进度：%s (ID:%d) 重置时间:%s", 
                instanceName, raidID, RaidProgressDisplay.FormatTimeLeft(instanceReset)))
        end
    end
    
    -- 显示当前保存的所有进度
    RaidProgressUtils.DebugPrint("当前角色保存的副本进度：")
    for raidID, progressData in pairs(charData.progress) do
        if progressData.resetTime and progressData.resetTime > RaidProgressUtils.GetCurrentTime() then
            local raidName = RaidProgressDisplay.GetRaidNameByID(raidID)
            local timeLeft = progressData.resetTime - RaidProgressUtils.GetCurrentTime()
            RaidProgressUtils.DebugPrint(string.format("- %s (ID:%d): %s", 
                raidName, raidID, RaidProgressDisplay.FormatTimeLeft(timeLeft)))
        end
    end
end

-- 显示所有角色进度（安全版本）- 已升级为表格界面
function RaidProgress:ShowProgress()
    -- 在显示界面前，先更新当前角色的周任务数据
    self:UpdateWeeklyQuests()
    
    -- 首先尝试新的表格界面
    if _G.RealTableUI and _G.RealTableUI.Show then
        _G.RealTableUI.Show()
        return
    elseif RealTableUI and RealTableUI.Show then
        RealTableUI.Show()
        return
    end
    
    -- 传统界面作为备选
    local success, error = RaidProgressUtils.SafeExecute(function()
        RaidProgressUtils.UpdateCurrentTime()
        
        RaidProgressDisplay.PrintSeparator()
        print("|cFFFFFF00副本进度检查 - 全部角色|r")
        RaidProgressDisplay.PrintSeparator()
        
        local hasValidCharacter = false
        local currentPlayerInfo = RaidProgressUtils.SafeGetPlayerInfo()
        
        self:UpdateCharacterInfo()
        self:UpdateAllInstances()
        
        local serverName = RaidProgressUtils.GetSafeServerName()
        print(string.format("|cFFFFFF00副本进度检查 - 全部角色 (%s服务器)|r", serverName))
        
        if not RaidProgressDB or not RaidProgressDB.characters then
            print("|cFFFF0000数据库未初始化|r")
            return
        end
        
        local characterCount = RaidProgressUtils.CountTableElements(RaidProgressDB.characters)
        RaidProgressUtils.DebugPrint(string.format("数据库中共有 %d 个角色", characterCount))
        
        if characterCount > 50 then
            print("|cFFFFAA00警告: 角色数量较多，可能需要较长时间处理...|r")
        end
        
        local processedCount = 0
        for fullName, charData in pairs(RaidProgressDB.characters) do            processedCount = processedCount + 1
            
            -- 每处理10个角色检查一次是否超时
            if mod(processedCount, 10) == 0 then
                RaidProgressUtils.DebugPrint(string.format("已处理 %d/%d 个角色", processedCount, characterCount))
            end
            
            if not charData or type(charData) ~= "table" then
                RaidProgressUtils.DebugPrint(string.format("跳过无效角色数据: %s", tostring(fullName)))
                -- 添加continue逻辑，跳过当前循环
            else
                RaidProgressUtils.DebugPrint(string.format("检查角色：%s, 等级：%s", 
                    fullName, tostring(charData.info and charData.info.level or "nil")))
                    
                if charData.info and charData.info.level and charData.info.level >= RaidProgressConfig.DISPLAY_LEVEL_THRESHOLD then
                    hasValidCharacter = true
                    
                    RaidProgressDisplay.PrintCharacterHeader(fullName, charData.info.class, charData.info.level)
                    
                    if fullName == currentPlayerInfo.fullName then
                        print("  |cFF00FF00[当前角色]|r")
                    end
                    
                    -- 使用分组显示进度
                    local hasProgress = RaidProgressDisplay.PrintCharacterProgressByGroup(charData)
                    
                    if not hasProgress then
                        print("  |cFF808080无副本CD|r")
                    end
                    print("")
                end
            end
        end
        
        if not hasValidCharacter then
            print("|cFFFF8080没有找到任何55级以上的角色数据。|r")
            print("|cFFFFFF00当前角色信息：|r")
            print(string.format("  角色名：%s", currentPlayerInfo.name))
            print(string.format("  等级：%d", currentPlayerInfo.level))
            print(string.format("  职业：%s", currentPlayerInfo.class))
            print(string.format("  完整名称：%s", currentPlayerInfo.fullName))
        end
        
        RaidProgressDisplay.PrintSeparator()
    end, "ShowProgress", 10) -- 10秒超时
    
    if not success then
        print("|cFFFF0000显示进度时发生错误，请尝试重新加载插件或联系作者|r")
    end
end

-- 显示当前角色所有副本状态（安全版本）
function RaidProgress:ShowAllRaidsStatus()
    local success, error = RaidProgressUtils.SafeExecute(function()
        local playerInfo = RaidProgressUtils.SafeGetPlayerInfo()
        local serverName = RaidProgressUtils.GetSafeServerName()
        
        RaidProgressDisplay.PrintSeparator()
        print(string.format("|cFFFFFF00%s - 全部副本状态 (%s服务器)|r", playerInfo.name, serverName))
        RaidProgressDisplay.PrintSeparator()
        
        RaidProgressDisplay.PrintAllRaidsStatusByGroup()
        
        RaidProgressDisplay.PrintSeparator()
    end, "ShowAllRaidsStatus", 5)
    
    if not success then
        print("|cFFFF0000显示副本状态时发生错误|r")
    end
end

-- 显示重置时间表（安全版本）
function RaidProgress:ShowResetSchedule()
    local success, error = RaidProgressUtils.SafeExecute(function()
        RaidProgressUtils.UpdateCurrentTime()
        
        local serverName = RaidProgressUtils.GetSafeServerName()
        
        RaidProgressDisplay.PrintSeparator()
        print(string.format("|cFFFFFF00副本重置时间表 (%s服务器)|r", serverName))
        RaidProgressDisplay.PrintSeparator()
        
        RaidProgressDisplay.PrintResetScheduleByGroup()
        
        RaidProgressDisplay.PrintSeparator()
    end, "ShowResetSchedule", 5)
    
    if not success then
        print("|cFFFF0000显示重置时间表时发生错误|r")
    end
end

-- 显示周常任务状态
function RaidProgress:ShowWeeklyQuestStatus()
    if not RaidProgressWeeklyQuest then
        print("|cFFFF0000错误：周常任务模块未加载|r")
        return
    end
    
    local allQuests = RaidProgressWeeklyQuest.GetAllCharactersWeeklyQuests()
    if not allQuests or not next(allQuests) then
        print("|cFFFFFF00暂无周常任务数据|r")
        return
    end
    
    print("|cFFFFFF00=== 周常任务状态 ===|r")
    
    for charName, questData in pairs(allQuests) do
        print(string.format("|cFF00FF00%s:|r", charName))
        
        for questID, questInfo in pairs(questData) do
            local statusColor = questInfo.completed and "|cFF00FF00" or "|cFFFF0000"
            local statusText = questInfo.completed and "已完成" or "未完成"
            local questName = questInfo.questName or ("任务" .. questID)
            
            print(string.format("  %s%s|r - %s%s|r", 
                "|cFFFFFFFF", questName, statusColor, statusText))
                
            -- 显示重置时间信息
            if questInfo.resetTime and questInfo.resetTime > 0 then
                local resetText = RaidProgressWeeklyQuest.FormatWeeklyQuestResetTime(questInfo.resetTime)
                print(string.format("    重置时间: %s", resetText))
            end
        end
    end    -- 显示即将重置的警告
    local warnings = RaidProgressWeeklyQuest.CheckWeeklyQuestResets()
    if warnings and warnings[1] then
        print("|cFFFF8800=== 重置提醒 ===|r")
        for _, warning in ipairs(warnings) do
            print("|cFFFF8800" .. warning .. "|r")
        end
    end
end

-- 显示所有角色的任务状态
function RaidProgress:ShowAllCharactersQuestStatus()
    print("|cFFFFFF00=== 所有角色周任务状态 ===|r")
    
    if not RaidProgressDB or not RaidProgressDB.characters then
        print("|cFFFF0000没有角色数据|r")
        return
    end
    
    local currentTime = time()
    local questNames = {
        quest_1 = "武装的召唤：净化腐化",
        quest_2 = "武装的召唤：地下城探索",
        quest_3 = "武装的召唤：熔火突袭"
    }
    
    for fullName, charData in pairs(RaidProgressDB.characters) do
        if charData.info and charData.info.level and charData.info.level >= 55 then
            print(string.format("|cFF00FF00角色：%s (%d级)|r", fullName, charData.info.level))
            
            if not charData.weeklyQuests or not next(charData.weeklyQuests) then
                print("  |cFFFFFFAA状态：无任务数据（从未接取过周任务）|r")
            else
                for questId, questName in pairs(questNames) do
                    local questData = charData.weeklyQuests[questId]
                    if not questData then
                        print(string.format("  %s: |cFF888888无记录|r", questName))
                    else
                        local resetTime = questData.resetTime or 0
                        local isReset = currentTime >= resetTime
                        local isCompleted = questData.completed or false
                        local lastUpdate = questData.lastUpdate or 0
                        local timeSinceUpdate = currentTime - lastUpdate
                        
                        local statusColor, statusText
                        if isReset then
                            statusColor = "|cFF00FF00"
                            statusText = "可重新接取（已重置）"
                        elseif isCompleted then
                            statusColor = "|cFFFFD700"
                            statusText = "本周已完成"
                        elseif timeSinceUpdate > 3600 then -- 超过1小时未更新
                            statusColor = "|cFFFF8800"
                            statusText = "可能被放弃（可重新接取）"
                        else
                            statusColor = "|cFF00AAFF"
                            statusText = "任务进行中"
                        end
                        
                        print(string.format("  %s: %s%s|r", questName, statusColor, statusText))
                        if questData.resetTime then
                            print(string.format("    重置时间: %s", os.date("%Y-%m-%d %H:%M", questData.resetTime)))
                        end
                        if questData.lastUpdate then
                            print(string.format("    最后更新: %s", os.date("%Y-%m-%d %H:%M", questData.lastUpdate)))
                        end
                    end
                end
            end
            print("") -- 空行分隔
        end
    end
end

-- 创建斜杠命令
function RaidProgress:CreateSlashCommands()
    -- 使用唯一的键名避免冲突    SLASH_RAIDPROGRESSV21 = "/rp"
    SLASH_RAIDPROGRESSV22 = "/raidprogress"
    
    -- 使用self引用避免作用域问题
    local self = self
      SlashCmdList["RAIDPROGRESSV2"] = function(msg)
        local command = string.lower(msg or "")
        
        if command == "" or command == "progress" then
            self:UpdateCharacterInfo()
            self:UpdateAllInstances()
            -- 强制使用新表格界面
            print("|cFFFFFF00RaidProgress 2.0 - 启动表格界面|r")
            print("检查RealTableUI状态: " .. (RealTableUI and "存在" or "不存在"))
            if RealTableUI and RealTableUI.Show then
                print("调用RealTableUI.Show()...")
                RealTableUI.Show()
            else
                print("|cFFFF0000错误：RealTableUI未加载，使用传统界面|r")
                -- 尝试直接调用全局的RealTableGridUI
                if _G["RealTableGridUI"] and _G["RealTableGridUI"].Show then
                    print("尝试使用RealTableGridUI...")
                    _G["RealTableGridUI"].Show()
                else
                    self:ShowProgress()
                end
            end
        elseif command == "table" or command == "ui" then
            self:UpdateCharacterInfo()
            self:UpdateAllInstances()
            -- table命令也使用新界面
            print("|cFFFFFF00RaidProgress 2.0 - 启动表格界面|r")
            if RealTableUI and RealTableUI.Show then
                RealTableUI.Show()
            else
                print("|cFFFF0000错误：RealTableUI未加载|r")
                self:ShowProgress()
            end
        elseif command == "simple" then
            -- simple命令也使用新界面
            self:UpdateCharacterInfo()
            self:UpdateAllInstances()
            print("|cFFFFFF00RaidProgress 2.0 - 启动表格界面|r")
            if RealTableUI and RealTableUI.Show then
                RealTableUI.Show()
            else
                print("|cFFFF0000错误：RealTableUI未加载|r")
                self:ShowProgress()
            end
        elseif command == "old" or command == "text" then            self:UpdateCharacterInfo()
            self:UpdateAllInstances()
            self:ShowProgress()
        elseif command == "allstatus" or command == "all" then
            self:UpdateCharacterInfo()
            self:UpdateAllInstances()
            self:ShowAllRaidsStatus()        elseif command == "reset" or command == "schedule" then
            self:ShowResetSchedule()        elseif command == "quest" or command == "weekly" then
            self:ShowWeeklyQuestStatus()
        elseif command == "queststatus" or command == "qs" then
            -- 显示所有角色的任务状态
            self:ShowAllCharactersQuestStatus()
        elseif command == "debug" then
            RaidProgressUtils.SetDebugMode(not RaidProgressUtils.GetDebugMode())        elseif command == "questdebug" or command == "qd" then
            -- 调试任务扫描
            print("|cFFFFFF00=== 任务扫描调试 ===|r")
            if RaidProgressWeeklyQuest then
                RaidProgressWeeklyQuest.DebugPrintAllQuests()
                
                -- 尝试扫描周常任务
                print("|cFFFFAA00=== 扫描周常任务 ===|r")
                local weeklyQuests = RaidProgressWeeklyQuest.ScanQuestLogForWeeklyQuests()
                if weeklyQuests and next(weeklyQuests) then
                    for questId, questData in pairs(weeklyQuests) do
                        print(string.format("找到：%s (%s) - %s", 
                            questData.name, questId, questData.completed and "已完成" or "进行中"))
                    end
                else
                    print("未找到周常任务")
                end
                
                -- 显示当前角色的周任务状态
                local playerInfo = RaidProgressUtils.SafeGetPlayerInfo()
                local charData = RaidProgressDB.characters[playerInfo.fullName]
                print("|cFF00AAFF=== 当前角色任务状态 ===|r")
                if charData and charData.weeklyQuests then
                    for questId, questData in pairs(charData.weeklyQuests) do
                        local questName = RaidProgressConfig.WEEKLY_QUEST_NAMES[questId] and questId or "未知任务"
                        local resetTime = questData.resetTime and os.date("%Y-%m-%d %H:%M", questData.resetTime) or "无"
                        local lastUpdate = questData.lastUpdate and os.date("%Y-%m-%d %H:%M", questData.lastUpdate) or "无"
                        print(string.format("任务：%s", questName))
                        print(string.format("  完成状态：%s", questData.completed and "已完成" or "未完成"))
                        print(string.format("  重置时间：%s", resetTime))
                        print(string.format("  最后更新：%s", lastUpdate))
                    end
                else
                    print("该角色无周任务数据")
                end            else
                print("WeeklyQuest 模块未加载")
            end
        elseif command == "test" then
            -- 一键测试命令
            print("|cFFFFFF00=== RaidProgress 2.0 测试 ===|r")
            print("RealTableUI存在: " .. (RealTableUI and "是" or "否"))
            if RealTableUI then
                print("RealTableUI.Show存在: " .. (RealTableUI.Show and "是" or "否"))
                print("尝试显示界面...")
                RealTableUI.Show()
            end        else            print("|cFFFFFF00RaidProgress 2.0 命令:|r")
            print("  |cFFFFAAAA/rp|r - 显示表格界面")
            print("  |cFFFFAAAA/rp old|r - 显示传统界面")
            print("  |cFFFFAAAA/rp test|r - 测试表格界面")
            print("  |cFFFFAAAA/rp reset|r - 查看重置时间")
            print("  |cFFFFAAAA/rp quest|r - 查看周常任务状态")
            print("  |cFFFFAAAA/rp questdebug|r - 调试任务扫描")
            print("  |cFFFFAAAA/rp queststatus|r - 查看所有角色任务状态")
            print("  |cFFFFAAAA/rp debug|r - 切换调试模式")
        end
    end
end

-- 初始化选项菜单
function RaidProgress:InitializeOptions()
    self.options = {
        type = "group",
        name = "查看副本进度 2.0",
        desc = "查看和管理角色副本进度 - 表格界面版",
        args = {
            progress = {
                type = "execute",
                name = "表格界面",
                desc = "查看所有角色的副本进度 (表格界面)",
                order = 1,                func = function()
                    self:UpdateCharacterInfo()
                    self:UpdateAllInstances()
                    if RaidProgressTableUISimple then
                        RaidProgressTableUISimple.Show()
                    elseif RaidProgressSimpleTable then
                        RaidProgressSimpleTable.Show()
                    else
                        self:ShowProgress()
                    end
                end
            },
            oldprogress = {
                type = "execute",
                name = "传统界面",
                desc = "查看所有角色的副本进度 (文字界面)",
                order = 2,
                func = function()
                    self:UpdateCharacterInfo()
                    self:UpdateAllInstances()
                    self:ShowProgress()
                end
            },
            debug = {
                type = "toggle",
                name = "调试模式",
                desc = "开启或关闭调试信息显示",
                order = 4,
                get = function() 
                    return RaidProgressUtils and RaidProgressUtils.GetDebugMode() or false
                end,
                set = function(value)
                    if RaidProgressUtils then
                        RaidProgressUtils.SetDebugMode(value)
                    end
                end
            }
        }
    }
end

-- =============================================================================
-- 周常任务事件处理
-- =============================================================================

-- 任务日志更新事件处理器
function RaidProgress:OnQuestLogUpdate()
    -- 使用延迟更新来避免频繁触发
    if not self.questUpdateTimer then
        self.questUpdateTimer = self:ScheduleEvent("UpdateWeeklyQuests", 1)
    end
end

-- 更新周常任务状态
function RaidProgress:UpdateWeeklyQuests()
    self.questUpdateTimer = nil
    
    local playerInfo = RaidProgressUtils.SafeGetPlayerInfo()
    if playerInfo.level >= RaidProgressConfig.LEVEL_THRESHOLD then
        if RaidProgressWeeklyQuest then
            RaidProgressWeeklyQuest.UpdateCharacterWeeklyQuests(playerInfo.fullName)
            
            RaidProgressUtils.DebugPrint(string.format("已更新 %s 的周常任务状态", playerInfo.fullName))
        end
    end
end