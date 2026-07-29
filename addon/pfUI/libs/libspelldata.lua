-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

--[[ libspelldata - Spell Knowledge Database for pfUI ]]--
--
-- Central database for spells where Nampower's AURA_CAST returns durationMs=0
-- or where special duration logic is needed (combopoint abilities, talent mods).
--
-- This library is PURE KNOWLEDGE + lightweight state tracking.
-- It does NOT store debuff timers itself - that remains libdebuff's job.
-- libdebuff calls libspelldata for answers, then stores results in its own tables.
--
-- Handles:
--   1. Self-overwrite debuffs (only one instance per target)
--   2. Debuff overwrite pairs (Faerie Fire <-> Faerie Fire (Feral))
--   3. Combopoint ability classification (Rip, Rupture, Kidney Shot, Expose Armor)
--   4. Forced durations (Judgements, AoE channels, passive procs)
--   5. Melee-hit refresh (Judgement timers refreshed by autoattacks)
--   6. Applicator caster correlation (Judgement SPELL_GO -> DEBUFF_ADDED)
--   7. Crit-based refresh (Ignite)
--   8. Carnage talent refresh detection (Ferocious Bite -> Rip/Rake reset)
--
-- Requires: Nampower 3.0.0+
-- Integrates with: libdebuff.lua (called from event handlers)

-- return instantly if not vanilla
if pfUI.client > 11200 then return end

-- Require Nampower
if not GetNampowerVersion then return end

pfUI.libspelldata = pfUI.libspelldata or {}
local lib = pfUI.libspelldata

-- ============================================================================
-- SELF-OVERWRITE DEBUFFS
-- Only ONE instance of these debuffs can exist on a target (regardless of caster).
-- When a new caster applies it, the old caster's entry is replaced.
-- ============================================================================

local sharedOverwriteDebuffs = {
  ["精灵之火"] = true,
  ["精灵之火（野性）"] = true,
  ["挫志怒吼"] = true,
  ["挫志咆哮"] = true,
  ["猎人印记"] = true,
  ["破甲攻击"] = true,
  ["雷霆一击"] = true,
  ["破甲"] = true,
  ["虚弱诅咒"] = true,
  ["鲁莽诅咒"] = true,
  ["元素诅咒"] = true,
  ["暗影诅咒"] = true,
  ["语言诅咒"] = true,
  ["疲劳诅咒"] = true,
  ["智慧审判"] = true,
  ["光明审判"] = true,
  ["十字军审判"] = true,
  ["公正审判"] = true,
  ["暗影之波"] = true,
  ["深冬之寒"] = true,
  ["火焰脆弱"] = true,
}

-- ============================================================================
-- DEBUFF OVERWRITE PAIRS
-- Variant debuffs that replace each other on the same target.
-- ============================================================================

local debuffOverwritePairs = {
  ["精灵之火"] = "精灵之火（野性）",
  ["精灵之火（野性）"] = "精灵之火",
  ["挫志怒吼"] = "挫志咆哮",
  ["挫志咆哮"] = "挫志怒吼",
}

-- ============================================================================
-- COMBOPOINT ABILITIES
-- Duration depends on combo points at time of cast.
-- For OUR casts: CPs captured at SPELL_CAST_EVENT time by libdebuff.
-- For OTHERS' casts: CP unknown -> duration = 0 (no timer shown)
--
-- Format: ["Spell Name"] = { base = N, perCP = N }
--   duration = base + combopoints * perCP
-- ============================================================================

local combopointSpells = {
  -- Druid
  ["撕扯"]            = { base = 8,  perCP = 2 },

  -- Rogue
  ["割裂"]        = { base = 6,  perCP = 2 },
  ["肾击"]    = { base = 1,  perCP = 1 },
  ["破甲"]   = { base = 30, perCP = 0 },  -- 固定30秒
}

-- ============================================================================
-- FORCED DURATIONS
-- Spells where AURA_CAST returns durationMs=0 or doesn't fire at all.
--
-- Format: ["Spell Name"] = { duration = seconds, refreshOnMelee = bool, ... }
--   refreshOnMelee: if true, every melee hit by the caster refreshes the timer
--   applicatorSpells: table of spell names that refresh this debuff, or false
--   critBasedRefresh: if true, any crit from triggering spells refreshes
-- ============================================================================

local forcedDurations = {
  -- 圣骑士审判（10秒，每次施法者自动攻击刷新）
  ["智慧审判"]       = { duration = 10, refreshOnMelee = true,  applicatorSpells = false },
  ["光明审判"]        = { duration = 10, refreshOnMelee = true,  applicatorSpells = false },
  ["十字军审判"] = { duration = 10, refreshOnMelee = true,  applicatorSpells = false },
  ["公正审判"]      = { duration = 10, refreshOnMelee = true,  applicatorSpells = false },

  -- 法师被动触发
  ["火焰脆弱"]        = { duration = 30, refreshOnMelee = false, applicatorSpells = {"灼烧", "火焰冲击", "火球术", "炎爆术", "烈焰风暴", "火焰冲击", "冲击波", "龙息术", "魔爆术"} },
  ["点燃"]                    = { duration = 4,  refreshOnMelee = false, critBasedRefresh = true },
  ["深冬之寒"]            = { duration = 15, refreshOnMelee = false, applicatorSpells = {"寒冰箭", "冰锥术", "冰霜新星"} },

  -- 牧师被动触发
  ["暗影之波"]            = { duration = 15, refreshOnMelee = false, applicatorSpells = {"心灵震爆", "精神鞭笞", "暗言术：痛", "噬灵疫病"} },

  -- 通道/AOE debuff（无AURA_CAST，SPELL_GO中无目标GUID）
  -- isAoEChannel: 后续周期性触发不应刷新计时器
  ["飓风"]                 = { duration = 10, isAoEChannel = true },
  ["奉献"]              = { duration = 8,  isAoEChannel = true },
  ["暴风雪"]                  = { duration = 8,  isAoEChannel = true },
  ["火雨"]              = { duration = 8,  isAoEChannel = true },
  ["冰霜陷阱"]           = { duration = 30,  isAoEChannel = true },
  ["爆炸陷阱效果"]     = { duration = 20,  isAoEChannel = true },
  ["烈焰风暴"]               = { duration = 8,  isAoEChannel = true },
  ["绞喉"]                   = { duration = 18,  isAoEChannel = false },
  ["穿刺射击"]            = { duration = 8,  isAoEChannel = false },

  -- 其他无AURA_CAST持续时间的技能
  ["痛苦尖刺"]                = { duration = 5,  refreshOnMelee = false, applicatorSpells = false },
  ["突袭流血"]              = { duration = 18, refreshOnMelee = false, applicatorSpells = {"突袭"} },
}

-- ============================================================================
-- APPLICATOR SPELLS (spellId -> true)
-- Spells whose SPELL_GO should be stored as pending caster for correlation
-- with the next DEBUFF_ADDED on the same target.
-- ============================================================================

local applicatorSpells = {
  [20271] = true,   -- 审判（结果取决于当前圣印）
}

-- ============================================================================
-- CARNAGE TALENT (Druid Feral, talent 2/17)
-- Ferocious Bite proc: If Carnage procs, Rip and Rake timers are reset.
-- ============================================================================

local carnageRefreshable = {
  ["撕扯"]  = true,
  ["斜掠"] = true,
}

-- ============================================================================
-- INTERNAL STATE
-- ============================================================================

-- Pending applicator casters: [targetGuid] = { casterGuid, time }
local pendingApplicators = {}

-- Carnage state
local _, playerClass = UnitClass("player")
local carnageState = nil
local carnageCallback = nil

-- Player GUID cache
local cachedPlayerGuid = nil
local function GetPlayerGuid()
  if not cachedPlayerGuid and GetUnitGUID then
    cachedPlayerGuid = GetUnitGUID("player")
  end
  return cachedPlayerGuid
end

-- ============================================================================
-- CARNAGE TALENT TRACKING
-- ============================================================================

-- No talent check needed: If Druid uses Ferocious Bite and gets +1 CP,
-- Carnage procced. The CP check in OnUpdate handles detection.

-- Persistent Carnage check frame
local carnageFrame = CreateFrame("Frame")
carnageFrame:Hide()
carnageFrame:SetScript("OnUpdate", function()
  if not carnageState then
    this:Hide()
    return
  end
  if GetTime() < carnageState.checkTime then return end

  -- Check if we gained a combo point (indicates Carnage proc)
  local cp = GetComboPoints() or 0

  if cp > 0 and carnageCallback then
    local affectedSpells = {}
    for spellName in pairs(carnageRefreshable) do
      table.insert(affectedSpells, spellName)
    end
    carnageCallback(carnageState.targetGuid, affectedSpells)
  end

  carnageState = nil
  this:Hide()
end)

-- ============================================================================
-- API: SPELL QUERIES
-- ============================================================================

function lib:IsSharedOverwrite(spellName)
  if not spellName then return false end
  return sharedOverwriteDebuffs[spellName] == true
end

function lib:GetOverwritePair(spellName)
  if not spellName then return nil end
  return debuffOverwritePairs[spellName]
end

function lib:IsComboPointAbility(spellName)
  if not spellName then return false end
  return combopointSpells[spellName] ~= nil
end

function lib:GetComboPointData(spellName)
  if not spellName then return nil, nil end
  local cpData = combopointSpells[spellName]
  if cpData then
    return cpData.base, cpData.perCP
  end
  return nil, nil
end

function lib:HasForcedDuration(spellName)
  if not spellName then return false end
  return forcedDurations[spellName] ~= nil
end

function lib:IsAoEChannel(spellName)
  if not spellName then return false end
  local data = forcedDurations[spellName]
  return data and data.isAoEChannel or false
end

function lib:IsAnyApplicatorSpell(spellName)
  if not spellName then return false end
  for _, data in pairs(forcedDurations) do
    if data.applicatorSpells then
      for _, applicator in ipairs(data.applicatorSpells) do
        if applicator == spellName then return true end
      end
    end
  end
  return false
end

-- Returns a list of debuff names that the given spell applies as a passive proc.
-- e.g. GetDebuffsForApplicator("灼烧") -> {"火焰脆弱"}
function lib:GetDebuffsForApplicator(spellName)
  if not spellName then return nil end
  local result = nil
  for debuffName, data in pairs(forcedDurations) do
    if data.applicatorSpells then
      for _, applicator in ipairs(data.applicatorSpells) do
        if applicator == spellName then
          result = result or {}
          result[table.getn(result) + 1] = debuffName
          break
        end
      end
    end
  end
  return result
end

function lib:IsApplicatorSpell(debuffName, spellName)
  if not debuffName or not spellName then return false end
  local data = forcedDurations[debuffName]
  if not data or not data.applicatorSpells then return false end
  for _, applicator in ipairs(data.applicatorSpells) do
    if applicator == spellName then
      return true
    end
  end
  return false
end

function lib:RequiresCritForRefresh(debuffName, spellName)
  if not debuffName then return false end
  local data = forcedDurations[debuffName]
  if not data then return false end
  return data.critBasedRefresh == true
end

--- Get the correct duration for a managed spell.
-- For combopoint abilities use GetComboPointData() instead.
function lib:GetDuration(spellName, rank, casterGuid)
  if not spellName then return nil end
  local forced = forcedDurations[spellName]
  if forced then
    return forced.duration
  end
  return nil
end

-- ============================================================================
-- API: MELEE REFRESH
-- ============================================================================

local meleeRefreshCache = nil
function lib:GetMeleeRefreshSpells()
  if not meleeRefreshCache then
    meleeRefreshCache = {}
    for spellName, data in pairs(forcedDurations) do
      if data.refreshOnMelee then
        meleeRefreshCache[spellName] = data.duration
      end
    end
  end
  return meleeRefreshCache
end

-- ============================================================================
-- API: CARNAGE
-- ============================================================================

function lib:SetCarnageCallback(callback)
  carnageCallback = callback
end

function lib:ShouldCheckCarnage(spellName, casterGuid, targetGuid, numHit)
  if playerClass ~= "DRUID" then return false end
  if spellName ~= "凶猛撕咬" then return false end  -- Ferocious Bite
  if casterGuid ~= GetPlayerGuid() then return false end
  if not targetGuid or (numHit and numHit == 0) then return false end
  return true
end

function lib:ScheduleCarnageCheck(targetGuid)
  carnageState = {
    targetGuid = targetGuid,
    checkTime = GetTime() + 0.05,
  }
  carnageFrame:Show()
end

-- ============================================================================
-- API: APPLICATOR TRACKING (SPELL_GO -> DEBUFF_ADDED caster correlation)
-- ============================================================================

function lib:OnSpellGo(spellId, spellName, casterGuid, targetGuid)
  if applicatorSpells[spellId] and targetGuid then
    pendingApplicators[targetGuid] = {
      casterGuid = casterGuid,
      time = GetTime()
    }
  end
end

function lib:OnDebuffAdded(targetGuid, spellId, spellName)
  if not targetGuid then return nil end
  if not forcedDurations[spellName] then return nil end
  local pending = pendingApplicators[targetGuid]
  if pending and (GetTime() - pending.time) < 0.5 then
    pendingApplicators[targetGuid] = nil
    return pending.casterGuid
  end
  return nil
end

function lib:OnDebuffRemoved(targetGuid, spellId, spellName)
  -- No internal state to clean up
end

-- ============================================================================
-- API: CLEANUP
-- ============================================================================

function lib:CleanupUnit(targetGuid)
  pendingApplicators[targetGuid] = nil
end