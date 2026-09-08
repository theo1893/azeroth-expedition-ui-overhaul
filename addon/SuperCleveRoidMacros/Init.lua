local _G = _G or getfenv(0)
local CleveRoids = _G.CleveRoids or {}
_G.CleveRoids = CleveRoids

-- Global flag for other addons to detect SRCM regardless of folder name
-- (pfUI macrotweak checks IsAddOnLoaded("SuperCleveRoidMacros") which fails
-- if the folder was renamed, e.g. "SuperCleveRoidMacros-main" from GitHub)
_G.SRCM_LOADED = true

CleveRoids.ready = false

CleveRoids.Hooks             = CleveRoids.Hooks      or {}
CleveRoids.Hooks.GameTooltip = {}

CleveRoids.Extensions          = CleveRoids.Extensions or {}
CleveRoids.actionEventHandlers = {}
CleveRoids.mouseOverResolvers  = {}

CleveRoids.mouseoverUnit = CleveRoids.mouseoverUnit or nil
CleveRoids.mouseOverUnit = nil

-- Environment flags
CleveRoids.hasSuperwow = SetAutoloot and true or false
CleveRoids.hasTurtle   = (type(_G.TURTLE_WOW_VERSION) ~= "nil")
CleveRoids.hasReliquary = (RQ_GetVersion ~= nil)
CleveRoids.supported   = CleveRoids.hasTurtle

CleveRoids.ParsedMsg = {}
CleveRoids.Items     = {}
CleveRoids.Spells    = {}
CleveRoids.PetSpells = {}
CleveRoids.Talents   = {}
CleveRoids.Cooldowns = {}
CleveRoids.Macros    = {}
CleveRoids.Actions   = {}
CleveRoids.Sequences = {}

CleveRoids.lastUpdate = 0
CleveRoids.lastGetItem = nil
CleveRoids.currentSequence = nil

CleveRoids.bookTypes = {BOOKTYPE_SPELL, BOOKTYPE_PET}
CleveRoids.unknownTexture = "Interface\\Icons\\INV_Misc_QuestionMark"

CleveRoids.spell_tracking = {}

-- GUID-based cast tracking (populated by pfUI 7.6 or standalone SPELL_START events)
-- Format: [casterGuid] = {spellID, spellName, icon, startTime, duration, endTime}
CleveRoids.castTracking = {}

-- pfUI 7.6+ with Nampower 2.31.0+ detected (GUID-based cast tracking available)
CleveRoids.hasPfUI76 = false

-- Combo point tracking (initialized early for /cast hook)
CleveRoids.lastComboPoints = 0
CleveRoids.lastComboPointsTime = 0

-- Resist tracking state
-- Structure: { resistType = "full"|"partial", targetGUID = guid }
CleveRoids.resistState = nil

-- KEY_DOWN/KEY_UP state table (populated when Nampower v2.41+ hasKeyEvents)
CleveRoids._keyState = {}

-- Holds information about the currently cast spell
CleveRoids.CurrentSpell = {
    -- "channeled" or "cast"
    type = "",
    -- the name of the spell
    spellName = "",
    -- is the Attack ability enabled
    autoAttack = false,
    -- is the Auto Shot ability enabled
    autoShot = false,
    -- is the Shoot ability (wands) enabled
    wand = false,
}

-- Enhanced casting state tracking
CleveRoids.UpdateCastingState = function()
    if not GetCurrentCastingInfo then return false end

    local castId, visId, autoId, casting, channeling, onswing, autoattack = GetCurrentCastingInfo()

    -- Update CurrentSpell based on actual cast state
    -- NOTE: Channel state is EXCLUSIVELY managed by SPELLCAST_CHANNEL_START/STOP events
    -- This function NEVER touches channel state, only regular casts
    if casting == 1 then
        CleveRoids.CurrentSpell.type = "cast"
        CleveRoids.CurrentSpell.castingSpellId = castId
    elseif CleveRoids.CurrentSpell.type == "cast" then
        -- Only clear if we were in a regular cast (not channel)
        CleveRoids.CurrentSpell.type = ""
        CleveRoids.CurrentSpell.castingSpellId = nil
    end
    -- DO NOT touch channel state here - events handle it

    -- Always update metadata from GetCurrentCastingInfo (onswing/autoattack only here)
    CleveRoids.CurrentSpell.autoAttack = (autoattack == 1)
    CleveRoids.CurrentSpell.onSwingPending = (onswing == 1)
    CleveRoids.CurrentSpell.visualSpellId = visId
    CleveRoids.CurrentSpell.autoRepeatSpellId = autoId
	
    -- Enhanced timing data from GetCastInfo (Nampower 2.18+)
    if GetCastInfo then
        local ok, info = pcall(GetCastInfo)
        if ok and info then
            CleveRoids.CurrentSpell.castRemainingMs = info.castRemainingMs
            CleveRoids.CurrentSpell.castEndTime = info.castEndS
            CleveRoids.CurrentSpell.gcdRemainingMs = info.gcdRemainingMs
            CleveRoids.CurrentSpell.gcdEndTime = info.gcdEndS
        else
            CleveRoids.CurrentSpell.castRemainingMs = nil
            CleveRoids.CurrentSpell.castEndTime = nil
            CleveRoids.CurrentSpell.gcdRemainingMs = nil
            CleveRoids.CurrentSpell.gcdEndTime = nil
        end
    end

    return true
end

CleveRoids.dynamicCmds = {
    ["/cast"]         = true,
    ["/castpet"]      = true,
    ["/castsequence"] = true,
    ["/use"]          = true,
    ["/equip"]        = true,
    ["/equipmh"]      = true,
    ["/equipoh"]      = true,
    ["/equip11"]      = true,
    ["/equip12"]      = true,
    ["/equip13"]      = true,
    ["/equip14"]      = true,
    ["/applymain"]    = true,
    ["/applyoff"]     = true,
}

-- Equipment swap queue system
CleveRoids.equipmentQueue = {}
CleveRoids.equipmentQueueLen = 0  -- PERFORMANCE: Track length to avoid table.getn() every frame
CleveRoids.lastEquipTime = {}
CleveRoids.lastGlobalEquipTime = 0
CleveRoids.EQUIP_COOLDOWN = 1.5  -- Per-slot cooldown
CleveRoids.EQUIP_GLOBAL_COOLDOWN = 0.5  -- Global cooldown

-- PERFORMANCE: Table pool for queue entries to reduce garbage collection
CleveRoids.queueEntryPool = {}

-- PERFORMANCE: Static buffer for proc removal to avoid per-frame allocation
CleveRoids._procRemovalBuffer = {}

-- PERFORMANCE: Static buffer for action grouping to avoid per-call allocation
CleveRoids._actionsToSlotsBuffer = {}
CleveRoids._slotsBuffer = {}
CleveRoids._actionsListBuffer = {}

-- PERFORMANCE: Static buffer for arg backup in SendEventForAction
CleveRoids._originalArgsBuffer = {}

-- KEYED DEBUG: Only prints when the message for a given key changes from last print.
-- Usage: CleveRoids.DebugChanged("immunity_moonfire", formatted_msg)
-- Prevents spam when the same state is reported repeatedly (e.g., per-frame or per-eval).
CleveRoids._lastDebugState = {}
function CleveRoids.DebugChanged(key, msg)
  if not CleveRoids.debug then return end
  if CleveRoids._lastDebugState[key] == msg then return end
  CleveRoids._lastDebugState[key] = msg
  DEFAULT_CHAT_FRAME:AddMessage(msg)
end

-- Spell queue state (Nampower)
CleveRoids.queuedSpell = nil
CleveRoids.lastCastSpell = nil

-- Macro execution control
CleveRoids.stopMacroFlag = false
CleveRoids.skipMacroFlag = false -- 新增 初始化 by 武藤纯子酱 2026.1.16
CleveRoids.stopOnCastFlag = false -- 新增 初始化 by 武藤纯子酱 2026.1.16

-- PERFORMANCE: Event-driven cached state (updated on events, not polled)
CleveRoids._cachedPlayerInCombat = nil   -- Updated on PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED

CleveRoids.ignoreKeywords = {
    action        = true,
    ignoretooltip = true,
    cancelaura    = true,
    noSpam        = true,  -- ! prefix flag: prevent toggle-off at execution time
    _operators    = true,  -- Metadata for AND/OR operator tracking
    _groups       = true,  -- Grouped conditional values for AND/OR evaluation
    multiscan     = true,  -- Processed before Keywords loop (target resolution)
    mouseuse      = true,  -- Post-cast modifier: auto-click AOE targeting circle at cursor
    stopattack    = true,  -- Post-cast modifier: stop autoattack after cast (CheapShot pattern)
}

-- TODO: Localize?
CleveRoids.countedItemTypes = {
    ["Consumable"]  = true,
    ["Reagent"]     = true,
    ["Projectile"]  = true,
    ["Trade Goods"] = true,
}


-- TODO: Localize?
CleveRoids.actionSlots    = {}
CleveRoids.reactiveSlots  = {}
CleveRoids.reactiveSpells = {
    [CleveRoids.Localized.Spells["Revenge"]]         = true, -- 新增多语言支持 by 武藤纯子酱 2026.2.2
    [CleveRoids.Localized.Spells["Overpower"]]       = true, -- 新增多语言支持 by 武藤纯子酱 2026.2.2
    [CleveRoids.Localized.Spells["Riposte"]]         = true, -- 新增多语言支持 by 武藤纯子酱 2026.2.2
    [CleveRoids.Localized.Spells["Surprise Attack"]] = true, -- 新增多语言支持 by 武藤纯子酱 2026.2.2
    [CleveRoids.Localized.Spells["Lacerate"]]        = true, -- 新增多语言支持 by 武藤纯子酱 2026.2.2
    [CleveRoids.Localized.Spells["Baited Shot"]]     = true, -- 新增多语言支持 by 武藤纯子酱 2026.2.2
    [CleveRoids.Localized.Spells["Counterattack"]]   = true, -- 新增多语言支持 by 武藤纯子酱 2026.2.2
    [CleveRoids.Localized.Spells["Arcane Surge"]]    = true, -- 新增多语言支持 by 武藤纯子酱 2026.2.2
    [CleveRoids.Localized.Spells["Aquatic Form"]]    = true, -- 新增多语言支持 by 武藤纯子酱 2026.2.2
}

CleveRoids.spamConditions = {
    [CleveRoids.Localized.Attack]   = "checkchanneled",
    [CleveRoids.Localized.AutoShot] = "checkchanneled",
    [CleveRoids.Localized.Shoot]    = "checkchanneled",
}

-- PERFORMANCE: Static lookup for toggled buff abilities (built once, used per-frame)
CleveRoids._toggledBuffAbilities = {
    [CleveRoids.Localized.Spells["Prowl"]] = true,
    [CleveRoids.Localized.Spells["Shadowmeld"]] = true,
}

function CleveRoids.IsToggledBuffAbility(spellName)
    return CleveRoids._toggledBuffAbilities[spellName]
end

CleveRoids.auraTextures = {
    [CleveRoids.Localized.Spells["Stealth"]]    = "Interface\\Icons\\Ability_Stealth",
    [CleveRoids.Localized.Spells["Prowl"]]      = "Interface\\Icons\\Spell_Nature_Invisibilty",
    [CleveRoids.Localized.Spells["Shadowform"]] = "Interface\\Icons\\Spell_Shadow_Shadowform",
	[CleveRoids.Localized.Spells["Shadowmeld"]] = "Interface\\Icons\\Spell_Nature_WispSplode",
    ["Seal of Wisdom"] = "Interface\\Icons\\Spell_Holy_RighteousnessAura",
    ["Seal of the Crusader"] = "Interface\\Icons\\Spell_Holy_HolySmite",
    ["Seal of Light"] = "Interface\\Icons\\Spell_Holy_HealingAura",
    ["Seal of the Justice"] = "Interface\\Icons\\Spell_Holy_SealOfWrath",
    ["Seal of Righteousness"] = "Interface\\Icons\\Ability_ThunderBolt",
    ["Seal of Command"] = "Interface\\Icons\\Ability_Warrior_InnerRage",
}


-- I need to make a 2h modifier
-- Maps easy to use weapon type names (e.g. Axes, Shields) to their inventory slot name and their localized tooltip name
CleveRoids.WeaponTypeNames = {
    Daggers   = { slot = "MainHandSlot", name = CleveRoids.Localized.Dagger },
    Fists     = { slot = "MainHandSlot", name = CleveRoids.Localized.FistWeapon },
    Axes      = { slot = "MainHandSlot", name = CleveRoids.Localized.Axe },
    Swords    = { slot = "MainHandSlot", name = CleveRoids.Localized.Sword },
    Staves    = { slot = "MainHandSlot", name = CleveRoids.Localized.Staff },
    Maces     = { slot = "MainHandSlot", name = CleveRoids.Localized.Mace },
    Polearms  = { slot = "MainHandSlot", name = CleveRoids.Localized.Polearm },
    -- OH
    Daggers2  = { slot = "SecondaryHandSlot", name = CleveRoids.Localized.Dagger },
    Fists2    = { slot = "SecondaryHandSlot", name = CleveRoids.Localized.FistWeapon },
    Axes2     = { slot = "SecondaryHandSlot", name = CleveRoids.Localized.Axe },
    Swords2   = { slot = "SecondaryHandSlot", name = CleveRoids.Localized.Sword },
    Maces2    = { slot = "SecondaryHandSlot", name = CleveRoids.Localized.Mace },
    Shields   = { slot = "SecondaryHandSlot", name = CleveRoids.Localized.Shield },
    -- ranged
    Guns      = { slot = "RangedSlot", name = CleveRoids.Localized.Gun },
    Crossbows = { slot = "RangedSlot", name = CleveRoids.Localized.Crossbow },
    Bows      = { slot = "RangedSlot", name = CleveRoids.Localized.Bow },
    Thrown    = { slot = "RangedSlot", name = CleveRoids.Localized.Thrown },
    Wands     = { slot = "RangedSlot", name = CleveRoids.Localized.Wand },
}

-- Detect available features
CleveRoids.hasNampower = (QueueSpellByName ~= nil)
CleveRoids.hasUnitXP = pcall(UnitXP, "nop", "nop")

-- Extended Nampower feature flags (populated by NampowerAPI.lua)
CleveRoids.nampowerVersion = { major = 0, minor = 0, patch = 0 }
CleveRoids.hasExtendedNampower = false  -- True if v2.12+ with new API functions

-- Feature detection messages
local function PrintFeatures()
    local features = {}
    if CleveRoids.hasSuperwow then table.insert(features, "SuperWoW") end
    if CleveRoids.hasNampower then
        local ver = CleveRoids.nampowerVersion
        if ver.major > 0 then
            table.insert(features, string.format("Nampower v%d.%d.%d", ver.major, ver.minor, ver.patch))
        else
            table.insert(features, "Nampower")
        end
    end
    if CleveRoids.hasUnitXP then table.insert(features, "UnitXP") end
    if CleveRoids.hasReliquary then
        local ok, major, minor, patch = pcall(RQ_GetVersion)
        if ok and major then
            table.insert(features, string.format("Reliquary v%d.%d.%d", major, minor, patch))
        else
            table.insert(features, "Reliquary")
        end
    end
    if CleveRoids.hasTurtle then table.insert(features, "Turtle") end

    if table.getn(features) > 0 then
        CleveRoids.Print("Enhanced features: " .. table.concat(features, ", "))
    end
end

-- Immunity data version - increment this when changing immunity data format
-- This will cause all immunity data to be reset on addon update
-- v3: Fixed Master Strike false physical immunity recording (split CC spell handling)
-- v4: Fixed false immunity recording when target dies with spells in-flight (dead = IMMUNE)
-- v5: Fixed false physical immunity from unknown spell schools (now uses DBC lookup; unknown defaults to nil not "physical")
-- v6: Reset stale immunity data that may contain false positives
CleveRoids.IMMUNITY_DATA_VERSION = 6

-- Call on next frame to ensure everything is loaded
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function()
    this:UnregisterAllEvents()

    -- Check immunity data version and reset if outdated
    CleveRoidMacros = CleveRoidMacros or {}
    CleveRoids_ImmunityData = CleveRoids_ImmunityData or {}
    local savedVersion = CleveRoidMacros.immunityDataVersion or 0

    if savedVersion < CleveRoids.IMMUNITY_DATA_VERSION then
        -- Check if there was existing data to clear
        local hadData = next(CleveRoids_ImmunityData) ~= nil

        -- Version changed - reset all immunity data
        CleveRoids_ImmunityData = {}
        CleveRoidMacros.immunityDataVersion = CleveRoids.IMMUNITY_DATA_VERSION

        if hadData then
            -- Show message if we actually cleared existing data
            CleveRoids.Print("|cffff9900Immunity data reset|r - addon updated to data version " .. CleveRoids.IMMUNITY_DATA_VERSION)
        end
    end

    -- Detect pfUI macrotweak conflict (folder name mismatch)
    -- pfUI macrotweak disables itself via IsAddOnLoaded("SuperCleveRoidMacros"),
    -- but this fails when the addon folder is renamed (e.g. GitHub download adds "-main").
    -- When both are active: conflicting SendChatMessage hooks, duplicate /use and /equip
    -- handlers, and #showtooltip can leak into chat (pfUI only filters "#showtooltip "
    -- with trailing space, missing bare "#showtooltip").
    if pfUI and pfUI.module and pfUI.module["macrotweak"]
       and not IsAddOnLoaded("SuperCleveRoidMacros") then
        CleveRoids.Print("|cffff0000WARNING:|r Your addon folder name is not |cff00ff00SuperCleveRoidMacros|r.")
        CleveRoids.Print("This causes a conflict with pfUI's macrotweak module.")
        CleveRoids.Print("Please rename the folder to exactly |cff00ff00SuperCleveRoidMacros|r and /reload.")
    end

    -- Initialize NampowerAPI if available
    if CleveRoids.NampowerAPI then
        local API = CleveRoids.NampowerAPI

        -- Get version info
        local major, minor, patch = API.GetVersion()
        CleveRoids.nampowerVersion = { major = major, minor = minor, patch = patch }

        -- Check for extended API (v2.12+)
        CleveRoids.hasExtendedNampower = API.HasMinimumVersion(2, 12, 0)

        -- Sync feature flags
        if API.features then
            CleveRoids.hasGetSpellRec = API.features.hasGetSpellRec
            CleveRoids.hasGetItemStats = API.features.hasGetItemStats
            CleveRoids.hasGetUnitData = API.features.hasGetUnitData
            CleveRoids.hasGetSpellModifiers = API.features.hasGetSpellModifiers
            CleveRoids.hasEnhancedSpellFunctions = API.features.hasEnhancedSpellFunctions
            -- v2.37+: CastSpellByName supports unit token strings as 2nd param
            CleveRoids.hasCastSpellByNameUnitToken = API.features.hasCastSpellByNameUnitToken
        end

        -- Initialize the API
        API.Initialize()
    end	

    PrintFeatures()
end)

--新增鼠标按键1-5的支持 by 武藤纯子酱 2025.11.26
CleveRoids.MouseDown = "LeftButton"
CleveRoids.MouseDownTime = GetTime() -- 新增 by 武藤纯子酱 2025.11.26
CleveRoids.Allbutton = {}

function CleveRoids.GetAllButtons()

	for i = 1, 12 do
		table.insert(CleveRoids.Allbutton, _G["ActionButton"..i])
		table.insert(CleveRoids.Allbutton, _G["MultiBarBottomLeftButton"..i])
		table.insert(CleveRoids.Allbutton, _G["MultiBarBottomRightButton"..i])
		table.insert(CleveRoids.Allbutton, _G["MultiBarRightButton"..i])
		table.insert(CleveRoids.Allbutton, _G["MultiBarLeftButton"..i])
		table.insert(CleveRoids.Allbutton, _G["BonusActionButton"..i])
	end

	if pfUI and pfUI.bars then
		for i = 1, 12 do
			table.insert(CleveRoids.Allbutton, _G["pfActionBarMainButton"..i])
			table.insert(CleveRoids.Allbutton, _G["pfActionBarPagingButton"..i])
			table.insert(CleveRoids.Allbutton, _G["pfActionBarRightButton"..i])
			table.insert(CleveRoids.Allbutton, _G["pfActionBarVerticalButton"..i])
			table.insert(CleveRoids.Allbutton, _G["pfActionBarLeftButton"..i])
			table.insert(CleveRoids.Allbutton, _G["pfActionBarTopButton"..i])
		end
	end

    if ZBAR_VERSION then
        for barIndex = 1, 4 do
            for buttonIndex = 1, 12 do
				table.insert(CleveRoids.Allbutton, _G["zBar"..barIndex.."Button"..buttonIndex])
            end
        end
    end

	for _, v in ipairs(CleveRoids.Allbutton) do
		v:SetScript("OnMouseDown", function()

			if arg1 then 
				CleveRoids.MouseDown = arg1 
				CleveRoids.MouseDownTime = GetTime()
			end
		end)
	end
	
    return
end

-- 创建工具提示扫描器 by 武藤纯子酱 2025.11.26
CleveRoids.Scanner = CreateFrame("GameTooltip", "CleverDismountScanner", nil, "GameTooltipTemplate")
CleveRoids.Scanner:SetOwner(UIParent, "ANCHOR_NONE")

CleveRoids.MountPatterns = {
	-- deDE
	"^Erhöht Tempo um (.+)%%",
	-- enUS
	"^Increases speed by (.+)%%",
	-- esES
	"^Aumenta la velocidad en un (.+)%%",
	-- frFR
	"^Augmente la vitesse de (.+)%%",
	-- ruRU
	"^Скорость увеличена на (.+)%%",
	-- koKR
	"^이동 속도 (.+)%%만큼 증가",
	-- zhCN
	"^速度提高(.+)%%",

	-- turtle-wow
	"speed based on",
	"Slow and steady...",
	"Riding",
	"根据您的骑行技能提高速度。",
	"根据骑术技能提高速度。",
	"又慢又稳......",
}

CleveRoids.FlyMountPatterns = {
	-- turtle-wow flying ride
	"Increases flying speed by (.+)%% for (.+) sec.",
	"飞行速度提高(.+)%%。",
}

CleveRoids.SpellCastTimes = CleveRoids.SpellCastTimes or {} -- 添加delay延迟记录表 by 武藤纯子酱 2025.11.26
CleveRoids.AssistsUnit = CleveRoids.AssistsUnit or {} -- 添加assists延迟记录表 by 武藤纯子酱 2025.11.26
CleveRoids.SpellTarget = CleveRoids.SpellTarget or {} -- 添加delay目标延迟记录表 by 武藤纯子酱 2026.1.20
CleveRoids.Tags = CleveRoids.Tags or {} -- 添加Tags标签表 by 武藤纯子酱 2026.1.27
CleveRoids.SetTags = false -- 添加/settag标记，表示当前正在settag by 武藤纯子酱 2026.1.28
CleveRoids.TagUnits = CleveRoids.TagUnits or {} -- 添加TagUnits标签表 by 武藤纯子酱 2026.1.27

-- 创建一个事件监听器框架
local Last_Friend_Target = CreateFrame("Frame")
CleveRoids.LastFriendTarget = nil

-- 注册需要监听的事件
Last_Friend_Target:RegisterEvent("PLAYER_TARGET_CHANGED")

Last_Friend_Target:SetScript("OnEvent", function()
	if UnitExists("target") and UnitIsFriend("player", "target") then 
		CleveRoids.LastFriendTarget = CleveRoids.GetGUID("target")
	end;
end)

-- 增加宏执行栈结构 by 武藤纯子酱 2025.11.26
CleveRoids.MacroStack = {}
CleveRoids.MaxMacroDepth = 10 -- 最大递归深度


-- 安全执行宏的函数 by 武藤纯子酱 2025.11.26
function CleveRoids.SafeRunMacro(macroType, msg)
    local action = function(args)
        -- 在条件处理前检查调用栈
        local stackSize = table.getn(CleveRoids.MacroStack)
        local currentMacro = stackSize > 0 and CleveRoids.MacroStack[stackSize] or nil
        if currentMacro and currentMacro == args then
            CleveRoids.Print("警告: 宏不能直接调用自身")
            return false
        end
        
        -- 检查调用栈深度
        if stackSize >= CleveRoids.MaxMacroDepth then
            CleveRoids.Print("警告: 宏调用深度超过限制 ("..CleveRoids.MaxMacroDepth..")")
            return false
        end
        
        if macroType == "macro" then
            return CleveRoids.ExecuteMacroByName(args)
        else
            return RunSuperMacro(args)
        end
    end
    
    if string.find(msg, "%[") then
        return CleveRoids.DoWithConditionals(msg, nil, CleveRoids.FixEmptyTarget, false, action)
    else
        return action(msg)
    end
end

-- 按条件选中目标 by 武藤纯子酱 2025.11.26
function CleveRoids.DoConditionalTargeting(msg, targetFunc, isFriendly)
	local handle
	local unitID = CleveRoids.GetGUID("target")
    
	for k, v in pairs(CleveRoids.splitStringIgnoringQuotes(msg)) do
		handled = false
		if CleveRoids.DoWithConditionals(v, targetFunc, CleveRoids.FixEmptyTarget, false, 
			function(name)
				if name and name ~= "" then
					targetFunc(name)
				else
					targetFunc()
				end

				-- 验证目标类型
				if UnitExists("target") then
					if isFriendly then
						if not UnitCanAssist("player", "target") then
							if unitID then
								TargetUnit(unitID)
							else
								ClearTarget()
							end
						end
					else
						if not UnitCanAttack("player", "target") then
							if unitID then
								TargetUnit(unitID)
							else
								ClearTarget()
							end
						end
					end
				end
			end) then
            handled = true
            break
        end
	end
    -- 如果未处理（条件不满足），恢复之前的目标
    if not handled then
		if unitID then
			TargetUnit(unitID)
		else
			ClearTarget()
		end
    end
    return handled
end

-- 装备到指定装备栏 by 武藤纯子酱 2025.11.26
function CleveRoids.EquipItemToSlot(itemName, slotId)
    local item = CleveRoids.GetItem(itemName)
    if not item then return false end
    -- 检查当前槽位是否已经装备了这个物品
    local currentItemLink = GetInventoryItemLink("player", slotId)
    if currentItemLink then
		local _,_,itemId = string.find(currentItemLink,"item:(%d+)")		
        local currentItemName = GetItemInfo(itemId)	
        if currentItemName and currentItemName == item.name then
			return true -- 已经装备，不需要操作
        end
    end
    if item.bagID then
        CleveRoids.GetNextBagSlotForUse(item, itemName)
        PickupContainerItem(item.bagID, item.slot)
    elseif item.inventoryID then
        PickupInventoryItem(item.inventoryID)
    else
        return false
    end
    EquipCursorItem(slotId)
    ClearCursor()
    CleveRoids.lastItemIndexTime = 0
    return true
end

-- 创建主帧用于定时更新
CleveRoids.TimerFrame = CreateFrame("Frame")
local DeathTimers = {} -- 全局表存储存活目标的计时数据

-- 定义定时器参数
local interval = 0.3
local elapsedTime = 0

-- 预估单位死亡时间
function CleveRoids.CalculateTimeRemaining(unitID)
    local data = DeathTimers[unitID]
    if not data or not data.historyCount or data.historyCount < 2 then return 1000 end
    
    -- 1. 加权平均法计算剩余时间
    local totalWeight = 0
    local weightedDamage = 0
    local maxHistory = 50
    
    for i = math.max(1, data.historyCount - maxHistory + 1), data.historyCount do
        if data.history[i] then
            local weight = 1 + (i - (data.historyCount - maxHistory)) * 0.8
            weightedDamage = weightedDamage + (data.history[i].damage or 0) * weight
            totalWeight = totalWeight + weight
        end
    end
    
    local timeRemainingWeighted = data.lastTimeRemaining or 1000
    if totalWeight > 0 then
        local avgDPS = (weightedDamage / totalWeight) / interval
        if avgDPS > 0 then
            timeRemainingWeighted = math.max(0, CleveRoids.NampowerAPI.GetUnitHealth(unitID) / avgDPS)
        end
    end
    
    -- 2. 近5秒平均伤害法计算剩余时间 - 使用实际时间跨度
    local currentTime = GetTime()
    local damage5s = 0
    local earliestTime = currentTime  -- 记录最早的有效伤害时间
    
    -- 遍历历史记录，统计最近5秒内的伤害总和
    for i = data.historyCount, 1, -1 do
        local record = data.history[i]
        if not record or not record.time then break end
        
        local timeDiff = currentTime - record.time
        if timeDiff <= 5 then
            damage5s = damage5s + (record.damage or 0)
            earliestTime = record.time  -- 更新最早的时间戳
        else
            break  -- 一旦超出5秒范围就停止遍历
        end
    end
    
    local timeRemaining5s = 1000
    local timeSpan = math.max(0.1, currentTime - earliestTime) -- 实际时间跨长，最小0.1秒
    
    --至少需要3秒数据才信任近5秒统计，否则只用加权平均
    if timeSpan >= 3 then
        local dps5s = damage5s / timeSpan  -- 使用实际时间跨长计算DPS
        timeRemaining5s = math.max(0, CleveRoids.NampowerAPI.GetUnitHealth(unitID) / dps5s)
        
        -- Debug: 查看实际统计时间跨长
        -- CleveRoids.Print("Time Span: ", string.format("%.1f秒", timeSpan))
    end
    
    -- 更新最后使用的剩余时间
    data.lastTimeRemaining = timeRemainingWeighted

    -- 返回两种算法的最小值
    return (timeSpan >= 3) and math.min(timeRemainingWeighted, timeRemaining5s) or timeRemainingWeighted
end

-- 计算到血量还剩20%所需时间
function CleveRoids.GetTimeTo20PercentHealth(unit)
    if not unit then unit = "target" end
    
    -- 如果单位不存在，返回1000
    if not UnitExists(unit) then
        return 1000, false
    end
    
    -- 如果单位已死亡或灵魂状态，返回0
    if UnitIsDeadOrGhost(unit) then
        return 0, true
    end
    
    -- 获取当前血量和最大血量
    local currentHealth = CleveRoids.NampowerAPI.GetUnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    
    -- 如果最大血量为0，返回1000
    if maxHealth <= 0 or not maxHealth then
        return 1000, false
    end
    
    -- 计算当前血量百分比
    local currentPercent = (currentHealth / maxHealth) * 100
    
    -- 如果当前血量已经低于20%，直接返回true
    if currentPercent <= 20 then
        return 0, true
    end
    
    -- 计算20%血量的具体值
    local healthThreshold = maxHealth * 0.2
    
    -- 计算需要减少的血量
    local healthToLose = currentHealth - healthThreshold
    
    -- 如果不需要减少血量（理论上不会发生，但安全起见）
    if healthToLose <= 0 then
        return 0, true
    end
    
    -- 获取单位GUID用于查找历史数据
    local unitID = CleveRoids.GetGUID(unit)
    
    -- 获取该单位的伤害历史数据
    local data = DeathTimers[unitID]
    if not data or not data.historyCount or data.historyCount < 2 then
        -- 没有足够的历史数据，无法预估
        return 1000, false
    end
    
    -- 使用与死亡预估相同的算法计算当前DPS
    local currentTime = GetTime()
    
    -- 1. 加权平均法计算DPS
    local totalWeight = 0
    local weightedDamage = 0
    local maxHistory = 50
    
    for i = math.max(1, data.historyCount - maxHistory + 1), data.historyCount do
        if data.history[i] then
            local weight = 1 + (i - (data.historyCount - maxHistory)) * 0.8
            weightedDamage = weightedDamage + (data.history[i].damage or 0) * weight
            totalWeight = totalWeight + weight
        end
    end
    
    local weightedDPS = 0
    if totalWeight > 0 then
        weightedDPS = (weightedDamage / totalWeight) / interval
    end
    
    -- 2. 近5秒平均伤害法计算DPS
    local damage5s = 0
    local earliestTime = currentTime
    
    -- 遍历历史记录，统计最近5秒内的伤害总和
    for i = data.historyCount, 1, -1 do
        local record = data.history[i]
        if not record or not record.time then break end
        
        local timeDiff = currentTime - record.time
        if timeDiff <= 5 then
            damage5s = damage5s + (record.damage or 0)
            earliestTime = record.time
        else
            break
        end
    end
    
    local dps5s = 0
    local timeSpan = math.max(0.1, currentTime - earliestTime)
    
    if timeSpan >= 3 then
        dps5s = damage5s / timeSpan
    end
    
    -- 选择更保守的DPS估计（取较小值，这样预估时间会更长，更安全）
    local estimatedDPS = 0
    if weightedDPS > 0 and dps5s > 0 then
        estimatedDPS = math.min(weightedDPS, dps5s)
    elseif weightedDPS > 0 then
        estimatedDPS = weightedDPS
    elseif dps5s > 0 then
        estimatedDPS = dps5s
    else
        -- 没有有效的DPS数据
        return 1000, false
    end
    
    -- 如果DPS为0或负数，无法预估
    if estimatedDPS <= 0 then
        return 1000, false
    end
    
    -- 计算到20%血量所需时间
    local timeTo20Percent = healthToLose / estimatedDPS
    
    -- 返回预估时间（秒），以及是否已低于20%
    return math.max(0, timeTo20Percent), false
end

-- 简化调用接口：如果低于20%返回0，否则返回剩余时间
function CleveRoids.GetTargetPercent20Time(unit)
    if not unit then unit = "target" end
    
    local timeRemaining, isBelow20 = CleveRoids.GetTimeTo20PercentHealth(unit)
    
    if isBelow20 then
        return 0
    elseif timeRemaining then
        return timeRemaining
    else
        -- 无法预估的情况
        return 1000
    end
end

-- 主体函数
CleveRoids.TimerFrame:SetScript("OnUpdate", function()
    if (GetTime() - elapsedTime) < interval then
        return
    end
    elapsedTime = GetTime()
    local unitsToCheck = {}
	
	if (elapsedTime - CleveRoids.MouseDownTime) > 0.1 then  -- 新增定期清除鼠标按键记录 by 武藤纯子酱 2025.11.27
		CleveRoids.MouseDown = "LeftButton"
	end
	
	-- 遍历所有跟踪的单位
	if Cursive and Cursive.core then
		for guid, _ in pairs(Cursive.core.guids) do
			if UnitAffectingCombat(guid) then
				unitsToCheck[guid] = true
			end
		end
	else
		-- 收集有效单位GUID/原始ID
		if UnitInRaid("player") then
			for i = 1, GetNumRaidMembers() do
				local unit = "raid"..i.."target"
				if UnitExists(unit) then
					unitsToCheck[CleveRoids.GetGUID(unit)] = true
				end
			end
		elseif UnitInParty("player") then
			for i = 1, GetNumPartyMembers() do
				local unit = "party"..i.."target"
				if UnitExists(unit) then
					unitsToCheck[CleveRoids.GetGUID(unit)] = true
				end
			end
		end
		
		-- 添加玩家当前目标
		local targetGUID = CleveRoids.GetGUID("target")
		if UnitExists("target") then
			unitsToCheck[targetGUID] = true
		end
	end

    -- 清理无效单位
    for unitID in pairs(DeathTimers) do
        if not unitsToCheck[unitID] or not UnitAffectingCombat(unitID) then
            DeathTimers[unitID] = nil
        end
    end

    -- 更新有效单位数据
    for unitID in pairs(unitsToCheck) do
        if (CleveRoids.hasSuperwow or UnitExists(unitID)) and not UnitIsDeadOrGhost(unitID) then
            local currentHealth = CleveRoids.NampowerAPI.GetUnitHealth(unitID)
            local currentTime = GetTime()
            
            if not DeathTimers[unitID] then
                DeathTimers[unitID] = {
                    history = {},
                    historyCount = 0,
                    lastHealth = currentHealth,
                    lastTime = currentTime
                }
            end
            
            local data = DeathTimers[unitID]
            local damage = (data.lastHealth or 0) - currentHealth
            
            data.historyCount = (data.historyCount or 0) + 1
            data.history[data.historyCount] = { damage = damage, time = currentTime }
            
            if data.historyCount > 20 then
                for i = 1, 20 do
                    data.history[i] = data.history[i+1]
                end
                data.historyCount = 20
            end
            
            data.lastHealth = currentHealth
            data.lastTime = currentTime
        end
    end
end)

-- 接口函数
-- 示例调用方式:
-- /script print(CleveRoids.GetTargetDeathTime("target"))
function CleveRoids.GetTargetDeathTime(unit)
	if not unit then unit = "target" end

    if CleveRoids.hasSuperwow then
        local targetGUID = CleveRoids.GetGUID(unit)
        if not targetGUID or not UnitExists(unit) then return 1000 end
        if UnitIsDeadOrGhost(unit) then return 0 end
        local data = DeathTimers[targetGUID]
        if data then
            return math.floor(CleveRoids.CalculateTimeRemaining(targetGUID) + 0.5)
        end
    else
        if not UnitExists(unit) then return 1000 end
        if UnitIsDeadOrGhost(unit) then return 0 end
        for unitID in pairs(DeathTimers) do
            if UnitIsUnit(unit, unitID) then
                return math.floor(CleveRoids.CalculateTimeRemaining(unitID) + 0.5)
            end
        end
    end
    return 1000
end

-- 增强事件响应
CleveRoids.TimerFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
CleveRoids.TimerFrame:SetScript("OnEvent", function()
    elapsedTime = interval
    DeathTimers = {}
end)

-- 通过attackbar插件获取平砍/平射计时 by 武藤纯子酱 2025.11.27
function CleveRoids.GetAttackState()
    local now = GetTime()
    local mhStarted, mhRemaining, ohStarted, ohRemaining = 0, 0, 0, 0
    local isMelee = CleveRoids.CurrentSpell.autoAttack
    local isRanged = CleveRoids.CurrentSpell.autoShot or CleveRoids.CurrentSpell.wand
	
    -- 获取主手攻击信息
    if Abar_Mhr and Abar_Mhr:IsVisible() then
        mhStarted = now - Abar_Mhr.st
        mhRemaining = Abar_Mhr.et - now
    end
    
    -- 获取副手攻击信息
    if Abar_Oh and Abar_Oh:IsVisible() then
        ohStarted = now - Abar_Oh.st
        ohRemaining = Abar_Oh.et - now
    end

    -- 确保值不为负
    mhStarted = math.max(0, mhStarted)
    mhRemaining = math.max(0, mhRemaining)
    ohStarted = math.max(0, ohStarted)
    ohRemaining = math.max(0, ohRemaining)
    
    return {
        mhStarted = mhStarted,
        mhRemaining = mhRemaining,
        ohStarted = ohStarted,
        ohRemaining = ohRemaining,
        isMelee = isMelee,
        isRanged = isRanged,
    }
end

function CleveRoids.IsGuidValid(condTarget, conds)
    if not condTarget or not UnitExists(condTarget) or UnitIsDeadOrGhost(condTarget) then
        return false
    end
    local orig = conds.target
    conds.target = condTarget
    local ok = true
    for k, _ in pairs(conds) do
        if not CleveRoids.ignoreKeywords[k] then
            local fn = CleveRoids.Keywords[k]
            if not fn or not fn(conds) then ok = false; break end
        end
    end
    conds.target = orig
    return ok
end

function CleveRoids.ParseCasttimeArg(arg)
    local mode = "end"
    local spellIdentifier = nil
    local rawName = nil

    if type(arg) == "table" then
        rawName = arg.name
    elseif type(arg) == "string" then
        rawName = arg
    end

    if type(rawName) == "string" then
        local pipePos = string.find(rawName, "|", 1, true)
        if pipePos then
            local prefix = string.sub(rawName, 1, pipePos - 1)
            local suffix = string.sub(rawName, pipePos + 1)
            local lowerPrefix = string.lower(prefix)
            if lowerPrefix == "start" or lowerPrefix == "end" then
                mode = lowerPrefix
                spellIdentifier = suffix
                -- 如果后缀以 | 开头，去掉第一个（可能是重复的）
                if string.sub(spellIdentifier, 1, 1) == "|" then
                    spellIdentifier = string.sub(spellIdentifier, 2)
                end
            else
                -- 没有合法前缀，整个字符串视为技能标识符
                spellIdentifier = rawName
            end
        else
            local lowerRaw = string.lower(rawName)
            if lowerRaw == "start" or lowerRaw == "end" then
                mode = lowerRaw
            else
                spellIdentifier = rawName
            end
        end
    end
    return mode, spellIdentifier
end

CleveRoids.SpellSchoolName = {
    [0] = "physical",  -- SPELL_SCHOOL_NORMAL (Physical/Armor)
    [1] = "holy",      -- SPELL_SCHOOL_HOLY
    [2] = "fire",      -- SPELL_SCHOOL_FIRE
    [3] = "nature",    -- SPELL_SCHOOL_NATURE
    [4] = "frost",     -- SPELL_SCHOOL_FROST
    [5] = "shadow",    -- SPELL_SCHOOL_SHADOW
    [6] = "arcane"     -- SPELL_SCHOOL_ARCANE
}

CleveRoids.DebuffType = {
    [1] = "magic",
    [2] = "curse",
    [3] = "disease",
    [4] = "poison",
}

CleveRoids.MacroTarget = nil
CleveRoids.TrueTarget = nil
CleveRoids.SetScan = nil
CleveRoids._mostWoundedGroupCache = nil
_G["CleveRoids"] = CleveRoids
