print("|cFF0099FF加载 InlineResetTime.lua - 内嵌重置时间显示|r")

-- 内嵌重置时间显示功能

-- 格式化剩余时间显示（简洁版本）
local function FormatTimeLeft(timeLeft)
    if timeLeft <= 0 then
        return "已重置"
    end
    
    local days = math.floor(timeLeft / (24 * 3600))
    local hours = math.floor((timeLeft - days * 24 * 3600) / 3600)
    local minutes = math.floor((timeLeft - days * 24 * 3600 - hours * 3600) / 60)
    
    if days > 0 then
        return string.format("%d天%dh", days, hours)
    elseif hours > 0 then
        return string.format("%dh%dm", hours, minutes)
    else
        return string.format("%dm", minutes)
    end
end

-- 计算下次重置的简化时间显示
local function GetSimpleResetTime(raidId)
    if not raidId then return "?" end
    
    -- 获取服务器配置
    local serverConfig = nil
    if RaidProgressConfig and RaidProgressConfig.GetServerRaidConfig then
        serverConfig = RaidProgressConfig.GetServerRaidConfig()
    end
    
    if not serverConfig or not serverConfig[raidId] then
        return "?"
    end
    
    local config = serverConfig[raidId]
    local currentTime = time()
    
    if config.resetDay and config.resetDay > 0 then
        -- 周重置副本
        local resetHour = config.resetHour or 12
        local currentDate = date("*t", currentTime)
        
        -- 计算到下次重置的天数
        local daysUntilReset = config.resetDay - currentDate.wday
        if daysUntilReset <= 0 then
            daysUntilReset = daysUntilReset + 7  -- 下周
        end
        
        local resetTime = currentTime + daysUntilReset * 24 * 3600
        local resetDate = date("*t", resetTime)
        resetDate.hour = resetHour
        resetDate.min = 0
        resetDate.sec = 0
        
        local actualResetTime = time(resetDate)
        local timeLeft = actualResetTime - currentTime
          if timeLeft <= 0 then
            actualResetTime = actualResetTime + 7 * 24 * 3600
            timeLeft = actualResetTime - currentTime
        end
        
        return FormatTimeLeft(timeLeft)
    else
        -- 固定周期副本
        if config.baseResetTime then
            local cycleLength = config.cycle
            local timeSinceBase = currentTime - config.baseResetTime
            local cyclesPassed = math.floor(timeSinceBase / cycleLength)
            local nextResetTime = config.baseResetTime + (cyclesPassed + 1) * cycleLength
              local timeLeft = nextResetTime - currentTime
            return FormatTimeLeft(timeLeft)
        else
            return "?"
        end
    end
end

-- 获取重置周期描述
local function GetResetCycleDesc(raidId)
    if not raidId then return "?" end
    
    local serverConfig = nil
    if RaidProgressConfig and RaidProgressConfig.GetServerRaidConfig then
        serverConfig = RaidProgressConfig.GetServerRaidConfig()
    end
    
    if not serverConfig or not serverConfig[raidId] then
        return "?"
    end
    
    local config = serverConfig[raidId]
    
    if config.resetDay and config.resetDay > 0 then
        -- 周重置
        local dayNames = {"", "一", "二", "三", "四", "五", "六", "日"}
        return "周" .. (dayNames[config.resetDay] or "?")
    else
        -- 固定周期
        local days = math.floor(config.cycle / (24 * 3600))
        return days .. "天"
    end
end

-- 导出函数
_G.GetSimpleResetTime = GetSimpleResetTime
_G.GetResetCycleDesc = GetResetCycleDesc

-- 测试函数
local function TestResetTime()
    print("=== 重置时间测试 ===")
    
    local testRaids = {409, 469, 531, 509, 719}
    
    for i, raidId in ipairs(testRaids) do
        local cycleDesc = GetResetCycleDesc(raidId)
        local resetTime = GetSimpleResetTime(raidId)
        print(string.format("副本%d: %s周期, %s后重置", raidId, cycleDesc, resetTime))
    end
    
    print("=== 测试完成 ===")
end

-- 注册命令
SLASH_TESTRESETTIME1 = "/testresettime"
SlashCmdList["TESTRESETTIME"] = function()
    TestResetTime()
end

print("|cFF0099FF内嵌重置时间显示已加载: /testresettime|r")
