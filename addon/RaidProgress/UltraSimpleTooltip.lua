print("|cFFFFAA00加载 UltraSimpleTooltip.lua - 超简单工具提示|r")

-- 超简单的工具提示实现，完全兼容 WoW 1.12

-- 副本名称映射表
local RAID_NAMES = {}
RAID_NAMES[409] = "熔火之心"
RAID_NAMES[469] = "黑翼之巢"
RAID_NAMES[509] = "奥妮克希亚的巢穴"
RAID_NAMES[531] = "祖尔格拉布"
RAID_NAMES[718] = "安其拉废墟"
RAID_NAMES[719] = "安其拉神殿"
RAID_NAMES[533] = "纳克萨玛斯"
RAID_NAMES[540] = "翡翠圣地"
RAID_NAMES[535] = "卡拉赞下层大厅"
RAID_NAMES[536] = "卡拉赞之塔"

-- 周常任务名称映射表
local QUEST_NAMES = {}
QUEST_NAMES["quest_1"] = "武装的召唤：净化腐化"
QUEST_NAMES["quest_2"] = "武装的召唤：地下城探索"
QUEST_NAMES["quest_3"] = "武装的召唤：熔火突袭"

-- 创建超简单的工具提示函数（支持任务和副本）
local function CreateUltraSimpleTooltip(button, raidId, isReset, raidInfo)
    if not button or not raidId then
        return
    end
    
    button:SetScript("OnEnter", function()
        if GameTooltip then
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            
            -- 判断是任务还是副本
            local isQuest = raidInfo and raidInfo.isQuest
            
            if isQuest then
                -- 处理周常任务
                local questName = QUEST_NAMES[raidId] or raidInfo.fullName or "未知任务"
                GameTooltip:SetText(questName)
                
                -- 根据任务状态显示不同信息
                if raidInfo.questStatus == "completed" then
                    GameTooltip:AddLine("本周已完成", 1, 0.8, 0) -- 金色
                    GameTooltip:AddLine("等待下周重置", 0.6, 0.6, 1) -- 淡蓝色
                elseif raidInfo.questStatus == "inprogress" then
                    GameTooltip:AddLine("任务进行中", 0, 0.8, 1) -- 蓝色
                    GameTooltip:AddLine("请完成任务目标", 1, 1, 0.6) -- 淡黄色
                elseif raidInfo.questStatus == "available" and isReset then
                    GameTooltip:AddLine("可以接取", 0, 1, 0) -- 绿色
                    GameTooltip:AddLine("可前往NPC接取", 0.7, 0.9, 1) -- 浅蓝色
                elseif raidInfo.questStatus == "available" and not isReset then
                    GameTooltip:AddLine("可接取（未重置）", 1, 1, 0) -- 黄色
                    GameTooltip:AddLine("下次重置：周三 12:00", 1, 0.8, 0.4) -- 橙色
                else
                    GameTooltip:AddLine("状态未知", 0.7, 0.7, 0.7) -- 灰色
                end
                
                GameTooltip:AddLine("周常任务", 0.8, 0.8, 0.8) -- 灰色说明
                
            else
                -- 处理副本
                local raidName = RAID_NAMES[raidId] or "未知副本"
                GameTooltip:SetText(raidName)
                
                if isReset then
                    GameTooltip:AddLine("已重置", 0, 1, 0) -- 绿色
                    GameTooltip:AddLine("可以进入", 0.7, 0.9, 1) -- 浅蓝色
                else
                    GameTooltip:AddLine("冷却中", 1, 0, 0) -- 红色
                    GameTooltip:AddLine("无法进入", 1, 0.5, 0.5) -- 淡红色
                end
                
                GameTooltip:AddLine("副本进度", 0.8, 0.8, 0.8) -- 灰色说明
            end
            
            GameTooltip:Show()
        end
    end)
    
    button:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
end

-- 导出函数
_G.CreateUltraSimpleTooltip = CreateUltraSimpleTooltip
_G.RAID_NAMES = RAID_NAMES
_G.QUEST_NAMES = QUEST_NAMES

-- 测试函数
local function TestTooltip()
    print("=== 工具提示测试 ===")
    
    -- 创建副本测试按钮
    local testButton1 = CreateFrame("Button", "TestTooltipButton1", UIParent)
    testButton1:SetWidth(100)
    testButton1:SetHeight(30)
    testButton1:SetPoint("CENTER", UIParent, "CENTER", -120, 50)
    
    local buttonText1 = testButton1:CreateFontString(nil, "OVERLAY")
    buttonText1:SetFont("Fonts\\FRIZQT__.TTF", 12)
    buttonText1:SetPoint("CENTER")
    buttonText1:SetText("MC副本")
    buttonText1:SetTextColor(1, 1, 1)
    
    -- 添加副本工具提示
    CreateUltraSimpleTooltip(testButton1, 409, true, {isQuest = false})  -- MC，已重置
    
    -- 创建任务测试按钮
    local testButton2 = CreateFrame("Button", "TestTooltipButton2", UIParent)
    testButton2:SetWidth(100)
    testButton2:SetHeight(30)
    testButton2:SetPoint("CENTER", UIParent, "CENTER", 120, 50)
    
    local buttonText2 = testButton2:CreateFontString(nil, "OVERLAY")
    buttonText2:SetFont("Fonts\\FRIZQT__.TTF", 12)
    buttonText2:SetPoint("CENTER")
    buttonText2:SetText("周任务")
    buttonText2:SetTextColor(1, 1, 0)
    
    -- 添加任务工具提示
    CreateUltraSimpleTooltip(testButton2, "quest_1", false, {
        isQuest = true, 
        fullName = "武装的召唤：净化腐化",
        questStatus = "inprogress"
    })
    
    testButton1:Show()
    testButton2:Show()
    
    print("测试按钮已创建：副本（左）和任务（右）")
    
    -- 5秒后隐藏
    local hideTimer = CreateFrame("Frame")
    hideTimer.elapsed = 0
    hideTimer:SetScript("OnUpdate", function()
        hideTimer.elapsed = hideTimer.elapsed + arg1
        if hideTimer.elapsed > 5 then
            testButton1:Hide()
            testButton2:Hide()
            hideTimer:SetScript("OnUpdate", nil)
            print("测试按钮已隐藏")
        end
    end)
end

-- 注册测试命令
SLASH_TOOLTIPTEST1 = "/testtooltip"
SlashCmdList["TOOLTIPTEST"] = function()
    TestTooltip()
end

print("|cFFFFAA00超简单工具提示已加载: /testtooltip|r")
