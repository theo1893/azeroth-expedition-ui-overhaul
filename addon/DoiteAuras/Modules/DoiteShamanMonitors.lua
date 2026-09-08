---------------------------------------------------------------
-- DoiteShamanMonitors.lua
-- 元素萨满现有监控的语义分组，以及相对 DoiteDPS 时间轴的跟随定位。
-- 只迁移和整理已经存在的监控，不改动其触发、冷却或自定义判断逻辑。
---------------------------------------------------------------

local PRESET_VERSION = 3
local FOLLOW_INTERVAL = 0.10
local CLEARCASTING_TEXTURE =
    "Interface\\Icons\\Spell_Shadow_ManaBurn"

local locale = (GetLocale and GetLocale()) or "zhCN"
local zh = locale == "zhCN" or locale == "zhTW"

local function LocalName(zhName, enName)
  if zh then
    return zhName
  end
  return enName
end

local GROUP_BURST =
    LocalName("萨满手动爆发", "Shaman Manual Burst")
local GROUP_PROCS =
    LocalName("萨满触发增益", "Shaman Proc Effects")
local GROUP_COOLDOWNS =
    LocalName("萨满技能冷却", "Shaman Ability Cooldowns")
local GROUP_TARGET =
    LocalName("萨满目标状态", "Shaman Target Effects")
local GROUP_TOTEMS =
    LocalName("萨满图腾状态", "Shaman Totem Effects")

local REAL_CLEARCASTING_SOURCE = [[
local rank = nil
if type(DoiteAuras_GetRealClearcastingRank) == "function" then
  rank = DoiteAuras_GetRealClearcastingRank()
end

if rank == nil then
  rank = 0
  local index = 1
  while index <= 32 do
    local texture, applications = UnitBuff("player", index)
    if texture == "Interface\\Icons\\Spell_Shadow_ManaBurn" then
      rank = tonumber(applications) or 1
      break
    end
    index = index + 1
  end
end

rank = tonumber(rank) or 0
if rank < 0 then
  rank = 0
end
rank = math.floor(rank + 0.5)

local remaining = nil
if rank > 0
    and type(DoiteAuras_GetPlayerAuraRemainingSeconds) == "function" then
  local ok, value = pcall(
      DoiteAuras_GetPlayerAuraRemainingSeconds,
      "节能施法",
      46761,
      true
  )
  if ok then
    remaining = tonumber(value)
  end
end

return rank > 0,
    "Interface\\Icons\\Spell_Shadow_ManaBurn",
    false,
    remaining,
    rank
]]

local function GetRealClearcastingRank()
  local getter = _G["EleDPS_GetClearcastingRank"]
  if type(getter) ~= "function" then
    return nil
  end

  local ok, value = pcall(getter)
  if not ok then
    return nil
  end

  local rank = tonumber(value)
  if not rank then
    return nil
  end
  if rank < 0 then
    rank = 0
  end
  return math.floor(rank + 0.5)
end

_G["DoiteAuras_GetRealClearcastingRank"] =
    GetRealClearcastingRank

-- DoiteDPS 无框时间轴为 318x46；五组分别排列在时间轴的上方和
-- 下方，并与战士监控使用相同的垂直间距。
local GROUPS = {
  {
    name = GROUP_BURST,
    dx = -114,
    dy = 42,
    iconSize = 24,
    spacing = 5,
    limit = 1,
    leaderId = "elementalMastery",
    label = LocalName("爆发", "BURST"),
    labelWidth = zh and 36 or 48,
    labelSide = "TOP",
    labelColor = { 1.00, 0.67, 0.20 },
  },
  {
    name = GROUP_PROCS,
    dx = 35,
    dy = 42,
    iconSize = 24,
    spacing = 5,
    limit = 3,
    leaderId = "clearcasting",
    label = LocalName("触发", "PROCS"),
    labelWidth = zh and 36 or 48,
    labelSide = "TOP",
    labelColor = { 0.36, 1.00, 0.55 },
  },
  {
    name = GROUP_COOLDOWNS,
    dx = -105,
    dy = -42,
    iconSize = 24,
    spacing = 5,
    limit = 2,
    leaderId = "earthquake",
    label = LocalName("冷却", "COOLDOWN"),
    labelWidth = zh and 36 or 70,
    labelSide = "BOTTOM",
    labelColor = { 0.35, 0.72, 1.00 },
  },
  {
    name = GROUP_TARGET,
    dx = -15,
    dy = -42,
    iconSize = 24,
    spacing = 5,
    limit = 1,
    leaderId = "flameShock",
    label = LocalName("目标", "TARGET"),
    labelWidth = zh and 36 or 52,
    labelSide = "BOTTOM",
    labelColor = { 1.00, 0.38, 0.28 },
  },
  {
    name = GROUP_TOTEMS,
    dx = 95,
    dy = -42,
    iconSize = 24,
    spacing = 5,
    limit = 2,
    leaderId = "fireTotemTimer",
    label = LocalName("图腾", "TOTEMS"),
    labelWidth = zh and 36 or 54,
    labelSide = "BOTTOM",
    labelColor = { 0.30, 0.90, 1.00 },
  },
}

if DoiteAurasMonitorLabels
    and DoiteAurasMonitorLabels.Register then
  DoiteAurasMonitorLabels:Register("SHAMAN", GROUPS)
end

local TARGETS = {
  {
    id = "elementalMastery",
    kind = "Ability",
    aliases = { "元素掌握", "Elemental Mastery" },
    group = GROUP_BURST,
    order = 6,
  },
  {
    id = "clearcasting",
    kind = "Buff",
    kinds = { "Buff", "Custom" },
    aliases = { "节能施法", "Clearcasting" },
    group = GROUP_PROCS,
    order = 9,
    showStacks = true,
    realClearcasting = true,
  },
  {
    id = "stormwolfCunning",
    kind = "Buff",
    aliases = {
      "风暴之狼的狡诈",
      "Stormwolf's Cunning",
      "Cunning of the Stormwolf",
    },
    group = GROUP_PROCS,
    order = 10,
  },
  {
    id = "seismicStrength",
    kind = "Buff",
    aliases = { "Seismic Strength", "震地之力" },
    group = GROUP_PROCS,
    order = 11,
  },
  {
    id = "earthquake",
    kind = "Ability",
    aliases = { "地震术", "Earthquake" },
    group = GROUP_COOLDOWNS,
    order = 2,
  },
  {
    id = "chainLightning",
    kind = "Ability",
    aliases = { "闪电链", "Chain Lightning" },
    group = GROUP_COOLDOWNS,
    order = 3,
  },
  {
    id = "flameShock",
    kind = "Debuff",
    aliases = { "烈焰震击", "Flame Shock" },
    group = GROUP_TARGET,
    order = 18,
  },
  {
    id = "fireTotemTimer",
    kind = "Custom",
    aliases = {
      "火焰图腾持续时间",
      "Fire Totem Duration",
    },
    group = GROUP_TOTEMS,
    order = 19,
  },
}

local LEGACY_GROUPS = {
  "Group 1 (4)",
  "Group 2 (4)",
  "Group 4 (2)",
}

local LEGACY_TOTEM_GROUPS = {
  "风系图腾",
  "Wind Totems",
}

local function IsLegacyTotemGroup(groupName)
  local index
  for index = 1, table.getn(LEGACY_TOTEM_GROUPS) do
    if groupName == LEGACY_TOTEM_GROUPS[index] then
      return true
    end
  end
  return false
end

local groupByName = {}
local leaderKeys = {}
local i
for i = 1, table.getn(GROUPS) do
  groupByName[GROUPS[i].name] = GROUPS[i]
end

local function IsShaman()
  if not UnitClass then
    return false
  end
  local localized, classTag = UnitClass("player")
  classTag = classTag and string.upper(classTag) or ""
  return classTag == "SHAMAN"
      or localized == "萨满祭司"
      or localized == "萨满"
end

local function RefreshPreset()
  if DoiteAuras_RefreshList then
    pcall(DoiteAuras_RefreshList)
  end
  if DoiteAuras_RefreshIcons then
    pcall(DoiteAuras_RefreshIcons)
  end
  if DoiteConditions_RequestEvaluate then
    pcall(DoiteConditions_RequestEvaluate)
  end
  if DoiteGroup and DoiteGroup.RequestReflow then
    pcall(DoiteGroup.RequestReflow)
  else
    _G["DoiteGroup_NeedReflow"] = true
  end
end

local function RequestReflow()
  if DoiteGroup and DoiteGroup.RequestReflow then
    pcall(DoiteGroup.RequestReflow)
  else
    _G["DoiteGroup_NeedReflow"] = true
  end
end

local function MatchesAlias(value, target)
  if not value then
    return false
  end
  local aliasIndex
  for aliasIndex = 1, table.getn(target.aliases) do
    if value == target.aliases[aliasIndex] then
      return true
    end
  end
  return false
end

local function MatchesTarget(key, data, target)
  if not data then
    return false
  end

  local kindMatches = data.type == target.kind
  if target.kinds then
    kindMatches = false
    local kindIndex
    for kindIndex = 1, table.getn(target.kinds) do
      if data.type == target.kinds[kindIndex] then
        kindMatches = true
        break
      end
    end
  end
  if not kindMatches then
    return false
  end

  return MatchesAlias(data.displayName, target)
      or MatchesAlias(data.shownName, target)
      or MatchesAlias(data.name, target)
      or MatchesAlias(key, target)
end

local function FindEntry(target)
  local spells = DoiteAurasDB and DoiteAurasDB.spells
  if not spells then
    return nil, nil
  end

  local fallbackKey, fallbackData
  local key, data
  for key, data in pairs(spells) do
    if MatchesTarget(key, data, target) then
      local legacyIndex
      for legacyIndex = 1, table.getn(LEGACY_GROUPS) do
        if data.group == LEGACY_GROUPS[legacyIndex] then
          return key, data
        end
      end
      if not fallbackData then
        fallbackKey = key
        fallbackData = data
      end
    end
  end
  return fallbackKey, fallbackData
end

local function GetTimelineAnchor()
  local ui = UIParent
  if not ui or not ui.GetCenter then
    return 0, -125, 1
  end

  local uiX, uiY = ui:GetCenter()
  local uiScale =
      (ui.GetEffectiveScale and ui:GetEffectiveScale()) or 1
  if not uiX or not uiY or not uiScale or uiScale <= 0 then
    return 0, -125, 1
  end

  local root = _G["DoiteDPSMainFrame"]
  if not root or not root.GetCenter then
    return 0, -125, 1
  end

  local rootX, rootY = root:GetCenter()
  if not rootX or not rootY then
    return 0, -125, 1
  end

  local rootScale =
      (root.GetEffectiveScale and root:GetEffectiveScale()) or uiScale
  if not rootScale or rootScale <= 0 then
    rootScale = uiScale
  end

  local centerX = ((rootX * rootScale) - (uiX * uiScale)) / uiScale
  local centerY = ((rootY * rootScale) - (uiY * uiScale)) / uiScale
  return centerX, centerY, rootScale / uiScale
end

local function RoundTenth(value)
  if value >= 0 then
    return math.floor(value * 10 + 0.5) / 10
  end
  return math.ceil(value * 10 - 0.5) / 10
end

local function FindLeaderKey(groupName)
  local cached = leaderKeys[groupName]
  local spells = DoiteAurasDB and DoiteAurasDB.spells
  if cached and spells and spells[cached]
      and spells[cached].group == groupName
      and spells[cached].isLeader == true then
    return cached
  end

  if not spells then
    return nil
  end
  local key, data
  for key, data in pairs(spells) do
    if data and data.group == groupName and data.isLeader == true then
      leaderKeys[groupName] = key
      return key
    end
  end
  return nil
end

local function SyncAnchors(force)
  if not IsShaman() or not DoiteAurasDB or not DoiteAurasDB.spells then
    return false
  end
  if DoiteAurasDB.shamanMonitorsFollowDoiteDPS == false then
    return false
  end
  if _G["DoiteEdit_CurrentKey"] and not force then
    return false
  end

  local centerX, centerY, relativeScale = GetTimelineAnchor()
  local changed = false
  local groupIndex
  for groupIndex = 1, table.getn(GROUPS) do
    local group = GROUPS[groupIndex]
    local leaderKey = FindLeaderKey(group.name)
    local leader = leaderKey and DoiteAurasDB.spells[leaderKey]
    if leader then
      local x = RoundTenth(centerX + group.dx * relativeScale)
      local y = RoundTenth(centerY + group.dy * relativeScale)
      local oldX = tonumber(leader.offsetX) or 0
      local oldY = tonumber(leader.offsetY) or 0
      if math.abs(oldX - x) > 0.05 or math.abs(oldY - y) > 0.05 then
        leader.point = "CENTER"
        leader.relativePoint = "CENTER"
        leader.offsetX = x
        leader.offsetY = y
        changed = true
      end
    end
  end

  if changed then
    RequestReflow()
  end
  return changed
end

local function ConfigureTargets(centerX, centerY, relativeScale)
  local spells = DoiteAurasDB.spells
  local entriesById = {}
  local membersByGroup = {}
  local fallbackLeaders = {}
  local targetIndex

  for targetIndex = 1, table.getn(TARGETS) do
    local target = TARGETS[targetIndex]
    local key, data = FindEntry(target)
    local group = groupByName[target.group]
    if data and group then
      data.group = group.name
      data.isLeader = false
      data.iconSize = group.iconSize
      data.growth = "水平居中"
      data.numAuras = group.limit
      data.spacing = group.spacing
      data.order = target.order
      data.doiteShamanMonitorPreset = PRESET_VERSION

      if target.showStacks and data.conditions
          and data.conditions.aura then
        data.conditions.aura.textStackCounter = true
      end

      if target.realClearcasting then
        data.type = "Custom"
        data.iconTexture = CLEARCASTING_TEXTURE
        data.customFunctionSource = REAL_CLEARCASTING_SOURCE
        data.doiteRealClearcasting = PRESET_VERSION
        data._daCustomCompiled = nil
        data._daCustomCompiledSrc = nil
        data._daCustomRuntime = nil
      end

      entriesById[target.id] = {
        key = key,
        data = data,
      }
      membersByGroup[group.name] =
          membersByGroup[group.name] or {}
      local members = membersByGroup[group.name]
      members[table.getn(members) + 1] = entriesById[target.id]

      local displayName = data.displayName or data.shownName
      if displayName and data.iconTexture then
        DoiteAurasDB.cache[displayName] = data.iconTexture
      end
    end
  end

  -- 风系图腾原本已经是一组完整的职业监控。将整组并入萨满图腾
  -- 状态，而不是逐个重建，以完整保留玩家已有的触发条件和图标。
  local key, data
  for key, data in pairs(spells) do
    if data and IsLegacyTotemGroup(data.group) then
      local group = groupByName[GROUP_TOTEMS]
      local wasLeader = data.isLeader == true
      local entry = {
        key = key,
        data = data,
      }

      data.group = group.name
      data.isLeader = false
      data.iconSize = group.iconSize
      data.growth = "水平居中"
      data.numAuras = group.limit
      data.spacing = group.spacing
      data.doiteShamanMonitorPreset = PRESET_VERSION

      membersByGroup[group.name] =
          membersByGroup[group.name] or {}
      local members = membersByGroup[group.name]
      members[table.getn(members) + 1] = entry

      if wasLeader and not fallbackLeaders[group.name] then
        fallbackLeaders[group.name] = entry
      end
    end
  end

  local groupIndex
  for groupIndex = 1, table.getn(GROUPS) do
    local group = GROUPS[groupIndex]
    local leaderEntry = entriesById[group.leaderId]
        or fallbackLeaders[group.name]
    if not leaderEntry then
      local members = membersByGroup[group.name]
      leaderEntry = members and members[1] or nil
    end

    if leaderEntry then
      local leader = leaderEntry.data
      leader.isLeader = true
      leader.point = "CENTER"
      leader.relativePoint = "CENTER"
      leader.offsetX =
          RoundTenth(centerX + group.dx * relativeScale)
      leader.offsetY =
          RoundTenth(centerY + group.dy * relativeScale)
      leaderKeys[group.name] = leaderEntry.key
    end
  end
end

local function ConfigureBuckets()
  local groupIndex
  for groupIndex = 1, table.getn(GROUPS) do
    local name = GROUPS[groupIndex].name
    DoiteAurasDB.groupSort[name] = "prio"
    DoiteAurasDB.bucketDisabled[name] = nil
    if DoiteGroup and DoiteGroup._sortCache then
      DoiteGroup._sortCache[name] = nil
    end
  end

  local legacyIndex
  for legacyIndex = 1, table.getn(LEGACY_GROUPS) do
    local name = LEGACY_GROUPS[legacyIndex]
    DoiteAurasDB.groupSort[name] = nil
    DoiteAurasDB.bucketDisabled[name] = true
    if DoiteGroup and DoiteGroup._sortCache then
      DoiteGroup._sortCache[name] = nil
    end
  end

  for legacyIndex = 1, table.getn(LEGACY_TOTEM_GROUPS) do
    local name = LEGACY_TOTEM_GROUPS[legacyIndex]
    DoiteAurasDB.groupSort[name] = nil
    DoiteAurasDB.bucketDisabled[name] = true
    if DoiteGroup and DoiteGroup._sortCache then
      DoiteGroup._sortCache[name] = nil
    end
  end
end

local function InstallPreset()
  if not IsShaman() then
    return true
  end

  DoiteAurasDB = DoiteAurasDB or {}
  DoiteAurasDB.spells = DoiteAurasDB.spells or {}
  DoiteAurasDB.cache = DoiteAurasDB.cache or {}
  DoiteAurasDB.groupSort = DoiteAurasDB.groupSort or {}
  DoiteAurasDB.bucketDisabled = DoiteAurasDB.bucketDisabled or {}

  if DoiteAurasDB.shamanMonitorsFollowDoiteDPS == nil then
    DoiteAurasDB.shamanMonitorsFollowDoiteDPS = true
  end

  if (tonumber(DoiteAurasDB.doiteShamanMonitorPresetVersion) or 0)
      >= PRESET_VERSION then
    return true
  end

  local centerX, centerY, relativeScale = GetTimelineAnchor()
  ConfigureTargets(centerX, centerY, relativeScale)
  ConfigureBuckets()

  DoiteAurasDB.doiteShamanMonitorPresetVersion = PRESET_VERSION
  RefreshPreset()
  return true
end

_G["DoiteAuras_InstallShamanMonitors"] = InstallPreset
_G["DoiteAuras_SyncShamanMonitorAnchors"] = SyncAnchors

local followFrame = CreateFrame(
    "Frame",
    "DoiteAurasShamanMonitorFollower"
)
local followElapsed = 0
followFrame:SetScript("OnUpdate", function()
  followElapsed = followElapsed + (arg1 or 0)
  if followElapsed < FOLLOW_INTERVAL then
    return
  end
  followElapsed = 0
  SyncAnchors(false)
end)

local installerFrame = CreateFrame(
    "Frame",
    "DoiteAurasShamanMonitorInstaller"
)
local pendingDelay = 0
local installElapsed = 0

local function QueueInstall(delay)
  if not IsShaman() then
    installerFrame:Hide()
    followFrame:Hide()
    return
  end
  followFrame:Show()
  pendingDelay = delay or 0.2
  installElapsed = 0
  installerFrame:Show()
end

installerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
installerFrame:RegisterEvent("SPELLS_CHANGED")
installerFrame:SetScript("OnEvent", function()
  QueueInstall(event == "PLAYER_ENTERING_WORLD" and 0.55 or 0.20)
end)
installerFrame:SetScript("OnUpdate", function()
  installElapsed = installElapsed + (arg1 or 0)
  if installElapsed < pendingDelay then
    return
  end

  installElapsed = 0
  InstallPreset()
  this:Hide()
end)

QueueInstall(0.30)
