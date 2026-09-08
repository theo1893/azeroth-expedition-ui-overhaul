

CastingSpeed = {
    -- 清理过期的施法数据
    CleanExpiredCastData = function()
        -- 空实现
    end,
    
    -- 检查是否应该治疗目标
    ShouldHealTarget = function(targetGUID, playerGUID, spellID)
        -- 默认返回true，表示应该治疗
        return true
    end
}

last_update=0;

-- 移动检测相关变量
MPPlayerIsMoving = false
prevX, prevY = 0, 0

-- 跟踪技能缺失警告次数
Heart_missing_spell_warnings = 0

-- 跟踪施法梯形警告次数
Heart_cast_warnings = 0

Heart_Tank = {
           ["Unit"] = nil,
           ["Name"] = nil
}
Heart_i_am_healing = {}
Heart_awaiting_rez = {}

Heart_bonus_divide = 3.5
Heart_bonus_instant_divide = 15
Heart_buff_affect_healing_search = {}
Heart_buff_unable_to_heal = {
	[C_Divine_intervention] = 1,
	[C_Phase_shift] = 1
}
Heart_class_hp_per_level = {
	[C_Druid] = 60,
	[C_Hunter] = 65,
	[C_Mage] = 50,
	[C_Paladin] = 70,
	[C_Priest] = 50,
	[C_Rogue] = 65,
	[C_Shaman] = 70,
	[C_Warlock] = 65,
	[C_Warrior] = 90
}
Heart_critical_bonus = 1.5
Heart_debuff_affect_healing_search = {}
Heart_debuff_unable_to_heal = {
	[C_Banish] = 1,
	[C_Deep_slumber] = 1
}
Heart_dont_scale_hots = {
	[C_Rejuvenation] = 1,
	[C_Renew] =1
}
Heart_dont_scale = {
	[C_Holy_nova] = 1,
	[C_Power_word_shield] = 1,
	[C_Prayer_of_healing] = 1,
	[C_Tranquility] = 1,
        [C_Resurrection] = 1,
	[C_Redemption] = 1,
	[C_Rebirth] = 1,
	[C_Ancestral_Spirit] = 1
}
Heart_error_moving = {
	[SPELL_FAILED_MOVING] = 1
}
Heart_rez_spells = {
        [C_Resurrection] = 1,
	[C_Redemption] = 1,
	[C_Rebirth] = 1,
	[C_Ancestral_Spirit] = 1
}
Heart_attachment_spells = {
        [C_Natures_swiftness] = 1,
        [C_Shaman_Ancestral_swiftness] = 1,
        [C_Blessing_of_protection] = 1,
        [C_Power_word_shield] = 1,
	[C_Divine_protection] = 1,
	[C_Divine_shield] = 1
}
Heart_attachment_global_cooldown = {
        [C_Blessing_of_protection] = 1,
        [C_Power_word_shield] = 1,
	[C_Divine_protection] = 1,
	[C_Divine_shield] = 1
}
Heart_attachment_has_target = {
        [C_Blessing_of_protection] = 1,
        [C_Power_word_shield] = 1
}
Heart_error_unable = {
        SPELL_FAILED_AFFECTING_COMBAT,
	SPELL_FAILED_CASTER_DEAD,
	SPELL_FAILED_CONFUSED,
	SPELL_FAILED_FLEEING,
	SPELL_FAILED_NOT_IN_CONTROL,
	SPELL_FAILED_NOT_MOUNTED,
	SPELL_FAILED_NOT_STANDING,
	SPELL_FAILED_OUT_OF_RANGE,
	SPELL_FAILED_PACIFIED,
	SPELL_FAILED_POSSESSED,
	string.gsub(SPELL_FAILED_REAGENTS, "%%s",""),
	SPELL_FAILED_SILENCED,
	SPELL_FAILED_SPELL_IN_PROGRESS,
	SPELL_FAILED_STUNNED,
	SPELL_FAILED_TARGETS_DEAD,
	SPELL_FAILED_TARGET_NOT_DEAD
}
Heart_heal_spells_search = {}
Heart_hot_duration = {
	[C_Crystal_restore] = 15,
	[C_First_aid] = 8,
	[C_Greater_heal] = 15,
	[C_Lightwell] = 10,
	[C_Regrowth] = 21,
	[C_Rejuvenation] = 12,
	[C_Renew] = 15
}
Heart_my_buff_affect_healing_search = {}
Heart_spell_level = {
	[C_Blessing_of_protection] = {0, 14, 28},
	[C_Power_word_shield] = {-4, 2, 8, 14, 20, 26, 32, 38, 44, 50},
	[C_Regrowth] = {2, 8, 14, 20, 26, 32, 38, 44, 50},
	[C_Rejuvenation] = {-6, 0, 6, 12, 18, 24, 30, 36, 42, 48, 50},
	[C_Renew] = {-2, 4, 10, 16, 22, 28, 34, 40, 46, 50}
}
Heart_low_level_spell_bonus_penalty = {
	[C_Heal] = {0.0375*16+0.25},
	[C_Healing_touch] = {0.0375*1+0.25, 0.0375*8+0.25, 0.0375*14+0.25},
	[C_Healing_wave] = {0.0375*1+0.25, 0.0375*6+0.25, 0.0375*12+0.25, 0.0375*18+0.25},
	[C_Holy_light] = {0.0375*1+0.25, 0.0375*6+0.25, 0.0375*14+0.25},
	[C_Lesser_heal] = {0.0375*1+0.25, 0.0375*4+0.25, 0.0375*10+0.25},
	[C_Regrowth] = {0.0375*12+0.25, 0.0375*18+0.25},
	[C_Rejuvenation] = {0.0375*4+0.25, 0.0375*10+0.25, 0.0375*16+0.25},
	[C_Renew] = {0.0375*8+0.25, 0.0375*14+0.25}
}
Heart_supported_classes = {
	[C_Druid] = 1,
	[C_Paladin] = 1,
	[C_Priest] = 1,
	[C_Shaman] = 1
}
Heart_blessing_of_light_text = {
        C_Holy_light,
        C_Flash_of_light
}
Heart_buff_affect_healing_text = {
	[C_Amplify_magic] = {"DamageUp", "HealUp"},
	[C_Dampen_magic] = {"DamageDown", "HealDown"}
}
Heart_debuff_affect_healing_text = {
        [C_Gehennas_curse] = {"HealDown", "Duration"},
        [C_Curse_ot_deadwood] = {"HealDown", "Duration"}
}
Heart_my_buff_affect_healing_text = {
	[C_Unstable_power] = {"DamageUp", "HealUp"},
	[C_HotA] = {"HealUp", "Duration"}
}
Heart_heal_spells_text = {
	[C_Blessing_of_protection] = {"Duration", "Delay"},
	[C_Chain_heal] = {"HealMin", "HealMax", "EffectLoss", "Targets"},
	[C_Divine_protection] = {"Duration"},
	[C_Divine_shield] = {"Duration", "AttackSpeedLoss"},
	[C_Flash_heal] = {"HealMin", "HealMax"},
	[C_Flash_of_light] = {"HealMin", "HealMax"},
	[C_Greater_heal] = {"HealMin", "HealMax"},
	[C_Heal] = {"HealMin", "HealMax"},
	[C_Healing_touch] = {"HealMin", "HealMax"},
	[C_Healing_wave] = {"HealMin", "HealMax"},
	[C_Holy_light] = {"HealMin", "HealMax"},
	[C_Holy_nova] = {"DamageMin", "DamageMax", "DamageRange", "HealRange", "HealMin", "HealMax"},
	[C_Holy_shock] = {"DamageMin", "DamageMax", "HealMin", "HealMax"},
	[C_Lesser_heal] = {"HealMin", "HealMax"},
	[C_Lesser_healing_wave] = {"HealMin", "HealMax"},
	[C_Power_word_shield] = {"Absorb", "Duration", "Delay"},
	[C_Prayer_of_healing] = {"HealMin", "HealMax"},
	[C_Regrowth] = {"HealMin", "HealMax", "HealingOverTime", "Duration"},
	[C_Rejuvenation] = {"Duration", "HealingOverTime"},
	[C_Renew] = {"Duration", "HealingOverTime"},
	[C_Swiftmend] = {"RejuvenationTime", "RegrowthTime"},
	[C_Tranquility] = {"Heal", "Interval", "ChannelTime"},
	[C_Resurrection] = {"Heal", "ManaRestored"},
	[C_Redemption] = {"Heal", "ManaRestored"},
	[C_Rebirth] = {"Heal", "ManaRestored"},
	[C_Ancestral_Spirit] = {"Heal", "ManaRestored"},
	[C_Natures_swiftness] = {"text"},
	[C_Shaman_Ancestral_swiftness] = {"text"}
}

rh_fools_classes_set={
	[C_Druid]={
		[35] = {
			["Scale"] = 0,
			["Spell"] = C_Regrowth,
			["Rank"] = 9,
		},
		[80] = {
			["Scale"] = 1,
			["Spell"] = C_Rejuvenation,
			["Rank"] = 10,
		},
		[75] = {
			["Scale"] = 0,
			["Spell"] = C_Healing_touch,
			["Rank"] = 10,
		}
		},
	[C_Priest]={
			[30] = {
				["Scale"] = 0,
				["Spell"] = C_Flash_heal,
				["Rank"] = 7,
			},
			[20] = {
				["Scale"] = 1,
				["Spell"] = C_Power_word_shield,
				["Rank"] = 10,
			},
			[90] = {
				["Scale"] = 1,
				["Spell"] = C_Renew,
				["Rank"] = 9,
			},
			[80] = {
				["Scale"] = 0,
				["Spell"] = C_Heal,
				["Rank"] = 4,
			},
			[50] = {
				["Scale"] = 0,
				["Spell"] = C_Greater_heal,
				["Rank"] = 5,
			},
		},
	[C_Paladin]={
			[90] = {
				["Scale"] = 0,
				["Spell"] = C_Flash_of_light,
				["Rank"] = 6,
			},
			[70] = {
				["Scale"] = 0,
				["Spell"] = C_Holy_light,
				["Rank"] = 8,
			}
		},
	[C_Shaman]={
			[80] = {
				["Scale"] = 0,
				["Spell"] = C_Lesser_healing_wave,
				["Rank"] = 6,
			},
			[60] = {
				["Scale"] = 0,
				["Spell"] = C_Healing_wave,
				["Rank"] = 9,
			}
		}
		
}


Heart_set_bonus_active_text = "Set:"
Heart_set_bonus_inactive_text = "%(%d%) Set:"

        for index, value in Heart_blessing_of_light_text do
	    Heart_blessing_of_light_search = (Heart_blessing_of_light_search or "[^%d]+") .. "(%d+%.?%d*)[^%d]+"
        end

        for buff, data in Heart_buff_affect_healing_text do
	    for index, value in data do
		Heart_buff_affect_healing_search[buff] = (Heart_buff_affect_healing_search[buff] or "[^%d]+") .. "(%d+%.?%d*)[^%d]+"
	    end
        end

        for debuff, data in Heart_debuff_affect_healing_text do
	    for index, value in data do
		Heart_debuff_affect_healing_search[debuff] = (Heart_debuff_affect_healing_search[debuff] or "[^%d]+") .. "(%d+%.?%d*)[^%d]+"
	    end
        end

        for spell, data in Heart_heal_spells_text do
	    for index, value in data do
		Heart_heal_spells_search[spell] = (Heart_heal_spells_search[spell] or "[^%d]+") .. "(%d+%.?%d*)[^%d]+"
	    end
        end
        
        -- 为回春术和恢复法术定义专用的正则表达式，匹配中文描述格式
        Heart_heal_spells_search[C_Rejuvenation] = "在(%d+)秒内恢复总计(%d+)点生命值。"
        Heart_heal_spells_search[C_Renew] = "在(%d+)秒内恢复总计(%d+)点生命值。"

        for index, value in Heart_hot_text do
	    Heart_hot_search = (Heart_hot_search or "[^%d]+") .. "(%d+%.?%d*)[^%d]+"
        end

        for buff, data in Heart_my_buff_affect_healing_text do
	    for index, value in data do
		Heart_my_buff_affect_healing_search[buff] = (Heart_my_buff_affect_healing_search[buff] or "[^%d]+") .. "(%d+%.?%d*)[^%d]+"
	    end
        end



--      ##################
--     # 信息收集 #
--    #        &       #
--   # 初始化 #
--  #        &       #
-- # 核心函数 #
--##################

function Heart_SetupSettings()
        Heart_UpdateSpells()
	-- 设置一些用户定义的设置
	C_update_player_data_time = (C_update_player_data_time or 2.5)

	Heart_Config = (Heart_Config or {})
	Heart_SavedProfiles = (Heart_SavedProfiles or {})
	
	if ((not Heart_Config["version"]) or (Heart_Config["version"] < 0.14001)) then
		-- 新版本，修复已更改的设置
		Heart_Config["debuff_affect_priority"] = nil
		Heart_Config["hook_useaction"] = nil
		Heart_Config["buff_affect_priority"]=nil
		Heart_Config["classes"]=nil
		C_Print("redHeart detect your old version of Heart. Will clean your classes sets for bug fixing. Sorry for the trouble.");
	end
	Heart_Config["version"] = 0.142
	Heart_Config["MTCastTime_Debuff"]=(Heart_Config["MTCastTime_Debuff"] or 0)
	Heart_Config["CastTime_Debuff"]=(Heart_Config["CastTime_Debuff"] or 0)
	Heart_Config["autocancel"] = (Heart_Config["autocancel"] or 1)
	Heart_Config["mm"] = (Heart_Config["mm"] or {})
	if (not Heart_Config["buff_affect_priority"]) then
		Heart_Config["buff_affect_priority"] = {
	[C_Blessing_of_protection] =  0.2,
	[C_Power_word_shield] =  0.4  }
	end
		
	Heart_Config["autocancel_time"] = (Heart_Config["autocancel_time"] or 0.25)
	if (not Heart_Config["class_priority"]) then
		Heart_Config["class_priority"] = {
			[C_Druid] = 0.5,
			[C_Hunter] = 0.4,
			[C_Mage] = 0.8,
			[C_Paladin] = 0.5,
			[C_Priest] = 0.7,
			[C_Rogue] = 0.7,
			[C_Shaman] = 0.6,
			[C_Warlock] = 0.6,
			[C_Warrior] = 1.0
		}
	end
	if (not Heart_Config["rez_priority"]) then
		Heart_Config["rez_priority"] = {
			[C_Druid] = 0.7,
			[C_Hunter] = 0.5,
			[C_Mage] = 0.6,
			[C_Paladin] = 0.5,
			[C_Priest] = 0.8,
			[C_Rogue] = 0.5,
			[C_Shaman] = 0.6,
			[C_Warlock] = 0.5,
			[C_Warrior] = 1.0
		}
	end
	if not Heart_Config["classes"] then
		Heart_Config["classes"]={}
		if rh_fools_classes_set[C_my_class] then
			Heart_Config["classes"]["standard"]=rh_fools_classes_set[C_my_class]
		end
	end

	if (not Heart_Config["debuff_affect_priority"]) then
		Heart_Config["debuff_affect_priority"] = {
			[C_Recently_bandaged] = 0.15,
			[C_Weakened_soul] = 0.15,
			[C_Mortal_strike] = 0.3
		}
	end
	if (not Heart_Config["rez_spell"]) then
                for spell, data in Heart_Spells do
                    if Heart_rez_spells[spell] then
                       Heart_Config["rez_spell"] = spell
                    end
                end
        end
        local rezspell = Heart_Config["rez_spell"]
        if rezspell then
                   Heart_Config["rez_rank"] = (Heart_Config["rez_rank"] or table.getn(Heart_Spells[rezspell]))
        end
        Heart_Config["MT_priority"] = (Heart_Config["MT_priority"] or 0.5)
        Heart_Config["rez_message"] = (Heart_Config["rez_message"] or "Come to the light $t")
        Heart_Config["enable_mouse"] = (Heart_Config["enable_mouse"] or 0)
        Heart_Config["rez_message_channel"] = (Heart_Config["rez_message_channel"] or "SAY")
        if (not Heart_supported_classes[C_my_class]) then
            local layout = {
                  icon = "Interface\\Icons\\INV_Misc_Organ_01",
                  drag = "CIRCLE",
                  left = function() if Heart_GUI:IsShown() then Heart_GUI:Hide() else Heart_GUI:Show() end end,
                  right = function() if Heart_Config["show_healing_me"] == 1 then Heart_Config["show_healing_me"] = 0 else Heart_Config["show_healing_me"] = 1 end end,
                  tooltip = Heart_GUI_help["MM2"]["Description"],
                  enabled = 0
            }
            MyMinimapButton:Create("Heart",Heart_Config["mm"],layout)
        else
            local layout = {
                  icon = "Interface\\Icons\\INV_Misc_Organ_01",
                  drag = "CIRCLE",
                  left = function() if Heart_GUI:IsShown() then Heart_GUI:Hide() else Heart_GUI:Show() end end,
                  right = function() if Heart_ClickFrame:IsShown() then Heart_ClickFrame:Hide() Heart_Config["hide_gui"] = 1 else Heart_ClickFrame:Show() Heart_Config["hide_gui"] = 0 end end,
                  tooltip = Heart_GUI_help["MM"]["Description"],
                  enabled = 0
            }
            MyMinimapButton:Create("Heart",Heart_Config["mm"],layout)
        end
        Heart_Config["hide_mm"] = (Heart_Config["hide_mm"] or 0)
        if Heart_Config["hide_mm"] == 0 then
           MyMinimapButton:SetEnable("Heart",1)
        end
        Heart_Config["hide_gui"] = (Heart_Config["hide_gui"] or 0)
        if Heart_Config["hide_gui"] == 0 then
           if (Heart_supported_classes[C_my_class]) then
              Heart_ClickFrame:Show()
              Heart_UpdateClassButtons()
           else
              Heart_ClickFrame:Hide()
           end
        end
        Heart_Config["always_tank_target"] = (Heart_Config["always_tank_target"] or 0)
        Heart_Config["rez_party_only"] = (Heart_Config["rez_party_only"] or 0)
	Heart_Config["heal_enough_modifier"] = (Heart_Config["heal_enough_modifier"] or 4)
	Heart_Config["heal_none_modifier"] = (Heart_Config["heal_none_modifier"] or 1)
	Heart_Config["heal_max_modifier"] = (Heart_Config["heal_max_modifier"] or 5)
	Heart_Config["heal_power"] = (Heart_Config["heal_power"] or 1.0)
	Heart_Config["heal_self_modifier"] = (Heart_Config["heal_self_modifier"] or 3)
	Heart_Config["heal_charmed"] = (Heart_Config["heal_charmed"] or 1)
	Heart_Config["heal_strategy"] = (Heart_Config["heal_strategy"] or 1)
	Heart_Config["heal_targettarget_modifier"] = (Heart_Config["heal_targettarget_modifier"] or 1)
	Heart_Config["hook_shields"] = (Heart_Config["hook_shields"] or 1)
	Heart_Config["hook_useaction"] = (Heart_Config["hook_useaction"] or 1)
	Heart_Config["ninja_useaction"] = (Heart_Config["ninja_useaction"] or 1)
	Heart_Config["hot_heal_threshold"] = (Heart_Config["hot_heal_threshold"] or 0.4)
	Heart_Config["hot_multiply"] = (Heart_Config["hot_multiply"] or 1.0)
	Heart_Config["hot_multiply_battle"] = (Heart_Config["hot_multiply_battle"] or 0.5)
	Heart_Config["max_overheal"] = (Heart_Config["max_overheal"] or 0.2)
	Heart_Config["min_heal_threshold"] = (Heart_Config["min_heal_threshold"] or 0.95)
	Heart_Config["mouse"] = (Heart_Config["mouse"] or {})
	Heart_Config["party_priority"] = (Heart_Config["party_priority"] or 0.8)
	Heart_Config["pet_priority"] = (Heart_Config["pet_priority"] or 0.2)
	Heart_Config["player_priority"] = (Heart_Config["player_priority"] or 1.0)
	Heart_Config["raid"] = (Heart_Config["raid"] or {})
	for group = 1, 8 do
		Heart_Config["raid"][group] = (Heart_Config["raid"][group] or {})
		for slot = 1, 5 do
			Heart_Config["raid"][group][slot] = (Heart_Config["raid"][group][slot] or 1)
		end
	end
	if (C_my_class == C_Druid or C_my_class == C_Paladin or C_my_class == C_Priest or C_my_class == C_Shaman) then
		Heart_Config["show_healing_all"] = (Heart_Config["show_healing_all"] or 1);
		Heart_Config["show_healing_me"] = (Heart_Config["show_healing_me"] or 0);
	else
		Heart_Config["show_healing_all"] = (Heart_Config["show_healing_all"] or 0);
		Heart_Config["show_healing_me"] = (Heart_Config["show_healing_me"] or 1);
	end
	Heart_Config["shapeshifted_druids"] = (Heart_Config["shapeshifted_druids"] or 1);
	Heart_Config["raid_priority"] = (Heart_Config["raid_priority"] or 0.5)
	Heart_Config["safe_cancel"] = (Heart_Config["safe_cancel"] or 1)
	Heart_Config["scale_spells"] = (Heart_Config["scale_spells"] or 1)
	Heart_Config["heal_count"] = (Heart_Config["heal_count"] or 3)
	Heart_Config["scale_hots"] = (Heart_Config["scale_hots"] or 0)
	Heart_Config["unchecked_priority"] = (Heart_Config["unchecked_priority"] or 0.3)
	Heart_Config["useaction_heal_most_wounded"] = (Heart_Config["useaction_heal_most_wounded"] or 1)
    Heart_Config["useaction_rez"] = (Heart_Config["useaction_rez"] or 1)
	Heart_Config["CastBar_Scale"] = (Heart_Config["CastBar_Scale"] or 1)
	Heart_Config["HealBars_Scale"] = (Heart_Config["HealBars_Scale"] or 1)
	Heart_Config["Buttons_Scale"] = (Heart_Config["Buttons_Scale"] or 1)
	Heart_Config["show_heal_bars"] = (Heart_Config["show_heal_bars"] or 1)
	Heart_Config["show_current_heal_bars"] = (Heart_Config["show_current_heal_bars"] or 1)
	Heart_Config["show_spell_rank_heal"] = (Heart_Config["show_spell_rank_heal"] or 1)
	Heart_Config["show_target_health"] = (Heart_Config["show_target_health"] or 1)
	Heart_Config["show_after_health"] = (Heart_Config["show_after_health"] or 1)
	Heart_Config["show_overheal"] = (Heart_Config["show_overheal"] or 1)
    Heart_Config["healer_count_limit"] = (Heart_Config["healer_count_limit"] or 3)
	Heart_Config["block_faster_healers"] = (Heart_Config["block_faster_healers"] or 0)
	Heart_UpdateClassButtons()
end
        -- 更新存储的设置
function Heart_UpdateSettings()
	Heart_UpdateScale()
        
	-- 确保this存在且有必要的属性
	if (not this) then
		return
	end
        
	-- 保存变量以避免重复访问
	local variable = this.variable
	if (not variable) then
		return
	end
  
	-- 重要：更新存储的设置值
	-- 根据复选框的选中状态设置配置项的值
	if string.find(variable, "Heart_Config") and this.GetChecked then
		local checked = this:GetChecked()
		-- 提取配置项名称
		local configKey = string.match(variable, 'Heart_Config%["([^"]+)"%]')
		if configKey then
			Heart_Config[configKey] = (checked and 1) or 0
		end
	end
  
	-- 更新存储的设置后刷新治疗条显示
	Heart_UpdateHealCurrent()
	
	-- 对于治疗条显示相关的设置变更，确保立即显示效果
	if (string.find(variable, "show_current_heal_bars") or string.find(variable, "show_spell_rank_heal") or string.find(variable, "show_target_health") or string.find(variable, "show_after_health") or string.find(variable, "show_overheal")) then
		-- 创建预览模式
		Heart_PreviewMode = true
		Heart_PreviewTarget = UnitName("player") or "预览目标"
		Heart_PreviewSpell = "强效治疗术"
		Heart_PreviewRank = 5
		Heart_PreviewHeal = 2500
		Heart_PreviewCurrentHP = UnitHealth("player") or 5000
		Heart_PreviewMaxHP = UnitHealthMax("player") or 10000
		
		-- 强制显示Heart_GUIHealCurrent框架来预览效果
		Heart_GUIHealCurrent:Show()
		Heart_GUIHealCurrent:SetAlpha(1)
		
		-- 模拟Heart_UpdateHealCurrent的部分功能来显示预览
		Heart_ShowHealPreview()
		
		-- 设置一个短暂的计时器，在预览显示一段时间后自动关闭预览模式
		-- 使用魔兽世界1.12版本兼容的GetTime()函数实现
		if not Heart_PreviewStartTime then
			Heart_PreviewStartTime = GetTime()
		else
			-- 如果已有计时器在运行，更新开始时间
			Heart_PreviewStartTime = GetTime()
		end
		
		-- 如果没有预览更新帧，创建一个
		if not Heart_PreviewUpdateFrame then
			Heart_PreviewUpdateFrame = CreateFrame("Frame")
			Heart_PreviewUpdateFrame:SetScript("OnUpdate", function()
				if Heart_PreviewStartTime and (GetTime() - Heart_PreviewStartTime > 5) then
					-- 预览时间结束（5秒后）
					Heart_PreviewMode = false
					Heart_PreviewStartTime = nil
					if not Heart_i_am_healing then
						Heart_GUIHealCurrent:Hide()
					end
				end
			end)
		end
	end
	
	-- 处理滑块和复选框的其他逻辑
	local start, stop, pre = string.find(variable, "^([%w%s:_%-]+)")
	if (not pre) then
		return
	end
	local value
	
	-- 确保this有GetName方法才执行下面的逻辑
	if this.GetName then
		local name = this:GetName()
		if (string.find(name, "^Heart_GUI.*Slider$") and this.GetValue) then
			-- 滑动条
			value = math.floor(this:GetValue() * 100 + 0.5) / 100
			if (name == "Heart_GUIAutocancelTimeSlider") then
				getglobal(name .. "High"):SetText(value * 1000 .. " ms")
			elseif (name == "Heart_GUIUpdatePlayerDataTimeSlider") then
				value = value / 10
				getglobal(name .. "High"):SetText(value .. " ms")
			elseif (name == "Heart_GUIHealStrategySlider") then
				getglobal(name .. "High"):SetText(Heart_GUI_heal_strategies[value])
			 elseif (name == "Heart_GUIHealerCountLimitSlider") then
				getglobal(name .. "High"):SetText((value).. "人")
			elseif (string.find(name, "Heart_GUIHeal.+ModifierSlider")) then
				getglobal(name .. "High"):SetText(Heart_GUI_keys[value])
			elseif (string.find(name, "RankSlider")) then
				getglobal(name .. "High"):SetText(value)
			elseif (string.find(name, "Value")) then
				getglobal(name .. "High"):SetText(value)
			else
				getglobal(name .. "High"):SetText(value * 100 .. "%")
			end
		elseif (string.find(name, "^Heart_GUI.*CheckButton$") and this.GetChecked) then
			-- 复选按钮
			if (this:GetChecked()) then
				value = 1
			else
				value = 0
			end
		else
			return
		end
	else
		return
	end
	-- 这个功能有点酷，但同时也是个小技巧 =)
	local args = {}
	for index in string.gfind(variable, "%[\"?([^%[%]\"]+)\"?%]") do
		if ((string.find(index, "Heart_") or string.find(index, "C_")) and getglobal(index)) then
			-- 我们想要索引这个变量的值，而不是文本本身
			index = getglobal(index)
		end
		table.insert(args, index)
	end
	if (table.getn(args) == 0) then
		if (pre == "C_update_player_data_time") then
			C_update_player_data_time = value
		end
	elseif (table.getn(args) == 1) then
		getglobal(pre)[args[1]] = value
	elseif (table.getn(args) == 2) then
		getglobal(pre)[args[1]][args[2]] = value
	elseif (table.getn(args) == 3) then
		getglobal(pre)[args[1]][args[2]][args[3]] = value
	elseif (table.getn(args) == 4) then
		getglobal(pre)[args[1]][args[2]][args[3]][args[4]] = value
	elseif (table.getn(args) == 5) then
		getglobal(pre)[args[1]][args[2]][args[3]][args[4]][args[5]] = value
	end
end

function Heart_Save_Profile(profile)
	-- 将当前设置保存到配置文件
	   Heart_SavedProfiles[profile] = {}
	   for key, value in Heart_Config do
		if (type(value) == "table") then
			Heart_SavedProfiles[profile][key] = {}
			for key2, value2 in value do
				if (type(value2) == "table") then
					Heart_SavedProfiles[profile][key][key2] = {}
					for key3, value3 in value2 do
						if (type(value3) == "table") then
						else
							Heart_SavedProfiles[profile][key][key2][key3] = value3
						end
					end
				else
					Heart_SavedProfiles[profile][key][key2] = value2
				end
			end
		else
			Heart_SavedProfiles[profile][key] = value
		end
	   end
end

function Heart_Load_Profile(profile)
	-- 从配置文件加载设置
           local classes = {}
	   for class, data in Heart_Config["classes"] do
		classes[class] = {}
		for spell, settings in data do
			classes[class][spell] = {}
			for key, value in settings do
				classes[class][spell][key] = value
			end
		end
	   end
	   Heart_Config = Heart_SavedProfiles[profile]
	   Heart_Config["classes"] = classes
	   if (Heart_GUI:IsVisible()) then
		Heart_GUI:Hide()
		Heart_GUI:Show()
		if (Heart_GUIRaid:IsVisible()) then
			Heart_SetRaidChecked()
		end
	   end
end

function Heart_UpdateSpells()
	-- 获取或更新我们已知的法术
	Heart_party_heal_spells = {
		[C_Chain_heal] = 0,
		[C_Holy_nova] = 0,
		[C_Prayer_of_healing] = 0,
		[C_Tranquility] = 0
	}
	Heart_player_heal_spells = {
		[C_Blessing_of_protection] = 0,
		[C_Flash_heal] = 0,
		[C_Flash_of_light] = 0,
		[C_Greater_heal] = 0,
		[C_Heal] = 0,
		[C_Healing_touch] = 0,
		[C_Healing_wave] = 0,
		[C_Holy_light] = 0,
		[C_Holy_shock] = 0,
		[C_Lesser_heal] = 0,
		[C_Lesser_healing_wave] = 0,
		[C_Power_word_shield] = 0,
		[C_Regrowth] = 0,
		[C_Rejuvenation] = 0,
		[C_Renew] = 0,
		[C_Swiftmend] = 0,
		[C_Resurrection] = 0,
		[C_Redemption] = 0,
		[C_Rebirth] = 0,
		[C_Ancestral_Spirit] = 0,
	}
	if (C_my_class == C_Shaman) then
		Heart_player_heal_spells[C_Rebirth] = nil
	end  --fix Chinese translation problem
	Heart_Spells = {}
	local spellid = 1
	local spellname = GetSpellName(spellid, BOOKTYPE_SPELL)
	while (spellname) do
		if (Heart_heal_spells_text[spellname]) then
			local start, stop
			if (not Heart_Spells[spellname]) then
				Heart_Spells[spellname] = {}
				rank = 1
			else
				rank = table.getn(Heart_Spells[spellname]) + 1
			end
			if (Heart_party_heal_spells[spellname]) then
				Heart_party_heal_spell = spellname
			end
			Heart_Spells[spellname][rank] = (Heart_Spells[spellname][rank] or {})
			Heart_Spells[spellname][rank]["ID"] = spellid
			local mana, range, casttime, text = C_GetSpellData(spellid, BOOKTYPE_SPELL)
			Heart_Spells[spellname][rank]["Mana"] = mana
			Heart_Spells[spellname][rank]["CastTime"] = casttime
			local realcasttime = casttime
			if (C_my_class == C_Druid and spellname == C_Healing_touch) then
				local crap1, crap2, crap3, crap4, crank, mrank = GetTalentInfo(3, 3)
				realcasttime = realcasttime + crank * 0.1
			elseif (C_my_class == C_Priest and (spellname == C_Heal or spellname == C_Greater_heal)) then
				local crap1, crap2, crap3, crap4, crank, mrank = GetTalentInfo(2, 5)
				realcasttime = realcasttime + crank * 0.1
			elseif (C_my_class == C_Shaman and spellname == C_Healing_wave) then
				local crap1, crap2, crap3, crap4, crank, mrank = GetTalentInfo(3, 1)
				realcasttime = realcasttime + crank * 0.1
			end
			Heart_Spells[spellname][rank]["RealCastTime"] = realcasttime
			Heart_Spells[spellname][rank]["Range"] = range
			Heart_Spells[spellname]["Texture"] = GetSpellTexture(spellid, BOOKTYPE_SPELL)
			local a = {}
			start, stop, cooldown, a[1], a[2], a[3], a[4], a[5], a[6] = string.find(text, Heart_heal_spells_search[spellname] .. "(%d+%.?%d*)[^%d]+")
			if (not start) then
				start, stop, a[1], a[2], a[3], a[4], a[5], a[6] = string.find(text, Heart_heal_spells_search[spellname])
			end
			if (start) then
				for index, value in Heart_heal_spells_text[spellname] do
					Heart_Spells[spellname][rank][value] = a[index] / 1.0
				end
			end
			if (Heart_player_heal_spells[spellname]) then
				Heart_player_heal_spells[spellname] = 1
			end
		end
		spellid = spellid + 1
		spellname = GetSpellName(spellid, BOOKTYPE_SPELL)
	end
	Heart_party_heal_spells = nil
	for spell, value in Heart_player_heal_spells do
		if (value == 0) then
			Heart_player_heal_spells[spell] = nil
		end
	end
	Heart_SavedSpells = Heart_Spells
end

function Heart_RaidUnitIsChecked(unit)
	-- 如果我们在团队中并且给定单位已被选中进行治疗，则返回1
	if (GetNumRaidMembers() <= 0) then
		return 1
	end
	if (not string.find(unit, "raid")) then
		return 1
	end
	if (string.find(unit, "pet")) then
		return 1
	end
	local slot = Heart_raid_cache[C_UnitName(unit)]
	if (not slot) then
		return 1
	end
	local start, stop, index = string.find(unit, "[^%d]*(%d+)[^%d]*")
	if (not index) then
		return 1
	end
	index = index / 1
	local name, rank, group = GetRaidRosterInfo(index)
	if (not group) then
		return 1
	end
	if (name ~= C_UnitName(unit)) then
		C_Print("Error: out of sync, \"" .. name .. "\" found, \"" .. C_UnitName(unit) .. "\" expected")
		return 1
	end
	if (Heart_Config["raid"][group][slot] == 1) then
		return 1
	end
end

function Heart_UnitID(person)
	-- 检查玩家是否在我们的小队/团队中
	if (not person or person == "") then
		return
	end
	if (person == C_UnitName("player")) then
		return "player"
	end
	for a = 1, GetNumRaidMembers() do
		if (UnitExists("raid" .. a) and person == C_UnitName("raid" .. a)) then
			return "raid" .. a
		elseif (UnitExists("raidpet" .. a) and person == C_UnitName("raidpet" .. a)) then
			return "raidpet" .. a
		end
	end
	for a = 1, GetNumPartyMembers() do
		if (UnitExists("party" .. a) and person == C_UnitName("party" .. a)) then
			return "party" .. a
		elseif (UnitExists("partypet" .. a) and person == C_UnitName("partypet" .. a)) then
			return "partypet" .. a
		end
	end
	return
end

function Heart_IsMT(unit)
    for key,value in pairs(CT_RA_MainTanks or (oRA_MainTank and oRA_MainTank.MainTankTable or nil) or {}) do
        if value == C_UnitName(unit) then
           return true 
        end
    end
    return
end

function Heart_GetActionSpell(slot)
	C_TooltipTextLeft1:SetText()
	C_TooltipTextRight1:SetText()
	C_Tooltip:SetAction(slot)
	local start, stop, name, rank
	name = C_TooltipTextLeft1:GetText()
	rank = C_TooltipTextRight1:GetText()
	start, stop, rank = string.find((rank or ""), "(%d+)")
	rank = (rank or 1) / 1.0
	return (name or ""), rank
end

function Heart_Receive(author, message)
	if (author == C_my_name or not C_GetUnitID(author)) then
		-- 我或该玩家不在我的小队/团队中
		return
	end
	local start, stop, what, who, spell, heal, hot, casttime, timeleft = string.find(message, "^(.+), (.+), (.+), (%d+%.?%d*), (%d+%.?%d*), (%d+%.?%d*), (%d+%.?%d*)")
	if (not start) then
		-- 不认识这个玩家 :\
		return
	end
	if (not C_GetUnitID(who)) then
		-- 不知道这个人是谁
		return
	end
	Heart_healing[who] = (Heart_healing[who] or {})
	if (what == "Update") then
		-- 常规更新:
-- + 有人开始治疗
-- + 有人更新了施法时间
-- + 有人被延迟
-- 我们只需更新数据
		heal = heal / 1.0
		hot = hot / 1.0
		casttime = casttime / 1.0
		timeleft = timeleft / 1.0
		if (Heart_healing[who][author] and Heart_healing[who][author]["Bar"]) then
			local bar = getglobal("Heart_GUIHealBars" .. Heart_healing[who][author]["Bar"])
			bar:SetMinMaxValues(666, 1337)
			bar:Hide()
		end
		Heart_healing[who][author] = {
			["CastTime"] = casttime,
			["Heal"] = heal,
			["HealingOverTime"] = hot,
			["Name"] = name,
			["Spell"] = spell,
			["Status"] = "Active",
			["TimeLeft"] = timeleft
		}
	else
                if (Heart_healing[who][author] and Heart_healing[who][author]["Status"] == "Active") then
			if (Heart_healing[who][author]["Spell"] == Heart_rez_spells[spell] and what == "Stop") then
                           if Heart_awaiting_rez[who] then
                              Heart_awaiting_rez[who]["wait_time"] = 120;
                           end
                        end
                        Heart_healing[who][author]["Status"] = what
			Heart_healing[who][author]["TimeLeft"] = -1
		end
	end
end

--    ###################
--   #     鼠标       #
--  #       &         #
-- # 按键绑定治疗 #
--###################

function Heart_MouseHeal(unit, button)
        if (Heart_Config["enable_mouse"] == 0) then
                return
	elseif (not Heart_IsHealModifierKeyDown("heal_enough_modifier") and not Heart_IsHealModifierKeyDown("heal_max_modifier")) or (Heart_IsHealModifierKeyDown("heal_none_modifier")) then
		-- 我们没有下令治疗
		return
        elseif (Heart_casting_spell) then
		if (Heart_Config["safe_cancel"] == 0 or Heart_GetOverheal() > Heart_Config["max_overheal"]) then
			SpellStopCasting()
			return
		end
        end
        if (CursorHasItem() or CursorHasMoney() or SpellIsTargeting()) then
               if (CursorHasItem() or CursorHasMoney()) then
                  DropItemOnUnit(unit)
                  return
               end
               return
        end
	button = string.lower(button)
	if (not button or not unit or not Heart_Config["mouse"][button]) then
		return
	end
	local spell = Heart_Config["mouse"][button]["SpellOrClass"]
	if (not Heart_Spells) then
		Heart_UpdateSpells()
	end
	local healvalue
	if (Heart_IsHealModifierKeyDown("heal_enough_modifier") and not Heart_IsHealModifierKeyDown("heal_max_modifier")) then
		-- 不是坦克治疗，设置治疗值
		healvalue = Heart_GetHealValue(unit)
		if (healvalue < UnitHealthMax(unit) * (1.0 - Heart_Config["min_heal_threshold"])) then
			return 1
		end
	end
	if (Heart_Spells[spell]) then
		-- 一个简单的法术
		local rank = Heart_Config["mouse"][button]["Rank"]
		Heart_Heal(unit, spell, rank, healvalue)
	else
		-- 一个组合
		Heart_HealUsingClass(unit, spell, healvalue)
	end
	return 1
end

function Heart_KeyClicks(button)
	if (not button) then
		return
	end
	local unit
        local frame = GetMouseFocus():GetName()
        if (string.find(frame, "PlayerFrame", 1, true) or string.find(frame, "Perl_Player") or string.find(frame, "oUF_Player"))then
		unit = "player"
	elseif (string.find(frame, "TargetFrame",1, true) or (string.find(frame, "oUF_Target"))) then
		unit = C_AKA("target")
	elseif (string.find(frame, "Perl_Target")) then
                if (string.find(GetMouseFocus():GetParent():GetParent():GetName(), "Perl_Target_Frame",1 ,true)) then
                       unit = C_AKA("target")
                elseif (string.find(GetMouseFocus():GetParent():GetParent():GetName(), "Perl_Target_Target_Frame",1 ,true)) then
		       unit = C_AKA("targettarget")
                elseif (string.find(GetMouseFocus():GetParent():GetParent():GetName(), "Perl_Target_Target_Target_Frame",1 ,true)) then
		       unit = C_AKA("targettargettarget")
		end
	elseif (string.find(frame, "Sparty")) then
	       unit = string.sub(GetMouseFocus():GetName(), 2)
	elseif (string.find(frame, "Starget")) then
	       unit = string.sub(GetMouseFocus():GetName(), 2)
	elseif (string.find(frame, "Splayer"))then
	       unit = string.sub(GetMouseFocus():GetName(), 2)
        elseif (string.find(frame, "Perl_party")) then
                local name = GetMouseFocus():GetName()
                id = string.sub(name, 11, 11)
                unit = "party"..id
        elseif (string.find(frame, "Perl_Party")) then
                local name = GetMouseFocus():GetName()
                id = string.sub(name, 23, 23)
                unit = "party"..id
        elseif (string.find(frame, "Nurfed_") or string.find(frame, "DUF_") or string.find(frame, "MGp") or string.find(frame, "MGt") or string.find(frame, "MGr") or string.find(frame, "oUF_Party") or string.find(frame, "oUF_TargetsTarget")) then
                if (getglobal(frame).unit) then
                    unit = getglobal(frame).unit
                end
        elseif (string.find(frame, "RaidPullout(%d?)Button")) then
		unit = (GetMouseFocus().unit or GetMouseFocus():GetParent().unit)
	elseif(string.find(frame, "CT_RA_EmergencyFrameFrame(%d?)ClickFrame")) then
                unit = getglobal(frame).unitid
	elseif(string.find(frame, "SqueakyBar(%d?)")) then
                local frametext = frame.."_Text"
                local text= getglobal(frametext):GetText()
                local nameend = string.find(text, ":")
                local name = string.sub(text, 1,(nameend-1))
                if name == C_UnitName("player") then
                        unit = "player"
                elseif GetNumRaidMembers()>0  then
                       for i = 1, GetNumRaidMemebers() do
                           if name == C_UnitName("raid"..i) then
                           unit = "raid"..i
                           break
                           end
                       end
                elseif GetNumPartyMembers()>0 then
                       for i = 1, GetNumPartyMemebers() do
                           if name == C_UnitName("party"..i) then
                           unit = "party"..i
                           break
                           end
                       end
                end
        elseif(string.find(frame, "Perl_Raid")) then
                local id = GetMouseFocus():GetID()
                if id == 0 then id = GetMouseFocus():GetParent():GetParent():GetID() end
                unit = "raid"..id
        elseif(string.find(frame, "CT_RAMember")) then
                local id = GetMouseFocus():GetParent():GetParent():GetID()
                unit = "raid"..id
        elseif(string.find(frame, "CT_RAMTGroupMember")) then
                if(string.find(frame, "MTTT")) then
                unit = (GetMouseFocus()).id
                else
                    local name = GetMouseFocus():GetParent():GetParent():GetName()
                    local id = tonumber(string.sub(name, 19, 20))
                  for k, v in CT_RA_MainTanks do
                    if k == id then
		       for i = 1, GetNumRaidMembers(), 1 do
				if ( C_UnitName("raid" .. i) == CT_RA_MainTanks[k] ) then
					unit = "raid" .. i
					break
				end
	              end
                    end
                  end
                end
        elseif(string.find(frame, "CT_AssistFrame")) then
                unit = "targettarget"
        elseif(UnitExists("mouseover")) then
		unit = C_AKA("mouseover")
	end
	Heart_MouseHeal(unit, button)
end

function Heart_Tank_Clicks(num, button)
         local id = tonumber(num)
         if (IsAddOnLoaded("CT_RaidAssist")) then
	         for k, v in CT_RA_MainTanks do
                     if k == id then
		        for i = 1, GetNumRaidMembers(), 1 do
				if ( C_UnitName("raid" ..i) == CT_RA_MainTanks[k] ) then
					local unit = "raid" .. i
					Heart_MouseHeal(unit, button)
				end
	                end
                      end
                end
          elseif (IsAddOnLoaded("oRA")) then
	         for k, v in oRA_MainTank.MainTankTable do
                     if k == id then
		        for i = 1, GetNumRaidMembers(), 1 do
				if ( C_UnitName("raid" ..i) == oRA_MainTank.MainTankTable[k] ) then
					local unit = "raid" .. i
					Heart_MouseHeal(unit, button)
				end
	                end
                      end
                end
          end
end

function Heart_Party_Clicks(unit, button)
         if UnitExists(unit) then
            Heart_MouseHeal(unit, button)
         end
end

--   ################
--  # 核心治疗 #
-- #   函数  #
--################

function Heart_Heal(unit, spell, rank, healvalue, noscale)
        local selfcasting = GetCVar("autoSelfCast");
        SetCVar("autoSelfCast",0);
	-- 用指定的法术和等级治疗指定单位（必要时降级）
	if (not unit or not spell or not rank or not UnitExists(unit)) then
		SetCVar("autoSelfCast",selfcasting)
                return
	end
	local UnitXP_SP3 = pcall(UnitXP, "nop", "nop");
	-- 检查目标是否在视野内
	if UnitXP_SP3 then
	if UnitExists(unit) then
		-- 检查是否有障碍物卡视野
		if (not UnitXP("inSight", unit, "player")) then
			-- 目标被障碍物遮挡，跳过
			SetCVar("autoSelfCast",selfcasting)
			return
		end
		
		-- 检查目标距离
		local _, unitID = UnitExists(unit)
		local distance = UnitXP("distanceBetween", "player", unitID)
		if (distance and distance > 40) then
			-- 目标距离超过40码，跳过
			SetCVar("autoSelfCast",selfcasting)
			return
		end
	end
    end

    if  SUPERWOW_STRING then
		_, playerGUID = UnitExists("player")
		 _, targetGUID = UnitExists(unit)
	CastingSpeed:CleanExpiredCastData()	 
    if not CastingSpeed:ShouldHealTarget(targetGUID, playerGUID, Heart_Spells[spell][rank]["ID"]) then
		SetCVar("autoSelfCast",selfcasting)
         return
       end
    end
    

	if (Heart_casting_spell) then
		if (Heart_Config["safe_cancel"] == 0 or Heart_GetOverheal() > Heart_Config["max_overheal"]) then
			SpellStopCasting()
		end
		SetCVar("autoSelfCast",selfcasting)
		return 1
	end
	if (not Heart_Spells) then
		Heart_UpdateSpells()
	end
	if (not Heart_Spells[spell] or not Heart_Spells[spell][rank]) then
	        SetCVar("autoSelfCast",selfcasting)
		return
	end
	if (GetSpellCooldown(Heart_Spells[spell][rank]["ID"], BOOKTYPE_SPELL) > 0) then
		-- 冷却中
		SetCVar("autoSelfCast",selfcasting)
		return
	end
	C_UpdatePlayerData()
	if ( (not(Heart_rez_spells[spell])) and (not Heart_CanHeal(unit)) ) then
	        SetCVar("autoSelfCast",selfcasting)
		return
	end
	if (Heart_rez_spells[spell]) and (not Heart_CanRez(unit))  then
	        SetCVar("autoSelfCast",selfcasting)
	        return
        end
	if (spell == C_Power_word_shield and (C_UnitGotDebuff(unit, C_Weakened_soul) or C_UnitGotBuff(unit, C_Ice_barrier) or C_UnitGotBuff(unit, C_Power_word_shield))) then
		-- 对有虚弱灵魂的人施放盾，这是不允许的
		SetCVar("autoSelfCast",selfcasting)
		return
	end
	if ((spell == C_Divine_shield or spell == C_Divine_protection or spell == C_Blessing_of_protection) and C_UnitGotDebuff(unit, C_Forbearance)) then
		-- 对有自律的人施放圣骑士盾
		SetCVar("autoSelfCast",selfcasting)
		return
	end
	-- 使用系统自带的IsBuffActive函数直接检查目标是否有恢复/回春术效果
	local hasBuff = false
	if (spell == C_Renew and IsBuffActive(C_Renew, unit)) then
		hasBuff = true -- 施放恢复术时检查目标是否已有恢复
	elseif (spell == C_Rejuvenation and IsBuffActive(C_Rejuvenation, unit)) then
		hasBuff = true -- 施放回春术时检查目标是否已有回春
	end
	if (spell ~= C_Greater_heal and hasBuff) then
		-- 有回春术/恢复时不再释放对应的技能，但愈合术不受限制
		SetCVar("autoSelfCast",selfcasting)
		return
	end
	if (spell == C_Swiftmend and not (C_UnitGotBuff(unit, C_Regrowth) or C_UnitGotBuff(unit, C_Rejuvenation))) then
		-- 试图对没有愈合/回春术的人施放迅捷治愈，返回
		SetCVar("autoSelfCast",selfcasting)
		return
	end
	if ((C_my_class == C_Druid and C_UnitGotBuff("player", C_Clearcasting)) or (C_my_class == C_Priest and C_UnitGotBuff("player", C_Inner_focus))) then
		-- 清晰预兆/心灵专注，使用最高等级
		rank = table.getn(Heart_Spells[spell])
	else
		while (rank > 0 and Heart_Spells[spell][rank]["Mana"] > UnitMana("player")) do
			-- 法力不足，降级
			rank = rank - 1
		end
	end
	while (Heart_spell_level[spell] and rank > 0 and UnitLevel(unit) < Heart_spell_level[spell][rank]) do
		-- 目标等级太低，降级
		rank = rank - 1
	end
	if (rank == 0) then
		-- 法力不足
		SetCVar("autoSelfCast",selfcasting)
		return
	end
	if (healvalue and not C_UnitGotBuff("player", C_Clearcasting) and (not (noscale and noscale == 1))) then
		-- 降级以使用"正确"的等级
		rank = Heart_ScaleSpell(unit, spell, rank, healvalue)
	end
	Heart_error_message = nil
	Heart_check_for_client_error = nil
	if (UnitExists("target") and (spell == C_Holy_shock or UnitIsFriend("player", "target")) and not UnitIsUnit(unit, "target")) then
		Heart_target_last_target = 1
		if (unit == "targettarget") then
			TargetUnit(unit)
		else
			ClearTarget()
		end
	end
	local checkname, checkrank = GetSpellName(Heart_Spells[spell][rank]["ID"], BOOKTYPE_SPELL)
	local start, stop, checkrank = string.find((checkrank or ""), "(%d+)")
	checkrank = (checkrank or 1) / 1.0
	if (checkname ~= spell or checkrank ~= rank) then
		Heart_UpdateSpells()
	end
	CastSpell(Heart_Spells[spell][rank]["ID"], BOOKTYPE_SPELL)
	if (SpellCanTargetUnit(unit)) then
		SpellTargetUnit(unit, true)
	end
	SetCVar("autoSelfCast",selfcasting)
	if (Heart_error_message) then
		-- 好的，我们遇到了一个错误，需要弄清楚该怎么处理
		if (Heart_error_moving[Heart_error_message]) then
			-- 我们正在移动，只允许瞬发法术
			Heart_only_instant_spells = 1
		end
		for error,msg in Heart_error_unable do
                if (string.find(Heart_error_message, msg)) then
		       return 1
		end
		end
	end
	if (Heart_check_for_client_error) then
		-- 客户端检测到错误（我们是否在坐下？）
		if (Heart_target_last_target) then
			TargetLastTarget()
			Heart_target_last_target = nil
		end
		return
	end
	if (SpellIsTargeting()) then
		-- 嗯，我们真的不应该再瞄准了。另一个错误？
		SpellStopTargeting()
		if (Heart_target_last_target) then
			TargetLastTarget()
			Heart_target_last_target = nil
		end
		return
	end
	if (Heart_target_last_target) then
		TargetLastTarget()
		Heart_target_last_target = nil
	end
	local name = C_UnitName(unit)
	if (string.find(unit, "pet")) then
		-- pet
		if (unit == "pet") then
			name = C_UnitName("player") .. "-" .. name
		else
			name = C_UnitName(string.gsub(unit, "pet", "")) .. "-" .. name
		end
	end
	local casttime = Heart_Spells[spell][rank]["CastTime"]
	if C_UnitGotBuff("player", C_Natures_swiftness) then casttime = 0 end
	local heal, healmin, healmax, hot = Heart_GetSpellHealing(unit, spell, rank)
	local cancelheal = heal
	if (healvalue and healvalue < heal) then
		cancelheal = healvalue
	end

	Heart_healing[name] = (Heart_healing[name] or {})
	if (Heart_healing[name][C_my_name] and Heart_healing[name][C_my_name]["Bar"]) then
		local bar = getglobal("Heart_GUIHealBars" .. Heart_healing[name][C_my_name]["Bar"])
		bar:SetMinMaxValues(666, 1337)
		bar:Hide()
	end

	Heart_healing = {
                [name] = {
                     [C_my_name] = {
		                 ["CancelHeal"] = cancelheal,
		                 ["CastTime"] = casttime,
		                 ["Heal"] = (healmin + healmax) / 2,
		                 ["HealingOverTime"] = hot,
		                 ["Rank"] = rank,
		                 ["Spell"] = spell,
		                 ["Status"] = "Active",
		                 ["TankHealing"] = (not healvalue),
		                 ["TimeLeft"] = casttime
		     }
		}
	}
	Heart_i_am_healing = name

	-- 只有当show_spell_rank_heal为1时才显示法术等级和治疗量预估
		if Heart_Config["show_spell_rank_heal"] == 1 then
			Heart_GUIHealCurrentSpellText:SetText(spell .. " " .. rank .. " - " .. math.floor((healmin + healmax) / 2) .. " / " .. math.floor(hot))
			Heart_GUIHealCurrentSpell:Show()
		else
			Heart_GUIHealCurrentSpellText:SetText("")
			Heart_GUIHealCurrentSpell:Hide()
		end
	Heart_GUIHealCurrentSpell:SetMinMaxValues(0, casttime)
	Heart_GUIHealCurrentTarget:SetMinMaxValues(0, UnitHealthMax(unit))
	Heart_GUIHealCurrentAfter:SetMinMaxValues(0, UnitHealthMax(unit))
	Heart_GUIHealCurrentOverheal:SetMinMaxValues(0, 1)
	Heart_GUIHealCurrent:SetAlpha(1.0)
	Heart_GUIHealCurrent:Show()
	Heart_UpdateHealCurrent()
     -- 播报SendAddonMessage("Heart", "Update, " .. name .. ", " .. spell .. ", " .. (healmin + healmax) / 2 .. ", " .. hot .. ", " .. casttime .. ", " .. casttime, "RAID")
	return 1
end

function Heart_HealUsingClass(unit, class, healvalue)
	if (not unit or not class or not Heart_Config["classes"][class]) then
		return
	end
	local percent = (UnitHealth(unit) / UnitHealthMax(unit)) * 100
	if (healvalue and (percent / 100) > Heart_Config["min_heal_threshold"]) then
		-- 不是目标治疗，且单位血量高于最低治疗阈值
		return
	end
	local spell = 1
	local spellstried = {}
	local lastpercent
	local attachment
	while (spell) do
		spell = nil
		lastpercent = nil
		local curspell = nil
		local rank = nil
		local noscale = nil
		for curpercent, data in Heart_Config["classes"][class] do
                        curspell = data["Spell"]
			if (not spellstried[curspell] and (not spell or (curpercent >= percent and lastpercent < percent) or (lastpercent > percent and curpercent >= percent and curpercent < lastpercent))) then
				-- ^^ 世界纪录（译注：原文为"world record"，指这段逻辑复杂度高）
				-- 它"简单地"确定要使用哪个法术
				if (not spell or (lastpercent and curpercent ~= lastpercent)) then
					spell = curspell
				end
				lastpercent = curpercent
				spell = curspell
				rank = data["Rank"]
				attachment = nil
	                        noscale = data["Scale"]
	                        if data["Attachment"] then
	                           attachment = data["Attachment"]
	                        end
			end
		end
		if (spell) then
			if (healvalue and lastpercent < percent) then
				-- 最高百分比的法术低于玩家的生命值百分比
				return
			end
			if (not rank) then
				rank = table.getn(Heart_Spells[spell])
			end
			if (attachment and not (Heart_only_instant_spells)) then
			   local attachrank = table.getn(Heart_Spells[attachment])
			   if not(Heart_attachment_global_cooldown[attachment] and Heart_attachment_has_target[attachment]) then
			      if GetSpellCooldown(Heart_Spells[attachment][attachrank]["ID"], BOOKTYPE_SPELL) > 0 then
			      else
			          CastSpell(Heart_Spells[attachment][attachrank]["ID"], BOOKTYPE_SPELL)
			          SpellStopCasting()
			      end
                           else
                              if (Heart_Heal(unit, attachment, attachrank, healvalue)) then
                                           return 1
                              end
                           end   
			end
			if ((not Heart_only_instant_spells or Heart_Spells[spell][rank]["CastTime"] == 0) and Heart_Heal(unit, spell, rank, healvalue, noscale)) then
				-- 似乎正在治疗
				Heart_only_instant_spells = nil
				return 1
			end
			spellstried[spell] = 1
		end
	end
	Heart_only_instant_spells = nil
	return
end
      
function Heart_ActionHeal(spell, rank)
	    if  SUPERWOW_STRING then
		_, playerGUID = UnitExists("player")
		 _, targetGUID = UnitExists(unit)
	CastingSpeed:CleanExpiredCastData() 	
    -- 检查spell和rank是否有效
    local spellData = spell and rank and Heart_Spells[spell] and Heart_Spells[spell][rank] or nil
    if spellData and not CastingSpeed:ShouldHealTarget(targetGUID, playerGUID, spellData["ID"]) then
		SetCVar("autoSelfCast",selfcasting)
             SpellStopCasting()
       end
    end

	if (Heart_casting_spell) then
		if (Heart_Config["safe_cancel"] == 0 or Heart_GetOverheal() > Heart_Config["max_overheal"]) then
			SpellStopCasting()
		end
		return 1
       end
	if (Heart_IsHealModifierKeyDown("heal_self_modifier") or Heart_IsHealModifierKeyDown("heal_targettarget_modifier") or (UnitExists("target") and UnitIsFriend("player", "target")) or (Heart_Tank and Heart_Tank["Name"]) or enemy_with_friendtarget()) then
                    -- 看起来我们想要治疗这个人
		local unit = C_AKA("target")
		local healvalue = nil
		if (Heart_Tank and Heart_Tank["Name"]) and not((Heart_IsHealModifierKeyDown("heal_self_modifier")) or (Heart_IsHealModifierKeyDown("heal_targettarget_modifier") and UnitExists("target"))) then
		   if (Heart_Tank["Name"] ~= C_UnitName(Heart_Tank["Unit"])) then
			  local aka = C_UnitName(Heart_Tank["Name"])
			  if (aka) then
				-- 不知何故我们的坦克有了新ID
				Heart_Tank["Unit"] = aka
                                unit = aka
                          else
				-- 我们的坦克不见了 :\
				C_Print(Heart_Tank["Name"] .. " 不在队伍/团队中。坦克模式已关闭。")
				Heart_Tank = {
			               ["Name"] = nil,
			               ["Unit"] = nil
                                }
			end
		   end
		   unit = Heart_Tank["Unit"]
		elseif (Heart_IsHealModifierKeyDown("heal_self_modifier")) then
			unit = "player"
		elseif ((Heart_IsHealModifierKeyDown("heal_targettarget_modifier") and UnitExists("target")) or enemy_with_friendtarget()) then
			-- 治疗"targettarget"
					if (not UnitExists("targettarget") or not Heart_CanHeal("targettarget")) then
				-- 无法治疗targettarget，确保我们不治疗"target"
				return 1
			end
			unit = C_AKA("targettarget")
		elseif (UnitExists("target") and UnitIsEnemy("player", "target") and UnitExists("targettarget")) then
			-- 目标是敌方时，治疗目标的目标
			if (not Heart_CanHeal("targettarget")) then
				-- 无法治疗targettarget，确保我们不治疗"target"
				return 1
			end
			unit = C_AKA("targettarget")
		end
		    if (not rank) then
                        if (Heart_IsHealModifierKeyDown("heal_max_modifier") or Heart_Config["always_tank_target"] == 1) then
                        else
                                healvalue = Heart_GetHealValue(unit)
                        end
			Heart_HealUsingClass(unit, spell, healvalue)
		    else
                        if (Heart_IsHealModifierKeyDown("heal_max_modifier") or Heart_Config["always_tank_target"] == 1) then
                        else
                                healvalue = Heart_GetHealValue(unit)
                        end
			Heart_Heal(unit, spell, rank, healvalue)
		    end
		return 1
	elseif (not UnitExists("target") or not UnitIsFriend("player", "target")) then
		-- 敌对目标或无目标且使用治疗法术：治疗最重伤员
		Heart_HealMostWounded(spell, rank)
		-- 如果我们已经钩子了这个法术，就不应该调用原始的UseAction
		return 1
	end
	return
end

function enemy_with_friendtarget()
	if UnitExists("target") and UnitIsEnemy("player","target") then
		if UnitExists("targettarget") then
			return UnitIsFriend("player","targettarget")
		end
	end
	return nil
end
