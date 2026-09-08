--[[
 Decursive (v 1.9.8) 魔兽世界用户界面插件
 版权所有 (C) 2006 Archarodim ( http://www.2072productions.com/?to=decursive-continued.txt )
 这是Quu原始Decursive (v1.9.4) 的延续版本
 Decursive 1.9.4 属于公共领域 ( www.quutar.com )
 
 许可协议：
	本程序是自由软件；您可以重新分发它和/或
	根据自由软件基金会发布的GNU通用公共许可证的条款修改它；版本2
	或（根据您的选择）任何更高版本。

	本程序的分发是希望它有用，但
	无任何担保；甚至没有适销性或特定用途适用性的默示担保。请参阅
	GNU通用公共许可证以获取更多详细信息。

	您应该已经收到了一份GNU通用公共许可证的副本
	随本程序一起提供；如果没有，请写信给自由软件基金会，地址：
	美国马萨诸塞州波士顿市富兰克林街51号5楼，邮编02110-1301。
--]]

-------------------------------------------------------------------------------
-- the constants for the mod (non localized)
-------------------------------------------------------------------------------
DCR_MACRO_COMMAND  = "/decursive";
DCR_MACRO_SHOW     = "/dcrshow";
DCR_MACRO_HIDE     = "/dcrhide";
DCR_MACRO_OPTION   = "/dcroption";
DCR_MACRO_RESET    = "/dcrreset";

DCR_MACRO_PRADD    = "/dcrpradd";
DCR_MACRO_PRCLEAR  = "/dcrprclear";
DCR_MACRO_PRLIST   = "/dcrprlist";
DCR_MACRO_PRSHOW   = "/dcrprshow";

DCR_MACRO_SKADD    = "/dcrskadd";
DCR_MACRO_SKCLEAR  = "/dcrskclear";
DCR_MACRO_SKLIST   = "/dcrsklist";
DCR_MACRO_SKSHOW   = "/dcrskshow";
DCR_MACRO_DEBUG	   = "/dcrdebug";

-- DO NOT TRANSLATE, THOSE ARE ALWAYS ENGLISH
DCR_CLASS_DRUID   = 'DRUID';
DCR_CLASS_HUNTER  = 'HUNTER';
DCR_CLASS_MAGE    = 'MAGE';
DCR_CLASS_PALADIN = 'PALADIN';
DCR_CLASS_PRIEST  = 'PRIEST';
DCR_CLASS_ROGUE   = 'ROGUE';
DCR_CLASS_SHAMAN  = 'SHAMAN';
DCR_CLASS_WARLOCK = 'WARLOCK';
DCR_CLASS_WARRIOR = 'WARRIOR';

DCR_DISEASE = 'Disease';
DCR_MAGIC   = 'Magic';
DCR_POISON  = 'Poison';
DCR_CURSE   = 'Curse';
DCR_CHARMED = 'Charm';

-------------------------------------------------------------------------------
-- Simplified Chinese localization
-------------------------------------------------------------------------------
if ( GetLocale() == "zhCN" ) then
DCR_VERSION_STRING = "一键驱散 1.9.9";
BINDING_HEADER_DECURSIVE = "一键驱散";

--start added in Rc4
DCR_ALLIANCE_NAME = '联盟';

DCR_LOC_CLASS_DRUID   = '德鲁伊';
DCR_LOC_CLASS_HUNTER  = '猎人';
DCR_LOC_CLASS_MAGE    = '法师';
DCR_LOC_CLASS_PALADIN = '圣骑士';
DCR_LOC_CLASS_PRIEST  = '牧师';
DCR_LOC_CLASS_ROGUE   = '盗贼';
DCR_LOC_CLASS_SHAMAN  = '萨满祭司';
DCR_LOC_CLASS_WARLOCK = '术士';
DCR_LOC_CLASS_WARRIOR = '战士';

DCR_STR_OTHER	    = '其它';
DCR_STR_ANCHOR	    = '定位器';
DCR_STR_OPTIONS	    = '选项设置';
DCR_STR_CLOSE	    = '关闭';
DCR_STR_DCR_PRIO    = '优先列表';
DCR_STR_DCR_SKIP    = '忽略列表';
DCR_STR_QUICK_POP   = '快速添加器';
DCR_STR_POP	    	= '快速添加列表';
DCR_STR_GROUP	    = '小队';

DCR_STR_NOMANA	    = '法力不足。';
DCR_STR_UNUSABLE    = '暂时不能净化。';
DCR_STR_NEED_CURE_ACTION_IN_BARS = 'Decursive在你的动作条上找不到任何可用的净化法术图标。Decursive需要它来检查施法距离。';


DCR_UP		    = '上移';
DCR_DOWN	    = '下移';

DCR_PRIORITY_SHOW   = '优';
DCR_POPULATE	    = '添';
DCR_SKIP_SHOW	    = '忽';
DCR_ANCHOR_SHOW	    = '锚';
DCR_OPTION_SHOW	    = '设';
DCR_CLEAR_PRIO	    = '清';
DCR_CLEAR_SKIP	    = '清';


--end added in Rc4
DCR_LOC_AF_TYPE = {};
DCR_LOC_AF_TYPE [DCR_DISEASE] = '疾病';
DCR_LOC_AF_TYPE [DCR_MAGIC]   = '魔法';
DCR_LOC_AF_TYPE [DCR_POISON]  = '中毒';
DCR_LOC_AF_TYPE [DCR_CURSE]   = '诅咒';
DCR_LOC_AF_TYPE [DCR_CHARMED] = '诱惑';


DCR_PET_FELHUNTER = "地狱猎犬";
DCR_PET_DOOMGUARD = "末日守卫";
DCR_PET_FEL_CAST  = "吞噬魔法";
DCR_PET_DOOM_CAST = "驱散魔法";


DCR_SPELL_CLEANSE_POISON_TOTEM = "清毒图腾" -- 用于驱散中毒
DCR_SPELL_CLEANSE_DISEASE_TOTEM = "祛病图腾" -- 用于驱散疾病
DCR_SPELL_CURE_DISEASE        = '祛病术';
DCR_SPELL_ABOLISH_DISEASE     = '驱除疾病';
DCR_SPELL_PURIFY              = '纯净术';
DCR_SPELL_CLEANSE             = '清洁术';
DCR_SPELL_DISPELL_MAGIC       = '驱散魔法';
DCR_SPELL_CURE_POISON         = '消毒术';
DCR_SPELL_ABOLISH_POISON      = '驱毒术';
DCR_SPELL_REMOVE_LESSER_CURSE = '解除次级诅咒';
DCR_SPELL_REMOVE_CURSE        = '解除诅咒';
DCR_SPELL_PURGE               = '净化术';
DCR_SPELL_NO_RANK             = '';
DCR_SPELL_RANK_1              = '等级 1';
DCR_SPELL_RANK_2              = '等级 2';

BINDING_NAME_DCRCLEAN   = "净化队伍";
BINDING_NAME_DCRSHOW    = "显示/隐藏工具条";
BINDING_NAME_DCROPTION  = "显示/隐藏选项设置界面";

BINDING_NAME_DCRPRADD     = "将目标添加到优先列表";
BINDING_NAME_DCRPRCLEAR   = "清空优先列表";
BINDING_NAME_DCRPRLIST    = "在聊天窗口显示优先列表内容";
BINDING_NAME_DCRPRSHOW    = "显示/隐藏优先列表界面";

BINDING_NAME_DCRSKADD   = "将目标添加到忽略列表";
BINDING_NAME_DCRSKCLEAR = "清空忽略列表";
BINDING_NAME_DCRSKLIST  = "在聊天窗口显示忽略列表内容";
BINDING_NAME_DCRSKSHOW  = "显示/隐藏忽略列表界面";


DCR_DISABLE_AUTOSELFCAST = "Decursive检测到选项设置“%s”已启用。\n\n此选项激活时，Decursive将不能正常工作。\n\n你想要禁用这个选项设置吗？";

DCR_PRIORITY_LIST  = "设置优先列表";
DCR_SKIP_LIST_STR  = "设置忽略列表";
DCR_SKIP_OPT_STR   = "选项设置";
DCR_POPULATE_LIST  = "列表快速添加器";
DCR_RREMOVE_ID     = "移除此玩家";
DCR_HIDE_MAIN      = "隐藏工具条";
DCR_SHOW_MSG	   = "如果你想要显示Decursive的工具条，输入/dcrshow";
DCR_IS_HERE_MSG	   = "Decursive初始化完毕。";

DCR_PRINT_CHATFRAME = "在聊天窗口显示信息";
DCR_PRINT_CUSTOM    = "在游戏画面中显示信息";
DCR_PRINT_ERRORS    = "显示错误信息";

DCR_SHOW_TOOLTIP    = "在实时列表中显示浮动提示";
DCR_REVERSE_LIVELIST= "反向显示实时列表";
DCR_TIE_LIVELIST    = "根据工具条是否可见显示/隐藏实时列表";
DCR_HIDE_LIVELIST   = "隐藏实时列表";

DCR_MUTAT_INJ       = "治愈变异注射";
DCR_WYV_STING		= "消除翼龙钉刺";
DCR_PRIVATE_WARNING	= "范围私密警告";
DCR_PUBLIC_MESSAGE	= "范围喊话提醒";
DCR_LEADER_MODE 	 = "团长模式";
DCR_LEADER_MONITOR_MAGIC = "监控魔法效果";
DCR_LEADER_MONITOR_DISEASE = "监控疾病效果";
DCR_LEADER_MONITOR_POISON = "监控中毒效果";
DCR_LEADER_MONITOR_CURSE = "监控诅咒效果";
DCR_LEADER_MODE_DESC = "在团长模式下，只显示负面效果而不进行驱散";
DCR_RANGE_CHECK    = "根据距离淡化驱散按钮";

DCR_AMOUNT_AFFLIC   = "实时列表显示人数：";
DCR_BLACK_LENGTH    = "黑名单持续时间(秒)：";
DCR_SCAN_LENGTH     = "实时检测时间间隔(秒)：";
DCR_ABOLISH_CHECK   = "在施法前检查是否需要净化";
DCR_BEST_SPELL      = "总是使用最高等级法术进行净化";
DCR_RANDOM_ORDER    = "随机净化玩家";
DCR_CURE_PETS       = "检测并净化宠物";
DCR_IGNORE_STEALTH  = "忽略潜行的玩家";
DCR_PLAY_SOUND	    = "有玩家需要净化时播放声音提示";
DCR_ANCHOR          = "Decursive文字定位";
DCR_CHECK_RANGE     = "在净化前检查是否超出施法距离";
DCR_DONOT_BL_PRIO   = "不将优先列表中的玩家加入黑名单";
DCR_CHOOSE_CURE	    = "净化类型选择";


-- $s is spell name
-- $a is affliction name/type
-- $t is target name
DCR_DISPELL_ENEMY    = "对敌方施放$s。";
DCR_NOT_CLEANED      = "没有任何效果被驱除。";
DCR_CLEAN_STRING     = "驱除$t受到的$a效果。";
DCR_SPELL_FOUND      = "找到$s法术。";
DCR_NO_SPELLS        = "没有找到驱除不良效果的法术。";
DCR_NO_SPELLS_RDY    = "驱除不良效果的法术尚未准备好。";
DCR_OUT_OF_RANGE     = "$t距离太远。$a效果无法被驱除。";
DCR_IGNORE_STRING    = "忽略$t受到的$a效果。";



-- 不可见效果列表：用于定义需要忽略的效果
DCR_INVISIBLE_LIST = {
	["潜伏"] = true,
	["潜行"] = true,
	["影遁"] = true,
}

-- 导致目标被忽略
-- 不要用此列表避免驱散，请使用DCR_AVOID_LIST
DCR_IGNORELIST = {
	["放逐术"] = true,
	["相位变换"] = true,
	["外域的恐惧"] = true,
	["元素诅咒"] = true,
};

-- 你不想驱散的法术
 -- 不要用此列表忽略显示减益效果，请使用DCR_SKIP_LIST
DCR_AVOID_LIST = {
	["不稳定的法力"] = true,
	["相位转换"] = true,
    ["外域的恐惧"] = true,
    ["元素诅咒"] = true,
}

-- 忽略此效果，它仍可能被意外驱散
 -- 如果要避免驱散，请使用DCR_AVOID_LIST
DCR_SKIP_LIST = {
	["无梦睡眠"] = true,
	["强效昏睡"] = true,
	["心灵视界"] = true,
	["变异注射"] = true,
	["熔岩镣铐"] = true,
	["金度的欺骗"] = true,
	["鲁莽诅咒"] = true,
	["摩尔达的勇气"] = true,
	["芬古斯的狂暴"] = true,
	["斯里基克的机智"] = true,
	["翼龙钉刺"] = true,
	["雷霆之怒"] = true,
	["风歌夜曲"] = true,
	["梦境"] = true,
	["噩梦的召唤"] = true,
	["毒蘑菇"] = true,
	["冰柱"] = true,
	["吸血光环"] = true,
	["外域的恐惧"] = true,
	["相位转换"] = true,

	
};

-- ignore the effect bassed on the class
DCR_SKIP_BY_CLASS_LIST = {
    ["ALL"] = {
	["不稳定的法力"] = true,
	["相位转换"] = true,
	["元素诅咒"] = true,
	["外域的恐惧"] = true
    },
    [DCR_CLASS_WARRIOR] = {
	["上古狂乱"] = true,
	["点燃法力"] = true,
	["污浊之魂"] = true,
	["魔鳞诅咒"] = true
    },
    [DCR_CLASS_ROGUE] = {
	["沉默"] = true,
	["上古狂乱"] = true,
	["点燃法力"] = true,
	["污浊之魂"] = true,
	["烟雾弹"] = true,
	["往日的尖啸"] = true,
	["魔鳞诅咒"] = true
    },
	[DCR_CLASS_WARLOCK] = {
    ["裂隙纠缠"] = true
    }
};
--[[

列表名称 作用对象 效果 
DCR_IGNORELIST Debuff名称 忽略特定的debuff，不驱散。
DCR_SKIP_LIST 玩家名称 跳过特定的玩家，不驱散其身上的任何debuff。
DCR_SKIP_BY_CLASS_LIST 职业 跳过特定职业的所有玩家。
DCR_INVISIBLE_LIST 特殊效果/光环 内部追踪，可能不显示，但插件会感知。
DCR_AVOID_LIST Debuff名称 极力避免驱散的debuff。
]]
end