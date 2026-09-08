-- 检测Superwow环境
local hasSuperwow = true;

if not GetPlayerBuffID or not CombatLogAdd or not SpellInfo then
	hasSuperwow = false;
end;

-- 增强版获取目标唯一标识
local function GetUnitIdentifier(unit)
    if hasSuperwow then
		local _, guid = UnitExists(unit)
        return guid		--Superwow提供真正的GUID
    else
        return 0		--默认返回0
    end
end

SMP_INV_SLOT = {
["AMMOSLOT"]=0,
["HEADSLOT"]=1,
["NECKSLOT"]=2,
["SHOULDERSLOT"]=3,
["SHIRTSLOT"]=4,
["CHESTSLOT"]=5,
["WAISTSLOT"]=6,
["LEGSSLOT"]=7,
["FEETSLOT"]=8,
["WRISTSLOT"]=9,
["HANDSSLOT"]=10,
["FINGER0SLOT"]=11,
["FINGER1SLOT"]=12,
["TRINKET0SLOT"]=13,
["TRINKET1SLOT"]=14,
["BACKSLOT"]=15,
["MAINHANDSLOT"]=16,
["SECONDARYHANDSLOT"]=17,
["RANGEDSLOT"]=18,
["TABARDSLOT"]=19,
["BAG0SLOT"]=20,
["BAG1SLOT"]=21,
["BAG2SLOT"]=22,
["BAG3SLOT"]=23,
}

SlashCmdList["SUPERMACROPLUS"] = function(msg)
	if ( not msg or gsub(msg, "%s", "")=="" ) then
		ShowUIPanel(SuperMacroPlusFrame);
		return;
	end
	local info = ChatTypeInfo["SYSTEM"];
	local text;
	local cmd = gsub(msg,"^%s*(%a*)%s*(.*)%s*$","%1" );
	local param = gsub(msg,"^%s*(%a*)%s*([%w %p]*)%s*$","%2" );
	if ( cmd=="import" ) then
		if ( SuperMacroPlusFrame:IsVisible() ) then
			SuperMacroPlusFrame_SaveSuperMacroPlus();
		end
		local importedSuper,importedRegular,skipped,copiedActions,sourceAvailable=SMP_MigrateFromSuperMacro(1);
		if ( not sourceAvailable ) then
			SMP_PrintError(SMP_MIGRATION_SOURCE_MISSING);
			return;
		end
		SMP_ORDERED=SortSuperMacroPlusList(SMP_GetCurrentCategory());
		SuperMacroPlusFrame.selectedSuper=(getn(SMP_ORDERED)>0) and 1 or nil;
		SuperMacroPlusFrame_Update();
		SMP_PrintMigrationResult(importedSuper, importedRegular, skipped, copiedActions);
		return;
	end
	if ( cmd=="hideaction") then
		text = param;
		if ( text == "0" or text=="false") then
			SMP_VARS.hideAction = 0;
			SMP_HideActionText();
		elseif ( text == "1" or text=="true") then
			SMP_VARS.hideAction = 1;
			SMP_HideActionText();
		else
			ChatFrame_DisplaySlashHelp("SUPERMACROPLUS",3,3);
		end
		if ( not SMP_VARS.hideAction ) then SMP_VARS.hideAction = 0; end
		text = "SMP_VARS.hideAction is "..SMP_VARS.hideAction;
		if ( SuperMacroPlusOptionsFrame:IsVisible() ) then
			SuperMacroPlusOptionsFrame_OnShow();
		end
		DEFAULT_CHAT_FRAME:AddMessage( text, info.r, info.g, info.b, info.id);
		return;
	end
	if ( cmd=="printcolor" ) then
		text = param;
		if ( text =="default" ) then
			SMP_VARS.printColor.r = SMP_PRINT_COLOR_DEF.r;
			SMP_VARS.printColor.g = SMP_PRINT_COLOR_DEF.g;
			SMP_VARS.printColor.b = SMP_PRINT_COLOR_DEF.b;
			if ( SuperMacroPlusOptionsFrame:IsVisible() ) then
				SuperMacroPlusOptionsFrame_OnShow();
			end
			return;
		end
		if ( gsub(text,"%s*","")=="" ) then
			ChatFrame_DisplaySlashHelp("SUPERMACROPLUS",4,4);
			return;
		end
		local color = gsub(msg, ".*color%s*(.*)","%1");
		local red = gsub(color, "%s*(-?%d*%.*%d*)%s*.*","%1");
		local green = gsub(color, "%s*(-?%d*%.*%d*)%s*(-?%d*%.*%d*)%s*(-?%d*%.*%d*)%s*.*","%2");
		local blue = gsub(color, "%s*(-?%d*%.*%d*)%s*(-?%d*%.*%d*)%s*(-?%d*%.*%d*)%s*.*","%3");
		red = tonumber(red) or 0;
		green = tonumber(green) or 0;
		blue = tonumber(blue) or 0;
		red = (red < 0 and 0) or (red > 1 and 1) or red;
		green = (green < 0 and 0) or (green > 1 and 1) or green;
		blue = (blue < 0 and 0) or (blue > 1 and 1) or blue;
		SMP_VARS.printColor = { r=red,g=green,b=blue };
		if ( SuperMacroPlusOptionsFrame:IsVisible() ) then
			SuperMacroPlusOptionsFrame_OnShow();
		end
		return;
	end
	if ( cmd=="macrotip" ) then
		text = param;
		if ( text =="default" ) then
			SMP_VARS.macroTip1 = 1;
			SMP_VARS.macroTip2 = 0;
			if ( SuperMacroPlusOptionsFrame:IsVisible() ) then
				SuperMacroPlusOptionsFrame_OnShow();
			end
			return;
		end	
		text = tonumber(text);
		if ( text and text >= 0 and text <= 3) then
			if ( mod(text, 2) == 1 ) then
				SMP_VARS.macroTip1 = 1;
			else
				SMP_VARS.macroTip1 = 0;
			end
			if ( text >= 2 ) then
				SMP_VARS.macroTip2 = 1;
			else
				SMP_VARS.macroTip2 = 0;
			end
			if ( SuperMacroPlusOptionsFrame:IsVisible() ) then
				SuperMacroPlusOptionsFrame_OnShow();
			end
		else
			ChatFrame_DisplaySlashHelp("SUPERMACROPLUS",5,6);
		end
		return;
	end
	if ( cmd=="options" ) then
		ShowUIPanel(SuperMacroPlusOptionsFrame);
		return;
	end

	ChatFrame_DisplaySlashHelp("SUPERMACROPLUS");
	return;
end

SlashCmdList["MACROPLUS"] = function(msg)
	if(not msg or msg == "") then
		ShowUIPanel(SuperMacroPlusFrame);
	else
		RunSuperMacroPlus(msg);
	end
end

SlashCmdList["SMPRUNSUPER"] = function(msg)
	if(msg) then
		RunSuperMacroPlus(msg);
	end
end

-- use item
SlashCmdList["SMUSE"] = function(msg)
	use(unpack(ListToTable(msg)));
end

-- equip item
SlashCmdList["SMEQUIP"] = function(msg)
	use(unpack(ListToTable(msg)));
end

-- equip offhand item
SlashCmdList["SMEQUIPOFF"] = function(msg)
	local bag, slot = FindItem(TrimSpaces(msg));
	if ( bag and slot ) then
		PickupContainerItem(bag, slot);
		PickupInventoryItem(17);
	end
end

-- unequip item by part or name
SlashCmdList["SMUNEQUIP"] = function(msg)
	local e,f = FindLastEmptyBagSlot();
	if ( e ) then
		PickupInventoryItem(FindItem(TrimSpaces(msg)));
		PickupContainerItem(e,f);
	end
end

-- print text to chatframe
SlashCmdList["SMPRINT"] = function(msg)
	SMP_print(msg);
end

-- after action passed text
SlashCmdList["SMPASS"] = function(msg)
	Pass(msg);
end

-- after action failed text
SlashCmdList["SMFAIL"] = function(msg)
	Fail(msg);
end

-- use items in order
SlashCmdList["SMDOORDER"] = function(msg)
	DoOrder(unpack(ListToTable(msg)));
end

-- channel without interruption
SlashCmdList["SMCHANNEL"] = function(msg)
	SMP_Channel(msg);
end

function SMP_print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg, SMP_VARS.printColor.r, SMP_VARS.printColor.g, SMP_VARS.printColor.b);
end

if ( not ChatFrame_DisplaySlashHelp ) then
function ChatFrame_DisplaySlashHelp(pre, start, last, frame)
	if ( not frame ) then
		frame=DEFAULT_CHAT_FRAME;
	end
	local info = ChatTypeInfo["SYSTEM"];
	local i = 1;
	if ( type(start) =="number" ) then i = start; end
	if ( i < 1 ) then i =1; end
	local text = TEXT(getglobal(pre.."_HELP_LINE"..i));
	while text do
		frame:AddMessage(text, info.r, info.g, info.b, info.id);
		i = i + 1;
		text = TEXT(getglobal(pre.."_HELP_LINE"..i));
		if ( last and i > last ) then break; end
	end
end
end -- if

-- in sec do cmd
SlashCmdList["SMIN"] = function(msg)
	local _,_,s,r,c = strfind(msg, "(%d+h?%d*m?%d*s?)(%+?)%s+(.*)");
	if ( not c or TrimSpaces(c)=="" ) then return end
	c=gsub(c,"\\n","\n");
	SuperMacroPlus_InEnter(s,c,r);
end

SMP_SHIFT_FORM = { bear=1,aquatic=2,cat=3,travel=4,moonkin=5, stealth=1, battle=1,defend=2,berzerk=3 };

SlashCmdList["SMSHIFT"] = function(msg)
	local form=msg;
	if ( SMP_SHIFT_FORM[msg] ) then
		form=SMP_SHIFT_FORM[msg];
	end
	CastShapeshiftForm(form);
end

SlashCmdList["SMCRAFT"] = function(msg)
	local skill, item, count = unpack(ListToTable(msg));
	count = tonumber(count);
	CraftItem(skill, item, count);
end

SlashCmdList["SMSAYRANDOM"] = function(msg)
	SayRandom(unpack(ListToTable(msg)));
end

SlashCmdList["SMCANCELBUFF"] = function(msg)
	CancelBuff(unpack(ListToTable(msg)));
end

function SayRandom(...)
	tinsert(arg, "");
	local r=random(arg.n);
	SMP_RunLine(arg[r]);
end

function SuperMacroPlus_InEnter( sec, cmd, rep)
	if ( not sec or not cmd ) then return end
	local t=SMP_INFRAME.events;
	local seconds=sec;
	if ( strfind(seconds,'[hms]') ) then
		seconds=gsub(seconds,'^(%d+)(h?)(%d*)(m?)(%d*)(s?)$', function(hd, h, md, m, sd, s)
			local a=0;
			if ( h=="h" ) then a=a+hd*3600
			else md=hd..md end;
			if ( m=="m" ) then a=a+md*60
			else sd=md..sd end;
			if ( sd~="" ) then a=a+sd end;
			return a;
		end );
	end
	s=GetTime()+seconds;
	t[s]={};
	t[s].cmd=cmd;
	t[s].sec=seconds;
	t[s].rep=rep and rep or "";
	t.n=t.n+1;
	SMP_INFRAME:Show();
end

SMP_IN=SuperMacroPlus_InEnter;

function SMP_INFRAME_OnUpdate( )
	local t=this.events;
	if ( getn(t)==0 ) then
		SMP_INFRAME:Hide();
	end
	for k,v in t do
		if ( k~='n' and k<=GetTime() ) then
			SMP_RunBody(v.cmd);
			if ( v.rep~="" ) then
				local s=GetTime()+v.sec;
				t[s]={};
				t[s].cmd=v.cmd;
				t[s].sec=v.sec;
				t[s].rep=v.rep;
				t[k]=nil;
			else
				t[k]=nil;
				t.n=t.n-1;
			end
		end
	end
end

function Pass(text)
	if( IsCurrentAction(lastActionUsed) ) then
		SMP_RunLine(text);
		return text;
	end
end

function Fail(text)
	if ( not IsCurrentAction(lastActionUsed) ) then
		SMP_RunLine(text);
		return text;
	end
end

function UseItemByName(item)
	local bag,slot = FindItem(item);
	if ( not bag ) then return; end;
	if ( slot ) then
		UseContainerItem(bag,slot); -- use, equip item in bag
		return bag, slot;
	else
		UseInventoryItem(bag); -- unequip from body
		return bag;
	end
end

function use(bag, slot)
	local b,s=tonumber(bag), tonumber(slot);
	if ( b ) then
		if ( s ) then
			UseContainerItem(bag,slot); -- use, equip item in bag
		else
			UseInventoryItem(bag); -- unequip from body
		end
	else
		UseItemByName(bag);
	end
end

function DoOrder(...)
	for k,i in arg do
		local item=FindItem(i);
		local spell,book=SMP_FindSpell(i);
		if ( spell and GetSpellCooldown(spell,book)==0) then
			CastSpell(spell,book);
			return i, spell, book;
		end
		if ( item and GetItemCooldown(i)==0 ) then
			UseItemByName(i);
			return i, item, slot;
		end
	end
end

function FindItem(item)
	if ( not item ) then return; end
	item = string.lower(ItemLinkToName(item));
	local link;
	for i = 1,23 do
		link = GetInventoryItemLink("player",i);
		if ( link ) then
			if ( item == string.lower(ItemLinkToName(link)) )then
				return i, nil, GetInventoryItemTexture('player', i), GetInventoryItemCount('player', i);
			end
		end
	end
	local count, bag, slot, texture;
	local totalcount = 0;
	for i = 0,NUM_BAG_FRAMES do
		for j = 1,MAX_CONTAINER_ITEMS do
			link = GetContainerItemLink(i,j);
			if ( link ) then
				if ( item == string.lower(ItemLinkToName(link))) then
					bag, slot = i, j;
					texture, count = GetContainerItemInfo(i,j);
					totalcount = totalcount + count;
				end
			end
		end
	end
	return bag, slot, texture, totalcount;
end

function GetItemCooldown(item)
	local bag, slot = FindItem(item);
	if ( slot ) then
		return GetContainerItemCooldown(bag, slot);
	elseif ( bag ) then
		return GetInventoryItemCooldown('player', bag);
	end
end

function FindLastEmptyBagSlot()
	for i=NUM_BAG_FRAMES,0,-1 do
		for j=GetContainerNumSlots(i),1,-1 do
			if not GetContainerItemInfo(i,j) then
				return i,j;
			end
		end
	end
end

function ListToTable(text)
	local t={};
	-- if comma is part of item, put % before it
	-- eg, Sulfuras%, Hand of Ragnaros
	text=gsub(text, "%%,", "%%044");
	-- convert link to name, commas ok
	text=gsub(text, "|c.-%[(.+)%]|h|r", function(x)
		return gsub(x, ",", "%%044");
	end );

	gsub(text, "[^,]+", function(a) -- list separated by comma
		a = TrimSpaces(a);
		if ( a~="" ) then
			a=gsub(a, "%%044", ",");
			tinsert(t,a);
		end
	end);
	return t;
end

function TrimSpaces(str)
	if ( str ) then
		return gsub(str,"^%s*(.-)%s*$","%1");
	end
end

function ItemLinkToName(link)
	if ( link ) then
   	return gsub(link,"^.*%[(.*)%].*$","%1");
	end
end
 -- 修改 by 武藤纯子酱 2025.8.14
function IsMyBuff(unitId,name)
	if not Chronometer then Print('Error: Chronometer not found.') return false end
	if not UnitExists(unitId) then return false end
	u = UnitName(unitId)
	  for i = 1, 20 do
		  if Chronometer.bars[i].id then
			  if Chronometer.bars[i].target == u and Chronometer.bars[i].name == name then
				  return true
			  end
		  end
	  end
	  return false
end
 -- 修改 by 武藤纯子酱 2025.8.14
function CheckMyDot(unit,spellName,refreshtime)
    if UnitExists(unit) and not UnitIsFriend("player", unit) then
        local targetGuid = GetUnitIdentifier(unit);
        local spellNameNoRank = spellName;
        local refresh = refreshtime
        -- 检查是否有你施放的DEBUFF
        if Cursive.curses:HasCurse(spellNameNoRank, targetGuid, refresh) then
			local curseData
			-- 添加层级存在性检查
			if Cursive.curses.guids[targetGuid] and Cursive.curses.guids[targetGuid][spellNameNoRank] then
				curseData = Cursive.curses.guids[targetGuid][spellNameNoRank];
			else
				curseData = nil;
			end;
			-- 检查curseData是否为有效值
            if curseData then
                local remaining = Cursive.curses:TimeRemaining(curseData)
                return true;
            else
                return false;
            end;
        else
            return false;
        end
    end
    return false; -- 补充默认返回值	
end
 -- 修改 by 武藤纯子酱 2025.8.14
function FindBuff( obuff, unit, isMine, refreshtime, item)
	local buff=strlower(obuff);
	local tooltip=SMP_Tooltip;
	local textleft1=getglobal(tooltip:GetName().."TextLeft1");
	local refresh = refreshtime -- 修改 by 武藤纯子酱 2025.8.14
	if ( not unit ) then
		unit ='player';
	elseif ( unit == "mouseover" ) then
		local frame = GetMouseFocus()
		if ( frame.label and frame.id ) then
			unit = frame.label .. frame.id
		end
	end
	local my, me, mc, oy, oe, oc = GetWeaponEnchantInfo();
	if ( my ) then
		tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		tooltip:SetInventoryItem( unit, 16);
		for i=1, 64 do
			local text = getglobal("SMP_TooltipTextLeft"..i):GetText();
			if ( not text ) then
				break;
			elseif ( strfind(strlower(text), buff) ) then
				tooltip:Hide();
				return "main",me, mc;
			end
		end
		tooltip:Hide();
	elseif ( oy ) then
		tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		tooltip:SetInventoryItem( unit, 17);
		for i=1, 64 do
			local text = getglobal("SMP_TooltipTextLeft"..i):GetText();
			if ( not text ) then
				break;
			elseif ( strfind(strlower(text), buff) ) then
				tooltip:Hide();
				return "off", oe, oc;
			end
		end
		tooltip:Hide();
	end
	if ( item ) then return end
	tooltip:SetOwner(UIParent, "ANCHOR_NONE");
	tooltip:SetTrackingSpell();
	local b = textleft1:GetText();
	if ( b and strfind(strlower(b), buff) ) then
		tooltip:Hide();
		return "track",b;
	end
	local c=nil;
	for i=1, 64 do
		tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		tooltip:SetUnitBuff(unit, i);
		b = textleft1:GetText();
		tooltip:Hide();
		if ( b and strfind(strlower(b), buff) ) then
			if not isMine then 
				return "buff", i, b;
			elseif Cursive and CheckMyDot(unit,obuff,refreshtime) then -- 修改 by 武藤纯子酱 2025.8.14
				return "buff", i, b;
			elseif Chronometer and IsMyBuff(unit,obuff) then -- 修改 by 武藤纯子酱 2025.8.14 
				return "buff", i, b; 
			end
		elseif ( c==b ) then
			break;
		end
		--c = b;
	end
	c=nil;
	for i=1, 128 do
		tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		tooltip:SetUnitDebuff(unit, i);
		b = textleft1:GetText();
		tooltip:Hide();
		if ( b and strfind(strlower(b), buff) ) then
			if not isMine then 
				return "debuff", i, b;
			elseif Cursive and CheckMyDot(unit,obuff,refreshtime) then -- 修改 by 武藤纯子酱 2025.8.14
				return "debuff", i, b;
			elseif Chronometer and IsMyBuff(unit,obuff) then -- 修改 by 武藤纯子酱 2025.8.14 
				return "debuff", i, b; 
			end
		elseif ( c==b) then
			break;
		end
		--c = b;
	end
	-- Turtle WoW overflow debuffs appear in buff slots - check there too
	c=nil;
	for i=1, 64 do
		tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		tooltip:SetUnitBuff(unit, i);
		b = textleft1:GetText();
		tooltip:Hide();
		if ( b and strfind(strlower(b), buff) ) then
			if not isMine then 
				return "debuff", i, b;
			elseif Cursive and CheckMyDot(unit,obuff,refreshtime) then -- 修改 by 武藤纯子酱 2025.8.14
				return "debuff", i, b;
			elseif Chronometer and IsMyBuff(unit,obuff) then -- 修改 by 武藤纯子酱 2025.8.14 
				return "debuff", i, b; 
			end
		elseif ( c==b ) then
			break;
		end
	end
	tooltip:Hide();
end

function SpellReady(spell)
    local i,a=0
    while a~=spell do
        i=i+1
        a=GetSpellName(i,"spell")
        if ( not a ) then return; end
    end
    if GetSpellCooldown(i,"spell") == 0 then
        return true
    end
end

function CancelBuff(...)
	for j=1, getn(arg) do
   	local buff = strlower(arg[j]);
   	for i=0, 32 do
   		SMP_Tooltip:SetOwner(UIParent, "ANCHOR_NONE");
   		SMP_Tooltip:SetPlayerBuff(i);
   		local name = SMP_TooltipTextLeft1:GetText();
   		if ( not name ) then break end;
   		if ( strfind(strlower(name), buff) ) then
   			CancelPlayerBuff(i);
   		end
   		SMP_Tooltip:Hide();
   	end
	end
end

function SMP_Pickup(bag, slot)
	if ( type(bag)=="string") then
		if ( SMP_INV_SLOT[strupper(bag)] ) then
			bag=GetInventorySlotInfo(bag);
		else
			bag,slot=FindItem(bag);
		end
	end
	if ( bag and not slot ) then
		PickupInventoryItem(bag);
	elseif ( bag and slot ) then
		PickupContainerItem(bag, slot);
	end
end

function caststop(...)
	for i=1, arg.n do
		CastSpellByName(arg[i]);
		SpellStopCasting();
	end
end

function SMP_Channel(spell)
	local cf = CastingBarFrame;
	local sp, book = SMP_FindSpell(spell);
	if ( not sp ) then return; end
	local cd = GetSpellCooldown(sp, book);
	if ( not cf.channeling and cd<=1.5 ) then
		cast(spell);
	end
end
Channel = SMP_Channel;

function FindTradeSkillIndex(tradeskill)
	tradeskill=strlower(tradeskill);
	if ( TradeSkillFrame and TradeSkillFrame:IsVisible()) then
		for i=1,GetNumTradeSkills() do
			local tsn,tst,tsx=GetTradeSkillInfo(i);
			if (strlower(tsn)==tradeskill) then
				SelectTradeSkill(i);
				TradeSkillInputBox:SetNumber(tsx);
				TradeSkillFrame.numAvailable=tsx;
				return i, tsx;
			end
		end
	end
	if ( CraftFrame and CraftFrame:IsVisible()) then
		for i=1,GetNumCrafts() do
		--craftName, craftSubSpellName, craftType, numAvailable, isExpanded,?,?
			local tsn,_,_,tsx=GetCraftInfo(i);
			if (strlower(tsn)==tradeskill) then
				SelectCraft(i);
				return i, 'c';
			end
		end
	end
end

function CraftItem( tradeskill, tradeitem, count)
	if ( TradeSkillFrame and TradeSkillFrame:IsVisible() ) then
		HideUIPanel(TradeSkillFrame);
	end
	if ( CraftFrame and CraftFrame:IsVisible() ) then
		HideUIPanel(CraftFrame);
	end
	cast(tradeskill);
	local index, avail = FindTradeSkillIndex(tradeitem);
	if ( avail=='c' ) then
		DoCraft(index);
	elseif (avail and avail > 0) then
		local amount;
		count = count or 1;
		if ( count <= 0 ) then
		-- 0 to make all, -1 to leave 1
			amount =avail+count;
		else
		-- amount user entered
			amount=count;
		end
		amount = amount<1 and 1 or amount>avail and avail or amount;
		TradeSkillInputBox:SetNumber(amount);
		DoTradeSkill(index, amount);
	end
end

-- register events to run macros
-- should put in Extend box or SMP_Extend.lua

function RegisterEventMacro( macro, super, ...)
	-- ... is for all events you want to register
	-- super is 1 if running 'Super' Macro; else 0 or nil
	
	local macroname = macro;
	if ( super == 1 ) then
		macroname = "SUPER" .. macroname;
	end
	
	for i=1, arg.n do
		local event = arg[i];
		--Print(event);
		SuperMacroPlus_EventsFrame:RegisterEvent(event);
		if ( not SuperMacroPlus_EventsFrame.events[event] ) then
			SuperMacroPlus_EventsFrame.events[event]={};
		end
		SuperMacroPlus_EventsFrame.events[event][macroname] = 1;
	end
end

function UnregisterEventMacro( macro, super, ...)
	local macroname = macro;
	if ( super == 1 ) then
		macroname = "SUPER" .. macroname;
	end
	
	for i=1, arg.n do
		local event = arg[i];
		--Print(event);
		
		if ( not SuperMacroPlus_EventsFrame.events[event] ) then
			-- event not registered
			break;
		end
		
		SuperMacroPlus_EventsFrame.events[event][macroname] = nil;

		if ( getn( SuperMacroPlus_EventsFrame.events[event] ) == 0 ) then
			-- no macros left for this event
			SuperMacroPlus_EventsFrame:UnregisterEvent(event);
			SuperMacroPlus_EventsFrame.events[event]=nil;
		end
	end
end

function SuperMacroPlus_EventsFrame_OnEvent()
	local ev = event;
	if ( this.events[ev] ) then
		for macro in pairs(this.events[ev]) do
			if ( strfind(macro, "^SUPER") ) then
				RunSuperMacroPlus( strsub( macro, 6) );
			else
				SuperMacroPlus_RunMacro( macro );
			end
		end
	end
end

function ViewEventMacros()
	Printt(SuperMacroPlus_EventsFrame.events, "EventMacros");
end

-- shortened replacements
-- also try Alias addon to save space, like to get player's mana

cast = CastSpellByName;
stopcast = SpellStopCasting;
echo = SMP_print;
send = SendChatMessage;
buffed = FindBuff;
unbuff = CancelBuff;
pickup = SMP_Pickup;

-- added debug print
function Printd(...)
	for i=1, arg.n do
		local t=arg[i] and (arg[i]~="" and arg[i] or '-""-' )or "-nil-";
		if ( type(t)=="boolean") then
			t="-"..tostring(t).."-";
		end
		DEFAULT_CHAT_FRAME:AddMessage(t,1,1,1);
	end
end

function PrintColor(r,g,b,...)
	for i=1, arg.n do
		local t=arg[i] and (arg[i]~="" and arg[i] or '-""-' )or "-nil-";
		if ( type(t)=="boolean") then
			t="-"..tostring(t).."-";
		end
		DEFAULT_CHAT_FRAME:AddMessage(t,r,g,b);
	end
end

Printc=PrintColor;

-- Prints a table in an organized format
function PrintTable(table, rowname, level) 
	if ( rowname == nil ) then rowname = "ROOT"; end
--Print(level)
	--level = level and level or 1;
	if ( not level ) then level = 1; end
	local msg = "";
	for i=1, level do 
		msg = msg .. "   ";	
	end

	if ( table == nil ) then Print (msg.."["..rowname.."] := nil "); return end
	if ( type(table) == "table" ) then
		Print(msg..rowname.." { ");
		for k,v in table do
			PrintTable(v,k,level+1);
		end
		Print(msg.."} ");
	elseif (type(table) == "function" ) then 
		Print(msg.."["..rowname.."] => {{FunctionPtr*}}");
	else
		Print(msg.."["..rowname.."] => "..table);
	end
end

Printt=PrintTable;
