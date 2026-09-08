-- 显示全身可附魔部位的工具

-- 装备槽位ID与名称的映射表
local slotNames = {
    [1] = "头部",
    [2] = "项链",
    [3] = "肩膀",
    [4] = "衬衫",
    [5] = "胸部",
    [6] = "腰部",
    [7] = "腿部",
    [8] = "脚部",
    [9] = "手腕",
    [10] = "手套",
    [11] = "戒指1",
    [12] = "戒指2",
    [13] = "饰品1",
    [14] = "饰品2",
    [15] = "背部",
    [16] = "主手",
    [17] = "副手",
    [18] = "远程",
    [19] = "弹药"
}

-- 可附魔的部位ID
local enchantableSlots = {
    9,3
}

function ShowAllEnchants()
    print("===== 全身可附魔部位信息 ====")
    
    -- 先检查武器附魔
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, 
          hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID = GetWeaponEnchantInfo()
    
    if hasMainHandEnchant then
        print("主手武器附魔ID: " .. (mainHandEnchantID or "未知"))
    end
    
    if hasOffHandEnchant then
        print("副手武器附魔ID: " .. (offHandEnchantID or "未知"))
    end
    
    -- 遍历所有可附魔部位，获取物品链接和工具提示信息
    for _, slotID in ipairs(enchantableSlots) do
        local itemLink = GetInventoryItemLink("player", slotID)
        if itemLink then
            -- 清除当前提示
            ClearCursor()
            GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
            GameTooltip:ClearLines()
            
            -- 获取物品信息
            GameTooltip:SetInventoryItem("player", slotID)
            GameTooltip:Show()
            
            local itemName = GetInventoryItemLink("player", slotID)
            print(slotNames[slotID] .. ": " .. (itemName or "空"))
            
            -- 获取工具提示文本
            for i = 1, GameTooltip:NumLines() do
                local line = _G["GameTooltipTextLeft"..i]
                if line and line:GetText() then
                    local text = line:GetText()
                    -- 显示所有包含可能是附魔信息的行
                    print("  " .. text)
                end
            end
        end
    end
    
    GameTooltip:Hide()
    print("==========================")
end

-- 创建一个聊天命令
SLASH_SHOWALLENCHANTS1 = "/showenchants";
SlashCmdList["SHOWALLENCHANTS"] = function()
    ShowAllEnchants()
end

print("输入 /showenchants 查看全身可附魔部位信息")