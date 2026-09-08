-- 提供几种常见的符号组合选项
local function QuickSymbolFix()
    print("=== 快速符号修复选项 ===")
    print("1. /symbol1 - 使用 + 和 - (加减号)")
    print("2. /symbol2 - 使用 O 和 X (字母)")
    print("3. /symbol3 - 使用 Y 和 N (Yes/No)")
    print("4. /symbol4 - 使用 * 和   (星号和空格)")
    print("5. /symbol5 - 使用 1 和 0 (数字)")
    print("6. /symboltest - 打开测试窗口查看所有选项")
    print("选择一个选项后使用 /sreload 重新加载界面")
end

-- 选项 1: + 和 -
SLASH_SYMBOL1_1 = "/symbol1"
SlashCmdList["SYMBOL1"] = function()
    _G.RAID_RESET_SYMBOL = "+"
    _G.RAID_COOLDOWN_SYMBOL = "-"
end

-- 选项 2: O 和 X
SLASH_SYMBOL2_1 = "/symbol2"
SlashCmdList["SYMBOL2"] = function()
    _G.RAID_RESET_SYMBOL = "O"
    _G.RAID_COOLDOWN_SYMBOL = "X"
end

-- 选项 3: Y 和 N
SLASH_SYMBOL3_1 = "/symbol3"
SlashCmdList["SYMBOL3"] = function()
    _G.RAID_RESET_SYMBOL = "Y"
    _G.RAID_COOLDOWN_SYMBOL = "N"
end

-- 选项 4: * 和 空格
SLASH_SYMBOL4_1 = "/symbol4"
SlashCmdList["SYMBOL4"] = function()
    _G.RAID_RESET_SYMBOL = "*"
    _G.RAID_COOLDOWN_SYMBOL = " "
end

-- 选项 5: 1 和 0
SLASH_SYMBOL5_1 = "/symbol5"
SlashCmdList["SYMBOL5"] = function()
    _G.RAID_RESET_SYMBOL = "1"
    _G.RAID_COOLDOWN_SYMBOL = "0"
end

-- 显示当前设置
SLASH_SHOWSYMBOLS1 = "/showsymbols"
SlashCmdList["SHOWSYMBOLS"] = function()
    local reset = _G.RAID_RESET_SYMBOL or "默认"
    local cooldown = _G.RAID_COOLDOWN_SYMBOL or "默认"
    print("当前符号设置: " .. reset .. " (重置) / " .. cooldown .. " (冷却)")
end

-- 注册帮助命令
SLASH_SYMBOLHELP1 = "/symbolhelp"
SlashCmdList["SYMBOLHELP"] = function()
    QuickSymbolFix()
end
