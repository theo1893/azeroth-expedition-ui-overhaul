--独立装备查看界面
--显示装备列表、人物头像、姓名、职业、装等

-- 测试加载
DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00S_ItemTip InspectFrame.lua 开始加载...|r")

local INSPECT_FRAME_WIDTH = 220
local INSPECT_FRAME_TOP_HEIGHT = 110  -- 顶部区域高度（头像、姓名、装等）- 增加以容纳等级框
local SLOT_HEIGHT = 18  -- 每个槽位的高度

--装备槽位列表
local SLOT_LIST = {
    {id = 1, name = "头部"},
    {id = 2, name = "颈部"},
    {id = 3, name = "肩部"},
    {id = 5, name = "胸部"},
    {id = 6, name = "腰部"},
    {id = 7, name = "腿部"},
    {id = 8, name = "脚部"},
    {id = 9, name = "手腕"},
    {id = 10, name = "手部"},
    {id = 11, name = "手指"},
    {id = 12, name = "手指"},
    {id = 13, name = "饰品"},
    {id = 14, name = "饰品"},
    {id = 15, name = "背部"},
    {id = 16, name = "主手"},
    {id = 17, name = "副手"},
    {id = 18, name = "远程"},
}

-- 根据槽位数量动态计算框架高度
local SLOT_COUNT = table.getn(SLOT_LIST)
local INSPECT_FRAME_HEIGHT = INSPECT_FRAME_TOP_HEIGHT + (SLOT_COUNT * SLOT_HEIGHT) + 20  -- +20 是底部边距

--全局变量（供 InspectGemAndEnchant.lua 使用）
S_ItemTip_InspectFrame = nil
local currentUnit = "player"

--创建主框架
local function CreateFrame_Delayed()
    if S_ItemTip_InspectFrame then return S_ItemTip_InspectFrame end
    
    S_ItemTip_InspectFrame = CreateFrame("Frame", "S_ItemTip_InspectFrame_UI", UIParent)
    local frame = S_ItemTip_InspectFrame
frame:SetWidth(INSPECT_FRAME_WIDTH)
frame:SetHeight(INSPECT_FRAME_HEIGHT)
frame:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", -35, -10)
frame:SetFrameStrata("MEDIUM")
frame:SetToplevel(true)
frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
})
frame:SetBackdropColor(0, 0, 0, 0.9)
frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:Hide()

-- 点击时提升层级
frame:SetScript("OnMouseDown", function()
    this:Raise()
end)

-- 添加拖动功能
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function()
    this:StartMoving()
end)
frame:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
end)

-- 原版没有关闭按钮，移除

--头像框架
frame.portraitFrame = CreateFrame("Frame", nil, frame)
frame.portraitFrame:SetWidth(64)
frame.portraitFrame:SetHeight(64)
frame.portraitFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -16)

--头像纹理
frame.portrait = frame.portraitFrame:CreateTexture(nil, "BACKGROUND")
frame.portrait:SetWidth(56)
frame.portrait:SetHeight(56)
frame.portrait:SetPoint("CENTER", frame.portraitFrame, "CENTER", 0, 0)

--头像边框
frame.portraitBorder = frame.portraitFrame:CreateTexture(nil, "OVERLAY")
frame.portraitBorder:SetTexture("Interface\\AddOns\\S_ItemTip\\边框")
frame.portraitBorder:SetWidth(254)
frame.portraitBorder:SetHeight(254)
frame.portraitBorder:SetPoint("CENTER", frame.portraitFrame, "CENTER", 5, -10)
frame.portraitBorder:SetBlendMode("BLEND")
frame.portraitBorder:SetVertexColor(1, 1, 1)  -- 默认白色

--等级背景框
frame.levelBg = CreateFrame("Frame", nil, frame)
frame.levelBg:SetWidth(40)
frame.levelBg:SetHeight(16)
frame.levelBg:SetPoint("BOTTOM", frame.portraitFrame, "BOTTOM", 0, -10)
frame.levelBg:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 8,
    edgeSize = 8,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
})
frame.levelBg:SetBackdropColor(0, 0, 0, 0.8)

--等级文本（显示在背景框中，金色字体）
frame.levelText = frame.levelBg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.levelText:SetPoint("CENTER", frame.levelBg, "CENTER", 0, 0)
frame.levelText:SetTextColor(1, 0.82, 0)  -- 金色

--职业图标（大图标，显示在头像右上角）
frame.classIcon = frame:CreateTexture(nil, "ARTWORK")
frame.classIcon:SetWidth(40)
frame.classIcon:SetHeight(40)
frame.classIcon:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -25)
frame.classIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")

--姓名
frame.nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.nameText:SetPoint("TOPLEFT", frame.portrait, "TOPRIGHT", 8, -5)
frame.nameText:SetJustifyH("LEFT")

--总装等（显示在姓名下方）
frame.ilevelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.ilevelText:SetPoint("TOPLEFT", frame.nameText, "BOTTOMLEFT", 0, -5)
frame.ilevelText:SetTextColor(1, 0.82, 0)
frame.ilevelText:SetJustifyH("LEFT")

--职业文字（隐藏，因为有图标了）
frame.classText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
frame.classText:SetPoint("TOPLEFT", frame.ilevelText, "BOTTOMLEFT", 0, -3)
frame.classText:SetJustifyH("LEFT")

--装备列表容器
frame.slotFrames = {}
local yOffset = -INSPECT_FRAME_TOP_HEIGHT
for i, slotData in ipairs(SLOT_LIST) do
    local slotFrame = CreateFrame("Frame", nil, frame)
    slotFrame:SetWidth(INSPECT_FRAME_WIDTH - 30)
    slotFrame:SetHeight(SLOT_HEIGHT)
    slotFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, yOffset)
    
    --槽位名称标签背景（只有这一小块有背景）
    slotFrame.labelBg = CreateFrame("Frame", nil, slotFrame)
    slotFrame.labelBg:SetWidth(32)
    slotFrame.labelBg:SetHeight(16)
    slotFrame.labelBg:SetPoint("LEFT", slotFrame, "LEFT", 1, 0)
    slotFrame.labelBg:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 8,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    slotFrame.labelBg:SetBackdropColor(0, 0.9, 0.9, 0.2)
    slotFrame.labelBg:SetBackdropBorderColor(0, 0.9, 0.9, 0.2)
    
    --槽位名称
    slotFrame.slotName = slotFrame.labelBg:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slotFrame.slotName:SetPoint("CENTER", slotFrame.labelBg, "CENTER", 0, 0)
    slotFrame.slotName:SetText(slotData.name)
    slotFrame.slotName:SetTextColor(0, 0.9, 0.9)
    slotFrame.slotName:SetWidth(30)
    slotFrame.slotName:SetJustifyH("CENTER")
    
    --装备等级
    slotFrame.itemLevel = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slotFrame.itemLevel:SetPoint("LEFT", slotFrame.labelBg, "RIGHT", 4, 0)
    slotFrame.itemLevel:SetTextColor(1, 1, 1)
    slotFrame.itemLevel:SetWidth(24)
    slotFrame.itemLevel:SetJustifyH("RIGHT")
    
    --装备名称
    slotFrame.itemName = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slotFrame.itemName:SetPoint("LEFT", slotFrame.itemLevel, "RIGHT", 2, 0)
    slotFrame.itemName:SetJustifyH("LEFT")
    slotFrame.itemName:SetWidth(100)  -- 固定宽度防止换行
    
    slotFrame.slotId = slotData.id
    slotFrame.itemLink = nil
    slotFrame.quality = nil
    
    --鼠标提示
    slotFrame:EnableMouse(true)
    slotFrame:SetScript("OnEnter", function()
        if this.slotId and frame.currentUnit and UnitExists(frame.currentUnit) then
            local itemLink = GetInventoryItemLink(frame.currentUnit, this.slotId)
            if not itemLink then return end
            
            -- 使用 ANCHOR_RIGHT，让 tooltip 显示在装备行的右侧
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetInventoryItem(frame.currentUnit, this.slotId)
            GameTooltip:Show()
        end
    end)
    slotFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    frame.slotFrames[i] = slotFrame
    yOffset = yOffset - SLOT_HEIGHT
end
    
    return S_ItemTip_InspectFrame
end

--获取单位装备槽位的物品链接
local function GetUnitItemLink(unit, slotId)
    if not UnitExists(unit) then return nil end
    
    -- 直接使用 GetInventoryItemLink
    -- 注意：对于 player 单位，这个函数返回的链接中附魔ID可能是0
    -- 但这是魔兽世界 1.12 客户端的限制，无法通过 Lua 代码解决
    -- 附魔信息需要通过其他方式获取（例如扫描 tooltip）
    return GetInventoryItemLink(unit, slotId)
end

--获取附魔信息
local function GetEnchantText(itemLink)
    if not itemLink then return "" end
    
    -- 从物品链接中提取附魔ID
    local enchantID = tonumber(string.match(itemLink, "item:%d+:(%d+)"))
    if not enchantID or enchantID == 0 then return "" end
    
    -- 尝试使用 LibItemEnchant 获取附魔名称
    if LibStub then
        local LibItemEnchant = LibStub:GetLibrary("LibItemEnchant.7000", true)
        if LibItemEnchant then
            local spellID = LibItemEnchant:GetEnchantSpellID(itemLink)
            if spellID then
                local enchantName = GetSpellInfo(spellID)
                if enchantName then
                    return " |cFF00FF00[" .. enchantName .. "]|r"
                end
            end
        end
    end
    
    -- 如果无法获取附魔名称，显示附魔ID
    return " |cFF00FF00[+" .. enchantID .. "]|r"
end

--更新装备信息（全局函数，供 InspectGemAndEnchant.lua 使用）
function S_ItemTip_UpdateFrame(unit)
    local frame = S_ItemTip_InspectFrame
    if not frame then return end
    if not UnitExists(unit) then return end
    
    currentUnit = unit
    frame.currentUnit = unit  -- 保存到框架上，供 tooltip 使用
    
    -- 先清空所有附魔图标（在 InspectGemAndEnchant.lua 中会重新创建）
    local index = 1
    while frame["gemIcon"..index] do
        frame["gemIcon"..index]:Hide()
        frame["gemIcon"..index].title = nil
        frame["gemIcon"..index].itemLink = nil
        frame["gemIcon"..index].spellID = nil
        index = index + 1
    end
    
    --设置头像和等级
    local level = UnitLevel(unit)
    frame.levelText:SetText(level)
    
    -- 设置头像（每次都刷新以确保显示）
    frame.portrait:SetTexture("Interface\\CharacterFrame\\TempPortrait")
    frame.portrait:Show()
    
    -- 延迟0.15秒后设置真实头像（增加延迟时间以确保数据加载完成）
    local portraitTimer = 0
    local portraitUpdateFrame = CreateFrame("Frame")
    portraitUpdateFrame:SetScript("OnUpdate", function()
        portraitTimer = portraitTimer + arg1
        if portraitTimer > 0.15 then
            if UnitExists(unit) then
                SetPortraitTexture(frame.portrait, unit)
                frame.portrait:Show()  -- 确保显示
            end
            portraitUpdateFrame:SetScript("OnUpdate", nil)
        end
    end)
    
    -- 再次延迟刷新以确保显示正确
    local timer2 = 0
    local updateFrame2 = CreateFrame("Frame")
    updateFrame2:SetScript("OnUpdate", function()
        timer2 = timer2 + arg1
        if timer2 > 0.3 then
            if UnitExists(unit) then
                SetPortraitTexture(frame.portrait, unit)
                frame.portrait:Show()
            end
            updateFrame2:SetScript("OnUpdate", nil)
        end
    end)
    
    --设置姓名
    local name = UnitName(unit)
    frame.nameText:SetText(name)
    
    --设置职业和颜色
    local localizedClass, class = UnitClass(unit)
    local classColor = RAID_CLASS_COLORS[class]
    if classColor then
        frame.nameText:SetTextColor(classColor.r, classColor.g, classColor.b)
        frame.levelBg:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b)
        -- 头像边框也使用职业颜色
        frame.portraitBorder:SetVertexColor(classColor.r, classColor.g, classColor.b)
    end
    
    --设置职业图标
    if CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[class] then
        local coords = CLASS_ICON_TCOORDS[class]
        frame.classIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        frame.classIcon:Show()
    else
        frame.classIcon:Hide()
    end
    
    --隐藏职业文字（因为有图标了）
    frame.classText:SetText("")
    
    --更新装备槽位并计算最大宽度
    local maxWidth = 200  -- 最小宽度
    local itemCount = 0
    for i, slotFrame in ipairs(frame.slotFrames) do
        local itemLink = GetUnitItemLink(unit, slotFrame.slotId)
        if itemLink then
            itemCount = itemCount + 1
            local _, _, itemID = string.find(itemLink, "item:(%d+):")
            if itemID then
                -- 获取物品信息
                local itemName, _, itemQuality, _, _, _, _, _, _, _, _ = GetItemInfo(itemID)
                
                -- 尝试从多个来源获取装备等级
                local itemLevel = 0
                
                -- 优先使用 lib (LibItem-enUS-1.0)
                if lib and lib.itemstats and lib.itemstats[tonumber(itemID)] then
                    itemLevel = lib.itemstats[tonumber(itemID)].level or 0
                end
                
                -- 如果 lib 没有，尝试 LibItem_Level
                if itemLevel == 0 and LibItem_Level then
                    itemLevel = LibItem_Level[tonumber(itemID)] or 0
                end
                
                -- 如果还是没有，尝试通过英文名称匹配（处理英文物品名）
                if itemLevel == 0 and itemName and lib and lib.Item_enUS then
                    for realID, engName in pairs(lib.Item_enUS) do
                        if engName == itemName then
                            itemLevel = LibItem_Level[realID] or 0
                            break
                        end
                    end
                end
                
                -- 显示装备等级
                if itemLevel > 0 then
                    slotFrame.itemLevel:SetText(itemLevel)
                else
                    slotFrame.itemLevel:SetText("")
                end
                
                -- 显示装备名称（不再显示附魔文本，改用图标）
                if itemName then
                    slotFrame.itemName:SetText(itemName)
                    -- 先重置宽度以获取实际文本宽度
                    slotFrame.itemName:SetWidth(0)
                    local actualNameWidth = slotFrame.itemName:GetWidth()
                    
                    -- 设置为实际宽度，让名称完整显示
                    slotFrame.itemName:SetWidth(actualNameWidth)
                    
                    -- 计算这一行的总宽度（宝石和附魔图标会在 InspectGemAndEnchant.lua 中添加）
                    -- 预留附魔图标空间（最多2个图标，每个17像素）
                    local rowWidth = 15 + 32 + 24 + actualNameWidth + 40  -- 40是附魔图标预留空间
                    if rowWidth > maxWidth then
                        maxWidth = rowWidth
                    end
                    
                    -- 设置品质颜色（装备名称）
                    if itemQuality then
                        local r, g, b = GetItemQualityColor(itemQuality)
                        slotFrame.itemName:SetTextColor(r, g, b)
                    end
                else
                    slotFrame.itemName:SetText("")
                end
                
                -- 保存品质信息
                slotFrame.quality = itemQuality
                slotFrame.itemLink = itemLink
                
                -- 根据品质设置标签颜色
                local r, g, b = 0, 0.9, 0.9
                if itemQuality then
                    r, g, b = GetItemQualityColor(itemQuality)
                end
                slotFrame.labelBg:SetBackdropColor(r, g, b, 0.2)
                slotFrame.labelBg:SetBackdropBorderColor(r, g, b, 0.2)
                slotFrame.slotName:SetTextColor(r, g, b)
                slotFrame:SetAlpha(1)
            else
                slotFrame.itemLevel:SetText("")
                slotFrame.itemName:SetText("")
                slotFrame.itemLink = nil
                slotFrame.quality = nil
                -- 重置为默认颜色
                slotFrame.labelBg:SetBackdropColor(0, 0.9, 0.9, 0.2)
                slotFrame.labelBg:SetBackdropBorderColor(0, 0.9, 0.9, 0.2)
                slotFrame.slotName:SetTextColor(0, 0.9, 0.9)
                slotFrame:SetAlpha(0.5)
            end
        else
            -- 没有装备时显示灰色
            slotFrame.itemLevel:SetText("")
            slotFrame.itemName:SetText("")
            slotFrame.itemLink = nil
            slotFrame.quality = nil
            -- 设置为灰色
            slotFrame.labelBg:SetBackdropColor(0.6, 0.6, 0.6, 0.2)
            slotFrame.labelBg:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.2)
            slotFrame.slotName:SetTextColor(0.6, 0.6, 0.6)
            slotFrame:SetAlpha(0.5)
        end
    end
    
    -- 调整框体宽度
    if maxWidth > 200 then
        frame:SetWidth(maxWidth + 20)
    else
        frame:SetWidth(200)
    end
    
    --使用 ItemSocre 的计算方法获取总装等
    local avgLevel = 0
    if ItemSocre and ItemSocre.ScanUnit then
        avgLevel = ItemSocre:ScanUnit(unit) or 0
    end
    frame.ilevelText:SetText(string.format("iLvl %.1f", avgLevel))
end

--当角色面板打开时
local function OnCharacterShow()
    if not S_ItemTip_InspectFrame then
        CreateFrame_Delayed()
    end
    
    local frame = S_ItemTip_InspectFrame
    if frame then
        -- 查看自己时使用 MEDIUM 层级（和 StatCompareSelfFrame 一样）
        frame:SetFrameStrata("MEDIUM")
        
        -- 固定附着到角色面板右边
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", -35, -10)
        frame:Show()  -- 先显示框架
        S_ItemTip_UpdateFrame("player")  -- 然后更新内容
        
        -- 注释掉：让 StatCompare 自己管理位置，避免冲突
        -- if StatCompareSelfFrame and StatCompareSelfFrame:IsVisible() then
        --     StatCompareSelfFrame:ClearAllPoints()
        --     StatCompareSelfFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", -5, 0)
        -- end
    end
end

--当角色面板关闭时
local function OnCharacterHide()
    if S_ItemTip_InspectFrame then
        S_ItemTip_InspectFrame:Hide()
    end
end

--装备变化时
local function OnEquipmentChanged()
    if S_ItemTip_InspectFrame and CharacterFrame:IsShown() and S_ItemTip_InspectFrame:IsShown() then
        S_ItemTip_UpdateFrame("player")
    end
end

--Hook角色面板的显示/隐藏
local oldCharacterFrame_OnShow = CharacterFrame:GetScript("OnShow")
CharacterFrame:SetScript("OnShow", function()
    if oldCharacterFrame_OnShow then
        oldCharacterFrame_OnShow()
    end
    -- 只在"角色"标签页显示
    if PaperDollFrame:IsVisible() then
        OnCharacterShow()
    end
end)

local oldCharacterFrame_OnHide = CharacterFrame:GetScript("OnHide")
CharacterFrame:SetScript("OnHide", function()
    if oldCharacterFrame_OnHide then
        oldCharacterFrame_OnHide()
    end
    OnCharacterHide()
end)

-- Hook PaperDollFrame 的显示/隐藏（当切换标签页时）
local oldPaperDollFrame_OnShow = PaperDollFrame:GetScript("OnShow")
PaperDollFrame:SetScript("OnShow", function()
    if oldPaperDollFrame_OnShow then
        oldPaperDollFrame_OnShow()
    end
    -- 切换到"角色"标签页时显示
    if CharacterFrame:IsVisible() then
        OnCharacterShow()
    end
end)

local oldPaperDollFrame_OnHide = PaperDollFrame:GetScript("OnHide")
PaperDollFrame:SetScript("OnHide", function()
    if oldPaperDollFrame_OnHide then
        oldPaperDollFrame_OnHide()
    end
    -- 切换到其他标签页时隐藏
    OnCharacterHide()
end)

--Hook查看面板的显示/隐藏（延迟执行，确保 InspectFrame 已加载）
local function HookInspectFrame()
    if not InspectFrame then
        return
    end
    
    local oldInspectFrame_OnShow = InspectFrame:GetScript("OnShow")
    InspectFrame:SetScript("OnShow", function()
        if oldInspectFrame_OnShow then
            oldInspectFrame_OnShow()
        end
        -- 查看其他玩家时
        if InspectFrame.unit then
            if not S_ItemTip_InspectFrame then
                CreateFrame_Delayed()
            end
            local frame = S_ItemTip_InspectFrame
            if frame then
                -- 查看目标时使用 LOW 层级（和 StatCompareTargetFrame 一样）
                frame:SetFrameStrata("LOW")
                
                frame:ClearAllPoints()
                frame:SetPoint("TOPLEFT", InspectFrame, "TOPRIGHT", -35, -10)
                frame:Show()
                
                -- 延迟更新装备信息，等待数据加载
                local updateTimer = 0
                local updateAttempts = 0
                local updateFrame = CreateFrame("Frame")
                updateFrame:SetScript("OnUpdate", function()
                    updateTimer = updateTimer + arg1
                    if updateTimer > 0.15 then  -- 减少到 0.15 秒
                        updateTimer = 0
                        updateAttempts = updateAttempts + 1
                        
                        -- 尝试获取第一个槽位的装备，检查数据是否准备好
                        local testLink = GetUnitItemLink(InspectFrame.unit, 1)
                        
                        if testLink or updateAttempts >= 10 then
                            S_ItemTip_UpdateFrame(InspectFrame.unit)
                            updateFrame:SetScript("OnUpdate", nil)
                            
                            -- 延迟重新定位 StatCompare，确保它已经显示
                            local repositionTimer = 0
                            local repositionFrame = CreateFrame("Frame")
                            repositionFrame:SetScript("OnUpdate", function()
                                repositionTimer = repositionTimer + arg1
                                if repositionTimer > 0.1 then  -- 减少到 0.1 秒
                                    -- 注释掉：让 StatCompare 自己管理位置，避免冲突
                                    -- 排列顺序：InspectFrame → S_ItemTip → StatCompareTargetFrame(对方) → StatCompareSelfFrame(自己)
                                    
                                    -- 对方的属性面板附着到我们的装备列表右边
                                    -- if StatCompareTargetFrame and StatCompareTargetFrame:IsVisible() then
                                    --     StatCompareTargetFrame:ClearAllPoints()
                                    --     StatCompareTargetFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", -5, 0)
                                    --     
                                    --     -- 自己的属性面板附着到对方属性面板的右边
                                    --     if StatCompareSelfFrame and StatCompareSelfFrame:IsVisible() then
                                    --         StatCompareSelfFrame:ClearAllPoints()
                                    --         StatCompareSelfFrame:SetPoint("TOPLEFT", StatCompareTargetFrame, "TOPRIGHT", -5, 0)
                                    --     end
                                    -- elseif StatCompareSelfFrame and StatCompareSelfFrame:IsVisible() then
                                    --     -- 如果只有自己的属性面板，附着到装备列表右边
                                    --     StatCompareSelfFrame:ClearAllPoints()
                                    --     StatCompareSelfFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", -5, 0)
                                    -- end
                                    
                                    repositionFrame:SetScript("OnUpdate", nil)
                                end
                            end)
                        end
                    end
                end)
            end
        end
    end)
    
    local oldInspectFrame_OnHide = InspectFrame:GetScript("OnHide")
    InspectFrame:SetScript("OnHide", function()
        if oldInspectFrame_OnHide then
            oldInspectFrame_OnHide()
        end
        if S_ItemTip_InspectFrame then
            S_ItemTip_InspectFrame:Hide()
        end
    end)
end

-- 延迟 Hook，确保 InspectFrame 已加载
local hookTimer = 0
local hookFrame = CreateFrame("Frame")
hookFrame:SetScript("OnUpdate", function()
    hookTimer = hookTimer + arg1
    if hookTimer > 1 then
        if InspectFrame then
            HookInspectFrame()
            hookFrame:SetScript("OnUpdate", nil)
        end
    end
end)

--注册装备变化事件
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
eventFrame:RegisterEvent("INSPECT_READY")
eventFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
eventFrame:RegisterEvent("UNIT_MODEL_CHANGED")
eventFrame:SetScript("OnEvent", function()
    if event == "UNIT_INVENTORY_CHANGED" then
        -- 1.12 版本中 arg1 就是单位名称
        if arg1 == "player" and S_ItemTip_InspectFrame and CharacterFrame:IsShown() and S_ItemTip_InspectFrame:IsShown() then
            S_ItemTip_UpdateFrame("player")
        end
    elseif event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_MODEL_CHANGED" then
        -- 处理头像更新事件
        if S_ItemTip_InspectFrame and S_ItemTip_InspectFrame:IsVisible() then
            local frame = S_ItemTip_InspectFrame
            local unit = frame.currentUnit
            if unit and UnitExists(unit) and frame.portrait then
                SetPortraitTexture(frame.portrait, unit)
                frame.portrait:Show()
            end
        end
    elseif event == "INSPECT_READY" then
        -- 当查看其他玩家的装备数据准备好时
        if InspectFrame and InspectFrame:IsShown() and InspectFrame.unit then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00开始更新装备信息: " .. tostring(InspectFrame.unit) .. "|r")
            if not S_ItemTip_InspectFrame then
                CreateFrame_Delayed()
            end
            local frame = S_ItemTip_InspectFrame
            if frame then
                -- 延迟一点更新，确保数据已经加载
                local updateTimer = 0
                local updateFrame = CreateFrame("Frame")
                updateFrame:SetScript("OnUpdate", function()
                    updateTimer = updateTimer + arg1
                    if updateTimer > 0.5 then
                        S_ItemTip_UpdateFrame(InspectFrame.unit)
                        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00装备信息已更新|r")
                        updateFrame:SetScript("OnUpdate", nil)
                    end
                end)
            end
        end
    end
end)

DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00S_ItemTip装备查看已加载|r - 按C键打开角色面板查看")

--斜杠命令
SLASH_SITEMINSPECT1 = "/si"
SLASH_SITEMINSPECT2 = "/siteminspect"
SlashCmdList["SITEMINSPECT"] = function(msg)
    if not S_ItemTip_InspectFrame then
        CreateFrame_Delayed()
    end
    if not S_ItemTip_InspectFrame then
        DEFAULT_CHAT_FRAME:AddMessage("框架创建失败")
        return
    end
    local frame = S_ItemTip_InspectFrame
    
    if msg == "target" then
        if UnitExists("target") and UnitIsPlayer("target") then
            S_ItemTip_UpdateFrame("target")
            frame:Show()
        else
            DEFAULT_CHAT_FRAME:AddMessage("请选择一个玩家目标")
        end
    else
        S_ItemTip_UpdateFrame("player")
        frame:Show()
    end
end

DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00S_ItemTip InspectFrame.lua 加载完成|r")
