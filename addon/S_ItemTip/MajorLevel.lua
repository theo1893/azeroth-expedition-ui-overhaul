--采矿等级
MINING_LEVEL_DATE = {
	["铜矿"] = 1,
	["锡矿"] = 65,
	["火岩矿脉"] = 65,
	["银矿"] = 75,
	["铁矿石"] = 125,
	["精铁矿脉"] = 150,
	["次级血石矿脉"] = 155,
	["金矿石"] = 155,
	["秘银矿脉"] = 175,
	["软泥覆盖的秘银矿脉"] = 175,
	["真银矿石"] = 230,
	["软泥覆盖的真银矿脉"] = 230,
	["瑟银矿脉"] = 245,
	["软泥覆盖的瑟银矿脉"] = 245,
	["富瑟银矿"] = 275,
	["软泥覆盖的富瑟银矿脉"] = 275,
	["哈卡莱瑟银矿脉"] = 250,
	["黑铁矿脉"] = 230,
	["小黑曜石块"] = 305,
	["大黑曜石块"] = 305,
}

--采草等级
HERB_LEVEL_DATE = {
	["宁神花"] = 1,
	["银叶草"] = 1,
	["地根草"] = 15,
	["魔皇草"] = 50,
	["石南草"] = 70,
	["荆棘藻"] = 85,
	["跌打草"] = 100,
	["野钢花"] = 115,
	["墓地苔"] = 120,
	["皇血草"] = 125,
	["活根草"] = 150,
	["枯叶草"] = 160,
	["金棘草"] = 170,
	["卡德加的胡须"] = 185,
	["冬刺草"] = 195,
	["火焰花"] = 205,
	["紫莲花"] = 210,
	["阿尔萨斯之泪"] = 220,
	["太阳草"] = 230,
	["盲目草"] = 235,
	["幽灵菇"] = 245,
	["格罗姆之血"] = 250,
	["黄金参"] = 260,
	["梦叶草"] = 270,
	["山鼠草"] = 280,
	["瘟疫花"] = 285,
	["冰盖草"] = 290,
	["黑莲花"] = 300,
}

--剥皮等级
function SKINNING_LEVEL_DATE(unit)
	if UnitLevel(unit)<=10 then
		return 0
	elseif UnitLevel(unit)>10 and UnitLevel(unit)<20 then
		return (UnitLevel(unit)-10)*10
	elseif UnitLevel(unit)>=20 then
		return UnitLevel(unit)*5
	end
end

--获取副职业技能点
function GetSkillRank(skill)
	local numskills = GetNumSkillLines()
    for i = 1, numskills do
        local skillname, _, _, skillrank = GetSkillLineInfo(i)
        if(skillname == skill) then
            return skillrank
        end
    end
    return 0
end

--鼠标提示
function Add_SkillTooltip(majorreq, skill_level, levelreq)
	local tipsframe = GetMouseFocus() and GetMouseFocus():GetName() or ""
	if (skill_level > 0) and (levelreq > skill_level) then
		if (tipsframe == "WorldFrame") then	
			for i=1, GameTooltip:NumLines() do
				local line = getglobal("GameTooltipTextLeft"..i)
				if line and string.find(line:GetText(), majorreq) then
					if majorreq == UNIT_SKINNABLE then
						line:SetText(majorreq.." "..levelreq, 1, 0, 0)				
					else
						line:SetText(format(ERR_USE_LOCKED_WITH_SPELL_KNOWN_SI, majorreq, levelreq), .99, .13, .13)
					end
				end
			end
		elseif (tipsframe == "Minimap") then
			if majorreq == UNIT_SKINNABLE then return end
			GameTooltip:AddLine(format(ERR_USE_LOCKED_WITH_SPELL_KNOWN_SI, majorreq, levelreq), .99, .13, .13)
		end
	end
	GameTooltip:Show()
end

--采矿
function Add_MiningTooltip(itemname)
	local levelreq = MINING_LEVEL_DATE[itemname]
	local skill_level = GetSkillRank("采矿")
	Add_SkillTooltip("采矿", skill_level, levelreq)
end    

--草药学
function Add_HerbTooltip(itemname)
    local levelreq = HERB_LEVEL_DATE[itemname]
	local skill_level = GetSkillRank("草药学")
	Add_SkillTooltip("草药学", skill_level, levelreq)
end

--剥皮
function Add_SkinningTooltip(unit)
    local levelreq = SKINNING_LEVEL_DATE(unit)
    local skill_level = GetSkillRank("剥皮")
	Add_SkillTooltip(UNIT_SKINNABLE, skill_level, levelreq)
end

--显示提示
function MajorLevel_OnShow()
    local itemName = getglobal(this:GetParent():GetName().."TextLeft1"):GetText()
	if (MINING_LEVEL_DATE[itemName]) then
		Add_MiningTooltip(itemName)
	elseif (HERB_LEVEL_DATE[itemName]) then
		Add_HerbTooltip(itemName)
	elseif SKINNING_LEVEL_DATE("Mouseover") then
		Add_SkinningTooltip("Mouseover")
	end
end

local MajorLevelTooltip = CreateFrame('Frame', "MajorLevelTooltip", GameTooltip)
MajorLevelTooltip:SetScript("OnShow",function() MajorLevel_OnShow() end)