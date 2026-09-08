-- filepath: c:\游戏\TurtleWoW\Interface\AddOns\RaidProgress\ResetCalculator.lua
-- ResetCalculator.lua - 副本重置时间计算器

-- 计算下次重置时间
function CalculateNextResetTime(config)
    if not config then return 0 end
    
    local currentTime = time()
    
    -- 如果有基准重置时间，使用固定周期计算
    if config.baseResetTime and config.cycle then
        local timeSinceBase = currentTime - config.baseResetTime
        local cyclesPassed = math.floor(timeSinceBase / config.cycle)
        return config.baseResetTime + (cyclesPassed + 1) * config.cycle
    end
    
    -- 使用每周重置计算
    if config.resetDay and config.resetHour and config.cycle then
        local resetHour = config.resetHour or 12
        local resetDay = config.resetDay -- 1=周一, 7=周日
        
        -- 获取当前时间信息
        local currentDate = date("*t", currentTime)
        local currentWeekDay = currentDate.wday -- 1=周日, 2=周一...
        
        -- 转换为我们的格式 (1=周一)
        local ourWeekDay = (currentWeekDay == 1) and 7 or (currentWeekDay - 1)
        
        -- 计算距离下次重置的天数
        local daysUntilReset = resetDay - ourWeekDay
        if daysUntilReset < 0 or (daysUntilReset == 0 and currentDate.hour >= resetHour) then
            daysUntilReset = daysUntilReset + 7
        end
        
        -- 计算重置时间戳
        local resetTime = currentTime + daysUntilReset * 86400
        resetTime = resetTime - (currentDate.hour * 3600 + currentDate.min * 60 + currentDate.sec)
        resetTime = resetTime + resetHour * 3600
        
        return resetTime
    end
    
    return 0
end

-- 导出函数
_G.CalculateNextResetTime = CalculateNextResetTime