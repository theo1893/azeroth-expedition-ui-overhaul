-- RaidProgressUI.lua - 副本进度检查插件 UI 框架（兼容旧版）

-- 创建一个 Ace2 插件对象
local RaidProgressUI = AceLibrary("AceAddon-2.0"):new(
    "AceEvent-2.0",
    "AceConsole-2.0"
)

-- 全局命名空间注册
_G["RaidProgressUI"] = RaidProgressUI

-- 创建主窗口
local function CreateMainWindow()
    local mainFrame = CreateFrame("Frame", "RaidProgressUIMainFrame", UIParent)
    mainFrame:SetWidth(400)  -- 分开设置宽度
    mainFrame:SetHeight(600) -- 分开设置高度
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    mainFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 25,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    mainFrame:SetBackdropColor(0, 0, 0, 1)
    mainFrame:Hide()
    
    -- 添加拖动功能
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", function() 
        mainFrame:StartMoving() 
    end)
    mainFrame:SetScript("OnDragStop", function() 
        mainFrame:StopMovingOrSizing() 
    end)
    
    -- 创建标题栏
    local titleBar = CreateFrame("Frame", nil, mainFrame)
    titleBar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)
    titleBar:SetHeight(24)  -- 高度单独设置
    titleBar:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    titleBar:SetBackdropColor(0.2, 0.2, 0.2, 0) -- 可调透明度
    titleBar:SetBackdropBorderColor(0, 0, 0, 0) 
    
    -- 标题文字
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("CENTER", titleBar, "CENTER", 0, -2)
    titleText:SetText("副本进度查询")
    titleText:SetTextColor(1, 1, 1)
    
    -- 设置标题栏为拖动区域
    titleBar:SetScript("OnMouseDown", function() 
        mainFrame:StartMoving() 
    end)
    titleBar:SetScript("OnMouseUp", function() 
        mainFrame:StopMovingOrSizing() 
    end)

    -- 创建滚动框架
    local scrollFrame = CreateFrame("ScrollFrame", "RaidProgressUIScrollFrame", mainFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -30, 10)
    
    -- 创建内容框架（分开设置宽度和高度）
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetWidth(scrollFrame:GetWidth())  -- 宽度单独设置
    contentFrame:SetHeight(10)                    -- 高度单独设置（初始值）
    scrollFrame:SetScrollChild(contentFrame)
    
    -- 创建文本框架（简单的FontString）
    local textFrame = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, 0)
    textFrame:SetPoint("RIGHT", contentFrame, "RIGHT", 0, 0)
    textFrame:SetJustifyH("LEFT")
    textFrame:SetJustifyV("TOP")
   -- textFrame:SetWordWrap(true)  -- 允许自动换行
    
    -- 创建关闭按钮
    local closeButton = CreateFrame("Button", "RaidProgressUICloseButton", mainFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", 0, 0)
    closeButton:SetScript("OnClick", function() mainFrame:Hide() end)

    -- 支持ESC关闭窗口
    table.insert(UISpecialFrames, "RaidProgressUIMainFrame")

    return mainFrame, textFrame, contentFrame, scrollFrame
end

-- 显示文本到UI
local function ShowTextToUI(textFrame, contentFrame, text)
    -- 设置文本
    textFrame:SetText(text)
    
    -- 计算所需高度（不使用gsub）
    local _, fontSize = textFrame:GetFontObject():GetFont()
    local lineHeight = fontSize + 2
    
    -- 手动计算行数
    local numLines = 1
    local textLen = string.len(text)
    for i = 1, textLen do
        if string.sub(text, i, i) == "\n" then
            numLines = numLines + 1
        end
    end
    
    -- 分开设置内容框架高度
    contentFrame:SetHeight(numLines * lineHeight + 20)  -- 添加额外边距
end

-- 初始化 UI 框架
function RaidProgressUI:OnInitialize()
    self.mainFrame, self.textFrame, self.contentFrame, self.scrollFrame = CreateMainWindow()

    self:RegisterChatCommand({"/rpui", "/rp"}, function(msg)
        -- 只显示进度和状态
        self.mainFrame:Show()
        local oldPrint = print
        local output = "=== 副本进度 ===\n"
        print = function(arg1, arg2, arg3, arg4, arg5)
            if arg1 then output = output .. tostring(arg1) end
            if arg2 then output = output .. tostring(arg2) end
            if arg3 then output = output .. tostring(arg3) end
            if arg4 then output = output .. tostring(arg4) end
            if arg5 then output = output .. tostring(arg5) end
            output = output .. "\n"
        end

        RaidProgress:ShowProgress()
        output = output .. "\n=== 副本状态 ===\n"
        RaidProgress:ShowAllRaidsStatus()

        print = oldPrint
        ShowTextToUI(self.textFrame, self.contentFrame, output)

        -- 滚动到顶部
        self.scrollFrame:SetVerticalScroll(0)
    end)
      -- 等待RaidInfoFrame加载完成再加钩子
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(_, addonName)
        if addonName == "Blizzard_RaidUI" or RaidInfoFrame then
            if RaidInfoFrame and RaidInfoFrame.SetScript then
                RaidInfoFrame:SetScript("OnShow", function()
                    RaidProgressUI:ShowCombinedInfo()
                end)
            end
            f:UnregisterEvent("ADDON_LOADED")
        end
    end)
end

-- 公共方法：显示组合信息
function RaidProgressUI:ShowCombinedInfo()
        -- 让窗口显示在 RaidInfoFrame 右侧
    if RaidInfoFrame then
        self.mainFrame:ClearAllPoints()
        self.mainFrame:SetPoint("TOPLEFT", RaidInfoFrame, "TOPRIGHT", 10, 0)
        
    end

    self.mainFrame:Show()
    
    -- 调用原有函数并捕获输出
    local oldPrint = print
    local output = "=== 副本进度 ===\n"
    print = function(arg1, arg2, arg3, arg4, arg5)
        if arg1 then output = output .. tostring(arg1) end
        if arg2 then output = output .. tostring(arg2) end
        if arg3 then output = output .. tostring(arg3) end
        if arg4 then output = output .. tostring(arg4) end
        if arg5 then output = output .. tostring(arg5) end
        output = output .. "\n"
    end
    
    RaidProgress:ShowProgress()
    
    output = output .. "\n=== 副本状态 ===\n"
    RaidProgress:ShowAllRaidsStatus()
    
    print = oldPrint
    ShowTextToUI(self.textFrame, self.contentFrame, output)
    
    -- 滚动到顶部
    self.scrollFrame:SetVerticalScroll(0)
end

--公共方法：隐藏组合信息
function RaidProgressUI:HideCombinedInfo()
    
        self.mainFrame:Hide()
   
end
