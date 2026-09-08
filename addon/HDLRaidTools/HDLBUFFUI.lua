

HDLUIBuffListDefault = {
    ["Fortitude"] = {
        ["Nums"] = 0,
        ["Names"] = {},
        [1] = "",
        [2] = "",
        [3] = "",
        [4] = "",
        [5] = "",
        [6] = "",
        [7] = "",
        [8] = "",
    },
    ["Intellect"] = {
        ["Nums"] = 0,
        ["Names"] = {},
        [1] = "",
        [2] = "",
        [3] = "",
        [4] = "",
        [5] = "",
        [6] = "",
        [7] = "",
        [8] = "",
    },
    ["WildMark"] = {
        ["Nums"] = 0,
        ["Names"] = {},
        [1] = "",
        [2] = "",
        [3] = "",
        [4] = "",
        [5] = "",
        [6] = "",
        [7] = "",
        [8] = "",
    },
    ["Curse"] = {
        ["Nums"] = 0,
        ["Names"] = {},
        [1] = "",
        [2] = "",
        [3] = "",
        [4] = "",
    },
    ["Tank"] = {
        ["Nums"] = 0,
        ["Names"] = {},
        [1] = "",
        [2] = "",
        [3] = "",
        [4] = "",
    },
    ["Blessing"] = {
        ["Nums"] = 0,
        ["Names"] = {},
        ["paladinBlessing"] = {}
    }
}

HDLUIBuffList =HDLUIBuffList or {
    ["Fortitude"] = {
        ["Nums"] = 0,
        ["Names"] = {},
        [1] = "",
        [2] = "",
        [3] = "",
        [4] = "",
        [5] = "",
        [6] = "",
        [7] = "",
        [8] = "",
    },
    ["Intellect"] = {
        ["Nums"] = 0,
        ["Names"] = {},
        [1] = "",
        [2] = "",
        [3] = "",
        [4] = "",
        [5] = "",
        [6] = "",
        [7] = "",
        [8] = "",
    },
    ["WildMark"] = {
        ["Nums"] = 0,
        ["Names"] = {},
        [1] = "",
        [2] = "",
        [3] = "",
        [4] = "",
        [5] = "",
        [6] = "",
        [7] = "",
        [8] = "",
    },
    ["Curse"] = {
        ["Nums"] = 0,
        ["Names"] = {},
        [1] = "",
        [2] = "",
        [3] = "",
        [4] = "",
    },
    ["Tank"] = {
        ["Nums"] = 0,
        ["Names"] = {},
        [1] = "",
        [2] = "",
        [3] = "",
        [4] = "",
    },
    ["Blessing"] = {
        ["Nums"] = 0,
        ["Names"] = {},
        ["paladinBlessing"] = {}
    }
}

--密语检查，默认关闭
HDLUI.CHATREGISTED = false

HDL_BlessingIcon = {};
HDL_BlessingIcon[0] = "";
HDL_BlessingIcon[1] = "Interface\\Icons\\Spell_Holy_GreaterBlessingofWisdom";
HDL_BlessingIcon[2] = "Interface\\Icons\\Spell_Holy_GreaterBlessingofKings";
HDL_BlessingIcon[3] = "Interface\\Icons\\Spell_Holy_GreaterBlessingofSalvation";
HDL_BlessingIcon[4] = "Interface\\Icons\\Spell_Holy_GreaterBlessingofLight";
HDL_BlessingIcon[5] = "Interface\\Icons\\Spell_Magic_GreaterBlessingofKings";
HDL_BlessingIcon[6] = "Interface\\Icons\\Spell_Holy_GreaterBlessingofSanctuary";

HDL_BuffIcon = {};
--filler?
HDL_BuffIcon[-1] = "Interface\\Icons\\Ability_Stealth"
--greater blessings
HDL_BuffIcon[1] = "Interface\\Icons\\Spell_Holy_GreaterBlessingofWisdom"
HDL_BuffIcon[2] = "Interface\\Icons\\Spell_Holy_GreaterBlessingofKings"
HDL_BuffIcon[3] = "Interface\\Icons\\Spell_Holy_GreaterBlessingofSalvation"
HDL_BuffIcon[4] = "Interface\\Icons\\Spell_Holy_GreaterBlessingofLight"
HDL_BuffIcon[5] = "Interface\\Icons\\Spell_Magic_GreaterBlessingofKings"
HDL_BuffIcon[6] = "Interface\\Icons\\Spell_Holy_GreaterBlessingofSanctuary"
--lesser blessings
HDL_BuffIcon[7] = "Interface\\Icons\\Spell_Holy_SealOfWisdom";
HDL_BuffIcon[8] = "Interface\\Icons\\Spell_Holy_FistOfJustice";
HDL_BuffIcon[9] = "Interface\\Icons\\Spell_Holy_SealOfSalvation";
HDL_BuffIcon[10] = "Interface\\Icons\\Spell_Holy_PrayerOfHealing02";
HDL_BuffIcon[11] = "Interface\\Icons\\Spell_Magic_MageArmor";
HDL_BuffIcon[12] = "Interface\\Icons\\Spell_Nature_LightningShield";

HDL_ClassTexture  = { };
HDL_ClassTexture [1] = "Interface\\AddOns\\HDLRaidTools\\Icons\\Warrior";
HDL_ClassTexture [2] = "Interface\\AddOns\\HDLRaidTools\\Icons\\Rogue";
HDL_ClassTexture [3] = "Interface\\AddOns\\HDLRaidTools\\Icons\\Priest";
HDL_ClassTexture [4] = "Interface\\AddOns\\HDLRaidTools\\Icons\\Druid";
HDL_ClassTexture [5] = "Interface\\AddOns\\HDLRaidTools\\Icons\\Paladin";
HDL_ClassTexture [6] = "Interface\\AddOns\\HDLRaidTools\\Icons\\Hunter";
HDL_ClassTexture [7] = "Interface\\AddOns\\HDLRaidTools\\Icons\\Mage";
HDL_ClassTexture [8] = "Interface\\AddOns\\HDLRaidTools\\Icons\\Warlock";
HDL_ClassTexture [9] = "Interface\\AddOns\\HDLRaidTools\\Icons\\Shaman";

--------------------------------------------
---minimapbutton
--------------------------------------------
-- 定义RestoreMinimapButtonPosition函数
function RestoreMinimapButtonPosition()
    -- 实现位置恢复逻辑（如果需要）
    -- 例如：从saved variables加载位置
    if HDLUI.MinimapPosX and HDLUI.MinimapPosY then
        HDLUI.MiniMapButtonFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", HDLUI.MinimapPosX, HDLUI.MinimapPosY)
    end
end

HDLUI.MiniMapButtonFrame = CreateFrame("Button", "HDLUIMiniMapButtonFrame", Minimap)
HDLUI.MiniMapButtonFrame:SetPoint("TOPLEFT", Minimap, "LEFT", 2, 0)
HDLUI.MiniMapButtonFrame:EnableMouse(true)
HDLUI.MiniMapButtonFrame:SetMovable(true)
HDLUI.MiniMapButtonFrame:SetToplevel(true)
HDLUI.MiniMapButtonFrame:SetWidth(33)
HDLUI.MiniMapButtonFrame:SetHeight(33)

-- 图标纹理
HDLUI.MiniMapButtonFrame.iconTexture = HDLUI.MiniMapButtonFrame:CreateTexture(nil, "BACKGROUND")
HDLUI.MiniMapButtonFrame.iconTexture:SetTexture("Interface\\AddOns\\HDLRaidTools\\HDLRaidTools")
HDLUI.MiniMapButtonFrame.iconTexture:SetWidth(22)
HDLUI.MiniMapButtonFrame.iconTexture:SetHeight(22)
HDLUI.MiniMapButtonFrame.iconTexture:SetPoint("TOPLEFT", HDLUI.MiniMapButtonFrame, "TOPLEFT", 5.6, -4.8)

-- 边框材质
HDLUI.MiniMapButtonFrame.borderTexture = HDLUI.MiniMapButtonFrame:CreateTexture(nil, "OVERLAY")
HDLUI.MiniMapButtonFrame.borderTexture:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
HDLUI.MiniMapButtonFrame.borderTexture:SetWidth(56)
HDLUI.MiniMapButtonFrame.borderTexture:SetHeight(56)
HDLUI.MiniMapButtonFrame.borderTexture:SetPoint("TOPLEFT", HDLUI.MiniMapButtonFrame, "TOPLEFT")

-- 高亮材质
HDLUI.MiniMapButtonFrame.hltexture = HDLUI.MiniMapButtonFrame:SetHighlightTexture(
  "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")

-- 注册左键和右键点击事件（关键：确保右键能触发OnClick）
HDLUI.MiniMapButtonFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

-- 点击事件处理 - 左键和右键均切换设置界面的显示/隐藏状态
HDLUI.MiniMapButtonFrame:SetScript("OnClick", function(self, button)
    -- 无论左键还是右键，均执行相同逻辑
    if HDLUI.IsRaidLeader() then
        HDLUI.Load()
        -- 检查设置窗口当前状态并切换
        if HDLUI.BuffWindow:IsShown() then
            HDLUI.BuffWindow:Hide()
        else
            HDLUI.BuffWindow:Show()
        end
    else
        print("只有团队领袖和团队助理可以使用此功能")
    end
end)

-- 鼠标悬停事件
HDLUI.MiniMapButtonFrame:SetScript("OnEnter", function()
    if not GameTooltip then return end
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:SetText("团队BUFF助手")
    GameTooltip:Show()
end)

HDLUI.MiniMapButtonFrame:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- 拖动移动功能
HDLUI.MiniMapButtonFrame:RegisterForDrag("LeftButton")
HDLUI.MiniMapButtonFrame:SetScript("OnDragStart", function()
    HDLUI.MiniMapButtonFrame:StartMoving()
    HDLUI.MiniMapButtonFrame.isMoving = true
end)

HDLUI.MiniMapButtonFrame:SetScript("OnDragStop", function()
    HDLUI.MiniMapButtonFrame:StopMovingOrSizing()
    HDLUI.MiniMapButtonFrame.isMoving = false
    
    -- 保存位置（如果需要）
    -- local x, y = HDLUI.MiniMapButtonFrame:GetCenter()
    -- local minimapX, minimapY = Minimap:GetCenter()
    -- HDLUI.MinimapPosX = x - minimapX
    -- HDLUI.MinimapPosY = y - minimapY
end)

HDLUI.MiniMapButtonFrame:Show()
RestoreMinimapButtonPosition()  -- 恢复按钮位置
--------------------------------------------
---主背景
--------------------------------------------

---主框架
local mainbackdrop = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 20,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

local ParentSettings = {
    Width = 660,
    Height = 520
}
HDLUI.BuffWindow = CreateFrame("Frame", "HDLUIBuffMainWindow", UIParent)
HDLUI.BuffWindow:SetFrameStrata("MEDIUM")
HDLUI.BuffWindow:SetWidth(ParentSettings.Width)
HDLUI.BuffWindow:SetHeight(ParentSettings.Height)
HDLUI.BuffWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
HDLUI.BuffWindow:SetBackdrop(mainbackdrop)
HDLUI.BuffWindow:SetBackdropColor(.2,.2,.2,1)
HDLUI.BuffWindow:SetBackdropBorderColor(.4,.4,.4,1)
HDLUI.BuffWindow:EnableMouse(true)
HDLUI.BuffWindow:SetMovable(true)
HDLUI.BuffWindow:RegisterForDrag("LeftButton")
HDLUI.BuffWindow:SetScript("OnDragStart", function() HDLUI.BuffWindow:StartMoving() end)
HDLUI.BuffWindow:SetScript("OnDragStop", function() HDLUI.BuffWindow:StopMovingOrSizing() end)
HDLUI.BuffWindow:Show()
--HDLUI.BuffWindow的位置移动到屏幕中心
HDLUI.BuffWindow:ClearAllPoints()
HDLUI.BuffWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
HDLUI.BuffWindow:Hide()


--标题背景及文字
HDLUI.BuffWindow.Title = HDLUI.BuffWindow:CreateTexture("HDLUIBuffMainWindowHeader", "ARTWORK")
HDLUI.BuffWindow.Title:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header") -- 设置纹理文件
HDLUI.BuffWindow.Title:SetWidth(400) -- 设置宽度
HDLUI.BuffWindow.Title:SetHeight(64) -- 设置高度
HDLUI.BuffWindow.Title:SetPoint("TOP", HDLUI.BuffWindow, "TOP", 0, 12)
HDLUI.BuffWindow.Title:Show()
HDLUI.BuffWindow.Title.Text = HDLUI.BuffWindow:CreateFontString(nil, "OVERLAY")
HDLUI.BuffWindow.Title.Text:SetFont(STANDARD_TEXT_FONT, 16)
HDLUI.BuffWindow.Title.Text:SetPoint("CENTER", HDLUI.BuffWindow.Title, "CENTER", 0, 11)
HDLUI.BuffWindow.Title.Text:SetText("团队|cff33e6b3BUFF|r助手")

HDLUI.BuffWindow.Title.TextAuther = HDLUI.BuffWindow:CreateFontString(nil, "OVERLAY")
HDLUI.BuffWindow.Title.TextAuther:SetFont(STANDARD_TEXT_FONT, 9)
HDLUI.BuffWindow.Title.TextAuther:SetTextColor(.1,.1,.1)
HDLUI.BuffWindow.Title.TextAuther:SetPoint("BOTTOMRIGHT", HDLUI.BuffWindow, "BOTTOMRIGHT", -24, 11)
HDLUI.BuffWindow.Title.TextAuther:SetText("By:卡拉赞-魂斗罗工会")
--------------------------------------------
---耐力
--------------------------------------------

local FortitudeBackDrop = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 20,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

local FortitudeSettings = {
    Width = 200,
    Height = 260
}

--真言术：韧
HDLUI.BuffWindow.Fortitude = CreateFrame("Frame", "HDLUIBuffWindowFortitude", HDLUI.BuffWindow)
HDLUI.BuffWindow.Fortitude:SetFrameStrata("MEDIUM")
HDLUI.BuffWindow.Fortitude:SetWidth(FortitudeSettings.Width)
HDLUI.BuffWindow.Fortitude:SetHeight(FortitudeSettings.Height)
HDLUI.BuffWindow.Fortitude:SetPoint("TOPLEFT", HDLUI.BuffWindow, "TOPLEFT", 20, -60)
HDLUI.BuffWindow.Fortitude:SetBackdrop(FortitudeBackDrop)
HDLUI.BuffWindow.Fortitude:SetBackdropColor(.2,.2,.2,1)
HDLUI.BuffWindow.Fortitude:SetBackdropBorderColor(.4,.4,.4,1)

-- 创建并设置HDLUI.BuffWindow.Fortitude.Text的位置和样式
HDLUI.BuffWindow.Fortitude.Text = HDLUI.BuffWindow.Fortitude:CreateFontString(nil, "OVERLAY")
HDLUI.BuffWindow.Fortitude.Text:SetFont(GameFontNormal:GetFont(), 16) -- 设置字体、大小和轮廓效果
HDLUI.BuffWindow.Fortitude.Text:SetText("真言术：韧") -- 设置显示文本
HDLUI.BuffWindow.Fortitude.Text:SetJustifyH("CENTER") -- 水平居中对齐
HDLUI.BuffWindow.Fortitude.Text:SetPoint("BOTTOM", HDLUI.BuffWindow.Fortitude, "TOP", 0, 5)
HDLUI.BuffWindow.Fortitude.Text:SetTextColor(0.2, 0.9, 0.7)

for i = 1, 8 do
    HDLUI.BuffWindow.Fortitude["Text"..i]  = HDLUI.BuffWindow.Fortitude:CreateFontString(nil, "OVERLAY") 
    HDLUI.BuffWindow.Fortitude["Text"..i] :SetFont(GameFontNormal:GetFont(), 14)
    HDLUI.BuffWindow.Fortitude["Text"..i] :SetText(i.."队")
    HDLUI.BuffWindow.Fortitude["Text"..i] :SetJustifyH("CENTER")
    HDLUI.BuffWindow.Fortitude["Text"..i] :SetPoint("TOPLEFT", HDLUI.BuffWindow.Fortitude, "TOPLEFT", 15, -15-((i-1)*30))
end

---下拉菜单

-- 初始化下拉菜单内容
local function InitializeDropDown(dropDownMenu)
    local menuName = dropDownMenu:GetName()
    local lastChar = string.sub(menuName, -1) -- 获取最后一个字符
    local numberFromChar = tonumber(lastChar) -- 尝试将字符转换为数字

    -- 添加 <空> 选项
    do
        local info = {
            text = "<空>",
            value = "",
            func = function()
                UIDropDownMenu_SetText("<空>", dropDownMenu)
                CloseDropDownMenus()
                HDLUIBuffList["Fortitude"][numberFromChar] = ""
            end,
            checked = nil,
        }
        UIDropDownMenu_AddButton(info)
    end

    local num,namelist = HDLUI.GetClassN("牧师")

    local num,namelist = HDLUI.GetClassN("牧师")
    -- 检查 namelist 是否有效
    if not namelist then
        local namelist = {} -- 如果获取失败，提供一个默认的空表
    end

    for i, value in ipairs(namelist) do
        (function(optionText, optionValue)
            local info = {
                text = optionText,
                value = optionValue,
                func = function()
                    UIDropDownMenu_SetText(optionText, dropDownMenu)
                    CloseDropDownMenus()
                    HDLUIBuffList["Fortitude"][numberFromChar] = optionText
                end,
                checked = nil,
            }
            UIDropDownMenu_AddButton(info)
        end)(tostring(value), value)
    end
end

-- 创建并初始化8个下拉菜单
for i = 1, 8 do
    -- 动态创建唯一的变量名，用于存储每个下拉菜单对象
    HDLUI.BuffWindow["Fortitude"..i] = CreateFrame("Button", "HDLUIBuffWindowFortitude"..i, HDLUI.BuffWindow.Fortitude, "UIDropDownMenuTemplate")
    HDLUI.BuffWindow["Fortitude"..i]:SetPoint("TOPLEFT", HDLUI.BuffWindow.Fortitude, "TOPLEFT", 35, -10-((i-1)*30))
    UIDropDownMenu_JustifyText("CENTER", HDLUI.BuffWindow["Fortitude"..i])
    UIDropDownMenu_SetText("<空>", HDLUI.BuffWindow["Fortitude"..i])

    -- 使用立即执行函数表达式(IIFE)确保每个下拉菜单都绑定到自己的初始化函数
    local function initializeDropdown(dropdown)
        UIDropDownMenu_Initialize(dropdown, function()
            InitializeDropDown(dropdown)
        end)
    end
    
    initializeDropdown(HDLUI.BuffWindow["Fortitude" .. i])
end

--------------------------------------------
---智力
--------------------------------------------

local IntellectBackDrop = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 20,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

local IntellectSettings = {
    Width = 200,
    Height = 260
}

--智力
HDLUI.BuffWindow.Intellect = CreateFrame("Frame", "HDLUIBuffWindowIntellect", HDLUI.BuffWindow)
HDLUI.BuffWindow.Intellect:SetFrameStrata("MEDIUM")
HDLUI.BuffWindow.Intellect:SetWidth(IntellectSettings.Width)
HDLUI.BuffWindow.Intellect:SetHeight(IntellectSettings.Height)
HDLUI.BuffWindow.Intellect:SetPoint("TOPLEFT", HDLUI.BuffWindow, "TOPLEFT", 230, -60)
HDLUI.BuffWindow.Intellect:SetBackdrop(IntellectBackDrop)
HDLUI.BuffWindow.Intellect:SetBackdropColor(.2,.2,.2,1)
HDLUI.BuffWindow.Intellect:SetBackdropBorderColor(.4,.4,.4,1)

-- 创建并设置HDLUI.BuffWindow.Intellect.Text的位置和样式
HDLUI.BuffWindow.Intellect.Text = HDLUI.BuffWindow.Intellect:CreateFontString(nil, "OVERLAY")
HDLUI.BuffWindow.Intellect.Text:SetFont(GameFontNormal:GetFont(), 16) -- 设置字体、大小和轮廓效果
HDLUI.BuffWindow.Intellect.Text:SetText("奥术智慧") -- 设置显示文本
HDLUI.BuffWindow.Intellect.Text:SetJustifyH("CENTER") -- 水平居中对齐
HDLUI.BuffWindow.Intellect.Text:SetPoint("BOTTOM", HDLUI.BuffWindow.Intellect, "TOP", 0, 5)
HDLUI.BuffWindow.Intellect.Text:SetTextColor(0.2, 0.9, 0.7)

for i = 1, 8 do
    HDLUI.BuffWindow.Intellect["Text"..i]  = HDLUI.BuffWindow.Intellect:CreateFontString(nil, "OVERLAY") 
    HDLUI.BuffWindow.Intellect["Text"..i] :SetFont(GameFontNormal:GetFont(), 14)
    HDLUI.BuffWindow.Intellect["Text"..i] :SetText(i.."队")
    HDLUI.BuffWindow.Intellect["Text"..i] :SetJustifyH("CENTER")
    HDLUI.BuffWindow.Intellect["Text"..i] :SetPoint("TOPLEFT", HDLUI.BuffWindow.Intellect, "TOPLEFT", 15, -15-((i-1)*30))
end

---下拉菜单

-- 初始化下拉菜单内容
local function InitializeDropDown(dropDownMenu)
    local menuName = dropDownMenu:GetName()
    local lastChar = string.sub(menuName, -1) -- 获取最后一个字符
    local numberFromChar = tonumber(lastChar) -- 尝试将字符转换为数字

    -- 添加 <空> 选项
    do
        local info = {
            text = "<空>",
            value = "",
            func = function()
                UIDropDownMenu_SetText("<空>", dropDownMenu)
                CloseDropDownMenus()
                HDLUIBuffList["Intellect"][numberFromChar] = ""
            end,
            checked = nil,
        }
        UIDropDownMenu_AddButton(info)
    end

    local num,namelist = HDLUI.GetClassN("法师")
    -- 检查 namelist 是否有效
    if not namelist then
        namelist = {} -- 如果获取失败，提供一个默认的空表
    end

    for i, value in ipairs(namelist) do
        (function(optionText, optionValue)
            local info = {
                text = optionText,
                value = optionValue,
                func = function()
                    UIDropDownMenu_SetText(optionText, dropDownMenu)
                    CloseDropDownMenus()
                    HDLUIBuffList["Intellect"][numberFromChar] = optionText
                end,
                checked = nil,
            }
            UIDropDownMenu_AddButton(info)
        end)(tostring(value), value)
    end
end

-- 创建并初始化8个下拉菜单
for i = 1, 8 do
    -- 动态创建唯一的变量名，用于存储每个下拉菜单对象
    HDLUI.BuffWindow["Intellect"..i] = CreateFrame("Button", "HDLUIBuffWindowIntellect"..i, HDLUI.BuffWindow.Intellect, "UIDropDownMenuTemplate")
    HDLUI.BuffWindow["Intellect"..i]:SetPoint("TOPLEFT", HDLUI.BuffWindow.Intellect, "TOPLEFT", 35, -10-((i-1)*30))
    UIDropDownMenu_JustifyText("CENTER", HDLUI.BuffWindow["Intellect"..i])
    UIDropDownMenu_SetText("<空>", HDLUI.BuffWindow["Intellect"..i])

    -- 使用立即执行函数表达式(IIFE)确保每个下拉菜单都绑定到自己的初始化函数
    local function initializeDropdown(dropdown)
        UIDropDownMenu_Initialize(dropdown, function()
            InitializeDropDown(dropdown)
        end)
    end
    
    initializeDropdown(HDLUI.BuffWindow["Intellect" .. i])
end


--------------------------------------------
---爪子
--------------------------------------------

local WildMarkBackDrop = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 20,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

local WildMarkSettings = {
    Width = 200,
    Height = 260
}

--爪子
HDLUI.BuffWindow.WildMark = CreateFrame("Frame", "HDLUIBuffWindowWildMark", HDLUI.BuffWindow)
HDLUI.BuffWindow.WildMark:SetFrameStrata("MEDIUM")
HDLUI.BuffWindow.WildMark:SetWidth(WildMarkSettings.Width)
HDLUI.BuffWindow.WildMark:SetHeight(WildMarkSettings.Height)
HDLUI.BuffWindow.WildMark:SetPoint("TOPLEFT", HDLUI.BuffWindow, "TOPLEFT", 440, -60)
HDLUI.BuffWindow.WildMark:SetBackdrop(WildMarkBackDrop)
HDLUI.BuffWindow.WildMark:SetBackdropColor(.2,.2,.2,1)
HDLUI.BuffWindow.WildMark:SetBackdropBorderColor(.4,.4,.4,1)

-- 创建并设置HDLUI.BuffWindow.WildMark.Text的位置和样式
HDLUI.BuffWindow.WildMark.Text = HDLUI.BuffWindow.WildMark:CreateFontString(nil, "OVERLAY")
HDLUI.BuffWindow.WildMark.Text:SetFont(GameFontNormal:GetFont(), 16) -- 设置字体、大小和轮廓效果
HDLUI.BuffWindow.WildMark.Text:SetText("野性印记") -- 设置显示文本
HDLUI.BuffWindow.WildMark.Text:SetJustifyH("CENTER") -- 水平居中对齐
HDLUI.BuffWindow.WildMark.Text:SetPoint("BOTTOM", HDLUI.BuffWindow.WildMark, "TOP", 0, 5)
HDLUI.BuffWindow.WildMark.Text:SetTextColor(0.2, 0.9, 0.7)

for i = 1, 8 do
    HDLUI.BuffWindow.WildMark["Text"..i]  = HDLUI.BuffWindow.WildMark:CreateFontString(nil, "OVERLAY") 
    HDLUI.BuffWindow.WildMark["Text"..i] :SetFont(GameFontNormal:GetFont(), 14)
    HDLUI.BuffWindow.WildMark["Text"..i] :SetText(i.."队")
    HDLUI.BuffWindow.WildMark["Text"..i] :SetJustifyH("CENTER")
    HDLUI.BuffWindow.WildMark["Text"..i] :SetPoint("TOPLEFT", HDLUI.BuffWindow.WildMark, "TOPLEFT", 15, -15-((i-1)*30))
end

---下拉菜单

-- 初始化下拉菜单内容
local function InitializeDropDown(dropDownMenu)
    local menuName = dropDownMenu:GetName()
    local lastChar = string.sub(menuName, -1) -- 获取最后一个字符
    local numberFromChar = tonumber(lastChar) -- 尝试将字符转换为数字

    -- 添加 <空> 选项
    do
        local info = {
            text = "<空>",
            value = "",
            func = function()
                UIDropDownMenu_SetText("<空>", dropDownMenu)
                CloseDropDownMenus()
                HDLUIBuffList["WildMark"][numberFromChar] = ""
            end,
            checked = nil,
        }
        UIDropDownMenu_AddButton(info)
    end

    local num,namelist = HDLUI.GetClassN("德鲁伊")
    -- 检查 namelist 是否有效
    if not namelist then
        namelist = {} -- 如果获取失败，提供一个默认的空表
    end

    for i, value in ipairs(namelist) do
        (function(optionText, optionValue)
            local info = {
                text = optionText,
                value = optionValue,
                func = function()
                    UIDropDownMenu_SetText(optionText, dropDownMenu)
                    CloseDropDownMenus()
                    HDLUIBuffList["WildMark"][numberFromChar] = optionText
                end,
                checked = nil,
            }
            UIDropDownMenu_AddButton(info)
        end)(tostring(value), value)
    end
end

-- 创建并初始化8个下拉菜单
for i = 1, 8 do
    -- 动态创建唯一的变量名，用于存储每个下拉菜单对象
    HDLUI.BuffWindow["WildMark"..i] = CreateFrame("Button", "HDLUIBuffWindowWildMark"..i, HDLUI.BuffWindow.WildMark, "UIDropDownMenuTemplate")
    HDLUI.BuffWindow["WildMark"..i]:SetPoint("TOPLEFT", HDLUI.BuffWindow.WildMark, "TOPLEFT", 35, -10-((i-1)*30))
    UIDropDownMenu_JustifyText("CENTER", HDLUI.BuffWindow["WildMark"..i])
    UIDropDownMenu_SetText("<空>", HDLUI.BuffWindow["WildMark"..i])

    -- 使用立即执行函数表达式(IIFE)确保每个下拉菜单都绑定到自己的初始化函数
    local function initializeDropdown(dropdown)
        UIDropDownMenu_Initialize(dropdown, function()
            InitializeDropDown(dropdown)
        end)
    end
    
    initializeDropdown(HDLUI.BuffWindow["WildMark" .. i])
end

--------------------------------------------
---诅咒
--------------------------------------------

local CurseBackDrop = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 20,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

local CurseSettings = {
    Width = 200,
    Height = 140
}

--真言术：韧
HDLUI.BuffWindow.Curse = CreateFrame("Frame", "HDLUIBuffWindowCurse", HDLUI.BuffWindow)
HDLUI.BuffWindow.Curse:SetFrameStrata("MEDIUM")
HDLUI.BuffWindow.Curse:SetWidth(CurseSettings.Width)
HDLUI.BuffWindow.Curse:SetHeight(CurseSettings.Height)
HDLUI.BuffWindow.Curse:SetPoint("TOPLEFT", HDLUI.BuffWindow, "TOPLEFT", 20, -350)
HDLUI.BuffWindow.Curse:SetBackdrop(CurseBackDrop)
HDLUI.BuffWindow.Curse:SetBackdropColor(.2,.2,.2,1)
HDLUI.BuffWindow.Curse:SetBackdropBorderColor(.4,.4,.4,1)

-- 创建并设置HDLUI.BuffWindow.Curse.Text的位置和样式
HDLUI.BuffWindow.Curse.Text = HDLUI.BuffWindow.Curse:CreateFontString(nil, "OVERLAY")
HDLUI.BuffWindow.Curse.Text:SetFont(GameFontNormal:GetFont(), 16) -- 设置字体、大小和轮廓效果
HDLUI.BuffWindow.Curse.Text:SetText("诅咒") -- 设置显示文本
HDLUI.BuffWindow.Curse.Text:SetJustifyH("CENTER") -- 水平居中对齐
HDLUI.BuffWindow.Curse.Text:SetPoint("BOTTOM", HDLUI.BuffWindow.Curse, "TOP", 0, 5)
HDLUI.BuffWindow.Curse.Text:SetTextColor(0.2, 0.9, 0.7)

for i = 1, 4 do
    local CurseList = {"鲁莽","元素","暗影","语言"}
    HDLUI.BuffWindow.Curse["Text"..i]  = HDLUI.BuffWindow.Curse:CreateFontString(nil, "OVERLAY") 
    HDLUI.BuffWindow.Curse["Text"..i] :SetFont(GameFontNormal:GetFont(), 14)
    HDLUI.BuffWindow.Curse["Text"..i] :SetText(CurseList[i])
    HDLUI.BuffWindow.Curse["Text"..i] :SetJustifyH("CENTER")
    HDLUI.BuffWindow.Curse["Text"..i] :SetPoint("TOPLEFT", HDLUI.BuffWindow.Curse, "TOPLEFT", 15, -15-((i-1)*30))
end

---下拉菜单

-- 初始化下拉菜单内容
local function InitializeDropDown(dropDownMenu)
    local menuName = dropDownMenu:GetName()
    local lastChar = string.sub(menuName, -1) -- 获取最后一个字符
    local numberFromChar = tonumber(lastChar) -- 尝试将字符转换为数字

    -- 添加 <空> 选项
    do
        local info = {
            text = "<空>",
            value = "",
            func = function()
                UIDropDownMenu_SetText("<空>", dropDownMenu)
                CloseDropDownMenus()
                HDLUIBuffList["Curse"][numberFromChar] = ""
            end,
            checked = nil,
        }
        UIDropDownMenu_AddButton(info)
    end

    local num,namelist = HDLUI.GetClassN("术士")
    -- 检查 namelist 是否有效
    if not namelist then
        namelist = {} -- 如果获取失败，提供一个默认的空表
    end

    for i, value in ipairs(namelist) do
        (function(optionText, optionValue)
            local info = {
                text = optionText,
                value = optionValue,
                func = function()
                    UIDropDownMenu_SetText(optionText, dropDownMenu)
                    CloseDropDownMenus()
                    HDLUIBuffList["Curse"][numberFromChar] = optionText
                end,
                checked = nil,
            }
            UIDropDownMenu_AddButton(info)
        end)(tostring(value), value)
    end
end

-- 创建并初始化8个下拉菜单
for i = 1, 4 do
    -- 动态创建唯一的变量名，用于存储每个下拉菜单对象
    HDLUI.BuffWindow["Curse"..i] = CreateFrame("Button", "HDLUIBuffWindowCurse"..i, HDLUI.BuffWindow.Curse, "UIDropDownMenuTemplate")
    HDLUI.BuffWindow["Curse"..i]:SetPoint("TOPLEFT", HDLUI.BuffWindow.Curse, "TOPLEFT", 35, -10-((i-1)*30))
    UIDropDownMenu_JustifyText("CENTER", HDLUI.BuffWindow["Curse"..i])
    UIDropDownMenu_SetText("<空>", HDLUI.BuffWindow["Curse"..i])

    -- 使用立即执行函数表达式(IIFE)确保每个下拉菜单都绑定到自己的初始化函数
    local function initializeDropdown(dropdown)
        UIDropDownMenu_Initialize(dropdown, function()
            InitializeDropDown(dropdown)
        end)
    end
    
    initializeDropdown(HDLUI.BuffWindow["Curse" .. i])
end

--------------------------------------------
---坦克
--------------------------------------------

local TankBackDrop = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 20,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

local TankSettings = {
    Width = 200,
    Height = 140
}

--真言术：韧
HDLUI.BuffWindow.Tank = CreateFrame("Frame", "HDLUIBuffWindowTank", HDLUI.BuffWindow)
HDLUI.BuffWindow.Tank:SetFrameStrata("MEDIUM")
HDLUI.BuffWindow.Tank:SetWidth(TankSettings.Width)
HDLUI.BuffWindow.Tank:SetHeight(TankSettings.Height)
HDLUI.BuffWindow.Tank:SetPoint("TOPLEFT", HDLUI.BuffWindow, "TOPLEFT", 230, -350)
HDLUI.BuffWindow.Tank:SetBackdrop(TankBackDrop)
HDLUI.BuffWindow.Tank:SetBackdropColor(.2,.2,.2,1)
HDLUI.BuffWindow.Tank:SetBackdropBorderColor(.4,.4,.4,1)

-- 创建并设置HDLUI.BuffWindow.Tank.Text的位置和样式
HDLUI.BuffWindow.Tank.Text = HDLUI.BuffWindow.Tank:CreateFontString(nil, "OVERLAY")
HDLUI.BuffWindow.Tank.Text:SetFont(GameFontNormal:GetFont(), 16) -- 设置字体、大小和轮廓效果
HDLUI.BuffWindow.Tank.Text:SetText("坦克") -- 设置显示文本
HDLUI.BuffWindow.Tank.Text:SetJustifyH("CENTER") -- 水平居中对齐
HDLUI.BuffWindow.Tank.Text:SetPoint("BOTTOM", HDLUI.BuffWindow.Tank, "TOP", 0, 5)
HDLUI.BuffWindow.Tank.Text:SetTextColor(0.2, 0.9, 0.7)

for i = 1, 4 do
    local TankList = {"MT","2T","3T","4T"}
    HDLUI.BuffWindow.Tank["Text"..i]  = HDLUI.BuffWindow.Tank:CreateFontString(nil, "OVERLAY") 
    HDLUI.BuffWindow.Tank["Text"..i] :SetFont(GameFontNormal:GetFont(), 14)
    HDLUI.BuffWindow.Tank["Text"..i] :SetText(TankList[i])
    HDLUI.BuffWindow.Tank["Text"..i] :SetJustifyH("CENTER")
    HDLUI.BuffWindow.Tank["Text"..i] :SetPoint("TOPLEFT", HDLUI.BuffWindow.Tank, "TOPLEFT", 15, -15-((i-1)*30))
end

---下拉菜单

-- 初始化下拉菜单内容
local function InitializeDropDown(dropDownMenu)
    local menuName = dropDownMenu:GetName()
    local lastChar = string.sub(menuName, -1) -- 获取最后一个字符
    local numberFromChar = tonumber(lastChar) -- 尝试将字符转换为数字

    -- 获取各个职业名称列表
    local num, namelist1 = HDLUI.GetClassN("德鲁伊")
    local num, namelist2 = HDLUI.GetClassN("圣骑士")
    local num, namelist3 = HDLUI.GetClassN("战士")
    local num, namelist4 = HDLUI.GetClassN("萨满祭司")

    -- 添加 <空> 选项
    do
        local info = {
            text = "<空>",
            value = "",
            func = function()
                UIDropDownMenu_SetText("<空>", dropDownMenu)
                CloseDropDownMenus()
                HDLUIBuffList["Tank"][numberFromChar] = ""
            end,
            checked = nil,
        }
        UIDropDownMenu_AddButton(info)
    end

    -- 合并namelist1-3
    local namelist = {}

    -- 定义一个辅助函数来检查表是否为空
    local function isNotEmpty(tbl)
        if tbl == nil then return false end -- 如果是nil直接返回false
        for _, _ in pairs(tbl) do
            return true -- 只要有任何一个元素就返回true
        end
        return false -- 循环完没有找到元素则返回false
    end
    if isNotEmpty(namelist1) then
        for _, value in ipairs(namelist1) do
            table.insert(namelist, value)
        end
    end
    if isNotEmpty(namelist2) then
        for _, value in ipairs(namelist2) do
            table.insert(namelist, value)
        end
    end
    if isNotEmpty(namelist3) then
        for _, value in ipairs(namelist3) do
            table.insert(namelist, value)
        end
    end
    if isNotEmpty(namelist4) then
        for _, value in ipairs(namelist3) do
            table.insert(namelist, value)
        end
    end


    -- 检查 namelist 是否有效
    if not namelist then
        namelist = {} -- 如果获取失败，提供一个默认的空表
    end

    for i, value in ipairs(namelist) do
        (function(optionText, optionValue)
            local info = {
                text = optionText,
                value = optionValue,
                func = function()
                    UIDropDownMenu_SetText(optionText, dropDownMenu)
                    CloseDropDownMenus()
                    HDLUIBuffList["Tank"][numberFromChar] = optionText
                end,
                checked = nil,
            }
            UIDropDownMenu_AddButton(info)
        end)(tostring(value), value)
    end
end

-- 创建并初始化8个下拉菜单
for i = 1, 4 do
    -- 动态创建唯一的变量名，用于存储每个下拉菜单对象
    HDLUI.BuffWindow["Tank"..i] = CreateFrame("Button", "HDLUIBuffWindowTank"..i, HDLUI.BuffWindow.Tank, "UIDropDownMenuTemplate")
    HDLUI.BuffWindow["Tank"..i]:SetPoint("TOPLEFT", HDLUI.BuffWindow.Tank, "TOPLEFT", 35, -10-((i-1)*30))
    UIDropDownMenu_JustifyText("CENTER", HDLUI.BuffWindow["Tank"..i])
    UIDropDownMenu_SetText("<空>", HDLUI.BuffWindow["Tank"..i])

    -- 使用立即执行函数表达式(IIFE)确保每个下拉菜单都绑定到自己的初始化函数
    local function initializeDropdown(dropdown)
        UIDropDownMenu_Initialize(dropdown, function()
            InitializeDropDown(dropdown)
        end)
    end
    
    initializeDropdown(HDLUI.BuffWindow["Tank" .. i])
end

--------------------------------------------
---按钮
--------------------------------------------

-- 先定义 ButtonBackDrop，确保在函数调用前存在
local ButtonBackDrop = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 24,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

local function CreateButton(name, SizeW, SizeH, x, y, text)
    local Button = CreateFrame("Button", name, HDLUI.BuffWindow)
    Button:SetWidth(SizeW)
    Button:SetHeight(SizeH)
    Button:SetFont(STANDARD_TEXT_FONT, 14)
    Button:SetPoint("TOPLEFT", HDLUI.BuffWindow, "TOPLEFT", x, y)    
    Button:SetText(text)
    Button:SetTextColor(0.7, 0.7, 0.7, 1)
    
    if name ~= "CloseButtonMini" then
        -- 设置背景和边框
        Button:SetBackdrop(ButtonBackDrop)
        Button:SetBackdropColor(0.1, 0.1, 0.1, 0) 
        Button:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

        Button:SetScript("OnEnter", function(self)
            Button:SetBackdropBorderColor(0.2, 0.9, 0.7)  -- 边框改为青绿色
            Button:SetTextColor(1, 1, 1)            -- 字体同步变色（可选）
        end)
        -- 鼠标移出时恢复默认颜色
        Button:SetScript("OnLeave", function(self)
            Button:SetBackdropBorderColor(0.4, 0.4, 0.4)  -- 恢复默认边框颜色
            Button:SetTextColor(0.7, 0.7, 0.7, 1)           -- 恢复默认字体颜色
        end)
    end
end

-- 后续循环创建按钮的代码保持不变...
local ButtonName = {"CloseButtonMini", "BlessingButton", "AutoAllocationButton", "TeamNotificationButton", "BuffCheckButton", "AutoResponseButton"}
local SizeW = {15, 200, 100, 100, 100, 100}
local SizeH = {15, 40, 40, 40, 40, 40}
local ButtonText = {"X", "骑士祝福设置", "自动分配", "团队通报", "BUFF检查", "密语监控"}
local ButtonX = {635,  440,  440,  540,  440,  540}
local ButtonY = {-10, -350, -410, -410, -450, -450}

for i = 1, 6 do
    CreateButton(ButtonName[i], SizeW[i], SizeH[i], ButtonX[i], ButtonY[i], ButtonText[i])
end

--为CloseButtonMini设置点击事件，点击后关闭窗口
CloseButtonMini:SetScript("OnClick", function() HDLUI.BuffWindow:Hide() end)
--为BlessingButton设置点击事件，点击后打开骑士祝福设置窗口
BlessingButton:SetScript("OnClick", function() HDLUI.RefreshBlessingFrame();HDLUI.OpenBlessingFrame() end)
--自动分配BUFF
AutoAllocationButton:SetScript("OnClick", function() HDLUI.AutoBuff() end)
--团队通报
TeamNotificationButton:SetScript("OnClick", function() HDLUI.BuffAllocationReport() end)
--BUFF检查
BuffCheckButton:SetScript("OnClick", function() HDLUI.BuffCheckAndReport() end)
--密语自动检查BUFF
AutoResponseButton:SetScript("OnClick",function() HDLUI.AutoResponse() end)



--------------------------------------------
---骑士祝福设置
--------------------------------------------

---1-主框架
local BlessingBackDrop = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 20,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

local BlessingSettings = {
    Width = 540,
    Height = 80
}

HDLUI.BuffWindow.BlessingFrame = CreateFrame("Frame", "HDLUIBuffMainWindowBlessingFrame", HDLUI.BuffWindow)
HDLUI.BuffWindow.BlessingFrame:SetFrameStrata("MEDIUM")
HDLUI.BuffWindow.BlessingFrame:SetWidth(BlessingSettings.Width)
HDLUI.BuffWindow.BlessingFrame:SetHeight(BlessingSettings.Height)
HDLUI.BuffWindow.BlessingFrame:SetPoint("TOPLEFT", HDLUI.BuffWindow, "TOPRIGHT", 0, 0)
HDLUI.BuffWindow.BlessingFrame:SetBackdrop(BlessingBackDrop)
HDLUI.BuffWindow.BlessingFrame:SetBackdropColor(.2,.2,.2,1)
HDLUI.BuffWindow.BlessingFrame:SetBackdropBorderColor(.4,.4,.4,1)
HDLUI.BuffWindow.BlessingFrame:EnableMouse(true)
HDLUI.BuffWindow.BlessingFrame:RegisterForDrag("LeftButton")
HDLUI.BuffWindow.BlessingFrame:SetScript("OnDragStart", function() HDLUI.BuffWindow:StartMoving() end)
HDLUI.BuffWindow.BlessingFrame:SetScript("OnDragStop", function() HDLUI.BuffWindow:StopMovingOrSizing() end)
HDLUI.BuffWindow.BlessingFrame:Hide()


--2-关闭按钮

HDLUI.BuffWindow.BlessingFrame.CloseButton = CreateFrame("Button", "HDLUIBuffWindowBlessingFrameCloseButton", HDLUI.BuffWindow.BlessingFrame)
HDLUI.BuffWindow.BlessingFrame.CloseButton:SetWidth(15)
HDLUI.BuffWindow.BlessingFrame.CloseButton:SetHeight(15)
HDLUI.BuffWindow.BlessingFrame.CloseButton:SetFont(STANDARD_TEXT_FONT, 14)
HDLUI.BuffWindow.BlessingFrame.CloseButton:SetPoint("TOPLEFT", HDLUI.BuffWindow.BlessingFrame, "TOPLEFT", 8, -10)    
HDLUI.BuffWindow.BlessingFrame.CloseButton:SetText("X")
HDLUI.BuffWindow.BlessingFrame.CloseButton:SetTextColor(0.7, 0.7, 0.7, 1)
HDLUI.BuffWindow.BlessingFrame.CloseButton:SetScript("OnClick", function() HDLUI.BuffWindow.BlessingFrame:Hide() end)


--3-职业图标显示

local function CreateClassTexture(i)
    local texture = HDLUI.BuffWindow.BlessingFrame:CreateTexture("HDLUIBuffWindowBlessingFrameClassTexture"..i, "ARTWORK")
    texture:SetPoint("TOPLEFT", HDLUI.BuffWindow.BlessingFrame, "TOPLEFT", 100+((i-1)*48), -30)
    texture:SetTexture(HDL_ClassTexture[i])
    texture:SetWidth(33)  -- 设置尺寸
    texture:SetHeight(33)
end

for i = 1, 9 do
    CreateClassTexture(i)
end


--4-动态生成骑士名字及祝福图标界面

--根据骑士数量PaladinNums和PaladinNames动态生成PaladinNums个没有背景的按钮，按钮点击后出现一个下拉菜单，下拉菜单中的选项为所有骑士的名字。
--背景HDLUI.BuffWindow.BlessingFrame的宽度随名字数量动态改变，增加的宽度为名字数量*70
--名字的位置为SetPoint("TOPLEFT", HDLUI.BuffWindow.BlessingFrame, "TOPLEFT", 75+((i-1)*48, -55))
-- 先定义初始宽度和基础偏移量


-- 创建存储骑士按钮的容器
HDLUI.BuffWindow.BlessingFrame.PaladinButtons = {}

-- 生成骑士按钮的函数
function HDLUI.CreatePaladinButton(index, PaladinNums, PaladinNames)
    HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index] = CreateFrame("Button", "BlessingPaladinButton"..index, HDLUI.BuffWindow.BlessingFrame)

    -- HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetWidth(string.len(PaladinNames[index])*7)
    HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetWidth(90)
    HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetHeight(32)
    HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetPoint("TOPLEFT", HDLUI.BuffWindow.BlessingFrame, "TOPLEFT", 10, -93-((index-1)*53))

    -- 按钮文字
    HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetFont(STANDARD_TEXT_FONT, 10)
    HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetText(PaladinNames[index])
    HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetTextColor(0.2, 0.9, 0.7)

    HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetBackdrop(ButtonBackDrop)
    HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetBackdropColor(0.1, 0.1, 0.1, 0)
    HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetBackdropBorderColor(0.4, 0.4, 0.4, 0)

    HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetScript("OnEnter", function(self)
        HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetBackdropBorderColor(0.2, 0.9, 0.7)  -- 边框改为青绿色
    end)
    -- 鼠标移出时恢复默认颜色
    HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetScript("OnLeave", function(self)
        HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetBackdropBorderColor(0.4, 0.4, 0.4, 0)  -- 恢复默认边框颜色
    end)

    -- originalText              optionText
    -- {"乌鸡"，        “黑发”，      “牛大”}


    -- 下拉菜单初始化
    HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index].Menu = CreateFrame("Frame", "BlessingPaladinMenu"..index, HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index], "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index].Menu, function()
        for i, value in ipairs(PaladinNames) do
            (function(optionText, optionValue)
                local info = {
                    text = optionText,
                    value = optionValue,
                    func = function()
                        -- 保存当前按钮原始文本
                        local originalText = HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:GetText()
                        
                        -- 遍历所有按钮
                        for buttonnIndex = 1, PaladinNums do
                            local otherBtn =HDLUI.BuffWindow.BlessingFrame.PaladinButtons[buttonnIndex]
                            
                            -- 跳过自身按钮
                            if buttonnIndex ~= index then
                                -- 发现重复则交换文本
                                if otherBtn:GetText() == optionText then
                                    otherBtn:SetText(originalText)

                                    --更换HDLUIBuffList["Blessing"][names]中的位置
                                    tableIndex = 1
                                    originalIndex = 0
                                    optionIndex = 0
                                    for _, value in pairs(HDLUIBuffList["Blessing"]["Names"]) do
                                        if value == originalText then
                                            originalIndex = tableIndex
                                        end
                                        if value == optionText then
                                            optionIndex = tableIndex
                                        end
                                        tableIndex = tableIndex + 1
                                    end
                                    HDLUIBuffList["Blessing"]["Names"][originalIndex] = optionText
                                    HDLUIBuffList["Blessing"]["Names"][optionIndex] = originalText
                                    HDLUI.BlessingPlayerList()
                                end
                            end
                        end
                   
                        -- 更新当前按钮文本
                        HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetText(optionText)
                        CloseDropDownMenus()
                    end,
                    checked = nil,
                }
                UIDropDownMenu_AddButton(info)
            end)(tostring(value), value)
        end
    end)

    -- 点击事件
    HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index]:SetScript("OnClick", function(self)
        ToggleDropDownMenu(1, nil, HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index].Menu, HDLUI.BuffWindow.BlessingFrame.PaladinButtons[index], 0, 0)
    end)
end

--生成祝福图标按钮的函数
--为每个骑士名字后生成9个图标按钮
--图标默认显示为空，点击后在HDL_BlessingIcon列表中的图标中进行切换。
--iconBtn:SetPoint("CENTER", btn, "CENTER", 0, 0)
function HDLUI.CreatePaladinBlessingButton(index, PaladinNums, PaladinNames)
    -- 确保图标按钮注册表存在
    HDLUI.iconButtonRegistry = HDLUI.iconButtonRegistry or {}
    HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons = HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons or {}
    HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick = HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick or {}
    -- 获取当前圣骑士名字
    local paladinName = PaladinNames[index]

    for iconIndex = 1, 9 do
        -- 创建局部变量隔离循环变量
        local currentIconIndex = iconIndex
        local currentIndex = index

        -- 创建父容器框架（代码保持不变）
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons[index] = HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons[index] or {}
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons[index][currentIconIndex] = CreateFrame("Button", "PaladinBlessingButton"..paladinName..currentIconIndex, HDLUI.BuffWindow.BlessingFrame)
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons[index][currentIconIndex]:SetWidth(33)
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons[index][currentIconIndex]:SetHeight(33)
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons[index][currentIconIndex]:SetPoint("TOPLEFT", HDLUI.BuffWindow.BlessingFrame, "TOPLEFT",
            100 + ((currentIconIndex-1)*48),
            -93 - (currentIndex-1)*53
        )
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons[index][currentIconIndex]:EnableMouse(false)

        -- 创建实际点击按钮（代码保持不变）
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[index] = HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[index] or {}
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[index][currentIconIndex] = CreateFrame("Button", nil, HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons[index][currentIconIndex])
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[index][currentIconIndex]:SetWidth(33)
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[index][currentIconIndex]:SetHeight(33)
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[index][currentIconIndex]:SetPoint("CENTER", HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons[index][currentIconIndex], "CENTER", 0, 0)
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[index][currentIconIndex]:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        -- 注册按钮到全局表（代码保持不变）
        HDLUI.iconButtonRegistry[paladinName] = HDLUI.iconButtonRegistry[paladinName] or {}
        HDLUI.iconButtonRegistry[paladinName][currentIconIndex] = HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[index][currentIconIndex]

        -- 初始化纹理和数据存储（代码保持不变）
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[index][currentIconIndex].Texture = HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[index][currentIconIndex]:CreateTexture("BlessingIconTexture"..currentIndex..currentIconIndex, "ARTWORK")
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[index][currentIconIndex].Texture:SetAllPoints()
        if not HDLUIBuffList["Blessing"]["paladinBlessing"][paladinName] then
            HDLUIBuffList["Blessing"]["paladinBlessing"][paladinName] = {}
        end
        local storage = HDLUIBuffList["Blessing"]["paladinBlessing"][paladinName]
        storage[currentIconIndex] = storage[currentIconIndex] or 0
        if storage[currentIconIndex] > 0 then
            HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[index][currentIconIndex].Texture:SetTexture(HDL_BlessingIcon[storage[currentIconIndex]])
        end

        -- 修改后的点击事件处理
        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[index][currentIconIndex]:SetScript("OnClick", function()
            local self = this
            local storage = HDLUIBuffList["Blessing"]["paladinBlessing"][paladinName]
            
            -- 强制类型转换确保数值类型
            storage[currentIconIndex] = tonumber(storage[currentIconIndex]) or 0
        
            if arg1 == "RightButton" then
                -- 类型安全获取当前状态
                local clickedState = tonumber(storage[currentIconIndex]) or 0
                
                -- 安全计算新状态
                local newGlobalState = clickedState + 1
                if newGlobalState > 6 then newGlobalState = 0 end
                
                -- 更新整行状态
                for i = 1, 9 do
                    storage[i] = newGlobalState
                    local targetBtn = HDLUI.iconButtonRegistry[paladinName][i]
                    if targetBtn and targetBtn.Texture then
                        targetBtn.Texture:SetTexture(HDL_BlessingIcon[newGlobalState] or "")
                        HDLUIBuffList["Blessing"]["paladinBlessing"][index][i] = newGlobalState
                        
                    end
                end
            else
                -- 左键逻辑保持不变但添加校验
                local current = tonumber(storage[currentIconIndex]) or 0
                current = current + 1
                if current > 6 then current = 0 end
                storage[currentIconIndex] = current
                self.Texture:SetTexture(HDL_BlessingIcon[current] or "")
                HDLUIBuffList["Blessing"]["paladinBlessing"][index][currentIconIndex] = current
            end
        end)

        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[index][currentIconIndex]:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    end
end

--清理按钮函数
function HDLUI.ClearOldButtons()
    HDLUI.BuffWindow.BlessingFrame.PaladinButtons = HDLUI.BuffWindow.BlessingFrame.PaladinButtons or {}
    HDLUI.iconButtonRegistry = HDLUI.iconButtonRegistry or {}
    for i = 1, 6 do
        if HDLUI.BuffWindow.BlessingFrame.PaladinButtons[i] then
            HDLUI.BuffWindow.BlessingFrame.PaladinButtons[i]:Hide()
            HDLUI.BuffWindow.BlessingFrame.PaladinButtons[i]:ClearAllPoints()
            HDLUI.BuffWindow.BlessingFrame.PaladinButtons[i]:SetParent(nil)
        end
        
        if type(HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons) == "table" then
            if type(HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons[i]) == "table" then
                for j = 1,9 do
                    if type(HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons[i][j]) == "table" then
                        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons[i][j]:Hide()
                        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons[i][j]:ClearAllPoints()
                        HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtons[i][j]:SetParent(nil)
                    end
                end
            end
        end
    end
end

function HDLUI.LoadPaladingSetting(i)
    for j = 1, 9 do
        HDLUIBuffList["Blessing"]["paladinBlessing"][i] = HDLUIBuffList["Blessing"]["paladinBlessing"][i] or {}
        HDLUIBuffList["Blessing"]["paladinBlessing"][i][j] = HDLUIBuffList["Blessing"]["paladinBlessing"][i][j] or {}
        if HDLUIBuffList["Blessing"]["paladinBlessing"][i][j] ~= {} then
            HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[i][j].Texture:SetTexture(HDL_BlessingIcon[HDLUIBuffList["Blessing"]["paladinBlessing"][i][j]])
        end
    end
end

--获取表的长度
function HDLUI.GetTableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

--判断两个表是否相等
function HDLUI.TableEqual(t1, t2)
    if HDLUI.GetTableLength(t1) ~= HDLUI.GetTableLength(t2) then
        return false
    end
    for k, v in pairs(t1) do
        if t2[k] == nil then
            return false
        end
        if t2[k] ~= v then
            return false
        end
    end
    return true
end

--判定表中是否含有某个值的函数
function HDLUI.TableContains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- 如果骑士数量变化后需要刷新界面可以调用此函数
function HDLUI.RefreshBlessingFrame()
    HDLUI.ClearOldButtons()
    local PaladinNums = 0
    local PaladinNames = {}
    if HDLUIBuffList["Blessing"]["Names"][1] == nil then
        PaladinNums, PaladinNames = HDLUI.GetClassN("圣骑士")
        HDLUIBuffList["Blessing"]["Names"] = PaladinNames
        HDLUIBuffList["Blessing"]["Nums"] = PaladinNums
    else
        
        --判定是否有新加入的骑士，或者有骑士退出,要考虑到骑士为止可以手动修改，所以要对每个项都进行比较，如果相同，则按如下规则处理
        -- PaladinNames = HDLUIBuffList["Blessing"]["Names"]
        -- PaladinNums = HDLUIBuffList["Blessing"]["Nums"]
        
        local PaladinNumsCompare, PaladinNamesCompare = HDLUI.GetClassN("圣骑士")
        if not HDLUI.TableEqual(PaladinNamesCompare, HDLUIBuffList["Blessing"]["Names"]) then
            --如果不同
            --如果新增了骑士则需要将新的名字列表和数量存入HDLUIBuffList["Blessing"]["Names"]和HDLUIBuffList["Blessing"]["Nums"]中的位置
            for _, v in pairs(PaladinNamesCompare) do
                if not HDLUI.TableContains(HDLUIBuffList["Blessing"]["Names"], v) then
                    table.insert(HDLUIBuffList["Blessing"]["Names"], v)
                    HDLUIBuffList["Blessing"]["Nums"] = HDLUIBuffList["Blessing"]["Nums"] + 1
                    --初始化图标为0
                    HDLUIBuffList["Blessing"]["paladinBlessing"][HDLUIBuffList["Blessing"]["Nums"]] = {}
                    for i = 1, 9 do
                        HDLUIBuffList["Blessing"]["paladinBlessing"][HDLUIBuffList["Blessing"]["Nums"]][i] = 0
                    end
                end
            end
            --如果有骑士退出，则需要将退出的骑士的名字从HDLUIBuffList["Blessing"]["Names"]中删除，并将数量减一，同时将HDLUIBuffList["Blessing"]["paladinBlessing"]中的对应项删除
            for _, v in pairs(HDLUIBuffList["Blessing"]["Names"]) do
                if not HDLUI.TableContains(PaladinNamesCompare, v) then
                    for i = 1, HDLUIBuffList["Blessing"]["Nums"] do
                        if HDLUIBuffList["Blessing"]["Names"][i] == v then
                            table.remove(HDLUIBuffList["Blessing"]["Names"], i)
                            HDLUIBuffList["Blessing"]["Nums"] = HDLUIBuffList["Blessing"]["Nums"] - 1
                            table.remove(HDLUIBuffList["Blessing"]["paladinBlessing"], i)
                        end
                    end
                end
            end
        end
    end

    PaladinNums = HDLUIBuffList["Blessing"]["Nums"]
    PaladinNames = HDLUIBuffList["Blessing"]["Names"]

    HDLUI.BuffWindow.BlessingFrame:SetHeight(100 + PaladinNums * 53)

        -- 批量创建按钮
    for i = 1, PaladinNums do
        if i > PaladinNums and HDLUI.BuffWindow.BlessingFrame.PaladinButtons[i] then
            HDLUI.BuffWindow.BlessingFrame.PaladinButtons[i]:Hide()
            HDLUI.BuffWindow.BlessingFrame.PaladinButtons[i]:ClearAllPoints()
        else
            HDLUI.CreatePaladinButton(i, PaladinNums, PaladinNames)
            HDLUI.CreatePaladinBlessingButton(i, PaladinNums, PaladinNames)
            HDLUI.LoadPaladingSetting(i)
        end
    end
end

function HDLUI.Load()
    -- 加载耐力分配
    for i = 1, 8 do
        local dropdown = _G["HDLUIBuffWindowFortitude"..i]
        if dropdown then
            local value = HDLUIBuffList["Fortitude"][i]
            UIDropDownMenu_SetText(value ~= "" and value or "<空>", dropdown)
        end
    end

    -- 加载智力分配
    for i = 1, 8 do
        local dropdown = _G["HDLUIBuffWindowIntellect"..i]
        if dropdown then
            local value = HDLUIBuffList["Intellect"][i]
            UIDropDownMenu_SetText(value ~= "" and value or "<空>", dropdown)
        end
    end

    -- 加载爪子分配
    for i = 1, 8 do
        local dropdown = _G["HDLUIBuffWindowWildMark"..i]
        if dropdown then
            local value = HDLUIBuffList["WildMark"][i]
            UIDropDownMenu_SetText(value ~= "" and value or "<空>", dropdown)
        end
    end

    -- 加载诅咒分配
    for i = 1, 4 do
        local dropdown = _G["HDLUIBuffWindowCurse"..i]
        if dropdown then
            local value = HDLUIBuffList["Curse"][i]
            UIDropDownMenu_SetText(value ~= "" and value or "<空>", dropdown)
        end
    end

    -- 加载坦克分配
    for i = 1, 4 do
        local dropdown = _G["HDLUIBuffWindowTank"..i]
        if dropdown then
            local value = HDLUIBuffList["Tank"][i]
            UIDropDownMenu_SetText(value ~= "" and value or "<空>", dropdown)
        end
    end
end





