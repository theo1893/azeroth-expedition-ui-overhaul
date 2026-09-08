--显示附魔图标
--基于扫描和缓存的实现
--1.12 版本只有附魔，没有宝石系统

-- 持久化缓存（保存到 SavedVariables）
-- 格式：itemLink -> {enchantName, timestamp}
S_ItemTip_EnchantCache = S_ItemTip_EnchantCache or {}

--可附魔的部位
local EnchantParts = {
    [1] = { 1, "头部" },
    [2] = { 1, "颈部" },  -- 颈部不能附魔
    [3] = { 1, "肩部" },
    [5] = { 1, "胸部" },
    [6] = { 1, "腰部" },  -- 腰部不能附魔
    [7] = { 1, "腿部" },
    [8] = { 1, "脚部" },
    [9] = { 1, "手腕" },
    [10] = { 1, "手部" },
    [11] = { 1, "手指" },  -- 戒指（附魔师专属）
    [12] = { 1, "手指" },  -- 戒指（附魔师专属）
    [13] = { 0, "饰品" },  -- 饰品不能附魔
    [14] = { 0, "饰品" },  -- 饰品不能附魔
    [15] = { 1, "背部" },
    [16] = { 1, "主手" },
    [17] = { 1, "副手" },
}

-- 清理过期缓存（保留最近30天的数据）
local function CleanOldCache()
    local now = time()
    local maxAge = 30 * 24 * 60 * 60  -- 30天
    local cleaned = 0
    
    for itemLink, data in pairs(S_ItemTip_EnchantCache) do
        -- 只清理新格式的缓存（有 timestamp 的）
        if type(data) == "table" and data.timestamp and (now - data.timestamp) > maxAge then
            S_ItemTip_EnchantCache[itemLink] = nil
            cleaned = cleaned + 1
        end
    end
    
    if cleaned > 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00S_ItemTip: 清理了 " .. cleaned .. " 条过期附魔缓存|r")
    end
end

--创建图标框架
local function CreateIconFrame(frame, index)
    local icon = CreateFrame("Frame", nil, frame)
    icon.index = index
    icon:Hide()
    icon:SetWidth(16)
    icon:SetHeight(16)
    
    -- 设置较高的层级，确保不被遮挡
    icon:SetFrameLevel(frame:GetFrameLevel() + 10)
    
    -- 启用鼠标事件，阻止穿透到下层
    icon:EnableMouse(true)
    icon:SetToplevel(true)
    
    icon:SetScript("OnEnter", function()
        if this.title then
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetText(this.title, 0, 1, 0.5, 1, true)
            if this.enchantID then
                GameTooltip:AddLine("附魔ID: " .. this.enchantID, 1, 1, 1)
            end
            GameTooltip:Show()
        end
    end)
    icon:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    icon.bg = icon:CreateTexture(nil, "BACKGROUND")
    icon.bg:SetWidth(16)
    icon.bg:SetHeight(16)
    icon.bg:SetPoint("CENTER", icon, "CENTER", 0, 0)
    icon.bg:SetTexture("Interface\\Buttons\\UI-EmptySlot")
    
    icon.texture = icon:CreateTexture(nil, "BORDER")
    icon.texture:SetWidth(14)
    icon.texture:SetHeight(14)
    icon.texture:SetPoint("CENTER", icon, "CENTER", 0, 0)
    
    frame["gemIcon"..index] = icon
    return icon
end

--隐藏所有图标
local function HideAllIcons(frame)
    local index = 1
    while frame["gemIcon"..index] do
        frame["gemIcon"..index].title = nil
        frame["gemIcon"..index].enchantID = nil
        frame["gemIcon"..index].itemLink = nil
        frame["gemIcon"..index].spellID = nil
        frame["gemIcon"..index]:Hide()
        index = index + 1
    end
end

--获取可用的图标框架
local function GetIconFrame(frame)
    local index = 1
    while frame["gemIcon"..index] do
        if not frame["gemIcon"..index]:IsShown() then
            return frame["gemIcon"..index]
        end
        index = index + 1
    end
    return CreateIconFrame(frame, index)
end

-- 创建隐藏的 Tooltip 用于扫描附魔信息
local ScanTooltip = CreateFrame("GameTooltip", "S_ItemTip_ScanTooltip", nil, "GameTooltipTemplate")
ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

-- 生成物品链接的缓存键（只保留物品ID和附魔ID）
local function GetItemCacheKey(itemLink)
    if not itemLink then return nil end
    
    -- 提取：item:itemID:enchantID:gem1:gem2:gem3:gem4:...
    local _, _, itemID, enchantID = string.find(itemLink, "item:(%d+):(%d+)")
    if itemID and enchantID and enchantID ~= "0" then
        return itemID .. ":" .. enchantID
    end
    
    return nil
end

-- 从物品链接提取附魔ID
local function GetEnchantIDFromLink(itemLink)
    if not itemLink then return nil end
    local _, _, enchantID = string.find(itemLink, "item:%d+:(%d+)")
    if enchantID and enchantID ~= "0" then
        return tonumber(enchantID)
    end
    return nil
end

-- 调试模式开关
local DEBUG_MODE = false

-- 通过扫描 Tooltip 获取附魔名称并缓存
local function ScanAndCacheEnchant(unit, slot, itemLink)
    if not unit or not slot or not UnitExists(unit) then 
        return nil 
    end
    
    ScanTooltip:ClearLines()
    ScanTooltip:SetInventoryItem(unit, slot)
    
    local numLines = ScanTooltip:NumLines()
    local enchantName = nil
    local requireLevelLine = nil
    
    -- 如果行数太少（小于10行），说明数据还没加载完，不扫描
    if numLines < 10 then
        if DEBUG_MODE then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000=== 槽位 " .. slot .. " 数据未加载完 (只有" .. numLines .. "行) ===|r")
        end
        return nil
    end
    
    if DEBUG_MODE then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00=== 扫描槽位 " .. slot .. " ===|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00总行数: " .. numLines .. "|r")
    end
    
    -- 第一步：找到"需要等级"、"职业"、"耐久度"、"装备"等所在的行
    for i = 1, numLines do
        local line = getglobal("S_ItemTip_ScanTooltipTextLeft" .. i)
        if line then
            local text = line:GetText()
            if text then
                -- 检查是否是需要等级、职业限制、耐久度等行
                if string.find(text, "需要等级") or 
                   string.find(text, "职业") or 
                   string.find(text, "需要") or 
                   string.find(text, "耐久度") or
                   string.find(text, "Requires Level") or 
                   string.find(text, "Requires") or
                   string.find(text, "Classes:") or
                   string.find(text, "Durability") then
                    requireLevelLine = i
                    if DEBUG_MODE then
                        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00找到限制行: " .. i .. " - " .. text .. "|r")
                    end
                    break
                end
            end
        end
    end
    
    -- 如果没找到"需要等级"等行，尝试找"装备"这个词
    if not requireLevelLine then
        for i = 1, numLines do
            local line = getglobal("S_ItemTip_ScanTooltipTextLeft" .. i)
            if line then
                local text = line:GetText()
                if text and (text == "装备" or text == "Equip") then
                    requireLevelLine = i
                    if DEBUG_MODE then
                        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00找到装备行: " .. i .. " - " .. text .. "|r")
                    end
                    break
                end
            end
        end
    end
    
    -- 第二步：扫描所有绿色文字（附魔、强化、临时附魔等）
    -- 从"需要等级"行往上扫描，找到最后一个绿色文字
    if requireLevelLine and requireLevelLine > 1 then
        for i = requireLevelLine - 1, 1, -1 do
            local line = getglobal("S_ItemTip_ScanTooltipTextLeft" .. i)
            if line then
                local text = line:GetText()
                local r, g, b = line:GetTextColor()
                
                if DEBUG_MODE then
                    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFFFFFF00第 %d 行: %s (R:%.2f G:%.2f B:%.2f)|r", i, text or "nil", r, g, b))
                end
                
                -- 检查是否是绿色文字（附魔/强化的特征）
                if text and g > 0.8 and g > r and g > b then
                    -- 排除以下情况：
                    -- 1. 套装效果
                    -- 2. 装备效果（"装备："开头）
                    -- 3. 使用效果（"使用："开头）
                    local isSetBonus = string.find(text, "套装") or string.find(text, "Set:")
                    local isEquipBonus = string.find(text, "装备：") or string.find(text, "Equip:")
                    local isUseEffect = string.find(text, "使用：") or string.find(text, "Use:")
                    
                    if not isSetBonus and not isEquipBonus and not isUseEffect then
                        enchantName = text
                        if DEBUG_MODE then
                            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00找到附魔/强化: " .. enchantName .. "|r")
                        end
                        break
                    end
                end
            end
        end
    end
    
    -- 如果找到附魔，保存到缓存
    if enchantName and enchantName ~= "" and itemLink then
        local cacheKey = GetItemCacheKey(itemLink)
        if cacheKey then
            -- 静默保存到缓存，不打印提示
            S_ItemTip_EnchantCache[cacheKey] = {
                enchantName = enchantName,
                timestamp = time()
            }
        end
        return enchantName
    end
    
    return nil
end

-- 获取附魔名称（优先从缓存，否则扫描）
local function GetEnchantName(itemLink, unit, slot)
    if not itemLink then return nil end
    
    local cacheKey = GetItemCacheKey(itemLink)
    
    -- 1. 先查缓存（兼容旧格式）
    if cacheKey and S_ItemTip_EnchantCache[cacheKey] then
        local cached = S_ItemTip_EnchantCache[cacheKey]
        -- 兼容旧格式（字符串）和新格式（表）
        if type(cached) == "table" then
            return cached.enchantName
        else
            return cached
        end
    end
    
    -- 2. 如果没有缓存，尝试扫描
    if unit and slot then
        local enchantName = ScanAndCacheEnchant(unit, slot, itemLink)
        if enchantName then
            return enchantName
        end
    end
    
    -- 3. 如果扫描不到，就不显示（即使有附魔ID）
    -- 因为可能是临时附魔或者其他原因导致无法获取名称
    return nil
end

--显示附魔图标
local function ShowEnchant(parentFrame, itemLink, anchorFrame, slotFrame)
    if not itemLink then 
        return 0 
    end
    
    local unit = parentFrame.currentUnit or "target"
    
    -- 检查该部位是否可以附魔
    if not EnchantParts[slotFrame.slotId] then
        return 0
    end
    
    -- 检查是否有附魔ID
    local enchantID = GetEnchantIDFromLink(itemLink)
    
    -- 如果有附魔ID（不为0），就显示图标
    if enchantID and enchantID ~= 0 then
        -- 尝试从tooltip获取附魔名称
        local enchantName = GetEnchantName(itemLink, unit, slotFrame.slotId)
        
        -- 如果扫描不到名称，就显示附魔ID
        if not enchantName then
            enchantName = "附魔 ID: " .. enchantID
        end
        local icon = GetIconFrame(parentFrame)
        
        -- 根据附魔效果类型设置不同的图标和颜色
        local lowerName = string.lower(enchantName)
        
        if string.find(lowerName, "抗性") or string.find(lowerName, "resist") then
            -- 抗性附魔：紫色
            icon.bg:SetVertexColor(0.8, 0.3, 1)
            icon.texture:SetTexture("Interface\\Icons\\Spell_Holy_PrayerOfHealing")
        elseif string.find(lowerName, "伤害") or string.find(lowerName, "damage") or 
               string.find(lowerName, "打击") or string.find(lowerName, "crusader") or
               string.find(lowerName, "十字军") then
            -- 伤害/攻击附魔：红色
            icon.bg:SetVertexColor(1, 0.3, 0.3)
            icon.texture:SetTexture("Interface\\Icons\\Ability_Warrior_DecisiveStrike")
        elseif string.find(lowerName, "治疗") or string.find(lowerName, "healing") or
               string.find(lowerName, "生命") or string.find(lowerName, "health") then
            -- 治疗/生命附魔：绿色
            icon.bg:SetVertexColor(0, 1, 0.5)
            icon.texture:SetTexture("Interface\\Icons\\Spell_Holy_GreaterHeal")
        elseif string.find(lowerName, "法力") or string.find(lowerName, "mana") or
               string.find(lowerName, "智力") or string.find(lowerName, "intellect") or
               string.find(lowerName, "精神") or string.find(lowerName, "spirit") then
            -- 法力/智力附魔：蓝色
            icon.bg:SetVertexColor(0.3, 0.5, 1)
            icon.texture:SetTexture("Interface\\Icons\\Spell_Frost_FrostArmor")
        elseif string.find(lowerName, "力量") or string.find(lowerName, "strength") or
               string.find(lowerName, "敏捷") or string.find(lowerName, "agility") or
               string.find(lowerName, "耐力") or string.find(lowerName, "stamina") then
            -- 属性附魔：黄色
            icon.bg:SetVertexColor(1, 1, 0)
            icon.texture:SetTexture("Interface\\Icons\\Spell_Holy_WordFortitude")
        elseif string.find(lowerName, "防御") or string.find(lowerName, "defense") or
               string.find(lowerName, "护甲") or string.find(lowerName, "armor") then
            -- 防御附魔：灰色
            icon.bg:SetVertexColor(0.7, 0.7, 0.7)
            icon.texture:SetTexture("Interface\\Icons\\Spell_Holy_DevotionAura")
        else
            -- 其他附魔：白色
            icon.bg:SetVertexColor(1, 1, 1)
            icon.texture:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
        end
        
        icon.title = enchantName
        icon.enchantID = GetEnchantIDFromLink(itemLink)
        icon.itemLink = nil
        icon.spellID = nil
        icon:ClearAllPoints()
        icon:SetPoint("LEFT", anchorFrame, "RIGHT", 15, 0)
        icon:Show()
        return 28
    end
    
    -- 没有附魔，不显示任何图标
    return 0
end

-- 延迟扫描附魔的函数
local function DelayedScanEnchants(unit)
    local frame = S_ItemTip_InspectFrame
    if not frame or not frame:IsShown() then
        return
    end
    
    -- 先隐藏所有图标
    HideAllIcons(frame)
    
    -- 为每个槽位显示附魔图标
    local maxWidth = frame:GetWidth()
    local enchantCount = 0
    for i, slotFrame in ipairs(frame.slotFrames) do
        if slotFrame.itemLink then
            local iconWidth = ShowEnchant(frame, slotFrame.itemLink, slotFrame.itemName, slotFrame)
            if iconWidth > 0 then
                enchantCount = enchantCount + 1
            end
            -- 增加右边距以确保图标不会超出边框
            local totalWidth = 15 + 32 + 24 + slotFrame.itemName:GetWidth() + iconWidth + 25
            if totalWidth > maxWidth then
                maxWidth = totalWidth
            end
        else
            -- 如果没有物品链接，确保该槽位的图标被隐藏
            if frame["gemIcon"..i] then
                frame["gemIcon"..i]:Hide()
            end
        end
    end
    
    -- 调整框架宽度（增加额外边距）
    if maxWidth > frame:GetWidth() then
        frame:SetWidth(maxWidth + 10)
    end
end

--Hook 到装备更新函数
local originalUpdateFrame = S_ItemTip_UpdateFrame
function S_ItemTip_UpdateFrame(unit)
    if originalUpdateFrame then
        originalUpdateFrame(unit)
    end
    
    local frame = S_ItemTip_InspectFrame
    if not frame or not frame:IsShown() then
        return
    end
    
    -- 保存当前单位
    frame.currentUnit = unit
    
    -- 如果是查看其他玩家，延迟扫描附魔（等待数据加载）
    if unit ~= "player" then
        -- 延迟0.5秒后扫描
        local timer = 0
        local delayFrame = CreateFrame("Frame")
        delayFrame:SetScript("OnUpdate", function()
            timer = timer + arg1
            if timer > 0.5 then
                DelayedScanEnchants(unit)
                delayFrame:SetScript("OnUpdate", nil)
            end
        end)
    else
        -- 查看自己时立即扫描
        DelayedScanEnchants(unit)
    end
end



-- 显示缓存的附魔列表
SLASH_ENCHANTCACHE1 = "/enchant"
SlashCmdList["ENCHANTCACHE"] = function(msg)
    if msg == "cache" or msg == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00=== 已缓存的附魔 ===|r")
        local count = 0
        for cacheKey, data in pairs(S_ItemTip_EnchantCache) do
            count = count + 1
            -- 兼容旧格式（字符串）和新格式（表）
            local enchantName = type(data) == "table" and data.enchantName or data
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[" .. cacheKey .. "] " .. enchantName .. "|r")
        end
        if count == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000暂无缓存的附魔|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00共缓存了 " .. count .. " 个附魔|r")
        end
    elseif msg == "clear" then
        S_ItemTip_EnchantCache = {}
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00附魔缓存已清空|r")
    elseif msg == "debug" then
        DEBUG_MODE = not DEBUG_MODE
        if DEBUG_MODE then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00调试模式已开启|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00调试模式已关闭|r")
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00用法:|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/enchant - 查看已缓存的附魔|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/enchant cache - 查看已缓存的附魔|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/enchant clear - 清空附魔缓存|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/enchant debug - 开启/关闭调试模式|r")
    end
end



-- 启动时清理过期缓存
CleanOldCache()

DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00S_ItemTip: 附魔扫描功能已加载|r")
DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00使用 /enchant 查看已缓存的附魔|r")
DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00使用 /enchant clear 清空附魔缓存|r")

-- 显示缓存统计
local cacheCount = 0
for _ in pairs(S_ItemTip_EnchantCache) do
    cacheCount = cacheCount + 1
end

if cacheCount > 0 then
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00已加载 " .. cacheCount .. " 个附魔缓存|r")
end
