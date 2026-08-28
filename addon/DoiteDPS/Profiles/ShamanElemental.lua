-- ============================================================================
-- DoiteDPS - Shaman damage profile
-- Recommendation logic is side-effect free; Execute() is called only by a
-- player key press and preserves EleDPS one-button behavior.
-- ============================================================================

local D = DoiteDPS
local T = D.Trackers.ShamanElemental
local P = {}
D.Profiles.ShamanElemental = P

P.key = "SHAMAN_ELEMENTAL"
P.CooldownKeys = D.ShamanCooldownKeys
-- 复用动作／预测记录，并保留一个候选暂存表。只有客户端缺少 HasFullControl()
-- 时，controlLost 才作为事件驱动的回退状态使用。
P._rec = {}
P._forecast = {}
P._candidates = {}
P.controlLost = false
local FORECAST_LIMIT = D.FORECAST_LIMIT or 3

local locale = (GetLocale and GetLocale()) or "enUS"
local zh = locale == "zhCN" or locale == "zhTW"

local HORDE_INSIGNIA_IDS = {
    [18834] = true,
    [18845] = true,
    [18846] = true,
    [18849] = true,
    [18850] = true,
    [18851] = true,
    [18852] = true,
    [18853] = true,
}
local TRINKET_SLOTS = { 13, 14 }
local MODE_ELEMENTAL_PVP_CLOSE = "elemental_pvp_close"
local MODE_ENHANCE_MELEE = "enhance_pvp_melee"
local MODE_ENHANCE_RANGED = "enhance_pvp_ranged"
local SEARING_TOTEM_MAX_DISTANCE = 25
local AOE_TOTEM_MAX_DISTANCE = 8
local ENHANCE_MELEE_CORE_ORDER = {
    "STORMSTRIKE",
    "LIGHTNING_STRIKE",
}
local ENHANCE_SHOCK_KEYS = {
    earth = "EARTH_SHOCK",
    frost = "FROST_SHOCK",
    flame = "FLAME_SHOCK",
}

P.ModeOrder = {
    "single",
    "aoe",
    MODE_ELEMENTAL_PVP_CLOSE,
    MODE_ENHANCE_MELEE,
    MODE_ENHANCE_RANGED,
}
P.ModeLabels = {
    single = zh and "元素单体" or "Elemental Single",
    aoe = zh and "元素AOE" or "Elemental AoE",
    [MODE_ELEMENTAL_PVP_CLOSE] = zh and "电萨PvP近战" or
        "Elemental PvP Close",
    [MODE_ENHANCE_MELEE] = zh and "增强PvP近战" or "Enhancement PvP Melee",
    [MODE_ENHANCE_RANGED] = zh and "增强PvP远程" or "Enhancement PvP Ranged",
}
P.EntryOrder = { "single", "aoe", "pvp_close" }
P.EntryPoints = {
    single = {
        label = zh and "单体出口" or "Single output",
        modes = { "single", MODE_ENHANCE_MELEE },
        default = "single",
    },
    aoe = {
        label = zh and "AOE出口" or "AoE output",
        modes = { "aoe", MODE_ENHANCE_RANGED },
        default = "aoe",
    },
    pvp_close = {
        label = zh and "电萨近战出口" or "Elemental close output",
        modes = { MODE_ELEMENTAL_PVP_CLOSE },
        default = MODE_ELEMENTAL_PVP_CLOSE,
    },
}
local OUTPUT_MODE_VALUES = {
    {
        value = "conserve",
        label = zh and "节能模式" or "Conserve mode",
    },
    {
        value = "burst",
        label = zh and "爆发模式" or "Burst mode",
    },
}
P.ConfigSchema = {
    title = zh and "萨满输出" or "Shaman Damage",
    modeGroups = {
        {
            key = "single",
            modes = {
                "single",
                MODE_ELEMENTAL_PVP_CLOSE,
                MODE_ENHANCE_MELEE,
            },
        },
        {
            key = "aoe",
            modes = {
                "aoe",
                MODE_ENHANCE_RANGED,
            },
        },
    },
    modes = {
        {
            key = "single",
            label = P.ModeLabels.single,
            note = zh and "无目标自动选敌；节能模式维护持续伤害，爆发模式直接输出；勾选的灼热图腾仅在目标25码内参与循环。"
                or "Auto-targets when needed; conserve mode maintains damage over time, burst mode deals direct damage, and selected Searing Totem participates only within 25 yards.",
        },
        {
            key = "aoe",
            label = P.ModeLabels.aoe,
            note = zh and "无目标自动选敌；节能模式等待节能施法，爆发模式直接输出；勾选的新星／熔岩图腾仅在目标8码内参与循环。"
                or "Auto-targets when needed; conserve mode waits for Clearcasting, burst mode deals direct damage, and selected Fire Nova/Magma Totems participate only within 8 yards.",
        },
        {
            key = MODE_ELEMENTAL_PVP_CLOSE,
            label = P.ModeLabels[MODE_ELEMENTAL_PVP_CLOSE],
            note = zh and "徽记优先解控；元素掌握 > 战争践踏 > 闪电链 > 大地震击 > 闪电箭；移动时大地震击前置，图腾手动。"
                or "Insignia first; Elemental Mastery > War Stomp > Chain Lightning > Earth Shock > Lightning Bolt; Earth Shock moves up while moving and totems remain manual.",
        },
        {
            key = MODE_ENHANCE_MELEE,
            label = P.ModeLabels[MODE_ENHANCE_MELEE],
            note = zh and "优先级：风暴打击 > 闪电打击 > 自选震击；可关闭自动震击，图腾手动。"
                or "Priority: Stormstrike > Lightning Strike > selected shock; automatic shocks may be disabled and totems remain manual.",
        },
        {
            key = MODE_ENHANCE_RANGED,
            label = P.ModeLabels[MODE_ENHANCE_RANGED],
            note = zh and "固定优先级：闪电链 > 闪电箭；图腾手动。"
                or "Fixed priority: Chain Lightning > Lightning Bolt; totems remain manual.",
        },
    },
    options = {
        {
            type = "choice",
            section = zh and "增强PvP近战循环" or
                "Enhancement PvP melee rotation",
            scope = "profile",
            key = "enhancePvPShock",
            label = zh and "自动震击" or "Automatic shock",
            modes = { MODE_ENHANCE_MELEE },
            values = {
                { value = "earth", label = zh and "大地震击" or "Earth Shock" },
                { value = "frost", label = zh and "冰霜震击" or "Frost Shock" },
                { value = "flame", label = zh and "烈焰震击" or "Flame Shock" },
                { value = "off", label = zh and "不自动震击" or "None" },
            },
        },
        {
            type = "choice",
            section = zh and "输出模式" or "Output mode",
            scope = "profile",
            key = "singleOutputMode",
            label = zh and "模式" or "Mode",
            modes = { "single" },
            values = OUTPUT_MODE_VALUES,
        },
        {
            type = "choice",
            section = zh and "输出模式" or "Output mode",
            scope = "profile",
            key = "aoeOutputMode",
            label = zh and "模式" or "Mode",
            modes = { "aoe" },
            values = OUTPUT_MODE_VALUES,
        },
        {
            type = "toggle",
            section = zh and "单体循环技能" or "Single-target skills",
            scope = "profile",
            key = "enableFSLB",
            label = zh and "烈焰震击 + 熔岩爆裂" or "Flame Shock + Lava Burst",
            modes = { "single" },
        },
        {
            type = "toggle",
            section = zh and "群体循环技能" or "Group rotation skills",
            scope = "profile",
            key = "enableQuakeAoE",
            label = zh and "地震术" or "Earthquake",
            modes = { "aoe" },
        },
        {
            type = "toggle",
            scope = "profile",
            key = "enableCL",
            label = zh and "闪电链" or "Chain Lightning",
            modes = { "single" },
        },
        {
            type = "toggle",
            scope = "profile",
            key = "enableCLAoE",
            label = zh and "闪电链" or "Chain Lightning",
            modes = { "aoe" },
        },
        {
            type = "toggle",
            section = zh and "伤害图腾" or "Damage totems",
            scope = "profile",
            key = "enableSearingTotem",
            label = zh and "灼热图腾" or "Searing Totem",
            modes = { "single" },
        },
        {
            type = "toggle",
            section = zh and "伤害图腾" or "Damage totems",
            scope = "profile",
            key = "enableFireNovaTotem",
            label = zh and "火焰新星图腾" or "Fire Nova Totem",
            modes = { "aoe" },
        },
        {
            type = "toggle",
            scope = "profile",
            key = "enableMagmaTotem",
            label = zh and "熔岩图腾" or "Magma Totem",
            modes = { "aoe" },
        },
        {
            type = "toggle",
            section = zh and "移动施法" or "Movement",
            scope = "profile",
            key = "enableESMoving",
            label = zh and "移动时：大地震击" or "While moving: Earth Shock",
            modes = { "single", "aoe" },
        },
    },
}

function P:NormalizeMode(mode)
    if mode == "aoe" or mode == MODE_ELEMENTAL_PVP_CLOSE
        or mode == MODE_ENHANCE_MELEE
        or mode == MODE_ENHANCE_RANGED then
        return mode
    end
    return "single"
end

function P:GetModeLabel(mode)
    return self.ModeLabels[self:NormalizeMode(mode)]
end

local REASON = {
    NO_TARGET = zh and "选择敌对目标" or "Select a hostile target",
    OUT_OF_RANGE = zh and "目标超出施法距离" or "Target is out of range",
    MOVING = zh and "移动中使用瞬发震击" or "Use an instant shock while moving",
    FLAME_SHOCK = zh and "补充烈焰震击" or "Apply Flame Shock",
    FLAME_SHOCK_URGENT = zh and "烈焰震击不足以覆盖下一次熔岩爆裂" or
        "Refresh Flame Shock before Lava Burst",
    LAVA_BURST = zh and "烈焰震击即将进入熔岩爆裂刷新窗口" or
        "Lava Burst refresh window",
    CLEARCASTING = zh and "用闪电链消耗节能施法" or
        "Spend Clearcasting on Chain Lightning",
    CLEARCASTING_AOE = zh and "用地震术消耗节能施法" or
        "Spend Clearcasting on Earthquake",
    BURST = zh and "爆发模式：按技能优先级输出" or
        "Burst mode: use direct damage priority",
    PVP_TRINKET = zh and "优先使用部落徽记解控" or
        "Use Insignia of the Horde to break control",
    ELEMENTAL_PVP_CLOSE = zh and "电萨PvP近战：按固定优先级输出" or
        "Elemental PvP close: use fixed skill priority",
    ELEMENTAL_PVP_WAIT = zh and "电萨PvP近战：等待技能冷却" or
        "Elemental PvP close: waiting for skill cooldowns",
    ENHANCE_PVP_MELEE = zh and "增强PvP近战：按技能优先级输出" or
        "Enhancement PvP melee: use fixed skill priority",
    ENHANCE_PVP_RANGED = zh and "增强PvP远程：按技能优先级输出" or
        "Enhancement PvP ranged: use fixed skill priority",
    ENHANCE_PVP_WAIT = zh and "增强PvP：等待技能冷却" or
        "Enhancement PvP: waiting for skill cooldowns",
    SEARING_TOTEM = zh and "切换或维持灼热图腾" or
        "Switch to or maintain Searing Totem",
    FIRE_NOVA_TOTEM = zh and "放置火焰新星图腾" or
        "Place Fire Nova Totem",
    MAGMA_TOTEM = zh and "放置或维持熔岩图腾" or
        "Place or maintain Magma Totem",
    LIGHTNING_BOLT = zh and "常规填充" or "Filler",
    QUEUE = zh and "为当前读条预先排队" or "Queue after the current cast",
    FORECAST = zh and "预计后续技能" or "Expected follow-up",
}

local BASE_CAST = {
    HORDE_INSIGNIA = 0,
    ELEMENTAL_MASTERY = 0,
    WAR_STOMP = 0.5,
    LIGHTNING_STRIKE = 1.5,
    STORMSTRIKE = 1.5,
    LIGHTNING_BOLT = 2.5,
    CHAIN_LIGHTNING = 2.0,
    LAVA_BURST = 2.0,
    EARTHQUAKE = 3.0,
    SEARING_TOTEM = 1.5,
    FIRE_NOVA_TOTEM = 1.5,
    MAGMA_TOTEM = 1.5,
}

local PRIORITY = {
    STORMSTRIKE = 1,
    LIGHTNING_STRIKE = 2,
    FLAME_SHOCK = 1,
    LAVA_BURST = 2,
    EARTH_SHOCK = 3,
    FROST_SHOCK = 3,
    EARTHQUAKE = 4,
    CHAIN_LIGHTNING = 5,
    FIRE_NOVA_TOTEM = 6,
    MAGMA_TOTEM = 7,
    SEARING_TOTEM = 8,
    LIGHTNING_BOLT = 9,
}

local function Max(a, b)
    a = tonumber(a) or 0
    b = tonumber(b) or 0
    if a > b then return a end
    return b
end

local function SetAction(action, key, reason, actionState, eta, uncertain)
    action.key = key
    action.name = D:GetName(key)
    action.texture = D:GetTexture(key)
    action.reason = reason or ""
    action.state = actionState or "ready"
    action.eta = eta
    action.uncertain = uncertain and true or false
    action.inventorySlot = nil
    return action
end

local function CooldownRemaining(state, key)
    local entry = state.cooldowns and state.cooldowns[key]
    if entry and entry.remaining then
        return entry.remaining
    end
    local remaining = D:GetNonGCDCooldown(key, state.now)
    return tonumber(remaining) or 0
end

local function Ready(state, key)
    return D:IsKnown(key) and CooldownRemaining(state, key) <= 0.05
end

-- 本函数不会延迟或排队施法；它只在当前读条或 GCD 尚未结束时，标记推荐动作
-- 何时能够执行。
local function ApplyCastDelay(action, state)
    if state.casting and (state.castRemaining or 0) > 0.05 then
        action.state = "queue"
        action.eta = state.castRemaining
    elseif state.gcd and state.gcd > 0.05 then
        action.state = "gcd"
        action.eta = state.gcd
    end
    return action
end

local function Enabled(db, key)
    return db and db[key] ~= false and db[key] ~= 0
end

local function DamageTotemTargetInRange(state)
    local distance = tonumber(state and state.targetDistance)
    if not distance or distance < 0 then return false end
    if state.mode == "single" then
        return distance <= SEARING_TOTEM_MAX_DISTANCE
    elseif state.mode == "aoe" then
        return distance <= AOE_TOTEM_MAX_DISTANCE
    end
    return false
end

-- Missing or unknown values preserve the pre-0.8.14 Earth Shock behavior.
-- "off" is intentionally the only value that removes shocks completely.
local function EnhancementShockKey(db)
    local choice = db and db.enhancePvPShock
    if choice == "off" then return nil end
    return ENHANCE_SHOCK_KEYS[choice] or "EARTH_SHOCK"
end

local function BurstModeEnabled(db, mode)
    if not db then return false end
    local outputMode
    if mode == "aoe" then
        outputMode = db.aoeOutputMode
    else
        outputMode = db.singleOutputMode
    end
    if outputMode ~= "conserve" and outputMode ~= "burst" then
        outputMode = db.outputMode
    end
    if outputMode ~= nil then
        return outputMode == "burst"
    end
    return db.enablePvPBurst == true or db.enablePvPBurst == 1
end

local function EnhancementPvPMode(mode)
    return mode == MODE_ENHANCE_MELEE or mode == MODE_ENHANCE_RANGED
end

local function InsigniaModeEnabled(state, db)
    return (state and state.mode) == MODE_ELEMENTAL_PVP_CLOSE
        or EnhancementPvPMode(state and state.mode)
        or BurstModeEnabled(db, state and state.mode)
end

-- Elemental burst preserves the former PvP toggle's insignia behavior, while
-- every explicit PvP mode always enters this contract. Keeping the
-- check ahead of target, range, GCD and damage lets an equipped insignia break
-- control even when no target exists.
function P:RecommendPvPInsignia(state, db, action)
    if not state or not InsigniaModeEnabled(state, db)
        or not state.controlLost then
        return nil
    end

    local slot = tonumber(state.hordeInsigniaSlot)
    if slot ~= 13 and slot ~= 14 then
        return nil
    end

    action = action or self._rec
    SetAction(
        action,
        "HORDE_INSIGNIA",
        REASON.PVP_TRINKET,
        "ready",
        nil,
        false
    )
    action.inventorySlot = slot
    return action
end

local function ChooseDamageTotem(state, db)
    if state.fireTotemStateAvailable ~= true then
        return nil
    end
    if not DamageTotemTargetInRange(state) then
        return nil
    end

    local kind = state.fireTotemKind
    if kind == "utility" or kind == "nova" then
        -- Utility fire totems are player-owned choices. Fire Nova owns the
        -- slot until its talent-adjusted activation has actually completed.
        return nil
    end

    if state.mode == "single" then
        if Enabled(db, "enableSearingTotem")
            and kind ~= "searing"
            and Ready(state, "SEARING_TOTEM") then
            return "SEARING_TOTEM", REASON.SEARING_TOTEM
        end
        return nil
    end

    if kind == "magma" then
        -- Let Magma finish its full 20 seconds even when Fire Nova's cooldown
        -- becomes ready earlier.
        return nil
    end
    if Enabled(db, "enableFireNovaTotem")
        and Ready(state, "FIRE_NOVA_TOTEM") then
        return "FIRE_NOVA_TOTEM", REASON.FIRE_NOVA_TOTEM
    end
    if Enabled(db, "enableMagmaTotem")
        and Ready(state, "MAGMA_TOTEM") then
        return "MAGMA_TOTEM", REASON.MAGMA_TOTEM
    end
    return nil
end

local function GetEquippedItemId(slot)
    if type(GetInventoryItemLink) ~= "function" then return nil end
    local link = GetInventoryItemLink("player", slot)
    if not link then return nil end
    local _, _, itemId = string.find(link, "item:(%d+)")
    return tonumber(itemId)
end

function P:IsControlLost()
    if type(UnitOnTaxi) == "function" and UnitOnTaxi("player") then
        return false
    end
    if type(UnitIsDeadOrGhost) == "function"
        and UnitIsDeadOrGhost("player") then
        return false
    end

    if type(HasFullControl) == "function" then
        local ok, hasControl = pcall(HasFullControl)
        if ok then
            return not (hasControl == true or hasControl == 1)
        end
    end
    return self.controlLost and true or false
end

function P:GetReadyHordeInsigniaSlot(now)
    if type(GetInventoryItemCooldown) ~= "function" then return nil end
    now = tonumber(now) or ((GetTime and GetTime()) or 0)

    local index = 1
    while index <= table.getn(TRINKET_SLOTS) do
        local slot = TRINKET_SLOTS[index]
        local itemId = GetEquippedItemId(slot)
        local locked = type(IsInventoryItemLocked) == "function"
            and IsInventoryItemLocked(slot)
        if itemId and HORDE_INSIGNIA_IDS[itemId] and not locked then
            local start, duration, enable =
                GetInventoryItemCooldown("player", slot)
            start = tonumber(start) or 0
            duration = tonumber(duration) or 0
            if enable ~= 0
                and (start <= 0 or duration <= 0
                    or start + duration <= now + 0.05) then
                return slot
            end
        end
        index = index + 1
    end
    return nil
end

-- Recommendation and forecast must use exactly the same participation rules.
-- A disabled option means that neither the one-button executor nor the future
-- timeline may surface the associated spell.
local function Participates(db, mode, key)
    if mode == MODE_ELEMENTAL_PVP_CLOSE then
        return key == "ELEMENTAL_MASTERY"
            or key == "WAR_STOMP"
            or key == "CHAIN_LIGHTNING"
            or key == "EARTH_SHOCK"
            or key == "LIGHTNING_BOLT"
    elseif mode == MODE_ENHANCE_MELEE then
        return key == "LIGHTNING_STRIKE"
            or key == "STORMSTRIKE"
            or key == EnhancementShockKey(db)
    elseif mode == MODE_ENHANCE_RANGED then
        return key == "CHAIN_LIGHTNING" or key == "LIGHTNING_BOLT"
    end

    if key == "FLAME_SHOCK" or key == "LAVA_BURST" then
        return mode == "single" and Enabled(db, "enableFSLB")
    elseif key == "CHAIN_LIGHTNING" then
        if mode == "aoe" then
            return Enabled(db, "enableCLAoE")
        end
        return Enabled(db, "enableCL")
    elseif key == "EARTHQUAKE" then
        return mode == "aoe" and Enabled(db, "enableQuakeAoE")
    elseif key == "EARTH_SHOCK" then
        return Enabled(db, "enableESMoving")
    elseif key == "SEARING_TOTEM" then
        return mode == "single" and Enabled(db, "enableSearingTotem")
    elseif key == "FIRE_NOVA_TOTEM" then
        return mode == "aoe" and Enabled(db, "enableFireNovaTotem")
    elseif key == "MAGMA_TOTEM" then
        return mode == "aoe" and Enabled(db, "enableMagmaTotem")
    end
    return true
end

-- Tracker 先补充法力、施法、烈焰震击、节能施法和图腾字段；本 Profile 再补充
-- 当前模式专属的失控与近距离观测。
function P:BuildState(state)
    T:BuildState(state)
    local db = state.profileDB or D:GetProfileDB(self.key)
    state.controlLost = InsigniaModeEnabled(state, db)
        and self:IsControlLost() or false
    state.hordeInsigniaSlot = state.controlLost
        and self:GetReadyHordeInsigniaSlot(state.now) or nil

    if state.mode == MODE_ELEMENTAL_PVP_CLOSE then
        local distance = tonumber(state.targetDistance)
        if distance then
            state.closeInRange = state.targetValid and distance <= 8 or false
        else
            -- The dedicated entry itself is the player's close-range intent.
            -- If exact distance is unavailable, only an explicit melee-range
            -- failure blocks War Stomp; ranged damage may still continue.
            local meleeRange = D:IsMeleeRange("target")
            state.closeInRange = state.targetValid
                and meleeRange ~= false or false
        end
    elseif state.mode == MODE_ENHANCE_MELEE then
        local meleeRange = D:IsMeleeRange("target", "LIGHTNING_STRIKE")
        state.meleeInRange = state.targetValid
            and meleeRange ~= false or false
    end
end

function P:OnEvent(eventName, a1, a2, a3, a4, a5, a6, a7, a8, a9)
    if eventName == "PLAYER_CONTROL_LOST" then
        self.controlLost = true
    elseif eventName == "PLAYER_CONTROL_GAINED"
        or eventName == "PLAYER_LOGIN"
        or eventName == "PLAYER_ENTERING_WORLD" then
        self.controlLost = false
    end
    T:OnEvent(eventName, a1, a2, a3, a4, a5, a6, a7, a8, a9)
end

function P:ResetRuntime()
    self.controlLost = false
end

-- 各模式拥有不同优先级，但共享同一外层顺序：
-- 解控 → 校验目标 → 明确的 PvP 优先级 → PvE 距离与移动瞬发 →
-- 爆发优先级或节能维护 → 图腾 → 填充技能。
function P:Recommend(state)
    local action = self._rec
    local db = state.profileDB or D:GetProfileDB(self.key)

    local insigniaAction = self:RecommendPvPInsignia(state, db, action)
    if insigniaAction then
        return insigniaAction
    end

    if D.testMode then
        local keys
        if state.mode == MODE_ELEMENTAL_PVP_CLOSE then
            keys = {
                "ELEMENTAL_MASTERY",
                "WAR_STOMP",
                "CHAIN_LIGHTNING",
                "EARTH_SHOCK",
                "LIGHTNING_BOLT",
            }
        elseif state.mode == MODE_ENHANCE_MELEE then
            keys = {
                ENHANCE_MELEE_CORE_ORDER[1],
                ENHANCE_MELEE_CORE_ORDER[2],
            }
            local testShockKey = EnhancementShockKey(db)
            if testShockKey then
                keys[3] = testShockKey
            end
        elseif state.mode == MODE_ENHANCE_RANGED then
            keys = { "CHAIN_LIGHTNING", "LIGHTNING_BOLT" }
        else
            keys = {
                "LIGHTNING_BOLT",
                "CHAIN_LIGHTNING",
                "FLAME_SHOCK",
                "LAVA_BURST",
                "EARTHQUAKE",
            }
        end
        local count = table.getn(keys)
        local value = math.floor(GetTime() / 1.5)
        local index = value - (math.floor(value / count) * count) + 1
        return SetAction(
            action,
            keys[index],
            zh and "测试模式：元素萨满图标轮换" or
                "Test mode: cycling Elemental actions",
            "ready",
            nil,
            false
        )
    end

    if not state.targetValid then
        return SetAction(action, "WAIT", REASON.NO_TARGET, "disabled", nil, false)
    end

    if state.mode == MODE_ELEMENTAL_PVP_CLOSE then
        if state.inRange
            and state.castName ~= D.Names.ELEMENTAL_MASTERY
            and Ready(state, "ELEMENTAL_MASTERY") then
            SetAction(
                action,
                "ELEMENTAL_MASTERY",
                REASON.ELEMENTAL_PVP_CLOSE,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        -- The dedicated PvP entry ignores the configurable PvE switch: while
        -- moving, use its instant Earth Shock before War Stomp and cast-time
        -- lightning spells so the key press still delivers damage.
        if state.moving and state.inRange
            and Ready(state, "EARTH_SHOCK") then
            SetAction(
                action,
                "EARTH_SHOCK",
                REASON.MOVING,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        if state.closeInRange == true
            and state.castName ~= D.Names.WAR_STOMP
            and Ready(state, "WAR_STOMP") then
            SetAction(
                action,
                "WAR_STOMP",
                REASON.ELEMENTAL_PVP_CLOSE,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        if not state.inRange then
            return SetAction(
                action,
                "WAIT",
                REASON.OUT_OF_RANGE,
                "range",
                nil,
                false
            )
        end

        if state.castName ~= D.Names.CHAIN_LIGHTNING
            and Ready(state, "CHAIN_LIGHTNING") then
            SetAction(
                action,
                "CHAIN_LIGHTNING",
                REASON.ELEMENTAL_PVP_CLOSE,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        if Ready(state, "EARTH_SHOCK") then
            SetAction(
                action,
                "EARTH_SHOCK",
                REASON.ELEMENTAL_PVP_CLOSE,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        if D:IsKnown("LIGHTNING_BOLT") then
            SetAction(
                action,
                "LIGHTNING_BOLT",
                REASON.ELEMENTAL_PVP_CLOSE,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        return SetAction(
            action,
            "WAIT",
            REASON.ELEMENTAL_PVP_WAIT,
            "cooldown",
            nil,
            false
        )
    end

    if state.mode == MODE_ENHANCE_MELEE then
        if state.meleeInRange == false then
            return SetAction(
                action,
                "WAIT",
                REASON.OUT_OF_RANGE,
                "range",
                nil,
                false
            )
        end

        local meleeIndex = 1
        while meleeIndex <= table.getn(ENHANCE_MELEE_CORE_ORDER) do
            local key = ENHANCE_MELEE_CORE_ORDER[meleeIndex]
            if Ready(state, key) then
                SetAction(
                    action,
                    key,
                    REASON.ENHANCE_PVP_MELEE,
                    "ready",
                    nil,
                    false
                )
                return ApplyCastDelay(action, state)
            end
            meleeIndex = meleeIndex + 1
        end

        local shockKey = EnhancementShockKey(db)
        if shockKey and Ready(state, shockKey) then
            SetAction(
                action,
                shockKey,
                REASON.ENHANCE_PVP_MELEE,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        return SetAction(
            action,
            "WAIT",
            REASON.ENHANCE_PVP_WAIT,
            "cooldown",
            nil,
            false
        )
    end

    if state.mode == MODE_ENHANCE_RANGED then
        if not state.inRange then
            return SetAction(
                action,
                "WAIT",
                REASON.OUT_OF_RANGE,
                "range",
                nil,
                false
            )
        end

        if state.castName ~= D.Names.CHAIN_LIGHTNING
            and Ready(state, "CHAIN_LIGHTNING") then
            SetAction(
                action,
                "CHAIN_LIGHTNING",
                REASON.ENHANCE_PVP_RANGED,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        if D:IsKnown("LIGHTNING_BOLT") then
            SetAction(
                action,
                "LIGHTNING_BOLT",
                REASON.ENHANCE_PVP_RANGED,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        return SetAction(
            action,
            "WAIT",
            REASON.ENHANCE_PVP_WAIT,
            "cooldown",
            nil,
            false
        )
    end

    if not state.inRange then
        return SetAction(
            action,
            "WAIT",
            REASON.OUT_OF_RANGE,
            "range",
            nil,
            false
        )
    end

    -- Moving Earth Shock is a shared single/AoE participation rule. Keep it
    -- ahead of the output-mode split so burst mode cannot strand the player
    -- on cast-time spells while this instant filler is enabled and ready.
    if state.moving and Participates(db, state.mode, "EARTH_SHOCK")
        and Ready(state, "EARTH_SHOCK") then
        SetAction(action, "EARTH_SHOCK", REASON.MOVING, "ready", nil, false)
        return ApplyCastDelay(action, state)
    end

    -- Burst mode deliberately ignores Clearcasting and cast-time
    -- setup/maintenance branches. Existing spell participation toggles still
    -- decide whether a listed spell may be recommended or executed.
    if BurstModeEnabled(db, state.mode) then
        if state.mode == "aoe"
            and Participates(db, state.mode, "EARTHQUAKE")
            and state.castName ~= D.Names.EARTHQUAKE
            and Ready(state, "EARTHQUAKE") then
            SetAction(
                action,
                "EARTHQUAKE",
                REASON.BURST,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        if Participates(db, state.mode, "CHAIN_LIGHTNING")
            and state.castName ~= D.Names.CHAIN_LIGHTNING
            and Ready(state, "CHAIN_LIGHTNING") then
            SetAction(
                action,
                "CHAIN_LIGHTNING",
                REASON.BURST,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        local burstTotemKey, burstTotemReason = ChooseDamageTotem(state, db)
        if burstTotemKey then
            SetAction(
                action,
                burstTotemKey,
                burstTotemReason,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        if D:IsKnown("LIGHTNING_BOLT") then
            SetAction(
                action,
                "LIGHTNING_BOLT",
                REASON.BURST,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        return SetAction(
            action,
            "WAIT",
            REASON.NO_TARGET,
            "disabled",
            nil,
            false
        )
    end

    if Participates(db, state.mode, "FLAME_SHOCK")
        and state.castName ~= D.Names.LAVA_BURST
        and not state.lavaBurstFlying then
        local fsRemaining = tonumber(state.flameShockRemaining) or 0
        local predictedFS = T:PredictFlameShockRemaining(fsRemaining, state)
        local lavaMinimum = 2.0 + (tonumber(state.lavaBurstTravel) or 1.5)
        local lavaWindowMaximum = lavaMinimum + 2.5

        if fsRemaining <= 0 and Ready(state, "FLAME_SHOCK") then
            SetAction(
                action,
                "FLAME_SHOCK",
                REASON.FLAME_SHOCK,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        if predictedFS > lavaMinimum
            and predictedFS <= lavaWindowMaximum
            and Ready(state, "LAVA_BURST") then
            SetAction(
                action,
                "LAVA_BURST",
                REASON.LAVA_BURST,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        if predictedFS > 0 and predictedFS <= lavaMinimum
            and Ready(state, "FLAME_SHOCK") then
            SetAction(
                action,
                "FLAME_SHOCK",
                REASON.FLAME_SHOCK_URGENT,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end
    end

    local clearcasting = tonumber(state.clearcasting) or 0
    if state.casting and clearcasting > 0 then
        clearcasting = clearcasting - 1
    end

    if state.mode == "aoe" and clearcasting > 0 then
        if Participates(db, state.mode, "EARTHQUAKE")
            and state.castName ~= D.Names.EARTHQUAKE
            and Ready(state, "EARTHQUAKE") then
            SetAction(
                action,
                "EARTHQUAKE",
                REASON.CLEARCASTING_AOE,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end

        if Participates(db, state.mode, "CHAIN_LIGHTNING")
            and state.castName ~= D.Names.CHAIN_LIGHTNING
            and Ready(state, "CHAIN_LIGHTNING") then
            SetAction(
                action,
                "CHAIN_LIGHTNING",
                REASON.CLEARCASTING,
                "ready",
                nil,
                false
            )
            return ApplyCastDelay(action, state)
        end
    elseif state.mode == "single" and clearcasting > 0
        and Participates(db, state.mode, "CHAIN_LIGHTNING")
        and state.castName ~= D.Names.CHAIN_LIGHTNING
        and Ready(state, "CHAIN_LIGHTNING") then
        SetAction(
            action,
            "CHAIN_LIGHTNING",
            REASON.CLEARCASTING,
            "ready",
            nil,
            false
        )
        return ApplyCastDelay(action, state)
    end

    local totemKey, totemReason = ChooseDamageTotem(state, db)
    if totemKey then
        SetAction(action, totemKey, totemReason, "ready", nil, false)
        return ApplyCastDelay(action, state)
    end

    if D:IsKnown("LIGHTNING_BOLT") then
        SetAction(
            action,
            "LIGHTNING_BOLT",
            REASON.LIGHTNING_BOLT,
            "ready",
            nil,
            false
        )
        return ApplyCastDelay(action, state)
    end

    return SetAction(action, "WAIT", REASON.NO_TARGET, "disabled", nil, false)
end

local function ClearCandidates()
    local i = table.getn(P._candidates)
    while i >= 1 do
        P._candidates[i] = nil
        i = i - 1
    end
end

local function AddCandidate(state, db, key, eta, uncertain, priority)
    if not Participates(db, state.mode, key)
        or not D:IsKnown(key) then
        return
    end
    eta = tonumber(eta) or 0
    if eta < 0 then eta = 0 end
    if eta > 15 then return end
    local item = {
        key = key,
        eta = eta,
        priority = tonumber(priority) or PRIORITY[key] or 50,
        uncertain = uncertain and true or false,
    }
    P._candidates[table.getn(P._candidates) + 1] = item
end

local function CandidateSort(a, b)
    if math.abs((a.eta or 0) - (b.eta or 0)) < 0.05 then
        return (a.priority or 50) < (b.priority or 50)
    end
    return (a.eta or 0) < (b.eta or 0)
end

local function RenderForecast(current)
    table.sort(P._candidates, CandidateSort)

    local outputIndex = 1
    local candidateIndex = 1
    while outputIndex <= FORECAST_LIMIT do
        local candidate = P._candidates[candidateIndex]
        if not candidate then
            P._forecast[outputIndex] = nil
            outputIndex = outputIndex + 1
        else
            if candidate.key ~= current.key then
                local action = P._forecast[outputIndex]
                if not action then
                    action = {}
                    P._forecast[outputIndex] = action
                end
                SetAction(
                    action,
                    candidate.key,
                    REASON.FORECAST,
                    "forecast",
                    candidate.eta,
                    candidate.uncertain
                )
                outputIndex = outputIndex + 1
            end
            candidateIndex = candidateIndex + 1
        end
    end
    return P._forecast
end

local function AddDamageTotemForecast(state, db, current, actionLock)
    if state.fireTotemStateAvailable ~= true
        or state.fireTotemKind == "utility"
        or not DamageTotemTargetInRange(state) then
        return
    end

    local kind = state.fireTotemKind
    local remaining = tonumber(state.fireTotemRemaining) or 0
    if state.mode == "single" then
        if not Enabled(db, "enableSearingTotem") then return end
        local eta = actionLock
        if kind == "nova" or kind == "searing" then
            eta = Max(eta, remaining)
        end
        AddCandidate(state, db, "SEARING_TOTEM", eta, false)
        return
    end

    if kind == "nova" then
        if Enabled(db, "enableMagmaTotem") then
            AddCandidate(
                state,
                db,
                "MAGMA_TOTEM",
                Max(actionLock, remaining),
                false
            )
        end
        return
    elseif kind == "magma" then
        local novaCooldown = CooldownRemaining(state, "FIRE_NOVA_TOTEM")
        if Enabled(db, "enableFireNovaTotem")
            and D:IsKnown("FIRE_NOVA_TOTEM")
            and novaCooldown <= remaining + 0.05 then
            AddCandidate(
                state,
                db,
                "FIRE_NOVA_TOTEM",
                Max(actionLock, remaining),
                false
            )
        elseif Enabled(db, "enableMagmaTotem") then
            AddCandidate(
                state,
                db,
                "MAGMA_TOTEM",
                Max(actionLock, remaining),
                false
            )
        end
        return
    end

    local totemKey = ChooseDamageTotem(state, db)
    if not totemKey then return end
    AddCandidate(state, db, totemKey, actionLock, false)
    if totemKey == "FIRE_NOVA_TOTEM"
        and Enabled(db, "enableMagmaTotem") then
        local activation = tonumber(state.fireNovaActivation) or 5
        local magmaEta
        if current and current.key == "FIRE_NOVA_TOTEM" then
            magmaEta = Max(actionLock, activation)
        else
            magmaEta = actionLock + activation
        end
        AddCandidate(state, db, "MAGMA_TOTEM", magmaEta, false)
    end
end

-- 仅生成参考时间线：候选 ETA 从当前读条／GCD 结束后开始，并与
-- Recommend／Execute 共用同一套 Participates 参与规则。
function P:BuildForecast(state, current)
    ClearCandidates()
    if not state.targetValid then
        local clearIndex = 1
        while clearIndex <= FORECAST_LIMIT do
            self._forecast[clearIndex] = nil
            clearIndex = clearIndex + 1
        end
        return self._forecast
    end

    local db = state.profileDB or D:GetProfileDB(self.key)
    local actionLock = Max(state.gcd, state.castRemaining)
    if not state.casting then
        actionLock = Max(actionLock, BASE_CAST[current.key] or 1.5)
    else
        actionLock = actionLock + (BASE_CAST[current.key] or 1.5)
    end

    local burstMode = BurstModeEnabled(db, state.mode)

    if state.mode == MODE_ELEMENTAL_PVP_CLOSE then
        local stompPriority = state.moving and 3 or 2
        local chainPriority = state.moving and 4 or 3
        local shockPriority = state.moving and 2 or 4
        local masteryEta = CooldownRemaining(state, "ELEMENTAL_MASTERY")
        if current.key == "ELEMENTAL_MASTERY" and masteryEta < 0.05 then
            masteryEta = 180
        end
        AddCandidate(
            state,
            db,
            "ELEMENTAL_MASTERY",
            Max(actionLock, masteryEta),
            false,
            1
        )

        local stompEta = CooldownRemaining(state, "WAR_STOMP")
        if current.key == "WAR_STOMP" and stompEta < 0.05 then
            stompEta = 60
        end
        if state.closeInRange == true then
            AddCandidate(
                state,
                db,
                "WAR_STOMP",
                Max(actionLock, stompEta),
                false,
                stompPriority
            )
        end

        local closeChainEta = CooldownRemaining(state, "CHAIN_LIGHTNING")
        if current.key == "CHAIN_LIGHTNING" and closeChainEta < 0.05 then
            closeChainEta = 6
        end
        AddCandidate(
            state,
            db,
            "CHAIN_LIGHTNING",
            Max(actionLock, closeChainEta),
            false,
            chainPriority
        )

        local shockEta = CooldownRemaining(state, "EARTH_SHOCK")
        if current.key == "EARTH_SHOCK" and shockEta < 0.05 then
            shockEta = 6
        end
        AddCandidate(
            state,
            db,
            "EARTH_SHOCK",
            Max(actionLock, shockEta),
            false,
            shockPriority
        )
        AddCandidate(
            state,
            db,
            "LIGHTNING_BOLT",
            actionLock,
            false,
            5
        )
        return RenderForecast(current)
    elseif state.mode == MODE_ENHANCE_MELEE then
        AddCandidate(
            state,
            db,
            "LIGHTNING_STRIKE",
            Max(actionLock, CooldownRemaining(state, "LIGHTNING_STRIKE")),
            false
        )
        AddCandidate(
            state,
            db,
            "STORMSTRIKE",
            Max(actionLock, CooldownRemaining(state, "STORMSTRIKE")),
            false
        )
        local forecastShockKey = EnhancementShockKey(db)
        if forecastShockKey then
            AddCandidate(
                state,
                db,
                forecastShockKey,
                Max(
                    actionLock,
                    CooldownRemaining(state, forecastShockKey)
                ),
                false,
                3
            )
        end
        return RenderForecast(current)
    elseif state.mode == MODE_ENHANCE_RANGED then
        local enhanceChainEta = CooldownRemaining(state, "CHAIN_LIGHTNING")
        if current.key == "CHAIN_LIGHTNING" and enhanceChainEta < 0.05 then
            enhanceChainEta = 6
        end
        AddCandidate(
            state,
            db,
            "CHAIN_LIGHTNING",
            Max(actionLock, enhanceChainEta),
            false
        )
        AddCandidate(state, db, "LIGHTNING_BOLT", actionLock, false)
        return RenderForecast(current)
    end

    if state.mode == "single" and not burstMode then
        local fsEta = tonumber(state.flameShockRemaining) or 0
        if current.key == "FLAME_SHOCK" then
            fsEta = 12
        end
        AddCandidate(
            state,
            db,
            "FLAME_SHOCK",
            Max(actionLock, fsEta),
            false
        )

        if state.flameShock or current.key == "FLAME_SHOCK" then
            local lavaEta = CooldownRemaining(state, "LAVA_BURST")
            if current.key == "LAVA_BURST" and lavaEta < 0.05 then
                lavaEta = 8
            end
            AddCandidate(
                state,
                db,
                "LAVA_BURST",
                Max(actionLock, lavaEta),
                false
            )
        end
    end


    if state.mode == "aoe" and burstMode then
        AddCandidate(
            state,
            db,
            "EARTHQUAKE",
            Max(actionLock, CooldownRemaining(state, "EARTHQUAKE")),
            false
        )
    end

    AddDamageTotemForecast(state, db, current, actionLock)

    local chainEta = CooldownRemaining(state, "CHAIN_LIGHTNING")
    if current.key == "CHAIN_LIGHTNING" and chainEta < 0.05 then
        chainEta = 6
    end
    AddCandidate(
        state,
        db,
        "CHAIN_LIGHTNING",
        Max(actionLock, chainEta),
        not burstMode and (tonumber(state.clearcasting) or 0) <= 0
    )
    AddCandidate(state, db, "LIGHTNING_BOLT", actionLock, false)

    return RenderForecast(current)
end

function P:Evaluate(state)
    local recommendation = self:Recommend(state)
    local forecasts = self:BuildForecast(state, recommendation)
    return recommendation, forecasts
end

function P:SelectNearestEnemy()
    if type(TargetNearestEnemy) ~= "function"
        or type(UnitExists) ~= "function"
        or type(UnitIsDead) ~= "function"
        or type(UnitCanAttack) ~= "function" then
        return false
    end

    TargetNearestEnemy()
    return UnitExists("target")
        and not UnitIsDead("target")
        and UnitCanAttack("player", "target") and true or false
end

-- 先于目标准备判断徽记，使没有敌对目标时也能解控；任何换目标后都重新构建
-- 技能动作所需的 State。
function P:Execute(mode)
    mode = self:NormalizeMode(mode)
    D:SetMode(mode, true)

    local state = D:BuildState()
    local action = self:Recommend(state)

    if not action or action.key ~= "HORDE_INSIGNIA" then
        local targetChanged = D:PrepareExecutionTarget(true)
        if targetChanged or not state.targetValid then
            state = D:BuildState()
            action = self:Recommend(state)
        end
    end

    if not action or not action.key or action.key == "WAIT"
        or not D:IsKnown(action.key) then
        D:Update(true)
        return false
    end

    if action.key == "HORDE_INSIGNIA" then
        local slot = tonumber(action.inventorySlot)
        if (slot == 13 or slot == 14)
            and type(UseInventoryItem) == "function" then
            T:SetLastCastReason(action.reason)
            UseInventoryItem(slot)
            D:Update(true)
            return true
        end
        D:Update(true)
        return false
    end

    T:SetLastCastReason(action.reason)
    CastSpellByName(action.name)
    D:Update(true)
    return true
end
