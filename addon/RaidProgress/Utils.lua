-- Utils.lua - 工具函数

-- 调试模式标志
local debugMode = false

-- 设置调试模式
function SetDebugMode(enabled)
    debugMode = enabled
end

-- 获取调试模式状态
function GetDebugMode()
    return debugMode
end

-- 安全打印函数
function SafePrint(msg)
    if msg and DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage(tostring(msg))
    end
end

-- 调试打印函数
function DebugPrint(msg)
    if debugMode then
        SafePrint("[RaidProgress Debug] " .. tostring(msg))
    end
end

-- 深度复制表
function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- 检查表是否为空
function IsTableEmpty(t)
    if not t then return true end
    return next(t) == nil
end

-- 获取表大小
function GetTableSize(t)
    if not t then return 0 end
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- 获取当前时间
local currentTime = time()
function UpdateCurrentTime()
    currentTime = time()
end

function GetCurrentTime()
    return currentTime
end

-- 安全获取玩家信息
function SafeGetPlayerInfo()
    local name = UnitName("player") or "Unknown"
    local level = UnitLevel("player") or 1
    local class = UnitClass("player") or "Unknown"
    local realm = GetRealmName() or "Unknown"
    
    return {
        name = name,
        level = level,
        class = class,
        realm = realm,
        fullName = name .. "-" .. realm
    }
end

-- 安全获取服务器名称
function GetSafeServerName()
    return GetRealmName() or "Unknown"
end

-- 检查是否有服务器特定配置
function HasServerSpecificConfig()
    if not RaidProgressConfig or not RaidProgressConfig.SERVER_SPECIFIC_CONFIGS then
        return false
    end
    
    local serverName = GetSafeServerName()
    return RaidProgressConfig.SERVER_SPECIFIC_CONFIGS[serverName] ~= nil
end

-- 获取当前服务器配置
function GetCurrentServerConfig()
    if RaidProgressConfig and RaidProgressConfig.GetServerRaidConfig then
        return RaidProgressConfig.GetServerRaidConfig()
    end
    return {}
end

-- 安全执行函数
function SafeExecute(func, name, timeout)
    timeout = timeout or 5
    name = name or "Unknown"
    
    local success, result = pcall(func)
    if not success then
        SafePrint("[RaidProgress Error] " .. name .. ": " .. tostring(result))
        return false, result
    end
    return true, result
end

-- 计算表元素数量
function CountTableElements(t)
    if not t or type(t) ~= "table" then return 0 end
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- 导出工具函数
RaidProgressUtils = {
    SetDebugMode = SetDebugMode,
    GetDebugMode = GetDebugMode,
    SafePrint = SafePrint,
    DebugPrint = DebugPrint,
    DeepCopy = DeepCopy,
    IsTableEmpty = IsTableEmpty,
    GetTableSize = GetTableSize,
    UpdateCurrentTime = UpdateCurrentTime,
    GetCurrentTime = GetCurrentTime,
    SafeGetPlayerInfo = SafeGetPlayerInfo,
    GetSafeServerName = GetSafeServerName,
    HasServerSpecificConfig = HasServerSpecificConfig,
    GetCurrentServerConfig = GetCurrentServerConfig,
    SafeExecute = SafeExecute,
    CountTableElements = CountTableElements
}