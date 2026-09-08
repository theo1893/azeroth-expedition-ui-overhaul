-- 版本信息
DEX_Version = "|cffffff00伤害显示器 ver 1.0 输入/dex查看选项|r";

-- 颜色模式下拉菜单选项
DEXOptionsDropDown = {"单色", "双色", "渐变色", "伤害类型"};

-- 未命中/特殊事件文本
DEX_TXT_IMM = "免疫";
DEX_TXT_PARRY = "招架";
DEX_TXT_DODGE = "闪躲";
DEX_TXT_MISS = "未击中";
DEX_TXT_ABSORB = "吸收";
DEX_TXT_RESIST = "抵抗";
DEX_TXT_BLOCK = "格挡";
DEX_TXT_DEFLECTED = "偏斜";
DEX_TXT_EVADE = "闪避";
DEX_TXT_SHIELD = "反射";
DEX_TXT_CRIT = "致命! ";

-- 按钮文本
DEX_BUTTON_RESET_LABEL = "重置";
DEX_MAIN_OPTION = "增强伤害显示器";
DEX_BUTTON_RESET_TIP = "恢复默认设置";

-- 错误消息
DEX_LANG_ERROR_NAMEPOWER_LOW = "Nampower 版本过低，请更新至 v4.0+ 以确保所有事件正常工作。";
DEX_LANG_ERROR_NO_NAMEPOWER = "|cffff0000DamageEx需要Nampower才能正常工作！|r";

-- 调试消息
DEX_LANG_DEBUG = {
    TITLE = "|cffff0000[DamageEx 调试]|r",
    COLOR_TITLE = "|cffff0000[DamageEx 颜色测试]|r",
    FONT_TITLE = "|cffff0000[DamageEx 字体测试]|r",
    FONT_SIZE = "当前字体大小: %d",
    CRIT_MULTIPLIER = "暴击放大倍数: %s",
    EXPECTED_CRIT_SIZE = "预期暴击大小: %d",
    CRIT_TEST_DONE = "|cff00ff00暴击测试完成！|r",
    NORMAL_TEST_DONE = "|cff00ff00普通伤害测试完成！|r",
    COLOR_TEST_DONE = "|cff00ff00颜色测试完成！查看渐变效果|r",
    COLOR_MODE = "当前颜色模式: %s",
    DEBUG_MODE_ON = "|cff00ff00[DamageEx]|r 调试模式已开启",
    DEBUG_MODE_OFF = "|cffff0000[DamageEx]|r 调试模式已关闭",
    FONT_NUMBER = "当前字体编号: %d",
    FONT_PATH = "当前字体路径: %s",
    FONT_LIST = "字体列表:",
    FONT_ENTRY = "字体%d: %s",
    START_TEST = "开始测试...",
    TEST_FONT = ">> 测试字体%d (%s)",
    FONT_TEST_DONE = "字体测试完成！已恢复到字体%d",
    OBSERVE_NOTE = "请观察屏幕上的三个数字 '88888' 是否有明显差异",
    SEE_NOTE = "如果看不到数字，请在游戏中攻击怪物观察伤害数字的字体变化",
    HELP_TITLE = "|cffff0000[DamageEx 测试命令]|r",
    HELP_CRIT = "|cff00ff00/dextest crit|r - 测试暴击效果",
    HELP_NORMAL = "|cff00ff00/dextest normal|r - 测试普通伤害",
    HELP_COLOR = "|cff00ff00/dextest color|r - 测试颜色渐变",
    HELP_FONT = "|cff00ff00/dextest font|r - 测试三种字体",
    HELP_DEBUG = "|cff00ff00/dextest debug|r - 开关调试模式",
};

-- 调试命令参数
DEX_LANG_COMMANDS = {
    CRIT = "crit",
    CRIT_ZH = "暴击",
    NORMAL = "normal",
    NORMAL_ZH = "普通",
    COLOR = "color",
    COLOR_ZH = "颜色",
    DEBUG = "debug",
    DEBUG_ZH = "调试",
    FONT = "font",
    FONT_ZH = "字体",
};

-- AOE 技能名称（按职业）
DEX_LANG_AOE_SKILLS = {
    WARRIOR = { "雷霆一击", "顺劈斩", "旋风斩" },
    ROGUE = { "剑刃乱舞" },
    PALADIN = { "奉献" },
    HUNTER = { "爆炸陷阱效果", "多重射击", "乱射" },
    WARLOCK = { "火焰之雨", "地狱烈焰" },
    MAGE = { "冰锥术", "魔爆术", "冰霜新星", "烈焰风暴", "奥术爆炸", "冲击波", "暴风雪" },
    PRIEST = { "神圣新星", "吸血鬼的拥抱" },
    DRUID = { "宁静", "飓风" },
    SHAMAN = { "火焰新星图腾", "熔岩图腾" },
};

-- 小地图按钮提示
DEX_LANG_MINIMAP_TOOLTIP = {
    TITLE = "DamageEx",
    LEFT_CLICK = "左键: 打开设置",
    RIGHT_CLICK = "右键: 启用/禁用",
    DRAG = "拖动: 移动按钮",
    STATUS_ENABLED = "状态: |cff00ff00已启用|r",
    STATUS_DISABLED = "状态: |cffff0000已禁用|r",
    DEX_ENABLE = "DamageEx 已启用",
    DEX_DISABLE = "DamageEx 已禁用",    
};

-- 复选框标题和提示
DEX_LANG_CHECKBOX = {
    ["DEX_Enable"] = { title = "开启", tooltip = "开启攻击伤害显示器" },
    ["DEX_ShowWithMess"] = { title = "以Log方式显示", tooltip = "以Log方式显示所有伤害信息" },
    ["DEX_ShowSpellName"] = { title = "显示技能名", tooltip = "在伤害数值边显示造成此次伤害的技能名" },
    ["DEX_ShowNameOnCrit"] = { title = "当暴击才显示", tooltip = "只有在致命一击时才显示技能名" },
    ["DEX_ShowNameOnMiss"] = { title = "当未击中才显示", tooltip = "只有在技能未击中，被抵抗等才显示技能名" },
    ["DEX_ShowSpellIcon"] = { title = "显示技能图标", tooltip = "在伤害数字旁显示技能图标" },
    ["DEX_ShowIncomingDamage"] = { title = "显示受到伤害", tooltip = "显示你受到的伤害" },
    ["DEX_ShowDamageNormal"] = { title = "显示物理伤害", tooltip = "显示物理攻击的伤害" },
    ["DEX_ShowDamageSkill"] = { title = "显示技能伤害", tooltip = "显示技能攻击的伤害" },
    ["DEX_ShowDamagePeriodic"] = { title = "显示持续伤害", tooltip = "显示持续攻击的伤害" },
    ["DEX_ShowDamageShield"] = { title = "显示反射伤害", tooltip = "显示你对敌人伤害的反射量" },
    ["DEX_ShowDamageHealth"] = { title = "显示治疗量", tooltip = "显示对目标的治疗量" },
    ["DEX_ShowBlockNumber"] = { title = "显示被格挡的伤害", tooltip = "以xxx（xx）方式显示被格挡、吸收、抵抗的数值" },
    ["DEX_ShowDamagePet"] = { title = "显示宠物伤害", tooltip = "显示宠物对目标的伤害，含图腾" },
    ["DEX_ShowDamageWoW"] = { title = "显示系统默认伤害", tooltip = "显示系统原有的伤害" },
    ["DEX_AttachNameplate"] = { title = "附着到姓名版", tooltip = "将造成的伤害数字附着到目标的姓名版" },
    ["DEX_ShowEnergize"] = { title = "显示能量回复", tooltip = "显示法力、怒气等能量回复效果" },
    ["DEX_HideFriendlyDamage"] = { title = "隐藏对友误伤", tooltip = "勾选后，不显示对友方单位（玩家或队友）造成的伤害" },
    ["DEX_EnableAOEStandalone"] = { title = "AOE独立显示", tooltip = "开启后，AOE技能会使用特殊动画独立显示，避免混乱" },
    ["DEX_EnableTargetLine"] = { title = "目标连线", tooltip = "从屏幕中心绘制红线到当前目标（需要姓名版可见和UnitXP）" },
};

-- 滑块标题、最小文本、最大文本、提示
DEX_LANG_SLIDER = {
    ["DEX_Font"] = { title = "字体 ", min = "字体1", max = "字体3", tooltip = "设置文字的类型" },
    ["DEX_FontSize"] = { title = "文字大小 ", min = "小", max = "大", tooltip = "设置文字的大小" },
    ["DEX_OutLine"] = { title = "字型描边 ", min = "无", max = "粗", tooltip = "设置文字的描边效果" },
    ["DEX_Speed"] = { title = "文字移动速度 ", min = "慢", max = "快", tooltip = "设置文字的移动速度" },
    ["DEX_ScrollHeight"] = { title = "滚动高度 ", min = "5条", max = "20条", tooltip = "设置伤害数字滚动的最大高度（以条数计算）" },
    ["DEX_LOGLINE"] = { title = "停留时间 ", min = "2秒", max = "10秒", tooltip = "设置伤害数字显示的停留时长" },
    ["DEX_AnimHeight"] = { title = "动画高度 ", min = "100", max = "800", tooltip = "设置伤害数字向上滚动的最大高度" },
    ["DEX_NameplateOffsetX"] = { title = "姓名版横向偏移", min = "-200", max = "200", tooltip = "微调姓名版附件的水平位置" },
    ["DEX_NameplateOffsetY"] = { title = "姓名版纵向偏移", min = "-200", max = "200", tooltip = "微调姓名版附件的垂直位置" },
    ["DEX_TrajectoryOutgoing"] = { title = "造成伤害轨迹", min = "1", max = "7", tooltip = "选择造成伤害的动画轨迹类型（包括宠物伤害）" },
    ["DEX_TrajectoryIncoming"] = { title = "受到伤害轨迹", min = "1", max = "7", tooltip = "选择受到伤害的动画轨迹类型" },
    ["DEX_TrajectorySideDir"] = { title = "侧向方向", min = "1", max = "5", tooltip = "选择伤害数字的侧向移动方向" },
    ["DEX_TrajectoryEnergize"] = { title = "能量回复轨迹", min = "1", max = "7", tooltip = "选择能量回复的动画轨迹类型" },
    ["DEX_TargetLineSize"] = { title = "连线点大小 ", min = "1", max = "8", tooltip = "设置红点的大小（像素）" },
};

-- 颜色选择器标题
DEX_LANG_COLORPICKER = {
    ["DEX_ColorNormal"] = "物理伤害颜色",
    ["DEX_ColorNormalSe"] = "物理伤害渐变色",
    ["DEX_ColorSkill"] = "技能伤害颜色",
    ["DEX_ColorSkillSe"] = "技能伤害渐变色",
    ["DEX_ColorPeriodic"] = "持续伤害颜色",
    ["DEX_ColorPeriodicSe"] = "持续伤害渐变色",
    ["DEX_ColorHealth"] = "治疗颜色",
    ["DEX_ColorHealthSe"] = "治疗渐变色",
    ["DEX_ColorSpec"] = "特殊事件颜色",
    ["DEX_ColorSpecSe"] = "特殊事件渐变色",
    ["DEX_ColorMana"] = "法力伤害颜色",
    ["DEX_ColorManaSe"] = "法力伤害渐变色",
    ["DEX_ColorPet"] = "宠物伤害颜色",
    ["DEX_ColorPetSe"] = "宠物伤害渐变色",
    ["DEX_TargetLineColor"] = "连线颜色",
};

-- 轨迹名称映射
DEX_LANG_TRAJECTORY_NAMES = {
    [1] = "垂直向上",
    [2] = "彩虹弧线",
    [3] = "水平移动",
    [4] = "斜向下抛物线",
    [5] = "斜向上抛物线",
    [6] = "洒水器效果",
    [7] = "垂直向下",
};

-- 侧向方向名称映射
DEX_LANG_SIDEDIR_NAMES = {
    [1] = "交替",
    [2] = "伤害向左",
    [3] = "伤害向右",
    [4] = "全部向左",
    [5] = "全部向右",
};

-- 其他界面文本
DEX_LANG_COLORMODE_LABEL = "颜色模式";
DEX_LANG_PREBOX_OUTGOING = "拖动我改变造成伤害出现位置";
DEX_LANG_PREBOX_INCOMING = "拖动我改变受到伤害出现位置";
DEX_LANG_CLOSE = "关闭";
DEX_LANG_LOGLINE_FORMAT = "%.1f秒";