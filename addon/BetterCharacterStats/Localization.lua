BCS = BCS or {}

BCS["L"] = {
	["^Set: Improves your chance to hit by (%d)%%."] = "^套装：使你击中目标的几率提高(%d)%%。",
	["Equip: Improves your chance to hit by (%d)%%."] = "装备： 使你击中目标的几率提高(%d)%%。",
	["Increases your chance to hit with melee weapons by (%d)%%."] = "使你的近战武器击中目标的几率提高(%d)%%。",
	["Increases your critical strike chance with ranged weapons by (%d)%%."] = "使你的远程武器造成致命一击的几率提高(%d)%%。",
	["Increases hit chance by (%d)%% and increases the chance movement impairing effects will be resisted by an additional %d+%%."] = "使你的攻击命中敌人的几率提高(%d)%%，并使你抵抗移动限制效果的几率提高%d+%%。",
	["Increases your critical strike chance with all attacks by (%d)%%."] = "使你的所有攻击造成致命一击的几率提高(%d)%%。",
	["Increases spell damage and healing by up to (%d+)%% of your total Spirit."] = "使你的法术的治疗和伤害效果提高，数值相当于你的精神值的(%d+)%%。",
	["Reduces the chance that the opponent can resist your Frost and Fire spells by (%d)%%."] = "使你的目标抵抗你的火焰和冰霜系法术的几率降低(%d)%%。",
	["Reduces the chance that the opponent can resist your Arcane spells by (%d+)%%."] = "使你的敌人抵抗你的奥术魔法的几率降低(%d+)%%。",
	["Reduces your target's chance to resist your Shadow spells by (%d+)%%."] = "使目标抵抗你的暗影法术的机率下降(%d+)%%。",
	["+(%d)%% Hit"] = "+(%d)%% 命中",
	
	-- Random Bonuses // https://wow.gamepedia.com/index.php?title=SuffixId&oldid=204406

	
	-- snowflakes ZG enchants
	["/Hit %+(%d+)"] = "/命中 %+(%d+)",

	-- auras
	["Chance to hit increased by (%d)%%."] = 														"命中率提高(%d)%%。",
	["Chance to hit reduced by (%d+)%%."] = 														"击中目标的几率降低(%d+)%%。",
	["Chance to hit decreased by (%d+)%% and %d+ Nature damage every %d+ sec."] = 					"攻击命中率降低(%d+)%%，每%d+秒受到%d+点自然伤害。",
	["Lowered chance to hit."] = 																	"命中率降低。", -- 5917	Fumble (25%)
	["Increases hitpoints by 300. 15%% haste to melee attacks. 10 mana regen every 5 seconds."] = 	"生命值提高300点。近战攻击速度提高15%%。每5秒回复10点法力值。",
	["Improves your chance to hit by (%d+)%%."] = 													"使你击中目标的几率提高(%d+)%%。",
	["Increases attack power by %d+ and chance to hit by (%d+)%%."] = 								"攻击强度提高%d+点，击中敌人的几率提高(%d+)%%。",
	["Holy spell critical hit chance increased by (%d+)%%."] = 										"使你的神圣法术造成致命一击的几率提高(%d+)%%。",
	["Destruction spell critical hit chance increased by (%d+)%%."] = 								"使你的毁灭系法术的致命一击几率提高(%d+)%%。",
	["Arcane spell critical hit chance increased by (%d+)%%.\r\nArcane spell critical hit damage increased by (%d+)%%."] = "奥术系法术造成致命一击效果的几率提高(%d+)%%。\r\n奥术系法术的致命一击伤害提高(%d+)%%。",
	["Holy spell critical hit chance increased by (%d+)%%."] = "使你的神圣法术造成致命一击的几率提高(%d+)%%。",
	["Destruction spell critical hit chance increased by (%d+)%%."] = "使你的毁灭系法术的致命一击几率提高(%d+)%%。",
	
	
	
	
	["MELEE_HIT_TOOLTIP"] = [[|cffffffff命中|r
	用近战或远程武器攻击 
	命中的结果.]],
	
	["SPELL_HIT_TOOLTIP"] = [[|cffffffff命中+抵抗|r
	法术攻击 
	命中+天赋抵抗的结果.]],
	
	["SPELL_HIT_SECONDARY_TOOLTIP"] = [[|cffffffff命中+抵抗 %d%% (%d%%|cff20ff20+%d%% %s|r|cffffffff)|r
	法术攻击 
	命中+天赋抵抗的结果.]],
	
	["SPELL_POWER_TOOLTIP"] = [[|cffffffff法术效果 %d|r
	增加法术造成的伤害效果.]],
	
	["SPELL_POWER_SECONDARY_TOOLTIP"] = [[|cffffffff法术效果+天赋效果 %d (%d|cff20ff20+%d %s|r|cffffffff)|r
	增加法术和天赋加成造成的伤害效果.]],
	
	["SPELL_HEALING_POWER_TOOLTIP"] = [[|cffffffff治疗效果+天赋效果 %d (%d|cff20ff20+%d|r|cffffffff)|r
	增加法术和天赋加成造成的治疗效果.]],	
	
	["SPELL_MANA_REGEN_TOOLTIP"] = [[|cffffffff非施法时%d，施法时%d (施法保持%d%%，五回%d)|r
	每2秒法力再生值.]],
	
	["HASTE_TOOLTIP"] = [[|cffffffff攻击和施法速度提高 %s |r
	攻击和施法速度提高.]],
	
	["HASTE_MELEE_TOOLTIP"] = [[|cffffffff近战攻击速度提高 %s |r
	包含如乱舞、切割等技能和装备的效果.]],
	["HASTE_RANGE_TOOLTIP"] = [[|cffffffff远程攻击速度提高 %s |r
	包含如箭袋、天赋、技能和装备的效果.]],
	
	["BLOCK_TOOLTIP"] = [[|cffffffff格挡值 %d|r
	使用盾牌格挡攻击的效果.]], 


	["ROGUE_MELEE_HIT_TOOLTIP"] = [[
+5% 总是击中敌对玩家.
+8% 技能总是命中团本级Boss.
+24.6% 任何攻击总是命中团本级Boss.]],

	PLAYERSTAT_BASE_STATS = "主属性",
	PLAYERSTAT_DEFENSES = "防御属性",
	PLAYERSTAT_MELEE_COMBAT = "近战属性",
	PLAYERSTAT_RANGED_COMBAT = "远程属性",
	PLAYERSTAT_SPELL_COMBAT = "法术属性",
	PLAYERSTAT_SPELL_SCHOOLS = "法术类型",
	
	MELEE_HIT_RATING_COLON = "命中:",
	RANGED_HIT_RATING_COLON = "命中:",
	SPELL_HIT_RATING_COLON = "命中:",
	MELEE_CRIT_COLON = "暴击:",
	RANGED_CRIT_COLON = "暴击:",
	SPELL_CRIT_COLON = "暴击:",
	MANA_REGEN_COLON = "法力回复:",
	HEAL_POWER_COLON = "治疗:",
	HASTE_COLON = "急速:",
	DODGE_COLON = DODGE .. ":",
	PARRY_COLON = PARRY .. ":",
	BLOCK_COLON = BLOCK .. ":",
	
	SPELL_POWER_COLON = "法术伤害:",
	
	SPELL_SCHOOL_ARCANE = "奥术",
	SPELL_SCHOOL_FIRE = "火焰",
	SPELL_SCHOOL_FROST = "冰霜",
	SPELL_SCHOOL_HOLY = "神圣",
	SPELL_SCHOOL_NATURE = "自然",
	SPELL_SCHOOL_SHADOW = "暗影",

	NONE = "无",
	SPELLBOOK_ATTACK = "攻击",
	["weaponSpeed"] = "速度 (%d+)%.(%d%d)",
	
}

BCS["L_RACE"] = {
	NIGHT_ELF = "暗夜精灵",
	HUMAN = "人类",
}

BCS["L_TALENT"] = {
	PRIEST_MENTAL_STRENGTH = "心灵之力",
	PRIEST_SPIRITUAL_GUIDANCE = "精神指引",
	PRIEST_PIERCING_LIGHT = "穿透之光", 
	PRIEST_SHADOW_FOCUS = "暗影集中",
	PRIEST_FORCE_OF_WILL = "意志之力",
	PRIEST_IMPROVED_INNER_FIRE = "强化心灵之火",
	PRIEST_MEDITATION = "冥想",
	PRIEST_DIVINITY = "神圣专精",
	MAGE_ARCANE_FOCUS = "奥术集中",
	MAGE_ELEMENTAL_PRECISION = "元素精准",
	MAGE_ARCANE_MEDITATION = "奥术冥想",
	PALADIN_IRONCLAD = "铁壁",
	PALADIN_PRECISION = "精确",
	PALADIN_SHIELD_SPECIALIZATION = "盾牌专精",
	PALADIN_RIGHTEOUS_STRIKES = "正义打击",
	DRUID_NATURAL_WEAPONS = "武器平衡",
	DRUID_REFLECTION = "反射",
	SHAMAN_ELEMENTAL_DEVASTATION = "元素浩劫",
	SHAMAN_IMPROVED_WATER_SHILED = "强化水之护盾",
	SHAMAN_SHIELD_SPECIALIZATION = "盾牌专精",
	SHAMAN_ENHANCING_TOTEMS = "强化图腾",
	WARRIOR_TOUGHNESS = "坚韧",
	WARRIOR_MASTER_OF_ARMS = "武器大师",
	ROGUE_SERRATED_BLADES = "锯齿利刃",
}

BCS["L_FORM"] = {
	BEAR = "熊形态",
	CAT = "猎豹形态",
	OTHER = "人形态",
}

BCS["L_HASTE"] = {
	["Libram of Rapidity"] = "^攻击速度 %+(%d)%%",
	["HASTE_improve_set"] = "^套装：使你的攻击速度和施法速度提高(%d)%%。",
	["HASTE_improve_equip_1"] = "^装备： 使你的攻击速度和施法速度提高(%d)%%。",
	["HASTE_improve_equip_2"] = "^装备： 使你的攻击和施法速度提高(%d)%%。",
	["HASTE_improve_enchant"] = "^%+(%d)%% 急速",
	["HASTE_BUFF_1"] = "^施法速度提高(%d+)%%。",
	["HASTE_BUFF_2"] = "^攻击速度和施法速度提高(%d+)%%。",
	["HASTE_BUFF_3"] = "^急速提高(%d+)%%。",
	["HASTE_PALADIN_ZEAL"] = "^攻击和施法速度提高(%d+)%%。",
	["ARCANE_POWER"] = "^施法速度提高(%d+)%%，但损失法力值",
	["Atiesh, Greatstaff of the Guardian_Druid_aura"] = "^你的攻击和施法速度提高(%d)%%。",
	["HASTE_WARLOCK_Master_Demonologist"] = "^攻击和施法速度提高(%d+)%%，受到治疗减少(%d+)%%。",
	
	["Contagion_of_Rot"] = "施法速度降低(%d+)%%。",
}

BCS["L_ARMOR"] = {
	["gainarmor"] = "(%d+)点护甲$",
	["gainarmor_set"] = "^套装：%+(%d+)护甲。",
}

BCS["L_SPELLHIT"] = {
	["Equip: Improves your chance to hit with spells by (%d)%%."] = "装备： 使你的法术击中敌人的几率提高(%d)%%。$",
	["/Spell Hit %+(%d+)"] = "/法术命中 %+(%d+)",
	["Scythe_of_Elune"] = "^装备： 使你的法术击中敌人的几率提高(%d)%%。使你的法术造成致命一击的几率提高(%d)%%。使你的法术造成的伤害提高(%d+)点。",
	["^Set: Improves your chance to hit with spells by (%d)%%."] = "^套装：使你的法术击中敌人的几率提高(%d+)%%。",
	["Rune_of_the_Guard_Captain"] = "^装备： 使你的物理攻击和法术击中敌人的几率提高(%d)%%",
	
	["Spell hit chance increased by (%d+)%%."] = "法术命中目标的几率提高(%d+)%%。",
	["Emerald_Essence"] = "^移动速度增加10%%。法术命中率增加(%d)%%。战斗中的法力回复增加(%d+)%%。",
}

BCS["L_SPELLCRIT"] = {
	["Equip: Improves your chance to get a critical strike with spells by (%d)%%."] = "装备： 使你的法术造成致命一击的几率提高(%d)%%。",
	["Eye of Diminution"] = "装备： 提高你的法术造成致命一击的几率(%d)%%。",
	["Power of the Scourge"] = "法术伤害%+(%d+)点，法术致命一击率%+(%d)%%",
	["Scythe_of_Elune"] = "^装备： 使你的法术击中敌人的几率提高(%d)%%。使你的法术造成致命一击的几率提高(%d)%%。使你的法术造成的伤害提高(%d+)点。",
	["^Set: Improves your chance to get a critical strike with spells by (%d)%%."] = "^套装：使你的法术造成致命一击的几率提高(%d)%%。",
	
	["Chance for a critical hit with a spell increased by (%d+)%%."] = 								"使用法术打出致命一击的几率提高(%d+)%%。",
	["While active, target's critical hit chance with spells and attacks increases by 10%%."] = 	"激活之后，你每一次施放火焰系伤害性法术，你的该类法术的致命一击几率都会提高10%%。",
	["Increases chance for a melee, ranged, or spell critical by (%d+)%% and all attributes by %d+."] = "打出致命一击的几率提高(%d+)%%，所有属性提高%d+点。",
	["Increases critical chance of spells by 10%%, melee and ranged by 5%% and grants 140 attack power. 120 minute duration."] = "使法术的致命一击几率提高10%%，近战和远程攻击的致命一击几率提高5%%，攻击强度提高140点。持续120分钟。",
	["Critical strike chance with spells and melee attacks increased by (%d+)%%."] = "近战武器和法术造成致命一击的几率提高(%d+)%%。",
	["mushroom_flower"] = "法术致命一击几率提高(%d+)%%。",
	["Dreamshard Elixir"] = "^法术伤害增加(%d+)点，治疗效果增加(%d+)点，使用法术造成致命一击的几率增加(%d+)%%。",
	["Moonkin Aura"] = "法术的致命一击率提高(%d+)%%。",
	["Atiesh, Greatstaff of the Guardian_Mage_aura"] = "^法术造成致命一击的几率提高(%d)%%。",
	["Melee critical-hit chance reduced by (%d+)%%.\r\nSpell critical-hit chance reduced by (%d+)%%."] = "近战武器造成致命一击的几率降低(%d+)%%。\r\n法术造成致命一击的几率降低(%d+)%%。",
	["Dream_Mongoose"] = "^法术伤害提高%d+点，\r\n敏捷提高25点，\r\n致命一击几率提高(%d+)%%",
}

BCS["L_MANAREGEN"] = {
	["^Mana Regen %+(%d+)"] = "^法力回复 %+(%d+)",
	["Equip: Restores (%d+) mana per 5 sec."] = "装备： 每5秒回复(%d+)点法力值。",
	["^%+(%d+) mana every 5 sec."] = "^每5秒回复(%d+)点法力值。",
	["Resilience of the Scourge"] = "^治疗%+(%d+)点，每5秒回复(%d+)点法力值",
	
	["Blessing_of_Wisdom"] = "^每5秒恢复(%d+)点法力值。",
	["Mageblood_Potion"] = "^每5秒回复(%d+)点法力值。",
	["Emerald_Essence"] = "^移动速度增加10%%。法术命中率增加(%d)%%。战斗中的法力回复增加(%d+)%%。",
	["cast_mana_percent_regen_1"] = "装备： 施法时可以保持(%d+)%%的法力值恢复速度。",
	["cast_mana_percent_regen_2"] = "装备： 使你在施法时仍保持(%d+)%%的法力值恢复速度。",
	["cast_mana_percent_regen_set"] = "^套装：使你在施法时仍保持(%d+)%%的法力回复速度。",
	
	["Evocation"] = "法力值回复速度提高(%d+)%%。",
	["magic_armor"] = "对所有魔法的抗性提高15点，在任意情况下都保持(%d+)%%的法力值回复速度。",
	["arcane_mage_3T2"] = "^套装：魔甲术可使你的所有抗性提高15，并在施法时保持(%d+)%%的法力恢复速度。",
	["Sylvan_Blessing"] = "^施法时仍保持(%d+)%%的法力恢复速度",
	["Aspect_of_Strider"] = "^距离陆行鸟50码范围内的小队成员在战斗中将获得(%d+)%%的法力值回复和20%%的生命值回复。该效果持续到主动取消。",
	
	
	["Shadowform"]="^使你能造成的暗影伤害提高(%d+)%%，受到物理攻击时承受的伤害降低(%d+)%%。不能施放神圣系的法术。",
	["Water_Shiled"] = "^受到攻击恢复(%d+)点法力值。",
	["Mana_Spring_totem"] = "^每2秒恢复(%d+)点法力值。",
	["Fizzy_Energy_Drink"] = "^法力值回复提高每5秒(%d+)点。",
}

BCS["L_SPELL_SCHOOL"] = {
	["Equip: Increases damage done by Arcane spells and effects by up to (%d+)."] = "装备： 提高奥术法术和效果所造成的伤害，最多(%d+)点。",
	["^%+(%d+) Arcane Spell Damage"] = "^%+(%d+) 奥术法术伤害",
	["Netherwind Epaulets"] = "^装备： 奥术伤害提高(%d+)。",
	["glove_20_arcane_power"] = "^%+(%d+) 奥术伤害",

	["Equip: Increases damage done by Fire spells and effects by up to (%d+)."] = "装备： 提高火焰法术和效果所造成的伤害，最多(%d+)点。",
	["Fire Damage %+(%d+)"] = "火焰伤害 %+(%d+)",
	["^%+(%d+) Fire Spell Damage"] = "^%+(%d+) 火焰法术伤害",

	["Equip: Increases damage done by Frost spells and effects by up to (%d+)."] = "装备： 提高冰霜法术和效果所造成的伤害，最多(%d+)点。",
	["Frost Damage %+(%d+)"] = "冰霜伤害 %+(%d+)",
	["^%+(%d+) Frost Spell Damage"] = "^%+(%d+) 冰霜法术伤害",

	["Equip: Increases damage done by Holy spells and effects by up to (%d+)."] = "装备： 提高神圣法术和效果所造成的伤害，最多(%d+)点。",
	["^%+(%d+) Holy Spell Damage"] = "^%+(%d+) 神圣法术伤害",

	["jewel_9_nature_power"] = "^提高自然效果 %+(%d)",
	["^%+(%d+) Nature Spell Damage"] = "^%+(%d+) 自然法术伤害",
	["Equip: Increases damage done by Nature spells and effects by up to (%d+)."] = "装备： 提高自然法术和效果所造成的伤害，最多(%d+)点。",
	
	["Set_Nature_damage"] = "套装：提高自然法术和效果所造成的伤害，最多(%d+)点。",
	
	["Equip: Increases damage done by Shadow spells and effects by up to (%d+)."] = "装备： 提高暗影法术和效果所造成的伤害，最多(%d+)点。",
	["Equip: Increases damage done by Shadow spells and effects by up (%d+)."] = "装备： 使暗影法术所造成的伤害提高最多(%d+)点。",
	["Shadow_effect_3"] = "装备： 使暗影法术和效果所造成的伤害提高(%d+)点。",
	["Shadow Damage %+(%d+)"] = "暗影伤害 %+(%d+)",
	["^%+(%d+) Shadow Spell Damage"] = "^%+(%d+) 暗影法术伤害",
	
	["Elixir_of_Greater_Nature_Power"] = "法术和技能造成的自然伤害最多增加(%d+)。",
	["Elixir_of_Greater_Frost_Power"] = "冰霜法术伤害提高最多(%d+)点。",
	["Elixir_of_Greater_Arcane_Power"] = "奥术法术伤害提高最多(%d+)点。",
}

BCS["L_SPELLPOWER"] = {
	["Equip: Increases damage and healing done by magical spells and effects by up to (%d+)."] = "装备： 提高所有法术和魔法效果所造成的伤害和治疗效果，最多(%d+)点。",
	["jewel_5_spell_power"] = "^提高法术伤害 %+(%d+)",
	["Atiesh, Greatstaff of the Guardian_Druid"] = "装备： 法术伤害提高最多(%d+)，治疗效果提高最多(%d+)。",
	["Atiesh, Greatstaff of the Guardian_Priest"] = "装备： 使你的法术伤害提高最多(%d+)点，治疗效果提高最多(%d+)点。",
	["Scythe_of_Elune"] = "^装备： 使你的法术击中敌人的几率提高(%d)%%。使你的法术造成致命一击的几率提高(%d)%%。使你的法术造成的伤害提高(%d+)点。",
	["Power of the Scourge"] = "法术伤害%+(%d+)点，法术致命一击率%+(%d)%%",
	["Spell Damage %+(%d+)"] = "%+(%d+) 法术伤害",
	["^%+(%d+) Spell Damage and Healing"] = "^法术治疗和伤害 %+(%d+)",
	["^%+(%d+) Damage and Healing Spells"] = "^%+(%d+) 伤害和治疗法术",
	["Healing Spells and Damage %+(%d+)"] = "治疗和法术伤害 %+(%d+)",
	["Desecration"] = "装备： 法术伤害和治疗效果增加(%d+)",
	["^Set: Increases damage and healing done by magical spells and effects by up to (%d+)%."] = "^套装：提高所有法术和魔法效果所造成的伤害和治疗效果，最多(%d+)点。",
	
	["Magical damage dealt is increased by up to (%d+)."] = "^法术伤害提高最多(%d+)点。",
	["Atiesh, Greatstaff of the Guardian_Warlock_aura"] = "^使法术和魔法效果造成的伤害和治疗效果提高最多(%d+)点。",
	["Dreamshard Elixir"] = "^法术伤害增加(%d+)点，治疗效果增加(%d+)点，使用法术造成致命一击的几率增加(%d+)%%。",
	["Talisman of Ephemeral Power"] = "^魔法伤害和治疗效果提高(%d+)点。",
	["INNER_FIRE"] = "^护甲值提高(%d+)。法术伤害增加(%d+)。",
	["Dreamtonic"] = "^法术和技能造成的魔法伤害最多增加(%d+)。",
	["Zandalarian_Hero_Charm_sp"] = "法术伤害效果提高最多(%d+)点。",
	["Wrath_of_Cenarius"] = "^法术效果提高(%d+)点。",
	["Remains_of_Overwhelming_Power"] = "^法术伤害和治疗效果增加(%d+)",
	["The_Restrained_Essence_of_Sapphiron"] = "^法术伤害和治疗效果提高最多(%d+)点。",
	["Arcane_Giant"] = "^法术伤害提高(%d+)点，\r\n力量提高25点。",
	["Dream_Firewater"] = "^法术伤害提高(%d+)点，\r\n攻击强度提高35点。",
	["Dream_Mongoose"] = "^法术伤害提高(%d+)点，\r\n敏捷提高25点，\r\n致命一击几率提高(%d+)%%",
}

BCS["L_HEALPOWER"] = {
	["Equip: Increases healing done by spells and effects by up to (%d+)."] = "装备： 提高法术所造成的治疗效果，最多(%d+)点。",
	["Healing Spells %+(%d+)"] = "治疗法术 %+(%d+)",
	["Equip: Increases healing (%d+)."] = "装备： 使治疗法术和效果所回复的生命值提高(%d+)点。",
	["^%+(%d+) Healing Spells"] = "^%+(%d+) 治疗法术",
	["jewel_12_heal_power"] = "^提高治疗效果 %+(%d+)",
	["Hammer of the Twisting Nether"] = "装备： 使法术的治疗效果提高最多(%d+)点。",
	["Scepter of the False Prophet"] = "装备： 提高法术和魔法效果所造成的治疗效果，最多(%d+)点。",
	["Atiesh, Greatstaff of the Guardian_Druid"] = "装备： 法术伤害提高最多(%d+)，治疗效果提高最多(%d+)。",
	["Atiesh, Greatstaff of the Guardian_Priest"] = "装备： 使你的法术伤害提高最多(%d+)点，治疗效果提高最多(%d+)点。",
	["Resilience of the Scourge"] = "^治疗%+(%d+)点，每5秒回复(%d+)点法力值",
	["^Set: Increases healing done by spells and effects by up to (%d+)%."] = "^套装：提高法术所造成的治疗效果，最多(%d+)点。",
	
	["Dreamshard Elixir"] = "^法术伤害增加(%d+)点，治疗效果增加(%d+)点，使用法术造成致命一击的几率增加(%d+)%%。",
	["Healing done by magical spells is increased by up to (%d+)."] = "治疗法术的效果提高最多(%d+)点。",
	["Atiesh, Greatstaff of the Guardian_Priest_aura"] = "^法术和魔法效果所造成的治疗效果提高最多(%d+)点。",
	["Zandalarian_Hero_Charm_hp"] = "法术治疗效果提高最多(%d+)点。",
	["Spirit_of_Arathor"] = "^治疗效果提高(%d+)。",
}

BCS["L_HIT"] = {
	["Rune_of_the_Guard_Captain"] = "^装备： 使你的物理攻击和法术击中敌人的几率提高(%d)%%",
}

BCS["L_BLOCKVALUE"] = {
	["BLOCKVALUE_1"] = "^(%d+)格挡",
	["BLOCKVALUE_2"] = "^装备： 使你的盾牌的格挡值提高(%d+)点。",
	["BLOCKVALUE_SET_1"] = "套装：盾牌的格挡值提高(%d+)点。",
	["BLOCKVALUE_SET_2"] = "套装：盾牌的格挡值提高(%d+)，神圣之盾产生的威胁值提高",
	
	["pala_8t2"] = "^盾牌的格挡值提高(%d+)，直到下次格挡",
	["Stoneskin_totem"] = "^物理伤害减免(%d+)点。",

}

BCS["L_ARMORPENETRATION"] = {
	["ARMORPENETRATION_1"] = "^装备： 你的攻击无视目标(%d+)点护甲。",
	["ARMORPENETRATION_2"] = "^护甲穿透 %+(%d+)",
	["ARMORPENETRATION_3"] = "%+(%d+) 护甲穿透",
	
	["ARMORPENETRATION_4"] = "忽略目标的(%d+)点护甲值。",
	["ARMORPENETRATION_5"] = "当前目标的护甲值降低(%d+)点。",
}

BCS["L_WEAPONTYPE"] = {
	["ONE_HANDED_MACE"] = "单手锤",
	["TWO_HANDED_MACE"] = "双手锤",
}
