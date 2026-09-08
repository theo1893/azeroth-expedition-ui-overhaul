---------------------------------------------------------------
-- DoitePlayerAuras.lua
-- 玩家光环缓存 + 查找辅助函数（增益/减益，槽位 + 层数计数）
-- 请尊重许可说明：使用前请询问
-- WoW 1.12 | Lua 5.0
---------------------------------------------------------------
local MAX_BUFF_SLOTS = 32
local MAX_DEBUFF_SLOTS = 16

local DoitePlayerAuras = {
  buffs = {}, -- 槽位 -> { spellId, stacks }
  debuffs = {}, -- 槽位 -> { spellId, stacks }

  spellIdToNameCache = {}, -- spellId -> 法术名称
  spellNameToIdCache = {}, -- 法术名称 -> spellId
  spellNameToMaxStacks = {}, -- 法术名称 -> 最大层数

  activeBuffs = {}, -- 法术名称 -> 槽位
  activeDebuffs = {}, -- 法术名称 -> 槽位
  activeBuffSpellIds = {}, -- spellId -> 槽位
  activeDebuffSpellIds = {}, -- spellId -> 槽位

  cappedBuffsExpirationTime = {}, -- 法术名称 -> 过期时间（秒）
  cappedBuffsStacks = {}, -- 法术名称 -> 层数

  playerBuffIndexCache = {}, -- 法术名称 -> 玩家增益索引（用于 GetPlayerBuffX 函数）

  numActiveBuffs = 0,
  numActiveDebuffs = 0,

  playerGuid = "",

  buffCapEventsEnabled = false,
  debugBuffCap = false -- 设置为 true 以禁用常规事件并强制测试缓冲上限事件
}
-- 初始化所有增益/减益索引
for i = 1, MAX_BUFF_SLOTS do
  table.insert(DoitePlayerAuras.buffs, {
    spellId = nil,
    stacks = nil
  })
end
for i = 1, MAX_DEBUFF_SLOTS do
  table.insert(DoitePlayerAuras.debuffs, {
    spellId = nil,
    stacks = nil
  })
end

_G["DoitePlayerAuras"] = DoitePlayerAuras

local function MarkActive(spellId, activeTable, slot)
  if activeTable == DoitePlayerAuras.activeBuffs then
    DoitePlayerAuras.activeBuffSpellIds[spellId] = slot
  elseif activeTable == DoitePlayerAuras.activeDebuffs then
    DoitePlayerAuras.activeDebuffSpellIds[spellId] = slot
  end

  -- 如果尚未缓存法术名称，则缓存
  if not DoitePlayerAuras.spellIdToNameCache[spellId] then
    local spellName = GetSpellRecField(spellId, "name")
    if spellName then
      DoitePlayerAuras.spellIdToNameCache[spellId] = spellName
      DoitePlayerAuras.spellNameToIdCache[spellName] = spellId
      activeTable[spellName] = slot
    end
  else
    -- 标记为活跃并记录槽位
    local spellName = DoitePlayerAuras.spellIdToNameCache[spellId]
    if spellName then
      activeTable[spellName] = slot
    end
  end
end

local function MarkInactive(spellId, activeTable)
  if activeTable == DoitePlayerAuras.activeBuffs then
    DoitePlayerAuras.activeBuffSpellIds[spellId] = false
  elseif activeTable == DoitePlayerAuras.activeDebuffs then
    DoitePlayerAuras.activeDebuffSpellIds[spellId] = false
  end

  local spellName = DoitePlayerAuras.spellIdToNameCache[spellId]
  if spellName then
    activeTable[spellName] = false
  end
end

local function RemoveCappedBuff(spellName)
  -- 将过期时间设置为 0
  DoitePlayerAuras.cappedBuffsExpirationTime[spellName] = 0
  -- 清除层数
  DoitePlayerAuras.cappedBuffsStacks[spellName] = 0
end

local function UpdateAuras()
  local auraSpellIds = GetUnitField("player", "aura")
  local auraStacks = GetUnitField("player", "auraApplications")

  -- 清除活跃的增益/减益
  DoitePlayerAuras.activeBuffs = {}
  DoitePlayerAuras.activeDebuffs = {}
  DoitePlayerAuras.activeBuffSpellIds = {}
  DoitePlayerAuras.activeDebuffSpellIds = {}

  -- aura 数组在 Lua 中变为 1 索引：1-32 是增益，33-48 是减益
  DoitePlayerAuras.numActiveBuffs = 0
  for i = 1, MAX_BUFF_SLOTS do
    local spellId = auraSpellIds[i]
    if spellId and spellId ~= 0 then
      DoitePlayerAuras.buffs[i].spellId = spellId
      DoitePlayerAuras.buffs[i].stacks = auraStacks[i] + 1 -- 原始增益层数是 0 索引，加 1
      MarkActive(spellId, DoitePlayerAuras.activeBuffs, i)
      DoitePlayerAuras.numActiveBuffs = i
    else
      DoitePlayerAuras.buffs[i].spellId = nil
      DoitePlayerAuras.buffs[i].stacks = nil
    end
  end

  -- 减益：aura 索引 33-48
  DoitePlayerAuras.numActiveDebuffs = 0
  for i = 1, MAX_DEBUFF_SLOTS do
    local spellId = auraSpellIds[MAX_BUFF_SLOTS + i]
    if spellId and spellId ~= 0 then
      DoitePlayerAuras.debuffs[i].spellId = spellId
      DoitePlayerAuras.debuffs[i].stacks = auraStacks[MAX_BUFF_SLOTS + i] + 1 -- 原始减益层数是 0 索引，加 1
      MarkActive(spellId, DoitePlayerAuras.activeDebuffs, i)
      DoitePlayerAuras.numActiveDebuffs = i
    else
      DoitePlayerAuras.debuffs[i].spellId = nil
      DoitePlayerAuras.debuffs[i].stacks = nil
    end
  end
end

function DoitePlayerAuras.IsHiddenByBuffCap(spellName)
  local expirationTime = DoitePlayerAuras.cappedBuffsExpirationTime[spellName]
  if expirationTime and expirationTime > 0 then
    if expirationTime > GetTime() then
      return true
    else
      -- 已过期，移除缓冲上限的增益
      RemoveCappedBuff(spellName)
    end
  end
  return false
end

function DoitePlayerAuras.IsActive(spellName)
  return DoitePlayerAuras.activeBuffs[spellName] or
      DoitePlayerAuras.activeDebuffs[spellName] or
      DoitePlayerAuras.IsHiddenByBuffCap(spellName)
end

function DoitePlayerAuras.HasBuff(spellName)
  return DoitePlayerAuras.activeBuffs[spellName] or
      DoitePlayerAuras.IsHiddenByBuffCap(spellName)
end

function DoitePlayerAuras.HasBuffSpellId(spellId)
  spellId = tonumber(spellId) or 0
  if spellId <= 0 then
    return false
  end
  return DoitePlayerAuras.activeBuffSpellIds[spellId] or false
end

function DoitePlayerAuras.HasDebuff(spellName)
  -- 目前认为玩家不太可能达到减益上限，暂时不处理
  return DoitePlayerAuras.activeDebuffs[spellName] or false
end

function DoitePlayerAuras.HasDebuffSpellId(spellId)
  spellId = tonumber(spellId) or 0
  if spellId <= 0 then
    return false
  end
  return DoitePlayerAuras.activeDebuffSpellIds[spellId] or false
end

function DoitePlayerAuras.GetActiveAuraSlot(spellName)
  local buffSlot = DoitePlayerAuras.activeBuffs[spellName]
  if buffSlot then
    return buffSlot - 1 -- 0-31
  end

  local debuffSlot = DoitePlayerAuras.activeDebuffs[spellName]
  if debuffSlot then
    return MAX_BUFF_SLOTS + debuffSlot - 1 -- 32-47
  end

  return nil
end

function DoitePlayerAuras.GetActiveAuraSlotBySpellId(spellId)
  spellId = tonumber(spellId) or 0
  if spellId <= 0 then
    return nil
  end

  local buffSlot = DoitePlayerAuras.activeBuffSpellIds[spellId]
  if buffSlot then
    return buffSlot - 1 -- 0-31
  end

  local debuffSlot = DoitePlayerAuras.activeDebuffSpellIds[spellId]
  if debuffSlot then
    return MAX_BUFF_SLOTS + debuffSlot - 1 -- 32-47
  end

  return nil
end

-- Nampower 的 auraApplications 通常已经包含光环层数，但部分按次数
-- 消耗的增益会把真实充能暴露在 GetPlayerBuffApplications 或增强版
-- UnitBuff 中。取三种来源中的最大有效值，既保留普通堆叠光环，也能
-- 正确显示横扫攻击、闪电盾一类的剩余次数。
local function GetBestBuffStacks(spellId, cachedSlot, cachedStacks)
  local best = tonumber(cachedStacks)
  if not best or best < 1 then
    best = 1
  end

  if GetPlayerBuffApplications and cachedSlot then
    local applications =
        tonumber(GetPlayerBuffApplications(cachedSlot - 1))
    if applications and applications > best then
      best = applications
    end
  end

  if UnitBuff then
    for i = 1, MAX_BUFF_SLOTS do
      local texture, applications, auraId = UnitBuff("player", i)
      if not texture then
        break
      end
      if tonumber(auraId) == tonumber(spellId) then
        applications = tonumber(applications)
        if applications and applications > best then
          best = applications
        end
        break
      end
    end
  end

  return best
end

function DoitePlayerAuras.GetBuffStacks(spellName)
  -- 检查法术是否活跃并获取缓存的槽位
  local cachedSlot = DoitePlayerAuras.activeBuffs[spellName]
  if not cachedSlot then
    -- 检查是否被缓冲上限隐藏
    if DoitePlayerAuras.IsHiddenByBuffCap(spellName) then
      return DoitePlayerAuras.cappedBuffsStacks[spellName]
    end

    return nil
  end

  local spellId = DoitePlayerAuras.spellNameToIdCache[spellName]
  if not spellId then
    return nil
  end

  -- 首先检查缓存的槽位
  if DoitePlayerAuras.buffs[cachedSlot] and DoitePlayerAuras.buffs[cachedSlot].spellId == spellId then
    return GetBestBuffStacks(
        spellId,
        cachedSlot,
        DoitePlayerAuras.buffs[cachedSlot].stacks
    )
  end

  -- 回退：搜索所有增益槽位以匹配法术 ID
  for i = 1, MAX_BUFF_SLOTS do
    if not DoitePlayerAuras.buffs[i].spellId then
      break
    end

    if DoitePlayerAuras.buffs[i].spellId == spellId then
      return GetBestBuffStacks(
          spellId,
          i,
          DoitePlayerAuras.buffs[i].stacks
      )
    end
  end

  return nil
end

function DoitePlayerAuras.GetBuffStacksBySpellId(spellId)
  local cachedSlot = DoitePlayerAuras.HasBuffSpellId(spellId)
  if not cachedSlot then
    return nil
  end

  if DoitePlayerAuras.buffs[cachedSlot] and DoitePlayerAuras.buffs[cachedSlot].spellId == spellId then
    return GetBestBuffStacks(
        spellId,
        cachedSlot,
        DoitePlayerAuras.buffs[cachedSlot].stacks
    )
  end

  for i = 1, MAX_BUFF_SLOTS do
    if not DoitePlayerAuras.buffs[i].spellId then
      break
    end

    if DoitePlayerAuras.buffs[i].spellId == spellId then
      return GetBestBuffStacks(
          spellId,
          i,
          DoitePlayerAuras.buffs[i].stacks
      )
    end
  end

  return nil
end

function DoitePlayerAuras.GetDebuffStacks(spellName)
  -- 检查是否活跃并获取缓存的槽位
  local cachedSlot = DoitePlayerAuras.activeDebuffs[spellName]
  if not cachedSlot then
    return nil
  end

  local spellId = DoitePlayerAuras.spellNameToIdCache[spellName]
  if not spellId then
    return nil
  end

  -- 首先检查缓存的槽位
  if DoitePlayerAuras.debuffs[cachedSlot] and DoitePlayerAuras.debuffs[cachedSlot].spellId == spellId then
    return DoitePlayerAuras.debuffs[cachedSlot].stacks
  end

  -- 回退：搜索所有减益槽位以匹配法术 ID
  for i = 1, MAX_DEBUFF_SLOTS do
    if not DoitePlayerAuras.debuffs[i].spellId then
      break
    end

    if DoitePlayerAuras.debuffs[i].spellId == spellId then
      return DoitePlayerAuras.debuffs[i].stacks
    end
  end

  return nil
end

function DoitePlayerAuras.GetDebuffStacksBySpellId(spellId)
  local cachedSlot = DoitePlayerAuras.HasDebuffSpellId(spellId)
  if not cachedSlot then
    return nil
  end

  if DoitePlayerAuras.debuffs[cachedSlot] and DoitePlayerAuras.debuffs[cachedSlot].spellId == spellId then
    return DoitePlayerAuras.debuffs[cachedSlot].stacks
  end

  for i = 1, MAX_DEBUFF_SLOTS do
    if not DoitePlayerAuras.debuffs[i].spellId then
      break
    end

    if DoitePlayerAuras.debuffs[i].spellId == spellId then
      return DoitePlayerAuras.debuffs[i].stacks
    end
  end

  return nil
end

function DoitePlayerAuras.GetHiddenBuffRemaining(spellName)
  local expirationTime = DoitePlayerAuras.cappedBuffsExpirationTime[spellName]
  if expirationTime and expirationTime > 0 then
    local remaining = expirationTime - GetTime()
    if remaining > 0 then
      return remaining
    end
    -- 已过期，移除缓冲上限的增益
    RemoveCappedBuff(spellName)
  end
  return nil
end

-- 调试辅助函数：用于 UI 显示的计数。
-- 这些计数是“客户端可见 + 跟踪的隐藏光环”。
function DoitePlayerAuras.GetVisibleAuraCounts()
  local buffCount = 0
  local debuffCount = 0

  for i = 1, MAX_BUFF_SLOTS do
    local aura = DoitePlayerAuras.buffs[i]
    if aura and aura.spellId and aura.spellId ~= 0 then
      buffCount = buffCount + 1
    end
  end

  for i = 1, MAX_DEBUFF_SLOTS do
    local aura = DoitePlayerAuras.debuffs[i]
    if aura and aura.spellId and aura.spellId ~= 0 then
      debuffCount = debuffCount + 1
    end
  end

  return buffCount, debuffCount
end

function DoitePlayerAuras.GetTrackedHiddenBuffCount()
  local now = GetTime()
  local count = 0

  for _, expiration in pairs(DoitePlayerAuras.cappedBuffsExpirationTime) do
    if expiration and expiration > now then
      count = count + 1
    end
  end

  return count
end

function DoitePlayerAuras.GetAuraCountSummary()
  local buffs, debuffs = DoitePlayerAuras.GetVisibleAuraCounts()
  local hidden = DoitePlayerAuras.GetTrackedHiddenBuffCount()
  return buffs, debuffs, hidden, (buffs + debuffs + hidden)
end

-- PLAYER_ENTERING_WORLD 事件的框架
local PlayerEnteringWorldFrame = CreateFrame("Frame", "DoitePlayerAuras_PlayerEnteringWorld")
PlayerEnteringWorldFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
PlayerEnteringWorldFrame:SetScript("OnEvent", function()
  if not DoitePlayerAuras.debugBuffCap then
    UpdateAuras()
  end

  local _, guid = UnitExists("player")
  DoitePlayerAuras.playerGuid = guid or ""

  -- 如果达到缓冲上限，启用额外事件
  if DoitePlayerAuras.numActiveBuffs >= MAX_BUFF_SLOTS or DoitePlayerAuras.debugBuffCap then
    DoitePlayerAuras.RegisterBuffCapEvents()
  end
end)

-- BUFF_ADDED_SELF 事件的框架
local BuffAddedFrame = CreateFrame("Frame", "DoitePlayerAuras_BuffAdded")
if not DoitePlayerAuras.debugBuffCap then
  BuffAddedFrame:RegisterEvent("BUFF_ADDED_SELF")
end
BuffAddedFrame:SetScript("OnEvent", function()
  local spellId = arg3
  local stacks = arg4
  local auraSlot = arg6 -- 0 为基础的原始槽位（0-31 用于增益）
  local state = arg7 -- 0=添加，1=移除，2=修改（层数更改）

  local slot = auraSlot + 1 -- 转换为 1 基础，用于内部 buffs 表
  DoitePlayerAuras.buffs[slot].spellId = spellId
  DoitePlayerAuras.buffs[slot].stacks = stacks
  MarkActive(spellId, DoitePlayerAuras.activeBuffs, slot)

  if state == 0 then
    -- 新添加
    DoitePlayerAuras.numActiveBuffs = DoitePlayerAuras.numActiveBuffs + 1

    if DoitePlayerAuras.numActiveBuffs >= MAX_BUFF_SLOTS or DoitePlayerAuras.debugBuffCap then
      DoitePlayerAuras.RegisterBuffCapEvents()
    end
  end
end)

-- BUFF_REMOVED_SELF 事件的框架
local BuffRemovedFrame = CreateFrame("Frame", "DoitePlayerAuras_BuffRemoved")
if not DoitePlayerAuras.debugBuffCap then
  BuffRemovedFrame:RegisterEvent("BUFF_REMOVED_SELF")
end
BuffRemovedFrame:SetScript("OnEvent", function()
  local spellId = arg3
  local stacks = arg4
  local auraSlot = arg6 -- 0 为基础的原始槽位（0-31 用于增益）
  local state = arg7 -- 0=添加，1=移除，2=修改（层数减少）

  local slot = auraSlot + 1 -- 转换为 1 基础，用于内部 buffs 表

  if state == 1 then
    -- 完全移除
    DoitePlayerAuras.buffs[slot].spellId = nil
    DoitePlayerAuras.buffs[slot].stacks = nil
    MarkInactive(spellId, DoitePlayerAuras.activeBuffs)
    DoitePlayerAuras.numActiveBuffs = DoitePlayerAuras.numActiveBuffs - 1

    if DoitePlayerAuras.buffCapEventsEnabled then
      -- 检查是否有任何缓冲上限的增益仍然活跃，然后再取消注册
      local hasActiveCappedBuffs = false
      for _, expiration in pairs(DoitePlayerAuras.cappedBuffsExpirationTime) do
        if expiration > GetTime() then
          hasActiveCappedBuffs = true
          break
        end
      end
      if not hasActiveCappedBuffs then
        DoitePlayerAuras.UnregisterBuffCapEvents()
      end
    end
  else
    -- state == 2，层数减少
    DoitePlayerAuras.buffs[slot].stacks = stacks
  end
end)

-- DEBUFF_ADDED_SELF 事件的框架
local DebuffAddedFrame = CreateFrame("Frame", "DoitePlayerAuras_DebuffAdded")
if not DoitePlayerAuras.debugBuffCap then
  DebuffAddedFrame:RegisterEvent("DEBUFF_ADDED_SELF")
end
DebuffAddedFrame:SetScript("OnEvent", function()
  local spellId = arg3
  local stacks = arg4
  local auraSlot = arg6 -- 0 为基础的原始槽位（32-47 用于减益）
  local state = arg7 -- 0=添加，1=移除，2=修改（层数更改）

  local slot = auraSlot - MAX_BUFF_SLOTS + 1 -- 转换为 1 基础的减益索引（1-16）
  DoitePlayerAuras.debuffs[slot].spellId = spellId
  DoitePlayerAuras.debuffs[slot].stacks = stacks
  MarkActive(spellId, DoitePlayerAuras.activeDebuffs, slot)

  if state == 0 then
    -- 新添加
    DoitePlayerAuras.numActiveDebuffs = DoitePlayerAuras.numActiveDebuffs + 1
  end
end)

-- DEBUFF_REMOVED_SELF 事件的框架
local DebuffRemovedFrame = CreateFrame("Frame", "DoitePlayerAuras_DebuffRemoved")
if not DoitePlayerAuras.debugBuffCap then
  DebuffRemovedFrame:RegisterEvent("DEBUFF_REMOVED_SELF")
end
DebuffRemovedFrame:SetScript("OnEvent", function()
  local spellId = arg3
  local stacks = arg4
  local auraSlot = arg6 -- 0 为基础的原始槽位（32-47 用于减益）
  local state = arg7 -- 0=添加，1=移除，2=修改（层数减少）

  local slot = auraSlot - MAX_BUFF_SLOTS + 1 -- 转换为 1 基础的减益索引（1-16）

  if state == 1 then
    -- 完全移除
    DoitePlayerAuras.debuffs[slot].spellId = nil
    DoitePlayerAuras.debuffs[slot].stacks = nil
    MarkInactive(spellId, DoitePlayerAuras.activeDebuffs)
    DoitePlayerAuras.numActiveDebuffs = DoitePlayerAuras.numActiveDebuffs - 1
  else
    -- state == 2，层数减少
    DoitePlayerAuras.debuffs[slot].stacks = stacks
  end
end)

-- AURA_CAST_ON_SELF 事件的框架（在缓冲上限期间动态注册）
local AuraCastFrame = CreateFrame("Frame", "DoitePlayerAuras_AuraCast")
AuraCastFrame:SetScript("OnEvent", function()
  -- 仅在达到缓冲上限时关心增益
  -- int auraCapStatus - 位域：1 = 增益条满，2 = 减益条满（3 表示两者都满）
  local spellId, durationMs, auraCapStatus = arg1, arg8, arg9

  local applyCappedBuff = auraCapStatus == 1 or auraCapStatus == 3 or DoitePlayerAuras.debugBuffCap



  -- 双重检查我们是否达到了缓冲上限
  if applyCappedBuff then
    -- 如果尚未缓存法术名称，则缓存
    local spellName = DoitePlayerAuras.spellIdToNameCache[spellId]
    if not spellName then
      spellName = GetSpellRecField(spellId, "name")
      if spellName then
        DoitePlayerAuras.spellIdToNameCache[spellId] = spellName
        DoitePlayerAuras.spellNameToIdCache[spellName] = spellId
      else
        return
      end
    end

    -- 缓存法术的最大层数
    if not DoitePlayerAuras.spellNameToMaxStacks[spellName] then
      local maxStacks = GetSpellRecField(spellId, "stackAmount")
      if maxStacks == 0 then
        maxStacks = 1
      end
      DoitePlayerAuras.spellNameToMaxStacks[spellName] = maxStacks
    end

    -- 如果已过期，清除之前的层数
    local expirationTime = DoitePlayerAuras.cappedBuffsExpirationTime[spellName]
    if expirationTime and expirationTime > 0 and expirationTime <= GetTime() then
      DoitePlayerAuras.cappedBuffsStacks[spellName] = 0
    end

    DoitePlayerAuras.cappedBuffsExpirationTime[spellName] = GetTime() + durationMs / 1000.0

    -- 增加层数，上限为最大层数
    local currentStacks = DoitePlayerAuras.cappedBuffsStacks[spellName] or 0
    local maxStacks = DoitePlayerAuras.spellNameToMaxStacks[spellName] or 1

    DoitePlayerAuras.cappedBuffsStacks[spellName] = math.min(currentStacks + 1, maxStacks)
  end
end)

-- 处理可能消耗层数或节能施法的法术施放的共享逻辑
local function ProcessBuffCappedSpell(spellId, casterGUID, targetGUID)
  if DoiteBuffData.stackModifiers[spellId] then
    local modifiedBuffName = DoiteBuffData.stackModifiers[spellId].modifiedBuffName
    local stackChange = DoiteBuffData.stackModifiers[spellId].stackChange

    local currentStacks = DoitePlayerAuras.cappedBuffsStacks[modifiedBuffName] or 0

    if stackChange > 0 then
      local maxStacks = DoitePlayerAuras.spellNameToMaxStacks[modifiedBuffName] or 1
      local newStacks = math.min(currentStacks + stackChange, maxStacks)
      DoitePlayerAuras.cappedBuffsStacks[modifiedBuffName] = newStacks

      local duration = DoiteBuffData.stackModifiers[spellId].duration
      if duration then
        DoitePlayerAuras.cappedBuffsExpirationTime[modifiedBuffName] = GetTime() + duration
      end
    elseif stackChange < 0 and currentStacks > 0 then
      local newStacks = math.max(0, currentStacks + stackChange)
      DoitePlayerAuras.cappedBuffsStacks[modifiedBuffName] = newStacks

      if newStacks == 0 then
        RemoveCappedBuff(modifiedBuffName)
      end
    end
  end
  -- 检查节能施法
  if DoitePlayerAuras.IsHiddenByBuffCap("节能施法") and
      targetGUID ~= casterGUID then
    -- 在施放任何消耗法力且不指向自己的法术后移除节能施法增益
    -- 不完美，因为对他人施放的增益也会移除，但相当好
    local manaCost = GetSpellRecField(spellId, "manaCost")
    if manaCost and manaCost > 0 then
      RemoveCappedBuff("节能施法")
    end
  end
end

-- SPELL_GO_SELF 事件的框架
local SpellGoSelfFrame = CreateFrame("Frame", "DoitePlayerAuras_SpellGoSelf")
SpellGoSelfFrame:SetScript("OnEvent", function()
  local spellId = arg2
  local casterGUID = arg3
  local targetGUID = arg4
  ProcessBuffCappedSpell(spellId, casterGUID, targetGUID)
end)

-- SPELL_CHANNEL_START 事件的框架（当玩家开始或更新引导法术时触发）
local SpellChannelStartFrame = CreateFrame("Frame", "DoitePlayerAuras_SpellChannelStart")
SpellChannelStartFrame:SetScript("OnEvent", function()
  local spellId = arg1
  local targetGUID = arg2 -- 来自 ChannelTargetGuid，如果没有则为 "0x0000000000000000"
  -- arg3 = durationMs（用于层数/节能施法逻辑，未使用）
  ProcessBuffCappedSpell(spellId, DoitePlayerAuras.playerGuid, targetGUID)
end)

function DoitePlayerAuras.RegisterBuffCapEvents()
  if DoitePlayerAuras.buffCapEventsEnabled then
    return
  end
  DoitePlayerAuras.buffCapEventsEnabled = true
  AuraCastFrame:RegisterEvent("AURA_CAST_ON_SELF")
  SpellGoSelfFrame:RegisterEvent("SPELL_GO_SELF")
  SpellChannelStartFrame:RegisterEvent("SPELL_CHANNEL_START")
end

-- 目前未使用，因为很难知道何时可以安全取消注册这些事件
-- 即使某人低于缓冲上限后，让它们保持注册应该不是问题
function DoitePlayerAuras.UnregisterBuffCapEvents()
  if not DoitePlayerAuras.buffCapEventsEnabled then
    return
  end
  DoitePlayerAuras.buffCapEventsEnabled = false
  AuraCastFrame:UnregisterEvent("AURA_CAST_ON_SELF")
  SpellGoSelfFrame:UnregisterEvent("SPELL_GO_SELF")
  SpellChannelStartFrame:UnregisterEvent("SPELL_CHANNEL_START")
end

function DoitePlayerAuras.SetDebugBuffCap(enabled)
  local want = (enabled == true)
  if DoitePlayerAuras.debugBuffCap == want then
    return
  end

  DoitePlayerAuras.debugBuffCap = want

  if DoitePlayerAuras.debugBuffCap then
    -- 启用调试模式：取消注册正常事件并注册缓冲上限事件
    BuffAddedFrame:UnregisterEvent("BUFF_ADDED_SELF")
    BuffRemovedFrame:UnregisterEvent("BUFF_REMOVED_SELF")
    DebuffAddedFrame:UnregisterEvent("DEBUFF_ADDED_SELF")
    DebuffRemovedFrame:UnregisterEvent("DEBUFF_REMOVED_SELF")
    DoitePlayerAuras.RegisterBuffCapEvents()
    print("DoitePlayerAuras: 调试缓冲上限已启用 - 模拟缓冲上限行为")
  else
    -- 禁用调试模式：注册正常事件并取消注册缓冲上限事件
    BuffAddedFrame:RegisterEvent("BUFF_ADDED_SELF")
    BuffRemovedFrame:RegisterEvent("BUFF_REMOVED_SELF")
    DebuffAddedFrame:RegisterEvent("DEBUFF_ADDED_SELF")
    DebuffRemovedFrame:RegisterEvent("DEBUFF_REMOVED_SELF")
    DoitePlayerAuras.UnregisterBuffCapEvents()
    -- 刷新增益/减益状态
	UpdateAuras()
    print("DoitePlayerAuras: 调试缓冲上限已禁用")
  end
end

function DoitePlayerAuras.ToggleDebugBuffCap()
  DoitePlayerAuras.SetDebugBuffCap(not DoitePlayerAuras.debugBuffCap)
end
