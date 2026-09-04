-- 加载 pfUI 环境
setfenv(1, pfUI:GetEnvironment())

--[[ libdebuff - GetUnitField 版本 ]]--
-- 一个 pfUI 库，用于检测并保存所有玩家、NPC 和敌人的持续减益效果。
--
-- 槽位映射来自 GetUnitField，而不是手动移位：常规减益占用真实光环槽
-- 33-48，第 17 个及之后的减益溢出到 1-32 的增益槽；只有 UnitDebuff 返回的
-- 显示槽位（1,2,3...）才是被压缩过的。多施法者追踪由本文件的所有权表维护。
--
--  libdebuff:UnitDebuff(unit, id)
--    返回指定单位上指定效果的减益信息。
--    name, rank, texture, stacks, dtype, duration, timeleft, caster

-- 如果不是在经典客户端上则立即返回
if pfUI.client > 11200 then return end

-- 如果另一个 libdebuff 已经激活则立即返回
if pfUI.api.libdebuff then return end

-- 修复 ruRU 捕获索引中的拼写错误（缺少 $）
if GetLocale() == "ruRU" then
  SPELLREFLECTSELFOTHER = gsub(SPELLREFLECTSELFOTHER, "%%2s", "%%2%$s")
end

local libdebuff = CreateFrame("Frame", "pfdebuffsScanner", UIParent)
local scanner = libtipscan:GetScanner("libdebuff")
local _, class = UnitClass("player")

-- ============================================================================
-- Nampower 支持
-- ============================================================================

local function IsNampowerAtLeast(major, minor, patch)
  if not GetNampowerVersion then return false end
  local haveMajor, haveMinor, havePatch = GetNampowerVersion()
  havePatch = havePatch or 0
  if haveMajor ~= major then return haveMajor > major end
  if haveMinor ~= minor then return haveMinor > minor end
  return havePatch >= patch
end

local function GetNampowerVersionString()
  local major, minor, patch = GetNampowerVersion()
  return major .. "." .. minor .. "." .. (patch or 0)
end

-- 最低要求版本：2.41.0（支持 CastSpellByName unitStr、SetMouseoverUnit）
local hasNampower = IsNampowerAtLeast(2, 41, 0)

-- GetUnitField 模式需要的事件 CVar
local nampowerCVars = {
  "NP_EnableSpellStartEvents",
  "NP_EnableSpellGoEvents",
  "NP_EnableAuraCastEvents",
  "NP_EnableAutoAttackEvents",
  "NP_EnableSpellHealEvents",
}

-- 返回：本次启用数量、原本已启用数量、读写失败数量
local function EnableNampowerCVars()
  local enabled, alreadyEnabled, failed = 0, 0, 0
  for _, cvar in ipairs(nampowerCVars) do
    local success, currentValue = pcall(GetCVar, cvar)
    if not success or not currentValue then
      failed = failed + 1
    elseif currentValue == "1" then
      alreadyEnabled = alreadyEnabled + 1
    elseif pcall(SetCVar, cvar, "1") then
      enabled = enabled + 1
    else
      failed = failed + 1
    end
  end
  return enabled, alreadyEnabled, failed
end

-- Nampower 启动检查：显示版本信息并确保 CVar 已设置。
-- 在 PLAYER_ENTERING_WORLD 后的第一个 OnUpdate 上运行，给 Nampower 初始化时间。
local nampowerCheckFrame = CreateFrame("Frame")
nampowerCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
nampowerCheckFrame:SetScript("OnEvent", function()
  -- 推迟到下一帧，以便 Nampower 完全初始化
  this:SetScript("OnUpdate", function()
    this:SetScript("OnUpdate", nil)
    this:UnregisterAllEvents()
    this:SetScript("OnEvent", nil)

    if not GetNampowerVersion then
      DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[libdebuff] 未找到 Nampower！减益追踪已禁用。|r")
      StaticPopup_Show("LIBDEBUFF_NAMPOWER_MISSING")
      return
    end

    local versionString = GetNampowerVersionString()
    if not IsNampowerAtLeast(3, 0, 0) then
      DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[libdebuff] 减益追踪已禁用！请将 Nampower 更新到 v3.0.0 或更高版本。|r")
      StaticPopup_Show("LIBDEBUFF_NAMPOWER_UPDATE", versionString)
      return
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[libdebuff]|r 检测到 Nampower v" .. versionString .. " - GetUnitField 模式已启用！")

    if not SetCVar or not GetCVar then return end

    local enabled, alreadyEnabled, failed = EnableNampowerCVars()
    if enabled > 0 then
      DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[libdebuff]|r 已启用 " .. enabled .. " 个 Nampower CVar")
    elseif alreadyEnabled == table.getn(nampowerCVars) then
      DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[libdebuff]|r 所有必需的 Nampower CVar 均已启用")
    end
    if failed > 0 then
      DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[libdebuff]|r 警告：无法检查/设置 " .. failed .. " 个 CVar")
    end
  end)
end)

-- ============================================================================
-- 数据结构
-- ============================================================================

-- ownDebuffs: [targetGUID][spellName] = {startTime, duration, texture, rank}
-- 仅存储我们自己施放的减益计时数据
pfUI.libdebuff_own = pfUI.libdebuff_own or {}
local ownDebuffs = pfUI.libdebuff_own

-- allAuraCasts: [targetGUID][spellName][casterGuid] = {startTime, duration, rank}
-- 存储所有减益的计时数据（多施法者支持）
pfUI.libdebuff_all_auras = pfUI.libdebuff_all_auras or {}
local allAuraCasts = pfUI.libdebuff_all_auras

-- slotOwnership: [targetGUID][auraSlot] = {casterGuid, spellName, spellId}
-- 将真实光环槽位（33-48）映射到施法者信息 - 无需移位！
pfUI.libdebuff_slot_ownership = pfUI.libdebuff_slot_ownership or {}
local slotOwnership = pfUI.libdebuff_slot_ownership

-- buffOwnership: [targetGUID][auraSlot] =
--   {casterGuid, spellId, spellName, isOurs}
-- BUFF_ADDED 给出真实槽位但不含施法者；用最近的 AURA_CAST 补齐归属。
pfUI.libdebuff_buff_ownership = pfUI.libdebuff_buff_ownership or {}
local buffOwnership = pfUI.libdebuff_buff_ownership

-- displayToAura: [targetGUID][displaySlot] = auraSlot
-- 将显示槽位（1-16）映射到真实光环槽位（33-48），用于 DEBUFF_REMOVED 关联
pfUI.libdebuff_display_to_aura = pfUI.libdebuff_display_to_aura or {}
local displayToAura = pfUI.libdebuff_display_to_aura

-- pendingCasts: [targetGUID][spellName] = {casterGuid, rank, time}
-- 从 SPELL_GO 到 DEBUFF_ADDED 关联的临时存储
pfUI.libdebuff_pending = pfUI.libdebuff_pending or {}
local pendingCasts = pfUI.libdebuff_pending

-- 法术图标缓存：[spellId] = texture
pfUI.libdebuff_icon_cache = pfUI.libdebuff_icon_cache or {}
local iconCache = pfUI.libdebuff_icon_cache

-- 施法追踪：[casterGuid] = {spellID, spellName, icon, startTime, duration, endTime}
-- 与姓名版共享，用于施法条显示
pfUI.libdebuff_casts = pfUI.libdebuff_casts or {}
pfUI.libdebuff_item_icons = pfUI.libdebuff_item_icons or {}  -- [casterGuid] = icon（在 SPELL_GO 后持续存在）

-- Cleveroids API：[targetGUID][spellID] = {start, duration, caster, stacks}
pfUI.libdebuff_objects_guid = pfUI.libdebuff_objects_guid or {}
local objectsByGuid = pfUI.libdebuff_objects_guid

-- 遗留：为向后兼容保留（外部模块可能检查它们）
pfUI.libdebuff_own_slots = pfUI.libdebuff_own_slots or {}
pfUI.libdebuff_all_slots = pfUI.libdebuff_all_slots or {}

-- 去重：追踪最近的 AURA_CAST 事件，忽略重复
-- [targetGuid][spellName][casterGuid] = 时间戳
pfUI.libdebuff_recent_casts = pfUI.libdebuff_recent_casts or {}
local recentCasts = pfUI.libdebuff_recent_casts

-- 记录最近施放法术的等级
pfUI.libdebuff_lastranks = pfUI.libdebuff_lastranks or {}
local lastCastRanks = pfUI.libdebuff_lastranks

-- 记录施放失败的法术
pfUI.libdebuff_lastfailed = pfUI.libdebuff_lastfailed or {}
local lastFailedSpells = pfUI.libdebuff_lastfailed

-- libpredict 的待处理施法信息（治疗预判目标追踪）
-- SPELL_CAST_EVENT 在 SPELLCAST_START 之前触发并带有 targetGuid，
-- 这使得 libpredict 能够知道队列中施法的正确目标。
-- 字段：{ spellId, spellName, targetGuid, time }
pfUI.libpredict_pending_cast = pfUI.libpredict_pending_cast or {}

-- 外部模块把回调写入 pfUI.libdebuff_<name>，libdebuff 在对应事件处理完成后
-- 依次触发。这里只负责创建缺失的表，已存在的表保持原引用。
local hookTables = {
  "spell_go_hooks",              -- fn(spellId, arg1..arg7) 处理 SPELL_GO_SELF 后
  "spell_go_other_hooks",        -- fn(spellId, casterGuid, targetGuid)
  "spell_start_self_hooks",      -- fn(spellId, casterGuid, targetGuid, castTime)
  "spell_start_other_hooks",     -- fn(spellId, casterGuid, targetGuid, castTime)
  "spell_failed_other_hooks",    -- fn(casterGuid, spellId)
  "aura_cast_on_self_hooks",     -- fn(spellId, casterGuid, targetGuid)
  "aura_cast_on_other_hooks",    -- fn(spellId, casterGuid, targetGuid)
  "debuff_added_other_hooks",    -- fn(guid, luaSlot, spellId, stackCount)
  "debuff_removed_other_hooks",  -- fn(guid, luaSlot, spellId, stackCount)
  "unit_health_hooks",           -- fn(unitToken)
  "player_target_changed_hooks", -- fn()
  "unit_died_hooks",             -- fn(guid)
  "spell_cast_hooks",            -- fn(success, spellId, castType, targetGuid)
}
for _, name in ipairs(hookTables) do
  local key = "libdebuff_" .. name
  pfUI[key] = pfUI[key] or {}
end

local function FireHooks(hooks, a1, a2, a3, a4, a5, a6, a7, a8)
  if not hooks then return end
  for _, fn in pairs(hooks) do
    fn(a1, a2, a3, a4, a5, a6, a7, a8)
  end
end

-- 从 SPELL_CAST_EVENT 捕获的连击点数（在客户端消耗之前）
-- SPELL_CAST_EVENT 在 UnitAura 更新之前触发，因此 GetComboPoints() 仍然有效
local capturedCP = nil

-- ============================================================================
-- 静态弹出对话框
-- ============================================================================

StaticPopupDialogs["LIBDEBUFF_NAMPOWER_UPDATE"] = {
  text = "|cffff0000！！！警告！！！|r\n\n需要更新 Nampower！\n\n您当前的版本：%s\n所需版本：3.0.0+\n\n请更新 Nampower 以继续使用 pfUI！",
  button1 = "显示下载链接",
  button2 = "忽略",
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 0,
  preferredIndex = 3,
  OnAccept = function()
    pfUI.chat.urlcopy.CopyText("https://gitea.com/avitasia/nampower/releases/tag/v3.0.0")
  end,
}

StaticPopupDialogs["LIBDEBUFF_NAMPOWER_MISSING"] = {
  text = "|cffff0000！！！警告！！！|r\n\n未找到 Nampower！\n\npfUI 正常运行需要 Nampower 3.0.0+。\n\n请安装 Nampower！",
  button1 = "显示下载链接",
  button2 = "忽略",
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 0,
  preferredIndex = 3,
  OnAccept = function()
    pfUI.chat.urlcopy.CopyText("https://gitea.com/avitasia/nampower/releases")
  end,
}

-- ============================================================================
-- 法术数据表
-- ============================================================================

-- 只有一个玩家可以拥有的减益（覆盖其他施法者）
local selfOverwriteDebuffs = {
  ["精灵之火"] = true,
  ["精灵之火（野性）"] = true,
  ["挫志怒吼"] = true,
  ["挫志咆哮"] = true,
  ["猎人印记"] = true,
  ["破甲攻击"] = true,
  ["雷霆一击"] = true,
  ["破甲"] = true,
  ["暗影易伤"] = true,
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
}

-- 猎人陷阱效果：没有 AURA_CAST 事件，只能在 DEBUFF_ADDED 时归给玩家自己
local trapDebuffs = {
  ["爆炸陷阱效果"] = true,
  ["冰霜陷阱光环"] = true,
  -- 其他陷阱效果可按需添加
}

-- 相互覆盖的减益对
local debuffOverwritePairs = {
  ["精灵之火"] = "精灵之火（野性）",
  ["精灵之火（野性）"] = "精灵之火",
  ["挫志怒吼"] = "挫志咆哮",
  ["挫志咆哮"] = "挫志怒吼",
}

-- 连击点技能：仅显示我们自己的施法计时器
local combopointAbilities = {
  -- Druid
  ["撕扯"] = { base = 8,  perCP = 2 },

  -- Rogue
  ["割裂"] = { base = 6, perCP = 2 },
  ["肾击"] = { base = 1, perCP = 1 },
  ["切割"] = { base = 9, perCP = 3 },
  ["破甲"] = { base = 30, perCP = 0 },  -- fixed 30s
}

-- Nampower 对多效果法术会连发多个 AURA_CAST，此窗口内的重复事件忽略
local AURA_CAST_DEDUPE_WINDOW = 0.1

-- 解离类型映射：SpellRec.dispel 索引 -> 暴雪 DebuffTypeColor 键
local dispelTypeMap = {
  [1] = "Magic",
  [2] = "Curse",
  [3] = "Disease",
  [4] = "Poison",
}

-- ============================================================================
-- 通用辅助函数
-- ============================================================================

local function IsEmptyTable(t)
  if not t then return true end
  for _ in pairs(t) do return false end
  return true
end

-- 删除超过 maxAge 的 [key] = {time = ...} 记录
local function ExpireByTime(entries, maxAge, now)
  for key, data in pairs(entries) do
    if now - data.time > maxAge then
      entries[key] = nil
    end
  end
end

-- 光环剩余时间（秒）；负值表示已过期
local function TimeLeft(data, now)
  return (data.startTime + data.duration) - (now or GetTime())
end

-- 仍在生效的高等级效果不能被低等级覆盖；返回被保护的剩余时间
local function HigherRankTimeLeft(existing, rankNum)
  if not existing or not rankNum or rankNum <= 0 then return nil end
  if not existing.rank or not existing.startTime or not existing.duration then
    return nil
  end
  local timeleft = TimeLeft(existing)
  if timeleft > 0 and rankNum < existing.rank then return timeleft end
end

-- 有效的追踪目标 GUID
local function IsTrackableGuid(guid)
  return guid and guid ~= "" and guid ~= "0x0000000000000000" and true or false
end

-- 图标 API 可能只返回短名，SetTexture 需要完整路径
local function NormalizeIconPath(texture)
  if texture and not string.find(texture, "\\") then
    return "Interface\\Icons\\" .. texture
  end
  return texture
end

local function GetTalentRank(tab, index)
  local _, _, _, _, rank = GetTalentInfo(tab, index)
  return rank or 0
end

local function SpellNameByRecField(spellId)
  return GetSpellRecField and GetSpellRecField(spellId, "name")
end

local function SpellNameByRec(spellId)
  if not GetSpellRec then return nil end
  local rec = GetSpellRec(spellId)
  return rec and rec.name or nil
end

local function GetDispelType(spellId)
  if not spellId or not GetSpellRecField then return nil end
  local dispelId = GetSpellRecField(spellId, "dispel")
  if dispelId and dispelId > 0 then
    return dispelTypeMap[dispelId]
  end
end

local function IsComboPointAbility(spellName)
  return spellName and combopointAbilities[spellName] and true or false
end

-- 连击点技能的基础时长与每点加成
local function GetComboPointData(spellName)
  local cpData = spellName and combopointAbilities[spellName]
  if not cpData then return nil, nil end
  if spellName == "割裂" then
    local talentRank = GetTalentRank(1, 10)
    if talentRank > 0 then
      return cpData.base + talentRank * 2, cpData.perCP
    end
  end
  return cpData.base, cpData.perCP
end

-- 玩家 GUID 缓存
local playerGUID = nil
local function GetPlayerGUID()
  if not playerGUID and UnitExists then
    local _, guid = UnitExists("player")
    playerGUID = guid
  end
  return playerGUID
end

-- ============================================================================
-- 调试统计
-- ============================================================================

pfUI.libdebuff_debugstats = pfUI.libdebuff_debugstats or {
  enabled = false,
  nampower_aura_logging = false,
  trackAllUnits = false,
  aura_cast = 0,
  nampower_aura_events = 0,
  debuff_added = 0,
  debuff_removed = 0,
  getunitfield_calls = 0,
}
local debugStats = pfUI.libdebuff_debugstats

local debugCounters = {
  "aura_cast", "nampower_aura_events", "debuff_added", "debuff_removed",
  "getunitfield_calls",
}

local function ResetDebugCounters()
  for _, key in ipairs(debugCounters) do
    debugStats[key] = 0
  end
end

local function DebugGuid(guid)
  if not guid then return "nil" end
  local str = tostring(guid)
  if string.len(str) > 4 then
    return string.sub(str, -4)
  end
  return str
end

local function IsCurrentTarget(guid)
  if debugStats.trackAllUnits then return true end
  if not guid or not UnitExists then return false end
  local _, targetGuid = UnitExists("target")
  return targetGuid == guid
end

-- 详细日志只针对当前目标（trackAllUnits 时针对所有单位）
local function IsDebugTarget(guid)
  return debugStats.enabled and IsCurrentTarget(guid)
end

local function GetDebugTimestamp()
  return string.format("[%.3f]", GetTime())
end

local function DebugUnitField(guid, field)
  if not GetUnitField then return nil end
  local ok, value = pcall(GetUnitField, guid, field)
  if ok then return value end
end

-- ============================================================================
-- 光环标志位
-- ============================================================================

local function AuraFlagBit(value, mask)
  if type(value) ~= "number" then return nil end
  local shifted = math.floor(value / mask)
  return shifted - math.floor(shifted / 2) * 2
end

-- auraFlags 每个 32 位字打包 8 个槽位，每槽 4 位
local function GetAuraFlagNibble(flags, auraSlot)
  if type(flags) ~= "table" or type(auraSlot) ~= "number" or
    auraSlot < 1 or auraSlot > 48 then return nil end

  local rawSlot = auraSlot - 1
  local wordIndex = math.floor(rawSlot / 8) + 1
  local word = flags[wordIndex]
  if type(word) ~= "number" then return nil end

  local offset = rawSlot - math.floor(rawSlot / 8) * 8
  local divisor = 1
  for _ = 1, offset do divisor = divisor * 16 end
  local shifted = math.floor(word / divisor)
  return shifted - math.floor(shifted / 16) * 16
end

-- 返回：有益位（0x4）、有害位（0x8）、原始 nibble
local function GetAuraFlagBits(flags, auraSlot)
  local nibble = GetAuraFlagNibble(flags, auraSlot)
  return AuraFlagBit(nibble, 4), AuraFlagBit(nibble, 8), nibble
end

-- 标志位缺失时按事件名兜底判定光环类型
local function AuraKindFromFlags(helpfulBit, harmfulBit, eventName)
  if harmfulBit == 1 then return "DEBUFF" end
  if helpfulBit == 1 then return "BUFF" end
  if eventName == "DEBUFF_ADDED_OTHER" or
    eventName == "DEBUFF_REMOVED_OTHER" then return "DEBUFF" end
  return "BUFF"
end

-- Nampower 的 BUFF_/DEBUFF_ 事件名不可靠（溢出减益会走增益槽），
-- 这里用真实光环标志位或已记录的所有权还原真正的类型。
function libdebuff:NormalizeOtherAuraEvent(eventName, guid, spellId, rawSlot)
  local added = eventName == "BUFF_ADDED_OTHER" or
    eventName == "DEBUFF_ADDED_OTHER"
  local removed = eventName == "BUFF_REMOVED_OTHER" or
    eventName == "DEBUFF_REMOVED_OTHER"
  if not added and not removed then return nil end

  local auraSlot = type(rawSlot) == "number" and rawSlot >= 0 and
    rawSlot <= 47 and rawSlot + 1 or nil
  local kind

  if added and guid and auraSlot and GetUnitField then
    local helpfulBit, harmfulBit = GetAuraFlagBits(
      GetUnitField(guid, "auraFlags"), auraSlot
    )
    kind = AuraKindFromFlags(helpfulBit, harmfulBit, eventName)
  elseif removed and guid and auraSlot then
    local ownership = slotOwnership[guid] and slotOwnership[guid][auraSlot]
    if ownership and ownership.spellId == spellId then
      kind = "DEBUFF"
    else
      ownership = buffOwnership[guid] and buffOwnership[guid][auraSlot]
      if ownership and ownership.spellId == spellId then kind = "BUFF" end
    end
  end

  kind = kind or AuraKindFromFlags(nil, nil, eventName)
  return kind .. (added and "_ADDED_OTHER" or "_REMOVED_OTHER")
end

function libdebuff:DebugNampowerAuraEvent(
  eventName, guid, luaSlot, spellId, stacks, auraLevel, rawSlot, state
)
  if not debugStats.nampower_aura_logging or
    (eventName ~= "BUFF_ADDED_SELF" and
      eventName ~= "BUFF_ADDED_OTHER" and
      eventName ~= "DEBUFF_ADDED_OTHER") or
    not IsCurrentTarget(guid) then return end

  debugStats.nampower_aura_events =
    (debugStats.nampower_aura_events or 0) + 1

  local helpfulBit, harmfulBit, flagNibble
  if type(rawSlot) == "number" and rawSlot >= 0 and rawSlot <= 47 then
    helpfulBit, harmfulBit, flagNibble = GetAuraFlagBits(
      DebugUnitField(guid, "auraFlags"), rawSlot + 1
    )
  end

  local auraKind = AuraKindFromFlags(helpfulBit, harmfulBit, eventName)
  local flagNibbleHex = type(flagNibble) == "number" and
    string.format("%X", flagNibble) or "nil"

  DEFAULT_CHAT_FRAME:AddMessage(string.format(
    "|cff66ccff[%s]|r %s(%s,%s,%s,%s,%s,%s,%s) %s f=%s",
    auraKind, tostring(eventName), DebugGuid(guid),
    tostring(luaSlot), tostring(spellId), tostring(stacks),
    tostring(auraLevel), tostring(rawSlot), tostring(state),
    tostring(SpellNameByRecField(spellId) or "?"), flagNibbleHex
  ))
end

-- ============================================================================
-- 法术图标
-- ============================================================================

function libdebuff:GetSpellIcon(spellId)
  if not spellId or type(spellId) ~= "number" or spellId <= 0 then
    return "Interface\\Icons\\INV_Misc_QuestionMark"
  end

  if iconCache[spellId] then
    return iconCache[spellId]
  end

  local texture = nil
  if GetSpellRecField and GetSpellIconTexture then
    local spellIconId = GetSpellRecField(spellId, "spellIconID")
    if spellIconId and type(spellIconId) == "number" and spellIconId > 0 then
      texture = NormalizeIconPath(GetSpellIconTexture(spellIconId))
    end
  end

  iconCache[spellId] = texture or "Interface\\Icons\\INV_Misc_QuestionMark"
  return iconCache[spellId]
end

pfUI.libdebuff_GetSpellIcon = function(spellId)
  return libdebuff:GetSpellIcon(spellId)
end

function libdebuff:DidSpellFail(spell)
  if not spell then return false end
  local data = lastFailedSpells[spell]
  return data and (GetTime() - data.time) < 1 or false
end

-- ============================================================================
-- 核心：基于 GetUnitField 的槽位映射
-- ============================================================================

-- GetDebuffSlotMap 的结果缓存：[guid] = {map, timestamp}
local slotMapCache = {}
local SLOT_MAP_CACHE_DURATION = 0.05  -- 50ms 缓存（1-2 帧）

local harmfulSpellCache = {}
local function IsHarmfulSpellId(spellId)
  local harmful = harmfulSpellCache[spellId]
  if harmful ~= nil then return harmful end
  local ok, attributesEx = pcall(GetSpellRecField, spellId, "attributesEx")
  if not ok then attributesEx = nil end
  local shifted = attributesEx and math.floor(attributesEx / 128)
  harmful = shifted and shifted ~= math.floor(shifted / 2) * 2 or false
  harmfulSpellCache[spellId] = harmful
  return harmful
end

-- 直接通过 GetUnitField 读取当前减益状态
-- 返回：{ [displaySlot] = {auraSlot, buffDisplaySlot, spellId,
--   spellName, stacks, texture, dtype} }
-- 显示槽位 1-16 来自真实槽 33-48；溢出到增益槽的减益用 16+auraSlot 表示。
local function GetDebuffSlotMap(guid)
  if not guid or not GetUnitField then
    return nil
  end

  local now = GetTime()
  local cached = slotMapCache[guid]
  if cached and cached.map and (now - cached.timestamp) < SLOT_MAP_CACHE_DURATION then
    return cached.map
  end

  local auras = GetUnitField(guid, "aura")
  if not auras then return nil end

  local auraApps = GetUnitField(guid, "auraApplications")
  local auraFlags = GetUnitField(guid, "auraFlags")

  if debugStats.enabled then
    debugStats.getunitfield_calls = debugStats.getunitfield_calls + 1
  end

  local map = {}
  local displaySlot = 0
  local buffDisplaySlot = 0

  for auraSlot = 1, 48 do
    local spellId = auras[auraSlot]
    if spellId and spellId > 0 then
      if auraSlot <= 32 then
        buffDisplaySlot = buffDisplaySlot + 1
      end

      local outputSlot
      if auraSlot > 32 then
        displaySlot = displaySlot + 1
        outputSlot = displaySlot
      else
        -- 增益槽里的光环只有被标记为有害或由我们登记过才算减益
        local ownership = slotOwnership[guid] and slotOwnership[guid][auraSlot]
        local ownedDebuff = ownership and ownership.spellId == spellId
        local _, harmfulBit = GetAuraFlagBits(auraFlags, auraSlot)
        if harmfulBit == 1 or
          (harmfulBit == nil and IsHarmfulSpellId(spellId)) or ownedDebuff
        then
          outputSlot = 16 + auraSlot
        end
      end

      if outputSlot then
        map[outputSlot] = {
          auraSlot = auraSlot,
          buffDisplaySlot = auraSlot <= 32 and buffDisplaySlot or nil,
          spellId = spellId,
          spellName = SpellNameByRecField(spellId) or "未知",
          -- auraApplications 从 0 开始计数
          stacks = (auraApps and auraApps[auraSlot] or 0) + 1,
          texture = libdebuff:GetSpellIcon(spellId),
          dtype = GetDispelType(spellId),
        }
      end
    end
  end

  -- 复用缓存条目，避免和调用方持有的引用互相失效
  cached = slotMapCache[guid]
  if not cached then
    cached = {}
    slotMapCache[guid] = cached
  end
  cached.map = map
  cached.timestamp = now

  return map
end

function libdebuff:IsOverflowDebuff(unit, buffSlot)
  if not hasNampower or not GetUnitGUID or not buffSlot or buffSlot < 1 or buffSlot > 32 then
    return false
  end

  local guid = GetUnitGUID(unit)
  local map = guid and GetDebuffSlotMap(guid)
  local data = map and map[16 + buffSlot]
  return data and true or false, data and data.buffDisplaySlot
end

function libdebuff:IsOverflowBuff(unit, displaySlot)
  if not hasNampower or not GetUnitGUID or not displaySlot then return false end
  local guid = GetUnitGUID(unit)
  local map = guid and GetDebuffSlotMap(guid)
  if not map then return false end
  for rawSlot = 1, 32 do
    local data = map[16 + rawSlot]
    if data and data.buffDisplaySlot == displaySlot then return true end
  end
  return false
end

function libdebuff:NotifyUnitFrameAuras(guid)
  local frames = pfUI.uf and pfUI.uf.frames
  if not guid or type(frames) ~= "table" or not GetUnitGUID then return end
  for _, frame in pairs(frames) do
    local unit = frame and frame.label and
      frame.label .. (frame.id or "")
    if unit and unit ~= "" and
      (unit == guid or GetUnitGUID(unit) == guid)
    then
      frame.update_aura = true
    end
  end
end

-- ============================================================================
-- 施法者归属
-- ============================================================================

-- 最近一次施放该法术的施法者：返回 casterGuid, startTime
local function GetLatestCaster(casts)
  if not casts then return nil end
  local casterGuid, castTime = nil, 0
  for caster, data in pairs(casts) do
    if data.startTime and data.startTime > castTime then
      casterGuid, castTime = caster, data.startTime
    end
  end
  return casterGuid, castTime
end

-- 1 秒内的最近施法者，用于给没有施法者信息的 BUFF_ADDED 补齐归属
local function GetRecentAuraCaster(guid, spellName)
  local casterGuid, castTime = GetLatestCaster(
    allAuraCasts[guid] and allAuraCasts[guid][spellName]
  )
  if casterGuid and GetTime() - castTime <= 1 then return casterGuid end
end

function libdebuff:UnitBuffCaster(unit, buffSlot, spellName)
  if not hasNampower or not GetUnitGUID then return nil end
  if not spellName then return nil end
  local guid = GetUnitGUID(unit)
  if not guid then return nil end
  local ownership = guid and buffOwnership[guid] and
    buffOwnership[guid][buffSlot]
  if not ownership or ownership.spellName ~= spellName then
    ownership = nil
    for _, data in pairs(buffOwnership[guid] or {}) do
      if data.spellName == spellName then
        ownership = data
        break
      end
    end
  end
  if not ownership then return nil end
  if ownership.isOurs then return "player" end
  if ownership.casterGuid then return "other" end
end

function libdebuff:UpdateBuffOwnershipFromCast(
  targetGuid, spellId, casterGuid, isOurs
)
  local ownership = buffOwnership[targetGuid]
  if not ownership then return end
  for _, data in pairs(ownership) do
    if data.spellId == spellId then
      data.casterGuid = casterGuid
      data.isOurs = isOurs
    end
  end
end

function libdebuff:HandleBuffOwnershipEvent(
  eventName, guid, spellId, auraSlot_0based, state
)
  if not guid or not spellId then return end
  local auraSlot = auraSlot_0based and (auraSlot_0based + 1) or nil

  if eventName == "BUFF_ADDED_SELF" or eventName == "BUFF_ADDED_OTHER" then
    -- 事件没带槽位时在增益区间里反查
    if not auraSlot and GetUnitField then
      local auras = GetUnitField(guid, "aura")
      if auras then
        for slot = 1, 32 do
          if auras[slot] == spellId then
            auraSlot = slot
            break
          end
        end
      end
    end
    if not auraSlot then return end

    local spellName = SpellNameByRecField(spellId)
    local casterGuid = spellName and
      GetRecentAuraCaster(guid, spellName) or nil
    local myGuid = GetPlayerGUID()
    buffOwnership[guid] = buffOwnership[guid] or {}
    buffOwnership[guid][auraSlot] = {
      casterGuid = casterGuid,
      spellId = spellId,
      spellName = spellName,
      isOurs = myGuid and casterGuid == myGuid or false,
    }
  elseif state ~= 2 and buffOwnership[guid] then
    if auraSlot then
      buffOwnership[guid][auraSlot] = nil
    else
      for slot, ownership in pairs(buffOwnership[guid]) do
        if ownership.spellId == spellId then
          buffOwnership[guid][slot] = nil
        end
      end
    end
  end
  slotMapCache[guid] = nil
end

-- 指定光环槽位的施法者信息：返回 casterGuid, isOurs
local function GetSlotCaster(guid, auraSlot, spellName)
  -- 首选我们自己登记的槽位所有权
  local ownership = slotOwnership[guid] and slotOwnership[guid][auraSlot]
  -- 校验法术名，槽位可能已被复用
  if ownership and ownership.spellName == spellName then
    return ownership.casterGuid, ownership.isOurs
  end

  local myGuid = GetPlayerGUID()
  if ownDebuffs[guid] and ownDebuffs[guid][spellName] then
    return myGuid, true
  end

  -- 回退：接受任意仍在生效的施法
  if allAuraCasts[guid] and allAuraCasts[guid][spellName] then
    for casterGuid, data in pairs(allAuraCasts[guid][spellName]) do
      if TimeLeft(data) > 0 then
        return casterGuid, (casterGuid == myGuid)
      end
    end
  end

  return nil, false
end

-- ============================================================================
-- 清理
-- ============================================================================

local lastRangeCheck = 0

-- 按 GUID 索引的追踪表，统一清理
local guidTables = {
  ownDebuffs, slotOwnership, buffOwnership, allAuraCasts, objectsByGuid,
  pendingCasts,
}

-- 复用缓冲区，避免每次调用创建表
local _cleanupBuf1 = {}
local _cleanupBuf2 = {}

local function CleanupUnit(guid)
  if not guid then return false end

  local cleaned = false
  for _, entries in ipairs(guidTables) do
    if entries[guid] then
      entries[guid] = nil
      cleaned = true
    end
  end

  if cleaned and IsDebugTarget(guid) then
    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffff0000[清理]|r GUID %s", DebugGuid(guid)))
  end

  return cleaned
end

local function CleanupExpiredTimers(guid)
  local now = GetTime()
  local grace = -2  -- 过期后仍保留 2 秒宽限

  if ownDebuffs[guid] then
    local n = 0
    for spellName, data in pairs(ownDebuffs[guid]) do
      if TimeLeft(data, now) < grace then
        n = n + 1
        _cleanupBuf1[n] = spellName
      end
    end
    for i = 1, n do
      ownDebuffs[guid][_cleanupBuf1[i]] = nil
      _cleanupBuf1[i] = nil
    end
  end

  if allAuraCasts[guid] then
    for spellName, casterTable in pairs(allAuraCasts[guid]) do
      local n = 0
      for casterGuid, data in pairs(casterTable) do
        if TimeLeft(data, now) < grace then
          n = n + 1
          _cleanupBuf2[n] = casterGuid
        end
      end
      for i = 1, n do
        casterTable[_cleanupBuf2[i]] = nil
        _cleanupBuf2[i] = nil
      end
      if IsEmptyTable(casterTable) then
        allAuraCasts[guid][spellName] = nil
      end
    end
  end
end

local function CleanupOutOfRangeUnits()
  local now = GetTime()
  if now - lastRangeCheck < 10 then return end
  lastRangeCheck = now

  local allGuids = {}
  for _, entries in ipairs(guidTables) do
    for guid in pairs(entries) do allGuids[guid] = true end
  end

  for guid in pairs(allGuids) do
    local exists = UnitExists and UnitExists(guid)
    local isDead = UnitIsDead and UnitIsDead(guid)

    if not exists or isDead then
      CleanupUnit(guid)
    end
  end

  ExpireByTime(lastCastRanks, 3, now)
  ExpireByTime(lastFailedSpells, 2, now)

  for guid, spells in pairs(pendingCasts) do
    ExpireByTime(spells, 1, now)
    if IsEmptyTable(spells) then
      pendingCasts[guid] = nil
    end
  end
end

-- ============================================================================
-- 持续时间
-- ============================================================================

function libdebuff:GetDuration(effect, rank)
  local durations = L["debuffs"][effect]
  if not durations then return 0 end

  local rankId = rank and tonumber((string.gsub(rank, RANK, ""))) or 0
  if not durations[rankId] then rankId = libdebuff:GetMaxRank(effect) end
  local duration = durations[rankId]

  local dyn = L["dyndebuffs"]
  if effect == dyn["Rupture"] then
    duration = duration + (GetComboPoints() or 0) * 2
  elseif effect == dyn["Kidney Shot"] then
    duration = duration + (GetComboPoints() or 0) * 1
  elseif effect == "撕扯" or effect == dyn["Rip"] then
    duration = 8 + (GetComboPoints() or 0) * 2
  elseif effect == dyn["Demoralizing Shout"] then
    local talentRank = GetTalentRank(2, 1)
    if talentRank > 0 then duration = duration + (duration / 100 * (talentRank * 10)) end
  elseif effect == dyn["Shadow Word: Pain"] then
    duration = duration + GetTalentRank(3, 4) * 3
  elseif effect == dyn["Frostbolt"] then
    duration = duration + GetTalentRank(3, 7)
  elseif effect == dyn["Gouge"] then
    duration = duration + GetTalentRank(3, 3) * .5
  end
  return duration
end

function libdebuff:GetMaxRank(effect)
  local max = 0
  for id in pairs(L["debuffs"][effect]) do
    if id > max then max = id end
  end
  return max
end

function libdebuff:UpdateDuration(unit, unitlevel, effect, duration)
  if not unit or not effect or not duration then return end
  unitlevel = unitlevel or 0

  local effects = libdebuff.objects[unit] and libdebuff.objects[unit][unitlevel]
  if effects and effects[effect] then
    effects[effect].duration = duration
  end
end

function libdebuff:UpdateUnits()
  if not pfUI.uf or not pfUI.uf.target then return end
  pfUI.uf:RefreshUnit(pfUI.uf.target, "aura")
end

-- ============================================================================
-- 遗留 API（turtle-wow.lua 兼容）
-- ============================================================================

libdebuff.pending = {}
libdebuff.objects = {}

function libdebuff:AddPending(unit, unitlevel, effect, duration, caster, rank)
  if not unit or duration <= 0 then return end
  if not L["debuffs"][effect] then return end
  if libdebuff.pending[3] then return end

  libdebuff.pending[1] = unit
  libdebuff.pending[2] = unitlevel or 0
  libdebuff.pending[3] = effect
  libdebuff.pending[4] = duration
  libdebuff.pending[5] = caster
  libdebuff.pending[6] = rank

  QueueFunction(libdebuff.PersistPending)
end

function libdebuff:RemovePending()
  for i = 1, 6 do libdebuff.pending[i] = nil end
end

function libdebuff:PersistPending(effect)
  if not libdebuff.pending[3] then return end

  if libdebuff.pending[3] == effect or ( effect == nil and libdebuff.pending[3] ) then
    local p1, p2, p3, p4, p5, p6 = libdebuff.pending[1], libdebuff.pending[2], libdebuff.pending[3], libdebuff.pending[4], libdebuff.pending[5], libdebuff.pending[6]
    libdebuff.AddEffect(libdebuff, p1, p2, p3, p4, p5, p6)
  end

  libdebuff:RemovePending()
end

function libdebuff:AddEffect(unit, unitlevel, effect, duration, caster, rank)
  if not rank and caster == "player" and effect then
    if libdebuff.pending[3] == effect and libdebuff.pending[6] then
      rank = libdebuff.pending[6]
    elseif lastCastRanks[effect] and (GetTime() - lastCastRanks[effect].time) < 2 then
      rank = lastCastRanks[effect].rank
    end
  end

  if not unit then return end
  unitlevel = unitlevel or 0

  libdebuff.objects[unit] = libdebuff.objects[unit] or {}
  libdebuff.objects[unit][unitlevel] = libdebuff.objects[unit][unitlevel] or {}

  -- 没给时长时查法术数据库
  if not duration or duration == 0 then
    duration = libdebuff:GetDuration(effect, rank)
  end

  local effects = libdebuff.objects[unit][unitlevel]
  local entry = effects[effect] or {}
  effects[effect] = entry

  entry.start = GetTime()
  entry.duration = duration
  entry.caster = caster
  entry.rank = rank
end

-- ============================================================================
-- 主 API：UnitDebuff（基于 GetUnitField）
-- ============================================================================

local cache = {}

-- 读取暴雪原生减益，并用 tooltip scanner 补出名称
local function ScanUnitDebuff(unit, displaySlot)
  local texture, stacks, dtype = UnitDebuff(unit, displaySlot)
  local effect
  if texture then
    scanner:SetUnitDebuff(unit, displaySlot)
    effect = scanner:Line(1) or ""
  end
  return effect, texture, stacks, dtype
end

-- 我们自己施放的计时数据：返回 duration, timeleft, rank
local function GetOwnTimer(guid, effect)
  local data = ownDebuffs[guid] and ownDebuffs[guid][effect]
  if not data then return nil end
  local remaining = TimeLeft(data)
  -- 宽限期内继续显示，剩余时间归零
  if remaining <= -1 then return nil end
  return data.duration, remaining > 0 and remaining or 0, data.rank
end

-- 其他施法者的计时数据：返回 duration, timeleft, rank
local function GetCastTimer(data)
  if not data then return nil end
  local remaining = TimeLeft(data)
  if remaining > 0 and data.duration > 0 then
    return data.duration, remaining, data.rank
  end
end

function libdebuff:UnitDebuff(unit, displaySlot)
  -- Nampower：所有减益数据都来自 GetUnitField，不需要暴雪的 UnitDebuff
  if hasNampower and GetUnitGUID then
    local guid = GetUnitGUID(unit)
    if not guid then
      -- 安全兜底：拿不到 GUID（有 Nampower 时不应发生）
      local effect, texture, stacks, dtype = ScanUnitDebuff(unit, displaySlot)
      return effect, nil, texture, stacks, dtype, nil, -1, nil
    end

    -- 当前槽位映射来自 GetUnitField（缓存 50ms）
    local slotMap = GetDebuffSlotMap(guid)
    local slotData = slotMap and slotMap[displaySlot]
    if not slotData then return nil end

    local effect = slotData.spellName
    local slotCasterGuid, isOurs = GetSlotCaster(guid, slotData.auraSlot, effect)
    local duration, timeleft, rank, caster = nil, -1, nil, nil

    if isOurs then
      caster = "player"
      local ownDuration, ownTimeleft, ownRank = GetOwnTimer(guid, effect)
      if ownDuration then
        duration, timeleft, rank = ownDuration, ownTimeleft, ownRank
      end
    else
      if slotCasterGuid then caster = "other" end

      local casts = allAuraCasts[guid] and allAuraCasts[guid][effect]
      if slotCasterGuid and casts then
        duration, timeleft, rank = GetCastTimer(casts[slotCasterGuid])
        if duration then caster = "other" end
      end

      -- 回退：指定施法者没有数据时接受任意仍在生效的施法
      if not duration and casts then
        for _, data in pairs(casts) do
          duration, timeleft, rank = GetCastTimer(data)
          if duration then
            caster = "other"
            break
          end
        end
      end
      timeleft = duration and timeleft or -1
    end

    return effect, rank, slotData.texture, slotData.stacks, slotData.dtype,
      duration, timeleft, caster
  end

  -- ==========================================================================
  -- 回退：非 Nampower 的遗留系统
  -- ==========================================================================

  local effect, texture, stacks, dtype = ScanUnitDebuff(unit, displaySlot)
  local unitname = UnitName(unit)

  if effect and libdebuff.objects[unitname] then
    for _, effects in pairs(libdebuff.objects[unitname]) do
      local entry = effects[effect]
      if entry and entry.duration then
        local timeleft = entry.start and
          entry.start + entry.duration - GetTime()

        if timeleft and timeleft > 0 then
          return effect, entry.rank, texture, stacks, dtype,
            entry.duration, timeleft, entry.caster
        end
      end
    end
  end

  return effect, nil, texture, stacks, dtype, nil, -1, nil
end

-- ============================================================================
-- API：UnitOwnDebuff（只返回我们自己的减益）
-- ============================================================================

-- 预定义排序函数，避免每次调用创建闭包
local _ownDebuffSortFunc = function(a, b)
  if a.data.startTime == b.data.startTime then
    return a.spellName < b.spellName
  end
  return a.data.startTime < b.data.startTime
end

function libdebuff:UnitOwnDebuff(unit, id)
  if hasNampower and GetUnitGUID then
    local guid = GetUnitGUID(unit)
    if guid and ownDebuffs[guid] then
      local sortedDebuffs = {}
      local count = 0
      local now = GetTime()

      for spellName, data in pairs(ownDebuffs[guid]) do
        local timeleft = TimeLeft(data, now)
        if timeleft > -1 then  -- 宽限期
          count = count + 1
          sortedDebuffs[count] = {
            spellName = spellName,
            data = data,
            timeleft = timeleft
          }
        end
      end

      -- 按 startTime 排序（最旧的在最前 = 最小显示槽位）
      -- startTime 相同时（如 Carnage 刷新后）用法术名保证稳定排序
      table.sort(sortedDebuffs, _ownDebuffSortFunc)

      local entry = sortedDebuffs[id]
      if entry then
        return entry.spellName, entry.data.rank,
          entry.data.texture or "Interface\\Icons\\INV_Misc_QuestionMark",
          entry.data.stacks or 1, GetDispelType(entry.data.spellId),
          entry.data.duration, entry.timeleft > 0 and entry.timeleft or 0,
          "player"
      end
    end
    return nil
  end

  -- 回退：遍历所有减益并过滤
  for k in pairs(cache) do cache[k] = nil end
  local count = 1
  for i=1,16 do
    local effect, rank, texture, stacks, dtype, duration, timeleft, caster = libdebuff:UnitDebuff(unit, i)
    if effect and not cache[effect] and caster and caster == "player" then
      cache[effect] = true
      if count == id then
        return effect, rank, texture, stacks, dtype, duration, timeleft, caster
      else
        count = count + 1
      end
    end
  end
end

-- ============================================================================
-- API：GetBestAuraCast（供 libpredict 追踪 HoT）
-- ============================================================================

function libdebuff:GetBestAuraCast(guid, spellName)
  if not guid or not spellName then return nil end

  -- 优先我们自己的施法
  if ownDebuffs[guid] and ownDebuffs[guid][spellName] then
    local data = ownDebuffs[guid][spellName]
    local timeleft = TimeLeft(data)
    if timeleft > 0 then
      return data.startTime, data.duration, timeleft, data.rank, GetPlayerGUID()
    end
  end

  -- 其次是任意施法者里剩余时间最长的
  if allAuraCasts[guid] and allAuraCasts[guid][spellName] then
    local bestData, bestCaster, bestTimeleft = nil, nil, 0

    for casterGuid, data in pairs(allAuraCasts[guid][spellName]) do
      local timeleft = TimeLeft(data)
      if timeleft > bestTimeleft then
        bestTimeleft = timeleft
        bestData = data
        bestCaster = casterGuid
      end
    end

    if bestData and bestTimeleft > 0 then
      return bestData.startTime, bestData.duration, bestTimeleft, bestData.rank, bestCaster
    end
  end

  return nil
end

-- ============================================================================
-- API：GetEnhancedDebuffs（供外部模块使用）
-- ============================================================================

function libdebuff:GetEnhancedDebuffs(targetGUID)
  if not targetGUID then return nil end
  local result = {}

  if ownDebuffs[targetGUID] then
    local myGuid = GetPlayerGUID()
    for spellName, data in pairs(ownDebuffs[targetGUID]) do
      if TimeLeft(data) > 0 then
        result[spellName] = result[spellName] or {}
        result[spellName][myGuid] = {
          startTime = data.startTime,
          duration = data.duration,
          texture = data.texture,
          rank = data.rank
        }
      end
    end
  end

  return result
end

-- ============================================================================
-- Nampower 事件处理
-- ============================================================================

if hasNampower then
  -- Carnage 天赋等级
  local carnageRank = 0
  local function UpdateCarnageRank()
    if class ~= "DRUID" then return end
    carnageRank = GetTalentRank(2, 17)
  end

  -- Carnage 触发后被刷新的德鲁伊流血效果。键必须是客户端本地化法术名，
  -- 因为 ownDebuffs／allAuraCasts 就是用 GetSpellRecField(spellId, "name")
  -- 的结果做键的；触发判定同样只认本地化的“凶猛撕咬”。
  local carnageRefreshSpells = { "撕扯", "斜掠" }

  -- 常驻的 Carnage 检查框（而不是每次凶猛撕咬都 CreateFrame）
  local carnageState = nil  -- {targetGuid, checkTime}
  local carnageCheckFrame = CreateFrame("Frame")
  carnageCheckFrame:Hide()
  carnageCheckFrame:SetScript("OnUpdate", function()
    if not carnageState then
      this:Hide()
      return
    end
    if GetTime() < carnageState.checkTime then return end

    -- 撕咬后立刻拿到连击点，说明 Carnage 触发了
    if (GetComboPoints() or 0) > 0 then
      local guid = carnageState.targetGuid
      local refreshTime = GetTime()
      local myGuid = GetPlayerGUID()

      for _, spellName in ipairs(carnageRefreshSpells) do
        local own = ownDebuffs[guid] and ownDebuffs[guid][spellName]
        if own then
          own.startTime = refreshTime
          if debugStats.enabled then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[CARNAGE]|r " .. spellName .. " refreshed (CP detected)")
          end
        end

        local casts = allAuraCasts[guid] and allAuraCasts[guid][spellName]
        if casts and casts[myGuid] then
          casts[myGuid].startTime = refreshTime
        end
      end

      if pfTarget and GetUnitGUID("target") == guid then
        pfTarget.update_aura = true
      end

      if pfUI.nameplates and pfUI.nameplates.OnAuraUpdate then
        pfUI.nameplates:OnAuraUpdate(guid)
      end
    end

    carnageState = nil
    this:Hide()
  end)

  local function NotifyAuraConsumers(guid)
    if pfUI.nameplates and pfUI.nameplates.OnAuraUpdate then
      pfUI.nameplates:OnAuraUpdate(guid)
    end
    -- 原始 GUID 可能收不到 UNIT_AURA，逐个刷新匹配的单位框体
    libdebuff:NotifyUnitFrameAuras(guid)
  end

  -- 事件处理表：键为归一化后的光环事件名或原始事件名。
  -- 处理函数返回 false 表示提前结束，与原实现一样跳过本次周期清理。
  local eventHandlers = {}

  eventHandlers["PLAYER_LOGOUT"] = function()
    this:UnregisterAllEvents()
    this:SetScript("OnEvent", nil)
    return false
  end

  eventHandlers["PLAYER_ENTERING_WORLD"] = function()
    GetPlayerGUID()
    UpdateCarnageRank()
  end

  eventHandlers["PLAYER_TALENT_UPDATE"] = UpdateCarnageRank

  eventHandlers["UNIT_HEALTH"] = function()
    local guid = arg1
    if guid and UnitIsDead and UnitIsDead(guid) then
      CleanupUnit(guid)
    end
    FireHooks(pfUI.libdebuff_unit_health_hooks, arg1)
  end

  eventHandlers["UNIT_DIED"] = function()
    FireHooks(pfUI.libdebuff_unit_died_hooks, arg1)
  end

  eventHandlers["SPELL_FAILED_OTHER"] = function()
    local casterGuid = arg1
    if casterGuid and pfUI.libdebuff_casts[casterGuid] then
      pfUI.libdebuff_casts[casterGuid] = nil
    end
    FireHooks(pfUI.libdebuff_spell_failed_other_hooks, casterGuid, arg2)
  end

  eventHandlers["PLAYER_TARGET_CHANGED"] = function()
    if not GetUnitGUID then return false end
    local targetGuid = GetUnitGUID("target")

    if targetGuid and targetGuid ~= "" then
      -- 取消／重新选中同一目标后，旧的槽位映射不再可信
      slotMapCache[targetGuid] = nil
      CleanupExpiredTimers(targetGuid)
    end
    FireHooks(pfUI.libdebuff_player_target_changed_hooks)
  end

  local function HandleSpellStart(eventName)
    local itemId, spellId, casterGuid, castTime = arg1, arg2, arg3, arg6

    if not casterGuid or not spellId then return false end

    local spellName = SpellNameByRec(spellId)
    local icon = libdebuff:GetSpellIcon(spellId)

    -- 物品触发的施法使用物品图标，并单独缓存
    -- （SPELL_GO 会清掉 libdebuff_casts，物品图标需要留存）
    if itemId and itemId > 0 and GetItemStatsField and GetItemIconTexture then
      local displayInfoId = GetItemStatsField(itemId, "displayInfoID")
      local itemIcon = displayInfoId and GetItemIconTexture(displayInfoId)
      if itemIcon then icon = NormalizeIconPath(itemIcon) end
      pfUI.libdebuff_item_icons[casterGuid] = {
        icon = icon,
        name = GetItemStatsField(itemId, "displayName")
      }
    else
      pfUI.libdebuff_item_icons[casterGuid] = nil
    end

    local startTime = GetTime()
    pfUI.libdebuff_casts[casterGuid] = {
      spellID = spellId,
      itemID = itemId and itemId > 0 and itemId or nil,
      spellName = spellName,
      icon = icon,
      startTime = startTime,
      duration = castTime and castTime / 1000 or 0,
      endTime = castTime and (startTime + castTime / 1000) or nil,
      event = "START"
    }

    if eventName == "SPELL_START_SELF" then
      FireHooks(pfUI.libdebuff_spell_start_self_hooks,
        spellId, casterGuid, arg4, castTime)
    else
      FireHooks(pfUI.libdebuff_spell_start_other_hooks,
        spellId, casterGuid, arg4, castTime)
    end
  end

  eventHandlers["SPELL_START_SELF"] = HandleSpellStart
  eventHandlers["SPELL_START_OTHER"] = HandleSpellStart

  local function HandleSpellGo(eventName)
    local spellId, casterGuid, targetGuid = arg2, arg3, arg4
    local numHit, numMissed = arg6 or 0, arg7 or 0
    local isSelf = eventName == "SPELL_GO_SELF"

    -- 只有与当前施法匹配的 SPELL_GO 才清空施法条
    -- （霜甲之类的被动触发也会发 SPELL_GO，但不应清空施法条）
    local cast = casterGuid and pfUI.libdebuff_casts[casterGuid]
    if cast and cast.spellID == spellId then
      pfUI.libdebuff_casts[casterGuid] = nil
    end

    -- 命中判定之前先触发 SPELL_GO_SELF 回调
    -- （挥砍计时器需要看到包括未命中在内的所有施法，用于重置挥砍）
    if isSelf then
      FireHooks(pfUI.libdebuff_spell_go_hooks,
        spellId, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    end
    if numMissed > 0 or numHit == 0 then return false end

    local spellName, spellRankString
    if SpellInfo then
      spellName, spellRankString = SpellInfo(spellId)
    elseif GetSpellRecField then
      spellName = GetSpellRecField(spellId, "name")
    end
    if not spellName then return false end

    local castRank = 0
    if spellRankString and spellRankString ~= "" then
      castRank = tonumber((string.gsub(spellRankString, "Rank ", ""))) or 0
    end

    -- 存入 pendingCasts 供 DEBUFF_ADDED 关联
    if targetGuid then
      pendingCasts[targetGuid] = pendingCasts[targetGuid] or {}
      pendingCasts[targetGuid][spellName] = {
        casterGuid = casterGuid,
        rank = castRank,
        time = GetTime()
      }
    end

    local myGuid = GetPlayerGUID()
    if casterGuid == myGuid then
      lastCastRanks[spellName] = {
        rank = castRank,
        time = GetTime()
      }
    end

    -- CARNAGE 天赋：凶猛撕咬会刷新 Rip 与 Rake
    -- 触发时撕咬后会立刻多给 1 点连击点，延迟 50ms 检查即可判断
    if class == "DRUID" and carnageRank >= 1 and spellName == "凶猛撕咬" and casterGuid == myGuid then
      if targetGuid and numHit > 0 then
        carnageState = {
          targetGuid = targetGuid,
          checkTime = GetTime() + 0.05
        }
        carnageCheckFrame:Show()
      end
    end

    -- SPELL_GO_SELF 的回调已在命中判定之前触发过，这里只处理他人施法
    if not isSelf then
      FireHooks(pfUI.libdebuff_spell_go_other_hooks,
        spellId, casterGuid, targetGuid)
    end
  end

  eventHandlers["SPELL_GO_SELF"] = HandleSpellGo
  eventHandlers["SPELL_GO_OTHER"] = HandleSpellGo

  eventHandlers["SPELL_CAST_EVENT"] = function()
    -- 在连击点被客户端消耗之前抓取
    -- 这个事件在你施放法术时触发（服务器处理之前）
    local success, spellId, castType, targetGuid = arg1, arg2, arg3, arg4

    if success ~= 1 or not spellId then return false end

    local spellName = SpellNameByRec(spellId)
    if not spellName and SpellInfo then
      spellName = SpellInfo(spellId)
    end

    -- 为 libpredict 记录待处理施法信息（治疗预判目标追踪）
    -- Nampower 队列施法时 CastSpellByName hook 在 current_cast 已设置的情况下
    -- 触发且无法更新 spell_queue，而 SPELL_CAST_EVENT 恰好早于 SPELLCAST_START。
    local pendingCast = pfUI.libpredict_pending_cast
    if spellName and IsTrackableGuid(targetGuid) then
      pendingCast.spellId = spellId
      pendingCast.spellName = spellName
      pendingCast.targetGuid = targetGuid
      pendingCast.time = GetTime()
    else
      -- 没有明确目标：清空待处理信息，让 libpredict 回退到 spell_queue
      pendingCast.spellId = nil
      pendingCast.spellName = nil
      pendingCast.targetGuid = nil
      pendingCast.time = nil
    end

    -- 只为连击点技能抓取连击点
    if spellName and IsComboPointAbility(spellName) then
      capturedCP = GetComboPoints() or 0
    end

    FireHooks(pfUI.libdebuff_spell_cast_hooks,
      success, spellId, castType, targetGuid)
  end

  -- 按连击点数解析时长
  local function GetComboPointDuration(spellName, rankNum, isOurs)
    local base, perCP = GetComboPointData(spellName)

    if isOurs then
      -- 自己施放：使用 SPELL_CAST_EVENT 抓到的连击点（如果有）
      local duration
      if base and perCP then
        duration = base + (capturedCP or 0) * perCP
      else
        duration = libdebuff:GetDuration(spellName, rankNum)
      end
      capturedCP = nil  -- 已消耗
      return duration
    end

    -- 其他玩家的连击点未知，只有固定时长可用（如破甲的 30 秒）
    if perCP == 0 and base then return base end
    return 0
  end

  local function HandleAuraCast(eventName)
    local spellId, casterGuid, targetGuid = arg1, arg2, arg3
    local durationMs = arg8

    if not spellId then return false end
    if not IsTrackableGuid(targetGuid) then return false end

    local spellName = (SpellInfo and SpellInfo(spellId)) or
      SpellNameByRecField(spellId)
    if not spellName then return false end

    -- 去重：Nampower 对多效果法术会连发多个 AURA_CAST
    -- （例如精灵之火有 3 个效果）
    recentCasts[targetGuid] = recentCasts[targetGuid] or {}
    recentCasts[targetGuid][spellName] = recentCasts[targetGuid][spellName] or {}

    local now = GetTime()
    local lastCastTime = recentCasts[targetGuid][spellName][casterGuid]
    if lastCastTime and (now - lastCastTime) < AURA_CAST_DEDUPE_WINDOW then
      return false
    end
    recentCasts[targetGuid][spellName][casterGuid] = now

    -- 从 spellId 取等级
    local rankNum = 0
    local rankString = GetSpellRecField(spellId, "rank")
    if rankString and rankString ~= "" then
      rankNum = tonumber((string.gsub(rankString, "Rank ", ""))) or 0
    end

    local myGuid = GetPlayerGUID()
    local isOurs = (myGuid and casterGuid == myGuid)
    local duration = durationMs and (durationMs / 1000) or 0

    libdebuff:UpdateBuffOwnershipFromCast(
      targetGuid, spellId, casterGuid, isOurs
    )

    if debugStats.enabled and isOurs then
      debugStats.aura_cast = debugStats.aura_cast + 1
    end

    if IsComboPointAbility(spellName) then
      duration = GetComboPointDuration(spellName, rankNum, isOurs)
    elseif duration == 0 then
      -- 非连击点技能：AURA_CAST 返回 0 时用法术数据库
      duration = libdebuff:GetDuration(spellName, rankNum) or 0
    end

    allAuraCasts[targetGuid] = allAuraCasts[targetGuid] or {}
    local spellCasts = allAuraCasts[targetGuid][spellName] or {}
    allAuraCasts[targetGuid][spellName] = spellCasts

    -- 降级保护：必须在清理其他施法者之前检查！
    if selfOverwriteDebuffs[spellName] then
      -- 独占型减益要检查所有已有施法者
      for otherCaster, existingData in pairs(spellCasts) do
        local blockedFor = HigherRankTimeLeft(existingData, rankNum)
        if blockedFor then
          if debugStats.enabled then
            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffff0000[DOWNRANK BLOCKED]|r %s: Rank %d from %s cannot overwrite Rank %d from %s (%.1fs left)",
              spellName, rankNum, DebugGuid(casterGuid), existingData.rank, DebugGuid(otherCaster), blockedFor))
          end
          return false
        end
      end
    else
      -- 非独占型：只检查同一施法者
      local blockedFor = HigherRankTimeLeft(spellCasts[casterGuid], rankNum)
      if blockedFor then
        if debugStats.enabled and isOurs then
          DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffff0000[DOWNRANK BLOCKED]|r %s: Rank %d cannot overwrite Rank %d (%.1fs left)",
            spellName, rankNum, spellCasts[casterGuid].rank, blockedFor))
        end
        return false
      end
    end

    -- 独占型减益：清掉其他施法者
    if selfOverwriteDebuffs[spellName] then
      local n = 0
      for otherCaster in pairs(spellCasts) do
        if otherCaster ~= casterGuid then
          n = n + 1
          _cleanupBuf1[n] = otherCaster
        end
      end
      for i = 1, n do
        spellCasts[_cleanupBuf1[i]] = nil
        _cleanupBuf1[i] = nil
      end

      -- 我们的减益被别人覆盖时从 ownDebuffs 移除
      if not isOurs and ownDebuffs[targetGuid] and ownDebuffs[targetGuid][spellName] then
        ownDebuffs[targetGuid][spellName] = nil
      end
    end

    -- 互相覆盖的变体（精灵之火 <-> 精灵之火（野性））
    local otherVariant = debuffOverwritePairs[spellName]
    if otherVariant and allAuraCasts[targetGuid][otherVariant] then
      allAuraCasts[targetGuid][otherVariant][casterGuid] = nil
    end

    spellCasts[casterGuid] = {
      startTime = now,
      duration = duration,
      rank = rankNum
    }

    -- 独占型减益刷新时同步 slotOwnership
    -- （刷新不会触发 DEBUFF_ADDED，必须在这里更新！）
    if selfOverwriteDebuffs[spellName] and slotOwnership[targetGuid] then
      for auraSlot, ownership in pairs(slotOwnership[targetGuid]) do
        if ownership.spellName == spellName then
          ownership.casterGuid = casterGuid
          ownership.isOurs = isOurs

          if IsDebugTarget(targetGuid) then
            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00ff00[SLOT UPDATED]|r aura=%d %s newCaster=%s isOurs=%s",
              auraSlot, spellName, DebugGuid(casterGuid), tostring(isOurs)))
          end
          break
        end
      end
    end

    if IsDebugTarget(targetGuid) then
      DEFAULT_CHAT_FRAME:AddMessage(string.format("%s |cff00ffff[AURA_CAST]|r %s target=%s caster=%s isOurs=%s dur=%.1fs",
        GetDebugTimestamp(), spellName, DebugGuid(targetGuid), DebugGuid(casterGuid), tostring(isOurs), duration))
    end

    NotifyAuraConsumers(targetGuid)

    -- 只有我们自己的减益才记入 ownDebuffs
    if not isOurs then return false end
    if targetGuid == myGuid then return false end  -- 跳过自身增益

    ownDebuffs[targetGuid] = ownDebuffs[targetGuid] or {}
    local data = ownDebuffs[targetGuid][spellName] or {}
    ownDebuffs[targetGuid][spellName] = data

    -- 降级保护：已有减益仍在生效且等级更高时拒绝更新
    local blockedFor = HigherRankTimeLeft(data, rankNum)
    if blockedFor then
      if debugStats.enabled then
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffff0000[DOWNRANK BLOCKED]|r %s: Rank %d cannot overwrite Rank %d (%.1fs left)",
          spellName, rankNum, data.rank, blockedFor))
      end
      return false
    end

    data.startTime = now
    data.duration = duration
    data.texture = libdebuff:GetSpellIcon(spellId)
    data.rank = rankNum
    data.spellId = spellId
    data.stacks = 1   -- 初始设为 1，稍后由 DEBUFF_ADDED 更新

    if otherVariant and ownDebuffs[targetGuid][otherVariant] then
      ownDebuffs[targetGuid][otherVariant] = nil
    end

    -- 供 Cleveroids API 使用
    objectsByGuid[targetGuid] = objectsByGuid[targetGuid] or {}
    objectsByGuid[targetGuid][spellId] = {
      start = now,
      duration = duration,
      caster = "player",
      stacks = 1
    }

    if eventName == "AURA_CAST_ON_SELF" then
      FireHooks(pfUI.libdebuff_aura_cast_on_self_hooks,
        spellId, casterGuid, targetGuid)
    else
      FireHooks(pfUI.libdebuff_aura_cast_on_other_hooks,
        spellId, casterGuid, targetGuid)
    end
  end

  eventHandlers["AURA_CAST_ON_SELF"] = HandleAuraCast
  eventHandlers["AURA_CAST_ON_OTHER"] = HandleAuraCast

  eventHandlers["DEBUFF_ADDED_OTHER"] = function()
    local guid, displaySlot, spellId, stacks = arg1, arg2, arg3, arg4

    -- Nampower 2.29+：arg6 是 0 起的真实槽位
    local auraSlot = arg6 and (arg6 + 1) or nil
    if auraSlot and auraSlot <= 32 then displaySlot = 16 + auraSlot end

    slotMapCache[guid] = nil

    local spellName = SpellNameByRecField(spellId)
    if not spellName then return false end

    if debugStats.enabled then
      debugStats.debuff_added = debugStats.debuff_added + 1
    end

    if UnitIsDead and UnitIsDead(guid) then
      CleanupUnit(guid)
      return false
    end

    -- 事件没带真实槽位时先查槽位映射，再退回显示槽位推算
    if not auraSlot then
      local slotMap = GetDebuffSlotMap(guid)
      local slotData = slotMap and slotMap[displaySlot]
      auraSlot = slotData and slotData.auraSlot or 32 + displaySlot
    end

    -- 尝试从 pendingCasts 获取施法者
    local casterGuid = nil
    local pending = pendingCasts[guid] and pendingCasts[guid][spellName]
    if pending and GetTime() - pending.time < 0.5 then
      casterGuid = pending.casterGuid
      pendingCasts[guid][spellName] = nil
    end

    -- 从 allAuraCasts 回退获取最近施法者
    if not casterGuid then
      casterGuid = GetLatestCaster(
        allAuraCasts[guid] and allAuraCasts[guid][spellName]
      )
    end

    local myGuid = GetPlayerGUID()
    local isOurs = (myGuid and casterGuid == myGuid)

    -- 从 ownDebuffs 回退（刚施放不久）
    if not isOurs and not casterGuid then
      local own = ownDebuffs[guid] and ownDebuffs[guid][spellName]
      if own and GetTime() - own.startTime < 0.5 then
        isOurs = true
        casterGuid = myGuid
      end
    end

    -- 猎人陷阱没有 AURA_CAST 事件，只能视为玩家自己施加
    if not casterGuid and trapDebuffs[spellName] then
      casterGuid = myGuid
      isOurs = true
      if debugStats.enabled then
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff33ff99[TRAP FALLBACK]|r 将 %s 视为玩家自己的 debuff", spellName))
      end
    end

    -- 存储槽位所有权
    slotOwnership[guid] = slotOwnership[guid] or {}
    slotOwnership[guid][auraSlot] = {
      casterGuid = casterGuid,
      spellName = spellName,
      spellId = spellId,
      isOurs = isOurs
    }

    displayToAura[guid] = displayToAura[guid] or {}
    displayToAura[guid][displaySlot] = auraSlot

    if IsDebugTarget(guid) then
      DEFAULT_CHAT_FRAME:AddMessage(string.format("%s |cff00ff00[DEBUFF_ADDED]|r display=%d aura=%d %s caster=%s isOurs=%s",
        GetDebugTimestamp(), displaySlot, auraSlot, spellName, DebugGuid(casterGuid), tostring(isOurs)))
    end

    -- 更新 ownDebuffs（如果是我们的 debuff）
    if isOurs and casterGuid and casterGuid == myGuid then
      local auraData = allAuraCasts[guid] and allAuraCasts[guid][spellName] and
        allAuraCasts[guid][spellName][casterGuid]
      local startTime, duration, rank

      if auraData then
        startTime = auraData.startTime
        duration = auraData.duration
        rank = auraData.rank or 0
      else
        -- 没有 AURA_CAST 数据（如陷阱 debuff），使用当前时间和默认持续时间
        startTime = GetTime()
        duration = libdebuff:GetDuration(spellName, 0) or 0
        rank = 0
        if debugStats.enabled then
          DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffffaa00[TRAP DURATION]|r %s 使用默认持续时间 %.1fs", spellName, duration))
        end
      end

      ownDebuffs[guid] = ownDebuffs[guid] or {}
      ownDebuffs[guid][spellName] = {
        startTime = startTime,
        duration = duration,
        texture = libdebuff:GetSpellIcon(spellId),
        rank = rank,
        spellId = spellId,
        stacks = stacks,
      }

      if IsDebugTarget(guid) then
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffff00ff[OWNDEBUFF SYNC]|r %s from DEBUFF_ADDED (dur=%.1f)", spellName, duration))
      end
    end

    CleanupExpiredTimers(guid)
    NotifyAuraConsumers(guid)
    FireHooks(pfUI.libdebuff_debuff_added_other_hooks, arg1, arg2, arg3, arg4)
  end

  eventHandlers["DEBUFF_REMOVED_OTHER"] = function()
    local guid, displaySlot, spellId = arg1, arg2, arg3

    -- Nampower 2.29+：arg6 是 0 起的真实槽位（32-47），转成 1 起的 Lua 索引
    local auraSlot = arg6 and (arg6 + 1) or nil
    if auraSlot and auraSlot <= 32 then displaySlot = 16 + auraSlot end

    slotMapCache[guid] = nil

    local spellName = SpellNameByRecField(spellId) or "?"

    if debugStats.enabled then
      debugStats.debuff_removed = debugStats.debuff_removed + 1
      if IsCurrentTarget(guid) then
        DEFAULT_CHAT_FRAME:AddMessage(string.format("%s |cffff9900[DEBUFF_REMOVED]|r display=%d aura=%d (0based=%d) %s",
          GetDebugTimestamp(), displaySlot, auraSlot or -1, arg6 or -1, spellName))
      end
    end

    if UnitIsDead and UnitIsDead(guid) then
      CleanupUnit(guid)
      return false
    end

    -- 事件没带真实槽位时回退 displayToAura 映射
    local foundAuraSlot = auraSlot or
      (displayToAura[guid] and displayToAura[guid][displaySlot])

    local wasOurs = false
    local removedCasterGuid = nil

    if foundAuraSlot then
      local ownership = slotOwnership[guid] and slotOwnership[guid][foundAuraSlot]
      if ownership then
        wasOurs = ownership.isOurs
        removedCasterGuid = ownership.casterGuid
      end

      if slotOwnership[guid] then
        slotOwnership[guid][foundAuraSlot] = nil
      end
      if displayToAura[guid] then
        displayToAura[guid][displaySlot] = nil
      end

      if IsDebugTarget(guid) then
        DEFAULT_CHAT_FRAME:AddMessage(string.format("%s |cffff9900[SLOT CLEARED]|r aura=%d [arg6] %s wasOurs=%s caster=%s",
          GetDebugTimestamp(), foundAuraSlot, spellName, tostring(wasOurs), DebugGuid(removedCasterGuid)))
      end
    end

    -- 只有不是刚刚续上的才真正删除
    local own = wasOurs and ownDebuffs[guid] and ownDebuffs[guid][spellName]
    if own and GetTime() - own.startTime > 1 then
      ownDebuffs[guid][spellName] = nil
    end

    local casts = removedCasterGuid and allAuraCasts[guid] and
      allAuraCasts[guid][spellName]
    local auraData = casts and casts[removedCasterGuid]
    if auraData and GetTime() - auraData.startTime > 1 then
      casts[removedCasterGuid] = nil
    end

    CleanupExpiredTimers(guid)
    NotifyAuraConsumers(guid)
    FireHooks(pfUI.libdebuff_debuff_removed_other_hooks, arg1, arg2, arg3, arg4)
  end

  local function HandleBuffOwnership(eventName)
    libdebuff:HandleBuffOwnershipEvent(eventName, arg1, arg3, arg6, arg7)
    libdebuff:NotifyUnitFrameAuras(arg1)
  end

  eventHandlers["BUFF_ADDED_OTHER"] = HandleBuffOwnership
  eventHandlers["BUFF_REMOVED_OTHER"] = HandleBuffOwnership

  local frame = CreateFrame("Frame")
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("PLAYER_TALENT_UPDATE")
  frame:RegisterEvent("PLAYER_LOGOUT")
  frame:RegisterEvent("SPELL_START_SELF")
  frame:RegisterEvent("SPELL_START_OTHER")
  frame:RegisterEvent("SPELL_GO_SELF")
  frame:RegisterEvent("SPELL_GO_OTHER")
  frame:RegisterEvent("SPELL_FAILED_OTHER")
  frame:RegisterEvent("UNIT_DIED")
  frame:RegisterEvent("SPELL_CAST_EVENT")
  frame:RegisterEvent("AURA_CAST_ON_SELF")
  frame:RegisterEvent("AURA_CAST_ON_OTHER")
  frame:RegisterEvent("BUFF_ADDED_OTHER")
  frame:RegisterEvent("BUFF_REMOVED_OTHER")
  frame:RegisterEvent("DEBUFF_ADDED_OTHER")
  frame:RegisterEvent("DEBUFF_REMOVED_OTHER")
  frame:RegisterEvent("PLAYER_TARGET_CHANGED")
  frame:RegisterEvent("UNIT_HEALTH")

  frame:SetScript("OnEvent", function()
    -- 光环事件名按真实标志位归一化后再分发
    local auraEvent = libdebuff:NormalizeOtherAuraEvent(
      event, arg1, arg3, arg6
    )
    if auraEvent then
      libdebuff:DebugNampowerAuraEvent(
        event, arg1, arg2, arg3, arg4, arg5, arg6, arg7
      )
    end

    local eventName = auraEvent or event
    local handler = eventHandlers[eventName]
    if handler and handler(eventName) == false then return end

    -- 周期清理
    CleanupOutOfRangeUnits()
  end)

  local buffFrame = CreateFrame("Frame")
  buffFrame:RegisterEvent("BUFF_ADDED_SELF")
  buffFrame:RegisterEvent("BUFF_REMOVED_SELF")
  buffFrame:SetScript("OnEvent", function()
    libdebuff:DebugNampowerAuraEvent(
      event, arg1, arg2, arg3, arg4, arg5, arg6, arg7
    )
    HandleBuffOwnership(event)
  end)

  -- Cleveroids API
  if CleveRoids then
    CleveRoids.libdebuff = libdebuff
    libdebuff.objects = objectsByGuid
  end
end

-- add libdebuff to pfUI API
pfUI.api.libdebuff = libdebuff

-- Expose debugStats for external access
libdebuff.debugStats = debugStats

-- ============================================================================
-- 调试命令
-- ============================================================================

_G.SLASH_LIBDEBUGSTATS1 = "/libdebugstats"
_G.SlashCmdList["LIBDEBUGSTATS"] = function(msg)
  msg = string.lower(msg or "")

  if msg == "start" or msg == "verbose" then
    debugStats.enabled = msg == "verbose"
    debugStats.nampower_aura_logging = true
    debugStats.trackAllUnits = false
    ResetDebugCounters()
    DEFAULT_CHAT_FRAME:AddMessage(msg == "verbose" and
      "|cff00ff00[libdebuff]|r Verbose debug tracking STARTED" or
      "|cff00ff00[libdebuff]|r Current-target Aura log STARTED")

  elseif msg == "stop" then
    debugStats.enabled = false
    debugStats.nampower_aura_logging = false
    DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[libdebuff]|r Debug tracking STOPPED")

  elseif msg == "stats" then
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff=== LIBDEBUFF STATS (GetUnitField Edition) ===|r")
    DEFAULT_CHAT_FRAME:AddMessage(string.format("AURA_CAST events: %d", debugStats.aura_cast))
    DEFAULT_CHAT_FRAME:AddMessage(string.format(
      "Nampower target aura events: %d",
      debugStats.nampower_aura_events or 0
    ))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("DEBUFF_ADDED events: %d", debugStats.debuff_added))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("DEBUFF_REMOVED events: %d", debugStats.debuff_removed))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("GetUnitField calls: %d", debugStats.getunitfield_calls))
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00No manual slot shifting needed!|r")

  elseif msg == "target" then
    local guid = GetUnitGUID("target")
    if not guid then
      DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[libdebuff]|r No target!")
      return
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff=== TARGET DEBUFF STATE ===|r")
    DEFAULT_CHAT_FRAME:AddMessage(string.format("GUID: %s", tostring(guid)))

    local slotMap = GetDebuffSlotMap(guid)
    if slotMap then
      DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00GetUnitField Slots:|r")
      for displaySlot, data in pairs(slotMap) do
        local casterGuid, isOurs = GetSlotCaster(guid, data.auraSlot, data.spellName)
        DEFAULT_CHAT_FRAME:AddMessage(string.format("  Display %d (aura %d): %s [caster=%s, ours=%s]",
          displaySlot, data.auraSlot, data.spellName, DebugGuid(casterGuid), tostring(isOurs)))
      end
    else
      DEFAULT_CHAT_FRAME:AddMessage("|cffff9900No debuffs via GetUnitField|r")
    end

    if ownDebuffs[guid] then
      DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00ownDebuffs:|r")
      for spell, data in pairs(ownDebuffs[guid]) do
        DEFAULT_CHAT_FRAME:AddMessage(string.format("  %s: dur=%.1f left=%.1f", spell, data.duration, TimeLeft(data)))
      end
    end

  else
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[libdebuff] GetUnitField Edition - Commands:|r")
    DEFAULT_CHAT_FRAME:AddMessage("  /libdebugstats start - Log current-target Aura additions")
    DEFAULT_CHAT_FRAME:AddMessage("  /libdebugstats verbose - Include legacy debug logs")
    DEFAULT_CHAT_FRAME:AddMessage("  /libdebugstats stop  - Stop debug tracking")
    DEFAULT_CHAT_FRAME:AddMessage("  /libdebugstats stats - Show statistics")
    DEFAULT_CHAT_FRAME:AddMessage("  /libdebugstats target - Show target debuff state")
  end
end

_G.SLASH_MEMCHECK1 = "/memcheck"
_G.SlashCmdList["MEMCHECK"] = function()
  local function countTable(t)
    local count = 0
    if not t then return 0 end
    for _ in pairs(t) do count = count + 1 end
    return count
  end

  local function countNestedEntries(t)
    local total = 0
    if not t then return 0 end
    for _, nested in pairs(t) do
      if type(nested) == "table" then
        total = total + countTable(nested)
      end
    end
    return total
  end

  DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff========== LIBDEBUFF MEMORY (GetUnitField Edition) ==========|r")
  DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00ff00Primary Tables:|r"))
  DEFAULT_CHAT_FRAME:AddMessage(string.format("  ownDebuffs: %d GUIDs, %d debuffs", countTable(ownDebuffs), countNestedEntries(ownDebuffs)))
  DEFAULT_CHAT_FRAME:AddMessage(string.format("  slotOwnership: %d GUIDs, %d slots", countTable(slotOwnership), countNestedEntries(slotOwnership)))
  DEFAULT_CHAT_FRAME:AddMessage(string.format("  allAuraCasts: %d GUIDs", countTable(allAuraCasts)))
  DEFAULT_CHAT_FRAME:AddMessage(string.format("  pendingCasts: %d GUIDs", countTable(pendingCasts)))
  DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00No ownSlots/allSlots (eliminated by GetUnitField approach!)|r")
  DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff============================================================|r")
end

DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[libdebuff]|r GetUnitField Edition loaded!")
