--由Sunelegy基于Shagu装备评分插件修改 20250210
--别特鸣谢：天乖乖

lib = LibStub("LibItem-enUS-1.0")
local libLevel = LibStub("LibItemLevel-1.0")
LibItem_Level = libLevel and libLevel.Item_Level or LibItem_Level or {}

local EquipSoltList = {
	INVTYPE_2HWEAPON,
	INVTYPE_BODY,
	INVTYPE_CHEST,
	INVTYPE_CLOAK,
	INVTYPE_FEET,
	INVTYPE_FINGER,
	INVTYPE_HAND,
	INVTYPE_HEAD,
	INVTYPE_HOLDABLE,
	INVTYPE_LEGS,
	INVTYPE_NECK,
	INVTYPE_RANGED,
	INVTYPE_RELIC,
	INVTYPE_ROBE,
	INVTYPE_SHIELD,
	INVTYPE_SHOULDER,
	INVTYPE_TABARD,
	INVTYPE_TRINKET,
	INVTYPE_WAIST,
	INVTYPE_WEAPON,
	INVTYPE_WEAPONMAINHAND,
	INVTYPE_WEAPONOFFHAND,
	INVTYPE_WRIST,
	"枪械",
	"弩",
	"魔杖",
	"投掷武器",
	"弹药",
}

local function IsEquip()
	if ItemRefTooltip:IsVisible() then
		for i = 2,5 do
			local EquipText = getglobal("ItemRefTooltipTextLeft"..i):GetText()
			for _, equip in pairs(EquipSoltList) do
				if EquipText == equip then
					return true
				end
			end
		end
	else
		for i = 2,5 do
			local EquipText = getglobal("GameTooltipTextLeft"..i):GetText()
			for _, equip in pairs(EquipSoltList) do
				if EquipText == equip then
					return true
				end
			end
		end	
	end
	
	return false
end

local function Add_ItemLevelLine(itemID, itemLevel)
	if not itemID then return end
	
	if IsEquip() then
		if itemLevel and itemLevel > 0 then
			if ItemRefTooltip:IsVisible() then
				ItemRefTooltip:AddLine("装备等级 " .. itemLevel, 1, 1, 0)
				ItemRefTooltip:Show()
			else
				GameTooltip:AddLine("装备等级 " .. itemLevel, 1, 1, 0)
				GameTooltip:Show()
			end
		else
			-- 调试信息：显示缺少装等数据的物品ID
			if ItemRefTooltip:IsVisible() then
				ItemRefTooltip:AddLine("装备等级 未知 (ID:" .. itemID .. ")", 0.7, 0.7, 0.7)
				ItemRefTooltip:Show()
			else
				GameTooltip:AddLine("装备等级 未知 (ID:" .. itemID .. ")", 0.7, 0.7, 0.7)
				GameTooltip:Show()
			end
		end
	end
end

ItemSocre = CreateFrame("Frame" , "ItemSocreTooltip", GameTooltip)
ItemSocre:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
ItemSocre:SetScript("OnEvent", function()
	-- 只有当 GameTooltip 已经显示时才添加装等信息
	if GameTooltip:IsVisible() then
		local score = this:ScanUnit("mouseover")
		if score and score > 0 then
			GameTooltip:AddLine("装备等级 " .. score, 1, 1, 0)
			GameTooltip:Show()
		end
	end
end)

ItemSocre:SetScript("OnShow", function()
	if GameTooltip.itemLink then
		local _, _, itemID = string.find(GameTooltip.itemLink, "item:(%d+):%d+:%d+:%d+")
		local itemLevel = LibItem_Level[tonumber(itemID)] or 0
		Add_ItemLevelLine(itemID, itemLevel)
	end
end)

ItemSocre:SetScript("OnHide", function()
	GameTooltip.itemLink = nil
end)

hooksecurefunc("SetItemRef", function(link, button)
	if ItemRefTooltip:IsVisible() then
		local _, _, itemID = string.find(link, "item:(%d+):%d+:%d+:%d+")
		local itemLevel = LibItem_Level[tonumber(itemID)] or 0
		Add_ItemLevelLine(itemID, itemLevel)
	end
end)

if IsAddOnLoaded("StatCompare") then
	StatCompareSelfFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	StatCompareSelfFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
	StatCompareSelfFrame:RegisterEvent("BAG_UPDATE")
	StatCompareSelfFrame:SetScript("OnEvent", function()
		local score = ItemSocre:ScanUnit("player")
		if score and score > 0 then
			PlayerItemGS:SetText("装备等级: " .. score)
			PlayerItemGS:SetTextColor(1, 1, 0)
		else
			PlayerItemGS:SetText()
		end
	end)
end

-- 增加AtlasLoot装备装等显示支持
if AtlasLootItem_OnEnter then
    local Hook_AtlasLootItem_OnEnter = AtlasLootItem_OnEnter
    AtlasLootItem_OnEnter = function()
        Hook_AtlasLootItem_OnEnter() -- 调用原始函数
        local sid = this.itemID
        if sid == 0 then
            return
        end
        
        -- 处理物品ID格式（ AtlasLoot可能的ID前缀）
        local st = string.sub(sid, 1, 1)
        local itemID = sid
        if st == "e" then
            -- 附魔类型不处理装等
            return
        elseif st == "s" then
            -- 配方类物品，尝试获取制作出的物品ID
            if GetSpellInfoVanillaDB then
                itemID = GetSpellInfoVanillaDB["craftspells"][tonumber(string.sub(sid, 2))]["craftItem"]
            else
                return
            end
        end
        
        -- 确定使用的tooltip
        local tooltip = AtlasLootTooltip
        if st == "s" then
            tooltip = AtlasLootTooltip2
        end
        
        -- 获取并显示装等
        local itemLevel = LibItem_Level[tonumber(itemID)] or 0
        -- 如果初始获取失败，尝试通过物品名称匹配
        if itemLevel == 0 then
            local itemName = GetItemInfo(itemID)
            if itemName then
                for realID, engName in pairs(lib.Item_enUS) do
                    if engName == itemName then
                        itemLevel = LibItem_Level[realID] or 0
                        break
                    end
                end
            end
        end
        
        -- 只有装备且有有效装等时才显示
        if itemLevel > 0 then
            -- 避免重复添加
            local lineAdded = false
            for i = 1, tooltip:NumLines() do
                local line = _G[tooltip:GetName().."TextLeft"..i]
                if line and line:GetText() and string.find(line:GetText(), "装备等级") then
                    lineAdded = true
                    break
                end
            end
            if not lineAdded then
                tooltip:AddLine("装备等级 " .. itemLevel, 1, 1, 0)
                tooltip:Show()
            end
        end
    end
end

ItemSocreHookInspectUnit = InspectUnit
function InspectUnit(unit)
	ItemSocreHookInspectUnit(unit)
	local score = ItemSocre:ScanUnit("target")
	if IsAddOnLoaded("StatCompare") then
		if score and score > 0 then
			TargetItemGS:SetText("装备等级 " .. score)
			TargetItemGS:SetTextColor(1, 1, 0)
		else
			TargetItemGS:SetText()
		end
	end
end

function ItemSocre:Calculate(rarity, ilvl)
	if not rarity then rarity = 0 end
	
	local qualityScale = 1
	if rarity == 5 then
		qualityScale = 1.3
	elseif rarity == 4 then
		qualityScale = 1.0
	elseif rarity == 3 then
		qualityScale = 0.85
	elseif rarity == 2 then
		qualityScale = 0.6
	elseif rarity == 1 then
		qualityScale = 0.25
	end
	
	return ilvl * qualityScale
end

function ItemSocre:ScanUnit(unit)
    if not UnitIsPlayer(unit) then return nil end

    local score = 0
    local _, class = UnitClass(unit)
    local isHunter = (class == "HUNTER")
    local hasMainHand = (GetInventoryItemLink(unit, 16) ~= nil)
    local hasOffhand = (GetInventoryItemLink(unit, 17) ~= nil)

    local slotCoefficients = {
        [1] = 1,
        [2] = 0.5625,
        [3] = 0.75,
        [5] = 1,
        [6] = 0.5625,
        [7] = 0.75,
        [8] = 0.75,
        [9] = 0.75,
        [10] = 0.75,
        [11] = 0.5625,
        [12] = 0.5625,
        [13] = 0.5625,
        [14] = 0.5625,
        [15] = 0.5625,
        [16] = 1,
        [17] = 1,
        [18] = 0.3164,
    }

    for i = 1, 19 do
        if i ~= 4 and i ~= 19 then
            local itemLink = GetInventoryItemLink(unit, i)
            if itemLink then
                local _, _, itemID = string.find(itemLink, "item:(%d+):%d+:%d+:%d+")
                local itemLevel = LibItem_Level[tonumber(itemID)] or 0
                local itemName, _, itemRarity = GetItemInfo(itemID)

                if itemLevel == 0 then              
                    for realID, engName in pairs(lib.Item_enUS) do
                        if engName == itemName then
                            local newItemLevel = LibItem_Level[realID] or 0
                            itemLevel = newItemLevel
                            break
                        end
                    end
                end

                local coef = slotCoefficients[i] or 1

                if i == 16 then
					local _, _, _, _, _, _, _, equipSlot = GetItemInfo(itemID)
					local itemName = GetItemInfo(itemID)
					if equipSlot == "INVTYPE_2HWEAPON" then
                        coef = isHunter and 1 or 2.6836
                    else
                        coef = isHunter and 0.5 or 1.6836
                    end
                elseif i == 17 then
                    coef = isHunter and 0.5 or 1
                elseif i == 18 then
                    coef = isHunter and 2 or 0.3164
                end

                local itemScore = ItemSocre:Calculate(itemRarity, itemLevel)
                if itemScore then
                    score = score + (itemScore * coef)
                end
            end
        end
    end

    local divisor = 17
    score = tonumber(string.format("%0.1f", (score / divisor) * 1.355))
  
    if score ~= 0 then return score else return nil end
end

function ItemSocre:GetItemLinkByName(name)
	for itemID = 1, 25818 do
		local itemName, hyperLink, itemQuality = GetItemInfo(itemID)
		if (itemName and itemName == name) then
			local _, _, _, hex = GetItemQualityColor(tonumber(itemQuality))
			return hex.. "|H"..hyperLink.."|h["..itemName.."]|h|r"
		end
	end
end

local HookSetBagItem = GameTooltip.SetBagItem
function GameTooltip.SetBagItem(self, container, slot)
	GameTooltip.itemLink = GetContainerItemLink(container, slot)
	_, GameTooltip.itemCount = GetContainerItemInfo(container, slot)
	return HookSetBagItem(self, container, slot)
end

local HookSetQuestLogItem = GameTooltip.SetQuestLogItem
function GameTooltip.SetQuestLogItem(self, itemType, index)
	GameTooltip.itemLink = GetQuestLogItemLink(itemType, index)
	if not GameTooltip.itemLink then return end
	return HookSetQuestLogItem(self, itemType, index)
end

local HookSetQuestItem = GameTooltip.SetQuestItem
function GameTooltip.SetQuestItem(self, itemType, index)
	GameTooltip.itemLink = GetQuestItemLink(itemType, index)
	return HookSetQuestItem(self, itemType, index)
end

local HookSetLootItem = GameTooltip.SetLootItem
function GameTooltip.SetLootItem(self, slot)
	GameTooltip.itemLink = GetLootSlotLink(slot)
	HookSetLootItem(self, slot)
end

local HookSetInboxItem = GameTooltip.SetInboxItem
function GameTooltip.SetInboxItem(self, mailID, attachmentIndex)
	local itemName, itemTexture, inboxItemCount, inboxItemQuality = GetInboxItem(mailID)
	GameTooltip.itemLink = ItemSocre:GetItemLinkByName(itemName)
	return HookSetInboxItem(self, mailID, attachmentIndex)
end

local HookSetInventoryItem = GameTooltip.SetInventoryItem
function GameTooltip.SetInventoryItem(self, unit, slot)
	GameTooltip.itemLink = GetInventoryItemLink(unit, slot)
	return HookSetInventoryItem(self, unit, slot)
end

local HookSetLootRollItem = GameTooltip.SetLootRollItem
function GameTooltip.SetLootRollItem(self, id)
	GameTooltip.itemLink = GetLootRollItemLink(id)
	return HookSetLootRollItem(self, id)
end

local HookSetMerchantItem = GameTooltip.SetMerchantItem
function GameTooltip.SetMerchantItem(self, merchantIndex)
	GameTooltip.itemLink = GetMerchantItemLink(merchantIndex)
	return HookSetMerchantItem(self, merchantIndex)
end

local HookSetCraftItem = GameTooltip.SetCraftItem
function GameTooltip.SetCraftItem(self, skill, slot)
	GameTooltip.itemLink = GetCraftReagentItemLink(skill, slot)
	return HookSetCraftItem(self, skill, slot)
end

local HookSetCraftSpell = GameTooltip.SetCraftSpell
function GameTooltip.SetCraftSpell(self, slot)
	GameTooltip.itemLink = GetCraftItemLink(slot)
	return HookSetCraftSpell(self, slot)
end

local HookSetTradeSkillItem = GameTooltip.SetTradeSkillItem
function GameTooltip.SetTradeSkillItem(self, skillIndex, reagentIndex)
	if reagentIndex then
		GameTooltip.itemLink = GetTradeSkillReagentItemLink(skillIndex, reagentIndex)
	else
		GameTooltip.itemLink = GetTradeSkillItemLink(skillIndex)
	end
	return HookSetTradeSkillItem(self, skillIndex, reagentIndex)
end

local HookSetAuctionItem = GameTooltip.SetAuctionItem
function GameTooltip.SetAuctionItem(self, atype, index)
  local itemName, _, itemCount = GetAuctionItemInfo(atype, index)
  GameTooltip.itemCount = itemCount
  GameTooltip.itemLink = ItemSocre:GetItemLinkByName(itemName)
  return HookSetAuctionItem(self, atype, index)
end

local HookSetAuctionSellItem = GameTooltip.SetAuctionSellItem
function GameTooltip.SetAuctionSellItem(self)
	local itemName, _, itemCount = GetAuctionSellItemInfo()
	GameTooltip.itemCount = itemCount
	GameTooltip.itemLink = ItemSocre:GetItemLinkByName(itemName)
	return HookSetAuctionSellItem(self)
end

local HookSetTradePlayerItem = GameTooltip.SetTradePlayerItem
function GameTooltip.SetTradePlayerItem(self, index)
	GameTooltip.itemLink = GetTradePlayerItemLink(index)
	return HookSetTradePlayerItem(self, index)
end

local HookSetTradeTargetItem = GameTooltip.SetTradeTargetItem
function GameTooltip.SetTradeTargetItem(self, index)
	GameTooltip.itemLink = GetTradeTargetItemLink(index)
	return HookSetTradeTargetItem(self, index)
end