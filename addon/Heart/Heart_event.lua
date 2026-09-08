-- # 加载、事件、更新和命令 #
--#######################################
function Heart_OnLoad()
        Heart_healing = {}
        Heart_item_heal_bonus_cache = {}
        Heart_raid_cache = {}
        

        C_my_class = UnitClass("player")
	C_my_name = C_UnitName("player")

	this:RegisterEvent("PLAYER_LOGIN")
	this:RegisterEvent("VARIABLES_LOADED")

	SLASH_Heart1 = "/heart"
	SlashCmdList["Heart"] = function(msg)
		Heart_Command(msg)
	end

end

function Heart_OnEvent()
	if (event == "CHAT_MSG_ADDON" and arg1 and arg2 and arg3 and arg4 and (arg1 == "Heart" or arg1 == "Genesis" or arg1 == "Panza" or arg1 == "Healer")) then
		Heart_Receive(arg4, arg2)
	elseif (event == "LEARNED_SPELL_IN_TAB") then
		Heart_UpdateSpells()
	elseif (event == "PLAYER_ENTERING_WORLD") then
		-- 我们进入了新区域，显然已经离开战斗
		C_player_in_combat = nil
		-- 而且显然我们没有在施法
		Heart_casting_spell = nil
	elseif (event == "PLAYER_LOGIN") then
                Heart_UpdateSpells()
		Heart_SetupSettings()
	        this:RegisterEvent("CHAT_MSG_ADDON")
		if (not Heart_supported_classes[C_my_class]) then
			-- 我们不是治疗职业，让我们修改"OnUpdate"方法
			Heart_OnUpdate = function(elapsed)
		               Heart_UpdateHealing(elapsed)
			end
			-- 然后返回，不需要再注册/钩入更多函数
			return
		else
		--在0.14版本中使用Sea Hooks
	        Sea.util.hook("UseAction","Heart_UseAction","replace")
			Sea.util.hook("CastSpellByName","Heart_CastSpellByName","before")
 			Sea.util.hook("CastSpell","Heart_CastSpell","before")
                        Sea.util.hook("SpellTargetUnit", "Heart_SpellTargetUnit", "before")

                        local WorldFrameMouseDown = WorldFrame:GetScript("OnMouseDown")
                        if WorldFrameMouseDown then
                           WorldFrame:SetScript("OnMouseDown", function() Heart_MouseDown(); WorldFrameMouseDown(); end )
                        else
                           WorldFrame:SetScript("OnMouseDown", function() Heart_MouseDown(); end )
                        end

                        Sea.util.hook("SpellStopCasting","Heart_SpellStopCasting","before")
                        
                        Sea.util.hook("SpellStopTargeting","Heart_SpellStopTargeting","before")

                        Sea.util.hook("PlayerFrame_OnClick","Heart_PlayerFrame_OnClick","replace")

                        Sea.util.hook("TargetFrame_OnClick","Heart_TargetFrame_OnClick","replace")

                        Sea.util.hook("PartyMemberFrame_OnClick", "Heart_PartyMemberFrame_OnClick","replace")
  			
                        Sea.util.hook("RaidPulloutButton_OnClick","Heart_RaidPulloutButton_OnClick","replace")
		        
                        
                        Sea.util.hook("TargetFrame_Update", "Heart_TargetFrame_Update", "replace")

                        this:RegisterEvent("LEARNED_SPELL_IN_TAB")
	        this:RegisterEvent("PLAYER_ENTERING_WORLD")
	        this:RegisterEvent("PLAYER_LEAVING_WORLD")
	        this:RegisterEvent("PLAYER_REGEN_DISABLED")
	        this:RegisterEvent("PLAYER_REGEN_ENABLED")
	        this:RegisterEvent("RAID_ROSTER_UPDATE")
	        this:RegisterEvent("SPELLCAST_DELAYED")
	        this:RegisterEvent("SPELLCAST_FAILED")
	        this:RegisterEvent("SPELLCAST_INTERRUPTED")
	        this:RegisterEvent("SPELLCAST_START")
	        this:RegisterEvent("SPELLCAST_STOP")
	        this:RegisterEvent("UI_ERROR_MESSAGE")
	        this:RegisterEvent("UNIT_INVENTORY_CHANGED")
		end

	elseif (event == "PLAYER_REGEN_DISABLED") then
		-- 能量回复被禁用，意味着我们在战斗中
		C_player_in_combat = 1
	elseif (event == "PLAYER_REGEN_ENABLED") then
		-- 能量回复被启用，意味着我们离开了战斗
		C_player_in_combat = nil
	elseif (event == "RAID_ROSTER_UPDATE") then
		Heart_SetRaidChecked()
	elseif (event == "SPELLCAST_DELAYED" and Heart_i_am_healing and arg1) then
		-- 我们当前的施法不知何故被延迟了
		local healingtarget = Heart_i_am_healing
		if (not Heart_healing[healingtarget] or not Heart_healing[healingtarget][C_my_name] or Heart_healing[healingtarget][C_my_name]["Complete"]) then
			return
		end
		Heart_healing[healingtarget][C_my_name]["TimeLeft"] = Heart_healing[healingtarget][C_my_name]["TimeLeft"] + arg1 / 1000
               -- 广播治疗更新信息: SendAddonMessage("Heart", "Update, " .. healingtarget .. ", " .. Heart_healing[healingtarget][C_my_name]["Spell"] .. ", " .. Heart_healing[healingtarget][C_my_name]["Heal"] .. ", " .. Heart_healing[healingtarget][C_my_name]["HealingOverTime"] .. ", " .. Heart_healing[healingtarget][C_my_name]["CastTime"] .. ", " .. Heart_healing[healingtarget][C_my_name]["TimeLeft"], "RAID")
	elseif (event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_STOP") then
		-- 我们的施法失败、被打断或停止了
		local wascasting = Heart_casting_spell
		Heart_casting_spell = nil
		Heart_check_for_client_error = 1
		local healingtarget = Heart_i_am_healing
		if (not healingtarget or not Heart_healing[healingtarget] or not Heart_healing[healingtarget][C_my_name]) then
			return
		end
		if (event == "SPELLCAST_FAILED") then
			Heart_healing[healingtarget][C_my_name]["Status"] = "Failed"
			if ((Heart_awaiting_rez[C_GetUnitID(healingtarget)])) then
                           Heart_awaiting_rez[C_GetUnitID(healingtarget)]["status"] = "int"
	        end
		elseif (event == "SPELLCAST_INTERRUPTED") then
			if ((Heart_awaiting_rez[C_GetUnitID(healingtarget)])) then
                           Heart_awaiting_rez[C_GetUnitID(healingtarget)]["status"] = "int"
	        end
			Heart_healing[healingtarget][C_my_name]["Status"] = "Interrupted"
		elseif (not wascasting) then
			-- 我们在收到"开始"信号之前收到了"停止"信号？
			-- 什么都不做，返回
			return
		elseif (event == "SPELLCAST_STOP") then
	        if ((Heart_awaiting_rez[C_GetUnitID(healingtarget)]) and (Heart_awaiting_rez[C_GetUnitID(healingtarget)]["status"] == "start")) then
	           Heart_awaiting_rez[C_GetUnitID(healingtarget)]["cast"] = 0.5
	           Heart_awaiting_rez[C_GetUnitID(healingtarget)]["status"] = "stop"
                        end
			Heart_healing[healingtarget][C_my_name]["Status"] = "Stop"
		end
		-- 尝试改进"治疗最重伤员"功能，短暂"禁止"治疗最后治疗过的玩家
		-- 可以使用"UNIT_HEALTH"事件来监控，但该事件会一直触发，浪费CPU
		-- 300毫秒的禁止应该足够了，如果玩家的生命值非常低，那么很可能
		-- 还有10个其他治疗正在尝试治疗那个玩家。
		Heart_soft_lock_player = C_GetUnitID(healingtarget)
		Heart_soft_lock_time = 0.3

		Heart_healing[healingtarget][C_my_name]["Complete"] = 1
		-- Heart_healing[healingtarget][C_my_name]["TimeLeft"] = -1
		-- 广播施法状态信息: SendAddonMessage("Heart", Heart_healing[healingtarget][C_my_name]["Status"] .. ", " .. healingtarget .. ", " .. Heart_healing[healingtarget][C_my_name]["Spell"] .. ", " .. Heart_healing[healingtarget][C_my_name]["Heal"] .. ", " .. Heart_healing[healingtarget][C_my_name]["HealingOverTime"] .. ", " .. Heart_healing[healingtarget][C_my_name]["CastTime"] .. ", " .. Heart_healing[healingtarget][C_my_name]["TimeLeft"], "RAID")
	elseif (event == "SPELLCAST_START" and arg2) then
		-- 我们刚刚开始施法
		Heart_casting_spell = 1
		local healingtarget = Heart_i_am_healing
		if Heart_spell_awaiting_target_Spell then
			if  Heart_spell_awaiting_target_Target then
			Heart_SpellTargetUnit(Heart_spell_awaiting_target_Target,false);
			elseif UnitExists("target") then
			Heart_SpellTargetUnit("target",false);
			elseif UnitExists("mouseover") then
			Heart_SpellTargetUnit("mouseover",false);
			else
			clean_spell_awaiting_target()
			end
		end

		if (not healingtarget or not Heart_healing[healingtarget] or not Heart_healing[healingtarget][C_my_name] or Heart_healing[healingtarget][C_my_name]["Complete"]) then
			return
		end
		arg2 = arg2 / 1000
		if (arg2 == Heart_healing[healingtarget][C_my_name]["CastTime"]) then
			
			-- 施法时间正确，无需通知所有人
			return
		end
		Heart_healing[healingtarget][C_my_name]["TimeLeft"] = Heart_healing[healingtarget][C_my_name]["TimeLeft"] + arg2 - Heart_healing[healingtarget][C_my_name]["CastTime"]
		Heart_healing[healingtarget][C_my_name]["CastTime"] = arg2

		 -- 广播施法更新信息: SendAddonMessage("Heart", "Update, " .. healingtarget .. ", " .. Heart_healing[healingtarget][C_my_name]["Spell"] .. ", " .. Heart_healing[healingtarget][C_my_name]["Heal"] .. ", " .. Heart_healing[healingtarget][C_my_name]["HealingOverTime"] .. ", " .. Heart_healing[healingtarget][C_my_name]["CastTime"] .. ", " .. Heart_healing[healingtarget][C_my_name]["TimeLeft"], "RAID")
	elseif (event == "UI_ERROR_MESSAGE") then
		Heart_error_message = arg1
	elseif (event == "UNIT_INVENTORY_CHANGED" and arg1 and arg1 == "player") then
		-- 玩家可能更换了装备
		-- 重新计算治疗加成
		Heart_UpdateItemHealBonus()
	elseif (event == "VARIABLES_LOADED") then
	end
end


function Heart_OnUpdate(elapsed)
	
	-- 计算角色是否在移动
	local x, y = GetPlayerMapPosition("player")
	
	if x ~= prevX or y ~= prevY then
		if not MPPlayerIsMoving then
			MPPlayerIsMoving = true
		end
	else
		if MPPlayerIsMoving then
			MPPlayerIsMoving = false
		end
	end
	
	prevX, prevY = x, y
	
	last_update=last_update+elapsed;
	if (last_update>0.02) then
	Heart_UpdateHealCurrent(last_update)
	Heart_UpdateHealing(last_update)
        Heart_UpdateDead(last_update)
	last_update=0;


        --if Heart_spell_awaiting_target_Spell then
          -- if not SpellIsTargeting() then
            --  Heart_spell_awaiting_target_Spell = nil
              --Heart_spell_awaiting_target_Rank = nil
           --end
        --end
end
	Heart_update_player_data_time = (Heart_update_player_data_time or 0) +elapsed 
	if (Heart_update_player_data_time > (C_update_player_data_interval or 0)) then
		C_UpdatePlayerData(Heart_update_player_data_time)
		Heart_update_player_data_time = 0
	end
	if (Heart_soft_lock_player and Heart_soft_lock_time) then
		Heart_soft_lock_time = Heart_soft_lock_time - elapsed
		if (Heart_soft_lock_time < 0) then
			Heart_soft_lock_time = nil
			Heart_soft_lock_player = nil
		end
	end
	

end

function Heart_Command(msg)
	if (not msg or msg == "") then
		-- 显示/隐藏界面
		if (Heart_GUI:IsShown()) then
			Heart_GUI:Hide()
		else
			Heart_GUI:Show()
		end
		return
	end
	
	msg = string.lower(msg)
	if (string.find(msg, "^save")) then
		-- 保存我们的设置
		local start, stop, profile = string.find(msg, "^save (.+)$")
		if (not profile) then
			C_Print("你必须指定要保存设置的配置文件名。")
			return
		end
		Heart_Save_Profile(profile)
		C_Print("设置已保存为配置文件\"" .. profile .. "\"")
	elseif (string.find(msg, "^load")) then
		-- 加载我们的设置
		local start, stop, profile = string.find(msg, "^load (.+)$")
		if (not profile) then
			C_Print("你必须指定要从哪个配置文件加载设置。")
			return
		end
		if (not Heart_SavedProfiles[profile]) then
			C_Print("找不到配置文件\"" .. profile .. "\"", "|cffff0000")
			return
		end
		Heart_Load_Profile(profile)
		C_Print("配置文件\"" .. profile .. "\"已加载。")
	elseif (string.find(msg, "^delete")) then
		-- 删除已保存的配置文件
		local start, stop, profile = string.find(msg, "^delete (.+)$")
		if (not profile) then
			C_Print("你必须指定要删除的配置文件。")
			return
		end
		if (not Heart_SavedProfiles[profile]) then
			C_Print("找不到配置文件\"" .. profile .. "\"", "|cffff0000")
			return
		end
		Heart_SavedProfiles[profile] = nil
		C_Print("配置文件\"" .. profile .. "\"已删除。")
		Heart_GUIProfileDropDownMenu:Hide()
		Heart_GUIProfileDropDownMenu:Show()
	elseif (msg == "list") then
		-- 列出我们的配置文件
		C_Print("已保存的配置文件：")
		local found
		for profile, data in Heart_SavedProfiles do
			C_Print(profile)
			found = 1
		end
		if (not found) then
			C_Print("没有保存的配置文件")
		end
	elseif (msg == "gui") then
	       if Heart_ClickFrame:IsVisible() then
	          Heart_ClickFrame:Hide()
	          Heart_Config["hide_gui"] = 1
	       else
	           Heart_ClickFrame:Show()
	          Heart_Config["hide_gui"] = 0
	       end
	elseif (msg == "opt") then
	       if Heart_GUI:IsVisible() then 
		  Heart_GUI:Hide() 
		else 
		  Heart_GUI:Show() 
		end 
	elseif (msg == "mm") then
	       if HeartMinimapButton:IsVisible() then
                  MyMinimapButton:SetEnable("Heart",0)
	          Heart_Config["hide_mm"] = 1
	       else
                  MyMinimapButton:SetEnable("Heart",1)
	          Heart_Config["hide_mm"] = 0
	       end
	elseif (msg == "tank") then
	        local aka = nil
	        if (UnitExists("target") and UnitIsFriend("player", "target")) then
                   aka = C_AKA("target")
                end
		if (aka) then
		   if ( aka ~= "target" or UnitIsUnit("player", aka)) then
			Heart_Tank = {
				["Unit"] = aka,
				["Name"] = C_UnitName(aka)
			}
			C_Print("将只治疗(" ..aka.."): ".. Heart_Tank["Name"])
		   else
		        C_Print("坦克单位必须在你的团队或小队中：" .. C_UnitName(aka) .. " 不在其中")
		        if (Heart_Tank and Heart_Tank["Name"]) then
		               C_Print("当前坦克保持不变(" ..Heart_Tank["Unit"].."): ".. Heart_Tank["Name"])
		        else
		               C_Print("没有专用治疗")
		        end
		   end
		else
			if (Heart_Tank and Heart_Tank["Name"]) then
				C_Print("将不再只治疗 " .. Heart_Tank["Name"])
		         else
				C_Print("没有专用治疗")
			end
			Heart_Tank = {
				["Unit"] = nil,
				["Name"] = nil
			}
                end
		return
	elseif (msg == "help") then
		-- 显示帮助
		C_Print("用法：")
		C_Print("/heart save <配置文件>|cffffffff   - 将当前设置保存到<配置文件>")
		C_Print("/heart load <配置文件>|cffffffff   - 从<配置文件>加载设置")
		C_Print("/heart list|cffffffff             - 列出所有已保存的配置文件")
		C_Print("/heart delete <配置文件>|cffffffff - 删除<配置文件>")
		C_Print("/heart gui|cffffffff              - 隐藏/显示界面元素")
		C_Print("/heart mm|cffffffff               - 隐藏/显示小地图按钮")
		C_Print("/heart opt|cffffffff              - 隐藏/显示选项面板")
	else
		-- 可能正在使用职业进行治疗
		Heart_ActionHeal(msg, nil)
	end
end

