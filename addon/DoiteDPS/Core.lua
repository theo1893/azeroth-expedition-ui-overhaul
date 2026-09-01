-- ============================================================================
-- DoiteDPS - Core
-- Turtle WoW / Vanilla 1.12 / Lua 5.0
-- ============================================================================

DoiteDPS = DoiteDPS or {}
local D = DoiteDPS

D.VERSION = "0.8.39"
D.UPDATE_IN_COMBAT = 0.05
D.UPDATE_OUT_OF_COMBAT = 0.15
D.GCD_MAX = 1.60
D.FORECAST_LIMIT = 3

-- 运行链：BuildState 读取客户端状态，当前 Profile 生成推荐与预测，UI 只负责
-- 展示；只有玩家主动触发的 Profile:Execute 才允许选择目标或施放技能。
local locale = (GetLocale and GetLocale()) or "enUS"
local zh = (locale == "zhCN" or locale == "zhTW")

D.Text = {
    TITLE = "DoiteDPS",
    SINGLE = zh and "单体" or "Single",
    AOE = zh and "多目标" or "AoE",
    BERSERKER_SINGLE = zh and "狂暴姿态武器战" or "Berserker Stance Arms Warrior",
    BATTLE_SINGLE = zh and "战斗姿态武器战" or "Battle Stance Arms Warrior",
    BATTLE_AOE = zh and "战斗姿态武器战" or "Battle Stance Arms Warrior",
    BERSERKER_AOE = zh and "狂暴姿态武器战" or "Berserker Stance Arms Warrior",
    NOW = zh and "现在" or "NOW",
    NEXT = zh and "即将" or "NEXT",
    AFTER_SWING = zh and "随后" or "LATER",
    COOLDOWNS = zh and "核心技能冷却" or "Core cooldowns",
    WAIT_TARGET = zh and "选择敌对目标" or "Select a hostile target",
    WAIT = zh and "等待" or "Wait",
    WAIT_GCD = zh and "等待公共冷却" or "Wait for global cooldown",
    WAIT_SWING = zh and "等待下一次白字" or "Wait for next swing",
    OUT_OF_RANGE = zh and "目标不在近战范围" or "Target out of melee range",
    RANGE_GRACE = zh and "目标刚离开近战，短暂保留目标" or
        "Target just left melee; holding briefly",
    NO_RAGE = zh and "等待怒气" or "Wait for rage",
    UNSUPPORTED = zh and "当前仅支持战士" or "Warrior only",
    SLAM_WINDOW = zh and "猛击窗口" or "Slam window",
    SLAM_LATE = zh and "猛击过晚" or "Slam is late",
    SWING_WAIT = zh and "等待平砍计时" or "Waiting for swing timer",
    CAST_WAIT = zh and "等待施法信息" or "Waiting for cast information",
    FLAME_SHOCK_TIMER = zh and "烈焰震击" or "Flame Shock",
    LAVA_IN_FLIGHT = zh and "熔岩爆裂飞行中" or "Lava Burst in flight",
    LOCKED = zh and "已锁定" or "Locked",
    UNLOCKED = zh and "已解锁，可拖动" or "Unlocked - drag to move",
}

D.Names = {
    BATTLE_STANCE = zh and "战斗姿态" or "Battle Stance",
    DEFENSIVE_STANCE = zh and "防御姿态" or "Defensive Stance",
    BERSERKER_STANCE = zh and "狂暴姿态" or "Berserker Stance",
    CHARGE = zh and "冲锋" or "Charge",
    INTERCEPT = zh and "拦截" or "Intercept",
    EXECUTE = zh and "斩杀" or "Execute",
    OVERPOWER = zh and "压制" or "Overpower",
    REND = zh and "撕裂" or "Rend",
    MORTAL_STRIKE = zh and "致死打击" or "Mortal Strike",
    BLOODTHIRST = zh and "嗜血" or "Bloodthirst",
    SLAM = zh and "猛击" or "Slam",
    HEROIC_STRIKE = zh and "英勇打击" or "Heroic Strike",
    CLEAVE = zh and "顺劈斩" or "Cleave",
    WHIRLWIND = zh and "旋风斩" or "Whirlwind",
    SWEEPING_STRIKES = zh and "横扫攻击" or "Sweeping Strikes",
    DEATH_WISH = zh and "死亡之愿" or "Death Wish",
    THUNDER_CLAP = zh and "雷霆一击" or "Thunder Clap",
    SHIELD_SLAM = zh and "盾牌猛击" or "Shield Slam",
    REVENGE = zh and "复仇" or "Revenge",
    SUNDER_ARMOR = zh and "破甲攻击" or "Sunder Armor",
    SHIELD_BLOCK = zh and "盾牌格挡" or "Shield Block",
    DEMORALIZING_SHOUT = zh and "挫志怒吼" or "Demoralizing Shout",
    CONCUSSION_BLOW = zh and "震荡猛击" or "Concussion Blow",
    BATTLE_SHOUT = zh and "战斗怒吼" or "Battle Shout",
    BERSERKER_RAGE = zh and "狂暴之怒" or "Berserker Rage",
    BLOODRAGE = zh and "血性狂暴" or "Bloodrage",
    BLOOD_FURY = zh and "血性狂怒" or "Blood Fury",
    ELEMENTAL_MASTERY = zh and "元素掌握" or "Elemental Mastery",
    WAR_STOMP = zh and "战争践踏" or "War Stomp",
    LIGHTNING_BOLT = zh and "闪电箭" or "Lightning Bolt",
    CHAIN_LIGHTNING = zh and "闪电链" or "Chain Lightning",
    LIGHTNING_STRIKE = zh and "闪电打击" or "Lightning Strike",
    STORMSTRIKE = zh and "风暴打击" or "Stormstrike",
    EARTH_SHOCK = zh and "大地震击" or "Earth Shock",
    FROST_SHOCK = zh and "冰霜震击" or "Frost Shock",
    FLAME_SHOCK = zh and "烈焰震击" or "Flame Shock",
    LAVA_BURST = zh and "熔岩爆裂" or "Lava Burst",
    EARTHQUAKE = zh and "地震术" or "Earthquake",
    SEARING_TOTEM = zh and "灼热图腾" or "Searing Totem",
    FIRE_NOVA_TOTEM = zh and "火焰新星图腾" or "Fire Nova Totem",
    MAGMA_TOTEM = zh and "熔岩图腾" or "Magma Totem",
    CLEARCASTING = zh and "节能施法" or "Clearcasting",
    HORDE_INSIGNIA = zh and "部落徽记" or "Insignia of the Horde",
    AUTO_ATTACK = zh and "自动攻击" or "Auto Attack",
    WAIT = zh and "等待" or "Wait",
}

-- 以内部动作 key 索引的静态元数据。name/texture 是查询与显示回退，cost 是
-- 基础资源消耗，virtual 表示不应从技能书解析的纯界面动作。
D.SpellDefs = {
    BATTLE_STANCE = {
        name = D.Names.BATTLE_STANCE,
        cost = 0,
        texture = "Interface\\Icons\\Ability_Warrior_OffensiveStance",
    },
    DEFENSIVE_STANCE = {
        name = D.Names.DEFENSIVE_STANCE,
        cost = 0,
        texture = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
    },
    BERSERKER_STANCE = {
        name = D.Names.BERSERKER_STANCE,
        cost = 0,
        texture = "Interface\\Icons\\Ability_Racial_Avatar",
    },
    CHARGE = {
        name = D.Names.CHARGE,
        cost = 0,
        texture = "Interface\\Icons\\Ability_Warrior_Charge",
    },
    INTERCEPT = {
        name = D.Names.INTERCEPT,
        cost = 10,
        texture = "Interface\\Icons\\Ability_Rogue_Sprint",
    },
    EXECUTE = {
        name = D.Names.EXECUTE,
        cost = 15,
        texture = "Interface\\Icons\\INV_Sword_48",
    },
    OVERPOWER = {
        name = D.Names.OVERPOWER,
        cost = 5,
        texture = "Interface\\Icons\\Ability_MeleeDamage",
    },
    REND = {
        name = D.Names.REND,
        cost = 10,
        texture = "Interface\\Icons\\Ability_Gouge",
    },
    MORTAL_STRIKE = {
        name = D.Names.MORTAL_STRIKE,
        cost = 30,
        texture = "Interface\\Icons\\Ability_Warrior_SavageBlow",
    },
    BLOODTHIRST = {
        name = D.Names.BLOODTHIRST,
        cost = 30,
        texture = "Interface\\Icons\\Spell_Nature_BloodLust",
    },
    SLAM = {
        name = D.Names.SLAM,
        cost = 15,
        texture = "Interface\\Icons\\Ability_Warrior_DecisiveStrike_New",
    },
    HEROIC_STRIKE = {
        name = D.Names.HEROIC_STRIKE,
        cost = 15,
        texture = "Interface\\Icons\\Ability_Rogue_Ambush",
    },
    CLEAVE = {
        name = D.Names.CLEAVE,
        cost = 20,
        texture = "Interface\\Icons\\Ability_Warrior_Cleave",
    },
    WHIRLWIND = {
        name = D.Names.WHIRLWIND,
        cost = 25,
        texture = "Interface\\Icons\\Ability_Whirlwind",
    },
    SWEEPING_STRIKES = {
        name = D.Names.SWEEPING_STRIKES,
        cost = 20,
        texture = "Interface\\Icons\\Ability_Rogue_SliceDice",
    },
    DEATH_WISH = {
        name = D.Names.DEATH_WISH,
        cost = 10,
        texture = "Interface\\Icons\\Spell_Shadow_DeathPact",
    },
    THUNDER_CLAP = {
        name = D.Names.THUNDER_CLAP,
        cost = 20,
        texture = "Interface\\Icons\\Spell_Nature_ThunderClap",
    },
    SHIELD_SLAM = {
        name = D.Names.SHIELD_SLAM,
        cost = 20,
        texture = "Interface\\Icons\\INV_Shield_05",
    },
    REVENGE = {
        name = D.Names.REVENGE,
        cost = 5,
        texture = "Interface\\Icons\\Ability_Warrior_Revenge",
    },
    SUNDER_ARMOR = {
        -- Turtle WoW removed Improved Sunder Armor and folded its full
        -- five-rage reduction into the base spell.
        name = D.Names.SUNDER_ARMOR,
        cost = 10,
        texture = "Interface\\Icons\\Ability_Warrior_Sunder",
    },
    SHIELD_BLOCK = {
        name = D.Names.SHIELD_BLOCK,
        cost = 10,
        texture = "Interface\\Icons\\Ability_Defend",
    },
    DEMORALIZING_SHOUT = {
        name = D.Names.DEMORALIZING_SHOUT,
        cost = 10,
        texture = "Interface\\Icons\\Ability_Warrior_WarCry",
    },
    CONCUSSION_BLOW = {
        name = D.Names.CONCUSSION_BLOW,
        cost = 15,
        texture = "Interface\\Icons\\Ability_ThunderBolt",
    },
    BATTLE_SHOUT = {
        name = D.Names.BATTLE_SHOUT,
        cost = 10,
        texture = "Interface\\Icons\\Ability_Warrior_BattleShout",
    },
    BERSERKER_RAGE = {
        name = D.Names.BERSERKER_RAGE,
        cost = 0,
        texture = "Interface\\Icons\\Spell_Nature_AncestralGuardian",
    },
    BLOODRAGE = {
        name = D.Names.BLOODRAGE,
        cost = 0,
        texture = "Interface\\Icons\\Ability_Racial_BloodRage",
    },
    BLOOD_FURY = {
        name = D.Names.BLOOD_FURY,
        cost = 0,
        texture = "Interface\\Icons\\Racial_Orc_BerserkerStrength",
    },
    ELEMENTAL_MASTERY = {
        name = D.Names.ELEMENTAL_MASTERY,
        cost = 0,
        texture = "Interface\\Icons\\Spell_Nature_WispHeal",
    },
    WAR_STOMP = {
        name = D.Names.WAR_STOMP,
        cost = 0,
        texture = "Interface\\Icons\\Ability_WarStomp",
    },
    LIGHTNING_BOLT = {
        name = D.Names.LIGHTNING_BOLT,
        cost = 0,
        texture = "Interface\\Icons\\Spell_Nature_Lightning",
    },
    CHAIN_LIGHTNING = {
        name = D.Names.CHAIN_LIGHTNING,
        cost = 0,
        texture = "Interface\\Icons\\Spell_Nature_ChainLightning",
    },
    LIGHTNING_STRIKE = {
        name = D.Names.LIGHTNING_STRIKE,
        cost = 0,
        texture = "Interface\\Icons\\Spell_Lightning_LightningBolt01",
    },
    STORMSTRIKE = {
        name = D.Names.STORMSTRIKE,
        cost = 0,
        texture = "Interface\\Icons\\Ability_Shaman_StormStrike",
    },
    EARTH_SHOCK = {
        name = D.Names.EARTH_SHOCK,
        cost = 0,
        texture = "Interface\\Icons\\Spell_Nature_EarthShock",
    },
    FROST_SHOCK = {
        name = D.Names.FROST_SHOCK,
        cost = 0,
        texture = "Interface\\Icons\\Spell_Frost_FrostShock",
    },
    FLAME_SHOCK = {
        name = D.Names.FLAME_SHOCK,
        cost = 0,
        texture = "Interface\\Icons\\Spell_Fire_FlameShock",
    },
    LAVA_BURST = {
        name = D.Names.LAVA_BURST,
        cost = 0,
        texture = "Interface\\Icons\\Spell_Shaman_LavaBurst",
    },
    EARTHQUAKE = {
        name = D.Names.EARTHQUAKE,
        cost = 0,
        texture = "Interface\\Icons\\Spell_Nature_Earthquake",
    },
    SEARING_TOTEM = {
        name = D.Names.SEARING_TOTEM,
        cost = 0,
        texture = "Interface\\Icons\\Spell_Fire_SearingTotem",
    },
    FIRE_NOVA_TOTEM = {
        name = D.Names.FIRE_NOVA_TOTEM,
        cost = 0,
        texture = "Interface\\Icons\\Spell_Fire_SealOfFire",
    },
    MAGMA_TOTEM = {
        name = D.Names.MAGMA_TOTEM,
        cost = 0,
        texture = "Interface\\Icons\\Spell_Fire_SelfDestruct",
    },
    CLEARCASTING = {
        name = D.Names.CLEARCASTING,
        cost = 0,
        texture = "Interface\\Icons\\Spell_Shadow_ManaBurn",
        virtual = true,
    },
    HORDE_INSIGNIA = {
        name = D.Names.HORDE_INSIGNIA,
        cost = 0,
        texture = "Interface\\Icons\\INV_Jewelry_TrinketPVP_02",
        virtual = true,
    },
    AUTO_ATTACK = {
        name = D.Names.AUTO_ATTACK,
        cost = 0,
        texture = "Interface\\Icons\\Ability_MeleeDamage",
        virtual = true,
    },
    WAIT = {
        name = D.Names.WAIT,
        cost = 0,
        texture = "Interface\\Icons\\INV_Misc_PocketWatch_01",
        virtual = true,
    },
}

D.SpellOrder = {
    "BATTLE_STANCE",
    "DEFENSIVE_STANCE",
    "BERSERKER_STANCE",
    "CHARGE",
    "INTERCEPT",
    "EXECUTE",
    "OVERPOWER",
    "REND",
    "MORTAL_STRIKE",
    "BLOODTHIRST",
    "SLAM",
    "HEROIC_STRIKE",
    "CLEAVE",
    "WHIRLWIND",
    "SWEEPING_STRIKES",
    "DEATH_WISH",
    "THUNDER_CLAP",
    "SHIELD_SLAM",
    "REVENGE",
    "SUNDER_ARMOR",
    "SHIELD_BLOCK",
    "DEMORALIZING_SHOUT",
    "CONCUSSION_BLOW",
    "BATTLE_SHOUT",
    "BERSERKER_RAGE",
    "BLOODRAGE",
    "BLOOD_FURY",
    "ELEMENTAL_MASTERY",
    "WAR_STOMP",
    "LIGHTNING_BOLT",
    "CHAIN_LIGHTNING",
    "LIGHTNING_STRIKE",
    "STORMSTRIKE",
    "EARTH_SHOCK",
    "FROST_SHOCK",
    "FLAME_SHOCK",
    "LAVA_BURST",
    "EARTHQUAKE",
    "SEARING_TOTEM",
    "FIRE_NOVA_TOTEM",
    "MAGMA_TOTEM",
}

D.WarriorCooldownKeys = {
    "INTERCEPT",
    "MORTAL_STRIKE",
    "OVERPOWER",
    "WHIRLWIND",
    "SWEEPING_STRIKES",
    "THUNDER_CLAP",
    "BERSERKER_RAGE",
    "BLOODRAGE",
    "BLOOD_FURY",
}
D.CooldownKeys = D.WarriorCooldownKeys

D.WarriorProtectionCooldownKeys = {
    "CONCUSSION_BLOW",
    "SHIELD_SLAM",
    "REVENGE",
    "THUNDER_CLAP",
    "SHIELD_BLOCK",
}

D.ShamanCooldownKeys = {
    "ELEMENTAL_MASTERY",
    "WAR_STOMP",
    "LAVA_BURST",
    "FLAME_SHOCK",
    "CHAIN_LIGHTNING",
    "LIGHTNING_STRIKE",
    "STORMSTRIKE",
    "EARTH_SHOCK",
    "FROST_SHOCK",
    "EARTHQUAKE",
    "FIRE_NOVA_TOTEM",
}

-- SavedVariables 根默认值。profileSettings 保存职业／Profile 数据；
-- 循环专属配置位于 profileSettings[profileKey].rotations 下。
D.DEFAULTS = {
    enabled = true,
    locked = true,
    mode = "single",
    scale = 1.00,
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = -125,
    showOnlyCombat = false,
    showForecast = true,
    showResource = true,
    showCooldowns = true,
    tier3TwoPiece = false,
    tankAssistEnabled = false,
    tankAssistName = "",
    heroicRage = 60,
    cleaveRage = 55,
    minimapAngle = -45,
    showMinimap = true,
    profileSettings = {},
}

D.WarriorCatalogModeKeys = {
    "arms_berserker_single",
    "protection_single",
    "arms_berserker_aoe",
    "protection_aoe",
}
D.WarriorCatalogModeSet = {}
do
    local index = 1
    while index <= table.getn(D.WarriorCatalogModeKeys) do
        D.WarriorCatalogModeSet[
            D.WarriorCatalogModeKeys[index]
        ] = true
        index = index + 1
    end
end

D.PROFILE_DEFAULTS = {
    WARRIOR_ARMS = {
        maintainBattleShout = true,
        showBloodrage = true,
        showBloodFury = true,
    },
    WARRIOR_PROTECTION = {},
    WARRIOR_ALL = {},
    SHAMAN_ELEMENTAL = {
        enhancePvPShock = "earth",
        singleOutputMode = "conserve",
        aoeOutputMode = "conserve",
        enableCL = true,
        enableCLAoE = true,
        enableQuakeAoE = true,
        enableESMoving = true,
        enableFSLB = true,
        enableSearingTotem = true,
        enableFireNovaTotem = true,
        enableMagmaTotem = true,
    },
}

-- 这些运行时记录会被复用以避免每帧分配；调用方只能把它们视作当前快照，
-- 不得长期持有并当作历史记录。
--   Spells[key]：已解析的技能书 slot/id/name/texture。
--   State：通用观测字段，以及 Profile:BuildState 追加的职业字段。
--   State.cooldowns[key]：remaining、duration、known、proc、procRemaining。
--   Recommendation／Forecasts[n]：包含 key/name/texture/reason、展示状态、
--     eta、uncertain 及可选 Profile 元数据的动作记录。
--   Profiles／Trackers：由已加载 Profile 文件注册的实例表。
D.Spells = D.Spells or {}
D.State = D.State or {}
D.Recommendation = D.Recommendation or {}
D.Forecasts = D.Forecasts or {}
D.Profiles = D.Profiles or {}
D.Trackers = D.Trackers or {}

local function Clamp(value, low, high)
    value = tonumber(value) or low
    if value < low then return low end
    if value > high then return high end
    return value
end

local function BoolValue(value)
    return value == true or value == 1
end

local function NormalizeTankName(value)
    if type(value) ~= "string" then
        return ""
    end
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

local function SameUnitName(left, right)
    left = NormalizeTankName(left)
    right = NormalizeTankName(right)
    if left == "" or right == "" then
        return false
    end
    return string.lower(left) == string.lower(right)
end

local function MigrateShamanElementalProfile(profileDB)
    if type(profileDB) ~= "table" then return end

    local legacyOutputMode = profileDB.outputMode
    if legacyOutputMode ~= "conserve" and legacyOutputMode ~= "burst" then
        legacyOutputMode = BoolValue(profileDB.enablePvPBurst)
            and "burst" or "conserve"
    end
    if profileDB.singleOutputMode ~= "conserve"
        and profileDB.singleOutputMode ~= "burst" then
        profileDB.singleOutputMode = legacyOutputMode
    end
    if profileDB.aoeOutputMode ~= "conserve"
        and profileDB.aoeOutputMode ~= "burst" then
        profileDB.aoeOutputMode = legacyOutputMode
    end

    local legacyTotemsEnabled = profileDB.enablePvEDamageTotems ~= false
        and profileDB.enablePvEDamageTotems ~= 0
    if profileDB.enableSearingTotem == nil then
        profileDB.enableSearingTotem = legacyTotemsEnabled
    end
    if profileDB.enableFireNovaTotem == nil then
        profileDB.enableFireNovaTotem = legacyTotemsEnabled
    end
    if profileDB.enableMagmaTotem == nil then
        profileDB.enableMagmaTotem = legacyTotemsEnabled
    end
end

function D:Print(message)
    local frame = DEFAULT_CHAT_FRAME or ChatFrame1
    if frame and frame.AddMessage then
        frame:AddMessage("|cff6FA8DCDoiteDPS:|r " .. tostring(message or ""))
    end
end

function D:InitializeDB()
    DoiteDPSDB = DoiteDPSDB or {}
    local key, value
    for key, value in pairs(self.DEFAULTS) do
        if DoiteDPSDB[key] == nil then
            if type(value) == "table" then
                DoiteDPSDB[key] = {}
            else
                DoiteDPSDB[key] = value
            end
        end
    end

    DoiteDPSDB.scale = Clamp(DoiteDPSDB.scale, 0.60, 1.60)
    DoiteDPSDB.heroicRage = Clamp(DoiteDPSDB.heroicRage, 30, 100)
    DoiteDPSDB.cleaveRage = Clamp(DoiteDPSDB.cleaveRage, 30, 100)
    DoiteDPSDB.tankAssistEnabled = BoolValue(
        DoiteDPSDB.tankAssistEnabled
    )
    DoiteDPSDB.tankAssistName = NormalizeTankName(
        DoiteDPSDB.tankAssistName
    )

    if DoiteDPSDB.mode == "battle_single" then
        DoiteDPSDB.mode = "battle"
    elseif DoiteDPSDB.mode ~= "aoe"
        and DoiteDPSDB.mode ~= "battle"
        and DoiteDPSDB.mode ~= "battle_aoe"
        and not self.WarriorCatalogModeSet[DoiteDPSDB.mode] then
        DoiteDPSDB.mode = "single"
    end

    self.DB = DoiteDPSDB
    self:InitializeProfileDB()
end

function D:InitializeProfileDB()
    if not self.DB then return end
    if type(self.DB.profileSettings) ~= "table" then
        self.DB.profileSettings = {}
    end

    local profileKey, defaults
    for profileKey, defaults in pairs(self.PROFILE_DEFAULTS) do
        local profileDB = self.DB.profileSettings[profileKey]
        if type(profileDB) ~= "table" then
            profileDB = {}
            self.DB.profileSettings[profileKey] = profileDB
        end

        if profileKey == "SHAMAN_ELEMENTAL" then
            MigrateShamanElementalProfile(profileDB)
        end

        local key, value
        for key, value in pairs(defaults) do
            if profileDB[key] == nil then
                profileDB[key] = value
            end
        end
    end
end

function D:GetProfileDB(profileKey)
    if not self.DB then
        self:InitializeDB()
    end
    self:InitializeProfileDB()
    if type(self.DB.profileSettings[profileKey]) ~= "table" then
        self.DB.profileSettings[profileKey] = {}
    end
    return self.DB.profileSettings[profileKey]
end

local function FillMissingDefaults(target, defaults)
    if type(target) ~= "table" or type(defaults) ~= "table" then
        return target
    end

    local key, value
    for key, value in pairs(defaults) do
        if target[key] == nil then
            if type(value) == "table" then
                target[key] = {}
                FillMissingDefaults(target[key], value)
            else
                target[key] = value
            end
        elseif type(value) == "table"
            and type(target[key]) == "table" then
            FillMissingDefaults(target[key], value)
        end
    end
    return target
end

-- 循环配置按 Profile 和标准化模式保存。只补齐缺失的默认值，加载过程绝不覆盖
-- 用户已经保存的选择。
function D:GetRotationDB(profileKey, mode, defaults)
    local profileDB = self:GetProfileDB(profileKey)
    if type(profileDB.rotations) ~= "table" then
        profileDB.rotations = {}
    end

    if type(profileDB.rotations[mode]) ~= "table" then
        profileDB.rotations[mode] = {}
    end

    local rotationDB = profileDB.rotations[mode]
    FillMissingDefaults(rotationDB, defaults)
    return rotationDB
end

function D:ResetRotationDB(profileKey, mode, defaults)
    local profileDB = self:GetProfileDB(profileKey)
    if type(profileDB.rotations) ~= "table" then
        profileDB.rotations = {}
    end
    profileDB.rotations[mode] = {}
    return self:GetRotationDB(profileKey, mode, defaults)
end

function D:GetProfileByKey(profileKey)
    local _, profile
    for _, profile in pairs(self.Profiles or {}) do
        if profile and profile.key == profileKey then
            return profile
        end
    end
    return nil
end

function D:NormalizeModeForProfile(profile, mode)
    if profile and profile.NormalizeMode then
        return profile:NormalizeMode(mode)
    end
    if mode == "aoe" then
        return "aoe"
    end
    return "single"
end

function D:GetModeLabel(profile, mode)
    if profile and profile.GetModeLabel then
        return profile:GetModeLabel(mode)
    end
    if mode == "aoe" then
        return self.Text.AOE
    end
    return self.Text.SINGLE
end

local function TrimRotationName(value)
    value = tostring(value or "")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

local RESERVED_ROTATION_NAMES = {
    single = true,
    battle = true,
    aoe = true,
    pvp_close = true,
    battle_aoe = true,
    battle_single = true,
}
do
    local index = 1
    while index <= table.getn(D.WarriorCatalogModeKeys or {}) do
        RESERVED_ROTATION_NAMES[
            D.WarriorCatalogModeKeys[index]
        ] = true
        index = index + 1
    end
end

local function IsReservedRotationName(value)
    return RESERVED_ROTATION_NAMES[
        string.lower(TrimRotationName(value))
    ] == true
end

local function IsMacroSafeRotationName(value)
    value = TrimRotationName(value)
    return value ~= ""
        and not string.find(value, "[\r\n\"]")
        and not string.find(value, "\\", 1, true)
end

local function GetProfileModeOrder(profile)
    if profile and type(profile.ModeOrder) == "table" then
        return profile.ModeOrder
    end

    local order = {}
    local modes = profile
        and profile.ConfigSchema
        and profile.ConfigSchema.modes
    local index = 1
    while type(modes) == "table" and index <= table.getn(modes) do
        order[table.getn(order) + 1] = modes[index].key
        index = index + 1
    end
    if table.getn(order) == 0 then
        order[1] = "single"
        order[2] = "aoe"
    end
    return order
end

function D:GetDefaultRotationName(profile, mode)
    mode = self:NormalizeModeForProfile(profile, mode)
    local modes = profile
        and profile.ConfigSchema
        and profile.ConfigSchema.modes
    local index = 1
    while type(modes) == "table" and index <= table.getn(modes) do
        if modes[index].key == mode and modes[index].label then
            return modes[index].label
        end
        index = index + 1
    end
    return self:GetModeLabel(profile, mode)
end

local function ResolveRotationStorage(profile, mode)
    if profile and profile.ResolveModeProfile then
        local storageProfile, storageMode =
            profile:ResolveModeProfile(mode)
        if storageProfile and storageProfile.key and storageMode then
            return storageProfile, storageMode
        end
    end
    return profile, mode
end

function D:GetRotationName(profile, mode)
    if not profile or not profile.key then
        return self:GetDefaultRotationName(profile, mode)
    end
    mode = self:NormalizeModeForProfile(profile, mode)
    local storageProfile, storageMode =
        ResolveRotationStorage(profile, mode)
    local profileDB = self:GetProfileDB(storageProfile.key)
    local names = profileDB.rotationNames
    local custom = type(names) == "table"
        and TrimRotationName(names[storageMode]) or ""
    if IsMacroSafeRotationName(custom)
        and not IsReservedRotationName(custom) then
        return custom
    end
    return self:GetDefaultRotationName(profile, mode)
end

local PUBLIC_ENTRY_KEYS = {
    single = true,
    aoe = true,
    pvp_close = true,
}

-- 公共入口合同：EntryPoints[entry] 声明 label、允许模式和默认模式；
-- entryBindings 保存当前选择。旧模式名的一次性迁移由 Profile 的
-- version/migrations 负责。
function D:NormalizeEntryPoint(value)
    local entry = string.lower(TrimRotationName(value))
    if PUBLIC_ENTRY_KEYS[entry] then
        return entry
    end
    return nil
end

function D:GetEntryOrder(profile)
    if profile and type(profile.EntryOrder) == "table" then
        return profile.EntryOrder
    end
    return { "single", "aoe" }
end

function D:GetEntryDefinition(profile, entry)
    entry = self:NormalizeEntryPoint(entry)
    if not entry then return nil end
    local definitions = profile and profile.EntryPoints
    if type(definitions) == "table"
        and type(definitions[entry]) == "table" then
        return definitions[entry]
    end
    -- Class-specific public entries must be declared by their profile. This
    -- keeps pvp_close unavailable to Warrior profiles while preserving the
    -- original implicit single/AoE contract for older profiles.
    if entry ~= "single" and entry ~= "aoe" then
        return nil
    end
    return {
        label = entry == "single"
            and (zh and "单体出口" or "Single output")
            or (zh and "AOE出口" or "AoE output"),
        modes = { entry },
        default = entry,
    }
end

function D:GetEntryLabel(profile, entry)
    local definition = self:GetEntryDefinition(profile, entry)
    return definition and definition.label or tostring(entry or "")
end

function D:GetEntryModes(profile, entry)
    local definition = self:GetEntryDefinition(profile, entry)
    local declared = definition and definition.modes or {}
    local modes = {}
    local seen = {}
    local index = 1
    while index <= table.getn(declared) do
        local mode = self:NormalizeModeForProfile(profile, declared[index])
        if not seen[mode] then
            modes[table.getn(modes) + 1] = mode
            seen[mode] = true
        end
        index = index + 1
    end
    return modes
end

function D:IsModeAllowedForEntry(profile, entry, mode)
    if mode == nil or mode == "" then
        return false, nil
    end

    local requested = tostring(mode)
    local normalizedMode = nil
    local profileModes = GetProfileModeOrder(profile)
    local profileIndex = 1
    while profileIndex <= table.getn(profileModes) do
        local declaredMode = tostring(profileModes[profileIndex])
        local candidate = self:NormalizeModeForProfile(
            profile,
            declaredMode
        )
        if requested == declaredMode or requested == candidate then
            normalizedMode = candidate
            break
        end
        profileIndex = profileIndex + 1
    end
    if not normalizedMode then
        return false, nil
    end

    local modes = self:GetEntryModes(profile, entry)
    local index = 1
    while index <= table.getn(modes) do
        if modes[index] == normalizedMode then
            return true, normalizedMode
        end
        index = index + 1
    end
    return false, nil
end

function D:GetDefaultEntryBinding(profile, entry)
    local definition = self:GetEntryDefinition(profile, entry)
    if not definition then return nil end

    local allowed, mode = self:IsModeAllowedForEntry(
        profile,
        entry,
        definition.default
    )
    if allowed then return mode end

    local modes = self:GetEntryModes(profile, entry)
    return modes[1]
end

function D:InitializeEntryBindings(profile)
    if not profile or not profile.key then return nil end
    local profileDB = self:GetProfileDB(profile.key)
    if profile.PrepareEntryBindings then
        profile:PrepareEntryBindings(profileDB)
    end
    if type(profileDB.entryBindings) ~= "table" then
        profileDB.entryBindings = {}
    end
    if type(profileDB.entryBindingVersions) ~= "table" then
        profileDB.entryBindingVersions = {}
    end

    local firstMigration = not profileDB.entryBindingsMigrated
    local entries = self:GetEntryOrder(profile)
    local index = 1
    while index <= table.getn(entries) do
        local entry = self:NormalizeEntryPoint(entries[index])
        if entry then
            local definition = self:GetEntryDefinition(profile, entry)
            local saved = profileDB.entryBindings[entry]
            local version = tonumber(definition and definition.version) or 0
            local savedVersion =
                tonumber(profileDB.entryBindingVersions[entry]) or 0
            if saved ~= nil and version > savedVersion
                and type(definition and definition.migrations) == "table"
                and definition.migrations[saved] ~= nil then
                local previousMode = saved
                saved = definition.migrations[saved]
                profileDB.entryBindings[entry] = saved
                if self.DB and self.DB.mode == previousMode then
                    self.DB.mode = saved
                end
            end
            if version > savedVersion then
                profileDB.entryBindingVersions[entry] = version
            end
            local allowed, normalized =
                self:IsModeAllowedForEntry(profile, entry, saved)

            if not allowed then
                local migrated = nil
                if firstMigration and entry == "single"
                    and self.DB and self.DB.mode then
                    local currentAllowed, currentMode =
                        self:IsModeAllowedForEntry(
                            profile,
                            entry,
                            self.DB.mode
                        )
                    if currentAllowed then
                        migrated = currentMode
                    end
                end
                profileDB.entryBindings[entry] =
                    migrated or self:GetDefaultEntryBinding(profile, entry)
            else
                profileDB.entryBindings[entry] = normalized
            end
        end
        index = index + 1
    end
    profileDB.entryBindingsMigrated = true
    return profileDB.entryBindings
end

function D:GetEntryBinding(profile, entry)
    entry = self:NormalizeEntryPoint(entry)
    if not profile or not entry then return nil end
    local bindings = self:InitializeEntryBindings(profile)
    local mode = bindings and bindings[entry] or nil
    local allowed, normalized =
        self:IsModeAllowedForEntry(profile, entry, mode)
    if allowed then return normalized end
    return self:GetDefaultEntryBinding(profile, entry)
end

function D:SetEntryBinding(profile, entry, mode)
    entry = self:NormalizeEntryPoint(entry)
    if not profile or not profile.key or not entry then
        return false, zh and "无效的输出入口。" or "Invalid output entry."
    end

    local allowed, normalized =
        self:IsModeAllowedForEntry(profile, entry, mode)
    if not allowed then
        return false, zh and "该循环不能绑定到这个输出入口。"
            or "That rotation cannot be assigned to this output entry."
    end

    local bindings = self:InitializeEntryBindings(profile)
    bindings[entry] = normalized
    return true, normalized
end

function D:ResolveEntryMode(profile, entry)
    entry = self:NormalizeEntryPoint(entry)
    if not profile or not entry then return nil end
    return self:GetEntryBinding(profile, entry)
end

function D:SetRotationName(profile, mode, value)
    if not profile or not profile.key then
        return false, zh and "当前职业没有可命名循环。"
            or "The active profile has no named rotations."
    end

    mode = self:NormalizeModeForProfile(profile, mode)
    local name = TrimRotationName(value)
    if name == "" then
        return false, zh and "循环名称不能为空。"
            or "Rotation name cannot be empty."
    end
    if string.len(name) > 48 then
        return false, zh and "循环名称过长，最多48字节。"
            or "Rotation name is too long (48 bytes maximum)."
    end
    if not IsMacroSafeRotationName(name) then
        return false, zh and "循环名称不能包含引号、反斜杠或换行。"
            or "Rotation name cannot contain quotes, backslashes or newlines."
    end

    local lowered = string.lower(name)
    if IsReservedRotationName(name) then
        return false, zh and "该名称是插件内部保留字，请换一个名称。"
            or "That name is reserved internally; choose another name."
    end
    local order = GetProfileModeOrder(profile)
    local index = 1
    while index <= table.getn(order) do
        local otherMode = self:NormalizeModeForProfile(profile, order[index])
        if otherMode ~= mode then
            local otherName = string.lower(
                self:GetRotationName(profile, otherMode)
            )
            local otherDefault = string.lower(
                self:GetDefaultRotationName(profile, otherMode)
            )
            if lowered == otherName
                or lowered == otherDefault then
                return false, zh and "循环名称不能与其他循环重复。"
                    or "Rotation names must be unique."
            end
        end
        index = index + 1
    end

    local storageProfile, storageMode =
        ResolveRotationStorage(profile, mode)
    local profileDB = self:GetProfileDB(storageProfile.key)
    if type(profileDB.rotationNames) ~= "table" then
        profileDB.rotationNames = {}
    end
    local defaultName = self:GetDefaultRotationName(profile, mode)
    if lowered == string.lower(defaultName) then
        profileDB.rotationNames[storageMode] = nil
    else
        profileDB.rotationNames[storageMode] = name
    end
    return true, self:GetRotationName(profile, mode)
end

function D:ResetRotationName(profile, mode)
    if not profile or not profile.key then return false end
    mode = self:NormalizeModeForProfile(profile, mode)
    local storageProfile, storageMode =
        ResolveRotationStorage(profile, mode)
    local profileDB = self:GetProfileDB(storageProfile.key)
    if type(profileDB.rotationNames) == "table" then
        profileDB.rotationNames[storageMode] = nil
    end
    return true
end

function D:ImportEleDPSDB(legacy, force)
    if type(legacy) ~= "table" then
        return false
    end

    local profileDB = self:GetProfileDB("SHAMAN_ELEMENTAL")
    if profileDB.legacyImported and not force then
        return false
    end
    local keys = {
        "enableCL",
        "enableCLAoE",
        "enableQuakeAoE",
        "enableESMoving",
        "enableFSLB",
    }

    local imported = false
    local i = 1
    while i <= table.getn(keys) do
        local key = keys[i]
        if legacy[key] ~= nil then
            profileDB[key] = legacy[key] ~= 0 and legacy[key] ~= false
            imported = true
        end
        i = i + 1
    end

    if imported then
        profileDB.legacyImported = true
    end
    if tonumber(legacy.minimapAngle) then
        self.DB.minimapAngle = tonumber(legacy.minimapAngle)
    end
    return imported
end

function D:GetSpell(key)
    return self.Spells[key]
end

function D:GetSpellDef(key)
    return self.SpellDefs[key]
end

function D:GetTexture(key)
    local spell = self.Spells[key]
    if spell and spell.texture then
        return spell.texture
    end
    local def = self.SpellDefs[key]
    if def and def.texture then
        return def.texture
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

function D:GetName(key)
    local def = self.SpellDefs[key]
    return (def and def.name) or tostring(key or "?")
end

function D:IsKnown(key)
    local def = self.SpellDefs[key]
    if def and def.virtual then
        return true
    end
    local spell = self.Spells[key]
    return spell and spell.slot and true or false
end

function D:RefreshSpellCache()
    local key, def
    for key, def in pairs(self.SpellDefs) do
        local entry = self.Spells[key]
        if not entry then
            entry = {}
            self.Spells[key] = entry
        end
        entry.key = key
        entry.name = def.name
        entry.slot = nil
        entry.bookType = BOOKTYPE_SPELL
        entry.rank = nil
        entry.spellId = nil
        entry.texture = def.texture
    end

    local nameToKey = {}
    for key, def in pairs(self.SpellDefs) do
        if not def.virtual then
            nameToKey[def.name] = key
        end
    end

    local i = 1
    while i <= 300 do
        local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
        if not spellName then
            break
        end

        key = nameToKey[spellName]
        if key then
            local entry = self.Spells[key]
            entry.slot = i
            entry.bookType = BOOKTYPE_SPELL
            entry.rank = spellRank
            if GetSpellTexture then
                local texture = GetSpellTexture(i, BOOKTYPE_SPELL)
                if texture then
                    entry.texture = texture
                end
            end
        end
        i = i + 1
    end

    if GetSpellIdForName then
        for key, def in pairs(self.SpellDefs) do
            if not def.virtual then
                local ok, spellId = pcall(GetSpellIdForName, def.name)
                if ok and spellId and spellId ~= 0 then
                    self.Spells[key].spellId = spellId
                end
            end
        end
    end
end

function D:GetCooldown(key, now)
    local spell = self.Spells[key]
    if not spell or not spell.slot then
        return 0, 0, false
    end

    now = now or GetTime()
    local start, duration, enabled = GetSpellCooldown(
        spell.slot,
        spell.bookType or BOOKTYPE_SPELL
    )

    start = tonumber(start) or 0
    duration = tonumber(duration) or 0
    local remaining = 0

    if start > 0 and duration > 0 then
        remaining = (start + duration) - now
        if remaining < 0 then
            remaining = 0
        end
    end

    return remaining, duration, (duration > self.GCD_MAX), enabled
end

function D:GetNonGCDCooldown(key, now)
    local remaining, duration, isNonGCD = self:GetCooldown(key, now)
    if isNonGCD then
        return remaining, duration
    end
    return 0, duration
end

function D:GetGCDRemaining(now)
    now = now or GetTime()
    local best = 0
    local i = 1
    while i <= table.getn(self.SpellOrder) do
        local key = self.SpellOrder[i]
        local remaining, duration = self:GetCooldown(key, now)
        if duration > 0 and duration <= self.GCD_MAX and remaining > best then
            best = remaining
        end
        i = i + 1
    end
    return best
end

function D:GetMaxRage()
    local rage = UnitManaMax and UnitManaMax("player") or 100
    rage = tonumber(rage) or 100
    if rage < 100 then rage = 100 end
    return rage
end

function D:GetRage()
    local rage = UnitMana and UnitMana("player") or 0
    rage = tonumber(rage) or 0
    if rage < 0 then rage = 0 end
    local maximum = self:GetMaxRage()
    if rage > maximum then rage = maximum end
    return rage
end

function D:GetStance()
    local stance = 0

    if GetNumShapeshiftForms and GetShapeshiftFormInfo then
        local ok, count = pcall(GetNumShapeshiftForms)
        count = ok and tonumber(count) or 0
        local i = 1
        while i <= count do
            local infoOK, icon, name, active =
                pcall(GetShapeshiftFormInfo, i)
            if infoOK and (active == true or active == 1) then
                if name == self.Names.BATTLE_STANCE then
                    stance = 1
                elseif name == self.Names.DEFENSIVE_STANCE then
                    stance = 2
                elseif name == self.Names.BERSERKER_STANCE then
                    stance = 3
                else
                    stance = i
                end
                break
            end
            i = i + 1
        end
    end

    if stance == 0
        and CleveRoids
        and CleveRoids.GetCurrentShapeshiftIndex then
        local ok, value = pcall(
            CleveRoids.GetCurrentShapeshiftIndex
        )
        if ok then stance = tonumber(value) or 0 end
    end

    if stance == 0 and GetBonusBarOffset then
        local ok, value = pcall(GetBonusBarOffset)
        value = ok and tonumber(value) or 0
        if value >= 1 and value <= 3 then
            stance = value
        end
    end

    if stance == 0 and GetShapeshiftForm then
        local ok, value = pcall(GetShapeshiftForm)
        if ok then stance = tonumber(value) or 0 end
    end

    local now = GetTime and GetTime() or 0
    if stance > 0 then
        self._lastKnownStance = stance
        self._lastKnownStanceAt = now
        return stance
    end

    if self._lastKnownStance
        and self._lastKnownStanceAt
        and (now - self._lastKnownStanceAt) <= 0.75 then
        return self._lastKnownStance
    end
    return 0
end

function D:GetManaState()
    local current = UnitMana and tonumber(UnitMana("player")) or 0
    local maximum = UnitManaMax and tonumber(UnitManaMax("player")) or 0
    current = current or 0
    maximum = maximum or 0
    local percent = 0
    if maximum > 0 then
        percent = (current / maximum) * 100
    end
    return current, maximum, Clamp(percent, 0, 100)
end

function D:GetUnitGUID(unit)
    unit = unit or "target"
    local exists, guid = UnitExists(unit)
    if not exists then
        return nil
    end

    -- Nampower exposes GetUnitGUID on 1.12. Prefer it over the later-client
    -- UnitGUID API so combat events and live unit state use the same GUID
    -- representation.
    local guidGetter = nil
    if getglobal then
        guidGetter = getglobal("GetUnitGUID")
    elseif _G then
        guidGetter = _G.GetUnitGUID
    end
    if type(guidGetter) == "function" then
        local ok, value = pcall(guidGetter, unit)
        if ok and value and value ~= "" then
            return value
        end
    end

    if guid and guid ~= "" then
        return guid
    end
    if UnitGUID then
        local ok, value = pcall(UnitGUID, unit)
        if ok and value and value ~= "" then
            return value
        end
    end
    return nil
end

function D:GetDistance(unit)
    unit = unit or "target"
    if not UnitExists(unit) or not UnitXP then
        return nil
    end
    local ok, value = pcall(UnitXP, "distanceBetween", "player", unit)
    value = tonumber(value)
    if ok and value and value >= 0 then
        return value
    end
    return nil
end

function D:IsMeleeRange(unit, meleeKey)
    unit = unit or "target"
    if not UnitExists(unit) then
        return false
    end

    if CleveRoids and CleveRoids.IsUnitInMeleeRange then
        local ok, result = pcall(
            CleveRoids.IsUnitInMeleeRange,
            unit,
            false
        )
        if ok and result ~= nil then
            return result and true or false
        end
    end

    if UnitXP then
        local ok, distance = pcall(
            UnitXP,
            "distanceBetween",
            "player",
            unit,
            "meleeAutoAttack"
        )
        distance = tonumber(distance)
        if ok and distance then
            return distance <= 0
        end
    end

    if meleeKey then
        local result = self:IsInRange(meleeKey, unit)
        if result ~= nil then
            return result
        end
    end

    return nil
end

function D:IsPlayerMoving()
    if PlayerIsMoving then
        local ok, value = pcall(PlayerIsMoving)
        if ok and value ~= nil then
            return value == 1 or value == true
        end
    end

    if CleveRoids and CleveRoids.IsPlayerMoving then
        local ok, value = pcall(CleveRoids.IsPlayerMoving)
        if ok and value ~= nil then
            return value and true or false
        end
    end

    if not GetPlayerMapPosition then
        return false
    end

    local x, y = GetPlayerMapPosition("player")
    if not x or not y or (x == 0 and y == 0) then
        return false
    end

    local now = GetTime()
    if self._moveX and (x ~= self._moveX or y ~= self._moveY) then
        self._movingUntil = now + 0.20
    end
    self._moveX = x
    self._moveY = y
    return self._movingUntil and now <= self._movingUntil or false
end

-- 返回复用的施法观测表。remaining/duration 单位为秒；channel 只描述展示形态，
-- active 才是该记录是否有效的唯一标记。
function D:GetCastState(reuse)
    local cast = reuse or {}
    local info = nil
    local api = CleveRoids and CleveRoids.NampowerAPI

    if api and api.GetCastInfo then
        local ok, value = pcall(api.GetCastInfo)
        if ok then info = value end
    elseif GetCastInfo then
        local ok, value = pcall(GetCastInfo)
        if ok then info = value end
    end

    cast.active = false
    cast.spellId = nil
    cast.name = nil
    cast.remaining = 0
    cast.duration = 0
    cast.channel = false

    if info then
        cast.spellId = tonumber(info.spellId or info.castId)
        cast.remaining = (tonumber(info.castRemainingMs) or 0) / 1000
        cast.duration = (tonumber(info.castDurationMs) or 0) / 1000
        cast.channel = tonumber(info.castType) == 3
        cast.active = cast.spellId and cast.spellId > 0 or cast.remaining > 0
    elseif GetCurrentCastingInfo then
        local ok, castId, visualId, autoId, casting, channeling =
            pcall(GetCurrentCastingInfo)
        if ok and castId and tonumber(castId) and tonumber(castId) > 0 then
            cast.spellId = tonumber(castId)
            cast.channel = channeling == 1
            cast.active = casting == 1 or channeling == 1
        end
    end

    if cast.spellId and GetSpellNameAndRankForId then
        local ok, name = pcall(GetSpellNameAndRankForId, cast.spellId)
        if ok then cast.name = name end
    end

    return cast
end

function D:IsUsable(key)
    local spell = self.Spells[key]
    local def = self.SpellDefs[key]
    if not def then
        return false, false
    end

    if def.virtual then
        return true, false
    end

    if not spell or not spell.slot then
        return false, false
    end

    if IsSpellUsable then
        local arg = spell.spellId or spell.name
        local ok, usable, noPower = pcall(IsSpellUsable, arg)
        if ok and usable ~= nil then
            local canUse = BoolValue(usable)
            local lacksPower = BoolValue(noPower)
            return (canUse and not lacksPower), lacksPower
        end
    end

    local remaining = self:GetNonGCDCooldown(key)
    local cost = tonumber(def.cost) or 0
    local lacksPower = self:GetRage() < cost
    return remaining <= 0.05 and not lacksPower, lacksPower
end

function D:IsInRange(key, unit)
    unit = unit or "target"
    if not UnitExists(unit) then
        return false
    end

    if not IsSpellInRange then
        return nil
    end

    local spell = self.Spells[key]
    if not spell or not spell.slot then
        return nil
    end

    local arg = spell.spellId or spell.name

    local api = CleveRoids and CleveRoids.NampowerAPI
    if api and api.IsSpellInRange then
        local ok, result = pcall(api.IsSpellInRange, arg, unit)
        if ok then
            if result == 1 or result == true then
                return true
            elseif result == 0 or result == false then
                return false
            end
        end
    end

    local ok, result = pcall(IsSpellInRange, arg, unit)
    if not ok then
        return nil
    end

    if result == 1 or result == true then
        return true
    elseif result == 0 or result == false then
        return false
    end
    return nil
end

function D:IsHostileUnit(unit)
    if not unit or type(UnitExists) ~= "function" or not UnitExists(unit) then
        return false
    end
    if type(UnitCanAttack) == "function"
        and not UnitCanAttack("player", unit) then
        return false
    end
    if type(UnitIsDeadOrGhost) == "function"
        and UnitIsDeadOrGhost(unit) then
        return false
    end
    if type(UnitIsDead) == "function" and UnitIsDead(unit) then
        return false
    end
    return true
end

function D:IsHostileTarget()
    return self:IsHostileUnit("target")
end

function D:IsGroupUnitToken(unit)
    local raidCount = type(GetNumRaidMembers) == "function"
        and (tonumber(GetNumRaidMembers()) or 0) or 0
    local index
    if raidCount > 0 then
        index = 1
        while index <= raidCount do
            if unit == "raid" .. tostring(index) then
                return true
            end
            index = index + 1
        end
        return false
    end

    local partyCount = type(GetNumPartyMembers) == "function"
        and (tonumber(GetNumPartyMembers()) or 0) or 0
    index = 1
    while index <= partyCount do
        if unit == "party" .. tostring(index) then
            return true
        end
        index = index + 1
    end
    return false
end

function D:FindGroupUnitByName(name)
    name = NormalizeTankName(name)
    if name == "" or type(UnitName) ~= "function" then
        return nil
    end

    local raidCount = type(GetNumRaidMembers) == "function"
        and (tonumber(GetNumRaidMembers()) or 0) or 0
    local index = 1
    if raidCount > 0 then
        while index <= raidCount do
            local unit = "raid" .. tostring(index)
            if SameUnitName(UnitName(unit), name) then
                return unit
            end
            index = index + 1
        end
        return nil
    end

    local partyCount = type(GetNumPartyMembers) == "function"
        and (tonumber(GetNumPartyMembers()) or 0) or 0
    while index <= partyCount do
        local unit = "party" .. tostring(index)
        if SameUnitName(UnitName(unit), name) then
            return unit
        end
        index = index + 1
    end
    return nil
end

function D:ResolveTankAssistUnit()
    if not self.DB then self:InitializeDB() end
    local name = NormalizeTankName(self.DB.tankAssistName)
    if name == "" then
        self._tankAssistUnit = nil
        return nil
    end

    local cached = self._tankAssistUnit
    if cached
        and self:IsGroupUnitToken(cached)
        and type(UnitName) == "function"
        and SameUnitName(UnitName(cached), name) then
        return cached
    end

    cached = self:FindGroupUnitByName(name)
    self._tankAssistUnit = cached
    return cached
end

function D:CanAssignTankUnit(unit)
    unit = unit or "target"
    if type(UnitExists) ~= "function" or not UnitExists(unit) then
        return false, "no_target"
    end
    if type(UnitIsPlayer) == "function" and not UnitIsPlayer(unit) then
        return false, "not_player"
    end

    local isSelf = false
    if type(UnitIsUnit) == "function" then
        local ok, result = pcall(UnitIsUnit, unit, "player")
        isSelf = ok and result and true or false
    elseif type(UnitName) == "function" then
        isSelf = SameUnitName(UnitName(unit), UnitName("player"))
    end
    if isSelf then
        return false, "self"
    end

    if type(UnitIsFriend) == "function"
        and not UnitIsFriend("player", unit) then
        return false, "not_friendly"
    end
    if type(UnitCanAttack) == "function"
        and UnitCanAttack("player", unit) then
        return false, "not_friendly"
    end

    local name = type(UnitName) == "function" and UnitName(unit) or nil
    name = NormalizeTankName(name)
    if name == "" then
        return false, "not_player"
    end
    local rosterUnit = self:FindGroupUnitByName(name)
    if not rosterUnit then
        return false, "not_grouped"
    end
    return true, rosterUnit, UnitName(rosterUnit) or name
end

function D:ResetTankAssistRuntime()
    self._tankAssistUnit = nil
    self._lastAssistedTargetGUID = nil
end

function D:InvalidateTankAssistRoster()
    self._tankAssistUnit = nil
end

function D:SetTankAssistFromUnit(unit)
    if not self.DB then self:InitializeDB() end
    local valid, rosterUnit, name = self:CanAssignTankUnit(unit)
    if not valid then
        return false, rosterUnit
    end
    self.DB.tankAssistName = NormalizeTankName(name)
    self.DB.tankAssistEnabled = true
    self:ResetTankAssistRuntime()
    self._tankAssistUnit = rosterUnit
    return true, self.DB.tankAssistName
end

function D:ClearTankAssist()
    if not self.DB then self:InitializeDB() end
    self.DB.tankAssistName = ""
    self:ResetTankAssistRuntime()
    return true
end

function D:GetTankAssistStatus()
    if not self.DB then self:InitializeDB() end
    local status = self._tankAssistStatus or {}
    self._tankAssistStatus = status
    status.state = nil
    status.name = NormalizeTankName(self.DB.tankAssistName)
    status.unit = nil
    status.targetUnit = nil
    status.targetName = nil

    if not self.DB.tankAssistEnabled then
        status.state = "disabled"
        return status
    end
    if status.name == "" then
        status.state = "unassigned"
        return status
    end

    local unit = self:ResolveTankAssistUnit()
    if not unit then
        status.state = "unavailable"
        return status
    end
    status.unit = unit

    if type(UnitIsConnected) == "function" and not UnitIsConnected(unit) then
        status.state = "offline"
        return status
    end
    if (type(UnitIsDeadOrGhost) == "function" and UnitIsDeadOrGhost(unit))
        or (type(UnitIsDead) == "function" and UnitIsDead(unit)) then
        status.state = "dead"
        return status
    end

    local targetUnit = unit .. "target"
    if not self:IsHostileUnit(targetUnit) then
        status.state = "no_target"
        return status
    end
    status.state = "ready"
    status.targetUnit = targetUnit
    status.targetName = type(UnitName) == "function"
        and UnitName(targetUnit) or nil
    return status
end

function D:GetTankAssistStatusText(status)
    status = status or self:GetTankAssistStatus()
    local name = status.name ~= "" and status.name
        or (zh and "未指定" or "Unassigned")
    if status.state == "disabled" then
        return zh and "坦克协助：关闭" or "Tank assist: off"
    elseif status.state == "unassigned" then
        return zh and "坦克：未指定" or "Tank: unassigned"
    elseif status.state == "unavailable" then
        return string.format(
            zh and "坦克：%s（不在队伍）" or "Tank: %s (not in group)",
            name
        )
    elseif status.state == "offline" then
        return string.format(
            zh and "坦克：%s（离线）" or "Tank: %s (offline)",
            name
        )
    elseif status.state == "dead" then
        return string.format(
            zh and "坦克：%s（死亡）" or "Tank: %s (dead)",
            name
        )
    elseif status.state == "no_target" then
        return string.format(
            zh and "坦克：%s（暂无敌对目标）" or
                "Tank: %s (no hostile target)",
            name
        )
    elseif status.state == "ready" then
        return string.format(
            zh and "坦克：%s → %s" or "Tank: %s -> %s",
            name,
            status.targetName or (zh and "敌对目标" or "hostile target")
        )
    end
    return zh and "坦克协助：状态未知" or "Tank assist: unknown"
end

function D:GetTankAssistAssignmentError(reason)
    if reason == "not_player" then
        return zh and "当前目标不是玩家。" or
            "The current target is not a player."
    elseif reason == "self" then
        return zh and "不能把自己指定为协助坦克。" or
            "You cannot assign yourself as the assist tank."
    elseif reason == "not_friendly" then
        return zh and "当前目标不是友方玩家。" or
            "The current target is not a friendly player."
    elseif reason == "not_grouped" then
        return zh and "当前目标不在你的队伍或团队中。" or
            "The current target is not in your party or raid."
    end
    return zh and "请先选中队伍或团队中的坦克。" or
        "Target the tank in your party or raid first."
end

function D:TargetMatchesUnit(unit)
    if not self:IsHostileTarget() or not unit then
        return false
    end
    if type(UnitIsUnit) == "function" then
        local ok, result = pcall(UnitIsUnit, "target", unit)
        if ok and result ~= nil then
            return result and true or false
        end
    end
    local targetGUID = self:GetUnitGUID("target")
    local unitGUID = self:GetUnitGUID(unit)
    if targetGUID and unitGUID then
        return targetGUID == unitGUID
    end
    return true
end

function D:TryAssistTankTarget()
    local status = self:GetTankAssistStatus()
    if status.state ~= "ready" then
        return false, status.state
    end

    local currentValid = self:IsHostileTarget()
    local currentGUID = currentValid and self:GetUnitGUID("target") or nil
    local shouldAssist = not currentValid
    if currentValid and not shouldAssist then
        if self._lastAssistedTargetGUID and currentGUID then
            if currentGUID == self._lastAssistedTargetGUID then
                shouldAssist = true
            else
                -- A different live hostile target was selected by the player.
                -- Preserve it until it dies or is cleared.
                self._lastAssistedTargetGUID = nil
                return false, "manual"
            end
        else
            return false, "manual"
        end
    end

    if not shouldAssist then
        return false, "current"
    end
    if currentValid and self:TargetMatchesUnit(status.targetUnit) then
        self._lastAssistedTargetGUID = currentGUID
        return false, "tank"
    end

    if type(AssistUnit) == "function" and status.unit then
        pcall(AssistUnit, status.unit)
    end
    if not self:TargetMatchesUnit(status.targetUnit)
        and type(TargetUnit) == "function" then
        pcall(TargetUnit, status.targetUnit)
    end
    if not self:TargetMatchesUnit(status.targetUnit) then
        return false, "failed"
    end

    self._lastAssistedTargetGUID = self:GetUnitGUID("target")
    return true, "tank"
end

function D:IsExecutionUnitInMeleeRange(unit, meleeKey)
    if not self:IsHostileUnit(unit) then
        return false
    end

    local inMelee = self:IsMeleeRange(unit, meleeKey)
    if inMelee ~= nil then
        return inMelee and true or false
    end

    local distance = self:GetDistance(unit)
    if distance ~= nil then
        return distance <= 5
    end
    return nil
end

function D:IsExecutionTargetInMeleeRange(meleeKey)
    return self:IsExecutionUnitInMeleeRange("target", meleeKey)
end

function D:ResetExecutionTargetRuntime()
    self._executionTargetRangeState = nil
end

function D:ObserveExecutionTargetRange(meleeKey)
    if not self:IsHostileTarget() then
        self._executionTargetRangeState = "none"
        return "none"
    end

    local inMelee = self:IsExecutionTargetInMeleeRange(meleeKey)
    if inMelee == true then
        self._executionTargetRangeState = "melee"
    elseif inMelee == nil then
        -- Unknown range is never permission to steal the player's target.
        self._executionTargetRangeState = "unknown"
    else
        self._executionTargetRangeState = "out"
    end
    return self._executionTargetRangeState
end

local function UnitHealthPercent(unit)
    if type(UnitHealth) ~= "function"
        or type(UnitHealthMax) ~= "function" then
        return 100
    end
    local current = tonumber(UnitHealth(unit)) or 0
    local maximum = tonumber(UnitHealthMax(unit)) or 0
    if maximum <= 0 then return 100 end
    return (current / maximum) * 100
end

function D:FindStableMeleeEnemy(meleeKey)
    local currentGUID = self:GetUnitGUID("target")
    local seen = {}
    if currentGUID then seen[currentGUID] = true end
    local best = nil

    local function AddCandidate(unit, priority, source, trusted)
        if not self:IsHostileUnit(unit) then return end
        local guid = self:GetUnitGUID(unit)
        local identity = guid or ("unit:" .. tostring(unit))
        if seen[identity] then return end
        seen[identity] = true

        if not trusted and type(UnitAffectingCombat) == "function"
            and not UnitAffectingCombat(unit) then
            return
        end
        if self:IsExecutionUnitInMeleeRange(unit, meleeKey) ~= true then
            return
        end

        local distance = tonumber(self:GetDistance(unit)) or 999
        local score = tonumber(priority) or 100
        -- Never hunt for a fresh Execute target. A low-health generic enemy is
        -- still eligible, but loses ties to an equally useful stable target.
        if not trusted and UnitHealthPercent(unit) <= 20 then
            score = score + 5
        end
        if not best or score < best.score
            or (score == best.score and distance < best.distance) then
            best = {
                unit = unit,
                guid = guid,
                score = score,
                distance = distance,
                source = source,
            }
        end
    end

    -- The selected assist tank is authoritative when its target is actually
    -- in melee. Unlike AssistUnit(), this probe does not alter the target.
    local tankStatus = self:GetTankAssistStatus()
    if tankStatus and tankStatus.state == "ready" then
        AddCandidate(tankStatus.targetUnit, 1, "tank_melee", true)
    end

    -- Skull through star, matching the game's raid-mark priority convention.
    local mark = 8
    while mark >= 1 do
        AddCandidate("mark" .. mark, 10 + (8 - mark), "raid_mark", true)
        mark = mark - 1
    end

    local raidCount = type(GetNumRaidMembers) == "function"
        and (tonumber(GetNumRaidMembers()) or 0) or 0
    local index = 1
    while index <= raidCount and index <= 40 do
        AddCandidate("raid" .. index .. "target", 30, "raid_target", false)
        index = index + 1
    end
    local partyCount = type(GetNumPartyMembers) == "function"
        and (tonumber(GetNumPartyMembers()) or 0) or 0
    index = 1
    while index <= partyCount and index <= 4 do
        AddCandidate("party" .. index .. "target", 31, "party_target", false)
        index = index + 1
    end
    AddCandidate("targettarget", 32, "target_target", false)
    AddCandidate("pettarget", 33, "pet_target", false)

    -- Visible nameplate GUIDs are the broadest read-only nearby source. Only
    -- use them when SuperWoW/Nampower explicitly exposes GUID-backed plates.
    local api = CleveRoids and CleveRoids.NampowerAPI or nil
    local features = api and api.features or nil
    local hasPlateGUID = (features and features.hasNameplateGUID)
        or (CleveRoids and CleveRoids.hasSuperwow)
    if hasPlateGUID and WorldFrame
        and type(WorldFrame.GetNumChildren) == "function"
        and type(WorldFrame.GetChildren) == "function" then
        local childCount = tonumber(WorldFrame:GetNumChildren()) or 0
        local children = { WorldFrame:GetChildren() }
        index = 1
        while index <= childCount do
            local frame = children[index]
            local visible = frame and (not frame.IsVisible or frame:IsVisible())
            if visible and type(frame.GetName) == "function" then
                local ok, guid = pcall(frame.GetName, frame, 1)
                if ok and type(guid) == "string" and guid ~= "" then
                    AddCandidate(guid, 40, "nameplate", false)
                end
            end
            index = index + 1
        end
    end

    if CleveRoids and type(CleveRoids.knownEnemyGuids) == "table" then
        for guid in pairs(CleveRoids.knownEnemyGuids) do
            AddCandidate(guid, 50, "known_enemy", false)
        end
    elseif Cursive and Cursive.core
        and type(Cursive.core.guids) == "table" then
        for guid in pairs(Cursive.core.guids) do
            AddCandidate(guid, 50, "known_enemy", false)
        end
    end

    return best
end

function D:SelectStableMeleeEnemy(meleeKey)
    if type(TargetUnit) ~= "function" then
        return false, "unavailable"
    end
    local candidate = self:FindStableMeleeEnemy(meleeKey)
    if not candidate then
        return false, "out_of_range"
    end

    local ok = pcall(TargetUnit, candidate.unit)
    if not ok or not self:TargetMatchesUnit(candidate.unit) then
        return false, "candidate_lost"
    end

    local guid = self:GetUnitGUID("target") or candidate.guid
    self._lastAssistedTargetGUID = guid
    self._executionTargetRangeState = "melee"
    return true, candidate.source or "stable_melee"
end

function D:StartExecutionAttack()
    if CleveRoids and type(CleveRoids.UpdateCastingState) == "function" then
        pcall(CleveRoids.UpdateCastingState)
    end
    local startAttack = CleveRoids and CleveRoids.Hooks
        and CleveRoids.Hooks.STARTATTACK_SlashCmd
        or (SlashCmdList and SlashCmdList.STARTATTACK)
    if type(startAttack) ~= "function" then return false end
    local hadHostileTarget = self:IsHostileTarget()
    local ok, result = pcall(startAttack, "")
    if not hadHostileTarget and self:IsHostileTarget() then
        self._lastAssistedTargetGUID = self:GetUnitGUID("target")
    end
    return ok, result
end

-- 仅供 Execute 使用的选目标策略。近战始终保留有效手动目标；只有 DDPS 自己
-- 选中的目标已确认超出近战范围时，才尝试换成稳定的附近候选。远程先尝试
-- 坦克协助，再回退到最近敌人。
function D:PrepareExecutionTarget(allowNearest, requireMelee, meleeKey)
    if requireMelee then
        local currentValid = self:IsHostileTarget()
        local changed = false
        local source = nil
        if currentValid then
            local rangeState = self:ObserveExecutionTargetRange(meleeKey)
            if rangeState == "melee" or rangeState == "unknown" then
                source = rangeState == "melee" and "current" or "unknown"
            elseif allowNearest then
                local currentGUID = self:GetUnitGUID("target")
                if currentGUID
                    and currentGUID == self._lastAssistedTargetGUID then
                    changed, source = self:SelectStableMeleeEnemy(meleeKey)
                else
                    self._lastAssistedTargetGUID = nil
                    source = "manual"
                end
            else
                source = "out_of_range"
            end
        else
            self._executionTargetRangeState = "none"
            if allowNearest then
                changed, source = self:SelectStableMeleeEnemy(meleeKey)
            else
                source = "none"
            end
        end

        self:StartExecutionAttack()
        return changed, source
    end

    local changed, source = self:TryAssistTankTarget()
    if self:IsHostileTarget() then
        return changed, source
    end

    -- Non-melee profiles preserve their legacy one-step nearest acquisition.
    if allowNearest and type(TargetNearestEnemy) == "function" then
        TargetNearestEnemy()
        if self:IsHostileTarget() then
            self._lastAssistedTargetGUID = self:GetUnitGUID("target")
            return true, "nearest"
        end
    end
    return changed, source or "none"
end

local function ReadUnitHealth(unit, guid)
    if type(GetUnitField) == "function" then
        -- Nampower's public wrapper accepts unit tokens; keep the GUID as a
        -- fallback for older builds that only expose cached objects by GUID.
        local identities = { unit, guid }
        local index = 1
        while index <= table.getn(identities) do
            local identity = identities[index]
            if identity then
                local healthOK, current = pcall(GetUnitField, identity, "health")
                local maxOK, maximum = pcall(GetUnitField, identity, "maxHealth")
                current = healthOK and tonumber(current) or nil
                maximum = maxOK and tonumber(maximum) or nil
                if current and current > 0 and maximum and maximum > 0 then
                    return current, maximum, "nampower"
                end
            end
            index = index + 1
        end
    end

    local current = type(UnitHealth) == "function"
        and (tonumber(UnitHealth(unit)) or 0) or 0
    local maximum = type(UnitHealthMax) == "function"
        and (tonumber(UnitHealthMax(unit)) or 0) or 0
    return current, maximum, "native"
end

function D:UpdateTargetHealthState(state)
    state.targetHP = 100
    state.targetHealthCurrent = nil
    state.targetHealthMax = nil
    state.targetHealthSource = nil
    state.targetClassification = nil
    state.targetBoss = false

    if not state.targetValid then
        return
    end

    local guid = state.targetGUID or self:GetUnitGUID("target")
    local current, maximum, source = ReadUnitHealth("target", guid)
    if maximum <= 0 then
        return
    end

    state.targetHealthCurrent = current
    state.targetHealthMax = maximum
    state.targetHealthSource = source
    state.targetHP = Clamp((current / maximum) * 100, 0, 100)
    if type(UnitClassification) == "function" then
        state.targetClassification = UnitClassification("target")
    end
    local targetLevel = type(UnitLevel) == "function"
        and tonumber(UnitLevel("target")) or nil
    state.targetBoss = state.targetClassification == "worldboss"
        or targetLevel == -1
end

function D:GetPlayerHealthPercent()
    local current = UnitHealth and tonumber(UnitHealth("player")) or 0
    local maximum = UnitHealthMax and tonumber(UnitHealthMax("player")) or 0
    current = current or 0
    maximum = maximum or 0
    if maximum <= 0 then
        return 100
    end
    return Clamp((current / maximum) * 100, 0, 100)
end

local function SameTexture(left, right)
    if type(left) ~= "string" or type(right) ~= "string" then
        return false
    end
    return string.lower(left) == string.lower(right)
end

function D:GetPlayerBuffState(key, withStacks)
    local def = self.SpellDefs[key]
    if not def then
        return false, nil, nil
    end

    local spell = self.Spells[key] or {}
    local spellId = tonumber(spell.spellId)
    local texture = spell.texture or def.texture
    local doiteActive = false
    local doiteRemaining = nil
    local doiteStacks = nil

    if DoitePlayerAuras and DoitePlayerAuras.HasBuff then
        local ok, active = pcall(DoitePlayerAuras.HasBuff, def.name)
        doiteActive = ok and active and true or false
        if withStacks and doiteActive and DoitePlayerAuras.GetBuffStacks then
            local stacksOK, stacks = pcall(
                DoitePlayerAuras.GetBuffStacks,
                def.name
            )
            if stacksOK then doiteStacks = tonumber(stacks) end
        end
    end
    if doiteActive
        and type(DoiteAuras_GetPlayerAuraRemainingSeconds) == "function" then
        local timeOK, timeLeft = pcall(
            DoiteAuras_GetPlayerAuraRemainingSeconds,
            def.name,
            spellId,
            false
        )
        if timeOK then doiteRemaining = tonumber(timeLeft) end
    end

    if GetPlayerBuff and GetPlayerBuffTexture then
        local index = 0
        while index < 32 do
            local ok, buffIndex = pcall(GetPlayerBuff, index, "HELPFUL")
            if ok and buffIndex and tonumber(buffIndex)
                and tonumber(buffIndex) >= 0 then
                local matches = false

                if spellId and GetPlayerBuffID then
                    local idOK, buffSpellId =
                        pcall(GetPlayerBuffID, buffIndex)
                    matches = idOK
                        and tonumber(buffSpellId) == spellId
                end

                if not matches then
                    local textureOK, buffTexture =
                        pcall(GetPlayerBuffTexture, buffIndex)
                    matches = textureOK
                        and SameTexture(buffTexture, texture)
                end

                if matches then
                    local remaining = nil
                    if GetPlayerBuffTimeLeft then
                        local timeOK, timeLeft =
                            pcall(GetPlayerBuffTimeLeft, buffIndex)
                        if timeOK and tonumber(timeLeft)
                            and tonumber(timeLeft) > 0 then
                            remaining = tonumber(timeLeft)
                        end
                    end
                    return true, remaining or doiteRemaining, doiteStacks
                end
            end
            index = index + 1
        end
    end

    if doiteActive then
        if not doiteRemaining and DoitePlayerAuras.GetHiddenBuffRemaining then
            local timeOK, timeLeft = pcall(
                DoitePlayerAuras.GetHiddenBuffRemaining,
                def.name
            )
            if timeOK then doiteRemaining = tonumber(timeLeft) end
        end
        return true, doiteRemaining, doiteStacks
    end

    return false, nil, nil
end

function D:HasTargetDebuff(spellName)
    if not spellName or not UnitExists("target") then
        return false
    end

    if DoiteTrack and DoiteTrack.HasDebuff then
        local ok, result = pcall(DoiteTrack.HasDebuff, spellName)
        if ok and result then
            return true
        end
    end

    local snapshot = DoiteConditions_AuraSnapshot
    local target = snapshot and snapshot.target
    if target and target.debuffs and target.debuffs[spellName] == true then
        return true
    end

    return false
end

function D:GetTargetDebuffRemaining(spellName)
    if not spellName or not UnitExists("target") then
        return nil
    end
    if DoiteTrack and DoiteTrack.GetAuraRemainingSecondsByName then
        local ok, remaining = pcall(
            DoiteTrack.GetAuraRemainingSecondsByName,
            DoiteTrack,
            spellName,
            "target"
        )
        if ok and remaining and remaining > 0 then
            return remaining
        end
    end
    return nil
end

function D:GetTargetDebuffStacks(spellName, spellKey)
    if not spellName or not UnitExists("target") then
        return 0
    end

    if DoiteTrack and DoiteTrack.GetDebuffStacks then
        local ok, stacks = pcall(DoiteTrack.GetDebuffStacks, spellName)
        stacks = tonumber(stacks)
        if ok and stacks and stacks > 0 then
            return stacks
        end
    end

    local spell = spellKey and self.Spells[spellKey] or nil
    local def = spellKey and self.SpellDefs[spellKey] or nil
    local spellId = spell and tonumber(spell.spellId) or nil
    local texture = (spell and spell.texture) or (def and def.texture)
    if UnitDebuff then
        local index = 1
        while index <= 32 do
            local auraTexture, applications, _, auraSpellId =
                UnitDebuff("target", index)
            if not auraTexture then break end
            local matches = spellId and tonumber(auraSpellId) == spellId
            if not matches and texture then
                matches = SameTexture(auraTexture, texture)
            end
            if matches then
                applications = tonumber(applications) or 1
                if applications < 1 then applications = 1 end
                return applications
            end
            index = index + 1
        end
    end

    return self:HasTargetDebuff(spellName) and 1 or 0
end

function D:GetReactiveState(key)
    local name = self:GetName(key)
    if key == "OVERPOWER"
        and CleveRoids
        and CleveRoids.HasReactiveProc then
        local ok, active = pcall(CleveRoids.HasReactiveProc, name)
        if ok then
            if active then
                local remaining = nil
                local data = CleveRoids.reactiveProcs
                    and CleveRoids.reactiveProcs[name]
                if data and data.expiry then
                    remaining = data.expiry - GetTime()
                    if remaining < 0 then remaining = 0 end
                end
                return true, remaining
            end
            -- SuperCleveRoidMacros' combat-log tracker is stance-independent
            -- and authoritative for Overpower. Do not fall through to
            -- IsSpellUsable when it explicitly reports that no proc exists;
            -- that API can retain a stale usable state across character swaps.
            return false, nil
        end
    end

    local usable = self:IsUsable(key)
    return usable and true or false, nil
end

function D:ClearReactiveState()
    local name = self:GetName("OVERPOWER")
    if not CleveRoids or not name then
        return
    end

    if CleveRoids.ClearReactiveProc then
        pcall(CleveRoids.ClearReactiveProc, name)
    elseif CleveRoids.reactiveProcs then
        CleveRoids.reactiveProcs[name] = nil
    end
end

function D:ResetCharacterRuntime()
    self.State = {}
    self._lastKnownStance = nil
    self._lastKnownStanceAt = nil
    self._activeProfileKey = nil
    self._pendingOnSwing = nil
    self._providerOnSwingLease = nil
    self._elapsed = 0
    self:ResetTankAssistRuntime()
    self:ResetExecutionTargetRuntime()
    self:ClearReactiveState()

    if self.UI and self.UI.ResetRuntimeState then
        self.UI:ResetRuntimeState()
    end
end

function D:GetSlamCastTime()
    if CleveRoids and CleveRoids.GetSlamCastTime then
        local ok, value = pcall(CleveRoids.GetSlamCastTime)
        value = tonumber(value)
        if ok and value and value > 0 then
            return value
        end
    end
    return 2.5
end

local ON_SWING_CONFIRM_GRACE = 0.75
local ON_SWING_EXPIRE_GRACE = 0.35

local function OnSwingLeaseDuration(remaining, speed)
    local wait = tonumber(remaining)
    if not wait or wait <= 0 then wait = tonumber(speed) end
    if not wait or wait <= 0 then wait = 3 end
    if wait < ON_SWING_CONFIRM_GRACE then
        wait = ON_SWING_CONFIRM_GRACE
    end
    return wait + ON_SWING_EXPIRE_GRACE
end

function D:MarkOnSwingQueued(key, swing)
    if key ~= "HEROIC_STRIKE" and key ~= "CLEAVE" then
        return false
    end

    local now = GetTime()
    local leaseDuration = OnSwingLeaseDuration(
        swing and swing.remaining,
        swing and swing.speed
    )

    self._pendingOnSwing = {
        key = key,
        queuedAt = now,
        expiresAt = now + leaseDuration,
        confirmed = false,
    }

    -- A provider flag that outlived its predicted swing is normally stale.
    -- If the player deliberately issues the same on-swing spell again later,
    -- start one new bounded observation window so that a genuine new queue can
    -- be confirmed without trusting the old flag forever.
    local providerLease = self._providerOnSwingLease
    if providerLease
        and providerLease.key == key
        and providerLease.stale then
        providerLease.expiresAt = now + leaseDuration
        providerLease.stale = false
    end

    -- Record only an attempted queue here. The client/provider remains the
    -- authority for whether Heroic Strike/Cleave really entered the native
    -- next-swing queue. This still blocks a rapid second press without showing
    -- an unconfirmed spell as already queued.
    if swing then
        swing.hsQueued = false
        swing.cleaveQueued = false
        swing.queuePending = true
        swing.queueConfirmed = false
        swing.pendingKey = key
    end
    return true
end

function D:ClearOnSwingQueued()
    self._pendingOnSwing = nil
end

function D:ResolveOnSwingQueued(spellId)
    local pending = self._pendingOnSwing
    local spell = pending and self.Spells and self.Spells[pending.key]
    if not spell or tonumber(spell.spellId) ~= tonumber(spellId) then
        return false
    end
    self._pendingOnSwing = nil
    return true
end

-- 战士 Profile 共用的标准化主手白字合同：时间字段描述当前白字；
-- queuePending 表示本地排队尝试，queueConfirmed 来自 provider，
-- queueStale 表示过期报告，决策时必须忽略。
function D:GetSwingState(reuse)
    local swing = reuse or {}
    local remaining = nil
    local speed = nil
    local progress = nil
    local active = false
    local provider = nil

    local api = pfUI and pfUI.swingtimer and pfUI.swingtimer.api
    if api and api.IsMHActive and api.GetMHTimer and api.GetMHSpeed then
        local okActive, isActive = pcall(api.IsMHActive)
        if okActive and isActive then
            local okRemaining, valueRemaining = pcall(api.GetMHTimer)
            local okSpeed, valueSpeed = pcall(api.GetMHSpeed)
            if okRemaining and okSpeed then
                remaining = tonumber(valueRemaining)
                speed = tonumber(valueSpeed)
                active = remaining ~= nil and speed ~= nil and speed > 0
                provider = active and "pfUI" or nil
            end
            if active and api.GetMHProgress then
                local okProgress, valueProgress = pcall(api.GetMHProgress)
                if okProgress then
                    progress = tonumber(valueProgress)
                end
            end
        end
    end

    if not active and CleveRoids and CleveRoids.GetSwingTimerRaw then
        local ok, valueRemaining, valueSpeed = pcall(CleveRoids.GetSwingTimerRaw)
        if ok then
            valueRemaining = tonumber(valueRemaining)
            valueSpeed = tonumber(valueSpeed)
            if valueRemaining ~= nil and valueSpeed and valueSpeed > 0 then
                remaining = valueRemaining
                speed = valueSpeed
                active = true
                provider = "SuperCleveRoidMacros"
            end
        end
    end

    if not speed or speed <= 0 then
        local mainSpeed = UnitAttackSpeed and UnitAttackSpeed("player")
        mainSpeed = tonumber(mainSpeed)
        if mainSpeed and mainSpeed > 0 then
            speed = mainSpeed
        end
    end

    if active and speed and speed > 0 then
        if remaining < 0 then remaining = 0 end
        if remaining > speed then remaining = speed end
        if not progress then
            progress = (speed - remaining) / speed
        end
    else
        remaining = nil
        progress = 0
    end

    local castTime = self:GetSlamCastTime()
    local capable = speed and speed > castTime or false
    local safe = active and capable and remaining >= castTime or false

    swing.active = active
    swing.provider = provider
    swing.remaining = remaining
    swing.speed = speed
    swing.progress = Clamp(progress or 0, 0, 1)
    swing.slamCast = castTime
    swing.slamCapable = capable
    swing.slamSafe = safe
    swing.hsQueued = false
    swing.cleaveQueued = false
    swing.queuePending = false
    swing.queueConfirmed = false
    swing.queueStale = false
    swing.pendingKey = nil
    swing.staleKey = nil

    local hsQueueApi = false
    local cleaveQueueApi = false
    local rawHsQueued = false
    local rawCleaveQueued = false
    if api then
        if api.IsHSQueued then
            hsQueueApi = true
            local ok, value = pcall(api.IsHSQueued)
            rawHsQueued = ok and value and true or false
        end
        if api.IsCleaveQueued then
            cleaveQueueApi = true
            local ok, value = pcall(api.IsCleaveQueued)
            rawCleaveQueued = ok and value and true or false
        end
    end

    -- pfUI exposes native queue events, but an unmatched queue-pop/spell-go
    -- event can leave that boolean true indefinitely. Treat a provider report
    -- as authoritative for no longer than the current main-hand swing plus a
    -- small event grace. A stale report is ignored until the provider clears
    -- it or a deliberate new local attempt refreshes the same spell's lease.
    local rawKey = rawHsQueued and "HEROIC_STRIKE"
        or (rawCleaveQueued and "CLEAVE")
    if rawKey then
        local now = GetTime()
        local providerLease = self._providerOnSwingLease
        if not providerLease or providerLease.key ~= rawKey then
            providerLease = {
                key = rawKey,
                expiresAt = now + OnSwingLeaseDuration(remaining, speed),
                stale = false,
            }
            self._providerOnSwingLease = providerLease
        elseif not providerLease.stale
            and now > (tonumber(providerLease.expiresAt) or now) then
            providerLease.stale = true
        end

        if providerLease.stale then
            swing.queueStale = true
            swing.staleKey = rawKey
        else
            swing.hsQueued = rawKey == "HEROIC_STRIKE"
            swing.cleaveQueued = rawKey == "CLEAVE"
        end
    else
        self._providerOnSwingLease = nil
    end

    -- The native next-swing queue event can arrive after the macro-triggered
    -- refresh. Keep that short gap as a hidden attempt lock, then hand display
    -- authority to pfUI when it confirms or rejects the queue. Without a queue
    -- API, retain the legacy latch until the predicted main-hand swing resolves.
    local pending = self._pendingOnSwing
    local actualKey = swing.hsQueued and "HEROIC_STRIKE"
        or (swing.cleaveQueued and "CLEAVE")
    if actualKey then
        swing.queueConfirmed = true
        if pending and pending.key == actualKey then
            pending.confirmed = true
        elseif pending then
            self._pendingOnSwing = nil
        end
    elseif pending then
        local now = GetTime()
        local queuedAt = tonumber(pending.queuedAt) or now
        local expiresAt = tonumber(pending.expiresAt) or queuedAt
        local apiAvailable = false
        if pending.key == "HEROIC_STRIKE" then
            apiAvailable = hsQueueApi
        else
            apiAvailable = cleaveQueueApi
        end
        local confirmationExpired = apiAvailable
            and (now - queuedAt) > ON_SWING_CONFIRM_GRACE

        local confirmationRejected = apiAvailable
            and not pending.confirmed and confirmationExpired
        if now > expiresAt or confirmationRejected then
            self._pendingOnSwing = nil
        else
            -- Queue-pop precedes the real on-swing result. Keep the confirmed
            -- attempt hidden but locked so repeated input cannot arm swing 2.
            swing.queuePending = true
            swing.pendingKey = pending.key
            if not apiAvailable then
                -- Without a queue-state provider there is no confirmation
                -- source. Preserve the legacy predicted-swing latch, but keep
                -- it explicitly marked as pending rather than confirmed.
                swing.hsQueued = pending.key == "HEROIC_STRIKE"
                swing.cleaveQueued = pending.key == "CLEAVE"
            end
        end
    end

    return swing
end

-- Keep DDPS execution decisions beside pfUI's native swing events. The writer
-- lives in pfUI; DDPS never opens or reads the trace file.
function D:TraceSwingExecution(profile, mode, state, action, result)
    local api = pfUI and pfUI.swingtimer and pfUI.swingtimer.api
    if not api or type(api.AppendTrace) ~= "function" then return false end

    state = state or {}
    local swing = state.swing or {}
    local castId, casting, channeling, onSwing, autoAttack = 0, false, false, false, false
    if type(GetCurrentCastingInfo) == "function" then
        local ok, spellId, _, _, isCasting, isChanneling, isOnSwing, isAutoAttack =
            pcall(GetCurrentCastingInfo)
        if ok then
            castId = tonumber(spellId) or 0
            casting = tonumber(isCasting) == 1
            channeling = tonumber(isChanneling) == 1
            onSwing = tonumber(isOnSwing) == 1
            autoAttack = tonumber(isAutoAttack) == 1
        end
    end

    local detail = string.format(
        "profile=%s mode=%s result=%s action=%s actionState=%s actionReason=%q rage=%d target=%s targetValid=%s range=%s melee=%s stateCasting=%s provider=%s swingActive=%s swingRem=%.3f swingSpeed=%.3f swingProgress=%.3f hs=%s cleave=%s pending=%s confirmed=%s stale=%s pendingKey=%s castId=%s casting=%s channeling=%s onSwing=%s autoAttack=%s",
        tostring(profile or "unknown"),
        tostring(mode or "unknown"),
        tostring(result or "unknown"),
        tostring(action and action.key or "none"),
        tostring(action and action.state or "none"),
        tostring(action and action.reason or ""),
        tonumber(state.rage) or 0,
        tostring(state.targetGUID or "none"),
        tostring(state.targetValid == true),
        tostring(state.targetRangeState or "unknown"),
        tostring(state.inMelee == true),
        tostring(state.casting == true),
        tostring(swing.provider or "none"),
        tostring(swing.active == true),
        tonumber(swing.remaining) or 0,
        tonumber(swing.speed) or 0,
        tonumber(swing.progress) or 0,
        tostring(swing.hsQueued == true),
        tostring(swing.cleaveQueued == true),
        tostring(swing.queuePending == true),
        tostring(swing.queueConfirmed == true),
        tostring(swing.queueStale == true),
        tostring(swing.pendingKey or "none"),
        tostring(castId),
        tostring(casting),
        tostring(channeling),
        tostring(onSwing),
        tostring(autoAttack)
    )
    local ok, written = pcall(api.AppendTrace, "DDPS_EXECUTE", detail)
    return ok and written and true or false
end

-- 先建立通用冷却表，再允许 Profile 补充压制／复仇等触发窗口；Profile 不得覆盖
-- 客户端 API 提供的冷却时间。
function D:BuildCooldownState(state, keys, profile)
    state.cooldowns = state.cooldowns or {}
    state.cooldownOrder = keys or {}
    local i = 1
    while i <= table.getn(state.cooldownOrder) do
        local key = state.cooldownOrder[i]
        local entry = state.cooldowns[key]
        if not entry then
            entry = {}
            state.cooldowns[key] = entry
        end
        entry.remaining, entry.duration = self:GetNonGCDCooldown(key, state.now)
        entry.known = self:IsKnown(key)
        entry.proc = false
        entry.procRemaining = nil
        if profile and profile.DecorateCooldown then
            profile:DecorateCooldown(key, entry, state)
        end
        i = i + 1
    end
end

function D:BuildState()
    local state = self.State
    local now = GetTime()
    local _, class = UnitClass("player")
    local profile = self:GetActiveProfile(class)

    -- 阶段 1：读取与职业无关的客户端状态。
    state.now = now
    state.class = class
    state.profileKey = profile and profile.key or nil
    state.mode = self:NormalizeModeForProfile(
        profile,
        (self.DB and self.DB.mode) or "single"
    )
    state.inCombat = self.inCombat and true or false
    state.targetValid = self:IsHostileTarget()
    state.targetGUID = self:GetUnitGUID("target")
    state.targetDistance = self:GetDistance("target")
    state.gcd = self:GetGCDRemaining(now)
    state.mana, state.manaMax, state.manaPercent = self:GetManaState()
    state.moving = self:IsPlayerMoving()
    state.cast = self:GetCastState(state.cast)
    state.casting = state.cast and state.cast.active and true or false
    state.castName = state.cast and state.cast.name or nil
    state.castRemaining = state.cast and state.cast.remaining or 0
    state.castDuration = state.cast and state.cast.duration or 0
    state.resourceType = nil
    state.resourceDisplay = nil
    state.timingType = nil

    -- 阶段 2：读取斩杀决策需要的当前目标实际血量。
    self:UpdateTargetHealthState(state)

    -- 阶段 3：由 Profile 补充职业资源、光环、距离和循环配置。
    if profile and profile.BuildState then
        profile:BuildState(state)
    end

    -- 阶段 4：战士使用距离滞回来保护手动目标，避免 provider 单帧漏报导致换目标；
    -- 其他职业直接使用各自 Profile 的距离结果。
    if class == "WARRIOR" and state.meleeRangeKey then
        state.targetRangeState = self:ObserveExecutionTargetRange(
            state.meleeRangeKey
        )
    else
        state.targetRangeState = nil
    end

    -- 最后构建冷却表，确保 Profile 装饰器读取到完整 State。
    self:BuildCooldownState(
        state,
        profile and profile.CooldownKeys or {},
        profile
    )

    return state
end

function D:GetActiveProfile(class)
    if not class then
        local localizedClass
        localizedClass, class = UnitClass("player")
    end
    if class == "WARRIOR" then
        -- Warrior visibility and execution are selected explicitly through
        -- the shared single/AoE catalog. Talents only affect whether an
        -- individual spell is actually known; they never hide a rotation or
        -- silently replace the player's output binding.
        if self.Profiles.Warrior then
            if self.Profiles.Warrior.PrepareRuntime then
                self.Profiles.Warrior:PrepareRuntime()
            end
            return self.Profiles.Warrior
        end
        return self.Profiles.WarriorArms
            or self.Profiles.WarriorProtection
    elseif class == "SHAMAN" then
        return self.Profiles.ShamanElemental
    end
    return nil
end

-- 纯观测、评估和渲染流程；不会切换目标或施法。相关副作用只能发生在玩家主动
-- 触发的 Execute 调用中。
function D:Update(force)
    if not self.initialized then
        return
    end

    local _, class = UnitClass("player")
    local activeProfile = self:GetActiveProfile(class)
    local activeProfileKey = activeProfile and activeProfile.key or nil
    if self._activeProfileKey ~= activeProfileKey then
        -- The Vanilla client can retain addon globals while returning to the
        -- character screen. Clear class-specific state before building the
        -- first frame for the newly selected character.
        self.State = {}
        self._lastKnownStance = nil
        self._lastKnownStanceAt = nil
        self:ResetExecutionTargetRuntime()
        self:ClearReactiveState()
        if self.UI and self.UI.ResetRuntimeState then
            self.UI:ResetRuntimeState()
        end
        self._activeProfileKey = activeProfileKey
        if activeProfile and activeProfile.ResetRuntime then
            activeProfile:ResetRuntime()
        end
        if self.Config and self.Config.Sync then
            self.Config:Sync()
        end
        if self.Config and self.Config.UpdateMinimapPosition then
            self.Config.UpdateMinimapPosition()
        end
    end

    local state = self:BuildState()
    local profile = activeProfile or self:GetActiveProfile()

    if profile and profile.Evaluate then
        self.Recommendation, self.Forecasts = profile:Evaluate(state)
    else
        local rec = self.Recommendation
        rec.key = "WAIT"
        rec.name = self.Text.UNSUPPORTED
        rec.reason = self.Text.UNSUPPORTED
        rec.state = "disabled"
        rec.eta = nil
        local forecastIndex = 1
        while forecastIndex <= self.FORECAST_LIMIT do
            self.Forecasts[forecastIndex] = nil
            forecastIndex = forecastIndex + 1
        end
    end

    if self.UI and self.UI.Update then
        self.UI:Update(state, self.Recommendation, self.Forecasts, force)
    end
end

function D:SetMode(mode, silent)
    if not self.DB then
        self:InitializeDB()
    end
    local profile = self:GetActiveProfile()
    mode = self:NormalizeModeForProfile(profile, mode)
    local changed = self.DB.mode ~= mode
    self.DB.mode = mode
    if not silent and changed then
        self:Print(
            (zh and "模式：" or "Mode: ")
                .. self:GetRotationName(profile, mode)
        )
    end
    self:Update(true)
    return true
end

function D:SetModeByEntry(entry, silent)
    local profile = self:GetActiveProfile()
    local mode = self:ResolveEntryMode(profile, entry)
    if not mode then
        if not silent then
            self:Print(
                zh and "未知或当前职业不支持的输出入口。"
                    or "Unknown output entry or unsupported by this profile."
            )
        end
        return false
    end
    return self:SetMode(mode, silent)
end

function D:ExecuteMode(mode)
    local profile = self:GetActiveProfile()
    if not profile or not profile.Execute then
        self:Print(zh and "当前职业配置不支持一键执行。" or
            "The active profile does not support one-button execution.")
        return false
    end
    mode = self:NormalizeModeForProfile(profile, mode)
    return profile:Execute(mode)
end

-- 公共宏入口：先解析已保存的输出绑定，再把目标准备和施法决策完整交给所属
-- Profile。
function D:Execute(entry)
    local profile = self:GetActiveProfile()
    if not profile or not profile.Execute then
        self:Print(zh and "当前职业配置不支持一键执行。" or
            "The active profile does not support one-button execution.")
        return false
    end
    local mode = self:ResolveEntryMode(profile, entry)
    if not mode then
        self:Print(
            zh and "未知或当前职业不支持的输出入口。"
                or "Unknown output entry or unsupported by this profile."
        )
        return false
    end
    return profile:Execute(mode)
end

function D:ResetPosition()
    local key, value
    for key, value in pairs(self.DEFAULTS) do
        if type(value) ~= "table" then
            self.DB[key] = value
        end
    end
    self.DB.mode = self:NormalizeModeForProfile(
        self:GetActiveProfile(),
        self.DB.mode
    )
    self:ResetTankAssistRuntime()
    if self.UI and self.UI.ApplySettings then
        self.UI:ApplySettings()
    end
    if self.Config and self.Config.UpdateMinimapPosition then
        self.Config.UpdateMinimapPosition()
    end
    if self.Config and self.Config.Sync then
        self.Config:Sync()
    end
    self:Update(true)
end

function D:MigrateSuperMacroOutputOrder()
    if type(SMP_SUPER) ~= "table" then
        return 0, false
    end

    local changed = 0
    local name, macro
    for name, macro in pairs(SMP_SUPER) do
        if type(macro) == "table" and type(macro[3]) == "string" then
            local body = macro[3]
            local updated, crlfCount = string.gsub(
                body,
                "/startattack\r\n(/run%s+DoiteDPS_Execute%b())",
                "%1\r\n/startattack",
                1
            )
            local lfCount
            updated, lfCount = string.gsub(
                updated,
                "/startattack\n(/run%s+DoiteDPS_Execute%b())",
                "%1\n/startattack",
                1
            )
            if (crlfCount or 0) + (lfCount or 0) > 0 then
                macro[3] = updated
                changed = changed + 1
                if type(SMP_UpdateActionSpell) == "function" then
                    pcall(SMP_UpdateActionSpell, name, "super", updated)
                end
                if type(SMP_NotifyMacroChanged) == "function" then
                    pcall(SMP_NotifyMacroChanged, name)
                end
            end
        end
    end
    return changed, true
end

function D:HandleSlash(message)
    message = message or ""
    if not self.DB then self:InitializeDB() end
    local _, _, command, rest = string.find(message, "^%s*(%S*)%s*(.-)%s*$")
    command = command and string.lower(command) or ""

    if command == "" or command == "toggle" then
        self.DB.enabled = not self.DB.enabled
        self:Update(true)
    elseif command == "show" then
        self.DB.enabled = true
        self:Update(true)
    elseif command == "hide" then
        self.DB.enabled = false
        self:Update(true)
    elseif command == "lock" then
        self.DB.locked = true
        if self.UI and self.UI.ApplyLock then self.UI:ApplyLock() end
        if self.Config and self.Config.Sync then self.Config:Sync() end
        self:Update(true)
        self:Print(self.Text.LOCKED)
    elseif command == "unlock" then
        self.DB.locked = false
        self.DB.enabled = true
        if self.UI and self.UI.ApplyLock then self.UI:ApplyLock() end
        if self.Config and self.Config.Sync then self.Config:Sync() end
        self:Update(true)
        self:Print(self.Text.UNLOCKED)
    elseif command == "mode" then
        self:SetModeByEntry(rest)
    elseif command == "scale" then
        local scale = Clamp(rest, 0.60, 1.60)
        self.DB.scale = scale
        if self.UI and self.UI.ApplySettings then self.UI:ApplySettings() end
        self:Print((zh and "缩放：" or "Scale: ") .. string.format("%.2f", scale))
    elseif command == "combat" then
        self.DB.showOnlyCombat = not self.DB.showOnlyCombat
        self:Print(zh and
            ("仅战斗显示：" .. (self.DB.showOnlyCombat and "开启" or "关闭")) or
            ("Combat only: " .. (self.DB.showOnlyCombat and "on" or "off")))
        self:Update(true)
    elseif command == "test" then
        self.testMode = not self.testMode
        self.DB.enabled = true
        self:Print(zh and
            ("测试模式：" .. (self.testMode and "开启" or "关闭")) or
            ("Test mode: " .. (self.testMode and "on" or "off")))
        self:Update(true)
    elseif command == "cast" then
        if rest == "" then
            self:Execute("single")
        else
            self:Execute(rest)
        end
    elseif command == "tank" then
        local tankCommand = string.lower(NormalizeTankName(rest))
        if tankCommand == "set" then
            local ok, nameOrReason = self:SetTankAssistFromUnit("target")
            if ok then
                self:Print((zh and "已指定协助坦克：" or
                    "Assist tank assigned: ") .. nameOrReason)
            else
                self:Print(self:GetTankAssistAssignmentError(nameOrReason))
            end
            if self.Config and self.Config.Sync then self.Config:Sync() end
            self:Update(true)
        elseif tankCommand == "clear" then
            self:ClearTankAssist()
            self:Print(zh and "已清除协助坦克。" or
                "Assist tank cleared.")
            if self.Config and self.Config.Sync then self.Config:Sync() end
            self:Update(true)
        elseif tankCommand == "" or tankCommand == "status" then
            self:Print(self:GetTankAssistStatusText())
        else
            self:Print(zh and "/ddps tank set|clear|status" or
                "/ddps tank set|clear|status")
        end
    elseif command == "macros" then
        local migrated, available = self:MigrateSuperMacroOutputOrder()
        if not available then
            self:Print(zh and "未检测到 SuperMacroPlus。" or
                "SuperMacroPlus was not detected.")
        elseif migrated > 0 then
            self:Print(string.format(
                zh and "已更新 %d 个 DDPS 输出宏；无需重新拖动动作条。" or
                    "Updated %d DDPS output macro(s); action-bar slots were preserved.",
                migrated
            ))
        else
            self:Print(zh and "DDPS 输出宏顺序已经正确。" or
                "DDPS output macro order is already current.")
        end
    elseif command == "config" then
        if self.Config and self.Config.Toggle then
            self.Config:Toggle()
        end
    elseif command == "debug" then
        self.debugMode = not self.debugMode
        EleDPS_Debug = self.debugMode
        self:Print(zh and
            ("调试：" .. (self.debugMode and "开启" or "关闭")) or
            ("Debug: " .. (self.debugMode and "on" or "off")))
    elseif command == "status" then
        local state = self:BuildState()
        if state.class == "SHAMAN" then
            self:Print(string.format(
                "mana=%d/%d cc=%d fs=%.1f cast=%s castRem=%.2f moving=%s gcd=%.2f",
                state.mana or 0,
                state.manaMax or 0,
                state.clearcasting or 0,
                state.flameShockRemaining or 0,
                tostring(state.castName),
                state.castRemaining or 0,
                tostring(state.moving),
                state.gcd or 0
            ))
        else
            local swing = state.swing or {}
            self:Print(string.format(
                "rage=%d stance=%d hp=%.1f gcd=%.2f swing=%s rem=%s speed=%s slam=%s",
                state.rage or 0,
                state.stance or 0,
                state.targetHP or 0,
                state.gcd or 0,
                tostring(swing.active),
                tostring(swing.remaining),
                tostring(swing.speed),
                tostring(swing.slamSafe)
            ))
        end
    elseif command == "reset" then
        self:ResetPosition()
        self:Print(zh and "设置已重置。" or "Settings reset.")
    else
        self:Print(zh and
            "/ddps show|hide|lock|unlock|mode single|aoe|pvp_close|cast [single|aoe|pvp_close]|tank set|clear|status|macros|config|scale 1.0|combat|test|debug|status|reset" or
            "/ddps show|hide|lock|unlock|mode single|aoe|pvp_close|cast [single|aoe|pvp_close]|tank set|clear|status|macros|config|scale 1.0|combat|test|debug|status|reset")
    end
end

SLASH_DOITEDPS1 = "/ddps"
SLASH_DOITEDPS2 = "/doitedps"
SlashCmdList["DOITEDPS"] = function(message)
    D:HandleSlash(message)
end

SLASH_ELEDPS1 = "/eledps"
SlashCmdList["ELEDPS"] = function(message)
    message = message or ""
    if message == "debug" then
        D:HandleSlash("debug")
    elseif message == "" then
        D:Execute("single")
    else
        D:Execute(message)
    end
end

function DoiteDPS_Execute(entry)
    return D:Execute(entry)
end

function DoiteDPS_SetMode(entry)
    return D:SetModeByEntry(entry, true)
end

function EleDPS_CastSpell()
    return D:Execute("single")
end

function EleDPS_CastAoE()
    return D:Execute("aoe")
end

function EleDPS_GetClearcastingRank()
    local tracker = D.Trackers and D.Trackers.ShamanElemental
    return tracker and tracker:GetClearcastingRank() or 0
end

function EleDPS_FlameShockRemaining()
    local tracker = D.Trackers and D.Trackers.ShamanElemental
    if not tracker then return 0 end
    local remaining = tracker:GetFlameShockState()
    return remaining or 0
end

function D:DispatchProfileEvent(
    eventName,
    a1,
    a2,
    a3,
    a4,
    a5,
    a6,
    a7,
    a8,
    a9
)
    if eventName == "SPELL_GO_SELF" and (tonumber(a1) or 0) == 0 then
        self:ResolveOnSwingQueued(a2)
    end
    local profile = self:GetActiveProfile()
    if profile and profile.OnEvent then
        profile:OnEvent(eventName, a1, a2, a3, a4, a5, a6, a7, a8, a9)
    end
end

-- 事件负责即时刷新；下方限频的 OnUpdate 只补偿连续计时器，以及不会主动发出
-- 事件的 provider 状态。
D.EventFrame = D.EventFrame or CreateFrame("Frame", "DoiteDPSEventFrame")
local eventFrame = D.EventFrame

eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
eventFrame:RegisterEvent("PLAYER_CONTROL_LOST")
eventFrame:RegisterEvent("PLAYER_CONTROL_GAINED")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
eventFrame:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
eventFrame:RegisterEvent("UNIT_RAGE")
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:RegisterEvent("UNIT_ATTACK_SPEED")
eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
eventFrame:RegisterEvent("AUTO_ATTACK_SELF")
eventFrame:RegisterEvent("AUTO_ATTACK_OTHER")
eventFrame:RegisterEvent("START_AUTOATTACK")
eventFrame:RegisterEvent("STOP_AUTOATTACK")
eventFrame:RegisterEvent("SPELL_CAST_EVENT")
eventFrame:RegisterEvent("SPELL_GO")
eventFrame:RegisterEvent("SPELL_GO_SELF")
eventFrame:RegisterEvent("SPELLCAST_START")
eventFrame:RegisterEvent("SPELLCAST_STOP")
eventFrame:RegisterEvent("SPELLCAST_FAILED")
eventFrame:RegisterEvent("SPELLCAST_INTERRUPTED")
eventFrame:RegisterEvent("AURA_CAST_ON_OTHER")
eventFrame:RegisterEvent("SPELL_DAMAGE_EVENT_SELF")
eventFrame:RegisterEvent("SPELL_MISS_SELF")
eventFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
eventFrame:RegisterEvent("CHAT_MSG_SPELL_FAILED_LOCALPLAYER")
eventFrame:RegisterEvent("CHAT_MSG_SPELL_FAILURE")

eventFrame:SetScript("OnEvent", function()
    D:DispatchProfileEvent(
        event,
        arg1,
        arg2,
        arg3,
        arg4,
        arg5,
        arg6,
        arg7,
        arg8,
        arg9
    )

    if event == "VARIABLES_LOADED" then
        D:InitializeDB()
        D:MigrateSuperMacroOutputOrder()
        if EleDPS_DB then
            D:ImportEleDPSDB(EleDPS_DB)
        end
        if D.UI and D.UI.ApplySettings then
            D.UI:ApplySettings()
        end
        if D.Config and D.Config.Sync then
            D.Config:Sync()
        end
    elseif event == "ADDON_LOADED" then
        if arg1 == "EleDPS" and EleDPS_DB then
            D:ImportEleDPSDB(EleDPS_DB)
            if D.Config and D.Config.Sync then D.Config:Sync() end
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if not D.DB then
            D:InitializeDB()
        end
        D:ResetCharacterRuntime()
        D:MigrateSuperMacroOutputOrder()
        D:RefreshSpellCache()
        D.inCombat = UnitAffectingCombat and UnitAffectingCombat("player") and true or false
        D.initialized = true
        if EleDPS_DB then
            D:ImportEleDPSDB(EleDPS_DB)
        end
        if D.UI and D.UI.ApplySettings then
            D.UI:ApplySettings()
        end
        D:Update(true)
        D:Print((zh and "已加载 v" or "Loaded v") .. D.VERSION ..
            (zh and "。输入 /ddps unlock 可拖动。" or ". Type /ddps unlock to move."))
    elseif event == "PLAYER_LOGIN" then
        D:Update(true)
    elseif event == "SPELLS_CHANGED" then
        D:RefreshSpellCache()
        D:Update(true)
    elseif event == "PLAYER_REGEN_DISABLED" then
        D.inCombat = true
        D:Update(true)
    elseif event == "PLAYER_REGEN_ENABLED" then
        D.inCombat = false
        D:Update(true)
    elseif event == "PARTY_MEMBERS_CHANGED"
        or event == "RAID_ROSTER_UPDATE" then
        D:InvalidateTankAssistRoster()
        if D.Config and D.Config.UpdateTankAssistStatus then
            D.Config:UpdateTankAssistStatus()
        end
        D:Update(true)
    elseif event == "UNIT_RAGE" or event == "UNIT_HEALTH" or event == "UNIT_AURA" then
        if arg1 == "player" or arg1 == "target" then
            D:Update(true)
        end
    else
        D:Update(true)
    end
end)

D._elapsed = 0
eventFrame:SetScript("OnUpdate", function()
    if not D.initialized then
        return
    end

    D._elapsed = D._elapsed + (arg1 or 0)
    local interval = (D.inCombat or D:IsHostileTarget())
        and D.UPDATE_IN_COMBAT or D.UPDATE_OUT_OF_COMBAT

    if D._elapsed >= interval then
        D._elapsed = 0
        D:Update(false)
    end
end)
