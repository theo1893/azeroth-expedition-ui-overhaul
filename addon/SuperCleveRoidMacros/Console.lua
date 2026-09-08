--[[
	Author: Dennis Werner Garske (DWG) / brian / Mewtiny
	License: MIT License
]]
local _G = _G or getfenv(0)
local CleveRoids = _G.CleveRoids or {}

SLASH_PETATTACK1 = "/petattack"

SlashCmdList.PETATTACK = function(msg) CleveRoids.DoPetAction(PetAttack, msg); end

SLASH_PETFOLLOW1 = "/petfollow"

SlashCmdList.PETFOLLOW = function(msg) CleveRoids.DoPetAction(PetFollow, msg); end

SLASH_PETWAIT1 = "/petwait"

SlashCmdList.PETWAIT = function(msg) CleveRoids.DoPetAction(PetWait, msg); end

SLASH_PETPASSIVE1 = "/petpassive"

SlashCmdList.PETPASSIVE = function(msg) CleveRoids.DoPetAction(PetPassiveMode, msg); end

SLASH_PETAGGRESSIVE1 = "/petaggressive"

SlashCmdList.PETAGGRESSIVE = function(msg) CleveRoids.DoPetAction(PetAggressiveMode, msg); end

SLASH_PETDEFENSIVE1 = "/petdefensive"

SlashCmdList.PETDEFENSIVE = function(msg) CleveRoids.DoPetAction(PetDefensiveMode, msg); end

SLASH_RELOAD1 = "/rl"

SlashCmdList.RELOAD = function() ReloadUI(); end

SLASH_USE1 = "/use"

SlashCmdList.USE = CleveRoids.DoUse

SLASH_EQUIP1 = "/equip"

SlashCmdList.EQUIP = CleveRoids.DoUse
-- take back supermacro and pfUI /equip and /use
SlashCmdList.SMEQUIP = CleveRoids.DoUse
SlashCmdList.PFEQUIP = CleveRoids.DoUse
SlashCmdList.PFUSE = CleveRoids.DoUse

SLASH_EQUIPMH1 = "/equipmh"
SlashCmdList.EQUIPMH = CleveRoids.DoEquipMainhand

SLASH_EQUIPOH1 = "/equipoh"
SlashCmdList.EQUIPOH = CleveRoids.DoEquipOffhand

SLASH_EQSLOT111 = "/equip11"
SlashCmdList.EQSLOT11 = CleveRoids.DoEquipRing1

SLASH_EQSLOT121 = "/equip12"
SlashCmdList.EQSLOT12 = CleveRoids.DoEquipRing2

SLASH_EQSLOT131 = "/equip13"
SlashCmdList.EQSLOT13 = CleveRoids.DoEquipTrinket1

SLASH_EQSLOT141 = "/equip14"
SlashCmdList.EQSLOT14 = CleveRoids.DoEquipTrinket2

SLASH_UNSHIFT1 = "/unshift"

SlashCmdList.UNSHIFT = CleveRoids.DoUnshift

SLASH_UNQUEUE1 = "/unqueue"
SlashCmdList.UNQUEUE = SpellStopCasting

-- TODO make this conditional too
SLASH_CANCELAURA1 = "/cancelaura"
SLASH_CANCELAURA2 = "/unbuff"

SlashCmdList.CANCELAURA = CleveRoids.DoConditionalCancelAura

SLASH_CASTPET1 = "/castpet"

SlashCmdList.CASTPET = function(msg)
    CleveRoids.DoCastPet(msg)
end

-- Define original implementations before hooking them.
-- This ensures we have a fallback for non-conditional use.
local StartAttack = function(msg)
    if not UnitExists("target") or CleveRoids.IsUnitDead("target") then TargetNearestEnemy() end
    -- Check both event-based flag AND action bar state for reliable detection
    local isAttacking = CleveRoids.CurrentSpell.autoAttack
    if not isAttacking then
        -- Fallback: check action bar state via IsCurrentAction
        local slot = CleveRoids.GetProxyActionSlot(CleveRoids.Localized.Attack)
        if slot and IsCurrentAction(slot) then
            CleveRoids.CurrentSpell.autoAttack = true
            isAttacking = true
        end
    end
    if not isAttacking and not CleveRoids.CurrentSpell.autoAttackLock and UnitExists("target") and UnitCanAttack("player","target") then
        CleveRoids.CurrentSpell.autoAttackLock = true
        CleveRoids.autoAttackLockElapsed = GetTime()
        AttackTarget()
        -- FIX: Immediately set autoAttack flag so subsequent macro lines know attack started
        -- Don't wait for PLAYER_ENTER_COMBAT event which has a delay
        CleveRoids.CurrentSpell.autoAttack = true
        -- FIX: Queue icon update so action bars reflect the new state
        if CleveRoidMacros and CleveRoidMacros.realtime == 0 then
            CleveRoids.QueueActionUpdate()
        end
    end
end

local StopAttack = function(msg)
    -- Deferred to next frame because CastSpellByName starts autoattack as a C++
    -- side-effect that hasn't settled yet — AttackTarget() toggle misses it.
    CleveRoids.DeferStopAttack()
end

-- Register slash commands and assign original handlers.
-- These will be hooked immediately after.
SLASH_STARTATTACK1 = "/startattack"
SlashCmdList.STARTATTACK = StartAttack

SLASH_STOPATTACK1 = "/stopattack"
SlashCmdList.STOPATTACK = StopAttack

SLASH_STOPCASTING1 = "/stopcasting"
SlashCmdList.STOPCASTING = SpellStopCasting

SLASH_CLEARTARGET1 = "/cleartarget"
SlashCmdList.CLEARTARGET = ClearTarget

----------------------------------
-- HOOK DEFINITIONS START
----------------------------------

-- /cleartarget hook
CleveRoids.Hooks.CLEARTARGET_SlashCmd = SlashCmdList.CLEARTARGET
SlashCmdList.CLEARTARGET = function(msg)
    if CleveRoids.stopMacroFlag then return end
    msg = msg or ""
    if string.find(msg, "%[") then
        CleveRoids.DoConditionalClearTarget(msg)
    else
        CleveRoids.Hooks.CLEARTARGET_SlashCmd()
    end
end

-- /startattack hook
CleveRoids.Hooks.STARTATTACK_SlashCmd = SlashCmdList.STARTATTACK
SlashCmdList.STARTATTACK = function(msg)
    if CleveRoids.stopMacroFlag then return end
    msg = msg or ""
    if string.find(msg, "%[") then
        CleveRoids.DoConditionalStartAttack(msg)
    else
        CleveRoids.Hooks.STARTATTACK_SlashCmd(msg)
    end
end

-- /stopattack hook
CleveRoids.Hooks.STOPATTACK_SlashCmd = SlashCmdList.STOPATTACK
SlashCmdList.STOPATTACK = function(msg)
    if CleveRoids.stopMacroFlag then return end
    msg = msg or ""
    if string.find(msg, "%[") then
        -- If conditionals are present, let the function handle it.
        -- It will only stop the attack if the conditions are met.
        CleveRoids.DoConditionalStopAttack(msg)
    else
        -- If no conditionals, run the original command.
        CleveRoids.Hooks.STOPATTACK_SlashCmd(msg)
    end
end

-- /stopcasting hook
CleveRoids.Hooks.STOPCASTING_SlashCmd = SlashCmdList.STOPCASTING
SlashCmdList.STOPCASTING = function(msg)
    if CleveRoids.stopMacroFlag then return end
    msg = msg or ""
    if string.find(msg, "%[") then
        -- If conditionals are present, let the function handle it.
        -- It will only stop the cast if the conditions are met.
        CleveRoids.DoConditionalStopCasting(msg)
    else
        -- If no conditionals, run the original command.
        CleveRoids.Hooks.STOPCASTING_SlashCmd()
    end
end

-- /unqueue hook
CleveRoids.Hooks.UNQUEUE_SlashCmd = SlashCmdList.UNQUEUE
SlashCmdList.UNQUEUE = function(msg)
    if CleveRoids.stopMacroFlag then return end
    msg = msg or ""
    if string.find(msg, "%[") then
        -- If conditionals are present, let the function handle it.
        CleveRoids.DoConditionalStopCasting(msg)
    else
        -- If no conditionals, run the original command.
        CleveRoids.Hooks.UNQUEUE_SlashCmd()
    end
end

-- /cast hook
CleveRoids.Hooks.CAST_SlashCmd = SlashCmdList.CAST
SlashCmdList.CAST = function(msg)
    if CleveRoids.stopMacroFlag or CleveRoids.skipMacroFlag then return end
    if msg and string.find(msg, "[%[%?!~{]") then
        CleveRoids.DoCast(msg)
    else
        -- Use lastComboPoints which is updated on every OnUpdate tick
        -- This is critical for instant-cast finishers where GetComboPoints() returns 0 immediately
        local currentCP = CleveRoids.lastComboPoints or 0

        -- Also try GetComboPoints as a fallback
        if currentCP == 0 and GetComboPoints then
            currentCP = GetComboPoints()
        end

        if currentCP > 0 then
            if CleveRoids.debug then
                DEFAULT_CHAT_FRAME:AddMessage(
                    string.format("|cffaaff00[/cast Hook]|r Using %d CP for %s",
                        currentCP, msg)
                )
            end

            -- Pre-inject combo duration into pfUI for instant-cast combo finishers
            -- Get the spell data to find the proper spell name (handles case-insensitive input)
            local spellData = CleveRoids.GetSpell and CleveRoids.GetSpell(msg)
            local spellName = spellData and spellData.name or msg

            -- If GetSpell didn't find it, capitalize first letter as fallback
            if not spellData and spellName then
                spellName = string.upper(string.sub(spellName, 1, 1)) .. string.sub(spellName, 2)
            end

            if CleveRoids.debug then
                DEFAULT_CHAT_FRAME:AddMessage(
                    string.format("|cffcccccc[/cast Debug]|r input='%s', spellName='%s', GetSpell=%s, IsComboScalingSpell=%s",
                        msg, spellName or "nil", tostring(spellData ~= nil), tostring(CleveRoids.IsComboScalingSpell ~= nil))
                )
            end

            if CleveRoids.IsComboScalingSpell and CleveRoids.IsComboScalingSpell(spellName) then
                if CleveRoids.debug then
                    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[/cast Debug]|r IS combo scaling spell")
                end
                local duration = CleveRoids.CalculateComboScaledDuration and
                                 CleveRoids.CalculateComboScaledDuration(spellName, currentCP)
                if CleveRoids.debug then
                    DEFAULT_CHAT_FRAME:AddMessage(
                        string.format("|cffcccccc[/cast Debug]|r duration=%s, pfUI=%s, pfUI.api=%s, pfUI.api.libdebuff=%s, debuffs=%s",
                            tostring(duration), tostring(pfUI ~= nil),
                            tostring(pfUI and pfUI.api ~= nil),
                            tostring(pfUI and pfUI.api and pfUI.api.libdebuff ~= nil),
                            tostring(pfUI and pfUI.api and pfUI.api.libdebuff and pfUI.api.libdebuff.debuffs ~= nil))
                    )
                end
                if duration and CleveRoids.ComboPointTracking then
                    -- Remove rank from spell name for pfUI compatibility
                    local baseName = CleveRoids.StripRank(spellName)
                    -- Populate name-based tracking BEFORE the spell is cast
                    -- This allows pfUI's AddEffect hook to find it
                    CleveRoids.ComboPointTracking[baseName] = {
                        combo_points = currentCP,
                        duration = duration,
                        cast_time = GetTime(),
                        target = UnitName("target") or "Unknown",
                        confirmed = true
                    }
                    if CleveRoids.debug then
                        DEFAULT_CHAT_FRAME:AddMessage(
                            string.format("|cffff00ff[/cast Pre-Tracking]|r Set tracking['%s'] = %ds (%d CP)",
                                baseName, duration, currentCP)
                        )
                    end
                end
            elseif CleveRoids.debug and currentCP > 0 then
                DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[/cast Debug]|r NOT a combo scaling spell")
            end
        end
        CleveRoids.Hooks.CAST_SlashCmd(msg)
    end
end

CleveRoids.Hooks.TARGET_SlashCmd = SlashCmdList.TARGET
CleveRoids.TARGET_SlashCmd = function(msg)
    tmsg = CleveRoids.Trim(msg)

    if tmsg ~= "" and not string.find(tmsg, "%[") and not string.find(tmsg, "@") then
        CleveRoids.Hooks.TARGET_SlashCmd(tmsg)
        return
    end

    if CleveRoids.DoTarget(tmsg) then
        if UnitExists("target") then
            return
        end
    end
    CleveRoids.Hooks.TARGET_SlashCmd(msg)
end
SlashCmdList.TARGET = CleveRoids.TARGET_SlashCmd


SLASH_CASTSEQUENCE1 = "/castsequence"
SlashCmdList.CASTSEQUENCE = function(msg)
    msg = CleveRoids.Trim(msg)
    local sequence = CleveRoids.GetSequence(msg)
    if not sequence then return end
    -- if not sequence.active then return end

    CleveRoids.DoCastSequence(sequence)
end


--[[
SLASH_RUNMACRO1 = "/runmacro"
SlashCmdList.RUNMACRO = function(msg)
    return CleveRoids.ExecuteMacroByName(CleveRoids.Trim(msg))
end
]]

SLASH_RUNMACRO1 = "/runmacro" --新增条件支持 by 武藤纯子酱 2025.11.26
function SlashCmdList.RUNMACRO(msg)
    if not msg then return end
    return CleveRoids.SafeRunMacro("macro", msg)
end

-- Global RunMacro wrapper for user convenience (delegates to namespaced internal function)
-- This pattern ensures internal logic uses CleveRoids.ExecuteMacroByName and won't break
-- if another addon overwrites the global RunMacro
-- NOTE: When SuperMacro is also loaded, Compatibility/SuperMacro.lua redirects this to
-- SuperMacro_RunMacro so macros go through RunLine (where CRM commands are intercepted)
function RunMacro(name)
    return CleveRoids.ExecuteMacroByName(name)
end

SLASH_RETARGET1 = "/retarget" --新增条件支持 by 武藤纯子酱 2025.11.26
SlashCmdList.RETARGET = function(msg)
    CleveRoids.DoRetarget(msg)
end

SLASH_STOPMACRO1 = "/stopmacro"
SlashCmdList.STOPMACRO = function(msg)
    CleveRoids.DoStopMacro(msg)
end

SLASH_SKIPMACRO1 = "/skipmacro"
SlashCmdList.SKIPMACRO = function(msg)
    CleveRoids.DoSkipMacro(msg)
end

-- Enable "first action only" mode - stop evaluation after first successful /cast or /use
-- Example:
--   /firstaction
--   /cast [myrawpower:>48] Shred
--   /cast [myrawpower:>40] Claw
-- Result: Only Shred casts if energy >= 48, Claw won't be queued
SLASH_FIRSTACTION1 = "/firstaction"
SlashCmdList.FIRSTACTION = function(msg)
    CleveRoids.DoFirstAction(msg)
end

-- Re-enable multi-queue behavior after /firstaction
-- Use this to restore normal evaluation where multiple casts can queue
-- Example:
--   /firstaction
--   /cast [myrawpower:>48] Shred      -- Priority section
--   /cast [myrawpower:>40] Claw
--   /nofirstaction
--   /cast Tiger's Fury                -- Can queue alongside above
SLASH_NOFIRSTACTION1 = "/nofirstaction"
SlashCmdList.NOFIRSTACTION = function(msg)
    CleveRoids.DoNoFirstAction(msg)
end

-- QuickHeal with conditionals support (requires QuickHeal addon)
-- Usage: /quickheal [conditionals] [target] [type]
-- Examples:
--   /quickheal                     -- Smart heal (auto-select target)
--   /quickheal target              -- Heal current target
--   /quickheal [combat] party      -- Heal party member if in combat
--   /quickheal [mypower:>50] mt    -- Heal tank if mana > 50%
--   /quickheal [threat:<80] hot    -- Apply HoT if threat is low
SLASH_QUICKHEAL1 = "/quickheal"
SLASH_QUICKHEAL2 = "/qh"
SlashCmdList.QUICKHEAL = function(msg)
    CleveRoids.DoQuickHeal(msg)
end

--- Execute QuickHeal with optional conditionals
--- @param msg string The command arguments (conditionals + QuickHeal params)
function CleveRoids.DoQuickHeal(msg)
    -- Check if QuickHeal addon is loaded
    if type(QuickHeal) ~= "function" then
        if not CleveRoids._quickHealErrorShown then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[SuperCleveRoidMacros]|r The /quickheal command requires the QuickHeal addon.", 1, 0.5, 0.5)
            CleveRoids._quickHealErrorShown = true
        end
        return
    end

    msg = CleveRoids.Trim(msg or "")

    -- Check if there are conditionals
    if string.find(msg, "^%[") then
        -- Parse the conditionals and remaining args
        local actions = CleveRoids.ParseMsg(msg)

        if not actions or table.getn(actions) == 0 then
            -- No valid actions parsed, just run QuickHeal
            QuickHeal()
            return
        end

        -- Find the first action whose conditionals pass
        for i = 1, table.getn(actions) do
            local action = actions[i]
            if CleveRoids.TestAction(action) then
                -- Conditionals passed - extract the target/type from action args
                local healTarget = nil
                local healType = nil

                if action.args then
                    -- Parse args - could be "target", "party", "mt", "hot", etc.
                    local args = CleveRoids.Trim(action.args)
                    if args ~= "" then
                        -- Check if it's a target or type keyword
                        local lowerArgs = string.lower(args)
                        if lowerArgs == "hot" or lowerArgs == "heal" or lowerArgs == "hs" or lowerArgs == "chainheal" then
                            healType = args
                        else
                            -- Assume it's a target specifier
                            healTarget = args
                        end
                    end
                end

                -- Execute QuickHeal with parsed parameters
                QuickHeal(healTarget, nil, nil, nil)
                return
            end
        end
        -- No conditions matched - don't heal
        return
    else
        -- No conditionals, pass through to QuickHeal directly
        -- Parse basic args: target and/or type
        local args = msg
        if args == "" then
            QuickHeal()
        else
            -- QuickHeal accepts: Target, SpellID, extParam, forceMaxHPS
            -- Common targets: player, target, targettarget, party, mt, nonmt, subgroup
            -- Common types: heal, hot, hs (paladin), chainheal (shaman)
            QuickHeal(args)
        end
    end
end

--新增 by 武藤纯子酱 2025.11.26
SLASH_PETSTAY1 = "/petstay"
SlashCmdList.PETSTAY = function(msg) CleveRoids.DoPetAction(PetWait, msg); end

SLASH_CASTRANDOM1 = "/castrandom"
function SlashCmdList.CASTRANDOM(msg)
    if not msg then return end
    
    local action = function(args)
        if not args or args == "" then return end
        
        local tbl = strsplit(args, ",")
        local spell = tbl[math.random(1,getn(tbl))]
        while strsub(spell,1,1) == " " do
            spell = strsub(spell,2)
        end
        while strsub(spell,strlen(spell)) == " " do
            spell = strsub(spell, 1, (strlen(spell)-1))
        end
        CastSpellByName(spell)
    end
    
    if string.find(msg, "%[") then
        CleveRoids.DoConditionalCastRandom(action,msg)
    else
        action(msg)
    end
end

SLASH_UNSHIFT2 = "/cancelform"

SLASH_SWITCH1 = "/switch"
SlashCmdList.SWITCH = CleveRoids.DoSwitch

SLASH_EQUIPSLOT1 = "/equipslot"
SlashCmdList.EQUIPSLOT = CleveRoids.DoEquipSlot

SLASH_ASSIST1 = "/assist"
SlashCmdList.ASSIST = CleveRoids.DoAssist
 
SLASH_TARGETENEMY1 = "/targetenemy"
SlashCmdList.TARGETENEMY = CleveRoids.DoTargetEnemy
 
SLASH_TARGETENEMYPLAYER1 = "/targetenemyplayer"
SlashCmdList.TARGETENEMYPLAYER = CleveRoids.DoTargetEnemyPlayer
 
SLASH_TARGETFRIEND1 = "/targetfriend"
SlashCmdList.TARGETFRIEND = CleveRoids.DoTargetFriend
 
SLASH_TARGETFRIENDPLAYER1 = "/targetfriendplayer"
SlashCmdList.TARGETFRIENDPLAYER = CleveRoids.DoTargetFriendPlayer
 
SLASH_TARGETLASTENEMY1 = "/targetlastenemy"
SlashCmdList.TARGETLASTENEMY = CleveRoids.DoTargetLastEnemy
 
SLASH_TARGETLASTFRIEND1 = "/targetlastfriend"
SlashCmdList.TARGETLASTFRIEND = CleveRoids.DoTargetLastFriend
 
SLASH_TARGETLASTTARGET1 = "/targetlasttarget"
SLASH_TARGETLASTTARGET2 = "/lasttarget"
SlashCmdList.TARGETLASTTARGET = CleveRoids.DoTargetLastTarget
 
SLASH_TARGETPARTY1 = "/targetparty"
SlashCmdList.TARGETPARTY = CleveRoids.DoTargetParty
 
SLASH_TARGETRAID1 = "/targetraid"
SlashCmdList.TARGETRAID = CleveRoids.DoTargetRaid

SLASH_TARGETEXACT1 = "/targetexact"
SlashCmdList.TARGETEXACT = CleveRoids.DoTargetExact

SLASH_PETAUTOCASTOFF1 = "/petautocastoff"
SlashCmdList.PETAUTOCASTOFF = CleveRoids.DoPetAutoCastOff
 
SLASH_PETAUTOCASTON1 = "/petautocaston"
SlashCmdList.PETAUTOCASTON = CleveRoids.DoPetAutoCastOn
 
SLASH_PETAUTOCASTTOGGLE1 = "/petautocasttoggle"
SlashCmdList.PETAUTOCASTTOGGLE = CleveRoids.DoPetAutoCastToggle

SLASH_MOUNT1 = "/mount"
SlashCmdList.MOUNT = CleveRoids.DoMount
 
SLASH_DISMOUNT1 = "/dismount"
SlashCmdList.DISMOUNT = CleveRoids.DoDismount

SLASH_CHANGEACTIONBAR1 = "/changeactionbar"
SlashCmdList.CHANGEACTIONBAR = CleveRoids.DoChangeActionBar

SLASH_SWAPACTIONBAR1 = "/swapactionbar"
SlashCmdList.SWAPACTIONBAR = CleveRoids.DoSwapActionBar

SLASH_USERNADOM1 = "/userandom"
function SlashCmdList.USERNADOM(msg)
    if not msg then return end
    
    local action = function(args)
        if not args or args == "" then return end
        
        local items = strsplit(args, ",")
        local item = items[math.random(1,getn(items))]
        while strsub(item,1,1) == " " do
            item = strsub(item,2)
        end
        while strsub(item,strlen(item)) == " " do
            item = strsub(item, 1, (strlen(item)-1))
        end
        CleveRoids.DoUse(item)
    end
    
    if string.find(msg, "%[") then
        CleveRoids.DoWithConditionals(msg, nil, CleveRoids.FixEmptyTarget, false, action)
    else
        action(msg)
    end
end

SLASH_FEED1 = "/feed"
SlashCmdList.FEED = function(msg)
    CleveRoids.DoFeed(msg)
end

SLASH_RUNSUPERMACRO1 = "/runsupermacro"
function SlashCmdList.RUNSUPERMACRO(msg)
    if not msg or not RunSuperMacro then return false end
    return CleveRoids.SafeRunMacro("supermacro", msg)
end

SLASH_RH1 = "/rh"
function SlashCmdList.RH(msg)
    if not msg then return end
    
    -- 解析模式：mw|a|ms
    local action = function(args)
        if not args or args == "" then return end
        
        -- 提取模式字符（mw/a/ms）和实际参数
        local mode, actualArgs
        if string.sub(args, 1, 2) == "mw" then
            mode = "mw"
            actualArgs = string.sub(args, 3)
        elseif string.sub(args, 1, 1) == "a" then
            mode = "a"
            actualArgs = string.sub(args, 2)
        elseif string.sub(args, 1, 2) == "ms" then
            mode = "ms"
            actualArgs = string.sub(args, 3)
        else
            -- 默认模式为 mw（向后兼容）
            mode = "mw"
            actualArgs = args
        end
        
        -- 去除参数开头的空格
        actualArgs = CleveRoids.Trim(actualArgs)
        
        -- 根据模式调用相应的函数
        if mode == "mw" and type(Heart_HealMostWounded) == "function" then
            Heart_HealMostWounded(actualArgs)
        elseif mode == "a" and type(Heart_ActionHeal) == "function" then
            Heart_ActionHeal(actualArgs)
        elseif mode == "ms" and type(Heart_HealMostWoundedMS) == "function" then
            Heart_HealMostWoundedMS(actualArgs)
		else
			return
        end
    end
    
    if string.find(msg, "%[") then
        -- 支持条件判断
        CleveRoids.DoWithConditionals(msg, nil, CleveRoids.FixEmptyTarget, false, action)
    else
        action(msg)
    end
end

SLASH_SETTAG1 = "/settag"
function SlashCmdList.SETTAG(msg)
	CleveRoids.SetTags = true
	
	local tag = CleveRoids.Trim(string.gsub(msg, "%[.-%]", ""))

	if not tag or tag == "" then return end
	
	CleveRoids.Tags[tag] = false
	CleveRoids.TagUnits[tag] = {}
	
    local action = function(args)
		if not args then return end
		CleveRoids.Tags[args] = true
		CleveRoids.SetTags = false
    end
	
	local removetag = function()
		CleveRoids.SetTags = false
	end

    if string.find(msg, "%[") then		
        -- 支持条件判断
        CleveRoids.DoWithConditionals(msg, removetag, CleveRoids.FixEmptyTarget, false, action)
    else		
        action(tag)
		CleveRoids.SetTags = false
    end
end

--以上为新增 by 武藤纯子酱 2025.11.26
