-- 定义一个全局变量来存储动作栏框架
local MyCustomActionBar = nil
local isActionBarDisplayed = false

-- 创建动作栏框架的函数
local function CreateCustomActionBar()
    -- 如果动作栏已经存在，则直接返回
    if MyCustomActionBar then return end

    -- 创建一个新的动作栏框架
    MyCustomActionBar = CreateFrame("Frame", "MyCustomActionBar", UIParent)
    MyCustomActionBar:SetHeight(36)
    MyCustomActionBar:SetWidth(36)
    MyCustomActionBar:SetPoint("CENTER", 0, 0) -- 初始位置在屏幕中心
    MyCustomActionBar:Hide()
    
    -- 创建一个动作按钮
    local button = CreateFrame("CheckButton", "MyCustomActionBarButton", MyCustomActionBar, "ActionBarButtonTemplate")
    button:SetPoint("CENTER", MyCustomActionBar, "CENTER", 0, 0)
    button:SetID(111) -- 设置按钮的ID为111

    -- 将炉石放入按钮中
    local function FindHearthstoneLocation()
        -- 遍历所有背包
        for bag = 0, 4 do -- 0 表示主背包，1-4 表示其他背包
            for slot = 1, GetContainerNumSlots(bag) do -- 遍历背包中的每个槽位
                local itemLink = GetContainerItemLink(bag, slot) -- 获取槽位中的物品链接
                if itemLink then -- 如果槽位中有物品
                    local itemID = tonumber(string.match(itemLink, "item:(%d+)")) -- 提取物品ID
                    if itemID == 6948 then -- 6948 是炉石的物品ID
                        return bag, slot -- 返回背包编号和槽位编号
                    end
                end
            end
        end
        return nil, nil -- 如果没有找到炉石，返回 nil
    end

    local bag, slot = FindHearthstoneLocation()
    if slot then
        PickupContainerItem(bag, slot) -- 捡起炉石
        PlaceAction(button:GetID()) -- 将炉石放入按钮中
        ClearCursor() -- 清除光标
    end

    -- 注册事件，更新按钮的显示
    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        if GameTooltip:SetAction(this:GetID()) then
            this.updateTooltip = TOOLTIP_UPDATE_TIME;
        else
            this.updateTooltip = nil;
        end
    end)
    button:SetScript("OnLeave", function()
        this.updateTooltip = nil;
        GameTooltip:Hide();
    end)
end

-- 显示动作栏在鼠标位置
local function ShowActionBarAtCursor()
    if not MyCustomActionBar then return end

    -- 如果动作栏已经显示，则不更新位置
    if isActionBarDisplayed then
        return
    end

    -- 获取鼠标位置
    local x, y = GetCursorPosition()
    local scale = UIParent:GetScale()
    if x and y then
        x, y = x / scale, y / scale
        -- 设置动作栏位置到鼠标位置
        MyCustomActionBar:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    else
        -- 如果为获取到鼠标位置，直接显示在中间
        MyCustomActionBar:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end

    MyCustomActionBar:Show()

    -- 设置动作栏已显示的标志
    isActionBarDisplayed = true
end

-- 隐藏动作栏并重置标志
local function HideActionBar()
    if MyCustomActionBar then
        MyCustomActionBar:Hide()
        isActionBarDisplayed = false
    end
end

-- 初始化炉石模块
function WorldBuffsTracker_Initialize()
    CreateCustomActionBar()
end

-- 显示动作栏
function WorldBuffsTracker_ShowActionBar()
    ShowActionBarAtCursor()
end

-- 隐藏动作栏
function WorldBuffsTracker_HideActionBar()
    HideActionBar()
end

