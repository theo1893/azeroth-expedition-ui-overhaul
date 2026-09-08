-- hook API functions

local oldPickupMacro=PickupMacro;
local oldPickupContainerItem=PickupContainerItem;
local oldPickupInventoryItem=PickupInventoryItem;
local oldPickupSpell=PickupSpell;
local oldPickupAction=PickupAction;
local oldPlaceAction=PlaceAction;
local oldUseAction=UseAction;
local oldGetActionText=GetActionText;
local oldGetActionTexture=GetActionTexture;
local oldClearCursor=ClearCursor;

SMP_CARRIER_MACRO_NAME = "SMP_Carrier";

local SMP_DragCursorFrame;
local SMP_CURSOR_WATCH_FRAME;
local SMP_ACTION_RECOVERY={};
local SMP_PENDING_ACTION_PICKUP;
local SMP_NATIVE_CARRIER_CURSOR;
local SMP_EXPECT_CURSOR_UPDATE;
local SMP_PRESERVE_CURSOR_UPDATE;

local function SMP_GetDragCursorFrame()
	if ( SMP_DragCursorFrame ) then return SMP_DragCursorFrame; end
	if ( not UIParent or not CreateFrame ) then return nil; end

	local frame=CreateFrame("Frame", "SuperMacroPlusDragCursorFrame", UIParent);
	frame:SetWidth(40);
	frame:SetHeight(40);
	frame:SetFrameStrata("TOOLTIP");
	frame:EnableMouse(false);
	frame:SetAlpha(0.9);
	frame:SetBackdrop({
		bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
		tile=true,
		tileSize=8,
		edgeSize=10,
		insets={ left=2, right=2, top=2, bottom=2 }
	});
	frame:SetBackdropColor(0, 0, 0, 0.85);
	frame:SetBackdropBorderColor(1, 0.82, 0, 1);

	local icon=frame:CreateTexture(nil, "ARTWORK");
	icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4);
	icon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4);
	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93);
	frame.icon=icon;

	frame:SetScript("OnUpdate", function()
		local scale=UIParent:GetEffectiveScale();
		local x,y=GetCursorPosition();
		if ( not scale or scale==0 ) then scale=1; end
		this:ClearAllPoints();
		this:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x/scale+16, y/scale-16);
	end);
	frame:Hide();
	SMP_DragCursorFrame=frame;
	return frame;
end

function SMP_RefreshDragCursor()
	local data=SMP_CURSOR_MACRO;
	if ( not data or (data.kind~="plus" and data.kind~="legacy") ) then
		if ( SMP_DragCursorFrame ) then SMP_DragCursorFrame:Hide(); end
		return;
	end
	local frame=SMP_GetDragCursorFrame();
	if ( not frame ) then return; end
	frame.icon:SetTexture(data.texture or "Interface\\Icons\\INV_Misc_QuestionMark");
	frame:Show();
end

function SMP_RebuildActionRecovery()
	SMP_ACTION_RECOVERY={};
	if ( type(SMP_ACTION)~="table" ) then return; end
	for id,name in pairs(SMP_ACTION) do
		if ( type(name)=="string" and type(SMP_SUPER[name])=="table" ) then
			SMP_ACTION_RECOVERY[id]=name;
		end
	end
end

local function SMP_AbandonPendingActionPickup()
	if ( SMP_PENDING_ACTION_PICKUP and SMP_PENDING_ACTION_PICKUP.slot ) then
		SMP_ACTION_RECOVERY[SMP_PENDING_ACTION_PICKUP.slot]=nil;
	end
	SMP_PENDING_ACTION_PICKUP=nil;
end

function SMP_IsCarrierAction(id)
	if ( not id ) then return nil; end
	return oldGetActionText(id)==SMP_CARRIER_MACRO_NAME and 1 or nil;
end

function SMP_GetManagedActionName(id)
	if ( not id ) then return nil; end
	local name=SMP_ACTION and SMP_ACTION[id];
	if ( name and type(SMP_SUPER[name])=="table" ) then
		SMP_ACTION_RECOVERY[id]=name;
		return name;
	end
	if ( SMP_IsCarrierAction(id) ) then
		name=SMP_ACTION_RECOVERY[id];
		if ( name and type(SMP_SUPER[name])=="table" ) then
			SMP_ACTION[id]=name;
			return name;
		end
	end
	return nil;
end

local function SMP_ResetTrackedCursor()
	SMP_CURSOR=nil;
	SMP_CURSOR_MACRO=nil;
	SMP_NATIVE_CARRIER_CURSOR=nil;
	SMP_EXPECT_CURSOR_UPDATE=nil;
	SMP_PRESERVE_CURSOR_UPDATE=nil;
	SMP_RefreshDragCursor();
end

local function SMP_SetCursorMacroData(name, texture, body, kind, sourceID)
	if ( not name or name=="" or name==SMP_CARRIER_MACRO_NAME ) then
		SMP_CURSOR_MACRO=nil;
		SMP_RefreshDragCursor();
		return;
	end
	SMP_CURSOR_MACRO={
		name=name,
		texture=texture or "Interface\\Icons\\INV_Misc_QuestionMark",
		body=body or "",
		kind=kind or "native",
		sourceID=sourceID
	};
	SMP_RefreshDragCursor();
end

function SMP_GetCursorMacroData()
	return SMP_CURSOR_MACRO;
end

local function SMP_GetCursorWatchFrame()
	if ( SMP_CURSOR_WATCH_FRAME ) then return SMP_CURSOR_WATCH_FRAME; end
	if ( not CreateFrame ) then return nil; end

	local frame=CreateFrame("Frame");
	frame:RegisterEvent("CURSOR_UPDATE");
	frame:SetScript("OnEvent", function()
		if ( event~="CURSOR_UPDATE" ) then return; end
		-- PickupMacro/PickupAction/PlaceAction cause their own cursor update. That
		-- event describes an operation initiated by Plus, not a cancellation.
		if ( SMP_EXPECT_CURSOR_UPDATE ) then
			return;
		end
		-- Category tabs are the one intentional exception: the tracked macro must
		-- survive their native cursor update so it can be dropped on another tab.
		if ( SMP_PRESERVE_CURSOR_UPDATE ) then
			return;
		end
		-- Native UI code can empty the cursor without calling the Lua ClearCursor
		-- hook. Mirror that cancellation into the custom drag cursor.
		if ( SMP_CURSOR_MACRO ) then
			SMP_AbandonPendingActionPickup();
			SMP_ResetTrackedCursor();
		end
	end);
	frame:SetScript("OnUpdate", function()
		-- CURSOR_UPDATE is normally delivered before the next update. Expire the
		-- guards quickly so a later, unrelated cancellation is never swallowed.
		if ( SMP_EXPECT_CURSOR_UPDATE ) then
			SMP_EXPECT_CURSOR_UPDATE=SMP_EXPECT_CURSOR_UPDATE-1;
			if ( SMP_EXPECT_CURSOR_UPDATE<=0 ) then SMP_EXPECT_CURSOR_UPDATE=nil; end
		end
		if ( SMP_PRESERVE_CURSOR_UPDATE ) then
			SMP_PRESERVE_CURSOR_UPDATE=SMP_PRESERVE_CURSOR_UPDATE-1;
			if ( SMP_PRESERVE_CURSOR_UPDATE<=0 ) then SMP_PRESERVE_CURSOR_UPDATE=nil; end
		end
	end);
	SMP_CURSOR_WATCH_FRAME=frame;
	return frame;
end

local function SMP_ExpectCursorUpdate()
	SMP_EXPECT_CURSOR_UPDATE=2;
	SMP_GetCursorWatchFrame();
end

function SMP_PreserveDragCursor()
	if ( not SMP_CURSOR_MACRO ) then return; end
	SMP_PRESERVE_CURSOR_UPDATE=2;
	SMP_GetCursorWatchFrame();
end

function ClearCursor()
	SMP_AbandonPendingActionPickup();
	SMP_ResetTrackedCursor();
	oldClearCursor();
end

function SMP_GetCarrierMacroIndex()
	local index=GetMacroIndexByName(SMP_CARRIER_MACRO_NAME);
	if ( index and index>0 ) then return index; end
	local numAccountMacros=GetNumMacros();
	if ( numAccountMacros<SMP_MAX_MACROS ) then
		index=CreateMacro(SMP_CARRIER_MACRO_NAME, 1, "", nil, false);
		if ( index and index>0 ) then return index; end
	end
	if ( GetMacroInfo(1) ) then return 1; end
	return nil;
end

function PickupMacro(macroid, supername)
	SMP_AbandonPendingActionPickup();
	if ( supername ) then
		local texture = GetSuperMacroPlusInfo(supername,"texture");
		if ( not texture ) then
			SMP_ResetTrackedCursor();
			if ( type(SM_SUPER)=="table" and type(SM_SUPER[supername])=="table" ) then
				local legacy=SM_SUPER[supername];
				SMP_SetCursorMacroData(legacy[1] or supername, legacy[2], legacy[3], "legacy", supername);
			end
			-- Let an earlier SuperMacro-compatible hook handle its own macro.
			SMP_ExpectCursorUpdate();
			oldPickupMacro(macroid, supername);
			return;
		end
		local carrier=SMP_GetCarrierMacroIndex();
		if ( not carrier ) then
			SMP_ResetTrackedCursor();
			SMP_PrintError(SMP_CARRIER_ERROR);
			return;
		end
		SMP_CURSOR=supername;
		SMP_SetCursorMacroData(supername, texture, GetSuperMacroPlusInfo(supername,"body"), "plus", supername);
		local tempicon=SMP_MACRO_ICON[texture] or 1;
		local macroname, macroicon=GetMacroInfo(carrier);
		macroicon=SMP_MACRO_ICON[macroicon] or 1;
		EditMacro(carrier,macroname, tempicon);
		SMP_ExpectCursorUpdate();
		oldPickupMacro(carrier);
		EditMacro(carrier,macroname, macroicon);
	else
		SMP_ResetTrackedCursor();
		local name,texture,body=GetMacroInfo(macroid);
		if ( name==SMP_CARRIER_MACRO_NAME ) then
			SMP_NATIVE_CARRIER_CURSOR=1;
		end
		SMP_SetCursorMacroData(name, texture, body, "native", macroid);
		SMP_ExpectCursorUpdate();
		oldPickupMacro(macroid);
	end
end

function PickupContainerItem(index, slot)
	SMP_AbandonPendingActionPickup();
	SMP_ResetTrackedCursor();
	oldPickupContainerItem(index, slot);
end

function PickupInventoryItem(index)
	SMP_AbandonPendingActionPickup();
	SMP_ResetTrackedCursor();
	oldPickupInventoryItem(index);
end

function PickupSpell(index, book)
	SMP_AbandonPendingActionPickup();
	SMP_ResetTrackedCursor();
	oldPickupSpell(index, book);
end

function PickupAction(id)
	SMP_AbandonPendingActionPickup();
	local managedName=SMP_GetManagedActionName(id);
	if ( managedName ) then
		SMP_CURSOR=managedName;
		local texture = GetSuperMacroPlusInfo(SMP_CURSOR,"texture");
		if ( texture ) then
			SMP_PENDING_ACTION_PICKUP={slot=id, name=managedName};
			SMP_SetCursorMacroData(SMP_CURSOR, texture, GetSuperMacroPlusInfo(SMP_CURSOR,"body"), "plus", id);
			local carrier=SMP_GetCarrierMacroIndex();
			if ( not carrier ) then
				SMP_PENDING_ACTION_PICKUP=nil;
				SMP_ResetTrackedCursor();
				SMP_PrintError(SMP_CARRIER_ERROR);
				return;
			end
			local tempicon=SMP_MACRO_ICON[texture] or 1;
			local macroname, macroicon=GetMacroInfo(carrier);
			macroicon=SMP_MACRO_ICON[macroicon] or 1;
			EditMacro(carrier,macroname, tempicon);
			SMP_ACTION[id]=nil;
			SMP_ExpectCursorUpdate();
			oldPickupAction(id);
			EditMacro(carrier,macroname, macroicon);
		else
			SMP_ACTION_RECOVERY[id]=nil;
			SMP_ResetTrackedCursor();
			SMP_ACTION[id]=nil;
			SMP_ExpectCursorUpdate();
			oldPickupAction(id);
		end
	else
		SMP_ACTION_RECOVERY[id]=nil;
		SMP_ResetTrackedCursor();
		local actionName=oldGetActionText(id);
		if ( actionName ) then
			if ( actionName==SMP_CARRIER_MACRO_NAME ) then
				SMP_NATIVE_CARRIER_CURSOR=1;
			end
			local macroID=GetMacroIndexByName(actionName);
			if ( macroID and macroID>0 ) then
				local name,texture,body=GetMacroInfo(macroID);
				SMP_SetCursorMacroData(name, texture, body, "native", macroID);
			elseif ( type(SM_SUPER)=="table" and type(SM_SUPER[actionName])=="table" ) then
				local legacy=SM_SUPER[actionName];
				SMP_SetCursorMacroData(legacy[1] or actionName, legacy[2], legacy[3], "legacy", id);
			end
		end
		SMP_ACTION[id]=nil;
		SMP_ExpectCursorUpdate();
		oldPickupAction(id);
	end
end


function PlaceAction(id)
	-- place and pickup super
	local sourceName=(SMP_CURSOR and type(SMP_SUPER[SMP_CURSOR])=="table") and SMP_CURSOR or nil;
	local targetName=SMP_GetManagedActionName(id);
	local preserveCarrier=SMP_NATIVE_CARRIER_CURSOR and targetName and 1 or nil;
	local newName=preserveCarrier and targetName or sourceName;
	SMP_ACTION[id]=newName;
	SMP_CURSOR=preserveCarrier and nil or targetName;
	SMP_ExpectCursorUpdate();
	oldPlaceAction(id);
	if ( preserveCarrier ) then
		-- Action-bar profile addons may replay the native carrier by name. It is
		-- only transport for the existing Plus mapping, never a user macro.
		oldClearCursor();
	end
	if ( SMP_PENDING_ACTION_PICKUP and SMP_PENDING_ACTION_PICKUP.slot ) then
		SMP_ACTION_RECOVERY[SMP_PENDING_ACTION_PICKUP.slot]=nil;
	end
	SMP_PENDING_ACTION_PICKUP=nil;
	if ( newName ) then
		SMP_ACTION_RECOVERY[id]=newName;
	else
		SMP_ACTION_RECOVERY[id]=nil;
	end
	SMP_NATIVE_CARRIER_CURSOR=nil;
	if ( SMP_CURSOR and SMP_SUPER[SMP_CURSOR] ) then
		SMP_SetCursorMacroData(SMP_CURSOR, SMP_SUPER[SMP_CURSOR][2], SMP_SUPER[SMP_CURSOR][3], "plus", id);
	else
		SMP_CURSOR_MACRO=nil;
		SMP_RefreshDragCursor();
	end
end

function UseAction( id, click, selfcast)
	lastActionUsed = id;
	if ( SuperMacroPlusFrame_SaveSuperMacroPlus and SuperMacroPlusFrame:IsVisible() ) then
		SuperMacroPlusFrame_SaveSuperMacroPlus();
	end
	local managedName=SMP_GetManagedActionName(id);
	if ( managedName ) then
		RunSuperMacroPlus(managedName);
	elseif ( SMP_IsCarrierAction(id) ) then
		-- Never execute the empty internal carrier as if it were a user macro.
		return;
	elseif ( type(SM_ACTION)=="table" and SM_ACTION[id] ) then
		-- When the original SuperMacro addon is enabled, let its captured
		-- UseAction hook execute slots that it owns. Running these through the
		-- Plus regular-macro path would lose the SuperMacro body.
		oldUseAction( id, click, selfcast );
	elseif ( GetActionText(id) ) then
		SuperMacroPlus_RunMacro(GetActionText(id));
	else
		oldUseAction( id, click, selfcast );
	end
end

function GetActionText(id)
	local managedName=SMP_GetManagedActionName(id);
	if ( managedName ) then return managedName; end
	local actionName=oldGetActionText(id);
	if ( actionName==SMP_CARRIER_MACRO_NAME ) then return nil; end
	return actionName;
end

function GetActionTexture(id)
	local managedName=SMP_GetManagedActionName(id);
	if ( managedName ) then
		if ( SMP_VARS and SMP_VARS.replaceIcon==1 and SMP_GetActionSpell ) then
			local _,_,inferredTexture=SMP_GetActionSpell(managedName, "super");
			if ( inferredTexture ) then return inferredTexture; end
		end
		return GetSuperMacroPlusInfo(managedName, "texture");
	end
	if ( SMP_IsCarrierAction(id) ) then return nil; end
	return oldGetActionTexture(id);
end

function SuperMacroPlus_UpdateAction(oldsuper, newsuper)
	for k,v in SMP_ACTION do
		if v==oldsuper then
			SMP_ACTION[k]=newsuper;
			SMP_ACTION_RECOVERY[k]=newsuper;
		end
	end
	for k,v in pairs(SMP_ACTION_RECOVERY) do
		if ( v==oldsuper ) then SMP_ACTION_RECOVERY[k]=newsuper; end
	end
end

function SetActionSuperMacroPlus(actionid, supername)
	if ( supername and actionid > 0 and actionid <= 120 ) then
		PickupAction( actionid );
		PickupMacro(1, supername );
		PlaceAction ( actionid );
	end
end

-- SavedVariables preserve which Plus macro owns each action slot, while the
-- client/server action profile separately preserves the native action placed in
-- that slot.  When a profile is copied to another character, rebuild the native
-- carrier actions once so every stance page can resolve its copied mapping.
function SMP_HydrateManagedActions()
	if ( type(SMP_ACTION)~="table" or type(SMP_SUPER)~="table" ) then
		return nil, 0, 0, 0;
	end
	if ( UnitAffectingCombat and UnitAffectingCombat("player") ) then
		return nil, 0, 0, 0;
	end

	local carrier=SMP_GetCarrierMacroIndex();
	if ( not carrier ) then
		SMP_PrintError(SMP_CARRIER_ERROR);
		return nil, 0, 0, 0;
	end

	local expected=0;
	local hydrated=0;
	local changed=0;
	oldClearCursor();
	for id=1,120 do
		local name=SMP_ACTION[id];
		if ( type(name)=="string" and type(SMP_SUPER[name])=="table" ) then
			expected=expected+1;
			if ( oldGetActionText(id)~=SMP_CARRIER_MACRO_NAME ) then
				oldPickupMacro(carrier);
				oldPlaceAction(id);
				oldClearCursor();
				changed=changed+1;
			end
			if ( oldGetActionText(id)==SMP_CARRIER_MACRO_NAME ) then
				hydrated=hydrated+1;
				SMP_ACTION_RECOVERY[id]=name;
			end
		end
	end
	oldClearCursor();
	SMP_RebuildActionRecovery();
	return expected>0 and hydrated==expected, changed, expected, hydrated;
end

local SMP_ACTION_HYDRATION_PLAYER="冠军水管 of Basin of Stars";
local SMP_ACTION_HYDRATION_VERSION="bigaxe-warrior-stances-v1";
local SMP_ACTION_HYDRATION_FRAME=CreateFrame("Frame");
local SMP_ACTION_HYDRATION_DELAY;

local function SMP_GetActionHydrationPlayerKey()
	if ( SMP_PLAYER_KEY ) then return SMP_PLAYER_KEY; end
	local player=UnitName("player");
	local realm=GetRealmName();
	if ( player and realm ) then return player.." of "..realm; end
	return nil;
end

local function SMP_ActionHydrationIsPending()
	if ( SMP_GetActionHydrationPlayerKey()~=SMP_ACTION_HYDRATION_PLAYER ) then
		return nil;
	end
	if ( type(SMP_VARS)~="table" ) then return nil; end
	if ( type(SMP_VARS.actionHydrationVersions)~="table" ) then
		SMP_VARS.actionHydrationVersions={};
	end
	return SMP_VARS.actionHydrationVersions[SMP_ACTION_HYDRATION_PLAYER]~=SMP_ACTION_HYDRATION_VERSION;
end

local function SMP_RunPendingActionHydration()
	if ( not SMP_ActionHydrationIsPending() ) then return; end
	if ( UnitAffectingCombat and UnitAffectingCombat("player") ) then
		SMP_ACTION_HYDRATION_FRAME:RegisterEvent("PLAYER_REGEN_ENABLED");
		return;
	end

	local complete,changed,expected,hydrated=SMP_HydrateManagedActions();
	if ( complete ) then
		SMP_VARS.actionHydrationVersions[SMP_ACTION_HYDRATION_PLAYER]=SMP_ACTION_HYDRATION_VERSION;
		SMP_ACTION_HYDRATION_FRAME:UnregisterEvent("PLAYER_REGEN_ENABLED");
		SMP_PrintMessage("已按大斧黑牛重建冠军水管的动作栏超级宏槽："..hydrated.."/"..expected.."（本次覆盖 "..changed.." 个）。");
	else
		SMP_PrintError("冠军水管动作栏超级宏槽重建未完成："..hydrated.."/"..expected.."；脱离战斗后会重试。");
		SMP_ACTION_HYDRATION_FRAME:RegisterEvent("PLAYER_REGEN_ENABLED");
	end
end

local function SMP_ScheduleActionHydration(delay)
	if ( not SMP_ActionHydrationIsPending() ) then return; end
	SMP_ACTION_HYDRATION_DELAY=delay or 1;
	SMP_ACTION_HYDRATION_FRAME:SetScript("OnUpdate", function()
		SMP_ACTION_HYDRATION_DELAY=SMP_ACTION_HYDRATION_DELAY-arg1;
		if ( SMP_ACTION_HYDRATION_DELAY<=0 ) then
			SMP_ACTION_HYDRATION_FRAME:SetScript("OnUpdate", nil);
			SMP_RunPendingActionHydration();
		end
	end);
end

SMP_ACTION_HYDRATION_FRAME:RegisterEvent("PLAYER_ENTERING_WORLD");
SMP_ACTION_HYDRATION_FRAME:SetScript("OnEvent", function()
	if ( event=="PLAYER_ENTERING_WORLD" ) then
		SMP_ScheduleActionHydration(1);
	elseif ( event=="PLAYER_REGEN_ENABLED" ) then
		SMP_ACTION_HYDRATION_FRAME:UnregisterEvent("PLAYER_REGEN_ENABLED");
		SMP_ScheduleActionHydration(0.1);
	end
end);

function SMP_ActionButton_OnClick()
	if ( SMP_CURSOR ) then
		PlaceAction(ActionButton_GetPagedID(this));
		ActionButton_UpdateState();
		return 1;
	end
end
