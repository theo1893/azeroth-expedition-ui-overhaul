SUPERMACROPLUS_VERSION = "1.0.0";
UIPanelWindows["SuperMacroPlusFrame"] = { area = "left", pushable = 7, whileDead = 1 };
UIPanelWindows["SuperMacroPlusOptionsFrame"] = { area = "left", pushable = 0, whileDead = 1 };
SMP_MACRO_ROWS = 3;
SMP_MACRO_COLUMNS = 10;
SMP_MACROS_REGULAR_SHOWN = 36;
SMP_MACROS_SUPER_SHOWN = SMP_MACRO_ROWS * SMP_MACRO_COLUMNS;
SMP_MAX_MACROS = 18;
--SMP_MAX_TOTAL_MACROS = 36;
SMP_NUM_MACRO_ICONS_SHOWN = 30;--20
SMP_NUM_ICONS_PER_ROW = 5;--5
SMP_NUM_ICON_ROWS = 6;--4
SMP_MACRO_ROW_HEIGHT = 36;
SMP_MACRO_ICON_ROW_HEIGHT = 36;
--SMP_MACRO_MAX_LETTERS = 255;
SMP_EXTEND_MAX_LETTERS = 50000;
SMP_SUPER_MAX_LETTERS = 50000;
SMP_CATEGORY_MAX_MACROS = 50;
SMP_MIGRATION_VERSION = 1;
SMP_PFUI_LAYOUT_VERSION = 1;
SMP_PFUI_FRAME_SCALE = 0.85;
SMP_PFUI_TAB_WIDTH = 56;
SMP_PRINT_COLOR_DEF = {r=1, g=1, b=1};
SMP_VARS = {}; -- options variables, Saved

SMP_CATEGORY_DEFINITIONS = {
	{ key="general", label="SMP_CATEGORY_GENERAL" },
	{ key="shaman", label="SMP_CATEGORY_SHAMAN" },
	{ key="mage", label="SMP_CATEGORY_MAGE" },
	{ key="paladin", label="SMP_CATEGORY_PALADIN" },
	{ key="druid", label="SMP_CATEGORY_DRUID" },
	{ key="hunter", label="SMP_CATEGORY_HUNTER" },
	{ key="priest", label="SMP_CATEGORY_PRIEST" },
	{ key="rogue", label="SMP_CATEGORY_ROGUE" },
	{ key="warlock", label="SMP_CATEGORY_WARLOCK" },
	{ key="warrior", label="SMP_CATEGORY_WARRIOR" },
};
SMP_DEFAULT_CATEGORY = "general";

-- 修复中文字符计数函数 by 武藤纯子酱 2026.1.27
function SMP_utf8len(str)
    if not str then return 0 end
    
    local count = 0
    local i = 1
    local len = strlen(str)
    
    while i <= len do
        local c = strbyte(str, i)
        
        if c <= 127 then
            -- ASCII字符
            i = i + 1
        elseif c >= 192 and c <= 223 then
            -- 2字节字符
            i = i + 2
        elseif c >= 224 and c <= 239 then
            -- 3字节字符（包括中文）
            i = i + 3
        elseif c >= 240 and c <= 247 then
            -- 4字节字符
            i = i + 4
        else
            -- 无效字节
            i = i + 1
        end
        
        count = count + 1
    end
    
    return count
end

--SMP_VARS.hideAction = 0;
--SMP_VARS.printColor = SMP_PRINT_COLOR_DEF;
--SMP_VARS.macroTip1 = 1;
--SMP_VARS.macroTip2 = 0;
--SMP_VARS.minimap = 1;
--SMP_VARS.replaceIcon = 1;
--SMP_VARS.checkCooldown = 1;
SMP_EXTEND = {}; -- ingame extended, Saved
SMP_SUPER={}; -- name -> {name, texture, body, category}, Saved
SMP_ORDERED={}; -- current category's supers in alphabetical order
SMP_ACTION={}; -- hold actions that have supers, for current player
SMP_ACTION_SUPER={}; -- hold actions for supers, Saved per character
SMP_MACRO_ICON={}; -- hold all available icons and their id
SMP_ACTION_SPELL={}; -- hold macros that cast spell or items
SMP_ACTION_SPELL.regular={};
SMP_ACTION_SPELL.super={};
SMP_AliasFunctions={}; -- functions to replace aliases
SMP_AliasFunctions.low=0;
SMP_AliasFunctions.high=0;
SMP_AliasFunctions[0]=function (body) return body; end

local function OnDragStart() this:StartMoving() end
local function OnDragStop() this:StopMovingOrSizing() end

function SMP_IsValidCategory(category)
	for i=1, getn(SMP_CATEGORY_DEFINITIONS) do
		if ( SMP_CATEGORY_DEFINITIONS[i].key==category ) then
			return 1;
		end
	end
	return nil;
end

function SMP_GetCurrentCategory()
	if ( not SMP_VARS.category or not SMP_IsValidCategory(SMP_VARS.category) ) then
		return SMP_DEFAULT_CATEGORY;
	end
	return SMP_VARS.category;
end

function SMP_GetCategoryID(category)
	for i=1, getn(SMP_CATEGORY_DEFINITIONS) do
		if ( SMP_CATEGORY_DEFINITIONS[i].key==category ) then
			return i;
		end
	end
	return 1;
end

function SMP_GetCategoryLabel(category)
	local id=SMP_GetCategoryID(category);
	local label=getglobal(SMP_CATEGORY_DEFINITIONS[id].label);
	return label or SMP_CATEGORY_DEFINITIONS[id].key;
end

function SMP_GetCategoryMacroCount(category)
	local count=0;
	category=category or SMP_GetCurrentCategory();
	for _,macro in pairs(SMP_SUPER) do
		if ( type(macro)=="table" and macro[4]==category ) then
			count=count+1;
		end
	end
	return count;
end

function SMP_NormalizeSuperMacros()
	for name,macro in pairs(SMP_SUPER) do
		if ( type(macro)~="table" ) then
			SMP_SUPER[name]=nil;
		else
			macro[1]=macro[1] or name;
			macro[2]=macro[2] or "Interface\\Icons\\INV_Misc_QuestionMark";
			macro[3]=macro[3] or "";
			if ( not SMP_IsValidCategory(macro[4]) ) then
				macro[4]=SMP_DEFAULT_CATEGORY;
			end
		end
	end
end

-- DoiteDPS-owned warrior actions used by the saved Protection action-bar
-- layout.  Provision definitions only; loading the layout remains an explicit
-- player action through /abp 防战.
local SMP_DOITE_WARRIOR_MACRO_VERSION = 6;
local SMP_DOITE_WARRIOR_MACROS = {
	{
		"防战单体仇恨宏",
		"Interface\\Icons\\INV_Shield_05",
		"#showtooltip 盾牌猛击\n/run DoiteDPS_Execute(\"single\")\n/startattack",
		previousBody = "#showtooltip 盾牌猛击\n/startattack\n/run DoiteDPS_Execute(\"single\")"
	},
	{
		"防战AOE仇恨宏",
		"Interface\\Icons\\Spell_Nature_ThunderClap",
		"#showtooltip 雷霆一击\n/run DoiteDPS_Execute(\"aoe\")\n/startattack",
		previousBody = "#showtooltip 雷霆一击\n/startattack\n/run DoiteDPS_Execute(\"aoe\")"
	},
	{
		"防战手动破甲宏",
		"Interface\\Icons\\Ability_Warrior_Sunder",
		"#showtooltip 破甲攻击\n/startattack\n/cast 破甲攻击"
	},
	{
		"战士破甲宏",
		"Interface\\Icons\\Ability_Warrior_Sunder",
		"#showtooltip 破甲攻击\n/startattack\n/cast 破甲攻击"
	},
	{
		"战士防御盾挡",
		"Interface\\Icons\\Ability_Defend",
		"#showtooltip 盾牌格挡\n/cast [stance:1,stance:3] 防御姿态\n/cast [stance:2] 盾牌格挡",
		forceUpdate = true
	},
	{
		"战士手动斩杀宏",
		"Interface\\Icons\\INV_Sword_48",
		"#showtooltip 斩杀\n/startattack\n/cast [stance:2] 战斗姿态\n/cast [stance:1,stance:3] 斩杀"
	},
	{
		"防战挫志宏",
		"Interface\\Icons\\Ability_Warrior_WarCry",
		"#showtooltip 挫志怒吼\n/cast 挫志怒吼"
	},
	{
		"防战战吼宏",
		"Interface\\Icons\\Ability_Warrior_BattleShout",
		"#showtooltip 战斗怒吼\n/cast 战斗怒吼"
	},
	{
		"防战挑战怒吼宏",
		"Interface\\Icons\\Ability_BullRush",
		"#showtooltip 挑战怒吼\n/cast 挑战怒吼"
	},
	{
		"防战血性狂暴宏",
		"Interface\\Icons\\Ability_Racial_BloodRage",
		"#showtooltip 血性狂暴\n/cast 血性狂暴"
	},
	{
		"防战狂暴之怒宏",
		"Interface\\Icons\\Spell_Nature_AncestralGuardian",
		"#showtooltip 狂暴之怒\n/cast [stance:1,stance:2] 狂暴姿态\n/cast [stance:3] 狂暴之怒"
	},
	{
		"防战血性狂怒宏",
		"Interface\\Icons\\Racial_Orc_BerserkerStrength",
		"#showtooltip 血性狂怒\n/cast 血性狂怒"
	},
	{
		"防战缴械宏",
		"Interface\\Icons\\Ability_Warrior_Disarm",
		"#showtooltip 缴械\n/cast [stance:3] 防御姿态\n/cast [stance:1,stance:2] 缴械"
	},
	{
		"战士断筋宏",
		"Interface\\Icons\\Ability_ShockWave",
		"#showtooltip 断筋\n/startattack\n/cast 断筋"
	},
	{
		"战士破胆怒吼宏",
		"Interface\\Icons\\Ability_GolemThunderClap",
		"#showtooltip 破胆怒吼\n/cast 破胆怒吼"
	},
	{
		"战士缴械宏",
		"Interface\\Icons\\Ability_Warrior_Disarm",
		"#showtooltip 缴械\n/cast [stance:3] 防御姿态\n/cast [stance:1,stance:2] 缴械"
	},
	{
		"战士冲拦援宏",
		"Interface\\Icons\\Ability_Warrior_Charge",
		"#showtooltip\n/cast [help,stance:1/3] 防御姿态; [harm,nocombat,stance:2/3] 战斗姿态; [harm,combat,stance:1/2] 狂暴姿态\n/cast [help,stance:2] 援护; [harm,nocombat,stance:1] 冲锋; [harm,combat,stance:3] 拦截\n/startattack [harm]",
		forceUpdate = true
	},
	{
		"战士打断宏",
		"Interface\\Icons\\INV_Gauntlets_04",
		"#showtooltip\n/cast [stance:3] 拳击; [stance:1/2] 盾击",
		forceUpdate = true
	},
};

local function SMP_InstallDoiteWarriorMacros()
	if ( tonumber(SMP_VARS.doiteWarriorMacroVersion or 0)>=SMP_DOITE_WARRIOR_MACRO_VERSION ) then
		return;
	end
	for i=1,getn(SMP_DOITE_WARRIOR_MACROS) do
		local definition=SMP_DOITE_WARRIOR_MACROS[i];
		local name=definition[1];
		if ( not SMP_SUPER[name] or definition.forceUpdate ) then
			SMP_SUPER[name]={name, definition[2], definition[3], "warrior"};
		elseif ( definition.previousBody and SMP_SUPER[name][3]==definition.previousBody ) then
			-- Only migrate the exact previously managed body. Player-edited
			-- variants remain untouched and can be reviewed with /ddps macros.
			SMP_SUPER[name][2]=definition[2];
			SMP_SUPER[name][3]=definition[3];
		end
	end
	SMP_VARS.doiteWarriorMacroVersion=SMP_DOITE_WARRIOR_MACRO_VERSION;
end

local function SMP_AddMigratedMacro(name, texture, body, generalCount)
	if ( type(name)~="string" or name=="" ) then
		return generalCount, nil;
	end
	if ( SMP_SUPER[name] or generalCount>=SMP_CATEGORY_MAX_MACROS ) then
		return generalCount, nil;
	end
	SMP_SUPER[name]={
		name,
		texture or "Interface\\Icons\\INV_Misc_QuestionMark",
		body or "",
		SMP_DEFAULT_CATEGORY
	};
	return generalCount+1, 1;
end

local function SMP_MigrateLegacyActionMappings()
	local copied=0;
	if ( type(SM_ACTION_SUPER)~="table" ) then return copied; end
	for player,actions in pairs(SM_ACTION_SUPER) do
		if ( type(actions)=="table" ) then
			if ( type(SMP_ACTION_SUPER[player])~="table" ) then
				SMP_ACTION_SUPER[player]={};
			end
			for actionid,name in pairs(actions) do
				if ( SMP_SUPER[name] and not SMP_ACTION_SUPER[player][actionid] ) then
					SMP_ACTION_SUPER[player][actionid]=name;
					copied=copied+1;
				end
			end
		end
	end
	return copied;
end

-- Manual, non-destructive migration from the original SuperMacro addon.
-- Super macros are copied first; native account/character macros use any
-- remaining room in General. The source SavedVariables and native macros stay
-- untouched. Migration only runs when the player enters /smp import.
function SMP_MigrateFromSuperMacro(force)
	if ( not force and tonumber(SMP_VARS.superMacroMigrationVersion or 0)>=SMP_MIGRATION_VERSION ) then
		return 0, 0, 0, 0, 1;
	end
	-- A disabled addon does not load its SavedVariables. Do not mark migration
	-- complete, so enabling SuperMacro once and reloading can retry it.
	if ( type(SM_SUPER)~="table" ) then
		return 0, 0, 0, 0, nil;
	end

	local importedSuper=0;
	local importedRegular=0;
	local skipped=0;
	local generalCount=SMP_GetCategoryMacroCount(SMP_DEFAULT_CATEGORY);
	local legacyNames={};
	for name in pairs(SM_SUPER) do
		table.insert(legacyNames, name);
	end
	table.sort(legacyNames);

	for i=1,getn(legacyNames) do
		local sourceName=legacyNames[i];
		local sourceMacro=SM_SUPER[sourceName];
		if ( type(sourceMacro)=="table" ) then
			local name=sourceMacro[1] or sourceName;
			local added;
			generalCount,added=SMP_AddMigratedMacro(name, sourceMacro[2], sourceMacro[3], generalCount);
			if ( added ) then
				importedSuper=importedSuper+1;
			else
				skipped=skipped+1;
			end
		else
			skipped=skipped+1;
		end
	end

	-- Original "regular" macros are native account/character macros. Import
	-- them only after the legacy Super macros so the 50-slot General cap cannot
	-- crowd out long SuperMacro bodies.
	local numAccountMacros,numCharacterMacros=GetNumMacros();
	local nativeMacroIDs={};
	for i=1,(numAccountMacros or 0) do
		table.insert(nativeMacroIDs, i);
	end
	for i=1,(numCharacterMacros or 0) do
		table.insert(nativeMacroIDs, SMP_MAX_MACROS+i);
	end
	for i=1,getn(nativeMacroIDs) do
		local name,texture,body=GetMacroInfo(nativeMacroIDs[i]);
		if ( name and name~=(SMP_CARRIER_MACRO_NAME or "SMP_Carrier") ) then
			local added;
			generalCount,added=SMP_AddMigratedMacro(name, texture, body, generalCount);
			if ( added ) then
				importedRegular=importedRegular+1;
			else
				skipped=skipped+1;
			end
		end
	end

	local copiedActions=SMP_MigrateLegacyActionMappings();
	SMP_VARS.superMacroMigrationVersion=SMP_MIGRATION_VERSION;
	return importedSuper, importedRegular, skipped, copiedActions, 1;
end

function SMP_PrintMigrationResult(importedSuper, importedRegular, skipped, copiedActions)
	if ( not DEFAULT_CHAT_FRAME ) then return; end
	DEFAULT_CHAT_FRAME:AddMessage(
		"|cff33aaffSuperMacroPlus:|r "..format(
			SMP_MIGRATION_DONE,
			importedSuper or 0,
			importedRegular or 0,
			skipped or 0,
			copiedActions or 0
		),
		0.25, 1, 0.5
	);
end

function SMP_PrintError(message)
	if ( DEFAULT_CHAT_FRAME and message ) then
		DEFAULT_CHAT_FRAME:AddMessage("|cff33aaffSuperMacroPlus:|r "..message, 1, 0.25, 0.25);
	end
end

function SMP_PrintMessage(message)
	if ( DEFAULT_CHAT_FRAME and message ) then
		DEFAULT_CHAT_FRAME:AddMessage("|cff33aaffSuperMacroPlus:|r "..message, 0.25, 1, 0.5);
	end
end

function SMP_NotifyMacroChanged(name, oldName)
	if ( CleveRoids and type(CleveRoids.OnSuperMacroPlusChanged)=="function" ) then
		CleveRoids.OnSuperMacroPlusChanged(name, oldName);
	end
end

function SMP_PrintCategoryFull()
	SMP_PrintError(format(SMP_CATEGORY_FULL, SMP_GetCategoryLabel(SMP_GetCurrentCategory()), SMP_CATEGORY_MAX_MACROS));
end

local function SMP_PfUISetFont(fontObject, size)
	if ( not fontObject or not fontObject.SetFont ) then return; end
	fontObject:SetFont(pfUI.font_default, size, "OUTLINE");
	if ( fontObject.SetTextColor ) then
		fontObject:SetTextColor(1, 1, 1);
	end
end

local function SMP_PfUISkinEditBox(editBox, fontSize)
	if ( not editBox ) then return; end
	pfUI.api.StripTextures(editBox, 1, "BACKGROUND");
	pfUI.api.CreateBackdrop(editBox, nil, 1);
	SMP_PfUISetFont(editBox, fontSize);
end

local function SMP_PfUISkinScrollbar(scrollbar)
	if ( not scrollbar or not scrollbar.GetName or not scrollbar.GetThumbTexture ) then return; end
	local name=scrollbar:GetName();
	if ( not name or not getglobal(name.."ScrollUpButton") or not getglobal(name.."ScrollDownButton") or
		not scrollbar:GetThumbTexture() ) then
		return;
	end
	pfUI.api.SkinScrollbar(scrollbar);
end

local function SMP_PfUISkinMacroIcon(button, fontSize)
	if ( not button ) then return; end
	pfUI.api.StripTextures(button, 1, "BACKGROUND");
	pfUI.api.CreateBackdrop(button);
	local icon=button:GetNormalTexture();
	if ( icon ) then
		icon:ClearAllPoints();
		icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2);
		icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2);
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
	end
	local name=button:GetName();
	if ( name ) then
		SMP_PfUISetFont(getglobal(name.."Name"), fontSize-2);
	end
end

local function SMP_PfUITab_OnShow()
	this:SetWidth(SMP_PFUI_TAB_WIDTH);
	this:SetHeight(20);
end

-- pfUI explicitly skins the original SuperMacro menu button but does not know
-- about SuperMacroPlus. Reuse its public helpers here so no pfUI file needs to
-- be patched and pfUI upgrades cannot overwrite this compatibility layer.
function SMP_ApplyPfUISkin()
	if ( SMP_PFUI_SKINNED ) then return 1; end
	if ( not pfUI or not pfUI.api or not pfUI.api.SkinButton or not pfUI.api.CreateBackdrop or
		not GameMenuButtonSuperMacroPlus ) then
		return nil;
	end
	if ( pfUI_config and pfUI_config.thirdparty and pfUI_config.thirdparty.supermacro and
		pfUI_config.thirdparty.supermacro.enable=="0" ) then
		return nil;
	end

	local api=pfUI.api;
	local fontSize=12;
	if ( pfUI_config and pfUI_config.global ) then
		fontSize=tonumber(pfUI_config.global.font_size) or fontSize;
	end
	-- The old 800x600 default nearly fills a low-resolution UI once the wide
	-- Blizzard artwork is removed. Compact existing installs once, while still
	-- allowing the user to resize it again through Options afterwards.
	if ( tonumber(SMP_VARS.pfUICompactLayoutVersion or 0)<SMP_PFUI_LAYOUT_VERSION ) then
		SMP_VARS.windowWidth=math.min(tonumber(SMP_VARS.windowWidth) or 620, 620);
		SMP_VARS.windowHeight=math.min(tonumber(SMP_VARS.windowHeight) or 520, 520);
		SMP_VARS.pfUICompactLayoutVersion=SMP_PFUI_LAYOUT_VERSION;
	end

	-- ESC menu entry.
	api.SkinButton(GameMenuButtonSuperMacroPlus);

	-- Main categorized-macro window.
	SuperMacroPlusFrame:SetScale(SMP_PFUI_FRAME_SCALE);
	SuperMacroPlusPopupFrame:SetScale(SMP_PFUI_FRAME_SCALE);
	SuperMacroPlusOptionsFrame:SetScale(SMP_PFUI_FRAME_SCALE);
	api.StripTextures(SuperMacroPlusFrame);
	api.CreateBackdrop(SuperMacroPlusFrame, nil, 1, 0.85);
	api.CreateBackdropShadow(SuperMacroPlusFrame);
	api.CreateBackdrop(SuperMacroPlusFrameMainBackground, nil, 1, 0.55);
	api.CreateBackdrop(SuperMacroPlusFrameSuperTextBackground, nil, 1, 0.55);
	SMP_PfUISetFont(SuperMacroPlusFrameTitle, fontSize+2);
	SMP_PfUISetFont(SuperMacroPlusFrameSelectedMacroName, fontSize+1);
	api.SkinCloseButton(SuperMacroPlusFrameCloseButton, SuperMacroPlusFrame, -6, -6);

	local mainButtons={
		"SuperMacroPlusNewSuperButton",
		"SuperMacroPlusSaveSuperButton",
		"SuperMacroPlusDeleteSuperButton",
		"SuperMacroPlusEditButton",
		"SuperMacroPlusOptionsButton",
		"SuperMacroPlusDeleteButton",
		"SuperMacroPlusSaveButton",
		"SuperMacroPlusExitButton",
		"SuperMacroPlusSaveExtendButton",
		"SuperMacroPlusDeleteExtendButton",
		"SuperMacroPlusNewAccountButton",
		"SuperMacroPlusNewCharacterButton"
	};
	for i=1,getn(mainButtons) do
		local button=getglobal(mainButtons[i]);
		if ( button ) then api.SkinButton(button); end
	end
	-- Blizzard's original +3/+4 offsets intentionally overlap textured button
	-- borders. pfUI uses square borders, so use a real gap and a common baseline.
	SuperMacroPlusNewSuperButton:SetWidth(100);
	SuperMacroPlusNewSuperButton:SetHeight(22);
	SuperMacroPlusNewSuperButton:ClearAllPoints();
	SuperMacroPlusNewSuperButton:SetPoint("BOTTOMRIGHT", SuperMacroPlusFrame, "BOTTOMRIGHT", -120, 79);
	SuperMacroPlusSaveSuperButton:SetWidth(100);
	SuperMacroPlusSaveSuperButton:SetHeight(22);
	SuperMacroPlusSaveSuperButton:ClearAllPoints();
	SuperMacroPlusSaveSuperButton:SetPoint("BOTTOMRIGHT", SuperMacroPlusNewSuperButton, "BOTTOMLEFT", -4, 0);
	SuperMacroPlusDeleteSuperButton:SetWidth(100);
	SuperMacroPlusDeleteSuperButton:SetHeight(22);
	SuperMacroPlusDeleteSuperButton:ClearAllPoints();
	SuperMacroPlusDeleteSuperButton:SetPoint("BOTTOMRIGHT", SuperMacroPlusSaveSuperButton, "BOTTOMLEFT", -4, 0);
	SuperMacroPlusOptionsButton:SetWidth(100);
	SuperMacroPlusOptionsButton:SetHeight(22);
	SuperMacroPlusOptionsButton:ClearAllPoints();
	SuperMacroPlusOptionsButton:SetPoint("BOTTOMLEFT", SuperMacroPlusFrame, "BOTTOMLEFT", 15, 79);

	local previousTab=nil;
	for i=1,getn(SMP_CATEGORY_DEFINITIONS) do
		local tab=getglobal("SuperMacroPlusFrameTab"..i);
		if ( tab ) then
			api.SkinTab(tab, 1);
			tab:SetWidth(SMP_PFUI_TAB_WIDTH);
			tab:SetHeight(20);
			-- CharacterFrameTabButtonTemplate has its own OnShow resize script.
			-- Replace it so the ten fixed tabs cannot grow past the right border.
			tab:SetScript("OnShow", SMP_PfUITab_OnShow);
			SMP_PfUISetFont(tab:GetFontString(), fontSize);
			tab:ClearAllPoints();
			if ( previousTab ) then
				tab:SetPoint("LEFT", previousTab, "RIGHT", 1, 0);
			else
				tab:SetPoint("BOTTOMLEFT", SuperMacroPlusFrame, "BOTTOMLEFT", 11, 45);
			end
			previousTab=tab;
		end
	end

	local scrollbarNames={
		"SuperMacroPlusFrameSuperScrollFrameScrollBar",
		"SuperMacroPlusFrameSuperEditScrollFrameScrollBar",
		"SuperMacroPlusFrameScrollFrameScrollBar",
		"SuperMacroPlusFrameExtendScrollFrameScrollBar"
	};
	for i=1,getn(scrollbarNames) do
		SMP_PfUISkinScrollbar(getglobal(scrollbarNames[i]));
	end

	SMP_PfUISkinMacroIcon(SuperMacroPlusFrameSelectedMacroSuperButton, fontSize);
	for i=1,SMP_MACROS_SUPER_SHOWN do
		SMP_PfUISkinMacroIcon(getglobal("SuperMacroPlusSuperButton"..i), fontSize);
	end

	-- Name/icon chooser popup.
	api.StripTextures(SuperMacroPlusPopupFrame);
	api.StripTextures(SuperMacroPlusPopupScrollFrame);
	api.CreateBackdrop(SuperMacroPlusPopupFrame, nil, 1, 0.9);
	api.CreateBackdropShadow(SuperMacroPlusPopupFrame);
	SMP_PfUISkinEditBox(SuperMacroPlusPopupEditBox, fontSize);
	api.SkinButton(SuperMacroPlusPopupCancelButton);
	api.SkinButton(SuperMacroPlusPopupOkayButton);
	-- The Blizzard popup artwork extends below its logical frame and therefore
	-- anchors these buttons at y=-1. pfUI uses the exact frame boundary, so keep
	-- both buttons inset and aligned instead of letting them cross the border.
	SuperMacroPlusPopupCancelButton:SetWidth(78);
	SuperMacroPlusPopupCancelButton:SetHeight(22);
	SuperMacroPlusPopupCancelButton:ClearAllPoints();
	SuperMacroPlusPopupCancelButton:SetPoint("BOTTOMRIGHT", SuperMacroPlusPopupFrame, "BOTTOMRIGHT", -8, 8);
	SuperMacroPlusPopupOkayButton:SetWidth(78);
	SuperMacroPlusPopupOkayButton:SetHeight(22);
	SuperMacroPlusPopupOkayButton:ClearAllPoints();
	SuperMacroPlusPopupOkayButton:SetPoint("BOTTOMRIGHT", SuperMacroPlusPopupCancelButton, "BOTTOMLEFT", -4, 0);
	SMP_PfUISkinScrollbar(SuperMacroPlusPopupScrollFrameScrollBar);
	for i=1,SMP_NUM_MACRO_ICONS_SHOWN do
		SMP_PfUISkinMacroIcon(getglobal("SuperMacroPlusPopupButton"..i), fontSize);
	end

	-- Options window opened from the main frame.
	if ( SuperMacroPlusOptionsFrame ) then
		api.StripTextures(SuperMacroPlusOptionsFrame);
		api.CreateBackdrop(SuperMacroPlusOptionsFrame, nil, 1, 0.9);
		api.CreateBackdropShadow(SuperMacroPlusOptionsFrame);
		SMP_PfUISetFont(SuperMacroPlusOptionsTitleText, fontSize+2);
		api.SkinCloseButton(SuperMacroPlusOptionsCloseButton, SuperMacroPlusOptionsFrame, -6, -6);
		api.SkinButton(SuperMacroPlusOptionsExitButton);
		for i=1,9 do
			local checkbox=getglobal("SuperMacroPlusOptionsFrameCheckButton"..i);
			if ( checkbox ) then
				api.SkinCheckbox(checkbox);
				SMP_PfUISetFont(getglobal(checkbox:GetName().."Text"), fontSize);
			end
		end
		for i=1,3 do
			local editBox=getglobal("SuperMacroPlusOptionsFrameEditBox"..i);
			SMP_PfUISkinEditBox(editBox, fontSize);
			if ( editBox ) then
				SMP_PfUISetFont(getglobal(editBox:GetName().."Text"), fontSize);
			end
		end
		if ( SuperMacroPlusOptionsFrameColorSwatch1 ) then
			api.CreateBackdrop(SuperMacroPlusOptionsFrameColorSwatch1);
			SMP_PfUISetFont(SuperMacroPlusOptionsFrameColorSwatch1Text, fontSize);
			SMP_PfUISetFont(SuperMacroPlusOptionsFrameColorSwatch1ExampleText, fontSize);
		end
	end

	SMP_PFUI_SKINNED=1;
	return 1;
end

function SMP_InitializeCategoryTabs()
	PanelTemplates_SetNumTabs(SuperMacroPlusFrame, getn(SMP_CATEGORY_DEFINITIONS));
	for i=1, getn(SMP_CATEGORY_DEFINITIONS) do
		local tab=getglobal("SuperMacroPlusFrameTab"..i);
		if ( tab ) then
			tab:SetText(SMP_GetCategoryLabel(SMP_CATEGORY_DEFINITIONS[i].key));
		end
	end
	local id=SMP_GetCategoryID(SMP_GetCurrentCategory());
	SuperMacroPlusFrame.selectedTab=id;
	PanelTemplates_SetTab(SuperMacroPlusFrame, id);
	PanelTemplates_UpdateTabs(SuperMacroPlusFrame);
end

function SuperMacroPlusCategoryTab_OnClick(id)
	local categoryInfo=SMP_CATEGORY_DEFINITIONS[id];
	if ( not categoryInfo ) then return; end
	SuperMacroPlusFrame_SaveSuperMacroPlus();
	SMP_VARS.category=categoryInfo.key;
	SMP_VARS.tabShown="super";
	SMP_ORDERED=SortSuperMacroPlusList(SMP_VARS.category);
	SuperMacroPlusFrame.selectedSuper=(getn(SMP_ORDERED)>0) and 1 or nil;
	FauxScrollFrame_SetOffset(SuperMacroPlusFrameSuperScrollFrame, 0);
	SuperMacroPlusFrameSuperScrollFrameScrollBar:SetValue(0);
	PanelTemplates_SetTab(SuperMacroPlusFrame, id);
	SuperMacroPlusPopupFrame:Hide();
	SuperMacroPlusFrame_Update();
	-- Picking up a Plus macro is intentionally allowed to survive a category
	-- switch so it can be dropped into an empty slot on the destination tab.
	if ( SMP_RefreshDragCursor ) then SMP_RefreshDragCursor(); end
end

function SuperMacroPlusFrame_OnLoad()
	PanelTemplates_SetNumTabs(this, getn(SMP_CATEGORY_DEFINITIONS));
	SuperMacroPlusFrame.selectedTab = 1;
	PanelTemplates_UpdateTabs(this);
	SuperMacroPlusFrameTitle:SetText(SUPERMACROPLUS_TITLE.." "..SUPERMACROPLUS_VERSION);
	SMP_UpdateAction();
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("TRADE_SKILL_SHOW");
	this:RegisterEvent("CRAFT_SHOW");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_LEAVING_WORLD");
	this:RegisterEvent("SPELLS_CHANGED");
	this:RegisterEvent("CHARACTER_POINTS_CHANGED");
	this:RegisterEvent("PLAYER_TALENT_UPDATE");
	lastActionUsed = nil;
	SMP_MACRO_ICON=SMP_LoadMacroIcons();
	if ( not Print ) then
		Print=Printd;
	end

	SuperMacroPlusFrame:SetMovable(true)
	SuperMacroPlusFrame:EnableMouse(true)
	SuperMacroPlusFrame:RegisterForDrag("LeftButton")
	SuperMacroPlusFrame:SetScript("OnDragStart", OnDragStart)
	SuperMacroPlusFrame:SetScript("OnDragStop", OnDragStop)
end

function SuperMacroPlusFrame_OnShow()
	SuperMacroPlusFrame_Update();
	PlaySound("igCharacterInfoOpen");

	SuperMacroPlusFrame:ClearAllPoints()
	if SuperMacroPlusFrame.savedPoint then
		local saved=SuperMacroPlusFrame.savedPoint;
		SuperMacroPlusFrame:SetPoint(saved.point or "TOPLEFT", saved.relativeTo, saved.relativePoint or "TOPLEFT", saved.x, saved.y)
	elseif SMP_PFUI_SKINNED then
		SuperMacroPlusFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	else
		local y = (math.floor(UIParent:GetTop()) - SuperMacroPlusFrame:GetHeight()) / 2
		SuperMacroPlusFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", 0, -y)
	end
end

function SuperMacroPlusFrame_OnHide()
	-- Closing or replacing the macro window is a cancellation, not a valid drop.
	-- Clear the tracked cursor as well as the native carrier cursor.
	if ( SMP_GetCursorMacroData and SMP_GetCursorMacroData() ) then
		ClearCursor();
	end
	local point,relativeTo,relativePoint,x,y=SuperMacroPlusFrame:GetPoint();
	SuperMacroPlusFrame.savedPoint = {
		point=point,
		relativeTo=relativeTo,
		relativePoint=relativePoint,
		x=x,
		y=y
	};
	
	-- Clear focus from all edit boxes to prevent crash when closing with Escape
	SuperMacroPlusFrameText:ClearFocus();
	SuperMacroPlusFrameSuperText:ClearFocus();
	SuperMacroPlusFrameExtendText:ClearFocus();

	SuperMacroPlusPopupFrame:Hide();
	SuperMacroPlusOptionsFrame:Hide();

	-- Hide ColorPickerFrame if it's open to prevent crash
	if ColorPickerFrame:IsVisible() then
		ColorPickerFrame:Hide();
	end
	
	SuperMacroPlusFrame_SaveSuperMacroPlus();
	PlaySound("igCharacterInfoClose");
	SuperMacroPlusRunAllExtend()
end

function SuperMacroPlusFrame_SetAccountMacros()
	local numAccountMacros, numCharacterMacros = GetNumMacros();
	if ( numAccountMacros > 0 ) then
		SuperMacroPlusFrame_SelectMacro(1);
	else
		SuperMacroPlusFrame_SetCharacterMacros();
	end
end

function SuperMacroPlusFrame_SetCharacterMacros()
	local numAccountMacros, numCharacterMacros = GetNumMacros();
	if ( numCharacterMacros > 0 ) then
		SuperMacroPlusFrame_SelectMacro(19);
	else
		SuperMacroPlusFrame_SelectMacro(nil);
	end
end

function SuperMacroPlusFrame_ShowFrame( tab )
	SuperMacroPlusFrameRegularFrame:Hide();
	SMP_ORDERED=SortSuperMacroPlusList(SMP_GetCurrentCategory());
	SuperMacroPlusFrameSuperFrame:Show();
end

function SuperMacroPlusFrame_Update()
	-- SuperMacroPlus exposes category tabs only; every managed macro is a Super macro.
	SMP_VARS.tabShown="super";
	-- determine to show regular or super macros from SMP_VARS.tabShown
-- START show regular frame
	if ( SMP_VARS.tabShown=="regular" ) then
	SuperMacroPlusFrame_ShowFrame("regular");
	local numMacros;
	local numAccountMacros, numCharacterMacros = GetNumMacros();
	local macroButton, macroIcon, macroName;
	local name, texture, body, isLocal;
	local selectedName, selectedBody, selectedIcon;

	-- Disable Buttons
	if ( SuperMacroPlusPopupFrame:IsVisible() ) then
		SuperMacroPlusEditButton:Disable();
		SuperMacroPlusDeleteButton:Disable();
		SuperMacroPlusSaveButton:Disable();
	else
		SuperMacroPlusEditButton:Enable();
		SuperMacroPlusDeleteButton:Enable();
		SuperMacroPlusSaveButton:Enable();
	end

	if ( not SuperMacroPlusFrame.selectedMacro or (numAccountMacros+numCharacterMacros==0)  ) then
		SuperMacroPlusDeleteButton:Disable();
		SuperMacroPlusEditButton:Disable();
		SuperMacroPlusSaveButton:Disable();
		SuperMacroPlusFrameSelectedMacroName:SetText('');
		SuperMacroPlusFrameText:SetText('');
		SuperMacroPlusFrameSelectedMacroButtonIcon:SetTexture('');
	end
	
	-- Macro List
	for j=0, SMP_MAX_MACROS, SMP_MAX_MACROS do
		if ( j == 0 ) then
			numMacros = numAccountMacros;
		else
			numMacros = numCharacterMacros;
		end
	for i=1, SMP_MAX_MACROS do
		local macroID = i+j;
		getglobal("SuperMacroPlusButton"..macroID.."ID"):SetText(macroID);
		macroButton = getglobal("SuperMacroPlusButton"..macroID);
		macroIcon = getglobal("SuperMacroPlusButton"..macroID.."Icon");
		macroName = getglobal("SuperMacroPlusButton"..macroID.."Name");
		if ( i <= numMacros ) then
			name, texture, body, isLocal = GetMacroInfo(macroID);
			macroButton:SetID(macroID);
			macroIcon:SetTexture(texture);
			macroName:SetText(name);
			macroButton:Enable();
			-- Highlight Selected Macro
			if ( macroID == SuperMacroPlusFrame.selectedMacro ) then
				macroButton:SetChecked(1);
    				SuperMacroPlusFrameSelectedMacroName:SetText(name);
					SuperMacroPlusFrameText:SetText(body);
					SuperMacroPlusFrameSelectedMacroButton:SetID(macroID);				
    				SuperMacroPlusFrameSelectedMacroButtonIcon:SetTexture(texture);
			else
				macroButton:SetChecked(0);
			end
		else
			macroButton:SetChecked(0);
			macroIcon:SetTexture("");
			macroName:SetText("");
			macroButton:Disable();
		end
	end
	end
	
	--Update New Button
	if ( numAccountMacros == SMP_MAX_MACROS ) then
		SuperMacroPlusNewAccountButton:Disable();
	else
		SuperMacroPlusNewAccountButton:Enable();
	end
	if ( numCharacterMacros == SMP_MAX_MACROS ) then
		SuperMacroPlusNewCharacterButton:Disable();
	else
		SuperMacroPlusNewCharacterButton:Enable();
	end
	
	end
-- END update regular frame

-- START show super frame
	if ( SMP_VARS.tabShown=="super" ) then
	SuperMacroPlusFrame_ShowFrame("super");
	local numMacros=GetNumSuperMacrosPlus();
	local macroButton, macroIcon, macroName;
	local name, texture, body;
	local category=SMP_GetCurrentCategory();
	SuperMacroPlusFrameTitle:SetText(SUPERMACROPLUS_TITLE.." "..SUPERMACROPLUS_VERSION.." - "..SMP_GetCategoryLabel(category).." ("..numMacros.."/"..SMP_CATEGORY_MAX_MACROS..")");
	if ( SuperMacroPlusFrame.selectedSuper and SuperMacroPlusFrame.selectedSuper>numMacros ) then
		SuperMacroPlusFrame.selectedSuper=nil;
	end
	if ( SuperMacroPlusFrame.selectedSuper ) then
		local selectedName, selectedTexture, selectedBody=GetOrderedSuperMacroPlusInfo(SuperMacroPlusFrame.selectedSuper);
		if ( selectedName ) then
			SuperMacroPlusFrameSelectedMacroName:SetText(selectedName);
			SuperMacroPlusFrameSuperText:SetText(selectedBody);
			SuperMacroPlusFrameSelectedMacroSuperButtonIcon:SetTexture(selectedTexture);
		end
	end

	-- Disable Buttons
	if ( SuperMacroPlusPopupFrame:IsVisible() ) then
		SuperMacroPlusNewSuperButton:Disable();
		SuperMacroPlusSaveSuperButton:Disable();
		SuperMacroPlusDeleteSuperButton:Disable();
		SuperMacroPlusEditButton:Disable();
	else
		if ( numMacros>=SMP_CATEGORY_MAX_MACROS ) then
			SuperMacroPlusNewSuperButton:Disable();
		else
			SuperMacroPlusNewSuperButton:Enable();
		end
		SuperMacroPlusSaveSuperButton:Enable();
		SuperMacroPlusDeleteSuperButton:Enable();
		SuperMacroPlusEditButton:Enable();
	end
	
	if ( not SuperMacroPlusFrame.selectedSuper or numMacros==0) then
	--[[
		SuperMacroPlusSaveSuperButton:Enable();
		SuperMacroPlusDeleteSuperButton:Enable();
		SuperMacroPlusEditButton:Enable();
	else
	--]]
		SuperMacroPlusSaveSuperButton:Disable();
		SuperMacroPlusDeleteSuperButton:Disable();
		SuperMacroPlusEditButton:Disable();
		SuperMacroPlusFrameSelectedMacroName:SetText('');
		SuperMacroPlusFrameSuperText:SetText('');
		SuperMacroPlusFrameSelectedMacroSuperButtonIcon:SetTexture('');
	end
	
	-- Macro List
	local offset=FauxScrollFrame_GetOffset(SuperMacroPlusFrameSuperScrollFrame);
	local firstmacro = offset*SMP_MACRO_COLUMNS+1;
	local lastmacro = firstmacro + SMP_MACRO_ROWS*SMP_MACRO_COLUMNS -1;
	
	for i=1, SMP_MACROS_SUPER_SHOWN do
		getglobal("SuperMacroPlusSuperButton"..i.."ID"):SetText(firstmacro+i-1);
		macroButton = getglobal("SuperMacroPlusSuperButton"..i);
		macroIcon = getglobal("SuperMacroPlusSuperButton"..i.."Icon");
		macroName = getglobal("SuperMacroPlusSuperButton"..i.."Name");
		local macroID = firstmacro+i-1;
		macroButton:SetID(macroID);
		if ( macroID <= numMacros ) then
			name, texture, body = GetOrderedSuperMacroPlusInfo(macroID);
			macroButton.smpEmpty=nil;
			macroIcon:SetTexture(texture);
			macroName:SetText(name);
			macroButton:Enable();
			-- Highlight Selected Macro
			if ( macroID == SuperMacroPlusFrame.selectedSuper ) then
				macroButton:SetChecked(1);
			else
				macroButton:SetChecked(0);
			end
		else
			macroButton.smpEmpty=1;
			macroButton:SetChecked(0);
			macroIcon:SetTexture("");
			macroName:SetText("");
			-- Empty buttons remain enabled so they can receive external macro drags.
			macroButton:Enable();
		end
	end

	-- Scroll frame stuff
	-- Keep all five logical rows scrollable, including empty slots 31-50.
	FauxScrollFrame_Update(SuperMacroPlusFrameSuperScrollFrame, ceil(SMP_CATEGORY_MAX_MACROS/SMP_MACRO_COLUMNS), SMP_MACRO_ROWS, SMP_MACRO_ROW_HEIGHT );
	
	end
-- END update super frame
end

function SuperMacroPlusFrame_AddMacroLine(line)
	if ( SuperMacroPlusFrameText:IsVisible() ) then
		SuperMacroPlusFrameText:SetText(SuperMacroPlusFrameText:GetText()..line);
	end
end

function SuperMacroPlusButton_OnClick( button )
	local id=this:GetID();
	SuperMacroPlusFrame_SaveMacro();
	SuperMacroPlusFrame_SelectMacro(id);
	SuperMacroPlusFrame_Update();
	SuperMacroPlusPopupFrame:Hide();
	SuperMacroPlusFrameText:ClearFocus();
	if ( button=="RightButton" ) then
		SuperMacroPlus_RunMacro(id);
	end
	SuperMacroPlusSelectExtend(SuperMacroPlusFrameSelectedMacroName:GetText())
end

function SuperMacroPlusSuperButton_OnClick( button )
	if ( this.smpEmpty ) then
		-- In addition to OnReceiveDrag, accept a click while a tracked macro is
		-- on the cursor. This keeps cross-category moves working on clients that
		-- stop emitting OnReceiveDrag after a category-tab click.
		if ( button=="LeftButton" and SMP_GetCursorMacroData and SMP_GetCursorMacroData() ) then
			SuperMacroPlusSuperButton_OnReceiveDrag();
		end
		return;
	end
	local id=this:GetID();
	SuperMacroPlusFrame_SaveSuperMacroPlus();
	SuperMacroPlusFrame_SelectSuperMacroPlus(id);
	SuperMacroPlusFrame_Update();
	SuperMacroPlusPopupFrame:Hide();
	SuperMacroPlusFrameSuperText:ClearFocus();
	if ( button=="RightButton" ) then
		RunSuperMacroPlus(id);
	end
end

function SuperMacroPlusSuperButton_OnReceiveDrag()
	local source=SMP_GetCursorMacroData and SMP_GetCursorMacroData();
	if ( not source or not source.name ) then
		-- A click fallback may already have completed this same drop. Only show
		-- the error while the destination is still an empty slot.
		if ( this.smpEmpty ) then SMP_PrintError(SMP_DROP_NOT_MACRO); end
		return;
	end

	local targetID=this:GetID();
	local numMacros=GetNumSuperMacrosPlus();
	if ( targetID<=numMacros ) then
		local targetName=GetOrderedSuperMacroPlusInfo(targetID);
		if ( source.kind=="plus" and source.name==targetName ) then
			ClearCursor();
			SuperMacroPlusFrame_SelectSuperMacroPlus(targetID);
			SuperMacroPlusFrame_Update();
			return;
		end
		SMP_PrintError(format(SMP_DROP_SLOT_OCCUPIED, targetName or targetID));
		return;
	end

	local category=SMP_GetCurrentCategory();
	if ( SMP_GetCategoryMacroCount(category)>=SMP_CATEGORY_MAX_MACROS ) then
		SMP_PrintCategoryFull();
		return;
	end

	local existing=SMP_SUPER[source.name];
	if ( existing ) then
		if ( source.kind=="plus" and existing[4]~=category ) then
			existing[4]=category;
			SMP_ORDERED=SortSuperMacroPlusList(category);
			local id=GetOrderedSuperMacroPlus(source.name);
			ClearCursor();
			SuperMacroPlusFrame_SelectSuperMacroPlus(id);
			SuperMacroPlusFrame_Update();
			SMP_PrintMessage(format(SMP_DROP_MOVED, source.name, SMP_GetCategoryLabel(category)));
			return;
		end
		ClearCursor();
		if ( existing[4]==category ) then
			local id=GetOrderedSuperMacroPlus(source.name);
			SuperMacroPlusFrame_SelectSuperMacroPlus(id);
			SuperMacroPlusFrame_Update();
		end
		SMP_PrintError(format(SMP_DROP_EXISTS, source.name, SMP_GetCategoryLabel(existing[4])));
		return;
	end

	local id=CreateSuperMacroPlus(source.name, source.texture, source.body, category);
	if ( not id ) then return; end
	ClearCursor();
	SuperMacroPlusFrame_SelectSuperMacroPlus(id);
	SuperMacroPlusFrame_Update();
	SMP_PrintMessage(format(SMP_DROP_IMPORTED, source.name, SMP_GetCategoryLabel(category)));
end

function SuperMacroPlusFrame_SelectSuperMacroPlus(id)
	SuperMacroPlusFrame.selectedSuper = id;
	if ( not id or not SuperMacroPlusFrameSuperScrollFrame ) then return; end
	local offset=FauxScrollFrame_GetOffset(SuperMacroPlusFrameSuperScrollFrame);
	local row=ceil(id/SMP_MACRO_COLUMNS);
	local targetOffset=offset;
	if ( row<=offset ) then
		targetOffset=row-1;
	elseif ( row>offset+SMP_MACRO_ROWS ) then
		targetOffset=row-SMP_MACRO_ROWS;
	end
	if ( targetOffset<0 ) then targetOffset=0; end
	if ( targetOffset~=offset ) then
		FauxScrollFrame_SetOffset(SuperMacroPlusFrameSuperScrollFrame, targetOffset);
		SuperMacroPlusFrameSuperScrollFrameScrollBar:SetValue(targetOffset*SMP_MACRO_ROW_HEIGHT);
	end
end

function SuperMacroPlusFrame_SelectMacro(id)
	SuperMacroPlusFrame.selectedMacro = id;
end

function SuperMacroPlusNewAccountButton_OnClick()
	SuperMacroPlusFrame_SaveMacro();
	SuperMacroPlusPopupFrame.mode = "newaccount";
	SuperMacroPlusPopupFrame:Show();
end

function SuperMacroPlusNewCharacterButton_OnClick()
	SuperMacroPlusFrame_SaveMacro();
	SuperMacroPlusPopupFrame.mode = "newcharacter";
	SuperMacroPlusPopupFrame:Show();
end

function SuperMacroPlusNewSuperButton_OnClick()
	SuperMacroPlusFrame_SaveSuperMacroPlus();
	if ( SMP_GetCategoryMacroCount()>=SMP_CATEGORY_MAX_MACROS ) then
		SMP_PrintCategoryFull();
		return;
	end
	SuperMacroPlusPopupFrame.mode = "newsuper";
	SuperMacroPlusPopupFrame:Show();
end

function SuperMacroPlusEditButton_OnClick()
	SuperMacroPlusFrame_SaveSuperMacroPlus();
	SuperMacroPlusPopupFrame.mode = "edit";
	SuperMacroPlusPopupFrame.oldname=SuperMacroPlusFrameSelectedMacroName:GetText();
	SuperMacroPlusPopupFrame:Show();
end

function SuperMacroPlusFrame_HideDetails()
	SuperMacroPlusEditButton:Hide();
	SuperMacroPlusFrameCharLimitText:Hide();
	SuperMacroPlusFrameText:Hide();
	SuperMacroPlusFrameSelectedMacroName:Hide();
	SuperMacroPlusFrameSelectedMacroBackground:Hide();
	SuperMacroPlusFrameSelectedMacroButton:Hide();
end

function SuperMacroPlusFrame_ShowDetails()
	SuperMacroPlusEditButton:Show();
	SuperMacroPlusFrameCharLimitText:Show();
	SuperMacroPlusFrameEnterMacroText:Show();
	SuperMacroPlusFrameText:Show();
	SuperMacroPlusFrameSelectedMacroName:Show();
	SuperMacroPlusFrameSelectedMacroBackground:Show();
	SuperMacroPlusFrameSelectedMacroButton:Show();
end

function SuperMacroPlusPopupFrame_OnShow()
	SuperMacroPlusPopupFrame:ClearAllPoints()
	if SMP_PFUI_SKINNED then
		SuperMacroPlusPopupFrame:SetPoint("TOPRIGHT", "SuperMacroPlusFrame", "TOPRIGHT", -20, -35)
	elseif SuperMacroPlusFrame:GetWidth() > 800 then
		SuperMacroPlusPopupFrame:SetPoint("TOPRIGHT", "SuperMacroPlusFrame", "TOPRIGHT", -60, -10)
	else
		SuperMacroPlusPopupFrame:SetPoint("TOPLEFT", "SuperMacroPlusFrame", "TOPRIGHT", -40, -40)
	end
	if ( this.mode == "newaccount" or this.mode == "newcharacter" ) then
		SuperMacroPlusFrameText:Hide();
		SuperMacroPlusFrameSelectedMacroButtonIcon:SetTexture("");
		SuperMacroPlusPopupFrame.selectedIcon = nil;
	elseif ( this.mode == "newsuper" ) then
		SuperMacroPlusFrameSuperText:Hide();
		SuperMacroPlusFrameSelectedMacroSuperButtonIcon:SetTexture("");
		SuperMacroPlusPopupFrame.selectedIcon = nil;
	end
	SuperMacroPlusFrameText:ClearFocus();
	SuperMacroPlusFrameSuperText:ClearFocus();
	SuperMacroPlusPopupEditBox:SetFocus();

	PlaySound("igCharacterInfoOpen");
	SuperMacroPlusPopupFrame_Update();
	SuperMacroPlusPopupOkayButton_Update();

	-- Disable Buttons
	SuperMacroPlusEditButton:Disable();
	SuperMacroPlusDeleteButton:Disable();
	SuperMacroPlusNewAccountButton:Disable();
	SuperMacroPlusNewCharacterButton:Disable();
end

function SuperMacroPlusPopupFrame_OnHide()
	PlaySound("igCharacterInfoClose");
	if ( this.mode == "newaccount" or this.mode == "newcharacter" ) then
		SuperMacroPlusFrameText:Show();
		SuperMacroPlusFrameText:SetFocus();
	elseif ( this.mode == "newsuper" ) then
		SuperMacroPlusFrameSuperText:Show();
		SuperMacroPlusFrameSuperText:SetFocus();
	end
	
	SuperMacroPlusFrame_Update();
end

function SuperMacroPlusPopupFrame_Update()
	local numMacroIcons = GetNumMacroIcons();
	local macroPopupIcon, macroPopupButton;
	local macroPopupOffset = FauxScrollFrame_GetOffset( SuperMacroPlusPopupScrollFrame );
	local index;
	
	-- Determine whether we're creating a new macro or editing an existing one
	if ( this.mode == "newaccount" or this.mode == "newcharacter" ) then
		SuperMacroPlusPopupEditBox:SetText("");
	elseif ( this.mode == "newsuper" ) then
		SuperMacroPlusPopupEditBox:SetText("");
	elseif ( this.mode == "edit" ) then
		local name;
		if ( SMP_VARS.tabShown=="regular") then
		name = GetMacroInfo(SuperMacroPlusFrame.selectedMacro);
		elseif ( SMP_VARS.tabShown=="super" ) then
			name = GetOrderedSuperMacroPlusInfo(SuperMacroPlusFrame.selectedSuper);
		end
		SuperMacroPlusPopupEditBox:SetText(name);
	end
	
	-- Icon list
	for i=1, SMP_NUM_MACRO_ICONS_SHOWN do
		macroPopupIcon = getglobal("SuperMacroPlusPopupButton"..i.."Icon");
		macroPopupButton = getglobal("SuperMacroPlusPopupButton"..i);
		index = (macroPopupOffset * SMP_NUM_ICONS_PER_ROW) + i;
		if ( index <= numMacroIcons ) then
			macroPopupIcon:SetTexture(GetMacroIconInfo(index));
			macroPopupButton:Show();
		else
			macroPopupIcon:SetTexture("");
			macroPopupButton:Hide();
		end
		if ( index == SuperMacroPlusPopupFrame.selectedIcon ) then
			macroPopupButton:SetChecked(1);
		else
			macroPopupButton:SetChecked(nil);
		end
	end
	
	-- Scrollbar stuff
	FauxScrollFrame_Update(SuperMacroPlusPopupScrollFrame, ceil(numMacroIcons / SMP_NUM_ICONS_PER_ROW) , SMP_NUM_ICON_ROWS, SMP_MACRO_ICON_ROW_HEIGHT );
end

function SuperMacroPlusPopupOkayButton_Update()
	if ( (strlen(SuperMacroPlusPopupEditBox:GetText()) > 0) and SuperMacroPlusPopupFrame.selectedIcon ) then
		SuperMacroPlusPopupOkayButton:Enable();
	else
		SuperMacroPlusPopupOkayButton:Disable();
	end
	if ( SuperMacroPlusPopupFrame.mode == "edit" and (strlen(SuperMacroPlusPopupEditBox:GetText()) > 0) ) then
		SuperMacroPlusPopupOkayButton:Enable();
	end
end

function SuperMacroPlusPopupButton_OnClick()
	SuperMacroPlusPopupFrame.selectedIcon = this:GetID() + (FauxScrollFrame_GetOffset(SuperMacroPlusPopupScrollFrame) * SMP_NUM_ICONS_PER_ROW);
	if ( SMP_VARS.tabShown=="regular" ) then
		SuperMacroPlusFrameSelectedMacroButtonIcon:SetTexture( GetMacroIconInfo(SuperMacroPlusPopupFrame.selectedIcon));
	elseif ( SMP_VARS.tabShown=="super" ) then
		SuperMacroPlusFrameSelectedMacroSuperButtonIcon:SetTexture( GetMacroIconInfo(SuperMacroPlusPopupFrame.selectedIcon));
	end
	SuperMacroPlusPopupOkayButton_Update();
	SuperMacroPlusPopupFrame_Update();
end

function SuperMacroPlusPopupOkayButton_OnClick()
	local index = 1;
	local texture=SuperMacroPlusFrameSelectedMacroSuperButtonIcon:GetTexture();
	local macroname=SuperMacroPlusPopupEditBox:GetText();
	if ( SuperMacroPlusPopupFrame.mode == "newaccount" ) then
		index = CreateMacro(macroname, SuperMacroPlusPopupFrame.selectedIcon, nil, nil, false );
		SuperMacroPlusFrame_SelectMacro(index);
	elseif ( SuperMacroPlusPopupFrame.mode == "newcharacter" ) then
		index = CreateMacro(macroname, SuperMacroPlusPopupFrame.selectedIcon, nil, nil, true );
		SuperMacroPlusFrame_SelectMacro(index);
	elseif ( SuperMacroPlusPopupFrame.mode == "newsuper" ) then
		if ( SMP_SUPER[macroname] ) then
			SMP_PrintError(format(SMP_DUPLICATE_MACRO, macroname));
			return;
		end
		if ( SMP_GetCategoryMacroCount()>=SMP_CATEGORY_MAX_MACROS ) then
			SMP_PrintCategoryFull();
			return;
		end
		index = CreateSuperMacroPlus(macroname, texture, '', SMP_GetCurrentCategory());
		SuperMacroPlusFrame_SelectSuperMacroPlus(index);
	elseif ( SuperMacroPlusPopupFrame.mode == "edit" ) then
		if ( SMP_VARS.tabShown=="regular" ) then
			if SuperMacroPlusPopupFrame.oldname ~= macroname then
				SuperMacroPlusCopyExtend(SuperMacroPlusPopupFrame.oldname, macroname)
				if not SMP_SameMacroName() then
					SuperMacroPlusDeleteExtend(SuperMacroPlusPopupFrame.oldname)
				end
			end
			index = EditMacro(SuperMacroPlusFrame.selectedMacro, macroname, SuperMacroPlusPopupFrame.selectedIcon);
			if ( GetMacroIndexByName(SuperMacroPlusPopupFrame.oldname)==0 ) then
				SMP_UpdateActionSpell(SuperMacroPlusPopupFrame.oldname, "regular", '');
			end
			SMP_UpdateActionSpell(macroname, "regular", GetMacroInfo(index, "body"));
			SuperMacroPlusFrame_SelectMacro(index);
		elseif ( SMP_VARS.tabShown=="super" ) then
			if ( macroname~=SuperMacroPlusPopupFrame.oldname and SMP_SUPER[macroname] ) then
				SMP_PrintError(format(SMP_DUPLICATE_MACRO, macroname));
				return;
			end
			index = EditSuperMacroPlus(SuperMacroPlusFrame.selectedSuper, macroname, texture);
			SuperMacroPlusFrame_SelectSuperMacroPlus(index);
		end
	end
	SuperMacroPlusPopupFrame:Hide();
	SuperMacroPlusFrame_Update();
end

function SuperMacroPlusOptionsButton_OnClick()
	if ( SuperMacroPlusOptionsFrame:IsVisible() ) then
		SuperMacroPlusOptionsFrame:Hide()
	else
		SuperMacroPlusOptionsFrame:Show()
	end
end

function SuperMacroPlusFrame_SaveMacro()
	if ( SuperMacroPlusFrame.textChanged and SuperMacroPlusFrame.selectedMacro ) then
		EditMacro(SuperMacroPlusFrame.selectedMacro, nil, nil, SuperMacroPlusFrameText:GetText());
		SuperMacroPlusFrame.textChanged = nil;
		SMP_UpdateActionSpell( GetMacroInfo(SuperMacroPlusFrame.selectedMacro, "name"), "regular", SuperMacroPlusFrameText:GetText());
	end
end

function SuperMacroPlusFrame_SaveSuperMacroPlus()
	if ( SuperMacroPlusFrame.textChanged and SuperMacroPlusFrame.selectedSuper ) then
		local macroName = SMP_SelectedMacroName();
		local macroTexture = SuperMacroPlusFrameSelectedMacroSuperButtonIcon:GetTexture();
		local macroBody = SuperMacroPlusFrameSuperText:GetText();
		SMP_SUPER[macroName] = {macroName,macroTexture,macroBody,SMP_GetCurrentCategory()};
		SuperMacroPlusFrame.textChanged = nil;
		SMP_UpdateActionSpell(macroName, "super", macroBody);
		SMP_NotifyMacroChanged(macroName);
	end
end

function SuperMacroPlusFrame_OnEvent(event)
	if ( event=="TRADE_SKILL_SHOW") then
		if ( not old_SMP_TradeSkillSkillButton_OnClick) then
			old_SMP_TradeSkillSkillButton_OnClick = TradeSkillSkillButton_OnClick;
			TradeSkillSkillButton_OnClick = SMP_TradeSkillSkillButton_OnClick;
			SMP_TradeSkillItem_OnClick();
		end
	end
	if ( event=="CRAFT_SHOW") then
		if ( not old_SMP_CraftButton_OnClick) then
			old_SMP_CraftButton_OnClick = CraftButton_OnClick;
			CraftButton_OnClick = SMP_CraftButton_OnClick;
			SMP_CraftItem_OnClick();
		end
	end
	if ( event=="SPELLS_CHANGED" or event=="CHARACTER_POINTS_CHANGED" or event=="PLAYER_TALENT_UPDATE" ) then
		-- Talent swaps can remove and later restore spells. Rebuild only the
		-- derived spell/item cache; macro bodies and action mappings stay intact.
		SMP_UpdateActionSpell();
		SMP_NotifyMacroChanged(nil);
	end
	if ( event=="VARIABLES_LOADED" ) then
		if ( not SMP_VARS.hideAction ) then
			SMP_VARS.hideAction = 0;
		end
		if ( not SMP_VARS.printColor ) then
			SMP_VARS.printColor = SMP_PRINT_COLOR_DEF;
		end
		if ( not SMP_VARS.macroTip1 ) then
			SMP_VARS.macroTip1= 1;
		end
		if ( not SMP_VARS.macroTip2 ) then
			SMP_VARS.macroTip2= 0;
		end
		if ( not SMP_VARS.minimap ) then
			SMP_VARS.minimap = 1;
		end
		if ( not SMP_VARS.showMenu ) then
			SMP_VARS.showMenu = 1;
		end
		if ( not SMP_VARS.wordWrap ) then
			SMP_VARS.wordWrap = 0;
		end
		if ( not SMP_VARS.replaceIcon ) then
			SMP_VARS.replaceIcon = 1;
		end
		if ( not SMP_VARS.checkCooldown ) then
			SMP_VARS.checkCooldown = 1;
		end
		SMP_VARS.tabShown = "super";
		if ( not SMP_VARS.category or not SMP_IsValidCategory(SMP_VARS.category) ) then
			SMP_VARS.category = SMP_DEFAULT_CATEGORY;
		end
		if ( not SMP_VARS.monoFont ) then
			SMP_VARS.monoFont = 0;
		end
		if ( not SMP_VARS.windowWidth ) then
			SMP_VARS.windowWidth = 620;
		end
		if ( not SMP_VARS.windowHeight ) then
			SMP_VARS.windowHeight = 520;
		end
		if ( not SMP_VARS.editBoxFontSize ) then
			SMP_VARS.editBoxFontSize = 12;
		end
		SMP_InstallDoiteWarriorMacros();
		SMP_InitializeCategoryTabs();
		SMP_HideActionText();
		SMP_ToggleMinimap();
		SMP_ToggleMenu();
		SMP_ApplyPfUISkin();
		SMP_ToggleWordWrap();
		SuperMacroPlusInitExtend()
		SMP_ORDERED=SortSuperMacroPlusList(SMP_GetCurrentCategory());
		SuperMacroPlusFrame.selectedSuper=(getn(SMP_ORDERED)>0) and 1 or nil;
		SMP_PLAYER_KEY=UnitName("player").." of "..GetRealmName();
		if ( not SMP_ACTION_SUPER[SMP_PLAYER_KEY] ) then
			SMP_ACTION_SUPER[SMP_PLAYER_KEY]={};
		end
		SMP_ACTION=SMP_ACTION_SUPER[SMP_PLAYER_KEY];
		if ( SMP_RebuildActionRecovery ) then SMP_RebuildActionRecovery(); end
		SMP_UpdateActionSpell();

		-- update alias replacement function
		-- ASF aka Alias-Spellchecker-Filter
		if (ReplaceAlias and ASFOptions.aliasOn) then
			SMP_InsertAliasFunction(ReplaceAlias);
		end
		-- ChatAlias
		if (CA_ParseMessage) then
			SMP_InsertAliasFunction(ReplaceAlias, -1);
			-- this messes up newlines, so should not run during RunMacro
		end
		-- for any other alias addons, do SMP_InsertAliasFunction(ReplaceAlias, -1); inside your mod
		SuperMacroPlusInitFrames()
		SuperMacroPlusFrame_Update();
	end
	if ( event=="PLAYER_ENTERING_WORLD" ) then
		SMP_ApplyPfUISkin();
		if ( SMP_RebuildActionRecovery ) then SMP_RebuildActionRecovery(); end
		SMP_UpdateActionSpell();
	end
	if ( event=="PLAYER_LEAVING_WORLD" ) then
		if ( SMP_PLAYER_KEY ) then
			SMP_ACTION_SUPER[SMP_PLAYER_KEY]=SMP_ACTION;
		end
	end
end

-- Internal namespaced function - use this for all internal calls
-- This ensures internal logic won't break if another addon overwrites RunMacro
function SuperMacroPlus_RunMacro(index)
	-- close edit boxes, then enter body line by line
	if ( SuperMacroPlusFrame_SaveMacro ) then
		SuperMacroPlusFrame_SaveMacro();
	end
	if ( MacroFrame_SaveMacro ) then
		MacroFrame_SaveMacro();
	end
	local body;
	if ( type(index) == "number" ) then
		body = GetMacroInfo(index, "body");
	elseif ( type(index) == "string" ) then
		body = GetMacroInfo(GetMacroIndexByName(index),"body");
	end
	if ( not body ) then return; end

	if ( ChatFrameEditBox:IsVisible() ) then
		ChatEdit_OnEscapePressed(ChatFrameEditBox);
	end

	body = SMP_ReplaceAlias(body);

	--SMP_MacroRunning = true;
	while ( strlen(body)>0 ) do
		local block, line;
		body, block, line=SMP_FindBlock(body);
		if ( block ) then
			RunScript(block);
		else
			SMP_RunLine(line);
		end
	end
	--SMP_MacroRunning = nil;
end

-- Global wrapper for user convenience (delegates to namespaced internal function)
function RunMacroPlusRegular(index)
	return SuperMacroPlus_RunMacro(index)
end

MacroPlus=SuperMacroPlus_RunMacro;

function RunSuperMacroPlus(index)
	if ( SuperMacroPlusFrame_SaveSuperMacroPlus ) then
		SuperMacroPlusFrame_SaveSuperMacroPlus();
	end
	local _,body=nil;
	if ( type(index)=="number") then
		_,_,body = GetOrderedSuperMacroPlusInfo(index);
	elseif ( type(index) == "string" ) then
		body = GetSuperMacroPlusInfo(index,"body");
	end
	if ( not body ) then return; end

	if ( ChatFrameEditBox:IsVisible() ) then
		ChatEdit_OnEscapePressed(ChatFrameEditBox);
	end

	body = SMP_ReplaceAlias(body);

	while ( strlen(body)>0 ) do
		local block, line;
		body, block, line=SMP_FindBlock(body);
		if ( block ) then
			RunScript(block);
		else
			SMP_RunLine(line);
		end
	end
end

function SMP_FindBlock(body)
	local a,b,block=strfind(body,"^/script (%-%-%-%-%[%[.-%-%-%-%-%]%])[\n]*");
	if ( block ) then
		body=strsub(body,b+1);
		return body, block;
	end
	local a,b,line=strfind(body,"^([^\n]*)[\n]*");
	if ( line ) then
		body=strsub(body,b+1);
		return body, nil, line;
	end
end

function SMP_RunBody(text)
	local body=text;
	local length = strlen(body);
	for w in string.gfind(body, "[^\n]+") do
		SMP_RunLine(w);
	end
end

function SMP_RunLine(...)
-- execute a line in a macro
-- if script or cast, then rectify and RunScript
-- else send to chat edit box
	for k=1,arg.n do
		local text=arg[k];
		
		-- replace aliases
		text = SMP_ReplaceAlias(text, -1);
		
		if not CleveRoids and ( string.find(text, "^/cast") ) then
			local i, book = SMP_FindSpell(gsub(text,"^%s*/cast%s*(%w.*[%w%)])%s*$","%1"));
			if ( i ) then
				CastSpell(i,book);
			end
		elseif ( string.find(text, "^/use%s") or string.find(text, "^/equip%s") ) then
			local item = gsub(text, "^/%S+%s+(.*)", "%1");
			if ( strlen(item) > 0 ) then
				use(item);
			end
		else
			if ( string.find(text,"^/script ")) then
				RunScript(gsub(text,"^/script ",""));
			else
				text = gsub( text, "\n", ""); -- cannot send newlines, will disconnect
				ChatFrameEditBox:SetText(text);
				ChatEdit_SendText(ChatFrameEditBox);
			end
		end
	end -- for
end -- SMP_RunLine()
	
function SMP_ReplaceAlias(body, after)
	local size, step;
	if ( after==-1 ) then
		size, step = SMP_AliasFunctions.low, -1;
	else
		size, step = SMP_AliasFunctions.high, 1;
	end
	for i=step, size, step do
		body = SMP_AliasFunctions[i](body);
	end
	return body;
end

function SMP_InsertAliasFunction(func, pos)
	if ( pos==-1 ) then
		SMP_AliasFunctions.low = SMP_AliasFunctions.low - 1;
		SMP_AliasFunctions[SMP_AliasFunctions.low]=func;
		return SMP_AliasFunctions.low;
	else
		SMP_AliasFunctions.high = SMP_AliasFunctions.high + 1;
		SMP_AliasFunctions[SMP_AliasFunctions.high]=func;
		return SMP_AliasFunctions.high;
	end
end

function SMP_FindSpell(spell)
	local s = gsub(spell, "%s*(.*)%s*%(.*","%1");
	local r="";
	local num = tonumber(gsub( spell, "%D*(%d+)%D*", "%1"),10);
	if ( string.find(spell, "%(%s*[Rr]acial")) then
		r = "racial"
	elseif ( string.find(spell, "%(%s*[Ss]ummon")) then
		r = "summon"
	elseif ( string.find(spell, "%(%s*[Aa]pprentice")) then
		r = "apprentice"
	elseif ( string.find(spell, "%(%s*[Jj]ourneyman")) then
		r = "journeyman"
	elseif ( string.find(spell, "%(%s*[Ee]xpert")) then
		r = "expert"
	elseif ( string.find(spell, "%(%s*[Aa]rtisan")) then
		r = "artisan"
	elseif ( string.find(spell, "%(%s*[Mm]aster")) then
		r = "master"
	elseif ( string.find(spell, "%(%s*[Mm]inor")) then
		s=s.."(Minor)";
	elseif ( string.find(spell, "%(%s*[Ll]esser")) then
		s=s.."(Lesser)";
	elseif ( string.find(spell, "%(%s*[Gg]reaterr")) then
		s=s.."(Greater)";
	elseif ( string.find(spell, "%(%s*[Ff]eral")) then
		s=s.."(Feral)";
	end
	if ( string.find(spell, "[Rr]ank%s*%d+") and num and num > 0) then
		r = gsub(spell, ".*%(.*[Rr]ank%s*(%d+).*", "Rank "..num);
	end
	return SMP_FindSpellExact(s,r);
end

function SMP_FindSpellExact(spell, rank)
	local i = 1;
	local booktype = { "spell", "pet", };
	local s,r;
	local ys, yr;
	for k, book in booktype do
		while spell do
		s, r = GetSpellName(i,book);
		if ( not s ) then
			i = 1;
			break;
		end
		if ( string.lower(s) == string.lower(spell)) then ys=true; end
		if ( (r == rank) or (r and rank and string.lower(r) == string.lower(rank))) then yr=true; end
		if ( rank=='' and ys and (not GetSpellName(i+1, book) or string.lower(GetSpellName(i+1, book)) ~= string.lower(spell) )) then
			yr = true; -- use highest spell rank if omitted
		end
		if ( ys and yr ) then
			return i,book;
		end
		i=i+1;
		ys = nil;
		yr = nil;
		end
	end
	return;
end


function SuperMacroPlusDeleteButton_OnClick()
-- check other macros with same name to see if save extend
	local macro=GetMacroInfo(SuperMacroPlusFrame.selectedMacro,"name");
	if not SMP_SameMacroName() then
		SuperMacroPlusDeleteExtend(macro); -- delete extend
	end
	DeleteMacro(SuperMacroPlusFrame.selectedMacro);
	SuperMacroPlusFrame_OnLoad();
	SuperMacroPlusFrame_Update();
	SuperMacroPlusFrameText:ClearFocus();
	SuperMacroPlusSelectExtend(GetMacroInfo(1,"name"))
end

function SuperMacroPlusDeleteSuperButton_OnClick()
	DeleteSuperMacroPlus(SuperMacroPlusFrame.selectedSuper);
	--SuperMacroPlusFrame_OnLoad();
	SuperMacroPlusFrame_Update();
	local name = GetOrderedSuperMacroPlusInfo(1);
	SuperMacroPlusFrameSuperText:ClearFocus();
end

function SMP_SameMacroName(macroindex)
	if ( not macroindex and SuperMacroPlusFrame.selectedMacro ) then
		macroindex = SuperMacroPlusFrame.selectedMacro;
	else
		return; -- error check for nil, no macro selected
	end
	local macro=GetMacroInfo(macroindex,"name");
	local prevmacro, nextmacro = GetMacroInfo(macroindex-1,"name"), GetMacroInfo(macroindex+1,"name");
	if ( prevmacro == macro ) then
		return macroindex-1;
	elseif ( nextmacro == macro ) then
		return macroindex+1;
	else
		return false; -- must check "==false"
		-- don't check "not SMP_SameMacroName()" unless error check or no macro selected
	end
end

function SMP_SelectedMacroName()
	return SuperMacroPlusFrameSelectedMacroName:GetText();
end

local oldGetMacroInfo=GetMacroInfo;
function GetMacroInfo(index, code)
	if ( not index ) then return; end
	-- code can be "name", "texture", "body", "islocal"
	local a={};
	a.name,a.texture,a.body,a.islocal=oldGetMacroInfo(index);
	if (not code) then
		return a.name,a.texture,a.body,a.islocal;
	else
		return a[code];
	end
end

function SetActionMacro( actionid , macro ) 
	local macroid = GetMacroIndexByName( macro )
	if ( macroid and actionid > 0 and actionid <= 120 ) then
		PickupAction( actionid );
		PickupMacro( macroid );
		PlaceAction ( actionid );
	end
end

function SMP_ToggleMinimap()
	if ( SMP_VARS.minimap == 1 ) then
		SuperMacroPlusMinimapButton:Show();
	else
		SuperMacroPlusMinimapButton:Hide();
	end
end

function SMP_UpdateAction()
	-- Update Macros on action bars
	local function doUpdate(button)
		if ( button ) then
			button:SetScript("OnLeave", SMP_ActionButton_OnLeave);
			local oldscript=button:GetScript("OnClick");
			button:SetScript("OnClick", function()
				if ( not SMP_ActionButton_OnClick() ) then
					oldscript();
				end
			end);
		end
	end
	for i=1,12 do
		doUpdate(getglobal("ActionButton"..i));
		doUpdate(getglobal("BonusActionButton"..i));
		doUpdate(getglobal("MultiBarBottomLeftButton"..i));
		doUpdate(getglobal("MultiBarBottomRightButton"..i));
		doUpdate(getglobal("MultiBarRightButton"..i));
		doUpdate(getglobal("MultiBarLeftButton"..i));
	end
	if ( FUActionButton1 ) then
		for i=1,72 do
			doUpdate(getglobal("FUActionButton"..i));
		end
	end
	---[[
	if ( DAB_ActionButton_1 ) then
		for i=1, 120 do
			doUpdate(getglobal("DAB_ActionButton_"..i));
		end
	end
	--]]
end

function GetNumSuperMacrosPlus(category)
	if ( category and category~=SMP_GetCurrentCategory() ) then
		return SMP_GetCategoryMacroCount(category);
	end
	return getn(SMP_ORDERED);
end

function GetSuperMacroPlusInfo( superName, code)
	if ( not superName or not SMP_SUPER[superName] ) then return; end
	-- code can be "name", "texture", "body", "category"
	local a={};
	a.name,a.texture,a.body,a.category=unpack(SMP_SUPER[superName]);
	if (not code) then
		return a.name,a.texture,a.body;
	else
		return a[code];
	end
end

function SortSuperMacroPlusList(category)
	-- sort the selected category into its visible list
	local a={};
	category=category or SMP_GetCurrentCategory();
	for n,macro in pairs(SMP_SUPER) do
		if ( type(macro)=="table" and macro[4]==category ) then
			table.insert(a, n);
		end
	end
	table.sort(a, atoz);
	return a;
end

function GetOrderedSuperMacroPlusInfo( id )
	if ( not SMP_ORDERED ) then
		SMP_ORDERED=SortSuperMacroPlusList(SMP_GetCurrentCategory());
	end
	if ( not SMP_SUPER[SMP_ORDERED[id] ] ) then
		return;
	end
	return unpack(SMP_SUPER[SMP_ORDERED[id] ]);
end

function GetOrderedSuperMacroPlus( name )
	for i,v in SMP_ORDERED do
		if ( v==name ) then
			return i;
		end
	end
end

function CreateSuperMacroPlus( name, texture, body, category )
	category=category or SMP_GetCurrentCategory();
	if ( SMP_SUPER[name] ) then return; end
	if ( SMP_GetCategoryMacroCount(category)>=SMP_CATEGORY_MAX_MACROS ) then return; end
	SMP_SUPER[name]={name, texture, body or '', category};
	SMP_UpdateActionSpell( name, "super", body);
	SMP_NotifyMacroChanged(name);
	SMP_ORDERED=SortSuperMacroPlusList(category);
	return GetOrderedSuperMacroPlus(name);
end

function EditSuperMacroPlus( id, name, texture)
	local oldMacro, oldTexture, oldBody, category=GetOrderedSuperMacroPlusInfo(id);
	if ( not oldMacro ) then return; end
	if ( oldMacro~=name ) then
		SMP_SUPER[oldMacro]=nil;
		SMP_UpdateActionSpell( oldMacro, "super", nil);
	end
	SMP_SUPER[name]={ name, texture, oldBody, category or SMP_GetCurrentCategory()};
	SuperMacroPlus_UpdateAction(oldMacro, name);
	SMP_UpdateActionSpell( name, "super", oldBody);
	SMP_NotifyMacroChanged(name, oldMacro~=name and oldMacro or nil);
	SMP_ORDERED=SortSuperMacroPlusList(SMP_GetCurrentCategory());
	return GetOrderedSuperMacroPlus(name);
end

function DeleteSuperMacroPlus( macro )
	local id=macro;
	if ( type(macro)=="number" ) then
		macro=GetOrderedSuperMacroPlusInfo(macro);
	else
		id=GetOrderedSuperMacroPlus(macro);
	end
	SuperMacroPlus_UpdateAction(macro, nil);
	SMP_UpdateActionSpell(macro, "super", nil);
	SMP_SUPER[macro]=nil;
	SMP_NotifyMacroChanged(nil, macro);
	SMP_ORDERED=SortSuperMacroPlusList(SMP_GetCurrentCategory());
	if ( GetNumSuperMacrosPlus()==0 ) then
		id=nil;
	else
		id=id>1 and id-1 or 1;
	end
	SuperMacroPlusFrame_SelectSuperMacroPlus(id);
end

function SMP_LoadMacroIcons()
	local icon={};
	for i=1,GetNumMacroIcons() do
		local texture=GetMacroIconInfo(i);
		icon[texture]=i;
	end
	return icon;
end

function SMP_UpdateActionSpell( macroname, macrotype, body)
-- SMP_ACTION_SPELL={}
-- SMP_ACTION_SPELL.regular={}
-- SMP_ACTION_SPELL.super={}
	if ( not macroname ) then
	-- update all macros
		for i=1, 36 do
			local name,_,body=GetMacroInfo(i);
			if ( name ) then
				SMP_UpdateActionSpell(name, "regular", body);
			end
		end
		for name,macro in pairs(SMP_SUPER) do
			if ( type(macro)=="table" ) then
				SMP_UpdateActionSpell(name, "super", macro[3]);
			end
		end
		return;
	end
	--macrotype is "regular" or "super"
	if ( macrotype~="regular" and macrotype~="super" ) then
		macrotype="regular";
	end
	SMP_ACTION_SPELL[macrotype][macroname]={};
	local tooltipFound,tooltipExplicit,tooltipType,tooltipAction,tooltipTexture=SMP_FindShowTooltip(body);
	if ( tooltipFound and tooltipExplicit ) then
		if ( tooltipType and tooltipTexture ) then
			SMP_ACTION_SPELL[macrotype][macroname].type=tooltipType;
			SMP_ACTION_SPELL[macrotype][macroname].spell=tooltipAction;
			SMP_ACTION_SPELL[macrotype][macroname].texture=tooltipTexture;
		else
			SMP_ACTION_SPELL[macrotype][macroname]=nil;
		end
		return;
	end
	local id, book, texture, count, spell=SMP_FindFirstSpell(body);
	if ( id ) then
		SMP_ACTION_SPELL[macrotype][macroname].type="spell";
		spell=count;
	else
		id, book, texture, count, spell=SMP_FindFirstItem(body);
		if ( id ) then
			SMP_ACTION_SPELL[macrotype][macroname].type="item";
		end
	end
	if ( not id ) then
		SMP_ACTION_SPELL[macrotype][macroname]=nil;
		return;
	end
	SMP_ACTION_SPELL[macrotype][macroname].spell=spell;
	SMP_ACTION_SPELL[macrotype][macroname].texture=texture;
end

function SMP_GetActionSpell(macroname, macrotype)
	if ( macrotype and macrotype~="regular" ) then
		macrotype="super";
	else
		macrotype="regular";
	end
	if ( not SMP_ACTION_SPELL[macrotype][macroname] ) then
		return nil;
	end
	local actiontype=SMP_ACTION_SPELL[macrotype][macroname].type;
	local spell=SMP_ACTION_SPELL[macrotype][macroname].spell;
	local texture=SMP_ACTION_SPELL[macrotype][macroname].texture;
	return actiontype, spell, texture;
end
