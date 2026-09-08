--   ##################
--  # Healing Helper #
-- #   Functions    #
--##################

function Heart_HealMostWoundedMS(profileName)
    -- 治疗最重伤员团刷版本
    -- profileName: 玩家设置的方案名称
    
    -- 首先判断职业是否为牧师
    if C_my_class ~= C_Priest then
        -- 如果不是牧师，直接调用原始函数
        return Heart_HealMostWounded(profileName, nil)
    end
    
    -- 检查方案是否存在
    if not Heart_Config["classes"][profileName] then
        return
    end
    
    -- 检查方案中是否包含神圣新星或治疗祷言
    local hasNovaOrPrayer = false
    local originalProfile = Heart_Config["classes"][profileName]
    
    for percent, data in originalProfile do
        if data["Spell"] == C_Holy_nova or data["Spell"] == C_Prayer_of_healing then
            hasNovaOrPrayer = true
            break
        end
    end
    
    -- 如果没有团刷技能，直接调用原始函数
    if not hasNovaOrPrayer then
        return Heart_HealMostWounded(profileName, nil)
    end
    
    -- 创建_S方案（只包含神圣新星）
    local profileNameS = profileName .. "_S"
    Heart_Config["classes"][profileNameS] = {}
    for percent, data in originalProfile do
        if data["Spell"] == C_Holy_nova then
            Heart_Config["classes"][profileNameS][percent] = {
                ["Scale"] = data["Scale"],
                ["Spell"] = data["Spell"],
                ["Rank"] = data["Rank"],
                ["Attachment"] = data["Attachment"]
            }
        end
    end
    
    -- 创建_T方案（只包含治疗祷言）
    local profileNameT = profileName .. "_T"
    Heart_Config["classes"][profileNameT] = {}
    for percent, data in originalProfile do
        if data["Spell"] == C_Prayer_of_healing then
            Heart_Config["classes"][profileNameT][percent] = {
                ["Scale"] = data["Scale"],
                ["Spell"] = data["Spell"],
                ["Rank"] = data["Rank"],
                ["Attachment"] = data["Attachment"]
            }
        end
    end
    
    -- 创建_D方案（不包含团刷技能）
    local profileNameD = profileName .. "_D"
    if not Heart_Config["classes"][profileNameD] then
        Heart_Config["classes"][profileNameD] = {}
        for percent, data in originalProfile do
            if data["Spell"] ~= C_Holy_nova and data["Spell"] ~= C_Prayer_of_healing then
                Heart_Config["classes"][profileNameD][percent] = {
                    ["Scale"] = data["Scale"],
                    ["Spell"] = data["Spell"],
                    ["Rank"] = data["Rank"],
                    ["Attachment"] = data["Attachment"]
                }
            end
        end
    end
    
    -- 判断小队内是否有三名或以上玩家血线符合要求
    local useHolyNovaScheme = false
    local usePrayerScheme = false
    local lowHealthPartyMembers = {}
    local partyMembers = GetNumPartyMembers()
    
    -- 检查玩家自己
    if Heart_CanHeal("player") then
        local healthPercent = UnitHealth("player") / UnitHealthMax("player")
        table.insert(lowHealthPartyMembers, {unit = "player", healthPercent = healthPercent})
    end
    
    -- 检查队友
    for i = 1, partyMembers do
        local unit = "party" .. i
        if Heart_CanHeal(unit) then
            local healthPercent = UnitHealth(unit) / UnitHealthMax(unit)
            table.insert(lowHealthPartyMembers, {unit = unit, healthPercent = healthPercent})
        end
    end
    
    -- 排序血量百分比（从高到低）
    table.sort(lowHealthPartyMembers, function(a, b) return a.healthPercent > b.healthPercent end)
    
    -- 计算UnitXP_SP3是否有效
    local UnitXP_SP3 = pcall(UnitXP, "nop", "nop")
    
    -- 输出调试信息：显示所有可治疗的队友状态
    -- Print("[Heart调试] 开始检查团刷条件...")
    -- Print("[Heart调试] 可治疗队友总数: " .. table.getn(lowHealthPartyMembers))
    
    for i = 1, table.getn(lowHealthPartyMembers) do
        local unit = lowHealthPartyMembers[i].unit
        local name = UnitName(unit)
        local healthPercent = lowHealthPartyMembers[i].healthPercent * 100
        local healthCurrent = UnitHealth(unit)
        local healthMax = UnitHealthMax(unit)
        local healthMissing = healthMax - healthCurrent
        
        -- Print("[Heart调试] 目标: " .. name .. " 血量: " .. math.floor(healthPercent) .. "% 缺少血量: " .. healthMissing)
    end
    
    -- 分别获取神圣新星和治疗祷言的血线设置，并转换为0-1的小数形式
    local holyNovaThreshold = 0
    local prayerOfHealingThreshold = 0
    
    for percent, data in originalProfile do
        if data["Spell"] == C_Holy_nova then
            holyNovaThreshold = percent / 100
        elseif data["Spell"] == C_Prayer_of_healing then
            prayerOfHealingThreshold = percent / 100
        end
    end
    
    -- 检查是否满足使用团刷技能的条件
    local useHolyNova = (holyNovaThreshold > 0)
    local usePrayerOfHealing = (prayerOfHealingThreshold > 0)
    
    -- 检查是否有至少3个队友血量符合要求且距离合适
    if table.getn(lowHealthPartyMembers) >= 3 then
        
        -- 检查距离
        local validCount = 0
        local validCountNova = 0
        local validCountPrayer = 0
        local maxDistanceNova = 7.5
        local maxDistancePrayer = 27.5
        
        -- 输出血线设置信息
        -- Print("[Heart调试] 神圣新星血线设置: " .. (holyNovaThreshold > 0 and math.floor(holyNovaThreshold * 100) or "未设置") .. "%  治疗祷言血线设置: " .. (prayerOfHealingThreshold > 0 and math.floor(prayerOfHealingThreshold * 100) or "未设置") .. "%")
        
        for i = 1, table.getn(lowHealthPartyMembers) do
            local unit = lowHealthPartyMembers[i].unit
            local name = UnitName(unit)
            local healthPercent = lowHealthPartyMembers[i].healthPercent * 100
            local healthCurrent = UnitHealth(unit)
            local healthMax = UnitHealthMax(unit)
            local healthMissing = healthMax - healthCurrent
            local distance = "未知"
            local inRangeNova = true
            local inRangePrayer = true
            
            -- 计算距离
            if UnitXP_SP3 and UnitExists(unit) then
                distance = UnitXP("distanceBetween", "player", unit) or "未知"
                if type(distance) == "number" then
                    if distance > maxDistanceNova then
                        inRangeNova = false
                    end
                    if distance > maxDistancePrayer then
                        inRangePrayer = false
                    end
                end
            end
            
            -- 分别检查是否符合各团刷技能的条件
            local meetsNovaCondition = (useHolyNova and inRangeNova and lowHealthPartyMembers[i].healthPercent <= holyNovaThreshold)
            local meetsPrayerCondition = (usePrayerOfHealing and inRangePrayer and lowHealthPartyMembers[i].healthPercent <= prayerOfHealingThreshold)
            
            -- 基于第三高血量玩家的情况决定优先使用哪个团刷技能
            -- 如果有至少3个低血量队友，检查第三个队友的血线
            if table.getn(lowHealthPartyMembers) >= 3 and i == 1 then
                local thirdHighestHealth = lowHealthPartyMembers[3].healthPercent
                -- 这里只记录优先级信息，不修改meetsNovaCondition和meetsPrayerCondition变量
                -- 优先级判断在最终方案选择时进行
            end
            
            if meetsNovaCondition or meetsPrayerCondition then
                validCount = validCount + 1
            end
            
            if meetsNovaCondition then
                validCountNova = validCountNova + 1
            end
            
            if meetsPrayerCondition then
                validCountPrayer = validCountPrayer + 1
            end
            
            -- 输出详细调试信息
            -- Print("[Heart调试] 目标: " .. name .. " 血量: " .. math.floor(healthPercent) .. "% 缺少血量: " .. healthMissing .. " 距离: " .. tostring(distance) .. "码 | 符合神圣新星: " .. (meetsNovaCondition and "是" or "否") .. " 符合治疗祷言: " .. (meetsPrayerCondition and "是" or "否"))
            
            -- -- 显示基于排序的优先逻辑
            -- if table.getn(lowHealthPartyMembers) >= 3 and i == 1 then
            --     -- 数组是从高到低排序的，第三个元素是血量最低的玩家
            --     local lowestHealth = lowHealthPartyMembers[3].healthPercent
            --     local priorityInfo = ""
            --     -- 比较两个技能的血线设置，血线设置低的技能优先级更高
            --     if holyNovaThreshold < prayerOfHealingThreshold then
            --         priorityInfo = "神圣新星血线设置(" .. math.floor(holyNovaThreshold * 100) .. "%)低于治疗祷言(" .. math.floor(prayerOfHealingThreshold * 100) .. "%)，神圣新星优先级更高"
            --     else
            --         priorityInfo = "治疗祷言血线设置(" .. math.floor(prayerOfHealingThreshold * 100) .. "%)低于神圣新星(" .. math.floor(holyNovaThreshold * 100) .. "%)，治疗祷言优先级更高"
            --     end
            --     Print("[Heart调试] " .. priorityInfo)
            -- end
        end
        
        -- Print("[Heart调试] 有效目标总数: " .. validCount .. " 神圣新星有效: " .. validCountNova .. " 治疗祷言有效: " .. validCountPrayer)
        
        -- 分别判断神圣新星和治疗祷言的条件是否满足
        if validCountNova >= 3 then
            useHolyNovaScheme = true
            -- Print("[Heart调试] 满足神圣新星使用条件")
        end
        
        if validCountPrayer >= 3 then
            usePrayerScheme = true
            -- Print("[Heart调试] 满足治疗祷言使用条件")
        end
    end
    
    -- 根据判断结果执行相应的治疗函数
    local finalDecision = "使用单体方案 (" .. profileNameD .. ")"
    local selectedProfile = profileNameD
    
    -- 判断是否同时满足两个团刷技能的条件
    if useHolyNovaScheme and usePrayerScheme then
        -- 检查移动状态，移动时优先使用神圣新星
        if MPPlayerIsMoving then
            -- 移动状态下优先使用神圣新星
            finalDecision = "移动状态下，优先使用神圣新星方案 (" .. profileNameS .. ")"
            selectedProfile = profileNameS
        else
            -- 比较两个技能的血线设置，血线设置低的技能优先级更高
            if holyNovaThreshold < prayerOfHealingThreshold then
                -- 神圣新星血线设置更低，优先级更高
                finalDecision = "同时满足两个团刷技能条件，神圣新星血线设置(" .. math.floor(holyNovaThreshold * 100) .. "%)低于治疗祷言(" .. math.floor(prayerOfHealingThreshold * 100) .. "%)，优先使用神圣新星方案 (" .. profileNameS .. ")"
                selectedProfile = profileNameS
            else
                -- 治疗祷言血线设置更低或相同，优先级更高
                finalDecision = "同时满足两个团刷技能条件，治疗祷言血线设置(" .. math.floor(prayerOfHealingThreshold * 100) .. "%)低于或等于神圣新星(" .. math.floor(holyNovaThreshold * 100) .. "%)，优先使用治疗祷言方案 (" .. profileNameT .. ")"
                selectedProfile = profileNameT
            end
        end
    elseif useHolyNovaScheme then
        finalDecision = "使用神圣新星方案 (" .. profileNameS .. ")"
        selectedProfile = profileNameS
    elseif usePrayerScheme then
        -- 检查移动状态，移动时不使用治疗祷言
        if MPPlayerIsMoving then
            finalDecision = "移动状态下，不使用治疗祷言，使用单体方案 (" .. profileNameD .. ")"
            selectedProfile = profileNameD
        else
            finalDecision = "使用治疗祷言方案 (" .. profileNameT .. ")"
            selectedProfile = profileNameT
        end
    end
    
    -- Print("[Heart调试] 最终决定: " .. finalDecision)
    
    return Heart_HealMostWounded(selectedProfile, nil)
end

function Heart_HealMostWounded(spell, rank)

	-- 治疗伤势最重的单位
	if (Heart_casting_spell) then
		if (Heart_Config["safe_cancel"] == 0 or Heart_GetOverheal() > Heart_Config["max_overheal"]) then
			SpellStopCasting()
		end
		return 1
	end
	if (not Heart_Spells) then
		Heart_UpdateSpells()
	end
	if (not ((rank and Heart_Spells[spell]) or (not rank and Heart_Config["classes"][spell]))) then
		-- 无法找到法术或职业
		return
	end
	if (rank and GetSpellCooldown(Heart_Spells[spell][rank]["ID"], BOOKTYPE_SPELL) ~= 0) then
		-- 法术正在冷却中
		return
	elseif (not rank) then
		local allcooldown = 1
		for thisclass, data in Heart_Config["classes"][spell] do
			-- 检查技能是否存在
			if Heart_Spells[data["Spell"]] and Heart_Spells[data["Spell"]][1] and Heart_Spells[data["Spell"]][1]["ID"] then
				if (GetSpellCooldown(Heart_Spells[data["Spell"]][1]["ID"], BOOKTYPE_SPELL) == 0) then
					allcooldown = nil
				end
			else
				-- 技能不存在，打印提示并跳过，限制最多显示5次
				Heart_missing_spell_warnings = Heart_missing_spell_warnings or 0
				if Heart_missing_spell_warnings < 5 then
					DEFAULT_CHAT_FRAME:AddMessage("[Heart Helper] 当前天赋下没有技能: " .. data["Spell"], 1, 0, 0)
					Heart_missing_spell_warnings = Heart_missing_spell_warnings + 1
				end
			end				
		end
		if (allcooldown) then
			-- 该职业所有法术都在冷却中
			return
		end
	end
	Heart_most_wounded_id = 1
	Heart_most_wounded = (Heart_most_wounded or {})
	C_UpdatePlayerData()
	
	local players = GetNumRaidMembers()
	local por = "raid"
	if (players == 0) then
		players = GetNumPartyMembers()
		por = "party"
		Heart_SetMostWoundedData("player")
		Heart_SetMostWoundedData("pet")
	end
	for a = 1, players do
		Heart_SetMostWoundedData(por .. a)
		Heart_SetMostWoundedData(por .. "pet" .. a)
	end

	-- 清除旧条目
	for id = Heart_most_wounded_id, table.getn(Heart_most_wounded) do
		Heart_most_wounded[id] = nil
	end

	-- 对列表进行排序
	table.sort(Heart_most_wounded, Heart_SortMostWoundedAlgorithm)

	-- 尝试按照正确的顺序治疗人员
	for id = 1, table.getn(Heart_most_wounded) do
		if (not Heart_target_last_target and UnitExists("target") and UnitIsFriend("player", "target")) then
			Heart_target_last_target = 1
			ClearTarget()
		end
		local unit = Heart_most_wounded[id]["Unit"]
		if (not rank) then
			-- 我们得到的是一个职业而不是一个法术
			if (Heart_HealUsingClass(unit, spell, Heart_most_wounded[id]["Heal"])) then
				if (Heart_target_last_target) then
					TargetLastTarget()
					Heart_target_last_target = nil
				end
				return 1
			end
		elseif ((not Heart_only_instant_spells or Heart_Spells[spell][rank]["CastTime"] == 0) and Heart_Heal(unit, spell, rank, Heart_most_wounded[id]["Heal"])) then
			-- 我们似乎正在治疗（至少客户端没有检测到错误）
			if (Heart_target_last_target) then
				TargetLastTarget()
				Heart_target_last_target = nil
			end
			Heart_only_instant_spells = nil
			return 1
		end
	end
	if (Heart_target_last_target) then
		TargetLastTarget()
		Heart_target_last_target = nil
	end
	Heart_only_instant_spells = nil
	return
end

function Heart_SortMostWoundedAlgorithm(a, b)
	-- 列表排序算法
	return (a["PriorityValue"] > b["PriorityValue"])
end

function Heart_SortAwaitingRez(a, b)
	-- 列表排序算法
	return (a["priority"] > b["priority"])
end

function Heart_SetMostWoundedData(unit)
	if ((Heart_soft_lock_player and Heart_soft_lock_player == unit) or not Heart_CanHeal(unit) or (string.find(unit, "pet") and UnitIsCharmed(unit) and Heart_Config["heal_charmed"] == 0)) then
		return
	end
	UnitXP_SP3 = pcall(UnitXP, "nop", "nop");
	if UnitXP_SP3 then
	-- 检查目标是否在视野内
	if UnitExists(unit) then
		-- 检查是否有障碍物卡视野
		local inSight = UnitXP("inSight", unit, "player")
		-- 仅当明确返回false时才跳过，空值时继续执行
		if inSight ~= nil and not inSight then
			-- 目标被障碍物遮挡，跳过
			return
		end
		
		-- 检查目标距离
		local distance = UnitXP("distanceBetween", "player", unit)
		-- 仅当获取到有效距离且超出范围时才跳过
		if distance ~= nil and distance > 40 then
			-- 目标距离超过40码，跳过
			return
		end
	end
end
	local healvalue = Heart_GetHealValue(unit)
	if (healvalue < UnitHealthMax(unit) * (1.0 - Heart_Config["min_heal_threshold"])) then
		return
	end
	local priority = Heart_GetPriority(unit)
	if (priority <= 0 or healvalue <= 0) then
		return
	end
	local priorityvalue
	if (Heart_Config["heal_strategy"] == 2) then
		-- 治疗剩余生命值百分比最低的
		priorityvalue = priority * (healvalue / UnitHealthMax(unit))
	elseif (Heart_Config["heal_strategy"] == 3) then
		-- 治疗失去生命值最多的
		priorityvalue = priority * healvalue
	else
		-- 治疗剩余生命值最少的（默认）
		local divideby = (UnitHealthMax(unit) - healvalue)
		if (divideby < 1) then
			divideby = 1
		end
		priorityvalue = priority * (666 / divideby)
	end
	Heart_most_wounded[Heart_most_wounded_id] = (Heart_most_wounded[Heart_most_wounded_id] or {})
	Heart_most_wounded[Heart_most_wounded_id]["Heal"] = healvalue
	Heart_most_wounded[Heart_most_wounded_id]["PriorityValue"] = priorityvalue
	Heart_most_wounded[Heart_most_wounded_id]["Unit"] = unit
	Heart_most_wounded_id = Heart_most_wounded_id + 1
end

function Heart_ScaleSpell(unit, spell, rank, heal)
	-- 缩放法术以恢复约100%的生命值
	if (Heart_Config["scale_spells"] == 0 or not unit or not spell or not rank or Heart_dont_scale[spell] or (Heart_dont_scale_hots[spell] and Heart_Config["scale_hots"]==0)) then
                return rank
	end
	if heal<0 then
		heal= heal*0.3
	end
	heal = heal * Heart_Config["heal_power"]
	
	while (rank > 1 and heal < Heart_GetSpellHealing(unit, spell, rank - 1)) do
		rank = rank - 1
	end
	return rank
end

function Heart_GetPriority(unit)
	-- 获取该单位的优先级
	local priority = 1
	if (GetNumRaidMembers() >0 and (not Heart_RaidUnitIsChecked(unit))) then
		-- 我们在团队中，这个单位没有被选中进行治疗
		-- 将优先级设置为"未选中优先级"
		priority = priority * Heart_Config["unchecked_priority"]
		-- 我们仍然要应用其他优先级
	end
	if (UnitIsUnit("player", unit)) then
		-- 我自己！
		priority = priority * Heart_Config["player_priority"]
	elseif (UnitInParty(unit) and not string.find(unit, "pet")) then
		-- 我的队伍成员
		priority = priority * Heart_Config["party_priority"]
	elseif (UnitInRaid(unit)) then
		-- 我的团队成员
		priority = priority * Heart_Config["raid_priority"]
	else
		-- 一个宠物(?)
		priority = priority * Heart_Config["pet_priority"]
	end
	if (not UnitIsUnit("player", unit)) then
		if (Heart_Config["shapeshifted_druids"] == 1 and UnitClass(unit) == C_Druid) then
			if (UnitPowerType(unit) == 0) then
				-- caster form
				priority = priority * Heart_Config["class_priority"][C_Druid];
			elseif (UnitPowerType(unit) == 1) then
				-- bear form
				priority = priority * Heart_Config["class_priority"][C_Warrior];
			else
				-- hopefully cat form
				priority = priority * Heart_Config["class_priority"][C_Rogue];
			end
		else
			priority = priority * Heart_Config["class_priority"][UnitClass(unit)];
		end
	end
	if (priority <= 0) then
		return 0
	end
	if (Heart_IsMT(unit)) then
	   priority = priority + Heart_Config["MT_priority"]
        end
	for buff, prioritychange in Heart_Config["buff_affect_priority"] do
		if (C_UnitGotBuff(unit, buff)) then
			priority = priority - prioritychange
		end
	end
	for debuff, prioritychange in Heart_Config["debuff_affect_priority"] do
		if (C_UnitGotDebuff(unit, debuff)) then
			priority = priority + prioritychange
		end
	end
	return priority
end

function Heart_GetSpellHealing(unit, spell, rank)
	-- 计算这个法术的治疗量
	if (not Heart_Spells) then
		Heart_UpdateSpells()
	end
	local healbonus = Heart_GetHealBonus(unit, spell, rank)
	if (spell == C_Regrowth) then
		healbonus = healbonus / 2
	end
	if (spell == C_Swiftmend) then
			local data = C_UnitGotBuff(unit, C_Rejuvenation)
			if (data) then
				local start, stop
				Heart_temp_table = (Heart_temp_table or {})
				Heart_temp_table2 = (Heart_temp_table2 or {})
				start, stop, Heart_temp_table[1], Heart_temp_table[2] = string.find(data["Text"], Heart_hot_search)
				for index, value in Heart_hot_text do
					Heart_temp_table2 = (Heart_temp_table2 or {})
					Heart_temp_table2[value] = Heart_temp_table[index] / 1.0
				end
				local heal = Heart_temp_table2["Heal"] * 5 + healbonus * 12 / Heart_bonus_instant_divide
				-- 添加调试信息
				-- Print("[Heart调试] 技能: " .. spell .. " 等级: " .. rank .. " 治疗量: " .. math.floor(heal) .. " 治疗加成应用量: " .. math.floor(healbonus * 12 / Heart_bonus_instant_divide) .. " 装备和附魔治疗总和: " .. (Heart_item_heal_bonus or 0))
				return heal, heal, heal, 0
			end
			data = C_UnitGotBuff(unit, C_Regrowth)
			-- if no reju then it eats regrowth if it's on the player
			if (data) then
				local start, stop
				Heart_temp_table = (Heart_temp_table or {})
				Heart_temp_table2 = (Heart_temp_table2 or {})
				start, stop, Heart_temp_table[1], Heart_temp_table[2] = string.find(data["Text"], Heart_hot_search)

				for index, value in Heart_hot_text do
					Heart_temp_table2 = (Heart_temp_table2 or {})
					Heart_temp_table2[value] = Heart_temp_table[index] / 1.0
				end
				local heal = Heart_temp_table2["Heal"] * 6 + healbonus * 15 / Heart_bonus_instant_divide
				-- 添加调试信息
				-- Print("[Heart调试] 技能: " .. spell .. " 等级: " .. rank .. " 治疗量: " .. math.floor(heal) .. " 治疗加成应用量: " .. math.floor(healbonus * 15 / Heart_bonus_instant_divide) .. " 装备和附魔治疗总和: " .. (Heart_item_heal_bonus or 0))
				return heal, heal, heal, 0
			end
		end

	local heal = (Heart_Spells[spell][rank]["Heal"] or 0)
	local healmin = (Heart_Spells[spell][rank]["HealMin"] or 0)
	local healmax = (Heart_Spells[spell][rank]["HealMax"] or 0)
	local hot = (Heart_Spells[spell][rank]["HealingOverTime"] or 0)
	local realcasttime = (Heart_Spells[spell][rank]["RealCastTime"] or 0)
	if (realcasttime > Heart_bonus_divide) then
		realcasttime = Heart_bonus_divide
	end
	local bonus = healbonus * realcasttime / Heart_bonus_divide
	if (C_player_in_combat) then
		heal = heal + healmin
	else
		heal = heal + healmax
	end
	heal = heal + bonus
	healmin = healmin + bonus
	healmax = healmax + bonus


	local hot_multiply = Heart_Config["hot_multiply"]
	if (C_player_in_combat) then
		hot_multiply = Heart_Config["hot_multiply_battle"]
	end
	hot = hot * hot_multiply
	local hot_bonus = 0
	local duration = (Heart_hot_duration[spell] or 0)
	
	-- 修复恢复技能的计算问题
	if (spell == C_Renew) then
		-- 即使没有从技能描述中提取到HealingOverTime值，也要确保有一个基础的hot值
		if (hot == 0) then
			-- 使用一个默认值作为基础hot值
			local default_hot_values = {
				[1] = 60,
				[2] = 85,
				[3] = 110,
				[4] = 145,
				[5] = 180,
				[6] = 225,
				[7] = 270,
				[8] = 325,
				[9] = 385,
				[10] = 450
			}
			hot = default_hot_values[rank] or 0
		end
	end
	
	if (hot > 0) then
		if (duration > Heart_bonus_instant_divide) then
			duration = Heart_bonus_instant_divide
		end
		hot_bonus = healbonus * duration / Heart_bonus_instant_divide
		hot = hot + hot_bonus
	end
	heal = heal + hot
	if (C_my_class == C_Paladin and (spell == C_Flash_of_light or spell == C_Holy_light) and C_UnitGotBuff("player", C_Divine_favor)) then
		-- 100%暴击几率
		heal = heal * Heart_critical_bonus
		healmin = healmin * Heart_critical_bonus
		healmax = healmax * Heart_critical_bonus
	end
	if (C_UnitGotBuff("player", C_Power_infusion)) then
		heal = heal * 1.2
		healmin = healmin * 1.2
		healmax = healmax * 1.2
	hot = hot * 1.2
	hot_bonus = hot_bonus * 1.2
	end
	-- 施法时间减益
	if (C_player_in_combat) then
		if C_UnitName(unit)~=nil and C_UnitName(unit)==Heart_Tank["Name"] then
			heal=heal-Heart_Spells[spell][rank]["CastTime"]*Heart_Config["MTCastTime_Debuff"]
		else 
			heal=heal-Heart_Spells[spell][rank]["CastTime"]*Heart_Config["CastTime_Debuff"]
		end
	end

	-- -- 添加调试信息，显示更详细的计算数据
	-- if (spell == C_Rejuvenation) then
	-- 	Print("[Heart调试] 技能: " .. spell .. " 等级: " .. rank .. " 总治疗量: " .. math.floor(heal) .. " (基础HOT: " .. math.floor(Heart_Spells[spell][rank]["HealingOverTime"] or 0) .. " 乘以: " .. hot_multiply .. " HOT治疗加成应用量: " .. math.floor(hot_bonus) .. " 总治疗加成: " .. math.floor(healbonus) .. " 装备和附魔治疗总和: " .. (Heart_item_heal_bonus or 0) .. ")")
	-- elseif (spell == C_Healing_touch) then
	-- 	-- 为治疗之触添加特殊的调试信息，显示casttime和实际法伤加成
	-- 	local casttime_bonus = healbonus * realcasttime / Heart_bonus_divide
	-- 	Print("[Heart调试] 技能: " .. spell .. " 等级: " .. rank .. " 治疗量: " .. math.floor(heal) .. " (最小: " .. math.floor(healmin) .. " 最大: " .. math.floor(healmax) .. " 施法时间: " .. realcasttime .. " 总治疗加成: " .. math.floor(healbonus) .. " 治疗加成应用量: " .. math.floor(casttime_bonus) .. " 装备和附魔治疗总和: " .. (Heart_item_heal_bonus or 0) .. ")")
	-- elseif (spell == C_Renew) then
	-- 	-- 为恢复技能添加调试信息
	-- 	Print("[Heart调试] 技能: " .. spell .. " 等级: " .. rank .. " 治疗量: " .. math.floor(heal) .. " (HOT: " .. math.floor(hot) .. " HOT治疗加成应用量: " .. math.floor(hot_bonus) .. " 总治疗加成: " .. math.floor(healbonus) .. " 持续时间: " .. duration .. " 装备和附魔治疗总和: " .. (Heart_item_heal_bonus or 0) .. ")")
	-- elseif (spell == C_Holy_nova or spell == C_Prayer_of_healing) then
	-- 	-- 为神圣新星和治疗祷言添加特殊调试信息，正确显示法伤加成
	-- 	local casttime_bonus = healbonus * realcasttime / Heart_bonus_divide
	-- 	Print("[Heart调试] 技能: " .. spell .. " 等级: " .. rank .. " 治疗量: " .. math.floor(heal) .. " (最小: " .. math.floor(healmin) .. " 最大: " .. math.floor(healmax) .. " HOT: " .. math.floor(hot) .. " 治疗加成应用量: " .. math.floor(casttime_bonus) .. " 装备和附魔治疗总和: " .. (Heart_item_heal_bonus or 0) .. ")")
	-- elseif (spell == C_Heal or spell == C_Lesser_heal or spell == C_Greater_heal or spell == C_Flash_heal) then
	-- 	-- 为普通治疗法术添加特殊调试信息，正确显示法伤加成
	-- 	local casttime_bonus = healbonus * realcasttime / Heart_bonus_divide
	-- 	Print("[Heart调试] 技能: " .. spell .. " 等级: " .. rank .. " 治疗量: " .. math.floor(heal) .. " (最小: " .. math.floor(healmin) .. " 最大: " .. math.floor(healmax) .. " HOT: " .. math.floor(hot) .. " 治疗加成应用量: " .. math.floor(casttime_bonus) .. " 装备和附魔治疗总和: " .. (Heart_item_heal_bonus or 0) .. ")")
	-- else
	-- 	Print("[Heart调试] 技能: " .. spell .. " 等级: " .. rank .. " 治疗量: " .. math.floor(heal) .. " (最小: " .. math.floor(healmin) .. " 最大: " .. math.floor(healmax) .. " HOT: " .. math.floor(hot) .. " HOT治疗加成应用量: " .. math.floor(hot_bonus) .. " 装备和附魔治疗总和: " .. (Heart_item_heal_bonus or 0) .. ")")
	-- end

	return heal, healmin, healmax, hot
end

function Heart_GetOverheal()


	-- 我们会过量治疗多少？
	local healingtarget = Heart_i_am_healing
	if (not healingtarget or not Heart_healing[healingtarget] or not Heart_healing[healingtarget][C_my_name]) then
		return 0
	end
	local unit = C_GetUnitID(healingtarget)
	if (not unit) then
		-- 嗯，这很奇怪
		return 0
	end
	local uhm = UnitHealthMax(unit)
	local uh = UnitHealth(unit)
	if (uhm == 100) then
		-- 可能是百分比而不是生命值
		uhm = uhm * UnitLevel(unit) * Heart_class_hp_per_level[UnitClass(unit)] / 100
		uh = uh * UnitLevel(unit) * Heart_class_hp_per_level[UnitClass(unit)] / 100
	end
	-- 当坦克治疗时，玩家将从持续治疗和其他治疗者那里获得多少治疗
	if (not Heart_healing[healingtarget][C_my_name]["TankHealing"]) then
		if (uh / uhm > Heart_Config["hot_heal_threshold"]) then
			uh = uh + Heart_GetHealingOverTime(unit)
		end
		uh = uh + Heart_GetOtherHealing(unit, Heart_healing[healingtarget][C_my_name]["TimeLeft"])
	end
	-- 然后看看我能治疗多少
	local heal = Heart_healing[healingtarget][C_my_name]["Heal"]
	if (heal == 0) then
		-- 防止无限循环
		heal = 1
	end
	local overheal = (uh + heal - uhm) / heal
	if (overheal > 1) then
		-- 由于持续治疗和其他治疗者的治疗，可能会获得超过100%的过量治疗 :o
		overheal = 1
	elseif (overheal < 0) then
		-- 治疗不足不影响我们 :)
		overheal = 0
	end
	return overheal
end

function Heart_GetHealValue(unit)
	-- 计算这个单位需要多少治疗量
	local hpmissing = UnitHealthMax(unit) - UnitHealth(unit)
	if (UnitHealthMax(unit) == 100) then
		-- 看起来我们不知道这个玩家的生命值
		hpmissing = hpmissing * UnitLevel(unit) * Heart_class_hp_per_level[UnitClass(unit)] / 100
	end
	local hot = Heart_GetHealingOverTime(unit)
	local other = Heart_GetOtherHealing(unit)
	return hpmissing - other - hot
end

function Heart_GetHealingOverTime(unit)
	-- 检查该玩家将获得多少持续治疗
	local hot = 0
	Heart_temp_table = (Heart_temp_table or {})
	Heart_temp_table2 = (Heart_temp_table2 or {})
	for buff, duration in Heart_hot_duration do
		local data = C_UnitGotBuff(unit, buff)
		if (data and data["Text"]) then
			local start, stop
			start, stop, Heart_temp_table[1], Heart_temp_table[2] = string.find(data["Text"], Heart_hot_search)
			if (start) then
				Heart_temp_table2["Heal"] = nil
				Heart_temp_table2["Interval"] = nil
				for index, value in Heart_hot_text do
					Heart_temp_table2[value] = (Heart_temp_table2[value] or 0) + Heart_temp_table[index]
				end
				if (Heart_temp_table2["Heal"] and Heart_temp_table2["Interval"]) then
					local timeleft = duration - data["Time"]
					if (timeleft > 0) then
						hot = hot + (timeleft * Heart_temp_table2["Heal"] / Heart_temp_table2["Interval"])
					end
				end
			end
		end
	end
	local hot_multiply = Heart_Config["hot_multiply"]
	if (C_player_in_combat) then
		hot_multiply = Heart_Config["hot_multiply_battle"]
	end
	hot = hot * hot_multiply
	return hot
end

function Heart_GetOtherHealing(unit, maxtimeleft)
	-- 获取其他治疗者正在治疗该单位的量
	local healing = 0
	local name = C_UnitName(unit)
	if (string.find(unit, "pet")) then
		-- pet
		if (unit == "pet") then
			name = C_UnitName("player") .. "-" .. name
		else
			name = C_UnitName(string.gsub(unit, "pet", "")) .. "-" .. name
		end
	end
	maxtimeleft = (maxtimeleft or 666)
	local hot_multiply = Heart_Config["hot_multiply"]
	if (C_player_in_combat) then
		hot_multiply = Heart_Config["hot_multiply_battle"]
	end
	if (Heart_healing[name]) then
		for healer, data in Heart_healing[name] do
			if (healer ~= C_my_name and Heart_healing[name][healer]["Status"] == "Active" and Heart_healing[name][healer]["TimeLeft"] < maxtimeleft) then
				healing = healing + Heart_healing[name][healer]["Heal"]
				healing = healing + Heart_healing[name][healer]["HealingOverTime"] * hot_multiply
			end
		end
	end
	return healing
end

function Heart_GetOtherRezing(player)
        local name = C_UnitName(player)
        if (Heart_healing[name]) then
           for rezer, data in Heart_healing[name] do
               if (Heart_rez_spells[Heart_healing[name][rezer]["Spell"]] and Heart_healing[name][rezer]["Status"] == "Active") then
                  return 1
               end
           end
	elseif (CT_RA_Ressers) then
           for rezer, data in CT_RA_Ressers do
               if data == name then
                  return 1
               end
           end
        elseif oRA_Resurrection then
	   for rezer, data in oRA_Resurrection.ressers do
               if data == name then
                  return 1
               end
           end
        end
        return
end

function Heart_GetHealBonus(unit, spell, rank)
	-- 检查由于目标身上的增益效果，我们将获得多少额外治疗量
	local healbonus = 0
	Heart_temp_table = (Heart_temp_table or {})
	Heart_temp_table2 = (Heart_temp_table2 or {})
	Heart_temp_table2[spell] = 0
	Heart_temp_table2["HealUp"] = 0
	Heart_temp_table2["HealDown"] = 0
	if (spell == C_Flash_of_light or spell == C_Holy_light) then
		local data = C_UnitGotBuff(unit, C_Blessing_of_light)
		data = (data or C_UnitGotBuff(unit, C_Greater_blessing_of_light))
		if (data and data["Text"]) then
			local start, stop
			start, stop, Heart_temp_table[1], Heart_temp_table[2] = string.find(data["Text"], Heart_blessing_of_light_search)
			if (start) then
				for index, value in Heart_blessing_of_light_text do
					Heart_temp_table2[value] = (Heart_temp_table2[value] or 0) * (Heart_bonus_divide / Heart_Spells[spell][rank]["CastTime"]) + Heart_temp_table[index]
				end
			end
		end
	end
	for buff, search in Heart_buff_affect_healing_search do
		local data = C_UnitGotBuff(unit, buff)
		if (data and data["Text"]) then
			local start, stop
			start, stop, Heart_temp_table[1], Heart_temp_table[2] = string.find(data["Text"], search)
			if (start) then
				for index, value in Heart_buff_affect_healing_text[buff] do
					Heart_temp_table2[value] = (Heart_temp_table2[value] or 0) + (Heart_temp_table[index] or 0)
				end
			end
		end
	end
	for debuff, search in Heart_debuff_affect_healing_search do
		local data = C_UnitGotDebuff(unit, debuff)
		if (data and data["Text"]) then
			local start, stop
			start, stop, Heart_temp_table[1], Heart_temp_table[2] = string.find(data["Text"], search)
			if (start) then
				for index, value in Heart_debuff_affect_healing_text[debuff] do
					Heart_temp_table2[value] = (Heart_temp_table2[value] or 0) + (Heart_temp_table[index] or 0)
				end
			end
		end
	end
	for buff, search in Heart_my_buff_affect_healing_search do
		local data = C_UnitGotBuff("player", buff)
		if (data and data["Text"]) then
			local start, stop
			start, stop, Heart_temp_table[1], Heart_temp_table[2] = string.find(data["Text"], search)
			if (start) then
				for index, value in Heart_my_buff_affect_healing_text[buff] do
					Heart_temp_table2[value] = (Heart_temp_table2[value] or 0) + (Heart_temp_table[index] or 0)
				end
			end
		end
	end
	healbonus = healbonus + (Heart_temp_table2[spell] or 0)
	healbonus = healbonus + (Heart_temp_table2["HealUp"] or 0)
	healbonus = healbonus - (Heart_temp_table2["HealDown"] or 0)
	-- 以及装备提供的 bonus
	if (not Heart_item_heal_bonus) then
		Heart_UpdateItemHealBonus()
	end
	healbonus = healbonus + Heart_item_heal_bonus
	-- 如果我们是牧师并且点了"精神指引"天赋
	if (C_my_class == C_Priest) then
		local crap1, crap2, crap3, crap4, crank, mrank = GetTalentInfo(2, 12)
		local base, cur = UnitStat("player", 5)
		healbonus = healbonus + crank * 0.05 * cur
		-- 如果我们是牧师并且点了"精神治疗"天赋（第二页第15个天赋）
		local crap1, crap2, crap3, crap4, spiritHealRank, mrank = GetTalentInfo(2, 15)
		if (spiritHealRank > 0) then
			healbonus = healbonus * (1 + spiritHealRank * 0.06)
		end
	end
	if (Heart_low_level_spell_bonus_penalty[spell] and Heart_low_level_spell_bonus_penalty[spell][rank]) then
		-- 低等级法术，会受到 bonus 惩罚
		healbonus = healbonus * Heart_low_level_spell_bonus_penalty[spell][rank]
	end
	return healbonus
end

function Heart_CanHeal(unit)
	-- 检查我们是否可以治疗这个单位
	if (not UnitExists(unit) or UnitIsDeadOrGhost(unit) or not UnitIsFriend("player", unit) or not UnitIsVisible(unit)) then
		return
	else
	    for buff, one in Heart_buff_unable_to_heal do
		if (C_UnitGotBuff(unit, buff)) then
			return
		end
	    end
	    for debuff, one in Heart_debuff_unable_to_heal do
		if (C_UnitGotDebuff(unit, debuff)) then
			return
		end
	    end
	    return 1
        end
end

function Heart_CanRez(unit)
	-- 检查我们是否可以复活这个单位
	if (not UnitExists(unit) or not UnitIsDead(unit) or not UnitIsFriend("player", unit) or not UnitIsConnected(unit)) then
	        return
        else
	return 1
	end
end

function Heart_IsHealModifierKeyDown(modifier)
	if (not modifier or not Heart_Config[modifier]) then
		return
	end
	if (Heart_Config[modifier] == 1) then
		return
	elseif (Heart_Config[modifier] == 2) then
		return 1
	elseif (Heart_Config[modifier] == 3 and IsAltKeyDown()) then
		return 1
	elseif (Heart_Config[modifier] == 4 and IsControlKeyDown()) then
		return 1
	elseif (Heart_Config[modifier] == 5 and IsShiftKeyDown()) then
		return 1
	elseif (Heart_Config[modifier] == 6 and IsAltKeyDown() and IsControlKeyDown()) then
		return 1
	elseif (Heart_Config[modifier] == 7 and IsAltKeyDown() and IsShiftKeyDown()) then
		return 1
	elseif (Heart_Config[modifier] == 8 and IsControlKeyDown() and IsShiftKeyDown()) then
		return 1
	elseif (Heart_Config[modifier] == 9 and IsAltKeyDown() and IsControlKeyDown() and IsShiftKeyDown()) then
		return 1
	end
end

function Heart_UpdateItemHealBonus()
	Heart_item_heal_bonus = 0
	Heart_set_bonus_applied = {}
	for slot = 1, 19 do
		local item = GetInventoryItemLink("player", slot)
		-- 检查武器槽位的附魔状态变化
		if (item and Heart_item_heal_bonus_cache[item] and (slot == 16 or slot == 17)) then
			local a, b, c, d, e, f = GetWeaponEnchantInfo()
			if (slot == 16 and ((a and not Heart_main_hand_enchant) or (not a and Heart_main_hand_enchant))) then
				Heart_item_heal_bonus_cache[item] = nil
				Heart_main_hand_enchant = a
			end
			if (slot == 17 and ((d and not Heart_off_hand_enchant) or (not d and Heart_off_hand_enchant))) then
				Heart_item_heal_bonus_cache[item] = nil
				Heart_off_hand_enchant = d
			end
		end
		-- 对于头部(5)、肩膀(3)等其他可附魔部位，每次都重新检查tooltip以捕获附魔变化
		-- 包括项链(2)、戒指1(11)、戒指2(12)等这个服务器中可附魔的部位
		local refreshTooltipSlots = {2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 16, 17} -- 项链、肩膀、头部、胸部、腰部、腿部、脚部、手腕、戒指1、戒指2、主手、副手
		local shouldRefreshTooltip = false
		for _, refreshSlot in pairs(refreshTooltipSlots) do
			if slot == refreshSlot then
				shouldRefreshTooltip = true
				break
			end
		end
		-- 如果是可附魔部位，强制刷新缓存
		if (item and Heart_item_heal_bonus_cache[item] and shouldRefreshTooltip) then
			Heart_item_heal_bonus_cache[item] = nil
		end
		if (item and Heart_item_heal_bonus_cache[item]) then
			Heart_item_heal_bonus = Heart_item_heal_bonus + Heart_item_heal_bonus_cache[item]
		else
			C_ClearTooltip()
			if (C_Tooltip:SetInventoryItem("player", slot)) then
				for line = 1, C_Tooltip:NumLines() do
					local itemtext = getglobal("C_TooltipTextLeft" .. line):GetText()
					local r, g, b, a = getglobal("C_TooltipTextLeft" .. line):GetTextColor()
					if (itemtext and itemtext ~= "" and not Heart_set_bonus_applied[itemtext] and not string.find(itemtext, Heart_set_bonus_inactive_text)) then
						for index, healtext in Heart_item_heal_bonus_text do
							local start, stop, bonus = string.find(itemtext, healtext)
							Heart_item_heal_bonus = Heart_item_heal_bonus + (bonus or 0)
							Heart_item_heal_bonus_cache[item] = (Heart_item_heal_bonus_cache[item] or 0) + (bonus or 0)
						end
						if (string.find(itemtext, Heart_set_bonus_active_text)) then
							Heart_set_bonus_applied[itemtext] = 1
						end
					end
				end
			end
		end
	end
end

function Heart_UpdateDead(elapsed)
           local players = GetNumRaidMembers()
           local por = "raid"
           if (GetNumRaidMembers() <= 0) or (Heart_Config["rez_party_only"] == 1) then
              players = GetNumPartyMembers()
              por = "party"
           end
           for a = 1, players do
                  if UnitIsDead(por .. a) then
                     Heart_awaiting_rez[por .. a] = (Heart_awaiting_rez[por .. a] or {})
                     Heart_awaiting_rez[por .. a]= {
                                            ["is_dead"] = 1,
                                            ["status"] = Heart_awaiting_rez[por .. a]["status"] or nil,
                                            ["waiting_time"] = Heart_awaiting_rez[por .. a]["waiting_time"] or nil,
                                            ["priority"] = tonumber(Heart_Config["rez_priority"][UnitClass(por .. a)]),
                                            ["cast"] = Heart_awaiting_rez[por .. a]["cast"] or nil
                     }
                  else
                     Heart_awaiting_rez[por .. a]= nil
                  end
           end
           if Heart_awaiting_rez then
              for player, data in Heart_awaiting_rez do
                  if (Heart_awaiting_rez[player]["is_dead"] and Heart_awaiting_rez[player]["waiting_time"]) and UnitIsDead(player) then
                     if not (Heart_awaiting_rez[player]["waiting_time"] <= 0) then
                        Heart_awaiting_rez[player]["waiting_time"] = Heart_awaiting_rez[player]["waiting_time"] - elapsed
                     else
                        Heart_awaiting_rez[player]["waiting_time"] = nil
                     end
                  elseif (Heart_awaiting_rez[player]["is_dead"] and not(UnitIsDead(player))) then
                     Heart_awaiting_rez[player]["is_dead"] = nil
                     Heart_awaiting_rez[player]["waiting_time"] = nil
                     Heart_awaiting_rez[player]["priority"] = 0
                  end
                  if (data["status"] and (data["cast"])) then
                  data["cast"] = data["cast"] - elapsed
                     if (data["cast"] <= 0) then
                        if (data["status"] == "stop") then
                           Heart_awaiting_rez[player]["waiting_time"] = 120
                           Heart_awaiting_rez[player]["status"] = nil
                           Heart_awaiting_rez[player]["cast"] = nil
                        else
                           Heart_awaiting_rez[player]["waiting_time"] = nil
                           Heart_awaiting_rez[player]["status"] = nil
                           Heart_awaiting_rez[player]["cast"] = nil
                        end
                     end
                  end
              end
           end
           table.sort(Heart_awaiting_rez, Heart_SortAwaitingRez)
end

function clean_spell_awaiting_target()
	Heart_spell_awaiting_target_Spell = nil
	Heart_spell_awaiting_target_Rank = nil
	Heart_spell_awaiting_target_Target= nil
end

-- 删除方案及其对应的_D、_S、_T方案
function Heart_DeleteClassAndRelated(classToDelete)
    if classToDelete then
        Heart_Config["classes"][classToDelete] = nil
        -- 检查并删除对应的_D、_S、_T方案
        if not string.find(classToDelete, "_D$") and not string.find(classToDelete, "_S$") and not string.find(classToDelete, "_T$") then
            if Heart_Config["classes"][classToDelete.."_D"] then
                Heart_Config["classes"][classToDelete.."_D"] = nil
            end
            if Heart_Config["classes"][classToDelete.."_S"] then
                Heart_Config["classes"][classToDelete.."_S"] = nil
            end
            if Heart_Config["classes"][classToDelete.."_T"] then
                Heart_Config["classes"][classToDelete.."_T"] = nil
            end
        end
        Heart_current_class = nil
        Heart_ClassDropDownMenuInitialize()
        Heart_UpdateClassButtons()
    end
end
