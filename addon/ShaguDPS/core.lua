--[[
    ============================================================================
    ShaguDPS 核心模块
    ============================================================================
    负责初始化全局数据表、默认配置、通用工具函数，并检测 Nampower 扩展是否可用。
    所有其他模块（解析器、窗口、设置）都依赖于此模块导出的 ShaguDPS 表。
    此模块在插件加载时最先执行，定义全局命名空间、数据结构、配置默认值、
    缓存加载/保存、公共函数等。
    ============================================================================
]]

-- ============================================================================
-- 1. 全局命名空间与基础变量
-- ============================================================================

ShaguDPS = {}

-- 小怪战斗累计总持续时间（秒），用于光环覆盖率计算时的总时间基准
ShaguDPS.small_fight_total_time = 0

-- 敌对目标跟踪表：用于精确战斗状态判定
ShaguDPS.hostile_targets = ShaguDPS.hostile_targets or {}

-- 创建一个通用的确认/取消对话框模板，用于清空数据等需要用户确认的操作
StaticPopupDialogs["SHAGUMETER_QUESTION"] = {
    button1 = YES,
    button2 = NO,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
}

-- 可用的状态栏材质列表，用于进度条外观切换
local textures = {
    "Interface\\BUTTONS\\WHITE8X8",
    "Interface\\TargetingFrame\\UI-StatusBar",
    "Interface\\Tooltips\\UI-Tooltip-Background",
    "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar"
}

-- ============================================================================
-- 2. 工具函数
-- ============================================================================

-- 简单的四舍五入函数
-- @param input 要舍入的数值
-- @param places 保留的小数位数，默认为 0
-- @return 舍入后的数值
local function round(input, places)
    if not places then places = 0 end
    if type(input) == "number" and type(places) == "number" then
        local pow = 1
        for i = 1, places do pow = pow * 10 end
        return floor(input * pow + 0.5) / pow
    end
end

-- ============================================================================
-- 2.5 vanilla 1.12 API 兼容层
-- ============================================================================
-- 部分 API 是 TBC+（2.x）才加入的暴雪原生接口，vanilla 1.12 没有：
--   GetUnitGUID     -> 1.12 用 UnitGUID（SuperWoW）或 UnitExists 的第二返回值
--   GetSpellRecField -> 1.12 只有 GetSpellInfo（返回 name/rank/icon 等基础字段）
-- 这里在缺失时提供等价实现，保证香草环境不报错。
-- Nampower 的 GUID 扩展用法（GetUnitGUID("0x...owner")）在 vanilla 无对应能力，
-- 返回 nil，调用方已有降级路径（GetUnitField charm/createdBy 等）。
if not GetUnitGUID then
    -- 三级降级链（与 pfUI.api.GetUnitGUID 一致）：
    --   1. Nampower 3.0+ -> GetUnitGUID(unit)（已在判断不存在，故不重复检查）
    --   2. SuperWoW      -> UnitGUID(unit)
    --   3. 纯 vanilla    -> select(2, UnitExists(unit))（vanilla 1.12 原生返回 GUID）
    -- Nampower 的 GUID 扩展用法（GetUnitGUID("0x...owner")）无对应能力时返回 nil，
    -- 调用方已有降级路径（GetUnitField charm/createdBy 等）。
    GetUnitGUID = function(unit)
        -- Nampower 扩展：petGUID .. "owner" 形式，环境不支持时返回 nil
        if type(unit) == "string" and string.sub(unit, 1, 2) == "0x" then
            return nil
        end
        if UnitGUID then
            local guid = UnitGUID(unit)
            if guid and guid ~= "" and guid ~= "0x0000000000000000" then
                return guid
            end
        end
        -- 纯 vanilla 原生：UnitExists 的第二返回值即 GUID
        if UnitExists then
            return select(2, UnitExists(unit))
        end
        return nil
    end
end

if not GetSpellRecField then
    -- GetSpellInfo 是 vanilla 1.12 核心 API，但为极特殊环境做防护
    local spellInfoApi = GetSpellInfo
    GetSpellRecField = function(spellId, field)
        if not spellInfoApi then
            return nil
        end
        local name = spellInfoApi(spellId)
        if field == "name" then
            return name
        end
        -- dispel/effect 等扩展字段 vanilla 无法获取，返回 nil（调用方已有 nil 防护）
        return nil
    end
end

-- 检测当前客户端版本（香草/TBC/WOTLK），用于不同扩展的兼容处理
-- @return "tbc", "wotlk" 或 "vanilla"
local function expansion()
    local _, _, _, client = GetBuildInfo()
    client = client or 11200

    if client >= 20000 and client <= 20400 then
        return "tbc"
    elseif client >= 30000 and client <= 30300 then
        return "wotlk"
    else
        return "vanilla"
    end
end

-- 检测 Nampower 是否可用且版本 >= 4.5.0（需要驱散事件等高级功能）
local function checkNampower()
    if not GetNampowerVersion then
        return false
    end
    local major, minor, patch = GetNampowerVersion()
    if major and (major > 4 or (major == 4 and minor >= 5)) then
        return true
    end
    return false
end

ShaguDPS.hasNampower = checkNampower()
if not ShaguDPS.hasNampower and GetNampowerVersion then
    -- Nampower 存在但版本过低，提示回退到战斗日志解析模式
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ShaguDPS: 需要 Nampower 4.5.0 或更高版本才能使用精确数据采集，已回退到战斗日志解析模式。|r")
end

-- ============================================================================
-- 3. 全局数据存储结构
-- ============================================================================

-- data 表包含所有统计类型（伤害/治疗/死亡/技能施放/命中明细/误伤/驱散/破甲/
-- 承受伤害/能量回复/无效伤害/受到治疗/DOT跳数/复活/光环/打断/敌人承伤等）。
-- 每种统计分两段：[0]=全程, [1]=当前战斗；单位数据以单位名为 key 存子表。
-- invalid_damage 按源玩家名存储，_by_target 映射目标名到子表。
local data = {
    damage = { [0] = {}, [1] = {} },
    heal = { [0] = {}, [1] = {} },
    death = { [0] = {}, [1] = {} },
    spellcast = { [0] = {}, [1] = {} },
    spellcast_details = { [0] = {}, [1] = {} },
    friendly_fire = { [0] = {}, [1] = {} },
    dispel = { [0] = {}, [1] = {} },
    sunder = { [0] = {}, [1] = {} },
    damage_taken = { [0] = {}, [1] = {} },
    enemy_damage_taken = { [0] = {}, [1] = {} },
    energize = { [0] = {}, [1] = {} },
    invalid_damage = { [0] = {}, [1] = {} },
    heal_taken = { [0] = {}, [1] = {} },
    dot_ticks = { [0] = {}, [1] = {} },
    hit_breakdown = { [0] = {}, [1] = {} },
    revive = { [0] = {}, [1] = {} },
    buff_coverage = { [0] = {}, [1] = {} },
    weakness_coverage = { [0] = {}, [1] = {} },
    interrupt = { [0] = {}, [1] = {} },
    playback = { [1] = {} },
    enemy_max_health = {},
    classes = {},
    threat = {},
    threat_history = {},
    death_timestamps = {},
    death_replays = {},
    all_death_replays = {},
}

data.combat_start_time = 0
data.last_fight_duration = 0
data.total_combat_time = 0
data.revive_noncombat = data.revive_noncombat or {}

-- 小怪累计统计（累加所有非BOSS战）
data.small_fight = {
    damage = {},
    heal = {},
    death = {},
    spellcast = {},
    spellcast_details = {},
    friendly_fire = {},
    dispel = {},
    sunder = {},
    damage_taken = {},
    enemy_damage_taken = {},
    energize = {},
    invalid_damage = {},
    heal_taken = {},
    dot_ticks = {},
    hit_breakdown = {},
    revive = {},
    buff_coverage = {},
    weakness_coverage = {},
    interrupt = {},
}

-- ============================================================================
-- 4. 用户配置默认值
-- ============================================================================

local config = {
    height = 15,
    spacing = 0,
    track_all_units = 0,
    merge_pets = 1,
    visible = 1,
    backdrop = 1,
    texture = 2,
    pastel = 0,
    lock = 0,
    exclude_critters = 0,
    hide_friendly_damage = 0,
    clamp_damage_to_health = 0,
    heal_only_in_combat = 1,
    show_dps_in_damage = 1,
    show_hps_in_heal = 0,
    show_overkill = 0,
    hide_nondefault_threat_out_of_combat = 0,
    show_only_tank_and_self_in_threat = 0,
    menu_grow_upwards = 0,
    scale = 1.0,
    report_lines = 10,
    pfuiStyle = 0,
    auto_reset_on_new_group = 1,
    separate_mh_oh_damage = 0,
    use_total_cbt_for_dps = 0,
    show_class_icon = 0,
    chinese_units = 0,
    title_autohide = 0,
    hide_out_of_combat = 0,
    hide_out_of_party = 0,
    perCharConfig = 0,
    enabled_stats = {
        [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1,
        [9]=1, [10]=1, [11]=1, [13]=1, [14]=1, [16]=1, [17]=1,
        [18]=1, [19]=1, [20]=1, [21]=1, [22]=1, [24]=1,
        [25]=1,
    },
}

-- 内部特殊字段名集合，用于在遍历技能列表时跳过这些元数据字段
local internals = {
    ["_sum"] = true,
    ["_ctime"] = true,
    ["_tick"] = true,
    ["_esum"] = true,
    ["_effective"] = true,
    ["_total"] = true,
    ["_offensive"] = true,
    ["_defensive"] = true,
    ["_overkill"] = true,
    ["_overkill_by_spell"] = true,
    ["_history"] = true,
    ["_by_type"] = true,
    ["_by_target"] = true,
    ["_total_time"] = true,
    ["_events"] = true,
    ["_deaths"] = true,
    ["_target_deaths"] = true,
}

-- 创建核心组件框架（实际内容在其他文件中填充）
local settings = CreateFrame("Frame", nil, UIParent)
local parser = CreateFrame("Frame")
local window = {}

-- 将内部变量暴露到全局 ShaguDPS 表，供其他模块通过 ShaguDPS.xxx 访问
ShaguDPS.data = data
ShaguDPS.config = config
ShaguDPS.textures = textures
ShaguDPS.window = window
ShaguDPS.settings = settings
ShaguDPS.internals = internals
ShaguDPS.parser = parser
ShaguDPS.round = round
ShaguDPS.expansion = expansion

-- ============================================================================
-- 5. 战斗状态缓存与判断
-- ============================================================================

-- 战斗状态缓存（0.2 秒 TTL）：避免高频事件（每次治疗/每个 aura 事件）重复做几十次 API 扫描
ShaguDPS._combatCacheTime = 0
ShaguDPS._combatCacheValue = nil

-- 判断当前是否处于战斗状态。
-- 注意两个分支行为不同：
--  - 非 Nampower：玩家/宠物/任一队友在战斗即视为战斗（宽松判定，仅用于基础统计）
--  - Nampower：即便玩家/宠物/队友在战斗，也必须有真实敌对目标（hostile_targets）
--    正在被攻击才返回 true，避免队友血性狂怒等"空进战斗"导致误统计
-- @param force 传 true 时强制重新计算（跳过缓存）
function ShaguDPS.Combat(force)
    local now = GetTime()
    if not force and now - ShaguDPS._combatCacheTime < 0.2 then
        return ShaguDPS._combatCacheValue
    end
    local result
    if not ShaguDPS.hasNampower then
        if UnitAffectingCombat("player") or UnitAffectingCombat("pet") then result = true end
        if not result then
            local raid = GetNumRaidMembers()
            local group = GetNumPartyMembers()
            if raid >= 1 then
                for i = 1, raid do
                    if UnitAffectingCombat("raid" .. i) or UnitAffectingCombat("raidpet" .. i) then
                        result = true
                        break
                    end
                end
            else
                for i = 1, group do
                    if UnitAffectingCombat("party" .. i) or UnitAffectingCombat("partypet" .. i) then
                        result = true
                        break
                    end
                end
            end
        end
    else
        local anyGroupInCombat = UnitAffectingCombat("player") or UnitAffectingCombat("pet")
        local raid = GetNumRaidMembers()
        local group = GetNumPartyMembers()
        if raid >= 1 then
            for i = 1, raid do
                if UnitAffectingCombat("raid" .. i) or UnitAffectingCombat("raidpet" .. i) then
                    anyGroupInCombat = true
                    break
                end
            end
        else
            for i = 1, group do
                if UnitAffectingCombat("party" .. i) or UnitAffectingCombat("partypet" .. i) then
                    anyGroupInCombat = true
                    break
                end
            end
        end
        -- 关键闸门：队伍在战斗且存在真实敌对目标时，需逐一验证目标确实在战斗
        if anyGroupInCombat then
            for guid, info in pairs(ShaguDPS.hostile_targets or {}) do
                if type(info) == "table" and not info.dead then
                    if UnitAffectingCombat(guid) then
                        result = true
                        break
                    end
                end
            end
        end
    end
    ShaguDPS._combatCacheTime = now
    ShaguDPS._combatCacheValue = result
    return result
end

-- ============================================================================
-- 6. 统计视图管理
-- ============================================================================

if ShaguDPS.hasNampower then
    ShaguDPS.rightStatViews = {1,2,3,4,5,6,7,8,9,10,11,13,14,16,17,18,19,20,21,22,24,25}
else
    ShaguDPS.rightStatViews = {1,2,3,4,11}
end

-- 是否启用某统计视图
-- 视图 ID 说明：
--  12 = BOSS战, 15 = BOSS汇总, 23 = 最近战斗 —— 不受右侧开关控制，始终可见
--  25 = 动作回放（仅 Nampower 环境），受右侧开关控制
--  11 = 仇恨 —— 无 Nampower 时仍可用
function ShaguDPS.IsStatEnabled(viewId)
    if viewId == 12 or viewId == 15 or viewId == 23 then return true end
    if viewId == 25 then return ShaguDPS.hasNampower and ShaguDPS.config.enabled_stats[25] ~= 0 end
    if not ShaguDPS.hasNampower and viewId ~= 11 and viewId > 4 then
        return false
    end
    local enabled_stats = ShaguDPS.config and ShaguDPS.config.enabled_stats
    if not enabled_stats then return true end
    return enabled_stats[viewId] ~= 0
end

-- 动作回放视图仅在当前/近期战斗/BOSS战中可用，全程/小怪/BOSS汇总不可见
-- segmentType: 0=全程 1=当前 2=小怪；viewId 可为普通视图ID或12/15/23
function ShaguDPS.IsPlaybackViewApplicable(segmentType, viewId)
    if viewId == 15 then return false end
    if viewId == 12 or viewId == 23 then return true end
    if segmentType == 0 or segmentType == 2 then return false end
    return true
end

function ShaguDPS.GetFirstEnabledStat()
    for _, id in ipairs(ShaguDPS.rightStatViews) do
        if ShaguDPS.IsStatEnabled(id) then
            return id
        end
    end
    return nil
end

function ShaguDPS.IsAnyViewEnabled(ids)
    for _, id in ipairs(ids) do
        if ShaguDPS.IsStatEnabled(id) then return true end
    end
    return false
end

-- ============================================================================
-- 7. 光环与易伤覆盖率活跃状态
-- ============================================================================

ShaguDPS.buff_coverage_active = {}
ShaguDPS.weakness_coverage_active = {}

-- ============================================================================
-- 8. BOSS 战与最近战斗记录
-- ============================================================================

ShaguDPS.boss_fights = ShaguDPS.boss_fights or {}
ShaguDPS.recent_fights = ShaguDPS.recent_fights or {}
ShaguDPS.current_recent_index = nil

-- 动作回放只保留在本次 UI 会话，退出或 /reload 后释放。
ShaguDPS.playback = {
    current = nil,  -- 当前战斗回放
    recent = {},    -- [index] = playback，与 ShaguDPS.recent_fights 对应
    boss = {},      -- [index] = playback，与 ShaguDPS.boss_fights 对应
}
ShaguDPS.cached_current_playback = ShaguDPS.playback.current

function ShaguDPS.ClearBossFights()
    for i = table.getn(ShaguDPS.boss_fights), 1, -1 do
        table.remove(ShaguDPS.boss_fights, i)
    end
    ShaguDPS.playback.boss = {}
end

-- ============================================================================
-- 9. 缓存管理
-- ============================================================================

ShaguDPS.cached_current_dispel = nil
ShaguDPS.cached_current_damage_taken = nil
ShaguDPS.cached_current_heal_taken = nil
ShaguDPS.cached_current_spellcast_details = nil
ShaguDPS.cached_current_hit_breakdown = nil
ShaguDPS.cached_current_buff_coverage = nil
ShaguDPS.cached_current_weakness_coverage = nil
ShaguDPS.cached_current_death_replays = nil

-- 附近非队伍玩家职业映射（用于职业图标，不参与染色）
ShaguDPS.classIcons = ShaguDPS.classIcons or {}

-- Only cumulative aggregates cross sessions. Event histories stay in memory.
local cacheLoaded = false
local cacheKeys = {
    "damage", "heal", "death", "spellcast", "spellcast_details",
    "friendly_fire", "dispel", "sunder", "damage_taken", "enemy_damage_taken",
    "energize", "invalid_damage", "heal_taken", "dot_ticks", "hit_breakdown",
    "revive", "buff_coverage", "weakness_coverage", "interrupt",
}

local function copySummary(value)
    if type(value) ~= "table" then
        if type(value) == "number" then
            if value - value == 0 then return value end -- finite numbers only (Lua 5.0)
        elseif type(value) == "string" or type(value) == "boolean" then
            return value
        end
        return nil
    end
    local result = {}
    for key, child in pairs(value) do
        if key == "_history" or key == "_by_target" then
            -- Empty containers are also type markers used by the parser and UI.
            result[key] = {}
        elseif key ~= "_tick" and key ~= "_detail_history" and key ~= "_detail_heal_history" then
            result[key] = copySummary(child)
        end
    end
    if type(result._ctime) == "number" and result._ctime <= 0 then result._ctime = 1 end
    return result
end

function ShaguDPS.SaveDataToCache()
    -- Combat events can fire before the first PLAYER_ENTERING_WORLD restores data.
    if not cacheLoaded then return end
    local cache = {
        version = 2,
        classes = copySummary(data.classes),
        total_combat_time = data.total_combat_time,
        small_fight_total_time = ShaguDPS.small_fight_total_time or 0,
        revive_noncombat = copySummary(data.revive_noncombat),
        small_fight = {},
    }
    for _, key in ipairs(cacheKeys) do
        cache[key .. "0"] = copySummary(data[key][0])
        cache.small_fight[key] = copySummary(data.small_fight[key])
    end
    -- Never alias live tables: later combat must not grow the saved snapshot.
    ShaguDPS_Cache = cache
end

function ShaguDPS.LoadDataFromCache()
    -- Zoning also fires PLAYER_ENTERING_WORLD; restore only once per UI session.
    if cacheLoaded then return false end
    cacheLoaded = true
    ShaguDPS_Playback = nil -- release the legacy SavedVariable, never restore it
    local cache = ShaguDPS_Cache
    if type(cache) ~= "table" or (cache.version ~= 1 and cache.version ~= 2) then
        ShaguDPS_Cache = {}
        return false
    end
    for _, key in ipairs(cacheKeys) do
        if type(cache[key .. "0"]) == "table" then
            data[key][0] = copySummary(cache[key .. "0"])
        end
        if type(cache.small_fight) == "table" and type(cache.small_fight[key]) == "table" then
            data.small_fight[key] = copySummary(cache.small_fight[key])
        end
    end
    if type(cache.classes) == "table" then data.classes = copySummary(cache.classes) end
    if type(cache.revive_noncombat) == "table" then
        data.revive_noncombat = copySummary(cache.revive_noncombat)
    end
    data.total_combat_time = tonumber(cache.total_combat_time) or 0
    ShaguDPS.small_fight_total_time = tonumber(cache.small_fight_total_time) or 0
    -- Old caches may have been saved mid-fight. Recover elapsed time, not the old clock.
    if cache.version == 1 and type(cache.combat_start_time) == "number"
        and cache.combat_start_time > 0 and type(cache.timestamp) == "number" then
        data.total_combat_time = data.total_combat_time
            + math.max(0, cache.timestamp - cache.combat_start_time)
    end
    if ShaguDPS.InvalidateBossSummaryCache then ShaguDPS.InvalidateBossSummaryCache() end
    ShaguDPS.SaveDataToCache()
    return true
end

-- The UI reset clears primary counters before clearing session details here.
function ShaguDPS.ClearCache()
    if ShaguDPS.InvalidateBossSummaryCache then ShaguDPS.InvalidateBossSummaryCache() end
    ShaguDPS_Cache = {}
    ShaguDPS.cached_current_damage = nil
    ShaguDPS.cached_current_heal = nil
    ShaguDPS.cached_current_death = nil
    ShaguDPS.cached_current_spellcast = nil
    ShaguDPS.cached_current_spellcast_details = nil
    ShaguDPS.cached_current_friendly_fire = nil
    ShaguDPS.cached_current_dispel = nil
    ShaguDPS.cached_current_damage_taken = nil
    ShaguDPS.cached_current_enemy_damage_taken = nil
    ShaguDPS.cached_current_energize = nil
    ShaguDPS.cached_current_invalid_damage = nil
    ShaguDPS.cached_current_heal_taken = nil
    ShaguDPS.cached_current_dot_ticks = nil
    ShaguDPS.cached_current_hit_breakdown = nil
    ShaguDPS.cached_current_revive = nil
    ShaguDPS.cached_current_buff_coverage = nil
    ShaguDPS.cached_current_weakness_coverage = nil
    ShaguDPS.cached_current_interrupt = nil
    ShaguDPS.cached_current_death_replays = nil
    data.playback[1] = {}
    ShaguDPS.cached_current_playback = nil
    ShaguDPS.playback = {
        current = nil,
        recent = {},
        boss = {},
    }
    ShaguDPS.playback_damaged = {}
    ShaguDPS.playback_death_times = {}
    ShaguDPS.playback_unit_deaths = {}
    data.death_replays = {}
    data.all_death_replays = {}
    ShaguDPS.boss_fights = {}
    ShaguDPS.recent_fights = {}
    ShaguDPS.current_recent_index = nil
    data.sunder[0] = {}
    data.sunder[1] = {}
    data.damage_taken[0] = {}
    data.damage_taken[1] = {}
    data.enemy_damage_taken[0] = {}
    data.enemy_damage_taken[1] = {}
    data.energize[0] = {}
    data.energize[1] = {}
    data.invalid_damage[0] = {}
    data.invalid_damage[1] = {}
    data.heal_taken[0] = {}
    data.heal_taken[1] = {}
    data.dot_ticks[0] = {}
    data.dot_ticks[1] = {}
    data.hit_breakdown[0] = {}
    data.hit_breakdown[1] = {}
    data.death_timestamps = {}
    data.total_combat_time = 0
    data.combat_start_time = 0
    data.last_fight_duration = 0
    data.revive_noncombat = {}
    data.revive[0] = {}
    data.revive[1] = {}
    data.spellcast_details[0] = {}
    data.spellcast_details[1] = {}
    data.buff_coverage[0] = {}
    data.buff_coverage[1] = {}
    data.weakness_coverage[0] = {}
    data.weakness_coverage[1] = {}
    data.interrupt[0] = {}
    data.interrupt[1] = {}
    ShaguDPS.buff_coverage_active = {}
    data.threat_history = {}
    data.threat = {}
    data.small_fight = {
        damage = {},
        heal = {},
        death = {},
        spellcast = {},
        spellcast_details = {},
        friendly_fire = {},
        dispel = {},
        sunder = {},
        damage_taken = {},
        enemy_damage_taken = {},
        energize = {},
        invalid_damage = {},
        heal_taken = {},
        dot_ticks = {},
        hit_breakdown = {},
        revive = {},
        buff_coverage = {},
        weakness_coverage = {},
        interrupt = {},
    }
    ShaguDPS.small_fight_total_time = 0
    ShaguDPS.hostile_targets = {}
    data.enemy_max_health = {}
end

-- ============================================================================
-- 10. 无效单位名单（造成伤害时不统计入正常伤害，归入“无效伤害”视图）
-- ============================================================================

ShaguDPS.Locale = GetLocale()

-- 无效单位名单按客户端语言分别加载（zhCN 使用中文名，其余使用英文名）
if ShaguDPS.Locale == "zhCN" then
    ShaguDPS.ignoredUnitNames = ShaguDPS.ignoredUnitNames or {
        ["死亡骑士学员"] = true,
        ["势不可挡的地狱火"] = true,
        ["虛空地狱火"] = true,
        ["恶魔之心"] = true,
        ["管理者埃克索图斯"] = true,
        ["熔核怒犬"] = true,
        ["肉用僵尸"] = true,
    }
else
    ShaguDPS.ignoredUnitNames = ShaguDPS.ignoredUnitNames or {
        ["Deathknight Understudy"] = true,
        ["Unstoppable Infernal"] = true,
        ["Nether Infernal"] = true,
        ["Felheart"] = true,
        ["Majordomo Executus"] = true,
        ["Core Rager"] = true,
        ["Zombie chow"] = true,
    }
end

-- ============================================================================
-- 11. 错误驱散监测
-- ============================================================================

-- 不可驱散DEBUFF清单（驱散会导致死亡或严重后果的debuff）
-- type 取值：1=魔法, 2=诅咒, 3=疾病, 4=中毒, 5=激怒
ShaguDPS.badDispelDebuffs = {
    ["不稳定的法力"] = { type = 1 },
    ["外域的恐惧"]   = { type = 2 },
}

-- 驱散技能清单（技能名 -> 可驱散的debuff类型列表）
ShaguDPS.dispelSpells = {
    ["驱散魔法"]      = { types = { 1 } },
    ["驱除疾病"]      = { types = { 3 } },
    ["净化术"]        = { types = { 1 } },
    ["消毒术"]        = { types = { 4 } },
    ["祛病术"]        = { types = { 3 } },
    ["祛病图腾"]      = { types = { 3 } },
    ["清毒图腾"]      = { types = { 4 } },
    ["清洁术"]        = { types = { 3 } },
    ["纯净术"]        = { types = { 1 } },
    ["解除次级诅咒"]  = { types = { 2 } },
    ["驱毒术"]        = { types = { 4 } },
    ["解除诅咒"]      = { types = { 2 } },
    ["宁神射击"]      = { types = { 5 } },
}

-- 当前战斗中，目标身上存在的“不可驱散debuff”标记
ShaguDPS.activeBadDispelDebuffs = {}
-- 错误驱散记录
ShaguDPS.wrongDispels = {}
