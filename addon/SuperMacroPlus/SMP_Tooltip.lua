--SMP_VARS.macroTip1 = 1; -- for spell, item
--SMP_VARS.macroTip2 = 1; -- for macro code

SMP_ITEM_PATTERN = "[%w '%-:]+";
SMP_SPELL_PATTERN="[%w'%(%) %-:]+";

local function SMP_TrimMacroAction(text)
	if ( not text ) then return nil; end
	text=gsub(text, "^%s+", "");
	text=gsub(text, "%s+$", "");
	while ( string.find(text, "^%b[]") ) do
		text=gsub(text, "^%b[]%s*", "", 1);
	end
	text=gsub(text, "^%s+", "");
	if ( string.sub(text, 1, 1)=="?" ) then return nil; end
	text=gsub(text, "^[!~]+", "");
	text=gsub(text, "^%s+", "");
	text=gsub(text, "%s+$", "");
	if ( text=="" ) then return nil; end
	return text;
end

local function SMP_FindSlashSpell(body)
	if ( not body ) then return nil; end
	for line in string.gfind(body.."\n", "([^\n]*)\n") do
		local _,_,command,args=string.find(line, "^%s*/([%a]+)%s+(.+)$");
		command=command and string.lower(command) or nil;
		if ( command=="cast" or command=="pfcast" ) then
			for clause in string.gfind(args..";", "(.-);") do
				local spell=SMP_TrimMacroAction(clause);
				if ( spell ) then
					local id,book=SMP_FindSpell(spell);
					if ( id and book ) then
						return id,book,GetSpellTexture(id,book),spell;
					end
				end
			end
		end
	end
	return nil;
end

-- Returns: directiveFound, explicitArgument, actionType, actionName, texture.
-- An explicit but currently unavailable spell still returns the first two
-- flags so it remains authoritative and falls back to the macro's saved icon.
function SMP_FindShowTooltip(text)
	if ( not text ) then return nil; end
	for line in string.gfind(text.."\n", "([^\n]*)\n") do
		local _,_,tooltip=string.find(line, "^%s*#showtooltips%s*(.-)%s*$");
		if ( tooltip==nil ) then
			_,_,tooltip=string.find(line, "^%s*#showtooltip%s*(.-)%s*$");
		end
		if ( tooltip~=nil ) then
			if ( tooltip=="" ) then return 1,nil; end
			for clause in string.gfind(tooltip..";", "(.-);") do
				local action=SMP_TrimMacroAction(clause);
				if ( action ) then
					local id,book=SMP_FindSpell(action);
					if ( id and book ) then
						return 1,1,"spell",action,GetSpellTexture(id,book);
					end
					local bag,slot,texture=FindItem(action);
					if ( bag ) then
						return 1,1,"item",action,texture;
					end
				end
			end
			return 1,1,nil,tooltip,nil;
		end
	end
	return nil;
end

oldActionButton_SetTooltip=ActionButton_SetTooltip;
function ActionButton_SetTooltip()
	oldActionButton_SetTooltip();
	local actionid=ActionButton_GetPagedID(this);
	SMP_ActionButton_SetTooltip(actionid);
end
--fix Error: attempt to index a nil value in function 'ActionButton_GetPagedID'  [Monteo]
oldBActionButton_SetTooltip=BActionButton_SetTooltip;
function BActionButton_SetTooltip()
	oldBActionButton_SetTooltip();
	local actionid=BActionButton.GetPagedID(this:GetID());
	SMP_ActionButton_SetTooltip(actionid);
end

-- Hooking into tooltip caller of Bongos [Fixed by Threewords]
if (BActionButton ~= nil) then
	oldUpdateTooltip=BActionButton.UpdateTooltip;
	BActionButton.UpdateTooltip = function(button)
		oldUpdateTooltip(button);
		local actionid=BActionButton.GetPagedID(this:GetID());
		SMP_ActionButton_SetTooltip(actionid);
	end
end

if (DAB_ActionButton_OnEnter ~= nil) then
	oldDAB_ActionButton_OnEnter=DAB_ActionButton_OnEnter;
	DAB_ActionButton_OnEnter = function()
		oldDAB_ActionButton_OnEnter();
		local actionid = this:GetActionID();
		SMP_ActionButton_SetTooltip(actionid);
	end
end

function SMP_ActionButton_SetTooltip(actionid)
	--local actionid=ActionButton_GetPagedID(this);
	local macroname=GetActionText(actionid); --or getglobal(this:GetName().."Name"):GetText();
	if ( macroname ) then
		local macro, _, body = GetMacroInfo(GetMacroIndexByName(macroname));
		
		-- for supermacros
		local superfound = SMP_ACTION[actionid];
		if ( superfound ) then
			local smacro, _, sbody = GetSuperMacroPlusInfo(superfound);
			if ( smacro ) then
				macro, body = smacro, sbody;
				GameTooltipTextLeft1:SetText(macro);
				GameTooltip:Show();
			else
				SMP_ACTION[actionid] = nil;
				superfound = nil;
			end
		end

		if ( not macro ) then return; end

		if ( SMP_VARS.macroTip1==1 ) then
			local actiontype, spell = SMP_GetActionSpell(macro, superfound);
			if ( actiontype=="spell" ) then
				local id, book = SMP_FindSpell(spell);
				if ( id ) then
					GameTooltip:SetSpell(id, book);
					if TheoryCraft_AddTooltipInfo then
						TheoryCraft_AddTooltipInfo(GameTooltip)
					else
						local s, r = GetSpellName(id, book);
						if ( r ) then
							GameTooltipTextRight1:SetText("|cff00ffff"..r.."|r");
							GameTooltipTextRight1:Show();
							GameTooltip:Show();
						end
					end
					return;
				end
			elseif ( actiontype=="item" ) then
				local id, book = FindItem(spell);
				if ( book ) then
					GameTooltip:SetBagItem(id, book);
				elseif ( id ) then
					GameTooltip:SetInventoryItem( 'player', id);
				end
				return;
			end
		end
		if ( SMP_VARS.macroTip2 == 1 ) then
			-- show macro code
			if ( not GameTooltipTextLeft1:GetText() ) then return; end
			body = gsub(body, "\n$", "");
			GameTooltipTextLeft1:SetText( "|cff00ffff"..macro.."|r");
			GameTooltipTextLeft2:SetText("|cffffffff"..body.."|r");
			GameTooltipTextLeft2:Show();
			GameTooltipTextLeft1:SetWidth(284);
			GameTooltipTextLeft2:SetWidth(284);
			GameTooltip:SetWidth(300);
			GameTooltip:SetHeight( GameTooltipTextLeft1:GetHeight() + GameTooltipTextLeft2:GetHeight() + 23);
			GameTooltipTextLeft2:SetNonSpaceWrap(true);
			return;
		end
	end
	-- brighten rank text on all tooltips
	if ( GameTooltipTextRight1:GetText() ) then
		local t = GameTooltipTextRight1:GetText();
		GameTooltipTextRight1:SetText("|cff00ffff"..t.."|r");
	end
	-- show crit info for Attack
	if ( GameTooltipTextLeft1:GetText()=="Attack" ) then
		id, book = SMP_FindSpellExact("Attack","");
		if ( id ) then
			GameTooltip:SetSpell(id, book);
			GameTooltip:Show();
		end
	end
end

function SMP_ActionButton_OnLeave()
	this.updateTooltip=nil;
	GameTooltipTextLeft2:SetWidth(100);
	GameTooltipTextLeft2:SetText("");
	GameTooltip:Hide();
end

local oldGetActionCooldown = GetActionCooldown;
function GetActionCooldown( actionid )
	-- start, duration, enable
	local macro=GetActionText(actionid);
	if ( macro and SMP_VARS.checkCooldown==1 ) then
		local name, icon, body = GetMacroInfo(GetMacroIndexByName(macro));
		--  for supermacros
		local superfound = SMP_ACTION[actionid];
		if ( superfound ) then
			local sname, sicon, sbody = GetSuperMacroPlusInfo(superfound);
			if ( sname ) then
				name, icon, body = sname, sicon, sbody;
			else
				SMP_ACTION[actionid] = nil;
				superfound = nil;
			end
		end

		if ( not name ) then
			return oldGetActionCooldown( actionid );
		end

		local buttonName = this:GetName() or ("BActionButton"..actionid);	-- The part after 'or' is to support Bongos [Fixed by Threewords]

		local macroname, pic;
		if ( this ) then
			macroname=getglobal(buttonName.."Name");
			if ( macroname ) then
				macroname:SetText(name);
			end
			pic = getglobal(buttonName.."Icon");
			if ( pic ) then
				pic:SetTexture(icon);
			end
		end

		local actiontype, spell, texture = SMP_GetActionSpell(name, superfound);
		if ( actiontype=="spell") then
			if ( SMP_VARS.replaceIcon==1 and texture and pic) then
				pic:SetTexture(texture);
			end
			local id, book = SMP_FindSpell(spell);
			if ( id ) then
				return GetSpellCooldown( id, book);
			end
		elseif ( actiontype=="item") then
			if ( SMP_VARS.replaceIcon==1 and texture and pic) then
				pic:SetTexture(texture);
			end
			local id, book, texture, count = FindItem(spell);
			if ( count and count>1 and macroname ) then
				macroname:Hide();
				getglobal(buttonName.."Count"):SetText(count);
			elseif ( macroname ) then
				macroname:Show();
				getglobal(buttonName.."Count"):SetText("");
			end
			if ( book ) then
				return GetContainerItemCooldown(id, book);
			elseif ( id ) then
				return GetInventoryItemCooldown('player', id);
			end
		end
	end
	return oldGetActionCooldown( actionid );
end

function SMP_FindFirstSpell( text )
	if not text then return nil end;
	local body = text;
	if (ReplaceAlias and ASFOptions.aliasOn) then
		-- correct aliases
		body = ReplaceAlias(body);
	end
	local id, book, texture, spell;
	while ( string.find(body, "CastSpellByName") ) do
		spell = gsub(body,'^.-CastSpellByName.-%(.-(["\'])(.-)%1.*$','%2');
		id, book = SMP_FindSpell(spell);
		if ( id ) then
			texture = GetSpellTexture(id, book);
			break;
		end
		body = gsub(body, "CastSpellByName","",1);
	end
	if ( not id ) then
		id,book,texture,spell=SMP_FindSlashSpell(body);
	end
	if ( not id ) then
		while ( string.find(body, "[%p%s]cast%(") ) do
			spell = gsub(body,'^.-[%p%s]-cast%(.-(["\'])(.-)%1.*$','%2');
			id, book = SMP_FindSpell(spell);
			if ( id ) then
				texture = GetSpellTexture(id, book);
				break;
			end
			body = gsub(body, "[%p%s]cast%(","", 1);
		end
	end
	if ( not id ) then
		while ( string.find(body, "CastSpell")) do
			spell = gsub(body,'^.-CastSpell.-%(%s*(.-)%s*)%s*%).*$','%1');
			local _,_,spellid = strfind(spell,"^(%d+).*");
			if ( spellid ) then
				local _,_,spellbook=strfind(spell,"^.-"..spellid..",%s*'(%a+)'%s*");
				id=spellid;
				book=spellbook or 'spell';
				texture = GetSpellTexture(id, book);
				break;
			end
			body = gsub(body, "CastSpell","", 1);
		end
	end
	return id, book, texture, spell;
end

function SMP_FindFirstItem( text )
	if not text then return nil end;
	local body = text;
	if (ReplaceAlias and ASFOptions.aliasOn) then
		-- correct aliases
		body = ReplaceAlias(body);
	end
	local bag, slot, texture, count, item;
	if ( strfind(body,"UseItemByName") ) then
		while ( string.find(body, "UseItemByName") ) do
			item = gsub(body,'^.-UseItemByName.-%(.-(["\'])(.-)%1.*$','%2');
			bag, slot, texture, count = FindItem(item);
			if ( bag ) then
				return bag, slot, texture, count, item;
			end
			body = gsub(body, "UseItemByName","", 1);
		end
	end
	if ( strfind(body,"/use") ) then
		while ( string.find(body, "/use") ) do
			if ( strfind(body, '^.-/use *%d') ) then
				-- number means container or inventory slot
				bag, slot = nil, nil;
				gsub(body,'^.-/use -(%d+)[,%s]*(%d*)', function(b,s)
					bag=tonumber(b);
					slot=tonumber(s);
				end );
				if ( bag and slot ) then
					texture, count = GetContainerItemInfo(bag, slot);
					item = ItemLinkToName(GetContainerItemLink(bag, slot));
				elseif ( bag and bag>0 and bag<=23) then
					texture, count = GetInventoryItemTexture('player', bag), GetInventoryItemCount('player', bag);
					item = ItemLinkToName(GetInventoryItemLink('player', bag));
				end
			else
				-- not a number
				item = gsub(body,'^.-/use *('..SMP_ITEM_PATTERN..')\n?.*$', '%1');
				bag, slot, texture, count = FindItem(item);
			end
			if ( bag ) then
				return bag, slot, texture, count, item;
			end
			body = gsub(body, "/use","", 1);
		end
	end
	if ( strfind(body,"use") ) then
		while ( string.find(body, "use") ) do
			if ( strfind(body, '^.-use.-%(%s*%d') ) then
				-- number means container or inventory slot
				bag, slot = nil, nil;
				gsub(body,'^.-use.-%(.-(%d+)[,%s]*(%d*)', function(b,s)
					bag=tonumber(b);
					slot=tonumber(s);
				end );
				if ( bag and slot ) then
					texture, count = GetContainerItemInfo(bag, slot);
					item = ItemLinkToName(GetContainerItemLink(bag, slot));
				elseif ( bag and bag>0 and bag<=23) then
					texture, count = GetInventoryItemTexture('player', bag), GetInventoryItemCount('player', bag);
					item = ItemLinkToName(GetInventoryItemLink('player', bag));
				end
			else
				-- not a number
				item = gsub(body,'^.-use.-%(.-(["\'])('..SMP_ITEM_PATTERN..')%1.*$','%2');
				bag, slot, texture, count = FindItem(item);
			end
			if ( bag ) then
				return bag, slot, texture, count, item;
			end
			body = gsub(body, "use","", 1);
		end
	end
	while ( strfind(body, "UseInventoryItem") ) do
		bag = gsub(body,'^.-UseInventoryItem.-(%d+)%s-%).*$','%1');
		if ( bag~=body) then
			texture = GetInventoryItemTexture('player', bag);
			count = GetInventoryItemCount('player', bag);
		end
		if ( texture ) then
			item=ItemLinkToName( GetInventoryItemLink('player', bag) );
			return bag, slot, texture, count, item;
		end
		body = gsub(body, "UseInventoryItem","", 1);
	end
	while ( strfind(body, "UseContainerItem") ) do
		bag = gsub(body,'^.-UseContainerItem.-(%d+)%s-,%s-(%d+)%s-%).*$','%1');
		slot = gsub(body,'^.-UseContainerItem.-(%d+)%s-,%s-(%d+)%s-%).*$','%2');
		if ( bag~=body and slot~=body) then
			texture, count = GetContainerItemInfo(bag, slot);
		end
		if ( bag~=body and slot~=body and texture ) then
			item=ItemLinkToName( GetContainerItemLink(bag, slot) );
			return bag, slot, texture, count, item;
		end
		body = gsub(body, "UseContainerItem","", 1);
	end
end
