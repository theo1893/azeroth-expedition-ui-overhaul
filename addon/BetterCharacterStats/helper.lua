BCS = BCS or {}


local BCS_Tooltip = getglobal("BetterCharacterStatsTooltip") or CreateFrame("GameTooltip", "BetterCharacterStatsTooltip", nil, "GameTooltipTemplate")
local BCS_Prefix = "BetterCharacterStatsTooltip"
BCS_Tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

local L = BCS["L"]
local L_RACE = BCS["L_RACE"]
local L_TALENT = BCS["L_TALENT"]
local L_HASTE = BCS["L_HASTE"]
local L_ARMOR = BCS["L_ARMOR"]
local L_FORM = BCS["L_FORM"]
local L_SPELLHIT = BCS["L_SPELLHIT"]
local L_SPELLCRIT = BCS["L_SPELLCRIT"]
local L_MANAREGEN = BCS["L_MANAREGEN"]
local L_SPELL_SCHOOL = BCS["L_SPELL_SCHOOL"]
local L_SPELLPOWER = BCS["L_SPELLPOWER"]
local L_HEALPOWER = BCS["L_HEALPOWER"]
local L_HIT = BCS["L_HIT"]
local L_BLOCKVALUE = BCS["L_BLOCKVALUE"]
local L_ARMORPENETRATION = BCS["L_ARMORPENETRATION"]
local L_WEAPONTYPE = BCS["L_WEAPONTYPE"]


local strfind = strfind
local tonumber = tonumber
local tinsert = tinsert
local lclass,class = UnitClass("player")



local BCS_USE_CACHE = 1
local BCS_GET_ON_DEMAND = 1
local VERSION = "1.0.11-SNAPSHOT"

local MELEE_HIT = 0
local GET_MELEE_HIT_TIME =0
local HASTE_CACHE = 0
local GET_HASTE_CACHE_TIME = 0
local SPELL_CRIT = 0
local GET_SPELL_CRIT_TIME = 0
local RANGE_HIT = 0
local GET_RANGE_HIT_TIME = 0
local SPELL_HIT = 0
local SPELL_HIT_FIRE = 0
local SPELL_HIT_FROST = 0
local SPELL_HIT_ARCANE = 0
local SPELL_HIT_SHADOW = 0
local SPELL_HIT_HOLY = 0
local GET_SPELL_HIT_TIME = 0
local MELEE_CRIT = 0
local GET_MELEE_CRIT_TIME = 0
local RANGE_CRIT = 0
local GET_RANGE_CRIT_TIME =0
local SPELL_POWER = 0
local HEAL_POWER = 0
local GET_HEAL_POWER_TIME = 0
local SPELL_POWER_IN_GETSPELLPOWER = 0
local SECOND_SPELL_POWER = 0
local SECOND_SPELL_POWER_NAME = 0
local DAMAGE_POWER = 0
local SPELL_POWER_BY_SCHOOL = {FIRE=0,FROST=0,ARCANE=0,SHADOW=0,HOLY=0,NATURE=0}
local GET_SPELL_POWER_TIME = 0
local MANA_REGEN_BASE = 0
local MANA_REGEN_CAST = 0
local MANA_REGEN_MP5 = 0
local MANA_REGEN_CAST_PERCENT = 0
local GET_MANA_REGEN_TIME = 0
local GEAR_ARMOR = 0
local GET_GEAR_ARMOR_TIME = 0
local BLOCK_VALUE = 0
local GET_BLOCK_VALUE_TIME = 0
local ARMORPENETRATION_VALUE = 0
local GET_ARMORPENETRATION_VALUE_TIME = 0


local function tContains(table, item)
	local index = 1
	while table[index] do
		if ( item == table[index] ) then
			return 1
		end
		index = index + 1
	end
	return nil
end

function BCS:GetPlayerAura(searchText, auraType)
	if not auraType then
		-- buffs
		-- http://blue.cardplace.com/cache/wow-dungeons/624230.htm
		-- 32 buffs max
		for i=0, 31 do
			local index = GetPlayerBuff(i, 'HELPFUL')
			if index > -1 then
				BCS_Tooltip:SetPlayerBuff(index)
				local MAX_LINES = BCS_Tooltip:NumLines()
					
				for line=1, MAX_LINES do
					local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
					if left:GetText() then
						local value = {strfind(left:GetText(), searchText)}
						if value[1] then
							return unpack(value)
						end
					end
				end
			end
		end
	elseif auraType == 'HARMFUL' then
		for i=0, 6 do
			local index = GetPlayerBuff(i, auraType)
			if index > -1 then
				BCS_Tooltip:SetPlayerBuff(index)
				local MAX_LINES = BCS_Tooltip:NumLines()
					
				for line=1, MAX_LINES do
					local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
					if left:GetText() then
						local value = {strfind(left:GetText(), searchText)}
						if value[1] then
							return unpack(value)
						end
					end
				end
			end
		end
	end
end

local Cache_GetHitRating_Tab, Cache_GetHitRating_Talent
local hit_debuff = 0


function BCS:GetHitRating(hitOnly)
	if BCS_GET_ON_DEMAND then 
		local on_show = 0
		local allow_options= {"PLAYERSTAT_MELEE_COMBAT","PLAYERSTAT_RANGED_COMBAT"} 
		for _,v in ipairs(allow_options) do
			if (BCSConfig["DropdownLeft"] == v) or (BCSConfig["DropdownRight"] == v) then
				on_show = 1
				break
			end
		end
		if on_show == 0 then 
			return 0
		end
	end
	if BCS_USE_CACHE == 1 then
		if MELEE_HIT and (GetTime() - GET_MELEE_HIT_TIME) < 2 then
			return MELEE_HIT
		else 
			MELEE_HIT = BCS:GetLiveHitRating(hitOnly)
			GET_MELEE_HIT_TIME = GetTime()
			return MELEE_HIT
		end
	else
		return BCS:GetLiveHitRating(hitOnly)
	end
end

function BCS:GetLiveHitRating(hitOnly)
	local Hit_Set_Bonus = {}
	local hit = 0
	local MAX_INVENTORY_SLOTS = 19
	hit_debuff = 0
	
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		if hasItem then
			local MAX_LINES = BCS_Tooltip:NumLines()
			local SET_NAME = nil
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L["Equip: Improves your chance to hit by (%d)%%."])
					if value then
						hit = hit + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["/Hit %+(%d+)"])
					if value then
						hit = hit + tonumber(value)
					end
					
					_,_, value = strfind(left:GetText(), L_HIT["Rune_of_the_Guard_Captain"])
					if value then
						hit = hit + tonumber(value)
					end
					
					_,_, value = strfind(left:GetText(), "(.+)（%d/%d）")
					if value then
						SET_NAME = value
					end
					_,_, value = strfind(left:GetText(), L["^Set: Improves your chance to hit by (%d)%%."])
					if value and SET_NAME and not tContains(Hit_Set_Bonus, SET_NAME) then
						tinsert(Hit_Set_Bonus, SET_NAME)
						hit = hit + tonumber(value)
						line = MAX_LINES
					end
				end
			end
			
		end
	end

	-- buffs
	local _, _, hitFromAura = BCS:GetPlayerAura(L["Chance to hit increased by (%d)%%."])
	if hitFromAura then
		hit = hit + tonumber(hitFromAura)
	end
	 _, _, hitFromAura = BCS:GetPlayerAura(L["Improves your chance to hit by (%d+)%%."])
	if hitFromAura then
		hit = hit + tonumber(hitFromAura)
	end
	 _, _, hitFromAura = BCS:GetPlayerAura(L["Increases attack power by %d+ and chance to hit by (%d+)%%."])
	if hitFromAura then
		hit = hit + tonumber(hitFromAura)
	end
	-- debuffs
	_, _, hitFromAura = BCS:GetPlayerAura(L["Chance to hit reduced by (%d+)%%."], 'HARMFUL')
	if hitFromAura then
		hit_debuff = hit_debuff + tonumber(hitFromAura)
	end
	_, _, hitFromAura = BCS:GetPlayerAura(L["Chance to hit decreased by (%d+)%% and %d+ Nature damage every %d+ sec."], 'HARMFUL')
	if hitFromAura then
		hit_debuff = hit_debuff + tonumber(hitFromAura)
	end
	hitFromAura = BCS:GetPlayerAura(L["Lowered chance to hit."], 'HARMFUL')
	if hitFromAura then
		hit_debuff = hit_debuff + 25
	end

	--from talent
	hit = hit + BCS:GetLiveMeleeHitRating_FromTalent()

	
	local MAX_TABS = GetNumTalentTabs()
	-- speedup
	if Cache_GetHitRating_Tab and Cache_GetHitRating_Talent then
		BCS_Tooltip:SetTalent(Cache_GetHitRating_Tab, Cache_GetHitRating_Talent)
		local MAX_LINES = BCS_Tooltip:NumLines()
		
		for line=1, MAX_LINES do
			local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
			if left:GetText() then
				-- rogues
				local _,_, value = strfind(left:GetText(), L["Increases your chance to hit with melee weapons by (%d)%%."])
				local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(Cache_GetHitRating_Tab, Cache_GetHitRating_Talent)
				if value and rank > 0 then
					hit = hit + tonumber(value)
					line = MAX_LINES
				end
				
				-- hunters
				_,_, value = strfind(left:GetText(), L["Increases hit chance by (%d)%% and increases the chance movement impairing effects will be resisted by an additional %d+%%."])
				name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(Cache_GetHitRating_Tab, Cache_GetHitRating_Talent)
				if value and rank > 0 then
					hit = hit + tonumber(value)
					line = MAX_LINES
				end
			end
		end
		
		if not hitOnly then
			hit = hit - hit_debuff
			if hit < 0 then hit = 0 end
			return hit
		else
			return hit
		end
	end
	
	for tab=1, MAX_TABS do
		local MAX_TALENTS = GetNumTalents(tab)
		
		for talent=1, MAX_TALENTS do
			BCS_Tooltip:SetTalent(tab, talent)
			local MAX_LINES = BCS_Tooltip:NumLines()
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					-- rogues
					local _,_, value = strfind(left:GetText(), L["Increases your chance to hit with melee weapons by (%d)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						hit = hit + tonumber(value)
						
						Cache_GetHitRating_Tab = tab
						Cache_GetHitRating_Talent = talent
						
						line = MAX_LINES
						talent = MAX_TALENTS
						tab = MAX_TABS
					end
					
					-- hunters
					_,_, value = strfind(left:GetText(), L["Increases hit chance by (%d)%% and increases the chance movement impairing effects will be resisted by an additional %d+%%."])
					name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						hit = hit + tonumber(value)
						
						Cache_GetHitRating_Tab = tab
						Cache_GetHitRating_Talent = talent
						
						line = MAX_LINES
						talent = MAX_TALENTS
						tab = MAX_TABS
					end
				end	
			end
			
		end
	end
	
	if not hitOnly then
		hit = hit - hit_debuff
		if hit < 0 then hit = 0 end -- Dust Cloud OP
		return hit
	else
		return hit
	end
end

function BCS:GetLiveMeleeHitRating_FromTalent()
	local hit = 0
	if class == "DRUID" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(1, 7)
		if talentname == L_TALENT.DRUID_NATURAL_WEAPONS then 
			hit = hit + crank
		end
	elseif class == "SHAMAN" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(1, 5)
		if talentname == L_TALENT.SHAMAN_ELEMENTAL_DEVASTATION then 
			hit = hit + crank
		end
	elseif class == "PALADIN" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(2, 3)
		if talentname == L_TALENT.PALADIN_PRECISION then 
			hit = hit + crank
		end
	end

	return hit
end

function BCS:GetRangedHitRating()

	if BCS_GET_ON_DEMAND then 
		local on_show = 0
		local allow_options= {"PLAYERSTAT_RANGED_COMBAT",} 
		for _,v in ipairs(allow_options) do
			if (BCSConfig["DropdownLeft"] == v) or (BCSConfig["DropdownRight"] == v) then
				on_show = 1
				break
			end
		end
		if on_show == 0 then 
			return 0
		end
	end

	if BCS_USE_CACHE == 1 then
		if RANGE_HIT and (GetTime() - GET_RANGE_HIT_TIME) < 2 then
			return RANGE_HIT
		else 
			RANGE_HIT = BCS:GetLiveRangedHitRating()
			GET_RANGE_HIT_TIME = GetTime()
			return RANGE_HIT
		end
	else
		return BCS:GetLiveRangedHitRating()
	end
	
end

function BCS:GetLiveRangedHitRating()
	local melee_hit = BCS:GetHitRating(true)
	local ranged_hit = melee_hit
	local debuff = hit_debuff

	local hasItem = BCS_Tooltip:SetInventoryItem("player", 18) -- ranged enchant
	if hasItem then
		local MAX_LINES = BCS_Tooltip:NumLines()
		for line=1, MAX_LINES do
			local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
			if left:GetText() then
				local _,_, value = strfind(left:GetText(), L["+(%d)%% Hit"])
				if value then
					ranged_hit = ranged_hit + tonumber(value)
					line = MAX_LINES
				end
			end
		end
	end
	
	ranged_hit = ranged_hit - debuff
	if ranged_hit < 0 then ranged_hit = 0 end
	return ranged_hit
end

function BCS:GetSpellHitRating()
	if BCS_GET_ON_DEMAND then 
		local on_show = 0
		local allow_options= {"PLAYERSTAT_SPELL_COMBAT",} 
		for _,v in ipairs(allow_options) do
			if (BCSConfig["DropdownLeft"] == v) or (BCSConfig["DropdownRight"] == v) then
				on_show = 1
				break
			end
		end
		if on_show == 0 then 
			return 0
		end
	end

	if BCS_USE_CACHE == 1 then
		if  (GetTime() - GET_SPELL_HIT_TIME) < 2 then
			return SPELL_HIT, SPELL_HIT_FIRE, SPELL_HIT_FROST, SPELL_HIT_ARCANE, SPELL_HIT_SHADOW ,SPELL_HIT_HOLY
		else 
			SPELL_HIT, SPELL_HIT_FIRE, SPELL_HIT_FROST, SPELL_HIT_ARCANE, SPELL_HIT_SHADOW,SPELL_HIT_HOLY = BCS:GetLiveSpellHitRating()
			GET_SPELL_HIT_TIME = GetTime()
			return SPELL_HIT, SPELL_HIT_FIRE, SPELL_HIT_FROST, SPELL_HIT_ARCANE, SPELL_HIT_SHADOW, SPELL_HIT_HOLY
		end
	else
		return BCS:GetLiveSpellHitRating()
	end
	return BCS:GetLiveSpellHitRating()
end

function BCS:GetLiveSpellHitRating()
	local hit = 0
	local hit_fire = 0
	local hit_frost = 0
	local hit_arcane = 0
	local hit_shadow = 0
	local hit_holy = 0
	local hit_Set_Bonus = {}
	
	-- scan gear
	local MAX_INVENTORY_SLOTS = 19
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		
		if hasItem then
			local SET_NAME
			local MAX_LINES = BCS_Tooltip:NumLines()
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L_SPELLHIT["Equip: Improves your chance to hit with spells by (%d)%%."])
					if value then
						hit = hit + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELLHIT["/Spell Hit %+(%d+)"])
					if value then
						hit = hit + tonumber(value)
					end

					_,_, value = strfind(left:GetText(), L_SPELLHIT["Scythe_of_Elune"])
					if value then
						hit = hit + tonumber(value)
					end
					
					_,_, value = strfind(left:GetText(), L_SPELLHIT["Rune_of_the_Guard_Captain"])
					if value then
						hit = hit + tonumber(value)
					end
					
					_,_, value = strfind(left:GetText(), "(.+)（%d/%d）")
					if value then
						SET_NAME = value
					end
					_, _, value = strfind(left:GetText(), L_SPELLHIT["^Set: Improves your chance to hit with spells by (%d)%%."])
					if value and SET_NAME and not tContains(hit_Set_Bonus, SET_NAME) then
						tinsert(hit_Set_Bonus, SET_NAME)
						hit = hit + tonumber(value)
					end
				end
			end
		
		end
	end
	
	-- scan talents

	local hit_all_from_talent, hit_fire_from_talent, hit_frost_from_talent, hit_arcane_from_talent, hit_shadow_from_talent, hit_holy_from_talent = BCS:GetLiveSpellHitRating_FromTalent()
	hit = hit + hit_all_from_talent
	hit_fire = hit_fire + hit_fire_from_talent
	hit_frost = hit_frost + hit_frost_from_talent
	hit_arcane = hit_arcane + hit_arcane_from_talent
	hit_shadow = hit_shadow + hit_shadow_from_talent
	hit_holy = hit_holy + hit_holy_from_talent
	
	-- buffs
	local _, _, hitFromAura = BCS:GetPlayerAura(L_SPELLHIT["Spell hit chance increased by (%d+)%%."])
	if hitFromAura then
		hit = hit + tonumber(hitFromAura)
	end
	local _, _, hitFromAura,_ = BCS:GetPlayerAura(L_SPELLHIT["Emerald_Essence"])
	if hitFromAura then
		hit = hit + tonumber(hitFromAura)
	end
	return hit, hit_fire, hit_frost, hit_arcane, hit_shadow , hit_holy
end

function BCS:GetLiveSpellHitRating_FromTalent()
	local hit_all = 0 
	local hit_holy = 0
	local hit_shadow = 0
	local hit_arcane = 0
	local hit_frost = 0
	local hit_fire = 0
	
	if class == "PRIEST" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(1, 2)
		if talentname == L_TALENT.PRIEST_PIERCING_LIGHT then 
			hit_holy = hit_holy + crank*2
		end

		local talentname, _, _, _, crank, _ = GetTalentInfo(3, 5)
		if talentname == L_TALENT.PRIEST_SHADOW_FOCUS then 
			hit_shadow = hit_shadow + crank*2
		end
	end

	if class == "MAGE" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(1, 5)
		if talentname == L_TALENT.MAGE_ARCANE_FOCUS then 
			hit_arcane = hit_arcane + crank*2
		end

		local talentname, _, _, _, crank, _ = GetTalentInfo(3, 3)
		if talentname == L_TALENT.MAGE_ELEMENTAL_PRECISION then 
			hit_fire = hit_fire + crank*2
			hit_frost = hit_frost + crank*2
		end
	end

	if class == "DRUID" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(1, 7)
		if talentname == L_TALENT.DRUID_NATURAL_WEAPONS then 
			hit_all = hit_all + crank
		end

	end

	if class == "SHAMAN" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(1, 5)
		if talentname == L_TALENT.SHAMAN_ELEMENTAL_DEVASTATION then 
			hit_all = hit_all + crank
		end

	end
	return hit_all, hit_fire, hit_frost, hit_arcane, hit_shadow, hit_holy
end

function BCS:GetCritChance()
	--[[
	if BCS_GET_ON_DEMAND then 
		local on_show = 0
		local allow_options= {"PLAYERSTAT_MELEE_COMBAT","PLAYERSTAT_RANGED_COMBAT",} 
		for _,v in ipairs(allow_options) do
			if (BCSConfig["DropdownLeft"] == v) or (BCSConfig["DropdownRight"] == v) then
				on_show = 1
				break
			end
		end
		if on_show == 0 then 
			return 0
		end
	end
	]]

	if BCS_USE_CACHE == 1 and (class ~= 'HUNTER') then 
		if  GET_MELEE_CRIT_TIME and (GetTime() - GET_MELEE_CRIT_TIME <2 ) then
			return MELEE_CRIT
		else 
			MELEE_CRIT = BCS:GetLiveCritChance()
			GET_MELEE_CRIT_TIME = GetTime()
			return MELEE_CRIT
		end
	else
		return BCS:GetLiveCritChance()
	end
end

function BCS:GetLiveCritChance()
	local crit = 0
	
	local MAX_TABS = GetNumTalentTabs()
	
	if class == 'HUNTER' then
		for tab=1, MAX_TABS do
			local MAX_TALENTS = GetNumTalents(tab)
			for talent=1, MAX_TALENTS do
				BCS_Tooltip:SetTalent(tab, talent)
				local MAX_LINES = BCS_Tooltip:NumLines()
				
				for line=1, MAX_LINES do
					local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
					if left:GetText() then
						local _,_, value = strfind(left:GetText(), L["Increases your critical strike chance with all attacks by (%d)%%."])
						local _, _, _, _, rank = GetTalentInfo(tab, talent)
						if value and rank > 0 then
							crit = crit + tonumber(value)
						end
					end	
				end
				
			end
		end
	end
	
	--修改by狗血编剧男
	local iCritInfo = 0
	local id = 1

	for spell_index = 1,80 do
		local spellName = GetSpellName(spell_index,BOOKTYPE_SPELL)
		if  spellName == L.SPELLBOOK_ATTACK then
			id = spell_index
			break
		end
	end
	BCS_Tooltip:SetSpell(id, BOOKTYPE_SPELL)
	local spellName = getglobal(BCS_Prefix .. "TextLeft" .. 2):GetText()
	if spellName then
		iCritInfo = string.gsub(spellName, "(.*)%%.*", "%1")
	end
	if(iCritInfo) then
		crit = crit + tonumber(iCritInfo)
	else
		crit = nil
	end
	return crit
end

local Cache_GetRangedCritChance_Tab, Cache_GetRangedCritChance_Talent, Cache_GetRangedCritChance_Line

function BCS:GetRangedCritChance()

	if BCS_GET_ON_DEMAND then 
		local on_show = 0
		local allow_options= {"PLAYERSTAT_RANGED_COMBAT",} 
		for _,v in ipairs(allow_options) do
			if (BCSConfig["DropdownLeft"] == v) or (BCSConfig["DropdownRight"] == v) then
				on_show = 1
				break
			end
		end
		if on_show == 0 then 
			return 0
		end
	end


	if BCS_USE_CACHE == 1 then 
		if  GET_RANGE_CRIT_TIME and (GetTime() - GET_RANGE_CRIT_TIME <2 ) then
			return RANGE_CRIT
		else 
			RANGE_CRIT = BCS:GetLiveRangedCritChance()
			GET_RANGE_CRIT_TIME = GetTime()
			return RANGE_CRIT
		end
	else
		return BCS:GetLiveRangedCritChance()
	end
end

function BCS:GetLiveRangedCritChance()
	local crit = BCS:GetCritChance()
	
	if Cache_GetRangedCritChance_Tab and Cache_GetRangedCritChance_Talent and Cache_GetRangedCritChance_Line then
		BCS_Tooltip:SetTalent(Cache_GetRangedCritChance_Tab, Cache_GetRangedCritChance_Talent)
		local left = getglobal(BCS_Prefix .. "TextLeft" .. Cache_GetRangedCritChance_Line)
		
		if left:GetText() then
			local _,_, value = strfind(left:GetText(), L["Increases your critical strike chance with ranged weapons by (%d)%%."])
			local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(Cache_GetRangedCritChance_Tab, Cache_GetRangedCritChance_Talent)
			if value and rank > 0 then
				crit = crit + tonumber(value)
			end
		end
	
		return crit
	end
	
	local MAX_TABS = GetNumTalentTabs()
	
	for tab=1, MAX_TABS do
		local MAX_TALENTS = GetNumTalents(tab)
		
		for talent=1, MAX_TALENTS do
			BCS_Tooltip:SetTalent(tab, talent)
			local MAX_LINES = BCS_Tooltip:NumLines()
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L["Increases your critical strike chance with ranged weapons by (%d)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						crit = crit + tonumber(value)
						
						line = MAX_LINES
						talent = MAX_TALENTS
						tab = MAX_TABS
					end
				end
			end
			
		end
	end
	
	return crit
end

function BCS:GetSpellCritChance()
	if BCS_GET_ON_DEMAND then 
		local on_show = 0
		local allow_options= {"PLAYERSTAT_SPELL_COMBAT",} 
		for _,v in ipairs(allow_options) do
			if (BCSConfig["DropdownLeft"] == v) or (BCSConfig["DropdownRight"] == v) then
				on_show = 1
				break
			end
		end
		if on_show == 0 then 
			return 0
		end
	end
	
	if BCS_USE_CACHE == 1 then
		if SPELL_CRIT and (GetTime() - GET_SPELL_CRIT_TIME) < 2 then
			return SPELL_CRIT
		else 
			SPELL_CRIT = BCS:GetLiveSpellCritChance()
			GET_SPELL_CRIT_TIME = GetTime()
			return SPELL_CRIT
		end
	else
		return BCS:GetLiveSpellCritChance()
	end
	
end

function BCS:GetLiveSpellCritChance()
	-- school crit: most likely never
	local Crit_Set_Bonus = {}
	local spellCrit = 0
	local _, intelect = UnitStat("player", 4)
	
	
	-- values from theorycraft / http://wow.allakhazam.com/forum.html?forum=21&mid=1157230638252681707
	if class == "MAGE" then
		spellCrit = 0.2 + (intelect / 59.5)
	elseif class == "WARLOCK" then
		spellCrit = 1.7 + (intelect / 60.6)
	elseif class == "PRIEST" then
		spellCrit = 0.8 + (intelect / 59.56)
	elseif class == "DRUID" then
		spellCrit = 1.8 + (intelect / 60)
	elseif class == "SHAMAN" then
		spellCrit = 1.8 + (intelect / 59.2)
	elseif class == "PALADIN" then
		spellCrit = intelect / 29.5
	end
	
	local MAX_INVENTORY_SLOTS = 19
	
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		
		if hasItem then
			local SET_NAME = nil
			
			for line=1, BCS_Tooltip:NumLines() do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)

				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L_SPELLCRIT["Equip: Improves your chance to get a critical strike with spells by (%d)%%."])
					if value then
						spellCrit = spellCrit + tonumber(value)
					end

					_,_, value = strfind(left:GetText(), L_SPELLCRIT["Eye of Diminution"])
					if value then
						spellCrit = spellCrit + tonumber(value)
					end

					_,_,_, value = strfind(left:GetText(), L_SPELLCRIT["Power of the Scourge"])
					if value then
						spellCrit = spellCrit + tonumber(value)
					end

					_,_,_, value = strfind(left:GetText(), L_SPELLCRIT["Scythe_of_Elune"])
					if value then
						spellCrit = spellCrit + tonumber(value)
					end

					_,_, value = strfind(left:GetText(), "(.+)（%d/%d）")
					if value then
						SET_NAME = value
					end

					_, _, value = strfind(left:GetText(), L_SPELLCRIT["^Set: Improves your chance to get a critical strike with spells by (%d)%%."])
					if value and SET_NAME and not tContains(Crit_Set_Bonus, SET_NAME) then
						tinsert(Crit_Set_Bonus, SET_NAME)
						spellCrit = spellCrit + tonumber(value)
					end

				end
			end
		end
		
	end
	
	-- buffs
	local _, _, critFromAura = BCS:GetPlayerAura(L_SPELLCRIT["Chance for a critical hit with a spell increased by (%d+)%%."])
	if critFromAura then
		spellCrit = spellCrit + tonumber(critFromAura)
	end
	_, _, critFromAura = BCS:GetPlayerAura(L_SPELLCRIT["While active, target's critical hit chance with spells and attacks increases by 10%%."])
	if critFromAura then
		spellCrit = spellCrit + 10
	end
	_, _, critFromAura = BCS:GetPlayerAura(L_SPELLCRIT["Increases chance for a melee, ranged, or spell critical by (%d+)%% and all attributes by %d+."])
	if critFromAura then
		spellCrit = spellCrit + tonumber(critFromAura)
	end
	critFromAura = BCS:GetPlayerAura(L_SPELLCRIT["Increases critical chance of spells by 10%%, melee and ranged by 5%% and grants 140 attack power. 120 minute duration."])
	if critFromAura then
		spellCrit = spellCrit + 10
	end
	_, _, critFromAura = BCS:GetPlayerAura(L_SPELLCRIT["Critical strike chance with spells and melee attacks increased by (%d+)%%."])
	if critFromAura then
		spellCrit = spellCrit + tonumber(critFromAura)
	end
	
	_, _, critFromAura = BCS:GetPlayerAura(L_SPELLCRIT["mushroom_flower"], 'HARMFUL')
	if critFromAura then
		spellCrit = spellCrit + tonumber(critFromAura)
	end

	_, _, _, _, critFromAura = BCS:GetPlayerAura(L_SPELLCRIT["Dreamshard Elixir"])
	if critFromAura then
		spellCrit = spellCrit + tonumber(critFromAura)
	end

	_, _, critFromAura = BCS:GetPlayerAura(L_SPELLCRIT["Moonkin Aura"])
	if critFromAura then
		spellCrit = spellCrit + tonumber(critFromAura)
	end

	_, _, critFromAura = BCS:GetPlayerAura(L_SPELLCRIT["Atiesh, Greatstaff of the Guardian_Mage_aura"])
	if critFromAura then
		spellCrit = spellCrit + tonumber(critFromAura)
	end
	
	_, _, critFromAura = BCS:GetPlayerAura(L_SPELLCRIT["Dream_Mongoose"])
	if critFromAura then
		spellCrit = spellCrit + tonumber(critFromAura)
	end
	

	-- debuffs
	_, _, _, critFromAura = BCS:GetPlayerAura(L_SPELLCRIT["Melee critical-hit chance reduced by (%d+)%%.\r\nSpell critical-hit chance reduced by (%d+)%%."], 'HARMFUL')
	if critFromAura then
		spellCrit = spellCrit - tonumber(critFromAura)
	end
	
	--talent
	if class == "PRIEST" then
		local talentname, _, _, _, crank, _ = GetTalentInfo(1, 17)
		if talentname == L_TALENT.PRIEST_FORCE_OF_WILL then
			if crank ~= 0 then
				spellCrit = spellCrit + crank
			end
		end
		
		talentname, _, _, _, crank, _ = GetTalentInfo(2, 3)
		if talentname == L_TALENT.PRIEST_DIVINITY then
			if crank ~= 0 then
				spellCrit = spellCrit + crank
			end
		end
	end
	
	return spellCrit
end

function BCS:GetSpellPower(school)
	if BCS_GET_ON_DEMAND then 
		local on_show = 0
		local allow_options= {"PLAYERSTAT_SPELL_COMBAT","PLAYERSTAT_SPELL_SCHOOLS",} 
		for _,v in ipairs(allow_options) do
			if (BCSConfig["DropdownLeft"] == v) or (BCSConfig["DropdownRight"] == v) then
				on_show = 1
				break
			end
		end
		if on_show == 0 then 
			return 0
		end
	end
	
	if BCS_USE_CACHE == 1 then
		if  (GetTime() - GET_SPELL_POWER_TIME) < 1 then
			return SPELL_POWER_IN_GETSPELLPOWER, SECOND_SPELL_POWER, SECOND_SPELL_POWER_NAME, DAMAGE_POWER, SPELL_POWER_BY_SCHOOL.ARCANE, SPELL_POWER_BY_SCHOOL.FIRE,  SPELL_POWER_BY_SCHOOL.FROST, SPELL_POWER_BY_SCHOOL.HOLY, SPELL_POWER_BY_SCHOOL.NATURE, SPELL_POWER_BY_SCHOOL.SHADOW
			
		else 
			SPELL_POWER_IN_GETSPELLPOWER, SECOND_SPELL_POWER, SECOND_SPELL_POWER_NAME, DAMAGE_POWER, SPELL_POWER_BY_SCHOOL.ARCANE, SPELL_POWER_BY_SCHOOL.FIRE,  SPELL_POWER_BY_SCHOOL.FROST, SPELL_POWER_BY_SCHOOL.HOLY, SPELL_POWER_BY_SCHOOL.NATURE, SPELL_POWER_BY_SCHOOL.SHADOW = BCS:GetLiveSpellPower(school)
			GET_SPELL_POWER_TIME = GetTime()
			return SPELL_POWER_IN_GETSPELLPOWER, SECOND_SPELL_POWER, SECOND_SPELL_POWER_NAME, DAMAGE_POWER, SPELL_POWER_BY_SCHOOL.ARCANE, SPELL_POWER_BY_SCHOOL.FIRE,  SPELL_POWER_BY_SCHOOL.FROST, SPELL_POWER_BY_SCHOOL.HOLY, SPELL_POWER_BY_SCHOOL.NATURE, SPELL_POWER_BY_SCHOOL.SHADOW
		end
	else
		return BCS:GetLiveSpellPower(school)
	end
	return BCS:GetLiveSpellPower(school)
end

function BCS:GetLiveSpellPower(school)
	local spellPower = 0
	local arcanePower = 0
	local firePower = 0
	local frostPower = 0
	local holyPower = 0
	local naturePower = 0
	local shadowPower = 0
	local damagePower = 0
	local MAX_INVENTORY_SLOTS = 19
	local SpellPower_Set_Bonus = {}
		
	-- scan gear
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		if hasItem then
			local SET_NAME
			for line=1, BCS_Tooltip:NumLines() do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L_SPELLPOWER["Equip: Increases damage and healing done by magical spells and effects by up to (%d+)."])
					if value then
						spellPower = spellPower + tonumber(value)
					end

					_,_, value = strfind(left:GetText(), L_SPELLPOWER["jewel_5_spell_power"])
					if value then
						spellPower = spellPower + tonumber(value)
					end

					_,_, value = strfind(left:GetText(), L_SPELLPOWER["Desecration"])
					if value then
						spellPower = spellPower + tonumber(value)
					end
														
					_,_, value,_ = strfind(left:GetText(), L_SPELLPOWER["Atiesh, Greatstaff of the Guardian_Druid"])
					if value then
						spellPower = spellPower + tonumber(value)
						damagePower = damagePower + tonumber(value)
					end

					_,_, value,_ = strfind(left:GetText(), L_SPELLPOWER["Atiesh, Greatstaff of the Guardian_Priest"])
					if value then
						spellPower = spellPower + tonumber(value)
						damagePower = damagePower + tonumber(value)
					end

					_,_,_,_, value = strfind(left:GetText(), L_SPELLPOWER["Scythe_of_Elune"])
					if value then
						spellPower = spellPower + tonumber(value)
						damagePower = damagePower + tonumber(value)
					end

					_,_, value,_ = strfind(left:GetText(), L_SPELLPOWER["Power of the Scourge"])
					if value then
						spellPower = spellPower + tonumber(value)
					end
						
					_,_, value = strfind(left:GetText(), L_SPELLPOWER["Spell Damage %+(%d+)"])
					if value then
						spellPower = spellPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELLPOWER["^%+(%d+) Spell Damage and Healing"])
					if value then
						spellPower = spellPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELLPOWER["^%+(%d+) Damage and Healing Spells"])
					if value then
						spellPower = spellPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELLPOWER["Healing Spells and Damage %+(%d+)"])
					if value then
						spellPower = spellPower + tonumber(value)
					end
						
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["Equip: Increases damage done by Arcane spells and effects by up to (%d+)."])
					if value then
						arcanePower = arcanePower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["^%+(%d+) Arcane Spell Damage"])
					if value then
						arcanePower = arcanePower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["Netherwind Epaulets"])
					if value then
						arcanePower = arcanePower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["glove_20_arcane_power"])
					if value then
						arcanePower = arcanePower + tonumber(value)
					end
						
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["Equip: Increases damage done by Fire spells and effects by up to (%d+)."])
					if value then
						firePower = firePower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["Fire Damage %+(%d+)"])
					if value then
						firePower = firePower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["^%+(%d+) Fire Spell Damage"])
					if value then
						firePower = firePower + tonumber(value)
					end
						
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["Equip: Increases damage done by Frost spells and effects by up to (%d+)."])
					if value then
						frostPower = frostPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["Frost Damage %+(%d+)"])
					if value then
						frostPower = frostPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["^%+(%d+) Frost Spell Damage"])
					if value then
						frostPower = frostPower + tonumber(value)
					end
					
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["Equip: Increases damage done by Holy spells and effects by up to (%d+)."])
					if value then
						holyPower = holyPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["^%+(%d+) Holy Spell Damage"])
					if value then
						holyPower = holyPower + tonumber(value)
					end
						
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["Equip: Increases damage done by Nature spells and effects by up to (%d+)."])
					if value then
						naturePower = naturePower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["^%+(%d+) Nature Spell Damage"])
					if value then
						naturePower = naturePower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["jewel_9_nature_power"])
					if value then
						naturePower = naturePower + tonumber(value)
					end
					
						
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["Equip: Increases damage done by Shadow spells and effects by up to (%d+)."])
					if value then
						shadowPower = shadowPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["Equip: Increases damage done by Shadow spells and effects by up (%d+)."])
					if value then
						shadowPower = shadowPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["Shadow_effect_3"])
					if value then
						shadowPower = shadowPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["Shadow Damage %+(%d+)"])
					if value then
						shadowPower = shadowPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_SPELL_SCHOOL["^%+(%d+) Shadow Spell Damage"])
					if value then
						shadowPower = shadowPower + tonumber(value)
					end
						
					_,_, value = strfind(left:GetText(), "(.+)（%d/%d）")
					if value then
						SET_NAME = value
					end

					_, _, value = strfind(left:GetText(), L_SPELLPOWER["^Set: Increases damage and healing done by magical spells and effects by up to (%d+)%."])
					if value and SET_NAME and not tContains(SpellPower_Set_Bonus, SET_NAME) then
						tinsert(SpellPower_Set_Bonus, SET_NAME)
						spellPower = spellPower + tonumber(value)
					end
					
					_, _, value = strfind(left:GetText(), L_SPELL_SCHOOL["Set_Nature_damage"])
					if value and SET_NAME and not tContains(SpellPower_Set_Bonus, SET_NAME) then
						tinsert(SpellPower_Set_Bonus, SET_NAME)
						naturePower = naturePower + tonumber(value)
					end
					
				end
			end
		end
	end
		
		-- scan talents
	spellPower = spellPower + BCS:GetLiveSpellPower_FromTalent()
	
		
		-- buffs
	local _, _, spellPowerFromAura = BCS:GetPlayerAura(L_SPELLPOWER["Magical damage dealt is increased by up to (%d+)."])
	if spellPowerFromAura then
		spellPower = spellPower + tonumber(spellPowerFromAura)
		damagePower = damagePower + tonumber(spellPowerFromAura)
	end

	_, _, spellPowerFromAura = BCS:GetPlayerAura(L_SPELLPOWER["Atiesh, Greatstaff of the Guardian_Warlock_aura"])
	if spellPowerFromAura then
		spellPower = spellPower + tonumber(spellPowerFromAura)
	end
	
	_, _, spellPowerFromAura = BCS:GetPlayerAura(L_SPELLPOWER["Wrath_of_Cenarius"])
	if spellPowerFromAura then
		spellPower = spellPower + tonumber(spellPowerFromAura)
		damagePower = damagePower + tonumber(spellPowerFromAura)
	end
	
	_, _, spellPowerFromAura = BCS:GetPlayerAura(L_SPELLPOWER["Remains_of_Overwhelming_Power"])
	if spellPowerFromAura then
		spellPower = spellPower + tonumber(spellPowerFromAura)
	end
	
	_, _, spellPowerFromAura = BCS:GetPlayerAura(L_SPELLPOWER["The_Restrained_Essence_of_Sapphiron"])
	if spellPowerFromAura then
		spellPower = spellPower + tonumber(spellPowerFromAura)
	end
	
	_, _, spellPowerFromAura = BCS:GetPlayerAura(L_SPELLPOWER["Arcane_Giant"])
	if spellPowerFromAura then
		spellPower = spellPower + tonumber(spellPowerFromAura)
	end
	
	_, _, spellPowerFromAura = BCS:GetPlayerAura(L_SPELLPOWER["Dream_Firewater"])
	if spellPowerFromAura then
		spellPower = spellPower + tonumber(spellPowerFromAura)
	end
	
	_, _, spellPowerFromAura = BCS:GetPlayerAura(L_SPELLPOWER["Dream_Mongoose"])
	if spellPowerFromAura then
		spellPower = spellPower + tonumber(spellPowerFromAura)
	end
		
	_, _, spellPowerFromAura,_,_ = BCS:GetPlayerAura(L_SPELLPOWER["Dreamshard Elixir"])
	if spellPowerFromAura then
		spellPower = spellPower + tonumber(spellPowerFromAura)
		damagePower = damagePower + tonumber(spellPowerFromAura)
	end
	
	_, _, spellPowerFromAura,_,_ = BCS:GetPlayerAura(L_SPELLPOWER["Zandalarian_Hero_Charm_sp"])
	if spellPowerFromAura then
		spellPower = spellPower + tonumber(spellPowerFromAura)
		damagePower = damagePower + tonumber(spellPowerFromAura)
	end

	_, _, spellPowerFromAura,_,_ = BCS:GetPlayerAura(L_SPELLPOWER["Talisman of Ephemeral Power"])
	if spellPowerFromAura then
		spellPower = spellPower + tonumber(spellPowerFromAura)
	end

	if class == "PRIEST" then
		_, _, _, spellPowerFromAura = BCS:GetPlayerAura(L_SPELLPOWER["INNER_FIRE"])
		if spellPowerFromAura then
			local talentname, _, _, _, crank, _ = GetTalentInfo(1, 8)
			if talentname == L_TALENT.PRIEST_IMPROVED_INNER_FIRE then 
				spellPower = spellPower + tonumber(spellPowerFromAura) * ( 1 + 0.15 * crank )
				damagePower = damagePower + tonumber(spellPowerFromAura) * ( 1 + 0.15 * crank )
			else
				spellPower = spellPower + tonumber(spellPowerFromAura)
				damagePower = damagePower + tonumber(spellPowerFromAura)
			end
		end
	end
	
	_, _, spellPowerFromAura = BCS:GetPlayerAura(L_SPELLPOWER["Dreamtonic"])
	if spellPowerFromAura then
		spellPower = spellPower + tonumber(spellPowerFromAura)
		damagePower = damagePower + tonumber(spellPowerFromAura)
	end
	
	_, _, spellPowerFromAura = BCS:GetPlayerAura(L_SPELL_SCHOOL["Elixir_of_Greater_Nature_Power"])
	if spellPowerFromAura then
		naturePower = naturePower + tonumber(spellPowerFromAura)
	end
	
	_, _, spellPowerFromAura = BCS:GetPlayerAura(L_SPELL_SCHOOL["Elixir_of_Greater_Frost_Power"])
	if spellPowerFromAura then
		frostPower = frostPower + tonumber(spellPowerFromAura)
	end
	
	_, _, spellPowerFromAura = BCS:GetPlayerAura(L_SPELL_SCHOOL["Elixir_of_Greater_Arcane_Power"])
	if spellPowerFromAura then
		arcanePower = arcanePower + tonumber(spellPowerFromAura)
	end
		
	local secondaryPower = 0
	local secondaryPowerName = ""
		
	if arcanePower > secondaryPower then
		secondaryPower = arcanePower
		secondaryPowerName = L.SPELL_SCHOOL_ARCANE
	end
	if firePower > secondaryPower then
		secondaryPower = firePower
		secondaryPowerName = L.SPELL_SCHOOL_FIRE
	end
	if frostPower > secondaryPower then
		secondaryPower = frostPower
		secondaryPowerName = L.SPELL_SCHOOL_FROST
	end
	if holyPower > secondaryPower then
		secondaryPower = holyPower
		secondaryPowerName = L.SPELL_SCHOOL_HOLY
	end
	if naturePower > secondaryPower then
		secondaryPower = naturePower
		secondaryPowerName = L.SPELL_SCHOOL_NATURE
	end
	if shadowPower > secondaryPower then
		secondaryPower = shadowPower
		secondaryPowerName = L.SPELL_SCHOOL_SHADOW
	end

	if class == "PRIEST" then
		local talentname, _, _, _, crank, _ = GetTalentInfo(1, 17)
		if talentname == L_TALENT.PRIEST_FORCE_OF_WILL then
			if crank ~= 0 then
				spellPower = spellPower * ( 1 + crank * 0.01 )
				secondaryPower = secondaryPower * ( 1 + crank * 0.01 )
				damagePower = damagePower * ( 1 + crank * 0.01 )
				arcanePower = arcanePower * ( 1 + crank * 0.01 )
				firePower = firePower * ( 1 + crank * 0.01 )
				frostPower = frostPower * ( 1 + crank * 0.01 )
				holyPower = holyPower * ( 1 + crank * 0.01 )
				naturePower = naturePower * ( 1 + crank * 0.01 )
				shadowPower = shadowPower * ( 1 + crank * 0.01 )
			end
		end
	end

	return spellPower, secondaryPower, secondaryPowerName, damagePower, arcanePower, firePower, frostPower, holyPower, naturePower, shadowPower
end

function BCS:GetLiveSpellPower_FromTalent()
	local spellPower = 0
	if class == "PRIEST" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(2, 12)
		local _, Spirit, _, _ = UnitStat("player", 5)
		if talentname == L_TALENT.PRIEST_SPIRITUAL_GUIDANCE then 
			spellPower = spellPower + crank * 0.05 * Spirit
		end
	end
	return spellPower
end

function BCS:GetHealingPower()
	if BCS_GET_ON_DEMAND then 
		local on_show = 0
		local allow_options= {"PLAYERSTAT_SPELL_COMBAT",} 
		for _,v in ipairs(allow_options) do
			if (BCSConfig["DropdownLeft"] == v) or (BCSConfig["DropdownRight"] == v) then
				on_show = 1
				break
			end
		end
		if on_show == 0 then 
			return 0
		end
	end
	if BCS_USE_CACHE == 1 then
		if HEAL_POWER and (GetTime() - GET_HEAL_POWER_TIME) < 2 then
			return HEAL_POWER
		else 
			HEAL_POWER = BCS:GetLiveHealingPower()
			GET_HEAL_POWER_TIME = GetTime()
			return HEAL_POWER
		end
	else
		return BCS:GetLiveHealingPower()
	end
end

function BCS:GetLiveHealingPower()
	local healPower = 0
	local healPower_Set_Bonus = {}
	local MAX_INVENTORY_SLOTS = 19
	
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		
		if hasItem then
			local SET_NAME
			
			for line=1, BCS_Tooltip:NumLines() do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L_HEALPOWER["Equip: Increases healing done by spells and effects by up to (%d+)."])
					if value then
						healPower = healPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_HEALPOWER["Healing Spells %+(%d+)"])
					if value then
						healPower = healPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_HEALPOWER["Equip: Increases healing (%d+)."])
					if value then
						healPower = healPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_HEALPOWER["^%+(%d+) Healing Spells"])
					if value then
						healPower = healPower + tonumber(value)
					end

					_,_, value = strfind(left:GetText(), L_HEALPOWER["jewel_12_heal_power"])
					if value then
						healPower = healPower + tonumber(value)
					end

					_,_, value = strfind(left:GetText(), L_HEALPOWER["Hammer of the Twisting Nether"])
					if value then
						healPower = healPower + tonumber(value)
					end

					_,_, value = strfind(left:GetText(), L_HEALPOWER["Scepter of the False Prophet"])
					if value then
						healPower = healPower + tonumber(value)
					end

					_,_,_, value = strfind(left:GetText(), L_HEALPOWER["Atiesh, Greatstaff of the Guardian_Druid"])
					if value then
						healPower = healPower + tonumber(value)
					end

					_,_,_, value = strfind(left:GetText(), L_HEALPOWER["Atiesh, Greatstaff of the Guardian_Priest"])
					if value then
						healPower = healPower + tonumber(value)
					end

					_,_, value = strfind(left:GetText(), L_HEALPOWER["Resilience of the Scourge"])
					if value then
						healPower = healPower + tonumber(value)
					end
					
					_,_, value = strfind(left:GetText(), "(.+)（%d/%d）")
					if value then
						SET_NAME = value
					end
					_, _, value = strfind(left:GetText(), L_HEALPOWER["^Set: Increases healing done by spells and effects by up to (%d+)%."])
					if value and SET_NAME and not tContains(healPower_Set_Bonus, SET_NAME) then
						tinsert(healPower_Set_Bonus, SET_NAME)
						healPower = healPower + tonumber(value)
					end
				end
			end
		end
		
	end

	--from talent
	healPower = healPower + BCS:GetLiveHealPower_FromTalent()
	
	
	-- buffs
	local _, _, healPowerFromAura = BCS:GetPlayerAura(L_HEALPOWER["Healing done by magical spells is increased by up to (%d+)."])
	if healPowerFromAura then
		healPower = healPower + tonumber(healPowerFromAura)
	end

	_, _, _, healPowerFromAura, _ = BCS:GetPlayerAura(L_HEALPOWER["Dreamshard Elixir"])
	if healPowerFromAura then
		healPower = healPower + tonumber(healPowerFromAura)
	end

	_, _, healPowerFromAura = BCS:GetPlayerAura(L_HEALPOWER["Atiesh, Greatstaff of the Guardian_Priest_aura"])
	if healPowerFromAura then
		healPower = healPower + tonumber(healPowerFromAura)
	end
	
	_, _, healPowerFromAura = BCS:GetPlayerAura(L_HEALPOWER["Zandalarian_Hero_Charm_hp"])
	if healPowerFromAura then
		healPower = healPower + tonumber(healPowerFromAura)
	end
	
	_, _, healPowerFromAura = BCS:GetPlayerAura(L_HEALPOWER["Spirit_of_Arathor"])
	if healPowerFromAura then
		healPower = healPower + tonumber(healPowerFromAura)
	end

	return healPower
end

function BCS:GetLiveHealPower_FromTalent()
	local healPower = 0
	--[[
	if class == "PRIEST" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(2, 12)
		local _, Spirit, _, _ = UnitStat("player", 5)
		if talentname == L_TALENT.PRIEST_SPIRITUAL_GUIDANCE then 
			healPower = healPower + crank * 0.05 * Spirit
		end
	end
	]]
	if class == "PALADIN" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(1, 12)
		if talentname == L_TALENT.PALADIN_IRONCLAD then 
			healPower = healPower + crank * 0.01 * BCS:GetOnlyGearArmor()
		end
	end
	return healPower
end

--[[
-- server\src\game\Object\Player.cpp
float Player::OCTRegenMPPerSpirit()
{
    float addvalue = 0.0

    float Spirit = GetStat(STAT_SPIRIT)
    uint8 Class = getClass()

    switch (Class)
    {
        case CLASS_DRUID:   addvalue = (Spirit / 5 + 15)   break
        case CLASS_HUNTER:  addvalue = (Spirit / 5 + 15)   break
        case CLASS_MAGE:    addvalue = (Spirit / 4 + 12.5) break
        case CLASS_PALADIN: addvalue = (Spirit / 5 + 15)   break
        case CLASS_PRIEST:  addvalue = (Spirit / 4 + 12.5) break
        case CLASS_SHAMAN:  addvalue = (Spirit / 5 + 17)   break
        case CLASS_WARLOCK: addvalue = (Spirit / 5 + 15)   break
    }

    addvalue /= 2.0f   // the above addvalue are given per tick which occurs every 2 seconds, hence this divide by 2

    return addvalue
}

void Player::UpdateManaRegen()
{
    // Mana regen from spirit
    float power_regen = OCTRegenMPPerSpirit()
    // Apply PCT bonus from SPELL_AURA_MOD_POWER_REGEN_PERCENT aura on spirit base regen
    power_regen *= GetTotalAuraMultiplierByMiscValue(SPELL_AURA_MOD_POWER_REGEN_PERCENT, POWER_MANA)

    // Mana regen from SPELL_AURA_MOD_POWER_REGEN aura
    float power_regen_mp5 = GetTotalAuraModifierByMiscValue(SPELL_AURA_MOD_POWER_REGEN, POWER_MANA) / 5.0f

    // Set regen rate in cast state apply only on spirit based regen
    int32 modManaRegenInterrupt = GetTotalAuraModifier(SPELL_AURA_MOD_MANA_REGEN_INTERRUPT)
    if (modManaRegenInterrupt > 100)
        { modManaRegenInterrupt = 100 }

    m_modManaRegenInterrupt = power_regen_mp5 + power_regen * modManaRegenInterrupt / 100.0f

    m_modManaRegen = power_regen_mp5 + power_regen
}
]]

local function GetRegenMPPerSpirit()
	local addvalue = 0
	
	local stat, Spirit, posBuff, negBuff = UnitStat("player", 5)
		
	if class == "DRUID" then
		addvalue = (Spirit / 5 + 15)
	elseif class == "HUNTER" then
		addvalue = (Spirit / 5 + 15)
	elseif class == "MAGE" then
		addvalue = (Spirit / 4 + 12.5)
	elseif class == "PALADIN" then
		addvalue = (Spirit / 5 + 15)
	elseif class == "PRIEST" then
		addvalue = (Spirit / 4 + 12.5)
	elseif class == "SHAMAN" then
		addvalue = (Spirit / 5 + 17)
	elseif class == "WARLOCK" then
		addvalue = (Spirit / 5 + 15)
	else
		return addvalue
	end
		
	return addvalue
end

function BCS:GetManaRegen()
	if BCS_GET_ON_DEMAND then 
		local on_show = 0
		local allow_options= {"PLAYERSTAT_SPELL_COMBAT",} 
		for _,v in ipairs(allow_options) do
			if (BCSConfig["DropdownLeft"] == v) or (BCSConfig["DropdownRight"] == v) then
				on_show = 1
				break
			end
		end
		if on_show == 0 then 
			return 0
		end
	end
	if BCS_USE_CACHE == 1 then
		if  (GetTime() - GET_MANA_REGEN_TIME) < 2 then
			return MANA_REGEN_BASE, MANA_REGEN_CAST, MANA_REGEN_MP5, MANA_REGEN_CAST_PERCENT
		else 
			MANA_REGEN_BASE, MANA_REGEN_CAST, MANA_REGEN_MP5, MANA_REGEN_CAST_PERCENT = BCS:GetLiveManaRegen()
			GET_MANA_REGEN_TIME = GetTime()
			return MANA_REGEN_BASE, MANA_REGEN_CAST, MANA_REGEN_MP5, MANA_REGEN_CAST_PERCENT
		end
	else
		return BCS:GetLiveManaRegen()
	end
end 

function BCS:GetLiveManaRegen()
	-- to-maybe-do: apply buffs/talents

	if class == "WARRIOR" or class == "ROGUE" then 
		return 0,0,0,0
	end

	local base, casting,casting_percent
	local power_regen = GetRegenMPPerSpirit()
	local ManaRegenCastPercent_Set_bonus = {}
	
	casting = 0
	casting_percent = 0
	base = power_regen
	
	local mp5 = 0
	local MAX_INVENTORY_SLOTS = 19
	
	local arcane_mage_3T2 = 0
	
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		 
		
		
		if hasItem then
			local SET_NAME
			for line=1, BCS_Tooltip:NumLines() do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L_MANAREGEN["^Mana Regen %+(%d+)"])
					if value then
						mp5 = mp5 + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_MANAREGEN["Equip: Restores (%d+) mana per 5 sec."])
					if value then
						mp5 = mp5 + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_MANAREGEN["^%+(%d+) mana every 5 sec."])
					if value then
						mp5 = mp5 + tonumber(value)
					end
					_,_,_, value = strfind(left:GetText(), L_MANAREGEN["Resilience of the Scourge"])
					if value then
						mp5 = mp5 + tonumber(value)
					end
		
					
					_,_, value = strfind(left:GetText(), L_MANAREGEN["cast_mana_percent_regen_1"])
					if value then
						casting_percent = casting_percent + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_MANAREGEN["cast_mana_percent_regen_2"])
					if value then
						casting_percent = casting_percent + tonumber(value)
					end
					
					--from set
					_,_, value = strfind(left:GetText(), "(.+)（%d/%d）")
					if value then
						SET_NAME = value
					end
					_, _, value = strfind(left:GetText(), L_MANAREGEN["cast_mana_percent_regen_set"])
					if value and SET_NAME and not tContains(ManaRegenCastPercent_Set_bonus, SET_NAME) then
						tinsert(ManaRegenCastPercent_Set_bonus, SET_NAME)
						casting_percent = casting_percent + tonumber(value)
					end
					
					_, _, value = strfind(left:GetText(), L_MANAREGEN["arcane_mage_3T2"])
					if value then
						arcane_mage_3T2 = 1
					end
					
				end
			end
		end
		
	end
	
	
	if UnitRace("player") == L_RACE.HUMAN then
		casting_percent = casting_percent + 5
	end

	--from talent
	if class == "PRIEST" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(1, 11)
		if talentname == L_TALENT.PRIEST_MEDITATION then 
			casting_percent = casting_percent + crank * 5
		end
	end
	
	if class == "DRUID" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(3, 8)
		if talentname == L_TALENT.DRUID_REFLECTION then 
			casting_percent = casting_percent + crank * 5
		end
	end
	
	if class == "MAGE" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(1, 13)
		if talentname == L_TALENT.MAGE_ARCANE_MEDITATION then 
			if crank > 0 then
				local casting_percent_add = 0
				if crank == 1 then
					casting_percent_add = 7
				elseif crank ==2 then
					casting_percent_add = 14
				elseif crank ==3 then
					casting_percent_add = 20
				end
				if UnitMana("player",0) / UnitManaMax("player",0) < 0.35 then
					casting_percent_add = casting_percent_add * 3
				end
				casting_percent = casting_percent + casting_percent_add
				
			end
		end
	end
	
	
	
	-- buffs
	local _, _, mp5FromAura = BCS:GetPlayerAura(L["Increases hitpoints by 300. 15%% haste to melee attacks. 10 mana regen every 5 seconds."])
	if mp5FromAura then
		mp5 = mp5 + 10
	end
	
	_, _, mp5FromAura = BCS:GetPlayerAura(L_MANAREGEN["Blessing_of_Wisdom"])
	if mp5FromAura then
		mp5 = mp5 + tonumber(mp5FromAura)
	end
	
	_, _, mp5FromAura = BCS:GetPlayerAura(L_MANAREGEN["Mageblood_Potion"])
	if mp5FromAura then
		mp5 = mp5 + tonumber(mp5FromAura)
	end
	
	_, _, value = BCS:GetPlayerAura(L_MANAREGEN["Fizzy_Energy_Drink"])
	if value then
		mp5 = mp5 + tonumber(value)
	end
	
	if class == "SHAMAN" then
		local _, _, watershiled = BCS:GetPlayerAura(L_MANAREGEN["Water_Shiled"])
		if watershiled then
			local talentname, _, _, _, crank, _ = GetTalentInfo(3, 11)
			if talentname == L_TALENT.SHAMAN_IMPROVED_WATER_SHILED then 
				mp5 = mp5 + crank * 3
			end
		end
	end
		
	_, _, _, value = BCS:GetPlayerAura(L_MANAREGEN["Emerald_Essence"])
	if value then
		casting_percent = casting_percent + tonumber(value)
	end
	
	_, _, value = BCS:GetPlayerAura(L_MANAREGEN["Sylvan_Blessing"])
	if value then
		casting_percent = casting_percent + tonumber(value)
	end
	
	_, _, value = BCS:GetPlayerAura(L_MANAREGEN["Aspect_of_Strider"])
	if value then
		casting_percent = casting_percent + tonumber(value)
	end
	
	_, _, mp5FromAura = BCS:GetPlayerAura(L_MANAREGEN["Mana_Spring_totem"])
	if mp5FromAura then
		mp5 = mp5 + tonumber(mp5FromAura) * 2.5
	end
	
	
	if class == "MAGE" then
		local _, _, casting_percentFromAura = BCS:GetPlayerAura(L_MANAREGEN["magic_armor"])
		if casting_percentFromAura then
			casting_percent = casting_percent + tonumber(casting_percentFromAura)
			if arcane_mage_3T2 == 1 then 
				casting_percent = casting_percent + 15
			end
		end
		_, _, value = BCS:GetPlayerAura(L_MANAREGEN["Evocation"])
		if value then
			base = base * (1 + tonumber(value) / 100 )
		end
	end
	
	if class == "PRIEST" then
		 _, _,  value = BCS:GetPlayerAura(L_MANAREGEN["Shadowform"])
		if value then
			if UnitLevel("player") == 60 then
				casting_percent = casting_percent + 15
			end
		end
	end
	
	
	casting = base * casting_percent / 100

	return base, casting, mp5, casting_percent
end

function BCS:GetHaste()

	if BCS_GET_ON_DEMAND then 
		local on_show = 0
		local allow_options= {"PLAYERSTAT_SPELL_COMBAT",} 
		for _,v in ipairs(allow_options) do
			if (BCSConfig["DropdownLeft"] == v) or (BCSConfig["DropdownRight"] == v)then
				on_show = 1
				break
			end
		end
		if on_show == 0 then 
			return 0
		end
	end
	 
	if BCS_USE_CACHE == 1 then 
		if  GET_HASTE_CACHE_TIME and (GetTime()-GET_HASTE_CACHE_TIME <2 ) then
			return HASTE_CACHE
		else 
			HASTE_CACHE = BCS:GetLiveHaste()
			GET_HASTE_CACHE_TIME = GetTime()
			return HASTE_CACHE
		end
	else
		return BCS:GetLiveHaste()
	end

end

function BCS:GetLiveHaste()
	local haste = 1.0000
	local haste_Set_bonus = {}
	local MAX_INVENTORY_SLOTS = 19
	--from gear
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		if hasItem then
			local SET_NAME = nil
			for line=1, BCS_Tooltip:NumLines() do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
				if left:GetText() then

					local _,_, value = strfind(left:GetText(), L_HASTE["HASTE_improve_equip_1"])
					if value then
						haste = haste * (1+tonumber(value)/100)
					end

					local _,_, value = strfind(left:GetText(), L_HASTE["HASTE_improve_equip_2"])
					if value then
						haste = haste * (1+tonumber(value)/100)
					end

					local _,_, value = strfind(left:GetText(), L_HASTE["HASTE_improve_enchant"])
					if value then
						haste = haste * (1+tonumber(value)/100)
					end

					local _,_, value = strfind(left:GetText(), L_HASTE["Libram of Rapidity"])
					if value then
						haste = haste * (1+tonumber(value)/100)
					end
					
					--from set
					_,_, value = strfind(left:GetText(), "(.+)（%d/%d）")
					if value then
						SET_NAME = value
					end

					_, _, value = strfind(left:GetText(), L_HASTE["HASTE_improve_set"])
					if value and SET_NAME and not tContains(haste_Set_bonus, SET_NAME) then
						tinsert(haste_Set_bonus, SET_NAME)
						haste = haste * (1+tonumber(value)/100)
					end

				end
			end
		end
		
	end
	
	--from buff
	local _, _, hasteFromAura = BCS:GetPlayerAura(L_HASTE["HASTE_BUFF_1"])
	if hasteFromAura then
		haste = haste * (1+tonumber(hasteFromAura)/100)
	end
	_, _, hasteFromAura = BCS:GetPlayerAura(L_HASTE["HASTE_BUFF_2"])
	if hasteFromAura then
		haste = haste * (1+tonumber(hasteFromAura)/100)
	end
	_, _, hasteFromAura = BCS:GetPlayerAura(L_HASTE["HASTE_BUFF_3"])
	if hasteFromAura then
		haste = haste * (1+tonumber(hasteFromAura)/100)
	end
	
	--from debuff
	_, _, hasteFromAura = BCS:GetPlayerAura(L_HASTE["Contagion_of_Rot"],'HARMFUL')
	if hasteFromAura then
		haste = haste * (1-tonumber(hasteFromAura)/100)
	end
	
	
	local _, _, hasteFromAura = BCS:GetPlayerAura(L_HASTE["HASTE_PALADIN_ZEAL"])
	if hasteFromAura then
		haste = haste * (1+tonumber(hasteFromAura)/100)
	end
	

	if class == "MAGE" then
		local _, _, hasteFromAura = BCS:GetPlayerAura(L_HASTE["ARCANE_POWER"])
		if hasteFromAura then
			haste = haste * (1+tonumber(hasteFromAura)/100)
		end
	end

	local _, _, hasteFromAura = BCS:GetPlayerAura(L_HASTE["Atiesh, Greatstaff of the Guardian_Druid_aura"])
	if hasteFromAura then
		haste = haste * (1+tonumber(hasteFromAura)/100)
	end

	if class == "WARLOCK" then
		local _, _, hasteFromAura,_ = BCS:GetPlayerAura(L_HASTE["HASTE_WARLOCK_Master_Demonologist"])
		if hasteFromAura then
			haste = haste * (1+tonumber(hasteFromAura)/100)
		end
	end

	--from race 
	if UnitRace("player") == L_RACE.NIGHT_ELF then
		haste = haste * 1.01
	end

	--from talent
	if class == "PRIEST" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(1, 14)
		if talentname == L_TALENT.PRIEST_MENTAL_STRENGTH then 
			haste = haste * (1+crank/100)
		end
	end
	return (haste-1)*100
end

function BCS:GetOriWeaponSpeed(slotID)
	if slotID ~= 16 and  slotID ~= 18 then 
		return nil
	end 
	local weaponSpeed = 0
	local hasItem = BCS_Tooltip:SetInventoryItem("player", slotID)
	if hasItem then
		for line=1, BCS_Tooltip:NumLines() do
			local right = getglobal(BCS_Prefix .. "TextRight" .. line)
			if right:GetText() then
				local _, _, v1, v2 = strfind(right:GetText(), L["weaponSpeed"])
				if v1 then
					weaponSpeed = v2/100+v1
					break
				end
			end
		end
	else 
		if slotID == 16 then 
			weaponSpeed = 2
		end
		if slotID == 18 then 
			weaponSpeed = 0
		end
	end
	return weaponSpeed
end

function BCS:GetOnlyGearArmor()
	if BCS_GET_ON_DEMAND then 
		local on_show = 0
		local allow_options= {"PLAYERSTAT_SPELL_COMBAT",} 
		for _,v in ipairs(allow_options) do
			if (BCSConfig["DropdownLeft"] == v) or (BCSConfig["DropdownRight"] == v)then
				on_show = 1
				break
			end
		end
		if on_show == 0 then 
			return 0
		end
	end
	 
	if BCS_USE_CACHE == 1 then 
		if  GET_GEAR_ARMOR_TIME and (GetTime() - GET_GEAR_ARMOR_TIME <2 ) then
			return GEAR_ARMOR
		else 
			GEAR_ARMOR = BCS:GetLiveOnlyGearArmor()
			GET_GEAR_ARMOR_TIME = GetTime()
			return GEAR_ARMOR
		end
	else
		return BCS:GetLiveOnlyGearArmor()
	end

	return BCS:GetLiveOnlyGearArmor()
end

function BCS:GetLiveOnlyGearArmor()
	local armor = 0
	local Set_bonus = {}
	for slot=0, 19 do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		if hasItem then
			local SET_NAME = nil
			for line=1, BCS_Tooltip:NumLines() do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L_ARMOR["gainarmor"])
					if value then
						armor = armor + tonumber(value)
					end
					--from set
					_,_, value = strfind(left:GetText(), "(.+)（%d/%d）")
					if value then
						SET_NAME = value
					end
					_, _, value = strfind(left:GetText(), L_ARMOR["gainarmor_set"])
					if value and SET_NAME and not tContains(Set_bonus, SET_NAME) then
						tinsert(Set_bonus, SET_NAME)
						armor = armor + tonumber(value)
					end

				end
			end
		end
	end
	return armor
end

function BCS:Version()
	return VERSION
end

function BCS:GetBlockValue()
	if BCS_GET_ON_DEMAND then 
		local on_show = 0
		local allow_options= {"PLAYERSTAT_DEFENSES",} 
		for _,v in ipairs(allow_options) do
			if (BCSConfig["DropdownLeft"] == v) or (BCSConfig["DropdownRight"] == v)then
				on_show = 1
				break
			end
		end
		if on_show == 0 then 
			return 0
		end
	end
	if BCS_USE_CACHE == 1 then 
		if  GET_BLOCK_VALUE_TIME and (GetTime() - GET_BLOCK_VALUE_TIME < 2 ) then
			return BLOCK_VALUE
		else 
			BLOCK_VALUE = BCS:GetLiveBlockValue()
			GET_BLOCK_VALUE_TIME = GetTime()
			return BLOCK_VALUE
		end
	else
		return BCS:GetLiveBlockValue()
	end
	return BCS:GetLiveBlockValue()
end

function BCS:GetLiveBlockValue()
	local blockvalue = 0
	local hasShield = false
	
	if class ~= "WARRIOR" and  class ~= "PALADIN" and class ~="SHAMAN" then 
		return 0
	end

	local offhandLink = GetInventoryItemLink("player", 17)
	if offhandLink then
		local _, _, itemID = string.find(offhandLink, "item:(%d+):%d+:%d+:%d+")
		local n = tonumber(itemID)
		local itemName, _, itemRarity, _, itemEquipType, _, _, itemInvType = GetItemInfo(n)	
		if itemInvType == "INVTYPE_SHIELD" then hasShield = true end
	else
		return 0
	end
	
	if not hasShield then return 0 end
	
	--from_strength
	blockvalue = blockvalue + UnitStat("player", 1) / 20
	
	--from equip
	local Set_bonus = {}
	for slot=0, 19 do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		if hasItem then
			local SET_NAME = nil
			for line=1, BCS_Tooltip:NumLines() do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L_BLOCKVALUE["BLOCKVALUE_1"])
					if value then
						blockvalue = blockvalue + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_BLOCKVALUE["BLOCKVALUE_2"])
					if value then
						blockvalue = blockvalue + tonumber(value)
					end
					
					--from set
					_,_, value = strfind(left:GetText(), "(.+)（%d/%d）")
					if value then
						SET_NAME = value
					end
					_, _, value = strfind(left:GetText(), L_BLOCKVALUE["BLOCKVALUE_SET_1"])
					if value and SET_NAME and not tContains(Set_bonus, SET_NAME) then
						tinsert(Set_bonus, SET_NAME)
						blockvalue = blockvalue + tonumber(value)
					end
					_, _, value = strfind(left:GetText(), L_BLOCKVALUE["BLOCKVALUE_SET_2"])
					if value and SET_NAME and not tContains(Set_bonus, SET_NAME) then
						tinsert(Set_bonus, SET_NAME)
						blockvalue = blockvalue + tonumber(value)
					end

				end
			end
		end
	end
	
	--from_talent
	if class == "WARRIOR" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(3, 5)
		if talentname == L_TALENT.WARRIOR_TOUGHNESS then 
			blockvalue = blockvalue * ( 1 + crank * 0.03)
		end
	end
	
	if class == "PALADIN" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(2, 8)
		if talentname == L_TALENT.PALADIN_SHIELD_SPECIALIZATION then 
			blockvalue = blockvalue * ( 1 + crank * 0.1)
		end
	end
	
	if class == "SHAMAN" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(2, 2)
		if talentname == L_TALENT.SHAMAN_SHIELD_SPECIALIZATION then 
			blockvalue = blockvalue * ( 1 + crank * 0.06)
		end
	end
	
	--from_buff
	_, _, blockFromAura = BCS:GetPlayerAura(L_BLOCKVALUE["pala_8t2"])
	if blockFromAura then
		blockvalue = blockvalue + tonumber(blockFromAura)
	end
	
	if class == "SHAMAN" then
		_, _, blockFromAura = BCS:GetPlayerAura(L_BLOCKVALUE["Stoneskin_totem"])
		if blockFromAura then
			local talentname, _, _, _, crank, _ = GetTalentInfo(2, 12)
			if talentname == L_TALENT.SHAMAN_ENHANCING_TOTEMS then
				blockvalue = blockvalue * ( 1 + crank * 0.15)
			end
		end
	end
	
	if class == "PALADIN" then
		_, _, blockFromAura = BCS:GetPlayerAura(L_HASTE["HASTE_PALADIN_ZEAL"])
		if blockFromAura then
			local talentname, _, _, _, crank, _ = GetTalentInfo(2, 15)
			if talentname == L_TALENT.PALADIN_RIGHTEOUS_STRIKES then
				blockvalue = blockvalue * ( 1 + crank * 0.02 * blockFromAura / 3)
			end
		end
	end
	
	return blockvalue
end

function BCS:GetArmorPenetrationValue()

	if BCS_USE_CACHE == 1 then 
		if  GET_ARMORPENETRATION_VALUE_TIME and (GetTime() - GET_ARMORPENETRATION_VALUE_TIME < 2 ) then
			return ARMORPENETRATION_VALUE
		else 
			ARMORPENETRATION_VALUE = BCS:GetLiveArmorPenetrationValue()
			GET_ARMORPENETRATION_VALUE_TIME = GetTime()
			return ARMORPENETRATION_VALUE
		end
	else
		return BCS:GetLiveArmorPenetrationValue()
	end
	return BCS:GetLiveArmorPenetrationValue()
end

function BCS:GetLiveArmorPenetrationValue()
	local armorPenetrationvalue = 0
	local playerlevel=UnitLevel("player")
	
	if class == "MAGE" or class == "WARLOCK" or class == "PRIEST" then 
		return 0
	end

	--from equip
	local Set_bonus = {}
	for slot=0, 19 do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		if hasItem then
			local SET_NAME = nil
			for line=1, BCS_Tooltip:NumLines() do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L_ARMORPENETRATION["ARMORPENETRATION_1"])
					if value then
						armorPenetrationvalue = armorPenetrationvalue + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L_ARMORPENETRATION["ARMORPENETRATION_2"])
					if value then
						armorPenetrationvalue = armorPenetrationvalue + tonumber(value)
					end
					
					_,_, value = strfind(left:GetText(), L_ARMORPENETRATION["ARMORPENETRATION_3"])
					if value then
						armorPenetrationvalue = armorPenetrationvalue + tonumber(value)
					end
					
					--[[
					--from set
					_,_, value = strfind(left:GetText(), "(.+)（%d/%d）")
					if value then
						SET_NAME = value
					end
					_, _, value = strfind(left:GetText(), L_BLOCKVALUE["ARMORPENETRATION_SET_1"])
					if value and SET_NAME and not tContains(Set_bonus, SET_NAME) then
						tinsert(Set_bonus, SET_NAME)
						armorPenetrationvalue = armorPenetrationvalue + tonumber(value)
					end
					_, _, value = strfind(left:GetText(), L_BLOCKVALUE["ARMORPENETRATION_SET_2"])
					if value and SET_NAME and not tContains(Set_bonus, SET_NAME) then
						tinsert(Set_bonus, SET_NAME)
						armorPenetrationvalue = armorPenetrationvalue + tonumber(value)
					end
					]]

				end
			end
		end
	end
	
	--from_talent
	if class == "WARRIOR" then 
		local hasMace = false
		local mainhandLink = GetInventoryItemLink("player", 16)
		if mainhandLink then
			local _, _, itemID = string.find(mainhandLink, "item:(%d+):%d+:%d+:%d+")
			local n = tonumber(itemID)
			local _, _, _, _, _, itemInvType = GetItemInfo(n)	
			if itemInvType == L_WEAPONTYPE["ONE_HANDED_MACE"] or itemInvType == L_WEAPONTYPE["TWO_HANDED_MACE"] then hasMace = true end
		end
		if not hasMace then
			local offhandLink = GetInventoryItemLink("player", 17)
			if offhandLink then
				local _, _, itemID = string.find(offhandLink, "item:(%d+):%d+:%d+:%d+")
				local n = tonumber(itemID)
				local _, _, _, _, _, itemInvType = GetItemInfo(n)	
				if itemInvType == L_WEAPONTYPE["ONE_HANDED_MACE"] then hasMace = true end
			end
		end
		
		if hasMace then
			local talentname, _, _, _, crank, _ = GetTalentInfo(1, 12)
			if talentname == L_TALENT.WARRIOR_MASTER_OF_ARMS then 
				armorPenetrationvalue = armorPenetrationvalue + crank * 1.2 * playerlevel
			end
		end
	end
	if class == "ROUGE" then 
		local talentname, _, _, _, crank, _ = GetTalentInfo(3, 6)
		if talentname == L_TALENT.ROGUE_SERRATED_BLADES then 
			if crank == 1 then
				armorPenetrationvalue = armorPenetrationvalue + 1.67 * playerlevel
			end
			if crank == 2 then
				armorPenetrationvalue = armorPenetrationvalue + 3.34 * playerlevel
			end
			if crank == 3 then
				armorPenetrationvalue = armorPenetrationvalue + 5 * playerlevel
			end
		end
	end
	
	--from_buff
	_, _, value = BCS:GetPlayerAura(L_ARMORPENETRATION["ARMORPENETRATION_4"])
	if value then
		armorPenetrationvalue = armorPenetrationvalue + tonumber(value)
	end
	
	_, _, value = BCS:GetPlayerAura(L_ARMORPENETRATION["ARMORPENETRATION_5"])
	if value then
		armorPenetrationvalue = armorPenetrationvalue + tonumber(value)
	end
	
	return armorPenetrationvalue
end