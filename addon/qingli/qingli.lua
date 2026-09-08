-- 创建主框架
local qingliFrame = CreateFrame("Frame", "QingliFrame", UIParent)
-- 初始化全局保存变量（用于持久化配置）
QingliDB = QingliDB or { interval = 10 }
local interval = tonumber(QingliDB.interval) or 10 -- 优先使用保存值，无保存时用10秒默认
local lastCleanTime = 0 -- 上次清理的时间
local isEnabled = true -- 默认启用内存清理

-- 创建状态文本
local statusText = qingliFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
statusText:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00已开启清理功能。|r")

-- 函数：执行内存清理
local function CleanMemory()
    collectgarbage() -- 执行内存清理
end

-- 函数：更新状态文本
local function UpdateStatusText()
    if isEnabled then
       DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00已开启清理功能。|r")
	   print("使用 /ql [数字] 来设置清理时间，使用 /ql 切换清理功能。")
	   print("当前清理时间: " .. QingliDB.interval .. "秒")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000已关闭清理功能。|r") 
	    print("使用 /ql [数字] 来设置清理时间，使用 /ql 切换清理功能。")
	 print("当前清理时间: " .. QingliDB.interval .. "秒")
    end

end

-- 函数：加载设置
local function LoadSettings()
    interval = tonumber(QingliDB.interval) or 10 -- 从全局保存变量加载设置
  
end

-- 函数：保存设置
local function SaveSettings()
    QingliDB.interval = interval -- 保存到全局变量实现持久化
  
end

-- 注册插件命令
SLASH_QINGLI1 = '/ql'
SlashCmdList["QINGLI"] = function(input)
    if input and tonumber(input) then
        interval = tonumber(input)
        SaveSettings() -- 保存新的设置
        print("清理时间设置为: " .. QingliDB.interval .. "秒")
    else
        isEnabled = not isEnabled -- 切换状态
        UpdateStatusText() -- 更新状态文本
    end
end

-- 注册 PLAYER_ENTERING_WORLD 事件来初始化插件
qingliFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
qingliFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        LoadSettings() -- 加载设置
        UpdateStatusText() -- 更新状态文本
        print("内存清理插件已加载。使用 /ql [数字] 来设置清理时间，使用 /ql 切换清理功能。")
        print("当前清理时间: " .. QingliDB.interval .. "秒")
    end
end)

-- 主循环：定时清理内存
local lastTime = GetTime() -- 获取当前时间

qingliFrame:SetScript("OnUpdate", function(self)
    if isEnabled then
        local currentTime = GetTime() -- 获取当前时间
        local elapsed = currentTime - lastTime -- 计算经过的时间
        lastTime = currentTime -- 更新上次时间

        lastCleanTime = lastCleanTime + elapsed

        if lastCleanTime >= interval then
            CleanMemory() -- 到达时间后清理内存
            lastCleanTime = 0 -- 重置计时器
        end
    end
end)