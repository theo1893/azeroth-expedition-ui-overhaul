local module, L = BigWigs:ModuleDeclaration("Anomalus", "Karazhan")

-- module variables
module.revision = 30000
module.enabletrigger = module.translatedName
module.toggleoptions = { "arcaneoverload", "arcaneprison", "manaboundstrike", "manaboundframe", "markdampenedplayers", "bosskill" }
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Tower of Karazhan"],
	AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"],
}

-- module defaults
module.defaultDB = {
	arcaneoverload = true,
	arcaneprison = true,
	manaboundstrike = true,
	manaboundframe = true,
	manaboundframeposx = 100,
	manaboundframeposy = 300,
	markdampenedplayers = true,
}

-- localization
L:RegisterTranslations("enUS", function()
	return {
		cmd = "Anomalus",

		arcaneoverload_cmd = "arcaneoverload",
		arcaneoverload_name = "Arcane Overload Alert",
		arcaneoverload_desc = "Warns when players get affected by Arcane Overload",

		arcaneprison_cmd = "arcaneprison",
		arcaneprison_name = "Arcane Prison Alert",
		arcaneprison_desc = "Warns when players get affected by Arcane Prison",

		manaboundstrike_cmd = "manaboundstrike",
		manaboundstrike_name = "Manabound Strike Alert",
		manaboundstrike_desc = "Warns when players get affected by Manabound Strike stacks",

		manaboundframe_cmd = "manaboundframe",
		manaboundframe_name = "Manabound Strikes Frame",
		manaboundframe_desc = "Shows a frame with player stacks and timers for Manabound Strikes",

		markdampenedplayers_cmd = "markdampenedplayers",
		markdampenedplayers_name = "Mark Dampened Players",
		markdampenedplayers_desc = "Mark players affected by Arcane Dampening if there are unused raid icons (requires assistant or leader)",

		trigger_arcaneOverloadYou = "You are afflicted by Arcane Overload",
		trigger_arcaneOverloadOther = "(.+) is afflicted by Arcane Overload",
		msg_arcaneOverloadYou = "BOMB ON YOU - DPS HARD THEN RUN AWAY!",
		msg_arcaneOverloadOther = "BOMB on %s!",
		bar_arcaneOverload = "Next Bomb",
		bar_arcaneOverloadExplosion = "BOMB ON YOU Explosion",

		trigger_arcanePrison = "(.+) is afflicted by Arcane Prison",
		msg_arcanePrison = "Arcane Prison on %s!",

		trigger_manaboundStrike = "(.+) is afflicted by Manabound Strikes %((%d+)%)",
		trigger_manaboundFade = "Manabound Strikes fades from (.+)",

		trigger_arcaneDampening = "(.+) is afflicted by Arcane Dampening",
		trigger_arcaneDampeningFade = "Arcane Dampening fades from (.+)",

		bar_manaboundExpire = "Manabound stacks expire",
	}
end)

L:RegisterTranslations("zhCN", function()
    return {
        cmd = "Anomalus",

        arcaneoverload_cmd = "奥术过载",
        arcaneoverload_name = "奥术过载警报",
        arcaneoverload_desc = "当玩家受到奥术过载影响时发出警告",

        arcaneprison_cmd = "奥术牢笼",
        arcaneprison_name = "奥术牢笼警报",
        arcaneprison_desc = "当玩家受到奥术牢笼影响时发出警告",

        manaboundstrike_cmd = "法力束缚打击",
        manaboundstrike_name = "法力束缚打击警报",
        manaboundstrike_desc = "当玩家受到法力束缚打击层数影响时发出警告",

        manaboundframe_cmd = "法力束缚框架",
        manaboundframe_name = "法力束缚打击框架",
        manaboundframe_desc = "显示一个带有玩家法力束缚打击层数和计时的框架",

        markdampenedplayers_cmd = "标记减益玩家",
        markdampenedplayers_name = "标记受减益影响的玩家",
        markdampenedplayers_desc = "如果有未使用的团队标记，标记受到奥术减益影响的玩家（需要助手或团长权限）",

        trigger_arcaneOverloadYou = "你受到了奥术超载效果的影响",
        trigger_arcaneOverloadOther = "(.+)受到了奥术超载效果的影响",
        msg_arcaneOverloadYou = "你身上有炸弹 - 用力输出然后跑开！",
        msg_arcaneOverloadOther = "%s身上有炸弹！",
        bar_arcaneOverload = "下一个炸弹",
        bar_arcaneOverloadExplosion = "你的炸弹即将爆炸",

        trigger_arcanePrison = "(.+)受到奥术牢笼影响",
        msg_arcanePrison = "%s受到奥术牢笼影响！",

        trigger_manaboundStrike = "(.+)受到了法力束缚打击效果的影响%（(%d+)%）",
        trigger_manaboundFade = "法力束缚打击效果从(.+)身上消失了",

        trigger_arcaneDampening = "(.+)受到了奥术抑制效果的影响",
        trigger_arcaneDampeningFade = "奥术抑制效果从(.+)身上消失了",

        bar_manaboundExpire = "法力束缚层数消失",
    }
end)

-- timer and icon variables
local timer = {
	arcaneOverload = {
		7, 15, 13.5, 12.1, 10.9, 9.8, 8.8, 8, 7.2, 6.5, 5.8, 5.2, 4.5
	},
	minArcaneOverload = 4.5, -- minimum time between Arcane Overload casts
	manaboundDuration = 60,
	arcaneOverloadExplosion = 15,
	arcaneDampening = 45, -- duration of Arcane Dampening
}

local icon = {
	arcaneOverload = "INV_Misc_Bomb_04",
	arcanePrison = "Spell_Frost_Glacier",
	manaboundStrike = "Spell_Arcane_FocusedPower",
	manaboundExpire = "Spell_Holy_FlashHeal",
	arcaneDampening = "Spell_Nature_AbolishMagic", -- icon for Arcane Dampening
}

local syncName = {
	arcaneOverload = "AnomalusArcaneOverload" .. module.revision,
	arcanePrison = "AnomalusArcanePrison" .. module.revision,
	manaboundStrike = "AnomalusManaboundStrike" .. module.revision,
	manaboundStrikeFade = "AnomalusManaboundStrikeFade" .. module.revision,
	arcaneDampening = "AnomalusArcaneDampening" .. module.revision,
	arcaneDampeningFade = "AnomalusArcaneDampeningFade" .. module.revision,
}

local maxManaboundPlayers = 10
local arcaneOverloadCount = 0
local manaboundStrikesPlayers = {}
local dampenedPlayers = {}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	self:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH")

	self:ThrottleSync(3, syncName.arcaneOverload)
	self:ThrottleSync(3, syncName.arcanePrison)
	self:ThrottleSync(3, syncName.manaboundStrike)
	self:ThrottleSync(3, syncName.manaboundStrikeFade)
	self:ThrottleSync(3, syncName.arcaneDampening)
	self:ThrottleSync(3, syncName.arcaneDampeningFade)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	arcaneOverloadCount = 0
	manaboundStrikesPlayers = {}
	dampenedPlayers = {}

	if self.db.profile.arcaneoverload then
		self:Bar(L["bar_arcaneOverload"], timer.arcaneOverload[arcaneOverloadCount], icon.arcaneOverload)
	end
end

function module:AfflictionEvent(msg)
	-- Arcane Overload
	if string.find(msg, L["trigger_arcaneOverloadYou"]) then
		self:Sync(syncName.arcaneOverload .. " " .. UnitName("player"))
	else
		local _, _, player = string.find(msg, L["trigger_arcaneOverloadOther"])
		if player then
			self:Sync(syncName.arcaneOverload .. " " .. player)
		end
	end

	-- Arcane Prison
	local _, _, player = string.find(msg, L["trigger_arcanePrison"])
	if player then
		self:Sync(syncName.arcanePrison .. " " .. player)
	end

	-- Manabound Strikes
	local _, _, player, count = string.find(msg, L["trigger_manaboundStrike"])
	if player and count then
		self:Sync(syncName.manaboundStrike .. " " .. player .. " " .. count)
	end

	-- Arcane Dampening
	local _, _, player = string.find(msg, L["trigger_arcaneDampening"])
	if player then
		self:Sync(syncName.arcaneDampening .. " " .. player)
	end
end

function module:CHAT_MSG_SPELL_AURA_GONE_SELF(msg)
	local _, _, player = string.find(msg, L["trigger_manaboundFade"])
	if player then
		self:Sync(syncName.manaboundStrikeFade .. " " .. player)
	end

	-- Arcane Dampening faded
	local _, _, player = string.find(msg, L["trigger_arcaneDampeningFade"])
	if player then
		self:Sync(syncName.arcaneDampeningFade .. " " .. player)
	end

	-- remove bar
	self:RemoveBar(L["bar_manaboundExpire"])
end

function module:CHAT_MSG_SPELL_AURA_GONE_PARTY(msg)
	local _, _, player = string.find(msg, L["trigger_manaboundFade"])
	if player then
		self:Sync(syncName.manaboundStrikeFade .. " " .. player)
	end

	-- Arcane Dampening faded
	local _, _, player = string.find(msg, L["trigger_arcaneDampeningFade"])
	if player then
		self:Sync(syncName.arcaneDampeningFade .. " " .. player)
	end
end

function module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	local _, _, player = string.find(msg, L["trigger_manaboundFade"])
	if player then
		self:Sync(syncName.manaboundStrikeFade .. " " .. player)
	end

	-- Arcane Dampening faded
	local _, _, player = string.find(msg, L["trigger_arcaneDampeningFade"])
	if player then
		self:Sync(syncName.arcaneDampeningFade .. " " .. player)
	end
end

function module:CHAT_MSG_COMBAT_FRIENDLY_DEATH(msg)
	-- Remove raid marker when a player dies
	local _, _, player = string.find(msg, "(.+)死亡了")
	if player and self.db.profile.markdampenedplayers and dampenedPlayers[player] then
		self:RemoveDampenedPlayerMark(player)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.arcaneOverload and rest then
		self:ArcaneOverload(rest)
	elseif sync == syncName.arcanePrison and rest then
		self:ArcanePrison(rest)
	elseif string.find(sync, syncName.manaboundStrike) and rest then
		local _, _, player, count = string.find(rest, "([^%s]+)(%d+)")
		if player and count then
			self:ManaboundStrike(player, count)
		end
	elseif sync == syncName.manaboundStrikeFade and rest then
		self:ManaboundStrikeFade(rest)
	elseif sync == syncName.arcaneDampening and rest then
		self:ArcaneDampening(rest)
	elseif sync == syncName.arcaneDampeningFade and rest then
		self:ArcaneDampeningFade(rest)
	end
end

function module:ArcaneOverload(player)
	arcaneOverloadCount = arcaneOverloadCount + 1

	-- Calculate next timer (minimum 7 seconds)
	local nextTimer = timer.arcaneOverload[arcaneOverloadCount] or timer.minArcaneOverload

	if self.db.profile.arcaneoverload then
		if player == UnitName("player") then
			self:Message(L["msg_arcaneOverloadYou"], "Important", true, "Alarm")
			self:WarningSign(icon.arcaneOverload, 5, true, "你是炸弹！")
			-- Add personal explosion bar with red color
			self:Bar(L["bar_arcaneOverloadExplosion"], timer.arcaneOverloadExplosion, icon.arcaneOverload, true, "red")
		else
			self:Message(string.format(L["msg_arcaneOverloadOther"], player), "Important")

			if IsRaidLeader() or IsRaidOfficer() then
				for i = 1, GetNumRaidMembers() do
					if UnitName("raid" .. i) == player then
						SetRaidTarget("raid" .. i, 7)
					end
				end
			end
		end

		self:RemoveBar(L["bar_arcaneOverload"])
		self:Bar(L["bar_arcaneOverload"], nextTimer, icon.arcaneOverload)
	end
end

function module:ArcanePrison(player)
	if self.db.profile.arcaneprison then
		self:Message(string.format(L["msg_arcanePrison"], player), "Attention")
	end
end

function module:ManaboundStrike(player, count)
	if tonumber(count) then
		-- Update or add player to tracking table
		manaboundStrikesPlayers[player] = {
			count = tonumber(count),
			expires = GetTime() + timer.manaboundDuration
		}

		-- Only show bar for the player's own debuff
		if player == UnitName("player") and self.db.profile.manaboundstrike then
			self:RemoveBar(L["bar_manaboundExpire"])
			self:Bar(L["bar_manaboundExpire"], timer.manaboundDuration, icon.manaboundExpire)
		end

	end
end

function module:ManaboundStrikeFade(player)
	-- Remove player from tracking table
	if manaboundStrikesPlayers[player] then
		manaboundStrikesPlayers[player] = nil

		-- Only remove the player's own bar
		if player == UnitName("player") then
			self:RemoveBar(L["bar_manaboundExpire"])
		end

	end
end

function module:ArcaneDampening(player)
	if self.db.profile.markdampenedplayers and (IsRaidLeader() or IsRaidOfficer()) then
		dampenedPlayers[player] = true
		self:MarkDampenedPlayer(player)
	end
	-- Add bar for the player with Arcane Dampening
	if player == UnitName("player") then
		self:Bar("Arcane Dampening - Can Soak", timer.arcaneDampening, icon.arcaneDampening)
	end
end

function module:ArcaneDampeningFade(player)
	if self.db.profile.markdampenedplayers and dampenedPlayers[player] then
		self:RemoveDampenedPlayerMark(player)
	end

	-- Remove the bar if it's the player
	if player == UnitName("player") then
		self:RemoveBar("Arcane Dampening - Can Soak")
	end
end

function module:MarkDampenedPlayer(player)
	if not (IsRaidLeader() or IsRaidOfficer()) then
		return
	end

	local playerUnit = nil
	for i = 1, GetNumRaidMembers() do
		if UnitName("raid" .. i) == player then
			playerUnit = "raid" .. i
			break
		end
	end

	if not playerUnit then
		return
	end

	-- Find next available raid mark (don't use skull/8)
	local usedMarks = {}
	for i = 1, GetNumRaidMembers() do
		local mark = GetRaidTargetIndex("raid" .. i)
		if mark then
			usedMarks[mark] = true
		end
	end

	for i = 1, 7 do
		if not usedMarks[i] then
			SetRaidTarget(playerUnit, i)
			dampenedPlayers[player] = i -- Store which mark was used
			break
		end
	end
end

function module:RemoveDampenedPlayerMark(player)
	if not (IsRaidLeader() or IsRaidOfficer()) then
		return
	end

	for i = 1, GetNumRaidMembers() do
		if UnitName("raid" .. i) == player then
			SetRaidTarget("raid" .. i, 0)
			break
		end
	end

	dampenedPlayers[player] = nil
end

function module:Test()
	-- Initialize module state
	self:OnSetup()
	self:OnEngage()

	local events = {
		-- Arcane Overload events
		{ time = 5, func = function()
			print("Test: Player gets Arcane Overload")
			module:AfflictionEvent("Player1 is afflicted by Arcane Overload")
		end },
		{ time = 15, func = function()
			print("Test: You get Arcane Overload")
			module:AfflictionEvent("You are afflicted by Arcane Overload")
		end },

		-- Arcane Prison event
		{ time = 10, func = function()
			print("Test: Player gets Arcane Prison")
			module:AfflictionEvent("Player3 is afflicted by Arcane Prison")
		end },

		-- Arcane Dampening events
		{ time = 12, func = function()
			print("Test: Tankeboy gets Arcane Dampening")
			module:AfflictionEvent("Tankeboy is afflicted by Arcane Dampening")
		end },
		{ time = 16, func = function()
			print("Test: Pepopo gets Arcane Dampening")
			module:AfflictionEvent("Pepopo is afflicted by Arcane Dampening")
		end },
		{ time = 22, func = function()
			print("Test: Arcane Dampening fades from Pepopo")
			module:CHAT_MSG_SPELL_AURA_GONE_PARTY("Arcane Dampening fades from Pepopo")
		end },
		{ time = 25, func = function()
			print("Test: Pepopo gets Arcane Dampening")
			module:AfflictionEvent("Pepopo is afflicted by Arcane Dampening")
		end },
		{ time = 28, func = function()
			print("Test: Pepopo dies")
			module:CHAT_MSG_COMBAT_FRIENDLY_DEATH("Pepopo dies")
		end },

		-- Manabound Strikes events
		{ time = 3, func = function()
			print("Test: Player1 gets Manabound Strikes (1)")
			module:AfflictionEvent("Player1 is afflicted by Manabound Strikes (1)")
		end },
		{ time = 8, func = function()
			print("Test: Player2 gets Manabound Strikes (1)")
			module:AfflictionEvent("Player2 is afflicted by Manabound Strikes (1)")
		end },
		{ time = 13, func = function()
			print("Test: Player1 gets Manabound Strikes (2)")
			module:AfflictionEvent("Player1 is afflicted by Manabound Strikes (2)")
		end },
		{ time = 18, func = function()
			print("Test: Player3 gets Manabound Strikes (1)")
			module:AfflictionEvent("Player3 is afflicted by Manabound Strikes (1)")
		end },
		{ time = 20, func = function()
			print("Test: Player2 gets Manabound Strikes (2)")
			module:AfflictionEvent("Player2 is afflicted by Manabound Strikes (2)")
		end },
		{ time = 25, func = function()
			print("Test: Player3 gets Manabound Strikes (2)")
			module:AfflictionEvent("Player3 is afflicted by Manabound Strikes (2)")
		end },
		{ time = 30, func = function()
			print("Test: Player1 gets Manabound Strikes (3)")
			module:AfflictionEvent("Player1 is afflicted by Manabound Strikes (3)")
		end },
		{ time = 35, func = function()
			print("Test: Player2 gets Manabound Strikes (3)")
			module:AfflictionEvent("Player2 is afflicted by Manabound Strikes (3)")
		end },
		{ time = 40, func = function()
			print("Test: Player3 gets Manabound Strikes (3)")
			module:AfflictionEvent("Player3 is afflicted by Manabound Strikes (3)")
		end },
		{ time = 45, func = function()
			print("Test: Player4 gets Manabound Strikes (1)")
			module:AfflictionEvent("Player4 is afflicted by Manabound Strikes (1)")
		end },
		{ time = 50, func = function()
			print("Test: Player1 gets Manabound Strikes (4)")
			module:AfflictionEvent("Player1 is afflicted by Manabound Strikes (4)")
		end },
		{ time = 53, func = function()
			print("Test: You get Manabound Strikes (7)")
			local playerName = UnitName("player")
			module:AfflictionEvent(playerName .. " is afflicted by Manabound Strikes (7)")
		end },
		{ time = 70, func = function()
			print("Test: Manabound Strikes fades from Player2")
			module:CHAT_MSG_SPELL_AURA_GONE_PARTY("Manabound Strikes fades from Player2")
		end },
		{ time = 75, func = function()
			print("Test: Manabound Strikes fades from Pepopo")
			module:CHAT_MSG_SPELL_AURA_GONE_PARTY("Manabound Strikes fades from Pepopo")
		end },
		{ time = 80, func = function()
			print("Test: Disengage")
			module:OnDisengage()
		end },
	}

	-- Schedule each event at its absolute time
	for i, event in ipairs(events) do
		self:ScheduleEvent("AnomalusTest" .. i, event.func, event.time)
	end

	self:Message("Anomalus test started", "Positive")
	return true
end

-- Test command:
-- /run local m=BigWigs:GetModule("Anomalus"); BigWigs:SetupModule("Anomalus");m:Test();
