
local name = "Common Auras"
local L = AceLibrary("AceLocale-2.2"):new("BigWigs" .. name)
local BC = AceLibrary("Babble-Class-2.2")
local BS = AceLibrary("Babble-Spell-2.2")

local bzorgrimmar = AceLibrary("Babble-Zone-2.2")["Orgrimmar"]
local bzthunderbluff = AceLibrary("Babble-Zone-2.2")["Thunder Bluff"]
local bzundercity = AceLibrary("Babble-Zone-2.2")["Undercity"]
local bzstonard = AceLibrary("Babble-Zone-2.2")["Stonard"]
local bzstormwind = AceLibrary("Babble-Zone-2.2")["Stormwind City"]
local bzironforge = AceLibrary("Babble-Zone-2.2")["Ironforge"]
local bzdarnassus = AceLibrary("Babble-Zone-2.2")["Darnassus"]
local bztheramore = AceLibrary("Babble-Zone-2.2")["Theramore Isle"]
local bzkarazhan = AceLibrary("Babble-Zone-2.2")["Karazhan"]

local spellStatus = nil

local whZone = nil
local whColor = nil
local whText = nil

local portalColor = nil
local portalText = nil

local PROTOCOL_VERSION = "2.16.1"

-- Use for detecting instant cast target (Fear Ward)
local spellTarget = nil
local spellCasting = nil

local timeToShutdown = nil
local shutdownBigWarning = nil

L:RegisterTranslations("enUS", function()
	return {
		-- iconPrefix = "Interface\\Icons\\",

		-- msg_fearward = " FearWard on ",
		-- bar_fearward = " FearWard CD",

		-- msg_shieldwall = " Shield Wall",
		-- bar_shieldwall = " Shield Wall",

		-- msg_laststand = " Last Stand",
		-- bar_laststand = " Last Stand",

		-- msg_lifegivingGem = " Enlightened State",
		-- bar_lifegivingGem = " Enlightened State",

		-- msg_challengingShout = " Challenging Shout",
		-- bar_challengingShout = " Challenging Shout",

		-- msg_challengingRoar = " Challenging Roar",
		-- bar_challengingRoar = " Challenging Roar",

		-- msg_divineIntervention = "Divine Intervention on ",
		-- bar_divineIntervention = " Divine Intervention",

		-- msg_divineIntervention = "Divine Intervention on ",
		-- bar_divineIntervention = " Divine Intervention",

		-- msg_barkskin = " Barkskin",
		-- bar_barkskin = " Barkskin",

		-- msg_berserk = " Berserk",
		-- bar_berserk = " Berserk",


		trigger_barkskin = "You cast Barkskin.",
		trigger_berserk = "You cast Berserk.",
		trigger_spiritlink = "You cast Spirit Link on (.+).",
		trigger_spiritlink_self = "You cast Spirit Link.",
		trigger_fearward = "You cast Fear Ward on (.+).",
		trigger_fearward_self = "You cast Fear Ward.",

		-- msg_spiritlink = " Spirit Link on ",

		-- msg_spiritlink = " Spirit Link on ",

		-- msg_spiritlink = " Spirit Link on ",
		-- bar_spiritlink = " Spirit Link",

		trigger_scythe = "You cast The Scythe of Elune.",
		msg_scythe = " Scythe of Elune",
		bar_scythe = " Scythe of Elune",

		trigger_scythe = "You cast The Scythe of Elune.",
		msg_scythe = " Scythe of Elune",
		bar_scythe = " Scythe of Elune",

		-- portal_regexp = ".*: (.*)",

		-- trigger_wormhole = "just opened a wormhole.", --CHAT_MSG_MONSTER_EMOTE
		-- bar_wormhole = " Wormhole",
		-- msg_wormhole = " Wormhole",

		-- trigger_orange = "begins to conjure a refreshment table.", --CHAT_MSG_MONSTER_EMOTE
		-- bar_orange = "Oranges!",
		-- msg_orange = "Oranges! Get your Vitamin C",

		-- trigger_soulwell = "begins a Soulwell ritual.", --CHAT_MSG_MONSTER_EMOTE
		-- bar_soulwell = "Soulwell!",
		-- msg_soulwell = "Soulwell! Get your Cookie",

		-- trigger_shutdown = "Shutdown in (.+) (.+)", --CHAT_MSG_SYSTEM
		-- trigger_restart = "Restart in (.+) (.+)", --CHAT_MSG_SYSTEM
		-- trigger_restartMinSec = "Shutdown in (.+) Minutes (.+) Seconds.", --CHAT_MSG_SYSTEM
		-- trigger_shutdownMinSec = "Restart in (.+) Minutes (.+) Seconds.", --CHAT_MSG_SYSTEM
		-- bar_shutDown = "Server Shutdown/Restart",
	
		casounds = "Common Auras Sounds",
		
		["Toggle %s display."] = true,
		["Wormhole"] = true,
		["Orange"] = true,
		["Soulwell"] = true,
		["Portal"] = true,
		["Shutdown"] = true,
		["broadcast"] = true,
		["Broadcast"] = true,
		["Toggle broadcasting the messages to the raidwarning channel."] = true,
		["Enable the Sounds for Common Auras Events"] = true,

		["Gives timer bars and raid messages about common buffs and debuffs."] = true,
		["Common Auras"] = true,
		["commonauras"] = true,

		["Invisibility"] = true,
		["Deepwood Pipe"] = true,
		["Lesser Invisibility"] = true,
		["Limited Invulnerability Potion"] = true,
		["Blessing of Protection"] = true,
		["Power Infusion"] = true,

		-- ["di_trigger"] = "You gain Divine Intervention",
		-- ["invis_trigger"] = "You gain Invisibility",
		-- ["lesser_invis_trigger"] = "You gain Lesser Invisibility",
		-- ["cloaking_invis_trigger"] = "You gain Cloaking",
		-- ["lip_trigger"] = "You gain Invulnerability",
		-- ["bop_trigger"] = "You gain Blessing of Protection",
		-- ["powerinfusion_trigger"] = "You gain Power Infusion",
		-- ["deepwoodpipe_trigger"] = "You gain Smoke Cloud", -- use this as trigger instead of Stealth due to overlap with rogue ability

		-- ["di_fades"] = "Divine Intervention fades",
		-- ["invis_fades"] = "Invisibility fades",
		-- ["lesser_invis_fades"] = "Lesser Invisibility fades",
		-- ["cloaking_invis_fades"] = "Cloaking fades",
		-- ["lip_fades"] = "Invulnerability fades",
		-- ["bop_fades"] = "Blessing of Protection fades",
		-- ["powerinfusion_fades"] = "Power Infusion fades",
		-- ["deepwoodpipe_fades"] = "Stealth fades",

		--英文端汉化，wind
		iconPrefix = "Interface\\Icons\\",

	msg_fearward = " 防护恐惧结界 ",
	bar_fearward = " 防护恐惧结界冷却",
	
	msg_shieldwall = " 盾墙",
	bar_shieldwall = " 盾墙",
	
	msg_laststand = " 破釜沉舟",
	bar_laststand = " 破釜沉舟",
	
	msg_lifegivingGem = " 生命宝石",
	bar_lifegivingGem = " 生命宝石",
	
	msg_challengingShout = " 挑战怒吼",
	bar_challengingShout = " 挑战怒吼",
	
	msg_challengingRoar = " 挑战咆哮",
	bar_challengingRoar = " 挑战咆哮",
	
	msg_divineIntervention = "圣佑术在 ",
	bar_divineIntervention = " 圣佑术",

	msg_barkskin = " 树皮术",
	bar_barkskin = " 树皮术",

	msg_berserk = " 狂暴",
	bar_berserk = " 狂暴",

	msg_spiritlink = " 灵魂连接: ",
	msg_spiritlink = " 灵魂连接: ",
	bar_spiritlink = " 灵魂连接",

	msg_scythe = " 艾露恩之镰",
	bar_scythe = " 艾露恩之镰",

		portal_regexp = ".*: (.*)",

		trigger_wormhole = "just opened a wormhole.", --CHAT_MSG_MONSTER_EMOTE
	bar_wormhole = " 虫洞",
	msg_wormhole = " 虫洞",

		trigger_orange = "begins to conjure a refreshment table.", --CHAT_MSG_MONSTER_EMOTE
	bar_orange = "橙子！",
	msg_orange = "橙子！补充维生素C",

		trigger_soulwell = "begins a Soulwell ritual.", --CHAT_MSG_MONSTER_EMOTE
	bar_soulwell = "灵魂之井!",
	msg_soulwell = "灵魂之井！拿你的饼干",

		trigger_shutdown = "Shutdown in (.+) (.+)", --CHAT_MSG_SYSTEM
		trigger_restart = "Restart in (.+) (.+)", --CHAT_MSG_SYSTEM
		trigger_restartMinSec = "Shutdown in (.+) Minutes (.+) Seconds.", --CHAT_MSG_SYSTEM
		trigger_shutdownMinSec = "Restart in (.+) Minutes (.+) Seconds.", --CHAT_MSG_SYSTEM
	bar_shutDown = "服务器关机/重启",

    
    -- casounds = "常用光环音效",
        
	["Toggle %s display."] = "切换%s显示。",
	-- ["Wormhole"] = "虫洞",
	-- ["Orange"] = "橘子",
	-- ["Soulwell"] = "灵魂之井",
	-- ["Portal"] = "传送门",
	-- ["Shutdown"] = "关机",
	-- ["broadcast"] = "广播",
	-- ["Broadcast"] = "广播",
	["Toggle broadcasting the messages to the raidwarning channel."] = "切换广播信息到团队警告频道。",
	["Enable the Sounds for Common Auras Events"] = "启用常用光环事件的音效",

	["Gives timer bars and raid messages about common buffs and debuffs."] = "提供关于常见增益和减益的计时条和团队信息。",
	["Common Auras"] = "常见的光环",
	-- ["commonauras"] = "常见的光环",

		["Invisibility"] = "隐形术",
		["Deepwood Pipe"] = "深木管",
		["Lesser Invisibility"] = "次级隐形术",
		["Limited Invulnerability Potion"] = "有限无敌药水",
		["Blessing of Protection"] = "保护祝福",
		["Power Infusion"] = "能量灌注",

		["di_trigger"] = "You gain Divine Intervention",
		["invis_trigger"] = "You gain Invisibility",
		["lesser_invis_trigger"] = "You gain Lesser Invisibility",
		["cloaking_invis_trigger"] = "You gain Cloaking",
		["lip_trigger"] = "You gain Invulnerability",
		["bop_trigger"] = "You gain Blessing of Protection",
		["powerinfusion_trigger"] = "You gain Power Infusion",
		["deepwoodpipe_trigger"] = "You gain Smoke Cloud", -- use this as trigger instead of Stealth due to overlap with rogue ability

		["di_fades"] = "Divine Intervention fades",
		["invis_fades"] = "Invisibility fades",
		["lesser_invis_fades"] = "Lesser Invisibility fades",
		["cloaking_invis_fades"] = "Cloaking fades",
		["lip_fades"] = "Invulnerability fades",
		["bop_fades"] = "Blessing of Protection fades",
		["powerinfusion_fades"] = "Power Infusion fades",
		["deepwoodpipe_fades"] = "Stealth fades",

	Dwarf = "Dwarf",
	Alliance = "Alliance",
	Horde = "Horde",
	inminutesseconds = " in (.+) Minutes (.+) Seconds.",
	in_plus = " in (.+) (.+)",
	inute = "inute",
	["Warlock Pet"] = true,
	}
end)

L:RegisterTranslations("zhCN", function()
	return {
	-- Wind汉化修复Turtle-WOW中文数据
	-- Last update: 2024-06-22
		iconPrefix = "Interface\\Icons\\",

	msg_fearward = " 防护恐惧结界 ",
	bar_fearward = " 防护恐惧结界冷却",
	
	msg_shieldwall = " 盾墙",
	bar_shieldwall = " 盾墙",
	
	msg_laststand = " 破釜沉舟",
	bar_laststand = " 破釜沉舟",
	
	msg_lifegivingGem = " 生命宝石",
	bar_lifegivingGem = " 生命宝石",
	
	msg_challengingShout = " 挑战怒吼",
	bar_challengingShout = " 挑战怒吼",
	
	msg_challengingRoar = " 挑战咆哮",
	bar_challengingRoar = " 挑战咆哮",
	
	msg_divineIntervention = "圣佑术在 ",
	bar_divineIntervention = " 圣佑术",

	msg_barkskin = " 树皮术",
	bar_barkskin = " 树皮术",

	msg_berserk = " 狂暴",
	bar_berserk = " 狂暴",

	msg_spiritlink = " 灵魂连接: ",
	bar_spiritlink = " 灵魂连接",

	msg_scythe = " 艾露恩之镰",
	bar_scythe = " 艾露恩之镰",

	trigger_barkskin = "你施放了树皮术",
	trigger_berserk = "你施放了狂暴。",
	trigger_spiritlink = "你对(.+)施放了灵魂连接。",
	trigger_spiritlink_self = "你施放了灵魂连接。",
	trigger_fearward = "你对(.+)施放了防护恐惧结界。",
	trigger_fearward_self = "你施放了防护恐惧结界。",

		portal_regexp = ".*: (.*)",

		portal_regexp = ".*: (.*)",

		trigger_wormhole = "just opened a wormhole.", --CHAT_MSG_MONSTER_EMOTE
	bar_wormhole = " 虫洞",
	msg_wormhole = " 虫洞",

		trigger_orange = "begins to conjure a refreshment table.", --CHAT_MSG_MONSTER_EMOTE
	bar_orange = "橙子！",
	msg_orange = "橙子！补充维生素C",

		trigger_soulwell = "begins a Soulwell ritual.", --CHAT_MSG_MONSTER_EMOTE
	bar_soulwell = "灵魂之井!",
	msg_soulwell = "灵魂之井！拿你的糖",

		trigger_shutdown = "Shutdown in (.+) (.+)", --CHAT_MSG_SYSTEM
		trigger_restart = "Restart in (.+) (.+)", --CHAT_MSG_SYSTEM
		trigger_restartMinSec = "Shutdown in (.+) Minutes (.+) Seconds.", --CHAT_MSG_SYSTEM
		trigger_shutdownMinSec = "Restart in (.+) Minutes (.+) Seconds.", --CHAT_MSG_SYSTEM
	bar_shutDown = "服务器关机/重启",
    
    casounds = "常用光环音效",
        
	["Toggle %s display."] = "切换%s显示。",
	["Wormhole"] = "虫洞",
	["Orange"] = "橘子",
	["Soulwell"] = "灵魂之井",
	["Portal"] = "传送门",
	["Shutdown"] = "关机",
	["broadcast"] = "广播",
	["Broadcast"] = "广播",
	["Toggle broadcasting the messages to the raidwarning channel."] = "切换广播信息到团队警告频道。",
	["Enable the Sounds for Common Auras Events"] = "启用常用光环事件的音效",

	["Gives timer bars and raid messages about common buffs and debuffs."] = "提供关于常见增益和减益的计时条和团队信息。",
	["Common Auras"] = "常见的光环",
	["commonauras"] = "常见的光环",

		["Invisibility"] = "隐形术",
		["Deepwood Pipe"] = "深木管",
		["Lesser Invisibility"] = "次级隐形术",
		["Limited Invulnerability Potion"] = "有限无敌药水",
		["Blessing of Protection"] = "保护祝福",
		["Power Infusion"] = "能量灌注",

		["di_trigger"] = "You gain Divine Intervention",
		["invis_trigger"] = "You gain Invisibility",
		["lesser_invis_trigger"] = "You gain Lesser Invisibility",
		["cloaking_invis_trigger"] = "You gain Cloaking",
		["lip_trigger"] = "You gain Invulnerability",
		["bop_trigger"] = "保护[祝之][福手]",
		["powerinfusion_trigger"] = "You gain Power Infusion",
		["deepwoodpipe_trigger"] = "You gain Smoke Cloud", -- use this as trigger instead of Stealth due to overlap with rogue ability

        ["di_fades"] = "神圣干涉消失了",
        ["invis_fades"] = "隐形术消失了",
        ["lesser_invis_fades"] = "次级隐形术消失了",
        ["cloaking_invis_fades"] = "隐蔽消失了",
        ["lip_fades"] = "无敌消失了",
        ["bop_fades"] = "保护[祝之][福手]",
        ["powerinfusion_fades"] = "能量灌注消失了",
        ["deepwoodpipe_fades"] = "潜行消失了",

	Dwarf = "矮人",
	Alliance = "联盟",
	Horde = "部落",
	inminutesseconds = "在 (.+) 分钟 (.+) 秒。",
	in_plus = "在 (.+) (.+)",
	inute = "分",
	["Warlock Pet"] = "术士宠物",
	}
end)

BigWigsCommonAuras = BigWigs:NewModule(name, "AceHook-2.1")
BigWigsCommonAuras.synctoken = myname
BigWigsCommonAuras.defaultDB = {
	challengingshout = true,
	laststand = true,
	shieldwall = true,
	
	challengingroar = true,
	
	bop = true,
	deepwood = true,
	di = true,
	fearward = true,
	invis = true,
	lifegivinggem = true,
	lip = true,
	powerinfusion = true,
	
	barkskin = true,
	berserk = true,
	spiritlink = true,
	
	orange = true,
	portal = true,
	shutdown = true,
	soulwell = true,
	wormhole = true,
	warlockpet = true,
	
	broadcast = false,
	
	casounds = true,
}
BigWigsCommonAuras.consoleCmd = L["commonauras"]
BigWigsCommonAuras.revision = 30094
BigWigsCommonAuras.external = true
BigWigsCommonAuras.consoleOptions = {
	type = "group",
	name = L["Common Auras"],
	desc = L["Gives timer bars and raid messages about common buffs and debuffs."],
	args = {
		
		
		["challengingshout"] = {
			type = "toggle",
			name = BS["Challenging Shout"],
			order = 1,
			desc = string.format(L["Toggle %s display."], BS["Challenging Shout"]),
			get = function()
				return BigWigsCommonAuras.db.profile.challengingshout
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.challengingshout = v
			end,
		},
		["laststand"] = {
			type = "toggle",
			name = BS["Last Stand"],
			order = 2,
			desc = string.format(L["Toggle %s display."], BS["Last Stand"]),
			get = function()
				return BigWigsCommonAuras.db.profile.laststand
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.laststand = v
			end,
		},
		["shieldwall"] = {
			type = "toggle",
			name = BS["Shield Wall"],
			order = 3,
			desc = string.format(L["Toggle %s display."], BS["Shield Wall"]),
			get = function()
				return BigWigsCommonAuras.db.profile.shieldwall
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.shieldwall = v
			end,
		},
		["spacer1"] = {
			type = "header",
			name = " ",
			order = 4,
		},
	
		["challengingroar"] = {
			type = "toggle",
			name = BS["Challenging Roar"],
			order = 5,
			desc = string.format(L["Toggle %s display."], BS["Challenging Roar"]),
			get = function()
				return BigWigsCommonAuras.db.profile.challengingroar
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.challengingroar = v
			end,
		},
		["barkskin"] = {
			type = "toggle",
			name = L["msg_barkskin"],
			order = 5.1,
			desc = string.format(L["Toggle %s display."], L["msg_barkskin"]),
			get = function()
				return BigWigsCommonAuras.db.profile.barkskin
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.barkskin = v
			end,
		},
		["berserk"] = {
			type = "toggle",
			name = L["msg_berserk"],
			order = 5.2,
			desc = string.format(L["Toggle %s display."], L["msg_berserk"]),
			get = function()
				return BigWigsCommonAuras.db.profile.berserk
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.berserk = v
			end,
		},
		["spiritlink"] = {
			type = "toggle",
			name = L["bar_spiritlink"],
			order = 5.3,
			desc = string.format(L["Toggle %s display."], L["bar_spiritlink"]),
			get = function()
				return BigWigsCommonAuras.db.profile.spiritlink
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.spiritlink = v
			end,
		},
		["spacer2"] = {
			type = "header",
			name = " ",
			order = 6,
		},
		
		["bop"] = {
			type = "toggle",
			name = L["Blessing of Protection"],
			order = 7,
			desc = string.format(L["Toggle %s display."], L["Blessing of Protection"]),
			get = function()
				return BigWigsCommonAuras.db.profile.bop
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.bop = v
			end,
		},
		["deepwood"] = {
			type = "toggle",
			name = L["Deepwood Pipe"],
			order = 8,
			desc = string.format(L["Toggle %s display."], L["Deepwood Pipe"]),
			get = function()
				return BigWigsCommonAuras.db.profile.deepwood
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.deepwood = v
			end,
		},
		["di"] = {
			type = "toggle",
			name = BS["Divine Intervention"],
			order = 9,
			desc = string.format(L["Toggle %s display."], BS["Divine Intervention"]),
			get = function()
				return BigWigsCommonAuras.db.profile.di
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.di = v
			end,
		},
		["fearward"] = {
			type = "toggle",
			name = BS["Fear Ward"],
			order = 10,
			desc = string.format(L["Toggle %s display."], BS["Fear Ward"]),
			get = function()
				return BigWigsCommonAuras.db.profile.fearward
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.fearward = v
			end,
		},
		["invisibility"] = {
			type = "toggle",
			name = L["Invisibility"],
			order = 11,
			desc = string.format(L["Toggle %s display."], L["Invisibility"]),
			get = function()
				return BigWigsCommonAuras.db.profile.invis
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.invis = v
			end,
		},
		["lifegivinggem"] = {
			type = "toggle",
			name = BS["Enlightened State"],
			order = 12,
			desc = string.format(L["Toggle %s display."], BS["Enlightened State"]),
			get = function()
				return BigWigsCommonAuras.db.profile.lifegivinggem
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.lifegivinggem = v
			end,
		},
		["lip"] = {
			type = "toggle",
			name = L["Limited Invulnerability Potion"],
			order = 13,
			desc = string.format(L["Toggle %s display."], L["Limited Invulnerability Potion"]),
			get = function()
				return BigWigsCommonAuras.db.profile.lip
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.lip = v
			end,
		},		
		["powerinfusion"] = {
			type = "toggle",
			name = L["Power Infusion"],
			order = 14,
			desc = string.format(L["Toggle %s display."], L["Power Infusion"]),
			get = function()
				return BigWigsCommonAuras.db.profile.powerinfusion
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.powerinfusion = v
			end,
		},
		["spacer3"] = {
			type = "header",
			name = " ",
			order = 15,
		},
		
		["orange"] = {
			type = "toggle",
			name = L["Orange"],
			order = 16,
			desc = string.format(L["Toggle %s display."], L["Orange"]),
			get = function()
				return BigWigsCommonAuras.db.profile.orange
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.orange = v
			end,
		},
		["portal"] = {
			type = "toggle",
			name = L["Portal"],
			order = 17,
			desc = string.format(L["Toggle %s display."], L["Portal"]),
			get = function()
				return BigWigsCommonAuras.db.profile.portal
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.portal = v
			end,
		},
		["shutdown"] = {
			type = "toggle",
			name = L["Shutdown"],
			order = 18,
			desc = string.format(L["Toggle %s display."], L["Shutdown"]),
			get = function()
				return BigWigsCommonAuras.db.profile.shutdown
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.shutdown = v
			end,
		},
		["soulwell"] = {
			type = "toggle",
			name = L["Soulwell"],
			order = 19,
			desc = string.format(L["Toggle %s display."], L["Soulwell"]),
			get = function()
				return BigWigsCommonAuras.db.profile.soulwell
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.soulwell = v
			end,
		},
		["wormhole"] = {
			type = "toggle",
			name = L["Wormhole"],
			order = 20,
			desc = string.format(L["Toggle %s display."], L["Wormhole"]),
			get = function()
				return BigWigsCommonAuras.db.profile.wormhole
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.wormhole = v
			end,
		},
		["warlockpet"] = {
			type = "toggle",
			name = L["Warlock Pet"],
			order = 21,
			desc = string.format(L["Toggle %s display."], L["Warlock Pet"]),
			get = function()
				return BigWigsCommonAuras.db.profile.warlockpet
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.warlockpet = v
			end,
		},
		["spacer4"] = {
			type = "header",
			name = " ",
			order = 21,
		},

		["broadcast"] = {
			type = "toggle",
			name = L["Broadcast"],
			order = 22,
			desc = L["Toggle broadcasting the messages to the raidwarning channel."],
			get = function()
				return BigWigsCommonAuras.db.profile.broadcast
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.broadcast = v
			end,
		},		
		["casounds"] = {
			type = "toggle",
			name = L["casounds"],
			order = 23,
			desc = L["Enable the Sounds for Common Auras Events"],
			get = function()
				return BigWigsCommonAuras.db.profile.casounds
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.casounds = v
			end,
		},
	}
}

local timer = {
	fearward = 30,
	laststand = 20,
	lifegivingGem = 20,
	challenging = 6,
	di = 60,
	portal = 60,
	wormhole = 8,
	orange = 60,
	soulwell = 60,
	barkskin = 12,
	berserk = 20,
	spiritlink = 20,
}
local icon = {
	fearward = L["iconPrefix"] .. "spell_holy_excorcism",
	shieldwall = L["iconPrefix"] .. "ability_warrior_shieldwall",
	laststand = L["iconPrefix"] .. "spell_holy_ashestoashes",
	lifegivingGem = L["iconPrefix"] .. "inv_misc_gem_pearl_05",
	challengingShout = L["iconPrefix"] .. "ability_bullrush",
	challengingRoar = L["iconPrefix"] .. "ability_druid_challangingroar",
	di = L["iconPrefix"] .. "spell_nature_timestop",
	wormhole = L["iconPrefix"] .. "Inv_Misc_EngGizmos_12",
	orange = L["iconPrefix"] .. "inv_misc_food_41",
	soulwell = L["iconPrefix"] .. "inv_stone_04",
	shutdown = L["iconPrefix"] .. "trade_engineering",
	barkskin = L["iconPrefix"] .. "Spell_Nature_StoneClawTotem",
	berserk = L["iconPrefix"] .. "Ability_Druid_Berserk",
	spiritlink = L["iconPrefix"] .. "Spell_Shaman_SpiritLink",
}
local color = {
	fearward = "Cyan",
	shieldwall = "Red",
	laststand = "Red",
	lifegivingGem = "Red",
	challengingShout = "Red",
	challengingRoar = "Red",
	di = "Blue",
	wormhole = "Cyan",
	orange = "Green",
	soulwell = "Green",
	shutdown = "White",
	barkskin = "Orange",
	berserk = "Red",
	spiritlink = "Cyan",
}

function BigWigsCommonAuras:OnEnable()
	--if UnitName("Player") == "Relar" then self:RegisterEvent("CHAT_MSG_SAY") end --Debug

	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")--trigger_wormhole, trigger_orange, trigger_soulwell
	self:RegisterEvent("CHAT_MSG_SYSTEM")--trigger_shutdown, trigger_restart
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF") -- For custom spells checking

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	self:RegisterEvent("UNIT_PET")

	-- For Scythe of Elune Party Timer
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_BUFF")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")
	self:RegisterEvent("CHAT_MSG_ADDON")
	
	-- For Scythe of Elune Party Timer
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_BUFF")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")
	self:RegisterEvent("CHAT_MSG_ADDON")
	-- DEBUG: Register all spell casts for debugging
	-- self:RegisterEvent("SPELLCAST_STOP")

	if UnitClass("player") == BC["Warrior"] or UnitClass("player") == BC["Druid"] or UnitClass("player") == BC["Shaman"] then
		self:RegisterEvent("SpellStatus_SpellCastInstant")

	elseif UnitClass("player") == BC["Priest"] then
		self:RegisterEvent("SpellStatus_SpellCastInstant")

	elseif UnitClass("player") == BC["Mage"] then
		if not spellStatus then
			spellStatus = AceLibrary("SpellStatus-1.0")
		end
		self:RegisterEvent("SpellStatus_SpellCastCastingFinish")
		self:RegisterEvent("SpellStatus_SpellCastFailure")
	end

	self:RegisterEvent("BigWigs_RecvSync")
	-- XXX Lets have a low throttle because you'll get 2 syncs from yourself, so
	-- it results in 2 messages.
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCAFW", .4) -- Fear Ward
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCASW", .4) -- Shield Wall
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCALS", .4) -- Last Stand
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCALG", .4) -- Last Stand
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCACS", .4) -- Challenging Shout
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCACR", .4) -- Challenging Roar
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCAP", .4) -- Portal
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCAWH", .4) -- Wormhole
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCAOR", .4) -- Orange
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCAWL", .4) -- Soulwell
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCABS", .4) -- Barkskin
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCAFR", .4) -- Berserk
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCASL", .4) -- Spirit Link
end

function BigWigsCommonAuras:SpellStatus_SpellCastInstant(sId, sName, sRank, sFullName, sCastTime)
	if sName == BS["Fear Ward"] or tonumber(sId) == 6346 then
		local targetName = nil
		if spellTarget then
			targetName = spellTarget
			spellCasting = nil
			spellTarget = nil
		else
			if UnitExists("target") and UnitIsPlayer("target") and not UnitIsEnemy("target", "player") then
				targetName = UnitName("target")
			else
				targetName = UnitName("player")
			end
		end
		self:TriggerEvent("BigWigs_SendSync", "BWCAFW " .. targetName)
	elseif sName == BS["Shield Wall"] then
		local shieldWallDuration
		local talentName, _, _, _, currentRank, _, _, _ = GetTalentInfo(3, 13)
		if currentRank == 0 then
			shieldWallDuration = 10
		elseif currentRank == 1 then
			shieldWallDuration = 13
		else
			shieldWallDuration = 15
		end
		self:TriggerEvent("BigWigs_SendSync", "BWCASW " .. tostring(shieldWallDuration))
	elseif sName == BS["Last Stand"] then
		self:TriggerEvent("BigWigs_SendSync", "BWCALS")
	elseif sName == BS["Challenging Shout"] then
		self:TriggerEvent("BigWigs_SendSync", "BWCACS")
	elseif sName == BS["Challenging Roar"] then
		self:TriggerEvent("BigWigs_SendSync", "BWCACR")
	end

	-- Debug / Backup Check
	-- DEFAULT_CHAT_FRAME:AddMessage("BWCA Debug: Cast " .. tostring(sName) .. " ID: " .. tostring(sId))

	local id = tonumber(sId)
	local playerClass = UnitClass("player")
	
	if playerClass == BC["Druid"] then
		if id == 51452 or (sName and string.find(sName, "树皮术")) or sName == "Barkskin" then -- Barkskin
			self:TriggerEvent("BigWigs_SendSync", "BWCABS " .. PROTOCOL_VERSION)
		elseif id == 45708 or (sName and string.find(sName, "狂暴") and not string.find(sName, "回复") and not string.find(sName, "血性")) or sName == "Berserk" then -- Berserk
			self:TriggerEvent("BigWigs_SendSync", "BWCAFR " .. PROTOCOL_VERSION)
		end
	elseif playerClass == BC["Shaman"] then
		if id == 51363 or id == 202 or (sName and string.find(sName, "灵魂连接")) or sName == "Spirit Link" then -- Spirit Link
			local targetName = nil
			if spellTarget then
				targetName = spellTarget
				spellCasting = nil
				spellTarget = nil
			else
				if UnitExists("target") and UnitIsPlayer("target") then
					targetName = UnitName("target")
				else
					targetName = UnitName("player")
				end
			end
			self:TriggerEvent("BigWigs_SendSync", "BWCASL " .. PROTOCOL_VERSION .. " " .. targetName)
		end
	end
end

function BigWigsCommonAuras:CHAT_MSG_SPELL_SELF_BUFF(msg)
	if string.find(msg, "艾露恩之镰") or string.find(msg, "The Scythe of Elune") or string.find(msg, "艾露恩的守护") or string.find(msg, "Protection of Elune") then
		local player = UnitName("player")
		SendAddonMessage("BigWigs", "BWCA_Scythe " .. player, "PARTY")
		self:CHAT_MSG_ADDON("BigWigs", "BWCA_Scythe " .. player, "PARTY", player) -- Local Loopback
	end

	local _, playerClass = UnitClass("player")
	if string.find(msg, L["trigger_barkskin"]) and playerClass == "DRUID" then
		self:TriggerEvent("BigWigs_SendSync", "BWCABS " .. PROTOCOL_VERSION)
	elseif string.find(msg, L["trigger_berserk"]) and playerClass == "DRUID" then
		self:TriggerEvent("BigWigs_SendSync", "BWCAFR " .. PROTOCOL_VERSION)
	elseif string.find(msg, L["trigger_spiritlink"]) and playerClass == "SHAMAN" then
	elseif string.find(msg, L["trigger_spiritlink"]) then
		local _, _, target = string.find(msg, L["trigger_spiritlink"])
		if target then
			self:TriggerEvent("BigWigs_SendSync", "BWCASL " .. PROTOCOL_VERSION .. " " .. target)
		end
	elseif string.find(msg, L["trigger_spiritlink_self"]) then
		local target = UnitName("player")
		self:TriggerEvent("BigWigs_SendSync", "BWCASL " .. PROTOCOL_VERSION .. " " .. target)
	elseif playerClass == "PRIEST" then
		if string.find(msg, L["trigger_fearward"]) then
			local _, _, target = string.find(msg, L["trigger_fearward"])
			if target then
				self:TriggerEvent("BigWigs_SendSync", "BWCAFW " .. target)
			end
		elseif string.find(msg, L["trigger_fearward_self"]) then
			self:TriggerEvent("BigWigs_SendSync", "BWCAFW " .. UnitName("player"))
		end
	end
end

function BigWigsCommonAuras:CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS(msg)
	if string.find(msg, BS["Gift of Life"]) and (UnitClass("Player") == BC["Warrior"] or UnitClass("Player") == BC["Druid"] or UnitClass("Player") == BC["Paladin"] ) then
		self:TriggerEvent("BigWigs_SendSync", "BWCALG")
	elseif string.find(msg, L["di_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "BWCADI")
	elseif string.find(msg, L["invis_trigger"]) and self.db.profile.invis then
		self:Bar(L["invis_trigger"], 18, "Spell_Magic_LesserInvisibilty", true)
	elseif string.find(msg, L["lesser_invis_trigger"]) and self.db.profile.invis then
		self:Bar(L["lesser_invis_trigger"], 15, "Spell_Magic_LesserInvisibilty", true)
	elseif string.find(msg, L["cloaking_invis_trigger"]) and self.db.profile.invis then
		self:Bar(L["cloaking_invis_trigger"], 10, "Spell_Magic_LesserInvisibilty", true)
	elseif string.find(msg, L["deepwoodpipe_trigger"]) and self.db.profile.deepwood then
		self:Bar(L["deepwoodpipe_trigger"], 30, "ability_stealth", true)
	elseif string.find(msg, L["lip_trigger"]) and self.db.profile.lip then
		self:Bar(L["lip_trigger"], 6, "inv_potion_62", true)
	elseif string.find(msg, L["bop_trigger"]) and self.db.profile.bop then
		self:Bar(L["Blessing of Protection"], 10, "Spell_Holy_SealOfProtection", true)
	elseif string.find(msg, L["powerinfusion_trigger"]) and self.db.profile.powerinfusion then
		self:Bar(L["powerinfusion_trigger"], 15, "Spell_Holy_PowerInfusion", true)
	end
end

function BigWigsCommonAuras:CHAT_MSG_SPELL_AURA_GONE_SELF(msg)
	if string.find(msg, L["di_fades"]) then
		self:RemoveBar(L["di_trigger"])
	elseif string.find(msg, L["invis_fades"]) then
		self:RemoveBar(L["invis_trigger"])
	elseif string.find(msg, L["lesser_invis_fades"]) then
		self:RemoveBar(L["lesser_invis_trigger"])
	elseif string.find(msg, L["cloaking_invis_fades"]) then
		self:RemoveBar(L["cloaking_invis_trigger"])
	elseif string.find(msg, L["deepwoodpipe_fades"]) then
		self:RemoveBar(L["deepwoodpipe_trigger"])
	elseif string.find(msg, L["lip_fades"]) then
		self:RemoveBar(L["lip_trigger"])
	elseif string.find(msg, L["bop_fades"]) then
		self:RemoveBar(L["Blessing of Protection"])
	elseif string.find(msg, L["powerinfusion_fades"]) then
		self:RemoveBar(L["powerinfusion_trigger"])
	end
end

function BigWigsCommonAuras:SpellStatus_SpellCastCastingFinish(sId, sName, sRank, sFullName, sCastTime)
	if not string.find(sName, L["Portal"]) then
		return
	end
	local name = BS:HasReverseTranslation(sName) and BS:GetReverseTranslation(sName) or sName
	self:ScheduleEvent("bwcaspellcast", self.SpellCast, 0.3, self, name)
end

function BigWigsCommonAuras:SpellStatus_SpellCastFailure(sId, sName, sRank, sFullName, isActiveSpell, UIEM_Message, CMSFLP_SpellName, CMSFLP_Message)
	-- do nothing if we are casting a spell but the error doesn't consern that spell, thanks Iceroth.
	if (spellStatus:IsCastingOrChanneling() and not spellStatus:IsActiveSpell(sId, sName)) then
		return
	end
	if self:IsEventScheduled("bwcaspellcast") then
		self:CancelScheduledEvent("bwcaspellcast")
	end
end

function BigWigsCommonAuras:SpellCast(sName)
	self:TriggerEvent("BigWigs_SendSync", "BWCAP " .. sName)
end

function BigWigsCommonAuras:CHAT_MSG_MONSTER_EMOTE(msg, sender)
	if string.find(msg, L["trigger_wormhole"]) then

		--Debug
		if UnitName("Player") == "Relar" or UnitName("Player") == "Dreadsome" then
			DEFAULT_CHAT_FRAME:AddMessage("发送者： " .. sender)
		end

		whZone = nil
		if GetNumRaidMembers() > 0 then
			for i = 1, GetNumRaidMembers() do
				if UnitName("raid" .. i) == sender then
					if UnitFactionGroup("raid" .. i) == L["Alliance"] then
						whZone = "Stormwind"
					elseif UnitFactionGroup("raid" .. i) == L["Horde"] then
						whZone = "Orgrimmar"
					else
						whZone = sender
					end
				end
			end
		elseif GetNumPartyMembers() > 0 then
			for i = 1, GetNumPartyMembers() do
				if UnitName("party" .. i) == sender then
					if UnitFactionGroup("party" .. i) == L["Alliance"] then
						whZone = "Stormwind"
					elseif UnitFactionGroup("party" .. i) == L["Horde"] then
						whZone = "Orgrimmar"
					else
						whZone = sender
					end
				end
			end
		else
			whZone = sender
		end

		if whZone ~= nil then
			self:TriggerEvent("BigWigs_SendSync", "BWCAWH " .. whZone)
		end


	elseif string.find(msg, L["trigger_orange"]) then
		self:TriggerEvent("BigWigs_SendSync", "BWCAOR")

	elseif string.find(msg, L["trigger_soulwell"]) then
		self:TriggerEvent("BigWigs_SendSync", "BWCAWL")
	end
end

function BigWigsCommonAuras:CHAT_MSG_SYSTEM(msg)
	if string.find(msg, L["trigger_restartMinSec"]) or string.find(msg, L["trigger_shutdownMinSec"]) then
		local _, _, minutes, seconds = string.find(msg, L["inminutesseconds"])
		timeToShutdown = tonumber(minutes) * 60 + tonumber(seconds)

		if self.db.profile.shutdown then
			if timeToShutdown > 9 then
				self:TriggerEvent("BigWigs_StopBar", self, L["bar_shutDown"])
				self:TriggerEvent("BigWigs_StartBar", self, L["bar_shutDown"], timeToShutdown, icon.shutdown, true, color.shutdown)
			end

			if not shutdownBigWarning then
				if self.db.profile.casounds then self:TriggerEvent("BigWigs_Sound", "Beware") end
				self:TriggerEvent("BigWigs_ShowWarningSign", icon.shutdown, 2)
				shutdownBigWarning = true
			end
		end


	elseif string.find(msg, L["trigger_restart"]) or string.find(msg, L["trigger_shutdown"]) then
		local _, _, digits, minSec = string.find(msg, L["in_plus"])
		if string.find(minSec, L["inute"]) then
			timeToShutdown = tonumber(digits) * 60
		else
			timeToShutdown = tonumber(digits)
		end

		if self.db.profile.shutdown then
			if timeToShutdown > 9 then
				self:TriggerEvent("BigWigs_StopBar", self, L["bar_shutDown"])
				self:TriggerEvent("BigWigs_StartBar", self, L["bar_shutDown"], timeToShutdown, icon.shutdown, true, color.shutdown)
			end

			if not shutdownBigWarning then
				if self.db.profile.casounds then self:TriggerEvent("BigWigs_Sound", "Beware") end
				self:TriggerEvent("BigWigs_ShowWarningSign", icon.shutdown, 2)
				shutdownBigWarning = true
			end
		end
	end
end

--Debug
--function BigWigsCommonAuras:CHAT_MSG_SAY(msg)
--end



function BigWigsCommonAuras:BigWigs_RecvSync(sync, rest, nick)
	if not nick then
		nick = UnitName("player")
	end

	if self.db.profile.fearward and sync == "BWCAFW" and rest then
		self:TriggerEvent("BigWigs_Message", nick .. L["msg_fearward"] .. rest, "Positive", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_fearward"], timer.fearward, icon.fearward, true, color.fearward)


	elseif self.db.profile.shieldwall and sync == "BWCASW" then
		local swTime = tonumber(rest)
		if not swTime then
			swTime = 10
		end -- If the tank uses an old BWCA, just assume 10 seconds.
		self:TriggerEvent("BigWigs_Message", nick .. L["msg_shieldwall"], "Urgent", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_shieldwall"], swTime, icon.shieldwall, true, color.shieldwall)
		self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_shieldwall"], function(name, button, extra)
			TargetByName(extra, true)
		end, nick)


	elseif self.db.profile.laststand and sync == "BWCALS" then
		self:TriggerEvent("BigWigs_Message", nick .. L["msg_laststand"], "Urgent", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_laststand"], timer.laststand, icon.laststand, true, color.laststand)
		self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_laststand"], function(name, button, extra)
			TargetByName(extra, true)
		end, nick)


	elseif self.db.profile.lifegivinggem and sync == "BWCALG" then
		self:TriggerEvent("BigWigs_Message", nick .. L["msg_lifegivingGem"], "Urgent", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_lifegivingGem"], timer.lifegivingGem, icon.lifegivingGem, true, color.lifegivingGem)
		self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_lifegivingGem"], function(name, button, extra)
			TargetByName(extra, true)
		end, nick)


	elseif self.db.profile.challengingshout and sync == "BWCACS" then
		self:TriggerEvent("BigWigs_Message", nick .. L["msg_challengingShout"], "Urgent", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_challengingShout"], timer.challenging, icon.challengingShout, true, color.challengingShout)
		self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_challengingShout"], function(name, button, extra)
			TargetByName(extra, true)
		end, nick)


	elseif self.db.profile.challengingroar and sync == "BWCACR" then
		self:TriggerEvent("BigWigs_Message", nick .. L["msg_challengingRoar"], "Urgent", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_challengingRoar"], timer.challenging, icon.challengingRoar, true, color.challengingRoar)
		self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_challengingRoar"], function(name, button, extra)
			TargetByName(extra, true)
		end, nick)

	elseif self.db.profile.di and sync == "BWCADI" then
		self:TriggerEvent("BigWigs_Message", L["msg_divineIntervention"] .. nick, "Urgent", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_divineIntervention"], timer.di, icon.di, true, color.di)
		self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_divineIntervention"], function(name, button, extra)
			TargetByName(extra, true)
		end, nick)

	elseif self.db.profile.portal and sync == "BWCAP" and rest then
		rest = BS:HasTranslation(rest) and BS:GetTranslation(rest) or rest
		local _, _, zone = string.find(rest, L["portal_regexp"])
		if zone then
			if zone == "Orgrimmar" or zone == "Thunder Bluff" or zone == "Undercity" or zone == "Stonard" then
				portalColor = "Red"
				portalText = "--部落-- 传送门到 "
			elseif zone == "Stormwind" or zone == "Ironforge" or zone == "Darnassus" or zone == "Theramore" then
				portalColor = "Blue"
				portalText = "--联盟-- 传送门到 "
			elseif zone == "Karazhan" or zone then
				portalColor = "Green"
				portalText = "--中立-- 传送门到 "
			end
			self:TriggerEvent("BigWigs_Message", portalText .. zone, "Attention", false, nil, false)
			if zone == "Stonard" then
				self:TriggerEvent("BigWigs_StartBar", self, rest, timer.portal, L["iconPrefix"] .. "Spell_Arcane_PortalStonard", true, portalColor)
			elseif zone == "Theramore" then
				self:TriggerEvent("BigWigs_StartBar", self, rest, timer.portal, L["iconPrefix"] .. "Spell_Arcane_PortalTheramore", true, portalColor)
			elseif zone == "Karazhan" then
				self:TriggerEvent("BigWigs_StartBar", self, rest, timer.portal, L["iconPrefix"] .. "Spell_Arcane_PortalUndercity", true, portalColor)
			else
				self:TriggerEvent("BigWigs_StartBar", self, rest, timer.portal, BS:GetSpellIcon(rest), true, portalColor)
			end
		end


	elseif self.db.profile.wormhole and sync == "BWCAWH" and rest then
		if rest == "Orgrimmar" then
			whColor = "Red"
			whText = "--部落-- 虫洞到奥格瑞玛"
		elseif rest == "Stormwind" then
			whColor = "Blue"
			whText = "--联盟-- 虫洞到暴风城"
		end
		self:TriggerEvent("BigWigs_Message", whText, "Attention", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, rest .. L["bar_wormhole"], timer.wormhole, icon.wormhole, true, whColor)
		if self.db.profile.casounds then self:TriggerEvent("BigWigs_Sound", "BikeHorn") end
		self:TriggerEvent("BigWigs_ShowWarningSign", icon.wormhole, 2)


	elseif self.db.profile.orange and sync == "BWCAOR" then
		self:TriggerEvent("BigWigs_Message", L["msg_orange"], "Positive", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, L["bar_orange"], timer.orange, icon.orange, true, color.orange)
		if self.db.profile.casounds then self:TriggerEvent("BigWigs_Sound", "BikeHorn") end
		self:TriggerEvent("BigWigs_ShowWarningSign", icon.orange, 5)


	elseif self.db.profile.soulwell and sync == "BWCAWL" then
		self:TriggerEvent("BigWigs_Message", L["msg_soulwell"], "Positive", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, L["bar_soulwell"], timer.soulwell, icon.soulwell, true, color.soulwell)
		if self.db.profile.casounds then self:TriggerEvent("BigWigs_Sound", "BikeHorn") end
		self:TriggerEvent("BigWigs_ShowWarningSign", icon.soulwell, 5)

	elseif self.db.profile.barkskin and sync == "BWCABS" then
		if self:VerifyVersion(rest) then
			self:TriggerEvent("BigWigs_Message", nick .. L["msg_barkskin"], "Urgent", false, nil, false)
			self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_barkskin"], timer.barkskin, icon.barkskin, true, color.barkskin)
			self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_barkskin"], function(name, button, extra)
				TargetByName(extra, true)
			end, nick)
		end

	elseif self.db.profile.berserk and sync == "BWCAFR" then
		if self:VerifyVersion(rest) then
			self:TriggerEvent("BigWigs_Message", nick .. L["msg_berserk"], "Urgent", false, nil, false)
			self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_berserk"], timer.berserk, icon.berserk, true, color.berserk)
			self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_berserk"], function(name, button, extra)
				TargetByName(extra, true)
			end, nick)
		end

	elseif self.db.profile.spiritlink and sync == "BWCASL" and rest then
		local ver, target = string.match(rest, "^(%S+)%s+(.*)$")
		if self:VerifyVersion(ver) and target then
			self:TriggerEvent("BigWigs_Message", nick .. L["msg_spiritlink"] .. target, "Urgent", false, nil, false)
			self:TriggerEvent("BigWigs_StartBar", self, target .. L["bar_spiritlink"], timer.spiritlink, icon.spiritlink, true, color.spiritlink)
			self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_spiritlink"], function(name, button, extra)
				TargetByName(extra, true)
			end, nick)
		end
	end
end

function BigWigsCommonAuras:VerifyVersion(ver)
	if not ver then return false end
	local major, minor, patch = string.match(ver, "^(%d+)%.(%d+)%.(%d+)$")
	if not major then return false end

	-- Protocol baseline: 2.16.1
	-- Accept any version >= 2.16.1
	if tonumber(major) > 2 then return true end
	if tonumber(major) == 2 then
		if tonumber(minor) > 16 then return true end
		if tonumber(minor) == 16 then
			if tonumber(patch) >= 1 then return true end
		end
	end
	return false
end

function BigWigsCommonAuras:CheckWarlockPet()
	if not self.db.profile.warlockpet then return end
	if not UnitExists("pet") then return end
	local name = UnitName("pet")
	local family = UnitCreatureFamily("pet")
	
	-- Fallback to name checking if family is nil (common on some private servers for custom pets)
	-- Also check English names just in case
	
	if (family == "地狱火") or (name == "地狱火") or (name == "Infernal") then
		self:TriggerEvent("BigWigs_StartBar", self, "地狱火叛变", 180, "Interface\\Icons\\Spell_Shadow_SummonInfernal")
	elseif (family == "恶魔卫士") or (name == "恶魔卫士") or (name == "Felguard") then
		self:TriggerEvent("BigWigs_StartBar", self, "恶魔卫士叛变", 180, "Interface\\Icons\\Spell_Shadow_SummonFelGuard")
	elseif (family == "末日守卫") or (name == "末日守卫") or (name == "Doomguard") then
		self:TriggerEvent("BigWigs_StartBar", self, "末日守卫叛变", 180, "Interface\\Icons\\Spell_Shadow_AntiMagicShell")
	end
end

function BigWigsCommonAuras:UNIT_PET(arg1)
	if arg1 ~= "player" then return end
	self:ScheduleEvent("BigWigsCommonAuras_CheckWarlockPet", self.CheckWarlockPet, 0.5, self)
end

------------------------------
--      Scythe of Elune     --
------------------------------

function BigWigsCommonAuras:CHAT_MSG_SPELL_PARTY_BUFF(msg)
	local _, _, player, spell = string.find(msg, "^(.+) casts (.+).$") 
    -- 英文: X casts Y.
    -- 中文: X施放了Y。
    if not player then
        _, _, player, spell = string.find(msg, "^(.+)施放了(.+)。$")
    end
    
	if spell and (string.find(spell, "艾露恩之镰") or string.find(spell, "The Scythe of Elune") or string.find(spell, "艾露恩的守护") or string.find(spell, "Protection of Elune")) then
		-- Only trigger locally, do NOT sync (Caster will sync)
		self:CHAT_MSG_ADDON("BigWigs", "BWCA_Scythe " .. player, "PARTY", player)
	end
end

function BigWigsCommonAuras:CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS(msg)
    local _, _, player, spell = string.find(msg, "^(.+) gains (.+).$")
    if not player then
         _, _, player, spell = string.find(msg, "^(.+)获得了(.+)。$")
    end
    
    if spell and (string.find(spell, "艾露恩之镰") or string.find(spell, "The Scythe of Elune") or string.find(spell, "艾露恩的守护") or string.find(spell, "Protection of Elune")) then
		-- Only trigger locally, do NOT sync
		self:CHAT_MSG_ADDON("BigWigs", "BWCA_Scythe " .. player, "PARTY", player)
	end
end

function BigWigsCommonAuras:CHAT_MSG_ADDON(prefix, message, type, sender)
	if prefix ~= "BigWigs" or type ~= "PARTY" then return end
	
    local _, _, sync, rest = string.find(message, "(%S+)%s*(.*)$")
	if not sync then return end

	if sync == "BWCA_Scythe" and rest then
        -- 触发计时条: rest 是玩家名字
        local player = rest
        
        -- Simple throttling to prevent double bars from Local + Sync both firing
        if not self.scytheThrottle then self.scytheThrottle = {} end
        if self.scytheThrottle[player] and GetTime() < self.scytheThrottle[player] then return end
        self.scytheThrottle[player] = GetTime() + 2
        
        local icon = "Interface\\Icons\\INV_Staff_05" -- Default fallback
        local _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(55505)
        if itemIcon then icon = itemIcon end
        
        local barName = player .. L["bar_scythe"]
        local registered, time, elapsed, running = BigWigsBars:GetBarStatus(self, barName)
        if registered and running and (time - elapsed) > 10 then return end

        self:TriggerEvent("BigWigs_StartBar", self, barName, 60, icon, true, "Cyan")
        self:TriggerEvent("BigWigs_Message", player .. L["msg_scythe"], "Positive")
	end
end

