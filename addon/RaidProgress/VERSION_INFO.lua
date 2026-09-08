-- RaidProgress 2.0 版本信息
-- 副本进度检查插件 - 乌龟服定制版

local VERSION_INFO = {
    version = "2.0",
    build = "Release", 
    date = "2025-01-01",
    author = "吊儿啷当，德兔",
    description = "副本进度和周常任务跟踪插件",
    
    features = {
        "10个经典副本进度跟踪",
        "武装的召唤系列任务跟踪", 
        "13列表格界面显示",
        "智能工具提示系统",
        "多角色数据管理",
        "WoW 1.12 完全兼容"
    },
    
    changelog = {
        ["2.0"] = {
            "全新表格界面设计",
            "增加周常任务跟踪功能",
            "优化工具提示系统", 
            "提升兼容性和稳定性"
        }
    }
}

-- 导出版本信息
_G["RAIDPROGRESS_VERSION"] = VERSION_INFO

-- 版本检查函数
local function ShowVersion()
    print(string.format("|cFF00FF00RaidProgress %s|r - %s", 
        VERSION_INFO.version, VERSION_INFO.description))
    print(string.format("作者: %s", VERSION_INFO.author))
    print("输入 |cFFFFFF00/rp|r 开始使用")
end

-- 启动时显示版本信息
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function()
    if arg1 == "RaidProgress" then
        -- 延迟显示，避免被其他插件信息覆盖
        local timer = CreateFrame("Frame")
        timer.elapsed = 0
        timer:SetScript("OnUpdate", function()
            timer.elapsed = timer.elapsed + arg1
            if timer.elapsed > 2 then -- 2秒后显示
                ShowVersion()
                timer:SetScript("OnUpdate", nil)
            end
        end)
    end
end)
