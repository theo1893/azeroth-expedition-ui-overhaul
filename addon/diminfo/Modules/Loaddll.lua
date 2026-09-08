-- 创建模组状态显示框
local diminfo_Loaddll = CreateFrame("Button", "diminfo_Loaddll", UIParent)
local Text = diminfo_Loaddll:CreateFontString(nil, "OVERLAY")
Text:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
Text:SetPoint("LEFT", diminfo_pos, "RIGHT", 20, 0)
diminfo_Loaddll:SetAllPoints(Text)

-- 颜色定义
local colorLoaded = {1, 1, 1}    -- 白色 (已加载)
local colorNotLoaded = {0.38, 0.38, 0.38} -- 灰色 (未加载)
local colorName = {0.3, 1, 0.6}     -- 模组名称颜色 (.3, 1, .6)

-- 更新模组状态显示
local function UpdateAddonStatus()
    local sStatus = SUPERWOW_STRING and colorLoaded or colorNotLoaded
    local uStatus = (type(UnitXP) == "function" and pcall(UnitXP, "nop", "nop")) and colorLoaded or colorNotLoaded
    local nStatus = (type(GetNampowerVersion) == "function") and colorLoaded or colorNotLoaded
	local iStatus = (type(Interact) == "function" or (Interact and type(Interact.Version) == "function")) and colorLoaded or colorNotLoaded
    
    Text:SetText(string.format("|cff%02x%02x%02xS|r |cff%02x%02x%02xU|r |cff%02x%02x%02xN|r |cff%02x%02x%02xI|r",
        sStatus[1]*255, sStatus[2]*255, sStatus[3]*255,
        uStatus[1]*255, uStatus[2]*255, uStatus[3]*255,
        nStatus[1]*255, nStatus[2]*255, nStatus[3]*255,
		iStatus[1]*255, iStatus[2]*255, iStatus[3]*255))
end

-- 鼠标提示
diminfo_Loaddll:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("模组状态")
    
    local nameColorCode = string.format("|cff%02x%02x%02x", 
        colorName[1]*255, colorName[2]*255, colorName[3]*255)
    
    -- 使用与主显示相同的判断逻辑
    local superwowLoaded = SUPERWOW_STRING ~= nil
    local unitXPLoaded = type(UnitXP) == "function" and pcall(UnitXP, "nop", "nop")
    local interactLoaded = type(Interact) == "function" or (Interact and type(Interact.Version) == "function")
    local nampowerLoaded = type(GetNampowerVersion) == "function"
    
    -- 添加各模组状态行，按 S U N I顺序
    GameTooltip:AddLine(nameColorCode.."SuperWOW:|r "..(superwowLoaded and "|cFFFFD700已加载|r" or "|cFF808080未加载|r"))
    GameTooltip:AddLine(nameColorCode.."UnitXP:|r "..(unitXPLoaded and "|cFFFFD700已加载|r" or "|cFF808080未加载|r"))
    GameTooltip:AddLine(nameColorCode.."Nampower:|r "..(nampowerLoaded and "|cFFFFD700已加载|r" or "|cFF808080未加载|r"))
	GameTooltip:AddLine(nameColorCode.."Interact:|r "..(interactLoaded and "|cFFFFD700已加载|r" or "|cFF808080未加载|r"))
    
    GameTooltip:Show()
end)

diminfo_Loaddll:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- 注册事件
diminfo_Loaddll:RegisterEvent("PLAYER_LOGIN")
diminfo_Loaddll:RegisterEvent("ADDON_LOADED")
diminfo_Loaddll:SetScript("OnEvent", UpdateAddonStatus)