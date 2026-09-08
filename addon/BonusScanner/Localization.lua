-- bonus names
BONUSSCANNER_NAMES = {	
	STR 		= "力量",
	AGI 		= "敏捷",
	STA 		= "耐力",
	INT 		= "智力",
	SPI 		= "精神",
	ARMOR 		= "护甲",
	
	ARCANERES 	= "奥术抗性",	
	FIRERES 	= "火焰抗性",
	NATURERES 	= "自然抗性",
	FROSTRES 	= "冰霜抗性",
	SHADOWRES 	= "阴影抗性",
	
	FISHING 	= "钓鱼",
	MINING 		= "挖矿",
	HERBALISM 	= "草药",
	SKINNING 	= "剥皮",
	DEFENSE 	= "防御技能",
	
	BLOCK 		= "格挡率",
	BLOCKVALUE = "格挡值",
	DODGE 		= "躲闪",
	PARRY 		= "招架",
	ATTACKPOWER = "攻击强度",
	ATTACKPOWERUNDEAD = "对亡灵攻击强度",
	ATTACKPOWERFERAL = "对野兽攻击强度",
	CRIT 		= "暴击",
	RANGEDATTACKPOWER = "远程攻击强度",
	RANGEDCRIT 	= "远程攻击致命",
	TOHIT 		= "命中率",
	HASTE       = "急速";
	LIFEDRAIN   = "吸血";
	BEARAP      = "德鲁伊野性攻强";
	
	DMG 		= "法术伤害",
	DMGUNDEAD	= "对亡灵法术伤害",
	ARCANEDMG 	= "奥术伤害",
	FIREDMG 	= "火焰伤害",
	FROSTDMG 	= "冰霜伤害",
	HOLYDMG 	= "神圣伤害",
	NATUREDMG 	= "自然伤害",
	SHADOWDMG 	= "暗影伤害",
	SPELLCRIT 	= "法术致命",
	SPELLTOHIT 	= "法术命中率",
	SPELLPEN 	= "降低目标抗性",
	HEAL 		= "治疗",
	HOLYCRIT 	= "神圣法术致命",

	HEALTHREG 	= "生命再生",
	MANAREG 	= "法力再生",
	HEALTH 		= "生命值",
	MANA 		= "法力值"
};

-- equip and set bonus prefixes:
BONUSSCANNER_PREFIX_EQUIP = "装备： ";
BONUSSCANNER_PREFIX_SET = "套装：";

-- passive bonus patterns. checked against lines which start with above prefixes
BONUSSCANNER_PATTERNS_PASSIVE = {
	{ pattern = "+(%d+) 攻击强度。",		effect = {"ATTACKPOWER", "RANGEDATTACKPOWER"} },
	{ pattern = "+(%d+) 护甲。",		effect = "ENARMOR"},
	{ pattern = "+(%d+)点护甲值。",		effect = "ENARMOR"},
	{ pattern = "防御技能提高(%d+)点。",	effect = "DEFENSE" },
	{ pattern = "每5秒回复(%d+)点生命值。",	effect = "HEALTHREG" },
	{ pattern = "剥皮技能提高(%d+)点。",	effect = "SKINNING" },
	{ pattern = "钓鱼技能提高(%d+)点。",	effect = "FISHING"},
	{ pattern = "每5秒恢复(%d+)点生命值。",	effect = "HEALTHREG" },
	{ pattern = "每5秒恢复(%d+)点法力值。",	effect = "MANAREG" },
	{ pattern = "每5秒回复(%d+)点法力值。",	effect = "MANAREG" },
	{ pattern = "+(%d+) 远程攻击强度。",	effect = "RANGEDATTACKPOWER" },
	{ pattern = "+(%d+) 所有魔法抗性。",	effect = {"ARCANERES", "FIRERES", "FROSTRES", "NATURERES", "SHADOWRES"} },
	{ pattern = "使你的生命值和法力值回复提高(%d+)点。",	effect = {"MANAREG","HEALTHREG"} },
	{ pattern = "使你用盾牌格挡攻击的几率提高(%d+)%%。",	effect = "TOBLOCK" },
	{ pattern = "使你的盾牌的格挡值提高(%d+)点。",		effect = "BLOCK" },
	{ pattern = "使你击中目标的几率提高(%d+)%%。",		effect = "TOHIT" },
	{ pattern = "使你躲闪攻击的几率提高(%d+)%%。",		effect = "DODGE" },
	{ pattern = "使你招架攻击的几率提高(%d+)%%。",		effect = "PARRY" },
	{ pattern = "使你的法术击中敌人的几率提高(%d+)%%。$",	effect = "SPELLTOHIT" },
	{ pattern = "使你的物理攻击和法术击中敌人的几率提高(%d)%%。",	effect = {"SPELLTOHIT","TOHIT","RANGEDTOHIT"} },
	{ pattern = "使你的法术造成致命一击的几率提高(%d+)%%。$",	effect = "SPELLCRIT" },
	{ pattern = "提高你的法术造成致命一击的几率(%d+)%%。",	effect = "SPELLCRIT" },
	{ pattern = "使你造成致命一击的几率提高(%d+)%%。",	effect = "CRIT" },
	{ pattern = "使你打出致命一击的几率提高(%d+)%%。",	effect = "CRIT" },
	{ pattern = "使你的法术目标的魔法抗性降低(%d+)点。",	effect = "SPELLPENETRATION" },
	{ pattern = "使圣光闪现的治疗效果提高最多(%d+)点。",	effect = "FLASHHOLYLIGHTHEAL"},
	{ pattern = "使次级治疗波的治疗效果提高最多(%d+)点。",	effect = "LESSERHEALWAVE"},
	{ pattern = "使次级治疗波所恢复的生命值提高最多(%d+)点。",	 effect= "LESSERHEALWAVE"},
	{ pattern = "使闪电链和闪电箭所造成的伤害提高最多(%d+)点。",	effect = {"CHAINLIGHTNING","LIGHTNINGBOLT"}}, -- thanks 段誉只爱语嫣@mop
	{ pattern = "使地震术、烈焰震击和冰霜震击所造成的伤害提高最多(%d+)点。",	effect = {"EARTHSHOCK","FLAMESHOCK","FROSTSHOCK"}}, -- thanks 段誉只爱语嫣@mop
	{ pattern = "使你的自然系法术造成致命一击的几率提高(%d+)%%。",	effect = "NATURECRIT" },
	{ pattern = "提高奥术法术和效果所造成的伤害，最多(%d+)点。",	effect = "ARCANEDMG" },
	{ pattern = "奥术伤害提高(%d+)。",	effect = "ARCANEDMG" },
	{ pattern = "提高火焰法术和效果所造成的伤害，最多(%d+)点。",	effect = "FIREDMG" },
	{ pattern = "提高冰霜法术和效果所造成的伤害，最多(%d+)点。",	effect = "FROSTDMG" },
	{ pattern = "提高神圣法术和效果所造成的伤害，最多(%d+)点。",	effect = "HOLYDMG" },
	{ pattern = "提高自然法术和效果所造成的伤害，最多(%d+)点。",	effect = "NATUREDMG" },
	{ pattern = "提高暗影法术和效果所造成的伤害，最多(%d+)点。",	effect = "SHADOWDMG" },
	{ pattern = "使暗影法术所造成的伤害提高最多(%d+)点。",		effect = "SHADOWDMG" },
	{ pattern = "使暗影法术和效果所造成的伤害提高(%d+)点。",		effect = "SHADOWDMG" },
	{ pattern = "使治疗法术和效果所回复的生命值提高(%d+)点。",		effect = "HEAL" },
	{ pattern = "提高法术所造成的治疗效果，最多(%d+)点。",		effect = "HEAL" },
	{ pattern = "提高法术和魔法效果所造成的治疗效果，最多(%d+)点。",	effect = "HEAL"},
	{ pattern = "使法术的治疗效果提高最多(%d+)点。",			effect = "HEAL" }, 	-- thanks kkk36@mop 
	{ pattern = "法术伤害和治疗效果增加(%d+)。", effect = {"HEAL", "DMG"} }, 
	{ pattern = "[提]*高所有法术和魔法效果所造成的伤害和治疗效果，最多(%d+)点。", effect = {"HEAL", "DMG"} }, -- thanks 旋律8246@mop
	{ pattern = "使你的神圣系法术的致命一击和极效治疗几率提高(%d+)%%。",	effect = "HOLYCRIT" },
	{ pattern = "使你的神圣法术造成致命一击的几率提高(%d+)%%。",		effect = "HOLYCRIT" },
	{ pattern = "与亡灵作战时的攻击强度提高(%d+)点。同时也可获得天灾石。",	effect = "ATTACKPOWERUNDEAD"}, 
	{ pattern = "与亡灵和恶魔作战时的攻击强度提高(%d+)点。同时也可获得天灾石。",	effect = "ATTACKPOWERUNDEAD"}, 
	{ pattern = "对亡灵的攻击强度提高(%d+)点。",				effect = "ATTACKPOWERUNDEAD"},
	{ pattern = "提高所有法术和效果对亡灵所造成的伤害，最多(%d+)点。",					effect = "DMGUNDEAD"},
	{ pattern = "法术和魔法效果对亡灵造成的伤害提高最多(%d+)点。",					effect = "DMGUNDEAD"},
	{ pattern = "使魔法和法术效果对亡灵造成的伤害提高最多(%d+)点。同时也可为银色黎明收集天灾石。",	effect = "DMGUNDEAD"},
	{ pattern = "使魔法和法术效果对亡灵和恶魔所造成的伤害提高最多(%d+)点。同时也可为银色黎明收集天灾石。",	effect = "DMGUNDEAD"}, -- thanks davybear@mop
	{ pattern = "防御值提高3点，暗影抗性提高10点，生命值恢复速度提高。", effect = {"DEFENSE", "SHADOWRES", "HEALTHREG"}, value = {3, 10, 3}}, -- thanks 风の传说@mop
	{ pattern = "使你的法术伤害提高最多150点，治疗效果提高最多300点。", effect = {"DMG", "HEAL"}, value = {150, 300}}, -- thanks i8i8@mop
	{ pattern = "法术伤害提高最多150，治疗效果提高最多300。", effect = {"DMG", "HEAL"}, value = {150, 300}},
	{ pattern = "使周围半径30码范围内的所有小队成员的法术和魔法效果所造成的治疗效果提高最多(%d+)点。", effect = "HEAL" }, -- thanks i8i8@mop
	{ pattern = "使周围半径30码范围内的所有小队成员的法术和魔法效果所造成的伤害和治疗效果提高最多(%d+)点。", effect = {"HEAL", "DMG"} }, -- thanks i8i8@mop
	{ pattern = "使周围半径30码范围内的所有小队成员的法术造成致命一击的几率提高(%d+)%%。", effect = "SPELLCRIT" }, -- thanks i8i8@mop
	{ pattern = "使周围半径30码范围内的所有小队成员每5秒恢复(%d+)点法力值。", effect = "MANAREG" }, -- thanks i8i8@mop
	{ pattern = "在猎豹、熊或巨熊形态下的攻击强度提高(%d+)点。", effect = {"BEARAP","CATAP"}},
	{ pattern = "在猎豹、熊、巨熊或枭兽形态下的攻击强度提高(%d+)点。", effect = {"BEARAP","CATAP"}},
	{ pattern = "使你的有效潜行等级提高1。", effect = "STEALTH", value = 5},
	{ pattern = "使你的潜行技能等级提高。", effect = "STEALTH", value = 8},
	{ pattern = "使你的攻击速度和施法速度提高(%d+)%%。", effect = "HASTE"},
	{ pattern = "使你的攻击和施法速度提高(%d+)%%。", effect = "HASTE"},
	{ pattern = "你的攻击无视目标(%d+)点护甲。", effect = "ARMORPENETRATION"},
	{ pattern = "将你的法术目标的魔法抗性降低(%d+)点。", effect = "SPELLPENETRATION"},
	{ pattern = "所造成伤害的(%d+)%%作为治疗返还。", effect = "LIFEDRAIN"},
	{ pattern = "双手剑技能提高(%d+)点。", effect = "WEAPONSKILL_TWOHAND_SWORD"},
	{ pattern = "双手斧技能提高(%d+)点。", effect = "WEAPONSKILL_TWOHAND_AXE"},
	{ pattern = "双手锤技能提高(%d+)点。", effect = "WEAPONSKILL_TWOHAND_MACE"},
	{ pattern = "单手剑技能提高(%d+)点。", effect = "WEAPONSKILL_ONEHAND_SWORD"},
	{ pattern = "单手斧技能提高(%d+)点。", effect = "WEAPONSKILL_ONEHAND_AXE"},
	{ pattern = "单手锤技能提高(%d+)点。", effect = "WEAPONSKILL_ONEHAND_MACE"},
	{ pattern = "徒手战斗技能提高(%d+)点。", effect = "WEAPONSKILL_FIST"},
	{ pattern = "匕首技能提高(%d+)点。", effect = "WEAPONSKILL_DAGGER"},
	{ pattern = "长柄武器技能提高(%d+)点。", effect = "WEAPONSKILL_POLEARMS"},
	{ pattern = "使你的远程武器造成致命一击的几率提高(%d+)%%。", effect = "RANGEDCRIT"},
	{ pattern = "使你的法术击中敌人的几率提高2%%。使你的法术造成致命一击的几率提高2%%。使你的法术造成的伤害提高40点。", effect = {"SPELLTOHIT", "SPELLCRIT", "DMG"}, value = {2, 2, 40}},
	{ pattern = "施法时可以保持(%d+)%%的法力值恢复速度。", effect = "CASTING_MANA_REG"},
	{ pattern = "使你在施法时仍保持(%d+)%%的法力回复速度。", effect = "CASTING_MANA_REG"},
	{ pattern = "使你在施法时仍保持(%d+)%%的法力值恢复速度。", effect = "CASTING_MANA_REG"},
};

-- generic patterns have the form "+xx bonus" or "bonus +xx" with an optional % sign after the value.

-- first the generic bonus string is looked up in the following table
BONUSSCANNER_PATTERNS_GENERIC_LOOKUP = {
		["所有属性"] 		= {"STR", "AGI", "STA", "INT", "SPI"},
		["力量"]			= "STR",
		["敏捷"]			= "AGI",
		["耐力"]			= "STA",
		["智力"]			= "INT",
		["精神"] 		= "SPI",

		["治疗和法术伤害"]	= {"DMG", "HEAL"},
		["伤害和治疗法术"]	= {"DMG", "HEAL"},
		["法术治疗和伤害"]	= {"DMG", "HEAL"},
		["法术伤害和治疗"]	= {"DMG", "HEAL"},
		["法术伤害"] 		= {"DMG", "HEAL"},
		["提高法术伤害"]	= {"DMG"},
		["提高治疗效果"]	= {"HEAL"},

		["所有抗性"] 		= {"ARCANERES", "FIRERES", "FROSTRES", "NATURERES", "SHADOWRES", "ALLRES"},

		["钓鱼"]			= "FISHING",
		["鱼饵"]			= "FISHING",
		["采矿"]			= "MINING",
		["草药"]			= "HERBALISM",
		["剥皮"]			= "SKINNING",

		["攻击强度。"] 		= {"ATTACKPOWER", "RANGEDATTACKPOWER"},
		["攻击强度"] 		= {"ATTACKPOWER", "RANGEDATTACKPOWER"},
		["格挡值"]		= "BLOCK",
		["闪躲"] 		= "DODGE",
		["躲闪"] 		= "DODGE",
		["躲避"] 		= "DODGE",
		["闪避"] 		= "DODGE",
		["命中"] 		= "TOHIT",
		["法术命中"]		= "SPELLTOHIT",
		["远程攻击强度"]		= "RANGEDATTACKPOWER",
		["近战攻击强度"]	= "ATTACKPOWER",
		["每5秒回复生命"]	= "HEALTHREG",
		["治疗法术"] 		= "HEAL",
		["每5秒恢复法力"] 	= "MANAREG",
		["法力回复"]		= "MANAREG",
		["伤害"] 		= "DMG",
		["生命值"]		= "HEALTH",
		["法力值"]		= "MANA",
		["护甲"]			= "ENARMOR",
		["强化护甲"]		= "ENARMOR",
		["防御"]			= "DEFENSE",
		["盾牌格挡"]		= "BLOCK",
		["攻击强度vs亡灵.*$"]	= "ATTACKPOWERUNDEAD",
};	

-- next we try to match against one pattern of stage 1 and one pattern of stage 2 and concatenate the effect strings
BONUSSCANNER_PATTERNS_GENERIC_STAGE1 = {
	{pattern = "奥术", 	effect = "ARCANE" },	
	{pattern = "火焰", 	effect = "FIRE" },
	{pattern = "冰霜", 	effect = "FROST" },
	{pattern = "神圣", 	effect = "HOLY" },	
	{pattern = "阴影",	effect = "SHADOW" },
	{pattern = "暗影",	effect = "SHADOW" },
	{pattern = "自然", 	effect = "NATURE" }
}; 	

BONUSSCANNER_PATTERNS_GENERIC_STAGE2 = {
	{pattern = "抗性", 	effect = "RES" },	
	{pattern = "伤害", 	effect = "DMG" },
	{pattern = "效果", 	effect = "DMG" },
}; 	

-- finally if we got no match, we match against some special enchantment patterns.
BONUSSCANNER_PATTERNS_OTHER = {
		{ pattern = "(%d+)格挡",			effect = "BLOCK"},
		{ pattern = "(%d+)点格挡",		effect = "BLOCK"},
		{ pattern = "格挡 +(%d+)%%",		effect = "TOBLOCK"},	-- thanks imole @mop
		{ pattern = "(%d+)点护甲",		effect = "ARMOR"},
		{ pattern = "每5秒恢复(%d+)点生命值[。]",	 effect = "HEALTHREG" },
		{ pattern = "每5秒回复(%d+)点生命值[。]",	 effect = "HEALTHREG" },
		{ pattern = "每5秒恢复(%d+)点法力值[。]",	 effect = "MANAREG" },
		{ pattern = "每5秒回复(%d+)点法力值[。]",	 effect = "MANAREG" },
		{ pattern = "赞达拉魔力徽章",		effect = {"DMG", "HEAL"}, value = 18 },
		{ pattern = "赞达拉宁静徽章",		effect = "HEAL", value = 33 },
		{ pattern = "赞达拉力量徽章",		effect = {"ATTACKPOWER", "RANGEDATTACKPOWER"}, value = 30 },
		{ pattern = "初级巫师之油",		effect = "DMG", value = 8 },
		{ pattern = "次级巫师之油",		effect = "DMG", value = 16 },
		{ pattern = "巫师之油",			effect = "DMG", value = 24 },
		{ pattern = "卓越巫师之油",	effect = {"DMG", "SPELLCRIT"}, value = {36, 1} }, -- thanks 马沙@mop
		{ pattern = "初级法力之油",	effect = "MANAREG", value = 4 },
		{ pattern = "次级法力之油",	effect = "MANAREG", value = 8 },
		{ pattern = "卓越法力之油",	effect = { "MANAREG", "HEAL"}, value = {12, 25} },
		{ pattern = "恒金渔线",		effect = "FISHING", value = 5 },
		{ pattern = "法术伤害%+15点，法术致命一击率%+1%%", effect = {"DMG", "HEAL", "SPELLCRIT"}, value = {15, 15, 1}},
		{ pattern = "治疗%+31点，每5秒回复5点法力值", effect = {"HEAL", "MANAREG"}, value = {31, 5}},
		{ pattern = "耐力%+16点，护甲%+100点", effect = {"STA", "ENARMOR"}, value = {16, 100}},
		{ pattern = "攻击强度%+26点，致命一击率%+1%%", effect = {"ATTACKPOWER", "RANGEDATTACKPOWER", "CRIT"}, value = {26, 26, 1}},

		{ pattern = "%+(%d+)%% 急速",		effect = "HASTE" },	
		{ pattern = "攻击速度 %+(%d+)%%",		effect = "HASTE" },
		{ pattern = "%+(%d+) 护甲穿透",		effect = "ARMORPENETRATION" },
		{ pattern = "护甲穿透 %+(%d+)",		effect = "ARMORPENETRATION" },
		{ pattern = "%+(%d+) 法术穿透",		effect = "SPELLPENETRATION" },
		{ pattern = "%+(%d+)%% 吸血",		effect = "LIFEDRAIN" },
};
