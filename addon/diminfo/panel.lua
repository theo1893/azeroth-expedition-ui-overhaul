--来自EK的diminfo，1.12修改by狗血编剧男
local MediaFolder = "Interface\\AddOns\\diminfo\\Media\\"

-- 获取当前角色的唯一标识符（服务器名-角色名）
local function GetCharacterKey()
    return GetRealmName() .. "-" .. UnitName("player")
end

-- 获取当前角色的配置，如果不存在则创建默认配置
local function GetCharacterConfig()
    local charKey = GetCharacterKey()
    
    -- 确保全局配置表存在
    if not DimInfo_Config then
        DimInfo_Config = {}
    end
    
    -- 如果当前角色配置不存在，创建默认配置
    if not DimInfo_Config[charKey] then
        DimInfo_Config[charKey] = {
            x = 0,
            spacing = 20,  -- 添加间距设置，默认20
            Hidden = {},
            OrderLeft = { "diminfo_Performance", "diminfo_RaidCD", "diminfo_Quest", "diminfo_Friend", "diminfo_Time" },
            OrderRight = { "diminfo_Loaddll", "diminfo_Durability", "diminfo_Bag", "diminfo_Gold" },
            ShowSeconds = false,  -- 默认不显示秒
            FontSize = 14  -- 添加字体大小设置，默认14
        }
    end
    
    -- 确保配置字段存在
    local config = DimInfo_Config[charKey]
    if not config.Hidden then config.Hidden = {} end
    if not config.OrderLeft then 
        config.OrderLeft = { "diminfo_Performance", "diminfo_RaidCD", "diminfo_Quest", "diminfo_Friend", "diminfo_Time" }
    end
    if not config.OrderRight then 
        config.OrderRight = { "diminfo_Loaddll", "diminfo_Durability", "diminfo_Bag", "diminfo_Gold" }
    end
    if config.x == nil then config.x = 0 end
    if config.spacing == nil then config.spacing = 20 end  -- 确保间距字段存在
    if config.ShowSeconds == nil then config.ShowSeconds = false end  -- 确保显示秒字段存在
    if config.FontSize == nil then config.FontSize = 14 end  -- 确保字体大小字段存在
    
    return config
end

-- 重置当前角色配置到默认状态
local function ResetCharacterConfig()
    local charKey = GetCharacterKey()
    
    DimInfo_Config[charKey] = {
        x = 0,
        spacing = 20,  -- 重置为默认间距
        Hidden = {},
        OrderLeft = { "diminfo_Performance", "diminfo_RaidCD", "diminfo_Quest", "diminfo_Friend", "diminfo_Time" },
        OrderRight = { "diminfo_Loaddll", "diminfo_Durability", "diminfo_Bag", "diminfo_Gold" },
        ShowSeconds = false,  -- 默认不显示秒
        FontSize = 14  -- 重置为默认字体大小
    }
    
    return DimInfo_Config[charKey]
end

-- 保存当前角色配置
local function SaveCharacterConfig()
    -- 配置已经通过引用更新，不需要额外保存
    -- WoW会自动保存全局变量DimInfo_Config
end

-- 更新所有模块字体大小
local function UpdateAllModulesFontSize()
    local config = GetCharacterConfig()
    local fontSize = config.FontSize or 14
    
    -- 模块列表
    local allModules = {
        "diminfo_Time", "diminfo_RaidCD", "diminfo_Quest", "diminfo_pos",
        "diminfo_Performance", "diminfo_Loaddll", "diminfo_Gold", 
        "diminfo_Friend", "diminfo_Durability", "diminfo_Bag"
    }
    
    for _, name in pairs(allModules) do
        local frame = getglobal(name)
        if frame then
            -- 遍历Frame的所有区域，查找FontString对象
            local regions = {frame:GetRegions()}
            local fontStringsProcessed = 0
            
            for _, region in ipairs(regions) do
                if region:GetObjectType() == "FontString" then
                    local _, _, fontFlags = region:GetFont()
                    region:SetFont(STANDARD_TEXT_FONT, fontSize, fontFlags)
                    fontStringsProcessed = fontStringsProcessed + 1
                    
                    -- 对于金币模块，最多处理3个FontString（金、银、铜）
                    if name == "diminfo_Gold" and fontStringsProcessed >= 3 then
                        break
                    end
                end
            end
            
            -- 特殊处理金币模块：还需要检查子Frame中的FontString
            if name == "diminfo_Gold" then
                local children = {frame:GetChildren()}
                for _, child in ipairs(children) do
                    local childRegions = {child:GetRegions()}
                    for _, region in ipairs(childRegions) do
                        if region:GetObjectType() == "FontString" then
                            local _, _, fontFlags = region:GetFont()
                            region:SetFont(STANDARD_TEXT_FONT, fontSize, fontFlags)
                        end
                    end
                end
            end
        end
    end
end

--创建框架
local CreatePanel = function(anchor, parent, relativeTo, x, y, w, h, a)
	local panel = CreateFrame("Frame", "diminfopanel", parent)
	local framelvl = parent:GetFrameLevel()

	-- 使用保存的位置或默认位置
    -- 先获取默认配置，等VARIABLES_LOADED后再更新
    local defaultCfg = { x = x, spacing = 20, Hidden = {}, FontSize = 14 }
    local cfg = defaultCfg  -- 临时使用默认值，事件加载后会更新

	--中间
    panel:SetWidth(w)
	panel:SetHeight(h)
	panel:ClearAllPoints()
	-- 仅使用 X 偏移，保持 Y 和其他锚点固定 (根据用户需求，主要是左右移动)
    -- 如果这里写死了 CENTER/TOP，那么 x 就是相对屏幕中心的偏移
	panel:SetPoint("CENTER", parent, "TOP", cfg.x or x, -10)
	panel:SetFrameStrata("BACKGROUND")
	panel:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)

	panel:SetBackdropColor(.1, .1, .1, a)
	panel:SetBackdropBorderColor(0, 0, 0)
	panel.bg = panel:CreateTexture(nil, "BACKGROUND")
	panel.bg:SetAllPoints(panel)
	panel.bg:SetTexture(MediaFolder.."bar")
	panel.bg:SetVertexColor(.1, .1, .1, a)

	--左侧渐变
	local left = CreateFrame("Frame", nil, parent)
	left:SetWidth(50)
	left:SetHeight(h)		
	left:ClearAllPoints()
	left:SetPoint("RIGHT", panel, "LEFT", 0, 0)
	left:SetFrameStrata("BACKGROUND")
	left:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)
	
	left.bg = left:CreateTexture(nil, "BACKGROUND")
	left.bg:SetAllPoints(left)
	left.bg:SetTexture(MediaFolder.."bar")
	left.bg:SetGradientAlpha("HORIZONTAL", .1, .1, .1, 0, .1, .1, .1, a)
		
	--右侧渐变
	local right = CreateFrame("Frame", nil, parent)
	right:SetWidth(50)
	right:SetHeight(h)
	right:ClearAllPoints()
	right:SetPoint("LEFT", panel, "RIGHT", 0, 0)
	right:SetFrameStrata("BACKGROUND")
	right:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)
	
	right.bg = right:CreateTexture(nil, "BACKGROUND")
	right.bg:SetAllPoints(right)
	right.bg:SetTexture(MediaFolder.."bar")
	right.bg:SetGradientAlpha("HORIZONTAL", .1, .1, .1, a, .1, .1, .1, 0)

    -- 更新位置函数
    panel.UpdatePosition = function(newX)
        local config = GetCharacterConfig()
        config.x = newX
        panel:ClearAllPoints()
        panel:SetPoint("CENTER", parent, "TOP", newX, -10)
    end

    -- 更新间距函数
    panel.UpdateSpacing = function(newSpacing)
        local config = GetCharacterConfig()
        config.spacing = newSpacing
        panel.ReanchorModules()  -- 重新锚定模块以应用新间距
    end
    
    -- 更新字体大小函数
    panel.UpdateFontSize = function(newFontSize)
        local config = GetCharacterConfig()
        config.FontSize = newFontSize
        SaveCharacterConfig()
        UpdateAllModulesFontSize()
    end
    
    -- 重新锚定模块以消除空隙
    panel.ReanchorModules = function()
        local config = GetCharacterConfig()
        
        -- 确保配置存在
        if not config.OrderLeft then
            config.OrderLeft = { "diminfo_Friend", "diminfo_Time", "diminfo_RaidCD", "diminfo_Quest" }
        end
        if not config.OrderRight then
            config.OrderRight = { "diminfo_Loaddll", "diminfo_Performance", "diminfo_Durability", "diminfo_Bag", "diminfo_Gold" }
        end
        
        local posFrame = getglobal("diminfo_pos")
        local isPosVisible = posFrame and not config.Hidden["diminfo_pos"]

        -- 获取当前间距设置
        local spacing = config.spacing or 20
        local centerSpacing = spacing / 2  -- 中心间距为一半
        -- 左侧链 (向左延伸)
        -- 用户需求：1 (最左) -> 2 -> 3 -> [Center]
        -- 所以我们需要倒序遍历：先锚定 index=Max (靠近 Center)，然后 index=Max-1 锚定到 index=Max ...
        local leftChain = config.OrderLeft
        local leftCount = table.getn(leftChain)
        
        local lastAnchor = posFrame -- 默认锚点 (Center)
        local lastAnchorPoint = "LEFT" -- 默认锚点连接点
        local myAnchorPoint = "RIGHT" -- 模块连接点
        local xOffset = -spacing  -- 使用配置的间距

        if not isPosVisible then
            -- 如果中间的位置模块隐藏了，第一个左侧模块 (index=Max) 锚定到主面板中心左侧
            lastAnchor = panel
            lastAnchorPoint = "CENTER"
            xOffset = -centerSpacing  -- 使用中心间距 
        end
        
        -- 倒序遍历: 从靠近中心 (Index=Max) 到远离中心 (Index=1)
        for i = leftCount, 1, -1 do
            local name = leftChain[i]
            local frame = getglobal(name)
            if frame and not config.Hidden[name] then
                -- 查找该 Frame 下的第一个 FontString
                local regions = {frame:GetRegions()}
                local textRegion = nil
                for _, region in ipairs(regions) do
                    if region:GetObjectType() == "FontString" then
                        textRegion = region
                        break
                    end
                end
                
                -- 特殊处理金币模块（无论在左侧还是右侧）
                if name == "diminfo_Gold" then
                    -- 先锚定整个Frame
                    frame:ClearAllPoints()
                    frame:SetPoint(myAnchorPoint, lastAnchor, lastAnchorPoint, xOffset, 0)
                    
                    -- 如果文字存在，将其锚定到Frame的左侧
                    if textRegion then
                        textRegion:ClearAllPoints()
                        textRegion:SetPoint("LEFT", frame, "LEFT", 2, 0)
                    end
                    
                    lastAnchor = frame 
                    lastAnchorPoint = "LEFT"  -- 下一个模块应该锚定到金币Frame的左侧
                else
                    -- 标准模块
                    if textRegion then
                        textRegion:ClearAllPoints()
                        textRegion:SetPoint(myAnchorPoint, lastAnchor, lastAnchorPoint, xOffset, 0)
                        
                        lastAnchor = frame 
                        lastAnchorPoint = "LEFT"
                    end
                end
                
                xOffset = -spacing  -- 使用配置的间距
            end
        end

        -- 右侧链 (向右延伸)
        -- 保持正序：[Center] -> 1 -> 2 -> 3
        local rightChain = config.OrderRight
        
        lastAnchor = posFrame
        lastAnchorPoint = "RIGHT"
        myAnchorPoint = "LEFT"
        xOffset = spacing  -- 使用配置的间距
        
        if not isPosVisible then
            lastAnchor = panel
            lastAnchorPoint = "CENTER"
            xOffset = centerSpacing  -- 使用中心间距
        end

        for _, name in ipairs(rightChain) do
            local frame = getglobal(name)
            if frame and not config.Hidden[name] then
                -- 查找 FontString
                local regions = {frame:GetRegions()}
                local textRegion = nil
                for _, region in ipairs(regions) do
                    if region:GetObjectType() == "FontString" then
                        textRegion = region
                        break
                    end
                end
                
                -- 特殊处理金币模块（无论在左侧还是右侧）
                if name == "diminfo_Gold" then
                    -- 先锚定整个Frame
                    frame:ClearAllPoints()
                    frame:SetPoint(myAnchorPoint, lastAnchor, lastAnchorPoint, xOffset, 0)
                    
                    -- 如果文字存在，将其锚定到Frame的左侧
                    if textRegion then
                        textRegion:ClearAllPoints()
                        textRegion:SetPoint("LEFT", frame, "LEFT", 2, 0)
                    end
                    
                    lastAnchor = frame
                    lastAnchorPoint = "RIGHT"  -- 下一个模块应该锚定到金币Frame的右侧
                else
                    -- 标准模块
                    if textRegion then
                        textRegion:ClearAllPoints()
                        textRegion:SetPoint(myAnchorPoint, lastAnchor, lastAnchorPoint, xOffset, 0)
                        
                        lastAnchor = frame
                        lastAnchorPoint = "RIGHT"
                    end
                end
                
                xOffset = spacing  -- 使用配置的间距
            end
        end
    end

    -- 应用模块可见性
    panel.ApplyVisibility = function()
        local config = GetCharacterConfig()
        
        -- 模块列表 (仅用于初始隐藏/显示，顺序不重要)
        local allModules = {
            "diminfo_Time", "diminfo_RaidCD", "diminfo_Quest", "diminfo_pos",
            "diminfo_Performance", "diminfo_Loaddll", "diminfo_Gold", 
            "diminfo_Friend", "diminfo_Durability", "diminfo_Bag"
        }
        
        for _, name in pairs(allModules) do
            local frame = getglobal(name)
            if frame then
                if config.Hidden[name] then
                    frame:Hide()
                else
                    frame:Show()
                end
            end
        end
        
        panel.ReanchorModules()
    end

    -- 重置所有模块到默认状态
    panel.ResetAllModules = function()
        -- 重置配置
        local config = ResetCharacterConfig()
    
        -- 更新UI
        panel.UpdatePosition(config.x or 0)
        panel.UpdateSpacing(config.spacing or 20)
        panel.UpdateFontSize(config.FontSize or 14)  -- 重置字体大小
        panel.ApplyVisibility()
    
        --刷新设置页面
        if DimInfoOptions and DimInfoOptions.RefreshList then
            DimInfoOptions:RefreshList()
        end
		
        -- 刷新时间显示
        if DimInfo_Time_UpdateDisplay then
            DimInfo_Time_UpdateDisplay()
        end
    end
	
	panel:SetScript("OnEnter", function()
	    GameTooltip:SetOwner(panel, "ANCHOR_TOP")
	    GameTooltip:SetText("信息条")
	    GameTooltip:AddLine("右键打开设置界面", 1, 1, 1)
	    GameTooltip:Show()
    end)
	
    panel:SetScript("OnLeave", function()
	    GameTooltip:Hide()
    end)
    
	return panel
end

--锚点, 父级框架, 依靠, X, Y, 宽, 高, 透明
-- 注意：这里传入的参数将作为默认值，实际加载时会使用 SavedVariables
local frame = CreatePanel("CENTER", UIParent, "TOP", 0, -10, 480, 22, 0)

-- 配置面板
local optionsFrame
local optionsContent
local function CreateOptionsFrame()
    if optionsFrame then return optionsFrame end
    
    optionsFrame = CreateFrame("Frame", "DimInfoOptions", UIParent)
    optionsFrame:SetWidth(400)
    optionsFrame:SetHeight(610)  -- 增加高度以容纳新的字体大小设置项
    optionsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    optionsFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    optionsFrame:SetBackdropColor(0, 0, 0, 1)
    optionsFrame:EnableMouse(true)
    optionsFrame:SetMovable(true)
    optionsFrame:RegisterForDrag("LeftButton")
    optionsFrame:SetScript("OnDragStart", function() this:StartMoving() end)
    optionsFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    optionsFrame:Hide()

    -- 标题
    local title = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("diminfo设置")

    -- 关闭按钮
    local closeColor = CreateFrame("Button", nil, optionsFrame, "UIPanelCloseButton")
    closeColor:SetPoint("TOPRIGHT", -10, -10)

    -- 滑动条：X偏移
    local slider = CreateFrame("Slider", "DimInfoXSlider", optionsFrame, "OptionsSliderTemplate")
    slider:SetPoint("TOP", 0, -50)
    slider:SetWidth(200)
    slider:SetHeight(20)
    slider:SetMinMaxValues(-400, 400)
    slider:SetValueStep(1)
    slider:SetValue(GetCharacterConfig().x or 0)
    
    getglobal(slider:GetName() .. "Text"):SetText("水平偏移")
    getglobal(slider:GetName() .. "Low"):SetText("左")
    getglobal(slider:GetName() .. "High"):SetText("右")
    
    slider:SetScript("OnValueChanged", function()
        local val = this:GetValue()
        frame.UpdatePosition(val)
    end)

    -- 位置复位按钮
    local resetBtn = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
    resetBtn:SetWidth(70) 
    resetBtn:SetHeight(20)
    resetBtn:SetPoint("LEFT", slider, "RIGHT", 10, 0)
    resetBtn:SetText("位置复位")
    resetBtn:SetScript("OnClick", function()
        slider:SetValue(0)
    end)
	
    -- 滑动条：模块间距
    local spacingSlider = CreateFrame("Slider", "DimInfoSpacingSlider", optionsFrame, "OptionsSliderTemplate")
    spacingSlider:SetPoint("TOP", slider, "BOTTOM", 0, -25)
    spacingSlider:SetWidth(200)
    spacingSlider:SetHeight(20)
    spacingSlider:SetMinMaxValues(1, 50)  -- 间距范围：1到50
    spacingSlider:SetValueStep(1)
    spacingSlider:SetValue(GetCharacterConfig().spacing or 20)
    
    getglobal(spacingSlider:GetName() .. "Text"):SetText("模块间距")
    getglobal(spacingSlider:GetName() .. "Low"):SetText("窄")
    getglobal(spacingSlider:GetName() .. "High"):SetText("宽")
    
    spacingSlider:SetScript("OnValueChanged", function()
        local val = this:GetValue()
        frame.UpdateSpacing(val)
    end)

    -- 间距复位按钮
    local resetSpacingBtn = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
    resetSpacingBtn:SetWidth(70)
    resetSpacingBtn:SetHeight(20)
    resetSpacingBtn:SetPoint("LEFT", spacingSlider, "RIGHT", 10, 0)
    resetSpacingBtn:SetText("间距复位")
    resetSpacingBtn:SetScript("OnClick", function()
        spacingSlider:SetValue(20)  -- 默认间距为20
    end)
    
    -- 滑动条：字体大小
    local fontSizeSlider = CreateFrame("Slider", "DimInfoFontSizeSlider", optionsFrame, "OptionsSliderTemplate")
    fontSizeSlider:SetPoint("TOP", spacingSlider, "BOTTOM", 0, -25)
    fontSizeSlider:SetWidth(200)
    fontSizeSlider:SetHeight(20)
    fontSizeSlider:SetMinMaxValues(10, 20)  -- 字体大小范围：10到20
    fontSizeSlider:SetValueStep(1)
    fontSizeSlider:SetValue(GetCharacterConfig().FontSize or 14)
    
    getglobal(fontSizeSlider:GetName() .. "Text"):SetText("字体大小")
    getglobal(fontSizeSlider:GetName() .. "Low"):SetText("小")
    getglobal(fontSizeSlider:GetName() .. "High"):SetText("大")
    
    fontSizeSlider:SetScript("OnValueChanged", function()
        local val = this:GetValue()
        frame.UpdateFontSize(val)
    end)

    -- 字体大小复位按钮
    local resetFontSizeBtn = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
    resetFontSizeBtn:SetWidth(70)
    resetFontSizeBtn:SetHeight(20)
    resetFontSizeBtn:SetPoint("LEFT", fontSizeSlider, "RIGHT", 10, 0)
    resetFontSizeBtn:SetText("字体复位")
    resetFontSizeBtn:SetScript("OnClick", function()
        fontSizeSlider:SetValue(14)  -- 默认字体大小为14
    end)
        
    -- 时间显示秒复选框
    local showSecondsCheckbox = CreateFrame("CheckButton", "DimInfoShowSecondsCheckbox", optionsFrame, "UICheckButtonTemplate")
    showSecondsCheckbox:SetPoint("TOP", fontSizeSlider, "BOTTOM", -50, -15)
    showSecondsCheckbox:SetWidth(20)
    showSecondsCheckbox:SetHeight(20)
    getglobal(showSecondsCheckbox:GetName() .. "Text"):SetText("时间模块显示秒")
    showSecondsCheckbox:SetChecked(GetCharacterConfig().ShowSeconds)

    showSecondsCheckbox:SetScript("OnClick", function()
        local config = GetCharacterConfig()
        config.ShowSeconds = this:GetChecked()
        SaveCharacterConfig()
        -- 刷新时间显示
        if DimInfo_Time_UpdateDisplay then
            DimInfo_Time_UpdateDisplay()
        end
    end)
	
    -- 组件复位按钮
    local resetAllBtn = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
    resetAllBtn:SetWidth(70)
    resetAllBtn:SetHeight(22)
    resetAllBtn:SetPoint("TOP", showSecondsCheckbox, "BOTTOM", 50, -15)
    resetAllBtn:SetText("组件复位")
    resetAllBtn:SetScript("OnClick", function()
        frame.ResetAllModules()
    end)
    
    resetAllBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- 容器 Frame 用于刷新列表
    optionsContent = CreateFrame("Frame", "DimInfoOptionsContent", optionsFrame)
    optionsContent:SetPoint("TOPLEFT", 15, -230)  -- 调整位置，为新设置项留出空间
    optionsContent:SetPoint("BOTTOMRIGHT", -15, 15)

    -- 模块名称映射 (Friendly Name)
    local niceNames = {
        diminfo_pos = "位置",
        diminfo_Friend = "好友",
        diminfo_Time = "时间",
        diminfo_RaidCD = "团本CD",
        diminfo_Quest = "任务",
        diminfo_Performance = "性能",
        diminfo_Loaddll = "模组",
        diminfo_Durability = "耐久",
        diminfo_Bag = "背包",
        diminfo_Gold = "金币"
    }

    local function RefreshList()
        -- 获取当前角色配置
        local config = GetCharacterConfig()
        
        -- 更新滑动条的值
        slider:SetValue(config.x or 0)
        spacingSlider:SetValue(config.spacing or 20)  -- 更新间距滑动条
        fontSizeSlider:SetValue(config.FontSize or 14)  -- 更新字体大小滑动条
        showSecondsCheckbox:SetChecked(config.ShowSeconds)  -- 更新显示秒复选框
        
        -- 清理旧的子 frames (简单粗暴：Hide 掉之前创建的，或者重用)
        if not optionsContent.rows then optionsContent.rows = {} end
        
        -- 数据源 (Ensure unique lists)
        local leftList = config.OrderLeft
        local rightList = config.OrderRight
        
        -- 显示列表构建
        local displayList = {}
        
        -- 左侧 Header
        table.insert(displayList, {type="header", text="--- 左侧 (1=最左) ---"})
        for i, name in ipairs(leftList) do
            table.insert(displayList, {type="item", name=name, list="left", index=i, max=table.getn(leftList)})
        end
        
        -- 中间 (Location)
        table.insert(displayList, {type="header", text="--- 中心 (锚点) ---"})
        table.insert(displayList, {type="item", name="diminfo_pos", list="center", index=0, max=0})
        
        -- 右侧 Header
        table.insert(displayList, {type="header", text="--- 右侧 (1=最左) ---"})
        for i, name in ipairs(rightList) do
            table.insert(displayList, {type="item", name=name, list="right", index=i, max=table.getn(rightList)})
        end

        -- 渲染
        local yOffset = 0
        for i, dataInfo in ipairs(displayList) do
            -- Capture loop variable for closure
            local data = dataInfo 
            
            if not optionsContent.rows[i] then
                local row = CreateFrame("Frame", nil, optionsContent)
                row:SetWidth(360) 
                row:SetHeight(24)
                
                local cb = CreateFrame("CheckButton", "DimInfoRowChk"..i, row, "UICheckButtonTemplate")
                cb:SetPoint("LEFT", 0, 0)
                cb:SetWidth(20) cb:SetHeight(20)
                getglobal(cb:GetName().."Text"):SetFontObject("GameFontNormal")
                row.cb = cb
                
                -- Numeric Input Box
                local editBox = CreateFrame("EditBox", "DimInfoRowEdit"..i, row, "InputBoxTemplate")
                editBox:SetWidth(30)
                editBox:SetHeight(20)
                editBox:SetPoint("RIGHT", 0, 0)
                editBox:SetAutoFocus(false)
                editBox:SetMaxLetters(2)
                row.editBox = editBox
                
                -- Label for input
                local sortLabel = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
                sortLabel:SetPoint("RIGHT", editBox, "LEFT", -5, 0)
                sortLabel:SetText("序:")
                row.sortLabel = sortLabel
                
                -- Swap Side Button (< or >)
                local shiftBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                shiftBtn:SetWidth(20) shiftBtn:SetHeight(20)
                shiftBtn:SetPoint("RIGHT", sortLabel, "LEFT", -5, 0)
                row.shiftBtn = shiftBtn
                
                optionsContent.rows[i] = row
            end
            
            local row = optionsContent.rows[i]
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, yOffset)
            row:Show()
            
            if data.type == "header" then
                row.cb:Hide()
                row.editBox:Hide()
                row.sortLabel:Hide()
                row.shiftBtn:Hide()
                local fs = getglobal(row.cb:GetName().."Text")
                fs:SetText(data.text)
                fs:SetTextColor(1, 0.82, 0) -- Yellow
                fs:ClearAllPoints()
                fs:SetPoint("LEFT", 0, 0) -- Header align left
            else
                row.cb:Show()
                local fs = getglobal(row.cb:GetName().."Text")
                fs:SetText(niceNames[data.name] or data.name)
                fs:SetTextColor(1, 1, 1)
                fs:ClearAllPoints()
                fs:SetPoint("LEFT", row.cb, "RIGHT", 5, 0)
                
                -- Checkbox logic
                row.cb:SetChecked(not config.Hidden[data.name])
                row.cb:SetScript("OnClick", function()
                    config.Hidden[data.name] = not this:GetChecked()
                    SaveCharacterConfig()
                    frame.ApplyVisibility()
                end)
                
                -- Side Swap Button Logic
                if data.list == "center" then
                     row.shiftBtn:Hide()
                else
                     row.shiftBtn:Show()
                     -- Only show Valid moves
                     if data.list == "left" then
                         row.shiftBtn:SetText(">")
                         row.shiftBtn:SetScript("OnClick", function()
                             -- Move from Left to Right
                             table.remove(config.OrderLeft, data.index)
                             table.insert(config.OrderRight, data.name)
                             SaveCharacterConfig()
                             frame.ApplyVisibility()
                             RefreshList()
                         end)
                     else
                         row.shiftBtn:SetText("<")
                         row.shiftBtn:SetScript("OnClick", function()
                             -- Move from Right to Left
                             table.remove(config.OrderRight, data.index)
                             table.insert(config.OrderLeft, data.name)
                             SaveCharacterConfig()
                             frame.ApplyVisibility()
                             RefreshList()
                         end)
                     end
                end
                
                -- EditBox logic
                if data.list == "center" then
                    row.editBox:Hide()
                    row.sortLabel:Hide()
                else
                    row.editBox:Show()
                    row.sortLabel:Show()
                    row.editBox:SetText(data.index)
                    
                    row.editBox:SetScript("OnEnterPressed", function()
                        local val = tonumber(this:GetText())
                        if val and val >= 1 and val <= data.max and val ~= data.index then
                            local list = (data.list == "left") and config.OrderLeft or config.OrderRight
                            local item = list[data.index]
                            table.remove(list, data.index)
                            table.insert(list, val, item)
                            
                            SaveCharacterConfig()
                            this:ClearFocus()
                            frame.ApplyVisibility()
                            RefreshList()
                        else
                            -- Reset invalid input
                            this:SetText(data.index)
                            this:ClearFocus()
                        end
                    end)
                    
                    -- 添加失去焦点事件处理
                    row.editBox:SetScript("OnEditFocusLost", function()
                        local val = tonumber(this:GetText())
                        if val and val >= 1 and val <= data.max and val ~= data.index then
                            local list = (data.list == "left") and config.OrderLeft or config.OrderRight
                            local item = list[data.index]
                            table.remove(list, data.index)
                            table.insert(list, val, item)
                            
                            SaveCharacterConfig()
                            frame.ApplyVisibility()
                            RefreshList()
                        else
                            -- Reset invalid input
                            this:SetText(data.index)
                        end
                    end)
                    
                    row.editBox:SetScript("OnEscapePressed", function()
                        this:SetText(data.index)
                        this:ClearFocus()
                    end)
                end
            end
            
            yOffset = yOffset - 25
        end
        
        -- Hide unused rows
        for k = table.getn(displayList) + 1, table.getn(optionsContent.rows) do
            optionsContent.rows[k]:Hide()
        end
    end

    optionsFrame:SetScript("OnShow", RefreshList)
    RefreshList() -- Initial draw
	
	-- 暴露RefreshList函数给全局，以便其他函数调用
    optionsFrame.RefreshList = RefreshList
    
    return optionsFrame
end

-- Slash Command Handler
SLASH_DIMINFO1 = "/dim"
SLASH_DIMINFO2 = "/diminfo"
SlashCmdList["DIMINFO"] = function(msg)
    local opts = CreateOptionsFrame()
    if opts:IsVisible() then
        opts:Hide()
    else
        opts:Show()
    end
end

-- 右键点击打开设置 
frame:EnableMouse(true)
frame:SetScript("OnMouseDown", function()
    if arg1 == "RightButton" then
        local opts = CreateOptionsFrame()
        if opts:IsVisible() then
            opts:Hide()
        else
            opts:Show()
        end
    end
end)

-- 延迟初始化以等待 SavedVariables
local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("VARIABLES_LOADED")
eventHandler:SetScript("OnEvent", function()
    -- 确保全局配置表存在
    if not DimInfo_Config then
        DimInfo_Config = {}
    end
    
    -- 获取当前角色配置（会自动创建默认配置）
    local config = GetCharacterConfig()
    
    -- 应用保存的位置
    frame.UpdatePosition(config.x or 0)
    
    -- 应用模块间距
    frame.UpdateSpacing(config.spacing or 20)
    
    -- 应用字体大小
    frame.UpdateFontSize(config.FontSize or 14)
        
    -- 应用模块可见性
    frame.ApplyVisibility()
    
    -- 再次更新字体大小，确保所有模块（包括金币模块）都应用了正确的字体大小
    UpdateAllModulesFontSize()
    
    -- 刷新时间显示
    if DimInfo_Time_UpdateDisplay then
        DimInfo_Time_UpdateDisplay()
    end
end)