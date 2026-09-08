print("|cFFFF0000加载 SimpleCompat.lua - 简单兼容性修复|r")

-- 极简的 WoW 1.12 兼容性修复，避免所有可能的问题

-- 1. 安全的 mod 函数
local function SafeMod(a, b)
    if not a or not b or b == 0 then
        return 0
    end
    return a - math.floor(a/b) * b
end

-- 2. 安全的时间计算
local function SafeTimeCalc(timeLeft)
    if not timeLeft or timeLeft <= 0 then
        return 0, 0
    end
    
    local totalHours = math.floor(timeLeft / 3600)
    local days = math.floor(totalHours / 24)
    local hours = totalHours - (days * 24)
    
    return days, hours
end

-- 3. 简单的字符串分割
local function SimpleSplit(str, sep)
    local result = {}
    local start = 1
    local pos = 1
    
    while pos <= string.len(str) do
        local found = string.find(str, sep, pos, true)
        if found then
            local part = string.sub(str, start, found - 1)
            table.insert(result, part)
            pos = found + 1
            start = pos
        else
            local part = string.sub(str, start)
            if string.len(part) > 0 then
                table.insert(result, part)
            end
            break
        end
    end
    
    return result
end

-- 4. 安全的表格计数
local function SafeTableCount(t)
    if not t then
        return 0
    end
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

-- 5. 导出到全局作用域
_G.SafeMod = SafeMod
_G.SafeTimeCalc = SafeTimeCalc  
_G.SimpleSplit = SimpleSplit
_G.SafeTableCount = SafeTableCount

-- 6. 简单测试
local function SimpleTest()
    print("=== 简单兼容性测试 ===")
    
    -- 测试 mod
    print("SafeMod(25, 24) = " .. SafeMod(25, 24))
    
    -- 测试时间计算
    local days, hours = SafeTimeCalc(90000)
    print("90000秒 = " .. days .. "天" .. hours .. "小时")
    
    -- 测试分割
    local parts = SimpleSplit("a.b.c", ".")
    print("分割测试: " .. SafeTableCount(parts) .. " 个部分")
    
    print("=== 测试完成 ===")
end

-- 注册命令
SLASH_SIMPLETEST1 = "/simpletest"
SlashCmdList["SIMPLETEST"] = function()
    SimpleTest()
end

-- 立即执行测试
SimpleTest()

print("|cFFFF0000简单兼容性修复已加载: /simpletest|r")
