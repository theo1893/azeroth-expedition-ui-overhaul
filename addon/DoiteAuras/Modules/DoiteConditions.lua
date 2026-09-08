---------------------------------------------------------------
-- DoiteConditions.lua
-- 评估技能和光环条件以显示/隐藏/更新图标
-- 请尊重许可说明：使用前请询问
-- WoW 1.12 | Lua 5.0
---------------------------------------------------------------

local DoiteConditions = {}
_G["DoiteConditions"] = DoiteConditions

if not _G["DoiteAurasDB"] then
  _G["DoiteAurasDB"] = {}
end

DoiteAurasDB = _G["DoiteAurasDB"]
DoiteAurasDB.cache = DoiteAurasDB.cache or {}
DoiteAurasCacheDB = DoiteAurasDB.cache
local IconCache = DoiteAurasDB.cache

local GetTime = GetTime
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitExists = UnitExists
local UnitIsFriend = UnitIsFriend
local UnitCanAttack = UnitCanAttack
local UnitIsUnit = UnitIsUnit
local UnitClass = UnitClass
local UnitMana = UnitMana
local GetNumTalents = GetNumTalents
local GetTalentInfo = GetTalentInfo
local _GetAuraStacksOnUnit
local _StacksPasses
local str_find = string.find
local str_gsub = string.gsub
local SpellUsableArgCache = {}
local _SoundStateByKey = {}

local function _DoitePlayConfiguredSound(fileName)
  if not fileName or fileName == "" then
    return
  end
  if not PlaySoundFile then
    return
  end
  local path = "Interface\\AddOns\\DoiteAuras\\Sounds\\" .. fileName
  pcall(PlaySoundFile, path)
end

local function _DoiteHandleEdgeSound(key, stateKey, nowActive, enabledFlag, fileName)
  if not key or not stateKey then
    return
  end
  local st = _SoundStateByKey[key]
  if not st then
    st = {}
    _SoundStateByKey[key] = st
  end

  local prev = st[stateKey]
  st[stateKey] = nowActive and true or false

  if prev == nil then
    return
  end
  if (not prev) and nowActive and enabledFlag and fileName and fileName ~= "" then
    _DoitePlayConfiguredSound(fileName)
  end
end

-- Nampower 返回：名称，纹理路径（任一可能为 nil）
local function _NP_SpellNameAndTexture(spellId)
  if not spellId or spellId <= 0 then
    return nil, nil
  end

  local name = nil
  if type(GetSpellNameAndRankForId) == "function" then
    local okName, n = pcall(GetSpellNameAndRankForId, spellId)
    if okName and type(n) == "string" and n ~= "" then
      name = n
    end
  end

  local tex = nil
  if type(GetSpellRecField) == "function" and type(GetSpellIconTexture) == "function" then
    local okIconId, iconId = pcall(GetSpellRecField, spellId, "spellIconID")
    if okIconId and iconId and iconId > 0 then
      local okTex, t = pcall(GetSpellIconTexture, iconId)
      if okTex and type(t) == "string" and t ~= "" then
        tex = t
      end
    end
  end

  return name, tex
end

-- 热路径的快速框架获取器（ApplyVisuals / 光环扫描 / 时间文本）
local function _GetIconFrame(k)
  if not k then
    return nil
  end

  -- 如果存在外部获取器，优先使用
  if DoiteAuras_GetIconFrame then
    local f = DoiteAuras_GetIconFrame(k)
    if f then
      return f
    end
  end

  -- 缓存表实时存在
  local byKey = DoiteConditions._iconFrameByKey
  if not byKey then
    byKey = {}
    DoiteConditions._iconFrameByKey = byKey
    DoiteConditions._iconFrameNameByKey = {}
  end

  local f = byKey[k]
  if f then
    return f
  end

  local nameByKey = DoiteConditions._iconFrameNameByKey
  local nm = nameByKey[k]
  if not nm then
    nm = "DoiteIcon_" .. k
    nameByKey[k] = nm
  end

  f = _G[nm]
  if f then
    byKey[k] = f
  end
  return f
end

local function _ForgetIconFrame(k)
  if DoiteConditions and DoiteConditions._iconFrameByKey then
    DoiteConditions._iconFrameByKey[k] = nil
  end
end

local function _Now()

  return (GetTime and GetTime()) or 0
end

-- 法术索引缓存（必须在任何使用前定义）
local SpellIndexCache = {}
_G.DoiteConditions_SpellIndexCache = SpellIndexCache
_G.DoiteConditions_SpellBookTypeCache = _G.DoiteConditions_SpellBookTypeCache or {}

local _isWarrior = false

local function _GetSpellIndexByName(spellName)
  if not spellName then
    return nil
  end

  local cached = SpellIndexCache[spellName]
  if cached ~= nil then
    return (cached ~= false) and cached or nil
  end

  -- Nampower 快速路径 - GetSpellSlotTypeIdForName(spellName)
  if GetSpellSlotTypeIdForName then
    local slot, bookType = GetSpellSlotTypeIdForName(spellName)
    if slot and slot > 0 and (bookType == "spell" or bookType == "pet") then
      SpellIndexCache[spellName] = slot
      _G.DoiteConditions_SpellBookTypeCache[spellName] = (bookType == "pet") and BOOKTYPE_PET or BOOKTYPE_SPELL
      return slot
    end
  end

  -- 扫描回退
  local i = 1
  while i <= 200 do
    local s = GetSpellName(i, BOOKTYPE_SPELL)
    if not s then
      break
    end
    if s == spellName then
      SpellIndexCache[spellName] = i
      _G.DoiteConditions_SpellBookTypeCache[spellName] = BOOKTYPE_SPELL
      return i
    end
    i = i + 1
  end

  -- 宠物法术书回退
  i = 1
  while i <= 200 do
    local s = GetSpellName(i, BOOKTYPE_PET)
    if not s then
      break
    end
    if s == spellName then
      SpellIndexCache[spellName] = i
      _G.DoiteConditions_SpellBookTypeCache[spellName] = BOOKTYPE_PET
      return i
    end
    i = i + 1
  end

  SpellIndexCache[spellName] = false
  _G.DoiteConditions_SpellBookTypeCache[spellName] = false
  return nil
end

-- 主更新循环使用的脏标志
local dirty_ability = false
local dirty_aura = false
local dirty_target = false
local dirty_power = false
local dirty_ability_time = false

-- 合并的光环扫描（在事件中设置；在 OnUpdate 中消费）
DoiteConditions._pendingAuraScanTarget = false

----------------------------------------------------------------
-- 下一帧进行一次重绘（避免事件内部的重入）
----------------------------------------------------------------

-- 前向声明，以便上面定义的函数可以将其捕获为上值
local _RequestImmediateEval

local _DoiteImmediateEval = CreateFrame("Frame", "DoiteImmediateEval")
_DoiteImmediateEval:Hide()
_DoiteImmediateEval._pending = false
_DoiteImmediateEval:SetScript("OnUpdate", function()
  this:Hide()
  this._pending = false

  dirty_ability = true
  dirty_aura = true
  dirty_target = true
  dirty_power = true
  dirty_ability_time = true

  if DoiteConditions and DoiteConditions.EvaluateAll then
    DoiteConditions:EvaluateAll()
  end

  if DoiteGroup then
    _G["DoiteGroup_NeedReflow"] = true
  end
end)

_RequestImmediateEval = function()
  if _DoiteImmediateEval._pending then
    return
  end
  _DoiteImmediateEval._pending = true
  _DoiteImmediateEval:Show()
end

_G.DoiteConditions_RequestImmediateEval = _RequestImmediateEval

local DG = _G["DoiteGlow"]

local function _IsKeyUnderEdit(k)
  if not k then
    return false
  end
  if _G["DoiteAuras_TestAll"] == true then
    return true
  end
  local cur = _G["DoiteEdit_CurrentKey"]
  if not cur or cur ~= k then
    return false
  end
  local f = _G["DoiteEdit_Frame"] or _G["DoiteEditMain"] or _G["DoiteEdit"]
  if f and f.IsShown then
    return f:IsShown() == 1
  end
  return true
end

local function _IsAnyKeyUnderEdit()
  if _G["DoiteAuras_TestAll"] == true then
    return true
  end
  local cur = _G["DoiteEdit_CurrentKey"]
  if not cur then
    return false
  end
  local f = _G["DoiteEdit_Frame"] or _G["DoiteEditMain"] or _G["DoiteEdit"]
  if f and f.IsShown then
    return f:IsShown() == 1
  end
  return false
end

----------------------------------------------------------------
-- 编辑模式心跳：编辑器打开时强制频繁刷新（防止 0.5 秒延迟/空闲时需要目标时）
----------------------------------------------------------------
local _editTick = CreateFrame("Frame", "DoiteEditTick")
local _editAccum = 0

-- 调整：0.10 感觉即时但仍然廉价。
local DOITE_EDIT_TICK = 0.10

_editTick:SetScript("OnUpdate", function()
  if not _IsAnyKeyUnderEdit() then
    _editAccum = 0
    return
  end

  -- 用户拖动图标或框架时跳过刷新（防止更新循环）
  if _G["DoiteUI_Dragging"] then
    return
  end

  _editAccum = _editAccum + (arg1 or 0)
  if _editAccum < DOITE_EDIT_TICK then
    return
  end
  _editAccum = 0

  -- 如果编辑器隐藏或零可见图标，则跳过
  local f = _G["DoiteEdit_Frame"]
  if not (f and f:IsShown()) then
    return
  end
  _editAccum = 0

  -- 强制正常流水线即使在玩家空闲时也运行。
  dirty_ability = true
  dirty_aura = true
  dirty_target = true
  dirty_power = true
  dirty_ability_time = true
end)

local function _MaybeResolveSpellIdForEntry(key, data)
  if not data or type(data) ~= "table" then
    return
  end

  -- 仅触碰看起来像临时 "法术 ID: ###" displayName 的条目
  local dn = data.displayName
  if not dn or dn == "" then
    return
  end
  if not str_find(dn, "^法术 ID") then
    return
  end

  local sidStr = data.spellid
  if not sidStr or sidStr == "" then
    return
  end
  local sid = tonumber(sidStr)
  if not sid or sid <= 0 then
    return
  end

  local name, tex

  -- Nampower：将 spellId -> name + texture 解析
  name, tex = _NP_SpellNameAndTexture(sid)

  -- 如果仍然没有真实名称，则不做任何更改
  if not name or name == "" then
    return
  end

  ------------------------------------------------------------
  -- 提交到数据库：真实名称 + 可选纹理
  ------------------------------------------------------------
  data.displayName = name
  if not data.name or data.name == "" then
    data.name = name
  end

  if tex and tex ~= "" then
    data.iconTexture = tex

    if IconCache then
      IconCache[name] = tex
    end
    if DoiteAurasDB and DoiteAurasDB.cache then
      DoiteAurasDB.cache[name] = tex
    end

    -- 如果存在，更新实时图标框架
    if key then
      local f = _GetIconFrame(key)
      if f and f.icon and f.icon.SetTexture then
        local cur = f.icon:GetTexture()
        if cur ~= tex then
          f.icon:SetTexture(tex)
        end
      end
    end
  end
end

local _trackedByName, _trackedBuiltAt = nil, 0

-- 池列表表，以避免在频繁重建期间重复分配（特别是在编辑器 TTL=0.25 时）
local _trackedListPool = {}
local _trackedListPoolN = 0

local function _PoolPopList()
  if _trackedListPoolN > 0 then
    local lst = _trackedListPool[_trackedListPoolN]
    _trackedListPool[_trackedListPoolN] = nil
    _trackedListPoolN = _trackedListPoolN - 1
    return lst
  end
  return {}
end

local function _PoolPushList(lst)
  if not lst then
    return
  end
  local j
  for j in pairs(lst) do
    lst[j] = nil
  end
  _trackedListPoolN = _trackedListPoolN + 1
  _trackedListPool[_trackedListPoolN] = lst
end

local function _GetTrackedByName()
  local now = GetTime()

  -- 编辑时，更积极地重建。
  local ttl = _IsAnyKeyUnderEdit() and 0.25 or 5.0

  local dbSize = 0
  if DoiteAurasDB and DoiteAurasDB.spells then
    for _ in pairs(DoiteAurasDB.spells) do
      dbSize = dbSize + 1
    end
  end

  local builtAt = _trackedBuiltAt or 0
  local cachedSize = _trackedByName and _trackedByName._dbSize or nil

  if _trackedByName and (now - builtAt) < ttl and cachedSize == dbSize then
    return _trackedByName
  end

  local t = _trackedByName
  if not t then
    t = {}
  else
    local k, lst
    for k, lst in pairs(t) do
      if type(lst) == "table" then
        _PoolPushList(lst)
      end
      t[k] = nil
    end
  end

  if DoiteAurasDB and DoiteAurasDB.spells then
    local key, data
    for key, data in pairs(DoiteAurasDB.spells) do
      if data and (data.type == "Buff" or data.type == "Debuff") then
        -- 如果此光环是通过 spellid 添加的，具有临时的 "法术 ID: ###" 名称，则使用 Nampower 解析一次。
        _MaybeResolveSpellIdForEntry(key, data)

        local nm = data.displayName or data.name
        if nm and nm ~= "" then
          local lst = t[nm]
          if not lst then
            lst = _PoolPopList()
            t[nm] = lst
          end
          table.insert(lst, key)
        end
      end
    end
  end

  _trackedByName, _trackedBuiltAt = t, now
  t._dbSize = dbSize
  return t
end

-- === 光环快照和单个工具提示 ===
local DoiteConditionsTooltip = _G["DoiteConditionsTooltip"]
if not DoiteConditionsTooltip then
  DoiteConditionsTooltip = CreateFrame("GameTooltip", "DoiteConditionsTooltip", nil, "GameTooltipTemplate")
  DoiteConditionsTooltip:SetOwner(UIParent, "ANCHOR_NONE")
end

-- 缓存工具提示字体字符串一次
local _CondTipLeft = {}
do
  local i = 1
  while i <= 15 do
    _CondTipLeft[i] = _G["DoiteConditionsTooltipTextLeft" .. i]
    i = i + 1
  end
end

-- 缓存 Left1 FS 一次，用于光环名称/时间读取
local _DoiteCondTipLeft1FS = _G["DoiteConditionsTooltipTextLeft1"]

local auraSnapshot = {
  -- TODO 改进
  target = { buffs = {}, debuffs = {}, buffIds = {}, debuffIds = {} },
}

_G.DoiteConditions_AuraSnapshot = auraSnapshot

-- 创建隐藏的工具提示一次；不要每次扫描都重新 SetOwner
local function _EnsureTooltip()
  if not DoiteConditionsTooltip then
    DoiteConditionsTooltip = CreateFrame("GameTooltip", "DoiteConditionsTooltip", UIParent, "GameTooltipTemplate")
    DoiteConditionsTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    DoiteConditionsTooltip:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0) -- 屏幕外
    if DoiteConditionsTooltip.SetScript then
      DoiteConditionsTooltip:SetScript("OnTooltipCleared", nil)
      DoiteConditionsTooltip:SetScript("OnHide", nil)
    end
  end
end

--UnitBuff/UnitDebuff 返回 auraId，Nampower 给出名称/纹理。
local _AuraNameTipLeft1FS = nil
local function _GetAuraName(unit, index, isDebuff)
  if not unit or not index or index < 1 then
    return nil
  end

  local tex, auraId
  if isDebuff then
    -- Nampower：纹理，层数，类型，法术 ID
    tex, _, _, auraId = UnitDebuff(unit, index)
  else
    -- Nampower：纹理，层数，法术 ID
    tex, _, auraId = UnitBuff(unit, index)
  end
  if not tex then
    -- 此索引处无光环：真正的列表结束标记
    return nil
  end

  local name

  -- Nampower：auraId (spellId) -> name
  if auraId then
    local n = _NP_SpellNameAndTexture(auraId)
    if type(n) == "string" and n ~= "" then
      name = n
    end
  end

  -- 备选：工具提示名称（原始版本/奇怪的光环/错误的 ID）
  if not name then
    _EnsureTooltip()
    DoiteConditionsTooltip:ClearLines()

    if isDebuff then
      if DoiteConditionsTooltip.SetUnitDebuff then
        DoiteConditionsTooltip:SetUnitDebuff(unit, index)
      elseif DoiteConditionsTooltip.SetUnitBuff then
        DoiteConditionsTooltip:SetUnitBuff(unit, index, "HARMFUL")
      end
    else
      if DoiteConditionsTooltip.SetUnitBuff then
        DoiteConditionsTooltip:SetUnitBuff(unit, index, "HELPFUL")
      end
    end

    if not _AuraNameTipLeft1FS then
      _AuraNameTipLeft1FS = _G["DoiteConditionsTooltipTextLeft1"]
    end
    local fs = _AuraNameTipLeft1FS
    if fs and fs.GetText then
      local t = fs:GetText()
      if t and t ~= "" then
        name = t
      end
    end
  end

  -- 返回一个非 nil 的哨兵，以便调用者不会认为列表结束。
  if not name then
    return ""
  end

  return name
end

-- 仅工具提示的回退，由 _ScanUnitAuras() 使用 - 已经具有 tex/auraId。
local _DoiteCondTipLeft1FS = nil
local function _GetAuraName_TooltipOnly(unit, index, isDebuff)
  if not unit or not index or index < 1 then
    return ""
  end

  _EnsureTooltip()
  DoiteConditionsTooltip:ClearLines()

  if isDebuff then
    if DoiteConditionsTooltip.SetUnitDebuff then
      DoiteConditionsTooltip:SetUnitDebuff(unit, index)
    elseif DoiteConditionsTooltip.SetUnitBuff then
      DoiteConditionsTooltip:SetUnitBuff(unit, index, "HARMFUL")
    end
  else
    if DoiteConditionsTooltip.SetUnitBuff then
      DoiteConditionsTooltip:SetUnitBuff(unit, index, "HELPFUL")
    end
  end

  if not _DoiteCondTipLeft1FS then
    _DoiteCondTipLeft1FS = _G["DoiteConditionsTooltipTextLeft1"]
  end

  local fs = _DoiteCondTipLeft1FS
  if fs and fs.GetText then
    local t = fs:GetText()
    if t and t ~= "" then
      return t
    end
  end

  -- 非 nil 哨兵（匹配 _GetAuraName() 对于“无法解析名称”的行为）
  return ""
end

local function _ScanTargetUnitAuras()
  local unit = "target"

  -- 使用缓存查找：auraName -> { 跟踪此名称的键列表 }
  local trackedByName = _GetTrackedByName()

  local snap = auraSnapshot[unit]
  if not snap then
    return
  end

  local prevBuffs, prevDebuffs = snap.buffCount or 0, snap.debuffCount or 0

  -- UnitBuff/UnitDebuff：此处仅抓取第一个返回（纹理）是有意的。
  local curBuffTex = UnitBuff(unit, 1)
  local curDebuffTex = UnitDebuff(unit, 1)

  -- 如果以前没有光环，现在仍然没有，则跳过扫描。
  if (not curBuffTex and prevBuffs == 0) and (not curDebuffTex and prevDebuffs == 0) then
    return
  end

  local buffs, debuffs = snap.buffs, snap.debuffs
  local buffIds, debuffIds = snap.buffIds, snap.debuffIds
  if not buffs or not debuffs then
    return
  end


  -- 跟踪实际占用的槽位数
  local buffCount = 0
  local debuffCount = 0

  -- 清除以前的快照
  for k in pairs(buffs) do
    buffs[k] = nil
  end
  for k in pairs(debuffs) do
    debuffs[k] = nil
  end
  if buffIds then
    for k in pairs(buffIds) do
      buffIds[k] = nil
    end
  end
  if debuffIds then
    for k in pairs(debuffIds) do
      debuffIds[k] = nil
    end
  end

  local cache = IconCache

  ----------------------------------------------------------------
  -- 增益
  ----------------------------------------------------------------
  local i = 1
  while true do
    -- Nampower：纹理，层数，法术 ID
    local tex, _, auraId = UnitBuff(unit, i)
    if not tex then
      break
    end
    buffCount = buffCount + 1

    -- 解析名称一次：Nampower id->name 快速路径，如果需要则仅工具提示回退
    local name = nil
    if auraId then
      name = _NP_SpellNameAndTexture(auraId)
    end

    if (not name) or name == "" then
      local n2 = _GetAuraName_TooltipOnly(unit, i, false)
      if n2 and n2 ~= "" then
        name = n2
      end
    end

    if name and name ~= "" then
      buffs[name] = true
      if buffIds and auraId then
        buffIds[auraId] = true
      end

      local list = trackedByName and trackedByName[name]
      if list and type(list) == "table" then
        -- 缓存同步（但永远不要用缓存阻塞实时更新）
        if tex and cache[name] ~= tex then
          cache[name] = tex
          if DoiteAurasDB and DoiteAurasDB.cache then
            DoiteAurasDB.cache[name] = tex
          end
        end

        local count = table.getn(list)
        local auraIdStr = nil
        for j = 1, count do
          local key = list[j]

          -- 1) 始终更新数据库图标
          if key and DoiteAurasDB and DoiteAurasDB.spells then
            local s = DoiteAurasDB.spells[key]
            if s then
              if tex and tex ~= "" then
                s.iconTexture = tex
              end
              if auraId and (not s.spellid or s.spellid == "") then
                if not auraIdStr then
                  auraIdStr = tostring(auraId)
                end
                s.spellid = auraIdStr
              end
              if (not s.displayName or s.displayName == "") then
                s.displayName = name
              end
            end
          end

          -- 2) 即使缓存已有，也更新实时图标框架
          local f = _GetIconFrame(key)
          if f and f.icon and tex and f.icon.GetTexture and f.icon.SetTexture then
            if f.icon:GetTexture() ~= tex then
              f.icon:SetTexture(tex)
            end
          end
        end
      end
    end

    i = i + 1
  end

  ----------------------------------------------------------------
  -- 减益
  ----------------------------------------------------------------
  i = 1
  while true do
    -- Nampower：纹理，层数，类型，法术 ID
    local tex, _, _, auraId = UnitDebuff(unit, i)
    if not tex then
      break
    end

    debuffCount = debuffCount + 1

    local name = nil
    if auraId then
      name = _NP_SpellNameAndTexture(auraId)
    end

    if (not name) or name == "" then
      local n2 = _GetAuraName_TooltipOnly(unit, i, true)
      if n2 ~= nil and n2 ~= "" then
        name = n2
      end
    end

    if type(name) == "string" and name ~= "" then
      debuffs[name] = true
      if debuffIds and auraId then
        debuffIds[auraId] = true
      end

      local list = trackedByName and trackedByName[name]
      if list and type(list) == "table" then
        if tex and cache[name] ~= tex then
          cache[name] = tex
          DoiteAurasDB.cache[name] = tex
        end

        local count = table.getn(list)
        local auraIdStr = nil
        for j = 1, count do
          local key = list[j]
          if key and DoiteAurasDB.spells then
            local s = DoiteAurasDB.spells[key]
            if s then
              if tex and tex ~= "" then
                s.iconTexture = tex
              end
              if auraId and (not s.spellid or s.spellid == "") then
                if not auraIdStr then
                  auraIdStr = tostring(auraId)
                end
                s.spellid = auraIdStr
              end
              if (not s.displayName or s.displayName == "") then
                s.displayName = name
              end
            end
          end

          local f = _GetIconFrame(key)
          if f and f.icon and tex and f.icon:GetTexture() ~= tex then
            f.icon:SetTexture(tex)
          end
        end
      end
    end

    i = i + 1
  end

  -- 记住实际使用了多少个增益/减益槽位
  snap.buffCount = buffCount
  snap.debuffCount = debuffCount
end

---------------------------------------------------------------
-- 本地辅助函数
---------------------------------------------------------------

-- 全局别名，以便更新循环可以调用它而无需捕获局部
_G.DoiteConditions_ScanUnitAuras = _ScanTargetUnitAuras

local function InCombat()
  return UnitAffectingCombat("player") == 1
end

local function InRaid()
  return (GetNumRaidMembers() or 0) > 0
end

local function InPartyOnly()
  -- 队伍，但不是团队
  return (GetNumPartyMembers() or 0) > 0 and not InRaid()
end

local function InGroup()
  return InRaid() or (GetNumPartyMembers() or 0) > 0
end

-- 能量百分比 (0..100)
local function GetPowerPercent()
  local max = UnitManaMax("player")
  if not max or max <= 0 then
    return 0
  end
  local cur = UnitMana("player")
  return (cur * 100) / max
end

-- === 剩余时间辅助函数 ===

-- 比较辅助函数：如果 rem（秒）通过 comp 与 target（秒）的比较，则返回 true
local function _RemainingPasses(rem, comp, target)
  if not rem or not comp or target == nil then
    return true
  end
  if comp == ">=" then
    return rem >= target
  elseif comp == "<=" then
    return rem <= target
  elseif comp == "==" then
    return rem == target
  end
  return true
end

-- 技能冷却剩余时间（秒），通过法术书索引；如果不在冷却中则返回 nil
local function _AbilityRemainingSeconds(spellIndex, bookType)
  if not spellIndex then
    return nil
  end
  local start, dur, enable = GetSpellCooldown(spellIndex, bookType or BOOKTYPE_SPELL)
  if start and dur and start > 0 and dur > 0 then
    local rem = (start + dur) - GetTime()
    if rem and rem > 0 then
      return rem
    end
  end
  return nil
end

-- 通过法术*名称*剩余时间（搜索法术书，然后调用 _AbilityRemainingSeconds）
local function _AbilityRemainingByName(spellName)
  if not spellName then
    return nil
  end
  local idx = _GetSpellIndexByName(spellName)
  local bt = _G.DoiteConditions_SpellBookTypeCache[spellName]
  return _AbilityRemainingSeconds(idx, bt or BOOKTYPE_SPELL)
end

-- 冷却时间（剩余，总持续时间）通过法术名称；如果不在法术书中，则返回 nil,nil
local function _AbilityCooldownByName(spellName)
  if not spellName then
    return nil, nil
  end
  local idx = _GetSpellIndexByName(spellName)
  local bt = _G.DoiteConditions_SpellBookTypeCache[spellName]
  if not idx then
    return nil, nil
  end

  local start, dur = GetSpellCooldown(idx, bt or BOOKTYPE_SPELL)
  if start and dur and start > 0 and dur > 0 then
    local rem = (start + dur) - GetTime()
    if rem < 0 then
      rem = 0
    end
    return rem, dur
  else
    return 0, dur or 0
  end
end

-- 法术冷却检查（将仅公共冷却视为“不在冷却中”）
local function _IsSpellOnCooldown(spellIndex, bookType)
  if not spellIndex then
    return false
  end
  local start, dur = GetSpellCooldown(spellIndex, bookType or BOOKTYPE_SPELL)
  return (start and start > 0 and dur and dur > 1.5) and true or false
end

-- Nampower 加速缓存：spellName -> spellId（最高等级）
local SpellUsableIdCache = {}

-- NamPower 安全的 IsSpellUsable 包装器。
local function _SafeSpellUsable(spellNameBase, spellIndex, bookType)
  if not IsSpellUsable or not spellNameBase then
    return 1, 0
  end

  ----------------------------------------------------------------
  -- 1) 快速路径：Nampower 存在 -> spellId + IsSpellUsable(id)
  ----------------------------------------------------------------
  if GetSpellIdForName then
    local sid = SpellUsableIdCache[spellNameBase]

    if sid == nil then
      sid = GetSpellIdForName(spellNameBase)
      SpellUsableIdCache[spellNameBase] = sid or false
    end

    if sid and sid ~= 0 then
      local ok, u, noMana = pcall(IsSpellUsable, sid)
      if ok and u ~= nil then
        return u, noMana
      end
    end
    -- 如果没有有效 id / pcall 失败，则回退到旧版
  end

  ----------------------------------------------------------------
  -- 2) 旧版回退：旧的基于字符串的行为（很少使用）
  ----------------------------------------------------------------
  local bt = bookType or BOOKTYPE_SPELL
  local arg = spellNameBase

  if GetSpellName and spellIndex then
    local cached = SpellUsableArgCache[spellIndex]
    if cached and cached.base == spellNameBase then
      arg = cached.arg
    else
      local idxForRank = spellIndex
      local i = spellIndex + 1
      while i <= 200 do
        local n = GetSpellName(i, bt)
        if not n or n ~= spellNameBase then
          break
        end
        idxForRank = i
        i = i + 1
      end

      local n, r = GetSpellName(idxForRank, bt)
      if n and r and r ~= "" then
        arg = n .. "(" .. r .. ")"
      else
        arg = spellNameBase
      end

      SpellUsableArgCache[spellIndex] = { base = spellNameBase, arg = arg }
    end
  end

  -- 2a) 首选旧版调用
  local ok, u, noMana = pcall(IsSpellUsable, arg)
  if ok and u ~= nil then
    return u, noMana
  end

  -- 2b) 最后的手段：纯名称（旧行为）
  ok, u, noMana = pcall(IsSpellUsable, spellNameBase)
  if ok and u ~= nil then
    return u, noMana
  end

  -- 3) 最终回退：视为可用，以便图标不会永远消失
  return 1, 0
end

-- === 物品辅助函数（装备栏/背包查找和冷却）=======================
local INV_SLOT_TRINKET1 = 13
local INV_SLOT_TRINKET2 = 14
local INV_SLOT_MAINHAND = 16
local INV_SLOT_OFFHAND = 17
local INV_SLOT_RANGED = 18
local INV_SLOT_AMMO = (GetInventorySlotInfo and GetInventorySlotInfo("AmmoSlot")) or 0

local DOITE_ITEM_CD_IGNORE = 5.0

local function _SlotIndexForName(name)
  if name == "TRINKET1" then
    return INV_SLOT_TRINKET1
  end
  if name == "TRINKET2" then
    return INV_SLOT_TRINKET2
  end
  if name == "MAINHAND" then
    return INV_SLOT_MAINHAND
  end
  if name == "OFFHAND" then
    return INV_SLOT_OFFHAND
  end
  if name == "RANGED" then
    return INV_SLOT_RANGED
  end
  if name == "AMMO" then
    return INV_SLOT_AMMO
  end
  return nil
end

-- 每个键的内存，用于 TRINKET_FIRST：“最先就绪者胜出”并保持胜者
local _TrinketFirstMemory = {}

local function _ClearTrinketFirstMemory()
  for k in pairs(_TrinketFirstMemory) do
    _TrinketFirstMemory[k] = nil
  end
end
_G.DoiteConditions_ClearTrinketFirstMemory = _ClearTrinketFirstMemory

-- 扫描玩家装备栏 + 背包以查找配置的物品
local _ItemScanCache = {}
local _ItemScanGen = 0
local _ItemScanCacheSize = 0

local function _InvalidateItemScanCache()
  _ItemScanGen = _ItemScanGen + 1

  -- 保持 gen 有界（偏执）
  if _ItemScanGen > 1000000 then
    _ItemScanGen = 1
    for k in pairs(_ItemScanCache) do
      _ItemScanCache[k] = nil
    end
    _ItemScanCacheSize = 0
  end
end

local _RefreshPlayerItemSnapshot

local function _GetPlayerItemSnapshot()
  local snap = DoiteConditions._daPlayerItemSnapshot
  if not snap then
    snap = {}
    DoiteConditions._daPlayerItemSnapshot = snap
  end
  if DoiteConditions._daItemSnapshotDirty and _RefreshPlayerItemSnapshot then
    _RefreshPlayerItemSnapshot()
  end
  return snap
end

_RefreshPlayerItemSnapshot = function()
  local snap = DoiteConditions._daPlayerItemSnapshot
  if not snap then
    snap = {}
    DoiteConditions._daPlayerItemSnapshot = snap
  end
  if not (UnitExists and UnitExists("player")) then
    DoiteConditions._daItemSnapshotDirty = true
    return
  end
  if not snap.eq then
    snap.eq = {}
  end
  local eq = snap.eq
  local s = 1
  while s <= 19 do
    local info = GetEquippedItem and GetEquippedItem("player", s) or nil
    eq[s] = info
    s = s + 1
  end
  snap.bags = GetBagItems and GetBagItems() or nil
  if GetAmmo then
    local ammoId, ammoCount = GetAmmo()
    snap.ammoId = ammoId
    snap.ammoCount = ammoCount
  else
    snap.ammoId = nil
    snap.ammoCount = 0
  end
  DoiteConditions._daItemSnapshotDirty = false
  _InvalidateItemScanCache()
end

local function _ScanPlayerItemInstances(data)
  if not data then
    return false, false, nil, nil, 0, 0
  end

  local expectedId = data.itemId or data.itemID
  if expectedId then
    expectedId = tonumber(expectedId)
  end
  local expectedName = data.itemName or data.displayName or data.name

  -- 缓存键
  local cacheKey = nil
  if expectedId then
    if data._daItemScanCacheKeyType ~= "id" or data._daItemScanCacheKeyId ~= expectedId then
      if data._daItemScanCacheKey then
        if _ItemScanCache[data._daItemScanCacheKey] ~= nil then
          _ItemScanCacheSize = _ItemScanCacheSize - 1
        end
        _ItemScanCache[data._daItemScanCacheKey] = nil
      end
      data._daItemScanCacheKey = "id:" .. expectedId
      data._daItemScanCacheKeyType = "id"
      data._daItemScanCacheKeyId = expectedId
      data._daItemScanCacheKeyName = nil
    end
    cacheKey = data._daItemScanCacheKey
  elseif expectedName and expectedName ~= "" then
    if data._daItemScanCacheKeyType ~= "name" or data._daItemScanCacheKeyName ~= expectedName then
      if data._daItemScanCacheKey then
        if _ItemScanCache[data._daItemScanCacheKey] ~= nil then
          _ItemScanCacheSize = _ItemScanCacheSize - 1
        end
        _ItemScanCache[data._daItemScanCacheKey] = nil
      end
      data._daItemScanCacheKey = "name:" .. expectedName
      data._daItemScanCacheKeyType = "name"
      data._daItemScanCacheKeyName = expectedName
      data._daItemScanCacheKeyId = nil
    end
    cacheKey = data._daItemScanCacheKey
  else
    if data._daItemScanCacheKey then
      if _ItemScanCache[data._daItemScanCacheKey] ~= nil then
        _ItemScanCacheSize = _ItemScanCacheSize - 1
      end
      _ItemScanCache[data._daItemScanCacheKey] = nil
    end
    data._daItemScanCacheKey = nil
    data._daItemScanCacheKeyType = nil
    data._daItemScanCacheKeyId = nil
    data._daItemScanCacheKeyName = nil
  end

  if cacheKey then
    local c = _ItemScanCache[cacheKey]
    if c then
      if (c.gen == _ItemScanGen) then
        return c.hasEquipped, c.hasBag, c.eqSlot, c.bagLoc, c.eqCount, c.bagCount
      end
    end
  end

  local hasEquipped, hasBag = false, false
  local firstEquippedSlot = nil
  local firstBagBag = nil
  local firstBagSlot = nil
  local eqCount, bagCount = 0, 0
  local nameCache = DoiteConditions._itemNameByIdCache
  if not nameCache then
    nameCache = {}
    DoiteConditions._itemNameByIdCache = nameCache
  end

  local bag, slot = nil, nil
  if FindPlayerItemSlot then
    if expectedId then
      bag, slot = FindPlayerItemSlot(expectedId)
    elseif expectedName and expectedName ~= "" then
      bag, slot = FindPlayerItemSlot(expectedName)
    end
  end
  if slot then
    if bag == nil then
      hasEquipped = true
      firstEquippedSlot = slot
    elseif bag >= 0 and bag <= 4 then
      hasBag = true
      firstBagBag = bag
      firstBagSlot = slot
    end
  end

  local snap = _GetPlayerItemSnapshot()
  local eq = snap.eq
  if eq then
    local eslot, itemInfo
    for eslot, itemInfo in pairs(eq) do
      local itemId = itemInfo and itemInfo.itemId
      local match = false
      if itemId then
        if expectedId then
          match = (itemId == expectedId)
        elseif expectedName and expectedName ~= "" then
          local nm = nameCache[itemId]
          if nm == nil then
            nm = GetItemInfo and GetItemInfo(itemId) or nil
            if nm then
              nameCache[itemId] = nm
            end
          end
          match = (nm and nm == expectedName) and true or false
        end
      end
      if match then
        hasEquipped = true
        if not firstEquippedSlot then
          firstEquippedSlot = eslot
        end
        local ccount = tonumber(itemInfo.stackCount) or 1
        if ccount <= 0 then
          ccount = 1
        end
        eqCount = eqCount + ccount
      end
    end
  end

  local bags = snap.bags
  if not bags and GetBagItems then
    bags = GetBagItems()
    snap.bags = bags
  end
  if bags then
    local b = 0
    while b <= 4 do
      local bagData = bags[b]
      if bagData then
        local bslot, itemInfo
        for bslot, itemInfo in pairs(bagData) do
          local itemId = itemInfo and itemInfo.itemId
          local match = false
          if itemId then
            if expectedId then
              match = (itemId == expectedId)
            elseif expectedName and expectedName ~= "" then
              local nm = nameCache[itemId]
              if nm == nil then
                nm = GetItemInfo and GetItemInfo(itemId) or nil
                if nm then
                  nameCache[itemId] = nm
                end
              end
              match = (nm and nm == expectedName) and true or false
            end
          end
          if match then
            hasBag = true
            if firstBagBag == nil then
              firstBagBag = b
              firstBagSlot = bslot
            end
            local ccount = tonumber(itemInfo.stackCount) or 1
            if ccount <= 0 then
              ccount = 1
            end
            bagCount = bagCount + ccount
          end
        end
      end
      b = b + 1
    end
  end

  -- 存储在缓存中（重用 bagLoc 表）
  if cacheKey then
    local c = _ItemScanCache[cacheKey]
    if not c then
      c = {}
      _ItemScanCache[cacheKey] = c
      _ItemScanCacheSize = _ItemScanCacheSize + 1
    end

    c.gen = _ItemScanGen
    c.hasEquipped = hasEquipped
    c.hasBag = hasBag
    c.eqSlot = firstEquippedSlot
    c.eqCount = eqCount
    c.bagCount = bagCount

    if firstBagBag ~= nil then
      if not c.bagLoc then
        c.bagLoc = {}
      end
      c.bagLoc.bag = firstBagBag
      c.bagLoc.slot = firstBagSlot
    else
      c.bagLoc = nil
    end

    return c.hasEquipped, c.hasBag, c.eqSlot, c.bagLoc, c.eqCount, c.bagCount
  end

  if firstBagBag ~= nil then
    data._daItemScanBagLoc = data._daItemScanBagLoc or {}
    data._daItemScanBagLoc.bag = firstBagBag
    data._daItemScanBagLoc.slot = firstBagSlot
    return hasEquipped, hasBag, firstEquippedSlot, data._daItemScanBagLoc, eqCount, bagCount
  end

  return hasEquipped, hasBag, firstEquippedSlot, nil, eqCount, bagCount
end

-- 单个装备栏槽位：它是否有物品，该物品是否在冷却中？
-- 返回：hasItem, onCooldown, rem, dur, isUseItem
local function _GetInventorySlotState(slot)
  if not slot then
    return false, false, 0, 0, false
  end
  local link = GetInventoryItemLink and GetInventoryItemLink("player", slot) or nil
  local snap = _GetPlayerItemSnapshot()
  local eq = snap.eq
  local info = eq and eq[slot] or nil
  if (not info) and GetEquippedItem then
    info = GetEquippedItem("player", slot)
  end
  local itemId = info and info.itemId
  if (not itemId) and link then
    local _, _, idStr = str_find(link, "item:(%d+)")
    if idStr then
      itemId = tonumber(idStr)
    end
  end
  if not itemId then
    return false, false, 0, 0, false
  end

  local start, dur, enable = GetInventoryItemCooldown("player", slot)
  local rem, onCd = 0, false
  if start and dur and start > 0 and dur > DOITE_ITEM_CD_IGNORE then

    rem = (start + dur) - GetTime()
    if rem < 0 then
      rem = 0
    end
    onCd = (rem > 0)
  else
    dur = dur or 0
  end

  -- 通过 API 优先检测可用/“使用：”物品，然后槽位工具提示回退。
  -- 尽可能按 itemId 缓存（稳定键，避免基于链接变体的键增长）。
  local useCache = DoiteConditions._itemUseCache
  if not useCache then
    useCache = {}
    DoiteConditions._itemUseCache = useCache
    DoiteConditions._itemUseCacheN = 0
  end

  local cacheKey = itemId

  local isUse = (useCache[cacheKey] == true)
  if not isUse then

    -- 如果装备物品当前处于冷却中，将其视为可使用。
    if onCd then
      isUse = true
    end

    -- 当提供时，优先使用结构化的装备物品元数据。
    if (not isUse) and info then
      if info.hasUseSpell == true or info.hasUseEffect == true then
        isUse = true
      else
        local useSpellId = tonumber(info.useSpellId) or 0
        if useSpellId > 0 then
          isUse = true
        else
          local spellId = tonumber(info.spellId) or 0
          if spellId > 0 then
            isUse = true
          end
        end
      end
    end

    -- 对于不公开上述丰富字段的客户端/辅助函数，回退处理。
    if (not isUse) and GetItemSpell then
      local spellName = GetItemSpell(itemId)
      if spellName and spellName ~= "" then
        isUse = true
      end
    end

    -- 最后手段：解析实际的装备槽位工具提示，用于未可靠提供法术元数据的经典/本地辅助函数。
    if (not isUse) and _EnsureTooltip and DoiteConditionsTooltip and DoiteConditionsTooltip.SetInventoryItem then
      _EnsureTooltip()
      DoiteConditionsTooltip:ClearLines()
      DoiteConditionsTooltip:SetInventoryItem("player", slot)

      local i = 1
      while i <= 15 do
        local fs = _CondTipLeft[i]
        if not fs or not fs.GetText then
          break
        end
        local txt = fs:GetText()
        if txt and txt ~= "" then
          local lower = string.lower(txt)
          if str_find(lower, "use:") or str_find(lower, "use ")
              or str_find(lower, "consume") then
            isUse = true
            break
          end
        end
        i = i + 1
      end
    end

    -- 仅缓存正向命中，以免在物品/法术元数据尚不可用时永久保留错误否定。
    if isUse then
      useCache[cacheKey] = true

      DoiteConditions._itemUseCacheN = (DoiteConditions._itemUseCacheN or 0) + 1
      if DoiteConditions._itemUseCacheN > 256 then
        for k in pairs(useCache) do
          useCache[k] = nil
        end
        DoiteConditions._itemUseCacheN = 0
      end
    end
  end

  return true, onCd, rem, dur or 0, isUse
end

-- 核心物品状态，由条件检查和文本覆盖使用
local _ItemStateScratch = {
  hasItem = false,
  isMissing = false,
  passesWhere = true,
  modeMatches = true,
  rem = nil,
  dur = nil,

  -- 临时附魔追踪（武器槽位）
  teRem = nil,       -- 剩余秒数（如果过期则为 0）
  teCharges = nil,   -- 剩余充能（如果无/过期则为 0）
  teItemId = nil,    -- 被附魔武器的缓存 itemId
  teEnchantId = nil, -- 缓存临时附魔 ID

  -- 堆叠/数量跟踪
  eqCount = 0, -- 已装备装备中的总量
  bagCount = 0, -- 背包中的总量（0..4）
  totalCount = 0, -- eqCount + bagCount
  effectiveCount = 0, -- 受 whereBag/whereEquipped 限制的数量
}

local function _ResetItemState(state)
  state.hasItem = false
  state.isMissing = false
  state.passesWhere = true
  state.modeMatches = true
  state.rem = nil
  state.dur = nil

  -- 重置临时附魔
  state.teRem = nil
  state.teCharges = nil
  state.teItemId = nil
  state.teEnchantId = nil

  -- 重置计数
  state.eqCount = 0
  state.bagCount = 0
  state.totalCount = 0
  state.effectiveCount = 0
end

local function _EvaluateItemCoreState(data, c)
  local state = _ItemStateScratch
  _ResetItemState(state)

  if not data or not c then
    return state
  end

  local invSlotName = c.inventorySlot

  -- --------------------------------------------------------------------
  -- 1) 合成装备栏槽位条目（已装备的饰品/武器）
  -- --------------------------------------------------------------------
  if invSlotName and invSlotName ~= "" then
    local mode = c.mode or ""
    local key = data and data.key

    -- 直接 1:1 槽位绑定（TRINKET1 / TRINKET2 / MAINHAND / OFFHAND / RANGED / AMMO）
    if invSlotName == "TRINKET1" or invSlotName == "TRINKET2"
        or invSlotName == "MAINHAND" or invSlotName == "OFFHAND"
        or invSlotName == "RANGED" or invSlotName == "AMMO" then

      local idx = _SlotIndexForName(invSlotName)
      local hasItem, onCd, rem, dur
      if invSlotName == "AMMO" then
        local snap = _GetPlayerItemSnapshot()
        hasItem = (snap.ammoId ~= nil)
        onCd = false
        rem = 0
        dur = 0
      else
        hasItem, onCd, rem, dur = _GetInventorySlotState(idx)
      end
      state.hasItem = hasItem
      state.isMissing = not hasItem
      state.rem = rem
      state.dur = dur

      if mode == "oncd" then
        state.modeMatches = (hasItem and onCd)
      elseif mode == "notcd" then
        state.modeMatches = (hasItem and (not onCd))
      elseif mode == "both" then
        state.modeMatches = hasItem
      else
        state.modeMatches = true
      end

      ----------------------------------------------------------------
      -- 临时附魔跟踪（Nampower GetEquippedItem）用于武器槽位合成条目
      -- 由 displayName == "---已装备的武器栏位---" 保护
      --
      -- 特殊情况：
      --  * mode == "notcd"/"both" + textTimeRemaining => 显示临时附魔剩余时间
      --  * textStackCounter / stacksEnabled    => 使用临时附魔充能作为“计数”
      --
      -- 即使被附魔的武器当前未装备在该槽位，缓存也会持续，因此倒计时继续。
      ----------------------------------------------------------------
      if (invSlotName == "MAINHAND" or invSlotName == "OFFHAND")
          and data.displayName == "---已装备的武器栏位---" then

        local needTE = false
        if ((mode == "notcd" or mode == "both")
              and (c.textTimeRemaining == true or c.remainingEnabled == true or c.enchant ~= nil))
            or (c.textStackCounter == true)
            or (c.stacksEnabled == true) then
          needTE = true
        end

        if needTE then
          local now = GetTime()

          local te = DoiteConditions._daTempEnchantCache
          if not te then
            te = {}
            DoiteConditions._daTempEnchantCache = te
          end

          local slotC = te[idx]
          if not slotC then
            slotC = {}
            te[idx] = slotC
          end

          -- 按时间使缓存的附魔过期
          if slotC.endTime and slotC.endTime <= now then
            slotC.endTime = nil
            slotC.tempEnchantId = nil
            slotC.charges = 0
          end

          -- 从当前装备在此槽位的物品进行速率限制刷新
          -- （UNIT_INVENTORY_CHANGED 也会触发此操作）
          local lastT = slotC.t or 0
          if (now - lastT) > 0.15 then
            slotC.t = now

            if GetEquippedItem then
              local info = GetEquippedItem("player", idx)

              -- 始终跟踪槽位中的当前物品，以便陈旧的 itemId 不会粘住。
              if info and info.itemId then
                slotC.itemId = info.itemId
              else
                slotC.itemId = nil
              end

              local teId = info and info.tempEnchantId or nil
              local msLeft = info and info.tempEnchantmentTimeLeftMs or nil

              if info and teId and teId > 0 then
                -- 可选的每个槽位内存（处理时间左未返回的罕见情况）
                local memE = slotC._e
                if not memE then
                  memE = {}
                  slotC._e = memE
                end
                local memC = slotC._c
                if not memC then
                  memC = {}
                  slotC._c = memC
                end

                local key = tostring(slotC.itemId or 0) .. ":" .. tostring(teId)

                -- 如果附魔 ID 更改，重置绝对计时器 - 不要保持陈旧时间。
                local prevTeId = slotC.tempEnchantId
                if prevTeId ~= teId then
                  slotC.endTime = nil
                  slotC._msLeft = nil
                end
                slotC.tempEnchantId = teId

                if msLeft and msLeft > 0 then
                  local prevMs = slotC._msLeft

                  -- 重要：
                  -- 某些客户端以粗略步长更新 tempEnchantmentTimeLeftMs（或者它可能卡住）。
                  -- 每次刷新都用 (now + msLeft) 覆盖 endTime 会导致倒计时冻结。
                  if (not slotC.endTime) or (not prevMs) then
                    slotC.endTime = now + (msLeft / 1000)
                  else
                    if msLeft > (prevMs + 2000) then
                      -- timeLeft 明显增加 => 刷新/重新应用
                      slotC.endTime = now + (msLeft / 1000)
                    elseif msLeft < (prevMs - 10000) then
                      -- 粗略的大幅下降 => 纠正我们的 endTime，使过期不会严重错误
                      slotC.endTime = now + (msLeft / 1000)
                    end
                    -- 否则：忽略（可能是“卡住的”msLeft），让 endTime 自然滴答
                  end

                  slotC._msLeft = msLeft
                  memE[key] = slotC.endTime
                else
                  slotC._msLeft = nil

                  -- 仅当还没有有效的运行计时器时才回退到内存。
                  if (not slotC.endTime) or (slotC.endTime <= now) then
                    local endT = memE[key]
                    if endT and endT > now then
                      slotC.endTime = endT
                    else
                      slotC.endTime = nil
                    end
                  end
                end

                -- 充能（层数）遵循相同的“槽位当前已附魔”事实。
                if info.tempEnchantmentCharges ~= nil then
                  local ch = tonumber(info.tempEnchantmentCharges) or 0
                  if ch < 0 then
                    ch = 0
                  end
                  slotC.charges = ch
                  memC[key] = ch
                else
                  local ch = memC[key]
                  if ch == nil then
                    ch = 0
                  end
                  slotC.charges = ch
                end

              else
                -- 此槽位当前装备的武器上没有临时附魔 => 清除显示。
                slotC.endTime = nil
                slotC.tempEnchantId = nil
                slotC.charges = 0
              end
            end
          end

          local remSec = 0
          if slotC.endTime then
            remSec = slotC.endTime - now
            if remSec < 0 then
              remSec = 0
            end
          end

          -- 如果计时器过期，充能也视为过期
          if remSec <= 0 then
            slotC.charges = 0
          end

          state.teRem = remSec
          state.teCharges = slotC.charges or 0
          state.teItemId = slotC.itemId
          state.teEnchantId = slotC.tempEnchantId

          -- 当武器槽位处于 notcd/both 时，“剩余时间”指的是临时附魔持续时间
          if (mode == "notcd" or mode == "both") then
            if c and (c.textTimeRemaining == true or c.remainingEnabled == true) then
              state.rem = remSec or 0
              state.dur = 0
            end
          end
        end
      end

      -- 复合“已装备的饰品”合成条目
    elseif invSlotName == "TRINKET_FIRST" or invSlotName == "TRINKET_BOTH" then
      local has1, on1, rem1, dur1, isUse1 = _GetInventorySlotState(INV_SLOT_TRINKET1)
      local has2, on2, rem2, dur2, isUse2 = _GetInventorySlotState(INV_SLOT_TRINKET2)

      local use1 = has1 and isUse1
      local use2 = has2 and isUse2

      -- 如果没有可用/有使用效果的物品，永远不显示
      if not use1 and not use2 then
        state.hasItem = false
        state.isMissing = true
        state.modeMatches = false
        state.passesWhere = true

        -- 合成条目的计数
        state.eqCount = 0
        state.bagCount = 0
        state.totalCount = 0
        state.effectiveCount = 0

        return state
      end

      state.hasItem = (use1 or use2)
      state.isMissing = not state.hasItem

      if invSlotName == "TRINKET_FIRST" then
        -- “最先就绪”语义，每个键有内存：
        local prevSlot = key
            and _TrinketFirstMemory[key]
            and _TrinketFirstMemory[key].slot
            or nil
        local winner = prevSlot

        if mode == "notcd" then
          -- 如果槽位是可用的饰品且不在冷却中，则视为“就绪”。
          local function slotReady(useFlag, onCdFlag)
            return useFlag and (not onCdFlag)
          end

          -- 如果之前的胜者停止就绪/可用，则丢弃。
          if winner == INV_SLOT_TRINKET1
              and not slotReady(use1, on1) then
            winner = nil
          elseif winner == INV_SLOT_TRINKET2
              and not slotReady(use2, on2) then
            winner = nil
          end

          if not winner then
            if slotReady(use1, on1) then
              winner = INV_SLOT_TRINKET1
            elseif slotReady(use2, on2) then
              winner = INV_SLOT_TRINKET2
            end
          end

          if winner == INV_SLOT_TRINKET1 then
            state.modeMatches = slotReady(use1, on1)
            state.rem = rem1
            state.dur = dur1
          elseif winner == INV_SLOT_TRINKET2 then
            state.modeMatches = slotReady(use2, on2)
            state.rem = rem2
            state.dur = dur2
          else
            state.modeMatches = false
          end

          if key then
            if winner then
              _TrinketFirstMemory[key] = _TrinketFirstMemory[key] or {}
              _TrinketFirstMemory[key].slot = winner
            else
              _TrinketFirstMemory[key] = nil
            end
          end

        elseif mode == "both" then
          -- 只要存在任何可用饰品就显示。
          state.modeMatches = (use1 or use2)

          -- 如果任何饰品在冷却中，优先显示一个在冷却中的饰品（类似于 oncd），
          -- 否则回退到 notcd 的“最先就绪”语义。
          local found, bestRem, bestDur = false, nil, nil

          if use1 and on1 then
            found = true
            bestRem = rem1
            bestDur = dur1
            winner = INV_SLOT_TRINKET1
          end
          if use2 and on2 then
            if (not found) or (rem2 < bestRem) then
              found = true
              bestRem = rem2
              bestDur = dur2
              winner = INV_SLOT_TRINKET2
            end
          end

          if found then
            state.rem = bestRem
            state.dur = bestDur
          else
            -- 没有在冷却中的 => 使用来自 notcd 的现有“最先就绪”内存逻辑
            local function slotReady(useFlag, onCdFlag)
              return useFlag and (not onCdFlag)
            end

            -- 如果之前的胜者停止就绪/可用，则丢弃。
            if winner == INV_SLOT_TRINKET1 and not slotReady(use1, on1) then
              winner = nil
            elseif winner == INV_SLOT_TRINKET2 and not slotReady(use2, on2) then
              winner = nil
            end

            if not winner then
              if slotReady(use1, on1) then
                winner = INV_SLOT_TRINKET1
              elseif slotReady(use2, on2) then
                winner = INV_SLOT_TRINKET2
              end
            end

            if winner == INV_SLOT_TRINKET1 then
              state.rem = rem1
              state.dur = dur1
            elseif winner == INV_SLOT_TRINKET2 then
              state.rem = rem2
              state.dur = dur2
            else
              -- 仍然“modeMatches”为真，如果存在任何可用饰品；没有特定计时器
              state.rem = 0
              state.dur = dur1 or dur2
            end
          end

          if key then
            if winner then
              _TrinketFirstMemory[key] = _TrinketFirstMemory[key] or {}
              _TrinketFirstMemory[key].slot = winner
            else
              _TrinketFirstMemory[key] = nil
            end
          end

        elseif mode == "oncd" then
          -- 在冷却中模式：任何在冷却中的可用饰品都通过；选择其中一个
          local found, bestRem, bestDur = false, nil, nil

          if use1 and on1 then
            found = true
            bestRem = rem1
            bestDur = dur1
            winner = INV_SLOT_TRINKET1
          end
          if use2 and on2 then
            if (not found) or (rem2 < bestRem) then
              found = true
              bestRem = rem2
              bestDur = dur2
              winner = INV_SLOT_TRINKET2
            end
          end

          state.modeMatches = found
          state.rem = bestRem
          state.dur = bestDur

          if key then
            if winner then
              _TrinketFirstMemory[key] = _TrinketFirstMemory[key] or {}
              _TrinketFirstMemory[key].slot = winner
            else
              _TrinketFirstMemory[key] = nil
            end
          end  

        else
          -- 没有显式模式：仅报告任何可用饰品的存在。
          state.modeMatches = (use1 or use2)
          state.rem = nil
          state.dur = nil
        end

      else
        -- TRINKET_BOTH：要求所有已装备的可用饰品处于请求状态。
        if mode == "oncd" then
          local ok = true
          if use1 and not on1 then
            ok = false
          end
          if use2 and not on2 then
            ok = false
          end
          state.modeMatches = ok
          if ok then
            local r1 = (use1 and rem1) or 0
            local r2 = (use2 and rem2) or 0
            state.rem = (r1 > r2) and r1 or r2
            state.dur = dur1 or dur2
          end
          
        elseif mode == "both" then
          -- both => 只要至少有一个可用饰品就显示
          local any = (use1 or use2)
          state.modeMatches = any
          if any then
            -- 显示时：显示那些在冷却中的饰品中的最大剩余时间，否则 0。
            local r1 = (use1 and on1 and rem1) or 0
            local r2 = (use2 and on2 and rem2) or 0
            state.rem = (r1 > r2) and r1 or r2
            state.dur = dur1 or dur2
          end
          
        elseif mode == "notcd" then
          local ok = true
          if use1 and on1 then
            ok = false
          end
          if use2 and on2 then
            ok = false
          end
          state.modeMatches = ok
          if ok then
            state.rem = 0
            state.dur = dur1 or dur2
          end
        else
          state.modeMatches = true
        end
      end
    end

    -- 合成条目没有 Whereabouts；视为通过
    state.passesWhere = true

    -- 对于合成条目，如果物品存在，将“堆叠计数”视为 1
    if state.hasItem then
      -- 特殊情况：已装备的武器槽位可以显示临时附魔充能
      if (invSlotName == "MAINHAND" or invSlotName == "OFFHAND")
          and data.displayName == "---已装备的武器栏位---"
          and (mode == "notcd" or mode == "both")
          and (c.textStackCounter == true or c.stacksEnabled == true) then

        local ch = state.teCharges
        if ch == nil then
          ch = 0
        end
        if ch < 0 then
          ch = 0
        end

        state.eqCount = ch
        state.bagCount = 0
        state.totalCount = ch
        state.effectiveCount = ch
      else
        local slotCount
        if invSlotName == "AMMO" then
          local snap = _GetPlayerItemSnapshot()
          local cnt = snap.ammoCount or 0
          slotCount = tonumber(cnt) or 0
          if slotCount < 0 then
            slotCount = 0
          end
        else
          slotCount = 0
          if idx ~= nil then
            local snap = _GetPlayerItemSnapshot()
            local eq = snap.eq
            local info = eq and eq[idx] or nil
            if info and info.stackCount ~= nil then
              slotCount = tonumber(info.stackCount) or 0
            end
          end
          if slotCount <= 0 then
            slotCount = 1
          end
        end
        state.eqCount = slotCount
        state.bagCount = 0
        state.totalCount = slotCount
        state.effectiveCount = slotCount
      end
    else
      state.eqCount = 0
      state.bagCount = 0
      state.totalCount = 0
      state.effectiveCount = 0
    end

    return state
  end

  -- --------------------------------------------------------------------
  -- 2) 正常物品（Whereabouts：已装备 / 背包 / 缺失）
  -- --------------------------------------------------------------------
  local hasEquipped, hasBag, eqSlot, bagLoc, eqCount, bagCount = _ScanPlayerItemInstances(data)
  local missing = (not hasEquipped and not hasBag)

  state.hasItem = not missing
  state.isMissing = missing

  -- 原始计数
  state.eqCount = eqCount or 0
  state.bagCount = bagCount or 0
  state.totalCount = (state.eqCount or 0) + (state.bagCount or 0)

  local passWhere = false
  if c.whereEquipped and hasEquipped then
    passWhere = true
  end
  if c.whereBag and hasBag then
    passWhere = true
  end
  if c.whereMissing and missing then
    passWhere = true
  end
  state.passesWhere = passWhere

  -- 仅从选定的 Whereabouts 计算有效计数
  local eff = 0
  if c.whereEquipped and state.eqCount and state.eqCount > 0 then
    eff = eff + state.eqCount
  end
  if c.whereBag and state.bagCount and state.bagCount > 0 then
    eff = eff + state.bagCount
  end
  -- 如果仅设置了 whereMissing，eff 保持为 0；DoiteEdit 会在那里隐藏堆叠 UI。
  state.effectiveCount = eff

  if not passWhere then
    return state
  end

  -- 如果存在，优先使用已装备的，否则使用第一个背包出现
  local kind, loc = nil, nil
  if eqSlot then
    kind = "inv"
    loc = eqSlot
  elseif bagLoc then
    kind = "bag"
    loc = bagLoc
  end

  if kind and loc then
    local hasItem, onCd, rem, dur
    local snap = _GetPlayerItemSnapshot()
    if kind == "inv" then
      local eq = snap.eq
      local eqInfo = eq and eq[loc] or nil
      if (not eqInfo) and GetEquippedItem then
        eqInfo = GetEquippedItem("player", loc)
      end
      hasItem = (eqInfo and eqInfo.itemId) and true or false
      local start, dur0, enable = GetInventoryItemCooldown("player", loc)
      if start and dur0 and start > 0 and dur0 > DOITE_ITEM_CD_IGNORE then

        rem = (start + dur0) - GetTime()
        if rem < 0 then
          rem = 0
        end
        onCd = (rem > 0)
        dur = dur0
      else
        onCd = false
        rem = 0
        dur = dur0 or 0
      end
    else
      local bags = snap.bags
      local bagData = bags and bags[loc.bag] or nil
      local bInfo = bagData and bagData[loc.slot] or nil
      if (not bInfo) and GetBagItem then
        bInfo = GetBagItem(loc.bag, loc.slot)
      end
      hasItem = (bInfo and bInfo.itemId) and true or false
      local start, dur0, enable = GetContainerItemCooldown(loc.bag, loc.slot)
      if start and dur0 and start > 0 and dur0 > DOITE_ITEM_CD_IGNORE then

        rem = (start + dur0) - GetTime()
        if rem < 0 then
          rem = 0
        end
        onCd = (rem > 0)
        dur = dur0
      else
        onCd = false
        rem = 0
        dur = dur0 or 0
      end
    end

    if not state.hasItem and hasItem then
      state.hasItem = true
      state.isMissing = false
    end

    state.rem = rem
    state.dur = dur

    local mode = c.mode or ""
    if mode == "oncd" then
      state.modeMatches = (hasItem and onCd)
    elseif mode == "notcd" then
      state.modeMatches = (hasItem and (not onCd))
    elseif mode == "both" then
      state.modeMatches = hasItem
    else
      state.modeMatches = true
    end
  else
    -- 根本没有实例（无 eqSlot/bagLoc）
    if missing and c.whereMissing then
      state.modeMatches = true
      state.rem = 0
      state.dur = 0
    else
      local mode = c.mode or ""
      if mode == "oncd" or mode == "notcd" then
        state.modeMatches = false
      end
    end
  end

  return state
end

-- =================================================================
-- 滑块检查
-- =================================================================

-- 对于滑块门控：哪些法术我们实际看到施放了？
_G["Doite_SliderSeen"] = _G["Doite_SliderSeen"] or {}

local function _MarkSliderSeen(spellName)
  if not spellName or spellName == "" then
    return
  end
  Doite_SliderSeen[spellName] = GetTime() or 0
end

-- ============================================================
-- 触发窗口计时器（非冷却计时器）
-- ============================================================
_G.DoiteConditions_ProcWindowDurations = _G.DoiteConditions_ProcWindowDurations or {
  ["压制"] = 4.0,
  ["复仇"] = 4.0,
  ["偷袭"] = 4.0,
  ["还击"] = 4.0,
  ["奥术涌动"] = 4.0,
  ["割伤"] = 4.0,
}

-- SpellName -> 绝对结束时间 (GetTime() + duration)
_G.DoiteConditions_ProcUntil = _G.DoiteConditions_ProcUntil or {}
-- 每个图标的上升沿检测器，用于“可用触发”图标
_G.DoiteConditions_ProcLastShowByKey = _G.DoiteConditions_ProcLastShowByKey or {}
local function _ProcWindowDuration(spellName)
  if not spellName then
    return nil
  end
  local d = _G.DoiteConditions_ProcWindowDurations and _G.DoiteConditions_ProcWindowDurations[spellName]
  if type(d) == "number" and d > 0 then
    return d
  end
  return nil
end

local function _ProcWindowSet(spellName, endTime)
  if not spellName or not endTime then
    return
  end
  _G.DoiteConditions_ProcUntil[spellName] = endTime

  dirty_ability_time = true
  dirty_ability = true

  _RequestImmediateEval()
end

local function _ProcWindowRemaining(spellName)
  if not spellName then
    return nil
  end
  local untilT = _G.DoiteConditions_ProcUntil and _G.DoiteConditions_ProcUntil[spellName]
  if untilT then
    local rem = untilT - (_Now() or 0)
    if rem and rem > 0 then
      return rem
    end
  end
  return nil
end

-- 保持战士特定的目标匹配状态
local _WarriorProc = { OP_until = 0, OP_target = nil, REV_until = 0 }
-- 规范法术名称解析器（优先使用法术书名称）
local function _GetCanonicalSpellNameFromData(data)
  if not data or type(data) ~= "table" then
    return nil
  end
  if data.name and data.name ~= "" then
    -- 这是规范的法术书名称（GetSpellName 看到的）
    return data.name
  end
  if data.displayName and data.displayName ~= "" then
    return data.displayName
  end
  return nil
end

-- =================================================================
-- Nampower: SPELL_GO_SELF -> 冷却所有权（仅玩家）
-- 仅用于门控“即将冷却结束”滑块，以便共享 CD 的技能
-- 仅在玩家实际施放时才显示滑块。
-- =================================================================

-- Nampower 将这些事件隐藏在 NP_EnableSpellGoEvents 之后（默认 0）。
-- 如果可用则启用；如果 CVar 缺失，则无害。
do
  if GetCVar and SetCVar then
    local ok, v = pcall(GetCVar, "NP_EnableSpellGoEvents")
    if ok and v and tostring(v) == "0" then
      pcall(SetCVar, "NP_EnableSpellGoEvents", "1")
    end
  end
end

local _daCast = CreateFrame("Frame", "DoiteCast")
_daCast:RegisterEvent("SPELL_GO_SELF")
_daCast:SetScript("OnEvent", function()
  -- SPELL_GO_SELF 参数 (Nampower):
  -- arg1=itemId (如果不是物品触发则为 0)
  -- arg2=spellId
  local itemId = arg1
  local spellId = arg2

  -- 仅跟踪真正的法术施放以用于滑块所有权（忽略物品触发）
  if itemId and itemId ~= 0 then
    return
  end
  if not spellId then
    return
  end

  -- Nampower id->name 映射
  local name = nil
  if GetSpellNameAndRankForId then
    local n = GetSpellNameAndRankForId(spellId)
    if type(n) == "string" and n ~= "" then
      name = n
    end
  end

  if not name or name == "" then
    return
  end

  -- debug：上次看到的 GO_SELF
  Doite_LastGoSelfId = spellId
  Doite_LastGoSelfName = name

  _MarkSliderSeen(name)
end)

-- 检查职业并仅注册玩家需要的触发事件
local _daClassCL = CreateFrame("Frame", "DoiteClassCL")
local _daClassCL2 = CreateFrame("Frame", "DoiteClassCL2")

local function _HasTrackedProcSpell(spellName)
  if not spellName or spellName == "" then
    return false
  end
  local db = DoiteAurasDB and DoiteAurasDB.spells
  if not db then
    return false
  end

  local _, data
  for _, data in pairs(db) do
    if type(data) == "table" and data.type == "Ability" then
      local nm = data.name or data.displayName
      if nm == spellName then
        return true
      end
    end
  end

  return false
end

do
  local _, cls = UnitClass("player")
  cls = cls and string.upper(cls) or ""

  if cls == "WARRIOR" then
    -- 压制：需要闪避检测
    _daClassCL:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
    _daClassCL:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")

    _daClassCL:SetScript("OnEvent", function()
      if not _HasTrackedProcSpell("压制") then
        return
      end

      local line = arg1
      if not line or line == "" then
        return
      end

      -- 压制：目标闪避了你的攻击
      local tgt
      local _, _, t1 = str_find(line, "你的(.+)被(.+)躲闪过去了")
      if t1 then
        tgt = t1
      else
        local _, _, t2 = str_find(line, "你躲闪开了")
        tgt = t2
      end

      if tgt then
        tgt = str_gsub(tgt, "%s*[%.!%?]+%s*$", "")
        _WarriorProc.OP_target = tgt

        local now = _Now()
        local dur = _ProcWindowDuration("压制") or 4.0
        _WarriorProc.OP_until = now + dur
        _ProcWindowSet("压制", _WarriorProc.OP_until)
      end
    end)

    -- 复仇：需要受到攻击/格挡/招架/闪避
    _daClassCL2:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
    _daClassCL2:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS")

    _daClassCL2:SetScript("OnEvent", function()
      if not _HasTrackedProcSpell("复仇") then
        return
      end

      local line = arg1
      if not line or line == "" then
        return
      end

      -- 复仇：你闪避/招架/格挡了
      if str_find(line, "你躲闪开了")
          or str_find(line, "你招架住了")
          or str_find(line, "你格挡")
          or ((str_find(line, "击中你") or str_find(line, "对你造成致命一击"))
          and str_find(line, "被格挡）")) then

        local now = _Now()
        local dur = _ProcWindowDuration("复仇") or 4.0
        _WarriorProc.REV_until = now + dur
        _ProcWindowSet("复仇", _WarriorProc.REV_until)

        dirty_ability = true
      end
    end)

  elseif cls == "ROGUE" then
    -- 偷袭：需要闪避检测
    _daClassCL:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
    _daClassCL:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")

    _daClassCL:SetScript("OnEvent", function()
      if not _HasTrackedProcSpell("偷袭") then
        return
      end

      local line = arg1
      if not line or line == "" then
        return
      end

      -- 偷袭：目标闪避了你的攻击
      local dodged = false
      local _, _, t1 = str_find(line, "你的(.+)被(.+)躲闪过去了")
      if t1 then
        dodged = true
      else
        local _, _, t2 = str_find(line, "你躲闪开了")
        if t2 then
          dodged = true
        end
      end

      if dodged then
        local dur = _ProcWindowDuration("偷袭")
        if dur then
          local now = _Now()
          _ProcWindowSet("偷袭", now + dur)
          dirty_ability = true
        end
      end
    end)

    -- 还击：在你的招架时触发（不绑定目标）
    _daClassCL2:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
    _daClassCL2:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS")

    _daClassCL2:SetScript("OnEvent", function()
      if not _HasTrackedProcSpell("还击") then
        return
      end

      local line = arg1
      if not line or line == "" then
        return
      end

      -- 还击：你招架了攻击
      if str_find(line, "你招架住了") then
        local dur = _ProcWindowDuration("还击") or 4.0
        local now = _Now()
        _ProcWindowSet("还击", now + dur)
        dirty_ability = true
      end
    end)

  elseif cls == "MAGE" then
    -- 奥术涌动：需要抵抗检测
    _daClassCL:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")

    _daClassCL:SetScript("OnEvent", function()
      if not _HasTrackedProcSpell("奥术涌动") then
        return
      end

      local line = arg1
      if not line or line == "" then
        return
      end

      -- 奥术涌动：法术被抵抗（完全或部分）
      if str_find(line, "你的(.+)被(.+)抵抗了")
          or str_find(line, "抵抗）")
          or str_find(line, "被抵抗")
          or str_find(line, "^(.+)抵抗了你的(.-)") then

        local dur = _ProcWindowDuration("奥术涌动")
        if dur then
          local now = _Now()
          _ProcWindowSet("奥术涌动", now + dur)
          dirty_ability = true
        end
      end
    end)
  elseif cls == "HUNTER" then
    -- 割伤：玩家暴击时触发，不受目标绑定限制。
    _daClassCL:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
    _daClassCL:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")

    _daClassCL:SetScript("OnEvent", function()
      if not _HasTrackedProcSpell("割伤") then
        return
      end

      local line = arg1
      if not line or line == "" then
        return
      end

      -- 普攻暴击："你对(.+)造成(.+)的致命一击伤害。"
      -- 技能暴击："你的(.+)对(.+)造成(.+)的致命一击伤害。"
      if str_find(line, "你对(.+)造成(.+)的致命一击伤害。")
          or str_find(line, "你的(.+)对(.+)造成(.+)的致命一击伤害。") then
        local dur = _ProcWindowDuration("割伤")
        if dur then
          local now = _Now()
          _ProcWindowSet("割伤", now + dur)
          dirty_ability = true
        end
      end
    end)
  end
end

-- 由技能可用覆盖使用的辅助函数
local function _Warrior_Overpower_OK()
  if (_Now() > _WarriorProc.OP_until) then
    return false
  end
  if not UnitExists("target") then
    return false
  end
  local tname = UnitName("target")
  return (tname ~= nil and _WarriorProc.OP_target ~= nil and tname == _WarriorProc.OP_target)
end

local function _Warrior_Revenge_OK()
  return _Now() <= _WarriorProc.REV_until
end

-- 压制/复仇的剩余触发窗口时间（秒），如果无触发则返回 nil
local function _WarriorProcRemainingForSpell(spellName)
  -- 向后兼容名称：现在使用共享的触发窗口存储。
  return _ProcWindowRemaining(spellName)
end


----------------------------------------------------------------
-- DoiteAuras 幻灯片管理器
----------------------------------------------------------------
local SlideMgr = {
  active = {},
}
_G.DoiteConditions_SlideMgr = SlideMgr

local _slideTick = CreateFrame("Frame", "DoiteSlideTick")
_slideTick:Hide()
_slideTick:SetScript("OnUpdate", function()
  local now = GetTime()
  local anyActive = false

  for key, s in pairs(SlideMgr.active) do
    if now >= s.endTime then
      SlideMgr.active[key] = nil
    else
      anyActive = true
    end
  end

  -- 滑动时，强制技能频繁重绘，以便位置平滑更新。
  if anyActive then
    dirty_ability = true
  else
    this:Hide()
  end
end)

-- 开始或刷新 'key' 的动画
-- endTime = GetTime() + remaining（在调用者内部限制剩余时间）
local function _NormalizeSlideDirection(dir)
  if dir == "左" then
    return "left"
  elseif dir == "右" then
    return "right"
  elseif dir == "上" then
    return "up"
  elseif dir == "下" then
    return "down"
  elseif dir == "居中" then
    return "center"
  end
  return dir or "center"
end

function SlideMgr:StartOrUpdate(key, dir, baseX, baseY, endTime)
  local st = self.active[key]
  local now = GetTime()
  dir = _NormalizeSlideDirection(dir)

  if not endTime then
    endTime = now
  end

  if not st then
    st = {
      dir = dir or "center",
      baseX = baseX or 0,
      baseY = baseY or 0,
      endTime = endTime,
    }

    -- 捕获此幻灯片窗口的长度一次，以便
    -- t 从 1 → 0 干净运行，中心 alpha 从 0 → 1。
    local total = st.endTime - now
    if not total or total <= 0 then
      total = 0.01
    end
    st.total = total

    self.active[key] = st
  else
    st.dir = dir or st.dir
    st.baseX = baseX or st.baseX
    st.baseY = baseY or st.baseY

    local curEnd = st.endTime or now
    local newEnd = endTime

    local curRem = curEnd - now
    local newRem = newEnd - now
    if curRem < 0 then
      curRem = 0
    end
    if newRem < 0 then
      newRem = 0
    end

    -- 抗抖动：
    if (newRem > 0.10) and (newRem <= 1.60) and (curRem > 1.60) then
      newEnd = curEnd
      newRem = curRem
    else
      -- 忽略微小的向后抖动（微小刷新噪声）
      if (newEnd < curEnd) and ((curEnd - newEnd) < 0.20) then
        newEnd = curEnd
        newRem = curRem
      end
    end

    -- 硬限制：滑动时，调用者不应延长幻灯片
    local total = st.total or 0
    if total and total > 0 then
      local maxEnd = now + total
      if newEnd > maxEnd then
        newEnd = maxEnd
      end
    end

    if newEnd > curEnd then
      local grow = newEnd - now
      if grow > (st.total or 0) and grow <= 3.05 then
        st.total = grow
      end
    end

    st.endTime = newEnd
    -- 注意：st.total 有意保持稳定（除了上面的小“增长”修复）
  end

  _slideTick:Show()
end

function SlideMgr:Stop(key)
  self.active[key] = nil
end

-- 查询当前偏移/alpha。返回：
-- active:boolean, dx:number, dy:number, alpha:number, suppressGlow:boolean, suppressGrey:boolean
function SlideMgr:Get(key)
  local st = self.active[key]
  if not st then
    return false, 0, 0, 1, false, false
  end

  local now = GetTime()
  local total = st.total or 3.0
  if total <= 0 then
    total = 0.01
  end

  local remaining = (st.endTime or now) - now
  if remaining < 0 then
    remaining = 0
  end

  -- 如果 endTime 漂移超过幻灯片窗口，将其拉回。
  if remaining > total then
    if remaining > (total + 0.25) then
      st.endTime = now + total
    end
    remaining = total
  end

  -- t 在幻灯片窗口上从 1 → 0
  local t = remaining / total
  if t < 0 then
    t = 0
  elseif t > 1 then
    t = 1
  end

  local farX, farY = 0, 0
  if st.dir == "left" then
    farX, farY = -80, 0
  elseif st.dir == "right" then
    farX, farY = 80, 0
  elseif st.dir == "up" then
    farX, farY = 0, 80
  elseif st.dir == "down" then
    farX, farY = 0, -80
  else
    farX, farY = 0, 0
  end

  local dx = farX * t
  local dy = farY * t

  local alpha
  if st.dir == "center" then
    alpha = 1.0 - t
  else
    alpha = 1.0
  end
  if alpha < 0 then
    alpha = 0
  elseif alpha > 1 then
    alpha = 1
  end

  return true, dx, dy, alpha, true, true
end

-- 供 ApplyVisuals 在滑动时获取最新基础锚点
function SlideMgr:UpdateBase(key, baseX, baseY)
  local st = self.active[key]
  if st then
    st.baseX = baseX or st.baseX
    st.baseY = baseY or st.baseY
  end
end

-- 供 ApplyVisuals 读取当前基础（即使不滑动）
function SlideMgr:GetBase(key)
  local st = self.active[key]
  if st then
    return st.baseX or 0, st.baseY or 0
  end
  return 0, 0
end

-- 读取图标的基础（保存的）XY（匹配 CreateOrUpdateIcon 布局优先级）
local function _GetBaseXY(key, dataTbl)
  -- 默认值
  local x, y = 0, 0

  -- 主要来源：DoiteAurasDB.spells
  if DoiteAurasDB and DoiteAurasDB.spells and key and DoiteAurasDB.spells[key] then
    local s = DoiteAurasDB.spells[key]
    x = s.offsetX or s.x or x
    y = s.offsetY or s.y or y
  end

  -- 可选覆盖：旧版 DoiteDB.icons 布局（如果存在）
  if DoiteDB and DoiteDB.icons and key and DoiteDB.icons[key] then
    local L = DoiteDB.icons[key]
    x = (L.posX or L.offsetX or x)
    y = (L.posY or L.offsetY or y)
  end

  return x, y
end

-- 仅玩家光环剩余（秒）；如果未计时/未找到，返回 nil。
local function _PlayerAuraRemainingSeconds(auraName, auraSpellId, addedViaSpellId)
  local useSpellIdOnly = (addedViaSpellId == true)
  local playerAuraSlot = nil

  if useSpellIdOnly then
    local sid = tonumber(auraSpellId) or 0
    if sid > 0 then
      playerAuraSlot = DoitePlayerAuras.GetActiveAuraSlotBySpellId(sid)
    end
  else
    if not auraName then
      return nil
    end
    playerAuraSlot = DoitePlayerAuras.GetActiveAuraSlot(auraName)
  end

  if playerAuraSlot then
    local _, remainingMs, _ = GetPlayerAuraDuration(playerAuraSlot)
    if remainingMs and remainingMs > 0 then
      return remainingMs / 1000
    end
  end

  if not useSpellIdOnly then
    local remaining = DoitePlayerAuras.GetHiddenBuffRemaining(auraName)
    if remaining and remaining > 0 then
      return remaining
    end
  end

  return nil
end

_G["DoiteAuras_GetPlayerAuraRemainingSeconds"] =
    _PlayerAuraRemainingSeconds

local function _ResolvePlayerAuraTextOverride(overrideValue, fallbackName, fallbackSpellId, fallbackUseSpellId)
  local v = overrideValue
  if type(v) == "string" then
    v = str_gsub(v, "^%s*(.-)%s*$", "%1")
    if v == "" then
      v = nil
    end
  else
    v = nil
  end

  if not v then
    return fallbackName, fallbackSpellId, fallbackUseSpellId
  end

  local sid = tonumber(v)
  if sid and sid > 0 then
    return fallbackName, sid, true
  end

  return v, 0, false
end

local function _DoiteTrackAuraOwnership(spellKey, unit, useSpellId)
  if not DoiteTrack or not spellKey or not unit then
    return nil, false, nil, false, false, false
  end

  -- 硬依赖合并的辅助函数
  local rem, recording, sid, isMine, isOther, ownerKnown

  if useSpellId == true then
    if not DoiteTrack.GetAuraOwnershipBySpellId then
      return nil, false, nil, false, false, false
    end
    rem, recording, sid, isMine, isOther, ownerKnown = DoiteTrack:GetAuraOwnershipBySpellId(spellKey, unit)
  else
    if not DoiteTrack.GetAuraOwnershipByName then
      return nil, false, nil, false, false, false
    end
    rem, recording, sid, isMine, isOther, ownerKnown = DoiteTrack:GetAuraOwnershipByName(spellKey, unit)
  end

  -- 规范化布尔值
  isMine = (isMine == true)
  isOther = (isOther == true)

  local known = (ownerKnown == true) or isMine or isOther

  -- 规范化剩余时间
  if rem ~= nil and rem <= 0 then
    rem = nil
  end

  -- 对于非玩家单位，如果所有权已知且不是我的，则不暴露剩余时间
  if known and unit ~= "player" and (not isMine) then
    rem = nil
    recording = false
  end

  return rem, recording, sid, isMine, isOther, known
end

-- 统一的剩余时间提供程序，由现有调用站点使用（仅 DoiteTrack）。
local function _DoiteTrackAuraRemainingSeconds(spellKey, unit, useSpellId)
  if not DoiteTrack or not spellKey or not unit then
    return nil
  end

  if useSpellId == true and DoiteTrack.GetAuraRemainingSecondsBySpellId then
    local rem = DoiteTrack:GetAuraRemainingSecondsBySpellId(spellKey, unit)
    if rem and rem > 0 then
      return rem
    end
  elseif DoiteTrack.GetAuraRemainingSecondsByName then
    local rem = DoiteTrack:GetAuraRemainingSecondsByName(spellKey, unit)
    if rem and rem > 0 then
      return rem
    end
  end

  if DoiteTrack.GetAuraRemainingOrRecordingByName then
    local rem2 = DoiteTrack:GetAuraRemainingOrRecordingByName(spellKey, unit)
    if rem2 and rem2 > 0 then
      return rem2
    end
  end

  return nil
end


-- 使用 DoiteTrack 对单位进行剩余时间比较。
local function _DoiteTrackRemainingPass(spellKey, unit, comp, threshold, useSpellId)
  if not DoiteTrack or not spellKey or not unit or not comp or threshold == nil then
    return nil
  end

  if useSpellId == true and DoiteTrack.RemainingPassesBySpellId then
    return DoiteTrack:RemainingPassesBySpellId(spellKey, unit, comp, threshold)
  elseif DoiteTrack.RemainingPassesByName then
    -- 插件辅助函数在内部处理比较
    return DoiteTrack:RemainingPassesByName(spellKey, unit, comp, threshold)
  end

  -- DoiteTrack 内部回退：如果没有辅助函数，使用数值剩余比较
  local rem = _DoiteTrackAuraRemainingSeconds(spellKey, unit, useSpellId)
  if rem and rem > 0 then
    return _RemainingPasses(rem, comp, threshold)
  end

  return nil
end

-- 对于减益检查：如果所有减益槽位都已满，且名称存在于增益中，则将其视为减益命中
local function _TargetHasOverflowDebuff(auraName)
  if not auraName then
    return false
  end

  local snap = auraSnapshot["target"]
  if not snap then
    return false
  end

  local debuffs = snap.debuffs
  if debuffs and debuffs[auraName] == true then
    return true
  end

  local count = snap.debuffCount or 0
  if count < 16 then
    -- 减益条未“满”，因此不要冒险将真正的增益视为减益。
    return false
  end

  local buffs = snap.buffs
  if buffs and buffs[auraName] == true then
    return true
  end

  return false
end

local function _TargetHasAura(auraName, wantDebuff)
  if not auraName or not UnitExists("target") then
    return false
  end
  if not DoiteTargetAuras then
    return false
  end

  if wantDebuff then
    if DoiteTargetAuras.HasDebuff then
      return DoiteTargetAuras.HasDebuff(auraName)
    end
    return false
  end

  if DoiteTargetAuras.HasBuff then
    return DoiteTargetAuras.HasBuff(auraName)
  end
  return false
end

local function _TargetHasAuraBySpellId(spellId, wantDebuff)
  spellId = tonumber(spellId) or 0
  if spellId <= 0 then
    return false
  end
  if not DoiteTargetAuras then
    return false
  end

  if wantDebuff then
    if DoiteTargetAuras.HasDebuffSpellId then
      return DoiteTargetAuras.HasDebuffSpellId(spellId)
    end
    return false
  end

  if DoiteTargetAuras.HasBuffSpellId then
    return DoiteTargetAuras.HasBuffSpellId(spellId)
  end
  return false
end

-- 天赋辅助函数，用于 auraConditions（已知 / 未知）
local function _TalentIsKnownByName(talentName)
  if not talentName or talentName == "" then
    return false
  end
  if not GetNumTalentTabs or not GetNumTalents or not GetTalentInfo then
    return false
  end

  local numTabs = GetNumTalentTabs()
  if not numTabs or numTabs <= 0 then
    return false
  end

  local tab = 1
  while tab <= numTabs do
    local numTalents = GetNumTalents(tab) or 0
    local idx = 1
    while idx <= numTalents do
      local name, _, _, _, rank = GetTalentInfo(tab, idx)
      if name == talentName then
        return (rank and rank > 0)
      end
      idx = idx + 1
    end
    tab = tab + 1
  end

  return false
end

---------------------------------------------------------------
-- 数组压缩辅助函数（防止 auraConditions 出现 nil 空洞）
---------------------------------------------------------------
local function _ArrayMaxIndex(t)
  if not t then
    return 0
  end
  local m = 0
  for k in pairs(t) do
    if type(k) == "number" and k > m then
      m = k
    end
  end
  return m
end

local function _CompactArrayInPlace(t)
  if not t then
    return
  end

  local max = _ArrayMaxIndex(t)
  if max <= 0 then
    return
  end

  local write = 1
  local i = 1
  while i <= max do
    local v = t[i]
    if v ~= nil then
      if write ~= i then
        t[write] = v
        t[i] = nil
      end
      write = write + 1
    end
    i = i + 1
  end

  -- 确保任何尾随的数字槽位为 nil
  i = write
  while i <= max do
    t[i] = nil
    i = i + 1
  end
end

local function _AuraConditions_CheckEntry(entry)
  if not entry or not entry.buffType or not entry.mode then
    return true
  end
  local name = entry.name
  if not name or name == "" then
    return true
  end

  -- ABILITY 分支：通过法术名称使用冷却时间
  if entry.buffType == "ABILITY" then
    if entry.mode == "notcd" or entry.mode == "oncd" then
      local rem, dur = _AbilityCooldownByName(name)
      if rem == nil then
        -- 技能不在法术书中 => 无法满足此条件
        return false
      end

      -- 将仅公共冷却（非常短的持续时间）视为“不在真正冷却中”
      local onCd = false
      if rem and rem > 0 then
        if dur and dur > 1.5 then
          onCd = true
        else
          onCd = false
        end
      end

      if entry.mode == "notcd" then
        return (not onCd)
      else
        return onCd
      end
    else
      return true
    end
  end

  -- ITEM 条件分支（在背包/已装备 或 缺失 + 在/不在冷却 + 数量）
  if entry.buffType == "ITEM" then
    local dataTmp = DoiteConditions._auraCondItemDataTmp
    if not dataTmp then
      dataTmp = {}
      DoiteConditions._auraCondItemDataTmp = dataTmp
    end

    dataTmp.name = name
    dataTmp.displayName = name
    dataTmp.itemName = name
    dataTmp.itemId = entry.itemId or entry.itemID
    dataTmp.itemID = entry.itemID or entry.itemId

    local cTmp = DoiteConditions._auraCondItemCondTmp
    if not cTmp then
      cTmp = {}
      DoiteConditions._auraCondItemCondTmp = cTmp
    end

    cTmp.whereEquipped = (entry.mode ~= "missing") and true or nil
    cTmp.whereBag = (entry.mode ~= "missing") and true or nil
    cTmp.whereMissing = (entry.mode == "missing") and true or nil
    cTmp.inventorySlot = nil
    cTmp.mode = (entry.unit == "oncd") and "oncd" or "notcd"

    local stacksEnabled = (entry.stacksEnabled == true) and (entry.mode ~= "missing")
    cTmp.stacksEnabled = stacksEnabled and true or nil
    cTmp.stacksComp = entry.stacksComp
    cTmp.stacksVal = entry.stacksVal

    local state = _EvaluateItemCoreState(dataTmp, cTmp)

    if entry.mode == "missing" then
      return state and state.isMissing and true or false
    end

    if not (state and state.hasItem and state.passesWhere and state.modeMatches) then
      return false
    end

    if stacksEnabled then
      local comp = cTmp.stacksComp
      local thr = tonumber(cTmp.stacksVal)
      if comp and thr then
        local cnt = state.effectiveCount or 0
        return _StacksPasses(cnt, comp, thr)
      end
    end

    return true
  end

  -- 缓存 TALENT 模式规范化，按原始字符串以避免每次评估进行 lower/gsub 分配
  local _DA_TalentModeKeyByRaw = _DA_TalentModeKeyByRaw or {}

  -- TALENT 条件分支（已知 / 未知）
  if entry.buffType == "TALENT" then
    local modeRaw = entry.mode or ""
    local modeKey = _DA_TalentModeKeyByRaw[modeRaw]
    if not modeKey then
      modeKey = string.lower(modeRaw)
      modeKey = str_gsub(modeKey, "%s+", "")
      _DA_TalentModeKeyByRaw[modeRaw] = modeKey
    end

    local isKnown = _TalentIsKnownByName(name)

    if modeKey == "known" then
      return isKnown
    elseif modeKey == "notknown" then
      return (not isKnown)
    else
      return true
    end
  end
  -- === 结束 TALENT 条件分支 ===

  ----------------------------------------------------------------
  -- 增益 / 减益分支：检查单位光环（+ 可选层数）
  ----------------------------------------------------------------
  local wantDebuff = (entry.buffType == "DEBUFF")

  local unit = entry.unit or "player"
  if unit ~= "player" and unit ~= "target" then
    unit = "player"
  end

  -- 如果显式目标是“target”但没有目标，则不通过
  if unit == "target" and (not UnitExists("target")) then
    return false
  end

  ----------------------------------------------------------------
  -- 层数配置（仅光环）
  -- 如果 stacksEnabled 但缺少 comp/val，则视为禁用。
  -- 在条目上缓存解析的数值阈值（无分配）。
  ----------------------------------------------------------------
  local stacksEnabled = (entry.stacksEnabled == true) and (entry.mode == "found")
  local stacksComp = nil
  local stacksThr = nil

  if stacksEnabled then
    stacksComp = entry.stacksComp
    if not stacksComp or stacksComp == "" then
      stacksEnabled = false
    else
      local raw = entry.stacksVal
      if raw == nil or raw == "" then
        stacksEnabled = false
      else
        -- 在条目上缓存 tonumber(raw)（仅运行时）
        if entry._daStacksValRaw ~= raw then
          entry._daStacksValRaw = raw
          local n = tonumber(raw)
          if n and n >= 0 then
            entry._daStacksValNum = n
          else
            entry._daStacksValNum = nil
          end
        end
        stacksThr = entry._daStacksValNum
        if stacksThr == nil then
          stacksEnabled = false
        end
      end
    end
  end

  ----------------------------------------------------------------
  -- 是否有光环？
  ----------------------------------------------------------------
  local hasAura = false
  local useSpellIdOnly = (entry.Addedviaspellid == true)
  local auraSpellId = tonumber(entry.spellid) or 0

  if unit == "player" then
    if useSpellIdOnly and auraSpellId > 0 then
      if (not wantDebuff) and DoitePlayerAuras.HasBuffSpellId(auraSpellId) then
        hasAura = true
      elseif wantDebuff and DoitePlayerAuras.HasDebuffSpellId(auraSpellId) then
        hasAura = true
      end
    else
      if (not wantDebuff) and DoitePlayerAuras.HasBuff(name) then
        hasAura = true
      elseif wantDebuff and DoitePlayerAuras.HasDebuff(name) then
        hasAura = true
      end
    end
  else
    -- unit == "target"
    if useSpellIdOnly and auraSpellId > 0 then
      hasAura = _TargetHasAuraBySpellId(auraSpellId, wantDebuff)
    else
      hasAura = _TargetHasAura(name, wantDebuff)
    end
  end

  ----------------------------------------------------------------
  -- 如果启用了层数并且光环存在，计算层数并进行比较。
  ----------------------------------------------------------------
  if stacksEnabled and hasAura then
    local cnt = _GetAuraStacksOnUnit(unit, name, wantDebuff, auraSpellId, useSpellIdOnly)
    if cnt == nil then
      cnt = 1
    end
    entry._daStacksLast = cnt

    local pass = _StacksPasses(cnt, stacksComp, stacksThr)

    -- stacksEnabled 意味着 entry.mode == "found"（参见上面的门控）
    return pass
  end

  ----------------------------------------------------------------
  -- 无层数逻辑（或光环不存在）：原始语义
  ----------------------------------------------------------------
  if entry.mode == "found" then
    return hasAura
  elseif entry.mode == "missing" then
    return (not hasAura)
  end

  return true
end

local function _EvaluateAuraConditionsList(list)
  if not list then
    return true
  end

  -- 关键：移除 nil 空洞，以便 table.getn() 或 DoiteLogic._len() 都不会截断列表。
  _CompactArrayInPlace(list)

  local n = table.getn(list)
  if n == 0 then
    return true
  end

  local DL = _G["DoiteLogic"]
  if DL and DL.EvaluateAuraList then
    return DL.EvaluateAuraList(list, _AuraConditions_CheckEntry)
  end

  -- 回退：原始严格 AND 语义
  local i = 1
  while i <= n do
    if not _AuraConditions_CheckEntry(list[i]) then
      return false
    end
    i = i + 1
  end
  return true
end

-- 全局包装器，以减少大型条件函数中的上值
function DoiteConditions_EvaluateAuraConditionsList(list)
  return _EvaluateAuraConditionsList(list)
end

-- === 层数辅助函数 ===

-- 比较：如果 'cnt' 满足 'comp' 与 'target' 的比较，则返回 true
_StacksPasses = function(cnt, comp, target)
  if not cnt or not comp or target == nil then
    return true
  end
  if comp == ">=" then
    return cnt >= target
  elseif comp == "<=" then
    return cnt <= target
  elseif comp == "==" then
    return cnt == target
  end
  return true
end

-- 获取目标（或玩家）上命名光环的层数。对于玩家检查使用 DoitePlayerAuras。
_GetAuraStacksOnUnit = function(unit, auraName, wantDebuff, auraSpellId, addedViaSpellId)
  if not unit or not auraName then
    return nil
  end

  -- 对于玩家检查使用 DoitePlayerAuras
  if unit == "player" then
    if addedViaSpellId == true then
      local sid = tonumber(auraSpellId) or 0
      if sid <= 0 then
        return nil
      end
      if wantDebuff then
        return DoitePlayerAuras.GetDebuffStacksBySpellId(sid)
      else
        return DoitePlayerAuras.GetBuffStacksBySpellId(sid)
      end
    end

    if wantDebuff then
      return DoitePlayerAuras.GetDebuffStacks(auraName)
    else
      return DoitePlayerAuras.GetBuffStacks(auraName)
    end
  end

  if unit == "target" then
    if not DoiteTargetAuras then
      return nil
    end

    if addedViaSpellId == true then
      local sid = tonumber(auraSpellId) or 0
      if sid <= 0 then
        return nil
      end
      if wantDebuff and DoiteTargetAuras.GetDebuffStacksBySpellId then
        return DoiteTargetAuras.GetDebuffStacksBySpellId(sid)
      elseif (not wantDebuff) and DoiteTargetAuras.GetBuffStacksBySpellId then
        return DoiteTargetAuras.GetBuffStacksBySpellId(sid)
      end
      return nil
    end

    if wantDebuff and DoiteTargetAuras.GetDebuffStacks then
      return DoiteTargetAuras.GetDebuffStacks(auraName)
    elseif (not wantDebuff) and DoiteTargetAuras.GetBuffStacks then
      return DoiteTargetAuras.GetBuffStacks(auraName)
    end
    return nil
  end

  -- TODO 改进其他单位的逻辑
  ----------------------------------------------------------------
  -- 主要扫描：非玩家单位的正常 增益/减益 列表
  ----------------------------------------------------------------
  local i = 1
  while i <= 32 do
    local tex, applications, auraId
    if wantDebuff then
      -- 纹理，层数，类型，法术 ID
      tex, applications, _, auraId = UnitDebuff(unit, i)
    else
      -- 纹理，层数，法术 ID
      tex, applications, auraId = UnitBuff(unit, i)
    end
    if not tex then
      break
    end

    local name
    if auraId then
      name = _NP_SpellNameAndTexture(auraId)
    end

    if addedViaSpellId == true then
      if auraId and auraSpellId and tonumber(auraId) == tonumber(auraSpellId) then
        return applications or 1
      end
    elseif name == auraName then
      return applications or 1
    end

    i = i + 1
  end


  -- 如果减益条已“满”（>=16）且光环名称存在于 增益 快照中，则将其视为溢出的减益并从 UnitBuff 读取层数。
  if wantDebuff then
    local snap = auraSnapshot[unit]
    if snap then
      local debCount = snap.debuffCount or 0
      local buffs = snap.buffs

      if debCount >= 16 and buffs and buffs[auraName] then
        -- 首先尝试基于 nampower 的传递（镜像主循环）
        local j = 1
        while j <= 32 do
          local tex2, applications2, auraId2 = UnitBuff(unit, j)
          if not tex2 then
            break
          end

          local name2
          if auraId2 then
            name2 = _NP_SpellNameAndTexture(auraId2)
          end

          if name2 == auraName then
            return applications2 or 1
          end

          j = j + 1
        end

        -- 回退：通过 _GetAuraName 进行基于工具提示的名称解析，然后第二次调用 UnitBuff 以读取层数。
        j = 1
        while j <= 32 do
          local n = _GetAuraName(unit, j, false)
          if n == nil then
            break
          end
          if n ~= "" and n == auraName then
            local _, applications3 = UnitBuff(unit, j)
            return applications3 or 1
          end
          j = j + 1
        end
      end
    end
  end

  return nil
end

-- 快速检查：单位是否有任何指定的增益名称？
local function _TargetHasAnyBuffName(names)
  local unit = "target"
  if not unit or not names then
    return false
  end

  if not DoiteTargetAuras or not DoiteTargetAuras.HasBuff then
    return false
  end

  local n = table.getn(names)
  for i = 1, n do
    if DoiteTargetAuras.HasBuff(names[i]) then
      return true
    end
  end
  return false
end


-- === 生命值 / 连击点数 / 格式化辅助函数 ===

-- 单位的 HP 百分比 (0..100)；如果单位无效或无最大生命值，返回 nil
local function _HPPercent(unit)
  if not unit or not UnitExists(unit) then
    return nil
  end
  local cur = UnitHealth(unit)
  local max = UnitHealthMax(unit)
  if not cur or not max or max <= 0 then
    return nil
  end
  return (cur * 100) / max
end

-- 比较辅助函数：如果 'val' 满足 'comp' 与 'target' 的比较，则返回 true
local function _ValuePasses(val, comp, target)
  if val == nil or comp == nil or target == nil then
    return true
  end
  if comp == ">=" then
    return val >= target
  elseif comp == "<=" then
    return val <= target
  elseif comp == "==" then
    return val == target
  end
  return true
end

-- 连击点数读取器
local function _GetComboPointsSafe()
  if not UnitExists("target") then
    return 0
  end
  local cp = GetComboPoints("player", "target")
  if not cp then
    return 0
  end
  return cp
end

-- 使用连击点数的职业
local function _PlayerUsesComboPoints()
  local _, cls = UnitClass("player")
  cls = cls and string.upper(cls) or ""
  return (cls == "ROGUE" or cls == "DRUID")
end

-- === 目标距离 / 范围 / 单位类型辅助函数 ==========================
-- 编辑器标签使用的映射（“1. 人型生物”， “复合: 1+2”等）
local UNIT_TYPE_INDEX_MAP = {
  [1] = "人型生物",
  [2] = "野兽",
  [3] = "龙类",
  [4] = "亡灵",
  [5] = "恶魔",
  [6] = "巨人",
  [7] = "机械",
  [8] = "元素生物",
}

-- 规范化 “任意”/nil/"" → nil（表示“无限制”）
local function _NormalizeTargetField(val)
  if not val or val == "" or val == "任意" then
    return nil
  end
  if val == "近战范围" then
    return "范围内"
  end
  return val
end

---------------------------------------------------------------
-- 复活法术列表
---------------------------------------------------------------

-- 允许对死亡的友善目标进行距离检查的复活法术。
local _ResurrectionSpellByName = {
  ["复生"] = true, -- 德鲁伊
  ["救赎"] = true, -- 圣骑士
  ["复活术"] = true, -- 牧师
  ["先祖之魂"] = true, -- 萨满
}

local function _IsResurrectionSpell(spellName)
  if not spellName then
    return false
  end
  return _ResurrectionSpellByName[spellName] == true
end

-- Nampower 安全的 IsSpellInRange 包装器；返回 true/false 或 nil（如果未知）
local function _IsSpellInRangeSafe(spellName, unit)
  if not spellName or not unit or type(IsSpellInRange) ~= "function" then
    return nil
  end

  local sid = nil
  if GetSpellIdForName then
    sid = GetSpellIdForName(spellName)
  end

  local ok, res
  if sid and sid ~= 0 then
    ok, res = pcall(IsSpellInRange, sid, unit)
  else
    ok, res = pcall(IsSpellInRange, spellName, unit)
  end
  if not ok then
    return nil
  end

  if res == 1 then
    return true
  elseif res == 0 then
    return false
  end
  return nil
end

-- 主要“targetDistance”评估
local function _PassesTargetDistance(condTbl, unit, spellName)
  if not condTbl or not unit then
    return true
  end

  local val = _NormalizeTargetField(condTbl.targetDistance)
  if not val then
    return true
  end
  if not UnitExists or not UnitExists(unit) then
    return true
  end

  local isDead = UnitIsDead and UnitIsDead(unit) == 1
  local isFriend = UnitIsFriend and UnitIsFriend("player", unit)
  local canAttack = UnitCanAttack and UnitCanAttack("player", unit)
  local isHostile = canAttack and (not isFriend)
  local hasUnitXP = (type(UnitXP) == "function")

  -- 组合位置+范围模式
  local wantPos = nil  -- “背后” / “正面” / nil
  if val == "背后且在范围内" then
    wantPos = "behind"
    val = "范围内"
  elseif val == "正面且在范围内" then
    wantPos = "front"
    val = "范围内"
  end

  -- 对于导入/保存的配置，UnitXP的不可用回退行为：
  -- - 背后/正面 => 视为任意
  -- - 位于背后且在射程内 / 位于正面且在射程内 => 视为在射程内
  if not hasUnitXP then
    if val == "背后" or val == "正面" then
      return true
    end
    wantPos = nil
  end

  -- 首先进行位置检查（也支持上面的组合模式）
  local posOK = true

  if val == "背后" or wantPos == "behind" then
    if hasUnitXP then
      local ok, behind = pcall(UnitXP, "behind", "player", unit)
      if ok then
        posOK = (behind == true)
      else
        posOK = true
      end
    else
      posOK = true
    end

    if val == "背后" then
      return posOK
    end

  elseif val == "正面" or wantPos == "front" then
    if hasUnitXP then
      local okB, behind = pcall(UnitXP, "behind", "player", unit)
      local okS, inSight = pcall(UnitXP, "inSight", "player", unit)
      if not okB then
        behind = false
      end
      if not okS then
        inSight = true
      end
      posOK = (not behind) and (inSight ~= false)
    else
      posOK = true
    end

    if val == "正面" then
      return posOK
    end
  end

  -- 对于基于范围的检查，死亡目标保护
  if val == "范围内" or val == "范围外" then
    if isDead then
      local allowRes = false
      if spellName and isFriend and (not isHostile) then
        if _IsResurrectionSpell(spellName) then
          allowRes = true
        end
      end

      -- 有害的死亡或友善的死亡且非复活法术：距离条件应简单不通过
      if not allowRes then
        return false
      end
    end
  end

  ----------------------------------------------------------------
  -- 基于范围的检查（“范围内”，“范围外”）
  ----------------------------------------------------------------
  local inRange = _IsSpellInRangeSafe(spellName, unit)
  if inRange == nil then
    -- 保持原有行为，即如果无法解析范围，则不隐藏图标。
    inRange = true
  end

  if val == "范围内" then
    if wantPos ~= nil then
      return (posOK and inRange)
    end
    return inRange
  elseif val == "范围外" then
    return (not inRange)
  end

  return true
end

-- 全局包装器，以减少大型条件函数中的上值
function DoiteConditions_PassesTargetDistance(condTbl, unit, spellName)
  return _PassesTargetDistance(condTbl, unit, spellName)
end

-- 简单的“目标活着/死亡”辅助函数
local function _PassesTargetStatus(condTbl, unit)
  if not condTbl or not unit then
    return true
  end

  local wantAlive = (condTbl.targetAlive == true)
  local wantDead = (condTbl.targetDead == true)

  -- 如果未设置任何一个标志，则不进行门控。
  if not wantAlive and not wantDead then
    return true
  end

  if not UnitExists or not UnitExists(unit) then
    -- 没有真实目标：不要仅仅因此杀死图标。
    return true
  end

  local isDead = (UnitIsDead and UnitIsDead(unit) == 1) and true or false

  -- UI 应使这些互斥，但无论如何都要健壮。
  if wantAlive and wantDead then
    return true
  elseif wantAlive then
    return (not isDead)
  elseif wantDead then
    return isDead
  end

  return true
end

-- 全局包装器，以减少大型条件函数中的上值
function DoiteConditions_PassesTargetStatus(condTbl, unit)
  return _PassesTargetStatus(condTbl, unit)
end

-- 解析“复合: 1+2+3” → { “人型生物”，“野兽”，“龙类” }
local function _ParseMultiUnitTypes(val)
  local wanted, seen = {}, {}
  local d
  for d in string.gfind(val, "(%d)") do
    local idx = tonumber(d)
    local name = idx and UNIT_TYPE_INDEX_MAP[idx] or nil
    if name and not seen[name] then
      table.insert(wanted, name)
      seen[name] = true
    end
  end
  return wanted
end

-- 主要“targetUnitType”评估
local function _PassesTargetUnitType(condTbl, unit)
  if not condTbl or not unit then
    return true
  end

  local val = _NormalizeTargetField(condTbl.targetUnitType)
  if not val then
    return true
  end
  if not UnitExists or not UnitExists(unit) then
    return true
  end

  if val == "玩家" then
    if UnitIsPlayer and UnitIsPlayer(unit) then
      return true
    end
    return false

  elseif val == "NPC" then
    if UnitIsPlayer and UnitIsPlayer(unit) then
      return false
    end
    return true

  elseif val == "首领" then
    -- UnitClassification(unit) 返回：“worldboss”，“rareelite”，“elite”，“rare”或“normal”
    local cls = UnitClassification and UnitClassification(unit) or nil
    if not cls or cls == "" then
      -- 没有分类信息；不要杀死图标
      return true
    end
    return (cls == "worldboss")

  elseif val == "非首领" then
    -- Boss 的反面。
    local cls = UnitClassification and UnitClassification(unit) or nil
    if not cls or cls == "" then
      return true
    end
    return (cls ~= "worldboss")
  end

  local creatureType = UnitCreatureType and UnitCreatureType(unit) or nil
  if not creatureType or creatureType == "" then
    -- 没有类型信息；不要杀死图标
    return true
  end

  -- 单一类型 “1. 人型生物”
  local _, _, num, label = str_find(val, "^(%d+)%s*%.%s*(.+)$")
  if num and label and label ~= "" then
    return (creatureType == label)
  end

  -- 多类型： “复合: 1+2+3”
  if string.find(val, "复合:") then
    local wanted = _ParseMultiUnitTypes(val)
    if table.getn(wanted) == 0 then
      return true
    end
    local i
    for i = 1, table.getn(wanted) do
      if creatureType == wanted[i] then
        return true
      end
    end
    return false
  end

  -- 回退：如果有人键入了原始类型，允许精确字符串匹配
  if creatureType == val then
    return true
  end

  -- 默认：在未知标签上不失败
  return true
end

-- 全局包装器，以减少大型条件函数中的上值
function DoiteConditions_PassesTargetUnitType(condTbl, unit)
  return _PassesTargetUnitType(condTbl, unit)
end

-- === 武器过滤器辅助函数（双手/盾牌/双持）=============

local function _ClassifyEquippedSlot(slot)
  if not slot or not GetInventoryItemLink or type(GetItemInfo) ~= "function" then
    return nil
  end

  local link = GetInventoryItemLink("player", slot)
  if not link then
    return nil
  end

  -- 使用相同的 itemID
  local itemId
  local _, _, idStr = str_find(link, "item:(%d+)")
  if idStr then
    itemId = tonumber(idStr)
  end
  if not itemId then
    return { hasItem = true }
  end

  -- xp3 风格的 GetItemInfo：name, link, quality, level, itemType, itemSubType, stack
  local _, _, _, _, itemType, itemSubType = GetItemInfo(itemId)
  if not itemType or itemType == "" then
    -- ItemInfo 尚未缓存；视为“未知武器状态”
    return { hasItem = true }
  end

  local isShield = false
  local isTwoHand = false
  local isWeapon = false

  -- 盾牌是护甲/盾牌
  if itemType == "护甲" and itemSubType == "盾牌" then
    isShield = true
  end

  -- 所有真正的武器共享 itemType == “武器”
  if itemType == "武器" then
    isWeapon = true

    if itemSubType then
      -- “双手剑”，“双手锤”等。
      if str_find(itemSubType, "双手") then
        isTwoHand = true
        -- 没有“双手”前缀的 2H 近战家族
      elseif itemSubType == "法杖"
          or itemSubType == "长柄武器"
          or itemSubType == "鱼竿" then
        isTwoHand = true
      end
    end
  end

  return {
    hasItem = true,
    isShield = isShield,
    isTwoHand = isTwoHand,
    isWeapon = isWeapon,
  }
end

local function _GetEquippedWeaponState()
  -- 返回 hasTwoHand, hasShieldOffhand, isDualWield；如果根本无法检查装备栏，则返回 nil,nil,nil
  if not GetInventoryItemLink or type(GetItemInfo) ~= "function" then
    return nil, nil, nil
  end

  local main = _ClassifyEquippedSlot(INV_SLOT_MAINHAND)
  local off = _ClassifyEquippedSlot(INV_SLOT_OFFHAND)

  if not main and not off then
    return nil, nil, nil
  end

  local hasTwoHand = false
  local hasShield = false
  local isDual = false

  if main and main.isTwoHand then
    hasTwoHand = true
  end

  if off and off.isShield then
    hasShield = true
  end

  -- 双持 = 双手都有真正的武器，且副手不是盾牌
  if main and main.isWeapon and off and off.isWeapon and not off.isShield then
    isDual = true
  end

  return hasTwoHand, hasShield, isDual
end

-- 按原始字符串缓存武器过滤器规范化，以避免重复的 lower/gsub 分配
local _DA_WeaponFilterNormByRaw = {}
local function _NormalizeWeaponFilter(mode)
  if not mode or mode == "" then
    return nil
  end

  local cached = _DA_WeaponFilterNormByRaw[mode]
  if cached ~= nil then
    if cached == false then
      return nil
    end
    return cached
  end

  local s = string.lower(mode)
  s = string.gsub(s, "%s+", "")
  s = string.gsub(s, "%-", "")

  local out = nil
  -- 接受 “双手”，“2手”，“2H”等。
  if s == "twohand" or s == "2hand" or s == "2h" then
    out = "2H"
    -- 接受 “盾牌”
  elseif s == "shield" or s == "sh" then
    out = "SH"
    -- 接受 “双持”，“DW”等。
  elseif s == "dualwield" or s == "dual" or s == "dw" then
    out = "DW"
  end

  -- 为 nil 结果存储 false 哨兵
  if out then
    _DA_WeaponFilterNormByRaw[mode] = out
    return out
  end
  _DA_WeaponFilterNormByRaw[mode] = false
  return nil
end

local function _PassesWeaponFilter(condTbl)
  if not condTbl then
    return true
  end

  local norm = _NormalizeWeaponFilter(condTbl.weaponFilter)
  if not norm then
    -- 未配置过滤器或标签未知 -> 不进行门控
    return true
  end

  -- 仅对战士/圣骑士/萨满有意义
  local _, cls = UnitClass("player")
  cls = cls and string.upper(cls) or ""
  if cls ~= "WARRIOR" and cls ~= "PALADIN" and cls ~= "SHAMAN" then
    return true
  end

  local hasTwoHand, hasShield, isDual = _GetEquippedWeaponState()
  if hasTwoHand == nil and hasShield == nil and isDual == nil then
    -- 装备栏 API 不可用；不要杀死图标
    return true
  end

  if norm == "2H" then
    return hasTwoHand
  elseif norm == "SH" then
    return hasShield
  elseif norm == "DW" then
    return isDual
  end

  return true
end

-- 全局包装器，以减少大型条件函数中的上值
function DoiteConditions_PassesWeaponFilter(condTbl)
  return _PassesWeaponFilter(condTbl)
end

-- 覆盖文本的时间剩余格式化器：
--  >= 3600s -> "#h"
--  >=   60s -> "#m"
--  <    10s -> "#.#s"（十分之一秒）
local function _FmtRem(remSec)
  if not remSec or remSec <= 0 then
    return nil
  end

  -- 单位选择必须在舍入之前进行，以避免 60m <-> 1h 闪烁。规则：任何高于 59:00 的保持在小时（防止 3599s 舍入到 60.0m）。
  local MIN = 60
  local HOUR = 3600
  local HOUR_CUTOVER = HOUR - MIN -- 59:00

  if remSec >= HOUR_CUTOVER then
    return (math.floor((remSec / HOUR) * 2 + 0.5) / 2) .. "h" -- 最接近的 0.5 小时
  elseif remSec >= MIN then
    return (math.floor((remSec / MIN) * 2 + 0.5) / 2) .. "m" -- 最接近的 0.5 分钟
  elseif remSec < 1.6 then
    -- 仅在剩余少于 1.6 秒时显示十分之一秒
    -- 通过截断稳定十分之一秒，而不是向上舍入（匹配旧行为）
    local t10 = math.floor(remSec * 10)
    local whole = math.floor(t10 / 10)
    local dec = t10 - (whole * 10)
    return whole .. "." .. dec
  else
    return math.ceil(remSec)
  end
end


-- === 形态/姿态评估（无回退）===
local function _ActiveFormMap()
  local map = DoiteConditions._activeFormMap
  if not map then
    map = {}
    DoiteConditions._activeFormMap = map
  else
    for k in pairs(map) do
      map[k] = nil
    end
  end

  for i = 1, 10 do
    local _, name, active = GetShapeshiftFormInfo(i)
    if not name then
      break
    end
    map[name] = (active and active == 1) and true or false
  end
  return map
end

local function _AnyActive(map, names)
  for _, n in ipairs(names) do
    if map[n] then
      return true
    end
  end
  return false
end

local function _DruidNoForm(map)
  -- 没有熊/猫/水栖/旅行/迅捷旅行/枭兽/树是活动的
  local any = _AnyActive(map, {
    "巨熊形态", "熊形态", "猎豹形态", "水栖形态",
    "旅行形态", "迅捷旅行形态", "枭兽形态", "生命之树形态"
  })
  return not any
end

local function _DruidStealth()
  return DoitePlayerAuras.HasBuff("潜伏")
end

local function _PriestShadowform()
  return DoitePlayerAuras.HasBuff("暗影形态")
end

-- 规范化编辑器标签，使逻辑对措辞差异具有鲁棒性
local function _NormalizeFormLabel(s)
  if not s or s == "" then
    return "All"
  end
  s = str_gsub(s, "^%s+", "")
  s = str_gsub(s, "%s+$", "")
  -- 统一“所有...”变体（编辑器可能说“所有光环”，“所有姿态”等）
  if s == "All" or s == "所有形态" or s == "所有姿态" or s == "所有光环" then
    return "All"
  end
  -- 统一德鲁伊“无形态”标签
  if s == "无形态" or s == "0. No forms" then
    return "无形态"
  end
  return s
end

-- 圣骑士：未选择光环（在姿态栏中）
local function _PaladinNoAura(map)
  return not _AnyActive(map, {
    "虔诚光环", "惩戒光环", "专注光环",
    "暗影抗性光环", "冰霜抗性光环", "火焰抗性光环", "圣洁光环"
  })
end

local function _PassesFormRequirement(formStr)
  formStr = _NormalizeFormLabel(formStr)
  if not formStr or formStr == "All" then
    return true
  end

  local _, cls = UnitClass("player")
  cls = cls and string.upper(cls) or ""
  local map = _ActiveFormMap()

  -- 战士
  if cls == "WARRIOR" then
    if formStr == "战斗姿态" then
      return map["战斗姿态"] == true
    end
    if formStr == "防御姿态" then
      return map["防御姿态"] == true
    end
    if formStr == "狂暴姿态" then
      return map["狂暴姿态"] == true
    end
    if formStr == "复合: 1+2" then
      return (map["战斗姿态"] == true) or (map["防御姿态"] == true)
    end
    if formStr == "复合: 1+3" then
      return (map["战斗姿态"] == true) or (map["狂暴姿态"] == true)
    end
    if formStr == "复合: 2+3" then
      return (map["防御姿态"] == true) or (map["狂暴姿态"] == true)
    end
    return true
  end

  -- 潜行者
  if cls == "ROGUE" then
    if formStr == "潜行" then
      return map["潜行"] == true
    end
    if formStr == "非潜行" then
      return map["潜行"] ~= true
    end
    return true
  end

  -- 牧师
  if cls == "PRIEST" then
    if formStr == "暗影形态" then
      return _PriestShadowform()
    end
    if formStr == "无形态" then
      return not _PriestShadowform()
    end
    return true
  end

  -- 德鲁伊（接受“无形态”）
  if cls == "DRUID" then
    if formStr == "无形态" then
      return _DruidNoForm(map)
    end
    if strfind(formStr, "熊") then
      return _AnyActive(map, { "巨熊形态", "熊形态" })
    end
    if formStr == "水栖形态" then
      return map["水栖形态"] == true
    end
    if formStr == "猎豹形态" then
      return map["猎豹形态"] == true
    end
    if formStr == "旅行形态" then
      return _AnyActive(map, { "旅行形态", "迅捷旅行形态" })
    end
    if formStr == "枭兽形态" then
      return map["枭兽形态"] == true
    end
    if formStr == "生命之树形态" then
      return map["生命之树形态"] == true
    end
    -- 潜行变体使用光环状态
    if formStr == "潜行" then
      return _DruidStealth()
    end
    if formStr == "非潜行" then
      return not _DruidStealth()
    end
    -- 多选
    if formStr == "复合: 0+5" then
      return _DruidNoForm(map) or (map["枭兽形态"] == true)
    end
    if formStr == "复合: 0+6" then
      return _DruidNoForm(map) or (map["生命之树形态"] == true)
    end
    if formStr == "复合: 1+3" then
      return _AnyActive(map, { "巨熊形态", "熊形态", "猎豹形态" })
    end
    if formStr == "复合: 3+7" then
      return (map["猎豹形态"] == true) or _DruidStealth()
    end
    if formStr == "复合: 3+8" then
      return (map["猎豹形态"] == true) and (not _DruidStealth())
    end
    if formStr == "复合: 5+6" then
      return _AnyActive(map, { "枭兽形态", "生命之树形态" })
    end
    if formStr == "复合: 0+5+6" then
      return _DruidNoForm(map) or _AnyActive(map, { "枭兽形态", "生命之树形态" })
    end
    if formStr == "复合: 1+3+8" then
      return _AnyActive(map, { "巨熊形态", "熊形态", "猎豹形态" }) and (not _DruidStealth())
    end
    return true
  end

  -- 圣骑士（通过 GetShapeshiftFormInfo 将光环视为形态）
  if cls == "PALADIN" then
    -- 编辑器选项：“所有光环”，“无光环”，“1. 虔诚” .. “7. 圣洁” + 多选
    if formStr == "无光环" then
      return _PaladinNoAura(map)
    end
    if formStr == "虔诚光环" then
      return map["虔诚光环"] == true
    end
    if formStr == "惩戒光环" then
      return map["惩戒光环"] == true
    end
    if formStr == "专注光环" then
      return map["专注光环"] == true
    end
    if formStr == "暗影抗性光环" then
      return map["暗影抗性光环"] == true
    end
    if formStr == "冰霜抗性光环" then
      return map["冰霜抗性光环"] == true
    end
    if formStr == "火焰抗性光环" then
      return map["火焰抗性光环"] == true
    end
    if formStr == "圣洁光环" then
      return map["圣洁光环"] == true
    end

    -- 多选（列出的光环的逻辑 OR）
    if formStr == "复合: 1+2" then
      return _AnyActive(map, { "虔诚光环", "惩戒光环" })
    end
    if formStr == "复合: 1+3" then
      return _AnyActive(map, { "虔诚光环", "专注光环" })
    end
    if formStr == "复合: 1+4+5+6" then
      return _AnyActive(map, { "虔诚光环", "暗影抗性光环", "冰霜抗性光环", "火焰抗性光环" })
    end
    if formStr == "复合: 1+7" then
      return _AnyActive(map, { "虔诚光环", "圣洁光环" })
    end
    if formStr == "复合: 1+2+3" then
      return _AnyActive(map, { "虔诚光环", "惩戒光环", "专注光环" })
    end
    if formStr == "复合: 1+2+3+4+5+6" then
      return _AnyActive(map, { "虔诚光环", "惩戒光环", "专注光环", "暗影抗性光环", "冰霜抗性光环", "火焰抗性光环" })
    end
    if formStr == "复合: 2+3" then
      return _AnyActive(map, { "惩戒光环", "专注光环" })
    end
    if formStr == "复合: 2+4+5+6" then
      return _AnyActive(map, { "惩戒光环", "暗影抗性光环", "冰霜抗性光环", "火焰抗性光环" })
    end
    if formStr == "复合: 2+7" then
      return _AnyActive(map, { "惩戒光环", "圣洁光环" })
    end
    if formStr == "复合: 2+3+4+5+6" then
      return _AnyActive(map, { "惩戒光环", "专注光环", "暗影抗性光环", "冰霜抗性光环", "火焰抗性光环" })
    end
    if formStr == "复合: 3+4+5+6" then
      return _AnyActive(map, { "专注光环", "暗影抗性光环", "冰霜抗性光环", "火焰抗性光环" })
    end
    if formStr == "复合: 3+7" then
      return _AnyActive(map, { "专注光环", "圣洁光环" })
    end
    if formStr == "复合: 4+5+6+7" then
      return _AnyActive(map, { "暗影抗性光环", "冰霜抗性光环", "火焰抗性光环", "圣洁光环" })
    end

    return true
  end

  return true
end

-- 全局包装器，以减少大型条件函数中的上值
function DoiteConditions_PassesFormRequirement(formStr)
  return _PassesFormRequirement(formStr)
end

local function _EnsureAbilityTexture(frame, data)
  if not frame or not frame.icon or not data then
    return
  end

  local spellName = data.displayName or data.name
  if not spellName then
    return
  end

  -- 与光环纹理路径一致：保存的技能纹理拥有最高优先级。
  -- 这也会替换图标池复用后残留的空纹理/问号占位纹理。
  if data.iconTexture and data.iconTexture ~= "" then
    if frame.icon:GetTexture() ~= data.iconTexture then
      frame.icon:SetTexture(data.iconTexture)
    end
    IconCache[spellName] = data.iconTexture
    if DoiteAurasDB and DoiteAurasDB.cache then
      DoiteAurasDB.cache[spellName] = data.iconTexture
    end
    return
  end

  local currentTexture = frame.icon:GetTexture()
  if currentTexture
      and not (
          type(currentTexture) == "string"
          and str_find(currentTexture, "INV_Misc_QuestionMark")
      ) then
    return
  end

  local idx = _GetSpellIndexByName(spellName)
  local bt = _G.DoiteConditions_SpellBookTypeCache[spellName]
  if idx then
    local tex = GetSpellTexture(idx, bt or BOOKTYPE_SPELL)
    if tex then
      frame.icon:SetTexture(tex)
      IconCache[spellName] = tex
      data.iconTexture = tex
      if DoiteAurasDB and DoiteAurasDB.cache then
        DoiteAurasDB.cache[spellName] = tex
      end
    end
  end
end


-- 确保增益/减益图标具有纹理（玩家/目标，然后通过法术书回退）
local function _EnsureAuraTexture(frame, data)
  -- 硬性保护：必须有真实的框架、真实的图标、真实的数据
  if not frame then
    return
  end
  local icon = frame.icon
  if not icon or not icon.GetTexture or not icon.SetTexture then
    return
  end
  if not data or type(data) ~= "table" then
    return
  end

  local c = data.conditions and data.conditions.aura
  local name = data.displayName or data.name
  if not c or not name or name == "" then
    return
  end

  -- 0) 如果此条目已经有存储的 iconTexture，立即使用。
  if data.iconTexture and data.iconTexture ~= "" then
    local cur = icon:GetTexture()
    if cur ~= data.iconTexture then
      icon:SetTexture(data.iconTexture)
    end

    IconCache[name] = data.iconTexture
    if DoiteAurasDB and DoiteAurasDB.cache then
      DoiteAurasDB.cache[name] = data.iconTexture
    end
    return
  end

  -- 0a) 如果配置已经有 spellid，通过 Nampower 解析纹理。
  if data.spellid then
    local sid = tonumber(data.spellid)
    if sid and sid > 0 then
      local _, tex = _NP_SpellNameAndTexture(sid)
      if tex and tex ~= "" then
        local cur = icon:GetTexture()
        if cur ~= tex then
          icon:SetTexture(tex)
        end

        IconCache[name] = tex
        if DoiteAurasDB and DoiteAurasDB.cache then
          DoiteAurasDB.cache[name] = tex
        end
        if DoiteAurasDB and DoiteAurasDB.spells and data.key and DoiteAurasDB.spells[data.key] then
          DoiteAurasDB.spells[data.key].iconTexture = tex
        end
        return
      end
    end
  end

  -- 0b) 如果 Nampower 法术书查找存在，即使没有人拥有该光环，也解析名称 -> spellId -> 纹理。
  if GetSpellIdForName then
    local sid = GetSpellIdForName(name)
    if sid and sid > 0 then
      local _, tex = _NP_SpellNameAndTexture(sid)
      if tex and tex ~= "" then
        local cur = icon:GetTexture()
        if cur ~= tex then
          icon:SetTexture(tex)
        end

        IconCache[name] = tex
        if DoiteAurasDB and DoiteAurasDB.cache then
          DoiteAurasDB.cache[name] = tex
        end
        if DoiteAurasDB and DoiteAurasDB.spells and data.key and DoiteAurasDB.spells[data.key] then
          local s = DoiteAurasDB.spells[data.key]
          s.iconTexture = tex
          if not s.spellid then
            s.spellid = tostring(sid)
          end
        end
        return
      end
    end
  end

  -- 1) 现有缓存/占位符逻辑（不变）
  local curTex = icon:GetTexture()
  local cached = IconCache and IconCache[name] or nil
  local isPlaceholder = (curTex == nil)
      or (type(curTex) == "string" and str_find(curTex, "INV_Misc_QuestionMark"))

  -- 如果已经有一个缓存的真实纹理用于此光环名称，直接使用。
  if cached and (not curTex or curTex ~= cached) then
    icon:SetTexture(cached)
    return
  end

  -- 如果图标已经有非占位符纹理且没有缓存，
  if (not isPlaceholder) and curTex then
    return
  end

  -- 2) 决定扫描哪些单位以获取实时光环纹理。使用与此文件其余部分相同的标志：targetSelf/targetHelp/targetHarm。
  local checkSelf, checkTarget = false, false

  local flagSelf = (c.targetSelf == true)
  local flagHelp = (c.targetHelp == true)
  local flagHarm = (c.targetHarm == true)

  -- 如果未选择任何标志，默认为自身（匹配 CheckAuraConditions / 覆盖逻辑）
  if (not flagSelf) and (not flagHelp) and (not flagHarm) then
    flagSelf = true
  end

  if flagSelf then
    checkSelf = true
  end
  if flagHelp or flagHarm then
    checkTarget = true
  end

  -- 向后兼容：如果遗留的 c.target 存在（“self”/“target”/“both”），让它覆盖。
  if c.target and type(c.target) == "string" then
    if c.target == "self" then
      checkSelf = true
      checkTarget = false
    elseif c.target == "target" then
      checkSelf = false
      checkTarget = true
    elseif c.target == "both" then
      checkSelf = true
      checkTarget = true
    end
  end

  local function tryUnit(unit)
    -- 1) 增益：通过 Nampower 确认名称，然后从 UnitBuff 获取纹理
    local i = 1
    while i <= 40 do
      local n = _GetAuraName(unit, i, false)
      if n == nil then
        break
      end
      if n ~= "" and n == name then
        local tex = UnitBuff(unit, i)
        if tex and (isPlaceholder or curTex ~= tex) then
          icon:SetTexture(tex)
          IconCache[name] = tex
          if DoiteAurasDB and DoiteAurasDB.cache then
            DoiteAurasDB.cache[name] = tex
          end
        end
        return true
      end
      i = i + 1
    end

    -- 2) 减益：确认名称，然后从 UnitDebuff 获取纹理
    i = 1
    while i <= 40 do
      local n = _GetAuraName(unit, i, true)
      if n == nil then
        break
      end
      if n ~= "" and n == name then
        local tex = UnitDebuff(unit, i)
        if tex and (isPlaceholder or curTex ~= tex) then
          icon:SetTexture(tex)
          IconCache[name] = tex
          if DoiteAurasDB and DoiteAurasDB.cache then
            DoiteAurasDB.cache[name] = tex
          end
        end
        return true
      end
      i = i + 1
    end

    return false
  end

  local got = false
  if checkSelf then
    got = tryUnit("player")
  end
  if (not got) and checkTarget and UnitExists("target") then
    got = tryUnit("target")
  end

  -- 回退到法术书纹理
  if not got then
    local i = 1
    while i <= 200 do
      local s = GetSpellName(i, BOOKTYPE_SPELL)
      if not s then
        break
      end
      if s == name then
        local tex = GetSpellTexture(i, BOOKTYPE_SPELL)
        if tex and (isPlaceholder or curTex ~= tex) then
          icon:SetTexture(tex)
          IconCache[name] = tex
          if DoiteAurasDB and DoiteAurasDB.cache then
            DoiteAurasDB.cache[name] = tex
          end
        end
        break
      end
      i = i + 1
    end
    -- 推动下一次常规更新，但不要递归地重新进入
    dirty_aura = true
    return
  end
end

-- 确保合成的物品槽位图标（已装备的饰品/武器）有真实纹理
local function _EnsureItemTexture(frame, data)
  if not frame or not frame.icon or not data then
    return
  end
  if not data.conditions or not data.conditions.item then
    return
  end

  local c = data.conditions.item
  local invSlotName = c.inventorySlot
  if not invSlotName or invSlotName == "" then
    return
  end

  local nameKey = data.displayName or data.name
  if not nameKey or nameKey == "" then
    return
  end

  local slot = nil

  if invSlotName == "TRINKET1" or invSlotName == "TRINKET2"
      or invSlotName == "MAINHAND" or invSlotName == "OFFHAND"
      or invSlotName == "RANGED" or invSlotName == "AMMO" then

    slot = _SlotIndexForName(invSlotName)

  elseif invSlotName == "TRINKET_FIRST" then
    -- 如果存在，优先使用此键的记住的胜者
    if data.key and _TrinketFirstMemory[data.key]
        and _TrinketFirstMemory[data.key].slot then
      slot = _TrinketFirstMemory[data.key].slot
    else
      -- 回退：当前有物品的饰品槽位（1，然后 2）
      local has1 = GetInventoryItemLink("player", INV_SLOT_TRINKET1) ~= nil
      local has2 = GetInventoryItemLink("player", INV_SLOT_TRINKET2) ~= nil
      if has1 then
        slot = INV_SLOT_TRINKET1
      elseif has2 then
        slot = INV_SLOT_TRINKET2
      end
    end

  elseif invSlotName == "TRINKET_BOTH" then
    -- 优先使用可用饰品的纹理。
    -- 如果两者都可用，优先选择槽位 1。
    -- 如果两者都不可用（没有“使用：”效果），外观上回退：槽位 1（如果存在）否则槽位 2。
    local has1, on1, rem1, dur1, isUse1 = _GetInventorySlotState(INV_SLOT_TRINKET1)
    local has2, on2, rem2, dur2, isUse2 = _GetInventorySlotState(INV_SLOT_TRINKET2)

    local use1 = has1 and isUse1
    local use2 = has2 and isUse2

    if use1 and use2 then
      slot = INV_SLOT_TRINKET1
    elseif use1 then
      slot = INV_SLOT_TRINKET1
    elseif use2 then
      slot = INV_SLOT_TRINKET2
    else
      local link1 = GetInventoryItemLink("player", INV_SLOT_TRINKET1)
      local link2 = GetInventoryItemLink("player", INV_SLOT_TRINKET2)
      if link1 then
        slot = INV_SLOT_TRINKET1
      elseif link2 then
        slot = INV_SLOT_TRINKET2
      end
    end
  end

  if not slot then
    return
  end

  local tex = GetInventoryItemTexture and GetInventoryItemTexture("player", slot)
  if not tex then
    return
  end

  local curTex = frame.icon:GetTexture()
  if curTex ~= tex then
    frame.icon:SetTexture(tex)
  end

  IconCache[nameKey] = tex
  DoiteAurasDB.cache[nameKey] = tex
  if DoiteAurasDB.spells and data.key and DoiteAurasDB.spells[data.key] then
    DoiteAurasDB.spells[data.key].iconTexture = tex
  end
end

-- === 时间逻辑辅助函数（用于心跳修剪）=================

-- 技能图标是否使用任何基于时间的特性？
local function _IconHasTimeLogic_Ability(data)
  if not data or not data.conditions or not data.conditions.ability then
    return false
  end
  local c = data.conditions.ability

  -- “即将冷却完毕”需要在图标隐藏期间持续检查冷却，否则只能等到
  -- SPELL_UPDATE_COOLDOWN 再次触发时才有机会开始滑入。
  if c.slider == true and (c.mode == "usable" or c.mode == "notcd") then
    return true
  end

  -- 现有原因
  if c.textTimeRemaining == true then
    return true
  end
  if c.remainingEnabled == true then
    return true
  end

  -- 触发窗口法术应在 mode == “usable” 时滴答
  if c.mode == "usable" then
    local spellName = _GetCanonicalSpellNameFromData(data)
    if spellName and _ProcWindowDuration(spellName) then
      return true
    end
  end

  return false
end


-- 物品图标是否使用任何基于时间的特性？
local function _IconHasTimeLogic_Item(data)
  if not data or not data.conditions or not data.conditions.item then
    return false
  end
  local c = data.conditions.item

  if c.mode == "oncd" or c.mode == "notcd" or c.mode == "both" then
    return true
  end

  if c.textTimeRemaining == true then
    return true
  end
  if c.remainingEnabled == true then
    return true
  end
  return false
end

-- 增益/减益图标是否使用任何基于时间的特性？
local function _IconHasTimeLogic_Aura(data)
  if not data or not data.conditions or not data.conditions.aura then
    return false
  end
  local c = data.conditions.aura
  if c.textTimeRemaining == true then
    return true
  end
  if c.remainingEnabled == true then
    return true
  end
  return false
end

-- 全局标志：是否有任何技能/物品图标需要 0.5 秒心跳？
local _hasAnyAbilityTimeLogic = false
-- 全局标志：是否有任何光环图标需要 0.5 秒心跳？
local _hasAnyAuraTimeLogic = false
-- 全局标志：我们是否有任何理由跟踪目标光环？
local _hasAnyTargetAuraUsage = true

-- ------------------------------------------------------------
-- 合并的光环扫描 + 计时器重建（减少 UNIT_AURA 突发）
-- 存储为 DoiteConditions 方法，以避免添加更多文件作用域局部变量。
-- ------------------------------------------------------------

function DoiteConditions:_ClearTargetAuraSnapshot()
  local s = auraSnapshot and auraSnapshot.target
  if s then
    local b, d = s.buffs, s.debuffs
    if b then
      for k in pairs(b) do
        b[k] = nil
      end
    end
    if d then
      for k in pairs(d) do
        d[k] = nil
      end
    end
  end
end

-- _RebuildPlayerAuraTimers 已移除 - 现在使用 DoitePlayerAuras 进行按需时间计算

function DoiteConditions:ProcessPendingAuraScans()
  -- 玩家光环扫描已移除 - 现在由 DoitePlayerAuras 事件驱动跟踪处理

  -- 目标：仅在使用了目标光环跟踪时才扫描；否则保持快照为空。
  if self._pendingAuraScanTarget then
    self._pendingAuraScanTarget = false

    if _hasAnyTargetAuraUsage and UnitExists and UnitExists("target") then
      _ScanTargetUnitAuras()
    else
      self:_ClearTargetAuraSnapshot()
    end
  end
end

-- 目标事实缓存
local _DA_TargetFacts = { exists = false, isSelf = false, isFriend = false, canAttack = false }

local function _DA_GetTargetFacts()
  local tf = _DA_TargetFacts
  local exists = UnitExists("target")
  tf.exists = exists and true or false

  if exists then
    tf.isSelf = UnitIsUnit("player", "target") and true or false
    tf.isFriend = UnitIsFriend("player", "target") and true or false
    tf.canAttack = UnitCanAttack("player", "target") and true or false
  else
    tf.isSelf, tf.isFriend, tf.canAttack = false, false, false
  end

  return tf
end

-- 缓存的键列表（通过 *_Rebuild*HeartbeatFlag / DoiteConditions_RequestEvaluate 重建）。
-- 目的：避免在 0.5 秒心跳时扫描每个图标表，并避免每次调用闭包分配。
-- 注意：这些是仅运行时缓存（不是保存的变量）。
local _timeKeysAbilityItem_live = {}
local _timeKeysAbilityItem_edit = {}
local _timeKeysAura_live = {}
local _timeKeysAura_edit = {}
local _DA_EMPTY_TABLE = {}

local function _WipeArray(t)
  local n = table.getn(t)
  while n > 0 do
    t[n] = nil
    n = n - 1
  end
end

local function _RebuildAbilityTimeHeartbeatFlag()
  _hasAnyAbilityTimeLogic = false

  -- 重建仅运行时键列表，以便 0.5 秒心跳传递不会扫描每个图标。
  _WipeArray(_timeKeysAbilityItem_live)
  _WipeArray(_timeKeysAbilityItem_edit)

  -- 1) 运行时图标
  if DoiteAurasDB and DoiteAurasDB.spells then
    local key, data
    for key, data in pairs(DoiteAurasDB.spells) do
      if type(data) == "table" and data.type then
        if data.type == "Ability" then
          if _IconHasTimeLogic_Ability(data) then
            _hasAnyAbilityTimeLogic = true
            table.insert(_timeKeysAbilityItem_live, key)
          end
        elseif data.type == "Item" then
          if _IconHasTimeLogic_Item(data) then
            _hasAnyAbilityTimeLogic = true
            table.insert(_timeKeysAbilityItem_live, key)
          end
        end
      end
    end
  end

  -- 2) 编辑器图标（可能与活动键重叠；评估循环将在需要时跳过活动键）
  if DoiteDB and DoiteDB.icons then
    local key, data
    for key, data in pairs(DoiteDB.icons) do
      if type(data) == "table" and data.type then
        if data.type == "Ability" then
          if _IconHasTimeLogic_Ability(data) then
            _hasAnyAbilityTimeLogic = true
            table.insert(_timeKeysAbilityItem_edit, key)
          end
        elseif data.type == "Item" then
          if _IconHasTimeLogic_Item(data) then
            _hasAnyAbilityTimeLogic = true
            table.insert(_timeKeysAbilityItem_edit, key)
          end
        end
      end
    end
  end
end

local function _RebuildAuraTimeHeartbeatFlag()
  _hasAnyAuraTimeLogic = false

  -- 重建仅运行时键列表，以便 0.5 秒文本/剩余更新不会扫描每个图标。
  _WipeArray(_timeKeysAura_live)
  _WipeArray(_timeKeysAura_edit)

  -- 1) 运行时图标
  if DoiteAurasDB and DoiteAurasDB.spells then
    local key, data
    for key, data in pairs(DoiteAurasDB.spells) do
      if type(data) == "table" and (data.type == "Buff" or data.type == "Debuff") then
        if _IconHasTimeLogic_Aura(data) then
          _hasAnyAuraTimeLogic = true
          table.insert(_timeKeysAura_live, key)
        end
      end
    end
  end

  -- 2) 编辑器图标（可能与活动键重叠；UpdateTimeText 已经为编辑器集跳过活动键）
  if DoiteDB and DoiteDB.icons then
    local key, data
    for key, data in pairs(DoiteDB.icons) do
      if type(data) == "table" and (data.type == "Buff" or data.type == "Debuff") then
        if _IconHasTimeLogic_Aura(data) then
          _hasAnyAuraTimeLogic = true
          table.insert(_timeKeysAura_edit, key)
        end
      end
    end
  end
end

local function _RebuildAuraUsageFlags()
  _hasAnyTargetAuraUsage = false

  -- 1) 活动图标
  if DoiteAurasDB and DoiteAurasDB.spells then
    local key, data
    for key, data in pairs(DoiteAurasDB.spells) do
      if type(data) == "table" then
        -- 任何显式的增益/减益图标，可能指向目标？
        if data.type == "Buff" or data.type == "Debuff" then
          local c = data.conditions and data.conditions.aura
          if c and (c.targetHarm or c.targetHelp) then
            _hasAnyTargetAuraUsage = true
            return
          end
        end

        -- 任何技能的 auraConditions 可以检查目标？
        local ca = data.conditions and data.conditions.ability
        if ca and ca.auraConditions and (ca.targetHarm or ca.targetHelp) then
          _hasAnyTargetAuraUsage = true
          return
        end

        -- 任何物品的 auraConditions 可以检查目标？
        local ci = data.conditions and data.conditions.item
        if ci and ci.auraConditions and (ci.targetHarm or ci.targetHelp) then
          _hasAnyTargetAuraUsage = true
          return
        end
      end
    end
  end

  -- 2) 仅编辑器图标
  if DoiteDB and DoiteDB.icons then
    local key, data
    for key, data in pairs(DoiteDB.icons) do
      if type(data) == "table" then
        if data.type == "Buff" or data.type == "Debuff" then
          local c = data.conditions and data.conditions.aura
          if c and (c.targetHarm or c.targetHelp) then
            _hasAnyTargetAuraUsage = true
            return
          end
        end

        local ca = data.conditions and data.conditions.ability
        if ca and ca.auraConditions and (ca.targetHarm or ca.targetHelp) then
          _hasAnyTargetAuraUsage = true
          return
        end

        local ci = data.conditions and data.conditions.item
        if ci and ci.auraConditions and (ci.targetHarm or ci.targetHelp) then
          _hasAnyTargetAuraUsage = true
          return
        end
      end
    end
  end
end

-- 全局标志：我们是否有任何图标使用 targetDistance / targetUnitType？
local _hasAnyTargetMods_Ability = false
local _hasAnyTargetMods_Aura = false
local _hasAnyCustomLogic = false

local function _IconHasTargetMods_AbilityOrItem(data)
  if not data or not data.conditions then
    return false
  end
  local c = data.conditions.ability or data.conditions.item
  if not c then
    return false
  end

  local td = _NormalizeTargetField(c.targetDistance)
  local tu = _NormalizeTargetField(c.targetUnitType)

  return (td ~= nil) or (tu ~= nil)
end

local function _IconHasTargetMods_Aura(data)
  if not data or not data.conditions or not data.conditions.aura then
    return false
  end
  local c = data.conditions.aura

  local td = _NormalizeTargetField(c.targetDistance)
  local tu = _NormalizeTargetField(c.targetUnitType)

  return (td ~= nil) or (tu ~= nil)
end

local function _RebuildTargetModsFlags()
  _hasAnyTargetMods_Ability = false
  _hasAnyTargetMods_Aura = false
  _hasAnyCustomLogic = false
  if DoiteConditions then
    DoiteConditions._hasAnyItemLogic = false
  end

  -- 1) 活动图标
  if DoiteAurasDB and DoiteAurasDB.spells then
    for key, data in pairs(DoiteAurasDB.spells) do
      if type(data) == "table" and data.type then
        local hasItemLogic = false
        if data.type == "Custom" then
          _hasAnyCustomLogic = true
        end

        if data.type == "Item" then
          hasItemLogic = true
        else
          local bucketNames = { "ability", "aura", "item" }
          local b = 1
          while b <= table.getn(bucketNames) do
            local bucket = data.conditions and data.conditions[bucketNames[b]]
            if bucket then
              local auraList = bucket.auraConditions
              local vfxList = bucket.vfxConditions
              local i, entry

              if auraList and table.getn(auraList) > 0 then
                for i = 1, table.getn(auraList) do
                  entry = auraList[i]
                  if entry and entry.buffType == "ITEM" then
                    hasItemLogic = true
                    break
                  end
                end
              end

              if (not hasItemLogic) and vfxList and table.getn(vfxList) > 0 then
                for i = 1, table.getn(vfxList) do
                  entry = vfxList[i]
                  if entry and entry.buffType == "ITEM" then
                    hasItemLogic = true
                    break
                  end
                end
              end
            end

            if hasItemLogic then
              break
            end
            b = b + 1
          end
        end

        if hasItemLogic and DoiteConditions then
          DoiteConditions._hasAnyItemLogic = true
        end

        if (data.type == "Ability" or data.type == "Item")
            and _IconHasTargetMods_AbilityOrItem(data) then
          _hasAnyTargetMods_Ability = true
        end
        if (data.type == "Buff" or data.type == "Debuff")
            and _IconHasTargetMods_Aura(data) then
          _hasAnyTargetMods_Aura = true
        end
        if _hasAnyTargetMods_Ability and _hasAnyTargetMods_Aura and DoiteConditions and DoiteConditions._hasAnyItemLogic then
          return
        end
      end
    end
  end

  -- 2) 仅编辑器图标
  if DoiteDB and DoiteDB.icons then
    for key, data in pairs(DoiteDB.icons) do
      if type(data) == "table" and data.type then
        local hasItemLogic = false
        if data.type == "Custom" then
          _hasAnyCustomLogic = true
        end

        if data.type == "Item" then
          hasItemLogic = true
        else
          local bucketNames = { "ability", "aura", "item" }
          local b = 1
          while b <= table.getn(bucketNames) do
            local bucket = data.conditions and data.conditions[bucketNames[b]]
            if bucket then
              local auraList = bucket.auraConditions
              local vfxList = bucket.vfxConditions
              local i, entry

              if auraList and table.getn(auraList) > 0 then
                for i = 1, table.getn(auraList) do
                  entry = auraList[i]
                  if entry and entry.buffType == "ITEM" then
                    hasItemLogic = true
                    break
                  end
                end
              end

              if (not hasItemLogic) and vfxList and table.getn(vfxList) > 0 then
                for i = 1, table.getn(vfxList) do
                  entry = vfxList[i]
                  if entry and entry.buffType == "ITEM" then
                    hasItemLogic = true
                    break
                  end
                end
              end
            end

            if hasItemLogic then
              break
            end
            b = b + 1
          end
        end

        if hasItemLogic and DoiteConditions then
          DoiteConditions._hasAnyItemLogic = true
        end

        if (data.type == "Ability" or data.type == "Item")
            and _IconHasTargetMods_AbilityOrItem(data) then
          _hasAnyTargetMods_Ability = true
        end
        if (data.type == "Buff" or data.type == "Debuff")
            and _IconHasTargetMods_Aura(data) then
          _hasAnyTargetMods_Aura = true
        end
        if _hasAnyTargetMods_Ability and _hasAnyTargetMods_Aura and DoiteConditions and DoiteConditions._hasAnyItemLogic then
          return
        end
      end
    end
  end
end

local _DA_SWIFTMEND_NEEDS = { "回春术", "愈合" }

local function _ClampFadeAlpha(v)
  local n = tonumber(v)
  if not n then
    return 0
  end
  if n < 0 then
    return 0
  end
  if n > 1 then
    return 1
  end
  return n
end

local function _EvaluateVfxConditions(data)
  if not data or not data.conditions then
    return false, false, false, 0
  end

  local glowOut, greyOut = false, false
  local fadeOut, fadeAlphaOut = false, 0

  local tIdx, typeKey
  for tIdx = 1, 3 do
    if tIdx == 1 then
      typeKey = "ability"
    elseif tIdx == 2 then
      typeKey = "aura"
    else
      typeKey = "item"
    end

    local bucket = data.conditions[typeKey]
    local list = bucket and bucket.vfxConditions
    if list and table.getn(list) > 0 then
      local i, entry
      for i = 1, table.getn(list) do
        entry = list[i]
        if _AuraConditions_CheckEntry(entry) then
          if entry.glow then glowOut = true end
          if entry.grey then greyOut = true end
          if entry.fade then
            fadeOut = true
            local entryFadeAlpha = _ClampFadeAlpha(entry.fadeAlpha)
            if entryFadeAlpha > fadeAlphaOut then
              fadeAlphaOut = entryFadeAlpha
            end
          end
        end
      end
    end
  end

  return glowOut, greyOut, fadeOut, fadeAlphaOut
end

-- ============================================================
-- 技能条件评估
-- ============================================================
local function CheckAbilityConditions(data)
  if not data or not data.conditions or not data.conditions.ability then
    return true, false, false, false, 0 -- 如果无条件，始终显示
  end
  local c = data.conditions.ability
  -- 合并的上下文表：保持局部计数较低，同时避免每次评估分配。
  local ctx = data._daCtx
  if not ctx then
    ctx = {}
    data._daCtx = ctx
  end
  ctx.allowHelp = (c.targetHelp == true)
  ctx.allowHarm = (c.targetHarm == true)
  ctx.allowSelf = (c.targetSelf == true)
  ctx.spellName = _GetCanonicalSpellNameFromData(data)
  ctx.spellIndex = _GetSpellIndexByName(ctx.spellName)
  ctx.spellBookType = _G.DoiteConditions_SpellBookTypeCache[ctx.spellName]
  ctx.tf = nil

  -- 编辑此键时，强制条件通过（始终显示）。
  if _IsKeyUnderEdit(data.key) then
    local glow = (c.glow and true) or false
    local grey = (c.greyscale and true) or false
    local fade = (c.fade and true) or false
    local fadeAlpha = fade and _ClampFadeAlpha(c.fadeAlpha) or 0
    return true, glow, grey, fade, fadeAlpha
  end

  -- “show” 现在代表所有非模式条件。
  local show = true
  data._daModeOk = true
  data._daSoundGate = nil

  -- === 滑块门控用于冷却滑块预览 ========================
  data._daSliderGuard = nil

  -- 重用每个图标的临时表；不能使用 _daSliderGuard，因为它稍后设置为布尔值。
  local _sg = data._daSliderGuardTmp
  if not _sg then
    _sg = {}
    data._daSliderGuardTmp = _sg
  end
  _sg.form, _sg.weapon, _sg.aura = nil, nil, nil

  if c.slider == true and (c.mode == "usable" or c.mode == "notcd") then
    local okSlider = true

    if c.form and c.form ~= "All" then
      _sg.form = DoiteConditions_PassesFormRequirement(c.form) and true or false
      if not _sg.form then
        okSlider = false
      end
    end

    if okSlider and c.weaponFilter and c.weaponFilter ~= "" then
      _sg.weapon = DoiteConditions_PassesWeaponFilter(c) and true or false
      if not _sg.weapon then
        okSlider = false
      end
    end

    if okSlider and c.auraConditions and table.getn(c.auraConditions) > 0 then
      _sg.aura = DoiteConditions_EvaluateAuraConditionsList(c.auraConditions) and true or false
      if not _sg.aura then
        okSlider = false
      end
    end

    data._daSliderGuard = okSlider and true or false
  end

  -- === 1. 冷却时间 / 可用性（仅模式） ===
  local spellName = ctx.spellName
  local spellIndex = ctx.spellIndex
  local bookType = ctx.spellBookType or BOOKTYPE_SPELL
  local onCdNow = false

  if not spellIndex then
    -- 不在法术书中：无图标，无声音。
    data._daModeOk = false
    data._daSoundGate = false
    return false
  end

  onCdNow = _IsSpellOnCooldown(spellIndex, bookType) and true or false

  local mode = c.mode or "notcd"
  local usablePass = nil

  if mode == "usable" or mode == "usableoncd" then
    usablePass = true

    local _, cls = UnitClass("player")
    cls = cls and string.upper(cls) or ""

    if cls == "WARRIOR" and (spellName == "压制" or spellName == "复仇") then
      if onCdNow then
        usablePass = false
      else
        local rage = UnitMana("player") or 0
        if rage < 5 then
          usablePass = false
        else
          if spellName == "压制" then
            usablePass = _Warrior_Overpower_OK() and true or false
          else
            usablePass = _Warrior_Revenge_OK() and true or false
          end
        end
      end
    else
      local usable, noMana = _SafeSpellUsable(spellName, spellIndex, bookType)
      if (usable ~= 1) or (noMana == 1) or onCdNow then
        usablePass = false
      else
        if cls == "DRUID" and spellName == "迅捷治愈" then
          local needs = _DA_SWIFTMEND_NEEDS
          local ok = false

          if ctx.allowHelp and not ctx.allowSelf then
            if UnitExists("target")
                and UnitIsFriend("player", "target")
                and (not UnitIsUnit("player", "target")) then
              ok = _TargetHasAnyBuffName(needs)
            else
              ok = false
            end

          elseif ctx.allowSelf and not (ctx.allowHelp or ctx.allowHarm) then
            ok = false
            for _, name in pairs(needs) do
              if DoitePlayerAuras.IsActive(name) then
                ok = true
                break
              end
            end
          else
            if UnitExists("target") then
              if UnitIsUnit("player", "target") then
                ok = false
                for _, name in pairs(needs) do
                  if DoitePlayerAuras.IsActive(name) then
                    ok = true
                    break
                  end
                end
              elseif UnitIsFriend("player", "target") then
                ok = _TargetHasAnyBuffName(needs)
              else
                ok = false
              end
            else
              ok = false
            end
          end

          if not ok then
            usablePass = false
          end
        end
      end
    end
  end

  if mode == "usable" then
    data._daModeOk = usablePass and true or false
  elseif mode == "notcd" then
    data._daModeOk = (not onCdNow) and true or false
  elseif mode == "oncd" then
    data._daModeOk = onCdNow and true or false
  elseif mode == "usableoncd" then
    data._daModeOk = ((usablePass == true) or onCdNow) and true or false
  elseif mode == "nocdoncd" then
    -- NotCD 或 OnCD 一旦技能存在于法术书中就始终为真。
    data._daModeOk = true
  end

  -- === 战斗状态（非模式） ===
  local inCombatFlag = (c.inCombat == true)
  local outCombatFlag = (c.outCombat == true)

  if not (inCombatFlag and outCombatFlag) then
    if inCombatFlag and not InCombat() then
      show = false
    end
    if outCombatFlag and InCombat() then
      show = false
    end
  end

  -- === 组队模式（非模式） ===
  local grouping = c.grouping
  if grouping ~= nil and grouping ~= "any" then
    local groupOk = true
    if grouping == "nogroup" then
      groupOk = not InGroup()
    elseif grouping == "party" then
      groupOk = InPartyOnly()
    elseif grouping == "raid" then
      groupOk = InRaid()
    elseif grouping == "partyraid" then
      groupOk = InGroup()
    else
      groupOk = false
    end
    if not groupOk then
      show = false
    end
  end

  -- 缓存目标事实，每次评估一次
  ctx.tf = _DA_GetTargetFacts()
  local tf = ctx.tf

  -- 目标门控（非模式）
  local ok = true
  if ctx.allowHelp or ctx.allowHarm or ctx.allowSelf then
    ok = false
    if ctx.allowSelf and tf.exists and tf.isSelf then
      ok = true
    end
    if (not ok) and ctx.allowHelp and tf.exists and tf.isFriend and (not tf.isSelf) then
      ok = true
    end
    if (not ok) and ctx.allowHarm and tf.exists and tf.canAttack and (not tf.isFriend) then
      ok = true
    end
  end
  if not ok then
    show = false
  end

  -- 目标状态 / 距离 / 类型（非模式）
  if show and (c.targetDistance or c.targetUnitType or c.targetAlive or c.targetDead) then
    local unitForTarget = nil
    if tf.exists then
      unitForTarget = "target"
    end
    if unitForTarget then
      if not DoiteConditions_PassesTargetStatus(c, unitForTarget) then
        show = false
      elseif not DoiteConditions_PassesTargetDistance(c, unitForTarget, spellName) then
        show = false
      elseif not DoiteConditions_PassesTargetUnitType(c, unitForTarget) then
        show = false
      end
    end
  end

  -- 形态/姿态（非模式）
  if show and c.form and c.form ~= "All" then
    if _sg.form ~= nil then
      if not _sg.form then
        show = false
      end
    else
      if not DoiteConditions_PassesFormRequirement(c.form) then
        show = false
      end
    end
  end

  -- 武器过滤器（非模式）
  if show and c.weaponFilter and c.weaponFilter ~= "" then
    if _sg.weapon ~= nil then
      if not _sg.weapon then
        show = false
      end
    else
      if not DoiteConditions_PassesWeaponFilter(c) then
        show = false
      end
    end
  end

  -- 生命值（非模式）
  if show and c.hpComp and c.hpVal and c.hpMode and c.hpMode ~= "" then
    local hpTarget = nil
    if c.hpMode == "my" then
      hpTarget = "player"
    elseif c.hpMode == "target" then
      if tf.exists then
        if (ctx.allowHelp or ctx.allowHarm or ctx.allowSelf) then
          local okHP = true
          if ctx.allowSelf then
            okHP = tf.isSelf
          elseif ctx.allowHelp then
            okHP = tf.isFriend and (not tf.isSelf)
          elseif ctx.allowHarm then
            okHP = tf.canAttack and (not tf.isFriend)
          end
          if okHP then
            hpTarget = "target"
          else
            hpTarget = nil
          end
        else
          hpTarget = "target"
        end
      end
    end

    if hpTarget then
      local pct = _HPPercent(hpTarget)
      local thr = tonumber(c.hpVal)
      if thr and not _ValuePasses(pct, c.hpComp, thr) then
        show = false
      end
    end
  end

  -- 连击点数（非模式）
  if show and c.cpEnabled == true and _PlayerUsesComboPoints() then
    local cp = _GetComboPointsSafe()
    local thr = tonumber(c.cpVal)
    if thr and c.cpComp and c.cpComp ~= "" then
      if not _ValuePasses(cp, c.cpComp, thr) then
        show = false
      end
    end
  end

  -- 能量（非模式）
  if show and c.powerEnabled
      and c.powerComp ~= nil and c.powerComp ~= ""
      and c.powerVal ~= nil and c.powerVal ~= "" then

    local valPct = GetPowerPercent()
    local targetPct = tonumber(c.powerVal) or 0
    local comp = c.powerComp

    local pass = true
    if comp == ">=" then
      pass = (valPct >= targetPct)
    elseif comp == "<=" then
      pass = (valPct <= targetPct)
    elseif comp == "==" then
      pass = (valPct == targetPct)
    end

    if not pass then
      show = false
    end
  end

  -- 剩余（非模式）
  if show and c.remainingEnabled
      and c.remainingComp and c.remainingComp ~= ""
      and c.remainingVal ~= nil and c.remainingVal ~= "" then

    local threshold = tonumber(c.remainingVal)
    if threshold then
      local rem = _AbilityRemainingSeconds(spellIndex, bookType)
      if rem and rem > 0 then
        if not _RemainingPasses(rem, c.remainingComp, threshold) then
          show = false
        end
      end
    end
  end

  -- 光环条件（非模式）
  if show and c.auraConditions and table.getn(c.auraConditions) > 0 then
    if _sg.aura ~= nil then
      if not _sg.aura then
        show = false
      end
    else
      if not DoiteConditions_EvaluateAuraConditionsList(c.auraConditions) then
        show = false
      end
    end
  end

  -- 声音门控 = 所有非模式条件
  data._daSoundGate = (show == true) and true or false

  -- 最终可见性包括模式
  if data._daModeOk == false then
    show = false
  end

  _DoiteHandleEdgeSound(
      data.key,
      "abilityOnCd",
      onCdNow,
      (data._daSoundGate and c.soundOnCDEnabled == true),
      c.soundOnCD)
  _DoiteHandleEdgeSound(
      data.key,
      "abilityOffCd",
      (not onCdNow),
      (data._daSoundGate and c.soundOffCDEnabled == true),
      c.soundOffCD)
  _DoiteHandleEdgeSound(
      data.key,
      "abilityOnProc",
      (_ProcWindowDuration(spellName) and _ProcWindowRemaining(spellName) and true or false),
      (data._daSoundGate and c.soundOnProcEnabled == true),
      c.soundOnProc)

  local vGlow, vGrey, vFade, vFadeAlpha = _EvaluateVfxConditions(data)
  local glow = (c.glow or vGlow) and true or false
  local grey = (c.greyscale or vGrey) and true or false
  local fade = (c.fade or vFade) and true or false
  local fadeAlpha = 0
  if c.fade then
    fadeAlpha = _ClampFadeAlpha(c.fadeAlpha)
  end
  if vFade and vFadeAlpha > fadeAlpha then
    fadeAlpha = vFadeAlpha
  end

  if not show then
    glow = false
    grey = false
    fade = false
    fadeAlpha = 0
  end

  return show, glow, grey, fade, fadeAlpha
end

-- ============================================================
-- 物品条件评估
-- ============================================================
local function CheckItemConditions(data)
  if not data or not data.conditions or not data.conditions.item then
    return true, false, false, false, 0
  end
  local c = data.conditions.item

  if _IsKeyUnderEdit(data.key) then
    local glow = (c.glow and true) or false
    local grey = (c.greyscale and true) or false
    local fade = (c.fade and true) or false
    local fadeAlpha = fade and _ClampFadeAlpha(c.fadeAlpha) or 0
    return true, glow, grey, fade, fadeAlpha
  end

  local show = true
  data._daModeOk = true
  data._daSoundGate = nil

  local allowHelp = (c.targetHelp == true)
  local allowHarm = (c.targetHarm == true)
  local allowSelf = (c.targetSelf == true)

  local tf = _DA_GetTargetFacts()

  local state = _EvaluateItemCoreState(data, c)
  local itemOnCdNow = (state and state.hasItem and state.rem and state.rem > 0) and true or false

  if not state.passesWhere then
    data._daModeOk = false
    data._daSoundGate = false
    local glow = c.glow and true or false
    local grey = c.greyscale and true or false
    local fade = c.fade and true or false
    local fadeAlpha = fade and _ClampFadeAlpha(c.fadeAlpha) or 0
    return false, glow, grey, fade, fadeAlpha
  end

  if state.modeMatches == false then
    data._daModeOk = false
  end

  if c.enchant ~= nil then
    local dn = data.displayName or data.name
    if dn == "---已装备的武器栏位---" then
      local hasEnchant = (state and state.teRem and state.teRem > 0) and true or false
      if c.enchant == true then
        if not hasEnchant then
          show = false
        end
      else
        if hasEnchant then
          show = false
        end
      end
    end
  end

  local inCombatFlag = (c.inCombat == true)
  local outCombatFlag = (c.outCombat == true)
  if not (inCombatFlag and outCombatFlag) then
    if inCombatFlag and not InCombat() then
      show = false
    end
    if outCombatFlag and InCombat() then
      show = false
    end
  end

  local grouping = c.grouping
  if grouping ~= nil and grouping ~= "any" then
    local groupOk = true
    if grouping == "nogroup" then
      groupOk = not InGroup()
    elseif grouping == "party" then
      groupOk = InPartyOnly()
    elseif grouping == "raid" then
      groupOk = InRaid()
    elseif grouping == "partyraid" then
      groupOk = InGroup()
    else
      groupOk = false
    end
    if not groupOk then
      show = false
    end
  end

  if show and (allowHelp or allowHarm or allowSelf) then
    local ok = false
    if allowSelf and tf.exists and tf.isSelf then
      ok = true
    end
    if (not ok) and allowHelp and tf.exists and tf.isFriend and (not tf.isSelf) then
      ok = true
    end
    if (not ok) and allowHarm and tf.exists and tf.canAttack and (not tf.isFriend) then
      ok = true
    end
    if not ok then
      show = false
    end
  end

  if show and (c.targetDistance or c.targetUnitType or c.targetAlive or c.targetDead) then
    local unitForTarget = nil
    if tf.exists then
      unitForTarget = "target"
    end
    if unitForTarget then
      if not DoiteConditions_PassesTargetStatus(c, unitForTarget) then
        show = false
      elseif not DoiteConditions_PassesTargetDistance(c, unitForTarget, nil) then
        show = false
      elseif not DoiteConditions_PassesTargetUnitType(c, unitForTarget) then
        show = false
      end
    end
  end

  if show and c.weaponFilter and c.weaponFilter ~= "" then
    if not DoiteConditions_PassesWeaponFilter(c) then
      show = false
    end
  end

  if show and c.form and c.form ~= "All" then
    if not DoiteConditions_PassesFormRequirement(c.form) then
      show = false
    end
  end

  if show and c.hpComp and c.hpVal and c.hpMode and c.hpMode ~= "" then
    local hpTarget = nil
    if c.hpMode == "my" then
      hpTarget = "player"
    elseif c.hpMode == "target" then
      if tf.exists then
        if allowSelf then
          if tf.isSelf then
            hpTarget = "target"
          end
        elseif allowHelp and allowHarm then
          if not tf.isSelf then
            hpTarget = "target"
          end
        elseif allowHelp then
          if tf.isFriend and (not tf.isSelf) then
            hpTarget = "target"
          end
        elseif allowHarm then
          if tf.canAttack and (not tf.isFriend) then
            hpTarget = "target"
          end
        else
          hpTarget = "target"
        end
      end
    end

    if hpTarget then
      local pct = _HPPercent(hpTarget)
      local thr = tonumber(c.hpVal)
      if thr and not _ValuePasses(pct, c.hpComp, thr) then
        show = false
      end
    end
  end

  if show and c.cpEnabled == true and _PlayerUsesComboPoints() then
    local cp = _GetComboPointsSafe()
    local thr = tonumber(c.cpVal)
    if thr and c.cpComp and c.cpComp ~= "" then
      if not _ValuePasses(cp, c.cpComp, thr) then
        show = false
      end
    end
  end

  if show and c.powerEnabled
      and c.powerComp ~= nil and c.powerComp ~= ""
      and c.powerVal ~= nil and c.powerVal ~= "" then
    local valPct = GetPowerPercent()
    local targetPct = tonumber(c.powerVal) or 0
    if not _ValuePasses(valPct, c.powerComp, targetPct) then
      show = false
    end
  end

  if show and c.stacksEnabled
      and c.stacksComp and c.stacksComp ~= ""
      and c.stacksVal ~= nil and c.stacksVal ~= "" then
    local threshold = tonumber(c.stacksVal)
    if threshold and state then
      local cnt = state.effectiveCount or 0
      if not _StacksPasses(cnt, c.stacksComp, threshold) then
        show = false
      end
    end
  end

  if show and c.remainingEnabled
      and c.remainingComp and c.remainingComp ~= ""
      and c.remainingVal ~= nil and c.remainingVal ~= "" then
    local threshold = tonumber(c.remainingVal)
    if threshold then
      if (c.mode == "notcd" or c.mode == "both")
          and (data.displayName == "---已装备的武器栏位---")
          and (c.inventorySlot == "MAINHAND" or c.inventorySlot == "OFFHAND") then
        if (not state) or (not state.teRem) or state.teRem <= 0 then
          show = false
        else
          if not _RemainingPasses(state.teRem, c.remainingComp, threshold) then
            show = false
          end
        end
      else
        if state.rem and state.rem > 0 then
          if not _RemainingPasses(state.rem, c.remainingComp, threshold) then
            show = false
          end
        end
      end
    end
  end

  if show and c.auraConditions and table.getn(c.auraConditions) > 0 then
    if not DoiteConditions_EvaluateAuraConditionsList(c.auraConditions) then
      show = false
    end
  end

  data._daSoundGate = (show == true) and true or false
  if data._daModeOk == false then
    show = false
  end

  _DoiteHandleEdgeSound(
      data.key,
      "itemOnCd",
      itemOnCdNow,
      (data._daSoundGate and c.soundOnCDEnabled == true),
      c.soundOnCD)
  _DoiteHandleEdgeSound(
      data.key,
      "itemOffCd",
      (not itemOnCdNow),
      (data._daSoundGate and c.soundOffCDEnabled == true),
      c.soundOffCD)

  local vGlow, vGrey, vFade, vFadeAlpha = _EvaluateVfxConditions(data)
  local glow = (c.glow or vGlow) and true or false
  local grey = (c.greyscale or vGrey) and true or false
  local fade = (c.fade or vFade) and true or false
  local fadeAlpha = 0
  if c.fade then
    fadeAlpha = _ClampFadeAlpha(c.fadeAlpha)
  end
  if vFade and vFadeAlpha > fadeAlpha then
    fadeAlpha = vFadeAlpha
  end

  if not show then
    glow = false
    grey = false
    fade = false
    fadeAlpha = 0
  end

  return show, glow, grey, fade, fadeAlpha
end

-- ============================================================
-- 光环条件评估
-- ============================================================
local function CheckAuraConditions(data)
  if not data or not data.conditions or not data.conditions.aura then
    return true, false, false, false, 0
  end
  local c = data.conditions.aura

  if _IsKeyUnderEdit(data.key) then
    local glow = (c.glow and true) or false
    local grey = (c.greyscale and true) or false
    local fade = (c.fade and true) or false
    local fadeAlpha = fade and _ClampFadeAlpha(c.fadeAlpha) or 0
    return true, glow, grey, fade, fadeAlpha
  end

  local name = data.displayName or data.name
  local useSpellIdOnly = (data.Addedviaspellid == true)
  local auraSpellId = tonumber(data.spellid) or 0

  if useSpellIdOnly and auraSpellId <= 0 then
    data._daSoundGate = false
    return false, false, false, false, 0
  end

  if (not useSpellIdOnly) and (not name) then
    data._daSoundGate = false
    return false, false, false, false, 0
  end

  local wantBuff = (data.type == "Buff")
  local wantDebuff = (data.type == "Debuff")
  if not wantBuff and not wantDebuff then
    wantBuff, wantDebuff = true, true
  end

  local allowHelp = (c.targetHelp == true)
  local allowHarm = (c.targetHarm == true)
  local allowSelf = (c.targetSelf == true)

  if (not allowHelp) and (not allowHarm) and (not allowSelf) then
    allowSelf = true
  end
  if allowSelf then
    allowHelp, allowHarm = false, false
  end

  local show = true
  data._daModeOk = true
  data._daSoundGate = nil

  local tf = _DA_GetTargetFacts()

  local ownerFilter = nil
  local wantMine = (c.onlyMine == true)
  local wantOthers = (c.onlyOthers == true)

  if wantMine and not wantOthers then
    ownerFilter = "mine"
  elseif wantOthers and not wantMine then
    ownerFilter = "others"
  else
    ownerFilter = nil
  end

  local requiresTarget = (allowHelp or allowHarm) and (not allowSelf)
  if requiresTarget then
    if not tf.exists then
      show = false
    else
      local isFriend = tf.isFriend
      local canAttack = tf.canAttack
      local matchesAny = false
      if allowHelp and isFriend then
        matchesAny = true
      end
      if (not matchesAny) and allowHarm and canAttack and (not isFriend) then
        matchesAny = true
      end
      if not matchesAny then
        show = false
      end
    end
  end


  local found = false

  if show and allowSelf then
    local hit = false
    if c.trackpet == true and DoitePetAuras and DoitePetAuras.HasAura then
      hit = DoitePetAuras.HasAura(name, auraSpellId, useSpellIdOnly, wantBuff, wantDebuff)
    elseif useSpellIdOnly and auraSpellId > 0 then
      if wantBuff then
        hit = DoitePlayerAuras.HasBuffSpellId(auraSpellId)
      end
      if (not hit) and wantDebuff then
        hit = DoitePlayerAuras.HasDebuffSpellId(auraSpellId)
      end
    else
      if wantBuff then
        hit = DoitePlayerAuras.HasBuff(name)
      end
      if (not hit) and wantDebuff then
        hit = DoitePlayerAuras.HasDebuff(name)
      end
    end
    if hit then
      found = true
    end
  end

  if show and (not found) and allowHelp then
    if c.trackpet == true and DoitePetAuras and DoitePetAuras.HasAura then
      if DoitePetAuras.HasAura(name, auraSpellId, useSpellIdOnly, wantBuff, wantDebuff) then
        found = true
      end
    else
      local hit = false
      if useSpellIdOnly and auraSpellId > 0 then
        if wantBuff and _TargetHasAuraBySpellId(auraSpellId, false) then
          hit = true
        elseif wantDebuff and _TargetHasAuraBySpellId(auraSpellId, true) then
          hit = true
        end
      else
        if wantBuff and _TargetHasAura(name, false) then
          hit = true
        elseif wantDebuff and _TargetHasAura(name, true) then
          hit = true
        end
      end
      if hit then
        found = true
      end
    end
  end

  if show and (not found) and allowHarm then
    if c.trackpet == true and DoitePetAuras and DoitePetAuras.HasAura then
      if DoitePetAuras.HasAura(name, auraSpellId, useSpellIdOnly, wantBuff, wantDebuff) then
        found = true
      end
    else
      local hit = false
      if useSpellIdOnly and auraSpellId > 0 then
        if wantBuff and _TargetHasAuraBySpellId(auraSpellId, false) then
          hit = true
        elseif wantDebuff and _TargetHasAuraBySpellId(auraSpellId, true) then
          hit = true
        end
      else
        if wantBuff and _TargetHasAura(name, false) then
          hit = true
        elseif wantDebuff and _TargetHasAura(name, true) then
          hit = true
        end
      end
      if hit then
        found = true
      end
    end
  end

  if show and found and ownerFilter and DoiteTrack then
    local ownerUnit = nil
    if allowSelf then
      ownerUnit = "player"
    elseif (allowHelp or allowHarm) and UnitExists("target") then
      ownerUnit = "target"
    end
    if ownerUnit then
      local _, _, _, isMine, isOther, mineKnown = _DoiteTrackAuraOwnership(useSpellIdOnly and auraSpellId or name, (c.trackpet == true and "pet") or ownerUnit, useSpellIdOnly)
      if mineKnown then
        if ownerFilter == "mine" and not isMine then
          found = false
        elseif ownerFilter == "others" and not isOther then
          found = false
        end
      end
    end
  end

  -- 模式可见性
  if c.mode == "missing" then
    data._daModeOk = (not found) and true or false
  elseif c.mode == "both" then
    data._daModeOk = true
  else
    data._daModeOk = found and true or false
  end

  local inCombatFlag = (c.inCombat == true)
  local outCombatFlag = (c.outCombat == true)
  if not (inCombatFlag and outCombatFlag) then
    if inCombatFlag and not InCombat() then
      show = false
    end
    if outCombatFlag and InCombat() then
      show = false
    end
  end

  local grouping = c.grouping
  if grouping ~= nil and grouping ~= "any" then
    local groupOk = true
    if grouping == "nogroup" then
      groupOk = not InGroup()
    elseif grouping == "party" then
      groupOk = InPartyOnly()
    elseif grouping == "raid" then
      groupOk = InRaid()
    elseif grouping == "partyraid" then
      groupOk = InGroup()
    else
      groupOk = false
    end
    if not groupOk then
      show = false
    end
  end

  if show and c.form and c.form ~= "All" then
    if not DoiteConditions_PassesFormRequirement(c.form) then
      show = false
    end
  end

  if show and c.weaponFilter and c.weaponFilter ~= "" then
    if not DoiteConditions_PassesWeaponFilter(c) then
      show = false
    end
  end

  if show and c.powerEnabled
      and c.powerComp and c.powerComp ~= ""
      and c.powerVal and c.powerVal ~= "" then
    local valPct = GetPowerPercent()
    local targetPct = tonumber(c.powerVal) or 0
    local comp = c.powerComp
    local pass = true
    if comp == ">=" then
      pass = (valPct >= targetPct)
    elseif comp == "<=" then
      pass = (valPct <= targetPct)
    elseif comp == "==" then
      pass = (valPct == targetPct)
    end
    if not pass then
      show = false
    end
  end

  if show and c.hpComp and c.hpVal and c.hpMode and c.hpMode ~= "" then
    local hpTarget = nil
    if c.hpMode == "my" then
      hpTarget = "player"
    elseif c.hpMode == "target" then
      if UnitExists("target") then
        if allowSelf then
          hpTarget = "target"
        elseif allowHelp and allowHarm then
          if not UnitIsUnit("player", "target") then
            hpTarget = "target"
          end
        elseif allowHelp then
          if UnitIsFriend("player", "target")
              and (not UnitIsUnit("player", "target")) then
            hpTarget = "target"
          end
        elseif allowHarm then
          if UnitCanAttack("player", "target")
              and (not UnitIsFriend("player", "target")) then
            hpTarget = "target"
          end
        else
          hpTarget = "target"
        end
      end
    end
    if hpTarget then
      local pct = _HPPercent(hpTarget)
      local thr = tonumber(c.hpVal)
      if thr and not _ValuePasses(pct, c.hpComp, thr) then
        show = false
      end
    end
  end

  if show and c.cpEnabled == true and _PlayerUsesComboPoints() then
    local cp = _GetComboPointsSafe()
    local thr = tonumber(c.cpVal)
    if thr and c.cpComp and c.cpComp ~= "" then
      if not _ValuePasses(cp, c.cpComp, thr) then
        show = false
      end
    end
  end

  -- 保持这些与现有门控（编辑器语义）一起
  if c.remainingEnabled
      and c.remainingComp and c.remainingComp ~= ""
      and c.remainingVal ~= nil and c.remainingVal ~= "" then
    if c.mode ~= "missing" and show then
      local targetSelf = true
      if not allowSelf and UnitExists("target") and (allowHelp or allowHarm) then
        local isFriend = UnitIsFriend("player", "target")
        local canAttack = UnitCanAttack("player", "target")
        if (allowHelp and allowHarm and not UnitIsUnit("player", "target")) or
            (allowHelp and isFriend and not UnitIsUnit("player", "target")) or
            (allowHarm and canAttack and not isFriend) then
          targetSelf = false
        end
      end

      local threshold = tonumber(c.remainingVal)
      if threshold then
        local comp = c.remainingComp
        local pass = true
        if targetSelf then
          local rem = nil
          if c.trackpet == true and DoitePetAuras and DoitePetAuras.GetAuraRemainingSeconds then
            rem = DoitePetAuras.GetAuraRemainingSeconds(name, auraSpellId, useSpellIdOnly)
          else
            rem = _PlayerAuraRemainingSeconds(name, auraSpellId, useSpellIdOnly)
          end
          if rem and rem > 0 then
            pass = _RemainingPasses(rem, comp, threshold)
          else
            pass = false
          end
        else
          if ownerFilter == "mine" and DoiteTrack then
            local rpass = _DoiteTrackRemainingPass(useSpellIdOnly and auraSpellId or name, (c.trackpet == true and "pet") or "target", comp, threshold, useSpellIdOnly)
            if rpass == nil then
              pass = false
            else
              pass = rpass
            end
          else
            pass = true
          end
        end
        if not pass then
          show = false
        end
      end
    end
  end

  if c.stacksEnabled
      and c.stacksComp and c.stacksComp ~= ""
      and c.stacksVal ~= nil and c.stacksVal ~= ""
      and c.mode ~= "missing"
      and show then
    local threshold = tonumber(c.stacksVal)
    if threshold then
      local unitToCheck = nil
      if allowSelf then
        unitToCheck = "player"
      elseif tf and tf.exists and (allowHelp or allowHarm) then
        local isFriend = tf.isFriend
        local canAttack = tf.canAttack
        if allowHelp and isFriend then
          unitToCheck = "target"
        elseif allowHarm and canAttack and (not isFriend) then
          unitToCheck = "target"
        end
      end
      if c.trackpet == true then
        unitToCheck = "pet"
      end
      if unitToCheck then
        local cnt = _GetAuraStacksOnUnit(unitToCheck, name, wantDebuff, auraSpellId, useSpellIdOnly)
        if cnt and (not _StacksPasses(cnt, c.stacksComp, threshold)) then
          show = false
        end
      end
    end
  end

  if show and (c.targetDistance or c.targetUnitType or c.targetAlive or c.targetDead) then
    local unitForTargetMods = nil
    if tf and tf.exists and (allowHelp or allowHarm) then
      unitForTargetMods = "target"
    end
    if unitForTargetMods then
      if not DoiteConditions_PassesTargetStatus(c, unitForTargetMods) then
        show = false
      elseif not DoiteConditions_PassesTargetDistance(c, unitForTargetMods, nil) then
        show = false
      elseif not DoiteConditions_PassesTargetUnitType(c, unitForTargetMods) then
        show = false
      end
    end
  end

  if show and c.auraConditions and table.getn(c.auraConditions) > 0 then
    if not DoiteConditions_EvaluateAuraConditionsList(c.auraConditions) then
      show = false
    end
  end

  data._daSoundGate = (show == true) and true or false
  if data._daModeOk == false then
    show = false
  end

  do
    local key = data.key
    local st = key and _SoundStateByKey[key]

    local isTargetAura = ((allowHelp or allowHarm) and (not allowSelf)) and true or false

    local curTargetName = nil
    if isTargetAura and tf and tf.exists then
      curTargetName = UnitName("target")
    end

    if isTargetAura then
      if not st then
        st = {}
        _SoundStateByKey[key] = st
      end

      local prevTargetName = st._daTargetName

    -- 如果目标身份更改，则在此评估中抑制声音边缘，并将边缘状态播种到当前真值，这样我们就不会得到延迟的错误边缘。
      if prevTargetName ~= curTargetName then
        st._daTargetName = curTargetName

        -- 将两个边缘状态播种到当前真值（这是 _DoiteHandleEdgeSound 会存储的）
        st["auraFound"] = found and true or false
        st["auraMissing"] = (not found) and true or false

        -- 在目标更改时不播放声音。
      else
        -- 相同目标：正常边缘声音行为
        _DoiteHandleEdgeSound(
            key,
            "auraFound",
            found,
            (data._daSoundGate and c.soundOnGainEnabled == true),
            c.soundOnGain)
        _DoiteHandleEdgeSound(
            key,
            "auraMissing",
            (not found),
            (data._daSoundGate and c.soundOnFadeEnabled == true),
            c.soundOnFade)
      end

    else
      -- 基于自身的光环图标：正常行为（玩家光环跟踪是稳定的）
      _DoiteHandleEdgeSound(
          key,
          "auraFound",
          found,
          (data._daSoundGate and c.soundOnGainEnabled == true),
          c.soundOnGain)
      _DoiteHandleEdgeSound(
          key,
          "auraMissing",
          (not found),
          (data._daSoundGate and c.soundOnFadeEnabled == true),
          c.soundOnFade)
    end
  end

  local vGlow, vGrey, vFade, vFadeAlpha = _EvaluateVfxConditions(data)
  local glow = (c.glow or vGlow) and true or false
  local grey = (c.greyscale or vGrey) and true or false
  local fade = (c.fade or vFade) and true or false
  local fadeAlpha = 0
  if c.fade then
    fadeAlpha = _ClampFadeAlpha(c.fadeAlpha)
  end
  if vFade and vFadeAlpha > fadeAlpha then
    fadeAlpha = vFadeAlpha
  end

  if not show then
    glow = false
    grey = false
    fade = false
    fadeAlpha = 0
  end

  return show, glow, grey, fade, fadeAlpha
end

---------------------------------------------------------------
-- 主更新
---------------------------------------------------------------
function DoiteConditions:EvaluateAll()
  local editingAny = _IsAnyKeyUnderEdit()
  local live = DoiteAurasDB and DoiteAurasDB.spells
  local edit = DoiteDB and DoiteDB.icons
  if not live and not edit then
    return
  end

  local key, data

  -- 1) 活动图标（运行时集）
  if live then
    for key, data in pairs(live) do
      -- 防御性：跳过并清理任何损坏的条目，以便它们
      -- 不会破坏评估循环。
      if type(data) ~= "table" then
        live[key] = nil
      elseif data.type then
        data.key = key

        if data.type == "Ability" or data.type == "Item" then
          local show, glow, grey, fade, fadeAlpha
          if data.type == "Ability" then
            show, glow, grey, fade, fadeAlpha = CheckAbilityConditions(data)
          else
            show, glow, grey, fade, fadeAlpha = CheckItemConditions(data)
          end
          DoiteConditions:ApplyVisuals(key, show, glow, grey, fade, fadeAlpha)

        elseif data.type == "Buff" or data.type == "Debuff" then
          local show, glow, grey, fade, fadeAlpha = CheckAuraConditions(data)
          DoiteConditions:ApplyVisuals(key, show, glow, grey, fade, fadeAlpha)
        end
      end
    end
  end

  -- 2) 任何额外的仅编辑器图标（不在 live 中的键）
  if edit then
    for key, data in pairs(edit) do
      if (not live) or (not live[key]) then
        if type(data) ~= "table" then
          edit[key] = nil
        elseif data.type then
          data.key = key

          if data.type == "Ability" or data.type == "Item" then
            local show, glow, grey, fade, fadeAlpha
            if data.type == "Ability" then
              show, glow, grey, fade, fadeAlpha = CheckAbilityConditions(data)
            else
              show, glow, grey, fade, fadeAlpha = CheckItemConditions(data)
            end
            DoiteConditions:ApplyVisuals(key, show, glow, grey, fade, fadeAlpha)

          elseif data.type == "Buff" or data.type == "Debuff" then
            local show, glow, grey, fade, fadeAlpha = CheckAuraConditions(data)
            DoiteConditions:ApplyVisuals(key, show, glow, grey, fade, fadeAlpha)
          end
        end
      end
    end
  end
end

-- 集中式覆盖更新器：剩余时间文本 + 层数。
-- 由 ApplyVisuals（逻辑传递）和轻量计时器滴答器使用。
-- 缓存小整数 -> 字符串以避免重复的 tostring() 搅动（层数/物品）
local _DA_NumStrCache = {}
local function _DA_NumToStr(n)
  if not n then
    return ""
  end
  local s = _DA_NumStrCache[n]
  if not s then
    s = tostring(n)
    _DA_NumStrCache[n] = s
  end
  return s
end


local function _SetTextureVertexAlpha(tex, alpha)
  if not tex or not tex.SetVertexColor then
    return
  end
  local r, g, b = 1, 1, 1
  if tex.GetVertexColor then
    local tr, tg, tb = tex:GetVertexColor()
    if tr then r = tr end
    if tg then g = tg end
    if tb then b = tb end
  end
  tex:SetVertexColor(r, g, b, alpha)
end

local function _ApplyFadeAlphaToBackdrop(frame, alpha)
  if not frame or not frame.backdrop then
    return
  end

  local bd = frame.backdrop

  -- pfUI 背景通常是父级为 frame.backdrop 的纹理区域。
  if bd.GetRegions then
    local regions = { bd:GetRegions() }
    local i, reg
    for i, reg in ipairs(regions) do
      if reg and reg.SetVertexColor then
        _SetTextureVertexAlpha(reg, alpha)
      end
    end
  end

  -- 防御性：一些背景公开直接纹理句柄。
  _SetTextureVertexAlpha(bd.bg, alpha)
  _SetTextureVertexAlpha(bd.border, alpha)
  _SetTextureVertexAlpha(bd.backdrop, alpha)
  _SetTextureVertexAlpha(bd.Top, alpha)
  _SetTextureVertexAlpha(bd.Bottom, alpha)
  _SetTextureVertexAlpha(bd.Left, alpha)
  _SetTextureVertexAlpha(bd.Right, alpha)
  _SetTextureVertexAlpha(bd.top, alpha)
  _SetTextureVertexAlpha(bd.bottom, alpha)
  _SetTextureVertexAlpha(bd.left, alpha)
  _SetTextureVertexAlpha(bd.right, alpha)
end

local function _Doite_UpdateOverlayForFrame(frame, key, dataTbl, slideActive)
  if not frame or not dataTbl then
    return
  end

  -- 确保一个专用的顶层，以便文本始终在任何发光框架之上渲染
  if not frame._daTextLayer then
    local tl = CreateFrame("Frame", nil, frame)
    frame._daTextLayer = tl
    tl:SetAllPoints(frame)
  end

  -- 保持此子框架远高于兄弟框架（包括典型的发光框架）
  do
    local baseLevel = frame:GetFrameLevel() or 0
    frame._daTextLayer:SetFrameStrata(frame:GetFrameStrata() or "MEDIUM")
    frame._daTextLayer:SetFrameLevel(baseLevel + 50)
  end

  -- 懒创建父级到文本层的字体字符串
  if not frame._daTextRem then
    local fs = frame._daTextLayer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetJustifyH("CENTER")
    fs:SetJustifyV("MIDDLE")
    frame._daTextRem = fs
  end
  if not frame._daTextStacks then
    local fs2 = frame._daTextLayer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs2:SetJustifyH("RIGHT")
    fs2:SetJustifyV("BOTTOM")
    frame._daTextStacks = fs2
    frame._daLastTextSize = 0
  end

  -- 仅在更改时调整大小
  local w = frame:GetWidth() or 36
  local last = frame._daLastTextSize or 0
  if math.abs(w - last) >= 1 then
    frame._daLastTextSize = w
    local remSize = math.max(10, math.floor(w * 0.42))
    local stackSize = math.max(8, math.floor(w * 0.28))
    frame._daRemSize = remSize
    frame._daStackSize = stackSize
    frame._daTextRem:SetFont(GameFontHighlight:GetFont(), remSize, "OUTLINE")
    frame._daTextStacks:SetFont(GameFontNormalSmall:GetFont(), stackSize, "OUTLINE")
  end

  -- 锚点（相对于图标框架；父级为 _daTextLayer）
  frame._daTextRem:ClearAllPoints()
  frame._daTextRem:SetPoint("CENTER", frame, "CENTER", 0, 0)

  frame._daTextStacks:ClearAllPoints()
  frame._daTextStacks:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)

  -- 默认隐藏（避免冗余的 SetText 分配）
  frame._daTextRem:Hide()
  frame._daTextStacks:Hide()

  -- 重置每次评估的排序剩余时间（由组“时间”模式使用）
  frame._daSortRem = nil

  -- ========== 剩余时间 ==========
  local wantRem = false
  local remText = nil
  local itemState = nil

  -- 决定是否显示技能的时间文本
  local function _ShowAbilityTime(ca, rem, dur, slide)
    if not rem or rem <= 0 then
      return false
    end
    dur = dur or 0

    -- 1) 在冷却中：仅显示真正的冷却（忽略纯公共冷却的短时闪烁）。
    if ca.mode == "oncd" or ca.mode == "usableoncd" or ca.mode == "nocdoncd" then
      return (dur > 1.6)
    end

    -- 2) 可用 / 不在冷却中 带有滑块：幻灯片可以覆盖 1.6 秒/GCD 过滤器
    if (ca.mode == "usable" or ca.mode == "notcd") and ca.slider == true then
      if slide then
        return true
      end
      local maxWindow = math.min(3.0, (dur or 0) * 0.6)
      return rem <= maxWindow and (dur > 1.6)
    end

    -- 默认（偏执）：延迟窗口 + 真正冷却
    local maxWindow = math.min(3.0, (dur or 0) * 0.6)
    return (dur > 1.6) and (rem <= maxWindow)
  end

    if dataTbl then
    ----------------------------------------------------------------
    -- 技能剩余时间文本
    ----------------------------------------------------------------
    if dataTbl.type == "Ability"
        and dataTbl.conditions
        and dataTbl.conditions.ability then

      local ca = dataTbl.conditions.ability

      local spellName = _GetCanonicalSpellNameFromData(dataTbl)
      local remCD, durCD = _AbilityCooldownByName(spellName)
      local remShown, durShown = nil, nil
      local remIsProc = false

      -- 1) 正常冷却剩余文本（仅当用户启用时）
      if ca.textTimeRemaining == true then
        if remCD and remCD > 0 and _ShowAbilityTime(ca, remCD, durCD, slideActive) then
          remShown = remCD
          durShown = durCD
        end
      end

      -- 2) 触发窗口剩余文本 (用于 usable/notcd/nocdoncd)
      if (not remShown) and spellName
          and (ca.mode == "usable" or ca.mode == "notcd" or ca.mode == "nocdoncd") then
        local procDur = _ProcWindowDuration(spellName)
        if procDur then
          local realCd = false
          if remCD and remCD > 0 and durCD and durCD > 1.6 then
            realCd = true
          end

          if not realCd then
            local remProc = _ProcWindowRemaining(spellName)
            if remProc and remProc > 0 then
              remShown = remProc
              durShown = procDur
              remIsProc = true
            end
          end
        end
      end

      if remShown and remShown > 0 then
        remText = _FmtRem(remShown)
        wantRem = (remText ~= nil)
        frame._daSortRem = remShown
        frame._daRemIsProc = remIsProc and true or false
      else
        frame._daRemIsProc = false
      end

      ----------------------------------------------------------------
      -- 物品剩余时间文本
      ----------------------------------------------------------------
    elseif (dataTbl.type == "Item")
        and dataTbl.conditions
        and dataTbl.conditions.item then

      local ci = dataTbl.conditions.item

      if ci.textTimeRemaining == true then
        local ovName, ovSpellId, ovUseSpellId = _ResolvePlayerAuraTextOverride(ci.remOverride, nil, 0, false)
        if ci.remOverride and (ovName or (ovUseSpellId and ovSpellId and ovSpellId > 0)) then
          local remOverride = _PlayerAuraRemainingSeconds(ovName, ovSpellId, ovUseSpellId)
          if remOverride and remOverride > 0 then
            remText = _FmtRem(remOverride)
            wantRem = (remText ~= nil)
            frame._daSortRem = remOverride
          end
        end

        if not wantRem then
        -- 稍后为堆叠计数器重用此
        itemState = _EvaluateItemCoreState(dataTbl, ci)

        -- 特殊情况：已装备的武器槽位 + mode=notcd/both => 显示临时附魔剩余时间
        if (ci.mode == "notcd" or ci.mode == "both")
            and (dataTbl.displayName == "---已装备的武器栏位---")
            and (ci.inventorySlot == "MAINHAND" or ci.inventorySlot == "OFFHAND") then

          local remTE = itemState and itemState.teRem or 0
          if remTE and remTE > 0 then
            remText = _FmtRem(remTE)
            wantRem = (remText ~= nil)
            frame._daSortRem = remTE
          end

        else
          local remItem = itemState and itemState.rem or nil
          local durItem = itemState and itemState.dur or 0

          -- 忽略超短的垃圾冷却时间；仅显示真正的冷却时间
          if remItem and remItem > 0 and durItem and durItem > 1.5 then
            remText = _FmtRem(remItem)
            wantRem = (remText ~= nil)
            frame._daSortRem = remItem
          end
        end
        end
      end

      ----------------------------------------------------------------
      -- 光环剩余时间文本
      ----------------------------------------------------------------
    elseif (dataTbl.type == "Buff" or dataTbl.type == "Debuff")
        and dataTbl.conditions
        and dataTbl.conditions.aura then

      local ca = dataTbl.conditions.aura

      if ca.textTimeRemaining == true then
        local auraName = dataTbl.displayName or dataTbl.name
        local useSpellIdOnly = (dataTbl.Addedviaspellid == true)
        local auraSpellId = tonumber(dataTbl.spellid) or 0
        auraName, auraSpellId, useSpellIdOnly = _ResolvePlayerAuraTextOverride(ca.remOverride, auraName, auraSpellId, useSpellIdOnly)

        local allowHelp = (ca.targetHelp == true)
        local allowHarm = (ca.targetHarm == true)
        local allowSelf = (ca.targetSelf == true)

        -- 如果未选择任何标志，默认为自身（匹配 CheckAuraConditions）
        if (not allowHelp) and (not allowHarm) and (not allowSelf) then
          allowSelf = true
        end

        local targetSelf = true
        if not allowSelf and (allowHelp or allowHarm) then
          local tf = _DA_GetTargetFacts()
          if tf and tf.exists then
            local isFriend = tf.isFriend
            local canAttack = tf.canAttack

            if (allowHelp and isFriend) or (allowHarm and canAttack and not isFriend) then
              targetSelf = false
            end
          end
        end

        local remAura = nil

        if ca.trackpet == true and DoitePetAuras and DoitePetAuras.GetAuraRemainingSeconds then
          remAura = DoitePetAuras.GetAuraRemainingSeconds(auraName, auraSpellId, useSpellIdOnly)
        elseif targetSelf then
          -- 玩家/自身剩余时间文本必须反映实际可见的光环时间（原始/工具提示扫描），永远不要 DoiteTrack。所有权过滤（onlyMine/onlyOthers）属于条件逻辑。
          remAura = _PlayerAuraRemainingSeconds(auraName, auraSpellId, useSpellIdOnly)
        else
          -- 目标剩余时间依赖于 DoiteTrack（原始目标光环不暴露持续时间）。
          remAura = _DoiteTrackAuraRemainingSeconds(useSpellIdOnly and auraSpellId or auraName, "target", useSpellIdOnly)
        end

        if remAura and remAura > 0 then
          remText = _FmtRem(remAura)
          wantRem = (remText ~= nil)
          frame._daSortRem = remAura
        end
      end

      ----------------------------------------------------------------
      -- 自定义剩余时间文本
      ----------------------------------------------------------------
    elseif dataTbl.type == "Custom" then
      local remCustom = tonumber(dataTbl._daCustomRemaining)
      if remCustom and remCustom > 0 then
        remText = _FmtRem(remCustom)
        wantRem = (remText ~= nil)
        frame._daSortRem = remCustom
      end
    end
  end

  if wantRem and remText then
    if remText ~= frame._daLastRemText then
      frame._daLastRemText = remText
      frame._daTextRem:SetText(remText)
    end
    local remIsProcNow = (frame._daRemIsProc == true)
    if remIsProcNow ~= frame._daLastRemProcState then
      frame._daLastRemProcState = remIsProcNow
      if remIsProcNow then
        frame._daTextRem:SetTextColor(0.2, 1, 0.2, 1)
      else
        frame._daTextRem:SetTextColor(1, 1, 1, 1)
      end
    end
    frame._daTextRem:Show()
  end

  -- ========== 堆叠计数器（仅光环） ==========
  if dataTbl
      and (dataTbl.type == "Buff" or dataTbl.type == "Debuff")
      and dataTbl.conditions
      and dataTbl.conditions.aura then

    local ca = dataTbl.conditions.aura
    if ca.textStackCounter == true then
      local auraName = dataTbl.displayName or dataTbl.name
      local useSpellIdOnly = (dataTbl.Addedviaspellid == true)
      local auraSpellId = tonumber(dataTbl.spellid) or 0
      local wantDebuff = (dataTbl.type == "Debuff")
      auraName, auraSpellId, useSpellIdOnly = _ResolvePlayerAuraTextOverride(ca.stackOverride, auraName, auraSpellId, useSpellIdOnly)

      -- 解析从哪个单位读取层数（与 CheckAuraConditions 相同的语义）
      local unitToCheck = nil
      local allowHelp = (ca.targetHelp == true)
      local allowHarm = (ca.targetHarm == true)
      local allowSelf = (ca.targetSelf == true)

      -- 如果未选择任何标志，默认为自身
      if (not allowHelp) and (not allowHarm) and (not allowSelf) then
        allowSelf = true
      end

      if allowSelf then
        unitToCheck = "player"
      elseif (allowHelp or allowHarm) then
        -- 缓存目标事实一次
        local tf = _DA_GetTargetFacts()
        if tf.exists then
          -- 帮助：友善目标包括自身
          if allowHelp and tf.isFriend then
            unitToCheck = "target"
            -- 伤害：敌对，非友善目标
          elseif allowHarm and tf.canAttack and (not tf.isFriend) then
            unitToCheck = "target"
          end
        end
      end

      if ca.trackpet == true then
        unitToCheck = "pet"
      end
      if unitToCheck then
        local cnt = _GetAuraStacksOnUnit(unitToCheck, auraName, wantDebuff, auraSpellId, useSpellIdOnly)
        if cnt and cnt >= 1 then
          local s = _DA_NumToStr(cnt)
          if s ~= frame._daLastStacksText then
            frame._daLastStacksText = s
            frame._daTextStacks:SetText(s)
            frame._daTextStacks:SetTextColor(1, 1, 1, 1)
          end
          -- 如果显示层数但不显示剩余，则使用更大的尺寸
          local sizeToUse = (not wantRem and frame._daRemSize) or frame._daStackSize
          if sizeToUse and sizeToUse ~= frame._daCurrentStackFontSize then
            frame._daCurrentStackFontSize = sizeToUse
            frame._daTextStacks:SetFont(GameFontNormalSmall:GetFont(), sizeToUse, "OUTLINE")
          end
          frame._daTextStacks:Show()
        end
      end
    end
  end
  -- ========== 堆叠计数器（自定义） ==========
  if dataTbl and dataTbl.type == "Custom" then
    local cnt = tonumber(dataTbl._daCustomStacks)
    if cnt then
      local rounded = math.floor(cnt + 0.5)
      local s = _DA_NumToStr(rounded)
      if s ~= frame._daLastStacksText then
        frame._daLastStacksText = s
        frame._daTextStacks:SetText(s)
        frame._daTextStacks:SetTextColor(1, 1, 1, 1)
      end
      local sizeToUse = (not wantRem and frame._daRemSize) or frame._daStackSize
      if sizeToUse and sizeToUse ~= frame._daCurrentStackFontSize then
        frame._daCurrentStackFontSize = sizeToUse
        frame._daTextStacks:SetFont(GameFontNormalSmall:GetFont(), sizeToUse, "OUTLINE")
      end
      frame._daTextStacks:Show()
    end
  end

  -- ========== 堆叠计数器（物品：总量） ==========
  if dataTbl
      and dataTbl.type == "Item"
      and dataTbl.conditions
      and dataTbl.conditions.item then

    local ci = dataTbl.conditions.item
    if ci.textStackCounter == true then
      -- 重用上面物品分支中已计算的任何状态
      local state = itemState
      if not state then
        state = _EvaluateItemCoreState(dataTbl, ci)
      end

      local cnt = state and state.effectiveCount or nil

      -- 特殊情况：已装备的武器槽位显示临时附魔充能（包括 0）
      if (dataTbl.displayName == "---已装备的武器栏位---")
          and (ci.inventorySlot == "MAINHAND" or ci.inventorySlot == "OFFHAND") then

        if not cnt then
          cnt = 0
        end
        if cnt < 0 then
          cnt = 0
        end

        local s = _DA_NumToStr(cnt)
        if s ~= frame._daLastStacksText then
          frame._daLastStacksText = s
          frame._daTextStacks:SetText(s)
          frame._daTextStacks:SetTextColor(1, 1, 1, 1)
        end
        -- 如果显示层数但不显示剩余，则使用更大的尺寸
        local sizeToUse = (not wantRem and frame._daRemSize) or frame._daStackSize
        if sizeToUse and sizeToUse ~= frame._daCurrentStackFontSize then
          frame._daCurrentStackFontSize = sizeToUse
          frame._daTextStacks:SetFont(GameFontNormalSmall:GetFont(), sizeToUse, "OUTLINE")
        end
        frame._daTextStacks:Show()

      elseif cnt and cnt >= 1 then
        local s = _DA_NumToStr(cnt)
        if s ~= frame._daLastStacksText then
          frame._daLastStacksText = s
          frame._daTextStacks:SetText(s)
          frame._daTextStacks:SetTextColor(1, 1, 1, 1)
        end
        -- 如果显示层数但不显示剩余，则使用更大的尺寸
        local sizeToUse = (not wantRem and frame._daRemSize) or frame._daStackSize
        if sizeToUse and sizeToUse ~= frame._daCurrentStackFontSize then
          frame._daCurrentStackFontSize = sizeToUse
          frame._daTextStacks:SetFont(GameFontNormalSmall:GetFont(), sizeToUse, "OUTLINE")
        end
        frame._daTextStacks:Show()
      end
    end
  end
end

-- 技能冷却滑块辅助函数（减少 ApplyVisuals 中的上值）
local function _HandleAbilitySlider(key, ca, dataTbl, sliderGuardOk)
  -- 仅适用于处于 usable/notcd 模式且启用了滑块的技能图标
  if not (key and ca and dataTbl) then
    if SlideMgr.active and SlideMgr.active[key] then
      SlideMgr:Stop(key)
    end
    return false, false, false, 0, 0, 1
  end

  if not (ca.slider and (ca.mode == "usable" or ca.mode == "notcd")) then
    -- 此图标禁用滑块：确保它已停止
    local had = SlideMgr.active and SlideMgr.active[key]
    if had then
      SlideMgr:Stop(key)
      return false, true, false, 0, 0, 1
    end
    SlideMgr:Stop(key)
    return false, false, false, 0, 0, 1
  end

  -- 滑块门控（形态/武器过滤器/光环条件）在 CheckAbilityConditions 中计算
  if sliderGuardOk == false then
    local had = SlideMgr.active and SlideMgr.active[key]
    if had then
      SlideMgr:Stop(key)
      return false, true, false, 0, 0, 1
    end
    SlideMgr:Stop(key)
    return false, false, false, 0, 0, 1
  end

  local spellName = _GetCanonicalSpellNameFromData(dataTbl)
  local rem, dur = _AbilityCooldownByName(spellName)
  local wasSliding = SlideMgr.active and SlideMgr.active[key]
  local maxWindow = math.min(3.0, (dur or 0) * 0.6)

  -- 上次看到 *此* 法术实际施放的时间（SPELL_GO_SELF -> _MarkSliderSeen）
  local lastSeen = spellName and Doite_SliderSeen and Doite_SliderSeen[spellName] or nil

  local hasSeenForThisCD = false

  -- 使用 SPELL_GO_SELF，仅对在观察到此法术的施放时开始的冷却显示滑块。
  if lastSeen and rem and dur and dur > 0 then
    local now = GetTime()
    -- 根据 (now, rem, dur) 重建近似的冷却开始时间
    local start = now + rem - dur
    -- 为事件计时/舍入留出小 epsilon
    if lastSeen + 0.35 >= start then
      hasSeenForThisCD = true
    end
  end

  -- 对没有共享冷却的内置监控，允许直接信任真实的长冷却。
  -- 这样在冷却期间 /reload 后，图标仍能在最后几秒正常滑入。
  if ca.sliderTrustCooldown == true and rem and dur and dur > 1.6 then
    hasSeenForThisCD = true
  end


  -- 仅当此冷却确实属于此法术时才启动，但允许短 CD（仅公共冷却）只要它们来自此法术。
  local shouldStart = hasSeenForThisCD and rem and dur and rem > 0 and rem <= maxWindow

  -- 一旦滑动，仅在幻灯片窗口内保持幻灯片活动。
  local contLimit = maxWindow

  -- 如果 maxWindow 非常小（短 CD / GCD 类似），允许高达 GCD 范围 - 不要在小跳动时杀死幻灯片。
  if contLimit < 1.60 then
    contLimit = 1.60
  end

  -- 小采样抖动余量。
  contLimit = contLimit + 0.15

  local shouldContinue = wasSliding and rem and rem > 0 and rem <= contLimit

  local startedSlide, stoppedSlide = false, false

  if shouldStart or shouldContinue then
    local baseX, baseY = 0, 0
    if _GetBaseXY then
      baseX, baseY = _GetBaseXY(key, dataTbl)
    end

    SlideMgr:StartOrUpdate(
        key,
        (ca.sliderDir or "center"),
        baseX,
        baseY,
        GetTime() + (rem or 0)
    )

    if not wasSliding then
      startedSlide = true
    end
  else
    if wasSliding then
      stoppedSlide = true
    end
    SlideMgr:Stop(key)
  end

  local active, dx, dy, alpha = SlideMgr:Get(key)
  if not active then
    return startedSlide, stoppedSlide, false, 0, 0, 1
  end
  return startedSlide, stoppedSlide, true, dx or 0, dy or 0, alpha or 1
end

---------------------------------------------------------------
-- 对图标应用视觉效果
---------------------------------------------------------------
function DoiteConditions:ApplyVisuals(key, show, glow, grey, fade, fadeAlpha)
  local frame = _GetIconFrame(key)
  if not frame then
    -- 如果图标重建，忘记此键的任何陈旧缓存引用并重试。
    _ForgetIconFrame(key)
    if DoiteAuras_RefreshIcons then
      DoiteAuras_RefreshIcons()
    end
    frame = _GetIconFrame(key)
    if not frame then
      return
    end
  end

  local dataTbl = (DoiteDB and DoiteDB.icons and DoiteDB.icons[key])
      or (DoiteAurasDB and DoiteAurasDB.spells and DoiteAurasDB.spells[key])

  -- 首先计算编辑状态（需要用于触发窗口保护 + 纹理预加载）
  local editing = _IsKeyUnderEdit(key)

  if (not editing) and dataTbl and dataTbl.type == "Ability"
      and dataTbl.conditions and dataTbl.conditions.ability then

    local ca = dataTbl.conditions.ability
    if ca and ca.mode == "usable" then
      local spellName = _GetCanonicalSpellNameFromData(dataTbl)
      local dur = _ProcWindowDuration(spellName)

      if dur then
        local prev = (_G.DoiteConditions_ProcLastShowByKey[key] == true)

        if show and (not prev) then
          local now = GetTime()
          local curUntil = _G.DoiteConditions_ProcUntil[spellName] or 0
          if curUntil < now then
            _ProcWindowSet(spellName, now + dur)
          end
        end

        _G.DoiteConditions_ProcLastShowByKey[key] = (show == true) and true or false
      end
    end
  end

  local preloadForSlider = dataTbl
      and dataTbl.type == "Ability"
      and dataTbl.conditions
      and dataTbl.conditions.ability
      and dataTbl.conditions.ability.slider == true

  -- 滑入图标在主条件转真前就会显示，因此必须在隐藏阶段预加载纹理。
  -- 否则首次滑入时只会看到空白边框，落位后才补上技能图标。
  if show or editing or preloadForSlider then
    if frame.icon and not frame.icon:GetTexture() and dataTbl and (dataTbl.displayName or dataTbl.name) then
      local nameKey = dataTbl.displayName or dataTbl.name

      -- 优先使用每个条目存储的纹理，然后缓存，然后回退。
      local tex = nil
      if dataTbl.iconTexture and dataTbl.iconTexture ~= "" then
        tex = dataTbl.iconTexture
      elseif IconCache and nameKey then
        tex = IconCache[nameKey]
      end

      if tex and tex ~= "" then
        frame.icon:SetTexture(tex)
      else
        frame.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
      end
    end

    if dataTbl then
      if dataTbl.type == "Ability" then
        _EnsureAbilityTexture(frame, dataTbl)
      elseif dataTbl.type == "Buff" or dataTbl.type == "Debuff" then
        _EnsureAuraTexture(frame, dataTbl)
      elseif dataTbl.type == "Item" then
        _EnsureItemTexture(frame, dataTbl)
      elseif dataTbl.type == "Custom" then
        local tex = dataTbl._daCustomTexture or dataTbl.iconTexture or "Interface\\Icons\\INV_Misc_QuestionMark"
        if frame.icon then
          frame.icon:SetTexture(tex)
        end
        -- 隐藏或恢复背景（pfUI 边框/背景）
        local wantHideBG = (dataTbl._daCustomHideBG == true)
        if wantHideBG then
          if frame.backdrop and frame.backdrop.Hide then
            frame.backdrop:Hide()
          end
          if frame.icon and frame.icon.SetTexCoord then
            frame.icon:SetTexCoord(0, 1, 0, 1)
          end
        else
          if frame.backdrop and frame.backdrop.Show then
            frame.backdrop:Show()
          end
        end
      end
    end
  end

  ------------------------------------------------------------
  -- 滑块（由 SlideMgr 驱动；忽略 GCD；超级平滑）
  ------------------------------------------------------------
  local slideActive, dx, dy, slideAlpha = false, 0, 0, 1

  if dataTbl and dataTbl.type == "Ability"
      and dataTbl.conditions
      and dataTbl.conditions.ability then

    local ca = dataTbl.conditions.ability
    local startedSlide, stoppedSlide

    -- 轻量级包装器：繁重逻辑位于 _HandleAbilitySlider
    startedSlide, stoppedSlide, slideActive, dx, dy, slideAlpha = _HandleAbilitySlider(key, ca, dataTbl, dataTbl._daSliderGuard)

    -- === 滑块开始/停止时立即组重排 ===
    if (startedSlide or stoppedSlide) and DoiteGroup and DoiteGroup.ApplyGroupLayout then
      if type(DoiteAuras) == "table"
          and type(DoiteAuras.GetAllCandidates) == "function" then
        _G["DoiteGroup_NeedReflow"] = true
      end
    end
  else
    -- 非技能图标从不滑动
    if SlideMgr.active and SlideMgr.active[key] then
      SlideMgr:Stop(key)
    end
  end

  -- 拉取当前幻灯片偏移/alpha（如果正在滑动）
  local allowSlideShow = false
  do


    -- ==== 具有旧行为默认值的有效标志 ====
    -- 1) 与旧代码一样，始终允许在幻灯片期间显示（预览）。
    allowSlideShow = false
    if slideActive and dataTbl and dataTbl.conditions and dataTbl.conditions.ability then
      local ca = dataTbl.conditions.ability
      if ca.slider == true and (dataTbl._daSliderGuard ~= false) then
        allowSlideShow = true
      end
    end

    -- 2) 除非明确启用滑块，否则在幻灯片期间默认抑制。
    local isSliderEnabled = false
    local sliderGlowFlag = false
    local sliderGreyFlag = false

    if dataTbl and dataTbl.type == "Ability" and dataTbl.conditions and dataTbl.conditions.ability then
      local ca = dataTbl.conditions.ability
      if ca.slider == true then
        isSliderEnabled = true
        sliderGlowFlag = (ca.sliderGlow == true)
        sliderGreyFlag = (ca.sliderGrey == true)
      end
    end

    local useGlow, useGrey
    if slideActive then
      if isSliderEnabled then
        useGlow = sliderGlowFlag
        useGrey = sliderGreyFlag
      else
        useGlow = false
        useGrey = false
      end
    else
      useGlow = (glow == true)
      useGrey = (grey == true)
    end

    -- 用于其他系统/更改检测器的标志
    frame._daSliding = slideActive and true or false
    frame._daShouldShow = ((show == true) or editing) and true or false
    frame._daUseGlow = useGlow and true or false
    frame._daUseGlow = useGlow and true or false
    frame._daUseGreyscale = useGrey and true or false
    frame._daUseFade = (fade == true) and true or false
    frame._daFadeAlpha = _ClampFadeAlpha(fadeAlpha)
    -- 与 DoiteAuras.lua 期望同步
    frame._daGreyscale = frame._daUseGreyscale
  end

  -- 确定基线锚点
  local baseX, baseY = 0, 0
  if _GetBaseXY and dataTbl then
    baseX, baseY = _GetBaseXY(key, dataTbl)
  end

  -- 如果此图标属于一个组，则优先使用最新计算的位置（对于组长和追随者）
  local isGrouped = (dataTbl and dataTbl.group and dataTbl.group ~= "" and dataTbl.group ~= "no")
  local hasGroupPos = false
  if isGrouped and _G["DoiteGroup_Computed"] and _G["DoiteGroup_Computed"][dataTbl.group] then
    local arr = _G["DoiteGroup_Computed"][dataTbl.group]
    local n = table.getn(arr)
    for idx = 1, n do
      local e = arr[idx]
      if e and e.key == key and e._computedPos then
        baseX = e._computedPos.x
        baseY = e._computedPos.y
        hasGroupPos = true
        break
      end
    end
  end

  if slideActive then
    SlideMgr:UpdateBase(key, baseX, baseY)
  end

  -- 即使在主要条件会隐藏的情况下，也在幻灯片预览期间显示
  local showForSlide = (show or allowSlideShow)

  -- 如果这是当前正在编辑的键，则无论条件/组限制如何，都强制其可见
  if editing then
    showForSlide = true
  end

  -- 组容量可能阻止此图标，除非正在编辑此键
  if frame._daBlockedByGroup and (not editing) then
    showForSlide = false
  end

  -- 应用位置和 alpha（无抖动：每次绘制设置确切坐标）
  do
    local isGrouped = (dataTbl and dataTbl.group and dataTbl.group ~= "" and dataTbl.group ~= "no")
    local isLeader = (dataTbl and dataTbl.isLeader == true)

    -- 应用位置和 alpha（无抖动：每次绘制设置确切坐标）
    do
      -- 如果用户正在拖动此框架，则不强制位置
      if not frame._daDragging then
          -- 滑动时：对所有人应用瞬态移动（组长 + 追随者）
          if slideActive then
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "CENTER", baseX + dx, baseY + dy)
            frame:SetAlpha(slideAlpha)
          else
            -- 不滑动时：不要在此处强制追随者的点。
            if not (isGrouped and not isLeader) then
              frame:ClearAllPoints()
              frame:SetPoint("CENTER", UIParent, "CENTER", baseX, baseY)
              frame:SetAlpha((dataTbl and dataTbl.alpha) or 1)
            else
              -- 追随者：
              -- 仅当为此键计算了组位置时才重新锚定。
              if hasGroupPos then
                frame:ClearAllPoints()
                frame:SetPoint("CENTER", UIParent, "CENTER", baseX, baseY)
              end
              -- 如果 !hasGroupPos：此滴答不触摸点；避免回弹到原始 x/y。
              frame:SetAlpha((dataTbl and dataTbl.alpha) or 1)
            end
          end
      end
    end
    -- === 覆盖文本：冷却剩余 + 层数（强制在发光之上） ===
    _Doite_UpdateOverlayForFrame(frame, key, dataTbl, slideActive)
  end

  -- === 应用效果与更改检测（不要每帧重新启动动画） ===
  do
    -- 决定最终显示标志（编辑和组门控保留）
    local showForSlide = (show or allowSlideShow)
    if editing then
      showForSlide = true
    end

    -- 编辑时永远不要因为组容量而抑制编辑的图标
    if frame._daBlockedByGroup and (not editing) then
      showForSlide = false
    end

    -- 仅在更改时应用可见性
    if frame._daLastShown ~= showForSlide then
      frame._daLastShown = showForSlide
      if showForSlide then
        frame:Show()

        if not slideActive then
          frame:SetAlpha(1)
        end
      else
        frame:Hide()
      end
    end

    -- 淡出（通过 SetVertexColor alpha 路径用于图标 + 边框/背景）
    do
      local wantFade = (frame._daUseFade == true) and showForSlide
      local wantedAlpha = 1
      if wantFade then
        wantedAlpha = 1 - (frame._daFadeAlpha or 0)
        if wantedAlpha < 0 then wantedAlpha = 0 end
        if wantedAlpha > 1 then wantedAlpha = 1 end
      end
      if frame._daLastFadeAlpha ~= wantedAlpha then
        frame._daLastFadeAlpha = wantedAlpha
        _SetTextureVertexAlpha(frame.icon, wantedAlpha)
        _ApplyFadeAlphaToBackdrop(frame, wantedAlpha)
      end
    end

    -- 灰度 — 仅在更改时翻转
    if frame.icon then
      local wantGrey = (frame._daGreyscale == true) and showForSlide
      if frame._daLastGrey ~= wantGrey then
        frame._daLastGrey = wantGrey
        if wantGrey then
          frame.icon:SetDesaturated(1)
        else
          frame.icon:SetDesaturated(nil)
        end
        
        -- 修复：当灰色状态更改时更新物品的可点击性
        -- 已移除：DoiteAuras.lua 现在集中处理所有可点击性/鼠标启用逻辑。
        -- 我们不再仅仅因为物品为灰色/冷却而禁用鼠标。
      end
    end

    -- 发光 — 仅在更改时开始/停止（保留动画）
    if DG then
      local wantGlow = (frame._daUseGlow == true) and showForSlide
      if frame._daLastGlow ~= wantGlow then
        frame._daLastGlow = wantGlow
        if wantGlow then
          DG.Start(frame)
        else
          DG.Stop(frame)
        end
      end
    end
  end


  ----------------------------------------------------------------
  -- 当此图标的逻辑可见性翻转时重排组。
  -- 这涵盖了仅光环组（不涉及技能）。
  ----------------------------------------------------------------
  if DoiteGroup and DoiteGroup.ApplyGroupLayout then
    if frame._lastShowState ~= show then
      frame._lastShowState = show
      if type(DoiteAuras) == "table" and type(DoiteAuras.GetAllCandidates) == "function" then
        _G["DoiteGroup_NeedReflow"] = true
      end
    end
  end
end

function DoiteConditions_RequestEvaluate()
  -- 如果有人仍然需要时间心跳，重新扫描图标
  if _RebuildAbilityTimeHeartbeatFlag then
    _RebuildAbilityTimeHeartbeatFlag()
  end
  if _RebuildAuraTimeHeartbeatFlag then
    _RebuildAuraTimeHeartbeatFlag()
  end
  if _RebuildAuraUsageFlags then
    _RebuildAuraUsageFlags()
  end
  if _RebuildTargetModsFlags then
    _RebuildTargetModsFlags()
  end
  dirty_ability, dirty_aura, dirty_target, dirty_power = true, true, true, true
end

function DoiteConditions:EvaluateAbilities(doLogic, doTime)
  local editingAny = _IsAnyKeyUnderEdit()
  -- 默认行为（无参数）：完整逻辑 + 时间，与之前一样。
  if doLogic == nil and doTime == nil then
    doLogic, doTime = true, true
  else
    if doLogic == nil then
      doLogic = true
    end
    if doTime == nil then
      doTime = false
    end
  end

  local live = DoiteAurasDB and DoiteAurasDB.spells
  local edit = DoiteDB and DoiteDB.icons
  if not live and not edit then
    return
  end

  local key, data

  -- 快速路径：仅时间心跳（避免每 0.5 秒扫描每个图标）
  if doLogic == false and doTime == true then
    -- 1) 实际有时间逻辑的活动键
    if live then
      local keys = _timeKeysAbilityItem_live
      if keys then
        local i, n = 1, table.getn(keys)
        while i <= n do
          key = keys[i]
          data = key and live[key]
          if data and (data.type == "Ability" or data.type == "Item") then
            data.key = key
            local show, glow, grey, fade, fadeAlpha
            if data.type == "Ability" then
              show, glow, grey, fade, fadeAlpha = CheckAbilityConditions(data)
            else
              show, glow, grey, fade, fadeAlpha = CheckItemConditions(data)
            end
            DoiteConditions:ApplyVisuals(key, show, glow, grey, fade, fadeAlpha)
          end
          i = i + 1
        end
      end
    end

    -- 2) 编辑器键（跳过任何存在于 live 中的键，与原始相同）
    if edit then
      local keys = _timeKeysAbilityItem_edit
      if keys then
        local i, n = 1, table.getn(keys)
        while i <= n do
          key = keys[i]
          if key and ((not live) or (not live[key])) then
            data = edit[key]
            if data and (data.type == "Ability" or data.type == "Item") then
              data.key = key
              local show, glow, grey, fade, fadeAlpha
              if data.type == "Ability" then
                show, glow, grey, fade, fadeAlpha = CheckAbilityConditions(data)
              else
                show, glow, grey, fade, fadeAlpha = CheckItemConditions(data)
              end
              DoiteConditions:ApplyVisuals(key, show, glow, grey, fade, fadeAlpha)
            end
          end
          i = i + 1
        end
      end
    end

    return
  end

  -- 1) 活动图标（运行时集）
  if live then
    for key, data in pairs(live) do
      if data and (data.type == "Ability" or data.type == "Item") then
        -- 决定此图标在此传递中是否应被触及
        local wantsTime = false
        if doTime then
          if data.type == "Ability" then
            wantsTime = _IconHasTimeLogic_Ability(data)
          else
            -- "Item"
            wantsTime = _IconHasTimeLogic_Item(data)
          end
        end

        local wantsLogic = doLogic

        if wantsLogic or wantsTime then
          data.key = key
          local show, glow, grey, fade, fadeAlpha
          if data.type == "Ability" then
            show, glow, grey, fade, fadeAlpha = CheckAbilityConditions(data)
          else
            show, glow, grey, fade, fadeAlpha = CheckItemConditions(data)
          end
          DoiteConditions:ApplyVisuals(key, show, glow, grey, fade, fadeAlpha)
        end
      end
    end
  end

  -- 2) 任何额外的仅编辑器图标（不在 live 中的键）
  if edit then
    for key, data in pairs(edit) do
      if (not live) or (not live[key]) then
        if data and (data.type == "Ability" or data.type == "Item") then
          local wantsTime = false
          if doTime then
            if data.type == "Ability" then
              wantsTime = _IconHasTimeLogic_Ability(data)
            else
              wantsTime = _IconHasTimeLogic_Item(data)
            end
          end

          local wantsLogic = doLogic

          if wantsLogic or wantsTime then
            data.key = key
            local show, glow, grey, fade, fadeAlpha
            if data.type == "Ability" then
              show, glow, grey, fade, fadeAlpha = CheckAbilityConditions(data)
            else
              show, glow, grey, fade, fadeAlpha = CheckItemConditions(data)
            end
            DoiteConditions:ApplyVisuals(key, show, glow, grey, fade, fadeAlpha)
          end
        end
      end
    end
  end
end

local function _DoiteCustomCompileForData(key, data)
  if type(data) ~= "table" then
    return nil, "无效的自定义数据条目。"
  end

  local src = data.customFunctionSource
  if type(src) ~= "string" or src == "" then
    src = _G["DOITE_DEFAULT_CUSTOM_FUNCTION_SOURCE"]
    data.customFunctionSource = src
  end

  if data._daCustomCompiled and data._daCustomCompiledSrc == src then
    return data._daCustomCompiled, nil
  end

  local wrapped = "return function(data)\n" .. src .. "\nend"
  local chunk, err = loadstring(wrapped)
  if not chunk then
    return nil, err
  end

  local ok, fn = pcall(chunk)
  if not ok then
    return nil, fn
  end
  if type(fn) ~= "function" then
    return nil, "编译的自定义源不可调用。"
  end

  data._daCustomCompiled = fn
  data._daCustomCompiledSrc = src
  data._daCustomCompileError = nil
  return fn, nil
end

local function _DoiteCustomPrintOnce(data, key, prefix, msg)
  if type(data) ~= "table" then
    return
  end
  local sig = tostring(prefix or "Custom") .. ": " .. tostring(msg or "?")
  if data._daCustomLastError == sig then
    return
  end
  data._daCustomLastError = sig

  local cf = DEFAULT_CHAT_FRAME or ChatFrame1
  if cf and cf.AddMessage then
    cf:AddMessage("|cffff4040DoiteAuras 自定义 [" .. tostring(key or "?") .. "] " .. tostring(prefix or "错误") .. ":|r " .. tostring(msg))
  end
end

local function _DoiteCustomClearError(data)
  if type(data) == "table" then
    data._daCustomLastError = nil
  end
end

local function _DoiteCustomEvaluateOne(key, data)
  if type(data) ~= "table" then
    return false
  end

  local fn, compileErr = _DoiteCustomCompileForData(key, data)
  if not fn then
    _DoiteCustomPrintOnce(data, key, "编译错误", compileErr)
    data._daCustomShow = false
    data._daCustomTexture = nil
    data._daCustomHideBG = false
    data._daCustomRemaining = nil
    data._daCustomStacks = nil
    DoiteConditions:ApplyVisuals(key, false, false, false, false, 0)
    return true
  end

  local state = data._daCustomRuntime
  if type(state) ~= "table" then
    state = {}
    data._daCustomRuntime = state
  end

  local ok, show, texture, hideBackground, remaining, stacks = pcall(fn, state)
  if not ok then
    _DoiteCustomPrintOnce(data, key, "运行时错误", show)
    data._daCustomShow = false
    data._daCustomTexture = nil
    data._daCustomHideBG = false
    data._daCustomRemaining = nil
    data._daCustomStacks = nil
    DoiteConditions:ApplyVisuals(key, false, false, false, false, 0)
    return true
  end

  _DoiteCustomClearError(data)
  data._daCustomShow = (show == true or show == 1)
  data._daCustomTexture = (type(texture) == "string" and texture ~= "") and texture or nil
  data._daCustomHideBG = (hideBackground == true)
  data._daCustomRemaining = (type(remaining) == "number") and remaining or nil
  data._daCustomStacks = (type(stacks) == "number") and stacks or nil

  DoiteConditions:ApplyVisuals(key, data._daCustomShow, false, false, false, 0)
  return true
end

function DoiteConditions:EvaluateCustom()
  local editingAny = _IsAnyKeyUnderEdit()
  local live = DoiteAurasDB and DoiteAurasDB.spells
  local edit = DoiteDB and DoiteDB.icons
  local touched = false

  if live then
    for key, data in pairs(live) do
      if type(data) ~= "table" then
        live[key] = nil
      elseif data.type == "Custom" then
        data.key = key
        if _DoiteCustomEvaluateOne(key, data) then
          touched = true
        end
      end
    end
  end

  if edit and editingAny then
    for key, data in pairs(edit) do
      if (not live) or (not live[key]) then
        if type(data) ~= "table" then
          edit[key] = nil
        elseif data.type == "Custom" then
          data.key = key
          if _DoiteCustomEvaluateOne(key, data) then
            touched = true
          end
        end
      end
    end
  end

  return touched
end

function DoiteConditions:EvaluateAuras()
  local editingAny = _IsAnyKeyUnderEdit()
  local live = DoiteAurasDB and DoiteAurasDB.spells
  local edit = DoiteDB and DoiteDB.icons
  if not live and not edit then
    return
  end

  local key, data

  -- 1) 活动图标（运行时集）
  if live then
    for key, data in pairs(live) do
      if type(data) ~= "table" then
        live[key] = nil
      elseif data.type == "Buff" or data.type == "Debuff" then
        data.key = key

        local show, glow, grey, fade, fadeAlpha = CheckAuraConditions(data)
        DoiteConditions:ApplyVisuals(key, show, glow, grey, fade, fadeAlpha)
      end
    end
  end

  -- 2) 任何额外的仅编辑器图标（不在 live 中的键）
  --    仅当至少有一个键正在编辑时才考虑，与之前相同。
  if edit and editingAny then
    for key, data in pairs(edit) do
      if (not live) or (not live[key]) then
        if type(data) ~= "table" then
          edit[key] = nil
        elseif data.type == "Buff" or data.type == "Debuff" then
          data.key = key

          local show, glow, grey, fade, fadeAlpha = CheckAuraConditions(data)
          DoiteConditions:ApplyVisuals(key, show, glow, grey, fade, fadeAlpha)
        end
      end
    end
  end
end


-- 小辅助函数：保持战士压制/复仇触发窗口同步
local function _WarriorProcTick()
  if not _isWarrior then
    return
  end
  if _WarriorProc.REV_until <= 0 and _WarriorProc.OP_until <= 0 then
    return
  end

  local nowAbs = GetTime()

  if _WarriorProc.REV_until > 0 and nowAbs > _WarriorProc.REV_until then
    _WarriorProc.REV_until = 0
    dirty_ability = true
  end

  if _WarriorProc.OP_until > 0 and nowAbs > _WarriorProc.OP_until then
    _WarriorProc.OP_until = 0
    dirty_ability = true
  end
end

_G.DoiteConditions_WarriorProcTick = _WarriorProcTick

-- 轻量级传递，仅刷新剩余时间文本/层数。
-- 无条件逻辑，无光环扫描 – 使用现有的缓存数据。
function DoiteConditions_UpdateTimeText()
  local live = DoiteAurasDB and DoiteAurasDB.spells
  local edit = DoiteDB and DoiteDB.icons
  if not live and not edit then
    return
  end

  -- 运行时图标（活动集）
  if live then
    -- 有时间逻辑的技能/物品键
    do
      local keys = _timeKeysAbilityItem_live
      local i, n = 1, table.getn(keys)
      while i <= n do
        local key = keys[i]
        local data = key and live[key]
        if type(data) == "table" and data.type then
          local frame = _GetIconFrame(key)
          if frame and frame.IsShown and frame:IsShown() then
            local dataTbl = (DoiteDB and DoiteDB.icons and DoiteDB.icons[key])
                or
                (DoiteAurasDB and DoiteAurasDB.spells and DoiteAurasDB.spells[key])
            if dataTbl then
              _Doite_UpdateOverlayForFrame(frame, key, dataTbl, frame._daSliding == true)
            end
          end
        end
        i = i + 1
      end
    end

    -- 有时间逻辑的光环键
    do
      local keys = _timeKeysAura_live
      local i, n = 1, table.getn(keys)
      while i <= n do
        local key = keys[i]
        local data = key and live[key]
        if type(data) == "table" and data.type then
          local frame = _GetIconFrame(key)
          if frame and frame.IsShown and frame:IsShown() then
            local dataTbl = (DoiteDB and DoiteDB.icons and DoiteDB.icons[key])
                or
                (DoiteAurasDB and DoiteAurasDB.spells and DoiteAurasDB.spells[key])
            if dataTbl then
              _Doite_UpdateOverlayForFrame(frame, key, dataTbl, frame._daSliding == true)
            end
          end
        end
        i = i + 1
      end
    end
  end

  -- 仅编辑器图标（不在 live 中的键）
  if edit then
    local skipKeys = live or _DA_EMPTY_TABLE

    -- 有时间逻辑的技能/物品键
    do
      local keys = _timeKeysAbilityItem_edit
      local i, n = 1, table.getn(keys)
      while i <= n do
        local key = keys[i]
        if key and (not skipKeys[key]) then
          local data = edit[key]
          if type(data) == "table" and data.type then
            local frame = _GetIconFrame(key)
            if frame and frame.IsShown and frame:IsShown() then
              local dataTbl = (DoiteDB and DoiteDB.icons and DoiteDB.icons[key])
                  or
                  (DoiteAurasDB and DoiteAurasDB.spells and DoiteAurasDB.spells[key])
              if dataTbl then
                _Doite_UpdateOverlayForFrame(frame, key, dataTbl, frame._daSliding == true)
              end
            end
          end
        end
        i = i + 1
      end
    end

    -- 有时间逻辑的光环键
    do
      local keys = _timeKeysAura_edit
      local i, n = 1, table.getn(keys)
      while i <= n do
        local key = keys[i]
        if key and (not skipKeys[key]) then
          local data = edit[key]
          if type(data) == "table" and data.type then
            local frame = _GetIconFrame(key)
            if frame and frame.IsShown and frame:IsShown() then
              local dataTbl = (DoiteDB and DoiteDB.icons and DoiteDB.icons[key])
                  or
                  (DoiteAurasDB and DoiteAurasDB.spells and DoiteAurasDB.spells[key])
              if dataTbl then
                _Doite_UpdateOverlayForFrame(frame, key, dataTbl, frame._daSliding == true)
              end
            end
          end
        end
        i = i + 1
      end
    end
  end
end

local _tick = CreateFrame("Frame", "DoiteConditionsTick")

-- 将这些保留为全局变量，以便 OnUpdate 脚本不会将它们捕获为上值
_acc = 0
_textAccum = 0
_distAccum = 0
_timeEvalAccum = 0

-- 武器临时附魔：仅在剩余时间 <= 60 秒时开始滴答
_teFastAccum = 0
_teProbeAccum = 0
_teFastActive = false

-- 将主体提升为真正的函数
function DoiteConditions_OnUpdate(dt)
  _acc = _acc + dt
  _textAccum = _textAccum + dt

  -- 0.5 秒心跳用于技能/物品基于时间的逻辑（冷却结束需要重新评估）。
  -- 心跳用于技能/物品基于时间的逻辑（冷却结束需要重新评估）。当武器临时附魔进入最后 60 秒时，更频繁地刷新，以便基于附魔的剩余/显示/隐藏响应更紧密的节奏。
  -- 0.5 秒心跳用于技能/物品基于时间的逻辑（冷却结束需要重新评估）。
  _timeEvalAccum = _timeEvalAccum + dt
  if _timeEvalAccum >= 0.5 then
    _timeEvalAccum = 0

    if _hasAnyAbilityTimeLogic then
      dirty_ability_time = true
    end

    if DoiteConditions and DoiteConditions._hasAnyItemLogic then
      dirty_aura = true
    end
  end

  -- 武器临时附魔快速滴答：
  -- 高于 60 秒：仅事件驱动（无滴答）。
  -- <=60 秒：以 0.10 秒滴答，以便在接近过期时保持显示/隐藏 + 剩余准确。
  do
    local dc = _G.DoiteConditions
    local te = dc and dc._daTempEnchantCache
    local hasTE = false

    if te then
      local now = GetTime()
      for _, slotC in pairs(te) do
        if slotC and slotC.endTime then
          local rem = slotC.endTime - now
          if rem > 0 then
            hasTE = true
            if rem <= 60 then
              _teFastActive = true
              break
            end
          end
        end
      end
    end

    if not hasTE then
      _teFastActive = false
    end

    if _teFastActive then
      _teFastAccum = _teFastAccum + dt
      if _teFastAccum >= 0.10 then
        _teFastAccum = 0
        dirty_ability_time = true
      end
    else
      _teFastAccum = 0
    end
  end

  -- 即使没有其他事件触发，也保持战士压制/复仇触发同步
  DoiteConditions_WarriorProcTick()

  -- 合并光环事件：在渲染/评估之前，每帧最多扫描/重建一次。
  DoiteConditions:ProcessPendingAuraScans()

  -- 平滑剩余时间文本（技能/物品/光环）在廉价路径上
  if _textAccum >= 0.1 then
    _textAccum = 0

    if _hasAnyAbilityTimeLogic or _hasAnyAuraTimeLogic or _teFastActive then
      DoiteConditions_UpdateTimeText()
    end
  end

  -- 轻量级距离心跳：保持目标距离检查的响应性。
  _distAccum = _distAccum + dt
  if _distAccum >= 0.15 then
    _distAccum = 0

    if UnitExists and UnitExists("target") then
      -- 仅当配置实际使用这些选项时才标记脏
      if _hasAnyTargetMods_Ability then
        dirty_ability = true
      end
      if _hasAnyTargetMods_Aura then
        dirty_aura = true
      end
    end
  end

  -- 滑动时渲染更快；否则约 30fps
  local thresh = (next(DoiteConditions_SlideMgr.active) ~= nil) and 0.03 or 0.10
  if _acc < thresh then
    return
  end
  _acc = 0

  local needAbilityLogic = dirty_ability or dirty_power
  local needAbilityTime = dirty_ability_time
  local needAura = dirty_aura or dirty_target or dirty_power
  local didCustom = false

  if needAbilityLogic or needAbilityTime then
    _G.DoiteConditions:EvaluateAbilities(needAbilityLogic, needAbilityTime)
  end
  if needAura then
    _G.DoiteConditions:EvaluateAuras()
  end

  -- 自定义函数在 OnUpdate 末尾附近运行。
  if _hasAnyCustomLogic then
    didCustom = _G.DoiteConditions:EvaluateCustom() and true or false
  end

  if needAbilityLogic or needAbilityTime or needAura or didCustom then
    dirty_aura, dirty_target, dirty_power = false, false, false
    dirty_ability_time = false
    -- 滑动时，技能图标每帧更新
    dirty_ability = next(DoiteConditions_SlideMgr.active) and true or false
  end
end

-- 避免每帧 pcall（分配/开销）。仅在调试时启用。
local function _DoiteConditions_OnUpdateWrapper()
  local dt = arg1 or 0
  if _G["DoiteAuras_DebugPcallOnUpdate"] == true then
    local ok, err = pcall(DoiteConditions_OnUpdate, dt)
    if not ok and DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage(
          "|cffff0000[DoiteAuras] OnUpdate 错误:|r " .. tostring(err)
      )
    end
  else
    DoiteConditions_OnUpdate(dt)
  end
end

_tick:SetScript("OnUpdate", _DoiteConditions_OnUpdateWrapper)

-- 预先加载光环快照并触发初始评估
if _G.UnitExists and _G.UnitExists("target") then
  DoiteConditions_ScanUnitAuras("target")
end
DoiteConditions._daItemSnapshotDirty = true
dirty_ability, dirty_aura, dirty_target, dirty_power = true, true, true, true

---------------------------------------------------------------
-- 事件处理 + 更平滑的更新
---------------------------------------------------------------
local eventFrame = CreateFrame("Frame", "DoiteConditionsEventFrame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("UNIT_MANA")
eventFrame:RegisterEvent("UNIT_ENERGY")
eventFrame:RegisterEvent("UNIT_RAGE")
eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:RegisterEvent("PLAYER_COMBO_POINTS")
eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED_GUID")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")

eventFrame:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" then
    -- 初始光环扫描
    if _G.UnitExists and _G.UnitExists("target") then
      DoiteConditions_ScanUnitAuras("target")
    end
    dirty_ability, dirty_aura, dirty_target, dirty_power = true, true, true, true
    DoiteConditions._daItemSnapshotDirty = true

    -- 缓存玩家职业以用于轻量级战士特定逻辑
    local _, cls = UnitClass("player")
    cls = cls and string.upper(cls) or ""
    _isWarrior = (cls == "WARRIOR")

    -- 预先加载时间心跳标志
    if _RebuildAbilityTimeHeartbeatFlag then
      _RebuildAbilityTimeHeartbeatFlag()
    end
    if _RebuildAuraTimeHeartbeatFlag then
      _RebuildAuraTimeHeartbeatFlag()
    end
    if _RebuildAuraUsageFlags then
      _RebuildAuraUsageFlags()
    end
    if _RebuildTargetModsFlags then
      _RebuildTargetModsFlags()
    end
  elseif event == "UNIT_AURA" then
    if arg1 == "player" then
      dirty_aura = true
      dirty_ability = true

    elseif arg1 == "target" then
      -- 仅当 *任何* 配置曾经查看目标光环时才关心。
      if _hasAnyTargetAuraUsage then
        -- 合并扫描/清除到 OnUpdate（每帧一次）
        DoiteConditions._pendingAuraScanTarget = true
        dirty_aura = true
        dirty_ability = true
      end
    end

  elseif event == "SPELLS_CHANGED" then
    -- 清除法术索引缓存和法术书类型缓存
    local cache = _G.DoiteConditions_SpellIndexCache
    if cache then
      for k in pairs(cache) do
        cache[k] = nil
      end
    end
    local btCache = _G.DoiteConditions_SpellBookTypeCache
    if btCache then
      for k in pairs(btCache) do
        btCache[k] = nil
      end
    end
    dirty_ability = true

  elseif event == "PLAYER_TARGET_CHANGED" then
    -- 如果在任何地方使用了目标光环跟踪，则在 OnUpdate 中扫描/清除一次。否则，保持快照为空，以便没有陈旧的目标光环数据能够匹配。
    if _hasAnyTargetAuraUsage then
      DoiteConditions._pendingAuraScanTarget = true
    else
      local snap = _G.DoiteConditions_AuraSnapshot
      local s = snap and snap.target
      if s then
        for k in pairs(s.buffs) do
          s.buffs[k] = nil
        end
        for k in pairs(s.debuffs) do
          s.debuffs[k] = nil
        end
      end
    end

    dirty_target, dirty_aura = true, true
    dirty_ability = true

  elseif event == "SPELL_UPDATE_COOLDOWN"
      or event == "UPDATE_SHAPESHIFT_FORM" then

    dirty_ability = true
    if DoiteConditions and DoiteConditions._hasAnyItemLogic then
      dirty_aura = true
    end

  elseif event == "UNIT_HEALTH" then
    if arg1 == "player" or arg1 == "target" then
      dirty_ability = true
      dirty_aura = true
    end

  elseif event == "PLAYER_COMBO_POINTS" then
    dirty_ability = true
    dirty_aura = true

  elseif event == "UNIT_MANA" or event == "UNIT_RAGE" or event == "UNIT_ENERGY" then
    if arg1 == "player" then
      dirty_power = true
    end

  elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
    dirty_ability, dirty_aura = true, true

  elseif event == "UNIT_INVENTORY_CHANGED_GUID" then
    if DoiteConditions and DoiteConditions._hasAnyItemLogic then
	  _RefreshPlayerItemSnapshot()
      DoiteConditions._daLastItemDirtyAt = GetTime()
      if _G.DoiteConditions_ClearTrinketFirstMemory then
        _G.DoiteConditions_ClearTrinketFirstMemory()
      end
      DoiteConditions._daItemSnapshotDirty = true

      -- 临时附魔跟踪：强制在下一次评估时刷新
      local te = DoiteConditions._daTempEnchantCache
      if te then
        if te[INV_SLOT_MAINHAND] then
          te[INV_SLOT_MAINHAND].t = 0
        end
        if te[INV_SLOT_OFFHAND] then
          te[INV_SLOT_OFFHAND].t = 0
        end
        if te[INV_SLOT_RANGED] then
          te[INV_SLOT_RANGED].t = 0
        end
      end

      dirty_ability = true
    end
  elseif event == "BAG_UPDATE" then
    if DoiteConditions and DoiteConditions._hasAnyItemLogic then
      local now = GetTime()
      local lastDirty = DoiteConditions._daLastItemDirtyAt or 0
      if (now - lastDirty) < 0.05 then
        return
      end
      DoiteConditions._daLastItemDirtyAt = now
      DoiteConditions._daItemSnapshotDirty = true
      dirty_ability = true
    end

  elseif event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
    -- 当队伍/团队成员变更时，重新评估所有条件
    dirty_ability, dirty_aura = true, true
  end
end)
