if GetLocale() == "ruRU" then
	-- Russian localization by Lichery
	SUPERMACROPLUSFRAME_EXTEND_CHAR_LIMIT = "Символы: %d/"..SMP_EXTEND_MAX_LETTERS;
	SUPERMACROPLUSFRAME_SUPER_CHAR_LIMIT = "Символы: %d/"..SMP_SUPER_MAX_LETTERS;
	REGULAR = "Обычный";
	SUPER = "Супер";
	SAVE_MACRO = "Сохранить";
	ENTER_EXTEND_LABEL = "Введите расширенный LUA код:";
	SAVE_EXTEND = "Сохр. расш-ие";
	DELETE_EXTEND = "Уд. расш-ие";
	SAVE_SUPERMACROPLUS = "Сохранить";
	NEW_SUPERMACROPLUS = "Новый";
	DELETE_SUPERMACROPLUS = "Удалить";
	SUPERMACROPLUS_TITLE = "СуперМакро";
	SUPERMACROPLUS_BUTTON = "M\nA\nC\nR\nO\nS";
	SUPERMACROPLUS_OPTIONS = "SM настройки";
	SUPERMACROPLUS_NEW_ACCOUNT = "Новый макрос аккаунта";
	SUPERMACROPLUS_NEW_CHARACTER = "Новый макрос персонажа";
	SUPERMACROPLUS_OPTIONS_TITLE = "Настройки СуперМакро";
	SUPERMACROPLUS_MINIMAP = "Открыть окно СуперМакро";
	
	SMP_HIDE_ACTION = "Скрыть имена на панели действий";
	SMP_MACRO_TIP_1 = "Показать подсказку о закл. или предмете";
	SMP_MACRO_TIP_2 = "Показать подсказку о скрипте макросов";
	SMP_PRINT_COLOR = "Цвет вывода для SMP_print() и /print";
	SMP_PRINT_COLOR_EXAMPLE_TEXT = "Пример: Ты видишь меня сейчас?";
	SMP_MINIMAP = "Показать кнопку миникарты";
	SMP_REPLACE_ICON = "Автозамена значков действий";
	SMP_CHECK_COOLDOWN = "Авто контроль перезарядки для действий";
	SMP_SHOW_MENU = "Показать кнопку меню";
	SMP_WORDWRAP = "Переносить длинные предложения";
	SMP_MONO_FONT = "Использовать монохромный шрифт для окна скриптов";
	SMP_WINDOW_HEIGHT = "Высота основного окна"
	SMP_WINDOW_WIDTH = "Ширина основного окна"
	SMP_EDITBOX_FONT_SIZE = "Размер шрифта для окна скриптов"
	
	--SLASH
	
	SLASH_SUPERMACROPLUS1 = "/supermacro";
	SUPERMACROPLUS_HELP_LINE1 = "Введите /supermacro, чтобы показать помощь"
	SUPERMACROPLUS_HELP_LINE2 = "/macro <название макроса>, чтобы запустить макрос по имени"
	SUPERMACROPLUS_HELP_LINE3 = "/supermacro hideaction 1 или 0, чтобы скрыть или показать имена макросов на кнопках действий"
	SUPERMACROPLUS_HELP_LINE4 = "/supermacro printcolor <красный> <заленый> <голубой> - каждый от 0 до 1, чтобы изменить цвет, используемый в /print"
	SUPERMACROPLUS_HELP_LINE5 = "/supermacro macrotip 0-3 - по умолчанию 1"
	SUPERMACROPLUS_HELP_LINE6 = "0 нормально, 1 показывает заклинание, 2 показывает код макроса, 3 показывает заклинание и/или код"
	
	SLASH_SMUSE1 = "/use";
	SLASH_SMUSE2 = "/smuse";
	SLASH_SMEQUIP1 = "/equip";
	SLASH_SMEQUIP2 = "/smequip";
	SLASH_SMEQUIP3 = "/eq";
	SLASH_SMEQUIP4 = "/smeq";
	SLASH_SMEQUIPOFF1 = "/equipoff";
	SLASH_SMEQUIPOFF2 = "/smequipoff";
	SLASH_SMEQUIPOFF3 = "/eqoff";
	SLASH_SMEQUIPOFF4 = "/smeqoff";
	SLASH_SMUNEQUIP1 = "/unequip";
	SLASH_SMUNEQUIP2 = "/smunequip";
	SLASH_SMUNEQUIP3 = "/uneq";
	SLASH_SMUNEQUIP4 = "/smuneq";
	SLASH_SMPRINT1 = "/print";
	SLASH_SMPRINT2 = "/smprint";
	SLASH_SMPASS1 = "/pass";
	SLASH_SMPASS2 = "/smpass";
	SLASH_SMFAIL1 = "/fail";
	SLASH_SMFAIL2 = "/smfail";
	SLASH_SMDOORDER1 = "/order";
	SLASH_SMDOORDER2 = "/smorder";
	SLASH_SMCHANNEL1 = "/smchan";
	SLASH_SMCHANNEL2 = "/smchannel";
	SLASH_SMIN1 = "/in";
	SLASH_SMIN2 = "/smin";
	SLASH_SMSHIFT1 = "/shift";
	SLASH_SMSHIFT2 = "/smshift";
	SLASH_SMCRAFT1 = "/craft";
	SLASH_SMCRAFT2 = "/smcraft";
	SLASH_SMSAYRANDOM1 = "/sayrandom";
	SLASH_SMSAYRANDOM2 = "/smsayrandom";
	SLASH_SMCANCELBUFF1 = "/unbuff";
	SLASH_SMCANCELBUFF2 = "/smunbuff";
	SLASH_SMRUNSUPER1 = "/smacro";
	
	--BINDINGS
	
	BINDING_HEADER_SUPERMACROPLUSHEADER = "СуперМакро";
	BINDING_NAME_TOGGLESUPERMACROPLUS = "Вкл./Выкл. окно СуперМакро";
	BINDING_NAME_OPENCHATSCRIPT = "Открыть чат /script";
	BINDING_NAME_OPENCHATMACRO = "Открыть чат /macro";
	BINDING_NAME_SMP_ATTACK = "Атака";
	BINDING_NAME_SMP_PETATTACK = "Атака питомца";
	BINDING_NAME_SMP_MACRO1 = "Макрос 1";
	BINDING_NAME_SMP_MACRO2 = "Макрос 2";
	BINDING_NAME_SMP_MACRO3 = "Макрос 3";
	BINDING_NAME_SMP_MACRO4 = "Макрос 4";
	BINDING_NAME_SMP_MACRO5 = "Макрос 5";
	BINDING_NAME_SMP_MACRO6 = "Макрос 6";
	BINDING_NAME_SMP_MACRO7 = "Макрос 7";
	BINDING_NAME_SMP_MACRO8 = "Макрос 8";
	BINDING_NAME_SMP_MACRO9 = "Макрос 9";
	BINDING_NAME_SMP_MACRO10 = "Макрос 10";
	BINDING_NAME_SMP_MACRO11 = "Макрос 11";
	BINDING_NAME_SMP_MACRO12 = "Макрос 12";
	BINDING_NAME_SMP_MACRO13 = "Макрос 13";
	BINDING_NAME_SMP_MACRO14 = "Макрос 14";
	BINDING_NAME_SMP_MACRO15 = "Макрос 15";
	BINDING_NAME_SMP_MACRO16 = "Макрос 16";
	BINDING_NAME_SMP_MACRO17 = "Макрос 17";
	BINDING_NAME_SMP_MACRO18 = "Макрос 18";
	BINDING_NAME_SMP_MACRO19 = "Макрос 19";
	BINDING_NAME_SMP_MACRO20 = "Макрос 20";
	BINDING_NAME_SMP_MACRO21 = "Макрос 21";
	BINDING_NAME_SMP_MACRO22 = "Макрос 22";
	BINDING_NAME_SMP_MACRO23 = "Макрос 23";
	BINDING_NAME_SMP_MACRO24 = "Макрос 24";
	BINDING_NAME_SMP_MACRO25 = "Макрос 25";
	BINDING_NAME_SMP_MACRO26 = "Макрос 26";
	BINDING_NAME_SMP_MACRO27 = "Макрос 27";
	BINDING_NAME_SMP_MACRO28 = "Макрос 28";
	BINDING_NAME_SMP_MACRO29 = "Макрос 29";
	BINDING_NAME_SMP_MACRO30 = "Макрос 30";
	BINDING_NAME_SMP_MACRO31 = "Макрос 31";
	BINDING_NAME_SMP_MACRO32 = "Макрос 32";
	BINDING_NAME_SMP_MACRO33 = "Макрос 33";
	BINDING_NAME_SMP_MACRO34 = "Макрос 34";
	BINDING_NAME_SMP_MACRO35 = "Макрос 35";
	BINDING_NAME_SMP_MACRO36 = "Макрос 36";
	BINDING_NAME_SMP_SUPERMACROPLUS1 = "Супер макрос 1";
	BINDING_NAME_SMP_SUPERMACROPLUS2 = "Супер макрос 2";
	BINDING_NAME_SMP_SUPERMACROPLUS3 = "Супер макрос 3";
	BINDING_NAME_SMP_SUPERMACROPLUS4 = "Супер макрос 4";
	BINDING_NAME_SMP_SUPERMACROPLUS5 = "Супер макрос 5";
	BINDING_NAME_SMP_SUPERMACROPLUS6 = "Супер макрос 6";
	BINDING_NAME_SMP_SUPERMACROPLUS7 = "Супер макрос 7";
	BINDING_NAME_SMP_SUPERMACROPLUS8 = "Супер макрос 8";
	BINDING_NAME_SMP_SUPERMACROPLUS9 = "Супер макрос 9";
	BINDING_NAME_SMP_SUPERMACROPLUS10 = "Супер макрос 10";
elseif GetLocale() == "zhCN" then
	--MACROFRAME_CHAR_LIMIT = "%d/"..SMP_MACRO_MAX_LETTERS.." Characters Used";
	SUPERMACROPLUSFRAME_EXTEND_CHAR_LIMIT = "%d/"..SMP_EXTEND_MAX_LETTERS.." 字符已使用";
	SUPERMACROPLUSFRAME_SUPER_CHAR_LIMIT = "%d/"..SMP_SUPER_MAX_LETTERS.." 字符已使用";
	REGULAR = "常规宏";
	SUPER = "超级宏";
	SAVE_MACRO = "保存";
	ENTER_EXTEND_LABEL = "输入 LUA 代码:";
	SAVE_EXTEND = "保存代码";
	DELETE_EXTEND = "删除代码";
	SAVE_SUPERMACROPLUS = "保存";
	NEW_SUPERMACROPLUS = "新建";
	DELETE_SUPERMACROPLUS = "删除";
	SUPERMACROPLUS_TITLE = "超级宏Plus";
	SUPERMACROPLUS_BUTTON = "超\n级\n宏\nP\nl\nu\ns";
	SUPERMACROPLUS_BUTTON_H = "超级宏Plus 设置";
	SUPERMACROPLUS_OPTIONS = "设置";
	SUPERMACROPLUS_NEW_ACCOUNT = "新建通用宏";
	SUPERMACROPLUS_NEW_CHARACTER = "新建专用宏";
	SUPERMACROPLUS_OPTIONS_TITLE = "超级宏Plus 设置";
	SUPERMACROPLUS_MINIMAP = "打开超级宏Plus窗口";

	SMP_HIDE_ACTION = "隐藏动作条宏名字";
	SMP_MACRO_TIP_1 = "显示技能和物品的鼠标提示";
	SMP_MACRO_TIP_2 = "显示宏脚本的的鼠标提示";
	SMP_PRINT_COLOR = "设置 SMP_print() 和 /print 的颜色";
	SMP_PRINT_COLOR_EXAMPLE_TEXT = "测试颜色: 你现在能看到我吗?";
	SMP_MINIMAP = "小地图显示按钮";
	SMP_REPLACE_ICON = "自动替换技能图标";
	SMP_CHECK_COOLDOWN = "自动检查CD";
	SMP_SHOW_MENU = "显示菜单超级宏按钮";
	SMP_WORDWRAP = "使用长句";
	SMP_MONO_FONT = "使用等宽字体（无法显示中文）";
	SMP_WINDOW_HEIGHT = "窗口高度"
	SMP_WINDOW_WIDTH = "窗口宽度"
	SMP_EDITBOX_FONT_SIZE = "字体大小"

	--SLASH

	SLASH_SUPERMACROPLUS1 = "/supermacro";
	SUPERMACROPLUS_HELP_LINE1 = "输入 /supermacro 显示帮助"
	SUPERMACROPLUS_HELP_LINE2 = "/macro <宏名字> 运行宏"
	SUPERMACROPLUS_HELP_LINE3 = "/supermacro hideaction 1 或 0 在动作按钮上隐藏或显示宏名称"
	SUPERMACROPLUS_HELP_LINE4 = "/supermacro printcolor <red> <green> <blue>, 每个从0到1改变颜色用于打印"
	SUPERMACROPLUS_HELP_LINE5 = "/supermacro macrotip 0-3, 默认为1"
	SUPERMACROPLUS_HELP_LINE6 = "0是一般, 1是显示法术, 2是显示宏代码, 3是显示法术和/或者代码"

	SLASH_SMUSE1 = "/use";
	SLASH_SMUSE2 = "/smuse";
	SLASH_SMEQUIP1 = "/equip";
	SLASH_SMEQUIP2 = "/smequip";
	SLASH_SMEQUIP3 = "/eq";
	SLASH_SMEQUIP4 = "/smeq";
	SLASH_SMEQUIPOFF1 = "/equipoff";
	SLASH_SMEQUIPOFF2 = "/smequipoff";
	SLASH_SMEQUIPOFF3 = "/eqoff";
	SLASH_SMEQUIPOFF4 = "/smeqoff";
	SLASH_SMUNEQUIP1 = "/unequip";
	SLASH_SMUNEQUIP2 = "/smunequip";
	SLASH_SMUNEQUIP3 = "/uneq";
	SLASH_SMUNEQUIP4 = "/smuneq";
	SLASH_SMPRINT1 = "/print";
	SLASH_SMPRINT2 = "/smprint";
	SLASH_SMPASS1 = "/pass";
	SLASH_SMPASS2 = "/smpass";
	SLASH_SMFAIL1 = "/fail";
	SLASH_SMFAIL2 = "/smfail";
	SLASH_SMDOORDER1 = "/order";
	SLASH_SMDOORDER2 = "/smorder";
	SLASH_SMCHANNEL1 = "/smchan";
	SLASH_SMCHANNEL2 = "/smchannel";
	SLASH_SMIN1 = "/in";
	SLASH_SMIN2 = "/smin";
	SLASH_SMSHIFT1 = "/shift";
	SLASH_SMSHIFT2 = "/smshift";
	SLASH_SMCRAFT1 = "/craft";
	SLASH_SMCRAFT2 = "/smcraft";
	SLASH_SMSAYRANDOM1 = "/sayrandom";
	SLASH_SMSAYRANDOM2 = "/smsayrandom";
	SLASH_SMCANCELBUFF1 = "/unbuff";
	SLASH_SMCANCELBUFF2 = "/smunbuff";
	SLASH_SMRUNSUPER1 = "/smacro";

	--BINDINGS

	BINDING_HEADER_SUPERMACROPLUSHEADER = "超级宏";
	BINDING_NAME_TOGGLESUPERMACROPLUS = "切换超级宏框架";
	BINDING_NAME_OPENCHATSCRIPT = "Open Chat /script";
	BINDING_NAME_OPENCHATMACRO = "Open Chat /macro";
	BINDING_NAME_SMP_ATTACK = "Attack";
	BINDING_NAME_SMP_PETATTACK = "PetAttack";
	BINDING_NAME_SMP_MACRO1 = "Macro 1";
	BINDING_NAME_SMP_MACRO2 = "Macro 2";
	BINDING_NAME_SMP_MACRO3 = "Macro 3";
	BINDING_NAME_SMP_MACRO4 = "Macro 4";
	BINDING_NAME_SMP_MACRO5 = "Macro 5";
	BINDING_NAME_SMP_MACRO6 = "Macro 6";
	BINDING_NAME_SMP_MACRO7 = "Macro 7";
	BINDING_NAME_SMP_MACRO8 = "Macro 8";
	BINDING_NAME_SMP_MACRO9 = "Macro 9";
	BINDING_NAME_SMP_MACRO10 = "Macro 10";
	BINDING_NAME_SMP_MACRO11 = "Macro 11";
	BINDING_NAME_SMP_MACRO12 = "Macro 12";
	BINDING_NAME_SMP_MACRO13 = "Macro 13";
	BINDING_NAME_SMP_MACRO14 = "Macro 14";
	BINDING_NAME_SMP_MACRO15 = "Macro 15";
	BINDING_NAME_SMP_MACRO16 = "Macro 16";
	BINDING_NAME_SMP_MACRO17 = "Macro 17";
	BINDING_NAME_SMP_MACRO18 = "Macro 18";
	BINDING_NAME_SMP_MACRO19 = "Macro 19";
	BINDING_NAME_SMP_MACRO20 = "Macro 20";
	BINDING_NAME_SMP_MACRO21 = "Macro 21";
	BINDING_NAME_SMP_MACRO22 = "Macro 22";
	BINDING_NAME_SMP_MACRO23 = "Macro 23";
	BINDING_NAME_SMP_MACRO24 = "Macro 24";
	BINDING_NAME_SMP_MACRO25 = "Macro 25";
	BINDING_NAME_SMP_MACRO26 = "Macro 26";
	BINDING_NAME_SMP_MACRO27 = "Macro 27";
	BINDING_NAME_SMP_MACRO28 = "Macro 28";
	BINDING_NAME_SMP_MACRO29 = "Macro 29";
	BINDING_NAME_SMP_MACRO30 = "Macro 30";
	BINDING_NAME_SMP_MACRO31 = "Macro 31";
	BINDING_NAME_SMP_MACRO32 = "Macro 32";
	BINDING_NAME_SMP_MACRO33 = "Macro 33";
	BINDING_NAME_SMP_MACRO34 = "Macro 34";
	BINDING_NAME_SMP_MACRO35 = "Macro 35";
	BINDING_NAME_SMP_MACRO36 = "Macro 36";
	BINDING_NAME_SMP_SUPERMACROPLUS1 = "SuperMacroPlus 1";
	BINDING_NAME_SMP_SUPERMACROPLUS2 = "SuperMacroPlus 2";
	BINDING_NAME_SMP_SUPERMACROPLUS3 = "SuperMacroPlus 3";
	BINDING_NAME_SMP_SUPERMACROPLUS4 = "SuperMacroPlus 4";
	BINDING_NAME_SMP_SUPERMACROPLUS5 = "SuperMacroPlus 5";
	BINDING_NAME_SMP_SUPERMACROPLUS6 = "SuperMacroPlus 6";
	BINDING_NAME_SMP_SUPERMACROPLUS7 = "SuperMacroPlus 7";
	BINDING_NAME_SMP_SUPERMACROPLUS8 = "SuperMacroPlus 8";
	BINDING_NAME_SMP_SUPERMACROPLUS9 = "SuperMacroPlus 9";
	BINDING_NAME_SMP_SUPERMACROPLUS10 = "SuperMacroPlus 10";
else
	--MACROFRAME_CHAR_LIMIT = "%d/"..SMP_MACRO_MAX_LETTERS.." Characters Used";
	SUPERMACROPLUSFRAME_EXTEND_CHAR_LIMIT = "%d/"..SMP_EXTEND_MAX_LETTERS.." Characters Used";
	SUPERMACROPLUSFRAME_SUPER_CHAR_LIMIT = "%d/"..SMP_SUPER_MAX_LETTERS.." Characters Used";
	REGULAR = "Regular";
	SUPER = "Super";
	SAVE_MACRO = "Save Macro";
	ENTER_EXTEND_LABEL = "Enter Extended LUA code:";
	SAVE_EXTEND = "Save Extend";
	DELETE_EXTEND = "Delete Extend";
	SAVE_SUPERMACROPLUS = "Save Super";
	NEW_SUPERMACROPLUS = "New Super";
	DELETE_SUPERMACROPLUS = "Delete Super";
	SUPERMACROPLUS_TITLE = "SuperMacroPlus";
	SUPERMACROPLUS_BUTTON = "M\nA\nC\nR\nO\nS";
	SUPERMACROPLUS_OPTIONS = "SM Options";
	SUPERMACROPLUS_NEW_ACCOUNT = "New account macro";
	SUPERMACROPLUS_NEW_CHARACTER = "New character macro";
	SUPERMACROPLUS_OPTIONS_TITLE = "SuperMacroPlus Options";
	SUPERMACROPLUS_MINIMAP = "Open SuperMacroPlus frame";
	
	SMP_HIDE_ACTION = "Hide names on action bars";
	SMP_MACRO_TIP_1 = "Show tooltip about spell or item";
	SMP_MACRO_TIP_2 = "Show tooltip about macro's script";
	SMP_PRINT_COLOR = "Output color of SMP_print() and /print";
	SMP_PRINT_COLOR_EXAMPLE_TEXT = "Ex: Can you see me now?";
	SMP_MINIMAP = "Show minimap button";
	SMP_REPLACE_ICON = "Auto-replace action icons";
	SMP_CHECK_COOLDOWN = "Auto-check cooldown for actions";
	SMP_SHOW_MENU = "Show menu button";
	SMP_WORDWRAP = "Wrap long sentences";
	SMP_MONO_FONT = "Use monospaced font for script editbox";
	SMP_WINDOW_HEIGHT = "Main window height"
	SMP_WINDOW_WIDTH = "Main window width"
	SMP_EDITBOX_FONT_SIZE = "Script editbox text font size"
	
	--SLASH
	
	SLASH_SUPERMACROPLUS1 = "/supermacro";
	SUPERMACROPLUS_HELP_LINE1 = "just /supermacro to show help"
	SUPERMACROPLUS_HELP_LINE2 = "/macro <macro_name> to run a macro by name"
	SUPERMACROPLUS_HELP_LINE3 = "/supermacro hideaction 1 or 0 to hide or show macro names on action buttons"
	SUPERMACROPLUS_HELP_LINE4 = "/supermacro printcolor <red> <green> <blue>, each from 0 to 1 to change color used in /print"
	SUPERMACROPLUS_HELP_LINE5 = "/supermacro macrotip 0-3, 1 default"
	SUPERMACROPLUS_HELP_LINE6 = "0 is normal, 1 show spells, 2 show macro code, 3 show  spell and/or code"
	
	SLASH_SMUSE1 = "/use";
	SLASH_SMUSE2 = "/smuse";
	SLASH_SMEQUIP1 = "/equip";
	SLASH_SMEQUIP2 = "/smequip";
	SLASH_SMEQUIP3 = "/eq";
	SLASH_SMEQUIP4 = "/smeq";
	SLASH_SMEQUIPOFF1 = "/equipoff";
	SLASH_SMEQUIPOFF2 = "/smequipoff";
	SLASH_SMEQUIPOFF3 = "/eqoff";
	SLASH_SMEQUIPOFF4 = "/smeqoff";
	SLASH_SMUNEQUIP1 = "/unequip";
	SLASH_SMUNEQUIP2 = "/smunequip";
	SLASH_SMUNEQUIP3 = "/uneq";
	SLASH_SMUNEQUIP4 = "/smuneq";
	SLASH_SMPRINT1 = "/print";
	SLASH_SMPRINT2 = "/smprint";
	SLASH_SMPASS1 = "/pass";
	SLASH_SMPASS2 = "/smpass";
	SLASH_SMFAIL1 = "/fail";
	SLASH_SMFAIL2 = "/smfail";
	SLASH_SMDOORDER1 = "/order";
	SLASH_SMDOORDER2 = "/smorder";
	SLASH_SMCHANNEL1 = "/smchan";
	SLASH_SMCHANNEL2 = "/smchannel";
	SLASH_SMIN1 = "/in";
	SLASH_SMIN2 = "/smin";
	SLASH_SMSHIFT1 = "/shift";
	SLASH_SMSHIFT2 = "/smshift";
	SLASH_SMCRAFT1 = "/craft";
	SLASH_SMCRAFT2 = "/smcraft";
	SLASH_SMSAYRANDOM1 = "/sayrandom";
	SLASH_SMSAYRANDOM2 = "/smsayrandom";
	SLASH_SMCANCELBUFF1 = "/unbuff";
	SLASH_SMCANCELBUFF2 = "/smunbuff";
	SLASH_SMRUNSUPER1 = "/smacro";
	
	--BINDINGS
	
	BINDING_HEADER_SUPERMACROPLUSHEADER = "SuperMacroPlus";
	BINDING_NAME_TOGGLESUPERMACROPLUS = "Toggle SuperMacroPlus Frame";
	BINDING_NAME_OPENCHATSCRIPT = "Open Chat /script";
	BINDING_NAME_OPENCHATMACRO = "Open Chat /macro";
	BINDING_NAME_SMP_ATTACK = "Attack";
	BINDING_NAME_SMP_PETATTACK = "PetAttack";
	BINDING_NAME_SMP_MACRO1 = "Macro 1";
	BINDING_NAME_SMP_MACRO2 = "Macro 2";
	BINDING_NAME_SMP_MACRO3 = "Macro 3";
	BINDING_NAME_SMP_MACRO4 = "Macro 4";
	BINDING_NAME_SMP_MACRO5 = "Macro 5";
	BINDING_NAME_SMP_MACRO6 = "Macro 6";
	BINDING_NAME_SMP_MACRO7 = "Macro 7";
	BINDING_NAME_SMP_MACRO8 = "Macro 8";
	BINDING_NAME_SMP_MACRO9 = "Macro 9";
	BINDING_NAME_SMP_MACRO10 = "Macro 10";
	BINDING_NAME_SMP_MACRO11 = "Macro 11";
	BINDING_NAME_SMP_MACRO12 = "Macro 12";
	BINDING_NAME_SMP_MACRO13 = "Macro 13";
	BINDING_NAME_SMP_MACRO14 = "Macro 14";
	BINDING_NAME_SMP_MACRO15 = "Macro 15";
	BINDING_NAME_SMP_MACRO16 = "Macro 16";
	BINDING_NAME_SMP_MACRO17 = "Macro 17";
	BINDING_NAME_SMP_MACRO18 = "Macro 18";
	BINDING_NAME_SMP_MACRO19 = "Macro 19";
	BINDING_NAME_SMP_MACRO20 = "Macro 20";
	BINDING_NAME_SMP_MACRO21 = "Macro 21";
	BINDING_NAME_SMP_MACRO22 = "Macro 22";
	BINDING_NAME_SMP_MACRO23 = "Macro 23";
	BINDING_NAME_SMP_MACRO24 = "Macro 24";
	BINDING_NAME_SMP_MACRO25 = "Macro 25";
	BINDING_NAME_SMP_MACRO26 = "Macro 26";
	BINDING_NAME_SMP_MACRO27 = "Macro 27";
	BINDING_NAME_SMP_MACRO28 = "Macro 28";
	BINDING_NAME_SMP_MACRO29 = "Macro 29";
	BINDING_NAME_SMP_MACRO30 = "Macro 30";
	BINDING_NAME_SMP_MACRO31 = "Macro 31";
	BINDING_NAME_SMP_MACRO32 = "Macro 32";
	BINDING_NAME_SMP_MACRO33 = "Macro 33";
	BINDING_NAME_SMP_MACRO34 = "Macro 34";
	BINDING_NAME_SMP_MACRO35 = "Macro 35";
	BINDING_NAME_SMP_MACRO36 = "Macro 36";
	BINDING_NAME_SMP_SUPERMACROPLUS1 = "SuperMacroPlus 1";
	BINDING_NAME_SMP_SUPERMACROPLUS2 = "SuperMacroPlus 2";
	BINDING_NAME_SMP_SUPERMACROPLUS3 = "SuperMacroPlus 3";
	BINDING_NAME_SMP_SUPERMACROPLUS4 = "SuperMacroPlus 4";
	BINDING_NAME_SMP_SUPERMACROPLUS5 = "SuperMacroPlus 5";
	BINDING_NAME_SMP_SUPERMACROPLUS6 = "SuperMacroPlus 6";
	BINDING_NAME_SMP_SUPERMACROPLUS7 = "SuperMacroPlus 7";
	BINDING_NAME_SMP_SUPERMACROPLUS8 = "SuperMacroPlus 8";
	BINDING_NAME_SMP_SUPERMACROPLUS9 = "SuperMacroPlus 9";
	BINDING_NAME_SMP_SUPERMACROPLUS10 = "SuperMacroPlus 10";
end

-- SuperMacroPlus category labels. Class globals are localized by the client,
-- while zhCN uses explicit short labels so all ten tabs fit on one row.
if GetLocale() == "zhCN" then
	SMP_CATEGORY_GENERAL = "通用";
	SMP_CATEGORY_SHAMAN = "萨满";
	SMP_CATEGORY_MAGE = "法师";
	SMP_CATEGORY_PALADIN = "圣骑士";
	SMP_CATEGORY_DRUID = "德鲁伊";
	SMP_CATEGORY_HUNTER = "猎人";
	SMP_CATEGORY_PRIEST = "牧师";
	SMP_CATEGORY_ROGUE = "盗贼";
	SMP_CATEGORY_WARLOCK = "术士";
	SMP_CATEGORY_WARRIOR = "战士";
	SMP_CATEGORY_FULL = "%s分类已达到%d个宏的上限。";
	SMP_DUPLICATE_MACRO = "宏名称已存在：%s";
	SMP_CARRIER_ERROR = "无法创建用于动作条拖放的内部宏槽。";
	SMP_MIGRATION_DONE = "已迁移原版超级宏 %d 个、常规宏 %d 个到通用页；跳过 %d 个，恢复动作条关联 %d 个。";
	SMP_MIGRATION_SOURCE_MISSING = "未检测到原版 SuperMacro 数据。请在插件列表中同时启用 SuperMacro 与 SuperMacroPlus，/reload 后手动输入 /smp import。";
	SMP_DROP_NOT_MACRO = "当前拖拽内容不是可导入的宏。";
	SMP_DROP_SLOT_OCCUPIED = "目标槽位已有宏：%s。请拖到空槽位。";
	SMP_DROP_EXISTS = "宏“%s”已存在于%s分类。";
	SMP_DROP_IMPORTED = "已将宏“%s”导入%s分类。";
	SMP_DROP_MOVED = "已将宏“%s”移动到%s分类。";
else
	SMP_CATEGORY_GENERAL = "Common";
	SMP_CATEGORY_SHAMAN = SHAMAN or "Shaman";
	SMP_CATEGORY_MAGE = MAGE or "Mage";
	SMP_CATEGORY_PALADIN = PALADIN or "Paladin";
	SMP_CATEGORY_DRUID = DRUID or "Druid";
	SMP_CATEGORY_HUNTER = HUNTER or "Hunter";
	SMP_CATEGORY_PRIEST = PRIEST or "Priest";
	SMP_CATEGORY_ROGUE = ROGUE or "Rogue";
	SMP_CATEGORY_WARLOCK = WARLOCK or "Warlock";
	SMP_CATEGORY_WARRIOR = WARRIOR or "Warrior";
	SMP_CATEGORY_FULL = "%s has reached the limit of %d macros.";
	SMP_DUPLICATE_MACRO = "A macro named %s already exists.";
	SMP_CARRIER_ERROR = "Unable to create the internal action-bar carrier macro.";
	SMP_MIGRATION_DONE = "Migrated %d legacy Super macros and %d regular macros to Common; skipped %d and restored %d action-bar mappings.";
	SMP_MIGRATION_SOURCE_MISSING = "Original SuperMacro data is not loaded. Enable SuperMacro and SuperMacroPlus together, /reload, then run /smp import manually.";
	SMP_DROP_NOT_MACRO = "The cursor does not contain an importable macro.";
	SMP_DROP_SLOT_OCCUPIED = "The target slot already contains %s. Drop onto an empty slot.";
	SMP_DROP_EXISTS = "The macro %s already exists in %s.";
	SMP_DROP_IMPORTED = "Imported %s into %s.";
	SMP_DROP_MOVED = "Moved %s into %s.";
end

-- Dedicated commands avoid replacing SuperMacro's /supermacro and /smacro.
SLASH_SUPERMACROPLUS1 = "/supermacroplus";
SLASH_SUPERMACROPLUS2 = "/smp";
SLASH_MACROPLUS1 = "/macroplus";
SLASH_SMPRUNSUPER1 = "/smacroplus";

if GetLocale() == "zhCN" then
	SUPERMACROPLUS_HELP_LINE1 = "/supermacroplus 或 /smp：打开分类宏窗口";
	SUPERMACROPLUS_HELP_LINE2 = "/macroplus <宏名>：运行超级宏";
	SUPERMACROPLUS_HELP_LINE3 = "/supermacroplus hideaction 1 或 0：隐藏或显示动作条宏名";
	SUPERMACROPLUS_HELP_LINE4 = "/supermacroplus printcolor <红> <绿> <蓝>：设置打印颜色";
	SUPERMACROPLUS_HELP_LINE5 = "/supermacroplus macrotip 0-3：设置宏提示信息";
	SUPERMACROPLUS_HELP_LINE6 = "分类标签每类最多保存 50 个超级宏";
	SUPERMACROPLUS_HELP_LINE7 = "/smp import：重新从原版 SuperMacro 导入宏到通用页";
else
	SUPERMACROPLUS_HELP_LINE1 = "/supermacroplus or /smp: open the category macro window";
	SUPERMACROPLUS_HELP_LINE2 = "/macroplus <name>: run a Super macro";
	SUPERMACROPLUS_HELP_LINE3 = "/supermacroplus hideaction 1 or 0: toggle action-button macro names";
	SUPERMACROPLUS_HELP_LINE4 = "/supermacroplus printcolor <red> <green> <blue>: set print color";
	SUPERMACROPLUS_HELP_LINE5 = "/supermacroplus macrotip 0-3: configure macro tooltips";
	SUPERMACROPLUS_HELP_LINE6 = "Each category tab stores up to 50 Super macros";
	SUPERMACROPLUS_HELP_LINE7 = "/smp import: retry importing original SuperMacro data to Common";
end

for i=1, SMP_CATEGORY_MAX_MACROS do
	if GetLocale() == "zhCN" then
		setglobal("BINDING_NAME_SMP_CATEGORY_MACRO"..i, "当前分类宏 "..i);
	else
		setglobal("BINDING_NAME_SMP_CATEGORY_MACRO"..i, "Current Category Macro "..i);
	end
end
