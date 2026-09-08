---------------------------------------------------------------
-- DoiteTargetAuras.lua
-- 光环持续时间 + 运行时剩余时间 API
-- 请尊重许可说明：使用前请询问
-- WoW 1.12 | Lua 5.0
---------------------------------------------------------------

local DoiteTargetAuras = {}
_G["DoiteTargetAuras"] = DoiteTargetAuras
_G["DoiteTrack"] = DoiteTargetAuras
local DoiteTrack = DoiteTargetAuras

---------------------------------------------------------------
-- 全局变量 / 配置覆盖
---------------------------------------------------------------

-- 仅通过 spellId 手动持续时间。
-- 值可以是：
--  - 数字（固定秒数）
--  - 表  (基于连击点数： [1..5] = 秒)
--  - 仅在 NP 返回 durationMs == 0 时使用。
local ManualDurationBySpellId = {
  ----------------------------------------------------------------
  -- 撕扯 (6 级) - 基于连击点数
  ----------------------------------------------------------------
  [1079] = { [1]=10,[2]=12,[3]=14,[4]=16,[5]=18 }, -- 撕扯 等级 1
  [9492] = { [1]=10,[2]=12,[3]=14,[4]=16,[5]=18 }, -- 撕扯 等级 2
  [9493] = { [1]=10,[2]=12,[3]=14,[4]=16,[5]=18 }, -- 撕扯 等级 3
  [9752] = { [1]=10,[2]=12,[3]=14,[4]=16,[5]=18 }, -- 撕扯 等级 4
  [9894] = { [1]=10,[2]=12,[3]=14,[4]=16,[5]=18 }, -- 撕扯 等级 5
  [9896] = { [1]=10,[2]=12,[3]=14,[4]=16,[5]=18 }, -- 撕扯 等级 6

  ----------------------------------------------------------------
  -- 割裂 (6 级) - 基于连击点数
  ----------------------------------------------------------------
  [1943] = { [1]=8,[2]=10,[3]=12,[4]=14,[5]=16 }, -- 割裂 等级 1
  [8639] = { [1]=8,[2]=10,[3]=12,[4]=14,[5]=16 }, -- 割裂 等级 2
  [8640] = { [1]=8,[2]=10,[3]=12,[4]=14,[5]=16 }, -- 割裂 等级 3
  [11273] = { [1]=8,[2]=10,[3]=12,[4]=14,[5]=16 }, -- 割裂 等级 4
  [11274] = { [1]=8,[2]=10,[3]=12,[4]=14,[5]=16 }, -- 割裂 等级 5
  [11275] = { [1]=8,[2]=10,[3]=12,[4]=14,[5]=16 }, -- 割裂 等级 6
  
  ----------------------------------------------------------------
  -- 肾击 (2 级) - 基于连击点数
  ----------------------------------------------------------------
  [408] = { [1]=1,[2]=2,[3]=3,[4]=4,[5]=5 }, -- 肾击 等级 1
  [8643] = { [1]=2,[2]=3,[3]=4,[4]=5,[5]=6 }, -- 肾击 等级 2
  
  ----------------------------------------------------------------
  -- 毒伤 (1 级) - 基于连击点数
  ----------------------------------------------------------------
  [52531] = { [1]=12,[2]=16,[3]=20,[4]=24,[5]=28 }, -- 毒伤 等级 1

  ----------------------------------------------------------------
  -- 占位符 (# 级) - 非基于连击点数
  ----------------------------------------------------------------  
  --[SpellID] = #,
}

---------------------------------------------------------------
-- 本地 API 快捷方式（登录时分配）
---------------------------------------------------------------
local GetTime = GetTime
local UnitClass = UnitClass
local UnitExists = UnitExists
local GetComboPoints = GetComboPoints
local GetSpellNameAndRankForId = GetSpellNameAndRankForId
local GetUnitField = GetUnitField
local GetTalentInfo = GetTalentInfo
local GetNumTalentTabs = GetNumTalentTabs
local GetNumTalents = GetNumTalents

---------------------------------------------------------------
-- 实用辅助函数
---------------------------------------------------------------
local function _Print(msg, r, g, b)
  if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
    DEFAULT_CHAT_FRAME:AddMessage(msg or "", r or 1.0, g or 1.0, b or 1.0)
  end
end

local function _GetUnitGuidSafe(unit)
  if not unit or not UnitExists then
    return nil
  end
  -- UnitExists(unit) 返回 existsFlag, guid
  local exists, guid = UnitExists(unit)
  if exists and guid and guid ~= "" then
    return guid
  end
  return nil
end

-- 玩家 GUID 缓存
local _playerGUID_cached = nil
local function _GetPlayerGUID()
  if _playerGUID_cached then
    return _playerGUID_cached
  end
  local g = _GetUnitGuidSafe("player")
  if g and g ~= "" then
    _playerGUID_cached = g
    return g
  end
  return nil
end

local function _UnitExistsFlag(unit)
  if not UnitExists then
    return false
  end
  local e = UnitExists(unit)
  return (e == 1 or e == true)
end

local _IsPlayerDruid = false
local _IsPlayerRogue = false

local function _PlayerUsesComboPoints()
  -- 使用缓存的标志（在 LOGIN/ENTERING_WORLD/LEARNED_SPELL_IN_TAB 上更新）
  return (_IsPlayerRogue == true) or (_IsPlayerDruid == true)
end

local function _GetComboPointsSafe()
  if not GetComboPoints then
    return 0
  end
  local ok, val = pcall(GetComboPoints)
  if ok and type(val) == "number" and val >= 0 then
    return val
  end
  return 0
end

---------------------------------------------------------------
-- 数据库连接（仅 NP 持续时间）
---------------------------------------------------------------
local function _GetDB()
  local db = _G["DoiteAurasDB"]
  if not db then
    db = {}
    _G["DoiteAurasDB"] = db
  end

  -- NP（首选）基线持续时间
  db.npDurations = db.npDurations or {}         -- [spellId] = 秒（四舍五入）
  db.npDurationsCP = db.npDurationsCP or {}     -- [spellId] = { [cp] = 秒（四舍五入） }
  db.npDurationsMeta = db.npDurationsMeta or {} -- [spellId] = { samples=?, lastMs=?, lastAt=?, name=?, rank=? }

  return db
end

---------------------------------------------------------------
-- 跟踪映射（来自 DoiteAuras 配置）
---------------------------------------------------------------
local TrackedBySpellId = {}   -- [spellId] = entry
local TrackedByNameNorm = {}  -- [normName] = entry

---------------------------------------------------------------
-- 规范化名称，以便跨等级匹配（"撕扯"，"撕扯（等级 4）"）
---------------------------------------------------------------
local function _NormSpellName(name)
  if not name or name == "" then
    return nil
  end

  name = string.gsub(name, "^%s+", "")
  name = string.gsub(name, "%s+$", "")
  name = string.lower(name)

  name = string.gsub(name, "%s*%(等级%s*%d+%)", "")
  name = string.gsub(name, "%s*等级%s*%d+", "")

  name = string.gsub(name, "^%s+", "")
  name = string.gsub(name, "%s+$", "")

  return name
end

---------------------------------------------------------------
-- 扫描 DoiteAuras 配置，找出哪些增益/减益应被跟踪玩家只关心 onlyMine == true 的条目。
---------------------------------------------------------------
local function _LooksLikeSpellConfigTable(tbl)
  if type(tbl) ~= "table" then
    return false
  end
  local seen = 0
  for _, v in pairs(tbl) do
    if type(v) == "table" then
      if v.type and v.conditions and v.conditions.aura then
        return true
      end
      seen = seen + 1
      if seen > 20 then
        break
      end
    end
  end
  return false
end

local function _DiscoverSpellTable()
  local visited = {}

  local function scan(tbl)
    if type(tbl) ~= "table" or visited[tbl] then
      return nil
    end
    visited[tbl] = true

    if type(tbl.spells) == "table" and _LooksLikeSpellConfigTable(tbl.spells) then
      return tbl.spells
    end

    for _, v in pairs(tbl) do
      if type(v) == "table" then
        local found = scan(v)
        if found then
          return found
        end
      end
    end

    return nil
  end

  local db = _G["DoiteAurasDB"]
  if db then
    local found = scan(db)
    if found then
      return found
    end
  end

  if _G["DoiteDB"] then
    local found = scan(_G["DoiteDB"])
    if found then
      return found
    end
  end

  return nil
end

local function _AddTrackedFromEntry(_, data)
  if not data or type(data) ~= "table" then
    return
  end

  if data.type ~= "Buff" and data.type ~= "Debuff" then
    return
  end

  local c = data.conditions and data.conditions.aura
  if not c then
    return
  end

  local isOnlyMine = (c.onlyMine == true)
  local isOnlyOthers = (c.onlyOthers == true)

  -- 跟踪 onlyMine 或 onlyOthers（配置驱动）
  if (not isOnlyMine) and (not isOnlyOthers) then
    return
  end


  -- 所有权跟踪仅对外部目标有意义。
  local hasTarget = (c.targetHelp or c.targetHarm)
  if not hasTarget then
    return
  end

  local sid = data.spellid and tonumber(data.spellid)
  if sid and sid <= 0 then
    sid = nil
  end

  local addedViaSpellId = (data.Addedviaspellid == true)
  local name = data.displayName or data.name or ""
  local norm = _NormSpellName(name)

  if addedViaSpellId then
    norm = nil
  end

  if not sid and not norm then
    return
  end

  local entry = nil
  if sid then
    entry = TrackedBySpellId[sid]
  end
  if (not entry) and norm then
    entry = TrackedByNameNorm[norm]
  end

  if not entry then
    entry = {
      spellIds = {},
      name = name,
      normName = norm,
      kind = data.type,
      trackHelp = false,
      trackHarm = false,
      onlyMine = false,
      onlyOthers = false,
      addedViaSpellId = addedViaSpellId,
    }
  elseif addedViaSpellId then
    entry.addedViaSpellId = true
  end

  if sid then
    entry.spellIds[sid] = true
    TrackedBySpellId[sid] = entry
  end
  if norm then
    TrackedByNameNorm[norm] = entry
  end

  if c.targetHelp then
    entry.trackHelp = true
  end
  if c.targetHarm then
    entry.trackHarm = true
  end
  if isOnlyMine then
    entry.onlyMine = true
  end
  if isOnlyOthers then
    entry.onlyOthers = true
  end

end

function DoiteTrack:RebuildWatchList()
  for k in pairs(TrackedBySpellId) do
    TrackedBySpellId[k] = nil
  end
  for k in pairs(TrackedByNameNorm) do
    TrackedByNameNorm[k] = nil
  end

  local spells = _DiscoverSpellTable()
  if not spells then
    return
  end

  for key, data in pairs(spells) do
    _AddTrackedFromEntry(key, data)
  end
end

---------------------------------------------------------------
-- 光环存在查询（通过 GetUnitField 的 auraId 表）
---------------------------------------------------------------
local function _GetUnitAuraTable(unit, isDebuff)
  if not GetUnitField then
    return nil
  end

  local function getFieldTable(fieldName)
    local cache = _G["DoiteTrack_AuraFieldCache"]
    if not cache then
      cache = {}
      _G["DoiteTrack_AuraFieldCache"] = cache
    end

    local now = 0
    if GetTime then
      now = GetTime()
    end

    local tick = math.floor(now * 10)
    if cache._tick ~= tick then
      cache._tick = tick
      cache._gen = (cache._gen or 0) + 1
    end
    local gen = cache._gen or 0

    local u = cache[unit]
    if type(u) ~= "table" then
      u = {}
      cache[unit] = u
    end

    local f = u[fieldName]
    if type(f) ~= "table" then
      f = {}
      u[fieldName] = f
    end

    if f._g1 == gen then
      local v = f._v1
      if v == false then
        return nil
      end
      return v
    end

    local ok, t = pcall(GetUnitField, unit, fieldName, 1)
    if ok and type(t) == "table" then
      f._g1 = gen
      f._v1 = t
      return t
    end

    f._g1 = gen
    f._v1 = false

    if f._g0 == gen then
      local v2 = f._v0
      if v2 == false then
        return nil
      end
      return v2
    end

    ok, t = pcall(GetUnitField, unit, fieldName)
    if ok and type(t) == "table" then
      f._g0 = gen
      f._v0 = t
      return t
    end

    f._g0 = gen
    f._v0 = false
    return nil
  end

  if isDebuff then
    return getFieldTable("debuff") or getFieldTable("aura") or getFieldTable("buff")
  else
    return getFieldTable("buff") or getFieldTable("aura") or getFieldTable("debuff")
  end
end

local AuraStateByGuid

local function _AuraHasSpellId(unit, spellId, isDebuff)
  spellId = tonumber(spellId) or 0
  if not unit or spellId <= 0 then
    return false
  end

  local auras = _GetUnitAuraTable(unit, isDebuff)
  if type(auras) ~= "table" then
    return false
  end

  if auras[spellId] then
    return true
  end

  local n = table.getn(auras)
  if n and n > 0 then
    local i
    for i = 1, n do
      if tonumber(auras[i]) == spellId then
        return true
      end
    end
  end

  if isDebuff then
    local buffs = _GetUnitAuraTable(unit, false)
    if type(buffs) == "table" then
      if buffs[spellId] then
        return true
      end

      local n2 = table.getn(buffs)
      if n2 and n2 > 0 then
        local j
        for j = 1, n2 do
          if tonumber(buffs[j]) == spellId then
            return true
          end
        end
      end
    end
  end

  -- 目标溢出/不可见光环的计时状态回退。
  -- 当光环在单位字段中不可见时（例如超过可见上限）使用。
  if unit == "target" then
    local guid = _GetUnitGuidSafe("target")
    if guid and guid ~= "" and AuraStateByGuid then
      local bucket = AuraStateByGuid[guid]
      local a = bucket and bucket[spellId]
      if a and a.appliedAt and a.fullDur and a.fullDur > 0 then
        local now = (GetTime and GetTime()) or 0
        local rem = (a.fullDur or 0) - (now - (a.appliedAt or now))
        if rem > 0 then
          if isDebuff == nil then
            return true
          end
          local stateIsDebuff = (a.isDebuff == true)
          if stateIsDebuff == (isDebuff == true) then
            return true
          end
        else
          bucket[spellId] = nil
        end
      end
    end
  end

  return false
end

local _GetSpellNameRank

local function _CollectAuraSpellIdsMatchingName(unit, isDebuff, normName, out)
  if not unit or not normName or normName == "" then
    return out
  end

  local auras = _GetUnitAuraTable(unit, isDebuff)
  if type(auras) ~= "table" then
    return out
  end

  out = out or {}

  local function maybeAddSid(rawSid)
    local sid = tonumber(rawSid) or 0
    if sid <= 0 or out[sid] then
      return
    end

    local n = _GetSpellNameRank(sid)
    if _NormSpellName(n) == normName then
      out[sid] = true
    end
  end

  local k
  for k in pairs(auras) do
    maybeAddSid(k)
  end

  local n = table.getn(auras)
  if n and n > 0 then
    local i
    for i = 1, n do
      maybeAddSid(auras[i])
    end
  end

  return out
end

---------------------------------------------------------------
-- 法术名称/等级辅助函数（保持兼容）
---------------------------------------------------------------
_GetSpellNameRank = function(spellId)
  spellId = tonumber(spellId) or 0

  local nameCache = _G["DoiteTrack_SpellNameCache"]
  if not nameCache then
    nameCache = {}
    _G["DoiteTrack_SpellNameCache"] = nameCache
  end

  local rankCache = _G["DoiteTrack_SpellRankCache"]
  if not rankCache then
    rankCache = {}
    _G["DoiteTrack_SpellRankCache"] = rankCache
  end

  local cachedName = nameCache[spellId]
  if cachedName ~= nil then
    if cachedName == false then
      return ("法术 " .. tostring(spellId)), nil
    end
    local cachedRank = rankCache[spellId]
    if cachedRank == false then
      cachedRank = nil
    end
    return cachedName, cachedRank
  end

  local name, rank

  if GetSpellNameAndRankForId then
    local ok, n, r = pcall(GetSpellNameAndRankForId, spellId)
    if ok and n and n ~= "" then
      name = n
      rank = r
    end
  end

  if not name or name == "" then
    nameCache[spellId] = false
    rankCache[spellId] = false
    return ("法术 " .. tostring(spellId)), nil
  end

  nameCache[spellId] = name
  if rank and rank ~= "" then
    rankCache[spellId] = rank
  else
    rankCache[spellId] = false
  end

  return name, rank
end

---------------------------------------------------------------
-- 运行时光环状态（仅我们的，通过 pending+ADDED 确认）
---------------------------------------------------------------
AuraStateByGuid = {} -- [guid] = { [spellId] = { appliedAt, fullDur, cp, isDebuff } }

local function _GetAuraBucketForGuid(guid, create)
  if not guid or guid == "" then
    return nil
  end
  local t = AuraStateByGuid[guid]
  if not t and create then
    t = {}
    AuraStateByGuid[guid] = t
  end
  return t
end

---------------------------------------------------------------
-- 特殊情况：
---------------------------------------------------------------

local _IsPlayerShaman = false
local _MoltenBlastSpellIdCache = {} -- [spellId] = true/false

-- 德鲁伊/潜行者天赋缓存（在登录/进入世界/学习法术标签时设置）
_IsPlayerDruid = false
_IsPlayerRogue = false
local _CarnageRank = 0             -- 德鲁伊：>0 启用 屠戮 触发逻辑
local _TasteForBloodRank = 0       -- 盗贼：0..2，手动割裂，1级+4秒，2级+6秒

-- 德鲁伊 屠戮 触发检测
local _FerociousBiteSpellIdCache = {} -- [spellId] = true/false
local _CarnageWatch = nil            -- { expiresAt, targetGuid, sawZero, lastCP }

-- 将 Flame Shock 跟踪的 ID 缓存为数字数组，以避免在每次熔岩爆裂时进行 pairs/tonumber 工作
local _FlameShockSpellIdsList = nil -- spellId 数组，如果未跟踪则为 nil

-- 缓存撕扯/扫击跟踪的 ID（由 屠戮 刷新使用）
local _RipSpellIdsList = nil  -- 数组
local _RakeSpellIdsList = nil -- 数组

local function _BuildOnlyMineDebuffSpellIdListByNorm(normName)
  local seen = {}
  local list = {}
  local n = 0

  local function addSpellId(sid)
    sid = tonumber(sid) or 0
    if sid <= 0 or seen[sid] then
      return
    end
    seen[sid] = true
    n = n + 1
    list[n] = sid
  end

  do
    local e = TrackedByNameNorm[normName]
    if e and e.onlyMine == true and e.kind == "Debuff" and type(e.spellIds) == "table" then
      local sid
      for sid in pairs(e.spellIds) do
        addSpellId(sid)
      end
    end
  end

  do
    local sid, e
    for sid, e in pairs(TrackedBySpellId) do
      if e and e.onlyMine == true and e.kind == "Debuff" then
        local n0 = _GetSpellNameRank(tonumber(sid) or 0)
        if _NormSpellName(n0) == normName then
          addSpellId(sid)
        end
      end
    end
  end

  if n > 0 then
    return list
  end
  return nil
end

local function _RebuildFlameShockSpellIdsList()
  _FlameShockSpellIdsList = _BuildOnlyMineDebuffSpellIdListByNorm("烈焰震击")
end

local function _RebuildRipRakeSpellIdLists()
  _RipSpellIdsList = _BuildOnlyMineDebuffSpellIdListByNorm("撕扯")
  _RakeSpellIdsList = _BuildOnlyMineDebuffSpellIdListByNorm("扫击")
end

local function _HasTrackedJudgementDebuff()
  if _BuildOnlyMineDebuffSpellIdListByNorm("十字军审判") then
    return true
  end
  if _BuildOnlyMineDebuffSpellIdListByNorm("光明审判") then
    return true
  end
  if _BuildOnlyMineDebuffSpellIdListByNorm("智慧审判") then
    return true
  end
  if _BuildOnlyMineDebuffSpellIdListByNorm("正义审判") then
    return true
  end
  return false
end

local function _IsBadGuid(g)
  return (not g) or g == "" or g == "0x000000000" or g == "0x0000000000000000"
end

local function _TryRefreshFlameShockOnTargetGuid(targetGuid, now)
  if _IsBadGuid(targetGuid) then
    return
  end

  -- 要求此 GUID 实际上是玩家的当前目标，以便玩家可以廉价地验证光环存在。
  local curTargetGuid = _GetUnitGuidSafe("target")
  if _IsBadGuid(curTargetGuid) or curTargetGuid ~= targetGuid then
    return
  end

  if type(_FlameShockSpellIdsList) ~= "table" then
    return
  end

  local bucket = AuraStateByGuid[targetGuid]
  if type(bucket) ~= "table" then
    return
  end

  local i = 1
  while _FlameShockSpellIdsList[i] do
    local sid = _FlameShockSpellIdsList[i]
    -- 火焰震击必须现在存在
    if _AuraHasSpellId("target", sid, true) then
      local a = bucket[sid]
      if a and a.appliedAt and a.fullDur and a.fullDur > 0 then
        local age = now - (a.appliedAt or now)
        if age >= 0 and age <= (a.fullDur + 0.25) then
          a.appliedAt = now
          a.lastSeen = now
        end
      end
    else
      bucket[sid] = nil
    end
    i = i + 1
  end
end

---------------------------------------------------------------
-- 德鲁伊/潜行者天赋 + 德鲁伊 屠戮 刷新辅助函数
---------------------------------------------------------------
local function _UpdateTalentCaches()
  _CarnageRank = 0
  _TasteForBloodRank = 0

  if not UnitClass then
    _IsPlayerDruid = false
    _IsPlayerRogue = false
    return
  end

  local _, cls = UnitClass("player")
  cls = cls and string.upper(cls) or ""
  _IsPlayerDruid = (cls == "DRUID")
  _IsPlayerRogue = (cls == "ROGUE")

  if (not _IsPlayerDruid) and (not _IsPlayerRogue) then
    return
  end

  if (not GetTalentInfo) or (not GetNumTalentTabs) or (not GetNumTalents) then
    return
  end

  local needCarnage = _IsPlayerDruid
  local needTaste = _IsPlayerRogue

  local numTabs = tonumber(GetNumTalentTabs()) or 0
  local tab
  for tab = 1, numTabs do
    local numTal = tonumber(GetNumTalents(tab)) or 0
    local i
    for i = 1, numTal do
      local name, _, _, _, rank = GetTalentInfo(tab, i)
      if name and name ~= "" then
        local norm = _NormSpellName(name)
        if needCarnage and norm == "屠戮" then
          _CarnageRank = tonumber(rank) or 0
          needCarnage = false
        end
        if needTaste and norm == "血腥气息" then
          _TasteForBloodRank = tonumber(rank) or 0
          needTaste = false
        end
        if (not needCarnage) and (not needTaste) then
          return
        end
      end
    end
  end
end

local function _TryRefreshRipRakeOnTargetGuid(targetGuid, now)
  if _IsBadGuid(targetGuid) then
    return
  end

  -- 要求当前目标匹配，以便玩家可以廉价地验证光环存在。
  local curTargetGuid = _GetUnitGuidSafe("target")
  if _IsBadGuid(curTargetGuid) or curTargetGuid ~= targetGuid then
    return
  end

  if (type(_RipSpellIdsList) ~= "table") and (type(_RakeSpellIdsList) ~= "table") then
    return
  end

  local bucket = AuraStateByGuid[targetGuid]
  if type(bucket) ~= "table" then
    return
  end

  local function refreshList(list)
    if type(list) ~= "table" then
      return
    end
    local i = 1
    while list[i] do
      local sid = list[i]
      -- 撕扯/斜掠必须现在存在
      if _AuraHasSpellId("target", sid, true) then
        local a = bucket[sid]
        if a and a.appliedAt and a.fullDur and a.fullDur > 0 then
          local age = now - (a.appliedAt or now)
          if age >= 0 and age <= (a.fullDur + 0.25) then
            a.appliedAt = now
            a.lastSeen = now
          end
        end
      else
        bucket[sid] = nil
      end
      i = i + 1
    end
  end

  refreshList(_RipSpellIdsList)
  refreshList(_RakeSpellIdsList)
end

function DoiteTrack:_OnUnitComboPoints()
  if arg1 and arg1 ~= "player" then
    return
  end
  if not _CarnageWatch then
    return
  end

  local now = GetTime and GetTime() or 0
  if now > (_CarnageWatch.expiresAt or 0) then
    _CarnageWatch = nil
    return
  end

  local cpNow = _GetComboPointsSafe()

  -- 玩家只接受在玩家观察到 CP 为 0 后发生的增益。
  if not _CarnageWatch.sawZero then
    if cpNow == 0 then
      _CarnageWatch.sawZero = true
      _CarnageWatch.lastCP = 0
    else
      _CarnageWatch.lastCP = cpNow
    end
    return
  end

  if (_CarnageWatch.lastCP or 0) == 0 and cpNow > 0 then
    _TryRefreshRipRakeOnTargetGuid(_CarnageWatch.targetGuid, now)
    _CarnageWatch = nil
    return
  end

  _CarnageWatch.lastCP = cpNow
end

function DoiteTrack:_OnLearnedSpellInTab()
  -- 天赋可能已更改；重新扫描并更新事件需求。
  _UpdateTalentCaches()
  self:_RecomputeEventNeeds()
  self:_ApplyEventRegistration()
end

---------------------------------------------------------------
-- 待处理应用缓存（全局，以避免在其他地方引起上值爆炸）
-- 结构（避免字符串键搅动）：
--   pend[spellId][targetGuid] = { t=now, dur=secRounded 或 nil, cp=cp 或 0, kind="Buff"/"Debuff", nameNorm="撕扯" }
---------------------------------------------------------------

local function _GetPendingTable()
  local p = _G["DoiteTrack_NPPending"]
  if not p then
    p = {}
    _G["DoiteTrack_NPPending"] = p
  end
  return p
end

---------------------------------------------------------------
-- NP 调试 + 去重打印
---------------------------------------------------------------
_G["DoiteTrack_SetNPDebug"] = function(on)
  _G["DoiteTrack_NPDebug"] = (on and true or false)
  if _G["DoiteTrack_NPDebug"] then
    _Print("|cff6FA8DCDoiteAuras:|r 调试 |cffffff00开启|r")
  else
    _Print("|cff6FA8DCDoiteAuras:|r 调试 |cffffff00关闭|r")
  end
end

local function _NP_DedupAllow(spellId, targetGuid, durationMs, cpVal, manualSec)
  local d = _G["DoiteTrack_NPDedup"]
  if not d then
    d = {}
    _G["DoiteTrack_NPDedup"] = d
  end

  local now = GetTime and GetTime() or 0
  local k =
    tostring(event or "AURA_CAST") .. ":" ..
    tostring(tonumber(spellId) or 0) .. ":" ..
    tostring(targetGuid or "") .. ":" ..
    tostring(tonumber(durationMs) or 0) .. ":" ..
    tostring(tonumber(cpVal) or 0) .. ":" ..
    tostring(tonumber(manualSec) or 0)

  local last = d[k]
  if last and (now - last) < 0.15 then
    return false
  end
  d[k] = now
  return true
end

local function _NP_PrintLine(spellId, spellName, spellNorm, targetGuid, durationMs, tracked, cpVal, manualSec)
  if not _G["DoiteTrack_NPDebug"] then
    return
  end
  if not _NP_DedupAllow(spellId, targetGuid, durationMs, cpVal, manualSec) then
    return
  end

  local tag = tracked and "tracked" or "untracked"
  local en = tostring(event or "AURA_CAST")

  local cpStr = "no"
  if type(cpVal) == "number" and cpVal > 0 then
    cpStr = "cp=" .. tostring(cpVal)
  end

  local manualStr = "no"
  if type(manualSec) == "number" and manualSec > 0 then
    manualStr = "manual=" .. tostring(manualSec)
  end

  if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
    DEFAULT_CHAT_FRAME:AddMessage(string.format(
      "%s [%s] sid=%d name=%s norm=%s tgt=%s durMs=%d %s %s",
      en,
      tag,
      tonumber(spellId) or 0,
      tostring(spellName or ""),
      tostring(spellNorm or ""),
      tostring(targetGuid or ""),
      tonumber(durationMs) or 0,
      cpStr,
      manualStr
    ))
  end
end

---------------------------------------------------------------
-- 基线持续时间获取器（NP 数据库 + 手动覆盖）
---------------------------------------------------------------
local function _WarnMissingManualDuration(spellName, spellRank, spellId)
  if not DEFAULT_CHAT_FRAME or not DEFAULT_CHAT_FRAME.AddMessage then
    return
  end

  local blue = "|cff6FA8DC" -- #6FA8DC = DoiteAuras 颜色 - 个人笔记
  local yellow = "|cffffff00"
  local white = "|cffffffff"
  local reset = "|r"

  local n = tostring(spellName or "")
  local r = tostring(spellRank or "")
  local label = n
  if r ~= "" then
    label = label .. " " .. r
  end

  DEFAULT_CHAT_FRAME:AddMessage(
    blue .. "[DoiteAuras]:" .. reset .. " " ..
    yellow .. label .. reset .. " " ..
    white .. "法术 ID " .. reset .. " " ..
    yellow .. tostring(tonumber(spellId) or 0) .. reset .. " " .. reset ..
    white .. "没有记录持续时间，也不存在于手动表格中。请向 Doite 报告。" .. reset
  )
end

local function _GetManualDurationBySpellId(spellId, cp)
  local v = ManualDurationBySpellId[spellId]
  if type(v) == "number" then
    if v > 0 then
      return v
    end
    return nil
  end

  if type(v) == "table" then
    if cp and cp > 0 then
      local sec = v[cp]
      if type(sec) == "number" and sec > 0 then
        return sec
      end
    end
    return nil
  end

  return nil
end

local function _CommitNPDuration(spellId, cp, secRounded, name, rank, durationMs)
  if not spellId or spellId <= 0 then
    return
  end
  if not secRounded or secRounded <= 0 then
    return
  end

  local db = _GetDB()

  if cp and cp > 0 then
    db.npDurationsCP[spellId] = db.npDurationsCP[spellId] or {}
    db.npDurationsCP[spellId][cp] = secRounded
  else
    db.npDurations[spellId] = secRounded
  end

  local meta = db.npDurationsMeta[spellId]
  if not meta then
    meta = { samples = 0 }
    db.npDurationsMeta[spellId] = meta
  end

  meta.samples = (meta.samples or 0) + 1
  meta.lastMs = tonumber(durationMs) or nil
  meta.lastAt = (GetTime and GetTime() or 0)
  if name and name ~= "" then
    meta.name = name
  end
  if rank and rank ~= "" then
    meta.rank = rank
  end
end

function DoiteTrack:_RecomputeEventNeeds()
  -- NP 事件：仅在有任何 onlyMine 条目时需要（计时器是我们自己的）
  local hasMine = false
  local _, e

  for _, e in pairs(TrackedBySpellId) do
    if e and e.onlyMine == true then
      hasMine = true
      break
    end
  end

  if not hasMine then
    for _, e in pairs(TrackedByNameNorm) do
      if e and e.onlyMine == true then
        hasMine = true
        break
      end
    end
  end

  self._hasTracked = hasMine

  -- 如果需要 SPELL_CAST_EVENT：
  --  a) 任何基于 CP 的手动持续时间存在（用于 CP 快照）
  --  b) 萨满熔岩爆裂刷新相关
  --  c) 德鲁伊 屠戮 触发检测活跃（凶猛撕咬 -> CP 增益窗口）
  local needCP = false
  if _IsPlayerDruid or _IsPlayerRogue then
    local _, v
    for _, v in pairs(ManualDurationBySpellId) do
      if type(v) == "table" then
        needCP = true
        break
      end
    end
  end

  local needMB = false
  if _IsPlayerShaman then
    needMB = (type(_FlameShockSpellIdsList) == "table")
  end

  local needCarnage = false
  if _IsPlayerDruid and _CarnageRank and _CarnageRank > 0 then
    if type(_RipSpellIdsList) == "table" or type(_RakeSpellIdsList) == "table" then
      needCarnage = true
    end
  end

  ----------------------------------------------------------------
  -- 圣骑士 SC：审判跟踪（圣印 -> 审判减益）
  -- 仅当玩家是圣骑士并且正在跟踪任何审判减益（onlyMine）时参与。
  -- 运行时“模式”（圣印已见 / 审判待定/活跃）存在于 _G["DoiteTrack_PalJ"] 中。
  ----------------------------------------------------------------
  local palTracked = false
  if _G["DoiteTrack_IsPaladin"] == true then
    palTracked = _HasTrackedJudgementDebuff()
  end

  _G["DoiteTrack_PalJ_Tracked"] = (palTracked and true or false)

  local pj = nil
  local palMode = false
  local palActive = false

  if palTracked then
    pj = _G["DoiteTrack_PalJ"]
    if type(pj) ~= "table" then
      pj = {}
      _G["DoiteTrack_PalJ"] = pj
    end

    -- 模式意味着：相关的圣印已见 或 审判待定/活跃
    palMode = (pj.mode == true) and true or false

    -- 活跃意味着：在目标上确认了一个审判，可以在命中时刷新
    if pj.activeTargetGuid and pj.activeTargetGuid ~= "" and pj.activeSpellId and (tonumber(pj.activeSpellId) or 0) > 0 and pj.activeDur and pj.activeDur > 0 then
      palActive = true
    end
  end

  -- SPELL_CAST_EVENT 需要用于：
  --  a) 手动 CP 表的 CP 快照
  --  b) 德鲁伊 屠戮 触发检测（凶猛撕咬监视）
  --  c) 圣骑士审判施放关联（仅在 palMode 时）
  self._needSpellCastEvent = (needCP or needCarnage or palMode)

  -- SPELL_DAMAGE_EVENT_SELF 需要用于：
  --  萨满熔岩爆裂 -> 火焰震击刷新（击中/生效时，而非施法开始）
  --  圣骑士对特定伤害法术的审判刷新（仅在 palActive 时）
  self._needSpellDamageEventSelf = ((needMB or palActive) and true or false)

  -- AUTO_ATTACK_SELF 仅用于圣骑士审判刷新（仅在 palActive 时）
  self._needAutoAttackSelf = (palActive and true or false)

  -- 移除光环事件仅用于圣骑士审判停止逻辑 / 圣印取消（仅在 palMode 时）
  self._needAuraRemoved = (palMode and true or false)

  self._needUnitComboPoints = needCarnage

  -- 仅当 API 存在且职业相关时才注册天赋更改事件。
  self._needTalentEvent = (_IsPlayerDruid or _IsPlayerRogue) and true or false
end

---------------------------------------------------------------
-- 事件处理程序
---------------------------------------------------------------
function DoiteTrack:_TryHookDoiteAurasRefreshIcons()
  if _G["DoiteTrack_Orig_DoiteAuras_RefreshIcons"] then
    return
  end

  local f = _G["DoiteAuras_RefreshIcons"]
  if type(f) ~= "function" then
    return
  end

  _G["DoiteTrack_Orig_DoiteAuras_RefreshIcons"] = f
  _G["DoiteAuras_RefreshIcons"] = _G["DoiteTrack_DoiteAuras_RefreshIcons_Hook"]
end

function DoiteTrack:_OnDoiteAurasConfigChanged()
  -- 完全重新扫描 DoiteAuras 配置 -> 重建跟踪映射 + 缓存列表 + 事件需求
  self:RebuildWatchList()

  -- 重建 Flame Shock 法术 ID 列表缓存（用于熔岩爆裂特殊情况）
  _RebuildFlameShockSpellIdsList()

  -- 重建撕扯/扫击法术 ID 列表（用于 屠戮 刷新）
  _RebuildRipRakeSpellIdLists()

  self:_RecomputeEventNeeds()
  self:_ApplyEventRegistration()
end

function DoiteTrack:_OnPlayerLogin()
  -- 初始化一次，但允许在 PLAYER_ENTERING_WORLD（天赋/标志）上重新扫描。
  local firstInit = (not self._didInit)

  if firstInit then
    self._didInit = true

    UnitExists = _G.UnitExists
    GetUnitField = _G.GetUnitField
    GetSpellNameAndRankForId = _G.GetSpellNameAndRankForId
    UnitClass = _G.UnitClass
    GetComboPoints = _G.GetComboPoints

    -- 天赋
    GetTalentInfo = _G.GetTalentInfo
    GetNumTalentTabs = _G.GetNumTalentTabs
    GetNumTalents = _G.GetNumTalents

    -- Nampower：启用 AuraCast 事件
    local SetCVar = _G.SetCVar
    if SetCVar then
      pcall(SetCVar, "NP_EnableAuraCastEvents", "1")
    end

    _playerGUID_cached = nil
    _GetPlayerGUID()

    -- 缓存萨满标志，用于熔岩爆裂 -> 火焰震击刷新
    _IsPlayerShaman = false

    -- 圣骑士标志，用于审判特殊情况
    _G["DoiteTrack_IsPaladin"] = false

    if UnitClass then
      local _, cls = UnitClass("player")
      cls = cls and string.upper(cls) or ""
      if cls == "SHAMAN" then
        _IsPlayerShaman = true
      end
      if cls == "PALADIN" then
        _G["DoiteTrack_IsPaladin"] = true
      end
    end

    self:RebuildWatchList()

    -- 重建 Flame Shock 法术 ID 列表缓存（用于熔岩爆裂特殊情况）
    _RebuildFlameShockSpellIdsList()

    -- 重建撕扯/扫击法术 ID 列表（用于 屠戮 刷新）
    _RebuildRipRakeSpellIdLists()
  end

  -- 总是在 LOGIN + ENTERING_WORLD 上刷新天赋缓存（廉价；无轮询）。
  _UpdateTalentCaches()

  -- 在监视列表/天赋刷新后重新计算事件需求
  self:_RecomputeEventNeeds()
  self:_ApplyEventRegistration()
  self:_TryHookDoiteAurasRefreshIcons()
end

-- SPELL_DAMAGE_EVENT_SELF
-- 参数（根据 Nampower 指南）：
--  arg1=targetGuid, arg2=casterGuid, arg3=spellId, arg4=amount,
--  arg5=mitigationStr "absorb,block,resist", arg6=hitInfo, arg7=spellSchool, arg8=effectAuraStr
function DoiteTrack:_OnSpellDamageEventSelf()
  ----------------------------------------------------------------
  -- 萨满 SC：熔岩爆裂 -> 刷新火焰震击（现有逻辑）
  ----------------------------------------------------------------
  if _IsPlayerShaman then
    -- 守卫：仅当跟踪了火焰震击（onlyMine 减益）时才运行
    if type(_FlameShockSpellIdsList) ~= "table" then
      return
    end

    local targetGuid = arg1
    local casterGuid = arg2
    local spellId = tonumber(arg3) or 0

    if spellId <= 0 then
      return
    end

    local pGuid = _GetPlayerGUID()
    if not pGuid or not casterGuid or casterGuid == "" or casterGuid ~= pGuid then
      return
    end

    -- 通过规范化法术名称识别熔岩爆裂（等级无关）
    local isMB = _MoltenBlastSpellIdCache[spellId]
    if isMB == nil then
      local n = _GetSpellNameRank(spellId)
      local norm = _NormSpellName(n)
      isMB = (norm == "熔岩爆裂") and true or false
      _MoltenBlastSpellIdCache[spellId] = isMB
    end

    if not isMB then
      return
    end

    -- 目标 GUID 健全性
    if _IsBadGuid(targetGuid) then
      targetGuid = _GetUnitGuidSafe("target")
    end
    if _IsBadGuid(targetGuid) then
      return
    end

    -- 守卫：仅在火焰震击是玩家的时运行
    local bucket = AuraStateByGuid[targetGuid]
    if type(bucket) ~= "table" then
      return
    end

    -- 现在刷新（此函数还需要当前目标 GUID 匹配 + 光环存在）
    local now = GetTime and GetTime() or 0
    _TryRefreshFlameShockOnTargetGuid(targetGuid, now)
    return
  end

  ----------------------------------------------------------------
  -- 圣骑士 SC：在（十字军打击 / 神圣打击）上刷新活跃的审判
  ----------------------------------------------------------------
  local pj = _G["DoiteTrack_PalJ"]
  if type(pj) ~= "table" then
    return
  end

  local tGuid = pj.activeTargetGuid
  local jSid = tonumber(pj.activeSpellId) or 0
  local dur = pj.activeDur

  if not tGuid or tGuid == "" or jSid <= 0 or not dur or dur <= 0 then
    return
  end

  local targetGuid = arg1
  local casterGuid = arg2
  local spellId = tonumber(arg3) or 0
  local amount = tonumber(arg4) or 0

  if amount <= 0 or spellId <= 0 then
    return
  end

  local pGuid = _GetPlayerGUID()
  if not pGuid or not casterGuid or casterGuid == "" or casterGuid ~= pGuid then
    return
  end

  if not targetGuid or targetGuid == "" or targetGuid ~= tGuid then
    return
  end

  -- 通过规范化名称识别允许的刷新法术
  local cache = _G["DoiteTrack_PalJ_HitSpellCache"]
  if type(cache) ~= "table" then
    cache = {}
    _G["DoiteTrack_PalJ_HitSpellCache"] = cache
  end

  local ok = cache[spellId]
  if ok == nil then
    local n = _GetSpellNameRank(spellId)
    local norm = _NormSpellName(n)
    ok = ((norm == "十字军打击") or (norm == "神圣打击")) and true or false
    cache[spellId] = ok
  end

  if not ok then
    return
  end

  local now = GetTime and GetTime() or 0
  local bucket = _GetAuraBucketForGuid(tGuid, true)
  if not bucket then
    return
  end

  local a = bucket[jSid]
  if not a then
    a = {}
    bucket[jSid] = a
  end

  a.appliedAt = now
  a.lastSeen = now
  a.fullDur = dur
  a.cp = 0
  a.isDebuff = true
end

function DoiteTrack:_OnAutoAttackSelf()
  local pj = _G["DoiteTrack_PalJ"]
  if type(pj) ~= "table" then
    return
  end

  local tGuid = pj.activeTargetGuid
  local sid = tonumber(pj.activeSpellId) or 0
  local dur = pj.activeDur

  if not tGuid or tGuid == "" or sid <= 0 or not dur or dur <= 0 then
    return
  end

  local attackerGuid = arg1
  local targetGuid = arg2
  local totalDamage = tonumber(arg3) or 0

  if totalDamage <= 0 then
    return
  end

  local pGuid = _GetPlayerGUID()
  if not pGuid or not attackerGuid or attackerGuid == "" or attackerGuid ~= pGuid then
    return
  end

  if not targetGuid or targetGuid == "" or targetGuid ~= tGuid then
    return
  end

  local now = GetTime and GetTime() or 0
  local bucket = _GetAuraBucketForGuid(tGuid, true)
  if not bucket then
    return
  end

  local a = bucket[sid]
  if not a then
    a = {}
    bucket[sid] = a
  end

  a.appliedAt = now
  a.lastSeen = now
  a.fullDur = dur
  a.cp = 0
  a.isDebuff = true
end

-- SPELL_CAST_EVENT
function DoiteTrack:_OnSpellCastEvent()
  local success = arg1
  local spellId = tonumber(arg2) or 0
  local targetGuid = arg4

  if success ~= 1 or spellId <= 0 then
    return
  end

  local pGuid = _GetPlayerGUID()
  if not pGuid then
    return
  end

  -- 德鲁伊 SC：屠戮 触发检测（凶猛撕咬 -> 0.5 秒内的 CP 增益刷新目标上的撕扯/斜掠）
  if _IsPlayerDruid and _CarnageRank and _CarnageRank > 0 then
    if type(_RipSpellIdsList) == "table" or type(_RakeSpellIdsList) == "table" then
      local isFB = _FerociousBiteSpellIdCache[spellId]
      if isFB == nil then
        local n = _GetSpellNameRank(spellId)
        local norm = _NormSpellName(n)
        isFB = (norm == "凶猛撕咬") and true or false
        _FerociousBiteSpellIdCache[spellId] = isFB
      end

      if isFB then
        local now = GetTime and GetTime() or 0

        -- 凶猛撕咬是有害的；优先使用实际的目标 GUID
        if _IsBadGuid(targetGuid) then
          targetGuid = _GetUnitGuidSafe("target")
        end

        if not _IsBadGuid(targetGuid) then
          local cpNow = _GetComboPointsSafe()
          _CarnageWatch = {
            expiresAt = now + 0.5,
            targetGuid = targetGuid,
            sawZero = (cpNow == 0) and true or false,
            lastCP = cpNow,
          }
        end
      end
    end
  end

  ----------------------------------------------------------------
  -- 圣骑士 SC：当活跃的跟踪圣印存在时，关联审判施放
  -- 不要依赖 AURA_CAST_ON_OTHER 来获取产生的减益。
  -- 仅在此处设置“pending”；确认发生在 BUFF/DEBUFF_ADDED_OTHER 上。
  ----------------------------------------------------------------
  if _G["DoiteTrack_IsPaladin"] == true and _G["DoiteTrack_PalJ_Tracked"] == true then
    local pj = _G["DoiteTrack_PalJ"]
    if type(pj) == "table" and pj.mode == true and pj.sealToken and pj.sealToken ~= "" then
      local isJ = nil
      do
        local n = _GetSpellNameRank(spellId)
        local norm = _NormSpellName(n)
        if norm == "审判" then
          isJ = true
        else
          isJ = false
        end
      end

      if isJ then
        local now = GetTime and GetTime() or 0

        if _IsBadGuid(targetGuid) then
          targetGuid = _GetUnitGuidSafe("target")
        end
        if not _IsBadGuid(targetGuid) then
          pj.pendingTargetGuid = targetGuid
          pj.pendingToken = pj.sealToken
          pj.pendingExpiresAt = now + 1.75
        end
      end
    end
  end

  -- 只关心跟踪的法术（onlyMine）用于 CP 快照行为
  local entry = TrackedBySpellId[spellId]
  if (not entry) then
    local n = _GetSpellNameRank(spellId)
    local nn = _NormSpellName(n)
    if nn then
      entry = TrackedByNameNorm[nn]
    end
  end

  if not entry or entry.onlyMine ~= true then
    return
  end

  -- 从 NP 事件解析目标，回退到当前目标。
  if _IsBadGuid(targetGuid) then
    local tg = _GetUnitGuidSafe("target")
    if not tg or tg == "" then
      return
    end
    targetGuid = tg
  end

  -- 仅当此法术 ID 有 CP 表手动条目时才快照 CP
  if type(ManualDurationBySpellId[spellId]) ~= "table" then
    return
  end

  local name, rank = _GetSpellNameRank(spellId)
  local norm = _NormSpellName(name)
  if not norm then
    return
  end


  local cp = 0
  if _PlayerUsesComboPoints() then
    cp = _GetComboPointsSafe()
  end

  local pend = _GetPendingTable()
  pend[spellId] = pend[spellId] or {}
  local t = pend[spellId]

  t[targetGuid] = t[targetGuid] or {}
  local p = t[targetGuid]

  p.confirmAt = nil
  p.dur = nil

  p.t = (GetTime and GetTime() or 0)
  p.cp = cp or 0
  p.kind = entry.kind
  p.nameNorm = norm
end

-- 组合处理程序：
--  AURA_CAST_ON_SELF/OTHER：捕获 durationMs + 设置 pending.dur
--  BUFF/DEBUFF_ADDED_SELF/OTHER：确认应用 -> 如果 pending 存在则启动计时器
function DoiteTrack:_OnAuraNPEvent()
  ----------------------------------------------------------------
  -- 0) 圣骑士 SC：在 REMOVED 事件上停止逻辑（仅在 palMode 时注册）
  -- 处理减益槽位和增益槽位（16 上限溢出）移除。
  ----------------------------------------------------------------
  if event == "BUFF_REMOVED_SELF" or event == "BUFF_REMOVED_OTHER" or event == "DEBUFF_REMOVED_OTHER" then
    if _G["DoiteTrack_IsPaladin"] == true and _G["DoiteTrack_PalJ_Tracked"] == true then
      local pj = _G["DoiteTrack_PalJ"]
      if type(pj) == "table" then
        local guid = arg1
        local spellId = tonumber(arg3) or 0
        if spellId <= 0 or not guid or guid == "" then
          return
        end

        local now = GetTime and GetTime() or 0

        -- 从玩家身上移除圣印：清除圣印令牌/spellId；如果无待定/活跃，则关闭模式。
        if event == "BUFF_REMOVED_SELF" then
          local pGuid = _GetPlayerGUID()
          if pGuid and guid == pGuid then
            local sealSid = tonumber(pj.sealSpellId) or 0
            if sealSid > 0 and spellId == sealSid then
              pj.sealSpellId = nil
              pj.sealToken = nil

              -- 如果没有活跃的审判且没有有效的待定，则禁用模式。
              local hasActive = false
              if pj.activeTargetGuid and pj.activeTargetGuid ~= "" and pj.activeSpellId and (tonumber(pj.activeSpellId) or 0) > 0 and pj.activeDur and pj.activeDur > 0 then
                hasActive = true
              end

              local hasPending = false
              if pj.pendingTargetGuid and pj.pendingTargetGuid ~= "" and pj.pendingToken and pj.pendingToken ~= "" then
                if (pj.pendingExpiresAt or 0) >= now then
                  hasPending = true
                else
                  pj.pendingTargetGuid = nil
                  pj.pendingToken = nil
                  pj.pendingExpiresAt = nil
                end
              end

              if (not hasActive) and (not hasPending) then
                pj.mode = false
              else
                pj.mode = true
              end

              self:_RecomputeEventNeeds()
              self:_ApplyEventRegistration()
            end
          end
          return
        end

        -- 从目标上移除审判：停止活跃跟踪（增益槽位或减益槽位）。
        do
          local aGuid = pj.activeTargetGuid
          local aSid = tonumber(pj.activeSpellId) or 0
          if aGuid and aGuid ~= "" and aSid > 0 and guid == aGuid and spellId == aSid then
            local bucket0 = AuraStateByGuid[aGuid]
            if bucket0 then
              bucket0[aSid] = nil
            end

            pj.activeTargetGuid = nil
            pj.activeSpellId = nil
            pj.activeDur = nil

            -- 如果没有圣印且没有待定，则完全禁用模式。
            local hasPending = false
            if pj.pendingTargetGuid and pj.pendingTargetGuid ~= "" and pj.pendingToken and pj.pendingToken ~= "" then
              if (pj.pendingExpiresAt or 0) >= now then
                hasPending = true
              else
                pj.pendingTargetGuid = nil
                pj.pendingToken = nil
                pj.pendingExpiresAt = nil
              end
            end

            if (not pj.sealToken or pj.sealToken == "") and (not hasPending) then
              pj.mode = false
            else
              pj.mode = true
            end

            self:_RecomputeEventNeeds()
            self:_ApplyEventRegistration()
          end
        end
      end
    end
    return
  end

  ----------------------------------------------------------------
  -- 1) 通过 BUFF/DEBUFF_ADDED_* 确认应用（启动计时器）
  ----------------------------------------------------------------
  if event == "BUFF_ADDED_SELF" or event == "BUFF_ADDED_OTHER" or event == "DEBUFF_ADDED_SELF" or event == "DEBUFF_ADDED_OTHER" then
    local guid = arg1
    local spellId = tonumber(arg3) or 0

    if spellId <= 0 or not guid or guid == "" then
      return
    end

    local now = GetTime and GetTime() or 0

    ----------------------------------------------------------------
    -- 圣骑士 SC：确认审判应用（不要依赖 AURA_CAST_ON_OTHER）
    -- 所有跟踪的审判持续时间硬编码为 10 秒。
    -- 也支持增益槽位溢出（BUFF_ADDED_OTHER）。
    ----------------------------------------------------------------
    if (event == "BUFF_ADDED_OTHER" or event == "DEBUFF_ADDED_OTHER") and _G["DoiteTrack_IsPaladin"] == true and _G["DoiteTrack_PalJ_Tracked"] == true then
      local pj = _G["DoiteTrack_PalJ"]
      if type(pj) == "table" and pj.pendingTargetGuid and pj.pendingTargetGuid ~= "" and pj.pendingToken and pj.pendingToken ~= "" then
        if pj.pendingTargetGuid == guid then
          if (pj.pendingExpiresAt or 0) < now then
            pj.pendingTargetGuid = nil
            pj.pendingToken = nil
            pj.pendingExpiresAt = nil
          else
            local n = _GetSpellNameRank(spellId)
            local norm = _NormSpellName(n)

            local match = false
            if norm then
              if pj.pendingToken == "crusader" then
                match = (norm == "十字军审判")
              elseif pj.pendingToken == "light" then
                match = (norm == "光明审判")
              elseif pj.pendingToken == "wisdom" then
                match = (norm == "智慧审判")
              elseif pj.pendingToken == "justice" then
                match = (norm == "正义审判")
              end
            end

            if match then
              -- 确保此法术 ID 被连接到跟踪映射中，如果用户仅按名称跟踪。
              if not TrackedBySpellId[spellId] and norm then
                local byN = TrackedByNameNorm[norm]
                if byN and byN.onlyMine == true and byN.kind == "Debuff" then
                  byN.spellIds = byN.spellIds or {}
                  if not byN.spellIds[spellId] then
                    byN.spellIds[spellId] = true
                  end
                  TrackedBySpellId[spellId] = byN
                end
              end

              -- 清除任何先前活跃的审判状态
              do
                local oldT = pj.activeTargetGuid
                local oldS = tonumber(pj.activeSpellId) or 0
                if oldT and oldT ~= "" and oldS > 0 then
                  if oldT ~= guid or oldS ~= spellId then
                    local b0 = AuraStateByGuid[oldT]
                    if b0 then
                      b0[oldS] = nil
                    end
                  end
                end
              end

              pj.activeTargetGuid = guid
              pj.activeSpellId = spellId
              pj.activeDur = 10
              pj.mode = true

              pj.pendingTargetGuid = nil
              pj.pendingToken = nil
              pj.pendingExpiresAt = nil

              local bucket = _GetAuraBucketForGuid(guid, true)
              if bucket then
                local a = bucket[spellId]
                if not a then
                  a = {}
                  bucket[spellId] = a
                end
                a.appliedAt = now
                a.lastSeen = now
                a.fullDur = 10
                a.cp = 0
                a.isDebuff = true
              end

              self:_RecomputeEventNeeds()
              self:_ApplyEventRegistration()
              return
            end
          end
        end
      end
    end

    ----------------------------------------------------------------
    -- 正常（现有）确认路径，用于跟踪的 onlyMine 光环
    ----------------------------------------------------------------
    local entry = TrackedBySpellId[spellId]
    if not entry or entry.onlyMine ~= true then
      return
    end

    -- 允许先确认（刷新/顺序差异）
    local pend = _GetPendingTable()
    local t = pend[spellId]
    if not t then
      return
    end

    local p = t[guid]
    if not p then
      return
    end

    p.confirmAt = now
    p.kind = entry.kind
    p.nameNorm = p.nameNorm or entry.normName

    -- 如果玩家已经从 AURA_CAST 获得了持续时间，现在（重新）启动计时器
    if p.dur and p.dur > 0 then
      local bucket = _GetAuraBucketForGuid(guid, true)
      if not bucket then
        t[guid] = nil
        return
      end

      local a = bucket[spellId]
      if not a then
        a = {}
        bucket[spellId] = a
      end

      a.appliedAt = now
      a.fullDur = p.dur
      a.cp = p.cp or 0
      a.isDebuff = (entry.kind == "Debuff")

      -- 成功启动后消耗 pending
      t[guid] = nil
    end
    return
  end

  ----------------------------------------------------------------
  -- 2) AURA_CAST_ON_SELF/OTHER：捕获 durationMs + 存储基线
  ----------------------------------------------------------------
  local spellId = tonumber(arg1) or 0
  local casterGuid = arg2
  local targetGuid = arg3
  local durationMs = tonumber(arg8) or 0
  local auraCapStatus = tonumber(arg9) or 0

  if spellId <= 0 then
    return
  end

  local pGuid = _GetPlayerGUID()
  if not pGuid or not casterGuid or casterGuid == "" or casterGuid ~= pGuid then
    return
  end

  -- 从 spellId 派生名称
  local spellName, spellRank = _GetSpellNameRank(spellId)
  local spellNameNorm = _NormSpellName(spellName)

  ----------------------------------------------------------------
  -- 圣骑士 SC：通过 AURA_CAST_ON_SELF 检测相关的圣印应用在自身
  -- 这启用了审判关联模式（SPELL_CAST_EVENT + 移除事件）。
  ----------------------------------------------------------------
  if event == "AURA_CAST_ON_SELF" and _G["DoiteTrack_IsPaladin"] == true and _G["DoiteTrack_PalJ_Tracked"] == true then
    local token = nil
    if spellNameNorm == "十字军圣印" then
      token = "crusader"
    elseif spellNameNorm == "光明圣印" then
      token = "light"
    elseif spellNameNorm == "智慧圣印" then
      token = "wisdom"
    elseif spellNameNorm == "正义圣印" then
      token = "justice"
    end

    if token then
      local pj = _G["DoiteTrack_PalJ"]
      if type(pj) ~= "table" then
        pj = {}
        _G["DoiteTrack_PalJ"] = pj
      end

      pj.mode = true
      pj.sealToken = token
      pj.sealSpellId = spellId

      self:_RecomputeEventNeeds()
      self:_ApplyEventRegistration()
    end
  end

  -- 解析跟踪的条目（先 spellId，然后名称）
  local entry = TrackedBySpellId[spellId]
  local byN = nil
  if spellNameNorm then
    byN = TrackedByNameNorm[spellNameNorm]
  end

  -- 始终用发现的 spellId 播种名称跟踪的 onlyMine 条目，即使严格的 Addedviaspellid 条目已经占据 TrackedBySpellId[spellId]。
  -- 这保持了混合设置中名称跟踪图标的正确所有权/剩余逻辑。
  if byN and byN.onlyMine == true then
    byN.spellIds = byN.spellIds or {}
    if not byN.spellIds[spellId] then
      byN.spellIds[spellId] = true
    end

    if not entry then
      entry = byN
      TrackedBySpellId[spellId] = entry
    end

    -- 当玩家通过名称发现新等级时，保持 Flame Shock 等级列表缓存同步。
    if _IsPlayerShaman and spellNameNorm == "烈焰震击" and byN.kind == "Debuff" then
      if type(_FlameShockSpellIdsList) ~= "table" then
        _FlameShockSpellIdsList = {}
      end
      local i = 1
      while _FlameShockSpellIdsList[i] do
        if _FlameShockSpellIdsList[i] == spellId then
          i = nil
          break
        end
        i = i + 1
      end
      if i then
        _FlameShockSpellIdsList[i] = spellId
      end
    end
  end

  -- *在条目存在之后* 修复无效/零 targetGuid。
  if _IsBadGuid(targetGuid) then
    local selfOnly = false

    if event == "AURA_CAST_ON_SELF" then
      selfOnly = true
    end

    if selfOnly then
      targetGuid = pGuid
    else
      local tg = _GetUnitGuidSafe("target")
      if tg and tg ~= "" then
        targetGuid = tg
      else
        -- 最后回退
        targetGuid = pGuid
      end
    end
  end

  -- 提前准备 pending，以便调试可以显示 cp/manual 决策
  if not entry or entry.onlyMine ~= true then
    -- 仍然允许调试打印，但不要创建 pending 条目
    _NP_PrintLine(spellId, spellName, spellNameNorm, targetGuid, durationMs, false, 0, nil)
    return
  end

  local pend = _GetPendingTable()
  pend[spellId] = pend[spellId] or {}
  local t = pend[spellId]

  t[targetGuid] = t[targetGuid] or {}
  local p = t[targetGuid]

  p.t = (GetTime and GetTime() or 0)
  p.kind = entry.kind
  p.nameNorm = spellNameNorm or p.nameNorm

  local cp = p.cp or 0
  if (not cp) or cp < 0 then
    cp = 0
  end

  -- 手动持续时间：
  --  - 固定手动：仅在 NP 返回 0 时使用。
  --  - CP 表手动：覆盖 NP（NP 通常对于基于 CP 的持续时间是错误的）
  local manualSec = nil
  local mv = ManualDurationBySpellId[spellId]
  local isCPTbl = (type(mv) == "table")

  if isCPTbl then
    -- 优先使用之前快照的 CP（p.cp）。如果缺失，最后尝试当前 CP。
    if (not cp) or cp <= 0 then
      if _PlayerUsesComboPoints() then
        cp = _GetComboPointsSafe()
      else
        cp = 0
      end
      p.cp = cp
    end

    if cp and cp > 0 then
      manualSec = _GetManualDurationBySpellId(spellId, cp)

      -- 盗贼SC：血腥气息增加割裂持续时间：
      -- 1级 => +4秒，2级 => 总共 +6秒。
      if manualSec and manualSec > 0 and _IsPlayerRogue and _TasteForBloodRank and _TasteForBloodRank > 0 then
        if spellNameNorm == "割裂" then
          if _TasteForBloodRank >= 2 then
            manualSec = manualSec + 6
          else
            manualSec = manualSec + 4
          end
        end
      end
    end
  elseif durationMs == 0 then
    -- 仅在 NP 返回 0 时使用固定手动持续时间
    manualSec = _GetManualDurationBySpellId(spellId, 0)
  end

  -- 总是调试打印（包括 durMs 0 / -1），但标记跟踪/未跟踪
  _NP_PrintLine(spellId, spellName, spellNameNorm, targetGuid, durationMs, (entry and entry.onlyMine == true), cp, manualSec)

  -- 如果 NP 报告 durationMs == 0 且玩家没有手动持续时间，则警告并停止。
  if durationMs == 0 and (not manualSec or manualSec <= 0) then
    _WarnMissingManualDuration(spellName, spellRank, spellId)
    return
  end

  -- onlyMine 守卫：仅在调试后处理跟踪的 onlyMine 光环
  if not entry or entry.onlyMine ~= true then
    return
  end

  -- 以秒为单位确定持续时间：
  --  a) durationMs > 0 -> 使用它
  --  b) durationMs == 0 -> 使用手动 CP 按名称或手动固定 spellId
  --  c) durationMs < 0 -> 无限/无 -> 忽略
  local secRounded = nil

  -- pend/pk/cp 已为调试准备就绪
  p.kind = entry.kind
  p.nameNorm = spellNameNorm or p.nameNorm

  if durationMs > 0 then
    local sec = durationMs / 1000
    local r = math.floor(sec + 0.5)
    if r and r > 0 then
      secRounded = r
    end

    -- CP 表法术：如果有效的 manualSec 存在，则覆盖 NP 持续时间
    if isCPTbl and manualSec and manualSec > 0 then
      secRounded = manualSec
    end
  elseif durationMs == 0 then
    secRounded = manualSec
  else
    -- durationMs < 0 => 无限/无持续时间 -> 忽略
    secRounded = nil
  end

  if secRounded and secRounded > 0 then
    p.dur = secRounded
    _CommitNPDuration(spellId, (cp and cp > 0) and cp or 0, secRounded, spellName, spellRank, durationMs)

    local now = GetTime and GetTime() or 0

    -- 上限溢出快速启动：
    -- 在增益/减益上限溢出时，*_ADDED_* 可能缺失。在这种情况下直接从 AURA_CAST 启动计时器。
    do
      local capOverflow = false
      if DoiteTrack.debugBuffCap == true then
        capOverflow = true
      elseif auraCapStatus == 3 then
        capOverflow = true
      elseif entry.kind == "Buff" and auraCapStatus == 1 then
        capOverflow = true
      elseif entry.kind == "Debuff" and auraCapStatus == 2 then
        capOverflow = true
      end

      if capOverflow then
        local bucket = _GetAuraBucketForGuid(targetGuid, true)
        if bucket then
          local a = bucket[spellId]
          if not a then
            a = {}
            bucket[spellId] = a
          end
          a.appliedAt = now
          a.lastSeen = now
          a.fullDur = secRounded
          a.cp = cp or 0
          a.isDebuff = (entry.kind == "Debuff")

          -- 圣骑士 SC 溢出回退：
          -- 如果 *_ADDED_* 因光环上限而被抑制，仍然启动活跃的审判刷新状态。
          if _G["DoiteTrack_IsPaladin"] == true and _G["DoiteTrack_PalJ_Tracked"] == true and entry.kind == "Debuff" then
            local token = nil
            if spellNameNorm == "十字军审判" then
              token = "crusader"
            elseif spellNameNorm == "光明审判" then
              token = "light"
            elseif spellNameNorm == "智慧审判" then
              token = "wisdom"
            elseif spellNameNorm == "正义审判" then
              token = "justice"
            end

            if token then
              local pj = _G["DoiteTrack_PalJ"]
              if type(pj) ~= "table" then
                pj = {}
                _G["DoiteTrack_PalJ"] = pj
              end

              pj.mode = true
              pj.sealToken = token
              pj.activeTargetGuid = targetGuid
              pj.activeSpellId = spellId
              pj.activeDur = 10
              pj.pendingTargetGuid = nil
              pj.pendingToken = nil
              pj.pendingExpiresAt = nil

              self:_RecomputeEventNeeds()
              self:_ApplyEventRegistration()
            end
          end

          t[targetGuid] = nil
          return
        end
      end
    end

    ----------------------------------------------------------------
    -- 刷新修复：
    -- 如果玩家已经为此 guid+spellId 有一个活跃的已确认计时器，则将 AURA_CAST 视为刷新并立即重新启动。
    -- 这涵盖了 NP 在重新应用时未触发 *_ADDED_* 的情况。
    ----------------------------------------------------------------
    do
      local bucket0 = AuraStateByGuid[targetGuid]
      if bucket0 then
        local a0 = bucket0[spellId]
        if a0 and a0.appliedAt and a0.fullDur then
          local age = now - (a0.appliedAt or now)
          local full = a0.fullDur or 0

          -- 仅当先前的计时器仍合理活跃时才刷新。
          -- （防止在静默掉落/陈旧状态后错误刷新）
          if full > 0 and age >= 0 and age <= (full + 0.25) then
            a0.appliedAt = now
            a0.lastSeen = now
            a0.fullDur = secRounded
            a0.cp = cp or 0
            a0.isDebuff = (entry.kind == "Debuff")

            t[targetGuid] = nil
            return
          end
        end
      end
    end

    -- 如果应用确认已经发生（刷新/顺序差异），立即启动计时器
    if p.confirmAt then
      if (now - (p.confirmAt or now)) <= 2.5 then
        local bucket = _GetAuraBucketForGuid(targetGuid, true)
        if bucket then
          local a = bucket[spellId]
          if not a then
            a = {}
            bucket[spellId] = a
          end

          a.appliedAt = now
          a.fullDur = secRounded
          a.cp = cp or 0
          a.isDebuff = (entry.kind == "Debuff")

          t[targetGuid] = nil
        end
      end
    end
  end
end

---------------------------------------------------------------
-- 事件框架接线（最小；无记录会话）
---------------------------------------------------------------
function DoiteTrack_DoiteAuras_RefreshIcons_Hook()
  local dt = _G["DoiteTrack"]
  if dt and dt._OnDoiteAurasConfigChanged then
    dt:_OnDoiteAurasConfigChanged()
  end

  local orig = _G["DoiteTrack_Orig_DoiteAuras_RefreshIcons"]
  if orig then
    return orig()
  end
end

local TrackFrame = CreateFrame("Frame", "DoiteTrackFrame")
DoiteTrack._frame = TrackFrame

TrackFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

---------------------------------------------------------------
-- 延迟初始化辅助函数（PLAYER_ENTERING_WORLD 后 1 秒）
---------------------------------------------------------------
function DoiteTrack:_ScheduleDelayedInit()
  local f = self._frame
  if not f then
    return
  end

  local now = GetTime and GetTime() or 0

  -- 在每个 ENTERING_WORLD（登录/重载/进入区域/副本）上总是延迟 1 秒
  self._initDelayUntil = now + 1.0

  -- 如果已经调度，只需将截止时间推后；不要堆叠 OnUpdate 处理程序。
  if self._initDelayActive then
    return
  end

  self._initDelayActive = true

  local oldOnUpdate = f:GetScript("OnUpdate")

  f:SetScript("OnUpdate", function()
    local dt = _G["DoiteTrack"]
    if not dt or dt._initDelayActive ~= true then
      f:SetScript("OnUpdate", oldOnUpdate)
      return
    end

    local t = GetTime and GetTime() or 0
    if t < (dt._initDelayUntil or 0) then
      return
    end

    -- 触发一次，然后恢复之前的 OnUpdate
    dt._initDelayActive = false
    dt._initDelayUntil = nil

    f:SetScript("OnUpdate", oldOnUpdate)

    -- 运行现有的初始化逻辑（包括钩子尝试 + 重新计算 + 注册）
    dt:_OnPlayerLogin()
  end)
end

-- 其他事件将在登录后根据监视列表和需求有条件地注册。
function DoiteTrack:_ApplyEventRegistration()
  local f = self._frame
  if not f then
    return
  end

  -- SPELL_CAST_EVENT：需要用于：
  --  a) 手动 CP 表的 CP 快照
  --  b) 德鲁伊 屠戮（凶猛撕咬监视）
  if self._needSpellCastEvent then
    f:RegisterEvent("SPELL_CAST_EVENT")
  else
    f:UnregisterEvent("SPELL_CAST_EVENT")
  end

  -- SPELL_DAMAGE_EVENT_SELF：需要用于：
  --  萨满熔岩爆裂 -> 火焰震击刷新（命中时）
  if self._needSpellDamageEventSelf then
    f:RegisterEvent("SPELL_DAMAGE_EVENT_SELF")
  else
    f:UnregisterEvent("SPELL_DAMAGE_EVENT_SELF")
  end

  -- 德鲁伊 屠戮：仅在 屠戮 活跃/需要时监听 CP 更改
  if self._needUnitComboPoints then
    f:RegisterEvent("PLAYER_COMBO_POINTS")
  else
    f:UnregisterEvent("PLAYER_COMBO_POINTS")
  end

  -- 德鲁伊/潜行者：学习新法术/天赋时重新扫描天赋
  if self._needTalentEvent then
    f:RegisterEvent("LEARNED_SPELL_IN_TAB")
  else
    f:UnregisterEvent("LEARNED_SPELL_IN_TAB")
  end

  -- AUTO_ATTACK_SELF：仅用于圣骑士审判刷新
  if self._needAutoAttackSelf then
    f:RegisterEvent("AUTO_ATTACK_SELF")
    -- 启用 NP 自动攻击事件（廉价全局切换；仍受注册保护）
    local SetCVar = _G.SetCVar
    if SetCVar then
      pcall(SetCVar, "NP_EnableAutoAttackEvents", "1")
    end
  else
    f:UnregisterEvent("AUTO_ATTACK_SELF")
  end

  -- 光环 REMOVED 事件：仅用于圣骑士审判停止逻辑 / 圣印取消
  if self._needAuraRemoved then
    f:RegisterEvent("BUFF_REMOVED_SELF")
    f:RegisterEvent("BUFF_REMOVED_OTHER")
    f:RegisterEvent("DEBUFF_REMOVED_OTHER")
  else
    f:UnregisterEvent("BUFF_REMOVED_SELF")
    f:UnregisterEvent("BUFF_REMOVED_OTHER")
    f:UnregisterEvent("DEBUFF_REMOVED_OTHER")
  end

  -- NP 事件：仅在玩家有任何跟踪的光环时
  if self._hasTracked then
    f:RegisterEvent("AURA_CAST_ON_SELF")
    f:RegisterEvent("AURA_CAST_ON_OTHER")

    f:RegisterEvent("BUFF_ADDED_SELF")
    f:RegisterEvent("BUFF_ADDED_OTHER")
    f:RegisterEvent("DEBUFF_ADDED_SELF")
    f:RegisterEvent("DEBUFF_ADDED_OTHER")
  else
    f:UnregisterEvent("AURA_CAST_ON_SELF")
    f:UnregisterEvent("AURA_CAST_ON_OTHER")

    f:UnregisterEvent("BUFF_ADDED_SELF")
    f:UnregisterEvent("BUFF_ADDED_OTHER")
    f:UnregisterEvent("DEBUFF_ADDED_SELF")
    f:UnregisterEvent("DEBUFF_ADDED_OTHER")

    -- 当没有跟踪的光环时，也确保圣骑士专用的移除/自动攻击关闭
    f:UnregisterEvent("AUTO_ATTACK_SELF")
    f:UnregisterEvent("BUFF_REMOVED_SELF")
    f:UnregisterEvent("BUFF_REMOVED_OTHER")
    f:UnregisterEvent("DEBUFF_REMOVED_OTHER")
  end
end

TrackFrame:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" then
    DoiteTrack:_ScheduleDelayedInit()
    return
  end
  if event == "LEARNED_SPELL_IN_TAB" then
    DoiteTrack:_OnLearnedSpellInTab()
    return
  end
  if event == "PLAYER_COMBO_POINTS" then
    DoiteTrack:_OnUnitComboPoints()
    return
  end
  if event == "SPELL_DAMAGE_EVENT_SELF" then
    DoiteTrack:_OnSpellDamageEventSelf()
    return
  end
  if event == "SPELL_CAST_EVENT" then
    DoiteTrack:_OnSpellCastEvent()
    return
  end
  if event == "AUTO_ATTACK_SELF" then
    DoiteTrack:_OnAutoAttackSelf()
    return
  end
  -- 此框架接收的任何其他事件（当注册时）都是 NP 光环相关的
  DoiteTrack:_OnAuraNPEvent()
end)

---------------------------------------------------------------
-- 运行时 API（兼容形状）
---------------------------------------------------------------
-- 内部辅助函数
local _GetRemainingFromState

local function _ClearAuraStateForGuidSpell(guid, spellId)
  if not guid or guid == "" then
    return
  end
  local b = AuraStateByGuid[guid]
  if b then
    b[spellId] = nil
  end
end

-- 假设光环存在已经通过 _AuraHasSpellId() 验证。仅使用玩家确认的计时器状态；如果未知/不是我的/过期，则返回 nil。
_GetRemainingFromState = function(guid, spellId, now)
  if not guid or guid == "" then
    return nil
  end

  local bucket = AuraStateByGuid[guid]
  if not bucket then
    return nil
  end

  local a = bucket[spellId]
  if not a or not a.appliedAt or not a.fullDur then
    return nil
  end

  local rem = (a.fullDur or 0) - (now - (a.appliedAt or now))
  if rem <= 0 then
    -- 仍然存在但已过期 => 停止声称所有权/计时器
    bucket[spellId] = nil
    return nil
  end

  return rem
end

-- 基于名称的辅助函数（保持兼容）
local function _GetEntryForName(spellName)
  if not spellName or spellName == "" then
    return nil
  end
  local norm = _NormSpellName(spellName)
  if not norm then
    return nil
  end
  return TrackedByNameNorm[norm]
end

function DoiteTrack:GetAuraRemainingSecondsByName(spellName, unit)
  if not spellName or not unit then
    return nil
  end

  local entry = _GetEntryForName(spellName)
  if not entry or not entry.spellIds then
    return nil
  end

  if not _UnitExistsFlag(unit) then
    return nil
  end

  local guid = _GetUnitGuidSafe(unit)
  if not guid then
    return nil
  end

  local now = GetTime and GetTime() or 0
  local isDebuff = (entry.kind == "Debuff")

  local bestRem, bestSpellId = nil, nil

  local sid
  for sid in pairs(entry.spellIds) do
    if _AuraHasSpellId(unit, sid, isDebuff) then
      local rem = _GetRemainingFromState(guid, sid, now)
      if rem and rem > 0 then
        if (not bestRem) or rem > bestRem then
          bestRem = rem
          bestSpellId = sid
        end
      end
    else
      -- 如果光环不再存在，清除任何陈旧的计时器状态
      _ClearAuraStateForGuidSpell(guid, sid)
    end
  end

  if not bestRem then
    return nil
  end
  return bestRem, bestSpellId
end

function DoiteTrack:GetAuraRemainingSecondsBySpellId(spellId, unit)
  spellId = tonumber(spellId) or 0
  if spellId <= 0 or not unit then
    return nil
  end

  local entry = TrackedBySpellId[spellId]
  if not entry then
    return nil
  end

  if not _UnitExistsFlag(unit) then
    return nil
  end

  local guid = _GetUnitGuidSafe(unit)
  if not guid then
    return nil
  end

  local isDebuff = (entry.kind == "Debuff")
  if not _AuraHasSpellId(unit, spellId, isDebuff) then
    _ClearAuraStateForGuidSpell(guid, spellId)
    return nil
  end

  local now = GetTime and GetTime() or 0
  local rem = _GetRemainingFromState(guid, spellId, now)
  if rem and rem > 0 then
    return rem, spellId
  end

  return nil
end

function DoiteTrack:RemainingPassesByName(spellName, unit, comp, threshold)
  if not spellName or not unit or not comp or threshold == nil then
    return nil
  end

  local rem = self:GetAuraRemainingSecondsByName(spellName, unit)
  if not rem or rem <= 0 then
    return nil
  end

  if comp == ">=" then
    return rem >= threshold
  elseif comp == "<=" then
    return rem <= threshold
  elseif comp == "==" then
    return rem == threshold
  end
  return nil
end


function DoiteTrack:RemainingPassesBySpellId(spellId, unit, comp, threshold)
  spellId = tonumber(spellId) or 0
  if spellId <= 0 or not unit or not comp or threshold == nil then
    return nil
  end

  local rem = self:GetAuraRemainingSecondsBySpellId(spellId, unit)
  if not rem or rem <= 0 then
    return nil
  end

  if comp == ">=" then
    return rem >= threshold
  elseif comp == "<=" then
    return rem <= threshold
  elseif comp == "==" then
    return rem == threshold
  end
  return nil
end

function DoiteTrack:GetAuraOwnershipByName(spellName, unit)
  if not spellName or not unit then
    return nil, false, nil, false, false, false
  end

  local entry = _GetEntryForName(spellName)
  if not entry or not entry.spellIds then
    return nil, false, nil, false, false, false
  end

  if not _UnitExistsFlag(unit) then
    return nil, false, nil, false, false, false
  end

  local guid = _GetUnitGuidSafe(unit)
  if not guid then
    return nil, false, nil, false, false, false
  end

  local now = GetTime and GetTime() or 0
  local isDebuff = (entry.kind == "Debuff")

  local hasMine = false
  local hasOther = false
  local bestRem, bestSpellId = nil, nil

  local sid
  for sid in pairs(entry.spellIds) do
    if _AuraHasSpellId(unit, sid, isDebuff) then
      local rem = _GetRemainingFromState(guid, sid, now)
      if rem and rem > 0 then
        hasMine = true
        if (not bestRem) or rem > bestRem then
          bestRem = rem
          bestSpellId = sid
        end
      else
        -- 光环存在但玩家没有确认的计时器 => 视为“他人”
        hasOther = true
      end
    else
      _ClearAuraStateForGuidSpell(guid, sid)
    end
  end

  -- 名称跟踪的条目可以在我们发现等级 spellId 之前被查询。
  -- 在第一次传递时，学习当前存在于单位上的任何法术 ID，这些 ID 规范化为此光环名称，然后立即从中评估所有权。
  if (not hasMine) and (not hasOther) and entry.normName then
    local discovered = _CollectAuraSpellIdsMatchingName(unit, isDebuff, entry.normName)
    if discovered then
      for sid in pairs(discovered) do
        if not entry.spellIds[sid] then
          entry.spellIds[sid] = true
        end

        if _AuraHasSpellId(unit, sid, isDebuff) then
          local rem = _GetRemainingFromState(guid, sid, now)
          if rem and rem > 0 then
            hasMine = true
            if (not bestRem) or rem > bestRem then
              bestRem = rem
              bestSpellId = sid
            end
          else
            hasOther = true
          end
        else
          _ClearAuraStateForGuidSpell(guid, sid)
        end
      end
    end
  end

  local ownerKnown = (hasMine or hasOther)
  return bestRem, false, bestSpellId, hasMine, hasOther, ownerKnown
end

function DoiteTrack:GetAuraOwnershipBySpellId(spellId, unit)
  spellId = tonumber(spellId) or 0
  if spellId <= 0 or not unit then
    return nil, false, nil, false, false, false
  end

  local entry = TrackedBySpellId[spellId]
  if not entry then
    return nil, false, nil, false, false, false
  end

  if not _UnitExistsFlag(unit) then
    return nil, false, nil, false, false, false
  end

  local guid = _GetUnitGuidSafe(unit)
  if not guid then
    return nil, false, nil, false, false, false
  end

  local isDebuff = (entry.kind == "Debuff")
  if not _AuraHasSpellId(unit, spellId, isDebuff) then
    _ClearAuraStateForGuidSpell(guid, spellId)
    return nil, false, nil, false, false, false
  end

  local now = GetTime and GetTime() or 0
  local rem = _GetRemainingFromState(guid, spellId, now)
  if rem and rem > 0 then
    return rem, false, spellId, true, false, true
  end

  return nil, false, spellId, false, true, true
end



---------------------------------------------------------------
-- 目标光环存在/层数缓存（与条件检查共享）
---------------------------------------------------------------
local function _WipeBoolTable(t)
  local k
  for k in pairs(t) do
    t[k] = nil
  end
end

local function _EnsureTargetAuraCacheFresh()
  local c = DoiteTrack._targetAuraCache
  if not c then
    c = {
      stamp = -1,
      buffCount = 0,
      debuffCount = 0,
      buffsByName = {},
      debuffsByName = {},
      buffsById = {},
      debuffsById = {},
      buffStacksByName = {},
      debuffStacksByName = {},
      buffStacksById = {},
      debuffStacksById = {}
    }
    DoiteTrack._targetAuraCache = c
  end

  if not _UnitExistsFlag("target") then
    c.stamp = -1
    c.buffCount = 0
    c.debuffCount = 0
    _WipeBoolTable(c.buffsByName)
    _WipeBoolTable(c.debuffsByName)
    _WipeBoolTable(c.buffsById)
    _WipeBoolTable(c.debuffsById)
    _WipeBoolTable(c.buffStacksByName)
    _WipeBoolTable(c.debuffStacksByName)
    _WipeBoolTable(c.buffStacksById)
    _WipeBoolTable(c.debuffStacksById)
    return c
  end

  local now = math.floor(((GetTime and GetTime()) or 0) * 20)
  if c.stamp == now then
    return c
  end

  c.stamp = now
  c.buffCount = 0
  c.debuffCount = 0
  _WipeBoolTable(c.buffsByName)
  _WipeBoolTable(c.debuffsByName)
  _WipeBoolTable(c.buffsById)
  _WipeBoolTable(c.debuffsById)
  _WipeBoolTable(c.buffStacksByName)
  _WipeBoolTable(c.debuffStacksByName)
  _WipeBoolTable(c.buffStacksById)
  _WipeBoolTable(c.debuffStacksById)

  local auraSpellIds = nil
  local auraStacks = nil
  if GetUnitField then
    local okIds, ids = pcall(GetUnitField, "target", "aura")
    if okIds and type(ids) == "table" then
      auraSpellIds = ids
    end
    local okStacks, stacks = pcall(GetUnitField, "target", "auraApplications")
    if okStacks and type(stacks) == "table" then
      auraStacks = stacks
    end
  end

  local i
  for i = 1, 32 do
    local sid = tonumber(auraSpellIds and auraSpellIds[i]) or 0
    if sid > 0 then
      local stacks = tonumber(auraStacks and auraStacks[i])
      stacks = (stacks and (stacks + 1)) or 1
      local nm = _GetSpellNameRank and _GetSpellNameRank(sid)
      c.buffCount = c.buffCount + 1
      c.buffsById[sid] = true
      c.buffStacksById[sid] = stacks
      if nm and nm ~= "" then
        c.buffsByName[nm] = true
        c.buffStacksByName[nm] = stacks
      end
    end
  end

  for i = 1, 16 do
    local idx = 32 + i
    local sid = tonumber(auraSpellIds and auraSpellIds[idx]) or 0
    if sid > 0 then
      local stacks = tonumber(auraStacks and auraStacks[idx])
      stacks = (stacks and (stacks + 1)) or 1
      local nm = _GetSpellNameRank and _GetSpellNameRank(sid)
      c.debuffCount = c.debuffCount + 1
      c.debuffsById[sid] = true
      c.debuffStacksById[sid] = stacks
      if nm and nm ~= "" then
        c.debuffsByName[nm] = true
        c.debuffStacksByName[nm] = stacks
      end
    end
  end

  return c
end

local function _GetTimedAuraStateForCurrentTargetSpellId(spellId, wantDebuff)
  spellId = tonumber(spellId) or 0
  if spellId <= 0 then
    return nil
  end

  local targetGuid = _GetUnitGuidSafe("target")
  if not targetGuid or targetGuid == "" then
    return nil
  end

  local now = (GetTime and GetTime()) or 0
  local rem = _GetRemainingFromState(targetGuid, spellId, now)
  if not rem or rem <= 0 then
    return nil
  end

  local bucket = AuraStateByGuid[targetGuid]
  local st = bucket and bucket[spellId]
  if not st then
    return nil
  end

  if wantDebuff ~= nil then
    local isDebuff = (st.isDebuff == true)
    if isDebuff ~= (wantDebuff == true) then
      return nil
    end
  end

  return st
end

local function _IsSpellIdVisibleInTargetCache(c, spellId, wantDebuff)
  if not c then
    return false
  end

  if wantDebuff == true then
    if c.debuffsById[spellId] then
      return true
    end
    if c.debuffCount >= 16 and c.buffsById[spellId] then
      return true
    end
    return false
  end

  return c.buffsById[spellId] or false
end

function DoiteTrack.HasBuff(spellName)
  if not spellName or spellName == "" then
    return false
  end
  local c = _EnsureTargetAuraCacheFresh()
  if (not DoiteTrack.debugBuffCap) and c and c.buffsByName[spellName] then
    return true
  end

  local entry = _GetEntryForName(spellName)
  if not entry or not entry.spellIds then
    return false
  end

  local sid
  for sid in pairs(entry.spellIds) do
    sid = tonumber(sid) or 0
    if sid > 0 and _GetTimedAuraStateForCurrentTargetSpellId(sid, false) then
      return true
    end
  end

  return false
end

function DoiteTrack.HasBuffSpellId(spellId)
  spellId = tonumber(spellId) or 0
  if spellId <= 0 then
    return false
  end
  local c = _EnsureTargetAuraCacheFresh()
  if (not DoiteTrack.debugBuffCap) and c and c.buffsById[spellId] then
    return true
  end
  return _GetTimedAuraStateForCurrentTargetSpellId(spellId, false) and true or false
end

function DoiteTrack.HasDebuff(spellName)
  if not spellName or spellName == "" then
    return false
  end
  local c = _EnsureTargetAuraCacheFresh()
  if not c then
    return false
  end
  if (not DoiteTrack.debugBuffCap) and c.debuffsByName[spellName] then
    return true
  end
  if (not DoiteTrack.debugBuffCap) and c.debuffCount >= 16 then
    if c.buffsByName[spellName] then
      return true
    end
  end

  local entry = _GetEntryForName(spellName)
  if not entry or not entry.spellIds then
    return false
  end

  local sid
  for sid in pairs(entry.spellIds) do
    sid = tonumber(sid) or 0
    if sid > 0 and _GetTimedAuraStateForCurrentTargetSpellId(sid, true) then
      return true
    end
  end

  return false
end

function DoiteTrack.HasDebuffSpellId(spellId)
  spellId = tonumber(spellId) or 0
  if spellId <= 0 then
    return false
  end
  local c = _EnsureTargetAuraCacheFresh()
  if not c then
    return false
  end
  if (not DoiteTrack.debugBuffCap) and c.debuffsById[spellId] then
    return true
  end
  if (not DoiteTrack.debugBuffCap) and c.debuffCount >= 16 then
    if c.buffsById[spellId] then
      return true
    end
  end
  if _GetTimedAuraStateForCurrentTargetSpellId(spellId, true) then
    return true
  end
  return false
end

function DoiteTrack.GetBuffStacks(spellName)
  if not spellName or spellName == "" then
    return nil
  end
  local c = _EnsureTargetAuraCacheFresh()
  if (not DoiteTrack.debugBuffCap) and c and c.buffStacksByName[spellName] then
    return c.buffStacksByName[spellName]
  end

  local entry = _GetEntryForName(spellName)
  if not entry or not entry.spellIds then
    return nil
  end

  local sid
  for sid in pairs(entry.spellIds) do
    sid = tonumber(sid) or 0
    if sid > 0 and _GetTimedAuraStateForCurrentTargetSpellId(sid, false) then
      return 1
    end
  end

  return nil
end

function DoiteTrack.GetBuffStacksBySpellId(spellId)
  spellId = tonumber(spellId) or 0
  if spellId <= 0 then
    return nil
  end
  local c = _EnsureTargetAuraCacheFresh()
  if (not DoiteTrack.debugBuffCap) and c and c.buffStacksById[spellId] then
    return c.buffStacksById[spellId]
  end
  if _GetTimedAuraStateForCurrentTargetSpellId(spellId, false) then
    return 1
  end
  return nil
end

function DoiteTrack.GetDebuffStacks(spellName)
  if not spellName or spellName == "" then
    return nil
  end
  local c = _EnsureTargetAuraCacheFresh()
  if not c then
    return nil
  end
  if (not DoiteTrack.debugBuffCap) and c.debuffStacksByName[spellName] then
    return c.debuffStacksByName[spellName]
  end
  if (not DoiteTrack.debugBuffCap) and c.debuffCount >= 16 then
    if c.buffStacksByName[spellName] then
      return c.buffStacksByName[spellName]
    end
  end

  local entry = _GetEntryForName(spellName)
  if not entry or not entry.spellIds then
    return nil
  end

  local sid
  for sid in pairs(entry.spellIds) do
    sid = tonumber(sid) or 0
    if sid > 0 and _GetTimedAuraStateForCurrentTargetSpellId(sid, true) then
      return 1
    end
  end

  return nil
end

function DoiteTrack.GetDebuffStacksBySpellId(spellId)
  spellId = tonumber(spellId) or 0
  if spellId <= 0 then
    return nil
  end
  local c = _EnsureTargetAuraCacheFresh()
  if not c then
    return nil
  end
  if (not DoiteTrack.debugBuffCap) and c.debuffStacksById[spellId] then
    return c.debuffStacksById[spellId]
  end
  if (not DoiteTrack.debugBuffCap) and c.debuffCount >= 16 then
    if c.buffStacksById[spellId] then
      return c.buffStacksById[spellId]
    end
  end
  if _GetTimedAuraStateForCurrentTargetSpellId(spellId, true) then
    return 1
  end
  return nil
end

function DoiteTrack.GetVisibleAuraCounts()
  local c = _EnsureTargetAuraCacheFresh()
  if not c then
    return 0, 0
  end
  return c.buffCount or 0, c.debuffCount or 0
end

function DoiteTrack.GetTrackedHiddenBuffCount()
  local c = _EnsureTargetAuraCacheFresh()
  local targetGuid = _GetUnitGuidSafe("target")
  if not targetGuid or targetGuid == "" then
    return 0
  end

  local bucket = AuraStateByGuid[targetGuid]
  if type(bucket) ~= "table" then
    return 0
  end

  local now = (GetTime and GetTime()) or 0
  local count = 0
  local sid
  for sid, _ in pairs(bucket) do
    sid = tonumber(sid) or 0
    if sid > 0 then
      local rem = _GetRemainingFromState(targetGuid, sid, now)
      local treatAsHidden =
          ((not _IsSpellIdVisibleInTargetCache(c, sid, false)) and (not _IsSpellIdVisibleInTargetCache(c, sid, true)))
      if rem and rem > 0 and treatAsHidden then
        count = count + 1
      end
    end
  end

  return count
end

function DoiteTrack.GetAuraCountSummary()
  local buffs, debuffs = DoiteTrack.GetVisibleAuraCounts()
  local hidden = DoiteTrack.GetTrackedHiddenBuffCount()
  return buffs, debuffs, hidden, (buffs + debuffs + hidden)
end

function DoiteTrack.SetDebugBuffCap(enabled)
  local want = (enabled == true)
  if (DoiteTrack.debugBuffCap == true) == want then
    return
  end

  DoiteTrack.debugBuffCap = want
  local state = want and "enabled" or "disabled"
  print("DoiteTargetAuras: 调试缓冲上限 " .. state)
end

function DoiteTrack.ToggleDebugBuffCap()
  DoiteTrack.SetDebugBuffCap(not (DoiteTrack.debugBuffCap == true))
end
---------------------------------------------------------------
-- 游戏内使用
---------------------------------------------------------------
-- /run DoiteTrack_SetNPDebug(true)
-- /run local r,sid=DoiteTrack:GetAuraRemainingSecondsByName("[添加法术名称]","target");DEFAULT_CHAT_FRAME:AddMessage("rem="..tostring(r).." sid="..tostring(sid))